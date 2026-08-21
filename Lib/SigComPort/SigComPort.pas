{
  +-----------------------------------------------------------------------------
  |
  | ComDrv32.pas (see ComDrv16.pas for Delphi 1.0)
  | (Now SigComPort.pas)
  | COM Port Driver for Delphi 2.0
  |
  | Written by Marco Cocco
  | Copyright (c) 1996-97 by Marco Cocco. All rights reseved.
  | Copyright (c) 1996-97 by d3k The Artisan Of Ware. All rights reseved.
  |
  | Please send comments to d3k@mdnet.it
  | URL: http://www.mdlive.com/d3k/
  +-----------------------------------------------------------------------------
  | v3.00 - 08/09/09
  |         Changes to cope with double byte strings...
  | v2.00 - Feb 7th, 2000
  |   Modified by A Davison for use of SigNET (AC) Ltd.
  |	Ported to Delphi 4.0
  |   > Renamed component from TCommPortDriver to TSigComPort
  |	new property: InputTimeout
  |		> timeout value for incoming data in ms.
  |	new property: OnInputTimeout
  |		> Event triggered when a timeout has occurred
  |	new property: IsTimedOut
  |		> Determines the input time out status
  |	new property: Status
  |		> Determines the status when communications was established
  |	new property: EnableTimeOut
  |		> Flag to enable/disable the input time out
  |	changed procedure TimerWndProc
  |		> Enabled new input time out routine. After specified time and no input
  |			has occurred, an input time out event is generated only if EnableTimeOut
  |			is true.
  |
  |  Note: web site for latest release of this code no longer exists.
  +-----------------------------------------------------------------------------
  | v1.00/32 - Feb 15th, 1997
  | original Delphi 2.0 implementation
  +-----------------------------------------------------------------------------
  | v1.00/16 - May 21st, 1997
  | ported to Delphi 1.0
  +-----------------------------------------------------------------------------
  | v1.02/32 - Jun 5th, 1997
  | new property: ComPortHandle
  |   > COM port device handle made public (read/write)
  | new proc: SendZString( pchar string )
  |   > send C-style strings
  | new proc: FlushBuffers( in, out: boolean )
  |   > flush incoming data buffer (if in=TRUE)
  |   > flush outcoming data buffer (if out=TRUE)
  | new property: EnableDTROnOpen: boolean
  |   > set to TRUE (default) to set DTR to high on connect and to leave
  |     it high until disconnect.
  |     set to FALSE to set DTR to low on connect and to leave it low
  | new procs: ToggleDTR( onOff: boolean )
  |            ToggleRTS( onOff: boolean )
  |   > manually set on/off DTR/RTS line. You must disable HW handshaking before
  |     using there procs. You also must set EnableDRTOnOpen to FALSE.
  |     These procs are usefull if you are driving a RS232 to RS485 converter.
  |     (Set DTR high on TX, reset it to low on end of TX)
  | new proc: function OutFreeSpace: word
  |   > returns available free space in the output data buffer or 65535
  |     if the COM port is not open
  | new property: OutputTimeout: word
  |   > timeout for output (milliseconds)
  | changed proc: function SendData( DataPtr: pointer;
  |                                  DataSize: integer ): integer
  |   > sends a block of memory. Breaks the data block in smaller blocks if it
  |     is too large to fit the available free space in the output buffer.
  |     The OutputTimeout property value is the timeout (in millisends) for
  |     one small packet being correctly sent. Returns DataSize if all ok or a
  |     value less than zero if a timeout occurred (abs(result) is the number
  |     of bytes sent).
  +-----------------------------------------------------------------------------
  |
  | * This component built up on request of Mark Kuhnke.
  | * Porting to Delphi 1.0 done up on request of Paul Para (paul@clark.com)
  |
  | Greetings to:
  |  - Igor Gitman (gitman@interlog.com)
  |      he reported me the COM1 bug (16 bit version only)
  |
  +-----------------------------------------------------------------------------
  | Do you need additional features ? Feel free to ask for it!
  +-----------------------------------------------------------------------------

  ******************************************************************************
  *   Permission to use, copy,  modify, and distribute this software and its   *
  *        documentation without fee for any purpose is hereby granted,        *
  *   provided that the above copyright notice appears on all copies and that  *
  *     both that copyright notice and this permission notice appear in all    *
  *                         supporting documentation.                          *
  *                                                                            *
  * NO REPRESENTATIONS ARE MADE ABOUT THE SUITABILITY OF THIS SOFTWARE FOR ANY *
  *    PURPOSE.  IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY.   *
  *   NEITHER MARCO COCCO OR D3K SHALL BE LIABLE FOR ANY DAMAGES SUFFERED BY   *
  *                          THE USE OF THIS SOFTWARE.                         *
  ******************************************************************************
  * d3k - The Artisan Of Ware - A Marco Cocco's Company                        *
  * Casella Postale 99 - 09047 Selargius (CA) - ITALY                          *
  * Phone +39 70 846091 (Italian Speaking)  Fax +39 70 848331                  *
  ******************************************************************************

  ------------------------------------------------------------------------------
   Check our site for the last release of this code: http://www.mdlive.com/d3k/
  ------------------------------------------------------------------------------
  Other Dr Kokko's components:
    - TFLXPlayer (play FLI/FLC animations) - *UNSUPPORTED* *V2.0 COMING SOON*
    - TCommPortDriver (send/received data to/from COM ports - Delphi 1.0)
	 - TD3KBitmappedLabel (label with bitmapped font support)
	 - TO97Menus (MS Office 97 like menus) (**)
	 - TExplorerTreeView, TExploterListView (make your own disk explorer)
		(Explorer Clone source code included!) (**)

	 (**) = COMING SOON (as on Jun 5th, 1997)

	 Check our site for new components !
  ------------------------------------------------------------------------------
}

unit SigComPort;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes;//,
  //Forms,
  //Dialogs;

type
  // COM Port Baud Rates
  TBaudRate = ( br110, br300, br600, br1200, br2400, br4800,
							  br9600, br14400, br19200, br38400, br56000,
                       br57600, br115200{v1.02: removed ->, br128000, br256000} );
  // COM Port Numbers
  TComPortNumber = ( pnOther, pnCOM1, pnCOM2, pnCOM3, pnCOM4, pnCOM5, pnCOM6, pnCOM7, pnCOM8 );
  // COM Port Data bits
  TDataBits = ( db5BITS, db6BITS, db7BITS, db8BITS );
  // COM Port Stop bits
  TStopBits = ( sbNone, sb1BITS, sb1HALFBITS, sb2BITS );
  // COM Port Parity
  TParity = ( ptNONE, ptODD, ptEVEN, ptMARK, ptSPACE );
  // COM Port Hardware Handshaking
  THwHandshaking = ( hhNONE, hhRTSCTS );
  // COM Port Software Handshaing
  TSwHandshaking = ( shNONE, shXONXOFF );

  TComPortReceiveDataEvent = procedure (Sender: TObject; DataPtr: pointer; DataSize: integer) of object;

  TNotifyOnCharacter = procedure(Sender: TObject; Character: Char) of object;

  TSigComPort = class(TComponent)
  private
    fBuffer: string;
    fOnChar: TNotifyOnCharacter;
    fAutoOpen: boolean;
    fPort: integer;
    fAutoAppendCR: boolean;
    fOnOpen: tNotifyEvent;
    fOnClose: tNotifyEvent;
    function GetText: string;
    procedure SetText(const Value: string);
    function GetIsOK: boolean;
    function GetIsOpen: boolean;
    procedure SetIsOpen(const Value: boolean);
    function GetRcvBufferSize: integer;
    procedure SetRcvBufferSize(const Value: integer);
    function GetSendBufferSize: integer;
    procedure SetSendBufferSize(const Value: integer);
    function GetBaudRateAsString: string;
    function GetComPort: TComPortNumber;
    procedure SetPort(const Value: integer);
    function GetBuffer: string;
    procedure SetBuffer(const Value: string);
  protected
    nRead: dword;
	  FComPortHandle             : THANDLE; // COM Port Device Handle

//    FComPort                   : TComPortNumber; // COM Port to use (1..4) superceded by fPORT
    FBaudRate                  : TBaudRate; // COM Port speed (brXXXX)
    FComPortDataBits           : TDataBits; // Data bits size (5..8)
    FComPortStopBits           : TStopBits; // How many stop bits to use (1,1.5,2)
	  FComPortParity             : TParity; // Type of parity to use (none,odd,even,mark,space)
    FHwHandshaking             : THwHandshaking; // Type of hw handshaking to use
	  FSwHandshaking             : TSwHandshaking; // Type of sw handshaking to use
	  FComPortInBufSize          : word; // Size of the input buffer
	  FComPortOutBufSize         : word; // Size of the output buffer
	  FComPortReceiveData        : TComPortReceiveDataEvent; // Event to raise on data reception
	  FComPortPollingDelay       : Word; // ms of delay between COM port pollings
	  FEnableDTROnOpen           : boolean; { enable/disable DTR line on connect }
	  FOutputTimeout             : DWord; { output timeout - milliseconds }
	  FOnOutputTimeout		       : TNotifyEvent; // On output timeout event
	  FNotifyWnd                 : HWND; // This is used for the timer
	  FTempInBuffer              : pointer;
//	  FTempInBuffer2             : array of byte;
    FTempOutBuffer             : array of byte;
	  FOnInputTimeout				     : TNOtifyEvent; // Input time out event
	  FEnableTimeout				     : Boolean;	// Enables/disables input time out event
	  FInputTimeoutValue		     : DWord;	// ms elapsed since last serial input
	  FInputTimeout					     : DWord; // input timeout - milliseconds
	  FStatus							       : integer;	// Status of communication with serial port
	  FOverlap                   : _Overlapped; // Overlapped structure for the serial port
	  FOnTick							       : TNotifyEvent; // Event generated every timer event

	  function  FIsTimedOut: Boolean;
    procedure SetComHandle( Value: THANDLE );
    procedure SetComPort( Value: TComPortNumber );
    procedure SetBaudRate( Value: TBaudRate );
    procedure SetDataBits( Value: TDataBits );
    procedure SetStopBits( Value: TStopBits );
    procedure SetParity( Value: TParity );
    procedure SetHwHandshaking( Value: THwHandshaking );
	  procedure SetSwHandshaking( Value: TSwHandshaking );
	  procedure SetComPortInBufSize( Value: word );
	  procedure SetComPortOutBufSize( Value: word );
	  procedure SetComPortPollingDelay( Value: word );

	  procedure ApplyCOMSettings;

	  procedure TimerWndProc( var msg: TMessage ); virtual;
  public
    { made public to allow TCommsPort to call it }
    procedure ClearBuffer; // explicit clear of buffer - the old way is ambiguous and might not work
    procedure Loaded; override;

    property IsTimedOut: Boolean
             read FIsTimedOut;
	  property Status: Integer
             read FStatus
             write FStatus;
	  property EnableTimeout: Boolean
             read fEnableTimeout
             write fEnableTimeout;
	  constructor Create( AOwner: TComponent ); override;
	  destructor Destroy; override;

	  function Connect: boolean;
	  procedure Disconnect;
	  function Connected: boolean;
	  { v1.02: flushes the rx/tx buffers }
	  procedure FlushBuffers( inBuf, outBuf: boolean );
	  { v1.02: returns the output buffer free space or 65535 if
				 not connected }
	  function OutFreeSpace: word;

	  { Send data }
	  { v1.02: changed result time from 'boolean' to 'integer'. See the docs
				 for more info }
	  function SendData( DataPtr: pointer; DataSize: integer ): integer;
	  // Send a pascal string (NULL terminated if $H+ (default))
	  function SendString( s: string ): boolean;
	  // v1.02: send a C-style strings (NULL terminated)
	  function SendZString( s: pchar ): boolean;
	  // v1.02: set DTR line high (onOff=TRUE) or low (onOff=FALSE).
	  //        You must not use HW handshaking.
	  procedure ToggleDTR( onOff: boolean );
	  // v1.02: set RTS line high (onOff=TRUE) or low (onOff=FALSE).
	  //        You must not use HW handshaking.
	  procedure ToggleRTS( onOff: boolean );

	  // v1.02: make the Handle to the com port public (for TAPI...)
	  property ComHandle: THANDLE
             read FComPortHandle
             write SetComHandle;
	  // Flag to enable/disable the input timeout
    function OpenComms : boolean;
    procedure CloseComms;
    property BaudRateAsString : string
             read GetBaudRateAsString;
    property IsOK : boolean
             read GetIsOK;
    function StatusAsString : string;
    property Buffer : string
             read GetBuffer
             write SetBuffer;
    property Text : string
             read GetText
             write SetText;
  published
    // Which COM Port to use
    property ComPort: TComPortNumber
             read GetComPort
             write SetComPort
             default pnCOM2;
    // COM Port speed (bauds)
	  property BaudRate: TBaudRate
             read FBaudRate
             write SetBaudRate
             default br9600;
	  // Data bits to used (5..8, for the 8250 the use of 5 data bits with 2 stop bits is an invalid combination,
    // as is 6, 7, or 8 data bits with 1.5 stop bits)
	  property DataBits: TDataBits
             read FComPortDataBits
             write SetDataBits
             default db8BITS;
    // Stop bits to use (1, 1.5, 2)
    property StopBits: TStopBits
             read FComPortStopBits
             write SetStopBits
             default sb1BITS;
	  // Parity Type to use (none,odd,even,mark,space)
    property Parity: TParity
             read FComPortParity
             write SetParity
             default ptNONE;
    // Hardware Handshaking Type to use:
    //  cdNONE          no handshaking
    //  cdCTSRTS        both cdCTS and cdRTS apply (** this is the more common method**)
    property HwHandshaking: THwHandshaking
             read FHwHandshaking
             write SetHwHandshaking
             default hhNONE;
    // Software Handshaking Type to use:
    //  cdNONE          no handshaking
    //  cdXONXOFF       XON/XOFF handshaking
    property SwHandshaking: TSwHandshaking
             read FSwHandshaking
             write SetSwHandshaking
             default shNONE;
    // Input Buffer size
    property ComPortInBufSize: word
             read FComPortInBufSize
             write SetComPortInBufSize
             default 2048;
    // Output Buffer size
    property ComPortOutBufSize: word
             read FComPortOutBufSize
             write SetComPortOutBufSize
             default 2048;
    // ms of delay between COM port pollings
	  property ComPortPollingDelay: word
             read FComPortPollingDelay
             write SetComPortPollingDelay
             default 50;
	  // v1.02: Set to TRUE to enable DTR line on connect and to leave it on until disconnect.
    //        Set to FALSE to disable DTR line on connect.
	  property EnableDTROnOpen: boolean
             read FEnableDTROnOpen
             write FEnableDTROnOpen
             default true;
	  // v1.02: Output timeout (milliseconds)
	  property OutputTimeout: Dword
             read FOutputTimeOut
             write FOutputTimeout
             default 4000;
	  property InputTimeout: Dword
             read FInputTimeout
             write FInputTimeout
             default 4000;
	  // Event to raise when there is data available (input buffer has data)
    property OnReceiveData: TComPortReceiveDataEvent
             read FComPortReceiveData
             write FComPortReceiveData;
	  property OnInputTimeout: TNotifyEvent
             read FOnInputTimeout
             write FOnInputTimeout;
	  property OnOutputTimeout: TNotifyEvent
             read FOnOutputTimeout
             write FOnOutputTimeout;
	  property OnTick: TNotifyEvent
             read FOnTick
             write FOnTick;
    property OnChar : TNotifyOnCharacter
             read fOnChar
             write fOnChar;
    property AutoOpen : boolean
             read fAutoOpen
             write fAutoOpen;
    property Port : integer  // to allow for port numbers higher than 8
             read fPort
             write SetPort;
    property SendBufferSize : integer
             read GetSendBufferSize
             write SetSendBufferSize;
    property RcvBufferSize : integer
             read GetRcvBufferSize
             write SetRcvBufferSize;
    property IsOpen : boolean
             read GetIsOpen
             write SetIsOpen;
    property AutoAppendCR : boolean
             read fAutoAppendCR
             write fAutoAppendCR
             default FALSE;
    property OnOpen : tNotifyEvent
             read fOnOpen
             write fOnOpen;
    property OnClose : tNotifyEvent
             read fOnClose
             write fOnClose;
  end;

const
  COMMS_OK = 0;
  COMMS_NOT_OPEN = -1;
  COMMS_IN_ERROR = -2;
  COMMS_INP_NOT_EMPTY = -3;
  COMMS_OUT_NOT_EMPTY = -4;
  COMMS_TIMEOUT = -5;
  COMMS_OVERFLOW = -6;
  COMMS_ERROR_REPLY = -7;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

constructor TSigComPort.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  // Initialize to default values
  FComPortHandle             := 0;       // Not connected
  ComPort                    := pnCOM2;  // COM 2
  FBaudRate                  := br9600;  // 9600 bauds
  FComPortDataBits           := db8BITS; // 8 data bits
  FComPortStopBits           := sb1BITS; // 1 stop bit
  FComPortParity             := ptNONE;  // no parity
  FHwHandshaking             := hhNONE;  // no hardware handshaking
  FSwHandshaking             := shNONE;  // no software handshaking
  FComPortInBufSize          := 2048;    // input buffer of 2048 bytes
  FComPortOutBufSize         := 2048;    // output buffer of 2048 bytes
  FComPortReceiveData        := nil;     // no data handler
  FComPortPollingDelay       := 50;      // poll COM port every 50ms
  FOutputTimeout             := 4000;    // output timeout - 4000ms
  FEnableDTROnOpen           := true;    // DTR high on connect
//  FEnableTimeout 				     := true;	  // enable input time out
  FInputTimeout				       := 4000;	  // input timeout - 4000ms
  FInputTimeoutValue			   := 0;		  // Reset input timeout counter
  FEnableTimeout				     := false;	  // By Default, disable timeout
  // Temporary buffer for received data
  {$WARNINGS OFF}
  GetMem( FTempInBuffer, FComPortInBufSize );
  {$WARNINGS ON}
  //  SetLength( FTempInBuffer2, FComPortInBufSize );
  SetLength( FTempOutBuffer, FComPortOutBufSize );
  // Allocate a window handle to catch timer's notification messages
  if not (csDesigning in ComponentState) then
  begin
	  FNotifyWnd := AllocateHWnd( TimerWndProc );
  end;
end;

destructor TSigComPort.Destroy;
begin
  KillTimer( FNotifyWND, 1 );
  DeallocateHWnd( FNotifyWnd );
  // Be sure to release the COM device
  Disconnect;
  // Free the temporary buffer
  {$WARNINGS OFF}
  FreeMem( FTempInBuffer );
  {$WARNINGS ON}
  //  SetLength( FTempInBuffer2, 0 );
  SetLength( FTempOutBuffer, 0 );
  // Destroy the timer's window
  inherited Destroy;
end;

// v1.02: The COM port handle made public and writeable.
// This lets you connect to external opened com port.
// Setting ComPortHandle to 0 acts as Disconnect.
procedure TSigComPort.SetBuffer(const Value: string);
begin
  SendString( Value );
end;

procedure TSigComPort.SetComHandle( Value: THANDLE );
begin
  // If same COM port then do nothing
  if FComPortHandle = Value then
	 exit;
  { If value is $FFFFFFFF then stop controlling the COM port
	 without closing in }
  if Value = $FFFFFFFF then
  begin
    if Connected then
      { Stop the timer }
//		if Connected then
        KillTimer( FNotifyWnd, 1 );
	 { No more connected }
	 FComPortHandle := 0;
  end
  else
  begin
    { Disconnect }
    Disconnect;
    { If Value is = 0 then exit now }
	 { (ComPortHandle := 0 acts as Disconnect) }
    if Value = 0  then
      exit;

    { Set COM port handle }
    FComPortHandle := Value;

    { Start the timer (used for polling) }
    SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
  end;
end;

procedure TSigComPort.SetComPort( Value: TComPortNumber );
begin
  // Be sure we are not using any COM port
(*
  if Connected then
  begin
    exit;
  end;
*)
  // Change COM port
  if Value <> pnOther then
  begin
    Port := Ord( Value );
  end;
end;

procedure TSigComPort.SetBaudRate( Value: TBaudRate );
begin
  // Set new COM speed
  FBaudRate := Value;
  // Apply changes
  if Connected then
  begin
    ApplyCOMSettings;
  end;
end;

procedure TSigComPort.SetDataBits( Value: TDataBits );
begin
  // Set new data bits
  FComPortDataBits := Value;
  // Apply changes
  if Connected then
    ApplyCOMSettings;
end;

procedure TSigComPort.SetIsOpen(const Value: boolean);
begin
  if Value then
  begin
    Connect;
  end
  else
  begin
    Disconnect;
  end;
end;

procedure TSigComPort.SetSendBufferSize(const Value: integer);
begin
  ComPortOutBufSize := Value;
end;

procedure TSigComPort.SetStopBits( Value: TStopBits );
begin
  // Set new stop bits
  FComPortStopBits := Value;
  // Apply changes
  if Connected then
    ApplyCOMSettings;
end;

procedure TSigComPort.SetText(const Value: string);
var
  iString : string;
begin
  iString := Value;
  if AutoAppendCR then
  begin
    if Length( iString ) = 0 then
    begin
      iString := iString +#13;
    end
    else if Value[ Length( iString ) ] <> #13 then
    begin
      iString := iString +#13;
    end;
  end;
  Buffer := iString;
end;

function TSigComPort.StatusAsString: string;
begin
  if fStatus = COMMS_OK then Result := 'Open'
  else
  case fStatus of
    COMMS_NOT_OPEN : Result := 'Not Open';
    COMMS_IN_ERROR : Result := 'Comms Error';
    COMMS_INP_NOT_EMPTY : Result := 'Input Buffer not empty';
    COMMS_OUT_NOT_EMPTY : Result := 'Output Buffer not empty';
    COMMS_TIMEOUT : Result := 'Comms Time Out';
    COMMS_OVERFLOW : Result := 'Buffer Overflow';
    COMMS_ERROR_REPLY : Result := 'Comms Error Reply';
  else Result := 'Unknown Error ' + IntToStr( fStatus );
  end;

end;

procedure TSigComPort.SetParity( Value: TParity );
begin
  // Set new parity
  FComPortParity := Value;
  // Apply changes
  if Connected then
  begin
    ApplyCOMSettings;
  end;
end;

procedure TSigComPort.SetPort(const Value: integer);
begin
  // Be sure we are not using any COM port
  if (Value < 1) then
  begin
    raise exception.Create( 'Illegal port number' );
  end;
  if Connected then
  begin
    if Port <> Value then
    begin
      CloseComms;
      fPort := Value;
      OpenComms;
    end;
    // raise exception.Create( 'Cannot change com port - already open' );
  end
  else
  begin
    // Change COM port
    fPort := Value;
    if fAutoOpen then
    begin
      OpenComms;
    end;
  end;
end;

procedure TSigComPort.SetRcvBufferSize(const Value: integer);
begin
  ComPortInBufSize := Value;
end;

procedure TSigComPort.SetHwHandshaking( Value: THwHandshaking );
begin
  // Set new hardware handshaking
  FHwHandshaking := Value;
  // Apply changes
  if Connected then
    ApplyCOMSettings;
end;

procedure TSigComPort.SetSwHandshaking( Value: TSwHandshaking );
begin
  // Set new software handshaking
  FSwHandshaking := Value;
  // Apply changes
  if Connected then
    ApplyCOMSettings;
end;

procedure TSigComPort.SetComPortInBufSize( Value: word );
begin
  { Do nothing if connected }
  if Connected then
  begin
    exit;
  end;
  if Value <> FComPortInBufSize then
  begin
    FComPortInBufSize := Value;
//    SetLength( FTempInBuffer2, FComPortInBufSize );
    // Free the temporary input buffer
    {$WARNINGS OFF}
    FreeMem( FTempInBuffer, FComPortInBufSize );
    {$WARNINGS ON}
    // Set new input buffer size
    FComPortInBufSize := Value;
    // Allocate the temporary input buffer
    {$WARNINGS OFF}
    GetMem( FTempInBuffer, FComPortInBufSize );
    {$WARNINGS ON}
  end;
end;

procedure TSigComPort.SetComPortOutBufSize( Value: word );
begin
  { Do nothing if connected }
  if Connected then
	begin
    exit;
  end;
  // Set new output buffer size
  FComPortOutBufSize := Value;
  SetLength( FTempOutBuffer, FComPortOutBufSize );
end;

procedure TSigComPort.SetComPortPollingDelay( Value: word );
begin
  // If new delay is not equal to previous value...
  if Value <> FComPortPollingDelay then
  begin
    // Stop the timer
    if Connected then
      KillTimer( FNotifyWnd, 1 );
    // Store new delay value
    FComPortPollingDelay := Value;
    // Restart the timer
    if Connected then
      SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
  end;
end;

const
  Win32BaudRates: array[br110..br115200] of DWORD =
    ( CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400, CBR_4800, CBR_9600,
      CBR_14400, CBR_19200, CBR_38400, CBR_56000, CBR_57600, CBR_115200{v1.02 removed: CRB_128000, CBR_256000} );

const
  dcb_Binary              = $00000001;
  dcb_ParityCheck         = $00000002;
  dcb_OutxCtsFlow         = $00000004;
  dcb_OutxDsrFlow         = $00000008;
  dcb_DtrControlMask      = $00000030;
  dcb_DtrControlDisable   = $00000000;
  dcb_DtrControlEnable    = $00000010;
  dcb_DtrControlHandshake = $00000020;
  dcb_DsrSensivity        = $00000040;
  dcb_TXContinueOnXoff    = $00000080;
  dcb_OutX                = $00000100;
  dcb_InX                 = $00000200;
  dcb_ErrorChar           = $00000400;
  dcb_NullStrip           = $00000800;
  dcb_RtsControlMask      = $00003000;
  dcb_RtsControlDisable   = $00000000;
  dcb_RtsControlEnable    = $00001000;
  dcb_RtsControlHandshake = $00002000;
  dcb_RtsControlToggle    = $00003000;
  dcb_AbortOnError        = $00004000;
  dcb_Reserveds           = $FFFF8000;

// Apply COM settings.
procedure TSigComPort.ApplyCOMSettings;
var
  dcb: TDCB;
begin
  // Do nothing if not connected
  if not Connected then
  begin
    exit;
  end;

  // Clear all
  FillChar( dcb, sizeof(dcb), 0 );

  //BuildCommDCB('Stop=1', dcb);

  {
  if not GetCommState( FComPortHandle, dcb ) then
  begin
    FStatus := longint (GetLastError);
  end;
  }

  // Setup dcb (Device Control Block) fields
  dcb.DCBLength := sizeof(dcb); // dcb structure size
  dcb.BaudRate := Win32BaudRates[ FBaudRate ]; // baud rate to use
  // Set fBinary: Win32 does not support non binary mode transfers
  // (also disable EOF check)
  dcb.Flags := dcb_Binary;
  if EnableDTROnOpen then
  begin
    { Enabled the DTR line when the device is opened and leaves it on }
    dcb.Flags := dcb.Flags or dcb_DtrControlEnable;
  end;

  case FHwHandshaking of // Type of hw handshaking to use
    hhNONE:; // No hardware handshaking
	  hhRTSCTS: // RTS/CTS (request-to-send/clear-to-send) hardware handshaking
    begin
      dcb.Flags := dcb.Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake;
    end;
  end;
  case FSwHandshaking of // Type of sw handshaking to use
    shNONE:; // No software handshaking
	  shXONXOFF: // XON/XOFF handshaking
    begin
		  dcb.Flags := dcb.Flags or dcb_OutX or dcb_InX;
    end;
  end;
  dcb.XONLim := FComPortInBufSize div 4; // Specifies the minimum number of bytes allowed
													  // in the input buffer before the XON character is sent
														  // (or CTS is set)
  dcb.XOFFLim := 1; // Specifies the maximum number of bytes allowed in the input buffer
                    // before the XOFF character is sent. The maximum number of bytes
                    // allowed is calculated by subtracting this value from the size,
						  // in bytes, of the input buffer
  dcb.ByteSize := 5 + ord(FComPortDataBits); // how many data bits to use
  dcb.Parity := ord(FComPortParity); // type of parity to use
  dcb.StopBits := ord(FComPortStopbits) - 1; // how many stop bits to use
  dcb.XONChar := #17; // XON ASCII char
  dcb.XOFFChar := #19; // XOFF ASCII char

  if SetCommState( FComPortHandle, dcb ) then
  begin
    FStatus := COMMS_OK;
  end
  else
  begin
	  { If there is an error setting the communication port, return the error and exit}
	 FStatus := longint (GetLastError);
	 Exit;
  end;
  { Flush buffers }
  FlushBuffers( true, true );
  // Setup buffers size
  if SetupComm( FComPortHandle, FComPortInBufSize, FComPortOutBufSize ) then
  begin
		FStatus := COMMS_OK;
  end
  else
  begin
		FStatus := longint (GetLastError);
  end;
end;

procedure TSigComPort.ClearBuffer;
begin
  fBuffer := '';
end;

procedure TSigComPort.CloseComms;
begin
  Disconnect;
end;

function TSigComPort.Connect: boolean;
var
  comName: array[0..10] of char;
  tms: TCOMMTIMEOUTS;
begin
  // Do nothing if already connected
  Result := Connected;
  if Result then
  begin
    exit;
  end;
  // Open the COM port

//  if Port < 10 then
//  begin
//    StrPCopy( comName, 'COM' + IntToStr( Port ) + #0 );
//  end
//  else
//  begin

    StrPCopy( comName, '\\.\COM' + IntToStr( Port ) + #0 );
//  end;
//  comName[3] := chr( ord('1') + ord(FComPort) );
//  comName[4] := #0;
  FComPortHandle := CreateFile( comName,
										  GENERIC_READ or GENERIC_WRITE,
										  0, // Not shared
										  nil, // No security attributes
										  OPEN_EXISTING,
										  //FILE_FLAG_OVERLAPPED or
										  FILE_ATTRIBUTE_NORMAL,
										  0 // No template
										) ;
  {If the handle is invalid, close the comms}
  if FComportHandle = INVALID_HANDLE_VALUE then
  begin
    Disconnect;
  end;

  Result := Connected;
  if not Result then
  begin
	  exit;
  end;
  // Apply settings
  ApplyCOMSettings;
  // Setup timeouts: we disable timeouts because we are polling the com port!
  tms.ReadIntervalTimeout := 1; // Specifies the maximum time, in milliseconds,
										  // allowed to elapse between the arrival of two
										  // characters on the communications line
  tms.ReadTotalTimeoutMultiplier := 0; // Specifies the multiplier, in milliseconds,
                                       // used to calculate the total time-out period
													// for read operations.
  tms.ReadTotalTimeoutConstant := 1; // Specifies the constant, in milliseconds,
												 // used to calculate the total time-out period
                                     // for read operations.
  tms.WriteTotalTimeoutMultiplier := 0; // Specifies the multiplier, in milliseconds,
                                        // used to calculate the total time-out period
                                        // for write operations.
  tms.WriteTotalTimeoutConstant := 0; // Specifies the constant, in milliseconds,
												  // used to calculate the total time-out period
                                      // for write operations.
  SetCommTimeOuts( FComPortHandle, tms );
  // Start the timer (used for polling)
  SetTimer( FNotifyWnd, 1, FComPortPollingDelay, nil );
  if assigned( fOnOpen ) then
  begin
    fOnOpen( self );
  end;
end;

procedure TSigComPort.Disconnect;
begin
  if Connected then
  begin
    // Stop the timer (used for polling)
    KillTimer( FNotifyWnd, 1 );
    // Release the COM port
    CloseHandle( FComPortHandle );
    // No more connected
    FComPortHandle := 0;
    if assigned ( fOnClose ) then
    begin
      fonClose( self );
    end;
  end;
end;

function TSigComPort.Connected: boolean;
begin
  Result := (FComPortHandle > 0);
end;

// v1.02: flush rx/rx buffers
procedure TSigComPort.FlushBuffers( inBuf, outBuf: boolean );
var dwAction: DWORD;
begin
  if not Connected then
  begin
	  exit;
  end;
  // Flush the incoming data buffer
  dwAction := 0;
  if outBuf then
  begin
    dwAction := dwAction or PURGE_TXABORT or PURGE_TXCLEAR;
  end;
  if inBuf then
  begin
    dwAction := dwAction or PURGE_RXABORT or PURGE_RXCLEAR;
  end;
  PurgeComm( FComPortHandle, dwAction );
end;

function TSigComPort.GetBaudRateAsString: string;
begin
  case BaudRate of
    br110: Result := '110';
    br300: Result := '300';
    br600: Result := '600';
    br1200: Result := '1200';
    br2400: Result := '2400';
    br4800: Result := '4800';
    br9600: Result := '9600';
    br14400: Result := '14400';
    br19200: Result := '19200';
    br38400: Result := '38400';
    br56000: Result := '56000';
    br57600: Result := '57600';
    br115200: Result := '115200';
  end;

end;

function TSigComPort.GetBuffer: string;
begin
  Result := fBuffer;
  fBuffer := '';
end;

function TSigComPort.GetComPort: TComPortNumber;
begin
  if fPort <= 8 then
  begin
    Result := TComPortNumber( fPort )
  end
  else
  begin
    Result := pnOther;
  end;
end;

function TSigComPort.GetIsOK: boolean;
begin
  Result := fStatus = COMMS_OK;
end;

function TSigComPort.GetIsOpen: boolean;
begin
  Result := Connected;
end;

function TSigComPort.GetRcvBufferSize: integer;
begin
  Result := ComPortInBufSize;
end;

function TSigComPort.GetSendBufferSize: integer;
begin
  Result := ComPortOutBufSize;
end;

function TSigComPort.GetText: string;
begin
  Result := Buffer;
end;

procedure TSigComPort.Loaded;
begin
  inherited;
  if (not (csDesigning in ComponentState )) and fAutoOpen then
  begin
    OpenComms;
  end;
end;

// v1.02: returns the output buffer free space or 65535 if
//        not connected }
function TSigComPort.OpenComms: boolean;
begin
  Result := Connect;
end;

function TSigComPort.OutFreeSpace: word;
var stat: TCOMSTAT;
    errs: DWORD;
begin
  if not Connected then
    Result := 65535
  else
  begin
  {$WARNINGS OFF}
	  ClearCommError( FComPortHandle, errs, @stat );
    {$WARNINGS ON}
    Result := FComPortOutBufSize - stat.cbOutQue;
  end;
end;

// Send data
{function TSigComPort.SendData( DataPtr: pointer; DataSize: integer ): boolean;
var nsent: DWORD;
begin
  Result := WriteFile( FComPortHandle, DataPtr^, DataSize, nsent, nil );
  Result := Result and (nsent=DataSize);
end;}

{ Send data (breaks the data in small packets if it doesn't fit in the output
  buffer) }
function TSigComPort.SendData( DataPtr: pointer; DataSize: integer ): integer;
var
  nToSend, nsent: DWord;
  t1: DWord;
begin
	{ 0 bytes sent }
	Result := 0;
	{ Do nothing if not connected }
	if not Connected then
  begin
		exit;
  end;
	{ Current time }
	t1 := GetTickCount;
	{ Loop until all data sent or timeout occurred }
	while DataSize > 0 do
	begin
		{ Get output buffer free space }
		nToSend := OutFreeSpace;
		{ If output buffer has some free space... }
		if nToSend > 0 then
		begin
			{ Don't send more bytes than we actually have to send }
			if integer (nToSend) > DataSize then
      begin
				nToSend := DataSize;
      end;
			{ Send }
      {$WARNINGS OFF}
			WriteFile( FComPortHandle, DataPtr^, nToSend, nsent, nil);
      {$WARNINGS ON}
			{ If nSent = 0, that implies there is an error writing to the comms port.
			Trigger an output timeout then exit }
			if (nSent = 0) and Assigned (FOnOutputTimeOut) then
      begin
				FOnOutputTimeout (Self);
				Exit;
			end;
			{ Update number of bytes sent }
			Result := Result + abs(nsent);
			{ Decrease the count of bytes to send }
			DataSize := DataSize - abs(nsent);
			{ Get current time }
			t1 := GetTickCount;
			{ Continue. This skips the time check below (don't stop
			trasmitting if the FOutputTimeout is set too low) }
			continue;
		end;
		{ Buffer is full. If we are waiting too long then
		invert the number of bytes sent and exit }
		if (GetTickCount-t1) > FOutputTimeout then
		begin
			// Generate an output time out event
			if Assigned (FonOutputTimeout) then
      begin
        FOnOutputTimeout (Self);
      end;
      Result := -Result;
			exit;
		end;
	end;
  {Start counter for input time out}
  FEnableTimeOut := true;
  FInputTimeoutValue := 0;
end;

// Send a pascal string (NULL terminated if $H+ (default))
function TSigComPort.SendString( s: string ): boolean;
var
  len: integer;
  i : integer;
begin
  len := length( s );
  for i := 1 to Len do
  begin
    FTempOutBuffer[ i - 1 ] := Ord( s[ i ] );
  end;
  Result := SendData( FTempOutBuffer, len ) = len;
(*
  {$IFOPT H+}
  // New syle pascal string (NULL terminated)
  Result := SendData( pchar(s), len ) = len;
  {$ELSE}
  // Old style pascal string (s[0] = length)
  Result := SendData( pchar(@s[1]), len ) = len;
  {$ENDIF}
*)
end;

// v1.02: send a C-style strings (NULL terminated)
function TSigComPort.SendZString( s: pchar ): boolean;
var
  len: integer;
  i : integer;
begin
  len := strlen( s );
  for i := 1 to Len do
  begin
    FTempOutBuffer[ i - 1 ] := Ord( s[ i ] );
  end;
  Result := SendData( s, len ) = len;
end;

// v1.02: set DTR line high (onOff=TRUE) or low (onOff=FALSE).
//        You must not use HW handshaking.
procedure TSigComPort.ToggleDTR( onOff: boolean );
const funcs: array[boolean] of integer = (CLRDTR,SETDTR);
begin
  if Connected then
	 EscapeCommFunction( FComPortHandle, funcs[onOff] );
end;

// v1.02: set RTS line high (onOff=TRUE) or low (onOff=FALSE).
//        You must not use HW handshaking.
procedure TSigComPort.ToggleRTS( onOff: boolean );
const funcs: array[boolean] of integer = (CLRRTS,SETRTS);
begin
  if Connected then
	 EscapeCommFunction( FComPortHandle, funcs[onOff] );
end;

function TSigComPort.FIsTimedOut: Boolean;
begin
	Result := (FInputTimeoutValue >= FInputTimeout);
end;

// COM port polling proc
procedure TSigComPort.TimerWndProc( var msg: TMessage );
var
	iData: byte;
  i: Integer;
  iTempPtr : Pbyte;
begin
  if (msg.Msg = WM_TIMER) and Connected then
  begin
    nRead := 0;
    {$WARNINGS OFF}
    if ReadFile( FComPortHandle, FTempInBuffer^, FComPortInBufSize, nRead, nil) then
    {$WARNINGS ON}
    //    iTmpPtr := @FTempInBuffer[ 0 ];
//	  if ReadFile( FComPortHandle, iTmpPtr, FComPortInBufSize, nRead, nil) then
    begin
      if (nRead <> 0) then
      begin
        FInputTimeoutValue := 0;
//			FEnableTimeout := false;
        if Assigned(FComPortReceiveData) then
        begin
          FComPortReceiveData( Self, FTempInBuffer, nRead );
        end;
        if (nRead <> 0) then  //BUG0000099
        begin
          iTempPtr := FTempInBuffer;
          for i := 0 to nRead - 1 do
          begin
            iData := iTempPtr^;
            //          iData := (FTempInBuffer + i)^ ;
            fBuffer := fBuffer + char( iData );
            if assigned( OnChar ) then
            begin
              OnChar( self, Char(iData) );
            end;
            inc( iTempPtr);
          end;
        end;
      end
      else if (nRead = 0) and EnableTimeOut then
      begin
        inc (FInputTimeoutValue, ComportPollingDelay);
        if FIsTimedOut and Assigned (FOnInputTimeOut)then
        begin
          FEnableTimeOut := false;
          FOnInputTimeout (Self);
        end; {if a timeout occurred}
      end; {else no data was read}
    end; {if ReadFile was successful}
    if Assigned (fOnTick) then
    begin
      fOnTick (Self);
    end;
  end; {if timer message}
end;

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  { Register this component and show it in the 'SigNET' tab
	 of the component palette }
	RegisterComponents('SigNET', [TSigComPort]);
end;
{$ENDIF}

end.
