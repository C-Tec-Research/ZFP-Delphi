program ProjectTimeSpinButtonTest;

uses
  Forms,
  UnitTimeSpinButtonTest in 'UnitTimeSpinButtonTest.pas' {Form1},
  TimeSpinButton in 'TimeSpinButton.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
