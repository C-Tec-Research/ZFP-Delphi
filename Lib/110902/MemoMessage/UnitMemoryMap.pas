unit UnitMemoryMap;

interface

uses
  Contnrs,
  SysUtils;

type
  tMMMessageModificationMatrixEntry = class
  protected
    iGenericMessageSilence : byte;
    iGenericMessageTest    : byte;
    iGenericMessageAlert   : byte;
    iGenericMessageEvac    : byte;
    iNormaliseMessageSilence : byte;
    iNormaliseMessageTest    : byte;
    iNormaliseMessageAlert   : byte;
    iNormaliseMessageEvac    : byte;
  public
    procedure Load( pValues : AnsiString );
    property GenericMessageSilence : byte
             read iGenericMessageSilence
             write iGenericMessageSilence;
    property GenericMessageTest : byte
             read iGenericMessageTest
             write iGenericMessageTest;
    property GenericMessageAlert : byte
             read iGenericMessageAlert
             write iGenericMessageAlert;
    property GenericMessageEvac : byte
             read iGenericMessageEvac
             write iGenericMessageEvac;
    property NormaliseMessageSilence : byte
             read iNormaliseMessageSilence
             write iNormaliseMessageSilence;
    property NormaliseMessageTest : byte
             read iNormaliseMessageTest
             write iNormaliseMessageTest;
    property NormaliseMessageAlert : byte
             read iNormaliseMessageAlert
             write iNormaliseMessageAlert;
    property NormaliseMessageEvac : byte
             read iNormaliseMessageEvac
             write iNormaliseMessageEvac;
    function DownLoadString : AnsiString;
  end;

  tMMMessageModificationMatrix = class
  protected
    iEntry : array [ 0..15 ] of tMMMessageModificationMatrixEntry;
    function fGetEntry( const index : integer ) : tMMMessageModificationMatrixEntry;
  public
    constructor Create;
    procedure Load( pValues : AnsiString );
    property Entry[ const index : integer ] : tMMMessageModificationMatrixEntry
             read fGetEntry;
    function DownLoadString : AnsiString;
  end;

  tMMPlayListEntry = class
  protected
    iValue : word;
    function fGetToken : byte;
    function fGetParm : word;
    procedure fSetToken( NewVal : byte );
    procedure fSetParm( NewVal : word );
  public
    procedure Load( pValue : AnsiString );
    property Token : byte
             read fGetToken
             write fSetToken;
    property Parm : word
             read fGetParm
             write fSetParm;
    property Value : word
             read iValue
             write iValue;
    function DownLoadString : AnsiString;
  end;

  tMMPlayList = class( tObjectList )
  protected
    iMaxSize : integer; // max number of entries
    function fGetItem( const index : integer ) : tMMPlayListEntry;
  public
    property Item[ const index : integer ] : tMMPlayListEntry
             read fGetItem;
    constructor Create( pMaxSize : integer );
    function Add( NewVal : tMMplayListEntry ) : integer; reintroduce;
    function DownLoadString : AnsiString;
    function Full : boolean;
  end;

type
  tMPDEList = class;

  tMPDirectoryEntry = class
  protected
    iFileLength : integer;
    iPageNo     : integer;
    iOwner      : tMPDEList;
    iChecksum   : word;
  public
    class function Size : integer;
    constructor Create( pOwner : tMPDEList );
    procedure Load( pEntry : AnsiString );
    function Exists : boolean;
    property FileLength : integer
             read iFileLength
             write iFileLength;
    property PageNo : integer
             read iPageNo
             write iPageNo;
    property CheckSum : word
             read iChecksum
             write iChecksum;
    function DownLoadString : AnsiString;
  end;

  tMPDEList = class( tObjectList )
  protected
    iPageSize : integer;
    function fGetEntry( const index : integer ) : tMPDirectoryEntry;
  public
    constructor Create( pPageSize : integer );
    procedure Load( pEntry : AnsiString );
    property Entry[ const index : integer ] : tMPDirectoryEntry
             read fGetEntry;
//    property Checksum : word
//             read iCS
//             write iCS;
    function DownLoadString : AnsiString;
  end;

type
  tMemoryPage = class
  protected
    iPageIndex : integer;
    iPageSize : integer;
  public
    constructor Create( pPageIndex : integer; pPageSize : integer );
    procedure Load( pVal : AnsiString ); virtual; abstract;
    function DownLoadString : AnsiString; virtual; abstract;
  end;

  tMPDirectory = class( tMemoryPage )
  protected
    iDirectory : tMPDEList;
  public
    procedure Load( pVal : AnsiString ); override;
    constructor Create( pPageIndex : integer; pPageSize : integer );
    destructor Destroy; override;
    property Directory : tMPDEList
             read iDirectory;
    function DownLoadString : AnsiString; override;
  end;

  tMPMMPlayList = class( tMemoryPage )
  protected
    iPlayList : tMMPlayList;
  public
    constructor Create( pPageIndex : integer; pPageSize : integer; pPlaylistSize : integer );
    destructor Destroy; override;
    procedure Load( pVal : AnsiString ); override;
    property PlayList : tMMPlayList
             read iPlayList;
    function DownLoadString : AnsiString; override;
    function Full : boolean;
  end;

  tMPMMMPage = class( tMPMMPlayList )
  protected
    iMessageModificationMatrix : tMMMessageModificationMatrix;
  public
    constructor Create( pPageIndex : integer; pPageSize : integer );
    destructor Destroy; override;
    procedure Load( pVal : AnsiString ); override;
    property MessageModificationMatrix : tMMMessageModificationMatrix
             read iMessageModificationMatrix;
    function DownLoadString : AnsiString; override;
  end;

  tMPData = class( tMemoryPage )
  protected
    iData : AnsiString;
  public
    procedure Load( pVal : AnsiString ); override;
    property Data : AnsiString
             read iData;
    function DataSize : integer;
    function DownLoadString : AnsiString; override;
    procedure LoadBinary( pVal : array of byte; var pSize : integer );
    function Checksum : word;
  end;

  tMemoryMap = class( tObjectList )
  protected
    iPageSize : integer;
    function fGetPage( const pPageNo : integer ) : tMemoryPage;
    function fGetDataPage( const pPageNo : integer ) : tMPData;
    function fGetPlayListPage( const pPageNo : integer ) : tMPMMPlayList;
    function fGetDirectory : tMPDEList;
    function fGetMemoryMatrix : tMMMessageModificationMatrix;
  public
    constructor Create( pPageSize : integer );
    property Page[ const pPageNo : integer ] : tMemoryPage
             read fGetPage;
    property DataPage[ const pPageNo : integer ] : tMPData
             read fGetDataPage;
    property PlayListPage[ const pPageNo : integer ] : tMPMMPlayList
             read fGetPlayListPage;
    procedure Load( pPage : integer; pVal : AnsiString );
    function Add( NewVal : tMemoryPage ) : integer; reintroduce;
    property Directory : tMPDEList
             read fGetDirectory;
    function DataSize( pPage : integer ) : integer;
    property MemoryMatrix : tMMMessageModificationMatrix
             read fGetMemoryMatrix;
    procedure AddPlayListData( NewVal : word );
  end;

implementation

{ tMemoryMap }

function tMemoryMap.Add(NewVal: tMemoryPage): integer;
begin
  Result := inherited Add( NewVal );
end;

procedure tMemoryMap.AddPlayListData(NewVal: word);
var
  i : integer;
  iMMPlayListEntry : tMMPlayListEntry;
begin
  for i := 1 to 3 do
  begin
    if Not PlayListPage[ i ].Full then
    begin
      iMMPlayListEntry := tMMPlayListEntry.Create;
      iMMPlayListEntry.Value := NewVal;
      PlayListPage[ i ].PlayList.Add( iMMPlayListEntry );
      exit;
    end;
  end;
  // if we get here we have run out of room
  raise exception.Create( 'Unsufficient space for play list!' );
end;

constructor tMemoryMap.Create( pPageSize : integer );
begin
  inherited Create( TRUE );
  iPageSize := pPageSize;
  Add( tMPDirectory.Create( 0, pPageSize ));
  Add( tMPMMMPage.Create( 1, pPageSize ));
  Add( tMPMMPlayList.Create( 2, pPageSize, pPageSize div 2 ));
  Add( tMPMMPlayList.Create( 3, pPageSize, pPageSize div 2 ));
end;

function tMemoryMap.DataSize(pPage: integer): integer;
begin
  Result := 0;
  if pPage < Count then
  begin
    if Page[ pPage ] is tMPData then
    begin
      Result := DataPage[ pPage ].DataSize;
    end;
  end;
end;

function tMemoryMap.fGetDataPage(const pPageNo: integer): tMPData;
begin
  Result := Page[ pPageNo ] as tMPData;
end;

function tMemoryMap.fGetDirectory: tMPDEList;
begin
  Result := (Page[ 0 ] as tMPDirectory).Directory;
end;

function tMemoryMap.fGetMemoryMatrix: tMMMessageModificationMatrix;
begin
  Result := ( Page[ 1 ] as tMPMMMPage ).MessageModificationMatrix;
end;

function tMemoryMap.fGetPage(const pPageNo: integer): tMemoryPage;
begin
  Result := Items[ pPageNo ] as tMemoryPage;
end;

function tMemoryMap.fGetPlayListPage(
  const pPageNo: integer): tMPMMPlayList;
begin
  Result := Page[ pPageNo ] as tMPMMPlayList;
end;

procedure tMemoryMap.Load(pPage: integer; pVal: AnsiString);
var
  iNewPage : tMPData;
  i : integer;
begin
  if pPage < Count then
  begin
    Page[ pPage ].Load( pVal );
  end
  else
  begin
    iNewPage := nil;
    for i := Count to pPage do
    begin
      iNewPage := tMPData.Create( i, iPageSize );
      Add( iNewPage );
    end;
    // iNewPage is latest added page
    iNewPage.Load( pVal );
  end;
end;

{ tMemoryPage }

constructor tMemoryPage.Create(pPageIndex, pPageSize: integer);
begin
  inherited Create;
  iPageIndex := pPageIndex;
  iPageSize := pPageSize;
end;

{ tMPDirectory }

constructor tMPDirectory.Create(pPageIndex, pPageSize: integer);
begin
  inherited Create( pPageIndex, pPageSize );
  iDirectory := tMPDEList.Create( pPageSize );
end;

destructor tMPDirectory.Destroy;
begin
  iDirectory.Free;
  inherited;
end;

function tMPDirectory.DownLoadString: AnsiString;
begin
  Result := iDirectory.DownLoadString;
end;

procedure tMPDirectory.Load(pVal: AnsiString);
begin
  inherited;
  iDirectory.Load( pVal );
end;

{ tMPDEList }

constructor tMPDEList.Create(pPageSize: integer);
var
  iEntryCount : integer;
  i : integer;
begin
  inherited Create( TRUE );
  iPageSize := pPageSize;
  iEntryCount := (pPageSize - 2) div tMPDirectoryEntry.Size;
  for i := 1 to iEntryCount do
  begin
    Add( tMPDirectoryEntry.Create( self ) );
  end;
end;

function tMPDEList.DownLoadString: AnsiString;
var
  i : integer;
  iCS : Word;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    Result := Result + Entry[ i ].DownLoadString;
  end;
  for i := 1 + Count * 8 to iPageSize - 2 do
  begin
    Result := Result + AnsiChar( $FF );
  end;
  iCS := 0;
  for i := 1 to Length( Result ) do
  begin
    inc( iCS, Ord( Result[ i ] ));
  end;
  Result := Result + AnsiChar( iCS div 256 ) + AnsiChar( iCS mod 256 );
end;

function tMPDEList.fGetEntry(const index: integer): tMPDirectoryEntry;
begin
  Result := Items[ index ] as tMPDirectoryEntry;
end;

procedure tMPDEList.Load(pEntry: AnsiString);
var
  i : integer;
  iStart, iEnd : integer;
begin
  iStart := 1;
  iEnd := 8;
  for i := 0 to Count - 1 do
  begin
    if iEnd > Length( pEntry ) then exit; // end of string
    // else
    Entry[ i ].Load( Copy( pEntry, iStart, 8 ));
    inc( iStart, 8 );
    inc( iEnd, 8 );
  end
end;

{ tMPDirectoryEntry }

constructor tMPDirectoryEntry.Create(pOwner: tMPDEList);
begin
  inherited Create;
  iOwner := pOwner;
  iFileLength := $FFFFFF;
  iPageNo     := $FFFF;
end;

function tMPDirectoryEntry.DownLoadString: AnsiString;
begin
  Result := AnsiChar ( iFileLength div (256 * 256))
         +  AnsiChar ( (iFileLength mod (256 * 256) ) div 256 )
         +  AnsiChar ( iFileLength mod 256 )
         +  AnsiChar ( iPageNo div 256 )
         +  AnsiChar ( iPageNo mod 256 )
         +  AnsiChar ( iChecksum div 256 )
         +  AnsiChar ( iChecksum mod 256 )
         +  AnsiChar ( $FF ); // spare
end;

function tMPDirectoryEntry.Exists: boolean;
begin
  Result := (iFileLength <> 0) and (iFileLength <> $FFFFFFF )
         and( iPageNo <> 0 ) and ( iPageNo <> $FFFF );
end;

procedure tMPDirectoryEntry.Load(pEntry: AnsiString);
begin
  FileLength := 256 * 256 * Ord( pEntry[ 1 ]) + 256 * Ord( pEntry[ 2 ] ) + Ord( pEntry[ 3 ] );
  PageNo := 256 * Ord( pEntry[ 4 ] ) + Ord( pEntry[ 5 ] );
//  iChecksum := 256 * Ord( pEntry[ 6 ] ) + Ord( pEntry[ 7 ] );
end;

class function tMPDirectoryEntry.Size: integer;
begin
  Result := 8;
end;

{ tMMMessageModificationMatrixEntry }

function tMMMessageModificationMatrixEntry.DownLoadString: AnsiString;
begin
  Result := AnsiChar( iGenericMessageSilence )
         +  AnsiChar( iGenericMessageTest )
         +  AnsiChar( iGenericMessageAlert )
         +  AnsiChar( iGenericMessageEvac )
         +  AnsiChar( iNormaliseMessageSilence )
         +  AnsiChar( iNormaliseMessageTest )
         +  AnsiChar( iNormaliseMessageAlert )
         +  AnsiChar( iNormaliseMessageEvac );
end;

procedure tMMMessageModificationMatrixEntry.Load(pValues: AnsiString);
begin
  iGenericMessageSilence := Ord( pValues[ 1 ] );
  iGenericMessageTest    := Ord( pValues[ 2 ] );
  iGenericMessageAlert   := Ord( pValues[ 3 ] );
  iGenericMessageEvac    := Ord( pValues[ 4 ] );
  iNormaliseMessageSilence := Ord( pValues[ 5 ] );
  iNormaliseMessageTest    := Ord( pValues[ 6 ] );
  iNormaliseMessageAlert   := Ord( pValues[ 7 ] );
  iNormaliseMessageEvac    := Ord( pValues[ 8 ] );
end;

{ tMMMessageModificationMatrix }

constructor tMMMessageModificationMatrix.Create;
var
  i : integer;
begin
  inherited Create;
  for i := 0 to 15 do
  begin
    iEntry[ i ] := tMMMessageModificationMatrixEntry.Create;
  end;
end;

function tMMMessageModificationMatrix.DownLoadString: AnsiString;
var
  i : integer;
begin
  Result := '';
  for i := 0 to 15 do
  begin
    Result := Result + Entry[ i ].DownLoadString;
  end;
end;

function tMMMessageModificationMatrix.fGetEntry(
  const index: integer): tMMMessageModificationMatrixEntry;
begin
  Result := iEntry[ index ];
end;

procedure tMMMessageModificationMatrix.Load(pValues: AnsiString);
var
  i : integer;
begin
  for i := 0 to 15 do
  begin
    iEntry[ i ].Load( Copy( pValues, 8 * i + 1, 8));
  end;
end;

{ tMMPlayListEntry }

function tMMPlayListEntry.fGetParm: word;
begin
  Result := iValue div $10;
end;

procedure tMMPlayListEntry.fSetParm( NewVal : word );
begin
  iValue := $10 * NewVal + Token;
end;

function tMMPlayListEntry.fGetToken: byte;
begin
  Result := iValue mod $10;
end;

procedure tMMPlayListEntry.fSetToken( NewVal : byte );
begin
  iValue := $10 * Parm + NewVal;
end;

procedure tMMPlayListEntry.Load(pValue: AnsiString);
begin
  iValue := 256 * Ord( pValue[ 1 ] ) + Ord( pValue[ 2 ] );
end;

function tMMPlayListEntry.DownLoadString : AnsiString;
begin
  Result := AnsiChar( iValue div 256 ) + AnsiChar ( iValue mod 256 );
end;

{ tMMPlayList }

function tMMPlayList.Add(NewVal: tMMplayListEntry): integer;
begin
  if Full then
  begin
    raise exception.Create( 'Playlist full for this page' );
  end;
  Result := inherited Add( NewVal );
end;

constructor tMMPlayList.Create( pMaxSize : integer );
begin
  inherited Create( TRUE );
  iMaxSize := pMaxSize;
end;

function tMMPlayList.DownLoadString: AnsiString;
var
  i : integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    Result := Result + Item[ i ].DownLoadString;
  end;
end;

function tMMPlayList.fGetItem(const index: integer): tMMPlayListEntry;
begin
  Result := Items[ index ] as tMMPlayListEntry;
end;

function tMMPlayList.Full: boolean;
begin
  Result := Count >= iMaxSize;
end;

{ tMPMMPlayList }

constructor tMPMMPlayList.Create(pPageIndex, pPageSize: integer; pPlaylistSize : integer);
begin
  inherited Create( pPageIndex, pPageSize );
  iPlayList := tMMPlayList.Create( pPlayListSize );
end;

destructor tMPMMPlayList.Destroy;
begin
  iPlayList.Free;
  inherited;
end;

function tMPMMPlayList.DownLoadString: AnsiString;
begin
  Result := iPlayList.DownLoadString;
end;

function tMPMMPlayList.Full: boolean;
begin
  Result := iPlayList.Full;
end;

procedure tMPMMPlayList.Load(pVal: AnsiString);
var
  i : integer;
  iNewVal : tMMPlayListEntry;
begin
  inherited;
  for i := 1 to Length( pVal ) div 2 do
  begin
    iNewVal := tMMPlayListEntry.Create;
    iNewVal.Load( Copy( pVal, (2 * i) - 1, 2));
    iPlayList.Add( iNewVal );
  end;
end;

{ tMPMMMPage }

constructor tMPMMMPage.Create(pPageIndex, pPageSize: integer);
begin
  inherited Create( pPageIndex, pPageSize, (pPageSize - 128 ) div 2 );
  iMessageModificationMatrix := tMMMessageModificationMatrix.Create;
end;

destructor tMPMMMPage.Destroy;
begin
  iMessageModificationMatrix.Free;
  inherited;
end;

function tMPMMMPage.DownLoadString: AnsiString;
begin
  Result := iMessageModificationMatrix.DownLoadString + inherited DownLoadString;
end;

procedure tMPMMMPage.Load(pVal: AnsiString);
begin
  iMessageModificationMatrix.Load( pVal );
  inherited Load( Copy( pVal, 129, Length( pVal )));
end;

{ tMPData }

function tMPData.Checksum: word;
var
  i : integer;
begin
  Result := 0;
  for i := 1 to Length( iData ) do
  begin
    inc( Result, ord( Data[ i ] ));
    Result := Result mod 256;
  end;
end;

function tMPData.DataSize: integer;
begin
  Result := Length( iData );
end;

function tMPData.DownLoadString: AnsiString;
begin
  if DataSize < iPageSize then
  begin
    Result := iData + StringOfChar( #$FF, iPageSize - DataSize );
  end
  else
  begin
    Result := iData;
  end;
end;

procedure tMPData.Load(pVal: AnsiString);
begin
  inherited;
  iData := pVal;
end;

procedure tMPData.LoadBinary(pVal: array of byte; var pSize: integer);
var
  i, iMax : integer;
begin
  if pSize > iPageSize then
  begin
    iMax := iPageSize;
  end
  else
  begin
    iMax := pSize;
  end;
  iData := '';
  for i := 0 to iMax - 1 do
  begin
    iData := iData + AnsiChar( pVal[ i ] );
  end;
  dec( pSize, iMax );
end;

end.
