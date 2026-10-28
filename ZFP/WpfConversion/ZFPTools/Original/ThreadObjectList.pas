unit ThreadObjectList;

{
  Just a clone of TThreadList but using TObjectList instead of TList. We don't
  use the duplicates property.

  The general constructs are:

  for functions if the TObjectList format is

  function xxx(...) : yyy;

  the corresponding TThreadObjectList function body will be

  function TThreadObjectList.xxx(...) : yyy;
  begin
    LockList
    try
      Result := FList.xxx(...);
    finally
      UnlockList;
    end;
  end;

  Similarly for procedures if the format is

  procedure xxx(...);

  the corresponding TThreadObjectList procedure body will be

  procedure TThreadObjectList.xxx(...);
  begin
    LockList
    try
      FList.xxx(...);
    finally
      UnlockList;
    end;
  end;
}

interface

uses
  System.Classes,
  System.Types,
  System.Contnrs;

type
  tThreadObjectList = class
  private
    FList: TObjectList;
    FLock: TObject;
    function GetItem(Index: Integer): TObject;
    procedure SetItem(Index: Integer; const Value: TObject);
    function GetOwnsObjects: boolean;
    procedure SetOwnsObjects(const Value: boolean);
  public
    constructor Create( const pOwnsObjects : boolean = FALSE );
    destructor Destroy; override;
    function Add(Item: TObject) : integer;
    procedure Clear;
    function LockList: TObjectList;
    procedure Remove(Item: TObject); inline;
    procedure RemoveItem(Item: TObject; Direction: TList.TDirection);
    procedure UnlockList; inline;
    function Count : integer;
    procedure Pack;
    procedure Delete(Index: Integer);

    property Items[Index: Integer]: TObject
             read GetItem write
             SetItem; default;
    property OwnsObjects : boolean
             read GetOwnsObjects
             write SetOwnsObjects;
    function IndexOf( AObject : TObject ) : integer; inline;
  end;

implementation

{ tThreadObjectList }

function tThreadObjectList.Add(Item: TObject): integer;
begin
  LockList;
  try
    Result := FList.Add(Item)
  finally
    UnlockList;
  end;
end;

procedure tThreadObjectList.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
    UnlockList;
  end;
end;

function tThreadObjectList.Count: integer;
begin
  LockList;
  try
    Result := fList.Count;
  finally
    UnlockList;
  end;
end;

constructor tThreadObjectList.Create(const pOwnsObjects: boolean);
begin
  inherited Create;
  FLock := TObject.Create;
  FList := TObjectList.Create( pOwnsObjects );
end;

procedure tThreadObjectList.Delete(Index: Integer);
begin
  LockList;
  try
    FList.Delete( Index );
  finally
    UnlockList;
  end;
end;

destructor tThreadObjectList.Destroy;
begin
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    FLock.Free;
  end;
end;

function tThreadObjectList.GetItem(Index: Integer): TObject;
begin
  LockList;
  try
    Result := FList.Items[ Index ];
  finally
    UnlockList;
  end;
end;

function tThreadObjectList.GetOwnsObjects: boolean;
begin
  Result := fList.OwnsObjects;
end;

function tThreadObjectList.IndexOf(AObject: TObject): integer;
begin
  Result := fList.IndexOf( AObject );
end;

function TThreadObjectList.LockList: TObjectList;
begin
  TMonitor.Enter(FLock);
  Result := FList;
end;

procedure tThreadObjectList.Pack;
begin
  LockList;
  try
    FList.Pack;
  finally
    UnlockList;
  end;
end;

procedure tThreadObjectList.Remove(Item: TObject);
begin
  RemoveItem(Item, TList.TDirection.FromBeginning);
end;

procedure tThreadObjectList.RemoveItem(Item: TObject;
  Direction: TList.TDirection);
begin
  LockList;
  try
    FList.RemoveItem(Item, Direction);
  finally
    UnlockList;
  end;
end;

procedure tThreadObjectList.SetItem(Index: Integer; const Value: TObject);
begin
  LockList;
  try
    FList.Items[ Index ] := Value;
  finally
    UnlockList;
  end;
end;

procedure tThreadObjectList.SetOwnsObjects(const Value: boolean);
begin
  fList.OwnsObjects := Value;
end;

procedure tThreadObjectList.UnlockList;
begin
  TMonitor.Exit(FLock);
end;

end.
