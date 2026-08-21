unit UnitEditUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, SigSpinEdit, StdCtrls, CheckLst, Mask, Buttons,
  UnitChangePassword;

type

  tChimeOptions = ( co0Chimes,
                    co1Chime,
                    co2Chimes,
                    co3Chimes,
                    coAsUnregulated  // default
                     );

  TFormEditUser = class(TForm)
    LabelName: TLabel;
    EditName: TEdit;
    CheckListBoxOptions: TCheckListBox;
    Label2: TLabel;
    GroupBoxChimes: TGroupBox;
    RadioButtonNoChimes: TRadioButton;
    RadioButton1Chime: TRadioButton;
    RadioButton2Chimes: TRadioButton;
    RadioButton3Chimes: TRadioButton;
    RadioButtonAsUnregulated: TRadioButton;
    BitBtnCancel: TBitBtn;
    BitBtnOK: TBitBtn;
    SpeedButtonChangePassword: TSpeedButton;
    procedure SpeedButtonChangePasswordClick(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure RadioButtonNoChimesClick(Sender: TObject);
    procedure RadioButton1ChimeClick(Sender: TObject);
    procedure RadioButton2ChimesClick(Sender: TObject);
    procedure RadioButton3ChimesClick(Sender: TObject);
  private
    fPassword: string;
    fAllowAsUnregulated: boolean;
    fChimeDelay: integer;
    function GetUserName: string;
    procedure SetUserName(const Value: string);
    function GetChimeOptions: tChimeOptions;
    procedure SetChimeOptions(const Value: tChimeOptions);
    procedure SetAllowAsUnregulated(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    property UserName : string
             read GetUserName
             write SetUserName;
    property Password : string
             read fPassword
             write fPassword;
    property ChimeOptions : tChimeOptions
             read GetChimeOptions
             write SetChimeOptions;
    property AllowAsUnregulated : boolean
             read fAllowAsUnregulated
             write SetAllowAsUnregulated;
    property ChimeDelay : integer
             read fChimeDelay
             write fChimeDelay;
  const
    dc0Chimes       = 0;   // in 100 ms chunks
    dc1Chime        = 10;
    dc2Chimes       = 15;
    dc3Chimes       = 20;
  end;

var
  FormEditUser: TFormEditUser;

implementation

{$R *.dfm}

{ TFormEditUser }

function TFormEditUser.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormEditUser.FormClick(Sender: TObject);
begin
  fChimeDelay := dc0Chimes;
end;

function TFormEditUser.GetChimeOptions: tChimeOptions;
begin
  if RadioButtonNoChimes.Checked then
  begin
    Result := co0Chimes;
  end
  else if RadioButton1Chime.Checked then
  begin
    Result := co1Chime;
  end
  else if RadioButton2Chimes.Checked then
  begin
    Result := co2Chimes;
  end
  else if RadioButton3Chimes.Checked then
  begin
    Result := co3Chimes;
  end
  else
  begin
    Result := coAsUnregulated;
  end;
end;

function TFormEditUser.GetUserName: string;
begin
  Result := EditName.Text;
end;

procedure TFormEditUser.RadioButton1ChimeClick(Sender: TObject);
begin
  fChimeDelay := dc1Chime;
end;

procedure TFormEditUser.RadioButton2ChimesClick(Sender: TObject);
begin
  fChimeDelay := dc2Chimes;
end;

procedure TFormEditUser.RadioButton3ChimesClick(Sender: TObject);
begin
  fChimeDelay := dc3Chimes;
end;

procedure TFormEditUser.RadioButtonNoChimesClick(Sender: TObject);
begin
  fChimeDelay := dc0Chimes;
end;

procedure TFormEditUser.SetAllowAsUnregulated(const Value: boolean);
begin
  fAllowAsUnregulated := Value;
  RadioButtonAsUnregulated.Enabled := Value;
end;

procedure TFormEditUser.SetChimeOptions(const Value: tChimeOptions);
begin
  RadioButtonNoChimes.Checked := FALSE;
  RadioButton1Chime.Checked := FALSE;
  RadioButton2Chimes.Checked := FALSE;
  RadioButton3Chimes.Checked := FALSE;
  RadioButtonAsUnregulated.Checked := FALSE;
  case Value of
    co0Chimes: RadioButtonNoChimes.Checked := TRUE;
    co1Chime: RadioButton1Chime.Checked := TRUE;
    co2Chimes: RadioButton2Chimes.Checked := TRUE;
    co3Chimes: RadioButton3Chimes.Checked := TRUE;
    coAsUnregulated: RadioButtonAsUnregulated.Checked := TRUE;
  end;
end;

procedure TFormEditUser.SetUserName(const Value: string);
begin
  EditName.Text := Value;
end;

procedure TFormEditUser.SpeedButtonChangePasswordClick(Sender: TObject);
begin
  with FormChangePassword do
  begin
    User := UserName;
    if Execute then
    begin
      self.Password := FormChangePassword.Password;    // self needed here!
    end;
  end;
end;

end.
