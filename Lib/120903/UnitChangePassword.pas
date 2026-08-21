unit UnitChangePassword;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, StdCtrls, Buttons;

type
  TFormChangePassword = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditUserName: TEdit;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    procedure MaskEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    f_ChangeText: string;
    f_RemoveText: string;
    function GetPassword: string;
    function GetUser: string;
    procedure SetUser(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    property ChangeText : string
             read f_ChangeText
             write f_ChangeText;
    property RemoveText : string
             read f_RemoveText
             write f_RemoveText;
    property Password : string
             read GetPassword;
    property User : string
             read GetUser
             write SetUser;
  end;

var
  FormChangePassword: TFormChangePassword;

implementation

{$R *.dfm}

{ TFormChangePassword }

function TFormChangePassword.Execute: boolean;
begin
  MaskEdit1.Text := 'MaskEdit1';
  MaskEdit2.Text := 'MaskEdit2';
  Result := ShowModal = mrOK;
end;

procedure TFormChangePassword.FormCreate(Sender: TObject);
begin
  f_ChangeText := 'Change Password';
  f_RemoveText := 'Remove Password';
end;

function TFormChangePassword.GetPassword: string;
begin
  Result := MaskEdit1.Text;
end;

function TFormChangePassword.GetUser: string;
begin
  Result := EditUserName.Text;
end;

procedure TFormChangePassword.MaskEdit1Change(Sender: TObject);
begin
  if Maskedit1.Text = MaskEdit2.Text then
  begin
    if MaskEdit1.Text = '' then
    begin
      BitBtnOK.Caption := RemoveText;
    end
    else
    begin
      BitBtnOK.Caption := ChangeText;
    end;
    BitBtnOK.Enabled := FALSE;
  end
  else
  begin
    BitBtnOK.Caption := ChangeText;
    BitBtnOK.Enabled := FALSE;
  end;
end;

procedure TFormChangePassword.SetUser(const Value: string);
begin
  EditUserName.Text := Value;
end;

end.
