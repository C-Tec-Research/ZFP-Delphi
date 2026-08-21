program SigBTreeTest;

uses
  Vcl.Forms,
  UnitSigBTreeTest in 'UnitSigBTreeTest.pas' {FormBTreeTest},
  SigBTree in 'SigBTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormBTreeTest, FormBTreeTest);
  Application.Run;
end.
