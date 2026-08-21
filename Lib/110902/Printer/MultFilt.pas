unit MultFilt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TMultFiltForm = class(TForm)
    Label1: TLabel;
    ListBox1: TListBox;
    OKBut: TBitBtn;
    Label2: TLabel;
    ToggleBut: TBitBtn;
    CancelBut: TBitBtn;
    procedure OKButClick(Sender: TObject);
    procedure ToggleButClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MultFiltForm: TMultFiltForm;

implementation

{$R *.DFM}

procedure TMultFiltForm.OKButClick(Sender: TObject);
begin
   if ListBox1.SelCount = 0 then begin
      MessageDlg('You must select at least one item!', mtError, [mbOK], 0);
      ModalResult := mrNone;
   end;
end;

procedure TMultFiltForm.ToggleButClick(Sender: TObject);
var
   i : integer;
begin
   for i := 0 to ListBox1.Items.Count-1 do
      ListBox1.Selected[i] := not ListBox1.Selected[i];
end;

end.
