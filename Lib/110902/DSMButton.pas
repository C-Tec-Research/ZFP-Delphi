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
    procedure SetColour(const Value: tColor);
    { Private declarations }
  protected
    { Protected declarations }
//    iOwnerWnd : HWND; // TSigButton;
    fMainWindow : HWND;
    fPropertyCount : integer;
    fProperty : array[ 1..cMaxProperties ] of TDSMProperty;
    fColour : tColor;
    fStripeColour : tColor;
    fHasStripe : boolean;
    fBevelWidth : integer;
    fFlat     : boolean;
    fTextColour : tColor;
    fIsDirty : boolean;
    fEditing : boolean;
    fCanvas   : TControlCanvas;
    fOwnerIndex : integer;
    fOwnerDims : TButtonDims;
    fAlwaysShow : boolean;
    fPainting : boolean;
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
    function GetPropertyName( pIndex : integer ) : string;
    function GetPropertyValue( pIndex : integer ) : string;
    procedure fOnPaint; virtual;
    function GetTop : integer; virtual;
    procedure SetTop( NewVal : integer ); virtual;
    function GetLeft : integer; virtual;
    procedure SetLeft( NewVal : integer ); virtual;
    function GetWidth : integer; virtual;
    procedure SetWidth( NewVal : integer ); virtual;
    function GetHeight : integer; virtual;
    procedure SetHeight( NewVal : integer ); virtual;
    procedure SetEditing( NewVal : boolean ); virtual;
    procedure SetStripe( NewColour : TColor );
  public
    { Public declarations }
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); virtual;
    destructor Destroy; override;
    procedure SetProperties; virtual;
    class function IsStyle( const ButtonType : string ) : boolean; virtual;
    class function Style : string; virtual;
    procedure DoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseMoveNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUpNormal  ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean; virtual;
    function SetPropertyAsInt( const PropertyID : string;
                          const PropertyValue : integer ) : boolean;
    function SetPropertyAsBool( const PropertyID : string;
                          const PropertyValue : boolean ) : boolean;
    // Changes a property, but does not create it if it does not exist
    function ChangeProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean; virtual;
    // Changes a property, creating it if necessary
    function GetProperty( const PropertyID : string ) : string;
    function GetPropertyAsInt( const PropertyID : string ) : integer;
    function GetPropertyAsBool( const PropertyID : string ) : boolean;
    property PropertyCount : integer
             read fPropertyCount;
    property PropertyName[ pIndex : integer ] : string
             read GetPropertyName;
    property PropertyValue[ pIndex : integer ] : string
             read GetPropertyValue;
    property Editing : boolean
             read fEditing
             write SetEditing;
    property Top : integer
             read GetTop
             write SetTop;
    property Left : integer
             read GetLeft
             write SetLeft;
    property Width : integer
             read GetWidth
             write SetWidth;
    property Height : integer
             read GetHeight
             write SetHeight;
    property IsDirty : boolean
             read fIsDirty
             write fIsDirty;
//    property IsEditing : boolean
//             read fEditing
//             write fEditing;
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
             read fStripeColour
             write SetStripe;
    property Colour : tColor
             read fColour
             write SetColour;
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
    function SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean; override;
    procedure SetProperties; override;
    property LineCount : integer
             read fGetLineCount;
{
    property Title : string
      read iTitle
      write fSetTitle;
}
  end;

type TDSMButtonList = class( TObjectList )
  protected
    function FGetItem( index : integer ) : TDSMButton;
  public
    constructor Create;
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
    fTimer : TTimer;
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
    function SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean; override;
  end;

  TDSMImageList = class( TStringList )
  {
    this holds file names in the strings and Pictures in the objects
  }
  protected
    //iOwnsImages : boolean;
    iOwner : tDSMButton;
    iAtX : integer;
    iAtY : integer;
    iCurrImageIndex : integer;
    function fGetGraphic : TGraphic;
  public
    procedure IncIndex;
    procedure fChangeImage( Sender : TObject ); // assigned to parent objects ONTICK event
    constructor Create( pOwner : tDSMButton {; pOwnsImages : boolean} );
    destructor Destroy; override;
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
    fCurrImageList : TDSMImageList;
    procedure SetCurrImageList( NewVal : TDSMImageList );
  protected
    procedure fOnPaint; override;
    property CurrImageList : TDSMImageList
             read fCurrImageList
             write SetCurrImageList;
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
    fCurrImageList : TDSMImageListList;
    function fGetCurrImageList( index : integer ) : TDSMImageList;
    procedure SetCurrImageList( index : integer; NewVal : TDSMImageList );
  protected
    procedure fOnPaint; override;
    property CurrImageList[ index : integer ] : TDSMImageList
             read fGetCurrImageList
             write SetCurrImageList;
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
  fOwnerIndex := pOwnerIndex;
  fMainWindow := pMainWindow;
  fPropertyCount := 0;
  fColour := clSilver;
  fBevelWidth := 3;
  fFlat := FALSE;
  fTextColour := clBlack;
  fCanvas := TControlCanvas.Create;
  Stripe := clBackground; // no stripe
  fAlwaysShow := FALSE;
end;

destructor TDSMButton.Destroy;
begin
  inherited Destroy;
end;

procedure TDSMButton.SetEditing( NewVal : boolean );
begin
  fEditing := NewVal;
end;

procedure TDSMButton.SetStripe( NewColour : TColor );
begin
  if fStripeColour <> NewColour then
  begin
    fStripeColour := NewColour;
    fHasStripe := (NewColour <> clBackground );
    // Invalidate;
  end;
end;

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
    fIsDirty := TRUE;
  end;
end;

procedure TDSMButton.fOnPaint;
begin
  if Editing or fAlwaysShow then
  begin
    PaintRaisedButton;
  end;
end;

procedure TDSMButton.DrawButtonFlat( FromX, FromY, ToX, ToY : integer; vColour : TColor );
begin
  with fCanvas do
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
  with fCanvas do
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
  with fCanvas do
  begin
    Pen.Width := 1;
    for i := 1 to fBevelWidth do
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
    DrawStripe( 0, 0, fOwnerDims.Width, fOwnerDims.Height, fStripeColour, 0, 5 );
  end
  else
  begin
    DrawStripe( 0, 0, fOwnerDims.Width, fOwnerDims.Height, fStripeColour, fBevelWidth, 5 );
  end;
end;

{
procedure TDSMButton.PaintRaisedButton;
var
  i : integer;
begin
  with Canvas do
  begin
    Brush.Color := fColour;
    Pen.Color := clBlack;
    Rectangle( 0, 0, fOwnerDims.Width, fOwnerDims.Height );
    // stripe, if required
    if fHasStripe then
    begin
      Pen.Width := 5;
      Pen.Color := fStripeColour;
      MoveTo( 0, 0 );
      LineTo( fOwnerDims.Width, fOwnerDims.Height );
      Pen.Width := 1;
    end;
    // and bevels
    if not Flat then
    begin
      for i := 1 to fBevelWidth do
      begin
        Pen.Color := clWhite;
        MoveTo( i, fOwnerDims.Height - i - 1 );
        LineTo( i, i );
        LineTo( fOwnerDims.Width - i - 1, i );
        Pen.Color := clGray;
        LineTo( fOwnerDims.Width - i - 1, fOwnerDims.Height - i - 1 );
        LineTo( i, fOwnerDims.Height - i - 1 );
      end;
    end;
  end;
end;
}

procedure TDSMButton.PaintRaisedButton;
begin
  DrawButtonFlat( 0, 0, fOwnerDims.Width, fOwnerDims.Height, fColour );
  // stripe, if required
  if fHasStripe then
  begin
    DrawButtonStripe;
  end;
  // and bevels
  if not Flat then
  begin
    DrawBevels( 0, 0, fOwnerDims.Width, fOwnerDims.Height, fBevelWidth, fColour, 180, 50 );
  end;
end;

function TDSMButton.Flat : boolean;
begin
  // in normal mode this is simply fFlat
  // In edit mode it is whether the button is active
  if Editing then
  begin
//    Result := (ActiveButton = iOwner);
    Result := (ActiveButton = self);
  end
  else
  begin
    Result := fFlat;
  end;
end;

procedure TDSMButton.Invalidate;
var
  ARect : TRect;
begin
  ARect := Rect( fOwnerDims.Left,
                  fOwnerDims.Top, fOwnerDims.Left + fOwnerDims.Width,
                  fOwnerDims.Top + fOwnerDims.Height);
  InvalidateRect( fMainWindow, @ARect, FALSE );
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

class function TDSMButton.Style : string;
begin
  // non-specific button
  Result := 'General';
end;

procedure TDSMButton.fDoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fFlat := TRUE;
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
  fFlat := FALSE;
end;

procedure TDSMButton.DoMouseUpNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDoMouseUpNormal( pButton, Shift, X, Y );
  // dispatch to inherited function
end;

procedure TDSMButton.OnPaint( pOwnerDims : TButtonDims );
begin
  if not fPainting then
  begin
    fPainting := TRUE;
    fOwnerDims := pOwnerDims;
    fCanvas.Handle := GetDC( fMainWindow );
    SetViewPortOrgEx( fCanvas.Handle, fOwnerDims.Left, fOwnerDims.Top, nil );
    IntersectClipRect( fCanvas.Handle, 0, 0, fOwnerDims.Width, fOwnerDims.Height );
    fOnPaint;
    // dispatch to inherited function
    ReleaseDC( fMainWindow, fCanvas.Handle );
    fPainting := FALSE;
  end;
end;

procedure TDSMButton.SetButtonDims( pOwnerDims : TButtonDims );
begin
  fOwnerDims := pOwnerDims;
end;

procedure TDSMButton.SetColour(const Value: tColor);
begin
  if fColour <> Value then
  begin
    fColour := Value;
    Invalidate;
  end;
end;

function TDSMButton.SetProperty( const PropertyID : string;
                      const PropertyValue : string ) : boolean;
var
  i : integer;
begin
  // only allow updates - no creation
  Result := FALSE;
  for i := 1 to fPropertyCount do
  begin
    if AnsiCompareText( fProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      if fProperty[ i ].PropertyValue <> PropertyValue then  // amend even if change of case
      begin
        fProperty[ i ].PropertyValue := PropertyValue;
        fProperty[ i ].PropertyAsInt := StrToIntDef( PropertyValue, 0 );
        if AnsiCompareText( TRIM( PropertyValue ), 'TRUE' ) = 0 then
          fProperty[ i ].PropertyAsBool := TRUE
        else if Trim( PropertyValue ) = '1' then
          fProperty[ i ].PropertyAsBool := TRUE
        else
          fProperty[ i ].PropertyAsBool := FALSE;
        Result := TRUE;
        if ActiveButton = self then
        begin
          SendMessage( fMainWindow, WM_SIGBUTTONREFRESH, fOwnerIndex, 0);
//        InvalidateRect( iOwnerWND, nil, FALSE );
        end;
        Exit;
      end;
    end;
  end;
end;

function TDSMButton.SetPropertyAsInt( const PropertyID : string;
                      const PropertyValue : integer ) : boolean;
begin
  // only allow updates - no creation
  Result := SetProperty( PropertyID, IntToStr( PropertyValue ));
end;

function TDSMButton.SetPropertyAsBool( const PropertyID : string;
                      const PropertyValue : boolean ) : boolean;
begin
  // only allow updates - no creation
  if PropertyValue then
    Result := SetProperty( PropertyID, 'TRUE' )
  else
    Result := SetProperty( PropertyID, 'FALSE' );
end;

function TDSMButton.ChangeProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean;
begin
  if not SetProperty( PropertyID, PropertyValue ) then
  begin
    if fPropertyCount < cMaxProperties then
    begin
      inc( fPropertyCount );
      fProperty[ fPropertyCount ].PropertyID := PropertyID;
      fProperty[ fPropertyCount ].PropertyValue := PropertyValue;
      fProperty[ fPropertyCount ].PropertyAsInt := StrToIntDef( PropertyValue, 0 );
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

function TDSMButton.GetProperty( const PropertyID : string ) : string;
var
  i : integer;
begin
  Result := '';
  for i := 1 to fPropertyCount do
  begin
    if AnsiCompareText( fProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := fProperty[ i ].PropertyValue;
      Exit;
    end;
  end;
end;

function TDSMButton.GetPropertyAsInt( const PropertyID : string ) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 1 to fPropertyCount do
  begin
    if AnsiCompareText( fProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := fProperty[ i ].PropertyAsInt;
      Exit;
    end;
  end;
end;

function TDSMButton.GetPropertyAsBool( const PropertyID : string ) : boolean;
var
  i : integer;
begin
  Result := FALSE;
  for i := 1 to fPropertyCount do
  begin
    if AnsiCompareText( fProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      Result := fProperty[ i ].PropertyAsBool;
      Exit;
    end;
  end;                        
end;

function TDSMButton.GetPropertyName( pIndex : integer ) : string;
begin
  if (pIndex > 0) and (pIndex <= fPropertyCount) then
    Result := fProperty[ pIndex ].PropertyID
  else
    Result := 'Property[ ' + IntToStr( pIndex ) + ' ]';
end;

function TDSMButton.GetPropertyValue( pIndex : integer ) : string;
begin
  if (pIndex > 0) and (pIndex <= fPropertyCount) then
    Result := fProperty[ pIndex ].PropertyValue
  else
    Result := '';
end;

function TDSMButton.GetTop : integer;
//var
//  ClientRect : TRect;
begin
//  GetWindowRect( iOwnerWND, ClientRect );
//  Result := ClientRect.Top;
  Result := fOwnerDims.Top;
end;

procedure TDSMButton.SetTop( NewVal : integer );
begin
  SendMessage( fMainWindow, WM_SIGBUTTONTOP, fOwnerIndex, NewVal);
  fOwnerDims.Top := NewVal;
end;

function TDSMButton.GetLeft : integer;
begin
  Result := fOwnerDims.Left;
end;

procedure TDSMButton.SetLeft( NewVal : integer );
begin
  SendMessage( fMainWindow, WM_SIGBUTTONLEFT, fOwnerIndex, NewVal);
  fOwnerDims.Left := NewVal;
end;

function TDSMButton.GetWidth : integer;
begin
  Result := fOwnerDims.Width;
end;

procedure TDSMButton.SetWidth( NewVal : integer );
begin
  SendMessage( fMainWindow, WM_SIGBUTTONWIDTH, fOwnerIndex, NewVal);
  fOwnerDims.Width := NewVal;
end;

function TDSMButton.GetHeight : integer;
begin
  Result := fOwnerDims.Height;
end;

procedure TDSMButton.SetHeight( NewVal : integer );
begin
  SendMessage( fMainWindow, WM_SIGBUTTONHEIGHT, fOwnerIndex, NewVal);
  fOwnerDims.Height := NewVal;
end;

//--------- TDSMTitledButton -----------------------------

constructor TDSMTitledButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  inherited Create( pMainWindow, pOwnerIndex );
  iLines := tStringList.Create;
  ChangeProperty( 'Title', '' );
end;

destructor TDSMTitledButton.Destroy;
begin
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
  iTextArea := fOwnerDims;
  // hide unless in edit mode or Caption
  if Editing or ( LineCount > 0 ) or fAlwaysShow then
  begin
    PaintRaisedButton;
  end
  else if fHasStripe then
  begin
    DrawButtonStripe;
  end;

  if LineCount > 0 then
  begin
    fCanvas.Brush.Style := bsClear;
    fCanvas.Pen.Color := fTextColour;
    fCanvas.Font.Style := [ fsBold ];
    fCanvas.Font.Height := -14;
    fCanvas.Font.Name := 'MS Sans Serif';
    TextExtent := fCanvas.TextExtent( iLines[ 0 ] );
    iLineHt := (TextExtent.cy) * 5 div 4;
    iTop := (fOwnerDims.Height - LineCount * iLineHt) div 2;
    for i := 0 to LineCount - 1 do
    begin
      iLeft := (iTextArea.Width - fCanvas.TextWidth( iLines[ i ] )) div 2;
      fCanvas.TextOut( iLeft, iTop, iLines[ i ] );
      inc( iTop, iLineHt );
    end;
  end;
end;

function TDSMTitledButton.fGetLineCount : integer;
begin
  Result := iLines.Count;
end;

function TDSMTitledButton.SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean;
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
  if FormTextButtonProps.ShowModal = mrOK then
  begin
    Top := FormTextButtonProps.SpinEditTop.Value;
    Left := FormTextButtonProps.SpinEditLeft.Value;
    Height := FormTextButtonProps.SpinEditHeight.Value;
    Width := FormTextButtonProps.SpinEditWidth.Value;
    fIsDirty := TRUE;
    SetProperty( 'Title', FormTextButtonProps.EditText.Text );
  end;
end;

constructor TDSMButtonList.Create;
begin
  inherited Create( FALSE );
end;

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

constructor TDSMImageList.Create( pOwner : tDSMButton{; pOwnsImages : boolean} );
begin
  inherited Create( FALSE );
  iCurrImageIndex := 0;
  iOwner := pOwner;
  //iOwnsImages := pOwnsImages;
end;

destructor TDSMImageList.Destroy;
begin
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
  inherited Create( FALSE );
  iOwner := pOwner;
  //OwnsObjects := FALSE;
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
    fCanvas.Draw( AtX, AtY, iCurrImage.Graphic );
  end;
end;

//----------------- TTimerActionButton -------------------

constructor TTimerActionButton.Create( pMainWindow: HWND;
                        pOwnerIndex : integer );
begin
  inherited Create( pMainWindow, pOwnerIndex );
  fTimer := TTimer.Create( nil );
  fTimer.Enabled := FALSE;
  ChangeProperty( 'Interval', '1000' );
end;

destructor TTimerActionButton.Destroy;
begin
  fTimer.Enabled := FALSE;
  inherited;
end;

procedure TTimerActionButton.SetProperties;
begin
  if FormTimerButtonProps.ShowModal = mrOK then
  begin
    Top := FormTimerButtonProps.SpinEditTop.Value;
    Left := FormTimerButtonProps.SpinEditLeft.Value;
    Height := FormTimerButtonProps.SpinEditHeight.Value;
    Width := FormTimerButtonProps.SpinEditWidth.Value;
    fIsDirty := TRUE;
    SetProperty( 'Title', FormTimerButtonProps.EditText.Text );
    SetProperty( 'Interval', FormTimerButtonProps.SpinEditInterval.Text );
  end;
end;

function TTimerActionButton.SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean;
begin
  if SameText( PropertyID, 'Interval' ) then
  begin
    Interval := StrToIntDef( PropertyValue, 1000 );
  end;
  Result := inherited SetProperty( PropertyID, PropertyValue );
end;

function TTimerActionButton.fGetInterval : integer;
begin
  Result := fTimer.Interval;
end;

procedure TTimerActionButton.fSetInterval( NewVal : integer );
begin
  fTimer.Interval := NewVal;
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
  if assigned( fCurrImageList ) then
  begin
    if assigned( fCurrImageList.Graphic ) then
    begin
      fCanvas.Draw( fCurrImageList.AtX, fCurrImageList.AtY, fCurrImageList.Graphic );
    end;
  end;
end;

procedure TMovingImageButton.SetCurrImageList( NewVal : TDSMImageList );
begin
  fTimer.Enabled := FALSE;
  fCurrImageList := NewVal;
  if assigned( NewVal ) then
  begin
    fTimer.OnTimer := NewVal.fChangeImage;
    fTimer.Enabled := TRUE;
  end
  else
  begin
    fTimer.OnTimer := nil;
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
  fCurrImageList := TDSMImageListList.Create( self );
  fTimer.OnTimer := fCurrImageList.fChangeImage;
end;

destructor TMovingImagesButton.Destroy;
begin
  fTimer.Enabled := FALSE;
  fCurrImageList.Free;
  inherited Destroy;
end;

function TMovingImagesButton.fGetCurrImageList( index : integer ) : TDSMImageList;
begin
  Result := fCurrImageList[ index ];
end;

procedure TMovingImagesButton.SetCurrImageList( index : integer; NewVal : TDSMImageList );
begin
  fCurrImageList[ index ] := NewVal;
  Invalidate;
end;

procedure TMovingImagesButton.fOnPaint;
var
  i : integer;
begin
  inherited fOnPaint;
//  if not Editing then
  begin
    for i := 0 to fCurrImageList.Count - 1 do
    begin
      with fCurrImageList[ i ] do
      begin
        fCanvas.Draw( AtX, AtY, Graphic );
      end;
    end
  end;
end;

initialization
  ActiveButton := nil;

end.
