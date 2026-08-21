unit CompRecordsDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, FormSettings, DB, DBTables, BenTools,
  ComCtrls;

type
   TFieldCon = class(TObject)
      Field    : TField;
      Lab      : TLabel;
      Edit1    : TEdit;
      Edit2    : TEdit;
      Match    : boolean;
   end;

   TFieldConList = class(TOwnList)
   protected
      function    GetFieldCon(i: integer): TFieldCon;
   public
      procedure   AddFieldCon(f: TField; Lab: TLabel; e1, e2: TEdit);
      function    FindFieldIdx(f: TField): integer;
      property    FieldCons[i: integer]: TFieldCon read GetFieldCon; default;
   end;

   TUserChoice = (ucNone, ucCancel, ucSkip, ucLocal, ucLocalAll, ucRemote, ucRemoteAll);

  TCompRecordForm = class(TForm)
    TopPanel: TPanel;
    FieldBox: TScrollBox;
    LocalBut: TButton;
    RemoteBut: TButton;
    AllLocalBut: TButton;
    AllRemoteBut: TButton;
    FieldPanel: TPanel;
    LocalValPanel: TPanel;
    RemoteValPanel: TPanel;
    FormSettings1: TFormSettings;
    BotPanel: TPanel;
    CancelBut: TBitBtn;
    StatusBar1: TStatusBar;
    SkipBut: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CancelButClick(Sender: TObject);
    procedure LocalButClick(Sender: TObject);
    procedure SkipButClick(Sender: TObject);
    procedure AllLocalButClick(Sender: TObject);
    procedure RemoteButClick(Sender: TObject);
    procedure AllRemoteButClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    FUserChoice: TUserChoice;
    FCList     : TFieldConList;
    procedure  SetUserChoice(Choice: TUserChoice);
  public
    property   UserChoice: TUserChoice read FUserChoice write SetUserChoice;
    procedure  InitFields(Table: TTable);
    procedure  SetFieldValues(f: TField; const v1, v2: string);
    procedure  GetUserChoice(InLocal, InRemote: boolean);
  end;


implementation

{$R *.DFM}


// ********************************************************************
// TFieldConList

procedure TFieldConList.AddFieldCon(f: TField; Lab: TLabel; e1, e2: TEdit);
var
   fc : TFieldCon;
begin
   fc := TFieldCon.Create;
   fc.Field := f;
   fc.Lab   := lab;
   fc.Edit1 := e1;
   fc.Edit2 := e2;
   Add(fc);
end;

function TFieldConList.FindFieldIdx(f: TField): integer;
var
   i : integer;
begin
   Result := -1;
   for i := 0 to Count-1 do
      if FieldCons[i].Field = f then
         Result := i;
end;

function TFieldConList.GetFieldCon(i: integer): TFieldCon;
begin
   Result := Items[i];
end;


// ********************************************************************
// TCompRecordForm

procedure TCompRecordForm.FormCreate(Sender: TObject);
begin
   FCList := TFieldConList.Create;
   FUserChoice := ucNone;
end;

procedure TCompRecordForm.FormDestroy(Sender: TObject);
begin
   FCList.Free;
end;

procedure TCompRecordForm.FormShow(Sender: TObject);
var
   i  : integer;
   s  : string;
begin
   s := '';
   for i := 0 to FCList.Count-1 do
      if FCList[i].Match = False then begin
         if s = '' then s := 'Field Conflicts: ';
         s := s + FCList[i].Field.DisplayLabel + ' ';
      end;

   StatusBar1.Panels[1].Text := s;
end;

procedure TCompRecordForm.SetUserChoice(Choice: TUserChoice);
begin
   FUserChoice := Choice;
   Close;
end;

procedure TCompRecordForm.InitFields(Table: TTable);
var
   i     : integer;
   f     : TField;
   Lab   : TLabel;
   Edit1 : TEdit;
   Edit2 : TEdit;
begin
   Assert(Table<>nil);

   // Clear out the old controls
   FCList.ClearItems;
   for i := FieldBox.ControlCount-1 downto 0 do
      FieldBox.Controls[i].Free;

   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if f.Visible then begin
         Lab            := TLabel.Create(Self);
         Lab.Parent     := FieldBox;
         Lab.Caption    := f.DisplayLabel;
         Lab.Left       := FieldPanel.Left;
         Lab.Top        := 8 + Lab.Height * 2 * FCList.Count;
         Lab.AutoSize   := False;
         Lab.Width      := FieldPanel.Width;

         Edit1          := TEdit.Create(Self);
         Edit1.Parent   := FieldBox;
         Edit1.Left     := LocalValPanel.Left;
         Edit1.Top      := Lab.Top;
         Edit1.Width    := LocalValPanel.Width;
         Edit1.ReadOnly := True;

         Edit2          := TEdit.Create(Self);
         Edit2.Parent   := FieldBox;
         Edit2.Left     := RemoteValPanel.Left;
         Edit2.Top      := Lab.Top;
         Edit2.Width    := RemoteValPanel.Width;
         Edit2.ReadOnly := True;

         FCList.AddFieldCon(f, Lab, Edit1, Edit2);
      end;
   end;
end;

procedure TCompRecordForm.SetFieldValues(f: TField; const v1, v2: string);
var
   i        : integer;
   e1, e2   : TEdit;
   Lab      : TLabel;
begin
   i := FCList.FindFieldIdx(f);
   Assert(i<>-1);

   e1 := FCList[i].Edit1;
   e2 := FCList[i].Edit2;

   e1.Text := v1;
   e2.Text := v2;

   if v1<>v2 then begin
      Lab := FCList[i].Lab;
      Lab.Color     := clRed;
      e1.Font.Color := clRed;
      e2.Font.Color := clRed;
   end;

   FCList[i].Match := (v1 = v2);
end;

procedure TCompRecordForm.GetUserChoice(InLocal, InRemote: boolean);
begin
   LocalBut.Enabled     := InLocal;
   AllLocalBut.Enabled  := InLocal;

   RemoteBut.Enabled    := InRemote;
   AllRemoteBut.Enabled := InRemote;

   ShowModal;
end;

procedure TCompRecordForm.CancelButClick(Sender: TObject);
begin
   UserChoice := ucCancel;
end;

procedure TCompRecordForm.SkipButClick(Sender: TObject);
begin
   UserChoice := ucSkip;
end;

procedure TCompRecordForm.LocalButClick(Sender: TObject);
begin
   UserChoice := ucLocal;
end;

procedure TCompRecordForm.AllLocalButClick(Sender: TObject);
begin
   UserChoice := ucLocalAll;
end;

procedure TCompRecordForm.RemoteButClick(Sender: TObject);
begin
   UserChoice := ucRemote;
end;

procedure TCompRecordForm.AllRemoteButClick(Sender: TObject);
begin
   UserChoice := ucRemoteAll;
end;

end.
