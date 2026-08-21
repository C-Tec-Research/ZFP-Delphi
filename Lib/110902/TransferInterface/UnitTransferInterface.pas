unit UnitTransferInterface;

{
  This handles a specialised interface where a record is exchanged
  with the following format
  header (<SOH>, <ACK> <NAK> or <ENQ> )
  [RecType] 1 byte
  [Datasize] one or more bytes big endian, excludes checksum etc
  Data
  [Checksum] one or more bytes.
  This is a separate layer to the underlying transfer mechanism, which
  could be serial, USB, etc.
  Words and DWords are Big-Andian
}

interface

uses
  Windows,
  SysUtils,
  Common,
  Math;

type
  tRecordClass = ( rcENQ = 5, rcSOH = 1, rcSTX = 2, rcACK = 6, rcNAK = 21 );

type
  ArrByte = array of byte;

type
  tReadResult = ( rrHeaderIncomplete, rrTransferIncomplete, rrOK, rrChecksumFail );

type
  tSpecialEntry = ( seNone, seByte, seRecSize, seBreak, seLost, seCS );

type
  tTransferInterface = class
  private
    fDataReady: boolean;
    fCheckSum : DWord;
    fDataSizeDigits: DWord;
    fChecksumDigits: DWord;
    fWriteRecPos : DWord;
    fReadRecPos : DWord;
    fWriteDataSize: DWord;
    fReadChecksum : DWord;
    fWriteBufferOverflow: boolean;
    function GetWriteBufferLen: DWord;
    procedure SetWriteBufferLen(const Value: DWord);
    function GetReadBufferLen: DWord;
    procedure SetReadBufferLen(const Value: DWord);
    procedure SetWriteRecPos(const Value: DWord);
    function GetHeaderSize: DWord;
    function GetReceiveData(const i : integer): byte;
    property WriteRecPos : DWord
             read fWriteRecPos
             write SetWriteRecPos;
  public
    TempReadBuffer : array of byte;     // Use to transfer data if interface requires a temporary buffer
    ReadBuffer : array of byte;     // Do not change directly - use as read only values
    WriteBuffer : array of byte;    // Do not change directly - use as read only values
    constructor Create( pDataSizeDigits : integer = 2; pChecksumDigits : integer = -1 );
    property DataReady : boolean
             read fDataReady;
    property WriteBufferLen : DWord
             read GetWriteBufferLen
             write SetWriteBufferLen;
    property ReadBufferLen : DWord
             read GetReadBufferLen
             write SetReadBufferLen;
    procedure StartRec( RecordClass : tRecordClass; RecType : Byte );
    procedure AddByte( const pValue : byte );
    procedure AddBytes( pValue : array of byte; pLen : byte = 0 );
    function EndRec : DWord;  // gives size of data to transfer
    property WriteRecLen : DWord  // includes SOH and CS. Only valid after EndRec
             read fWriteRecPos;
    property WriteDataSize : DWord
             read fWriteDataSize; // only valid after EndRec
    property HeaderSize : DWord
             read GetHeaderSize;
    function ReadDataSize : DWord; // only valid after header is completely read
    function ReadBufferChecksum : DWord; // only valid after complete record read.
    property ReadChecksum : DWord
             read fReadChecksum; // only valid after complete record read.
    function ReceiveRecClass : tRecordClass;
    function ReceiveRecClassValid : boolean;
    function ReceiveRecType : byte;
    function StartRead : DWord; // initialise buffers reaturns Header size in case needed for first read
    function ReceiveRead( const pCount : DWord; var BytesLeft : dWord ) : tReadResult; overload; // transfer next pCount bytes from TempBuffer
    function ReceiveRead( const pByte : byte ) : tReadResult; overload; // transfer single byte
    function EndRead : tReadResult; virtual;
    function ReceiveDataAsString : string;
    property ReceiveData[ const i : integer ] : byte   // starts after record type. RecordType = 0, true data = 1
             read GetReceiveData;
    procedure Interpret( const pString : string; var pSize : DWord); // for putting duff data into write buffer.
    function AddStandardWrapper( const pString : string ) : string; // to prepare string for Interpret
    function StripWrapper( const pString : string ) : string;
    procedure FindSpecialEntry( const pString : string; var pType : tSpecialEntry;
              var pStartPos : integer; var pLength : integer; var pExtra : integer; var pExtra2 : integer );
    function ReplaceString( const pInString : string; const pStartPos : integer;
                            const pLength : integer; const pByString : string ) : string;
  // published
    property DataSizeDigits : DWord
             read fDataSizeDigits
             write fDataSizeDigits
             default 2;
    property ChecksumDigits : DWord
             read fChecksumDigits
             write fChecksumDigits
             default 2;
    function ReadChecksumOK : boolean;
    property WriteBufferOverflow : boolean
             read fWriteBufferOverflow
             write fWriteBufferOverflow;
  end;

const
  cEOT : byte = $04;

implementation

{ tTransferInterface }

procedure tTransferInterface.AddByte( const pValue: byte);
begin
  if not WriteBufferOverflow then
  begin
    WriteBuffer[ WriteRecPos ] := pValue;
    WriteRecPos := WriteRecPos + 1;
    inc( fChecksum, pValue );
  end;
end;

procedure tTransferInterface.AddBytes(pValue: array of byte; pLen: byte);
var
  i: Integer;
begin
  if pLen = 0 then
  begin
    pLen := Length( pValue );
  end;
  for i := 0 to pLen - 1 do
  begin
    AddByte( pValue[ i ] );
  end;
end;

function tTransferInterface.AddStandardWrapper(const pString : string): string;
begin
  Result := '<SOH><01><REC SIZE>' + pString + '<CS><EOT>';
end;

constructor tTransferInterface.Create( pDataSizeDigits : integer = 2; pChecksumDigits : integer = -1 ); //(pDeviceName: string; pUSBBulkTransfer : tUSBBulkTransfer );
begin
  inherited Create;
  fDataSizeDigits := pDataSizeDigits;
  if pChecksumDigits < 0 then
  begin
    fChecksumDigits := pDataSizeDigits;
  end
  else
  begin
    fChecksumDigits := pChecksumDigits;
  end;
  WriteBufferLen := 2048;
  ReadBufferLen := 2048;
  //fUSBBulkTransfer := pUSBBulkTransfer;
end;

function tTransferInterface.EndRead: tReadResult;
var
  i: Integer;
begin
  fReadChecksum := 0;
  for i := 0 to HeaderSize + ReadDataSize - 1 do
  begin
    inc( fReadCheckSum, ReadBuffer[ i ] );
  end;
  if ReadChecksumOK then
  begin
    Result := rrOK;
  end
  else
  begin
    Result := rrChecksumFail;
    exit;
  end;
end;

function tTransferInterface.EndRec : DWord;
var
  iPos : integer;
  iVal : byte;
  i : integer;
  iDataLen : integer;
  iChecksum : integer;
begin
  // Write the length byte(s)
  iPos := 1 + DataSizeDigits;
  iDataLen := fWriteRecPos - 2 - DataSizeDigits;
  fWriteDataSize := iDataLen; // save in case needed by main program
  for i := 1 to DataSizeDigits do
  begin
    iVal := iDataLen mod 256;
    WriteBuffer[ iPos ] := iVal;
    inc( fChecksum, iVal );
    dec( iPos );
    iDataLen := iDataLen div 256;
  end;
  if iDataLen <> 0 then
  begin
    raise exception.Create( 'USB Data record too big for record format' );
  end;
  // else append the checksum.
  iChecksum := fChecksum; // don't let it modify itself!
  iPos := WriteRecPos + ChecksumDigits;
  for i := 1 to ChecksumDigits do
  begin
    dec( iPos );
    iVal := iChecksum mod 256;
    WriteBuffer[ iPos ] := iVal;
    iCheckSum := iChecksum div 256;
    WriteRecPos := WriteRecPos + 1;
  end;
  AddByte( cEOT );
  Result := WriteRecPos;
end;

procedure tTransferInterface.FindSpecialEntry(const pString: string;
  var pType: tSpecialEntry; var pStartPos, pLength: integer; var pExtra : integer; var pExtra2 : integer);
var
  iPosL, iPosR, iPosP : integer;
  iTempString, iTestString : string;
const
  cRecSize = 'REC SIZE';
  cCS = 'CS';
  cLOST = 'LOST';
begin
  pType := seNone;
  iTempString := pString;
  pStartPos := 0;
  pLength := 0;
  pExtra := 0;
  pExtra2 := 0;
  repeat
    iPosL := Pos( '<', iTempString );
    if iPosL = 0 then
    begin
      exit;
    end;
    inc( pStartPos, iPosL );
    iTempString := Copy( iTempString, iPosL + 1, Length( iTempString ));
    iPosR := Pos( '>', iTempString );
    if iPosR = 0 then
    begin
      // unbalanced
      exit;
    end;
    pLength := iPosR + 1;
    iTestString := Copy( iTempString, 1, iPosR - 1 );
    if SameText( iTestString, 'SOH' ) then
    begin
      pType := seByte;
      pExtra := Ord( rcSOH );
      exit;
    end;
    if SameText( iTestString, 'ENQ') then
    begin
      pType := seByte;
      pExtra := Ord( rcENQ );
      exit;
    end;
    if SameText( iTestString, 'ACK') then
    begin
      pType := seByte;
      pExtra := Ord( rcACK );
      exit;
    end;
    if SameText( iTestString, 'NAK') then
    begin
      pType := seByte;
      pExtra := Ord( rcNAK );
      exit;
    end;
    if SameText( iTestString, 'EOT') then
    begin
      pType := seByte;
      pExtra := 4; // EOT
      exit;
    end;
    if SameText( iTestString, 'BREAK') then
    begin
      pType := seBreak;
      pExtra := iPosL;
      exit;
    end;
    if SameText( iTestString, 'RBREAK') then
    begin
      pType := seBreak;
      pExtra := 1 + Floor( Random( iPosL ));
      exit;
    end;
    if Length( iTestString ) = 2 then
    begin
      if IsHex( iTestString ) then
      begin
        pType := seByte;
        pExtra := HexToInt( iTestString ); // <xx>
        exit;
      end;
    end;
    if SameText( Copy( iTestString, 1, Length( cRecSize)), cRecSize) then
    begin
      pType := seRecSize;
      iTestString := Copy( iTestString, Length( cRecSize ) + 1, Length( iTestString ));
      if Trim( iTestString ) = '' then
      begin
        pExtra := DataSizeDigits;
      end
      else
      begin
        pExtra := StrToInt( iTestString );
      end;
      exit;
    end;
    if SameText( Copy( iTestString, 1, Length( cLOST)), cLOST) then
    begin
      pType := seLOST;
      iTestString := Copy( iTestString, Length( cLOST ) + 1, Length( iTestString ));
      if Trim( iTestString ) = '' then
      begin
        pExtra := 1;
      end
      else
      begin
        pExtra := StrToInt( iTestString );
      end;
      exit;
    end;
    if SameText( Copy( iTestString, 1, Length( cCS)), cCS) then
    begin
      pType := seCS;
      iTempString := Copy( iTestString, Length( cCS ) + 1, Length( iTestString ));
      iPosP := Pos( '+', iTempString );
      if iPosP > 0 then
      begin
        iTestString := Copy( iTempString, iPosP + 1, Length( iTempString ));
        iTempString := Copy( iTempString, 1, iPosP - 1 );
        pExtra2 := StrToInt( iTestString );
        iTempString := iTestString;
      end;
      if Trim( iTempString ) = '' then
      begin
        pExtra := ChecksumDigits;
      end
      else
      begin
        pExtra := StrToInt( iTempString );
      end;
      exit;
    end;
  until FALSE;
end;

function tTransferInterface.GetHeaderSize: DWord;
begin
  Result := 2 + DataSizeDigits;
end;

function tTransferInterface.GetReadBufferLen: DWord;
begin
  Result := Length( ReadBuffer )
end;

function tTransferInterface.GetReceiveData(const i : integer): byte;
begin
  Result := ReadBuffer[ HeaderSize + i ];
end;

function tTransferInterface.GetWriteBufferLen: DWord;
begin
  Result := Length( WriteBuffer )
end;

procedure tTransferInterface.Interpret(const pString : string; var pSize : DWord);
var
  i, iPos : integer;
  iString : string;
  pType : tSpecialEntry;
  pStartPos, pLength, pExtra, pExtra2 : integer;
  pRecSizePos, pCSPos, pBreakPos : integer;
  pRecSize, pCSSize, pCSError : integer;
  pLostCount : integer;
  iCS : integer;
  iRecSize : integer;
  iByte : byte;
begin
  pSize := 0;
  pRecSizePos := 0;
  iString := pString;
  pBreakPos := 0;
  pLostCount := 0;
  pCSPos := 0;
  pCSSize := 0;
  pCSError := 0;
  pRecSize := 0;
  while True do
  begin
    FindSpecialEntry( iString, pType, pStartPos, pLength, pExtra, pExtra2 );
    case pType of
      seNone:
      begin
        // Done. copy to write buffer and set pSize
        pSize := Length( iString );
        iCS := pCSError;
        if pCSPos = 0 then
        begin
          // assume rec size is whole rest of field
          iRecSize := pSize - pRecSizePos - pRecSize;
        end
        else
        begin
          iRecSize := pCSPos - pRecSizePos - pRecSize;
        end;
        inc( iRecSize, pLostCount );
        // basic copy
        for i := 0 to pSize - 1 do
        begin
          iByte := byte( iString[ i + 1 ] );
          WriteBuffer[ i ] := iByte;
          if i < pCSPos then
          begin
            inc( iCS, iByte );  // if pCSPos = 0, never adds, but this is OK because nowhere to put result anyway
          end;
        end;
        if pRecSizePos <> 0 then
        begin
          iPos := pRecSizePos + pRecSize - 2; // 1 for count and one for zero offset
          for i := iPos downto pRecSizePos - 1 do
          begin
            iByte := iRecSize mod 256;
            WriteBuffer[ i ] := iByte;
            if i < pCSPos then
            begin
              inc( iCS, iByte );  // if pCSPos = 0, never adds, but this is OK because nowhere to put result anyway
            end;
            iRecSize := iRecSize div 256;
          end;
        end;
        if pCSPos <> 0 then
        begin
          iPos := pCSPos + pCSSize - 2; // 1 for count and one for zero offset
          for i := iPos downto pCSPos - 1 do
          begin
            iByte := iCS mod 256;
            WriteBuffer[ i ] := iByte;
            iCS := iCS div 256;
          end;
        end;
        if pBreakPos <> 0 then
        begin
          pSize := pBreakPos;
        end;
        exit;
      end;
      seByte:
      begin
        iString := ReplaceString( iString, pStartPos, pLength, char( pExtra ));
      end;
      seRecSize:
      begin
        if pRecSizePos <> 0 then
        begin
          raise exception.Create('Only one record size field allowed per line');
        end;
        pRecSizePos := pStartPos;
        pRecSize := pExtra;
        iString := ReplaceString( iString, pStartPos, pLength, StringOfChar( #0, pExtra ));
      end;
      seBreak:
      begin
        if pBreakPos <> 0 then
        begin
          raise exception.Create('Only one break field allowed per line');
        end;
        pBreakPos := pExtra;
        iString := ReplaceString( iString, pStartPos, pLength, '');
      end;
      seLost:
      begin
        inc( pLostCount, pExtra );
        iString := ReplaceString( iString, pStartPos, pLength, '');
      end;
      seCS:
      begin
        if pCSPos <> 0 then
        begin
          raise exception.Create('Only one record size field allowed per line');
        end;
        pCSPos := pStartPos;
        pCSSize := pExtra;
        pCSError := pExtra2;
        iString := ReplaceString( iString, pStartPos, pLength, StringOfChar( #0, pExtra ));
      end;
    end;
  end;
end;

function tTransferInterface.StripWrapper(const pString: string): string;
var
  iPos : integer;
begin

end;

function tTransferInterface.ReadBufferChecksum: DWord;
var
  iPos : integer;
  i : integer;
begin
  if fReadRecPos < HeaderSize then
  begin
    raise exception.Create( 'Transfer Interface Data size not yet established' );
  end;
  iPos := HeaderSize + ReadDataSize; // Position to checksum
  Result := 0;
  for i := 1 to ChecksumDigits do
  begin
    Result := Result * 256 + ReadBuffer[ iPos ];
    inc( iPos );
  end;
end;

function tTransferInterface.ReadChecksumOK: boolean;
begin
  case fChecksumDigits of
    1: fReadCheckSum := fReadChecksum mod 256;
    2: fReadCheckSum := fReadChecksum mod (256 * 256);
    4: ; // leave as is
    else raise exception.Create( 'Internal error - illegal number of checksum digits ');
  end;
  Result := ReadBufferChecksum = fReadChecksum;
end;

function tTransferInterface.ReadDataSize: DWord;
var
  iPos : integer;
  i : integer;
begin
  if fReadRecPos < HeaderSize then
  begin
    raise exception.Create( 'Transfer Interface Data size not yet established' );
  end;
  iPos := 2; // Pos 0 = SOH, Pos 1 = RecType
  Result := 0;
  for i := 1 to DataSizeDigits do
  begin
    Result := Result * 256 + ReadBuffer[ iPos ];
    inc( iPos );
  end;
end;

function tTransferInterface.ReceiveRecType: byte;
begin
  Result := ReadBuffer[ 1 ];
end;

function tTransferInterface.ReceiveDataAsString: string;
var
  i: Integer;
begin
  Result := '';
  for i := HeaderSize to HeaderSize + ReadDataSize - 1 do
  begin
    Result := Result + Char( ReadBuffer[ i ] );
  end;
end;

function tTransferInterface.ReceiveRead(const pCount: DWord; var BytesLeft : dWord ) : tReadResult;
var
  i : integer;
begin
  for i := 0 to pCount - 1 do
  begin
    // ignore all until SOH read
    ReadBuffer[ fReadRecPos ] := TempReadBuffer[ i ];
    if (fReadRecPos > 0) or ReceiveRecClassValid then
    begin
      inc( fReadRecPos );
    end;
  end;
  // has header been completely read?
  if fReadRecPos < HeaderSize then
  begin
    BytesLeft := HeaderSize - fReadRecPos;
    Result := rrHeaderIncomplete;
    exit;
  end;
  BytesLeft := HeaderSize + ReadDataSize + ChecksumDigits + 1 {for EOT} - fReadRecPos;
  if BytesLeft <= 0 then
  begin
    Result := EndRead;
  end
  else
  begin
    Result := rrTransferIncomplete;
  end;
end;

function tTransferInterface.ReceiveRead(const pByte: byte): tReadResult;
var
  iBytesLeft : integer;
begin
  // ignore all until SOH read
  ReadBuffer[ fReadRecPos ] := pByte;
  if (fReadRecPos > 0) or ReceiveRecClassValid then
  begin
    inc( fReadRecPos );
  end;
  // has header been completely read?
  if fReadRecPos < HeaderSize then
  begin
    Result := rrHeaderIncomplete;
    exit;
  end;
  iBytesLeft := HeaderSize + ReadDataSize + ChecksumDigits + 1 {for EOT} - fReadRecPos;
  if iBytesLeft <= 0 then
  begin
    Result := EndRead;
  end
  else
  begin
    Result := rrTransferIncomplete;
  end;
end;

function tTransferInterface.ReceiveRecClass: tRecordClass;
begin
  if ReceiveRecClassValid then
  begin
    Result := tRecordClass( ReadBuffer[ 0 ] )
  end
  else
  begin
    raise exception.Create('Receive Record Class is not valid');
  end;
end;

function tTransferInterface.ReceiveRecClassValid: boolean;
begin
  Result := ReadBuffer[ 0 ] in [ {rcENQ =} 5, {rcSOH =} 1, {rcACK =} 6, {rcNAK =} 21 ];
end;

function tTransferInterface.ReplaceString(const pInString: string;
  const pStartPos, pLength: integer; const pByString: string) : string;
begin
  Result := Copy( pInString, 1, pStartPos - 1 ) + pByString + Copy( pInString, pStartPos + pLength, Length( pInString ));
end;

procedure tTransferInterface.SetReadBufferLen(const Value: DWord);
begin
  SetLength( ReadBuffer, Value );
  SetLength( TempReadBuffer, Value );
end;

procedure tTransferInterface.SetWriteBufferLen(const Value: DWord);
begin
  SetLength( WriteBuffer, Value );
end;

procedure tTransferInterface.SetWriteRecPos(const Value: DWord);
begin

  fWriteRecPos := Value;
  if Value >= WriteBufferLen then
  begin
    if not WriteBufferOverflow then
    begin
      WriteBufferOverflow := TRUE;
      raise exception.Create('USB Write Buffer Overflow' );
    end;
  end
  else
  begin
    WriteBufferOverflow := FALSE;
  end;
end;

function tTransferInterface.StartRead : DWord;
begin
  fReadRecPos := 0;
  Result := HeaderSize;
end;

procedure tTransferInterface.StartRec(RecordClass : tRecordClass; RecType: Byte);
begin
  fChecksum := 0;
  WriteRecPos := 0;
  AddByte( Byte( RecordClass ));
  AddByte( RecType );
  WriteRecPos := WriteRecPos + DataSizeDigits;  // skip data digits for now
end;

end.
