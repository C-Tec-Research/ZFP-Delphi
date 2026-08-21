unit SigDBVCLHelper;

{
  DB helpers specifically for VCL.
}

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  VCL.Graphics,
  VCL.Controls,
  SigDBHelper,
  SigDBRawDB,
  SigBTree,
  SigGeneralGrid,
  UnitSigBtreePaintbox;

type

  TSigDBGridMode = ( gm_ShowSel, gm_ShowDataRecNo, gm_ShowIndexRecNo );
  TSigDBGridModes = set of TSigDBGridMode;

  TSigDBFileBaseVCLhelper = class( TSigDBHelper )
  private
    fListGrid: TSigGeneralGrid;
    fSigDBGridModes: TSigDBGridModes;
    procedure SetListGrid(const Value: TSigGeneralGrid);
    procedure SetSigDBGridModes(const Value: TSigDBGridModes);
    function GetFixedColCount: integer;
  protected
  public
    procedure ShowCell( const pX, pY : integer; const pText : string ); virtual;
    procedure ShowRow( const pRec : tSigDBRecPointer; const pRow : integer; const pText : string ); virtual;
    procedure ShowRecs( const pFromRecNo : tSigDBRecPointer );
    property ListGrid : TSigGeneralGrid
             read fListGrid
             write SetListGrid;
    property SigDBGridModes : TSigDBGridModes
             read fSigDBGridModes
             write SetSigDBGridModes;
    property FixedColCount : integer
             read GetFixedColCount;

  end;

{
  TSigDBIndexRootVCLHelper = class( TSigDBHelper )
  private
    fPaintBox: TPaintBox;
    fShowAll: boolean;
    fBkGround: TColor;
    fOnMouseUp : TMouseEvent;
    fOnChange: TNotifyEvent;
    fVisibleRoot: tSigDBIndex;
    fSigDBIndexRoot: TSigDBIndexRoot;
    procedure OnOwnerChange( Sender : TObject );
    procedure SetBkGround(const Value: TColor);
    procedure SetPaintBox(const Value: TPaintBox);
    procedure OnPaint( Sender : TObject );
    procedure OnMouseUp( Sender : TObject; pButton : TMouseButton; pShift : TShiftState; X,Y : integer );
    procedure SetSigDBIndexRoot(const Value: TSigDBIndexRoot);
    procedure SetVisibleRoot(const Value: tSigDBIndex);
  protected
  public
    procedure DrawTree( pFromNode : TSigBTreeNode; const PaintBox : TPaintBox; const pLineHeight : integer; const pCurrLine : tRect; const DrawAll : boolean = TRUE ); virtual;
    procedure DrawNode( pFromNode : TSigBTreeNode; const PaintBox : TPaintbox; pCurrLine : TRect ); virtual;

    property SigDBIndexRoot : TSigDBIndexRoot     //SigBTreeRoot
             read fSigDBIndexRoot
             write SetSigDBIndexRoot;
    property PaintBox : TPaintBox
             read fPaintBox
             write SetPaintBox;
    property BkGround : TColor
             read fBkGround
             write SetBkGround;
    property ShowAll : boolean
             read fShowAll
             write fShowAll;
    property VisibleRoot : tSigDBIndex
             read fVisibleRoot
             write SetVisibleRoot;
  end;
}

  TSigDBIndexFileVCLHelper = class( TSigDBFileBaseVCLhelper )
  private
    fPaintBox: tPaintBox;
    fShowAll: boolean;
    fBkGround: tColor;
    fOnMouseUp : TMouseEvent;
    fVisibleRoot: tSigDBIndex;
    procedure SetBkGround(const Value: tColor);
    procedure SetPaintBox(const Value: tPaintBox);
    procedure SetShowAll(const Value: boolean);
    procedure OnMouseUp( Sender : TObject; pButton : TMouseButton; pShift : TShiftState; X,Y : integer );
    procedure OnPaint( Sender : TObject );
    procedure SetVisibleRoot(const Value: tSigDBIndex);
  protected
  public
    procedure ShowSortedRecs( var pFromRow : integer; var fNext : tSigDBIndex ); virtual;
    procedure DrawTree( pFromNode : TSigBTreeNode; const pLineHeight : integer; const pCurrLine : tRect; const DrawAll : boolean = TRUE ); virtual;
    procedure DrawNode( pFromNode : TSigBTreeNode; pCurrLine : TRect ); virtual;

    property PaintBox : tPaintBox
             read fPaintBox
             write SetPaintBox;
    property BkGround : tColor
             read fBkGround
             write SetBkGround;
    property ShowAll : boolean
             read fShowAll
             write SetShowAll;
    property VisibleRoot : tSigDBIndex
             read fVisibleRoot
             write SetVisibleRoot;
  end;

implementation

{ TSigDBIndexRootVCLHelper }

(*
procedure TSigDBIndexRootVCLHelper.DrawNode(pFromNode: TSigBTreeNode;
  const PaintBox: TPaintbox; pCurrLine: TRect);
var
  iText : string;
begin
  with pFromNode do
  begin
    iText := NodeText;
    Paintbox.AddCell( iText, pCurrLine, self );
  end;
end;

procedure TSigDBIndexRootVCLHelper.DrawTree(pFromNode: TSigBTreeNode;
  const PaintBox: TPaintBox; const pLineHeight: integer; const pCurrLine: tRect;
  const DrawAll: boolean);
  {
    unlike our ancestor we do not draw the entire tree - only the loaded portion
  }
var
  iLeftRect, iRightRect : TRect;
  iCentre : integer;
  iSigDBIndex : TSigDBIndex;
begin
  iSigDBIndex := pFromNode as TSigDBIndex;
  DrawNode( iSigDBIndex, Paintbox, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if assigned( iSigDBIndex.LeftChild ) or (DrawAll and (iSigDBIndex.LeftChildIndex <> 0)) then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    DrawTree( iSigDBIndex.LeftChild, PaintBox, pLineHeight, iLeftRect, DrawAll );
  end
  else if iSigDBIndex.LeftChildIndex <> 0 then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iLeftRect, self, iSigDBIndex.cLeftChild );
  end;
  if assigned( iSigDBIndex.RightChild ) or (DrawAll and (iSigDBIndex.RightChildIndex <> 0)) then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    DrawTree( iSigDBIndex.RightChild, Paintbox, pLineHeight, iRightRect, DrawAll );
  end
  else if iSigDBIndex.RightChildIndex <> 0 then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iRightRect, self, iSigDBIndex.cRightChild );
  end;
end;

procedure TSigDBIndexRootVCLHelper.OnMouseUp(Sender: TObject;
  pButton: TMouseButton; pShift: TShiftState; X, Y: integer);
var
  iCell : TPaintBoxCell;
begin
  if assigned( fOnMouseUp ) then
  begin
    fOnMouseUp( Sender, pButton, pShift, X, Y );
  end;
  if pButton = mbLeft then
  begin
    if pShift = [] then
    begin
      iCell := PaintBox.MouseToCell( X, Y );
      if assigned( iCell ) then
      begin
        case iCell.Tag of
          0:
          begin
            if iCell.Data = fVisibleRoot then
            begin
              fVisibleRoot := nil;
            end
            else
            begin
              fVisibleRoot:= iCell.Data as tSigDBIndex;
            end;
          end;
          1: // left Child
          begin
            (iCell.Data as tSigDBIndex).LeftChild; // load left child! But leave root as is
          end;
          2:
          begin
            (iCell.Data as tSigDBIndex).RightChild; // Load right child
          end;
          else
          begin
            // should not get here!
            fVisibleRoot := nil;
          end;
        end;
        if iCell.Tag = 0 then
        begin
        end
        else if iCell.Tag <> 0 then
        else
        begin
          fVisibleRoot := nil;
        end;
        Paintbox.Repaint;
      end;
    end
    else if pShift = [ ssShift ] then
    begin
      fShowAll := not fShowAll;
      Paintbox.Repaint;
    end;
  end;
end;

procedure TSigDBIndexRootVCLHelper.OnPaint(Sender: TObject);
var
  iDepth, iRowCount : integer;
  iRowHeight : integer;
  iRect : tRect;
  iVisibleRoot : tSigDBIndex;
begin
  // A box filling the whole canvas in the background colour
  fPaintbox.Clear;
  if assigned( fVisibleRoot ) then
  begin
    iVisibleRoot := fVisibleRoot;
  end
  else
  begin
    iVisibleRoot := fVisibleRoot.LeftChild as tSigDBIndex;
  end;
  if assigned( iVisibleRoot ) then
  begin
    iDepth := iVisibleRoot.TreeDepth + 1;
    // interlace the rows by blank rows (for our lines );
    iRowCount := 2 * iDepth + 1;
    iRowHeight := fPaintbox.ClientHeight div iRowCount;
    iRect := fPaintbox.ClientRect;
    DrawTree( iVisibleRoot, fPaintbox, iRowHeight, iRect, ShowAll );
  end;
end;

procedure TSigDBIndexRootVCLHelper.OnOwnerChange(Sender : TObject);
begin
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
  if assigned( fPaintbox ) then
  begin
    fPaintbox.Repaint;
  end;
end;

procedure TSigDBIndexRootVCLHelper.SetBkGround(const Value: TColor);
begin
  fBkGround := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintbox.BkColour := Value;
  end;
end;

procedure TSigDBIndexRootVCLHelper.SetPaintBox(const Value: TPaintBox);
begin
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnMouseUp := fOnMouseUp;
  end;
  fPaintBox := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnPaint := self.OnPaint;
    fOnMouseUp := fPaintBox.OnMouseUp;
    fPaintBox.OnMouseUp := OnMouseUp;
    fPaintBox.BkColour := fBkGround;
    fPaintBox.Repaint;
  end;
end;

procedure TSigDBIndexRootVCLHelper.SetSigDBIndexRoot(
  const Value: TSigDBIndexRoot);
begin
  if assigned( SigDBIndexRoot ) then
  begin
    SigDBIndexRoot.OnChange := self.fOnChange;
  end;
  fSigDBIndexRoot := Value;
  if assigned( SigDBIndexRoot ) then
  begin
    fOnChange := SigDBIndexRoot.OnChange;
    SigDBIndexRoot.OnChange := self.OnOwnerChange;
  end;

end;

procedure TSigDBIndexRootVCLHelper.SetVisibleRoot(const Value: tSigDBIndex);
begin
  fVisibleRoot := Value;
  if assigned( fPaintbox ) then
  begin
    fPaintbox.Repaint;
  end;
end;
*)

{ TSigDBFileBaseVCLhelper }

function TSigDBFileBaseVCLhelper.GetFixedColCount: integer;
begin
  Result := 0;
  if gm_ShowSel in SigDBGridModes then
  begin
    inc( Result );
  end;
  if gm_ShowDataRecNo in SigDBGridModes then
  begin
    inc( Result );
  end;
  if gm_ShowIndexRecNo in SigDBGridModes then
  begin
    inc( Result );
  end;
end;

procedure TSigDBFileBaseVCLhelper.SetListGrid(const Value: TSigGeneralGrid);
var
  i : integer;
begin
  fListGrid := Value;
  if assigned( fListGrid ) then
  begin
    with fListGrid do
    begin
      if assigned( DataFile ) then
      begin
        Visible := TRUE;
        ColCount := FieldCount + 1;   // one for Rec No
        ShowCell( 0, 0, 'Rec No.' );
        for i := 0 to FieldCount - 1 do
        begin
          ShowCell( i + 1, 0, FieldTitle( i ));
        end;
      end
      else
      begin
        Visible := FALSE;
      end;
    end;
  end;
end;

procedure TSigDBFileBaseVCLhelper.SetSigDBGridModes(
  const Value: TSigDBGridModes);
begin
  fSigDBGridModes := Value;
end;

procedure TSigDBFileBaseVCLhelper.ShowCell(const pX, pY: integer;
  const pText: string);
var
  iTextWidth : integer;
begin
  if assigned( fListGrid ) then
  begin
    with fListGrid do
    begin
      iTextWidth := Canvas.TextWidth( pText + 'XX' );
      if iTextWidth > ColWidths[ pX ] then
      begin
        ColWidths[ pX ] := iTextWidth;
      end;
      Cell[ pX, pY ] := pText;
    end;
  end;
end;

procedure TSigDBFileBaseVCLhelper.ShowRecs(const pFromRecNo: tSigDBRecPointer);
var
  iMaxRows : integer;
  iRecsLeft : integer;
  i, j: Integer;
begin
  if assigned( fListGrid ) then
  begin
    iMaxRows := (fListGrid.ClientHeight div fListGrid.DefaultRowHeight) - fListGrid.FixedRows;
    iRecsLeft := SigDBFileBase.RecCount - pFromRecNo;
    if iRecsLeft < iMaxRows then
    begin
      iMaxRows := iRecsLeft;
    end;
    fListGrid.RowCount := iMaxRows + 1;
    for i := 0 to iMaxRows - 1 do
    begin
      SigDBFileBase.Read( i + pFromRecNo );
      if assigned( IndexFile ) then
      begin
        IndexFile.ReadData( IndexFile.DataRec );
      end;
      ShowCell( 0, i + 1, IntToStr( i + pFromRecNo ));
      for j := 0 to DataFile.FieldCount - 1 do
      begin
        ShowCell( j + 1, i + 1, DataFile.FieldAsText( j ));
      end;
    end;
  end;
end;

procedure TSigDBFileBaseVCLhelper.ShowRow(const pRec: tSigDBRecPointer;
  const pRow: integer; const pText: string);
var
  j : integer;
begin
  SigDBFileBase.Lock;
  try
    SigDBFileBase.Read( pRec );
    if assigned( IndexFile ) then
    begin
      IndexFile.ReadData( IndexFile.DataRec );
    end;
    for j := 0 to DataFile.FieldCount - 1 do
    begin
      ShowCell( j + 1, pRow, DataFile.FieldAsText( j ));
    end;
  finally
    SigDBFileBase.Unlock;
  end;
end;

{ TSigDBIndexFileVCLHelper }

procedure TSigDBIndexFileVCLHelper.DrawNode(pFromNode: TSigBTreeNode;
  pCurrLine: TRect);
var
  iText : string;
begin
  with pFromNode do
  begin
    iText := NodeText;
    Paintbox.AddCell( iText, pCurrLine, self );
  end;
end;

procedure TSigDBIndexFileVCLHelper.DrawTree(pFromNode: TSigBTreeNode;
  const pLineHeight: integer; const pCurrLine: tRect; const DrawAll: boolean);
var
  iLeftRect, iRightRect : TRect;
  iCentre : integer;
  iSigDBIndex : TSigDBIndex;
begin
  iSigDBIndex := pFromNode as TSigDBIndex;
  DrawNode( iSigDBIndex, pCurrLine );
  iCentre := (pCurrLine.Right + pCurrLine.Left) div 2;
  if assigned( iSigDBIndex.LeftChild ) or (DrawAll and (iSigDBIndex.LeftChildIndex <> 0)) then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    DrawTree( iSigDBIndex.LeftChild, pLineHeight, iLeftRect, DrawAll );
  end
  else if iSigDBIndex.LeftChildIndex <> 0 then
  begin
    iLeftRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iLeftRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iLeftRect.Left := pCurrLine.Left;
    iLeftRect.Right := iCentre;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iLeftRect.Left + iLeftRect.Right) div 2, iLeftRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iLeftRect, self, iSigDBIndex.cLeftChild );
  end;
  if assigned( iSigDBIndex.RightChild ) or (DrawAll and (iSigDBIndex.RightChildIndex <> 0)) then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    DrawTree( iSigDBIndex.RightChild, pLineHeight, iRightRect, DrawAll );
  end
  else if iSigDBIndex.RightChildIndex <> 0 then
  begin
    iRightRect.Top := pCurrLine.Top + 2 * pLineHeight;
    iRightRect.Bottom := pCurrLine.Bottom + 2 * pLineHeight;
    iRightRect.Left := iCentre;
    iRightRect.Right := pCurrLine.Right;
    Paintbox.Canvas.MoveTo( iCentre, pCurrLine.Top + Paintbox.Canvas.TextHeight( 'X' ) + 2 );
    Paintbox.Canvas.LineTo( (iRightRect.Left + iRightRect.Right) div 2, iRightRect.Top - 2);
    PaintBox.AddCell('<not loaded>', iRightRect, self, iSigDBIndex.cRightChild );
  end;
end;

procedure TSigDBIndexFileVCLHelper.OnMouseUp(Sender: TObject;
  pButton: TMouseButton; pShift: TShiftState; X, Y: integer);
var
  iCell : TPaintBoxCell;
begin
  if assigned( fOnMouseUp ) then
  begin
    fOnMouseUp( Sender, pButton, pShift, X, Y );
  end;
  if pButton = mbLeft then
  begin
    if pShift = [] then
    begin
      iCell := PaintBox.MouseToCell( X, Y );
      if assigned( iCell ) then
      begin
        case iCell.Tag of
          0:
          begin
            if iCell.Data = fVisibleRoot then
            begin
              fVisibleRoot := nil;
            end
            else
            begin
              fVisibleRoot:= iCell.Data as tSigDBIndex;
            end;
          end;
          1: // left Child
          begin
            (iCell.Data as tSigDBIndex).LeftChild; // load left child! But leave root as is
          end;
          2:
          begin
            (iCell.Data as tSigDBIndex).RightChild; // Load right child
          end;
          else
          begin
            // should not get here!
            fVisibleRoot := nil;
          end;
        end;
        if iCell.Tag = 0 then
        begin
        end
        else if iCell.Tag <> 0 then
        else
        begin
          fVisibleRoot := nil;
        end;
        Paintbox.Repaint;
      end;
    end
    else if pShift = [ ssShift ] then
    begin
      fShowAll := not fShowAll;
      Paintbox.Repaint;
    end;
  end;
end;

procedure TSigDBIndexFileVCLHelper.OnPaint(Sender: TObject);
var
  iDepth, iRowCount : integer;
  iRowHeight : integer;
  iRect : tRect;
  iVisibleRoot : tSigDBIndex;
begin
  // A box filling the whole canvas in the background colour
  fPaintbox.Clear;
  if assigned( fVisibleRoot ) then
  begin
    iVisibleRoot := fVisibleRoot;
  end
  else
  begin
    iVisibleRoot := fVisibleRoot.LeftChild as tSigDBIndex;
  end;
  if assigned( iVisibleRoot ) then
  begin
    iDepth := iVisibleRoot.TreeDepth + 1;
    // interlace the rows by blank rows (for our lines );
    iRowCount := 2 * iDepth + 1;
    iRowHeight := fPaintbox.ClientHeight div iRowCount;
    iRect := fPaintbox.ClientRect;
    DrawTree( iVisibleRoot, iRowHeight, iRect, ShowAll );
  end;
end;

procedure TSigDBIndexFileVCLHelper.SetBkGround(const Value: tColor);
begin
  fBkGround := Value;
end;

procedure TSigDBIndexFileVCLHelper.SetPaintBox(const Value: tPaintBox);
begin
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnMouseUp := fOnMouseUp;
  end;
  fPaintBox := Value;
  if assigned( fPaintBox ) then
  begin
    fPaintBox.OnPaint := self.OnPaint;
    fOnMouseUp := fPaintBox.OnMouseUp;
    fPaintBox.OnMouseUp := OnMouseUp;
    fPaintBox.BkColour := fBkGround;
    fPaintBox.Repaint;
  end;
end;

procedure TSigDBIndexFileVCLHelper.SetShowAll(const Value: boolean);
begin
  fShowAll := Value;
end;

procedure TSigDBIndexFileVCLHelper.SetVisibleRoot(const Value: tSigDBIndex);
begin
  fVisibleRoot := Value;
  if assigned( fPaintbox ) then
  begin
    fPaintbox.Repaint;
  end;
end;

procedure TSigDBIndexFileVCLHelper.ShowSortedRecs(var pFromRow: integer; var fNext: tSigDBIndex);
var
  iMaxRows : integer;
  i, j: Integer;
  iRec : tSigDBRecPointer;
begin
  inherited;
  if assigned( fListGrid ) then
  begin
    iMaxRows := (fListGrid.ClientHeight div fListGrid.DefaultRowHeight) - fListGrid.FixedRows;
    fListGrid.RowCount := iMaxRows;
    if not assigned( fNext ) then
    begin
      iRec := IndexFile.First( fNext );
    end
    else
    begin
      iRec := IndexFile.Next( fNext );
    end;

    for i := 1 to iMaxRows - 1 do
    begin
      IndexFile.ReadData( iRec );
      //ReadData( DataRec );
      ShowCell( 0, i, IntToStr( iRec ));
      for j := 0 to FieldCount - 1 do
      begin
        ShowCell( j + 1, i, DataFile.FieldAsText( j ));
      end;
      IndexFile.Next( fNext );
      if assigned(fNext) then
      begin
        iRec := fNext.CurrIndex;
      end
      else
      begin
        fListGrid.RowCount := i + 1;
        break;
      end;
    end;
  end;
end;

end.
