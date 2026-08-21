program SigDBConsole;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  about in 'about.pas' {AboutBox},
  SelectableEdit in '..\SelectableEdit\SelectableEdit.pas',
  SigFile in 'SigFile.pas',
  ErrorList in '..\ErrorList\ErrorList.pas',
  UnitUndoList in '..\UndoRedo\UnitUndoList.pas',
  PrevPrinter in '..\Printer\PrevPrinter.pas',
  SigDBFiles in 'SigDBFiles.pas',
  SigFilePgmStatus in 'SigFilePgmStatus.pas',
  SigSaveDialog in '..\SigSave\SigSaveDialog.pas',
  UnitFileNotSaved in '..\FileNotSaved\UnitFileNotSaved.pas' {FormFileNotSaved},
  Common in '..\Common\Common.pas',
  sigparse in '..\Common\sigparse.pas',
  PageSetupDlg in '..\Printer\PageSetupDlg.pas' {PageSetupForm},
  FormSettings in '..\Printer\FormSettings.pas',
  PrevForm in '..\Printer\PrevForm.pas' {PreviewForm},
  Gopage in '..\Printer\Gopage.pas' {GoPageForm},
  PendingActions in '..\PendingActions\PendingActions.pas',
  UnitNew in 'UnitNew.pas' {FormNewFile},
  SigGeneralGrid in '..\SigStringGrid\SigGeneralGrid.pas',
  SigBTree in '..\SigBTree\SigBTree.pas',
  UnitChangeTableName in 'UnitChangeTableName.pas' {FormChangeTableName},
  TimeSpinButton in '..\TimeSpinButton\TimeSpinButton.pas',
  UnitFormatSigDBWarning in 'UnitFormatSigDBWarning.pas' {FormFormat},
  SigDBRawDB in 'SigDBRawDB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TFormFileNotSaved, FormFileNotSaved);
  Application.CreateForm(TPageSetupForm, PageSetupForm);
  Application.CreateForm(TGoPageForm, GoPageForm);
  Application.CreateForm(TGoPageForm, GoPageForm);
  Application.CreateForm(TFormNewFile, FormNewFile);
  Application.CreateForm(TFormChangeTableName, FormChangeTableName);
  Application.CreateForm(TFormFormat, FormFormat);
  Application.Run;
end.
