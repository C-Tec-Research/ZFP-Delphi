unit UnitLogFileCfg;

// this unit relates to the cfg file for log files.

// The log file itself is a CSV list

// There are two levels of customisation. There is the top level
// that defines the various fields by giving them a name and so on
// that can be used as building blocks to the actual report.

// the second level is a report generator that allows the user to
// build specific reports from these fields
// There are default reports built in to the config file.

interface

uses
  SysUtils,
  Types,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Grids,
  Common,
  SigFile,
  ErrorList,
  Classes,
  AnsiStrings,
  UnitSigStrings,
  //SigNETStringGrid,
  SigNET.TStringGrid,
  SigPanel,
  UnitLogFiles,
  UnitExpertModes,
  UnitParseExpression;

type
  tLogField = class( tSigTextProperty )
  private
  public
    function ValueAsInt : integer;
    function ValueAsBool : boolean;
  end;

  tLogLine = class( tSigTextProperty )
  private
  protected
  public
  end;

  tLogRequestID = class( tSigIntegerProperty )
    // this is the request ID for a report
  private
  protected
  end;

  tLogRequestIDs = class( tSigObjectArray )
  private
    function GetRequestID(const i: integer): tLogRequestID;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    procedure BuildRequestList( const pStrings : tStrings; const pSuffix : string );

    property RequestID[ const i : integer ] : tLogRequestID
             read GetRequestID;
  end;

  tLogFieldDef = class( tSigCompoundProperty )

  end;

  tLogFieldDefs = class( tSigObjectArray )
  private
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
  end;

  tLogFilterIncludeType = ( lf_Include, lf_Exclude );
  tLogFilterOpType = ( lf_IsNumeric, lf_EQ, lf_NE, lf_GT, lt_LT, lt_GE, lt_LE, lf_AND, lf_OR );

  tLogFilterPointer = class;

  tLogExpressionType = ( et_Constant, et_Column );

  tLogExpression = class( tSigCompoundProperty )
  private
    fExpressionType: tSigEnum<tLogExpressionType>;
    fParm: tSigTextProperty;
    function GetExpressionType: tLogExpressionType;
    procedure SetExpressionType(const Value: tLogExpressionType);
    function GetParm: Integer;
    procedure SetParm(const Value: Integer);
    function GetParmText: string;
    procedure SetParmText(const Value: string);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property ExpressionType : tLogExpressionType
             read GetExpressionType
             write SetExpressionType;
    property Parm : Integer
             read GetParm
             write SetParm;
    property ParmText : string
             read GetParmText
             write SetParmText;

    function Evaluate( pDataList : tStrings ) : string;

    function IsInteger( pDataList : tStrings ) : boolean;

    procedure GetParmExpression( const pParseExpression: tParseExpression );
    procedure GetParmValue( const pParseExpression: tParseExpression );
  end;

  tLogFilter = class( tSigCompoundProperty )
  // filters records
  private
    fIncludeType: tSigEnum<tLogFilterIncludeType>;
    fOp: tSigEnum<tLogFilterOpType>;
    fFilter1: tLogFilterPointer;
    fFilter2: tLogFilterPointer;
    fCompareObject1: tLogExpression;
    fCompareObject2: tLogExpression;
    function GetIncludeType: tLogFilterIncludeType;
    procedure SetIncludeType(const Value: tLogFilterIncludeType);
    function GetOp: tLogFilterOpType;
    procedure SetOp(const Value: tLogFilterOpType);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property IncludeType : tLogFilterIncludeType
             read GetIncludeType
             write SetIncludeType;
    property Op : tLogFilterOpType
             read GetOp
             write SetOp;
    property CompareObject1 : tLogExpression
             read fCompareObject1;
    property CompareObject2 : tLogExpression
             read fCompareObject2;
    property Filter1 : tLogFilterPointer
             read fFilter1;
    property Filter2 : tLogFilterPointer
             read fFilter2;

    function Include( pDataList : tStrings ) : boolean;
  end;

  tLogFilterPointer = class( tSigPointer )
  private
    function GetFilter: tLogFilter;
    procedure SetFilter(const Value: tLogFilter);
  public
    property Filter : tLogFilter
             read GetFilter
             write SetFilter;
  end;

  tLogFilterList = class( tSigObjectArray )
  private
    function GetFilter(const i: integer): tLogFilter;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;

    function BuildFilters( const pParseExpression : tParseExpression ) : tLogFilter;
    function BuildExpression( const pParseExpression : tParseExpression ) : tLogExpression;
    property Filter[ const i : integer ] : tLogFilter
             read GetFilter;
  end;

  tLogSort = class( tSigCompoundProperty )

  end;

  tLogSorts = class( tSigObjectArray )
  private
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
  end;

  tLogSourceFiles = class( tSigRelativeFilePropertyList )

  end;

  tLogColDef = class( tSigCompoundProperty )
  private
    fTitles: tMemoProperty;
    fSourceIndex: tSigIntegerProperty;
    function GetTitleLine(const i: integer): string;
    function GetSourceIndex: integer;
    procedure SetSourceIndex(const Value: integer);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    property Titles : tMemoProperty
             read fTitles;
    function FixedRowCount : integer;

    function AddTitleLine( const pTitle : string ) : integer;

    property TitleLine[ const i : integer ] : string
             read GetTitleLine;
    property SourceIndex : integer
             read GetSourceIndex
             write SetSourceIndex;

  end;

  tLogColDefs = class( tSigObjectArray )
  private
    function GetLogColDef(const i: integer): tLogColDef;
    function GetTitle(const ACol, ARow: integer): string;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;

    function FixedRowCount : integer;

    property LogColDef[ const i : integer ] : tLogColDef
             read GetLogColDef; default;

    property Title[ const ACol, ARow : integer ] : string
             read GetTitle;

    function AddCol( const pTitle : string; const pSourceCol : integer ) : integer;

  end;

  tLogReport = class( tSigFileProperty )  // independently saveable
  private
    fList : tInfiniteStringList;
    fLog : tStringList;
    fReportData : tStringList; // source data after filtering and sorting
    fName: tSigTextProperty;
    fLogRequestIDs: tLogRequestIDs;
    fDataFiles: tLogSourceFiles;
    fFilterPointer: tLogFilterPointer;
    fFilter : tSigTextProperty;
    fFilters: tLogFilterList;
    fSorts: tLogSorts;
    fColDefs: tLogColDefs;
    fLogEditor: tMemo;
    fLogGrid: TStringGrid;
    fLogGridShowing, fLogEditorShowing : boolean;
    fOnPrintHeader: tNotifyEvent;
    fOnPrintFooter: tNotifyEvent;
    fColWidths : array of integer;
    fFixedRows : integer;
    fLogicalTableWidth : integer;
    fBackPanel: tSigPanel;
    function GetName: string;
    procedure SetName(const Value: string);
    procedure SetLogEditor(const Value: tMemo);
    procedure SetLogGrid(const Value: TStringGrid);
    procedure SetFilter(const Value: string);
    function GetFilter: string;
    procedure SetBackPanel(const Value: tSigPanel);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure Clear; override;

    destructor Destroy; override;

    procedure BuildRequestList( const pStrings : tStrings; const pSuffix : string  );

    property Name : string
             read GetName
             write SetName;
    property RequestIDs : tLogRequestIDs
             read fLogRequestIDs;
    property DataFiles : tLogSourceFiles
             read fDataFiles;
    property Filter : string
             read GetFilter
             write SetFilter;
    property Sorts : tLogSorts
             read fSorts;
    property ColDefs : tLogColDefs
             read fColDefs;

    procedure CopyLog( const pSource : tStrings; const pClear : boolean );

    procedure ShowLog;
    procedure ShowLogEditor;
    procedure ShowLogGrid;
    procedure RefreshLog;
    procedure ExportFile( const pLines : tStrings );

    function ImportLogFile( const pRecType : integer; const pFile : tStrings; var iIndex : integer;
                          const pErrors : tErrorList; const pErrorObject : tObject ) : boolean;

    function PrintFindLogFileLogicalWidth( const pCanvas : tCanvas; const pGridWidth : integer ) : integer;
    function PrintPrepareLogFilePages( const pCanvas : tCanvas; const pRect : tRect;
                                       const pGridWidth : integer; var pStartLine : integer;
                                       const pCalculating : boolean ) : boolean; // Returns TRUE when done

    property OnPrintFooter : tNotifyEvent
             read fOnPrintFooter
             write fOnPrintFooter;
    property OnPrintHeader : tNotifyEvent
             read fOnPrintHeader
             write fOnPrintHeader;

    // Editors
    property LogEditor : tMemo // currently but WILL change
             read fLogEditor
             write SetLogEditor;
    property LogGrid : TStringGrid
             read fLogGrid
             write SetLogGrid;
    property BackPanel : tSigPanel
             read fBackPanel
             write SetBackPanel;

    function Include( pDataList : tStrings ) : boolean;

  end;

  tLogReports = class( tSigObjectArray )
  private
    fTabSheetEditor: tTabControl;
    fLogEditor: tMemo;
    fLogGrid: TStringGrid;
    fBackPanel: tSigPanel;
    function GetLogReport(const i: integer): tLogReport;
    procedure SetTabSheetEditor(const Value: tTabControl);
    procedure OnTabSheetChange( Sender : tObject );
    procedure SetLogEditor(const Value: tMemo);
    procedure SetLogGrid(const Value: TStringGrid);
    procedure SetBackPanel(const Value: tSigPanel);
  protected
    procedure SetActiveChild(const Value: integer); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;

    property LogReport[ const i : integer ] : tLogReport
             read GetLogReport;

    function CreateBasicLogReport( const pRequestID :integer; const pName : string ) : tLogReport;

    function CurrentLogReport : tLogReport;

    function ImportLogFile( const pRecType : integer; const pFile : tStrings; var iIndex : integer;
                          const pErrors : tErrorList; const pErrorObject : tObject ) : boolean;
    // Editors

    property TabSheetEditor : tTabControl
             read fTabSheetEditor
             write SetTabSheetEditor;

    property LogEditor : tMemo // currently but WILL change
             read fLogEditor
             write SetLogEditor;
    property LogGrid : TStringGrid
             read fLogGrid
             write SetLogGrid;
    property BackPanel : tSigPanel
             read fBackPanel
             write SetBackPanel;
  end;

  TLogReportsCfgFile = class( TSigFileProperty ) // not a true cfg file - is does not have to have application name, for example
                                                 // Nor is it a log file, which is just a csv file
  private
    fLogReports: TLogReports;
    fEditorFrame: TFrameLogFiles;
    procedure SetEditorFrame(const Value: TFrameLogFiles);
  protected
    //procedure OnLogReportTabChange( Sender : tObject );
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property LogReports : tLogReports
             read fLogReports;

    function CreateBasicLogReport( const pRequestID :integer; const pName : string ) : tLogReport;

    function CurrentLogReport : tLogReport;

    procedure RefreshLog;
    // Editors

    function ImportLogFile( const pRecType : integer; const pFile : tStrings; var iIndex : integer;
                          const pErrors : tErrorList; const pErrorObject : tObject ) : boolean;

    property EditorFrame : TFrameLogFiles
             read fEditorFrame
             write SetEditorFrame;

  end;

implementation

{ tLogReports }

constructor tLogReports.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogReport );

end;

function tLogReports.CreateBasicLogReport(const pRequestID: integer;
  const pName: string): tLogReport;
var
  iRequestID : tLogRequestID;
begin
  Result := AddNewChild as tLogReport;
  iRequestID := Result.RequestIDs.AddNewChild as tLogRequestID;
  iRequestID.ValueAsInt := pRequestID;
  Result.Name := pName;
  Result.Filter := '(Col[0]=' + IntToStr( pRequestID ) + ') and IsNumeric(Col[1])';
  if assigned( TabSheetEditor ) then
  begin
    TabSheetEditor.Tabs.AddObject( pName, Result );
  end;
end;

function tLogReports.CurrentLogReport: tLogReport;
begin
  if ActiveChild < 0 then
  begin
    Result := nil;
  end
  else
  begin
    Result := LogReport[ ActiveChild ];
  end;
end;

function tLogReports.GetLogReport(const i: integer): tLogReport;
begin
  if (i < 0) or (i > Max ) then
  begin
    Result := nil;
  end
  else
  begin
    Result := Entry[ i ] as tLogReport;
  end;
end;

function tLogReports.ImportLogFile(const pRecType: integer;
  const pFile: tStrings; var iIndex: integer; const pErrors: tErrorList;
  const pErrorObject: tObject): boolean;
var
  i: Integer;
begin
  Result := FALSE; // unless one of our children says otherwise
  for i := 0 to Max do
  begin
    if LogReport[ i ].ImportLogFile( pRecType, pFile, iIndex, pErrors, pErrorObject ) then
    begin
      Result := TRUE;
      ActiveChild := i;
    end;
  end;
end;

procedure tLogReports.OnTabSheetChange(Sender: tObject);
begin
  if assigned( fTabSheetEditor ) then
  begin
    if fTabSheetEditor.TabIndex <> ActiveChild then
    begin
      ActiveChild := fTabSheetEditor.TabIndex;
    end;
  end;
end;

procedure tLogReports.SetActiveChild(const Value: integer);
begin
  if ActiveChild >= 0 then
  begin
    LogReport[ ActiveChild ].LogEditor := nil;
    LogReport[ ActiveChild ].LogGrid := nil;
  end;
  inherited;
  if assigned( fTabSheetEditor ) then
  begin
    if ActiveChild >= 0 then
    begin
      if fTabSheetEditor.TabIndex <> ActiveChild then
      begin
        fTabSheetEditor.TabIndex := ActiveChild;
      end;
      LogReport[ ActiveChild ].LogEditor := fLogEditor;
      LogReport[ ActiveChild ].LogGrid := fLogGrid;
    end;
  end;
end;

procedure tLogReports.SetBackPanel(const Value: tSigPanel);
begin
  fBackPanel := Value;
  if ActiveChild >= 0 then
  begin
    LogReport[ ActiveChild ].BackPanel := fBackPanel;
  end;
end;

procedure tLogReports.SetLogEditor(const Value: tMemo);
begin
  // remove any existing linkages
  fLogEditor := Value;
  if ActiveChild >= 0 then
  begin
    LogReport[ ActiveChild ].LogEditor := fLogEditor;
  end;
end;

procedure tLogReports.SetLogGrid(const Value: TStringGrid);
begin
  fLogGrid := Value;
  if ActiveChild >= 0 then
  begin
    LogReport[ ActiveChild ].LogGrid := fLogGrid;
  end;
end;

procedure tLogReports.SetTabSheetEditor(const Value: tTabControl);
var
  i: integer;
begin
  fTabSheetEditor := Value;
  if assigned( fTabSheetEditor ) then
  begin
    with fTabSheetEditor do
    begin
      Tabs.Clear;
      for i := 0 to Max do
      begin
        Tabs.AddObject( LogReport[ i ].Name, LogReport[ i ] );
      end;
      OnChange := OnTabSheetChange;
      if ActiveChild < 0 then
      begin
        ActiveChild := 0;
      end
      else
      begin
        TabIndex := ActiveChild;
      end;
    end;
  end;
end;

{ tLogReport }

procedure tLogReport.BuildRequestList( const pStrings: tStrings; const pSuffix : string );
begin
  fLogRequestIDs.BuildRequestList( pStrings, pSuffix );
end;

procedure tLogReport.Clear;
begin
  inherited;
  // add default columns. Note that Log Columns defs could be cleared independantly later
  with ColDefs do
  begin
    AddCol( Translate( 'Seq' ), 1);
    AddCol( Translate( 'Date/Time' ), 2);
    AddCol( Translate( 'Loop' ), 3);
    AddCol( Translate( 'Device ID' ), 4);
    AddCol( Translate( 'Zone Number' ), 5);
    AddCol( Translate( 'Zone Name' ), 6);
    AddCol( Translate( 'Device Name' ), 7);
    AddCol( Translate( 'Event Type' ), 8);
  end;
end;

procedure tLogReport.CopyLog(const pSource: tStrings; const pClear: boolean);
var
  i: Integer;
begin
  if pClear then
  begin
    fLog.Clear;
  end;
  for i := 0 to pSource.Count - 1 do
  begin
    fLog.Add( pSource[ i ] );
  end;
  ShowLogEditor;
  ShowLogGrid;
end;

constructor tLogReport.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fName          := tSigTextProperty.Create( 'Name', self );
  fLogRequestIDs := tLogRequestIDs.Create( 'Request IDs', self );
  fDataFiles     := tLogSourceFiles.Create( 'Source Files', self );
  fFilter        := tSigTextProperty.Create( 'Filter', self );;
  fFilters       := tLogFilterList.Create( 'Filters', self );
  fFilterPointer := tLogFilterPointer.Create( 'Filter Pointer', self, fFilters.Children );
  fSorts         := tLogSorts.Create( 'Sorts', self );
  fColDefs       := tLogColDefs.Create( 'Col Defs', self );

  fLog := tStringList.Create;
end;

destructor tLogReport.Destroy;
begin
  fList.Free;
  fLog.Free;
  fReportData.Free;

  inherited;
end;

procedure tLogReport.ExportFile(const pLines: tStrings);
begin
  pLines.Assign( fLog );
end;

function tLogReport.GetFilter: string;
begin
  Result := fFilter.Value;
end;

function tLogReport.GetName: string;
begin
  Result := fName.Value;
end;

function tLogReport.ImportLogFile(const pRecType: integer;
  const pFile: tStrings; var iIndex: integer; const pErrors: tErrorList;
  const pErrorObject: tObject): boolean;
var
  i: Integer;
begin
  Result := FALSE;
  // see if it is for any of our IDS
  for i := 0 to fLogRequestIDs.Max do
  begin
    if fLogRequestIDs.RequestID[ i ].ValueAsInt = pRecType then
    begin
      Result := TRUE;
      fLogEditorShowing := FALSE;
      fLogGridShowing := FALSE;
      fLog.Assign( pFile );
      ShowLog;
      exit;
    end;
  end;
end;

function tLogReport.Include(pDataList: tStrings): boolean;
begin
  if assigned( fFilterPointer.Filter ) then
  begin
    Result := fFilterPointer.Filter.Include( pDataList );
  end
  else
  begin
    Result := TRUE;
  end;
end;

function tLogReport.PrintFindLogFileLogicalWidth(
  const pCanvas: tCanvas; const pGridWidth : integer): integer;
var
  i, j, iCol, iRow, iWidth : integer;
  iString : string;
  iList : tInfiniteStringList;
begin
  // set up titles, etc
  SetLength( fColWidths, ColDefs.Max + 1 );
  fFixedRows := ColDefs.FixedRowCount;
  pCanvas.Font.Style := [ fsBold ];
  for iCol := 0 to ColDefs.Max do
  begin
    fColWidths[ iCol ] := 0;
    for iRow := 0 to fFixedRows - 1 do
    begin
      iString := ColDefs.Title[ iCol, iRow ];
      iWidth := pCanvas.TextWidth( ColDefs.Title[ iCol, iRow ] + 'XX' );
      if iWidth > fColWidths[ iCol ] then
      begin
        fColWidths[ iCol ] := iWidth;
      end;
    end;
  end;

  pCanvas.Font.Style := [ ];
  iList := tInfiniteStringList.Create;
  try
    for i := 0 to fLog.Count - 1 do
    begin
      iString := fLog.Strings[ i ];
      CommaListToStringList( iString, iList, TRUE );
      if Include( iList ) then
      begin
        for iCol := 0 to ColDefs.Max do
        begin
          j := ColDefs[ iCol ].SourceIndex;
          iWidth := pCanvas.TextWidth( iList[ j ] + 'XX' );
          if iWidth > fColWidths[ iCol ] then
          begin
            fColWidths[ iCol ] := iWidth;
          end;
        end;
      end;
    end;
  finally
    iList.Free;
  end;

  Result := pGridWidth;
  for i := 0 to Length( fColWidths ) - 1 do
  begin
    Result := Result + fColWidths[ i ] + pGridWidth;
  end;
  fLogicalTableWidth := Result;
end;

function tLogReport.PrintPrepareLogFilePages(const pCanvas: tCanvas;
  const pRect: tRect; const pGridWidth : integer; var pStartLine : integer;
  const pCalculating : boolean ) : boolean;
var
  iPrintPos, iLeft : integer;
  iLineHeight, iLineMargin, iTextMargin : integer;
  iCol, iRow, j : integer;
  iString : string;
  iList : tInfiniteStringList;
begin
  iPrintPos := pRect.Top;
  iLeft := pRect.Left;
  iLineMargin := pCanvas.TextHeight( 'XX') div 8;
  iLineHeight := pCanvas.TextHeight( 'XX') + (2 * iLineMargin);
  iTextMargin := pCanvas.TextWidth( 'X' );
  if pGridWidth > 0 then
  begin
    pCanvas.Pen.Width := pGridWidth;
  end;
  // print titles
  if not pCalculating then
  begin
    if pGridWidth > 0 then
    begin
      pCanvas.MoveTo( iLeft, iPrintPos );
      pCanvas.LineTo( iLeft + fLogicalTableWidth, iPrintPos );
    end;
  end;
  inc( iPrintPos, pGridWidth );
  pCanvas.Font.Style := [ fsBold ];
  for iRow := 0 to fFixedRows - 1 do
  begin
    if not pCalculating then
    begin
      if pGridWidth > 0 then
      begin
        pCanvas.MoveTo( iLeft, iPrintPos );
        pCanvas.LineTo( iLeft, iPrintPos + iLineHeight );
        inc( iLeft, pGridWidth );
      end;
      for iCol := 0 to Length( fColWidths ) - 1 do
      begin
        pCanvas.TextOut( iLeft + iTextMargin, iPrintPos + iLineMargin, ColDefs.Title[ iCol, iRow ] );
        inc( iLeft, fColWidths[ iCol ] );
        pCanvas.MoveTo( iLeft, iPrintPos );
        pCanvas.LineTo( iLeft, iPrintPos + iLineHeight );
        inc( iLeft, pGridWidth );
      end;
    end;
    inc( iPrintPos, iLineHeight );
    // don't print lines in title boxes
  end;
  if not pCalculating then
  begin
    iLeft := pRect.Left;
    if pGridWidth > 0 then
    begin
      pCanvas.MoveTo( iLeft, iPrintPos );
      pCanvas.LineTo( iLeft + fLogicalTableWidth, iPrintPos );
    end;
  end;
  inc( iPrintPos, pGridWidth );

  pCanvas.Font.Style := [ ];
  iList := tInfiniteStringList.Create;
  try
    while pStartLine < fLog.Count do
    begin
      if (iPrintPos + iLineHeight + pGridWidth) > pRect.Bottom then
      begin
        Result := FALSE;
        exit;
      end;
      iString := fLog.Strings[ pStartLine ];
      CommaListToStringList( iString, iList, TRUE );
      if Include( iList ) then
      begin
        if not pCalculating then
        begin
          iLeft := pRect.Left;
          if pGridWidth > 0 then
          begin
            pCanvas.MoveTo( iLeft, iPrintPos );
            pCanvas.LineTo( iLeft, iPrintPos + iLineHeight );
            inc( iLeft, pGridWidth );
          end;
          for iCol := 0 to Length( fColWidths ) - 1 do
          begin
            j := ColDefs[ iCol ].SourceIndex;
            pCanvas.TextOut( iLeft + iTextMargin, iPrintPos + iLineMargin, iList[ j ] );
            inc( iLeft, fColWidths[ iCol ] );
            pCanvas.MoveTo( iLeft, iPrintPos );
            pCanvas.LineTo( iLeft, iPrintPos + iLineHeight );
            inc( iLeft, pGridWidth );
          end;
        end;
        inc( iPrintPos, iLineHeight );

        if not pCalculating then
        begin
          iLeft := pRect.Left;
          if pGridWidth > 0 then
          begin
            pCanvas.MoveTo( iLeft, iPrintPos );
            pCanvas.LineTo( iLeft + fLogicalTableWidth, iPrintPos );
          end;
        end;
        inc( iPrintPos, pGridWidth );
      end;
      inc( pStartLine );
    end;
  // if we get here then there is no more to do
  Result := TRUE;
  finally
    iList.Free;
  end;
end;

procedure tLogReport.RefreshLog;
begin
  ShowLog;
end;

procedure tLogReport.ShowLog;
begin
  if em_View_Log_as_Table in ExpertModes then
  begin
    if assigned( fLogEditor ) then
    begin
      fLogEditor.Visible := FALSE;
    end;
    fLogEditorShowing := FALSE;
    if assigned( fLogGrid ) then
    begin
      //fLogGrid.Visible := TRUE;
      fLogGrid.Align := alClient;
      if not fLogGridShowing then
      begin
        //ShowLogGrid;
        fLogGridShowing := TRUE;
      end;
      //fLogGrid.Visible := FALSE;
      ShowLogGrid;
    end
    else
    begin
      fLogGridShowing := FALSE;
    end;
  end
  else
  begin
    if assigned( fLogGrid ) then
    begin
      fLogGrid.Visible := FALSE;
    end;
    fLogGridShowing := FALSE;
    if assigned( fLogEditor ) then
    begin
      fLogEditor.Visible := TRUE;
      fLogEditor.Align := alClient;
      if not fLogEditorShowing then
      begin
        ShowLogEditor;
        fLogEditorShowing := TRUE;
      end;
    end
    else
    begin
      fLogEditorShowing := FALSE;
    end;
  end;
end;

procedure tLogReport.SetBackPanel(const Value: tSigPanel);
begin
  fBackPanel := Value;
end;

procedure tLogReport.SetFilter(const Value: string);
var
  iParseExpression : tParseExpression;
  iString : string;
begin
  fFilter.Value := Value;
  iString := Value;
  iParseExpression := tParseExpression.Create( iString );
  // now work through and build up filters
  fFilterPointer.Filter := fFilters.BuildFilters( iParseExpression )
end;

procedure tLogReport.SetLogEditor(const Value: tMemo);
begin
  fLogEditor := Value;
  //ShowLog;
end;

procedure tLogReport.SetLogGrid(const Value: TStringGrid);
var
  iCol, iRow, iWidth : integer;
begin
  fLogGrid := Value;
  // set up titles, etc
  if assigned( fLogGrid ) then
  begin
    with fLogGrid do
    begin
      FixedRows := ColDefs.FixedRowCount;
      ColCount := ColDefs.Max + 1;
      for iCol := 0 to ColDefs.Max do
      begin
        for iRow := 0 to FixedRows - 1 do
        begin
          Cells[ iCol, iRow ] := ColDefs.Title[ iCol, iRow ];
          iWidth := Canvas.TextWidth( ColDefs.Title[ iCol, iRow ] + 'xx' );
          if iWidth > ColWidths[ iCol ] then
          begin
            ColWidths[ iCol ] := iWidth;
          end;
        end;
      end;
    end;
  end;
  ShowLog;
end;

procedure tLogReport.SetName(const Value: string);
begin
  fName.Value := Value;
end;

procedure tLogReport.ShowLogEditor;
begin
  if assigned( LogEditor ) then
  begin
    LogEditor.Lines.Assign( fLog );
  end;
end;

procedure tLogReport.ShowLogGrid;
var
  i, j, iCol, iRow, iWidth : integer;
  iString : string;
  iList : tInfiniteStringList;
begin
  if assigned( fLogGrid ) then
  begin
    iList := tInfiniteStringList.Create;
    try
      fBackPanel.Caption := Translate('Retrieving - Please wait...');
      with fLogGrid do
      begin
        Visible := FALSE;
        iRow := FixedRows;
        for i := 0 to fLog.Count - 1 do
        begin
          iString := fLog.Strings[ i ];
          CommaListToStringList( iString, iList, TRUE );
          if Include( iList ) then
          begin
            for iCol := 0 to ColDefs.Max do
            begin
              j := ColDefs[ iCol ].SourceIndex;
              Cells[ iCol, iRow ] := iList[ j ];
              iWidth := Canvas.TextWidth( iList[ j ] + 'xx' );
              if iWidth > ColWidths[ iCol ] then
              begin
                ColWidths[ iCol ] := iWidth;
              end;
            end;
            inc( iRow );
          end;
        end;
        Visible := fLog.Count > 0;
        fBackPanel.Caption := '';
        if Visible then
        begin
          RowCount := iRow;
        end;
      end;
    finally
      iList.Free;
    end;
  end;
end;

{ tLogField }

function tLogField.ValueAsBool: boolean;
begin
  case ValueAsInt of
    0: Result := FALSE;
    1: Result := TRUE;
    else raise Exception.Create('Illegal boolean value "' + Value + '"');
  end;
end;

function tLogField.ValueAsInt: integer;
begin
  if Value = '' then
  begin
    Result := 0;
  end
  else
  begin
    Result := StrToInt( Value );
  end;

end;

{ tLogLine }

{ tLogRequestIDs }

procedure tLogRequestIDs.BuildRequestList( const pStrings: tStrings; const pSuffix : string );
var
  i: Integer;
begin
  //pStrings.Clear;
  for i := 0 to Max do
  begin
    pStrings.Add( RequestID[ i ].Value + pSuffix );
  end;
end;

constructor tLogRequestIDs.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogRequestID );

end;

function tLogRequestIDs.GetRequestID(const i: integer): tLogRequestID;
begin
  Result := Entry[ i ] as tLogRequestID;
end;

{ tLogSorts }

constructor tLogSorts.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogSort );

end;

{ tLogColDefs }

function tLogColDefs.AddCol(const pTitle: string; const pSourceCol : integer): integer;
begin
  Max := Max + 1;
  Result := Max;
  with LogColDef[ Result ] do
  begin
    AddTitleLine( pTitle );
    SourceIndex := pSourceCol;
  end;
end;

constructor tLogColDefs.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogColDef );;

end;

function tLogColDefs.FixedRowCount: integer;
var
  i, iTest: Integer;
begin
  Result := 0;
  for i := 0 to Max do
  begin
    iTest := LogColDef[ i ].FixedRowCount;
    if iTest > Result then
    begin
      Result := iTest;
    end;
  end;
end;

function tLogColDefs.GetLogColDef(const i: integer): tLogColDef;
begin
  Result := Entry[ i ] as tLogColDef;
end;

function tLogColDefs.GetTitle(const ACol, ARow: integer): string;
begin
  Result := LogColDef[ ACol ].TitleLine[ ARow ];
end;

{ tLogFieldDefs }

constructor tLogFieldDefs.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogFieldDef );

end;

{ tLogReportsCfgFile }

constructor tLogReportsCfgFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fLogReports := tLogReports.Create( 'Log reports', self );
end;

function tLogReportsCfgFile.CreateBasicLogReport(const pRequestID: integer;
  const pName: string): tLogReport;
begin
  Result := LogReports.CreateBasicLogReport( pRequestID, pName );
end;

function tLogReportsCfgFile.CurrentLogReport: tLogReport;
begin
  Result := fLogReports.CurrentLogReport;
end;

function tLogReportsCfgFile.ImportLogFile(const pRecType: integer;
  const pFile: tStrings; var iIndex: integer; const pErrors: tErrorList;
  const pErrorObject: tObject): boolean;
begin
  Result := fLogReports.ImportLogFile( pRecType, pFile, iIndex, pErrors, pErrorObject );
end;

procedure tLogReportsCfgFile.RefreshLog;
var
  iCurrentLogReport : tLogReport;
begin
  iCurrentLogReport := CurrentLogReport;
  if assigned( iCurrentLogReport ) then
  begin
    iCurrentLogReport.RefreshLog;
  end;
end;

procedure tLogReportsCfgFile.SetEditorFrame(const Value: TFrameLogFiles);
begin
  fEditorFrame := Value;
  if assigned( fEditorFrame ) then
  begin
    LogReports.TabSheetEditor := fEditorFrame.TabControlLogs;
    LogReports.LogEditor := fEditorFrame.MemoLog;
    LogReports.LogGrid := fEditorFrame.StringGridLog;
  end;
end;

{ tLogColDef }

function tLogColDef.AddTitleLine(const pTitle: string): integer;
begin
  Result := Titles.Lines.Add( pTitle );
end;

constructor tLogColDef.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fTitles := tMemoProperty.Create( 'Titles', self );
  fSourceIndex := tSigIntegerProperty.Create( 'Source Column', self );

end;

function tLogColDef.FixedRowCount: integer;
begin
  Result := Titles.Lines.Count;
end;

function tLogColDef.GetSourceIndex: integer;
begin
  Result := fSourceIndex.ValueAsInt;
end;

function tLogColDef.GetTitleLine(const i: integer): string;
begin
  if i >= Titles.Lines.Count then
  begin
    Result := '';
  end
  else
  begin
    Result := Titles.Lines[ i ];
  end;
end;

procedure tLogColDef.SetSourceIndex(const Value: integer);
begin
  fSourceIndex.ValueAsInt := Value;
end;

{ tLogFilter }

constructor tLogFilter.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fIncludeType    := tSigEnum<tLogFilterIncludeType>.Create( 'Include/Exclude', self );
  fOp             := tSigEnum<tLogFilterOpType>.Create( 'Operation', self );
  fCompareObject1 := tLogExpression.Create( 'Object 1', self );
  fCompareObject2 := tLogExpression.Create( 'Object 2', self );
  fFilter1        := tLogFilterPointer.Create( 'Filter 1', self, pOwner.Children );
  fFilter2        := tLogFilterPointer.Create( 'Filter 2', self, pOwner.Children );
end;

function tLogFilter.GetIncludeType: tLogFilterIncludeType;
begin
  Result := tLogFilterIncludeType( fIncludeType.ValueAsInt );
end;

function tLogFilter.GetOp: tLogFilterOpType;
begin
  Result := tLogFilterOpType( fOp.ValueAsInt );
end;

function tLogFilter.Include(pDataList: tStrings): boolean;
var
  iCompareObject1, iCompareObject2 : tLogFilter;
  sV1, sV2 : string;
  iV1, iV2 : integer;
  iIntegerCompare : boolean;
begin
  iIntegerCompare := CompareObject1.IsInteger( pDataList ) and
                     CompareObject2.IsInteger( pDataList );
  sV1 := CompareObject1.Evaluate( pDataList );
  sV2 := CompareObject2.Evaluate( pDataList );
  if iIntegerCompare then
  begin
    iV1 := StrToInt( sV1 );
    iV2 := StrToInt( sV2 );
  end
  else
  begin
    iV1 := 0;
    iV2 := 1;
  end;
  iCompareObject1 := fFilter1.Filter;
  iCompareObject2 := fFilter2.Filter;
  case tLogFilterOpType( fOp.ValueAsInt ) of
    lf_IsNumeric:
    begin
      Result := CompareObject1.IsInteger( pDataList );
    end;
    lf_EQ:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 = iV2;
      end
      else
      begin
        Result := SameText( sV1, sV2 );
      end;
    end;
    lf_NE:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 <> iV2;
      end
      else
      begin
        Result := not SameText( sV1, sV2 );
      end;
    end;
    lf_GT:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 > iV2;
      end
      else
      begin
        Result := CompareText( sV1, sV2 ) > 0;
      end;
    end;
    lt_LT:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 < iV2;
      end
      else
      begin
        Result := CompareText( sV1, sV2 ) < 0;
      end;
    end;
    lt_GE:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 >= iV2;
      end
      else
      begin
        Result := CompareText( sV1, sV2 ) >= 0;
      end;
    end;
    lt_LE:
    begin
      if iIntegerCompare then
      begin
        Result := iV1 <= iV2;
      end
      else
      begin
        Result := CompareText( sV1, sV2 ) <= 0;
      end;
    end;
    lf_AND:
    begin
      if assigned( iCompareObject1 ) and assigned( iCompareObject2 ) then
      begin
        Result := iCompareObject1.Include( pDataList ) and iCompareObject2.Include( pDataList );
      end
      else
      begin
        raise Exception.Create(Translate('Incomplete AND filter'));
      end;
    end;
    lf_OR:
    begin
      if assigned( iCompareObject1 ) and assigned( iCompareObject2 ) then
      begin
        Result := iCompareObject1.Include( pDataList ) or iCompareObject2.Include( pDataList );
      end
      else
      begin
        raise Exception.Create(Translate('Incomplete OR filter'));
      end;
    end;
    else
    begin
      raise Exception.Create(Translate('Unexpected operand in filter'));
    end;
  end;
  if fIncludeType.ValueAsInt = ord( lf_Exclude ) then
  begin
    Result := not Result;
  end;
end;

procedure tLogFilter.SetIncludeType(const Value: tLogFilterIncludeType);
begin
  fIncludeType.ValueAsInt := Ord( Value );
end;

procedure tLogFilter.SetOp(const Value: tLogFilterOpType);
begin
  fOp.ValueAsInt := Ord( Value );
end;

{ tLogFilterPointer }

function tLogFilterPointer.GetFilter: tLogFilter;
begin
  Result := DestinationObject as tLogFilter;
end;

procedure tLogFilterPointer.SetFilter(const Value: tLogFilter);
begin
  DestinationObject := Value;
end;

{ tLogFilterList }

function tLogFilterList.BuildExpression(
  const pParseExpression: tParseExpression): tLogExpression;
var
  iTemp : string;
begin
  if assigned( pParseExpression ) then
  begin
    case pParseExpression.ExpressionType of
      //pet_Empty: ;
      pet_BracketedExpression:
      begin
        Result := BuildExpression( pParseExpression.LeftChild );
      end;
      //pet_Name:
      //begin
      //end;
      pet_NonaryExpression:
      begin
        case pParseExpression.LeftChild.ExpressionType of
          //pet_Empty: ;
          //pet_BracketedExpression: ;
          pet_Name:
          begin
            iTemp := pParseExpression.LeftChild.Expression;
            if SameText( iTemp, 'Col' ) then
            begin
              Result := tLogExpression.Create( '', self );
              Result.ExpressionType := et_Column;
              Result.GetParmExpression( pParseExpression.RightChild );
            end
            else
            begin
              raise Exception.Create('Internal Error 020');
            end;
          end;
          //pet_NonaryExpression: ;
          //pet_UnaryExpression: ;
          //pet_BinaryExpression: ;
          else
          begin
            raise Exception.Create('Internal Error 018');
          end;
        end;
      end;
      //pet_UnaryExpression: ;
      //pet_BinaryExpression: ;
      else
      begin
        raise Exception.Create('Internal Error 019');
      end;
    end;
  end
  else
  begin
    raise Exception.Create('Internal Error 017');
  end;
end;

function tLogFilterList.BuildFilters(
  const pParseExpression: tParseExpression): tLogFilter;
begin
  if assigned( pParseExpression ) then
  begin
    case pParseExpression.ExpressionType of
      //pet_Empty: ;
      pet_BracketedExpression:
      begin
        Result := BuildFilters( pParseExpression.LeftChild );
      end;
      //pet_Name: ;
      pet_NonaryExpression:
      begin
        case pParseExpression.LeftChild.ExpressionType of
          //pet_Empty: ;
          //pet_BracketedExpression: ;
          pet_Name:
          begin
            if SameText( pParseExpression.LeftChild.Expression, 'IsNumeric' ) then
            begin
              Max := Max + 1;
              Result := Filter[ Max ];
              Result.Op := lf_IsNumeric;
              Result.CompareObject1.GetParmExpression( pParseExpression.RightChild );
            end
            else
            begin
              raise Exception.Create('Internal Error 011');
            end;
          end;
          //pet_NonaryExpression: ;
          //pet_UnaryExpression: ;
          //pet_BinaryExpression: ;
          else
          begin
            raise Exception.Create('Internal Error 010');
          end;
        end;
      end;
      //pet_UnaryExpression: ;
      pet_BinaryExpression:
      begin
        if SameText( pParseExpression.Expression, 'AND' ) then
        begin
          Max := Max + 1;
          Result := Filter[ Max ];
          Result.Op := lf_AND;
          Result.Filter1.Filter := BuildFilters( pParseExpression.LeftChild );
          Result.Filter2.Filter := BuildFilters( pParseExpression.RightChild );
        end
        else  if SameText( pParseExpression.Expression, 'OR' ) then
        begin
          Max := Max + 1;
          Result := Filter[ Max ];
          Result.Op := lf_OR;
          Result.Filter1.Filter := BuildFilters( pParseExpression.LeftChild );
          Result.Filter2.Filter := BuildFilters( pParseExpression.RightChild );
        end
        else  if pParseExpression.Expression = '=' then
        begin
          Max := Max + 1;
          Result := Filter[ Max ];
          Result.Op := lf_EQ;
          Result.CompareObject1.GetParmExpression( pParseExpression.LeftChild );
          Result.CompareObject2.GetParmExpression( pParseExpression.RightChild );
        end
        else
        begin
          raise Exception.Create('Internal Error 008');
        end;
      end;
      else
      begin
        raise Exception.Create('Internal Error 009');
      end;
    end;
  end
  else
  begin
    raise Exception.Create('Internal Error 007');
  end;
end;

constructor tLogFilterList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tLogFilter );

end;

function tLogFilterList.GetFilter(const i: integer): tLogFilter;
begin
  Result := Entry[ i ] as tLogFilter;
end;

{ tLogExpression }

constructor tLogExpression.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fExpressionType := tSigEnum<tLogExpressionType>.Create( 'Expression Type', self );
  fParm           := tSigTextProperty.Create( 'Parm', self );
end;

function tLogExpression.Evaluate(pDataList: tStrings): string;
begin
  case ExpressionType of
    et_Constant:          Result := ParmText;
    et_Column:            Result := pDataList[ Parm ];
    else                  Result := '';
  end;
end;

function tLogExpression.GetExpressionType: tLogExpressionType;
begin
  Result := tLogExpressionType( fExpressionType.ValueAsInt );
end;

function tLogExpression.GetParm: Integer;
begin
  Result := StrToInt( fParm.Value );
end;

procedure tLogExpression.GetParmExpression(const pParseExpression: tParseExpression);
begin
  case pParseExpression.ExpressionType of
    //pet_Empty: ;
    pet_BracketedExpression:
    begin
      GetParmExpression( pParseExpression.LeftChild );
    end;
    pet_Name:
    begin
      ExpressionType := et_Constant;
      GetParmValue( pParseExpression );
    end;
    pet_NonaryExpression:
    begin
      // column?
      case pParseExpression.LeftChild.ExpressionType of
        //pet_Empty: ;
        //pet_BracketedExpression: ;
        pet_Name:
        begin
          if SameText( pParseExpression.LeftChild.Expression, 'Col' ) then
          begin
            ExpressionType := et_Column;
            GetParmValue( pParseExpression.RightChild );
          end
          else
          begin
            raise Exception.Create('Internal Error 023');
          end;
        end;
        //pet_NonaryExpression: ;
        //pet_UnaryExpression: ;
        //pet_BinaryExpression: ;
        else
        begin
          raise Exception.Create('Internal Error 022');
        end;
      end;
    end;
    //pet_UnaryExpression: ;
    //pet_BinaryExpression: ;
    else
    begin
      raise Exception.Create('Internal Error 021');
    end;
  end;
end;

function tLogExpression.GetParmText: string;
begin
  Result := fParm.Value;
end;

procedure tLogExpression.GetParmValue(const pParseExpression: tParseExpression);
begin
  case pParseExpression.ExpressionType of
    //pet_Empty: ;
    pet_BracketedExpression:
    begin
      GetParmValue( pParseExpression.LeftChild );
    end;
    pet_Name:
    begin
      ParmText := pParseExpression.Expression;
    end;
    //pet_NonaryExpression: ;
    //pet_UnaryExpression: ;
    //pet_BinaryExpression: ;
    else
    begin
      raise Exception.Create('Internal Error 031');
    end;
  end;
end;

function tLogExpression.IsInteger(pDataList: tStrings): boolean;
begin
  Result := IsValidNumber( Evaluate( pDataList ), 0, 99999 );
end;

procedure tLogExpression.SetExpressionType(const Value: tLogExpressionType);
begin
  fExpressionType.ValueAsInt := Ord( Value );
end;

procedure tLogExpression.SetParm(const Value: Integer);
begin
  fParm.Value := IntToStr( Value );
end;

procedure tLogExpression.SetParmText(const Value: string);
begin
  fParm.Value := Value;
end;

end.
