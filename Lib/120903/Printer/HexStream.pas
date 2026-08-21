unit HexStream;

interface

uses SysUtils, Classes;

   function MemStream_to_HexString(ms: TMemoryStream): string;
   function HexString_to_MemStream(const hs: string): TMemoryStream;

implementation

function MemStream_to_HexString(ms: TMemoryStream): string;
var
   i     : integer;
   c     : byte;
begin
   SetLength(Result, ms.Size*2);
   for i := 0 to ms.Size-1 do begin
      c := byte(PChar(ms.Memory)[i]);
      Result[i*2+1] := Format('%x', [c shr 4])[1];
      Result[i*2+2] := Format('%x', [c and 15])[1];
   end;
end;

function HexString_to_MemStream(const hs: string): TMemoryStream;
var
   ms          : TMemoryStream;
   i           : integer;
   b, v1, v2   : byte;
begin
   ms := TMemoryStream.Create;
   for i := 1 to Length(hs) div 2 do begin
      v1 := StrToInt('$' + hs[(i-1)*2 + 1]);
      v2 := StrToInt('$' + hs[(i-1)*2 + 2]);
      b := v1 shl 4 + v2;
      ms.WriteBuffer(b, sizeof(b));
   end;

   Result := ms;
end;

end.
