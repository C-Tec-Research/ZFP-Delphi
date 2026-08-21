unit FmxSigFileObject;

interface

uses
  System.SysUtils, System.Classes, FMX.Types;

type
  TFmxSigFileObject = class(TFmxObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FMX SigFile', [TFmxSigFileObject]);
end;

end.
