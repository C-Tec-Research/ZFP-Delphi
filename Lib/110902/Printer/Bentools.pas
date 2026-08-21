unit BenTools;

interface

uses Classes;

type
   TOwnList = class(TList)
   public
      destructor  Destroy; override;
      procedure   ClearItems;
   end;

   THolder = class(TComponent)
   protected
      procedure   GetChildren(Proc: TGetChildProc; Root: TComponent); override;
   public
      function    ObjectText: string;
      class function CreateFromObjectText(const Text: string; Instance: THolder): THolder;
      function    AddComponent(c: TComponent): integer;
      procedure   LoadFromFile(const FileName: string);
      procedure   SaveToFile(const FileName: string);
      procedure   Fill_Strings(Strings: TStrings);
   end;

   function  DirFileSize(filename: string): integer;
   procedure RunWait(comline: string; CmdShow: integer);
   procedure SwapStr(var s1, s2: string);
   procedure SwapInt(var i1, i2: integer);
   function  IsUpCase(const s: string): boolean;
   procedure FindReplace(var s: string; Find, Rep: string);
   procedure RegisterShellExt(const Ext, ExtName, ExtDesc: string);
   function  EncodeStr(const s: string): string;
   function  DecodeStr(const s: string): string;


implementation

uses SysUtils, Windows, Forms, WaitDlg, Registry;


function DirFileSize(filename: string): integer;
var
   Rec : TSearchRec;
begin
   Result := 0;
   try
      if FindFirst(filename, faAnyFile, Rec)=0 then
         Result := Rec.Size
      else
         raise Exception.Create('Unable to find file: '+filename);
   finally
      SysUtils.FindClose(Rec);
   end;
end;

procedure RunWait(comline: string; CmdShow: integer);
var
   StartInfo   : TStartupInfo;
   ProcInfo    : TProcessInformation;
   wf          : TWaitForm;
begin
   GetStartupInfo(StartInfo);
   if CmdShow = SW_SHOW then CmdShow := SW_SHOWNA;
   StartInfo.wShowWindow := CmdShow;
   if CreateProcess(nil, PChar(comline), nil, nil, false, 0, nil, nil, StartInfo, ProcInfo)=False then
      raise Exception.Create('Could not execute ' + comline);
   // Application.BringToFront;
   wf := TWaitForm.Create(Application.MainForm);
   wf.hProc := ProcInfo.hProcess;
   wf.ProcLab.Caption := comline;
   wf.BeginWait;
   wf.Free;
end;

procedure FindReplaceSlow(var s: string; Find, Rep: string);
var
   Done : boolean;
   p    : integer;
begin
   if Pos(Find, Rep)<>0 then raise Exception.Create('Find string is in Replace string!');
   repeat
      p := Pos(Find, s);
      Done := (p = 0);
      if not Done then begin
         s := Copy(s, 1, p-1) + Rep + Copy(s, p+Length(Find), Length(s));
      end;
   until Done;
end;

procedure FindReplace(var s: string; Find, Rep: string);
var
   s2, buf, f, r  : PChar;
   Len            : integer;
   fLen, rLen     : integer;
   n, NewSize     : integer;
   pSrc, pDest    : integer;
begin
   if Pos(Find, Rep)<>0 then raise Exception.Create('Find string is in Replace string!');
   
   s2   := PChar(s);
   f    := PChar(Find);
   r    := PChar(Rep);
   fLen := Length(Find);
   rLen := Length(Rep);
   Len  := Length(s);

   n := 0;
   pSrc := 0;
   repeat
      if StrLIComp(@s2[pSrc], f, fLen) = 0 then begin
         n     := n + 1;
         pSrc  := pSrc + fLen;
      end else begin
         pSrc  := pSrc + 1;
      end;
   until pSrc >= Len;

   NewSize := Len + n * (rLen - fLen) + 1;
   buf := AllocMem(NewSize);

   pSrc  := 0;
   pDest := 0;
   while pSrc < Len do begin
      if StrLIComp(@s2[pSrc], f, fLen) = 0 then begin
         StrCopy(@buf[pDest], r);
         pDest := pDest + rLen;
         pSrc  := pSrc + fLen;
      end else begin
         buf[pDest] := s2[pSrc];
         pDest := pDest + 1;
         pSrc  := pSrc + 1;
      end;
   end;

   if pDest <> NewSize-1 then
      raise Exception.CreateFmt('Find & Replace Error: pDest = %d, NewSize-1 = %d', [pDest, NewSize-1]);

   s := buf;
   FreeMem(buf);
end;


procedure SwapInt(var i1, i2: integer);
var
   tmp : integer;
begin
   tmp := i1;
   i1 := i2;
   i2 := tmp;
end;

procedure SwapStr(var s1, s2: string);
var
   tmp : string;
begin
   tmp := s1;
   s1 := s2;
   s2 := tmp;
end;

function IsUpCase(const s: string): boolean;
var
   i : integer;
begin
   Result := True;
   for i := 1 to Length(s) do
      if s[i] <> UpCase(s[i]) then Result := False;
end;

procedure CreateRegKey(Root: HKEY; const Key, Value: string);
begin
  RegSetValue(Root, PChar(Key), REG_SZ, PChar(Value), Length(Value));
end;

procedure RegisterShellExt(const Ext, ExtName, ExtDesc: string);
var
   reg : TRegistry;
begin
   Assert(Application<>nil, 'RegisterShellExt: Application = nil');

   reg := TRegistry.Create;
   reg.RootKey := HKEY_CLASSES_ROOT;
   CreateRegKey(HKEY_CLASSES_ROOT, Ext, ExtName);
   CreateRegKey(HKEY_CLASSES_ROOT, ExtName, ExtDesc);
   reg.OpenKey(ExtName, False);
   CreateRegKey(reg.CurrentKey, 'DefaultIcon', Application.ExeName + ',0');

   CreateRegKey(reg.CurrentKey, 'Shell', '');
   reg.OpenKey('Shell', False);
   CreateRegKey(reg.CurrentKey, 'Open', '');
   reg.OpenKey('Open', False);
   CreateRegKey(reg.CurrentKey, 'Command', Application.ExeName + ' "%1"');

   reg.Free;
end;

const
   ESCN = '_ESC_SLASH_N_';
   ESCT = '_ESC_SLASH_T_';

function EncodeStr(const s: string): string;
begin
   Result := s;
   FindReplace(Result, '\n',   ESCN);
   FindReplace(Result, '\t',   ESCT);
   FindReplace(Result, #13#10, '\n');
   FindReplace(Result, #9,     '\t');
end;

function DecodeStr(const s: string): string;
begin
   Result := s;
   FindReplace(Result, '\n', #13#10);
   FindReplace(Result, '\t', #9);
   FindReplace(Result, ESCN, '\n');
   FindReplace(Result, ESCT, '\t');
end;


// ************************************************************************
// TOwnList

destructor TOwnList.Destroy;
begin
   ClearItems;
   inherited;
end;

procedure TOwnList.ClearItems;
var
   i : integer;
begin
   for i := Count-1 downto 0 do
      TObject(Items[i]).Free;
   Clear;
end;


// ************************************************************************
// THolder

procedure THolder.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i : Integer;
  c : TComponent;
begin
   for i := 0 to ComponentCount - 1 do begin
      c := Components[i];
      if not c.HasParent then Proc(c);
   end;
end;

function THolder.ObjectText: string;
var
   ms : TMemoryStream;
   ss : TStringStream;
begin
   ms := TMemoryStream.Create;
   try
      ms.WriteComponent(Self);
      ms.Position := 0;
      ss := TStringStream.Create('');
      try
         ObjectBinaryToText(ms, ss);
         Result := ss.DataString;
      finally
         ss.Free;
      end;
   finally
      ms.Free;
   end;
end;

class function THolder.CreateFromObjectText(const Text: string; Instance: THolder): THolder;
var
   ms : TMemoryStream;
   ss : TStringStream;
begin
   ss := TStringStream.Create(Text);
   try
      ss.Position := 0;
      ms := TMemoryStream.Create;
      try
         ObjectTextToBinary(ss, ms);
         ms.Position := 0;
         Result := ms.ReadComponent(Instance) as THolder;
      finally
         ms.Free;
      end;
   finally
      ss.Free;
   end;
end;

// AddComponent - Adds the component to the THolder.
// The THolder becomes the new Owner.

function THolder.AddComponent(c: TComponent): integer;
var
   oc : TComponent;
begin
   Assert(c<>nil);
   oc := c.Owner;
   if oc<>nil then oc.RemoveComponent(c);
   InsertComponent(c);
   Result := c.ComponentIndex;
end;

procedure THolder.LoadFromFile(const FileName: string);
var
   fs : TFileStream;
begin
   fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
   try
      fs.ReadComponent(Self);
   finally
      fs.Free;
   end;
end;

procedure THolder.SaveToFile(const FileName: string);
var
   fs : TFileStream;
begin
   fs := TFileStream.Create(FileName, fmCreate);
   try
      fs.WriteComponent(Self);
   finally
      fs.Free;
   end;
end;

procedure THolder.Fill_Strings(Strings: TStrings);
var
   i : integer;
begin
   Strings.Clear;
   for i := 0 to ComponentCount-1 do begin
      Strings.AddObject('', Components[i]);
   end;
end;



initialization
   if GetClass('THolder') = nil then
      Classes.RegisterClass(THolder);
end.
