unit UnitFileVer;

interface

uses
  System.SysUtils;

type
TSigFileVer = record
  private
  public
    Major : word;
    Minor : word;
    //class operator implicit( a : TSigFileVer ) : TSigFileVer;
    class operator implicit( a : TSigFileVer ) : string;
    class operator implicit( a : string ) : TSigFileVer;
    class operator Add( a, b : TSigFileVer ) : TSigFileVer;
    class operator Add( a : TSigFileVer; b : string ) : TSigFileVer;
    class operator Equal( a, b : TSigFileVer ) : boolean;
    class operator NotEqual( a, b : TSigFileVer ) : boolean;
    class operator GreaterThan( a, b : TSigFileVer ) : boolean;
    class operator GreaterThanOrEqual( a, b : TSigFileVer ) : boolean;
    class operator LessThan( a, b : TSigFileVer ) : boolean;
    class operator LessThanOrEqual( a, b : TSigFileVer ) : boolean;
end;

implementation

{ TSigFileVer }

class operator TSigFileVer.Add(a, b: TSigFileVer): TSigFileVer;
begin
  Result.Major := a.Major + b.Major;
end;

class operator TSigFileVer.Add(a: TSigFileVer; b: string): TSigFileVer;
begin
  Result := b;
  Result := Result + a;
end;

class operator TSigFileVer.Equal(a, b: TSigFileVer): boolean;
begin
  Result := (a.Major = b.Major) and (a.Minor = b.Minor);
end;

class operator TSigFileVer.GreaterThan(a, b: TSigFileVer): boolean;
begin
  if a.Major > b.Major then Result := TRUE
  else if a.Major = b.Major then Result := (a.Minor > b.Minor)
  else Result := FALSE;
end;

class operator TSigFileVer.GreaterThanOrEqual(a, b: TSigFileVer): boolean;
begin
  if a.Major > b.Major then Result := TRUE
  else if a.Major = b.Major then Result := (a.Minor >= b.Minor)
  else Result := FALSE;
end;

class operator TSigFileVer.implicit(a: TSigFileVer): string;
begin
  if (a.Major = 0) and (a.Minor = 0) then Result := ''
  else  Result := IntToStr(a.Major) + '.' + IntToStr(a.Minor);
end;

class operator TSigFileVer.implicit(a: string): TSigFileVer;
var
  iPos : integer;
  iLeft, iRight : string;
begin
  if Trim(a) = '' then
  begin
    Result.Major := 0;
    Result.Minor := 0;
    exit;
  end;
  // else
  iPos := Pos( '.', a );
  if iPos = 0 then
  begin
    Result.Major := StrToInt( a );
    Result.Minor := 0;
  end
  else
  begin
    iLeft := Copy( a, 1, iPos - 1 );
    iRight := Copy( a, iPos + 1 );
    if iLeft = '' then
    begin
      Result.Major := 0;
    end
    else
    begin
      Result.Major := StrToInt( iLeft );
    end;
    if iRight = '' then
    begin
      Result.Minor := 0;
    end
    else
    begin
      Result.Minor := StrToInt( iRight );
    end;
  end;
end;

class operator TSigFileVer.LessThan(a, b: TSigFileVer): boolean;
begin
  Result := b > a;
end;

class operator TSigFileVer.LessThanOrEqual(a, b: TSigFileVer): boolean;
begin
  Result := b >= a;
end;

class operator TSigFileVer.NotEqual(a, b: TSigFileVer): boolean;
begin
  Result := not ( a = b );
end;

end.
