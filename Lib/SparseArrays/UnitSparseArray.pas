unit UnitSparseArray;

{
  sparse arrays. Based on object lists, have a deffault object to be
  returned if no entry found.
}

interface

uses
  contnrs;

type
  tSparseObject = class
  private
    fID: integer;
    // descend your sparse objects from this, adding whatever values
    // you wish
  public
    constructor Create( pID : integer );
    property ID : integer
             read fID;
  end;

type
  tSparseObjectList = class( tObjectList )
  private
    function GetItem(const index: integer): tSparseObject;
    procedure SetItem(const index: integer; const Value: tSparseObject);
    function GetIndexedItem(const index: integer): tSparseObject;
    property IndexedItem[ const index : integer ] : tSparseObject
             read GetIndexedItem;
  public
    constructor Create; reintroduce;
    property Item[ const index : integer ] : tSparseObject
             read GetItem
             write SetItem;
  end;

implementation

{ tSparseObject }

constructor tSparseObject.Create(pID: integer);
begin
  inherited Create;
  fID := pID;
end;

{ tSparseObjectList }

constructor tSparseObjectList.Create;
begin
  inherited Create( TRUE );
end;

function tSparseObjectList.GetIndexedItem(const index: integer): tSparseObject;
begin
  Result := Items[ index ] as tSparseObject;
end;

function tSparseObjectList.GetItem(const index: integer): tSparseObject;
begin
  Result := nil;
end;

procedure tSparseObjectList.SetItem(const index: integer;
  const Value: tSparseObject);
begin

end;

end.
