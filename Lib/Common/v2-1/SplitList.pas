unit SplitList;

interface

uses
  SysUtils;

function SplitAtWhitespace( const NewVal : string; var pLeft : string; var pRight : string ) : boolean;
// splits list at first location that contains a character in ParseList
// Returns TRUE if a split found

implementation

function SplitAtWhitespace( const NewVal : string; var pLeft : string; var pRight : string ) : boolean;
// splits list at first location that contains a character in ParseList
// Returns TRUE if a split found
var
  i : integer;
  iTest : string;
  iTest2 : string;
begin
  iTest := Trim( NewVal );
  pLeft := iTest;
  pRight := '';
  Result := FALSE;
  for i := 1 to Length( iTest ) do
  begin
    iTest2 := Copy( iTest, 1 , i );
    if Trim( iTest2 ) <> iTest2 then
    begin
      pRight := Trim( Copy( iTest, i+1, Length( iTest )));
      pLeft := Trim( iTest2 );
      Result := TRUE;
      exit;
    end;
  end;
end;

end.
