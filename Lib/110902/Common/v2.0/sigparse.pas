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

function SigNETParse ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : boolean;

function StripSpace( const SigText : string ) : string;

implementation

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


function SigNETParse ( const SigText : string;
         var SigProperty : string;
         var SigIndex : string;
         var SigValue : string;
         var SigComment : string) : boolean;
var
  i, iMax : Integer;
  TempString : String;
  HasIndex : Boolean;
begin
  { remove current strings }
  SigProperty := '';
  SigIndex := '';
  SigValue := '';
  SigComment := '';

  { Assume success (only index can fail) }
  Result := True;

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
        Break;
      end;
      '(':
      { about to start Index }
      begin
        { bypass ( sign for next stage }
        HasIndex := True;
        Inc( i );
        Break;
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
    Result := False;

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
          Result := True;
          Break;
        end;
      end;
    end;

    if not Result then Exit; { end of string and no index! }

    { Until next character is ')'
      we are dealing with Index. Note
    that if we find a white space, we
    store to a temporary string and add
    back in if we do not find ')' next }
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
        { about to start value. If Result is still False,
          we never found a ')' so abort }
        begin
          if Result then
          begin
            { bypass = sign for next stage }
            Inc( i );
            Break;
          end
          else
            { no ')' so fail }
            Exit;
        end;
        ')':
        { We have found end of index }
        begin
          { set result to show that we have found index }
          Result := True;
          Inc( i );
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
              if not Result then
              begin
                SigIndex := SigIndex + TempString
                          + SigText[ i ];
                TempString := '';
                Inc (i );
              end
              else
              begin
                { characters after ')' other than
                  whitespace of = }
                Result := False;
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
  case SigText[ i ] of
    ' ', Chr(7), Chr( 10 ), Chr(13) :
    { Whitespace }
    Inc( i );
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
