unit SigBTree;

{
  This unit provides both an abstracted class and a memory based descentant,
  although that is also abstract because the data is not defined so
  LessThan cannot be defined.

  The root is a placeholder: Only ever use leftchild of the
  root.
}

interface

uses
  System.Types,
  System.SysUtils,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  VCL.Graphics;

type

  tSigBTreeNode = class
  private
  protected
    function GetLeftChild: tSigBTreeNode; virtual; abstract;
    function GetParent: tSigBTreeNode; virtual; abstract;
    function GetRightChild: tSigBTreeNode; virtual; abstract;
    procedure SetLeftChild(const Value: tSigBTreeNode);  virtual; abstract;
    procedure SetParent(const Value: tSigBTreeNode);  virtual; abstract;
    procedure SetRightChild(const Value: tSigBTreeNode);  virtual; abstract;
    function GetTreeDepth: integer; virtual;
    procedure SetTreeDepth(const Value: integer); virtual;
  public
    property Parent : tSigBTreeNode
             read GetParent
             write SetParent;
    property LeftChild : tSigBTreeNode
             read GetLeftChild
             write SetLeftChild;
    property RightChild : tSigBTreeNode
             read GetRightChild
             write SetRightChild;

    function LessThan( const SigTreeNode : tSigBTreeNode ) : boolean; virtual; // by default compares the NodeText

    procedure Add( const SigTreeNode : tSigBTreeNode ) ; virtual;

    function First : tSigBTreeNode;
    function Next  : tSigBTreeNode;
    function Last  : tSigBTreeNode;
    function Prev  : tSigBTreeNode;

    property TreeDepth : integer
             read GetTreeDepth
             write SetTreeDepth;

    function Balance : tSigBTreeNode;  // returns new balance root

    function NodeText : string; virtual; abstract;  // returns the text to be displayed visually

    procedure DrawTree( const Canvas : tCanvas; const pLineHeight : integer; const pCurrLine : tRect );
    procedure DrawNode( const Canvas : tCanvas; pCurrLine : tRect ); virtual;

    procedure CheckTreeDepth; virtual;
  end;

  tSigBTreeNodeAVL = class( tSigBTreeNode )
  private
    fTreeDepth : integer;
  protected
    function GetTreeDepth: integer; override;
    procedure SetTreeDepth(const Value: integer); override;
  public
    procedure Add( const SigTreeNode : tSigBTreeNode ); override; // returns tree depth

    procedure CheckTreeDepth; override;
  end;

  tSigBTreeNodeMemory = class( tSigBTreeNodeAVL )
  private
    fParent : tSigBTreeNode;
    fLeftChild : tSigBTreeNode;
    fRightChild : tSigBTreeNode;
  protected
    function GetLeftChild: tSigBTreeNode; override;
    function GetParent: tSigBTreeNode; override;
    function GetRightChild: tSigBTreeNode; override;
    procedure SetLeftChild(const Value: tSigBTreeNode);  override;
    procedure SetParent(const Value: tSigBTreeNode);  override;
    procedure SetRightChild(const Value: tSigBTreeNode);  override;
  public
    destructor Destroy; override;
  end;

  tSigDBTreeRoot = class( tSigBTreeNodeMemory )
  private
    fPaintBox: tPaintBox;
    fBkGround: tColor;
    procedure SetPaintBox(const Value: tPaintBox);
    procedure OnPaint( Sender : tObject );
  protected
  public
    constructor Create; reintroduce;
    procedure Add( const SigTreeNode : tSigBTreeNode ); override; // returns tree depth
    property PaintBox : tPaintBox
             read fPaintBox
             write SetPaintBox;
    property BkGround : tColor
             read fBkGround
             write fBkGround;

    function NodeText : string; override;  // Root never gets displayed!
  end;

implementation

{ tSigBTreeNode }


procedure tSigBTreeNode.Add(const SigTreeNode: tSigBTreeNode);
begin
  if self.LessThan( SigTreeNode ) then
  begin
    // must add to right child
    if assigned( RightChild ) then
    begin
      RightChild.Add( SigTreeNode );
    end
    else
    begin
      RightChild := SigTreeNode;
      RightChild.GetLeftChild.Parent := self;
    end;
  end
  else
  begin
    // must add to left child
    if assigned( LeftChild ) then
    begin
      LeftChild.Add( SigTreeNode );
    end
    else
    begin
      LeftChild := SigTreeNode;
      LeftChild.Parent := self;
    end;
  end;
end;

function tSigBTreeNode.Balance: tSigBTreeNode;
var
  iLeftDepth, iRightDepth, iDiff : integer;
begin
  if assigned( LeftChild ) then
  begin
    iLeftDepth := LeftChild.TreeDepth + 1;
  end
  else
  begin
    iLeftDepth := 0;
  end;
  if assigned( RightChild ) then
  begin
    iRightDepth := RightChild.TreeDepth + 1;
  end
  else
  begin
    iRightDepth := 0;
  end;

  iDiff := iRightDepth - iLeftDepth;
  if iDiff > 1 then
  begin
    // Right is too long, so our rightchild becomes the new base
    Result := RightChild;
    // Its left child becomes our right child
    RightChild := Result.LeftChild;
    // We become its left child
    Result.LeftChild := self;
    if assigned( RightChild ) then
    begin
      iRightDepth := RightChild.TreeDepth + 1;
    end
    else
    begin
      iRightDepth := 0;
    end;
  end
  else if iDiff < -1 then
  begin
    // Left is too long, so
    begin
      // our leftchild becomes the new base
      Result := LeftChild;
      // Its right child becomes our left child
      LeftChild := Result.RightChild;
      // We become its Right child
      Result.RightChild := self;
      if assigned( LeftChild ) then
      begin
        iLeftDepth := LeftChild.TreeDepth + 1;
      end
      else
      begin
        iLeftDepth := 0;
      end;
    end;
  end
  else
  begin
    // nothing to do
    Result := self;
    exit;
  end;

  // point parent to new root
  if assigned( Parent ) then
  begin
    with Parent do
    begin
      if LeftChild = self then
      begin
        LeftChild := Result;
      end
      else if RightChild = self then
      begin
        RightChild := Result;
      end
      else
      begin
        raise Exception.Create('Internal Error 001');
      end;
      Result.Parent := Parent;
    end;
  end;
  Parent := Result;
  // recalculate depth
  if iLeftDepth > iRightDepth then
  begin
    TreeDepth := iLeftDepth
  end
  else
  begin
    TreeDepth := iRightDepth;
  end;
end;

procedure tSigBTreeNode.CheckTreeDepth;
begin
  // doe nothing
end;

procedure tSigBTreeNode.DrawNode(const Canvas: tCanvas; pCurrLine: tRect);
var
  iText : string;
  iTextWidth, iMargin : integer;
begin
  iText := NodeText;
  iTextWidth := Canvas.TextWidth( iText ) + 2;
  iMargin := (pCurrLine.Right + pCurrLine.Left - iTextWidth) div 2;
  Canvas.TextOut( iMargin, pCurrLine.Top, iText );
end;

procedure tSigBTreeNode.DrawTree(const Canvas: tCanvas;
  const pLineHeight: integer; const pCurrLine: tRect);
var
  iLeftRect, iRightRect : tRect;
  iCentre : integer;
begin
  DrawNode( Canvas, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if assigned( LeftChild ) then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Canvas.MoveTo( iCentre, pCurrLine.Top + Canvas.TextHeight( 'X' ) + 2 );
    Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    LeftChild.DrawTree( Canvas, pLineHeight, iLeftRect );
  end;
  if assigned( RightChild ) then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Canvas.MoveTo( iCentre, pCurrLine.Top + Canvas.TextHeight( 'X' ) + 2 );
    Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    RightChild.DrawTree( Canvas, pLineHeight, iRightRect );
  end;

end;

function tSigBTreeNode.First: tSigBTreeNode;
begin
  if assigned( LeftChild ) then
  begin
    Result := LeftChild.First;
  end
  else
  begin
    Result := self;
  end;
end;

function tSigBTreeNode.GetTreeDepth: integer;
var
  iRightDepth : integer;
begin
  if assigned( LeftChild ) then
  begin
    Result := LeftChild.TreeDepth + 1;
  end
  else
  begin
    Result := 0;
  end;
  if assigned( RightChild ) then
  begin
    iRightDepth := (RightChild.TreeDepth ) + 1;
  end
  else
  begin
    iRightDepth := 0;
  end;
  if iRightDepth > 0 then
  begin
    Result := iRightDepth;
  end;
end;

function tSigBTreeNode.Last: tSigBTreeNode;
begin
  if assigned( RightChild ) then
  begin
    Result := RightChild.Last;
  end
  else
  begin
    Result := self;
  end;
end;

function tSigBTreeNode.LessThan(const SigTreeNode: tSigBTreeNode): boolean;
begin
  Result := NodeText < SigTreeNode.NodeText;
end;

function tSigBTreeNode.Next: tSigBTreeNode;
begin
  if assigned( RightChild ) then
  begin
    Result := RightChild.First;
  end
  else
  begin
    Result := Parent;
  end;
end;

function tSigBTreeNode.Prev: tSigBTreeNode;
begin
  if assigned( LeftChild ) then
  begin
    Result := LeftChild.Last;
  end
  else
  begin
    Result := Parent;
  end;
end;

procedure tSigBTreeNode.SetTreeDepth(const Value: integer);
begin

end;

{ tSigBTreeNodeMemory }

destructor tSigBTreeNodeMemory.Destroy;
begin
  fLeftChild.Free;
  fRightChild.Free;
  inherited;
end;

function tSigBTreeNodeMemory.GetLeftChild: tSigBTreeNode;
begin
  Result := fLeftChild;
end;

function tSigBTreeNodeMemory.GetParent: tSigBTreeNode;
begin
  Result := fParent;
end;

function tSigBTreeNodeMemory.GetRightChild: tSigBTreeNode;
begin
  Result := fRightChild;
end;

procedure tSigBTreeNodeMemory.SetLeftChild(const Value: tSigBTreeNode);
begin
  fLeftChild := Value;
end;

procedure tSigBTreeNodeMemory.SetParent(const Value: tSigBTreeNode);
begin
  fParent := Value;
end;

procedure tSigBTreeNodeMemory.SetRightChild(const Value: tSigBTreeNode);
begin
  fRightChild := Value;
end;

{ tSigBTreeNodeAVL }

procedure tSigBTreeNodeAVL.Add(const SigTreeNode: tSigBTreeNode);
begin
  if self.LessThan( SigTreeNode ) then
  begin
    // must add to right child
    if assigned( RightChild ) then
    begin
      RightChild.Add( SigTreeNode );
      if assigned( LeftChild ) then
      begin
        if LeftChild.TreeDepth < RightChild.TreeDepth - 1 then
        begin
          Balance;
        end;
      end
      else if RightChild.TreeDepth > 0 then
      begin
        Balance;
      end;
    end
    else
    begin
      RightChild := SigTreeNode;
      RightChild.Parent := self;
    end;
  end
  else
  begin
    // must add to left child
    if assigned( LeftChild ) then
    begin
      LeftChild.Add( SigTreeNode );
      if assigned( RightChild ) then
      begin
        if RightChild.TreeDepth < LeftChild.TreeDepth - 1 then
        begin
          Balance;
        end
        else
        begin
          fTreeDepth := LeftChild.TreeDepth + 1;
        end;
      end
      else if LeftChild.TreeDepth > 0 then
      begin
        Balance;
      end;
    end
    else
    begin
      LeftChild := SigTreeNode;
      LeftChild.Parent := self;
    end;
  end;
  CheckTreeDepth;
end;

procedure tSigBTreeNodeAVL.CheckTreeDepth;
var
  iLeftDepth, iRightDepth : integer;
begin
  inherited;
  if assigned( LeftChild ) then
  begin
    iLeftDepth := LeftChild.TreeDepth + 1;
  end
  else
  begin
    iLeftDepth := 0;
  end;
  if assigned( RightChild ) then
  begin
    iRightDepth := RightChild.TreeDepth + 1;
  end
  else
  begin
    iRightDepth := 0;
  end;
  if iLeftDepth > iRightDepth then
  begin
    TreeDepth := iLeftDepth;
  end
  else
  begin
    TreeDepth := iRightDepth;
  end;
end;

function tSigBTreeNodeAVL.GetTreeDepth: integer;
begin
  Result := fTreeDepth;
end;

procedure tSigBTreeNodeAVL.SetTreeDepth(const Value: integer);
begin
  fTreeDepth := Value;
end;

{ tSigDBTreeRoot }

procedure tSigDBTreeRoot.Add(const SigTreeNode: tSigBTreeNode);
begin
  if assigned( LeftChild ) then
  begin
    LeftChild.Add( SigTreeNode );
  end
  else
  begin
    LeftChild := SigTreeNode;
    LeftChild.Parent := self;
  end;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.Repaint;
  end;
end;

constructor tSigDBTreeRoot.Create;
begin
  inherited Create;

  fBkGround := clWhite;
end;

function tSigDBTreeRoot.NodeText: string;
begin
  Result := '';
end;

procedure tSigDBTreeRoot.OnPaint(Sender: tObject);
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
  if assigned( LeftChild ) then
  begin
    iDepth := LeftChild.TreeDepth + 1;
    // interlace the rows by blank rows (for our lines );
    iRowCount := 2 * iDepth + 1;
    iRowHeight := fPaintbox.ClientHeight div iRowCount;
    iRect := fPaintbox.ClientRect;
    LeftChild.DrawTree( fPaintbox.Canvas, iRowHeight, iRect );
  end;
end;

procedure tSigDBTreeRoot.SetPaintBox(const Value: tPaintBox);
begin
  fPaintBox := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnPaint := self.OnPaint;
    fPaintBox.Repaint;
  end;
end;

end.
