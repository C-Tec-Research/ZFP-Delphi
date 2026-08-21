{ $DEFINE FMX_COMMON}    // temp to help editor
{$IFNDEF FMX_COMMON}
unit Common;
{$ENDIF}

interface
  uses SysUtils,
       System.UITypes,
       Classes,
{$IFDEF FMX_COMMON}
{$ELSE}
       Windows,
       Graphics,
       Dialogs,
{$ENDIF}
       Types;

  procedure CommaListToStringList( pString : string; pList : tStrings; IgnoreTrailingComma : boolean = FALSE );

  function Iff( const pTest : boolean; const pVal1, pVal2 : integer ) : string; overload;
  //function Iff( const pTest : boolean; const pVal1, pVal2 : string ) : string; overload;
  //function Iff( const pTest : boolean; const pVal1, pVal2 : integer ) : integer; overload;
  //function Iff( const pTest : boolean; const pVal1, pVal2 : TDateTime ) : TDateTime; overload;

  function NextChar( var Value : string ) : char;

  function IsHex( Value : string ) : Boolean;
  function IsBinaryByte( Value : string ) : Boolean;
  function IsBinary( Value : string ) : Boolean;
  function BinaryToInt( Value : string ) : integer;
  function HexToInt( Value : string ) : integer;
  function HexToUInt64( Value : string ) : UInt64;
  function IntToBCD( Value : Word ) : byte;
  function isBinaryMask( Value : string ) : Boolean;
  function CreateANDMask( Value : string ) : Word;
  function IsValidNumber( Value : string; Min, Max : integer ) : boolean;

  function PCharToString( Value : PChar ) : string;
  procedure StringToPChar( var Dest : PAnsiChar; const Src : string );
  function SubString( Value : String ; From, ForChar : integer ) : string;
  function Substitute( const Source : string; const Replace : string;
           const ReplaceBy : string; MaxSubs : integer = 0 ) : string;

  function Map( const TrueMin,
                      TrueMax,
                      MapMin,
                      MapMax,
                      TrueVal : LongInt ) : LongInt;

  function MakeCharReadable( const Text : char ) : string;
  function MakeTextReadable( const Text : string ) : string;
  function MakeEnumReadable( const Text : string ) : string;
  function ExtractReadableChar( const Text : string ) : char;

{$IFDEF FMX_COMMON}
{$ELSE}
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
  {Find value from resource stream of application}
  function FindResourceValue (const sVersionInfo: string): string;

  procedure Warning( pWarning : string );
  procedure ErrorMsg( pError : string );
  function MsgVisible : boolean;

{$ENDIF}

  function SplitDSMList( var List : string;
                         var First : integer;
                         var Last : integer ) : boolean;
  function ValueInDSMList( const List : string; const Val : integer ) : boolean;

  function Bit( const iVal : byte; const iBitNo : integer ) : boolean; overload;
  procedure Incl( var iVal : byte; const iBitNo : integer ); overload;
  procedure Excl( var iVal : byte; const iBitNo : integer ); overload;
  procedure SetBit( var iVal : byte; const iBitNo : integer; const Value : boolean ); overload;
  function Bit( const iVal : word; const iBitNo : integer ) : boolean; overload;
  procedure Incl( var iVal : word; const iBitNo : integer ); overload;
  procedure Excl( var iVal : word; const iBitNo : integer ); overload;
  procedure SetBit( var iVal : word; const iBitNo : integer; const Value : boolean ); overload;
  function Bit( const iVal : longword; const iBitNo : integer ) : boolean; overload;
  procedure Incl( var iVal : longword; const iBitNo : integer ); overload;
  procedure Excl( var iVal : longword; const iBitNo : integer ); overload;
  procedure SetBit( var iVal : longword; const iBitNo : integer; const Value : boolean ); overload;

  function ISQRT( const i : integer; const RoundUp : boolean ) : integer;

  function ReplaceWord( const pText, pReplace, pReplaceBy : string; const pIgnoreCase, pWordsOnly : boolean ) : string;

  function TextSimilar( const pString1, pString2 : string; const MinMatchPC, MaxLenDiff : integer ) : boolean;

  const
    cCharNUL = 0;
    cCharSOH = 1;
    cCharSTX = 2;
    cCharETX = 3;
    cCharEOT = 4;
    cCharENQ = 5;
    cCharACK = 6;
    cCharBEL = 7;
    cCharBS  = 8;
    cCharHT  = 9;
    cCharLF  = 10;
    cCharVT  = 11;
    cCharFF  = 12;
    cCharCR  = 13;
    cCharSO  = 14;
    cCharSI  = 15;
    cCharDLE = 16;
    cCharDC1 = 17;
    cCharDC2 = 18;
    cCharDC3 = 19;
    cCharDC4 = 20;
    cCharNAK = 21;
    cCharSYN = 22;
    cCharETB = 23;
    cCharCAN = 24;
    cCharEM  = 25;
    cCharSUB = 26;
    cCharESC = 27;
    cCharFS  = 28;
    cCharGS  = 29;
    cCharRS  = 30;
    cCharUS  = 31;
    cCharDEL = 127;

implementation

{$IFDEF FMX_COMMON}
{$ELSE}
var
  fMsgVisible : boolean;
{$ENDIF}

function TextSimilar( const pString1, pString2 : string; const MinMatchPC, MaxLenDiff : integer ) : boolean;
var
  i, iMinLength, iMatchCount, iLen1, iLen2, iDiff : integer;
begin
  // min length is fewest characters where 1 char difference >= (100 - MinMatchPC)/100
  // so 1/iMinLength >=  1 - MinMatchPC/100
  // So MinLength = (100/ (100 - MinMatchPC ) rounded up = (199 - MinMatchPC)/(100 - MinMatchPC)
  // Measured wrt pString1
  // examples if MinMatchPC = 50%, then min length = 2 (logically)
  // (199 - 50 ) / ( 100 - 50 ) =149 / 50 = 2
  // If MinMatchPC = 90% then Min length = 10 chars (logically)
  // (199 - 90) /(100 - 90) = 109 / 10 = 10.
  // Our test measures the matching chars from the beginning and add that to the
  // matching characters from the end.
  iMinLength := (MinMatchPC + 99) div 100;
  if Length( pString1 ) < iMinLength then
  begin
    // too small - must be same text
    Result := SameText( pString1, pString2 );
  end
  else
  begin
    iMatchCount := 0;
    iLen1 := Length( pString1 );
    iLen2 := Length( pString2 );
    if iLen1 > iLen2 then
    begin
      iDiff := iLen1 - iLen2;
    end
    else
    begin
      iDiff := iLen2 - iLen1;
    end;
    if iDiff > MaxLenDiff then
    begin
      Result := FALSE;
      exit;
    end;
    for i := 1 to iLen1 do
    begin
      if SameText( pString1[ i ], pString2[ i ] ) then
      begin
        inc( iMatchCount );
      end
      else
      begin
        break;
      end;
    end;
    for i := iLen1 downto iMatchCount + 1 do
    begin
      if SameText( pString1[ i ], pString2[ i ] ) then
      begin
        inc( iMatchCount );
      end
      else
      begin
        break;
      end;
    end;
    Result := iMatchCount >= iMinLength;
  end;
end;

function Iff( const pTest : boolean; const pVal1, pVal2 : integer ) : string;
begin
  if pTest then
  begin
    Result := chr(pVal1);
  end
  else
  begin
    Result := chr(pVal2);
  end;
end;
{
function Iff( const pTest : boolean; const pVal1, pVal2 : string ) : string;
begin
  if pTest then
  begin
    Result := pVal1;
  end
  else
  begin
    Result := pVal2;
  end;
end;

function Iff( const pTest : boolean; const pVal1, pVal2 : integer ) : integer;
begin
  if pTest then
  begin
    Result := pVal1;
  end
  else
  begin
    Result := pVal2;
  end;
end;

function Iff( const pTest : boolean; const pVal1, pVal2 : TDateTime ) : TDateTime;
begin
  if pTest then
  begin
    Result := pVal1;
  end
  else
  begin
    Result := pVal2;
  end;
end;
}
procedure CommaListToStringList( pString : string; pList : tStrings; IgnoreTrailingComma : boolean = FALSE );
var
  i : integer;
  iText : string;
begin
  pString := Trim( pString );
  if IgnoreTrailingComma and ( Length( pString ) > 0 ) then
  begin
    if pString[ Length( pString ) ] = ',' then
    begin
      // remove terminating comma
      pString := copy( pString, 1, Length( pString ) - 1);
    end;
  end;
  if pString <> '' then
  begin
    if pString[ 1 ] = '[' then
    begin
      pString := copy( pString, 2 );
    end;
    if pString[ Length( pString )] = ']' then
    begin
      pString := copy( pString, 1, Length( pString ) - 1 );
    end;
  end;
  with pList do
  begin
    Delimiter := ',';
    QuoteChar := '"';
    StrictDelimiter := TRUE;
    Clear;
    DelimitedText := pString;
    for i := 0 to Count - 1 do
    begin
      iText := Trim( Strings[ i ] );
      if Length(iText) >= 2 then
      begin
        if (iText[ 1 ] = '"') and (iText[ Length( iText ) ] = '"') then
        begin
          iText := Copy( iText, 2, Length( iText ) - 2 );
        end;
      end;
      Strings[ i ] := iText;
    end;
  end;
end;

function CouldBeWordChar( pVal : char ) : boolean;
begin
  case pVal of
    'a'..'z',
    'A'..'Z',
    '0'..'9',
    '_':
    begin
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function ReplaceWord( const pText, pReplace, pReplaceBy : string; const pIgnoreCase, pWordsOnly : boolean ) : string;
var
  i : integer;
  iCanBeWord, iMatch : boolean;
  iReplaceLen, iReplaceByLen, iTotalLen : integer;
begin
  Result := '';
  iCanBeWord := TRUE;
  iReplaceLen := Length( pReplace );
  iReplaceByLen := Length( pReplaceBy );
  iTotalLen := Length( pText );
  Result := pText;
  if iReplaceLen = 0 then
  begin
    exit;
  end;
  i := 0;
  while i < iTotalLen do
  begin
    inc( i );
    if pIgnoreCase then
    begin
      iMatch := SameText( Copy( Result, i, iReplaceLen ), pReplace );
    end
    else
    begin
      iMatch := Copy( Result, i, iReplaceLen ) = pReplace;
    end;
    if iMatch then
    begin
      if pWordsOnly then
      begin
        if not iCanBeWord then
        begin
          iMatch := FALSE;
        end
        else if (i + iReplaceLen) <= iTotalLen then
        begin
          iMatch := not CouldBeWordChar( Result[ i + iReplaceLen ] );
        end;
      end;
    end;
    if iMatch then
    begin
      Result := Copy( Result, 1, i-1 ) + pReplaceBy  + Copy( Result, i + iReplaceLen, iTotalLen );
      i := i + iReplaceByLen - 1;
      iTotalLen := Length( Result );
      iCanBeWord := FALSE;
    end
    else
    begin
      iCanBeWord := not CouldBeWordChar( Result[ i ] );
    end;
  end;
end;


function ISQRT( const i : integer; const RoundUp : boolean  ) : integer;
var
  iMin, iAve, iMax, iTest : integer;
begin
  if i < 0 then
  begin
    raise Exception.Create( 'Attempt to take SQRT of negative number (' + IntToStr( i ) + ')');
  end;
  iMin := 0;
  iMax := i;
  while True do
  begin
    iAve := (iMin + iMax) div 2;
    iTest := iAve * iAve;
    if iTest = i then
    begin
      Result := iAve;
      exit;
    end
    else if iMin = iMax then
    begin
      Result := iMin;
      exit;
    end
    else if iMax = iMin + 1 then
    begin
      if RoundUp then
      begin
        Result := iMax;
      end
      else
      begin
        Result := iMin;
      end;
      exit;
    end
    else if iTest > i then
    begin
      iMax := iAve
    end
    else
    begin
      iMin := iAve;
    end;
  end;
end;

procedure SetBit( var iVal : byte; const iBitNo : integer; const Value : boolean );
begin
  if Value then
  begin
    Incl( iVal, iBitNo );
  end
  else
  begin
    Excl( iVal, iBitNo );
  end;
end;

function Bit( const iVal : byte; const iBitNo : integer ) : boolean;
begin
  Result := ( iVal and ( $01 shl iBitNo ) ) <> $00;
end;

procedure Incl( var iVal : byte; const iBitNo : integer );
begin
  iVal := iVal or ( $01 shl iBitNo );
end;

procedure Excl( var iVal : byte; const iBitNo : integer );
begin
  iVal := iVal and not (  $01 shl iBitNo );
end;

procedure SetBit( var iVal : word; const iBitNo : integer; const Value : boolean );
begin
  if Value then
  begin
    Incl( iVal, iBitNo );
  end
  else
  begin
    Excl( iVal, iBitNo );
  end;
end;

function Bit( const iVal : word; const iBitNo : integer ) : boolean;
begin
  Result := ( iVal and ( $01 shl iBitNo ) ) <> $00;
end;

procedure Incl( var iVal : word; const iBitNo : integer );
begin
  iVal := iVal or ( $01 shl iBitNo );
end;

procedure Excl( var iVal : word; const iBitNo : integer );
begin
  iVal := iVal and not (  $01 shl iBitNo );
end;

procedure SetBit( var iVal : longword; const iBitNo : integer; const Value : boolean );
begin
  if Value then
  begin
    Incl( iVal, iBitNo );
  end
  else
  begin
    Excl( iVal, iBitNo );
  end;
end;

function Bit( const iVal : longword; const iBitNo : integer ) : boolean;
begin
  Result := ( iVal and ( $01 shl iBitNo ) ) <> $00;
end;

procedure Incl( var iVal : longword; const iBitNo : integer );
begin
  iVal := iVal or ( $01 shl iBitNo );
end;

procedure Excl( var iVal : longword; const iBitNo : integer );
begin
  iVal := iVal and not (  $01 shl iBitNo );
end;

{$IFDEF FMX_COMMON}
{$ELSE}
function MsgVisible : boolean;
begin
  Result := fMsgVisible;
end;

procedure Warning( pWarning : string );
begin
  fMsgVisible := TRUE;
  MessageDlg( pWarning, mtWarning, [mbOK ], 0 );
  fMsgVisible := FALSE;
end;

procedure ErrorMsg( pError : string );
begin
  fMsgVisible := TRUE;
  MessageDlg( pError, mtError, [mbOK ], 0 );
  fMsgVisible := FALSE;
end;
{$ENDIF}

type EDSMListError = class(Exception);

function ValueInDSMList( const List : string; const Val : integer ) : boolean;
var
  iList : string;
  iBegin, iEnd : integer;
begin
  iList := List;
  Result := FALSE;
  while SplitDSMList( iList, iBegin, iEnd ) do
  begin
    // assume sorted!
    if Val < iBegin then
    begin
      exit;
    end
    else if Val <= iEnd then
    begin
      Result := TRUE;
      exit;
    end;
  end;
end;

function SplitDSMList( var List : string;
                         var First : integer;
                         var Last : integer ) : boolean;
var
  i : integer;
  ProcessingLast : boolean;
begin
  // splits list of form like '1-3,5,9,11-23' and so on
  // Returns TRUE if there has been a split, and false otherwise.
  // Space characters are ignored

  // If the above string were passed, the return values would be
  // List = '5,9,11-23'
  // First = 1
  // Last = 3
  // return = TRUE

  // The next call would return
  // List = '9,11-23'
  // First = 5
  // Last = 5

  Result := FALSE;
  First := 0;
  Last := 0;
  ProcessingLast := FALSE;

  for i := 1 to Length( List ) do
  begin
    case List[i] of
      '0'..'9':
      begin
        if ProcessingLast then
        begin
          Last := Last * 10 + Ord(List[i]) - Ord('0');
          Result := TRUE;
        end
        else
        begin
          First := First * 10 + Ord(List[i]) - Ord('0');
          Last := First;
          Result := TRUE;
        end;
      end;
      '-':
      begin
        ProcessingLast := TRUE;
        Last := 0;
        Result := TRUE;
      end;
      ',':
      begin
        Result := TRUE;
        List := Copy( List, i + 1, Length( List ) - i);
        Exit;
      end;
      ' ':
        // ignore spaces
        ;
      else
        // illegal character
        raise EDSMListError.Create('Illegal character found in list "' + List + '"');
    end;
  end;
  // If we get here we have reached the end of the message, so...
  List := '';
end;

  function NextChar( var Value : string ) : char;
  begin
    if Value = '' then
    begin
      Result := #0;
    end
    else
    begin
      Result := Value[ 1 ];
      Value := Copy( Value, 2, Length( Value ));
    end;
  end;

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

  function HexToInt( Value : string ) : integer;
  var
    i, iMin : integer;
    iNeg : boolean;
  begin
    Result := 0;
    if Length( Value ) = 0 then
    begin
      raise Exception.Create('"" is not a valid number' );
    end;
    if Value[ 1 ] = '-' then
    begin
      iNeg := TRUE;
      iMin := 2;
    end
    else
    begin
      iNeg := FALSE;
      iMin := 1;
    end;
    for i:= iMin to Length( Value ) do
    begin
      case Value[ i ] of
      	'0'..'9' : Result := 16 * Result + Ord( Value[ i ] ) - Ord ( '0' );
        'a'..'f' : Result := 16 * Result +  10 + Ord( Value[ i ] ) - Ord ( 'a' );
        'A'..'F' : Result := 16 * Result +  10 + Ord( Value[ i ] ) - Ord ( 'A' );
        'h': if i <> Length( Value ) then raise Exception.Create('"' + Value + '" is not a valid number');
        'x', '$': if i <> iMin then raise Exception.Create('"' + Value + '" is not a valid number');
        else raise Exception.Create('"' + Value + '" is not a valid number');
      end;
    end;
    if iNeg then Result := -Result;

  end;

  function HexToUInt64( Value : string ) : UInt64;
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

  procedure StringToPChar( var Dest : PAnsiChar; const Src : string );
  var
    i : integer;
  begin
    for i := 1 to Length( Src ) do
      Dest[ i-1 ] := AnsiChar( Src[ i ] );
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

  function MakeCharReadable( const Text : char ) : string;
  begin
    case Ord(Text) of
      cCharNUL: Result := '<NUL>';
      cCharSOH: Result := '<SOH>';
      cCharSTX: Result := '<STX>';
      cCharETX: Result := '<ETX>';
      cCharEOT: Result := '<EOT>';
      cCharENQ: Result := '<ENQ>';
      cCharACK: Result := '<ACK>';
      cCharBEL: Result := '<BEL>';
      cCharBS:  Result := '<BS>';
      cCharHT:  Result := '<HT>';
      cCharLF:  Result := '<LF>';
      cCharVT:  Result := '<VT>';
      cCharFF:  Result := '<FF>';
      cCharCR:  Result := '<CR>';
      cCharSO:  Result := '<SO>';
      cCharSI:  Result := '<SI>';
      cCharDLE: Result := '<DLE>';
      cCharDC1: Result := '<DC1>';
      cCharDC2: Result := '<DC2>';
      cCharDC3: Result := '<DC3>';
      cCharDC4: Result := '<DC4>';
      cCharNAK: Result := '<NAK>';
      cCharSYN: Result := '<SYN>';
      cCharETB: Result := '<ETB>';
      cCharCAN: Result := '<CAN>';
      cCharEM:  Result := '<EM>';
      cCharSUB: Result := '<SUB>';
      cCharESC: Result := '<ESC>';
      cCharFS:  Result := '<FS>';
      cCharGS:  Result := '<GS>';
      cCharRS:  Result := '<RS>';
      cCharUS:  Result := '<US>';
      cCharDEL: Result := '<DEL';
      128..255: Result := '<#' + IntToHex( Ord(Text),2) +'>';
    else  Result := Text;
    end;
  end;

  function ExtractReadableChar( const Text : string ) : char;
  var
    i : char;
    s : string;
  begin
    case Length( Text ) of
      0, 2: raise eRangeError.Create( '"' + Text + '" does not represent a valid character');
      1: Result := Text[ 1 ];
      else
      begin
        if (Text[ 1 ] <> '<') or (Text[ length( Text ) ] <> '>')  then
        begin
          raise eRangeError.Create( '"' + Text + '" does not represent a valid character');
        end;
        if Text[ 2 ] = '#' then
        begin
          //hex number ?
          s := Copy( Text, 3, Length( Text ) - 3 );
          if IsHex( s ) then
          begin
            Result := char( HexToInt( s ) );
          end
          else
          begin
            raise eRangeError.Create( '"' + Text + '" does not represent a valid character');
          end;
        end
        else
        begin
          s := Copy( Text, 2, Length( Text ) - 2 );
          if IsValidNumber( s, 0, 255) then
          begin
            Result := Char(StrToInt( s ));
          end
          else
          begin
            for i := #0 to #31 do
            begin
              if SameText( MakeCharReadable( i ), Text ) then
              begin
                Result := i;
                exit;
              end;
            end;
            // else
            raise eRangeError.Create( '"' + Text + '" does not represent a valid character');
          end;
        end;
      end;
    end;

  end;

  function MakeTextReadable( const Text : string ) : string;
  var
    i : integer;
  begin
    Result := '';
    for i := 1 to Length( Text ) do
    begin
      Result := Result + MakeCharReadable( Text[ i ] );
    end;
  end;

  function MakeEnumReadable( const Text : string ) : string;
  var
    iVal : string;
    iPos : integer;
  begin
    iVal := Text;
    iPos := Pos( '_', iVal );
    iVal := Copy( iVal, iPos + 1, Length( iVal ));
    iPos := Pos( '_', iVal );
    while iPos > 0 do
    begin
    {$WARNINGS OFF}
      iVal[ iPos ] := ' ';
    {$WARNINGS ON}
      iPos := Pos( '_', iVal );
    end;
    Result := iVal;
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

{$IFDEF FMX_COMMON}
{$ELSE}
  function PasDrawText( DC: HDC; Str : string; var Rect : TRect;
                       Format : WORD) : Integer;
 //var
//   iAnsiChar : array[ 0..255 ] of AnsiChar;
 begin
   { pascal version of DrawText }
   //StringToPChar( @iAnsiChar, Str );
   //Result := DrawText( DC, iAnsiChar, -1, Rect, Format );
   Result := DrawText( DC, Str, -1, Rect, Format );
 end;

 function CanvasDrawText( Canvas : TCanvas; Str : String;
                           var Rect : TRect; Format : WORD ) : Integer;
 begin
   Result := PasDrawText( Canvas.Handle, Str, Rect, Format );
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
function FindResourceValue (const sVersionInfo: string): string;
var
  ResourceStream : TResourceStream;
  NextChar : WideChar;
  i, iMatchLen : integer;
  vString : string;
  FindValue : WideString;
begin
	{ update version info }
	FindValue := sVersionInfo;
	try
		ResourceStream := TResourceStream.CreateFromID( HInstance, 1, RT_VERSION );
	except
		Exit;
	end;

	iMatchLen := 1;
	for i := 1 to ResourceStream.size do
  begin
		ResourceStream.Read( NextChar, 2 );
		if Nextchar = FindValue[ iMatchLen ] then
    begin
			if iMatchLen = Length( FindValue ) then
      begin
				vString := '';
				ResourceStream.Read( NextChar, 2 );
				while NextChar = WideChar(0) do
        begin
					ResourceStream.Read( NextChar, 2 );
        end;
				while NextChar <> WideChar(0) do
        begin
					vString := VString + NextChar;
					ResourceStream.Read( NextChar, 2 );
				end;
			end
			else
      begin
				iMatchLen := iMatchLen + 1;
			end;
		end
		else
    begin
			iMatchLen := 1;
		end;
	end;
	Result := vString;
	ResourceStream.Free;
end;

initialization
  fMsgVisible := FALSE;
{$ENDIF}


end.
