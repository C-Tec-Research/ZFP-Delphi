unit UnitPrintReport;

{
  descend from type tPrintReport for your reports.
  Has several useful functions built in.

  The preview printer must be constructed externally.

  A report is split into sections, each section having its own layout consisting
  of a header, a footer and several columns

  The top of any column is always the bottom of the header, so to change column
  tops, change the header height. Similarly the bottom of a column is is the
  top of the footer.
}

interface

uses
  SysUtils,
  Graphics,
  PrevPrinter,
  Contnrs,
  SigSparseLists,
  SigFile,
  Classes;

type

  tPrintLineResponse = ( plrOK, plrDone, plrNoRoom );

  tFontStack = class( tObjectStack )
  private
  public
    function Push(AObject: TFont): TFont; reintroduce;
    function Pop: TFont; reintroduce;
    function Peek: TFont; reintroduce;
  end;

  tPrintReport = class;
  tPrintSection = class;

  tPrintArea = class( tObjectList )
  private
    function GetPreviewPrinter: tPreviewPrinter;
    function GetCanvas: tCanvas;
    procedure SetCalculatingPages(const Value: boolean);
    function GetParentReport: tPrintReport;
    function GetPrintArea(const i: integer): tPrintArea;
    function GetFont: tFont;
    function GetParentSection: tPrintSection;
  protected
    fParent: tPrintArea;
    function GetCalculatingPages: boolean; virtual;
    function GetTextVisible: boolean; virtual;
    function GetCurrentTop: integer; virtual;
    procedure SetCurrentTop(const Value: integer); virtual;
    function GetHeight: integer; virtual;
    function GetWidth: integer; virtual;
    function GetTop: integer; virtual;
    function GetBottom : integer; virtual;
    function GetLeft: integer; virtual;
    function GetRight: integer; virtual;
    function GetCurrentPage: integer; virtual;
    procedure SetCurrentPage(const Value: integer); virtual;
    function GetPageCount: integer; virtual;
    function GetSaveFont: tFontStack; virtual;
  public
    constructor Create( AParent : tPrintArea ); virtual;
    destructor Destroy; override;

    function Print : boolean; virtual;
    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; virtual; abstract;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; virtual; abstract;

    function LeftJustifyText( const Text : string; var pHeight : integer; var pWidth : integer  ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    function CentreText( const Text : string; var pHeight : integer; var pWidth : integer  ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    function RightJustifyText( const Text : string; var pHeight : integer; var pWidth : integer  ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    function LeftJustifyText( const Text : string  ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    function CentreText( const Text : string ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    function RightJustifyText( const Text : string ) : boolean; overload;// returns false if cannot print becaus of footer or Width problems
    procedure StartPrintActivity;
    procedure CompletePrintActivity;
    function TextHeight( const Text : string ) : integer;
    function TextWidth( const Text : string ) : integer;

    procedure SetupPrint; virtual; // intended to set and children sizes, etc

    function Add( Value : tPrintArea ) : integer; reintroduce;

    procedure Next; virtual;  // page or columne

    property PrintArea[ const i : integer ] : tPrintArea
             read GetPrintArea; default;

    property Parent : tPrintArea
             read fParent;
    property ParentReport : tPrintReport
             read GetParentReport;
    property ParentSection : tPrintSection
             read GetParentSection;
    property Top : integer
             read GetTop;
    property Left : integer
             read GetLeft;
    property Bottom : integer
             read GetBottom;
    property Right : integer
             read GetRight;
    property Width : integer
             read GetWidth;
    property Height : integer
             read GetHeight;

    property CurrentTop : integer
             read GetCurrentTop
             write SetCurrentTop;
    property CalculatingPages : boolean
             read GetCalculatingPages
             write SetCalculatingPages;
    property TextVisible : boolean
             read GetTextVisible;
    property Font : tFont
             read GetFont;
    property PreviewPrinter : tPreviewPrinter
             read GetPreviewPrinter;

    property Canvas : tCanvas
             read GetCanvas;

    property CurrentPage : integer
             read GetCurrentPage
             write SetCurrentPage;
    property PageCount : integer
             read GetPageCount;

    property SaveFont : tFontStack
             read GetSaveFont;
  end;

  tPrintHeader = class( tPrintArea )
  private
  protected
    fBottom : integer;
    procedure SetHeight(const Value: integer);
    function GetTop: integer; override;
    function GetBottom : integer ; override;
  public
    constructor Create( AParent : tPrintArea ); override;

    function Print : boolean; override;
    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    {
      here the top is fixed, but Height is adjustable
    }
    property Height : integer
             read GetHeight
             write SetHeight;
  end;

  tPrintSubheader = class( tPrintArea )
  {
    This gives a standarsd subtitle according to certain styles
  }
  private
    fText: string;
    fOverLineThickness: integer;
    fUnderLineThickness: integer;
    fMarginPC: integer;
  protected
    function GetWidth : integer; override;
  public
    constructor Create( AParent : tPrintArea ); override;

    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    property Text : string
             read fText
             write fText;
    property OverLineThickness : integer  // <= 0 means no overline
             read fOverLineThickness
             write fOverLineThickness;
    property UnderLineThickness : integer   // 0 = same as overline thickness, -1 = no underline
             read fUnderLineThickness
             write fUnderLineThickness;
    property MarginPC : integer  // margin as a percentage of width; default 5%
             read fMarginPC
             write fMarginPC;
  end;

  tPrintBox = class( tPrintArea  )
  private
    fText: string;
    fLineThickness: integer;
    fLeft : integer;
    fRight : integer;
    fMaxWidth: integer;
    procedure SetMaxWidth(const Value: integer);
    procedure SetText(const Value: string);
  protected
    function GetLeft : integer; override;
    function GetRight : integer; override;
  public
    constructor Create( AParent : tPrintArea ); override;

    procedure SetupPrint; override; // intended to set and children sizes, etc

    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    property Text : string
             read fText
             write SetText;
    property LineThickness : integer
             read fLineThickness
             write fLineThickness;
    property Left : integer
             read fLeft
             write fLeft;
    property Right : integer
             read fRight
             write fRight;
    property MaxWidth : integer
             read fMaxWidth
             write SetMaxWidth;
  end;

  tPrintFooter = class( tPrintArea )
  private
    fTop : integer;
    fCurrentTop : integer;
    procedure SetHeight(const Value: integer);
    function GetParentReport: tPrintReport;
  protected
    function GetTop : integer; override;
    function GetCurrentTop: integer; override;
    procedure SetCurrentTop(const Value: integer); override;
    function GetBottom : integer ; override;
  public
    constructor Create( AParent : tPrintArea ); override;
    {
      here the bottom is fixed, but Height is adjustable
    }
    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    property Height : integer
             read GetHeight
             write SetHeight;
    property ParentReport : tPrintReport
             read GetParentReport;
  end;

  tPrintColumn = class( tPrintArea )
  private
    fWidthSet: boolean;
    fLeft: integer;
    fRight : integer;
    fWidth : integer;
  protected
    procedure SetWidth(const Value: integer);
    function GetBottom: integer; override;
    function GetTop: integer; override;
    function GetWidth : integer; override;
  public
    constructor Create( AParent : tPrintArea ); override;

    procedure Next; override;  // page or columne

    property Width : integer
             read GetWidth
             write SetWidth;
    property WidthSet : boolean
             read fWidthSet
             write fWidthSet;
    property Left : integer
             read fLeft
             write fLeft;
    property Top : integer
             read GetTop;
    property Bottom : integer
             read GetBottom;
  end;

  tPrintSection = class( tPrintArea )
  private
    //fParent: tPrintReport;
    fHeader: tPrintHeader;
    fFooter: tPrintFooter;
    fCurrentColumn: integer;
    function GetColumn(const i: integer): tPrintColumn;
    procedure SetColumnWidth(const i, Value: integer);
    function GetPreviewPrinter: tPreviewPrinter;
    function GetNeedsNewPage: boolean;
    procedure SetNeedsNewPage(const Value: boolean);
    function GetFooter: tPrintFooter;
  protected
    function GetWidth: integer; override;
    function GetHeight: integer; override;
    function GetBottom: integer; override;
    function GetColumnWidth(const i: integer): integer; virtual;
  public
    constructor Create( AParent : tPrintArea ); override;
    destructor Destroy; override;

    function Add( NewVal : tPrintColumn ) : integer; reintroduce;

    procedure BalanceColumns;
    function Print : boolean; override;
    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    procedure Next; override;  // page or columne

    //property Parent : tPrintReport
    //         read fParent;

    property Header : tPrintHeader
             read fHeader
             write fHeader;
    property Footer : tPrintFooter
             read GetFooter
             write fFooter;
    property Column[ const i : integer ] : tPrintColumn
             read GetColumn;
    property ColumnWidth[ const i : integer ] : integer
             read GetColumnWidth
             write SetColumnWidth;

    property Width : integer
             read GetWidth;
    property Height : integer
             read GetHeight;
    property CurrentPage : integer
             read GetCurrentPage
             write SetCurrentPage;
    property NeedsNewPage : boolean
             read GetNeedsNewPage
             write SetNeedsNewPage;
    property PreviewPrinter : tPreviewPrinter
             read GetPreviewPrinter;
    property CurrentColumn : integer
             read fCurrentColumn;
  end;

  tPrintVirtualTable = class( tPrintSection )
  private
    fTitles : tStringList;
  protected
  public
    constructor Create( AParent : tPrintArea ); override;
    destructor Destroy; override;

    //function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    //function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function PrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; virtual; abstract;
    function CanPrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; virtual; abstract;

    property Titles : tStringList
             read fTitles;

  end;

  tPrintTable = class( tPrintVirtualTable )
  {
    in this case the columns are table columns. We have a host
    of properties pertaining to tables, including line thicknes,
    titles and so on.
  }
  private
    fCells : tSigSparseTable;
  protected
  public
    constructor Create( AParent : tPrintArea ); override;
    destructor Destroy; override;

    //function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    //function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    //function PrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    //function CanPrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    property Cells : tSigSparseTable
             read fCells;

  end;

  tPrintEMapTable = class( tPrintVirtualTable )
  private
    fEMapList: tSigEnumMapList;
    fLine: integer;
    fVisBox : tPrintBox;
    fIDBox  : tPrintBox;
    fValueBox : tPrintBox;
    fMarginPC: integer;
    procedure SetMarginPC(const Value: integer);
  protected
  public
    constructor Create( AParent : tPrintArea; pEMapList : tSigEnumMapList ); reintroduce;

    function Print : boolean; override;
    function PrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function PrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;
    function CanPrintHeaderLine( var pHeight, pWidth : integer ) : tPrintLineResponse; override;

    property EMapList : tSigEnumMapList
             read fEMapList;
    property Line : integer
             read fLine
             write fLine;
    property MarginPC : integer
             read fMarginPC
             write SetMarginPC;
  end;

  tWrappableSection = class( tPrintSection )
  private
    fColCount: integer;
    fCurrCol : integer;
  protected
    function GetLeft: integer; override;
    function GetColumnWidth(const i: integer): integer; override;
    function GetWidth : integer; override;
  public
    constructor Create( AParent : tPrintArea ); override;

    function Print : boolean; override;
    procedure Next; override;  // page or column


    property ColCount : integer
             read fColCount
             write fColCount;
  end;

  tPrintReport = class( tPrintArea )
  private
    fPreviewPrinter: tPreviewPrinter;
    fPageTop: integer;
    fPageBottom: integer;
    fPageLeft: integer;
    fPageRight: integer;
    fCalculatingPages: boolean;
    fNeedsNewPage: boolean;
    fCurrentTop: integer;
    fPageCount: integer;
    fCurrentPage: integer;
    fPrintAll : boolean;
    fPageFrom, fPageTo : integer;
    fSaveFont : tFontStack;
    function GetSection(const i: integer): tPrintSection;
    function GetParentReport: tPrintReport;
  protected
    function GetTextVisible: boolean; override;
    function GetWidth: integer; override;
    function GetRight: integer; override;
    function GetLeft: integer; override;
    function GetTop: integer; override;
    function GetBottom: integer; override;
    function GetHeight: integer; override;
    procedure PrintSections;
    procedure SetCurrentPage(const Value: integer); override;
    function GetSaveFont: tFontStack; override;
    function GetCurrentTop: integer; override;
    procedure SetCurrentTop(const Value: integer); override;
  public
    constructor Create( const pPreviewPrinter : tPreviewPrinter ); reintroduce;
    destructor Destroy; override;

    function Print : boolean; override;
    function CalculatePages : integer; virtual;
    procedure PrintPages; overload; virtual;
    procedure PrintPages( pFrom, pTo : integer); overload; virtual;

    property PreviewPrinter : tPreviewPrinter
             read fPreviewPrinter;
    property Width : integer
             read GetWidth;
    property Height : integer
             read GetHeight;
    property CalculatingPages : boolean
             read fCalculatingPages
             write fCalculatingPages;
    property TextVisible : boolean
             read GetTextVisible;
    property Section[ const i : integer ] : tPrintSection
             read GetSection;
    property NeedsNewPage : boolean
             read fNeedsNewPage
             write fNeedsNewPage;
    property CurrentPage : integer
             read fCurrentPage
             write SetCurrentPage;
    property PageCount : integer
             read fPageCount;
    property ParentReport : tPrintReport
             read GetParentReport;
  end;

implementation

{ tPrintReport }

function tPrintReport.CalculatePages : integer;
begin
  CalculatingPages := TRUE;
  SetupPrint;
  fNeedsNewPage := FALSE;
  CurrentPage := 0;
  PrintSections;
  Result := PageCount;
end;

constructor tPrintReport.Create(const pPreviewPrinter: tPreviewPrinter);
begin
  inherited Create( nil );

  fSaveFont := tFontStack.Create;

  fPreviewPrinter := pPreviewPrinter;

  fPageTop := fPreviewPrinter.OffsetY;
  fPageBottom := fPreviewPrinter.PageHeight - 2 * fPageTop;
  fPageLeft := fPreviewPrinter.OffsetX;
  fPageRight := fPreviewPrinter.PageWidth - 2 * fPageLeft;

end;

destructor tPrintReport.Destroy;
begin
  fSaveFont.Free;
  inherited;
end;

function tPrintReport.GetBottom: integer;
begin
  Result := fPageBottom;
end;

function tPrintReport.GetTextVisible: boolean;
begin
  if fPrintAll then
  begin
    Result := not fCalculatingPages;
  end
  else if (fCalculatingPages) or (fCurrentPage < fPageFrom) or (fCurrentPage > fPageTo) then
  begin
    Result := FALSE;
  end
  else
  begin
    Result :=TRUE;
  end;
end;

function tPrintReport.GetCurrentTop: integer;
begin
  Result := fCurrentTop;
end;

function tPrintReport.GetHeight: integer;
begin
  Result := Bottom - Top;
end;

function tPrintReport.GetLeft: integer;
begin
  Result := fPageLeft;
end;

function tPrintReport.GetParentReport: tPrintReport;
begin
  Result := self;
end;

function tPrintReport.GetRight: integer;
begin
  Result := fPageRight;
end;

function tPrintReport.GetSaveFont: tFontStack;
begin
  Result := fSaveFont;
end;

function tPrintReport.GetSection(const i: integer): tPrintSection;
begin
  Result := Items[ i ] as tPrintSection;
end;

function tPrintReport.GetTop: integer;
begin
  Result := fPageTop;
end;

function tPrintReport.GetWidth: integer;
begin
  Result := Right - Left;
end;

function tPrintReport.Print : boolean;
begin
  CalculatePages;
  PrintPages;
  Result := FALSE;
end;

procedure tPrintReport.PrintPages(pFrom, pTo : integer);
begin
  CalculatingPages := FALSE;
  fPrintAll := FALSE;
  fPageFrom := pFrom;
  fPageTo := pTo;
  fNeedsNewPage := FALSE;
  CurrentPage := 0;
  PrintSections;
end;

procedure tPrintReport.PrintPages;
begin
  CalculatingPages := FALSE;
  fPrintAll := TRUE;
  fNeedsNewPage := FALSE;
  CurrentPage := 0;
  PrintSections;
end;

procedure tPrintReport.PrintSections;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    Section[ i ].Print;
  end;
end;

procedure tPrintReport.SetCurrentPage(const Value: integer);
begin
  fCurrentPage := Value;
  if CalculatingPages then
  begin
    fPageCount := fCurrentPage;
  end;
end;

procedure tPrintReport.SetCurrentTop(const Value: integer);
begin
  fCurrentTop := Value;
end;

{ tPrintSection }

function tPrintSection.Add(NewVal: tPrintColumn): integer;
begin
  Result := inherited Add( NewVal );
  //BalanceColumns;
end;

procedure tPrintSection.BalanceColumns;
var
  iColWidth : integer;
  iColWidthLeft : integer;
  iColsLeft : integer;
  iLeft : integer;
  i : integer;
begin
  // reset all column widths to be equal, and reset WidthSet flag.
  iColWidthLeft := Width;
  iLeft := Left;
  iColsLeft := Count;
  for i := 0 to Count - 1 do
  begin
    iColWidth := iColWidthLeft div iColsLeft;
    with Column[ i ] do
    begin
      Left := iLeft;
      Width := iColWidth;
      WidthSet := False;
    end;
    inc( iLeft, iColWidth );
    dec( iColWidthLeft, iColWidth );
    dec( iColsLeft );
  end;
end;

constructor tPrintSection.Create( AParent : tPrintArea );
begin
  inherited Create( AParent );

end;

destructor tPrintSection.Destroy;
begin
  //fFont.Free;
  fHeader.Free;
  fFooter.Free;
  inherited;
end;

function tPrintSection.GetBottom: integer;
begin
  Result := Footer.Top;
end;

function tPrintSection.GetColumn(const i: integer): tPrintColumn;
begin
  Result := Items[ i ] as tPrintColumn;
end;

function tPrintSection.GetColumnWidth(const i: integer): integer;
begin
  Result := Column[ i ].Width;
end;

function tPrintSection.GetFooter: tPrintFooter;
begin
  Result := fFooter;
  if not assigned( Result ) then
  begin
    Result := ParentSection.Footer;
  end;
end;

function tPrintSection.GetHeight: integer;
begin
  Result := Parent.Height;
end;

function tPrintSection.GetNeedsNewPage: boolean;
begin
  Result := ParentReport.NeedsNewPage;
end;

function tPrintSection.GetPreviewPrinter: tPreviewPrinter;
begin
  Result := Parent.PreviewPrinter;
end;

function tPrintSection.GetWidth: integer;
begin
  Result := Parent.Width;
end;

procedure tPrintSection.Next;
begin
  // create a new page
  Header.Print;
  Footer.Print;
end;

function tPrintSection.Print : boolean;
var
  iColumn, iHeight, iWidth : integer;
  iStat : tPrintLineResponse;
begin
  Result := FALSE; // assume done
  fCurrentColumn := 0;
  // if we don't have headers or footers yet, create defaults
  if not assigned( fHeader ) then
  begin
    fHeader := tPrintHeader.Create( self );
  end;
  if not assigned( fFooter ) then
  begin
    fFooter := tPrintFooter.Create( self );
  end;

  Header.Print;
  Footer.Print;
  iColumn := 0;
  iStat := plrOK;
  if Count > 0 then
  begin
    while not (iStat = plrDone) do
    begin
      iStat := plrDone;
      case Column[ iColumn ].CanPrintLine( iHeight, iWidth ) of
        plrNoRoom:
        begin
          Next;
        end;
      end;

      case Column[ iColumn ].PrintLine( iHeight, iWidth ) of
        plrOK:
        begin
          iStat := plrOK;
        end;
        plrDone:
        begin

        end;
        plrNoRoom:
        begin
          iStat := plrNoRoom; //
        end;
      end;

      inc( iColumn );
      if iColumn >= Count then
      begin
        iColumn := 0;
      end;
    end;
  end;
end;

function tPrintSection.PrintLine(var pHeight, pWidth: integer): tPrintLineResponse;
var
  i, iHeight, iWidth: integer;
begin
  Result := plrDone;
  for i := 0 to Count - 1 do
  begin
    case Column[ i ].CanPrintLine( iHeight, iWidth ) of
      plrOK:
      begin
        Result := plrOK;
      end;
      plrDone: ;
      plrNoRoom:
      begin
        Result := plrNoRoom;
        break;
      end;
    end;
  end;
  case Result of
    plrOK: ;
    plrDone:
    begin
      exit;
    end;
    plrNoRoom:
    begin
      Next;
    end;
  end;
  pHeight := 0; pWidth := Width;
  for i := 0 to Count - 1 do
  begin
    case Column[ i ].PrintLine( iHeight, iWidth ) of
      plrOK:
      begin
        if iHeight > pHeight then
        begin
          pHeight := iHeight;
        end;
      end;
      plrDone: ;
      plrNoRoom:
      begin
        Result := plrNoRoom; // should not get here!
      end;
    end;
  end;
  CurrentTop := CurrentTop + pHeight;
  pHeight := 0;
  pWidth := Width;
  {
  for i := 0 to Count - 1 do
  begin
    Column[ i ].CurrentTop := Column[ i ].CurrentTop + iHeight;
  end;
  }
end;

procedure tPrintSection.SetColumnWidth(const i, Value: integer);
var
  iColWidth : integer;
  iColWidthLeft : integer;
  iColsLeft : integer;
  iLeft : integer;
  j : integer;
begin
  // in changing a column width we must adjust other columns
  iColsLeft := 0;
  if Count < 2 then
  begin
    raise exception.Create( 'Single column report. Column widths cannot be set by ColumnWidths property' )
  end;
  for j := 0 to Count - 1 do
  begin
    if (not Column[ j ].WidthSet) and (j <> i) then
    begin
      inc( iColsLeft );
    end;
  end;
  if iColsLeft = 0 then
  begin
    // all modified - change all
    iColsLeft := Count - 1;
    for j := 0 to Count - 1 do
    begin
      Column[ j ].WidthSet := FALSE;
    end;
  end;
  iLeft := Column[ 0 ].Left;
  iColWidthLeft := Column[ i ].Width - Value; // could be negative!
  for j := 0 to Count - 1 do
  begin
    iColWidth := iColWidthLeft div iColsLeft;
    with Column[ j ] do
    begin
      if i = j then
      begin
        Left := iLeft;
        Width := Value;  // implicit set of WidthSet
        inc( iLeft, Value );
      end
      else if WidthSet then
      begin
        inc( iLeft, Width );
      end
      else
      begin
        inc( iColWidth, Width );
        Left := iLeft;
        Width := iColWidth;
        inc( iLeft, iColWidth );
        dec( iColWidthLeft, iColWidth );
        dec( iColsLeft );
        WidthSet := FALSE;
      end;
    end;
  end;
end;

procedure tPrintSection.SetNeedsNewPage(const Value: boolean);
begin
  ParentReport.NeedsNewPage := Value;
end;

{ tPrintArea }

function tPrintArea.CentreText(const Text: string; var pHeight : integer; var pWidth : integer  ) : boolean;
begin
  StartPrintActivity;
  pHeight := Canvas.TextHeight( Text );
  pWidth := Canvas.TextWidth( Text );
  Result := (pWidth <= Width) and ((CurrentTop + pHeight) <= Bottom );
  if Result then
  begin
    if TextVisible then
    begin
      Canvas.TextOut( Left + (Width - pWidth) div 2, CurrentTop, Text );
    end;
  end;
  CompletePrintActivity;
end;

function tPrintArea.Add(Value: tPrintArea): integer;
begin
  Result := inherited Add( Value );
end;

function tPrintArea.CentreText(const Text: string): boolean;
var
  iWidth, iHeight : integer;
begin
  Result := CentreText( Text, iHeight, iWidth );
end;

procedure tPrintArea.CompletePrintActivity;
var
  iFont : tFont;
begin
  iFont := SaveFont.Pop;
  PreviewPrinter.Canvas.Font.Assign( iFont );
  iFont.Free;
end;

constructor tPrintArea.Create(AParent: tPrintArea);
begin
  inherited Create();
  fParent := AParent;

end;

destructor tPrintArea.Destroy;
begin
  inherited;
end;

function tPrintArea.GetBottom: integer;
begin
  Result := Parent.Bottom;
end;

function tPrintArea.GetCalculatingPages: boolean;
begin
  Result := ParentReport.CalculatingPages;
end;

function tPrintArea.GetCanvas: tCanvas;
begin
  Result := PreviewPrinter.Canvas;
end;

function tPrintArea.GetCurrentPage: integer;
begin
  Result := ParentReport.CurrentPage;
end;

function tPrintArea.GetCurrentTop: integer;
begin
  Result := Parent.CurrentTop;
end;

function tPrintArea.GetFont: tFont;
begin
  Result := PreviewPrinter.Canvas.Font;
end;

function tPrintArea.GetHeight: integer;
begin
  Result := Bottom - Top;
end;

function tPrintArea.GetLeft: integer;
begin
  Result := Parent.Left;
end;

function tPrintArea.GetPageCount: integer;
begin
  Result := ParentReport.PageCount;
end;

function tPrintArea.GetParentReport: tPrintReport;
var
  iParent : tPrintArea;
begin
  iParent := Parent;
  while assigned( iParent ) do
  begin
    if iParent is tPrintReport then
    begin
      Result := iParent as tPrintReport;
      exit;
    end
    else
    begin
      iParent := iParent.Parent;
    end;
  end;
  Result := nil;
end;

function tPrintArea.GetParentSection: tPrintSection;
var
  iParent : tPrintArea;
begin
  iParent := Parent;
  while assigned( iParent ) do
  begin
    if iParent is tPrintSection then
    begin
      Result := iParent as tPrintSection;
      exit;
    end
    else
    begin
      iParent := iParent.Parent;
    end;
  end;
  Result := nil;
end;

function tPrintArea.GetPreviewPrinter: tPreviewPrinter;
begin
  Result := ParentReport.PreviewPrinter;
end;

function tPrintArea.GetPrintArea(const i: integer): tPrintArea;
begin
  Result := Items[ i ] as tPrintArea;
end;

function tPrintArea.GetRight: integer;
begin
  Result := Parent.Right;
end;

function tPrintArea.GetSaveFont: tFontStack;
begin
  Result := Parent.SaveFont;
end;

function tPrintArea.GetTextVisible: boolean;
begin
  Result := Parent.TextVisible;
end;

function tPrintArea.GetTop: integer;
begin
  Result := Parent.Top;
end;

function tPrintArea.GetWidth: integer;
begin
  Result := Right - Left;
end;

function tPrintArea.LeftJustifyText(const Text: string): boolean;
var
  iWidth, iHeight : integer;
begin
  Result := LeftJustifyText( Text, iHeight, iWidth );
end;

procedure tPrintArea.Next;
begin
  Parent.Next;
end;

function tPrintArea.LeftJustifyText(const Text: string; var pHeight,
  pWidth: integer): boolean;
begin
  StartPrintActivity;
  pHeight := TextHeight( Text );
  pWidth := TextWidth( Text );
  Result := (pWidth <= Width) and ((CurrentTop + pHeight) <= Bottom );
  if Result then
  begin
    if TextVisible then
    begin
      Canvas.TextOut( Left, CurrentTop, Text );
    end;
  end;
  CompletePrintActivity;
end;

function tPrintArea.Print: boolean;
begin
  //CurrentTop := Top;
  Result := TRUE; // done!
end;

function tPrintArea.RightJustifyText(const Text: string): boolean;
var
  iWidth, iHeight : integer;
begin
  Result := RightJustifyText( Text, iHeight, iWidth );
end;

function tPrintArea.RightJustifyText(const Text: string; var pHeight,
  pWidth: integer): boolean;
begin
  pHeight := TextHeight( Text );
  pWidth := TextWidth( Text );
  Result := (pWidth <= Width) and ((CurrentTop + pHeight) <= Bottom );
  if Result then
  begin
    if TextVisible then
    begin
      Canvas.TextOut( Right - pWidth, CurrentTop, Text );
    end;
  end;
end;

procedure tPrintArea.SetCalculatingPages(const Value: boolean);
begin
  ParentReport.CalculatingPages := Value;
end;

procedure tPrintArea.SetCurrentPage(const Value: integer);
begin
  Parent.CurrentPage := Value;
end;

procedure tPrintArea.SetCurrentTop(const Value: integer);
begin
  Parent.CurrentTop := Value;
end;

procedure tPrintArea.SetupPrint;
var
  i: Integer;
begin
  // by default pass down to children.
  // decendants will generally call inherited AFTER
  // any local assignments
  for i := 0 to Count - 1 do
  begin
    PrintArea[ i ].SetupPrint;
  end;
end;

procedure tPrintArea.StartPrintActivity;
var
  iFont : tFont;
begin
  iFont := tFont.Create;
  iFont.Assign( PreviewPrinter.Canvas.Font );
  SaveFont.Push( iFont );
end;

function tPrintArea.TextHeight(const Text: string): integer;
begin
  Result := PreviewPrinter.Canvas.TextHeight( Text );
end;

function tPrintArea.TextWidth(const Text: string): integer;
begin
  Result := PreviewPrinter.Canvas.TextWidth( text );
end;

{ tPrintHeader }

function tPrintHeader.CanPrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  Result := plrDone;
end;

constructor tPrintHeader.Create(AParent: tPrintArea);
begin
  inherited;
  Height := 0;
end;

function tPrintHeader.GetBottom: integer;
begin
  Result := fBottom;
end;

function tPrintHeader.GetTop: integer;
begin
  Result := PreviewPrinter.OffsetY;
end;

function tPrintHeader.Print: boolean;
begin
  ParentReport.CurrentPage := ParentReport.CurrentPage + 1;
  if TextVisible then
  begin
    if ParentReport.NeedsNewPage then
    begin
      PreviewPrinter.NewPage;     // first page does not need NewPage action
    end
    else
    begin
      ParentReport.NeedsNewPage := TRUE;
    end;
  end;
  CurrentTop := Bottom; // parent's current top area corresponds to our bottom

  Result := inherited Print;
end;

function tPrintHeader.PrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  Result := plrDone;
end;

procedure tPrintHeader.SetHeight(const Value: integer);
begin
  fBottom := Top + Value;
end;

{ tPrintFooter }

function tPrintFooter.CanPrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  Result := plrDone;
end;

constructor tPrintFooter.Create(AParent: tPrintArea);
begin
  inherited;
  Height := 0;
end;

function tPrintFooter.GetBottom: integer;
begin
  Result := ParentReport.Bottom;
end;

function tPrintFooter.GetCurrentTop: integer;
begin
  Result := fCurrentTop;
end;

function tPrintFooter.GetParentReport: tPrintReport;
begin
  Result := Parent.ParentReport;
end;

function tPrintFooter.GetTop: integer;
begin
  Result := fTop;
end;

function tPrintFooter.PrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  Result := plrDone;
end;

procedure tPrintFooter.SetCurrentTop(const Value: integer);
begin
  fCurrentTop := Value;
end;

procedure tPrintFooter.SetHeight(const Value: integer);
begin
  fTop := ParentReport.Bottom - Value;
end;

{ tPrintColumn }

constructor tPrintColumn.Create(AParent: tPrintArea);
begin
  inherited;
  Width := 0;
  WidthSet := FALSE;
end;

function tPrintColumn.GetBottom: integer;
begin
  Result := ParentSection.Footer.Top;
end;

function tPrintColumn.GetTop: integer;
begin
  Result := ParentSection.Header.Bottom;
end;

function tPrintColumn.GetWidth: integer;
begin
  if WidthSet then
  begin
    Result := fWidth;
  end
  else
  begin
    Result := inherited;
  end;
end;

procedure tPrintColumn.Next;
begin
  if WidthSet then
  begin
    if (fRight + fWidth) <= Parent.Right then
    begin
      fLeft := fLeft + fWidth;
      fRight := fRight + fWidth;
    end
    else
    begin
      fLeft := Parent.Left;
      fRight := fLeft + fWidth;
      fParent.Next; // parent may reset our left, right or width. The above values are just defaults
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure tPrintColumn.SetWidth(const Value: integer);
begin
  if (fLeft + Value) <= Parent.Right then
  begin
    fRight := fLeft + Value;
    fWidth := Value;
    fWidthSet := TRUE;
  end;
end;

{ tFontStack }

function tFontStack.Peek: TFont;
begin
  Result := inherited Peek as TFont;
end;

function tFontStack.Pop: TFont;
begin
  Result := inherited Pop as TFont;
end;

function tFontStack.Push(AObject: TFont): TFont;
begin
  Result := inherited Push( AObject ) as tFont;
end;

{ tWrappableSection }

constructor tWrappableSection.Create(AParent: tPrintArea);
begin
  inherited;
  fColCount := 1;
end;

function tWrappableSection.GetColumnWidth(const i: integer): integer;
begin
  Result := inherited div fColCount;
end;

function tWrappableSection.GetLeft: integer;
begin
  Result := Parent.Left + (fCurrCol * Width);
end;

function tWrappableSection.GetWidth: integer;
begin
  Result := Parent.Width div fColCount;
end;

procedure tWrappableSection.Next;
begin

  inc (fCurrCol );
  if fCurrCol >= fColCount then
  begin
    fCurrCol := 0;
  end;

  inherited;

end;

function tWrappableSection.Print : boolean;
begin
  fCurrCol := 0;
  Result := inherited;
end;

{ tPrintSubheader }

function tPrintSubheader.CanPrintLine( var pHeight, pWidth : integer ): tPrintLineResponse;
begin
  pWidth := Width;
  pHeight := 3 * TextHeight( Text );
  if (CurrentTop + pHeight) <= Bottom then
  begin
    Result := plrOK;
  end
  else
  begin
    Result := tPrintLineResponse.plrNoRoom;
  end;

end;

constructor tPrintSubheader.Create(AParent: tPrintArea);
begin
  inherited;
  OverlineThickness := 3;
  UnderlineThickness := 2;
  MarginPC := 5;
end;

function tPrintSubheader.GetWidth: integer;
begin
  Result := ParentSection.ColumnWidth[ ParentSection.CurrentColumn ];
end;

function tPrintSubheader.PrintLine( var pHeight, pWidth : integer ): tPrintLineResponse;
var
  iLineHeight, iLeft, iRight : integer;
  iUnderlineThickness : integer;
  iSavePenThickness : integer;
begin
  Result := plrDone;
  StartPrintActivity;
  iSavePenThickness := Canvas.Pen.Width;
  Font.Style := [ fsBold ];

  iLineHeight := TextHeight( Text );
  iLeft := Left + ((Width * MarginPC ) div 100 );
  iRight := Left + Width - ((Width * MarginPC ) div 100 );
  if OverLineThickness > 0 then
  begin
    if TextVisible then
    begin
      Canvas.Pen.Width := OverLineThickness;
      Canvas.MoveTo( iLeft, CurrentTop + ((iLineHeight - OverlineThickness) div 2));
      Canvas.LineTo( iRight, CurrentTop + ((iLineHeight - OverlineThickness) div 2));
    end;
  end;
  CurrentTop := CurrentTop + iLineHeight;
  CentreText( Text );
  CurrentTop := CurrentTop + iLineHeight;
  if UnderlineThickness = 0 then
  begin
    iUnderLineThickness := OverLineThickness;
  end
  else
  begin
    iUnderLineThickness := UnderLineThickness;
  end;
  if iUnderlineThickness > 0 then
  begin
    if TextVisible then
    begin
      Canvas.Pen.Width := iUnderLineThickness;
      Canvas.MoveTo( iLeft, CurrentTop + ((iLineHeight - iUnderlineThickness) div 2));
      Canvas.LineTo( iRight, CurrentTop + ((iLineHeight - iUnderlineThickness) div 2));
    end;
  end;

  CurrentTop := CurrentTop + iLineHeight;

  Canvas.Pen.Width := iSavePenThickness;
  pWidth := Width;
  pHeight := 0; // already incremented
  CompletePrintActivity;
end;

{ tPrintBox }

function tPrintBox.CanPrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  pHeight := 2 * TextHeight( Text );
  if (CurrentTop + pHeight) > Parent.Bottom then
  begin
    Result := plrNoRoom;
  end
  else
  begin
    Result := plrOK;
  end;
end;

constructor tPrintBox.Create(AParent: tPrintArea);
begin
  inherited;
  LineThickness := 2;
end;

function tPrintBox.GetLeft: integer;
begin
  Result := fLeft;
end;

function tPrintBox.GetRight: integer;
begin
  Result := fRight;
end;

function tPrintBox.PrintLine(var pHeight, pWidth: integer): tPrintLineResponse;
var
  iLineHeight : integer;
  iSavePenThickness : integer;
  iSaveTop : integer;
begin
  Result := plrOK;
  StartPrintActivity;
  iSavePenThickness := Canvas.Pen.Width;

  pWidth := fRight - fLeft;

  iLineHeight := TextHeight( Text );
  pHeight := 2 * iLineHeight;
  if LineThickness > 0 then
  begin
    if TextVisible then
    begin
      Canvas.Pen.Width := LineThickness;
      Canvas.MoveTo( fLeft, CurrentTop );
      Canvas.LineTo( fRight, CurrentTop );
      Canvas.LineTo( fRight, CurrentTop + 2 * iLineHeight);
      Canvas.LineTo( fLeft, CurrentTop + 2 * iLineHeight);
      Canvas.LineTo( fLeft, CurrentTop );
    end;
  end;
  iSaveTop := CurrentTop;
  CurrentTop := CurrentTop + iLineHeight Div 2;
  CentreText( Text );
  CurrentTop := iSaveTop;

  Canvas.Pen.Width := iSavePenThickness;
  CompletePrintActivity;
end;

procedure tPrintBox.SetMaxWidth(const Value: integer);
begin
  if Value > fMaxWidth then
  begin
    fMaxWidth := Value;
  end;
end;

procedure tPrintBox.SetText(const Value: string);
begin
  fText := Value;
  if CalculatingPages then
  begin
    MaxWidth := TextWidth( fText );
  end;
end;

procedure tPrintBox.SetupPrint;
begin
  fMaxWidth := 0;

  inherited;

end;

{ tPrintTable }

constructor tPrintTable.Create(AParent: tPrintArea);
begin
  inherited;
  fCells := tSigSparseTable.Create;
end;

destructor tPrintTable.Destroy;
begin
  fCells.Free;
  inherited;
end;

{ tPrintVirtualTable }

constructor tPrintVirtualTable.Create(AParent: tPrintArea);
begin
  inherited;
  fTitles := tStringList.Create;
end;

destructor tPrintVirtualTable.Destroy;
begin
  fTitles.Free;
  inherited;
end;

{ tPrintEMapTable }

function tPrintEMapTable.CanPrintHeaderLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  pHeight := 4 * TextHeight( 'X' );
  if fLine >= fEMapList.Max then
  begin
    Result := plrDone;
  end
  else if (CurrentTop + pHeight ) > Bottom then
  begin
    Result := plrNoRoom;
  end
  else
  begin
    Result := plrOK;
  end;
end;

function tPrintEMapTable.CanPrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  pHeight := 2 * TextHeight( 'X' );
  if fLine >= fEMapList.Max then
  begin
    Result := plrDone;
  end
  else if (CurrentTop + pHeight ) > Bottom then
  begin
    Result := plrNoRoom;
  end
  else
  begin
    Result := plrOK;
  end;
end;

constructor tPrintEMapTable.Create(AParent: tPrintArea;
  pEMapList: tSigEnumMapList);
begin
  inherited Create( AParent );
  fEMapList := pEMapList;
end;

function tPrintEMapTable.Print: boolean;
var
  iWidth, iHeight : integer;
begin
  // this can be used as a basis for printline based outputs
  if fEMapList.Max >= 0 then
  begin
    // don't print empty table
    fLine := 0;
    if CanPrintHeaderLine( iHeight, iWidth ) = plrNoRoom then
    begin
      Parent.Next;
    end;
    PrintHeaderLine( iHeight, iWidth );
    CurrentTop := CurrentTop + iHeight;
  end;
  Result := FALSE;
end;

function tPrintEMapTable.PrintHeaderLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
begin
  fVisBox.Text := fEMapList.VisibleColHeader.Value;
  if fVisBox.Text = '' then
  begin
    fVisBox.Text := 'Vis.';
  end
  else if StrToIntDef( fVisBox.Text, -1 ) <> -1  then
  begin
    fVisBox.Text := 'Vis.';
  end;
  fIDBox.Text := fEMapList.IDColHeader.Value;
  if fIDBox.Text = ''  then
  begin
    fIDBox.Text := 'ID';
  end
  else if StrToIntDef( fIDBox.Text, -1 ) <> -1  then
  begin
    fIDBox.Text := 'ID';
  end;
  fValueBox.Text := fEMapList.NameColHeader.Value;
  if fValueBox.Text = ''  then
  begin
    fValueBox.Text := 'Name';
  end
  else if StrToIntDef( fValueBox.Text, -1 ) <> -1  then
  begin
    fValueBox.Text := 'Name';
  end;
  fVisBox.PrintLine( pHeight, pWidth );
  fIDBox.PrintLine( pHeight, pWidth );
  fValueBox.PrintLine( pHeight, pWidth );
  Result := plrOK;
end;

function tPrintEMapTable.PrintLine(var pHeight,
  pWidth: integer): tPrintLineResponse;
var
  iTotalWidth, iWidth : integer;
begin
  // if current line is 0, and we are not calculating pages we set out
  // our tabs
  if fLine >= fEMapList.Max then
  begin
    Result := plrDone;
    fLine := 0;
  end
  else if (CurrentTop + pHeight ) > Bottom then
  begin
    Result := plrNoRoom;
  end
  else
  begin
    if fLine = 0 then
    begin
      if TextVisible then
      begin
        iWidth := (Parent.Width * (100 - 2 * fMarginPC )) div 100;
        iTotalWidth := fVisBox.MaxWidth + fIDBox.MaxWidth + fValueBox.MaxWidth;
        // total width cannot be 0 because of titles.
        fVisBox.Left := Left + (Parent.Width * fMarginPC ) div 100;
        fVisBox.Right := fVisBox.Left + ((iWidth * fVisBox.MaxWidth) div iTotalWidth );
        fIDBox.Left := fVisBox.Right;
        fIDBox.Right := fIDBox.Left + ((iWidth * fIDBox.MaxWidth) div iTotalWidth );
        fValueBox.Left := fIDBox.Right;
        fValueBox.Right := fValueBox.Left + ((iWidth * fValueBox.MaxWidth) div iTotalWidth );
      end;
    end;

    fVisBox.Text := fEMapList.Map[ fLine ].Visible.Value;
    fIDBox.Text := fEMapList.Map[ fLine ].Enum.Value;
    fValueBox.Text := fEMapList.Map[ fLine ].EnumName.Value;
    fVisBox.PrintLine( pHeight, pWidth );
    fIDBox.PrintLine( pHeight, pWidth );
    fValueBox.PrintLine( pHeight, pWidth );

    inc( fLine );

    Result := plrOK;
  end;
end;

procedure tPrintEMapTable.SetMarginPC(const Value: integer);
begin
  fMarginPC := Value;
end;

end.
