unit UnitBinaryTree;

{
  This unit forms the basis for a basic binary tree structure.
  Actual trees are descended in separate units
}

interface

type
  tBinaryTreeElement = class
  protected
    function fGetText : string; virtual; abstract;
    procedure fSetText( NewVal : string ); virtual; abstract;
  public
    property Text : string
             read fGetText
             write fSetText;
  end;

  tBinaryTree = class
  protected
    iRoot : tBinaryTreeElement;
    function fGetText : string; virtual;
    procedure fSetText( NewVal : string ); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    property Root : tBinaryTreeElement
             read iRoot
             write iRoot;
    property Text : string
             read fGetText
             write fSetText;
  end;

  tBinaryTreeLeaf = class( tBinaryTreeElement )
  protected
    // descendants will have properties, but the base does not
  public
  end;

  tBinaryTreeUnaryElement = class( tBinaryTreeElement )
  protected
    iLeft : tBinaryTreeElement;
  public
    property Left : tBinaryTreeElement
             read iLeft
             write iLeft;
    constructor Create;
    destructor Destroy; override;
  end;

  tBinaryTreeBinaryElement = class( tBinaryTreeUnaryElement )
  protected
    iRight : tBinaryTreeElement;
  public
    property Right : tBinaryTreeElement
             read iRight
             write iRight;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

//-------------------- tBinaryTree ---------------------

constructor tBinaryTree.Create;
begin
  inherited Create;
  iRoot := nil;
end;

destructor tBinaryTree.Destroy;
begin
  iRoot.Free;
  inherited Destroy;
end;

function tBinaryTree.fGetText : string;
begin
  if assigned( iRoot ) then Result := iRoot.Text
  else Result := '';
end;

  //----------------- tBinaryTreeUnaryElement -------------

constructor tBinaryTreeUnaryElement.Create;
begin
  inherited Create;
  iLeft := nil;
end;

destructor tBinaryTreeUnaryElement.Destroy;
begin
  iLeft.Free;
  inherited Destroy;
end;

//--------------------- tBinaryTreeBinaryElement -----------

constructor tBinaryTreeBinaryElement.Create;
begin
  inherited Create;
  iRight := nil;
end;

destructor tBinaryTreeBinaryElement.Destroy;
begin
  iRight.Free;
  inherited Destroy;
end;

end.
