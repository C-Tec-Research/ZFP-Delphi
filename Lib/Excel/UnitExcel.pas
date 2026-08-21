unit UnitExcel;

interface

uses
  System.Generics.Collections,
  SysUtils,
  System.Variants,
  Winapi.Windows,
  ExcelConst,
  System.Win.ComObj;

type
  TDSMExcelApplication = class;

  TDSMExcelObject = class
  protected
    fExcelObject : Variant;
    fOwner: TDSMExcelApplication;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); virtual;
    property ExcelObject : variant
             read fExcelObject;

    class function ColIntToText( const pCol : integer ) : string;

    property Owner : TDSMExcelApplication
             read fOwner;

    function RangeText( const pLeft : string; const pTop : integer; const pRight : string; const pBottom : integer ): string; overload;
    function RangeText( const pLeft, pTop, pRight, pBottom : integer ): string; overload;
  end;

  TDSMExcelObjectList< T : TDSMExcelObject > = class( TObjectList< T > )
  protected
    fExcelObject : Variant;
    fOwner: TDSMExcelApplication;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); virtual;

    property ExcelObject : variant
             read fExcelObject;

    function ExcelCount : integer; // count in excel object which may be different to out count

    function Add : T; reintroduce; virtual;  // WARNING this is NOT valid for all types.
  end;

  TSeries = class( TDSMExcelObject )
  private
    function GetHasDataLabels: boolean;
    procedure SetHasDataLabels(const Value: boolean);
  public
    property HasDataLabels : boolean
             read GetHasDataLabels
             write SetHasDataLabels;
  end;

  TSeriesList = class( TDSMExcelObjectList< TSeries > )
  private
  public
    //constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); override;

    function Add : TSeries; override;
  end;

  TDSMChart = class( TDSMExcelObject )
  private
//    Result := ExcelObject.SeriesCollection;

    fSeriesList: TSeriesList;
    function GetChartType: integer;
    procedure SetChartType(const Value: integer);
    function GetSeries(const i: integer): TSeries;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); override;
    destructor Destroy; override;
    property SeriesList : TSeriesList
             read fSeriesList;
    property Series[ const i : integer ] : TSeries
             read GetSeries;

    property ChartType : integer
             read GetChartType
             write SetChartType;

    procedure SetSourceData( const pRange : variant ); // overload;
  end;

  TDSMExcelChartObject = class( TDSMExcelObject )
  private
    fChart: TDSMChart;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); override;
    destructor Destroy; override;
    property Chart : TDSMChart
             read fChart;
  end;

  TDSMExcelCharts = class( TDSMExcelObject )
  public
    function Add( const Left, Top, Width, Height : double ) : TDSMExcelChartObject;
  end;

  TDSMWorksheet = class;

  TDSMWorksheetCharts = class( TDSMExcelCharts )
  private
    fWorksheet: TDSMWorksheet;
  public
    constructor Create( const pWorksheet : TDSMWorksheet ); reintroduce;
    destructor Destroy; override;

    property Worksheet : TDSMWorksheet
             read fWorksheet;
  end;

  TDSMWorksheet = class( TDSMExcelObject )
  private
    fCharts: TDSMWorksheetCharts;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); override;
    destructor Destroy; override;

    procedure SetCell( const pCol, pRow : string; const pVal : string ); overload;
    procedure SetCell( const pCol, pRow : integer; const pVal : string ); overload;

    property Charts : TDSMWorksheetCharts
             read fCharts;

    function Range( const pRange : string ) : variant; overload;
    function Range( const pCol : string; const pRow : integer ) : variant; overload;
    function Range( const pCol : integer; const pRow : integer ) : variant; overload;
    function Range( const pLeft : string; const pTop : integer; const pRight : string; const pBottom : integer ) : variant; overload;
    function Range( const pLeft : integer; const pTop : integer; const pRight : integer; const pBottom : integer ) : variant; overload;
  end;

(*
  TDSMExcelWorkbook = class( TDSMExcelObject )
  private
    //fWorkbook : Variant;
    fIndex: integer;
  public

    property Index : integer
             read fIndex
             write fIndex;
  end;
*)

  //TDSMExcelWorkbookList = class( TObjectList< TDSMExcelWorkbook > )
  TDSMExcelWorkbookList = class( TDSMExcelObject )
  private
    function GetCount: integer;
  public
    constructor Create( const pOwner : TDSMExcelApplication; const pObject : variant ); override;

    //function AddWorkbook : TDSMExcelWorkbook;
    procedure AddWorkBook;

    procedure Open( FileName : string );

    property Count : integer
             read GetCount;

  end;

  TDSMExcelApplication = class( TDSMExcelObject )
  private
  protected
    fWorkBooks : TDSMExcelWorkbookList;
    fVisible: boolean;
    //function GetWorkbook(const i: integer): TDSMExcelWorkbook;
    procedure SetVisible(const Value: boolean);
  public
    constructor Create( const pWithWorkbook : boolean = TRUE ); reintroduce; overload; virtual;
    constructor Create( const pWithWorkbook : string ); reintroduce; overload; virtual;
    destructor Destroy; override;

//    function AddWorkBook : TDSMExcelWorkbook;
    procedure AddWorkBook;

    property Visible : boolean
             read fVisible
             write SetVisible;
  end;

  TDSMExcel = class
  public

  end;

implementation

{ TDSMExcelApplication }

procedure TDSMExcelApplication.AddWorkBook;
begin
  fWorkBooks.AddWorkbook;
end;

constructor TDSMExcelApplication.Create( const pWithWorkbook : boolean = TRUE );
begin
  inherited Create( nil, System.Variants.Null );
  fExcelObject := CreateOleObject('Excel.Application');
  fWorkBooks := TDSMExcelWorkbookList.Create( self, fExcelObject.Workbooks );

  if pWithWorkbook then
  begin
    if fWorkbooks.Count = 0 then
    begin
      AddWorkbook;
    end;
  end;
  Visible := TRUE; // temporary
end;

constructor TDSMExcelApplication.Create(const pWithWorkbook: string);
begin
  Create( FALSE );
  fWorkBooks.Open( pWithWorkbook );
end;

destructor TDSMExcelApplication.Destroy;
begin
  if not VarIsEmpty( fExcelObject ) then
  begin
    fExcelObject.Quit;
  end;
  fWorkBooks.Free;

  inherited;
end;

(*
function TDSMExcelApplication.GetWorkbook(const i: integer): TDSMExcelWorkbook;
begin
  Result := fWorkbooks[ i ];
end;
*)

procedure TDSMExcelApplication.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  fExcelObject.Visible := Value;
end;

{ TDSMExcelWorkbookList }

procedure TDSMExcelWorkbookList.AddWorkbook; //: TDSMExcelWorkbook;
begin
  fOwner.ExcelObject.Workbooks.Add;
end;

constructor TDSMExcelWorkbookList.Create(const pOwner: TDSMExcelApplication; const pObject : variant);
begin
  inherited;
end;

function TDSMExcelWorkbookList.GetCount: integer;
begin
  Result := ExcelObject.Count;
end;

procedure TDSMExcelWorkbookList.Open(FileName: string);
begin
  ExcelObject.Open( FileName );
end;

{ TDSMExcelObject }

class function TDSMExcelObject.ColIntToText(const pCol: integer): string;
var
  iInt1, iInt2 : integer;

  // A-Z
const
  cBase = Ord('Z') - Ord('A' ) + 1;
begin
  iInt1 := (pCol div cBase);
  iInt2 := pCol mod cBase;
  if iInt1 = 0 then
  begin
    Result := '';
  end
  else
  begin
    Result := char( iInt1 + Ord( 'A' ) - 1);
  end;
  Result := Result + char( iInt2 + Ord( 'A' ));
end;

constructor TDSMExcelObject.Create(const pOwner: TDSMExcelApplication; const pObject : variant);
begin
  inherited Create;
  fOwner := pOwner;
  fExcelObject := pObject;
end;

function TDSMExcelObject.RangeText(const pLeft: string; const pTop: integer;
  const pRight: string; const pBottom: integer): string;
begin
  Result := pLeft + IntToStr( pTop ) + ':' + pRight + IntToStr( pBottom );
end;

function TDSMExcelObject.RangeText(const pLeft, pTop, pRight,
  pBottom: integer): string;
begin
  Result := RangeText( ColIntToText( pLeft ), pTop, ColIntToText( pRight), pBottom);
end;

{ TDSMResultSheet }

procedure TDSMWorksheet.SetCell(const pCol, pRow: string;
  const pVal: string);
var
  iRange : string;
begin
  iRange := pCol + pRow;
  ExcelObject.Range[ iRange, iRange ].Value := pVal;

end;

constructor TDSMWorksheet.Create(const pOwner: TDSMExcelApplication;
  const pObject: variant);
begin
  inherited;

  fCharts := TDSMWorksheetCharts.Create( self );
end;

destructor TDSMWorksheet.Destroy;
begin
  fCharts.Free;

  inherited;
end;

function TDSMWorksheet.Range(const pCol: string; const pRow: integer): variant;
begin
  Result := Range( pCol, pRow, pCol, pRow );
end;

function TDSMWorksheet.Range(const pRange: string): variant;
begin
  Result := ExcelObject.Range[ pRange ];
end;

function TDSMWorksheet.Range(const pCol, pRow: integer): variant;
begin
  Result := Range( pCol, pRow, pCol, pRow );
end;

function TDSMWorksheet.Range(const pLeft, pTop, pRight,
  pBottom: integer): variant;
begin
  Result := Range( RangeText( pLeft, pTop, pRight, pBottom ));
end;

function TDSMWorksheet.Range(const pLeft: string; const pTop: integer;
  const pRight: string; const pBottom: integer): variant;
begin
  Result := Range( RangeText( pLeft, pTop, pRight, pBottom ));
end;

procedure TDSMWorksheet.SetCell(const pCol, pRow: integer;
  const pVal: string);
begin
  SetCell( ColIntToText( pCol ), IntToStr(pRow ), pVal );

end;

{ TDSMWorksheetChart }

constructor TDSMWorksheetCharts.Create(const pWorksheet: TDSMWorksheet);
begin
  inherited Create( pWorkSheet.Owner, pWorksheet.ExcelObject.ChartObjects );
  fWorksheet := pWorksheet;
end;

{ TDSMExcelCharts }

function TDSMExcelCharts.Add( const Left, Top, Width, Height : double ): TDSMExcelChartObject;
begin
  Result := TDSMExcelChartObject.Create( fOwner, ExcelObject.Add( Left, Top, Width, Height ));
end;

destructor TDSMWorksheetCharts.Destroy;
begin
  fWorksheet.Free;

  inherited;
end;

{ TDSMExcelChartObject }

constructor TDSMExcelChartObject.Create(const pOwner: TDSMExcelApplication;
  const pObject: variant);
begin
  inherited;

  fChart := TDSMChart.Create( fOwner, ExcelObject.Chart );
end;

destructor TDSMExcelChartObject.Destroy;
begin

  inherited;
end;

{ TDSMChart }

constructor TDSMChart.Create(const pOwner: TDSMExcelApplication;
  const pObject: variant);
begin
  inherited;
  fSeriesList := TSeriesList.Create( fOwner, ExcelObject.SeriesCollection );
end;

destructor TDSMChart.Destroy;
begin
  fSeriesList.Free;
  inherited;
end;

function TDSMChart.GetChartType: integer;
begin
  Result := ExcelObject.Charttype;
end;

function TDSMChart.GetSeries(const i: integer): TSeries;
begin
  Result := fSeriesList.Items[ i ];
end;

procedure TDSMChart.SetChartType(const Value: integer);
begin
  ExcelObject.ChartType :=  Value;
end;

procedure TDSMChart.SetSourceData(const pRange: variant);
begin
  fExcelObject.SetSourceData( pRange );
end;

{ TDSMExcelObjectList<T> }

function TDSMExcelObjectList<T>.Add: T;
begin
  if Count < ExcelCount then
  begin
    // already in excel object, so
    Result := T.Create( fOwner, fExcelObject.Item[ Count + 1 ] ); // this is correct because excel items start at 1
  end
  else
  begin
    // need to add to both collections
    Result := T.Create( fOwner, fExcelObject.Add );
  end;
  inherited Add( Result );
end;

constructor TDSMExcelObjectList<T>.Create(const pOwner: TDSMExcelApplication;
  const pObject: variant);
begin
  inherited Create( TRUE );
  fExcelObject := pObject;
  fOwner := pOwner;
end;

function TDSMExcelObjectList<T>.ExcelCount: integer;
begin
  Result := fExcelObject.Count;
end;

{ TSeries }

function TSeries.GetHasDataLabels: boolean;
begin
  Result := ExcelObject.HasDataLabels;
end;

procedure TSeries.SetHasDataLabels(const Value: boolean);
begin
  ExcelObject.HasDataLabels := Value;
end;

{ TSeriesList }

function TSeriesList.Add: TSeries;
begin
  if Count < ExcelCount then
  begin
    // already in excel object, so
    Result := TSeries.Create( fOwner, fExcelObject.Item[ Count + 1 ] ); // this is correct because excel items start at 1
  end
  else
  begin
    // need to add to both collections
    Result := TSeries.Create( fOwner, fExcelObject.NewSeries );
  end;
  (self as TObjectList<TSeries>).Add( Result );
end;

end.
