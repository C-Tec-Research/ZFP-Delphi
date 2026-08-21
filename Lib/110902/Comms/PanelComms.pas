unit PanelComms;

interface

uses SysUtils, Windows, Classes, Dialogs, ComPanel,
	   Forms,
     SigComPort,
     Common;

type
	TPanelProtocol = (ppNone, ppNew, ppOld, ppOldInverted);
	TPacketReceived = procedure (Sender: TObject; CmdChar: Char; Packet: string) of object;


	TPanelComms = class (TCommsPanel)
  private
    fOnReceiveDataEvent: TComportReceiveDataEvent;
    fBuffer: string;
    fText: string;
    fOnOutputTimeout: TNotifyEvent;
    function GetHwHandshaking: THwHandshaking;
    function GetSwHandshaking: TSwHandshaking;
    procedure SetHwHandshaking(const Value: THwHandshaking);
    procedure SetSwHandshaking(const Value: TSwHandshaking);
//    function GetComPortDataBits: TDataBits;
//    procedure SetComPortDataBits(const Value: TDataBits);
//    function GetComPortStopBits: TStopBits;
//    procedure SetComPortStopBits(const Value: TStopBits);
//    function GetComPortBaudRate: tBaudRate;
//    procedure SetComPortBaudRate(const Value: tBaudRate);
    function GetOutputTimeout: Dword;
    procedure SetOutputTimeout(const Value: Dword);
	protected
		FProtocolType: TPanelProtocol;
		FOnTickEvent: TNotifyEvent;
		FHandshakeReceived: Boolean;
    FIsASCIIOnly : Boolean;
		FCommsFault: Boolean;
		FCommsRetries: integer;
		FOnPacketReceived: TPacketReceived;

		CharsReceived: word;	// Number of characters received
		FDataLength: integer;
		FRxBuffer: string;
		FOnInvalidChecksum: TNotifyEvent;
    FCancel: Boolean;
    FOnHandshakeReceived: TNotifyEvent;
    FOnTimeout: TNotifyEvent;
		procedure EstablishHandshake;
    procedure SetBuffer(const Value: string); override;
    procedure SetText(const Value: string); override;
	protected
//		property RxBuffer: string read FRxBuffer write FRxBuffer;
		property DataLength: Integer read FDataLength write FDataLength;

		property CommsRetries: integer read FCommsRetries write FCommsRetries;
		procedure Loaded; override;
		procedure fOnTick (Sender: TObject);
		procedure fOnReceiveData (Sender: TObject; DataPtr: Pointer; DataSize: integer);
		procedure fOnInputTimeoutEvent (Sender: TObject);
//		procedure fOnReceiveData (Sender: TObject; DataPtr: Pointer; DataSize: integer);

		procedure EstablishComms;
		procedure ReceivedHandshake;
    procedure TxDelay;
		function ValidateChecksum (Checksum: Char): Boolean;
	public
		property ProtocolType: TPanelProtocol read FProtocolType write FProtocolType;
		property CommsFault: Boolean read FCommsFault write FCommsFault;
		property HandshakeReceived: Boolean read FHandshakeReceived write FHandshakeReceived;
		property Cancel: Boolean read FCancel write FCancel;
    property SetCharsReceived: word Read CharsReceived write CharsReceived;


		constructor Create (AOwner: TComponent); override;
		procedure SendString (Data: string); virtual;
    procedure ClearASCIIBuffer;
    property Buffer : string
				     read fBuffer
				     write SetBuffer;
	 procedure FlushBuffers (inBuf, outBuf: Boolean);
	published
		property OnInvalidChecksum: TNotifyEvent read FOnInvalidChecksum write FOnInvalidChecksum;
		property OnPacketReceived: TPacketReceived read FOnPacketReceived write FOnPacketReceived;
		property OnTick: TNotifyEvent read FOnTickEvent write FOnTickEvent;
		property OnHandshakeReceived: TNotifyEvent read FOnHandshakeReceived write FOnHandshakeReceived;
		property OnTimeout: TNotifyEvent read FOnTimeout write FOnTimeout;
		property RxBuffer: string read FRxBuffer write FRxBuffer;
		property DCharsReceived: word read CharsReceived write CharsReceived;
    property IsASCIIOnly : boolean Read FIsASCIIOnly write FIsASCIIOnly default FALSE;
	  property OnReceiveData :TComportReceiveDataEvent
				     read fOnReceiveDataEvent
				     write fOnReceiveDataEvent;
	  property Text : string
             read fText
             write SetText;
	  property OnOutputTimeout: TNotifyEvent // Output time out event
             read fOnOutputTimeout
             write fOnoutputTimeout;
	  property OutputTimeout: Dword
             read GetOutputTimeout
             write SetOutputTimeout;
//    property ComPortSpeed: tBaudRate
//             read GetComPortBaudRate
//             write SetComPortBaudRate;
//    property ComPortParity : tParity
//             read GetParity
//             write SetParity
//             default ptEven;
//	  property ComPortDataBits: TDataBits
//             read GetComPortDataBits
//             write SetComPortDataBits;
//	  property ComPortStopBits: TStopBits
//             read GetComPortStopBits
//             write SetComPortStopBits;
    // Hardware Handshaking Type to use:
	  //  cdNONE          no handshaking
	  //  cdCTSRTS        both cdCTS and cdRTS apply (** this is the more common method**)
	  property HwHandshaking: THwHandshaking
             read GetHwHandshaking
             write SetHwHandshaking;
    // Software Handshaking Type to use:
	  //  cdNONE          no handshaking
	  //  cdXONXOFF       XON/XOFF handshaking
	  property SwHandshaking: TSwHandshaking
				     read GetSwHandshaking
             write SetSwHandshaking;

	end;

procedure Register;

// Constants
const
	{ Constants used in serial communication }
	NEW_PROTOCOL = 0;
	OLD_PROTOCOL = 1;
	OLD_PROTOCOL_PARITY_INVERTED = 2;

	SOH = #1;
	RxAck = #6;
	RxNak = #21;
	ReqUpload = #65;
	RetUpload = #65;
	ReqDownload = #66;
	RetDownload = #66;
	TxReqPointName = #67;
	RxRetPointName = #67;
	TxSetPointName = #68;
	RxSetPointName = RxAck;
	TxReqZoneName = #69;
	RxRetZoneName = #69;
	TxSetZoneName = #70;
	RxSetZoneName = RxAck;
	TxReqMaintName = #71;
	RxRetMaintName = #71;
	TxSetMaintName = #72;
	RxSetMaintName = RxAck;
	TxReqPData = #73;
	RxRetPData = #73;
	TxSetPData = #74;
	RxSetPData = RxAck;
	TxReqMaintDate = #75;
	RxRetMaintDate = #75;
	TxSetMaintDate = #76;
	RxSetMaintDate = RxAck;

	TxReqZGroup = #77;
	RxRetZGroup = #77;
	TxSetZGroup = #78;
	RxSetZGroup = RxAck;

	TxReqAL2Code = #79;
	RxRetAL2Code = #79;
	TxSetAL2Code = #80;
	RxSetAL2Code = RxAck;
	TxReqAL3Code = #81;
	RxRetAL3Code = #81;
	TxSetAL3Code = #82;
	RxSetAL3Code = RxAck;
	TxReqPhasedSettings = #83;
	RxRetPhasedSettings = #83;
	TxSetPhasedSettings = #84;
	RxSetPhasedSettings = RxAck;
	TxSetTimeDate = #85;
	RxSetTimeDate = RxAck;
	TxReqLoopType = #86;
	RxRetLoopType = #86;
	TxSetLoopType = #87;
	RxSetLoopType = RxAck;
	TxReqFaultLockoutTime = #88;
	RxRetFaultLockoutTime = #88;
	TxSetFaultLockoutTime = #89;
	RxSetFaultLockoutTime = RxAck;
	TxReqZoneTimers = #90;
	RxRetZoneTimers = #90;
	TxSetZoneTimers = #91;
	RxSetZoneTimers = RxAck;
	TxReqMainVersion = #92;
	RxRetMainVersion = #92;
	TxReqRepeaterName = #93;
	RxRetRepeaterName = #93;
	TxSetRepeaterName = #94;
	RxSetRepeaterName = RxAck;
	TxReqOutputName = #95;
	RxRetOutputName = #95;
	TxSetOutputName = #96;
	RxSetOutputName = RxAck;
	TxReqRepeaterFitted = #97;
	RxRetRepeaterFitted = #97;
	TxSetRepeaterFitted = #98;
	RxSetRepeaterFitted = RxAck;
	TxReqOutputFitted = #99;
	RxRetOutputFitted = #99;
	TxSetOutputFitted = #100;

	TxReqSegNo = #101;
	RxRetSegNo = #101;
	TxSetSegNo = #102;
	RxSetSegNo = RxAck;

	TxReqPanelName = #103;
	RxRetPanelName = #103;
	TxSetPanelName = #104;
	RxSetPanelName = RxAck;

	TxReqZoneSet = #105;
	RxRetZoneSet = #105;
	TxSetZoneSet = #106;
	RxSetZoneSet = RxAck;

	TxReqZoneNonFire = #107;
	RxRetZoneNonFire = #107;
	TxSetZoneNonFire = #108;
	RxSetZoneNonFire = RxAck;
	RxSetOutputFitted = RxAck;

	HandshakePacket = 'A' + #0 + 'A';

	Base_Year = 2000;
	VerifyError = 1;
	WriteError = 2;
	DataCommsTimeoutTime = 5000;         //in milliseconds
	RxTimeoutTime=700;                   //in milliseconds
	MAX_BUFFER_LENGTH = 60;

	{ These constants are used during to printing to represent true are false }
	TRUE_SYMBOL = 'O';
	FALSE_SYMBOL = ' ';
	PULSED_SYMBOL = '-';
	NON_FIRE_SYMBOL = 'x';

	INVALID_DEVICE = 0;

	NEW_VERSION = '08 00';


implementation

procedure Register;
begin
	RegisterComponents ('AFP', [TPanelComms]);
end;

{ TPanelComms }

procedure TPanelComms.EstablishHandshake;
begin
	{ Check to see if handshake signal is to be resent using current protocol }
	if (FCommsRetries > 0) then begin
		{ If so, then decrement the number of retries for this protocol and resend the
		handshake string }
		dec (FCommsRetries);
		SendString (ReqUpload + #0);
	end
	else begin
		{ If not, change the protocol then reset the number of retries.
		If last retry on last protocol, then flag comms error }
		FCommsRetries := 10;
		case FProtocolType of
			ppNew:
			begin
				FProtocolType := ppOld;
				EstablishComms;
				SendString (ReqUpload + #0);
			end;

			ppOld: { Change the protocol to old inverted, and try again }
			begin
				FProtocolType := ppOldInverted;
				EstablishComms;
				SendString (ReqUpload + #0);
			end;

			ppOldInverted:
			begin
				FCommsFault := true;
				FProtocolType := ppNone;
			end; { ppOldInverted }
		end; { Case FProtocol Type }
	end; { if number of retries is zero }
end;

procedure TPanelComms.FlushBuffers(inBuf, outBuf: Boolean);
begin
  fComPort1.FlushBuffers( inBuf, OutBuf );
end;

constructor TPanelComms.Create(AOwner: TComponent);
begin
	inherited;
	{ Initialise component for use with AFP Panel }
	AutoOpen := false;
	AutoAppendCR := false;

	{ Initialise protocol settings }
	FProtocolType := ppNone;
//	SetupString := 'COM1: 9600, n, 8, 1';
  Port := 1;
	BaudRate := br9600;
	DataBits := db8BITS;
	StopBits := sb1BITS;
	TickInterval := 100; { Set tick interval to be 100ms }
	FProtocolType := ppNone;
  IsASCIIOnly := FALSE;
end;

{ There are 4 possible protocol states: None, new, old, old inverted
	None - protocol not set
	New - 9600, N, 8, 1
	Old - 9600, S, 8, 1
	Old inverted - 9600, M, 8, 1

In the case of the old protocol, the parity refers to the parity of the first
character
}
procedure TPanelComms.EstablishComms;
begin
	{ If there is an active connection, close it before changing the protocol }
	if isOpen then CloseComms;

	CharsReceived := 0;
        FRxBuffer := '';


	{ If the comms status form is not showing, display it }
	{ Determine the previous protocol, then set up the comms for the new protocol }
	case FProtocolType of
		ppNew: { New protocol - no parity }
			begin
				{ Set up status form }
				Parity := ptNone;
				OpenComms;
			end;

		ppOld: { Old protocol - space parity for first character }
			begin
				Parity := ptSpace;
				OpenComms;
			end;

		ppOldInverted: { Old protocol inverted - mark parity for first character }
			begin
				Parity := ptMark;
				OpenComms;
			end;
	end;
end;

procedure TPanelComms.fOnReceiveData(Sender: TObject; DataPtr: Pointer;
	DataSize: integer);
var
	Data: Char;
	TmpPtr: PChar;
	TmpSize: integer;
	HandshakeString: string;
	PacketString: string;
begin
	TmpPtr := DataPtr;
	TmpSize := DataSize;
	if Assigned (fOnReceiveDataEvent) then fOnReceiveDataEvent (Sender, DataPtr, DataSize);
	while TmpSize > 0 do begin
		Data := Char (TmpPtr^);
		{ Only increment CharsReceived if the first character received is not an ACK
		or an NAK. This is to prevent it registering as a packet, since no packet will
		begin with either of these 2 characters, and thus it will prevent invalid
		checksums also }

   if IsASCIIOnly = FALSE then
   begin
    if CharsReceived = 0 then
    begin
      if ( (Data <> #6) and (Data <> #21) ) then
      begin
  			inc (CharsReceived);
  			{ Add character to receive buffer }
	  		FRxBuffer := FRxBuffer + Data;
      end;
    end else
    begin
 			inc (CharsReceived);
			{ Add character to receive buffer }
  		FRxBuffer := FRxBuffer + Data;
    end;

		{ Determine the length }
		{ If current byte is length byte, store length of data }
		if CharsReceived = 2 then begin
			FDataLength := Ord (Data);
		end
		{ The packet length is defined as 3 + length of data, which is stored in the
		2nd byte.  Packet structure is [Cmd][DataLength]<data>[Checksum] }
		else if CharsReceived >= FDataLength + 3 then begin
			{ If checksum character received, see if it is valid }
			if ValidateChecksum (Data) then begin
				{ If it is valid, check to see if handshaking has been established }
				if (not HandshakeReceived) then begin
					HandshakeString := RetUpload + #0 + RetUpload;
					if (FRxBuffer = HandshakeString) then begin
						ReceivedHandshake;
					end
					else if not FCommsFault then begin
						{ If invalid data received, change old protocol }
						EstablishHandshake;
					end;
				end;
				{ Generate the OnPacketReceived event, and the string to pass to it }
				PacketString := Copy (FRxBuffer, 1, FDataLength + 3);
				{ Disable the comms time-out }
				fComport1.EnableTimeout := false;
				if Assigned (FOnPacketReceived) then
					FOnPacketReceived (Self, RxBuffer[1], PacketString);
			end
			{ If checksum is not valid, handle any special processing }
			else begin
				if not HandshakeReceived then EstablishHandshake
				else if Assigned (FOnInvalidChecksum) then FOnInvalidChecksum (Self);
			end; { if checksum is valid }
			{ Reset the number of characters received }
			CharsReceived := 0;
			FRxBuffer := '';
      Buffer := '';
      Text := '';
		end; {if Checksum character received }

		{ If handshake has been deteremined, and the panel receives a handshake signal,
		ignore it }
		if FHandshakeReceived and (FRxBuffer = HandshakePacket) then begin
			FRxBuffer := '';
			CharsReceived := 0;
		end;

  end;
		{ Handle the On Character event for each character}
		if Assigned (fOnCharacter) then fOnCharacter (Self, Data);

{ note this following block of code is badly positioned, in that it will interpret ANY
 occurrence of the characters its looking for, regardless of where they appear, even if
 they form  a valid part of a packet of data}
//   if CharsReceived = 0 then begin
		case Data of
			{Ack received}
			Chr(6):
				begin
					{Ensure the ack character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the ack character into readable text}
					fText := fText + '<ACK>';
					{ Handle the OnInput and OnAck events}
					if Assigned (fOnInput) then fOnInput (Self,Buffer);
          if CharsReceived = 0 then
					  if Assigned (fOnAck) then fOnAck (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
				end;

			Chr(13):
				begin
					{Ensure the CR character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the CR character into readable text}
					fText := fText + '<CR>';
					{Handle the OnInput and OnCR events}
					if Assigned (fOnInput) then fOnInput (Self, Buffer);
					if Assigned (fOnCR) then fOnCR (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
				end;

			Chr(21):
				begin
					{Ensure the NAK character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the NAK character into readable text}
					fText := fText + '<NAK>';
					{Handle the OnInput and OnNak events}
					if Assigned (fOnInput) then fOnInput (Self, Buffer);
          if CharsReceived = 0 then
					  if Assigned (fOnNak) then fOnNak (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
				end;
		else
			{Otherwise place the next character into the string}
 	    fBuffer := fBuffer + Data;
	    fText := fText + Data;
		end;
//  end;
		{Point to the next character}
		inc (TmpPtr);
		dec (TmpSize);
	end; {while still characters to process}
end;


procedure TPanelComms.ClearASCIIBuffer;
begin
     fBuffer := '';
     fText := '';
end;

procedure TPanelComms.fOnTick(Sender: TObject);
begin
	if FCancel then Exit;
	{ If cancel has been set, ignore the OnTick event }
	if not (HandshakeReceived or CommsFault) then
  begin
		{ If the protocol type is none, then that siginifies that it is at the start
		of the handshaking procedure. First try the new protocol, and send the
		handshake signal to the AFP }
		if FProtocolType = ppNone then
    begin
			FProtocolType := ppNew;
			{ New style protocol involves listening only }
			FCommsRetries := 10;	{ This is 3 seconds }
			EstablishComms;
			SendString (ReqUpload + #0);
		end;
	end; { if comms is not established }
	{ Handle the OnTick event normally if there has been no fault with comms }
	if Assigned (fOnTickEvent) then
  begin
    fOnTickEvent (Self);
  end;
end;

{
function TPanelComms.GetComPortBaudRate: tBaudRate;
begin
  Result := BaudRate;
end;
}

//function TPanelComms.GetComPortDataBits: TDataBits;
//begin
//  Result := DataBits;
//end;

function TPanelComms.GetHwHandshaking: THwHandshaking;
begin
  Result := fComPort1.HwHandshaking;
end;

{
function TPanelComms.GetComPortStopBits: TStopBits;
begin
  Result := StopBits;
end;
}

function TPanelComms.GetSwHandshaking: TSwHandshaking;
begin
  Result := fComPort1.SwHandshaking;
end;

function TPanelComms.GetOutputTimeout: Dword;
begin
  Result := fComPort1.OutputTimeout;
end;

procedure TPanelComms.fOnInputTimeoutEvent(Sender: TObject);
begin
	{ This procedure is used to intercept the OnTimeout procedure. This is
	necessary for the handling of the handshaking process. Otherwise, it will
	pass on the OnTimeout procedure for normal operation }
	if not (HandshakeReceived or CommsFault ) then begin
		{ Since no handshake has been received and the comms has timed out, then
		change the protocol, and retry }
		EstablishHandshake;
	end
	else if Assigned (fOnTimeout) then fOnTimeout (Self);
end;

procedure TPanelComms.Loaded;
begin
	inherited;
	{ Set up special handling to hide the handshaking procedure. 3 Events are used:
	OnTick, OnReceiveData, OnInputTimeout }
	fComPort1.OnTick := fOnTick;
	fComPort1.OnInputTimeout := fOnInputTimeoutEvent;
	fComPort1.OnReceiveData := fOnReceiveData;

  fComport1.OnReceiveData := fOnReceiveData;
  fComport1.OnOutputTimeout := FOnOutputTimeout;
end;

procedure TPanelComms.ReceivedHandshake;
begin
	FHandshakeReceived := true;
	FCommsRetries := 50;
	if Assigned (FOnHandshakeReceived) then
		FOnHandshakeReceived (Self);
end;

{ This procedure sends the passed string to the AFP Panel. The checksum is calculated
and appended to the string. This procedure will also determine the parity which the
string is to be sent, and if it is the new protocol, it will prepend an SOH character }
procedure TPanelComms.SendString(Data: string);
var
	Checksum: integer;
	Count: integer;
//	lpOverlapped: POverlapped;
//	dwEventMask: DWord;
	s: string;
begin
	{ Determine the checksum }
	Checksum := 0;
	for count := 1 to length(Data) do
  begin
		Checksum := Checksum + ord(Data[Count]);
  end;

	{ Append the checksum to the data }
	Data := Data + chr (Checksum mod 256);

	{ Determine the protocol that will be used in during communication }
	case FProtocolType of
		ppNew:
    begin
      CharsReceived := 0;
      Text := SOH + Data;
    end;
		ppOld:
		begin
      { First character is sent at space parity, the rest of the string is sent
				using mark parity }
      TxDelay;
			Parity := ptSpace;
      //				lpOverlapped := nil;
      { Set the event so it will await for Tx empty }
      SetCommMask (fComport1.ComHandle, EV_TXEMPTY);
      Text := Data[1];
      //				WaitCommEvent (Comport1.ComHandle, dwEventMask, lpOverlapped);
      TxDelay;
      { Change the parity }
      Parity := ptMark;
      { Send the rest of the data and wait for the last character to be transmitted }
      SetCommMask (fComport1.ComHandle, EV_TXEMPTY);
      Text := Copy (Data, 2, Length (Data) - 1);
      //				WaitCommEvent (Comport1.ComHandle, dwEventMask, lpOverlapped);
    end;
		ppOldInverted:
    begin
      { First character is sent at space parity, the rest of the string is sent
				using mark parity }
      TxDelay;

 			Parity := ptMark;
      //				lpOverlapped := nil;
			{ Set the event so it will await for Tx empty }
			SetCommMask (fComport1.ComHandle, EV_TXEMPTY);
			S := Data[1];
			Text := s;
      //				WaitCommEvent (Comport1.ComHandle, dwEventMask, lpOverlapped);

      TxDelay;
			{ Change the parity }
			Parity := ptSpace;

			{ Send the rest of the data and wait for the last character to be transmitted }
			SetCommMask (fComport1.ComHandle, EV_TXEMPTY);
			S := Copy (Data, 2, Length (Data) - 1);
			Text := s;
      //				WaitCommEvent (Comport1.ComHandle, dwEventMask, lpOverlapped);
    end;
	end;
end;

procedure TPanelComms.SetBuffer(const Value: string);
var
  iString : string;
begin
  iString := Value;
	if AutoAppendCR then iString := iString + Chr(13);
	if Assigned( fOnOutPut ) then fOnOutput( self,
		MakeTextReadable( iString ));
	fComPort1.SendString (iString);
end;

{
procedure TPanelComms.SetComPortBaudRate(const Value: tBaudRate);
begin
  BaudRate := Value;
end;
}

{
procedure TPanelComms.SetComPortDataBits(const Value: TDataBits);
begin
  DataBits := Value;
end;
}

procedure TPanelComms.SetHwHandshaking(
  const Value: THwHandshaking);
begin
  fComPort1.HwHandshaking := Value;
end;

{
procedure TPanelComms.SetComPortStopBits(const Value: TStopBits);
begin
  StopBits := Value;
end;
}

procedure TPanelComms.SetSwHandshaking( const Value: TSwHandshaking);
begin
  fComPort1.SwHandshaking := Value;
end;

procedure TPanelComms.SetOutputTimeout(const Value: Dword);
begin
	fComport1.OutputTimeout := Value;
end;

procedure TPanelComms.SetText(const Value: string);
var
  iString : string;
begin
  iString := Value;
	if Assigned( fOnOutPut ) then
  begin
    fOnOutput( self, MakeTextReadable( iString ));
  end;
	if AutoAppendCR then
  begin
    iString := iString + Chr(13);
  end;
	fComPort1.SendString (iString);
end;

Procedure TPanelComms.TxDelay;
Var
//   Counter : LongInt;
//   D2ms : Longint;
   Hour, Min, Sec, MSec: Word;
   LastMSec : word;
   Elapsed : Smallint;
   Present : TDateTime;
Begin

       Present:= Now;
       DecodeTime(Present, Hour, Min, Sec, MSec);
       LastMSec:=MSec;
       Elapsed:=0;
       While (Elapsed < 50 ) do
       Begin
          Present:= Now;
          DecodeTime(Present, Hour, Min, Sec, MSec);
          Elapsed:=MSec-LastMSec;
          if Elapsed < 0 then Elapsed:=Elapsed+1000;
          Application.ProcessMessages;
       End;
End;

function TPanelComms.ValidateChecksum(Checksum: Char): Boolean;
var
	 BuffPointer : Word;
   DataLength : Word;
	 CalcChecksum : integer;
	 RxdChecksum : byte;
	 RxdChar: Byte;
begin

	{ If FRxBuffer is an invalid length, return false }
	if Length (FRxBuffer) < 3 then begin
		Result := false;
		exit;
	end;


	{ Determine the data length. The position varies depending upon whether the
	new protocol is used, or the old protocol }
	case FProtocolType of
		ppNew: DataLength := Ord (FRxBuffer[2]);
		ppOld, ppOldInverted: DataLength := Ord (FRxBuffer[2]);
	else
		{ otherwise assume that no data has been passed }
		DataLength := 0;
	end;
	BuffPointer := 1;
	CalcChecksum := 0;

	{ Calculate the checksum from the RxBuffer }
	try
		while BuffPointer < (DataLength + 3) do
		begin
			RxdChar := Ord (FRxBuffer[BuffPointer]);
			CalcChecksum := CalcChecksum + RxdChar;
			inc (BuffPointer);
		end;
		{ Obtain the Checksum from the RxBuffer }
		RxdChecksum := ord(FRxBuffer[BuffPointer]);
		{ Compare the calculate and received checksums. If they match, return true otherwise
		return false }
		Result := (RxdChecksum = (CalcChecksum mod 256))
	except
		{ If this fails for any reason, return an invalid checksum.  The most common
		reason for failure is incorrect number of bytes }
		Result := false;
	end;
end;


end.
