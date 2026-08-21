unit UnitFormChangeName;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  System.Character,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TFormName = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EditCurrentName: TEdit;
    EditNewName: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditCurrentPrefix: TEdit;
    EditNewPrefix: TEdit;
  private
    { Private declarations }
    function GetPrefix( const pValue : string ) : string;
  public
    { Public declarations }
    function Execute( const pName : string; const pClassName : string ) : string;
  end;

var
  FormName: TFormName;

implementation

{$R *.dfm}

{ TFormName }

function TFormName.Execute(const pName: string; const pClassName: string): string;
begin
  EditNewPrefix.Text := GetPrefix( pClassName );
  if SameText( EditNewPrefix.Text, Copy( pName, 1, Length(EditNewPrefix.Text) )) then
  begin
    EditCurrentPrefix.Text := Copy( pName, 1, Length( EditNewPrefix.Text ));
    EditCurrentName.Text := Copy( pName, Length(EditNewPrefix.Text) + 1 );
  end
  else
  begin
    EditCurrentPrefix.Text := '';
    EditCurrentName.Text := pName;
  end;
  EditNewName.Text := EditCurrentName.Text;
  if ShowModal = mrOK then
  begin
    Result := EditNewPrefix.Text + EditNewName.Text;
  end
  else
  begin
    Result := pName;
  end;
end;

function TFormName.GetPrefix(const pValue: string): string;
begin
  case pValue[ 1 ] of
    'T', 't': Result := Copy( pValue, 2 );
    else Result := pValue;
  end;


end;

end.
