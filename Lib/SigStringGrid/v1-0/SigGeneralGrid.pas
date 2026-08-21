unit SigGeneralGrid;

interface

{
  A bit like a string grid but designed to have multiple editors, one for each column.
}

uses
  SysUtils, Classes, Controls, Grids,
  Mask,
  StdCtrls,
  Contnrs,
  Graphics,
  Types,
  SigSpinEdit;

type
  tSigEditorStyle = ( esNone, esMaskEdit, esDropDown, esDropDownList, esImageList, esSpinEdit );

  tSigGetImageIndex = function( const Col, Row : integer; const IsFixed : boolean; const Value : string ) : integer of object;

  tSetupEditor = procedure( const Value : string ) of object;

type
  TSigGeneralGrid = class;

  tSigEditor = class
  private
    fEditor: tWinControl;
    fStyle: tSigEditorStyle;
    fOwner: TSigGeneralGrid;
    fColumn: integer;
    fImages: tImageList;
    fOnGetImageIndex: tSigGetImageIndex;
    fAutoSizeCol: boolean;
    fResizeColsSet : boolean;
    fCellBeingEdited: integer;
    fGetEditValue : tSetupEditor;
    procedure SetStyle(const Value: tSigEditorStyle);
    function GetComboBox: tComboBox;
    function GetStrings: tStrings;
    procedure SetAutoSizeCol(const Value: boolean);
    function GetAutoSizeCol: boolean;
    function GetSpinEdit: tSigSpinEdit;
    property ComboBox : tComboBox
             read GetComboBox;
    property SpinEdit : tSigSpinEdit
             read GetSpinEdit;
    procedure OnSpinEditChange( Sender : tObject );
    procedure OnDropDownListChange( Sender : tObject );
    procedure GetSpinEditValue( const Value : string );
    procedure GetDropDownListEditValue( const Value : string );
    procedure EditorExit( Sender : tObject );
    procedure CheckColWidth( const Value : string );
  public
    constructor Create( pOwner : TSigGeneralGrid; const pColumn : integer );
    destructor Destroy; override;

    property Editor : tWinControl
             read fEditor;
    property Style : tSigEditorStyle
             read fStyle
             write SetStyle;
    property Owner : TSigGeneralGrid
             read fOwner;
    property Column : integer
             read fColumn;
    property Items : tStrings
             read GetStrings;
    property Images : tImageList
             read fImages
             write fImages;
    property OnGetImageIndex : tSigGetImageIndex
             read fOnGetImageIndex
             write fOnGetImageIndex;
    property AutoSizeCol : boolean
             read GetAutoSizeCol
             write SetAutoSizeCol;
    property CellBeingEdited : integer
             read fCellBeingEdited;

    function DesiredRowHeight( const DefaultTextHeight : integer ) : integer;
    procedure DrawCell( Canvas : TCanvas; ARow : Integer; Rect: TRect; State: TGridDrawState; Value : string );
    procedure DrawString( Canvas : TCanvas; Rect : TRect; Value : string );
  end;

  tSigEditorList = class( tObjectList )
  private
    fParent: tSigGeneralGrid;
    function GetEditor(const pColumn : integer): tSigEditor;
    function GetEditorType(const pColumn: integer): tSigEditorStyle;
    procedure SetEditorType(const pColumn: integer;
      const Value: tSigEditorStyle);
    function GetChoiceStrings(const pCol: integer): tStrings;
  public
    constructor Create( const pParent : tsigGeneralGrid ); reintroduce;

    property Parent : tSigGeneralGrid
             read fParent;
    property Editor[ const pColumn : integer ] : tSigEditor
             read GetEditor;
    property EditorType[ const pColumn : integer ] : tSigEditorStyle
             read GetEditorType
             write SetEditorType;
    property ChoiceStrings[ const pCol : integer ] : tStrings
             read GetChoiceStrings;

    procedure DrawCell( Canvas : TCanvas; ACol, ARow : Integer; Rect: TRect; State: TGridDrawState; Value : string );

  end;

  tSigGeneralGridCell = class
  private
    fRow: integer;
    fCol: integer;
    fText: string;
    fError: boolean;
  public
    constructor Create( const pCol, pRow : integer );
    property Row : integer
             read fRow;
    property Column : integer
             read fCol;
    property Text : string
             read fText
             write fText;
    property Error : boolean // defines which font to use for this cell
             read fError
             write fError;
  end;

  tSigGeneralGridCellList = class( tObjectList )
  private
    function GetSigGeneralGridCell(const Col, Row : integer; ForceCreate : boolean = FALSE ): tSigGeneralGridCell;
    function GetCell(const Col, Row: integer): string;
    procedure SetCell(const Col, Row: integer; const Value: string);
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
{
    property SigGeneralGridCell[ const Col, Row : integer ] : tSigGeneralGridCell
             read GetSigGeneralGridCell;
}
  public
    constructor Create; reintroduce;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property InError[ const Col, Row : integer ] : boolean
             read GetError
             write SetError;
  end;

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
    function GetCell(const Col, Row : integer): string;
    procedure SetCell(const Col, Row : integer; const Value: string);
    procedure SetTextHMargin(const Value: integer);
    procedure SetAutosizeRows(const Value: boolean);
    function GetColumnEditStyle(const pCol: integer): tSigEditorStyle;
    procedure SetColumnEditStyle(const pCol: integer;
      const Value: tSigEditorStyle);
    procedure SetTextVMargin100(const Value: integer);
    procedure SetMinRowHeight(const Value: integer);
    function GetImageList(const pCol: integer): tImageList;
    procedure SetImageList(const pCol: integer; const Value: tImageList);
    function GetChoiceStrings(const pCol: integer): tStrings;
    function GetError(const Col, Row: integer): boolean;
    procedure SetError(const Col, Row: integer; const Value: boolean);
    procedure SetErrorFont(const Value: TFont);
    procedure SetNormalFont(const Value: TFont);
  protected
    { Protected declarations }
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Cell[ const Col, Row : integer ] : string
             read GetCell
             write SetCell;
    property ColumnEditStyle[ const pCol : integer ] : tSigEditorStyle
             read GetColumnEditStyle
             write SetColumnEditStyle;
    property ImageList[ const pCol : integer ] : tImageList
             read GetImageList
             write SetImageList;
    property ChoiceStrings[ const pCol : integer ] : tStrings
             read GetChoiceStrings;
    property Error[ const Col, Row : integer ] : boolean
             read GetError
             write SetError;

    function MaxTextWidth( const Col : integer ) : integer;
  published
    { Published declarations }
    property AutoSizeRows : boolean
             read fAutosizeRows
             write SetAutosizeRows
             default FALSE;
    property AutoSizeCols : boolean
             read fAutoSizeCols
             write fAutoSizeCols
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
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigGeneralGrid]);
end;

{ tSigEditor }

procedure tSigEditor.CheckColWidth(const Value: string);
var
  iWidth : integer;
begin
  if AutoSizeCol then
  begin
    iWidth := 0;
    case fStyle of
      esNone: ;
      esMaskEdit:
      begin
        iWidth := Owner.Canvas.TextWidth( Value + 'XX' );
      end;
      esSpinEdit,
      esDropDown,
      esDropDownList:
      begin
        iWidth := Owner.Canvas.TextWidth( Value + 'XX' ) + 16; // allow for spinner or drop down icon
      end;
      esImageList: ;
    end;
    if iWidth > Owner.ColWidths[ fColumn ] then
    begin
      Owner.ColWidths[ fColumn ] := iWidth;
      fEditor.Width := iWidth;
    end;
  end;
end;

constructor tSigEditor.Create(pOwner: TSigGeneralGrid; const pColumn : integer);
begin
  inherited Create;

  fOwner := pOwner;
  fColumn := pColumn;
  fCellBeingEdited := -1;

end;

function tSigEditor.DesiredRowHeight( const DefaultTextHeight : integer ): integer;
begin
  case fStyle of
    esNone: Result := 0;
    esSpinEdit,
    esMaskEdit,
    esDropDown,
    esDropDownList: Result := DefaultTextHeight;
    esImageList:
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

destructor tSigEditor.Destroy;
begin

  inherited;

end;

procedure tSigEditor.DrawCell(Canvas: TCanvas; ARow : Integer; Rect: TRect;
  State: TGridDrawState; Value: string);
var
  iImageIndex : integer;
begin
  CheckColWidth( Value );
  case fStyle of
    esNone:
    begin
      DrawString( Canvas, Rect, Value );
    end;
    esSpinEdit,
    esMaskEdit,
    esDropDown,
    esDropDownList:
    begin
      if gdSelected in State then
      begin
        // resize and show editor
        if fCellBeingEdited <> ARow then
        begin
          fCellBeingEdited := ARow;
          fEditor.Visible := TRUE;
          if assigned( fGetEditValue ) then
          begin
            fGetEditValue( Value );
          end;
          fEditor.Top := Owner.Top + Rect.Top + 2;
          fEditor.Left := Owner.Left + Rect.Left + 2;
          fEditor.Width := Rect.Right - Rect.Left;
          fEditor.Height := Rect.Bottom - Rect.Top + 2;
          fEditor.SetFocus;
//        end
//        else
//        begin
//          fEditor.Invalidate;
//          fEditor.Top := Rect.Top;
//          fEditor.Left := Rect.Left;
//          fEditor.Width := Rect.Right - Rect.Left;
//          fEditor.Height := Rect.Bottom - Rect.Top;
        end;
      end
      else
      begin
        // hide Editor if showing at current location and show text
        if CellBeingEdited = ARow then
        begin
          fEditor.Visible := FALSE;
          fCellBeingEdited := -1;
        end;
        DrawString( Canvas, Rect, Value );
      end;
    end;
    esImageList:
    begin
      if assigned( fImages ) then
      begin
        iImageIndex := StrToIntDef( Value, 0 );
        if (iImageIndex >= 0) and (iImageIndex < fImages.Count ) then
        begin
          fImages.Draw( Canvas, Rect.Left, Rect.Top, iImageIndex );
          if AutoSizeCol then
          begin
            Owner.ColWidths[ fColumn ] := fImages.Width;
          end;
        end
        else
        begin
          DrawString( Canvas, Rect, Value );
        end;
      end
      else
      begin
        DrawString( Canvas, Rect, Value );
      end;
    end;
  end;
end;

procedure tSigEditor.DrawString(Canvas: TCanvas; Rect: TRect; Value: string);
begin
  // for now we use standard method
  Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, Value );
end;

procedure tSigEditor.EditorExit(Sender: tObject);
begin
  fEditor.Hide;
  fCellBeingEdited := -1;
end;

function tSigEditor.GetAutoSizeCol: boolean;
begin
  if fResizeColsSet then
  begin
    Result := fAutoSizeCol;
  end
  else
  begin
    Result := Owner.AutoSizeCols;
  end;
end;

function tSigEditor.GetComboBox: tComboBox;
begin
  Result := fEditor as tComboBox;
end;

procedure tSigEditor.GetDropDownListEditValue(const Value: string);
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

function tSigEditor.GetSpinEdit: tSigSpinEdit;
begin
  Result := fEditor as tSigSpinedit;
end;

procedure tSigEditor.GetSpinEditValue( const Value : string );
begin
  SpinEdit.Value := StrToIntDef( Value, 0 );
end;

function tSigEditor.GetStrings: tStrings;
begin
  case fStyle of
    esNone: Result := nil;
    esSpinEdit,
    esMaskEdit: Result := nil;
    esDropDown: Result := ComboBox.Items;
    esDropDownList: Result := ComboBox.Items;
    esImageList: Result := nil;
    else Result := nil;
  end;
end;

procedure tSigEditor.OnDropDownListChange(Sender: tObject);
begin
  Owner.Cell[ Column, CellBeingEdited ] := ComboBox.Text;
  CheckColWidth( ComboBox.Text );
end;

procedure tSigEditor.OnSpinEditChange(Sender: tObject);
begin
  if SpinEdit.IsValid then
  begin
    Owner.Cell[ Column, CellBeingEdited ] := SpinEdit.Text;
    CheckColWidth( SpinEdit.Text );
  end;
end;

procedure tSigEditor.SetAutoSizeCol(const Value: boolean);
(*
var
  iNewWidth, iNewWidth2 : integer;
  i: Integer;
*)
begin
  fAutoSizeCol := Value;
  fResizeColsSet := TRUE;
 (*
  if Value then
  begin
    // force parent resize
    case fStyle of
      esNone: ;
      esMaskEdit:
      begin
        iNewWidth := Owner.MaxTextWidth( Column );
        if iNewWidth > Owner.ColWidths[ Column ] then
        begin
          Owner.ColWidths[ Column ] := iNewWidth;
        end;
      end;
      esDropDown,
      esDropDownList:
      begin
        iNewWidth := Owner.MaxTextWidth( Column );
        // this takes account of current values, but we also need to allow for potential values
        if assigned( Items ) then
        begin
          for i := 0 to Items.Count - 1 do
          begin
            iNewWidth2 := Owner.Canvas.TextWidth( Items[ i ] );
            if iNewWidth2 > iNewWidth then
            begin
              iNewWidth := iNewWidth2;
            end;
          end;
        end;

        if iNewWidth > Owner.ColWidths[ Column ] then
        begin
          Owner.ColWidths[ Column ] := iNewWidth;
        end;
      end;
      esImageList: ;
    end;
  end;
  *)
end;

procedure tSigEditor.SetStyle(const Value: tSigEditorStyle);
begin
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
    esSpinEdit:
    begin
      fEditor := tSigSpinEdit.Create( fOwner );
      SpinEdit.OnChange := OnSpinEditChange;
      fGetEditValue := GetSpinEditValue;
      SpinEdit.OnExit := EditorExit;
    end;
    esMaskEdit:
    begin
      fEditor := tMaskEdit.Create( fOwner );
      fGetEditValue := nil;
    end;
    esDropDown:
    begin
      fEditor := tComboBox.Create( fOwner );
      ComboBox.Style := csDropDown;
      fGetEditValue := nil;
    end;
    esDropDownList:
    begin
      fEditor := tComboBox.Create( fOwner );
      ComboBox.Style := csDropDownList;
      fGetEditValue := GetDropDownListEditValue;
      ComboBox.OnChange := OnDropDownListChange;
    end;
    esImageList:
    begin
      fEditor := nil;
      if assigned( Images ) then
      begin
        Owner.ColWidths[ Column ] := Images.Width;
        fGetEditValue := nil;
      end;
    end;
    else
    begin
      fEditor := nil;
    end;
  end;
  if assigned( fEditor ) then
  begin
    fEditor.Parent := fOwner.Parent;
    fEditor.Visible := FALSE;
  end;
end;

{ tSigEditorList }

constructor tSigEditorList.Create( const pParent : tsigGeneralGrid );
begin
  inherited Create( TRUE );
  fParent := pParent;
end;

procedure tSigEditorList.DrawCell(Canvas: TCanvas; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState; Value: string);
var
  iEditor : tSigEditor;
begin
  iEditor := Editor[ ACol ];
  if assigned( iEditor ) then
  begin
    iEditor.DrawCell( Canvas, ARow, Rect, State, Value );
  end
  else
  begin
    Canvas.TextRect( Rect, Rect.Left+2, Rect.Top+2, Value );
  end;
end;

function tSigEditorList.GetChoiceStrings(const pCol: integer): tStrings;
var
  iEditor : tSigEditor;
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

function tSigEditorList.GetEditor(const pColumn : integer): tSigEditor;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[ i ] as tSigEditor;
    if Result.Column = pColumn then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function tSigEditorList.GetEditorType(const pColumn: integer): tSigEditorStyle;
var
  iEditor : tSigEditor;
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

procedure tSigEditorList.SetEditorType(const pColumn: integer;
  const Value: tSigEditorStyle);
var
  iEditor : tSigEditor;
begin
  iEditor := Editor[ pColumn ];
  if not assigned( iEditor ) then
  begin
    iEditor := tSigEditor.Create( fParent, pColumn );
    Add( iEditor );
  end;
  iEditor.Style := Value;
end;

{ TSigGeneralGrid }

constructor TSigGeneralGrid.Create(AOwner: TComponent);
begin
  inherited;

  fEditorList := tSigEditorList.Create( self );
  fSigCells := tSigGeneralGridCellList.Create;

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
  fEditorList.Free;
  fSigCells.Free;

  FreeAndNil( fNormalFont );
  FreeAndNil ( fErrorFont );

  inherited;
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
  fEditorList.DrawCell( Canvas, ACol, ARow, ARect, AState, Cell[ ACol, ARow ] );
end;

function TSigGeneralGrid.GetCell(const Col, Row : integer): string;
begin
  Result := fSigCells.Cell[ Col, Row ];
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

function TSigGeneralGrid.GetError(const Col, Row: integer): boolean;
begin
  Result := fSigCells.InError[ Col, Row ];
end;

function TSigGeneralGrid.GetImageList(const pCol: integer): tImageList;
var
  iEditor : tSigEditor;
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

procedure TSigGeneralGrid.SetAutosizeRows(const Value: boolean);
var
  iNewRowValue, iNewRowValue2 : integer;
  iTextHeight : integer;
  i: Integer;
  iEditor : tSigEditor;
begin
  fAutosizeRows := Value;
  if Value then
  begin
    iNewRowValue := 0;
    iTextHeight := Canvas.TextHeight( 'X' );
    iTextHeight := (iTextHeight * ( 100 + 2* fTextVMargin100 )) div 100;
    for i := 0 to ColCount - 1 do
    begin
      iEditor := fEditorList.Editor[ i ];
      if assigned( ieditor ) then
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

procedure TSigGeneralGrid.SetCell(const Col, Row : integer; const Value: string);
begin
  fSigCells.Cell[ Col, Row ] := Value;
end;

procedure TSigGeneralGrid.SetColumnEditStyle(const pCol: integer;
  const Value: tSigEditorStyle);
begin
  fEditorList.EditorType[ pCol ] := Value;
end;

procedure TSigGeneralGrid.SetError(const Col, Row: integer;
  const Value: boolean);
begin
  fSigCells.InError[ Col, Row ] := Value;
end;

procedure TSigGeneralGrid.SetErrorFont(const Value: TFont);
begin
  fErrorFont.Assign( Value );
end;

procedure TSigGeneralGrid.SetImageList(const pCol: integer;
  const Value: tImageList);
var
  iEditor : tSigEditor;
begin
  iEditor := fEditorList.Editor[ pCol ];
  if not assigned( iEditor ) then
  begin
    fEditorList.EditorType[ pCol ] := esNone;
  end;
  iEditor.Images := Value;
end;

procedure TSigGeneralGrid.SetMinRowHeight(const Value: integer);
begin
  fMinRowHeight := Value;
end;

procedure TSigGeneralGrid.SetNormalFont(const Value: TFont);
begin
  fNormalFont.Assign( Value );
end;

procedure TSigGeneralGrid.SetTextHMargin(const Value: integer);
begin
  fTextHMargin := Value;
end;

procedure TSigGeneralGrid.SetTextVMargin100(const Value: integer);
begin
  fTextVMargin100 := Value;
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

{ tSigGeneralGridCell }

constructor tSigGeneralGridCell.Create(const pCol, pRow: integer);
begin
  inherited Create;

  fRow := pRow;
  fCol := pCol;

  fText := '';

end;

{ tSigGeneralGridCellList }

constructor tSigGeneralGridCellList.Create;
begin
  inherited Create( TRUE );
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
          Result := tSigGeneralGridCell.Create( Col, Row);
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
        Result := tSigGeneralGridCell.Create( Col, Row);
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
    Result := tSigGeneralGridCell.Create( Col, Row);
    Add( Result );
  end
  else
  begin
    Result := nil;
  end;
end;

(*
function tSigGeneralGridCellList.MaxTextWidth(const Canvas : TCanvas; const Col: integer): integer;
var
  i, iTest : Integer;
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    iSigGeneralGridCell := Items[ i ] as tSigGeneralGridCell;
    if iSigGeneralGridCell.Column = Col then
    begin
      iTest := Canvas.TextWidth( iSigGeneralGridCell.Text );
      if iTest > Result then
      begin
        Result := iTest;
      end;
    end
    else if iSigGeneralGridCell.Column > Col then
    begin
      break; // done
    end;
  end;
  if fhTextMargin = -1 then
  begin
    inc(Result, 2 * Canvas.TextWidth( 'X' ));
  end
  else
  begin
    inc( Result, 2 * fhTextMargin );
  end;
end;
*)

procedure tSigGeneralGridCellList.SetCell(const Col, Row: integer;
  const Value: string);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Text := Value;
end;

(*
procedure tSigGeneralGridCellList.SetCell(const Col, Row: integer;
  const Value: string);
var
  i: Integer;
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  // keep ordered by col then row
  for i := 0 to Count - 1 do
  begin
    iSigGeneralGridCell := Items[ i ] as tSigGeneralGridCell;
    if iSigGeneralGridCell.Column = Col then
    begin
      if iSigGeneralGridCell.Row = Row then
      begin
        iSigGeneralGridCell.Text := Value;
        exit;
      end
      else if iSigGeneralGridCell.Row > Row then
      begin
        iSigGeneralGridCell := tSigGeneralGridCell.Create( Col, Row );
        Insert( i, iSigGeneralGridCell );
        iSigGeneralGridCell.Text := Value;
        exit;
      end;
    end
    else if iSigGeneralGridCell.Column > Col then
    begin
      iSigGeneralGridCell := tSigGeneralGridCell.Create( Col, Row );
      Insert( i, iSigGeneralGridCell );
      iSigGeneralGridCell.Text := Value;
      exit;
    end;
  end;
  // else
  iSigGeneralGridCell := tSigGeneralGridCell.Create( Col, Row );
  Add( iSigGeneralGridCell );
  iSigGeneralGridCell.Text := Value;
end;
*)

procedure tSigGeneralGridCellList.SetError(const Col, Row: integer;
  const Value: boolean);
var
  iSigGeneralGridCell : tSigGeneralGridCell;
begin
  iSigGeneralGridCell := GetSigGeneralGridCell( Col, Row, TRUE );
  iSigGeneralGridCell.Error := Value;
end;

end.
