unit UnitThreadSafeComponents;

interface

uses
  System.Classes,
  System.Types,
  VCL.Controls,
  VCL.StdCtrls;

type
  TMemo = class( VCL.StdCtrls.TMemo )
  private
    fLockObject : TObject;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
  end;

implementation

{ TMemo }

constructor TMemo.Create(AOwner: TComponent);
begin
  inherited;
  fLockObject := TObject.Create;
end;

destructor TMemo.Destroy;
begin
  fLockObject.Free;
  inherited;
end;

procedure TMemo.Lock;
begin
  TMonitor.Enter(fLockObject);
end;

procedure TMemo.Unlock;
begin
  TMonitor.Exit(fLockObject);
end;

end.
