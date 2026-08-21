unit StrUtil;

interface

function FindRepAll(var s: string; const FindStr, RepStr: string): boolean;


implementation

// ************************************************************************
// Utility functions
// ************************************************************************

function FindRep(var s: string; const FindStr, RepStr: string): boolean;
var
   w : integer;
begin
   Result := False;
   if Pos(FindStr, RepStr)<>0 then exit;  // Otherwise it would do infinite recursion

   w := Pos(FindStr, s);
   if (w<>0) then begin
      s := Copy(s, 1, w-1) + RepStr + Copy(s, w + Length(FindStr), Length(s));
      Result := True;
   end;
end;

function FindRepAll(var s: string; const FindStr, RepStr: string): boolean;
begin
   Result := False;
   while FindRep(s, FindStr, RepStr) do
      Result := True;
end;

end.
