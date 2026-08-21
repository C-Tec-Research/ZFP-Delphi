unit SigObjectStack;

interface

uses
  contnrs;

type
  tSigObjectStack = class( tObjectStack )
  private
    fObjectClass: tClass;
  public
    constructor Create( pObjectClass : tClass  );
    destructor Destroy; override;
    procedure Push( NewVal : fObjectClass ); reintroduce;
    function Pop : fObjectClass; reintroduce;
    function Peek : fObjectClass; reintroduce;
    procedure Clear;
    property ObjectClass : tClass
             read fObjectClass;
  end;

implementation

{ tSigObjectStack }

procedure tSigObjectStack.Clear;
var
  iObject : fObjectClass;
begin
  while Count > 0 do
  begin
    iObject := Pop;
    iObject.Free;
  end;
end;

constructor tSigObjectStack.Create(pObjectClass: tClass);
begin
  inherited Create;
  fObjectClass := pObjectClass;
end;

destructor tSigObjectStack.Destroy;
begin

  inherited;
end;

function tSigObjectStack.Peek: fObjectClass;
begin

end;

function tSigObjectStack.Pop: fObjectClass;
begin

end;

procedure tSigObjectStack.Push(NewVal: fObjectClass);
begin

end;

end.
