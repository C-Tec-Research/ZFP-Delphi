unit BenTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
   TNewLogEvent = procedure(Sender: TObject; const Line: string) of object;

   TBenTable = class(TTable)
   protected
      FieldVals   : TStringList;
      FLogText    : TStringList;
      FUpdateLog  : boolean;
      FPK_Field   : TField;
      WasInsert   : boolean;
      FAutoIncPK  : boolean;
      DelRecord   : string;
      FLogFile    : string;
      FOnLog      : TNewLogEvent;
      FNextPK     : integer;
      NeedIncPK   : boolean;
      NeedMeta    : boolean;
      Old_IndexName : string;
      Old_IndexFieldNames : string;
      procedure   DoAfterInsert; override;
      procedure   DoAfterPost; override;
      procedure   DoAfterDelete; override;
      procedure   DoBeforeDelete; override;
      procedure   DoBeforeEdit; override;
      procedure   DoOnNewRecord; override;
      procedure   DoAfterOpen; override;
      procedure   DoBeforeInsert; override;
      function    GetLogText: TStrings;
      procedure   SetPK_Field(f: TField);
      procedure   SetUpdateLog(b: boolean);
      procedure   SetLogFile(s: string);
      procedure   GetCurFields;
      procedure   AddLog(const s: string);
      procedure   FindNextPK;
      procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
      procedure   ParseFields(const Line: string; var KeyWord: string; Params: TStrings);
   public
      ErrLog      : TStringList;
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      function    SafeStr(const s: string): string;
      function    NormalStr(const s: string): string;
      function    ApplyLog(Log: TStrings): boolean;
      function    MachineName: string;
      function    UserName: string;
      function    SaveLogFile: boolean;
      procedure   SaveIndex;
      procedure   RestoreIndex;
      property    LogText: TStrings read GetLogText;
      property    NextPK: integer read FNextPK write FNextPK;
   published
      property    UpdateLog: boolean read FUpdateLog write SetUpdateLog default True;
      property    PK_Field: TField read FPK_Field write SetPK_Field;
      property    LogFile: string read FLogFile write SetLogFile;
      property    OnLogChange: TNewLogEvent read FOnLog write FOnLog;
      property    AutoIncPK: boolean read FAutoIncPK write FAutoIncPK default True;
   end;

procedure Register;

implementation

uses TableUtils, BenTools;


constructor TBenTable.Create(AOwner: TComponent);
begin
   inherited;
   FUpdateLog := True;
   FAutoIncPK := True;
   FieldVals  := TStringList.Create;
   FLogText   := TStringList.Create;
   ErrLog     := TStringList.Create;
end;

destructor TBenTable.Destroy;
begin
   SaveLogFile;
   FieldVals.Free;
   FLogText.Free;
   ErrLog.Free;
   inherited;
end;

procedure TBenTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
   inherited;
   if (Operation = opRemove) and (AComponent = PK_Field) then begin
      FPK_Field := nil;
   end;
end;

function TBenTable.SafeStr(const s: string): string;
begin
   Result := AdjustLineBreaks(s);
   FindReplace(Result, #13#10, '\n');
   FindReplace(Result, #9, '\t');
   Result := AnsiQuotedStr(Result, '"');
end;

function TBenTable.NormalStr(const s: string): string;
begin
   Result := s;
   FindReplace(Result, '\n', #13#10);
   FindReplace(Result, '\t', #9);
end;

function TBenTable.SaveLogFile: boolean;
var
   fs : TFileStream;
begin
   Result := False;

   if (LogFile<>'') and (LogText.Count > 0) then begin
      if FileExists(LogFile) then fs := TFileStream.Create(LogFile, fmOpenReadWrite or fmShareDenyWrite)
         else fs := TFileStream.Create(LogFile, fmCreate);
      try
         fs.Position := fs.Size;
         LogText.SaveToStream(fs);
      finally
         fs.Free;
      end;
      LogText.Clear;
      Result := True;
   end;
end;

procedure TBenTable.AddLog(const s: string);
var
   tmp : string;
begin
   if NeedMeta then begin
      NeedMeta := False;
      tmp := Format('META Machine="%s" User="%s" Date="%s"',
         [MachineName, UserName, FormatDateTime('mm/dd/yyyy hh:nn:ss ampm', Now)]);
      AddLog(tmp);
   end;

   LogText.Add(s);
   if Assigned(OnLogChange) then OnLogChange(Self, s);
end;

function TBenTable.GetLogText: TStrings;
begin
   Result := FLogText;
end;

procedure TBenTable.SetLogFile(s: string);
begin
   FLogFile := s;
end;

procedure TBenTable.SetUpdateLog(b: boolean);
begin
   if FUpdateLog<>b then begin
      Assert(not (State in dsEditModes), 'Table must not be in edit mode to change UpdateLog');
      FUpdateLog := b;

      if UpdateLog then begin
         LogText.Clear;
         NeedMeta := True;
      end;
   end;
end;

procedure TBenTable.SetPK_Field(f: TField);
var
   i     : integer;
   Match : boolean;
begin
   if f <> FPK_Field then begin
      Match := False;
      for i := 0 to FieldCount-1 do
         if Fields[i] = f then Match := True;
      Assert(Match, f.FieldName + ' is not in this DataSet');
      FPK_Field := f;
   end;
end;

procedure TBenTable.GetCurFields;
var
   i : integer;
begin
   FieldVals.Clear;
   for i := 0 to FieldCount-1 do begin
      FieldVals.AddObject(Fields[i].AsString, Fields[i]);
   end;
end;

procedure TBenTable.DoAfterInsert;
begin
   inherited;
   if UpdateLog then begin
      FieldVals.Clear;
      WasInsert := True;
   end;
end;

procedure TBenTable.DoAfterPost;
var
   i      : integer;
   f      : TField;
   Match  : boolean;
   s      : string;
begin
   inherited;

   if UpdateLog then begin
      Assert(PK_Field<>nil, 'PK_Field must not be NIL');

      if not WasInsert then s := 'UPDATE '
         else s := 'INSERT ';

      for i := 0 to FieldCount-1 do begin
         f := Fields[i];
         Match := False;
         if (i < FieldVals.Count) and (f.FieldName<>PK_Field.FieldName) then begin
            Match := f.AsString = FieldVals[i];
         end;
         if (not Match) and (f.FieldKind = fkData) then
            s := s + Format('%s=%s ', [f.FieldName, SafeStr(f.AsString)]);
      end;

      AddLog(s);
   end;
   
   if AutoIncPK and NeedIncPK then begin
      NextPK := NextPK + 1;

      Assert(PK_Field<>nil, 'PK_Field must not be NIL');
      if PK_Field.AsInteger >= NextPK then
         NextPK := PK_Field.AsInteger + 1;
   end;
end;

procedure TBenTable.DoAfterDelete;
begin
   inherited;
   if UpdateLog then begin
      AddLog(Format('DELETE %s=%s', [PK_Field.FieldName, SafeStr(DelRecord)]));
   end;
end;

procedure TBenTable.DoBeforeDelete;
begin
   inherited;
   if UpdateLog then begin
      Assert(PK_Field<>nil, 'PK_Field must not be NIL');
      DelRecord := PK_Field.AsString;
   end;
end;

procedure TBenTable.DoBeforeEdit;
begin
   NeedIncPK := False;
   inherited;
   if UpdateLog then begin
      WasInsert := False;
      GetCurFields;
   end;
end;

procedure TBenTable.FindNextPK;
var
   OldSrc : TDataSource;
   OldFlt : boolean;
begin
   // Save current Index & MasterSource
   SaveIndex;
   OldSrc := MasterSource;
   OldFlt := Filtered;

   MasterSource    := nil;
   IndexFieldNames := PK_Field.FieldName;
   Filtered        := False;
   try
      Last;
      NextPK := PK_Field.AsInteger + 1;
   finally
      RestoreIndex;
      if OldSrc<>MasterSource then MasterSource := OldSrc;
      Filtered := OldFlt;
   end;
end;

procedure TBenTable.DoBeforeInsert;
begin
   inherited;
   if AutoIncPK then begin
      Assert(PK_Field<>nil, 'PK_Field must not be NIL');
      if NextPK = -1 then FindNextPK;
   end;
end;

procedure TBenTable.DoOnNewRecord;
begin
   if AutoIncPK then begin
      Assert(PK_Field<>nil, 'PK_Field must not be NIL');
      PK_Field.AsInteger := NextPK;
      NeedIncPK := True;
   end;
   inherited;
end;

procedure TBenTable.DoAfterOpen;
begin
   FNextPK := -1;
   inherited;
end;

function TBenTable.MachineName: string;
var
   buf : array[0..MAX_PATH] of char;
   Len : DWORD;
begin
   Len := sizeof(buf);
   GetComputerName(buf, Len);
   Result := buf;
end;

function TBenTable.UserName: string;
var
   buf : array[0..MAX_PATH] of char;
   Len : DWORD;
begin
   Len := sizeof(buf);
   GetUserName(buf, Len);
   Result := buf;
end;

procedure TBenTable.ParseFields(const Line: string; var KeyWord: string; Params: TStrings);
var
   tmp      : string;
   p        : integer;
   FldName  : string;
   FldVal   : string;
   pc       : PChar;
begin
   tmp := Line;
   p := Pos(' ', tmp);
   KeyWord := UpperCase(Copy(tmp, 1, p-1));
   tmp := Copy(tmp, p+1, Length(tmp));

   // Parse the Fields
   Params.Clear;
   repeat
      p := Pos('=', tmp);
      FldName := Trim(UpperCase(Copy(tmp, 1, p-1)));
      tmp := Copy(tmp, p+1, Length(tmp));
      pc := PChar(tmp);
      FldVal := AnsiExtractQuotedStr(pc, '"');
      tmp := Trim(pc);
      Params.Values[FldName] := FldVal;
   until tmp='';
end;


function TBenTable.ApplyLog(Log: TStrings): boolean;
var
   i, j     : integer;
   FList    : TStringList;
   rc       : boolean;
   kw       : string;
   FldName  : string;
   FldVal   : string;
begin
   Assert(PK_Field<>nil, 'PK_Field must not be NIL');

   Result := True;
   SaveIndex;
   IndexFieldNames := PK_Field.FieldName;

   ErrLog.Clear;
   FList := TStringList.Create;
   for i := 0 to Log.Count-1 do begin
      if Trim(Log[i]) = '' then continue;
      ParseFields(Log[i], kw, FList);
      if kw='META' then continue;

      try
         if kw<>'INSERT' then begin
            rc := FindKey([FList.Values[PK_Field.FieldName]]);
            Assert(rc, 'Unable to find Record');
         end;

         if kw='DELETE' then begin
            Delete;
         end else begin
            if kw='INSERT' then Insert
               else Edit;
            // Apply the fields
            for j := 0 to FList.Count-1 do begin
               FldName := FList.Names[j];
               FldVal  := FList.Values[FldName];
               FieldByName(FldName).AsString := NormalStr(FldVal);
            end;
            Post;
         end;
      except
         on e: Exception do begin
            if State in dsEditModes then Cancel;
            Result := False;
            ErrLog.Add(Format('Error: %s'#13#10'Line: %s', [e.Message, Log[i]]));
         end;
      end;
   end;
   FList.Free;
   RestoreIndex;
end;

procedure TBenTable.SaveIndex;
begin
   Old_IndexName := IndexName;
   Old_IndexFieldNames := IndexFieldNames;
end;

procedure TBenTable.RestoreIndex;
begin
   IndexFieldNames := Old_IndexFieldNames;
   if (Old_IndexName <> '') then IndexName := Old_IndexName;
end;


procedure Register;
begin
  RegisterComponents('Samples', [TBenTable]);
end;

end.
