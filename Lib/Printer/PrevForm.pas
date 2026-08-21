unit PrevForm;

{
   Print Preview
   Version 2.0
   by Ben Ziegler

   Updated on:
   - April 11, 1998
   - December 18, 1997

TODO:
   Printing in a thread (Refresh Next buttons as new pages come, etc)
}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Buttons,
  PrevPrinter;

const
   crZoom = 40;
   ZOOMFACTOR = 1.5;

type
  TPreviewForm = class(TForm)
    ToolBarPanel: TPanel;
    GridBut: TSpeedButton;
    ZoomCursorBut: TSpeedButton;
    HandCursorBut: TSpeedButton;
    OnePageBut: TSpeedButton;
    TwoPageBut: TSpeedButton;
    PrintBut: TButton;
    NextPageBut: TButton;
    PrevPageBut: TButton;
    CloseBut: TButton;
    AboutBut: TButton;
    ZoomBox: TComboBox;
    StatBarPanel: TPanel;
    CurPageLabel: TPanel;
    ZoomLabel: TPanel;
    Panel1: TPanel;
    HintLabel: TLabel;
    MoveButPanel: TPanel;
    FirstPageSpeed: TSpeedButton;
    PrevPageSpeed: TSpeedButton;
    NextPageSpeed: TSpeedButton;
    LastPageSpeed: TSpeedButton;
    PageNumSpeed: TSpeedButton;
    ScrollBox1: TScrollBox;
    ContainPanel: TPanel;
    PagePanel: TPanel;
    PB1: TPaintBox;
    PagePanel2: TPanel;
    PB2: TPaintBox;
    PrintDialog1: TPrintDialog;
    FitPageBut: TSpeedButton;
    FitWidthBut: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure CloseButClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure PBPaint(Sender: TObject);
    procedure GridButClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ZoomBoxChange(Sender: TObject);
    procedure TwoPageButClick(Sender: TObject);
    procedure NextPageButClick(Sender: TObject);
    procedure PrevPageButClick(Sender: TObject);
    procedure FirstPageSpeedClick(Sender: TObject);
    procedure LastPageSpeedClick(Sender: TObject);
    procedure ZoomCursorButClick(Sender: TObject);
    procedure HandCursorButClick(Sender: TObject);
    procedure PB1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PB1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PB1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PrintButClick(Sender: TObject);
    procedure PageNumSpeedClick(Sender: TObject);
    procedure OnePageButMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FitPageButClick(Sender: TObject);
    procedure FitWidthButClick(Sender: TObject);
  protected
    FCurPage      : integer;
    OldHint       : TNotifyEvent;
    DownX, DownY  : integer;
    Moving        : boolean;
    procedure     DrawMetaFile(PB: TPaintBox; mf: TMetaFile);
    procedure     OnHint(Sender: TObject);
    procedure     SetCurPage(Val: integer);
    procedure     CheckEnable;
    property      CurPage: integer read FCurPage write SetCurPage;
  public
    Zoom          : double;
    PrevPrinter   : TPreviewPrinter;
  end;

  
implementation

uses Gopage;

{$R *.DFM}
{$R GRID.RES}

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
   ZoomBox.ItemIndex := 0;
   WindowState := wsMaximized;
   Screen.Cursors[crZoom] := LoadCursor(hInstance, 'ZOOM_CURSOR');
   ZoomCursorButClick(nil);
end;

procedure TPreviewForm.CloseButClick(Sender: TObject);
begin
   Close;
end;

procedure TPreviewForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caFree;
   Application.OnHint := OldHint;
end;

procedure TPreviewForm.ScrollBox1Resize(Sender: TObject);
const
   BORD = 20;
var
   z        : double;
   tmp      : integer;
   TotWid   : integer;
begin
   case ZoomBox.ItemIndex of
      0  : FitPageBut.Down := True;
      1  : FitWidthBut.Down := True;
      else begin FitPageBut.Down := False; FitWidthBut.Down := False; end;
   end;

   if ZoomBox.ItemIndex = -1 then
      ZoomBox.ItemIndex := 0;

   case ZoomBox.ItemIndex of
      0: z := ((ScrollBox1.ClientHeight - BORD) / PixelsPerInch) /
         (PrevPrinter.PageHeight / PrevPrinter.PixelsPerInchY);
      1: z := ((ScrollBox1.ClientWidth - BORD) / PixelsPerInch) /
         (PrevPrinter.PageWidth / PrevPrinter.PixelsPerInchX);
      2: z := Zoom;
      3: z := 0.25;
      4: z := 0.50;
      5: z := 0.75;
      6: z := 1.00;
      7: z := 1.25;
      8: z := 1.50;
      9: z := 2.00;
      10: z := 3.00;
      11: z := 4.00;
      else z := 1;
   end;

   if ZoomBox.ItemIndex<>0 then OnePageBut.Down := True;

   PagePanel.Height := TRUNC(PixelsPerInch * z * PrevPrinter.PageHeight / PrevPrinter.PixelsPerInchY);
   PagePanel.Width := TRUNC(PixelsPerInch * z * PrevPrinter.PageWidth / PrevPrinter.PixelsPerInchX);

   PagePanel2.Visible := TwoPageBut.Down;
   if TwoPageBut.Down then begin
      PagePanel2.Width := PagePanel.Width;
      PagePanel2.Height := PagePanel.Height;
   end;

   TotWid := PagePanel.Width + BORD;
   if TwoPageBut.Down then
      TotWid := TotWid + PagePanel2.Width + BORD;
   
   // Resize the Contain Panel
   tmp := PagePanel.Height + BORD;
   if tmp < ScrollBox1.ClientHeight then tmp := ScrollBox1.ClientHeight-1;
   ContainPanel.Height := tmp;

   tmp := TotWid;
   if tmp < ScrollBox1.ClientWidth then tmp := ScrollBox1.ClientWidth-1;
   ContainPanel.Width := tmp;

   // Center the Page Panel
   if PagePanel.Height + BORD < ContainPanel.Height then begin
      PagePanel.Top := ContainPanel.Height div 2 - PagePanel.Height div 2;
   end else begin
      PagePanel.Top := BORD div 2;
   end;
   PagePanel2.Top := PagePanel.Top;

   if TotWid < ContainPanel.Width then begin
      PagePanel.Left := ContainPanel.Width div 2 - (TotWid - BORD) div 2;
   end else begin
      PagePanel.Left := BORD div 2;
   end;
   PagePanel2.Left := PagePanel.Left + PagePanel.Width + BORD;

   // Set the Zoom Variable
   Zoom := z;
   ZoomLabel.Caption := Format('%1.0n', [z * 100]) + '%';
end;

procedure TPreviewForm.DrawMetaFile(PB: TPaintBox; mf: TMetaFile);
begin
   PB.Canvas.Draw(0, 0, mf);
end;

procedure TPreviewForm.PBPaint(Sender: TObject);
var
   PB       : TPaintBox;
   x1, y1   : integer;
   x, y     : integer;
   Draw     : boolean;
   Page     : integer;
begin
   PB := Sender as TPaintBox;

   if PB = PB1 then begin
      Draw := CurPage < PrevPrinter.LastAvailPage;
      Page := CurPage;
   end else begin
      // PB2
      Draw := TwoPageBut.Down and (CurPage+1 < PrevPrinter.LastAvailPage);
      Page := CurPage + 1;
   end;

   SetMapMode(PB.Canvas.Handle, MM_ANISOTROPIC);
   SetWindowExtEx(PB.Canvas.Handle, PrevPrinter.PageWidth, PrevPrinter.PageHeight, nil);
   SetViewportExtEx(PB.Canvas.Handle, PB.Width, PB.Height, nil);
   if Draw then
      DrawMetaFile(PB, PrevPrinter.MetaFiles[Page]);

   if GridBut.Down then begin
      PB.Canvas.Pen.Color := clLtGray;

      for x := 1 to PrevPrinter.PageWidth div PrevPrinter.PixelsPerInchX do begin
         x1 := Round(PrevPrinter.PixelsPerInchX * x);
         PB.Canvas.MoveTo(x1, 0);
         PB.Canvas.LineTo(x1, PrevPrinter.PageHeight);
      end;

      for y := 1 to PrevPrinter.PageHeight div PrevPrinter.PixelsPerInchY do begin
         y1 := Round(PrevPrinter.PixelsPerInchY * y);
         PB.Canvas.MoveTo(0, y1);
         PB.Canvas.LineTo(PrevPrinter.PageWidth, y1);
      end;
   end;
end;

procedure TPreviewForm.GridButClick(Sender: TObject);
begin
   PB1.Invalidate;
   PB2.Invalidate;
end;

procedure TPreviewForm.OnHint(Sender: TObject);
begin
   HintLabel.Caption := Application.Hint;
end;


procedure TPreviewForm.FormShow(Sender: TObject);
begin
   CurPage := 0;
   OldHint := Application.OnHint;
   Application.OnHint := OnHint;
   CheckEnable;
end;

procedure TPreviewForm.SetCurPage(Val: integer);
var
   tmp : integer;
begin
   FCurPage := Val;
   tmp := 0;
   if PrevPrinter<>nil then tmp := PrevPrinter.LastAvailPage;
   CurPageLabel.Caption := Format('Page %d of %d', [Val+1, tmp]);
   PB1.Invalidate;
   PB2.Invalidate;
end;

procedure TPreviewForm.ZoomBoxChange(Sender: TObject);
begin
   ScrollBox1Resize(nil);
   ScrollBox1Resize(nil);
end;

procedure TPreviewForm.TwoPageButClick(Sender: TObject);
begin
   ZoomBox.ItemIndex := 0;
   ScrollBox1Resize(nil);
end;

procedure TPreviewForm.NextPageButClick(Sender: TObject);
begin
   CurPage := CurPage + 1;
   CheckEnable;
end;

procedure TPreviewForm.PrevPageButClick(Sender: TObject);
begin
   CurPage := CurPage - 1;
   CheckEnable;
end;

procedure TPreviewForm.CheckEnable;
begin
   NextPageBut.Enabled := CurPage+1 < PrevPrinter.LastAvailPage;
   PrevPageBut.Enabled := CurPage > 0;

   NextPageSpeed.Enabled := NextPageBut.Enabled;
   PrevPageSpeed.Enabled := PrevPageBut.Enabled;

   FirstPageSpeed.Enabled := PrevPageBut.Enabled;
   LastPageSPeed.Enabled  := NextPageBut.Enabled;

   PageNumSpeed.Enabled := PrevPrinter.LastAvailPage > 1;
end;


procedure TPreviewForm.FirstPageSpeedClick(Sender: TObject);
begin
   CurPage := 0;
   CheckEnable;
end;

procedure TPreviewForm.LastPageSpeedClick(Sender: TObject);
begin
   CurPage := PrevPrinter.LastAvailPage-1;
   CheckEnable;
end;

procedure TPreviewForm.ZoomCursorButClick(Sender: TObject);
begin
   PB1.Cursor := crZoom;
   PB2.Cursor := crZoom;
end;

procedure TPreviewForm.HandCursorButClick(Sender: TObject);
begin
   PB1.Cursor := crHandPoint;
   PB2.Cursor := crHandPoint;
end;

procedure TPreviewForm.PB1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   sx, sy : single;
   nx, ny : integer;
begin
   if ZoomCursorBut.Down then begin
      sx := X / PagePanel.Width;
      sy := Y / PagePanel.Height;

      if ssLeft  in Shift then Zoom := Zoom * ZOOMFACTOR;
      if ssRight in Shift then Zoom := Zoom / ZOOMFACTOR;
      ZoomBox.ItemIndex := 2;
      ScrollBox1Resize(nil);

      nx := TRUNC(sx * PagePanel.Width);
      ny := TRUNC(sy * PagePanel.Height);
      ScrollBox1.HorzScrollBar.Position := nx - ScrollBox1.Width div 2;
      ScrollBox1.VertScrollBar.Position := ny - ScrollBox1.Height div 2;
   end;
   if HandCursorBut.Down then begin
      DownX  := X;
      DownY  := Y;
      Moving := True;
   end;
end;

procedure TPreviewForm.PB1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if moving then begin
      ScrollBox1.HorzScrollBar.Position := ScrollBox1.HorzScrollBar.Position + (DownX - X);
      ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position + (DownY - Y);
   end;
end;

procedure TPreviewForm.PB1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Moving := False;
end;

procedure TPreviewForm.PrintButClick(Sender: TObject);
begin
  PrevPrinter.PrintDialog;
end;

procedure TPreviewForm.PageNumSpeedClick(Sender: TObject);
var
  gp : TGoPageForm;
begin
  gp := TGoPageForm.Create(Self);
  gp.PageNum.MaxValue := PrevPrinter.LastAvailPage;
  gp.PageNum.Value := CurPage + 1;

  if gp.ShowModal = mrOK then
  begin
    CurPage := gp.PageNum.Value - 1;
    CheckEnable;
  end;
  gp.Free;
end;

procedure TPreviewForm.OnePageButMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   ZoomBox.ItemIndex := 0;   
   ScrollBox1Resize(nil);
end;

procedure TPreviewForm.FitPageButClick(Sender: TObject);
begin
   ZoomBox.ItemIndex := 0;
   ZoomBoxChange(nil);
end;

procedure TPreviewForm.FitWidthButClick(Sender: TObject);
begin
   ZoomBox.ItemIndex := 1;
   ZoomBoxChange(nil);
end;

end.
