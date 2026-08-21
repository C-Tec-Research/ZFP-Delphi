unit UnitTreeViewHelper;

interface

uses
  VCL.ComCtrls,
  UnitFiles;

type
  TDBTreeViewActiveNode = ( an_DB_Overview );
  TDBTreeViewHelper = class
  private
    fTreeView: TTreeView;
    fDatabase : TTreeNode;
    fDatabaseDetails : TTreeNode;
    fFiles : TTreeNode;
    fActiveNode: TDBTreeViewActiveNode;
    fSigFile: TSigDBBFile;
    fOnTreeViewChange : TTVChangedEvent;
    fPageControlProperties: TPageControl;
    procedure SetActiveNode(const Value: TDBTreeViewActiveNode);
    procedure SetSigFile(const Value: TSigDBBFile);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure SetTreeView(const Value: TTreeView);
    procedure BuildFiles;
    procedure AddIndexFileNodes( const pToBaseNode : TTreeNode; const pForBaseFile : TSigDBBBaseFile );
    procedure SetPageControlProperties(const Value: TPageControl);
  protected
  public
    property TreeView : TTreeView
             read fTreeView
             write SetTreeView;
    property ActiveNode : TDBTreeViewActiveNode
             read fActiveNode
             write SetActiveNode;
    property SigFile : TSigDBBFile
             read fSigFile
             write SetSigFile;

    property PageControlProperties : TPageControl
             read fPageControlProperties
             write SetPageControlProperties;

    procedure BuildTreeView;
  end;

implementation

{ TDBTreeViewHelper }

procedure TDBTreeViewHelper.AddIndexFileNodes(const pToBaseNode: TTreeNode;
  const pForBaseFile: TSigDBBBaseFile);
var
  i: Integer;
begin
  with pForBaseFile.IndexFiles do
  begin
    for i := 0 to Max do
    begin
      fTreeView.Items.AddChildObject( pToBaseNode, SigDBBIndexFile[ i ].FullName, SigDBBIndexFile[ i ] );
    end;
  end;
  fTreeView.Items.AddChildObject( pToBaseNode,'<New>', pForBaseFile.IndexFiles );
end;

procedure TDBTreeViewHelper.BuildFiles;
var
  i : integer;
  iFileNode : TTreeNode;
begin
  // add one line for each data file
  if assigned( fSigFile ) then
  begin
    with fSigFile.DataBase.Files do
    begin
      for i := 0 to Max do
      begin
        iFileNode := fTreeView.Items.AddChildObject( fFiles, BaseFile[ i ].BaseFileName.Value, BaseFile[ i ]);
        AddIndexFileNodes( iFileNode, BaseFile[ i ] );
      end;
    end;
    fTreeView.Items.AddChildObject( fFiles,'<New>', fSigFile.DataBase.Files );
  end;
end;

procedure TDBTreeViewHelper.BuildTreeView;
begin
  if assigned( fTreeView ) then
  begin
    fTreeView.Items.Clear;
    if assigned( fSigFile ) then
    begin
      fDatabase := fTreeView.Items.AddChild( nil, 'Database' );
      fDatabaseDetails := fTreeView.Items.AddChild( fDatabase, 'Database Details' );
      fFiles := fTreeView.Items.AddChild( fDatabase, 'Files' );
      BuildFiles;
      fDatabase.Expand( FALSE );
      fFiles.Expand( FALSE );
    end;
  end;
end;

procedure TDBTreeViewHelper.SetActiveNode(const Value: TDBTreeViewActiveNode);
begin
  fActiveNode := Value;
end;

procedure TDBTreeViewHelper.SetPageControlProperties(const Value: TPageControl);
var
  i: Integer;
begin
  fPageControlProperties := Value;
  if assigned( fPageControlProperties ) then
  begin
    for i := 0 to fPageControlProperties.PageCount - 1 do
    begin
      fPageControlProperties.Pages[ i ].TabVisible := FALSE;
    end;
  end;
end;

procedure TDBTreeViewHelper.SetSigFile(const Value: TSigDBBFile);
begin
  fSigFile := Value;
  BuildTreeView;
end;

procedure TDBTreeViewHelper.SetTreeView(const Value: TTreeView);
begin
  if assigned( fTreeView ) then
  begin
    fTreeView.OnChange := fOnTreeViewChange;
  end;
  fTreeView := Value;
  if assigned( fTreeView ) then
  begin
    fOnTreeViewChange := fTreeView.OnChange;
    fTreeView.OnChange := TreeViewChange;
  end;
end;

procedure TDBTreeViewHelper.TreeViewChange(Sender: TObject; Node: TTreeNode);
const
  cDatabase = 0;
  cDatabaseDetails = cDatabase { + 1};
begin
  if assigned( fOnTreeViewChange ) then
  begin
    fOnTreeViewChange( Sender, Node );
  end;
  if assigned( fPageControlProperties ) then
  begin
    if Node = fDatabase then
    begin
      fPageControlProperties.Visible := TRUE;
      fPageControlProperties.ActivePageIndex := cDatabase;
    end
    else if Node = fDatabaseDetails then
    begin
      fPageControlProperties.Visible := TRUE;
      fPageControlProperties.ActivePageIndex := cDatabaseDetails;
    end
    else
    begin
      fPageControlProperties.Visible := FALSE;
    end;
  end;
end;

end.
