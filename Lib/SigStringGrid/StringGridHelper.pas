unit StringGridHelper;

interface

uses
  System.Classes,
  VCL.Grids;

type
  TSigNETStringGrid = class helper for TStringGrid
  private
    procedure SetRowCount(Value: Longint);
    function GetRowCount : Longint;
  public
    { Public declarations }
    procedure InvalidateCell(ACol, ARow: Longint);
    property RowCount : LongInt
             read GetRowCount
             write SetRowCount;
  end;

implementation

{ TSigNETStringGrid }

function TSigNETStringGrid.GetRowCount: Longint;
begin
  if Visible then
  begin
    Result := inherited RowCount;
  end
  else if csDesigning in ComponentState then
  begin
    Result := inherited RowCount;
  end
  else
  begin
    Result := FixedRows;
  end
end;

procedure TSigNETStringGrid.InvalidateCell(ACol, ARow: Integer);
begin
  inherited InvalidateCell( ACol, ARow );
end;

procedure TSigNETStringGrid.SetRowCount(Value: Integer);
begin
  if csDesigning in ComponentState then
  begin
    inherited RowCount := Value;
  end
  else if Value <= FixedRows then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited RowCount := Value;
  end;
end;

end.
