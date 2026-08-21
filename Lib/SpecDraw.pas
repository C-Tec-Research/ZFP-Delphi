unit SpecDraw;

{ special draw functions (and editors?) for grids }

interface

uses
  Graphics,
  Windows;

procedure Draw3dCheck( Canvas : TCanvas; Rect : TRect; Checked : boolean );

implementation

procedure Draw3dCheck( Canvas : TCanvas; Rect : TRect; Checked : boolean );
var
  BoxRect : TRect;
  BoxWidth : integer;
  BoxHeight : integer;
begin
  with Canvas do
  begin
    { draw silver rectangle }
    Pen.Width := 1;
    Pen.Style := psSolid;
    Pen.Color := clSilver;
    Brush.Color := clSilver;
    Rectangle( Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
    { calculate square for check box. Allow 2 pixel border, but make square }
    BoxHeight := Rect.Bottom - Rect.Top - 6;
    BoxWidth := Rect.Right - Rect.Left - 6;
    if BoxWidth < BoxHeight then BoxHeight := BoxWidth else BoxWidth := BoxHeight;
    BoxRect.Top := (Rect.Top + Rect.Bottom - BoxHeight) div 2;
    BoxRect.Bottom := BoxRect.Top + BoxHeight;
    BoxRect.Left := (Rect.Left + Rect.Right - BoxWidth) div 2;
    BoxRect.Right := BoxRect.Left + BoxWidth;
    { draw white square }
    Pen.Color := clRed;
    Brush.Color := clWhite;
    Rectangle( BoxRect.Left, BoxRect.Top, BoxRect.Right, BoxRect.Bottom);
    { give 3d effect }
    Pen.Color := clGray;
    MoveTo( BoxRect.Left, BoxRect.Bottom );
    LineTo( BoxRect.Left, BoxRect.Top );
    LineTo( BoxRect.Right, BoxRect.Top );
    Pen.Color := clWhite;
    LineTo( BoxRect.Right, BoxRect.Bottom );
    LineTo( BoxRect.Left, BoxRect.Bottom );
    Inc( BoxRect.Left );
    Inc( BoxRect.Top );
    Dec( BoxRect.Right );
    Dec( BoxRect.Bottom );
    Pen.Color := clGray;
    MoveTo( BoxRect.Left, BoxRect.Bottom );
    LineTo( BoxRect.Left, BoxRect.Top );
    LineTo( BoxRect.Right, BoxRect.Top );
    Pen.Color := clWhite;
    LineTo( BoxRect.Right, BoxRect.Bottom );
    LineTo( BoxRect.Left, BoxRect.Bottom );
    Inc( BoxRect.Left );
    Inc( BoxRect.Top );
    Dec( BoxRect.Right );
    Dec( BoxRect.Bottom );
    MoveTo( BoxRect.Left, BoxRect.Bottom);
    LineTo( BoxRect.Left, BoxRect.Top );
    LineTo( BoxRect.Right, BoxRect.Top );
    Pen.Color := clSilver;
    LineTo( BoxRect.Right, BoxRect.Bottom );
    LineTo( BoxRect.Left, BoxRect.Bottom );
    { and the X if Checked }
    if Checked then
    begin
      Inc( BoxRect.Left, 2 );
      Inc( BoxRect.Top, 2 );
      Dec( BoxRect.Right, 2 );
      Dec( BoxRect.Bottom, 2 );
      Pen.Width := 2;
      Pen.Color := clBlack;
      MoveTo( BoxRect.Left, BoxRect.Top );
      LineTo( BoxRect.Right, BoxRect.Bottom );
      MoveTo( BoxRect.Right, BoxRect.Top );
      LineTo( BoxRect.Left, BoxRect.Bottom );
    end;
    // Put back to something sensible
    Pen.Color := clBlack;
    Pen.Width := 1;
  end;
end;

end.
