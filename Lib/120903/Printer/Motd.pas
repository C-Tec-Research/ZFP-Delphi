unit motd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, verslab;

type
  TMOTDForm = class(TForm)
    TopPanel: TPanel;
    Memo1: TMemo;
    BotPanel: TPanel;
    OKBut: TBitBtn;
    DateLabel: TLabel;
    VersionLabel1: TVersionLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MOTDForm: TMOTDForm;

implementation

{$R *.DFM}

procedure TMOTDForm.FormShow(Sender: TObject);
begin
   Caption := Application.Title + ' - Message of the Day';
   DateLabel.Caption := FormatDateTime('dddd, mmmm dd, yyyy', Now);
end;

end.
