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
    procedure SetRowCount(Value: Longint);
    procedure SetFixedRows(Value: Longint);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property RowCount         
             read NewRowCount
             write SetRowCount;
    property FixedRows         
             read NewFixedRows
             write SetFixedRows;
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
