unit UnitFix64;

interface

const
  FracMax = 1024;

type
  Fix64 = record
  private
    fIntBit : integer;
    fFracBit : integer;
    fFracMax : integer;
    procedure SetIntBit(const Value: integer);
    procedure SetFracBit(const Value: integer);
  public
    class operator Add( A, B : Fix64 ) : Fix64;
    procedure Normalise;
    property IntBit : integer
             read fIntBit
             write SetIntBit;
    property FracBit : integer
             read fFracBit
             write SetFracBit;
  end;


implementation

procedure Test;
var
  X, Y : Fix64;
begin
  X.IntBit := 10;
  X.FracBit := 1000;
  Y := X+X;
end;

procedure Fix64.Normalise;
begin
  while fFracBit > fFracMax do
  begin
    inc( fIntBit );
    dec( fFracBit, fFracMax );
  end;
end;

procedure Fix64.SetFracBit(const Value: integer);
begin
  fFracBit := Value;
  Normalise;
end;

procedure Fix64.SetIntBit(const Value: integer);
begin
  fIntBit := Value;
  Normalise;
end;

class operator Fix64.Add( A, B : Fix64 ) : Fix64;
begin
  Result.fIntBit := A.fIntBit + B.fIntBit;
  Result.fFracBit := A.fFracBit + B.fFracBit;
  Result.Normalise;

end;

end.
