unit UnitEditableLanguageObjects;

{
  This provides an editable language template facility to provide fast input
  for a structured language or a programming style that uses a structured approach

  Each template  comprises a shell with optional or mandatory children

  There are 3 levels (minimum, although bottom level may not be open) present

   ****************************
   *                          *
   * Template owner           *
   *                          *
   ****************************
               *
               *
   ****************************
   *                          *
   * Template                 *
   *                          *
   ****************************
               *
               *
   ****************************
   *                          *
   * Object                   *
   *                          *
   ****************************

   All are of the same basic type.

   There are two views :

   Template view, where we are editing the template, and

   Object view where we are editing the object.

   The template owner cannot be edited (except by making the template
   into the object.

   Note that an object can utilise multiple templates


}

interface

  uses
    Contnrs,
    classes,
    Dialogs,
    Controls,
    Common,
    SysUtils,
    ButtonGroup,
    ComCtrls,
    UnitNewTemplate;

type

  //------------- text locators
  tTextLocator = class
  private
    fLine: integer;
    fStartPos: integer;
    fEndPos: integer;
  public
    property Line : integer
             read fLine
             write fLine;
    property StartPos : integer
             read fStartPos
             write fStartPos;
    property EndPos : integer
             read fEndPos
             write fEndPos;
  end;

  tTextLocatorList = class( TObjectList )
  public
    constructor Create; reintroduce;
  end;

  //----------------------- properties

  tLanguageProperty = class
  private
    fID: string;
    fIsDirty: boolean;
    fValue: string;
    fTextLocatorList: tTextLocatorList;
    procedure SetDirty(const Value: boolean);
    procedure SetValue(const pValue: string);
  public
    constructor Create( pID : string );
    destructor Destroy; override;
    property ID : string
             read fID;
    property Value : string
             read fValue
             write SetValue;
    property IsDirty : boolean
             read fIsDirty
             write SetDirty;
    property TextLocatorList : tTextLocatorList
             read fTextLocatorList;
  end;

  tLanguagePropertyList = class( tObjectList )
  private
    function GetItemWithName(const Index: string): tLanguageProperty;
    function GetItem(const index: integer): tLanguageProperty;
  public
    constructor Create; reintroduce;
    function Add( NewID : string ) : tLanguageProperty; reintroduce;
    property Item[ const index : integer ] : tLanguageProperty
             read GetItem;
    property ItemWithName[ const Index : string ] : tLanguageProperty
             read GetItemWithName;
  end;

  //-------------------- template

  tTemplateMode = (tmRTF, tmLibrary );

  tLanguageTemplateList = class;
  tLanguageTemplateFileList = class;

  tLanguageTemplate = class
  private
    fChildren: tLanguageTemplateList;
    fIsDirty: boolean;
    fSource: tStringList;
    fFileName: string;
    fParent: tLanguageTemplate;
    fActiveTemplate: tLanguageTemplate;
    fTemplateMode: tTemplateMode;
    class var fButtonGroup: tButtonGroup;
    function GetIsDirty: boolean;
    procedure SetIsDirty(const Value: boolean);
  public
    constructor Create( aOwner : tLanguageTemplateFileList; aParent : tLanguageTemplate ); reintroduce;
    destructor Destroy; override;
    property Children : tLanguageTemplateList
             read fChildren;
    property IsDirty : boolean
             read GetIsDirty
             write SetIsDirty;
    property Source : tStringList
             read fSource;
    procedure Load( pFileName : string );
    procedure Save( pFileName : string ); overload;
    procedure Save( pData : tStrings; var indent : integer ); overload;
    procedure Save; overload;
    property FileName : string
             read fFileName;
    property Parent : tLanguageTemplate
             read fParent;
    procedure ShowRTF( Window1, Window2 : tRichEdit;
              var CaratPosRow : integer; var CaratPosCol : integer;
              var SelStartRow : integer; var SelStartCol : integer;
              var SelEndRow : integer;   var SelEndCol   : integer );
    procedure ShowTemplate( Window1, Window2 : tRichEdit;
              var CaratPosRow : integer; var CaratPosCol : integer;
              var SelStartRow : integer; var SelStartCol : integer;
              var SelEndRow : integer;   var SelEndCol   : integer );
    procedure ShowSelfAsTemplate( Window1, Window2 : tRichEdit;
              var CaratPosRow : integer; var CaratPosCol : integer;
              var SelStartRow : integer; var SelStartCol : integer;
              var SelEndRow : integer;   var SelEndCol   : integer );
    property ActiveTemplate : tLanguageTemplate
             read fActiveTemplate;
    class  property ButtonGroup : tButtonGroup
             read fButtonGroup
             write fButtonGroup;
    property TemplateMode : tTemplateMode
             read fTemplateMode;
  end;

  tTopLevelTemplate = class( tLanguageTemplate )
  public
    constructor Create( aOwner : tLanguageTemplateFileList ); reintroduce;
  end;

  tBuiltInTemplate = class( tLanguageTemplate )
    // the built in template - the daddy of all others
  public
    constructor Create; reintroduce;
  end;

  tLanguageTemplateList = class( tObjectList )
  private
    fIsDirty : boolean;
    fNewText: string;
    fName: string;
    fOwner: tLanguageTemplateFileList;
    fIndentSpaces: integer;
    function GetItem(const index: integer): tLanguageTemplate;
    function GetIsDirty: boolean;
    procedure SetDirty(const Value: boolean);
    procedure SetIndentSpaces(const Value: integer);
    procedure SetName(const Value: string);
    procedure SetNewText(const Value: string);
  public
    constructor Create( aOwner : tLanguageTemplateFileList) ; reintroduce;
    destructor Destroy; override;
    function Load( pData : tStrings ) : boolean;
    procedure Save( pData : tStrings; var indent : integer );
    procedure Close;
    property IsDirty : boolean
             read GetIsDirty
             write SetDirty;
    property NewText : string
             read fNewText
             write SetNewText;
    property Name : string
             read fName
             write SetName;
    property Owner : tLanguageTemplateFileList
             read fOwner;
    property IndentSpaces : integer
             read fIndentSpaces
             write SetIndentSpaces;
    property Item[ const index : integer ] : tLanguageTemplate
             read GetItem;
  end;

  tLanguageTemplateFileList = class( tObjectList )
  private
    function GetItem(const index: integer): tLanguageTemplate;
  public
    constructor Create;
    procedure Add( NewVal : tLanguageTemplate ); reintroduce;
    procedure ShowFiles( pStrings : tStrings );
    property Item[ const index : integer ] : tLanguageTemplate
             read GetItem;
    function SaveFilesIfDirty : boolean; // returns FALSE if user pressed 'Cancel'
  end;

implementation

var
  BuiltInTemplate : tBuiltInTemplate;

{ tLanguageTemplateList }

procedure tLanguageTemplateList.Close;
begin
  fOwner.Remove( self );
end;

constructor tLanguageTemplateList.Create( aOwner : tLanguageTemplateFileList);
begin
  inherited Create;
  fNewText := 'New Template Entry';
  fOwner := aOwner;
end;

destructor tLanguageTemplateList.Destroy;
begin
  inherited;
end;

function tLanguageTemplateList.GetIsDirty: boolean;
var
  i: Integer;
begin
  Result := fIsDirty;
  if not Result then
  begin
    for i := 0 to Count - 1 do
    begin
      Result := Item[ i ].IsDirty;
      if Result then
      begin
        exit;
      end;
    end;
  end;
end;

function tLanguageTemplateList.GetItem(const index: integer): tLanguageTemplate;
begin
  Result := Items[ index ] as tLanguageTemplate;
end;

function tLanguageTemplateList.Load(pData: tStrings): boolean;
begin
  Result := TRUE;
  fIsDirty := FALSE;
end;

procedure tLanguageTemplateList.Save(pData: tStrings; var indent : integer );
begin
  // sets up parameters too
  pData.Add( IndentedString( 'Template List = ' + Name, indent) );
  inc( indent, self.IndentSpaces );
  dec( indent, self.IndentSpaces );
  pData.Add( IndentedString( 'End Template List = ' + Name, indent) );
end;

procedure tLanguageTemplateList.SetDirty(const Value: boolean);
var
  i: Integer;
begin
  fIsDirty := Value;
  for i := 0 to Count - 1 do
  begin
    Item[ i ].IsDirty := Value;
  end;
end;

procedure tLanguageTemplateList.SetIndentSpaces(const Value: integer);
begin
  if fIndentSpaces <> Value then
  begin
    fIndentSpaces := Value;
    fIsDirty := TRUE;
  end;
end;

procedure tLanguageTemplateList.SetName(const Value: string);
begin
  if fName <> Value then
  begin
    fName := Value;
    fIsDirty := TRUE;
  end;
end;

procedure tLanguageTemplateList.SetNewText(const Value: string);
begin
  if fNewText <> Value then
  begin
    fNewText := Value;
    fIsDirty := TRUE;
  end;
end;

{ tLanguagePropertyList }

function tLanguagePropertyList.Add(NewID: string): tLanguageProperty;
var
  i: Integer;
begin
  // make sure not already in list
  for i := 0 to Count - 1 do
  begin
    if SameText( Item[ i ].ID, NewId) then
    begin
      Result := Item[ i ];
      exit;
    end;
  end;
  // does not exist so add
  Result := tLanguageProperty.Create( NewID );
  inherited Add( Result );
end;

constructor tLanguagePropertyList.Create;
begin
  inherited Create( TRUE );
end;

function tLanguagePropertyList.GetItem(const index: integer): tLanguageProperty;
begin
  Result := Items[ index ] as tLanguageProperty;
end;

function tLanguagePropertyList.GetItemWithName(
  const Index: string): tLanguageProperty;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if SameText(Item[ i ].ID, index) then
    begin
      Result := Item[ i ];
      exit;
    end;
  end;
  // else
  Result := nil;
end;

{ tLanguageTemplateFileList }

procedure tLanguageTemplateFileList.Add(NewVal: tLanguageTemplate );
begin
  inherited Add( NewVal );
end;

constructor tLanguageTemplateFileList.Create;
begin
  inherited Create( TRUE );
end;

function tLanguageTemplateFileList.GetItem(
  const index: integer): tLanguageTemplate;
begin
  Result := Items[ index ] as tLanguageTemplate;
end;

function tLanguageTemplateFileList.SaveFilesIfDirty: boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Count - 1 do
  begin
    if (Item[ i ].FileName <> '') and Item[ i ].IsDirty then
    begin
      case MessageDlg( Item[ i ].FileName + ' not saved. Save now?', mtWarning, [mbYes, mbNo, mbCancel ], 0 ) of
        mrYes:
        begin
          Item[ i ].Save;
        end;
        mrCancel:
        begin
          Result := FALSE;
          exit;
        end;
      end;
    end;
  end;
end;

procedure tLanguageTemplateFileList.ShowFiles(pStrings: tStrings);
var
  i: Integer;
begin
  pStrings.Clear;
  for i := 0 to Count - 1 do
  begin
    if Item[ i ].FileName <> '' then
    begin
      pStrings.Add( ExtractFileName( Item[ i ].FileName ));
    end;
  end;
end;

{ tLanguageProperty }

constructor tLanguageProperty.Create(pID: string);
begin
  inherited Create;
  fID := pID;
  fValue := pID;
  fTextLocatorList := tTextLocatorList.Create;
end;

destructor tLanguageProperty.Destroy;
begin
  fTextLocatorList.Free;
  inherited;
end;

procedure tLanguageProperty.SetDirty(const Value: boolean);
begin
  fIsDirty := Value;
end;

procedure tLanguageProperty.SetValue(const pValue: string);
begin
  if fValue <> pValue then
  begin
    fValue := pValue;
    fIsDirty := TRUE;
  end;
end;

{ tTextLocatorList }

constructor tTextLocatorList.Create;
begin
  inherited Create( TRUE );
end;

{ tLanguageTemplate }

constructor tLanguageTemplate.Create( aOwner : tLanguageTemplateFileList; aParent : tLanguageTemplate);
begin
  inherited Create;
  fChildren := tLanguageTemplateList.Create( aOwner );
  fSource := tStringList.Create;
  fParent := aParent;
  if assigned( aOwner ) then
  begin
    aOwner.Add( self );
  end;
end;

destructor tLanguageTemplate.Destroy;
begin
  fSource.Free;
  fChildren.Free;
  inherited;
end;

function tLanguageTemplate.GetIsDirty: boolean;
begin
  Result := fIsDirty;
  if not Result then
  begin
    Result := Children.IsDirty;
  end;
end;

procedure tLanguageTemplate.Load(pFileName: string);
begin
  fFileName := pFileName;
  try
    fSource.LoadFromFile( pFileName + '.tpl' );
  except

  end;
  IsDirty := FALSE;
end;

procedure tLanguageTemplate.Save(pFileName: string);
var
  iText : tStringList;
  indent : integer;
begin
  // save template and generated file together
  fSource.SaveToFile( pFileName + '.tpl' );
  iText := tStringList.Create;
  indent := 0;
  Save( iText, indent );
  iText.Free;
end;

procedure tLanguageTemplate.Save(pData: tStrings; var indent: integer);
begin
  // actually just generates the source from the template as text. All special
  // tokens removed.
  // to do
end;

procedure tLanguageTemplate.Save;
begin
  Save( fFileName );
end;

procedure tLanguageTemplate.SetIsDirty(const Value: boolean);
begin
  fIsDirty := Value;
  Children.IsDirty := Value;
end;


procedure tLanguageTemplate.ShowSelfAsTemplate(Window1, Window2: tRichEdit;
  var CaratPosRow, CaratPosCol, SelStartRow, SelStartCol, SelEndRow,
  SelEndCol: integer);
begin
  // this shows the current file as plain text in window 2
  // and highlighted text in window 1.
  fTemplateMode := tmLibrary;

  Window1.Lines.Clear;
  Window2.Lines.Clear;
  fButtonGroup.Items.Clear;
  // to do
end;

procedure tLanguageTemplate.ShowRTF( Window1, Window2 : tRichEdit;
          var CaratPosRow : integer; var CaratPosCol : integer;
          var SelStartRow : integer; var SelStartCol : integer;
          var SelEndRow : integer;   var SelEndCol   : integer );
begin
  // this shows the file as object with buttons of current selected template
  fTemplateMode := tmRTF;

  Window1.Lines.Clear;
  Window2.Lines.Clear;
  fButtonGroup.Items.Clear;
  // to do
end;

procedure tLanguageTemplate.ShowTemplate(Window1, Window2: tRichEdit;
  var CaratPosRow, CaratPosCol, SelStartRow, SelStartCol, SelEndRow,
  SelEndCol: integer);
begin
  if assigned( fActiveTemplate ) then
  begin
    fActiveTemplate.ShowSelfAsTemplate( Window1, Window2, CaratPosRow, CaratPosCol,
                                           SelStartRow, SelStartCol, SelEndRow, SelEndCol );
  end
  else
  begin
    raise exception.Create( 'No template active' );
  end;
end;

{ tBuiltInTemplate }

constructor tBuiltInTemplate.Create;
begin
  inherited Create( nil, nil );
end;

{ tTopLevelTemplate }

constructor tTopLevelTemplate.Create(aOwner: tLanguageTemplateFileList);
begin
  inherited Create( aOwner, BuiltInTemplate );
end;

initialization

  BuiltInTemplate := tBuiltInTemplate.Create;

finalization

  BuiltInTemplate.Free;

end.

