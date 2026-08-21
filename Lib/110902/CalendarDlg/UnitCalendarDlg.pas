unit UnitCalendarDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin, SigSpinEdit, Grids, Calendar;

type
  TFormCalendarSelect = class(TForm)
    CalendarMain: TCalendar;
    ComboBoxMonth: TComboBox;
    SigSpinEditYear: TSigSpinEdit;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    procedure SigSpinEditYearChange(Sender: TObject);
    procedure ComboBoxMonthChange(Sender: TObject);
    procedure CalendarMainChange(Sender: TObject);
  private
    function GetUseCurrentDate: boolean;
    procedure SetUseCurrentDate(const Value: boolean);
    function GetYear: integer;
    procedure SetYear(const Value: integer);
    function GetMonth: integer;
    procedure SetMonth(const Value: integer);
    function GetDay: integer;
    procedure SetDay(const Value: integer);
    function GetDataTime: tDateTime;
    procedure SetDateTime(const Value: tDateTime);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    property UseCurrentDate : boolean
             read GetUseCurrentDate
             write SetUseCurrentDate;
    property Year : integer
             read GetYear
             write SetYear;
    property Month : integer
             read GetMonth
             write SetMonth;
    property Day : integer
             read GetDay
             write SetDay;
    property DateTime : tDateTime
             read GetDataTime
             write SetDateTime;
  end;

var
  FormCalendarSelect: TFormCalendarSelect;

implementation

{$R *.dfm}

{ TFormCalendarSelect }

procedure TFormCalendarSelect.CalendarMainChange(Sender: TObject);
var
  iYear, iMonth1 : integer;
begin
  iYear := CalendarMain.Year;
  iMonth1 := CalendarMain.Month - 1;
  if iYear <> SigSpinEditYear.Value then
  begin
    SigSpinEditYear.Value := iYear;
  end;
  if iMonth1 <> ComboBoxMonth.ItemIndex then
  begin
    ComboBoxMonth.ItemIndex := iMonth1;
  end;
end;

procedure TFormCalendarSelect.ComboBoxMonthChange(Sender: TObject);
var
  iMonth : integer;
begin
  iMonth := ComboBoxMonth.ItemIndex + 1;
  if CalendarMain.Month <> iMonth then
  begin
    CalendarMain.Month := iMonth;
  end;
end;

function TFormCalendarSelect.Execute: boolean;
begin
  ComboBoxMonth.ItemIndex := CalendarMain.Month - 1;
  SigSpinEditYear.Value := CalendarMain.Year;
  Result := ShowModal = mrOK;
end;

function TFormCalendarSelect.GetDataTime: tDateTime;
begin
  Result := CalendarMain.CalendarDate;
end;

function TFormCalendarSelect.GetDay: integer;
begin
  Result := CalendarMain.Day;
end;

function TFormCalendarSelect.GetMonth: integer;
begin
  Result := CalendarMain.Month;
end;

function TFormCalendarSelect.GetUseCurrentDate: boolean;
begin
  Result := CalendarMain.UseCurrentDate;
end;

function TFormCalendarSelect.GetYear: integer;
begin
  Result := CalendarMain.Year;
end;

procedure TFormCalendarSelect.SetDateTime(const Value: tDateTime);
begin
  CalendarMain.CalendarDate := Value;
end;

procedure TFormCalendarSelect.SetDay(const Value: integer);
begin
  CalendarMain.Day := Value;
end;

procedure TFormCalendarSelect.SetMonth(const Value: integer);
begin
  CalendarMain.Month := Value;
end;

procedure TFormCalendarSelect.SetUseCurrentDate(const Value: boolean);
begin
  CalendarMain.UseCurrentDate := Value;
end;

procedure TFormCalendarSelect.SetYear(const Value: integer);
begin
  CalendarMain.Year := Value;
end;

procedure TFormCalendarSelect.SigSpinEditYearChange(Sender: TObject);
begin
  if SigSpinEditYear.IsValid then
  begin
    if CalendarMain.Year <> SigSpinEditYear.Value then
    begin
      CalendarMain.Year := SigSpinEditYear.Value
    end;
  end;
end;

end.
