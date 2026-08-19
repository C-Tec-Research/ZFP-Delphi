unit UnitFrameSupergroupEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameGlobalObjectEditor,
  Vcl.ImgList, SigGeneralGrid, SigVariableEditorList, Vcl.ComCtrls, Vcl.Grids,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, UnitFrameErrorList, Vcl.Menus,
  System.ImageList;

type
  TFrameSupergroupEditor = class(TFrameGlobalObjectEditor)
    TabSheetComponentGroups: TTabSheet;
    PanelSuperGroupsGroups: TPanel;
    Panel57: TPanel;
    BitBtnAddAllGroups: TBitBtn;
    BitBtnClearAllGroups: TBitBtn;
    SigGeneralGridSuperGroupGroups: TSigGeneralGrid;
    Panel56: TPanel;
    Panel58: TPanel;
    BitBtnAddAllSuperGroups: TBitBtn;
    BitBtnClearAllSuperGroups: TBitBtn;
    SigGeneralGridSuperGroupSuperGroups: TSigGeneralGrid;
    tSigGridEditorSGSGDescrition: tSigGridEditor;
    tSigGridEditorSGSGPresent: tSigGridEditor;
    tSigGridEditorSGGPresent: tSigGridEditor;
    tSigGridEditorSGGDescription: tSigGridEditor;
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrameSupergroupEditor: TFrameSupergroupEditor;

implementation

{$R *.dfm}

procedure TFrameSupergroupEditor.FrameResize(Sender: TObject);
begin
  inherited;
  PanelSuperGroupsGroups.Width := self.PageControlProperties.ClientWidth div 2;
end;

end.
