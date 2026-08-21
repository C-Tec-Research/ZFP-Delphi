unit DlgLinkedComponents;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, SigPanel, Vcl.Grids,
  SigGeneralGrid, Vcl.StdCtrls, Vcl.Buttons;

type
  TFormSigFile7PropertyEditor = class(TForm)
    SigPanel1: TSigPanel;
    SigPanelComponentName: TSigPanel;
    SigPanel3: TSigPanel;
    SigPanel4: TSigPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SigGridEditorAction: TSigGridEditor;
    SigGeneralGridEditor: TSigGeneralGrid;
    SigGridEditorLinkedComponents: TSigGridEditor;
  private
    fComponentName: string;
    procedure SetComponentName(const Value: string);
    function GetCurrentComponentCount: integer;
    function GetCurrentComponent(i: integer): TComponent;
    { Private declarations }
  public
    { Public declarations }
    property ComponentName : string
             read fComponentName
             write SetComponentName;
    procedure ClearAllowableComponents;
    procedure AddAllowableComponent( const pComponent : TComponent );
    procedure ClearCurrentComponents;
    procedure AddBlankCurrentComponent;
    procedure AddCurrentComponent( const pComponent : TComponent );
    property CurrentComponentCount : integer
             read GetCurrentComponentCount;
    property CurrentComponent[ i : integer ] : TComponent
             read GetCurrentComponent;
    function Execute : boolean;
  end;

var
  FormSigFile7PropertyEditor: TFormSigFile7PropertyEditor;

implementation

{$R *.dfm}

{ TFormSigFile7PropertyEditor }

procedure TFormSigFile7PropertyEditor.AddAllowableComponent(
  const pComponent: TComponent);
begin
  SigGridEditorLinkedComponents.ItemsList.AddObject( pComponent.Name, pComponent );
end;

procedure TFormSigFile7PropertyEditor.AddBlankCurrentComponent;
var
  iNewRow : integer;
begin
  iNewRow := SigGeneralGridEditor.RowCount;
  SigGeneralGridEditor.RowCount := iNewRow + 1;
  SigGeneralGridEditor.Cell[0, iNewRow ] := '';
  SigGeneralGridEditor.Cell[1, iNewRow ] := '';
end;

procedure TFormSigFile7PropertyEditor.AddCurrentComponent(
  const pComponent: TComponent);
var
  iTestRow : integer;
begin
  iTestRow := SigGeneralGridEditor.RowCount - 1;
  if SigGeneralGridEditor.Cell[ 0, iTestRow ] <> '' then
  begin
    AddBlankCurrentComponent;
    inc( iTestRow );
  end;
  SigGeneralGridEditor.Cell[ 0, iTestRow ] := 'Delete';
  SigGeneralGridEditor.Cell[ 1, iTestRow ] := pComponent.Name;
  SigGeneralGridEditor.CellObject[ 1, iTestRow ] := pComponent;
end;

procedure TFormSigFile7PropertyEditor.ClearAllowableComponents;
begin
  SigGridEditorLinkedComponents.ItemsList.Clear;
end;

procedure TFormSigFile7PropertyEditor.ClearCurrentComponents;
begin
  SigGeneralGridEditor.RowCount := 2;
  SigGeneralGridEditor.Cell[ 1, 1 ] := '';
  SigGeneralGridEditor.Cell[ 0, 1 ] := '';
  SigGeneralGridEditor.CellObject[ 1, 1 ] := nil;
end;

function TFormSigFile7PropertyEditor.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

function TFormSigFile7PropertyEditor.GetCurrentComponent(
  i: integer): TComponent;
var
  iRow : integer;
begin
  iRow := 1;
  while iRow < SigGeneralGridEditor.RowCount do
  begin
    Result := SigGeneralGridEditor.CellObject[ 1, iRow ] as TComponent;
    if assigned( Result ) then
    begin
      if i = 0 then
      begin
        exit;
      end
      else
      begin
        dec( i );
      end;
    end;
    inc( iRow )
  end;
  // else
  Result := nil;
end;

function TFormSigFile7PropertyEditor.GetCurrentComponentCount: integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to SigGeneralGridEditor.RowCount - 1 do
  begin
    if assigned( SigGeneralGridEditor.CellObject[ 1, i ] ) then
    begin
      inc( Result );
    end;
  end;
end;

procedure TFormSigFile7PropertyEditor.SetComponentName(const Value: string);
begin
  fComponentName := Value;
  SigPanelComponentName.Caption := Value;
end;

end.
