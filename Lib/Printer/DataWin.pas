unit DataWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Db, Grids, DBGrids, StdCtrls, DBCtrls, DBTables, Menus, MultFilt,
  IniFiles, BDE, AppendNavigator, Registry;

const
   // Filter Panel Constants
   COLWIDTH        = 150;
   HMARGIN         = 8;
   VMARGIN         = 4;
   MAX_COMBO_ITEMS = 16384;
   FCNAME          = 'Filter_Con_';

type
   TFilterCombo = class(TComboBox)
   protected
      MultForm    : TMultFiltForm;
   public
      Multiples   : boolean;
      DataField   : TField;      // The LOOKUP field this combobox refers to
      function    ShowMultForm: integer;
   end;

   TBuddyLabel = class(TLabel)
   public
      Buddy       : TControl;
   end;

  TDataWinForm = class(TForm)
    Panel1: TPanel;
    DBNavigator1: TAppendNavigator;
    Label1: TLabel;
    IndexCombo: TComboBox;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    FilterBut: TButton;
    FilterPanelTop: TPanel;
    TablePopupMenu: TPopupMenu;
    ExporttoExcel1: TMenuItem;
    ExporttoAscii1: TMenuItem;
    ImportTablefromAscii1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    RefreshTable1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ViewTableStructure1: TMenuItem;
    EmptyTable1: TMenuItem;
    StatusPanel: TPanel;
    StatPanel1: TPanel;
    StatPanel2: TPanel;
    ViewStatusBar1: TMenuItem;
    RefreshFilterCombos1: TMenuItem;
    Font1: TMenuItem;
    FontDialog1: TFontDialog;
    Exclusive1: TMenuItem;
    Admin1: TMenuItem;
    CreateIndex1: TMenuItem;
    DeleteIndex1: TMenuItem;
    N4: TMenuItem;
    LookupFilterPopup: TPopupMenu;
    MultFilt1: TMenuItem;
    ResetTableViewtoDefault1: TMenuItem;
    NumFilterPopup: TPopupMenu;
    FilteronRange1: TMenuItem;
    ScrollBox1: TScrollBox;
    FilterPanel: TPanel;
    Splitter1: TSplitter;
    ExpandBut: TButton;
    View1: TMenuItem;
    N5: TMenuItem;
    Find1: TMenuItem;
    FindNext1: TMenuItem;
    RegenerateIndexes1: TMenuItem;
    ClearBut: TButton;
    TableDefaults1: TMenuItem;
    RebuildIndexes1: TMenuItem;
    FindDialog1: TFindDialog;
    Advanced1: TMenuItem;
    CreateTransLog1: TMenuItem;
    ImportTransLog1: TMenuItem;
    CloseTransLog1: TMenuItem;
    N6: TMenuItem;
    SaveTransDialog: TSaveDialog;
    ImportTransDialog: TOpenDialog;
    ViewTransLog1: TMenuItem;
    UpdateVersion1: TMenuItem;
    FindFilter1: TMenuItem;
    procedure IndexComboChange(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FilterButClick(Sender: TObject);
    procedure FilterPanelResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RefreshFilterCombos1Click(Sender: TObject);
    procedure ExporttoAscii1Click(Sender: TObject);
    procedure RefreshTable1Click(Sender: TObject);
    procedure ViewTableStructure1Click(Sender: TObject);
    procedure EmptyTable1Click(Sender: TObject);
    procedure TablePopupMenuPopup(Sender: TObject);
    procedure ViewStatusBar1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure Exclusive1Click(Sender: TObject);
    procedure CreateIndex1Click(Sender: TObject);
    procedure DeleteIndex1Click(Sender: TObject);
    procedure MultFilt1Click(Sender: TObject);
    procedure ResetTableViewtoDefault1Click(Sender: TObject);
    procedure DBGrid1ColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FilteronRange1Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure ExpandButClick(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure RegenerateIndexes1Click(Sender: TObject);
    procedure ClearButClick(Sender: TObject);
    procedure TableDefaults1Click(Sender: TObject);
    procedure ImportAscii1Click(Sender: TObject);
    procedure RebuildIndexes1Click(Sender: TObject);
    procedure StatPanel1DblClick(Sender: TObject);
    procedure ExporttoExcel1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure CreateTransLog1Click(Sender: TObject);
    procedure CloseTransLog1Click(Sender: TObject);
    procedure ImportTransLog1Click(Sender: TObject);
    procedure ViewTransLog1Click(Sender: TObject);
    procedure UpdateVersion1Click(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FindFilter1Click(Sender: TObject);
  protected
    NumFilter     : integer;
    DoFirst       : boolean;
    TableDefs     : TStringList;
    OldOnNewRec   : TDataSetNotifyEvent;
    TotRec        : integer;
    MemoForm      : TForm;
    FindFilt      : boolean;
    Keywords      : string;
    procedure  InitIndexCombo;
    procedure  InitFilterControls;
    procedure  LayoutFilterPanel;
    procedure  Fill_Filter_Combo(cb: TFilterCombo);
    procedure  TableFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure  FindFilterFunc(DataSet: TDataSet; var Accept: Boolean);
    procedure  FilterComboChange(Sender: TObject);
    procedure  FilterLabelClick(Sender: TObject);
    procedure  DateFilterLabelClick(Sender: TObject);
    procedure  StringFilterLabelClick(Sender: TObject);
    procedure  NumLabelClick(Sender: TObject);
    procedure  NumKeyPress(Sender: TObject; var Key: char);
    procedure  UpdateNumRecords;
    procedure  FormHint(Sender: TObject);
    function   SetExclusiveMode(Mode: boolean): boolean;
    procedure  AddLookupFilter(f: TField; FilterNum: integer);
    procedure  AddDateFilter(f: TField; FilterNum: integer);
    procedure  AddNumFilter(f: TField; FilterNum: integer);
    procedure  AddStrFilter(f: TField; FilterNum: integer);
    function   NumVisibleFields: integer;
    procedure  StatCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
    procedure  Empty_CurTable;
    procedure  LoadDefaults;
    procedure  SaveDefaults;
    procedure  TableNewRecord(DataSet: TDataSet);
    procedure  DoFind;
    procedure  SaveTransactionSettings;
    procedure  LoadTransactionSettings;
    function   CreateRegIni: TRegIniFile;
    procedure  Set_IndexCombo_To_Current;
    procedure  SaveCurrentIndex;
    procedure  RestoreCurrentIndex;
    procedure  Refresh_Lookup_Cache;
  public
    CurTable            : TTable;
    IgnoreTitleClick    : boolean;
    DefColList          : TStringList;
    FiltList      : TStringList;
    procedure  AssignTable(Table: TTable);
    procedure  Refresh_Filter_Combos;
    function   GetFilterDesc: TStringList;
    procedure  SaveColumnSettings;
    procedure  RestoreColumnSettings;
    function   GetColSetName: string;
    procedure  SaveDefaultColumnSettings;
    procedure  RefreshCurTable;
    function   TextInRecord: boolean;
  end;

implementation

{$R *.DFM}

uses TableUtils, TableStructure, CreateIndexFrm, DateFilter, NumFilter,
  StringFilter, TableDefaults, BenTable, StringListDlg, Restruct,
  FindFilter;

procedure TDataWinForm.AssignTable(Table: TTable);
begin
   // Restore any settings for the "Old" CurTable
   if CurTable<>nil then begin
      SaveColumnSettings;
      SaveTransactionSettings;
      SaveCurrentIndex;
      CurTable.Filtered := False;
      CurTable.OnFilterRecord := nil;
      CurTable.OnNewRecord := OldOnNewRec;
   end;

   // Set to the new value
   CurTable := Table;
   DataSource1.DataSet := CurTable;

   if CurTable<>nil then begin
      SaveDefaultColumnSettings;
      RestoreColumnSettings;
      RestoreCurrentIndex;
      LoadTransactionSettings;
      LoadDefaults;
      CurTable.Filtered := True;
      CurTable.OnFilterRecord := TableFilterRecord;
      OldOnNewRec := CurTable.OnNewRecord;
      CurTable.OnNewRecord := TableNewRecord;
   end;

   InitIndexCombo;
   InitFilterControls;
   RefreshCurTable;
   Refresh_Lookup_Cache;
end;

procedure TDataWinForm.InitIndexCombo;
var
   i : integer;
   s : string;
begin
   IndexCombo.Items.Clear;
   if CurTable=nil then exit;

   CurTable.IndexDefs.Update;
   for i := 0 to CurTable.IndexDefs.Count-1 do begin
      s := CurTable.IndexDefs[i].Name;
      if s = '' then
         s := CurTable.IndexDefs[i].Fields;
      if s<>CurTable.IndexDefs[i].Fields then
         s := s + ' (' + CurTable.IndexDefs[i].Fields + ')';
      IndexCombo.Items.Add(s);
   end;
   Set_IndexCombo_To_Current;
end;

procedure TDataWinForm.Set_IndexCombo_To_Current;
var
   i, j : integer;
begin
   if CurTable=nil then exit;

   j := -1;
   for i := 0 to CurTable.IndexDefs.Count-1 do
      if CurTable.IndexDefs[i].Name = CurTable.IndexName then
         j := i;

   if j<>-1 then
      IndexCombo.ItemIndex := j;
end;

procedure TDataWinForm.IndexComboChange(Sender: TObject);
var
   i : integer;
begin
   i := IndexCombo.ItemIndex;
   if i = -1 then exit;
   CurTable.IndexDefs.Update;
   CurTable.IndexName := CurTable.IndexDefs[i].Name;
end;

procedure TDataWinForm.DBGrid1ColumnMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
begin
   IgnoreTitleClick := True;
end;

procedure TDataWinForm.DBGrid1TitleClick(Column: TColumn);
var
   f : TField;
   s : string;
   i : integer;
   b : boolean;
begin
   if IgnoreTitleClick then begin
      // This is used to avoid a fake click when the user just wants
      // to move a column.
      IgnoreTitleClick := False;
      exit;
   end;

   f := Column.Field;
   s := f.FieldName;

   if f.FieldKind = fkLookup then begin
      s := f.KeyFields;
   end;

   b := False;
   for i := 0 to CurTable.IndexDefs.Count-1 do begin
      if CurTable.IndexDefs[i].Fields = s then begin
         CurTable.IndexName := CurTable.IndexDefs[i].Name;
         IndexCombo.ItemIndex := i;
         b := True;
      end;
   end;

   if not b then
      MessageDlg('No Index exists for field: ' + s, mtWarning, [mbOK], 0);
end;

procedure TDataWinForm.FilterButClick(Sender: TObject);
begin
   FilterPanelTop.Visible := not FilterPanelTop.Visible;

   if FilterPanelTop.Visible then
      FilterBut.Caption := '&Hide'
   else
      FilterBut.Caption := '&Show'
end;

procedure TDataWinForm.Fill_Filter_Combo(cb: TFilterCombo);
var
   ds          : TDataSet;
   f           : TField;
   IDFldName   : string;
   TextFldName : string;
   Num         : integer;
begin
   cb.Items.Clear;
   f  := cb.DataField;
   ds := f.LookupDataSet;
   IDFldName   := f.LookupKeyFields;
   TextFldName := f.LookupResultField;

   if ds.Active=False then exit;

   ds.First;
   Num := 0;
   while not ds.EOF do begin
      Num := Num + 1;
      if Num > MAX_COMBO_ITEMS then break;
      
      cb.Items.AddObject(ds.FieldByName(TextFldName).AsString,
         pointer(ds.FieldByName(IDFldName).AsInteger));
      ds.Next;
   end;

   cb.Multiples := False;
   if cb.MultForm<>nil then
      cb.MultForm.ListBox1.Items.Assign(cb.Items);
end;

procedure TDataWinForm.AddNumFilter(f: TField; FilterNum: integer);
var
   lb       : TLabel;
   ne       : TNumFilter;
begin
   lb := TLabel.Create(FilterPanel);
   lb.Name           := 'Filter_Label_'+IntToStr(FilterNum);
   lb.Parent         := FilterPanel;
   lb.Caption        := f.DisplayName;
   lb.Hint           := 'Double click to clear this filter';
   lb.OnDblClick     := NumLabelClick;

   ne := TNumFilter.Create(FilterPanel);
   ne.Name           := FCNAME+IntToStr(FilterNum);
   ne.Parent         := FilterPanel;
   ne.Width          := COLWIDTH - HMARGIN;
   ne.DataField      := f;
   ne.Hint           := 'Enter a number to filter on (and press Enter), or right click for a filter range';
   ne.OnKeyPress     := NumKeyPress;
   ne.AutoSelect     := True;
   ne.PopupMenu      := NumFilterPopup;
   ne.UpdateText;

   lb.FocusControl := ne;
end;

procedure TDataWinForm.AddLookupFilter(f: TField; FilterNum: integer);
var
   lb       : TLabel;
   cb       : TFilterCombo;
begin
   lb := TLabel.Create(FilterPanel);
   lb.Name           := 'Filter_Label_'+IntToStr(FilterNum);
   lb.Parent         := FilterPanel;
   lb.Caption        := f.DisplayName;
   lb.Hint           := 'Double click to clear this filter';
   lb.OnDblClick     := FilterLabelClick;

   cb := TFilterCombo.Create(FilterPanel);
   cb.Name           := FCNAME+IntToStr(FilterNum);
   cb.Parent         := FilterPanel;
   cb.Width          := COLWIDTH - HMARGIN;
   cb.Style          := csDropDownList;
   cb.DropDownCount  := 12;
   cb.DataField      := f;
   cb.OnChange       := FilterComboChange;
   cb.Hint           := 'Select an item to Filter the table, right click for Multiple filters';
   cb.PopupMenu      := LookupFilterPopup;
   Fill_Filter_Combo(cb);

   lb.FocusControl := cb;
end;

procedure TDataWinForm.AddDateFilter(f: TField; FilterNum: integer);
var
   lb       : TBuddyLabel;
   fc       : TFilterDate;
begin
   lb := TBuddyLabel.Create(FilterPanel);
   lb.Name           := 'Filter_Label_'+IntToStr(FilterNum);
   lb.Parent         := FilterPanel;
   lb.Caption        := f.DisplayName;
   lb.Hint           := 'Double click to clear this filter';
   lb.OnDblClick     := DateFilterLabelClick;

   fc := TFilterDate.Create(FilterPanel);
   fc.Name           := FCNAME+IntToStr(FilterNum);
   fc.Parent         := FilterPanel;
   fc.Width          := COLWIDTH - HMARGIN;
   fc.Height         := 21;
   fc.Alignment      := taLeftJustify;
   fc.Hint           := 'Double click to change this filter';
   fc.DataField      := f;
   fc.OnDblClick     := DateFilterLabelClick;
   fc.MinDate        := Now;
   fc.MaxDate        := Now;
   fc.UpdateCaption;

   lb.Buddy := fc;
end;

procedure TDataWinForm.AddStrFilter(f: TField; FilterNum: integer);
var
   lb       : TBuddyLabel;
   fc       : TFilterString;
begin
   lb := TBuddyLabel.Create(FilterPanel);
   lb.Name           := 'Filter_Label_'+IntToStr(FilterNum);
   lb.Parent         := FilterPanel;
   lb.Caption        := f.DisplayName;
   lb.Hint           := 'Double click to clear this filter';
   lb.OnDblClick     := StringFilterLabelClick;

   fc := TFilterString.Create(FilterPanel);
   fc.Name           := FCNAME+IntToStr(FilterNum);
   fc.Parent         := FilterPanel;
   fc.Width          := COLWIDTH - HMARGIN;
   fc.Height         := 21;
   fc.Alignment      := taLeftJustify;
   fc.Hint           := 'Double click to change this filter';
   fc.DataField      := f;
   fc.OnDblClick     := StringFilterLabelClick;
   fc.UpdateCaption;

   lb.Buddy := fc;
end;

procedure TDataWinForm.InitFilterControls;
var
   i, j     : integer;
   f        : TField;
begin
   FilterPanel.Visible := False;

   // Clear out any old controls
   for i := FilterPanel.ControlCount-1 downto 0 do begin
      FilterPanel.Controls[i].Free;
   end;
   if CurTable=nil then exit;

   j := 0;
   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if not f.Visible then continue;

      StatPanel2.Caption := Format('  Creating a filter control for field: %s', [f.DisplayLabel]);
      StatPanel2.Update;

      if f.FieldKind = fkLookup then begin
         AddLookupFilter(f, j);
         j := j + 1;
      end;

      if f.DataType = ftDateTime then begin
         AddDateFilter(f, j);
         j := j + 1;
      end;

      if (f.DataType = ftInteger) or (f.DataType = ftFloat) then begin
         AddNumFilter(f, j);
         j := j + 1;
      end;

      if (f.FieldKind <> fkLookup) and (f.FieldKind <> fkCalculated) and
         ((f.DataType = ftString) {or (f.DataType = ftMemo)} ) then begin
         AddStrFilter(f, j);
         j := j + 1;
      end;

   end;
   NumFilter := j;

   if NumFilter = 0 then begin
      FilterPanel.Visible := False;
      FilterBut.Visible := False;
   end else begin
      FilterPanel.Visible := True;
      FilterBut.Visible := True;
      FilterBut.Enabled := True;
      FilterBut.Caption := '&Hide';
      LayoutFilterPanel;
      ScrollBox1.HorzScrollBar.Visible := False;
   end;

   StatPanel2.Caption := '  Done creating Filter controls';
   StatPanel2.Update;
end;

procedure TDataWinForm.LayoutFilterPanel;
var
   i        : integer;
   lb       : TControl;
   cb       : TControl;
   CurTop   : integer;
   CurLeft  : integer;
   MaxTop   : integer;
begin
   CurTop  := VMARGIN;
   CurLeft := HMARGIN;
   MaxTop  := CurTop;
   for i := 0 to NumFilter-1 do begin
      lb := FilterPanel.FindComponent('Filter_Label_'+IntToStr(i)) as TControl;
      lb.Top      := CurTop;
      lb.Left     := CurLeft;

      cb := FilterPanel.FindComponent(FCNAME+IntToStr(i)) as TControl;
      cb.Top      := CurTop + lb.Height;
      cb.Left     := CurLeft;

      MaxTop  := CurTop + lb.Height + cb.Height;

      CurLeft := CurLeft + COLWIDTH;
      if CurLeft + COLWIDTH > FilterPanel.Width then begin
         CurLeft := HMARGIN;
         CurTop := CurTop + lb.Height + cb.Height + VMARGIN;
      end;
   end;

   FilterPanel.Height := MaxTop + VMARGIN;
end;

procedure TDataWinForm.Refresh_Filter_Combos;
var
   i  : integer;
   fc : TControl;
   cb : TFilterCombo;
begin
   for i := 0 to NumFilter-1 do begin
      fc := FilterPanel.FindComponent(FCNAME+IntToStr(i)) as TControl;
      if fc is TFilterCombo then begin
         cb := fc as TFilterCombo;
         Fill_Filter_Combo(cb);
      end;
   end;
end;

procedure TDataWinForm.FilterPanelResize(Sender: TObject);
begin
   LayoutFilterPanel;
end;

procedure TDataWinForm.FormCreate(Sender: TObject);
begin
   NumFilter := 0;
   Assert(not Assigned(Application.OnHint), 'Application.OnHint is not nil');
   Application.OnHint := FormHint;
   DefColList := TStringList.Create;
   TableDefs := TStringList.Create;
   FiltList := TStringList.Create;
end;

procedure TDataWinForm.FormDestroy(Sender: TObject);
var
   i : integer;
begin
   AssignTable(nil);
   for i := 0 to DefColList.Count-1 do
      DefColList.Objects[i].Free;
   DefColList.Free;
   TableDefs.Free;
   FiltList.Free;
end;

procedure TDataWinForm.LoadDefaults;
var
   fn : string;
begin
   TableDefs.Clear;
   if CurTable=nil then exit;
   fn := ExtractFilePath(Application.ExeName) + CurTable.TableName + '.def';
   if FileExists(fn) then
      TableDefs.LoadFromFile(fn);
end;

procedure TDataWinForm.SaveDefaults;
var
   fn : string;
begin
   if CurTable=nil then exit;
   fn := ExtractFilePath(Application.ExeName) + CurTable.TableName + '.def';
   try
      TableDefs.SaveToFile(fn);
   except
   end;
end;

procedure TDataWinForm.RefreshFilterCombos1Click(Sender: TObject);
var
   i : integer;
begin
   Refresh_Lookup_Cache;
   Refresh_Filter_Combos;

   for i := 0 to CurTable.FieldCount-1 do begin
      if CurTable.Fields[i].FieldKind = fkLookup then
         CurTable.Fields[i].RefreshLookupList;
   end;
end;

procedure TDataWinForm.UpdateNumRecords;
begin
   if CurTable<>nil then
      StatPanel1.Caption := Format('Num Records = %d', [CurTable.RecordCount])
   else
      StatPanel1.Caption := 'No Table Selected';
end;

procedure TDataWinForm.FilterComboChange(Sender: TObject);
var
   cb    : TFilterCombo;
   idx   : integer;
begin
   cb := Sender as TFilterCombo;
   cb.Multiples := False;
   idx := cb.ItemIndex;
   cb.Style := csDropDownList;
   cb.ItemIndex := idx;

   RefreshCurTable;
end;

procedure TDataWinForm.StringFilterLabelClick(Sender: TObject);
var
   fs : TFilterString;
   sf : TStringFilterForm;
begin
   if (Sender is TBuddyLabel) then begin
      fs := (Sender as TBuddyLabel).Buddy as TFilterString;
      fs.UseMin    := False;
      fs.UseMax    := False;
      fs.IncBlanks := False;
      fs.Mode      := fsNone;
      fs.UpdateCaption;
   end;

   if (Sender is TFilterString) then begin
      sf := TStringFilterForm.Create(Self);
      sf.fs := (Sender as TFilterString);
      sf.ShowModal;
   end;

   RefreshCurTable;
end;

procedure TDataWinForm.DateFilterLabelClick(Sender: TObject);
var
   df : TDateFilterForm;
   fd : TFilterDate;
begin
   if (Sender is TBuddyLabel) then begin
      fd := (Sender as TBuddyLabel).Buddy as TFilterDate;
      fd.UseMin := False;
      fd.UseMax := False;
      fd.IncBlanks := True;
      fd.UpdateCaption;
   end;

   if (Sender is TFilterDate) then begin
      df := TDateFilterForm.Create(Self);
      try
         df.fd := (Sender as TFilterDate);
         df.ShowModal;
      except
         on e: Exception do begin
            e.Message := 'User does not have latest Common Controls DLL?' +
               #13#10#13#10 + e.Message;
            df.Free;
            raise;
         end;
      end;
   end;

   RefreshCurTable;
end;

procedure TDataWinForm.FilterLabelClick(Sender: TObject);
var
   cb : TFilterCombo;
begin
   cb := (Sender as TLabel).FocusControl as TFilterCombo;
   cb.ItemIndex := -1;
   cb.OnChange(cb);
end;

procedure TDataWinForm.TableFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
   i, j     : integer;
   idx      : integer;
   FilterID : integer;
   fc       : TControl;
   cb       : TFilterCombo;
   fd       : TFilterDate;
   fs       : TFilterString;
   ne       : TNumFilter;
   f, f2    : TField;
   MatchOne : boolean;
   v        : double;
begin
   Accept := True;

   for i := 0 to NumFilter-1 do begin
      fc := FilterPanel.FindComponent(FCNAME+IntToStr(i)) as TControl;

      if fc is TFilterString then begin
         fs := fc as TFilterString;
         if not fs.IsStrInFilter(fs.DataField.AsString) then begin
            Accept := False;
            exit;
         end;
      end;

      if fc is TFilterDate then begin
         fd := fc as TFilterDate;

         if not fd.IsDateInFilter(fd.DataField.AsDateTime) then begin
            Accept := False;
            exit;
         end;
      end;

      if fc is TNumFilter then begin
         ne := fc as TNumFilter;

         v := 0;
         if ne.DataField.DataType = ftInteger then v := ne.DataField.AsInteger;
         if ne.DataField.DataType = ftFloat then v := ne.DataField.AsFloat;

         if not ne.IsNumInFilter(v) then begin
            Accept := False;
            exit;
         end;
      end;

      if fc is TFilterCombo then begin
         cb := fc as TFilterCombo;

         f := cb.DataField;
         f2 := f.DataSet.FieldByname(f.KeyFields);

         if cb.Multiples then begin
            // We have a multiple-selection filter
            MatchOne := False;
            for j := 0 to cb.Items.Count-1 do begin
               FilterID := integer(cb.Items.Objects[j]);
               if cb.MultForm.ListBox1.Selected[j] and (FilterID = f2.AsInteger) then begin
                  MatchOne := True;
                  break;
               end;
            end;
            if not MatchOne then begin
               Accept := False;
               exit;
            end;
         end else begin
            // We have a single filter
            idx := cb.ItemIndex;
            if idx = -1 then continue;
            FilterID := integer(cb.Items.Objects[idx]);
            if f2.AsInteger<>FilterID then begin
               Accept := False;
               exit;
            end;
         end;
      end;

   end;
end;

procedure TDataWinForm.ExporttoAscii1Click(Sender: TObject);
var
   s        : TStringList;
   OldFilt  : boolean;
begin
   if SaveDialog1.Execute then begin
      s := TStringList.Create;
      Screen.Cursor := crHourGlass;
      DataSource1.Enabled := False;
      OldFilt := CurTable.Filtered;
      CurTable.Filtered := False;
      try
         ExportTableToStringList(CurTable, s, nil);
         s.SaveToFile(SaveDialog1.FileName);
      finally
         s.Free;
         Screen.Cursor := crDefault;
         DataSource1.Enabled := True;
         CurTable.Filtered := OldFilt;
      end;
   end;
end;

procedure TDataWinForm.RefreshTable1Click(Sender: TObject);
begin
   RefreshCurTable;
   Refresh_Lookup_Cache;
   InitIndexCombo;
   StatPanel2.Caption := '  Table Refreshed';
end;

procedure TDataWinForm.StatCallback(RecordNum: integer; const Msg: string; DS: TDataSet);
begin
   if (RecordNum and 3) = 0 then begin
      StatPanel2.Caption := Format('  Imported Record %d of %d from %s   %s',
         [RecordNum, TotRec, DS.Name, Msg]);
      StatPanel2.Update;
   end;
end;

procedure TDataWinForm.ViewTableStructure1Click(Sender: TObject);
var
   tsf : TTableStructureForm;
begin
   tsf := TTableStructureForm.Create(Self);
   tsf.Table := CurTable;
   tsf.ShowModal;
   tsf.Free; 
end;

procedure TDataWinForm.EmptyTable1Click(Sender: TObject);
var
   rc : integer;
begin
   rc := MessageDlg('Are you SURE you want to empty the Table?',
      mtWarning, mbYesNoCancel, 0);
   if rc<>mrYes then exit;

   Empty_CurTable;
end;

procedure TDataWinForm.Empty_CurTable;
begin
   CurTable.Active := False;
   CurTable.Exclusive := True;

   CurTable.EmptyTable;

   CurTable.Active := False;
   CurTable.Exclusive := False;
   CurTable.Active := True;
end;

procedure TDataWinForm.TablePopupMenuPopup(Sender: TObject);
begin
   ViewStatusBar1.Checked := StatusPanel.Visible;
   Exclusive1.Checked := CurTable.Exclusive;
   FindNext1.Enabled := FindDialog1.FindText<>'';

   CreateTransLog1.Enabled := (CurTable is TBenTable) and (not TBenTable(CurTable).UpdateLog);
   CloseTransLog1.Enabled  := (CurTable is TBenTable) and (TBenTable(CurTable).UpdateLog);
   ViewTransLog1.Enabled   := CloseTransLog1.Enabled;
   ImportTransLog1.Enabled := CurTable is TBenTable;
end;

procedure TDataWinForm.ViewStatusBar1Click(Sender: TObject);
begin
   StatusPanel.Visible := not StatusPanel.Visible;
end;

procedure TDataWinForm.Font1Click(Sender: TObject);
begin
   FontDialog1.Font := DBGrid1.Font;
   if FontDialog1.Execute then
      DBGrid1.Font := FontDialog1.Font;
end;

function TDataWinForm.SetExclusiveMode(Mode: boolean): boolean;
begin
   Result := True;
   try
      CurTable.Active := False;
      CurTable.Exclusive := Mode;
      CurTable.Active := True;
   except
      // If there is an error try to reopen without exclusive mode
      on e: Exception do begin
         MessageDlg('Exclusive Access Failed!'#13#10+e.Message, mtError, [mbOk], 0);
         CurTable.Active := False;
         CurTable.Exclusive := False;
         CurTable.Active := True;
         Result := False;
      end;
   end;
end;


procedure TDataWinForm.Exclusive1Click(Sender: TObject);
begin
   Exclusive1.Checked := not Exclusive1.Checked;
   SetExclusiveMode(Exclusive1.Checked);
end;

procedure TDataWinForm.CreateIndex1Click(Sender: TObject);
var
   cif      : TCreateIndexForm;
   OldExcl  : boolean;
begin
   // Get Exclusive Mode
   OldExcl := CurTable.Exclusive;
   if not CurTable.Exclusive then
      if not SetExclusiveMode(True) then begin
         MessageDlg('Failed to get Exclusive Mode.'#13#10'Unable to Create Index',
            mtError, [mbOK], 0);
         exit;
      end;

   // Create the Index
   cif := TCreateIndexForm.Create(Self);
   cif.Table := CurTable;
   if cif.ShowModal = mrOK then begin
      InitIndexCombo;
   end;
   cif.Free;

   if not OldExcl then
      SetExclusiveMode(False);
end;

procedure TDataWinForm.FormHint(Sender: TObject);
var
   s : string;
begin
   s := Application.Hint;
   if s<>'' then begin
      StatPanel2.Caption := s;
   end;
end;

procedure TDataWinForm.DeleteIndex1Click(Sender: TObject);
var
   OldExcl  : boolean;
   IdxName  : string;
begin
   if MessageDlg('Are you SURE you want to delete the current Index?',
      mtWarning, mbYesNoCancel, 0)<>mrYes then exit;

   // Get Exclusive Mode
   OldExcl := CurTable.Exclusive;
   if not CurTable.Exclusive then
      if not SetExclusiveMode(True) then begin
         MessageDlg('Failed to get Exclusive Mode.'#13#10'Unable to Delete Index',
            mtError, [mbOK], 0);
         exit;
      end;

   // Find the index name by fields
   CurTable.IndexDefs.Update;
   IdxName := CurTable.IndexName;

   // Delete the index
   if IdxName<>'' then begin
      CurTable.IndexFieldNames := '';
      CurTable.DeleteIndex(IdxName);
      CurTable.IndexDefs.Update;
      MessageDlg('Deleted Index: ' + IdxName, mtInformation, [mbOK], 0);
      InitIndexCombo;
      RefreshCurTable;
   end else begin
      MessageDlg('No Index to delete (Can''t delete a primary index)', mtInformation, [mbOK], 0);
   end;

   if not OldExcl then
      SetExclusiveMode(False);
end;

procedure TDataWinForm.RegenerateIndexes1Click(Sender: TObject);
var
   OldExcl  : boolean;
begin
   // Get Exclusive Mode
   OldExcl := CurTable.Exclusive;
   if not CurTable.Exclusive then
      SetExclusiveMode(True);

   // Regenerate Indexes
   Screen.Cursor := crHourGlass;
   try
      Check(DbiRegenIndexes(CurTable.Handle));
   finally
      Screen.Cursor := crDefault;
      if not OldExcl then SetExclusiveMode(False);
   end;
end;

function TFilterCombo.ShowMultForm: integer;
begin
   if MultForm=nil then begin
      MultForm := TMultFiltForm.Create(Self);
      MultForm.ListBox1.Items.Assign(Items);
   end;
   Result := MultForm.ShowModal;
   if Result = mrOK then begin
      Multiples := True;
   end;
end;

procedure TDataWinForm.MultFilt1Click(Sender: TObject);
var
   cb : TFilterCombo;
   i  : integer;
   t  : TStringList;
begin
   cb := LookupFilterPopup.PopupComponent as TFilterCombo;

   if cb.ShowMultForm = mrOK then begin
      cb.Style := csDropDown;
      // cb.Text := 'MULTIPLE: ';
      t := TStringList.Create;
      with cb.MultForm.ListBox1 do
         for i := 0 to Items.Count-1 do
            if Selected[i] then
               t.Add(Items[i]);
      cb.Text := t.CommaText;
      t.Free;

      RefreshCurTable;
   end;
end;

function TDataWinForm.GetFilterDesc: TStringList;
var
   sl : TStringList;
   s  : string;
   i  : integer;
   fc : TControl;
   fd : TFilterDate;
   cb : TFilterCombo;
   ne : TNumFilter;
begin
   sl := TStringList.Create;
   Result := sl;

   for i := 0 to NumFilter-1 do begin
      fc := FilterPanel.FindComponent(FCNAME+IntToStr(i)) as TControl;

      if fc is TFilterDate then begin
         fd := fc as TFilterDate;

         if fd.UseMin or fd.UseMax or (not fd.IncBlanks) then begin
            s := Format('%s: %s', [fd.DataField.DisplayName, fd.Caption]);
            sl.Add(s);
         end;
      end;

      if fc is TNumFilter then begin
         ne := fc as TNumFilter;

         if ne.UseMin or ne.useMax or (not ne.IncBlanks) then begin
            s := Format('%s: %s', [ne.DataField.DisplayName, ne.Text]);
            sl.Add(s);
         end;
      end;

      if fc is TFilterCombo then begin
         cb := fc as TFilterCombo;

         if (cb.ItemIndex<>-1) or (cb.Multiples) then begin
            s := Format('%s: %s', [cb.DataField.DisplayName, cb.Text]);
            sl.Add(s);
         end;
      end;
   end;

   if FindFilt then begin
      s := Format('Keyword: %s', [Keywords]);
      sl.Add(s);
   end;
end;

procedure TDataWinForm.ResetTableViewtoDefault1Click(Sender: TObject);
var
   i        : integer;
   DefCols  : TMemoryStream;
begin
   i := DefColList.IndexOf(CurTable.TableName);
   if i=-1 then exit;
   DefCols := TMemoryStream(DefColList.Objects[i]);

   with DBGrid1.Columns do begin
      DefCols.Position := 0;
      LoadFromStream(DefCols);
      RebuildColumns;   // This really makes everything before this useless.
      for i := Count-1 downto 0 do
         if not Items[i].Field.Visible then
            Items[i].Free; 
   end;
end;

function TDataWinForm.GetColSetName: string;
begin
   Assert(CurTable<>nil);
   Result := ExtractFilePath(Application.ExeName) + CurTable.TableName + '.col';
end;

procedure TDataWinForm.SaveColumnSettings;
var
   fs : TFileStream;
begin
   if CurTable=nil then exit;

   try
      fs := TFileStream.Create(GetColSetName, fmCreate or fmOpenWrite or fmShareExclusive);
      DBGrid1.Columns.SaveToStream(fs);
      fs.Free;
   except
   end;
end;

function TDataWinForm.NumVisibleFields: integer;
var
   i : integer;
   f : TField;
begin
   Result := 0;
   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if f.Visible then Result := Result + 1;
   end;
end;

procedure TDataWinForm.RestoreColumnSettings;
var
   fn  : string;
   fs  : TFileStream;
begin
   fn := GetColSetName;

   if FileExists(fn) then begin
      fs := TFileStream.Create(GetColSetName, fmOpenRead or fmShareExclusive);
      DBGrid1.Columns.LoadFromStream(fs);
      fs.Free;
   end;

   // Check if new database fields have been added.
   // If they have, Reset the column view (because the new fields will be missiing)
   if DBGrid1.Columns.Count <> NumVisibleFields then begin
      ResetTableViewtoDefault1Click(nil);
      StatPanel2.Caption := ' Reset column view settings because database has changed!';
   end;
end;

procedure TDataWinForm.SaveDefaultColumnSettings;
var
   i        : integer;
   DefCols  : TMemoryStream;
begin
   i := DefColList.IndexOf(CurTable.TableName);
   if i<>-1 then exit;

   DefCols := TMemoryStream.Create;

   with DBGrid1.Columns do begin
      State := csCustomized;
      RebuildColumns;
      // Get rid of invisible columns
      for i := Count-1 downto 0 do
         if (Items[i].Field <> nil) and (not Items[i].Field.Visible) then
            Items[i].Free;
      SaveToStream(DefCols);
   end;

   DefColList.AddObject(CurTable.TableName, DefCols);
end;


procedure TDataWinForm.NumLabelClick(Sender: TObject);
var
   ne : TNumFilter;
begin
   ne := (Sender as TLabel).FocusControl as TNumFilter;
   ne.UseMin := False;
   ne.UseMax := False;
   ne.IncBlanks := True;
   ne.UpdateText;

   RefreshCurTable;
end;

procedure TDataWinForm.NumKeyPress(Sender: TObject; var Key: char);
var
   ne : TNumFilter;
begin
   ne := Sender as TNumFilter;

   if Key = #13 then begin
      ne.UseOneVal;

      ne.UpdateText;
      Key := #0;
      RefreshCurTable;
   end;
end;


procedure TDataWinForm.FilteronRange1Click(Sender: TObject);
var
   ne : TNumFilter;
begin
   ne := NumFilterPopup.PopupComponent as TNumFilter;

   if NumFilterForm=nil then
      NumFilterForm := TNumFilterForm.Create(Self);

   NumFilterForm.ne := ne;
   if NumFilterForm.ShowModal=mrOK then begin
      RefreshCurTable;
   end;
end;

procedure TDataWinForm.DBGrid1DblClick(Sender: TObject);
var
   m  : TDBMemo;
   f  : TField;
   ds : TDataSet;
begin
   if DBGrid1.SelectedField = nil then exit;
   f := DBGrid1.SelectedField;

   if f.DataType = ftBoolean then begin
      ds := f.DataSet;
      if not (ds.State in dsEditModes) then ds.Edit;
      f.AsBoolean := not f.AsBoolean;
   end;

   if f.DataType = ftMemo then begin
      if MemoForm=nil then begin
         MemoForm := TForm.Create(Self);
         MemoForm.Caption   := 'Edit Field: ' + f.FieldName;
         MemoForm.Position  := poScreenCenter;
         MemoForm.Width     := 600;
         MemoForm.Height    := 400;

         m := TDBMemo.Create(MemoForm);
         m.Name       := 'Memo1';
         m.Align      := alClient;
         m.Parent     := MemoForm;
         m.ScrollBars := ssVertical;
         m.WordWrap   := True;
      end;

      m := MemoForm.FindComponent('Memo1') as TDBMemo;
      m.DataSource := DataSource1;
      m.DataField  := f.FieldName;

      MemoForm.ShowModal;
   end;
end;

procedure TDataWinForm.ScrollBox1Resize(Sender: TObject);
begin
   FilterPanel.Width := ScrollBox1.ClientWidth;
   FilterPanel.Width := ScrollBox1.ClientWidth;  // Twice incase scrollbar appears
end;

procedure TDataWinForm.ExpandButClick(Sender: TObject);
begin
   if FilterPanelTop.Height=45 then begin
      FilterPanelTop.ClientHeight := FilterPanel.Height+2;
   end else begin
      FilterPanelTop.Height := 45;
   end;
end;

function TDataWinForm.TextInRecord: boolean;
var
   i           : integer;
   f           : TField;
   MatchCase   : boolean;
begin
   Result := False;
   MatchCase := frMatchCase in FindDialog1.Options;

   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if (f.DataType = ftString) or (f.DataType = ftMemo) then
         if MatchCase then
            Result := Result or (Pos(FindDialog1.FindText, f.AsString)<>0)
         else
            Result := Result or (Pos(UpperCase(FindDialog1.FindText), UpperCase(f.AsString))<>0);
      if Result then break;
   end;
end;

procedure TDataWinForm.DoFind;
var
   Found  : boolean;
   Rec    : integer;
   Done   : boolean;
   MoveUp : boolean;
begin
   Screen.Cursor := crHourGlass;
   DataSource1.DataSet := nil;
   try
      MoveUp := frDown in FindDialog1.Options;
      Found := False;
      Rec   := 0;

      repeat
         if DoFirst then
            if MoveUp then CurTable.Next
               else CurTable.Prior;

         if MoveUp then Done := CurTable.EOF
            else Done := CurTable.BOF;
         if Done then break;

         Rec := Rec + 1;
         StatPanel2.Caption := '  Searching for "' + FindDialog1.FindText + '"  in record ' + IntToStr(Rec);
         StatPanel2.Update;
         Found := TextInRecord;
         if Found then break;

         DoFirst := True;
      until False;

      if not Found then begin
         Beep;
         StatPanel2.Caption := '  Not Found!';
         // FindDialog1.CloseDialog;
      end else begin
         StatPanel2.Caption := '  Found!';
      end;

   finally
      DataSource1.DataSet := CurTable;
      Screen.Cursor := crDefault;
   end;
end;

procedure TDataWinForm.Find1Click(Sender: TObject);
begin
   DoFirst := False;
   FindDialog1.Execute;
end;

procedure TDataWinForm.FindNext1Click(Sender: TObject);
begin
   DoFirst := True;
   DoFind;
end;

procedure TDataWinForm.RefreshCurTable;
begin
   if CurTable=nil then exit;
   
   Screen.Cursor := crHourGlass;
   try
      StatPanel1.Caption := 'Num Records = ?';
      StatPanel2.Caption := '  Table Refresh';
      Update;
      CurTable.Refresh;

      if StatPanel1.BevelInner = bvRaised then begin
         StatPanel2.Caption := '  Counting Records';
         StatPanel2.Update;
         UpdateNumRecords;
      end;

      StatPanel2.Caption := '  Table Refreshed';
   finally
      Screen.Cursor := crDefault;
   end;
end;


procedure TDataWinForm.ClearButClick(Sender: TObject);
begin
   KeyWords := '';
   FindFilt := False;
   CurTable.OnFilterRecord := TableFilterRecord;
   InitFilterControls;
   RefreshCurTable;
end;

procedure TDataWinForm.TableDefaults1Click(Sender: TObject);
begin
   if TabDefaultsForm=nil then TabDefaultsForm := TTabDefaultsForm.Create(Self);
   
   TabDefaultsForm.Defaults.Assign(TableDefs);
   TabDefaultsForm.SetTable(CurTable);
   if TabDefaultsForm.SetDefaults then begin
      TableDefs.Assign(TabDefaultsForm.Defaults);
      SaveDefaults;
   end;
end;

procedure TDataWinForm.TableNewRecord(DataSet: TDataSet);
var
   i     : integer;
   fn    : string;
   Val   : string;
   f     : TField;
begin
   if Assigned(OldOnNewRec) then OldOnNewRec(DataSet);

   // Apply the User's Defaults
   for i := 0 to TableDefs.Count-1 do begin
      fn := TableDefs.Names[i];
      Val := TableDefs.Values[fn];

      f := CurTable.FieldByName(fn);
      Assert(f<>nil);

      if f.FieldKind = fkLookup then
         f := CurTable.FieldByName(f.KeyFields);

      f.AsString := Val;
   end;
end;


procedure TDataWinForm.ImportAscii1Click(Sender: TObject);
var
   s : TStringList;
begin
   if MessageDlg('Importing data may OVERWRITE existing data!'#13#10+
      'Do you want to continue?', mtWarning, mbYesNoCancel, 0)<>mrYes then exit;

   DataSource1.DataSet := nil;
   s := TStringList.Create;
   Screen.Cursor := crHourGlass;

   try
      if OpenDialog1.Execute then begin
         s.LoadFromFile(OpenDialog1.FileName);
         TotRec := s.Count - 1;
         ImportTableFromStringList(CurTable, s, StatCallback);
      end;
   finally
      s.Free;
      DataSource1.DataSet := CurTable;
      Screen.Cursor := crDefault;
   end;

end;

procedure TDataWinForm.RebuildIndexes1Click(Sender: TObject);
var
   f, pk  : TField;
   i      : integer;
begin
   SetExclusiveMode(True);

   // Create the new indexes
   pk := GetRequiredField(CurTable);
   if pk=nil then exit;

   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if f=pk then continue;
      if (f.DataType = ftInteger) or (f.DataType = ftDateTime) or (f.DataType = ftDate) then begin
         StatPanel2.Caption := Format('  Recreating Index: %s', [f.FieldName]);
         StatPanel2.Update;
         CurTable.AddIndex(f.FieldName, f.FieldName, []);
      end;
   end;

   InitIndexCombo;
end;


procedure TDataWinForm.StatPanel1DblClick(Sender: TObject);
begin
   if StatPanel1.BevelInner = bvLowered then
      StatPanel1.BevelInner := bvRaised
   else
      StatPanel1.BevelInner := bvLowered;

   RefreshCurTable;
end;

procedure TDataWinForm.ExporttoExcel1Click(Sender: TObject);
begin
   ExportTableToExcel(CurTable);
end;

procedure TDataWinForm.FindDialog1Find(Sender: TObject);
begin
   FindNext1Click(Sender);
end;

procedure TDataWinForm.CreateTransLog1Click(Sender: TObject);
begin
   SaveTransDialog.FileName := (CurTable as TBenTable).LogFile;
   if SaveTransDialog.Execute then begin
      with (CurTable as TBenTable) do begin
         LogFile   := SaveTransDialog.FileName;
         UpdateLog := True;
         if FileExists(LogFile) then DeleteFile(LogFile);
      end;
   end;
end;

procedure TDataWinForm.CloseTransLog1Click(Sender: TObject);
begin
   with (CurTable as TBenTable) do begin
      UpdateLog := False;
      SaveLogFile;
   end;
end;

procedure TDataWinForm.ImportTransLog1Click(Sender: TObject);
var
   sl : TStringList;
begin
   if ImportTransDialog.Execute then begin
      with (CurTable as TBenTable) do begin
         sl := TStringList.Create;
         try
            sl.LoadFromFile(ImportTransDialog.FileName);
            ApplyLog(sl);
         finally
            sl.Free;
         end;
      end;
   end;
end;

function TDataWinForm.CreateRegIni: TRegIniFile;
var
   f : string;
begin
   Assert(Application<>nil);
   f := ExtractFileName(Application.Title);
   f := ChangeFileExt(f, '');
   Result := TRegIniFile.Create('Software\' + f);
end;

procedure TDataWinForm.SaveTransactionSettings;
var
   ini : TRegIniFile;
begin
   if CurTable is TBenTable then begin
      ini := CreateRegIni;
      ini.WriteBool('Transactions', 'Enabled', TBenTable(CurTable).UpdateLog);
      ini.WriteString('Transactions', 'LogFile', TBenTable(CurTable).LogFile);
      ini.Free;
   end;
end;

procedure TDataWinForm.LoadTransactionSettings;
var
   ini : TRegIniFile;
begin
   if CurTable is TBenTable then begin
      ini := CreateRegIni;
      TBenTable(CurTable).UpdateLog := ini.ReadBool('Transactions', 'Enabled', False);
      TBenTable(CurTable).LogFile   := ini.ReadString('Transactions', 'LogFile', '');
      ini.Free;
   end;
end;

procedure TDataWinForm.ViewTransLog1Click(Sender: TObject);
var
   bt : TBenTable;
begin
   if StringListForm=nil then StringListForm := TStringListForm.Create(Self);
   with StringListForm.DataMemo.Lines do begin
      Clear;
      bt := CurTable as TBenTable;
      if FileExists(bt.LogFile) then LoadFromFile(bt.LogFile);
      AddStrings(bt.LogText);
   end;
   StringListForm.ShowModal;
end;

procedure TDataWinForm.SaveCurrentIndex;
var
   ini : TRegIniFile;
begin
   Assert(CurTable<>nil);

   ini := CreateRegIni;
   ini.WriteString('Default Index', CurTable.TableName, CurTable.IndexName);
   ini.Free;
end;

procedure TDataWinForm.RestoreCurrentIndex;
var
   ini : TRegIniFile;
begin
   Assert(CurTable<>nil);

   ini := CreateRegIni;
   CurTable.IndexName := ini.ReadString('Default Index', CurTable.TableName, CurTable.IndexName);
   ini.Free;
end;


procedure TDataWinForm.UpdateVersion1Click(Sender: TObject);
var
   OldExcl  : boolean;
begin
   // Get Exclusive Mode
   OldExcl := CurTable.Exclusive;
   if not CurTable.Exclusive then
      SetExclusiveMode(True);

   // Regenerate Indexes
   Screen.Cursor := crHourGlass;
   try
      AlterVersion(CurTable, 7);
   finally
      Screen.Cursor := crDefault;
      if not OldExcl then SetExclusiveMode(False);
   end;
end;

procedure TDataWinForm.Refresh_Lookup_Cache;
var
   i : integer;
   f : TField;
begin
   if CurTable=nil then exit;

   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if f.LookupCache = True then
         f.RefreshLookupList;
   end;
end;


procedure TDataWinForm.Splitter1Moved(Sender: TObject);
const
   FUDGE = 38;
var
   h : integer;
begin
   h := ((FilterPanelTop.ClientHeight - VMARGIN) + FUDGE div 2) div FUDGE;
   if h < 1 then h := 1;
   h := h * FUDGE;
   FilterPanelTop.Height := h + VMARGIN * 2;
end;

procedure TDataWinForm.FindFilter1Click(Sender: TObject);
var
   ff    : TFindFilterForm;
begin
   ff := TFindFilterForm.Create(Self);
   ff.dw := Self;
   ff.FindEdit.Text := FindDialog1.FindText;
   
   ff.ShowModal;
   if not ff.Cancel then begin
      CurTable.OnFilterRecord := FindFilterFunc;
      FindFilt := True;
      Keywords := Keywords + FindDialog1.FindText + ' ';
      RefreshCurTable;
   end;

   ff.Free;
end;

procedure TDataWinForm.FindFilterFunc(DataSet: TDataSet; var Accept: Boolean);
var
   pkf   : TField;
   pk    : string;
   idx   : integer;
begin
   pkf := GetRequiredField(CurTable);
   Assert(pkf<>nil, 'No Primary Key!');
   pk := pkf.AsString;

   Accept := FiltList.Find(pk, idx);

   if Accept then
      TableFilterRecord(DataSet, Accept);
end;


end.
