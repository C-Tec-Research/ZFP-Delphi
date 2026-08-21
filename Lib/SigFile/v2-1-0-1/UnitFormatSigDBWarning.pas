unit UnitFormatSigDBWarning;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TFormFormat = class(TForm)
    MemoFormatWarning: TMemo;
    BitBtnAbort: TBitBtn;
    BitBtnProceed: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
  end;

var
  FormFormat: TFormFormat;

implementation

{$R *.dfm}

{ TFormFormat }

function TFormFormat.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

end.
