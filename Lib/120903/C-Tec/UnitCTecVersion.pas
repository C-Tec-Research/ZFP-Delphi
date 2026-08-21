unit UnitCTecVersion;

interface

uses
  SysUtils;

type
  tCTecVersion = record
  private
    fMajor : integer;
    fSeparator : char;
    fMinor : integer;
  public
    property Major : integer
             read fMajor
             write fMajor;
    property Separator : char
             read fSeparator
             write fSeparator;
    property Minor : integer
             read fMinor
             write fMinor;

    class operator implicit( a : tCTecVersion ) : string;
    class operator implicit( a : string ) : tCTecVersion;
    class operator LessThan( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator LessThan( a : tCTecVersion; b : string ) : boolean;
    class operator LessThan( a : string; b : tCTecVersion ) : boolean;
    class operator Equal( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator Equal( a : tCTecVersion; b : string ) : boolean;
    class operator Equal( a : string; b : tCTecVersion ) : boolean;
    class operator LessThanOrEqual( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator LessThanOrEqual( a : tCTecVersion; b : string ) : boolean;
    class operator LessThanOrEqual( a : string; b : tCTecVersion ) : boolean;
    class operator GreaterThan( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator GreaterThan( a : tCTecVersion; b : string ) : boolean;
    class operator GreaterThan( a : string; b : tCTecVersion ) : boolean;
    class operator GreaterThanOrEqual( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator GreaterThanOrEqual( a : tCTecVersion; b : string ) : boolean;
    class operator GreaterThanOrEqual( a : string; b : tCTecVersion ) : boolean;
    class operator NotEqual( a : tCTecVersion; b : tCTecVersion ) : boolean;
    class operator NotEqual( a : tCTecVersion; b : string ) : boolean;
    class operator NotEqual( a : string; b : tCTecVersion ) : boolean;
  end;

implementation


{ tCTecVersion }

class operator tCTecVersion.implicit(a: tCTecVersion): string;
var
  iSep : char;
begin
  if a.fSeparator in ['A'..'Z'] then
  begin
    iSep := a.fSeparator;
  end
  else
  begin
    iSep := 'A';
  end;
  Result := IntToStr( a.fMinor );
  if Length( Result ) = 1 then
  begin
    Result := IntToStr( a.fMajor ) + iSep + '0' + Result;
  end
  else
  begin
    Result := IntToStr( a.fMajor ) + iSep + Result;
  end;
end;

class operator tCTecVersion.Equal(a, b: tCTecVersion): boolean;
begin
  Result := (a.Major = b.Major) and (a.Separator = b.Separator) and (a.Minor = b.Minor );
end;

class operator tCTecVersion.Equal(a: tCTecVersion; b: string): boolean;
var
  c : tCTecVersion;
begin
  c := b;
  Result := a = c;
end;

class operator tCTecVersion.Equal(a: string; b: tCTecVersion): boolean;
var
  c : tCTecVersion;
begin
  c := a;
  Result := b = c;
end;

class operator tCTecVersion.GreaterThan(a, b: tCTecVersion): boolean;
begin
  Result := not (a <= b);
end;

class operator tCTecVersion.GreaterThan(a: tCTecVersion; b: string): boolean;
begin
  Result := not (a <= b);
end;

class operator tCTecVersion.GreaterThan(a: string; b: tCTecVersion): boolean;
begin
  Result := not (a <= b);
end;

class operator tCTecVersion.GreaterThanOrEqual(a, b: tCTecVersion): boolean;
begin
  Result := not (a < b );
end;

class operator tCTecVersion.GreaterThanOrEqual(a: tCTecVersion;
  b: string): boolean;
begin
  Result := not (a < b );
end;

class operator tCTecVersion.GreaterThanOrEqual(a: string;
  b: tCTecVersion): boolean;
begin
  Result := not (a < b );
end;

class operator tCTecVersion.implicit(a: string): tCTecVersion;
var
  iLen : integer;
  iMajor, iMinor : integer;
  iSep : char;
begin
  iLen := Length( a );
  if iLen < 4 then
  begin
    raise Exception.Create('Illegal Version');
  end;
  try
    iMinor := StrToInt( Copy( a, iLen - 1, 2 ));
  except
    raise Exception.Create('Illegal Version');
  end;
  iSep := a[ iLen - 2 ];
  if not (iSep in ['A'..'Z']) then
  begin
    raise Exception.Create('Illegal Version');
  end;
  try
    iMajor := StrToInt( Copy( a, 1, iLen - 3 ));
  except
    raise Exception.Create('Illegal Version');
  end;
  Result.fMajor := iMajor;
  Result.fSeparator := iSep;
  Result.fMinor := iMinor;
end;

class operator tCTecVersion.LessThan(a: string; b: tCTecVersion): boolean;
var
  c : tCTecVersion;
begin
  c := a;
  Result := c < b;
end;

class operator tCTecVersion.LessThanOrEqual(a, b: tCTecVersion): boolean;
begin
  Result := (a < b) or (a=b);
end;

class operator tCTecVersion.LessThanOrEqual(a: tCTecVersion;
  b: string): boolean;
begin
  Result := (a < b) or (a=b);
end;

class operator tCTecVersion.LessThanOrEqual(a: string;
  b: tCTecVersion): boolean;
begin
  Result := (a < b) or (a=b);
end;

class operator tCTecVersion.NotEqual(a, b: tCTecVersion): boolean;
begin
  Result := not (a=b);
end;

class operator tCTecVersion.NotEqual(a: tCTecVersion; b: string): boolean;
begin
  Result := not (a=b);
end;

class operator tCTecVersion.NotEqual(a: string; b: tCTecVersion): boolean;
begin
  Result := not (a=b);
end;

class operator tCTecVersion.LessThan(a: tCTecVersion; b: string): boolean;
var
  c : tCTecVersion;
begin
  c := b;
  Result := a < c;
end;

class operator tCTecVersion.LessThan(a, b: tCTecVersion): boolean;
begin
  if a.Major < b.Major then
  begin
    Result := TRUE;
  end
  else if a.Major = b.Major then
  begin
    if a.Separator < b.Separator then
    begin
      Result := TRUE;
    end
    else if a.Separator = b.Separator then
    begin
      Result := a.Minor < b.Minor;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

end.
