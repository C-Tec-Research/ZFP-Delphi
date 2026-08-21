unit SigFile7;

{*******************************************************************************
 *                                                                             *
 * Based on the SigFile unit but based as components, since the structure in   *
 * Firemonkey lends itself to this.                                            *
 *                                                                             *
 * Also make full use of generics.                                             *
 *                                                                             *
 * The visual structure does not exactly match physical structure because of   *
 * array type elements, so the components act like intermediaries between      *
 * physical data and visual components interpreting the text property, usually *
 *                                                                             *
 * There is only one data element type that encapsulates all variants of       *
 * of the FMX components, which simplifes loading and saving. The FMX elements *
 * expose different ways of intereting the data, exposing appropriate          *
 * properties and creating appropriate setters and getters.                    *
 *                                                                             *
 *******************************************************************************
 *                                                                             *
 * Additional functionality.                                                   *
 *                                                                             *
 * To make things more visual, FMX control awareness has been built in to the  *
 * components.                                                                 *
 *                                                                             *
 * More than one FMX component can be linked to a single SigFile7 component    *
 * Until we build a property editor we will allow one main component to be     *
 * linked visually.                                                            *
 *                                                                             *
 * We allow a component to save its children dependant upon a value of text    *
 *                                                                             *
 *******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  UnitListComponents,
  FMX.Types,
  FMX.Controls;
  //FMX.Edit,
  //FMX.Listbox;

type
  tSigLoadAction = (laNone, laLoadingFromDevice, laComparingFromDevice );
  tSigFileUndoAction = ( undoClear, undoUnClear, undoClearUndoList, undoValue, undoChangeMax, undoAdd,
                         undoInsert2, undoDelete2, undoUndelete2, undoSelPos, undoSelLen,
                         undoChangeActiveChild, undoMove, undoSwap2, undoPointer,
                         undoSort, undoUnSort );

  TSigFile7ParseResult = ( prSyntaxError, prValue, prBegin, prEnd, prEmptyString, prComment );

  TSigFile7ErrorLevel = (elOK, elWarning, elError, elFatalError );

  TSigFile7BaseProperty = class;
  TSigFile7BaseDataList = class;

  TSigFile7TextComponentList = class( TObjectList< TSigFile7TextComponent > )
  private
    fUpdating : integer;
  public
    destructor Destroy; override;
    function AddControl( pControl : TControl; const pUseStandardIntercepts : boolean = TRUE ) : TSigFile7TextComponent;
    procedure Remove( const pControl : TControl ); overload;
    procedure BeginUpdate;
    procedure Endupdate;
  end;

  TSaveChildren = ( scAlways, scNever, scIfEQ, scIfNE );

  TSigFile7BaseData = class
  private
    fText: string;
    fOwner: TSigFile7BaseData;
    fStructureOwner: TSigFile7BaseProperty;
    fChildren: TSigFile7BaseDataList;
    fItems: TSigFile7BaseDataList;
    fActiveItem: integer;
    fIsDirty2: boolean;
    fIsItem : boolean;
    fSaveActiveItem: boolean;
    fUpdating : integer;
    function GetName: string;
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);
    procedure SetActiveItem(const Value: integer); overload;
    function SetActiveItem(const pSender : TControl; const Value: TObject) : boolean; overload;
    procedure SetText(const Value: string);
    procedure SetItemText(const pItem : TSigFile7BaseData; const Value: string);
    function GetChild(const pWithName: string): TSigFile7BaseData;
    function GetItem(const pIndex: integer): TSigFile7BaseData;
    function GetIsDirty: boolean;
    procedure SetIsDirty(const Value: boolean);
    function GetValueAsBool: Boolean;
    procedure SetValueAsBool(const Value: Boolean);
    function GetValueAsFloat: single;
    procedure SetValueAsFloat(const Value: single);
    procedure SetOwner(const Value: TSigFile7BaseData);
    function GetValueAsInt: integer;
    procedure SetValueAsInt(const Value: integer);
    function GetUpdating: boolean;
    procedure SetUpdating(const Value: boolean);
  protected
  public
    constructor Create( pOwner : TSigFile7BaseData; const pStructureOwner : TSigFile7BaseProperty;
                        pIsItem : boolean );
    destructor Destroy; override;  // Do not call FREE directly - Call RemoveMe;
    procedure RemoveMe;

    procedure Clear;

    function CanSaveChildren : boolean; virtual;
    procedure Save( const pStrings : TStrings; const Indent : string ); overload; virtual;
    procedure Save( const pStrings : TStrings; const pIndex : integer; const Indent : string ); overload; virtual;
    procedure Save( const pStrings : TStrings; const pName : string; const pIndex : integer; const Indent : string ); overload; virtual;
    procedure Save( const pStrings : TStrings; const pName : string; const Indent : string ); overload; virtual;
    function Load( const pStrings : TStrings; var pFromLine : integer;
             const pErrors : TStrings; const pValue : string;
             const pEndName, pItemName : string ) : TSigFile7ErrorLevel; virtual;

    function SeekEnd( const pStrings : TStrings; var pFromLine : integer; const pErrors : TStrings; pName : string ) : TSigFile7ErrorLevel; virtual;

    property Text : string
             read fText
             write SetText;
    property Owner : TSigFile7BaseData
             read fOwner
             write SetOwner;
    property StructureOwner : TSigFile7BaseProperty
             read fStructureOwner;
    property Children : TSigFile7BaseDataList
             read fChildren;
    property Items : TSigFile7BaseDataList
             read fItems;

    property Child[ const pWithName : string ] : TSigFile7BaseData
             read GetChild;
    property Item[ const pIndex : integer ] : TSigFile7BaseData
             read GetItem; default;

    property Name : string
             read GetName;

    property Active : boolean
             read GetActive
             write SetActive;

    property ActiveItem : integer
             read fActiveItem
             write SetActiveItem;

    property SaveActiveItem : boolean
             read fSaveActiveItem
             write fSaveActiveItem;

    property IsDirty : boolean
             read GetIsDirty
             write SetIsDirty;
    class function Parse( const pStr : string; var pName : string; var pValue : string ) : TSigFile7ParseResult;
    class function IsIndexed( const pName : string; var pRootName : string; var pIndex : integer ) : boolean;

    //procedure RegisterEditor( const pEditor : TControl );
    //procedure UnRegisterEditor( const pEditor : TControl );

    property ValueAsBool : Boolean
             read GetValueAsBool
             write SetValueAsBool;
    property ValueAsFloat : single
             read GetValueAsFloat
             write SetValueAsFloat;
    property ValueAsInt : integer
             read GetValueAsInt
             write SetValueAsInt;
    property Updating : boolean
             read GetUpdating
             write SetUpdating;
  end;

  TSigFile7BaseDataList = class( TObjectList< TSigFile7BaseData > )
  private
  protected
  public
    function Add( pObject : TSigFile7BaseData ) : integer; reintroduce;
  end;

  TOnTextAccess = procedure( const pSender : TObject; var pText : string ) of object;

  TSigFile7BaseProperty = class(TControl)
  private
    fText: string;
    fSigFileParent: TSigFile7BaseProperty;
    fItemIndex: integer;
    fCurrentData: TSigFile7BaseData;
    //fControl : TTextControl;
    fEditorList : TSigFile7TextComponentList;
    fItem: TSigFile7BaseProperty;
    fSaveAsRelativeFileName: boolean;
    fOnLoadText: TOnTextAccess;
    fOnSaveText: TOnTextAccess;
    fSaveChildren: TSaveChildren;
    fSaveChildrenText: string;
    fEditor1: TControl;
    fEditor3: TControl;
    fEditor2: TControl;
    fEditor4: TControl;
    function GetSigParent: TSigFile7BaseProperty;
    procedure SetCurrentData(const Value: TSigFile7BaseData);
    function GetCurrentData: TSigFile7BaseData;
    function CanCreateCurrentData : boolean;
    function CreateCurrentData : TSigFile7BaseData;
//    function CanCreateCurrentItem : boolean;
//    function CreateCurrentItem : TSigFile7BaseData;
    function ChildCurrentDataParent( const pChild : TSigFile7BaseProperty ) : TSigFile7BaseData;
    procedure SetEditor1(const Value: TControl);
    procedure SetEditor2(const Value: TControl);
    procedure SetEditor3(const Value: TControl);
    procedure SetEditor4(const Value: TControl);
    procedure SetItem(const Value: TSigFile7BaseProperty);
    { Private declarations }
  protected
    function GetIsDirty: boolean;
    procedure SetText(const Value: string); overload; virtual;
    function SetText( const pEditor : TControl; const PValue : string ) : boolean; overload; virtual;
    procedure SetItemIndex(const Value: integer); overload; virtual;
    function SetItemIndex( const pEditor : TControl; const pValue : integer ) : boolean; overload; virtual;
    procedure SetItemIndex; overload; virtual;
    function IsOurControl( const pEditor : TControl ) : boolean; virtual;
    property Item : TSigFile7BaseProperty
             read fItem
             write SetItem;
    procedure SetParent(const Value: TFmxObject); override;
    { Protected declarations }
    property SaveAsRelativeFileName : boolean
             read fSaveAsRelativeFileName
             write fSaveAsRelativeFileName;

    function AddItem : TSigFile7BaseData; virtual;

    procedure DoBeginUpdate; override;
    procedure DoEndUpdate; override;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IsLegalEditor( pControl : TControl ) : boolean; virtual;
    procedure Paint; override;

    function SetItemIndex( const pEditor : TControl; const pValue : TObject ) : boolean; overload; virtual;

    procedure ChangeItemText(const pItem : TSigFile7BaseData; const Value: string); virtual;
    procedure AddItemText(const pItem : TSigFile7BaseData; const Value: string); virtual;
    procedure RemoveItemText(const pItem : TSigFile7BaseData); virtual;

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

    procedure RegisterEditor( const pEditor : TControl );
    procedure UnRegisterEditor( const pEditor : TControl );
    procedure UnregisterAllEditors;

    procedure ChangeText( const pSender : TObject; const pValue : string ); // slow way!

    property IsDirty : boolean
             read GetIsDirty;

    procedure BuildStructure( pData : TSigFile7BaseData ); // creates inactive children using out structure
    function CanSaveChildrenWhenTextIs( pValue : String ) : boolean; virtual;
  published
    { Published declarations }
    property OnSaveText : TOnTextAccess
             read fOnSaveText
             write fOnSaveText;
    property OnLoadText : TOnTextAccess
             read fOnLoadText
             write fOnLoadText;
    property SaveChildren : TSaveChildren
             read fSaveChildren
             write fSaveChildren default scAlways;
    property SaveChildrenText : string
             read fSaveChildrenText
             write fSaveChildrenText;
    property Editor1 : TControl
             read fEditor1
             write SetEditor1;
    property Editor2 : TControl
             read fEditor2
             write SetEditor2;
    property Editor3: TControl
             read fEditor3
             write SetEditor3;
    property Editor4: TControl
             read fEditor4
             write SetEditor4;
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
    property SaveAsRelativeFileName;
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

  TSigFile7BooleanProperty = class( TSigFile7BaseProperty )
  private
    function GetValue: boolean;
    procedure SetValue(const Value: boolean);
  protected
  public
  published
    property Value : boolean
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

  TSigFile7ListComponentList = class( TObjectList< TSigFile7TestListComponent > )
  private
    fUpdating : integer;
  public
    function AddControl( pControl : TControl; const pUseStandardIntercepts : boolean = TRUE;
                         const pUseStandardSelectors : boolean = TRUE ) : TSigFile7TestListComponent; reintroduce;
    procedure Remove( const pControl : TControl ); overload;
    function IsOurControl( const pEditor : TControl ) : boolean;
    function SetItemIndex( const pEditor : TControl; const pValue : integer ) : boolean;
    function ItemWithControl( const pEditor : TControl ) : TSigFile7TestListComponent;
    procedure ChangeItemText(const pItem : TSigFile7BaseData; const Value: string);
    procedure AddItemText( const pItem : TSigFile7BaseData; const pValue : string );
    procedure RemoveItemText( const pItem : TSigFile7BaseData );

    procedure BeginUpdate;
    procedure EndUpdate;
  end;

  TSigFile7List = class(  TSigFile7BaseProperty )
  private
    fItemsEditorList : TSigFile7ListComponentList;
    fSaveItemIndex: boolean;
    fItemsEditor2: TControl;
    fItemsEditor3: TControl;
    fItemsEditor1: TControl;
    fItemsEditor4: TControl;
    procedure SetItemsEditor1(const Value: TControl);
    procedure SetItemsEditor2(const Value: TControl);
    procedure SetItemsEditor3(const Value: TControl);
    procedure SetItemsEditor4(const Value: TControl);
  protected
    procedure SetItemIndex(const Value: integer); overload; override;
    function SetItemIndex( const pEditor : TControl; const pValue : integer ) : boolean; overload; override;
    procedure SetItemIndex; overload; override;
    function IsOurControl( const pEditor : TControl ) : boolean; override;
    procedure DoBeginUpdate; override;
    procedure DoEndUpdate; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RegisterItemsEditor( const pEditor : TControl );
    procedure UnRegisterItemsEditor( const pEditor : TControl );

    function SetItemIndex( const pEditor : TControl; const pValue : TObject ) : boolean; overload; override;

    procedure SetListBoxTexts( const pEditor : TControl ); overload;
    procedure SetListBoxTexts( const pEditor : TSigFile7TestListComponent ); overload;
    procedure SetListBoxTexts; overload;

    procedure ChangeItemText(const pItem : TSigFile7BaseData; const Value: string); override;
    procedure AddItemText(const pItem : TSigFile7BaseData; const Value: string); override;
    procedure RemoveItemText(const pItem : TSigFile7BaseData); override;

    function AddItem : TSigFile7BaseData; override;

  published
    property Item;       // class corresponding to Item[ i ]
    property SaveItemIndex : boolean
             read fSaveItemIndex
             write fSaveItemIndex;
    property ItemsEditor1 : TControl
             read fItemsEditor1
             write SetItemsEditor1;
    property ItemsEditor2 : TControl
             read fItemsEditor2
             write SetItemsEditor2;
    property ItemsEditor3: TControl
             read fItemsEditor3
             write SetItemsEditor3;
    property ItemsEditor4: TControl
             read fItemsEditor4
             write SetItemsEditor4;
  end;

  TSigFile7File = class( TSigFile7BaseProperty )
  private
    fFileName: string;
  protected
  public
    function Load( const pStrings : TStrings;
             const pErrors : TStrings ) : TSigFile7ErrorLevel; virtual;
    procedure Save( const pStrings : TStrings ); virtual;

    (*
    property IsDirty : boolean
             read fIsDirty
             write SetIsDirty;
    *)

    function LoadFromFile( const pFilename : string = '' ) : boolean; virtual; // true if file exists
    procedure SaveToFile( const pFilename : string = '' ); virtual;
    procedure SaveIfDirty( const pFilename : string = '' ); virtual;

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
                                   TSigFile7BooleanProperty,
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

function TSigFile7BaseProperty.AddItem: TSigFile7BaseData;
begin
  Result := nil;
  if assigned( fCurrentData ) then
  begin
    if assigned( Item ) then
    begin
      Result := TSigFile7BaseData.Create( fCurrentData, Item, TRUE );
      Result.Active := TRUE;
    end;
  end;
end;

procedure TSigFile7BaseProperty.AddItemText(const pItem: TSigFile7BaseData;
  const Value: string);
begin
  // we don't have list editors so do nothing!
end;

procedure TSigFile7BaseProperty.BuildStructure(pData: TSigFile7BaseData);
var
  i: Integer;
begin
  for i := 0 to ControlsCount - 1 do
  begin
    if Controls[ i ] is TSigFile7BaseProperty then
    begin
      TSigFile7BaseData.Create( pData, (Controls[ i ] as TSigFile7BaseProperty), FALSE );
    end;
  end;
end;

function TSigFile7BaseProperty.CanCreateCurrentData: boolean;
begin
  if csDesigning in ComponentState then
  begin
    Result := FALSE;
  end
  else if Self is TSigFile7File then
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

(*
function TSigFile7BaseProperty.CanCreateCurrentItem: boolean;
begin
  if csDesigning in ComponentState then
  begin
    Result := FALSE;
  end
  else if assigned( self.Item ) then
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;
*)

function TSigFile7BaseProperty.CanSaveChildrenWhenTextIs(
  pValue: String): boolean;
begin
  case fSaveChildren of
    scAlways:
    begin
      Result := TRUE;
    end;
    scNever:
    begin
      Result := FALSE;
    end;
    scIfEQ:
    begin
      Result := pValue = SaveChildrenText;
    end;
    scIfNE:
    begin
      Result := pValue <> SaveChildrenText;
    end;
    else
    begin
      Result := TRUE;
    end;
  end;
end;

procedure TSigFile7BaseProperty.ChangeItemText(const pItem: TSigFile7BaseData;
  const Value: string);
begin
  // we don't have list editors so do nothing!
end;

procedure TSigFile7BaseProperty.ChangeText(const pSender: TObject;
  const pValue: string);
var
  i : integer;
begin
  if pSender is TControl then
  begin
    if IsOurControl( pSender as TControl ) then
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
    if assigned( Children ) then
    begin
      for i := 0 to Children.Count - 1 do
      begin
        if Children[ i ] is TSigFile7BaseProperty then
        begin
          (Children[ i ] as TSigFile7BaseProperty).ChangeText( pSender, pValue );
        end;
      end;
    end;
  end;
end;

constructor TSigFile7BaseProperty.Create(AOwner: TComponent);
begin
  inherited;
  fEditorList := TSigFile7TextComponentList.Create; //( FALSE );
  fItemIndex := -1;
  // see if we can create our data
  // GetCurrentData;
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
  Result := fCurrentData;
end;

(*
function TSigFile7BaseProperty.CreateCurrentItem: TSigFile7BaseData;
begin
  Result := nil;
  if assigned( Item ) then
  begin
    Item.CurrentData := TSigFile7BaseData.Create( ChildCurrentDataParent( Item ), Item, TRUE );
    Result := Item.CurrentData;
  end;
end;
*)

destructor TSigFile7BaseProperty.Destroy;
begin
  UnregisterAllEditors;
  fEditorList.Free;
  inherited;
end;

procedure TSigFile7BaseProperty.DoBeginUpdate;
begin
  inherited;
  fEditorList.BeginUpdate;
end;

procedure TSigFile7BaseProperty.DoEndUpdate;
begin
  inherited;
  fEditorList.Endupdate;
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
  if assigned( CurrentData ) then
  begin
    Result := CurrentData.IsDirty;
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
    If we are contructing the file visually we will put the elements in the classes
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

function TSigFile7BaseProperty.IsLegalEditor(pControl: TControl): boolean;
begin
  Result := TRUE; // add proper tests later!
end;

function TSigFile7BaseProperty.IsOurControl(
  const pEditor: TControl): boolean;
var
  i: Integer;
begin
  for i := 0 to fEditorList.Count - 1 do
  begin
    if fEditorList[ i ].Control = pEditor then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

procedure TSigFile7BaseProperty.Paint;
//var
//  ResStream : TResourceStream;
begin
  inherited;
  (*
  if csDesigning in ComponentState then
  begin
    ResStream := TResourceStream.Create( HInstance, self.ClassName, RT_RCDATA);
  end;
  *)
end;

procedure TSigFile7BaseProperty.RegisterEditor(const pEditor: TControl );
var
  iComponent : TSigFile7TextComponent;
begin
  iComponent := fEditorList.AddControl( pEditor );
  pEditor.TagObject := self;
  if not( csDesigning in pEditor.ComponentState) then
  begin
    GetCurrentData;
  end;
  iComponent.Text := Text;
end;

procedure TSigFile7BaseProperty.RemoveItemText(const pItem: TSigFile7BaseData);
begin
  // do nothing by default
end;

function TSigFile7BaseData.CanSaveChildren: boolean;
begin
  if Children.Count = 0 then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := StructureOwner.CanSaveChildrenWhenTextIs( fText );
  end;
end;

procedure TSigFile7BaseData.Clear;
var
  i: Integer;
begin
  fText := fStructureOwner.Text; // use owner text as a default!
  Items.Clear;
  for i := 0 to Children.Count - 1 do
  begin
    Children[ i ].Clear;
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
  fIsItem := pIsItem;
  if assigned( pOwner ) then
  begin
    if pIsItem then
    begin
      pOwner.Items.Add( self );
      pOwner.StructureOwner.AddItemText( self, fText );
      {
      if pOwner.ActiveItem < 0 then
      begin
        pOwner.ActiveItem := 0;
      end;
      }
      //pOwner.ActiveItem := iItem;
      fStructureOwner.BuildStructure( self ); // it is only items that are build 'on the fly'
    end
    else
    begin
      pOwner.Children.Add( self );
    end;
  end;
  IsDirty := TRUE;
end;

destructor TSigFile7BaseData.Destroy;
begin
  //fEditorList.Free;

  if fStructureOwner.fCurrentData = self then
  begin
    fStructureOwner.fCurrentData := nil;
  end;
  if fIsItem then
  begin
    if assigned( fOwner ) then
    begin
      if fOwner.ActiveItem >= fOwner.Items.Count then
      begin
        fOwner.ActiveItem := fOwner.Items.Count - 1;
      end;
    end;
  end;

  fItems.Free;
  fChildren.Free;
  inherited;
end;

function TSigFile7BaseData.GetActive: boolean;
begin
  Result := fStructureOwner.fCurrentData = self;
  // We use the local fCurrentData because we do not want current data to be auto created in this case
end;

function TSigFile7BaseData.GetChild(const pWithName: string): TSigFile7BaseData;
var
  i: Integer;
begin
  for i := 0 to Children.Count - 1 do
  begin
    Result := Children[ i ];
    if SameText( Result.Name, pWithName ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function TSigFile7BaseData.GetIsDirty: boolean;
begin
  if assigned( fOwner ) then
  begin
    Result := fOwner.IsDirty;
  end
  else
  begin
    Result := fIsDirty2;
  end;
end;

function TSigFile7BaseData.GetItem(const pIndex: integer): TSigFile7BaseData;
begin
  Result := Items[ pIndex ];
end;

function TSigFile7BaseData.GetName: string;
begin
  Result := StructureOwner.Name;
end;

function TSigFile7BaseData.GetUpdating: boolean;
begin
  Result := fUpdating <> 0;
end;

function TSigFile7BaseData.GetValueAsBool: Boolean;
begin
  if SameText( Text, 'TRUE' ) or (Text = '1') then
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TSigFile7BaseData.GetValueAsFloat: single;
begin
  Result := StrToFloatDef( Text, 0 );
end;

function TSigFile7BaseData.GetValueAsInt: integer;
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
    pRootName := pName;
    Result := FALSE;
  end;

end;

function TSigFile7BaseData.Load(const pStrings: TStrings;
  var pFromLine: integer; const pErrors: TStrings; const pValue : string;
  const pEndName, pItemName : string) : TSigFile7ErrorLevel;
var
  iParseResult : TSigFile7ParseResult;
  iName, iValue, iNameRoot : string;
  i, iIndex : integer;
  iResult : TSigFile7ErrorLevel;
label
  Retry;
  procedure SetItemText( const pItem : TSigFile7BaseData; pValue : string );
  begin
    if assigned( pItem.StructureOwner.OnLoadText ) then
    begin
      pItem.StructureOwner.OnLoadText( pItem, pValue );
    end;
    if pItem.StructureOwner.SaveAsRelativeFileName then
    begin
      pValue := ExtractFilePath( ParamStr( 0 )) + pValue;
      pValue := ExpandUNCFileName( pValue );
    end;
    pItem.Text := pValue;
  end;
begin
  Result := elOK;
  SetItemText( self, pValue );
  //Text := pValue;
  // first we need to analyse the line. The first line (BEGIN...) has already been read.
  try
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
      prValue:
      begin
        // single line variant
        if iName = '' then
        begin
          // we can only have nameless children in arrays
          Result := elError;
          pErrors.AddObject( 'VALUE without name - object ignored', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
          inc( pFromLine );
          goto Retry;
        end
        else
        begin
          if IsIndexed( iName, iNameRoot, iIndex ) then
          begin
            if (iNameRoot = '') or SameText( iNameRoot, pItemName )  then
            begin
              while iIndex >= Items.Count do
              begin
                TSigFile7BaseData.Create( self, fStructureOwner.Item, TRUE);
              end;
              inc( pFromLine );
              SetItemText( Items[ iIndex ], iValue );
              Items[ iIndex ].Active := TRUE;
              //Items[ iIndex ].Text := iValue;
              goto Retry;
            end
            else
            begin
              Result := elError;
              pErrors.AddObject( 'Indexed item does not match list object', TSigFile7ErrorObject.Create( Result, pFromLine, self ));
              inc( pFromLine );
              goto Retry;
            end;
          end
          else
          begin
            // not indexed, so there should be a one to one relationship
            // with fStructureOwner children
            with fStructureOwner do
            begin
                if assigned( Children ) then
                begin
                for i := 0 to Children.Count - 1 do
                begin
                  if SameText(Children.Items[ i ].Name, iName) then
                  begin
                    inc( pFromLine );
                    with Children.Items[ i ] as TSigFile7BaseProperty do
                    begin
                      if assigned( CurrentData ) then
                      begin
                        SetItemText( CurrentData, iValue );
                        //CurrentData.Text := iValue;
                        goto Retry;
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
            goto Retry;
          end;
        end;
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
            if (iNameRoot = '') or SameText( iNameRoot, pItemName )  then
            begin
              while iIndex >= Items.Count do
              begin
                TSigFile7BaseData.Create( self, fStructureOwner.Item, TRUE);
              end;
              inc( pFromLine );
              Items[ iIndex ].Active := TRUE;
              Items[ iIndex ].Load( pStrings, pFromLine, pErrors, iValue, iName, pItemName );
              goto Retry;
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
                if SameText(Children.Items[ i ].Name, iName) then
                begin
                  inc( pFromLine );
                  with Children.Items[ i ] as TSigFile7BaseProperty do
                  begin
                    if assigned( CurrentData ) then
                    begin
                      iResult := CurrentData.Load( pStrings, pFromLine, pErrors, iValue, iName, iName );
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
        if SameText(iName, pEndName) then
        begin
          // OK;
          inc( pFromLine );
          exit;
        end
        else
        begin
          Result := elError;
          pErrors.AddObject( 'Missing "END "' + pEndName, TSigFile7ErrorObject.Create( Result, pFromLine, self ));
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
  finally
    //SetItemText( self, pValue );
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
    prValue:
    begin
      inc( pFromLine );
      goto Retry;
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

function TSigFile7BaseData.SetActiveItem(const pSender: TControl;
  const Value: TObject): boolean;
var
  i : integer;
begin
  for i := 0 to Items.Count - 1 do
  begin
    if Items[ i ] = Value then
    begin
      SetActiveItem( i );
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

procedure TSigFile7BaseData.SetActiveItem(const Value: integer);
begin
  if fActiveItem <> Value then
  begin
    if fActiveItem >= 0 then
    begin
      fItems[ fActiveItem ].Active := FALSE;
    end;
    fActiveItem := Value;
    if fActiveItem >= 0 then
    begin
      fItems[ fActiveItem ].Active := TRUE;
    end;
    StructureOwner.SetItemIndex;
  end;
end;

procedure TSigFile7BaseData.SetIsDirty(const Value: boolean);
begin
  if assigned( fOwner ) then
  begin
    fOwner.IsDirty := Value;
  end
  else
  begin
    fIsDirty2 := Value;
  end;
end;

procedure TSigFile7BaseData.SetItemText(const pItem: TSigFile7BaseData;
  const Value: string);
begin
  fStructureOwner.ChangeItemText( pItem, Value );
end;

procedure TSigFile7BaseData.SetOwner(const Value: TSigFile7BaseData);
begin
  fOwner := Value;
end;

procedure TSigFile7BaseData.SetText(const Value: string);
begin
  // we cannot set a value if we are already in the process of setting a value
  if not Updating then
  begin
    Updating := TRUE;
    try
      if fText <> Value then
      begin
        IsDirty := TRUE;
      end;
      fText := Value;
      fStructureOwner.ChangeText( self, Value );
      if fIsItem then
      begin
        if assigned( fOwner ) then
        begin
          fOwner.SetItemText( self, Value );
        end;
      end;
    finally
      Updating := FALSE;
    end;
  end;
end;

procedure TSigFile7BaseData.SetUpdating(const Value: boolean);
begin
  if Value then
  begin
    inc( fUpdating );
  end
  else
  begin
    if fUpdating > 0 then
    begin
      Dec( fUpdating );
    end;
  end;
end;

procedure TSigFile7BaseData.SetValueAsBool(const Value: Boolean);
begin
  if Value then
  begin
    Text := 'TRUE';
  end
  else
  begin
    Text := 'FALSE';
  end;
end;

procedure TSigFile7BaseData.SetValueAsFloat(const Value: single);
begin
  Text := FloatToStr( Value );
end;

procedure TSigFile7BaseData.SetValueAsInt(const Value: integer);
begin
  Text := IntToStr( Value );
end;

{
procedure TSigFile7BaseData.UnRegisterEditor(const pEditor: TControl);
begin
  fEditorList.Remove( pEditor );
end;
}

procedure TSigFile7BaseProperty.SetCurrentData(const Value: TSigFile7BaseData);
var
  i: Integer;
begin
 fCurrentData := Value;
 if assigned( fCurrentData ) then
 begin
   for i := 0 to fEditorList.Count - 1 do
   begin
     fEditorList[ i ].Text := fCurrentData.Text;
   end;
 end
 else
 begin
   for i := 0 to fEditorList.Count - 1 do
   begin
     fEditorList[ i ].Text := '';
   end;
 end;
end;

procedure TSigFile7BaseProperty.SetEditor1(const Value: TControl);
begin
  if assigned( fEditor1 ) then
  begin
    UnRegisterEditor( fEditor1 );
  end;
  fEditor1 := Value;
  if assigned( fEditor1 ) then
  begin
    RegisterEditor( fEditor1 );
  end;
end;

procedure TSigFile7BaseProperty.SetEditor2(const Value: TControl);
begin
  if assigned( fEditor2 ) then
  begin
    UnRegisterEditor( fEditor2 );
  end;
  fEditor2 := Value;
  if assigned( fEditor2 ) then
  begin
    RegisterEditor( fEditor2 );
  end;
end;

procedure TSigFile7BaseProperty.SetEditor3(const Value: TControl);
begin
  if assigned( fEditor3 ) then
  begin
    UnRegisterEditor( fEditor3 );
  end;
  fEditor3 := Value;
  if assigned( fEditor3 ) then
  begin
    RegisterEditor( fEditor3 );
  end;
end;

procedure TSigFile7BaseProperty.SetEditor4(const Value: TControl);
begin
  if assigned( fEditor4 ) then
  begin
    UnRegisterEditor( fEditor4 );
  end;
  fEditor3 := Value;
  if assigned( fEditor4 ) then
  begin
    RegisterEditor( fEditor4 );
  end;
end;

procedure TSigFile7BaseProperty.SetItemIndex;
begin
  // do nothing - only applies to lists
end;

function TSigFile7BaseProperty.SetItemIndex(const pEditor: TControl;
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

procedure TSigFile7BaseProperty.SetItem(const Value: TSigFile7BaseProperty);
begin
  if fItem <> Value then
  begin
    if assigned( fItem ) then
    begin
      fItem.SigParent := nil;
    end;
    fItem := Value;
    if assigned( fItem ) then
    begin
      fItem.SigParent := self;
    end;
  end;
end;

function TSigFile7BaseProperty.SetItemIndex(const pEditor: TControl;
  const pValue: TObject): boolean;
begin
  // does nothing!
  Result := FALSE;
end;

function TSigFile7BaseProperty.SetText(const pEditor: TControl;
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
    end
    else
    begin
      Result := FALSE;
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


procedure TSigFile7BaseProperty.UnregisterAllEditors;
var
  i: Integer;
begin
  for i := fEditorList.Count - 1 downto 0 do
  begin
    fEditorList.Remove( fEditorList[ i ]);
  end;
end;

procedure TSigFile7BaseProperty.UnRegisterEditor(const pEditor: TControl);
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
    if csDesigning in ComponentState then
    begin
      Result := StrToIntDef( Text, 0);
    end
    else
    begin
      Result := StrToInt( Text ); // allow exception to raise if error!
    end;
  end;
end;

procedure TSigFile7IntegerProperty.SetValue(const Value: integer);
begin
  Text := IntToStr( Value );
end;

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
    // missing BEGIN.
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
    prValue:
    begin
      Result := elFatalError;
      pErrors.AddObject( 'Missing "BEGIN "' + Name, TSigFile7ErrorObject.Create( Result, iFromLine, fCurrentData ));
      exit;
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
  BeginUpdate;
  try
    fCurrentData.Clear;
    inc( iFromLine );
    //fCurrentData.Text := iValue;
    Result := fCurrentData.Load( pStrings, iFromLine, pErrors, iValue, Name, Name );
    fCurrentData.IsDirty := FALSE;
  finally
    EndUpdate;
  end;
end;

{ TSigFile7TextProperty }

function TSigFile7File.LoadFromFile(const pFilename: string) : boolean;
var
  iSrc, iErrors : TStringList;
  iFileName : string;
begin
  if pFileName = '' then
  begin
    iFileName := TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + ExtractFileName( fFileName );
  end
  else
  begin
    iFileName := pFileName;
    if fFileName = '' then
    begin
      fFileName := pFileName;
    end;
  end;
  if FileExists( iFileName ) then
  begin
    Result := TRUE;
    iSrc := TStringList.Create;
    iErrors := TStringList.Create;
    try
      iSrc.LoadFromFile( iFileName );
      Load( iSrc, iErrors );
    finally
      iSrc.Free;
      iErrors.Free;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TSigFile7File.Save(const pStrings: TStrings);
begin
  fCurrentData.Save( pStrings, '' );
end;

procedure TSigFile7File.SaveIfDirty(const pFilename: string);
begin
  if IsDirty then
  begin
    SaveToFile( pFileName );
  end;
end;

procedure TSigFile7File.SaveToFile(const pFilename: string);
var
  iSrc : TStringList;
  iFileName : string;
begin
  if pFileName = '' then
  begin
    iFileName := TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + ExtractFileName( fFileName );
  end
  else
  begin
    iFileName := pFileName;
    if fFileName = '' then
    begin
      fFileName := pFileName;
    end;
  end;
  iSrc := TStringList.Create;
  try
    Save( iSrc );
    iSrc.SaveToFile( iFileName );
  finally
    iSrc.Free;
  end;
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
  else if SameText( Copy( iStr, 1, 5 ), 'VALUE' ) then
  begin
    Result := prValue;
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

procedure TSigFile7BaseData.RemoveMe;
begin
  if assigned( Owner ) then
  begin
    if fIsItem then
    begin
      Owner.Items.Remove( self );
      Owner.StructureOwner.RemoveItemText( self );
      fStructureOwner.BuildStructure( self ); // it is only items that are build 'on the fly'
    end
    else
    begin
      Owner.Children.Remove( self );
    end;
  end
  else
  begin
    Free;
  end;
end;

{
procedure TSigFile7BaseData.RegisterEditor(const pEditor: TControl);
var
  iComponent : TSigFile7TextComponent;
begin
  if not( csDesigning in pEditor.ComponentState) then
  begin
    iComponent := fEditorList.AddControl( pEditor );
    pEditor.TagObject := self;
    iComponent.Text := Text;
  end;
end;
}

procedure TSigFile7SingleProperty.SetValue(const Value: single);
begin
  Text := FloatToStr( Value );
end;

procedure TSigFile7BaseData.Save(const pStrings: TStrings; const pName,
  Indent: string);
var
  i : integer;
  iText : string;
  iCanSaveChildren : boolean;
begin
  if StructureOwner.SaveAsRelativeFileName then
  begin
    iText := ExtractRelativePath( ParamStr( 0 ), Text )
  end
  else
  begin
    iText := Text;
  end;
  if assigned( fStructureOwner.OnSaveText ) then
  begin
    fStructureOwner.OnSaveText( self, iText );
  end;
  iCanSaveChildren := CanSaveChildren;
  if (Items.Count = 0) and (not iCanSaveChildren) then
  begin
    if iText = '' then
    begin
      pStrings.Add( Indent + 'VALUE ' + pName );
    end
    else
    begin
      pStrings.Add( Indent + 'VALUE ' + pName + ' = ' + iText);
    end;
  end
  else
  begin
    if iText = '' then
    begin
      pStrings.Add( Indent + 'BEGIN ' + pName );
    end
    else
    begin
      pStrings.Add( Indent + 'BEGIN ' + pName + ' = ' + iText);
    end;
    for i := 0 to Items.Count - 1 do
    begin
      Items[ i ].Save( pStrings, pName, i, Indent + '  ');
    end;
    if iCanSaveChildren then
    begin
      for i := 0 to Children.Count - 1 do
      begin
        Children[ i ].Save( pStrings, Indent + '  ');
      end;
    end;
    pStrings.Add( Indent + 'END ' + pName);
  end;
end;

procedure TSigFile7BaseData.Save(const pStrings: TStrings; const pName: string;
  const pIndex: integer; const Indent: string);
begin
  Save( pStrings, pName + '(' + IntToStr( pIndex ) + ')', Indent );
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

{ TSigFile7List }

function TSigFile7List.AddItem: TSigFile7BaseData;
begin
  Result := inherited AddItem;
end;

procedure TSigFile7List.AddItemText(const pItem: TSigFile7BaseData;
  const Value: string);
begin
  inherited;
  fItemsEditorList.AddItemText( pItem, Value );
end;

procedure TSigFile7List.ChangeItemText(const pItem: TSigFile7BaseData;
  const Value: string);
begin
  inherited;
  fItemsEditorList.ChangeItemText( pItem, Value );
end;

constructor TSigFile7List.Create(AOwner: TComponent);
begin
  inherited;

  fItemsEditorList := TSigFile7ListComponentList.Create; //( FALSE );

end;

destructor TSigFile7List.Destroy;
begin
  fItemsEditorList.Free;

  inherited;
end;

procedure TSigFile7List.DoBeginUpdate;
begin
  inherited;
  fItemsEditorList.BeginUpdate;
end;

procedure TSigFile7List.DoEndUpdate;
begin
  inherited;
  fItemsEditorList.EndUpdate;
end;

function TSigFile7List.IsOurControl(const pEditor: TControl): boolean;
begin
  Result := inherited;
  if not Result then
  begin
    Result := fItemsEditorList.IsOurControl( pEditor );
  end;
end;

procedure TSigFile7List.RegisterItemsEditor(const pEditor: TControl);
begin
  fItemsEditorList.AddControl( pEditor );
  pEditor.TagObject := self;
  GetCurrentData;
  SetListBoxTexts( pEditor );
  if assigned( CurrentData ) then
  begin
    SetItemIndex( pEditor, CurrentData.ActiveItem);
  end
  else
  begin
    SetItemIndex( pEditor, -1);
  end;
end;

procedure TSigFile7List.RemoveItemText(const pItem: TSigFile7BaseData);
begin
  inherited;
  fItemsEditorList.RemoveItemText( pItem );

end;

procedure TSigFile7List.SetItemIndex(const Value: integer);
begin
  inherited;
  if assigned( CurrentData ) then
  begin
    CurrentData.ActiveItem := Value;
  end;
end;

procedure TSigFile7List.SetItemIndex;
var
  i: Integer;
  iIndex : integer;
begin
  if assigned( CurrentData ) then
  begin
    iIndex := CurrentData.ActiveItem;
  end
  else
  begin
    iIndex := -1;
  end;
  if assigned( fItemsEditorList ) then
  begin
    for i := 0 to fItemsEditorList.Count - 1 do
    begin
      SetItemIndex( fItemsEditorList.Items[ i ].Control, iIndex );
    end;
  end;
end;

function TSigFile7List.SetItemIndex(const pEditor: TControl;
  const pValue: integer): boolean;
begin
  Result := fItemsEditorList.SetItemIndex( pEditor, pValue );
  if assigned( Item ) then
  begin
    if assigned( GetCurrentData() ) then
    begin
      if pValue >= 0 then
      begin
        Item.CurrentData := CurrentData.Items[ pValue ];
      end
      else
      if assigned( Item.GetCurrentData() ) then
      begin
        Item.CurrentData.Active := FALSE;;
      end;
    end;
  end;
  if not Result then
  begin
    Result := inherited;
  end;
end;

function TSigFile7List.SetItemIndex(const pEditor: TControl;
  const pValue: TObject): boolean;
begin
  if assigned( fCurrentData ) then
  begin
    Result := fCurrentData.SetActiveItem( pEditor, pValue );
  end
  else
  begin
    Result := FALSE;
  end;
  if not Result then
  begin
    Result := inherited;
  end;
end;

procedure TSigFile7List.SetItemsEditor1(const Value: TControl);
begin
  if assigned( fItemsEditor1 ) then
  begin
    UnRegisterItemsEditor( fItemsEditor1 );
  end;
  fItemsEditor1 := Value;
  if assigned( fItemsEditor1 ) then
  begin
    RegisterItemsEditor( fItemsEditor1 );
  end;
end;

procedure TSigFile7List.SetItemsEditor2(const Value: TControl);
begin
  if assigned( fItemsEditor2 ) then
  begin
    UnRegisterItemsEditor( fItemsEditor2 );
  end;
  fItemsEditor2 := Value;
  if assigned( fItemsEditor2 ) then
  begin
    RegisterItemsEditor( fItemsEditor2 );
  end;
end;

procedure TSigFile7List.SetItemsEditor3(const Value: TControl);
begin
  if assigned( fItemsEditor3 ) then
  begin
    UnRegisterItemsEditor( fItemsEditor3 );
  end;
  fItemsEditor3 := Value;
  if assigned( fItemsEditor3 ) then
  begin
    RegisterItemsEditor( fItemsEditor3 );
  end;
end;

procedure TSigFile7List.SetItemsEditor4(const Value: TControl);
begin
  if assigned( fItemsEditor4 ) then
  begin
    UnRegisterItemsEditor( fItemsEditor4 );
  end;
  fItemsEditor4 := Value;
  if assigned( fItemsEditor4 ) then
  begin
    RegisterItemsEditor( fItemsEditor4 );
  end;
end;

procedure TSigFile7List.SetListBoxTexts;
var
  i: Integer;
begin
  if assigned( fItemsEditorList ) then
  begin
    for i := 0 to fItemsEditorList.Count - 1 do
    begin
      SetListBoxTexts( fItemsEditorList.Items[ i ] );
    end;
  end;
end;

procedure TSigFile7List.SetListBoxTexts(const pEditor: TControl );
var
  iItem : TSigFile7TestListComponent;
begin
  iItem := self.fItemsEditorList.ItemWithControl( pEditor );
  SetListBoxTexts( iItem );
end;

procedure TSigFile7List.SetListBoxTexts(
  const pEditor: TSigFile7TestListComponent);
var
  i : integer;
begin
  if assigned( pEditor ) then
  begin
    pEditor.Clear;
    if assigned( CurrentData ) then
    begin
      with CurrentData.Items do
      begin
        for i := 0 to Count - 1 do
        begin
          pEditor.Items.AddObject( CurrentData.Items[ i ].Text, CurrentData.Items[ i ] )
        end;
      end;
    end;
  end;
end;

procedure TSigFile7List.UnRegisterItemsEditor(const pEditor: TControl);
begin
  fItemsEditorList.Remove( pEditor );
end;

{ TSigFile7TextComponentList }

function TSigFile7TextComponentList.AddControl(
  pControl: TControl; const pUseStandardIntercepts : boolean ): TSigFile7TextComponent;
var
  i: Integer;
begin
  Result := TSigFile7TextComponent.Create( pControl, pUseStandardIntercepts );
  Add( Result );
  // we do not expect to add while updating, but, just in case
  for i := 1 to fUpdating do
  begin
    pControl.BeginUpdate;
  end;
end;

procedure TSigFile7TextComponentList.BeginUpdate;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[ i ].Control.BeginUpdate;
  end;
end;

destructor TSigFile7TextComponentList.Destroy;
begin
  inherited;
end;

procedure TSigFile7TextComponentList.Endupdate;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[ i ].Control.EndUpdate;
  end;
end;

procedure TSigFile7TextComponentList.Remove(const pControl: TControl);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Control = pControl then
    begin
      Delete( i );
      exit;
    end;
  end;
end;

{ TSigFile7ListComponentList }

function TSigFile7ListComponentList.AddControl(
  pControl: TControl; const pUseStandardIntercepts, pUseStandardSelectors : boolean): TSigFile7TestListComponent;
var
  i: Integer;
begin
  Result := TSigFile7TestListComponent.Create( pControl, pUseStandardIntercepts, pUseStandardSelectors );
  Add( Result );
  for i := 1 to fUpdating do
  begin
    pControl.BeginUpdate;
  end;
end;

procedure TSigFile7ListComponentList.AddItemText(const pItem: TSigFile7BaseData;
  const pValue: string);
var
  i : integer;
begin
  inherited;
  for i := 0 to Count - 1 do
  begin
    Items[ i ].AddItemText( pItem, pValue );
  end;
end;

procedure TSigFile7ListComponentList.BeginUpdate;
var
  i: Integer;
begin
  Inc( fUpdating );
  for i := 0 to Count - 1 do
  begin
    Items[ i ].Control.BeginUpdate;
  end;
end;

procedure TSigFile7ListComponentList.ChangeItemText(
  const pItem: TSigFile7BaseData; const Value: string);
var
  i : integer;
begin
  inherited;
  for i := 0 to Count - 1 do
  begin
    Items[ i ].ChangeItemText( pItem, Value );
  end;
end;

procedure TSigFile7ListComponentList.EndUpdate;
var
  i: Integer;
begin
  Dec( fUpdating );
  for i := 0 to Count - 1 do
  begin
    Items[ i ].Control.EndUpdate;
  end;
end;

function TSigFile7ListComponentList.IsOurControl(
  const pEditor: TControl): boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Control = pEditor then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

function TSigFile7ListComponentList.ItemWithControl(
  const pEditor: TControl): TSigFile7TestListComponent;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[ i ];
    if Result.Control = pEditor then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

procedure TSigFile7ListComponentList.Remove(const pControl: TControl);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Control = pControl then
    begin
      Delete( i );
      exit;
    end;
  end;
end;

procedure TSigFile7ListComponentList.RemoveItemText(
  const pItem: TSigFile7BaseData);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[ i ].RemoveItemText( pItem );
  end;
end;

function TSigFile7ListComponentList.SetItemIndex(const pEditor: TControl;
  const pValue: integer): boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Control = pEditor then
    begin
      Items[ i ].ItemIndex := pValue;
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

{ TSigFile7BooleanProperty }

function TSigFile7BooleanProperty.GetValue: boolean;
begin
  if SameText( Text, 'TRUE' ) then
  begin
    Result := TRUE;
  end
  else if Text = '1' then
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TSigFile7BooleanProperty.SetValue(const Value: boolean);
begin
  if Value then
  begin
    Text := 'TRUE';
  end
  else
  begin
    Text := 'FALSE';
  end;
end;

{ TSigFile7BaseDataList }

function TSigFile7BaseDataList.Add(pObject: TSigFile7BaseData): integer;
begin
  Result := inherited Add( pObject );
end;

initialization

finalization


end.

