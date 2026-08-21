unit Common;

interface
  uses SysUtils;

  function IsHex( Value : string ) : Boolean;
  function HexToInt( Value : string ) : integer;
  function PCharToString( Value : PChar ) : string;
  procedure StringToPChar( var Dest : PChar; const Src : string );
  function SubString( Value : String ; From, ForChar : integer ) : string;

  function Map( const TrueMin,
                      TrueMax,
                      MapMin,
                      MapMax,
                      TrueVal : LongInt ) : LongInt;

  function MakeTextReadable( const Text : string ) : string;

implementation

  function IsHex( Value : string ) : Boolean
  ;
  var
    i : integer;
  begin
    Result := True;
    for i:= 1 to Length( Value ) do
    begin
      case Value[ i ] of
	'0'..'9','a'..'f','A'..'F' : ;
      else
	Result := False;
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
  end;

  function PCharToString( Value : PChar ) : string;
  var
    i: integer;
  begin
    Result := '';
    for i := 0 to StrLen( Value ) - 1 do
      Result := Result + Value[ i ];
  end;

  procedure StringToPChar( var Dest : PChar; const Src : string );
  var
    i : integer;
  begin
    for i := 1 to Length( Src ) do
      Dest[ i-1 ] := Src[ i ];
    Dest[ Length( Src )] := Chr(0);
  end;

  function SubString( Value : String ; From, ForChar : integer ) : string;
  var
    i, j: integer;
  begin
    Result := '';
    j := From;
    for i:=1 to ForChar do
    begin
      if j <= Length( Value ) then
      begin
        Result := Result + Value[ j ];
        Inc(j);
      end;
    end;
  end;

  function Map( const TrueMin,
                      TrueMax,
                      MapMin,
                      MapMax,
                      TrueVal : LongInt ) : LongInt;
  begin
    { MapVal = MapMin + TrueVal * (MapMax - MapMin) / (TrueMax - TrueMin ) }
    Result := MapMin + ( (TrueVal - TrueMin) * (MapMax - MapMin ))
              div (TrueMax - TrueMin );
  end;

  function MakeTextReadable( const Text : string ) : string;
  var
    i : integer;
  begin
    Result := '';
    for i := 1 to Length( Text ) do
    begin
      case Ord(Text[ i ]) of
        0: Result := Result + '<NUL>';
        1: Result := Result + '<SOH>';
        2: Result := Result + '<STX>';
        3: Result := Result + '<ETX>';
        4: Result := Result + '<EOT>';
        5: Result := Result + '<ENQ>';
        6: Result := Result + '<ACK>';
        7: Result := Result + '<BEL>';
        8: Result := Result + '<BS>';
        9: Result := Result + '<HT>';
        10: Result := Result + '<LF>';
        11: Result := Result + '<VT>';
        12: Result := Result + '<FF>';
        13: Result := Result + '<CR>';
        14: Result := Result + '<SO>';
        15: Result := Result + '<SI>';
        16: Result := Result + '<DLE>';
        17: Result := Result + '<DC1>';
        18: Result := Result + '<DC2>';
        19: Result := Result + '<DC3>';
        20: Result := Result + '<DC4>';
        21: Result := Result + '<NAK>';
        22: Result := Result + '<SYN>';
        23: Result := Result + '<ETB>';
        24: Result := Result + '<CAN>';
        25: Result := Result + '<EM>';
        26: Result := Result + '<SUB>';
        27: Result := Result + '<ESC>';
        28: Result := Result + '<FS>';
        29: Result := Result + '<GS>';
        30: Result := Result + '<RS>';
        31: Result := Result + '<US>';
      else  Result := Result + Text[ i ];
      end;
    end;
  end;

end.
