unit NewMemMgr;

interface

uses TraceUnit;

var
   GetMemCount       : integer;
   FreeMemCount      : integer;
   ReallocMemCount   : integer;
   OldMemMgr         : TMemoryManager;

procedure SetNewMemMgr;


implementation

uses SysUtils;

function NewGetMem(Size: Integer): Pointer;
begin
   Inc(GetMemCount);
   Result := OldMemMgr.GetMem(Size);
   // Trace('Get Mem  Size = %d', [Size]);
   TraceMsg(1, size);
end;

function NewFreeMem(P: Pointer): Integer;
begin
   Inc(FreeMemCount);
   Result := OldMemMgr.FreeMem(P);
   // Trace('Free Mem', [0]);
   TraceMsg(2, 0);
end;

function NewReallocMem(P: Pointer; Size: Integer): Pointer;
begin
   Inc(ReallocMemCount);
   Result := OldMemMgr.ReallocMem(P, Size);
   // Trace('ReAlloc Mem  New Size = ', [Size]);
   TraceMsg(3, size);
end;

const
   NewMem : TMemoryManager = (
      GetMem: NewGetMem;
      FreeMem: NewFreeMem;
      ReallocMem: NewReallocMem);

procedure SetNewMemMgr;
begin
   GetMemoryManager(OldMemMgr);
   SetMemoryManager(NewMem);
end;

var
   a,b : integer;

initialization
   SetNewMemMgr;
finalization
   a := GetMemCount;
   b := FreeMemCount;
   // if a<>b then raise Exception.Create(Format('GetMem = %d  FreeMem = %d', [a, b]));
end.
