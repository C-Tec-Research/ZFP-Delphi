unit CreateIndexFrm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, DB, DBTables;

type
  TCreateIndexForm = class(TForm)
    CreateBut: TButton;
    CancelBtn: TButton;
    SrcList: TListBox;
    DstList: TListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    UniqueBox: TCheckBox;
    DescendBox: TCheckBox;
    CaseBox: TCheckBox;
    Label2: TLabel;
    NameEdit: TEdit;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure FormShow(Sender: TObject);
    procedure CreateButClick(Sender: TObject);
  protected
    procedure UpdateIdxName;
  public
    { Public declarations }
    Table   : TTable;
  end;

var
  CreateIndexForm: TCreateIndexForm;

implementation

{$R *.DFM}

procedure TCreateIndexForm.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
   UpdateIdxName;
end;

procedure TCreateIndexForm.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
   UpdateIdxName;
end;

procedure TCreateIndexForm.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I], 
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
   UpdateIdxName;
end;

procedure TCreateIndexForm.ExcAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
   UpdateIdxName;
end;

procedure TCreateIndexForm.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TCreateIndexForm.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
  CreateBut.Enabled := not DstEmpty;
end;

function TCreateIndexForm.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TCreateIndexForm.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

procedure TCreateIndexForm.FormShow(Sender: TObject);
var
   i : integer;
begin
   SrcList.Items.Clear;
   Table.FieldDefs.Update;
   for i := 0 to Table.FieldDefs.Count-1 do begin
      SrcList.Items.Add(Table.FieldDefs[i].Name);
   end;
   SetButtons;
   UpdateIdxName;
end;

procedure TCreateIndexForm.CreateButClick(Sender: TObject);
var
   i           : integer;
   IdxFields   : string;
   IdxOpt      : TIndexOptions;
begin
   for i := 0 to DstList.Items.Count-1 do begin
      IdxFields := IdxFields + DstList.Items[i];
      if i < DstList.Items.Count-1 then IdxFields := IdxFields + ';';
   end;

   IdxOpt := [];
   if UniqueBox.Checked then IdxOpt := IdxOpt + [ixUnique];
   if DescendBox.Checked then IdxOpt := IdxOpt + [ixDescending];
   if CaseBox.Checked then IdxOpt := IdxOpt + [ixCaseInsensitive];

   Table.AddIndex(NameEdit.Text, IdxFields, IdxOpt);
   Table.IndexDefs.Update;
   Table.Refresh;
   Table.IndexFieldNames := IdxFields;
   ModalResult := mrOK;
end;

procedure TCreateIndexForm.UpdateIdxName;
begin
   if DstList.Items.Count > 0 then begin
      if DstList.Items.Count > 1 then begin
         Table.IndexDefs.Update;
         NameEdit.Text := 'Index'+IntToStr(Table.IndexDefs.Count+1);
      end else
         NameEdit.Text := DstList.Items[0];
   end else
      NameEdit.Text := 'None';
end;


end.
