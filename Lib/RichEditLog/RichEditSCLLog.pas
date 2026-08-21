unit RichEditSCLLog;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, ComCtrls, RichEditLog;

type
  TRichEditSCLLog = class(TRichEditLog)
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
  RegisterComponents('SigNET', [TRichEditSCLLog]);
end;

end.
