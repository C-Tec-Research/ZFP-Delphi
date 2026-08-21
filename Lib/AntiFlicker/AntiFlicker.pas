unit AntiFlicker;

interface

{
  Usage:

  BeginUpdate and EndUpdate should only occur in pairs, so use this
  methodology:

  AntiFlicker.BeginUpdate;
  try
    ...
  finally
    AntiFlicker.Endupdate;
  end;

  Can be safely nested.
}

uses
  VCL.Controls,
  Windows,
  Messages;

type
  TAntiFlicker = class
  private
    FCount : integer;
    FOwner : TWinControl;
    FInvalidateOnCompletion : boolean;
  public
    procedure BeginUpdate;
    procedure EndUpdate;
    constructor Create( const pOwner : TWinControl; pInvalidateOnCompletion : boolean );
  end;

implementation

{ TAntiFlicker }

procedure TAntiFlicker.BeginUpdate;
begin
  if FCount = 0 then
  begin
    SendMessage( FOwner.Handle, WM_SETREDRAW, WPARAM( FALSE ), 0 );
  end;
  inc( FCount );
end;

constructor TAntiFlicker.Create(const pOwner: TWinControl; pInvalidateOnCompletion : boolean);
begin
  inherited Create;
  FOwner := pOwner;
  FInvalidateOnCompletion := pInvalidateOnCompletion;
end;

procedure TAntiFlicker.EndUpdate;
begin
  if FCount > 0 then
  begin
    dec( FCount );
    if FCount = 0 then
    begin
      SendMessage( FOwner.Handle, WM_SETREDRAW, WPARAM( TRUE ), 0 );
      if FInvalidateOnCompletion then
      begin
        FOwner.Invalidate;
      end;
    end;
  end;
end;

end.
