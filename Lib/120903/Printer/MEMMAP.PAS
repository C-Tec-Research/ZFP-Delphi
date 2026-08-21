unit MemMap;

interface

uses Windows, SysUtils, Classes;

type
  EMMFError = class(Exception);

  TMemMapFile = class
  private
    FFileName: String;
    FSize: Longint;
    FFileSize: Longint;
    FFileMode: Integer;
    FFileHandle: Integer;
    FMapHandle: Integer;
    FData: PByte;
    FMakeNull: Boolean;
    FMapNow: Boolean;
    procedure AllocFileHandle;
    procedure AllocFileMapping;
    procedure AllocFileView;
    function GetSize: Longint;
  public
    constructor Create(FileName: String; FileMode: integer; Size: integer;
                       MakeNull, MapNow: Boolean); virtual;
    destructor Destroy; override;
    procedure FreeMapping;
    property Data: PByte read FData;
    property Size: Longint read GetSize;
    property FileName: String read FFileName;
    property FileHandle: Integer read FFileHandle;
    property MapHandle: Integer read FMapHandle;
  end;

implementation

constructor TMemMapFile.Create(FileName: String; FileMode: integer;
                               Size: integer; MakeNull, MapNow: Boolean);
{ Creates Memory Mapped view of FileName file.  }
{ FileName: Full pathname of file. }
{ FileMode: Use fmXXX constants. }
{ Size: size of memory map.  Pass zero as the size to use the file's own size. }
{ MakeNull: Indicates whether to put a null terminator at the end of the }
{           file for use as a PChar. If this param is True, Size is ignored }
var
  TmpPtr: PChar;
begin
  if (MakeNull) and (FileMode <> fmOpenReadWrite) then
    raise EMMFError.Create('Must open in fmOpenReadWrite mode to create' +
                           ' null terminator');
  FMapNow := MapNow;
  FFileName := FileName;
  FFileMode := FileMode;
  FMakeNull := MakeNull;
  AllocFileHandle;
  FFileSize := GetFileSize(FFileHandle, Nil);   // assume file is < 2 gig
  if MakeNull then FSize := FFileSize + 1 else FSize := Size;
  try
    AllocFileMapping;
  except
    on EMMFError do begin
      CloseHandle(FFileHandle);  // close file handle on error
      FFileHandle := 0;          // set handle back to 0 for clean up
      raise;                     // re-raise exception
    end;
  end;
  if FMapNow then begin
    AllocFileView;
    if MakeNull then begin
      PByte(TmpPtr) := FData;
      inc(TmpPtr, FFileSize + 1);
      TmpPtr^ := #0;
    end;
  end;
end;

destructor TMemMapFile.Destroy;
begin
  if FMakeNull then
    SetFilePointer(FFileHandle, FFileSize, Nil, FILE_BEGIN);
  if FFileHandle <> 0 then
    CloseHandle(FFileHandle);
  if FMapHandle <> 0 then CloseHandle(FMapHandle);
  FreeMapping;
  inherited Destroy;
end;

procedure TMemMapFile.FreeMapping;
begin
  if FData <> Nil then begin
    UnmapViewOfFile(FData);
    FData := Nil;
  end;
end;

function TMemMapFile.GetSize: Longint;
begin
  if FSize <> 0 then
    Result := FSize
  else
    Result := FFileSize;
end;

procedure TMemMapFile.AllocFileHandle;
{ creates or opens disk file before creating memory mapped file }
begin
  if FFileMode = fmCreate then
    FFileHandle := FileCreate(FFileName)
  else
    FFileHandle := FileOpen(FFileName, FFileMode);
  if FFileHandle < 0 then
    raise EMMFError.Create('Failed to open or crate file');
end;

procedure TMemMapFile.AllocFileMapping;
var
  ProtAttr: DWORD;
begin
  if FFileMode = fmOpenRead then     // obtain correct protection attribute
    ProtAttr := Page_ReadOnly
  else
    ProtAttr := Page_ReadWrite;
  { attempt to create file mapping of disk file.  Raise exception on error. }
  FMapHandle := CreateFileMapping(FFileHandle, Nil, ProtAttr, 0, FSize, Nil);
  if FMapHandle = 0 then
    raise EMMFError.Create('Failed to create file mapping');
end;

procedure TMemMapFile.AllocFileView;
var
  Access: Longint;
begin
  if FFileMode = fmOpenRead then    // obtain correct
    Access := File_Map_Read
  else
    Access := File_Map_All_Access;
  FData := MapViewOfFile(FMapHandle, Access, 0, 0, FSize);
  if FData = Nil then
    raise EMMFError.Create('Failed to map view of file');
end;



end.
