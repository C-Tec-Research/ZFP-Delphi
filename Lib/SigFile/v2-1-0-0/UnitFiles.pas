unit UnitFiles;

interface

uses
  SigFile,
  SigGeneralGrid,
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  VCL.Controls,
  VCL.ComCtrls,
  VCL.Buttons,
  VCL.StdCtrls,
  VCL.Dialogs,
  ErrorList,
  SigDBRawDB,
  SigSpinEdit,
  UnitSetAnalysis;

type
  tSigDBBComparisonStyle = ( cs_None, cs_Numeric, cs_Enum, cs_Text, cs_String,
                             cs_DateTime, cs_Set_Membership, cs_boolean );

  tSigDBBCompareProperty = class( tSigEnum< tSigDBBComparisonStyle > )
  private
    function GetValueAsStyle: tSigDBBComparisonStyle;
    procedure SetValueAsStyle(const Value: tSigDBBComparisonStyle);
  public
    property ValueAsStyle : tSigDBBComparisonStyle
             read GetValueAsStyle
             write SetValueAsStyle;
  end;

  tSigDBBBaseFile = class;
  tSigDBBIndexFile = class;

  tSigDBBField = class( tSigCompoundProperty )
  private
    fConstID: tSigIntegerProperty;
    fFieldName: tSigTextProperty;
    fFieldType: tSigTextProperty;
    fCompareStyle: tSigDBBCompareProperty;
    fComment: tSigTextProperty;
    function GetDataFile: tSigDBBBaseFile;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure Clear; override;

    procedure AddRecInfo( const pLines : tStrings );
    procedure AddSettersAndGetters(const pLines: tStrings);
    procedure AddSettersAndGettersImplementation( const pClassName : string; const pLines : tStrings );
    procedure AddPublicDataInfo( const pLines : tStrings );
    procedure AddMirrorGetterAndSetter( const pLines : tStrings );
    procedure AddMirrorInfo( const pLines : tStrings );
    procedure AddMirrorImplementation( const pClassName : string; const pLines : tStrings );
    procedure AddConstDataInfo( const pLines : tStrings );
    procedure BuildDataImplementation1a( const pLines : tStrings );
    procedure BuildDataImplementation1b( const pLines : tStrings );
    procedure BuildDataImplementation2( const pLines : tStrings );
    procedure BuildDataImplementation3( const pLines : tStrings );
    procedure BuildDataImplementation4( const pLines : tStrings );

    function ParmText : string;

    property ConstID : tSigIntegerProperty
             read fConstID;
    property FieldName : tSigTextProperty
             read fFieldName;
    property FieldType : tSigTextProperty
             read fFieldType;
    property CompareStyle : tSigDBBCompareProperty
             read fCompareStyle;
    property Comment : tSigTextProperty
             read fComment;

    property DataFile : tSigDBBBaseFile
             read GetDataFile;
  end;

  tSigDBBFieldPointer = class( tSigPointer )
  private
    function GetDBBField: tSigDBBField;
    procedure SetDBBField(const Value: tSigDBBField);
    function GetCellText: string;
    procedure SetCellText(const pValue: string);
  protected
    procedure OnInterestedPartyDestroy( const pParty : tSigBaseProperty ); override;
  public
    property DBBField : tSigDBBField
             read GetDBBField
             write SetDBBField;

    property CellText : string
             read GetCellText
             write SetCellText;

    procedure BuildAllowableNames( const pValue : TStrings );
  end;

  tSigDBBFieldList = class( tSigObjectList )
  private
    fAddFieldButton: TSpeedButton;
    fFieldsEditor: TSigGeneralGrid;
    fDeleteFieldButton: TSpeedButton;
    function GetDBField(const i: integer): tSigDBBField;
    procedure BuildFieldsEditor;
    procedure OnFieldEditorCellEditChange( const Sender : TObject; const Col, Row : integer; const Value : string );
    procedure SigGeneralGridFieldsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnAddFieldClick( sender : TObject );
    procedure OnDeleteFieldClick( sender : TObject );
    procedure SetAddFieldButton(const Value: TSpeedButton);
    procedure SetFieldsEditor(const Value: TSigGeneralGrid);
    procedure BuildDataImplementation3(const pLines: tStrings);
    procedure SetDeleteFieldButton(const Value: TSpeedButton);
  protected
    procedure SetActiveChild(const Value: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure AddRecInfo( const pLines : tStrings );
    procedure AddDataInfo( const pLines : tStrings );
    procedure AddSettersAndGetters( const pLines : tStrings );
    procedure AddSettersAndGettersImplementation( const pClassName : string; const pLines : tStrings );
    procedure AddMirrorInfo( const pLines : tStrings );
    procedure AddMirrorGettersAndSetters( const pLines : tStrings );
    procedure AddMirrorImplementation( const pClassName : string; const pLines : tStrings );
    procedure AddConstInfo( const pLines : tStrings );
    procedure BuildDataImplementation1a( const pLines : tStrings );
    procedure BuildDataImplementation1b( const pLines : tStrings );
    procedure BuildDataImplementation2( const pLines : tStrings );
    procedure BuildDataImplementation4( const pLines : tStrings );

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure Sort; reintroduce;
    procedure RefreshEditors;
    procedure RemoveEditors; override;

    property DBField[ const i : integer ] : tSigDBBField
             read GetDBField;

    property FieldsEditor : TSigGeneralGrid
             read fFieldsEditor
             write SetFieldsEditor;
    property AddFieldButton : TSpeedButton
             read fAddFieldButton
             write SetAddFieldButton;
    property DeleteFieldButton : TSpeedButton
             read fDeleteFieldButton
             write SetDeleteFieldButton;

    const
      cColID = 0;
      cColName = cColID + 1;
      cColType = cColName + 1;
      cColCompareType = cColType + 1;
      cColComment = cColCompareType + 1;
  end;

  tSigDBIndexFilter = class( tSigEnum< tSigDBFieldType > )
  private
    function GetSigDBFieldType: tSigDBFieldType;
    procedure SetSigDBFieldType(const Value: tSigDBFieldType);
  protected
  public
    procedure Clear; override;

    function ValueToCellText : string;
    function ValueToTypeText : string;
    procedure CellTextToValue( const pValue : string );

    property ValueAsSigDBFieldType : tSigDBFieldType
             read GetSigDBFieldType
             write SetSigDBFieldType;
  const
    cIndexAscending = 'Index Ascending';
    cIndexDescending = 'Index Descending';
    cFilterLT = 'Filter <';
    cFilterLE = 'Filter <=';
    cFilterEQ = 'Filter =';
    cFilterNE = 'Filter <>';
    cFilterGE = 'Filter >=';
    cFilterGT = 'Filter >';
    cFilterIN = 'Filter Contains';
    cFilterNotIN = 'Filter Does not contain';
    cFilterChanged = 'Test Changed';
  end;

  tSigDBFindFunctionMode = (ff_Variable, ff_EQ, ff_LE, ff_GE,   // differ in how to handle not found situations
                            ff_First, ff_Next, ff_Prev, ff_Last );

  tSigDBFindFunctionModeEnum = class( TSigEnum< tSigDBFindFunctionMode > )
  private
    function GetValueAsEnum: tSigDBFindFunctionMode;
    procedure SetValueAsEnum(const Value: tSigDBFindFunctionMode);
  protected
  public
    property ValueAsEnum : tSigDBFindFunctionMode
             read GetValueAsEnum
             write SetValueAsEnum;

  end;

  {
  tSigDBFindFunctionReadsData = (ff_FALSE, ff_TRUE, ff_Parm );

  tSigDBFindFunctionReadDataEnum = class( TSigEnum< tSigDBFindFunctionReadsData > )
  private
    function GetValueAsEnum: tSigDBFindFunctionReadsData;
    procedure SetValueAsEnum(const Value: tSigDBFindFunctionReadsData);
  protected
  public
    property ValueAsEnum : tSigDBFindFunctionReadsData
             read GetValueAsEnum
             write SetValueAsEnum;
  end;
  }

  tSigDBFindFunction = class( tSigCompoundProperty )
  private
    fFindMode: tSigDBFindFunctionModeEnum;
    //fFindReadsData : tSigDBFindFunctionReadDataEnum;
    fFindLevel: tSigIntegerProperty;
    fUsesFirstNext1: TSigBooleanProperty;
    fFirstLevel1: tSigIntegerProperty;
    fMatchLevel: tSigIntegerProperty;
    function GetDataFile: tSigDBBBaseFile;
    function GetIndexFile: tSigDBBIndexFile;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    procedure Clear; override;

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure AfterLoad; override;

    procedure AddFindDef( const pLines : tStrings );
    procedure AddFindImplementation( const pLines : tStrings );

    property FindMode : tSigDBFindFunctionModeEnum
             read fFindMode;
    property FindLevel : tSigIntegerProperty
             read fFindLevel;
    property MatchLevel : tSigIntegerProperty
             read fMatchLevel;
    //property UsesFirstNext : TSigBooleanProperty
    //         read fUsesFirstNext;
    //property FirstLevel : tSigIntegerProperty
    //         read fFirstLevel;
    //property FindReadsData : tSigDBFindFunctionReadDataEnum
    //         read fFindReadsData;


    property DataFile : tSigDBBBaseFile
             read GetDataFile;
    property IndexFile : tSigDBBIndexFile
             read GetIndexFile;
  end;

  TSigDBFindFunctions = class( tSigObjectList )
  private
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    function GetFindFunction(const i: integer): tSigDBFindFunction;
    function GetDataFile: tSigDBBBaseFile;
  protected
    procedure BuildSigGeneralGridFind;
    procedure OnFieldEditorCellEditChange( const Sender : TObject; const Col, Row : integer; const pValue : string );
    procedure SigGeneralGridFindMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnSpeedButtonAddFindFunctionClick( Sender : TObject );
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    function Load( pFile : tStrings; var pLine : integer; const pAllowUndo : boolean; const pIsDirty : boolean; pErrors : tErrorList = nil ) : boolean; override;
    procedure AfterLoad; override;

    property FindFunction[ const i : integer ] : tSigDBFindFunction
             read GetFindFunction;

    procedure AddFindDefs( const pLines : tStrings );
    procedure AddFindImplementations( const pLines : tStrings );

    procedure RemoveEditors; override;

    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;

    property DataFile : tSigDBBBaseFile
             read GetDataFile;
  const
    cColFindMode = 0;
    cColFindLevel = cColFindMode + 1;
    cColMatchLevel = cColFindLevel + 1;
    //cColFirstLevel = cColFirst + 1;
    //cColFindReadsData = cColFirstLevel + 1;
  end;

  tSigDBIndexField = class( tSigCompoundProperty )
  private
    fDBBField: tSigDBBFieldPointer;
    fCompareValue: tSigTextProperty;
    fFilter: tSigDBIndexFilter;
    function GetDataFile: tSigDBBBaseFile;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    property DBBField : tSigDBBFieldPointer
             read fDBBField;
    property Filter : tSigDBIndexFilter
             read fFilter;
    property CompareValue : tSigTextProperty
             read fCompareValue;

    property DataFile : tSigDBBBaseFile
             read GetDataFile;

    procedure RemoveSelf;
  end;

  tSigDBBDatabase = class;

  TSigDBBIndexFile = class( tSigObjectList )
  private
    fNameExtension: tSigTextProperty;
    fEditIndexExtension: TEdit;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fFindFunctions: TSigDBFindFunctions;
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fMirrorDataFields: TSigBooleanProperty;
    fCheckBoxMirrorDataFields: TCheckBox;
    fIntercept: TSigBooleanProperty;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fEncrypted: tSigBooleanProperty;
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    function GetIndexField(const i: integer): tSigDBIndexField;
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure OnSigGeneralGridIndexesChange( const Sender : TObject; const Col, Row : integer; const pValue : string );
    function GetDataFile: tSigDBBBaseFile;
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
  protected
    procedure OnSigSpinEditIndexCountChange( Sender : TObject );
    procedure ShowIndexes;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    procedure RefreshEditors;

    procedure AddClassDef( const pLines : tStrings );
    procedure AddClassFieldDefs( const pLines : tStrings );
    procedure AddClassImplementation( const pLines : tStrings );
    procedure AddClassFieldImplementations( const pLines : tStrings );
    procedure AddDBFileDef( const pLines : TStrings );
    procedure AddAppendDef( const pLines : TStrings );
    procedure AddUpdateDef( const pLines : TStrings );
    procedure AddDBFileGetter( const pLines : TStrings );
    procedure AddMirrorDefs( const pLines : TStrings );
    procedure AddMirrorGettersAndSetters( const pLines : tStrings );
    procedure AddFindDefs( const pLines : tStrings );
    procedure AddFindImplementations( const pLines : tStrings );

    procedure AddDBIndexSource( const pLines : TStrings );
    procedure AddDBIndexSetter( const pLines : TStrings );
    procedure AddDBIndexProperty( const pLines : TStrings );
    procedure AddDBIndexFileListImplementation( const IndexFileListName : string; const pLines : tStrings );

    procedure UpdateDBSourceClasses( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSource( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSetter( i : integer; const pLines : tStrings );
    procedure InsertDBIndexProperty( i : integer; const pLines : tStrings );
    procedure UpdateIndexListConstructor( i : integer; const pLines : tStrings );
    procedure RemoveIndexField( pIndexField : tSigDBIndexField );

    property NameExtension : tSigTextProperty
             read fNameExtension;
    property FindFunctions : tSigDBFindFunctions
             read fFindFunctions;
    property MirrorDataFields : TSigBooleanProperty
             read fMirrorDataFields;
    property Intercept : TSigBooleanProperty
             read fIntercept;
    property Encrypted : tSigBooleanProperty
             read fEncrypted;

    property IndexField[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    procedure RemoveEditors; override;

    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property DataFile : tSigDBBBaseFile
             read GetDataFile;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;

    function KeyParm( const i : integer ) : string;

    function FullName : string;
  const
    cColIndexNo = 0;
    cColField = cColIndexNo + 1;
    cColFilter = cColField + 1;
    cColCompare = cColFilter + 1;
  end;

  TSigDBBIndexFileList = class( tSigObjectList )
  private
    fEditIndexExtension: TEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fCheckBoxMirrorDataFields: TCheckBox;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fSetAnalysis : TBitSetLines;
    function GetSigDBBIndexFile(const i: integer): tSigDBBIndexFile;
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
  protected
    procedure SetActiveChild(const Value: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    destructor Destroy; override;

    procedure RefreshEditors;

    procedure AddIndexesClasses( const pLines : tStrings );
    procedure AddIndexesImplementations( const pLines : tStrings );

    procedure AddDBIndexSources( const pLines : TStrings );
    procedure AddDBIndexSetters( const pLines : TStrings );
    procedure AddDBIndexProperties( const pLines : TStrings );
    procedure AddDBIndexFileListImplementation( const IndexFileListName : string; const pLines : tStrings );

    procedure UpdateDBSourceClasses( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSources( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSetters( i : integer; const pLines : tStrings );
    procedure InsertDBIndexProperties( i : integer; const pLines : tStrings );
    procedure UpdateIndexListConstructors( i : integer; const pLines : tStrings );
    //procedure UpdateIndexListSetters( const IndexFileListName : string; i : integer; const pLines : tStrings );

    property SigDBBIndexFile[ const i : integer ] : TSigDBBIndexFile
             read GetSigDBBIndexFile;

    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;
  end;

  TSigDBBBaseFile = class( tSigCompoundProperty )
  private
    fFields: tSigDBBFieldList;
    fBaseFileName: tSigTextProperty;
    fAdditionalPrivateMembers: tMemoProperty;
    fAdditionalPublicMembers: tMemoProperty;
    fIndexFiles: tSigDBBIndexFileList;

    fBaseFileNameEditor: TEdit;
    fAdditionalTypes: tMemoProperty;
    fFileAdditionalTypesEditor: TMemo;
    fFieldsEditor: TSigGeneralGrid;
    fAddFieldButton: TSpeedButton;
    fFileAdditionalPrivateMembersEditor: TMemo;
    fFileAdditionalPublicMembersEditor: TMemo;
    fEditIndexExtension: TEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fCheckBoxMirrorDataFields: TCheckBox;
    fIntercept: TSigBooleanProperty;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fCheckBoxAddDataIntercept: TCheckBox;
    fEncrypted: tSigBooleanProperty;
    fDeleteFieldButton: TSpeedButton;
    procedure SetBaseFileNameEditor(const Value: TEdit);
    procedure SetFileAdditionalTypesEditor(const Value: TMemo);
    procedure SetFieldsEditor(const Value: TSigGeneralGrid);
    procedure SetAddFieldButton(const Value: TSpeedButton);
    procedure SetFileAdditionalPrivateMembersEditor(const Value: TMemo);
    procedure SetFileAdditionalPublicMembersEditor(const Value: TMemo);
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
    procedure SetCheckBoxAddDataIntercept(const Value: TCheckBox);
    function GetDatabase: tSigDBBDatabase;
    procedure SetDeleteFieldButton(const Value: TSpeedButton);
  protected
    procedure AddHeaderInfo( const pLines : tStrings );
    procedure AddRecInfo( const pLines : tStrings );
    procedure AddDataInfo( const pLines : tStrings );
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure Clear; override;

    procedure AddConstInfo( const pLines : tStrings );
    procedure AddMirrorInfo( const pLines : tStrings );
    procedure AddMirrorGettersAndSetters( const pLines : tStrings );
    procedure AddMirrorImplementation( const pClassName : string; const  pLines : tStrings );
    procedure AddDataListConstructor( const pLines : tStrings );
    procedure AddIndexListImplementation( const IndexFileListName : string; const pLines : tStrings );

    procedure RefreshEditors;

    procedure BuildFileSource( const pLines : tStrings );
    procedure BuildFileImplementation( const pLines : tStrings );
    procedure BuildDataImplementation( const pLines : tStrings );
    procedure BuildDataFileListConstructor( const pLines : tStrings );
    procedure AddDataFileListField( const pLines : tStrings );
    procedure AddDBIndexFileListSources( const pLines : tStrings );
    procedure AddDBIndexFileListSetters( const pLines : tStrings );
    procedure AddDBIndexFileListProperties( const pLines : tStrings );
    procedure AddDBIndexFileListImplementation( const IndexFileListName : string; const pLines : tStrings );
    procedure AddDataFileListProperty( const pLines : tStrings );

    procedure UpdateDBSourceClasses( i : integer; const pLines : tStrings ); // we don't change i because sources could be in any order
    procedure UpdateInterceptSourceClasses( i : integer; const pLines : tStrings ); // we don't change i because sources could be in any order
    procedure UpdateInterceptSourceClass( const pClass : string; i : integer; const pLines : tStrings ); // we don't change i because sources could be in any order
    procedure InsertDBSource( i : integer; const pLines : tStrings ); // we don't change i because sources could be in any order
    procedure InsertDBProperty( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSources( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSetters( i : integer; const pLines : tStrings );
    procedure InsertDBIndexProperties( i : integer; const pLines : tStrings );
    procedure UpdateDataListConstructor( i : integer; const pLines : tStrings );
    procedure UpdateIndexListConstructors( i : integer; const pLines : tStrings );
    //procedure UpdateIndexListSetters( const IndexFileListName : string; i : integer; const pLines : tStrings );

    function RawUnitName : string;
    property BaseFileName : tSigTextProperty
             read fBaseFileName;
    property Intercept : TSigBooleanProperty
             read fIntercept;
    property AdditionalTypes : tMemoProperty
             read fAdditionalTypes;
    property AdditionalPrivateMembers : tMemoProperty
             read fAdditionalPrivateMembers;
    property AdditionalPublicMembers : tMemoProperty
             read fAdditionalPublicMembers;
    property Fields : tSigDBBFieldList
             read fFields;
    property Encrypted : TSigBooleanProperty
             read fEncrypted;
    property IndexFiles : TSigDBBIndexFileList
             read fIndexFiles;

    property DataBase : tSigDBBDatabase
             read GetDatabase;

    procedure RemoveEditors; override;

    property BaseFileNameEditor : TEdit
             read fBaseFileNameEditor
             write SetBaseFileNameEditor;
    property FileAdditionalTypesEditor : TMemo
             read fFileAdditionalTypesEditor
             write SetFileAdditionalTypesEditor;
    property FileAdditionalPrivateMembersEditor : TMemo
             read fFileAdditionalPrivateMembersEditor
             write SetFileAdditionalPrivateMembersEditor;
    property FileAdditionalPublicMembersEditor : TMemo
             read fFileAdditionalPublicMembersEditor
             write SetFileAdditionalPublicMembersEditor;
    property FieldsEditor : TSigGeneralGrid
             read fFieldsEditor
             write SetFieldsEditor;
    property AddFieldButton : TSpeedButton
             read fAddFieldButton
             write SetAddFieldButton;
    property DeleteFieldButton : TSpeedButton
             read fDeleteFieldButton
             write SetDeleteFieldButton;
    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property CheckBoxAddDataIntercept : TCheckBox
             read fCheckBoxAddDataIntercept
             write SetCheckBoxAddDataIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;
  end;

  TSigDBBaseFileList = class( tSigObjectList )
  private
    fBaseFileNameEditor: TEdit;
    fFileAdditionalTypesEditor: TMemo;
    fFieldsEditor: TSigGeneralGrid;
    fAddFieldButton: TSpeedButton;
    fFileAdditionalPrivateMembersEditor: TMemo;
    fFileAdditionalPublicMembersEditor: TMemo;
    fEditIndexExtension: TEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fCheckBoxMirrorDataFields: TCheckBox;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fCheckBoxAddDataIntercept: TCheckBox;
    fDeleteFieldButton: TSpeedButton;
    function GetBaseFile(const i: integer): tSigDBBBaseFile;
    procedure SetBaseFileNameEditor(const Value: TEdit);
    procedure SetFileAdditionalTypesEditor(const Value: TMemo);
    procedure SetFieldsEditor(const Value: TSigGeneralGrid);
    procedure SetAddFieldButton(const Value: TSpeedButton);
    procedure SetFileAdditionalPrivateMembersEditor(const Value: TMemo);
    procedure SetFileAdditionalPublicMembersEditor(const Value: TMemo);
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetCheckBoxAddDataIntercept(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
    function GetDatabase: tSigDBBDatabase;
    procedure SetDeleteFieldButton(const Value: TSpeedButton);
  protected
    procedure SetActiveChild(const pValue: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    procedure RefreshEditors;

    procedure BuildFileSource( const pLines : tStrings; pFile : integer = -1 );
    procedure BuildPasSource( const pLines : tStrings );
    procedure BuildPasFileListsSource( const pLines : tStrings );
    procedure BuildFileImplementation( const pLines : tStrings; pFile : integer = -1  );
    procedure BuildPasImplementation( const pLines : tStrings );
    procedure BuildPasFileListsImplementation( const pLines : tStrings );
    procedure BuildDataFileListImplementation( const pLines : tStrings );
    procedure BuildIndexFileListImplementation( const pLines : tStrings );
    procedure AddDBSources( const pLines : tStrings );
    procedure AddDBIndexFileListSources( const pLines : tStrings );
    procedure AddDBIndexFileListSetters( const pLines : tStrings );
    procedure AddDBIndexFileListProperties( const pLines : tStrings );
    procedure AddDBProperties( const pLines : tStrings );
    procedure AddDataListConstructors( const pLines : tStrings );
    procedure AddIndexListImplementation( const IndexFileName : string; const pLines : tStrings );

    procedure UpdateDBSourceClasses( var i : integer; const pLines : tStrings );
    procedure InsertDBSources( i : integer; const pLines : tStrings );
    procedure UpdateInterceptSourceClasses( i : integer; const pLines : tStrings );
    procedure InsertDBProperties( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSources( i : integer; const pLines : tStrings );
    procedure InsertDBIndexSetters( i : integer; const pLines : tStrings );
    procedure InsertDBIndexProperties( i : integer; const pLines : tStrings );
    procedure UpdateDataListConstructors( i : integer; const pLines : tStrings );
    procedure UpdateIndexListConstructors( i : integer; const pLines : tStrings );

    property BaseFile[ const i : integer ] : TSigDBBBaseFile
             read GetBaseFile;

    property DataBase : tSigDBBDatabase
             read GetDatabase;

    function BaseName : string;

    property BaseFileNameEditor : TEdit
             read fBaseFileNameEditor
             write SetBaseFileNameEditor;
    property FileAdditionalTypesEditor : TMemo
             read fFileAdditionalTypesEditor
             write SetFileAdditionalTypesEditor;
    property FileAdditionalPrivateMembersEditor : TMemo
             read fFileAdditionalPrivateMembersEditor
             write SetFileAdditionalPrivateMembersEditor;
    property FileAdditionalPublicMembersEditor : TMemo
             read fFileAdditionalPublicMembersEditor
             write SetFileAdditionalPublicMembersEditor;
    property FieldsEditor : TSigGeneralGrid
             read fFieldsEditor
             write SetFieldsEditor;
    property AddFieldButton : TSpeedButton
             read fAddFieldButton
             write SetAddFieldButton;
    property DeleteFieldButton : TSpeedButton
             read fDeleteFieldButton
             write SetDeleteFieldButton;
    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property CheckBoxAddDataIntercept : TCheckBox
             read fCheckBoxAddDataIntercept
             write SetCheckBoxAddDataIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;

  end;

  tSigDBBDatabase = class( tSigCompoundProperty )
  private
    fFiles: tSigDBBaseFileList;
    fBaseFileNameEditor: TEdit;
    fFileAdditionalTypesEditor: TMemo;
    fFieldsEditor: TSigGeneralGrid;
    fAddFieldButton: TSpeedButton;
    fFileAdditionalPrivateMembersEditor: TMemo;
    fFileAdditionalPublicMembersEditor: TMemo;
    fEditIndexExtension: TEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fBaseName: tSigTextProperty;
    fDBBaseNameEditor: TEdit;
    fSigGeneralGridFind: tSigGeneralGrid;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fCheckBoxMirrorDataFields: TCheckBox;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fCheckBoxAddDataIntercept: TCheckBox;
    fDeleteFieldButton: TSpeedButton;
    procedure SetBaseFileNameEditor(const Value: TEdit);
    procedure SetFileAdditionalTypesEditor(const Value: TMemo);
    procedure SetFieldsEditor(const Value: TSigGeneralGrid);
    procedure SetAddFieldButton(const Value: TSpeedButton);
    procedure SetFileAdditionalPrivateMembersEditor(const Value: TMemo);
    procedure SetFileAdditionalPublicMembersEditor(const Value: TMemo);
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    procedure SetDBBaseNameEditor(const Value: TEdit);
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetCheckBoxAddDataIntercept(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
    procedure SetDeleteFieldButton(const Value: TSpeedButton);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    procedure RefreshEditors;

    procedure BuildDBSource( const pLines : tStrings );
    procedure BuildDBImplementation( const pLines : tStrings );
    procedure BuildFileSource( const pLines : tStrings );
    procedure BuildPasSource( const pLines : tStrings );
    procedure BuildFileImplementation( const pLines : tStrings );
    procedure BuildPasImplementation( const pLines : tStrings );

    procedure UpdateDBSourceClasses( var i : integer; const pLines : tStrings );
    procedure UpdateInterceptSourceClasses( var i : integer; const pLines : tStrings );
    procedure UpdateDBSourceImplementation( var i : integer; const pLines : tStrings );

    property BaseName : tSigTextProperty
             read fBaseName;
    property Files : TSigDBBaseFileList
             read fFiles;

    procedure RemoveEditors; override;

    property DBBaseNameEditor : TEdit
             read fDBBaseNameEditor
             write SetDBBaseNameEditor;
    property BaseFileNameEditor : TEdit
             read fBaseFileNameEditor
             write SetBaseFileNameEditor;
    property FileAdditionalTypesEditor : TMemo
             read fFileAdditionalTypesEditor
             write SetFileAdditionalTypesEditor;
    property FieldsEditor : TSigGeneralGrid
             read fFieldsEditor
             write SetFieldsEditor;
    property AddFieldButton : TSpeedButton
             read fAddFieldButton
             write SetAddFieldButton;
    property DeleteFieldButton : TSpeedButton
             read fDeleteFieldButton
             write SetDeleteFieldButton;
    property FileAdditionalPrivateMembersEditor : TMemo
             read fFileAdditionalPrivateMembersEditor
             write SetFileAdditionalPrivateMembersEditor;
    property FileAdditionalPublicMembersEditor : TMemo
             read fFileAdditionalPublicMembersEditor
             write SetFileAdditionalPublicMembersEditor;
    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property CheckBoxAddDataIntercept : TCheckBox
             read fCheckBoxAddDataIntercept
             write SetCheckBoxAddDataIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;
  end;

  TSigDBBFile = class( tSigFileProperty )
  private
    fPasFileName: tSigRelativeFileProperty;
    fDatabase: tSigDBBDatabase;
    fAdditionalTypes: tMemoProperty;
  private
    fBaseFileNameEditor: TEdit;
    fFileAdditionalTypesEditor: TMemo;
    fFieldsEditor: TSigGeneralGrid;
    fAddFieldButton: TSpeedButton;
    fFileAdditionalPrivateMembersEditor: TMemo;
    fFileAdditionalPublicMembersEditor: TMemo;
    fEditIndexExtension: TEdit;
    fSigGeneralGridIndexes: TSigGeneralGrid;
    fSigSpinEditIndexCount: TSigSpinEdit;
    fDBBaseNameEditor: TEdit;
    fSpeedButtonAddFindFunction: TSpeedButton;
    fSigGeneralGridFind: tSigGeneralGrid;
    fCheckBoxMirrorDataFields: TCheckBox;
    fTabControlPasSources: TTabControl;
    fMemoPasSource: TMemo;
    fPasInterceptName: tSigRelativeFileProperty;
    fPasFileListName: tSigRelativeFileProperty;
    fPasDatabaseName: tSigRelativeFileProperty;
    fCheckBoxAddIndexIntercept: TCheckBox;
    fCheckBoxAddDataIntercept: TCheckBox;
    fDeleteFieldButton: TSpeedButton;
    procedure SetBaseFileNameEditor(const Value: TEdit);
    procedure BuildPasHeader( const pLines : tStrings );
    procedure BuildPasFileListsHeader( const pLines : tStrings );
    procedure BuildPasImplementation( const pLines : tStrings );
    procedure BuildPasFinalization( const pLines : tStrings );
    function RawUnitName : string;
    function FileListsUnitName : string;
    function DBUnitName : string;
    function InterceptUnitName : string;
    procedure SetFileAdditionalTypesEditor(const Value: TMemo);
    procedure SetFieldsEditor(const Value: TSigGeneralGrid);
    procedure SetAddFieldButton(const Value: TSpeedButton);
    procedure SetFileAdditionalPrivateMembersEditor(const Value: TMemo);
    procedure SetFileAdditionalPublicMembersEditor(const Value: TMemo);
    procedure SetEditIndexExtension(const Value: TEdit);
    procedure SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
    procedure SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
    procedure SetDBBaseNameEditor(const Value: TEdit);
    procedure SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
    procedure SetSigGeneralGridFind(const Value: tSigGeneralGrid);
    procedure SetCheckBoxMirrorDataFields(const Value: TCheckBox);
    procedure SetTabControlPasSources(const Value: TTabControl);
    procedure OnTabControlPasSourcesChange( Sender : TObject );
    procedure SetMemoPasSource(const Value: TMemo);
    procedure SetCheckBoxAddDataIntercept(const Value: TCheckBox);
    procedure SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
    procedure SetDeleteFieldButton(const Value: TSpeedButton);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure Clear; override;
    procedure RefreshEditors;

    property PasFileName : tSigRelativeFileProperty
             read fPasFileName;
    property PasInterceptName : tSigRelativeFileProperty
             read fPasInterceptName;
    property PasFileListName : tSigRelativeFileProperty
             read fPasFileListName;
    property PasDatabaseName : tSigRelativeFileProperty
             read fPasDatabaseName;
    property DataBase : tSigDBBDatabase
             read fDatabase;
    property AdditionTypes : tMemoProperty
             read fAdditionalTypes;

    procedure BuildDBSource( const pLines : tStrings );
    procedure BuildFileSource( const pLines : tStrings );
    procedure BuildPasSource( const pLines : tStrings );

    procedure UpdateDBSource( const pLines : tStrings );
    procedure UpdateInterceptSource( const pLines : tStrings );
    procedure UpdateDBSourceUnitName( var i : integer; const pLines : tStrings );
    procedure UpdateInterceptSourceUnitName( var i : integer; const pLines : tStrings );
    procedure UpdateDBSourceUsesClause( var i : integer; const pLines : tStrings );
    procedure UpdateInterceptSourceUsesClause( var i : integer; const pLines : tStrings );
    procedure UpdateDBSourceClasses( var i : integer; const pLines : tStrings );
    procedure UpdateInterceptSourceClasses( var i : integer; const pLines : tStrings );
    procedure UpdateDBSourceImplementation( var i : integer; const pLines : tStrings );
    procedure BuildRawSource( const pLines : tStrings );
    procedure BuildFileListsSource( const pLines : tStrings );
    procedure BuildInterceptSkeleton( const pLines : tStrings );
    procedure BuildFileListsSkeleton( const pLines : tStrings );
    procedure BuildDBSkeleton( const pLines : tStrings );

    procedure ShowPasSource;
    procedure SaveSource;

    procedure BuildFileName;

    procedure RemoveEditors; override;

    property DBBaseNameEditor : TEdit
             read fDBBaseNameEditor
             write SetDBBaseNameEditor;
    property BaseFileNameEditor : TEdit
             read fBaseFileNameEditor
             write SetBaseFileNameEditor;
    property FileAdditionalTypesEditor : TMemo
             read fFileAdditionalTypesEditor
             write SetFileAdditionalTypesEditor;
    property FieldsEditor : TSigGeneralGrid
             read fFieldsEditor
             write SetFieldsEditor;
    property AddFieldButton : TSpeedButton
             read fAddFieldButton
             write SetAddFieldButton;
    property DeleteFieldButton : TSpeedButton
             read fDeleteFieldButton
             write SetDeleteFieldButton;
    property FileAdditionalPrivateMembersEditor : TMemo
             read fFileAdditionalPrivateMembersEditor
             write SetFileAdditionalPrivateMembersEditor;
    property FileAdditionalPublicMembersEditor : TMemo
             read fFileAdditionalPublicMembersEditor
             write SetFileAdditionalPublicMembersEditor;
    property EditIndexExtension : TEdit
             read fEditIndexExtension
             write SetEditIndexExtension;
    property CheckBoxMirrorDataFields : TCheckBox
             read fCheckBoxMirrorDataFields
             write SetCheckBoxMirrorDataFields;
    property CheckBoxAddIndexIntercept : TCheckBox
             read fCheckBoxAddIndexIntercept
             write SetCheckBoxAddIndexIntercept;
    property CheckBoxAddDataIntercept : TCheckBox
             read fCheckBoxAddDataIntercept
             write SetCheckBoxAddDataIntercept;
    property SigSpinEditIndexCount : TSigSpinEdit
             read fSigSpinEditIndexCount
             write SetSigSpinEditIndexCount;
    property SigGeneralGridIndexes : TSigGeneralGrid
             read fSigGeneralGridIndexes
             write SetSigGeneralGridIndexes;
    property SigGeneralGridFind : tSigGeneralGrid
             read fSigGeneralGridFind
             write SetSigGeneralGridFind;
    property SpeedButtonAddFindFunction : TSpeedButton
             read fSpeedButtonAddFindFunction
             write SetSpeedButtonAddFindFunction;
    property TabControlPasSources : TTabControl
             read fTabControlPasSources
             write SetTabControlPasSources;
    property MemoPasSource : TMemo
             read fMemoPasSource
             write SetMemoPasSource;
    const
      cTabDatabase = 0;
      cTabFileLists = cTabDatabase + 1;
      cTabInterceptFiles = cTabFileLists + 1;
      cTabRawFiles = cTabInterceptFiles + 1;
  end;

implementation

{ tSigDBBFile }

procedure tSigDBBFile.BuildDBSkeleton(const pLines: tStrings);
begin
  with pLines do
  begin
    Clear;
    Add( 'unit UnitDBFiles;' );
    Add( '' );
    Add( 'interface' );
    Add( '' );
    Add( 'uses' );
    Add( '  SigDBRawDB,' );
    Add( '  System.AnsiStrings,' );
    Add( '  System.DateUtils,' );
    Add( '  System.SysUtils,' );
    Add( '  System.Classes,' );
    Add( '  SigCrypt,' );
    Add( '  PendingActions,' );
    Add( '  {UnitDBRawFiles,}' );
    Add( '  {UnitDBIntFiles,}' );
    Add( '  {UnitDBFLFiles,}' );
    Add( '  UnitSigStrings,' );
    Add( '  Windows;' );
    Add( '' );
    Add( 'type' );
    Add( '' );
    Add( '  //=============================================================================');
    Add( '' );
    Add( '  //----------------------------- Database --------------------------------------');
    Add( '');
    Add( '  TDB = class( TSigDBDatabase )');
    Add( '  private');
    Add( '    function GetDataFiles: TDataFileList;');
    Add( '    function GetIndexFiles: TIndexFileList;');
    Add( '  protected');
    Add( '  public');
    Add( '    constructor Create( const pPath : string ); override;');
    Add( '');
    Add( '    property DataFiles : TDataFileList');
    Add( '             read GetDataFiles;');
    Add( '    property IndexFiles : TIndexFileList');
    Add( '             read GetIndexFiles;');
    Add( '');
    Add( '    procedure Log( const pEvent : string );');
    Add( '  end;');
    Add( '');
    Add( 'implementation' );
    Add( '' );
    Add( '{ TDB }' );
    Add( '' );
    Add( 'constructor TDB.Create(const pPath: string);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '' );
    Add( '  fDataFiles  := TDataFileList.Create( self );' );
    Add( '  fIndexFiles := TIndexFileList.Create( self );' );
    Add( 'end;' );
    Add( '' );
    Add( 'function TDB.GetDataFiles: TDataFileList;' );
    Add( 'begin' );
    Add( '  Result := fDataFiles as TDataFileList;' );
    Add( 'end;' );
    Add( '' );
    Add( 'function TDB.GetIndexFiles: TIndexFileList;' );
    Add( 'begin' );
    Add( '  Result := fIndexFiles as TIndexFileList;' );
    Add( 'end;' );
    Add( '' );
    Add( 'procedure TDB.Log(const pEvent: string);' );
    Add( 'begin' );
    Add( '' );
    Add( 'end;' );
    Add( '' );
    Add( 'end.' );
  end;
end;

procedure tSigDBBFile.BuildDBSource(const pLines: tStrings);
begin
  BuildPasHeader( pLines );
  fDatabase.BuildPasSource( pLines );
  BuildPasImplementation( pLines );
  fDatabase.BuildPasImplementation( pLines );
end;

procedure tSigDBBFile.BuildFileListsSkeleton(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( 'unit UnitDBFileLists;' );
    Add( '' );
    Add( 'interface' );
    Add( '' );
    Add( 'uses' );
    Add( '  SigDBRawDB,' );
    Add( '  System.AnsiStrings,' );
    Add( '  System.DateUtils,' );
    Add( '  System.SysUtils,' );
    Add( '  System.Classes,' );
    Add( '  SigCrypt,' );
    Add( '  PendingActions,' );
    Add( '  {UnitDBRawFiles,}' );
    Add( '  {UnitDBIntFiles,}' );
    Add( '  UnitSigStrings,' );
    Add( '  Windows;' );
    Add( '' );
    Add( 'type' );
    Add( '' );
    Add( '  //=============================================================================');
    Add( '' );
    Add( '  //----------------------------- Database Files --------------------------------');
    Add( '' );
    Add( '  TDataFileList = class( TSigDBDataFileList )');
    Add( '  private' );
    Add( '' );
    Add( '  public');
    Add( '    constructor Create( const pDatabase : TSigDBDatabase ); override;');
    Add( '' );
    Add( '  end;');
    Add( '');
    Add( '  TIndexFileList = class( TSigDBIndexFileList )');
    Add( '  private');
    Add( '');
    Add( '  public');
    Add( '    constructor Create( const pDatabase : TSigDBDatabase ); override;');
    Add( '');
    Add( '  end;');
    Add( '');
    Add( 'implementation' );
    Add( '' );
    Add( '{ TDataFileList }' );
    Add( '' );
    Add( 'constructor TDataFileList.Create(const pDatabase: tSigDBDatabase);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '' );
    Add( 'end;' );
    Add( '' );
    Add( '{ TIndexFileList }' );
    Add( '' );
    Add( 'constructor TIndexFileList.Create(const pDatabase: tSigDBDatabase);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '' );
    Add( 'end;' );
    Add( '' );
    Add( 'end.' );

  end;
end;

procedure tSigDBBFile.BuildFileListsSource(const pLines: tStrings);
begin
  (*
     We always create the FileList source from scratch. The resultant
     file should never be modified by hand.
  *)
  BuildPasFileListsHeader( pLines );
  DataBase.Files.BuildPasFileListsSource( pLines );
  BuildPasImplementation( pLines );   // common
  Database.Files.BuildPasFileListsImplementation( pLines );
  BuildPasFinalization( pLines );  // common
end;

procedure tSigDBBFile.BuildFileName;
var
  iRaw, iPathName, iFileName, iFileExt : string;
  iPos : PWideChar;
begin
  iPathName := ExtractFilePath( fPasFileName.Value );
  iFileName := ExtractFileName( fPasFileName.Value );
  iFileExt := ExtractFileExt( iFileName );
  iFileName := ChangeFileExt( iFileName, '' );
  iRaw := 'raw';
  iPos := TextPos( PChar(iFileName), PChar(iRaw) );
  if not assigned( iPos ) then
  begin
    if fPasFileListName.Value = '' then
    begin
      fPasFileListName.Value := iPathName + iFileName + 'FL' + iFileExt;
    end;
    if fPasInterceptName.Value = '' then
    begin
      fPasInterceptName.Value := iPathName + iFileName + 'Int' + iFileExt;
    end;
    if fPasDatabaseName.Value = '' then
    begin
      fPasDatabaseName.Value := iPathName + iFileName + 'DB' + iFileExt;
    end;
  end
  else
  begin
    if fPasFileListName.Value = '' then
    begin
      fPasFileListName.Value := iPathName + ReplaceText( iFileName, 'raw', 'FL') + iFileExt;
    end;
    if fPasInterceptName.Value = '' then
    begin
      fPasInterceptName.Value := iPathName + ReplaceText( iFileName, 'raw', 'Int') + iFileExt;
    end;
    if fPasDatabaseName.Value = '' then
    begin
      fPasDatabaseName.Value := iPathName + ReplaceText( iFileName, 'raw', 'DB') + iFileExt;
    end;
  end;
end;

procedure tSigDBBFile.BuildFileSource(const pLines: tStrings);
begin
  BuildPasHeader( pLines );
  fDatabase.BuildFileSource( pLines );
  BuildPasImplementation( pLines );
  fDatabase.BuildFileImplementation( pLines );
  BuildPasFinalization( pLines );
end;

procedure tSigDBBFile.BuildInterceptSkeleton(const pLines: tStrings);
begin
  with pLines do
  begin
    Clear;
    Add( 'unit UnitDBIntercepts;' );
    Add( '' );
    Add( 'interface' );
    Add( '' );
    Add( 'uses' );
    Add( '  SigDBRawDB,' );
    Add( '  System.AnsiStrings,' );
    Add( '  System.DateUtils,' );
    Add( '  System.SysUtils,' );
    Add( '  System.Classes,' );
    Add( '  SigCrypt,' );
    Add( '  PendingActions,' );
    Add( '  {UnitDBRawFiles,}' );
    Add( '  UnitSigStrings,' );
    Add( '  Windows;' );
    Add( '' );
    Add( 'type' );
    Add( '' );
    Add( '  //=============================================================================');
    Add( '' );
    Add( '  //----------------------------- Database Intercepts --------------------------------');
    Add( '' );
    Add( '');
    Add( '');
    Add( 'implementation' );
    Add( '' );
    Add( 'end.' );

  end;
end;

procedure tSigDBBFile.BuildPasFileListsHeader(const pLines: tStrings);
begin
  with pLines do
  begin
    Clear;
    Add( 'unit ' + FileListsUnitName + ';');
    Add( '' );
    Add( 'interface');
    Add( '');
    Add( 'uses');
    Add( '  SigDBRawDB,');
    Add( '  System.AnsiStrings,');
    Add( '  System.DateUtils,');
    Add( '  System.SysUtils,');
    Add( '  System.Classes,');
    Add( '  SigCrypt,');
    Add( '  ' + RawUnitName + ',');
    Add( '  ' + InterceptUnitName + ',');
    Add( '  PendingActions,');
    Add( '  UnitSigStrings,');
    Add( '  Windows;');
    Add( '');
    Add( 'type');
    Add( '');
  end;
end;

procedure tSigDBBFile.BuildPasFinalization(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '' );
    Add( 'end.' );
  end;
end;

procedure tSigDBBFile.BuildPasHeader(const pLines: tStrings);
begin
  with pLines do
  begin
    Clear;
    Add( 'unit ' + RawUnitName + ';');
    Add( '' );
    Add( 'interface');
    Add( '');
    Add( 'uses');
    Add( '  Common,' );
    Add( '  SigDBRawDB,');
    Add( '  System.AnsiStrings,');
    Add( '  System.DateUtils,');
    Add( '  System.SysUtils,');
    Add( '  System.Classes,');
    Add( '  SigCrypt,');
    Add( '  PendingActions,');
    Add( '  UnitSigStrings,');
    Add( '  IDGlobal,');
    Add( '  Windows;');
    Add( '');
    Add( 'type');
    Add( '');
    // additional (global) types
    fAdditionalTypes.AddTo( pLines );
  end;
end;

procedure tSigDBBFile.BuildPasImplementation(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( 'implementation' );
    Add( '' );
  end;
end;

procedure tSigDBBFile.BuildPasSource(const pLines: tStrings);
begin
  BuildPasHeader( pLines );
  Database.BuildPasSource( pLines );
  BuildPasImplementation( pLines );
  fDatabase.BuildPasImplementation( pLines );
  BuildPasFinalization( pLines );
end;

procedure tSigDBBFile.BuildRawSource(const pLines: tStrings);
begin
  (*
     We always create the raw source from scratch. The resultant
     file should never be modified by hand.
  *)
  BuildPasHeader( pLines );
  DataBase.Files.BuildPasSource( pLines );
  BuildPasImplementation( pLines );
  Database.Files.BuildPasImplementation( pLines );
  BuildPasFinalization( pLines );
end;

procedure tSigDBBFile.Clear;
begin
  inherited;

end;

constructor tSigDBBFile.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited;

  fPasFileName := tSigRelativeFileProperty.Create( 'PAS File Name', self );
  fPasInterceptName := tSigRelativeFileProperty.Create( 'PAS Intercept Name', self );
  fPasFileListName := tSigRelativeFileProperty.Create( 'PAS FileList Name', self );
  fPasDatabaseName := tSigRelativeFileProperty.Create( 'PAS Database Name', self );
  fDatabase := tSigDBBDatabase.Create( 'Database', self );
  fAdditionalTypes := tMemoProperty.Create( 'Additional Types', self );

end;

function tSigDBBFile.DBUnitName: string;
begin
  Result := ExtractFileName( fPasDatabaseName.Value );
  Result := ChangeFileExt( Result, '' );
  if Result = '' then
  begin
    Result := 'UnitDBFiles';
  end;
end;

function tSigDBBFile.InterceptUnitName: string;
begin
  Result := ExtractFileName( fPasInterceptName.Value );
  Result := ChangeFileExt( Result, '' );
  if Result = '' then
  begin
    Result := 'UnitInterceptFiles';
  end;
end;

procedure tSigDBBFile.OnTabControlPasSourcesChange(Sender: TObject);
begin
  ShowPasSource;
end;

procedure tSigDBBFile.SaveSource;
begin
  if assigned( fTabControlPasSources ) then
  begin
    if assigned( MemoPasSource ) then
    begin
      case fTabControlPasSources.TabIndex of
        cTabDatabase:
        begin
          MemoPasSource.Lines.SaveToFile( PasDatabaseName.Value );
        end;
        cTabRawFiles:
        begin
          MemoPasSource.Lines.SaveToFile( PasFileName.Value );
        end;
        cTabInterceptFiles:
        begin
          MemoPasSource.Lines.SaveToFile( PasInterceptName.Value );
        end;
        cTabFileLists:
        begin
          MemoPasSource.Lines.SaveToFile( PasFileListName.Value );
        end;
      end;
    end;
  end;
end;

procedure tSigDBBFile.SetAddFieldButton(const Value: TSpeedButton);
begin
  fAddFieldButton := Value;
  Database.AddFieldButton := Value;
end;

procedure tSigDBBFile.SetBaseFileNameEditor(const Value: TEdit);
begin
  fBaseFileNameEditor := Value;
  fDatabase.BaseFileNameEditor := Value;
end;

procedure tSigDBBFile.SetCheckBoxAddDataIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddDataIntercept := Value;
  Database.CheckBoxAddDataIntercept := Value;
end;

procedure tSigDBBFile.SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  Database.CheckBoxAddIndexIntercept := Value;
end;

procedure tSigDBBFile.SetCheckBoxMirrorDataFields(const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  DataBase.CheckBoxMirrorDataFields := Value;
end;

procedure tSigDBBFile.SetDBBaseNameEditor(const Value: TEdit);
begin
  fDBBaseNameEditor := Value;
  Database.DBBaseNameEditor := Value;
end;

procedure tSigDBBFile.SetDeleteFieldButton(const Value: TSpeedButton);
begin
  fDeleteFieldButton := Value;
  Database.DeleteFieldButton := Value;
end;

procedure tSigDBBFile.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  Database.EditIndexExtension := Value;
end;

procedure tSigDBBFile.SetFieldsEditor(const Value: TSigGeneralGrid);
begin
  fFieldsEditor := Value;
  Database.FieldsEditor := Value;
end;

procedure tSigDBBFile.SetFileAdditionalPrivateMembersEditor(const Value: TMemo);
begin
  fFileAdditionalPrivateMembersEditor := Value;
  Database.FileAdditionalPrivateMembersEditor := Value;
end;

procedure tSigDBBFile.SetFileAdditionalPublicMembersEditor(const Value: TMemo);
begin
  fFileAdditionalPublicMembersEditor := Value;
  Database.FileAdditionalPublicMembersEditor := Value;
end;

procedure tSigDBBFile.SetFileAdditionalTypesEditor(const Value: TMemo);
begin
  fFileAdditionalTypesEditor := Value;
  Database.FileAdditionalTypesEditor := Value;
end;

procedure tSigDBBFile.SetMemoPasSource(const Value: TMemo);
begin
  fMemoPasSource := Value;
  ShowPasSource;
end;

procedure tSigDBBFile.SetSigGeneralGridFind(const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  DataBase.SigGeneralGridFind := Value;
end;

procedure tSigDBBFile.SetSigGeneralGridIndexes(const Value: TSigGeneralGrid);
begin
  fSigGeneralGridIndexes := Value;
  Database.SigGeneralGridIndexes := Value;
end;

procedure tSigDBBFile.SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
begin
  fSigSpinEditIndexCount := Value;
  Database.SigSpinEditIndexCount := Value;
end;

procedure tSigDBBFile.SetSpeedButtonAddFindFunction(const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  Database.SpeedButtonAddFindFunction := Value;
end;

procedure tSigDBBFile.SetTabControlPasSources(const Value: TTabControl);
begin
  fTabControlPasSources := Value;
  if assigned( fTabControlPasSources ) then
  begin
    fTabControlPasSources.OnChange := OnTabControlPasSourcesChange;
    ShowPasSource;
  end;
end;

procedure tSigDBBFile.ShowPasSource;
begin
  if assigned( fTabControlPasSources ) then
  begin
    if assigned( MemoPasSource ) then
    begin
      case fTabControlPasSources.TabIndex of
        cTabRawFiles:
        begin
          BuildRawSource( MemoPasSource.Lines );
        end;
        cTabInterceptFiles:
        begin
          UpdateInterceptSource( MemoPasSource.Lines );
        end;
        cTabFileLists:
        begin
          BuildFileListsSource( MemoPasSource.Lines );
        end;
        cTabDatabase:
        begin
          UpdateDBSource( MemoPasSource.Lines );
        end;
      end;
    end;
  end;
end;

procedure tSigDBBFile.UpdateDBSource(const pLines: tStrings);
var
  i : integer;
begin
  (*
    we only create the DB file if it isn't there already.
    In this case we add our standard skeleton and treat as an update.

    The format of key lines (class definitions, implementation, uses,
    must not be modified - these are used to identify where to insert
    lines.
    We can insert database fields, always at the end of the first
    private section, and file interceptor classes, always at top of
    the classes list. We only add new interceptor classes - if the
    class already exists it is not added.
  *)
  if FileExists( PasDatabaseName.Value ) then
  begin
    pLines.LoadFromFile( PasDatabaseName.Value );
  end
  else
  begin
    BuildDBSkeleton( pLines );
  end;
  i := 0;
  UpdateDBSourceUnitName( i, pLines );
  UpdateDBSourceUsesClause( i, pLines );
  UpdateDBSourceClasses( i, pLines );
  UpdateDBSourceImplementation( i, pLines );
end;

procedure tSigDBBFile.UpdateDBSourceClasses(var i: integer;
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ) + ' ', 1, 5 ), 'type ') then
    begin
      inc( i );
      break;
    end;
    inc( i );
  end;
  DataBase.UpdateDBSourceClasses( i, pLines );
end;

procedure tSigDBBFile.UpdateDBSourceImplementation(var i: integer;
  const pLines: tStrings);
begin
  Database.UpdateDBSourceImplementation( i, pLines );
end;

procedure tSigDBBFile.UpdateDBSourceUnitName(var i: integer;
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ), 1, 5 ), 'Unit ') then
    begin
      // ensure unit Name is right
      pLines[ i ] := 'Unit ' +  DBUnitName + ';';
      inc( i );
      exit;
    end;
    inc( i );
  end;
end;

procedure tSigDBBFile.UpdateDBSourceUsesClause(var i: integer;
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ) + ' ', 1, 5 ), 'uses ') then
    begin
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( '{UnitDBRawFiles,}', pLines[ i ] ) <> 0 then
    begin
      pLines[ i ] := '  ' + RawUnitName + ', {UnitDBRawFiles,}';
    end
    else if Pos( '{UnitDBIntFiles,}', pLines[ i ] ) <> 0 then
    begin
      pLines[ i ] := '  ' + InterceptUnitName + ', {UnitDBIntFiles,}';
    end
    else if Pos( '{UnitDBFLFiles,}', pLines[ i ] ) <> 0 then
    begin
      pLines[ i ] := '  ' + FileListsUnitName + ', {UnitDBFLFiles,}';
    end
    else if Pos( ';', pLines[ i ] ) <> 0 then
    begin
      inc( i );
      exit;
    end;
    inc( i );
  end;
end;

procedure tSigDBBFile.UpdateInterceptSource(const pLines: tStrings);
var
  i : integer;
begin
  (*
    we only create the DB file if it isn't there already.
    In this case we add our standard skeleton and treat as an update.

    The format of key lines (class definitions, implementation, uses,
    must not be modified - these are used to identify where to insert
    lines.
    We can insert database fields, always at the end of the first
    private section, and file interceptor classes, always at top of
    the classes list. We only add new interceptor classes - if the
    class already exists it is not added.
  *)
  if FileExists( PasInterceptName.Value ) then
  begin
    pLines.LoadFromFile( PasInterceptName.Value );
  end
  else
  begin
    BuildInterceptSkeleton( pLines );
  end;
  i := 0;
  UpdateInterceptSourceUnitName( i, pLines );
  UpdateInterceptSourceUsesClause( i, pLines );
  UpdateInterceptSourceClasses( i, pLines );
end;

procedure tSigDBBFile.UpdateInterceptSourceClasses(var i: integer;
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ) + ' ', 1, 5 ), 'type ') then
    begin
      inc( i );
      break;
    end;
    inc( i );
  end;
  DataBase.UpdateInterceptSourceClasses( i, pLines );
end;

procedure tSigDBBFile.UpdateInterceptSourceUnitName(var i: integer;
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ), 1, 5 ), 'Unit ') then
    begin
      // ensure unit Name is right
      pLines[ i ] := 'Unit ' +  InterceptUnitName + ';';
      exit;
    end;
    inc( i );
  end;
end;

procedure tSigDBBFile.UpdateInterceptSourceUsesClause(var i: integer;
  const pLines: tStrings);
var
  iUsesLine : integer;
  iTest : string;
begin
  iUsesLine := i; // to satisfy compiler
  while i < pLines.Count do
  begin
    if SameText( copy( Trim( pLines[ i ] ) + ' ', 1, 5 ), 'uses ') then
    begin
      iUsesLine := i;
      break;
    end;
    inc( i );
  end;
  iTest := '{UnitDBRawFiles,}';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) <> 0 then
    begin
      pLines[ i ] := '  ' + RawUnitName + ', // {UnitDBRawFiles,}';
      break;
    end
    else if Pos( ';', pLines[ i ] ) <> 0 then
    begin
      // done and source not found so insert after uses line
      PLines.Insert( iUsesLine + 1, '  ' + RawUnitName + ', // {UnitDBRawFiles,}');
      inc( i, 2 );
      exit;
    end;
    inc( i );
  end;
  // source foud. go to end of list
  while i < pLines.Count do
  begin
    if Pos( ';', pLines[ i ] ) <> 0 then
    begin
      inc( i );
      exit;
    end;
    inc( i );
  end;
end;

function tSigDBBFile.FileListsUnitName: string;
begin
  Result := ExtractFileName( fPasFileListName.Value );
  Result := ChangeFileExt( Result, '' );
  if Result = '' then
  begin
    Result := 'UnitDBFileLists';
  end;
end;

function tSigDBBFile.RawUnitName: string;
begin
  Result := ExtractFileName( fPasFileName.Value );
  Result := ChangeFileExt( Result, '' );
  if Result = '' then
  begin
    Result := 'UnitDBRawFiles';
  end;
end;

procedure tSigDBBFile.RefreshEditors;
begin
  Database.RefreshEditors;
  ShowPasSource;
end;

procedure tSigDBBFile.RemoveEditors;
begin
  inherited;
  // no editors at this level
end;

{ tSigDBBField }

procedure tSigDBBField.AddConstDataInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('      c' + fFieldName.Value + ' = ' + fConstID.Value + ';');
  end;
end;

procedure tSigDBBField.AddMirrorGetterAndSetter(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '' );
    Add( '    function Get' + fFieldName.Value +' : ' + fFieldType.Value + ';' );
    Add( '    procedure Set' + fFieldName.Value + '(const Value: ' + fFieldType.Value + ');' );
  end;
end;

procedure tSigDBBField.AddMirrorImplementation(const pClassName : string; const pLines: tStrings);
begin
  with pLines do
  begin
    Add( 'function ' + pClassName + ' .Get' + fFieldName.Value + ' : ' + fFieldType.Value + ';' );
    Add( 'begin' );
    Add( '  Result := ' + DataFile.fBaseFileName.Value + 'Data.' + fFieldName.Value + ';' );
    Add( 'end;' );
    Add( '' );
    Add( 'procedure ' + pClassName + '.Set' + fFieldName.Value + '(const Value: ' + fFieldType.Value + ');' );
    Add( 'begin' );
    Add( '  ' + DataFile.fBaseFileName.Value + 'Data.' + fFieldName.Value + ' := Value;' );
    Add( 'end;' );
    Add( '' );
  end;
end;

procedure tSigDBBField.AddMirrorInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('    property ' + fFieldName.Value + ' : ' + fFieldType.Value);
    Add('             read Get' + fFieldName.Value);
    Add('             write  Set' + fFieldName.Value + ';');
  end;
end;

procedure tSigDBBField.AddPublicDataInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('    property ' + fFieldName.Value + ' : ' + fFieldType.Value);
    Add('             read Get' + fFieldName.Value);
    Add('             write  Set' + fFieldName.Value + ';');
  end;
end;

procedure tSigDBBField.AddSettersAndGetters(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '    function Get' + fFieldName.Value + ': ' + fFieldType.Value + ';' );
    Add( '    procedure Set' + fFieldName.Value +'(const Value: ' + fFieldType.Value + ');' );
  end;
end;

procedure tSigDBBField.AddSettersAndGettersImplementation( const pClassName : string;
  const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '' );
    Add( 'function ' + pClassName + '.Get' + fFieldName.Value + ': ' + fFieldType.Value + ';' );
    Add( 'begin' );
    Add( '  Result := fFields0.Rec.Data2.' + fFieldName.Value + ';' );
    Add( 'end;' );
    Add( '' );
    Add( 'procedure ' + pClassName + '.Set' + fFieldName.Value + '(const Value: ' + fFieldType.Value + ');' );
    Add( 'begin' );
    Add( '  fFields0.Rec.Data2.' + fFieldName.Value + ' := Value;' );
    //Add( '  fFields0RecNo := 0;' ); this line wrecks read-modify-write operations!
    Add( 'end;' );
  end;
end;

procedure tSigDBBField.AddRecInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    if Comment.Value = '' then
    begin
      Add('    ' + fFieldName.Value + ' : ' + fFieldType.Value + ';');
    end
    else
    begin
      Add('    ' + fFieldName.Value + ' : ' + fFieldType.Value + ';  // ' + Comment.Value );
    end;
  end;
end;

procedure tSigDBBField.BuildDataImplementation1a(const pLines: tStrings);
var
  iLine : string;
begin
  // case statements within CompareFieldDetail (Form 1)
  with pLines do
  begin
    iLine := '    c' + fFieldName.Value + ': Result := ';
    case self.fCompareStyle.ValueAsStyle of
      cs_None:    exit; // no comparison possible so will go to drop through
      cs_Numeric:        iLine := iLine + 'pRec1.' + fFieldName.Value + ' - ' + 'pRec2.' + fFieldName.Value + ';';
      cs_Enum:           iLine := iLine + 'Ord(pRec1.' + fFieldName.Value + ') - Ord(' + 'pRec2.' + fFieldName.Value + ');';
      cs_Text:           iLine := iLine + 'CompareText( string(pRec1.' + fFieldName.Value + '), string(pRec2.' + fFieldName.Value +') );';
      cs_String:         iLine := iLine + 'CompareStr( string(pRec1.' + fFieldName.Value + '), string(pRec2.' + fFieldName.Value +') );';
      cs_DateTime:       iLine := iLine + 'CompareDateTime( pRec1.' + fFieldName.Value + ', pRec2.' + fFieldName.Value +' );';
      cs_Set_Membership: iLine := iLine + 'Iff( pRec1.' + fFieldName.Value + ' = pRec2.' + fFieldName.Value +', 0, Iff( pRec1.' + fFieldName.Value + ' >= pRec2.' + fFieldName.Value +', 1, -1  ));';
      cs_boolean:        iLine := iLine + 'Iff( pRec1.' + fFieldName.Value + ' = pRec2.' + fFieldName.Value +', 0, Iff( pRec1.' + fFieldName.Value + ', 1, -1  ));';
      else               exit;
    end;
    Add( iLine );
  end;
end;

procedure tSigDBBField.BuildDataImplementation1b(const pLines: tStrings);
var
  iLine : string;
begin
  // case statements within CompareFieldDetail (Form 2)
  with pLines do
  begin
    iLine := '    c' + fFieldName.Value + ': Result := ';
    case self.fCompareStyle.ValueAsStyle of
      cs_None:           exit; // no comparison possible so will go to drop through
      cs_Numeric:        iLine := iLine + 'pRec.' + fFieldName.Value + ' - StrToInt( pFilter );';
      cs_Enum:           iLine := iLine + 'Ord(pRec.' + fFieldName.Value + ') - StrToInt( pFilter );';
      cs_Text:           iLine := iLine + 'CompareText( string(pRec.' + fFieldName.Value + '), pFilter );';
      cs_String:         iLine := iLine + 'CompareStr( string(pRec.' + fFieldName.Value + '), pFilter );';
      cs_DateTime:       iLine := iLine + 'Iff( IsNumeric( pFilter ), Round(pRec.' + fFieldName.Value + ') - StrToInt( pFilter ), CompareDateTime( pRec.' + fFieldName.Value + ', StrToDateTime( pFilter )));';
      cs_Set_Membership: iLine := '    c' + fFieldName.Value + ': raise exception.Create(''Invalid Set Comparison with Text'');'; // this form not valid in data files
      cs_boolean:        iLine := iLine + 'Iff( ' +fFieldName.Value + ', Iff( SameText( pFilter, ''TRUE''), 0, 1 ), Iff( SameText( pFilter, ''TRUE''), -1,0 ));';
      else               exit;
    end;
    Add( iLine );
  end;
end;

procedure tSigDBBField.BuildDataImplementation2(const pLines: tStrings);
var
  iLine : string;
begin
  // case statements within FieldAsText
  with pLines do
  begin
    iLine := '    c' + fFieldName.Value + ': Result := ';
    case self.fCompareStyle.ValueAsStyle of
      cs_None:           exit; // go to drop through
      cs_Numeric:        iLine := iLine + 'IntToStr(' + fFieldName.Value + ');';
      cs_Enum:           iLine := iLine + 'IntToStr(Ord(' + fFieldName.Value + '));';
      cs_Text:           iLine := iLine + 'string(' + fFieldName.Value + ');';
      cs_String:         iLine := iLine + 'string(' + fFieldName.Value + ');';
      cs_DateTime:       iLine := iLine + 'DateTimeToStr( ' + fFieldName.Value + ');';
      cs_Set_Membership: exit;
      else               exit;
    end;
    Add( iLine );
  end;

end;

procedure tSigDBBField.BuildDataImplementation3(const pLines: tStrings);
var
  iLine : string;
begin
  // case statements within FieldTitle
  with pLines do
  begin
    iLine := '    c' + fFieldName.Value + ': Result := ''';
    if fComment.Value <> '' then
    begin
      iLine := iLine + fComment.Value + ''';';
    end
    else
    begin
      iLine := iLine + fFieldName.Value + ''';';
    end;
    Add( iLine );
  end;

end;

procedure tSigDBBField.BuildDataImplementation4(const pLines: tStrings);
var
  iLine : string;
begin
  // case statements within TextToField
  with pLines do
  begin
    iLine := '    c' + fFieldName.Value + ': ' + fFieldName.Value + ' := ';
    case self.fCompareStyle.ValueAsStyle of
      cs_None:           exit; // go to drop through
      cs_Numeric:        iLine := iLine + 'StrToInt( Value );';
      cs_Enum:           iLine := iLine + fFieldType.Value + '(StrToInt( Value ));';
      cs_Text:           iLine := iLine + 'Value;';
      cs_String:         iLine := iLine + 'Value;';
      cs_DateTime:       iLine := iLine + 'StrToDateTime( Value );';
      cs_Set_Membership: exit;
      else               exit;
    end;
    Add( iLine );
  end;

end;

procedure tSigDBBField.Clear;
begin
  inherited;
  fConstID.ValueAsInt := StrToInt( Index );
end;

constructor tSigDBBField.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fConstID := tSigIntegerProperty.Create( 'Const ID', self );
  fFieldName := tSigTextProperty.Create( 'Field Name', self );
  fFieldType := tSigTextProperty.Create( 'Field Type', self );
  fCompareStyle := tSigDBBCompareProperty.Create( 'Compare Style', self );
  fComment := tSigTextProperty.Create( 'Comment', self );
end;

function tSigDBBField.GetDataFile: tSigDBBBaseFile;
begin
  Result := GetOwnerOfType( tSigDBBBaseFile ) as tSigDBBBaseFile;
end;

function tSigDBBField.ParmText: string;
begin
  Result := 'const p' + fFieldName.Value + ' : ' +  fFieldType.Value;
end;

{ tSigDBBFieldList }

procedure tSigDBBFieldList.AddConstInfo(const pLines: tStrings);
var
  i : integer;
begin
  with pLines do
  begin
    if Max >= 0 then
    begin
      Add('    const');
      for i := 0 to Max do
      begin
        DBField[ i ].AddConstDataInfo( pLines );
      end;
      Add('      cFieldCount = ' + IntToStr( Max + 1 ) + ';' );
    end;
  end;
end;

procedure tSigDBBFieldList.AddDataInfo(const pLines: tStrings);
var
  i : integer;
begin
  with pLines do
  begin
    for i := 0 to Max do
    begin
      DBField[ i ].AddPublicDataInfo( pLines );
    end;
    Add('');
    AddConstInfo( pLines );
      (*
      iParms := DBField[ 0 ].ParmText;
      for i := 1 to Max do
      begin
        iParms := iParms + '; ' + DBField[ i ].ParmText;
      end;
      Add('    function Add( ' + iParms + ' ) : tSigDBRecPointer;');
      Add('');
      No! This should be in index files area!
      *)
    Add('  end;');
    Add('');
  end;
end;

procedure tSigDBBFieldList.AddMirrorGettersAndSetters(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].AddMirrorGetterAndSetter( pLines );
  end;
end;

procedure tSigDBBFieldList.AddMirrorImplementation(const pClassName : string; const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].AddMirrorImplementation( pClassName, pLines );
  end;
end;

procedure tSigDBBFieldList.AddMirrorInfo(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].AddMirrorInfo( pLines );
  end;
end;

procedure tSigDBBFieldList.AddRecInfo(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].AddRecInfo( pLines );
  end;
end;

procedure tSigDBBFieldList.AddSettersAndGetters(const pLines: tStrings);
var
  i : integer;
begin
  for i := 0 to Max do
  begin
    DBfield[ i ].AddSettersAndGetters( pLines );
  end;
end;

procedure tSigDBBFieldList.AddSettersAndGettersImplementation( const pClassName : string;
  const pLines: tStrings);
var
  i : integer;
begin
  for i := 0 to Max do
  begin
    DBfield[ i ].AddSettersAndGettersImplementation( pClassName, pLines );
  end;
end;

procedure tSigDBBFieldList.BuildDataImplementation1a(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].BuildDataImplementation1a( pLines );
  end;
end;

procedure tSigDBBFieldList.BuildDataImplementation1b(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].BuildDataImplementation1b( pLines );
  end;
end;

procedure tSigDBBFieldList.BuildDataImplementation2(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].BuildDataImplementation2( pLines );
  end;
end;

procedure tSigDBBFieldList.BuildDataImplementation3(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].BuildDataImplementation3( pLines );
  end;
end;

procedure tSigDBBFieldList.BuildDataImplementation4(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    DBField[ i ].BuildDataImplementation4( pLines );
  end;
end;

procedure tSigDBBFieldList.BuildFieldsEditor;
var
  i: integer;
begin
  if assigned( fFieldsEditor ) then
  begin
    with fFieldsEditor do
    begin
      if Max < 0 then
      begin
        Visible := FALSE;
      end
      else
      begin
        Visible := TRUE;
        RowCount := Max + 2;
        DBField[ 0 ].fCompareStyle.AssignItemList( fFieldsEditor.Editor[ cColCompareType ].ItemsList );
        for i := 0 to Max do
        begin
          with DBField[ i ] do
          begin
            Cell[ cColID, i + 1 ] := ConstID.Value;
            Cell[ cColName, i + 1 ] := FieldName.Value;
            Cell[ cColType, i + 1 ] := FieldType.Value;
            Cell[ cColCompareType, i + 1 ] := CompareStyle.ValueAsText;
            Cell[ cColComment, i + 1 ] := Comment.Value;
          end;
        end;
      end;
    end;
  end;
end;

constructor tSigDBBFieldList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBBField );

end;

function tSigDBBFieldList.GetDBField(const i: integer): tSigDBBField;
begin
  Result := Entry[ i ] as tSigDBBField;
end;

function tSigDBBFieldList.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  Sort;
  BuildFieldsEditor;
end;

procedure tSigDBBFieldList.OnAddFieldClick(sender: TObject);
begin
  Max := Max + 1;
  BuildFieldsEditor;
end;

procedure tSigDBBFieldList.OnDeleteFieldClick(sender: TObject);
begin
   // we need to delete record and any indexes that reference it,
   if assigned( fFieldsEditor ) then
   begin
     with ChildArray do
     begin
       if fFieldsEditor.RowBeingEdited > 0 then
       begin
         Delete( fFieldsEditor.RowBeingEdited - 1 );
       end;
     end;
   end;
   BuildFieldsEditor;
end;

procedure tSigDBBFieldList.OnFieldEditorCellEditChange(const Sender: TObject;
  const Col, Row: integer; const Value: string);
begin
  if Row > 0 then
  begin
    case Col of
      cColID:
      begin
        DBField[ Row - 1 ].ConstID.Value := Value;
      end;
      cColName:
      begin
        DBField[ Row - 1 ].FieldName.Value := Value;
      end;
      cColType:
      begin
        DBField[ Row - 1 ].FieldType.Value := Value;
      end;
      cColCompareType:
      begin
        DBField[ Row - 1 ].CompareStyle.ValueAsText := Value;
      end;
      cColComment: // or Value
      begin
        DBField[ Row - 1 ].Comment.Value := Value;
      end;
    end;
  end;
end;

procedure tSigDBBFieldList.RefreshEditors;
begin
  BuildFieldsEditor;
end;

procedure tSigDBBFieldList.RemoveEditors;
begin
  inherited;

  FieldsEditor := nil;
  AddFieldButton := nil;
  DeleteFieldButton := nil;

end;

procedure tSigDBBFieldList.SetActiveChild(const Value: integer);
begin
  inherited;
  if assigned( fDeleteFieldButton ) then
  begin
    fDeleteFieldButton.Enabled := ActiveChild >= 0;
  end;
end;

procedure tSigDBBFieldList.SetAddFieldButton(const Value: TSpeedButton);
begin
  if assigned( fAddFieldButton ) then
  begin
    fAddFieldButton.OnClick := nil;
    fAddFieldButton.Enabled := FALSE;
  end;
  fAddFieldButton := Value;
  if assigned( fAddFieldButton ) then
  begin
    fAddFieldButton.OnClick := OnAddFieldClick;
    fAddFieldButton.Enabled := TRUE;
  end;
end;

procedure tSigDBBFieldList.SetDeleteFieldButton(const Value: TSpeedButton);
begin
  if assigned( fDeleteFieldButton ) then
  begin
    fDeleteFieldButton.OnClick := nil;
    fDeleteFieldButton.Enabled := FALSE;
  end;
  fDeleteFieldButton := Value;
  if assigned( fDeleteFieldButton ) then
  begin
    fDeleteFieldButton.OnClick := OnDeleteFieldClick;
    fDeleteFieldButton.Enabled := ActiveChild >= 0;
  end;
end;

procedure tSigDBBFieldList.SetFieldsEditor(const Value: TSigGeneralGrid);
begin
  if assigned( fFieldsEditor ) then
  begin
    fFieldsEditor.OnCellEditChange := nil;
    fFieldsEditor.OnMouseUp := nil;
  end;
  fFieldsEditor := Value;
  if assigned( fFieldsEditor ) then
  begin
    fFieldsEditor.OnCellEditChange := OnFieldEditorCellEditChange;
    fFieldsEditor.OnMouseUp := SigGeneralGridFieldsMouseUp;
  end;
  BuildFieldsEditor;
end;

procedure tSigDBBFieldList.SigGeneralGridFieldsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iRow, iCol : integer;
begin
  if Button = mbRight then
  begin
    fFieldsEditor.MouseToCell( X, Y, iCol, iRow );
    if MessageDlg( 'Are you sure that you want to delete field ' + fFieldsEditor.Cell[ cColName, iRow ] + '?',
                   mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes  then
    begin
      Delete( iRow - 1, undoDelete2 );
      BuildFieldsEditor;
    end;
  end;
end;

procedure tSigDBBFieldList.Sort;
  function CompareIDs( a, b : pointer ) : integer;
  var
    ia, ib : tSigDBBField;
  begin
    ia := tSigDBBField( a );
    ib := tSigDBBField( b );
    Result := ia.ConstID.ValueAsInt - ib.ConstID.ValueAsInt;
  end;
begin
  ChildArray.Children.Sort( @CompareIDs );
  BuildFieldsEditor;
end;

{ tSigDBBBaseFile }

procedure tSigDBBBaseFile.AddDataInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('  T' + fBaseFileName.Value + 'Data = class( tSigDBDataFile< T' + fBaseFileName.Value + 'Rec >)');
    Add('  private');
    Fields.AddSettersAndGetters( pLines );
    Add('  protected');
    Add('    //fFields0, fFields1, fFields2: ' + fBaseFileName.Value + 'Rec; // record structure defined in inherited classes');
    Add('  public');
    Add('');
    Add('    function CompareFieldDetail( const pFieldID : integer; pRec1, pRec2 : T' + fBaseFileName.Value + 'Rec ) : integer; overload; override;');
    Add('    function CompareFieldDetail( const pFieldID : integer; pRec : T' + fBaseFileName.Value + 'Rec; const pFilter : string ) : integer; overload; override;');
    Add('    function FieldAsText(const pFieldID: integer) : string; override;' );
    Add('    procedure TextToField( const pFieldID : integer; Value : string ); override;' );
    Add('    function FieldTitle(const pFieldID: integer) : string; override;' );
    Add('    function FieldCount : integer; override;' );
    Add('');
    Fields.AddDataInfo( pLines );
  end;
end;

procedure tSigDBBBaseFile.AddDataListConstructor(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '  f' + fBaseFileName.Value + 'Data := T' + fBaseFileName.Value + 'Data.Create( ''' + fBaseFileName.Value + ''', fDatabase );' );
    Add( '  Add( f' + fBaseFileName.Value + 'Data );' );
  end;
end;

procedure tSigDBBBaseFile.AddDBIndexFileListImplementation( const IndexFileListName : string;
  const pLines: tStrings);
begin
  IndexFiles.AddDBIndexFileListImplementation( IndexFileListName, pLines );
end;

procedure tSigDBBBaseFile.AddDBIndexFileListProperties(const pLines: tStrings);
begin
  IndexFiles.AddDBIndexProperties( pLines );
end;

procedure tSigDBBBaseFile.AddDBIndexFileListSetters(const pLines: tStrings);
begin
  IndexFiles.AddDBIndexSetters( pLines );
end;

procedure tSigDBBBaseFile.AddDBIndexFileListSources(const pLines: tStrings);
begin
  IndexFiles.AddDBIndexSources( pLines );
end;

procedure tSigDBBBaseFile.AddDataFileListProperty(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '    property ' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data');
    Add( '             read f' + fBaseFileName.Value + 'Data;');
  end;
end;

procedure tSigDBBBaseFile.AddConstInfo(const pLines: tStrings);
begin
  Fields.AddConstInfo( pLines );
end;

procedure tSigDBBBaseFile.AddDataFileListField(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '    f' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data;');
  end;
end;

procedure tSigDBBBaseFile.AddHeaderInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('  //----------------------------------- ' + fBaseFileName.Value + ' ------------------------------');
    Add('');
  end;
  fAdditionalTypes.AddTo( pLines );
end;

procedure tSigDBBBaseFile.AddIndexListImplementation(const IndexFileListName: string;
  const pLines: tStrings);
begin
  IndexFiles.AddDBIndexFileListImplementation( IndexFileListName, pLines );
end;

procedure tSigDBBBaseFile.AddMirrorGettersAndSetters(const pLines: tStrings);
begin
  fFields.AddMirrorGettersAndSetters( pLines );
end;

procedure tSigDBBBaseFile.AddMirrorImplementation(const pClassName : string; const pLines: tStrings);
begin
  fFields.AddMirrorImplementation( pClassName, pLines );
end;

procedure tSigDBBBaseFile.AddMirrorInfo(const pLines: tStrings);
begin
  fFields.AddMirrorInfo( pLines );
end;

procedure tSigDBBBaseFile.AddRecInfo(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('  T' + fBaseFileName.Value + 'Rec = packed record');
    fFields.AddRecInfo( pLines );
    Add('  end;');
    Add('');
  end;
end;

procedure tSigDBBBaseFile.BuildDataFileListConstructor(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '  f' + fBaseFileName.Value + 'Data := T' + fBaseFileName.Value + 'Data.Create( ''' + fBaseFileName.Value + ''', fDatabase );' );
    Add( '  Add( f' + fBaseFileName.Value + 'Data );' );
  end;
end;

procedure tSigDBBBaseFile.BuildDataImplementation(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '{ T' + fBaseFileName.Value + 'Data }' );
    Add( '' );
    Add( 'function T' + fBaseFileName.Value + 'Data.CompareFieldDetail(const pFieldID: integer;' );
    Add( '  pRec1, pRec2: T' + fBaseFileName.Value + 'Rec): integer;' );
    Add( 'begin' );
    Add( '  case pFieldID of' );
    Fields.BuildDataImplementation1a( pLines );
    Add( '    else' );
    Add( '    begin' );
    Add( '      Result := 0;' );
    Add( '    end;' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    Add( '');
    Add( 'function T' + fBaseFileName.Value + 'Data.CompareFieldDetail(const pFieldID: integer;' );
    Add( '  pRec: T' + fBaseFileName.Value + 'Rec; const pFilter : string): integer;' );
    Add( 'begin' );
    Add( '  case pFieldID of' );
    Fields.BuildDataImplementation1b( pLines );
    Add( '    else' );
    Add( '    begin' );
    Add( '      Result := 0;' );
    Add( '    end;' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
  //  function FieldAsText( const pFieldID : integer ) : string; virtual;
    Add( 'function T' + fBaseFileName.Value + 'Data.FieldAsText(const pFieldID: integer) : string;' );
    Add( 'begin' );
    Add( '  case pFieldID of' );
    Fields.BuildDataImplementation2( pLines );
    Add( '  else Result := '''';' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    Add( 'procedure T' + fBaseFileName.Value + 'Data.TextToField( const pFieldID : integer; Value : string );' );
    Add( 'begin' );
    Add( '  case pFieldID of' );
    Fields.BuildDataImplementation4( pLines );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    Add( 'function T' + fBaseFileName.Value + 'Data.FieldTitle(const pFieldID: integer) : string;' );
    Add( 'begin' );
    Add( '  case pFieldID of' );
    Fields.BuildDataImplementation3( pLines );
    Add( '  else Result := ''???'';' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    if Fields.Max >= 0 then
    begin
      Add( 'function T' + fBaseFileName.Value + 'Data.FieldCount : integer;' );
      Add( 'begin' );
      Add( '  Result := cFieldCount;' );
      Add( 'end;' );
      Add( '' );
    end;
    Fields.AddSettersAndGettersImplementation( 'T' + fBaseFileName.Value + 'Data', pLines );
  end;
end;

  { tSigDBBCompareProperty }

function tSigDBBCompareProperty.GetValueAsStyle: tSigDBBComparisonStyle;
begin
  Result := tSigDBBComparisonStyle( ValueAsInt );
end;

procedure tSigDBBCompareProperty.SetValueAsStyle(
  const Value: tSigDBBComparisonStyle);
begin
  ValueAsInt := Ord( Value );
end;

procedure tSigDBBBaseFile.BuildFileImplementation(const pLines: tStrings);
begin
  BuildDataImplementation( pLines );
  IndexFiles.AddIndexesImplementations( pLines );
end;

procedure tSigDBBBaseFile.BuildFileSource(const pLines: tStrings);
begin
  AddHeaderInfo( pLines );
  AddRecInfo( pLines );
  AddDataInfo( pLines );
  IndexFiles.AddIndexesClasses( pLines );
end;

procedure tSigDBBBaseFile.Clear;
begin
  inherited;
  fBaseFileName.Value := '<New>';
end;

constructor tSigDBBBaseFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fBaseFileName := tSigTextProperty.Create( 'Base File Name', self );
  fIntercept := TSigBooleanProperty.Create( 'Add Intercept?', self );
  fEncrypted := tSigBooleanProperty.Create( 'Encryped?', self );
  fAdditionalTypes := tMemoProperty.Create( 'Additional Types', self );
  fAdditionalPrivateMembers := tMemoProperty.Create( 'Additional Private Members', self );
  fAdditionalPublicMembers := tMemoProperty.Create( 'Additional Public Members', self );
  fFields := tSigDBBFieldList.Create( 'Fields', self );
  fIndexFiles := tSigDBBIndexFileList.Create( 'Index Files', self );

end;

function tSigDBBBaseFile.GetDatabase: tSigDBBDatabase;
begin
  Result := GetOwnerOfType( tSigDBBDatabase ) as tSigDBBDatabase;
end;

procedure tSigDBBBaseFile.InsertDBIndexProperties(i: integer;
  const pLines: tStrings);
begin
  IndexFiles.InsertDBIndexProperties( i, pLines );
end;

procedure tSigDBBBaseFile.InsertDBIndexSetters(i: integer;
  const pLines: tStrings);
begin
  IndexFiles.InsertDBIndexSetters( i, pLines );
end;

procedure tSigDBBBaseFile.InsertDBIndexSources(i: integer;
  const pLines: tStrings);
begin
  IndexFiles.InsertDBIndexSources( i, pLines );
end;

procedure tSigDBBBaseFile.InsertDBProperty(i: integer; const pLines: tStrings);
var
  iTest : string;
begin
  iTest := 'property ' + fBaseFileName.Value + 'Data';
  while i < pLines.Count  do
  begin
    if Pos( iTest, pLines[ i ] ) <> 0 then
    begin
      // found
      exit;
    end
    else if SameText( Trim( pLines[ i ]), 'end;') then
    begin
      // not found
      // '    property ' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data'
      // '             read f' + fBaseFileName.Value + 'Data;'
      pLines.Insert( i, '             read f' + fBaseFileName.Value + 'Data;');
      pLines.Insert( i, '    property ' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data' );
      // order of insertion reversed so that i does not need to change
    end;
    inc( i );
  end;
end;

procedure tSigDBBBaseFile.InsertDBSource(i: integer; const pLines: tStrings);
var
  iTestLine : string;
  iLastPublic : integer;
begin
  iTestLine := 'f' + fBaseFileName.Value + 'Data';
  iLastPublic := i;
  while i < pLines.Count do
  begin
    if Pos( iTestLine, pLines[ i ] ) <> 0 then
    begin
      // found
      exit;
    end
    else if SameText(Trim( pLines[ i ] ), 'public' )  then
    begin
      iLastPublic := i;
    end
    else if Pos( 'constructor', pLines[ i ]) <> 0 then
    begin
      // not found
      pLines.Insert( iLastPublic, '    f' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data;' );
    end;
    inc( i );
  end;
end;

function tSigDBBBaseFile.RawUnitName: string;
begin
  Result := (OwnerFile as tSigDBBFile).RawUnitName;
end;

procedure tSigDBBBaseFile.RefreshEditors;
begin
  fFields.RefreshEditors;
  IndexFiles.RefreshEditors;
end;

procedure tSigDBBBaseFile.RemoveEditors;
begin
  inherited;
  // no editors at this level.
end;

procedure tSigDBBBaseFile.SetAddFieldButton(const Value: TSpeedButton);
begin
  fAddFieldButton := Value;
  fFields.AddFieldButton := Value;
end;

procedure tSigDBBBaseFile.SetBaseFileNameEditor(const Value: TEdit);
begin
  fBaseFileNameEditor := Value;
  fBaseFileName.Editor := Value;
end;

procedure tSigDBBBaseFile.SetCheckBoxAddDataIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddDataIntercept := Value;
  fIntercept.Editor := Value;
end;

procedure tSigDBBBaseFile.SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  IndexFiles.CheckBoxAddIndexIntercept := Value;
end;

procedure tSigDBBBaseFile.SetCheckBoxMirrorDataFields(const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  IndexFiles.CheckBoxMirrorDataFields := Value;
end;

procedure tSigDBBBaseFile.SetDeleteFieldButton(const Value: TSpeedButton);
begin
  fDeleteFieldButton := Value;
  fFields.DeleteFieldButton := Value;
end;

procedure tSigDBBBaseFile.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  IndexFiles.EditIndexExtension := Value;
end;

procedure tSigDBBBaseFile.SetFieldsEditor(const Value: TSigGeneralGrid);
begin
  fFieldsEditor := Value;
  fFields.FieldsEditor := Value;
end;

procedure tSigDBBBaseFile.SetFileAdditionalPrivateMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPrivateMembersEditor := Value;
  fAdditionalPrivateMembers.Editor := Value;
end;

procedure tSigDBBBaseFile.SetFileAdditionalPublicMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPublicMembersEditor := Value;
  fAdditionalPublicMembers.Editor := Value;
end;

procedure tSigDBBBaseFile.SetFileAdditionalTypesEditor(const Value: TMemo);
begin
  fFileAdditionalTypesEditor := Value;
  fAdditionalTypes.Editor := Value;
end;

procedure tSigDBBBaseFile.SetSigGeneralGridFind(const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  IndexFiles.SigGeneralGridFind := Value;
end;

procedure tSigDBBBaseFile.SetSigGeneralGridIndexes(
  const Value: TSigGeneralGrid);
begin
  fSigGeneralGridIndexes := Value;
  IndexFiles.SigGeneralGridIndexes := Value;
end;

procedure tSigDBBBaseFile.SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
begin
  fSigSpinEditIndexCount := Value;
  IndexFiles.SigSpinEditIndexCount := Value;
end;

procedure tSigDBBBaseFile.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  IndexFiles.SpeedButtonAddFindFunction := Value;
end;

procedure tSigDBBBaseFile.UpdateDataListConstructor(i: integer;
  const pLines: tStrings);
var
  iTest : string;
begin
  iTest := 'f' + fBaseFileName.Value + 'Data :=';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      // done
      exit;
    end
    else if SameText( Trim( pLines[ i ] ), 'end;' ) then
    begin
{
    '  f' + fBaseFileName.Value + 'Data := T' + fBaseFileName.Value + 'Data.Create( ''' + fBaseFileName.Value + ''', fDatabase );'
    '  Add( f' + fBaseFileName.Value + 'Data );'
}
    pLines.Insert( i, '  Add( f' + fBaseFileName.Value + 'Data );');
    pLines.Insert( i, '  f' + fBaseFileName.Value + 'Data := T' + fBaseFileName.Value + 'Data.Create( ''' + fBaseFileName.Value + ''', fDatabase );');
    // Note reversed order of insertion
    end;
  end;

end;

procedure tSigDBBBaseFile.UpdateDBSourceClasses(i: integer;
  const pLines: tStrings);
var
  iLastPublic : integer;
begin
  iLastPublic := i;
  while i < pLines.Count do
  begin
    if Pos( 'f' + fBaseFileName.Value + 'Data : T', pLines[ i ]) <> 0 then
    begin
      // already exists!
      exit;
    end;
    if SameText( Trim( pLines[ i ] ), 'public') then
    begin
      iLastPublic := i;
    end;
    if Pos( 'constructor', pLines[ i ] ) <> 0  then
    begin
      // not found
      pLines.Insert( iLastPublic, '    f' + fBaseFileName.Value + 'Data : T' + fBaseFileName.Value + 'Data;' );
      exit;
    end;
    inc( i );
  end;
end;

{
procedure tSigDBBBaseFile.UpdateIndexListSetters(
  const IndexFileListName: string; i: integer; const pLines: tStrings);
begin
  IndexFiles.UpdateIndexListSetters( IndexFileListName, i, pLines );
end;
}

procedure tSigDBBBaseFile.UpdateIndexListConstructors(i: integer;
  const pLines: tStrings);
begin
  IndexFiles.UpdateIndexListConstructors( i, pLines );
end;

procedure tSigDBBBaseFile.UpdateInterceptSourceClass(const pClass: string;
  i: integer; const pLines: tStrings);
var
  iTest : string;
begin
  iTest := pClass + ' =';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      // already there
      exit;
    end
    else
    begin
      if SameText( Trim(pLines[ i ] ), 'implementation' ) then
      begin
        // not found
        with pLines do
        begin
{
      TxxxData = class( UnitDBRaw.TxxxData )' );
      private' );
      protected' );
      public' );
      end;' );
}
          Insert( i, '' );
          Insert( i, '  end;' );
          Insert( i, '  public' );
          Insert( i, '  protected' );
          Insert( i, '  private' );
          Insert( i, '  ' + iTest + ' class( ' + RawUnitName + '.' + pClass + ' )');
        end;
        exit;
      end;
    end;
    Inc( i );
  end;

end;

procedure tSigDBBBaseFile.UpdateInterceptSourceClasses(i: integer;
  const pLines: tStrings);
var
  j : integer;
begin
  if Intercept.ValueAsBool then
  begin
    UpdateInterceptSourceClass( 'T' + BaseFileName.Value + 'Data', i, pLines );
  end;
  with IndexFiles do
  begin
    for j := 0 to Max do
    begin
      with SigDBBIndexFile[ j ] do
      begin
        if Intercept.ValueAsBool then
        begin
          UpdateInterceptSourceClass( 'T' + FullName, i, pLines );
        end;
      end;
    end;
  end;
end;

{ tSigDBBaseFileList }

procedure tSigDBBaseFileList.AddDataListConstructors(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDataListConstructor( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddDBIndexFileListProperties(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDBIndexFileListProperties( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddDBIndexFileListSetters(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDBIndexFileListSetters( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddDBIndexFileListSources(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDBIndexFileListSources( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddDBProperties(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDataFileListProperty( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddDBSources(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddDBIndexFileListSources( pLines );
  end;
end;

procedure tSigDBBaseFileList.AddIndexListImplementation(const IndexFileName: string;
  const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BaseFile[ i ].AddIndexListImplementation( IndexFileName, pLines );
  end;
end;

function tSigDBBaseFileList.BaseName: string;
begin
  Result := Database.BaseName.Value;
end;

procedure tSigDBBaseFileList.BuildDataFileListImplementation(
  const pLines: tStrings);
var
  i: integer;
begin
  with pLines do
  begin
    Add( '{ T' + BaseName + 'DataFileList }' );
    Add( '' );
    Add( 'constructor T' + BaseName + 'DataFileList.Create(const pDatabase: tSigDBDatabase);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].BuildDataFileListConstructor( pLines );
{
    Add( '  fSurveyorPasswordsData := tSurveyorPasswordData.Create( 'Passwords', fDatabase );' );
    Add( '  Add( fSurveyorPasswordsData );' );
}
    end;
    Add( 'end;' );
    Add( '' );
  end;
end;

procedure tSigDBBaseFileList.BuildFileImplementation(const pLines: tStrings;
  pFile: integer);
begin
  if pFile < 0 then
  begin
    pFile := ActiveChild;
  end;
  BaseFile[ pFile ].BuildFileImplementation( pLines );
end;

procedure tSigDBBaseFileList.BuildFileSource(const pLines: tStrings;
  pFile: integer);
begin
  if pFile < 0 then
  begin
    pFile := ActiveChild;
  end;
  BaseFile[ pFile ].BuildFileSource( pLines );
end;

procedure tSigDBBaseFileList.BuildIndexFileListImplementation(
  const pLines: tStrings);
var
  i: integer;
begin
  with pLines do
  begin
    Add( '{ T' + BaseName + 'IndexFileList }' );
    Add( '' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDBIndexFileListImplementation( BaseName, pLines );
    end;
{
    Add( 'procedure tSurveyorIndexFileList.SetEventSequenceID(' );
    Add( '  const Value: TEventSequenceIDIndex);' );
    Add( 'begin' );
    Add( '  Reassign( tSigDBIndexFile(fEventSequenceIDIndex), Value );' );
    Add( 'end;' );
    Add( '' );
}
  end;
end;

procedure tSigDBBaseFileList.BuildPasFileListsImplementation(
  const pLines: tStrings);
begin
  BuildDataFileListImplementation( pLines );
  BuildIndexFileListImplementation( pLines );

  {
  for i := 0 to Max do
  begin
    BaseFile[ i ].BuildPasFileListsImplementation( pLines, i );
  end;
  }
end;

procedure tSigDBBaseFileList.BuildPasFileListsSource(const pLines: tStrings);
var
  i: Integer;
begin
  with pLines do
  begin
    Add( '  T' + BaseName +'DataFileList = class( TSigDBDataFileList )' );
    Add( '  private' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDataFileListField( pLines );
    end;
    Add( '  public' );
    Add( '' );
    Add( '    constructor Create( const pDatabase : TSigDBDatabase ); override;' );
    Add( '' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDataFileListProperty( pLines );
    end;
    Add( '  end;' );
    Add( '' );
    Add( '  T' + BaseName +'IndexFileList = class( TSigDBIndexFileList )' );
    Add( '  private' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDBIndexFileListSources( pLines );
    end;
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDBIndexFileListSetters( pLines );
    end;
    Add( '  public' );
    Add( '' );
    for i := 0 to Max do
    begin
      BaseFile[ i ].AddDBIndexFileListProperties( pLines );
    end;
    Add( '' );
    Add( '  end;' );
    Add( '' );
  end;
end;

procedure tSigDBBaseFileList.BuildPasImplementation(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BuildFileImplementation( pLines, i );
  end;
end;

procedure tSigDBBaseFileList.BuildPasSource(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    BuildFileSource( pLines, i );
  end;
end;

constructor tSigDBBaseFileList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBBBaseFile );

end;

function tSigDBBaseFileList.GetBaseFile(const i: integer): tSigDBBBaseFile;
begin
  Result := Entry[ i ] as tSigDBBBaseFile;
end;

function tSigDBBaseFileList.GetDatabase: tSigDBBDatabase;
begin
  Result := GetOwnerOfType( tSigDBBDatabase ) as tSigDBBDatabase;
end;

procedure tSigDBBaseFileList.InsertDBIndexProperties(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].InsertDBIndexProperties( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.InsertDBIndexSetters(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].InsertDBIndexSetters( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.InsertDBIndexSources(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].InsertDBIndexSources( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.InsertDBProperties(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].InsertDBProperty( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.InsertDBSources(i: integer;
  const pLines: tStrings);
var
  j : integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].InsertDBSource( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.RefreshEditors;
begin
  if (ActiveChild >= 0) and (ActiveChild <= Max ) then
  begin
    BaseFile[ ActiveChild ].RefreshEditors;
  end;
end;

procedure tSigDBBaseFileList.SetActiveChild(const pValue: integer);
begin
  if (ActiveChild >= 0) and (ActiveChild <= Max ) then
  begin
    // remove editors
    with BaseFile[ ActiveChild ] do
    begin
      BaseFileNameEditor := nil;
      FileAdditionalTypesEditor := nil;
      FieldsEditor := nil;
      AddFieldButton := nil;
      DeleteFieldButton := nil;
      FileAdditionalPrivateMembersEditor := nil;
      FileAdditionalPublicMembersEditor := nil;
      EditIndexExtension := nil;
      SigGeneralGridIndexes := nil;
      SigSpinEditIndexCount := nil;
      SigGeneralGridFind := nil;
      SpeedButtonAddFindFunction := nil;
      CheckBoxMirrorDataFields := nil;
      CheckBoxAddDataIntercept := nil;
      CheckBoxAddIndexIntercept := nil;
    end;
  end;
  inherited;
  if ActiveChild >= 0 then
  begin
    // add editors
    with BaseFile[ ActiveChild ] do
    begin
      BaseFileNameEditor := self.BaseFileNameEditor; // self required here
      FileAdditionalTypesEditor := self.FileAdditionalTypesEditor; // self required here
      FieldsEditor := self.FieldsEditor; // self required here
      AddFieldButton := self.AddFieldButton; // self required here
      DeleteFieldButton := self.DeleteFieldButton; // self required here
      FileAdditionalPrivateMembersEditor := self.FileAdditionalPrivateMembersEditor; // self required here
      FileAdditionalPublicMembersEditor := self.FileAdditionalPublicMembersEditor; // self required here
      EditIndexExtension := self.EditIndexExtension; // self required here
      SigGeneralGridIndexes := self.SigGeneralGridIndexes; // self required here
      SigSpinEditIndexCount := self.SigSpinEditIndexCount; // self required here
      SigGeneralGridFind := self.SigGeneralGridFind; // self required here
      SpeedButtonAddFindFunction := self.SpeedButtonAddFindFunction; // self required here
      CheckBoxMirrorDataFields := self.CheckBoxMirrorDataFields; // self required here
      CheckBoxAddDataIntercept := self.CheckBoxAddDataIntercept; // self required here
      CheckBoxAddIndexIntercept := self.CheckBoxAddIndexIntercept; // self required here
    end;
  end
  else
  begin
    DeleteFieldButton.Enabled := FALSE;
  end;
end;

procedure tSigDBBaseFileList.SetAddFieldButton(const Value: TSpeedButton);
begin
  fAddFieldButton := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].AddFieldButton := Value;
  end;
end;

procedure tSigDBBaseFileList.SetBaseFileNameEditor(const Value: TEdit);
begin
  fBaseFileNameEditor := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].BaseFileNameEditor := Value;
  end;
end;

procedure tSigDBBaseFileList.SetCheckBoxAddDataIntercept(
  const Value: TCheckBox);
begin
  fCheckBoxAddDataIntercept := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].CheckBoxAddDataIntercept := Value;
  end;
end;

procedure tSigDBBaseFileList.SetCheckBoxAddIndexIntercept(
  const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].CheckBoxAddIndexIntercept := Value;
  end;
end;

procedure tSigDBBaseFileList.SetCheckBoxMirrorDataFields(
  const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].CheckBoxMirrorDataFields := Value;
  end;
end;

procedure tSigDBBaseFileList.SetDeleteFieldButton(const Value: TSpeedButton);
begin
  fDeleteFieldButton := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].DeleteFieldButton := Value;
  end
  else
  begin
    fDeleteFieldButton.Enabled := FALSE;
  end;
end;

procedure tSigDBBaseFileList.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].EditIndexExtension := Value;
  end;
end;

procedure tSigDBBaseFileList.SetFieldsEditor(const Value: TSigGeneralGrid);
begin
  fFieldsEditor := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].FieldsEditor := Value;
  end;
end;

procedure tSigDBBaseFileList.SetFileAdditionalPrivateMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPrivateMembersEditor := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].FileAdditionalPrivateMembersEditor := Value;
  end;
end;

procedure tSigDBBaseFileList.SetFileAdditionalPublicMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPublicMembersEditor := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].FileAdditionalPublicMembersEditor := Value;
  end;
end;

procedure tSigDBBaseFileList.SetFileAdditionalTypesEditor(const Value: TMemo);
begin
  fFileAdditionalTypesEditor := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].FileAdditionalTypesEditor := Value;
  end;
end;

procedure tSigDBBaseFileList.SetSigGeneralGridFind(
  const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].SigGeneralGridFind := Value;
  end;
end;

procedure tSigDBBaseFileList.SetSigGeneralGridIndexes(
  const Value: TSigGeneralGrid);
begin
  fSigGeneralGridIndexes := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].SigGeneralGridIndexes := Value;
  end;
end;

procedure tSigDBBaseFileList.SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
begin
  fSigSpinEditIndexCount := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].SigSpinEditIndexCount := Value;
  end;
end;

procedure tSigDBBaseFileList.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  if ActiveChild >= 0 then
  begin
    BaseFile[ ActiveChild ].SpeedButtonAddFindFunction := Value;
  end;
end;

procedure tSigDBBaseFileList.UpdateDataListConstructors(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].UpdateDataListConstructor( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.UpdateDBSourceClasses(var i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].UpdateDBSourceClasses( i, pLines );
    BaseFile[ j ].IndexFiles.UpdateDBSourceClasses( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.UpdateIndexListConstructors(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].UpdateIndexListConstructors( i, pLines );
  end;
end;

procedure tSigDBBaseFileList.UpdateInterceptSourceClasses(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    BaseFile[ j ].UpdateInterceptSourceClasses( i, pLines );
  end;
end;

{ tSigDBBDatabase }

procedure tSigDBBDatabase.BuildDBImplementation(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '{ T' + BaseName.Value + 'DataFileList }' );
    Add( '' );
    Add( 'constructor T' + BaseName.Value + 'DataFileList.Create(const pDatabase: TSigDBDatabase);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '' );
    Files.AddDataListConstructors( pLines );
    Add( 'end;' );
    Add( '' );
  end;
end;

procedure tSigDBBDatabase.BuildDBSource(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '' );
    Add( '  //=============================================================================');
    Add( '' );
    Add( '  //----------------------------- Database --------------------------------------');
    Add( '' );
    Add( '  T' + BaseName.Value + 'DB = class( tSigDBDatabase )');
    Add( '  private');
    Add( '    function GetDataFiles: T' + BaseName.Value + 'DataFileList;');
    Add( '    function GetIndexFiles: T' + BaseName.Value + 'IndexFileList;');
    Add( '  protected');
    Add( '  public');
    Add( '    constructor Create( const pPath : string ); override;');
    Add( '');
    Add( '    property DataFiles : T' + BaseName.Value + 'DataFileList');
    Add( '             read GetDataFiles;');
    Add( '    property IndexFiles : T' + BaseName.Value + 'IndexFileList');
    Add( '             read GetIndexFiles;');
    Add( '');
    Add( '    procedure Log( const pEvent : string );');
    Add( '  end;');
    Add( '');
  end;
end;

procedure tSigDBBDatabase.BuildFileImplementation(const pLines: tStrings);
begin
  Files.BuildFileImplementation( pLines )
end;

procedure tSigDBBDatabase.BuildFileSource(const pLines: tStrings );
begin
  Files.BuildFileSource( pLines );
end;

procedure tSigDBBDatabase.BuildPasImplementation(const pLines: tStrings);
begin
  Files.BuildPasImplementation( pLines );
  BuildDBImplementation( pLines );
end;

procedure tSigDBBDatabase.BuildPasSource(const pLines: tStrings);
begin
  Files.BuildPasSource( pLines );
  BuildDBSource( pLines );
end;

constructor tSigDBBDatabase.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fBaseName := tSigTextProperty.Create( 'Base Name', self );
  fFiles := tSigDBBaseFileList.Create( 'Files', self );
end;

procedure tSigDBBDatabase.RefreshEditors;
begin
  Files.RefreshEditors;
end;

procedure tSigDBBDatabase.RemoveEditors;
begin
  inherited;
  // no editors at this level
end;

procedure tSigDBBDatabase.SetAddFieldButton(const Value: TSpeedButton);
begin
  fAddFieldButton := Value;
  Files.AddFieldButton := Value;
end;

procedure tSigDBBDatabase.SetBaseFileNameEditor(const Value: TEdit);
begin
  fBaseFileNameEditor := Value;
  Files.BaseFileNameEditor := Value;
end;

procedure tSigDBBDatabase.SetCheckBoxAddDataIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddDataIntercept := Value;
  Files.CheckBoxAddDataIntercept := Value;
end;

procedure tSigDBBDatabase.SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  Files.CheckBoxAddIndexIntercept := Value;
end;

procedure tSigDBBDatabase.SetCheckBoxMirrorDataFields(const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  Files.CheckBoxMirrorDataFields := Value;
end;

procedure tSigDBBDatabase.SetDBBaseNameEditor(const Value: TEdit);
begin
  fDBBaseNameEditor := Value;
  fBaseName.Editor := Value;
end;

procedure tSigDBBDatabase.SetDeleteFieldButton(const Value: TSpeedButton);
begin
  fDeleteFieldButton := Value;
  Files.DeleteFieldButton := Value;
end;

procedure tSigDBBDatabase.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  Files.EditIndexExtension := Value;
end;

procedure tSigDBBDatabase.SetFieldsEditor(const Value: TSigGeneralGrid);
begin
  fFieldsEditor := Value;
  Files.FieldsEditor := Value;
end;

procedure tSigDBBDatabase.SetFileAdditionalPrivateMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPrivateMembersEditor := Value;
  Files.FileAdditionalPrivateMembersEditor := Value;
end;

procedure tSigDBBDatabase.SetFileAdditionalPublicMembersEditor(
  const Value: TMemo);
begin
  fFileAdditionalPublicMembersEditor := Value;
  Files.FileAdditionalPublicMembersEditor := Value;
end;

procedure tSigDBBDatabase.SetFileAdditionalTypesEditor(const Value: TMemo);
begin
  fFileAdditionalTypesEditor := Value;
  Files.FileAdditionalTypesEditor := Value;
end;

procedure tSigDBBDatabase.SetSigGeneralGridFind(const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  Files.SigGeneralGridFind := Value;
end;

procedure tSigDBBDatabase.SetSigGeneralGridIndexes(
  const Value: TSigGeneralGrid);
begin
  fSigGeneralGridIndexes := Value;
  Files.SigGeneralGridIndexes := Value;
end;

procedure tSigDBBDatabase.SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
begin
  fSigSpinEditIndexCount := Value;
  Files.SigSpinEditIndexCount := Value;
end;

procedure tSigDBBDatabase.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  Files.SpeedButtonAddFindFunction := Value;
end;

procedure tSigDBBDatabase.UpdateDBSourceClasses(var i: integer;     // on entry, i is just after 'type' clause
  const pLines: tStrings);
begin
  while i < pLines.Count do
  begin
    if Pos( 'class( TSigDBDatabase )', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '  T' + BaseName.Value + 'DB = class( TSigDBDatabase )';
      inc( i );
      break;
    end;
    inc( i );
  end;
  {
    Add( '  private');
  }
  while i < pLines.Count do
  begin
    if Pos( 'function GetDataFiles', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '    function GetDataFiles: T' + BaseName.Value + 'DataFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'function GetIndexFiles', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '    function GetIndexFiles: T' + BaseName.Value + 'IndexFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'property DataFiles', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '    property DataFiles : T' + BaseName.Value + 'DataFileList';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'property IndexFiles', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '    property IndexFiles : T' + BaseName.Value + 'IndexFileList';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if SameText( Trim( pLines[ i ] ), 'implementation' ) then
    begin
      break;
      // implementation MUST be on own line!
    end;
    inc( i );
  end;
end;

procedure tSigDBBDatabase.UpdateDBSourceImplementation(var i: integer;
  const pLines: tStrings);
var
  iTest : string;
begin

  // database
  while i < pLines.Count do
  begin
    if Pos( 'DB }', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '{ T' + BaseName.Value + 'DB }';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'DB.Create', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := 'constructor T' + BaseName.Value + 'DB.Create(const pPath: string);';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'DataFileList.Create', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '  fDataFiles  := T' + BaseName.Value + 'DataFileList.Create( self ); // set by descendants';
      inc( i );
      break;
    end;
    inc( i );
  end;
  while i < pLines.Count do
  begin
    if Pos( 'IndexFileList.Create', pLines[ i ] ) <> 0 then  // NOTE We do NOT syntax check for optional spaces, so do NOT REFORMAT!
    begin
      //make sure correct
      pLines[ i ] := '  fIndexFiles  := T' + BaseName.Value + 'IndexFileList.Create( self ); // set by descendants';
      inc( i );
      // ensure creation lines are all correct.
      Files.UpdateIndexListConstructors( i, pLines );
      break;
    end;
    inc( i );
  end;
  iTest := 'DB.GetDataFiles';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      pLines[ i ] := 'function T' + BaseName.Value + 'DB.GetDataFiles: T' + BaseName.Value + 'DataFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  iTest := 'fDataFiles';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      pLines[ i ] := '  Result := fDataFiles as T' + BaseName.Value + 'DataFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  iTest := 'DB.GetIndexFiles';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      pLines[ i ] := 'function T' + BaseName.Value + 'DB.GetIndexFiles: T' + BaseName.Value + 'IndexFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  iTest := 'fIndexFiles';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      pLines[ i ] := '  Result := fIndexFiles as T' + BaseName.Value + 'IndexFileList;';
      inc( i );
      break;
    end;
    inc( i );
  end;
  iTest := 'DB.Log';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      pLines[ i ] := 'procedure T' + BaseName.Value + 'DB.Log(const pEvent: string);';
      inc( i );
      break;
    end;
    inc( i );
  end;
end;

procedure tSigDBBDatabase.UpdateInterceptSourceClasses(var i: integer;
  const pLines: tStrings);
begin
  Files.UpdateInterceptSourceClasses( i, pLines );
end;

{ tSigDBBFieldPointer }

procedure tSigDBBFieldPointer.BuildAllowableNames(const pValue: TStrings);
var
  i : integer;
begin
  pValue.Clear;
  begin
    with DestinationList do
    begin
      for i := 0 to Count - 1 do
      begin
        with Item[ i ] as tSigDBBField do
        begin
          pValue.Add( FieldName.Value )
        end;
      end;
    end;
  end;
end;

function tSigDBBFieldPointer.GetCellText: string;
begin
  if assigned( DBBField ) then
  begin
    Result := DBBField.FieldName.Value;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigDBBFieldPointer.GetDBBField: tSigDBBField;
begin
  Result := DestinationObject as tSigDBBField;
end;

procedure tSigDBBFieldPointer.OnInterestedPartyDestroy(
  const pParty: tSigBaseProperty);
begin
  inherited;
  if Owner is tSigDBIndexField then
  begin
    (Owner as tSigDBIndexField).RemoveSelf;
  end;
end;

procedure tSigDBBFieldPointer.SetCellText(const pValue: string);
var
  i : integer;
begin
  if pValue = '' then
  begin
    DBBField := nil;
  end
  else
  begin
    with DestinationList do
    begin
      for i := 0 to Count - 1 do
      begin
        with Items[ i ] as tSigDBBField do
        begin
          if SameText( pValue, FieldName.Value ) then
          begin
            DBBField := Items[ i ] as tSigDBBField;
            exit;
          end;
        end;
      end;
      // else
      raise Exception.Create('Field not found!');
    end;
  end;
end;

procedure tSigDBBFieldPointer.SetDBBField(const Value: tSigDBBField);
begin
  DestinationObject := Value;
end;

{ tSigDBIndexField }

constructor tSigDBIndexField.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fDBBField := tSigDBBFieldPointer.Create( 'Data File Field', self, DataFile.Fields.ChildArray.Children );
  fFilter := tSigDBIndexFilter.Create( 'Filter', self );
  fCompareValue := tSigTextProperty.Create( 'Compare with', self );
end;

{ tSigDBIndexList }

procedure tSigDBBIndexFile.AddAppendDef(const pLines: TStrings);
var
  i : integer;
  iLine, iLine2 : string;
  iNeedsSemicolon : boolean;
begin
  with pLines do
  begin
    Add( '' );
    iLine := '    function AppendData( ';
    iNeedsSemicolon := FALSE;
    for i := 0 to DataFile.Fields.Max do
    begin
      if iNeedsSemicolon then
      begin
        iLine := iLine + '; ';
      end
      else
      begin
        iNeedsSemicolon := TRUE;
      end;
      with DataFile.Fields.DBField[ i ] do
      begin
        iLine2 := 'p' + FieldName.Value + ' : ' + FieldType.Value;
      end;
      if (Length( iLine ) + Length( iLine2 )) > 110 then
      begin
        Add( iLine );
        iLine := '             ' + iLine2;
      end
      else
      begin
        iLine := iLine + iLine2;
      end;
    end;
    Add( iLine + ' ) : tSigDBRecPointer; overload;' );
  end;
end;

procedure tSigDBBIndexFile.AddUpdateDef(const pLines: TStrings);
var
  i : integer;
  iLine, iLine2 : string;
begin
  with pLines do
  begin
    Add( '' );
    iLine := '    procedure UpdateData( const pRec : TSigDBRecPointer';
    for i := 0 to DataFile.Fields.Max do
    begin
      iLine := iLine + '; ';
      with DataFile.Fields.DBField[ i ] do
      begin
        iLine2 := 'p' + FieldName.Value + ' : ' + FieldType.Value;
      end;
      if (Length( iLine ) + Length( iLine2 )) > 110 then
      begin
        Add( iLine );
        iLine := '             ' + iLine2;
      end
      else
      begin
        iLine := iLine + iLine2;
      end;
    end;
    Add( iLine + ' ); overload;' );
  end;
end;

procedure tSigDBBIndexFile.AddClassDef(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '  T' + FullName + ' = class( tSigDBIndexFile )' );
    Add( '  private' );
    AddDBFileGetter( pLines );
    if MirrorDataFields.ValueAsBool then
    begin
      AddMirrorGettersAndSetters( pLines );
    end;
    Add( '  public' );
    Add( '    constructor Create( const pName : string; const pDatabase : tSigDBDatabase; const pDataFile : tSigDBFileBase ); override;' );
    Add( '' );
    AddDBFileDef( pLines );
    Add( '' );
    AddAppendDef( pLines );
    AddUpdateDef( pLines );
    Add( '' );
    AddFindDefs( pLines );
    Add( '' );
    if MirrorDataFields.ValueAsBool then
    begin
      AddMirrorDefs( pLines );
    end;
    Add( '  end;' );
    Add( '' );
  end;
end;

procedure tSigDBBIndexFile.AddClassFieldDefs(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    // do we need an field class entry?
    with IndexField[ i ] do
    begin
      case Filter.ValueAsSigDBFieldType of
        ft_Filter_in, ft_Filter_not_in:
        begin
          // yes; filter is on a set
          with pLines do
          begin
            Add( '  T' + FullName + 'Field' + IntToStr(i) + ' = class( tSigDBIndexField )' );
            Add( '  public' );
            Add( '    function FieldValid( const pDBRec : tSigDBRecPointer ) : boolean; override; // checks filters' );
            Add( '  end;' );
            Add( '' );
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigDBBIndexFile.AddClassFieldImplementations(const pLines: tStrings);
var
  i : integer;
begin
  for i := 0 to Max do
  begin
    // do we need an field class entry?
    with IndexField[ i ] do
    begin
      case Filter.ValueAsSigDBFieldType of
        ft_Filter_in, ft_Filter_not_in:
        begin
          with pLines do
          begin
            Add( '{ T' + FullName + 'Field' + IntToStr(i) + ' }' );
            Add( '' );
            Add( 'function T' + FullName + 'Field' + IntToStr(i) + '.FieldValid( const pDBRec : tSigDBRecPointer ) : boolean;' );
            Add( 'var' );
            Add( '  iSaveRec : tSigDBRecPointer;' );
            Add( 'begin' );
            Add( '  with (Owner.DataFile as T' + DataFile.BaseFileName.Value + 'Data) do' );
            Add( '  begin' );
            Add( '    Lock;' );
            Add( '    try' );
            Add( '      iSaveRec := CurrRec;' );
            Add( '      Read( pDBRec );' );
            Add( '      Result := ' + CompareValue.Value + ' in ' + DBBField.CellText + ';' );
            Add( '      Read( iSaveRec );' );
            Add( '    finally' );
            Add( '      Owner.DataFile.Unlock;' );
            Add( '    end;' );
            Add( '  end;' );
            Add( 'end;' );
            Add( '' );
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigDBBIndexFile.AddClassImplementation(const pLines: tStrings);
var
  i : integer;
  iFieldString : string;
  iLine, iLine2 : string;
  iNeedsSemicolon : boolean;
begin
  with pLines do
  begin
    Add( '{ T' + FullName + ' }' );
    Add( '' );
    Add( 'constructor T' + FullName + '.Create(const pName : string; const pDatabase: tSigDBDatabase;' );
    Add( '  const pDataFile: tSigDBFileBase);' );
    Add( 'begin' );
    Add( '  inherited;' );
    Add( '  // add indexes' );
    Add( '  {' );
    DataFile.Fields.AddConstInfo( pLines );
    Add( '  }' );
    Add( '  with Fields do' );
    Add( '  begin' );
    for i := 0 to Max do
    begin
      with IndexField[ i ] do
      begin
        if assigned( DBBField.DBBField ) then
        begin
          case Filter.ValueAsSigDBFieldType of
            ft_Filter_in, ft_Filter_not_in:
            begin
              iFieldString := 'T' + FullName + 'Field' + IntToStr(i);
            end;
            else
            begin
              iFieldString := 'TSigDBIndexField';
            end;
          end;
          case Filter.ValueAsSigDBFieldType of
            ft_Filter_LT,
            ft_Filter_LE,
            ft_Filter_EQ,
            ft_Filter_NE,
            ft_Filter_GE,
            ft_Filter_GT,
            ft_Filter_in,
            ft_Filter_not_in,
            ft_Filter_Changed:
            begin
              case DBBField.DBBField.CompareStyle.ValueAsStyle of
                cs_None:
                begin
                  //raise Exception.Create('No comparison method specified for field ' + DBBField.DBBField.FieldName.Value);
                end;
                //cs_Numeric: ;  default OK
                cs_Enum: // need to map value to integer
                begin
                  Add( '    Add( ' + iFieldString + '.Create( Fields, ' + Filter.ValueToTypeText + ', T'
                       + DataFile.BaseFileName.Value +'Data.c' + DBBField.DBBField.FieldName.Value
                       + ', IntToStr( Ord( ' + CompareValue.Value + ' ))));' );
                end;
                //cs_Text, cs_String, default OK
                //cs_DateTime: ; default OK
                //cs_Set_Membership: // not valid to compare set membership to text
                //begin
                  //raise Exception.Create('Not valid to use set membership field for filter for field ' + DBBField.DBBField.FieldName.Value);
                //end;
                //cs_boolean:  ;
                else
                begin
                  Add( '    Add( ' + iFieldString + '.Create( Fields, ' + Filter.ValueToTypeText + ', T'
                       + DataFile.BaseFileName.Value +'Data.c' + DBBField.DBBField.FieldName.Value
                       + ', ''' + CompareValue.Value + ''' ));' );
                end;
              end;
            end
            else
            begin
              Add( '    Add( ' + iFieldString + '.Create( Fields, ' + Filter.ValueToTypeText + ', T'
                   + DataFile.BaseFileName.Value +'Data.c' + DBBField.DBBField.FieldName.Value + ' ));' );
            end;
          end;
        end
        else
        begin
          raise Exception.Create('Index Field not defined!');
        end;
      end;
    end;
    Add( '  end;' );
    Add( '' );
    Add( 'end;' );
    Add( '' );
    iLine := 'function T' + FullName + '.AppendData( ';
    iNeedsSemicolon := FALSE;
    for i := 0 to DataFile.Fields.Max do
    begin
      if iNeedsSemicolon then
      begin
        iLine := iLine + '; ';
      end
      else
      begin
        iNeedsSemicolon := TRUE;
      end;
      with DataFile.Fields.DBField[ i ] do
      begin
        iLine2 := 'p' + FieldName.Value + ' : ' + FieldType.Value;
      end;
      if (Length( iLine ) + Length( iLine2 )) > 110 then
      begin
        Add( iLine );
        iLine := '             ' + iLine2;
      end
      else
      begin
        iLine := iLine + iLine2;
      end;
    end;
    Add( iLine + ' ) : tSigDBRecPointer;' );
    Add( 'begin' );
    Add( '  DataBase.Lock;' );
    Add( '  try' );
    if MirrorDataFields.ValueAsBool then
    begin
      iLine2 := '    ';
    end
    else
    begin
      Add( '    with ' + DataFile.BaseFileName.Value + 'Data do' );
      Add( '    begin' );
      iLine2 := '      ';
    end;
    for i := 0 to DataFile.Fields.Max do
    begin
      with DataFile.Fields.DBField[ i ] do
      begin
        Add( iLine2 + FieldName.Value + ' := p' + FieldName.Value + ';' );
      end;
    end;
    if not MirrorDataFields.ValueAsBool then
    begin
      Add( '    end;' );
    end;
    Add( '    Result := AppendData;' );
    Add( '  finally' );
    Add( '    Database.Unlock;' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    iLine := 'procedure T' + FullName + '.UpdateData(  const pRec : TSigDBRecPointer';
    for i := 0 to DataFile.Fields.Max do
    begin
      iLine := iLine + '; ';
      with DataFile.Fields.DBField[ i ] do
      begin
        iLine2 := 'p' + FieldName.Value + ' : ' + FieldType.Value;
      end;
      if (Length( iLine ) + Length( iLine2 )) > 110 then
      begin
        Add( iLine );
        iLine := '             ' + iLine2;
      end
      else
      begin
        iLine := iLine + iLine2;
      end;
    end;
    Add( iLine + ' );' );
    Add( 'begin' );
    Add( '  DataBase.Lock;' );
    Add( '  try' );
    Add( '  ReadData( pRec );' );
    if MirrorDataFields.ValueAsBool then
    begin
      iLine2 := '    ';
    end
    else
    begin
      Add( '    with ' + DataFile.BaseFileName.Value + 'Data do' );
      Add( '    begin' );
      iLine2 := '      ';
    end;
    for i := 0 to DataFile.Fields.Max do
    begin
      with DataFile.Fields.DBField[ i ] do
      begin
        Add( iLine2 + FieldName.Value + ' := p' + FieldName.Value + ';' );
      end;
    end;
    if not MirrorDataFields.ValueAsBool then
    begin
      Add( '    end;' );
    end;
    Add( '    UpdateData;' );
    Add( '  finally' );
    Add( '    Database.Unlock;' );
    Add( '  end;' );
    Add( 'end;' );
    Add( '' );
    Add( 'function T' + FullName + '.Get' + DataFile.BaseFileName.Value + 'Data: T' + DataFile.BaseFileName.Value + 'Data;' );
    Add( 'begin' );
    Add( '  Result := DataFile as T' + DataFile.BaseFileName.Value + 'Data;' );
    Add( 'end;' );
    Add( '' );
    if MirrorDataFields.ValueAsBool then
    begin
      DataFile.AddMirrorImplementation( 'T' + FullName, pLines );
    end;
  end;
  AddFindImplementations( pLines );
end;

procedure tSigDBBIndexFile.AddDBFileDef(const pLines: tStrings);
begin
  with pLines do
  begin
    Add('    property ' + DataFile.BaseFileName.Value + 'Data : T' + DataFile.BaseFileName.Value + 'Data');
    Add('             read Get' + DataFile.BaseFileName.Value + 'Data;');
  end;
end;

procedure tSigDBBIndexFile.AddDBFileGetter(const pLines: tStrings);
begin
  with pLines do
  begin
    Add( '    function Get' + DataFile.BaseFileName.Value + 'Data : T' + DataFile.BaseFileName.Value + 'Data;');
  end;
end;

procedure tSigDBBIndexFile.AddDBIndexProperty(const pLines: TStrings);
begin
  with pLines do
  begin
    Add( '    property ' + FullName + ' : T' + FullName );
    Add( '             read f' + FullName );
    Add( '             write Set' + FullName + ';');
  end;
end;

procedure tSigDBBIndexFile.AddDBIndexSetter(const pLines: TStrings);
begin
  with pLines do
  begin
    Add( '    procedure Set' + FullName + '(const Value: T' + FullName + ');');
  end;
end;

procedure tSigDBBIndexFile.AddDBIndexSource(const pLines: TStrings);
begin
  with pLines do
  begin
    Add( '    f' + FullName + ' : T' + FullName + ';');
  end;
end;

procedure tSigDBBIndexFile.AddFindDefs(const pLines: tStrings);
begin
  fFindFunctions.AddFindDefs( pLines );
end;

procedure tSigDBBIndexFile.AddFindImplementations(const pLines: tStrings);
begin
  fFindFunctions.AddFindImplementations( pLines );
end;

procedure tSigDBBIndexFile.AddDBIndexFileListImplementation(const IndexFileListName: string;
  const pLines: tStrings);
begin
  with pLines do
  begin
    Add( 'procedure T' + IndexFileListName + 'IndexFileList.Set' + FullName + '(' );
    Add( '  const Value: T' + FullName + ');' );
    Add( 'begin' );
    Add( '  Reassign( tSigDBIndexFile(f' + FullName + '), Value );' );
    Add( 'end;' );
    Add( '' );
  end;
end;

procedure tSigDBBIndexFile.AddMirrorDefs(const pLines: tStrings);
begin
  DataFile.AddMirrorInfo( pLines );
  DataFile.AddConstInfo( pLines );
end;

procedure tSigDBBIndexFile.AddMirrorGettersAndSetters(const pLines: tStrings);
begin
  DataFile.AddMirrorGettersAndSetters( pLines );
end;

constructor tSigDBBIndexFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBIndexField );

  fNameExtension := tSigTextProperty.Create( 'Name Extension', self );
  fFindFunctions := tSigDBFindFunctions.Create( 'Find Functions', self );
  fMirrorDataFields := TSigBooleanProperty.Create( 'Mirror Data Fields', self );
  fIntercept := TSigBooleanProperty.Create( 'Add Intercept?', self );
  fEncrypted := tSigBooleanProperty.Create( 'Encrypted?', self );

end;

function tSigDBBIndexFile.FullName: string;
begin
  Result := Trim(DataFile.BaseFileName.Value) + 'Index' + Trim(NameExtension.Value);
end;

{ tSigDBIndexFileList }

procedure tSigDBBIndexFileList.AddDBIndexFileListImplementation(
  const IndexFileListName: string; const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    SigDBBIndexFile[ i ].AddDBIndexFileListImplementation( IndexFileListName, pLines );
  end;
end;

procedure tSigDBBIndexFileList.AddDBIndexProperties(const pLines: TStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    SigDBBIndexFile[ i ].AddDBIndexProperty( pLines );
  end;
end;

procedure tSigDBBIndexFileList.AddDBIndexSetters(const pLines: TStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    SigDBBIndexFile[ i ].AddDBIndexSetter( pLines );
  end;
end;

procedure tSigDBBIndexFileList.AddDBIndexSources(const pLines: TStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    SigDBBIndexFile[ i ].AddDBIndexSource( pLines );
  end;
end;

procedure tSigDBBIndexFileList.AddIndexesClasses(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    with SigDBBIndexFile[ i ] do
    begin
      AddClassFieldDefs( pLines );
      AddClassDef( pLines );
    end;
  end;
end;

procedure tSigDBBIndexFileList.AddIndexesImplementations(
  const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    with SigDBBIndexFile[ i ] do
    begin
      AddClassFieldImplementations( pLines );
      AddClassImplementation( pLines );
    end;
  end;
end;

constructor tSigDBBIndexFileList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigDBBIndexFile );

  fSetAnalysis := TBitSetLines.Create;
end;

destructor tSigDBBIndexFileList.Destroy;
begin
  fSetAnalysis.Free;

  inherited;
end;

function tSigDBBIndexFileList.GetSigDBBIndexFile(
  const i: integer): tSigDBBIndexFile;
begin
  Result := Entry[ i ] as tSigDBBIndexFile;
end;

procedure tSigDBBIndexFileList.InsertDBIndexProperties(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].InsertDBIndexProperty( i, pLines );
  end;
end;

procedure tSigDBBIndexFileList.InsertDBIndexSetters(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].InsertDBIndexSetter( i, pLines );
  end;
end;

procedure tSigDBBIndexFileList.InsertDBIndexSources(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].InsertDBIndexSource( i, pLines );
  end;
end;

procedure tSigDBBIndexFileList.RefreshEditors;
begin
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].RefreshEditors;
  end;
end;

procedure tSigDBBIndexFileList.SetActiveChild(const Value: integer);
begin
  if (ActiveChild >= 0) and (ActiveChild <= Max ) then
  begin
    with SigDBBIndexFile[ ActiveChild ] do
    begin
      EditIndexExtension := nil;
      SigGeneralGridIndexes := nil;
      SigSpinEditIndexCount := nil;
      SigGeneralGridFind := nil;
      SpeedButtonAddFindFunction := nil;
      CheckBoxMirrorDataFields := nil;
      CheckBoxAddIndexIntercept := nil;
    end;
  end;
  inherited;
  if ActiveChild >= 0 then
  begin
    with SigDBBIndexFile[ ActiveChild ] do
    begin
      EditIndexExtension := self.EditIndexExtension; // self required here
      SigGeneralGridIndexes := self.SigGeneralGridIndexes; // self required here
      SigSpinEditIndexCount := self.SigSpinEditIndexCount; // self required here
      SigGeneralGridFind := self.SigGeneralGridFind; // self required here
      SpeedButtonAddFindFunction := self.SpeedButtonAddFindFunction; // self required here
      CheckBoxMirrorDataFields := self.CheckBoxMirrorDataFields; // self required here
      CheckBoxAddIndexIntercept := self.CheckBoxAddIndexIntercept; // self required here
    end;
  end;
end;

procedure tSigDBBIndexFileList.SetCheckBoxAddIndexIntercept(
  const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].CheckBoxAddIndexIntercept := Value;
  end;
end;

procedure tSigDBBIndexFileList.SetCheckBoxMirrorDataFields(
  const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].CheckBoxMirrorDataFields := Value;
  end;
end;

procedure tSigDBBIndexFileList.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].EditIndexExtension := Value;
  end;
end;

procedure tSigDBBIndexFileList.SetSigGeneralGridFind(
  const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].SigGeneralGridFind := Value;
  end;
end;

procedure tSigDBBIndexFileList.SetSigGeneralGridIndexes(
  const Value: TSigGeneralGrid);
begin
  fSigGeneralGridIndexes := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].SigGeneralGridIndexes := Value;
  end;
end;

procedure tSigDBBIndexFileList.SetSigSpinEditIndexCount(
  const Value: TSigSpinEdit);
begin
  fSigSpinEditIndexCount := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].SigSpinEditIndexCount := Value;
  end;

end;

procedure tSigDBBIndexFileList.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  if ActiveChild >= 0 then
  begin
    SigDBBIndexFile[ ActiveChild ].SpeedButtonAddFindFunction := Value;
  end;
end;

procedure tSigDBBIndexFileList.UpdateDBSourceClasses(i: integer;  // we don't pass updated i back
  const pLines: tStrings);
var
  j : integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].UpdateDBSourceClasses( i, pLines );
  end;
end;

procedure tSigDBBIndexFileList.UpdateIndexListConstructors(i: integer;
  const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].UpdateIndexListConstructor( i, pLines );
  end;
end;

{
procedure tSigDBBIndexFileList.UpdateIndexListSetters(
  const IndexFileListName: string; i: integer; const pLines: tStrings);
var
  j: Integer;
begin
  for j := 0 to Max do
  begin
    SigDBBIndexFile[ j ].AddDBIndexFileListImplementation( IndexFileListName, i, pLines );
  end;
end;
}

function tSigDBBIndexFile.GetDataFile: tSigDBBBaseFile;
begin
  Result := GetOwnerOfType( tSigDBBBaseFile ) as tSigDBBBaseFile;
end;

function tSigDBBIndexFile.GetIndexField(const i: integer): tSigDBIndexField;
begin
  Result := Entry[ i ] as tSigDBIndexField;
end;

procedure tSigDBBIndexFile.InsertDBIndexProperty(i: integer;
  const pLines: tStrings);
var
  iTest : string;
begin
  iTest := 'property ' + FullName + ' : T';
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      // already there
      exit;
    end
    else if SameText( 'end;', Trim(pLines[ i ]) ) then
    begin
      // not there - add
{
    '    property ' + FullName + ' : T' + FullName
    '             read f' + FullName
    '             write Set' + FullName + ';'
}
      pLines.Insert( i, '             write Set' + FullName + ';' );
      pLines.Insert( i, '             read f' + FullName );
      pLines.Insert( i, '    property ' + FullName + ' : T' + FullName ); // note reversed order of insertion
    end;
  end;

end;

procedure tSigDBBIndexFile.InsertDBIndexSetter(i: integer;
  const pLines: tStrings);
var
  iTest : string;
  iLastPublic : integer;
begin
  iTest := 'procedure Set' + FullName + '(';
  iLastPublic := i;
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      // already there
      exit;
    end
    else if SameText( Trim( pLines[ i ] ), 'public' ) then
    begin
      iLastPublic := i;
    end
    else if Pos( 'constructor', pLines[ i ] ) > 0 then
    begin
      // not there - add
      pLines.Insert( iLastPublic, '    procedure Set' + FullName + '(const Value: T' + FullName + ');' );
    end;
  end;

end;

procedure tSigDBBIndexFile.InsertDBIndexSource(i: integer;
  const pLines: tStrings);
var
  iTest : string;
  iLastPublic : integer;
  iFirstProcedure : integer;
begin
  iTest := 'f' + FullName + ' :';
  iLastPublic := i;
  iFirstProcedure := 0;
  while i < pLines.Count do
  begin
    if Pos( iTest, pLines[ i ] ) > 0 then
    begin
      // already there
      exit;
    end
    else if SameText( Trim( pLines[ i ] ), 'public' ) then
    begin
      iLastPublic := i;
    end
    else if Pos( 'constructor', pLines[ i ] ) > 0 then
    begin
      // not there - add
      if iFirstProcedure <> 0 then
      begin
        iLastPublic := iFirstProcedure;
      end;
      pLines.Insert( iLastPublic, '    f' + FullName + ' : T' + FullName + ';' );
    end
    else if iFirstProcedure = 0 then
    begin
      if Pos( 'procedure', pLines[ i ] ) > 0 then
      begin
        iFirstProcedure := i;
      end;
    end;
  end;

end;

function tSigDBBIndexFile.KeyParm(const i: integer): string;
begin
  with IndexField[ i ].DBBField.DBBField do
  begin
    Result := 'p' + FieldName.Value + ' : ' + FieldType.Value;
  end;
end;

procedure tSigDBBIndexFile.OnSigGeneralGridIndexesChange(const Sender: TObject;
  const Col, Row: integer; const pValue: string);
begin
  if Row > 0 then
  begin
    with IndexField[ Row - 1] do
    begin
      case Col of
        cColField:
        begin
          DBBField.CellText := pValue;
        end;
        cColFilter:
        begin
          Filter.CellTextToValue( pValue );
        end;
        cColCompare:
        begin
          CompareValue.Value := pValue;
        end;
      end;
    end;
  end;
end;

procedure tSigDBBIndexFile.OnSigSpinEditIndexCountChange(Sender: TObject);
begin
  if fSigSpinEditIndexCount.IsValid then
  begin
    ShowIndexes;
  end;
end;

procedure tSigDBBIndexFile.RefreshEditors;
begin
  ShowIndexes;
end;

procedure tSigDBBIndexFile.RemoveEditors;
begin
  inherited;
  SigSpinEditIndexCount := nil;
  SigGeneralGridIndexes := nil;
end;

procedure tSigDBBIndexFile.RemoveIndexField(pIndexField: tSigDBIndexField);
var
  i, iIndex : integer;
begin
  iIndex := -1;
  for i := 0 to Max do
  begin
    if IndexField[ i ] = pIndexField then
    begin
      iIndex := i;
      break;
    end;
  end;
  if iIndex >= 0 then
  begin
  // we need to remove the index field and, if necessary, update the Find Functions
    Delete( iIndex );
    with FindFunctions do
    begin
      for i := 0 to Max do
      begin
        with FindFunction [ i ] do
        begin
          if FindLevel.ValueAsInt >= iIndex then
          begin
            FindLevel.ValueAsInt := FindLevel.ValueAsInt - 1;
          end;
          if MatchLevel.ValueAsInt >= iIndex then
          begin
            MatchLevel.ValueAsInt := FindLevel.ValueAsInt - 1;
          end;
          {
          if FirstLevel.ValueAsInt >= iIndex then
          begin
            FirstLevel.ValueAsInt := FirstLevel.ValueAsInt - 1;
          end;
          }
        end;
      end;
    end;
  end;
end;

procedure tSigDBBIndexFile.SetCheckBoxAddIndexIntercept(const Value: TCheckBox);
begin
  fCheckBoxAddIndexIntercept := Value;
  fIntercept.Editor := Value;
end;

procedure tSigDBBIndexFile.SetCheckBoxMirrorDataFields(const Value: TCheckBox);
begin
  fCheckBoxMirrorDataFields := Value;
  fMirrorDataFields.Editor := Value;
end;

procedure tSigDBBIndexFile.SetEditIndexExtension(const Value: TEdit);
begin
  fEditIndexExtension := Value;
  fNameExtension.Editor := Value;
end;

procedure tSigDBBIndexFile.SetSigGeneralGridFind(const Value: tSigGeneralGrid);
begin
  fSigGeneralGridFind := Value;
  fFindFunctions.SigGeneralGridFind := Value;
end;

procedure tSigDBBIndexFile.SetSigGeneralGridIndexes(
  const Value: TSigGeneralGrid);
begin
  if assigned( fSigGeneralGridIndexes ) then
  begin
    fSigGeneralGridIndexes.OnCellEditChange := nil;
  end;
  fSigGeneralGridIndexes := Value;
  if assigned( fSigGeneralGridIndexes ) then
  begin
    fSigGeneralGridIndexes.OnCellEditChange := OnSigGeneralGridIndexesChange;
  end;
  ShowIndexes;
end;

procedure tSigDBBIndexFile.SetSigSpinEditIndexCount(const Value: TSigSpinEdit);
begin
  CountEditor := nil;
  if assigned( fSigSpinEditIndexCount ) then
  begin
    fSigSpinEditIndexCount.OnChange := nil;
  end;
  fSigSpinEditIndexCount := Value;
  if assigned( fSigSpinEditIndexCount ) then
  begin
    fSigSpinEditIndexCount.OnChange := OnSigSpinEditIndexCountChange;
  end;
  CountEditor := Value;
end;

procedure tSigDBBIndexFile.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  fSpeedButtonAddFindFunction := Value;
  fFindFunctions.SpeedButtonAddFindFunction := Value;
end;

procedure tSigDBBIndexFile.ShowIndexes;
var
  i : integer;
begin
  if assigned( SigGeneralGridIndexes ) then
  begin
    with SigGeneralGridIndexes do
    begin
      if Max < 0 then
      begin
        Visible := FALSE;
      end
      else
      begin
        Visible := TRUE;
        RowCount := Max + 2;
        for i := 0 to Max do
        begin
          Cell[ cColIndexNo, i + 1 ] := IntToStr( i );
          Cell[ cColField, i + 1 ]   := IndexField[ i ].DBBField.CellText;
          IndexField[ i ].DBBField.BuildAllowableNames(  Editor[ cColField ].ItemsList );
          Cell[ cColFilter, i + 1 ]   := IndexField[ i ].Filter.ValueToCellText;
          Cell[ cColCompare, i + 1 ]   := IndexField[ i ].CompareValue.Value;
        end;
      end;
    end;
  end;
end;

procedure tSigDBBIndexFile.UpdateDBSourceClasses(i: integer;
  const pLines: tStrings);
var
  iLastPublic : integer;
begin
  iLastPublic := i;
  while i < pLines.Count do
  begin
    if Pos( 'f' + FullName + ' : T', pLines[ i ]) <> 0 then
    begin
      // already exists!
      exit;
    end;
    if SameText( Trim( pLines[ i ] ), 'public') then
    begin
      iLastPublic := i;
    end;
    if Pos( 'constructor', pLines[ i ] ) <> 0  then
    begin
      // not found
      pLines.Insert( iLastPublic, '    f' + FullName + ' : T' + FullName + ';' );
      exit;
    end;
    inc( i );
  end;
end;

procedure tSigDBBIndexFile.UpdateIndexListConstructor(i: integer;
  const pLines: tStrings);
var
  iTest : string;
  iFull : string;
begin
  iTest := 'IndexFiles.' + FullName;
  iFull := '  ' + iTest +  ' := T' + FullName + '.Create( ''' + FullName +''', self, DataFiles.' + DataFile.BaseFileName.Value + 'Data );';
  while i < pLines.Count do
  begin
    if Pos( FullName, pLines[ i ] ) <> 0 then
    begin
      // found - make sure is correct
      pLines[ i ] := iFull;
      exit;
    end
    else if SameText( Trim( pLines[ i ] ), 'end;') then
    begin
      // done, but not found. insert new creation line
      pLines.Insert( i, iFull );
      exit;
    end;
    inc( i );
  end;
end;

function tSigDBIndexField.GetDataFile: tSigDBBBaseFile;
begin
  Result := GetOwnerOfType( tSigDBBBaseFile ) as tSigDBBBaseFile;
end;

procedure tSigDBIndexField.RemoveSelf;
var
  iOwner : TSigCompoundProperty;
begin
  iOwner := Owner;
  while assigned( iOwner ) do
  begin
    if iOwner is tSigDBBIndexFile then
    begin
      (iOwner as tSigDBBIndexFile).RemoveIndexField( self );
      exit;
    end
    else
    begin
      iOwner := iOwner.Owner;
    end;
  end;
end;

{ tSigDBIndexFilter }

procedure tSigDBIndexFilter.CellTextToValue(const pValue: string);
begin
  if SameText( pValue, cIndexAscending ) then
  begin
    ValueAsSigDBFieldType := ft_Index_Ascending;
  end
  else if SameText( pValue, cIndexDescending ) then
  begin
    ValueAsSigDBFieldType := ft_Index_Descending;
  end
  else if SameText( pValue, cFilterLT ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_LT;
  end
  else if SameText( pValue, cFilterLE ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_LE;
  end
  else if SameText( pValue, cFilterEQ ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_EQ;
  end
  else if SameText( pValue, cFilterNE ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_NE;
  end
  else if SameText( pValue, cFilterGE ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_GE;
  end
  else if SameText( pValue, cFilterGT ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_GT;
  end
  else if SameText( pValue, cFilterIN ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_in;
  end
  else if SameText( pValue, cFilterNotIN ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_not_in;
  end
  else if SameText( pValue, cFilterChanged ) then
  begin
    ValueAsSigDBFieldType := ft_Filter_Changed;
  end
  else
  begin
    raise Exception.Create('Unrecognised filter');
  end;

end;

procedure tSigDBIndexFilter.Clear;
begin
  inherited;

  ValueAsSigDBFieldType := ft_Index_Ascending;
end;

function tSigDBIndexFilter.GetSigDBFieldType: tSigDBFieldType;
begin
  Result := tSigDBFieldType( ValueAsInt );
end;

procedure tSigDBIndexFilter.SetSigDBFieldType(const Value: tSigDBFieldType);
begin
  ValueAsInt := Ord( Value );
end;

function tSigDBIndexFilter.ValueToCellText: string;
begin
  case ValueAsSigDBFieldType of
    ft_String,
    ft_Integer,
    ft_Date_Time,
    ft_Field_Pointer:    raise exception.Create( 'Field type not valid here' );
    ft_Index_Ascending:  Result := cIndexAscending;
    ft_Index_Descending: Result := cIndexDescending;
    ft_Filter_LT:        Result := cFilterLT;
    ft_Filter_LE:        Result := cFilterLE;
    ft_Filter_EQ:        Result := cFilterEQ;
    ft_Filter_NE:        Result := cFilterNE;
    ft_Filter_GE:        Result := cFilterGE;
    ft_Filter_GT:        Result := cFilterGT;
    ft_Filter_in:        Result := cFilterIN;
    ft_Filter_not_in:    Result := cFilterNotIN;
    ft_Filter_Changed:   Result := cFilterChanged;
  end;
end;

function tSigDBIndexFilter.ValueToTypeText: string;
begin
  case ValueAsSigDBFieldType of
    ft_String,
    ft_Integer,
    ft_Date_Time,
    ft_Field_Pointer:    raise exception.Create( 'Field type not valid here' );
    ft_Index_Ascending:  Result := 'ft_Index_Ascending';
    ft_Index_Descending: Result := 'ft_Index_Descending';
    ft_Filter_LT:        Result := 'ft_Filter_LT';
    ft_Filter_LE:        Result := 'ft_Filter_LE';
    ft_Filter_EQ:        Result := 'ft_Filter_EQ';
    ft_Filter_NE:        Result := 'ft_Filter_NE';
    ft_Filter_GE:        Result := 'ft_Filter_GE';
    ft_Filter_GT:        Result := 'ft_Filter_GT';
    ft_Filter_in:        Result := 'ft_Filter_in';
    ft_Filter_not_in:    Result := 'ft_Filter_not_in';
    ft_Filter_Changed:   Result := 'ft_Filter_Changed';
  end;
end;

{ tSigDBFindFunctionModeEnum }

function tSigDBFindFunctionModeEnum.GetValueAsEnum: tSigDBFindFunctionMode;
begin
  Result := tSigDBFindFunctionMode( ValueAsInt );
end;

procedure tSigDBFindFunctionModeEnum.SetValueAsEnum(
  const Value: tSigDBFindFunctionMode);
begin
  ValueAsInt := Ord( Value );
end;

{ tSigDBFindFunction }

procedure tSigDBFindFunction.AddFindDef(const pLines: tStrings);
var
  iLine : string;
  i : integer;
begin
  // Find, First and Next
  // First and next only on partial keys with equality
  with pLines do
  begin
    case self.FindMode.ValueAsEnum of
      ff_Variable:
      begin
        iLine := '    function Find( const pMode : tSigDBFindMode; ';
      end;
      ff_EQ, ff_LE, ff_GE:
      begin
        iLine := '    function Find( ';
      end;
      ff_First:
      begin
        iLine := '    function First( var pCurr: tSigDBIndex; ';
      end;
      ff_Next:
      begin
        iLine := '    function Next( var pCurr: tSigDBIndex; ';
      end;
      ff_Prev:
      begin
        iLine := '    function Prev( var pCurr: tSigDBIndex; ';
      end;
      ff_Last:
      begin
        iLine := '    function Last( var pCurr: tSigDBIndex; ';
      end;
    end;
    for i := 0 to FindLevel.ValueAsInt - 2 do
    begin
      iLine := iLine + IndexFile.KeyParm( i ) + ';';
      Add( iLine );
      iLine := '        ';
    end;
    iLine := iLine + IndexFile.KeyParm( FindLevel.ValueAsInt - 1 ) + ' ) : tSigDBRecPointer; overload;';
    Add( iLine );
    Add( '' );

  end;
end;

procedure tSigDBFindFunction.AddFindImplementation(const pLines: tStrings);
var
  iLine : string;
  i, iFindLevel, iMatchLevel : integer;
begin
  // Find, First and Next
  // First and next only on partial keys with equality
  with pLines do
  begin
    iFindLevel := FindLevel.ValueAsInt;
    iMatchLevel := MatchLevel.ValueAsInt;
    if iMatchLevel < 0 then
    begin
      iMatchLevel := iFindLevel;
    end;
    case FindMode.ValueAsEnum of
      ff_Variable, ff_EQ, ff_LE, ff_GE:
      begin
        iLine := 'function T' + IndexFile.FullName + '.Find(';
        case FindMode.ValueAsEnum of
          ff_Variable:
          begin
            iLine := iLine + 'const pMode : tSigDBFindMode; ';
          end;
        end;
        for i := 0 to iFindLevel - 2 do
        begin
          iLine := iLine + IndexFile.KeyParm( i ) + ';';
          Add( iLine );
          iLine := '        ';
        end;
        Add( iLine + IndexFile.KeyParm( iFindLevel - 1 ) + ' ) : TSigDBRecPointer;' );
        Add('begin');
        Add('  Database.Lock;');
        Add('  try');
        Add('    with ' + DataFile.BaseFileName.Value + 'Data do');
        Add('    begin');
        for i := 0 to iFindLevel - 1 do
        begin
          with IndexFile.IndexField[ i ].DBBField.DBBField do
          begin
            Add('      ' + FieldName.Value + ' := p' + FieldName.Value + ';');
          end;
        end;
        case FindMode.ValueAsEnum of
          ff_Variable:
          begin
            Add('      Result := Find( pMode, ' + IntToStr(iFindLevel) + ' );'); // Match level not used for Find
          end;
          ff_EQ:
          begin
            Add('      Result := Find( fmEQ, ' + IntToStr(iFindLevel) + ' );');
          end;
          ff_LE:
          begin
            Add('      Result := Find( fmLE, ' + IntToStr(iFindLevel) + ' );');
          end;
          ff_GE:
          begin
            Add('      Result := Find( fmGE, ' + IntToStr(iFindLevel) + ' );');
          end;
          else
          begin
            raise Exception.Create('Unexpected Find Mode');
          end;
        end;
        Add('      if Result <> 0 then');
        Add('      begin');
        Add('        ReadData( Result );');
        Add('      end;');
        Add('    end;');
        Add('  finally');
        Add('    Database.Unlock;');
        Add('  end;');
        Add('end;');
        Add('');
      end;
      ff_First:
      begin
        iLine := 'function T' + IndexFile.FullName + '.First( var pCurr: tSigDBIndex; ';
        for i := 0 to iFindLevel - 2 do
        begin
          iLine := iLine + IndexFile.KeyParm( i ) + ';';
          Add( iLine );
          iLine := '        ';
        end;
        Add( iLine + IndexFile.KeyParm( iFindLevel - 1 ) + ' ) : TSigDBRecPointer;' );
        Add('begin');
        Add('  Database.Lock;');
        Add('  try');
        Add('    with ' + DataFile.BaseFileName.Value + 'Data do');
        Add('    begin');
        for i := 0 to iFindLevel - 1 do
        begin
          with IndexFile.IndexField[ i ].DBBField.DBBField do
          begin
            Add('      ' + FieldName.Value + ' := p' + FieldName.Value + ';');
          end;
        end;
        Add('    end;');
        Add('    Result := inherited First( pCurr, ' + IntToStr(iFindLevel) + ', ' + IntToStr(iMatchLevel) + ' );');
        Add('  finally');
        Add('    Database.Unlock;');
        Add('  end;');
        Add('end;');
        Add('');
      end;
      ff_Next:
      begin
        iLine := 'function T' + IndexFile.FullName + '.Next( var pCurr: tSigDBIndex; ';
        for i := 0 to iFindLevel - 2 do
        begin
          iLine := iLine + IndexFile.KeyParm( i ) + ';';
          Add( iLine );
          iLine := '        ';
        end;
        Add( iLine + IndexFile.KeyParm( iFindLevel - 1 ) + ' ) : TSigDBRecPointer;' );
        Add( 'begin');
        Add( '  Database.Lock;');
        Add( '  try');
        Add( '    with ' + DataFile.BaseFileName.Value + 'Data do');
        Add( '    begin');
        for i := 0 to iFindLevel - 1 do
        begin
          with IndexFile.IndexField[ i ].DBBField.DBBField do
          begin
            Add('      ' + FieldName.Value + ' := p' + FieldName.Value + ';');
          end;
        end;
        Add( '    end;');
        Add( '    Result := inherited Next( pCurr, ' + IntToStr(iFindLevel) + ', ' + IntToStr(iMatchLevel) + ' );' );
        Add( '  finally');
        Add( '    Database.Unlock;');
        Add( '  end;');
        Add( 'end;');
        Add( '');
      end;
      ff_Prev:
      begin
        iLine := 'function T' + IndexFile.FullName + '.Prev( var pCurr: tSigDBIndex; ';
        for i := 0 to iFindLevel - 2 do
        begin
          iLine := iLine + IndexFile.KeyParm( i ) + ';';
          Add( iLine );
          iLine := '        ';
        end;
        Add( iLine + IndexFile.KeyParm( iFindLevel - 1 ) + ' ) : TSigDBRecPointer;' );
        Add( 'begin');
        Add( '  Database.Lock;');
        Add( '  try');
        Add( '    with ' + DataFile.BaseFileName.Value + 'Data do');
        Add( '    begin');
        for i := 0 to iFindLevel - 1 do
        begin
          with IndexFile.IndexField[ i ].DBBField.DBBField do
          begin
            Add('      ' + FieldName.Value + ' := p' + FieldName.Value + ';');
          end;
        end;
        Add( '    end;');
        Add( '    Result := inherited Prev( pCurr, ' + IntToStr(iFindLevel) + ', ' + IntToStr(iMatchLevel) + ' );' );
        Add( '  finally');
        Add( '    Database.Unlock;');
        Add( '  end;');
        Add( 'end;');
        Add( '');
      end;
      ff_Last:
      begin
        iLine := 'function T' + IndexFile.FullName + '.Last( var pCurr: tSigDBIndex; ';
        for i := 0 to iFindLevel - 2 do
        begin
          iLine := iLine + IndexFile.KeyParm( i ) + ';';
          Add( iLine );
          iLine := '        ';
        end;
        Add( iLine + IndexFile.KeyParm( iFindLevel - 1 ) + ' ) : TSigDBRecPointer;' );
        Add('begin');
        Add('  Database.Lock;');
        Add('  try');
        Add('    with ' + DataFile.BaseFileName.Value + 'Data do');
        Add('    begin');
        for i := 0 to iFindLevel - 1 do
        begin
          with IndexFile.IndexField[ i ].DBBField.DBBField do
          begin
            Add('      ' + FieldName.Value + ' := p' + FieldName.Value + ';');
          end;
        end;
        Add('    end;');
        Add('    Result := inherited Last( pCurr, ' + IntToStr(iFindLevel) + ', ' + IntToStr(iMatchLevel) + ' );');
        Add('  finally');
        Add('    Database.Unlock;');
        Add('  end;');
        Add('end;');
        Add('');
      end;
    end;
  end;
end;

procedure tSigDBFindFunction.AfterLoad;
var
  iOwner : tSigDBFindFunctions;
begin
  inherited;
  if fUsesFirstNext1.ValueAsBool then
  begin
    iOwner := GetOwnerOfType( tSigDBFindFunctions ) as tSigDBFindFunctions;
    if assigned( iOwner ) then
    begin
      iOwner.Max := iOwner.Max + 1;
      iOwner.FindFunction[ iOwner.Max ].FindMode.ValueAsEnum := ff_First;
      iOwner.FindFunction[ iOwner.Max ].FindLevel.ValueAsInt := self.fFirstLevel1.ValueAsInt;
      iOwner.Max := iOwner.Max + 1;
      iOwner.FindFunction[ iOwner.Max ].FindMode.ValueAsEnum := ff_Next;
      iOwner.FindFunction[ iOwner.Max ].FindLevel.ValueAsInt := self.fFirstLevel1.ValueAsInt;
      iOwner.Max := iOwner.Max + 1;
      iOwner.FindFunction[ iOwner.Max ].FindMode.ValueAsEnum := ff_Prev;
      iOwner.FindFunction[ iOwner.Max ].FindLevel.ValueAsInt := self.fFirstLevel1.ValueAsInt;
      iOwner.Max := iOwner.Max + 1;
      iOwner.FindFunction[ iOwner.Max ].FindMode.ValueAsEnum := ff_Last;
      iOwner.FindFunction[ iOwner.Max ].FindLevel.ValueAsInt := self.fFirstLevel1.ValueAsInt;
    end;
    fUsesFirstNext1.ValueAsBool := FALSE;
  end;
end;

procedure tSigDBFindFunction.Clear;
begin
  inherited;
  fMatchLevel.ValueAsInt := -1;
end;

constructor tSigDBFindFunction.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fFindMode := tSigDBFindFunctionModeEnum.Create( 'Find Mode', self );
  fFindLevel := tSigIntegerProperty.Create( 'Find Level', self );
  fMatchLevel := tSigIntegerProperty.Create( 'Match Level', self );

  fUsesFirstNext1 := TSigBooleanProperty.Create( 'Create First/Next Procedures', self );
  fFirstLevel1 := tSigIntegerProperty.Create( 'First Level', self );
  fUsesFirstNext1.SaveWithFile := FALSE;
  fFirstLevel1.SaveWithFile := FALSE;
end;

function tSigDBFindFunction.GetDataFile: tSigDBBBaseFile;
begin
  Result := GetOwnerOfType( tSigDBBBaseFile ) as tSigDBBBaseFile;
end;

function tSigDBFindFunction.GetIndexFile: tSigDBBIndexFile;
begin
  Result := GetOwnerOfType( tSigDBBIndexFile ) as tSigDBBIndexFile;
end;

function tSigDBFindFunction.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  if fUsesFirstNext1.ValueAsBool then
  begin
    OwnerFile.RegisterAfterLoadEntry( self );
  end;
end;

{ tSigDBFindFunctions }

procedure tSigDBFindFunctions.AddFindDefs(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FindFunction[ i ].AddFindDef( pLines );
  end;
end;

procedure tSigDBFindFunctions.AddFindImplementations(const pLines: tStrings);
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FindFunction[ i ].AddFindImplementation( pLines );
  end;
end;

procedure tSigDBFindFunctions.AfterLoad;
begin
  inherited;
  BuildSigGeneralGridFind;
end;

procedure tSigDBFindFunctions.BuildSigGeneralGridFind;
var
  i : integer;
begin
  if (not LoadingFromFile) or ExecutingAfterLoad then
  begin
    if assigned( fSigGeneralGridFind ) then
    begin
      with fSigGeneralGridFind do
      begin
        if Max < 0 then
        begin
          Visible := FALSE;
        end
        else
        begin
          Visible := TRUE;
          RowCount := Max + 2;
          for i  := 0 to Max do
          begin
            with FindFunction[ i ] do
            begin
              Cell[ cColFindMode, i + 1 ] := Editor[ cColFindMode ].ItemsList[ FindMode.ValueAsInt ];
              Cell[ cColFindLevel, i + 1 ] := FindLevel.Value;
              Cell[ cColMatchLevel, i + 1 ] := MatchLevel.Value;
              {
              if UsesFirstNext.ValueAsBool then
              begin
                Cell[ cColFirst, i + 1 ] := '1';
              end
              else
              begin
                Cell[ cColFirst, i + 1 ] := '0';
              end;
              Cell[ cColFirstLevel, i + 1 ] := FirstLevel.Value;
              }
            end;
          end;
        end;
      end;
    end;
  end;
end;

constructor tSigDBFindFunctions.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner,tSigDBFindFunction );

end;

function tSigDBFindFunctions.GetDataFile: tSigDBBBaseFile;
begin
  Result := GetOwnerOfType( tSigDBBBaseFile ) as tSigDBBBaseFile;
end;

function tSigDBFindFunctions.GetFindFunction(
  const i: integer): tSigDBFindFunction;
begin
  Result := Entry[ i ] as tSigDBFindFunction;
end;

function tSigDBFindFunctions.Load(pFile: tStrings; var pLine: integer;
  const pAllowUndo, pIsDirty: boolean; pErrors: tErrorList): boolean;
begin
  Result := inherited;
  OwnerFile.RegisterAfterLoadEntry( self );
end;

procedure tSigDBFindFunctions.OnFieldEditorCellEditChange(const Sender: TObject;
  const Col, Row: integer; const pValue: string);
var
  i : integer;
begin
  if Row > 0 then
  begin
    case Col of
      cColFindMode:
      begin
        with fSigGeneralGridFind.Editor[ cColFindMode ].ItemsList do
        begin
          for i := 0 to Count - 1 do
          begin
            if SameText( Strings[ i ], pValue ) then
            begin
              FindFunction[ Row - 1 ].FindMode.ValueAsInt := i;
            end;
          end;
        end;
      end;
      cColFindLevel:
      begin
        if pValue <> '' then // when scrolling can get intermediate blanks. Ignore these.
        begin
          FindFunction[ Row - 1 ].FindLevel.ValueAsInt := StrToInt( pValue );
        end;
      end;
      cColMatchLevel:
      begin
        if pValue <> '' then // when scrolling can get intermediate blanks. Ignore these.
        begin
          FindFunction[ Row - 1 ].MatchLevel.ValueAsInt := StrToInt( pValue );
        end;
      end;
      {
      cColFirst:
      begin

      end;
      cColFirstLevel:
      begin
        if pValue <> '' then // when scrolling can get intermediate blanks. Ignore these.
        begin
          FindFunction[ Row - 1 ].FirstLevel.ValueAsInt := StrToInt( pValue );
        end;
      end;
      }
    end;
  end;
end;

procedure tSigDBFindFunctions.OnSpeedButtonAddFindFunctionClick(
  Sender: TObject);
begin
  Max := Max + 1;
  BuildSigGeneralGridFind;
end;

procedure tSigDBFindFunctions.RemoveEditors;
begin
  inherited;

  SigGeneralGridFind := nil;
  SpeedButtonAddFindFunction := nil;
end;

procedure tSigDBFindFunctions.SetSigGeneralGridFind(
  const Value: tSigGeneralGrid);
begin
  if assigned( fSigGeneralGridFind ) then
  begin
    fSigGeneralGridFind.OnCellEditChange := nil;
    fSigGeneralGridFind.OnMouseUp := nil;
  end;
  fSigGeneralGridFind := Value;
  if assigned( fSigGeneralGridFind ) then
  begin
    fSigGeneralGridFind.OnCellEditChange := OnFieldEditorCellEditChange;
    fSigGeneralGridFind.OnMouseUp := SigGeneralGridFindMouseUp;
    BuildSigGeneralGridFind;
  end;
end;

procedure tSigDBFindFunctions.SetSpeedButtonAddFindFunction(
  const Value: TSpeedButton);
begin
  if assigned( fSpeedButtonAddFindFunction ) then
  begin
    fSpeedButtonAddFindFunction.OnClick := nil;
    fSpeedButtonAddFindFunction.Enabled := FALSE;
  end;
  fSpeedButtonAddFindFunction := Value;
  if assigned( fSpeedButtonAddFindFunction ) then
  begin
    fSpeedButtonAddFindFunction.OnClick := OnSpeedButtonAddFindFunctionClick;
    fSpeedButtonAddFindFunction.Enabled := TRUE;
  end;
end;

procedure tSigDBFindFunctions.SigGeneralGridFindMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iRow, iCol : integer;
begin
  if (Button = mbLeft) and (Shift = [ssAlt]) then
  begin
    with SigGeneralGridFind do
    begin
      MouseToCell( X, Y, iCol, iRow );
      if iRow > 0 then
      begin
        if MessageDlg( 'Are you sure that you want to delete Find Mode?',
                       mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes  then
        begin
          Delete( iRow - 1, undoDelete2 );
          BuildSigGeneralGridFind;
        end;
      end;
    end;
(*
  end
  else if (Button = mbLeft) and (Shift = []) then
  begin
    with SigGeneralGridFind do
    begin
      MouseToCell( X, Y, iCol, iRow );
      if iRow > 0 then
      begin
        if iCol = cColFirst then
        begin
          if Cell[ iCol, iRow ] = '1' then
          begin
            FindFunction[ iRow - 1 ].UsesFirstNext.ValueAsBool := FALSE;
            Cell[ iCol, iRow ] := '0';
          end
          else
          begin
            FindFunction[ iRow - 1 ].UsesFirstNext.ValueAsBool := TRUE;
            Cell[ iCol, iRow ] := '1';
          end;
        end;
      end;
    end;
*)
  end;
end;

end.
