unit UnitEditorsProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls,
  DesignEditors,
  DesignIntf,
  Contnrs;

type
  tAutosizeColumn = (ascParent, ascFALSE, ascTRUE );

type
  TSigEditorEntry = class
  private
    fEditorStyle: integer;
    fAutosizeColumn: tAutosizeColumn;
  public
    property EditorStyle : integer
             read fEditorStyle
             write fEditorStyle;
    property AutoSizeColumn : tAutosizeColumn
             read fAutosizeColumn
             write fAutosizeColumn;
  end;

type
  TFormEditorsEditor = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    TabControlEditors: TTabControl;
    Label1: TLabel;
    ComboBoxEditorStyle: TComboBox;
    Label3: TLabel;
    EditPropertyName: TEdit;
    Label2: TLabel;
    ComboBoxAutosizeColumn: TComboBox;
    LabelItems: TLabel;
    MemoItems: TMemo;
    ComboBoxImageList: TComboBox;
    LabelFixedCol: TLabel;
    Label4: TLabel;
    EditFixedColumns: TEdit;
    procedure TabControlEditorsChange(Sender: TObject);
    procedure ComboBoxEditorStyleChange(Sender: TObject);
    procedure ComboBoxAutosizeColumnChange(Sender: TObject);
  private
    fFixedColumns: integer;
    function GetCount: integer;
    procedure SetCount(const Value: integer);
    function GetEditorStyle( const i : integer ): integer;
    procedure SetEditorStyle(const i, Value: integer);
    function GetAutosizeColumn( const i : integer ): tAutosizeColumn;
    function GetEditorEntry(const i: integer): TSigEditorEntry;
    procedure SetAutosizeColumn(const i: integer; const Value: tAutosizeColumn);
    function GetCurrentEditor: integer;
    procedure SetFixedColumns(const Value: integer);
    { Private declarations }
  public
    { Public declarations }
    destructor Destroy; override;

    function Execute : boolean;

    property Count : integer
             read GetCount
             write SetCount;

    property EditorStyle[ const i : integer ] : integer
             read GetEditorStyle
             write SetEditorStyle;

    property AutosizeColumn[ const i : integer ] : tAutosizeColumn
             read GetAutosizeColumn
             write SetAutosizeColumn;
    property EditorEntry[ const i : integer ] : TSigEditorEntry
             read GetEditorEntry;

    property CurrentEditor : integer
             read GetCurrentEditor;

    property FixedColumns : integer
             read fFixedColumns
             write SetFixedColumns;
  end;

  TSigGridEditorsProperty =  class( TComponentProperty )
  private
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  procedure Register;

implementation

{$R *.dfm}
uses
  SigGeneralGrid;

procedure Register;
begin
  RegisterPropertyEditor( TypeInfo( TSigEditors ), tSigGeneralGrid, '', tSigGridEditorsProperty );
end;

{ TFormEditorsEditor }

procedure TFormEditorsEditor.ComboBoxAutosizeColumnChange(Sender: TObject);
begin
  EditorEntry[ CurrentEditor ].AutoSizeColumn := tAutosizeColumn( ComboBoxAutosizeColumn.ItemIndex );
end;

procedure TFormEditorsEditor.ComboBoxEditorStyleChange(Sender: TObject);
begin
  EditorStyle[ TabControlEditors.TabIndex ] := ComboBoxEditorStyle.ItemIndex;
end;

destructor TFormEditorsEditor.Destroy;
begin
  Count := 0;

  inherited;
end;

function TFormEditorsEditor.Execute: boolean;
begin
  // do fake setup
  TabControlEditorsChange( self );
  Result := ShowModal = mrOK;
end;

function TFormEditorsEditor.GetAutosizeColumn( const i : integer ): tAutosizeColumn;
begin
  Result := EditorEntry[ i ].AutoSizeColumn;
end;

function TFormEditorsEditor.GetCount: integer;
begin
  Result := TabControlEditors.Tabs.Count;
end;

function TFormEditorsEditor.GetCurrentEditor: integer;
begin
  Result := TabControlEditors.TabIndex;
end;

function TFormEditorsEditor.GetEditorEntry(const i: integer): TSigEditorEntry;
begin
  Result := TSigEditorEntry( TabControlEditors.Tabs.Objects[ i ] );
end;

function TFormEditorsEditor.GetEditorStyle( const i : integer ): integer;
begin
  Result := EditorEntry[ i ].EditorStyle;
end;

procedure TFormEditorsEditor.SetAutosizeColumn(const i: integer;
  const Value: tAutosizeColumn);
begin
  EditorEntry[ i ].AutoSizeColumn := Value;
end;

procedure TFormEditorsEditor.SetCount(const Value: integer);
var
  i: Integer;
begin
  if Value > Count then
  begin
    for i := Count to Value - 1 do
    begin
      TabControlEditors.Tabs.AddObject( 'Column ' + IntToStr( i ), TSigEditorEntry.Create );
    end;
  end
  else
  begin
    for i := Count - 1 to Value do
    begin
      TabControlEditors.Tabs.Objects[ i ].Free;
      TabControlEditors.Tabs.Delete( i );
    end;
  end;
end;

procedure TFormEditorsEditor.SetEditorStyle(const i, Value: integer);
begin
  EditorEntry[ i ].EditorStyle := Value;
  if i = TabControlEditors.TabIndex then
  begin
    ComboBoxEditorStyle.ItemIndex := Value;
  end;
end;

procedure TFormEditorsEditor.SetFixedColumns(const Value: integer);
begin
  fFixedColumns := Value;
  EditFixedColumns.Text := IntToStr( Value );
end;

procedure TFormEditorsEditor.TabControlEditorsChange(Sender: TObject);
var
  i : integer;
begin
  i := TabControlEditors.TabIndex;
  ComboBoxEditorStyle.ItemIndex := EditorStyle[ i ];
  ComboBoxAutosizeColumn.ItemIndex := Ord( AutosizeColumn[ i ] );
  LabelFixedCol.Visible := (i < FixedColumns);
end;

{ TSigGridEditorsProperty }

procedure TSigGridEditorsProperty.Edit;
var
  i : integer;
  iEditors : tSigEditors;
  iComponent : tPersistent;
  iSigGeneralGrid : tSigGeneralGrid;
  //iSigEditorComponent : tSigEditorComponent;
begin
  inherited;

  //iEditors := GetComponent( 0 ) as tSigEditors;

  with TFormEditorsEditor.Create( Application ) do
  begin
    try
      if PropCount > 0 then
      begin
        iComponent := GetComponent(0);
        if assigned( iComponent ) then
        begin
          EditPropertyName.Text := GetVisualValue;
          if iComponent is tSigGeneralGrid then
          begin
            iSigGeneralGrid := iComponent as tSigGeneralGrid;
            Count := iSigGeneralGrid.ColCount;
            if Count >0 then
            begin
              TabControlEditors.TabIndex := 0;
            end;
            Caption := 'Editors for ' + iSigGeneralGrid.Name;
            iEditors := iSigGeneralGrid.Editors;
            FixedColumns := iSigGeneralGrid.FixedCols;
            for i := 0 to iEditors.ComponentCount - 1 do
            begin
              EditorStyle[ i ] := Ord( iEditors.EditorType[ i ] );
            end;
            // set values
            if Execute then
            begin
              //iEditors.Name := EditPropertyName.Text;
              for i := 0 to Count - 1 do
              begin
                if EditorStyle[ i ] <> Ord( iEditors.EditorType[ i ] ) then
                begin
                  iEditors.EditorType[ i ] := tSigEditorStyle( EditorStyle[ i ] );
                end;
              end;
              Modified;
            end;
          end;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

function TSigGridEditorsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [ paDialog ];
end;

end.
