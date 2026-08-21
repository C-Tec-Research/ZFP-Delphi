unit UnitObjectEditorHelper;

interface

uses
  //SigNETStringGrid,
  UnitPCCfgFile,
  VCL.Buttons,
  VCL.Controls,
  VCL.ExtCtrls,
  VCL.Grids,
  VCL.Graphics,
  Contnrs,
  WinAPI.Windows,
  SigNET.TStringGrid,
  System.UITypes,
  System.SysUtils,
  System.Classes;

type
  tIncludeSelectionIn = procedure( pObjects : tObjectList ) of object;

type
  TObjectEditorHelper = class
  private
    fSigNETStringGridObjects: TSigNETStringGrid;
    fImageListObjectsSelected: tImageList;
    fOnIncludeSelectionIn: tIncludeSelectionIn;
    fSelectedCount: integer;
    procedure SetSigNETStringGridObjects(const Value: TSigNETStringGrid);
    procedure SetImageListObjectsSelected(const Value: tImageList);
    function Translate( const pVal : string ) : string;
    function GetSelected(const iRow: integer): boolean;
    procedure SetSelected(const iRow: integer; const Value: boolean);
    procedure SetSelectedCount(const Value: integer);
  private
    fActiveChild: integer;
    fImageListObjects: tImageList;
    // Event handlers
    procedure SigNETStringGridObjectsDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SigNETStringGridObjectsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetImageListObjects(const Value: tImageList);
  public
    property SigNETStringGridObjects : TSigNETStringGrid
             read fSigNETStringGridObjects
             write SetSigNETStringGridObjects;
    property ImageListObjectsSelected : tImageList
             read fImageListObjectsSelected
             write SetImageListObjectsSelected;

    property ImageListObjects : tImageList
             read fImageListObjects
             write SetImageListObjects;

    property OnIncludeSelectionIn : tIncludeSelectionIn
             read fOnIncludeSelectionIn
             write fOnIncludeSelectionIn;

    property Selected[ const iRow : integer ] : boolean
             read GetSelected
             write SetSelected;
    property SelectedCount : integer
             read fSelectedCount
             write SetSelectedCount;

    procedure ClearObjects;
    procedure AddObject( const pImageIndex : integer; const pName : string;
              const pID : integer; const pObject : TObject);
    procedure SelectObject( pObject : tObject );

    procedure SetupGrid;

    procedure ClearSelections;
    procedure ClearAllSelections;

    property ActiveChild : integer
             read fActiveChild
             write fActiveChild;

    const
      cColSel = 0;
      cColImage = cColSel + 1;
      cColDeviceName = cColImage + 1;
      cColID = cColDeviceName + 1;
      cColCount = cColID + 1;
  end;

implementation

{ tObjectEditorHelper }

procedure tObjectEditorHelper.AddObject( const pImageIndex : integer; const pName : string;
              const pID : integer; const pObject : TObject);
var
  iRow : integer;
begin
  with SigNETStringGridObjects do
  begin
    iRow := RowCount;
    Objects[ cColSel, iRow ] := pObject;
    Cells[ cColImage, iRow ] := IntToStr( pImageIndex );
    Cells[ cColDeviceName, iRow ] := pName;
    Cells[ cColID, iRow ] := IntToStr( pID );
    RowCount := RowCount + 1; // forces a redisplay!
    Invalidate;
  end;
end;

procedure tObjectEditorHelper.ClearAllSelections;
var
  i: Integer;
begin
  for i := 1 to SigNETStringGridObjects.RowCount - 1 do
  begin
    Selected[ i ] := FALSE;
  end;
end;

procedure tObjectEditorHelper.ClearObjects;
begin
  ClearAllSelections;
  with SigNETStringGridObjects do
  begin
    RowCount := 1;
  end;
end;

procedure tObjectEditorHelper.ClearSelections;
begin
  ClearAllSelections;
  Selected[ ActiveChild + 1 ] := TRUE;
end;

function tObjectEditorHelper.GetSelected(const iRow: integer): boolean;
begin
  if (iRow > 0) and (iRow < SigNETStringGridObjects.RowCount ) then
  begin
    Result := SigNETStringGridObjects.Cells[ 0, iRow ] = 'X';
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure tObjectEditorHelper.SelectObject(pObject: tObject);
var
  i: Integer;
begin
  ClearAllSelections;
  with SigNETStringGridObjects do
  begin
    for i := 1 to RowCount - 1 do
    begin
      if Objects[ cColSel, i ] = pObject then
      begin
        Selected[ i ] := TRUE;
        ActiveChild := i - 1;
        exit;
      end;
    end;
  end;

end;

procedure TObjectEditorHelper.SetImageListObjects(const Value: tImageList);
begin
  fImageListObjects := Value;
end;

procedure tObjectEditorHelper.SetImageListObjectsSelected(
  const Value: tImageList);
begin
  fImageListObjectsSelected := Value;
end;

procedure tObjectEditorHelper.SetSelected(const iRow: integer;
  const Value: boolean);
begin
  if (iRow > 0) and (iRow < SigNETStringGridObjects.RowCount ) then
  begin
    if Selected[ iRow ] <> Value then
    begin
      if Value then
      begin
        SigNETStringGridObjects.Cells[ 0, iRow ] := 'X';
        SelectedCount := SelectedCount + 1;
      end
      else
      begin
        SigNETStringGridObjects.Cells[ 0, iRow ] := '';
        SelectedCount := SelectedCount - 1;
      end;
    end;
  end;
end;

procedure tObjectEditorHelper.SetSelectedCount(const Value: integer);
begin
  fSelectedCount := Value;
end;

procedure tObjectEditorHelper.SetSigNETStringGridObjects(
  const Value: TSigNETStringGrid);
begin
  fSigNETStringGridObjects := Value;
  SigNETStringGridObjects.OnDrawCell := SigNETStringGridObjectsDrawCell;
  SigNETStringGridObjects.OnMouseDown := SigNETStringGridObjectsMouseDown;
  SetupGrid;
end;

procedure tObjectEditorHelper.SetupGrid;
var
  iWidthLeft : integer;
begin
  with SigNETStringGridObjects do
  begin
    ColCount := cColCount;
    iWidthLeft := ClientWidth - ColCount * GridLineWidth - GetSystemMetrics( SM_CXVSCROLL );
    RowHeights[ 0 ] := 16;
    ColWidths[ cColSel ] := 34;
    Cells[ cColSel, 0 ] := ' ';
    dec( iWidthLeft, ColWidths[ cColSel ] );
    ColWidths[ cColImage ] := 34;
    Cells[ cColImage, 0 ] := Translate( 'Type' );
    dec( iWidthLeft, ColWidths[ cColImage ] );
    ColWidths[ cColID ] := 32;
    Cells[ cColID, 0 ] := Translate( 'Addr' );
    dec( iWidthLeft, ColWidths[ cColID ] );
    if iWidthLeft < 128 then
    begin
      iWidthLeft := 128;
    end;
    Cells[ cColDeviceName, 0 ] := Translate( 'Name' );
    ColWidths[ cColDeviceName ] := iWidthLeft;
  end;
end;

procedure tObjectEditorHelper.SigNETStringGridObjectsDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iImageIndex : integer;
  iSaveColour, iSavePenColour : tColor;
begin
  if ARow > 0 then
  begin
    if ACol = cColImage then
    begin
      with SigNETStringGridObjects do
      begin
        iImageIndex := StrToIntDef( Cells[ ACol, ARow ], -1 );
        if iImageIndex = -1 then
        begin
          iSaveColour := Canvas.Brush.Color;
          iSavePenColour := Canvas.Pen.Color;
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Color := clWhite;
          Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right+1, Rect.Bottom+1 );
          Canvas.Brush.Color := iSaveColour;
          Canvas.Pen.Color := iSavePenColour;
        end
        else
        begin
          if iImageIndex < ImageListObjects.Count then
          begin
            ImageListObjects.Draw( Canvas, Rect.Left - 1, Rect.Top, iImageIndex );
          end
          else
          begin
            iSaveColour := Canvas.Brush.Color;
            Canvas.Brush.Color := clSilver;
            Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right, Rect.Bottom );
            Canvas.Brush.Color := iSaveColour;
          end;
        end;
      end;
    end
    else if ACol = cColSel then
    begin
      with SigNETStringGridObjects do
      begin
        if Cells[ ACol, ARow ] = '' then
        begin
          ImageListObjectsSelected.Draw( Canvas, Rect.Left - 1, Rect.Top, 0);
        end
        else
        begin
          ImageListObjectsSelected.Draw( Canvas, Rect.Left - 1, Rect.Top, 1);
        end;
      end;
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure tObjectEditorHelper.SigNETStringGridObjectsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, iCol, iRow : integer;
begin
  if assigned( SigNETStringGridObjects ) then
  begin
    SigNETStringGridObjects.MouseToCell( X, Y, iCol, iRow );
    //if iCol = cColSel then
    if iCol = cColSel then
    begin
      if (iRow > 0) and (iRow < SigNETStringGridObjects.RowCount ) then
      begin
        // in the target area!
        if Shift = [ ssLeft ] then
        begin
          // Just select
          ActiveChild := iRow - 1;
          ClearSelections;
        end
        else if Shift = [ ssShift, ssLeft ] then
        begin
          // Clear all selections then select from Active Child to here
          ClearAllSelections;
          if iRow <= ActiveChild then
          begin
            for i := ActiveChild + 1 downto iRow do
            begin
              Selected[ i ] := TRUE;
            end;
          end
          else
          begin
            for i := ActiveChild + 1 to iRow do
            begin
              Selected[ i ] := TRUE;
            end;
          end;
          ActiveChild := iRow - 1;
        end
        else if Shift = [ ssCtrl, ssLeft ] then
        begin
          // This toggles current selection. If selection being removed, try
          // to find next. If not found, try to find previous. if not found
          // it must be last selection removed, so leave active child as is
          Selected[ iRow ] := not Selected[ iRow ];
          ActiveChild := iRow - 1;
        end

      end;
    end;
  end;
end;

function tObjectEditorHelper.Translate(const pVal: string): string;
begin
  if assigned( XFP4PgmCfg ) then
  begin
    Result := XFP4PgmCfg.Translate( pVal );
  end
  else
  begin
    Result := pVal;
  end;
end;

end.

