unit WWW_DataMod;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WABD_Objects, TableSet, DBTables, Db;

type
  TWWWDataMod = class(TDataModule)
    WABD_SessionMgr1: TWABD_SessionMgr;
    WABD_Session1: TWABD_Session;
    MainForm: TWABD_Form;
    WABD_Header1: TWABD_Header;
    WABD_FormSection1: TWABD_FormSection;
    WABD_Label1: TWABD_Label;
    TableBox: TWABD_ComboBox;
    ViewBut: TWABD_Button;
    TableForm: TWABD_Form;
    DataTable: TWABD_DataTable;
    DataSource1: TDataSource;
    WABD_FormSection2: TWABD_FormSection;
    ReturnBut: TWABD_Button;
    TimeHdr: TWABD_Header;
    TableDetailForm: TWABD_Form;
    TabNameHdr: TWABD_Header;
    TabNameHdr2: TWABD_Header;
    DetailTable: TWABD_DataTable;
    WABD_FormSection3: TWABD_FormSection;
    ReturnBut2: TWABD_Button;
    LogOffBut: TWABD_Button;
    LogOffForm: TWABD_Form;
    WABD_Header2: TWABD_Header;
    WABD_FormSection5: TWABD_FormSection;
    Anchor1: TWABD_Anchor;
    procedure WABD_SessionMgr1CreateSession(var NewSession: TWABD_Session);
    procedure WABD_SessionMgr1DestroySession(Session: TWABD_Session);
    procedure MainFormShow(Sender: TObject);
    procedure ReturnButClick(Sender: TObject);
    procedure ViewButClick(Sender: TObject);
    procedure WABD_Session1FirstLogon(Sender: TObject);
    procedure ReturnBut2Click(Sender: TObject);
    procedure DataTableRecordClick(Sender: TWABD_DataTable;
      RowIndex: Integer; var MoveToRecord: Boolean);
    procedure LogOffButClick(Sender: TObject);
  protected
    procedure  SetCurTable;
  public
    { Public declarations }
    TableSet   : TTableSetHelper;
  end;

var
  WWWDataMod: TWWWDataMod;

implementation

{$R *.DFM}

procedure TWWWDataMod.WABD_SessionMgr1CreateSession(
  var NewSession: TWABD_Session);
var
   dm : TWWWDataMod;
begin
   dm := TWWWDataMod.Create(nil);
   dm.TableSet := TableSet;    // This is NOT thread safe!
   NewSession := dm.WABD_Session1;
end;

procedure TWWWDataMod.WABD_SessionMgr1DestroySession(
  Session: TWABD_Session);
begin
   Session.Owner.Free;
end;

procedure TWWWDataMod.MainFormShow(Sender: TObject);
begin
   TimeHdr.Caption := FormatDateTime('dddd, d-mmm-yy  hh:nn:ss ampm', Now);
end;

procedure TWWWDataMod.ReturnButClick(Sender: TObject);
begin
   MainForm.Show;
end;

procedure TWWWDataMod.SetCurTable;
var
   s : string;
   i : integer;
   c : TComponent;
begin
   s := TableBox.Lines[TableBox.SelIndex];

   for i := 0 to TableSet.DataGroup.ComponentCount-1 do begin
      c := TableSet.DataGroup.Components[i];
      if c is TTable then
         if TTable(c).TableName = s then
            DataSource1.DataSet := TTable(c);
   end;

   Assert(DataSource1.DataSet<>nil);

   DataSource1.DataSet.First;
end;

procedure TWWWDataMod.ViewButClick(Sender: TObject);
begin
   SetCurTable;
   TabNameHdr.Caption := DataSource1.DataSet.Name;
   TableForm.Show;
end;

procedure TWWWDataMod.WABD_Session1FirstLogon(Sender: TObject);
var
   i : integer;
   c : TComponent;
begin
   Assert(TableSet<>nil);

   TableBox.Lines.Clear;

   for i := 0 to TableSet.DataGroup.ComponentCount-1 do begin
      c := TableSet.DataGroup.Components[i];
      if c is TTable then
         TableBox.Lines.Add(TTable(c).TableName);
   end;

   if TableBox.Lines.Count > 0 then
      TableBox.SelIndex := 0;

end;

procedure TWWWDataMod.ReturnBut2Click(Sender: TObject);
begin
   TableForm.Show;
end;

procedure TWWWDataMod.DataTableRecordClick(Sender: TWABD_DataTable;
  RowIndex: Integer; var MoveToRecord: Boolean);
begin
   MoveToRecord := False;
   Sender.JumpToTableRecord(RowIndex);
   TabNameHdr2.Caption := DataSource1.DataSet.Name;
   TableDetailForm.Show;
end;

procedure TWWWDataMod.LogOffButClick(Sender: TObject);
begin
   WABD_Session1.LogOff;
   LogOffForm.Show;
end;

end.
