unit SigList;

{
  Implements a List like 1-3,7,99-108. Unlike DSMList, keeps it as a simple list
}


interface

uses
  System.SysUtils,
  System.StrUtils;

type
  tSigRange = record
  private
    fFinish: integer;
    fStart: integer;
    function GetEntry(i: integer): integer;
  public
    property Start : integer
             read fStart
             write fStart;
    property Finish : integer
             read fFinish
             write fFinish;

    property Entry[ i : integer ] : integer
             read GetEntry;

    function Count : integer;

    class operator implicit( a : tSigRange ) : string;
    class operator implicit( a : string ) : tSigRange;
  end;

  tSigList = record
  private
    fValue : string;
    fNext : integer;
    function GetEntry( i: integer): integer;
  public
    class operator implicit( a : string ) : tSigList;
    class operator implicit( a : tSigList ) : string;

    class function IsValidList( a : string ) : boolean; static;

    function First : string;
    function Next : string;

    function Count : integer;

    property Entry[ i : integer ] : integer
             read GetEntry;

    function Random : integer;
  end;

type
  tSigTimeRange = record
  private
    fFinish: tDateTime;
    fStart: tDateTime;
    function GetEntry(i: tDateTime): tDateTime;
  public
    property Start : tDateTime
             read fStart
             write fStart;
    property Finish : tDateTime
             read fFinish
             write fFinish;

    property Entry[ i : tDateTime ] : tDateTime
             read GetEntry;

    function Count : tDateTime;

    class function StrToTime(const S: string ): TDateTime; static;

    class operator implicit( a : tSigTimeRange ) : string;
    class operator implicit( a : string ) : tSigTimeRange;
  end;

  tSigTimeList = record
  private
    fValue : string;
    fNext : integer;
    function GetEntry( i: tDateTime): tDateTime;
  public
    class operator implicit( a : string ) : tSigTimeList;
    class operator implicit( a : tSigTimeList ) : string;

    class function IsValidList( a : string ) : boolean; static;

    function First : string;
    function Next : string;

    function Count : tDateTime;

    property Entry[ i : tDateTime ] : tDateTime
             read GetEntry;

    function Random : tDateTime;
  end;

implementation

{ tSigRange }

class operator tSigRange.implicit(a: tSigRange): string;
begin
  with a do
  begin
    if Start = Finish then
    begin
      Result := IntToStr( Start );
    end
    else
    begin
      Result := IntToStr( Start ) + '-' + IntToStr( Finish );
    end;
  end;
end;

function tSigRange.Count: integer;
begin
  Result := 1 + Finish - Start;
end;

function tSigRange.GetEntry(i: integer): integer;
begin
  Result := Start + i;
end;

class operator tSigRange.implicit(a: string): tSigRange;
var
  iPos : integer;
  iSub : string;
begin
  { must be of form a or a-b,
    empty (Start = 0, Finish = -1
    or a- (same as a, i.e. strart = finish = a }
  iPos := Pos('-', a );
  with Result do
  begin
    if Trim( a ) = '' then
    begin
      Start := 0;
      Finish := -1;
    end
    else if iPos = 0 then
    begin
      Start := StrToInt( a );
      Finish := Start;
    end
    else
    begin
      Start := StrToInt( Copy( a, 1, iPos - 1 ));
      iSub := Copy( a, iPos + 1);
      if iSub = '' then
      begin
        Finish := Start;
      end
      else
      begin
        Finish := StrToInt( iSub );
      end;
      if Start > Finish then
      begin
        iPos := Start;
        Start := Finish;
        Finish := iPos;
      end;
    end;
  end;
end;

{ tSigList }

function tSigList.Count: integer;
var
  iNext : integer;
  iNextRange : string;
  iRange : tSigRange;
begin
  iNext := fNext;
  try
    Result := 0;  // empty is valid!
    iNextRange := First;
    while iNextRange <> '' do
    begin
      iRange := iNextRange;
      inc( Result, iRange.Count );
      iNextRange := Next;
    end;
  finally
    fNext := iNext;
  end;
end;

function tSigList.First: string;
begin
  fNext := 1;
  Result := Next;
end;

function tSigList.GetEntry( i: integer): integer;
var
  iNext : integer;
  iNextString : string;
  iNextRange : tSigRange;
  iNextCount : integer;
begin
  iNext := fNext;
  try
    iNextString := First;
    while iNextString <> '' do
    begin
      iNextRange := iNextString;
      iNextCount := iNextRange.Count;
      if i > iNextCount then
      begin
        dec( i, iNextCount );
      end
      else
      begin
        Result := iNextRange.Entry[ i ];
      end;
      iNextRange := Next;
    end;
    // should not get here
    raise Exception.Create('Out of range');
  finally
    fNext := iNext;
  end;
end;

class operator tSigList.implicit(a: tSigList): string;
begin
  Result := a.fValue;
end;

class function tSigList.IsValidList(a: string): boolean;
var
  iSigList : tSigList;
begin
  try
    iSigList := a;
    Result := TRUE;
  except
    Result := FALSE;
  end;
end;

function tSigList.Next: string;
var
  iPos : integer;
begin
  iPos := PosEx( ',', fValue, fNext );
  if iPos = 0 then
  begin
    Result := Copy( fValue, fNext );
    fNext := Length( fValue) + 1;
  end
  else
  begin
    Result := Copy( fValue, fNext, iPos - fNext - 1 );
    fNext := iPos + 1;
  end;
end;

function tSigList.Random: integer;
begin
  Result := Entry[ System.Random( Count ) ];
end;

class operator tSigList.implicit(a: string): tSigList;
begin
  with Result do
  begin
    fValue := a;
    fNext := 1;
    Count; // does an implied validity check
  end;
end;

{ tSigTimeRange }

function tSigTimeRange.Count: tDateTime;
begin
  Result := Finish - Start;
end;

function tSigTimeRange.GetEntry(i: tDateTime): tDateTime;
begin
  Result := Start + i;
end;

class operator tSigTimeRange.implicit(a: tSigTimeRange): string;
var
  iLocale : TFormatSettings;
begin
  iLocale := TFormatSettings.Create( 'en-GB' );
  Result := TimeToStr( a.Start, iLocale );
  if a.Start <> a.Finish then
  begin
    Result := Result + '-' + TimeToStr( a.Finish, iLocale );
  end;
end;

class operator tSigTimeRange.implicit(a: string): tSigTimeRange;
var
  iLocale : TFormatSettings;
  iPos : integer;
begin
  iLocale := TFormatSettings.Create( 'en-GB' );
  iPos := Pos( '-', a );
  if iPos = 0 then
  begin
    Result.fStart := StrToTime( a );
    Result.fFinish := Result.fStart;
  end
  else
  begin
    Result.fStart := StrToTime( Copy( a, 1, iPos - 1) );
    Result.fFinish := StrToTime( Copy( a, iPos + 1) );
  end;
end;

class function tSigTimeRange.StrToTime(const S: string): TDateTime;
var
  iHr, iMin, iSec: integer;
  iString : string;
  iPos : integer;
begin
  // we allow a blank value as 0
  iHr := 0;
  iMin := 0;
  iSec := 0;
  iString := S;
  while iString <> '' do
  begin
    if iHr <> 0 then
    begin
      raise Exception.Create('"' + S + '" is not a valid time');
    end;
    // else
    iHr := iMin;
    iMin := iSec;
    iPos := Pos( ':', S );
    if iPos = 0 then
    begin
      iSec := StrToInt( iString );
      iString := '';
    end
    else
    begin
      iSec := StrToInt( Copy(iString, 1, iPos - 1) );
      iString := Copy( iString, iPos + 1 );
    end;
  end;
  Result := (iHr/24) + (iMin/ (24*60)) + (iSec/(24*60*60));
end;

{ tSigTimeList }

function tSigTimeList.Count: tDateTime;
var
  iNext : integer;
  iNextRange : string;
  iRange : tSigTimeRange;
begin
  iNext := fNext;
  try
    Result := 0;  // empty is valid!
    iNextRange := First;
    while iNextRange <> '' do
    begin
      iRange := iNextRange;
      Result := Result + iRange.Count;
      iNextRange := Next;
    end;
  finally
    fNext := iNext;
  end;
end;

function tSigTimeList.First: string;
begin
  fNext := 1;
  Result := Next;
end;

function tSigTimeList.GetEntry(i: tDateTime): tDateTime;
var
  iNext : integer;
  iNextString : string;
  iNextRange : tSigTimeRange;
  iNextCount : tDateTime;
begin
  iNext := fNext;
  try
    iNextString := First;
    while iNextString <> '' do
    begin
      iNextRange := iNextString;
      iNextCount := iNextRange.Count;
      if i > iNextCount then
      begin
        i := i - iNextCount;
      end
      else
      begin
        Result := iNextRange.Entry[ i ];
        exit;
      end;
      iNextRange := Next;
    end;
    // should not get here
    raise Exception.Create('Out of range');
  finally
    fNext := iNext;
  end;
end;

class operator tSigTimeList.implicit(a: string): tSigTimeList;
begin
  with Result do
  begin
    fValue := a;
    fNext := 1;
    Count; // does an implied validity check
  end;
end;

class operator tSigTimeList.implicit(a: tSigTimeList): string;
begin
  Result := a.fValue;
end;

class function tSigTimeList.IsValidList(a: string): boolean;
var
  iSigList : tSigTimeList;
begin
  try
    iSigList := a;
    Result := TRUE;
  except
    Result := FALSE;
  end;
end;

function tSigTimeList.Next: string;
var
  iPos : integer;
begin
  iPos := PosEx( ',', fValue, fNext );
  if iPos = 0 then
  begin
    Result := Copy( fValue, fNext );
    fNext := Length( fValue ) + 1;
  end
  else
  begin
    Result := Copy( fValue, fNext, iPos - fNext - 1 );
    fNext := iPos + 1;
  end;
end;

function tSigTimeList.Random: tDateTime;
begin
  Result := Entry[ System.Random * Count ];
end;

end.
