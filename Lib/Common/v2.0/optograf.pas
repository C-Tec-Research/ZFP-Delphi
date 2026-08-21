unit Optograf;

{ This takes a function that has a number of parameters
  and optimises the parameters to try and achieve a
  result at those points }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Common;

type
  TGrabHandleData = Record
  X, GrabHandleY, ParameterX {=Y} : integer;
  MapGrabHandleX, MapGrabHandleY : integer;
end;

type
  TGraphFunction = function (Sender : Tobject;
                 const AtX : integer;
                 const ArraySize : integer;
                 const Params : array of TGrabHandleData;
                 var Error : boolean ) : integer
                 of object;
type
  TOptoGraph = class(TPaintBox)
  private
    { Private declarations }
    iBorderColour, iBackgroundColour : TColor;
    iAxisXColour, iAxisYColour : TColor;
    iTickXColour, iTickYColour : TColor;
    iGraphColour, iGraphErrorColour : TColor;
    iGrabHandleColour : TColor;

    iGraphFunction : TGraphFunction;
    iMinX, iMaxX, iTickX : integer;
    iMinY, iMaxY, iTickY : integer;
    iXPoints : integer; { the number of points in the array }
    iPoints : array [ 1 .. 50 ] of TGrabHandleData;
    ErrorCheck : boolean;

    iOptimize : boolean;

    iSpreadGrabHandles : boolean;
    ActiveGrabHandle : integer;

    procedure fWriteBorderColour( NewColour : TColor );
    procedure fWriteBackgroundColour( NewColour : TColor );
    procedure fWriteAxisXColour( NewColour : TColor );
    procedure fWriteAxisYColour( NewColour : TColor );
    procedure fWriteTickXColour( NewColour : TColor );
    procedure fWriteTickYColour( NewColour : TColor );

    procedure fWriteGraphColour( NewColour : TColor );
    procedure fWriteGraphErrorColour( NewColour : TColor );
    procedure fWriteGrabHandleColour( NewColour : TColor );

    procedure fWriteMinX( NewVal : Integer );
    procedure fWriteMaxX( NewVal : Integer );
    procedure fWriteTickX( NewVal : Integer );
    procedure fWriteMinY( NewVal : Integer );
    procedure fWriteMaxY( NewVal : Integer );
    procedure fWriteTickY( NewVal : Integer );

    procedure fWriteXPoints( NewVal : integer );
    procedure fWritePoint( index : integer ; Value : TPoint);
    function fReadPoint ( index : integer ) : TPoint;

    procedure fOptimize;
    function doGraphFunction( iTemp : integer ) : integer;

    function DefaultGraphFunction(Sender: TObject; const AtX,
      ArraySize: Integer; const Params: array of TGrabHandleData;
      var Error: Boolean): Integer;
    procedure fSpreadGrabHandles;
  protected
    { Protected declarations }
    procedure WMPaint( var Message : TWMPaint) ;
              message WM_PAINT;
    procedure WMKillFocus( var Message : TWMKillFocus );
              message WM_KillFocus;
    procedure WMLButtonUp( var Message : TWMLButtonUp );
              message WM_LButtonUp;
    procedure WMLButtonDown( var Message : TWMLButtonDown );
              message WM_LButtonDown;
    procedure WMMouseMove( var Message : TWMMouseMove );
              message WM_MouseMove;
    procedure DrawXTicks; virtual;
    procedure DrawYTicks; virtual;
    procedure DrawGrabHandles; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Optimize;
    property Point[ index: integer ] : TPoint
             read fReadPoint
             write fWritePoint;
  published
    { Published declarations }
    property BorderColour : TColor
             read iBorderColour
             write fWriteBorderColour
             default clBlack;
    property BackgroundColour : TColor
             read iBackgroundColour
             write iBackgroundColour
             default clWhite;
    property AxisXColour : TColor
             read iAxisXColour
             write fWriteAxisXColour
             default clGray;
    property AxisYColour : TColor
             read iAxisYColour
             write fWriteAxisYColour
             default clGray;
    property TickXColour : TColor
             read iTickXColour
             write fWriteTickXColour
             default clGray;
    property TickYColour : TColor
             read iTickYColour
             write fWriteTickYColour
             default clGray;
    property GraphColour : TColor
             read iGraphColour
             write fWriteGraphColour
             default clBlue;
    property GraphErrorColour : TColor
             read iGraphErrorColour
             write fWriteGraphErrorColour
             default clRed;
    property GrabHandleColour : TColor
             read iGrabHandleColour
             write fWriteGrabHandleColour
             default clBlack;
    property GraphFunction : TGraphFunction
             read iGraphFunction
             write iGraphFunction;
    property GrabHandles : integer
             read iXPoints
             write fWriteXPoints
             default 10;
    property MinX : integer
             read iMinX
             write fWriteMinX
             default -50;
    property MaxX : integer
             read iMaxX
             write fWriteMaxX
             default 50;
    property TickX : integer
             read iTickX
             write fWriteTickX
             default 10;
    property MinY : integer
             read iMinY
             write fWriteMinY
             default -50;
    property MaxY : integer
             read iMaxY
             write fWriteMaxY
             default 50;
    property TickY : integer
             read iTickY
             write fWriteTickY
             default 10;
    property SpreadGrabHandles : boolean
             read iSpreadGrabHandles
             write iSpreadGrabHandles
             default TRUE;
  end;

procedure Register;

implementation

constructor TOptoGraph.Create(AOwner: TComponent);
var
  i : integer;
  v, x : integer;
begin
  inherited Create( AOwner );

  iBorderColour := clBlack;
  iBackgroundColour := clWhite;
  iAxisXColour := clGray;
  iAxisYColour := clGray;
  iTickXColour := clGray;
  iTickYColour := clGray;
  iGraphColour := clBlue;
  iGraphErrorColour := clRed;
  iGrabHandleColour := clBlack;

  iXPoints := 10;
  iMinX := -50;
  iMaxX := 50;
  iTickX := 10;
  iMinY := -50;
  iMaxY := 50;
  iTickY := 10;
  { set points to a decay function... }
  x := iMinX;
  v := iMaxY;
  fSpreadGrabHandles;
  for i := 1 to iXPoints do
  begin
    iPoints[i].GrabHandleY := v;
    iPoints[i].ParameterX := 0;
    v := -v div 2;
  end;
  iOptimize := True;

  ActiveGrabHandle := 0;

  iSpreadGrabHandles := TRUE;

end;

procedure TOptoGraph.WMKillFocus( var Message : TWMKillFocus );
begin
  { release grab handle, if any; }
  ActiveGrabHandle := 0;
  MouseCapture := FALSE;
end;

procedure TOptoGraph.WMLButtonUp( var Message : TWMLButtonUp );
begin
  { release grab handle, if any; }
  ActiveGrabHandle := 0;
  iOptimize := TRUE;
  MouseCapture := FALSE;
  invalidate;
end;

procedure TOptoGraph.WMLButtonDown( var Message : TWMLButtonDown );
var
  i : integer;
begin
  { ignore if we are already processing a handle }
  if ActiveGrabHandle = 0 then
  begin
    with Message do
    begin
      { see if we are within a handle }
      for i := 1 to iXPoints do
      begin
        with iPoints [i] do
        begin
          if  (XPos > MapGrabHandleX - 4)
          and (XPos < MapGrabHandleX + 4)
          and (YPos > MapGrabHandleY - 4)
          and (YPos < MapGrabHandleY + 4)
          then
          begin
            ActiveGrabHandle := i;
            MouseCapture := TRUE;
          end;
        end;
      end;
    end;
  end;
end;

procedure TOptoGraph.WMMouseMove( var Message : TWMMouseMove );
begin
  if ActiveGrabHandle > 0 then
  begin
    with iPoints[ ActiveGrabHandle ] do
    begin
      GrabHandleY := Map( Height, 0, iMinY, iMaxY, Message.YPos );
    end;
    { if we move to edge of client area, drop move }
    if (Message.YPos <= 0) or (Message.YPos >= Height - 1) then
    begin
      ActiveGrabHandle := 0;
      iOptimize := TRUE;
      MouseCapture := FALSE;
    end;
    invalidate;
  end;
end;

procedure TOptoGraph.WMPaint( var Message : TWMPaint) ;
var
  iTemp : integer;
  tickTemp : integer;
  i : integer;
begin
  inherited;
  { Check if we need to optimize }
  if (iOptimize) then
  begin
    fOptimize;
    iOptimize := FALSE;
  end;
  { White coloured rectangle, by default }
  with Canvas do
  begin
    { override default pen style = dashed }
    Pen.Style := psSolid;
    Brush.Style := bsSolid;

    { the background }
    Pen.Color := iBorderColour;
    Brush.Color := iBackgroundColour;
    Rectangle( 0, 0, Width, Height );

    { Y... }
    Pen.Color := iAxisYColour;
    iTemp := Map( iMinX, iMaxX, 0, Width, 0);
    MoveTo( iTemp, 0 );
    LineTo( iTemp, Height );

    { The Axes }
    { X... }
    Pen.Color := iAxisXColour;
    iTemp := Map( iMinY, iMaxY, Height, 0, 0);
    MoveTo( 0, iTemp );
    LineTo( Width, iTemp );

    { the tick marks, +- 2 pixel }
    Pen.Color := iTickXColour;
    { negative axis }
    i := -iTickX;
    while i > iMinX do
    begin
      tickTemp := Map( iMinX, iMaxX, 0, Width, i );
      MoveTo( tickTemp, iTemp - 2 );
      LineTo( tickTemp, iTemp + 2 );
      Dec( i, iTickX );
    end;
    { positive axis }
    i := iTickX;
    while i < iMaxX do
    begin
      tickTemp := Map( iMinX, iMaxX, 0, Width, i );
      MoveTo( tickTemp, iTemp - 2 );
      LineTo( tickTemp, iTemp + 2 );
      Inc( i, iTickX );
    end;

    { Draw the tick Marks }

    DrawXTicks;
    DrawYTicks;

    { draw the curve }
    MoveTo( 0, iTemp);
    for i := 0 to Width do
    begin
      iTemp := Map( 0, Width, iMinX, iMaxX, i);
      if Assigned( iGraphFunction ) then
      begin
        tickTemp := iGraphFunction( self, iTemp,
                    iXPoints, iPoints, ErrorCheck );
      end
      else
      begin
        tickTemp := DefaultGraphFunction( self, iTemp,
                    iXPoints, iPoints, ErrorCheck );
      end;

      if ErrorCheck then
      begin
        Pen.Color := GraphErrorColour;
      end
      else
      begin
        Pen.Color := GraphColour;
      end;
      LineTo(i, Map( iMinY, iMaxY, Height, 0, tickTemp ));
    end;

    { draw grab handles }
    DrawGrabHandles;

  end;
end;

procedure TOptoGraph.DrawGrabHandles;
var
  i : integer;
begin
  with Canvas do
  begin
    { override default pen style = dashed }
    Pen.Style := psSolid;

    { draw grab handles }
    Pen.Color := GrabHandleColour;
    Brush.Style := bsClear;
    for i := 1 to iXPoints do
    begin
      with iPoints[i] do
      begin
        MapGrabHandleX := Map( iMinX, iMaxX, 0, Width, X);
        MapGrabHandleY := Map( iMinY, iMaxY, Height, 0,
                          GrabHandleY );
        Rectangle( MapGrabHandleX - 4, MapGrabHandleY - 4,
                   MapGrabHandleX + 4, MapGrabHandleY + 4 );
      end;
    end;
  end;
end;

procedure TOptoGraph.DrawYTicks;
var
  iTemp : integer;
  tickTemp : integer;
  i : integer;
begin
  with Canvas do
  begin
    { override default pen style = dashed }
    Pen.Style := psSolid;

    { the tick marks, +- 2 pixel }
    Pen.Color := iTickYColour;
    { negative axis }
    iTemp := Map( iMinX, iMaxX, 0, Width, 0);
    i := -iTickY;
    while i > iMinY do
    begin
      tickTemp := Map( iMinY, iMaxY, Height, 0, i );
      MoveTo( iTemp - 2, tickTemp );
      LineTo( iTemp + 2, tickTemp );
      Dec( i, iTickY );
    end;
    { positive axis }
    i := iTickY;
    while i < iMaxY do
    begin
      tickTemp := Map( iMinY, iMaxY, Height, 0, i );
      MoveTo( iTemp - 2, tickTemp );
      LineTo( iTemp + 2, tickTemp );
      Inc( i, iTickY );
    end;

  end;
end;

procedure TOptoGraph.DrawXTicks;
var
  iTemp : integer;
  tickTemp : integer;
  i : integer;
begin
  with Canvas do
  begin
    { override default pen style = dashed }
    Pen.Style := psSolid;
    Brush.Style := bsSolid;

    { the tick marks, +- 2 pixel }
    Pen.Color := iTickXColour;
    iTemp := Map( iMinY, iMaxY, Height, 0, 0);
    { negative axis }
    i := -iTickX;
    while i > iMinX do
    begin
      tickTemp := Map( iMinX, iMaxX, 0, Width, i );
      MoveTo( tickTemp, iTemp - 2 );
      LineTo( tickTemp, iTemp + 2 );
      Dec( i, iTickX );
    end;
    { positive axis }
    i := iTickX;
    while i < iMaxX do
    begin
      tickTemp := Map( iMinX, iMaxX, 0, Width, i );
      MoveTo( tickTemp, iTemp - 2 );
      LineTo( tickTemp, iTemp + 2 );
      Inc( i, iTickX );
    end;

  end;
end;

procedure TOptoGraph.fWriteXPoints( NewVal : integer );
begin
  if NewVal < 2 then iXPoints := 2
  else if NewVal > 50 then iXPoints := 50
  else iXPoints := NewVal;
  { release grab handle, if any; }
  ActiveGrabHandle := 0;
  { spread grab handles if supposed to }
  if iSpreadGrabHandles then fSpreadGrabHandles;
  invalidate;
end;

procedure TOptoGraph.fSpreadGrabHandles;
var
  i : integer;
begin
  for i := 1 to iXPoints do
  begin
    iPoints[i].X := Map( 1, iXPoints, iMinX, iMaxX, i);
  end;
end;

procedure TOptoGraph.fWritePoint( index : integer ; Value : TPoint);
begin
  if (index > 0) and (index <= iXPoints) then
  begin
    iPoints[ index ].X := Value.X;
    iPoints[ index ].GrabHandleY := Value.Y;
  end;
  invalidate;
end;

function TOptoGraph.fReadPoint ( index : integer ) : TPoint;
begin
  if (index > 0) and (index <= iXPoints) then
  begin
    Result.X := iPoints[ index ].X;
    Result.Y := iPoints[ index ].GrabHandleY;
  end
  else
    raise ERangeError.Create('Graph index' + IntToStr(index) +
          ' not in range 1-' + IntToStr( iXPoints ));
end;

procedure TOptoGraph.fWriteBorderColour( NewColour : TColor );
begin
  iBorderColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteBackgroundColour( NewColour : TColor );
begin
  iBackgroundColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteAxisXColour( NewColour : TColor );
begin
  iAxisXColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteAxisYColour( NewColour : TColor );
begin
  iAxisYColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteTickXColour( NewColour : TColor );
begin
  iTickXColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteTickYColour( NewColour : TColor );
begin
  iTickYColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteGraphColour( NewColour : TColor );
begin
  iGraphColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteGraphErrorColour( NewColour : TColor );
begin
  iGraphErrorColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteGrabHandleColour( NewColour : TColor );
begin
  iGrabHandleColour := NewColour;
  invalidate;
end;

procedure TOptoGraph.fWriteMinX( NewVal : Integer );
begin
  iMinX := NewVal;
  invalidate;
end;

procedure TOptoGraph.fWriteMaxX( NewVal : Integer );
begin
  iMaxX := NewVal;
  invalidate;
end;

procedure TOptoGraph.fWriteTickX( NewVal : Integer );
begin
  iTickX := NewVal;
  invalidate;
end;

procedure TOptoGraph.fWriteMinY( NewVal : Integer );
begin
  iMinY := NewVal;
  invalidate;
end;

procedure TOptoGraph.fWriteMaxY( NewVal : Integer );
begin
  iMaxY := NewVal;
  invalidate;
end;

procedure TOptoGraph.fWriteTickY( NewVal : Integer );
begin
  iTickY := NewVal;
  invalidate;
end;

function TOptoGraph.DefaultGraphFunction(Sender: TObject; const AtX,
      ArraySize: Integer; const Params: array of TGrabHandleData;
      var Error: Boolean): Integer;
var
  i: integer;
  x1, y1, x2, y2 : real;
  r : real;
begin
  { remember open arrays start at zero }
  { step function }
  x1 := Params[0].X;
  y1 := Params[0].ParameterX;
  x2 := Params[1].X;
  y2 := Params[1].ParameterX;

  for i := 1 to ArraySize - 1 do
  begin
    if AtX > x2 then
    begin
      if ( i < ArraySize - 1) then
      begin
        { not in this band, move to next }
        x1 := x2;
        y1 := y2;
        x2 := Params[ i + 1 ]. X;
        y2 := Params[ i + 1 ]. ParameterX;
      end;
    end
    else
    begin
      r := Atx;
      r := (r - x1)*Pi/(x2 - x1);
      r := ((y1 + y2) + Cos( r )* (y1 - y2)) / 2;
      Result := Trunc( r );
      Error := (Result < -25) or (Result > 25);
      if Result > 40 then Result := 40;
      Exit;
    end;
  end;
  Result := 0;
end;

procedure TOptoGraph.Optimize;
begin
  iOptimize := True;
  invalidate;
end;

procedure TOptoGraph.fOptimize;
var
  i : integer;
  CurrentFit, NewFit : integer;
  TotalBestFit, TotalNewFit : Word;
  ImprovementFound : boolean;
label
  TryAgainUp1, TryAgainDown1, Refine;
begin
  { systematically optimise the parameters to give best fit }
  { first pass - optimise each parameter in turn to try to give
    best fit regardless of others. Method only works with
    increasing and decreasing functions. }
  TotalNewFit := 64000; { not too difficult to beat! }
Refine:
  TotalBestFit := TotalNewFit;
  TotalNewFit := 0;
  for i :=1 to iXPoints do
  begin
    ImprovementFound := FALSE;
    with iPoints[i] do
    begin
      NewFit := abs(GrabHandleY - doGraphFunction( X ));
TryAgainUp1:
      CurrentFit := NewFit;
      Inc( ParameterX );
      NewFit := abs(GrabHandleY - doGraphFunction( X ));
      if NewFit < CurrentFit then
      begin
        ImprovementFound := TRUE;
        goto TryAgainUp1;
      end;
      { going up no longer gives improvement - if no
        improvement was found, try going down. }
      Dec( ParameterX ); { to get back to best fit so far }
      if not ImprovementFound then
      begin
TryAgainDown1:
        Dec( ParameterX );
        NewFit := abs(GrabHandleY - doGraphFunction( X ));
        if NewFit < CurrentFit then
        begin
          ImprovementFound := TRUE;
          CurrentFit := NewFit;
          goto TryAgainDown1;
        end;
        Inc( ParameterX ); { to get back to best so far }
      end;
    end;
    Inc( TotalNewFit, CurrentFit );
  end;
  if TotalNewFit < TotalBestFit then goto Refine;
end;

function TOptoGraph.doGraphFunction( iTemp : integer ) : integer;
begin
  if Assigned( iGraphFunction ) then
  begin
    Result := iGraphFunction( self, iTemp,
                    iXPoints, iPoints, ErrorCheck );
  end
  else
  begin
    Result := DefaultGraphFunction( self, iTemp,
                    iXPoints, iPoints, ErrorCheck );
  end;
end;

procedure Register;
begin
  RegisterComponents('SigNET', [TOptoGraph]);
end;

end.
