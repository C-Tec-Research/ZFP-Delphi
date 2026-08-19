unit UnitNewIconGroupName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFormNewIconGroupName = class(TForm)
    Label1: TLabel;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    EditGroupName: TEdit;
    procedure EditGroupNameChange(Sender: TObject);
  private
    { Private declarations }
    fRootDir : string;
    function GetGroupName: string;
  public
    { Public declarations }
    function Execute( const RootDir : string ) : boolean;
    function LegalName( const pName : string ) : boolean;
    property GroupName : string
             read GetGroupName;
  end;

var
  FormNewIconGroupName: TFormNewIconGroupName;

implementation

{$R *.dfm}

{ TFormNewIconGroupName }

procedure TFormNewIconGroupName.EditGroupNameChange(Sender: TObject);
begin
  BitBtnOK.Enabled := LegalName(EditGroupName.Text) and (not FileExists( fRootDir + EditGroupName.Text ));
end;

function TFormNewIconGroupName.Execute(const RootDir: string): boolean;
begin
  fRootDir := RootDir;
  EditGroupName.Text := '';
  Result := ShowModal = mrOK;
end;

function TFormNewIconGroupName.GetGroupName: string;
begin
  Result := EditGroupName.Text;
end;

function TFormNewIconGroupName.LegalName(const pName: string): boolean;
var
  i: Integer;
begin
  if pName = '' then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := TRUE;
    for i := 1 to Length( pName ) do
    begin
      case pName[ i ] of
        ' ', 'A'..'Z', 'a'..'z', '0'..'9', ',', '_', '(', ')': ;
        else
        begin
          Result := FALSE;
          exit;
        end;
      end;
    end;
  end;
end;

end.
