unit SigRTFOutput;

interface

{ Intended as a (partially implemented RTF) output object }
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TSigRTFOutput = class(TImage)
  BMP : TBitmap;
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create (AOwner: TComponent); override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigRTFOutput]);
end;

constructor TSigRTFOutput.Create (AOwner: TComponent);
begin
  inherited Create;
end;

end.
