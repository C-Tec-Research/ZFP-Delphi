unit TestPrev;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Printers, Spin, PrevPrinter, ComCtrls;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    FontDialog1: TFontDialog;
    OpenDialog1: TOpenDialog;
    ShowGridBox: TCheckBox;
    PreviewPrinter1: TPreviewPrinter;
    ZoomBox: TComboBox;
    Label1: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    TestBut: TButton;
    FontBut: TButton;
    LoadBut: TButton;
    OwnerDrawBox: TCheckBox;
    Label2: TLabel;
    PageSetupBut: TButton;
    StatusBar1: TStatusBar;
    RichEdit1: TRichEdit;
    procedure TestButClick(Sender: TObject);
    procedure FontButClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadButClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PreviewPrinter1OwnerDraw(Sender: TObject; Page,
      Line: Integer; R: TRect; Canvas: TCanvas);
    procedure PreviewPrinter1NewPage(Sender: TObject; Page: Integer);
    procedure PreviewPrinter1OwnerHeight(Sender: TObject; Line: Integer;
      var Height: Integer; var ForceNewPage: Boolean);
    procedure PageSetupButClick(Sender: TObject);
    procedure PreviewPrinter1Status(Sender: TObject; const StatMsg: String;
      PageNum: Integer; StatusType: TStatusType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function GetScreenCap: TBitmap;
var
   dc : HDC;
   c  : TCanvas;
   R  : TRect;
begin
   dc := GetDC(0);
   try
      c := TCanvas.Create;
      c.Handle := dc;
      try
         Result := TBitmap.Create;
         Result.Width := Screen.Width;
         Result.Height := Screen.Height;
         R := Rect(0, 0, Screen.Width, Screen.Height);
         Result.Canvas.CopyRect(R, c, R);
      finally
         c.Free;
      end;
   finally
      ReleaseDC(0, dc);
   end;
end;

procedure TForm1.TestButClick(Sender: TObject);
var
   pp    : TPreviewPrinter;
begin
   pp := PreviewPrinter1;

   pp.ShowGrid := ShowGridBox.Checked;

   case ZoomBox.ItemIndex of
      0 : pp.ZoomOption := zoFitToPage;
      1 : pp.ZoomOption := zoFitToWidth;
      2 : pp.ZoomOption := zoTwoPages;
   end;

   pp.TextOptions.DrawStyle := dsStandard;
   pp.TextOptions.BodyFont := FontDialog1.Font;

   if OwnerDrawBox.Checked then begin
      pp.TextOptions.DrawStyle := dsOwnerDrawFixed;
      pp.DrawStringList(RichEdit1.Lines);
   end else begin
      pp.DrawRichText(RichEdit1);
   end;

   pp.Preview;
end;


procedure TForm1.FontButClick(Sender: TObject);
begin
   FontDialog1.Font := RichEdit1.Font;
   if FontDialog1.Execute then
      RichEdit1.Font := FontDialog1.Font;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
   i : integer;
begin
   for i := ComponentCount-1 downto 0 do begin
      Components[i].Free;
   end;
end;

procedure TForm1.LoadButClick(Sender: TObject);
begin
   if OpenDialog1.Execute then begin
      RichEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
      PreviewPrinter1.TextOptions.Header := OpenDialog1.FileName;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   ZoomBox.ItemIndex := 0;
   try
      RichEdit1.Lines.LoadFromFile('PrevPrinter.pas');
      PreviewPrinter1.TextOptions.Header := 'PrevPrinter.Pas';
   except
      on e:Exception do ShowMessage(e.Message);
   end;
end;

procedure TForm1.PreviewPrinter1OwnerDraw(Sender: TObject; Page,
  Line: Integer; R: TRect; Canvas: TCanvas);
begin
   Canvas.Brush.Color := clLtGray;
   Canvas.Pen.Width   := PreviewPrinter1.PixelsPerInchX * 1 div 72;
   Canvas.Rectangle(R.Left, R.Top, R.Right-1, R.Bottom-1);
   Canvas.TextRect(R, R.Left, R.Top, RichEdit1.Lines[Line]);
   Canvas.Brush.Color := clWhite;
end;

procedure TForm1.PreviewPrinter1NewPage(Sender: TObject; Page: Integer);
begin
   PreviewPrinter1.TextOptions.Footer :=
      FormatDateTime('d-mmm-yy (ddd)  hh:nn ampm', Now);
end;

procedure TForm1.PreviewPrinter1OwnerHeight(Sender: TObject; Line: Integer;
  var Height: Integer; var ForceNewPage: Boolean);
begin
   ForceNewPage := (Line = 100) or (Line = 300);
end;

procedure TForm1.PageSetupButClick(Sender: TObject);
begin
   PreviewPrinter1.PageSetupDlg;
end;

procedure TForm1.PreviewPrinter1Status(Sender: TObject;
  const StatMsg: String; PageNum: Integer; StatusType: TStatusType);
begin
   StatusBar1.Panels[0].Text := StatMsg;
   Update;
end;

end.
