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
  v5.0   Various bug fixes
  v6.0   Enable for live bindings and add a properties ActiveRowCount and
         ActiveColCount which are the non-fixed equivalent to FixedRows and FixedCols
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
  Buttons,
  VCL.ExtCtrls,
  VCL.ComCtrls,
  PendingActions,
  Data.bind.components;

type
  TSigEditorStyle = ( esNone, esMaskEdit, esDropDown, esDropDownList,
                      esImageList, esSpinEdit, esDropDownImageList,
                      esButton, esDatePicker, esTimePicker );

  TSigGetImageIndex = function( const Sender : TObject; const Col, Row : integer; const State: TGridDrawState; const Value : string ) : integer of object;

  TSetupEditor = procedure( const Value : string ) of object;

  TOnCellChange = procedure( const Sender : TObject; const Col, Row : integer; const Value : string ) of object;
  TOnEditorSelectionChange = procedure( const Sender : TObject; const pParm : integer ) of object;

type
  TSigGeneralGrid = class;
  TSigGeneralGridCell = class;

  TSigGridEditor = class( TComponent )    // this component is added on the pallet
  private
    fEditor: TWinControl;
    fSigGrid: TSigGeneralGrid;
    fStyle: TSigEditorStyle;
    fGetEditValue : TSetupEditor;
    fColumn: integer;
    fParentAutoSizeColumn: boolean;
    fAutoSizeColumn: boolean;
    fImages: TImageList;
    fOnGetImageIndex: TSigGetImageIndex;
    fStringList: TStringList;
    fParentColWidth: boolean;
    fColWidth: integer;
    fEditorEntered : boolean;
    fAllowUseToRight: boolean;
    fItemsList: TStringList;
    fVisible: boolean;
    fOnKeyPress: TKeyPressEvent;
    fMaxLen: integer;
    fMaxVal: integer;
    fMinVal: integer;
    fOnClick: TNotifyEvent;
    fInstantAction: boolean;
    procedure OnButtonClick( Sender : TObject );
    procedure SetSigGrid(const Value: TSigGeneralGrid);
    procedure SetStyle(const Value: TSigEditorStyle);
    procedure GetSpinEditValue( const Value : string );
    procedure GetDatePickerValue( const Value : string );
    function GetSpinEdit: TSigSpinEdit;
    procedure EditorExit( Sender : TObject );
    procedure OnSpinEditChange( Sender : TObject );
    procedure OnDatePickerChange( Sender : TObject );
    function GetComboBox: TComboBox;
    procedure SetAutoSizeColumn(const Value: boolean);
    procedure GetDropDownListEditValue( const Value : string );
    procedure GetDropDownImageListEditValue( const Value : string );
    procedure GetDropDownEditValue( const Value : string );
    procedure GetMaskEditValue( const Value : string );
    procedure GetButtonEditValue( const Value : string );
    procedure OnDropDownListChange( Sender : TObject );
    procedure OnDropDownImageListChange( Sender : TObject );
    procedure OnMaskEditChange( Sender : TObject );
    function GetStrings: TStrings;
    function GetMaskEdit: TMaskEdit;
    procedure SetStringList(const Value: TStringList);
    procedure SetColumn(const Value: integer);
    procedure SetParentColWidth(const Value: boolean);
    procedure SetColWidth(const Value: integer);
    procedure SetImages(const Value: TImageList);
    procedure SetAllowUseToRight(const Value: boolean);
    procedure SetParentAutoSizeColumn(const Value: boolean);
    procedure SetItemsList(const Value: TStringList);
    procedure OnDropDownImageListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SetVisible(const Value: boolean);
    procedure SetOnKeyPress(const Value: TKeyPressEvent);
    procedure SetMaxLen(const Value: integer);
    procedure SetMaxVal(const Value: integer);
    procedure SetMinVal(const Value: integer);
    function GetButton: TBitBtn;
    procedure SetOnClick(const Value: TNotifyEvent);
    function GetCellRowBeingEdited: integer;
    procedure SetCellRowBeingEdited(const Value: integer);
    function GetCellColBeingEdited: integer;
    procedure SetCellColBeingEdited(const Value: integer);
    function GetObjects(const pVal: string): tObject;
    procedure SetObjects(const pVal: string; const Value: tObject);
    function GetDatePicker: tDateTimePicker;
    //procedure OnItemListChange( Sender : TObject );
  protected
    //procedure HandleVisualChange;
    procedure DelayedImmediateAction( const pObject : TObject; var pNewDelay : integer );

    procedure ShowEditor( const pVisible : boolean; const pRect : TRect );
    property SpinEdit : TSigSpinEdit
             read GetSpinEdit;
    property ComboBox : TComboBox
             read GetComboBox;
    property MaskEdit : TMaskEdit
             read GetMaskEdit;
    property Button : TBitBtn
             read GetButton;
    property DatePicker : TDateTimePicker
             read GetDatePicker;
    procedure CheckColWidth( const pCol : integer; const Value : string );
  public
    constructor Create(AOwner: TComponent); override;
    procedure AfterConstruction; override;
    destructor Destroy; override;

    property Editor : TWinControl
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
    property Items : TStrings
             read GetStrings;
    property Visible : boolean
             read fVisible
             write SetVisible;
    property Objects[ const pVal : string ] : tObject
             read GetObjects
             write SetObjects;

    procedure DrawCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect;
              const State: TGridDrawState; const pCell : TSigGeneralGridCell;
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
    property Style : TSigEditorStyle
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
    property Images : TImageList
             read fImages
             write SetImages;
    property OnGetImageIndex : TSigGetImageIndex
             read fOnGetImageIndex
             write fOnGetImageIndex;
    property Titles : TStringList
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
    property ItemsList : TStringList
             read fItemsList
             write SetItemsList;
    property OnKeyPress : TKeyPressEvent
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
    property OnClick : TNotifyEvent
             read fOnClick
             write SetOnClick;
    property InstantAction : boolean
             read fInstantAction
             write fInstantAction
             default TRUE;

    procedure ResetText( const pCol, pRow : integer; const pNewVal : string );
    procedure HideEditor;


  end;

  TSigEditorList = class( TObjectList )
  private
    fParent: TSigGeneralGrid;
    fVisible: boolean;
    fOnKeyPress: TKeyPressEvent;
    function GetEditor(const pColumn : integer): TSigGridEditor;
    function GetEditorType(const pColumn: integer): TSigEditorStyle;
    function GetChoiceStrings(const pCol: integer): TStrings;
    procedure SetVisible(const Value: boolean);
    procedure SetOnKeyPress(const Value: TKeyPressEvent);
  public
    constructor Create( const pParent : TSigGeneralGrid ); reintroduce;
    destructor Destroy; override;

    property ParentAsGrid : TSigGeneralGrid
             read fParent;
    property Editor[ const pColumn : integer ] : TSigGridEditor
             read GetEditor;
    property EditorType[ const pColumn : integer ] : TSigEditorStyle
             read GetEditorType;
    property ChoiceStrings[ const pCol : integer ] : TStrings
             read GetChoiceStrings;
    property Visible : boolean
             read fVisible
             write SetVisible;

    property OnKeyPress : TKeyPressEvent
             read fOnKeyPress
             write SetOnKeyPress;

    procedure DrawCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; const State: TGridDrawState;
              const pCell : TSigGeneralGridCell; const OwnerEnabled : boolean; const OwnerFocused : boolean;
              const CellEnabled : boolean; const ErrorText : string );

    procedure PrintCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; Value : string );

    procedure RegisterEditor( NewVal : TSigGridEditor );
    procedure UnregisterEditor( OldVal : TSigGridEditor );

  end;

  TSigGeneralGridCellList = class;

  TSigGeneralGridCell = class
  private
    fRow: integer;
    fCol: integer;
    fText: string;
    fError: boolean;
    fOwner: TSigGeneralGridCellList;
    fEnabled: boolean;
    fErrorText: string;
    fCellObject: TObject;
    fTag: integer;
    procedure SetText(const Value: string);
    procedure SetErrorText(const Value: string);
  public
    constructor Create( const pCol, pRow : integer; const pOwner : TSigGeneralGridCellList );
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
    property Owner : TSigGeneralGridCellList
             read fOwner;
    property Enabled : boolean
             read fEnabled
             write fEnabled;
    property CellObject : TObject
             read fCellObject
             write fCellObject;
    property Tag : integer
             read fTag
             write fTag;
  end;

  TSigGeneralGridCellList = class( TObjectList )
  private
    fOwner: TSigGeneralGrid;
    function GetSigGeneralGridCell(const Col, Row : integer; ForceCreate : boolean = FALSE ): TSigGeneralGridCell;
    function GetCell(const Col, Row: integer): string;
    procedure SetCell(const Col, Row: integer; const Value: string);
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
    function GetEnabled(const Col, Row: integer): boolean;
    procedure SetEnabled(const Col, Row: integer; const Value: boolean);
    function GetErrorText(const Col, Row: integer): string;
    procedure SetErrorText(const Col, Row: integer; const Value: string);
    function GetCellObject(const Col, Row: integer): TObject;
    procedure SetCellObject(const Col, Row: integer; const Value: TObject);
    function GetCellTag(const Col, Row: integer): integer;
    procedure SetCellTag(const Col, Row, Value: integer);
{
    property SigGeneralGridCell[ const Col, Row : integer ] : TSigGeneralGridCell
             read GetSigGeneralGridCell;
}
  public
    constructor Create( pOwner : TSigGeneralGrid ); reintroduce;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property CellObject[ const Col, Row : integer ] : TObject
             read GetCellObject
             write SetCellObject;
    property CellTag[ const Col,Row : integer ] : integer
             read GetCellTag
             write SetCellTag;
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

  TOnPrint = procedure( const pCanvas : TCanvas; const pRect : TRect; var pTop, pBottom : integer;
                        const pPage, pOfPages : integer; pCalculatingPages : boolean ) of object;

  [ObservableMember('ActiveColCount')]
  [ObservableMember('ActiveRowCount')]
  TSigGeneralGrid = class(TDrawGrid)
  private
    { Private declarations }
    fEditorList : TSigEditorList;
    fSigCells : TSigGeneralGridCellList;
    fTextHMargin: integer;
    fAutosizeRows: boolean;
    fTextVMargin100: integer;
    fMinRowHeight: integer;
    fAutoSizeCols: boolean;
    fNormalFont: TFont;
    fErrorFont: TFont;
    fOnCellChange: TOnCellChange;
    fOnCellEditChange: TOnCellChange;
    fFocused : boolean;
    fOnPrintHeader: TOnPrint;
    fOnPrintFooter: TOnPrint;
    fRowBeingEdited: integer;
    fOnRowSelectionChange: TOnEditorSelectionChange;
    fColBeingEdited: integer;
    fOnColSelectionChange: TOnEditorSelectionChange;
    fTimer: TTimer;
    fSigGeneralGridPendingActionList: TSigPendingActionList;
    fJustClicked: boolean;
    fRowCount: integer;
    fColCount: integer;
    function GetCell(const Col, Row : integer): string;
    procedure SetCell(const Col, Row : integer; const Value: string);
    procedure SetTextHMargin(const Value: integer);
    procedure SetAutosizeRows(const Value: boolean);
    function GetColumnEditStyle(const pCol: integer): TSigEditorStyle;
    procedure SetTextVMargin100(const Value: integer);
    procedure SetMinRowHeight(const Value: integer);
    function GetImageList(const pCol: integer): TImageList;
    function GetChoiceStrings(const pCol: integer): TStrings;
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
    procedure SetErrorFont(const Value: TFont);
    procedure SetNormalFont(const Value: TFont);
    function GetEditor(const pCol: integer): TSigGridEditor;
    procedure SetAutoSizeCols(const Value: boolean);
    procedure SetVisible(const Value: boolean);
    function GetVisible: boolean;
    function GetCellEnabled(const Col, Row: integer): boolean;
    procedure SetCellEnabled(const Col, Row: integer; const Value: boolean);
    function GetErrorText(const Col, Row: integer): string;
    procedure SetErrorText(const Col, Row: integer; const Value: string);
    function GetCellObject(const Col, Row: integer): TObject;
    procedure SetCellObject(const Col, Row: integer; const Value: TObject);
    procedure SetOnKeyPress(const Value: TKeyPressEvent);
    procedure SetRowBeingEdited(const Value: integer);
    procedure SetColBeingEdited(const Value: integer);
    function GetCellTag(const Col, Row: integer): integer;
    procedure SetCellTag(const Col, Row, Value: integer);
    procedure SetJustClicked(const Value: boolean);
    function GetRowVisible(const pRow: integer): boolean;
    procedure SetRowVisible(const pRow: integer; const Value: boolean);
    function GetActiveColCount: integer;
    function GetActiveRowCount: integer;
    procedure SetActiveColCount(const Value: integer);
    procedure SetActiveRowCount(const Value: integer);
    procedure SetColCount(const Value: integer);
    procedure SetRowCount(const Value: integer);
  protected
    { Protected declarations }
    function CanObserve( const ID : integer ): boolean; override;
    procedure ObserverAdded(  const ID : integer; const Observer: IObserver); override;
    procedure fOnTimer( Sender : TObject );
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure RecalculateRowHeights;
    procedure Click; override;

    procedure RegisterEditor( NewVal : TSigGridEditor );
    procedure UnregisterEditor( OldVal : TSigGridEditor );

    procedure DoEnter; override;
    procedure DoExit; override;

    procedure InvalidateEditor( const ACol, ARow : integer; const pNewVal : string );

    property Timer : TTimer
             read fTimer
             stored FALSE;

    property SigGeneralGridPendingActionList : TSigPendingActionList
             read fSigGeneralGridPendingActionList;
  public
    { Public declarations }

    property JustClicked : boolean
             read fJustClicked
             write SetJustClicked;
    procedure AddDelayedAction( const pPendingActionEvent : TSigPendingActionEvent; const pObject : TObject = nil;
                  const pDelay : integer = 0 );
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property ColumnEditStyle[ const pCol : integer ] : TSigEditorStyle
             read GetColumnEditStyle;
    property ImageList[ const pCol : integer ] : TImageList
             read GetImageList;
    property ChoiceStrings[ const pCol : integer ] : TStrings
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
    property CellObject[ const Col, Row : integer ] : TObject
             read GetCellObject
             write SetCellObject;
    property CellTag[ const Col, Row : integer ] : integer
             read GetCellTag
             write SetCellTag;
    property Editor[ const pCol : integer ] : TSigGridEditor
             read GetEditor;
    property RowVisible[const pRow : integer ] : boolean
             read GetRowVisible
             write SetRowVisible;

    function MaxTextWidth( const Col : integer ) : integer;

    procedure ClearCells;

    function ExportCSV( const pFileName : string ) : boolean;

    procedure Print( const pStartPage : integer; var pPageCount : integer;
              const pCanvas : TCanvas; const pRect : TRect; const pCalculatingPages : boolean );

    procedure PrintCell( const pCol, pLine : integer; const pCanvas : TCanvas;
                         const pLeft : integer; const pCurrentTop, pLineHeight,
                         pCellWidth, pScaleFactor : integer );

    procedure PrintLine( const pLine : integer; const pCanvas : TCanvas; const pRect : TRect;
                         var pCurrentPage, pPageCount, pCurrentTop, pCurrentBottom : integer;
                         const pLeftMargin, pScaleFactor : integer; const pCalculatingPages : boolean );
    function PrintLineHeight( const pLine : integer; const pCanvas : TCanvas; const pScaleFactor : integer ) : integer;
    function PrintColWidth( const pCol : integer; const pCanvas : TCanvas; const pScaleFactor : integer ) : integer;
    procedure GetPrintParms( const pCanvas : TCanvas; const pRect : TRect; var pScaleFactor : integer; var pLeft : integer );
    property RowBeingEdited : integer
             read fRowBeingEdited
             write SetRowBeingEdited;
    property ColBeingEdited : integer
             read fColBeingEdited
             write SetColBeingEdited;
    procedure HideEditor;
    property ColWidths stored FALSE;
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

    property ActiveRowCount : integer
             read GetActiveRowCount
             write SetActiveRowCount stored FALSE;
    property ActiveColCount : integer
             read GetActiveColCount
             write SetActiveColCount stored FALSE;

    property RowCount : integer
             read fRowCount
             write SetRowCount
             default 5;
    property ColCount : integer
             read fColCount
             write SetColCount
             default 5;

    property OnCellChange : TOnCellChange  // called whenever a Cell Changes
             read fOnCellChange
             write fOnCellChange;
    property OnCellEditChange : TOnCellChange   // only called when an editor changes a value
             read fOnCellEditChange
             write fOnCellEditChange;
    property OnRowSelectionChange : TOnEditorSelectionChange
             read fOnRowSelectionChange
             write fOnRowSelectionChange;
    property OnColSelectionChange : TOnEditorSelectionChange
             read fOnColSelectionChange
             write fOnColSelectionChange;

    property OnKeyPress
             write SetOnKeyPress;

    property OnPrintHeader : TOnPrint
             read fOnPrintHeader
             write fOnPrintHeader;
    property OnPrintFooter : TOnPrint
             read fOnPrintFooter
             write fOnPrintFooter;

  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [ TSigGeneralGrid ]);
  RegisterComponents('SigNET', [ TSigGridEditor ]);
end;
{$ENDIF}

{ TSigEditorList }

constructor TSigEditorList.Create( const pParent : TSigGeneralGrid );
begin
  inherited Create( FALSE );
  fParent := pParent;
  //Visible := fParent.Visible;  editor never visible by default
end;

destructor TSigEditorList.Destroy;
var
  i: Integer;
  iEditor : TSigGridEditor;
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

procedure TSigEditorList.DrawCell(Canvas: TCanvas; ACol, ARow: Integer;
  Rect: TRect; const State: TGridDrawState; const pCell : TSigGeneralGridCell;
  const OwnerEnabled : boolean; const OwnerFocused : boolean;
  const CellEnabled : boolean; const ErrorText : string );
var
  iEditor : TSigGridEditor;
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

function TSigEditorList.GetChoiceStrings(const pCol: integer): TStrings;
var
  iEditor : TSigGridEditor;
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

function TSigEditorList.GetEditor(const pColumn : integer): TSigGridEditor;
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
      Result := Items[ i ] as TSigGridEditor;
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
    Result := Items[ iBestSoFar ] as TSigGridEditor;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigEditorList.GetEditorType(const pColumn: integer): TSigEditorStyle;
var
  iEditor : TSigGridEditor;
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

procedure TSigEditorList.PrintCell(Canvas: TCanvas; ACol, ARow: Integer;
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

procedure TSigEditorList.RegisterEditor(NewVal: TSigGridEditor);
begin
  Add( NewVal );
  NewVal.Visible := fVisible;
  NewVal.OnKeyPress := self.OnKeyPress;
end;

procedure TSigEditorList.SetOnKeyPress(const Value: TKeyPressEvent);
var
  i: Integer;
begin
  fOnKeyPress := Value;
  for i := 0 to Count - 1 do
  begin
    (Items[ i ] as TSigGridEditor).OnKeyPress := self.OnKeyPress;
  end;
end;

procedure TSigEditorList.SetVisible(const Value: boolean);
var
  i: Integer;
begin
  fVisible := Value;
  for i := 0 to Count - 1 do
  begin
    Editor[ i ].Visible := Value;
  end;
end;

procedure TSigEditorList.UnregisterEditor(OldVal: TSigGridEditor);
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

procedure TSigGeneralGrid.AddDelayedAction(
  const pPendingActionEvent: TSigPendingActionEvent; const pObject: TObject;
  const pDelay: integer);
begin
  SigGeneralGridPendingActionList.Add( pPendingActionEvent, pObject, pDelay );
  if not fTimer.Enabled then
  begin
    fTimer.Enabled := TRUE;
  end;
end;

function TSigGeneralGrid.CanObserve(const ID: integer): boolean;
begin
  {
    Read-Only fields are not supported
  }
  case ID of
    TObserverMapping.EditLinkID,
    TObserverMapping.ControlValueID:
    begin
      Result := TRUE;
    end;
    else
    begin
      Result := FALSE;
    end;
  end;
end;

procedure TSigGeneralGrid.ClearCells;
begin
  fSigCells.Clear;
end;

procedure TSigGeneralGrid.Click;
begin
  if JustClicked then
  begin
    inherited;
  end
  else
  begin
    fJustClicked := TRUE;
    inherited;
    Invalidate;
  end;
end;

constructor TSigGeneralGrid.Create(AOwner: TComponent);
begin
  inherited;

  RowCount := 5;
  ColCount := 5;

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

  fTimer := TTimer.Create( self );
  fTimer.Interval := 10;
  fTimer.Enabled := FALSE;
  fTimer.OnTimer := fOnTimer;

  fSigGeneralGridPendingActionList := TSigPendingActionList.Create;

end;

destructor TSigGeneralGrid.Destroy;
begin
  FreeAndNil( fEditorList );
  FreeAndNil( fSigCells );

  FreeAndNil( fNormalFont );
  FreeAndNil ( fErrorFont );

  FreeAndNil( fSigGeneralGridPendingActionList );
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
  iStringList : TStringList;
  i, j: Integer;
  iValue : string;
  iLine : string;
  iEditor : TSigGridEditor;
begin

  //Result := FALSE;
  iStringList := TStringList.Create;
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

procedure TSigGeneralGrid.fOnTimer(Sender: tObject);
begin
  if fJustClicked then
  begin
    Timer.Enabled := fSigGeneralGridPendingActionList.ExecuteTick;
  end;
end;

function TSigGeneralGrid.GetActiveColCount: integer;
begin
  Result := ColCount - FixedCols;
end;

function TSigGeneralGrid.GetActiveRowCount: integer;
begin
  Result := RowCount - FixedRows;
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

function TSigGeneralGrid.GetCellObject(const Col, Row: integer): TObject;
begin
  Result := fSigCells.CellObject[ Col, Row ];
end;

function TSigGeneralGrid.GetCellTag(const Col, Row: integer): integer;
begin
  Result := fSigCells.CellTag[ Col, Row ];
end;

function TSigGeneralGrid.GetChoiceStrings(const pCol: integer): TStrings;
begin
  Result := fEditorList.ChoiceStrings[ pCol ];
end;

function TSigGeneralGrid.GetColumnEditStyle(
  const pCol: integer): TSigEditorStyle;
begin
  Result := fEditorList.EditorType[ pCol ];
end;

function TSigGeneralGrid.GetEditor(const pCol: integer): TSigGridEditor;
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

function TSigGeneralGrid.GetImageList(const pCol: integer): TImageList;
var
  iEditor : TSigGridEditor;
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

procedure TSigGeneralGrid.GetPrintParms(const pCanvas: TCanvas; const pRect : TRect;
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

function TSigGeneralGrid.GetRowVisible(const pRow: integer): boolean;
begin
  (*
  if not Visible then
  begin
    Result := FALSE;
  end
  else
  *)
  if pRow < TopRow then
  begin
    Result := FALSE;
  end
  else if pRow >= RowCount then
  begin
    Result := FALSE;
  end
  else if pRow >= (TopRow + VisibleRowCount) then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := TRUE;
  end;
end;

function TSigGeneralGrid.GetVisible: boolean;
begin
  Result := inherited Visible;
end;

procedure TSigGeneralGrid.HideEditor;
var
  i: Integer;
begin
  for i := 0 to fEditorList.Count - 1 do
  begin
    fEditorList.Editor[ i ].HideEditor;
  end;
end;

procedure TSigGeneralGrid.InvalidateEditor(const ACol, ARow : integer; const pNewVal : string );
var
  iEditor : TSigGridEditor;
begin
  iEditor := Editor[ ACol ];
  if assigned( iEditor ) then
  begin
    iEditor.ResetText( ACol, ARow, pNewVal );
  end;
end;

procedure TSigGeneralGrid.SetActiveColCount(const Value: integer);
begin
  if (Value <> ActiveColCount) then
  begin
    ColCount := Value + FixedCols;
    TLinkObservers.ControlChanged( self );
  end;
end;

procedure TSigGeneralGrid.SetActiveRowCount(const Value: integer);
begin
  if (Value <> ActiveRowCount) then
  begin
    {
    if Value <= 0 then
    begin
      Visible := FALSE;
    end
    else
    begin
      Visible := TRUE;
    }
      RowCount := Value + FixedRows;
    //end;
    TLinkObservers.ControlChanged( self );
  end;
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

procedure TSigGeneralGrid.SetCellTag(const Col, Row, Value: integer);
begin
  fSigCells.CellTag[ Col, Row ] := Value;
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

procedure TSigGeneralGrid.SetColCount(const Value: integer);
begin
  fColCount := Value;
  if Value <= FixedCols then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited ColCount := Value;
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

procedure TSigGeneralGrid.SetJustClicked(const Value: boolean);
begin
  fJustClicked := Value;
end;

procedure TSigGeneralGrid.SetMinRowHeight(const Value: integer);
begin
  fMinRowHeight := Value;
end;

procedure TSigGeneralGrid.SetNormalFont(const Value: TFont);
begin
  fNormalFont.Assign( Value );
end;

procedure TSigGeneralGrid.SetOnKeyPress(const Value: TKeyPressEvent);
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

procedure TSigGeneralGrid.SetRowCount(const Value: integer);
begin
  fRowCount := Value;
  if Value <= FixedRows then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    inherited RowCount := Value;
  end;
end;

procedure TSigGeneralGrid.SetRowVisible(const pRow: integer;
  const Value: boolean);
var
  iNewTopRow : integer;
begin
  if VisibleRowCount < 1 then
  begin
    // avoid infinite loop
    exit;
  end;
  if not RowVisible[ pRow ] then
  begin
    if (pRow >= FixedRows) and (pRow <= RowCount) then
    begin
      iNewTopRow := TopRow;
      if pRow < TopRow then
      begin
        while iNewTopRow > pRow do
        begin
          dec( iNewTopRow, VisibleRowCount );
        end;
        if iNewTopRow < FixedRows then
        begin
          iNewTopRow := FixedRows;
        end;
        TopRow := iNewTopRow;
      end
      else
      begin
        // need to move down at least one page
        while (iNewTopRow + VisibleRowCount) <= pRow do
        begin
          inc( iNewTopRow, VisibleRowCount );
        end;
        // should not be possible to get into an error condition
        TopRow := iNewTopRow;
      end;
    end
    else
    begin
      // not possible
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

procedure TSigGeneralGrid.UnregisterEditor(OldVal: TSigGridEditor);
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

procedure TSigGeneralGrid.ObserverAdded(const ID: integer;
  const Observer: IObserver);
begin
  inherited;

end;

procedure TSigGeneralGrid.Print(const pStartPage: integer;
  var pPageCount: integer; const pCanvas: TCanvas; const pRect: TRect;
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
  const pCanvas: TCanvas; const pLeft: integer; const pCurrentTop, pLineHeight,
  pCellWidth, pScaleFactor: integer);
var
  iRect : TRect;
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
  const pCanvas: TCanvas; const pRect: TRect; var pCurrentPage, pPageCount,
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
  const pCanvas: TCanvas; const pScaleFactor: integer): integer;
begin
  Result := (ColWidths[ pCol ] + 2 * GridLineWidth ) * pScaleFactor;
end;

function TSigGeneralGrid.PrintLineHeight(const pLine: integer;
  const pCanvas: TCanvas; const pScaleFactor: integer): integer;
begin
  Result := (RowHeights[ pLine ] + GridLineWidth) * pScaleFactor;
end;

procedure TSigGeneralGrid.RecalculateRowHeights;
var
  iNewRowValue, iNewRowValue2 : integer;
  iTextHeight : integer;
  i: Integer;
  iEditor : TSigGridEditor;
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

procedure TSigGeneralGrid.RegisterEditor(NewVal: TSigGridEditor);
begin
  fEditorList.RegisterEditor( NewVal );
  RecalculateRowHeights;
end;

{ TSigGeneralGridCell }

constructor TSigGeneralGridCell.Create(const pCol, pRow: integer; const pOwner : TSigGeneralGridCellList);
begin
  inherited Create;

  fRow := pRow;
  fCol := pCol;

  fOwner := pOwner;

  fText := '';

  fEnabled := TRUE;

end;

procedure TSigGeneralGridCell.SetErrorText(const Value: string);
begin
  if fErrorText <> Value then
  begin
    fErrorText := Value;
  end;
end;

procedure TSigGeneralGridCell.SetText(const Value: string);
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

{ TSigGeneralGridCellList }

constructor TSigGeneralGridCellList.Create( pOwner : TSigGeneralGrid );
begin
  inherited Create( TRUE );

  fOwner := pOwner;

end;

function TSigGeneralGridCellList.GetCell(const Col, Row: integer): string;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
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

function TSigGeneralGridCellList.GetCellObject(const Col,
  Row: integer): TObject;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
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

function TSigGeneralGridCellList.GetCellTag(const Col, Row: integer): integer;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, FALSE );
  if assigned( iSigGeneralGridCell ) then
  begin
    Result := iSigGeneralGridCell.Tag;
  end
  else
  begin
    Result := 0;
  end;
end;

function TSigGeneralGridCellList.GetEnabled(const Col, Row: integer): boolean;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
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

function TSigGeneralGridCellList.GetError(const Col, Row: integer): boolean;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
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

function TSigGeneralGridCellList.GetErrorText(const Col, Row: integer): string;
var
  iSigGeneralGridCell : TSigGeneralGridCell;
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

function TSigGeneralGridCellList.GetSigGeneralGridCell(const Col,
  Row : integer; ForceCreate : boolean): TSigGeneralGridCell;
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

procedure TSigGeneralGridCellList.SetCell(const Col, Row: integer;
  const Value: string);
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Text := Value;
end;

procedure TSigGeneralGridCellList.SetCellObject(const Col, Row: integer;
  const Value: tObject);
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.CellObject := Value;
end;

procedure TSigGeneralGridCellList.SetCellTag(const Col, Row, Value: integer);
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Tag := Value;
end;

procedure TSigGeneralGridCellList.SetEnabled(const Col, Row: integer;
  const Value: boolean);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Enabled := Value;
end;

procedure TSigGeneralGridCellList.SetError(const Col, Row: integer;
  const Value: boolean);
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Error := Value;
end;

procedure TSigGeneralGridCellList.SetErrorText(const Col, Row: integer;
  const Value: string);
var
  iSigGeneralGridCell : TSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.ErrorText := Value;
end;

{ TSigGridEditor }

procedure TSigGridEditor.AfterConstruction;
begin
  inherited;
  {
  case Style of
    esNone: ;
    esMaskEdit: ;
    esDropDown,
    esDropDownList:
    begin
      if assigned( fItemsList ) then
      begin
        if fItemsList.Count > 0 then
        begin
          ComboBox.Items.Assign( fItemsList );
        end;
      end;
    end;
    esImageList: ;
    esSpinEdit: ;
    esDropDownImageList: ;
    esButton: ;
  end;
  }
end;

function TSigGridEditor.AutoSizeCol: boolean;
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

procedure TSigGridEditor.CheckColWidth(const pCol : integer; const Value: string);
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
        esDatePicker,
        esTimePicker,
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
        if assigned( fEditor ) then
        begin
          fEditor.Width := iWidth;
        end;
      end;
    end;
  except;
  end;
end;

constructor TSigGridEditor.Create(AOwner: TComponent);
begin
  inherited;

  fStringList := tStringList.Create;
  fItemsList := tStringList.Create;
  //fItemsList.OnChange := OnItemListChange;

  fParentAutoSizeColumn := TRUE;
  fParentColWidth := TRUE;
  fColWidth := 64;
  fInstantAction := TRUE;
end;

procedure TSigGridEditor.DelayedImmediateAction(const pObject: tObject;
  var pNewDelay: integer);
begin
  if fInstantAction then
  begin
    if fSigGrid.JustClicked then
    begin
      // make sure we are still active

      fSigGrid.JustClicked := FALSE;
      if assigned( Combobox ) then
      begin
        if not ComboBox.DroppedDown then
        begin
          ComboBox.DroppedDown := TRUE;
        end;
      end
      else if assigned( Button ) then
      begin
        OnButtonClick( Self );
      end;
    end;
  end;

  (*
  // resize and show editor
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
        //ComboBox.DroppedDown := TRUE;
      end;
    end;
  end;
  *)
end;

function TSigGridEditor.DesiredRowHeight(
  const DefaultTextHeight: integer): integer;
begin
  case fStyle of
    esNone: Result := 0;
    esDatePicker,
    esTimePicker,
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

destructor TSigGridEditor.Destroy;
begin
  if assigned( fSigGrid ) then
  begin
    fSigGrid.UnregisterEditor( self );
    fSigGrid.InvalidateGrid;
  end;
  fStringList.Free;
  fItemsList.Free;
  inherited;
end;

procedure TSigGridEditor.DrawCell(Canvas: TCanvas; ACol, ARow: Integer; Rect: TRect;
  const State: TGridDrawState; const pCell : TSigGeneralGridCell; const OwnerEnabled : boolean;
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
      try
        CheckColWidth( ACol, iValue );
      except
      end;
      case fStyle of
        esNone:
        begin
          DrawString( Canvas, Rect, iValue );
        end;
        esDatePicker,
        esTimePicker,
        esSpinEdit,
        esButton,
        esMaskEdit,
        esDropDown,
        esDropDownList:
        begin
          if csDesigning in ComponentState then
          begin
            if (ARow = fSigGrid.FixedRows) and (ACol = Column ) then
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
                //fEditor.Height := Rect.Top - Rect.Bottom;
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
              if OwnerFocused{ or fEditor.Focused} then
              begin
                // resize and show editor
                if (CellRowBeingEdited <> ARow) or (CellColBeingEdited <> ACol ) then
                begin
                  if SigGrid.JustClicked then
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
                    //fEditor.Top := fSigGrid.Top + Rect.Top + 2;
                    fEditor.Top := fSigGrid.Top + 2 + ((Rect.Bottom + Rect.Top - fEditor.Height ) div 2);
                    fEditor.Left := fSigGrid.Left + Rect.Left + 2;
                    fEditor.Width := Rect.Right - Rect.Left;
                    //fEditor.Height := Rect.Top - Rect.Bottom;
                    fEditor.Hint := ErrorText;
                    fEditor.ShowHint := ErrorText <> '';
                    fEditor.SetFocus;
                    if assigned( fGetEditValue ) then
                    begin
                      fGetEditValue( iValue ); // don't use titles in editor!
                    end;
                    if fEditor is tMaskEdit then
                    begin
                      (fEditor as tMaskEdit).SelectAll;
                    end
                    else if fEditor is tComboBox then
                    begin
                      ComboBox.Items.Assign( fItemsList );
                    end;
                    if fInstantAction then
                    begin
                      if assigned( Button ) then
                      begin
                        fSigGrid.AddDelayedAction( DelayedImmediateAction, self );
                      end
                      else if assigned( DatePicker ) then
                      begin
                        if not DatePicker.DroppedDown then
                        begin
                          fSigGrid.AddDelayedAction( DelayedImmediateAction, self );
                        end;
                      end
                      else if assigned( Combobox ) then
                      begin
                        if not ComboBox.DroppedDown then
                        begin
                          //ComboBox.DroppedDown := TRUE;
                          fSigGrid.AddDelayedAction( DelayedImmediateAction, self );
                        end;
                      end;
                    end;
                  end
                  else
                  begin
                    DrawString( Canvas, Rect, iValue );
                  end;
                end
              end
              else if fEditor.Focused then
              begin
                if (CellRowBeingEdited = ARow) and (CellColBeingEdited = ACol ) then
                begin
                  if assigned( fGetEditValue ) then
                  begin
                    fGetEditValue( iValue ); // don't use titles in editor!
                  end;
                  {
                  if fEditor is tMaskEdit then
                  begin
                    (fEditor as tMaskEdit).SelStart := Length( (fEditor as tMaskEdit).Text );
                  end;
                  }
                end
                else
                begin
                  DrawString( Canvas, Rect, iValue );
                end;
              end
              else if fEditor.Visible then
              begin
                if (CellRowBeingEdited = ARow) and (CellColBeingEdited = ACol ) then
                begin
                  if assigned( fGetEditValue ) then
                  begin
                    fGetEditValue( iValue ); // don't use titles in editor!
                  end;
                  {
                  if fEditor is tMaskEdit then
                  begin
                    (fEditor as tMaskEdit).SelStart := Length( (fEditor as tMaskEdit).Text );
                  end;
                  }
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
              {
              if ((CellRowBeingEdited = ARow) and (CellColBeingEdited = ACol)) or (not OwnerEnabled) then
              begin
                fEditor.Visible := FALSE;
                fSigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited );
                CellRowBeingEdited := -1;
                CellColBeingEdited := -1;
              end;
              }
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

procedure TSigGridEditor.DrawString(Canvas: TCanvas; Rect: TRect;
  Value: string);
begin
  // for now we use standard method
  //Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, Value );
  inc( Rect.Left, 2 );
  dec( Rect.Right, 1 );
  inc( Rect.Top, 2 );
  dec( Rect.Bottom, 1 );
  Canvas.TextRect( Rect, Value, [tfWordBreak] );
end;

procedure TSigGridEditor.EditorExit(Sender: tObject);
begin
  fEditor.Hide;
  SigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited);
  CellRowBeingEdited := -1;
  CellColBeingEdited := -1;
end;

function TSigGridEditor.GetButton: tBitBtn;
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

procedure TSigGridEditor.GetButtonEditValue(const Value: string);
begin
  Button.Caption := Value;
end;

function TSigGridEditor.GetCellColBeingEdited: integer;
begin
  Result := SigGrid.ColBeingEdited;
end;

function TSigGridEditor.GetCellRowBeingEdited: integer;
begin
  Result := SigGrid.RowBeingEdited;
end;

function TSigGridEditor.GetComboBox: tComboBox;
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

function TSigGridEditor.GetDatePicker: tDateTimePicker;
begin
  Result := nil;
  if assigned( fEditor ) then
  begin
    if fEditor is tDateTimePicker then
    begin
      Result := fEditor as tDateTimePicker;
    end;
  end;
end;

procedure TSigGridEditor.GetDatePickerValue(const Value: string);
begin
  try
    case DatePicker.Kind of
      dtkDate:
      begin
        if Value = '' then
        begin
          DatePicker.Date := Now();
        end
        else
        begin
          DatePicker.Date := StrToDate( Value );
        end;
      end;
      dtkTime:
      begin
        if Value = '' then
        begin
          DatePicker.Time := 0;
        end
        else
        begin
          DatePicker.Time := StrToTime( Value );
        end;
      end
    end;
  except

  end;
end;

procedure TSigGridEditor.GetDropDownEditValue(const Value: string);
begin
  if ComboBox.Text <> Value then
  begin
    ComboBox.Text := Value;
  end;
end;

procedure TSigGridEditor.GetDropDownImageListEditValue(const Value: string);
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

procedure TSigGridEditor.GetDropDownListEditValue(const Value: string);
var
  i: Integer;
begin
  if not SameText( ComboBox.Text, Value ) then
  begin
    for i := 0 to ComboBox.Items.Count - 1 do
    begin
      if SameText( Value, ComboBox.Items[ i ] ) then
      begin
        ComboBox.ItemIndex := i;
        exit;
      end;
    end;
    // else
    ComboBox.ItemIndex := -1;
  end;
end;

function TSigGridEditor.GetMaskEdit: tMaskEdit;
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

procedure TSigGridEditor.GetMaskEditValue(const Value: string);
begin
  MaskEdit.Text := Value;
end;

function TSigGridEditor.GetObjects(const pVal: string): tObject;
var
  i: Integer;
begin
  for i := 0 to fItemsList.Count - 1 do
  begin
    if SameText( fItemsList[ i ], pVal ) then
    begin
      Result := fItemsList.Objects[ i ];
      exit;
    end;
  end;
  // else
  raise Exception.Create('"' + pVal + '" not found in Items List');
end;

function TSigGridEditor.GetSpinEdit: tSigSpinEdit;
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

procedure TSigGridEditor.GetSpinEditValue(const Value: string);
begin
  SpinEdit.Value := StrToIntDef( Value, 0 );
end;

function TSigGridEditor.GetStrings: TStrings;
begin
  Result := fItemsList;
  {
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
  }
end;

procedure TSigGridEditor.HideEditor;
begin
  if assigned( fEditor ) then
  begin
    if fEditor.Visible then
    begin
      fEditor.Visible := FALSE;
      fSigGrid.InvalidateCell( CellColBeingEdited, CellRowBeingEdited );
      CellRowBeingEdited := -1;
      CellColBeingEdited := -1;
    end;
  end;
end;

procedure TSigGridEditor.OnButtonClick(Sender: tObject);
begin
  if assigned( fOnClick ) then
  begin
    fOnClick( self );
    // caption may have changed
    Button.Caption := fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ];
  end;
end;

procedure TSigGridEditor.OnDatePickerChange(Sender: TObject);
var
  iNewVal : string;
begin
  case DatePicker.Kind of
    dtkDate: iNewVal := DateToStr( DatePicker.Date );
    dtkTime: iNewVal := TimeToStr( DatePicker.Time );
  end;
  if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> iNewVal then
  begin
    fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := iNewVal;
    if assigned( fSigGrid.OnCellEditChange ) then
    begin
      fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, iNewVal );
    end;
    CheckColWidth( CellColBeingEdited, iNewVal );
  end;

end;

procedure TSigGridEditor.OnDropDownImageListChange(Sender: tObject);
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

procedure TSigGridEditor.OnDropDownListChange(Sender: tObject);
begin
  if fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] <> ComboBox.Text then
  begin
    fSigGrid.Cell[ CellColBeingEdited, CellRowBeingEdited ] := ComboBox.Text;
    fSigGrid.CellObject[ CellColBeingEdited, CellRowBeingEdited ] := ItemsList.Objects[ ComboBox.ItemIndex ];
    if assigned( fSigGrid.OnCellEditChange ) then
    begin
      fSigGrid.OnCellEditChange( fSigGrid, CellColBeingEdited, CellRowBeingEdited, ComboBox.Text );
    end;
    CheckColWidth( CellColBeingEdited, ComboBox.Text );
  end;
end;

procedure TSigGridEditor.OnMaskEditChange(Sender: tObject);
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

procedure TSigGridEditor.OnSpinEditChange(Sender: TObject);
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

procedure TSigGridEditor.PrintCell(Canvas: TCanvas; ACol, ARow: Integer;
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
    esDatePicker,
    esTimePicker,
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

procedure TSigGridEditor.ResetText( const pCol, pRow : integer; const pNewVal: string);
var
  i : integer;
  iDate : tDateTime;
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
          esDatePicker:
          begin
            try
              iDate := StrToDate( pNewVal );
              DatePicker.DateTime := iDate;
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
          esDropDown:
          begin
            ComboBox.Text := pNewVal;
          end;
          esDropDownList:
          begin
            if ComboBox.Text <> pNewVal then
            begin
              for i := 0 to ComboBox.Items.Count - 1 do
              begin
                if SameText( ComboBox.Items[ i ], pNewVal) then
                begin
                  ComboBox.ItemIndex := i;
                  exit;
                end;
              end;
              // else
              ComboBox.ItemIndex := -1;
            end;
          end;
        end;
      end;
    end;
  end;
end;

class function TSigGridEditor.ScrollBarWidth: integer;
begin
  Result := GetSystemMetrics( SM_CXVSCROLL );
end;

procedure TSigGridEditor.SetAllowUseToRight(const Value: boolean);
//var
//  i : integer;
begin
  fAllowUseToRight := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetAutoSizeColumn(const Value: boolean);
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

procedure TSigGridEditor.SetCellColBeingEdited(const Value: integer);
begin
  SigGrid.ColBeingEdited := Value;
end;

procedure TSigGridEditor.SetCellRowBeingEdited(const Value: integer);
begin
  SigGrid.RowBeingEdited := Value;
end;

procedure TSigGridEditor.SetColumn(const Value: integer);
begin
  fColumn := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetColWidth(const Value: integer);
begin
  fColWidth := Value;
  if assigned( SigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetImages(const Value: tImageList);
begin
  fImages := Value;
  if assigned( fSigGrid ) then
  begin
    fSigGrid.RecalculateRowHeights;
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetItemsList(const Value: TStringList);
begin
  if assigned( Value ) then
  begin
    fItemsList.Assign( Value );
  end
  else
  begin
    fItemsList.Clear;
  end;
  if assigned( ComboBox ) then
  begin
    ComboBox.Items.Assign( fItemsList );
  end;
end;

procedure TSigGridEditor.SetMaxLen(const Value: integer);
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
    esDatePicker: ;
    esTimePicker: ;
  end;
end;

procedure TSigGridEditor.SetMaxVal(const Value: integer);
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
    esDatePicker: ;
    esTimePicker: ;
  end;
end;

procedure TSigGridEditor.SetMinVal(const Value: integer);
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
    esDatePicker: ;
    esTimePicker: ;
  end;
end;

procedure TSigGridEditor.SetObjects(const pVal: string; const Value: tObject);
var
  i: Integer;
begin
  for i := 0 to fItemsList.Count - 1 do
  begin
    if SameText( fItemsList[ i ], pVal ) then
    begin
      fItemsList.Objects[ i ] := Value;
      exit;
    end;
  end;
  // else
  raise Exception.Create('"' + pVal + '" not found in Items List');
end;

procedure TSigGridEditor.SetOnClick(const Value: TNotifyEvent);
begin
  fOnClick := Value;
end;

procedure TSigGridEditor.SetOnKeyPress(const Value: TKeyPressEvent);
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
    esDatePicker,
    esTimePicker:
    begin
      DatePicker.OnKeyPress := fOnKeyPress;
    end;
  end;
end;

procedure TSigGridEditor.SetParentAutoSizeColumn(const Value: boolean);
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

procedure TSigGridEditor.SetParentColWidth(const Value: boolean);
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

procedure TSigGridEditor.SetSigGrid(const Value: TSigGeneralGrid);
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
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetStringList(const Value: TStringList);
begin
  fStringList.Assign( Value );
  if assigned( fSigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetStyle(const Value: TSigEditorStyle);
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
    esDatePicker:
    begin
      fEditor := TDateTimePicker.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      DatePicker.OnChange := OnDatePickerChange;
      fGetEditValue := GetDatePickerValue;
      DatePicker.OnExit := EditorExit;
      DatePicker.OnKeyPress := fOnKeyPress;
      DatePicker.Kind := dtkDate;
    end;
    esTimePicker:
    begin
      fEditor := TDateTimePicker.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      DatePicker.OnChange := OnDatePickerChange;
      fGetEditValue := GetDatePickerValue;
      DatePicker.OnExit := EditorExit;
      DatePicker.OnKeyPress := fOnKeyPress;
      DatePicker.Kind := dtkTime;
    end;
    esButton:
    begin
      fEditor := tBitBtn.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      Button.OnKeyPress := fOnKeyPress;
      Button.OnClick := OnButtonClick;
      Button.OnExit := EditorExit;
      fGetEditValue := GetButtonEditValue;
    end;
    esSpinEdit:
    begin
      fEditor := tSigSpinEdit.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
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
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      fGetEditValue := GetMaskEditValue;
      MaskEdit.OnChange := OnMaskEditChange;
      MaskEdit.OnExit := EditorExit;
      MaskEdit.OnKeyPress := fOnKeyPress;
      MaskEdit.MaxLength := fMaxLen;
    end;
    esDropDown:
    begin
      fEditor := tComboBox.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      ComboBox.Style := csDropDown;
      fGetEditValue := GetDropDownEditValue;
      ComboBox.OnChange := OnDropDownListChange;
      ComboBox.OnExit := EditorExit;
      ComboBox.MaxLength := fMaxLen;
    end;
    esDropDownList:
    begin
      fEditor := tComboBox.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
      ComboBox.Style := csDropDownList;
      fGetEditValue := GetDropDownListEditValue;
      ComboBox.OnChange := OnDropDownListChange;
      ComboBox.OnExit := EditorExit;
      ComboBox.MaxLength := fMaxLen;
    end;
    esImageList:
    begin
      fEditor := nil;
      if assigned( Images ) then
      begin
        if assigned( SigGrid ) then
        begin
          SigGrid.ColWidths[ Column ] := Images.Width;
        end;
      end;
      fGetEditValue := nil;
    end;
    esDropDownImageList:
    begin
      fEditor := tComboBox.Create( self );
      if assigned( SigGrid ) then
      begin
        fEditor.Parent := SigGrid.Parent;
      end;
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
    fSigGrid.RecalculateRowHeights;
    fEditor.Visible := FALSE;
  end;
  if assigned( SigGrid ) then
  begin
    fSigGrid.InvalidateGrid;
  end;
end;

procedure TSigGridEditor.SetVisible(const Value: boolean);
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

procedure TSigGridEditor.OnDropDownImageListDrawItem(Control: TWinControl; Index: Integer;
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


procedure TSigGridEditor.ShowEditor(const pVisible: boolean; const pRect : TRect);
begin
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


initialization
  Data.bind.components.RegisterObservableMember( TArray<TClass>.Create( TSigGeneralGrid ), 'ActiveColCount','DFM');
  Data.bind.components.RegisterObservableMember( TArray<TClass>.Create( TSigGeneralGrid ), 'ActiveRowCount','DFM');

finalization
  Data.bind.components.UnRegisterObservableMember( TArray<TClass>.Create( TSigGeneralGrid ) );

end.
