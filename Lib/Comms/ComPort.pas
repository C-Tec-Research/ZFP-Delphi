unit Comport;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Common;

const
  COMMS_OK = 0;
  COMMS_NOT_OPEN = -1;
  COMMS_IN_ERROR = -2;
  COMMS_INP_NOT_EMPTY = -3;
  COMMS_OUT_NOT_EMPTY = -4;
  COMMS_TIMEOUT = -5;
  COMMS_OVERFLOW = -6;
  COMMS_ERROR_REPLY = -7;

type
  TComPort = class(TComponent)
  private
    { Private declarations }
    hCommsPort : THandle;
{    CommsStatus : TCOMSTAT;}
{    EventMask : PWord; }
    iStatus : integer;
{    SendBuffer : array[ 0 .. 256 ] of char;}
    ReplyBuffer : array[ 0 .. 256 ] of char;
    ReplyString : string;
    iReplyBuffer : string;
    ReplyBufferPtr : integer;
    iCommsString : string;
    iSendBufferSize, iRcvBufferSize : integer;
    fAutoOpen : boolean;
    iAutoAppendCR : boolean; { every time a message is sent }
    iEnableTimeOut : boolean; { enable timeout error }

    fCharBuffer: Char; // Added by AD
{
    iReadOverlap, iWriteOverlap : TOverlapped;
}
    iOverlap : TOverlapped;
{
    iEventMask : DWORD;
}
    iCommTimeouts : TCommTimeouts;
    fOnInput : TNotifyEvent; {every time a whole line is read }
    fOnAck : TNotifyEvent; {every time an ACK terminated string is recieved }
    fOnNak : TNotifyEvent; {every time a NACK terminated string is recieced.
                            Note - mispelling of NACK with NAK is intentional
                            to reduce risk of typing errors.}
    fOnCR :  TNotifyEvent; { every time a <CR> received }
    fOnCharacter: TNotifyEvent; {Every time a character is received}

    hDCB : TDCB;  // a record, not a handle!
    function iIsOpen : boolean;
    function fIsOK : boolean;
    function iCheckStat : boolean;
    procedure ChangeOpen( Value: boolean);
    procedure CopyBuffers;
  protected
    { Protected declarations }
    property Handle : THandle
             read hCommsPort;
    function fStatus : string;
  public
    { made public to allow TCommsPort to call it }
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create( AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseComms;
    function OpenComms : boolean;
    function CheckInput( Sender: TObject ) : Boolean;
             { returns true if any characters read,
               or false otherwise }
    procedure fWrite( iValue : string );
{    function Write( Value : PChar ) : integer; }
    property IsOpen : boolean
             read iIsOpen
             write ChangeOpen;
    property IsOK : boolean
             read iCheckStat;
    property Text : string
             read ReplyString
             write fWrite;
    property Buffer : string
             read iReplyBuffer
             write fWrite;
    property CharBuffer: Char // Added by AD
    			 read fCharBuffer
             write fCharBuffer;
  published
    { Published declarations }
    property AutoOpen : boolean
             read fAutoOpen
             write fAutoOpen;
    property AutoAppendCR : boolean
             read iAutoAppendCR
             write iAutoAppendCR;
    property EnabletimeOut : boolean
             read iEnableTimeOut
             write iEnabletimeOut;
    property SetupString : string
             read iCommsString
             write iCommsString;
    property SendBufferSize : integer
             read iSendBufferSize
             write iSendBufferSize;
    property RcvBufferSize : integer
             read iRcvBufferSize
             write iRcvBufferSize;
    property Status : string
             read fStatus;
    property OnInput : TNotifyEvent
             read fOnInput
             write fOnInput;
    property OnAck : TNotifyEvent
             read fOnAck
             write fOnAck;
    property OnNak : TNotifyEvent
             read fOnNak
             write fOnNak;
    property OnCR : TNotifyEvent
             read fOnCR
             write fOnCR;
    property OnCharacter: TNotifyEvent //Added by AD
    			 read fOnCharacter
             write fOnCharacter;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TComport]);
end;

constructor TComPort.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  iCommsString := 'COM1: 9600, e, 7, 1';
  iSendBufferSize := 256;
  iRcvBufferSize := 256;
  hCommsPort := COMMS_OK;
  iStatus := COMMS_NOT_OPEN;
  iAutoAppendCR := True;
  iEnableTimeOut := False;
  fAutoOpen := True;
end;

destructor TComPort.Destroy;
begin
  CloseComms;
  inherited Destroy;
end;

procedure TComPort.Loaded;
begin
  inherited Loaded;
  if (not (csDesigning in ComponentState ))
     and fAutoOpen then OpenComms;
end;

function TComPort.OpenComms : boolean;
var
  Port : array [0 .. 256] of char;
  i : Integer;
{  hDCB : TDCB;}
  PPort : PAnsiChar;
begin
  CloseComms;
  i := 0;
  { derive port ID from iCommsString }
  { Note: we may have to prepend \\.\ }
  while ((i < Length( iCommsString ))
        and (iCommsString[ i + 1] <> ' ')
        and (i < 15)) do
  begin
    Port[i] := iCommsString[i+1];
    Inc( i );
  end;
  Port[i] := Chr(0);
  { Open Comms Port, if Possible }
  hCommsPort := CreateFile( Port,
             GENERIC_READ or GENERIC_WRITE,
             0, {exclusive access }
             nil, { we are not interested in security, but we may need
                    to create a descriptor anyway }
             OPEN_EXISTING,
             FILE_FLAG_OVERLAPPED,
             0 ); {no template }
  {
    OpenComm(Port, RcvBufferSize, SendBufferSize );
  }
  if IsOpen then
  begin
    { copy rest of iCommsString }
    PPort := @Port;
    StringToPChar( PPort, iCommsString );
{    while (i < Length( iCommsString )) do
    begin
      Port[i] := iCommsString[i+1];
      Inc( i );
    end;
    Port[i] := Chr(0);
}
    if BuildCommDCB(Port, hDCB) then
      iStatus := COMMS_OK
    else
      iStatus := GetLastError;
    if fIsOK then
    begin
      if SetCommState( hCommsPort, hDCB ) then
        iStatus := COMMS_OK
      else
        iStatus := GetLastError;
{
      iStatus := SetCommState( ^hDCB );
}
{
      if fIsOK and SetCommMask( hCommsPort, EV_RXCHAR ) then
        iStatus := COMMS_OK
      else
        iStatus := GetLastError;
}

      { Set Time out values }
      iCommTimeouts.ReadIntervalTimeout := MAXDWORD;
      iCommTimeouts.ReadTotalTimeoutMultiplier := 0;
      iCommTimeouts.ReadTotalTimeoutConstant := 0;
      iCommTimeouts.WriteTotalTimeoutMultiplier := 0;
      iCommTimeouts.WriteTotalTimeoutConstant := 0;
      if fIsOK and SetCommTimeouts( hCommsPort, iCommTimeouts ) then
        iStatus := COMMS_OK
      else
        iStatus := GetLastError;

{
      EventMask := SetCommEventMask( hCommsPort, EV_RXCHAR );
}
      { Set up event object }
{
      iOverlap.hEvent := CreateEvent( nil, TRUE, FALSE, nil );
}                      { default security, manual, initially not set, unnamed }
    end;
  end;
  result := fIsOk;
end;

procedure TComPort.CloseComms;
begin
  if IsOpen then
  begin
    CloseHandle( hCommsPort );
    hCommsPort := INVALID_HANDLE_VALUE;
  end;
end;

function TComPort.iIsOpen : boolean;
begin
  result := (hCommsPort <> INVALID_HANDLE_VALUE );
end;

function TComPort.fIsOK : boolean;
begin
  result := (iStatus = COMMS_OK );
end;

procedure TComPort.ChangeOpen( Value: boolean);
begin
  if Value then OpenComms else CloseComms;
end;

function TComPort.iCheckStat : boolean;
begin
{  iStatus := GetCommError( hCommsPort, CommsStatus ); }
  Result := fIsOk;
end;

function TComPort.fStatus : string;
begin
  if iStatus = COMMS_OK then Result := 'Open'
  else
  case iStatus of
    COMMS_NOT_OPEN : Result := 'Not Open';
    COMMS_IN_ERROR : Result := 'Comms Error';
    COMMS_INP_NOT_EMPTY : Result := 'Input Buffer not empty';
    COMMS_OUT_NOT_EMPTY : Result := 'Output Buffer not empty';
    COMMS_TIMEOUT : Result := 'Comms Time Out';
    COMMS_OVERFLOW : Result := 'Buffer Overflow';
    COMMS_ERROR_REPLY : Result := 'Comms Error Reply';
  else Result := 'Unknown Error ' + IntToStr( iStatus );
  end;
end;

function TComPort.CheckInput( Sender: TObject ) : Boolean;
var
  BytesRead : LongWord;
  TempBuffer : array [1..2] of char;
begin
  fStatus;
  Result := False;
  iOverlap.Offset := 0;
  iOverlap.OffsetHigh := 0;
  ReadFile( hCommsPort, TempBuffer, 1, BytesRead, @iOverlap );
  while BytesRead > 0 do
  begin
    Result := True;
    ReplyBuffer[ ReplyBufferPtr ] := TempBuffer[1];
    fCharBuffer := ReplyBuffer[ReplyBufferPtr];
    if Assigned (fOnCharacter) then fOnCharacter (Self); // Added by AD
    case ReplyBuffer[ ReplyBufferPtr ] of
      Chr( 6 ),chr( 13), chr( 21 ):
      begin
        CopyBuffers;
//        Exit;
      end;
    else
      if ReplyBufferPtr < (iRcvBufferSize - 1) then
      begin
        Inc (ReplyBufferPtr);
      end
      else
      begin
        CopyBuffers;
//        Exit;
      end;
    end;
    ReadFile( hCommsPort, TempBuffer, 1, BytesRead, @iOverlap );
  end;
end;

procedure TComPort.fWrite( iValue : string );
var
  i,j : integer;
  Value : array[ 0.. 256 ] of char;
  BytesWritten : LongWord;
begin
  j := 0;
  for i:= 1 to Length( iValue ) do
  begin
    Value[j] := iValue[i];
    Inc( j );
  end;
  if iAutoAppendCR and ((j = 0) or (Value[j-1] <> Chr(13))) then
  begin
    Value[j] := Chr(13);
    Inc(j);
  end;
  EnableTimeOut:=True;  {a timeout is now possible}
  Value[j] := Chr(0);
{
  iStatus := WriteComm(hCommsPort, Value,strlen(Value));
}
  iOverlap.Offset := 0;
  iOverlap.OffsetHigh := 0;
  WriteFile( hCommsPort, Value, strlen(Value), BytesWritten, @iOverlap );
{
  if BytesWritten <> strlen(Value) then
    iStatus := GetLastError;
}
end;

procedure TComPort.CopyBuffers;
var
  i : integer;
begin
  ReplyString := '';
  iReplyBuffer := '';
  for i := 0 to ReplyBufferPtr - 1 do
  begin
    ReplyString := ReplyString + ReplyBuffer[i];
    iReplyBuffer := iReplyBuffer + ReplyBuffer[i];
  end;
  iReplyBuffer := iReplyBuffer + ReplyBuffer[ ReplyBufferPtr ] ;
               { copy terminator litterally to buffer }
               { substitute readable string in text }
  case ReplyBuffer[ ReplyBufferPtr ] of
    chr(6) :        { ack }
      begin
        ReplyString := ReplyString + '<ack>';
        EnableTimeOut:=False;
        if Assigned( fOnInput ) then fOnInput( Self );
        if Assigned( fOnAck ) then fOnAck( Self );
      end;
    chr(21) :       { nack }
      begin
        ReplyString := ReplyString + '<nack>';
        EnableTimeOut:=False;
        if Assigned( fOnInput ) then fOnInput( Self );
        if Assigned( fOnNak ) then fOnNak( Self );
      end;
    chr(13) :       { cr }
      begin
        ReplyString := ReplyString + '<cr>';
        EnableTimeOut:=False;
        if Assigned( fOnInput ) then fOnInput( Self );
        if Assigned( fOnCR ) then fOnCR( Self );
      end;
    else
      begin
        // buffer overflow
        ReplyString := ReplyString + '<overflow>';
        EnableTimeOut:=False;
        if Assigned( fOnInput ) then fOnInput( Self );
      end;
  end;
  { we have dealt with the 3 possible terminators - now the common stuff }
  ReplyBufferPtr := 0;
end;

end.
