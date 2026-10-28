unit UnitBlockAddition;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Samples.Spin, SigSpinEdit;

type
  TFormBlockAddition = class(TForm)
    EditName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SigSpinEditFrom: TSigSpinEdit;
    Label3: TLabel;
    SigSpinEditTo: TSigSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
  end;

var
  FormBlockAddition: TFormBlockAddition;

implementation

{$R *.dfm}

{ TFormBlockAddition }

procedure TFormBlockAddition.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #$E then // <n>
  begin
    EditName.SelText := '<n>';
    Key := #0;
  end;
end;

function TFormBlockAddition.Execute: boolean;
begin
  EditName.Text := '';
  SigSpinEditFrom.Value := 1;
  SigSpinEditTo.Value := 2;
  Result := ShowModal = mrOK;
end;

end.
