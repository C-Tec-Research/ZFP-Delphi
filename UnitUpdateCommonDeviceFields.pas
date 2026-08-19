unit UnitUpdateCommonDeviceFields;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, SigGeneralGrid, Vcl.StdCtrls,
  Vcl.ExtCtrls, SigImage, Vcl.Buttons, SigPanel;

type
  TFormUpdateCommonDeviceFields = class(TForm)
    SigPanel1: TSigPanel;
    SigPanel2: TSigPanel;
    SigPanel3: TSigPanel;
    BitBtn1: TBitBtn;
    SigImage1: TSigImage;
    Label1: TLabel;
    EditDeviceName: TEdit;
    SigGridEditorSubDeviceName: TSigGridEditor;
    SigGeneralGridCommonDeviceFields: TSigGeneralGrid;
    SigGridEditorSubdeviceZone: TSigGridEditor;
    SigGridEditorSubdeviceInputGroup: TSigGridEditor;
    SigGridEditorSubdeviceOutputGroup: TSigGridEditor;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Execute;
  end;

var
  FormUpdateCommonDeviceFields: TFormUpdateCommonDeviceFields;

implementation

{$R *.dfm}

{ TFormUpdateCommonDeviceFields }

procedure TFormUpdateCommonDeviceFields.Execute;
begin
  ShowModal;
end;

end.
