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
  System.Types,
  System.TypInfo,
  System.Character,
  SigBTree,
  //VCL.Controls,
  //VCL.ExtCtrls,
  //VCL.Graphics,
  //VCL.Grids,
  //TypedObjectList,
  System.Generics.Collections,
  PendingActions; //,
  //UnitSigBtreePaintbox;

type
  TSigDBException = class( Exception );

  TSigDBRecPointer = int64;

  TSigDBFileBase = class;

  TSigDBIndexFile = class;

  TSigDBIndex = class( tSigBTreeNodeMemory ) // binary tree stored in a file
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
    property SigDBIndex : tSigDBRecPointer // data file index
             read fSigDBIndex;
    property CurrIndex : tSigDBRecPointer  // index file index
              read fCurrIndex;
    property IndexFile : tSigDBIndexFile
             read fIndexFile;
    function NodeText : string; override;

    property LastAccessed : tDateTime  // actually our parents use this, not us.
             read fLastAccessed
             write fLastAccessed;

    procedure UpdateIndexFile;

    procedure Invalidate( const NewLeftChildRec, NewRightChildRec : tSigDBRecPointer) ; // The file has changed other than through the tree.
                          // We need to set it so that a reread is forced...

    {
    procedure DrawTree( const Canvas : tCanvas; const pLineHeight : integer; const pCurrLine : tRect ); override;
    procedure DrawNode( const Canvas : tCanvas; pCurrLine : tRect ); override;

    procedure DrawTree( const PaintBox : tPaintBox; const pLineHeight : integer; const pCurrLine : tRect; const DrawAll : boolean = TRUE ); override;
    }

    function PruneOldBranches( pNotUsedSince : tDateTime ) : boolean; // returns true if I can be pruned

    function LessThan( const SigTreeNode : tSigBTreeNode ) : boolean; override;

    const
      cSelf = 0;
      cLeftChild = cSelf + 1;
      cRightChild = cLeftChild + 1;
  end;

  TSigDBIndexRoot = class( tSigDBIndex ) // corresponds to record 1, which we always load
  private
    fIndexName: string;
    fLock : tObject;
    //fPaintBox: tPaintBox;
    //fBkGround: tColor;
    //fShowAll: boolean;
    //fVisibleRoot : tSigDBIndex;
    //fOnMouseUp : TMouseEvent;
    //procedure SetPaintBox(const Value: TPaintBox);  // locking the root by implication locks tree. this reduces overhead of making threadsafe, just as with TTheadList
    //procedure OnPaint( Sender : TObject );
    //procedure OnMouseUp( Sender : TObject; pButton : TMouseButton; pShift : TShiftState; X,Y : integer );
    //procedure SetVisibleRoot(const Value: TSigDBIndex);
    //procedure SetBkGround(const Value: tColor);
  protected
    function GetLeftChild: tSigBTreeNode; override;
    function GetRightChild: tSigBTreeNode; override;
    procedure SetLeftChild(const Value: tSigBTreeNode);  override;
    procedure SetRightChild(const Value: tSigBTreeNode);  override;
    function GetLeftChildIndex: tSigDBRecPointer; override;
  public
    constructor Create( const pIndexFile : tSigDBIndexFile; const pCurrIndex, pDBIndex : integer ); override;
    destructor Destroy; override;

    procedure Add( const SigTreeNode : tSigBTreeNode ); override;
    property FirstDeletedIndex : tSigDBRecPointer
             read fRightChildIndex;
    property Root : tSigDBRecPointer
             read fLeftChildIndex;
    property IndexName : string
             read fIndexName;

    //function Remove( const SigTreeNode : tSigBTreeNode ) : boolean; overload; override; // finds the node to remove, if it exists. TRUE if removed, FALSE if not found
    //procedure Remove; overload; override;

    function NodeText : string; override;  // returns the text to be displayed visually

    procedure Lock;
    procedure Unlock;

    //property PaintBox : TPaintBox
    //         read fPaintBox
    //         write SetPaintBox;
    //property BkGround : tColor
    //         read fBkGround
    //         write SetBkGround;
    //property ShowAll : boolean
    //         read fShowAll
    //         write fShowAll;
    //property VisibleRoot : tSigDBIndex
    //         read fVisibleRoot
    //         write SetVisibleRoot;

    procedure PruneOldBranches( pNotUsedSince : tDateTime );

  end;

  TSigDBFieldType = ( ft_String, ft_Integer, ft_Date_Time, ft_Field_Pointer,
                      ft_Index_Ascending, ft_Index_Descending,
                      ft_Filter_LT, ft_Filter_LE,ft_Filter_EQ, ft_Filter_NE,
                      ft_Filter_GE, ft_Filter_GT, ft_Filter_in, ft_Filter_not_in,
                      ft_Filter_Changed );
                      // ft_Filter_Changed simply tests for change


  TSigDBIndexFieldList = class;

  TSigDBIndexField = class
  private
    fFieldType : tSigDBFieldType;
    fFilter: string;
    fDataFieldID : integer;
    fOwner : tSigDBIndexFieldList;
    fDataFileID: Int32;
  protected
  public
    function FieldValid( const pDBRec : tSigDBRecPointer ) : boolean; virtual; // checks filters
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

  TCompareResult = (crLT, crEQ, crGT );

  TSigDBIndexFieldList = class( TObjectList<TSigDBIndexField> )
  private
    fOwner : tSigDBIndexFile;
    fDataFile: tSigDBFileBase;
    fRoot : tSigDBIndexRoot;
    fOpen: boolean;
    //fPaintBox: tPaintBox;
    //fShowAll: boolean;
    //fBkGround: tColor;
    function GetIndexField(const i: integer): tSigDBIndexField;
    procedure SetOpen(const Value: boolean);
    //procedure SetPaintBox(const Value: tPaintBox);
    //procedure SetBkGround(const Value: tColor);
    //procedure SetShowAll(const Value: boolean);
  protected
    function CompareField( const pIndex: integer; const pDBRec1, pDBRec2 : tSigDBRecPointer ) : tCompareResult; // 0 = current DB file values rather than a record
    function CompareUpdateField( const pIndex: integer; const pDBRec1 : tSigDBRecPointer ) : tCompareResult; // 0 = current DB file values rather than a record
    function FieldValid( const pIndex : integer; const pDBRec : tSigDBRecPointer ) : boolean; // checks filters
  public
    constructor Create( const pOwner : tSigDBIndexFile; const pDataFile : tSigDBFileBase );reintroduce; virtual;

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

    (*
    property PaintBox : tPaintBox
             read fPaintBox
             write SetPaintBox;
    property BkGround : tColor
             read fBkGround
             write SetBkGround;
    property ShowAll : boolean
             read fShowAll
             write SetShowAll;
    *)
  end;

  TSigDBDatabase = class;
  TInterestedPartiesList = class;

  TSigDBFileBase = class
    // really just a placeholder for tSigDBFileBase< T >
  private
    fName: string;
    fInterestedParties : TInterestedPartiesList;
    //fListGrid: tStringGrid;
    //procedure SetListGrid(const Value: tStringGrid);
  protected
    fOpen : boolean;
    fForceCreate : boolean; // used in reindex for index files particularly
    function GetRecCount: Int64; virtual;
    function GetLastInserted: tSigDBRecPointer; virtual;
    function GetLastDeleted: tSigDBRecPointer; virtual;
    function GetNextRec: tSigDBRecPointer; virtual;
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

    property RecCount : Int64
             read GetRecCount;
    property LastInserted : tSigDBRecPointer
             read GetLastInserted;
    property LastDeleted : tSigDBRecPointer
             read GetLastDeleted;
    property NextRec : tSigDBRecPointer
             read GetNextRec;

    //function Read( const pRec : tSigDBRecPointer; pBuffer : pointer; var pIndex : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    function Read( const pRec : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    //function Write( const pRec : tSigDBRecPointer; pBuffer : pointer ) : boolean; overload; virtual; abstract;
    function Write( const pRec : tSigDBRecPointer ) : boolean; overload; virtual; abstract;
    //function Append( pBuffer : pointer; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; virtual; abstract; // 0 = fail
    function Append : tSigDBRecPointer; overload; virtual; abstract; // 0 = fail
    function Delete( pRec : tSigDBRecPointer ) : boolean; virtual; abstract;
    function Update : tSigDBRecPointer; virtual; abstract; // = write to rec0

    procedure AfterOpen; virtual; abstract;
    procedure AfterDBCreate; virtual; abstract;
    procedure BeforeClose; virtual; abstract;
    procedure BeforeRecAppend; virtual; abstract;
    procedure AfterRecAppend( const pRec : tSigDBRecPointer); virtual; abstract;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer); virtual; abstract;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer); virtual; abstract;
    procedure AfterRecRead( const pRec : tSigDBRecPointer); virtual; abstract;
    function CanDelete( const pRec : tSigDBRecPointer): boolean ; virtual; abstract;
    procedure BeforeRecDelete( const pRec : tSigDBRecPointer); virtual; abstract;
    procedure AfterRecDelete( const pRec : tSigDBRecPointer); virtual; abstract;
    procedure OnAction( const pRec : tSigDBRecPointer); virtual;
              // general action that can be called any time for any record

    procedure Lock; virtual; abstract;
    procedure Unlock; virtual; abstract;

    function UserData : TObject; virtual; abstract;

    function CurrRec : tSigDBRecPointer; virtual; abstract;

    function DataFile : tSigDBFileBase; virtual;
    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer ); virtual;

    function FieldAsText( const pFieldID : integer ) : string; virtual;
    procedure TextToField( const pFieldID : integer; Value : string ); virtual; abstract;
    function FieldTitle( const pFieldID : integer ) : string; virtual;
    function FieldCount : integer; virtual;

    //procedure ShowCell( const pX, pY : integer; const pText : string ); virtual;
    //procedure ShowRecs( const pFromRecNo : tSigDBRecPointer );

    //property ListGrid : tStringGrid
    //         read fListGrid
    //         write SetListGrid;

    property InterestedParties : TInterestedPartiesList
             read fInterestedParties;

    function Version : string; virtual; abstract;

    function UpdateRecNo : tSigDBRecPointer; virtual; abstract;
  end;

  TSigDBFileBaseFlag = ( flgEncryptedBlowfish, flgEncyptedDES );
                       // Notes; Encrypted means at read/write level
                       // Multiple encryptions are compound encryptions! and may be slow!
  TSigDBFileBaseFlags = set of tSigDBFileBaseFlag;

  TInterestedParty = class
  private
    { Use a descendant of this to act whenever database file is modified and register it
      The functions in this do nothing. Override the functions needed. }
  protected
  public
    procedure AfterOpen( Sender : TObject ); virtual;
    procedure AfterDBCreate( Sender : TObject ); virtual;
    procedure BeforeClose( Sender : TObject ); virtual;
    procedure BeforeRecAppend( Sender : TObject ); virtual;
    procedure AfterRecAppend( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure BeforeRecWrite( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecWrite( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecRead( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    function CanDelete( Sender : TObject; const pRec : tSigDBRecPointer ) : boolean ; virtual;
    {
      CanDelete is not guaranteed to execute for all interested parties
    }
    procedure BeforeRecordDelete( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecordDelete( Sender : TObject ); virtual;
    procedure OnAction( Sender : TObject; const pRec : tSigDBRecPointer); virtual;
              // general action that can be called any time for any record
  end;

  TInterestedPartiesList = class( TObjectList< TInterestedParty>)
  private
    { Use a descendant of this to act whenever database file is modified and register it
      The functions in this do nothing. Override the functions needed. }
  protected
  public
    procedure AfterOpen( Sender : TObject ); virtual;
    procedure AfterDBCreate( Sender : TObject ); virtual;
    procedure BeforeClose( Sender : TObject ); virtual;
    procedure BeforeRecAppend( Sender : TObject ); virtual;
    procedure AfterRecAppend( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure BeforeRecWrite( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecWrite( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecRead( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    function CanDelete( Sender : TObject; const pRec : tSigDBRecPointer) : boolean ; virtual;
    procedure BeforeRecordDelete( Sender : TObject; const pRec : tSigDBRecPointer ); virtual;
    procedure AfterRecordDelete( Sender : TObject ); virtual;
    procedure OnAction( Sender : TObject; const pRec : tSigDBRecPointer); virtual;
              // general action that can be called any time for any record
  end;

  TSigDBFileBase< T : Record > = class( tSigDBFileBase )
  private
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
    fBTreeRootRec: tD2;
    fTempRec, fDelRec, fUpdateRec : tD2;
    //fRec1, fRec2 : integer;
    fFields0RecNo, fFields1RecNo, fFields2RecNo : tSigDBRecPointer;
    fUpdateRecNo, fBTreeRecNo : tSigDBRecPointer;

    //procedure OnField0Change;
    procedure SetOpen( pOpen : boolean ); override;
    function OpenDBFile( const pVerMajor, pVerMinor : Word ) : boolean; virtual;
    procedure CloseDBFile; virtual;
    function GetRecCount: Int64; override;
    function GetLastInserted: tSigDBRecPointer; override;
    function GetLastDeleted: tSigDBRecPointer; override;
    function GetNextRec: tSigDBRecPointer; override;
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

    procedure AfterOpen; override;
    procedure AfterDBCreate; override;
    procedure BeforeClose; override;
    procedure BeforeRecAppend; override;  // fRec0 is record
    procedure AfterRecAppend( const pRec : tSigDBRecPointer); override;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer); override;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer); override;
    procedure AfterRecRead( const pRec : tSigDBRecPointer); override;
    function CanDelete( const pRec : tSigDBRecPointer): boolean ; override;
    procedure BeforeRecDelete( const pRec : tSigDBRecPointer); override;
    procedure AfterRecDelete( const pRec : tSigDBRecPointer); override;

    { When verriding these procedures make sure inherited is called to service interested parties}

    function Read( const pRec : tSigDBRecPointer; var pBuffer : Td2; var pIndex : tSigDBRecPointer ) : boolean; overload; virtual;
    function Read( const pRec : tSigDBRecPointer ) : boolean; overload; override;
    function Write( const pRec : tSigDBRecPointer; var pBuffer : Td2 ) : boolean; overload; virtual;
    function Write( const pRec : tSigDBRecPointer ) : boolean; overload; override;
    function Append( var pBuffer : Td2; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; virtual; // 0 = fail
    function Append : tSigDBRecPointer; overload; override; // 0 = fail
    function Update : tSigDBRecPointer; override; // = write to rec0
    function Delete( pRec : tSigDBRecPointer ) : boolean; override;
    procedure Lock; override;
    procedure Unlock; override;

    procedure RegisterInterestedParty( pParty : TInterestedParty );
    procedure UnregisterInterestedParty( pParty : TInterestedParty );

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

    function CurrRec : tSigDBRecPointer; override;
    function Version : string; override;

    function UpdateRecNo : tSigDBRecPointer; override;
  end;

  TSigDBFileBaselist = class( TObjectList< TSigDBFileBase > )
  private
    fActiveChild : integer;
    fOpen: boolean;
    function GetFileBase( const i : integer ): tSigDBFileBase;
    function GetMax : integer;
    procedure SetActiveChild(const Value: integer);
    procedure SetOpen(const Value: boolean);
  protected
    fDatabase : tSigDBDatabase;
    procedure AfterOpen; virtual;
    procedure BeforeClose; virtual;
  public
    constructor Create( const pDatabase : tSigDBDatabase );reintroduce; virtual;
    function FileExists( const pTableName : string ): boolean;

    property FileBase[ const i : integer ] : tSigDBFileBase
             read GetFileBase;
    function FileBaseWithName( const pName : string ) :  tSigDBFileBase;

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

  TSigDBDataFile< T : record > = class( tSigDBFileBase< T > )
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

    //procedure AfterOpen; override;
    //procedure BeforeClose; override;
    //procedure BeforeRecAppend; override;  // fRec0 is record
    procedure AfterRecAppend( const pRec : tSigDBRecPointer); override;
    procedure BeforeRecWrite( const pRec : tSigDBRecPointer); override;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer); override;
    //procedure AfterRecRead( const pRec : tSigDBRecPointer); override;
    //function CanDelete( const pRec : tSigDBRecPointer): boolean ; override;
    //procedure BeforeRecDelete( const pRec : tSigDBRecPointer); override;

    function Delete( pRec : tSigDBRecPointer ) : boolean; override;
    function Append( var pBuffer : tSigDBFileBase< T >.Td2; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; override; // 0 = fail

    class function Ext : string; override;
    class function IsIndexFile : boolean; override;

    function First : tSigDBRecPointer; virtual;
    function Next( const pCurr : tSigDBRecPointer )  : tSigDBRecPointer; virtual;

    function UserData: TObject; override;
  end;


  TSigDBDataFileList = class( tSigDBFileBaselist )
  private
    function GetDataFile(const i: integer): tSigDBFileBase;
  protected
  public

    property DataFile[ const i : integer ] : TSigDBFileBase
             read GetDataFile;
  end;

  TSigDBIndexRec = packed record
    DataRec    : tSigDBRecPointer;  // in record file
    LeftChild  : tSigDBRecPointer;
    RightChild : tSigDBRecPointer;
    TreeDepth  : int32;
    DBFileID   : Int32;   // only used for index files that go across multiple DB Files
                          // or multiply across a single DB File, or both
  end;

  {
  TSigDBIndexRec0 = packed record
    NotUsed    : tSigDBRecPointer;
    Root       : tSigDBRecPointer;
    Deleted    : tSigDBRecPointer;
    TreeDepth  : Int32;
    Unused     : Int32;
  end;
  }

  TSigDBFindMode = (fmEQ, fmLE, fmGE );  // differ in how to handle not found situations

  TSigDBIndexFile = class( TSigDBFileBase< TSigDBIndexRec > )
  protected
    function GetIndexField(const i: integer): TSigDBIndexField;
  private
    //fPaintBox: tPaintBox;
    //fShowAll: boolean;
    //fBkGround: tColor;
    fCurrent : TSigDBIndex;
    fFindPtr : TSigDBIndex;
    function GetRoot: TSigDBIndexRoot;
    function GetRootRoot: TSigDBRecPointer;
    //procedure SetPaintBox(const Value: tPaintBox);
    //procedure SetShowAll(const Value: boolean);
    //procedure SetBkGround(const Value: tColor);
    function GetDataRec: tSigDBRecPointer;
    procedure SetDataRec(const Value: tSigDBRecPointer);
    function GetLeftChild: tSigDBRecPointer;
    procedure SetLeftChild(const Value: tSigDBRecPointer);
    function GetRightChild: tSigDBRecPointer;
    procedure SetRightChild(const Value: tSigDBRecPointer);
    function GetTreeDepth: Int32;
    procedure SetTreeDepth(const Value: Int32);
    function GetDBFileID: Int32;
    procedure SetDBFileID(const Value: Int32);
  protected
    fFields : tSigDBIndexFieldList;
    fDataFile: tSigDBFileBase;
    function FilterValid( const pIndex : integer; const pValue : string ) : boolean;
    function IsValidList( const pValue : string ) : boolean;
    function IsSingleValue( const pValue : string ) : boolean; // depends on destination field type
  public
    constructor Create( const pName : string; const pDatabase : tSigDBDatabase; const pDataFile : tSigDBFileBase ); reintroduce; virtual;

    //function OpenDBFile( const pVerMajor, pVerMinor : Word ) : boolean; override;
    procedure AfterDBCreate; override;
    procedure AfterOpen; override;
    //procedure BeforeClose; override;
    //procedure BeforeRecAppend; override;  // fRec0 is record
    //procedure AfterRecAppend( const pRec : tSigDBRecPointer); override;
    //procedure BeforeRecWrite( const pRec : tSigDBRecPointer); override;
    procedure AfterRecWrite( const pRec : tSigDBRecPointer); override;
    //procedure AfterRecRead( const pRec : tSigDBRecPointer); override;
    //function CanDelete( const pRec : tSigDBRecPointer): boolean ; override;
    //procedure BeforeRecDelete( const pRec : tSigDBRecPointer); override;

    function Find( pMode : tSigDBFindMode; const pFieldCount : integer = -1 ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function FindUpdateRec( pMode : tSigDBFindMode ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function AppendData : tSigDBRecPointer; overload;
    function UpdateData : tSigDBRecPointer; overload;
    function ReadData( const pRec : tSigDBRecPointer ) : boolean;
    function WriteData( const pRec : tSigDBRecPointer ) : boolean;
    function DeleteData( const pRec : tSigDBRecPointer ) : boolean;
    function Append( var pBuffer : tSigDBFileBase< tSigDBIndexRec >.Td2; var pIndex : tSigDBRecPointer ) : tSigDBRecPointer; overload; override; // 0 = fail

    function CompareField( const pFieldID : integer; pRec1, pRec2 : tSigDBRecPointer ) : tCompareResult; overload; override;
    function CompareField( const pFieldID : integer; pRec : tSigDBRecPointer; const pFilter : string ) : tCompareResult; overload; override;
    function CompareUpdateField( const pFieldID : integer; pRec1 : tSigDBRecPointer ) : tCompareResult; override;

    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer ); override;
    procedure DeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer ); overload;
    //procedure DeleteIndex( const pRec : tSigDBRecPointer ); overload;
    procedure DeleteUpdateIndex( const pDataFile : tSigDBFileBase );
    procedure UpdateIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    function IndexChanged( const pDataFile : tSigDBFileBase ) : boolean; reintroduce;

    //procedure RebuildIndex; // only used for single index build, not for any of the multiple rebuilds

    //procedure ShowSortedRecs( const FromNode : tSigDBRecPointer );

    function DataFile : tSigDBFileBase; override;

    property Fields : tSigDBIndexFieldList
             read fFields;
    property Field[ const i : integer ] : tSigDBIndexField
             read GetIndexField;

    property DataRec    : tSigDBRecPointer
             read GetDataRec
             write SetDataRec;  // in record file
    property LeftChild  : tSigDBRecPointer
             read GetLeftChild
             write SetLeftChild;
    property RightChild : tSigDBRecPointer
             read GetRightChild
             write SetRightChild;
    property TreeDepth : Int32
             read GetTreeDepth
             write SetTreeDepth;
    property DBFileID : Int32
             read GetDBFileID
             write SetDBFileID;
    property Root : tSigDBIndexRoot
             read GetRoot;
    property RootRoot : tSigDBRecPointer
             read GetRootRoot;

    class function Ext : string; override;
    class function IsIndexFile : boolean; override;

    function First( var pCurr : tSigDBIndex ) : tSigDBRecPointer; overload; virtual; // points to DB File!
    function First( var pCurr : tSigDBIndex; const pFieldCount, pMatchCount : integer; const IsReentrant : boolean = FALSE ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function Next( var pCurr : tSigDBIndex )  : tSigDBRecPointer; overload; virtual;
    function Next( var pCurr : tSigDBIndex; const pFieldCount, pMatchCount : integer )  : tSigDBRecPointer; overload; virtual;

    function Last( var pCurr : tSigDBIndex ) : tSigDBRecPointer; overload; virtual; // points to DB File!
    function Last( var pCurr : tSigDBIndex; const pFieldCount, pMatchCount : integer; const IsReentrant : boolean = FALSE ) : tSigDBRecPointer; overload;// finds the record in the data file with the key supplied in fFields0
    function Prev( var pCurr : tSigDBIndex )  : tSigDBRecPointer; overload; virtual;
    function Prev( var pCurr : tSigDBIndex; const pFieldCount, pMatchCount : integer )  : tSigDBRecPointer; overload; virtual;

    function UserData: TObject; override;

    function NodeText : string;

    //property PaintBox : tPaintBox
    //         read fPaintBox
    //         write SetPaintBox;
    //property BkGround : tColor
    //         read fBkGround
    //         write SetBkGround;
    //property ShowAll : boolean
    //         read fShowAll
    //         write SetShowAll;
    function FieldCount : integer; override;
    function FieldTitle( const pFieldID : integer ) : string; override;
    function FieldAsText( const pFieldID : integer ) : string; override;
    procedure TextToField( const pFieldID : integer; Value : string ); override;

    function NextRec : tSigDBRecPointer;
    function PrevRec : tSigDBRecPointer;

    procedure Reindex;

    const
      cDataRec    = 0;  // in record file
      cLeftChild  = cDataRec + 1;
      cRightChild = cLeftChild + 1;
      cTreeDepth  = cRightChild + 1;
      cDBFileID   = cTreeDepth + 1;   // only used for index files that go across multiple DB Files
                                      // or multiply across a single DB File, or both
      cFieldCount = cDBFileID + 1;
  end;

  TSigDBIndexFileList = class( tSigDBFileBaselist )
  private
    function GetIndexFile(const i: integer): TSigDBIndexFile;
  protected
    procedure Reassign( var OldValue : TSigDBIndexFile; const NewValue : tSigDBIndexFile );
  public
    property  IndexFile[ const i : integer ] : tSigDBIndexFile
              read GetIndexFile;
    procedure AddIndex( const pDataFile : TSigDBFileBase; const pRec : tSigDBRecPointer );
    function CanDeleteIndex( const pDataFile : TSigDBFileBase; const pRec : tSigDBRecPointer ) : boolean;
    procedure DeleteIndex( const pDataFile : TSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure UpdateIndex( const pDataFile : TSigDBFileBase; const pRec : tSigDBRecPointer );

  end;

  TSigDBDatabase = class
  private
    fPath : string;
    fPendingActions: TSigPendingActionList;
    fLock: TObject;
    fOpen: boolean;
    function GetIndexFile(const i: integer): tSigDBFileBase;
    function GetDataFile(const i : integer): tSigDBFileBase;
    procedure SetOpen(const Value: boolean);
  protected
    fDataFiles: tSigDBDataFileList;
    fIndexFiles: tSigDBIndexFileList;

    procedure AfterOpen; virtual;
    procedure BeforeClose; virtual;
  public
    constructor Create( const pPath : string ); virtual;
    destructor Destroy; override;

    procedure Format( const pDataFile : tSigDBFileBase = nil);
    //function Open : boolean;
    //procedure Close;

    procedure AddIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    function CanDeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer ) : boolean;
    procedure DeleteIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );
    procedure UpdateIndex( const pDataFile : tSigDBFileBase; const pRec : tSigDBRecPointer );

    property Path : string
             read fPath;
    property DataFiles : tSigDBDataFileList
             read fDataFiles;
    property IndexFiles : tSigDBIndexFileList
             read fIndexFiles;

    property IndexFile[ const i : integer ] : tSigDBFileBase
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

procedure tSigDBDatabase.AfterOpen;
begin
  fDataFiles.AfterOpen;
  fIndexFiles.AfterOpen;
end;

procedure tSigDBDatabase.BeforeClose;
begin
  fDataFiles.BeforeClose;
  fIndexFiles.BeforeClose;
end;

function tSigDBDatabase.CanDeleteIndex(const pDataFile: tSigDBFileBase; const pRec : tSigDBRecPointer): boolean;
begin
  Result := fIndexFiles.CanDeleteIndex( pDataFile, pRec )
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
  iIndexFile : tSigDBFileBase;
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
              iIndexFile := IndexFiles.FileBaseWithName( iName );
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

function tSigDBDatabase.GetIndexFile(const i: integer): tSigDBFileBase;
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
          AfterOpen;
        end;
      end
      else
      begin
        BeforeClose;
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

function tSigDBIndexFileList.CanDeleteIndex(const pDataFile: tSigDBFileBase; const pRec : tSigDBRecPointer): boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Count-1 do
  begin
    with IndexFile[ i ] do
    begin
      if DataFile = pDataFile then
      begin
        if Not CanDelete( pRec ) then
        begin
          Result := FALSE;
          exit;
        end;
      end;
    end;
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
    IndexFile[ i ].UpdateIndex( pDataFile, pRec );
    //if IndexFile[ i ].IndexChanged( pDataFile ) then
    //begin
      //IndexFile[ i ].DeleteUpdateIndex( pDataFile );
      //IndexFile[ i ].AddIndex( pDataFile, pRec );
    //end;
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
  if pFieldCount = -1 then
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
      ft_Filter_not_in,
      ft_Filter_Changed: // not used in comparing
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
      ft_Filter_GT,
      ft_Filter_Changed: // not used in comparing
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
  fRoot := tSigDBIndexRoot.Create( pOwner, 1, 0 );

end;

function tSigDBIndexFieldList.FieldValid(const pIndex: integer;
  const pDBRec: tSigDBRecPointer): boolean;
begin
  with IndexField[ pIndex ] do
  begin
    case FieldType of
      ft_String,
      ft_Integer,
      ft_Date_Time,
      ft_Field_Pointer: raise Exception.Create('Unexpected Index Field Type');
      ft_Index_Ascending,
      ft_Index_Descending,
      ft_Filter_Changed:
      begin
        Result := TRUE; // not a filter field so always valid
      end;
      ft_Filter_LT:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) = crLT;
      end;
      ft_Filter_LE:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) in [crLT, crEQ];
      end;
      ft_Filter_EQ:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) = crEQ;
      end;
      ft_Filter_NE:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) in [crLT, crGT];
      end;
      ft_Filter_GE:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) in [crEQ, crGT];
      end;
      ft_Filter_GT:
      begin
        Result := DataFile.CompareField( DataFieldID, pDBRec, Filter ) = crGT;
      end;
      ft_Filter_in:
      begin
        Result := FieldValid( pDBRec );
      end;
      ft_Filter_not_in:
      begin
        Result := not FieldValid( pDBRec );
      end;
      else
      begin
        raise Exception.Create('Unrecognised Filter Type');
      end;
    end;
  end;
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
    if DataFile.IndexChanged( IndexField[ i ].DataFieldID ) then
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

(*
procedure TSigDBIndexFieldList.SetBkGround(const Value: tColor);
begin
  fBkGround := Value;
  Root.BkGround := Value;
end;
*)

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
    Owner.Read( 1 ); // root record is in record 1
    Root.fLeftChildIndex := Owner.LeftChild;
  end
  else
  begin
    Root.fLeftChildIndex := 0;
  end;
end;

(*
procedure TSigDBIndexFieldList.SetPaintBox(const Value: tPaintBox);
begin
  fPaintBox := Value;
  Root.PaintBox := Value;
end;
*)

(*
procedure TSigDBIndexFieldList.SetShowAll(const Value: boolean);
begin
  fShowAll := Value;
  Root.ShowAll := Value;
end;
*)

{ tSigDBIndexFile }

procedure tSigDBIndexFile.AddIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  iNew : tSigDBIndex;
begin
  if DataFile = pDataFile then
  begin
    ReadData( pRec );
    if fFields.RecValid( pRec ) then
    begin
      BeforeRecAppend;
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
      AfterRecAppend( pRec );
      OnAction( pRec );
    end;
  end;
end;

procedure tSigDBIndexFile.AfterDBCreate;
begin
  // we add the tree root record

  Append(fBTreeRootRec, fBTreeRecNo );
  inherited;

end;

procedure tSigDBIndexFile.AfterOpen;
begin
  inherited;
  //FreeAndNil( Root.fRightChild ); // safety first
  Read( 1, fBTreeRootRec, fBTreeRecNo );
  // set out root to correct values
  //Root.Invalidate( LeftChild, RightChild );
  //Root.RightChildIndex := RightChild;
end;

procedure tSigDBIndexFile.AfterRecWrite(const pRec: tSigDBRecPointer);
begin
  inherited;
  if pRec = 1 then
  begin
    fBTreeRootRec.Rec := fTempRec.Rec; // not used by data files
  end;
end;

function tSigDBIndexFile.Append(var pBuffer: tSigDBFileBase< tSigDBIndexRec >.Td2;
  var pIndex: tSigDBRecPointer): tSigDBRecPointer;
begin
  //BeforeRecAppend;
  Result := inherited Append( pBuffer, pIndex );
  OnAction( Result );
  //AfterRecAppend( Result );
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

function tSigDBIndexFile.DataFile: tSigDBFileBase;
begin
  Result := fDataFile;
end;

function tSigDBIndexFile.DeleteData(const pRec: tSigDBRecPointer): boolean;
begin
  Result := DataFile.Delete( pRec );
end;

procedure tSigDBIndexFile.DeleteIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
var
  iToDelete : tSigDBRecPointer;
  iIndexRec : tSigDBRecPointer;
begin
  if (DataFile = pDataFile) and (pRec > 0) then
  begin
    DataFile.Lock;
    try
      Datafile.Read( pRec );
      iToDelete := Find( fmEQ );
      if iToDelete > 0 then
      begin
        iIndexRec := fFindPtr.fCurrIndex;
        if Root.LeftChild.Remove( fFindPtr ) then
        begin
          // added because freeing of tree branch no longer deletes index record
          Delete( iIndexRec );
          AfterRecDelete( pRec );
        end;
      end;
    finally
      Unlock;
    end;
  end;
end;

{
procedure tSigDBIndexFile.DeleteIndex(const pRec: tSigDBRecPointer);
begin
  // what about the BTree?
  if pRec > 0 then
  begin
    Delete( pRec );
  end;
end;
}

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

function tSigDBIndexFile.FieldAsText(const pFieldID: integer): string;
begin
  case pFieldID of
    cDataRec    : Result := IntToStr( DataRec );
    cLeftChild  : Result := IntToStr( LeftChild );
    cRightChild : Result := IntToStr( RightChild );
    cTreeDepth  : Result := IntToStr( TreeDepth );
    cDBFileID   : Result := IntToStr( DBFileID );
    else
    begin
      if assigned( fDataFile ) then
      begin
        fDataFile.Read( DataRec );
        Result := fDataFile.FieldAsText( pFieldID - cFieldCount );
      end
      else
      begin
        Result := '';
      end;
    end;
  end;
end;

function tSigDBIndexFile.FieldCount: integer;
begin
  Result := cFieldCount;
  if Assigned( fDataFile ) then
  begin
    Result := Result + fDataFile.FieldCount;
  end;
end;

function tSigDBIndexFile.FieldTitle(const pFieldID: integer): string;
begin
  case pFieldID of
    cDataRec    : Result := 'Data Rec';
    cLeftChild  : Result := 'Left Child';
    cRightChild : Result := 'Right Child';
    cTreeDepth  : Result := 'Tree Depth';
    cDBFileID   : Result := 'DB File ID';
    else
    begin
      if assigned( fDataFile ) then
      begin
        Result := fDataFile.FieldTitle( pFieldID - cFieldCount );
      end
      else
      begin
        Result := '???';
      end;
    end;
  end;
end;

function tSigDBIndexFile.FilterValid(const pIndex : integer; const pValue: string): boolean;
begin
  case Field[ pIndex ].FieldType of
    ft_Filter_Changed: Result := TRUE;
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

function tSigDBIndexFile.Find(pMode: tSigDBFindMode; const pFieldCount : integer ): tSigDBRecPointer;
begin
  if not Open then
  begin
    raise Exception.Create('File not open');
  end;
  // Root.LeftChild is the start point for our search
  fCurrent := Root.LeftChild as tSigDBIndex;
  fFindPtr := nil;
  while assigned( fCurrent ) do
  begin
    //DataFile.Read( iCurrent.SigDBIndex );
    case fFields.Compare( fCurrent.SigDBIndex, pFieldCount ) of
      crEQ:// match found
      begin
        Result := fCurrent.SigDBIndex;
        fFindPtr := fCurrent;
        // it is possible that there are duplicate keys so make sure that we have the lowest
        fCurrent := fCurrent.Prev as tSigDBIndex;
        while assigned( fCurrent ) do
        begin
          if fFields.Compare( fCurrent.SigDBIndex, pFieldCount ) = crEQ then
          begin
            Result := fCurrent.SigDBIndex;
            fFindPtr := fCurrent;
            fCurrent := fCurrent.Prev as tSigDBIndex;
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
        if fCurrent.RightChildIndex = 0 then
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmLE: Result := fFields0.Rec.Data2.DataRec;
            fmGE:
            begin
              fCurrent := fCurrent.Next as tSigDBIndex;
              Read( fCurrent.SigDBIndex );
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
          fCurrent := fCurrent.RightChild as tSigDBIndex;
        end;
      end;
      crGT:
      begin
        // try again with Left Child
        if fCurrent.LeftChildIndex = 0 then
        begin
          // done -  what we return depends on mode
          case pMode of
            fmEQ: Result := 0;
            fmGE: Result := fFields0.Rec.Data2.DataRec;
            fmLE:
            begin
              fCurrent := fCurrent.Prev as tSigDBIndex;
              Read( fCurrent.SigDBIndex );
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
          fCurrent := fCurrent.LeftChild as tSigDBIndex;
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

function tSigDBIndexFile.First( var pCurr: tSigDBIndex;
  const pFieldCount, pMatchCount: integer; const IsReentrant : boolean = FALSE): tSigDBRecPointer;
var
  iCurr : TSigDBIndex;
  iResult : integer;
begin
  if not Open then
  begin
    raise Exception.Create('File not open');
  end;
  // Root.LeftChild is the start point for our search
  if not IsReentrant then
  begin
    pCurr := Root.LeftChild as tSigDBIndex;
  end;
  while assigned( pCurr ) do
  begin
    //DataFile.Read( iCurrent.SigDBIndex );
    case fFields.Compare( pCurr.SigDBIndex, pFieldCount ) of
      crEQ:// match found
      begin
        Result := pCurr.SigDBIndex;
        // it is possible that there are duplicate keys so make sure that we have the lowest
        // we know it must be to the left of us so...
        iCurr := pCurr.LeftChild as tSigDBIndex;
        if assigned( iCurr ) then
        begin
          iResult := First( iCurr, pFieldCount, pMatchCount, TRUE );
          if iResult <> 0 then
          begin
            pCurr := iCurr;
            Result := iResult;
          end;
        end;
        // this should be more efficient than the previous version (below)
        (*
        iCurr := pCurr.Prev as tSigDBIndex;
        while assigned( iCurr ) do
        begin
          if fFields.Compare( iCurr.SigDBIndex, pFieldCount ) = crEQ then
          begin
            pCurr := iCurr;
            Result := iCurr.SigDBIndex;
            iCurr := iCurr.Prev as tSigDBIndex;
          end
          else
          begin
            exit;
          end;
        end;
        *)
        exit;
      end;
      crLT:
      begin
        // try again with Right Child
        if pCurr.RightChildIndex = 0 then
        begin
          Result := 0;
          exit;
        end
        else
        begin
          pCurr := pCurr.RightChild as tSigDBIndex;
        end;
      end;
      crGT:
      begin
        // try again with Left Child
        if pCurr.LeftChildIndex = 0 then
        begin
          // might still be OK if we are just looking for partial match
          if (pMatchCount < pFieldCount) and (fFields.Compare( pCurr.SigDBIndex, pMatchCount ) = crEQ) then
          begin
            Result := pCurr.SigDBIndex;
          end
          else
          begin
            Result := 0;
          end;
          exit;
        end
        else
        begin
          // need to be careful, as this might be possible match
          if (pMatchCount < pFieldCount) and (fFields.Compare( pCurr.SigDBIndex, pMatchCount ) = crEQ) then
          begin
            // here we kind of behave like crEQ above.
            Result := pCurr.SigDBIndex;
            iCurr := pCurr.LeftChild as tSigDBIndex;
            if assigned( iCurr ) then
            begin
              iResult := First( iCurr, pFieldCount, pMatchCount, TRUE );
              if iResult <> 0 then
              begin
                pCurr := iCurr;
                Result := iResult;
              end;
            end;
            exit;
          end
          else
          begin
            pCurr := pCurr.LeftChild as tSigDBIndex;
          end;
        end;
      end;
    end;
  end;
  // if we get here internal structure ensures that the only way to leave
  // the loop is via an exit command. Therefore the only way to get here
  // is with an empty file
  Result := 0;
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
      //DataFile.Read( Result );
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

function tSigDBIndexFile.GetDataRec: tSigDBRecPointer;
begin
  Result := fFields0.Rec.Data2.DataRec;
end;

function tSigDBIndexFile.GetDBFileID: Int32;
begin
  Result := fFields0.Rec.Data2.DBFileID;
end;

function tSigDBIndexFile.GetIndexField(const i: integer): tSigDBIndexField;
begin
  Result := fFields.IndexField[ i ];
end;

function tSigDBIndexFile.GetLeftChild: tSigDBRecPointer;
begin
  Result := fFields0.Rec.Data2.LeftChild;
end;

function tSigDBIndexFile.GetRightChild: tSigDBRecPointer;
begin
  Result := fFields0.Rec.Data2.RightChild;
end;

function tSigDBIndexFile.GetRoot: tSigDBIndexRoot;
begin
  Result := fFields.Root;
end;

function tSigDBIndexFile.GetRootRoot: tSigDBRecPointer;
begin
  Result := fBTreeRootRec.Rec.Data2.LeftChild;
end;

function tSigDBIndexFile.GetTreeDepth: Int32;
begin
  Result := fFields0.Rec.Data2.TreeDepth;
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

function tSigDBIndexFile.Last(var pCurr: tSigDBIndex;
  const pFieldCount, pMatchCount: integer; const IsReentrant : boolean = FALSE): tSigDBRecPointer;
var
  iCurr : TSigDBIndex;
  iResult : integer;
begin
  if not Open then
  begin
    raise Exception.Create('File not open');
  end;
  if not IsReentrant then
  begin
    // Root.LeftChild is the start point for our search
    pCurr := Root.LeftChild as tSigDBIndex;
  end;
  while assigned( pCurr ) do
  begin
    //DataFile.Read( iCurrent.SigDBIndex );
    case fFields.Compare( pCurr.SigDBIndex, pFieldCount ) of
      crEQ:// match found
      begin
        Result := pCurr.SigDBIndex;
        // it is possible that there are duplicate keys so make sure that we have the lowest
        // we know it must be to the left of us so...
        iCurr := pCurr.LeftChild as tSigDBIndex;
        if assigned( iCurr ) then
        begin
          iResult := Last( iCurr, pFieldCount, pMatchCount, TRUE );
          if iResult <> 0 then
          begin
            pCurr := iCurr;
            Result := iResult;
          end;
        end;
        exit;
      end;
      crLT:
      begin
        // try again with Right Child
        if pCurr.RightChildIndex = 0 then
        begin
          // might still be OK if we are just looking for partial match
          if (pMatchCount < pFieldCount) and (fFields.Compare( pCurr.SigDBIndex, pMatchCount ) = crEQ) then
          begin
            Result := pCurr.SigDBIndex;
          end
          else
          begin
            Result := 0;
          end;
          exit;
        end
        else
        begin
          // need to be careful, as this might be possible match
          if (pMatchCount < pFieldCount) and (fFields.Compare( pCurr.SigDBIndex, pMatchCount ) = crEQ) then
          begin
            // here we kind of behave like crEQ above.
            Result := pCurr.SigDBIndex;
            iCurr := pCurr.RightChild as tSigDBIndex;
            if assigned( iCurr ) then
            begin
              iResult := Last( iCurr, pFieldCount, pMatchCount, TRUE );
              if iResult <> 0 then
              begin
                pCurr := iCurr;
                Result := iResult;
              end;
            end;
            exit;
          end
          else
          begin
            pCurr := pCurr.RightChild as tSigDBIndex;
          end;
        end;
      end;
      crGT:
      begin
        // try again with Left Child
        if pCurr.LeftChildIndex = 0 then
        begin
          Result := 0;
          exit;
        end
        else
        begin
          pCurr := pCurr.LeftChild as tSigDBIndex;
        end;
      end;
    end;
  end;
  // if we get here internal structure ensures that the only way to leave
  // the loop is via an exit command. Therefore the only way to get here
  // is with an empty file
  Result := 0;
end;

function tSigDBIndexFile.Last(var pCurr: tSigDBIndex): tSigDBRecPointer;
begin
  Lock;
  try
    pCurr := Root.Last as tSigDBIndex;
    if assigned( pCurr ) then
    begin
      Result := pCurr.fSigDBIndex;
      //DataFile.Read( Result );
    end
    else
    begin
      Result := 0;
    end;
  finally
    Unlock;
  end;
end;

function tSigDBIndexFile.Next(var pCurr: tSigDBIndex;
  const pFieldCount, pMatchCount: integer): tSigDBRecPointer;
begin
  Result := Next( pCurr );
  if Result <> 0 then
  begin
    if fFields.Compare( pCurr.SigDBIndex, pMatchCount ) <> crEQ then
    begin
      Result := 0;
    end;
    {
    else if fFields.Compare( pCurr.SigDBIndex, pFieldCount ) = crGT then
    begin
      Result := 0;
    end;
    }
  end;
end;

function tSigDBIndexFile.NextRec: tSigDBRecPointer;
begin
  Result := fFields0.Rec.Next;
end;

function tSigDBIndexFile.NodeText: string;
var
  i: Integer;
  iString : string;
begin
  Result := '';
  for i := 0 to Fields.Count - 1 do
  begin
    iString := DataFile.FieldAsText( Field[ i ].DataFieldID );
    if iString <> '' then
    begin
      if Result <> '' then
      begin
        Result := Result + ',';
      end;
      Result := Result + iString;
    end;
  end;
end;

function tSigDBIndexFile.Prev(var pCurr: tSigDBIndex;
  const pFieldCount, pMatchCount: integer): tSigDBRecPointer;
begin
  Result := Prev( pCurr );
  if Result <> 0 then
  begin
    if fFields.Compare( pCurr.SigDBIndex, pFieldCount ) <> crEQ then
    begin
      Result := 0;
    end
    else if fFields.Compare( pCurr.SigDBIndex, pFieldCount ) = crLT then
    begin
      Result := 0;
    end;
  end;
end;

function tSigDBIndexFile.PrevRec: tSigDBRecPointer;
begin
  Result := self.fFields0.Rec.Prev;
end;

function tSigDBIndexFile.Prev(var pCurr: tSigDBIndex): tSigDBRecPointer;
begin
  Lock;
  try
    pCurr := pCurr.Prev as tSigDBIndex;
    if assigned( pCurr ) then
    begin
      Result := pCurr.fSigDBIndex;
      //DataFile.Read( Result );
    end
    else
    begin
      Result := 0;
    end;
  finally
    Unlock;
  end;
end;

function tSigDBIndexFile.Next(var pCurr: tSigDBIndex): tSigDBRecPointer;
begin
  Lock;
  try
    pCurr := pCurr.Next as tSigDBIndex;
    if assigned( pCurr ) then
    begin
      Result := pCurr.fSigDBIndex;
      //DataFile.Read( Result );
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
  Result := DataFile.Read( pRec );
end;

procedure tSigDBIndexFile.Reindex;
var
  iRec : tSigDBRecPointer;
begin
  Lock;
  try
    Open := FALSE;
    fForceCreate := TRUE;
    Root.Invalidate( 0, 0 );
    Open := TRUE;
    iRec := DataFile.LastInserted;
    while iRec > 0 do
    begin
      AddIndex( DataFile, iRec );
      iRec := DataFile.NextRec;
    end;
  finally
    Unlock;
  end;
end;

(*
procedure tSigDBIndexFile.SetBkGround(const Value: tColor);
begin
  fBkGround := Value;
  Fields.BkGround := Value;
end;
*)

procedure tSigDBIndexFile.SetDataRec(const Value: tSigDBRecPointer);
begin
  fFields0.Rec.Data2.DataRec := Value;
  //OnField0Change;
end;

procedure tSigDBIndexFile.SetDBFileID(const Value: Int32);
begin
  fFields0.Rec.Data2.DBFileID := Value;
  //OnField0Change;
end;

procedure tSigDBIndexFile.SetLeftChild(const Value: tSigDBRecPointer);
begin
  fFields0.Rec.Data2.LeftChild := Value;
  //OnField0Change;
end;

(*
procedure tSigDBIndexFile.SetPaintBox(const Value: tPaintBox);
begin
  fPaintBox := Value;
  Fields.PaintBox := Value;
end;
*)

procedure tSigDBIndexFile.SetRightChild(const Value: tSigDBRecPointer);
begin
  fFields0.Rec.Data2.RightChild := Value;
  //OnField0Change;
end;

(*
procedure tSigDBIndexFile.SetShowAll(const Value: boolean);
begin
  fShowAll := Value;
  Fields.ShowAll := Value;
end;
*)

procedure tSigDBIndexFile.SetTreeDepth(const Value: Int32);
begin
  fFields0.Rec.Data2.TreeDepth := Value;
  //OnField0Change;
end;

(*
procedure tSigDBIndexFile.ShowSortedRecs(const FromNode: tSigDBRecPointer);
var
  iMaxRows : integer;
  i, j: Integer;
  iNext : tSigDBIndex;
  iRec : tSigDBRecPointer;
begin
  if assigned( fListGrid ) then
  begin
    iMaxRows := (fListGrid.ClientHeight div fListGrid.DefaultRowHeight) - fListGrid.FixedRows;
    fListGrid.RowCount := iMaxRows;
    if FromNode = 0 then
    begin
      iRec := First( iNext );
    end
    else if CurrIndex = FromNode then
    begin
      iNext := fCurrent;
      iRec := FromNode;
    end
    else
    begin
      raise Exception.Create('Internal error 001');
    end;

    for i := 1 to iMaxRows - 1 do
    begin
      Read( iRec );
      //ReadData( DataRec );
      ShowCell( 0, i, IntToStr( iRec ));
      for j := 0 to FieldCount - 1 do
      begin
        ShowCell( j + 1, i, FieldAsText( j ));
      end;
      {iRec := }Next( iNext );
      if assigned(iNext) then
      begin
        iRec := iNext.CurrIndex;
      end
      else
      begin
        fListGrid.RowCount := i + 1;
        break;
      end;
    end;
  end;
end;
*)

procedure TSigDBIndexFile.TextToField(const pFieldID: integer; Value: string);
begin
  //DataFile.TextToField( pFieldID, Value );
  case pFieldID of
    cDataRec    : DataRec := StrToInt( Value );
    cLeftChild  : LeftChild := StrToInt( Value );
    cRightChild : RightChild := StrToInt( Value );
    cTreeDepth  : TreeDepth := StrToInt( Value );
    cDBFileID   : DBFileID := StrToInt( Value );
    else
    begin
      if assigned( fDataFile ) then
      begin
        fDataFile.TextToField( pFieldID - cFieldCount, Value );
      end;
    end;
  end;

end;

function tSigDBIndexFile.UpdateData: tSigDBRecPointer;
begin
  Result := DataFile.Update;
end;

procedure tSigDBIndexFile.UpdateIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  if DataFile = pDataFile then
  begin
    if IndexChanged( pDataFile ) then
    begin
      //DeleteIndex( pDataFile, pDataFile.UpdateRecNo );
      DeleteIndex( pDataFile, pRec );
      //DeleteUpdateIndex( pDataFile );
      AddIndex( pDataFile, pRec );
    end;
    OnAction( pRec );  // data file has changed to execute an OnAction even if index has not changed
  end;
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
  raise TSigDBException.Create('Field Validity cannot be determined');
end;

{ tSigDBFileBaselist }

procedure tSigDBFileBaselist.AfterOpen;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FileBase[ i ].AfterOpen;
  end;
end;

procedure tSigDBFileBaselist.BeforeClose;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    FileBase[ i ].BeforeClose;
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

procedure tSigDBDataFile<T>.AfterRecWrite( const pRec : tSigDBRecPointer);
begin
  inherited;
  // buffers are in fFields0 and old value in fUpdateRec.
  // data buffer can use these values to decide if
  // index needs to be updated
  Database.UpdateIndex( self, pRec );
end;

function tSigDBDataFile<T>.Append(var pBuffer: tSigDBFileBase< T >.Td2;
  var pIndex: tSigDBRecPointer): tSigDBRecPointer;
begin
  Lock;
  try
    fTempRec := pBuffer;
    BeforeRecAppend;
    pBuffer := fTempRec;
    Result := inherited Append( pBuffer, pIndex );
    AfterRecAppend( Result );
  finally
    Unlock;
  end;
end;

procedure tSigDBDataFile<T>.BeforeRecWrite(const pRec: tSigDBRecPointer );
begin
  inherited;
  // load the current record to the update buffer

  Read( pRec, fUpdateRec, fUpdateRecNo );
  // and restore rec0 to the temporary buffer
  fTempRec := fFields0;
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
    // but also need to mark field 0 as memory rec!
    fFields0RecNo := 0;
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
    // but also need to mark field 0 as memory rec!
    fFields0RecNo := 0;
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
    // but also need to mark field 0 as memory rec!
    fFields0RecNo := 0;
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

function tSigDBDataFile<T>.Delete(pRec: tSigDBRecPointer) : boolean;
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

procedure tSigDBDataFile<T>.AfterRecAppend(const pRec: tSigDBRecPointer );
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
    // pCurrIndex is always 1 for Root, but the root record is not read
    // until file is open
    fCurrIndex := pCurrIndex;

  end
  else if pCurrIndex = 0 then // we are adding new record
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
  // removal of associated record in index file not valid - must do expilicitely not implicitely
  //if fCurrIndex > 1 then
  //begin
  //  fIndexFile.Delete( fCurrIndex );
  //end;
  inherited;
end;

{
procedure tSigDBIndex.DrawNode(const Canvas: tCanvas; pCurrLine: tRect);
begin
  inherited;

end;
}

(*
procedure tSigDBIndex.DrawTree(const Canvas: tCanvas;
  const pLineHeight: integer; const pCurrLine: tRect);
  {
    unlike our ancestor we do not draw the entire tree - only the loaded portion
  }
var
  iLeftRect, iRightRect : tRect;
  iCentre : integer;
begin
  DrawNode( Canvas, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if LeftChildIndex <> 0 then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Canvas.MoveTo( iCentre, pCurrLine.Top + Canvas.TextHeight( 'X' ) + 2 );
    Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    LeftChild.DrawTree( Canvas, pLineHeight, iLeftRect );
  end;
  if RightChildIndex <> 0 then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Canvas.MoveTo( iCentre, pCurrLine.Top + Canvas.TextHeight( 'X' ) + 2 );
    Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    RightChild.DrawTree( Canvas, pLineHeight, iRightRect );
  end;
end;
*)

(*
procedure tSigDBIndex.DrawTree(const Paintbox: tPaintBox;
  const pLineHeight: integer; const pCurrLine: tRect; const DrawAll : boolean);
  {
    unlike our ancestor we do not draw the entire tree - only the loaded portion
  }
var
  iLeftRect, iRightRect : tRect;
  iCentre : integer;
begin
  DrawNode( Paintbox, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if assigned( fLeftChild ) or (DrawAll and (LeftChildIndex <> 0)) then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    LeftChild.DrawTree( PaintBox, pLineHeight, iLeftRect, DrawAll );
  end
  else if  LeftChildIndex <> 0 then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iLeftRect, self, cLeftChild );
  end;
  if assigned( fRightChild ) or (DrawAll and (RightChildIndex <> 0)) then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    RightChild.DrawTree( Paintbox, pLineHeight, iRightRect, DrawAll );
  end
  else if RightChildIndex <> 0 then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iRightRect, self, cRightChild );
  end;
end;
*)

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
        Result.Parent := self;
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

procedure tSigDBIndex.Invalidate(const NewLeftChildRec,
  NewRightChildRec: tSigDBRecPointer);
begin
  FreeAndNil( fLeftChild );
  FreeAndNil( fRightChild );
  fLeftChildIndex := NewLeftChildRec;
  fRightChildIndex := NewRightChildRec;
end;

function tSigDBIndex.LessThan(const SigTreeNode: tSigBTreeNode): boolean;
var
  iSigTreeNode : tSigDBIndex;
begin
  iSigTreeNode := SigTreeNode as tSigDBIndex;
  Result := IndexFile.Fields.Compare( self.SigDBIndex, iSigTreeNode.SigDBIndex, IndexFile.Fields.Count ) = crLT;
end;

function tSigDBIndex.NodeText: string;
begin
  IndexFile.ReadData( SigDBIndex );
  Result := IndexFile.NodeText;
end;

function tSigDBIndex.PruneOldBranches(pNotUsedSince: tDateTime) : boolean;
begin
  Result := fLastAccessed < pNotUsedSince;
  if assigned( fLeftChild ) then
  begin
    if (fLeftChild as tSigDBIndex).PruneOldBranches( pNotUsedSince ) then
    begin
      (fLeftChild as tSigDBIndex).fCurrIndex := 0;
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
      (fRightChild as tSigDBIndex).fCurrIndex := 0;
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
      LastAccessed := Now;
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
begin
  if fTreeDepth <> Value then
  begin
    fTreeDepth := Value;
    UpdateIndexFile;
  end;
end;

procedure tSigDBIndex.UpdateIndexFile;
begin
  IndexFile.Lock;
  try
    IndexFile.Read( fCurrIndex );
    IndexFile.LeftChild := fLeftChildIndex;
    IndexFile.RightChild := fRightChildIndex;
    IndexFile.TreeDepth := fTreeDepth;
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

(*
procedure tSigDBIndexRoot.OnMouseUp(Sender: TObject; pButton: TMouseButton;
  pShift: TShiftState; X, Y: integer);
var
  iCell : TPaintBoxCell;
begin
  if assigned( fOnMouseUp ) then
  begin
    fOnMouseUp( Sender, pButton, pShift, X, Y );
  end;
  if pButton = mbLeft then
  begin
    if pShift = [] then
    begin
      iCell := PaintBox.MouseToCell( X, Y );
      if assigned( iCell ) then
      begin
        case iCell.Tag of
          cSelf:
          begin
            if iCell.Data = fVisibleRoot then
            begin
              fVisibleRoot := nil;
            end
            else
            begin
              fVisibleRoot:= iCell.Data as tSigDBIndex;
            end;
          end;
          1: // left Child
          begin
            (iCell.Data as tSigDBIndex).LeftChild; // load left child! But leave root as is
          end;
          2:
          begin
            (iCell.Data as tSigDBIndex).RightChild; // Load right child
          end;
          else
          begin
            // should not get here!
            fVisibleRoot := nil;
          end;
        end;
        if iCell.Tag = 0 then
        begin
        end
        else if iCell.Tag <> 0 then
        else
        begin
          fVisibleRoot := nil;
        end;
        Paintbox.Repaint;
      end;
    end
    else if pShift = [ ssShift ] then
    begin
      fShowAll := not fShowAll;
      Paintbox.Repaint;
    end;
  end;
end;
*)

(*
procedure tSigDBIndexRoot.OnPaint(Sender: tObject);
var
  iDepth, iRowCount : integer;
  iRowHeight : integer;
  iRect : tRect;
  iVisibleRoot : tSigDBIndex;
begin
  // A box filling the whole canvas in the background colour
  fPaintbox.Clear;
  if assigned( fVisibleRoot ) then
  begin
    iVisibleRoot := fVisibleRoot;
  end
  else
  begin
    iVisibleRoot := LeftChild as tSigDBIndex;
  end;
  if assigned( iVisibleRoot ) then
  begin
    iDepth := iVisibleRoot.TreeDepth + 1;
    // interlace the rows by blank rows (for our lines );
    iRowCount := 2 * iDepth + 1;
    iRowHeight := fPaintbox.ClientHeight div iRowCount;
    iRect := fPaintbox.ClientRect;
    iVisibleRoot.DrawTree( fPaintbox, iRowHeight, iRect, ShowAll );
  end;
  {
  if ShowAll then
  begin
    if LeftChildIndex > 0 then
    begin
      iDepth := LeftChild.TreeDepth + 1;
      // interlace the rows by blank rows (for our lines );
      iRowCount := 2 * iDepth + 1;
      iRowHeight := fPaintbox.ClientHeight div iRowCount;
      iRect := fPaintbox.ClientRect;
      LeftChild.DrawTree( fPaintbox, iRowHeight, iRect );
    end;
  end
  else
  begin
    if assigned( LeftChild ) then
    begin
      iDepth := LeftChild.TreeDepth + 1;
      // interlace the rows by blank rows (for our lines );
      iRowCount := 2 * iDepth + 1;
      iRowHeight := fPaintbox.ClientHeight div iRowCount;
      iRect := fPaintbox.ClientRect;
      LeftChild.DrawTree( fPaintbox, iRowHeight, iRect );
    end;
  end;
  }
end;
*)

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
    if assigned( fOnChange ) then
    begin
      fOnChange( self );
    end;
  end;
end;

(*
procedure tSigDBIndexRoot.SetBkGround(const Value: tColor);
begin
  fBkGround := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintbox.BkColour := Value;
  end;
end;
*)

procedure tSigDBIndexRoot.SetLeftChild(const Value: tSigBTreeNode);
begin
  Lock;
  try
    inherited;
  finally
    Unlock;
    if assigned( fOnChange ) then
    begin
      fOnChange( Self );
    end;
  end;
end;

(*
procedure tSigDBIndexRoot.SetPaintBox(const Value: tPaintBox);
begin
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnMouseUp := fOnMouseUp;
  end;
  fPaintBox := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnPaint := self.OnPaint;
    fOnMouseUp := fPaintBox.OnMouseUp;
    fPaintBox.OnMouseUp := OnMouseUp;
    fPaintBox.BkColour := fBkGround;
    fPaintBox.Repaint;
  end;
end;
*)

procedure tSigDBIndexRoot.SetRightChild(const Value: tSigBTreeNode);
begin
  Lock;
  try
    inherited;
  finally
    Unlock;
    if assigned( fOnChange ) then
    begin
      fOnChange( self );
    end;
  end;
end;

(*
procedure tSigDBIndexRoot.SetVisibleRoot(const Value: tSigDBIndex);
begin
  fVisibleRoot := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.Repaint;
  end;
end;
*)

procedure tSigDBIndexRoot.Unlock;
begin
  TMonitor.Exit(fLock);
end;

{ tSigDBFileBase<T> }

function tSigDBFileBase<T>.Append(var pBuffer: Td2;
  var pIndex: tSigDBRecPointer): tSigDBRecPointer;
var
  iTemp : tSigDBRecPointer;
  iResult : integer;
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
    //fTempRec := pBuffer;
    //BeforeRecAppend;
    //pBuffer := fTempRec;
    if fRootRec.Rec.DelLast = 0 then
    begin
      Seek( fFile, FileSize( fFile ) );  // find end of file
      Result := FilePos( fFile );        // record it
      pBuffer.Rec.Next := fRootRec.Rec.InsLast;  // maintain linked list
      pBuffer.Rec.Prev := 0;
      BlockWrite( fFile, pBuffer.Rec, 1, iResult );
      if iResult <> 1 then  // write new record
      begin
        raise Exception.Create('Unable to append record');
      end;
      pIndex := Result;                  // update store
      if fRootRec.Rec.InsLast <> 0 then
      begin
        fUpDateRecNo := 0; // force read
        Read( fRootRec.Rec.InsLast, fUpdateRec, fUpdateRecNo );
        fUpdateRec.Rec.Prev := Result;
        Write( fUpdateRecNo, fUpdateRec );
      end;
      //Seek( fFile, iTemp );
      //BlockWrite( fFile, fUpdateRec, 1 );
      fRootRec.Rec.InsLast := Result;        // renew last entry in linked list
      Write( 0, fRootRec );// update root
      //fTempRec := pBuffer;
      //AfterRecAppend( Result );             // do any ancillary actions
      // no need to write back - data would not match file!
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
        if fFields2RecNo = fUpdateRecNo then
        begin
          fFields2.Rec := fUpdateRec.Rec;
        end;
        if fFields1RecNo = fUpdateRecNo then
        begin
          fFields1.Rec := fUpdateRec.Rec;
        end;
      end;
      //Seek( fFile, iTemp );
      //BlockWrite( fFile, fUpdateRec, 1 );
      fRootRec.Rec.InsLast := Result;              // renew entry in linked list
      Write( 0, fRootRec );      // update root
      //fTempRec := pBuffer;
      //AfterRecAppend( Result );             // do any ancillary actions
    end;
  finally
    (*
    // force data to disk. If this is not done a susequent read will bring
    // back old read value.
    CloseFile( fFile );
    Reset( fFile, SizeOf( tD ));
    *)
    Database.Unlock;
  end;
end;

procedure tSigDBFileBase<T>.AfterRecRead(const pRec: tSigDBRecPointer );
begin
  fInterestedParties.AfterRecRead( self, pRec );
end;

procedure tSigDBFileBase<T>.AfterRecWrite(const pRec: tSigDBRecPointer );
begin
  fInterestedParties.AfterRecWrite( self, pRec );
end;

function tSigDBFileBase<T>.Append: tSigDBRecPointer;
begin
  Result := Append( fFields0, fFields0RecNo );
  //OnField0Change;
end;

procedure tSigDBFileBase<T>.BeforeClose;
begin
  fInterestedParties.BeforeClose( self );
end;

procedure tSigDBFileBase<T>.BeforeRecAppend;
begin
  fInterestedParties.BeforeRecAppend( self );
end;

procedure tSigDBFileBase<T>.BeforeRecDelete(const pRec: tSigDBRecPointer);
begin
  fInterestedParties.BeforeRecordDelete( self, pRec );
end;

procedure tSigDBFileBase<T>.BeforeRecWrite(const pRec: tSigDBRecPointer);
begin
  fInterestedParties.BeforeRecWrite( self, pRec );
end;

function tSigDBFileBase<T>.CanDelete(const pRec: tSigDBRecPointer ): boolean;
begin
  Result := fInterestedParties.CanDelete( self, pRec );
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
  fInterestedParties := TInterestedPartiesList.Create;
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

function tSigDBFileBase<T>.CurrRec: tSigDBRecPointer;
begin
  Result := fFields0RecNo;
end;

class function tSigDBFileBase<T>.CurrVerMajor: word;
begin
  Result := 0;
end;

class function tSigDBFileBase<T>.CurrVerMinor: word;
begin
  Result := 0;
end;

function tSigDBFileBase<T>.Delete(pRec: tSigDBRecPointer) : boolean;
var
  iDelRec : tSigDBRecPointer;
begin
  // move the record to the deleted list
  Lock;
  try
    Read( pRec, fDelRec, iDelRec );
    Result := CanDelete( pRec );
    if Result then
    begin
      BeforeRecDelete( pRec );
      // If we are deleting the last inserted record then we need to adjust
      // last inserted record.
      if fRootRec.Rec.InsLast = iDelRec then
      begin
        fRootRec.Rec.InsLast := fDelRec.Rec.Next;
        // don't write yet - it will be written later in this procedure.
      end;
      if fDelRec.Rec.Prev = 0 then
      begin
        fFields1RecNo := 0;
      end
      else
      begin
        Read( fDelRec.Rec.Prev, fFields1, fFields1RecNo );
      end;
      if fDelRec.Rec.Next = 0 then
      begin
        fFields2RecNo := 0;
      end
      else
      begin
        Read( fDelRec.Rec.Next, fFields2, fFields2RecNo );
      end;
      if fFields1RecNo <> 0 then
      begin
        fFields1.Rec.Next := fFields2RecNo;
        Write( fFields1RecNo, fFields1 );
      end;
      if fFields2RecNo <> 0 then
      begin
        fFields2.Rec.Prev := fFields1RecNo;
        Write( fFields2RecNo, fFields2 );
      end;
      fDelRec.Rec.Next := fRootRec.Rec.DelLast;
      fRootRec.Rec.DelLast := iDelRec;
      Write( iDelRec, fDelRec );
      Write ( 0, fRootRec );
    end;
  finally
    Unlock;
  end;

end;

destructor tSigDBFileBase<T>.Destroy;
begin
  fInterestedParties.Free;
  //fLock.Free;
  inherited;
end;

function tSigDBFileBase<T>.GetLastDeleted: tSigDBRecPointer;
begin
  if Open then
  begin
    Result := fRootRec.Rec.DelLast;
  end
  else
  begin
    raise Exception.Create('File not open');
  end;
end;

function tSigDBFileBase<T>.GetLastInserted: tSigDBRecPointer;
begin
  if Open then
  begin
    Result := fRootRec.Rec.InsLast;
  end
  else
  begin
    raise Exception.Create('File not open');
  end;
end;

function tSigDBFileBase<T>.GetNextRec: tSigDBRecPointer;
begin
  if Open then
  begin
    Result := fFields0.Rec.Next;
  end
  else
  begin
    raise Exception.Create('File not open');
  end;
end;

function tSigDBFileBase<T>.GetRecCount: Int64;
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

procedure tSigDBFileBase<T>.AfterDBCreate;
begin
  fInterestedParties.AfterDBCreate( self );
end;

procedure tSigDBFileBase<T>.AfterOpen;
begin
  fInterestedParties.AfterOpen( self );
end;

procedure tSigDBFileBase<T>.AfterRecAppend(const pRec: tSigDBRecPointer);
begin
  fInterestedParties.AfterRecAppend( self, pRec );
end;

procedure tSigDBFileBase<T>.AfterRecDelete(const pRec: tSigDBRecPointer);
begin
  fInterestedParties.AfterRecordDelete( self );
end;

{
procedure tSigDBFileBase<T>.OnField0Change;
begin
  if fFields0RecNo = fFields1RecNo then
  begin
    fFields1 := fFields0;
  end;
  if fFields0RecNo = fFields2RecNo then
  begin
    fFields2 := fFields0;
  end;
end;
}

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
    if fForceCreate or not FileExists( iFile ) then
    begin
      fForceCreate := FALSE;
      Rewrite( fFile, iRecLen );
      try
        // create record zero
        fRootRec.Rec.DelLast := 0;
        fRootRec.Rec.VerMajor := pVerMajor;
        fRootRec.Rec.VerMinor := pVerMinor;
        BlockWrite( fFile, fRootRec.Rec, 1, iResult );
        if iResult <> 1 then
        begin
          raise Exception.Create('Unable to create file successfully');
        end;
        AfterDBCreate;
      finally
        CloseFile( fFile );
      end;
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
        BlockWrite( fFile, fRootRec.Rec, 1, iResult );
        if iResult <> 1 then
        begin
          raise Exception.Create('Unable to initialise file successfully');
        end;
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
  {
  // because Rec0 is volatile, we cannot assume that rec0 data is valid!
  else if pRec = fFields0RecNo then
  begin
    Result := TRUE;
    fTempRec := fFields0;
    AfterRecRead( pRec );
    fFields0 := fTempRec;
  end
  }
  else if pRec = fFields1RecNo then
  begin
    fFields0.Rec := fFields1.Rec;
    fFields0RecNo := fFields1RecNo;
    Result := TRUE;
    fTempRec := fFields0;
    AfterRecRead( pRec );
    fFields0 := fTempRec;
    fFields1 := fTempRec;
  end
  else if pRec = fFields2RecNo then
  begin
    fFields0.Rec := fFields2.Rec;
    fFields0RecNo := fFields2RecNo;
    Result := TRUE;
    fTempRec := fFields0;
    AfterRecRead( pRec );
    fFields0 := fTempRec;
    fFields2 := fTempRec;
  end
  else
  begin
    fFields0RecNo := 0; // force reread
    Result := Read( pRec, fFields0, fFields0RecNo );
  end;
end;

procedure tSigDBFileBase<T>.RegisterInterestedParty( pParty: TInterestedParty);
begin
  fInterestedParties.Add( pParty );
end;

function tSigDBFileBase<T>.Read(const pRec: tSigDBRecPointer; var pBuffer: Td2;
  var pIndex: tSigDBRecPointer): boolean;
var
  iResult : integer;
begin
  Lock;
  try
    if fOpen then
    begin
      if pRec >= RecCount then
      begin
        Result := FALSE;
        exit;
      end;
      Seek( fFile, pRec );
      BlockRead( fFile, pBuffer.Rec, 1, iResult );
      if iResult <> 1 then
      begin
        Result := FALSE;
        exit;
      end;
      pIndex := pRec;
      Result := TRUE;
      fTempRec := pBuffer;
      AfterRecRead( pRec );
      pBuffer := fTempRec;
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
      fOpen := TRUE; // required because OpenDBFile tests for fOpen before updating certain fields
      fOpen := OpenDBFile( CurrVerMajor, CurrVerMinor );
    end
    else
    begin
      CloseDBFile;
      fOpen := FALSE;
    end;
  finally
    Unlock;
  end;
end;

procedure tSigDBFileBase<T>.Unlock;
begin
  Database.Unlock;
end;

procedure tSigDBFileBase<T>.UnregisterInterestedParty(pParty: TInterestedParty);
begin
  fInterestedParties.Remove( pParty );
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

function tSigDBFileBase<T>.UpdateRecNo: tSigDBRecPointer;
begin
  Result := fUpdateRecNo;
end;

function tSigDBFileBase<T>.Version: string;
begin
  Result := IntToStr( fRootRec.Rec.VerMajor ) + '.' + IntToStr( fRootRec.Rec.VerMinor );
end;

function tSigDBFileBase<T>.Write(const pRec: tSigDBRecPointer): boolean;
begin
  fTempRec := fFields0;
  BeforeRecWrite( pRec );
  fFields0 := fTempRec;
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
  fTempRec := fFields0;
  AfterRecWrite( pRec );
end;

function tSigDBFileBase<T>.Write(const pRec: tSigDBRecPointer; var pBuffer: Td2 ): boolean;
var
  iResult : integer;
begin
  Lock;
  try
    if fOpen then
    begin
      Seek( fFile, pRec );
      BlockWrite( fFile, pBuffer.Rec, 1, iResult );
      Result := iResult = 1;
      //Result := TRUE;
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

procedure tSigDBFileBase.AddIndex(const pDataFile: tSigDBFileBase;
  const pRec: tSigDBRecPointer);
begin
  // do nothing by default
end;

constructor tSigDBFileBase.Create(const pName: string);
begin
  inherited Create;
  fName := pName;
end;

function tSigDBFileBase.DataFile: tSigDBFileBase;
begin
  Result := nil;
end;

function tSigDBFileBase.FieldAsText(const pFieldID: integer): string;
begin
  Result := '';
end;

function tSigDBFileBase.FieldCount: integer;
begin
  Result := 0;
end;

function tSigDBFileBase.FieldTitle(const pFieldID : integer): string;
begin
  Result := '';
end;

function tSigDBFileBase.GetLastDeleted: tSigDBRecPointer;
begin
  raise exception.Create( 'Invalid LAST DELETED request' );
end;

function tSigDBFileBase.GetLastInserted: tSigDBRecPointer;
begin
  raise exception.Create( 'Invalid LAST INSERTED request' );
end;

function tSigDBFileBase.GetNextRec: tSigDBRecPointer;
begin
  raise exception.Create( 'Invalid NEXT REC request' );
end;

function tSigDBFileBase.GetRecCount: Int64;
begin
  raise exception.Create( 'Invalid RECORD COUNT request' );
end;

procedure tSigDBFileBase.OnAction(const pRec: tSigDBRecPointer);
begin
  fInterestedParties.OnAction( self, pRec );
end;

(*
procedure tSigDBFileBase.SetListGrid(const Value: tStringGrid);
var
  i : integer;
begin
  fListGrid := Value;
  if assigned( fListGrid ) then
  begin
    with fListGrid do
    begin
      ColCount := FieldCount + 1;   // one for Rec No
      ShowCell( 0, 0, 'Rec No.' );
      for i := 0 to FieldCount - 1 do
      begin
        ShowCell( i + 1, 0, FieldTitle( i ));
      end;
    end;
  end;
end;
*)

procedure tSigDBFileBase.SetOpen(pOpen: boolean);
begin
  raise exception.Create( 'Invalid OPEN request' );
end;

(*
procedure tSigDBFileBase.ShowCell(const pX, pY: integer; const pText: string);
var
  iTextWidth : integer;
begin
  if assigned( fListGrid ) then
  begin
    with fListGrid do
    begin
      iTextWidth := Canvas.TextWidth( pText + 'XX' );
      if iTextWidth > ColWidths[ pX ] then
      begin
        ColWidths[ pX ] := iTextWidth;
      end;
      Cells[ pX, pY ] := pText;
    end;
  end;
end;

procedure tSigDBFileBase.ShowRecs(const pFromRecNo: tSigDBRecPointer);
var
  iMaxRows : integer;
  iRecsLeft : integer;
  i, j: Integer;
begin
  if assigned( fListGrid ) then
  begin
    iMaxRows := (fListGrid.ClientHeight div fListGrid.DefaultRowHeight) - fListGrid.FixedRows;
    iRecsLeft := RecCount - pFromRecNo;
    if iRecsLeft < iMaxRows then
    begin
      iMaxRows := iRecsLeft;
    end;
    fListGrid.RowCount := iMaxRows + 1;
    for i := 0 to iMaxRows - 1 do
    begin
      Read( i + pFromRecNo );
      ShowCell( 0, i + 1, IntToStr( i + pFromRecNo ));
      for j := 0 to FieldCount - 1 do
      begin
        ShowCell( j + 1, i + 1, FieldAsText( j ));
      end;
    end;
  end;

end;
*)

{ TInterestedParty<T> }

procedure TInterestedParty.AfterDBCreate( Sender : TObject );
begin

end;

procedure TInterestedParty.AfterOpen( Sender : TObject );
begin

end;

procedure TInterestedParty.AfterRecAppend( Sender : TObject; const pRec : tSigDBRecPointer );
begin

end;

procedure TInterestedParty.AfterRecordDelete(Sender: TObject);
begin

end;

procedure TInterestedParty.AfterRecRead( Sender : TObject; const pRec : tSigDBRecPointer );
begin

end;

procedure TInterestedParty.AfterRecWrite( Sender : TObject; const pRec : tSigDBRecPointer );
begin

end;

procedure TInterestedParty.BeforeClose( Sender : TObject );
begin

end;

procedure TInterestedParty.BeforeRecAppend( Sender : TObject);
begin

end;

procedure TInterestedParty.BeforeRecordDelete( Sender : TObject; const pRec : tSigDBRecPointer );
begin

end;

procedure TInterestedParty.BeforeRecWrite( Sender : TObject; const pRec : tSigDBRecPointer );
begin

end;

function TInterestedParty.CanDelete( Sender : TObject; const pRec : tSigDBRecPointer ): boolean;
begin
  Result := TRUE;
end;

procedure TInterestedParty.OnAction(Sender : TObject; const pRec: tSigDBRecPointer);
begin

end;

{ TInterestedPartiesList }

procedure TInterestedPartiesList.AfterDBCreate( Sender : TObject );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterDBCreate( Sender );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.AfterOpen( Sender : TObject );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterOpen( Sender );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.AfterRecAppend( Sender : TObject;const pRec: tSigDBRecPointer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterRecAppend( Sender, pRec );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.AfterRecordDelete(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterRecordDelete( Sender );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.AfterRecRead( Sender : TObject; const pRec: tSigDBRecPointer );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterRecRead( Sender, pRec );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.AfterRecWrite( Sender : TObject; const pRec: tSigDBRecPointer );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].AfterRecWrite( Sender, pRec );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.BeforeClose( Sender : TObject );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].BeforeClose( Sender );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.BeforeRecAppend( Sender : TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].BeforeRecAppend( Sender );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.BeforeRecordDelete( Sender : TObject; const pRec: tSigDBRecPointer);
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].BeforeRecordDelete( Sender, pRec );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

procedure TInterestedPartiesList.BeforeRecWrite( Sender : TObject; const pRec: tSigDBRecPointer );
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].BeforeRecWrite( Sender, pRec );
    except
      // don't abort on error - is clients responsibility totrap errors and act on them
    end;
  end;
end;

function TInterestedPartiesList.CanDelete( Sender : TObject; const pRec: tSigDBRecPointer): boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Count - 1 do
  begin
    try
      if not Items[ i ].CanDelete( Sender, pRec ) then
      begin
        Result := FALSE;
        exit;
      end;
    except
      // assume OK to delete on failure
    end;
  end;
end;

procedure TInterestedPartiesList.OnAction(Sender : TObject; const pRec: tSigDBRecPointer);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    try
      Items[ i ].OnAction( Sender, pRec );
    except
    end;
  end;
end;

end.

