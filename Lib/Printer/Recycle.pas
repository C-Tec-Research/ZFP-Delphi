unit Recycle;


{ This function deletes a file in Windows 95 and moves it to the recycle bin.
  It returns True if the operation is successful, and False otherwise

  Syntax:

          x := RecycleFile(Filename);

          *** Distribute this file freely

          This unit written by John Ruzicka 75160.2376@compuserve.com
          based on code from Dennis Passmore and Steve Schafer on the
          BDELPHI forum

  }

interface

uses Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ShellAPI;

   function RecycleFile(FileToRecycle: TFilename): boolean;
   function RecycleFileEx(FileToRecycle: TFilename; Confirm: boolean): boolean;

implementation

function RecycleFile(FileToRecycle: TFilename): boolean;
begin
   Result := RecycleFileEx(FileToRecycle, True);
end;

function RecycleFileEx(FileToRecycle: TFilename; Confirm: boolean): boolean;
var
   Struct   : TSHFileOpStruct;
   tmp      : string;
   Resultval: integer;
begin
   tmp := FileToRecycle+#0#0;
   Struct.wnd := 0;
   Struct.wFunc := FO_DELETE;
   Struct.pFrom := PChar(tmp);
   Struct.pTo   := nil;
   Struct.fFlags:= FOF_ALLOWUNDO;
   if not Confirm then
      Struct.fFlags := Struct.fFlags or FOF_NOCONFIRMATION;
   Struct.fAnyOperationsAborted := false;
   Struct.hNameMappings := nil;
   try
      Resultval := ShFileOperation(Struct);
   except
      on e: Exception do begin
         e.Message := 'Tried to recycle file: ' + FileToRecycle + #13#10 + e.Message;
         raise;
      end;
   end;
   Result := (Resultval = 0);
end;


end.

