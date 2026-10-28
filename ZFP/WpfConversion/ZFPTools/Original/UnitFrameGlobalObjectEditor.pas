unit UnitFrameGlobalObjectEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, SigVariableEditorList,
  Vcl.Grids, SigGeneralGrid, Vcl.ExtCtrls,
  Vcl.ImgList, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Buttons, UnitFrameErrorList, Vcl.Menus,
  UnitConfirmTreeDelete,
  SigFile, System.ImageList;

type
  TFrameGlobalObjectEditor = class(TFrame)
    Panel17: TPanel;
    SigGeneralGridGlobalPanelList: TSigGeneralGrid;
    Panel18: TPanel;
    PanelCaption: TPanel;
    Panel43: TPanel;
    Panel44: TPanel;
    SigGeneralGridGlobal: TSigGeneralGrid;
    SigGridEditorNames: tSigGridEditor;
    tSigGridEditorID: tSigGridEditor;
    ImageListBlankTick: TImageList;
    tSigGridEditorPanelUses: tSigGridEditor;
    tSigGridEditorPanelNo: tSigGridEditor;
    tSigGridEditorSequencesPanelName: tSigGridEditor;
    PageControlProperties: TPageControl;
    TabSheetProperties: TTabSheet;
    SigVariableEditorList: TSigVariableEditorList;
    PanelTools: TPanel;
    ImageListSelected: TImageList;
    SigGridEditorSelected: tSigGridEditor;
    BitBtnBlockAdd: TBitBtn;
    BitBtnDeleteSelected: TBitBtn;
    TabSheetWhereUsed: TTabSheet;
    Panel1: TPanel;
    TreeViewWhereUsed: TTreeView;
    FrameErrorList: TFrameErrorList;
    Label1: TLabel;
    PopupMenuWhereUsed: TPopupMenu;
    GotoCETree1: TMenuItem;
    N1: TMenuItem;
    FindFirst1: TMenuItem;
    FindNext1: TMenuItem;
    Delete1: TMenuItem;
    procedure GotoCETree1Click(Sender: TObject);
    procedure PopupMenuWhereUsedPopup(Sender: TObject);
    procedure FindFirst1Click(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure TreeViewWhereUsedChange(Sender: TObject; Node: TTreeNode);
  private
    fSearchObject: pointer;
    fLastIndex : integer;
    fDontAskAgain : boolean;
    fPruneParents : boolean;
    function GetWhereUsedImageList: tImageList;
    procedure SetGetWhereUsedImageList(const Value: tImageList);
    procedure SetSearchObject(const Value: pointer);
    { Private declarations }
  public
    { Public declarations }
    procedure AfterConstruction; override;

    procedure Setup; virtual;

    property WhereUsedImageList : tImageList
             read GetWhereUsedImageList
             write SetGetWhereUsedImageList;

    property SearchObject : pointer
             read fSearchObject
             write SetSearchObject;
  end;

implementation

uses
  UnitMain,
  UnitFiles;

{$R *.dfm}

{ TFrameGlobalObjectEditor }

{ TFrameGlobalObjectEditor }

procedure TFrameGlobalObjectEditor.AfterConstruction;
begin
  // override the tab
  PageControlProperties.TabIndex := 0;
  inherited;
end;

procedure TFrameGlobalObjectEditor.Delete1Click(Sender: TObject);
var
  iNode, iNode1 : TTreeNode;
  iCETreeProperty : TCETreeProperty;
  iOwner : TSigCompoundProperty;
  iOwnerNode, iToDelete : TCETreeProperty;
begin
  // Goto corresponding element in main tree
  iNode := TreeViewWhereUsed.Selected;
  if assigned( iNode ) then
  begin
    iNode1 := TTreeNode( iNode.Data );
    iCETreeProperty := tCETreeProperty( iNode1.Data );
    if iCETreeProperty.UsesGlobalObject( TZFPGlobalObject(fSearchObject) ) then
    begin
      if not fDontAskAgain then
      begin
        if not FormConfirmCETreeDelete.Execute( fPruneParents, fDontAskAgain ) then
        begin
          exit; // cancel pressed!
        end;
      end;
      iToDelete := iCETreeProperty;
      // if pruning to a valid tree we need to move up the tree if we have siblings
      if fPruneParents then
      begin
        iOwner := iCETreeProperty.Owner;
        if iOwner is TCETreeProperty then
        begin
          iOwnerNode := iOwner as TCETreeProperty;
        end
        else
        begin
          iOwnerNode := nil;
        end;
        while assigned( iOwnerNode ) do
        begin
          if iOwnerNode.TreeChildrenCount = 1 then
          begin
            // would give illegal form - prune parents
            iToDelete := iOwnerNode;
            iOwner := iOwnerNode.Owner;
            if iOwner is TCETreeProperty then
            begin
              iOwnerNode := iOwner as TCETreeProperty;
              iNode := iNode.Parent;
            end
            else
            begin
              iOwnerNode := nil;
            end;
          end
          else
          begin
            // Valid Form - stop here
            break;
          end;
        end;
        if not assigned( iOwnerNode ) then
        begin
          // we are in trouble
          fDontAskagain := FALSE;
          raise Exception.Create(FormMain.Translate('Deletion would lead to removal of whole tree. Deletion aborted'));
        end;
      end;
      fLastIndex := iNode.AbsoluteIndex - 1;
      TreeViewWhereUsed.Items.Delete( iNode );
      // and remove from main tree
      iToDelete.ZFPFile.UndoRedo.GroupUndoActive := TRUE;
      try
        iToDelete.Owner.Remove( iToDelete, undoDelete2 );
      finally
        iToDelete.ZFPFile.UndoRedo.GroupUndoActive := FALSE;
      end;
    end;
  end;
end;

procedure TFrameGlobalObjectEditor.FindFirst1Click(Sender: TObject);
begin
  fLastIndex := -1;
  FindNext1Click( Sender );
end;

procedure TFrameGlobalObjectEditor.FindNext1Click(Sender: TObject);
var
  i: Integer;
  iNode,
  iNode1 : TTreeNode;
  iCETreeProperty : tCETreeProperty;
begin
  for i := fLastIndex + 1 to TreeViewWhereUsed.Items.Count - 1 do
  begin
    iNode := TreeViewWhereUsed.Items[ i ];
    iNode1 := TTreeNode( iNode.Data );
    iCETreeProperty := tCETreeProperty( iNode1.Data );
    if iCETreeProperty.UsesGlobalObject( TZFPGlobalObject(fSearchObject) ) then
    begin
      iNode.Selected := TRUE;
      //iNode.MakeVisible;
      fLastIndex := i;
      exit;
    end;
  end;
  // loop round
  for i := 0 to fLastIndex -1 do
  begin
    iNode := TreeViewWhereUsed.Items[ i ];
    iNode1 := TTreeNode( iNode.Data );
    iCETreeProperty := tCETreeProperty( iNode1.Data );
    if iCETreeProperty.UsesGlobalObject( TZFPGlobalObject(fSearchObject) ) then
    begin
      iNode.Selected := TRUE;
      //iNode.MakeVisible;
      fLastIndex := i;
      exit;
    end;
  end;
end;

function TFrameGlobalObjectEditor.GetWhereUsedImageList: tImageList;
begin
  Result := TreeViewWhereUsed.Images as tImageList;
end;

procedure TFrameGlobalObjectEditor.GotoCETree1Click(Sender: TObject);
var
  iNode, iNode1 : TTreeNode;
begin
  // Goto corresponding element in main tree
  iNode := TreeViewWhereUsed.Selected;
  if assigned( iNode ) then
  begin
    iNode1 := TTreeNode( iNode.Data );
    with unitMain.FormMain do
    begin
      PageControlMain.ActivePage := TabSheetCauseAndEffects;
      iNode1.Selected := TRUE;
    end;
  end;
end;

procedure TFrameGlobalObjectEditor.PopupMenuWhereUsedPopup(Sender: TObject);
var
  iNode, iNode1 : TTreeNode;
  iCETreeProperty : tCETreeProperty;
begin
  // when menu pops up...
  if assigned( fSearchObject ) then
  begin
    FindFirst1.Enabled := TRUE;
    FindNext1.Enabled := TRUE;
    iNode := TreeViewWhereUsed.Selected;
    if assigned( iNode ) then
    begin
      iNode1 := TTreeNode( iNode.Data );
      // iNode1.Data is of type tCETreeProperty
      iCETreeProperty := tCETreeProperty( iNode1.Data );
      Delete1.Enabled := iCETreeProperty.UsesGlobalObject( TZFPGlobalObject(fSearchObject) );
    end
    else
    begin
      Delete1.Enabled := FALSE;
    end;
  end
  else
  begin
    FindFirst1.Enabled := FALSE;
    FindNext1.Enabled := FALSE;
    Delete1.Enabled := FALSE;
  end;
end;

procedure TFrameGlobalObjectEditor.SetGetWhereUsedImageList(
  const Value: tImageList);
begin
  TreeViewWhereUsed.Images := Value;
end;

procedure TFrameGlobalObjectEditor.SetSearchObject(const Value: pointer);
begin
  fSearchObject := Value;
  fLastIndex := -1;
end;

procedure TFrameGlobalObjectEditor.Setup;
begin
  //
end;

procedure TFrameGlobalObjectEditor.TreeViewWhereUsedChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned( TreeViewWhereUsed.Selected ) then
  begin
    fLastIndex := TreeViewWhereUsed.Selected.AbsoluteIndex;
  end;
end;

end.
