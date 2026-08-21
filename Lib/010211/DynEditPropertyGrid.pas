unit DynEditPropertyGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids,
  DynEditProperty;

type
  TDynEditPropertyGrid = class(TStringGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
    DynEditPropertyList : TDyneditPropertyList;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DynEdit', [TDynEditPropertyGrid]);
end;

constructor TDynEditPropertyGrid.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  DynEditPropertyList := TDynEditPropertyList.Create;
end;

destructor TDynEditPropertyGrid.Destroy;
begin
  DynEditPropertyList.Free;
  inherited Destroy;
end;

end.
