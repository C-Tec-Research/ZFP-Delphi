unit Wait;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TWaitForm = class(TForm)
    Label1: TLabel;
    ProcLab: TLabel;
    Label2: TLabel;
    ElapLab: TLabel;
    BitBtn1: TBitBtn;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    hProc      : THandle;
    Start      : double;
    procedure  BeginWait;
  end;

var
  WaitForm: TWaitForm;

implementation

{$R *.DFM}

procedure TWaitForm.Timer1Timer(Sender: TObject);
begin
   ElapLab.Caption := FormatDateTime('nn:ss', Time - Start);
   if WaitForSingleObject(hProc, 0) = WAIT_OBJECT_0 then
      Close;
end;

procedure TWaitForm.BitBtn1Click(Sender: TObject);
begin
   TerminateProcess(hProc, -1);
   Close;
end;

procedure TWaitForm.BitBtn2Click(Sender: TObject);
begin
   Application.Minimize;
end;

procedure TWaitForm.BeginWait;
begin
   Start := Time;
   Timer1.Enabled := True;
   ShowModal;
end;

end.
