unit UnitDataChanged;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

  {
    ShowMOdal returns
    mrOK for Save
    mrYes for SaveAs
    mrNo for Don't save
    and
    mrCancel for mrCancel
  }
type
  TFormDataChanged = class(TForm)
    Label1: TLabel;
    BitBtnSave: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDataChanged: TFormDataChanged;

implementation

{$R *.dfm}

end.
