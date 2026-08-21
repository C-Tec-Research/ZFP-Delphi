program ProjectThreadComponentTest;

uses
  Vcl.Forms,
  UnitThreadComponentTest in 'UnitThreadComponentTest.pas' {FormThreadsafeTest},
  UnitThreadSafeComponents in 'UnitThreadSafeComponents.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormThreadsafeTest, FormThreadsafeTest);
  Application.Run;
end.
