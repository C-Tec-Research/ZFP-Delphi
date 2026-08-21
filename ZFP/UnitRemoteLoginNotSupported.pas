unit UnitRemoteLoginNotSupported;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormRemoteLoginNotSupported = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ImageButtonX: TImage;
    ImageButtonTick: TImage;
    procedure ImageButtonXClick(Sender: TObject);
    procedure ImageButtonTickClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
  end;

var
  FormRemoteLoginNotSupported: TFormRemoteLoginNotSupported;

implementation

{$R *.dfm}

function TFormRemoteLoginNotSupported.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormRemoteLoginNotSupported.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13:
    begin
      ModalResult := mrOK;
      Key := #0;
    end;
    #27:
    begin
      ModalResult := mrCancel;
      Key := #0;
    end;
  end;
end;

procedure TFormRemoteLoginNotSupported.ImageButtonTickClick(Sender: TObject);
begin
  ModalResult := MROK;
end;

procedure TFormRemoteLoginNotSupported.ImageButtonXClick(Sender: TObject);
begin
  ModalResult := MRCancel;
end;

end.
