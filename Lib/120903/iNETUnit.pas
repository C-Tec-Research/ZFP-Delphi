unit iNETUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Options;

type
  TiNETUnit = class(TImage)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iMoveStart : boolean;
    iSaveX, iSaveY : integer;
    iSaveLeft, iSaveTop : integer;
    procedure fMouseDown( Sender: TObject;
                          Button: TMouseButton;
                          Shift: TShiftState;
                          X, Y: Integer);
    procedure fMouseMove( Sender: TObject;
                          Shift: TShiftState;
                          X, Y: Integer);
    procedure fMouseUp(   Sender: TObject;
                          Button: TMouseButton;
                          Shift: TShiftState;
                          X, Y: Integer);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;

  TiNetCPU = class( TiNETUnit )
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;

  TiNETAmplifier = class( TiNETUnit )
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;

  TiNETPC = class( TiNETUnit )
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TiNETUnit]);
end;

constructor TiNETUnit.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  AutoSize := TRUE;
  iMoveStart := FALSE;
  OnMouseDown := fMouseDown;
  OnMouseMove := fMouseMove;
  OnMouseUp   := fMouseUp;
end;

procedure TiNETUnit.fMouseDown( Sender: TObject;
                          Button: TMouseButton;
                          Shift: TShiftState;
                          X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if Shift = [ ssLeft ] then
    begin
      iMoveStart := TRUE;
      iSaveX := X;
      iSaveY := Y;
      iSaveLeft := Left;
      iSaveTop := Top;
    end;
  end;
end;

procedure TiNETUnit.fMouseMove( Sender: TObject;
                          Shift: TShiftState;
                          X, Y: Integer);
begin
  if iMoveStart then
  begin
    Top := iSaveTop + Y - iSaveY;
    Left := iSaveLeft + X - iSaveX;
  end;
end;

procedure TiNETUnit.fMouseUp( Sender: TObject;
                          Button: TMouseButton;
                          Shift: TShiftState;
                          X, Y: Integer);
begin
  iMoveStart := FALSE;
end;

constructor TiNetCPU.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  Picture.LoadFromFile( Option.CreatePathedString( 'Images\', 'iNetUnit.bmp' ));
end;

constructor TiNETAmplifier.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  Picture.LoadFromFile( Option.CreatePathedString( 'Images\', 'iNetAddressAmp.bmp' ));
end;

constructor TiNETPC.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  Picture.LoadFromFile( Option.CreatePathedString( 'Images\', 'iNetPC.bmp' ));
end;

end.
