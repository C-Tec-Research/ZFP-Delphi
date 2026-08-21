unit Companel;

interface

{
  Notes
    Acts as a serial interface via a visual panel

    If a timeout occurs, Enable Timeout must be set to TRUE before
    any further timeouts are allowed.

    Now moved to use SigComPanel to reduce proliferation of objects doing
    same job.

    Timer object removed (because SigComPort has its own timer function)
    but tick interval etc. must now be done by ComPane for
    compatibility reasons.
}

uses
  SysUtils,
  WinTypes,
  WinProcs,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  SigComPort,
  Common;

type
  TNotifyOnTransferEvent = procedure(Sender: TObject;
                       ConvertedString : string ) of object;

  // Added by AD
  TNotifyOnCharacter = procedure(Sender: TObject; Character: Char) of object;

type
  TCommsPanel = class(TPanel)
  private
    fTickInterval: Word;
    fTickValue : Word;
    fCharMode: boolean;
    function GetComPort: TComPortNumber;
    procedure SetComPort(const Value: TComPortNumber);
    function GetInputTimeOut: LongInt;
    procedure SetInputTimeOut(const Value: LongInt);
    procedure SetParityAsString(const Value: string);
//    function GetOnTick: TNotifyEvent;
    function GetOnTimeOut: TNotifyEvent;
    function GetTimeOut: LongInt;
    procedure SetOnTick(const Value: TNotifyEvent);
    procedure SetOnTimeOut(const Value: TNotifyEvent);
    procedure SetTimeOut(const Value: LongInt);
    function GetPort: integer;
    function GetStopBits: tStopbits;
    function GetDataBits: tDataBits;
//    function GetOnCharacter: TNotifyOnCharacter;
//    procedure SetOnCharacter(const Value: TNotifyOnCharacter);
    procedure fOnCharacterInput(Sender: TObject; pChar : char);
    procedure SetStopBits(const Value: tStopbits);
    function GetDataBitsAsInt: integer;
    procedure SetDataBitsAsInt(const Value: integer);
    procedure SetDataBits(const Value: tDataBits);
    function GetBaudRate: tBaudRate;
    procedure SetBaudRate(const Value: tBaudRate);
    procedure SetPort(const Value: integer);
    { Private declarations }
    function GetIsTimedOut : boolean;

    procedure fInterceptedOnTick( Sender : tObject );
    function GetOnOpen: tNotifyEvent;
    procedure SetOnOpen(const Value: tNotifyEvent);
    function GetOnClose: tNotifyEvent;
    procedure SetOnClose(const Value: tNotifyEvent);

  protected
    { Protected declarations }
    fComPort1 : TSigComPort; { Comms }
//    fTimer1 : TTimer;

//    fTimeOut : LongInt ; { in Ticks }
//    fTimeOutValue : LongInt ; {current Value }

    fOnTick : TNotifyEvent; { every timer tick }
    fOnCreate : TNotifyEvent;
//    fOnTimeOut : TNotifyEvent; { whenever a time out occurs }

    fOnCR : TNotifyEvent; { every CR }
    fOnAck : TNotifyEvent; { every ACK }
    fOnNak : TNotifyEvent; { every NACK }

    fOnCharacter : TNotifyOnCharacter; { every character - Added by AD}

    fOnOutput : TNotifyOnTransferEvent; {every string sent }
    fOnInput : TNotifyOnTransferEvent; {every string sent }

    procedure InternalOnAck(Sender: TObject); virtual;
    procedure InternalOnNak(Sender: TObject); virtual;

    { to allow auto-open }
    procedure Loaded; override;

    { internals - mostly mapping to TComPort component }
    procedure InternalTimerAction (Sender: TObject); virtual;

    function GetSetupString : string; virtual;
    procedure SetSetupString( pSetupString : string ); virtual;

    function GetSendBufferSize : integer; virtual;
    procedure SetSendBufferSize( SendBufferSize : integer ); virtual;

    function GetRcvBufferSize : integer; virtual;
    procedure SetRcvBufferSize( RcvBufferSize : integer ); virtual;

    function GetIsOpen : boolean; virtual;
    procedure SetIsOpen( Value : boolean ); virtual;

    function GetIsOK : boolean; virtual;

    function GetStatus : string; virtual;

    function GetText : string; virtual;
    procedure SetText( const Value : string ); virtual;

    function GetBuffer : string; virtual;
    procedure SetBuffer(const Value : string ); virtual;

//    function GetTickInterval : Word; virtual;
    procedure SetTickInterval( Value : Word ); virtual;

    function GetAutoOpen : boolean; virtual;
    procedure SetAutoOpen( Value : boolean ); virtual;

    function GetAutoAppendCR : boolean; virtual;
    procedure SetAutoAppendCR( Value : boolean ); virtual;

    function GetEnableTimeOut : boolean; virtual;
    procedure SetEnableTimeOut( Value : boolean ); virtual;

    procedure fOnInputIndirect(Sender: TObject);
    //    procedure fOnCharacterInput(Sender: TObject); //Added by AD
    function GetParityAsString : string;
    function StopBitsAsString : string;
    function GetParity: tParity;
    procedure SetParity(const Value: tParity);
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ) ; override;
    destructor Destroy; override;
    procedure CloseComms;
    function OpenComms : boolean;
    property IsOpen : boolean
             read GetIsOpen
             write SetIsOpen;
    property IsOK : boolean
             read GetIsOK;
    property Text : string
             read GetText
             write SetText;
    property Buffer : string
             read GetBuffer
             write SetBuffer;
    property IsTimedOut : boolean
             read GetIsTimedOut;
{
    property TimeOutValue : LongInt
             read fTimeOutValue;
}
    property EnableTimeOut : boolean
             read GetEnableTimeOut
             write SetEnableTimeOut;
    property DataBitsAsInt : integer
             read GetDataBitsAsInt
             write SetDataBitsAsInt;
    property ParityAsString : string
             read GetParityAsString
             write SetParityAsString;
  published
    { Published declarations }
    property AutoAppendCR : boolean
             read GetAutoAppendCR
             write SetAutoAppendCR;
    property AutoOpen : boolean
             read GetAutoOpen
             write SetAutoOpen;
    property RcvBufferSize : integer
             read GetRcvBufferSize
             write SetRcvBufferSize;
    property SendBufferSize : integer
             read GetSendBufferSize
             write SetSendBufferSize;
    property SetupString : string
             read GetSetupString
             write SetSetupString;
    property Status : string
             read GetStatus;
    property TickInterval : Word
             read fTickInterval
             write SetTickInterval
             default 100;
    property TimeOut : LongInt
             read GetTimeOut
             write SetTimeOut
             default 30;
    property InputTimeOut : LongInt
             read GetInputTimeOut
             write SetInputTimeOut
             default 3000;
    property OnTick : TNotifyEvent
             read fOnTick
             write SetOnTick;
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
             read GetOnTimeOut
             write SetOnTimeOut;
    property OnInputTimeOut : TNotifyEvent
             read GetOnTimeOut
             write SetOnTimeOut;
    property OnCharacter : TNotifyOnCharacter // Added by AD
    			   read fOnCharacter
             write fOnCharacter;
    property Port : integer
             read GetPort
             write SetPort
             default 1;
    property ComPort : TComPortNumber
             read GetComPort
             write SetComPort
             default pnCOM1;
    property BaudRate : tBaudRate
             read GetBaudRate
             write SetBaudRate
             default br9600;
    property Parity : tParity
             read GetParity
             write SetParity
             default ptEven;
    property DataBits : tDataBits
             read GetDataBits
             write SetDataBits
             default db7Bits;
    property StopBits : tStopbits
             read GetStopBits
             write SetStopBits
             default sb1BITS;
    property OnOpen : tNotifyEvent
             read GetOnOpen
             write SetOnOpen;
    property OnClose : tNotifyEvent
             read GetOnClose
             write SetOnClose;
    property CharMode : boolean
             read fCharMode
             write fCharMode
             default FALSE;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TCommsPanel]);
end;

constructor TCommsPanel.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  fComPort1 := TSigComPort.Create( self );
//  fTimer1 := TTimer.Create( self );
  TickInterval := 100;
//  fTimer1.OnTimer := iTimerAction;
  TimeOut := 30;           { 30 ticks == 3 seconds }
  if (not (csDesigning in ComponentState ))
     and Assigned( fOnCreate ) then fOnCreate( self );
  Port := 1;
  BaudRate := br9600;
  DataBits := db7bits;
  Parity := ptEven;
  StopBits := sb1BITS;
  CharMode := FALSE;
end;

procedure TCommsPanel.fOnInputIndirect(Sender: TObject);
begin
  if Assigned( fOnInput ) then fOnInput( self,
     MakeTextReadable( fComport1.Buffer ));
end;

procedure TCommsPanel.fInterceptedOnTick(Sender: tObject);
begin
  inc( fTickValue );
  if fTickValue >= fTickInterval then
  begin
    InternalTimerAction( self );
    fTickValue := 0;
  end;
end;

procedure TCommsPanel.fOnCharacterInput(Sender: TObject; pChar : char);
begin
	if Assigned (fOnCharacter) then
  begin
   	fOnCharacter (Self, pChar);
    if CharMode then
    begin
      fComport1.Buffer; // clear buffer
    end;
  end;
//  fTimeOutValue := 0;
  case pChar of
    #6: // ACK
    begin
      InternalOnAck( self );
      if Assigned( fOnInput ) then
      begin
        fOnInput( self, MakeTextReadable( fComport1.Buffer ));
      end
      else
      begin
        fComport1.Buffer; // clear buffer
      end;
    end;
    #21: // NAK
    begin
      InternalOnNak( self );
      if Assigned( fOnInput ) then
      begin
        fOnInput( self, MakeTextReadable( fComport1.Buffer ));
      end
      else
      begin
        fComport1.Buffer; // clear buffer
      end;
    end;
    #13: // CR
    begin
      if assigned( fOnCR) then
      begin
        fOnCR( self );
      end;
      if Assigned( fOnInput ) then
      begin
        fOnInput( self, MakeTextReadable( fComport1.Buffer ));
      end
      else
      begin
        fComport1.Buffer; // clear buffer
      end;
    end;
  end;
end;

procedure TCommsPanel.Loaded;
begin
  { call inherited Loaded }
  inherited Loaded;
  { set ComPort Values }
  fComPort1.OnChar := fOnCharacterInput; //Added by AD
  { call embedded components Loaded functions }
  fComPort1.Loaded;
end;

destructor TCommsPanel.Destroy;
begin
//  fComPort1.Free; descendent of component - do not free
  inherited Destroy;
end;

procedure TCommsPanel.CloseComms;
begin
  fComPort1.CloseComms;
end;

function TCommsPanel.OpenComms : boolean;
begin
  Result := fComPort1.OpenComms;
end;

function TCommsPanel.GetParityAsString: string;
begin
  case fComPort1.Parity of
    ptNONE: Result := 'N';
    ptODD: Result := 'O';
    ptEVEN: Result := 'E';
    ptMARK: Result := 'M';  // made this up - there is no standard
    ptSPACE: Result := 'S'; // ditto
  end;
end;

function TCommsPanel.GetSetupString : string;
begin
  // Result := fComPort1.SetupString;
  Result := 'COM' + IntToStr( Port ) + ': ' + fComPort1.BaudRateAsString + ', '
         + ParityAsString + ', ' + IntToStr( DataBitsAsInt ) + ', '
         + StopBitsAsString;
end;

procedure TCommsPanel.SetSetupString( pSetupString : string );
var
  iPos : integer;
  iString : string;
begin
  // e.g. 'COM1: 9600, e, 7, 1'
  // remove spaces
  pSetupString := Trim( pSetupString );
  // first 3 chars chould be COM (not case sensitive)
  if not SameText( Copy( pSetupString, 1, 3), 'COM') then
  begin
    raise exception.Create('illegal Setup string');
  end;
  iPos := Pos( ':', pSetupString );
  if iPos < 5 then
  begin
    raise exception.Create('illegal Setup string');
  end;

  Port := StrToInt( Trim(Copy( pSetupString, 4, iPos - 4 )));

  pSetupString := Trim( Copy( pSetupString, iPos + 1, Length( pSetupString )));
  iPos := Pos( ',', pSetupString );
  if iPos < 2 then
  begin
    raise exception.Create('illegal Setup string');
  end
  else
  begin
    iString := Trim(Copy( pSetupString, 1, iPos - 1 ));
    if iString = '110' then
    begin
      fComPort1.BaudRate := br110;
    end
    else if iString = '300' then
    begin
      fComPort1.BaudRate := br300;
    end
    else if iString ='600' then
    begin
      fComPort1.BaudRate := br600;
    end
    else if iString = '1200' then
    begin
      fComPort1.BaudRate := br1200;
    end
    else if iString = '2400' then
    begin
      fComPort1.BaudRate := br2400;
    end
    else if iString = '4800' then
    begin
      fComPort1.BaudRate := br4800;
    end
    else if iString = '9600' then
    begin
      fComPort1.BaudRate := br9600;
    end
    else if iString = '14400' then
    begin
      fComPort1.BaudRate := br14400;
    end
    else if iString = '19200' then
    begin
      fComPort1.BaudRate := br19200;
    end
    else if iString = '38400' then
    begin
      fComPort1.BaudRate := br38400;
    end
    else if iString = '56000' then
    begin
      fComPort1.BaudRate := br56000;
    end
    else if iString = '57600' then
    begin
      fComPort1.BaudRate := br57600;
    end
    else if iString = '115200' then
    begin
      fComPort1.BaudRate := br115200;
    end
    else
    begin
      raise Exception.Create( 'Illegal setup string' );
    end;
  end;

  pSetupString := Trim( Copy( pSetupString, iPos + 1, Length( pSetupString )));
  iPos := Pos( ',', pSetupString );
  if iPos < 2 then
  begin
    raise exception.Create('illegal Setup string');
  end;
  ParityAsString := Copy( pSetupString, 1, iPos - 1);

  pSetupString := Trim( Copy( pSetupString, iPos + 1, Length( pSetupString )));
  iPos := Pos( ',', pSetupString );
  if iPos < 2 then
  begin
    raise exception.Create('illegal Setup string');
  end;
  case StrToInt( Trim( Copy( pSetupString, 1, iPos - 1))) of
    7: fComPort1.DataBits := db7Bits;
    8: fComPort1.DataBits := db8Bits;
  else
    raise exception.Create( 'Illegal Setup String' );
  end;

  pSetupString := Trim( Copy( pSetupString, iPos + 1, Length( pSetupString )));
  if pSetupString = '1' then
  begin
    fComport1.StopBits := sb1Bits;
  end
  else if pSetupString = '1.5' then  // made up!
  begin
    fComport1.StopBits := sb1HALFBITS;
  end
  else if pSetupString = '2' then  // made up!
  begin
    fComport1.StopBits := sb2BITS;
  end
  else
  begin
    raise exception.Create( 'Illegal Setup String' );
  end;
end;

procedure TCommsPanel.SetStopBits(const Value: tStopbits);
begin
  fComPort1.StopBits := Value;
end;

function TCommsPanel.GetSendBufferSize : integer;
begin
  Result := fComPort1.SendBufferSize;
end;

procedure TCommsPanel.SetSendBufferSize( SendBufferSize : integer );
begin
  fComPort1.SendBufferSize := SendBufferSize;
end;

function TCommsPanel.GetRcvBufferSize : integer;
begin
  Result := fComPort1.RcvBufferSize;
end;

procedure TCommsPanel.SetRcvBufferSize( RcvBufferSize : integer );
begin
  fComPort1.RcvBufferSize := RcvBufferSize;
end;

function TCommsPanel.GetIsOpen : boolean;
begin
  Result := fComPort1.IsOpen;
end;

{
function TCommsPanel.GetOnCharacter: TNotifyOnCharacter;
begin
  Result := fComPort1.OnChar;
end;
}

function TCommsPanel.GetOnClose: tNotifyEvent;
begin
  Result := fComPort1.OnClose;
end;

function TCommsPanel.GetOnOpen: tNotifyEvent;
begin
  Result := fComPort1.OnOpen;
end;

function TCommsPanel.GetOnTimeOut: TNotifyEvent;
begin
  Result := fComPort1.OnInputTimeout;
end;

function TCommsPanel.GetParity: tParity;
begin
  Result := fComport1.Parity;
end;

function TCommsPanel.GetPort: integer;
begin
  Result := fComPort1.Port;
end;

procedure TCommsPanel.SetInputTimeOut(const Value: LongInt);
begin
  fComPort1.InputTimeout := Value;
end;

procedure TCommsPanel.SetIsOpen( Value : boolean );
begin
  fComPort1.IsOpen := Value;
end;

{
procedure TCommsPanel.SetOnCharacter(const Value: TNotifyOnCharacter);
begin
  fComPort1.OnChar := Value;
end;
}

procedure TCommsPanel.SetOnClose(const Value: tNotifyEvent);
begin
  fComPort1.OnClose := Value;
end;

procedure TCommsPanel.SetOnOpen(const Value: tNotifyEvent);
begin
  fComPort1.OnOpen := Value;;
end;

procedure TCommsPanel.SetOnTick(const Value: TNotifyEvent);
begin
  fOnTick := Value;
  if assigned( Value ) then
  begin
    fComPort1.OnTick := fInterceptedOnTick;
  end
  else
  begin
    fComPort1.OnTick := nil;
  end;
end;

procedure TCommsPanel.SetOnTimeOut(const Value: TNotifyEvent);
begin
  fComPort1.OnInputTimeout := Value;
end;

procedure TCommsPanel.SetParity(const Value: tParity);
begin
  fComPort1.Parity := Value;
end;

procedure TCommsPanel.SetParityAsString(const Value: string);
var
  iString : string;
begin
  istring := UpperCase( Trim( Value ));
  case iString[ 1 ] of
    'N': fComPort1.Parity := ptNONE;
    'O': fComPort1.Parity := ptODD;
    'E': fComPort1.Parity := ptEVEN;
    'M': fComPort1.Parity := ptMARK; // made this up - there is no standard
    'S': fComPort1.Parity := ptSPACE; // made this up - there is no standard
    else raise exception.Create( 'Illegal parity string - "' + Value + '"' );
  end;

end;

procedure TCommsPanel.SetPort(const Value: integer);
begin
  fComPort1.Port := Value;
end;

function TCommsPanel.GetAutoOpen : boolean;
begin
  Result := fComPort1.AutoOpen;
end;

procedure TCommsPanel.SetAutoOpen( Value : boolean );
begin
  fComPort1.AutoOpen := Value;
end;

function TCommsPanel.GetAutoAppendCR : boolean;
begin
  Result := fComPort1.AutoAppendCR;
end;

procedure TCommsPanel.SetAutoAppendCR( Value : boolean );
begin
  fComPort1.AutoAppendCR := Value;
end;

function TCommsPanel.GetEnableTimeOut : boolean;
begin
  Result := fComPort1.EnableTimeOut;
end;

procedure TCommsPanel.SetEnableTimeOut( Value : boolean );
begin
  fComPort1.EnableTimeOut := Value;
end;

function TCommsPanel.GetIsTimedOut : boolean;
begin
  //  Result := (fTimeOutValue >= fTimeOut);
  Result := fComPort1.IsTimedOut;
end;

function TCommsPanel.GetInputTimeOut: LongInt;
begin
  Result := fComPort1.InputTimeout;
end;

function TCommsPanel.GetIsOK : boolean;
begin
  Result := fComPort1.IsOK;
end;

function TCommsPanel.GetStatus : string;
begin
  Result := fComPort1.StatusAsString;
end;

function TCommsPanel.GetStopBits: tStopbits;
begin
  Result := fComPort1.StopBits;
end;

function TCommsPanel.GetText : string;
begin
  Result := MakeTextReadable( fComPort1.Buffer );
end;

procedure TCommsPanel.SetText( const Value : string );
begin
  fComPort1.Text := Value;
//  fTimeOutValue := 0;
  if Assigned( fOnOutPut ) then fOnOutput( self,
     MakeTextReadable( Value ));
end;

function TCommsPanel.GetBaudRate: tBaudRate;
begin
  Result := fComPort1.BaudRate;
end;

function TCommsPanel.GetBuffer : string;
begin
  Result := fComPort1.Buffer;
end;

function TCommsPanel.GetComPort: TComPortNumber;
begin
  Result := fComPort1.ComPort;
end;

procedure TCommsPanel.SetBaudRate(const Value: tBaudRate);
begin
  fComPort1.BaudRate := Value;
end;

procedure TCommsPanel.SetBuffer( const Value : string );
begin
  fComPort1.Buffer := Value;
//  fTimeOutValue := 0;
  if Assigned( fOnOutPut ) then fOnOutput( self,
     MakeTextReadable( Value ));
end;

procedure TCommsPanel.SetComPort(const Value: TComPortNumber);
begin
  fComPort1.ComPort := Value;
end;

{
function TCommsPanel.GetTickInterval : Word;
begin
  Result := fTimer1.Interval;
end;
}

function TCommsPanel.GetTimeOut: LongInt;
begin
  if TickInterval = 0 then
  begin
    Result := fComPort1.InputTimeout;
  end
  else
  begin
    Result := fComPort1.InputTimeout div TickInterval;
  end;
end;

function TCommsPanel.GetDataBits: tDataBits;
begin
  Result := fComPort1.DataBits
end;

function TCommsPanel.GetDataBitsAsInt: integer;
begin
  Result := 7;
  case DataBits of
    db7Bits: Result := 7;
    db8Bits: Result := 8;
  end;
end;

procedure TCommsPanel.SetTickInterval( Value : Word );
var
  fTimeout : integer;
begin
  fTimeout := Timeout;
  fTickInterval := Value;
  if fTickInterval = 0 then
  begin
    fComPort1.InputTimeout := fTimeout;
  end
  else
  begin
    fComPort1.InputTimeout := fTimeout * fTickInterval;
  end;
end;

procedure TCommsPanel.SetTimeOut(const Value: LongInt);
begin
  if fTickInterval = 0 then
  begin
    fComPort1.InputTimeout := Value;
  end
  else
  begin
    fComPort1.InputTimeout := Value * fTickInterval;
  end;
end;

function TCommsPanel.StopBitsAsString: string;
begin
  case fComPort1.StopBits of
    sb1BITS: Result := '1';
    sb1HALFBITS: Result := '1.5'; // made up
    sb2BITS: Result := '2';
  end;
end;

procedure TCommsPanel.SetDataBits(const Value: tDataBits);
begin
  fComport1.DataBits := Value;
end;

procedure TCommsPanel.SetDataBitsAsInt(const Value: integer);
begin
  case Value of
       7: DataBits := db7Bits;
       8: DataBits := db8Bits;
       else raise exception.Create( 'illegal word size (must be 7 or 8 bits)');
  end;
end;

procedure TCommsPanel.InternalOnAck(Sender: TObject);
begin
  if assigned( fOnAck ) then
  begin
    fOnAck( sender );
  end;
end;

procedure TCommsPanel.InternalOnNak(Sender: TObject);
begin
  if assigned( fOnNak) then
  begin
    fOnNak( sender );
  end;
end;

procedure TCommsPanel.InternalTimerAction (Sender: TObject);
begin
  if Assigned(fOnTick) then fOnTick( Self );
end;

end.
