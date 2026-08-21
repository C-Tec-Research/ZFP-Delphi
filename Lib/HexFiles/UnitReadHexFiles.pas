unit UnitReadHexFiles;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Common;

type
  THexRecordType = ( rtDataRecord, rtEOF, rtExtSeg, rtNotUsed, rtExtLinearAddress, rtStartLinearAddress );

  THexData = array of byte;

  THexLine = class
  private
    fDataCount: byte;
    fAddress: word;
    fRecordType: THexRecordType;
    fData: THexData;
    procedure SetDataCount(const Value: byte);
    function GetChecksum: byte;
    function GetData(const i: integer): byte;
    procedure SetData(const i: integer; const Value: byte);
    function GetText: string;
    procedure SetText(const Value: string);
  public
    property DataCount : byte
             read fDataCount
             write SetDataCount;
    property Address : word
             read fAddress
             write fAddress;
    property RecordType : THexRecordType
             read fRecordType
             write fRecordType;
    property Data[ const i : integer ] : byte     // note - do not use until DataCount is set
             read GetData
             write SetData;
    property Checksum : byte
             read GetChecksum;
    property Text : string
             read GetText
             write SetText;
  end;

  THexLines = class( TObjectList< THexLine > )
  private
    function GetByte(const pAddress: integer): integer;
    function GetMaxAddress: integer;
    function GetMinAddress: integer;
  public
    property ByteAt[ const pAddress : integer ] : integer  // -1 = not found
             read GetByte;
    property MinAddress : integer
             read GetMinAddress;
    property MaxAddress : integer
             read GetMaxAddress;
    function MemStart( const pLine : THexLine ) : integer;
  end;

  THexFile = class( TStrings )
  private
    fHexLines : THexLines;
    fData : array of Byte;
    fMemSize: integer;
    fLineSize: integer;
    fPageSize: integer;
    function GetByte(const pAddress: integer): integer;
    procedure SetMemSize(const Value: integer);
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
  public
    constructor Create(const pMemSize, pPageSize : integer );
    destructor Destroy; override;

    procedure Clear; override;
    procedure ClearMemory;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;

    property ByteAt[ const pAddress : integer ] : integer  // -1 = not found
             read GetByte;
    property MemSize : integer
             read fMemSize
             write SetMemSize;
    property LineSize : integer
             read fLineSize
             write fLineSize;
    property PageSize : integer
             read fPageSize
             write fPageSize;
  end;

type
  EHexExceptionInvalidRecord = class( Exception )

  end;

  EHexExceptionChecksumFail = class( Exception )

  end;

  EHexExceptionUnexpectedRecordType = class( Exception )

  end;

implementation

{ THexLine }

function THexLine.GetChecksum: byte;
var
  i: Integer;
begin
  Result := 1 - fDataCount - Lo( fAddress ) - Hi( fAddress ) - Ord( fRecordType ) ;
  for i := 0 to fDataCount - 1 do
  begin
    dec( Result, fData[ i ] );
  end;
end;

function THexLine.GetData(const i: integer): byte;
begin
  Result := fData[ i ];
end;

function THexLine.GetText: string;
var
  i: Integer;
begin
  Result := ':' + IntToHex( fDataCount, 2 )
         + IntToHex( fAddress, 4 )
         + IntToHex( Ord( fRecordType ), 2 );
  for i := 0 to fDataCount - 1 do
  begin
    Result := Result + IntToHex( Data[ i ], 2 );
  end;
  Result := Result + IntToHex( Checksum, 2 );
end;

procedure THexLine.SetData(const i: integer; const Value: byte);
begin
  fData[ i ] := Value;
end;

procedure THexLine.SetDataCount(const Value: byte);
begin
  fDataCount := Value;
  SetLength( fData, Value );
end;

procedure THexLine.SetText(const Value: string);
var
  i: Integer;
  iCS : byte;
begin
  try
    if Value[ 1 ] <> ':' then
    begin
      raise EHexExceptionInvalidRecord.Create('Invalid Hex Record');
    end;
    DataCount := HexToInt( Copy( Value, 2, 2) );
    Address := HexToInt( Copy( Value, 4, 4) );
    RecordType := THexRecordType( HexToInt( Copy( Value, 6, 2 ) ));
    for i := 0 to DataCount - 1 do
    begin
      Data[ i ] := HexToInt( Copy( Value, 8 + (2 * i), 2));
    end;
    iCS := HexToInt( Copy( Value, 8 + (2 * DataCount ), 2 ));
    if iCS <> Checksum then
    begin
      raise EHexExceptionChecksumFail.Create('Hex Record Checksum Fail');
    end;
  except
    raise EHexExceptionInvalidRecord.Create('Invalid Hex Record');
  end;
end;

{ THexFile }

procedure THexFile.Clear;
begin
  inherited;
  fHexLines.Clear;
end;

procedure THexFile.ClearMemory;
begin
  SetLength( fData, fMemSize );
  // fill with $FF
  FillChar( fData, fMemSize, $FF );
end;

constructor THexFile.Create(const pMemSize, pPageSize : integer );
begin
  inherited Create;

  fHexLines := THexLines.Create( TRUE );
  MemSize := pMemSize;
  PageSize := pPageSize;
end;

procedure THexFile.Delete(Index: Integer);
begin
  inherited;
  fHexLines.Delete( Index );
end;

destructor THexFile.Destroy;
begin
  fHexLines.Free;
  inherited;
end;

function THexFile.Get(Index: Integer): string;
begin
  Result := fHexLines[ Index ].Text;
end;

function THexFile.GetByte(const pAddress: integer): integer;
begin
  Result := fHexLines.ByteAt[ pAddress ];
end;

function THexFile.GetCount: Integer;
begin
  Result := fHexLines.Count;
end;

procedure THexFile.Insert(Index: Integer; const S: string);
var
  iLine : THexLine;
  i, iMemStart : integer;
begin
  inherited;
  iLine := THexLine.Create;
  iLine.Text := S;
  fHexLines.Insert( Index, iLine );
  iMemStart := fHexLines.MemStart( iLine );
  for i := 0 to iLine.DataCount do
  begin
    fData[ iMemStart + i ] := iLine.Data[ i ];
  end;
end;

procedure THexFile.SetMemSize(const Value: integer);
begin
  fMemSize := Value;
  ClearMemory;
end;

{ THexLines }

function THexLines.GetByte(const pAddress: integer): integer;
var
  iExtOffset : integer;
  iHexLine : THexLine;
  i, iMin, iMax: Integer;
begin
  Result := -1;
  iExtOffset := 0;
  for i := 0 to Count - 1 do
  begin
    iHexLine := self[ i ];
    case iHexLine.fRecordType of
      rtDataRecord:
      begin
        iMin := iExtOffset + iHexLine.Address;
        iMax := iMin + iHexLine.DataCount - 1;
        if pAddress >= iMin then
        begin
          if pAddress <= iMax then
          begin
            Result := iHexLine.Data[ pAddress - iMin ];
            exit;
          end;
        end;
      end;
      rtEOF:
      begin
        exit;
      end;
      rtExtSeg:
      begin
        iExtOffset := ((256 * iHexLine.Data[ 0 ]) + iHexLine.Data[ i ]) * 16;
      end;
      rtNotUsed,
      rtExtLinearAddress,
      rtStartLinearAddress: raise EHexExceptionUnexpectedRecordType.Create('Unexpected record type');
    end;
  end;
end;

function THexLines.GetMaxAddress: integer;
var
  iExtOffset : integer;
  iLine : THexLine;
  i, iVal: Integer;
begin
  Result := -1;
  iExtOffset := 0;
  for i := 0 to Count - 1 do
  begin
    iLine := self[ i ];
    case iLine.RecordType of
      rtDataRecord:
      begin
        iVal := iExtOffSet + iLine.Address + iLine.DataCount - 1;
        if iVal > Result then
        begin
          Result := iVal;
        end;
      end;
      rtEOF:
      begin
        exit;
      end;
      rtExtSeg:
      begin
        iExtOffset := ((256 * iLine.Data[ 0 ]) + iLine.Data[ i ]) * 16;
      end;
      rtNotUsed,
      rtExtLinearAddress,
      rtStartLinearAddress: raise EHexExceptionUnexpectedRecordType.Create('Unexpected record type');
    end;
  end;
end;

function THexLines.GetMinAddress: integer;
var
  iExtOffset : integer;
  iLine : THexLine;
  i, iVal: Integer;
begin
  Result := -1;
  iExtOffset := 0;
  for i := 0 to Count - 1 do
  begin
    iLine := self[ i ];
    case iLine.RecordType of
      rtDataRecord:
      begin
        iVal := iExtOffSet + iLine.Address + iLine.DataCount - 1;
        if Result < 0 then
        begin
          Result := iVal;
        end
        else if iVal < Result then
        begin
          Result := iVal;
        end;
      end;
      rtEOF:
      begin
        exit;
      end;
      rtExtSeg:
      begin
        iExtOffset := ((256 * iLine.Data[ 0 ]) + iLine.Data[ i ]) * 16;
      end;
      rtNotUsed,
      rtExtLinearAddress,
      rtStartLinearAddress: raise EHexExceptionUnexpectedRecordType.Create('Unexpected record type');
    end;
  end;
end;

function THexLines.MemStart(const pLine: THexLine): integer;
var
  iExtOffset : integer;
  iHexLine : THexLine;
  i, iMin: Integer;
begin
  Result := -1;
  iExtOffset := 0;
  for i := 0 to Count - 1 do
  begin
    iHexLine := self[ i ];
    case iHexLine.fRecordType of
      rtDataRecord:
      begin
        iMin := iExtOffset + iHexLine.Address;
        if iHexLine = pLine then
        begin
          Result := iMin;
          exit;
        end;
      end;
      rtEOF:
      begin
        exit;
      end;
      rtExtSeg:
      begin
        iExtOffset := ((256 * iHexLine.Data[ 0 ]) + iHexLine.Data[ i ]) * 16;
      end;
      rtNotUsed,
      rtExtLinearAddress,
      rtStartLinearAddress: raise EHexExceptionUnexpectedRecordType.Create('Unexpected record type');
    end;
  end;
end;

end.
