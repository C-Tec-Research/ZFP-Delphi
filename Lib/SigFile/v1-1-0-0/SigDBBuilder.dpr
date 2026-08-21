program SigDBBuilder;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  about in 'about.pas' {AboutBox},
  SelectableEdit in '..\SelectableEdit\SelectableEdit.pas',
  SigFile in 'SigFile.pas',
  ErrorList in '..\ErrorList\ErrorList.pas',
  PrevPrinter in '..\Printer\PrevPrinter.pas',
  UnitFiles in 'UnitFiles.pas',
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
  UnitUndoList in '..\UndoRedo\UnitUndoList.pas',
  TimeSpinButton in '..\TimeSpinButton\TimeSpinButton.pas',
  ThreadObjectList in '..\ThreadObjectList\ThreadObjectList.pas',
  SigPanel in '..\SigPanel\SigPanel.pas',
  SigBTree in '..\SigBTree\SigBTree.pas',
  SigCrypt in '..\SigCrypt\SigCrypt.pas',
  UnitSigStrings in '..\SigStrings\UnitSigStrings.pas',
  TypedObjectList in '..\Common\TypedObjectList.pas',
  DCPblockciphers in '..\SigCrypt\dcpcrypt2\DCPblockciphers.pas',
  DCPcrypt2 in '..\SigCrypt\dcpcrypt2\DCPcrypt2.pas',
  DCPbase64 in '..\SigCrypt\dcpcrypt2\DCPbase64.pas',
  DCPconst in '..\SigCrypt\dcpcrypt2\DCPconst.pas',
  DCPrijndael in '..\SigCrypt\dcpcrypt2\Ciphers\DCPrijndael.pas',
  UnitSetAnalysis in 'UnitSetAnalysis.pas',
  UnitSigBtreePaintbox in '..\SigBTree\UnitSigBtreePaintbox.pas',
  SigRegistry in '..\SigRegistry\SigRegistry.pas',
  SigSpinEdit in '..\SigSpinEdit\SigSpinEdit.pas',
  UnitTreeViewHelper in 'UnitTreeViewHelper.pas';

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
  Application.Run;
end.
