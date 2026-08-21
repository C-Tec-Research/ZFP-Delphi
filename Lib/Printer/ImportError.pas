unit ImportError;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Buttons, ExtCtrls;

type
  TImportErrForm = class(TForm)
    BotPanel: TPanel;
    OKBut: TBitBtn;
    StringGrid1: TStringGrid;
    TopPanel: TPanel;
    Label1: TLabel;
    DataEdit: TEdit;
    Label2: TLabel;
    CancelBut: TBitBtn;
    Label3: TLabel;
    ErrEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure  SetData(const ErrMsg, OrigLine: string; FieldSL, DataSL: TStringList; FieldNum: integer);
  end;

var
  ImportErrForm: TImportErrForm;

implementation

{$R *.DFM}

procedure TImportErrForm.FormCreate(Sender: TObject);
begin
   with StringGrid1 do begin
      Cells[0,0] := 'Field';
      Cells[1,0] := 'Import Data';
   end;
end;

procedure TImportErrForm.SetData(const ErrMsg, OrigLine: string; FieldSL, DataSL: TStringList; FieldNum: integer);
var
   i, max, x : integer;
begin
   ErrEdit.Text  := ErrMsg;
   DataEdit.Text := OrigLine;

   max := DataSL.Count;
   if FieldSL.Count > max then max := FieldSL.Count;

   StringGrid1.RowCount := 1 + max;

   for i := 0 to FieldSL.Count-1 do
      StringGrid1.Cells[0, i + 1] := FieldSL[i];

   for i := 0 to DataSL.Count-1 do
      StringGrid1.Cells[1, i + 1] := DataSL[i];

   with StringGrid1 do begin
      Col := 1;
      Row := 1 + FieldNum;

      x := 1 + FieldNum - VisibleRowCount + 1;
      if x > TopRow then TopRow := x;
   end;
end;

procedure TImportErrForm.FormShow(Sender: TObject);
begin
   StringGrid1.SetFocus;
end;

end.
