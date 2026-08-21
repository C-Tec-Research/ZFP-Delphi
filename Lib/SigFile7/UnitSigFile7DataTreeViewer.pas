unit UnitSigFile7DataTreeViewer;

{
  SigFile7 Data Viewer
}

interface

uses
  System.SysUtils,
  FMX.TreeView,
  SigFile7;

type
  TSigFile7DataHelper = class helper for TSigFile7BaseData
  private
  public
    function AddNode( const pTreeView : TTreeView; const pToNode : TTreeViewItem = nil;
             const pIndex : integer = 0 ) : TTreeViewItem;
    function NodeText( const pIndex : integer ) : string;
    function IndexedName( const pIndex : integer ) : string;
  end;


implementation

{ TSigFile7DataHelper }


function TSigFile7DataHelper.IndexedName( const pIndex : integer ): string;
begin
  if Self.fIsItem then
  begin
    Result := Name + '(' + IntToStr( pIndex ) + ')'
  end
  else
  begin
    Result := Name;
  end;
end;

function TSigFile7DataHelper.NodeText( const pIndex : integer ): string;
var
  i : integer;
  iText : string;
  iCanSaveChildren : boolean;
begin
  iText := Text;
  iCanSaveChildren := CanSaveChildren;
  if (Items.Count = 0) and (not iCanSaveChildren) then
  begin
    if iText = '' then
    begin
      Result := cVALUE + ' ' + IndexedName( pIndex );
    end
    else
    begin
      Result := cVALUE + ' ' + IndexedName( pIndex ) + ' = ' + iText;
    end;
  end
  else
  begin
    if iText = '' then
    begin
      Result := cBEGIN + ' ' + IndexedName( pIndex ) ;
    end
    else
    begin
      Result := cBEGIN + ' ' + IndexedName( pIndex ) + ' = ' + iText;
    end;
  end;
end;

{ TSigFile7DataHelper }

function TSigFile7DataHelper.AddNode(const pTreeView: TTreeView;
  const pToNode: TTreeViewItem;
  const pIndex : integer): TTreeViewItem;
var
  i: Integer;
  iLabel : string;
begin
  Result := TTreeViewItem.Create( pTreeView );
  Result.Text := NodeText( pIndex );
  if assigned( pToNode ) then
  begin
    pToNode.AddObject( Result );
  end
  else
  begin
    pTreeView.AddObject( Result );
  end;
  for i := 0 to self.Items.Count - 1 do
  begin
    self.Items[ i ].AddNode( pTreeView, Result, i );
  end;
  for i := 0 to Children.Count - 1 do
  begin
    self.Children[ i ].AddNode( pTreeView, Result, -i );
  end;

end;

end.
