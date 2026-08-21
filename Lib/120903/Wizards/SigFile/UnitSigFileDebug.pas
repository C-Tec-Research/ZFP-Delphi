unit UnitSigFileDebug;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  UnitSigFileGUI,
  StdCtrls, Buttons, ExtCtrls;

type
  TFormSigFileDebug = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BitBtnDone: TBitBtn;
    BitBtnLoad: TBitBtn;
    procedure BitBtnDoneClick(Sender: TObject);
    procedure BitBtnLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSigFileDebug: TFormSigFileDebug;

implementation

{$R *.dfm}

procedure TFormSigFileDebug.BitBtnDoneClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSigFileDebug.BitBtnLoadClick(Sender: TObject);
begin
  //
  with FormSigFileGUI do
  begin
    if Execute then
    begin
      UpdateChanges;
    end;
  end;
end;

end.
