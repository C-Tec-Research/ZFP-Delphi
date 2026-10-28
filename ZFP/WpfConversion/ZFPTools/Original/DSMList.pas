unit DSMList;

interface

{
  This implements a list as a record. It maps to and from a string

  We implicitly cast to a sting and explicitly from

  As a string a list looks like, e.g. 1-3,7,16-19

  A number of operators are overloaded and have special meaning

  + adds an element. It resizes the array to accommodate if required

  - removes an element if it is there. It produces no error if not there.

  x <= sX means x is a member of sX and returns true if x is in sX.
  sX <= sY means sX is a subset of sY
  sX >= sY means sX is a superset of sY (and is equivalent to sY <= sY
  sX = sY means that the two set have the same members (but not necessarily the same size)


}

uses
  SysUtils,
  Common;

type
  tDSMRange = record
  private
    fFinish: integer;
    fStart: integer;
  public
    property Start : integer
             read fStart
             write fStart;
    property Finish : integer
             read fFinish
             write fFinish;

    class operator LessThanOrEqual( a : integer; b : tDSMRange ) : boolean; // is a member of
    class operator implicit( a : integer ) : tDSMRange;

  end;

type
  tDSMList = record
  public
    const cMin = 0;
    const cMax = 9999;
  private
    fList : array [cMin..cMax] of boolean;
    fPos : integer;
  public
    function First : integer;
    function Next : integer;
    function Last : integer;
    function Count : integer;

    function IndexOf( const pVal : integer ) : integer;

    class operator Add( a : tDSMList; b : tDSMList ) : tDSMList;
    class operator Add( a : tDSMList; b : integer ) : tDSMList;
    class operator Add( b : integer; a : tDSMList ) : tDSMList;
    class operator Add( a : tDSMList; b : tDSMRange ) : tDSMList;
    class operator implicit( a : tDSMList ) : string;
    class operator implicit( a : string ) : tDSMList;
    class operator implicit( a : integer ) : tDSMList;
    class operator implicit( a : tDSMRange ) : tDSMList;
    class operator LessThanOrEqual( a : integer; b : tDSMList ) : boolean; // is a member of
    class operator Subtract( a : tDSMList; b : integer ) : tDSMList;
    class operator Subtract( a : tDSMList; b : tDSMList ) : tDSMList;
    class operator Subtract( a : tDSMList; b : tDSMRange ) : tDSMList;
    class operator NotEqual( a : tDSMList; b : integer ) : boolean;
    class operator NotEqual( a : tDSMList; b : tDSMList ) : boolean;

  end;

implementation

{
var
  sTest : string;

function Test : string;
var
  a, b : tDSMList;
begin
  a := 4;
  b := a + 5;
  Result := b + 8;
end;
}

{ tDSMList }

class operator tDSMList.Add( a : tDSMList; b : tDSMRange ) : tDSMList;
var
  i : integer;
begin
  Result := a;
  for i := b.Start to b.Finish do
  begin
    Result.fList[ i ] := TRUE;
  end;
end;

function tDSMList.Count: integer;
var
  i: Integer;
begin
  Result := 0;
  for i := cMin to cMax do
  begin
    if fList[ i ] then
    begin
      inc( Result );
    end;
  end;
end;

class operator tDSMList.Add( a : tDSMList; b : tDSMList ) : tDSMList;
var
  i : integer;
begin
  for i := cMin to cMax do
  begin
    Result.fList[ i ] := a.fList[ i ] or b.fList[ i ];
  end;
end;

class operator tDSMList.Add( a : tDSMList; b : integer ) : tDSMList;
begin
  Result := a;
  Result.fList[ b ] := TRUE;
end;

class operator tDSMList.Add( b : integer; a : tDSMList ) : tDSMList;
begin
  Result := a;
  Result.fList[ b ] := TRUE;
end;

function tDSMList.First: integer;
var
  i : integer;
begin
  Result := -1;
  fPos := -1;
  for i := cMin to cMax do
  begin
    if fList[ i ] then
    begin
      Result := i;
      fPos := i;
      exit;
    end;
  end;
end;

function tDSMList.IndexOf(const pVal: integer): integer;
var
  i: Integer;
begin
  Result := cMin - 1;
  if fList[ pVal ] then
  begin
    for i := cMin to pVal do
    begin
      if fList[ i ] then
      begin
        inc( Result );
      end;
    end;
  end;
end;

class operator tDSMList.implicit( a : tDSMRange ) : tDSMList;
var
  i : integer;
begin
  for i := cMin to cMax do
  begin
    Result.fList[ i ] := i <= a;
  end;
end;

class operator tDSMList.implicit( a : integer ) : tDSMList;
var
  i : integer;
begin
  for i := cMin to cMax do
  begin
    Result.fList[ i ] := i = a;
  end;
end;

class operator tDSMList.implicit( a : tDSMList ) : string;
var
  i, iStart, iEnd : integer;
begin
  Result := '';
  iStart := -1;
  iEnd := -1;
  for i := cMin to cMax do
  begin
    if a.fList[ i ] then
    begin
      if iStart = -1 then
      begin
        iStart := i;
        iEnd := i;
      end
      else if i = iEnd + 1 then
      begin
        iEnd := i;
      end
      else
      begin
        if Result <> '' then
        begin
          Result := Result + ',';
        end;
        Result := Result + IntToStr( iStart );
        if iEnd <> iStart then
        begin
          Result := Result + '-' + IntToStr( iEnd );
        end;
        iStart := i;
        iEnd := i;
      end;
    end;
  end;
  if iStart <> -1 then
  begin
    if Result <> '' then
    begin
      Result := Result + ',';
    end;
    Result := Result + IntToStr( iStart );
    if iEnd <> iStart then
    begin
      Result := Result + '-' + IntToStr( iEnd );
    end;
  end;
end;

class operator tDSMList.implicit( a : string ) : tDSMList;
var
  i, iLast, iStart, iEnd : integer;
  ia : string;
begin
  ia := a;
  iLast := -1;
  while SplitDSMList( ia, iStart, iEnd ) do
  begin
    for i := iLast + 1 to iStart - 1 do
    begin
      Result.fList[ i ] := FALSE;
    end;
    for i := iStart to iEnd do
    begin
      Result.fList[ i ] := TRUE;
    end;
    iLast := iEnd;
  end;
  for i := iLast + 1 to cMax do
  begin
    Result.fList[ i ] := FALSE;
  end;
end;

function tDSMList.Last: integer;
var
  i : integer;
begin
  Result := -1;
  for i := cMax downto cMin do
  begin
    if fList[ i ] then
    begin
      Result := i;
      exit;
    end;
  end;
end;

class operator tDSMList.LessThanOrEqual( a : integer; b : tDSMList ) : boolean;
begin
  if a <= cMax then
  begin
    Result := b.fList[ a ];
  end
  else
  begin
    Result := FALSE;
  end;
end;

function tDSMList.Next: integer;
var
  i : integer;
begin
  for i := fPos + 1 to 255 do
  begin
    if fList[ i ] then
    begin
      Result := i;
      fPos := i;
      exit;
    end;
  end;
  // else
  Result := -1;
  fPos := -1;
end;

class operator tDSMList.NotEqual(a, b: tDSMList): boolean;
var
  i: Integer;
begin
  for i := cMin to cMax do
  begin
    if a.fList[ i ] <> b.fList[ i ] then
    begin
      Result := TRUE;
      exit;
    end;
  end;
  // else
  Result := FALSE;
end;

class operator tDSMList.NotEqual(a: tDSMList; b: integer): boolean;
var
  i : integer;
begin
  for i := cMin to cMax do
  begin
    if a.fList[ i ] then
    begin
      if b<>i then
      begin
        Result := TRUE;
        exit;
      end;
    end
    else
    begin
      if b=i then
      begin
        Result := TRUE;
        exit;
      end;
    end;
  end;
  // else
  Result := FALSE;
end;

class operator tDSMList.Subtract( a : tDSMList; b : tDSMList ) : tDSMList;
var
  i : integer;
begin
  Result := a;
  for i := 0 to 255 do
  begin
    if b.fList[ i ] then
    begin
      Result.fList[ i ] := FALSE;
    end;
  end;
end;

class operator tDSMList.Subtract( a : tDSMList; b : tDSMRange ) : tDSMList;
var
  i : integer;
begin
  Result := a;
  for i := 0 to 255 do
  begin
    if i <= b then
    begin
      Result.fList[ i ] := FALSE;
    end;
  end;
end;

class operator tDSMList.Subtract( a : tDSMList; b : integer ) : tDSMList;
begin
  Result := a;
  Result.fList[ b ] := FALSE;
end;

{
initialization
  sTest := Test;
}

{ tDSMRange }

class operator tDSMRange.implicit( a : integer ) : tDSMRange;
begin
  Result.Start := a;
  Result.Finish := a;
end;

class operator tDSMRange.LessThanOrEqual( a : integer; b : tDSMRange ) : boolean; // is a member of
begin
  Result := ((a >= b.Start) and ( a <= b.Finish )) or ((a >= b.Finish) and ( a <= b.Start ))
end;

end.

