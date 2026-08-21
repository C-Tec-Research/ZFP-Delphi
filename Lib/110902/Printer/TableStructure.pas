unit TableStructure;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, DB, DBTables, Menus, StdCtrls, ClipBrd;

type
  TTableStructureForm = class(TForm)
    ListView1: TListView;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Print1: TMenuItem;
    N1: TMenuItem;
    PrinterSetup1: TMenuItem;
    N2: TMenuItem;
    Close1: TMenuItem;
    Edit1: TMenuItem;
    CopytoClipboard1: TMenuItem;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ListPopup: TPopupMenu;
    ShowField1: TMenuItem;
    HideField1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure PrinterSetup1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure ListPopupPopup(Sender: TObject);
    procedure ShowHideClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
    MadeChange : boolean;
    procedure  UpdateListItem(i: integer; li: TListItem; f: TField);
  public
    Table      : TTable;
    function   GetText: string;
  end;

var
  TableStructureForm: TTableStructureForm;

implementation

{$R *.DFM}

procedure TTableStructureForm.UpdateListItem(i: integer; li: TListItem; f: TField);
var
   s : string;
begin
   li.Caption := Format('%d. %s', [i+1, f.FieldName]);
   li.Data := f;

   li.SubItems.Clear;
   if f.Visible then s := 'Show' else s := 'Hide';
   li.SubItems.Add(s);

   case f.DataType of
      ftString : s := 'String';
      ftSmallint, ftInteger, ftWord : s := 'Integer';
      ftBoolean : s := 'Boolean';
      ftFloat : s := 'Float';
      ftDate : s := 'Date';
      ftTime : s := 'Time';
      ftDateTime : s := 'Date / Time';
      ftAutoInc : s := 'AutoInc';
      ftMemo, ftFmtMemo : s := 'Memo';
      ftBytes, ftVarBytes, ftBlob, ftGraphic,
      ftParadoxOle, ftDBaseOle, ftTypedBinary : s := 'Blob';
   end;
   li.SubItems.Add(s);

   if f.Size>0 then
      li.SubItems.Add(IntToStr(f.Size))
   else
      li.SubItems.Add('');

   li.SubItems.Add(f.DisplayLabel);

   s := '';
   if f.FieldKind = fkLookup then begin
      s := Format('%s -> %s (%s)',
         [f.KeyFields, f.LookupResultField, f.LookupDataSet.Name]);
   end;
   if f.FieldKind = fkCalculated then
      s := Format('Calculated (%s)', [f.LookupResultField]);
   li.SubItems.Add(s);
end;

procedure TTableStructureForm.FormShow(Sender: TObject);
var
   i  : integer;
   f  : TField;
   li : TListItem;
begin
   Caption := 'View Table Structure - ' + Table.TableName;
   ListView1.Items.Clear;
   Table.FieldDefs.Update;

   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      li := ListView1.Items.Add;
      UpdateListItem(i, li, f);
   end;
   MadeChange := False;
end;

procedure TTableStructureForm.Close1Click(Sender: TObject);
begin
   Close;
end;

procedure TTableStructureForm.PrinterSetup1Click(Sender: TObject);
begin
   PrinterSetupDialog1.Execute;
end;

procedure TTableStructureForm.Print1Click(Sender: TObject);
var
   f  : TForm;
   he : TRichEdit;
begin
   f  := TForm.Create(Self);
   he := TRichEdit.Create(Self);
   try
      he.Parent := f;
      he.Text := Caption + #13#10 + #13#10 + GetText;
      he.Print(Caption);
   finally
      he.Free;
      f.Free;
   end;
end;

function TTableStructureForm.GetText: string;
const
   TAB = #9;
   CR  = #13#10;
var
   i, j  : integer;
   li    : TListItem;
   s     : string;
begin
   s := '';
   for i := 0 to ListView1.Items.Count-1 do begin
      li := ListView1.Items[i];
      s := s + li.Caption + TAB;

      for j := 0 to li.SubItems.Count-1 do
         s := s + li.SubItems[j] + TAB;
      s := s + CR;
   end;
   Result := s;
end;

procedure TTableStructureForm.CopytoClipboard1Click(Sender: TObject);
begin
   ClipBoard.SetTextBuf(PChar(GetText));
end;

procedure TTableStructureForm.ListPopupPopup(Sender: TObject);
var
   li : TListItem;
   f  : TField;
begin
   li := ListView1.Selected;

   ShowField1.Enabled := False;
   HideField1.Enabled := False;
   if li<>nil then begin
      f := li.Data;
      Assert(f<>nil);
      ShowField1.Enabled := not f.Visible;
      HideField1.Enabled := f.Visible;
   end;
end;

procedure TTableStructureForm.ShowHideClick(Sender: TObject);
var
   li : TListItem;
   f  : TField;
begin
   li := ListView1.Selected;
   Assert(li<>nil);
   f := li.Data;
   Assert(f<>nil);

   if Sender=ShowField1 then f.Visible := True;
   if Sender=HideField1 then f.Visible := False;

   UpdateListItem(li.Index, li, f);
   MadeChange := True;
end;

procedure TTableStructureForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   if MadeChange then
      ShowMessage('NOTE:  You have made changes to this table''s visible fields.' + #13#10 +
         'To see these changes you must select the View / Reset Table Column Settings menu.');
end;

end.
