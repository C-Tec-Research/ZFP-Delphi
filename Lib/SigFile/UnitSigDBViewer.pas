unit UnitSigDBViewer;

{
  Generic Viewer/Editor for SigDB databases
}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.Buttons,
  Vcl.ComCtrls,
  SigPanel,
  SigGeneralGrid,
  SigSpinEdit,
  SigDBRawDB,
  SigDBVCLHelper,
  UnitCustomMessages,
  UnitSigBtreePaintbox,
  System.ImageList;

type
  TTreeViewInterestedParty = class( TInterestedParty )
  private
    fPauseActive: boolean;
    fPauseReleased: boolean;
    fLiveView: boolean;
    fSigDBIndexFileVCLHelper : TSigDBIndexFileVCLHelper;
    fIndexFile: TSigDBIndexFile;
  public
    procedure AfterRecAppend( Sender : TObject; const pRec : tSigDBRecPointer ); override;

    property PauseActive : boolean
             read fPauseActive
             write fPauseActive;

    property PauseReleased : boolean
             read fPauseReleased
             write fPauseReleased;
    property LiveView : boolean
             read fLiveView
             write fLiveView;
    property SigDBIndexFileVCLHelper : TSigDBIndexFileVCLHelper
             read  fSigDBIndexFileVCLHelper
             write fSigDBIndexFileVCLHelper;
    property IndexFile : TSigDBIndexFile
             read fIndexFile
             write fIndexFile;
  end;


  TFrameSigDBViewer = class(TFrame)
    SigPanel1: TSigPanel;
    SigPanel2: TSigPanel;
    SigPanel3: TSigPanel;
    Label1: TLabel;
    ComboBoxIndexFile: TComboBox;
    ImageListSel: TImageList;
    PageControlViewMode: TPageControl;
    TabSheetTreeView: TTabSheet;
    TabSheetRawView: TTabSheet;
    TabSheetEditView: TTabSheet;
    SigPanel4: TSigPanel;
    SigPanelKeyInfo: TSigPanel;
    Label2: TLabel;
    SpeedButtonSearch: TSpeedButton;
    Label3: TLabel;
    SigGeneralGridKeys: TSigGeneralGrid;
    SigSpinEditMaxRecords: TSigSpinEdit;
    SigPanel6: TSigPanel;
    SigPanel7: TSigPanel;
    SigGeneralGridData: TSigGeneralGrid;
    SigPanel8: TSigPanel;
    SigPanel9: TSigPanel;
    SigPanel10: TSigPanel;
    SpeedButtonStartReindex: TSpeedButton;
    SpeedButtonReindexNext: TSpeedButton;
    SpeedButtonCompleteReindex: TSpeedButton;
    PaintBoxDBTree: TPaintBox;
    SigGridEditorKeyName: TSigGridEditor;
    SigGridEditorKeyValue: TSigGridEditor;
    SigPanel11: TSigPanel;
    SigPanel12: TSigPanel;
    SigPanel13: TSigPanel;
    SigPanelRawViewTopLeft: TSigPanel;
    SigPanelRawViewTopRight: TSigPanel;
    Label4: TLabel;
    SigSpinEditFromRec: TSigSpinEdit;
    Label5: TLabel;
    SigSpinEditMaxCount: TSigSpinEdit;
    SpeedButtonShowNow: TSpeedButton;
    SpeedButtonReindex: TSpeedButton;
    Label6: TLabel;
    EditLastIns: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    EditLastDel: TEdit;
    EditRecCount: TEdit;
    SigGeneralGridRawView: TSigGeneralGrid;
    SigGridEditorEditViewSel: TSigGridEditor;
    SigGridEditorEditViewData: TSigGridEditor;
    SpeedButtonLiveView: TSpeedButton;
    SigGridEditorRawViewSel: TSigGridEditor;
    SigGridEditorRawViewRecNo: TSigGridEditor;
    SigGridEditorRawViewDBRecNo: TSigGridEditor;
    SigGridEditorRawDataLeftChild: TSigGridEditor;
    SigGridEditorRawDataRightChild: TSigGridEditor;
    procedure ComboBoxIndexFileChange(Sender: TObject);
    procedure SpeedButtonStartReindexClick(Sender: TObject);
    procedure SpeedButtonReindexNextClick(Sender: TObject);
    procedure SpeedButtonCompleteReindexClick(Sender: TObject);
    procedure SigGeneralGridDataFixedCellClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure SigGeneralGridDataCellEditChange(const Sender: TObject; const Col,
      Row: Integer; const Value: string);
    procedure SigGeneralGridKeysCellEditChange(const Sender: TObject; const Col,
      Row: Integer; const Value: string);
    procedure SpeedButtonLiveViewClick(Sender: TObject);
    procedure SpeedButtonShowNowClick(Sender: TObject);
  private
    fDatabase: TSigDBDatabase;
    fIndexFile : TSigDBIndexFile;
    fDataFile : TSigDBFileBase;
    fTreeViewInterestedParty : TTreeViewInterestedParty;
    fRowBeingEdited: integer;
    fSigDBIndexFileVCLHelper : TSigDBIndexFileVCLHelper;
    procedure SetDatabase(const Value: TSigDBDatabase);
    { Private declarations }
    procedure BuildDataViewKeyList;
    procedure BuildDataViewDataHeadings;
    procedure SetIndexFile(const Value: TSigDBIndexFile);
    procedure SetRowBeingEdited(const Value: integer);
    function ComboBoxIndexOfFile( const pFile : TSigDBIndexFile ) : integer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Database : TSigDBDatabase
             read fDatabase
             write SetDatabase;
    property CurrentIndexFile : TSigDBIndexFile
             read fIndexFile
             write SetIndexFile;
    property CurrentDataFile : TSigDBFileBase
             read fDataFile;
    property RowBeingEdited : integer
             read fRowBeingEdited
             write SetRowBeingEdited;
    procedure StartLiveView;
    procedure ShowIndexFileRawView;
    procedure AddRawViewRow( const pRow : integer );
    procedure AddRawViewRec( const pRec : integer );
  end;

  TRawDataInterestedParty = class( TInterestedParty )
  private
    fFrame: TFrameSigDBViewer;
  public
    constructor Create( const pFrame : TFrameSigDBViewer );

    procedure OnAction( Sender : TObject; const pRec : tSigDBRecPointer); override;

    property Frame : TFrameSigDBViewer
             read fFrame;
  end;

implementation

{$R *.dfm}

{ TFrameSigDBViewer }

procedure TFrameSigDBViewer.AddRawViewRec(const pRec: integer);
var
  iRow : integer;
begin
  iRow := pRec - SigSpinEditFromRec.Value;
  if (iRow >= 1) and (iRow <= SigSpinEditMaxRecords.Value ) then
  begin
    AddRawViewRow( iRow );
  end;
end;

procedure TFrameSigDBViewer.AddRawViewRow(const pRow: integer);
var
  iRec : integer;
  iRow : integer;
begin
  iRec := SigSpinEditFromRec.Value + pRow;
  iRow := pRow + SigGeneralGridRawView.FixedCols;
  fIndexFile.Lock;
  try
    SigGeneralGridRawView.Cell[ 1, iRow ] := IntToStr( iRec );
    if fIndexFile.Read( iRec ) then
    begin
      SigGeneralGridRawView.Cell[ 2, iRow ] := IntToStr( fIndexFile.DataRec );
      SigGeneralGridRawView.Cell[ 3, iRow ] := IntToStr( fIndexFile.LeftChild );
      SigGeneralGridRawView.Cell[ 4, iRow ] := IntToStr( fIndexFile.RightChild );
    end
    else
    begin
      SigGeneralGridRawView.Cell[ 2, iRow ] := '';
      SigGeneralGridRawView.Cell[ 3, iRow ] := '';
      SigGeneralGridRawView.Cell[ 4, iRow ] := '';
    end;

  finally
    fIndexFile.Unlock
  end;
end;

procedure TFrameSigDBViewer.BuildDataViewDataHeadings;
var
  i, iCol: Integer;
begin
  // implicitly this hides the data grid until the search button is clicked
  SigGeneralGridData.Visible := FALSE;
  // this also speeds up the update process!
  if assigned( CurrentDataFile ) then
  begin
    iCol := 0;
    for i := 0 to CurrentDataFile.FieldCount - 1 do
    begin
      inc( iCol );
      SigGeneralGridData.Cell[ iCol, 0 ] := CurrentDataFile.FieldTitle( i );
      SigGeneralGridData.CellTag[ iCol, 0 ] := i; // in case column moved by user!
    end;
    if iCol > 0 then
    begin
      SigGeneralGridData.ColCount := iCol + 1;
      SpeedButtonSearch.Enabled := TRUE;
      SigSpinEditMaxRecords.Enabled := TRUE;
    end
    else
    begin
      SpeedButtonSearch.Enabled := FALSE;
      SigSpinEditMaxRecords.Enabled := FALSE;
    end;
  end;
end;

procedure TFrameSigDBViewer.BuildDataViewKeyList;
var
  iDataFile : TSigDBFileBase;
  iRow : integer;
  i: integer;
  iFieldID : integer;
begin
  {
    Builds the key list to allow users to enter their key values
  }
  if assigned( fIndexFile ) then
  begin
    iDataFile := fIndexFile.DataFile;
    iRow := 0;
    for i := 0 to fIndexFile.Fields.Count - 1 do
    begin
      inc( iRow );
      iFieldID := fIndexFile.Fields.IndexField[ i ].DataFileID;
      SigGeneralGridKeys.Cell[ 0, iRow ] := iDataFile.FieldTitle( iFieldID );
      SigGeneralGridKeys.CellTag[ 1, iRow ] := iFieldID;
      SigGeneralGridKeys.Cell[ 1, iRow ] := '';
         // Column = iRow (starting at 1) because of the Sel Column
    end;
    if iRow < 1 then
    begin
      SigPanelKeyInfo.Visible := FALSE;
    end
    else
    begin
      SigPanelKeyInfo.Visible := TRUE;
      SigGeneralGridKeys.RowCount := iRow + 1;
    end;
  end
  else
  begin
    SigPanelKeyInfo.Visible := FALSE;
  end;
end;

procedure TFrameSigDBViewer.ComboBoxIndexFileChange(Sender: TObject);
begin
  if ComboBoxIndexFile.ItemIndex < 0 then
  begin
    CurrentIndexFile := nil;
  end
  else
  begin
    CurrentIndexFile := ComboBoxIndexFile.Items.Objects[ ComboBoxIndexFile.ItemIndex ] as tSigDBIndexFile;
  end;
  //FrameSigDBFileStructureListViews.SigDBIndexFile := fIndexFile;
  BuildDataViewKeyList;
  BuildDataViewDataHeadings;
end;

function TFrameSigDBViewer.ComboBoxIndexOfFile(
  const pFile: TSigDBIndexFile): integer;
begin
  for Result := 0 to ComboBoxIndexFile.Items.Count - 1 do
  begin
    if ComboBoxIndexFile.Items.Objects[ Result ] = pFile then
    begin
      exit;
    end;
  end;
  // else
  Result := -1;
end;

constructor TFrameSigDBViewer.Create(AOwner: TComponent);
begin
  inherited;

  fSigDBIndexFileVCLHelper := TSigDBIndexFileVCLHelper.Create;

end;

destructor TFrameSigDBViewer.Destroy;
begin
  fSigDBIndexFileVCLHelper.Free;

  inherited;
end;

procedure TFrameSigDBViewer.StartLiveView;
begin
  if assigned(CurrentIndexFile) then
  begin
    if not assigned(fTreeViewInterestedParty) then
    begin
      fTreeViewInterestedParty := TTreeViewInterestedParty.Create;
      fTreeViewInterestedParty.SigDBIndexFileVCLHelper := fSigDBIndexFileVCLHelper;
      fTreeViewInterestedParty.IndexFile := CurrentIndexFile;
      CurrentIndexFile.RegisterInterestedParty(fTreeViewInterestedParty);
    end;
    fTreeViewInterestedParty.LiveView := TRUE;
    fTreeViewInterestedParty.PauseActive := FALSE;
  end;
end;

procedure TFrameSigDBViewer.SetDatabase(const Value: TSigDBDatabase);
var
  i : integer;
  iIndexFile : tSigDBIndexFile;
begin
  fDatabase := Value;
  ComboBoxIndexFile.Clear; // when we clear a combo box, its itemIndex property goes to -1,
  CurrentIndexFile := nil; // We could do this more clearly by calling ComboBoxIndexFileChange( self ) but this is quicker
  if assigned( fDatabase ) then
  begin
    with fDatabase.IndexFiles do
    begin
      for i := 0 to Count - 1 do
      begin
        iIndexFile := IndexFile[ i ];
        ComboBoxIndexFile.Items.AddObject( iIndexFile.ClassName, iIndexFile );
      end;
    end;
  end;
end;

procedure TFrameSigDBViewer.SetIndexFile(const Value: TSigDBIndexFile);
var
  iIndex : integer;
begin
  // disassociate current links
  if fIndexFile <> Value then
  begin
    if assigned( fIndexFile ) then
    begin
      if assigned( fTreeViewInterestedParty ) then
      begin
        fIndexFile.UnRegisterInterestedParty( fTreeViewInterestedParty );
      end;
      fSigDBIndexFileVCLHelper.PaintBox := nil;
      fSigDBIndexFileVCLHelper.SigDBFileBase := nil;
    end;
    fIndexFile := Value;
    // make sure combo box is aligned
    iIndex := ComboBoxIndexOfFile( fIndexFile );
    if ComboBoxIndexFile.ItemIndex <> iIndex then
    begin
      ComboBoxIndexFile.ItemIndex := iIndex;
    end;
    // register interest
    if assigned( fIndexFile ) then
    begin
      fDataFile := fIndexFile.DataFile;
      if assigned( fTreeViewInterestedParty ) then
      begin
        fIndexFile.RegisterInterestedParty( fTreeViewInterestedParty );
      end;
      fSigDBIndexFileVCLHelper.SigDBFileBase := Value;
      fSigDBIndexFileVCLHelper.PaintBox := PaintBoxDBTree;
      fSigDBIndexFileVCLHelper.BkGround := clWhite;
    end
    else
    begin
      fDataFile := nil;
    end;
    // either way
    BuildDataViewKeyList;
    SigGeneralGridData.Visible := FALSE;
  end;
end;

procedure TFrameSigDBViewer.SetRowBeingEdited(const Value: integer);
begin
  if fRowBeingEdited > 0 then
  begin
    SigGeneralGridData.Cell[ 0, fRowBeingEdited ] := '0';
  end;
  fRowBeingEdited := Value;
  if fRowBeingEdited > 0 then
  begin
    SigGeneralGridData.Cell[ 0, fRowBeingEdited ] := '1';
  end;
end;

procedure TFrameSigDBViewer.ShowIndexFileRawView;
var
  i : integer;
begin
  if assigned( fIndexFile ) then
  begin
    SigGeneralGridRawView.ActiveRowCount := SigSpinEditMaxCount.Value;
    for i := 0 to SigSpinEditMaxCount.Value - 1 do
    begin
      AddRawViewRow( i );
    end;
  end;
end;

procedure TFrameSigDBViewer.SigGeneralGridDataCellEditChange(
  const Sender: TObject; const Col, Row: Integer; const Value: string);
begin
  // the user is changing data in the file.
  // The record number in the physical file is in the CellTag of the Sel column
  // and the field ID is stored in the column headers
end;

procedure TFrameSigDBViewer.SigGeneralGridDataFixedCellClick(Sender: TObject;
  ACol, ARow: Integer);
begin
  if ARow > 0 then
  begin
    RowBeingEdited := ARow;
  end;
end;

procedure TFrameSigDBViewer.SigGeneralGridKeysCellEditChange(
  const Sender: TObject; const Col, Row: Integer; const Value: string);
begin
  if Col = 1 then
  begin
    // must be, but safety first!
    if Row > 1 then
    begin
      //fDataFile.TextToField()
    end;
  end;
end;

procedure TFrameSigDBViewer.SpeedButtonCompleteReindexClick(Sender: TObject);
begin
  if assigned( CurrentIndexFile ) then
  begin
    if assigned( fTreeViewInterestedParty ) then
    begin
      fTreeViewInterestedParty.PauseActive := FALSE;
      fTreeViewInterestedParty.LiveView := FALSE;
    end
    else
    begin
      CurrentIndexFile.Reindex;
    end;
  end;
end;

procedure TFrameSigDBViewer.SpeedButtonLiveViewClick(Sender: TObject);
begin
  StartLiveView;
end;

procedure TFrameSigDBViewer.SpeedButtonReindexNextClick(Sender: TObject);
begin
  if assigned( fTreeViewInterestedParty ) then
  begin
    fTreeViewInterestedParty.PauseReleased := TRUE;
  end;
end;

procedure TFrameSigDBViewer.SpeedButtonShowNowClick(Sender: TObject);
begin
  ShowIndexFileRawView;
end;

procedure TFrameSigDBViewer.SpeedButtonStartReindexClick(Sender: TObject);
begin
  if assigned( CurrentIndexFile ) then
  begin
    if not assigned( fTreeViewInterestedParty ) then
    begin
      fTreeViewInterestedParty := TTreeViewInterestedParty.Create;
      CurrentIndexFile.RegisterInterestedParty( fTreeViewInterestedParty );
    end;
    fTreeViewInterestedParty.PauseActive := TRUE;
    fTreeViewInterestedParty.LiveView := FALSE;
    CurrentIndexFile.Reindex;
  end;

end;

{ TTreeViewInterestedParty }

procedure TTreeViewInterestedParty.AfterRecAppend(Sender: TObject;
  const pRec: tSigDBRecPointer);
begin
  inherited;
  while PauseActive and not PauseReleased do
  begin
    Application.ProcessMessages;
  end;
  if not LiveView then
  begin
    PauseReleased := FALSE;
  end;
  fSigDBIndexFileVCLHelper.VisibleRoot :=  IndexFile.Root;
end;

{ TRawDataInterestedParty }

constructor TRawDataInterestedParty.Create(const pFrame: TFrameSigDBViewer);
begin
  inherited Create;

  fFrame := pFrame;
end;

procedure TRawDataInterestedParty.OnAction(Sender: TObject;
  const pRec: tSigDBRecPointer);
begin
  inherited;
  // must be careful not to enter a fatal embrace situation here, plus
  // VCL is not threadsafe, so
  PostMessage( Frame.WindowHandle, WM_RAW_DATA_UPDATE, 0, pRec );
end;

end.
