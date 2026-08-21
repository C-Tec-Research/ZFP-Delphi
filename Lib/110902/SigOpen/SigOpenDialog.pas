unit SigOpenDialog;

interface

uses
  SysUtils, Classes, Dialogs,
  SigRegistry;

type
  TOnLoad = procedure (Sender : tObject; var pOK : boolean ) of object;
  TOnHistoryChange = procedure( Sender : tObject ) of object;

type
  TSigOpenDialog = class(TOpenDialog)
  private
    fSigRegistry: tSigRegistry;
    fOnHistoryChange: tOnHistoryChange;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    property SigRegistry : tSigRegistry
             read fSigRegistry
             write fSigRegistry;
  published
    { Published declarations }
    property OnHistoryChange : tOnHistoryChange
             read fOnHistoryChange
             write fOnHistoryChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigOpenDialog]);
end;

end.
