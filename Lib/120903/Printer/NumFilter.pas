unit NumFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, Buttons;

const
   NOT_SET_STR     = '<Not Set>';

type
   TNumFilter = class(TEdit)
   protected
      FieldName   : string;
      DataSet     : TDataSet;
      function    GetDataField: TField;
      procedure   SetDataField(f: TField);
   public
      UseMin      : boolean;
      UseMax      : boolean;
      MinVal      : double;
      MaxVal      : double;
      IncBlanks   : boolean;
      constructor Create(AOwner: TComponent); override;
      function    IsNumInFilter(Num: double): boolean;
      procedure   UpdateText;
      procedure   UseOneVal;
      property    DataField: TField read GetDataField write SetDataField;
   end;

  TNumFilterForm = class(TForm)
    MinBox: TCheckBox;
    MinEdit: TEdit;
    MaxBox: TCheckBox;
    MaxEdit: TEdit;
    BlanksBox: TCheckBox;
    OKBut: TBitBtn;
    CancelBut: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure OKButClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ne         : TNumFilter;
  end;

var
  NumFilterForm: TNumFilterForm;

implementation

{$R *.DFM}

constructor TNumFilter.Create(AOwner: TComponent);
begin
   inherited;
   IncBlanks := True;
end;

function TNumFilter.IsNumInFilter(Num: double): boolean;
var
   GoodMin   : boolean;
   GoodMax   : boolean;
begin
   if DataField.IsNull then begin
      Result := IncBlanks;
   end else begin
      GoodMin := (not UseMin) or (MinVal <= Num);
      GoodMax := (not UseMax) or (MaxVal >= Num);
      Result := GoodMin and GoodMax;
   end;
end;

procedure TNumFilter.UpdateText;
var
   v1, v2   : string;
begin
   if (not UseMin) and (not UseMax) then begin
      Caption := NOT_SET_STR;
      Font.Style := Font.Style - [fsBold];
   end else begin
      Font.Style := Font.Style + [fsBold];
   end;

   v1 := FloatToStr(MinVal);
   v2 := FloatToStr(MaxVal);

   if UseMin and UseMax then
      if (MinVal = MaxVal) then
         Caption := Format('%s', [v1])
      else
         Caption := Format('%s to %s', [v1, v2]);

   if UseMin and (not UseMax) then
      Caption := Format('After: %s', [v1]);

   if (not UseMin) and (UseMax) then
      Caption := Format('Before: %s', [v2]);

   if not IncBlanks then
      Caption := Caption + ' (No Blanks)';

   SelectAll;
end;

procedure TNumFilter.UseOneVal;
begin
   UseMin := True;
   UseMax := True;
   try
      MinVal := StrToFloat(Text);
   except
      MinVal := 0;
   end;
   MaxVal := MinVal;
   IncBlanks := False;
end;

function TNumFilter.GetDataField: TField;
begin
   Assert(DataSet<>nil);
   Result := DataSet.FieldByName(FieldName);
end;

procedure TNumFilter.SetDataField(f: TField);
begin
   FieldName := f.FieldName;
   DataSet := f.DataSet;
end;


procedure TNumFilterForm.FormShow(Sender: TObject);
begin
   MinBox.Checked := ne.UseMin;
   MaxBox.Checked := ne.UseMax;
   BlanksBox.Checked := ne.IncBlanks;

   MinEdit.Text := FloatToStr(ne.MinVal);
   MaxEdit.Text := FloatToStr(ne.MaxVal);

   CheckBoxClick(nil);
end;

procedure TNumFilterForm.CheckBoxClick(Sender: TObject);
begin
   MinEdit.Enabled := MinBox.Checked;
   MaxEdit.Enabled := MaxBox.Checked;
end;

function SafeStrToFloat(const S: string): double;
begin
   try
      Result := StrToFloat(s);
   except
      Result := 0;
   end;
end;

procedure TNumFilterForm.OKButClick(Sender: TObject);
begin
   ne.IncBlanks := BlanksBox.Checked;

   ne.UseMin := MinBox.Checked;
   if ne.UseMin then
      ne.MinVal := SafeStrToFloat(MinEdit.Text);

   ne.UseMax := MaxBox.Checked;
   if ne.UseMax then
      ne.MaxVal := SafeStrToFloat(MaxEdit.Text);

   ne.UpdateText;
end;

end.
