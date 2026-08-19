unit UnitGlobalDevices;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.Buttons,
  Vcl.ComCtrls,
  SigGeneralGrid,
  PrevPrinter;

type
  TFrameGlobalDevices = class(TFrame)
    Panel1: TPanel;
    SigGridEditorLoop: tSigGridEditor;
    SigGridEditorDevice: tSigGridEditor;
    SigGridEditorDeviceType: tSigGridEditor;
    SigGridEditorDeviceImage: tSigGridEditor;
    SigGridEditorDevName: tSigGridEditor;
    SigGridEditorLoopName: tSigGridEditor;
    PageControlPanelDevices: TPageControl;
    TabSheetDeviceSummary: TTabSheet;
    SigGeneralGridGlobalDevices: TSigGeneralGrid;
    TabSheetZonalSummary: TTabSheet;
    SigGeneralGridZonalSummary: TSigGeneralGrid;
    SigGridEditorZoneName: tSigGridEditor;
    SigGridEditorZoneLoopName: tSigGridEditor;
    SigGridEditorZoneLoop: tSigGridEditor;
    SigGridEditorZoneLoopSubdevices: tSigGridEditor;
    SigGridEditorZoneDevice: tSigGridEditor;
    SigGridEditorZoneDeviceType: tSigGridEditor;
    SigGridEditorZoneDeviceImage: tSigGridEditor;
    SigGridEditorZoneDeviceName: tSigGridEditor;
    SigGridEditorZoneID: TSigGridEditor;
    SigGridEditorDevIG: TSigGridEditor;
    SigGridEditorDevOG: TSigGridEditor;
    SigGridEditorDevZone: TSigGridEditor;
    SigGridEditorDevDisablement: TSigGridEditor;
    SigGridEditorFaultGroup: TSigGridEditor;
    procedure FrameResize(Sender: TObject);
    procedure SigGeneralGridZonalSummaryDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SigGeneralGridGlobalDevicesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    procedure SetImageList(const Value: tImageList);
    function GetMaxDevNameLen: integer;
    procedure SetMaxDevNameLen(const Value: integer);
    { Private declarations }
  public
    { Public declarations }
    property DeviceImageList : tImageList
             write SetImageList;
    property MaxDevNameLen : integer
             read GetMaxDevNameLen
             write SetMaxDevNameLen;
  end;

implementation

uses
  UnitMain;

{$R *.dfm}

procedure TFrameGlobalDevices.FrameResize(Sender: TObject);
begin
  with SigGeneralGridGlobalDevices do
  begin
    RowHeights[ 0 ] := 16;
    RowHeights[ 1 ] := 16;
  end;
  with SigGeneralGridZonalSummary do
  begin
    RowHeights[ 0 ] := 16;
    RowHeights[ 1 ] := 16;
  end;
end;

function TFrameGlobalDevices.GetMaxDevNameLen: integer;
begin
  Result := SigGridEditorDevName.MaxLength;
end;

procedure TFrameGlobalDevices.SetImageList(const Value: tImageList);
begin
  SigGridEditorDeviceImage.Images := Value;
  SigGridEditorZoneDeviceImage.Images := Value;
end;

procedure TFrameGlobalDevices.SetMaxDevNameLen(const Value: integer);
begin
  SigGridEditorDevName.MaxLength := Value;
  SigGridEditorZoneDeviceName.MaxLength := Value;
end;

procedure TFrameGlobalDevices.SigGeneralGridGlobalDevicesDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iSaveColour : TColor;
begin
  if ARow > 1 then
  begin
    with SigGeneralGridGlobalDevices.Canvas do
    begin
      iSaveColour := Pen.Color;
      Pen.Color := clGray;
      MoveTo( Rect.Left, Rect.Top - 2 );
      LineTo( Rect.Right, Rect.Top - 2 );
      Pen.Color := clWhite;
      MoveTo( Rect.Left, Rect.Bottom - 1 );
      LineTo( Rect.Right, Rect.Bottom - 1 );
      Pen.Color := iSaveColour;
    end;
  end;
end;

procedure TFrameGlobalDevices.SigGeneralGridZonalSummaryDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iSaveColour : TColor;
begin
  if (ARow > 1) and (ACol < 8 ) then
  begin
    with SigGeneralGridZonalSummary.Canvas do
    begin
      iSaveColour := Pen.Color;
      Pen.Color := clGray;
      MoveTo( Rect.Left, Rect.Top - 2 );
      LineTo( Rect.Right, Rect.Top - 2 );
      Pen.Color := clWhite;
      MoveTo( Rect.Left, Rect.Bottom - 1 );
      LineTo( Rect.Right, Rect.Bottom - 1 );
      Pen.Color := iSaveColour;
    end;
  end;
end;

end.
