unit UnitLCDText;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrameLCDText = class(TFrame)
    Panel1: TPanel;
    MemoText: TMemo;
    procedure Panel1Resize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrameLCDText.Panel1Resize(Sender: TObject);
begin
  with MemoText do
  begin
    Font.Height := (ClientHeight - 3) div 2; // 2 lines
  end;

end;

end.
