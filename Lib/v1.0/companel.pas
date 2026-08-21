unit Companel;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, ComPort, Common;

type
  TNotifyOnTransferEvent = procedure(Sender: TObject;
                       ConvertedString : string ) of object;

  // Added by AD
  TNotifyOnCharacter = procedure(Sender: TObject; Character: Char) of object;

type
  TCommsPanel = class(TPanel)
  private
    { Private declarations }
    function fIsTimedOut : boolean;

  protected
    { Protected declarations }
    ComPort1 : TComPort; { Comms }
    Timer1 : TTimer;

    iTimeOut : LongInt ; { in Ticks }
    iTimeOutValue : LongInt ; {current Value }

    fOnTick : TNotifyEvent; { every timer tick }
    fOnCreate : TNotifyEvent;
    fOnTimeOut : TNotifyEvent; { whenever a time out occurs }

    fOnCR : TNotifyEvent; { every CR }
    fOnAck : TNotifyEvent; { every ACK }
    fOnNak : TNotifyEvent; { every NACK }

    fOnCharacter : TNotifyOnCharacter; { every character - Added by AD}

    fOnOutput : TNotifyOnTransferEvent; {every string sent }
    fOnInput : TNotifyOnTransferEvent; {every string sent }

    { to allow auto-open }
    procedure Loaded; override;

    { internals - mostly mapping to TComPort component }
    procedure fTimerAction (Sender: TObject); virtual;

    function fReadSetupString : string; virtual;
    procedure fWriteSetupString( SetupString : string ); virtual;

    function fReadSendBufferSize : integer; virtual;
    procedure fWriteSendBufferSize( SendBufferSize : integer ); virtual;

    function fReadRcvBufferSize : integer; virtual;
    procedure fWriteRcvBufferSize( RcvBufferSize : integer ); virtual;

    function fIsOpen : boolean; virtual;
    procedure fChangeOpen( Value : boolean ); virtual;

    function fCheckStat : boolean; virtual;

    function fStatus : string; virtual;

    function fReadText : string; virtual;
    procedure fWriteText( Value : string ); virtual;

    function fReadBuffer : string; virtual;
    procedure fWriteBuffer( Value : string ); virtual;

    function fReadCheckInterval : Word; virtual;
    procedure fWriteCheckInterval( Value : Word ); virtual;

    function fReadAutoOpen : boolean; virtual;
    procedure fWriteAutoOpen( Value : boolean ); virtual;

    function fReadAutoAppendCR : boolean; virtual;
    procedure fWriteAutoAppendCR( Value : boolean ); virtual;

    function fReadEnableTimeOut : boolean; virtual;
    procedure fWriteEnableTimeOut( Value : boolean ); virtual;

    procedure fOnInputIndirect(Sender: TObject);
    procedure fOnCharacterInput(Sender: TObject); //Added by AD

  public
    { Public declarations }
    constructor Create( AOwner: TComponent ) ; override;
    destructor Destroy; override;
    procedure CloseComms;
    function OpenComms : boolean;
    property IsOpen : boolean
             read fIsOpen
             write fChangeOpen;
    property IsOK : boolean
             read fCheckStat;
    property Text : string
             read fReadText
             write fWriteText;
    property Buffer : string
             read fReadBuffer
             write fWriteBuffer;
    property IsTimedOut : boolean
             read fIsTimedOut;
    property TimeOutValue : LongInt
             read iTimeOutValue;
    property EnableTimeOut : boolean
             read fReadEnableTimeOut
             write fWriteEnableTimeOut;
  published
    { Published declarations }
    property SetupString : string
             read fReadSetupString
             write fWriteSetupString;
    property SendBufferSize : integer
             read fReadSendBufferSize
             write fWriteSendBufferSize;
    property RcvBufferSize : integer
             read fReadRcvBufferSize
             write fWriteRcvBufferSize;
    property Status : string
             read fStatus;
    property TickInterval : Word
             read fReadCheckInterval
             write fWriteCheckInterval;
    property AutoOpen : boolean
             read fReadAutoOpen
             write fWriteAutoOpen;
    property AutoAppendCR : boolean
             read fReadAutoAppendCR
             write fWriteAutoAppendCR;
    property TimeOut : LongInt
             read iTimeOut
             write iTimeOut;
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
  ComPort1 := TComPort.Create( self );
  Timer1 := TTimer.Create( self );
  Timer1.Interval := 100;
  Timer1.OnTimer := fTimerAction;
  iTimeOut := 30;           { 30 ticks == 3 seconds }
  if (not (csDesigning in ComponentState ))
     and Assigned( fOnCreate ) then fOnCreate( self );
end;

procedure TCommsPanel.fOnInputIndirect(Sender: TObject);
begin
  if Assigned( fOnInput ) then fOnInput( self,
     MakeTextReadable( Comport1.Buffer ));
end;

procedure TCommsPanel.fOnCharacterInput(Sender: TObject);
begin
	if Assigned (fOnCharacter) then
   	fOnCharacter (Self, ComPort1.CharBuffer);
end;

procedure TCommsPanel.Loaded;
begin
  { call inherited Loaded }
  inherited Loaded;
  { set ComPort Values }
  Comport1.OnInput := fOnInputIndirect;
  ComPort1.OnAck := fOnAck;
  ComPort1.OnNak := fOnNak;
  ComPort1.OnCR := fOnCR;
  ComPort1.OnCharacter := fOnCharacterInput; //Added by AD
  { call embedded components Loaded functions }
  ComPort1.Loaded;
end;

destructor TCommsPanel.Destroy;
begin
  Timer1.Free;
  ComPort1.Free;
  inherited Destroy;
end;

procedure TCommsPanel.CloseComms;
begin
  ComPort1.CloseComms;
end;

function TCommsPanel.OpenComms : boolean;
begin
  Result := ComPort1.OpenComms;
end;

function TCommsPanel.fReadSetupString : string;
begin
  Result := ComPort1.SetupString;
end;

procedure TCommsPanel.fWriteSetupString( SetupString : string );
begin
  ComPort1.SetupString := SetupString;
end;

function TCommsPanel.fReadSendBufferSize : integer;
begin
  Result := ComPort1.SendBufferSize;
end;

procedure TCommsPanel.fWriteSendBufferSize( SendBufferSize : integer );
begin
  ComPort1.SendBufferSize := SendBufferSize;
end;

function TCommsPanel.fReadRcvBufferSize : integer;
begin
  Result := ComPort1.RcvBufferSize;
end;

procedure TCommsPanel.fWriteRcvBufferSize( RcvBufferSize : integer );
begin
  ComPort1.RcvBufferSize := RcvBufferSize;
end;

function TCommsPanel.fIsOpen : boolean;
begin
  Result := ComPort1.IsOpen;
end;

procedure TCommsPanel.fChangeOpen( Value : boolean );
begin
  ComPort1.IsOpen := Value;
end;

function TCommsPanel.fReadAutoOpen : boolean;
begin
  Result := ComPort1.AutoOpen;
end;

procedure TCommsPanel.fWriteAutoOpen( Value : boolean );
begin
  ComPort1.AutoOpen := Value;
end;

function TCommsPanel.fReadAutoAppendCR : boolean;
begin
  Result := ComPort1.AutoAppendCR;
end;

procedure TCommsPanel.fWriteAutoAppendCR( Value : boolean );
begin
  ComPort1.AutoAppendCR := Value;
end;

function TCommsPanel.fReadEnableTimeOut : boolean;
begin
  Result := ComPort1.EnableTimeOut;
end;

procedure TCommsPanel.fWriteEnableTimeOut( Value : boolean );
begin
  ComPort1.EnableTimeOut := Value;
end;

function TCommsPanel.fIsTimedOut : boolean;
begin
  Result := (iTimeOutValue >= iTimeOut);
end;

function TCommsPanel.fCheckStat : boolean;
begin
  Result := ComPort1.IsOK;
end;

function TCommsPanel.fStatus : string;
begin
  Result := ComPort1.Status;
end;

function TCommsPanel.fReadText : string;
begin
  Result := ComPort1.Text;
end;

procedure TCommsPanel.fWriteText( Value : string );
begin
  ComPort1.Text := Value;
  iTimeOutValue := 0;
  if Assigned( fOnOutPut ) then fOnOutput( self,
     MakeTextReadable( Value ));
end;

function TCommsPanel.fReadBuffer : string;
begin
  Result := ComPort1.Buffer;
end;

procedure TCommsPanel.fWriteBuffer( Value : string );
begin
  ComPort1.Buffer := Value;
  iTimeOutValue := 0;
  if Assigned( fOnOutPut ) then fOnOutput( self,
     MakeTextReadable( Value ));
end;

function TCommsPanel.fReadCheckInterval : Word;
begin
  Result := Timer1.Interval;
end;

procedure TCommsPanel.fWriteCheckInterval( Value : Word );
begin
  Timer1.Interval := Value;
end;

procedure TCommsPanel.fTimerAction (Sender: TObject);
begin
  if ComPort1.CheckInput( Sender ) then
  begin
    { some data received, restart timeout }
    iTimeOutValue := 0;
  end
  else if iTimeOutValue < iTimeOut then
  begin
    Inc( iTimeOutValue );
    if Assigned(fOnTimeOut)
       and (iTimeOutValue = iTimeOut)
       and (EnableTimeOut = True) then
    begin
      fOnTimeOut( self );
      EnableTimeOut:=False; { only one timeout allowed}
    end;
  end;
  if Assigned(fOnTick) then fOnTick( Self );
end;

end.
