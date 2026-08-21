unit Common;

interface
  uses Graphics, SysUtils, WinTypes, WinProcs;

  function IsHex( Value : string ) : Boolean;
  function IsBinaryByte( Value : string ) : Boolean;
  function IsBinary( Value : string ) : Boolean;
  function BinaryToInt( Value : string ) : integer;
  function HexToInt( Value : string ) : LongWord;
  function IntToBCD( Value : Word ) : byte;
  function isBinaryMask( Value : string ) : Boolean;
  function CreateANDMask( Value : string ) : Word;
  function IsValidNumber( Value : string; Min, Max : integer ) : boolean;

  function PCharToString( Value : PChar ) : string;
  procedure StringToPChar( var Dest : PChar; const Src : string );
  function SubString( Value : String ; From, ForChar : integer ) : string;
  function Substitute( const Source : string; const Replace : string;
           const ReplaceBy : string; MaxSubs : integer ) : string;

  function Map( const TrueMin,
                      TrueMax,
                      MapMin,
                      MapMax,
                      TrueVal : LongInt ) : LongInt;

  function MakeTextReadable( const Text : string ) : string;

  function PasDrawText( DC: HDC; Str : string; var Rect : TRect;
                        Format : WORD) : Integer;

  function CanvasDrawText( Canvas : TCanvas; Str : String;
                           var Rect : TRect; Format : WORD ) : Integer;

  { some useful rectangle functions }

  procedure ZeroRect( var Rect : TRect ); { intialised elements to zero }
  procedure ResetRect( var Rect : TRect; const NewTop : integer );
                                        { Resets top to zero;
                                          Maintains Height }
  procedure PlaceAfter( const RectBefore : TRect; var RectAfter : TRect );
                                           { puts left of after after right of before;
                                             Maintains width }
  procedure AlignRect( var Rect : array of TRect; NewTop : integer );
                           { set all rectangles in an array to the same top value
                             Sets all bottoms to largest height
                             Puts rectangles one after the other }
implementation

  function IsHex( Value : string ) : Boolean;
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

  function HexToInt( Value : string ) : LongWord;
  var
    i : LongWord;
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
        ' ', char( 7 ) : { ignore spaces and tabs };
      else
        raise EConvertError.Create( 'Illegal Hex value ' + Value );
      end;
    end;
  end;

  function IntToBCD( Value : Word ) : byte;
  begin
    Result := HexToInt( IntToStr( Value ));
  end;

  function IsBinaryByte( Value : string ) : Boolean;
  var
    i : integer;
  begin
    Result := (Length(Value) = 8); {must be 8 bits long }
    for i:= 1 to 8 do
    begin
      case Value[ i ] of
	'0','1':;
      else
	Result := False;
      end;
    end;
  end;

  function IsBinary( Value : string ) : Boolean;
  var
    i : integer;
  begin
    Result := True;
    for i:= 1 to Length( Value ) do
    begin
      case Value[ i ] of
	'0','1':;
      else
	Result := False;
      end;
    end;
  end;

  function BinaryToInt( Value : string ) : integer;
  var
    i : integer;
  begin
    Result := 0;
    for i:= 1 to Length( Value ) do
    begin
      case Value[ i ] of
	'0'..'1' : Result := 2 * Result +
			    Ord( Value[ i ] ) - Ord ( '0' );
      end;
    end;
  end;

  function isBinaryMask( Value : string ) : Boolean;
  var
    i : integer;
  begin
    Result := (Length(Value) = 8); {must be 8 bits long }
    if Result then
    begin
      for i:= 1 to 8 do
      begin
        case Value[ i ] of
          '.','X':;
        else
	  Result := False;
        end;
      end;
    end;
  end;

  function CreateANDMask( Value : string ) : Word;
  var
    i, CurrBitVal : integer;
  begin
    if isBinaryMask(Value ) then
    begin
      Result := 0;
      CurrBitVal := 128;
      for i:= 1 to Length( Value ) do
      begin
        case Value[ i ] of
       	  'X' : Result := Result + CurrBitVal;
          '.' : ;
        else
          begin
	    Result := 511; { 255 + extra bit }
            Exit;
          end;
        end;
        CurrBitVal := CurrBitVal div 2;
      end;
    end
    else
      Result := 255;
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

 function PasDrawText( DC: HDC; Str : string; var Rect : TRect;
                       Format : WORD) : Integer;
 var
   cStr : array [0..255] of char;
   pcStr : pChar;
 begin
   { pascal version of DrawText }
   pcStr := @cStr;
   StringToPChar( pcStr, Str );
   Result := DrawText( DC, pcStr, -1, Rect, Format );
 end;

 function CanvasDrawText( Canvas : TCanvas; Str : String;
                           var Rect : TRect; Format : WORD ) : Integer;
 begin
   Result := PasDrawText( Canvas.Handle, Str, Rect, Format );
 end;

 function Substitute( const Source : string; const Replace : string;
           const ReplaceBy : string ; MaxSubs : integer) : string;
 var
   From : integer;
 begin
   Result := Source;
   From := Pos( Replace, Result );
   if MaxSubs = 0 then MaxSubs := 255;
   while (From > 0) and (MaxSubs > 0) do
   begin
     Delete( Result, From, Length(Replace));
     Insert( ReplaceBy, Result, From );
     From := Pos( Replace, Result );
     Dec(MaxSubs);
   end;
 end;

 procedure ZeroRect( var Rect : TRect ); { intialised elements to zero }
 begin
   with Rect do
   begin
     Top := 0;
     Left := 0;
     Bottom := 0;
     Right := 0;
   end;
 end;

 procedure ResetRect( var Rect : TRect; const NewTop : integer ); { Resets top to zero;
                                             Maintains Height }
 begin
   with Rect do
   begin
     Bottom := Bottom - Top + NewTop;
     Top := NewTop;
   end;
 end;

 procedure PlaceAfter( const RectBefore : TRect; var RectAfter : TRect );
                                           { puts left of after after right of before;
                                             Maintains width }
 begin
   with RectAfter do
   begin
     Right := Right - Left + RectBefore.Right;
     Left := RectBefore.Right;
   end;
 end;

 procedure AlignRect( var Rect : array of TRect; NewTop : integer );
 var
   i, iMax : Integer;
   bMax : Integer;
 begin
                           { set all rectangles in an array to the same top value
                             Sets all bottoms to largest height
                             Puts rectangles one after the other }
   bMax := NewTop;
   iMax := High( Rect );
   { set tops, and get largest bottom }
   for i := 0 to iMax do
   begin
     ResetRect( Rect[i], NewTop );
     if Rect[i].Bottom > bMax then bMax := Rect[i].Bottom;
     if i > 0 then PlaceAfter( Rect[i-1], Rect[i]);
   end;
   for i := 0 to iMax do
   begin
     Rect[i].Bottom := bMax;
   end;
 end;

 function IsValidNumber( Value : string; Min, Max : integer ) : boolean;
 var
   i : integer;
 begin
   try
     i := StrToInt( Value);
     if (i >= Min) and (i <=Max) then Result := TRUE
     else Result := FALSE;
   except
     Result := FALSE;
   end;
 end;

end.
