program SigFile7Test;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitSigFile7Test in 'UnitSigFile7Test.pas' {Form1},
  SigFile7 in 'SigFile7.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
