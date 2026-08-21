unit Sig3ComPort;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Common;

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
  TSig3ComPort = class(TComponent)
  private
    { Private declarations }
    hCommsPort : THandle;
    iStatus : integer;
    ReplyBuffer : array[ 0 .. 255 ] of byte;
    ReplyBufferPtr : integer;
    iReplyBuffer : array[ 0..255] of byte;
    iCommsString : string;
    iSendBufferSize, iRcvBufferSize : integer;
    iAutoOpen : boolean;
    iEnableTimeOut : boolean; { enable timeout error }
    iSender : byte;
    iDestination : byte;
    iRecordType : byte;
    iChecksum : byte;
{
    iReadOverlap, iWriteOverlap : TOverlapped;
}
    iOverlap : TOverlapped;
    iCommTimeouts : TCommTimeouts;
    fOnInput : TNotifyEvent; {every time a whole record is read }
    fOnCharacter: TNotifyEvent; {Every time a character is received}

    hDCB : TDCB;
    iRecordSize : integer; // size of records - default to 15
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
    property IsOpen : boolean
             read iIsOpen
             write ChangeOpen;
    property IsOK : boolean
             read iCheckStat;
    property Sender : byte
             read iSource
             write iSender;
    property Destination : byte
             read iTarget
             write iDestination;
    property RecordType : byte
             read iRcvRecordType
             write iSendRecordType;
  published
    { Published declarations }
    property AutoOpen : boolean
             read iAutoOpen
             write iAutoOpen;
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
    property RecordSize : integer
             read iRecordSize
             write iRecordSize;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSig3ComPort]);
end;

end.
 