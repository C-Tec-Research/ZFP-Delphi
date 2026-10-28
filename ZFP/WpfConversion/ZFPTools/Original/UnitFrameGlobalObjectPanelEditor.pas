unit UnitFrameGlobalObjectPanelEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  UnitFiles, Vcl.Buttons, Vcl.Grids, SigGeneralGrid, SigVariableEditorList,
  Vcl.ExtCtrls;

type
  TFrameGlobalObjectPanelEditor = class(TFrame)
    Panel17: TPanel;
    Panel18: TPanel;
    Panel42: TPanel;
    Panel43: TPanel;
    SigVariableEditorList: TSigVariableEditorList;
    Panel44: TPanel;
    SigGeneralGridUsage: TSigGeneralGrid;
    Panel1: TPanel;
    SpeedButtonShowHide: TSpeedButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
