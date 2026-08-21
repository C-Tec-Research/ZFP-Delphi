unit UnitSigDBFileStructure;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls,
  SigPanel,
  SigDBRawDB, SigGeneralGrid, Vcl.Grids,
  Vcl.Samples.Spin, SigSpinEdit,
  Vcl.Buttons, Vcl.StdCtrls;

type
  TOnGetDataText = function( const pRecNo : tSigDBRecPointer ) : string of Object;

  TFrameSigDBFileStructure = class(TFrame)
    SigPanel1: TSigPanel;
    SigPanelTop: TSigPanel;
    SigPanel3: TSigPanel;
    SigGeneralGridIndexFile: TSigGeneralGrid;
    SigGridEditorRecNo: TSigGridEditor;
    SigGridEditorNext: TSigGridEditor;
    SigGridEditorPrev: TSigGridEditor;
    SigGridEditorData: TSigGridEditor;
    SigGridEditorLeftChild: TSigGridEditor;
    SigGridEditorRightChild: TSigGridEditor;
    SigGridEditorTreeDepth: TSigGridEditor;
    SigPanelOptions: TSigPanel;
    SigPanel5: TSigPanel;
    Label1: TLabel;
    Label2: TLabel;
    EditLastIns: TEdit;
    EditLastDel: TEdit;
    SpeedButtonShowNow: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    SigSpinEditFromRec: TSigSpinEdit;
    SigSpinEditMaxCount: TSigSpinEdit;
    Label5: TLabel;
    EditRecCount: TEdit;
    SpeedButtonReindex: TSpeedButton;
    SigGridEditorDataVal: TSigGridEditor;
    procedure FrameResize(Sender: TObject);
    procedure SpeedButtonShowNowClick(Sender: TObject);
    procedure SpeedButtonReindexClick(Sender: TObject);
  private
    fSigDBIndexFile: tSigDBIndexFile;
    fOnGetDataText: TOnGetDataText;
    procedure SetOnGetDataText(const Value: TOnGetDataText);
    { Private declarations }
  public
    { Public declarations }
    property SigDBIndexFile : tSigDBIndexFile
             read fSigDBIndexFile
             write fSigDBIndexFile;
    procedure ShowRecs;
  published
    property OnGetDataText : TOnGetDataText
             read fOnGetDataText
             write SetOnGetDataText;
  end;

implementation

{$R *.dfm}

procedure TFrameSigDBFileStructure.FrameResize(Sender: TObject);
begin
  SigPanelOptions.Width := SigPanelTop.ClientWidth div 2;
  if csDesigning in ComponentState then
  begin
    SigGeneralGridIndexFile.ColCount := 8;
  end
  else if assigned( fOnGetDataText ) then
  begin
    SigGeneralGridIndexFile.ColCount := 8
  end
  else
  begin
    SigGeneralGridIndexFile.ColCount := 7
  end;
end;

procedure TFrameSigDBFileStructure.SetOnGetDataText(
  const Value: TOnGetDataText);
begin
  fOnGetDataText := Value;
  if assigned( fOnGetDataText ) then
  begin
    SigGeneralGridIndexFile.ColCount := 8
  end
  else
  begin
    SigGeneralGridIndexFile.ColCount := 7
  end;
end;

procedure TFrameSigDBFileStructure.ShowRecs;
var
  i, iRecNo, iRecCount : integer;
const
  cRecNo = 0;
  cNext = cRecNo + 1;
  cPrev = cNext + 1;
  cDataRec  = cPrev + 1;
  cLeftChild = cDataRec + 1;
  cRightChild = cLeftChild + 1;
  cTreeDepth = cRightChild + 1;
  cData = cTreeDepth + 1;
begin
  if assigned( SigDBIndexFile ) then
  begin
    EditRecCount.Text := IntToStr( SigDBIndexFile.RecCount );
    EditLastIns.Text := IntToStr( SigDBIndexFile.LastInserted );
    EditLastDel.Text := IntToStr( SigDBIndexFile.LastDeleted );
    iRecCount := SigDBIndexFile.RecCount - SigSpinEditFromRec.Value + 1;
    if iRecCount > SigSpinEditMaxCount.Value then
    begin
      iRecCount := SigSpinEditMaxCount.Value;
    end;
    if iRecCount < 1 then
    begin
      SigGeneralGridIndexFile.Visible := FALSE;
    end
    else
    begin
      SigGeneralGridIndexFile.RowCount := iRecCount;
      for i := 1 to iRecCount - 1 do
      begin
        iRecNo := i + SigSpinEditFromRec.Value  - 1;
        SigGeneralGridIndexFile.Cell[ cRecNo, i ] := IntToStr( iRecNo );
        SigDBIndexFile.Read( iRecNo );
        SigGeneralGridIndexFile.Cell[ cNext, i ] := IntToStr( SigDBIndexFile.NextRec );
        SigGeneralGridIndexFile.Cell[ cPrev, i ] := IntToStr( SigDBIndexFile.PrevRec );
        SigGeneralGridIndexFile.Cell[ cDataRec, i ] := IntToStr( SigDBIndexFile.DataRec );
        SigGeneralGridIndexFile.Cell[ cLeftChild, i ] := IntToStr( SigDBIndexFile.LeftChild );
        SigGeneralGridIndexFile.Cell[ cRightChild, i ] := IntToStr( SigDBIndexFile.RightChild );
        SigGeneralGridIndexFile.Cell[ cTreeDepth, i ] := IntToStr( SigDBIndexFile.TreeDepth );
        if assigned( fOnGetDataText ) then
        begin
          SigGeneralGridIndexFile.Cell[ cData, i ] := fOnGetDataText( SigDBIndexFile.DataRec );
        end;
      end;
      SigGeneralGridIndexFile.Visible := TRUE;
    end;
  end;
end;

procedure TFrameSigDBFileStructure.SpeedButtonReindexClick(Sender: TObject);
begin
  SigDBIndexFile.Reindex;
  ShowRecs;
end;

procedure TFrameSigDBFileStructure.SpeedButtonShowNowClick(Sender: TObject);
begin
  ShowRecs;
end;

end.
