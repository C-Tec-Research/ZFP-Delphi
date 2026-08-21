unit SigNavigator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type

  tNavigatorButton = (nbNone, nbOK, nbUp, nbDown, nbLeft, nbRight);

  TFrameSigNavigator = class(TFrame)
    ImageSigNavigator: TImage;
    procedure ImageSigNavigatorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
  private
    fNavigatorButton: tNavigatorButton;
    fOuterRadius2, fOKRadius2 : integer;  // radius squared
    function GetCentreX: integer;
    function GetCentreY: integer;
    function GetOuterRadius: integer;
    function GetOKRadius: integer;
    { Private declarations }
  public
    { Public declarations }
    property CentreX : integer
             read GetCentreX;
    property CentreY : integer
             read GetCentreY;
    property OuterRadius : integer
             read GetOuterRadius;
    property OKRadius : integer
             read GetOKRadius;
    property Button : tNavigatorButton
             read fNavigatorButton;
  end;

implementation

{$R *.dfm}

{ TFrameSigNavigator }

procedure TFrameSigNavigator.FrameResize(Sender: TObject);
var
  iTestRadius : integer;
begin
  iTestRadius := OKRadius;
  fOKRadius2 := iTestRadius * iTestRadius;
  iTestRadius := OuterRadius;
  fOuterRadius2 := iTestRadius * iTestRadius;
end;

function TFrameSigNavigator.GetCentreX: integer;
begin
  Result := (Width div 2);
end;

function TFrameSigNavigator.GetCentreY: integer;
begin
  Result := (Height div 2 );
end;

function TFrameSigNavigator.GetOKRadius: integer;
begin
  Result := Height div 5; // = 0.4 * Outer radius!
end;

function TFrameSigNavigator.GetOuterRadius: integer;
begin
  Result := Height div 2;
end;

procedure TFrameSigNavigator.ImageSigNavigatorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iRadius2 : integer; // radius squared
  iX, iY : integer; // relative to centre
  {
        \  y <= x  /  Remember Y axis inverted!
         \ y <= -x/
   y > x  \______/  y <= x
   y <= -x/      \  y > -x
         / y > x  \
        / y > - x  \
  }
begin
  iX := X - CentreX;
  iY := Y - CentreY;
  iRadius2 := (iX * iX) + (iY * iY);
  if iRadius2 <= fOKRadius2 then
  begin
    fNavigatorButton := nbOK;
  end
  else if iRadius2 > fOuterRadius2 then
  begin
    fNavigatorButton := nbNone;
  end
  else if iY > iX then  // start of quadrant test
  begin
    if iY > (-iX) then
    begin
      fNavigatorButton := nbDown;
    end
    else  // iY <= -iX
    begin
      fNavigatorButton := nbLeft;
    end;
  end
  else // iX <= iY
  begin
    if iY > (-iX) then
    begin
      fNavigatorButton := nbRight;
    end
    else  // iY <= -iX
    begin
      fNavigatorButton := nbUp;
    end;
  end;

end;

end.
