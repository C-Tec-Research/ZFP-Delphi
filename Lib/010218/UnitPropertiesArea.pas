unit UnitPropertiesArea;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons, Dialogs, ExtDlgs;

type
  TFormPropertiesArea = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    EditName: TEdit;
    RadioGroupStyle: TRadioGroup;
    Label2: TLabel;
    EditImage: TEdit;
    SpeedButton1: TSpeedButton;
    OpenPictureDialog: TOpenPictureDialog;
    procedure SpeedButton1Click(Sender: TObject);
  end;

var
  FormPropertiesArea: TFormPropertiesArea;

implementation

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

end.
