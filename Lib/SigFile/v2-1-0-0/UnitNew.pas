unit UnitNew;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.IOUtils;

type
  TFormNewFile = class(TForm)
    Label1: TLabel;
    EditTableName: TEdit;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    LabelBasedOn: TLabel;
    ComboBoxBasedOn: TComboBox;
    procedure EditTableNameChange(Sender: TObject);
    procedure EditTableNameKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    function GetTableName: string;
    procedure SetTableName(const Value: string);
    function GetBasedOn: tObject;
    procedure SetBasedOn(const Value: tObject);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    procedure ClearBasedOnEntries;
    function AddBasedOnEntry( const pObject : tObject; const pObjectName : string ) : integer;

    property TableName : string
             read GetTableName
             write SetTableName;

    property BasedOn : tObject
             read GetBasedOn
             write SetBasedOn;
  end;

var
  FormNewFile: TFormNewFile;

implementation

{$R *.dfm}

{ TFormNewFile }

function TFormNewFile.AddBasedOnEntry(const pObject: tObject;
  const pObjectName: string): integer;
begin
  Result := ComboBoxBasedOn.Items.AddObject( pObjectName, pObject );
  ComboBoxBasedOn.Visible := TRUE;
  LabelBasedOn.Visible := TRUE;
end;

procedure TFormNewFile.ClearBasedOnEntries;
begin
  ComboBoxBasedOn.Items.Clear;
  ComboBoxBasedOn.Visible := FALSE;
  LabelBasedOn.Visible := FALSE;
end;

procedure TFormNewFile.EditTableNameChange(Sender: TObject);
begin
  BitBtnOK.Enabled := TableName <> '';
end;

procedure TFormNewFile.EditTableNameKeyPress(Sender: TObject; var Key: Char);
begin
  if not tPath.IsValidPathChar( Key ) then
  begin
    Key := #0;
    beep;
  end;
end;

function TFormNewFile.Execute: boolean;
begin
  BitBtnOK.Enabled := TableName <> '';
  Result := ShowModal = mrOK;
  ClearBasedOnentries;
end;

procedure TFormNewFile.FormCreate(Sender: TObject);
begin
  ClearBasedOnEntries;
end;

function TFormNewFile.GetBasedOn: tObject;
begin
  if ComboBoxBasedOn.ItemIndex < 0 then
  begin
    Result := nil;
  end
  else
  begin
    Result := ComboBoxBasedOn.Items.Objects[ ComboBoxBasedOn.ItemIndex ];
  end;
end;

function TFormNewFile.GetTableName: string;
begin
  Result := EditTableName.Text;
end;

procedure TFormNewFile.SetBasedOn(const Value: tObject);
var
  i: Integer;
begin
  with ComboBoxBasedOn do
  begin
    for i := 0 to Items.Count - 1 do
    begin
      if Items.Objects[ i ] = Value then
      begin
        ItemIndex := i;
        exit;
      end;
    end;
    // else
    ItemIndex := -1;
  end;
end;

procedure TFormNewFile.SetTableName(const Value: string);
begin
  EditTableName.Text := Value;
end;

end.
