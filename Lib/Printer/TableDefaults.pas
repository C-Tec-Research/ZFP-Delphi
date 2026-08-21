unit TableDefaults;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, DB, DBTables;

type
   TDefCheckbox = class(TCheckBox)
      Field    : TField;
      Buddy    : TControl;
   end;

   TDefEdit = class(TEdit)
      ck       : TDefCheckbox;
   end;

   TDefComboBox = class(TComboBox)
      ck       : TDefCheckbox;
   end;

   
  TTabDefaultsForm = class(TForm)
    BotPanel: TPanel;
    OKBut: TBitBtn;
    CancelBut: TBitBtn;
    ScrollBox1: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKButClick(Sender: TObject);
  protected
    procedure  Fill_Combo(cb: TComboBox; f: TField);
    procedure  DefChange(Sender: TObject);
    function   HasDefault(const FieldName: string): boolean;
    procedure  SetComboID(cb: TDefComboBox; ID: integer);
  public
    CurTable   : TTable;
    Defaults   : TStringList;
    procedure  SetTable(Table: TTable);
    function   SetDefaults: boolean;
  end;

var
  TabDefaultsForm: TTabDefaultsForm;

implementation

{$R *.DFM}


   
procedure TTabDefaultsForm.FormCreate(Sender: TObject);
begin
   Defaults := TStringList.Create;
end;

procedure TTabDefaultsForm.FormDestroy(Sender: TObject);
begin
   Defaults.Free;
end;

function TTabDefaultsForm.HasDefault(const FieldName: string): boolean;
var
   i : integer;
begin
   Result := False;

   for i := 0 to Defaults.Count-1 do
      if Defaults.Names[i] = FieldName then begin
         Result := True;
         break;
      end;
end;

procedure TTabDefaultsForm.SetComboID(cb: TDefComboBox; ID: integer);
var
   i : integer;
begin
   for i := 0 to cb.Items.Count-1 do begin
      if integer(cb.Items.Objects[i]) = ID then begin
         cb.ItemIndex := i;
         exit;
      end;
   end;

   cb.ItemIndex := -1;
end;

procedure TTabDefaultsForm.SetTable(Table: TTable);
const
   DEFHEIGHT = 40;
var
   i        : integer;
   f        : TField;
   ck       : TDefCheckBox;
   CurTop   : integer;
   e        : TDefEdit;
   cb       : TDefComboBox;
begin
   CurTable := Table;

   with ScrollBox1 do
      for i := ControlCount-1 downto 0 do
         Controls[i].Free;

   CurTop := 15;
   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if not f.Visible then continue;
      if f.Calculated or f.ReadOnly then continue;

      ck := TDefCheckBox.Create(Self);
      ck.Parent    := ScrollBox1;
      ck.Left      := 15;
      ck.Top       := CurTop;
      ck.Caption   := f.DisplayLabel;
      ck.Width     := 125;
      ck.Field     := f;

      if f.FieldKind = fkData then begin
         e := TDefEdit.Create(Self);
         e.Parent     := ScrollBox1;
         e.Left       := 155;
         e.Top        := CurTop;
         e.Width      := 275;
         e.ck         := ck;
         e.OnChange   := DefChange;
         ck.Buddy := e;
      end;

      if f.FieldKind = fkLookup then begin
         cb := TDefComboBox.Create(Self);
         cb.Parent    := ScrollBox1;
         cb.Left      := 155;
         cb.Top       := CurTop;
         cb.Width     := 275;
         cb.Style     := csDropDownList;
         cb.ck        := ck;
         cb.OnClick   := DefChange;
         ck.Buddy := cb;

         Fill_Combo(cb, f);
      end;

      if HasDefault(f.FieldName) then begin
         ck.Checked := True;
         if ck.Buddy is TDefEdit then
            (ck.Buddy as TDefEdit).Text := Defaults.Values[f.FieldName];
         if ck.Buddy is TDefComboBox then
            SetComboID(ck.Buddy as TDefComboBox, StrToInt(Defaults.Values[f.FieldName]));
      end;

      CurTop := CurTop + DEFHEIGHT;
   end;
end;

procedure  TTabDefaultsForm.Fill_Combo(cb: TComboBox; f: TField);
var
   ds          : TDataSet;
   IDFldName   : string;
   TextFldName : string;
   // Num         : integer;
begin
   cb.Items.Clear;
   ds := f.LookupDataSet;
   IDFldName   := f.LookupKeyFields;
   TextFldName := f.LookupResultField;

   if ds.Active=False then exit;

   ds.First;
   // Num := 0;
   while not ds.EOF do begin
      // Num := Num + 1;
      // if Num > MAX_COMBO_ITEMS then break;

      cb.Items.AddObject(ds.FieldByName(TextFldName).AsString,
         pointer(ds.FieldByName(IDFldName).AsInteger));
      ds.Next;
   end;
end;


function TTabDefaultsForm.SetDefaults: boolean;
begin
   Result := False;

   if ShowModal = mrOK then begin
      Result := True;
   end;
end;

procedure TTabDefaultsForm.DefChange(Sender: TObject);
begin
   if Sender is TDefEdit then
      (Sender as TDefEdit).ck.Checked := True;

   if Sender is TDefComboBox then
      (Sender as TDefComboBox).ck.Checked := True;
end;


procedure TTabDefaultsForm.OKButClick(Sender: TObject);
var
   i  : integer;
   c  : TComponent;
   ck : TDefCheckBox;
   cb : TDefComboBox;
   s  : string;
begin
   Defaults.Clear;

   for i := 0 to ScrollBox1.ControlCount-1 do begin
      c := ScrollBox1.Controls[i];
      if not (c is TDefCheckbox) then continue;

      ck := c as TDefCheckbox;
      if ck.Checked = False then continue;

      if ck.Buddy is TDefEdit then
         s := (ck.Buddy as TDefEdit).Text;
      if ck.Buddy is TDefComboBox then begin
         cb := ck.Buddy as TDefComboBox;
         s := IntToStr(integer(cb.Items.Objects[cb.ItemIndex]));
      end;

      Defaults.Values[ck.Field.FieldName] := s;
   end;
end;

end.
