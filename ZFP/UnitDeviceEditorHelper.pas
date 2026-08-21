unit UnitDeviceEditorHelper;

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
  //SigNET.TStringGrid,
  System.UITypes,
  System.SysUtils,
  System.Classes;

type
  TSigNETStringGrid = TStringGrid;

type
  tIncludeSelectionIn = procedure( pObjects : tObjectList ) of object;

type
  tDeviceEditorHelper = class
  private
    fSpeedButtonIncludeSelectionIn: tSpeedButton;
    fSigNETStringGridDevices: TSigNETStringGrid;
    fImageListDevicesSelected: tImageList;
    fPanelDeviceOptions: tPanel;
    fOnIncludeSelectionIn: tIncludeSelectionIn;
    fSelectedCount: integer;
    procedure SetSpeedButtonIncludeSelectionIn(const Value: tSpeedButton);
    procedure SetSigNETStringGridDevices(const Value: TSigNETStringGrid);
    procedure SetImageListDevicesSelected(const Value: tImageList);
    procedure SetPanelDeviceOptions(const Value: tPanel);
    function Translate( const pVal : string ) : string;
    function GetSelected(const iRow: integer): boolean;
    procedure SetSelected(const iRow: integer; const Value: boolean);
    procedure SetSelectedCount(const Value: integer);
  private
    fActiveChild: integer;
    // Event handlers
    procedure SpeedButtonIncludeSelectionInClick(Sender: TObject);
    procedure SigNETStringGridDevicesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SigNETStringGridDevicesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    property PanelDeviceOptions : tPanel
             read fPanelDeviceOptions
             write SetPanelDeviceOptions;
    property SpeedButtonIncludeSelectionIn : tSpeedButton
             read fSpeedButtonIncludeSelectionIn
             write SetSpeedButtonIncludeSelectionIn;
    property SigNETStringGridDevices : TSigNETStringGrid
             read fSigNETStringGridDevices
             write SetSigNETStringGridDevices;
    property ImageListDevicesSelected : tImageList
             read fImageListDevicesSelected
             write SetImageListDevicesSelected;

    property OnIncludeSelectionIn : tIncludeSelectionIn
             read fOnIncludeSelectionIn
             write fOnIncludeSelectionIn;

    property Selected[ const iRow : integer ] : boolean
             read GetSelected
             write SetSelected;
    property SelectedCount : integer
             read fSelectedCount
             write SetSelectedCount;

    procedure ClearDevices;
    procedure AddDevice( const pPanel, pLoop, pPos, pSubDevice, pImageIndex : integer; const pName : string;
              pDevice : tObject );
    procedure SelectSubdevice( pSubdevice : tObject );

    procedure SetupGrid;

    procedure ClearSelections;
    procedure ClearAllSelections;

    property ActiveChild : integer
             read fActiveChild
             write fActiveChild;

    const
      cColSel = 0;
      cColPanel = cColSel + 1;
      cColLoop = cColPanel + 1;
      cColPosition = cColLoop + 1;
      cColSubDevice = cColPosition + 1;
      cColDeviceType = cColSubDevice + 1;
      cColDeviceName = cColDeviceType + 1;
      cColCount = cColDeviceName + 1;
  end;

implementation

{ tDeviceEditorHelper }

procedure tDeviceEditorHelper.AddDevice(const pPanel, pLoop, pPos, pSubDevice,
  pImageIndex: integer; const pName: string; pDevice: tObject);
var
  iRow : integer;
begin
  with SigNETStringGridDevices do
  begin
    iRow := RowCount;
    Objects[ cColSel, iRow ] := pDevice;
    Cells[ cColPanel, iRow ] := IntToStr( pPanel );
    Cells[ cColLoop, iRow ] := IntToStr( pLoop );
    Cells[ cColPosition, iRow ] := IntToStr( pPos );
    Cells[ cColSubDevice, iRow ] := IntToStr( pSubDevice );
    Cells[ cColDeviceType, iRow ] := IntToStr( pImageIndex );
    Cells[ cColDeviceName, iRow ] := pName;
    RowCount := RowCount + 1; // forces a redisplay!
    Invalidate;
  end;
end;

procedure tDeviceEditorHelper.ClearAllSelections;
var
  i: Integer;
begin
  for i := 1 to SigNETStringGridDevices.RowCount - 1 do
  begin
    Selected[ i ] := FALSE;
  end;
end;

procedure tDeviceEditorHelper.ClearDevices;
begin
  ClearAllSelections;
  with SigNETStringGridDevices do
  begin
    RowCount := 1;
  end;
  SpeedButtonIncludeSelectionIn.Enabled := FALSE;
end;

procedure tDeviceEditorHelper.ClearSelections;
begin
  ClearAllSelections;
  Selected[ ActiveChild + 1 ] := TRUE;
end;

function tDeviceEditorHelper.GetSelected(const iRow: integer): boolean;
begin
  if (iRow > 0) and (iRow < SigNETStringGridDevices.RowCount ) then
  begin
    Result := SigNETStringGridDevices.Cells[ 0, iRow ] = 'X';
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure tDeviceEditorHelper.SelectSubdevice(pSubdevice: tObject);
var
  i: Integer;
begin
  ClearAllSelections;
  with SigNETStringGridDevices do
  begin
    for i := 1 to RowCount - 1 do
    begin
      if Objects[ cColSel, i ] = pSubdevice then
      begin
        Selected[ i ] := TRUE;
        ActiveChild := i - 1;
        exit;
      end;
    end;
  end;

end;

procedure tDeviceEditorHelper.SetImageListDevicesSelected(
  const Value: tImageList);
begin
  fImageListDevicesSelected := Value;
end;

procedure tDeviceEditorHelper.SetPanelDeviceOptions(const Value: tPanel);
begin
  fPanelDeviceOptions := Value;
end;

procedure tDeviceEditorHelper.SetSelected(const iRow: integer;
  const Value: boolean);
begin
  if (iRow > 0) and (iRow < SigNETStringGridDevices.RowCount ) then
  begin
    if Selected[ iRow ] <> Value then
    begin
      if Value then
      begin
        SigNETStringGridDevices.Cells[ 0, iRow ] := 'X';
        SelectedCount := SelectedCount + 1;
      end
      else
      begin
        SigNETStringGridDevices.Cells[ 0, iRow ] := '';
        SelectedCount := SelectedCount - 1;
      end;
    end;
  end;
end;

procedure tDeviceEditorHelper.SetSelectedCount(const Value: integer);
begin
  fSelectedCount := Value;
  SpeedButtonIncludeSelectionIn.Enabled := fSelectedCount <> 0;
end;

procedure tDeviceEditorHelper.SetSigNETStringGridDevices(
  const Value: TSigNETStringGrid);
begin
  fSigNETStringGridDevices := Value;
  if assigned( fSigNETStringGridDevices ) then
  begin
    fSigNETStringGridDevices.OnDrawCell := SigNETStringGridDevicesDrawCell;
    fSigNETStringGridDevices.OnMouseDown := SigNETStringGridDevicesMouseDown;
    SetupGrid;
  end;
end;

procedure tDeviceEditorHelper.SetSpeedButtonIncludeSelectionIn(
  const Value: tSpeedButton);
begin
  fSpeedButtonIncludeSelectionIn := Value;
  fSpeedButtonIncludeSelectionIn.OnClick := SpeedButtonIncludeSelectionInClick;
end;

procedure tDeviceEditorHelper.SetupGrid;
var
  iWidthLeft : integer;
begin
  with SigNETStringGridDevices do
  begin
    ColCount := cColCount;
    iWidthLeft := ClientWidth - ColCount * GridLineWidth - GetSystemMetrics( SM_CXVSCROLL );
    RowHeights[ 0 ] := 16;
    ColWidths[ cColSel ] := 34;
    Cells[ cColSel, 0 ] := ' ';
    ColWidths[ cColPanel ] := 32;
    Cells[ cColPanel, 0 ] := Translate( 'Panel' );
    dec( iWidthLeft, ColWidths[ cColPanel ] );
    ColWidths[ cColLoop ] := 32;
    Cells[ cColLoop, 0 ] := Translate( 'Loop' );
    dec( iWidthLeft, ColWidths[ cColLoop ] );
    ColWidths[ cColPosition ] := 32;
    Cells[ cColPosition, 0 ] := Translate( 'Addr' );
    dec( iWidthLeft, ColWidths[ cColPosition ] );
    ColWidths[ cColSubDevice ] := 32;
    Cells[ cColSubDevice, 0 ] := Translate( 'Sub' );
    dec( iWidthLeft, ColWidths[ cColSubDevice ] );
    ColWidths[ cColDeviceType ] := 34;
    Cells[ cColDeviceType, 0 ] := Translate( 'Type' );
    dec( iWidthLeft, ColWidths[ cColDeviceType ] );
    if iWidthLeft < 128 then
    begin
      iWidthLeft := 128;
    end;
    Cells[ cColDeviceName, 0 ] := Translate( 'Name' );
    ColWidths[ cColDeviceName ] := iWidthLeft;
  end;
  if assigned( PanelDeviceOptions ) then
  begin
    SpeedButtonIncludeSelectionIn.Left := (PanelDeviceOptions.ClientWidth - SpeedButtonIncludeSelectionIn.Width ) div 2;
  end;
end;

procedure tDeviceEditorHelper.SigNETStringGridDevicesDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iImageIndex : integer;
  iSaveColour, iSavePenColour : tColor;
begin
  if ARow > 0 then
  begin
    if ACol = cColDeviceType then
    begin
      with SigNETStringGridDevices do
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
          if iImageIndex < XFP4PgmCfg.ImageListComponentPalette.Count then
          begin
            XFP4PgmCfg.ImageListComponentPalette.Draw( Canvas, Rect.Left - 1, Rect.Top, iImageIndex );
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
      with SigNETStringGridDevices do
      begin
        if Cells[ ACol, ARow ] = '' then
        begin
          ImageListDevicesSelected.Draw( Canvas, Rect.Left - 1, Rect.Top, 0);
        end
        else
        begin
          ImageListDevicesSelected.Draw( Canvas, Rect.Left - 1, Rect.Top, 1);
        end;
      end;
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure tDeviceEditorHelper.SigNETStringGridDevicesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, iCol, iRow : integer;
begin
  if assigned( SigNETStringGridDevices ) then
  begin
    SigNETStringGridDevices.MouseToCell( X, Y, iCol, iRow );
    //if iCol = cColSel then
    if iCol = cColSel then
    begin
      if (iRow > 0) and (iRow < SigNETStringGridDevices.RowCount ) then
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

procedure tDeviceEditorHelper.SpeedButtonIncludeSelectionInClick(
  Sender: TObject);
var
  iSelectedObjectList : tObjectList;
  i : integer;
begin
  if assigned( fOnIncludeSelectionIn ) then
  begin
    iSelectedObjectList := tObjectList.Create( FALSE );
    try
      for i := 1 to SigNETStringGridDevices.RowCount - 1 do
      begin
        if Selected[ i ] then
        begin
          iSelectedObjectList.Add( SigNETStringGridDevices.Objects[ 0, i ] );
        end;
      end;
      fOnIncludeSelectionIn( iSelectedObjectList );
    finally
      iSelectedObjectList.Free;
    end;
  end;
end;

function tDeviceEditorHelper.Translate(const pVal: string): string;
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
