unit UnitFormLoadFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFormLoadFile = class(TForm)
    ProgressBarLoad: TProgressBar;
    LabelPC: TLabel;
    TimerFinish: TTimer;
    procedure TimerFinishTimer(Sender: TObject);
  private
    { Private declarations }
    fCount : integer;
    fLastPC : integer;
  public
    { Public declarations }
    procedure OnLoadLine ( const pLine, pLineCount : integer );

  end;

var
  FormLoadFile: TFormLoadFile;

implementation

{$R *.dfm}

{ TFormLoadFile }

procedure TFormLoadFile.OnLoadLine(const pLine, pLineCount: integer);
var
  iPC : integer;
begin
  if pLineCount > 0 then
  begin
    iPC := (pLine * 100) div pLineCount;
    if iPC <> fLastPC then
    begin
      LabelPC.Caption := IntToStr( iPC ) + '%';
      ProgressBarLoad.Max := 100;
      fLastPC := iPC;
    end;
    if fCount = 0 then
    begin
      ProgressBarLoad.Position := iPC;
      fCount := 10;
    end
    else
    begin
      dec( fCount );
    end;
    if (pLine = pLineCount) then
    begin
      ProgressBarLoad.Position := ProgressBarLoad.Max;
      TimerFinish.Enabled := TRUE;
    end
    else
    begin
      if not Visible then
      begin
        Visible := TRUE;
      end;
    end;
  end;
  Application.ProcessMessages;
end;

procedure TFormLoadFile.TimerFinishTimer(Sender: TObject);
begin
  TimerFinish.Enabled := FALSE;
  Visible := FALSE;
end;

end.
