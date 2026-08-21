unit SetupAPI;

interface

uses
  Windows;

type
  HDEVINFO = pointer;

type
  SP_DEVICE_INTERFACE_DATA  = record
    cbSize : DWORD;
    InterfaceClassGuid : TGUID;
    Flags : DWORD;
    Reserved : ULONG_PTR;
  end;


implementation

function SetupEnumAvailableComPorts:TstringList;
// Enumerates all serial communications ports that are available and ready to
// be used.

// For the setupapi unit see
// http://homepages.borland.com/jedi/cms/modules/apilib/visit.php?cid=4&lid=3

var
  RequiredSize:             Cardinal;
  Guid:                     TGUID;
  DevInfoHandle:            HDEVINFO;
  DeviceInfoData:           TSPDevInfoData;
  MemberIndex:              Cardinal;
  PropertyRegDataType:      DWord;
  RegProperty:              Cardinal;
  RegTyp:                   Cardinal;
  Key:                      Hkey;
  Info:                     TRegKeyInfo;
  S1,S2:                    string;
  hc:                       THandle;
begin
  Result:=Nil;
//If we cannot access the setupapi.dll then we return a nil pointer.
  if not LoadsetupAPI then exit;
  try
// get 'Ports' class guid from name
    if SetupDiClassGuidsFromName('Ports',@Guid,RequiredSize,RequiredSize) then begin
//get object handle of 'Ports' class to interate all devices
       DevInfoHandle:=SetupDiGetClassDevs(@Guid,Nil,0,DIGCF_PRESENT);
       if Cardinal(DevInfoHandle)<>Invalid_Handle_Value then begin
         try
           MemberIndex:=0;
           result:=TStringList.Create;
//iterate device list
           repeat
             FillChar(DeviceInfoData,SizeOf(DeviceInfoData),0);
             DeviceInfoData.cbSize:=SizeOf(DeviceInfoData);
//get device info that corresponds to the next memberindex
             if Not SetupDiEnumDeviceInfo(DevInfoHandle,MemberIndex,DeviceInfoData) then
               break;
//query friendly device name LIKE 'BlueTooth Communication Port (COM8)' etc
             RegProperty:=SPDRP_FriendlyName;{SPDRP_Driver, SPDRP_SERVICE, SPDRP_ENUMERATOR_NAME,SPDRP_PHYSICAL_DEVICE_OBJECT_NAME,SPDRP_FRIENDLYNAME,}
             SetupDiGetDeviceRegistryProperty(DevInfoHandle,DeviceInfoData,
                                                   RegProperty,
                                                   @PropertyRegDataType,
                                                   NIL,0,@RequiredSize);
             SetLength(S1,RequiredSize);
             if SetupDiGetDeviceRegistryProperty(DevInfoHandle,DeviceInfoData,
                                                 RegProperty,
                                                 @PropertyRegDataType,
                                                 @S1[1],RequiredSize,@RequiredSize) then begin
               KEY:=SetupDiOpenDevRegKey(DevInfoHandle,DeviceInfoData,DICS_FLAG_GLOBAL,0,DIREG_DEV,KEY_READ);
               if key<>INValid_Handle_Value then begin
                 FillChar(Info, SizeOf(Info), 0);
//query the real port name from the registry value 'PortName'
                 if RegQueryInfoKey(Key, nil, nil, nil, @Info.NumSubKeys,@Info.MaxSubKeyLen, nil, @Info.NumValues, @Info.MaxValueLen,
                                                        @Info.MaxDataLen, nil, @Info.FileTime) = ERROR_SUCCESS then begin
                   RequiredSize:= Info.MaxValueLen + 1;
                   SetLength(S2,RequiredSize);
                   if RegQueryValueEx(KEY,'PortName',Nil,@Regtyp,@s2[1],@RequiredSize)=Error_Success then begin
                     If (Pos('COM',S2)=1) then begin
//Test if the device can be used
                       hc:=CreateFile(pchar('\\.\'+S2+#0),
                                      GENERIC_READ or GENERIC_WRITE,
                                      0,
                                      nil,
                                      OPEN_EXISTING,
                                      FILE_ATTRIBUTE_NORMAL,
                                      0);
                       if hc<> INVALID_HANDLE_VALUE then begin
                         Result.Add(Strpas(PChar(S2))+': = '+StrPas(PChar(S1)));
                         CloseHandle(hc);
                       end;
                     end;
                   end;
                 end;
                 RegCloseKey(key);
               end;
             end;
             Inc(MemberIndex);
           until False;
//If we did not found any free com. port we return a NIL pointer.
           if Result.Count=0 then begin
             Result.Free;
             Result:=NIL;

           end
         finally
           SetupDiDestroyDeviceInfoList(DevInfoHandle);
         end;
       end;
    end;
  finally
    UnloadSetupApi;
  end;
end;


end.
