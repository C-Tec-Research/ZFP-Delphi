unit GrafWiz;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TeeProcs, TeEngine, Chart, ExtCtrls, StdCtrls, DB, Series, Menus, DBTables,
  ComCtrls, TeeFunci, FormSettings;

type
  TGrafWizForm = class(TForm)
    ToolPanel: TPanel;
    Chart1: TChart;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    TimePerCombo: TComboBox;
    FieldCombo: TComboBox;
    CreateGraphBut: TButton;
    TimeCombo: TComboBox;
    TabSheet2: TTabSheet;
    RemEmptyBox: TCheckBox;
    TabSheet3: TTabSheet;
    PrintBut: TButton;
    Button1: TButton;
    PrintDialog1: TPrintDialog;
    ShowMarksBox: TCheckBox;
    RefreshBut: TButton;
    Timer1: TTimer;
    GraphTypeCombo: TComboBox;
    Label4: TLabel;
    GradientBox: TCheckBox;
    View3DBox: TCheckBox;
    RefreshLab: TLabel;
    CreateLab: TLabel;
    FormSettings1: TFormSettings;
    procedure FormShow(Sender: TObject);
    procedure CreateGraphButClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PrintButClick(Sender: TObject);
    procedure ComboChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure OptionChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure RefreshButClick(Sender: TObject);
    procedure GradientBoxClick(Sender: TObject);
    procedure View3DBoxClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  protected
    NumSeries  : integer;
    SeriesLab  : TStringList;
    NumPoints  : integer;
    PointLab   : TStringList;
    Data       : TStringList;
    ShowSeries : TBits;
    function   GetData(Series, X: integer): double;
    function   CalcPeriod(Date: TDateTime): TDateTime;
    procedure  ClearData;
    procedure  AddData(Series: integer; const TimePer: string; NumAdd: double);
    procedure  RemoveEmptySeries;
    procedure  SetStat(s: string);
  public
    CurTable   : TTable;
    FilterDesc : string;
    DefaultDataField : string;
    procedure  CalcGraphData;
    procedure  CalcGraphData_Lookup;
    procedure  CalcGraphData_Data;
    procedure  DrawGraph;
    property   Stat: string write SetStat;
  end;

var
  GrafWizForm: TGrafWizForm;

implementation

{$R *.DFM}

type
   TDblArray = array[0..0] of double;
   PDblArray = ^TDblArray;

procedure TGrafWizForm.FormCreate(Sender: TObject);
begin
   TimePerCombo.ItemIndex := 2;
   GraphTypeCombo.ItemIndex := 0;
   SeriesLab  := TStringList.Create;
   PointLab   := TStringList.Create;
   Data       := TStringList.Create;
   ShowSeries := TBits.Create;
end;

procedure TGrafWizForm.FormDestroy(Sender: TObject);
begin
   SeriesLab.Free;
   PointLab.Free;
   ClearData;
   Data.Free;
   ShowSeries.Free;
end;

procedure TGrafWizForm.FormShow(Sender: TObject);
var
   i  : integer;
   f  : TField;
begin
   PageControl1.ActivePage := TabSheet1;
   
   // Fill in the FieldCombo
   FieldCombo.Items.Clear;
   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if (f.DataType = ftInteger) and (f.Required) then continue; // Primary Key
      if not ((f.FieldKind = fkLookup) or
         ((f.FieldKind = fkData) and ((f.DataType = ftInteger) or
         (f.DataType = ftFloat)))) then continue;
      if not f.Visible then continue;
      FieldCombo.Items.AddObject(f.DisplayLabel, f);
   end;

   // Fill in the TimeCombo
   TimeCombo.Items.Clear;
   for i := 0 to CurTable.FieldCount-1 do begin
      f := CurTable.Fields[i];
      if (f.DataType <> ftDate) and (f.DataType <> ftDateTime) then continue;
      if not f.Visible then continue;
      TimeCombo.Items.AddObject(f.DisplayLabel, f);
   end;
   TimeCombo.ItemIndex := 0;

   if FieldCombo.Items.Count > 0 then
      FieldCombo.ItemIndex := 0;
   Chart1.Title.Text.Text := '** Initializing Graph **';
   // Timer1.Enabled := True;
   Timer1.Enabled := False;

   FormSettings1.LoadSettings;

   i := FieldCombo.Items.IndexOf(DefaultDataField);
   if i = -1 then begin
      if FieldCombo.Items.Count > 0 then
         FieldCombo.ItemIndex := 0;
   end;
   ComboChange(nil);
end;

procedure TGrafWizForm.CreateGraphButClick(Sender: TObject);
var
   tmp : string;
begin
   Screen.Cursor := crHourGlass;
   try
      if FilterDesc<>'' then tmp := #13#10 + 'Filter = ' + FilterDesc;
      tmp := FieldCombo.Text + ' (' + TimePerCombo.Text + ')' + tmp;
      Chart1.Title.Text.Text := tmp;

      CalcGraphData;
      RemoveEmptySeries;
      DrawGraph;
   finally
      Screen.Cursor := crDefault;
   end;

   CreateLab.Visible := False;
   CreateGraphBut.Enabled := False;
end;

function TGrafWizForm.CalcPeriod(Date: TDateTime): TDateTime;
var
   m, d, y: word;
begin
   case TimePerCombo.ItemIndex of
      0  : Result := Trunc(Date);
      1  : Result := Trunc(Date) - (DayOfWeek(Date) - 1);
      2  : begin DecodeDate(Date, y, m, d); Result := EncodeDate(y, m, 1); end;
      3  : begin DecodeDate(Date, y, m, d); m := ((m-1) div 3) * 3 + 1; Result := EncodeDate(y, m, 1); end;
      4  : begin DecodeDate(Date, y, m, d); Result := EncodeDate(y, 1, 1); end;
      5  : begin DecodeDate(Date, y, m, d); Result := EncodeDate(1, 1, 1); end;
   else
      Result := 0;
   end;
end;

procedure TGrafWizForm.ClearData;
var
   i : integer;
begin
   // Clear out the Old Data
   for i := 0 to Data.Count-1 do begin
      FreeMem(pointer(Data.Objects[i]));
   end;
   Data.Clear;
end;

procedure TGrafWizForm.AddData(Series: integer; const TimePer: string; NumAdd: double);
var
   i     : integer;
   idx   : integer;
   ary   : PDblArray;
begin
   idx := Data.IndexOf(TimePer);
   if idx = -1 then begin
      GetMem(ary, sizeof(double) * NumSeries);
      for i := 0 to NumSeries-1 do
         ary^[i] := 0;
      idx := Data.AddObject(TimePer, TObject(ary));
   end;

   // TRACE('TimePer = %-15s   Series = %3d   Idx = %3d   Data Count = %3d', [TimePer, Series, idx, Data.Count]);

   ary := PDblArray(Data.Objects[idx]);
   Assert(Series < NumSeries);
   Assert(Series >= 0);
   ary^[Series] := ary^[Series] + NumAdd;
end;

function TGrafWizForm.GetData(Series, X: integer): double;
var
   ary   : PDblArray;
begin
   ary := PDblArray(Data.Objects[X]);
   Result := ary^[Series];
end;

procedure TGrafWizForm.CalcGraphData;
var
   i           : integer;
   DataField   : TField;
begin
   i := FieldCombo.ItemIndex;
   if i=-1 then exit;
   DataField := FieldCombo.Items.Objects[i] as TField;
   Assert(DataField<>nil);

   if DataField.FieldKind = fkLookup then
      CalcGraphData_Lookup
   else
      CalcGraphData_Data;
end;

procedure TGrafWizForm.CalcGraphData_Data;
var
   DataField   : TField;
   TimeField   : TField;
   Tab         : TTable;
   OldIdx      : string;
   RecNum      : integer;
   TimeLab     : string;
begin
   Stat := 'Calculating Graph Data';

   if (FieldCombo.ItemIndex = -1) or (TimeCombo.ItemIndex = -1) then exit;

   DataField := FieldCombo.Items.Objects[FieldCombo.ItemIndex] as TField;
   Assert(DataField<>nil);
   TimeField := TimeCombo.Items.Objects[TimeCombo.ItemIndex] as TField;
   Assert(TimeField<>nil);

   SeriesLab.Add(DataField.DisplayLabel);
   NumSeries := 1;
   ClearData;

   // Calculate the new Data
   with DataField.DataSet do begin
      Tab := TTable(DataField.DataSet);
      OldIdx := Tab.IndexFieldNames;
      Tab.IndexFieldNames := TimeField.FieldName;

      First;
      RecNum := 0;
      while not EOF do begin
         RecNum := RecNum + 1;
         if (RecNum and 15) = 0 then Stat := Format('Processing Record %d', [RecNum]);

         if not TimeField.IsNull then begin
            TimeLab := FormatDateTime('mm/dd/yy', CalcPeriod(TimeField.AsDateTime));
            if TimePerCombo.ItemIndex = 5 then TimeLab := 'ALL';
            AddData(0, TimeLab, DataField.AsFloat);
         end;
         Next;
      end;
      Stat := Chart1.Hint;

      Tab.IndexFieldNames := OldIdx;
   end;
   NumPoints := Data.Count;

   // Init the Point Labels
   PointLab.Clear;
   PointLab.AddStrings(Data);
end;

procedure TGrafWizForm.CalcGraphData_Lookup;
var
   DataField   : TField;
   TimeField   : TField;
   IDField     : TField;
   ResField    : TField;
   KeyField    : TField;
   IDMap       : TStringList;
   TimeLab     : string;
   idx         : integer;
   OldIdx      : string;
   Tab         : TTable;
   RecNum      : integer;
begin
   Stat := 'Calculating Graph Data';

   NumSeries := 0;
   if (FieldCombo.ItemIndex = -1) or (TimeCombo.ItemIndex = -1) then exit;

   DataField := FieldCombo.Items.Objects[FieldCombo.ItemIndex] as TField;
   Assert(DataField<>nil);
   TimeField := TimeCombo.Items.Objects[TimeCombo.ItemIndex] as TField;
   Assert(TimeField<>nil);

   // Create the Lookup ID Map
   SeriesLab.Clear;
   IDMap := TStringList.Create;
   with DataField.LookupDataSet do begin
      IDField  := FieldByName(DataField.LookupKeyFields);
      ResField := FieldByName(DataField.LookupResultField);

      First;
      while not EOF do begin
         IDMap.Add(IntToStr(IDField.AsInteger));
         SeriesLab.Add(ResField.AsString);
         Next;
      end;
   end;
   NumSeries := IDMap.Count;

   ClearData;

   // Calculate the new Data
   with DataField.DataSet do begin
      Tab := TTable(DataField.DataSet);
      OldIdx := Tab.IndexFieldNames;
      Tab.IndexFieldNames := TimeField.FieldName;

      KeyField := FieldByName(DataField.KeyFields);

      First;
      RecNum := 0;
      while not EOF do begin
         RecNum := RecNum + 1;
         if (RecNum and 15) = 0 then Stat := Format('Processing Record %d', [RecNum]);

         if not TimeField.IsNull then begin
            TimeLab := FormatDateTime('mm/dd/yy', CalcPeriod(TimeField.AsDateTime));
            if TimePerCombo.ItemIndex = 5 then TimeLab := 'ALL';
            idx := IDMap.IndexOf(IntToStr(KeyField.AsInteger));
            if idx<>-1 then AddData(idx, TimeLab, 1);
         end;
         Next;
      end;
      Stat := Chart1.Hint;

      Tab.IndexFieldNames := OldIdx;
   end;
   NumPoints := Data.Count;

   // Init the Point Labels
   PointLab.Clear;
   PointLab.AddStrings(Data);

   IDMap.Free;
end;

procedure TGrafWizForm.RemoveEmptySeries;
var
   Series, Point  : integer;
   Tot            : double;
begin
   ShowSeries.Size := NumSeries;

   for Series := 0 to NumSeries-1 do begin
      if RemEmptyBox.Checked then begin
         Tot := 0;
         for Point := 0 to NumPoints-1 do
            Tot := Tot + GetData(Series, Point);
         ShowSeries.Bits[Series] := Tot > 0;
      end else begin
         ShowSeries.Bits[Series] := True;
      end;
   end;
end;

procedure TGrafWizForm.DrawGraph;
var
   i, j     : integer;
   Series   : TChartSeries;
begin
   Chart1.RemoveAllSeries;

   // Add the new Series
   for i := 0 to NumSeries-1 do begin
      case GraphTypeCombo.ItemIndex of
         1  : Series := TLineSeries.Create(nil);
         2  : Series := TAreaSeries.Create(nil);
         3  : Series := TPointSeries.Create(nil);
      else
         Series := TBarSeries.Create(nil);
      end;

      Chart1.AddSeries(Series);

      Series.Title := SeriesLab[i];
      Series.Marks.Visible := ShowMarksBox.Checked;
      Series.Marks.Style := smsValue; // smsLabelValue;
      Series.Active := ShowSeries.Bits[i];
   end;

   // Fill in the Data
   for j := 0 to NumSeries-1 do begin
      if not ShowSeries.Bits[j] then continue;

      for i := 0 to NumPoints-1 do begin
         // Chart1.Series[j].AddXY(i, GetData(j, i), PointLab[i], clTeeColor);
         Chart1.Series[j].AddXY(i, GetData(j, i), SeriesLab[j], clTeeColor);
         Chart1.Series[j].XLabel[i] := PointLab[i];
      end;
   end;

   Chart1.UndoZoom;
   Chart1.Update;
end;


procedure TGrafWizForm.PrintButClick(Sender: TObject);
begin
   if PrintDialog1.Execute then begin
      Screen.Cursor := crHourGlass;
      try
         Chart1.Title.Font.Color := clBlack;
         Chart1.PrintLandscape;
      finally
         Screen.Cursor := crDefault;
      end;
   end;
end;

procedure TGrafWizForm.ComboChange(Sender: TObject);
begin
   CreateLab.Visible := True;
   CreateGraphBut.Enabled := True;
end;

procedure TGrafWizForm.PageControl1Change(Sender: TObject);
begin
   RefreshBut.Enabled := CreateGraphBut.Enabled;
end;

procedure TGrafWizForm.OptionChange(Sender: TObject);
begin
   RefreshBut.Enabled := True;
   RefreshLab.Visible := True;
end;

procedure TGrafWizForm.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled := False;
   CreateGraphButClick(nil);
end;

procedure TGrafWizForm.SetStat(s: string);
begin
   StatusBar1.Panels[0].Text := s;
   StatusBar1.Update;
end;

procedure TGrafWizForm.RefreshButClick(Sender: TObject);
begin
   RefreshLab.Visible := False;
   RefreshBut.Enabled := False;
   CreateGraphButClick(nil);
end;

procedure TGrafWizForm.GradientBoxClick(Sender: TObject);
begin
   Chart1.Gradient.Visible := GradientBox.Checked;
end;

procedure TGrafWizForm.View3DBoxClick(Sender: TObject);
begin
   Chart1.View3D := View3DBox.Checked;
end;

procedure TGrafWizForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   FormSettings1.SaveSettings;
end;

procedure TGrafWizForm.Button1Click(Sender: TObject);
begin
   Chart1.CopyToClipboardMetafile(True);
end;

end.
