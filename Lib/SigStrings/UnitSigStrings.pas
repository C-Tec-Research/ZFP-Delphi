unit UnitSigStrings;

{
  Functions to add sorted strings to a a tStrings object or descendant
}

interface

uses
  Classes,
  System.SysUtils{,
  AnsiStrings};

type
  TInfiniteStringList = class( tStringList )
  private
  protected
    function Get(Index: Integer): string; override;
  public
  end;

function AddSigString( const Value : string; const List : tStrings ) : integer;
         // inserts, adds or finds a case insensitive string in a list
         // Returns insertion point.

implementation

function AddSigString( const Value : string; const List : tStrings ) : integer;
         // inserts, adds or finds a case insensitive string in a list
         // Returns insertion point.
begin
  for Result := 0 to List.Count - 1 do
  begin
    if SameText( List[ Result ], Value ) then
    begin
      if Value > List[ Result ] then
      begin
        List[ Result ] := Value; // use mixed or lower case in preference
      end;
      exit;
    end
    else if Value < List[ Result ] then
    begin
      // insert here
      List.Insert( Result, Value );
      exit;
    end;
  end;
  // else
  Result := List.Add( Value );
end;

{ tInfiniteStringList }

function TInfiniteStringList.Get(Index: Integer): string;
begin
  if Index >= Count then
  begin
    Result := '';
  end
  else
  begin
    Result := inherited;
  end;
end;

end.
