unit UnitFrameNodes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameErrorList,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, SigGeneralGrid, SigVariableEditorList,
  Vcl.ComCtrls, Vcl.ExtCtrls, SigImage, Vcl.ImgList;

type
  TFrameNodes = class(TFrame)
    Panel17: TPanel;
    Panel18: TPanel;
    PanelCaption: TPanel;
    Panel43: TPanel;
    PageControlProperties: TPageControl;
    TabSheetProperties: TTabSheet;
    SigVariableEditorList: TSigVariableEditorList;
    Panel44: TPanel;
    SigGeneralGridGlobal: TSigGeneralGrid;
    PanelTools: TPanel;
    BitBtnBlockAdd: TBitBtn;
    BitBtnDeleteSelected: TBitBtn;
    FrameErrorList: TFrameErrorList;
    Panel1: TPanel;
    SigGeneralGrid1: TSigGeneralGrid;
    Panel2: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    FrameErrorList1: TFrameErrorList;
    tSigGridEditorNames: tSigGridEditor;
    tSigGridEditorSelected: tSigGridEditor;
    tSigGridEditorID: tSigGridEditor;
    ImageListSelected: TImageList;
    ImageListNodes: TImageList;
    Panel3: TPanel;
    SigImageNodeType: TSigImage;
    Label1: TLabel;
    ComboBoxNodeType: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
