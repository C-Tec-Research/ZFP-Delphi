unit UnitRIFF;

interface

uses
  SysUtils,
  Classes,
  Types,
  Contnrs;

type
  tRIFFName = array[ 1..4 ] of AnsiChar;

type

  tRIFFChunk = class
  protected
    fID : tRIFFName;
    fSize : dword;
    fLoadedSize : dword;

    procedure SetSize( NewVal : dword ); virtual;
  public
    constructor Create( pID : tRIFFName );
    function Load( F : TStream ) : dword; overload; virtual; abstract;
    procedure Save( F : TStream ); overload; virtual; // saves only the headers. MUST be overridden and called from descendat classes
    property Size : dword
             read fSize
             write SetSize;
    property ID : tRIFFName
             read fID;
    procedure Expand( iValue : smallint; var pData : array of smallint;
                       var pIndex : dword; const iMaxSize : dword ); virtual;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; virtual; abstract; // creates a copy of ourselves
    class function CreateRIFF( pID : tRIFFName ) : tRIFFChunk; // class factory
    class function SameRIFF( v1, v2 : tRIFFName ) : boolean;
    class function StdID : tRIFFName; virtual;
  end;

type
  tRIFFChunkList = class( tObjectList )
  protected
    function GetItem( const index : integer ) : tRIFFChunk;
    function GetChunk( const pID : tRIFFName ) : tRIFFChunk;
  public
    function Add( NewVal : tRIFFChunk ) : integer; reintroduce;
    property Item[ const index : integer ] : tRIFFChunk
             read GetItem; default;
    property Chunk[ const pID : tRIFFName ] : tRIFFChunk
             read GetChunk;
  end;

type
  tByteDataRIFFChunk = class( tRIFFChunk )
  protected
    fData : array of byte;
    procedure SetSize( NewVal : dword ); override;
  public
    function Load(  F : TStream ) : dword; overload; override;
    procedure Save( F : TStream ); overload; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
  end;

type
  tShortIntDataRIFFChunk = class( tRIFFChunk )
  protected
    fData : array of shortint;
    procedure SetSize( NewVal : dword ); override;
  public
    function Load(  F : TStream ) : dword; overload; override;
    procedure Save( F : TStream ); overload; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
  end;

type
  tSmallIntDataRIFFChunk = class( tRIFFChunk )
  protected
    fData : array of SmallInt;
    procedure SetSize( NewVal : dword ); override;
  public
    function Load( F : TStream ) : dword; overload; override;
    procedure Save( F : TStream ); overload; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
  end;

type
  tUnknownRIFFChunk = class( tByteDataRIFFChunk )
  protected
  public
  end;

type
  tCompoundRIFFChunk = class( tRIFFChunk )
  protected
    fData : tRIFFChunkList;
    function GetSize : dword; virtual;
    procedure SetSize( NewVal : dword ); override;
    function GetChunk( const pID : tRIFFName ) : tRIFFChunk;
  public
    constructor Create( pID : tRIFFName );
    function Load( F : TStream ) : dword; overload; override;
    procedure Save( F : TStream ); overload; override;
    destructor Destroy; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    property Size : dword
             read GetSize
             write SetSize;
    property Data : tRIFFChunkList
             read fData;
    property Chunk[ const pID : tRIFFName ] : tRIFFChunk
             read GetChunk;
  end;

type
  tRIFFFile = class( tCompoundRIFFChunk )
  protected
    fFileName : string;
    fRIFFType : tRIFFName;
  public
    constructor Create;
    procedure Load; overload;
    function Load( F : TStream ) : dword; overload; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    procedure Save; overload;
    procedure Save( F : TStream ); overload; override;
    property FileName : string
             read fFileName
             write fFileName;
    class function StdID : tRIFFName; override;
  end;

type
  tFmtChunk = class( tRIFFChunk )
  protected
    wFormatTag : word;
    wChannels  : word;
    dwSamplesPerSec : dword;
    dwAvgBytesPerSec : dword;
    wBlockAlign : word;
    wBitsPerSample : word;
    fData : array of byte; // spurious extra data
    procedure SetSize( NewVal : dword ); override;
  public
    constructor Create;
    function Load( F : TStream ) : dword; overload; override;
    procedure Save( F : TStream ); overload; override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    property Size
             read fSize
             write SetSize;
    class function StdID : tRIFFName; override;
  end;

type
  tDataChunk = class( tSmallIntDataRIFFChunk )
  protected
  public
    constructor Create;
    class function StdID : tRIFFName; override;
  end;

type
  tWAVFile = class( tRIFFFile )
  private
    function GetFmtChunk: tFmtChunk;
    function GetPlayTime: double;
  protected
    function GetDataChunk : tDataChunk;
    function GetSize : dword; override;
  public
    constructor Create;
    property DataChunk : tDataChunk
             read GetDataChunk;
    property FmtChunk : tFmtChunk
             read GetFmtChunk;
    property PlayTime : double
             read GetPlayTime;
  end;

(*
type
  tDSMChunk = class( tByteDataRIFFChunk )
  protected
    iUncompressedSize : dword;
    function fCompress( var pData : array of smallint; const pSize : dword;
                        var pIndex : dword; var iError : smallint ) : byte;
  public
    procedure Expand( iValue : smallint; var pData : array of smallint;
                       var pIndex : dword; const iMaxSize : dword ); override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    constructor Create( From : tDataChunk );
    class function StdID : tRIFFName; override;
  end;
*)

type
  tDSMSChunk = class( tSmallIntDataRIFFChunk )
  protected
    iUncompressedSize : dword;
    function fCompress( var pData : array of SmallInt; const pSize : dword;
                        var pIndex : dword ) : SmallInt;
  public
    procedure Expand( iValue : smallint; var pData : array of smallint;
                       var pIndex : dword; const iMaxSize : dword ); override;
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    constructor Create( From : tDataChunk );
    class function StdID : tRIFFName; override;
  end;

type
  tDSMLChunk = class( tByteDataRIFFChunk )
  protected
    iUncompressedSize : dword;
    iBlockSize : dword;
    jData : array of byte; // for temporary work
    procedure fCompress( const pData : array of SmallInt; const pSize : dword;
                         var pIndex : dword );
    function fCompressBlock( const pData : array of SmallInt; const pSize : dword;
                             var pIndex : dword; const pMin : SmallInt;
                             const iDeltaDepth : integer; const iSampleSize : integer;
                             var iIndex : dword ) : boolean;
  public
    procedure ExpandBlock( const BlockNo : dword; var pData : array of smallint; var pIndex : dword; const iMaxSize : dword );
    function Copy( AsType : tRIFFName ) : tRIFFChunk; override;
    constructor Create( From : tDataChunk; pBlockSize : integer );
    destructor Destroy; override;
    class function StdID : tRIFFName; override;
    function CalcSampleSize( nBits, dLevel : dword ) : dword;
  end;


implementation

//const

//  cRIFF : tRIFFName = 'RIFF';

//------------------------ tRIFFChunk ----------------------

constructor tRIFFChunk.Create( pID : tRIFFName);
begin
  inherited Create;
  fID := pID;
end;

procedure tRIFFChunk.Save( F : TStream );
begin
  // saves only the headers. MUST be overridden and called from descendat classes
  F.Write( fID, 4 );
  F.Write( fSize, sizeof( fSize ) );
end;

procedure tRIFFChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  fLoadedSize := 0;
end;

procedure tRIFFChunk.Expand( iValue : smallint; var pData : array of smallint;
                       var pIndex : dword; const iMaxSize : dword );
begin
  // for compressed chunks. Not all chunks are compressible, so by default
  // does nothing
end;

class function tRIFFChunk.CreateRIFF( pID : tRIFFName ) : tRIFFChunk; // class factory
begin
  if SameRIFF( pID, tFmtChunk.StdID ) then
  begin
    Result := tFmtChunk.Create;
  end
  else if SameRIFF( pID, tDataChunk.StdID ) then
  begin
    Result := tDataChunk.Create;
  end
  else
  begin
    result := tUnknownRIFFChunk.Create( pID );
  end;
end;

class function tRIFFChunk.SameRIFF( v1, v2 : tRIFFName ) : boolean;
var
  i : integer;
begin
  Result := TRUE;
  for i := 1 to 4 do
  begin
    if v1[ i ] <> v2[ i ] then
    begin
      Result := FALSE;
      exit;
    end;
  end;
end;

class function tRIFFChunk.StdID : tRIFFName;
begin
  raise exception.Create( 'Attempting to obtain Standard ID of Generic RIFF Chunk' );
end;

//------------------------ tByteDataRIFFChunk ----------------------

procedure tByteDataRIFFChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  SetLength( fData, NewVal );
  fLoadedSize := 0;
end;

function tByteDataRIFFChunk.Load( F : TStream ) : dword;
var
//  fDataSize : dword;
  Dummy : byte;
begin
//  F.Read( fDataSize, sizeof( fDataSize ) );
//  Size := fDataSize;
  F.Read( fData[ 0 ], Size );
  // dummy read if required
  if ( Size mod 2 ) <> 0 then
  F.Read( Dummy, 1 );
  Result := Size + 8;
end;

procedure tByteDataRIFFChunk.Save( F : TStream );
var
  Dummy : byte;
begin
  inherited Save( F );
  F.Write( fData[ 0 ], Size );
  if (Size mod 2 ) <> 0 then
  begin
    // dummy write if required
    Dummy := 0;
    F.Write( Dummy, 1 );
  end;
end;

function tByteDataRIFFChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  // do a byte by byte copy of the data
  Result := CreateRIFF( AsType );
  // make sure a descendant of ourselves. If not, following line will raise an exception
  with Result as tByteDataRIFFChunk do
  begin
    Size := self.Size;
    for i := 0 to Size -1 do
    begin
      fData[ i ] := self.fData[ i ];
    end;
  end;
end;

//------------------------ tShortIntDataRIFFChunk ----------------------

procedure tShortIntDataRIFFChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  SetLength( fData, NewVal );
  fLoadedSize := 0;
end;

function tShortIntDataRIFFChunk.Load( F : TStream ) : dword;
var
  Dummy : byte;
begin
  F.Read( fData[ 0 ], Size );
  // dummy read if required
  if ( Size mod 2 ) <> 0 then
  F.Read( Dummy, 1 );
  Result := Size + 8;
end;

procedure tShortIntDataRIFFChunk.Save( F : TStream );
var
  Dummy : byte;
begin
  inherited Save( F );
  F.Write( fData[ 0 ], Size );
  if (Size mod 2 ) <> 0 then
  begin
    // dummy write if required
    Dummy := 0;
    F.Write( Dummy, 1 );
  end;
end;

function tShortIntDataRIFFChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  // do a byte by byte copy of the data
  Result := CreateRIFF( AsType );
  // make sure a descendant of ourselves. If not, following line will raise an exception
  with Result as tShortIntDataRIFFChunk do
  begin
    Size := self.Size;
    for i := 0 to Size -1 do
    begin
      fData[ i ] := self.fData[ i ];
    end;
  end;
end;

//------------------------ tSmallIntDataRIFFChunk ----------------------

procedure tSmallIntDataRIFFChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  SetLength( fData, NewVal div 2 );
  fLoadedSize := 0;
end;

function tSmallIntDataRIFFChunk.Load( F : TStream ) : dword;
begin
//  F.Read( fDataSize, sizeof( fDataSize ) );
//  Size := fDataSize;
  F.Read( fData[ 0 ], Size );
  // never dummy read required, reading 2 bytes at a time
  Result := Size + 8;
end;

procedure tSmallIntDataRIFFChunk.Save( F : TStream );
begin
  inherited Save( F );
  F.Write( fData[ 0 ], fSize );
    // dummy write never required
end;

function tSmallIntDataRIFFChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  // do a byte by byte copy of the data
  Result := CreateRIFF( AsType );
  // make sure a descendant of ourselves. If not, following line will raise an exception
  with Result as tSmallIntDataRIFFChunk do
  begin
    Size := self.Size;
    for i := 0 to (Size div 2) - 1 do
    begin
      fData[ i ] := self.fData[ i ];
    end;
  end;
end;

//---------------- tCompoundRIFFChunk ----------------------

constructor tCompoundRIFFChunk.Create( pID : tRIFFName );
begin
  inherited Create( pID );
  fData := tRIFFChunkList.Create( TRUE );
end;

destructor tCompoundRIFFChunk.Destroy;
begin
  fData.Free;
  inherited Destroy;
end;

function tCompoundRIFFChunk.GetChunk( const pID : tRIFFName ) : tRIFFChunk;
begin
  Result := fData.Chunk[ pID ];
end;

procedure tCompoundRIFFChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  fLoadedSize := 0;
end;

function tCompoundRIFFChunk.Load( F : TStream ) : dword;
var
  iChunkRiffName : tRIFFName;
  iChild : tRIFFChunk;
  iChildSize : dword;
begin
//  F.Read( fSize, sizeof( fSize );
  while fLoadedSize < fSize do
  begin
    // enforce even byte boundaries
    if fLoadedSize mod 2 = 1 then
    begin
      F.Read( iChunkRiffName, 1 );
      inc (fLoadedSize);
      continue;
    end;
    F.Read( iChunkRiffName, 4 );
    iChild := CreateRIFF( iChunkRiffName );
    fData.Add( iChild );
    F.Read( iChildSize, sizeof( iChildSize) );
    if F.Position + iChildSize > fSize + 8 then
    begin
      raise exception.Create('Load Error reading RIFF file' );
    end;
    // else
    iChild.Size := iChildSize;
    inc( fLoadedSize, iChild.Load( F ));
  end;
  Result := fSize + 8; // 8 byte overhead
end;

procedure tCompoundRIFFChunk.Save( F : TStream );
var
  i : integer;
begin
  inherited Save( F );
  for i := 0 to fData.Count - 1 do
  begin
    fData[ i ].Save( F );
  end;
end;

function tCompoundRIFFChunk.GetSize : dword;
var
  i : integer;
begin
  Result := 0;
  with fData do
  begin
    for i := 0 to Count - 1 do
    begin
      Result := Result + Item[ i ].Size + 8; // each chunk has an 8 byte overhead
    end;
  end;
end;

function tCompoundRIFFChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  Result := CreateRIFF( AsType );
  // make sure a descendant of ourselves. If not, following line will raise an exception
  with Result as tCompoundRIFFChunk do
  begin
    for i := 0 to self.fData.Count - 1 do
    begin
      fData.Add( Self.fData[ i ].Copy( Self.fData[ i ].ID ) );
    end;
  end;
end;

//---------------- tRIFFChunkList ---------------

function tRIFFChunkList.GetItem( const index : integer ) : tRIFFChunk;
begin
  try
    Result := Items[ index ] as tRIFFChunk;
  except
    Result := nil;
  end;
end;

function tRIFFChunkList.GetChunk( const pID : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if tRIFFChunk.SameRIFF( Item[ i ].ID, pID ) then
    begin
      Result := Item[ i ];
      exit;
    end;
  end;
end;

function tRIFFChunkList.Add( NewVal : tRIFFChunk ) : integer;
begin
  Result := inherited Add( NewVal );
end;

//----------------- tRIFFFile --------------------

constructor tRIFFFile.Create;
begin
  inherited Create( StdID );
end;

procedure tRIFFFile.Load;
var
  F : TFileStream;
begin
  F := TFileStream.Create( fFileName, fmOpenRead );
  try
    Load( F );
  finally
    F.Free;
  end;
end;

function tRIFFFile.Load( F : TStream ) : dword;
begin

  F.Position := 0;
  F.Read( fID, 4 );
  if SameRIFF( fID, StdID ) then
  begin
    // we are the RIFF chunk. Load
    F.Read( fSize, sizeof( fSize ) );
    fLoadedSize := 0;
  end
  else
  begin
    raise exception.Create('RIFF chunk not found. Load failed' );
  end;

  F.Read( fRIFFType, sizeof( fRIFFType ) );
  inc( fLoadedSize, sizeof( fRIFFType ) );
  Result := inherited Load( F );
end;

procedure tRIFFFile.Save;
var
  F : TFileStream;
begin
  F := TFileStream.Create( fFileName, fmCreate );
  try
    Save( F );
  finally
    F.Free;
  end;
end;

procedure tRIFFFile.Save( F : TStream );
var
  jSize : dword;
  i : integer;
  iID : tRIFFName;
begin
  jSize := Size;
  iID := tRIFFFile.StdID;
  F.Write( iID, 4 );
  F.Write( jSize, Sizeof( jSize ) );
  F.Write( fRIFFType, sizeof( fRIFFType ) );
  for i := 0 to fData.Count - 1 do
  begin
    fData[ i ].Save( F );
  end;
end;

function tRIFFFile.Copy( AsType : tRIFFName ) : tRIFFChunk;
begin
  Result := inherited Copy( AsType );
  with Result as tRIFFFile do
  begin
    fRIFFType := self.fRIFFType;
  end;
end;

class function tRIFFFile.StdID : tRIFFName;
begin
  Result := 'RIFF';
end;

//----------------- tFmtChunk --------------------

constructor tFmtChunk.Create;
begin
  inherited Create( StdID );
  wFormatTag := 1; // uncompressed data;
  wChannels  := 1; // mono;
  dwSamplesPerSec := 16000; // 16kHz;
  dwAvgBytesPerSec := 32000; // 16 bit per sample
  wBlockAlign := 2; // 1 sample per block
  wBitsPerSample := 16; // 16 bits per sample
  fSize := 16; // no extra data
  SetLength( fData, 0 );
end;

procedure tFmtChunk.SetSize( NewVal : dword );
begin
  fSize := NewVal;
  SetLength( fData, fSize - 16 );
  fLoadedSize := 0;
end;

function tFmtChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i : integer;
begin
  // do a byte by byte copy of the data
  Result := CreateRIFF( AsType );
  // make sure a descendant of ourselves. If not, following line will raise an exception
  with Result as tFmtChunk do
  begin
    Size := self.Size;
    wFormatTag := self.wFormatTag;
    wChannels  := self.wChannels;
    dwSamplesPerSec := self.dwSamplesPerSec;
    dwAvgBytesPerSec := self.dwAvgBytesPerSec;
    wBlockAlign := self.wBlockAlign;
    wBitsPerSample := self.wBitsPerSample; // 16 bits per sample
    for i := 0 to fSize -17 do
    begin
      fData[ i ] := self.fData[ i ];
    end;
  end;
end;


function tFmtChunk.Load( F : TStream ) : dword;
begin
//  F.Read( fDataSize, sizeof( fDataSize ) );
//  Size := fDataSize; // allocates room for extra data if any
  F.Read( wFormatTag, sizeof( wFormatTag ));
  F.Read( wChannels, sizeof( wChannels ));
  F.Read( dwSamplesPerSec, sizeof( dwSamplesPerSec ));
  F.Read( dwAvgBytesPerSec, sizeof( dwAvgBytesPerSec ));
  F.Read( wBlockAlign, sizeof( wBlockAlign ));
  F.Read( wBitsPerSample, sizeof( wBitsPerSample ) );
  // read spare data
  if Size > 16 then
  begin
    F.Read( fData[ 0 ], Size - 16 );
  end;
  Result := Size + 8;
end;

procedure tFmtChunk.Save( F : TStream );
begin
  inherited Save( F );
  F.Write( wFormatTag, sizeof(wFormatTag ));
  F.Write( wChannels, sizeof( wChannels ));
  F.Write( dwSamplesPerSec, sizeof( dwSamplesPerSec ));
  F.Write( dwAvgBytesPerSec, sizeof( dwAvgBytesPerSec ));
  F.Write( wBlockAlign, sizeof( wBlockAlign ));
  F.Write( wBitsPerSample, sizeof( wBitsPerSample ));
  if Size > 16 then
  begin
    F.Write( fData[ 0 ], Size - 16 );
  end;
end;

class function tFmtChunk.StdID : tRIFFName;
begin
  Result := 'fmt ';
end;

//---------------- tDataChunk ------------------

constructor tDataChunk.Create;
begin
  inherited Create( StdID );
end;

class function tDataChunk.StdID : tRIFFName;
begin
  Result := 'data';
end;

//------------------ tDSMSChunk -------------------

constructor tDSMSChunk.Create( From : tDataChunk );
var
  iIndex : dword;
  iCompressedSize : dword;
begin
  inherited Create( StdID );
  // set the size initially to From size. It won't be bigger!
  Size := From.Size;
  iUncompressedSize := fSize;
  iCompressedSize := 0;
  iIndex := 0;
  while iIndex < From.Size do
  begin
    fData[ iCompressedSize ] := fCompress( From.fData, From.Size, iIndex );
    inc( iCompressedSize );
  end;
  Size := 2 * iCompressedSize;
end;

class function tDSMSChunk.StdID : tRIFFName;
begin
  Result := 'DSMS';
end;

procedure tDSMSChunk.Expand( iValue : SmallInt; var pData : array of smallint;
                       var pIndex : dword; const iMaxSize : dword );
var
  i : integer;
  iIndex : dword;
  iSilenceCount : integer;
  jMaxSize : dword;
begin
  iIndex := pIndex div 2;
  jMaxSize := iMaxSize div 2;
  if (iValue <= 3) and (iValue >= - 4) then
  begin
    // a silence block
    iSilenceCount := 1;
    for i := -3 to iValue do // equivalent to -4 to iValue - 1 since i is not used inside the loop
    begin
      iSilenceCount := iSilenceCount * 4;
    end;
    for i := 1 to iSilenceCount do
    begin
      if iIndex >= jMaxSize then
      begin
        raise exception.Create('Size exceeded during expansion');
      end;
      pData[ iIndex ] := 0;
      inc( iIndex );
    end;
  end
  else
  begin
    if iIndex >= jMaxSize then
    begin
      raise exception.Create('Size exceeded during expansion');
    end;
    pData[ iIndex ] := iValue;
    inc( iIndex );
  end;
  pIndex := 2 * iIndex;
end;

function tDSMSChunk.fCompress( var pData : array of smallint; const pSize : dword;
                              var pIndex : dword ) : SmallInt;
var
  iSilenceCount : dword;
  iIsSilence : boolean;
  iSample : smallint;
  iIndex : dword;
  i : integer;
begin
  iSilenceCount := 0;
  iIndex := pIndex div 2;
  while TRUE do
  begin
    iSample := pData[ iIndex ] ;
    iIsSilence := (iSample >= -4 ) and (iSample <= 3);
    if iIsSilence then
    begin
      inc( iSilenceCount );
      inc( iIndex );
    end
    else
    begin
      // done. Silence?
      if iSilenceCount > 0 then
      begin
        // yes, setup count
        iIndex := 2;
        for i := -4 to 3 do
        begin
          Result := i;
          if iSilenceCount < 4 then
          begin
            // done
            break;
          end;
          iSilenceCount := iSilenceCount div 4;
          iIndex := iIndex * 4;
        end;
        // move pointer
        pIndex := pIndex + iIndex;
        exit;
      end
      else
      begin
        // no, just store this sample
        Result := iSample;
        inc( pIndex, 2 );
        exit;
      end;
    end;
  end;
end;

function tDSMSChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  i, iIndex : dWord;
begin
  // we can copy ourselves either as a DSMS chunk or a data chunk
  // If copying as a data chunk, we expand ourelves
  if SameRIFF( AsType, StdID ) then
  begin
    // just straight copy, so can use inherited
    Result := inherited Copy( AsType );
  end
  else if SameRIFF( AsType, tDataChunk.StdID ) then
  begin
    Result := CreateRIFF( AsType );
    with Result as tDataChunk do
    begin
      Size := self.iUncompressedSize;
      iIndex := 0;
      for i := 0 to (self.Size div 2) - 1 do
      begin
        self.Expand( self.fData[ i ], fData, iIndex, Size );
      end;
      if iIndex <> Size then
      begin
        raise Exception.Create( 'Unexpected Size in decompression' );
      end;
    end;
  end
  else
  begin
    raise exception.Create( 'cannot copy type "' + StdID + '" to type "' + AsType + '".');
  end;
end;

//----------------  tWAVFile ----------------

constructor tWAVFile.Create;
begin
  inherited Create;
  fRIFFType := 'WAVE';
end;

function tWAVFile.GetDataChunk : tDataChunk;
begin
  Result := Chunk[ tDataChunk.StdID ] as tDataChunk;
end;

function tWAVFile.GetFmtChunk: tFmtChunk;
begin
  Result := Chunk[ tFmtChunk.StdID ] as tFmtChunk;
end;

function tWAVFile.GetPlayTime: double;
var
  iDataChunk : tDataChunk;
  iFmtChunk : tFmtChunk;
begin
  // calculates average play time
  Result := 0.0;
  iDataChunk := DataChunk;
  iFmtChunk := FmtChunk;
  if assigned( iDataChunk ) and assigned( iFmtChunk ) and (iFmtChunk.dwAvgBytesPerSec <> 0 ) then
  begin
    Result := iDataChunk.Size / iFmtChunk.dwAvgBytesPerSec;
  end;
end;

function tWAVFile.GetSize : dword;
begin
  Result := inherited GetSize + 4; // for 'WAVE' identifier etc
end;

//----------------------------- tDSMLChunk -------------------------

constructor tDSMLChunk.Create( From : tDataChunk; pBlockSize : integer );
var
  iIndex : dword;
begin
  inherited Create( StdID );

  iBlocksize := pBlockSize;
  iUncompressedSize := From.Size;
  SetLength( jData, iBlockSize );

  iIndex := 0;
  fCompress( From.fData, From.Size, iIndex );
end;

destructor tDSMLChunk.Destroy;
begin
  inherited Destroy;
end;

function tDSMLChunk.fCompressBlock( const pData : array of SmallInt; const pSize : dword;
                             var pIndex : dword; const pMin : SmallInt;
                             const iDeltaDepth : integer; const iSampleSize : integer;
                             var iIndex : dword ) : boolean;

var
  pMax : SmallInt;
  iCalc : array [ 0..2040 ] of integer;
//  iIndex : dword;
  iTemp : word;
  icData1, icData2 : dword;
  icOffset : integer;
  i, j : dword;
  iSampleCount : integer;
begin
  pMax := not pMin;
  iIndex := 0;
  iSampleCount := CalcSampleSize( iSampleSize, iDeltaDepth );
  if iSampleSize = 0 then
  begin
    // uncompressed
    jData[ iIndex ] := 0;
    inc( iIndex );
    for i := 1 to (iBlockSize div 2) - 1 do
    begin
      if pIndex >= (pSize div 2) then break;
      iTemp := word( pData[ pIndex ] );
      jData[ iIndex ] := iTemp mod 256;
      inc( iIndex );
      jData[ iIndex ] := iTemp div 256;
      inc( iIndex );
      inc( pIndex );
    end;
    // set pad byte to zero
    if pIndex < (pSize div 2) then
    begin
      jData[ iIndex ] := 0;
      inc( iIndex );
    end;
    Result := TRUE;
    exit;
  end
  else
  begin
//    SetLength( iCalc, iSampleCount );
    // copy array
    for i := 0 to iSampleCount - 1 do
    begin
      if (pIndex + i) < (pSize div 2) then
      begin
        iCalc[ i ] := pData[ pIndex + i ];
      end
      else
      begin
        iCalc[ i ] := 0; // pad with silence
      end;
    end;
    // calc differences
    for i := 1 to iDeltaDepth do
    begin
      for j := iSampleCount - 1 downto i do
      begin
        iCalc[ j ] := iCalc[ j ] - iCalc[ j - 1 ];
      end;
    end;
    // check sizes
    for i := iDeltaDepth to iSampleCount - 1 do
    begin
      if (iCalc[ i ] < pMin) or (iCalc[ i ] > pMax ) then
      begin
        Result := FALSE;
        exit;
      end;
    end;
    // first store sample size and delta depth
    jData[ iIndex ] := 16 * iSampleSize + iDeltaDepth;
    inc( iIndex );
    // next copy deltadepth samples
    for j := 0 to iDeltaDepth - 1 do
    begin
      // these samples are uncompressed
      iTemp := word( iCalc[ j ] );
      jData[ iIndex ] := iTemp mod 256;
      inc( iIndex );
      jData[ iIndex ] := iTemp div 256;
      inc( iIndex );
    end;
    icData2 := 0;
    icOffset := 0;
    // now compress remaining samples
    for i := iDeltaDepth to iSampleCount - 1 do
    begin
      if pIndex >= pSize then // done
      begin
        // now need to send remaining bits, if any
        while icOffset > 0 do
        begin
          jData[ iIndex ] := byte( icData2 shr 24 );
          inc( iIndex );
          dec( icOffset, 8 );
          icData2 := icData2 shl 8;
        end;
        Result := TRUE;
        exit;
      end;

      // we now now need to move the bits into appropriate locations of icData1, icData2 before
      // transferring to jData
      iTemp := word( iCalc[ i ] );
      iTemp := iTemp shl (15 - iSampleSize );
      icData1 := iTemp;
      icData1 := icData1 shl 16;
      icData2 := icData2 or (icData1 shr icOffset );
      inc( icOffset, iSampleSize );
      // ready to transfer byte?
      while icOffSet > 7 do // we have at least one byte available
      begin
        jData[ iIndex ] := byte( icData2 shr 24 );
        inc( iIndex );
        icData2 := icData2 shl 8;
        dec( icOffset, 8 );
      end;
    end;
    // now need to send remaining bits, if any
    while icOffset > 0 do
    begin
      jData[ iIndex ] := byte( icData2 shr 24 );
      inc( iIndex );
      icData2 := icData2 shl 8;
      dec( icOffset, 8 );
    end;
    // now move to next boundry, padding with zeros if necessay
    // unless we are at end
    if pIndex < (pSize div 2) then
    begin
      while iIndex <> iBlockSize do
      begin
        jData[ iIndex ] := 0;
        inc( iIndex );
      end;
    end;
    inc( pIndex, iSampleCount );
    Result := TRUE;
  end;
end;

(*
function tDSMLChunk.fCompressBlock( const pData : array of SmallInt; const pSize : dword;
                             var pIndex : dword; const pMin : SmallInt;
                             const iDeltaDepth : integer; const iSampleSize : integer ) : boolean;

var
  pMax : SmallInt;
  iDiff : array [-1..15] of integer;
  iIndex : dword;
  iTemp : word;
  icData1, icData2 : dword;
  icOffset : integer;
  i, j : integer;
  iSampleCount : integer;
begin
  pMax := not pMin;
  iIndex := 0;
  iSampleCount := CalcSampleSize( iSampleSize, iDeltaDepth );
  if iSampleSize = 0 then
  begin
    // uncompressed
    jData[ iIndex ] := 0;
    inc( iIndex );
    for i := 0 to (iBlockSize div 2) - 1 do
    begin
      iTemp := word( pData[ pIndex ] );
      fData[ iIndex ] := iTemp mod 256;
      inc( iIndex );
      fData[ iIndex ] := iTemp div 256;
      inc( iIndex );
      inc( pIndex );
    end;
    // set pad byte to zero
    jData[ iIndex ] := 0;
    Result := TRUE;
    exit;
  end
  else
  begin
    // first store sample size and delta depth
    jData[ iIndex ] := 16 * iSampleSize + iDeltaDepth;
    inc( iIndex );
    // next copy deltadepth samples
    iDiff[ -1 ] := 0;
    for j := 0 to iDeltaDepth do
    begin
      if pIndex < (pSize div 2) then
      begin
        iDiff[ j ] := pData[ pIndex ]- iDiff[ j - 1 ];
        inc( pIndex );
      end
      else
      begin
        iDiff[ j ] := 0;
      end;
    end;
    icData2 := 0;
    icOffset := 0;
    // now let samples bubble to top
    for i := 1 to iSampleCount do
    begin
      if pIndex >= pSize then // done
      begin
        // now need to send remaining bits, if any
        if icOffset > 0 then
        begin
          jData[ iIndex ] := byte( icData2 shr 24 );
        end;
        Result := TRUE;
        exit;
      end;

      if i <= iDeltaDepth then
      begin
        // these samples are uncompressed
        iTemp := word( iDiff[ 0 ] );
        jData[ iIndex ] := iTemp mod 256;
        inc( iIndex );
        fData[ iIndex ] := iTemp div 256;
        inc( iIndex );
      end
      else
      begin
        // we now now need to move the bits into appropriate locations of icData1, icData2 before
        // transferring to jData
        if (iDiff[ 0 ] < pMin) or (iDiff[ 0 ] > pMax) then
        begin
          Result := FALSE;
          exit;
        end;
        iTemp := word( iDiff[ 0 ] );
        iTemp := iTemp shl (15 - iSampleSize );
        icData1 := iTemp;
        icData1 := icData1 shl 16;
        icData2 := icData2 or (icData1 shr icOffset );
        inc( icOffset, iSampleSize );
        // ready to transfer byte?
        while icOffSet > 7 do // we have at least one byte available
        begin
          jData[ iIndex ] := byte( icData2 shr 24 );
          inc( iIndex );
          icData2 := icData2 shl 8;
          dec( icOffset, 8 );
        end;
      end;
      for j := 0 to iDeltaDepth - 1 do
      begin
        iDiff[ j ] := iDiff[ j + 1 ] - iDiff[ j ];
      end;
      if i < iSampleCount - iDeltaDepth then
      begin
        iDiff[ iDeltaDepth ] := pData[ pIndex ] - iDiff[ iDeltaDepth ];
        inc( pIndex );
      end
      else
      begin
        iDiff[ iDeltaDepth ] := 0; // last few samples. Don't overincrement pIndex
      end;
    end;
    // now need to send remaining bits, if any
    if icOffset > 0 then
    begin
      jData[ iIndex ] := byte( icData2 shr 24 );
      inc( iIndex );
    end;
    // now move to next boundry, padding with zeros if necessay
    while iIndex mod iBlockSize <> 0 do
    begin
      jData[ iIndex ] := 0;
      inc( iIndex );
    end;
    Result := TRUE;
  end;
end;
*)

procedure tDSMLChunk.fCompress( const pData : array of SmallInt; const pSize : dword;
                        var pIndex : dword );
var
  iBlockCount : dword;
  iMin : integer;
  iSampleSize : integer;
  iDeltaDepth : integer;
  i : integer;
  iIndex : integer;
  jIndex : dword;
  iBlockDone : boolean;
  iUsedCount : dword;
begin
  // max number of blocks is Size/127 rounded up
  iBlockCount := (pSize + iBlocksize - 2) div (iBlockSize - 1);
  SetLength( fData, pSize + iBlockCount ); // even all uncompressed would only come to this
  iIndex := 0;
  while pIndex < (pSize div 2) do
  begin
    // it is always better to increase delta depth rather than sample size for density
    iMin := -1;
    for iSampleSize := 1 to 16 do
    begin
      for iDeltaDepth := 0 to 7 do // values > 7 slow decode time and may not produce compression
      begin
        jIndex := pIndex;
        iBlockDone := fCompressBlock( pData, pSize, jIndex, iMin, iDeltaDepth,
                                      iSampleSize mod 16, iUsedCount );
        if iBlockDone then
        begin
          // success
          for i := 0 to iUsedCount - 1 do
          begin
            fData[ iIndex ] := jData[ i ];
            inc( iIndex );
          end;
          pIndex := jIndex;
          break;
        end;
      end;
      if iBlockDone then
      begin
        // done
        break;
      end
      else
      begin
        iMin := 2 * iMin;
        // try next
      end;
    end;
  end;
  fSize := iIndex;
end;

function tDSMLChunk.CalcSampleSize( nBits, dLevel : dword ) : dword;
begin
  if nBits = 0 then
  begin
    Result := (iBlockSize div 2) - 1;
  end
  else
  begin
    Result := (((iBlockSize - 1 - (2 * dLevel)) * 8 ) div nBits) + dLevel;
  end;
end;

procedure tDSMLChunk.ExpandBlock( const BlockNo : dword; var pData : array of smallint; var pIndex : dword; const iMaxSize : dword );
var
  iSampleSize : integer;
  iDeltaDepth : integer;
  i, j : integer;
  iIndex : dword;
  iDiff : array [0..7] of integer;
  iTemp : word;
  icData1 : dword;
  icData2 : longint;
  icOffset : integer;
  iTemp2 : ShortInt;
  iBase : dword;
begin
  iIndex := iBlockSize * BlockNo; //
  iBase := iIndex;
  // get sample size and DeltaDepth
  iSampleSize := fData[ iIndex ] div 16;
  iDeltaDepth := fData[ iIndex ] mod 16;
  inc( iIndex );
  // load the samples
  if iSampleSize = 0 then
  begin
    // uncompressed
    for i := 1 to (iBlockSize - 2) div 2 do
    begin
      iTemp := fData[ iIndex ] + 256 * fData[ iIndex + 1 ];
      inc( iIndex, 2 );
      pData[ pIndex ] := SmallInt( iTemp );
      inc( pIndex );
    end;
  end
  else
  begin
    // load initial differences
    for i := 0 to iDeltaDepth - 1 do
    begin
      iTemp := fData[ iIndex ] + 256 * fData[ iIndex + 1 ];
      inc( iIndex, 2 );
      iTemp2 := ShortInt( iTemp );
      iDiff[ i ] := iTemp2;
    end;
    // load 1st 4 compressed bytes
    icData1 := 0;
    icOffset := 0;
    for i := 1 to 4 do
    begin
      icData1 := icData1 shl 8;
      if iIndex < fSize then
      begin
        icData1 := icData1 + fData[ iIndex ];
        inc( iIndex );
      end;
    end;
    for i := 1 to CalcSampleSize( iSampleSize, iDeltaDepth) do
    begin
      // calculate iDiff[ iDeltaDepth ]
      icData2 := icData1;
      iDiff[ iDeltaDepth ] := icData2 div ( 1 shl (31 - iSampleSize) );
      for j := 1 to iSampleSize do
      begin
        icData1 := icData1 shl 1;
        inc( icOffset );
        // room for next byte or bytes ?
        if icOffset = 8 then
        begin
          if (iIndex < fSize) and (iIndex < (iBase + iBlockSize)) then
          begin
            icData1 := icData1 + fData[ iIndex ];
            inc( iIndex );
            icOffset := 0;
          end;
        end;
      end;
      // load the data, and calculate next
      pData[ pIndex ] := iDiff[ 0 ];
      inc( pIndex );
      if pIndex > (iMaxSize div 2 ) then
      begin
        if iIndex >= fSize then
        begin
          // done
          exit
        end
        else
        begin
//          raise exception.Create( 'Error - Size exceeded' );
          exit;
        end;
      end;
      for j := 0 to iDeltaDepth - 1 do
      begin
        iDiff[ j ] := iDiff[ j ] + iDiff[ j + 1 ];
      end;
    end;
  end;
end;

function tDSMLChunk.Copy( AsType : tRIFFName ) : tRIFFChunk;
var
  iIndex : dword;
  i : integer;
begin
  // we can copy ourselves either as a DSMS chunk or a data chunk
  // If copying as a data chunk, we expand ourelves
  if SameRIFF( AsType, StdID ) then
  begin
    // just straight copy, so can use inherited
    Result := inherited Copy( AsType );
  end
  else if SameRIFF( AsType, tDataChunk.StdID ) then
  begin
    Result := CreateRIFF( AsType );
    with Result as tDataChunk do
    begin
      Size := self.iUncompressedSize;
      iIndex := 0;
      for i := 0 to (self.Size div iBlocksize) do
      begin
        self.ExpandBlock( i, fData, iIndex, Size );
      end;
      if iIndex <> Size then
      begin
//        raise Exception.Create( 'Unexpected Size in expansion - ' + IntToStr( iIndex ) + ' bytes.' );
      end;
    end;
  end
  else
  begin
    raise exception.Create( 'cannot copy type "' + StdID + '" to type "' + AsType + '".');
  end;
end;

class function tDSMLChunk.StdID : tRIFFName;
begin
  Result := 'DSML';
end;

end.
