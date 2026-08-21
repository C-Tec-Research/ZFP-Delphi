unit DynEditSpeedButton;

{ Like a standard speed button but has a
  TDynEditPlaceable object associated with it
  at run tume. Until it has an object associated
  it is not visible. If it is made not visible,
  the assocition is removed and must be
  re-established to make it visible again }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons;

type
  TDynEditSpeedButton = class(TSpeedButton)
  private
    { Private declarations }
    vPlaceableObject : TDynEditPlaceableObject;
    procedure fSetPlaceableObject( NewVal : TDynEditPlaceableObject );
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property PlaceableObject : TDynEditPlaceableObject
             read vPlaceableObject
             write fSetPlaceableObject;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DynEdit', [TDynEditSpeedButton]);
end;

constructor TDynEditSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  Visible := FALSE;
end;

procedure TDynEditSpeedButton.fSetPlaceableObject( NewVal : TDynEditPlaceableObject );
begin
  vPlaceableObject := NewVal;
  if NewVal = nil then
  begin
    Visible := FALSE;
  end
  else
  begin
    Visible := TRUE;
    Glyph :=
  end;
end;

end.
