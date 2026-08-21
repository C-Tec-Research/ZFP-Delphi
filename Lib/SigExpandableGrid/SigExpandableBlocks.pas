unit SigExpandableBlocks;

interface

{
  provides a helper class to allow grids to have collapsible elements
}

uses
  Grids,
  Types,
  Contnrs,
  Graphics,
  SysUtils,
  Classes;

type
  tSigExpandableBlockIndexResult = ( ebrNotMe, ebrTitleCell, ebrClientCell, ebrMeCollapsed, ebrSeparator );

  eExpandableBlockException = class( Exception )

  end;

  tSigExpandableBlock = class;
  tSigExpandableGrid = class;

  tSigExpandableBlock = class( tObjectList )
  private
    fSize: integer;
    fColour: tColor;
    fParent: tSigExpandableBlock;
    fParentGrid: tSigExpandableGrid;
    fCollapsed: boolean;
    function GetChildBlock(const i: integer): tSigExpandableBlock;
    function GetChildColor: tColor;
  protected
    procedure Refresh; virtual;
  public
    constructor Create( pParent : tObject ); reintroduce; virtual;

    property Parent : tSigExpandableBlock
             read fParent;
    property ParentGrid : tSigExpandableGrid
             read fParentGrid;
    property Size : integer
             read fSize
             write fSize;
    property Colour : tColor
             read fColour;
    property ChildBlock[ const i : integer ] : tSigExpandableBlock
             read GetChildBlock;
    property Collapsed : boolean
             read fCollapsed
             write fCollapsed;

    function MapPhysicalCellIndex( var pPhysicalIndex : integer;
                                   var pLogicalIndex : integer;
                                   var Destination : tSigExpandableBlock ): tSigExpandableBlockIndexResult; virtual;
    procedure InsertDivider( AtPos : integer; pColour : tColor; pThickness : integer ); virtual;

    property ChildColour : tColor
             read GetChildColor;

  end;

  (*
  tSigExpandableBlock = class( tSigExpandableBlockRoot )
  private
    fCollapsed: boolean;
    fThickness: integer;
    fOnDrawDivider: tDrawCellEvent;
    fOnDrawCollapsed: tDrawCellEvent;
  public
    property Collapsed : boolean
             read fCollapsed
             write fCollapsed;
    property Thickness : integer
             read fThickness
             write fThickness;
    property OnDrawCollapsed : tDrawCellEvent
             read fOnDrawCollapsed
             write fOnDrawCollapsed;
    property OnDrawDivider : tDrawCellEvent
             read fOnDrawDivider
             write fOnDrawDivider;

    procedure DrawCollapsed(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState); virtual;

    procedure DrawDivider(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState); virtual;

    function MapPhysicalCellIndex( var pPhysicalIndex : integer; var pLogicalIndex : integer; var Destination : tSigExpandableBlock ): tSigExpandableBlockIndexResult; override;
{
    property OnDrawCell : tDrawCellEvent
             read fOnDrawCell
             write fOnDrawCell;

    function DrawCell(Sender: TObject; var ACol, ARow: Longint; Rect: TRect; State: TGridDrawState) : boolean;
}

  end;
  *)
  (*
  tSigExpandableBlockBase = class( tSigExpandableBlock )
    // the actual interface
  private
    fOnRefresh: tNotifyEvent;
  protected
    procedure Refresh; override;
  public
    constructor Create; reintroduce;
    property OnRefresh : tNotifyEvent
             read fOnRefresh
             write fOnRefresh;
  end;
  *)

  tSigExpandableGrid = class
  {
    A 2 dimensional interface mapping a table to 2 expandable blocks
    One for rows and one for columns
  }
  private
    fRows: tSigExpandableBlock;
    fCols: tSigExpandableBlock;
    fRowDividersDominate: boolean;
    fTitleColCount: integer;
    fColCount: integer;
    fRowCount: integer;
    fTitleRowCount: integer;
    procedure SetColCount(const Value: integer);
    procedure SetTitleColCount(const Value: integer);
    procedure SetRowCount(const Value: integer);
    procedure SetTitleRowCount(const Value: integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function MapCell( const FromCol, FromRow : integer; var ToCol, ToRow, ToColCount, ToRowCount : integer;
                      var pColour : tColor ): tSigExpandableBlockIndexResult;

    property Cols : tSigExpandableBlock
             read fCols;
    property Rows : tSigExpandableBlock
             read fRows;

    property RowDividersDominate : boolean
             read fRowDividersDominate
             write fRowDividersDominate;

    property TitleColCount : integer
             read fTitleColCount
             write SetTitleColCount;
    property ColCount : integer
             read fColCount
             write SetColCount;
    property TitleRowCount : integer
             read fTitleRowCount
             write SetTitleRowCount;
    property RowCount : integer
             read fRowCount
             write SetRowCount;

  end;

implementation

(*
{ tSigExpandableBlock }


procedure tSigExpandableBlock.DrawCollapsed(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if assigned( fOnDrawCollapsed )  then
  begin
    fOnDrawCollapsed( Sender, ACol, ARow, Rect, State );
  end;
end;

procedure tSigExpandableBlock.DrawDivider(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if assigned( fOnDrawDivider )  then
  begin
    fOnDrawDivider( Sender, ACol, ARow, Rect, State );
  end;
end;

function tSigExpandableBlock.MapPhysicalCellIndex(var pPhysicalIndex: integer;
  var pLogicalIndex: integer;
  var Destination: tSigExpandableBlock): tSigExpandableBlockIndexResult;
var
  i: Integer;
begin
  // map a physical cell to a logical one or an expansion cell
  if Collapsed then
  begin
    case pPhysicalIndex of
      0:
      begin
        Result := ebrMeCollapsed;
        Destination := self;
      end;
      1:
      begin
        Result := ebrSeparator;
        Destination := self;
      end;
      else
      begin
        Result := ebrNotMe;
        dec( pPhysicalIndex, 2 );
        inc( pLogicalIndex, Size );
      end;
    end;
  end
  else
  begin
    if pPhysicalIndex = Size then
    begin
      Result := ebrSeparator;
      Destination := self;
    end
    else if pPhysicalIndex < Size then
    begin
      if Count > 0 then
      begin
        for i := 0 to Count - 1 do
        begin
          Result := ChildBlock[ i ].MapPhysicalCellIndex( pPhysicalIndex, pLogicalIndex, Destination );
          case Result of
            ebrNotMe: ; // pass to next
            ebrClientCell,
            ebrMeCollapsed,
            ebrSeparator:
            begin
              exit;
            end;
          end;
        end;
        // should not get here
        raise eExpandableBlockException.Create( 'Internal Error 001 - Expandable Blocks' );
      end
      else
      begin
        Result := ebrClientCell; // gives physical cell location
        Destination := self;
      end;
    end
    else
    begin
      Result := ebrNotMe;
      dec( pPhysicalIndex, Size + 1 );
      inc( pLogicalIndex, Size );
    end;
  end;
end;
*)

{ tSigExpandableBlockRoot }

constructor tSigExpandableBlock.Create( pParent : tObject );
begin
  inherited Create( TRUE );
  if pParent is tSigExpandableBlock then
  begin
    fParent := pParent as tSigExpandableBlock;
    fParentGrid := fParent.ParentGrid;
  end
  else
  begin
    fParent := nil;
    fParentGrid := pParent as tSigExpandableGrid;
  end;
  if assigned( fParent ) then
  begin
    case fParent.Colour of
      clNone:           fColour := clBlue;
      clBlue:           fColour := clRed;
      clRed:            fColour := clLime;
      clLime:           fColour := clFuchsia;
      else              fColour := clNone;
    end;
  end
  else
  begin
    fColour := clBlue;
  end;
end;

function tSigExpandableBlock.GetChildBlock(
  const i: integer): tSigExpandableBlock;
begin
  Result := Items[ i ] as tSigExpandableBlock;
end;

function tSigExpandableBlock.GetChildColor: tColor;
begin
  case Colour of
      clNone:           Result := clBlue;
      clBlue:           Result := clRed;
      clRed:            Result := clLime;
      clLime:           Result := clFuchsia;
      else              Result := clNone;
  end;
end;

procedure tSigExpandableBlock.InsertDivider(AtPos: integer; pColour: tColor;
  pThickness: integer);
var
  i : integer;
  iChild : tSigExpandableBlock;
begin
  if AtPos > size then
  begin
    raise eExpandableBlockException.Create( 'Split Range Error (' + IntToStr(AtPos) + ') in Expandable Blocks' );
  end;
  if AtPos = Size then
  begin
    raise eExpandableBlockException.Create( 'Cannot split block here' );
  end;
  // colour implies level
  if Count = 0 then
  begin
    if pColour = ChildColour then
    begin
      // add two children, whose size adds up to ours
      iChild := tSigExpandableBlock.Create( self );
      iChild.Size := AtPos;
      Add( iChild );
      iChild := tSigExpandableBlock.Create( self );
      iChild.Size := Size - AtPos;
      Add( iChild );
    end
    else
    begin
      raise eExpandableBlockException.Create( 'Cannot split block here' );
    end;
  end
  else if pColour = ChildColour then
  begin
    // need to split a child
    for i := 0 to Count - 1 do
    begin
      with ChildBlock[ i ] do
      begin
        if Size = AtPos then
        begin
          raise eExpandableBlockException.Create( 'Cannot split block here' );
        end
        else if AtPos > Size then
        begin
          dec( AtPos, Size );
        end
        else
        begin
          Size := Size - AtPos;
          iChild := tSigExpandableBlock.Create( self );
          iChild.Size := AtPos;
          Insert( i, iChild );
        end;
      end;
    end;
  end
  else
  begin

  end;
end;

function tSigExpandableBlock.MapPhysicalCellIndex(var pPhysicalIndex,
  pLogicalIndex: integer;
  var Destination: tSigExpandableBlock): tSigExpandableBlockIndexResult;
var
  i: Integer;
begin
  // map a physical cell to a logical one or an expansion cell
  if Collapsed then
  begin
    case pPhysicalIndex of
      1:
      begin
        Result := ebrMeCollapsed;
        Destination := self;
      end;
      0,2:
      begin
        Result := ebrSeparator;
        Destination := self;
      end;
      else
      begin
        Result := ebrNotMe;
        dec( pPhysicalIndex, 3 );
        inc( pLogicalIndex, Size );
      end;
    end;
  end
  else
  begin
    if (pPhysicalIndex = 0) or (pPhysicalIndex = Size + 1) then
    begin
      Result := ebrSeparator;
      Destination := self;
    end
    else if pPhysicalIndex <= Size then
    begin
      if Count > 0 then
      begin
        for i := 0 to Count - 1 do
        begin
          Result := ChildBlock[ i ].MapPhysicalCellIndex( pPhysicalIndex, pLogicalIndex, Destination );
          case Result of
            ebrNotMe: ; // pass to next
            ebrClientCell,
            ebrMeCollapsed,
            ebrSeparator:
            begin
              exit;
            end;
          end;
        end;
        // should not get here
        raise eExpandableBlockException.Create( 'Internal Error 001 - Expandable Blocks' );
      end
      else
      begin
        dec( pPhysicalIndex );
        Result := ebrClientCell; // gives physical cell location
        Destination := self;
      end;
    end
    else
    begin
      Result := ebrNotMe;
      dec( pPhysicalIndex, Size + 2 );
      inc( pLogicalIndex, Size );
    end;
  end;
end;

procedure tSigExpandableBlock.Refresh;
begin
  fParent.Refresh;
end;

(*
{ tSigExpandableBlockBase }

constructor tSigExpandableBlockBase.Create;
begin
  inherited Create( nil );
end;

procedure tSigExpandableBlockBase.Refresh;
begin
  if assigned( fOnRefresh ) then
  begin
    fOnRefresh( self );
  end;

end;
*)

{ tSigExpandableGrid }

procedure tSigExpandableGrid.Clear;
begin
  fRows.Clear;
  fCols.Clear;
end;

constructor tSigExpandableGrid.Create;
begin
  inherited Create;

  fCols := tSigExpandableBlock.Create( self );
  fRows := tSigExpandableBlock.Create( self );
end;

destructor tSigExpandableGrid.Destroy;
begin
  fRows.Free;
  fCols.Free;

  inherited;
end;

function tSigExpandableGrid.MapCell(const FromCol, FromRow: integer; var ToCol,
  ToRow, ToColCount, ToRowCount: integer; var pColour : tColor): tSigExpandableBlockIndexResult;
var
  iColResult, iRowResult : tSigExpandableBlockIndexResult;
  iRowDestination, iColDestination : tSigExpandableBlock;
  iFromCol, iFromRow : integer;
begin
  pColour := clNone;
  iRowDestination := nil;
  iColDestination := nil;
  ToCol := FromCol;
  Result := ebrNotMe; // error state
  if FromCol < fTitleColCount then
  begin
    iColResult := ebrTitleCell;
  end
  else
  begin
    iFromCol := FromCol;
    iColResult := fCols.MapPhysicalCellIndex( iFromCol, ToCol, iColDestination );
  end;
  ToRow := ToRow;
  if FromRow < fTitleRowCount then
  begin
    iRowResult := ebrTitleCell;
  end
  else
  begin
    iFromRow := FromRow;
    iRowResult := fRows.MapPhysicalCellIndex( iFromRow, ToRow, iRowDestination );
  end;
  case iColResult of
    ebrNotMe:
    begin
      Result := ebrNotMe; // ???
      ToColCount := 0;
      ToRowCount := 0;
    end;
    ebrTitleCell:
    begin
      case iRowResult of
        ebrNotMe:
        begin
          Result := ebrNotMe; // ???
          ToColCount := 0;
          ToRowCount := 0;
        end;
        ebrTitleCell:
        begin
          Result := ebrTitleCell;
          ToColCount := 1;
          ToRowCount := 1;
        end;
        ebrClientCell:
        begin
          Result := ebrTitleCell;
          ToColCount := 1;
          ToRowCount := 1;
        end;
        ebrMeCollapsed:
        begin
          Result := ebrTitleCell;
          ToColCount := 1;
          ToRowCount := iRowDestination.Size;
        end;
        ebrSeparator:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iRowDestination.Colour;
        end;
      end;
    end;
    ebrClientCell:
    begin
      case iRowResult of
        ebrNotMe:
        begin
          Result := ebrNotMe; // ???
          ToColCount := 0;
          ToRowCount := 0;
        end;
        ebrTitleCell:
        begin
          Result := ebrTitleCell;
          ToColCount := 1;
          ToRowCount := 1;
        end;
        ebrClientCell:
        begin
          Result := ebrClientCell;
          ToColCount := 1;
          ToRowCount := 1;
        end;
        ebrMeCollapsed:
        begin
          Result := ebrMeCollapsed;
          ToColCount := 1;
          ToRowCount := iRowDestination.Size;
        end;
        ebrSeparator:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iRowDestination.Colour;
        end;
      end;
    end;
    ebrMeCollapsed:
    begin
      case iRowResult of
        ebrNotMe:
        begin
          Result := ebrNotMe; // ???
          ToColCount := 0;
          ToRowCount := 0;
        end;
        ebrTitleCell:
        begin
          Result := ebrTitleCell;
          ToColCount := iColDestination.Size;
          ToRowCount := 1;
        end;
        ebrClientCell:
        begin
          Result := ebrMeCollapsed;
          ToColCount := iColDestination.Size;
          ToRowCount := 1;
        end;
        ebrMeCollapsed:
        begin
          Result := ebrMeCollapsed;
          ToColCount := iColDestination.Size;
          ToRowCount := iRowDestination.Size;
        end;
        ebrSeparator:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iRowDestination.Colour;
        end;
      end;
    end;
    ebrSeparator:
    begin
      case iRowResult of
        ebrNotMe:
        begin
          Result := ebrNotMe; // ???
          ToColCount := 0;
          ToRowCount := 0;
        end;
        ebrTitleCell:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iColDestination.Colour;
        end;
        ebrClientCell:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iColDestination.Colour;
        end;
        ebrMeCollapsed:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          pColour := iColDestination.Colour;
        end;
        ebrSeparator:
        begin
          Result := ebrSeparator;
          ToColCount := 1;
          ToRowCount := 1;
          if RowDividersDominate then
          begin
            pColour := iRowDestination.Colour;
          end
          else
          begin
            pColour := iColDestination.Colour;
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigExpandableGrid.SetColCount(const Value: integer);
begin
  fColCount := Value;
end;

procedure tSigExpandableGrid.SetRowCount(const Value: integer);
begin
  fRowCount := Value;
end;

procedure tSigExpandableGrid.SetTitleColCount(const Value: integer);
begin
  fTitleColCount := Value;
end;

procedure tSigExpandableGrid.SetTitleRowCount(const Value: integer);
begin
  fTitleRowCount := Value;
end;

end.
