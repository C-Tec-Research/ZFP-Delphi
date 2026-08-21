unit TableSet;

interface

uses SysUtils, Classes, Dialogs, DB, DBTables, TableUtils;


type
   TStatusProc = procedure(Sender: TObject; const Msg: string; LastOperation: boolean) of object;
   TSpecialIdxProc = procedure(NewDataGroup: TComponent) of object;

   // Operations on Table Set's (e.g., DataModules)
   TTableSetHelper = class(TObject)
   protected
      BackStream  : TStream;
      procedure   SendStatus(const StatMsg: string);
      procedure   EndStatus;
      procedure   RestoreCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
      procedure   BackupCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
      // For Each functions
      procedure   AddPrimaryIdx(Table: TTable);
      procedure   AddIndexes(Table: TTable);
      procedure   CreateTable(Table: TTable);
      procedure   OpenTable(Table: TTable);
      procedure   CloseTable(Table: TTable);
      procedure   DeleteTable(Table: TTable);
      procedure   ClearIdxDefsTable(Table: TTable);
      procedure   BackupTable(Table: TTable);
      procedure   BackupTableToStream(Table: TTable);
      procedure   RestoreTable(Table: TTable);
      procedure   RestoreTableFromStream(Table: TTable);
      function    CreateMemStream(const TableName: string): TMemoryStream;
   public
      ErrLog      : TStringList;
      DataGroup   : TComponent;
      StatusProc  : TStatusProc;
      IdxProc     : TSpecialIdxProc;
      ShowErrors  : boolean;
      constructor Create;
      destructor  Destroy; override;
      procedure   ForEachTable(EachProc: TEachTableProc);
      procedure   OpenTables;
      procedure   CloseTables;
      procedure   CreateTablesWithIdx;
      procedure   CreateTables;
      procedure   DeleteTables;
      procedure   ClearIdxDefsTables;
      procedure   BackupTables;        // To current directory as *.txt
      procedure   BackupTablesToStream(Stream: TStream);
      procedure   RestoreTables;
      procedure   RestoreTablesFromStream(Stream: TStream);
      procedure   RegenIndexes(Table: TTable);
      procedure   CheckErrors;
   end;


implementation


// **********************************************************************
// TTableSetHelper

constructor TTableSetHelper.Create;
begin
   inherited;
   ErrLog := TStringList.Create;
   ShowErrors := True;
end;

destructor TTableSetHelper.Destroy;
begin
   ErrLog.Free;
   inherited;
end;


// Protected Functions

procedure TTableSetHelper.SendStatus(const StatMsg: string);
begin
   if Assigned(StatusProc) then
      StatusProc(Self, StatMsg, False);
end;

procedure TTableSetHelper.EndStatus;
begin
   if Assigned(StatusProc) then
      StatusProc(Self, '', True);
end;

procedure TTableSetHelper.ForEachTable(EachProc: TEachTableProc);
begin
   Assert(DataGroup<>nil);
   ForEachTableIn(DataGroup, EachProc);
end;

procedure TTableSetHelper.OpenTable(Table: TTable);
begin
   SendStatus('Opening Table: ' + Table.TableName);
   try
      Table.IndexDefs.Clear;
      Table.FieldDefs.Clear;     // Not everyone will want this feature
      Table.Active := True;
   except
      on e: Exception do ErrLog.Add(e.Message);
   end;
end;

procedure TTableSetHelper.CloseTable(Table: TTable);
begin
   SendStatus('Closing Table: ' + Table.TableName);
   Table.Active := False;
end;

procedure TTableSetHelper.DeleteTable(Table: TTable);
begin
   SendStatus('Deleting Table: ' + Table.TableName);
   try
      Table.Active := False;
      Table.Exclusive := True;
      Table.DeleteTable;
   except
      on e: Exception do ErrLog.Add(e.Message);
   end;
end;

procedure TTableSetHelper.CreateTable(Table: TTable);
begin
   SendStatus('Creating Table: ' + Table.TableName);
   try
      Table.CreateTable;
   except
      on e: Exception do ErrLog.Add(e.Message);
   end;
end;

procedure TTableSetHelper.ClearIdxDefsTable(Table: TTable);
begin
   Table.IndexDefs.Clear;
end;

procedure TTableSetHelper.AddPrimaryIdx(Table: TTable);
var
   f  : TField;
begin
   f := GetRequiredField(Table);
   if f=nil then exit;
   Table.IndexDefs.Add(f.FieldName, f.FieldName, [ixPrimary]);
end;

procedure TTableSetHelper.AddIndexes(Table: TTable);
var
   f, pk  : TField;
   i      : integer;
begin
   pk := GetRequiredField(Table);
   if pk=nil then exit;

   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if f=pk then continue;
      if (f.DataType = ftInteger) or (f.DataType = ftDateTime) or (f.DataType = ftDate) then begin
         Table.IndexDefs.Add(f.FieldName, f.FieldName, []);
      end;
   end;
end;


procedure TTableSetHelper.BackupTable(Table: TTable);
var
   s  : TStringList;
begin
   s := TStringList.Create;
   try
      SendStatus('Backing up Table: ' + Table.TableName);
      ExportTableToStringList(Table, s, BackupCallBack);
      s.SaveToFile(Table.TableName + '.txt');
   finally
      s.Free;
   end;
end;

procedure TTableSetHelper.BackupTableToStream(Table: TTable);
var
   s  : TStringList;
   w  : TWriter;
   ms : TMemoryStream;
begin
   Table.Active := True;

   w := TWriter.Create(BackStream, 4096);
   w.WriteString(Table.TableName);

   s := TStringList.Create;
   ms := TMemoryStream.Create;
   try
      SendStatus('Backing up Table: ' + Table.TableName);
      ExportTableToStringList(Table, s, BackupCallBack);
      s.SaveToStream(ms);

      w.WriteInteger(ms.Size);
      w.FlushBuffer;
      ms.SaveToStream(BackStream);
   finally
      s.Free;
      w.Free;
      ms.Free;
   end;

   Table.Active := False;
end;

function TTableSetHelper.CreateMemStream(const TableName: string): TMemoryStream;
var
   ms    : TMemoryStream;
   rd    : TReader;
   n     : string;
   len   : integer;
begin
   ms := TMemoryStream.Create;
   Result := ms;

   BackStream.Position := 0;
   rd := TReader.Create(BackStream, 4096);
   repeat
      n := rd.ReadString;
      len := rd.ReadInteger;
      rd.FlushBuffer;

      ms.SetSize(len);
      BackStream.ReadBuffer(ms.Memory^, len);
      ms.Position := 0;

      if TableName = n then break;
   until False;

   rd.Free;
end;

procedure TTableSetHelper.RestoreTableFromStream(Table: TTable);
var
   s           : TStringList;
   ms          : TMemoryStream;
   OldActive   : boolean;
begin
   s := TStringList.Create;

   with Table do begin
      OldActive := Active;
      Active := False;
      Exclusive := True;
      EmptyTable;
      Active := False;
      Exclusive := False;
   end;

   // Load the ms Stream from the BackStream
   ms := CreateMemStream(Table.TableName);

   try
      SendStatus('Restoring Table: ' + Table.TableName);
      s.LoadFromStream(ms);
      ImportTableFromStringList(Table, s, RestoreCallback);
   finally
      s.Free;
      ms.Free;
   end;
   Table.Active := OldActive;
end;


procedure TTableSetHelper.BackupCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
begin
   if (RecordNum and 3) = 0 then
      SendStatus(Format('Backing up Table: %s   Line: %4d   %s', [DS.name, RecordNum, Msg]));
end;

procedure TTableSetHelper.RestoreCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
begin
   if (RecordNum and 3) = 0 then
      SendStatus(Format('Restoring Table: %s   Line: %4d   %s', [DS.name, RecordNum, Msg]));
end;

procedure TTableSetHelper.RestoreTable(Table: TTable);
var
   s  : TStringList;
begin
   s := TStringList.Create;
   try
      SendStatus('Restoring Table: ' + Table.TableName);
      s.LoadFromFile(Table.TableName + '.txt');
      ImportTableFromStringList(Table, s, RestoreCallback);
   finally
      s.Free;
   end;
end;


// Public functions

procedure TTableSetHelper.OpenTables;
begin
   ErrLog.Clear;
   ForEachTable(OpenTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.CloseTables;
begin
   ForEachTable(CloseTable);
   EndStatus;
end;

procedure TTableSetHelper.CreateTables;
begin
   ErrLog.Clear;

   ForEachTable(CloseTable);
   ForEachTable(CreateTable);

   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.CreateTablesWithIdx;
begin
   ErrLog.Clear;

   ForEachTable(CloseTable);
   ForEachTable(ClearIdxDefsTable);
   ForEachTable(AddPrimaryIdx);
   ForEachTable(AddIndexes);
   if Assigned(IdxProc) then IdxProc(DataGroup);
   ForEachTable(CreateTable);

   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.RegenIndexes(Table: TTable);
var
   OldEx : boolean;
   i     : integer;
begin
   Table.Active := False;
   OldEx := Table.Exclusive;
   Table.Exclusive := True;

   // Add the New Ones
   AddPrimaryIdx(Table);
   AddIndexes(Table);

   for i := 0 to Table.IndexDefs.Count-1 do begin
      Table.AddIndex(Table.IndexDefs[i].Name, Table.IndexDefs[i].Fields,
         Table.IndexDefs[i].Options);  
   end;

   Table.Exclusive := OldEx;
   Table.Active := True;
end;

procedure TTableSetHelper.DeleteTables;
begin
   ErrLog.Clear;
   ForEachTable(DeleteTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.ClearIdxDefsTables;
begin
   ForEachTable(ClearIdxDefsTable);
end;

procedure TTableSetHelper.BackupTablesToStream(Stream: TStream);
begin
   BackStream := Stream;
   ErrLog.Clear;
   ForEachTable(CloseTable);
   ForEachTable(BackupTableToStream);
   ForEachTable(OpenTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.RestoreTablesFromStream(Stream: TStream);
begin
   BackStream := Stream;
   ErrLog.Clear;
   ForEachTable(CloseTable);
   ForEachTable(RestoreTableFromStream);
   ForEachTable(OpenTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.BackupTables;
begin
   ErrLog.Clear;
   ForEachTable(BackupTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.RestoreTables;
begin
   ErrLog.Clear;
   ForEachTable(RestoreTable);
   EndStatus;
   if ShowErrors then CheckErrors;
end;

procedure TTableSetHelper.CheckErrors;
begin
   if ErrLog.Count > 0 then begin
      MessageDlg('The following errors occurred:'#13#10#13#10 +
         ErrLog.Text, mtWarning, [mbOk], 0);
   end;
end;


end.
