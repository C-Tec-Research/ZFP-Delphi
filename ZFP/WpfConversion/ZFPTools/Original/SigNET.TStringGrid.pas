unit SigNET.TStringGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VCL.Grids;

type
  TStringGrid = class(VCL.Grids.TStringGrid)
  private
    { Private declarations }
    NewRowCount : LongInt;
    fAutoResize: boolean;
    procedure SetRowCount(Value: Longint);
    procedure SetFixedRows(Value: Longint);
    function GetFixedRows : Longint;
    procedure SetAutoResize(const Value: boolean);
  protected
    { Protected declarations }
    procedure fOnAutoResize( Sender : TObject );
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure InvalidateCell(ACol, ARow: Longint);
    property ColWidths stored FALSE;
  //published
    { Published declarations }
    property RowCount
             read NewRowCount
             write SetRowCount;
    property FixedRows
             read GetFixedRows
             write SetFixedRows;
    procedure SaveToCSV( FileName : string );
    procedure LoadFromCSV( FileName : string );
    property AutoResize : boolean
             read fAutoResize
             write SetAutoResize
             default FALSE;
  end;

implementation

constructor TStringGrid.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  NewRowCount := inherited RowCount; // the default
end;

procedure TStringGrid.SetRowCount(Value: Longint);
//Var
//  SaveOptions : TGridOptions;
begin
//  SaveOptions := Options;
//  Options := Options - [goAlwaysShowEditor, goEditing ];
  NewRowCount := Value;
  if Value <= FixedRows then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited RowCount := Value;
  end;
//  Options := SaveOptions;
end;

procedure TStringGrid.fOnAutoResize(Sender: TObject);
begin
  DefaultColWidth := (ClientWidth - (ColCount - 1) * GridLineWidth) div ColCount;
end;

function TStringGrid.GetFixedRows: Longint;
begin
  Result := inherited FixedRows;
end;

procedure TStringGrid.InvalidateCell(ACol, ARow: Integer);
begin
  inherited InvalidateCell( ACol, ARow );
end;

procedure TStringGrid.LoadFromCSV(FileName: string);
var
  iStrings : tStringList;
  iRow : tStringList;
  i, j, k : integer;
begin
  iStrings := tStringList.Create;
  iRow := tStringList.Create;
  iStrings.LoadFromFile( FileName );
  k := 0;
  // each line will be a csv line.
  for i := 0 to iStrings.Count - 1 do
  begin
    iRow.Clear;
    iRow.CommaText := iStrings[ i ];
    if iRow.Count < ColCount then
    begin
      ColCount := iRow.Count;
    end;
    if k >= RowCount then
    begin
      RowCount := RowCount + 1;
    end;
    for j := 0 to iRow.Count - 1 do
    begin
      Cells[ j, k ] := iRow[ k ];
    end;
    inc( k );
  end;
  iRow.Free;
  iStrings.Free;
end;

procedure TStringGrid.SaveToCSV(FileName: string);
var
  iStrings : tStringList;
  i : integer;
begin
  iStrings := tStringList.Create;
  for i := 0 to RowCount - 1 do
  begin
    iStrings.Add( Rows[ i ].CommaText );
  end;
  iStrings.SaveToFile( FileName );
  iStrings.Free;
end;

procedure TStringGrid.SetAutoResize(const Value: boolean);
begin
  fAutoResize := Value;
  if Value then
  begin
    OnResize := fOnAutoResize;
  end
  else
  begin
    OnResize := nil;
  end;
end;

procedure TStringGrid.SetFixedRows(Value: Longint);
begin
  if Value >= NewRowCount then
  begin
    Visible := FALSE;
    inherited RowCount := Value + 1; // avoid silly action
  end
  else
  begin
    Visible := TRUE;
    inherited FixedRows := Value;
    if NewRowCount <> inherited RowCount then
    begin
      inherited RowCount := NewRowCount;
    end;
  end;
end;

end.
