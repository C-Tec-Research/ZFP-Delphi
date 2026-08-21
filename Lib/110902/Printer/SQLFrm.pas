unit SQLFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBCtrls, Grids, DBGrids, ExtCtrls, DBTables, StdCtrls, Buttons, Menus;

type
  TSQLForm = class(TForm)
    ToolPanel: TPanel;
    BotPanel: TPanel;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DataSource1: TDataSource;
    Query1: TQuery;
    Label4: TLabel;
    NumRecLab: TLabel;
    RightPanel: TPanel;
    QueryBut: TBitBtn;
    UpdateBut: TBitBtn;
    SQLRefHelp: TBitBtn;
    LocalSQLHelp: TBitBtn;
    CloseBut: TBitBtn;
    SQLPopup: TPopupMenu;
    LoadSQLFromFile1: TMenuItem;
    SaveSQLToFile1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SQLMemo: TMemo;
    LiveBox: TCheckBox;
    PrevCombo: TComboBox;
    TablePopup: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    ExporttoExcel1: TMenuItem;
    SavedLabel: TLabel;
    SavedBox: TComboBox;
    LoadBut: TSpeedButton;
    SaveBut: TSpeedButton;
    procedure QueryButClick(Sender: TObject);
    procedure UpdateButClick(Sender: TObject);
    procedure CloseButClick(Sender: TObject);
    procedure SQLRefHelpClick(Sender: TObject);
    procedure LocalSQLHelpClick(Sender: TObject);
    procedure PrevComboChange(Sender: TObject);
    procedure LoadSQLFromFile1Click(Sender: TObject);
    procedure SaveSQLToFile1Click(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure ExporttoExcel1Click(Sender: TObject);
    procedure SavedBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
  public
    function   StripPathExt(const f: string): string;
    procedure  UpdateSavedBox;
  end;

var
  SQLForm: TSQLForm;

implementation

{$R *.DFM}

uses TableUtils;

procedure TSQLForm.QueryButClick(Sender: TObject);
begin
   Query1.Active := False;
   Query1.SQL.Assign(SQLMemo.Lines);
   Query1.RequestLive := LiveBox.Checked;

   if PrevCombo.Items.IndexOf(SQLMemo.Text)=-1 then
      PrevCombo.ItemIndex := PrevCombo.Items.Add(SQLMemo.Text);
   Screen.Cursor := crHourGlass;
   try
      Query1.Open;
   finally
      Screen.Cursor := crDefault;
   end;
   NumRecLab.Caption := IntToStr(Query1.RecordCount);
end;

procedure TSQLForm.UpdateButClick(Sender: TObject);
var
   s : string;
begin
   Query1.Active := False;
   Query1.SQL.Assign(SQLMemo.Lines);

   if PrevCombo.Items.IndexOf(SQLMemo.Text)=-1 then
      PrevCombo.ItemIndex := PrevCombo.Items.Add(SQLMemo.Text);
   Screen.Cursor := crHourGlass;
   try
      Query1.ExecSQL;
   finally
      Screen.Cursor := crDefault;
   end;

   s := Format('Number of Rows affected by Update: %d', [Query1.RowsAffected]);
   MessageDlg(s, mtInformation, [mbOk], 0);
end;

procedure TSQLForm.CloseButClick(Sender: TObject);
begin
   Close;
end;


procedure TSQLForm.SQLRefHelpClick(Sender: TObject);
begin
   WinHelp(Handle, 'SQLRef32.hlp', HELP_FINDER, 0);
end;

procedure TSQLForm.LocalSQLHelpClick(Sender: TObject);
begin
   WinHelp(Handle, 'LocalSQL.hlp', HELP_FINDER, 0);
end;

procedure TSQLForm.PrevComboChange(Sender: TObject);
begin
   if PrevCombo.ItemIndex<>-1 then
      SQLMemo.Text := PrevCombo.Items[PrevCombo.ItemIndex];
end;

procedure TSQLForm.LoadSQLFromFile1Click(Sender: TObject);
begin
   if OpenDialog1.Execute then
      SQLMemo.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TSQLForm.SaveSQLToFile1Click(Sender: TObject);
begin
   if SaveDialog1.Execute then begin
      SQLMemo.Lines.SaveToFile(SaveDialog1.FileName);
      SavedBox.Text := StripPathExt(SaveDialog1.FileName);
      UpdateSavedBox;
   end;
end;

procedure TSQLForm.CopytoClipboard1Click(Sender: TObject);
begin
   ExportTableToClipboard(Query1);
end;

procedure TSQLForm.ExporttoExcel1Click(Sender: TObject);
begin
   ExportTableToExcel(Query1);
end;

function TSQLForm.StripPathExt(const f: string): string;
var
   tmp : string;
begin
   tmp := ExtractFileName(f);
   Result := ChangeFileExt(tmp, '');
end;

procedure TSQLForm.UpdateSavedBox;
var
   p     : string;
   tmp   : string;
   sr    : TSearchRec;
   i     : integer;
begin
   tmp := SavedBox.Text;

   SavedBox.Items.Clear;
   p := ExtractFilePath(Application.ExeName) + '*.sql';
   if FindFirst(p, faAnyFile, sr)=0 then repeat
      SavedBox.Items.Add(StripPathExt(sr.Name));
   until FindNext(sr)<>0;
   FindClose(sr);

   i := SavedBox.Items.IndexOf(tmp);
   SavedBox.ItemIndex := i;
end;


procedure TSQLForm.SavedBoxChange(Sender: TObject);
var
   f : string;
begin
   f := ExtractFilePath(Application.ExeName) + SavedBox.Text + '.sql';

   SQLMemo.Lines.LoadFromFile(f);
   QueryBut.SetFocus;
end;

procedure TSQLForm.FormShow(Sender: TObject);
begin
   OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
   SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
   UpdateSavedBox;
end;

end.
