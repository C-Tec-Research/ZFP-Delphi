unit UnitFrameSeqEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameGlobalObjectEditor,
  Vcl.ImgList, SigGeneralGrid, SigVariableEditorList, Vcl.ComCtrls, Vcl.Grids,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, UnitFrameErrorList, Vcl.Menus,
  System.ImageList;

type
  TFrameSequenceEditor = class(TFrameGlobalObjectEditor)
    TabSheetSequences: TTabSheet;
    Panel70: TPanel;
    SigGeneralGridSequenceSteps: TSigGeneralGrid;
    SigGridEditorSequenceID: tSigGridEditor;
    SigGridEditorSeqPredelay: tSigGridEditor;
    SigGridEditorSeqAction: tSigGridEditor;
    SigGridEditorPulsePattern: tSigGridEditor;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrameSequenceEditor: TFrameSequenceEditor;

implementation

{$R *.dfm}

end.
