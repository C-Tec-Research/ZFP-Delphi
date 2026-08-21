unit UnitSigBTreeVCLHelper;

{
  Helpers for Binary Tree specifically for VCL
}

interface

uses
  System.Types,
  VCL.Graphics,
  SigBTree,
  UnitSigBTreeHelper,
  UnitSigBtreePaintbox;

type TSigBTreeVCLHelper = class( TSigBTreeHelper )
  private
    fPaintbox: TPaintBox;
    fBkGround: TColor;
    procedure OnPaint( Sender : tObject );
    procedure SetPaintBox(const Value: TPaintBox);
  protected
    procedure SetSigBTreeRoot(const Value: TSigDBTreeRoot); override;
  public
    constructor Create;
    property Paintbox : TPaintBox
             read fPaintbox
             write SetPaintBox;
    property BkGround : TColor
             read fBkGround
             write fBkGround;

    procedure DrawTree( pFromNode : TSigBTreeNode; const PaintBox : TPaintbox; const pLineHeight : integer; const pCurrLine : tRect; const DrawAll : boolean = TRUE ); virtual;
    procedure DrawNode( pFromNode : TSigBTreeNode; const PaintBox : TPaintbox; pCurrLine : TRect ); virtual;
    procedure DrawPaintbox;
  end;

implementation

{ TSigBTreeVCLHelper }

constructor TSigBTreeVCLHelper.Create;
begin
  inherited Create;
  fBkGround := clWhite;
end;

procedure TSigBTreeVCLHelper.DrawNode(pFromNode: TSigBTreeNode; const PaintBox: TPaintbox; pCurrLine: TRect);
var
  iText : string;
begin
  with pFromNode do
  begin
    iText := NodeText;
    Paintbox.AddCell( iText, pCurrLine, self );
  end;
end;

procedure TSigBTreeVCLHelper.DrawPaintbox;
begin
  if assigned( Paintbox ) then
  begin
    if assigned( SigBTreeRoot ) then
    begin
      Paintbox.Repaint;
    end;
  end;
end;

procedure TSigBTreeVCLHelper.DrawTree(pFromNode: TSigBTreeNode; const PaintBox: TPaintbox; const pLineHeight: integer; const pCurrLine: tRect; const DrawAll: boolean = TRUE);
var
  iLeftRect, iRightRect : tRect;
  iCentre : integer;
begin
  with pFromNode do
  begin
    DrawNode( pFromNode, Paintbox, pCurrLine );
    iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
    if assigned( LeftChild ) then
    begin
      iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
      iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
      iLeftRect.Left := pCurrLine.Left;
      iLeftRect.Right := iCentre;
      Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
      Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
      DrawTree( LeftChild, Paintbox, pLineHeight, iLeftRect, DrawAll );
    end;
    if assigned( RightChild ) then
    begin
      iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
      iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
      iRightRect.Left := iCentre;
      iRightRect.Right := pCurrLine.Right;
      Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
      Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
      DrawTree( RightChild, Paintbox, pLineHeight, iRightRect, DrawAll );
    end;
  end;
end;

procedure TSigBTreeVCLHelper.OnPaint(Sender: tObject);
var
  iDepth, iRowCount : integer;
  iRowHeight : integer;
  iRect : tRect;
begin
  // A box filling the whole canvas in the background colour
  with fPaintbox.Canvas do
  begin
    Brush.Color := BkGround;
    FillRect( fPaintBox.ClientRect );
  end;
  if assigned( SigBTreeRoot.LeftChild ) then
  begin
    iDepth := SigBTreeRoot.LeftChild.TreeDepth + 1;
    // interlace the rows by blank rows (for our lines );
    iRowCount := 2 * iDepth + 1;
    iRowHeight := fPaintbox.ClientHeight div iRowCount;
    iRect := fPaintbox.ClientRect;
    //LeftChild.DrawTree( fPaintbox.Canvas, iRowHeight, iRect );
    if assigned( SigBTreeRoot ) then
    begin
      DrawTree( SigBTreeRoot.LeftChild, fPaintbox, iRowHeight, iRect );
    end;
  end;
end;

procedure TSigBTreeVCLHelper.SetPaintBox(const Value: TPaintBox);
begin
  fPaintbox := Value;
  DrawPaintBox;
end;

procedure TSigBTreeVCLHelper.SetSigBTreeRoot(const Value: TSigDBTreeRoot);
begin
  inherited;
  DrawPaintbox;
end;

end.
