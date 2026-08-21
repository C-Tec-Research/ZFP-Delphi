unit SigNETStringGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TSigNETStringGrid = class(TStringGrid)
  private
    { Private declarations }
    NewRowCount : LongInt;
    NewFixedRows : LongInt;
    fAutoResize: boolean;
    procedure SetRowCount(Value: Longint);
    procedure SetFixedRows(Value: Longint);
    procedure SetAutoResize(const Value: boolean);
  protected
    { Protected declarations }
    procedure fOnAutoResize( Sender : TObject );
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure InvalidateCell(ACol, ARow: Longint);
  published
    { Published declarations }
    property RowCount
             read NewRowCount
             write SetRowCount;
    property FixedRows
             read NewFixedRows
             write SetFixedRows;
    procedure SaveToCSV( FileName : string );
    procedure LoadFromCSV( FileName : string );
    property AutoResize : boolean
             read fAutoResize
             write SetAutoResize
             default FALSE;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigNETStringGrid]);
end;

constructor TSigNETStringGrid.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  NewRowCount := 5; // the default
  NewFixedRows := 1; // The default
end;

procedure TSigNETStringGrid.SetRowCount(Value: Longint);
//Var
//  SaveOptions : TGridOptions;
begin
//  SaveOptions := Options;
//  Options := Options - [goAlwaysShowEditor, goEditing ];
  NewRowCount := Value;
  if Value <= NewFixedRows then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited RowCount := Value;
    if NewFixedRows <> FixedRows then
    begin
      FixedRows := NewFixedRows;
    end;
  end;
//  Options := SaveOptions;
end;

procedure TSigNETStringGrid.fOnAutoResize(Sender: TObject);
begin
  DefaultColWidth := (ClientWidth - (ColCount - 1) * GridLineWidth) div ColCount;
end;

procedure TSigNETStringGrid.InvalidateCell(ACol, ARow: Integer);
begin
  inherited InvalidateCell( ACol, ARow );
end;

procedure TSigNETStringGrid.LoadFromCSV(FileName: string);
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

procedure TSigNETStringGrid.SaveToCSV(FileName: string);
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

procedure TSigNETStringGrid.SetAutoResize(const Value: boolean);
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

procedure TSigNETStringGrid.SetFixedRows(Value: Longint);
begin
  NewFixedRows := Value;
  if Value >= NewRowCount then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited FixedRows := Value;
    if NewRowCount <> RowCount then
    begin
      RowCount := NewRowCount;
    end;
  end;
end;

end.
