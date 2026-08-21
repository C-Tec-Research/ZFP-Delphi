unit UnitTreeViewHelper;

{
  Helper for TTreeView
}

interface

uses
  VCL.ComCtrls;

type
  TTreeViewHelper = class helper for TTreeNode
  private
    function GetCommonImage: integer;
    procedure SetCommonImage(const Value: integer);
  public
    property CommonImage : integer
      read GetCommonImage
      write SetCommonImage;
  end;

implementation

{ TTreeViewHelper }

function TTreeViewHelper.GetCommonImage: integer;
begin
  Result := self.ImageIndex;
end;

procedure TTreeViewHelper.SetCommonImage(const Value: integer);
begin
  self.ImageIndex := Value;
  self.SelectedIndex := Value;
end;

end.
