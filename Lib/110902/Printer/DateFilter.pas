unit DateFilter;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, ComCtrls, DB, Menus;

const
   NOT_SET_STR     = '<Not Set>';

type
   TFilterDate = class(TPanel)
   protected
      FieldName   : string;
      DataSet     : TDataSet;
      function    GetDataField: TField;
      procedure   SetDataField(f: TField);
   public
      UseMin      : boolean;
      UseMax      : boolean;
      MinDate     : TDateTime;
      MaxDate     : TDateTime;
      IncBlanks   : boolean;
      constructor Create(AOwner: TComponent); override;
      function    IsDateInFilter(dt: TDateTime): boolean;
      procedure   UpdateCaption;
      property    DataField: TField read GetDataField write SetDataField;
   end;

  TDateFilterForm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Label3: TLabel;
    Panel1: TPanel;
    StartDatePicker: TDateTimePicker;
    StartTimePicker: TDateTimePicker;
    StopDatePicker: TDateTimePicker;
    StopTimePicker: TDateTimePicker;
    StartCheckBox: TCheckBox;
    StopCheckBox: TCheckBox;
    Last7But: TButton;
    Last30But: TButton;
    Last60But: TButton;
    Last90But: TButton;
    DatePopup: TPopupMenu;
    CalendarMode1: TMenuItem;
    UpDownEditMode1: TMenuItem;
    Last365But: TButton;
    IncBlankBox: TCheckBox;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure Last7ButClick(Sender: TObject);
    procedure Last30ButClick(Sender: TObject);
    procedure Last60ButClick(Sender: TObject);
    procedure Last90ButClick(Sender: TObject);
    procedure DatePopupPopup(Sender: TObject);
    procedure CalendarMode1Click(Sender: TObject);
    procedure UpDownEditMode1Click(Sender: TObject);
    procedure Last365ButClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fd         : TFilterDate;
    CurDTP     : TDateTimePicker;
    procedure  DoLast(Days: double);
  end;

var
  DateFilterForm: TDateFilterForm;

implementation

{$R *.DFM}

constructor TFilterDate.Create(AOwner: TComponent);
begin
   inherited;
   IncBlanks := True;
end;

function TFilterDate.IsDateInFilter(dt: TDateTime): boolean;
var
   GoodMin   : boolean;
   GoodMax   : boolean;
begin
   if dt=0 then begin
      Result := IncBlanks;
   end else begin
      GoodMin := (not UseMin) or (dt >= MinDate);
      GoodMax := (not UseMax) or (dt <= MaxDate);
      Result := GoodMin and GoodMax;
   end;
end;

procedure TFilterDate.UpdateCaption;
var
   d1, d2   : string;
begin
   if (not UseMin) and (not UseMax) then begin
      Caption := NOT_SET_STR;
      Font.Style := Font.Style - [fsBold];
   end else begin
      Font.Style := Font.Style + [fsBold];
   end;

   d1 := FormatDateTime('mm/dd/yy', MinDate);
   d2 := FormatDateTime('mm/dd/yy', MaxDate);

   if UseMin and UseMax then
      Caption := Format('%s to %s', [d1, d2]);

   if UseMin and (not UseMax) then
      Caption := Format('After: %s', [d1]);

   if (not UseMin) and (UseMax) then
      Caption := Format('Before: %s', [d2]);

   if not IncBlanks then
      Caption := Caption + ' (No Blanks)';
end;

function TFilterDate.GetDataField: TField;
begin
   Assert(DataSet<>nil);
   Result := DataSet.FieldByName(FieldName);
end;

procedure TFilterDate.SetDataField(f: TField);
begin
   FieldName := f.FieldName;
   DataSet := f.DataSet;
end;


procedure TDateFilterForm.OKBtnClick(Sender: TObject);
begin
   fd.IncBlanks := IncBlankBox.Checked;

   fd.UseMin := StartCheckBox.Checked;
   if fd.UseMin then
      fd.MinDate := Trunc(StartDatePicker.Date) + Frac(StartTimePicker.Time);

   fd.UseMax := StopCheckBox.Checked;
   if fd.UseMax then
      fd.MaxDate := Trunc(StopDatePicker.Date) + Frac(StopTimePicker.Time);

   fd.UpdateCaption;
end;

procedure TDateFilterForm.FormShow(Sender: TObject);
begin
   IncBlankBox.Checked := fd.IncBlanks;

   StartDatePicker.Date := Trunc(fd.MinDate);
   StartTimePicker.Time := Frac(fd.MinDate);

   StopDatePicker.Date := Trunc(fd.MaxDate);
   StopTimePicker.Time := Frac(fd.MaxDate);

   StartCheckBox.Checked := fd.UseMin;
   StopCheckBox.Checked := fd.UseMax;

   CheckBoxClick(nil);
end;


procedure TDateFilterForm.CheckBoxClick(Sender: TObject);
begin
   StartDatePicker.Enabled := StartCheckBox.Checked;
   StartTimePicker.Enabled := StartCheckBox.Checked;
   
   StopDatePicker.Enabled := StopCheckBox.Checked;
   StopTimePicker.Enabled := StopCheckBox.Checked;
end;

procedure TDateFilterForm.Last7ButClick(Sender: TObject);
begin
   DoLast(7);
end;

procedure TDateFilterForm.Last30ButClick(Sender: TObject);
begin
   DoLast(30);
end;

procedure TDateFilterForm.Last60ButClick(Sender: TObject);
begin
   DoLast(60);
end;

procedure TDateFilterForm.Last90ButClick(Sender: TObject);
begin
   DoLast(90);
end;

procedure TDateFilterForm.Last365ButClick(Sender: TObject);
begin
   DoLast(365);
end;

procedure TDateFilterForm.DoLast(Days: double);
begin
   fd.MaxDate := Now;
   fd.MinDate := Trunc(Now - Days);
   fd.UseMin  := True;
   fd.UseMax  := True;
   FormShow(nil);
end;

procedure TDateFilterForm.DatePopupPopup(Sender: TObject);
var
   dtp : TDateTimePicker;
begin
   dtp := (Sender as TPopupMenu).PopupComponent as TDateTimePicker;
   CurDTP := dtp;

   if dtp.DateMode = dmComboBox then begin
      CalendarMode1.Checked := True;
      UpDownEditMode1.Checked := False;
   end else begin
      CalendarMode1.Checked := False;
      UpDownEditMode1.Checked := True;
   end;
end;

procedure TDateFilterForm.CalendarMode1Click(Sender: TObject);
begin
   CurDTP.DateMode := dmComboBox;
end;

procedure TDateFilterForm.UpDownEditMode1Click(Sender: TObject);
begin
   CurDTP.DateMode := dmUpDown;
end;

end.
