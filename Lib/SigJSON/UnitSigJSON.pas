unit UnitSigJSON;

(*******************************************************************************
 *                                                                             *
 * This implements JSON as strings, rather than the Delphi implementation      *
 * I found rather hard to come to terms with and implement. The Delphi         *
 * implementation is a rather techie one, I think.                             *
 *                                                                             *
 * Dave Mear.                                                                  *
 *                                                                             *
 * This is a very rigid implementation designed to work the way I do. The      *
 * Object type should be determinable from the name of the top level structure *
 * and hence via the FromJSONType function. From then on in, although other    *
 * is unimportant and fields can be omitted extra fields will raise an         *
 * exception.                                                                  *
 *                                                                             *
 *******************************************************************************)

interface

uses
  System.Classes,
  System.Contnrs,
  System.Generics.Collections,
  System.SysUtils,
  System.StrUtils;

type
  TSigJSONList = class;

  TSigJSONObjectType = ( jotUnknown, jotString, jotNumber, jotBoolean, jotNull, jotObject, jotArray );

  ESigJSONException = class( Exception )

  end;

  TSigJSONObject = class;

  TSigJSONChildClass = class of TSigJSONObject;

  TSigJSONObject = class
  private
    {
      This is kind of like a TSigFileObject and 'knows' how to convert to and from JSON
    }
    function GetChildWithName(const pName: string): TSigJSONObject;
    procedure SetJSONType(const Value: TSigJSONObjectType);
  protected
    fIsDefault : boolean;
    fChildClass : TSigJSONChildClass;
    fJSONName: string;
    fJSONValue : string; // not for compound or array types!
    fChildren : TSigJSONList;  // not for simple types
    fUnsupportedChildren : TSigJSONList;
    fJSONType: TSigJSONObjectType;

    function GetJSONValue: string; virtual;
    procedure SetJSONValue(const Value: string); virtual;
    function GetValueAsBool: boolean; virtual;
    procedure SetValueAsBool(const Value: boolean); virtual;
    procedure SetValueAsInt(const Value: integer); virtual;
    function GetValueAsInt: integer; virtual;
    function GetChildrenCount: integer; virtual;
    function GetChild(const i: integer): TSigJSONObject; virtual;
    function GetUnsupportedChild(const i: integer): TSigJSONObject;
    function AddItemIntrinsic : TSigJSONObject; virtual;
    function GetUnsupportedChildrenCount: integer;
    function GetUnsupportedChildWithName(
      const pName: string): TSigJSONObject;

    function GetJSON: string; virtual;
    procedure SetJSON(const Value: string); virtual;
    procedure FromJSON(var iValue: string); virtual;   // *** Note that this will only be part of the JSON string - the data part.
                                                      // This is akin to the way sigfile works.
    procedure FromJSONString( var iValue : string ); virtual; // this can be overridden by enums
    procedure FromJSONNumber( var iValue : string );
    procedure FromJSONBool( var iValue : string );
    procedure FromJSONNull( var iValue : string );
    procedure FromJSONObject( var iValue : string );
    procedure FromJSONArray( var iValue : string );
    property ValueAsBool : boolean
             read GetValueAsBool
             write SetValueAsBool;
    property ValueAsInt : integer
             read GetValueAsInt
             write SetValueAsInt;

  public
    constructor Create( const pJSONName : string ); virtual;
    destructor Destroy; override;
    property JSONName : string
             read fJSONName;
    property JSONType : TSigJSONObjectType
             read fJSONType
             write SetJSONType;
    property JSON : string
             read GetJSON
             write SetJSON;
             {
               *** JSON Refers to the data portion of a JSON Pair
             }
    property ValueAsText : string
             read GetJSONValue
             write SetJSONValue;
    property UnsupportedChildrenCount : integer
             read GetUnsupportedChildrenCount;
    property UnsupportedChild[ const i : integer ] : TSigJSONObject
             read GetUnsupportedChild;
    property UnsupportedChildWithName[ const pName : string ] : TSigJSONObject
             read GetUnsupportedChildWithName;
    function AddUnsupportedChild( const pName : string ) : TSigJSONObject;

    property ChildrenCount : integer
             read GetChildrenCount;
    property Child[ const i : integer ] : TSigJSONObject
             read GetChild;
    property ChildWithName[ const pName : string ] : TSigJSONObject
             read GetChildWithName;
    function AddChild( const pName : string ) : TSigJSONObject; overload;
    function AddChild( const pClass : TSigJSONChildClass; const pName : string ) : TSigJSONObject; overload;
    function AddChild< T : class >( const pName : string ) : T; overload;
    class function ExtractName( var pString : string ) : string ;
    class function ExtractValueType( const pString : string; const pTerminator : string ) : TSigJSONObjectType;
    function IsDefault : boolean; virtual;
  end;

  TSigJSONList = class( TObjectList< TSigJSONObject > )
  protected
  public
  end;

  TSigJSONTextObject = class( TSigJSONObject )
  private
  public
    constructor Create( const pJSONName : string ); override;
  end;

  TSigJSONIntegerObject = class( TSigJSONObject )
  private
  public
    constructor Create( const pJSONName : string ); override;
    property ValueAsInt;
  end;

  TSigJSONBooleanObject = class( TSigJSONObject )
  public
    constructor Create( const pJSONName : string ); override;
    property ValueAsBool;
  end;

  TSigJSONBooleanTRUEObject = class( TSigJSONBooleanObject )  // default (ignored on write) if FALSE
  public
    function IsDefault : boolean; override;

  end;

  TSigJSONBooleanFALSEObject = class( TSigJSONBooleanObject )  // default (ignored on write) if FALSE
  public
    function IsDefault : boolean; override;

  end;

  TSigJSONCompoundObject = class( TSigJSONObject )
  protected
  public
    constructor Create( const pJSONName : string ); override;
  end;

  TSigJSONArray< T : TSigJSONObject > = class;

  TSigJSONArrayEnnumerator< T : TSigJSONObject > = class
  private
    fIndex : integer;
    fList : TSigJSONArray< T >;
    function GetCurrent :  T ;
  public
    constructor Create( AList : TSigJSONArray< T > );
    function MoveNext : boolean;
    property Current :  T
             read GetCurrent;
  end;

  TSigJSONArray< T : TSigJSONObject > = class( TSigJSONObject )
  private
    function GetItems(const i: integer): T;
    procedure SetItems(const i: integer; const Value: T);
    function GetItemCount: integer;
  protected
    function AddItemIntrinsic : TSigJSONObject; override;
  public
    constructor Create( const pJSONName : string ); override;
    function GetEnumerator : TSigJSONArrayEnnumerator< T >;
    procedure Clear;
    function Add( pValue : T ) : integer;
    function AddItem : T;
    function InsertItem( const pAtPoint : integer ) : T;
    property Items[ const i : integer ] : T
             read GetItems
             write SetItems; default;
    property ItemCount : integer
             read GetItemCount;
    procedure Remove( const pValue : T );
    procedure Delete( const i : integer );
  end;

  TSigJSONObjectList< T : TSigJSONObject > = class( TSigJSONCompoundObject )
  private
    function GetItems(const i: integer): T;
    procedure SetItems(const i: integer; const Value: T);
    function GetItemCount: integer;
  protected
    fItems : TSigJSONArray< T >;
  protected
    function AddItemIntrinsic : TSigJSONObject; override;
  public
    constructor Create( const pJSONName : string ); override;
    procedure Clear;
    function Add( pValue : T ) : integer;
    function AddItem : T;
    property Items[ const i : integer ] : T
             read GetItems
             write SetItems; default;
    property ItemCount : integer
             read GetItemCount;
    procedure Remove( const pValue : T );
  end;

implementation




{ TSigJSONObject }

function TSigJSONObject.AddChild(const pName : string): TSigJSONObject;
begin
  Result := AddChild( TSigJSONObject, pName );
end;

function TSigJSONObject.AddChild(const pClass: TSigJSONChildClass;
  const pName: string): TSigJSONObject;
begin
  Result := pClass.Create( pName );
  fChildren.Add( Result );
end;

function TSigJSONObject.AddChild<T>(const pName: string): T;
var
  iClass : TSigJSONChildClass;
begin
  iClass := TSigJSONChildClass( T );
  Result := T( AddChild( iClass, pName ));
end;

function TSigJSONObject.AddItemIntrinsic: TSigJSONObject;
var
  iArray : TSigJSONObject;
begin
  // adds a nameless child, usually to an array
  case JSONType of
    jotUnknown,
    jotString,
    jotNumber,
    jotBoolean,
    jotNull:
    begin
      Result := AddUnsupportedChild( '' );
      exit;
    end;
    jotObject:
    begin
      iArray := ChildWithName['Items'];
    end;
    jotArray:
    begin
      iArray := self;
    end;
    else
    begin
      Result := AddUnsupportedChild( '' );
      exit;
    end;
  end;
  if assigned( iArray ) then
  begin
    Result := iArray.AddChild( '' );
  end
  else
  begin
    Result := AddUnsupportedChild( '' );
  end;
end;

function TSigJSONObject.AddUnsupportedChild(const pName : string): TSigJSONObject;
begin
  Result := TSigJSONObject.Create( pName );
  fUnsupportedChildren.Add( Result );
end;

constructor TSigJSONObject.Create(const pJSONName: string);
begin
  inherited Create;
  fJSONName := pJSONName;
  fChildClass := TSigJSONObject;
  fChildren := TSigJSONList.Create( TRUE );
  fUnsupportedChildren := TSigJSONList.Create( TRUE );
end;

destructor TSigJSONObject.Destroy;
begin
  fChildren.Free;
  fUnsupportedChildren.Free;
  inherited;
end;

class function TSigJSONObject.ExtractName(var pString: string): string;
var
  iPos : integer;
begin
  pString := Trim( pString );
  if pString = '' then
  begin
    raise ESigJSONException.Create('Missing Name');
  end
  else
  begin
    case pString[ 1 ] of
      '"':
      begin
        iPos := PosEx( '"', pString, 2 );
        if iPos > 2 then
        begin
          Result := Copy( pString, 2, iPos - 2 );
          pString := Copy( pString, iPos + 1 );
        end
        else
        begin
          raise ESigJSONException.Create('Missing Name');
        end;
      end
      else
      begin
        raise ESigJSONException.Create('Missing Name');
      end;
    end;
  end;
end;

class function TSigJSONObject.ExtractValueType(
  const pString: string; const pTerminator : string): TSigJSONObjectType;
var
  iPos1, iPos2 : integer;
  iTest : string;
  iString : string;
begin
  Result := jotUnknown;
  iString := Trim( pString );
  if iString <> '' then
  begin
    case iString[ 1 ] of
      '"' :
      begin
        Result := jotString;
      end;
      '[':
      begin
        Result := jotArray;
      end;
      '{':
      begin
        Result := jotObject;
      end;
      else
      begin
        iPos1 := Pos( ',', iString );
        if pTerminator = '' then
        begin
          iPos2 := 0;
        end
        else
        begin
          iPos2 := Pos( pTerminator, iString );
        end;
        if iPos1 = 0 then
        begin
          if iPos2 = 0 then
          begin
            iTest := iString;
          end
          else
          begin
            iTest := Trim( Copy( iString, 1, iPos2 ));
          end;
        end
        else if iPos2 = 0 then
        begin
          iTest := Trim( Copy( iString, 1, iPos1 ));
        end
        else if iPos2 < iPos1 then
        begin
          iTest := Trim( Copy( iString, 1, iPos2 ));
        end
        else
        begin
          // iPos2 > iPos1 so just use iPos1
          iTest := Trim( Copy( iString, 1, iPos1 ));
        end;
        if SameText( iTest, 'TRUE' )  then  Result := jotBoolean
        else if SameText( iTest, 'FALSE' ) then Result := jotBoolean
        else if SameText( iTest, 'NULL' ) then Result := jotNull
        else
        begin
          try
            StrToFloat( iTest );
            // if does not raise an exception
            Result := jotNumber;
          except
            // allow to stay as jotUnknown
          end;
        end;
      end;
    end;
  end;
end;

function TSigJSONObject.GetChild(const i: integer): TSigJSONObject;
begin
  Result := fChildren[ i ];
end;

function TSigJSONObject.GetChildrenCount: integer;
begin
  Result := fChildren.Count;
end;

function TSigJSONObject.GetChildWithName(const pName: string): TSigJSONObject;
begin
  for Result in fChildren do
  begin
    if SameText( Result.JSONName, pName ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function TSigJSONObject.GetJSON: string;
var
  iChild : TSigJSONObject;
  iSep : string;
begin
  // the data part, which excludes the colon
  case JSONType of
    jotUnknown: raise ESigJSONException.Create('Unknown JSON Type');
    jotString: Result := '"' + ValueAsText + '"';
    jotNumber: Result := IntToStr( ValueAsInt );
    jotBoolean:
    begin
      if ValueAsBool then
      begin
        Result := 'true';
      end
      else
      begin
        Result := 'false';
      end;
    end;
    jotNull: Result := 'null';
    jotObject:
    begin
      Result := '{';
      iSep := '';
      for iChild in fChildren do
      begin
        // don't save defaults
        if not iChild.IsDefault then
        begin
          Result := Result + iSep + '"' + iChild.JSONName + '":' + iChild.JSON;
          iSep := ',';
        end;
      end;
      Result := Result + '}';
    end;
    jotArray:
    begin
      Result := '[';
      iSep := '';
      for iChild in fChildren do
      begin
        Result := Result + iSep + iChild.JSON;
        iSep := ',';
      end;
      Result := Result + ']';
    end;
  end;
end;

function TSigJSONObject.GetJSONValue: string;
var
  i: Integer;
begin
  Result := fJSONValue;
  // put in escape codes
  for i := Length( Result ) downto 1 do
  begin
    case Result[i] of
      '"', '\': Insert( '\', Result, i );
    end;
  end;
end;

function TSigJSONObject.GetUnsupportedChild(
  const i: integer): TSigJSONObject;
begin
  Result := fUnsupportedChildren[ i ];
end;

function TSigJSONObject.GetUnsupportedChildrenCount: integer;
begin
  Result := fUnsupportedChildren.Count;
end;

function TSigJSONObject.GetUnsupportedChildWithName(
  const pName: string): TSigJSONObject;
var
  i : TSigJSONObject;
begin
  Result := nil;
  for i in fUnsupportedChildren do
  begin
    if SameText( i.JSONName, pName ) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TSigJSONObject.GetValueAsBool: boolean;
begin
  if fJSONType = jotBoolean then
  begin
    if SameText(fJSONValue, 'TRUE') then
    begin
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    raise ESigJSONException.Create('Not a boolean value');
  end;
end;

function TSigJSONObject.GetValueAsInt: integer;
begin
  if fJSONValue = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( fJSONValue );
  end;
end;

function TSigJSONObject.IsDefault: boolean;
begin
  if JSONType = jotArray then
  begin
    Result := ChildrenCount = 0;
  end
  else
  begin
    Result := fIsDefault;
  end;
end;

procedure TSigJSONObject.FromJSON(var iValue: string);
var
  iType : TSigJSONObjectType;
begin
  fUnsupportedChildren.Clear;
  iValue := Trim( iValue );
  if iValue = '' then
  begin
    raise ESigJSONException.Create('JSON Syntax error');
  end;
  case iValue[1] of
    '{':  iType := jotObject;
    '"':  iType := jotString;
    '[':  iType := jotArray;
    '0'..'9', '-': iType := jotNumber;
    't','T','f','F': iType := jotBoolean;
    'n', 'N': iType := jotNull;
    else
    begin
      iType := jotUnknown;
    end;
  end;
  JSONType := iType; // this will raise an error if not valid
  case iType of
    jotUnknown: ;
    jotString: FromJSONString( iValue );
    jotNumber: FromJSONNumber( iValue );
    jotBoolean: FromJSONBool( iValue );
    jotNull: FromJSONNull( iValue );
    jotObject: FromJSONObject( iValue );
    jotArray: FromJSONArray( iValue );
  end;
end;

procedure TSigJSONObject.FromJSONArray(var iValue: string);
var
  iChild : TSigJSONObject;
begin
  // very like an object, but children are not named
  fChildren.Clear;
  while True do
  begin
    iValue := Trim( Copy( iValue, 2 ));
    if iValue = '' then
    begin
      raise ESigJSONException.Create('JSON Syntax error');
    end;
    case iValue[ 1 ]  of
      ']' : break; // done  - empty array
    end;
    iChild := AddItemIntrinsic; // array elements have no name
    iChild.FromJSON( iValue );
    iValue := Trim( iValue );
    // now we should have either a ',' or a ']'
    if iValue = '' then
    begin
      raise ESigJSONException.Create('JSON Syntax error');
    end;
    case iValue[ 1 ]  of
      ']' : break; // done
      ',': ; // continue
      else
      begin
        raise ESigJSONException.Create('JSON Syntax error');
      end;
    end;
  end;
  // remove terminating char
  iValue := Trim(Copy( iValue, 2 ));
end;

procedure TSigJSONObject.FromJSONBool(var iValue: string);
var
  iTest : string;
begin
  case iValue[ 1 ] of
    't', 'T':
    begin
      fJSONValue := 'true';
      iTest := Copy( iValue, 1, 4 );
      if SameText( iTest, 'true' ) then
      begin
        iValue := Copy( iValue, 5 );
      end
      else
      begin
        iValue := Copy( iValue, 2 ); // single letter form, or syntax error which will be picked up later
      end;
    end;
    'f', 'F':
    begin
      fJSONValue := 'false';
      iTest := Copy( iValue, 1, 5 );
      if SameText( iTest, 'false' ) then
      begin
        iValue := Copy( iValue, 6 );
      end
      else
      begin
        iValue := Copy( iValue, 2 ); // single letter form, or syntax error which will be picked up later
      end;
    end;
  end;
end;

procedure TSigJSONObject.FromJSONNull(var iValue: string);
var
  iTest : string;
begin
  iTest := Copy( iValue, 1, 4 );
  if SameText( iTest, 'null' ) then
  begin
    fJSONValue := 'null';
    if not (self is TSigJSONCompoundObject)  then
    begin // not allowed to remove known structure!
      fChildren.Clear;
    end;
    iValue := Copy( iValue, 5 );
  end
  else
  begin
    raise ESigJSONException.Create('JSON Syntax error');
  end;
end;

procedure TSigJSONObject.FromJSONNumber(var iValue: string);
var
  iEndPos : integer;
begin
  iEndPos := 2;
  while iEndPos <= Length( iValue ) do
  begin
    case iValue[ iEndPos ] of
      '0'..'9','.': inc( iEndPos );
      else break;
    end;
  end;
  fJSONValue := Copy( iValue, 1, iEndPos - 1 );
  iValue := Copy( iValue, iEndPos ); // end pos is the first non-numeric value
end;

procedure TSigJSONObject.FromJSONObject(var iValue: string);
var
  iEndName : integer;
  iName : string;
  iChild : TSigJSONObject;
begin
  while True do
  begin
    iValue := Trim( Copy( iValue, 2 ));
    if iValue = '' then
    begin
      raise ESigJSONException.Create('JSON Syntax error');
    end;
    // the next char should be '"'
    if iValue[ 1 ] = '"' then
    begin
      iEndName := PosEx( '"', iValue, 2 );
      if iEndName < 2 then
      begin
        raise ESigJSONException.Create('JSON Syntax error');
      end;
      iName := Copy( iValue, 2, iEndName - 2 );
      iValue := Trim(Copy( iValue, iEndName + 1 ));
      // next value should be ':'
      if iValue = '' then
      begin
        raise ESigJSONException.Create('JSON Syntax error');
      end;
      if iValue[ 1 ] <> ':' then
      begin
        raise ESigJSONException.Create('JSON Syntax error');
      end;
      iValue := Copy( iValue, 2 );
      // see if it one of our known properties
      iChild := ChildWithName[ iName ];
      if not assigned( iChild ) then
      begin
        iChild := TSigJSONObject.Create( iName );
        fUnsupportedChildren.Add( iChild );
      end;
    end
    else if iValue[1] = '}' then
    begin
      // empty object
      break;
    end
    else
    begin
      iChild := AddItemIntrinsic;
    end;
    iChild.FromJSON( iValue );
    iValue := Trim( iValue );
    // now we should have either a ',' or a '}'
    if iValue = '' then
    begin
      raise ESigJSONException.Create('JSON Syntax error');
    end;
    case iValue[ 1 ]  of
      '}' : break; // done
      ',': ;
      else
      begin
        raise ESigJSONException.Create('JSON Syntax error');
      end;
    end;
  end;
  // remove terminating char
  iValue := Trim(Copy( iValue, 2 ));
end;

procedure TSigJSONObject.FromJSONString(var iValue: string);
var
  iEndPos : integer;
begin
  iEndPos := PosEx( '"', iValue, 2 );
  if iEndPos < 2 then
  begin
    raise ESigJSONException.Create('JSON Syntax error - unterminated string');
  end;
  fJSONValue := Copy( iValue, 2, iEndPos - 2 );
  iValue := Copy( iValue, iEndPos + 1 );
end;

procedure TSigJSONObject.SetJSON(const Value: string);
var
  iValue : string;
begin
  iValue := Value;
  FromJSON( iValue );
end;

procedure TSigJSONObject.SetJSONType(const Value: TSigJSONObjectType);
begin
  if fJSONType <> Value then
  begin
    if fJSONType = jotUnknown then
    begin
      fJSONType := Value;
      case Value of
        jotUnknown: ;
        jotString: ;
        jotNumber: fJSONValue := '0';
        jotBoolean: fJSONValue := 'FALSE';
        jotNull: ;
        jotObject: ;
        jotArray: ;
      end;
    end
    else if ( fJSONType = jotArray) and (Value = jotNULL) then
    begin
      // this is permitted for validation purposes, but does not change the actual value
    end
    else if ( fJSONType = jotNumber) and (Value = jotString) then
    begin
      // this is permitted for, for example, enums with a text property.
      // We don't change the type, but the calling routine will use string value
      // to try an decode
    end
    else
    begin
      raise ESigJSONException.Create('Unable to change type');
    end;
  end;
end;

procedure TSigJSONObject.SetJSONValue(const Value: string);
var
  i: Integer;
  iEscaped : boolean;
begin
  fJSONValue := '';
  iEscaped := FALSE;
  for i := 1 to Length( Value ) do
  begin
    case Value[ i ] of
      '\':
      begin
        if iEscaped then
        begin
          fJSONValue := fJSONValue + Value[ i ];
          iEscaped := FALSE;
        end
        else
        begin
          iEscaped := TRUE;
        end;
      end
      else
      begin
        fJSONValue := fJSONValue + Value[ i ];
        iEscaped := FALSE;
      end;
    end;
  end;
end;

procedure TSigJSONObject.SetValueAsBool(const Value: boolean);
begin
  if fJSONType = jotBoolean then
  begin
    if Value then
    begin
      fJSONValue := 'true'
    end
    else
    begin
      fJSONValue := 'false';
    end;
  end
  else
  begin
    raise ESigJSONException.Create('Unable to change type');
  end;
end;

procedure TSigJSONObject.SetValueAsInt(const Value: integer);
begin
  fJSONValue := IntToStr( Value );
end;

{ TSigJSONCompoundObject }


constructor TSigJSONCompoundObject.Create(const pJSONName: string);
begin
  inherited;
  fJSONType := jotObject;
end;


{ TSigTextObject }

constructor TSigJSONTextObject.Create(const pJSONName: string);
begin
  inherited;
  fJSONType := jotString;
end;

{ TSigJSONIntegerObject }

constructor TSigJSONIntegerObject.Create(const pJSONName: string);
begin
  inherited;
  fJSONType := jotNumber;
end;

{ TSigJSONArray<T> }

function TSigJSONArray<T>.Add(pValue: T): integer;
begin
  Result := fChildren.Add( pValue );
end;

function TSigJSONArray<T>.AddItem: T;
begin
  Result := AddChild< T >( '' );  // in this case name is redundant
end;

function TSigJSONArray<T>.AddItemIntrinsic: TSigJSONObject;
begin
  Result := AddItem;
end;

procedure TSigJSONArray<T>.Clear;
begin
  fChildren.Clear;
end;

constructor TSigJSONArray<T>.Create(const pJSONName: string);
begin
  inherited;
  fJSONType := jotArray;
  fChildClass := T;
end;

procedure TSigJSONArray<T>.Delete(const i: integer);
begin
  fChildren.Delete( i );
end;

function TSigJSONArray<T>.GetEnumerator: TSigJSONArrayEnnumerator<T>;
begin
  Result := TSigJSONArrayEnnumerator< T >.Create( self );
end;

function TSigJSONArray<T>.GetItemCount: integer;
begin
  Result := fChildren.Count;
end;

function TSigJSONArray<T>.GetItems(const i: integer): T;
begin
  Result := fChildren.Items[ i ] as T;
end;

function TSigJSONArray<T>.InsertItem(const pAtPoint: integer): T;
begin
  Result := T.Create( '' );
  fChildren.Insert( pAtPoint, Result );
end;

procedure TSigJSONArray<T>.Remove(const pValue: T);
begin
  fChildren.Remove( pValue );
end;

procedure TSigJSONArray<T>.SetItems(const i: integer; const Value: T);
begin
  fChildren.Items[ i ] := Value;
end;

{ TSigJSONBooleanObject }

constructor TSigJSONBooleanObject.Create(const pJSONName: string);
begin
  inherited;
  fJSONType := jotBoolean;
end;

{ TSigJSONObjectList<T> }

function TSigJSONObjectList<T>.Add(pValue: T): integer;
begin
  Result := fItems.Add( pValue );
end;

function TSigJSONObjectList<T>.AddItem: T;
begin
  Result := fItems.AddItem;
end;

function TSigJSONObjectList<T>.AddItemIntrinsic: TSigJSONObject;
begin
  Result := fItems.AddItemIntrinsic;
end;

procedure TSigJSONObjectList<T>.Clear;
begin
  fItems.Clear;
end;

constructor TSigJSONObjectList<T>.Create(const pJSONName: string);
begin
  inherited;
  fItems := TSigJSONArray< T >.Create( 'Items' );
  fChildren.Add( fItems ); ;
end;

function TSigJSONObjectList<T>.GetItemCount: integer;
begin
  Result := fItems.ItemCount;
end;

function TSigJSONObjectList<T>.GetItems(const i: integer): T;
begin
  Result := fItems.Items[ i ];
end;

procedure TSigJSONObjectList<T>.Remove(const pValue: T);
begin
  fItems.Remove( pValue );
end;

procedure TSigJSONObjectList<T>.SetItems(const i: integer; const Value: T);
begin
  fItems.Items[ i ] := Value;
end;

{ TSigJSONArrayEnnumerator<T> }

constructor TSigJSONArrayEnnumerator<T>.Create(AList: TSigJSONArray<T>);
begin
  inherited Create;
  fIndex := -1;
  fList := AList;
end;

function TSigJSONArrayEnnumerator<T>.GetCurrent: T;
begin
  Result := fList[ fIndex ];
end;

function TSigJSONArrayEnnumerator<T>.MoveNext: boolean;
begin
  inc( fIndex );
  Result := fIndex < fList.ItemCount;
end;

{ TSigJSONBooleanTRUEObject }

function TSigJSONBooleanTRUEObject.IsDefault: boolean;
begin
  Result := not ValueAsBool;
end;

{ TSigJSONBooleanFALSEObject }

function TSigJSONBooleanFALSEObject.IsDefault: boolean;
begin
  Result := ValueAsBool;
end;

end.
