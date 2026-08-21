unit StringListDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TStringListForm = class(TForm)
    BotPanel: TPanel;
    DataMemo: TMemo;
    OKBut: TBitBtn;
    procedure OKButClick(Sender: TObject);
    procedure BotPanelResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StringListForm: TStringListForm;

implementation

{$R *.DFM}

procedure TStringListForm.OKButClick(Sender: TObject);
begin
   Close;
end;

procedure TStringListForm.BotPanelResize(Sender: TObject);
begin
   OKBut.Left := BotPanel.ClientWidth div 2 - OKBut.Width div 2;
end;

end.
