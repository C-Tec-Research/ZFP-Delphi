unit UnitListBoxHelper;

{
  The idea here is to create a helper for combo box items which
  store an ID ( used for storing the data) and a text string
  (to populate the list box).
  Derivitives may add additional items.
  Because this uses TStrings, which are used by both VCL and Firemonkey
  this is not platform dependant, and can in fact, be used for other
  things too.
}

interface

uses
  System.Generics.Collections,
  System.Classes;

type
  TListBoxHelperItem = class
  strict private
  private
    fID: integer;
    fEnglishText: string;
  public
    constructor Create( const pID : integer; const pEnglishText : string );
    property ID : integer
             read fID;
    property EnglishText : string
             read fEnglishText;
  end;

  TListBoxHelperItems< T : TListBoxHelperItem > = class( TObjectList< T > )
  public
    constructor Create; virtual;

    procedure LoadStrings( const pStrings : TStrings ); // this loads all strings. It is also possible to add your own selective ones!

    procedure AddItem( const pWithID : integer; pToList : TStrings );

    function IndexWithID( const pID : integer ) : integer;
    function ObjectWithID( const pID : integer ) : T;
  end;


implementation

{ TListBoxHelperItems }

procedure TListBoxHelperItems<T>.AddItem(const pWithID: integer;
  pToList: TStrings);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].ID = pWithID then
    begin
      pToList.AddObject( Items[ i ].EnglishText, Items[ i ] );
    end;
  end;
end;

constructor TListBoxHelperItems< T >.Create;
begin
  inherited Create( TRUE );
  // actual class builds entries on create;
end;

function TListBoxHelperItems<T>.IndexWithID(const pID: integer): integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].ID = pID then
    begin
      Result := i;
      exit;
    end;
  end;
end;

procedure TListBoxHelperItems<T>.LoadStrings(const pStrings: TStrings);
var
  i: Integer;
begin
  pStrings.Clear;
  for i := 0 to Count - 1 do
  begin
    pStrings.AddObject( Items[ i ].EnglishText, Items[ i ] );
  end;
end;

function TListBoxHelperItems<T>.ObjectWithID(const pID: integer): T;
var
  iIndex : integer;
begin
  iIndex := IndexWithID( pID );
  if iIndex < 0  then
  begin
    Result := nil;
  end
  else
  begin
    Result := Items[ iIndex ];
  end;
end;

{ TListBoxHelperItem }

constructor TListBoxHelperItem.Create(const pID: integer;
  const pEnglishText: string);
begin
  inherited Create;
  fID := pID;
  fEnglishText := pEnglishText;
end;

end.
