unit DynEditPlaceableObject;

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
  DynEditObject;

type
  TDynEditPlaceableObject = class(TDynEditObject)
  private
    { Private declarations }
  protected
    { Protected declarations }
    X, Y : LongInt;
    Width, Height : LongInt;
    MinWidth, MinHeight : LongInt;
    Autosize : Boolean;
  public
    { Public declarations }
    constructor Create( pMyParent : TDynEditObject ); override;
    class procedure DrawObjectGhost( const Canvas : TCanvas;
            var Rect : TRect ); virtual;
    class procedure ClearObjectGhost( const Canvas : TCanvas;
            var Rect : TRect ); virtual;
    procedure DrawObject( Canvas : TCanvas; Zoom : integer; Rect : TRect );
  published
    { Published declarations }
  end;

implementation

constructor TDynEditPlaceableObject.Create( pMyParent : TDynEditObject );
begin
  inherited Create( pMyParent );
  x := 0;
  y := 0;
  Width := 32;
  Height := 32;
  MinWidth := 32;
  MinHeight := 32;
  Autosize := FALSE;
end;

class procedure TDynEditPlaceableObject.DrawObjectGhost( const Canvas : TCanvas;
            var Rect : TRect );
begin
  { by default, draw elastic band }
  with Canvas do
  begin
    DrawFocusRect( Rect );
  end;
end;

class procedure TDynEditPlaceableObject.ClearObjectGhost( const Canvas : TCanvas;
            var Rect : TRect );
begin
  { by default, draw elastic band }
  with Canvas do
  begin
    DrawFocusRect( Rect );
  end;
end;

end.
