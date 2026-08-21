program SigFileDebug;

uses
  Forms,
  UnitSigFileDebug in 'UnitSigFileDebug.pas' {FormSigFileDebug},
  UnitSigFileGUI in 'UnitSigFileGUI.pas' {FormSigFileGUI},
  UnitSigFileAnalyser in 'UnitSigFileAnalyser.pas',
  UnitProjectExportFile in 'UnitProjectExportFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSigFileDebug, FormSigFileDebug);
  Application.CreateForm(TFormSigFileDebug, FormSigFileDebug);
  Application.CreateForm(TFormSigFileGUI, FormSigFileGUI);
  Application.Run;
end.
