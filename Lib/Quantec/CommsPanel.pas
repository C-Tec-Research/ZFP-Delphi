unit commspanel;
{
********************************************************************************
v1.2 - 27th Jan 2000 - Modified AD
	1. Fixed: On timer action, if the time-outs are to be enabled, ensure that the
		enable time-out flag is set to true so that future time-outs can occur.
********************************************************************************

********************************************************************************
v1.1 - Modified AD
	1. Added: OnCharacter event.
********************************************************************************
}

interface

uses
  SysUtils, Windows, Classes, ExtCtrls, Common, SigComPort;

type
  TNotifyOnTransferEvent = procedure(Sender: TObject;
							  ConvertedString : string ) of object;

  // Added by AD
  TNotifyOnCharacter = procedure(Sender: TObject; Character: Char) of object;

type
	TCommPanel = class(TPanel)
  private
	 { Private declarations }

  protected
	 { Protected declarations }
	 ComPort1 : TSigComPort; { Comms }
	 { variables used for properties }
	 fSetupString: string;	{ string holding parameters to setup COM port}
	 fAutoOpen: Boolean;		{ Comport automatically opened on load}
	 fAutoAppendCR: Boolean;	{ CR automatically appended to string sent to COM port }
	 fText: string;	{ returned string, with special characters converted }
	 fBuffer: string;	{ returned string, with special characters unconverted }
	 fInputTimeout: Word; {Timeout value}
	 fOnTick : TNotifyEvent; { every timer tick }
	 fOnCreate : TNotifyEvent;
	 fOnTimeOut : TNotifyEvent; { whenever a time out occurs }
	 fOnCR : TNotifyEvent; { every CR }
	 fOnAck : TNotifyEvent; { every ACK }
	 fOnNak : TNotifyEvent; { every NACK }
	 fOnCharacter : TNotifyOnCharacter; { every character - Added by AD}
	 fOnOutput : TNotifyOnTransferEvent; {every string sent }
	 fOnInput : TNotifyOnTransferEvent; {every string sent }
	 fOnOutputTimeout: TNotifyEvent;  { Output time out event }
	 fOnReceiveDataEvent: TComportReceiveDataEvent; { On receive data event }
	 procedure fOnReceiveData (Sender: TObject; DataPtr: Pointer; DataSize: integer);
//	 procedure fOnInputTimeout (Sender: TObject);
	 function fIsOpen : boolean; virtual;
	 function fCheckStat : boolean; virtual;
	 function fIsTimedOut: Boolean;
	 procedure fWriteSetupString( SetupString : string ); virtual;
	 function fReadSendBufferSize : integer; virtual;
	 procedure fWriteSendBufferSize (Value: integer); virtual;
	 function fReadRcvBufferSize : integer; virtual;
	 procedure fWriteRcvBufferSize (Value: integer); virtual;
	 function fStatus : integer; virtual;
	 procedure fWriteText( Value : string ); virtual;
	 procedure fWriteBuffer( Value : string ); virtual;
	 function fReadCheckInterval : Word; virtual;
	 procedure fWriteCheckInterval(const Value : Word ); virtual;
	 function fReadEnableTimeOut : boolean; virtual;
	 procedure fWriteEnableTimeOut( Value : boolean ); virtual;
	 function fReadInputTimeout: Dword;
	 procedure fWriteInputTimeout (Value: Dword);
	 function fReadOutputTimeout: Dword;
	 procedure fWriteOutputTimeout (Value: Dword);
	 function fGetTimeout: Dword;
	 procedure fSetTimeout (Value: Dword);

	 { Functions used to get/set up COM port}
	 function GetComPort: TComPortNumber;
	 function GetComPortBaudRate: TBaudRate;
	 function GetComPortDataBits: TDataBits;
	 function GetComPortHwHandshaking: THwHandshaking;
	 function GetComPortParity: TParity;
	 function GetComPortStopBits: TStopBits;
	 function GetComPortSwHandshaking: TSwHandshaking;
	 procedure SetComPort(const Value: TComPortNumber);
	 procedure SetComPortBaudRate(const Value: TBaudRate);
	 procedure SetComPortDataBits(const Value: TDataBits);
	 procedure SetComPortHwHandshaking(const Value: THwHandshaking);
	 procedure SetComPortParity(const Value: TParity);
	 procedure SetComPortStopBits(const Value: TStopBits);
	 procedure SetComPortSwHandshaking(const Value: TSwHandshaking);
	 { to allow auto-open }
	 procedure Loaded; override;
  public
	 { Public declarations }
	 constructor Create( AOwner: TComponent ) ; override;
	 destructor Destroy; override;
	 procedure CloseComms;
	 function OpenComms : boolean;
	 procedure FlushBuffers (inBuf, outBuf: Boolean);
         procedure SetRTS;
         procedure SetDTR;
	 property IsOpen : boolean
				 read fIsOpen;
	 property IsOK : boolean
				 read fCheckStat;
	 property Text : string
				 read fText
				 write fWriteText;
	 property Buffer : string
				 read fBuffer
				 write fWriteBuffer;
	 property IsTimedOut : boolean
				 read fIsTimedOut;
	 property EnableTimeOut : boolean
				 read fReadEnableTimeOut
				 write fWriteEnableTimeOut;
	 property Status : integer
				 read fStatus;

  published
	 { Published declarations }
	 property SetupString : string
				 read fSetupString
				 write fWriteSetupString;
	 property SendBufferSize : integer
				 read fReadSendBufferSize
				 write fWriteSendBufferSize;
	 property RcvBufferSize : integer
				 read fReadRcvBufferSize
				 write fWriteRcvBufferSize;
	 property TickInterval : Word
				 read fReadCheckInterval
             write fWriteCheckInterval;
	 property AutoOpen : boolean
				 read fAutoOpen
				 write fAutoOpen;
    property AutoAppendCR : boolean
				 read fAutoAppendCR
				 write fAutoAppendCR;
	 property TimeOut : Dword
				 read fGetTimeOut
				 write fSetTimeOut;
	 property InputTimeOut: Dword
				 read fReadInputTimeout
				 write fWriteInputTimeout;
	 property OutputTimeout: Dword
				 read fReadOutputTimeout
				 write fWriteOutputTimeout;
	 property OnTick : TNotifyEvent
				 read fOnTick
				 write fOnTick;
	 property OnInput : TNotifyOnTransferEvent
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
	 property OnOutput : TNotifyOnTransferEvent
				 read fOnOutput
				 write fOnOutput;
	 property OnCreate : TNotifyEvent
				 read fOnCreate
				 write fOnCreate;
	 property OnTimeOut : TNotifyEvent
				 read fOnTimeOut
				 write fOnTimeOut;
	 property OnCharacter : TNotifyOnCharacter // Added by AD
				 read fOnCharacter
				 write fOnCharacter;
	 property OnOutputTimeout: TNotifyEvent // Output time out event
				 read fOnOutputTimeout
				 write fOnoutputTimeout;
	 property OnReceiveData :TComportReceiveDataEvent
				 read fOnReceiveDataEvent
				 write fOnReceiveDataEvent;
	 property ComPort: TComPortNumber read GetComPort write SetComPort;
	 // COM Port speed (bauds)
	 property ComPortSpeed: TBaudRate read GetComPortBaudRate write SetComPortBaudRate;
	 // Data bits to used (5..8, for the 8250 the use of 5 data bits with 2 stop bits is an invalid combination,
	 // as is 6, 7, or 8 data bits with 1.5 stop bits)
	 property ComPortDataBits: TDataBits read GetComPortDataBits write SetComPortDataBits;
	 // Stop bits to use (1, 1.5, 2)
	 property ComPortStopBits: TStopBits read GetComPortStopBits write SetComPortStopBits;
	 // Parity Type to use (none,odd,even,mark,space)
	 property ComPortParity: TParity read GetComPortParity write SetComPortParity;
	 // Hardware Handshaking Type to use:
	 //  cdNONE          no handshaking
	 //  cdCTSRTS        both cdCTS and cdRTS apply (** this is the more common method**)
	 property ComPortHwHandshaking: THwHandshaking
				 read GetComPortHwHandshaking write SetComPortHwHandshaking;
	 // Software Handshaking Type to use:
	 //  cdNONE          no handshaking
	 //  cdXONXOFF       XON/XOFF handshaking
	 property ComPortSwHandshaking: TSwHandshaking
				 read GetComPortSwHandshaking write SetComPortSwHandshaking;

  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

procedure Register;
begin
  RegisterComponents('AFP', [TCommPanel]);
end;

constructor TCommPanel.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  ComPort1 := TSigComPort.Create( self );
  SetupString := 'COM1: 9600, e, 7, 1';
  AutoAppendCR := true;
  AutoOpen := true;
  if (not (csDesigning in ComponentState ))
	  and Assigned( fOnCreate ) then fOnCreate( self );
end;

procedure TCommPanel.fOnReceiveData (Sender: TObject; DataPtr: Pointer; DataSize: integer);
var
	Data: Char;
	TmpPtr: PChar;
	TmpSize: integer;
begin
	TmpPtr := DataPtr;
	TmpSize := DataSize;
	if Assigned (fOnReceiveDataEvent) then fOnReceiveDataEvent (Sender, DataPtr, DataSize);
	while TmpSize > 0 do begin
		{ Handle the On Character event for each character}
    {$WARNINGS OFF}
		Data := Char (TmpPtr^);
    {$WARNINGS ON}
		if Assigned (fOnCharacter) then fOnCharacter (Self, Data);
		case Data of
			{Ack received}
			Chr(6):
				begin
					{Ensure the ack character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the ack character into readable text}
					fText := fText + '<ACK>';
					{ Handle the OnInput and OnAck events}
					if Assigned (fOnInput) then fOnInput (Self, Text);
					if Assigned (fOnAck) then fOnAck (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
					{ Disable the comms time-out }
					Comport1.EnableTimeout := false;
				end;

			Chr(13):
				begin
					{Ensure the CR character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the CR character into readable text}
					fText := fText + '<CR>';
					{Handle the OnInput and OnCR events}
					if Assigned (fOnInput) then fOnInput (Self, Text);
					if Assigned (fOnCR) then fOnCR (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
					{ Disable the comms time-out }
					Comport1.EnableTimeout := false;
				end;

			Chr(21):
				begin
					{Ensure the NAK character is in the buffer}
					fBuffer := fBuffer + Data;
					{Convert the NAK character into readable text}
					fText := fText + '<NAK>';
					{Handle the OnInput and OnNak events}
					if Assigned (fOnInput) then fOnInput (Self, Text);
					if Assigned (fOnNak) then fOnNak (Self);
					{Since the events are handled, now prepare for the next string}
					fText := '';
					fBuffer := '';
					{ Disable the comms time-out }
					Comport1.EnableTimeout := false;
				end;
		else
			{Otherwise place the next character into the string}
			fBuffer := fBuffer + Data;
			fText := fText + Data;
		end;
		{Point to the next character}
		inc (TmpPtr);
		dec (TmpSize);
	end; {while still characters to process}
end;

procedure TCommPanel.Loaded;
begin
  { call inherited Loaded }
  inherited Loaded;
  { set ComPort Values }
  Comport1.OnReceiveData := fOnReceiveData;
  Comport1.OnInputTimeout := FOnTimeout;
  Comport1.OnOutputTimeout := FOnOutputTimeout;
  Comport1.OnTick := fOnTick;
  if not (csDesigning in ComponentState) and fAutoOpen and isOK then OpenComms;
end;

destructor TCommPanel.Destroy;
begin
	ComPort1.Free;
	inherited Destroy;
end;

procedure TCommPanel.CloseComms;
begin
	ComPort1.Disconnect;
	{ Now disable the timeout since the comms have been closed }
	EnableTimeout := false;
end;

procedure TCommPanel.FlushBuffers (inBuf, outBuf: Boolean);
begin
	Comport1.FlushBuffers (inBuf, outBuf);
end;

function TCommPanel.OpenComms : boolean;
begin
  Result := ComPort1.Connect;
end;

procedure TCommPanel.fWriteSetupString( SetupString : string );
var
	ComportPart: array [1..5] of string;
	PartNo: integer;
	i: integer;
	Part: string;
	PartInc: Boolean;
begin
	// Store the setup string
	fSetupString := SetupString;
	// Now deconstruct setup string to set up COM port
	PartNo := 1;
	PartInc := false;
	// Acquire component parts
	for i := 1 to Length (SetupString) do begin
		if ((SetupString[i] = ',') or (SetupString[i] = ' ' )) and not PartInc then begin
			inc (PartNo);
			PartInc := true;
		end
		else begin
			ComportPart[PartNo] := ComportPart[PartNo] + SetupString[i];
			PartInc := false;
		end;
	end;

	// Acquire the com port
	Part := Uppercase (ComportPart[1]);
	if Part = 'COM1:' then ComPort := pnCOM1
	else if Part = 'COM2:' then Comport := pnCOM2
	else if Part = 'COM3:' then Comport := pnCOM3
	else if Part = 'COM4:' then Comport := pnCOM4;

	// Acquire the baud rate
	Part := ComportPart[2];
	if Part = '110' then ComportSpeed := br110
	else if Part = '300' then ComportSpeed := br300
	else if Part = '600' then ComportSpeed := br600
	else if Part = '1200' then ComportSpeed := br1200
	else if Part = '2400' then ComportSpeed := br2400
	else if Part = '4800' then ComportSpeed := br4800
	else if Part = '9600' then ComportSpeed := br9600
	else if Part = '14400' then ComportSpeed := br14400
	else if Part = '19200' then ComportSpeed := br19200
	else if Part = '38400' then ComportSpeed := br38400
	else if Part = '56000' then ComportSpeed := br56000
	else if Part = '57600' then ComportSpeed := br57600
	else if Part = '115200' then ComportSpeed := br115200;

	// Acquire the parity
	Part := Lowercase (ComportPart[3]);
	if (Part = 'n') or (Part = 'none') then ComportParity := ptNONE
	else if (Part = 'o') or (Part = 'odd') then ComportParity := ptODD
	else if (Part = 'e') or (Part = 'even') then ComportParity := ptEVEN
	else if (Part = 'm') or (Part = 'mark') then ComportParity := ptMARK
	else if (Part = 's') or (Part = 'space') then ComportParity := ptSPACE;

	// Acquire the data bits
	Part := ComportPart[4];
	if Part = '5' then ComportDataBits := db5BITS
	else if Part = '6' then ComportDataBits := db6BITS
	else if Part = '7' then ComportDataBits := db7BITS
	else if Part = '8' then ComportDataBits := db8BITS;

	// Acquire the stop bits
	Part := ComportPart[5];
	if Part = '1' then ComportStopBits := sb1BITS
	else if Part = '2' then ComportStopBits := sb2BITS;
end;

function TCommPanel.fReadSendBufferSize : integer;
begin
  Result := ComPort1.ComPortOutBufSize;
end;

procedure TCommPanel.fWriteSendBufferSize( Value : integer );
begin
  ComPort1.ComportOutBufSize := Value;
end;

function TCommPanel.fReadRcvBufferSize : integer;
begin
  Result := ComPort1.ComportInBufSize;
end;

procedure TCommPanel.fWriteRcvBufferSize( Value : integer );
begin
  ComPort1.ComportInBufSize := Value;
end;

function TCommPanel.fIsOpen : boolean;
begin
  Result := ComPort1.Connected;
end;


function TCommPanel.fCheckStat : boolean;
begin
  Result := (ComPort1.ComHandle <> INVALID_HANDLE_VALUE);
end;

function TCommPanel.fStatus : integer;
begin
  Result := ComPort1.Status;
end;

procedure TCommPanel.fWriteText( Value : string );
begin
	if Assigned( fOnOutPut ) then fOnOutput( self,
		MakeTextReadable( Value ));
	if AutoAppendCR then Value := Value + Chr(13);
	ComPort1.SendString (Value);
end;

procedure TCommPanel.fWriteBuffer( Value : string );
begin
	if AutoAppendCR then Value := Value + Chr(13);
	if Assigned( fOnOutPut ) then fOnOutput( self,
		MakeTextReadable( Value ));
	ComPort1.SendString (Value);
end;

function TCommPanel.fReadCheckInterval : Word;
begin
  Result := Comport1.ComPortPollingDelay;
end;

procedure TCommPanel.fWriteCheckInterval(const Value : Word );
begin
	Comport1.ComPortPollingDelay := Value;
end;

function TCommPanel.GetComPort: TComPortNumber;
begin
	Result := Comport1.Comport;
end;

function TCommPanel.GetComPortBaudRate: TBaudRate;
begin
	Result := Comport1.BaudRate;
end;

function TCommPanel.GetComPortDataBits: TDataBits;
begin
	Result := Comport1.DataBits;
end;

function TCommPanel.GetComPortHwHandshaking: THwHandshaking;
begin
	Result := Comport1.HWHandshaking;
end;

function TCommPanel.GetComPortParity: TParity;
begin
	Result := Comport1.Parity;
end;

function TCommPanel.GetComPortStopBits: TStopBits;
begin
	Result := Comport1.StopBits;
end;

function TCommPanel.GetComPortSwHandshaking: TSwHandshaking;
begin
	Result := Comport1.SWHandshaking;
end;

procedure TCommPanel.SetComPort(const Value: TComPortNumber);
begin
	Comport1.Comport := Value;
end;

procedure TCommPanel.SetComPortBaudRate(const Value: TBaudRate);
begin
	Comport1.BaudRate := Value;
end;

procedure TCommPanel.SetComPortDataBits(const Value: TDataBits);
begin
	Comport1.DataBits := Value;
end;

procedure TCommPanel.SetComPortHwHandshaking(
  const Value: THwHandshaking);
begin
	Comport1.HWHandshaking := Value;
end;

procedure TCommPanel.SetDTR;
begin
	Comport1.ToggleDTR(TRUE);
end;

procedure TCommPanel.SetRTS;
begin
	Comport1.ToggleRTS(TRUE);
end;


procedure TCommPanel.SetComPortParity(const Value: TParity);
begin
	Comport1.Parity := Value;
end;

procedure TCommPanel.SetComPortStopBits(const Value: TStopBits);
begin
	Comport1.StopBits := Value;
end;

procedure TCommPanel.SetComPortSwHandshaking(
  const Value: TSwHandshaking);
begin
	Comport1.SWHandshaking := Value;
end;

function TCommPanel.fReadEnableTimeOut : boolean;
begin
	Result := Comport1.EnableTimeout;
end;

procedure TCommPanel.fWriteEnableTimeOut( Value : boolean );
begin
	Comport1.EnableTimeout := Value;
end;

function TCommPanel.fReadInputTimeout: Dword;
begin
	Result := Comport1.InputTimeout;
end;

procedure TCommPanel.fWriteInputTimeout (Value: Dword);
begin
	Comport1.InputTimeout := Value;
end;

function TCommPanel.fReadOutputTimeout: Dword;
begin
	Result := Comport1.OutputTimeout;
end;

procedure TCommPanel.fWriteOutputTimeout (Value: Dword);
begin
	Comport1.OutputTimeout := Value;
end;

function TCommPanel.fGetTimeout: Dword;
begin
	Result := InputTimeout div TickInterval;
end;

procedure TCommPanel.fSetTimeout (Value: Dword);
begin
	InputTimeout := Value * TickInterval;
end;

function TCommPanel.fIsTimedOut: Boolean;
begin
	Result := Comport1.IsTimedOut;
end;

end.
