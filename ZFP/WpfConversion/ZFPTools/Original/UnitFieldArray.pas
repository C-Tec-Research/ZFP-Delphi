unit UnitFieldArray;

interface

uses
  Common;

type
  tFieldArray = record
  private
    iData : array[ 0..31 ] of byte;
    function GetData(const i: integer): byte;
    procedure SetData(const i: integer; const Value: byte);
  public
    procedure Zero;
    procedure SetByte( const i : integer; const Value : integer );
    procedure SetBit( const StartBit : integer; const Value : boolean );
    procedure SetBits( const StartBit : integer; const BitLen : integer; const Value : integer );
    procedure SetMSB( const Address : integer );
    procedure SetWord( const i : integer; const Value : integer ); // address is address of field of type Word!
    function GetBits( const StartBit : integer; const BitLen : integer ) : integer;
    function GetBit( const StartBit : integer ) : boolean;

    property Data[ const i : integer ] : byte
             read GetData
             write SetData; default;
  end;

implementation

{ tFieldArray }

function tFieldArray.GetBit(const StartBit: integer): boolean;
var
  iByte, iBit : integer;
begin
  iByte := StartBit div 8;
  iBit := StartBit mod 8;
  Result := Common.Bit( iData[ iByte ], iBit);
end;

function tFieldArray.GetBits(const StartBit, BitLen : integer): integer;
var
  i, iByte, iBit, iVMask : integer;
begin
  iVMask := 1;
  Result := 0;
  for i := StartBit to StartBit + BitLen - 1 do
  begin
    iByte := i div 8;
    iBit := i mod 8;
    if Bit( iData[ iByte ], iBit) then
    begin
      Inc( Result, iVMask );
    end;
    iVMask := iVMask shl 1;
  end;

end;

function tFieldArray.GetData(const i: integer): byte;
begin
  Result := iData[ i ];
end;

procedure tFieldArray.SetBit(const StartBit: integer; const Value: boolean);
var
  iByte, iBit : integer;
begin
  iByte := StartBit div 8;
  iBit := StartBit mod 8;
  Common.SetBit( iData[ iByte ], iBit, Value );
end;

procedure tFieldArray.SetBits(const StartBit, BitLen, Value: integer);
var
  i, iByte, iBit, iVMask : integer;
begin
  iVMask := 1;
  for i := StartBit to StartBit + BitLen - 1 do
  begin
    iByte := i div 8;
    iBit := i mod 8;
    if (Value and iVMask) = 0 then
    begin
      Excl( iData[ iByte ], iBit );
    end
    else
    begin
      Incl( iData[ iByte ], iBit );
    end;
    iVMask := iVMask shl 1;
  end;
end;

procedure tFieldArray.SetByte(const i, Value: integer);
begin
  iData[ i ] := Value;
end;

procedure tFieldArray.SetData(const i: integer; const Value: byte);
begin
  iData[ i ] := Value;
end;

procedure tFieldArray.SetMSB(const Address: integer);
var
  iByte : integer;
begin
  iByte := Address div 8;
  incl( iData[ iByte + 1 ], 7 );
end;

procedure tFieldArray.SetWord(const i, Value: integer);
begin
  iData[ i ] := Value mod 256;
  iData[ i + 1 ] := Value div 256;
end;

procedure tFieldArray.Zero;
var
  i: Integer;
begin
  for i := 0 to 31 do
  begin
    iData[ i ] := 0;
  end;
end;

end.
