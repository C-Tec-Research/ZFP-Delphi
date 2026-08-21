unit DynEditConstructorButton;

{ These buttons create DynEdit Objects through DLLs, and contain
  the necessary additional information to use those DLLs. }
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
  Buttons;

type
  TDynEditConstructorButton = class(TSpeedButton)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iInternalIndex : integer;
  public
    { Public declarations }
  published
    { Published declarations }
    property
      InternalIndex : integer
                    read iInternalIndex
                    write iInternalIndex;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DynEdit', [TDynEditConstructorButton]);
end;

end.
