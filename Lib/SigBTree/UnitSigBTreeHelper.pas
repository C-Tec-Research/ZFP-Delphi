unit UnitSigBTreeHelper;

interface

uses
  SigBTree;

type TSigBTreeHelper = class
  private
    fSigBTreeRoot: TSigDBTreeRoot;
  protected
    procedure SetSigBTreeRoot(const Value: TSigDBTreeRoot); virtual;
  public
    property SigBTreeRoot : TSigDBTreeRoot
             read fSigBTreeRoot
             write SetSigBTreeRoot;
end;

implementation

{ TSigBTreeHelper }


{ TSigBTreeHelper }

procedure TSigBTreeHelper.SetSigBTreeRoot(const Value: TSigDBTreeRoot);
begin
  fSigBTreeRoot := Value;
end;

{ TSigBTreeHelper }


end.
