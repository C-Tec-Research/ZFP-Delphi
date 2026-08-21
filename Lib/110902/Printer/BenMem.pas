unit BenMem;

interface

uses SysUtils, Dialogs;

implementation

var
   OldMgr, NewMgr    : TMemoryManager;
   GetMemCount       : integer;
   FreeMemCount      : integer;
   ReallocMemCount   : integer;
   TotGetMem         : integer;


function NewGetMem(Size: integer): pointer;
begin
   Inc(GetMemCount);
   TotGetMem := TotGetMem + Size;
   Result := OldMgr.GetMem(Size);
end;

function NewFreeMem(p: pointer): integer;
begin
   Inc(FreeMemCount);
   Result := OldMgr.FreeMem(p);
end;

function NewReallocMem(p: pointer; Size: integer): pointer;
begin
   Inc(ReallocMemCount);
   Result := OldMgr.ReallocMem(p, Size);
end;

procedure SetMemMgr;
begin
   with NewMgr do begin
      GetMem      := NewGetMem;
      FreeMem     := NewFreeMem;
      ReallocMem  := NewReallocMem;
   end;

   GetMemoryManager(OldMgr);
   SetMemoryManager(NewMgr);
end;

initialization
   SetMemMgr;

finalization
   ShowMessage(Format('Get = %d  Free = %d  Realloc = %d',
      [GetMemCount, FreeMemCount, ReallocMemCount]));

end.
