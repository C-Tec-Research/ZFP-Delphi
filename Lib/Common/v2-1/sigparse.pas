unit Sigparse;

{ This provides standard text parsing.

  The returned strings are PROPERTY, VALUE and
  COMMENT, any or all of which may be empty.

  The general format is

  Property (index) = Value // Comment

  There is no quote pairing or any other such
  device, so property may not contain either
  set of special character, and value may not
  contain //
}

interface

uses
  Sysutils;

type tSigNETParseResult = ( spNone, spEq, spUnbalancedBraces, spGT, spLT, spGE, spLE, spNE, spPlus, spMinus, spTimes, spDiv );

function ParseResultToString( const Val : tSigNETParseResult ) : string;

function GetRangeFromList( var SigList : string;
                           var SigMin : integer;
                           var SigMax : integer ) : boolean;

function IsInList( SigList : string; SigTest : integer ) : boolean;

function SigNETParse ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : boolean;

function SigNETParseDetail ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : tSigNETParseResult;

function IndentedString( pValue : string; pIndent : integer ) : string;

function BlankLineOrComment( const SigText : string; var SigComment : string ) : boolean;

function StripSpace( const SigText : string ) : string;

implementation

function IndentedString( pValue : string; pIndent : integer ) : string;
begin
  Result := StringOfChar( ' ', pIndent ) + pValue;
end;

function IsInList( SigList : string; SigTest : integer ) : boolean;
var
  iStart, iEnd : integer;
begin
  Result := FALSE; // assume failure
  while GetRangeFromList( SigList, iStart, iEnd ) do
  begin
    if SigTest <= iEnd then
    begin
      if SigTest >= iStart then
      begin
        Result := TRUE;
      end;
      exit;  // assume list sorted
    end;
  end;
end;

function GetRangeFromList( var SigList : string;
                           var SigMin : integer;
                           var SigMax : integer ) : boolean;
var
  i, j : integer;
begin
  if SigList = '' then Result := FALSE
  else
  begin
    Result := TRUE;
    SigMin := 0;
    SigMax := 0;
    for i := 1 to length( SigList ) do
    begin
      case SigList[ i ] of
        '0'..'9':
        begin
          SigMin := 10 * SigMin + ord( SigList[ i ] ) - ord('0');
          SigMax := SigMin;
        end;
        '-':
        begin
          SigMax := 0;
          for j := i + 1 to length( SigList ) do
          begin
            case SigList[ j ] of
              '0'..'9':
              begin
                SigMax := 10 * SigMax + ord( SigList[ j ] ) - ord('0');
              end;
              ',':
              begin
                SigList := copy( SigList, j + 1, Length( SigList ));
                exit;
              end;
            end;
          end;
          SigList := ''; // end of list
          exit;
        end;
        ',':
        begin
          SigList := copy( SigList, i + 1, Length( SigList ));
          exit;
        end;
      end;
    end;
    // end of list
    SigList := '';
    exit;
  end;
end;

function StripSpace( const SigText : string ) : string;
var
  i, iMax : integer;
  TempString : String;
begin
  Result := '';
  { Get limits }
  iMax := Length( SigText );

  { Set to start of string }
  i := 1;

  { Remove leading whitespace }
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      Inc( i );
    else
      { Drop out of loop }
      Break;
    end;
  end;

  { Copy all characters except whitespace at end.
    Note that if we find a white space, we
    store to a temporary string and add
    back in if we do not find end of string }
  TempString := '';
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      begin
        TempString := TempString + SigText[ i ];
        Inc( i );
      end;
    else
      { Copy To Property }
      begin
       Result := Result + TempString
                   + SigText[ i ];
       TempString := '';
       Inc (i );
      end;
    end;
  end;

end;

function ParseResultToString( const Val : tSigNETParseResult ) : string;
begin
  case Val of
    spNone : Result := '';
    spEq   : Result := ' = ';
    spUnbalancedBraces : raise Exception.Create( 'Error - Unbalanced Braces' );
    spGT   : Result := ' > ';
    spLT   : Result := ' < ';
    spGE   : Result := ' >= ';
    spLE   : Result := ' <= ';
    spNE   : Result := ' <> ';
    spPlus : Result := ' + ';
    spMinus: Result := ' - ';
    spTimes: Result := ' * ';
    spDiv  : Result := ' / ';
  end;
end;

function BlankLineOrComment( const SigText : string; var SigComment : string ) : boolean;
var
  SigProperty : string;
  SigIndex : string;
  SigValue : string;
begin
  Result := SigNETParse( SigText, SigProperty, SigIndex, SigValue, SigComment );
  if Result then
  begin
    if SigProperty <> '' then Result := FALSE;
    if SigIndex <> '' then Result := FALSE;
    if SigValue <> '' then Result := FALSE;
  end;
end;

function SigNETParse ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : boolean;
var
  SigResult : tSigNETParseResult;
begin
  SigResult := SigNETParseDetail( Trim(SigText), SigProperty, SigIndex, SigValue, SigComment );
  case SigResult of
    spNone, spEq: Result := TRUE;
    spUnbalancedBraces: Result := FALSE;
    else
    begin
      // for these the split is not valid, i.e. treat as property without value
      if SigIndex = '' then
      begin
        if SigComment = '' then
        begin
          // no comment, so can give exact reply
          SigProperty := Trim( SigText );
          SigValue := '';
          Result := TRUE;
        end
        else
        begin
          // reconstitute in standard format
          SigProperty := SigProperty + ParseResultToString( SigResult ) + SigValue;
          SigValue := '';
          Result := TRUE;
        end;
      end
      else
      begin
        Result := FALSE;
      end;
    end;
  end;
end;

function SigNETParseDetail ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : tSigNETParseResult;
var
  i, iMax : Integer;
  TempString : String;
  HasIndex : Boolean;
  IndexFail : boolean;
  iBraceCount : integer;
begin
  { remove current strings }
  SigProperty := '';
  SigIndex := '';
  SigValue := '';
  SigComment := '';
  HasIndex := FALSE;

  Result := spNone;

  iBraceCount := 0;

  { Get limits }
  iMax := Length( SigText );

  { Set to start of string }
  i := 1;

  { Remove leading whitespace }
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      Inc( i );
    else
      { Drop out of loop }
      Break;
    end;
  end;

  { Until next character is =, ( or /
    we are dealing with Property. Note
    that if we find a white space, we
    store to a temporary string and add
    back in if we do not find = or // next }
  TempString := '';
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      begin
        TempString := TempString + SigText[ i ];
        Inc( i );
      end;
      '=':
      { about to start value }
      begin
        { bypass = sign for next stage }
        HasIndex := False;
        Inc( i );
        // could be second separator
        case SigText[ i ] of
          '<':
          begin
            Result := spLE;
            inc( i );
          end;
          '>':
          begin
            Result := spGE;
            inc( i );
          end;
          else
          begin
            // ignore the rest
            Result := spEQ;
            // no inrement here!
          end;
        end;
        Break;
      end;
      '<':
      { about to start value }
      begin
        { bypass = sign for next stage }
        HasIndex := False;
        Inc( i );
        // could be second separator
        case SigText[ i ] of
          '=':
          begin
            Result := spLE;
            inc( i );
          end;
          '>':
          begin
            Result := spNE;
            inc( i );
          end;
          else
          begin
            // ignore the rest
            Result := spLT;
            // no increment here!
          end;
        end;
        Break;
      end;
      '>':
      { about to start value }
      begin
        { bypass = sign for next stage }
        HasIndex := False;
        Inc( i );
        // could be second separator
        case SigText[ i ] of
          '=':
          begin
            Result := spGE;
            inc( i );
          end;
          '>':
          begin
            Result := spNE;
            inc( i );
          end;
          else
          begin
            // ignore the rest
            Result := spGT;
            // no increment here!
          end;
        end;
        Break;
      end;
      '(':
      { about to start Index }
      begin
        if iBraceCount = 0 then
        begin
          inc( iBraceCount );
          { bypass ( sign for next stage }
          HasIndex := True;
          Inc( i );
          Break;
        end
        else
        begin
          TempString := TempString + '(';
        end;
      end;
      '/' :
      { Might be about to start comment - check }
        begin
          if (i < iMax) and (SigText [ i + 1 ] = '/') then
          begin
            { Are starting comment }
            Break;
          end
          else
          begin
            { Not starting comment - carry on }
            SigProperty := SigProperty + TempString
                          + SigText[ i ];
            TempString := '';
            Inc (i );
          end;
        end;
    else
      { Copy To Property }
      begin
       SigProperty := SigProperty + TempString
                   + SigText[ i ];
       TempString := '';
       Inc (i );
      end;
    end;
  end;

  { Deal with index, if any }
  if HasIndex then
  begin

    { this bit can fail }
    IndexFail := TRUE;

    { Remove leading whitespace }
    while i <= iMax do
    begin
      case SigText[ i ] of
        ' ', Chr(7), Chr( 10 ), Chr(13) :
        { Whitespace }
        Inc( i );
      else
        begin
          { Drop out of loop }
          IndexFail := FALSE;
          Break;
        end;
      end;
    end;

    if IndexFail then
    begin
      Result := spUnbalancedBraces;
      Exit; { end of string and no index! }
    end;

    { Until next character is ')'
      we are dealing with Index. Note
    that if we find a white space, we
    store to a temporary string and add
    back in if we do not find ')' next }
    IndexFail := TRUE;

    TempString := '';
    while i <= iMax do
    begin
      case SigText[ i ] of
        ' ', Chr(7), Chr( 10 ), Chr(13) :
        { Whitespace }
        begin
          TempString := TempString + SigText[ i ];
          Inc( i );
        end;
        '=':
        { about to start value. If IndexFail  is still False,
          we never found a ')' so abort }
        begin
          if IndexFail then
          begin
            if Pos( ')', Copy( SigText, i+1, Length( SigText ))) = 0 then
            begin
              { no ')' so fail unless a later ')' exists}
              Result := spUnbalancedBraces;
              Exit;
            end
            else
            begin
              SigIndex := SigIndex + TempString
                       + SigText[ i ];
              TempString := '';
              Inc (i );
            end;
          end
          else
          begin
            { bypass = sign for next stage }
            Inc( i );
            // could be second value
            case SigText[ i ] of
              '<':
              begin
                Result := spLE;
                inc( i );
              end;
              '>':
              begin
                Result := spGE;
                inc( i );
              end;
              else
              begin
                // ignore the rest
                Result := spEQ;
                // no increment here!
              end;
            end;
            Break;
          end;
        end;
        '<':
        { about to start value. If IndexFail  is still False,
          we never found a ')' so abort }
        begin
          if IndexFail then
          begin
            { no ')' so fail }
            Result := spUnbalancedBraces;
            Exit;
          end
          else
          begin
            { bypass = sign for next stage }
            Inc( i );
            // could be second value
            case SigText[ i ] of
              '=':
              begin
                Result := spLE;
                inc( i );
              end;
              '>':
              begin
                Result := spNE;
                inc( i );
              end;
              else
              begin
                // ignore the rest
                Result := spLT;
                // no increment here!
              end;
            end;
            Break;
          end;
        end;
        '>':
        { about to start value. If IndexFail  is still False,
          we never found a ')' so abort }
        begin
          if IndexFail then
          begin
            { no ')' so fail }
            Result := spUnbalancedBraces;
            Exit;
          end
          else
          begin
            { bypass = sign for next stage }
            Inc( i );
            // could be second value
            case SigText[ i ] of
              '<':
              begin
                Result := spNE;
                inc( i );
              end;
              '=':
              begin
                Result := spGE;
                inc( i );
              end;
              else
              begin
                // ignore the rest
                Result := spGT;
                // no increment here!
              end;
            end;
            Break;
          end;
        end;
        '(':
        begin
          inc( iBraceCount );
          SigIndex := SigIndex + TempString
                   + SigText[ i ];
          TempString := '';
          Inc (i );
        end;
        ')':
        { We have found end of index }
        begin
          if iBraceCount > 1 then
          begin
            dec( iBraceCount );
            SigIndex := SigIndex + TempString
                     + SigText[ i ];
            TempString := '';
            Inc (i );
          end
          else
          begin
            { set result to show that we have found index }
            IndexFail := FALSE;
            Inc( i );
          end;
        end;
        '/' :
        { Might be about to start comment - check }
          begin
            if (i < iMax) and (SigText [ i + 1 ] = '/') then
            begin
              { Are starting comment }
              Break;
            end
            else
            begin
              { Not starting comment - carry on }
              if IndexFail then
              begin
                SigIndex := SigIndex + TempString
                          + SigText[ i ];
                TempString := '';
                Inc (i );
              end
              else
              begin
                { characters after ')' other than
                  whitespace, =, <, or > }
                Result := spUnbalancedBraces;
                Exit;
              end;
            end;
          end;
        else
        { Copy To index }
        begin
          SigIndex := SigIndex + TempString
                   + SigText[ i ];
          TempString := '';
          Inc (i );
        end;
      end;
    end;

  end;

  { if we get here, we can no longer fail }
  { ready for value; strip leading white space }
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      Inc( i );
    else
      { Drop out of loop }
      Break;
    end;
  end;

  { Until next characters are //
    we are dealing with Property. Note
    that if we find a white space, we
    store to a temporary string and add
    back in if we do not find / next }
  TempString := '';
  while i <= iMax do
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      begin
        TempString := TempString + SigText[ i ];
        Inc( i );
      end;
      '/' :
      { Might be about to start comment - check }
        begin
          if (i < iMax) and (SigText [ i + 1 ] = '/') then
          begin
            { Are starting comment, bypass next 2 characters }
            i := i + 2;
            Break;
          end
          else
          begin
            { Not starting comment - carry on }
            SigValue := SigValue + TempString
                          + SigText[ i ];
            TempString := '';
            Inc (i );
          end;
        end;
    else
      { Copy To Value }
      begin
       SigValue := SigValue + TempString
                   + SigText[ i ];
       TempString := '';
       Inc (i );
      end;
    end;
  end;

  { ready for comment; strip a maximum of
    1 leading white space. This allows
    indented comments if required }
  if i < iMax then
  begin
    case SigText[ i ] of
      ' ', Chr(7), Chr( 10 ), Chr(13) :
      { Whitespace }
      Inc( i );
    end;
  end;

  { copy rest of line to comment, including any
    trailing whitespace characters}
  while i <= iMax do
  begin
    SigComment := SigComment + SigText [ i ];
    Inc (i);
  end;

end;

end.
