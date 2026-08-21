unit MearLanDrawGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, MearLanObjects;

type
  TMearLanDrawGrid = class(TDrawGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TMearLanDrawGrid]);
end;

constructor TMearLanDrawGrid.Create(AOwner: TComponent); override;
begin
  inherited Create;
  RowCount := 1;
  ColCount := 2;
  FixedRows := 0;
  FixedCols := 1;
end;

end.
