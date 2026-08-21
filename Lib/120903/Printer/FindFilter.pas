unit FindFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, DataWin, DB;

type
  TFindFilterForm = class(TForm)
    Label1: TLabel;
    FindEdit: TEdit;
    CaseBox: TCheckBox;
    FindBut: TBitBtn;
    CancelBut: TBitBtn;
    StatusBar1: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FindButClick(Sender: TObject);
    procedure CancelButClick(Sender: TObject);
  protected
  public
    dw         : TDataWinForm;
    Cancel     : boolean;
    procedure  Enable(b: boolean);
  end;

var
  FindFilterForm: TFindFilterForm;

implementation

uses TableUtils;

{$R *.DFM}

procedure TFindFilterForm.FormShow(Sender: TObject);
begin
   if FindEdit.CanFocus then FindEdit.SetFocus;
end;

procedure TFindFilterForm.Enable(b: boolean);
begin
   FindEdit.Enabled  := b;
   CaseBox.Enabled   := b;
   FindBut.Enabled   := b;
end;

procedure TFindFilterForm.FormCreate(Sender: TObject);
begin
   Enable(True);
end;

procedure TFindFilterForm.FindButClick(Sender: TObject);
var
   pkf      : TField;
   pk       : string;
   NewList  : TStringList;
   Num      : integer;
begin
   NewList := TStringList.Create;

   Enable(False);
   Cancel := False;

   with dw do begin
      FindDialog1.FindText := FindEdit.Text;
      if CaseBox.Checked then FindDialog1.Options := [frMatchCase]
         else FindDialog1.Options := [];

      DataSource1.DataSet := nil;
      CurTable.First;
      pkf := GetRequiredField(CurTable);
      Assert(pkf<>nil, 'No Primary Key!');
      Num := 0;
      while (not CurTable.EOF) and (not Cancel) do begin
         pk := pkf.AsString;

         if TextInRecord then
            NewList.Add(pk);

         Num := Num + 1;
         StatusBar1.Panels[0].Text := Format('Found:  %d  of  %d', [NewList.Count, Num]);
         Update;

         CurTable.Next;

         Application.ProcessMessages;
      end;

      if not Cancel then begin
         FiltList.Sorted := False;
         FiltList.Assign(NewList);
         FiltList.Sorted := True;
         
         RefreshCurTable;
      end;
      DataSource1.DataSet := CurTable;
   end;

   Close;
   NewList.Free;
end;

procedure TFindFilterForm.CancelButClick(Sender: TObject);
begin
   Cancel := True;
end;

end.
