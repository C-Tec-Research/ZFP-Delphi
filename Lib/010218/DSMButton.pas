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
  Dialogs,
  Messages,
  UnitTextButtonProps,
  UnitBasicButtonProps;

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
    iBevelWidth : integer;
    iFlat     : boolean;
    iTextColour : tColor;
    iIsDirty : boolean;
    iEditing : boolean;
    Canvas   : TCanvas;
    iOwnerIndex : integer;
    iOwnerDims : TButtonDims;
    function Flat   : boolean;
    procedure PaintRaisedButton;
    procedure fDoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure fDoMouseMoveNormal  ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure fDoMouseUpNormal  (  pButton : TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    function fGetPropertyName( iIndex : integer ) : shortstring;
    function fGetPropertyValue( iIndex : integer ) : shortstring;
    procedure fOnPaint; virtual;
    function fGetTop : integer;
    procedure fSetTop( NewVal : integer );
    function fGetLeft : integer;
    procedure fSetLeft( NewVal : integer );
    function fGetWidth : integer;
    procedure fSetWidth( NewVal : integer );
    function fGetHeight : integer;
    procedure fSetHeight( NewVal : integer );
  public
    { Public declarations }
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); virtual;
    destructor Destroy; override;
    procedure SetProperties; virtual;
    class function IsStyle( const ButtonType : string ) : boolean;
    class function Style : shortstring; virtual;
    procedure DoMouseDownNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseMoveNormal( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUpNormal  ( pButton : TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
    function SetPropertyAsInt( const PropertyID : shortstring;
                          const PropertyValue : integer ) : boolean;
    // Changes a property, but does not create it if it does not exist
    function ChangeProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
    // Changes a property, creating it if necessary
    function GetProperty( const PropertyID : shortstring ) : shortstring;
    function GetPropertyAsInt( const PropertyID : shortstring ) : integer;
    property PropertyCount : integer
             read iPropertyCount;
    property PropertyName[ iIndex : integer ] : shortstring
             read fGetPropertyName;
    property PropertyValue[ iIndex : integer ] : shortstring
             read fGetPropertyValue;
    property Editing : boolean
             read iEditing
             write iEditing;
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
    property IsEditing : boolean
             read iEditing
             write iEditing;
{
    property Owner : TPaintbox
             read iOwner;
}
//    procedure OnPaint( Canvas : TCanvas; pOwnerDims : TButtonDims );
//    procedure OnPaint( MyBoss : TPaintBox; pOwnerDims : TButtonDims );
    procedure OnPaint( pOwnerDims : TButtonDims );
  end;

  TDSMTitledButton = class( TDSMButton )
  private
    { Private declarations }
  protected
    { Protected declarations }
{
    procedure fPaintTitled(Sender: TObject);
    procedure EndEdit; override;
    procedure fSetTitle( NewTitle : string );
}
    procedure fOnPaint; override;
  public
    { Public declarations }
    constructor Create( pMainWindow: HWND;
                        pOwnerIndex : integer ); override;
    procedure SetProperties; override;
{
    property Title : string
      read iTitle
      write fSetTitle;
}
  end;

var
  ActiveButton : TDSMButton{TPaintbox}{ TSigButton };

implementation

//-------------------- TDSMButton -----------------

constructor TDSMButton.Create( pMainWindow: HWND;
                               pOwnerIndex : integer );
begin
  iOwnerIndex := pOwnerIndex;
  iMainWindow := pMainWindow;
  iPropertyCount := 0;
  iColour := clSilver;
  iBevelWidth := 3;
  iFlat := FALSE;
  iTextColour := clBlack;
  Canvas := TCanvas.Create;
end;

destructor TDSMButton.Destroy;
begin
  Canvas.Free;
  inherited Destroy;
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
  with FormBasicButtonProps do
  begin
{
    SpinEditTop.Value := Y;
    SpinEditLeft.Value := X;
    SpinEditHeight.Value := H;
    SpinEditWidth.Value := W;
}
    if ShowModal = mrOK then
    begin
      Top := SpinEditTop.Value;
      Left := SpinEditLeft.Value;
      Height := SpinEditHeight.Value;
      Width := SpinEditWidth.Value;
      iIsDirty := TRUE;
//      EndEdit;
    end;
  end;
end;

procedure TDSMButton.fOnPaint;
begin
  if Editing then
  begin
    PaintRaisedButton;
  end;
end;

procedure TDSMButton.PaintRaisedButton;
var
  i : integer;
begin
  with Canvas do
  begin
    Brush.Color := iColour;
    Pen.Color := clBlack;
    Rectangle( 0, 0, iOwnerDims.Width, iOwnerDims.Height );
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
      iProperty[ i ].PropertyValue := PropertyValue;
      iProperty[ i ].PropertyAsInt := StrToIntDef( PropertyValue, 0 );
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

function TDSMButton.SetPropertyAsInt( const PropertyID : shortstring;
                      const PropertyValue : integer ) : boolean;
var
  i : integer;
begin
  // only allow updates - no creation
  Result := FALSE;
  for i := 1 to iPropertyCount do
  begin
    if AnsiCompareText( iProperty[ i ].PropertyID, PropertyID ) = 0 then
    begin
      iProperty[ i ].PropertyValue := IntToStr( PropertyValue );
      iProperty[ i ].PropertyAsInt := PropertyValue;
      Result := TRUE;
      Exit;
    end;
  end;
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
  ChangeProperty( 'Title', '' );
end;

//procedure TDSMTitledButton.fOnPaint( Canvas : TCanvas );
//procedure TDSMTitledButton.fOnPaint( MyBoss : TPaintbox );
procedure TDSMTitledButton.fOnPaint;
var
  TextExtent : tSize;
  iTitle : string;
//  ClientRect : TRect;
begin
  // hide unless in edit mode or Caption
  iTitle := GetProperty( 'Title' );
  if Editing or (iTitle <> '') then
  begin
    PaintRaisedButton;
    TextExtent := Canvas.TextExtent( iTitle );
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := iTextColour;
    Canvas.TextOut ( (iOwnerDims.Width - TextExtent.cx) div 2,
                       (iOwnerDims.Height - TextExtent.cy) div 2, iTitle );
  end;
end;

procedure TDSMTitledButton.SetProperties;
begin
  // Tile and size properties
  with FormTextButtonProps do
  begin
{
    SpinEditTop.Value := Y;
    SpinEditLeft.Value := X;
    SpinEditHeight.Value := H;
    SpinEditWidth.Value := W;
}
    if ShowModal = mrOK then
    begin
      Top := SpinEditTop.Value;
      Left := SpinEditLeft.Value;
      Height := SpinEditHeight.Value;
      Width := SpinEditWidth.Value;
      iIsDirty := TRUE;
      SetProperty( 'Title', EditText.Text );
//      EndEdit;
    end;
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

initialization
  ActiveButton := nil;

end.
