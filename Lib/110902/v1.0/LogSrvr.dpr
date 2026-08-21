program LogSrvr;

uses
  Forms,
  Main in '\Alvin\Dev32\SigLogServer\Main.pas' {MainForm},
  Usercmt in '\Alvin\Dev32\SigLog\USERCMT.PAS' {DlgUserComment},
  COLOPTS in '\Alvin\Dev32\SigLogServer\COLOPTS.PAS' {ColOptDlg},
  PRINTING in '\Alvin\Dev32\SigLogServer\PRINTING.PAS' {DlgPrint},
  LOGDLG in '\Alvin\Dev32\SigLogServer\LOGDLG.PAS' {LogDialog},
  Common in '\Alvin\SigNET\Common\Common.pas',
  sigtime in '\Alvin\Dev32\SigLogServer\sigtime.pas';

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDlgUserComment, DlgUserComment);
  Application.CreateForm(TColOptDlg, ColOptDlg);
  Application.CreateForm(TDlgPrint, DlgPrint);
  Application.CreateForm(TLogDialog, LogDialog);
  Application.Run;
end.
