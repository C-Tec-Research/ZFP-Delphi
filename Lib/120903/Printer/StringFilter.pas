unit StringFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, DB;

type
   TFilterStringMode = (fsNone, fsSubstring, fsRange);

   TFilterString = class(TPanel)
   protected
      FieldName   : string;
      DataSet     : TDataSet;
      function    GetDataField: TField;
      procedure   SetDataField(f: TField);
   public
      Mode        : TFilterStringMode;
      SubStr      : string;
      UseMin      : boolean;
      UseMax      : boolean;
      MinStr      : string;
      MaxStr      : string;
      IncBlanks   : boolean;
      CaseSense   : boolean;
      WholeWord   : boolean;
      constructor Create(AOwner: TComponent); override;
      function    IsStrInFilter(const s: string): boolean;
      procedure   UpdateCaption;
      property    DataField: TField read GetDataField write SetDataField;
   end;

  TStringFilterForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    SubStringEdit: TEdit;
    WholeWordBox: TCheckBox;
    Panel1: TPanel;
    CaseBox: TCheckBox;
    IncBlanksBox: TCheckBox;
    UseMinBox: TCheckBox;
    MinValEdit: TEdit;
    UseMaxBox: TCheckBox;
    MaxValEdit: TEdit;
    OKBut: TBitBtn;
    CancelBut: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure OKButClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fs   : TFilterString;
  end;

var
  StringFilterForm: TStringFilterForm;

implementation

{$R *.DFM}

// **********************************************************************
// TFilterString

constructor TFilterString.Create(AOwner: TComponent);
begin
   inherited;
   Mode      := fsNone;
   IncBlanks := False;
   WholeWord := False;
end;

function TFilterString.GetDataField: TField;
begin
   Assert(DataSet<>nil);
   Result := DataSet.FieldByName(FieldName);
end;

procedure TFilterString.SetDataField(f: TField);
begin
   FieldName := f.FieldName;
   DataSet := f.DataSet;
end;

function TFilterString.IsStrInFilter(const s: string): boolean;
var
   s1, s2      : string;
   smin,smax   : string;
   GoodMin     : boolean;
   GoodMax     : boolean;
begin
   Result := False;

   if Mode = fsNone then begin
      Result := True;
      exit;
   end;

   s1   := s;
   s2   := SubStr;
   smin := MinStr;
   smax := MaxStr;

   if not CaseSense then begin
      s1 := UpperCase(s1);
      s2 := UpperCase(s2);
      smin := UpperCase(smin);
      smax := UpperCase(smax);
   end;

   if Mode = fsSubstring then begin
      Result := Pos(s2, s1) <> 0;
   end;

   if Mode = fsRange then begin
      GoodMin := (not UseMin) or (s1 >= smin);
      GoodMax := (not UseMax) or (s1 <= smax);
      Result := GoodMin and GoodMax;
   end;

   if not Result and IncBlanks then
      if s='' then Result := True;
end;

procedure TFilterString.UpdateCaption;
begin
   if Mode = fsNone then begin
      Caption := '<Not Set>';
      Font.Style := Font.Style - [fsBold];
   end else begin
      Font.Style := Font.Style + [fsBold];
   end;

   if Mode = fsSubstring then begin
      Caption := 'Substring: ' + SubStr;
   end;

   if Mode = fsRange then begin
      if UseMin and UseMax then
         Caption := Format('%s to %s', [MinStr, MaxStr]);

      if UseMin and (not UseMax) then
         Caption := Format('After: %s', [MinStr]);

      if (not UseMin) and (UseMax) then
         Caption := Format('Before: %s', [MaxStr]);
   end;
end;


// **********************************************************************
// TStringFilterForm

procedure TStringFilterForm.FormShow(Sender: TObject);
var
   ap : TTabSheet;
begin
   case fs.Mode of
      fsNone      : ap := TabSheet1;
      fsSubstring : ap := TabSheet1;
      fsRange     : ap := TabSheet2;
      else        ap := nil;
   end;
   PageControl1.ActivePage := ap;

   SubStringEdit.Text   := fs.SubStr;
   WholeWordBox.Checked := fs.WholeWord;

   UseMinBox.Checked    := fs.UseMin;
   UseMaxBox.Checked    := fs.UseMax;
   MinValEdit.Text      := fs.MinStr;
   MaxValEdit.Text      := fs.MaxStr;

   CaseBox.Checked      := fs.CaseSense;
   IncBlanksBox.Checked := fs.IncBlanks;
end;

procedure TStringFilterForm.OKButClick(Sender: TObject);
var
   ap : TTabSheet;
begin
   ap := PageControl1.ActivePage;

   if ap = TabSheet1 then begin
      fs.Mode := fsSubString;

      fs.SubStr      := SubStringEdit.Text;
      fs.WholeWord   := WholeWordBox.Checked;

      if fs.SubStr = '' then
         fs.Mode := fsNone;
   end;

   if ap = TabSheet2 then begin
      fs.Mode := fsRange;

      fs.UseMin   := UseMinBox.Checked;
      fs.UseMax   := UseMaxBox.Checked;
      fs.MinStr   := MinValEdit.Text;
      fs.MaxStr   := MaxValEdit.Text;
   end;

   fs.CaseSense := CaseBox.Checked;
   fs.IncBlanks := IncBlanksBox.Checked;

   fs.UpdateCaption;
end;

end.
