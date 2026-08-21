unit USBPanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TBulkUSBPanel = class(TPanel)
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
  RegisterComponents('SigNET', [TBulkUSBPanel]);
end;

end.
