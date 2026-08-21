unit UnitAreaButtonProps;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  UnitTextButtonProps,
  StdCtrls,
  Spin;

type
  TFormAreaButtonProps = class(TFormTextButtonProps)
    ComboBoxArea: TComboBox;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBoxAreaChange(Sender: TObject);
  private
    { Private declarations }
    SaveArea : integer;
  public
    { Public declarations }
  end;

var
  FormAreaButtonProps: TFormAreaButtonProps;

implementation

{$R *.DFM}

uses
//  UnitMain,
  DSMButton,
  UnitSigForm;

procedure TFormAreaButtonProps.FormShow(Sender: TObject);
var
  i : integer;
begin
  // store current values
  with ActiveButton do
  begin
    SaveArea := GetPropertyAsInt('Area No');
  end;
  // set up areas list
  with ComboBoxArea do
  begin
    Clear;
    for i := 0 to SigAreas.ReadInteger( 'General', 'No Areas', 1 ) - 1 do
    begin
      Items.Add( IntToStr(i) + ': ' +
           SigAreas.ReadString( 'Area ' + intToStr( i ), 'Long Title',
                                'Area ' + intToStr( i )));
    end;
    ItemIndex := SaveArea;
  end;
  // and all inherited stuff
  inherited;

end;

procedure TFormAreaButtonProps.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  // restore extra value
{
  with FormMain.ActiveButton do
  begin
    SetProperty( 'Area No', SaveArea );
  end;
}
end;

procedure TFormAreaButtonProps.ComboBoxAreaChange(Sender: TObject);
begin
  inherited;
  ButtonOK.Enabled := TRUE;
end;

end.
