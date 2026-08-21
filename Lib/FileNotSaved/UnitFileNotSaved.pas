unit UnitFileNotSaved;

{
  How to use:

  Set the file names, DIR, etc as for a file save Dialog. You can
  directly use the Save and SaveAs functions, or call the execute function
  with a dirty parameter

  You must supply an OnSave callback!
}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons;

type
  TFormFileNotSaved = class(TForm)
    LabelNotSavedWarning: TLabel;
    BitBtnYes: TBitBtn;
    BitBtnNo: TBitBtn;
    BitBtnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFileNotSaved: TFormFileNotSaved;

implementation

{$R *.dfm}

{ TFormFileNotSaved }


end.
