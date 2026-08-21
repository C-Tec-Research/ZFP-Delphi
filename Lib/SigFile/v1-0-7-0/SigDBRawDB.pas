unit SigDBRawDB;

{
  Database definitions are stored in the program.
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
  System.TypInfo,
  System.Character,
  SigBTree,
  TypedObjectList,
  PendingActions,
  ThreadObjectList;

type
  TSigDBException = class( Exception );

  tSigDBRecPointer = int64;

  tSigDBFileBase = class;
  tSigDBIndexFile = class;

  tSigDBIndex = class( tSigBTreeNodeMemory ) // binary tree stored in a file
  {
    The file is not stored in memory; in its entirity, but the accessed records are
    We do not need to store parent indexes in the file, since by definition, to access
    a record we must have accessed its parents, which we do store.
    Unaccessed children are indicated by nil pointers and non-zero indices
  }
  private
    fLastAccessed: tDateTime;
    procedure SetLeftChildIndex(const Value: tSigDBRecPointer);
    procedure SetRightChildIndex(const Value: tSigDBRecPointer);
  protected
    fLeftChildIndex: tSigDBRecPointer;
    fRightChildIndex: tSigDBRecPointer;
    fSigDBIndex: tSigDBRecPointer;
    fIndexFile: tSigDBIndexFile;
    //fSigDBTable: tSigDBDataFile;
    fCurrIndex: tSigDBRecPointer;
    function GetLeftChild: tSigBTreeNode; override;
    function GetRightChild: tSigBTreeNode; override;
    procedure SetLeftChild(const Value: tSigBTreeNode);  override;
    procedure SetRightChild(const Value: tSigBTreeNode);  override;
    procedure SetTreeDepth(const Value: integer); override;
    function GetTreeDepth: integer; override;
    function GetRightChildIndex: tSigDBRecPointer; virtual;
    function GetLeftChildIndex: tSigDBRecPointer; virtual;
  public
    constructor Create( const pIndexFile : tSigDBIndexFile; const pCurrIndex, pDBIndex : integer ); virtual;
    {
      There are two reasons for creating. If pCurrIndex is 0 we are adding a new record, and
      pDBIndex is used to point to the associated physical record. If pCurrIndex is non-zero,
      we are reading an existing value and pDB index is ignored.

    }
    destructor Destroy; override;

    property RightChildIndex : tSigDBRecPointer
             read GetRightChildIndex
             write SetRightChildIndex;
    property LeftChildIndex : tSigDBRecPointer
             read GetLeftChildIndex
             write SetLeftChildIndex;
    //property SigDBTable : tSigDBDataFile
    //         read fSigDBTable;
    property SigDBIndex : tSigDBRecPointer
             read fSigDBIndex;
    property CurrIndex : tSigDBRecPointer
              read fCurrIndex;
    property IndexFile : tSigDBIndexFile
             read fIndexFile;
    function NodeText : string; override;

    property LastAccessed : tDateTime  // actually our parents use this, not us.
             read fLastAccessed
             write fLastAccessed;

    procedure UpdateIndexFile;

    function PruneOldBranches( pNotUsedSince : tDateTime ) : boolean; // returns true if I can be pruned

    function LessThan( const SigTreeNode : tSigBTreeNode ) : boolean; override;
  end;

  tSigDBIndexRoot = class( tSigDBIndex ) // corresponds to record zero, which we always load
  private
    fIndexName: string;
    fLock : tObject;  // locking the root by implication locks tree. this reduces overhead of making threadsafe, just as with TTheadList
  protected
    function GetLeftChild: tSigBTreeNode; override;
    function GetRightChild: tSigBTreeNode; override;
    procedure SetLeftChild(const Value: tSigBTreeNode);  override;
    procedure SetRightChild(const Value: tSigBTreeNode);  override;
    function GetLeftChildIndex: tSigDBRecPointer; override;
  public
    constructor Create( const pIndexFile : tSigDBIndexFile; const pCurrIndex, pDBIndex : integer ); override;
    destructor Destroy; override;

    procedure Add( const SigTreeNode : tSigBTreeNode ); override; // returns tree depth
    property FirstDeletedIndex : tSigDBRecPointer
             read fRightChildIndex;
    property Root : tSigDBRecPointer
             read fLeftChildIndex;
    property IndexName : string
             read fIndexName;

    function NodeText : string; override;  // returns the text to be displayed visually

    procedure Lock;
    procedure Unlock;

    procedure PruneOldBranches( pNotUsedSince : tDateTime );
  end;

  tSigDBFieldType = ( ft_String, ft_Integer, ft_Date_Time, ft_Field_Pointer,
                      ft_Index_Ascending, ft_Index_Descending,
                      ft_Filter_LT, ft_Filter_LE,ft_Filter_EQ, ft_Filter_NE,
                      ft_Filter_GE, ft_Filter_GT, ft_Filter_in, ft_Filter_not_in );


  tSigDBIndexFieldList = class;

  tSigDBIndexField = class
  private
    fFieldType : tSigDBFieldType;
    fFilter: string;
    fDataFieldID : integer;
    fOwner : tSigDBIndexFieldList;
    fDataFileID: Int32;
  protected
    function FieldValid( const pDBRec : tSigDBRecPointer ) : boolean; virtual; // checks filters
  public
    constructor Create( const pOwner : tSigDBIndexFieldList;
                        const pFieldType : tSigDBFieldType;
                        const pDataFieldID : integer;
                        const pFilter : string = '';
                        const pDataFileID : Int32 = 0 ); virtual;

    procedure Clear;

    // for Filters
    property FieldType : tSigDBFieldType
             read fFieldType;
    property DataFieldID : integer
             read fDataFieldID;
    property DataFileID : Int32
             read fDataFileID;
    property Filter : string
             read fFilter;

    property Owner : tSigDBIndexFieldList
             read fOwner;
  end;

  tCompareResult = (crLT, crEQ, crGT );

  tSigDBIndexFieldList = class( tThreadObjectList )
  private
    fOwner : tSigDBIndexFile;
    fDataFile: tSigDBFileBase;
    fRoot : tSigDBIndexRoot;
    fOpen: boolean;
    function GetIndexField(const i: integer): tSigDBIndexField;
    procedure SetOpen(const Value: boolean);
  protected
    function CompareField( const pIndex: integer; const pDBRec1, pDBRec2 : tSigDBRecPointer ) : tCompareResult; // 0 = current DB file values rather than a record
    function CompareUpdateField( const pIndex: integer; const pDBRec1 : tSigDBRecPointer ) : tCompareResult; // 0 = current DB file values rather than a record
    function FieldValid( const pIndex : integer; const pDBRec : tSigDBRecPointer ) : boolean; // checks filters
  public
    constructor Create( const pOwner : tSigDBIndexFile; const pDataFile : tSigDBFileBase ); virtual;

    function RecValid( const pDBRec : tSigDBRecPointer ) : boolean;

    property DataFile : tSigDBFileBase
             read fDataFile;

    property IndexField[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    property Owner : tSigDBIndexFile
             read fOwner;
    property Root : tSigDBIndexRoot
             read fRoot;

    property Open : boolean
             read fOpen
             write SetOpen;

    function CompareUpdateRec( const pDBRec1 : tSigDBRecPointer ) : tCompareResult;
    function Compare( const pDBRec1 : tSigDBRecPointer; pFieldCount : integer ) : tCompareResult; overload;
    function Compare( const pDBRec1, pDBRec2 : tSigDBRecPointer; pFieldCount : integer ) : tCompareResult; overload;

    function IndexChanged : boolean;
  end;

  tSigDBDatabase = class;

  tSigDBFileBase = class
    // really just a placeholder for tSigDBFileBase< T >
  private
    fName: string;
  protected
    fOpen : boolean;
    function GetRecCount: integer; virtual;
    procedure SetOpen( pOpen : boolean ); virtual;
  public
    constructor Create( const pName : string ); virtual;
    function CompareField( const pFieldID : integer; pRec1, pRec2 : tSigDBRecPointer ) : tCompareResult; overload; virtual; abstract;
    function CompareField( const pFieldID : integer; pRec : tSigDBRecPointer; const pFilter : string ) : tCompareResult; overload; virtual; abstract;
    function CompareUpdateField( const pFieldID : integer; pRec1 : tSigDBRecPointer ) : tCompareResult; virtual; abstract;
    function IndexChanged( const pFieldID : integer ) : boolean; virtual; abstract;
    property Name : string
             read fName;

    property Open : boolean
             read fOpen
             write SetOpen;

    property RecCount : integer
             read GetRecCount;

    //function Read( const pRec : tSigDBRecPointer; pBuffer : pointer; var pIndex : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    function Read( const pRec : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    //function Write( const pRec : tSigDBRecPointer; pBuffer : pointer ) : boolean; overload; virtual; abstract;
    function Write( const pRec : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    //function Append( pBuffer : pointer; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; virtual; abstract; // 0 = fail
    function Append : tSigDBRecPointer; overload; virtual; abstract; // 0 = fail
    procedure Delete( pRec : tSigDBRecPointer ); virtual; abstract;
    function Update : tSigDBRecPointer; virtual; abstract; // = write to rec0

    procedure AfterDBOpen; virtual;
    procedure BeforeDBClose; virtual;

    procedure Lock; virtual; abstract;
    procedure Unlock; virtual; abstract;

    function UserData : TObject; virtual; abstract;


  end;

  tSigDBFileBaseFlag = ( flgEncryptedBlowfish, flgEncyptedDES );
                       // Notes; Encrypted means at read/write level
                       // Multiple encryptions are compound encryptions! and may be slow!
  tSigDBFileBaseFlags = set of tSigDBFileBaseFlag;

  TInterestedParty< T : Record > = class
  private
    { Use a descendant of this to act whenever database file is modified and register it
      The functions in this do nothing. Override the functions needed. }
  protected
  public
    procedure BeforeRecAppend( var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecAppend( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecRead( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
  end;

  TInterestedPartiesList< T : Record > = class( TTypedObjectList< TInterestedParty< T >>)
  private
    { Use a descendant of this to act whenever database file is modified and register it
      The functions in this do nothing. Override the functions needed. }
  protected
  public
    procedure BeforeRecAppend( var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecAppend( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
    procedure AfterRecRead( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); virtual;
  end;

  tSigDBFileBase< T : Record > = class( tSigDBFileBase )
  private
    fInterestedParties : TInterestedPartiesList< T >;
  protected
    type tD = packed record
      case integer of
        1 : ( DelLast, InsLast : tSigDBRecPointer; VerMajor, VerMinor : Word; Flags : tSigDBFileBaseFlags );
                                                                                  // operated as a stack   // Record 0
        2 : ( Next, Prev : tSigDBRecPointer; Data2 : T );                         // Live or Deleted Record
    end;
    type tD2 = record
      Rec : tD;            // saved to file
      UserData : tObject;  // for random user data
    end;
  protected
    fFile : File;
    fDatabase : tSigDBDatabase;

    fFields0, fFields1, fFields2: tD2; // record structure defined in inherited classes
    fRootRec: tD2;
    fDelRec, fUpdateRec : tD2;
    //fRec1, fRec2 : integer;
    fFields0RecNo, fFields1RecNo, fFields2RecNo : tSigDBRecPointer;
    fUpdateRecNo : tSigDBRecPointer;

    procedure SetOpen( pOpen : boolean ); override;
    function OpenDBFile( const pVerMajor, pVerMinor : Word ) : boolean; virtual;
    procedure CloseDBFile; virtual;
    function GetRecCount: integer; override;
    procedure OnVersionChange( const pOldVerMajor, pOldVerMinor, pNewVerMajor, pNewVerMinor : Word ); virtual;
  public
    constructor Create( const pName : string; const pDatabase : tSigDBDatabase ); reintroduce; virtual;
    destructor Destroy; override;

    {
    property CurrRec : T
             read fFields0.Rec.Data2;
    }

    property Database : tSigDBDatabase
             read fDatabase;

    procedure BeforeRecAppend( var pBuffer : T; var pUserData : TObject ); overload; virtual;
    procedure AfterRecAppend( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); overload; virtual;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); overload; virtual;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); overload; virtual;
    procedure AfterRecRead( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); overload; virtual;
    { When verriding these procedures make sur inherited is called to service interested parties}

    function Read( const pRec : tSigDBRecPointer; var pBuffer : Td2; var pIndex : tSigDBRecPointer ) : boolean; overload; virtual;
    function Read( const pRec : tSigDBRecPointer ) : boolean; overload; override;
    function Write( const pRec : tSigDBRecPointer; var pBuffer : Td2 ) : boolean; overload; virtual;
    function Write( const pRec : tSigDBRecPointer ) : boolean; overload; override;
    function Append( var pBuffer : Td2; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; virtual; // 0 = fail
    function Append : tSigDBRecPointer; overload; override; // 0 = fail
    function Update : tSigDBRecPointer; override; // = write to rec0
    procedure Delete( pRec : tSigDBRecPointer ); override;
    procedure Lock; override;
    procedure Unlock; override;

    procedure RegisterInterestedParty( pParty : TInterestedParty< T > );

    property CurrIndex : tSigDBRecPointer
             read fFields0RecNo;

    {
    property RootRec : tD
             read fRootRec;
    }
    {
    function ReadBuffer( const pRec, pBuffer : tSigDBRecPointer ) : boolean; virtual; abstract;
    function WriteBuffer( const pRec, pBuffer : tSigDBRecPointer ) : boolean; virtual; abstract;
    function AppendBuffer( pBuffer : tSigDBRecPointer ) : int64; virtual; abstract; // 0 = fail
    }

    class function Ext : string; virtual; abstract;
    class function IsIndexFile : boolean; virtual; abstract;

    class function CurrVerMajor : word; virtual;
    class function CurrVerMinor : word; virtual;

  end;

  tSigDBFileBaselist = class( tThreadObjectList )
  private
    fActiveChild : integer;
    fOpen: boolean;
    function GetFileBase( const i : integer ): tSigDBFileBase;
    function GetMax : integer;
    procedure SetActiveChild(const Value: integer);
    procedure SetOpen(const Value: boolean);
  protected
    fDatabase : tSigDBDatabase;
  public
    constructor Create( const pDatabase : tSigDBDatabase ); virtual;
    function FileExists( const pTableName : string ): boolean;

    property FileBase[ const i : integer ] : tSigDBFileBase
             read GetFileBase;
    function FileBaseWithName( const pName : string ) :  tSigDBFileBase;

    procedure AfterDBOpen; virtual;
    procedure BeforeDBClose; virtual;

    // Open / close
    property Open : boolean
             read fOpen
             write SetOpen;

    // General
    property ActiveChild : integer
             read fActiveChild
             write SetActiveChild;
    property Database : tSigDBDatabase
             read fDatabase;

    property Max : integer
             read GetMax;
  end;

  { create your own tSigDBDataRecord based on this template
    tSigDBDataRecord = packed record
      ...
  }

  {
  tSigDBDataFile = class( tSigDBFileBase )
    // really just a placeholder for < T > derived classes
  public
  end;
  }

  tSigDBDataFile< T : record > = class( tSigDBFileBase< T > )
  private
  protected
  public
    //constructor Create( const pDatabase : tSigDBDatabase ); override;

    class function RecLen : int64; virtual;
    function CompareField( const pFieldID : integer; pRec1, pRec2 : tSigDBRecPointer ) : tCompareResult; overload; override;
    function CompareField( const pFieldID : integer; pRec : tSigDBRecPointer; const pFilter : string ) : tCompareResult; overload; override;
    function CompareUpdateField( const pFieldID : integer; pRec1 : tSigDBRecPointer ) : tCompareResult; override;
    function IndexChanged( const pFieldID : integer ) : boolean; override;
    function CompareFieldDetail( const pFieldID : integer; pRec1, pRec2 : T ) : integer; overload; virtual; abstract;
             // 0 => Rec1.Field = Rec2.Field; <0 => Rec1.Field < Rec2.Field; >0 => Rec1.Field > Rec2.Field
    function CompareFieldDetail( const pFieldID : integer; pRec1 : T; const pFilter : string ) : integer; overload; virtual; abstract;
             // 0 => Rec.Field = Filter; <0 => Rec.Field < Filter; >0 => Rec.Field > Filter

    procedure BeforeRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); override;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); override;
    procedure AfterRecAppend( const pRec : tSigDBRecPointer; var pBuffer : T; var pUserData : TObject ); override;
    procedure Delete( pRec : tSigDBRecPointer ); override;

    class function Ext : string; override;
    class function IsIndexFile : boolean; override;

    function First : tSigDBRecPointer; virtual;
    function Next( const pCurr : tSigDBRecPointer )  : tSigDBRecPointer; virtual;

    function UserData: TObject; override;
  end;


  tSigDBDataFileList = class( tSigDBFileBaselist )
  private
    function GetDataFile(const i: integer): tSigDBFileBase;
  protected
  public

    property DataFile[ const i : integer ] : tSigDBFileBase
             read GetDataFile;
  end;

  tSigDBIndexRec = packed record
    DataRec    : tSigDBRecPointer;  // in record file
    LeftChild  : tSigDBRecPointer;
    RightChild : tSigDBRecPointer;
    TreeDepth  : int32;
    DBFileID   : Int32;   // only used for index files that go across multiple DB Files
                          // or multiply across a single DB File, or both
  end;

  {
  tSigDBIndexRec0 = packed record
    NotUsed    : tSigDBRecPointer;
    Root       : tSigDBRecPointer;
    Deleted    : tSigDBRecPointer;
    TreeDepth  : Int32;
    Unused     : Int32;
  end;
  }

  tSigDBFindMode = (fmEQ, fmLE, fmGE );  // differ in how to handle not found situations

  tSigDBIndexFile = class( tSigDBFileBase< tSigDBIndexRec > )
  protected
    function GetIndexField(const i: integer): tSigDBIndexField;
  private
    function GetRoot: tSigDBIndexRoot;
    function GetRootRoot: tSigDBRecPointer;
  protected
    fFields : tSigDBIndexFieldList;
    fDataFile: tSigDBFileBase;
    function FilterValid( const pIndex : integer; const pValue : string ) : boolean;
    function IsValidList( const pValue : string ) : boolean;
    function IsSingleValue( const pValue : string ) : boolean; // depends on destination field type
  public
    constructor Create( const pName : string; const pDatabase : tSigDBDatabase; const pDataFile : tSigDBFileBase ); reintroduce; virtual;

    function Find( pMode : tSigDBFindMode; const pFieldCount : integer = 0 ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function FindUpdateRec( pMode : tSigDBFindMode ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function AppendData : tSigDBRecPointer; overload;
    function UpdateData : tSigDBRecPointer; overload;
    function ReadData( const pRec : tSigDBRecPointer ) : boolean;
    function WriteData( const pRec : tSigDBRecPointer ) : boolean;

    function CompareField( const pFieldID : integer; pRec1, pRec2 : tSigDBRecPointer ) : tCompareResult; overload; override;
    function CompareField( const pFieldID : integer; pRec : tSigDBRecPointer; const pFilter : string ) : tCompareResult; overload; override;
    function CompareUpdateField( const pFieldID : integer; pRec1 : tSigDBRecPointer ) : tCompareResult; override;

    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure DeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure DeleteUpdateIndex( const pDataFile : tSigDBFileBase );
    procedure UpdateIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    function IndexChanged( const pDataFile : tSigDBFileBase ) : boolean; reintroduce;

    //procedure RebuildIndex; // only used for single index build, not for any of the multiple rebuilds

    property DataFile : tSigDBFileBase
             read fDataFile;

    property Fields : tSigDBIndexFieldList
             read fFields;
    property Field[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    property DataRec    : tSigDBRecPointer
             read fFields0.Rec.Data2.DataRec
             write fFields0.Rec.Data2.DataRec;  // in record file
    property LeftChild  : tSigDBRecPointer
             read fFields0.Rec.Data2.LeftChild
             write fFields0.Rec.Data2.LeftChild;
    property RightChild : tSigDBRecPointer
             read fFields0.Rec.Data2.RightChild
             write fFields0.Rec.Data2.RightChild;
    property TreeDepth : Int32
             read fFields0.Rec.Data2.TreeDepth
             write fFields0.Rec.Data2.TreeDepth;
    property DBFileID : Int32
             read fFields0.Rec.Data2.DBFileID
             write fFields0.Rec.Data2.DBFileID;
    property Root : tSigDBIndexRoot
             read GetRoot;
    property RootRoot : tSigDBRecPointer
             read GetRootRoot;

    class function Ext : string; override;
    class function IsIndexFile : boolean; override;

    function First( var pCurr : tSigDBIndex ) : tSigDBRecPointer; virtual; // points to DB File!
    function Next( var pCurr : tSigDBIndex )  : tSigDBRecPointer; virtual;

    function UserData: TObject; override;
  end;

  tSigDBIndexFileList = class( tSigDBFileBaselist )
  private
    function GetIndexFile(const i: integer): tSigDBIndexFile;
  protected
    procedure Reassign( var OldValue : tSigDBIndexFile; const NewValue : tSigDBIndexFile );
  public
    property  IndexFile[ const i : integer ] : tSigDBIndexFile
              read GetIndexFile;
    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure DeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure UpdateIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );

  end;

  tSigDBDatabase = class
  private
    fPath : string;
    fPendingActions: tSigPendingActionList;
    fLock: TObject;
    fOpen: boolean;
    function GetIndexFile(const i: integer): tSigDBIndexFile;
    function GetDataFile(const i : integer): tSigDBFileBase;
    procedure SetOpen(const Value: boolean);
  protected
    fDataFiles: tSigDBDataFileList;
    fIndexFiles: tSigDBIndexFileList;
  public
    constructor Create( const pPath : string ); virtual;
    destructor Destroy; override;

    procedure AfterDBOpen; virtual;
    procedure BeforeDBClose; virtual;

    procedure Format( const pDataFile : tSigDBFileBase = nil);
    //function Open : boolean;
    //procedure Close;

    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure DeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure UpdateIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );

    property Path : string
             read fPath;
    property DataFiles : tSigDBDataFileList
             read fDataFiles;
    property IndexFiles : tSigDBIndexFileList
             read fIndexFiles;

    property IndexFile[ const i : integer ] : tSigDBIndexFile
             read GetIndexFile;
    property DataFile[ const i : integer ] : tSigDBFileBase
             read GetDataFile;

    property PendingActions : tSigPendingActionList
             read fPendingActions;

    procedure Lock;  // database only really needs to be locked or unlocked during Open/Close
    procedure Unlock;

    property Open : boolean
             read fOpen
             write SetOpen;
  end;

implementation

{ tSigDBDatabase }

procedure tSigDBDatabase.AddIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  Lock;
  try
    fIndexFiles.AddIndex( pDataFile, pRec );
  finally
    Unlock;
  end;
end;

{
procedure tSigDBDatabase.Close;
begin
  fDataFiles.Open := FALSE;
  fIndexFiles.Open := FALSE;
end;
}

procedure tSigDBDatabase.AfterDBOpen;
begin
  fDataFiles.AfterDBOpen;
  fIndexFiles.AfterDBOpen;
end;

procedure tSigDBDatabase.BeforeDBClose;
begin
  fDataFiles.BeforeDBClose;
  fIndexFiles.BeforeDBClose;
end;

constructor tSigDBDatabase.Create( const pPath : string );
begin
  inherited Create;

  fLock := tObject.Create;

  fPendingActions := tSigPendingActionList.Create;

  fPath := pPath;

  //fDataFiles  :=  tSigDBDataFileList.Create( self ); set by descendants
  // fIndexFiles := tSigDBIndexFileList.Create( self ); set by descendants

end;

procedure tSigDBDatabase.DeleteIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  Lock;
  try
    fIndexFiles.DeleteIndex( pDataFile, pRec );
  finally
    Unlock;
  end;
end;

destructor tSigDBDatabase.Destroy;
begin
  Open := FALSE;

  fPendingActions.Free;
  fLock.Free;

  inherited;
end;

procedure tSigDBDatabase.Format( const pDataFile : tSigDBFileBase = nil);
var
  i : integer;
  iFile : string;
  iSearch : tSearchRec;
  iAttr : integer;
  iToDelete : tStringList;
  iExt : string;
  iSaveOpen : boolean;
  iPath : string;
  iName : string;
  iIndexFile : tSigDBIndexFile;
begin
  Lock;
  iSaveOpen := Open;
  try
    Open := FALSE;
    iAttr := 0;
    //remove all dta and idx file from directory
    iToDelete := tStringList.Create;
    try
      iPath := fPath + '\*.*';
      if FindFirst( iPath, iAttr, iSearch ) = 0 then
      begin
        repeat
          iFile := iSearch.Name;
          iExt := ExtractFileExt( iFile );
          if assigned( pDataFile ) then
          begin
            iName := ExtractFileName( iFile );
            iName := ChangeFileExt(iName, '' );
            if SameText( iExt, '.dta' ) then
            begin
              // see if this is the physical file
              if SameText( iName, pDataFile.Name ) then
              begin
                iToDelete.Add( iFile );
              end;
            end
            else if SameText( iExt, '.idx' ) then
            begin
              // see if this index file is associated with the physical file
              iIndexFile := self.IndexFiles.FileBaseWithName( iName ) as tSigDBIndexFile;
              if assigned( iIndexFile ) then
              begin
                if iIndexFile.DataFile = pDataFile then
                begin
                  iToDelete.Add( iFile );
                end;
              end;
            end;
          end
          else if SameText( iExt, '.idx' ) or SameText( iExt, '.dta' ) then
          begin
            iToDelete.Add( iFile );
          end;
        until FindNext( iSearch ) <> 0;
        FindClose( iSearch );
        for i := 0 to iToDelete.Count - 1 do
        begin
          iPath := fPath + '\' + iToDelete[ i ];
          DeleteFile( iPath );
        end;
      end;
    finally
      iToDelete.Free;
    end;
    // OK all files removed
    // Now to create new ones.
    Open := iSaveOpen;
  finally
    Unlock;
  end;
end;

function tSigDBDatabase.GetDataFile(const i: integer): tSigDBFileBase;
begin
  Result := fDataFiles.DataFile[ i ];
end;

function tSigDBDatabase.GetIndexFile(const i: integer): tSigDBIndexFile;
begin
  Result := fIndexFiles.IndexFile[ i ];
end;

procedure tSigDBDatabase.Lock;
begin
  TMonitor.Enter( fLock );
end;

procedure tSigDBDatabase.SetOpen(const Value: boolean);
begin
  if fOpen <> Value then
  begin
    Lock;
    try
      fOpen := Value;
      if Value then
      begin
        fDataFiles.Open := TRUE;
        fIndexFiles.Open := TRUE;
        fOpen := fDataFiles.Open and fIndexFiles.Open;
        if fOpen then
        begin
          // OK to execute pending actions, if any
          fPendingActions.ExecuteTick;
          AfterDBOpen;
        end;
      end
      else
      begin
        BeforeDBClose;
        fDataFiles.Open := FALSE;
        fIndexFiles.Open := FALSE;
      end;
    finally
      Unlock;
    end;
  end;
end;

procedure tSigDBDatabase.Unlock;
begin
  TMonitor.Exit( fLock );
end;

procedure tSigDBDatabase.UpdateIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  Lock;
  try
    fIndexFiles.UpdateIndex( pDataFile, pRec );
  finally
    Unlock;
  end;
end;

{
function tSigDBDatabase.Open: boolean;
begin
  fDataFiles.Open := TRUE;
  fIndexFiles.Open := TRUE;
  Result := fDataFiles.Open or fIndexFiles.Open;
  if Result then
  begin
    // OK to execute pending actions, if any
    fPendingActions.ExecuteTick;
  end;
end;
}

{ tSigDBDataFileList }

{
procedure tSigDBDataFileList.AddFile(const pNewFileName: string);
begin
  if FileExists( pNewFileName ) then
  begin
    raise tSigDBException.Create('A table with name "' + pNewFileName + '" already exists');
  end;
  // else
  AddDataFileForced( pNewFileName );
end;
}

function tSigDBDataFileList.GetDataFile(const i: integer): tSigDBFileBase;
begin
  Result := FileBase[ i ] as tSigDBFileBase;
end;

{ tSigDBIndexFileList }

procedure tSigDBIndexFileList.AddIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    IndexFile[ i ].AddIndex( pDataFile, pRec );
  end;
end;

procedure tSigDBIndexFileList.DeleteIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    IndexFile[ i ].DeleteIndex( pDataFile, pRec );
  end;
end;

function tSigDBIndexFileList.GetIndexFile(const i: integer): tSigDBIndexFile;
begin
  Result := Items[ i ] as tSigDBIndexFile;
end;

procedure tSigDBIndexFileList.Reassign(var OldValue: tSigDBIndexFile;
  const NewValue: tSigDBIndexFile);
begin
  Database.Lock;
  try
    if assigned( OldValue ) then
    begin
      OldValue.Open := FALSE;
      Remove( OldValue );
    end;
    OldValue := NewValue;
    if assigned( OldValue ) then
    begin
      Add( OldValue );
      if Open then
      begin
        OldValue.Open := TRUE;
      end;
    end;
  finally
    Database.Unlock;
  end;
end;

procedure tSigDBIndexFileList.UpdateIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    if IndexFile[ i ].IndexChanged( pDataFile ) then
    begin
      IndexFile[ i ].DeleteUpdateIndex( pDataFile );
      IndexFile[ i ].AddIndex( pDataFile, pRec );
    end;
  end;
end;

{ tSigDBIndexFieldList }

function tSigDBIndexFieldList.Compare( const pDBRec1: tSigDBRecPointer; pFieldCount : integer): tCompareResult;
begin
  Result := Compare( pDBRec1, 0, pFieldCount );
end;

function tSigDBIndexFieldList.Compare(const pDBRec1,
  pDBRec2: tSigDBRecPointer; pFieldCount : integer): tCompareResult;
var
  i: Integer;
begin
  if pFieldCount = 0 then
  begin
    pFieldCount := Count;
  end;
  for i := 0 to pFieldCount - 1 do
  begin
    Result := CompareField( i, pDBRec1, pDBRec2 );
    case Result of
      crLT, crGT:
      begin
        exit;
      end;
    end;
  end;
  // else
  Result := crEQ;
end;

function tSigDBIndexFieldList.CompareField(const pIndex: integer; const pDBRec1,
  pDBRec2: tSigDBRecPointer): tCompareResult;
begin
  with IndexField[ pIndex ] do
  begin
    case FieldType of
      ft_String,
      ft_Integer,
      ft_Date_Time,
      ft_Field_Pointer: raise Exception.Create('Unexpected Index Field Type');
      ft_Index_Ascending:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec1, pDBRec2 );
      end;
      ft_Index_Descending:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec2, pDBRec1 ); // notice field order reversal to reverse sense of compare
      end;
      ft_Filter_LT,
      ft_Filter_LE,
      ft_Filter_EQ,
      ft_Filter_NE,
      ft_Filter_GE,
      ft_Filter_GT,
      ft_Filter_in,
      ft_Filter_not_in: // not used in comparing
      begin
        Result := crEQ;
      end;
      else
      begin
        raise Exception.Create('Unrecognised Filter Type');
      end;
    end;
  end;
end;

function tSigDBIndexFieldList.CompareUpdateField(const pIndex: integer;
  const pDBRec1: tSigDBRecPointer): tCompareResult;
begin
  with IndexField[ pIndex ] do
  begin
    case FieldType of
      ft_String,
      ft_Integer,
      ft_Date_Time,
      ft_Field_Pointer: raise Exception.Create('Unexpected Index Field Type');
      ft_Index_Ascending:
      begin
        Result := DataFile.CompareUpdateField( DataFieldID, pDBRec1 );
      end;
      ft_Index_Descending:
      begin
        case DataFile.CompareUpdateField( DataFieldID, pDBRec1 ) of
          crLT: Result := crGT;
          crEQ: Result := crEQ;
          crGT: Result := crLT;
          else
          begin
            raise Exception.Create('Unrecognised Index Type');
          end;
        end;
      end;
      ft_Filter_LT,
      ft_Filter_LE,
      ft_Filter_EQ,
      ft_Filter_NE,
      ft_Filter_GE,
      ft_Filter_GT: // not used in comparing
      begin
        Result := crEQ;
      end;
      else
      begin
        raise Exception.Create('Unrecognised Filter Type');
      end;
    end;
  end;
end;

function tSigDBIndexFieldList.CompareUpdateRec(
  const pDBRec1: tSigDBRecPointer): tCompareResult;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := CompareUpdateField( i, pDBRec1 );
    case Result of
      crLT, crGT:
      begin
        exit;
      end;
    end;
  end;
  // else
  Result := crEQ;
end;

constructor tSigDBIndexFieldList.Create( const pOwner : tSigDBIndexFile; const pDataFile : tSigDBFileBase );
begin
  inherited Create( TRUE );

  fOwner  := pOwner;
  fDataFile := pDataFile;
  fRoot := tSigDBIndexRoot.Create( pOwner, 0, 0 );

end;

function tSigDBIndexFieldList.FieldValid(const pIndex: integer;
  const pDBRec: tSigDBRecPointer): boolean;
begin
  Result := IndexField[ pIndex ].FieldValid( pDBRec );
end;

function tSigDBIndexFieldList.GetIndexField(const i: integer): tSigDBIndexField;
begin
  Result := Items[ i ] as tSigDBIndexField;
end;

function tSigDBIndexFieldList.IndexChanged: boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if DataFile.IndexChanged( i ) then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

function tSigDBIndexFieldList.RecValid(const pDBRec: tSigDBRecPointer): boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if not FieldValid( i, pDBRec ) then
    begin
      Result := FALSE;
      exit;
    end;
  end;
  // else
  Result := TRUE;
end;

procedure tSigDBIndexFieldList.SetOpen(const Value: boolean);
begin
  if Owner.Open then
  begin
    fOpen := Value;
  end
  else
  begin
    fOpen := FALSE;
  end;
  Root.FreeChildren;
  if fOpen then
  begin
    // load the root record index
    Root.fLeftChildIndex := Owner.fRootRec.Rec.Data2.LeftChild;
  end
  else
  begin
    Root.fLeftChildIndex := 0;
  end;
end;

{ tSigDBIndexFile }

procedure tSigDBIndexFile.AddIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  iNew : tSigDBIndex;
begin
  if DataFile = pDataFile then
  begin
    if fFields.RecValid( pRec ) then
    begin
      iNew := tSigDBIndex.Create( self, 0, pRec );
      //iNew.fSigDBIndex := pRec;
      if Root.LeftChildIndex = 0 then
      begin
        Root.LeftChild := iNew;
        iNew.Parent := Root;
      end
      else
      begin
        Root.LeftChild.Add( iNew );
      end;
    end;
  end;
end;

function tSigDBIndexFile.AppendData: tSigDBRecPointer;
begin
  Result := DataFile.Append;
end;

function tSigDBIndexFile.CompareField(const pFieldID: integer; pRec1,
  pRec2: tSigDBRecPointer): tCompareResult;
begin
  raise Exception.Create('Compare Field in Index files not allowed');
end;

function tSigDBIndexFile.CompareField(const pFieldID: integer;
  pRec: tSigDBRecPointer; const pFilter: string): tCompareResult;
begin
  raise Exception.Create('Compare Field in Index files not allowed');
end;

function tSigDBIndexFile.CompareUpdateField(const pFieldID: integer;
  pRec1: tSigDBRecPointer): tCompareResult;
begin
  raise Exception.Create('Compare Update Field in Index files not allowed');
end;

constructor tSigDBIndexFile.Create( const pName : string; const pDatabase : tSigDBDatabase; const pDataFile : tSigDBFileBase );
begin
  inherited Create( pName, pDatabase );

  fDataFile := pDataFile;
  fFields   := tSigDBIndexFieldList.Create( self, pDataFile );
end;

procedure tSigDBIndexFile.DeleteIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  iToDelete : tSigDBRecPointer;
begin
  if DataFile = pDataFile then
  begin
    DataFile.Lock;
    try
      Datafile.Read( pRec );
      iToDelete := Find( fmEQ );
      if iToDelete > 0 then
      begin
        Delete( iToDelete );
      end;
    finally
      Unlock;
    end;
  end;
end;

procedure tSigDBIndexFile.DeleteUpdateIndex(const pDataFile: tSigDBFileBase);
var
  iToDelete : tSigDBRecPointer;
begin
  if DataFile = pDataFile then
  begin
    DataFile.Lock;
    try
      iToDelete := FindUpdateRec( fmEQ );
      if iToDelete > 0 then
      begin
        Delete( iToDelete );
      end;
    finally
      Unlock;
    end;
  end;
end;

class function tSigDBIndexFile.Ext: string;
begin
  Result := '.idx';
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

function tSigDBIndexFile.Find(pMode: tSigDBFindMode; const pFieldCount : integer): tSigDBRecPointer;
var
  iCurrent : tSigDBIndex;
begin
  if not Open then
  begin
    raise Exception.Create('File not open');
  end;
  // Root.LeftChild is the start point for our search
  iCurrent := Root.LeftChild as tSigDBIndex;
  while assigned( iCurrent ) do
  begin
    //DataFile.Read( iCurrent.SigDBIndex );
    //case fFields.Compare( fFields0.Data.DataRec ) of
    case fFields.Compare( iCurrent.SigDBIndex, pFieldCount ) of
      crEQ:// match found
      begin
        Result := iCurrent.SigDBIndex;
        // it is possible that there are duplicate keys so make sure that we have the lowest
        iCurrent := iCurrent.Prev as tSigDBIndex;
        while assigned( iCurrent ) do
        begin
          if fFields.Compare( iCurrent.SigDBIndex, pFieldCount ) = crEQ then
          begin
            Result := iCurrent.SigDBIndex;
            iCurrent := iCurrent.Prev as tSigDBIndex;
          end
          else
          begin
            exit;
          end;
        end;
        exit;
      end;
      crLT:
      begin
        // try again with Right Child
        if iCurrent.RightChildIndex = 0 then
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmLE: Result := fFields0.Rec.Data2.DataRec;
            fmGE:
            begin
              iCurrent := iCurrent.Next as tSigDBIndex;
              Read( iCurrent.SigDBIndex );
              Result := fFields0.Rec.Data2.DataRec;
            end;
            else
            begin
              raise Exception.Create('Unrecognised "Find" Mode');
            end;

          end;
          exit;
        end
        else
        begin
          iCurrent := iCurrent.RightChild as tSigDBIndex;
        end;
      end;
      crGT:
      begin
        // try again with Left Child
        if iCurrent.LeftChildIndex = 0 then
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmGE: Result := fFields0.Rec.Data2.DataRec;
            fmLE:
            begin
              iCurrent := iCurrent.Prev as tSigDBIndex;
              Read( iCurrent.SigDBIndex );
              Result := fFields0.Rec.Data2.DataRec;
            end;
            else
            begin
              raise Exception.Create('Unrecognised "Find" Mode');
            end;
          end;
          exit;
        end
        else
        begin
          iCurrent := iCurrent.LeftChild as tSigDBIndex;
        end;
      end;
    end;
  end;
  // if we get here internal structure ensures that the only way to leave
  // the loop is via an exit command. Therefore the only way to get here
  // is with an empty file
  Result := 0;
  exit;

end;

function tSigDBIndexFile.FindUpdateRec(pMode: tSigDBFindMode): tSigDBRecPointer;
var
  iCurrent : tSigDBIndex;
begin
  if not Open then
  begin
    raise Exception.Create('File not open');
  end;
  // Root.LeftChild is the start point for our search
  iCurrent := Root.LeftChild as tSigDBIndex;
  while assigned( iCurrent ) do
  begin
    //DataFile.Read( iCurrent.SigDBIndex );
    //case fFields.Compare( fFields0.Data.DataRec ) of
    case fFields.CompareUpdateRec( iCurrent.SigDBIndex ) of
      crEQ:// match found
      begin
        Result := iCurrent.SigDBIndex;
        exit;
      end;
      crLT:
      begin
        // try again with Right Child
        if iCurrent.RightChildIndex = 0 then
        begin
          iCurrent := iCurrent.RightChild as tSigDBIndex;
        end
        else
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmLE: Result := fFields0.Rec.Data2.DataRec;
            fmGE:
            begin
              iCurrent := iCurrent.Next as tSigDBIndex;
              Read( iCurrent.SigDBIndex );
              Result := fFields0.Rec.Data2.DataRec;
            end;
            else
            begin
              raise Exception.Create('Unrecognised "Find" Mode');
            end;

          end;
          exit;
        end;
      end;
      crGT:
      begin
        // try again with Left Child
        if iCurrent.LeftChildIndex = 0 then
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmGE: Result := fFields0.Rec.Data2.DataRec;
            fmLE:
            begin
              iCurrent := iCurrent.Prev as tSigDBIndex;
              Read( iCurrent.SigDBIndex );
              Result := fFields0.Rec.Data2.DataRec;
            end;
            else
            begin
              raise Exception.Create('Unrecognised "Find" Mode');
            end;
          end;
          exit;
        end
        else
        begin
          iCurrent := iCurrent.LeftChild as tSigDBIndex;
        end;
      end;
    end;
  end;
  // if we get here internal structure ensures that the only way to leave
  // the loop is via an exit command. Therefore the only way to get here
  // is with an empty file
  Result := 0;
  exit;
end;

function tSigDBIndexFile.First( var pCurr : tSigDBIndex ): tSigDBRecPointer;
begin
  Lock;
  try
    pCurr := Root.First as tSigDBIndex;
    if assigned( pCurr ) then
    begin
      Result := pCurr.fSigDBIndex;
      DataFile.Read( Result );
    end
    else
    begin
      Result := 0;
    end;
  finally
    Unlock;
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

function tSigDBIndexFile.GetRoot: tSigDBIndexRoot;
begin
  Result := fFields.Root;
end;

function tSigDBIndexFile.GetRootRoot: tSigDBRecPointer;
begin
  Result := fRootRec.Rec.Data2.LeftChild;
end;

function tSigDBIndexFile.UserData: tObject;
begin
  Result := DataFile.UserData;
end;

function tSigDBIndexFile.WriteData(const pRec: tSigDBRecPointer): boolean;
begin
  Result := DataFile.Write( pRec );
end;

function tSigDBIndexFile.IndexChanged( const pDataFile : tSigDBFileBase ): boolean;
begin
  if DataFile = pDataFile then
  begin
    Result := fFields.IndexChanged;
  end
  else
  begin
    Result := FALSE;
  end;
end;

class function tSigDBIndexFile.IsIndexFile: boolean;
begin
  Result := TRUE;
end;

function tSigDBIndexFile.IsSingleValue(const pValue: string): boolean;
begin
  raise Exception.Create('To do');
end;

function tSigDBIndexFile.IsValidList(const pValue: string): boolean;
begin
  raise Exception.Create('To do');
end;

function tSigDBIndexFile.Next(var pCurr: tSigDBIndex): tSigDBRecPointer;
begin
  Lock;
  try
    pCurr := pCurr.Next as tSigDBIndex;
    if assigned( pCurr ) then
    begin
      Result := pCurr.fSigDBIndex;
      DataFile.Read( Result );
    end
    else
    begin
      Result := 0;
    end;
  finally
    Unlock;
  end;
end;

function tSigDBIndexFile.ReadData( const pRec : tSigDBRecPointer ) : boolean;
begin
  Result := dataFile.Read( pRec );
end;

function tSigDBIndexFile.UpdateData: tSigDBRecPointer;
begin
  Result := DataFile.Update;
end;

procedure tSigDBIndexFile.UpdateIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  DeleteUpdateIndex( pDataFile );
  AddIndex( pDataFile, pRec );
end;

{ tSigDBIndexField }

procedure tSigDBIndexField.Clear;
begin
  inherited;

  fFieldType := ft_Index_Ascending;
end;

constructor tSigDBIndexField.Create( const pOwner : tSigDBIndexFieldList;
                        const pFieldType : tSigDBFieldType;
                        const pDataFieldID : integer;
                        const pFilter : string = '';
                        const pDataFileID : Int32 = 0 );
begin
  inherited Create;
  fOwner := pOwner;
  fFieldType := pFieldType;
  fDataFieldID := pDataFieldID;
  fDataFileID := pDataFileID;
  fFilter := pFilter;
end;

function tSigDBIndexField.FieldValid(const pDBRec: tSigDBRecPointer): boolean;
begin
  Result := TRUE;
end;

{ tSigDBFileBaselist }

procedure tSigDBFileBaselist.AfterDBOpen;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FileBase[ i ].AfterDBOpen;
  end;
end;

procedure tSigDBFileBaselist.BeforeDBClose;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FileBase[ i ].BeforeDBClose;
  end;
end;

constructor tSigDBFileBaselist.Create(const pDatabase: tSigDBDatabase);
begin
  inherited Create( TRUE );

  fDatabase := pDatabase;
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

function tSigDBFileBaselist.GetFileBase( const i : integer ): tSigDBFileBase;
begin
  Result := Items[ i ] as tSigDBFileBase;
end;

function tSigDBFileBaselist.GetMax: integer;
begin
  Result := Count - 1;
end;

procedure tSigDBFileBaselist.SetActiveChild(const Value: integer);
begin
  fActiveChild := Value;
end;

procedure tSigDBFileBaselist.SetOpen(const Value: boolean);
var
  i: Integer;
begin
  fOpen := Value;
  for i := 0 to Max do
  begin
    with FileBase[ i ] do
    begin
      Open := Value;
      if not Open then
      begin
        fOpen := FALSE;
      end;
    end;
  end;
end;

{ tSigDBDataFile<T> }

procedure tSigDBDataFile<T>.AfterRecWrite(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  inherited;
  // buffers are in fFields0 and old value in fUpdateRec.
  // data buffer can use these values to decide if
  // index needs to be updated
  Database.UpdateIndex( self, pRec );
end;

procedure tSigDBDataFile<T>.BeforeRecWrite(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  inherited;
  // load the current record to the update buffer

  Read( pRec, fUpdateRec, fUpdateRecNo );
end;

function tSigDBDataFile<T>.CompareField(const pFieldID: integer; pRec1,
  pRec2: tSigDBRecPointer): tCompareResult;
var
  iTest : integer;
begin
  {
    Our overridden descendants must define CompareFieldDetail
    which does the detailed work of comparing fields after we have
    made sure the correct records are loaded.

    we use the following function to load the data.

    function Read( const pRec : int64; pBuffer : pointer ) : boolean; virtual;

    A record number zero refers to the memory record fFields0, and is not loaded
    fRec1 and fRec2 refer to the current records in fFields 1 and 2 respectively

    Note that CompareFieldDetail is only required to give values <0 =0 or >0

  }

  if not Open then
  begin
    raise Exception.Create('File not open');
  end;

  if pRec1 = pRec2 then
  begin
    Result := crEQ;
    exit;
  end;

  if pRec1 = 0 then
  begin
    // memory rec - only need to check pRec2
    if pRec2 = fFields2RecNo then
    begin
      iTest := CompareFieldDetail( pFieldID, fFields0.Rec.Data2, fFields2.Rec.Data2 );
    end
    else if pRec2 = fFields1RecNo then
    begin
      iTest := CompareFieldDetail( pFieldID, fFields0.Rec.Data2, fFields1.Rec.Data2 );
    end
    else
    begin
      // we need to load a record - use record 2 arbitrarily
      Read( pRec2, fFields2, fFields2RecNo );
      iTest := CompareFieldDetail( pFieldID, fFields0.Rec.Data2, fFields2.Rec.Data2 );
    end;
  end
  else if pRec2 = 0 then
  begin
    // memory rec - only need to check pRec1
    if pRec1 = fFields1RecNo then
    begin
      iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fFields0.Rec.Data2 );
    end
    else if pRec1 = fFields2RecNo then
    begin
      iTest := CompareFieldDetail( pFieldID, fFields2.Rec.Data2, fFields0.Rec.Data2 );
    end
    else
    begin
      // we need to load a record - use record 1 arbitrarily
      Read( pRec1, fFields1, fFields1RecNo );
      iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fFields0.Rec.Data2 );
    end;
  end
  else if pRec1 = fFields1RecNo then
  begin
    // rec 1 loaded, just need to check record 2. We already know that this is not zero
    // and also that this is not fRec1, because we tested for pRec1 = pRec2 earlier
    // therefore we just need to check whether to load fFields2
    if pRec2 <> fFields2RecNo then
    begin
      // we need to load a record - must use record 2 because record 1 is in use
      Read( pRec2, fFields2, fFields2RecNo );
    end;
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fFields2.Rec.Data2 );
  end
  else if pRec1 = fFields2RecNo then
  begin
    // rec 2 loaded, just need to check record 1. We already know that this is not zero
    // and also that this is not fRec1, because we tested for pRec1 = pRec2 earlier
    // therefore we just need to check whether to load fFields1
    if pRec2 <> fFields1RecNo then
    begin
      // we need to load a record - must use record 1 because record 2 is in use
      Read( pRec2, fFields1, fFields1RecNo );
    end;
    iTest := CompareFieldDetail( pFieldID, fFields2.Rec.Data2, fFields1.Rec.Data2 ); // note order of test!!!
  end
  else if pRec2 = fFields2RecNo then
  begin
    // rec 2 loaded, just need to check record 1. We already know that this is not zero
    // and also that this is not fRec1, because we tested for pRec1 = pRec2 earlier
    // therefore we just need to check whether to load fFields1
    if pRec1 <> fFields1RecNo then
    begin
      // we need to load a record - must use record 1 because record 2 is in use
      Read( pRec1, fFields1, fFields1RecNo );
    end;
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fFields2.Rec.Data2 );
  end
  else if pRec2 = fFields1RecNo then
  begin
    // rec 2 loaded, just need to check record 1. We already know that this is not zero
    // and also that this is not fRec1, because we tested for pRec1 = pRec2 earlier
    // therefore we just need to check whether to load fFields2
    if pRec1 <> fFields2RecNo then
    begin
      // we need to load a record - must use record 2 because record 1 is in use
      Read( pRec1, fFields2, fFields2RecNo );
    end;
    iTest := CompareFieldDetail( pFieldID, fFields2.Rec.Data2, fFields1.Rec.Data2 ); // note order of test!!!
  end
  else
  begin
    // No records are loaded so we need to load both!
    Read( pRec1, fFields1, fFields1RecNo );
    Read( pRec2, fFields2, fFields2RecNo );
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fFields2.Rec.Data2 );
  end;
  if iTest < 0 then
  begin
    Result := crLT;
  end
  else if iTest = 0 then
  begin
    Result := crEQ;
  end
  else
  begin
    Result := crGT;
  end;
end;

function tSigDBDataFile<T>.CompareField(const pFieldID: integer;
  pRec: tSigDBRecPointer; const pFilter: string): tCompareResult;
var
  iTest : integer;
begin
  {
    Our overridden descendants must define CompareFieldDetail
    which does the detailed work of comparing the field after we have
    made sure the correct records are loaded.

    we use the following function to load the data.

    function Read( const pRec : int64; pBuffer : pointer ) : boolean; virtual;

    A record number zero refers to the memory record fFields0, and is not loaded
    fRec1 and fRec2 refer to the current records in fFields 1 and 2 respectively

    Note that CompareFieldDetail is only required to give values <0 =0 or >0

  }

  if not Open then
  begin
    raise Exception.Create('File not open');
  end;

  if pRec = 0 then
  begin
    // memory rec - only need to check pRec2
    iTest := CompareFieldDetail( pFieldID, fFields0.Rec.Data2, pFilter );
  end
  else if pRec = fFields1RecNo then
  begin
    // rec loaded into area 1. We already know that this is not zero
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, pFilter );
  end
  else if pRec = fFields2RecNo then
  begin
    // rec loaded into area 2. We already know that this is not zero
    iTest := CompareFieldDetail( pFieldID, fFields2.Rec.Data2, pFilter ); // note order of test!!!
  end
  else
  begin
    // No record loaded
    Read( pRec, fFields1, fFields1RecNo );
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, pFilter );
  end;
  if iTest < 0 then
  begin
    Result := crLT;
  end
  else if iTest = 0 then
  begin
    Result := crEQ;
  end
  else
  begin
    Result := crGT;
  end;
end;

function tSigDBDataFile<T>.CompareUpdateField(const pFieldID: integer;
  pRec1: tSigDBRecPointer): tCompareResult;
var
  iTest : integer;
begin
  {
    Our overridden descendants must define CompareFieldDetail
    which does the detailed work of comparing fields after we have
    made sure the correct records are loaded.

    we use the following function to load the data.

    function Read( const pRec : int64; pBuffer : pointer ) : boolean; virtual;

    A record number zero refers to the memory record fFields0, and is not loaded
    fRec1 and fRec2 refer to the current records in fFields 1 and 2 respectively

    Note that CompareFieldDetail is only required to give values <0 =0 or >0

  }

  if not Open then
  begin
    raise Exception.Create('File not open');
  end;

  if pRec1 = fFields1RecNo then
  begin
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fUpdateRec.Rec.Data2 );
  end
  else if pRec1 = fFields2RecNo then
  begin
    iTest := CompareFieldDetail( pFieldID, fFields2.Rec.Data2, fUpdateRec.Rec.Data2 );
  end
  else     // can't test fFields0 because those fields are volatile
  begin
    // records not loaded!
    Read( pRec1, fFields1, fFields1RecNo );
    iTest := CompareFieldDetail( pFieldID, fFields1.Rec.Data2, fUpdateRec.Rec.Data2 );
  end;
  if iTest < 0 then
  begin
    Result := crLT;
  end
  else if iTest = 0 then
  begin
    Result := crEQ;
  end
  else
  begin
    Result := crGT;
  end;
end;

procedure tSigDBDataFile<T>.Delete(pRec: tSigDBRecPointer);
begin
  Database.DeleteIndex( self, pRec );
  inherited;
end;

class function tSigDBDataFile<T>.Ext: string;
begin
  Result := '.dta';
end;

function tSigDBDataFile<T>.First: tSigDBRecPointer;
begin
  Lock;
  try
    // for physical files it is just effectively a random order (actually more like last)
    Result := fRootRec.Rec.InsLast;
    Read( Result );
  finally
    Unlock;
  end;
end;

function tSigDBDataFile<T>.UserData: TObject;
begin
  Result := fFields0.UserData;
end;

function tSigDBDataFile<T>.IndexChanged(const pFieldID: integer): boolean;
begin
  Result := CompareFieldDetail( pFieldID, fFields0.Rec.Data2, fUpdateRec.Rec.Data2 ) <> 0;
end;

class function tSigDBDataFile<T>.IsIndexFile: boolean;
begin
  Result := FALSE;
end;

function tSigDBDataFile<T>.Next( const pCurr : tSigDBRecPointer ): tSigDBRecPointer;
begin
  // for physical files it is just effectively a random order (actually more like prev)
  Lock;
  try
    Read( pCurr ); // safety first - probably already there
    Result := fFields0.Rec.Next;
    Read( Result );
  finally
    Unlock;
  end;
end;

procedure tSigDBDataFile<T>.AfterRecAppend(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  inherited;
  Database.AddIndex( self, pRec );
end;

class function tSigDBDataFile<T>.RecLen: int64;
begin
  Result := SizeOf( tD );
end;

{ tSigDBIndex }

constructor tSigDBIndex.Create(const pIndexFile: tSigDBIndexFile; const pCurrIndex, pDBIndex : integer);
begin
  inherited Create;
  fIndexFile := pIndexFile;
  if self is tSigDBIndexRoot then
  begin
    // pCurrIndex is always zero for Root, but the root record is not read
    // until file is open

  end
  else if pCurrIndex = 0 then // The root record is of type tSigDBIndexRoot, so we are adding new record
  begin
    // we need to add new record to index file
    pIndexFile.Lock;
    try
      pIndexFile.LeftChild := 0;
      pIndexFile.RightChild := 0;
      pIndexFile.DataRec := pDBIndex;
      fCurrIndex := pIndexFile.Append();
      fSigDBIndex := pDBIndex;
    finally
      pIndexFile.Unlock;
    end;
  end
  else
  begin
    // not created unless file is open
    fCurrIndex := pCurrIndex;
    pIndexFile.Lock;
    try
      pIndexFile.Read( fCurrIndex );
      fLeftChildIndex := pIndexFile.LeftChild;
      fRightChildIndex := pIndexFile.RightChild;
      fTreeDepth := pIndexFile.TreeDepth;
      fSigDBIndex := pIndexFile.DataRec;
    finally
      pIndexFile.Unlock;
    end;
  end;
end;

destructor tSigDBIndex.Destroy;
begin
  inherited;
end;

function tSigDBIndex.GetLeftChild: tSigBTreeNode;
begin
  if LeftChildIndex = 0 then
  begin
    Result := nil;
  end
  else
  begin
    Result := fLeftChild;
    if not assigned( Result ) then
    begin
      fIndexFile.Lock;
      try
        Result := tSigDBIndex.Create( fIndexFile, LeftChildIndex, 0 );
        fLeftChild := Result;
        Result.Parent := self;
      finally
        fIndexFile.Unlock;
        {
        fIndexFile.Read( fLeftChildIndex );
        with fLeftChild as tSigDBIndex do
        begin
          LeftChildIndex := fIndexFile.LeftChild;
          RightChildIndex := fIndexFile.RightChild;
          TreeDepth := fIndexFile.TreeDepth;
        end;
        }
      end;
    end;
    (Result as tSigDBIndex).LastAccessed := Now;
  end;
end;

function tSigDBIndex.GetLeftChildIndex: tSigDBRecPointer;
begin
  Result := fLeftChildIndex;
end;

function tSigDBIndex.GetRightChild: tSigBTreeNode;
begin
  if RightChildIndex = 0 then
  begin
    Result := nil;
  end
  else
  begin
    Result := fRightChild;
    if not assigned( Result ) then
    begin
      fIndexFile.Lock;
      try
        Result := tSigDBIndex.Create( fIndexFile, RightChildIndex, 0 );
        fRightChild := Result;
        {
        fIndexFile.Read( RightChildIndex );
        with fRightChild as tSigDBIndex do
        begin
          LeftChildIndex := fIndexFile.LeftChild;
          RightChildIndex := fIndexFile.RightChild;
          TreeDepth := fIndexFile.TreeDepth;
        end;
        }
      finally
        fIndexFile.Unlock;
      end;
    end;
    (Result as tSigDBIndex).LastAccessed := Now;
  end;
end;

function tSigDBIndex.GetRightChildIndex: tSigDBRecPointer;
begin
  Result := fRightChildIndex;
end;

function tSigDBIndex.GetTreeDepth: integer;
begin
  Result := inherited;

end;

function tSigDBIndex.LessThan(const SigTreeNode: tSigBTreeNode): boolean;
var
  iSigTreeNode : tSigDBIndex;
begin
  iSigTreeNode := SigTreeNode as tSigDBIndex;
  Result := IndexFile.Fields.Compare( self.SigDBIndex, iSigTreeNode.SigDBIndex, 0 ) = crLT;
end;

function tSigDBIndex.NodeText: string;
begin
  Result := '';
end;

function tSigDBIndex.PruneOldBranches(pNotUsedSince: tDateTime) : boolean;
begin
  Result := fLastAccessed < pNotUsedSince;
  if assigned( fLeftChild ) then
  begin
    if (fLeftChild as tSigDBIndex).PruneOldBranches( pNotUsedSince ) then
    begin
      FreeAndNil( fLeftChild );
    end
    else
    begin
      Result := FALSE;
    end;
  end;
  if assigned( fRightChild ) then
  begin
    if (fRightChild as tSigDBIndex).PruneOldBranches( pNotUsedSince ) then
    begin
      FreeAndNil( fRightChild );
    end
    else
    begin
      Result := FALSE;
    end;
  end;
end;

procedure tSigDBIndex.SetLeftChild(const Value: tSigBTreeNode);
begin
  inherited;
  if assigned( Value ) then
  begin
    with Value as tSigDBIndex do
    begin
      self.LeftChildIndex := CurrIndex; // self required here
      (Value as tSigDBIndex).LastAccessed := Now;
    end;
  end
  else
  begin
    LeftChildIndex := 0;
  end;
end;

procedure tSigDBIndex.SetLeftChildIndex(const Value: tSigDBRecPointer);
begin
  if fLeftChildIndex <> Value then
  begin
    fLeftChildIndex := Value;
    UpdateIndexFile;
  end;
end;

procedure tSigDBIndex.SetRightChild(const Value: tSigBTreeNode);
begin
  inherited;
  if assigned( Value ) then
  begin
    with Value as tSigDBIndex do
    begin
      self.RightChildIndex := CurrIndex; // self required here
    end;
  end
  else
  begin
    RightChildIndex := 0;
  end;
end;

procedure tSigDBIndex.SetRightChildIndex(const Value: tSigDBRecPointer);
begin
  if fRightChildIndex <> Value then
  begin
    fRightChildIndex := Value;
    UpdateIndexFile;
  end;
end;

procedure tSigDBIndex.SetTreeDepth(const Value: integer);
//var
//  iTemp : integer;
begin
  inherited;
//  iTemp := IndexFile.CurrIndex;
  IndexFile.Read( CurrIndex );
  if IndexFile.TreeDepth <> Value then
  begin
    IndexFile.TreeDepth := Value;
    IndexFile.Write( CurrIndex );
    if assigned( Parent ) and (Value > 0) then
    begin
      Parent.TreeDepth := Value - 1;
    end;
  end;
//  IndexFile.Read( iTemp );
end;

procedure tSigDBIndex.UpdateIndexFile;
begin
  IndexFile.Lock;
  try
    IndexFile.LeftChild := fLeftChildIndex;
    IndexFile.RightChild := fRightChildIndex;
    IndexFile.TreeDepth := TreeDepth;
    IndexFile.DataRec := fSigDBIndex;
    IndexFile.Write( fCurrIndex );
  finally
    IndexFile.Unlock;
  end;
end;

{ tSigDBIndexRoot }

procedure tSigDBIndexRoot.Add(const SigTreeNode: tSigBTreeNode);
begin
  Lock;
  try
    if assigned( LeftChild ) then
    begin
      LeftChild.Add( SigTreeNode );
    end
    else
    begin
      LeftChild := SigTreeNode;
      LeftChild.Parent := self;
    end;
  finally
    Unlock;
  end;
end;

constructor tSigDBIndexRoot.Create(const pIndexFile: tSigDBIndexFile;
  const pCurrIndex, pDBIndex: integer);
begin
  inherited;
  fLock := tObject.Create;
end;

destructor tSigDBIndexRoot.Destroy;
begin
  fLock.Free;
  inherited;
end;

function tSigDBIndexRoot.GetLeftChild: tSigBTreeNode;
begin
  Lock;
  try
    Result := inherited;
  finally
    Unlock;
  end;
end;

function tSigDBIndexRoot.GetRightChild: tSigBTreeNode;
begin
  Lock;
  try
    Result := inherited;
  finally
    Unlock;
  end;
end;

function tSigDBIndexRoot.GetLeftChildIndex: tSigDBRecPointer;
begin
  Result := IndexFile.RootRoot;
end;

procedure tSigDBIndexRoot.Lock;
begin
  TMonitor.Enter(fLock);
end;

function tSigDBIndexRoot.NodeText: string;
begin
  Result := 'Root';
end;

procedure tSigDBIndexRoot.PruneOldBranches(pNotUsedSince: tDateTime);
begin
  Lock;
  try
    if assigned( fLeftChild ) then
    begin
      (fLeftChild as tSigDBIndex).PruneOldBranches( pNotUsedSince);
    end;
  finally
    Unlock;
  end;
end;

procedure tSigDBIndexRoot.SetLeftChild(const Value: tSigBTreeNode);
begin
  Lock;
  try
    inherited;
  finally
    Unlock;
  end;
end;

procedure tSigDBIndexRoot.SetRightChild(const Value: tSigBTreeNode);
begin
  Lock;
  try
    inherited;
  finally
    Unlock;
  end;
end;

procedure tSigDBIndexRoot.Unlock;
begin
  TMonitor.Exit(fLock);
end;

{ tSigDBFileBase<T> }

function tSigDBFileBase<T>.Append(var pBuffer: Td2;
  var pIndex: tSigDBRecPointer): tSigDBRecPointer;
var
  iTemp : tSigDBRecPointer;
begin
  Database.Lock;
  try
    // see if we can reuse a record
  {
    The root record is handled differently for index files and
    data files.

    In both cases the LastDel field is updated during a delete or
    append where record is reused from the deleted list.

    In the case of an data file the next rec field is always updated during an append.
    In the case of an index file, the equivalent field, root, can be updated
    during an update, but this is treated as a delete followed by an append,
    both of which may affect the root pointer.
  }
    BeforeRecAppend( pBuffer.Rec.Data2, pBuffer.UserData );
    if fRootRec.Rec.DelLast = 0 then
    begin
      Seek( fFile, FileSize( fFile ) );  // find end of file
      Result := FilePos( fFile );        // record it
      pBuffer.Rec.Next := fRootRec.Rec.InsLast;  // maintain linked list
      pBuffer.Rec.Prev := 0;
      BlockWrite( fFile, pBuffer.Rec, 1 );   // write new record
      pIndex := Result;                  // update store
      if fRootRec.Rec.InsLast <> 0 then
      begin
        Read( fRootRec.Rec.InsLast, fUpdateRec, fUpdateRecNo );
        fUpdateRec.Rec.Prev := Result;
        Write( fUpdateRecNo, fUpdateRec );
      end;
      //Seek( fFile, iTemp );
      //BlockWrite( fFile, fUpdateRec, 1 );
      fRootRec.Rec.InsLast := Result;        // renew last entry in linked list
      Write( 0, fRootRec );// update root
      AfterRecAppend( Result, pBuffer.Rec.Data2, pBuffer.UserData );             // do any ancillary actions
    end
    else
    begin
      // use deleted record instead
      Result := fRootRec.Rec.DelLast;
      iTemp := 0;                              // force read
      Read( Result, fDelRec, iTemp );          // although really interested in fDelRec.Next
      pBuffer.Rec.Next := fRootRec.Rec.InsLast;        // maintain linked list
      pBuffer.Rec.Prev := 0;
      pIndex := Result;
      Write( Result, pBuffer );
      fRootRec.Rec.DelLast := fDelRec.Rec.Next;        // remove deleted record from deleted stack
      if fRootRec.Rec.InsLast <> 0 then
      begin
        Read( fRootRec.Rec.InsLast, fUpdateRec, fUpdateRecNo );
        fUpdateRec.Rec.Prev := Result;
        Write( fUpdateRecNo, fUpdateRec );
      end;
      //Seek( fFile, iTemp );
      //BlockWrite( fFile, fUpdateRec, 1 );
      fRootRec.Rec.InsLast := Result;              // renew entry in linked list
      Write( 0, fRootRec );      // update root
      AfterRecAppend( Result, pBuffer.Rec.Data2, pBuffer.UserData );             // do any ancillary actions
    end;
  finally
    Database.Unlock;
  end;
end;

procedure tSigDBFileBase<T>.AfterRecRead(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  fInterestedParties.AfterRecRead( pRec, pBuffer, pUserData );
end;

procedure tSigDBFileBase<T>.AfterRecWrite(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  fInterestedParties.AfterRecWrite( pRec, pBuffer, pUserData );
end;

function tSigDBFileBase<T>.Append: tSigDBRecPointer;
begin
  Result := Append( fFields0, fFields0RecNo );
end;

procedure tSigDBFileBase<T>.BeforeRecAppend( var pBuffer: T; var pUserData : TObject);
begin
  fInterestedParties.BeforeRecAppend( pBuffer, pUserData );
end;

procedure tSigDBFileBase<T>.BeforeRecWrite(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  fInterestedParties.BeforeRecWrite( pRec, pBuffer, pUserData );
end;

procedure tSigDBFileBase<T>.CloseDBFile;
begin
  if fOpen then
  begin
    CloseFile( fFile );
    fOpen := FALSE;
  end;
end;

constructor tSigDBFileBase<T>.Create(const pName : string; const pDatabase: tSigDBDatabase);
begin
  inherited Create( pName );
  //fLock := TObject.Create;
  fDatabase := pDatabase;
  fInterestedParties := TInterestedPartiesList< T >.Create;
  {
  if IsIndexFile then
  begin
    pDatabase.IndexFiles.Add( self );
  end
  else
  begin
    pDatabase.DataFiles.Add( self );
  end;
  }
end;

class function tSigDBFileBase<T>.CurrVerMajor: word;
begin
  Result := 0;
end;

class function tSigDBFileBase<T>.CurrVerMinor: word;
begin
  Result := 0;
end;

procedure tSigDBFileBase<T>.Delete(pRec: tSigDBRecPointer);
var
  iDelRec : tSigDBRecPointer;
begin
  // move the record to the deleted list
  Read( pRec, fDelRec, iDelRec );
  Read( fFields0.Rec.Prev, fFields1, fFields1RecNo );
  Read( fFields0.Rec.Next, fFields2, fFields2RecNo );
  fFields1.Rec.Next := fFields2RecNo;
  fFields2.Rec.Prev := fFields1RecNo;
  fDelRec.Rec.Next := fRootRec.Rec.DelLast;
  fRootRec.Rec.DelLast :=iDelRec;
  Write( fFields1RecNo, fFields1 );
  Write( fFields2RecNo, fFields2 );
  Write( iDelRec, fDelRec );
  Write ( 0, fRootRec );

end;

destructor tSigDBFileBase<T>.Destroy;
begin
  fInterestedParties.Free;
  //fLock.Free;
  inherited;
end;

function tSigDBFileBase<T>.GetRecCount: integer;
begin
  if Open then
  begin
    Result := FileSize( fFile );
  end
  else
  begin
    raise Exception.Create('File not open');
  end;
end;

procedure tSigDBFileBase<T>.Lock;
begin
  Database.Lock;
end;

procedure tSigDBFileBase<T>.AfterRecAppend(const pRec: tSigDBRecPointer; var pBuffer : T; var pUserData : TObject);
begin
  fInterestedParties.AfterRecAppend( pRec, pBuffer, pUserData );
end;

procedure tSigDBFileBase<T>.OnVersionChange(const pOldVerMajor, pOldVerMinor,
  pNewVerMajor, pNewVerMinor: Word);
begin
  // finally update the root record with the new version
  fRootRec.Rec.VerMajor := pNewVerMajor;
  fRootRec.Rec.VerMinor := pNewVerMinor;
  Write( 0, fRootRec );
end;

function tSigDBFileBase<T>.OpenDBFile( const pVerMajor, pVerMinor : Word ): boolean;
var
  iPathName : string;
  iFile : string;
  iRecLen : int64;
  iResult : integer;
  //iRec : array of byte;
begin
  iPathName := fDatabase.Path;
  {
  if iPathName[ Length(iPathName) ] = '\' then
  begin
    iPathName := Copy( iPathName, 1, Length( iPathName ) - 1);
  end;
  }
  Result := ForceDirectories( iPathName );
  if iPathName[ Length(iPathName) ] <> '\' then
  begin
    iPathName := iPathName + '\';
  end;
  iFile := iPathName + Name + Ext;
  AssignFile( fFile, iFile );
  try
    iRecLen := SizeOf( tD );
    if not FileExists( iFile ) then
    begin
      Rewrite( fFile, iRecLen );
      // create record zero
      fRootRec.Rec.DelLast := 0;
      fRootRec.Rec.VerMajor := pVerMajor;
      fRootRec.Rec.VerMinor := pVerMinor;
      BlockWrite( fFile, fRootRec.Rec, 1 );
      CloseFile( fFile );
    end;
    if FileExists( iFile ) then
    begin
      Reset( fFile, iRecLen );
      BlockRead( fFile, fRootRec.Rec, 1, iResult );
      if iResult < 1 then
      begin
        // empty file. Should not happen, but
        Seek( fFile, 0 );
        fRootRec.Rec.DelLast := 0;
        fRootRec.Rec.VerMajor := pVerMajor;
        fRootRec.Rec.VerMinor := pVerMinor;
        BlockWrite( fFile, fRootRec.Rec, 1 );
      end;
      fOpen := TRUE;
      if (fRootRec.Rec.VerMajor <> pVerMajor) or (fRootRec.Rec.VerMinor <> pVerMinor ) then
      begin
        OnVersionChange( fRootRec.Rec.VerMajor, fRootRec.Rec.VerMinor, pVerMajor, pVerMinor );
      end;
    end
    else
    begin
      fOpen := FALSE;
    end;
  except
    fOpen := FALSE;
  end;
  Result := fOpen;
end;

function tSigDBFileBase<T>.Read(const pRec: tSigDBRecPointer): boolean;
begin
  // see if record already loaded and we can just copy memory
  if pRec = 0 then    // root record request - must do first, because means record not loaded in other fields
  begin
    fFields0.Rec := fRootRec.Rec;
    fFields0RecNo := 0;
    Result := TRUE;
  end
  else if pRec = fFields0RecNo then
  begin
    Result := TRUE;
  end
  else if pRec = fFields1RecNo then
  begin
    fFields0.Rec := fFields1.Rec;
    fFields0RecNo := fFields1RecNo;
    Result := TRUE;
    AfterRecRead( pRec, fFields0.Rec.Data2, fFields0.UserData );
  end
  else if pRec = fFields2RecNo then
  begin
    fFields0.Rec := fFields2.Rec;
    fFields0RecNo := fFields2RecNo;
    Result := TRUE;
    AfterRecRead( pRec, fFields0.Rec.Data2, fFields0.UserData );
  end
  else
  begin
    Result := Read( pRec, fFields0, fFields0RecNo );
  end;
end;

procedure tSigDBFileBase<T>.RegisterInterestedParty(
  pParty: TInterestedParty<T>);
begin
  fInterestedParties.Add( pParty );
end;

function tSigDBFileBase<T>.Read(const pRec: tSigDBRecPointer; var pBuffer: Td2;
  var pIndex: tSigDBRecPointer): boolean;
begin
  Lock;
  try
    if fOpen then
    begin
      if pIndex <> pRec then
      begin
        Seek( fFile, pRec );
        BlockRead( fFile, pBuffer.Rec, 1 );
        pIndex := pRec;
      end;
      Result := TRUE;
      AfterRecRead( pRec, pBuffer.Rec.Data2, pBuffer.UserData );
    end
    else
    begin
      Result := FALSE;
    end;
  finally
    Unlock;
  end;
end;

procedure tSigDBFileBase<T>.SetOpen(pOpen: boolean);
begin
  Lock;
  try
    if pOpen then
    begin
      fOpen := OpenDBFile( CurrVerMajor, CurrVerMinor );
    end
    else
    begin
      fOpen := FALSE;
      CloseDBFile;
    end;
  finally
    Unlock;
  end;
end;

procedure tSigDBFileBase<T>.Unlock;
begin
  Database.Unlock;
end;

function tSigDBFileBase<T>.Update: tSigDBRecPointer;
begin
  if fFields0RecNo <> 0 then
  begin
    Write( fFields0RecNo );
    Result := fFields0RecNo;
  end
  else
  begin
    raise Exception.Create('Attempt to update before read');
  end;
end;

function tSigDBFileBase<T>.Write(const pRec: tSigDBRecPointer): boolean;
begin
  BeforeRecWrite( pRec, fFields0.Rec.Data2, fFields0.UserData );
  Result := Write( pRec, fFields0 );
  fFields0RecNo := pRec;
  if fFields1RecNo = pRec then
  begin
    fFields1.Rec := fFields0.Rec;
  end;
  if fFields2RecNo = pRec then
  begin
    fFields2.Rec := fFields0.Rec;
  end;
  if pRec = 0 then
  begin
    fRootRec.Rec := fFields0.Rec;
  end;
  AfterRecWrite( pRec, fFields0.Rec.Data2, fFields0.UserData );
end;

function tSigDBFileBase<T>.Write(const pRec: tSigDBRecPointer; var pBuffer: Td2 ): boolean;
begin
  Lock;
  try
    if fOpen then
    begin
      Seek( fFile, pRec );
      BlockWrite( fFile, pBuffer.Rec, 1 );
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  finally
    Unlock;
  end;
end;

{ tSigDBFileBase }

procedure tSigDBFileBase.AfterDBOpen;
begin
  // by default, no action
end;

procedure tSigDBFileBase.BeforeDBClose;
begin
  // by default, no action
end;

constructor tSigDBFileBase.Create(const pName: string);
begin
  inherited Create;
  fName := pName;
end;

function tSigDBFileBase.GetRecCount: integer;
begin
  raise exception.Create( 'Invalid RECORD COUNT request' );
end;

procedure tSigDBFileBase.SetOpen(pOpen: boolean);
begin
  raise exception.Create( 'Invalid OPEN request' );
end;

{ TInterestedParty<T> }

procedure TInterestedParty<T>.AfterRecAppend(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
begin

end;

procedure TInterestedParty<T>.AfterRecRead(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
begin

end;

procedure TInterestedParty<T>.AfterRecWrite(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
begin

end;

procedure TInterestedParty<T>.BeforeRecAppend(var pBuffer: T;
  var pUserData: TObject);
begin

end;

procedure TInterestedParty<T>.BeforeRecWrite(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
begin

end;

{ TInterestedPartiesList<T> }

procedure TInterestedPartiesList<T>.AfterRecAppend(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].AfterRecAppend( pRec, pBuffer, pUserData );
  end;
end;

procedure TInterestedPartiesList<T>.AfterRecRead(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].AfterRecRead( pRec, pBuffer, pUserData );
  end;
end;

procedure TInterestedPartiesList<T>.AfterRecWrite(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].AfterRecWrite( pRec, pBuffer, pUserData );
  end;
end;

procedure TInterestedPartiesList<T>.BeforeRecAppend(var pBuffer: T;
  var pUserData: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].BeforeRecAppend( pBuffer, pUserData );
  end;
end;

procedure TInterestedPartiesList<T>.BeforeRecWrite(const pRec: tSigDBRecPointer;
  var pBuffer: T; var pUserData: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Item[ i ].BeforeRecWrite( pRec, pBuffer, pUserData );
  end;
end;

end.

