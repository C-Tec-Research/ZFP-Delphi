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
  System.Classes; //,
  //Vcl.ExtCtrls,
  //Vcl.StdCtrls,
  //VCL.Graphics,
  //UnitSigBtreePaintbox;

type

  TSigBTreeNode = class
  private
  protected
    fOnChange: TNotifyEvent;
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
    function Remove( const SigTreeNode : tSigBTreeNode ) : boolean; overload; virtual; // finds the node to remove, if it exists. TRUE if removed, FALSE if not found
    procedure Remove; overload; virtual;
    procedure RemoveAndFree;

    function First : tSigBTreeNode;
    function Next  : tSigBTreeNode;
    function Last  : tSigBTreeNode;
    function Prev  : tSigBTreeNode;
    class function LeftParent( const pOf : tSigBTreeNode ) : tSigBTreeNode;  // see function for details
    class function RightParent( const pOf : tSigBTreeNode ) : tSigBTreeNode; // see function for details

    property TreeDepth : integer
             read GetTreeDepth
             write SetTreeDepth;

    property OnChange : TNotifyEvent
             read fOnChange
             write fOnChange;

    function LeftTreeDepth : integer;
    function RightTreeDepth : integer;

    function Balance : tSigBTreeNode;  // returns new balance root

    function NodeText : string; virtual; abstract;  // returns the text to be displayed visually

    {
    procedure DrawTree( const Canvas : tCanvas; const pLineHeight : integer; const pCurrLine : tRect ); virtual;
    procedure DrawNode( const Canvas : tCanvas; pCurrLine : tRect ); virtual;
    }
    //procedure DrawTree( const PaintBox : tPaintbox; const pLineHeight : integer; const pCurrLine : tRect; const DrawAll : boolean = TRUE ); virtual;
    //procedure DrawNode( const PaintBox : tPaintbox; pCurrLine : tRect ); virtual;

    procedure CheckTreeDepth; virtual;

    function RotateLeft : tSigBTreeNode; // returns new root
    function RotateRight : tSigBTreeNode;

  end;

  tSigBTreeNodeAVL = class( tSigBTreeNode )
  private
  protected
    fTreeDepth : integer;
    function GetTreeDepth: integer; override;
    procedure SetTreeDepth(const Value: integer); override;
  public
    procedure Add( const SigTreeNode : tSigBTreeNode ); override; // returns tree depth

    procedure CheckTreeDepth; override;
  end;

  TSigBTreeNodeMemory = class( tSigBTreeNodeAVL )
  private
  protected
    fParent : tSigBTreeNode;
    fLeftChild : tSigBTreeNode;
    fRightChild : tSigBTreeNode;
    function GetLeftChild: tSigBTreeNode; override;
    function GetParent: tSigBTreeNode; override;
    function GetRightChild: tSigBTreeNode; override;
    procedure SetLeftChild(const Value: tSigBTreeNode);  override;
    procedure SetParent(const Value: tSigBTreeNode);  override;
    procedure SetRightChild(const Value: tSigBTreeNode);  override;
  public
    destructor Destroy; override;
    procedure FreeChildren;
  end;

  TSigDBTreeRoot = class( TSigBTreeNodeMemory )
  private
    //fPaintBox: tPaintBox;
    //fBkGround: tColor;
    //procedure SetPaintBox(const Value: tPaintBox);
    //procedure OnPaint( Sender : tObject );
  protected
  public
    constructor Create; reintroduce;
    procedure Add( const SigTreeNode : tSigBTreeNode ); override; // returns tree depth
    //property PaintBox : tPaintBox
    //         read fPaintBox
    //         write SetPaintBox;
    //property BkGround : TColor
    //         read fBkGround
    //         write fBkGround;

    function NodeText : string; override;  // Root never gets displayed!
    function Remove( const SigTreeNode : tSigBTreeNode ) : boolean; overload; override; // finds the node to remove, if it exists. TRUE if removed, FALSE if not found
    procedure Clear;
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
      //RightChild.GetLeftChild.Parent := self;
      RightChild.Parent := self;
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
  CheckTreeDepth;
  if assigned( fOnChange ) then
  begin
    fOnChange( self );
  end;
end;

function tSigBTreeNode.Balance: tSigBTreeNode;
var
  iLeftDepth, iRightDepth, iDiff : integer;
  iChild : tSigBTreeNode;
begin
  iLeftDepth := LeftTreeDepth;
  iRightDepth := RightTreeDepth;

  iDiff := iRightDepth - iLeftDepth;
  if iDiff > 1 then
  begin
    // Right is too long.
    // If its right leg is shorter (at all ) than its left leg then
    // we need to rotate right first, otherwise our rotate left will not work
    // note that this assumes a correctly balanced tree
    iChild := RightChild;
    if iChild.RightTreeDepth < iChild.LeftTreeDepth then
    begin
      iChild.RotateRight;
    end;

    Result := RotateLeft;
  end
  else if iDiff < -1 then
  begin
    // left is too long.
    // If its left leg is shorter (at all ) than its right leg then
    // we need to rotate left first, otherwise our rotate right will not work
    iChild := LeftChild;
    if iChild.LeftTreeDepth < iChild.RightTreeDepth then
    begin
      iChild.RotateLeft;
    end;
    Result := RotateRight;
  end
  else
  begin
    // nothing to do
    Result := self;
    exit;
  end;

end;

procedure tSigBTreeNode.CheckTreeDepth;
begin
  // does nothing
end;

{
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
}

{
procedure tSigBTreeNode.DrawNode(const Paintbox: tPaintBox; pCurrLine: tRect);
var
  iText : string;
begin
  iText := NodeText;
  Paintbox.AddCell( iText, pCurrLine, self );
end;
}

{
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
}

{
procedure tSigBTreeNode.DrawTree(const Paintbox: tPaintBox;
  const pLineHeight: integer; const pCurrLine: tRect; const DrawAll : boolean);
var
  iLeftRect, iRightRect : tRect;
  iCentre : integer;
begin
  DrawNode( Paintbox, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if assigned( LeftChild ) then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    LeftChild.DrawTree( Paintbox, pLineHeight, iLeftRect, DrawAll );
  end;
  if assigned( RightChild ) then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    RightChild.DrawTree( Paintbox, pLineHeight, iRightRect, DrawAll );
  end;

end;
}

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

class function tSigBTreeNode.LeftParent(
  const pOf: tSigBTreeNode): tSigBTreeNode;
begin
  {
    When traversing a tree to get prev we need to get to a parent where
    our branch is a right fork, i.e. a parent (or us) is the right child
    of its parent.
  }
  Result := pOf.Parent;
  if assigned( Result ) then
  begin
    if Result.RightChild = pOf then
    begin
      // found it
      exit;
    end
    else
    begin
      Result := LeftParent( Result );
    end;
  end;
end;

function tSigBTreeNode.LeftTreeDepth: integer;
begin
  if assigned( LeftChild ) then
  begin
    Result := LeftChild.TreeDepth + 1;
  end
  else
  begin
    Result := 0;
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
    Result := RightParent( self );
    {
    if assigned( Result ) then
    begin
      Result := Result.Next;
    end;
    }
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
    Result := LeftParent( Self );
    {
    if assigned( Result ) then
    begin
      Result := Result.Prev;
    end;
    }
  end;
end;

function tSigBTreeNode.Remove(const SigTreeNode: tSigBTreeNode): boolean;
begin
  if self = SigTreeNode then
  begin
    Result := TRUE;
    RemoveAndFree;
  end
  else if LessThan( SigTreeNode ) then
  begin
    if assigned( RightChild ) then
    begin
      Result := RightChild.Remove( SigTreeNode );
      CheckTreeDepth;
      Balance;
    end
    else
    begin
      // else not found
      Result := FALSE;
    end;
  end
  else
  begin
    if assigned( LeftChild ) then
    begin
      Result := LeftChild.Remove( SigTreeNode );
      CheckTreeDepth;
      Balance;
    end
    else
    begin
      // else not found
      Result := FALSE;
    end;
  end;
end;

procedure tSigBTreeNode.Remove;
var
  iLeaf, iLeafParent, iTemp, iTempParent : tSigBTreeNode;
begin
  // There are 3 cases to consider.
  if assigned( LeftChild ) then
  begin
    if assigned( RightChild ) then
    begin
      // the most complex case. We find a leaf that can replace us from
      // the longer branch if any. This can never unbalance the tree
      if LeftTreeDepth < RightTreeDepth then
      begin
        // we find the smallest value on the right tree
        iLeaf := RightChild.First;
      end
      else
      begin
        // we find the largest value on the left
        iLeaf := LeftChild.Last;
      end;
      // save the parent in case it needs balancing
      iLeafParent := iLeaf.Parent;
      // swap places with the leaf, then reattempt the removal.
      iTempParent := Parent;
      Parent := iLeafParent;
      iLeaf.Parent := iTempParent;
      if iTempParent.LeftChild = self then
      begin
        iTempParent.LeftChild := iLeaf;
      end
      else if iTempParent.RightChild = self then
      begin
        iTempParent.RightChild := iLeaf;
      end
      else
      begin
        raise Exception.Create('Internal error 001 - disowned by parent');
      end;
      if iLeafParent.LeftChild = iLeaf then
      begin
        iLeafParent.LeftChild := self;
      end
      else if iLeafParent.RightChild = iLeaf then
      begin
        iLeafParent.RightChild := self;
      end
      else
      begin
        raise Exception.Create('Internal error 001 - disowned by parent');
      end;
      iTemp := iLeaf.LeftChild;
      iLeaf.LeftChild := LeftChild;
      LeftChild := iTemp;
      iLeaf.LeftChild.Parent := iLeaf;  // this must exist
      if assigned( LeftChild ) then
      begin
        LeftChild.Parent := self;
      end;
      iTemp := iLeaf.RightChild;
      iLeaf.RightChild := RightChild;
      RightChild := iTemp;
      iLeaf.RightChild.Parent := iLeaf; // this must exist
      if assigned( RightChild ) then
      begin
        RightChild.Parent := self;
      end;
      // tree is not now valid, but the next step, an iterative delete, does not need the tree to be valid
      // because either our left child or right child is nil so no further search is made
      Remove;
      // we now need to reckeck iLeaf tree depth
      iLeaf.CheckTreeDepth;
    end
    else
    begin
      // we simply need to replace ourslves by our left child
      if assigned( Parent ) then
      begin
        if Parent.LeftChild = self then
        begin
          Parent.LeftChild := LeftChild;
        end
        else if Parent.RightChild = self then
        begin
          Parent.RightChild := LeftChild;
        end
        else
        begin
          raise Exception.Create('Internal error 001 - disowned by parent');
        end;
        LeftChild.Parent := Parent;
        Parent.CheckTreeDepth;
        // nil our pointers
        Parent := nil;
        LeftChild := nil;
      end
      else
      begin
        raise Exception.Create('Internal error 002 - orphan found');
      end;
    end;
  end
  else if assigned( RightChild ) then
  begin
    // we simply need to replace ourslves by our right child
    if assigned( Parent ) then
    begin
      if Parent.LeftChild = self then
      begin
        Parent.LeftChild := RightChild;
      end
      else if Parent.RightChild = self then
      begin
        Parent.RightChild := RightChild;
      end
      else
      begin
        raise Exception.Create('Internal error 001 - disowned by parent');
      end;
      RightChild.Parent := Parent;
      Parent.CheckTreeDepth;
      // nil our pointers
      Parent := nil;
      RightChild := nil;
    end
    else
    begin
      raise Exception.Create('Internal error 002 - orphan found');
    end;
  end
  else
  begin
    // else just delete!
    if Parent.LeftChild = self then
    begin
      Parent.LeftChild := nil;
    end
    else if Parent.RightChild = self then
    begin
      Parent.RightChild := nil;
    end
    else
    begin
      raise Exception.Create('Internal error 001 - disowned by parent');
    end;
    Parent := nil;
  end;
end;

procedure tSigBTreeNode.RemoveAndFree;
begin
  Remove;
  Free;
end;

class function tSigBTreeNode.RightParent(
  const pOf: tSigBTreeNode): tSigBTreeNode;
begin
  {
    When traversing a tree to get next we need to get to a parent where
    our branch is a left fork, i.e. a parent (or us) is the left child
    of its parent.
  }
  Result := pOf.Parent;
  if assigned( Result ) then
  begin
    if Result.LeftChild = pOf then
    begin
      // found it
      exit;
    end
    else
    begin
      Result := RightParent( Result );
    end;
  end;
end;

function tSigBTreeNode.RightTreeDepth: integer;
begin
  if assigned( RightChild ) then
  begin
    Result := RightChild.TreeDepth + 1;
  end
  else
  begin
    Result := 0;
  end;
end;

function tSigBTreeNode.RotateLeft : tSigBTreeNode;
begin
  // we can only rotate left if our rightchild exists!
  if assigned( RightChild ) then
  begin
    Result := RightChild;
    // Its left child becomes our right child
    RightChild := Result.LeftChild;
    if assigned( RightChild ) then
    begin
      RightChild.Parent := self;
    end;
    // We become its left child
    Result.LeftChild := self;
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
      end;
    end;
    Result.Parent := Parent;
    Parent := Result;
    CheckTreeDepth;
    Result.CheckTreeDepth;        // only really required if our tree depth does not change
    if assigned( Result.Parent ) then
    begin
      Result.Parent.CheckTreeDepth; // only really required when our new parent's tree depth does not change
    end;
  end
  else
  begin
    // no rotation possible!
    Result := self;
  end;
end;

function tSigBTreeNode.RotateRight : tSigBTreeNode;
begin
  // we can only rotate right if our leftchild exists!
  if assigned( LeftChild ) then
  begin
    Result := LeftChild;
    // Its right child becomes our left child
    LeftChild := Result.RightChild;
    if assigned( LeftChild ) then
    begin
      LeftChild.Parent := self;
    end;
    // We become its right child
    Result.RightChild := self;
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
      end;
    end;
    Result.Parent := Parent;
    Parent := Result;
    CheckTreeDepth;
    Result.CheckTreeDepth;        // only really required if our tree depth does not change
    if assigned( Result.Parent ) then
    begin
      Result.Parent.CheckTreeDepth; // only really required when our new parent's tree depth does not change
    end;
  end
  else
  begin
    // no rotation possible!
    Result := self;
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

procedure tSigBTreeNodeMemory.FreeChildren;
begin
  FreeAndNil( fLeftChild );
  FreeAndNil( fRightChild );
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

{
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
}

procedure tSigBTreeNodeAVL.Add(const SigTreeNode: tSigBTreeNode);
var
  iChild : tSigBTreeNode;
begin
  // simplified version
  if self.LessThan( SigTreeNode ) then
  begin
    // must add to right child
    iChild := RightChild;
    if assigned( iChild ) then
    begin
      iChild.Add( SigTreeNode );
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
    iChild := LeftChild;
    if assigned( iChild ) then
    begin
      iChild.Add( SigTreeNode );
    end
    else
    begin
      LeftChild := SigTreeNode;
      LeftChild.Parent := self;
    end;
  end;
  CheckTreeDepth;
  Balance;
end;

procedure tSigBTreeNodeAVL.CheckTreeDepth;
var
  iRightDepth, iDepth : integer;
  iLeftChild, iRightChild : tSigBTreeNode;
begin
  inherited;
  iLeftChild := LeftChild;
  iRightChild := RightChild;
  if assigned( iLeftChild ) then
  begin
    iDepth := iLeftChild.TreeDepth + 1;
  end
  else
  begin
    iDepth := 0;
  end;
  if assigned( iRightChild ) then
  begin
    iRightDepth := iRightChild.TreeDepth + 1;
  end
  else
  begin
    iRightDepth := 0;
  end;
  if iDepth < iRightDepth then
  begin
    iDepth := iRightDepth;
  end;
  if TreeDepth <> iDepth then
  begin
    TreeDepth := iDepth;
    if assigned( Parent ) then
    begin
      Parent.CheckTreeDepth;
    end;
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
end;

procedure TSigDBTreeRoot.Clear;
begin
  FreeAndNil( fLeftChild );
end;

constructor tSigDBTreeRoot.Create;
begin
  inherited Create;

  //fBkGround := clWhite;
end;

function tSigDBTreeRoot.NodeText: string;
begin
  Result := '';
end;

{
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
    //LeftChild.DrawTree( fPaintbox.Canvas, iRowHeight, iRect );
    LeftChild.DrawTree( fPaintbox, iRowHeight, iRect );
  end;
end;
}

function tSigDBTreeRoot.Remove(const SigTreeNode: tSigBTreeNode): boolean;
begin
  if assigned( LeftChild ) then
  begin
    Result := LeftChild.Remove( SigTreeNode );
  end
  else
  begin
    Result := FALSE;
  end;
end;

{
procedure tSigDBTreeRoot.SetPaintBox(const Value: tPaintBox);
begin
  fPaintBox := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnPaint := self.OnPaint;
    fPaintBox.Repaint;
  end;
end;
}

end.
