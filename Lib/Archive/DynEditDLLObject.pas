unit DynEditDLLObject;

interface

uses
  DynEditObject;

type TDynEditDLLObject = class( TDynEditObject )
  private
    DynEditDLL : TDynEditDLL;
    ObjectTypeIndex : integer;
    DLLObject : TDynEditObject;
  public
    constructor Create( pMyParent : TDynEditObject;
                        pDynEditDLL : TDynEditDLL;
                        index : integer );
end;

implementation

constructor TDynEditDLLObject.Create( pMyParent : TDynEditObject;
                        pDynEditDLL : TDynEditDLL;
                        index : integer );
begin
  inherited Create( pMyParent );
  DynEditDLL := pDynEditDLL;
  DLLObject := DynEditDLL.CreateObjectByIndex( index );
end;

end.
