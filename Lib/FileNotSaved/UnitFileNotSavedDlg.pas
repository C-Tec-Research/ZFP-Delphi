unit UnitFileNotSavedDlg;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  Vcl.Dialogs,
  UnitFileNotSaved;

type
  TFileNotSavedResult = ( fns_SaveNow, fns_DontSave, fns_Cancel );

  TFileNotSavedDlg = class(TComponent)
  private
    { Private declarations }
    fFormFileNotSaved : TFormFileNotSaved;
  protected
    { Protected declarations }
  public
    { Public declarations }
    function Execute : TFileNotSavedResult;
  published
    { Published declarations }
    xxx;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TFileNotSavedDlg]);
end;

{ TFileNotSavedDlg }

function TFileNotSavedDlg.Execute: TFileNotSavedResult;
begin
  if not assigned( fFormFileNotSaved ) then
  begin
    fFormFileNotSaved := TFormFileNotSaved.Create( self );
  end;
  with fFormFileNotSaved do
  begin
    // assign properties
  end;
  case fFormFileNotSaved.ShowModal of
    mrYES: Result := fns_SaveNow;
    mrNO:  Result := fns_DontSave;
    else
    begin
      Result := fns_Cancel;
    end;
  end;
end;

end.
