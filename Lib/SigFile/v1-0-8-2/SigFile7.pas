unit SigFile7;

{*******************************************************************************
 *                                                                             *
 * Based on the SigFile unit but based as components, since the structure in   *
 * Firemonkey lends itself to this.                                            *
 *                                                                             *
 * Also make full use of generics.                                             *
 *                                                                             *
 * The visual structure does exactly match physical structure because of array *
 * type elements, so the components act like intermediaries between physical   *
 * data and visual components interpreting the text property, usually          *
 *                                                                             *
 * There is only one data element type that encapsulates all variants of       *
 * of the FMX components, which simplifes loading and saving. The FMX elements *
 * expose different ways of intereting the data, exposing appropriate          *
 * properties and creating appropriate setters and getters.                    *
 *                                                                             *
 *******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Types,
  FMX.Controls,
  FMX.Edit;

type
  tSigLoadAction = (laNone, laLoadingFromDevice, laComparingFromDevice );
  tSigFileUndoAction = ( undoClear, undoUnClear, undoClearUndoList, undoValue, undoChangeMax, undoAdd,
                         undoInsert2, undoDelete2, undoUndelete2, undoSelPos, undoSelLen,
                         undoChangeActiveChild, undoMove, undoSwap2, undoPointer,
                         undoSort, undoUnSort );

  TSigFile7ParseResult = ( prSyntaxError, prBegin, prEnd, prEmptyString, prComment );

  TSigFile7ErrorLevel = (elOK, elWarning, elError, elFatalError );

  TSigFile7BaseProperty = class;
  TSigFile7BaseDataList = class;

  TSigFile7BaseData = class
  private
    fText: string;
    fOwner: TSigFile7BaseData;
    fStructureOwner: TSigFile7BaseProperty;
    fChildren: TSigFile7BaseDataList;
    fItems: TSigFile7BaseDataList;
    fActiveItem: integer;
    fIsDirty: boolean;
    function GetName: string;
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);
    procedure SetActiveItem(const Value: integer);
    procedure SetText(const Value: string);
  protected
  public
    constructor Create( pOwner : TSigFile7BaseData; const pStructureOwner : TSigFile7BaseProperty;
                        pIsItem : boolean );
    destructor Destroy; override;

    procedure Clear;

    procedure Save( const pStrings : TStrings; const Indent : string ); overload; virtual;
    procedure Save( const pStrings : TStrings; const pIndex : integer; const Indent : string ); overload; virtual;
    procedure Save( const pStrings : TStrings; const pName : string; const Indent : string ); overload; virtual;
    function Load( const pStrings : TStrings; var pFromLine : integer;
             const pErrors : TStrings; const pValue : string ) : TSigFile7ErrorLevel; virtual;

    function SeekEnd( const pStrings : TStrings; var pFromLine : integer; const pErrors : TStrings; pName : string ) : TSigFile7ErrorLevel; virtual;

    property Text : string
             read fText
             write SetText;
    property Owner : TSigFile7BaseData
             read fOwner;
    property StructureOwner : TSigFile7BaseProperty
             read fStructureOwner;
    property Children : TSigFile7BaseDataList
             read fChildren;
    property Items : TSigFile7BaseDataList
             read fItems;

    property Name : string
             read GetName;

    property Active : boolean
             read GetActive
             write SetActive;

    property ActiveItem : integer
             read fActiveItem
             write SetActiveItem;

    class function Parse( const pStr : string; var pName : string; var pValue : string ) : TSigFile7ParseResult;
    class function IsIndexed( const pName : string; var pRootName : string; var pIndex : integer ) : boolean;
  end;

  TSigFile7BaseDataList = class( TObjectList< TSigFile7BaseData > )
  private
  protected
  public
  end;

  TSigFile7BaseProperty = class(TControl)
  private
    fText: string;
    fSigFileParent: TSigFile7BaseProperty;
    fItemIndex: integer;
    fCurrentData: TSigFile7BaseData;
    //fControl : TTextControl;
    fEditorList : TObjectList< TCustomEdit >;
    fItem: TSigFile7BaseProperty;
    function GetSigParent: TSigFile7BaseProperty;
    procedure SetCurrentData(const Value: TSigFile7BaseData);
    function GetCurrentData: TSigFile7BaseData;
    function CanCreateCurrentData : boolean;
    function ChildCurrentDataParent( const pChild : TSigFile7BaseProperty ) : TSigFile7BaseData;
    function CreateCurrentData : TSigFile7BaseData;
    { Private declarations }
  protected
    function GetIsDirty: boolean; virtual;
    procedure SetIsDirty(const Value: boolean); virtual;
    procedure SetText(const Value: string); overload; virtual;
    function SetText( const pEditor : TCustomEdit; const PValue : string ) : boolean; overload; virtual;
    procedure SetItemIndex(const Value: integer); overload; virtual;
    function SetItemIndex( const pEditor : TCustomEdit; const PValue : integer ) : boolean; overload; virtual;
    function IsOurControl( const pEditor : TCustomEdit ) : boolean;
    property Item : TSigFile7BaseProperty
             read fItem
             write fItem;
    procedure SetParent(const Value: TFmxObject); override;
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;

    property SigParent : TSigFile7BaseProperty
             read GetSigParent
             write fSigFileParent;
    property Text : string
             read fText
             write SetText;

    property ItemIndex : integer
             read fItemIndex
             write SetItemIndex;
    property CurrentData : TSigFile7BaseData
             read GetCurrentData
             write SetCurrentData;

    procedure RegisterEditor( const pEditor : TCustomEdit );
    procedure UnRegisterEditor( const pEditor : TCustomEdit );

    procedure ChangeText( const pSender : TObject; const pValue : string ); // slow way!

    property IsDirty : boolean
             read GetIsDirty
             write SetIsDirty;
  published
    { Published declarations }
  end;

  TSigFile7ErrorObject = class
  private
    fErrorLevel: TSigFile7ErrorLevel;
    fErrorLine: integer;
    fErrorObject: TSigFile7BaseData;
    fErrorPos: integer;
  protected
  public
    constructor Create( const pErrorLevel : TSigFile7ErrorLevel;
                        const pErrorLine, pErrorPos : integer;
                        const pErrorObject : TSigFile7BaseData ); overload;
    constructor Create( const pErrorLevel : TSigFile7ErrorLevel;
                        const pErrorLine : integer;
                        const pErrorObject : TSigFile7BaseData ); overload;

    property ErrorLevel : TSigFile7ErrorLevel
             read fErrorLevel;
    property ErrorLine : integer
             read fErrorLine;
    property ErrorPos : integer
             read fErrorPos;
    property ErrorObject : TSigFile7BaseData
             read fErrorObject;
  end;

  TSigFile7TextProperty = class( TSigFile7BaseProperty )
  private
  protected
  public
  published
    property Text;
  end;

  TSigFile7IntegerProperty = class( TSigFile7BaseProperty )
  private
    function GetValue: integer;
    procedure SetValue(const Value: integer);
  protected
  public
  published
    property Value : integer
             read GetValue
             write SetValue;
  end;

  TSigFile7SingleProperty = class( TSigFile7BaseProperty )
  private
    function GetValue: single;
    procedure SetValue(const Value: single);
  protected
  public
  published
    property Value : single
             read GetValue
             write SetValue;
  end;

  TOnGetNilItem< T : class > = function( const pIndex : integer ) : T;

  TSigFile7List = class(  TSigFile7BaseProperty )
  private
  published
    property Item;       // class corresponding to Item[ i ]
  end;

  TSigFile7File = class( TSigFile7BaseProperty )
  private
    fFileName: string;
    fIsDirty: boolean;
  protected
    function GetIsDirty: boolean; override;
    procedure SetIsDirty(const Value: boolean); override;
  public
    function Load( const pStrings : TStrings;
             const pErrors : TStrings ) : TSigFile7ErrorLevel; virtual;
    procedure Save( const pStrings : TStrings ); virtual;

    (*
    property IsDirty : boolean
             read fIsDirty
             write SetIsDirty;
    *)

  published
    property FileName : string
             read fFileName
             write fFileName;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigFile7', [ TSigFile7TextProperty,
                                   TSigFile7IntegerProperty,
                                   TSigFile7SingleProperty,
                                   TSigFile7List,
                                   TSigFile7File ]);
end;

{ TSigFile7BaseProperty }

function TSigFile7BaseProperty.ChildCurrentDataParent(
  const pChild: TSigFile7BaseProperty): TSigFile7BaseData;
begin
  Result := nil; // assume failure
  if assigned( CurrentData ) then
  begin
    // we don't exist data wise, so neither do our children
    if pChild = Item then
    begin
      if ItemIndex >= 0 then
      begin
        Result := CurrentData.Items[ ItemIndex ];
      end;
    end
    else
    begin
      Result := CurrentData;
    end;
  end;

end;

function TSigFile7BaseProperty.CanCreateCurrentData: boolean;
begin
  if Self is TSigFile7File then
  begin
    Result := TRUE;
  end
  else if assigned( SigParent ) then
  begin
    Result := assigned( SigParent.ChildCurrentDataParent( self ) );
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TSigFile7BaseProperty.ChangeText(const pSender: TObject;
  const pValue: string);
var
  i : integer;
begin
  if pSender is TCustomEdit then
  begin
    if IsOurControl( pSender as TCustomEdit ) then
    begin
      if assigned( CurrentData ) then
      begin
        CurrentData.Text := pValue;
      end;
      for i := 0 to fEditorList.Count - 1 do
      begin
        if fEditorList[ i ] <> pSender then
        begin
          fEditorList[ i ].Text := pValue;
        end;
      end;
    end;
  end
  else if pSender = CurrentData then
  begin
    for i := 0 to fEditorList.Count - 1 do
    begin
      if fEditorList[ i ].Text <> pValue then
      begin
        fEditorList[ i ].Text := pValue;
      end;
    end;
  end
  else
  begin
    if assigned( Item ) then
    begin
      Item.ChangeText( pSender, pValue );
    end;
    for i := 0 to Children.Count - 1 do
    begin
      if Children[ i ] is TSigFile7BaseProperty then
      begin
        (Children[ i ] as TSigFile7BaseProperty).ChangeText( pSender, pValue );
      end;
    end;
  end;
end;

constructor TSigFile7BaseProperty.Create(AOwner: TComponent);
begin
  inherited;
  fEditorList := TObjectList< TCustomEdit >.Create( FALSE );
  // see if we can create our data
  GetCurrentData;
end;

function TSigFile7BaseProperty.CreateCurrentData: TSigFile7BaseData;
begin
  if assigned( SigParent ) then
  begin
    fCurrentData := TSigFile7BaseData.Create( SigParent.ChildCurrentDataParent( self ), self, self = SigParent.Item );
  end
  else
  begin
    fCurrentData := TSigFile7BaseData.Create( nil, self, FALSE);
  end;
end;

destructor TSigFile7BaseProperty.Destroy;
begin
  fEditorList.Free;
  inherited;
end;

function TSigFile7BaseProperty.GetCurrentData: TSigFile7BaseData;
begin
  Result := fCurrentData;
  if not assigned( fCurrentData ) then
  begin
    if CanCreateCurrentData then
    begin
      Result := CreateCurrentData;
    end;
  end;
end;

function TSigFile7BaseProperty.GetIsDirty: boolean;
begin
  if assigned( fSigFileParent ) then
  begin
    Result := fSigFileParent.IsDirty;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TSigFile7BaseProperty.GetSigParent: TSigFile7BaseProperty;
begin
  {
    This needs some explanation.
    If we are contructimg the file visually we will put the elements in the classes
    tree in the editor and the way it works the Parent and SigParent will be the
    same. This structure can be overridden programatically, however to allow
    the physical structure to be different to the visual one. This is particularly
    important with arrays, which are programatically different to the visual structure
    almost by definition.
  }
  if assigned( fParent ) then
  begin
    if assigned( fSigFileParent ) then
    begin
      Result := fSigFileParent;
    end
    else if FParent is TSigFile7BaseProperty then
    begin
      Result := FParent as TSigFile7BaseProperty;
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigFile7BaseProperty.IsOurControl(
  const pEditor: TCustomEdit): boolean;
var
  i: Integer;
begin
  for i := 0 to fEditorList.Count - 1 do
  begin
    if fEditorList[ i ] = pEditor then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

procedure TSigFile7BaseProperty.Paint;
var
  ResStream : TResourceStream;
begin
  inherited;
  (*
  if csDesigning in ComponentState then
  begin
    ResStream := TResourceStream.Create( HInstance, self.ClassName, RT_RCDATA);
  end;
  *)
end;

procedure TSigFile7BaseProperty.RegisterEditor(const pEditor: TCustomEdit);
begin
  fEditorList.Add( pEditor );
  pEditor.TagObject := self;
  GetCurrentData;
  pEditor.Text := Text;
end;

procedure TSigFile7BaseData.Clear;
var
  i: Integer;
begin
  fText := fStructureOwner.Text; // use owner text as a default!
  Items.Clear;
  for i := 0 to Children.Count - 1 do
  begin
    Children.Clear;
  end;
end;

constructor TSigFile7BaseData.Create(pOwner: TSigFile7BaseData;
  const pStructureOwner: TSigFile7BaseProperty; pIsItem : boolean);
begin
  inherited Create;
  fOwner := pOwner;
  fStructureOwner := pStructureOwner;
  fText := fStructureOwner.Text; // use owner text as a default!
  fItems := TSigFile7BaseDataList.Create( TRUE );
  fChildren := TSigFile7BaseDataList.Create( TRUE );
  fActiveItem := -1;
  if assigned( pOwner ) then
  begin
    if pIsItem then
    begin
      pOwner.Items.Add( self );
    end
    else
    begin
      pOwner.Children.Add( self );
    end;
  end;
end;

destructor TSigFile7BaseData.Destroy;
begin
  if fStructureOwner.fCurrentData = self then
  begin
    fStructureOwner.fCurrentData := nil;
  end;
  inherited;
end;

function TSigFile7BaseData.GetActive: boolean;
begin
  Result := fStructureOwner.CurrentData = self;
end;

function TSigFile7BaseData.GetName: string;
begin
  Result := StructureOwner.Name;
end;

class function TSigFile7BaseData.IsIndexed(const pName: string;
  var pRootName: string; var pIndex: integer): boolean;
var
  iPos1, iPos2 : integer;
begin
  iPos1 := Pos( '(', pName );
  if iPos1 > 0 then
  begin
    iPos2 := Pos( ')', pName );
    if iPos2 > iPos1 then
    begin
      Result := TRUE;
      pRootName := Copy( pName, 1, iPos1 - 1 );
      pIndex := StrToInt( Copy( pName, iPos1 + 1, iPos2 - iPos1 - 1 ) );
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := FALSE;
  end;

end;

function TSigFile7BaseData.Load(const pStrings: TStrings;
  var pFromLine: integer; const pErrors: TStrings; const pValue : string) : TSigFile7ErrorLevel;
var
  iParseResult : TSigFile7ParseResult;
  iName, iValue, iNameRoot : string;
  i, iIndex : integer;
  iResult : TSigFile7ErrorLevel;
label
  Retry;
begin
  Result := elOK;
  Text := pValue;
  // first we need to analyse the line. The first line (BEGIN...) has already been read.
Retry:
  if pFromLine >= pStrings.Count then
  begin
    // missing END.
    Result := elError;
    pErrors.AddObject( 'Missing "END "' + Name, TSigFile7ErrorObject.Create( Result, pFromLine, self ));
    exit;
  end;
  iParseResult := Parse( pStrings[ pFromLine ], iName, iValue );
  case iParseResult of
    prSyntaxError:
    begin
        Result := elFatalError;
        pErrors.AddObject( 'Syntax Error', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
    end;
    prBegin:
    begin
      if iName = '' then
      begin
        // we can only have nameless children in arrays
        Result := elError;
        pErrors.AddObject( 'BEGIN without name - object ignored', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
        inc( pFromLine );
        if SeekEnd( pStrings, pFromLine, pErrors, '' ) = elFatalError then
        begin
          exit;
        end
        else
        begin
          goto Retry;
        end;
      end
      else
      begin
        if IsIndexed( iName, iNameRoot, iIndex ) then
        begin
          if (iNameRoot = '') or SameText( iNameRoot, fStructureOwner.Item.Name )  then
          begin
            while iIndex >= Items.Count do
            begin
              TSigFile7BaseData.Create( self, fStructureOwner.Item, TRUE);
            end;
            inc( pFromLine );
            Items[ iIndex ].Load( pStrings, pFromLine, pErrors, iValue );
          end
          else
          begin
            Result := elError;
            pErrors.AddObject( 'Indexed item does not match list object', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
            inc( pFromLine );
            if SeekEnd( pStrings, pFromLine, pErrors, '' ) = elFatalError then
            begin
              Result := elFatalError;
              exit;
            end
            else
            begin
              goto Retry;
            end;
          end;
        end
        else
        begin
          // not indexed, so there should be a one to one relationship
          // with fStructureOwner children
          with fStructureOwner do
          begin
            for i := 0 to Children.Count - 1 do
            begin
              if Children.Items[ i ].Name = iName then
              begin
                inc( pFromLine );
                with Children.Items[ i ] as TSigFile7BaseProperty do
                begin
                  if assigned( CurrentData ) then
                  begin
                    iResult := CurrentData.Load( pStrings, pFromLine, pErrors, iValue );
                    case iResult of
                      elOK,
                      elWarning:
                      begin
                        if Result <> elError then
                        begin
                          Result := iResult;
                        end;
                        goto Retry;
                      end;
                      elError:
                      begin
                        Result := iResult;
                        goto Retry;
                      end;
                      elFatalError:
                      begin
                        Result := iResult;
                        exit;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          // if we get here child was not found - see if it should be
          Result := elError;
          pErrors.AddObject( 'Property ' + iName + ' not found and ignored', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
          inc( pFromLine );
          if SeekEnd( pStrings, pFromLine, pErrors, '' ) = elFatalError then
          begin
            Result := elFatalError;
            exit;
          end
          else
          begin
            goto Retry;
          end;
        end;
      end;
    end;
    prEnd:
    begin
      // check correct end!
      if iName = fStructureOwner.Name then
      begin
        // OK;
        inc( pFromLine );
        exit;
      end
      else
      begin
        Result := elError;
        pErrors.AddObject( 'Missing "END "' + Name, TSigFile7ErrorObject.Create( Result, pFromLine, self ));
        // exit to parent without incrementing Line!
        exit;
      end;
    end;
    prEmptyString:
    begin
      inc( pFromLine );
      goto Retry;
    end;
    prComment:
    begin
    end;
  end;
end;

function TSigFile7BaseData.SeekEnd(const pStrings: TStrings;
  var pFromLine: integer; const pErrors: TStrings;
  pName: string): TSigFile7ErrorLevel;
var
  iParseResult : TSigFile7ParseResult;
  iName, iValue : string;
label
  Retry;
begin
  { This is pretty much a load without an object. }
  Result := elOK;
  // first we need to analyse the line. The first line (BEGIN...) has already been read.
Retry:
  if pFromLine >= pStrings.Count then
  begin
    // missing END.
    Result := elError;
    pErrors.AddObject( 'Missing "END "' + pName, TSigFile7ErrorObject.Create( Result, pFromLine, nil ));
    exit;
  end;
  iParseResult := Parse( pStrings[ pFromLine ], iName, iValue );
  case iParseResult of
    prSyntaxError:
    begin
        Result := elFatalError;
        pErrors.AddObject( 'Syntax Error', TSigFile7ErrorObject.Create( Result, pFromLine, nil ));
    end;
    prBegin:
    begin
      Result := elError;
      inc( pFromLine );
      if SeekEnd( pStrings, pFromLine, pErrors, '' ) = elFatalError then
      begin
        exit;
      end
      else
      begin
        goto Retry;
      end;
    end;
    prEnd:
    begin
      // check correct end!
      if iName = pName then
      begin
        // OK;
        inc( pFromLine );
        exit;
      end
      else
      begin
        Result := elError;
        pErrors.AddObject( 'Missing "END "' + Name, TSigFile7ErrorObject.Create( Result, pFromLine, self ));
        // exit to parent without incrementing Line!
        exit;
      end;
    end;
    prEmptyString:
    begin
      inc( pFromLine );
      goto Retry;
    end;
    prComment:
    begin
      // silently ignore comments
      inc( pFromLine );
      goto Retry;
    end;
  end;
end;

procedure TSigFile7BaseData.SetActive(const Value: boolean);
var
  i: Integer;
begin
  if Active <> Value then
  begin
    if Value then
    begin
      fStructureOwner.CurrentData := self;
    end
    else
    begin
      fStructureOwner.CurrentData := nil;
    end;
    for i := 0 to Children.Count - 1 do
    begin
      Children[ i ].Active := Value;
    end;
    if ActiveItem >= 0 then
    begin
      fItems[ ActiveItem ].Active := Value;
    end;

  end;
end;

procedure TSigFile7BaseData.SetActiveItem(const Value: integer);
begin
  if fActiveItem <> Value then
  begin
    if (fActiveItem >= 0) and (Value < 0) then
    begin
      fItems[ fActiveItem ].Active := FALSE;
    end;
    fActiveItem := Value;
    if fActiveItem >= 0 then
    begin
      fItems[ fActiveItem ].Active := TRUE;
    end;
  end;
end;

procedure TSigFile7BaseData.SetText(const Value: string);
begin
  if fText <> Value then
  begin
    fStructureOwner.IsDirty := TRUE;
  end;
  fText := Value;
  if fStructureOwner.CurrentData = self then
  begin
    fStructureOwner.ChangeText( self, Value );
  end;
end;

procedure TSigFile7BaseProperty.SetCurrentData(const Value: TSigFile7BaseData);
begin
  fCurrentData := Value;
end;

procedure TSigFile7BaseProperty.SetIsDirty(const Value: boolean);
begin
  if assigned( SigParent ) then
  begin
    SigParent.IsDirty := Value;
  end;
end;

function TSigFile7BaseProperty.SetItemIndex(const pEditor: TCustomEdit;
  const PValue: integer): boolean;
var
  i : integer;
begin
  if IsOurControl( pEditor ) then
  begin
    ItemIndex := pValue;
    Result := TRUE;
  end
  else
  begin
    for i := 0 to Children.Count - 1 do
    begin
      if Children[ i ] is TSigFile7BaseProperty then
      begin
        with Children[ i ] as TSigFile7BaseProperty do
        begin
          if SetItemIndex( pEditor, pValue ) then
          begin
            Result := TRUE;
            exit;
          end;
        end;
      end;
    end;
    // else
    Result := FALSE;
  end;
end;

procedure TSigFile7BaseProperty.SetParent(const Value: TFmxObject);
begin
  inherited;
  if not assigned( CurrentData ) then
  begin
    GetCurrentData;
  end;
end;

procedure TSigFile7BaseProperty.SetItemIndex(const Value: integer);
begin
  fItemIndex := Value;
end;

function TSigFile7BaseProperty.SetText(const pEditor: TCustomEdit;
  const PValue: string): boolean;
var
  i: Integer;
begin
  if IsOurControl( pEditor ) then
  begin
    if assigned( fCurrentData ) then
    begin
      fCurrentData.Text := pValue;
      Result := TRUE;
    end;
  end
  else
  begin
    for i := 0 to Children.Count - 1 do
    begin
      if Children[ i ] is TSigFile7BaseProperty then
      begin
        with Children[ i ] as TSigFile7BaseProperty do
        begin
          if SetText( pEditor, pValue ) then
          begin
            Result := TRUE;
            exit;
          end;
        end;
      end;
    end;
    // else
    Result := FALSE;
  end;
end;

procedure TSigFile7BaseProperty.SetText(const Value: string);
//var
//  i: Integer;
begin
  if fText <> Value then
  begin
    fText := Value;
    if assigned( CurrentData ) then
    begin
      CurrentData.Text := Value;
    end;
    {
    for i := 0 to fControlList.Count - 1 do
    begin
      if fControlList[ i ].Text <> Value then
      begin
        fControlList[ i ].Text := Value;
      end;
    end;
    }
  end;
end;

procedure TSigFile7BaseProperty.UnRegisterEditor(const pEditor: TCustomEdit);
begin
  fEditorList.Remove( pEditor );
end;

{ TSigFile7IntegerProperty }


function TSigFile7IntegerProperty.GetValue: integer;
begin
  if Text = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( Text ); // allow exception to raise if error!
  end;
end;

procedure TSigFile7IntegerProperty.SetValue(const Value: integer);
begin
  Text := IntToStr( Value );
end;

{ TSigFile7List }

{ TSigFile7ErrorObject }

constructor TSigFile7ErrorObject.Create(const pErrorLevel: TSigFile7ErrorLevel;
  const pErrorLine, pErrorPos: integer;
  const pErrorObject: TSigFile7BaseData);
begin
  inherited Create;
  fErrorLevel  := pErrorLevel;
  fErrorLine   := pErrorLine;
  fErrorPos    := pErrorPos;
  fErrorObject := pErrorObject;
end;

constructor TSigFile7ErrorObject.Create(const pErrorLevel: TSigFile7ErrorLevel;
  const pErrorLine: integer; const pErrorObject: TSigFile7BaseData);
begin
  Create( pErrorLevel, pErrorLine, 0, pErrorObject );
end;


{ TSigFile7File }

function TSigFile7File.GetIsDirty: boolean;
begin
  Result := fIsDirty;
end;

function TSigFile7File.Load(const pStrings: TStrings;
  const pErrors: TStrings): TSigFile7ErrorLevel;
var
  iParseResult : TSigFile7ParseResult;
  iName, iValue : string;
  iFromLine : integer;
label
  Retry;
begin
  // the main difference between this and others is that the initial line
  // is read and checked first if pFromLine = 0, i.e. the first line.
  iFromLine := 0;
Retry:
  if iFromLine >= pStrings.Count then
  begin
    // missing END.
    Result := elFatalError;
    pErrors.AddObject( 'Missing "BEGIN "' + Name, TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
    exit;
  end;
  iParseResult := TSigFile7BaseData.Parse( pStrings[ iFromLine ], iName, iValue );
  case iParseResult of
    prSyntaxError:
    begin
      Result := elFatalError;
      pErrors.AddObject( 'Syntax Error', TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
    end;
    prBegin:
    begin
      if iName = '' then
      begin
        // we can can not be nameless!
        Result := elFatalError;
        pErrors.AddObject( 'BEGIN without name - Aborted', TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
        exit;
      end
      else if Name <> iName then
      begin
        // Name does not match
        Result := elFatalError;
        pErrors.AddObject( 'BEGIN ' + iName + ' found instead of BEGIN ' + Name , TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
        exit;
      end;
    end;
    prEnd:
    begin
      Result := elFatalError;
      pErrors.AddObject( 'END before BEGIN', TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
      exit;
    end;
    prEmptyString:
    begin
      inc( iFromLine );
      goto Retry;
    end;
    prComment:
    begin
      // discard silently
      inc( iFromLine );
      goto Retry;
    end;
  end;
  fCurrentData.Clear;
  inc( iFromLine );
  //fCurrentData.Text := iValue;
  Result := fCurrentData.Load( pStrings, iFromLine, pErrors, iValue );
  IsDirty := FALSE;
end;

{ TSigFile7TextProperty }

procedure TSigFile7File.Save(const pStrings: TStrings);
begin
  fCurrentData.Save( pStrings, '' );
end;

procedure TSigFile7File.SetIsDirty(const Value: boolean);
begin
  fIsDirty := Value;
end;

{ TSigFile7SingleProperty }

function TSigFile7SingleProperty.GetValue: single;
begin
  if Text = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToFloat( Text );
  end;
end;

class function TSigFile7BaseData.Parse(const pStr: string; var pName,
  pValue: string): TSigFile7ParseResult;
var
  iStr : string;
  iPos : integer;
begin
  Result := prSyntaxError;
  iStr := Trim(pStr);
  if iStr = '' then
  begin
    Result := prEmptyString;
    pName := '';
    pValue := '';
    exit;
  end;
  if Length( iStr ) < 2 then
  begin
    exit; // really is a syntax error
  end;
  if Copy( iStr, 1, 2 ) = '//' then
  begin
    pName := '';
    pValue := Copy( iStr, 4 ); // no trimming here!
    Result := prComment;
    exit;
  end;
  if Length( iStr ) < 3 then
  begin
    exit; // really is a syntax error
  end;
  if SameText( Copy( iStr, 1, 3 ), 'END') then
  begin
    pName := Trim( Copy( iStr, 4 ));
    pValue := '';
    Result := prEnd;
    exit;
  end
  else if Length( iStr ) < 5 then
  begin
    exit; // really is a syntax error
  end
  else if SameText( Copy( iStr, 1, 5 ), 'BEGIN' ) then
  begin
    Result := prBegin;
    iStr := Copy( iStr, 6 );
    iPos := Pos( '=', iStr );
    if iPos = 0 then
    begin
      // optional = not present
      pName := Trim( iStr );
      pValue := '';
      exit;
    end
    else
    begin
      pName := Trim( Copy( iStr, 1, iPos - 1 ));
      pValue := Trim( Copy( iStr, iPos + 1 ));
      exit;
    end;
  end
  else
  begin
    exit; // syntax error
  end;
end;

procedure TSigFile7SingleProperty.SetValue(const Value: single);
begin
  Text := FloatToStr( Value );
end;

procedure TSigFile7BaseData.Save(const pStrings: TStrings; const pName,
  Indent: string);
var
  i : integer;
begin
  if Text = '' then
  begin
    pStrings.Add( Indent + 'BEGIN ' + pName );
  end
  else
  begin
    pStrings.Add( Indent + 'BEGIN ' + pName + ' = ' + Text);
  end;
  for i := 0 to Items.Count - 1 do
  begin
    Items[ i ].Save( pStrings, i, Indent + '  ');
  end;
  for i := 0 to Children.Count - 1 do
  begin
    Children[ i ].Save( pStrings, Indent + '  ');
  end;
  pStrings.Add( Indent + 'END ' + pName);
end;

procedure TSigFile7BaseData.Save(const pStrings: TStrings;
  const Indent: string);
begin
  Save( pStrings, Name, Indent );
end;

procedure TSigFile7BaseData.Save(const pStrings: TStrings; const pIndex: integer;
  const Indent: string);
begin
  Save( pStrings, Name + '(' + IntToStr( pIndex ) + ')', Indent );
  //Save( pStrings, 'Item(' + IntToStr( pIndex ) + ')', Indent ); // Alternate form
end;

initialization

finalization


end.

