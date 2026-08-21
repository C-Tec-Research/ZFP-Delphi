unit WinIOCtl;

interface

uses
  Windows;

function CTL_CODE( pDeviceType, pFunction, pMethod, pAccess : DWord ) : DWord;

type DEVICE_TYPE = DWORD;

const FILE_DEVICE_BEEP                = $00000001;
const FILE_DEVICE_CD_ROM              = $00000002;
const FILE_DEVICE_CD_ROM_FILE_SYSTEM  = $00000003;
const FILE_DEVICE_CONTROLLER          = $00000004;
const FILE_DEVICE_DATALINK            = $00000005;
const FILE_DEVICE_DFS                 = $00000006;
const FILE_DEVICE_DISK                = $00000007;
const FILE_DEVICE_DISK_FILE_SYSTEM    = $00000008;
const FILE_DEVICE_FILE_SYSTEM         = $00000009;
const FILE_DEVICE_INPORT_PORT         = $0000000a;
const FILE_DEVICE_KEYBOARD            = $0000000b;
const FILE_DEVICE_MAILSLOT            = $0000000c;
const FILE_DEVICE_MIDI_IN             = $0000000d;
const FILE_DEVICE_MIDI_OUT            = $0000000e;
const FILE_DEVICE_MOUSE               = $0000000f;
const FILE_DEVICE_MULTI_UNC_PROVIDER  = $00000010;
const FILE_DEVICE_NAMED_PIPE          = $00000011;
const FILE_DEVICE_NETWORK             = $00000012;
const FILE_DEVICE_NETWORK_BROWSER     = $00000013;
const FILE_DEVICE_NETWORK_FILE_SYSTEM = $00000014;
const FILE_DEVICE_NULL                = $00000015;
const FILE_DEVICE_PARALLEL_PORT       = $00000016;
const FILE_DEVICE_PHYSICAL_NETCARD    = $00000017;
const FILE_DEVICE_PRINTER             = $00000018;
const FILE_DEVICE_SCANNER             = $00000019;
const FILE_DEVICE_SERIAL_MOUSE_PORT   = $0000001a;
const FILE_DEVICE_SERIAL_PORT         = $0000001b;
const FILE_DEVICE_SCREEN              = $0000001c;
const FILE_DEVICE_SOUND               = $0000001d;
const FILE_DEVICE_STREAMS             = $0000001e;
const FILE_DEVICE_TAPE                = $0000001f;
const FILE_DEVICE_TAPE_FILE_SYSTEM    = $00000020;
const FILE_DEVICE_TRANSPORT           = $00000021;
const FILE_DEVICE_UNKNOWN             = $00000022;
const FILE_DEVICE_VIDEO               = $00000023;
const FILE_DEVICE_VIRTUAL_DISK        = $00000024;
const FILE_DEVICE_WAVE_IN             = $00000025;
const FILE_DEVICE_WAVE_OUT            = $00000026;
const FILE_DEVICE_8042_PORT           = $00000027;
const FILE_DEVICE_NETWORK_REDIRECTOR  = $00000028;
const FILE_DEVICE_BATTERY             = $00000029;
const FILE_DEVICE_BUS_EXTENDER        = $0000002a;
const FILE_DEVICE_MODEM               = $0000002b;
const FILE_DEVICE_VDM                 = $0000002c;
const FILE_DEVICE_MASS_STORAGE        = $0000002d;
const FILE_DEVICE_SMB                 = $0000002e;
const FILE_DEVICE_KS                  = $0000002f;
const FILE_DEVICE_CHANGER             = $00000030;
const FILE_DEVICE_SMARTCARD           = $00000031;
const FILE_DEVICE_ACPI                = $00000032;
const FILE_DEVICE_DVD                 = $00000033;
const FILE_DEVICE_FULLSCREEN_VIDEO    = $00000034;
const FILE_DEVICE_DFS_FILE_SYSTEM     = $00000035;
const FILE_DEVICE_DFS_VOLUME          = $00000036;
const FILE_DEVICE_SERENUM             = $00000037;
const FILE_DEVICE_TERMSRV             = $00000038;
const FILE_DEVICE_KSEC                = $00000039;
const FILE_DEVICE_FIPS                = $0000003A;
const FILE_DEVICE_INFINIBAND          = $0000003B;

const METHOD_BUFFERED                = 0;
const METHOD_IN_DIRECT               = 1;
const METHOD_OUT_DIRECT              = 2;
const METHOD_NEITHER                 = 3;

const FILE_ANY_ACCESS                = 0;
const FILE_SPECIAL_ACCESS            = (FILE_ANY_ACCESS);
const FILE_READ_ACCESS               = ( $0001 );    // file & pipe
const FILE_WRITE_ACCESS              = ( $0002 );    // file & pipe



implementation

function CTL_CODE( pDeviceType, pFunction, pMethod, pAccess : DWord ) : DWord;
begin
  Result := ((pDeviceType) shl 16) or ((pAccess) shl 14) or ((pFunction) shl 2) or (pMethod);
end;


end.
