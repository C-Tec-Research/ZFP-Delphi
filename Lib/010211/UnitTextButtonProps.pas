unit UnitTextButtonProps;

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
  UnitBasicButtonProps,
  StdCtrls,
  Spin;

type
  TFormTextButtonProps = class(TFormBasicButtonProps)
    Label4: TLabel;
    EditText: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure EditTextChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SaveTitle : string;
  end;

var
  FormTextButtonProps: TFormTextButtonProps;

implementation

uses DSMButton;

{$R *.DFM}

procedure TFormTextButtonProps.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // Restore values
  inherited;
  with Parent do
  begin
    with ActiveButton do
    begin
      SetProperty( 'Title', SaveTitle );
    end;
  end;
end;

procedure TFormTextButtonProps.FormShow(Sender: TObject);
begin
  // store current values
  with ActiveButton do
  begin
    SaveTitle := GetProperty( 'Title' );
  end;
  EditText.Text := SaveTitle;
  // and all inherited stuff
  inherited;
end;

procedure TFormTextButtonProps.EditTextChange(Sender: TObject);
begin
  inherited;
  with ActiveButton do
  begin
    SetProperty( 'Title', EditText.Text );
  end;
  ButtonOK.Enabled := TRUE;
end;

end.
