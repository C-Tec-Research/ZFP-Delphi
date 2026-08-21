unit UnitLoadErrors;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TFormLoadErrors = class(TForm)
    LabelMsg: TLabel;
    MemoLoadErrors: TMemo;
    BitBtnContinue: TBitBtn;
    BitBtnAbort: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute( pCaption, pMsg : string ) : boolean;
  end;

var
  FormLoadErrors: TFormLoadErrors;

implementation

{$R *.dfm}

{ TFormLoadErrors }

function TFormLoadErrors.Execute( pCaption, pMsg : string ): boolean;
begin
  Caption := pCaption;
  LabelMsg.Caption := pMsg;
  Result := ShowModal = mrOK;
end;

end.
