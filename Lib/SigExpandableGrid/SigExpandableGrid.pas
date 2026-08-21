unit SigExpandableGrid;

{
  The purpose of this design is to provide a grid with expansion
  and compression capabolities.

  Rows and columns are organised into expansion groups and objects.

  An expansion cell has a two expansion group parents. It also has
  and optional icon and short string displayed under the icon.

  There are 4 states for the grid members. These determine bg colour
  of text:
    No-Error, Not selected   Black on White
    No-Error, Selected       White on black
    Error, Not Selected      Bold Red Italic on White
    Error, Selected          Bold White Italic on Red
  An error in any expanded cell implies an error in the higher level
  compressed cells.

  Every cell has an Icon and text, be it compressed or expanded. Icons
  of compressed (or expanded) cells can be determined statically (by
  assigning the icon) or dynamically by supplying either a OnGetCellIcon
  or OnGetCellIconIndex call-back.
}

interface

uses
  SysUtils,
  Classes,
  Controls,
  Grids,
  Contnrs;

type
  tExpandableCell = class
  private
    fParent: tExpandableCell;
    fExpanded: boolean;
  protected
    procedure SetExpanded(const Value: boolean); virtual;
    procedure Refresh; virtual;
  public
    constructor Create( pParent : tExpandableCell );

    property Parent : tExpandableCell
             read fParent;
    property Expanded : boolean
             read fExpanded
             write SetExpanded;
  end;

  tExpandableGroupCell = class( tExpandableCell )
  private
    fIndex: integer;
  public
    property Index : integer
             read fIndex;
  end;

  tExpandableGroupCellList = class( tObjectList )
  private
  public
  end;

  tExpandableCellEntry = class( tExpandableCell )
  private
    fRow: tExpandableGroupCell;
    fColumn: tExpandableGroupCell;
  public
    property Row : tExpandableGroupCell
    read fRow;
    property Column : tExpandableGroupCell
    read fColumn;
  end;

  tExpandableCellEntryList = class( tObjectList )
  private
  public
  end;

  tExpandableGroupBlock = class( tExpandableGroupCell )
  private
    fCells : tExpandableGroupCellList;
  public
    constructor Create( pParent : tExpandableCell );
  end;

  tExpandableGroupEntryBlock = class( tExpandableCellEntry )
  private
    fCells : tExpandableCellEntryList;
  public
  end;

  tExpandableTable = class( tExpandableCell )
  private
    fRowHeaders: tExpandableGroupBlock;
  public
    constructor Create;
    destructor Destroy; override;

    property RowHeaders : tExpandableGroupBlock
             read fRowHeaders;
  end;

  TSigExpandableDrawGrid = class(TDrawGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigExpandableDrawGrid]);
end;

{ tExpandableTable }

constructor tExpandableTable.Create;
begin
  inherited Create( nil );

  fRowHeaders := tExpandableGroupBlock.Create( self );

end;

destructor tExpandableTable.Destroy;
begin

  fRowHeaders.Free;

  inherited;
end;

{ tExpandableGroupBlock }

constructor tExpandableGroupBlock.Create(pParent: tExpandableCell);
begin
  inherited Create( pParent );

  fCells := tExpandableGroupCellList.Create;

end;

{ tExpandableCell }

constructor tExpandableCell.Create(pParent: tExpandableCell);
begin
  inherited Create;

  fParent := pParent;
  fExpanded := TRUE;
end;

procedure tExpandableCell.Refresh;
begin
  if assigned( fParent ) then
  begin
    fParent.Refresh;
  end;
end;

procedure tExpandableCell.SetExpanded(const Value: boolean);
begin
  fExpanded := Value;
  Refresh;
end;

end.
