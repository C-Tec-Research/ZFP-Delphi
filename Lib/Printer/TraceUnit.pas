unit TraceUnit;

interface

uses SysUtils, Classes, Windows;

   procedure TRACE(const s: string; args: array of const);
   procedure TRACE0(const s: string);

implementation

procedure TRACE(const s: string; args: array of const);
begin
   TRACE0(Format(s, args));
end;

procedure TRACE0(const s: string);
begin
   OutputDebugString(PChar(s));
end;


end.
