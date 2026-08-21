unit PrevPrinter;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Graphics,
  Forms,
  Printers,
  StdCtrls,
  ComCtrls;

const
   INCH_TO_CM = 2.54;

type
   TDrawStyle = (dsStandard, dsOwnerDrawFixed, dsOwnerDrawVariable);
   TPrintPageNumber = (pnBottom, pnTop, pnNone);
   TUnits = (unInches, unCentimeters);
   TZoomOption = (zoFitToPage, zoFitToWidth, zoTwoPages, zoCustom);
   TStatusType = (stPaginating, stPrinting, stPaginationFinished, stPrintFinished);

   TOwnerHeightProc = procedure(Sender: TObject; Line: integer; var Height: integer; var ForceNewPage: boolean) of object;
   TOwnerDrawProc = procedure(Sender: TObject; Page, Line: integer; R: TRect; Canvas: TCanvas) of object;
   TNewPageProc = procedure(Sender: TObject; Page: integer) of object;
   TStatusProc = procedure(Sender: TObject; const StatMsg: string; PageNum: integer; StatusType: TStatusType) of object;

   TTextOptions = class(TPersistent)
   protected
      FDrawStyle  : TDrawStyle;
      FLeft       : double;
      FTop        : double;
      FRight      : double;
      FBot        : double;
      FBodyFont   : TFont;
      FHdrFont    : TFont;
      FFtrFont    : TFont;
      FPageFont   : TFont;
      FHeader     : string;
      FFooter     : string;
      FHdrMarg    : double;
      FFtrMarg    : double;
      FHdrAlign   : TAlignment;
      FFtrAlign   : TAlignment;
      FPrtPage    : TPrintPageNumber;
      FPageAlign  : TAlignment;
      FPageText   : string;
      procedure   SetBodyFont(Val: TFont);
      procedure   SetHdrFont(Val: TFont);
      procedure   SetFtrFont(Val: TFont);
      procedure   SetPageFont(Val: TFont);
   public
      constructor Create;
      destructor  Destroy; override;
      procedure   Assign(Source: TPersistent); override;
   published
      property    DrawStyle: TDrawStyle read FDrawStyle write FDrawStyle;
      property    MarginLeft: double read FLeft write FLeft;
      property    MarginTop: double read FTop write FTop;
      property    MarginRight: double read FRight write FRight;
      property    MarginBottom: double read FBot write FBot;
      property    BodyFont: TFont read FBodyFont write SetBodyFont;
      property    HeaderFont: TFont read FHdrFont write SetHdrFont;
      property    FooterFont: TFont read FFtrFont write SetFtrFont;
      property    PageNumFont: TFont read FPageFont write SetPageFont;
      property    Header: string read FHeader write FHeader;
      property    Footer: string read FFooter write FFooter;
      property    HeaderMargin: double read FHdrMarg write FHdrMarg;
      property    FooterMargin: double read FFtrMarg write FFtrMarg;
      property    HeaderAlign: TAlignment read FHdrAlign write FHdrAlign;
      property    FooterAlign: TAlignment read FFtrAlign write FFtrAlign;
      property    PrintPageNumber: TPrintPageNumber read FPrtPage write FPrtPage;
      property    PageNumAlign: TAlignment read FPageAlign write FPageAlign;
      property    PageNumText: string read FPageText write FPageText;
   end;

   TPreviewPrinter = class(TComponent)
   private
    fUsePrinterOrientation: boolean;
    procedure SetUserPrinterOrientation(const Value: boolean);
    procedure SetOrient(const Value: TPrinterOrientation);
    function GetOrient: TPrinterOrientation;
    function GetPrintableWidth: integer;
    function GetPrintableHeight: integer;
//      TmpBmp      : TBitmap;
   protected
      FOrient     : TPrinterOrientation;
      FPrinting   : boolean;
      FTitle      : string;
      MFList      : TList;
      CurCanvas   : TCanvas;
      ppix, ppiy  : integer;
      sizex,sizey : integer;
      offx, offy  : integer;
      UsedPage    : boolean;
      FDrawOpt    : TTextOptions;
      FUnits      : TUnits;
      ConvFac     : double;
      FShowGrid   : boolean;
      FZoomOpt    : TZoomOption;
      FZoomVal    : integer;
      FOwnHgt     : TOwnerHeightProc;
      FOwnDraw    : TOwnerDrawProc;
      FNewPage    : TNewPageProc;
      FOnStatus   : TStatusProc;
      function    GetCanvas: TCanvas;
      function    GetPageNum: integer;
      procedure   FreeMetaFiles;
      function    GetMetaFile(i: integer): TMetaFile;
      function    GetLastAvailPage: integer;
      procedure   SetDrawOptions(NewOptions: TTextOptions);
      procedure   SetUnits(Val: TUnits);
      procedure   InitPrinterVars(hdc: THandle);
      procedure   Loaded; override;
   public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
   // Helper Methods (Canvas)
      function    UnitToX(x: double): integer;
      function    UnitToY(y: double): integer;
      function    XToUnit(x: integer): double;
      function    YToUnit(y: integer): double;
      procedure   DrawAlignText(y: integer; Align: TAlignment; const Text: string; Font: TFont);
      procedure   FixFont(Font: TFont);
      procedure   RestoreFont(Font: TFont; PPI: integer);
      function    PageSetupDlg: integer;
   // Printer Methods
      procedure   BeginDoc;
      procedure   NewPage;
      procedure   EndDoc;
      procedure   Preview;
      procedure   Print;
      function    GetPreviewForm: TForm;
      function    PrintDialog: boolean;
      function    PrintRange(StartPage, StopPage: integer): boolean;
      procedure   DrawHdrFtrPage(PageNum: integer);
      procedure   DrawStringList(Strings: TStrings);
      procedure   DrawRichText(RE: TCustomRichEdit);
      property    MetaFiles[i: integer]: TMetaFile read GetMetaFile;
      property    PixelsPerInchX: integer read ppix;
      property    PixelsPerInchY: integer read ppiy;
      property    PageWidth: integer read sizex;
      property    PageHeight: integer read sizey;
      property    OffsetX: integer read offx;
      property    OffsetY: integer read offy;
      property    LastAvailPage: integer read GetLastAvailPage;
      property    Canvas: TCanvas read GetCanvas;
      property    PageNumber: integer read GetPageNum;
      property    Printing: boolean read FPrinting;
      property    PrintableWidth : integer
                  read GetPrintableWidth;
      property    PrintableHeight : integer
                  read GetPrintableHeight;
   published
      property    Orientation: TPrinterOrientation read GetOrient write SetOrient;
      property    Title: string read FTitle write FTitle;
      property    TextOptions: TTextOptions read FDrawOpt write SetDrawOptions;
      property    Units: TUnits read FUnits write SetUnits;
      property    ShowGrid: boolean read FShowGrid write FShowGrid;
      property    ZoomOption: TZoomOption read FZoomOpt write FZoomOpt;
      property    ZoomVal: integer read FZoomVal write FZoomVal;
      property    OnOwnerHeight: TOwnerHeightProc read FOwnHgt write FOwnHgt;
      property    OnOwnerDraw: TOwnerDrawProc read FOwnDraw write FOwnDraw;
      property    OnNewPage: TNewPageProc read FNewPage write FNewPage;
      property    OnStatus: TStatusProc read FOnStatus write FOnStatus;
      property    UsePrinterOrientation : boolean
                  read fUsePrinterOrientation
                  write SetUserPrinterOrientation
                  default FALSE;
   end;

   procedure Register;


implementation

uses
  PrevForm,
  Controls,
  Dialogs,
  RichEdit,
  PageSetupDlg;

type
   TBenMetaFileCanvas = class(TMetaFileCanvas)
   protected
      OldFontChanged : TNotifyEvent;
      procedure   NewFontChanged(Sender: TObject);
   public
      PPI         : integer;
      constructor Create(AMetafile: TMetafile; ReferenceDevice: HDC);
   end;


// ************************************************************************
// TBenMetaFileCanvas

constructor TBenMetaFileCanvas.Create(AMetafile: TMetafile; ReferenceDevice: HDC);
begin
   inherited;
   OldFontChanged := Font.OnChange;
   Font.OnChange := NewFontChanged;
end;

procedure TBenMetaFileCanvas.NewFontChanged(Sender: TObject);
begin
   if Assigned(OldFontChanged) then OldFontChanged(Sender);
   {OldSize := Font.Size;
   Font.PixelsPerInch := PPI;
   Font.Size := OldSize;}
end;


// ************************************************************************
// TTextOptions

constructor TTextOptions.Create;
begin
   inherited;
   DrawStyle    := dsStandard;
   MarginLeft   := 1;
   MarginTop    := 1;
   MarginRight  := 1;
   MarginBottom := 1;
   FHdrMarg     := 0.5;
   FFtrMarg     := 0.75;
   FHdrAlign    := taCenter;
   FFtrAlign    := taCenter;

   PrintPageNumber := pnBottom;
   FPageAlign      := taRightJustify;

   FBodyFont := TFont.Create;
   FHdrFont  := TFont.Create;
   FFtrFont  := TFont.Create;
   FPageFont := TFont.Create;

   FBodyFont.Name := 'Arial';
   FBodyFont.Size := 10;
   FHdrFont.Name  := 'Times New Roman';
   FHdrFont.Size  := 18;
   FHdrFont.Style := [fsBold];
   FFtrFont.Name  := 'Times New Roman';
   FFtrFont.Size  := 10;
   FFtrFont.Style := [fsItalic];
   FPageFont.Assign(FFtrFont);

   FPageText := 'Page %d';
end;

destructor TTextOptions.Destroy;
begin
   FBodyFont.Free;
   FHdrFont.Free;
   FFtrFont.Free;
   FPageFont.Free;
   inherited;
end;

procedure TTextOptions.Assign(Source: TPersistent);
begin
   if Self = Source then exit;
   MessageBeep(0);
end;

procedure TTextOptions.SetBodyFont(Val: TFont);
begin
   FBodyFont.Assign(Val);
end;

procedure TTextOptions.SetHdrFont(Val: TFont);
begin
   FHdrFont.Assign(Val);
end;

procedure TTextOptions.SetFtrFont(Val: TFont);
begin
   FFtrFont.Assign(Val);
end;

procedure TTextOptions.SetPageFont(Val: TFont);
begin
   FPageFont.Assign(Val);
end;


// ************************************************************************
// TPreviewPrinter

constructor TPreviewPrinter.Create(AOwner: TComponent);
begin
   inherited;
   FDrawOpt  := TTextOptions.Create;
   FPrinting := False;
   FOrient   := poPortrait;
   CurCanvas := nil;
   MFList    := TList.Create;
   FUnits    := unInches;
   FShowGrid := False;
   FZoomOpt  := zoFitToPage;
   FZoomVal  := 100;
end;

destructor TPreviewPrinter.Destroy;
begin
//   TmpBmp.Free;
   FreeMetaFiles;
   MFList.Free;
   FDrawOpt.Free;
   inherited;
end;

procedure TPreviewPrinter.Loaded;
var
   ps : TPageSetupForm;
begin
   inherited;

   if not (csDesigning in ComponentState) then
   begin
      ps          := TPageSetupForm.Create(Self);
      ps.TextOpt  := TextOptions;
      ps.pp       := Self;

      ps.GetDefaults;
      ps.Free;
   end;
end;

procedure TPreviewPrinter.SetDrawOptions(NewOptions: TTextOptions);
begin
  if FDrawOpt<>NewOptions then
  begin
    FDrawOpt.Assign(NewOptions);
  end;
end;

procedure TPreviewPrinter.SetOrient(const Value: TPrinterOrientation);
begin
  fOrient := Value;
end;

function TPreviewPrinter.PageSetupDlg: integer;
var
  ps : TPageSetupForm;
begin
  ps          := TPageSetupForm.Create(Self);
  ps.TextOpt  := TextOptions;
  ps.pp       := Self;

  Result := ps.Execute;
  ps.Free;
end;


procedure TPreviewPrinter.FreeMetaFiles;
var
  i : integer;
begin
  for i := 0 to MFList.Count-1 do
  begin
    MetaFiles[i].Free;
  end;
  MFList.Clear;
  CurCanvas.Free;
  CurCanvas := nil;
end;

function TPreviewPrinter.GetMetaFile(i: integer): TMetaFile;
begin
  Result := MFList[i];
end;

function TPreviewPrinter.GetOrient: TPrinterOrientation;
begin
  if UsePrinterOrientation and not (csDesigning in ComponentState) then
  begin
    Result := Printer.Orientation
  end
  else
  begin
    Result := fOrient;
  end;
end;

procedure TPreviewPrinter.SetUnits(Val: TUnits);
begin
  FUnits := Val;
  case FUnits of
    unInches       : ConvFac := 1;
    unCentimeters  : ConvFac := INCH_TO_CM;
  end;
end;

procedure TPreviewPrinter.SetUserPrinterOrientation(const Value: boolean);
begin
  fUsePrinterOrientation := Value;
end;

procedure TPreviewPrinter.BeginDoc;
begin
  FPrinting := True;
  FreeMetaFiles;
  NewPage;
end;

procedure TPreviewPrinter.InitPrinterVars(hdc: THandle);
begin
  ppix := GetDeviceCaps(hdc, LOGPIXELSX);
  ppiy := GetDeviceCaps(hdc, LOGPIXELSY);

  sizex := GetDeviceCaps(hdc, PHYSICALWIDTH);
  sizey := GetDeviceCaps(hdc, PHYSICALHEIGHT);

  if sizex = 0 then
  begin
    sizex := Round(8.5 * Screen.PixelsPerInch);
    sizey := Round(11 * Screen.PixelsPerInch);
  end;

  offx := GetDeviceCaps(hdc, PHYSICALOFFSETX);
  offy := GetDeviceCaps(hdc, PHYSICALOFFSETY);
end;

procedure TPreviewPrinter.NewPage;
var
  MetaFile    : TMetaFile;
  NewCanvas   : TCanvas;
  UseScreen   : boolean;
begin
  Assert(FPrinting);

  MetaFile := TMetaFile.Create;
  MFList.Add(MetaFile);

  // Setup up the Metafile Canvas
  // Use the Default Printer if one is available, otherwise use the Screen

  UseScreen := True;
  NewCanvas := nil;
  if Printer.Printers.Count > 0 then
  begin
    UseScreen := False;
    try
      if not UsePrinterOrientation then
      begin
        Printer.Orientation := Orientation;
      end;
      NewCanvas := TBenMetaFileCanvas.Create(MetaFile, Printer.Handle);
      InitPrinterVars(Printer.Handle);
    except
      UseScreen := True;
      NewCanvas.Free;
    end;
  end;

  // Use the screen if there is no Default Printer or printers installed
  if UseScreen then
  begin
    NewCanvas := TBenMetaFileCanvas.Create(MetaFile, 0);
    InitPrinterVars(NewCanvas.Handle);
  end;

  (NewCanvas as TBenMetaFileCanvas).PPI := ppiy;
  NewCanvas.Font.PixelsPerInch := ppiy;  // Delphi must not do this right, that's why I have to do it manually here
  if assigned( CurCanvas ) then
  begin
    NewCanvas.Font  := CurCanvas.Font;
    NewCanvas.Brush := CurCanvas.Brush;
    NewCanvas.Pen   := CurCanvas.Pen;
  end
  else
  begin
    NewCanvas.Font.Name := 'Arial';  // Need a TrueType font that can scale (MS Sans Serif doesn't scale well)
    NewCanvas.Font.Size := 10;
    NewCanvas.Brush.Style := bsClear;
  end;

  CurCanvas.Free;
  CurCanvas := NewCanvas;
  UsedPage := False;

  if Assigned(OnStatus) then
  begin
    OnStatus(Self, Format('Paginating page %d', [MFList.Count]), MFList.Count, stPaginating);
  end;
end;

function TPreviewPrinter.UnitToX(x: double): integer;
begin
  Result := Round(x * ppix / ConvFac);
end;

function TPreviewPrinter.UnitToY(y: double): integer;
begin
  Result := Round(y * ppiy / ConvFac);
end;

function TPreviewPrinter.XToUnit(x: integer): double;
begin
  Result := x / ppix * ConvFac;
end;

function TPreviewPrinter.YToUnit(y: integer): double;
begin
  Result := y / ppiy * ConvFac;
end;

procedure TPreviewPrinter.EndDoc;
var
  i : integer;
begin
  FPrinting := False;
  CurCanvas.Free;      // This is to close out the MetaFile
  CurCanvas := nil;

  // This is incase they called NewPage, but never drew anything on it
  if UsedPage = False then
  begin
    i := MFList.Count-1;
    if i >= 0 then
    begin
      MetaFiles[ i ].Free;
      MFList.Delete(i);
    end;
  end;

  if Assigned(OnStatus) then
  begin
    OnStatus(Self, 'Pagination Complete', -1, stPaginationFinished);
  end;
end;

function TPreviewPrinter.GetPreviewForm: TForm;
var
  pf : TPreviewForm;
begin
  Assert(FPrinting = False); // Change this later when allow threaded printing
  pf := TPreviewForm.Create(nil);
  pf.PrevPrinter := Self;
  pf.GridBut.Down := ShowGrid;

  case ZoomOption of
    zoFitToPage  :
    begin
      pf.ZoomBox.ItemIndex := 0;
    end;
    zoFitToWidth :
    begin
      pf.ZoomBox.ItemIndex := 1;
    end;
    zoTwoPages   :
    begin
      pf.TwoPageBut.Down := True;
    end;
    zoCustom     :
    begin
      pf.ZoomBox.ItemIndex := 11;
      pf.Zoom := ZoomVal;
    end;
  end;
  pf.ScrollBox1Resize(nil);

  Result := pf;
end;

function TPreviewPrinter.GetPrintableHeight: integer;
begin
  try
    Result := GetDeviceCaps( Printer.Handle, VERTRES );
  except
    Result := PageHeight;
  end;
end;

function TPreviewPrinter.GetPrintableWidth: integer;
begin
  try
    Result := GetDeviceCaps( Printer.Handle, HORZRES );
  except
    Result := PageWidth;
  end;
end;

procedure TPreviewPrinter.Preview;
var
  pf : TPreviewForm;
begin
  pf := GetPreviewForm as TPreviewForm;

  pf.ShowModal;
  pf.Free;
end;

function TPreviewPrinter.PrintDialog: boolean;
var
  pd                : TPrintDialog;
  Start, Stop, Copy : integer;
begin
  Result := False;

  pd := TPrintDialog.Create(nil);
  pd.FromPage := 1;
  pd.MinPage  := 1;
  pd.MaxPage  := LastAvailPage;
  pd.ToPage   := LastAvailPage;
  pd.Options  := [poPageNums];

  try
    if pd.Execute then
    begin
      Result := True;

      if pd.PrintRange = prAllPages then
      begin
        Start := 0;
        Stop  := LastAvailPage - 1;
      end else
      begin
        Start := pd.FromPage - 1;
        Stop  := pd.ToPage - 1;
      end;

      for Copy := 1 to pd.Copies do
      begin
        PrintRange(Start, Stop);
      end;
    end;
  finally
    pd.Free;
  end;
end;

procedure TPreviewPrinter.Print;
begin
  PrintRange(0, LastAvailPage-1);
end;

// Returns False if user cancels print job
function TPreviewPrinter.PrintRange(StartPage, StopPage: integer): boolean;
var
  Page  : integer;
begin
  Screen.Cursor := crHourGlass;
  try
    Result := True;

    if not UsePrinterOrientation then
    begin
      Printer.Orientation := Orientation;
    end;
    Printer.BeginDoc;
    Printer.Title := Title;
    InitPrinterVars(Printer.Handle);

    for Page := StartPage to StopPage do
    begin
      if Assigned(OnStatus) then
      begin
        OnStatus(Self, Format('Printing page %d', [Page]), Page, stPrinting);
      end;

      // Print the Page
      Printer.Canvas.Draw(-offx, -offy, MetaFiles[Page]);

      if Page < StopPage then
      begin
        Printer.NewPage;
      end;
    end;

    Printer.EndDoc;

    if Assigned(OnStatus) then
    begin
      OnStatus(Self, 'Print Job Complete', -1, stPrintFinished);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPreviewPrinter.GetPageNum: integer;
begin
  Result := MFList.Count;
end;

function TPreviewPrinter.GetLastAvailPage: integer;
begin
  // TODO:  This will change with threading
  Result := GetPageNum;
end;

function TPreviewPrinter.GetCanvas: TCanvas;
begin
  Assert(FPrinting, 'Canvas is not available before BeginDoc');
  Result := CurCanvas;
  UsedPage := True;
end;

procedure TPreviewPrinter.RestoreFont(Font: TFont; PPI: integer);
var
  OldSize : integer;
begin
  OldSize := Font.Size;
  Font.PixelsPerInch := PPI;
  Font.Size := OldSize;
end;

procedure TPreviewPrinter.FixFont(Font: TFont);
begin
  // RestoreFont(Font, ppiy);
end;

procedure TPreviewPrinter.DrawAlignText(y: integer; Align: TAlignment; const Text: string; Font: TFont);
var
  OldFont : TFont;
  x, tmp  : integer;
begin
  OldFont := TFont.Create;
  OldFont.Assign(Canvas.Font);

  if Font<>nil then
  begin
    Canvas.Font := Font;
  end;
  tmp := Canvas.TextWidth(Text);
  case Align of
    taLeftJustify   : x := UnitToX(TextOptions.MarginLeft);
    taCenter        : x := PageWidth div 2 - tmp div 2;
    taRightJustify  : x := PageWidth - UnitToX(TextOptions.MarginRight) - tmp;
    else x := 0;
  end;

  Canvas.TextOut(x, y, Text);

  Canvas.Font := OldFont;
  OldFont.Free;
end;

procedure TPreviewPrinter.DrawHdrFtrPage(PageNum: integer);
var
  y1, y2   : integer;
  PageStr  : string;
begin
  with TextOptions do
  begin
    // Draw the Header, Footer, & Page Num
    y1 := UnitToY(HeaderMargin);
    y2 := PageHeight - UnitToY(FooterMargin);
    DrawAlignText(y1, HeaderAlign, Header, HeaderFont);
    DrawAlignText(y2, FooterAlign, Footer, FooterFont);
    PageStr := Format(PageNumText, [PageNum]);
    case PrintPageNumber of
      pnTop    : DrawAlignText(y1, PageNumAlign, PageStr, PageNumFont);
      pnBottom : DrawAlignText(y2, PageNumAlign, PageStr, PageNumFont);
    end;
  end;
end;

procedure TPreviewPrinter.DrawStringList(Strings: TStrings);
var
  Line         : integer;
  Page         : integer;
  x, y         : integer;
  h            : integer;
  R            : TRect;
  ForceNewPage : boolean;
  tm           : TTextMetric;
begin
  Screen.Cursor := crHourGlass;
  BeginDoc;

   // Init the fonts
  with TextOptions do
  begin
    FixFont(BodyFont);
    FixFont(HeaderFont);
    FixFont(FooterFont);
    FixFont(PageNumFont);
  end;

  Page := 0;

   // Begin Page
  x := UnitToX(TextOptions.MarginLeft);
  y := -2;

  for Line := 0 to Strings.Count-1 do
  begin
    with TextOptions do
    begin
      // Get our current line height (and check for New Page)
      Canvas.Font := BodyFont;
      h := -1;
      ForceNewPage := False;
      if Assigned(OnOwnerHeight) then
      begin
        OnOwnerHeight(Self, Line, h, ForceNewPage);
      end;
      if ForceNewPage then
      begin
         y := -1;
      end;
      if DrawStyle <> dsOwnerDrawVariable then
      begin
        h := Canvas.TextHeight('f');
        GetTextMetrics(Canvas.Handle, tm);
        h := h + tm.tmInternalLeading + tm.tmExternalLeading;
      end;
      if h=-1 then
      begin
        Exception.Create('OnOwnerHeight Event returned an invalid height!');
      end;

      // Check if we need a new page
      if (y < 0) or (y + h > UnitToY(YToUnit(PageHeight)-TextOptions.MarginBottom)) then
      begin
        Page := Page + 1;
        if Assigned(OnNewPage) then
        begin
          OnNewPage(Self, Page);
        end;
        if y >= -1 then
        begin
          NewPage;
        end;
        y := UnitToY(MarginTop);

        DrawHdrFtrPage(Page);
      end;

      // Draw the current line
      R := Rect(UnitToX(MarginLeft), y, PageWidth - UnitToX(MarginRight)+1,  y+h+1 {PageHeight - lower "g" getting clipped?});
      case DrawStyle of
        dsOwnerDrawFixed,
        dsOwnerDrawVariable:
        begin
          if Assigned(OnOwnerDraw) then
          begin
            OnOwnerDraw(Self, Page, Line, R, Canvas);
          end;
        end
        else Canvas.TextRect(R, x, y, Strings[Line]);
      end;

      y := y + h;
    end;
  end;

  EndDoc;
  Screen.Cursor := crDefault;
end;


procedure RE_To_Canvas(RE: TCustomRichEdit; Canvas: TCanvas; var R: TRect;
   var Pos: integer; var NeedWrap: boolean);
var
  Range              : TFormatRange;
  OutDC              : HDC;
  LastChar, MaxLen,
  LogX, LogY, OldMap : Integer;
begin
   Assert(RE<>nil);
   Assert(IsWindow(RE.Handle));

   FillChar(Range, SizeOf(TFormatRange), 0);

   LastChar := Pos;

   OutDC             := Canvas.Handle;
   Range.hdc         := OutDC;
   Range.hdcTarget   := OutDC;
   LogX := GetDeviceCaps(OutDC, LOGPIXELSX);
   LogY := GetDeviceCaps(OutDC, LOGPIXELSY);
   if IsRectEmpty(RE.PageRect) then begin
      Range.rc := R;
   end else begin
      Range.rc.left := RE.PageRect.Left * 1440 div LogX;
      Range.rc.top := RE.PageRect.Top * 1440 div LogY;
      Range.rc.right := RE.PageRect.Right * 1440 div LogX;
      Range.rc.bottom := RE.PageRect.Bottom * 1440 div LogY;
   end;
   Range.rcPage := Range.rc;
   MaxLen := RE.GetTextLen;
   Range.chrg.cpMax := -1;

   // ensure the output DC is in text map mode
   OldMap := SetMapMode(Range.hdc, MM_TEXT);
   SendMessage(RE.Handle, EM_FORMATRANGE, 0, 0);  // flush buffer

   Range.chrg.cpMin := LastChar;
   LastChar := SendMessage(RE.Handle, EM_FORMATRANGE, 1, Longint(@Range));
   NeedWrap := (LastChar < MaxLen) and (LastChar <> -1);

   SendMessage(RE.Handle, EM_FORMATRANGE, 0, 0);  // flush buffer
   SetMapMode(OutDC, OldMap);

   Pos := LastChar;
   R   := Range.rc;
end;


procedure TPreviewPrinter.DrawRichText(RE: TCustomRichEdit);
var
   x1, y1    : integer;
   x2, y2    : integer;
   R         : TRect;
   Pos, Page : integer;
   NeedWrap  : boolean;
   OldUnits  : TUnits;
begin
   Screen.Cursor := crHourGlass;
   OldUnits := Units;
   Units := unInches;
   try
      Pos := 0;
      Page := 0;
      repeat
         if Pos = 0 then BeginDoc
            else NewPage;

         Page := Page + 1;
         DrawHdrFtrPage(Page);

         x1 := Round(1440.0 * TextOptions.MarginLeft);
         y1 := Round(1440.0 * TextOptions.MarginTop);
         x2 := Round(1440.0 * (XToUnit(PageWidth) - TextOptions.MarginRight));
         y2 := Round(1440.0 * (XToUnit(PageHeight) - TextOptions.MarginBottom));
         R := Rect(x1, y1, x2, y2);

         RE_To_Canvas(RE, Canvas, R, Pos, NeedWrap);
      until not NeedWrap;

      EndDoc;
   finally
      Units := OldUnits;
      Screen.Cursor := crDefault;
   end;
end;


procedure Register;
begin
   RegisterComponents('Samples', [TPreviewPrinter]);
end;


end.
