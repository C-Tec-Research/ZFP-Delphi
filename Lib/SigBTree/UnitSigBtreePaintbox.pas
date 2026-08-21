unit UnitSigBtreePaintbox;

interface

Uses
  System.Types,
  System.Classes,
  VCL.ExtCtrls,
  VCL.Graphics,
  //TypedObjectList
  System.Generics.Collections;

type
  TPaintboxCell = class
  private
    fRect: TRect;
    fText: string;
    fData: TObject;
    fTag: integer;
  protected
  public
    property Rect : TRect
             read fRect
             write fRect;
    property Text : string
             read fText
             write fText;
    property Data : TObject
             read fData
             write fData;
    property Tag : integer
             read fTag
             write fTag;
  end;

  TPaintboxCellList = class( TObjectList< TPaintboxCell > )
  private
    function GetMax: integer;
  protected
  public
    function MouseToCell( const X,Y : integer ) : TPaintboxCell;

    property Max : integer
             read GetMax;
  end;

  TPaintBox = class( VCL.ExtCtrls.TPaintBox )
  private
    fCells: TPaintboxCellList;
    fColour: TColor;
    procedure SetColour(const Value: TColor);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    property Cells : TPaintboxCellList
             read fCells;
    property BkColour : TColor
             read fColour
             write SetColour;
    function AddCell( const pText : string; const pRect : TRect; const pObject : TObject; const pTag : integer = 0 ) : TPaintboxCell; overload;
    function AddCell( const pText : string; const pRect : TRect; const pTag : integer ) : TPaintboxCell; overload;
    function AddCell( const pText : string; const pRect : TRect ) : TPaintboxCell; overload;
    function MouseToCell( const X,Y : integer ) : TPaintboxCell;
  end;

implementation

{ TPaintBox }

function TPaintBox.AddCell(const pText: string; const pRect: TRect; const pObject : TObject; const pTag : integer ): TPaintboxCell;
begin
  Result := AddCell( pText, pRect );
  Result.Data := pObject;
  Result.Tag := pTag;
end;

function TPaintBox.AddCell(const pText: string; const pRect: TRect;
  const pTag: integer): TPaintboxCell;
begin
  Result := AddCell( pText, pRect );
  Result.Tag := pTag;
end;

function TPaintBox.AddCell(const pText: string; const pRect: TRect): TPaintboxCell;
var
  iTextWidth : integer;
  iRect : TRect;
  iText : string;
begin
  iRect := pRect;
  iText := ' ' + pText + ' ';
  iTextWidth := Canvas.TextWidth( iText );

  if iTextWidth < (iRect.Right - iRect.Left) then
  begin
    iRect.Left := (pRect.Left + pRect.Right - iTextWidth) div 2;
    iRect.Right := iRect.Left + iTextWidth;
  end;

  Result := TPaintboxCell.Create;
  Result.Rect := iRect;
  Result.Text := pText;
  fCells.Add( Result );
  Canvas.FrameRect( iRect );
  Canvas.TextRect( iRect, iText );

end;

procedure TPaintBox.Clear;
begin
  fCells.Clear;

  with Canvas do
  begin
    Brush.Color := BkColour;
    FillRect( ClientRect );
  end;
end;

constructor TPaintBox.Create(AOwner: TComponent);
begin
  inherited;

  fCells := TPaintboxCellList.Create;

end;

destructor TPaintBox.Destroy;
begin
  fCells.Free;
  inherited;
end;

function TPaintBox.MouseToCell(const X, Y: integer): TPaintboxCell;
begin
  Result := fCells.MouseToCell( X, Y );
end;

procedure TPaintBox.SetColour(const Value: TColor);
begin
  fColour := Value;
  with Canvas do
  begin
    Brush.Color := BkColour;
    FillRect( ClientRect );
  end;
end;

{ TPaintboxCellList }

function TPaintboxCellList.GetMax: integer;
begin
  Result := Count - 1;
end;

function TPaintboxCellList.MouseToCell(const X, Y: integer): TPaintboxCell;
var
  iPoint : TPoint;
  i: Integer;
begin
  iPoint.X := X;
  iPoint.Y := Y;
  for i := 0 to Max do
  begin
    Result := Items[ i ];
    if Result.Rect.Contains( iPoint ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

end.
