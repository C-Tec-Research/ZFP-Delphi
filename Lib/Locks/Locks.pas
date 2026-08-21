unit Locks;

interface

uses
  System.Generics.Collections;

type
  TLockObject = class
  strict private
    fRefObject : TObject;
    fLockObject : TObject;
  public
    constructor Create( const pRef : TObject );
    destructor Destroy; override;
    property RefObject : TObject
             read fRefObject;
    procedure Lock;
    procedure Unlock;
  end;

  TLocks = class( TObjectList<TLockObject> )
  private
    procedure InternalLock( const pRef : TObject );
    procedure InternalUnlock( const pRef : TObject );
  public
    class procedure Lock( const pRef : TObject );
    class procedure Unlock( const pRef : TObject );
  end;

implementation

var
  FLocks : TLocks;

{ TLockObject }

constructor TLockObject.Create(const pRef: TObject);
begin
  inherited Create;

  fLockObject := TObject.Create;
  fRefObject := pRef;
end;

destructor TLockObject.Destroy;
begin
  // we own FLockObject but not FRefObject

  FLockObject.Free;

  inherited;
end;

procedure TLockObject.Lock;
begin
  TMonitor.Enter( fLockObject );
end;

procedure TLockObject.Unlock;
begin
  TMonitor.Exit( fLockObject );
end;

{ TLocks }

procedure TLocks.InternalLock(const pRef: TObject);
var
  I: Integer;
  iLock : TLockObject;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[ i ].RefObject = pRef then
    begin
      Items[ i ].Lock;
      exit;
    end;
  end;
  // else
  iLock := TLockObject.Create( pRef );
  Add( iLock );
  iLock.Lock;
end;

procedure TLocks.InternalUnlock(const pRef: TObject);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[ i ].RefObject = pRef then
    begin
      Items[ i ].UnLock;
      exit;
    end;
  end;
  // should not get here, but ignore.
end;

class procedure TLocks.Lock(const pRef: TObject);
begin
  FLocks.InternalLock( pRef );
end;

class procedure TLocks.Unlock(const pRef: TObject);
begin
  FLocks.InternalUnlock( pRef );
end;

initialization
  FLocks := TLocks.Create();

finalization
  FLocks.Free;

end.
