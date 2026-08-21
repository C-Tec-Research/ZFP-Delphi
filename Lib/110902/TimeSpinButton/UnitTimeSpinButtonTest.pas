unit UnitTimeSpinButtonTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TimeSpinButton, Buttons, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    SpeedButton1: TSpeedButton;
    TimeSpinButton1: TTimeSpinButton;
    Edit1: TEdit;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    iSpinTest : tTimeSpinButton;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  iSpinTest := tTimeSpinButton.Create( self );
  iSpinTest.Parent := self;
  iSpinTest.Visible := TRUE;
end;

end.
