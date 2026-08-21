unit IPAddressChecks;

interface
  uses
    System.StrUtils,
    System.SysUtils;


type
  TIPAddressValid = ( ipvNo, ipv4,ipv6 );

  function IPAddressValid( const pVal : string ) : TIPAddressValid;
  function IP4AddressValid( const S : string ) : boolean;
  function IP6AddressValid( const S : string ) : boolean;

implementation

const
  IPv4BitSize = SizeOf(Byte) * 4 * 8;
  IPv6BitSize = SizeOf(Word) * 8 * 8;

type
  T4 = 0..3;
  T8 = 0..7;
  TIPv4ByteArray = array[T4] of Byte;
  TIPv6WordArray = array[T8] of Word;

  TIPv4 = packed record
    case Integer of
      0: (D, C, B, A: Byte);
      1: (Groups: TIPv4ByteArray);
      2: (Value: Cardinal);
  end;

  TIPv6 = packed record
    case Integer of
      0: (H, G, F, E, D, C, B, A: Word);
      1: (Groups: TIPv6WordArray);
  end;

function IPAddressValid( const pVal : string ) : TIPAddressValid;
begin
  if IP4AddressValid( pVal ) then
  begin
    Result := ipv4;
  end
  else if IP6AddressValid( pVal ) then
  begin
    Result := ipv6;
  end
  else
  begin
    Result := ipvNo;
  end;
end;

function IP4AddressValid(const S: String): boolean;
var
  SIP: String;
  Start: Integer;
  i : integer;
  Index: Integer;
  Count: Integer;
  SGroup: String;
  G: Integer;
begin
  SIP := S + '.';
  Start := 1;
  for i := 1 to 4 do
  begin
    Index := PosEx('.', SIP, Start);
    if Index = 0 then
    begin
      Result := FALSE;
      exit;
    end;
    Count := Index - Start + 1;
    SGroup := Copy(SIP, Start, Count - 1);
    if TryStrToInt(SGroup, G) and (G >= Low(Word)) and (G <= High(Word)) then
    else
    begin
      Result := FALSE;
      exit;
    end;
    Inc(Start, Count);
  end;
  if Copy( SIP, Start ) <> '' then
  begin
    Result := FALSE;
  end
  else
  begin
    Result := TRUE;
  end;
end;

function IP6AddressValid(const S: String): boolean;
{ Valid examples for S:
  2001:0db8:85a3:0000:0000:8a2e:0370:7334
  2001:db8:85a3:0:0:8a2e:370:7334
  2001:db8:85a3::8a2e:370:7334
  ::8a2e:370:7334
  2001:db8:85a3::
  ::1
  ::
  ::ffff:c000:280
  ::ffff:192.0.2.128 }
var
  ZeroPos: Integer;
  DotPos: Integer;
  SIP: String;
  Start: Integer;
  Index: Integer;
  Count: Integer;
  SGroup: String;
  G: Integer;

  function NormalNotation : boolean;
  var
    I: T8;
  begin
    SIP := S + ':';
    Start := 1;
    for I := High(T8) downto Low(T8) do
    begin
      Index := PosEx(':', SIP, Start);
      if Index = 0 then
      begin
        Result := FALSE;
        exit;
      end;
      Count := Index - Start + 1;
      SGroup := '$' + Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
      begin
        Result := FALSE;
        exit;
      end;
      Inc(Start, Count);
    end;
    if Copy( SIP, Start ) <> '' then
    begin
      Result := FALSE;
    end
    else
    begin
      Result := TRUE;
    end;
  end;

  function CompressedNotation : boolean;
  var
    I: T8;
  begin
    SIP := S + ':';
    Start := 1;
    I := High(T8);
    while Start < ZeroPos do
    begin
      Index := PosEx(':', SIP, Start);
      if Index = 0 then
      begin
        Result := FALSE;
        exit;
      end;
      Count := Index - Start + 1;
      SGroup := '$' + Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
      begin
        Result := FALSE;
        exit;
      end;
      Inc(Start, Count);
      Dec(I);
    end;
    if ZeroPos < (Length(S) - 1) then
    begin
      Start := ZeroPos + 2;
      repeat
        Index := PosEx(':', SIP, Start);
        if Index > 0 then
        begin
          Count := Index - Start + 1;
          SGroup := '$' + Copy(SIP, Start, Count - 1);
          if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
          begin
            Result := FALSE;
            exit;
          end;
          Inc(Start, Count);
          Dec(I);
        end;
      until Index = 0;
      Inc(I);
    end;
    Result := I = Low( T8 );
  end;

  function DottedQuadNotation : boolean;
  var
    I: T4;
  begin
    Result := TRUE;
    if UpperCase(Copy(S, ZeroPos + 2, 4)) <> 'FFFF' then
    begin
      Result := FALSE;
      exit;
    end;
    SIP := S + '.';
    Start := ZeroPos + 7;
    for I := Low(T4) to High(T4) do
    begin
      Index := PosEx('.', SIP, Start);
      if Index = 0 then
      begin
        Result := FALSE;
        exit;
      end;
      Count := Index - Start + 1;
      SGroup := Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Byte)) or (G < 0) then
      begin
        Result := FALSE;
        exit;
      end;
      Inc(Start, Count);
    end;
  end;

begin
  ZeroPos := Pos('::', S);
  if ZeroPos = 0 then
  begin
    Result := NormalNotation;
  end
  else
  begin
    DotPos := Pos('.', S);
    if DotPos = 0 then
    begin
      Result := CompressedNotation;
    end
    else
    begin
      Result := DottedQuadNotation;
    end;
  end;
end;

end.
