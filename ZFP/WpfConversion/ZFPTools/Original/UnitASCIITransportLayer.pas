unit UnitASCIITransportLayer;

{
  This builds an ASCII transport layer on top of the bulk mode transfer interface
  It builds legal transfers as an ASCII file into a several sets of strings.

  Objects are added to each line to give extra information, such as
  direction, checksum, a timestamp, and so on to allow detailed handling.

  The PC is usually a master, but uncontrolled responses are also allowed.

  Normally, however, the connnection is openned on first supply of a record
  to transmit and closed after a fixed timeout period from the last receipt.

  Automatic retransmission on timeout is allowed, but checking for 'out of step'
  states belongs to the owning process.

  An alternative to Transfer interface but limited to ASCII transfers with
  the standard protocol

  header (<SOH>)
  [RecType] 1 byte = 1 (ASCII)
  [Datasize] 2 bytes big endian, excludes checksum etc
  Data
  [Checksum] 2 bytes.

  (Data is ASCII, so a non-ascii a character in data area aborts a transfer.
   if it is SOH then it is reckoned to be a new record)
}

interface

uses
  Controls,
  Classes,
  SysUtils,
  Windows,
  USBBulkTransferMode,
  UnitDongleInterface;

type

  tASCIIXITxObject = class
  private
    fStatus: DWord;
    fRetryCount: integer;
    fChecksum: DWord;
    fBytesToSend: DWord;
  public
    BytesSent : DWord; // direct access needed for transmission
    property Status : DWord
             read fStatus
             write fStatus;
    property RetryCount : integer
             read fRetryCount
             write fRetryCount;
    property Checksum : DWord
             read fChecksum
             write fChecksum;
    property BytesToSend : DWord
             read fBytesToSend
             write fBytesToSend;

  end;

  tASCIIXIRxObject = class
  private
    fCalcChecksum: DWord;
    fRcvChecksum: DWord;
  public
    property CalcChecksum : DWord
             read fCalcChecksum
             write fCalcChecksum;
    property RcvChecksum : DWord
             read fRcvChecksum
             write fRcvChecksum;
    function ChecksumOK : boolean;
  end;

  tASCIITransferThread = class;

  tOnRcvRec = procedure( const pRec : string; const pStatus : tASCIIXIRxObject ) of object;
  tOnFail = procedure( const ReasonCode : DWord ) of object;

  tASCIIExtraInfo = class
  private
    EOT_Rcvd: boolean;
    fSendHistory: tStringList;
    fRcvHistory: tStringList;
    fSendIndex: integer;
    fRcvIndex: integer;
    fActivePort: tUSBBulkTransfer;
    fActivePortIndex: integer;
    fUSBBulkTransferList: tUSBBulkTransferList;
    fASCIITransferThread : tASCIITransferThread;
    fRcvBuffer : array[ 0..2047 ] of byte;
    fRcvPointer : integer;
    //fRcvChecksum : DWord;
    fRcvRecLength : DWord;
    fSendBuffer : array[ 0..2047 ] of byte;
    fSendPointer : integer;
    fSendChecksum : DWord;
    //fSendRecLength : DWord;
    fOnRcvRec: tOnRcvRec;
    fOnFail: tOnFail;
    fTxObject : tASCIIXITxObject;
    fOnSendFail: tOnFail;
    fUseThreading: boolean;
    fUseWaitForSingleObject: boolean;
    function GetRcvCount: integer;
    function GetSendCount: integer;
    procedure SetActivePortIndex(const Value: integer);
    procedure StartRec;
    procedure AddByte( const pValue : byte );
    procedure SetUseWaitForSingleObject(const Value: boolean);
    procedure SetUseThreading(const Value: boolean);
    function GetConnectionName(const i: integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    function Start : boolean;
    procedure Stop;
    procedure Clear;
    property SendHistory : tStringList
             read fSendHistory;
    property RcvHistory : tStringList
             read fRcvHistory;
    property SendIndex : integer
             read fSendIndex; // count of records sent so far
    property RcvIndex : integer
             read fRcvIndex; // count of records sent so far
    property SendCount : integer
             read GetSendCount; // count of records sent so far
    property RcvCount : integer
             read GetRcvCount; // count of records sent so far
    property ActivePort : tUSBBulkTransfer
             read fActivePort;
    property ActivePortIndex : integer
             read fActivePortIndex
             write SetActivePortIndex;
    function CheckForDevices : integer;
    property USBBulkTransferList : tUSBBulkTransferList
             read fUSBBulkTransferList;
    property OnRcvRec : tOnRcvRec
             read fOnRcvRec
             write fOnRcvRec;
    property OnRcvFail : tOnFail
             read fOnFail
             write fOnFail;
    property OnSendFail : tOnFail
             read fOnSendFail
             write fOnSendFail;

    function CheckSendErrorStatus( pStatus : DWord ) : boolean;

    function SendString( const pString : string ) : boolean;
    function ResendLastRec : boolean;
    function SendNotification( const pReason : string ) : boolean;

    procedure RcvByte( iVal : byte );
    procedure HandleRcvRec;

    procedure HandleError( const pError : DWord );

    function CurrentSendStatus : tASCIIXITxObject;
    function CurrentRcvStatus : tASCIIXIRxObject;
    function CurrentSendString : string;

    function Execute : integer;

    property UseWaitForSingleObject : boolean
             read fUseWaitForSingleObject
             write SetUseWaitForSingleObject;

    property UseThreading : boolean
             read fUseThreading
             write SetUseThreading;

    property ConnectionName[ const i : integer ] : string
             read GetConnectionName;
    const
      cSOH = 1;
      cEOT = 4;
      cASCIITransfer = 1;
      cHeaderSize = 4;
      cNonDataSize = 7;
  end;

  tASCIITransferThread = class( tThread )
  private
    fOwner: tASCIIExtraInfo;
  protected
    procedure Execute; override;
  public
    constructor Create( pOwner : tASCIIExtraInfo );
    procedure GetByte;
    property Owner : tASCIIExtraInfo
             read fOwner;
  end;

implementation

{ tASCIIExtraInfo }

procedure tASCIIExtraInfo.AddByte(const pValue: byte);
begin
  fSendBuffer[ fSendPointer ] := pValue;
  fSendPointer := fSendPointer + 1;
  inc( fSendChecksum, pValue );
end;

function tASCIIExtraInfo.CheckSendErrorStatus(pStatus: DWord): boolean;
begin
  Result := pStatus = NO_ERROR;
  if not Result then
  begin
    if assigned( fOnSendFail ) then
    begin
      fOnSendFail( pStatus );
    end;
  end;
end;

function tASCIIExtraInfo.CheckForDevices: integer;
begin
  fUSBBulkTransferList.CheckInfo;
  Result := fUSBBulkTransferList.Count;
  FormDongleInterface.USBPanel.Open_USB;
  if FormDongleInterface.USBPanel.Open then
  begin
    inc( Result );
    FormDongleInterface.USBPanel.Close_USB;
  end;
end;

procedure tASCIIExtraInfo.Clear;
begin
  fSendHistory.Clear;
  fSendIndex := 0;
  fRcvHistory.Clear;
  fRcvIndex := 0;
end;

constructor tASCIIExtraInfo.Create;
begin
  inherited Create;
  fSendHistory := tStringList.Create;
  fSendHistory.OwnsObjects := TRUE;
  fRcvHistory := tStringList.Create;
  fRcvHistory.OwnsObjects := TRUE;
  fUSBBulkTransferList := tUSBBulkTransferList.Create;
  fUSBBulkTransferList.AllowDev := TRUE;
  fUseThreading := FALSE;
  //fASCIITransferThread := tASCIITransferThread.Create( self );
  //fASCIITransferThread.FreeOnTerminate := FALSE;  // we reuse this thread
end;

function tASCIIExtraInfo.CurrentRcvStatus: tASCIIXIRxObject;
begin
  with fRcvHistory do
  begin
    if Count > 0 then
    begin
      Result := Objects[ Count - 1] as tASCIIXIRxObject;
    end
    else
    begin
      Result := nil;
    end;
  end;
end;

function tASCIIExtraInfo.CurrentSendStatus: tASCIIXITxObject;
begin
  with fSendHistory do
  begin
    if Count > 0 then
    begin
      Result := Objects[ Count - 1] as tASCIIXITxObject;
    end
    else
    begin
      Result := nil;
    end;
  end;
end;

function tASCIIExtraInfo.CurrentSendString: string;
var
  i : integer;
begin
  i := SendHistory.Count - 1;
  if i >= 0 then
  begin
    Result := SendHistory[ i ];
  end
  else
  begin
    Result := '';
  end;
end;


destructor tASCIIExtraInfo.Destroy;
begin
  fSendHistory.Free;
  fRcvHistory.Free;
  fUSBBulkTransferList.Free;
  fASCIITransferThread.Free;
  inherited;
end;

function tASCIIExtraInfo.Execute : integer;
var
  iVal : byte;
label
  Loop;
begin
  Result := 0;
  if ActivePort.IsOpen then
  begin
Loop:
    if EOT_Rcvd = FALSE then
    begin
      ActivePort.GetByte( iVal );
      inc( Result );
      RcvByte( iVal );
      goto Loop;
    end
    else
    begin
      EOT_Rcvd := FALSE;
    end;

    {if ActivePort.GetByte( iVal ) then
    begin
      inc( Result );
      RcvByte( iVal );
      goto Loop;
    end
    else if ActivePort.ByteReadError = ERROR_ACCESS_DENIED then
    begin
      //HandleError( ActivePort.ByteReadError );
    end
    else if ActivePort.ByteReadError <> ERROR_IO_PENDING then
    begin
      if ActivePort.ByteReadError <> ERROR_IO_INCOMPLETE then
      begin
        HandleError( ActivePort.ByteReadError );
      end;
    end;}
  end;
end;

function tASCIIExtraInfo.SendNotification(const pReason: string): boolean;
var
  iString : string;
  iSendStatus : tASCIIXITxObject;
  iPos : integer;
  i, iLen : integer;
  iChecksum : dWord;
  iBytesSent : dWord;
begin
  Result := FALSE;
  iSendStatus := CurrentSendStatus;
  if iSendStatus.RetryCount < 3 then
  begin
    iSendStatus.RetryCount := iSendStatus.RetryCount + 1;
    iString := CurrentSendString;
    iPos := Pos( ',', iString );
    if iPos > 0 then
    begin
      if CurrentRcvStatus = nil then
      begin
        iString := Copy( iString, 1, iPos ) // include ','
                 + pReason + ',0';
      end
      else
      begin
        iString := Copy( iString, 1, iPos ) // include ','
                 + pReason + ',' + IntToStr( CurrentRcvStatus.RcvChecksum );
      end;
    end;
    StartRec;
    iLen := Length( iString );
    AddByte( iLen div 256 );
    AddByte( iLen mod 256 );
    for i := 1 to Length( iString ) do
    begin
      AddByte( Ord( iString[ i ] ));
    end;
    iChecksum := fSendChecksum mod (256 * 256); // don't let it modify itself!
    AddByte( iChecksum div 256 );
    AddByte( iChecksum mod 256 );
    AddByte( cEOT );
    if ActivePort.IsOpen then
    begin
      ActivePort.Write( fSendBuffer, fSendPointer, iBytesSent);
      iSendStatus.Status := ActivePort.LastError;
    end
    else
    begin
      iSendStatus.Status := ERROR_INVALID_HANDLE;
    end;
    Result := iSendStatus.Status = NO_ERROR;
  end;
end;

function tASCIIExtraInfo.SendString( const pString : string ) : boolean;
var
  i, iLen : integer;
begin
  // else append the checksum.
  fTxObject := tASCIIXITxObject.Create;
  StartRec;
  // add data length
  iLen := Length( pString );
  AddByte( iLen div 256 );
  AddByte( iLen mod 256 );
  for i := 1 to iLen do
  begin
    AddByte( Ord( pString[ i ] ));
  end;
  with fTxObject do
  begin
    Checksum := fSendChecksum mod (256 * 256); // don't let it modify itself!
    AddByte( Checksum div 256 );
    AddByte( Checksum mod 256 );
    AddByte( cEOT );
    BytesToSend := fSendPointer;
  end;
  if ActivePort.IsOpen then
  begin
    ActivePort.Write( fSendBuffer, fTxObject.BytesToSend, fTxObject.BytesSent);
    fTxObject.Status := ActivePort.LastError;
  end
  else
  begin
    fTxObject.Status := ERROR_INVALID_HANDLE;
  end;
  SendHistory.AddObject( pString, fTxObject );
  Result := CheckSendErrorStatus( fTxObject.Status );
end;

function tASCIIExtraInfo.GetConnectionName(const i: integer): string;
begin
  if i < fUSBBulkTransferList.Count then
  begin
    Result := USBBulkTransferList.Entry[ i ].Name;
  end
  else
  begin
    Result := 'USB HS Serial Interface';
  end;

end;

function tASCIIExtraInfo.GetRcvCount: integer;
begin
  Result := fRcvHistory.Count
end;

function tASCIIExtraInfo.GetSendCount: integer;
begin
  Result := fSendHistory.Count
end;

procedure tASCIIExtraInfo.HandleError(const pError: DWord);
begin
  if assigned( fOnFail ) and (pError <> NO_ERROR) then
  begin
    fOnFail( pError );
  end;
end;

procedure tASCIIExtraInfo.HandleRcvRec;
var
  iRec : string;
  i : integer;
  iRcvObject : tASCIIXIRxObject;
begin
  // Save text of record and create object describing success/failure
  iRcvObject := tASCIIXIRxObject.Create;
  with iRcvObject do
  begin
    RcvChecksum := 256 * fRcvBuffer[ cHeaderSize + fRcvRecLength ] + fRcvBuffer[ cHeaderSize + fRcvRecLength + 1 ];

    CalcChecksum := 0;
    iRec := '';
    for i := 0 to cHeaderSize - 1 do
    begin
      CalcCheckSum := CalcChecksum + fRcvBuffer[ i ] ;
    end;
    for i := cHeaderSize to cHeaderSize + fRcvRecLength - 1 do
    begin
      CalcCheckSum := CalcChecksum + fRcvBuffer[ i ] ;
      iRec := iRec + char( fRcvBuffer[ i ] );
    end;
  end;
  RcvHistory.AddObject( iRec, iRcvObject );
  if assigned( fOnRcvRec ) then
  begin
    fOnRcvRec( iRec, iRcvObject );
  end;
end;

procedure tASCIIExtraInfo.RcvByte(iVal: byte);
begin
  {
  header (<SOH>)
  [RecType] 1 byte = 1 (ASCII)
  [Datasize] 2 bytes big endian, excludes checksum etc
  Data
  [Checksum] 2 bytes.
  }

  fRcvBuffer[ fRcvPointer ] := iVal;
  case fRcvPointer of
    0:
    begin
      // Waiting for SOH
      if iVal = cSOH then
      begin
        inc( fRcvPointer );
      end;
    end;
    1:
    begin
      if iVal = cASCIITransfer then
      begin
        inc( fRcvPointer );
      end
      else
      begin
        fRcvPointer := 0;  // wait for next SOH
      end;
    end;
    2:
    begin
      inc( fRcvPointer );
    end;
    3:
    begin
      fRcvRecLength := 256 * fRcvBuffer[ 2 ] + iVal;
      inc( fRcvPointer );
    end;
    else
    begin
      inc( fRcvPointer );
      // have we reached end of record?
      if fRcvPointer > integer(fRcvRecLength) + cHeaderSize then
      begin
        if fRcvPointer = integer(fRcvRecLength) + cNonDataSize then
        begin
          if iVal = cEOT then
          begin
            // complete record received
            EOT_Rcvd := TRUE;
            HandleRcvRec;
            fRcvPointer := 0;
          end;
        end;
      end
      {else if iVal in [8..255] then // ASCII Byte
      begin
        // OK
      end
      else if iVal = cSOH then
      begin
        // discard what we had and start again
        fRcvPointer := 1; // we kno [0] = SOH so need to rewrite
      end
      else
      begin
        // corruption - start again
        fRcvPointer := 0;
      end;}
    end;
  end;

end;

function tASCIIExtraInfo.ResendLastRec: boolean;
begin
  if ActivePort.IsOpen then
  begin
    fTxObject.RetryCount := fTxObject.RetryCount + 1;
    ActivePort.Write( fSendBuffer, fTxObject.BytesToSend, fTxObject.BytesSent);
    fTxObject.Status := ActivePort.LastError;
  end
  else
  begin
    fTxObject.Status := ERROR_INVALID_HANDLE;
  end;
  Result := CheckSendErrorStatus( fTxObject.Status );
end;

procedure tASCIIExtraInfo.SetActivePortIndex(const Value: integer);
begin
  fActivePortIndex := Value;
  if Value < 0 then
  begin
    fActivePort := nil;
  end
  else
  begin
    if Value >= USBBulkTransferList.Count then
    begin
      fActivePort := nil;
      FormDongleInterface.USBPanel.Open_USB;
      if not FormDongleInterface.USBPanel.Open then
      begin
        raise exception.Create( 'Connection index out of bounds' );
      end;
    end
    else
    begin
      fActivePort := USBBulkTransferList.Entry[ Value ];
      if Assigned( fActivePort ) then
      begin
        ActivePort.UseWaitForSingleObject := fUseWaitForSingleObject;
      end;
    end;
  end;
end;

procedure tASCIIExtraInfo.SetUseThreading(const Value: boolean);
begin
  if fUseThreading <> Value then
  begin
    fUseThreading := Value;
    if Value then
    begin
      fASCIITransferThread := tASCIITransferThread.Create( self );
      fASCIITransferThread.FreeOnTerminate := FALSE;  // we reuse this thread
    end
    else
    begin
      FreeAndNil( fASCIITransferThread );
    end;
  end;
end;

procedure tASCIIExtraInfo.SetUseWaitForSingleObject(const Value: boolean);
begin
  fUseWaitForSingleObject := Value;
  if assigned( ActivePort ) then
  begin
    ActivePort.UseWaitForSingleObject := Value;
  end;
end;

function tASCIIExtraInfo.Start: boolean;
begin
  Result := TRUE;
  if assigned( fActivePort ) then
  begin
    if ActivePort.IsOpen then
    begin
      fRcvPointer := 0;
    end
    else
    begin
      ActivePort.Open;
      Result := ActivePort.IsOpen;
      if Result then
      begin
        fRcvPointer := 0;
        if UseThreading then
        begin
          fASCIITransferThread.Start;
        end;
      end;
    end;
  end;
end;

procedure tASCIIExtraInfo.StartRec;
begin
  fSendChecksum := 0;
  fSendPointer := 0;
  AddByte( cSOH );
  AddByte( cASCIITransfer );
end;

procedure tASCIIExtraInfo.Stop;
begin
  if assigned( fActivePort ) then
  begin
    if UseThreading then
    begin
      if assigned( fASCIITransferThread ) then
      begin
        if not fASCIITransferThread.Terminated then
        begin
          fASCIITransferThread.Terminate;
        end;
      end;
    end;
    fActivePort.Close;
  end;
end;

{ tASCIITransferThread }

constructor tASCIITransferThread.Create(pOwner: tASCIIExtraInfo);
begin
  inherited Create( TRUE );
  fOwner := pOwner;
end;

procedure tASCIITransferThread.Execute;
begin
  inherited;

  // we are simply reading - we have nothing to do with sending
  while not Terminated do
  begin
    GetByte;
  end;
end;

procedure tASCIITransferThread.GetByte;
var
  iVal : byte;
begin
  with fOwner.ActivePort do
  begin
    if IsOpen then
    begin
      if GetByte( iVal ) then
      begin
        fOwner.RcvByte( iVal );
      end
      else if ByteReadError <> ERROR_IO_PENDING then
      begin
        if ByteReadError <> ERROR_IO_INCOMPLETE then
        begin
          fOwner.HandleError( ByteReadError );
        end;
      end;
    end;
  end;
end;

{ tASCIIXIRxObject }

function tASCIIXIRxObject.ChecksumOK: boolean;
begin
  Result := fCalcChecksum = fRcvChecksum;
end;

end.
