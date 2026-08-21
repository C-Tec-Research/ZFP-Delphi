unit PageSetupDlg;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  PrevPrinter,
  Buttons,
  Printers,
  FormSettings;

type
  TPageSetupForm = class(TForm)
    PageMarginGroup: TGroupBox;
    InchBut: TRadioButton;
    CentBut: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LeftEdit: TEdit;
    RightEdit: TEdit;
    TopEdit: TEdit;
    BotEdit: TEdit;
    PageOrientGroup: TGroupBox;
    PortBut: TRadioButton;
    LandBut: TRadioButton;
    PortShape: TShape;
    LandShape: TShape;
    OKBut: TBitBtn;
    CancelBut: TBitBtn;
    HeaderGroup: TGroupBox;
    Label5: TLabel;
    HeaderEdit: TEdit;
    Label6: TLabel;
    HdrMarginEdit: TEdit;
    HdrLeftBut: TRadioButton;
    HdrCenterBut: TRadioButton;
    HdrRightBut: TRadioButton;
    HdrFontBut: TBitBtn;
    FooterGroup: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    FooterEdit: TEdit;
    FtrMarginEdit: TEdit;
    FtrLeftBut: TRadioButton;
    FtrCenterBut: TRadioButton;
    FtrRightBut: TRadioButton;
    FtrFontBut: TBitBtn;
    PageNumGroup: TGroupBox;
    Panel1: TPanel;
    PageBotBut: TRadioButton;
    PageTopBut: TRadioButton;
    PageNoneBut: TRadioButton;
    Panel2: TPanel;
    PageLeftBut: TRadioButton;
    PageCenterBut: TRadioButton;
    PageRightBut: TRadioButton;
    Label9: TLabel;
    PageNumEdit: TEdit;
    PageNumFontBut: TBitBtn;
    PrinterSetupBut: TBitBtn;
    PrinterSetupDialog1: TPrinterSetupDialog;
    FooterFontDialog: TFontDialog;
    HeaderFontDialog: TFontDialog;
    PageNumFontDialog: TFontDialog;
    SetDefaultBut: TBitBtn;
    FormSettings1: TFormSettings;
    procedure FormShow(Sender: TObject);
    procedure OKButClick(Sender: TObject);
    procedure PortButClick(Sender: TObject);
    procedure PrinterSetupButClick(Sender: TObject);
    procedure PageNumFontButClick(Sender: TObject);
    procedure HdrFontButClick(Sender: TObject);
    procedure FtrFontButClick(Sender: TObject);
    procedure SetDefaultButClick(Sender: TObject);
  protected
    procedure  Data_To_Form;
    procedure  Form_To_Data;
    procedure  EnumToChkBox(n: integer; p: TWinControl);
    function   ChkBoxToEnum(p: TWinControl): integer;
    procedure  FontToBut(f: TFont; b: TBitBtn; fd: TFontDialog);
    procedure  DoFontDlg(b: TBitBtn; fd: TFontDialog);
  public
    TextOpt    : TTextOptions;
    pp         : TPreviewPrinter;
    function   Execute: integer;
    procedure  GetDefaults;
  end;

var
  PageSetupForm: TPageSetupForm;

implementation

{$R *.DFM}

function TPageSetupForm.Execute: integer;
begin
   Result := ShowModal;
end;

procedure TPageSetupForm.FormShow(Sender: TObject);
begin
   Data_To_Form;
end;

procedure TPageSetupForm.OKButClick(Sender: TObject);
begin
   Form_To_Data;
end;

procedure TPageSetupForm.PrinterSetupButClick(Sender: TObject);
begin
   PrinterSetupDialog1.Execute;
end;

procedure TPageSetupForm.EnumToChkBox(n: integer; p: TWinControl);
var
   i : integer;
   c : TControl;
begin
   for i := 0 to p.ControlCount-1 do begin
      c := p.Controls[i];
      if c is TRadioButton then
         if c.Tag = n then
            TRadioButton(c).Checked := True;
   end;
end;

function TPageSetupForm.ChkBoxToEnum(p: TWinControl): integer;
var
   i : integer;
   c : TControl;
begin
   Result := -1;
   for i := 0 to p.ControlCount-1 do begin
      c := p.Controls[i];
      if c is TRadioButton then
         if TRadioButton(c).Checked then
            Result := c.Tag;
   end;
end;

procedure TPageSetupForm.FontToBut(f: TFont; b: TBitBtn; fd: TFontDialog);
begin
   fd.Font := f;
   b.Caption := Format('%s %d pt', [f.Name, f.Size]);
end;

procedure TPageSetupForm.DoFontDlg(b: TBitBtn; fd: TFontDialog);
begin
   if fd.Execute then
      FontToBut(fd.Font, b, fd);
end;

procedure TPageSetupForm.PortButClick(Sender: TObject);
var
   b : boolean;
begin
   b := PortBut.Checked;
   PortShape.Visible := b;
   LandShape.Visible := not b;
end;

procedure TPageSetupForm.PageNumFontButClick(Sender: TObject);
begin
   DoFontDlg(PageNumFontBut, PageNumFontDialog);
end;

procedure TPageSetupForm.HdrFontButClick(Sender: TObject);
begin
   DoFontDlg(HdrFontBut, HeaderFontDialog);
end;

procedure TPageSetupForm.FtrFontButClick(Sender: TObject);
begin
   DoFontDlg(FtrFontBut, FooterFontDialog);
end;

procedure TPageSetupForm.Data_To_Form;
begin
   // Page Margins
   EnumToChkBox(integer(pp.Units), PageMarginGroup);
   LeftEdit.Text  := Format('%1.3n', [TextOpt.MarginLeft]);
   RightEdit.Text := Format('%1.3n', [TextOpt.MarginRight]);
   TopEdit.Text   := Format('%1.3n', [TextOpt.MarginTop]);
   BotEdit.Text   := Format('%1.3n', [TextOpt.MarginBottom]);

   // Page Orientation
   EnumToChkBox(integer(pp.Orientation), PageOrientGroup);
   PortButClick(nil);

   // Page Number Options
   EnumToChkBox(integer(TextOpt.PrintPageNumber), Panel1);
   EnumToChkBox(integer(TextOpt.PageNumAlign), Panel2);
   PageNumEdit.Text := TextOpt.PageNumText;
   FontToBut(TextOpt.PageNumFont, PageNumFontBut, PageNumFontDialog);

   // Header
   HeaderEdit.Text := TextOpt.Header;
   HdrMarginEdit.Text := Format('%1.3n', [TextOpt.HeaderMargin]);
   EnumToChkBox(integer(TextOpt.HeaderAlign), HeaderGroup);
   FontToBut(TextOpt.HeaderFont, HdrFontBut, HeaderFontDialog);

   // Footer
   FooterEdit.Text := TextOpt.Footer;
   FtrMarginEdit.Text := Format('%1.3n', [TextOpt.FooterMargin]);
   EnumToChkBox(integer(TextOpt.FooterAlign), FooterGroup);
   FontToBut(TextOpt.FooterFont, FtrFontBut, FooterFontDialog);
end;

procedure TPageSetupForm.Form_To_Data;
begin
   // Page Margins
   pp.Units := TUnits(ChkBoxToEnum(PageMarginGroup));
   TextOpt.MarginLeft   := StrToFloat(LeftEdit.Text);
   TextOpt.MarginTop    := StrToFloat(TopEdit.Text);
   TextOpt.MarginRight  := StrToFloat(RightEdit.Text);
   TextOpt.MarginBottom := StrToFloat(BotEdit.Text);

   // Page Orientation
   pp.Orientation := TPrinterOrientation(ChkBoxToEnum(PageOrientGroup));

   // Page Number Options
   TextOpt.PrintPageNumber := TPrintPageNumber(ChkBoxToEnum(Panel1));
   TextOpt.PageNumAlign    := TAlignment(ChkBoxToEnum(Panel2));
   TextOpt.PageNumText     := PageNumEdit.Text;
   TextOpt.PageNumFont     := PageNumFontDialog.Font;

   // Header
   TextOpt.Header       := HeaderEdit.Text;
   TextOpt.HeaderMargin := StrToFloat(HdrMarginEdit.Text);
   TextOpt.HeaderAlign  := TAlignment(ChkBoxToEnum(HeaderGroup));
   TextOpt.HeaderFont   := HeaderFontDialog.Font;

   // Footer
   TextOpt.Footer       := FooterEdit.Text;
   TextOpt.FooterMargin := StrToFloat(FtrMarginEdit.Text);
   TextOpt.FooterAlign  := TAlignment(ChkBoxToEnum(FooterGroup));
   TextOpt.FooterFont   := FooterFontDialog.Font;
end;


procedure TPageSetupForm.SetDefaultButClick(Sender: TObject);
begin
   if MessageDlg('Are you sure you want to save these values as the Default Settings?',
      mtWarning, mbYesNoCancel, 0) = mrYes then begin
      FormSettings1.SaveValues := True;
      FormSettings1.SaveSettings;
      FormSettings1.SaveValues := False;
   end;
end;

procedure TPageSetupForm.GetDefaults;
begin
   Data_To_Form;
   FormSettings1.LoadSettings;
   Form_To_Data;
end;


end.
