unit UnitTreeViewHelper;

interface

uses
  VCL.ComCtrls,
  UnitFiles,
  SigFile;

type
  TDBTreeViewActiveNode = ( an_DB_Overview );
  TDBTreeViewHelper = class
  private
    fTreeView: TTreeView;
    fDatabase : TTreeNode;
    //fFiles : TTreeNode;
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
  iIndexNode : TTreeNode;
begin
  with pForBaseFile.IndexFiles do
  begin
    for i := 0 to Max do
    begin
      iIndexNode := fTreeView.Items.AddChildObject( pToBaseNode, SigDBBIndexFile[ i ].FullName, SigDBBIndexFile[ i ] );
      fTreeView.Items.AddChildObject( iIndexNode, 'Find Functions', SigDBBIndexFile[ i ].FindFunctions );
    end;
  end;
  fTreeView.Items.AddChildObject( pToBaseNode,'<New>', pForBaseFile.IndexFiles );
end;

procedure TDBTreeViewHelper.BuildFiles;
var
  i : integer;
  iFileNode, iIndexesNode : TTreeNode;
begin
  // add one line for each data file
  if assigned( fSigFile ) then
  begin
    with fSigFile.DataBase.Files do
    begin
      for i := 0 to Max do
      begin
        iFileNode := fTreeView.Items.AddChildObject( fDatabase, BaseFile[ i ].BaseFileName.Value, BaseFile[ i ]);
        fTreeView.Items.AddChildObject( iFileNode, 'Fields', BaseFile[ i ].Fields );
        iIndexesNode := fTreeView.Items.AddChildObject( iFileNode, 'Indexes', nil {BaseFile[ i ].IndexFiles} );
        AddIndexFileNodes( iIndexesNode, BaseFile[ i ] );
        fTreeView.Items.AddChildObject( iFileNode, 'Encryption', BaseFile[ i ].Encrypted ); // to do!
      end;
    end;
    fTreeView.Items.AddChildObject( fDatabase,'<New>', fSigFile.DataBase.Files );
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
      //fFiles := fTreeView.Items.AddChild( fDatabase, 'Files' );
      BuildFiles;
      fDatabase.Expand( FALSE );
      //fFiles.Expand( FALSE );
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
  cFile = cDatabase + 1;
  cFields = cFile + 1;
  cIndexFile = cFields + 1;
  cFindFunctions = cIndexFile + 1;
  cEncryption = cFindFunctions + 1;
var
  iObject : TObject;
  iNewFile : TSigDBBBaseFile;
  iIndexesNode : TTreeNode;
  iNewIndexFile : TSigDBBIndexFile;
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
    else
    begin
      iObject := Node.Data;
      if assigned( iObject ) then
      begin
        if iObject is TSigDBBBaseFile then
        begin
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cFile;
          (iObject as TSigDBBBaseFile).MakeMeActive();
        end
        else if iObject is tSigDBBFieldList then
        begin
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cFields;
          (iObject as tSigDBBFieldList).MakeMeActive();
        end
        else if iObject is TSigDBBIndexFile then
        begin
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cIndexFile;
          (iObject as TSigDBBIndexFile).MakeMeActive();
        end
        else if iObject is TSigDBFindFunctions then
        begin
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cFindFunctions;
          (iObject as TSigDBFindFunctions).MakeMeActive();
        end
        else if iObject is TSigBooleanProperty then  // strictly temporary!
        begin
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cEncryption;
          (iObject as TSigBooleanProperty).MakeMeActive();
        end
        else if iObject is TSigDBBaseFileList then
        begin
          with (iObject as TSigDBBaseFileList) do
          begin
            Max := Max + 1;
            iNewFile := BaseFile[ Max ];
          end;
          // we now need to convert node to newly added child
          Node.Text := iNewFile.BaseFileName.Value;
          Node.Data := iNewFile;
          fTreeView.Items.AddChildObject( Node, 'Fields', iNewFile.Fields );
          iIndexesNode := fTreeView.Items.AddChildObject( Node, 'Indexes', iNewFile.IndexFiles );
          AddIndexFileNodes( iIndexesNode, iNewFile ); // probably not required
          fTreeView.Items.AddChildObject( Node, 'Encryption', iNewFile.Encrypted ); // to do!
          Node.Expand( FALSE );
          fTreeView.Items.AddChildObject( fDatabase,'<New>', fSigFile.DataBase.Files );
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cFile;
          iNewFile.MakeMeActive();
        end
        else if iObject is tSigDBBIndexFileList then
        begin
          with iObject as tSigDBBIndexFileList do
          begin
            Max := Max + 1;
            iNewIndexFile := SigDBBIndexFile[ Max ];
          end;
          // now we need to convert node to newly added child
          Node.Text := iNewIndexFile.FullName;
          Node.Data := iNewIndexFile;
          fTreeView.Items.AddChildObject( Node, 'Find Functions', iNewIndexFile.FindFunctions );
          Node.Expand( FALSE );
          fTreeView.Items.AddObject( Node,'<New>', iObject );
          fPageControlProperties.Visible := TRUE;
          fPageControlProperties.ActivePageIndex := cIndexFile;
          iNewIndexFile.MakeMeActive();
        end
        else
        begin
          fPageControlProperties.Visible := FALSE;
        end;
      end
      else
      begin
        fPageControlProperties.Visible := FALSE;
      end;
    end;
  end;
end;

end.
