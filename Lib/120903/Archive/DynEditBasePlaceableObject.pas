unit DynEditBasePlaceableObject;

{ Base placeable object. Used as blank base for screen.
  Holds the blank Grahics area }

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DynEditPlaceableObject,
  DynEditObject;

type
  TDynEditBasePlaceableObject = class(TDynEditPlaceableObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create( pMyParent : TDynEditObject ); override;
{ the following functions should be redefined for every object }
    function MyName : string; override;
  published
    { Published declarations }
  end;

implementation

constructor TDynEditBasePlaceableObject.Create( pMyParent : TDynEditObject );
begin
  inherited Create( pMyParent );
  Autosize := TRUE;
  DynEditProperty.DynEditProperty[ 'FileName' ] := '';
end;

function TDynEditBasePlaceableObject.MyName : string;
begin
  Result := 'File';
end;

end.
