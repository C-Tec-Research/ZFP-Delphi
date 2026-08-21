unit USBPanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls,
  Types,
  WinTypes,
  Dialogs,
  ImgList,
  Grids;

const
  cDefaultXON = 17;
  cDefaultXOFF = 19;

type
  FT_PROGRAM_DATA = record
    Vendor_ID      : word;     // $0403
    Product_ID     : word;     // $6001
    Manufacturer   : pchar;    // 'FTDI'
    ManufacturerID : pchar;    // 'FT'
    Description    : pchar;    // 'USB HS Serial Converter'
    SerialNo       : pchar;    // 'FT000001' if fixed or nil
    MaxPower       : word;     // 0 < MaxPower <= 500
    PnP            : word;     // 0 = disabled, 1 = enabled
    SelfPowered    : word;     // 0 = bus powered, 1 = self powered
    RemoteWakeup   : word;     // 0 = not capable, 1 = capable
    //
    // Rev 4 extensions
    //
    Rev4           : boolean;  // True if rev4 chip, false otherwise
    IsoIn          : boolean;  // true if endpoint is isosynchronous
    IsoOut         : boolean;  // true if endpoint is isosynchronous
    PullDownEnable : boolean;  // true if Pull Down enabled
    SerNumEnable   : boolean;  // True if serial number to be used
    USBVersion     : word;     // BCD (0x0200 => USB 2.0)
  end;

type
  FT_Result = Integer;

//  tFT_Open          = function (PVDevice : Integer; var ftHandle : dword ) : FT_Result ; stdcall;
  tFT_Open          = function (PVDevice : Integer; ftHandle : pointer ) : FT_Result ; stdcall;
  tFT_OpenEx        = function (pvArg1 : Pointer; dwFlags : dword; ftHandle : Pointer) : FT_Result ; stdcall ;
  tFT_GetNumDevices = function (pvArg1 : Pointer; pvArg2 : Pointer; dwFlags : dword) : FT_Result ; stdcall ;
  tFT_ListDevices   = function (pvArg1 : dword; pvArg2 : Pointer; dwFlags : Dword) : FT_Result ; stdcall ;
  tFT_Close         = function (ftHandle : dword) : FT_Result ; stdcall ;

  tFT_SetBaudRate   = function (ftHandle : dword; BaudRate : dword) : FT_Result ; stdcall ;
  tFT_SetDataCharacteristics
                    = function (ftHandle : dword; WordLength, StopBits, Parity : byte) : FT_Result ; stdcall ;
  tFT_SetFlowControl
                    = function (ftHandle : dword; FlowControl : word; XonChar,XoffChar : Byte) : FT_Result ; stdcall ;
  tFT_SetDTR        = function (ftHandle : dword) : FT_Result ; stdcall ;
  tFT_ClrDTR        = function (ftHandle : dword) : FT_Result ; stdcall ;
  tFT_SetRTS        = function (ftHandle : dword) : FT_Result ; stdcall ;
  tFT_ClrRTS        = function (ftHandle : dword) : FT_Result ; stdcall ;
  tFT_SetBreakOff   = function (ftHandle : dword) : FT_Result ; stdcall ;
  tFT_SetBreakOn    = function (ftHandle : dword) : FT_Result ; stdcall ;

  tFT_Write         = function (ftHandle : dword; FTOutBuf : Pointer; BufferSize : LongInt; ResultPtr : Pointer ) : FT_Result ; stdcall ;
  tFT_GetQueueStatus
                    = function (ftHandle : dword; RxBytes:Pointer) : FT_Result ; stdcall ;
  tFT_Read          = function (ftHandle : dword; FTInBuf : Pointer; BufferSize : LongInt; ResultPtr : Pointer ) : FT_Result ; stdcall ;

  tFT_Purge         = function (ftHandle : dword; Mask : dword) : FT_Result ; stdcall;

  // EE functions
//  tFT_EE_Program    = function( FT_Handle : dword; var PFT_PROGRAM_DATA : FT_PROGRAM_DATA ) : FT_Result; stdcall;
//  tFT_EE_Read = function( FT_Handle : dword; var PFT_PROGRAM_DATA : FT_PROGRAM_DATA ) : FT_RESULT; stdcall;
//  tFT_EE_UASize = function( FT_Handle : dword; var Size : dword ) : FT_RESULT; stdcall;
//  tFT_EE_UAWrite = function( FT_Handle : dword; pData : pointer; size : dword ) : FT_RESULT; stdcall;
//  tFT_EE_UARead = function( FT_Handle : dword; pData : pointer; size : dword; var BytesRead : dword ) : FT_RESULT; stdcall;
  tFT_EE_Program    = function( FT_Handle : dword; PFT_PROGRAM_DATA : pointer ) : FT_Result; stdcall;
  tFT_EE_Read = function( FT_Handle : dword; PFT_PROGRAM_DATA : pointer ) : FT_RESULT; stdcall;
  tFT_EE_UASize = function( FT_Handle : dword; Size : pointer ) : FT_RESULT; stdcall;
  tFT_EE_UAWrite = function( FT_Handle : dword; pData : pointer; size : dword ) : FT_RESULT; stdcall;
  tFT_EE_UARead = function( FT_Handle : dword; pData : pointer; size : dword; var BytesRead : dword ) : FT_RESULT; stdcall;

type
  tErrorStyle = ( esThrowErrors, esPopUpErrors, esHideErrors );

  TDataLength = ( dl7Bits,
                  dl8Bits );

  TStopBits =   ( sb1Bit,
                  sb2Bits );

  TParity =     ( pNone,
                  pOdd,
                  pEven,
                  pMark,
                  pSpace );

  tPnP =        ( PnP_disabled,
                  PnP_enabled );

  tSelfPowered =( spBusPowered,
                  spSelfPowered );

  tRemoteWakeUp=( rwuNotCapable,
                  rwuCapable );

  tLineState =  ( lsClr,
                  lsSet );

  TFTBaudRate = (   br___300 ,
                    br___600 ,
                    br__1200 ,
                    br__2400 ,
                    br__4800 ,
                    br__9600 ,
                    br_14400 ,
                    br_19200 ,
                    br_38400 ,
                    br_57600 ,
                    br115200 ,
                    br230400 ,
                    br460800 ,
                    br921600
                  );

  TFlowControl = ( fcNone,
                   fcRTS_CTS,
                   fcDTR_DSR,
                   fcXON_XOFF
                   );

  TUSB_OpenMethod = ( omByDevice,
                      omByID );

  TOnChar = procedure( Sender: TObject; iChar : char ) of object;
  TOnTimeOut = procedure( Sender: TObject ) of object;

type
  TUSBPanel = class(TPanel)
  private
    { Private declarations }
  protected
    { Protected declarations }

    iTimer : TTimer;
    iImageList : TImageList;

    iOpen : boolean;
    iErrorStyle : tErrorStyle;

    iFT_Handle : dword;

    iDevice_String : array[ 1..50 ] of char;

    iBaudRate : dword;
    iWordLength : byte;
    iStopBits : byte;
    iParity : TParity;

    iProgramData : FT_PROGRAM_DATA;
    iManufacturer : array [ 0..50 ] of char;
    iManufacturerID : array [ 0..50 ] of char;
    iDescription : array [ 0..64 ] of char;
    iSerialNo : array [ 0..50 ] of char;

    iRcvUSBBufferCount : integer;
    iReadBuffer : array of char;
    iWriteBuffer : array of char;

    iReadBufferSize : integer;
    iWriteBufferSize : integer;

    iOnChar : TOnChar;
    iDelayCount : integer;
    iTimeout : integer;
    iTimeoutCountDown : integer;
    iOnTimeOut : tOnTimeOut;

    iFlowControl : word; // FT_FLOW_NONE = fcNone
    iXON : byte;  // 17  = ^Q
    iXOFF :byte; // 19  = ^S

    iDTR : tLineState;
    iRTS : tLineState;
    iBreak : tLineState;

    // Images
    iOpenImage : TImage;
    iSendBufferImage : TImage;
    iRcvBufferImage  : TImage;

    // Open
    iOpenMethod : TUSB_OpenMethod;
    iDeviceNo : dWord;

    procedure fSetOpen( NewVal : boolean );

    procedure fSetDevice_String( NewVal : string );
    function  fGetDevice_String : string;

    function FT_Error_Check(ErrStr: String; PortStatus : Integer) : boolean;

    procedure fSetBaudRate( NewVal : TFTBaudRate );
    function  fGetBaudRate : TFTBaudRate;

    procedure fSetDataLength( NewVal : TDataLength );
    function  fGetDataLength : TDataLength;
    procedure fSetStopBits( NewVal : TStopBits );
    function fGetStopBits : TStopBits;
    procedure fSetParity( NewVal : TParity );

    procedure fSetCurrentBaudRate;
    procedure fSetDataCharacteristics;

    function  fGetPnP : tPnP;
    procedure fSetPnP( NewVal : tPnP );

    function fGetDLLIsLoaded : boolean;

    procedure fSetReadBufferSize( NewVal : integer );
    procedure fSetWriteBufferSize( NewVal : integer );
    procedure fSetText( NewVal : string ); virtual;
    function fGetText : string; virtual;
    procedure fGetUSBBuffer;

    procedure fSetTickInterval( NewVal : integer );
    function fGetTickInterval : integer;
    procedure fTimerAction (Sender: TObject); virtual;

    function  fGetVendorID : string;
    procedure fSetVendorID( NewVal : string );
    function  fGetProductID : string;
    procedure fSetProductID( NewVal : string );
    function  fGetManufacturer : string;
    procedure fSetManufacturer(NewVal : string );
    function  fGetManufacturerID : string;
    procedure fSetManufacturerID( NewVal : string );
    function  fGetDescription : string;
    procedure fSetDescription( newVal : string );
    function  fGetSerialNo : string;
    procedure fSetSerialNo( NewVal : string );
    function  fGetMaxPower : word;
    procedure fSetMaxPower( NewVal : word );
    function  fGetSelfPowered : tSelfPowered;
    procedure fSetSelfPowered( NewVal : tSelfPowered );
    function  fGetRemoteWakeup : tRemoteWakeUp;
    procedure fSetRemoteWakeup( NewVal : tRemoteWakeUp );
    //
    // Rev 4 extensions
    //
    function  fGetRev4 : boolean;
    procedure fSetRev4( NewVal : boolean );
    function  fGetIsoIn : boolean;
    procedure fSetIsoIn( NewVal : boolean );
    function  fGetIsoOut : boolean;
    procedure fSetIsoOut( NewVal : boolean );
    function  fGetPullDownEnable : boolean;
    procedure fSetPullDownEnable( NewVal : boolean );
    function  fGetSerNumEnable : boolean;
    procedure fSetSerNumEnable( NewVal : boolean );
    function  fGetUSBVersion : string;
    procedure fSetUSBVersion( NewVal : string );

    procedure fSetFlowControl( NewVal : TFlowControl ); // FT_FLOW_NONE = fcNone
    function  fGetFlowControl : TFlowControl;
    procedure fSetXON( NewVal : byte );  // 17  = ^Q
    procedure fSetXOFF( NewVal : byte ); // 19  = ^S
    procedure fWriteFlowControl;
    procedure fSetDTR( NewVal : tLineState );
    procedure fSetRTS( NewVal : tLineState );
    procedure fSetBreak( NewVal : tLineState );

  public
    { Public declarations }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property USB_Handle : dword
             read iFT_Handle; // read only property

    procedure Open_USB;
    procedure Close_USB;

    function GetFTDeviceCount : dword;
    function GetFTDeviceDescription( DevNo : dword ) : string;

    property DLLIsLoaded : boolean
             read fGetDLLIsLoaded; // read only property!

    property Text : string
             read fGetText
             write fSetText;

    property Delay : integer
             read iDelayCount
             write iDelayCount; // delay in ticks.
    // EE Functions
    function Program_Device : boolean;
    function Read_Device : boolean;
    function Get_User_Area_Size : dword;
    function ReadUserArea( pUA : pointer; size : dword ) : dword; // returns bytes actually read
    function WriteUserArea( pUA : pointer; size : dword ) : boolean;

    // flow control
    property DTR : tLineState
             read iDTR
             write fSetDTR;
    property RTS : tLineState
             read iRTS
             write fSetRTS;
    property BreakCondition : tLineState
             read iBreak
             write fSetBreak;

    // others
    procedure Purge( Mask : dword );

    procedure Open_USB_ByID;
    procedure Open_USB_ByDevice;

  published
    { Published declarations }
    property VendorID : string
             read fGetVendorID
             write fSetVendorID;
    property ProductID : string
             read fGetProductID
             write fSetProductID;
    property Manufacturer : string
             read fGetManufacturer
             write fSetManufacturer;
    property ManufacturerID : string
             read fGetManufacturerID
             write fSetManufacturerID;
    property Description : string
             read fGetDescription
             write fSetDescription;
    property SerialNo : string
             read fGetSerialNo
             write fSetSerialNo;
    property MaxPower : word
             read fGetMaxPower
             write fSetMaxPower
             default 44;

    property Open : boolean
             read iOpen
             write fSetOpen
             default FALSE;
    property ErrorStyle : tErrorStyle
             read iErrorStyle
             write iErrorStyle
             default esThrowErrors;
    property Device_String : string
             read fGetDevice_String
             write fSetDevice_String;
    property BaudRate : TFTBaudRate
             read fGetBaudRate
             write fSetBaudRate
             default br__9600;
    property DataBits : TDataLength
             read fGetDataLength
             write fSetDataLength
             default dl8Bits;
    property StopBits : TStopBits
             read fGetStopBits
             write fSetStopBits
             default sb1Bit;
    property Parity : TParity
             read iParity
             write fSetParity
             default pNone;
    property PnP : tPnP
             read fGetPnP
             write fSetPnP
             default PnP_enabled;
    property WriteBufferSize : integer
             read iWriteBufferSize
             write fSetWriteBufferSize
             default 2048;
    property ReadBufferSize : integer
             read iReadBufferSize
             write fSetReadBufferSize
             default 2048;
    property OnChar : TOnChar
             read iOnChar
             write iOnChar;
    property TimeOut : integer // in ticks
             read iTimeOut
             write iTimeout
             default 300;
    property OnTimeOut : tOnTimeout
             read iOnTimeOut
             write iOnTimeOut;
    property TickInterval : integer // in m/secs
             read fGetTickInterval
             write fSetTickInterval
             default 10;
    property SelfPowered : tSelfPowered
             read fGetSelfPowered
             write fSetSelfPowered
             default spBusPowered;
    property RemoteWakeup : tRemoteWakeUp
             read fGetRemoteWakeUp
             write fSetRemoteWakeup
             default rwuCapable;     // 0 = not capable, 1 = capable
    //
    // Rev 4 extensions
    //
    property Rev4 : boolean
             read fGetRev4
             write fSetRev4
             default FALSE;  // True if rev4 chip, false otherwise
    property IsoIn : boolean
             read fGetIsoIn
             write fSetIsoIn
             default FALSE;  // true if endpoint is isosynchronous
    property IsoOut : boolean
             read fGetIsoOut
             write fSetIsoOut
             default FALSE;  // true if endpoint is isosynchronous
    property PullDownEnable : boolean
             read fGetPullDownEnable
             write fSetPullDownEnable
             default FALSE;  // true if Pull Down enabled
    property SerNumEnable : boolean
             read fGetSerNumEnable
             write fSetSerNumEnable
             default FALSE;  // True if serial number to be used
    property USBVersion : string
             read fGetUSBVersion
             write fSetUSBVersion;     // BCD (0200 => USB 2.0)
    //
    // Flow Control
    //
    property FlowControl : TFlowControl
             read fGetFlowControl
             write fSetFlowControl
             default fcNone; // FT_FLOW_NONE = fcNone
    property XON : byte
             read iXON
             write fSetXON
             default cDefaultXON;   // 17  = ^Q
    property XOFF : byte
             read iXOFF
             write fSetXOFF
             default cDefaultXOFF; // 19  = ^S
    //
    // Images
    //
    property ImageList : tImageList
             read iImageList
             write iImageList;

    property OpenMethod : TUSB_OpenMethod
             read iOpenMethod
             write iOpenMethod
             default omByID;

    property DeviceNo : dword
             read iDeviceNo
             write iDeviceNo
             default 0;
  end;

// columns for TUSBGrid
const
  cIndex = 0;
  cVendorID = 1;
  cProductID = 2;
  cManufacturer = 3;
  cManufacturerID = 4;
  cDescription = 5;
  cSerialNo = 6;
  cMaxPower = 7;
  cPnP = 8;
  cSelfPowered = 9;
  cRemoteWakeup = 10;
    //
    // Rev 4 extensions
    //
  cRev4 = 11;
  cIsoIn = 12;
  cIsoOut = 13;
  cPullDownEnable = 14;
  cSerNumEnable = 15;
  cUSBVersion = 16;

  cUSBGridColCount = 17;

type
  TUSBGrid = class(TStringGrid)
  protected
    iTimer : TTimer;
//    iAutoConnect : boolean;
    iActiveMonitor : boolean;
    iErrorStyle : tErrorStyle;
    iDeviceCount : integer;

    iProgramData : FT_PROGRAM_DATA;
    iManufacturer : array [ 0..50 ] of char;
    iManufacturerID : array [ 0..50 ] of char;
    iDescription : array [ 0..64 ] of char;
    iSerialNo : array [ 0..50 ] of char;

    procedure fTimerAction (Sender: TObject);
    procedure fFillGrid;
    procedure fSetActiveMonitor( NewVal : boolean );
  public
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
    function GetFTDeviceCount : dword;

    function FT_Error_Check(ErrStr: String; PortStatus : Integer) : boolean;
    property DeviceCount : integer
             read iDeviceCount; // last read device count
  published
    property DefaultRowHeight
             default 20;
    property ColCount
             default cUSBGridColCount;
    property ErrorStyle : tErrorStyle
             read iErrorStyle
             write iErrorStyle
             default esThrowErrors;
    property ActiveMonitor : boolean
             read iActiveMonitor
             write fSetActiveMonitor
             default FALSE;
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TUSBPanel, TUSBGrid]);
end;

//------------------ DLL Functions -------------------

Const
// FT_Result Values
  FT_OK = 0;
  FT_INVALID_HANDLE = 1;
  FT_DEVICE_NOT_FOUND = 2;
  FT_DEVICE_NOT_OPENED = 3;
  FT_IO_ERROR = 4;
  FT_INSUFFICIENT_RESOURCES = 5;
  FT_INVALID_PARAMETER = 6;
  FT_SUCCESS = FT_OK;

// FT_Open_Ex Flags
  FT_OPEN_BY_SERIAL_NUMBER = 1;
  FT_OPEN_BY_DESCRIPTION = 2;

// FT_List_Devices Flags
  FT_LIST_NUMBER_ONLY = $80000000;
  FT_LIST_BY_INDEX = $40000000;
  FT_LIST_ALL = $20000000;

// Flow Control Selection
  FT_FLOW_NONE = $0000;
  FT_FLOW_RTS_CTS = $0100;
  FT_FLOW_DTR_DSR = $0200;
  FT_FLOW_XON_XOFF = $0400;

// Purge Commands
  FT_PURGE_RX = 1;
  FT_PURGE_TX = 2;

var
  hUSB                      : THandle;
  FT_Open                   : tFT_Open;
  FT_OpenEx                 : tFT_OpenEx;
  FT_GetNumDevices          : tFT_GetNumDevices;
  FT_ListDevices            : tFT_ListDevices;
  FT_Close                  : tFT_Close;
  FT_SetBaudRate            : tFT_SetBaudRate;
  FT_SetDataCharacteristics : tFT_SetDataCharacteristics;
  FT_SetFlowControl         : tFT_SetFlowControl;
  FT_SetDTR                 : tFT_SetDTR;
  FT_ClrDTR                 : tFT_ClrDTR;
  FT_SetRTS                 : tFT_SetRTS;
  FT_ClrRTS                 : tFT_ClrRTS;
  FT_SetBreakOff            : tFT_SetBreakOff;
  FT_SetBreakOn             : tFT_SetBreakOn;

  FT_Write                  : tFT_Write;
  FT_GetQueueStatus         : tFT_GetQueueStatus;
  FT_Read                   : tFT_Read;
  FT_Purge                  : tFT_Purge;

  FT_EE_Program             : tFT_EE_Program;
  FT_EE_Read                : tFT_EE_Read;
  FT_EE_UASize              : tFT_EE_UASize;
  FT_EE_UAWrite             : tFT_EE_UAWrite;
  FT_EE_UARead              : tFT_EE_UARead;

  InstanceCount             : integer; // a count of how many instances there are.
                                       // this is used to decide when and if to unload the DLL
procedure OpenUSBLib;
begin
  hUSB := LoadLibrary('ftd2xx.dll'); // gives HINSTANCE_ERROR if load fails
  if hUSB > HINSTANCE_ERROR then
  begin
    FT_Open := GetProcAddress( hUSB, 'FT_Open' );
    FT_Close := GetProcAddress( hUSB, 'FT_Close' );
    FT_ListDevices := GetProcAddress( hUSB, 'FT_ListDevices' );
    FT_GetNumDevices := GetProcAddress( hUSB, 'FT_ListDevices' );
    FT_OpenEx := GetProcAddress( hUSB, 'FT_OpenEx' );
    FT_SetBaudRate := GetProcAddress( hUSB, 'FT_SetBaudRate' );
    FT_SetDataCharacteristics := GetProcAddress( hUSB, 'FT_SetDataCharacteristics' );
    FT_SetFlowControl := GetProcAddress( hUSB, 'FT_SetFlowControl' );
    FT_SetDTR := GetProcAddress( hUSB, 'FT_SetDTR' );
    FT_ClrDTR := GetProcAddress( hUSB, 'FT_ClrDTR' );
    FT_SetRTS := GetProcAddress( hUSB, 'FT_SetRTS' );
    FT_ClrRTS := GetProcAddress( hUSB, 'FT_ClrRTS' );
    FT_SetBreakOff := GetProcAddress( hUSB, 'FT_SetBreakOff' );
    FT_SetBreakOn := GetProcAddress( hUSB, 'FT_SetBreakOn' );

    FT_Write := GetProcAddress( hUSB, 'FT_Write' );
    FT_GetQueueStatus := GetProcAddress( hUSB, 'FT_GetQueueStatus' );
    FT_Read := GetProcAddress( hUSB, 'FT_Read' );
    FT_Purge := GetProcAddress( hUSB, 'FT_Purge' );

    FT_EE_Program := GetProcAddress( hUSB, 'FT_EE_Program' );
//    FT_EE_Read := GetProcAddress( hUSB, 'FT_EE_Program' );          //??????
    FT_EE_Read := GetProcAddress( hUSB, 'FT_EE_Read' );          //??????
    FT_EE_UASize := GetProcAddress( hUSB, 'FT_EE_UASize' );
    FT_EE_UAWrite := GetProcAddress( hUSB, 'FT_EE_UAWrite' );
    FT_EE_UARead := GetProcAddress( hUSB, 'FT_EE_UARead' );

  end
  else
  begin
    FT_Open := nil;
    FT_Close := nil;
    FT_ListDevices := nil;
    FT_GetNumDevices := nil;
    FT_OpenEx := nil;
    FT_SetBaudRate := nil;
    FT_SetDataCharacteristics := nil;
    FT_SetFlowControl := nil;
    FT_SetDtr := nil;
    FT_ClrDtr := nil;
    FT_SetRts := nil;
    FT_ClrRts := nil;

    FT_Write := nil;
    FT_GetQueueStatus := nil;
    FT_Read := nil;
    FT_Purge := nil;

    FT_EE_Program := nil;
    FT_EE_Read := nil;
    FT_EE_UASize := nil;
    FT_EE_UAWrite := nil;
    FT_EE_UARead := nil;
  end;
end;

procedure CloseUSBLib;
begin
  if hUSB > HINSTANCE_ERROR then
  begin
    FreeLibrary( hUSB );
  end;
end;

//------------- TUSBGrid ----------------------------

constructor TUSBGrid.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );

  // load library if required
  if InstanceCount = 0 then
  begin
    OpenUSBLib;
  end;
  inc( InstanceCount );

  DefaultRowHeight := 20;

  ColCount := cUSBGridColCount;
  RowCount := 2;
  Cells[ cIndex, 0 ] := 'Index';
  ColWidths[ cIndex ] := 32;
  Cells[ cVendorID, 0 ] := 'Vendor ID';
  ColWidths[ cVendorID ] := 40;
  Cells[ cProductID, 0 ] := 'Product ID';
  Colwidths[ cProductID ] := 40;
  Cells[ cManufacturer, 0 ] := 'Manufacturer';
  Colwidths[ cManufacturer ] := 80;
  Cells[ cManufacturerID, 0 ] := 'Manuf. ID';
  Cells[ cDescription, 0 ] := 'Description';
  Cells[ cSerialNo, 0 ] := 'Serial No';
  ColWidths[ cSerialNo ] := 48;
  Cells[ cMaxPower, 0 ] := 'Max Power';
  Cells[ cPnP, 0 ] := 'PnP';
  ColWidths[ cPnP ] := 32;
  Cells[ cSelfPowered, 0 ] := 'Self Powered';
  Colwidths[ cSelfPowered ] := 72;
  Cells[ cRemoteWakeup, 0 ] := 'Remote Wakeup';
  Colwidths[ cRemoteWakeup ] := 88;
    //
    // Rev 4 extensions
    //
  Cells[ cRev4, 0 ] := 'Rev 4';
  ColWidths[ cRev4 ] := 40;
  Cells[ cIsoIn, 0 ] := 'Iso In';
  ColWidths[ cIsoIn ] := 40;
  Cells[ cIsoOut, 0 ] := 'Iso Out';
  ColWidths[ cIsoOut ] := 40;
  Cells[ cPullDownEnable, 0 ] := 'Pull Down';
  ColWidths[ cPullDownEnable ] := 56;
  Cells[ cSerNumEnable, 0 ] := 'Ser Num En';
  ColWidths[ cSerNumEnable ] := 64;
  Cells[ cUSBVersion, 0 ] := 'USB Ver.';
  ColWidths[ cUSBVersion ] := 48;

  iTimer := TTimer.Create( self );
  iTimer.Enabled := FALSE;
  iTimer.Interval := 100;
  iTimer.OnTimer := fTimerAction;

//  iAutoConnect := FALSE;
  iActiveMonitor := FALSE;

  iErrorStyle := esThrowErrors;

  iDeviceCount := 0;

  iProgramData.Vendor_ID      := $0403;
  iProgramData.Product_ID     := $6001;
  iProgramData.Manufacturer   := @iManufacturer;
  StrCopy( @iManufacturer, 'FTDI' );
  iProgramData.ManufacturerID := @iManufacturerID;
  StrCopy( @iManufacturerID, 'FT' );
  iProgramData.Description    := @iDescription;
  StrCopy( @iDescription, 'USB HS Serial Converter');
  iProgramData.SerialNo       := @iSerialNo;
  StrCopy( @iSerialNo, 'FT000001' );
  iProgramData.MaxPower       := 44;
  iProgramData.PnP            := 1;
  iProgramData.SelfPowered    := 0;
  iProgramData.RemoteWakeup   := 1;
    //
    // Rev 4 extensions
    //
  iProgramData.Rev4           := FALSE;  // True if rev4 chip, false otherwise
  iProgramData.IsoIn          := FALSE;  // true if endpoint is isosynchronous
  iProgramData.IsoOut         := FALSE;  // true if endpoint is isosynchronous
  iProgramData.PullDownEnable := FALSE;  // true if Pull Down enabled
  iProgramData.SerNumEnable   := FALSE;  // True if serial number to be used
  iProgramData.USBVersion     := $0200; // BCD (0x0200 => USB 2.0)

end;

destructor TUSBGrid.Destroy;
begin
  dec( InstanceCount );
  if InstanceCount = 0 then
  begin
    CloseUSBLib;
  end;
  inherited Destroy;
end;

procedure TUSBGrid.fTimerAction (Sender: TObject);
var
  iNewDeviceCount : integer;
begin
  // check for USB changes. Assume not able to both add and
  // remove a device within one tenth of a second
  iNewDeviceCount := GetFTDeviceCount;
  if iNewDeviceCount <> iDeviceCount then
  begin
    iDeviceCount := iNewDeviceCount;
    fFillGrid;
  end;
end;

procedure TUSBGrid.fFillGrid;
var
  i, j, iRowCount : integer;
  iUSBHandle : dword;
//  iProgramData : FT_PROGRAM_DATA;
//  iDevice_String : array[ 1..50 ] of char;
begin
  iRowCount := GetFTDeviceCount;
  if (iRowCount = 0) or not iActiveMonitor then
  begin
    RowCount := 2;
    for i := 0 to ColCount - 1 do
    begin
      Cells[ i, 1 ] := '';
    end;
  end
  else
  begin
    RowCount := iRowCount + 1;
    for i := 0 to IRowCount - 1 do
    begin
      Cells[ cIndex, i + 1 ] := intToStr( i );
      for j := 1 to ColCount - 1 do
      begin
        Cells[ j, i + 1 ] := '';
      end;
//      if assigned( FT_OpenEx ) then
//      begin
//        if FT_Error_Check( 'Opening device ' + intToStr( i ),
//           FT_OpenEx( @iDevice_String, FT_OPEN_BY_SERIAL_NUMBER, @iUSBHandle )) then
      if assigned( FT_Open ) then
      begin
        if FT_Error_Check( 'Opening device ' + intToStr( i ),
           FT_Open( i, @iUSBHandle )) then
//           FT_Open( i, iUSBHandle )) then
        begin
          if assigned( FT_EE_Read ) then
          begin
            if FT_Error_Check( 'Reading device ' + intToStr( i ),
               FT_EE_Read( iUSBHandle, @iProgramData )) then
            begin
              Cells[ cVendorID, i + 1 ] := IntToHex( iProgramData.Vendor_ID, 4 );
              Cells[ cProductID, i + 1 ] := IntToHex( iProgramData.Product_ID, 4 );
              Cells[ cManufacturer, i + 1 ] := iProgramData.Manufacturer;
              Cells[ cManufacturerID, i + 1 ] := iProgramData.ManufacturerID;
              Cells[ cDescription, i + 1 ] := iProgramData.Description;
              if assigned( iProgramData.SerialNo ) then
              begin
                Cells[ cSerialNo, i + 1 ] := iProgramData.SerialNo;
              end
              else
              begin
                Cells[ cSerialNo, i + 1 ] := '[none]';
              end;
              Cells[ cMaxPower, i + 1 ] := intToStr( iProgramData.MaxPower );
              if iProgramData.PnP = 0 then
              begin
                Cells[ cPnP, i + 1 ] := 'Disabled';
              end
              else
              begin
                Cells[ cPnP, i + 1 ] := 'Enabled';
              end;
              if iProgramData.SelfPowered = 0 then
              begin
                Cells[ cSelfPowered, i + 1 ] := 'False';
              end
              else
              begin
                Cells[ cSelfPowered, i + 1 ] := 'True';
              end;
              if iProgramData.RemoteWakeup = 0 then
              begin
                Cells[ cRemoteWakeup, i + 1 ] := 'False';
              end
              else
              begin
                Cells[ cRemoteWakeup, i + 1 ] := 'True';
              end;
                  //
                  // Rev 4 extensions
                  //
              if iProgramData.Rev4 then
              begin
                Cells[ cRev4, i + 1 ] := 'True';
              end
              else
              begin
                Cells[ cRev4, i + 1 ] := 'False';
              end;
              if iProgramData.IsoIn then
              begin
                Cells[ cIsoIn, i + 1 ] := 'True';
              end
              else
              begin
                Cells[ cIsoIn, i + 1 ] := 'False';
              end;
              if iProgramData.IsoOut then
              begin
                Cells[ cIsoOut, i + 1 ] := 'True';
              end
              else
              begin
                Cells[ cIsoOut, i + 1 ] := 'False';
              end;
              if iProgramData.PullDownEnable then
              begin
                Cells[ cPullDownEnable, i + 1 ] := 'Enabled';
              end
              else
              begin
                Cells[ cPullDownEnable, i + 1 ] := 'Disabled';
              end;
              if iProgramData.SerNumEnable then
              begin
                Cells[ cSerNumEnable, i + 1 ] := 'True';
              end
              else
              begin
                Cells[ cSerNumEnable, i + 1 ] := 'Disabled';
              end;
              Cells[ cUSBVersion, i + 1 ] := intToHex( iProgramData.USBVersion, 4 );
            end;
          end;
        end;
        if assigned( FT_Close ) then
        begin
          FT_Error_Check( 'Closing file ' + intToStr( i ),
              FT_Close( iUSBHandle ));
        end;
      end;
    end
  end;
end;

function TUSBGrid.GetFTDeviceCount : dword;
begin
  Result := 0;
  if assigned( FT_GetNumDevices ) then
  begin
    FT_Error_Check( 'Getting USB Device Count', FT_GetNumDevices( @Result, nil, FT_LIST_NUMBER_ONLY ));
  end;
end;

function TUSBGrid.FT_Error_Check(ErrStr: String; PortStatus : Integer) : boolean;
var
  Str : String;
begin
  if PortStatus = FT_OK then
  begin
    result := TRUE;
  end
  else
  begin
    case PortStatus of
      FT_INVALID_HANDLE : Str := 'Error ' + ErrStr + ' - Invalid Handle...';
      FT_DEVICE_NOT_FOUND : Str := 'Error ' + ErrStr + ' - Device Not Found....';
      FT_DEVICE_NOT_OPENED : Str := 'Error ' + ErrStr + ' - Device Not Opened...';
      FT_IO_ERROR : Str := 'Error ' + ErrStr + ' - General IO Error...';
      FT_INSUFFICIENT_RESOURCES : Str := 'Error ' + ErrStr + ' - Insufficient Resources...';
      FT_INVALID_PARAMETER : Str := 'Error ' + ErrStr + ' - Invalid Parameter ...';
    end;
    result := FALSE;
    if not (csDesigning in ComponentState) then
    begin
      if ErrorStyle = esThrowErrors then
      begin
        raise Exception.Create( Str );
      end
      else if ErrorStyle = esPopUpErrors then
      begin
        MessageDlg(Str, mtError, [mbOk], 0);
      end;
    end;
  end;
end;

procedure TUSBGrid.fSetActiveMonitor( NewVal : boolean );
begin
  iActiveMonitor := NewVal;
  iTimer.Enabled := NewVal;
  fFillGrid;
end;

//------------- TUSBPanel ---------------------------

constructor TUSBPanel.Create( AOwner: TComponent);
begin
  inherited Create( AOwner );

  // load library if required
  if InstanceCount = 0 then
  begin
    OpenUSBLib;
  end;
  inc( InstanceCount );

  iOpen := FALSE;
  iFT_Handle := 0;
  iErrorStyle := esThrowErrors;
  Device_String := 'DLP-USB232M';
  iWordLength := 8;
  iStopBits := 0;  // seems odd!
  iParity := pNone;

  iProgramData.Vendor_ID      := $0403;
  iProgramData.Product_ID     := $6001;
  iProgramData.Manufacturer   := @iManufacturer;
  StrCopy( @iManufacturer, 'FTDI' );
  iProgramData.ManufacturerID := @iManufacturerID;
  StrCopy( @iManufacturerID, 'FT' );
  iProgramData.Description    := @iDescription;
  StrCopy( @iDescription, 'USB HS Serial Converter');
  iProgramData.SerialNo       := @iSerialNo;
  StrCopy( @iSerialNo, 'FT000001' );
  iProgramData.MaxPower       := 44;
  iProgramData.PnP            := 1;
  iProgramData.SelfPowered    := 0;
  iProgramData.RemoteWakeup   := 1;
    //
    // Rev 4 extensions
    //
  iProgramData.Rev4           := FALSE;  // True if rev4 chip, false otherwise
  iProgramData.IsoIn          := FALSE;  // true if endpoint is isosynchronous
  iProgramData.IsoOut         := FALSE;  // true if endpoint is isosynchronous
  iProgramData.PullDownEnable := FALSE;  // true if Pull Down enabled
  iProgramData.SerNumEnable   := FALSE;  // True if serial number to be used
  iProgramData.USBVersion     := $0200; // BCD (0x0200 => USB 2.0)

  ReadBufferSize := 2048;
  WriteBufferSize := 2048;

  iRTS := lsClr;
  iDTR := lsClr;
  iBreak := lsClr;
  iXON := cDefaultXON;
  iXOFF := cDefaultXOFF;
  iFlowControl := FT_FLOW_NONE;
  fWriteFlowControl;

  BaudRate := br__9600;

  iImageList := nil;

  iTimer := TTimer.Create( self );
  iTimer.Enabled := iOpen and not (csDesigning in ComponentState );
  TickInterval := 10;
  iTimer.OnTimer := fTimerAction;
  iTimeOut := 300;           { 300 ticks == 3 seconds }
  iTimeOutCountdown := iTimeOut;

  iOpenImage := TImage.Create( self );
  with iOpenImage do
  begin
    Parent := self;
    width := 17;
    height := 17;
    top := self.Height - 34;
    left := self.Width - 102;
    Anchors := [akBottom, akRight];
  end;
  iSendBufferImage := TImage.Create( self );
  with iSendBufferImage do
  begin
    Parent := self;
    width := 17;
    height := 17;
    top := self.Height - 34;
    left := self.Width - 68;
    Anchors := [akBottom, akRight];
  end;
  iRcvBufferImage  := TImage.Create( self );
  with iRcvBufferImage do
  begin
    Parent := self;
    width := 17;
    height := 17;
    top := self.Height - 34;
    left := self.Width - 34;
    Anchors := [akBottom, akRight];
  end;

  iOpenMethod := omByID;
  iDeviceNo   := 0;

end;

destructor TUSBPanel.Destroy;
begin
  dec( InstanceCount );
  if InstanceCount = 0 then
  begin
    CloseUSBLib;
  end;
  inherited Destroy;
end;

function TUSBPanel.fGetDLLIsLoaded : boolean;
begin
  result := hUSB > HINSTANCE_ERROR;
end;

procedure TUSBPanel.fSetOpen( NewVal : boolean );
begin
  // we only want open or close to do anything
  // if we are not designing
//  if NewVal <> iOpen then
  begin
    if csDesigning in ComponentState then
    begin
      iOpen := NewVal;
    end
    else
    begin
      if NewVal then
      begin
        Open_USB;
      end
      else
      begin
        Close_USB;
      end;
    end;
  end;
end;

procedure TUSBPanel.Open_USB;
begin
  case iOpenMethod of
    omByID: Open_USB_ByID;
    omByDevice: Open_USB_ByDevice;
  end;
end;

procedure TUSBPanel.Open_USB_ByDevice;
begin
  if assigned( FT_Open ) then
  begin
    try
      if FT_Error_Check( 'Opening USB',
         FT_Open( iDeviceNo, @iFT_Handle )) then
      begin
        iOpen := TRUE;
        fSetCurrentBaudRate;
        fSetDataCharacteristics;
        iTimer.Enabled := TRUE;
      end;
    except
      iOpen := FALSE;
      raise;
    end;
  end;
end;

procedure TUSBPanel.Open_USB_ByID;
var
  i, iDeviceCount : integer;
  itProgramData : FT_PROGRAM_DATA;
  itManufacturer : array [ 0..50 ] of char;
  itManufacturerID : array [ 0..50 ] of char;
  itDescription : array [ 0..64 ] of char;
  itSerialNo : array [ 0..50 ] of char;
begin
  //Set up structure
  itProgramData.Manufacturer := @itManufacturer;
  itProgramData.ManufacturerID := @itManufacturerID;
  itProgramData.Description := @itDescription;
  itProgramData.SerialNo := @itSerialNo;
  // no way to call in design mode, so no need to test
  if assigned( FT_Open ) then
  begin
    iDeviceCount := GetFTDeviceCount;
    for i := 0 to iDeviceCount - 1 do
    begin
      try
        if FT_Error_Check( 'Opening USB',
////          FT_Open( i, @iUSBHandle )) then ????
          FT_Open( i, @iFT_Handle )) then
        begin
          if assigned( FT_EE_Read ) then
          begin
            if FT_Error_Check( 'Reading EEPROM',
////               FT_EE_Read( iUSBHandle, @itProgramData )) then   ????
               FT_EE_Read( iFT_Handle, @itProgramData )) then 
            begin
              if (itProgramData.Vendor_ID = iProgramData.Vendor_ID)
                 and (itProgramData.Product_ID = iProgramData.Product_ID) then
              begin
                // done
                iOpen := TRUE;
                iDeviceNo := i;
                fSetCurrentBaudRate;
                fSetDataCharacteristics;
                iTimer.Enabled := TRUE;
                exit;
              end;
            end;
          end;
        end;
        if assigned( FT_Close ) then
        begin
          FT_Close( iFT_Handle );
        end;
      except
      end;
    end;
  end;
  iOpen := FALSE;
  case ErrorStyle of
    esThrowErrors: raise Exception.Create( 'Error opening by ID' );
    esPopUpErrors: MessageDlg('Error opening by ID', mtError, [mbOk], 0);
  end;
end;

procedure TUSBPanel.Close_USB;
begin
  iTimer.Enabled := FALSE;
  if iOpen then
  begin
    if assigned( FT_Close ) then
    begin
      FT_Close( iFT_Handle );
    end;
    iOpen := FALSE;
  end;
end;

function  TUSBPanel.fGetDevice_String : string;
var
  i : integer;
begin
  result := '';
  for i := 1 to 50 do
  begin
    if iDevice_String[ i ] = #0 then exit;
    result := result + iDevice_String[ i ];
  end;
end;

procedure TUSBPanel.fSetDevice_String( NewVal : string );
var
  i : integer;
begin
  for i := 1 to length( NewVal ) do
  begin
    iDevice_String[ i ] := NewVal[ i ];
  end;
  iDevice_String[ length( NewVal ) + 1 ] := #0;
end;

function TUSBPanel.GetFTDeviceDescription( DevNo : dword ) : string;
var
  Buffer : array [1..50] of char;
  i : integer;
begin
  Result := '';
  if assigned( FT_ListDevices ) then
  begin
    if FT_Error_Check( 'Getting USB Device Description for device ' + IntToStr( DevNo ),
       FT_ListDevices( DevNo, @Buffer, FT_OPEN_BY_DESCRIPTION or FT_LIST_BY_INDEX )) then
    begin
      for i := 1 to 50 do
      begin
        if Buffer[ i ] = #0 then break; // done
        Result := Result + Buffer[ i ];
      end;
    end;
  end;
end;

function TUSBPanel.GetFTDeviceCount : dword;
begin
  Result := 0;
  if assigned( FT_GetNumDevices ) then
  begin
    FT_Error_Check( 'Getting USB Device Count', FT_GetNumDevices( @Result, nil, FT_LIST_NUMBER_ONLY ));
  end;
end;

procedure TUSBPanel.fSetCurrentBaudRate;
begin
  if assigned( FT_SetBaudRate ) then
  begin
    if iOpen then
    begin
      FT_SetBaudRate( iFT_Handle, iBaudRate );
    end;
  end;
end;

procedure TUSBPanel.fSetDataCharacteristics;
begin
  if not (csDesigning in ComponentState ) then
  begin
    if iOpen then
    begin
      if assigned( FT_SetDataCharacteristics ) then
      begin
        FT_Error_Check( 'Setting Data Characteristics', FT_SetDataCharacteristics( iFT_Handle, Ord(iWordLength), Ord( iStopBits ), Ord( iParity ) ));
      end;
    end;
  end;
end;

procedure TUSBPanel.fSetBaudRate( NewVal : TFTBaudRate );
begin
  case NewVal of
    br___300: iBaudRate := 300;
    br___600: iBaudRate := 600;
    br__1200: iBaudRate := 1200;
    br__2400: iBaudRate := 2400;
    br__4800: iBaudRate := 4800;
    br__9600: iBaudRate := 9600;
    br_14400: iBaudRate := 14400;
    br_19200: iBaudRate := 19200;
    br_38400: iBaudRate := 38400;
    br_57600: iBaudRate := 57600;
    br115200: iBaudRate := 115200;
    br230400: iBaudRate := 230400;
    br460800: iBaudRate := 460800;
    br921600: iBaudRate := 921600;
    // iBaudRate := NewVal;
  end;
  if Open then
  begin
    fSetCurrentBaudRate;
  end;
end;

function TUSBPanel.fGetBaudRate : TFTBaudRate;
begin
  case iBaudRate of
       300: Result := br___300;
       600: Result := br___600;
      1200: Result := br__1200;
      2400: Result := br__2400;
      4800: Result := br__4800;
      9600: Result := br__9600;
     14400: Result := br_14400;
     19200: Result := br_19200;
     38400: Result := br_38400;
     57600: Result := br_57600;
    115200: Result := br115200;
    230400: Result := br230400;
    460800: Result := br460800;
    921600: Result := br921600;
  else
    Result := br__9600;
  end;
end;

procedure TUSBPanel.fSetDataLength( NewVal : TDataLength );
begin
  case NewVal of
    dl7Bits:
    begin
      if iWordLength <> 7 then
      begin
        iWordLength := 7;
        fSetDataCharacteristics;
      end
    end;
    dl8Bits:
    begin
      if iWordLength <> 8 then
      begin
        iWordLength := 8;
        fSetDataCharacteristics;
      end
    end;
  end;
end;

function TUSBPanel.fGetDataLength : TDataLength;
begin
  case iWordLength of
    7: Result := dl7Bits;
  else
    Result := dl8Bits;
  end;
end;

procedure TUSBPanel.fSetStopBits( NewVal : TStopBits );
begin
  case NewVal of
    sb1Bit:
    begin
      if iStopBits <> 0 then
      begin
        iStopBits := 0;
        fSetDataCharacteristics;
      end;
    end;
    sb2Bits:
    begin
      if iStopBits <> 2 then
      begin
        iStopBits := 2;
        fSetDataCharacteristics;
      end;
    end;
  end;
end;

function TUSBPanel.fGetStopBits : TStopBits;
begin
  case iStopBits of
    2: Result := sb2Bits;
  else
    Result := sb1Bit;
  end;
end;

procedure TUSBPanel.fSetParity( NewVal : TParity );
begin
  if iParity <> NewVal then
  begin
    iParity := NewVal;
    try
      fSetDataCharacteristics;
    except
      raise Exception.Create( 'Unable to set USB parity' );
    end;
  end;
end;

function  TUSBPanel.fGetPnP : tPnP;
begin
  if iProgramData.PnP = 0 then Result := PnP_disabled
  else Result := PnP_enabled;
end;

procedure TUSBPanel.fSetPnP( NewVal : tPnP );
begin
  iProgramData.PnP := Ord( NewVal );
end;

function TUSBPanel.fGetText : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to iRcvUSBBufferCount - 1 do
  begin
    Result := Result + iReadBuffer[ i ];
  end;
  iRcvUSBBufferCount := 0;
end;

function TUSBPanel.Program_Device : boolean;
begin
  Result := FALSE;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( FT_EE_Program ) then
    begin
      Result := FT_Error_Check( 'programming USB device',
                FT_EE_Program( iFT_Handle, @iProgramData ));
    end;
  end;
end;

procedure TUSBPanel.fSetReadBufferSize( NewVal : integer );
begin
  iReadBufferSize := NewVal;
  if NewVal = 0 then
  begin
    iReadBuffer := nil;
  end
  else
  begin
    SetLength( iReadBuffer, NewVal );
  end;
end;

procedure TUSBPanel.fSetWriteBufferSize( NewVal : integer );
begin
  iWriteBufferSize := NewVal;
  if NewVal = 0 then
  begin
    iWriteBuffer := nil;
  end
  else
  begin
    SetLength( iWriteBuffer, NewVal );
  end;
end;

procedure TUSBPanel.fSetText( NewVal : string );
var
  i : integer;
  rPtr : integer;
begin
  if assigned( FT_Write ) then
  begin
    for i := 1 to length( NewVal ) do
    begin
      iWriteBuffer[ i - 1 ] := NewVal[ i ];
      iTimeOutCountdown := iTimeOut;
    end;
//    FT_Error_Check( 'writing to USB port', FT_Write( iFT_Handle, @iWriteBuffer, Length( NewVal ), @rPtr ));
    FT_Error_Check( 'writing to USB port', FT_Write( iFT_Handle, iWriteBuffer, Length( NewVal ), @rPtr ));
  end;
end;

procedure TUSBPanel.fGetUSBBuffer;
var
  pending : dword;
  rcvd : dword;
  RcvdChar : array [ 0..2 ] of char; // leave one spare in case
begin
   RcvdChar[0] := #255;
   RcvdChar[1] := #255;
   RcvdChar[2] := #255;

  if not ( csDesigning in ComponentState ) then
  begin
    if assigned( FT_GetQueueStatus ) then
    begin
      try
        if FT_Error_Check( 'Reading from USB Port', FT_GetQueueStatus( iFT_Handle, @pending )) then
        begin
          while pending > 0 do
          begin
            iTimeOutCountdown := iTimeOut;
            FT_Read( iFT_Handle, @RcvdChar, 1, @rcvd );
            iReadBuffer[ iRcvUSBBufferCount ] := RcvdChar[ 0 ];
            inc( iRcvUSBBufferCount );
            if assigned( iOnChar ) then
            begin
              iOnChar( self, RcvdChar[ 0 ] );
            end;
            if not FT_Error_Check( 'Reading from USB Port', FT_GetQueueStatus( iFT_Handle, @pending )) then
            begin
              pending := 0;
            end;
          end;
        end;
      except
        // do not bother with time-outs if there is an error
        raise; // rethrow the exception
      end;
    end;
  end;
  if iTimeOutCountdown > 0 then
  begin
    dec( iTimeOutCountdown );
  end
  else
  begin
    if assigned( iOnTimeOut ) then
    begin
      iOnTimeOut( self );
    end;
  end;
end;

procedure TUSBPanel.fSetTickInterval( NewVal : integer );
begin
  iTimer.Interval := NewVal;
end;

function TUSBPanel.fGetTickInterval : integer;
begin
  result := iTimer.Interval;
end;

procedure TUSBPanel.fTimerAction (Sender: TObject);
begin
  if iDelayCount > 0 then
  begin
    dec( iDelayCount );
  end
  else
  begin
    fGetUSBBuffer;
  end;
end;

function TUSBPanel.Read_Device : boolean;
begin
  Result := FALSE;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( FT_EE_Read ) then
    begin
      Result := FT_Error_Check( 'reading USB device EEPROM',
          FT_EE_Read( iFT_Handle, @iProgramData ));
    end;
  end;
end;

function TUSBPanel.Get_User_Area_Size : dword;
begin
  Result := 0;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( FT_EE_UASize ) then
    begin
      FT_Error_Check( 'getting EEPROM user area size',
                      FT_EE_UASize( iFT_Handle, @Result ));
    end;
  end;
end;

function TUSBPanel.ReadUserArea( pUA : pointer; size : dword ) : dword;
begin
  Result := 0;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( FT_EE_UARead ) then
    begin
      FT_Error_Check( 'reading USB device EEPROM user area', FT_EE_UARead( iFT_Handle, pUA, size, Result ));
    end;
  end;
end;

function TUSBPanel.WriteUserArea( pUA : pointer; size : dword ) : boolean;
begin
  Result := FALSE;
  if not (csDesigning in ComponentState) then
  begin
    if assigned( FT_EE_UAWrite ) then
    begin
      Result := FT_Error_Check( 'writing to USB device EEPROM user area',
                FT_EE_UAWrite( iFT_Handle, pUA, size ));
    end;
  end;
end;

function TUSBPanel.fGetVendorID : string;
begin
  Result := IntToHex( iProgramData.Vendor_ID, 4 );
end;

procedure TUSBPanel.fSetVendorID( NewVal : string );
begin
  iProgramData.Vendor_ID := StrToInt( '$' + NewVal );
end;

function TUSBPanel.fGetProductID : string;
begin
  Result := IntToHex( iProgramData.Product_ID, 4 );
end;

procedure TUSBPanel.fSetProductID( NewVal : string );
begin
  iProgramData.Product_ID := StrToInt( '$' + NewVal );
end;

function  TUSBPanel.fGetManufacturer : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to sizeof( iManufacturer ) do
  begin
    if iManufacturer[ i ] = #0 then
    begin
      break;
    end
    else
    begin
      Result := Result + iManufacturer[ i ];
    end;
  end;
end;

procedure TUSBPanel.fSetManufacturer(NewVal : string );
var
  i : integer;
begin
  // should check size - to do
  for i := 1 to length( NewVal ) do
  begin
    iProgramData.Manufacturer[ i - 1 ] := NewVal[ i ];
  end;
  iProgramData.Manufacturer[ length( NewVal ) ] := #0;
end;

function  TUSBPanel.fGetManufacturerID : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to sizeof( iManufacturerID ) do
  begin
    if iManufacturerID[ i ] = #0 then
    begin
      break;
    end
    else
    begin
      Result := Result + iManufacturerID[ i ];
    end;
  end;
end;

procedure TUSBPanel.fSetManufacturerID( NewVal : string );
var
  i : integer;
begin
  // should check size - to do
  for i := 1 to length( NewVal ) do
  begin
    iProgramData.ManufacturerID[ i - 1 ] := NewVal[ i ];
  end;
  iProgramData.ManufacturerID[ length( NewVal ) ] := #0;
end;

function  TUSBPanel.fGetDescription : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to sizeof( iDescription ) - 1 do
  begin
    if iDescription[ i ] = #0 then
    begin
      break;
    end
    else
    begin
      Result := Result + iDescription[ i ];
    end;
  end;
end;

procedure TUSBPanel.fSetDescription( newVal : string );
var
  i : integer;
begin
  // should check size - to do
  for i := 1 to length( NewVal ) do
  begin
    iDescription[ i - 1 ] := NewVal[ i ];
  end;
  iDescription[ length( NewVal ) ] := #0;
end;

function  TUSBPanel.fGetSerialNo : string;
var
  i : integer;
begin
  Result := '';
  for i := 0 to sizeof( iSerialNo ) do
  begin
    if iSerialNo[ i ] = #0 then
    begin
      break;
    end
    else
    begin
      Result := Result + iSerialNo[ i ];
    end;
  end;
end;

procedure TUSBPanel.fSetSerialNo( NewVal : string );
var
  i : integer;
begin
  // should check size - to do
  for i := 1 to length( NewVal ) do
  begin
    iSerialNo[ i - 1 ] := NewVal[ i ];
  end;
  iSerialNo[ length( NewVal ) ] := #0;
end;

function  TUSBPanel.fGetMaxPower : word;
begin
  Result := iProgramData.MaxPower;
end;

procedure TUSBPanel.fSetMaxPower( NewVal : word );
begin
  if (NewVal > 0) and (NewVal <= 500) then
  begin
    iProgramData.MaxPower := NewVal;
  end
  else
  begin
    raise Exception.Create('USB Max power must lie in range 1-500' );
  end;
end;

function  TUSBPanel.fGetSelfPowered : tSelfPowered;
begin
  if iProgramData.SelfPowered = 0 then Result := spBusPowered
  else Result := spSelfPowered;
end;

procedure TUSBPanel.fSetSelfPowered( NewVal : tSelfPowered );
begin
  iProgramData.SelfPowered := Ord( NewVal );
end;

function  TUSBPanel.fGetRemoteWakeup : tRemoteWakeUp;
begin
  if iProgramData.RemoteWakeup = 0 then Result := rwuNotCapable
  else Result := rwuCapable;
end;

procedure TUSBPanel.fSetRemoteWakeup( NewVal : tRemoteWakeUp );
begin
  iProgramData.RemoteWakeup := Ord( NewVal );
end;

    //
    // Rev 4 extensions
    //
function  TUSBPanel.fGetRev4 : boolean;
begin
  Result := iProgramData.Rev4;
end;

procedure TUSBPanel.fSetRev4( NewVal : boolean );
begin
  iProgramData.Rev4 := NewVal;
end;

function  TUSBPanel.fGetIsoIn : boolean;
begin
  Result := iProgramData.IsoIn;
end;

procedure TUSBPanel.fSetIsoIn( NewVal : boolean );
begin
  iProgramData.IsoIn := NewVal;
end;

function  TUSBPanel.fGetIsoOut : boolean;
begin
  Result := iProgramData.IsoOut;
end;

procedure TUSBPanel.fSetIsoOut( NewVal : boolean );
begin
  iProgramData.IsoOut := NewVal;
end;

function  TUSBPanel.fGetPullDownEnable : boolean;
begin
  Result := iProgramData.PullDownEnable;
end;

procedure TUSBPanel.fSetPullDownEnable( NewVal : boolean );
begin
  iProgramData.PullDownEnable := NewVal;
end;

function  TUSBPanel.fGetSerNumEnable : boolean;
begin
  Result := iProgramData.SerNumEnable;
end;

procedure TUSBPanel.fSetSerNumEnable( NewVal : boolean );
begin
  iProgramData.SerNumEnable := NewVal;
end;

function  TUSBPanel.fGetUSBVersion : string;
begin
  Result := IntToHex( iProgramData.USBVersion, 4 );
end;

procedure TUSBPanel.fSetUSBVersion( NewVal : string );
begin
  iProgramData.USBVersion := StrToInt( '$' + NewVal );
end;

procedure TUSBPanel.fSetFlowControl( NewVal : TFlowControl ); // FT_FLOW_NONE = fcNone
begin
  if NewVal <> FlowControl then
  begin
    case NewVal of
      fcNone:     iFlowControl := FT_FLOW_NONE;
      fcRTS_CTS:  iFlowControl := FT_FLOW_RTS_CTS;
      fcDTR_DSR:  iFlowControl := FT_FLOW_DTR_DSR;
      fcXON_XOFF: iFlowControl := FT_FLOW_XON_XOFF;
    end;
    fWriteFlowControl;
  end;
end;

function  TUSBPanel.fGetFlowControl : TFlowControl;
begin
  case iFlowControl of
    FT_FLOW_NONE:     Result := fcNone;
    FT_FLOW_RTS_CTS:  Result := fcRTS_CTS;
    FT_FLOW_DTR_DSR:  Result := fcDTR_DSR;
    FT_FLOW_XON_XOFF: REsult := fcXON_XOFF;
  else
    raise Exception.Create( 'Illegal Flow control setting.' );
  end;
end;

procedure TUSBPanel.fSetXON( NewVal : byte );  // 17  = ^Q
begin
  if NewVal <> iXON then
  begin
    iXON := NewVal;
    if FlowControl = fcXON_XOFF then
    begin
      // Don't care for any other setting
      fWriteFlowControl;
    end;
  end;
end;

procedure TUSBPanel.fSetXOFF( NewVal : byte ); // 19  = ^S
begin
  if NewVal <> iXOFF then
  begin
    iXOFF := NewVal;
    if FlowControl = fcXON_XOFF then
    begin
      // Don't care for any other setting
      fWriteFlowControl;
    end;
  end;
end;

procedure TUSBPanel.fWriteFlowControl;
begin
  if not (csDesigning in ComponentState ) then
  begin
    if assigned( FT_SetFlowControl ) then
    begin
      if iOpen then
      begin
        FT_ERROR_CHECK( 'writing flow control',
        FT_SetFlowControl( self.iFT_Handle, iFlowControl, iXON, iXOFF ));
      end;
    end;
  end;
end;

procedure TUSBPanel.fSetDTR( NewVal : tLineState );
begin
  if NewVal <> iDTR then
  begin
    iDTR := NewVal;
    if not (csDesigning in ComponentState ) then
    begin
      if iOpen then
      begin
        if NewVal = lsSet then
        begin
          if assigned( FT_ClrDTR ) then
          begin
            FT_ClrDTR( iFT_Handle );
          end;
        end
        else
        begin
          if assigned( FT_SetDTR ) then
          begin
            FT_SetDTR( iFT_Handle );
          end;
        end;
      end;
    end;
  end;
end;

procedure TUSBPanel.fSetRTS( NewVal : tLineState );
begin
  if NewVal <> iRTS then
  begin
    iRTS := NewVal;
    if not (csDesigning in ComponentState ) then
    begin
      if iOpen then
      begin
        if NewVal = lsSet then
        begin
          if assigned( FT_ClrRTS ) then
          begin
            FT_ClrRTS( iFT_Handle );
          end;
        end
        else
        begin
          if assigned( FT_SetRTS ) then
          begin
            FT_SetRTS( iFT_Handle );
          end;
        end;
      end;
    end;
  end;
end;

procedure TUSBPanel.fSetBreak( NewVal : tLineState );
begin
  if NewVal <> iBreak then
  begin
    iBreak := NewVal;
    if not (csDesigning in ComponentState ) then
    begin
      if iOpen then
      begin
        if NewVal = lsSet then
        begin
          if assigned( FT_SetBreakOff ) then
          begin
            FT_SetBreakOff( iFT_Handle );
          end;
        end
        else
        begin
          if assigned( FT_SetBreakOn ) then
          begin
            FT_SetBreakOn( iFT_Handle );
          end;
        end;
      end;
    end;
  end;
end;

procedure TUSBPanel.Purge( Mask : dword );
begin
  if iOpen then
  begin
    if assigned( FT_Purge ) then
    begin
      FT_Error_Check( 'attempting to Purge',
                      FT_Purge( iFT_Handle, Mask ));
    end;
  end;
end;

function TUSBPanel.FT_Error_Check(ErrStr: String; PortStatus : Integer) : boolean;
var
  Str : String;
begin
  if PortStatus = FT_OK then
  begin
    result := TRUE;
  end
  else
  begin
    case PortStatus of
      FT_INVALID_HANDLE : Str := 'Error ' + ErrStr + ' - Invalid Handle...';
      FT_DEVICE_NOT_FOUND : Str := 'Error ' + ErrStr + ' - Device Not Found....';
      FT_DEVICE_NOT_OPENED : Str := 'Error ' + ErrStr + ' - Device Not Opened...';
      FT_IO_ERROR : Str := 'Error ' + ErrStr + ' - General IO Error...';
      FT_INSUFFICIENT_RESOURCES : Str := 'Error ' + ErrStr + ' - Insufficient Resources...';
      FT_INVALID_PARAMETER : Str := 'Error ' + ErrStr + ' - Invalid Parameter ...';
    end;
    result := FALSE;
    if ErrorStyle = esThrowErrors then
    begin
      raise Exception.Create( Str );
    end
    else if ErrorStyle = esPopUpErrors then
    begin
      MessageDlg(Str, mtError, [mbOk], 0);
    end;
  end;
end;

end.
