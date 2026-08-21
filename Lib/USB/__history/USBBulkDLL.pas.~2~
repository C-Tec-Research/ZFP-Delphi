{
/*********************************************************************
*                SEGGER MICROCONTROLLER GmbH                         *
*        Solutions for real time microcontroller applications        *
**********************************************************************
*                                                                    *
*        (c) 2021-2021     SEGGER Microcontroller GmbH               *
*                                                                    *
*        Internet: www.segger.com    Support:  support@segger.com    *
*                                                                    *
**********************************************************************
----------------------------------------------------------------------
Purpose : Host USB API to access USB devices
---------------------------END-OF-HEADER------------------------------
*/
}
unit USBBulkDLL;
{$MINENUMSIZE 4}
interface

const
  {$IF Defined(WIN32)}
  LIB_USBBULK = 'Drivers\Lib32\USBBulk.dll';
  {$ELSEIF Defined(WIN64)}
  LIB_USBBULK = 'Drivers\Lib64\USBBulk.dll';
  {$ELSE}
    {$MESSAGE Error 'Unsupported platform'}
  {$ENDIF}

const
  { TODO : Macro probably uses invalid symbol "unsigned": }
  (* U8 unsigned char *)
  { TODO : Macro probably uses invalid symbol "unsigned": }
  (* U16 unsigned short *)
  { TODO : Macro probably uses invalid symbol "unsigned": }
  (* U32 unsigned int *)
  { TODO : Macro probably uses invalid symbol "signed": }
  (* I8 signed char *)
  { TODO : Macro probably uses invalid symbol "signed": }
  (* I16 signed short *)
  { TODO : Macro probably uses invalid symbol "signed": }
  (* I32 signed int *)
  { TODO : Macro probably uses invalid symbol "unsigned": }
  (* U64 unsigned __int64 *)
  { TODO : Macro probably uses invalid symbol "signed": }
  (* I64 signed __int64 *)
  { TODO : Unable to convert function-like macro: }
  (* U64_C ( x ) x ## ULL *)
  { TODO : Unable to convert function-like macro: }
  (* I64_C ( x ) x ## LL *)
  { TODO : Macro uses commented-out symbol "U64": }
  (* PTR_ADDR U64 *)
  USBBULK_BUFFERSIZE = (64*1024);
  USBBULK_MAX_DEVICES = 10;
  USBBULK_MODE_BIT_ALLOW_SHORT_READ = (1 shl 0);
  USBBULK_MODE_BIT_ALLOW_SHORT_WRITE = (1 shl 1);
  USBBULK_MTYPE_INIT = (1 shl 0);
  USBBULK_MTYPE_CORE = (1 shl 1);
  USBBULK_MTYPE_DEVICE = (1 shl 2);
  USBBULK_MTYPE_API = (1 shl 3);
  USBBULK_MTYPE_READ = (1 shl 4);
  USBBULK_MTYPE_WRITE = (1 shl 5);
  USBBULK_MTYPE_LOCK = (1 shl 6);
  USBBULK_MTYPE_APPLICATION = (1 shl 31);
  USBBULK_SETUP_REQUEST_HOST_TO_DEVICE = ($00);
  USBBULK_SETUP_REQUEST_DEVICE_TO_HOST = ($80);
  USBBULK_SETUP_REQUEST_VENDOR = ($40);
  USBBULK_SETUP_REQUEST_CLASS = ($20);
  USBBULK_SETUP_REQUEST_STANDARD = ($00);
  USBBULK_SETUP_REQUEST_DEVICE = ($00);
  USBBULK_SETUP_REQUEST_INTERFACE = ($01);
  USBBULK_SETUP_REQUEST_ENDPOINT = ($02);
  USBBULK_SETUP_REQUEST_OTHER = ($03);
  USBBULK_SPEED_UNKNOWN = 0;
  USBBULK_SPEED_LOW = 1;
  USBBULK_SPEED_FULL = 2;
  USBBULK_SPEED_HIGH = 3;
  USBBULK_SPEED_SUPER = 4;

type
  UTF8Char = AnsiChar;
  PUTF8Char = ^AnsiChar;
  (*********************************************************************
   *
   *       Types
   *
   **********************************************************************
   *)
  _USBBULK_DEVICE_EVENT = (
    USBBULK_DEVICE_EVENT_ADD = 0,
    USBBULK_DEVICE_EVENT_REMOVE = 1);
  P_USBBULK_DEVICE_EVENT = ^_USBBULK_DEVICE_EVENT;
  (*********************************************************************
   *
   *       Types
   *
   **********************************************************************
   *)
  USBBULK_DEVICE_EVENT = _USBBULK_DEVICE_EVENT;

  _USBBULK_DEV_INFO = record
    VendorId: Word;
    ProductId: Word;
    acSN: array [0..255] of UTF8Char;
    acDevName: array [0..254] of UTF8Char;
    InterfaceNo: Byte;
    Speed: Byte;
  end;

  USBBULK_DEV_INFO = _USBBULK_DEV_INFO;
  PUSBBULK_DEV_INFO = ^USBBULK_DEV_INFO;

  _USBBULK_SETUP_REQUEST = record
    bRequestType: Byte;
    bRequest: Byte;
    wValue: Word;
    wIndex: Word;
    wLength: Word;
  end;

  USBBULK_SETUP_REQUEST = _USBBULK_SETUP_REQUEST;
  PUSBBULK_SETUP_REQUEST = ^USBBULK_SETUP_REQUEST;
  USB_BULK_HANDLE = Integer;

  PUSBBULK_NOTIFICATION_FUNC = procedure(pContext: Pointer; Index: Cardinal; Event: USBBULK_DEVICE_EVENT); stdcall;

  PUSBBULK_LOG_FUNC = procedure(const sLog: PUTF8Char); stdcall;

  PUSBBULK_WARN_FUNC = procedure(const sWarn: PUTF8Char); stdcall;


(*********************************************************************
 *
 *       USB-Bulk basic functions
 *)
procedure USBBULK_Close(hDevice: USB_BULK_HANDLE); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
    name '_USBBULK_Close@4'
  {$Endif}
  ;

function USBBULK_Open(DevIndex: Cardinal): USB_BULK_HANDLE; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Open@4'
  {$Endif}
  ;

function USBBULK_OpenTimed(DevIndex: Cardinal; Timeout: Integer): USB_BULK_HANDLE; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Open@4'
  {$Endif}
  ;


function USBBULK_GetDevInfoByIdx(Idx: Cardinal; var pDevInfo: USBBULK_DEV_INFO): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Open@4'
  {$Endif}
  ;

procedure USBBULK_Init(pfNotification: PUSBBULK_NOTIFICATION_FUNC; pContext: Pointer); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Init@8'
  {$Endif}
  ;

procedure USBBULK_Exit(); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Exit@0'
  {$Endif}
  ;

procedure USBBULK_AddAllowedDeviceItem(VendorId: Word; ProductId: Word); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_AddAllowedDeviceItem@8'
  {$Endif}
  ;


procedure USBBULK_RemoveAllowedDeviceItem(VendorId: Word; ProductId: Word); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_RemoveAllowedDeviceItem@8'
  {$Endif}
  ;


(*********************************************************************
 *
 *       USB-Bulk direct input/output functions
 *)
function USBBULK_Read(hDevice: USB_BULK_HANDLE; pBuffer: Pointer; NumBytes: Integer): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Read@12'
  {$Endif}
  ;

function USBBULK_Write(hDevice: USB_BULK_HANDLE; const pBuffer: Pointer; NumBytes: Integer): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_Write@12'
  {$Endif}
  ;

procedure USBBULK_CancelRead(hDevice: USB_BULK_HANDLE); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_CancelRead@4'
  {$Endif}
  ;

function USBBULK_ReadTimed(hDevice: USB_BULK_HANDLE; pBuffer: Pointer; NumBytes: Integer; ms: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_ReadTimed@16'
  {$Endif}
  ;

function USBBULK_WriteTimed(hDevice: USB_BULK_HANDLE; const pBuffer: Pointer; NumBytes: Integer; ms: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_WriteTimed@16'
  {$Endif}
  ;

function USBBULK_WriteEx(hDevice: USB_BULK_HANDLE; const pBuffer: Pointer; NumBytes: Integer; ms: Cardinal; Send0PacketIfRequired: Integer): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_WriteEx@20'
  {$Endif}
  ;

function USBBULK_FlushRx(hDevice: USB_BULK_HANDLE): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_FlushRx@4'
  {$Endif}
  ;

function USBBULK_SetupRequest(hDevice: USB_BULK_HANDLE; var pSetupRequest: USBBULK_SETUP_REQUEST; pBuffer: Pointer; pBufferSize: PCardinal; Timeout: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetupRequest@20'
  {$Endif}
  ;

(*********************************************************************
 *
 *       USB-Bulk control functions
 *)
function USBBULK_GetConfigDescriptor(hDevice: USB_BULK_HANDLE; pBuffer: Pointer; Size: Integer): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetConfigDescriptor@12'
  {$Endif}
  ;

function USBBULK_GetMode(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetMode@4'
  {$Endif}
  ;

function USBBULK_GetReadMaxTransferSize(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetReadMaxTransferSize@4'
  {$Endif}
  ;

function USBBULK_GetWriteMaxTransferSize(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetWriteMaxTransferSize@4'
  {$Endif}
  ;

function USBBULK_GetReadMaxPacketSize(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetReadMaxPacketSize@4'
  {$Endif}
  ;

function USBBULK_GetWriteMaxPacketSize(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetWriteMaxPacketSize@4'
  {$Endif}
  ;

function USBBULK_ResetINPipe(hDevice: USB_BULK_HANDLE): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_ResetINPipe@4'
  {$Endif}
  ;

function USBBULK_ResetOUTPipe(hDevice: USB_BULK_HANDLE): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_ResetOUTPipe@4'
  {$Endif}
  ;

function USBBULK_ResetDevice(hDevice: USB_BULK_HANDLE): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_ResetDevice@4'
  {$Endif}
  ;

function USBBULK_SetMode(hDevice: USB_BULK_HANDLE; Mode: Cardinal): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetMode@8'
  {$Endif}
  ;

procedure USBBULK_SetReadTimeout(hDevice: USB_BULK_HANDLE; Timeout: Integer); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetReadTimeout@8'
  {$Endif}
  ;

procedure USBBULK_SetWriteTimeout(hDevice: USB_BULK_HANDLE; Timeout: Integer); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetWriteTimeout8'
  {$Endif}
  ;

function USBBULK_GetEnumTickCount(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetEnumTickCount@4'
  {$Endif}
  ;

function USBBULK_GetReadMaxTransferSizeDown(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetReadMaxTransferSizeDown@4'
  {$Endif}
  ;

function USBBULK_GetWriteMaxTransferSizeDown(hDevice: USB_BULK_HANDLE): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetWriteMaxTransferSizeDown@4'
  {$Endif}
  ;

function USBBULK_SetWriteMaxTransferSizeDown(hDevice: USB_BULK_HANDLE; TransferSize: Cardinal): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetWriteMaxTransferSizeDown@8'
  {$Endif}
  ;

function USBBULK_SetReadMaxTransferSizeDown(hDevice: USB_BULK_HANDLE; TransferSize: Cardinal): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetReadMaxTransferSizeDown@8'
  {$Endif}
  ;

function USBBULK_GetSN(hDevice: USB_BULK_HANDLE; pBuffer: PByte; BufferSize: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetSN@12'
  {$Endif}
  ;

procedure USBBULK_GetDevInfo(hDevice: USB_BULK_HANDLE; var DevInfo: USBBULK_DEV_INFO); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetDevInfo@8'
  {$Endif}
  ;

procedure USBBULK_GetUSBId(hDevice: USB_BULK_HANDLE; var pVendorIdMask: Word; var pProductIdMask: PWord); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetUSBId@12'
  {$Endif}
  ;

function USBBULK_GetProductName(hDevice: USB_BULK_HANDLE; sProductName: PUTF8Char; BufferSize: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetProductName@12'
  {$Endif}
  ;

function USBBULK_GetVendorName(hDevice: USB_BULK_HANDLE; sVendorName: PUTF8Char; BufferSize: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetVendorName@12'
  {$Endif}
  ;

function USBBULK_GetLocationInfo(hDevice: USB_BULK_HANDLE; pBuffer: PUTF8Char; NumBytesBuffer: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetLocationInfo@12'
  {$Endif}
  ;

function USBBULK_GetStringDesc(hDevice: USB_BULK_HANDLE; StringIndex: Cardinal; pBuffer: PByte; BufferSize: Cardinal): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetStringDesc@16'
  {$Endif}
  ;

function USBBULK_SetAlternateSetting(hDevice: USB_BULK_HANDLE; AlternateSetting: Byte): Integer; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetAlternateSetting@8'
  {$Endif}
  ;

(*********************************************************************
 *
 *       USB-Bulk general GET functions
 *)
function USBBULK_GetDriverCompileDate(s: PUTF8Char; Size: Cardinal): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetDriverCompileDate@8'
  {$Endif}
  ;

function USBBULK_GetDriverVersion(): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetDriverVersion@0'
  {$Endif}
  ;

function USBBULK_GetVersion(): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetVersion@0'
  {$Endif}
  ;

function USBBULK_GetNumAvailableDevices(pMask: PCardinal): Cardinal; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetNumAvailableDevices@4'
  {$Endif}
  ;

function USBBULK_GetGUID(): TGUID; stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_GetGUID@4'
  {$Endif}
  ;

type
  USBBULK_EnableLog_pfLog = procedure(); stdcall;

type
  USBBULK_EnableLog_pfWarn = procedure(); stdcall;

(*********************************************************************
 *
 *       USB-Bulk logging functions
 *)
procedure USBBULK_EnableLog(pfLog: USBBULK_EnableLog_pfLog; pfWarn: USBBULK_EnableLog_pfWarn); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_AddAllowedDeviceItem@8'
  {$Endif}
  ;

procedure USBBULK_SetLogFilter(FilterMask: Cardinal); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_AddAllowedDeviceItem@8'
  {$Endif}
  ;

procedure USBBULK_SetWarnFilter(FilterMask: Cardinal); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_SetWarnFilter@4'
  {$Endif}
  ;

procedure USBBULK_AddLogFilter(FilterMask: Cardinal); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_AddLogFilter@4'
  {$Endif}
  ;

procedure USBBULK_AddWarnFilter(FilterMask: Cardinal); stdcall;
  external LIB_USBBULK
  {$IF Defined(WIN32)}
  name '_USBBULK_AddWarnFilter@4'
  {$Endif}
  ;

implementation

end.
