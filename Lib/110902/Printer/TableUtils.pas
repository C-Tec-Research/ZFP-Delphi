unit TableUtils;

interface

uses
  SysUtils,
  Classes,
  DB,
  DBTables,
  ClipBrd,
  Controls,
  Variants;

{
   Assumptions:

   - The first field that has "Required = True" is assumed to be the Primary Key
}

type
   TIECallback = procedure(RecordNum: integer; const Msg: string; DS: TDataSet) of object;
   TEachTableProc = procedure(Table: TTable) of object;

   // Iterating Tables
   procedure ForEachTableIn(Owner: TComponent; CallBack: TEachTableProc);

   // General String
   procedure FindReplace(var s: string; const Find, Rep: string);

   // Import / Export
   function  GetNumVisFields(DS: TDataSet): integer;
   function  GetVisibleField(DS: TDataSet; Index: integer): TField;
   procedure ExportTableToExcel(DS: TDataSet);
   procedure ExportTableToClipboard(DS: TDataSet);
   procedure ExportTableToStringList(DS: TDataSet; SL: TStringList; Callback: TIECallback);
   procedure ImportTableFromStringList(DS: TDataSet; SL: TStringList; Callback: TIECallback);

   // Primary Key
   function  GetRequiredField(DataSet: TDataSet): TField;
   function  GetLastPK(Table: TTable): integer;


implementation

uses ComObj, Dialogs, ImportError;

procedure FindReplace(var s: string; const Find, Rep: string);
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


function GetNumVisFields(DS: TDataSet): integer;
var
   i : integer;
begin
   Result := 0;
   for i := 0 to DS.FieldCount-1 do begin
      if DS.Fields[i].Visible then Result := Result + 1;
   end;
end;


function GetVisibleField(DS: TDataSet; Index: integer): TField;
var
   i, j : integer;
begin
   i := 0;
   j := 0;
   Result := nil;
   while (i < DS.FieldCount) do begin
      if DS.Fields[i].Visible then begin
         if Index = j then Result := DS.Fields[i];
         j := j + 1;
      end;

      i := i + 1;
   end;
end;


procedure ExportTableToExcel(DS: TDataSet);
var
   XL       : Variant;
   Xarr     : Variant;
   Range1   : Variant;
   Range2   : Variant;
   Cell1    : Variant;
   Cell2    : Variant;
   xs, ys   : integer;
   i, j     : integer;
   s        : string;
   SlowMode : boolean;
   v        : Variant;
begin
   try
      XL := GetActiveOLEObject('Excel.Application');
   except
      XL := CreateOLEObject('Excel.Application');
   end;

   XL.Visible := True;
   XL.Workbooks.Add;

   xs := GetNumVisFields(DS);
   ys := DS.RecordCount + 1;
   XArr := VarArrayCreate([1,ys,1,xs], varVariant);

   j := 1;
   for i := 0 to xs-1 do begin
      XArr[j, i+1] := GetVisibleField(DS, i).DisplayName;
   end;
   j := j + 1;

   DS.First;
   while not DS.EOF do begin
      for i := 0 to xs-1 do begin
         s := GetVisibleField(DS, i).AsString;
         FindReplace(s, #13, '');               // Excel converts them to boxes
         XArr[j, i+1] := s;
      end;
      j := j + 1;
      DS.Next;
   end;

   Range1 := XL.Cells;

   Cell1 := Range1.Item[1,1];
   Cell2 := Range1.Item[ys,xs];

   Range2 := Range1.Range[Cell1, Cell2];

   // Determine which Version of Excel we have
   v := XL.Version;
   v := Copy(v, 1, Pos('.', v)-1);
   SlowMode := (StrToInt(v) < 8);

   if SlowMode then begin
      for i := 1 to xs do begin
         for j := 1 to ys do begin
            Range1.Item[j,i].Value := XArr[j, i];
         end;
      end;
   end else begin
      Range2.Value := XArr;
   end;

   Range2.Columns.AutoFit;
   Range2.Rows.AutoFit;
   // Range2.AutoFormat;
   // XL.Quit;
end;


procedure ExportTableToClipboard(DS: TDataSet);
var
   xs       : integer;
   i        : integer;
   t1, t2   : string;
begin
   xs := GetNumVisFields(DS);

   DS.First;
   t1 := '';
   while not DS.EOF do begin
      for i := 0 to xs-1 do begin
         t2 := GetVisibleField(DS, i).AsString;
         FindReplace(t2, #13#10, '');
         t1 := t1 + t2;
         if i < xs-1 then t1 := t1 + #9;
      end;
      t1 := t1 + #13#10;
      DS.Next;
   end;

   Clipboard.SetTextBuf(PChar(t1));
end;


procedure ExportTableToStringList(DS: TDataSet; SL: TStringList; Callback: TIECallback);
var
   i        : integer;
   ts       : TStringList;
   s        : string;
   Line     : integer;
   OldCalc  : boolean;
begin
   ts := TStringList.Create;
   SL.Clear;
   DS.First;
   Line := 0;

   OldCalc := ds.AutoCalcFields;
   ds.AutoCalcFields := False;

   // Add the Field Names
   ts.Clear;
   for i := 0 to DS.FieldCount-1 do begin
      if DS.Fields[i].FieldKind <> fkData then continue;
      ts.Add(DS.Fields[i].FieldName);
   end;
   SL.Add(ts.CommaText);

   // Add the Data
   while not DS.EOF do begin
      ts.Clear;
      for i := 0 to DS.FieldCount-1 do begin
         if DS.Fields[i].FieldKind <> fkData then continue;
         s := DS.Fields[i].AsString;
         FindReplace(s, #13#10, '\n');
         FindReplace(s, #9, '\t');
         ts.Add(s);
      end;
      SL.Add(ts.CommaText);

      Line := Line + 1;
      if Assigned(Callback) then Callback(Line, '', DS);
      DS.Next;
   end;
   ts.Free;
   ds.AutoCalcFields := OldCalc;
end;


// This function will convert a Tab delimited line of text to a comma
// delimited line of text (with quotes).

function Tab_To_Comma(const s: string): string;
const
   Q   = '"';
   TAB = #9;
var
   p        : integer;
   tmp      : string;
   FoundTab : boolean;
begin
   tmp := s;

   Result := '';
   FoundTab := False;
   repeat
      p := Pos(TAB, tmp);
      if p<>0 then begin
         FoundTab := True;
         if Copy(tmp, 1, 1)<>Q then
            Result := Result + Q + Copy(tmp, 1, p-1) + Q
         else
            Result := Result + Copy(tmp, 1, p-1);
         tmp := Copy(tmp, p+1, Length(tmp));
         if Length(tmp) > 0 then Result := Result + ',';
      end else begin
         if Length(tmp) > 0 then begin
            if Copy(tmp, 1, 1)<>Q then
               Result := Result + Q + tmp + Q
            else
               Result := Result + tmp;
         end;
      end;
   until p = 0;

   if not FoundTab then
      Result := s;
end;

procedure Basic_ImportTableFromStringList(DS: TDataSet; SL: TStringList; Callback: TIECallback);
var
   i, Line  : integer;
   ts, fs   : TStringList;
   NumErr   : integer;
   s        : string;
begin
   ts := TStringList.Create;
   fs := TStringList.Create;

   DS.Active := True;

   // Add the Field Names
   fs.CommaText := Tab_To_Comma(SL.Strings[0]);

   // Add the Data
   NumErr := 0;
   for Line := 1 to SL.Count-1 do begin
      ts.CommaText := Tab_To_Comma(SL.Strings[Line]);

      // if Assigned(Callback) then Callback(Line, 'Before Append', DS);
      DS.Append;
      // if Assigned(Callback) then Callback(Line, 'After Append', DS);
      for i := 0 to ts.Count-1 do begin
         s := ts.Strings[i];
         FindReplace(s, '\n', #13#10);
         FindReplace(s, '\t', #9);
         try
            DS.FieldByName(fs.Strings[i]).AsString := s;
         except
            on e: Exception do begin
               if ImportErrForm=nil then ImportErrForm := TImportErrForm.Create(nil);
               ImportErrForm.SetData(e.Message, SL.Strings[Line], fs, ts, i);
               if ImportErrForm.ShowModal = mrCancel then exit;
            end;
         end;
      end;
      try
         // if Assigned(Callback) then Callback(Line, 'Before Post', DS);
         DS.Post;
         if Assigned(Callback) then Callback(Line, '', DS);
      except
         on Exception do begin
            DS.Cancel;
            NumErr := NumErr + 1;
         end;
      end;
   end;
   ts.Free;
   fs.Free;

   if NumErr > 0 then begin
      ShowMessage(Format('Importing to Table %s had %d errors!', [DS.Name, NumErr]));
   end;
end;


type
   TIndexInfo = class
      Name     : string;
      Fields   : string;
      Options  : TIndexOptions;
   end;

procedure ImportTableFromStringList(DS: TDataSet; SL: TStringList; Callback: TIECallback);
var
   CurTable          : TTable;
   i                 : integer;
   OldMode           : boolean;
   OldCalc           : boolean;
   IdxList           : TList;
   IdxInfo           : TIndexInfo;
   Old_BeforeEdit    : TDataSetNotifyEvent;
   Old_BeforePost    : TDataSetNotifyEvent;
   Old_OnCalcField   : TDataSetNotifyEvent;
   Old_OnNewRecord   : TDataSetNotifyEvent;
   Old_AfterPost     : TDataSetNotifyEvent;
begin
   if DS is TTable then CurTable := DS as TTable
      else CurTable := nil;

   OldMode           := False;
   OldCalc           := False;
   IdxList           := nil;
   Old_BeforeEdit    := nil;
   Old_BeforePost    := nil;
   Old_OnCalcField   := nil;
   Old_OnNewRecord   := nil;
   Old_AfterPost     := nil;

   if CurTable<>nil then begin
      OldMode := CurTable.Exclusive;
      CurTable.Active    := False;
      CurTable.Exclusive := True;
      CurTable.Active    := True;
      IdxList := TList.Create;

      // Delete Unnecessary Indexes
      CurTable.IndexDefs.Update;
      for i := CurTable.IndexDefs.Count-1 downto 0 do begin
         try
            CurTable.DeleteIndex(CurTable.IndexDefs[i].Fields);
            // This will be skipped if DeleteIndex throws an exception (which is what I want).
            // I don't want to add it to the list if it was not successfully deleted.
            IdxInfo := TIndexInfo.Create;
            IdxInfo.Name    := CurTable.IndexDefs[i].Name;
            IdxInfo.Fields  := CurTable.IndexDefs[i].Fields;
            IdxInfo.Options := CurTable.IndexDefs[i].Options;
            IdxList.Add(IdxInfo);
         except
         end;
      end;

      Old_BeforeEdit    := CurTable.BeforeEdit;
      Old_BeforePost    := CurTable.BeforePost;
      Old_OnCalcField   := CurTable.OnCalcFields;
      Old_OnNewRecord   := CurTable.OnNewRecord;
      Old_AfterPost     := CurTable.AfterPost;

      CurTable.BeforeEdit     := nil;
      CurTable.BeforePost     := nil;
      CurTable.OnCalcFields   := nil;
      CurTable.OnNewRecord    := nil;
      CurTable.AfterPost      := nil;
      OldCalc                 := CurTable.AutoCalcFields;
      CurTable.AutoCalcFields := False;

      CurTable.EmptyTable;
   end;

   // Do the Import
   try
      Basic_ImportTableFromStringList(DS, SL, Callback);
   finally
      if CurTable<>nil then begin
         CurTable.BeforeEdit     := Old_BeforeEdit;
         CurTable.BeforePost     := Old_BeforePost;
         CurTable.OnCalcFields   := Old_OnCalcField;
         CurTable.OnNewRecord    := Old_OnNewRecord;
         CurTable.AfterPost      := Old_AfterPost;
         CurTable.AutoCalcFields := OldCalc;

         // Rebuild the Indexes
         for i := 0 to IdxList.Count-1 do with TIndexInfo(IdxList.Items[i]) do begin
            CurTable.AddIndex(Name, Fields, Options);
         end;

         CurTable.Active    := False;
         CurTable.Exclusive := OldMode;
         CurTable.Active    := True;

         for i := 0 to IdxList.Count-1 do
            TObject(IdxList.Items[i]).Free;
         IdxList.Free;
      end;
   end;
end;


procedure ForEachTableIn(Owner: TComponent; CallBack: TEachTableProc);
var
   i : integer;
   c : TComponent;
begin
   Assert(Assigned(CallBack), '');
   Assert(Owner<>nil, '');
   for i := 0 to Owner.ComponentCount-1 do begin
      c := Owner.Components[i];
      if (c is TTable) then CallBack(c as TTable);
   end;
end;


function GetRequiredField(DataSet: TDataSet): TField;
var
   i : integer;
begin
   Result := nil;
   for i := 0 to DataSet.FieldCount-1 do begin
      if DataSet.Fields[i].Required then begin
         Result := DataSet.Fields[i];
         break;
      end;
   end;
end;

function GetLastPK(Table: TTable): integer;
var
   PK       : TField;
   OldIdx   : string;
   bm       : TBookMark;
begin
   OldIdx := '';
   PK := GetRequiredField(Table);
   Assert(PK<>nil, '');

   bm := Table.GetBookmark;
   if Table.IndexFieldNames<>PK.FieldName then
      OldIdx := Table.IndexFieldNames;
   Table.IndexFieldNames := PK.FieldName;
   Table.Last;
   Result := PK.AsInteger;
   Table.GotoBookMark(bm);
   Table.FreeBookmark(bm);

   if OldIdx<>'' then Table.IndexFieldNames := OldIdx;
end;



end.
