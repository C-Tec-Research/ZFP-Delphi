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
  tSigExpandableBlockIndexResult = ( ebrNotMe, ebrClientCell, ebrMeCollapsed, ebrSeparator );

  eExpandableBlockException = class( Exception )

  end;

  tSigExpandableBlock = class;

  tSigExpandableBlockRoot = class( tObjectList )
  private
    fSize: integer;
    fColour: tColor;
    fParent: tSigExpandableBlockRoot;
    function GetChildBlock(const i: integer): tSigExpandableBlock;
    function GetChildColor: tColor;
  protected
    procedure Refresh; virtual;
  public
    constructor Create( pParent : tSigExpandableBlockRoot ); reintroduce; virtual;

    property Parent : tSigExpandableBlockRoot
             read fParent;
    property Size : integer
             read fSize
             write fSize;
    property Colour : tColor
             read fColour;
    property ChildBlock[ const i : integer ] : tSigExpandableBlock
             read GetChildBlock;

    function MapPhysicalCellIndex( var pPhysicalIndex : integer; var pLogicalIndex : integer; var Destination : tSigExpandableBlock ): tSigExpandableBlockIndexResult; virtual;
    procedure InsertDivider( AtPos : integer; pColour : tColor; pThickness : integer ); virtual;

    property ChildColour : tColor
             read GetChildColor;


  end;

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

  tSigExpandableBlockBase = class( tSigExpandableBlockRoot )
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

implementation

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

{ tSigExpandableBlockRoot }

constructor tSigExpandableBlockRoot.Create( pParent : tSigExpandableBlockRoot );
begin
  inherited Create( TRUE );
  fParent := pParent;
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
    fColour := clNone;
  end;
end;

function tSigExpandableBlockRoot.GetChildBlock(
  const i: integer): tSigExpandableBlock;
begin
  Result := Items[ i ] as tSigExpandableBlock;
end;

function tSigExpandableBlockRoot.GetChildColor: tColor;
begin
  case Colour of
      clNone:           Result := clBlue;
      clBlue:           Result := clRed;
      clRed:            Result := clLime;
      clLime:           Result := clFuchsia;
      else              Result := clNone;
  end;
end;

procedure tSigExpandableBlockRoot.InsertDivider(AtPos: integer; pColour: tColor;
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

function tSigExpandableBlockRoot.MapPhysicalCellIndex(var pPhysicalIndex,
  pLogicalIndex: integer;
  var Destination: tSigExpandableBlock): tSigExpandableBlockIndexResult;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := ChildBlock[ i ].MapPhysicalCellIndex( pPhysicalIndex, pLogicalIndex, Destination );
    case result of
      ebrNotMe: ;   // try next one
      ebrClientCell,
      ebrMeCollapsed,
      ebrSeparator:
      begin
        exit;
      end;
    end;
  end;
  // should not get here
  raise eExpandableBlockException.Create( 'Internal Error 002 - Expandable Blocks' );
end;

procedure tSigExpandableBlockRoot.Refresh;
begin
  fParent.Refresh;
end;

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

end.
