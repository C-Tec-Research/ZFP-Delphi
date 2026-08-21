unit TypedObjectList;

interface

uses
  System.UITypes,
  System.Contnrs,
  System.Classes,
  System.Types;

type
  TTypedObjectList< T : class > = class( TObjectList )
  private
    fLockObject : TObject;
    function GetItem(const i: integer): T;
    function GetMax: integer;
  protected
  public
    constructor Create( const pOwnsObjects : boolean = TRUE ); reintroduce; virtual;
    destructor Destroy; override;

    function Add( pValue : T ) : integer; reintroduce; virtual;
    function Extract(Item: T): T; reintroduce; virtual;
    function ExtractItem(Item: T; Direction: TList.TDirection): T; reintroduce; virtual;
    function Remove(AObject: T): Integer; reintroduce; overload; virtual;
    function RemoveItem(AObject: T; ADirection: TList.TDirection): Integer; reintroduce; virtual;
    function IndexOf(AObject: T): Integer; reintroduce; virtual;
    function IndexOfItem(AObject: T; ADirection: TList.TDirection): Integer; reintroduce; virtual;
    procedure Insert(Index: Integer; AObject: T); reintroduce; virtual;
    function First: T; reintroduce; virtual;
    function Last: T; reintroduce; virtual;

    procedure Lock;
    procedure Unlock;

    property Item[ const i : integer ] : T
             read GetItem; default;
    property Max : integer
             read GetMax;
  end;

implementation

{ TTypedObjectList<T> }

function TTypedObjectList<T>.Add(pValue: T): integer;
begin
  Result := inherited Add( pValue );
end;

constructor TTypedObjectList<T>.Create( const pOwnsObjects : boolean = TRUE );
begin
  inherited Create( pOwnsObjects );

  fLockObject := TObject.Create;
end;

destructor TTypedObjectList<T>.Destroy;
begin
  fLockObject.Free;
  inherited;
end;

function TTypedObjectList<T>.Extract(Item: T): T;
begin
  Result := inherited Extract( Item ) as T;
end;

function TTypedObjectList<T>.ExtractItem(Item: T;
  Direction: TList.TDirection): T;
begin
  Result := inherited ExtractItem( Item, Direction ) as T;
end;

function TTypedObjectList<T>.First: T;
begin
  Result := inherited First as T;
end;

function TTypedObjectList<T>.GetItem(const i: integer): T;
begin
  Result := Items[ i ] as T;
end;

function TTypedObjectList<T>.GetMax: integer;
begin
  Result := Count - 1;
end;

function TTypedObjectList<T>.IndexOf(AObject: T): Integer;
begin
  Result := inherited IndexOf( AObject );
end;

function TTypedObjectList<T>.IndexOfItem(AObject: T;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited IndexOfItem( AObject, ADirection );
end;

procedure TTypedObjectList<T>.Insert(Index: Integer; AObject: T);
begin
  inherited Insert( Index, AObject );
end;

function TTypedObjectList<T>.Last: T;
begin
  Result := inherited Last as T;
end;

procedure TTypedObjectList<T>.Lock;
begin
  TMonitor.Enter( fLockObject );
end;

function TTypedObjectList<T>.Remove(AObject: T): Integer;
begin
  Result := inherited Remove( AObject );
end;

function TTypedObjectList<T>.RemoveItem(AObject: T;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited RemoveItem( AObject, ADirection );
end;

procedure TTypedObjectList<T>.Unlock;
begin
  TMonitor.Exit( fLockObject );
end;

end.
