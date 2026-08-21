unit SigFile7PropertyEditors;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  DesignEditors;

type
  TFormLinkControlsPropertyEditor = class(TForm)
    ListBoxSigFileControls: TListBox;
    ListBoxFMXControls: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtnDelete: TBitBtn;
    ComboBoxSigFileControl: TComboBox;
    ComboBoxFMXControl: TComboBox;
    BitBtnAdd: TBitBtn;
    procedure BitBtnAddClick(Sender: TObject);
    procedure ListBoxSigFileControlsClick(Sender: TObject);
    procedure ListBoxFMXControlsClick(Sender: TObject);
    procedure BitBtnDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    procedure Clear;
    procedure AddSigFileControl( pName : string; const pControl : TObject );
    procedure AddFMXFileControl( pName : string; const pControl : TObject );
    procedure AddControlPair( pSigFileName : string; const pSigFileControl : TObject; pFMXName : string; const pFMXControl : TObject );
  end;

  type TSigFile7LinksEditor = class( TClassProperty )

  end;
var
  FormLinkControlsPropertyEditor: TFormLinkControlsPropertyEditor;

implementation

{$R *.dfm}

{ TFormLinkControlsPropertyEditor }

procedure TFormLinkControlsPropertyEditor.AddControlPair(pSigFileName: string;
  const pSigFileControl: TObject; pFMXName: string; const pFMXControl: TObject);
begin
  ListBoxSigFileControls.Items.AddObject( pSigFileName, pSigFileControl );
  ListBoxSigFileControls.Items.AddObject( pFMXName, pFMXControl );
end;

procedure TFormLinkControlsPropertyEditor.AddFMXFileControl(pName: string;
  const pControl: TObject);
begin
  ComboBoxFMXControl.Items.AddObject( pName, pControl );
end;

procedure TFormLinkControlsPropertyEditor.AddSigFileControl(pName: string;
  const pControl: TObject);
begin
  ComboBoxSigFileControl.Items.AddObject( pName, pControl );
end;

procedure TFormLinkControlsPropertyEditor.BitBtnAddClick(Sender: TObject);
begin
  if ComboBoxSigFileControl.ItemIndex >= 0 then
  begin
    if ComboBoxFMXControl.ItemIndex >= 0 then
    begin
      AddControlPair( ComboBoxSigFileControl.Text, ComboBoxSigFileControl.Items.Objects[ ComboBoxSigFileControl.ItemIndex ],
                      ComboBoxFMXControl.Text, ComboBoxFMXControl.Items.Objects[ ComboBoxFMXControl.ItemIndex ] );
    end;
  end;
end;

procedure TFormLinkControlsPropertyEditor.BitBtnDeleteClick(Sender: TObject);
var
  iIndex : integer;
begin
  iIndex := ListBoxSigFileControls.ItemIndex;
  if iIndex >= 0 then
  begin
    ListBoxSigFileControls.Items.Delete( iIndex );
    ListBoxFMXControls.Items.Delete( iIndex );
  end;
end;

procedure TFormLinkControlsPropertyEditor.Clear;
begin
  ComboBoxSigFileControl.Clear;
  ComboBoxSigFileControl.Style := csDropDownList;
  ComboBoxFMXControl.Clear;
  ComboBoxFMXControl.Style := csDropDownList;
  ListBoxSigFileControls.Clear;
  ListBoxSigFileControls.Clear;
end;

function TFormLinkControlsPropertyEditor.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormLinkControlsPropertyEditor.ListBoxFMXControlsClick(
  Sender: TObject);
begin
  ListBoxSigFileControls.ItemIndex := ListBoxFMXControls.ItemIndex;
end;

procedure TFormLinkControlsPropertyEditor.ListBoxSigFileControlsClick(
  Sender: TObject);
begin
  ListBoxFMXControls.ItemIndex := ListBoxSigFileControls.ItemIndex;
end;

end.
