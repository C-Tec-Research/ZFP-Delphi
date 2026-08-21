unit DynEditObject;

{
  Overview:
    This object is the parent of all Dynamic Editor
    Objects. These are not visible objects in the
    normal sense, although some can draw on a suitable
    canvas.
}
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  DynEditProperty,
  DynEditParse,
  DynEditConstructorButton;


type
  TDynEditObjectList = class;
  TDynEditDLL = class;
  TDynEditDLLList = class;
  TDynEditDLLObject = class;
  TDynEditObject = class;
{ the various DLL function prototypes }
  TPlaceableObjectCount = function : Integer; stdcall;
  TPlaceableObjectPage = procedure( Dest : PChar ); stdcall;
  TGetBitmapFileName = procedure( index : integer; BitmapFileName : PChar ); stdcall;
  TGetHintText = procedure( index : integer; HintText : PChar ); stdcall;
  TGetCursor = function ( index : integer ): HCURSOR; stdcall;
  TDrawObjectGhost = procedure ( const Canvas : TCanvas; index : integer;
            var Rect : TRect ); stdcall;
  TClearObjectGhost = procedure ( const Canvas : TCanvas; index : integer;
            var Rect : TRect ); stdcall;
  TCreateObjectByIndex = function ( index : integer;
           pParent : TDynEditObject ) : TDynEditObject; stdcall;
  TFreeObject = procedure ( pObject : TDynEditObject ); stdcall;

  TDynEditObject = class(TObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iIndent, iIndentUnit : integer;
    DynEditProperty : TDynEditPropertyList;
    iMyParent : TDynEditObject;
    iChildList : TDynEditObjectList;
    iDLLList : TDynEditDLLList;
    procedure fSetPropertyValue( index, Value : string );
    function fGetPropertyValue( index : string ) : string;
    function fGetPropertyItemValue( index : Integer ) : string;
    function fGetPropertyItemName( index : Integer ) : string;
    function fGetPropertyCount : integer;
    function fGetDLLList : TDynEditDLLList;
  public
    { Public declarations }
    constructor Create( pMyParent : TDynEditObject ); virtual;
    destructor Destroy; override;
    function Save( var F : TextFile; Indent, IndentUnit : integer ) : boolean;
    procedure WriteIndent( var F : TextFile );
    procedure WriteProperty( var F : TextFile ; PropertyName, PropertyValue : string );

    function LoadFromFile( var F : TextFile ) : boolean;
    function CreateChildFromFile( var F : TextFile;
             ChildsParent : TDynEditObject; ChildType : string ) : boolean;
    function AddDLL( DLLName : string ) : boolean;
    function DLLCount : integer;
    procedure AddConstructorPages( TabControlObjects : TTabControl );
    procedure SetConstructorButton( DynEditConstructorButton : TDynEditConstructorButton;
              Page, index : integer );
    function CreateDLLChild( DLL : TDynEditDLL; Index : integer ) : TDynEditObject;
{ the following functions should be redefined for every object }
    function MyName : string; virtual;

{ properties }
    property PropertyItem[ index : string ] : string
             read fGetPropertyValue
             write fSetPropertyValue;
    property PropertyValue[ index : integer ] : string
             read fGetPropertyItemValue;
    property PropertyName[ index : integer ] : string
             read fGetPropertyItemName;
    property PropertyCount : integer
             read fGetPropertyCount;
    property MyParent : TDynEditObject
             read iMyParent;
    property DLLList : TDynEditDLLList
             read fGetDLLList;
  published
    { Published declarations }
  end;

  TDynEditObjectList = class( TList )
    protected
      function fGetObjectItem( index : integer ) : TDynEditObject;
    public
      property DynEditObjectItem[ index : integer ] : TDynEditObject
             read fGetObjectItem;
      destructor Destroy; override;
  end;

  TDynEditDLL = class( TObject )
  private
    { Private declarations }
  protected
    { Protected declarations }
    iDLLFileName : string;
    iHandle : HINST;
    fPlaceableObjectCount : TPlaceableObjectCount;
    fPlaceableObjectPage : TPlaceableObjectPage;
    fGetBitmapFileName : TGetBitmapFileName;
    fGetHintText : TGetHintText;
    fGetCursor : TGetCursor;
    fDrawObjectGhost : TDrawObjectGhost;
    fClearObjectGhost : TClearObjectGhost;
    fCreateObjectByIndex : TCreateObjectByIndex;
    fFreeObject : TFreeObject;
    function fGetPlaceableObjectCount : integer;
  public
    constructor Create( pHandle : HINST; pDLLFileName : string );
    destructor Destroy; override;

    procedure AddConstructorPage( TabControlObjects : TTabControl );
    procedure SetObjectConstructorBitmap( DynEditConstructorButton : TDynEditConstructorButton );

    procedure DrawObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
    procedure ClearObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );

{
    function CreateObject( ObjectType : string ) : TDynEditObject;
}
    function CreateObjectByIndex( index : integer;
           pParent : TDynEditObject ) : TDynEditObject;
    procedure FreeObject( pObject : TDynEditObject );

    property PlaceableObjectCount : integer
             read fGetPlaceableObjectCount;
end;

  TDynEditDLLList = class(TList)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function fGetDLLItem( index : integer ) : TDynEditDLL;
  public
    { Public declarations }
    destructor Destroy; override;

    class function IsValidDLL( Handle : HINST ) : boolean;

    function AddDLL( DLLName : string ) : boolean;

    procedure AddConstructorPages( TabControlObjects : TTabControl );

    property DynEditDLLItem[ index : integer ] : TDynEditDLL
             read fGetDLLItem;
  published
    { Published declarations }
end;

  TDynEditDLLObject = class( TDynEditObject )
  private
    DynEditDLL : TDynEditDLL;
    ObjectTypeIndex : integer;
    DLLObject : TDynEditObject;
  public
    constructor Create( pMyParent : TDynEditObject;
                        pDynEditDLL : TDynEditDLL;
                        index : integer );
    destructor Destroy; override;
end;

implementation

constructor TDynEditObject.Create( pMyParent : TDynEditObject );
begin
  inherited Create;
  DynEditProperty := TDynEditPropertyList.Create;
  iMyParent := pMyParent;
  iChildList := TDynEditObjectList.Create;
  { if we are root we hold the DLL List }
  if iMyParent = nil then
  begin
    iDLLList := TDynEditDLLList.Create;
  end
  else
  begin
    iDLLList := nil;
  end;
end;

destructor TDynEditObject.Destroy;
begin
  DynEditProperty.Free;
  iDLLList.Free;
  iChildList.Free;
  inherited Destroy;
end;

function TDynEditObject.Save( var F : TextFile; Indent, IndentUnit : integer ) : boolean;
begin
  if MyName = '' then
  begin
    Application.MessageBox( 'Unnamed object cannot be saved', 'Save Error',
                            mb_OK or mb_ICONSTOP );

    Result := FALSE;
  end
  else
  begin
    iIndent := Indent;
    iIndentUnit := IndentUnit;
    Result := TRUE;
    WriteIndent( F );
    WriteLn( F, MyName );
    Inc( iIndent );
    DynEditProperty.Save( F, iIndent, iIndentUnit );
    Dec( iIndent );
    WriteIndent( F );
    WriteLn(F, 'End ' + MyName);
  end;
end;

function TDynEditObject.MyName : string;
begin
  result := '';
end;

procedure TDynEditObject.WriteProperty( var F : TextFile ; PropertyName, PropertyValue : string );
begin
  WriteIndent( F );
  WriteLn( F, PropertyName + ' = ' + PropertyValue );
end;

procedure TDynEditObject.WriteIndent( var F : TextFile  );
var
  i : integer;
begin
  for i := 1 to iIndent * iIndentUnit do
  begin
    Write( F, ' ');
  end;
end;

procedure TDynEditObject.fSetPropertyValue( index, Value : string );
begin
  DynEditProperty.DynEditProperty[ index ] := Value;
end;

function TDynEditObject.fGetPropertyValue( index : string ) : string;
begin
  Result := DynEditProperty.DynEditProperty[ index ];
end;

function TDynEditObject.fGetPropertyItemValue( index : Integer ) : string;
begin
  Result := DynEditProperty.DynEditPropertyItem[ index ].Value;
end;

function TDynEditObject.fGetPropertyItemName( index : Integer ) : string;
begin
  Result := DynEditProperty.DynEditPropertyItem[ index ].Name;
end;

function TDynEditObject.fGetPropertyCount : integer;
begin
  Result := DynEditProperty.Count;
end;

function TDynEditObject.LoadFromFile( var F : TextFile ) : boolean;
var
  Line, ObjectOrProperty, Value, Comment : string;
begin
  { the start line (MyName) has already been read in order
    to create me. Now we just need to read and create
    objects until (End Myname) is found. }
  while not EOF( F) do
  begin
    ReadLn( F, Line );
    case DEParse( Line, ObjectOrProperty, Value, Comment ) of
      deObject:
        begin
          if CompareText( ObjectOrProperty, 'End ' + MyName ) = 0 then
          begin
            Result := TRUE;
            Exit;
          end
          else
          begin
            if not CreateChildFromFile( F, self, ObjectOrProperty ) then
            begin
              Result := FALSE;
              Exit;
            end;
          end;
        end;
      deProperty:
        begin
          PropertyItem[ ObjectOrProperty ] := Value;
        end;
      deError:
        begin
          Result := FALSE;
          Exit;
        end;
    end;
  end;
  { if we get here we have an unexpected end of file }
  Result := FALSE;
end;

function TDynEditObject.CreateChildFromFile( var F : TextFile;
         ChildsParent : TDynEditObject; ChildType : string ) : boolean;
begin
  if MyParent = nil then { I am the root }
  begin
    Result := FALSE; { currently I can't create children }
  end
  else
  begin
    Result := MyParent.CreateChildFromFile( F, ChildsParent, ChildType );
  end
end;

function TDynEditObject.AddDLL( DLLName : string ) : boolean;
begin
  Result := DLLList.AddDLL( DLLName );
end;

function TDynEditObject.DLLCount : integer;
begin
  Result := DLLList.Count;
end;

procedure TDynEditObject.AddConstructorPages( TabControlObjects : TTabControl );
begin
  DLLList.AddConstructorPages( TabControlObjects );
end;

function TDynEditObject.fGetDLLList : TDynEditDLLList;
begin
  if MyParent = nil then { I am the root }
  begin
    Result := iDLLList; { I hold the DLL list }
  end
  else
  begin
    Result := MyParent.DLLList; { I don't have it - let my parent try }
  end
end;

procedure TDynEditObject.SetConstructorButton( DynEditConstructorButton : TDynEditConstructorButton;
              Page, index : integer );
begin
  { The page refers to the component page, and hence to that DLL.
    The index is the object within that DLL }
  if index > DLLList.DynEditDLLItem[ Page ].PlaceableObjectCount then
  begin
    DynEditConstructorButton.Visible := FALSE;
  end
  else
  begin
    DynEditConstructorButton.Visible := TRUE;
    DLLList.DynEditDLLItem[ Page ].SetObjectConstructorBitmap( DynEditConstructorButton );
  end;
end;

function TDynEditObject.CreateDLLChild( DLL : TDynEditDLL; Index : integer ) : TDynEditObject;
begin
  Result := TDynEditDLLObject.Create( self, DLL, Index );
  if Result <> nil then iChildList.Add( Result );
end;

{--------------------- TDynEditObjectList ------------------------}

function TDynEditObjectList.fGetObjectItem( index : integer ) : TDynEditObject;
begin
  result := Items[ index ];
end;

destructor TDynEditObjectList.Destroy;
var
  i : integer;
begin
  // destroy my members
  for i:=0 to Count-1 do
  begin
    DynEditObjectItem[ i ].Free;
  end;
  inherited Destroy;
end;

{----------------------- TDynEditDLL -------------------}

constructor TDynEditDLL.Create( pHandle : HINST; pDLLFileName : string );
begin
  inherited Create;
  iDLLFileName := pDLLFileName;
  iHandle := pHandle;
  fPlaceableObjectCount := GetProcAddress( iHandle, 'PlaceableObjectCount' );
  fPlaceableObjectPage := GetProcAddress( iHandle, 'PlaceableObjectPage' );
  fGetBitmapFileName := GetProcAddress( iHandle, 'GetBitmapFileName' );
  fGetHintText := GetProcAddress( iHandle, 'GetHintText' );
  fGetCursor := GetProcAddress( iHandle, 'GetCursor' );
  fDrawObjectGhost := GetProcAddress( iHandle, 'DrawObjectGhost' );
  fClearObjectGhost := GetProcAddress( iHandle, 'ClearObjectGhost' );
  fCreateObjectByIndex := GetProcAddress( iHandle, 'CreateObjectByIndex' );
  fFreeObject := GetProcAddress( iHandle, 'FreeObject' );
end;

destructor TDynEditDLL.Destroy;
begin
  FreeLibrary( iHandle );
  inherited Destroy;
end;

procedure TDynEditDLL.AddConstructorPage( TabControlObjects : TTabControl );
var
  PageName : PChar;
begin
  PageName := StrAlloc( 255 );
  StrCopy( PageName, 'Empty' );
  fPlaceableObjectPage( PageName );
  TabControlObjects.Tabs.Add( PageName );
  StrDispose( PageName );
end;

function TDynEditDLL.fGetPlaceableObjectCount : integer;
begin
  Result := fPlaceableObjectCount;
end;

procedure TDynEditDLL.SetObjectConstructorBitmap( DynEditConstructorButton : TDynEditConstructorButton );
var
  Temp : PChar;
begin
  Temp := StrAlloc( 255 );
  with DynEditConstructorButton do
  begin
    if Assigned( fGetBitmapFileName ) then
    begin
      fGetBitmapFileName( InternalIndex, Temp );
      Glyph.LoadFromFile( Temp );
      NumGlyphs := 4;
    end
    else
    begin

    end;

    if Assigned( fGetHintText ) then
    begin
      fGetHintText( InternalIndex, Temp );
      Hint := Temp;
    end
    else
    begin
      Hint := '';
    end;

    if Assigned( fGetCursor ) then
    begin
      Screen.Cursors[ InternalIndex ] := fGetCursor( InternalIndex );
    end
    else
    begin
      Screen.Cursors[ InternalIndex ] := LoadCursor(0, IDC_ARROW);
    end;
  end;
  StrDispose( Temp );
end;

procedure TDynEditDLL.DrawObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
begin
  if assigned( fDrawObjectGhost ) then
     fDrawObjectGhost( Canvas, index, Rect )
  else
    Canvas.DrawFocusRect( Rect );

end;

procedure TDynEditDLL.ClearObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
begin
  if assigned( fClearObjectGhost ) then
     fClearObjectGhost( Canvas, index, Rect )
  else
    Canvas.DrawFocusRect( Rect );

end;

function TDynEditDLL.CreateObjectByIndex( index : integer;
           pParent : TDynEditObject ) : TDynEditObject;
begin
  if assigned( fCreateObjectByIndex ) then
     Result := fCreateObjectByIndex( index, pParent )
  else
    Result := nil;

end;

procedure TDynEditDLL.FreeObject( pObject : TDynEditObject );
begin
  if assigned( fFreeObject ) then
     fFreeObject( pObject )
end;


{------------------------ TDynEditDLLList --------------}

destructor TDynEditDLLList.Destroy;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    DynEditDLLItem[ i ].Free;
  end;
  inherited Destroy;
end;

function TDynEditDLLList.fGetDLLItem( index : integer ) : TDynEditDLL;
begin
  result := Items[ index ];
end;

function TDynEditDLLList.AddDLL( DLLName : string ) : boolean;
var
  Handle : HINST;
begin
  { check that the DLL Exists }
  Handle := LoadLibrary( PChar(DLLName) );
  if Handle > 0 then
  begin
    Result := IsValidDLL( Handle );
    if Result then Add( TDynEditDLL.Create( Handle, DLLName ));
  end
  else
  begin
    Result := FALSE;
  end;
end;

class function TDynEditDLLList.IsValidDLL( Handle : HINST ) : boolean;
begin
  Result := TRUE;
  if GetProcAddress( Handle, 'PlaceableObjectCount' ) = nil
     then Result := FALSE;
  if GetProcAddress( Handle, 'PlaceableObjectPage' ) = nil
     then Result := FALSE;
  { GetBitmapFileName is an optional function - there may be
    no constructor buttons }
end;

procedure TDynEditDLLList.AddConstructorPages( TabControlObjects : TTabControl );
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    DynEditDLLItem[ i ].AddConstructorPage( TabControlObjects );
  end;
end;

constructor TDynEditDLLObject.Create( pMyParent : TDynEditObject;
                        pDynEditDLL : TDynEditDLL;
                        index : integer );
begin
  inherited Create( pMyParent );
  DynEditDLL := pDynEditDLL;
  ObjectTypeIndex := index;
  DLLObject := DynEditDLL.CreateObjectByIndex( index, Self );
end;

destructor TDynEditDLLObject.Destroy;
begin
  DLLObject.Free;
  inherited Destroy;
end;

end.


