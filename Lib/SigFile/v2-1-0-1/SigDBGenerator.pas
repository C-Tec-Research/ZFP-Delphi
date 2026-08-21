unit SigDBGenerator;

interface

uses
  System.SysUtils, System.Classes;

type
  TSigDBGenerator = class(TComponent)
  private
    fFileName: TFileName;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    property SourceFile : TFileName
             read fFileName
             write fFileName;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigDBGenerator]);
end;

end.
