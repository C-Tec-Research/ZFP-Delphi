unit UnitChangeTableName;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.IOUtils;

type
  TFormChangeTableName = class(TForm)
    Label1: TLabel;
    EditCurrentName: TEdit;
    EditNewName: TEdit;
    Label2: TLabel;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    procedure EditNewNameKeyPress(Sender: TObject; var Key: Char);
  private
    function GetFileName: tFileName;
    procedure SetFileName(const Value: tFileName);
    { Private declarations }
  public
    { Public declarations }
    property FileName : tFileName
             read GetFileName
             write SetFileName;

    function Execute : boolean;
  end;

var
  FormChangeTableName: TFormChangeTableName;

implementation

{$R *.dfm}

procedure TFormChangeTableName.EditNewNameKeyPress(Sender: TObject; var Key: Char);
begin
  if not tPath.IsValidPathChar( Key ) then
  begin
    Key := #0;
    beep;
  end;
end;

function TFormChangeTableName.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

function TFormChangeTableName.GetFileName: tFileName;
begin
  Result := EditNewName.Text;
end;

procedure TFormChangeTableName.SetFileName(const Value: tFileName);
begin
  EditCurrentName.Text := Value;
  EditNewName.Text := Value;
end;

end.
