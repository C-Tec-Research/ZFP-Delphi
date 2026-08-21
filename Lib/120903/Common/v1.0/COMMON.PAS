unit Common;

interface
  uses SysUtils;

  function IsHex( Value : string ) : Boolean;
  function HexToInt( Value : string ) : integer;
  function PCharToString( Value : PChar ) : string;
  procedure StringToPChar( var Dest : PChar; const Src : string );

implementation

  function IsHex( Value : string ) : Boolean
  ;
  var
    i : integer;
  begin
    IsHex := True;
    for i:= 1 to Length( Value ) do
    begin
      case Value[ i ] of
	'0'..'9','a'..'f','A'..'F' : ;
      else
	IsHex := False;
      end;
    end;
  end;

  function HexToInt( Value : string ) : integer;
  var
    i : integer;
  begin
    Result := 0;
    for i:= 1 to Length( Value ) do
    begin
      case Value[ i ] of
	'0'..'9' : Result := 16 * Result +
			    Ord( Value[ i ] ) - Ord ( '0' );
	'a'..'f' : Result := 16 * Result +  10 +
			    Ord( Value[ i ] ) - Ord ( 'a' );
	'A'..'F' : Result := 16 * Result +  10 +
			    Ord( Value[ i ] ) - Ord ( 'A' );
      end;
    end;
    HexToInt := Result;
  end;

  function PCharToString( Value : PChar ) : string;
  var i: integer;
      Data : string;
  begin
    Data := '';
    for i := 0 to StrLen( Value ) - 1 do
      Data := Data + Value[ i ];
    PCharToString := Data;
  end;

  procedure StringToPChar( var Dest : PChar; const Src : string );
  var
    i : integer;
  begin
    for i := 1 to Length( Src ) do
      Dest[ i-1 ] := Src[ i ];
    Dest[ Length( Src )] := Chr(0);
  end;

end.
