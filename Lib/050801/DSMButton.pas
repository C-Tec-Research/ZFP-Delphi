unit DSMButton;

{
  Interface for button contruction.

  This both creates internal buttons and controls button defined in
  SigButton32.DLL, which may vary from application to application.

  It supplies functions to the main program that mirror to some
  extent those supplied in the DLL, but adding its own internal
  definitions.
}

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  ExtCtrls,
  Forms,
  Contnrs,
  Dialogs,
  Messages,
  Math,
  UnitTextButtonProps,
  UnitBasicButtonProps,
  UnitFormTimerButtonProperties;

const
  cMaxProperties = 64;
  WM_SIGBUTTONTOP    = WM_APP + 403;
  WM_SIGBUTTONLEFT   = WM_APP + 404;
  WM_SIGBUTTONWIDTH  = WM_APP + 405;
  WM_SIGBUTTONHEIGHT = WM_APP + 406;
  WM_SIGBUTTONREFRESH= WM_APP + 407;

type
  TDSMProperty = record
  PropertyID : string;
  PropertyValue : string;
  PropertyAsInt : integer; // for integer properties; must be stored as string Value as well
  PropertyAsBool : boolean; // for boolean properties; must be stored as string as well
end;

type
  TButtonDims = Record
  Top : integer;
  Left : integer;
  Width : integer;
  Height : integer;
end;

type
  TDSMButton = class
  private
    { Private declarations }
  protected
    { Protected declarations }
//    iOwnerWnd : HWND; // TSigButton;
    iMainWindow : HWND;
    iPropertyCount : integer;
    iProperty : array[ 1..cMaxProperties ] of TDSMProperty;
    iColour : tColor;
    iStripeColour : tColor;
    iHasStripe : boolean;
    iBevelWidth : integer;
    iFlat     : boolean;
    iTextColour : tColor;
    iIsDirty : boolean;
    iEditing : boolean;
    Canvas   : TCanvas;
    iOwnerIndex : integer;
    iOwnerDims : TButtonDims;
    iAlwaysShow : boolean;
    function Flat   : boolean;
    procedure DrawButtonFlat( FromX, FromY, ToX, ToY : integer; vColour : TColor );
    procedure DrawStripe( FromX, FromY, ToX, ToY : integer; vColour : TColor; vBevelWidth, vStripeWidth : integer);
    procedure DrawBevels( FromX, FromY, ToX, ToY : integer; vBevelWidth : integer; vColour : TColor; LightPC, ShadePC : Integer ); // LightPC = -1 means white
                                                              // ShadePC = -1 means Silver
    procedure DrawButtonStripe; virtual; // varies from button to button
    procedure PaintRaisedButton; virtual;
    procedure fDoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure fDoMouseMoveNormal ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure fDoMouseUpNormal ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    function fGetPropertyName( iIndex : integer ) : shortstring;
    function fGetPropertyValue( iIndex : integer ) : shortstring;
    procedure fOnPaint; virtual;
    function fGetTop : integer; virtual;
    procedure fSetTop( NewVal : integer ); virtual;
    function fGetLeft : integer; virtual;
    procedure fSetLeft( NewVal : integer ); virtual;
    function fGetWidth : integer; virtual;
    procedure fSetWidth( NewVal : integer ); virtual;
    function fGetHeight : integer; virtual;
    procedure fSetHeight( NewVal : integer ); virtual;
    procedure fSetEditing( NewVal : boolean ); virtual;
    procedure fSetStripe( NewColour : TColor );
  public
    { Public declarations }
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); virtual;
    destructor Destroy; override;
    procedure SetProperties; virtual;
    class function IsStyle( const ButtonType : string ) : boolean; virtual;
    class function Style : shortstring; virtual;
    procedure DoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseMoveNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUpNormal  ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean; virtual;
    function SetPropertyAsInt( const PropertyID : shortstring;
                          const PropertyValue : integer ) : boolean;
    function SetPropertyAsBool( const PropertyID : shortstring;
                          const PropertyValue : boolean ) : boolean;
    // Changes a property, but does not create it if it does not exist
    function ChangeProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean; virtual;
    // Changes a property, creating it if necessary
    function GetProperty( const PropertyID : shortstring ) : shortstring;
    function GetPropertyAsInt( const PropertyID : shortstring ) : integer;
    function GetPropertyAsBool( const PropertyID : shortstring ) : boolean;
    property PropertyCount : integer
             read iPropertyCount;
    property PropertyName[ iIndex : integer ] : shortstring
             read fGetPropertyName;
    property PropertyValue[ iIndex : integer ] : shortstring
             read fGetPropertyValue;
    property Editing : boolean
             read iEditing
             write fSetEditing;
    property Top : integer
             read fGetTop
             write fSetTop;
    property Left : integer
             read fGetLeft
             write fSetLeft;
    property Width : integer
             read fGetWidth
             write fSetWidth;
    property Height : integer
             read fGetHeight
             write fSetHeight;
    property IsDirty : boolean
             read iIsDirty
             write iIsDirty;
//    property IsEditing : boolean
//             read iEditing
//             write iEditing;
{
    property Owner : TPaintbox
             read iOwner;
}
//    procedure OnPaint( Canvas : TCanvas; pOwnerDims : TButtonDims );
//    procedure OnPaint( MyBoss : TPaintBox; pOwnerDims : TButtonDims );
    procedure OnPaint( pOwnerDims : TButtonDims );
    procedure SetButtonDims( pOwnerDims : TButtonDims );
    procedure Invalidate;
    property Stripe : tColor
             read iStripeColour
             write fSetStripe;
    property Colour : tColor
             read iColour
             write iColour;
    class function DimColour( iColour : TColor; PerCent : integer ) : TColor;
             // % values > 100  lighten a colour, < 100 dims a colour
  end;

  TDSMTitledButton = class( TDSMButton )
  protected
//    iFont : TFont;
//    iPixelsPerInch : integer;
    { Protected declarations }
{
    procedure fPaintTitled(Sender: TObject);
    procedure EndEdit; override;
    procedure fSetTitle( NewTitle : string );
}
    iTextArea : tButtonDims;
    iLines : tStringList; // Line texts, set by text property
    function fGetLineCount : integer;
    procedure fOnPaint; override;
  public
    { Public declarations }
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); override;
    destructor Destroy; override;
    function SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean; override;
    procedure SetProperties; override;
    property LineCount : integer
             read fGetLineCount;
{
    property Title : string
      read iTitle
      write fSetTitle;
}
  end;

type TDSMButtonList = class( TList )
  protected
    function FGetItem( index : integer ) : TDSMButton;
  public
    property Items[ index : integer ] : TDSMButton
             read FGetItem; default;
end;

type
  TImageButton = class( TDSMTitledButton )
  {
    Note - this class is descended from only. Descendants must
    add properties to associate images with states
  }
  protected
    iCurrImage : TPicture;
    procedure fOnPaint; override;
    function fGetX : integer; virtual; abstract;
    function fGetY : integer; virtual; abstract;
    procedure fSetX( NewVal : integer ); virtual; abstract;
    procedure fSetY( NewVal : integer ); virtual; abstract;
  public
    property AtX : integer
             read fGetX
             write fSetX;
    property AtY : integer
             read fGetY
             write fSetY;
  end;

//  TTimerActionButton = class( TDSMButton )
  TTimerActionButton = class( TDSMTitledButton )
  protected
    iTimer : TTimer;
    function fGetInterval : integer;
    procedure fSetInterval( NewVal : integer );
  public
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); override;
    destructor Destroy; override;
    property Interval : integer
             read fGetInterval
             write fSetInterval;
    procedure SetProperties; override;
    function SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean; override;
  end;

  TDSMImageList = class( TStringList )
  {
    this holds file names in the strings and Pictures in the objects
  }
  protected
    iOwnsImages : boolean;
    iOwner : tDSMButton;
    iAtX : integer;
    iAtY : integer;
    iCurrImageIndex : integer;
    function fGetGraphic : TGraphic;
  public
    procedure IncIndex;
    procedure fChangeImage( Sender : TObject ); // assigned to parent objects ONTICK event
    constructor Create( pOwner : tDSMButton; pOwnsImages : boolean );
    destructor Destroy; override; // need to destroy the images we created
    property AtX : integer
             read iAtX
             write iAtX;
    property AtY : integer
             read iAtY
             write iAtY;
    property Graphic : TGraphic
             read fGetGraphic;
  end;

  TMovingImageButton = class( TTimerActionButton )
  {
    Note - this class is descended from only. Descendants must
    add properties to associate images with states
  }
  private
    iCurrImageList : TDSMImageList;
    procedure fSetCurrImageList( NewVal : TDSMImageList );
  protected
    procedure fOnPaint; override;
    property CurrImageList : TDSMImageList
             read iCurrImageList
             write fSetCurrImageList;
  public
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); override;
  end;

  TDSMImageListList = class( TObjectList )
  {
    This holds a list of simultaneously active images
  }
  protected
    iOwner : tDSMButton;
    function fGetGraphic( index : integer) : TGraphic;
    function fGetItem( index : integer ) : TDSMImageList;
    procedure fSetItem( index : integer; NewVal : TDSMImageList );
  public
    constructor Create( pOwner : tDSMButton );
    procedure fChangeImage( Sender : TObject ); // assigned to parent objects ONTICK event
    property Graphic[ index : integer ] : TGraphic
             read fGetGraphic;
    property Item[ index : integer ] : TDSMImageList
             read fGetItem
             write fSetItem; default;
  end;

  TMovingImagesButton = class( TTimerActionButton )
  {
    Note - this class is descended from only. Descendants must
    add properties to associate images with states
  }
  protected
    iCurrImageList : TDSMImageListList;
    function fGetCurrImageList( index : integer ) : TDSMImageList;
    procedure fSetCurrImageList( index : integer; NewVal : TDSMImageList );
  protected
    procedure fOnPaint; override;
    property CurrImageList[ index : integer ] : TDSMImageList
             read fGetCurrImageList
             write fSetCurrImageList;
  public
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); override;
    destructor Destroy; override;
  end;

var
  ActiveButton : TDSMButton{TPaintbox}{ TSigButton };

implementation

//-------------------- TDSMButton -----------------

class function TDSMButton.DimColour( iColour : TColor; PerCent : integer ) : TColor;
var
  iPalette : integer;
  iRed, iGreen, iBlue : integer;
  Intensity : integer;
begin
             // % values > 100  lighten a colour, < 100 dims a colour
  iPalette := iColour div $1000000;
  iColour := iColour mod $1000000;
  iBlue := iColour div $10000;
  iColour := iColour mod $10000;
  iGreen := iColour div $100;
  iRed := iColour mod $100;

  Intensity := ( Max( Max( iBlue, iRed), iGreen ) * ( PerCent - 100 ) ) div 100;

{
  iBlue := (iBlue * ByPerCent) div 100;
  iGreen := (iGreen * ByPerCent) div 100;
  iRed := (iRed * ByPerCent) div 100;
}
  Inc( iBlue, Intensity );
  Inc( iGreen, Intensity );
  Inc( iRed, Intensity );

  if iBlue > $FF then iBlue := $FF; // limit to range!
  if iGreen > $FF then iGreen := $FF; // limit to range!
  if iRed > $FF then iRed := $FF; // limit to range!

  if iBlue < $00 then iBlue := $00; // limit to range!
  if iGreen < $00 then iGreen := $00; // limit to range!
  if iRed < $00 then iRed := $00; // limit to range!

  Result := iPalette * $1000000 + iBlue * $10000 + iGreen * $100 + iRed;

end;

constructor TDSMButton.Create( pMainWindow: HWND;
                               pOwnerIndex : integer );
begin
  inherited Create;
  iOwnerIndex := pOwnerIndex;
  iMainWindow := pMainWindow;
  iPropertyCount := 0;
  iColour := clSilver;
  iBevelWidth := 3;
  iFlat := FALSE;
  iTextColour := clBlack;
  Canvas := TCanvas.Create;
  Stripe := clBackground; // no stripe
  iAlwaysShow := FALSE;
end;

destructor TDSMButton.Destroy;
begin
  Canvas.Free;
  inherited Destroy;
end;

procedure TDSMButton.fSetEditing( NewVal : boolean );
begin
  iEditing := NewVal;
end;

procedure TDSMButton.fSetStripe( NewColour : TColor );
begin
  iStripeColour := NewColour;
  iHasStripe := (NewColour <> clBackground );
end;

{
procedure TDSMButton.EndEdit;
begin
  if iIsDirty then
  begin
    // save properties
    with FormMain.SigAreas do
    begin
      WriteString( iSectionName, 'Type', iButtonStyle );

      WriteInteger( iSectionName, 'X', Left );
      WriteInteger( iSectionName, 'Y', Top );
      WriteInteger( iSectionName, 'W', Width );
      WriteInteger( iSectionName, 'H', Height );
    end;
    iIsDirty := FALSE;
  end;
end;
}

procedure TDSMButton.SetProperties;
begin
  // just basic size properties
{
    SpinEditTop.Value := Y;
    SpinEditLeft.Value := X;
    SpinEditHeight.Value := H;
    SpinEditWidth.Value := W;
}
  if not assigned( FormBasicButtonProps ) then
  begin
    FormBasicButtonProps := TFormBasicButtonProps.Create( Application );
  end;
  FormBasicButtonProps.Caption := Style + ' Button Properties';
  if FormBasicButtonProps.ShowModal = mrOK then
  begin
    Top := FormBasicButtonProps.SpinEditTop.Value;
    Left := FormBasicButtonProps.SpinEditLeft.Value;
    Height := FormBasicButtonProps.SpinEditHeight.Value;
    Width := FormBasicButtonProps.SpinEditWidth.Value;
    iIsDirty := TRUE;
  end;
end;

procedure TDSMButton.fOnPaint;
begin
  if Editing or iAlwaysShow then
  begin
    PaintRaisedButton;
  end;
end;

procedure TDSMButton.DrawButtonFlat( FromX, FromY, ToX, ToY : integer; vColour : TColor );
begin
  with Canvas do
  begin
    Brush.Color := vColour;
    Pen.Color := clBlack;
    Rectangle( FromX, FromY, ToX, ToY );
  end;
end;

procedure TDSMButton.DrawStripe( FromX, FromY, ToX, ToY : integer; vColour : TColor; vBevelWidth, vStripeWidth : integer);
var
  i : integer;
begin
  // move inside border
  inc( FromX);
  inc( FromY );
  dec( ToX );
  dec( ToY );
  with Canvas do
  begin
    // a stripe from bottom left to top right.
    Pen.Color := vColour;
    // draw centre line
    MoveTo( FromX + vBevelWidth, FromY + vBevelWidth );
    LineTo( ToX - vBevelWidth, ToY - vBevelWidth );
    for i := 1 to vStripeWidth div 2 do
    begin
      MoveTo( FromX + vBevelWidth, FromY + vBevelWidth + i );
      LineTo( ToX - vBevelWidth - i, ToY - vBevelWidth );
      MoveTo( FromX + vBevelWidth + i, FromY + vBevelWidth );
      LineTo( ToX - vBevelWidth, ToY - vBevelWidth - i );
    end;
  end;
end;

procedure TDSMButton.DrawBevels( FromX, FromY, ToX, ToY : integer; vBevelWidth : integer; vColour : TColor; LightPC, ShadePC : Integer ); // LightPC = -1 means white
                                                              // ShadePC = -1 means Silver
var
  LightEdge : TColor;
  DarkEdge : TColor;
  i : integer;
begin
  if LightPC = -1 then
  begin
    LightEdge := clWhite;
  end
  else
  begin
    LightEdge := DimColour( vColour, LightPC );
  end;
  if ShadePC = -1 then
  begin
    DarkEdge := clGray;
  end
  else
  begin
    DarkEdge := DimColour( vColour, ShadePC );
  end;
  with Canvas do
  begin
    Pen.Width := 1;
    for i := 1 to iBevelWidth do
    begin
      Pen.Color := LightEdge;
      MoveTo( FromX + i, ToY - i - 1 );
      LineTo( FromX + i, FromY + i );
      LineTo( ToX - i - 1, FromY + i );
      Pen.Color := DarkEdge;
      LineTo( ToX - i - 1, ToY - i - 1 );
      LineTo( FromX + i, ToY - i - 1 );
    end;
  end;
end;

procedure TDSMButton.DrawButtonStripe;
begin
  // varies from button to button
  if Flat then
  begin
    DrawStripe( 0, 0, iOwnerDims.Width, iOwnerDims.Height, iStripeColour, 0, 5 );
  end
  else
  begin
    DrawStripe( 0, 0, iOwnerDims.Width, iOwnerDims.Height, iStripeColour, iBevelWidth, 5 );
  end;
end;

{
procedure TDSMButton.PaintRaisedButton;
var
  i : integer;
begin
  with Canvas do
  begin
    Brush.Color := iColour;
    Pen.Color := clBlack;
    Rectangle( 0, 0, iOwnerDims.Width, iOwnerDims.Height );
    // stripe, if required
    if iHasStripe then
    begin
      Pen.Width := 5;
      Pen.Color := iStripeColour;
      MoveTo( 0, 0 );
      LineTo( iOwnerDims.Width, iOwnerDims.Height );
      Pen.Width := 1;
    end;
    // and bevels
    if not Flat then
    begin
      for i := 1 to iBevelWidth do
      begin
        Pen.Color := clWhite;
        MoveTo( i, iOwnerDims.Height - i - 1 );
        LineTo( i, i );
        LineTo( iOwnerDims.Width - i - 1, i );
        Pen.Color := clGray;
        LineTo( iOwnerDims.Width - i - 1, iOwnerDims.Height - i - 1 );
        LineTo( i, iOwnerDims.Height - i - 1 );
      end;
    end;
  end;
end;
}

procedure TDSMButton.PaintRaisedButton;
begin
  DrawButtonFlat( 0, 0, iOwnerDims.Width, iOwnerDims.Height, iColour );
  // stripe, if required
  if iHasStripe then
  begin
    DrawButtonStripe;
  end;
  // and bevels
  if not Flat then
  begin
    DrawBevels( 0, 0, iOwnerDims.Width, iOwnerDims.Height, iBevelWidth, iColour, 180, 50 );
  end;
end;

function TDSMButton.Flat : boolean;
begin
  // in normal mode this is simply iFlat
  // In edit mode it is whether the button is active
  if Editing then
  begin
//    Result := (ActiveButton = iOwner);
    Result := (ActiveButton = self);
  end
  else
  begin
    Result := iFlat;
  end;
end;

procedure TDSMButton.Invalidate;
var
  ARect : TRect;
begin
  ARect := Rect( iOwnerDims.Left,
                  iOwnerDims.Top, iOwnerDims.Left + iOwnerDims.Width,
                  iOwnerDims.Top + iOwnerDims.Height);
  InvalidateRect( iMainWindow, @ARect, FALSE );
end;

{
procedure TDSMButton.fOnMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
var
  OldButton : TDSMButton;
begin
  iButton := Button; // needed for mouse move
  if FormMain.Editing then
  begin
    OldButton := FormMain.ActiveButton;
    FormMain.ActiveButton := Self;
    FormMain.EditPropertiesButton.Enabled := TRUE;
    if assigned( OldButton ) then
    begin
      OldButton.Invalidate;
    end;
    DoMouseDownEditing( Shift, X, Y );
    Invalidate;
  end
  else
  begin
    DoMouseDownNormal( Shift, X, Y );
  end;
end;

procedure TDSMButton.fOnMouseMove(Sender: TObject;
              Shift: TShiftState; X, Y: Integer);
begin
  if iButton <> mbMiddle then // unused value, also used for not pressed
  begin
    if not iUpdating then
    begin
      iUpdating := TRUE; // stop re-entrancy problems
      if FormMain.Editing then
        DoMouseMoveEditing( Shift, X, Y )
      else
        DoMouseMoveNormal( Shift, X, Y );
      iUpdating := FALSE;
    end;
  end;
end;

procedure TDSMButton.fOnMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
begin
  if FormMain.Editing then
  begin
    DoMouseUpEditing( Shift, X, Y );
  end
  else
  begin
    DoMouseUpNormal( Shift, X, Y );
  end;
  iButton := mbMiddle; // safe, unused value
end;

}

class function TDSMButton.IsStyle( const ButtonType : string ) : boolean;
begin
  // non-specific button
//  Result := AnsiCompareText( ButtonType, 'General' ) = 0;
  Result := AnsiCompareText( ButtonType, Style ) = 0;
end;

class function TDSMButton.Style : shortstring;
begin
  // non-specific button
  Result := 'General';
end;

procedure TDSMButton.fDoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  iFlat := TRUE;
end;

procedure TDSMButton.DoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDoMouseDownNormal( pButton, Shift, X, Y );
  // dispatch to inherited function
end;

procedure TDSMButton.fDoMouseMoveNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TDSMButton.DoMouseMoveNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDoMouseMoveNormal( pButton, Shift, X, Y );
  // dispatch to inherited function
end;

procedure TDSMButton.fDoMouseUpNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  iFlat := FALSE;
end;

procedure TDSMButton.DoMouseUpNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDoMouseUpNormal( pButton, Shift, X, Y );
  // dispatch to inherited function
end;

procedure TDSMButton.OnPaint( pOwnerDims : TButtonDims );
begin
  iOwnerDims := pOwnerDims;
  Canvas.Handle := GetDC( iMainWindow );
  SetViewPortOrgEx( Canvas.Handle, iOwnerDims.Left, iOwnerDims.Top, nil );
  IntersectClipRect( Canvas.Handle, 0, 0, iOwnerDims.Width, iOwnerDims.Height );
  fOnPaint;
  // dispatch to inherited function
  ReleaseDC( iMainWindow, Canvas.Handle );
end;

procedure TDSMButton.SetButtonDims( pOwnerDims : TButtonDims );
begin
  iOwnerDims := pOwnerDims;
end;

function TDSMButton.SetProperty( const PropertyID : shortstring;
                      const PropertyValue : shortstring ) : boolean;
var
  i : integer;
begin
  // only allow updates - no creation
  Result := FALSE;
  for i := 1 to iPropertyCount do
  begin
    if AnsiCompareText( iProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      if iProperty[ i ].PropertyValue <> PropertyValue then  // amend even if change of case
      begin
        iProperty[ i ].PropertyValue := PropertyValue;
        iProperty[ i ].PropertyAsInt := StrToIntDef( PropertyValue, 0 );
        if AnsiCompareText( TRIM( PropertyValue ), 'TRUE' ) = 0 then
          iProperty[ i ].PropertyAsBool := TRUE
        else if Trim( PropertyValue ) = '1' then
          iProperty[ i ].PropertyAsBool := TRUE
        else
          iProperty[ i ].PropertyAsBool := FALSE;
        Result := TRUE;
        if ActiveButton = self then
        begin
          SendMessage( iMainWindow, WM_SIGBUTTONREFRESH, iOwnerIndex, 0);
//        InvalidateRect( iOwnerWND, nil, FALSE );
        end;
        Exit;
      end;
    end;
  end;
end;

function TDSMButton.SetPropertyAsInt( const PropertyID : shortstring;
                      const PropertyValue : integer ) : boolean;
begin
  // only allow updates - no creation
  Result := SetProperty( PropertyID, IntToStr( PropertyValue ));
end;

function TDSMButton.SetPropertyAsBool( const PropertyID : shortstring;
                      const PropertyValue : boolean ) : boolean;
begin
  // only allow updates - no creation
  if PropertyValue then
    Result := SetProperty( PropertyID, 'TRUE' )
  else
    Result := SetProperty( PropertyID, 'FALSE' );
end;

function TDSMButton.ChangeProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
begin
  if not SetProperty( PropertyID, PropertyValue ) then
  begin
    if iPropertyCount < cMaxProperties then
    begin
      inc( iPropertyCount );
      iProperty[ iPropertyCount ].PropertyID := PropertyID;
      iProperty[ iPropertyCount ].PropertyValue := PropertyValue;
      iProperty[ iPropertyCount ].PropertyAsInt := StrToIntDef( PropertyValue, 0 );
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := TRUE;
  end;
end;

function TDSMButton.GetProperty( const PropertyID : shortstring ) : shortstring;
var
  i : integer;
begin
  Result := '';
  for i := 1 to iPropertyCount do
  begin
    if AnsiCompareText( iProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := iProperty[ i ].PropertyValue;
      Exit;
    end;
  end;
end;

function TDSMButton.GetPropertyAsInt( const PropertyID : shortstring ) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 1 to iPropertyCount do
  begin
    if AnsiCompareText( iProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := iProperty[ i ].PropertyAsInt;
      Exit;
    end;
  end;
end;

function TDSMButton.GetPropertyAsBool( const PropertyID : shortstring ) : boolean;
var
  i : integer;
begin
  Result := FALSE;
  for i := 1 to iPropertyCount do
  begin
    if AnsiCompareText( iProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := iProperty[ i ].PropertyAsBool;
      Exit;
    end;
  end;
end;

function TDSMButton.fGetPropertyName( iIndex : integer ) : shortstring;
begin
  if (iIndex > 0) and (iIndex <= iPropertyCount) then
    Result := iProperty[ iIndex ].PropertyID
  else
    Result := 'Property[ ' + IntToStr( iIndex ) + ' ]';
end;

function TDSMButton.fGetPropertyValue( iIndex : integer ) : shortstring;
begin
  if (iIndex > 0) and (iIndex <= iPropertyCount) then
    Result := iProperty[ iIndex ].PropertyValue
  else
    Result := '';
end;

function TDSMButton.fGetTop : integer;
//var
//  ClientRect : TRect;
begin
//  GetWindowRect( iOwnerWND, ClientRect );
//  Result := ClientRect.Top;
  Result := iOwnerDims.Top;
end;

procedure TDSMButton.fSetTop( NewVal : integer );
begin
//  SendMessage( iOwnerWND, WM_SIGBUTTONTOP, NewVal, 0 );
//  iOwner.Top := NewVal;
  SendMessage( iMainWindow, WM_SIGBUTTONTOP, iOwnerIndex, NewVal);
  iOwnerDims.Top := NewVal;
end;

function TDSMButton.fGetLeft : integer;
//var
//  ClientRect : TRect;
begin
//  GetWindowRect( iOwnerWND, ClientRect );
//  Result := ClientRect.Left;
  Result := iOwnerDims.Left;
end;

procedure TDSMButton.fSetLeft( NewVal : integer );
begin
//  SendMessage( iOwnerWND, WM_SIGBUTTONLEFT, NewVal, 0 );
//  iOwner.Left := NewVal;
  SendMessage( iMainWindow, WM_SIGBUTTONLEFT, iOwnerIndex, NewVal);
  iOwnerDims.Left := NewVal;
end;

function TDSMButton.fGetWidth : integer;
//var
//  ClientRect : TRect;
begin
//  GetWindowRect( iOwnerWND, ClientRect );
//  Result := ClientRect.Right - ClientRect.Left;
  Result := iOwnerDims.Width;
end;

procedure TDSMButton.fSetWidth( NewVal : integer );
begin
//  SendMessage( iOwnerWND, WM_SIGBUTTONWIDTH, NewVal, 0 );
//  iOwner.Width := NewVal;
  SendMessage( iMainWindow, WM_SIGBUTTONWIDTH, iOwnerIndex, NewVal);
  iOwnerDims.Width := NewVal;
end;

function TDSMButton.fGetHeight : integer;
//var
//  ClientRect : TRect;
begin
//  GetWindowRect( iOwnerWND, ClientRect );
//  Result := ClientRect.Bottom - ClientRect.Top;
  Result := iOwnerDims.Height;
end;

procedure TDSMButton.fSetHeight( NewVal : integer );
begin
//  SendMessage( iOwnerWND, WM_SIGBUTTONHEIGHT, NewVal, 0 );
//  iOwner.Height := NewVal;
  SendMessage( iMainWindow, WM_SIGBUTTONHEIGHT, iOwnerIndex, NewVal);
  iOwnerDims.Height := NewVal;
end;

//--------- TDSMTitledButton -----------------------------

constructor TDSMTitledButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  inherited Create( pMainWindow, pOwnerIndex );
  iLines := tStringList.Create;
  ChangeProperty( 'Title', '' );
//  iFont := TFont.Create;
//  iFont.Assign( Canvas.Font );
//  iPixelsPerInch := Canvas.Font.PixelsPerInch;

end;

destructor TDSMTitledButton.Destroy;
begin
//  iFont.Free;
  iLines.Free;
  inherited Destroy;
end;

//procedure TDSMTitledButton.fOnPaint( Canvas : TCanvas );
//procedure TDSMTitledButton.fOnPaint( MyBoss : TPaintbox );
procedure TDSMTitledButton.fOnPaint;
var
  TextExtent : tSize;
  i : integer;
  iTop, iLeft : integer;
  iLineHt : integer;
begin
  // By default text area is same as button area, but descendants may
  // change tins in PaintRaisedButton or (more usually) Paint Stripe descendants
  iTextArea := iOwnerDims;
  // hide unless in edit mode or Caption
  if Editing or ( LineCount > 0 ) or iAlwaysShow then
  begin
    PaintRaisedButton;
  end;
  if LineCount > 0 then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := iTextColour;
    Canvas.Font.Style := [ fsBOLD ];
    TextExtent := Canvas.TextExtent( iLines[ 0 ] );
    iLineHt := (TextExtent.cy) * 5 div 4;
    iTop := (iOwnerDims.Height - LineCount * iLineHt) div 2;
    for i := 0 to LineCount - 1 do
    begin
      iLeft := (iTextArea.Width - Canvas.TextWidth( iLines[ i ] )) div 2;
      Canvas.TextOut( iLeft, iTop, iLines[ i ] );
      inc( iTop, iLineHt );
    end;
  end;
end;

function TDSMTitledButton.fGetLineCount : integer;
begin
  Result := iLines.Count;
end;

function TDSMTitledButton.SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
var
  iCR : integer;
  iText : string;
  iLine : string;
begin
  Result := inherited SetProperty( PropertyID, PropertyValue );
  if SameText( PropertyID, 'Title' ) then
  begin
    iText := PropertyValue;
    iLines.Clear;
    iCR := Pos( '~', iText );
    while iCR > 0 do
    begin
      iLine := Copy( iText, 1, iCR - 1 );
      iText := Copy( iText, iCR + 1, Length( iText ));
      iLines.Add( iLine );
      iCR := Pos( '~', iText );
    end;
    if iText <> '' then
    begin
      iLines.Add( iText );
    end;
  end;
end;

procedure TDSMTitledButton.SetProperties;
begin
  // Tile and size properties
{
    SpinEditTop.Value := Y;
    SpinEditLeft.Value := X;
    SpinEditHeight.Value := H;
    SpinEditWidth.Value := W;
}
  if FormTextButtonProps.ShowModal = mrOK then
  begin
    Top := FormTextButtonProps.SpinEditTop.Value;
    Left := FormTextButtonProps.SpinEditLeft.Value;
    Height := FormTextButtonProps.SpinEditHeight.Value;
    Width := FormTextButtonProps.SpinEditWidth.Value;
    iIsDirty := TRUE;
    SetProperty( 'Title', FormTextButtonProps.EditText.Text );
  end;
end;

{
procedure TDSMTitledButton.EndEdit;
begin
  if iIsDirty then
  begin
    inherited EndEdit;
    // save properties
    with FormMain.SigAreas do
    begin
      // add Title
      WriteString( iSectionName, 'Title', iTitle );
    end;
  end;
end;

procedure TDSMTitledButton.fSetTitle( NewTitle : string );
begin
  iTitle := NewTitle;
  Invalidate;
end;
}

function TDSMButtonList.FGetItem( index : integer ) : TDSMButton;
begin
  result := TDSMButton( inherited Items[ index ] );
end;

//--------------------- TDSMImageList --------------------

procedure TDSMImageList.IncIndex; // assigned to parent objects ONTICK event
begin
  if Count > 0 then
  begin
    inc( iCurrImageIndex );
    if iCurrImageIndex >= Count then
    begin
      iCurrImageIndex := 0;
    end;
  end;
end;

procedure TDSMImageList.fChangeImage( Sender : TObject ); // assigned to parent objects ONTICK event
begin
  if Count > 0 then
  begin
    IncIndex;
    iOwner.Invalidate;
  end;
end;

constructor TDSMImageList.Create( pOwner : tDSMButton; pOwnsImages : boolean );
begin
  inherited Create;
  iCurrImageIndex := 0;
  iOwner := pOwner;
  iOwnsImages := pOwnsImages;
end;

destructor TDSMImageList.Destroy;
var
  i : integer;
begin
  if iOwnsImages then
  begin
    for i := 0 to Count - 1 do
    begin
      Objects[ i ].Free;
    end;
  end;
//  For all current implementations, objects are not owned
  inherited destroy;
end;

function TDSMImageList.fGetGraphic : TGraphic;
begin
  Result := TGraphic( Objects[ iCurrImageIndex ] );
end;

//--------------------- TDSMImageListList ---------------

constructor TDSMImageListList.Create( pOwner : tDSMButton );
begin
  inherited Create;
  iOwner := pOwner;
  OwnsObjects := FALSE;
end;

function TDSMImageListList.fGetGraphic( index : integer) : TGraphic;
begin
  Result := Item[ index ].Graphic;
end;

procedure TDSMImageListList.fSetItem( index : integer; NewVal : TDSMImageList );
begin
  Items[ index ] := NewVal;
end;

function TDSMImageListList.fGetItem( index : integer ) : TDSMImageList;
begin
  Result := Items[ index ] as TDSMImageList;
end;

procedure TDSMImageListList.fChangeImage( Sender : TObject );
var
  i : integer;
begin
  if not iOwner.Editing then
  begin
    if Count > 0 then
    begin
      for i := 0 to Count - 1 do
      begin
        Item[ i ].IncIndex;
      end;
      iOwner.Invalidate;
    end;
  end;
end;

//---------------- TImageButton --------------------
{
  paints an image (usually one of a series depicting states) on the canvas
}
procedure TImageButton.fOnPaint;
begin
  inherited fOnPaint;
  if assigned( iCurrImage ) then
  begin
    Canvas.Draw( AtX, AtY, iCurrImage.Graphic );
  end;
end;

//----------------- TTimerActionButton -------------------

constructor TTimerActionButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  inherited Create( pMainWindow, pOwnerIndex );
  iTimer := TTimer.Create( nil );
  iTimer.Enabled := FALSE;
  ChangeProperty( 'Interval', '1000' );
end;

destructor TTimerActionButton.Destroy;
begin
  iTimer.Enabled := FALSE;
  iTimer.Free;
end;

procedure TTimerActionButton.SetProperties;
begin
  if FormTimerButtonProps.ShowModal = mrOK then
  begin
    Top := FormTimerButtonProps.SpinEditTop.Value;
    Left := FormTimerButtonProps.SpinEditLeft.Value;
    Height := FormTimerButtonProps.SpinEditHeight.Value;
    Width := FormTimerButtonProps.SpinEditWidth.Value;
    iIsDirty := TRUE;
    SetProperty( 'Title', FormTimerButtonProps.EditText.Text );
    SetProperty( 'Interval', FormTimerButtonProps.SpinEditInterval.Text );
  end;
end;

function TTimerActionButton.SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
begin
  if SameText( PropertyID, 'Interval' ) then
  begin
    Interval := StrToIntDef( PropertyValue, 1000 );
  end;
  Result := inherited SetProperty( PropertyID, PropertyValue );
end;

function TTimerActionButton.fGetInterval : integer;
begin
  Result := iTimer.Interval;
end;

procedure TTimerActionButton.fSetInterval( NewVal : integer );
begin
  iTimer.Interval := NewVal;
end;

//-------------- TMovingImageButton ----------------

constructor TMovingImageButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  inherited Create( pMainWindow, pOwnerIndex );
end;

procedure TMovingImageButton.fOnPaint;
begin
  inherited fOnPaint;
  if assigned( iCurrImageList ) then
  begin
    if assigned( iCurrImageList.Graphic ) then
    begin
      Canvas.Draw( iCurrImageList.AtX, iCurrImageList.AtY, iCurrImageList.Graphic );
    end;
  end;
end;

procedure TMovingImageButton.fSetCurrImageList( NewVal : TDSMImageList );
begin
  iTimer.Enabled := FALSE;
  iCurrImageList := NewVal;
  if assigned( NewVal ) then
  begin
    iTimer.OnTimer := NewVal.fChangeImage;
    iTimer.Enabled := TRUE;
  end
  else
  begin
    iTimer.OnTimer := nil;
    // leave disabled
  end;
  Invalidate;
end;

//------------ TMovingImagesButton ---------------

constructor TMovingImagesButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  {
    Note - this class is descended from only. Descendants must
    add properties to associate images with states
  }
  inherited Create( pMainWindow, pOwnerIndex );
  iCurrImageList := TDSMImageListList.Create( self );
  iTimer.OnTimer := iCurrImageList.fChangeImage;
end;

destructor TMovingImagesButton.Destroy;
begin
  iTimer.Enabled := FALSE;
  iCurrImageList.Free;
  inherited Destroy;
end;

function TMovingImagesButton.fGetCurrImageList( index : integer ) : TDSMImageList;
begin
  Result := iCurrImageList[ index ];
end;

procedure TMovingImagesButton.fSetCurrImageList( index : integer; NewVal : TDSMImageList );
begin
  iCurrImageList[ index ] := NewVal;
  Invalidate;
end;

procedure TMovingImagesButton.fOnPaint;
var
  i : integer;
begin
  inherited fOnPaint;
  if not Editing then
  begin
    for i := 0 to iCurrImageList.Count - 1 do
    begin
      with iCurrImageList[ i ] do
      begin
        Canvas.Draw( AtX, AtY, Graphic );
      end;
    end
  end;
end;

initialization
  ActiveButton := nil;

end.
