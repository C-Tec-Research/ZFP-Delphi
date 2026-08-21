unit UnitBulkTransfer;

{
  This handles a specialised interface where a record is exchanged
  with the following format
  header (<SOH>, <ACK> or <NAK> )
  [RecType] 1 byte
  [Datasize] one or more bytes low endian, excludes checksum etc
  Data
  [Checksum] one or more bytes.
}

interface

uses
  USBBulkTransferMode,
  SysUtils;

type
  tRecordClass = ( rcENQ = 5, rcSOH = 1, rcACK = 6, rcNAK = 21 );

type
  ArrByte = array of byte;

implementation

{ tUSBBulkTransferInterface }

procedure tUSBBulkTransferInterface.AddByte( const pValue: byte);
begin
  WriteBuffer[ WriteRecPos ] := pValue;
  WriteRecPos := WriteRecPos + 1;
  inc( fChecksum, pValue );
end;

procedure tUSBBulkTransferInterface.AddBytes(pValue: array of byte; pLen: byte);
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

constructor tUSBBulkTransferInterface.Create; //(pDeviceName: string; pUSBBulkTransfer : tUSBBulkTransfer );
begin
  inherited Create;
  fDataSizeDigits := 1;
  fChecksumDigits := 1;
  WriteBufferLen := 1024;
  ReadBufferLen := 1024;
  //fUSBBulkTransfer := pUSBBulkTransfer;
end;

procedure tUSBBulkTransferInterface.EndRec;
var
  iPos : integer;
  iVal : byte;
  i : integer;
  iDataLen : integer;
  iChecksum : integer;
begin
  // Write the length byte(s)
  iPos := 2;
  iDataLen := fWriteRecPos - 2 - DataSizeDigits;
  fWriteDataLen := iDataLen; // save in case needed by main program
  for i := 1 to DataSizeDigits do
  begin
    iVal := iDataLen mod 256;
    WriteBuffer[ iPos ] := iVal;
    inc( fChecksum, iVal );
    inc( iPos );
    iDataLen := iDataLen div 256;
  end;
  if iDataLen <> 0 then
  begin
    raise exception.Create( 'USB Data record too big for record format' );
  end;
  // else append the checksum.
  iChecksum := fChecksum; // don't let it modify itself!
  for i := 1 to ChecksumDigits do
  begin
    iVal := iChecksum mod 256;
    AddByte( iVal );
    iCheckSum := iChecksum div 256;
  end;

end;

function tUSBBulkTransferInterface.GetReadBufferLen: integer;
begin
  Result := Length( ReadBuffer )
end;

function tUSBBulkTransferInterface.GetWriteBufferLen: integer;
begin
  Result := Length( WriteBuffer )
end;

procedure tUSBBulkTransferInterface.SetReadBufferLen(const Value: integer);
begin
  SetLength( ReadBuffer, Value );
end;

procedure tUSBBulkTransferInterface.SetWriteBufferLen(const Value: integer);
begin
  SetLength( WriteBuffer, Value );
end;

procedure tUSBBulkTransferInterface.SetWriteRecPos(const Value: integer);
begin
  fWriteRecPos := Value;
  if Value >= WriteBufferLen then
  begin
    raise exception.Create('USB Write Buffer Overflow' );
  end;
end;

procedure tUSBBulkTransferInterface.StartRec(RecordClass : tRecordClass; RecType: Byte);
begin
  fChecksum := 0;
  WriteRecPos := 0;
  AddByte( Byte( RecordClass ));
  AddByte( RecType );
  WriteRecPos := WriteRecPos + DataSizeDigits;  // skip data digits for now
end;

end.
