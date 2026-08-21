unit SigButton;

interface

uses
  Windows,
  Forms,
  Controls,
  ExtCtrls,
  Graphics,
  Classes,
  SysUtils,
  Messages,
  DSMButton,
  UnitSigMAINButtons,
  UnitMain;

const
  WM_CHANGESIGBUTTON = WM_APP + 400;
  WM_SIGBUTTONDIRTY  = WM_APP + 401;
//  WM_LOADAREA        = WM_APP + 402; used in UnitSigMAINButtons
//  WM_SIGBUTTONTOP    = WM_APP + 403; used in DSMButton
//  WM_SIGBUTTONLEFT   = WM_APP + 404;       "
//  WM_SIGBUTTONWIDTH  = WM_APP + 405;       "
//  WM_SIGBUTTONHEIGHT = WM_APP + 406;       "
//  WM_SIGBUTTONREFRESH= WM_APP + 407;       "

type
//  TSigButton = class( TPaintbox )
  TSigButton = class( TGraphicControl )
  {
    This operates as a factory-style object and placeholder
    It creates and holds the correct button type
    and hold externally controlled values
  }
  private
    { Private declarations }
    iButtonStyle : string;
    UsesDLL : boolean;
    iObject : TDSMButton; // to actual object
    iOldX, iOldY : integer;
    iSectionName : string;
    iUpdating : boolean;
    iButton : TMouseButton;
    iOwner : TForm;
    iDims : TButtonDims;
    iIndex : integer;
    iEditing : boolean;
    procedure fOnMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure fOnMouseMove(Sender: TObject;
              Shift: TShiftState; X, Y: Integer);
    procedure fOnMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure DoMouseDownEditing( Shift: TShiftState; X, Y: Integer);
    procedure DoMouseMoveEditing( Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUpEditing(   Shift: TShiftState; X, Y: Integer);
    procedure EndEdit;
    function fGetPropertyCount : integer;
    function fGetPropertyName( iIndex : integer ) : string;
    function fGetPropertyValue( iIndex : integer ) : string;
    procedure fWriteSectionName( NewName : string );
    procedure fSetTop( NewVal : integer );
    procedure fSetLeft( NewVal : integer );
    procedure fSetWidth( NewVal : integer );
    procedure fSetHeight( NewVal : integer );
  protected
    { Protected declarations }
    function fGetDirty : boolean;
    procedure fSetDirty( NewVal : boolean );
    function fGetEditing : boolean;
    procedure fSetEditing( NewVal : boolean );
//    procedure fPaint(Sender: TObject);
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create( AOwner : TForm; AParent : TForm;
                        const ButtonStyle : string;
                        const SectionName : string;
                        pIndex : integer;
                        X : integer;
                        Y : integer;
                        W : integer;
                        H : integer ); reintroduce;
    procedure ChangeObject( const ButtonStyle : string;
                  const SectionName : string;
                        X : integer;
                        Y : integer;
                        W : integer;
                        H : integer );
    destructor Destroy; override;
    property ButtonStyle : string
             read iButtonStyle; // read only property
    property IsDirty : boolean
             read fGetDirty
             write fSetDirty;
    property Editing : boolean
             read fGetEditing
             write fSetEditing;
    function SetProperty( const PropertyID : string;
                          const PropertyValue : string ) : boolean;
    function SetPropertyAsInt( const PropertyID : string;
                          const PropertyValue : integer ) : boolean;
    function GetProperty( const PropertyID : string ) : string;
    function GetPropertyAsInt( const PropertyID : string ) : integer;
    procedure SetProperties;
    property Section : string
             read iSectionName
             write fWriteSectionName;
    property PropertyCount : integer
             read fGetPropertyCount;
    property PropertyName[ iIndex : integer ] : string
             read fGetPropertyName;
    property PropertyValue[ iIndex : integer ] : string
             read fGetPropertyValue;
    class function GetButtonStyleCount : integer;
    class function GetButtonStyle( pIndex : integer ) : string;
    class procedure SetActiveProperties;
    function Style : string;
    procedure MakeActive;
    property ButtonObject : TDSMButton
             read iObject;
    property Top
             write fSetTop;
    property Left
             write fSetLeft;
    property Width
             write fSetWidth;
    property Height
             write fSetHeight;
  end;

var
  OldButton : TSigButton;

implementation

//-------------------- TSigButton -----------------

const
  cIntrinsicButtonTypeCount = 2;
                            // Exit
                            // Area

var
  TSigButton_Last    : TRect; // Misuse - Bottom = Height, Right = Width

class function TSigButton.GetButtonStyleCount : integer;
begin
  Result := cIntrinsicButtonTypeCount + UnitMain.GetButtonStyleCount;
end;

class function TSigButton.GetButtonStyle( pIndex : integer ) : string;
begin
  case pIndex of
    1: Result := TAreaButton.Style;
    2: Result := TExitButton.Style;
    else
      Result := UnitMain.GetButtonStyle( pIndex - cIntrinsicButtonTypeCount );
  end;
end;

constructor TSigButton.Create( AOwner : TForm; AParent : TForm;
                               const ButtonStyle : string;
                               const SectionName : string;
                               pIndex : integer;
                               X,Y,W,H : integer );
begin
  inherited Create( AOwner );
  ParentFont := FALSE;
  OnMouseDown := fOnMouseDown;
  OnMouseMove := fOnMouseMove;
  OnMouseUp   := fOnMouseUp;
  iButton := mbMiddle; // safe, unused value
  iUpdating := FALSE;
  iOwner := AOwner;
  iObject := nil;
//  OnPaint := fPaint;
  Editing := FALSE;
  Parent := AParent;
  iIndex := pIndex;
  ChangeObject( ButtonStyle, SectionName, X, Y, W, H );
  // ensure mouse is captured
  ControlStyle := ControlStyle + [csCaptureMouse ];
end;

procedure TSigButton.Paint;
begin
  if assigned( iObject ) then
  begin
    if usesDLL then
    begin
      UnitMain.PaintButton( iObject, iDims );
    end
    else
    begin
      iObject.OnPaint( iDims);
    end;
  end;
end;

procedure TSigButton.ChangeObject( const ButtonStyle : string;
                  const SectionName : string;
                        X : integer;
                        Y : integer;
                        W : integer;
                        H : integer );
begin
  iSectionName := SectionName;
  Visible      := TRUE;

  with TSigButton_Last do
  begin
    if (W = 0) or (H = 0) then
    begin
      if (Top + 2 * Bottom) < iOwner.ClientHeight then
      begin
        Top := Top + Bottom;
      end
      else
      begin
        Top := 0;
        if (Left + 2 * Right) < iOwner.ClientWidth then
        begin
          Left := Left + Right;
        end
        else
        begin
          Left := 0;
        end;
      end;
      X := Left;
      Y := Top;
      W := Right;
      H := Bottom;
    end
    else
    begin
      Left := X;    // TSigButton_Last values, not TSigButton values
      Top  := Y;
      Right := W;
      Bottom := H;
    end;
  end;  // misuse of TRect - Bottom = height, Right = Width

  Top := Y;
  Left := X;
  Width := W;
  Height := H;

  if assigned( iObject ) then
  begin
    if UsesDLL then
    begin
      UnitMain.DestroyButton( iObject );
    end
    else
    begin
      iObject.Free;
    end;
    iObject := nil;
  end;

  iButtonStyle := ButtonStyle;

  // check internal styles first
  UsesDLL := FALSE;
  if TDSMButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TDSMButton.Create( Parent.Handle, iIndex );
  end
  else if TExitButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TExitButton.Create( Parent.Handle, iIndex );
  end
  else if TAreaButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TAreaButton.Create( Parent.Handle, iIndex );
  end
  else
  begin
    iObject := UnitMain.CreateButton( ButtonStyle, Parent.Handle, iIndex );
    UsesDLL := TRUE;
//    iObject := nil;
  end;

  if UsesDLL then
  begin
    UnitMain.SetButtonDims( iObject, iDims );
  end
  else
  begin
    iObject.SetButtonDims( iDims );
  end;

end;

destructor TSigButton.Destroy;
begin
  if assigned( iObject ) then
  begin
    if UsesDLL then
    begin
      UnitMain.DestroyButton( iObject );
    end
    else
    begin
      iObject.Free;
    end;
  end;
  inherited Destroy;
end;

procedure TSigButton.fSetTop( NewVal : integer );
begin
  inherited Top := NewVal;
  iDims.Top := NewVal;
end;

procedure TSigButton.fSetLeft( NewVal : integer );
begin
  inherited Left := NewVal;
  iDims.Left := NewVal;
end;

procedure TSigButton.fSetWidth( NewVal : integer );
begin
  inherited Width := NewVal;
  iDims.Width := NewVal;
end;

procedure TSigButton.fSetHeight( NewVal : integer );
begin
  inherited Height := NewVal;
  iDims.Height := NewVal;
end;

function TSigButton.fGetDirty : boolean;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).IsDirty
    if UsesDLL then
    begin
      Result := UnitMain.GetDirty( iObject );
    end
    else
    begin
      Result := iObject.IsDirty;
    end;
  end
  else
    Result := FALSE;
end;

procedure TSigButton.fSetDirty( NewVal : boolean );
begin
  if assigned( iObject ) then
//    TDSMButton( iObject ).IsDirty := NewVal;
    if UsesDLL then
    begin
      UnitMain.SetDirty( iObject, NewVal );
    end
    else
    begin
      iObject.IsDirty := NewVal;
    end;
end;

function TSigButton.fGetEditing : boolean;
begin
{
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).IsEditing
    if UsesDLL then
    begin
      UnitMain.GetEditing( iObject );
    end
    else
    begin
      Result := iObject.IsEditing;
    end
  else
}
    Result := iEditing;
end;

procedure TSigButton.fSetEditing( NewVal : boolean );
begin
  if assigned( iObject ) then
  begin
//    TDSMButton( iObject ).IsEditing := NewVal;
    if UsesDLL then
    begin
      UnitMain.SetEditing( iObject, NewVal );
    end
    else
    begin
      iObject.Editing := NewVal;
    end;
  end;
  iEditing := NewVal;
end;

procedure TSigButton.fWriteSectionName( NewName : string );
begin
  iSectionName := NewName;
  SendMessage( iOwner.Handle, WM_SIGBUTTONDIRTY, 0, integer(self) );
end;

function TSigButton.SetProperty( const PropertyID : string;
                      const PropertyValue : string ) : boolean;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).SetProperty( PropertyID, PropertyValue );
    if UsesDLL then
    begin
      Result := UnitMain.SetProperty( iObject, PropertyID, PropertyValue );
    end
    else
    begin
      Result := iObject.SetProperty( PropertyID, PropertyValue );
    end;
    Invalidate;
  end
  else
    Result := FALSE;
end;

function TSigButton.SetPropertyAsInt( const PropertyID : string;
                          const PropertyValue : integer ) : boolean;
begin
  Result := SetProperty( PropertyID, IntToStr( PropertyValue ));
end;

function TSigButton.Style : string;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).Style;
    if UsesDLL then
    begin
      Result := UnitMain.ButtonStyle( iObject );
    end
    else
    begin
      Result := iObject.Style;
    end;
  end
  else
  begin
    Result := '';
  end;
end;

function TSigButton.GetProperty( const PropertyID : string ) : string;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).GetProperty( PropertyID )
  begin
    if UsesDLL then
    begin
      Result := UnitMain.GetProperty( iObject, PropertyID );
    end
    else
    begin
      Result := iObject.GetProperty( PropertyID )
    end;
  end
  else
    Result := '';
end;

function TSigButton.GetPropertyAsInt( const PropertyID : string ) : integer;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).GetPropertyAsInt( PropertyID )
    if UsesDLL then
    begin
      Result := UnitMain.GetPropertyAsInt( iObject, PropertyID );
    end
    else
    begin
      Result := iObject.GetPropertyAsInt( PropertyID );
    end
  else
    Result := 0;
end;

procedure TSigButton.MakeActive;
begin
  if Editing then
  begin
    if assigned( iObject ) then
    begin
      if UsesDLL then
      begin
        // Set ActiveButton in DLL
        UnitMain.MakeButtonActive( iObject );
        //ActiveButton := nil; // local instance
      end
      else
      begin
        // Set ActiveButton in DLL to nil
        //UnitMain.MakeButtonActive( nil );
        ActiveButton := iObject; // local instance
      end;
    end
    else
    begin
      ActiveButton := nil;
    end;
    SendMessage( iOwner.Handle, WM_CHANGESIGBUTTON, 0, integer(self) );
//    Allow owner to do what it needs
    if assigned( OldButton ) then
    begin
      OldButton.Invalidate;
    end;
    OldButton := self;
  end;
end;

procedure TSigButton.fOnMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
begin
  iButton := Button; // needed for mouse move
  if Editing then
  begin
    MakeActive;
    DoMouseDownEditing( Shift, X, Y );
  end
  else
  begin
    if assigned( iObject ) then
    begin
//      TDSMButton( iObject ).DoMouseDownNormal( Shift, X, Y );
      if UsesDLL then
      begin
        UnitMain.DoMouseDownNormal( iObject, iButton, Shift, X, Y );
      end
      else
      begin
        iObject.DoMouseDownNormal( iButton, Shift, X, Y );
      end;
    end;
  end;
  Invalidate; // repaint
end;

procedure TSigButton.fOnMouseMove(Sender: TObject;
              Shift: TShiftState; X, Y: Integer);
begin
  if iButton <> mbMiddle then // unused value, also used for not pressed
  begin
    if not iUpdating then
    begin
      iUpdating := TRUE; // stop re-entrancy problems
      if Editing then
        DoMouseMoveEditing( Shift, X, Y )
      else
      begin
        if assigned( iObject ) then
        begin
//          TDSMButton( iObject ).DoMouseMoveNormal( Shift, X, Y );
          if UsesDLL then
          begin
            UnitMain.DoMouseMoveNormal( iObject, iButton, Shift, X, Y );
          end
          else
          begin
            iObject.DoMouseMoveNormal( iButton, Shift, X, Y );
          end;
        end;
      end;
      Invalidate;
      iUpdating := FALSE;
    end;
  end;
end;

procedure TSigButton.fOnMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
begin
  if Editing then
  begin
    DoMouseUpEditing( Shift, X, Y );
  end
  else
  begin
    iButton := mbMiddle; // safe, unused value
    if assigned( iObject ) then
    begin
//      TDSMButton( iObject ).DoMouseUpNormal( Button, Shift, X, Y );
      if UsesDLL then
      begin
        UnitMain.DoMouseUpNormal( iObject, Button, Shift, X, Y );
      end
      else
      begin
        iObject.DoMouseUpNormal( Button, Shift, X, Y );
      end;
      // This statement must be the last executable that acesses
      // iObject, since activation of DoMouseupNormal can result
      // in destruction of the iObject
    end;
  end;
  Invalidate;
end;

procedure TSigButton.DoMouseDownEditing( Shift: TShiftState; X, Y: Integer);
begin
  iOldX := X;
  iOldY := Y;
end;

procedure TSigButton.DoMouseMoveEditing( Shift: TShiftState; X, Y: Integer);
begin
  if (X <> iOldX) or (Y <> iOldY ) then
  begin
    IsDirty := TRUE;
    case iButton of
      mbLeft:
      begin
        // move
        if (X <> iOldX) then
        begin
          Left := Left + X - iOldX;
        end;
        if (Y <> iOldY) then
        begin
          Top := Top + Y - iOldY;
        end;
      end;
      mbRight:
      begin
        // resize;
        if (X <> iOldX) then
        begin
          Width := Width + X - iOldX;
          iOldX := X;
          IsDirty := TRUE;
        end;
        if (Y <> iOldY) then
        begin
          Height := Height + Y - iOldY;
          iOldY := Y;
        end;
      end;
    end;
  end;
end;

procedure TSigButton.DoMouseUpEditing( Shift: TShiftState; X, Y: Integer);
begin
  EndEdit;
end;

procedure TSigButton.EndEdit;
begin
  if IsDirty then
  begin
    // save properties
    SendMessage( iOwner.Handle, WM_SIGBUTTONDIRTY, 0, integer(self) );
  end;
  iButton := mbMiddle; // safe value
end;

function TSigButton.fGetPropertyCount : integer;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyCount
    if UsesDLL then
      Result := UnitMain.GetPropertyCount( iObject )
    else
      Result := iObject.PropertyCount
  else
    Result := 0;
end;

function TSigButton.fGetPropertyName( iIndex : integer ) : string;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyName[ iIndex ]
    if UsesDLL then
      Result := UnitMain.GetPropertyName( iObject, iIndex )
    else
      Result := iObject.PropertyName[ iIndex ]
  else
    Result := 'Property[ ' + IntToStr( iIndex ) + ' ]';
end;

function TSigButton.fGetPropertyValue( iIndex : integer ) : string;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyValue[ iIndex ]
    if UsesDLL then
      Result := UnitMain.GetPropertyValue( iObject, iIndex )
    else
      Result := iObject.PropertyValue[ iIndex ]
  else
    Result := '';
end;

procedure TSigButton.SetProperties;
begin
  if assigned( iObject ) then
  begin
//    TDSMButton( iObject ).SetProperties;
    if UsesDLL then
    begin
      UnitMain.SetProperties( iObject );
    end
    else
    begin
      iObject.SetProperties;
    end;
    EndEdit;
  end;
end;

//procedure TSigButton.PaintWindow(DC: HDC);

{
procedure TSigButton.fPaint(Sender: TObject);
begin
  if assigned( iObject ) then
    if usesDLL then
    begin
      UnitMain.PaintButton( iObject, iDims );
    end
    else
    begin
      iObject.OnPaint( iDims);
    end;
//  inherited;
end;
}

class procedure TSigButton.SetActiveProperties;
begin
  if assigned( OldButton ) then
  begin
    OldButton.SetProperties;
  end;
end;

initialization
  //SigButton32Load;
  with TSigButton_Last do
  begin
    Left := 0;
    Top  := 0;
    Right := 128; // Width
    Bottom := 64; // Height
  end;
  OldButton := nil;

finalization
  //SigButton32Unload;

end.
