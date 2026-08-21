unit UnitManagedControlList;

interface

{
  A managed cotrol list is a list of visual components that
  behave in sympathy.
  Add a control to the list and then setting the
  enabled, disabled and so on properties of the list
  repeat that action for all the contained controls
}

uses
  Contnrs,
  Controls;

type
  TManagedControlList = class( TObjectList )
  protected
    iEnabled : boolean;
    procedure fSetEnabled( NewVal : boolean );
    function fGetItem( index : integer ) : TControl;
  public
    constructor Create;
    function Add( NewVal : TControl ) : integer; reintroduce;
    property Enabled : boolean
             read iEnabled
             write fSetEnabled;
    property Item[ index : integer ] : TControl
             read fGetItem;
  end;

implementation

//----------------- TManagedControlList -------------------

constructor TManagedControlList.Create;
begin
  inherited Create;
  iEnabled := TRUE;
end;

procedure TManagedControlList.fSetEnabled( NewVal : boolean );
var
  i : integer;
begin
  if iEnabled <> NewVal then
  begin
    iEnabled := NewVal;
    for i := 0 to Count - 1 do
    begin
      Item[ i ].Enabled := NewVal;
    end;
  end;
end;

function TManagedControlList.fGetItem( index : integer ) : TControl;
begin
  result := TControl( Items[ index ] );
end;

function TManagedControlList.Add( NewVal : TControl ) : integer;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Item[ i ] = NewVal then // duplicate
    begin
      Result := i;
      exit;
    end;
  end;
  // really new value
  Result := inherited Add( NewVal );
  NewVal.Enabled := iEnabled;
end;


end.
