program ProjectSigFile7PropertyEditor;

uses
  Vcl.Forms,
  UnitSigFile7PropertyEditorMain in 'UnitSigFile7PropertyEditorMain.pas' {Form2},
  DlgLinkedComponents in 'DlgLinkedComponents.pas' {FormSigFile7PropertyEditor},
  SigPanel in '..\..\SigPanel\SigPanel.pas',
  UnitSigFile7LinkedComponentsPropertyEditor in 'UnitSigFile7LinkedComponentsPropertyEditor.pas',
  SigFile7 in '\\psf\Home\Delphi Projects\Lib\SigFile\SigFile7.pas',
  UnitListComponents in '\\psf\Home\Delphi Projects\Lib\SigFile\UnitListComponents.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TFormSigFile7PropertyEditor, FormSigFile7PropertyEditor);
  Application.Run;
end.
