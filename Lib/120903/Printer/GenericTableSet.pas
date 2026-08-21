unit GenericTableSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ExtCtrls, DB, DBTables, TableUtils, TableSet, DataWin,
  DBLookup, SQLFrm, ComCtrls, DBCtrls{, WABD_Objects};

const
   WM_AFTERADD    = WM_USER + 1;

type
  TGenericTableSetForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    ExportTableToExcel1: TMenuItem;
    ExportTabletoAscii1: TMenuItem;
    N1: TMenuItem;
    PrinterSetup1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Tools1: TMenuItem;
    AdminOnly1: TMenuItem;
    BackupExportAllTables1: TMenuItem;
    RestoreImportAllTables1: TMenuItem;
    N4: TMenuItem;
    RecreateTablesDangerous1: TMenuItem;
    DeleteAllTablesDangerous1: TMenuItem;
    ToolPanel: TPanel;
    Label1: TLabel;
    TableCombo: TComboBox;
    Panel1: TPanel;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SQLQuery1: TMenuItem;
    N2000: TMenuItem;
    StartupTimer: TTimer;
    TableTools1: TMenuItem;
    SelectDatabase1: TMenuItem;
    N100: TMenuItem;
    Synchronize1: TMenuItem;
    N3000: TMenuItem;
    WWWServer1: TMenuItem;
    ButPanel: TPanel;
    WWWImage: TImage;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    N105: TMenuItem;
    BackuptoFile1: TMenuItem;
    RestoreFromFile1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure TableComboChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure PrinterSetup1Click(Sender: TObject);
    procedure ExportTabletoAscii1Click(Sender: TObject);
    procedure BackupExportAllTables1Click(Sender: TObject);
    procedure DeleteAllTablesDangerous1Click(Sender: TObject);
    procedure RecreateTablesDangerous1Click(Sender: TObject);
    procedure RestoreImportAllTables1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SQLQuery1Click(Sender: TObject);
    procedure StartupTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ExportTableToExcel1Click(Sender: TObject);
    procedure TableTools1Click(Sender: TObject);
    procedure SelectDatabase1Click(Sender: TObject);
    procedure Synchronize1Click(Sender: TObject);
    procedure WWWServer1Click(Sender: TObject);
    procedure ToolPanelResize(Sender: TObject);
    procedure WWWImageDblClick(Sender: TObject);
    procedure BackuptoFile1Click(Sender: TObject);
    procedure RestoreFromFile1Click(Sender: TObject);
  private
    function GetBackupDir: string;
    procedure SetBackupDir(const Value: string);
  protected
    TableSet   : TTableSetHelper;
    dw         : TDataWinForm;
    MainTable  : string;
    OldNavClk  : ENavClick;
    Skip_Backup: boolean;
    procedure  InitTableCombo;
    procedure  FillComboTable(Table: TTable);
    procedure  TableStatus(Sender: TObject; const Msg: string; LastOperation: boolean); virtual;
    procedure  AppendTablePopup;
    function   GetIniName: string;
    procedure  GetAliasFromINI;
    procedure  NavOnClick(Sender: TObject; Button: TNavigateBtn);
    procedure  AfterAdd(var Msg: TMessage); message WM_AFTERADD;
    procedure  SetAliasCaption;
    // Backup
    function   GetLastBackup: TDateTime;
    procedure  SetLastBackup(d: TDateTime);
    function   BackupDays: integer;
    function   NumBackupFiles: integer;
    procedure  Delete_Old_Backups;
    procedure  SetDefaultExtension(const Desc, Ext: string);
    // Virtual
    procedure  OpenTables; virtual;
    procedure  DataTableDblClick(Sender: TObject); virtual;
    procedure  ShowWWWServer; virtual;
    function   CreateBackup: boolean; virtual;
    // Virtual & Abstract
    procedure  SetAlias(const Alias: string); virtual; abstract;
    function   GetAlias: string; virtual; abstract;
    function   GetDataModule: TDataModule; virtual; abstract;
  public
    procedure  Show_MOTD(const Path: string; ShowEmpty: boolean);
//    function   Create_WABD_SesMgr: TWABD_SessionMgr; virtual;
    procedure  DoIntervalBackup;
    property   LastBackup: TDateTime read GetLastBackup write SetLastBackup;
    property   BackupDir: string read GetBackupDir write SetBackupDir;
  end;

var
  GenericTableSetForm: TGenericTableSetForm;

implementation

uses IniFiles, Motd, Alias, SynchDlg, WWW, WWW_DataMod, Registry, Recycle;

{$R *.DFM}

procedure TGenericTableSetForm.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TGenericTableSetForm.InitTableCombo;
begin
   TableCombo.Items.Clear;
   ForEachTableIn(TableSet.DataGroup, FillComboTable);
   TableCombo.ItemIndex := TableCombo.Items.IndexOf(MainTable);
   TableComboChange(nil);
end;

procedure TGenericTableSetForm.FillComboTable(Table: TTable);
begin
   TableCombo.Items.AddObject(Table.TableName, Table);
end;

procedure TGenericTableSetForm.TableComboChange(Sender: TObject);
var
   i : integer;
   t : TTable;
begin
   i := TableCombo.ItemIndex;
   if i = -1 then exit;
   t := TableCombo.Items.Objects[i] as TTable;
   if not t.Active then t.Active := True;
   dw.AssignTable(t);
   dw.Show;
end;

procedure TGenericTableSetForm.DataTableDblClick(Sender: TObject);
begin
   dw.DBGrid1DblClick(Sender);
end;

procedure TGenericTableSetForm.FormCreate(Sender: TObject);
begin
   Skip_Backup := False;
   
   dw := TDataWinForm.Create(nil);
   dw.BorderStyle := bsNone;
   dw.Parent      := Panel1;
   dw.Visible     := True;
   OldNavClk := dw.DBNavigator1.OnClick;
   dw.DBNavigator1.OnClick := NavOnClick;
   dw.DBGrid1.OnDblClick := DataTableDblClick;
   AppendTablePopup;

   TableSet := TTableSetHelper.Create;
   TableSet.StatusProc := TableStatus;
   MainTable := 'Bugs';
end;

procedure TGenericTableSetForm.Panel1Resize(Sender: TObject);
begin
   if dw=nil then exit;
   
   dw.Left := 0;
   dw.Top  := 0;
   dw.Width := Panel1.Width;
   dw.Height := Panel1.Height;
end;

procedure TGenericTableSetForm.PrinterSetup1Click(Sender: TObject);
begin
   PrinterSetupDialog1.Execute;
end;

procedure TGenericTableSetForm.ExportTabletoAscii1Click(Sender: TObject);
begin
   dw.ExporttoAscii1Click(nil);
end;


procedure TGenericTableSetForm.BackupExportAllTables1Click(Sender: TObject);
begin
   dw.DataSource1.DataSet := nil;
   TableSet.BackupTables;
   dw.DataSource1.DataSet := dw.CurTable;
end;

procedure TGenericTableSetForm.RestoreImportAllTables1Click(Sender: TObject);
begin
   dw.DataSource1.DataSet := nil;
   TableSet.RestoreTables;
   dw.DataSource1.DataSet := dw.CurTable;

   dw.RefreshCurTable;
   dw.Refresh_Filter_Combos;
end;

procedure TGenericTableSetForm.DeleteAllTablesDangerous1Click(Sender: TObject);
begin
   if MessageDlg('Are you sure you want to Delete all Tables?'#13#10 +
      'All existing Data will be lost.', mtWarning, mbYesNoCancel, 0)<>mrYes then exit;

   dw.DataSource1.Enabled := False;
   TableSet.DeleteTables;
   InitTableCombo;
end;

procedure TGenericTableSetForm.RecreateTablesDangerous1Click(Sender: TObject);
var
   OrigDG : TComponent;
   TmpDG  : TComponent;
begin
   if MessageDlg('Are you sure you want to Recreate all Tables?'#13#10 +
      'All existing Data will be lost.', mtWarning, mbYesNoCancel, 0)<>mrYes then exit;

   with TableSet do begin
      TmpDG := TComponentClass(DataGroup.ClassType).Create(Self);
      OrigDG := DataGroup;
      CloseTables;   // For the original DataGroup (global DataModule1)
      DataGroup := TmpDG;

      CreateTablesWithIdx;
      TmpDG.Free;

      DataGroup := OrigDG;
      OpenTables;

      if dw.CurTable<>nil then begin
         dw.CurTable.Refresh;
         dw.IndexComboChange(nil);
      end;
   end;
end;

procedure TGenericTableSetForm.FormDestroy(Sender: TObject);
begin
   TableSet.Free;
end;

procedure TGenericTableSetForm.TableStatus(Sender: TObject; const Msg: string; LastOperation: boolean);
begin
   Assert(dw<>nil);

   dw.StatPanel2.Caption := '  ' + Msg;
   Update;

   if not LastOperation then begin
      dw.DataSource1.DataSet := nil;
   end else begin
      dw.DataSource1.DataSet := dw.CurTable;
   end;
end;

procedure CopySubMenus(SrcMenu: TMenuItem; DestMenu: TMenuItem);
var
   i  : integer;
   mi : TMenuItem;
begin
   with SrcMenu do begin
      for i := 0 to Count-1 do begin
         mi := TMenuItem.Create(DestMenu);
         mi.Caption := Items[i].Caption;
         mi.Hint    := Items[i].Hint;
         mi.OnClick := Items[i].OnClick;
         DestMenu.Add(mi);
         CopySubMenus(Items[i], mi);
      end;
   end;
end;

procedure TGenericTableSetForm.AppendTablePopup;
begin
   {Table1.OnClick := DataWinForm.TablePopupMenu.OnPopup;
   CopySubMenus(DataWinForm.TablePopupMenu.Items, Table1);}
end;


procedure TGenericTableSetForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   DoIntervalBackup;

   TableSet.CloseTables;
   TableStatus(Self, 'Closing Down', False);

   dw.SaveColumnSettings;
   dw.AssignTable(nil);
   // Why did I free the Data Window?
   // dw.Free;
   // dw := nil;
end;

procedure TGenericTableSetForm.SQLQuery1Click(Sender: TObject);
begin
   if SQLForm=nil then
      SQLForm := TSQLForm.Create(Self);
   with SQLForm.Query1 do begin
      Active := False;
      Assert(dw.CurTable<>nil);
      DatabaseName := dw.CurTable.DatabaseName;
      SessionName := dw.CurTable.SessionName;
   end;
   SQLForm.ShowModal;
   dw.RefreshCurTable;
end;

procedure TGenericTableSetForm.StartupTimerTimer(Sender: TObject);
begin
   StartupTimer.Enabled := False;
   Update;

   TableSet.DataGroup := GetDataModule;
   GetAliasFromINI;
   InitTableCombo;
end;

procedure TGenericTableSetForm.FormShow(Sender: TObject);
begin
   StartupTimer.Enabled := True;
end;

procedure TGenericTableSetForm.ExportTableToExcel1Click(Sender: TObject);
begin
   ExportTableToExcel(dw.CurTable);
end;

// Show the MOTD - Message of the Day

procedure TGenericTableSetForm.Show_MOTD(const Path: string; ShowEmpty: boolean);
var
   sl    : TStringList;
   Len   : integer;
begin
   sl := TStringList.Create;

   Len := 0;
   sl.Text := 'File not Found: ' + Path;
   if FileExists(Path) then begin
      try
         sl.LoadFromFile(Path);
         Len := Length(Trim(sl.Text));
      except
         on e: Exception do begin
            Len := 0;
            sl.Text := 'Error openning file ' + Path + ': ' + e.Message;
         end;
      end;
   end;

   if (Len <> 0) or ShowEmpty then begin
      if MOTDForm=nil then MOTDForm := TMOTDForm.Create(Self);
      MOTDForm.Memo1.Lines.Assign(sl);
      MOTDForm.ShowModal;
   end;

   sl.Free;
end;

procedure TGenericTableSetForm.TableTools1Click(Sender: TObject);
var
   p : TPoint;
begin
   GetCursorPos(p);
   dw.TablePopupMenu.Popup(p.x, p.y);
end;

function TGenericTableSetForm.GetIniName: string;
begin
   Result := ExtractFileName(Application.ExeName);
   Result := ChangeFileExt(Result, '.ini');
end;

procedure TGenericTableSetForm.GetAliasFromINI;
var
   ini      : TIniFile;
   Alias    : string;
begin
   ini := TIniFile.Create(GetIniName);
   Alias := ini.ReadString('Database', 'CurrentAlias', '');
   ini.Free;

   if Alias='' then begin
      SelectDatabase1Click(nil);
   end else begin
      SetAlias(Alias);  // DataModule1.SetAlias(Alias);
      SetAliasCaption;
      OpenTables;
   end;
end;

procedure TGenericTableSetForm.OpenTables;
begin
   TableSet.OpenTables;
end;

procedure TGenericTableSetForm.SelectDatabase1Click(Sender: TObject);
var
   ini   : TIniFile;
begin
   if AliasForm=nil then AliasForm := TAliasForm.Create(Self);

   AliasForm.CurAlias := GetAlias;
   if AliasForm.ShowModal = mrOK then begin
      SetAlias(AliasForm.CurAlias);
      SetAliasCaption;
      OpenTables;
      if dw.CurTable<>nil then begin
         dw.AssignTable(dw.CurTable);
      end;

      ini := TIniFile.Create(GetIniName);
      ini.WriteString('Database', 'CurrentAlias', AliasForm.CurAlias);
      ini.Free;
   end;
end;

procedure TGenericTableSetForm.NavOnClick(Sender: TObject; Button: TNavigateBtn);
begin
   if Assigned(OldNavClk) then OldNavClk(Sender, Button);
   
   if Button = nbInsert	then
      PostMessage(Handle, WM_AFTERADD, 0, 0);
end;

procedure TGenericTableSetForm.AfterAdd(var Msg: TMessage);
begin
   dw.DBGrid1.OnDblClick(dw.DBGrid1);
end;

procedure TGenericTableSetForm.Synchronize1Click(Sender: TObject);
var
   sf : TSynchForm;
begin
   dw.DataSource1.DataSet := nil;
   try
      sf := TSynchForm.Create(Self);
      sf.TableSet := TableSet;
      sf.ShowModal;
   finally
      if not Application.Terminated then
         dw.DataSource1.DataSet := dw.CurTable;
   end;
end;

procedure TGenericTableSetForm.SetAliasCaption;
begin
   Caption := Application.Title + ' - ' + GetAlias;
end;

procedure TGenericTableSetForm.WWWServer1Click(Sender: TObject);
begin
   ShowWWWServer;
end;

procedure TGenericTableSetForm.ShowWWWServer;
begin
   if WWWForm=nil then WWWForm := TWWWForm.Create(Self);
   WWWForm.Show;
end;

(*
function TGenericTableSetForm.Create_WABD_SesMgr: TWABD_SessionMgr;
var
   dm  : TWWWDataMod;
begin
   dm := TWWWDataMod.Create(Self);
   dm.TableSet := TableSet;
   Result := dm.WABD_SessionMgr1;
end;
*)

procedure TGenericTableSetForm.ToolPanelResize(Sender: TObject);
begin
   ButPanel.Left := ToolPanel.ClientWidth - ButPanel.Width - 4;
end;

procedure TGenericTableSetForm.WWWImageDblClick(Sender: TObject);
begin
   Assert(WWWForm<>nil);
   WWWForm.Show;
end;

function TGenericTableSetForm.GetLastBackup: TDateTime;
var
   ini : TRegIniFile;
   s   : string;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   s := ini.ReadString('Backup', GetAlias, '01/01/1900');
   Result := StrToDateTime(s);
   ini.Free;
end;

procedure TGenericTableSetForm.SetLastBackup(d: TDateTime);
var
   ini : TRegIniFile;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   ini.WriteString('Backup', GetAlias, FormatDateTime('m/d/yyyy hh:nn:ss', d));
   ini.Free;
end;

function TGenericTableSetForm.BackupDays: integer;
const
   Key = 'Backup Days';
var
   ini : TRegIniFile;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   Result := ini.ReadInteger('Backup', Key, 1);
   ini.WriteInteger('Backup', Key, Result);
   ini.Free;
end;

function TGenericTableSetForm.NumBackupFiles: integer;
const
   Key = 'Num Backup Files';
var
   ini : TRegIniFile;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   Result := ini.ReadInteger('Backup', Key, 5);
   ini.WriteInteger('Backup', Key, Result);
   ini.Free;
end;

procedure TGenericTableSetForm.DoIntervalBackup;
var
   d : TDateTime;
   s : string;
begin
   if Skip_Backup then exit;
   d := LastBackup;
   if Now - d >= BackupDays then begin
      if d = StrToDateTime('01/01/1900') then begin
         s := 'Never'
      end else begin
         s := Format('%s (%1.1n days ago)',
            [FormatDateTime('dddd, mm/dd/yy  hh:nn ampm', d), Now - d]);
      end;
      MessageDlg('Last Backup was: ' + s  + #13#10 +
         Format('Backup Interval = %d days', [BackupDays]), mtInformation, [mbOK], 0);

      if CreateBackup then begin
         MessageDlg('Backup Complete', mtInformation, [mbOK], 0);
      end else begin
         MessageDlg('Backup Failed!', mtError, [mbOK], 0);
      end;
   end;
end;

procedure TGenericTableSetForm.BackuptoFile1Click(Sender: TObject);
begin
   CreateBackup;
end;

function TGenericTableSetForm.CreateBackup: boolean;
var
   fs : TFileStream;
begin
   Result := False;
   SaveDialog1.InitialDir := BackupDir;
   SaveDialog1.FileName := GetAlias + ' ' + FormatDateTime('yyyy-mm-dd', Now);

   if SaveDialog1.Execute then begin
      dw.DataSource1.DataSet := nil;
      fs := TFileStream.Create(SaveDialog1.FileName, fmCreate or fmOpenWrite or fmShareExclusive);
      try
         TableSet.BackupTablesToStream(fs);
      finally
         dw.DataSource1.DataSet := dw.CurTable;
         fs.Free;
      end;
      BackupDir := ExtractFilePath(SaveDialog1.FileName);
      Delete_Old_Backups;
      Result := True;
      LastBackup := Now;
   end;
end;

procedure TGenericTableSetForm.RestoreFromFile1Click(Sender: TObject);
var
   fs : TFileStream;
begin
   inherited;
   if OpenDialog1.Execute then begin
      dw.DataSource1.DataSet := nil;
      fs := TFileStream.Create(OpenDialog1.FileName, fmOpenRead or fmShareExclusive);
      try
         TableSet.RestoreTablesFromStream(fs);
      finally
         dw.DataSource1.DataSet := dw.CurTable;
         fs.Free;
      end;
   end;
   
   if dw.CurTable<>nil then
      dw.CurTable.Refresh;
end;

procedure TGenericTableSetForm.SetDefaultExtension(const Desc, Ext: string);
begin
   OpenDialog1.DefaultExt := Ext;
   OpenDialog1.Filter     := Desc + ' Files (*.' + Ext + ')|*.' + Ext + '|All Files|*.*';
   SaveDialog1.DefaultExt := Ext;
   SaveDialog1.Filter     := OpenDialog1.Filter;
end;

type
   PSearchRec = ^TSearchRec;

function SortFileTime(Item1, Item2: Pointer): Integer;
begin
   Result := PSearchRec(Item2).Time - PSearchRec(Item1).Time;
end;

procedure TGenericTableSetForm.Delete_Old_Backups;
var
   sr    : TSearchRec;
   FList : TList;
   psr   : PSearchRec;
   i     : integer;
   Path  : string;
   Ext   : string;
begin
   FList := TList.Create;
   Path := BackupDir;
   Ext := GetAlias + '*.' + OpenDialog1.DefaultExt;
   if FindFirst(Path + Ext, faAnyFile and (not faDirectory), sr) = 0 then repeat
      New(psr);
      psr^ := sr;
      FList.Add(psr);
   until FindNext(sr)<>0;
   FindClose(sr);

   FList.Sort(SortFileTime);

   for i := NumBackupFiles to FList.Count-1 do begin
      RecycleFileEx(Path + PSearchRec(FList[i]).Name, False);
   end;

   for i := 0 to FList.Count-1 do begin
      psr := FList[i];
      Dispose(psr);
   end;
   FList.Free;
end;


function TGenericTableSetForm.GetBackupDir: string;
var
   ini : TRegIniFile;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   Result := ini.ReadString('Backup', 'BackupDir', GetCurrentDir);
   if Copy(Result, Length(Result), 1)<>'\' then Result := Result + '\';
   ini.Free;
end;

procedure TGenericTableSetForm.SetBackupDir(const Value: string);
var
   ini : TRegIniFile;
begin
   ini := TRegIniFile.Create('Software\' + Application.Title);
   ini.WriteString('Backup', 'BackupDir', Value);
   ini.Free;
end;

end.
