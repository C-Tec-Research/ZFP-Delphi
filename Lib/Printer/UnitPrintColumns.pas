unit UnitPrintColumns;

interface

uses
  System.Classes,
  PrevPrinter,
  Contnrs,
  Graphics,
  SysUtils,
  StrUtils
;

type
  tOnTranslate = function ( const s : string ) : string of object;

  TTabs = class;

  TTab = class
  private
    fWidth: integer;
    fFont: tFont;
    fOwner: TTabs;
  public
    constructor Create( pOwner : TTabs );
    destructor Destroy; override;
    property Width : integer
             read fWidth
             write fWidth;
    property Font : tFont
             read fFont;
    property Owner : TTabs
             read fOwner;
  end;

  TTabs = class( tObjectList )
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

  TPrintColumn = class
  private
    fRight: integer;
    fLeft: integer;
    fTabs: tTabs;
    fWrap: boolean;
    fHangingIndent: integer;
    fLeftMargin: integer;
    fRightMargin: integer;
    function GetClientWidth: integer;
    function GetWidth: integer;
    function GetLeftMargin: integer;
    function GetRightMargin: integer;
    function GetLeft: integer;
    function GetRight: integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Left : integer                 // When we write, we exclude margins. When we read we include them
             read GetLeft
             write fLeft;
    property Right : integer
             read GetRight
             write fRight;
    property Tabs : tTabs
             read fTabs;
    property Wrap : boolean
             read fWrap
             write fWrap;
    property HangingIndent : integer
             read fHangingIndent
             write fHangingIndent;
    property LeftMargin : integer
             read GetLeftMargin             // if not overridden (i.e. if 0) assume 1% of width
             write fLeftMargin;
    property RightMargin : integer
             read GetRightMargin
             write fRightMargin;
    property Width : integer              // excluding margins
             read GetWidth;
    property ClientWidth : integer        // including margins
             read GetClientWidth;
  end;

  TPrintColumns = class( tObjectList )
  private
    fColumnCount: integer;
    fPageLeft: integer;
    fPageRight: integer;
    fPrinter: TPreviewPrinter;
    fFont: tFont;
    fSaveFont: tFont;
    fCurrCol: integer;
    fCalculatingPageCount: boolean;
    fPrintPos: integer;
    fHalfLineSpacing: integer;
    fPageNo: integer;
    fFooterFont: tFont;
    fPageCount: integer;
    fFooterTop: integer;
    fHeaderText : string;
    fSubHeaderText : string;
    fHeaderBottom: integer;
    fOnTranslate: tOnTranslate;
    procedure SetColumnCount(const Value: integer);
    procedure SetPageLeft(const Value: integer);
    procedure SetPageRight(const Value: integer);
    procedure SetPrinter(const Value: TPreviewPrinter);
    procedure SetPrintPos(const Value: integer);
    procedure SetPageNo(const Value: integer);
    function GetColumn(const i: integer): tPrintColumn;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure RecalcCols;
    procedure TextOut(const Text: string); overload;
    procedure TextOut( const Text: array of string); overload;
    procedure TextOut( const X,Y : integer; const Text: string); overload;
    procedure TextOut( const X : integer; const Text: string; SkipCount : integer = -1 ); overload;
    procedure PrintFooter;
    procedure PrintHeader( const HeaderText : string = '' );
    procedure PrintSubHeader( const SubHeaderText : string = '' );
    procedure SkipHalfLine( const pCount : integer = 1 );

    function TextWidth( const s : string ) : integer;
    function TextHeight( const s : string ) : integer;

    function Translate( const s : string ) : string;
    function CurrLeft : integer;
    function WrapText : boolean;
    function HangingIndent : integer;
    function CurrWidth : integer;

    property ColumnCount : integer
             read fColumnCount
             write SetColumnCount;
    property PageLeft : integer
             read fPageLeft
             write SetPageLeft;
    property PageRight : integer
             read fPageRight
             write SetPageRight;
    property Printer : TPreviewPrinter
             read fPrinter
             write SetPrinter;
    property Font : tFont
             read fFont;
    property FooterFont : tFont
             read fFooterFont;
    property CurrCol : integer
             read fCurrCol;
    property CalculatingPageCount : boolean
             read fCalculatingPageCount
             write fCalculatingPageCount;
    property PageCount : integer
             read fPageCount
             write fPageCount;
    property PrintPos : integer
             read fPrintPos
             write SetPrintPos;
    property HalfLineSpacing : integer
             read fHalfLineSpacing
             write fHalfLineSpacing;
    property CurrPageNo : integer
             read fPageNo
             write SetPageNo;
    property FooterTop : integer
             read fFooterTop
             write fFooterTop;
    property HeaderBottom : integer
             read fHeaderBottom
             write fHeaderBottom;
    property Column[ const i : integer ] : tPrintColumn
             read GetColumn;

    property OnTranslate : tOnTranslate
             read fOnTranslate
             write fOnTranslate;
  end;


implementation

{ TPrintColumns }

constructor TPrintColumns.Create;
begin
  inherited Create( TRUE );
  fColumnCount := 0;
  fFont:= tFont.Create;
  fSaveFont:= tFont.Create;
  fFooterFont:= tFont.Create;
  fHalfLineSpacing := 3;
end;

function TPrintColumns.CurrLeft: integer;
begin
  Result := Column[ fCurrCol ].Left;
end;

function TPrintColumns.CurrWidth: integer;
begin
  Result := Column[ fCurrCol ].Right - Column[ fCurrCol ].Left;
end;

destructor TPrintColumns.Destroy;
begin
  fFont.Free;
  fSaveFont.Free;
  fFooterFont:= tFont.Create;
  inherited;
end;

function TPrintColumns.GetColumn(const i: integer): tPrintColumn;
begin
  Result := Items[ i ] as tPrintColumn;
end;

function TPrintColumns.HangingIndent: integer;
begin
  Result := Column[ fCurrCol ].HangingIndent;
end;

procedure TPrintColumns.PrintFooter;
var
  ileft : integer;
  iFooterText : string;
begin
  {
    Always print the footer first if a new page is required, then print
    the header if required. This is to make sure that PrintPos is set to
    the right value.
  }
  CurrPageNo := CurrPageNo + 1;
  if not CalculatingPageCount then
  begin
    if CurrPageNo <> 1 then
    begin
      fPrinter.NewPage;
    end;
    with fPrinter.Canvas do
    begin
      fSaveFont.Assign( Font );
      Font.Assign( FooterFont );
      iFooterText := Translate('Page') + ' ' + IntToStr( CurrPageNo ) + ' ' + Translate('of') + ' ' + IntToStr( PageCount );
      fPrintPos := FooterTop + TextHeight( iFooterText );
      iLeft := (fPrinter.PageWidth - TextWidth( iFooterText )) div 2;
      TextOut( iLeft, fPrintPos, iFooterText );
      Font.Assign( fSaveFont );
    end;
  end;

  PrintPos := fPrinter.OffsetY;

end;

procedure TPrintColumns.PrintHeader(const HeaderText: string);
var
  iLeft : integer;
begin
  if HeaderText <> '' then
  begin
    fHeaderText := HeaderText;
  end;

  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Size := 2 * Font.Size;
    Font.Style := [ fsBold ];

    if not CalculatingPageCount then
    begin
      iLeft := (fPrinter.PageWidth - TextWidth( fHeaderText )) div 2;
      TextOut( iLeft, PrintPos, fHeaderText );
    end;

    PrintPos := PrintPos + 2 * TextHeight( fHeaderText );

    if not CalculatingPageCount then
    begin
      MoveTo( fPrinter.OffsetX, PrintPos );
      LineTo( fPrinter.PageWidth - fPrinter.OffsetY, PrintPos )
    end;

    Font.Assign( fSaveFont );

    PrintPos := PrintPos + TextHeight( fHeaderText );

  end;
end;

procedure TPrintColumns.PrintSubHeader(const SubHeaderText: string);
var
  iLeft : integer;
begin
  if SubHeaderText <> '' then
  begin
    fSubHeaderText := SubHeaderText;
  end;

  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Size := (3 * Font.Size) div 2;
    Font.Style := [ fsBold ];

    if not CalculatingPageCount then
    begin
      iLeft := (fPrinter.PageWidth - TextWidth( fSubHeaderText )) div 2;
      TextOut( iLeft, PrintPos, fSubHeaderText );
    end;

    PrintPos := PrintPos + 2 * TextHeight( fSubHeaderText );

    Font.Assign( fSaveFont );
  end;
end;

procedure TPrintColumns.RecalcCols;
var
  i: Integer;
  iCol, iLastCol : tPrintColumn;
  iPageWidth : integer;
begin
  Clear;
  if ColumnCount > 0 then
  begin
    iLastCol := nil;
    iPageWidth := PageRight - PageLeft;
    for i := 0 to ColumnCount - 1 do
    begin
      iCol := tPrintColumn.Create;
      Add( iCol );
      iCol.Left := PageLeft + (i * iPageWidth ) div ColumnCount;
      if assigned( iLastCol ) then
      begin
        iLastCol.Right := iCol.Left - 1;
      end;
      iLastCol := iCol;
    end;
    iLastCol.Right := PageRight - 1;
  end;
  fCurrCol := 0;
end;

procedure TPrintColumns.SetColumnCount(const Value: integer);
begin
  if fColumnCount <> Value then
  begin
    fColumnCount := Value;
    RecalcCols;
  end;
end;

procedure TPrintColumns.SetPageLeft(const Value: integer);
begin
  if fPageLeft <> Value then
  begin
    fPageLeft := Value;
    RecalcCols;
  end;
end;

procedure TPrintColumns.SetPageNo(const Value: integer);
begin
  fPageNo := Value;
  if fPageNo > fPageCount then
  begin
    fPageCount := fPageNo;
  end;
end;

procedure TPrintColumns.SetPageRight(const Value: integer);
begin
  if fPageRight <> Value then
  begin
    fPageRight := Value;
    RecalcCols;
  end;
end;

procedure TPrintColumns.SetPrinter(const Value: TPreviewPrinter);
begin
  if fPrinter <> Value then
  begin
    fPrinter := Value;
    if assigned( fPrinter ) then
    begin
      fPageLeft := fPrinter.OffsetX;
      fPageRight := fPageLeft + fPrinter.PageWidth;
      fFont.Assign( fPrinter.Canvas.Font );
      fFooterFont.Assign( fPrinter.Canvas.Font );
      RecalcCols;
    end;
  end;
end;

procedure TPrintColumns.SetPrintPos(const Value: integer);
begin
  fPrintPos := Value;
  if Value > fFooterTop then
  begin
    PrintFooter;
    PrintHeader;
  end;
end;

procedure TPrintColumns.SkipHalfLine(const pCount: integer);
begin
  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Assign( fFont );
    PrintPos := PrintPos + ((pCount * TextHeight( 'X' )) div 2);
    Font.Assign( fSaveFont );
  end;
end;

function TPrintColumns.TextHeight(const s: string): integer;
begin
  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Assign( fFont );
    Result := TextHeight( s );
    Font.Assign( fSaveFont );
  end;
end;

procedure TPrintColumns.TextOut(const X, Y: integer; const Text: string);
begin
  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Assign( fFont );
    if not CalculatingPageCount then
    begin
      TextOut( X, Y, Text );
    end;
    Font.Assign( fSaveFont );
  end;
end;

function TPrintColumns.TextWidth(const s: string): integer;
begin
  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Assign( fFont );
    Result := TextWidth( s );
    Font.Assign( fSaveFont );
  end;
end;

function TPrintColumns.Translate(const s: string): string;
begin
  if assigned( fonTranslate ) then
  begin
    Result := fOnTranslate( s );
  end
  else
  begin
    Result := s;
  end;
end;

function TPrintColumns.WrapText: boolean;
begin
  Result := Column[ fCurrCol ].Wrap;
end;

procedure TPrintColumns.TextOut(const Text: string);
begin
  TextOut( 0, Text );
end;

procedure TPrintColumns.TextOut(const Text: array of string);
var
  i, iLeft, jLeft : integer;
  iWidth : integer;
  iCount : integer;
begin
  with fPrinter.Canvas do
  begin
    fSaveFont.Assign( Font );
    Font.Assign( fFont );
    if PrintPos + TextHeight( Text[ 0 ] ) > fFooterTop then
    begin
      inc( fCurrCol );
      if fCurrCol >= ColumnCount then
      begin
        fCurrCol := 0;
        PrintFooter;
        PrintHeader;
      end
      else
      begin
        PrintPos := fHeaderBottom;
      end;
    end;
    if not CalculatingPageCount then
    begin
      iCount := High( Text ) - Low( Text ) + 1;
      iLeft := Column[ fCurrCol ].Left;
      iWidth := Column[ fCurrCol ].Right - iLeft;
      for i := Low( Text ) to High( Text ) do
      begin
        jLeft := iLeft + (i * iWidth) div iCount;
        TextOut( jLeft, PrintPos, Text[ i ]);
      end;
    end;
    PrintPos := PrintPos + ((HalfLineSpacing * TextHeight( Text[ 0 ] )) div 2);
    Font.Assign( fSaveFont );
  end;
end;

procedure TPrintColumns.TextOut(const X: integer; const Text: string; SkipCount : integer = -1);
var
  iString1, iString2 : string;
  iIndent : integer;
  iPos, iPos2 : integer;
begin
  //with fPrinter.Canvas do
  begin
    fSaveFont.Assign( fPrinter.Canvas.Font );
    fPrinter.Canvas.Font.Assign( fFont );
    if PrintPos + fPrinter.Canvas.TextHeight( Text ) > fFooterTop then
    begin
      inc( fCurrCol );
      if fCurrCol >= ColumnCount then
      begin
        fCurrCol := 0;
        PrintFooter;
        PrintHeader;
      end
      else
      begin
        PrintPos := fHeaderBottom;
      end;
    end;
    if WrapText then
    begin
      iString2 := Text;
      iIndent := 0;
      while iString2 <> '' do
      begin
        if PrintPos + fPrinter.Canvas.TextHeight( Text ) > fFooterTop then
        begin
          inc( fCurrCol );
          if fCurrCol >= ColumnCount then
          begin
            fCurrCol := 0;
            PrintFooter;
            PrintHeader;
          end
          else
          begin
            PrintPos := fHeaderBottom;
          end;
        end;
        if fPrinter.Canvas.TextWidth( TrimRight(iString2) ) > CurrWidth - X - iIndent then
        begin
          iString1 := iString2;
          iString2 := '';
          iPos2 := 1;
          repeat
            iPos := iPos2;
            iPos2 := PosEx( ' ', iString1, iPos + 1 );
            if iPos2 > 0 then
            begin
              if fPrinter.Canvas.TextWidth( TrimRight(Copy( iString1, 1, iPos2 - 1))) > (CurrWidth - X - iIndent ) then
              begin
                iPos2 := 0;
              end;
            end;
          until iPos2 = 0;
          if iPos > 1 then
          begin
            iString2 := Trim( Copy( iString1, iPos + 1 ));
            iString1 := TrimRight(Copy( iString1, 1, iPos - 1));
          end;
          if not CalculatingPageCount then
          begin
            fPrinter.Canvas.TextOut( CurrLeft + X + iIndent, PrintPos, iString1 );
          end;
          iIndent := HangingIndent;
          PrintPos := PrintPos + ((HalfLineSpacing * fPrinter.Canvas.TextHeight( Text )) div 2);
        end
        else
        begin
          if not CalculatingPageCount then
          begin
            fPrinter.Canvas.TextOut( CurrLeft + X + iIndent, PrintPos, iString2 );
          end;
          PrintPos := PrintPos + ((HalfLineSpacing * fPrinter.Canvas.TextHeight( Text )) div 2);
          iString2 := '';
        end;
      end;
    end
    else
    begin
      if not CalculatingPageCount then
      begin
        fPrinter.Canvas.TextOut( CurrLeft + X, PrintPos, Text );
      end;
      PrintPos := PrintPos + ((HalfLineSpacing * fPrinter.Canvas.TextHeight( Text )) div 2);
    end;

    if SkipCount = -1 then
    begin
      PrintPos := PrintPos + ((HalfLineSpacing * fPrinter.Canvas.TextHeight( Text )) div 2);
    end
    else
    begin
      PrintPos := PrintPos + ((SkipCount * fPrinter.Canvas.TextHeight( Text )) div 2);
    end;
    fPrinter.Canvas.Font.Assign( fSaveFont );
  end;
end;

{ TTab }

constructor TTab.Create( pOwner : TTabs );
begin
  inherited Create;
  fFont := tFont.Create;
  fOwner := pOwner;
end;

destructor TTab.Destroy;
begin
  fFont.Free;
  inherited;
end;

{ TTabs }

constructor TTabs.Create;
begin
  inherited Create( TRUE );
end;

destructor TTabs.Destroy;
begin

  inherited;
end;

{ TPrintColumn }

constructor TPrintColumn.Create;
begin
  inherited Create;
  fTabs := tTabs.Create;
end;

destructor TPrintColumn.Destroy;
begin
  fTabs.Free;
  inherited;
end;

function TPrintColumn.GetClientWidth: integer;
begin
  Result := Width - LeftMargin - RightMargin;
end;

function TPrintColumn.GetLeft: integer;
begin
  Result := fLeft + LeftMargin;
end;

function TPrintColumn.GetLeftMargin: integer;
begin
  if fLeftMargin = 0 then
  begin
    Result := (Width + 25) div 50; // assume 2% equivalent to 2 chars on a 100 char line
  end
  else
  begin
    Result := fLeftMargin;
  end;
end;

function TPrintColumn.GetWidth: integer;
begin
  Result := fRight - fLeft;
end;

function TPrintColumn.GetRight: integer;
begin
  Result := fRight - RightMargin;
end;

function TPrintColumn.GetRightMargin: integer;
begin
  if fRightMargin = 0 then
  begin
    Result := (Width + 25) div 50; // assume 2%
  end
  else
  begin
    Result := fRightMargin;
  end;
end;

end.
