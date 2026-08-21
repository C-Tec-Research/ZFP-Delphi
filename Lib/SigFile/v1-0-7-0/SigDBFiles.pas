unit SigDBFiles;

{
  Database definitions are stored in a normal SigFile structure.
  Database Tables and Index Tables are stored in a linear files that
  share a common base structure.

  To minimise data writing deleted records are simply flagged and reused,
  so unless a PACK is issued, file sizes never shrink. PACK will not
  be in the first implementation since it implies re-indexing.

  Each file comprises two multiply linked lists, one of deleted records which
  starts at record zero and one of live records which starts at record 1.
  These two records are the most dynamic, being maintained at the centre of
  the binary tree. In the case of a data record which is always added at the
  logical end of the file, every second addition causes record 1 to swap
  places with its 'next' record and the tree structure is modified accoringly.

  For indexes we use a modification of the AVL algorithm.

}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Contnrs,
  VCL.Buttons,
  VCL.ComCtrls,
  VCL.StdCtrls,
  SigFile,
  SigGeneralGrid,
  ErrorList,
  SigBTree,
  UnitNew,
  UnitChangeTableName,
  UnitFormatSigDBWarning;

type
  tSigDBException = class( Exception );

  tSigDBTableRecData = class

  end;

  tSigDBTableRec = class;

  tCompareTableRecs = function ( const pRec1, pRec2 : tSigDBTableRec ) : boolean;

  tSigDBTableRec = class
  private
    fCurrIndex: int64;
    fData: tSigDBTableRecData;
  protected
  public
    property CurrIndex : int64
             read fCurrIndex;
    property Data : tSigDBTableRecData
             read fData;

  end;

  tSigDBTable = class( tObjectList ) // indexed flat file - only keeps records read in memory
  private
    fTableName: string;
    fLessThan: tCompareTableRecs;
  protected
    fIndex : tSigBTreeNodeMemory;
  public
    property TableName : string
             read fTableName;

    property LessThan : tCompareTableRecs
             read fLessThan
             write fLessThan;

    function IsLessThan( const RecA, RecB : int64 ) : boolean;
  end;

  tSigDBIndex = class( tSigBTreeNodeMemory ) // binary tree stored in a file
  {
    The file is not stored in memory in its entirity, but the accessed record are
    We do not need to store parent indexes in the file, since by definition, to access
    a record we must have accessed its parents, which we do store.
    Unaccessed children are indicated by nil pointers and non-zero indices
  }
  private
    fLeftChildIndex: int64;
    fRightChildIndex: int64;
    fCurrIndex: int64;
  protected
  public
    property RightChildIndex : int64
             read fRightChildIndex;
    property LeftChildIndex : int64
             read fLeftChildIndex;
    property CurrIndex : int64
             read fCurrIndex;
  end;

  tSigDBIndexRoot = class( tSigDBTreeRoot ) // corresponds to record zero, which we always load
  private
    fLeftChildIndex: int64;
    fRightChildIndex: int64;
    fSigDBTable: tSigDBTable;
    fIndexName: string;
  protected
  public
    property FirstDeletedIndex : int64
             read fRightChildIndex;
    property LeftChildIndex : int64
             read fLeftChildIndex;
    property SigDBTable : tSigDBTable
             read fSigDBTable;
    property IndexName : string
             read fIndexName;

  end;

  tSigDBFieldType = ( ft_String, ft_Integer, ft_Date_Time, ft_Field_Pointer,
                      ft_Index_Ascending, ft_Index_Descending,
                      ft_Filter_LT, ft_Filter_LE,ft_Filter_EQ, ft_Filter_NE,
                      ft_Filter_GE, ft_Filter_GT );

  tSigDBFieldTypeType = class( tSigEnum<tSigDBFieldType> )
  private
    fCalculating : boolean;
  protected
    procedure SetValue(const pValue: string); override;
    function ValueToText( pValue : integer ) : string; override;
    class function ClassValueToText( pValue : integer ) : string;
  public
    class procedure SetupTableOptions( const pItems : tStrings );
    class procedure SetupIndexOptions( const pItems : tStrings );
  end;

  tSigDBFile = class;
  tSigDBField = class;

  tSigFieldPointer = class( tSigAdaptablePointer )
  private
    function GetField: tSigDBField;
    procedure SetField(const Value: tSigDBField);
  protected
  public
    property Field : tSigDBField
             read GetField
             write SetField;
  end;

  tSigDBField = class( tSigCompoundProperty )
  private
    fFieldType: tSigDBFieldTypeType;
    fDataField: tSigFieldPointer;
    function GetFieldType: tSigDBFieldType;
    procedure SetFieldType(const Value: tSigDBFieldType);
    function GetDBFile: tSigDBFile;
    function GetFieldTypeAsString: string;
    procedure SetFieldTypeAsString(const Value: string);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    // General
    property DBFile : tSigDBFile
             read GetDBFile;

    // Base properties
    property FieldType : tSigDBFieldType
             read GetFieldType
             write SetFieldType;
    property FieldTypeAsString : string
             read GetFieldTypeAsString
             write SetFieldTypeAsString;

    // for field pointers, including index fields
    property DataField : tSigFieldPointer
             read fDataField;


  end;

  tSigDBDataField = class( tSigDBField )
  private
    fName: tSigTextProperty;
    fFieldLen: tSigIntegerProperty;
    fIndexTable: tSigPointer;
    function GetFieldLen: integer;
    procedure SetFieldLen(const Value: integer);
    function GetIndexTable: string;
    procedure SetIndexTable(const Value: string);
    function GetIndexField: string;
    procedure SetIndexField(const Value: string);
    function GetName: string;
    procedure SetName(const Value: string);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    // for data fields
    property Name : string
             read GetName
             write SetName;

    property FieldLen : integer
             read GetFieldLen   // for strings, mainly. For other objects is fixed
             write SetFieldLen;

    property IndexTable : string
             read GetIndexTable
             write SetIndexTable;
    property IndexField : string  // this is the field in the data
             read GetIndexField
             write SetIndexField;

    procedure CheckIndexField( const pRow : integer ); // checks that the index field in this row of current grid
  end;

  tSigDBIndexFieldList = class;

  tSigDBIndexField = class( tSigDBField )
  private
    fFilter: tSigTextProperty;
    function GetFilter: string;
    procedure SetFilter(const Value: string);
    function GetDataField: string;
    procedure SetDataField(const Value: string);
    function GetOwnerAsSigDBIndexFieldList: tSigDBIndexFieldList;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure Clear; override;

    // for Filters
    property DataField : string
             read GetDataField
             write SetDataField;
    property Filter : string
             read GetFilter
             write SetFilter;

    property OwnerAsSigDBIndexFieldList : tSigDBIndexFieldList
             read GetOwnerAsSigDBIndexFieldList;
  end;

  tSigDBFieldList = class( tSigObjectList )
  private
    function GetField(const i: integer): tSigDBField;
    function GetDBFile: tSigDBFile;
  protected
    //procedure BuildFieldList( const pList : tStrings );
  public
    property Field[ const i : integer ] : tSigDBField
             read GetField;
    //function FieldWithName( const pName : string ) : tSigDBField;

    // General
    property DBFile : tSigDBFile
             read GetDBFile;
  end;

  tSigDBDataFieldList = class( tSigDBFieldList )
  private
    function GetDataField(const i: integer): tSigDBDataField;
  protected
    procedure BuildFieldList( const pList : tStrings );
    procedure OnFieldsCellEditChange( const Sender: TObject; const Col, Row: Integer; const pValue: string);
    procedure SetRecEditor(const Value: tSigGeneralGrid); override;
    procedure BuildRecCell( const pCol, pRow : integer; const pRec : tSigBaseProperty ); override; // pRec guaranteed to exist
    //procedure RebuildRecEditor; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property DataField[ const i : integer ] : tSigDBDataField
             read GetDataField;

    function FieldWithName( const pName : string ) : tSigDBDataField;
    procedure BuildDesktopFieldsGridTitles( const pGrid : tSigGeneralGrid );

    const
      cSel        = 0;
      cName       = 1;
      cFieldType  = 2;
      cIndexTable = 3;
      cIndexField = 4;
      cLen        = 5;
  end;

  tSigDBDataFile = class;
  tSigDBIndexFile = class;

  tSigDBDataFilePointer = class( tSigPointer )
  private
    function GetDataFile: tSigDBDataFile;
    procedure SetDataFile(const Value: tSigDBDataFile);
  public
    property DataFile : tSigDBDataFile
             read GetDataFile
             write SetDataFile;
  end;

  tSigDBIndexFieldList = class( tSigDBFieldList )
  private
    fDataFile: tSigDBDataFilePointer;
    fComboBoxIndexFileBasedOn: tComboBox;
    function GetIndexField(const i: integer): tSigDBIndexField;
    function GetDataFile: tSigDBDataFile;
    procedure SetDataFile(const Value: tSigDBDataFile);
    function GetOwnerAsSigDBIndexFile: tSigDBIndexFile;
    procedure SetComboBoxIndexFileBasedOn(const Value: tComboBox);
    procedure SetComboBoxIndexFileBasedOnItemIndex;
    procedure OnComboBoxIndexFileBasedOnChange( Sender : tObject );
    procedure BuildFieldsDropdown;
  protected
    procedure OnFieldsCellEditChange( const Sender: TObject; const Col, Row: Integer; const pValue: string);
    procedure SetRecEditor(const Value: tSigGeneralGrid); override;
    procedure BuildRecCell( const pCol, pRow : integer; const pRec : tSigBaseProperty ); override; // pRec guaranteed to exist
    //procedure RebuildRecEditor; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure AfterLoad; override;

    property DataFile : tSigDBDataFile
             read GetDataFile
             write SetDataFile;

    property IndexField[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    function IndexFieldWithName( const pName : string ) : tSigDBDataField;

    property OwnerAsSigDBIndexFile : tSigDBIndexFile
             read GetOwnerAsSigDBIndexFile;
    // editors

    property ComboBoxIndexFileBasedOn : tComboBox
             read fComboBoxIndexFileBasedOn
             write SetComboBoxIndexFileBasedOn;

    const
      cColSel = 0;
      cColDataField = 1;
      cColDataType = 2;
      cColCompareField = 3;
  end;

  tSigDBFileBase = class( tSigCompoundProperty )
  private
    fName: tSigRelativeFileProperty;
    fFile : File;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetSigDBFile: tSigDBFile;
  protected
    fOpen : boolean;
    procedure OnNameChange( const pChangedObject : tSigBaseProperty );
    function FieldCount : integer; virtual; abstract;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    destructor Destroy; override;

    property Name : string
             read GetName
             write SetName;

    property SigDBFile : tSigDBFile
             read GetSigDBFile;

    // Editors
  end;

  tSigDBFileBaselist = class( tSigObjectArray )
  private
    fTabControlFiles: tTabControl;
    fSpeedButtonChangeName: tSpeedButton;
    function GetFileBase( const i : integer ): tSigDBFileBase;
    procedure SetTabControlFiles(const Value: tTabControl);
    procedure SetSpeedButtonChangeName(const Value: tSpeedButton);
    function GetDBFile: tSigDBFile;
  protected
    procedure SetupTabs;
    procedure SetMax(const Value: integer); override;
    procedure OnTabChange( Sender : tObject );
    procedure OnSpeedButtonChangeNameClick( Sender : tObject ); virtual;
    procedure SetActiveChild(const pValue: integer); override;
  public
    function FileExists( const pTableName : string ): boolean;

    procedure BuildFileList( const pStrings : tStrings );

    property FileBase[ const i : integer ] : tSigDBFileBase
             read GetFileBase;
    function FileBaseWithName( const pName : string ) :  tSigDBFileBase;

    // General
    property DBFile : tSigDBFile
             read GetDBFile;

    // Editors
    property TabControlFiles : tTabControl
             read fTabControlFiles
             write SetTabControlFiles;
    property SpeedButtonChangeName : tSpeedButton
             read fSpeedButtonChangeName
             write SetSpeedButtonChangeName;
  end;

  tSigDBDataFile = class( tSigDBFileBase )
  private
    fFields: tSigDBDataFieldList;
    fTableGridFields: tSigGeneralGrid;
    fBuffer : tMemoryStream;
    fRecFirst, fRecLast, fDelFirst, fDelLast : int64;
    function GetField(const i: integer): tSigDBDataField;
    procedure SetTableGridFields(const Value: tSigGeneralGrid);
  protected
    function FieldCount : integer; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    function Open : boolean;
    procedure Close;

    procedure BuildDesktopFieldsGridTitles( const pGrid : tSigGeneralGrid );

    function RecLen : int64;

    property Fields : tSigDBDataFieldList
             read fFields;
    property Field[ const i : integer ] : tSigDBDataField
             read GetField;

    // Editors
    property TableGridFields : tSigGeneralGrid
             read fTableGridFields
             write SetTableGridFields;
  end;

  tSigDBDataFileList = class( tSigDBFileBaselist )
  private
    fTableGridFields: tSigGeneralGrid;
    fTabControlEditDB: tTabControl;
    function GetDataFile(const i: integer): tSigDBDataFile;
    procedure SetTableGridFields(const Value: tSigGeneralGrid);
    procedure SetTabControlEditDB(const Value: tTabControl);
  protected
    procedure SetActiveChild(const pValue: integer); override;
    procedure OnEditDBTabsChange( Sender : tObject );
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure AddDataFile( const pNewFileName : string );

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure AfterLoad; override;

    function Open : boolean;
    procedure Close;

    procedure BuildEditDBTabs;
    procedure BuildDesktopFieldsGridTitles( const pGrid : tSigGeneralGrid );

    property DataFile[ const i : integer ] : tSigDBDataFile
             read GetDataFile;
    // Editors
    property TableGridFields : tSigGeneralGrid
             read fTableGridFields
             write SetTableGridFields;
    property TabControlEditDB : tTabControl
             read fTabControlEditDB
             write SetTabControlEditDB;
  end;

  tSigDBIndexRec = packed record
      Parent     : int64;
      LeftChild  : int64;
      RightChild : int64;
  end;

  tSigDBIndexRec0 = packed record
      NotUsed    : int64;
      Root       : int64;
      Deleted    : int64;
  end;

  tSigDBIndexFile = class( tSigDBFileBase )
  private
    fFields: tSigDBIndexFieldList;
    fComboBoxIndexFileBasedOn: tComboBox;
    fTableGridFields: tSigGeneralGrid;
    fRec0 : tSigDBIndexRec0;
    fRec  : tSigDBIndexRec;
    function GetIndexField(const i: integer): tSigDBIndexField;
    procedure SetComboBoxIndexFileBasedOn(const Value: tComboBox);
    procedure SetTableGridFields(const Value: tSigGeneralGrid);
  protected
    function FieldCount : integer; override;
    procedure CheckDataField( const pRow : integer ); // checks that the index field in this row of current grid
    function FilterValid( const pIndex : integer; const pValue : string ) : boolean;
    function IsValidList( const pValue : string ) : boolean;
    function IsSingleValue( const pValue : string ) : boolean; // depends on destination field type
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    function Open : boolean;
    procedure Close;

    property Fields : tSigDBIndexFieldList
             read fFields;
    property Field[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    // editors
    property ComboBoxIndexFileBasedOn : tComboBox
             read fComboBoxIndexFileBasedOn
             write SetComboBoxIndexFileBasedOn;
    property TableGridFields : tSigGeneralGrid
             read fTableGridFields
             write SetTableGridFields;
  end;

  tSigDBIndexFileList = class( tSigDBFileBaselist )
  private
    fComboBoxIndexFileBasedOn: tComboBox;
    fTableGridFields: tSigGeneralGrid;
    procedure SetComboBoxIndexFileBasedOn(const Value: tComboBox);
    function GetIndexFile(const i: integer): tSigDBIndexFile;
    procedure SetTableGridFields(const Value: tSigGeneralGrid);
  protected
    procedure SetActiveChild(const pValue: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure AddIndexFile( const pNewFileName : string );
    property  IndexFile[ const i : integer ] : tSigDBIndexFile
              read GetIndexFile;

    function Open : boolean;
    procedure Close;

    // Editors
    property ComboBoxIndexFileBasedOn : tComboBox
             read fComboBoxIndexFileBasedOn
             write SetComboBoxIndexFileBasedOn;
    property TableGridFields : tSigGeneralGrid
             read fTableGridFields
             write SetTableGridFields;
  end;

  tSigDBDatabase= class( tSigCompoundProperty )
  private
    fDataFiles: tSigDBDataFileList;
    fIndexFiles: tSigDBIndexFileList;
    fTabControlDataFiles: tTabControl;
    fDataGridFields: tSigGeneralGrid;
    fIndexGridFields: tSigGeneralGrid;
    fTabControlIndexFiles: tTabControl;
    fPageControlDatabase: tPageControl;
    fSpeedButtonChangeIndexName: tSpeedButton;
    fComboBoxIndexFileBasedOn: tComboBox;
    fTabControlEditDB: tTabControl;
    fSigGeneralGridDesktopFields: tSigGeneralGrid;
    procedure OnPageControlDatabaseChange( Sender : tObject );
    procedure SetTabControlDataFiles(const Value: tTabControl);
    procedure SetDataGridFields(const Value: tSigGeneralGrid);
    function GetIndexFile(const pName: string): tSigDBIndexFile;
    function GetDataFile(const pName: string): tSigDBIndexFile;
    procedure SetIndexGridFields(const Value: tSigGeneralGrid);
    procedure SetTabControlIndexFiles(const Value: tTabControl);
    procedure SetPageControlDatabase(const Value: tPageControl);
    procedure SetSpeedButtonChangeIndexName(const Value: tSpeedButton);
    procedure SetComboBoxIndexFileBasedOn(const Value: tComboBox);
    procedure SetTabControlEditDB(const Value: tTabControl);
    procedure SetSigGeneralGridDesktopFields(const Value: tSigGeneralGrid);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure AfterLoad; override;

    procedure Format;
    function Open : boolean;
    procedure Close;

    property DataFiles : tSigDBDataFileList
             read fDataFiles;
    property IndexFiles : tSigDBIndexFileList
             read fIndexFiles;
    procedure AddNewDataFile( const pName : string );
    procedure AddNewIndexFile( const pName : string );

    property IndexFile[ const pName : string ] : tSigDBIndexFile
             read GetIndexFile;
    property DataFile[ const pName : string ] : tSigDBIndexFile
             read GetDataFile;

    // Build dropdowns etc.
    procedure BuildIndexFileDropDown;
    procedure BuildTableFileDropDown;

    procedure BuildDesktopFieldsGrid;
    procedure BuildDesktopFieldsGridTitles;
    procedure BuildDesktopFieldsGridFields;

    // Editors
    property TabControlDataFiles : tTabControl
             read fTabControlDataFiles
             write SetTabControlDataFiles;
    property TabControlIndexFiles : tTabControl
             read fTabControlIndexFiles
             write SetTabControlIndexFiles;
    property DataGridFields : tSigGeneralGrid
             read fDataGridFields
             write SetDataGridFields;
    property IndexGridFields : tSigGeneralGrid
             read fIndexGridFields
             write SetIndexGridFields;
    property PageControlDatabase : tPageControl
             read fPageControlDatabase
             write SetPageControlDatabase;
    property SigGeneralGridDesktopFields : tSigGeneralGrid
             read fSigGeneralGridDesktopFields
             write SetSigGeneralGridDesktopFields;

    property SpeedButtonChangeIndexName : tSpeedButton
             read fSpeedButtonChangeIndexName
             write SetSpeedButtonChangeIndexName;
    property ComboBoxIndexFileBasedOn : tComboBox
             read fComboBoxIndexFileBasedOn
             write SetComboBoxIndexFileBasedOn;
    property TabControlEditDB : tTabControl
             read fTabControlEditDB
             write SetTabControlEditDB;
  end;

  tSigDBFile = class( tSigFileProperty )
  private
    fDatabase: tSigDBDatabase;
    fNewDataTableButton: tSpeedButton;
    fErrorList: tErrorList;
    fTabControlDataFiles: tTabControl;
    fDataGridFields: tSigGeneralGrid;
    fTabControlIndexFiles: tTabControl;
    fNewIndexTableButton: tSpeedButton;
    fIndexGridFields: tSigGeneralGrid;
    fPageControlDatabase: tPageControl;
    fSpeedButtonChangeIndexName: tSpeedButton;
    fComboBoxIndexFileBasedOn: tComboBox;
    fTabControlEditDB: tTabControl;
    fSigGeneralGridDesktopFields: tSigGeneralGrid;

    // editor functions
    procedure OnNewDataTableButtonClick( Sender : tObject );
    procedure OnNewIndexTableButtonClick( Sender : tObject );

    // Setters and Getters
    procedure SetNewDataTableButton(const Value: tSpeedButton);
    function GetErrorList: tErrorList;
    procedure SetTabControlDataFiles(const Value: tTabControl);
    procedure SetDataGridFields(const Value: tSigGeneralGrid);
    procedure SetIndexGridFields(const Value: tSigGeneralGrid);
    procedure SetNewIndexTableButton(const Value: tSpeedButton);
    procedure SetTabControlIndexFiles(const Value: tTabControl);
    procedure SetPageControlDatabase(const Value: tPageControl);
    procedure SetSpeedButtonChangeIndexName(const Value: tSpeedButton);
    procedure SetComboBoxIndexFileBasedOn(const Value: tComboBox);
    procedure SetTabControlEditDB(const Value: tTabControl);
    procedure SetSigGeneralGridDesktopFields(const Value: tSigGeneralGrid);

  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure Clear; override;
    destructor Destroy; override;

    function Save( pShortFormat : boolean = FALSE) : boolean; override;
    function SaveAs( const pFileName : string = ''; pShortFormat : boolean = FALSE) : boolean; override;

    property Database : tSigDBDatabase
             read fDatabase;

    property ErrorList : tErrorList
             read GetErrorList;

    procedure Format;

    // Editors

    property NewDataTableButton : tSpeedButton
             read fNewDataTableButton
             write SetNewDataTableButton;
    property TabControlDataFiles : tTabControl
             read fTabControlDataFiles
             write SetTabControlDataFiles;
    property DataGridFields : tSigGeneralGrid
             read fDataGridFields
             write SetDataGridFields;
    property TabControlEditDB : tTabControl
             read fTabControlEditDB
             write SetTabControlEditDB;
    property SigGeneralGridDesktopFields : tSigGeneralGrid
             read fSigGeneralGridDesktopFields
             write SetSigGeneralGridDesktopFields;

    property NewIndexTableButton : tSpeedButton
             read fNewIndexTableButton
             write SetNewIndexTableButton;
    property TabControlIndexFiles : tTabControl
             read fTabControlIndexFiles
             write SetTabControlIndexFiles;
    property IndexGridFields : tSigGeneralGrid
             read fIndexGridFields
             write SetIndexGridFields;
    property SpeedButtonChangeIndexName : tSpeedButton
             read fSpeedButtonChangeIndexName
             write SetSpeedButtonChangeIndexName;
    property ComboBoxIndexFileBasedOn : tComboBox
             read fComboBoxIndexFileBasedOn
             write SetComboBoxIndexFileBasedOn;

    property PageControlDatabase : tPageControl
             read fPageControlDatabase
             write SetPageControlDatabase;

  end;

implementation

{ tMyFile }

procedure tSigDBFile.Clear;
begin
  inherited;

end;

constructor tSigDBFile.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited;

  fDatabase := tSigDBDatabase.Create( 'Database', self );
end;

destructor tSigDBFile.Destroy;
begin
  fErrorList.Free;

  inherited;
end;

procedure tSigDBFile.Format;
begin
  fDatabase.Format;
end;

function tSigDBFile.GetErrorList: tErrorList;
begin
  if not assigned( fErrorList ) then
  begin
    fErrorList := tErrorList.Create;
  end;
  Result := fErrorList;
end;

procedure tSigDBFile.OnNewDataTableButtonClick(Sender: tObject);
begin
  // Attempts to add a new table to the database. File should not exist, ideally. Warn if it does

  with FormNewFile do
  begin
    TableName := '';
    if Execute then
    begin
      fDatabase.AddNewDataFile(TableName );
    end;
  end;
end;

procedure tSigDBFile.OnNewIndexTableButtonClick(Sender: tObject);
begin
  // Attempts to add a new index to the database. File should not exist, ideally. Warn if it does

  with FormNewFile do
  begin
    TableName := '';
    if Execute then
    begin
      fDatabase.AddNewIndexFile(TableName );
    end;
  end;
end;

function tSigDBFile.Save(pShortFormat: boolean): boolean;
begin
  Result := inherited;
end;

function tSigDBFile.SaveAs(const pFileName: string;
  pShortFormat: boolean): boolean;
begin
  Result := inherited;
end;

procedure tSigDBFile.SetComboBoxIndexFileBasedOn(const Value: tComboBox);
begin
  fComboBoxIndexFileBasedOn := Value;
  Database.ComboBoxIndexFileBasedOn := ComboBoxIndexFileBasedOn;
end;

procedure tSigDBFile.SetIndexGridFields(const Value: tSigGeneralGrid);
begin
  if fIndexGridFields <> Value then
  begin
    fIndexGridFields := Value;
    Database.IndexGridFields := Value;
  end;
end;

procedure tSigDBFile.SetNewDataTableButton(const Value: tSpeedButton);
begin
  if fNewDataTableButton <> Value then
  begin
    if assigned( fNewDataTableButton ) then
    begin
      fNewDataTableButton.OnClick := nil;
    end;
    fNewDataTableButton := Value;
    if assigned( fNewDataTableButton ) then
    begin
      fNewDataTableButton.OnClick := OnNewDataTableButtonClick;
    end;
  end;
end;

procedure tSigDBFile.SetNewIndexTableButton(const Value: tSpeedButton);
begin
  if fNewIndexTableButton <> Value then
  begin
    if assigned( fNewIndexTableButton ) then
    begin
      fNewIndexTableButton.OnClick := nil;
    end;
    fNewIndexTableButton := Value;
    if assigned( fNewIndexTableButton ) then
    begin
      fNewIndexTableButton.OnClick := OnNewIndexTableButtonClick;
    end;
  end;
end;

procedure tSigDBFile.SetPageControlDatabase(const Value: tPageControl);
begin
  fPageControlDatabase := Value;
  Database.PageControlDatabase := Value;
end;

procedure tSigDBFile.SetSigGeneralGridDesktopFields(
  const Value: tSigGeneralGrid);
begin
  fSigGeneralGridDesktopFields := Value;
  Database.SigGeneralGridDesktopFields := Value;
end;

procedure tSigDBFile.SetSpeedButtonChangeIndexName(const Value: tSpeedButton);
begin
  fSpeedButtonChangeIndexName := Value;
  Database.SpeedButtonChangeIndexName := Value;
end;

procedure tSigDBFile.SetTabControlDataFiles(const Value: tTabControl);
begin
  if fTabControlDataFiles <> Value then
  begin
    fTabControlDataFiles := Value;
    Database.TabControlDataFiles := Value;
  end;
end;

procedure tSigDBFile.SetTabControlEditDB(const Value: tTabControl);
begin
  fTabControlEditDB := Value;
  fDatabase.TabControlDataFiles := Value;
end;

procedure tSigDBFile.SetTabControlIndexFiles(const Value: tTabControl);
begin
  if fTabControlIndexFiles <> Value then
  begin
    fTabControlIndexFiles := Value;
    Database.TabControlIndexFiles := Value;
  end;
end;

procedure tSigDBFile.SetDataGridFields(const Value: tSigGeneralGrid);
begin
  if fDataGridFields <> Value then
  begin
    fDataGridFields := Value;
    Database.DataGridFields := Value;
  end;
end;

{ tSigDBDataFile }

procedure tSigDBDataFile.BuildDesktopFieldsGridTitles(
  const pGrid: tSigGeneralGrid);
begin
  fFields.BuildDesktopFieldsGridTitles( pGrid );
end;

procedure tSigDBDataFile.Close;
begin
  CloseFile( fFile );
end;

constructor tSigDBDataFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin

  inherited;

  fFields    := tSigDBDataFieldList.Create( 'Fields', self );

end;

function tSigDBDataFile.FieldCount: integer;
begin
  Result := fFields.Max + 1;
end;

function tSigDBDataFile.GetField(const i: integer): tSigDBDataField;
begin
  Result := fFields.DataField[ i ];
end;

function tSigDBDataFile.Open: boolean;
var
  iPathName : string;
  iFile : string;
  iRecLen : int64;
  iResult : integer;
  iRec : array of byte;
begin
  if OwnerFile.SaveIfDirty  then
  begin
    iPathName := ExtractFilePath( OwnerFile.FileName );
    iFile := iPathName + Name;
    try
      iRecLen := RecLen;
      AssignFile( fFile, iFile  );
      if not assigned( fBuffer ) then
      begin
        fBuffer := tMemoryStream.Create;
      end
      else
      begin
        fBuffer.Clear;
      end;
      fBuffer.SetSize( iRecLen );
      if FileExists( iFile ) then
      begin
        Reset( fFile, iRecLen );
        BlockRead( fFile, iRec, 1, iResult );
        if iResult < 1 then
        begin
          // empty file. Should not happen, but
          Seek( fFile, 0 );
          fBuffer.Position := 0;
          fRecFirst:= 0;
          fRecLast := 0;
          fDelFirst:= 0;
          fDelLast := 0;
          fBuffer.Write( fRecFirst, sizeof( fRecFirst ) );
          fBuffer.Write( fRecLast, sizeof( fRecLast ) );
          fBuffer.Write( fDelFirst, sizeof( fDelFirst ) );
          fBuffer.Write( fDelLast, sizeof( fDelLast ) );
          BlockWrite( fFile, fBuffer.Memory, 1 );
        end
        else
        begin
          // OK - load values
          fBuffer.Position := 0;
          fBuffer.Write( iRec, iRecLen );
          fBuffer.Position := 0;
          fBuffer.Read( fRecFirst, sizeof( fRecFirst ) );
          fBuffer.Read( fRecLast, sizeof( fRecLast ) );
          fBuffer.Read( fDelFirst, sizeof( fDelFirst ) );
          fBuffer.Read( fDelLast, sizeof( fDelLast ) );
        end;
      end
      else
      begin
        Rewrite( fFile, iRecLen );
        // create record zero, which is 4 zero entries.
        fBuffer.Position := 0;
        fRecFirst:= 0;
        fRecLast := 0;
        fDelFirst:= 0;
        fDelLast := 0;
        fBuffer.Write( fRecFirst, sizeof( fRecFirst ) );
        fBuffer.Write( fRecLast, sizeof( fRecLast ) );
        fBuffer.Write( fDelFirst, sizeof( fDelFirst ) );
        fBuffer.Write( fDelLast, sizeof( fDelLast ) );
        BlockWrite( fFile, fBuffer.Memory, 1 );
      end;
      fOpen := TRUE;
    except
      fOpen := FALSE;
    end;
  end
  else
  begin
    fOpen := FALSE;
  end;
  Result := fOpen;
end;

function tSigDBDataFile.RecLen: int64;
var
  i: Integer;
begin
  Result := 2 * Sizeof( Int64 ); // linked list entries
  for i := 0 to fFields.Max do
  begin
    inc( Result, Field[ i ].FieldLen );
  end;
end;

procedure tSigDBDataFile.SetTableGridFields(const Value: tSigGeneralGrid);
begin
  fTableGridFields := Value;
  fFields.RecEditor := Value;
end;

{ tSigDBField }

constructor tSigDBField.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fFieldType := tSigDBFieldTypeType.Create( 'Type', self );
  fDataField := tSigFieldPointer.Create( 'Data Field', self );
end;

function tSigDBField.GetDBFile: tSigDBFile;
begin
  Result := OwnerFile as tSigDBFile;
end;

function tSigDBField.GetFieldType: tSigDBFieldType;
begin
  Result := tSigDBFieldType( fFieldType.ValueAsInt );
end;

function tSigDBField.GetFieldTypeAsString: string;
begin
  Result := fFieldType.ValueAsText;
end;


procedure tSigDBField.SetFieldType(const Value: tSigDBFieldType);
begin
  fFieldType.ValueAsInt := Ord( Value );
end;

procedure tSigDBField.SetFieldTypeAsString(const Value: string);
begin
  fFieldType.Value := Value;
end;

{ tSigDBFieldList }

{
procedure tSigDBFieldList.BuildFieldList(const pList: tStrings);
var
  i: Integer;
begin
  pList.Clear;
  for i := 0 to Max do
  begin
    pList.AddObject( Field[ i ].Name, Field[ i ] );
  end;
end;

function tSigDBFieldList.FieldWithName(const pName: string): tSigDBField;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Result := Field[ i ];
    if SameText( Result.Name, pName ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;
}

function tSigDBFieldList.GetDBFile: tSigDBFile;
begin
  Result := OwnerFile as tSigDBFile;
end;

function tSigDBFieldList.GetField(const i: integer): tSigDBField;
begin
  Result := Entry[ i ] as tSigDBField;
end;

{ tSigDBDatabase }

procedure tSigDBDatabase.AddNewDataFile(const pName: string);
begin
  fDataFiles.AddDataFile( pName );
end;

procedure tSigDBDatabase.AddNewIndexFile(const pName: string);
begin
  fIndexFiles.AddIndexFile( pName );
end;

procedure tSigDBDatabase.AfterLoad;
begin
  inherited;
  BuildIndexFileDropDown;
  BuildTableFileDropDown;
end;

procedure tSigDBDatabase.BuildDesktopFieldsGridFields;
begin
  raise Exception.Create('to do');
end;

procedure tSigDBDatabase.BuildDesktopFieldsGrid;
begin
  if assigned( fSigGeneralGridDesktopFields ) then
  begin
    // set up titles
    BuildDesktopFieldsGridTitles;
    BuildDesktopFieldsGridFields;
  end;
end;

procedure tSigDBDatabase.BuildDesktopFieldsGridTitles;
begin
  if assigned( fSigGeneralGridDesktopFields ) then
  begin
    // apart from the sel column, which is predefined, the titles
    // are defined by the fields of the active data files
    fDataFiles.BuildDesktopFieldsGridTitles;
  end;
end;

procedure tSigDBDatabase.BuildIndexFileDropDown;
begin
  if assigned( fComboBoxIndexFileBasedOn ) then
  begin
    // need to build Index files
    fDataFiles.BuildFileList( fComboBoxIndexFileBasedOn.Items );
  end;
end;

procedure tSigDBDatabase.BuildTableFileDropDown;
begin
  if assigned( fIndexGridFields ) then
  begin
    // need to build table files list
    fIndexFiles.BuildFileList( fIndexGridFields.Editor[ tSigDBDataFieldList.cIndexTable ].ItemsList );
  end;
end;

procedure tSigDBDatabase.Close;
begin
  fDataFiles.Close;
  fIndexFiles.Close;
end;

constructor tSigDBDatabase.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fDataFiles  := tSigDBDataFileList.Create( 'Data Files', self );
  fIndexFiles := tSigDBIndexFileList.Create( 'Index Files', self );
end;

procedure tSigDBDatabase.Format;
var
  i : integer;
  iPath : string;
  iFile : string;
  iSearch : tSearchRec;
  iAttr : integer;
  iToDelete : tStringList;
  iExt : string;
begin
  Close;
  iFile := OwnerFile.FileName;
  if OwnerFile.SaveIfDirty then
  begin
    iPath := ExtractFilePath( iFile );
    if FormFormat.Execute then
    begin
      iAttr := 0;
      //remove all dta and idx file from directory
      iToDelete := tStringList.Create;
      try
        if FindFirst( iPath, iAttr, iSearch ) = 0 then
        begin
          repeat
            iFile := iSearch.Name;
            iExt := ExtractFileExt( iFile );
            if SameText( iExt, 'idx' ) or SameText( iExt, 'dta' ) then
            begin
              iToDelete.Add( iFile );
            end;
          until FindNext( iSearch ) <> 0;
          FindClose( iSearch );
          for i := 0 to iToDelete.Count - 1 do
          begin
            DeleteFile( iToDelete[ i ] );
          end;
        end;
      finally
        iToDelete.Free;
      end;
      // OK all files removed
      // Now to create new ones.
      Open;
    end;
  end;
end;

function tSigDBDatabase.GetDataFile(const pName: string): tSigDBIndexFile;
begin
  Result := fDataFiles.FileBaseWithName( pName ) as tSigDBIndexFile;
end;

function tSigDBDatabase.GetIndexFile(const pName: string): tSigDBIndexFile;
begin
  Result := fIndexFiles.FileBaseWithName( pName ) as tSigDBIndexFile;
end;

function tSigDBDatabase.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  OwnerFile.RegisterAfterLoadEntry( self );
  Result := inherited;
end;

procedure tSigDBDatabase.OnPageControlDatabaseChange(Sender: tObject);
begin
  with fPageControlDatabase do
  begin
    case ActivePageIndex of
      0:
      begin
        BuildIndexFileDropDown;
      end;
      1:
      begin
        BuildTableFileDropDown;
      end;
    end;
  end;
end;

function tSigDBDatabase.Open: boolean;
begin
  Result := fDataFiles.Open or fIndexFiles.Open;
end;

procedure tSigDBDatabase.SetComboBoxIndexFileBasedOn(const Value: tComboBox);
begin
  fComboBoxIndexFileBasedOn := Value;
  BuildTableFileDropDown;
  IndexFiles.ComboBoxIndexFileBasedOn := ComboBoxIndexFileBasedOn;
end;

procedure tSigDBDatabase.SetIndexGridFields(const Value: tSigGeneralGrid);
begin
  if fIndexGridFields <> Value then
  begin
    fIndexGridFields := Value;
    IndexFiles.TableGridFields := Value;
    BuildIndexFileDropDown;
  end;
end;

procedure tSigDBDatabase.SetPageControlDatabase(const Value: tPageControl);
begin
  fPageControlDatabase := Value;
  // Page control is only set once, and we are in the fortunate position
  // that tables referred to on page 1 can only be added or removed on page zero
  // and vice versa, which means that we only need to update the file
  // drop-down lists on page change
  if assigned( fPageControlDatabase ) then
  begin
    fPageControlDatabase.OnChange := OnPageControlDatabaseChange;
  end;
end;

procedure tSigDBDatabase.SetSigGeneralGridDesktopFields(
  const Value: tSigGeneralGrid);
begin
  fSigGeneralGridDesktopFields := Value;
  BuildDesktopFieldsGrid;
end;

procedure tSigDBDatabase.SetSpeedButtonChangeIndexName(
  const Value: tSpeedButton);
begin
  fSpeedButtonChangeIndexName := Value;
  IndexFiles.SpeedButtonChangeName := Value;
end;

procedure tSigDBDatabase.SetTabControlDataFiles(const Value: tTabControl);
begin
  if fTabControlDataFiles <> Value then
  begin
    fTabControlDataFiles := Value;
    DataFiles.TabControlFiles := Value;
  end;
end;

procedure tSigDBDatabase.SetTabControlEditDB(const Value: tTabControl);
begin
  fTabControlEditDB := Value;
  fDataFiles.TabControlEditDB := Value;
end;

procedure tSigDBDatabase.SetTabControlIndexFiles(const Value: tTabControl);
begin
  if fTabControlIndexFiles <> Value then
  begin
    fTabControlIndexFiles := Value;
    IndexFiles.TabControlFiles := Value;
  end;
end;

procedure tSigDBDatabase.SetDataGridFields(const Value: tSigGeneralGrid);
begin
  if fDataGridFields <> Value then
  begin
    fDataGridFields := Value;
    DataFiles.TableGridFields := Value;
    BuildTableFileDropDown;
  end;
end;

{ tSigDBDataFileList }

procedure tSigDBDataFileList.AddDataFile(const pNewFileName: string);
begin
  if FileExists( pNewFileName ) then
  begin
    raise tSigDBException.Create('A table with name "' + pNewFileName + '" already exists');
  end;
  // else
  Max := Max + 1;
  DataFile[ Max ].Name := pNewFileName;
  SetupTabs;
end;

procedure tSigDBDataFileList.AfterLoad;
begin
  inherited;
  BuildEditDBTabs;
end;

procedure tSigDBDataFileList.BuildDesktopFieldsGridTitles( const pGrid : tSigGeneralGrid );
begin
  if ActiveChild >= 0 then
  begin
    DataFile[ ActiveChild ].BuildDesktopFieldsGridTitles( pGrid );
  end
  else
  begin
    pGrid.ColCount := 1;
  end;
end;

procedure tSigDBDataFileList.BuildEditDBTabs;
var
  i: integer;
begin
  if assigned( fTabControlEditDB ) then
  begin
    with fTabControlEditDB.Tabs do
    begin
      Clear;
      for i := 0 to Max do
      begin
        AddObject( DataFile[ i ].Name, DataFile[ i ] );
      end;
    end;
    fTabControlEditDB.TabIndex := ActiveChild;
  end;
end;

procedure tSigDBDataFileList.Close;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DataFile[ i ].Close;
  end;
end;

constructor tSigDBDataFileList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBDataFile );

end;

function tSigDBDataFileList.GetDataFile(const i: integer): tSigDBDataFile;
begin
  Result := FileBase[ i ] as tSigDBDataFile;
end;

function tSigDBDataFileList.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  OwnerFile.RegisterAfterLoadEntry( self );
end;

procedure tSigDBDataFileList.OnEditDBTabsChange(Sender: tObject);
begin
  ActiveChild := fTabControlEditDB.TabIndex;
end;

function tSigDBDataFileList.Open: boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Max do
  begin
    if not DataFile[ i ].Open then
    begin
      Result := FALSE;
    end;
  end;
end;

procedure tSigDBDataFileList.SetActiveChild(const pValue: integer);
begin
  if ActiveChild >= 0 then
  begin
    DataFile[ ActiveChild ].TableGridFields := nil;
  end;
  inherited;
  if ActiveChild >= 0 then
  begin
    DataFile[ ActiveChild ].TableGridFields := fTableGridFields;
  end;
end;

procedure tSigDBDataFileList.SetTabControlEditDB(const Value: tTabControl);
begin
  if assigned( fTabControlEditDB ) then
  begin
    fTabControlEditDB.OnChange := nil;
  end;
  fTabControlEditDB := Value;
  if assigned( fTabControlEditDB ) then
  begin
    fTabControlEditDB.OnChange := OnEditDBTabsChange;
  end;
end;

procedure tSigDBDataFileList.SetTableGridFields(const Value: tSigGeneralGrid);
begin
  if ActiveChild >= 0 then
  begin
    DataFile[ ActiveChild ].TableGridFields := nil;
  end;
  fTableGridFields := Value;
  if ActiveChild >= 0 then
  begin
    DataFile[ ActiveChild ].TableGridFields := Value;
  end;
end;

{ tSigDBIndexFileList }

procedure tSigDBIndexFileList.AddIndexFile(const pNewFileName: string);
begin
  if FileExists( pNewFileName ) then
  begin
    raise tSigDBException.Create('An index with name "' + pNewFileName + '" already exists');
  end;
  // else
  Max := Max + 1;
end;

procedure tSigDBIndexFileList.Close;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    IndexFile[ i ].Close;
  end;
end;

constructor tSigDBIndexFileList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBIndexFile );

end;

function tSigDBIndexFileList.GetIndexFile(const i: integer): tSigDBIndexFile;
begin
  Result := Entry[ i ] as tSigDBIndexFile;
end;

function tSigDBIndexFileList.Open: boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Max do
  begin
    if not IndexFile[ i ].Open then
    begin
      Result := FALSE;
    end;
  end;
end;

procedure tSigDBIndexFileList.SetActiveChild(const pValue: integer);
begin
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].ComboBoxIndexFileBasedOn := nil;
    IndexFile[ ActiveChild ].TableGridFields := nil;
  end;
  inherited;
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].ComboBoxIndexFileBasedOn := fComboBoxIndexFileBasedOn;
    IndexFile[ ActiveChild ].TableGridFields := fTableGridFields;
  end;
end;

procedure tSigDBIndexFileList.SetComboBoxIndexFileBasedOn(
  const Value: tComboBox);
begin
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].ComboBoxIndexFileBasedOn := nil;
  end;
  fComboBoxIndexFileBasedOn := Value;
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].ComboBoxIndexFileBasedOn := Value;
  end;
end;

procedure tSigDBIndexFileList.SetTableGridFields(const Value: tSigGeneralGrid);
begin
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].TableGridFields := nil;
  end;
  fTableGridFields := Value;
  if ActiveChild >= 0 then
  begin
    IndexFile[ ActiveChild ].TableGridFields := fTableGridFields;
  end;
end;

{ tSigDBDataField }

procedure tSigDBDataField.CheckIndexField(const pRow: integer);
begin
  raise Exception.Create('To Do');
end;

constructor tSigDBDataField.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fName      := tSigTextProperty.Create( 'Name', self );
  fFieldLen  := tSigIntegerProperty.Create( 'Field Length', self );
end;

function tSigDBDataField.GetFieldLen: integer;
begin
 // Result := fFieldLen.ValueAsInt;
  case FieldType of
    ft_String: Result := fFieldLen.ValueAsInt;
    ft_Integer: Result := sizeof( Int64 );
    ft_Date_Time: Result := Sizeof( tDateTime );
    ft_Field_Pointer: Result := sizeof( Int64 );
    ft_Index_Ascending,
    ft_Index_Descending,
    ft_Filter_LT,
    ft_Filter_LE,
    ft_Filter_EQ,
    ft_Filter_NE,
    ft_Filter_GE,
    ft_Filter_GT: raise Exception.Create('Field Type not valid in data files');
    else
    begin
      raise Exception.Create('Unknown Field Type');
    end;
  end;
end;

function tSigDBDataField.GetIndexField: string;
var
  iField : tSigDBDataField;
begin
  iField := fDataField.Field as tSigDBDataField;
  if assigned( iField ) then
  begin
    Result := iField.Name;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigDBDataField.GetIndexTable: string;
begin
  if assigned( fIndexTable.DestinationObject ) then
  begin
    with fIndexTable.DestinationObject as tSigDBFileBase do
    begin
      Result := Name;
    end;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigDBDataField.GetName: string;
begin
  Result := fName.Value;
end;

procedure tSigDBDataField.SetFieldLen(const Value: integer);
begin
  fFieldLen.ValueAsInt := Value;
end;

procedure tSigDBDataField.SetIndexField(const Value: string);
begin
  raise Exception.Create('To do');
  // depends on the table
end;

procedure tSigDBDataField.SetIndexTable(const Value: string);
begin
  // we need to find the index file from the database list
  // and assign it to our pointer. Blank = delete
  if Value = '' then
  begin
    fIndexTable.DestinationObject := nil;
  end
  else if SameText( Value, '<none>' ) then
  begin
    fIndexTable.DestinationObject := nil;
  end
  else
  begin
    fIndexTable.DestinationObject := DBFile.Database.IndexFile[ Value ];
    if not assigned(fIndexTable.DestinationObject) then
    begin
      raise Exception.Create('Index file not found');
    end;
  end;
end;

procedure tSigDBDataField.SetName(const Value: string);
begin
  fName.Value := Value;
end;

{ tSigDBFileBase }

{
procedure tSigDBFileBase.BuildFieldsGrid;
var
  i: integer;
begin
  if assigned( GridFields ) then
  begin
    with GridFields do
    begin
      HideEditor;
      RowCount := FieldCount + 2; // one for blank line
      for i := 0 to FieldCount do
      begin
        BuildFieldsLine( i );
      end;
    end;
  end;
end;
}

constructor tSigDBFileBase.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fName      := tSigRelativeFileProperty.Create( 'File Name', self );
  //fNextIndex := tSigInt64.Create( 'Next Index', self );

  fName.OnChange := OnNameChange;
end;

destructor tSigDBFileBase.Destroy;
begin
  inherited;
end;

function tSigDBFileBase.GetName: string;
begin
  Result := fName.Value;
end;

function tSigDBFileBase.GetSigDBFile: tSigDBFile;
begin
  Result := OwnerFile as tSigDBFile;
end;

procedure tSigDBFileBase.OnNameChange(const pChangedObject: tSigBaseProperty);
begin
  (Owner as tSigDBFileBaselist).SetupTabs;
end;

{
procedure tSigDBFileBase.SetGridFields(const Value: tSigGeneralGrid);
begin
  if fGridFields <> Value then
  begin
    if assigned( fGridFields ) then
    begin
      fGridFields.OnCellEditChange := nil;
    end;
    fGridFields := Value;
    if assigned( fGridFields ) then
    begin
      fGridFields.OnCellEditChange := OnFieldsCellEditChange;
      BuildFieldsGrid;
    end;
  end;
end;
}

procedure tSigDBFileBase.SetName(const Value: string);
begin
  fName.Value := Value;
end;

{ tSigDBDataFieldList }

procedure tSigDBDataFieldList.BuildDesktopFieldsGridTitles(
  const pGrid: tSigGeneralGrid);
var
  i: Integer;
begin
  // 1 col for sel
  pGrid.ColCount := 2 + Max;
  for i := 0 to Max do
  begin
    pGrid.Cell[ i + 1, 0 ] := DataField[ i ].Name;
  end;
end;

procedure tSigDBDataFieldList.BuildFieldList(const pList: tStrings);
var
  i: Integer;
begin
  pList.Clear;
  for i := 0 to Max do
  begin
    pList.AddObject( DataField[ i ].Name, Field[ i ] );
  end;
end;

procedure tSigDBDataFieldList.BuildRecCell(const pCol, pRow: integer;
  const pRec: tSigBaseProperty);
var
  iRec : tSigDBDataField;
begin
  inherited;
  iRec := pRec as tSigDBDataField;
  with RecEditor, iRec do
  begin
    case pCol of
      cName:        Cell[ cName, pRow ]       := Name;
      cFieldType:   Cell[ cFieldType, pRow ]  := FieldTypeAsString;
      cIndexTable:  Cell[ cIndexTable, pRow ] := '';
      cIndexField:  Cell[ cIndexField, pRow]  := '';
      cLen:         Cell[ cLen, pRow ]        := IntToStr( FieldLen );
    end;
  end;

end;

constructor tSigDBDataFieldList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBDataField );
  AllowRecCreate := TRUE;
end;

function tSigDBDataFieldList.FieldWithName(const pName: string): tSigDBDataField;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Result := DataField[ i ];
    if SameText( Result.Name, pName ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function tSigDBDataFieldList.GetDataField(const i: integer): tSigDBDataField;
begin
  Result := Field[ i ] as tSigDBDataField;
end;

procedure tSigDBDataFieldList.OnFieldsCellEditChange(const Sender: TObject;
  const Col, Row: Integer; const pValue: string);
var
  iChild : integer;
begin
  iChild := Row - RecEditor.FixedRows;
  if iChild >= 0 then
  begin
    if iChild < Max then
    begin
      Max := iChild;
    end;
    with DataField[ iChild ] do
    begin
      case Col of
        cSel:;
        cName:       Name              := pValue;
        cFieldType:  FieldTypeAsString := pValue;
        cIndexTable: IndexTable        := pValue;
        cIndexField: IndexField        := pValue;
        cLen:        FieldLen          := StrToIntDef( pValue, FieldLen );
      end;
    end;
  end;
end;

procedure tSigDBDataFieldList.SetRecEditor(const Value: tSigGeneralGrid);
begin
  if assigned( RecEditor ) then
  begin
    RecEditor.OnCellEditChange := nil;
  end;
  inherited;
  if assigned( RecEditor ) then
  begin
    RecEditor.OnCellEditChange := OnFieldsCellEditChange;
  end;
end;

{ tSigDBIndexFieldList }

procedure tSigDBIndexFieldList.AfterLoad;
begin
  inherited;
  SetComboBoxIndexFileBasedOnItemIndex;
  BuildFieldsDropdown;
end;

procedure tSigDBIndexFieldList.BuildFieldsDropdown;
begin
  if assigned( RecEditor ) then
  begin
    if assigned( DataFile ) then
    begin
      DataFile.Fields.BuildFieldList( RecEditor.Editor[ tSigDBIndexFieldList.cColDataField ].ItemsList );
    end;
  end;
end;

procedure tSigDBIndexFieldList.BuildRecCell(const pCol, pRow: integer;
  const pRec: tSigBaseProperty);
var
  iRec : tSigDBIndexField;
begin
  inherited;
  iRec := pRec as tSigDBIndexField;
  with RecEditor, iRec do
  begin
    case pCol of
      cColDataField:  Cell[ cColDataField, pRow ]  := DataField;
      cColDataType:   Cell[ cColDataType, pRow ] := FieldTypeAsString;
      cColCompareField:  Cell[ cColCompareField, pRow]  := Filter;
    end;

  end;
end;

constructor tSigDBIndexFieldList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBIndexField );

  fDataFile  := tSigDBDataFilePointer.Create( 'Data File', self, DBFile.Database.DataFiles.Children );
  AllowRecCreate := TRUE;
end;

function tSigDBIndexFieldList.GetDataFile: tSigDBDataFile;
begin
  Result := fDataFile.DestinationObject as tSigDBDataFile;
end;

function tSigDBIndexFieldList.GetIndexField(const i: integer): tSigDBIndexField;
begin
  Result := Field[ i ] as tSigDBIndexField;
end;

function tSigDBIndexFieldList.GetOwnerAsSigDBIndexFile: tSigDBIndexFile;
begin
  Result := GetOwnerOfType( tSigDBIndexFile ) as tSigDBIndexFile;
end;

function tSigDBIndexFieldList.IndexFieldWithName(
  const pName: string): tSigDBDataField;
begin
  if assigned( DataFile ) then
  begin
    Result := DataFile.Fields.FieldWithName( pName ) as tSigDBDataField;
  end
  else
  begin
    Result := nil;
  end;

end;

function tSigDBIndexFieldList.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  OwnerFile.RegisterAfterLoadEntry( self );
end;

procedure tSigDBIndexFieldList.OnComboBoxIndexFileBasedOnChange(
  Sender: tObject);
begin
  if fComboBoxIndexFileBasedOn.ItemIndex >= 0 then
  begin
    DataFile := fComboBoxIndexFileBasedOn.Items.Objects[ fComboBoxIndexFileBasedOn.ItemIndex ] as tSigDBDataFile;
  end
  else
  begin
    DataFile := nil;
  end;
  BuildFieldsDropdown;
end;

procedure tSigDBIndexFieldList.OnFieldsCellEditChange(const Sender: TObject;
  const Col, Row: Integer; const pValue: string);
begin
  if Row > 0 then
  begin
    // ignore Header row
    if Row > Max + 1 then
    begin
      // adding new child
      Max := Max + 1;
      RecEditor.RowCount := Max + 3; // Live row count := Max + 1, plus 1 for header and 1 for blank line
      BuildRecLine( Row - 1, IndexField[ Max ] );
      BuildRecLine( Row, nil );
      RecEditor.Cell[ Col, Row ] := pValue; // !
    end;
    with IndexField[ Row - 1 ] do
    begin
      case Col of
        cColSel        :;
        cColDataField : DataField         := pValue;
        cColDataType  : FieldTypeAsString := pValue;
        cColCompareField:
        begin
          if OwnerAsSigDBIndexFile.FilterValid( Row - 1, pValue ) then
          begin
            Filter := pValue;
          end
          else
          begin
            raise Exception.Create('To do');
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigDBIndexFieldList.SetComboBoxIndexFileBasedOn(
  const Value: tComboBox);
begin
  fComboBoxIndexFileBasedOn := Value;
  SetComboBoxIndexFileBasedOnItemIndex;
  BuildFieldsDropdown;
end;

procedure tSigDBIndexFieldList.SetComboBoxIndexFileBasedOnItemIndex;
var
  i, iIndex: Integer;
begin
  if assigned( fComboBoxIndexFileBasedOn ) then
  begin
    iIndex := -1;
    fComboBoxIndexFileBasedOn.OnChange := OnComboBoxIndexFileBasedOnChange;
    if assigned( DataFile ) then
    begin
      with fComboBoxIndexFileBasedOn.Items do
      for i := 0 to Count - 1 do
      begin
        if Objects[ i ] = DataFile then
        begin
          iIndex := i;
          break;
        end;
      end;
    end;
    if fComboBoxIndexFileBasedOn.ItemIndex <> iIndex then
    begin
      fComboBoxIndexFileBasedOn.ItemIndex := iIndex;
    end;
    OnComboBoxIndexFileBasedOnChange( self );
  end;
end;

procedure tSigDBIndexFieldList.SetDataFile(const Value: tSigDBDataFile);
begin
  fDataFile.DestinationObject := Value;
end;

procedure tSigDBIndexFieldList.SetRecEditor(const Value: tSigGeneralGrid);
begin
  if assigned( RecEditor ) then
  begin
    RecEditor.OnCellEditChange := nil;
  end;
  inherited;
  if assigned( RecEditor ) then
  begin
    RecEditor.OnCellEditChange := OnFieldsCellEditChange;
  end;
end;

{ tSigDBIndexFile }

procedure tSigDBIndexFile.CheckDataField(const pRow: integer);
begin
  raise Exception.Create('To Do');
end;

procedure tSigDBIndexFile.Close;
begin
  CloseFile( fFile );
end;

constructor tSigDBIndexFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner );

  fFields   := tSigDBIndexFieldList.Create( 'Fields', self );
end;

function tSigDBIndexFile.FieldCount: integer;
begin
  Result := fFields.Max + 1;
end;

function tSigDBIndexFile.FilterValid(const pIndex : integer; const pValue: string): boolean;
begin
  case Field[ pIndex ].FieldType of
    ft_Index_Ascending, ft_Index_Descending: Result := pValue = '';
    ft_Filter_LT, ft_Filter_LE,
    ft_Filter_GE, ft_Filter_GT: Result := IsValidList( pValue );
    ft_Filter_EQ, ft_Filter_NE: Result := IsSingleValue( pValue );
    else
    begin
      Result := FALSE;
    end;
  end;
end;

{
function tSigDBIndexFile.GetDataFile: tSigDBDataFile;
begin
  Result := fFields.fDataFile.DataFile;
end;
}

function tSigDBIndexFile.GetIndexField(const i: integer): tSigDBIndexField;
begin
  Result := fFields.IndexField[ i ];
end;

function tSigDBIndexFile.IsSingleValue(const pValue: string): boolean;
begin
  raise Exception.Create('To do');
end;

function tSigDBIndexFile.IsValidList(const pValue: string): boolean;
begin
  raise Exception.Create('To do');
end;

function tSigDBIndexFile.Open: boolean;
var
  iPathName : string;
  iFile : string;
  iRecLen : int64;
  iResult : integer;
begin
  if OwnerFile.SaveIfDirty  then
  begin
    iPathName := ExtractFilePath( OwnerFile.FileName );
    iFile := iPathName + Name;
    try
      iRecLen := SizeOf( fRec );
      AssignFile( fFile, iFile  );
      if FileExists( iFile ) then
      begin
        Reset( fFile, iRecLen );
        BlockRead( fFile, fRec0, 1, iResult );
        if iResult < 1 then
        begin
          // empty file. Should not happen, but
          Seek( fFile, 0 );
          fRec0.NotUsed := 0;
          fRec0.Root := 0;
          fRec0.Deleted:= 0;
          BlockWrite( fFile, fRec0, 1 );
        end
        else
        begin
          // OK - values loaded
        end;
      end
      else
      begin
        Rewrite( fFile, iRecLen );
        // create record zero, which is 4 zero entries.
          fRec0.NotUsed := 0;
          fRec0.Root := 0;
          fRec0.Deleted:= 0;
          BlockWrite( fFile, fRec0, 1 );
      end;
      fOpen := TRUE;
    except
      fOpen := FALSE;
    end;
  end
  else
  begin
    fOpen := FALSE;
  end;
  Result := fOpen;
end;

procedure tSigDBIndexFile.SetComboBoxIndexFileBasedOn(const Value: tComboBox);
begin
  fComboBoxIndexFileBasedOn := Value;
  fFields.ComboBoxIndexFileBasedOn := Value;
  //SetComboBoxIndexFileBasedOnItemIndex;
  //BuildFieldsDropdown;
end;

{
procedure tSigDBIndexFile.SetDataFile(const Value: tSigDBDataFile);
begin
  fFields.fDataFile.DataFile := Value;
end;
}

procedure tSigDBIndexFile.SetTableGridFields(const Value: tSigGeneralGrid);
begin
  fTableGridFields := Value;
  fFields.RecEditor := Value;
end;

{ tSigDBIndexField }

procedure tSigDBIndexField.Clear;
begin
  inherited;

  fFieldType.ValueAsInt := Ord( ft_Index_Ascending );
end;

constructor tSigDBIndexField.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fFilter    := tSigTextProperty.Create( 'Filter', self );

end;

function tSigDBIndexField.GetDataField: string;
var
  iField : tSigDBDataField;
begin
  iField := fDataField.Field as tSigDBDataField;
  if assigned( iField ) then
  begin
    Result := iField.Name;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigDBIndexField.GetFilter: string;
begin
  Result := fFilter.Value;
end;

function tSigDBIndexField.GetOwnerAsSigDBIndexFieldList: tSigDBIndexFieldList;
var
  iOwner : tSigCompoundProperty;
begin
  iOwner := self.Owner;
  Result := nil;
  while assigned( iOwner ) do
  begin
    if iOwner is tSigDBIndexFieldList then
    begin
      Result := iOwner as tSigDBIndexFieldList;
      exit;
    end;
    iOwner := iOwner.Owner;
  end;
end;

procedure tSigDBIndexField.SetDataField(const Value: string);
begin
  // depends on the table
  fDataField.Field := OwnerAsSigDBIndexFieldList.IndexFieldWithName( Value );
end;

procedure tSigDBIndexField.SetFilter(const Value: string);
begin
  fFilter.Value := Value;
end;

{ tSigDBFileBaselist }

{procedure tSigDBFileBaselist.AfterLoad;
begin
  inherited;
  if ActiveChild >= 0 then
  begin
    FileBase[ ActiveChild ].BuildFieldsGrid;
  end;
end;
}

procedure tSigDBFileBaselist.BuildFileList(const pStrings: tStrings);
var
  i: Integer;
  iName : string;
begin
  with pStrings do
  begin
    if Count > Max + 1 then
    begin
      Clear;
    end;
    for i := 0 to Count - 1 do
    begin
      iName := ExtractRelativePath( ExtractFilePath(OwnerFile.FileName), FileBase[ i ].Name );
      pStrings[ i ] := iName;
      pStrings.Objects[ i ] := FileBase[ i ];
    end;
    for i := Count to Max do
    begin
      iName := ExtractRelativePath( ExtractFilePath(OwnerFile.FileName), FileBase[ i ].Name );
      pStrings.AddObject( iName, FileBase[ i ] );
    end;
  end;
end;

function tSigDBFileBaselist.FileBaseWithName(const pName : string ): tSigDBFileBase;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    Result := FileBase[ i ];
    if SameText( pName, Result.Name ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function tSigDBFileBaselist.FileExists(const pTableName: string): boolean;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if SameText( pTableName, FileBase[ i ].Name ) then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

function tSigDBFileBaselist.GetDBFile: tSigDBFile;
begin
  Result := OwnerFile as tSigDBFile;
end;

function tSigDBFileBaselist.GetFileBase( const i : integer ): tSigDBFileBase;
begin
  Result := Entry[ i ] as tSigDBFileBase;
end;

{
function tSigDBFileBaselist.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  OwnerFile.RegisterAfterLoadEntry( self );
end;
}

procedure tSigDBFileBaselist.OnSpeedButtonChangeNameClick(Sender: tObject);
begin
  if ActiveChild >= 0 then
  begin
    FormChangeTableName.FileName := FileBase[ ActiveChild ].Name;
    if FormChangeTableName.Execute then
    begin
      FileBase[ ActiveChild ].Name := FormChangeTableName.FileName;
    end;
  end;
end;

procedure tSigDBFileBaselist.OnTabChange(Sender: tObject);
begin
  if assigned( fTabControlFiles ) then
  begin
    if fTabControlFiles.TabIndex <> ActiveChild then
    begin
      ActiveChild := fTabControlFiles.TabIndex;
    end;
  end;
end;

procedure tSigDBFileBaselist.SetActiveChild(const pValue: integer);
begin
  if ActiveChild >= 0 then
  begin
    with FileBase[ ActiveChild ] do
    begin
      // remove links
      //GridFields := nil;
    end;
  end;
  inherited;
  if ActiveChild >= 0 then
  begin
    with FileBase[ ActiveChild ] do
    begin
      // add links
      if assigned( self.TabControlFiles ) then
      begin
        if TabControlFiles.TabIndex <> pValue then
        begin
          TabControlFiles.TabIndex := pValue;
        end;
      end;
      //GridFields := self.fGridFields; // self required here
    end;
  end;
end;

procedure tSigDBFileBaselist.SetMax(const Value: integer);
begin
  inherited;
  SetupTabs;
end;

procedure tSigDBFileBaselist.SetSpeedButtonChangeName(
  const Value: tSpeedButton);
begin
  if assigned( fSpeedButtonChangeName ) then
  begin
    fSpeedButtonChangeName.OnClick := nil;
  end;
  fSpeedButtonChangeName := Value;
  if assigned( fSpeedButtonChangeName ) then
  begin
    fSpeedButtonChangeName.OnClick := OnSpeedButtonChangeNameClick;
  end;
end;

procedure tSigDBFileBaselist.SetTabControlFiles(const Value: tTabControl);
begin
  fTabControlFiles := Value;
  if assigned( fTabControlFiles ) then
  begin
    fTabControlFiles.OnChange := OnTabChange;
    SetupTabs;
  end;
end;

procedure tSigDBFileBaselist.SetupTabs;
var
  i: integer;
  iName : string;
begin
  if assigned( fTabControlFiles ) then
  begin
    if Max < 0 then
    begin
      fTabControlFiles.Visible := FALSE;
    end
    else
    begin
      fTabControlFiles.Visible := TRUE;
      with fTabControlFiles.Tabs do
      begin
        if Max < Count - 1 then
        begin
          Clear;
        end;
        for i := 0 to Count - 1 do
        begin
          iName := ExtractRelativePath( ExtractFilePath(OwnerFile.FileName), FileBase[ i ].Name );
          Strings[ i ] := iName;
          Objects[ i ] := FileBase[ i ];
        end;
        for i := Count to Max do
        begin
          iName := ExtractRelativePath( ExtractFilePath(OwnerFile.FileName), FileBase[ i ].Name );
          AddObject( iName, FileBase[ i ] );
        end;
      end;
      if fTabControlFiles.TabIndex <> ActiveChild then
      begin
        fTabControlFiles.TabIndex := ActiveChild;
        {
        if ActiveChild >= 0 then
        begin
          with FileBase[ ActiveChild ] do
          begin
            // add links
            GridFields := self.fGridFields; // self required here
          end;
        end;
        }
      end;
    end;
  end;
end;

{ tSigDBTable }

function tSigDBTable.IsLessThan(const RecA, RecB: int64): boolean;
begin
  raise Exception.Create('To do');
end;

{ tSigFieldPointer }

function tSigFieldPointer.GetField: tSigDBField;
begin
  Result := DestinationObject as tSigDBField;
end;

procedure tSigFieldPointer.SetField(const Value: tSigDBField);
begin
  DestinationObject := Value;
end;

{ tSigDBFieldTypeType }

class procedure tSigDBFieldTypeType.SetupIndexOptions(const pItems: tStrings);
begin
  with pItems do
  begin
    Clear;
    Add( ClassValueToText( Ord( ft_String )));
    Add( ClassValueToText( Ord( ft_Integer )));
    Add( ClassValueToText( Ord( ft_Date_Time )));
    Add( ClassValueToText( Ord( ft_Field_Pointer )));
  end;
end;

class procedure tSigDBFieldTypeType.SetupTableOptions(const pItems: tStrings);
begin
  with pItems do
  begin
    Clear;
    Add( ClassValueToText( Ord( ft_Index_Ascending )));
    Add( ClassValueToText( Ord( ft_Index_Descending )));
    Add( ClassValueToText( Ord( ft_Filter_LT )));
    Add( ClassValueToText( Ord( ft_Filter_LE )));
    Add( ClassValueToText( Ord( ft_Filter_EQ )));
    Add( ClassValueToText( Ord( ft_Filter_NE )));
    Add( ClassValueToText( Ord( ft_Filter_GE )));
    Add( ClassValueToText( Ord( ft_Filter_GT )));
  end;
end;

procedure tSigDBFieldTypeType.SetValue(const pValue: string);
begin
  if not fCalculating then
  begin
    fCalculating := TRUE;
    try
      if SameText( pValue, 'String' ) then
      begin
        ValueAsInt := Ord( ft_String );
      end
      else if SameText( pValue, 'Integer' ) then
      begin
        ValueAsInt := Ord( ft_Integer );
      end
      else if SameText( pValue, 'Date/Time' ) then
      begin
        ValueAsInt := Ord( ft_Date_Time );
      end
      else if SameText( pValue, 'Lookup' ) then
      begin
        ValueAsInt := Ord( ft_Field_Pointer );
      end
      else if SameText( pValue, 'Index (Ascending)' ) then
      begin
        ValueAsInt := Ord( ft_Index_Ascending );
      end
      else if SameText( pValue, 'Index (Descending)' ) then
      begin
        ValueAsInt := Ord( ft_Index_Descending );
      end
      else if SameText( pValue, 'Filter ( < )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_LT );
      end
      else if SameText( pValue, 'Filter ( <= )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_LE );
      end
      else if SameText( pValue, 'Filter ( =, IN )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_EQ );
      end
      else if SameText( pValue, 'Filter ( <>, Not IN )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_NE );
      end
      else if SameText( pValue, 'Filter ( >= )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_GE );
      end
      else if SameText( pValue, 'Filter ( > )' ) then
      begin
        ValueAsInt := Ord( ft_Filter_GT );
      end
      else
      begin
        inherited;
      end;
    finally
      fCalculating := FALSE;
    end;
  end;

end;


function tSigDBFieldTypeType.ValueToText(pValue: integer): string;
begin
  Result := ClassValueToText( pValue );
  if Result = '' then
  begin
    Result := inherited;
  end;
end;

class function tSigDBFieldTypeType.ClassValueToText(pValue: integer): string;
begin
  case tSigDBFieldType( pValue ) of
     ft_String:            Result := 'String';
     ft_Integer:           Result := 'Integer';
     ft_Date_Time:         Result := 'Date/Time';
     ft_Field_Pointer:     Result := 'Lookup';
     ft_Index_Ascending:   Result := 'Index (Ascending)';
     ft_Index_Descending:  Result := 'Index (Descending)';
     ft_Filter_LT:         Result := 'Filter ( < )';
     ft_Filter_LE:         Result := 'Filter ( <= )';
     ft_Filter_EQ:         Result := 'Filter ( =, IN )';
     ft_Filter_NE:         Result := 'Filter ( <>, Not IN )';
     ft_Filter_GE:         Result := 'Filter ( >= )';
     ft_Filter_GT:         Result := 'Filter ( > )';
     else
     begin
       Result := '';
     end;
  end;
end;

{ tSigDBDataFilePointer }

function tSigDBDataFilePointer.GetDataFile: tSigDBDataFile;
begin
  Result := DestinationObject as tSigDBDataFile;
end;

procedure tSigDBDataFilePointer.SetDataFile(const Value: tSigDBDataFile);
begin
  DestinationObject := Value;
end;

end.
