unit DynEditRackRoom;

{ The rack room objects }

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
  DynEditObject ;

type
  TDynEditRackRoom = class(TDynEditPlaceableObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create( pMyParent : TDynEditObject ); override;
  published
    { Published declarations }
  end;

implementation

constructor TDynEditRackRoom.Create( pMyParent : TDynEditObject );
begin
  inherited Create( pMyParent );
end;

end.
