unit UnitPropertiesArea;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons, Dialogs, ExtDlgs;

type
  TFormPropertiesArea = class(TForm)
    Label1: TLabel;
    EditName: TEdit;
    RadioGroupStyle: TRadioGroup;
    Label2: TLabel;
    EditImage: TEdit;
    SpeedButton1: TSpeedButton;
    OpenPictureDialog: TOpenPictureDialog;
    SpeedButton2: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  protected
    fPassword : string;
  public
    property Password : string
             read fPassword
             write fPassword;
  end;

var
  FormPropertiesArea: TFormPropertiesArea;

implementation

uses UnitFormChangePassword;

{$R *.DFM}

procedure TFormPropertiesArea.SpeedButton1Click(Sender: TObject);
begin
  with OpenPictureDialog do
  begin
    FileName := EditImage.Text;
    if Execute then
    begin
      EditImage.Text := FileName;
    end;
  end;
end;

procedure TFormPropertiesArea.SpeedButton2Click(Sender: TObject);
begin
  FormChangePassword.Password := fPassword;
  case FormChangePassword.ShowModal of
    mrOK: fPassword := FormChangePassword.Password;
    mrNO: fPassword := '';
  end;
end;

end.
