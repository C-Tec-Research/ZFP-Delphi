unit SigGeneralGrid;

interface

{
  A bit like a string grid but designed to have multiple editors, one for each column.

  v2.0 - Base editors on TComponent so that they can be saved and a property editor built
         Apart from being based on TComponent, many features are the same.
  v3.0 - Add variants of image list to rotate around the images or drop down list images.
         Add a new property ItemList which is a string list for the drop down boxes and
         image sequences. To maintain backwards compatibility the list is not assigned to
         the editor if the items list is empty. Thus an esImageList is just as before
         if the Items list is empty, but rotates through the values if it is not empty.

         '' is no longer treated as zero in the title bar.
  v4.0 - Allow multiline edit. Maintains a list of selected lines (which can be empty).
         If not empty and the current selection is within selected lines list, all lines
         in that column and in the list are changed.

         Also, and changes to the selected cell that occur during the OnSelect
}

uses
  Windows,
  SysUtils,
  Classes,
  Controls,
  Grids,
  Mask,
  StdCtrls,
  Contnrs,
  Graphics,
  Types,
  SigSpinEdit,
  Buttons;

type
  tSigEditorStyle = ( esNone, esMaskEdit, esDropDown, esDropDownList,
                      esImageList, esSpinEdit, esDropDownImageList,
                      esButton );

  tSigGetImageIndex = function( const Sender : tObject; const Col, Row : integer; const State: TGridDrawState; const Value : string ) : integer of object;

  tSetupEditor = procedure( const Value : string ) of object;

  tOnCellChange = procedure( const Sender : tObject; const Col, Row : integer; const Value : string ) of object;
  tOnEditorSelectionChange = procedure( const Sender : tObject; const pParm : integer ) of object;

type
  tSigGeneralGrid = class;
  tSigGeneralGridCell = class;

  tSigGridEditor = class( tComponent )    // this component is added on the pallet
  private
    fEditor: tWinControl;
    fSigGrid: TSigGeneralGrid;
    fStyle: tSigEditorStyle;
    fGetEditValue : tSetupEditor;
    fColumn: integer;
    fParentAutoSizeColumn: boolean;
    fAutoSizeColumn: boolean;
    fImages: tImageList;
    fOnGetImageIndex: tSigGetImageIndex;
    fStringList: tStringList;
    fParentColWidth: boolean;
    fColWidth: integer;
    fEditorEntered : boolean;
    fAllowUseToRight: boolean;
    fItemsList: tStringList;
    fVisible: boolean;
    fOnKeyPress: tKeyPressEvent;
    fMaxLen: integer;
    fMaxVal: integer;
    fMinVal: integer;
    fOnClick: tNotifyEvent;
    fInstantAction: boolean;
    procedure OnButtonClick( Sender : tObject );
    procedure SetSigGrid(const Value: TSigGeneralGrid);
    procedure SetStyle(const Value: tSigEditorStyle);
    procedure GetSpinEditValue( const Value : string );
    function GetSpinEdit: tSigSpinEdit;
    procedure EditorExit( Sender : tObject );
    procedure OnSpinEditChange( Sender : tObject );
    function GetComboBox: tComboBox;
    procedure SetAutoSizeColumn(const Value: boolean);
    procedure GetDropDownListEditValue( const Value : string );
    procedure GetDropDownImageListEditValue( const Value : string );
    procedure GetDropDownEditValue( const Value : string );
    procedure GetMaskEditValue( const Value : string );
    procedure GetButtonEditValue( const Value : string );
    procedure OnDropDownListChange( Sender : tObject );
    procedure OnDropDownImageListChange( Sender : tObject );
    procedure OnMaskEditChange( Sender : tObject );
    function GetStrings: tStrings;
    function GetMaskEdit: tMaskEdit;
    procedure SetStringList(const Value: tStringList);
    procedure SetColumn(const Value: integer);
    procedure SetParentColWidth(const Value: boolean);
    procedure SetColWidth(const Value: integer);
    procedure SetImages(const Value: tImageList);
    procedure SetAllowUseToRight(const Value: boolean);
    procedure SetParentAutoSizeColumn(const Value: boolean);
    procedure SetItemsList(const Value: tStringList);
    procedure OnDropDownImageListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SetVisible(const Value: boolean);
    procedure SetOnKeyPress(const Value: tKeyPressEvent);
    procedure SetMaxLen(const Value: integer);
    procedure SetMaxVal(const Value: integer);
    procedure SetMinVal(const Value: integer);
    function GetButton: tBitBtn;
    procedure SetOnClick(const Value: tNotifyEvent);
    function GetCellRowBeingEdited: integer;
    procedure SetCellRowBeingEdited(const Value: integer);
    function GetCellColBeingEdited: integer;
    procedure SetCellColBeingEdited(const Value: integer);
  protected
    //procedure HandleVisualChange;
    procedure ShowEditor( const pVisible : boolean; const pRect : tRect );
    property SpinEdit : tSigSpinEdit
             read GetSpinEdit;
    property ComboBox : tComboBox
             read GetComboBox;
    property MaskEdit : tMaskEdit
             read GetMaskEdit;
    property Button : tBitBtn
             read GetButton;
    procedure CheckColWidth( const pCol : integer; const Value : string );
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Editor : tWinControl
             read fEditor
             stored FALSE;
    property CellRowBeingEdited : integer
             read GetCellRowBeingEdited
             write SetCellRowBeingEdited
             stored FALSE;
    property CellColBeingEdited : integer
             read GetCellColBeingEdited
             write SetCellColBeingEdited
             stored FALSE;
    property Items : tStrings
             read GetStrings;
    property Visible : boolean
             read fVisible
             write SetVisible;

    procedure DrawCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect;
              const State: TGridDrawState; const pCell : tSigGeneralGridCell;
              const OwnerEnabled : boolean; const OwnerFocused : boolean;
              const CellEnabled : boolean; const ErrorText : string );
    procedure PrintCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; Value : string );
    function DesiredRowHeight( const DefaultTextHeight : integer ) : integer;
    procedure DrawString( Canvas : TCanvas; Rect : TRect; Value : string );
    function AutoSizeCol : boolean;
    class function ScrollBarWidth : integer;

  published
    property SigGrid : TSigGeneralGrid
             read fSigGrid
             write SetSigGrid;
    property Style : tSigEditorStyle
             read fStyle
             write SetStyle
             default esNone;
    property Column : integer
             read fColumn
             write SetColumn
             default 0;
    property ParentAutoSizeColumn : boolean
             read fParentAutoSizeColumn
             write SetParentAutoSizeColumn
             default TRUE;
    property AutoSizeColumn : boolean
             read fAutoSizeColumn
             write SetAutoSizeColumn
             default FALSE;
    property Images : tImageList
             read fImages
             write SetImages;
    property OnGetImageIndex : tSigGetImageIndex
             read fOnGetImageIndex
             write fOnGetImageIndex;
    property Titles : tStringList
             read fStringList
             write SetStringList;
    property ParentColWidth : boolean
             read fParentColWidth
             write SetParentColWidth
             default TRUE;
    property ColWidth : integer
             read fColWidth
             write SetColWidth
             default 64;
    property AllowUseToRight : boolean
             read fAllowUseToRight
             write SetAllowUseToRight
             default FALSE;
    property ItemsList : tStringList
             read fItemsList
             write SetItemsList;
    property OnKeyPress : tKeyPressEvent
             read fOnKeyPress
             write SetOnKeyPress;
    property MaxLength : integer
             read fMaxLen
             write SetMaxLen
             default 0;
    property MaxVal : integer
             read fMaxVal
             write SetMaxVal
             default 0;
    property MinVal : integer
             read fMinVal
             write SetMinVal
             default 0;
    property OnClick : tNotifyEvent
             read fOnClick
             write SetOnClick;
    property InstantAction : boolean
             read fInstantAction
             write fInstantAction
             default TRUE;

    procedure ResetText( const pCol, pRow : integer; const pNewVal : string );
  end;

  tSigEditorList = class( tObjectList )
  private
    fParent: tSigGeneralGrid;
    fVisible: boolean;
    fOnKeyPress: tKeyPressEvent;
    function GetEditor(const pColumn : integer): tSigGridEditor;
    function GetEditorType(const pColumn: integer): tSigEditorStyle;
    function GetChoiceStrings(const pCol: integer): tStrings;
    procedure SetVisible(const Value: boolean);
    procedure SetOnKeyPress(const Value: tKeyPressEvent);
  public
    constructor Create( const pParent : tSigGeneralGrid ); reintroduce;
    destructor Destroy; override;

    property ParentAsGrid : tSigGeneralGrid
             read fParent;
    property Editor[ const pColumn : integer ] : tSigGridEditor
             read GetEditor;
    property EditorType[ const pColumn : integer ] : tSigEditorStyle
             read GetEditorType;
    property ChoiceStrings[ const pCol : integer ] : tStrings
             read GetChoiceStrings;
    property Visible : boolean
             read fVisible
             write SetVisible;

    property OnKeyPress : tKeyPressEvent
             read fOnKeyPress
             write SetOnKeyPress;

    procedure DrawCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; const State: TGridDrawState;
              const pCell : tSigGeneralGridCell; const OwnerEnabled : boolean; const OwnerFocused : boolean;
              const CellEnabled : boolean; const ErrorText : string );

    procedure PrintCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; Value : string );

    procedure RegisterEditor( NewVal : tSigGridEditor );
    procedure UnregisterEditor( OldVal : tSigGridEditor );

  end;

  tSigGeneralGridCellList = class;

  tSigGeneralGridCell = class
  private
    fRow: integer;
    fCol: integer;
    fText: string;
    fError: boolean;
    fOwner: tSigGeneralGridCellList;
    fEnabled: boolean;
    fErrorText: string;
    fCellObject: tObject;
    procedure SetText(const Value: string);
    procedure SetErrorText(const Value: string);
  public
    constructor Create( const pCol, pRow : integer; const pOwner : tSigGeneralGridCellList );
    property Row : integer
             read fRow;
    property Column : integer
             read fCol;
    property Text : string
             read fText
             write SetText;
    property Error : boolean // defines which font to use for this cell
             read fError
             write fError;
    property ErrorText : string // defines which font to use for this cell
             read fErrorText
             write SetErrorText;
    property Owner : tSigGeneralGridCellList
             read fOwner;
    property Enabled : boolean
             read fEnabled
             write fEnabled;
    property CellObject : tObject
             read fCellObject
             write fCellObject;
  end;

  tSigGeneralGridCellList = class( tObjectList )
  private
    fOwner: TSigGeneralGrid;
    function GetSigGeneralGridCell(const Col, Row : integer; ForceCreate : boolean = FALSE ): tSigGeneralGridCell;
    function GetCell(const Col, Row: integer): string;
    procedure SetCell(const Col, Row: integer; const Value: string);
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
    function GetEnabled(const Col, Row: integer): boolean;
    procedure SetEnabled(const Col, Row: integer; const Value: boolean);
    function GetErrorText(const Col, Row: integer): string;
    procedure SetErrorText(const Col, Row: integer; const Value: string);
    function GetCellObject(const Col, Row: integer): tObject;
    procedure SetCellObject(const Col, Row: integer; const Value: tObject);
{
    property SigGeneralGridCell[ const Col, Row : integer ] : tSigGeneralGridCell
             read GetSigGeneralGridCell;
}
  public
    constructor Create( pOwner : TSigGeneralGrid ); reintroduce;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property CellObject[ const Col, Row : integer ] : tObject
             read GetCellObject
             write SetCellObject;
    property InError[ const Col, Row : integer ] : boolean
             read GetError
             write SetError;
    property ErrorText[ const Col, Row : integer ] : string
             read GetErrorText
             write SetErrorText;
    property Enabled[ const Col, Row : integer ] : boolean
             read GetEnabled
             write SetEnabled;
    property Owner : TSigGeneralGrid
             read fOwner;
  end;

  tOnPrint = procedure( const pCanvas : tCanvas; const pRect : tRect; var pTop, pBottom : integer;
                        const pPage, pOfPages : integer; pCalculatingPages : boolean ) of object;

  TSigGeneralGrid = class(TDrawGrid)
  private
    { Private declarations }
    fEditorList : tSigEditorList;
    fSigCells : tSigGeneralGridCellList;
    fTextHMargin: integer;
    fAutosizeRows: boolean;
    fTextVMargin100: integer;
    fMinRowHeight: integer;
    fAutoSizeCols: boolean;
    fNormalFont: TFont;
    fErrorFont: TFont;
    fOnCellChange: tOnCellChange;
    fOnCellEditChange: tOnCellChange;
    fFocused : boolean;
    fOnPrintHeader: tOnPrint;
    fOnPrintFooter: tOnPrint;
    fRowBeingEdited: integer;
    fOnRowSelectionChange: tOnEditorSelectionChange;
    fColBeingEdited: integer;
    fOnColSelectionChange: tOnEditorSelectionChange;
    function GetCell(const Col, Row : integer): string;
    procedure SetCell(const Col, Row : integer; const Value: string);
    procedure SetTextHMargin(const Value: integer);
    procedure SetAutosizeRows(const Value: boolean);
    function GetColumnEditStyle(const pCol: integer): tSigEditorStyle;
    procedure SetTextVMargin100(const Value: integer);
    procedure SetMinRowHeight(const Value: integer);
    function GetImageList(const pCol: integer): tImageList;
    function GetChoiceStrings(const pCol: integer): tStrings;
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
    procedure SetErrorFont(const Value: TFont);
    procedure SetNormalFont(const Value: TFont);
    function GetEditor(const pCol: integer): tSigGridEditor;
    procedure SetAutoSizeCols(const Value: boolean);
    procedure SetVisible(const Value: boolean);
    function GetVisible: boolean;
    function GetCellEnabled(const Col, Row: integer): boolean;
    procedure SetCellEnabled(const Col, Row: integer; const Value: boolean);
    function GetErrorText(const Col, Row: integer): string;
    procedure SetErrorText(const Col, Row: integer; const Value: string);
    function GetCellObject(const Col, Row: integer): tObject;
    procedure SetCellObject(const Col, Row: integer; const Value: tObject);
    procedure SetOnKeyPress(const Value: tKeyPressEvent);
    procedure SetRowBeingEdited(const Value: integer);
    procedure SetColBeingEdited(const Value: integer);
  protected
    { Protected declarations }
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure RecalculateRowHeights;

    procedure RegisterEditor( NewVal : tSigGridEditor );
    procedure UnregisterEditor( OldVal : tSigGridEditor );

    procedure DoEnter; override;
    procedure DoExit; override;

    procedure InvalidateEditor( const ACol, ARow : integer; const pNewVal : string );

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property ColumnEditStyle[ const pCol : integer ] : tSigEditorStyle
             read GetColumnEditStyle;
    property ImageList[ const pCol : integer ] : tImageList
             read GetImageList;
    property ChoiceStrings[ const pCol : integer ] : tStrings
             read GetChoiceStrings;
    property Error[ const Col, Row : integer ] : boolean
             read GetError
             write SetError;
    property ErrorText[ const Col, Row : integer ] : string
             read GetErrorText
             write SetErrorText;
    property CellEnabled[ const Col, Row : integer ] : boolean
             read GetCellEnabled
             write SetCellEnabled;
    property CellObject[ const Col, Row : integer ] : tObject
             read GetCellObject
             write SetCellObject;
    property Editor[ const pCol : integer ] : tSigGridEditor
             read GetEditor;

    function MaxTextWidth( const Col : integer ) : integer;

    procedure ClearCells;

    function ExportCSV( const pFileName : string ) : boolean;

    procedure Print( const pStartPage : integer; var pPageCount : integer;
              const pCanvas : tCanvas; const pRect : tRect; const pCalculatingPages : boolean );

    procedure PrintCell( const pCol, pLine : integer; const pCanvas : tCanvas;
                         const pLeft : integer; const pCurrentTop, pLineHeight,
                         pCellWidth, pScaleFactor : integer );

    procedure PrintLine( const pLine : integer; const pCanvas : tCanvas; const pRect : tRect;
                         var pCurrentPage, pPageCount, pCurrentTop, pCurrentBottom : integer;
                         const pLeftMargin, pScaleFactor : integer; const pCalculatingPages : boolean );
    function PrintLineHeight( const pLine : integer; const pCanvas : tCanvas; const pScaleFactor : integer ) : integer;
    function PrintColWidth( const pCol : integer; const pCanvas : tCanvas; const pScaleFactor : integer ) : integer;
    procedure GetPrintParms( const pCanvas : tCanvas; const pRect : tRect; var pScaleFactor : integer; var pLeft : integer );
    property RowBeingEdited : integer
             read fRowBeingEdited
             write SetRowBeingEdited;
    property ColBeingEdited : integer
             read fColBeingEdited
             write SetColBeingEdited;
  published
    { Published declarations }
    property AutoSizeRows : boolean
             read fAutosizeRows
             write SetAutosizeRows
             default FALSE;
    property AutoSizeCols : boolean
             read fAutoSizeCols
             write SetAutoSizeCols
             default FALSE;
    property TextHMargin : integer
             read fTextHMargin
             write SetTextHMargin
             default -1;
    property TextVMargin100 : integer
             read fTextVMargin100
             write SetTextVMargin100
             default 25;
    property MinRowHeight : integer
             read fMinRowHeight
             write SetMinRowHeight
             default 16;
    property NormalFont : TFont
             read fNormalFont
             write SetNormalFont;
    property ErrorFont : TFont
             read fErrorFont
             write SetErrorFont;
    property Visible : boolean
             read GetVisible
             write SetVisible;

    property OnCellChange : tOnCellChange  // called whenever a Cell Changes
             read fOnCellChange
             write fOnCellChange;
    property OnCellEditChange : tOnCellChange   // only called when an editor changes a value
             read fOnCellEditChange
             write fOnCellEditChange;
    property OnRowSelectionChange : tOnEditorSelectionChange
             read fOnRowSelectionChange
             write fOnRowSelectionChange;
    property OnColSelectionChange : tOnEditorSelectionChange
             read fOnColSelectionChange
             write fOnColSelectionChange;

    property OnKeyPress
             write SetOnKeyPress;

    property OnPrintHeader : tOnPrint
             read fOnPrintHeader
             write fOnPrintHeader;
    property OnPrintFooter : tOnPrint
             read fOnPrintFooter
             write fOnPrintFooter;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [ TSigGeneralGrid, TSigGridEditor ]);
  //RegisterComponents('SigNET', [  ]);
end;

{ tSigEditorList }

constructor tSigEditorList.Create( const pParent : tsigGeneralGrid );
begin
  inherited Create( FALSE );
  fParent := pParent;
  //Visible := fParent.Visible;  editor never visible by default
end;

destructor tSigEditorList.Destroy;
var
  i: Integer;
  iEditor : tSigGridEditor;
begin
  // disconnect editors from parent
  for i := 0 to Count - 1 do
  begin
    iEditor := Editor[ i ];
    if assigned( iEditor ) then
    begin
      iEditor.SigGrid := nil;
    end;
  end;
  inherited;
end;

procedure tSigEditorList.DrawCell(Canvas: TCanvas; ACol, ARow: Integer;
  Rect: TRect; const State: TGridDrawState; const pCell : tSigGeneralGridCell;
  const OwnerEnabled : boolean; const OwnerFocused : boolean;
  const CellEnabled : boolean; const ErrorText : string );
var
  iEditor : tSigGridEditor;
begin
  iEditor := Editor[ ACol ];
  if assigned( iEditor ) then
  begin
    iEditor.DrawCell( Canvas, ACol, ARow, Rect, State, pCell, OwnerEnabled, OwnerFocused, CellEnabled, ErrorText);
  end
  else if assigned( pCell ) then
  begin
    Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, pCell.Text );
  end
  else
  begin
    Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, '' );
  end;
end;

function tSigEditorList.GetChoiceStrings(const pCol: integer): tStrings;
var
  iEditor : tSigGridEditor;
begin
  iEditor := Editor[ pCol ];
  if assigned( iEditor ) then
  begin
    Result := iEditor.Items;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSigEditorList.GetEditor(const pColumn : integer): tSigGridEditor;
var
  i: Integer;
  iBestSoFar : integer;
  iBestColSoFar : integer;
begin
  iBestSoFar := -1;
  iBestColSoFar := -1;
  for i := 0 to Count - 1 do
  begin
    try
      Result := Items[ i ] as tSigGridEditor;
      if Result.Column = pColumn then
      begin
        exit;
      end;
      // else
      if Result.Column < pColumn then
      begin
        if Result.AllowUseToRight then
        begin
          if Result.Column > iBestColSoFar then
          begin
            iBestColSoFar := Result.Column;
            iBestSoFar := i;
          end;
        end;
      end;
    except

    end;
  end;
  // else
  if iBestSoFar >= 0 then
  begin
    Result := Items[ iBestSoFar ] as tSigGridEditor;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSigEditorList.GetEditorType(const pColumn: integer): tSigEditorStyle;
var
  iEditor : tSigGridEditor;
begin
  iEditor := Editor[ pColumn ];
  if assigned( iEditor ) then
  begin
    Result := iEditor.Style;
  end
  else
  begin
    Result := esNone;
  end;
end;

procedure tSigEditorList.PrintCell(Canvas: TCanvas; ACol, ARow: Integer;
  Rect: TRect; Value: string);
var
  iEditor : tSigGridEditor;
begin
  iEditor := Editor[ ACol ];
  if assigned( iEditor ) then
  begin
    iEditor.PrintCell( Canvas, ACol, ARow, Rect, Value);
  end
  else
  begin
    Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, Value );
  end;
end;

procedure tSigEditorList.RegisterEditor(NewVal: tSigGridEditor);
begin
  Add( NewVal );
  NewVal.Visible := fVisible;
  NewVal.OnKeyPress := self.OnKeyPress;
end;

procedure tSigEditorList.SetOnKeyPress(const Value: tKeyPressEvent);
var
  i: Integer;
begin
  fOnKeyPress := Value;
  for i := 0 to Count - 1 do
  begin
    (Items[ i ] as tSigGridEditor).OnKeyPress := self.OnKeyPress;
  end;
end;

procedure tSigEditorList.SetVisible(const Value: boolean);
var
  i: Integer;
begin
  fVisible := Value;
  for i := 0 to Count - 1 do
  begin
    Editor[ i ].Visible := Value;
  end;
end;

procedure tSigEditorList.UnregisterEditor(OldVal: tSigGridEditor);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ] = OldVal then
    begin
      Delete( i );
      exit;
    end;
  end;
end;

{ TSigGeneralGrid }

procedure TSigGeneralGrid.ClearCells;
begin
  fSigCells.Clear;
end;

constructor TSigGeneralGrid.Create(AOwner: TComponent);
begin
  inherited;

  fEditorList := tSigEditorList.Create( self );

  fSigCells := tSigGeneralGridCellList.Create( self );

  fTextHMargin := -1; // use width of 'X' char as a Text Margin.
                      // all text columns use the same margin
  fTextVMargin100 := 25; // The space above and below text as a percentage of text height
  fMinRowHeight := 16;

  fNormalFont := TFont.Create;
  fErrorFont  := TFont.Create;

  fNormalFont.Assign( Font );
  fErrorFont.Assign( Font );
end;

destructor TSigGeneralGrid.Destroy;
begin
  FreeAndNil( fEditorList );
  FreeAndNil( fSigCells );

  FreeAndNil( fNormalFont );
  FreeAndNil ( fErrorFont );

  inherited;
end;

procedure TSigGeneralGrid.DoEnter;
begin
  inherited;
  fFocused := TRUE;
  invalidate
end;

procedure TSigGeneralGrid.DoExit;
begin
  inherited;
  fFocused := FALSE;
  invalidate;
end;

procedure TSigGeneralGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
begin
  inherited;
  if Error[ ACol, ARow ] then
  begin
    Canvas.Font.Assign( ErrorFont );
  end
  else
  begin
    Canvas.Font.Assign( NormalFont );
  end;
  //fEditorList.DrawCell( Canvas, ACol, ARow, ARect, AState, Cell[ ACol, ARow ],
  fEditorList.DrawCell( Canvas, ACol, ARow, ARect, AState, fSigCells.GetSigGeneralGridCell( ACol, ARow, TRUE ),
                        Enabled, fFocused, CellEnabled[ ACol, ARow ], ErrorText[ ACol, ARow ] );
end;

function TSigGeneralGrid.ExportCSV(const pFileName: string) : boolean;
var
  iStringList : tStringList;
  i, j: Integer;
  iValue : string;
  iLine : string;
  iEditor : tSigGridEditor;
begin

  //Result := FALSE;
  iStringList := tStringList.Create;
  try
    for i := 0 to RowCount - 1 do
    begin
      iLine := '';
      for j := 0 to ColCount - 1 do
      begin
        iEditor := fEditorList.Editor[ j ];
        iValue := Cell[ j, i ];
        if (iValue = '') and assigned( iEditor ) then
        begin
          if (i < iEditor.Titles.Count ) then
          begin
            iValue := iEditor.Titles[ i ];
          end;
        end;
        iLine := iLine + '"' + iValue + '"';
        if j < (ColCount - 1) then
        begin
          iLine := iLine + ',';
        end;
      end;
      iStringList.Add( iLine );
    end;
    iStringList.SaveToFile( pFileName );
    Result := TRUE;
  finally
    iStringList.Free;
  end;
end;

function TSigGeneralGrid.GetCell(const Col, Row : integer): string;
begin
  Result := fSigCells.Cell[ Col, Row ];
end;

function TSigGeneralGrid.GetCellEnabled(const Col, Row: integer): boolean;
begin
  //Result := TRUE;
  Result := fSigCells.Enabled[ Col, Row ];
end;

function TSigGeneralGrid.GetCellObject(const Col, Row: integer): tObject;
begin
  Result := fSigCells.CellObject[ Col, Row ];
end;

function TSigGeneralGrid.GetChoiceStrings(const pCol: integer): tStrings;
begin
  Result := fEditorList.ChoiceStrings[ pCol ];
end;

function TSigGeneralGrid.GetColumnEditStyle(
  const pCol: integer): tSigEditorStyle;
begin
  Result := fEditorList.EditorType[ pCol ];
end;

function TSigGeneralGrid.GetEditor(const pCol: integer): tSigGridEditor;
begin
  Result := fEditorList.Editor[ pCol ];
end;

function TSigGeneralGrid.GetError(const Col, Row: integer): boolean;
begin
  Result := fSigCells.InError[ Col, Row ];
end;

function TSigGeneralGrid.GetErrorText(const Col, Row: integer): string;
begin
  Result := fSigCells.ErrorText[ Col, Row ];
end;

function TSigGeneralGrid.GetImageList(const pCol: integer): tImageList;
var
  iEditor : tSigGridEditor;
begin
  iEditor := fEditorList.Editor[ pCol ];
  if assigned( iEditor ) then
  begin
    Result := fEditorList.Editor[ pCol ].Images;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure TSigGeneralGrid.GetPrintParms(const pCanvas: tCanvas; const pRect : tRect;
  var pScaleFactor, pLeft: integer);
var
  i, iRectWidth, iBaseWidth : integer;
begin
  iRectWidth := pRect.Right - pRect.Left;
  iBaseWidth := GridLineWidth;
  for i := 0 to ColCount - 1 do
  begin
    inc( iBaseWidth, ColWidths[ i ] );
    inc( iBaseWidth, GridLineWidth );
  end;
  pScaleFactor := iRectWidth div iBaseWidth;
  if pScaleFactor < 1 then
  begin
    raise Exception.Create('Page too narrow to print table');
  end;
  pLeft := (iRectWidth - (pScaleFactor * iBaseWidth)) div 2;
end;

function TSigGeneralGrid.GetVisible: boolean;
begin
  Result := inherited Visible;
end;

procedure TSigGeneralGrid.InvalidateEditor(const ACol, ARow : integer; const pNewVal : string );
begin
  Editor[ ACol ].ResetText( ACol, ARow, pNewVal );
end;

procedure TSigGeneralGrid.SetAutoSizeCols(const Value: boolean);
begin
  if fAutoSizeCols <> Value then
  begin
    fAutoSizeCols := Value;
    InvalidateGrid;
  end;
end;

procedure TSigGeneralGrid.SetAutosizeRows(const Value: boolean);
begin
  if fAutoSizeRows <> Value then
  begin
    fAutosizeRows := Value;
    RecalculateRowHeights;
  end;
end;

procedure TSigGeneralGrid.SetCell(const Col, Row : integer; const Value: string);
begin
  if assigned( fSigCells ) then
  begin
    fSigCells.Cell[ Col, Row ] := Value;
    InvalidateCell( Col, Row );
    InvalidateEditor( Col, Row, Value );
  end;
end;

procedure TSigGeneralGrid.SetCellEnabled(const Col, Row: integer;
  const Value: boolean);
begin
  if fSigCells.Enabled[ Col, Row ] <> Value then
  begin
    fSigCells.Enabled[ Col, Row ] := Value;
    InvalidateCell( Col, Row );
  end;
end;

procedure TSigGeneralGrid.SetCellObject(const Col, Row: integer;
  const Value: tObject);
begin
  fSigCells.CellObject[ Col, Row ] := Value;
end;

procedure TSigGeneralGrid.SetColBeingEdited(const Value: integer);
begin
  if fColBeingEdited <> Value then
  begin
    fColBeingEdited := Value;
    if assigned( fOnColSelectionChange ) then
    begin
      fOnColSelectionChange( self, fColBeingEdited );
    end;
    if Value >= 0 then
    begin
      InvalidateCol( Value );
    end;
  end;
end;

procedure TSigGeneralGrid.SetError(const Col, Row: integer;
  const Value: boolean);
begin
  if fSigCells.InError[ Col, Row ] <> Value then
  begin
    fSigCells.InError[ Col, Row ] := Value;
    InvalidateCell( Col, Row );
  end;
end;

procedure TSigGeneralGrid.SetErrorFont(const Value: TFont);
begin
  fErrorFont.Assign( Value );
end;

procedure TSigGeneralGrid.SetErrorText(const Col, Row: integer;
  const Value: string);
begin
  if fSigCells.ErrorText[ Col, Row ] <> Value then
  begin
    fSigCells.ErrorText[ Col, Row ] := Value;
  end;
end;

procedure TSigGeneralGrid.SetMinRowHeight(const Value: integer);
begin
  fMinRowHeight := Value;
end;

procedure TSigGeneralGrid.SetNormalFont(const Value: TFont);
begin
  fNormalFont.Assign( Value );
end;

procedure TSigGeneralGrid.SetOnKeyPress(const Value: tKeyPressEvent);
begin
  inherited OnKeyPress := Value;
  fEditorList.OnKeyPress := Value;
end;

procedure TSigGeneralGrid.SetRowBeingEdited(const Value: integer);
begin
  if fRowBeingEdited <> Value then
  begin
    fRowBeingEdited := Value;
    if assigned( OnRowSelectionChange ) then
    begin
      OnRowSelectionChange( self, RowBeingEdited );
    end;
    if Value <> -1 then
    begin
      InvalidateRow( Value );
    end;
  end;
end;

procedure TSigGeneralGrid.SetTextHMargin(const Value: integer);
begin
  fTextHMargin := Value;
end;

procedure TSigGeneralGrid.SetTextVMargin100(const Value: integer);
begin
  fTextVMargin100 := Value;
end;

procedure TSigGeneralGrid.SetVisible(const Value: boolean);
begin
  inherited Visible := Value;
  //fEditorList.Visible := Value;
end;

procedure TSigGeneralGrid.UnregisterEditor(OldVal: tSigGridEditor);
begin
  if not (csDestroying in ComponentState) then
  begin
    if assigned( fEditorList )  then
    begin
      fEditorList.UnregisterEditor( OldVal );
      RecalculateRowHeights
    end;
  end;
end;

function TSigGeneralGrid.MaxTextWidth(const Col: integer) : integer;
var
  i, iNewColWidth : integer;
begin
  Result := ColWidths[ Col ];

  if assigned( Canvas ) then
  begin
    for i := 0 to RowCount - 1 do
    begin
      iNewColWidth := Canvas.TextWidth( fSigCells.Cell[ Col, i ] );
      if iNewColWidth > Result then
      begin
       Result := iNewColWidth;
      end;
    end;
  end;
end;

procedure TSigGeneralGrid.Print(const pStartPage: integer;
  var pPageCount: integer; const pCanvas: tCanvas; const pRect: tRect;
  const pCalculatingPages: boolean);
var
  i, iCurrentPage : integer;
  iCurrentTop, iCurrentBottom : integer;
  iScaleFactor : integer;
  iBaseWidth, iRectWidth : integer;
  iLeftMargin : integer;
begin
  iCurrentPage := pStartPage - 1;
  iCurrentBottom := pRect.Bottom;
  iCurrentTop := iCurrentBottom;
  iRectWidth := pRect.Right - pRect.Left;
  iBaseWidth := GridLineWidth;
  for i := 0 to ColCount - 1 do
  begin
    inc( iBaseWidth, ColWidths[ i ] );
    inc( iBaseWidth, GridLineWidth );
  end;
  iScaleFactor := iRectWidth div iBaseWidth;
  if iScaleFactor < 1 then
  begin
    raise Exception.Create('Page too narrow to print table');
  end
  else
  begin
    iScaleFactor := 1;
  end;
  iLeftMargin := (iRectWidth - (iScaleFactor * iBaseWidth)) div 2;
  for i := 0 to RowCount - 1 do
  begin
    PrintLine( i, pCanvas, pRect, iCurrentPage, pPageCount, iCurrentTop, iCurrentBottom,
               iLeftMargin, iScaleFactor, pCalculatingPages );
  end;
end;

procedure TSigGeneralGrid.PrintCell(const pCol, pLine: integer;
  const pCanvas: tCanvas; const pLeft: integer; const pCurrentTop, pLineHeight,
  pCellWidth, pScaleFactor: integer);
var
  iRect : tRect;
  iDelta : integer;
begin
  if Error[ pCol, pLine ] then
  begin
    pCanvas.Font.Assign( ErrorFont );
  end
  else
  begin
    pCanvas.Font.Assign( NormalFont );
  end;
  iDelta := GridLineWidth * pScaleFactor;
  iRect.Top := pCurrentTop;
  iRect.Bottom := pCurrentTop + pLineHeight - iDelta;
  iRect.Left := pLeft;
  iRect.Right := iRect.Left + pCellWidth;
  pCanvas.Pen.Color := clBlack;
  pCanvas.Pen.Width := iDelta;
  if (pLine < FixedRows) or (pCol < FixedCols) then
  begin
    pCanvas.Brush.Color := clSilver;
  end
  else
  begin
    pCanvas.Brush.Color := clWhite;
  end;
  pCanvas.Rectangle( iRect );
  inc( iRect.Top, iDelta );
  dec( iRect.Bottom, iDelta );
  inc( iRect.Left, iDelta );
  dec( irect.Right, iDelta );
  fEditorList.PrintCell( pCanvas, pCol, pLine, iRect, Cell[ pCol, pLine ] );
end;

procedure TSigGeneralGrid.PrintLine(const pLine: integer;
  const pCanvas: tCanvas; const pRect: tRect; var pCurrentPage, pPageCount,
  pCurrentTop, pCurrentBottom: integer; const pLeftMargin,
  pScaleFactor: integer; const pCalculatingPages: boolean);
var
  iLineHeight : integer;
  iCellWidth : integer;
  i: Integer;
  iLeft : integer;
begin
  iLineHeight := PrintLineHeight( pLine, pCanvas, pScaleFactor );
  if (pCurrentTop + iLineheight) > pCurrentBottom then
  begin
    inc( pCurrentPage );
    pCurrentBottom := pRect.Bottom;
    pCurrentTop := pRect.Top;
    if assigned( fOnPrintFooter ) then
    begin
      fOnPrintFooter( pCanvas, pRect, pCurrentTop, pCurrentBottom, pCurrentPage, pPageCount, pCalculatingPages );
    end;
    if assigned( fOnPrintHeader ) then
    begin
      fOnPrintHeader( pCanvas, pRect, pCurrentTop, pCurrentBottom, pCurrentPage, pPageCount, pCalculatingPages );
    end;
  end;
  if not pCalculatingPages then
  begin
    iLeft := pLeftMargin;
    for i := 0 to ColCount - 1 do
    begin
      iCellWidth := (ColWidths[ i ] + 2 * GridLineWidth ) * pScaleFactor;
      PrintCell( i, pLine, pCanvas, iLeft, pCurrentTop, iLineHeight, iCellWidth, pScaleFactor );
      inc( iLeft, iCellWidth - GridLineWidth * pScaleFactor );
    end;
  end;
  inc( pCurrentTop, iLineHeight );
end;

function TSigGeneralGrid.PrintColWidth(const pCol : integer;
  const pCanvas: tCanvas; const pScaleFactor: integer): integer;
begin
  Result := (ColWidths[ pCol ] + 2 * GridLineWidth ) * pScaleFactor;
end;

function TSigGeneralGrid.PrintLineHeight(const pLine: integer;
  const pCanvas: tCanvas; const pScaleFactor: integer): integer;
begin
  Result := (RowHeights[ pLine ] + GridLineWidth) * pScaleFactor;
end;

procedure TSigGeneralGrid.RecalculateRowHeights;
var
  iNewRowValue, iNewRowValue2 : integer;
  iTextHeight : integer;
  i: Integer;
  iEditor : tSigGridEditor;
begin
  if not (csDestroying in ComponentState) then
  begin
    if fAutosizeRows then
    begin
      iNewRowValue := 0;
      iTextHeight := Canvas.TextHeight( 'X' );
      iTextHeight := (iTextHeight * ( 100 + 2* fTextVMargin100 )) div 100;
      for i := 0 to ColCount - 1 do
      begin
        iEditor := fEditorList.Editor[ i ];
        if assigned( iEditor ) then
        begin
          iNewRowValue2 := iEditor.DesiredRowHeight( iTextHeight );
          if iNewRowValue2 > iNewRowValue then
          begin
            iNewRowValue := iNewRowValue2;
          end;
        end;
      end;
      if iNewRowValue < fMinRowHeight then
      begin
        iNewRowValue := fMinRowHeight;
      end;
      DefaultRowHeight := iNewRowValue;
    end;
  end;
end;

procedure TSigGeneralGrid.RegisterEditor(NewVal: tSigGridEditor);
begin
  fEditorList.RegisterEditor( NewVal );
  RecalculateRowHeights;
end;

{ tSigGeneralGridCell }

constructor tSigGeneralGridCell.Create(const pCol, pRow: integer; const pOwner : tSigGeneralGridCellList);
begin
  inherited Create;

  fRow := pRow;
  fCol := pCol;

  fOwner := pOwner;

  fText := '';

  fEnabled := TRUE;

end;

procedure tSigGeneralGridCell.SetErrorText(const Value: string);
begin
  if fErrorText <> Value then
  begin
    fErrorText := Value;
  end;
end;

procedure tSigGeneralGridCell.SetText(const Value: string);
begin
  if fText <> Value then
  begin
    fText := Value;
    if assigned( Owner ) then
    begin
      if assigned( Owner.Owner ) then
      begin
        if assigned( Owner.Owner.OnCellChange ) then
        begin
          Owner.Owner.OnCellChange( self, fCol, fRow, Value );
        end;
      end;
    end;
  end;
end;

{ tSigGeneralGridCellList }

constructor tSigGeneralGridCellList.Create( pOwner : TSigGeneralGrid );
begin
  inherited Create( TRUE );

  fOwner := pOwner;

end;

function tSigGeneralGridCellList.GetCell(const Col, Row: integer): string;
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.Text;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigGeneralGridCellList.GetCellObject(const Col,
  Row: integer): tObject;
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, FALSE );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.CellObject;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSigGeneralGridCellList.GetEnabled(const Col, Row: integer): boolean;
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.Enabled;
  end
  else
  begin
    Result := TRUE;
  end;
end;

function tSigGeneralGridCellList.GetError(const Col, Row: integer): boolean;
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.Error;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function tSigGeneralGridCellList.GetErrorText(const Col, Row: integer): string;
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.ErrorText;
  end
  else
  begin
    Result := '';
  end;
end;

function tSigGeneralGridCellList.GetSigGeneralGridCell(const Col,
  Row : integer; ForceCreate : boolean): tSigGeneralGridCell;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[ i ] as tSigGeneralGridCell;
    if Result.Column = Col then
    begin
      if Result.Row = Row then
      begin
        exit;
      end
      else if Result.Row > Row then
      begin
        if ForceCreate then
        begin
          Result := tSigGeneralGridCell.Create( Col, Row, self );
          Insert( i, Result );
        end
        else
        begin
          Result := nil;
        end;
        exit;
      end;
    end
    else if Result.Column > Col then
    begin
      if ForceCreate then
      begin
        Result := tSigGeneralGridCell.Create( Col, Row, self);
        Insert( i, Result );
      end
      else
      begin
        Result := nil;
      end;
      exit;
    end;
  end;
  if ForceCreate then
  begin
    Result := tSigGeneralGridCell.Create( Col, Row, self);
    Add( Result );
  end
  else
  begin
    Result := nil;
  end;
end;

procedure tSigGeneralGridCellList.SetCell(const Col, Row: integer;
  const Value: string);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Text := Value;
end;

procedure tSigGeneralGridCellList.SetCellObject(const Col, Row: integer;
  const Value: tObject);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.CellObject := Value;
end;

procedure tSigGeneralGridCellList.SetEnabled(const Col, Row: integer;
  const Value: boolean);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Enabled := Value;
end;

procedure tSigGeneralGridCellList.SetError(const Col, Row: integer;
  const Value: boolean);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Error := Value;
end;

procedure tSigGeneralGridCellList.SetErrorText(const Col, Row: integer;
  const Value: string);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.ErrorText := Value;
end;

{ tSigGridEditor }

function tSigGridEditor.AutoSizeCol: boolean;
begin
  if ParentAutoSizeColumn then
  begin
    Result := fSigGrid.AutoSizeCols;
  end
  else
  begin
    Result := AutoSizeColumn;
  end;
end;

procedure tSigGridEditor.CheckColWidth(const pCol : integer; const Value: string);
var
  iWidth : integer;
  iAutoSizeCol : boolean;
begin
  try
    if (not ParentColWidth) and (not AutoSizeCol) then
    begin
      SigGrid.ColWidths[ pCol ] := ColWidth;
      exit;
    end;
    // else
    if ParentAutoSizeColumn then
    begin
      iAutoSizeCol := SigGrid.AutoSizeCols;
    end
    else
    begin
      iAutoSizeCol := AutoSizeColumn;
    end;
    if iAutoSizeCol then
    begin
      iWidth := 0;
      case fStyle of
        esNone:
        begin
          iWidth := SigGrid.Canvas.TextWidth( Value + 'XX' );
        end;
        esButton,
        esMaskEdit:
        begin
          iWidth := SigGrid.Canvas.TextWidth( Value + 'XX' );
        end;
        esSpinEdit,
        esDropDown,
        esDropDownList:
        begin
          iWidth := SigGrid.Canvas.TextWidth( Value + 'XX' ) + 16; // allow for spinner or drop down icon
        end;
        esImageList: ;
        esDropDownImageList: ;
{
        begin
          if assigned( Images ) then
          begin
            fEditor.Width := Images.Width + ScrollBarWidth;
          end;
        end;
}
      end;
      if iWidth > SigGrid.ColWidths[ pCol ] then
      begin
        SigGrid.ColWidths[ pCol ] := iWidth;
        fEditor.Width := iWidth;
      end;
    end;
  except;
  end;
end;

constructor tSigGridEditor.Create(AOwner: TComponent);
begin
  inherited;

  fStringList := tStringList.Create;

  fParentAutoSizeColumn := TRUE;
  fParentColWidth := TRUE;
  fColWidth := 64;
  fInstantAction := TRUE;
end;

function tSigGridEditor.DesiredRowHeight(
  const DefaultTextHeight: integer): integer;
begin
  case fStyle of
    esNone: Result := 0;
    esButton,
    esSpinEdit,
    esMaskEdit,
    esDropDown,
    esDropDownList: Result := DefaultTextHeight;
    esImageList,
    esDropDownImageList:
    begin
      if assigned( fImages ) then
      begin
        Result := fImages.Height;
      end
      else
      begin
        Result := 0;
      end;
    end;
    else Result := DefaultTextHeight;
  end;
end;

destructor tSigGridEditor.Destroy;
begin
  if assigned( fSigGrid ) then
  begin
    fSigGrid.UnregisterEditor( self );
    fSigGrid.InvalidateGrid;
  end;
  fStringList.Free;
  inherited;
end;

procedure tSigGridEditor.DrawCell(Canvas: TCanvas; ACol, ARow: Integer; Rect: TRect;
  const State: TGridDrawState; const pCell : tSigGeneralGridCell; const OwnerEnabled : boolean;
  const OwnerFocused : boolean; const CellEnabled : boolean; const ErrorText : string );
var
  iImageIndex : integer;
  iValue : string;
begin
  if not fEditorEntered then
  begin
    fEditorEntered := TRUE;
    try
      if assigned( pCell ) then
      begin
        iValue := pCell.Text;
      end
      else
      begin
        iValue := '';
      end;
      //iValue := Value;
      if (iValue = '') and (ARow < Titles.Count ) then
      begin
        iValue := Titles[ ARow ];
      end;
      CheckColWidth( ACol, iValue );
      case fStyle of
        esNone:
        begin
          DrawString( Canvas, Rect, iValue );
        end;
        esSpinEdit,
        esButton,
        esMaskEdit,
        esDropDown,
        esDropDownList:
        begin
          if csDesigning in ComponentState then
          begin
            if ARow = fSigGrid.FixedRows then
            begin
              // resize and show editor
              if (CellRowBeingEdited <> ARow) or (CellColBeingEdited <> ACol ) then
              begin
                if not fEditor.Visible  then
                begin
                  fEditor.Visible := TRUE;
                end;
                if assigned( fGetEditValue ) then
                begin
                  fGetEditValue( iValue ); // don't use titles in editor!
                end;
                //fEditor.Top := fSigGrid.Top + Rect.Top + 2;
                fEditor.Top := fSigGrid.Top + 2 + ((Rect.Bottom + Rect.Top - fEditor.Height ) div 2);
                fEditor.Left := fSigGrid.Left + Rect.Left + 2;
                fEditor.Width := Rect.Right - Rect.Left;
              end;
            end
            else
            begin
              DrawString( Canvas, Rect, iValue );
            end;
          end
          else
          begin
            if (gdSelected {gdFocused} in State) and OwnerEnabled and CellEnabled then
            begin
              if OwnerFocused or fEditor.Focused then
              begin
                // resize and show editor
                if (CellRowBeingEdited <> ARow) or (CellColBeingEdited <> ACol ) then
                begin
                  SigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited );
                  CellRowBeingEdited := ARow;
                  CellColBeingEdited := ACol;
                  // Value may have changed, so recheck
                  if assigned( pCell ) then
                  begin
                    iValue := pCell.Text;
                  end;
                  fEditor.Visible := TRUE;
                  fEditor.Top := fSigGrid.Top + Rect.Top + 2;
                  fEditor.Left := fSigGrid.Left + Rect.Left + 2;
                  fEditor.Width := Rect.Right - Rect.Left;
                  fEditor.Hint := ErrorText;
                  fEditor.ShowHint := ErrorText <> '';
                  fEditor.SetFocus;
                  if assigned( fGetEditValue ) then
                  begin
                    fGetEditValue( iValue ); // don't use titles in editor!
                  end;
                  if fInstantAction then
                  begin
                    if assigned( Button ) then
                    begin
                      OnButtonClick( Self );
                    end
                    else if assigned( Combobox ) then
                    begin
                      if not ComboBox.DroppedDown then
                      begin
                        ComboBox.DroppedDown := TRUE;
                      end;
                    end;
                  end;
                end
                else if fEditor.Focused then
                begin
                  if assigned( fGetEditValue ) then
                  begin
                    fGetEditValue( iValue ); // don't use titles in editor!
                  end;
                end;
              end
              else
              begin
                DrawString( Canvas, Rect, iValue );
              end;
              if assigned( MaskEdit ) then
              begin
                MaskEdit.Font.Assign( Canvas.Font );
              end
              else if assigned( SpinEdit ) then
              begin
                SpinEdit.Font.Assign( Canvas.Font );
              end;
              if assigned( Button ) then
              begin
                Button.Font.Assign( Canvas.Font );
              end;

            end
            else
            begin
              // hide Editor if showing at current location and show text
              if ((CellRowBeingEdited = ARow) and (CellColBeingEdited = ACol)) or (not OwnerEnabled) then
              begin
                fEditor.Visible := FALSE;
                fSigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited );
                CellRowBeingEdited := -1;
                CellColBeingEdited := -1;
              end;
              DrawString( Canvas, Rect, iValue );
            end;
          end;
        end;
        esImageList,
        esDropDownImageList:
        begin
          if assigned( fImages ) then
          begin
            if assigned( OnGetImageIndex) then
            begin
              iImageIndex := OnGetImageIndex( fSigGrid, ACol, ARow, State, iValue );
            end
            else if iValue = '' then
            begin
              iImageIndex := 0;
            end
            else
            begin
              iImageIndex := StrToIntDef( iValue, -1 );
            end;
            if (iImageIndex >= 0) and (iImageIndex < fImages.Count ) then
            begin
              fImages.Draw( Canvas, Rect.Left, Rect.Top, iImageIndex );
              if AutoSizeCol then
              begin
                fSigGrid.ColWidths[ ACol ] := fImages.Width;
              end;
            end
            else
            begin
              DrawString( Canvas, Rect, iValue );
            end;
          end
          else
          begin
            DrawString( Canvas, Rect, iValue );
          end;
        end;
      end;
    finally
      fEditorEntered := FALSE;
    end;
  end;

end;

procedure tSigGridEditor.DrawString(Canvas: TCanvas; Rect: TRect;
  Value: string);
begin
  // for now we use standard method
  Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, Value );
end;

procedure tSigGridEditor.EditorExit(Sender: tObject);
begin
  fEditor.Hide;
  SigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited);
  CellRowBeingEdited := -1;
  CellColBeingEdited := -1;
end;

function tSigGridEditor.GetButton: tBitBtn;
begin
  Result := nil;
  if assigned( fEditor ) then
  begin
    if fEditor is tBitBtn then
    begin
      Result := fEditor as tBitBtn;
    end;
  end;
end;

procedure tSigGridEditor.GetButtonEditValue(const Value: string);
begin
  Button.Caption := Value;
end;

function tSigGridEditor.GetCellColBeingEdited: integer;
begin
  Result := SigGrid.ColBeingEdited;
end;

function tSigGridEditor.GetCellRowBeingEdited: integer;
begin
  Result := SigGrid.RowBeingEdited;
end;

function tSigGridEditor.GetComboBox: tComboBox;
begin
  Result := nil;
  if assigned( fEditor ) then
  begin
    if fEditor is tComboBox then
    begin
      Result := fEditor as tComboBox;
    end;
  end;
end;

procedure tSigGridEditor.GetDropDownEditValue(const Value: string);
begin
  if ComboBox.Text <> Value then
  begin
    ComboBox.Text := Value;
  end;
end;

procedure tSigGridEditor.GetDropDownImageListEditValue(const Value: string);
var
  i: Integer;
begin
  ComboBox.ItemIndex := -1;
  for i := 0 to ComboBox.Items.Count - 1 do
  begin
    if SameText( Value, ComboBox.Items[ i ] ) then
    begin
      ComboBox.ItemIndex := i;
      break;
    end;
  end;
end;

procedure tSigGridEditor.GetDropDownListEditValue(const Value: string);
var
  i: Integer;
begin
  ComboBox.ItemIndex := -1;
  for i := 0 to ComboBox.Items.Count - 1 do
  begin
    if SameText( Value, ComboBox.Items[ i ] ) then
    begin
      ComboBox.ItemIndex := i;
      break;
    end;
  end;
end;

function tSigGridEditor.GetMaskEdit: tMaskEdit;
begin
  Result := nil;
  if assigned( fEditor ) then
  begin
    if fEditor is tMaskEdit then
    begin
      Result := fEditor as tMaskEdit;
    end;
  end;
end;

procedure tSigGridEditor.GetMaskEditValue(const Value: string);
begin
  MaskEdit.Text := Value;
end;

function tSigGridEditor.GetSpinEdit: tSigSpinEdit;
begin
  if fEditor is tSigSpinEdit then
  begin
    Result := fEditor as tSigSpinEdit;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure tSigGridEditor.GetSpinEditValue(const Value: string);
begin
  SpinEdit.Value := StrToIntDef( Value, 0 );
end;

function tSigGridEditor.GetStrings: tStrings;
begin
  case fStyle of
    esNone: Result := nil;
    esSpinEdit,
    esButton,
    esMaskEdit: Result := nil;
    esDropDown: Result := ComboBox.Items;
    esDropDownList: Result := ComboBox.Items;
    esImageList: Result := fItemsList;
    esDropDownImageList: Result := fItemsList;
    else Result := nil;
  end;
end;

{
procedure tSigGridEditor.HandleVisualChange;
var
  iRect : tRect;
begin
  if assigned( fSigGrid ) then
  begin
    if csDesigning in ComponentState then
    begin
      if (fColumn >= 0) and (fColumn < fSigGrid.ColCount) and (fSigGrid.FixedRows < fSigGrid.RowCount) then
      begin
        iRect := fSigGrid.CellRect( fColumn, fSigGrid.FixedRows);
        inc( iRect.Top, fSigGrid.Top + 2);
        inc( iRect.Bottom, fSigGrid.Top + 2);
        inc( iRect.Left, fSigGrid.Left  + 2);
        inc( iRect.Right, fSigGrid.Left + 2);
        ShowEditor( TRUE, iRect );
      end;
    end
    else
    begin
      ShowEditor( FALSE, iRect );
    end;
  end;
end;
}

procedure tSigGridEditor.OnButtonClick(Sender: tObject);
begin
  if assigned( fOnClick ) then
  begin
    fOnClick( self );
    // caption may have changed
    Button.Caption := fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ];
  end;
end;

procedure tSigGridEditor.OnDropDownImageListChange(Sender: tObject);
begin
  if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> ComboBox.Text then
  begin
    fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := ComboBox.Text;
    if assigned( fSigGrid.OnCellEditChange ) then
    begin
      fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, ComboBox.Text );
    end;
  end;
end;

procedure tSigGridEditor.OnDropDownListChange(Sender: tObject);
begin
  if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> ComboBox.Text then
  begin
    fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := ComboBox.Text;
    if assigned( fSigGrid.OnCellEditChange ) then
    begin
      fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, ComboBox.Text );
    end;
    CheckColWidth( CellColBeingEdited, ComboBox.Text );
  end;
end;

procedure tSigGridEditor.OnMaskEditChange(Sender: tObject);
begin
  if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> MaskEdit.Text then
  begin
    fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := MaskEdit.Text;
    if assigned( fSigGrid.OnCellEditChange ) then
    begin
      fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, MaskEdit.Text );
    end;
    CheckColWidth( CellColBeingEdited, MaskEdit.Text );
  end;
end;

procedure tSigGridEditor.OnSpinEditChange(Sender: tObject);
begin
  if SpinEdit.IsValid then
  begin
    if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> SpinEdit.Text then
    begin
      fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := SpinEdit.Text;
      if assigned( fSigGrid.OnCellEditChange ) then
      begin
        fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, SpinEdit.Text );
      end;
      CheckColWidth( CellColBeingEdited, SpinEdit.Text );
    end;
  end;
end;

procedure tSigGridEditor.PrintCell(Canvas: TCanvas; ACol, ARow: Integer;
  Rect: TRect; Value: string);
var
  iImageIndex : integer;
  iValue : string;
  iTempBMP : tBitmap;
begin
  iValue := Value;
  if (Value = '') and (ARow < Titles.Count ) then
  begin
    iValue := Titles[ ARow ];
  end;
  case fStyle of
    esNone:
    begin
      DrawString( Canvas, Rect, iValue );
    end;
    esSpinEdit,
    esButton,
    esMaskEdit,
    esDropDown,
    esDropDownList:
    begin
      DrawString( Canvas, Rect, iValue );
    end;
    esImageList,
    esDropDownImageList:
    begin
      if assigned( fImages ) then
      begin
        if assigned( OnGetImageIndex) then
        begin
          iImageIndex := OnGetImageIndex( fSigGrid, ACol, ARow, [], iValue );
        end
        else if iValue = '' then
        begin
          iImageIndex := 0;
        end
        else
        begin
          iImageIndex := StrToIntDef( iValue, -1 );
        end;
        if (iImageIndex >= 0) and (iImageIndex < fImages.Count ) then
        begin
          iTempBMP := tBitMap.Create;
          try
            SetStretchBltMode( Canvas.Handle, HalfTone );
            fImages.GetBitmap( iImageIndex, iTempBMP );
            StretchBlt( Canvas.Handle, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
                        Rect.Bottom - Rect.Top, iTempBMP.Canvas.Handle, 0, 0, iTempBMP.Width,
                        iTempBMP.Height, SRCCOPY );
          finally
            iTempBMP.Free;
          end;
        end
        else
        begin
          DrawString( Canvas, Rect, iValue );
        end;
      end
      else
      begin
        DrawString( Canvas, Rect, iValue );
      end;
    end;
  end;
end;

procedure tSigGridEditor.ResetText( const pCol, pRow : integer; const pNewVal: string);
begin
  if (pRow = CellRowBeingEdited) and (pCol = CellColBeingEdited ) then
  begin
    if assigned( fEditor ) then
    begin
      if fEditor.Visible then
      begin
        case fStyle of
          esNone: ;
          esSpinEdit:
          begin
            try
              SpinEdit.Value := StrToInt( pNewVal );
            except
            end;
          end;
          esButton:
          begin
            Button.Caption := pNewVal;
          end;
          esMaskEdit:
          begin
            MaskEdit.Text := pNewVal;
          end;
          esDropDown, esDropDownList:
          begin
            ComboBox.Text := pNewVal;
          end;
        end;
      end;
    end;
  end;
end;

class function tSigGridEditor.ScrollBarWidth: integer;
begin
  Result := GetSystemMetrics( SM_CXVSCROLL );
end;

procedure tSigGridEditor.SetAllowUseToRight(const Value: boolean);
//var
//  i : integer;
begin
  fAllowUseToRight := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
  {
  if Value then
  begin
    SetColWidth( fColWidth );
  end
  else
  begin
    for i := Column + 1 to SigGrid.ColCount - 1 do
    begin
      SigGrid.ColWidths[ Column ] := fSigGrid.DefaultColWidth;
      SigGrid.InvalidateCol( i );
    end;
  end;
  }
end;

procedure tSigGridEditor.SetAutoSizeColumn(const Value: boolean);
begin
  if fAutosizeColumn <> Value then
  begin
    fAutoSizeColumn := Value;
    fParentAutoSizeColumn := FALSE;
    fParentColWidth := FALSE;
    if assigned( fSigGrid ) then
    begin
      fSigGrid.InvalidateGrid;
    end;
  end;
end;

procedure tSigGridEditor.SetCellColBeingEdited(const Value: integer);
begin
  SigGrid.ColBeingEdited := Value;
end;

procedure tSigGridEditor.SetCellRowBeingEdited(const Value: integer);
begin
  SigGrid.RowBeingEdited := Value;
end;

procedure tSigGridEditor.SetColumn(const Value: integer);
begin
  fColumn := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
  //HandleVisualChange;
end;

procedure tSigGridEditor.SetColWidth(const Value: integer);
//var
//  i: Integer;
begin
  fColWidth := Value;
  if assigned( SigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
  end;
  {
  if assigned( SigGrid ) and not fParentColWidth then
  begin
    SigGrid.ColWidths[ Column ] := Value;
    if AllowUseToRight then
    begin
      for i := Column + 1 to SigGrid.ColCount - 1 do
      begin
        SigGrid.ColWidths[ Column ] := Value;
      end;
    end;
  end;
  }
end;

procedure tSigGridEditor.SetImages(const Value: tImageList);
begin
  fImages := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
end;

procedure tSigGridEditor.SetItemsList(const Value: tStringList);
begin
  fItemsList := Value;
  if fItemsList.Count > 0 then
  begin
    if assigned( ComboBox ) then
    begin
      ComboBox.Items.Assign( fItemsList );
    end;
  end;
end;

procedure tSigGridEditor.SetMaxLen(const Value: integer);
begin
  fMaxLen := Value;
  case fStyle of
    esNone: ;
    esMaskEdit:
    begin
      MaskEdit.MaxLength := Value;
    end;
    esDropDown:
    begin
      ComboBox.MaxLength := Value;
    end;
    esDropDownList:
    begin
      ComboBox.MaxLength := Value;
    end;
    esImageList: ;
    esSpinEdit:
    begin
      SpinEdit.MaxLength := Value;
    end;
    esDropDownImageList: ;
    esButton: ;
  end;
end;

procedure tSigGridEditor.SetMaxVal(const Value: integer);
begin
  fMaxVal := Value;
  case fStyle of
    esNone: ;
    esMaskEdit: ;
    esDropDown: ;
    esDropDownList: ;
    esImageList: ;
    esSpinEdit:
    begin
      SpinEdit.MaxValue := Value;
    end;
    esDropDownImageList: ;
    esButton: ;
  end;
end;

procedure tSigGridEditor.SetMinVal(const Value: integer);
begin
  fMinVal := Value;
  case fStyle of
    esNone: ;
    esMaskEdit: ;
    esDropDown: ;
    esDropDownList: ;
    esImageList: ;
    esSpinEdit:
    begin
      SpinEdit.MinValue := Value;
    end;
    esDropDownImageList: ;
    esButton: ;
  end;
end;

procedure tSigGridEditor.SetOnClick(const Value: tNotifyEvent);
begin
  fOnClick := Value;
{
  case fStyle of
    esNone: ;
    esMaskEdit: ;
    esDropDown: ;
    esDropDownList: ;
    esImageList: ;
    esSpinEdit: ;
    esDropDownImageList: ;
    esButton: Button.OnClick := fOnClick;
  end;
}
end;

procedure tSigGridEditor.SetOnKeyPress(const Value: tKeyPressEvent);
begin
  fOnKeyPress := Value;
  case fStyle of
    esNone: ;
    esMaskEdit:
    begin
      MaskEdit.OnKeyPress := fOnKeyPress;
    end;
    esDropDown:
    begin
      ComboBox.OnKeyPress := fOnKeyPress;
    end;
    esDropDownList:
    begin
      ComboBox.OnKeyPress := fOnKeyPress;
    end;
    esImageList: ;
    esSpinEdit:
    begin
      SpinEdit.OnKeyPress := fOnKeyPress;
    end;
    esDropDownImageList: ;
    esButton:
    begin
      Button.OnKeyPress := fOnKeyPress;
    end;
  end;
end;

procedure tSigGridEditor.SetParentAutoSizeColumn(const Value: boolean);
begin
  if fParentAutosizeColumn <> Value then
  begin
    fParentAutoSizeColumn := Value;
    if assigned( fSigGrid ) then
    begin
      fSigGrid.InvalidateGrid;
    end;
  end;
end;

procedure tSigGridEditor.SetParentColWidth(const Value: boolean);
begin
  fParentColWidth := Value;
  if Value then
  begin
    fAutosizeColumn := FALSE;
    if assigned( fSigGrid ) then
    begin
      fSigGrid.InvalidateGrid;
    end;
  end
  else
  begin
    if assigned( fSigGrid ) then
    begin
      fSigGrid.ColWidths[ Column ] := ColWidth;
    end;
  end;
end;

procedure tSigGridEditor.SetSigGrid(const Value: TSigGeneralGrid);
var
  iRect : tRect;
begin
  if assigned( fSigGrid ) then
  begin
    fSigGrid.UnregisterEditor( self );
    fSigGrid.InvalidateGrid;
  end;
  fSigGrid := Value;
  iRect.Left := 0;
  iRect.Right := 0;
  iRect.Top := 0;
  iRect.Bottom := 0;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RegisterEditor( self );
    if assigned( fEditor ) then
    begin
      fEditor.Parent := fSigGrid.Parent;
    end;
    //HandleVisualChange;
    fSigGrid.InvalidateGrid;
  end;
end;

procedure tSigGridEditor.SetStringList(const Value: tStringList);
begin
  fStringList.Assign( Value );
  if assigned( fSigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
  end;
end;

procedure tSigGridEditor.SetStyle(const Value: tSigEditorStyle);
begin
  fStyle := Value;
  if assigned( fEditor ) then
  begin
    fEditor.Free;
  end;
  fStyle := Value;
  case Value of
    esNone:
    begin
      fEditor := nil;
    end;
    esButton:
    begin
      fEditor := tBitBtn.Create( self );
      Button.OnKeyPress := fOnKeyPress;
      Button.OnClick := OnButtonClick;
      Button.OnExit := EditorExit;
      fGetEditValue := GetButtonEditValue;
    end;
    esSpinEdit:
    begin
      fEditor := tSigSpinEdit.Create( self );
      SpinEdit.OnChange := OnSpinEditChange;
      fGetEditValue := GetSpinEditValue;
      SpinEdit.OnExit := EditorExit;
      SpinEdit.MaxLength := MaxLength;
      SpinEdit.MinValue := MinVal;
      SpinEdit.MaxValue := MaxVal;
    end;
    esMaskEdit:
    begin
      fEditor := tMaskEdit.Create( self );
      fGetEditValue := GetMaskEditValue;
      MaskEdit.OnChange := OnMaskEditChange;
      MaskEdit.OnExit := EditorExit;
      MaskEdit.OnKeyPress := fOnKeyPress;
      MaskEdit.MaxLength := fMaxLen;
    end;
    esDropDown:
    begin
      fEditor := tComboBox.Create( self );
      ComboBox.Style := csDropDown;
      fGetEditValue := GetDropDownEditValue;
      ComboBox.OnChange := OnDropDownListChange;
      if assigned( fItemsList ) then
      begin
        if fItemsList.Count > 0 then
        begin
          ComboBox.Items.Assign( fItemsList );
        end;
      end;
      ComboBox.OnExit := EditorExit;
      ComboBox.MaxLength := fMaxLen;
    end;
    esDropDownList:
    begin
      fEditor := tComboBox.Create( self );
      ComboBox.Style := csDropDownList;
      fGetEditValue := GetDropDownListEditValue;
      ComboBox.OnChange := OnDropDownListChange;
      if assigned( fItemsList ) then
      begin
        if fItemsList.Count > 0 then
        begin
          ComboBox.Items.Assign( fItemsList );
        end;
      end;
      ComboBox.OnExit := EditorExit;
      ComboBox.MaxLength := fMaxLen;
    end;
    esImageList:
    begin
      fEditor := nil;
      if assigned( Images ) then
      begin
        SigGrid.ColWidths[ Column ] := Images.Width;
      end;
      fGetEditValue := nil;
    end;
    esDropDownImageList:
    begin
      fEditor := tComboBox.Create( self );
      ComboBox.Style := csOwnerDrawFixed;
      fGetEditValue := GetDropDownImageListEditValue;
      ComboBox.OnChange := OnDropDownImageListChange;
      ComboBox.OnDrawItem := OnDropDownImageListDrawItem;
      if assigned( fItemsList ) then
      begin
        if fItemsList.Count > 0 then
        begin
          ComboBox.Items.Assign( fItemsList );
        end;
      end;
      if assigned( Images ) then
      begin
        SigGrid.ColWidths[ Column ] := Images.Width;
      end;
      ComboBox.OnExit := EditorExit;
    end
    else
    begin
      fEditor := nil;
    end;
  end;
  if assigned( fEditor ) and assigned( SigGrid ) then
  begin
    fEditor.Parent := SigGrid.Parent;
    fSigGrid.RecalculateRowHeights;
    fEditor.Visible := FALSE;
  end;
  if assigned( SigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
    //fEditor.Visible := FALSE;
    //HandleVisualChange;
  end;
end;

procedure tSigGridEditor.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  if assigned( fEditor ) then
  begin
    if not( Value ) then
    begin
      fEditor.Visible := Value;
    end;
  end;
end;

procedure tSigGridEditor.OnDropDownImageListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  iBmp : tBitmap;
begin
  iBmp := tBitmap.Create;
  if (Index >= 0) and (Index < fItemsList.Count ) then
  begin
    if assigned( Images ) then
    begin
      Images.GetBitmap( Index, iBmp );
      with Control as TComboBox do
      begin
        Canvas.FillRect( Rect );
        Canvas.Draw( Rect.Left, Rect.Top, iBmp);
      end;
    end;
  end;
  iBmp.Free;
end;


procedure tSigGridEditor.ShowEditor(const pVisible: boolean; const pRect : tRect);
begin
  // to do
  if assigned( fEditor ) then
  begin
    if pVisible then
    begin
      fEditor.Height := pRect.Bottom - pRect.Top;
      if fStyle = esDropDownImageList then
      begin
        fEditor.Width := pRect.Right - pRect.Left + ScrollBarWidth;  // editor overlaps next column
      end
      else
      begin
        fEditor.Width := pRect.Right - pRect.Left;
      end;
      fEditor.Left := pRect.Left;
      fEditor.Top  := pRect.Top;
    end;
    fEditor.Visible := pVisible;
  end;
end;


end.
