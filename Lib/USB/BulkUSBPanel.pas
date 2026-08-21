unit BulkUSBPanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls,
  USBBulkTransferMode,
  UnitTransferInterface;

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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

var
  USBBulkTransferList : tUSBBulkTransferList;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TBulkUSBPanel]);
end;

{ TBulkUSBPanel }

constructor TBulkUSBPanel.Create(AOwner: TComponent);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    if not assigned( USBBulkTransferList ) then
    begin
      USBBulkTransferList := tUSBBulkTransferList.Create;
    end;
  end;
end;

destructor TBulkUSBPanel.Destroy;
begin

  inherited;
end;

initialization

finalization
  if assigned( USBBulkTransferList ) then
  begin
    USBBulkTransferList.Free;
  end;

end.
