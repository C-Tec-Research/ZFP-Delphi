unit UnitVCLMacroEditor;

interface

{
  Although strictly speaking this is a dialog box (ish) we treat it
  more like an application
}

uses
  UnitVCLMacro,
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus,
  SigSaveDialog, Vcl.ExtCtrls,
  SigPanel, SigRegistry;

type
  TFormVCLMacroEditor = class(TForm)
    SigPanel1: TSigPanel;
    SigPanel2: TSigPanel;
    SigPanel3: TSigPanel;
    SigSaveDialogMacro: TSigSaveDialog;
    MainMenuMacroEditor: TMainMenu;
    SigRegistryMacros: TSigRegistry;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fMacros: TVCLMacro;
    function GetMainForm: TForm;
    procedure SetMainForm(const Value: TForm);
    { Private declarations }
  public
    { Public declarations }
    property Macros : TVCLMacro
             read fMacros;

    property MainForm : TForm
             read GetMainForm
             write SetMainForm;

  end;

var
  FormVCLMacroEditor: TFormVCLMacroEditor;

implementation

{$R *.dfm}

procedure TFormVCLMacroEditor.FormCreate(Sender: TObject);
begin
  fMacros := TVCLMacro.Create;

end;

procedure TFormVCLMacroEditor.FormDestroy(Sender: TObject);
begin
  fMacros.Free;
end;

function TFormVCLMacroEditor.GetMainForm: TForm;
begin
  Result := fMacros.MainForm;
end;

procedure TFormVCLMacroEditor.SetMainForm(const Value: TForm);
begin
  fMacros.MainForm := Value;
end;

end.
