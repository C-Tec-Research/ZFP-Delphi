unit UnitExpertModes;

interface

type
  TErrorReportingLevel = ( elErrors_Warnings_Hints, el_Errors_Warnings, el_Errors, el_None );
  TExpertMode  =   ( em_Allow_Cfg_from_remote_panels,
                     em_Show_Advanced_Send_Rcv,
                     em_Use_Threading,
                     em_Check_USB_Status,
                     em_Use_Full_Dictionaries,
                     em_View_Log_as_Table,
                     em_Unlock_System_Devices,
                     em_Allow_File_Transfer,
                     em_Show_Errors_Tab,
                     em_Show_Import_Export,
                     em_Auto_Reload_Last_Saved_File,
                     em_Show_ValidationButtons );

  tExpertModes = set of tExpertMode;

const
  em_Simple =      [ em_View_Log_as_Table, em_Allow_Cfg_from_remote_panels ];
  em_Expert =      [ em_Show_Advanced_Send_Rcv, em_Allow_Cfg_from_remote_panels,
                     em_View_Log_as_Table, em_Allow_File_Transfer, em_Show_Import_Export ];

var
  ExpertModes : tExpertModes;
  ErrorReportingLevel : TErrorReportingLevel;

implementation

end.
