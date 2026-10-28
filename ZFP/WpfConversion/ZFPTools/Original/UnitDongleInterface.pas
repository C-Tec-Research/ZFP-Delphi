unit UnitDongleInterface;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, USBPanel;

type
  TFormDongleInterface = class(TForm)
    USBPanel: TUSBPanel;
  private
    function GetBaudRate: TFTBaudRate;
    procedure SetBaudRate(const Value: TFTBaudRate);
    { Private declarations }
  public
    { Public declarations }
    property BaudRate : TFTBaudRate
             read GetBaudRate
             write SetBaudRate;
  end;

var
  FormDongleInterface: TFormDongleInterface;

implementation

{$R *.dfm}

{ TFormDongleInterface }

function TFormDongleInterface.GetBaudRate: TFTBaudRate;
begin
  Result := USBPanel.BaudRate;
end;

procedure TFormDongleInterface.SetBaudRate(const Value: TFTBaudRate);
begin
  USBPanel.BaudRate := Value;
end;

end.
