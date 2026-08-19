unit UnitConfirmTreeDelete;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TFormConfirmCETreeDelete = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroupPruneParents: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBoxDontAskAgain: TCheckBox;
  private
    function GetPruneParents: boolean;
    procedure SetPruneParents(const Value: boolean);
    function GetDontAskAgain: boolean;
    procedure SetDontAskAgain(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    function Execute(var pPruneParents, pDontAskAgain: boolean): boolean;
    property PruneParents : boolean
             read GetPruneParents
             write SetPruneParents;
    property DontAskAgain : boolean
             read GetDontAskAgain
             write SetDontAskAgain;
  end;

var
  FormConfirmCETreeDelete: TFormConfirmCETreeDelete;

implementation

{$R *.dfm}

{ TFormConfirmCETreeDelete }

function TFormConfirmCETreeDelete.Execute(var pPruneParents, pDontAskAgain : boolean ): boolean;
begin
  PruneParents := pPruneParents;
  Result := ShowModal = mrOK;
  if Result then
  begin
    pPruneParents := PruneParents;
    pDontAskAgain := DontAskAgain;
  end;
end;

function TFormConfirmCETreeDelete.GetDontAskAgain: boolean;
begin
  Result := CheckBoxDontAskAgain.Checked;
end;

function TFormConfirmCETreeDelete.GetPruneParents: boolean;
begin
  Result := RadioGroupPruneParents.ItemIndex = 1;
end;

procedure TFormConfirmCETreeDelete.SetDontAskAgain(const Value: boolean);
begin
  CheckBoxDontAskAgain.Checked := Value;
end;

procedure TFormConfirmCETreeDelete.SetPruneParents(const Value: boolean);
begin
  if Value then
  begin
    RadioGroupPruneParents.ItemIndex := 1;
  end
  else
  begin
    RadioGroupPruneParents.ItemIndex := 0;
  end;
end;

end.
