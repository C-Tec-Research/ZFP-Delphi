unit SigSparseLists;

{
  A series of sparse arrays and grids
}

interface

uses
  Contnrs,
  Classes;

type
  tSigSparseElementList = class;
  tSigSparseColumn = class;
  tSigSparseTable = class;

  tSigSparseElement = class
  private
    fText: string;
  protected
    fOwner: tSigSparseElementList;
  public
    constructor Create( pOwner : tSigSparseElementList );
    property Owner : tSigSparseElementList
             read fOwner;
    property Text : string
             read fText
             write fText;
  end;

  tSigSparseElementList = class( tObjectList )
  private
  public
    constructor Create;

    function Add( Value : tSigSparseElement ) : integer; reintroduce;
  end;

  tSigSparseColumnCell = class( tSigSparseElement )
  private
    fRow: integer;
  public
    constructor Create( pOwner : tSigSparseColumn );

    property Row : integer
             read fRow;
  end;

  tSigSparseColumn = class( tSigSparseElementList )
  private
  public
    function Add( Value : tSigSparseColumnCell ) : integer; reintroduce;
    procedure Insert( const AtIndex : integer; Value : tSigSparseColumnCell ); reintroduce;

  end;

  tSigSparseTableCell = class( tSigSparseColumnCell )
  // 2D version
  private
    fColumn: integer;
  public
    constructor Create( pOwner : tSigSparseTable );

    property Column : integer
             read fColumn;
  end;

  tSigSparseTable = class( tSigSparseColumn )
  private
    function GetCell(const x, y: integer): string;
    procedure SetCell(const x, y: integer; const Value: string);
  public

    function Add( Value : tSigSparseTableCell ) : integer; reintroduce;
    procedure Insert( const AtIndex : integer; Value : tSigSparseTableCell ); reintroduce;

    property Cell[ const x, y : integer ] : string
             read GetCell
             write SetCell;
  end;


implementation



{ tSigSparseElement }

constructor tSigSparseElement.Create(pOwner: tSigSparseElementList);
begin
  inherited Create;
  fOwner := pOwner;
end;

{ tSigSparseElementList }

function tSigSparseElementList.Add(Value: tSigSparseElement): integer;
begin
  Result := inherited Add( Value );
end;

constructor tSigSparseElementList.Create;
begin
  inherited Create( TRUE );
end;

{ tSigSparseTable }

function tSigSparseTable.Add(Value: tSigSparseTableCell): integer;
var
  i: Integer;
  iCell : tSigSparseTableCell;
begin
  for i := 0 to Count - 1 do
  begin
    iCell := Items[ i ] as  tSigSparseTableCell;
    if (Value.Row <= iCell.Row) and (Value.Column <= iCell.Column )  then
    begin
      Result := i;
      Insert( i, Value );
      exit;
    end;
  end;
  Result := inherited Add( Value );
end;

function tSigSparseTable.GetCell(const x, y: integer): string;
var
  i: Integer;
  iCell : tSigSparseTableCell;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    iCell := Items[ i ] as  tSigSparseTableCell;
    if iCell.Column = x then
    begin
      if iCell.Row = y then
      begin
        Result := iCell.Text;
        exit;
      end
      else if iCell.Row > y then
      begin
        exit;
      end;
    end
    else if iCell.Column > x then
    begin
      exit;
    end;
  end;
end;

procedure tSigSparseTable.Insert(const AtIndex: integer;
  Value: tSigSparseTableCell);
begin
  inherited Insert( AtIndex, Value );
end;

procedure tSigSparseTable.SetCell(const x, y: integer; const Value: string);
var
  i: Integer;
  iCell : tSigSparseTableCell;
begin
  for i := 0 to Count - 1 do
  begin
    iCell := Items[ i ] as  tSigSparseTableCell;
    if iCell.Column = x then
    begin
      if iCell.Row = y then
      begin
        iCell.Text := Value;
        exit;
      end
      else if iCell.Row > y then
      begin
        break;
      end;
    end
    else if iCell.Column > x then
    begin
      break;
    end;
  end;
  // if we get here we are adding
  iCell := tSigSparseTableCell.Create( self );
  iCell.Text := Value;
  iCell.fRow := y;
  iCell.fColumn := x;
  Add( iCell );
end;

{ tSigSparseColumnCell }

constructor tSigSparseColumnCell.Create(pOwner: tSigSparseColumn);
begin
  inherited Create( pOwner );
end;

{ tSigSparseTableCell }

constructor tSigSparseTableCell.Create(pOwner: tSigSparseTable);
begin
  inherited Create( pOwner );
end;

{ tSigSparseColumn }

function tSigSparseColumn.Add(Value: tSigSparseColumnCell): integer;
var
  i: Integer;
  iCell : tSigSparseColumnCell;
begin
  for i := 0 to Count - 1 do
  begin
    iCell := Items[ i ] as  tSigSparseColumnCell;
    if Value.Row <= iCell.Row  then
    begin
      Result := i;
      Insert( i, Value );
      exit;
    end;
  end;
  Result := inherited Add( Value );
end;

procedure tSigSparseColumn.Insert(const AtIndex: integer;
  Value: tSigSparseColumnCell);
begin
  inherited Insert( AtIndex, Value );
end;

end.
