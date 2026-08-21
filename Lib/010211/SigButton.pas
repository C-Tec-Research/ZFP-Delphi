unit SigButton;

interface

uses
  Windows,
  Forms,
  Controls,
  ExtCtrls,
  Classes,
  SysUtils,
  Messages,
  DSMButton,
  UnitSigMAINButtons,
  SigButton32Interface;

const
  WM_CHANGESIGBUTTON = WM_APP + 400;
  WM_SIGBUTTONDIRTY  = WM_APP + 401;
//  WM_LOADAREA        = WM_APP + 402; used in UnitSigMAINButtons

type
  TSigButton = class( TPaintbox )
  {
    This operates as a factory-style object and placeholder
    It creates and holds the correct button type
    and hold externally controlled values
  }
  private
    { Private declarations }
    iButtonStyle : shortstring;
    UsesDLL : boolean;
    iObject : TDSMButton; // to actual object
    iOldX, iOldY : integer;
    iSectionName : shortstring;
    iUpdating : boolean;
    iButton : TMouseButton;
    iOwner : TForm;
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
    function fGetPropertyName( iIndex : integer ) : shortstring;
    function fGetPropertyValue( iIndex : integer ) : shortstring;
    procedure fPaint(Sender: TObject);
    procedure fWriteSectionName( NewName : shortstring );
  protected
    { Protected declarations }
    function fGetDirty : boolean;
    procedure fSetDirty( NewVal : boolean );
    function fGetEditing : boolean;
    procedure fSetEditing( NewVal : boolean );
  public
    { Public declarations }
    constructor Create( AOwner : TForm;
                        const ButtonStyle : shortstring;
                        const SectionName : shortstring;
                        X : integer = 0;
                        Y : integer = 0;
                        W : integer = 0;
                        H : integer = 0 ); reintroduce;
    procedure ChangeObject( const ButtonStyle : shortstring;
                  const SectionName : shortstring;
                        X : integer = 0;
                        Y : integer = 0;
                        W : integer = 0;
                        H : integer = 0 );
    destructor Destroy; override;
    property ButtonStyle : shortstring
             read iButtonStyle; // read only property
    property IsDirty : boolean
             read fGetDirty
             write fSetDirty;
    property Editing : boolean
             read fGetEditing
             write fSetEditing;
    function SetProperty( const PropertyID : shortstring;
                          const PropertyValue : shortstring ) : boolean;
    function GetProperty( const PropertyID : shortstring ) : shortstring;
    function GetPropertyAsInt( const PropertyID : shortstring ) : integer;
    procedure SetProperties;
    property Section : shortstring
             read iSectionName
             write fWriteSectionName;
    property PropertyCount : integer
             read fGetPropertyCount;
    property PropertyName[ iIndex : integer ] : shortstring
             read fGetPropertyName;
    property PropertyValue[ iIndex : integer ] : shortstring
             read fGetPropertyValue;
    class function GetButtonStyleCount : integer;
    class function GetButtonStyle( pIndex : integer ) : shortstring;
    function Style : shortstring;
    procedure MakeActive;
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
  Result := cIntrinsicButtonTypeCount + SigButton32_GetButtonStyleCount;
end;

class function TSigButton.GetButtonStyle( pIndex : integer ) : shortstring;
begin
  case pIndex of
    1: Result := TAreaButton.Style;
    2: Result := TExitButton.Style;
    else
      Result := SigButton32_GetButtonStyle( pIndex - cIntrinsicButtonTypeCount );
  end;
end;

constructor TSigButton.Create( AOwner : TForm;
                               const ButtonStyle : shortstring;
                               const SectionName : shortstring;
                               X,Y,W,H : integer );
begin
  inherited Create( AOwner );
  OnMouseDown := fOnMouseDown;
  OnMouseMove := fOnMouseMove;
  OnMouseUp   := fOnMouseUp;
  iButton := mbMiddle; // safe, unused value
  iUpdating := FALSE;
  iOwner := AOwner;
  iObject := nil;
  UsesDLL := FALSE;
  OnPaint := fPaint;
  Editing := FALSE;
  ChangeObject( ButtonStyle, SectionName, X, Y, W, H );
end;

procedure TSigButton.ChangeObject( const ButtonStyle : shortstring;
                  const SectionName : shortstring;
                        X : integer = 0;
                        Y : integer = 0;
                        W : integer = 0;
                        H : integer = 0 );
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
    if AnsiCompareText( iButtonStyle, ButtonStyle ) = 0 then
//    if iObject.IsStyle( ButtonStyle ) then
    begin
      // same type - just change parameters
      Exit;
    end
    else
    begin
      if UsesDLL then
      begin
        SigButton32_DestroyButton( iObject );
        UsesDLL := FALSE;
      end
      else
      begin
        iObject.Free;
      end;
    end;
  end;

  iButtonStyle := ButtonStyle;

  // check internal styles first
  if TDSMButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TDSMButton.Create( self );
  end
  else if TExitButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TExitButton.Create( self );
  end
  else if TAreaButton.IsStyle( ButtonStyle ) then
  begin
    iObject := TAreaButton.Create( self );
  end
  else
  begin
    iObject := SigButton32_CreateButton( self, ButtonStyle );
    UsesDLL := TRUE;
//    iObject := nil;
  end;

end;

destructor TSigButton.Destroy;
begin
  if assigned( iObject ) then
//    TDSMButton(iObject ).Free;
    if UsesDLL then
    begin
      SigButton32_DestroyButton( iObject );
    end
    else
    begin
      iObject.Free;
    end;
  inherited Destroy;
end;

function TSigButton.fGetDirty : boolean;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).IsDirty
    if UsesDLL then
    begin
      Result := FALSE; // for now
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
      // do nothing for now
    end
    else
    begin
      iObject.IsDirty := NewVal;
    end;
end;

function TSigButton.fGetEditing : boolean;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).IsEditing
    if UsesDLL then
    begin
      Result := FALSE; // for now
    end
    else
    begin
      Result := iObject.IsEditing;
    end
  else
    Result := FALSE;
end;

procedure TSigButton.fSetEditing( NewVal : boolean );
begin
  if assigned( iObject ) then
  begin
//    TDSMButton( iObject ).IsEditing := NewVal;
    if UsesDLL then
    begin
      // do nothing for now
    end
    else
    begin
      iObject.IsEditing := NewVal;
    end;
  end;
end;

procedure TSigButton.fWriteSectionName( NewName : shortstring );
begin
  iSectionName := NewName;
  PostMessage( iOwner.Handle, WM_SIGBUTTONDIRTY, 0, integer(self) );
end;

function TSigButton.SetProperty( const PropertyID : shortstring;
                      const PropertyValue : shortstring ) : boolean;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).SetProperty( PropertyID, PropertyValue );
    if UsesDLL then
    begin
      Result := FALSE; // for now
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

function TSigButton.Style : shortstring;
begin
  if assigned( iObject ) then
  begin
//    Result := TDSMButton( iObject ).Style;
    if UsesDLL then
    begin
      Result := iButtonStyle; // for now
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

function TSigButton.GetProperty( const PropertyID : shortstring ) : shortstring;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).GetProperty( PropertyID )
  begin
    if UsesDLL then
    begin
      Result := ''; // for now
    end
    else
    begin
      Result := iObject.GetProperty( PropertyID )
    end;
  end
  else
    Result := '';
end;

function TSigButton.GetPropertyAsInt( const PropertyID : shortstring ) : integer;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).GetPropertyAsInt( PropertyID )
    if UsesDLL then
    begin
      Result := 0; // for now
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
        ActiveButton := iObject; // local instance
      end
      else
      begin
        // Set ActiveButton in DLL to nil
        ActiveButton := nil; // local instance
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
    Invalidate;
  end
  else
  begin
    if assigned( iObject ) then
    begin
//      TDSMButton( iObject ).DoMouseDownNormal( Shift, X, Y );
      if UsesDLL then
      begin
        // Do nothing for now
      end
      else
      begin
        iObject.DoMouseDownNormal( Shift, X, Y );
      end;
      Invalidate; // repaint
    end;
  end;
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
            // do nothing for now
          end
          else
          begin
            iObject.DoMouseMoveNormal( Shift, X, Y );
          end;
        end;
      end;
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
        // try direct access
//        iObject.DoMouseUpNormal( Button, Shift, X, Y );
      end
      else
      begin
        iObject.DoMouseUpNormal( Button, Shift, X, Y );
      end;
      // This statement must be the last executable, since activation
      // of iObject DoMouse up Normal can result in destruction of the
      // object
    end;
  end;
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
{
    with FormMain.SigAreas do
    begin
      WriteString( iSectionName, 'Type', iButtonStyle );

      WriteInteger( iSectionName, 'X', Left );
      WriteInteger( iSectionName, 'Y', Top );
      WriteInteger( iSectionName, 'W', Width );
      WriteInteger( iSectionName, 'H', Height );
    end;
    iIsDirty := FALSE;
}
  end;
end;

function TSigButton.fGetPropertyCount : integer;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyCount
    if UsesDLL then
      Result := 0 // for now
    else
      Result := iObject.PropertyCount
  else
    Result := 0;
end;

function TSigButton.fGetPropertyName( iIndex : integer ) : shortstring;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyName[ iIndex ]
    if UsesDLL then
      Result := 'Property[ ' + IntToStr( iIndex ) + ' ]' // for now
    else
      Result := iObject.PropertyName[ iIndex ]
  else
    Result := 'Property[ ' + IntToStr( iIndex ) + ' ]';
end;

function TSigButton.fGetPropertyValue( iIndex : integer ) : shortstring;
begin
  if assigned( iObject ) then
//    Result := TDSMButton( iObject ).PropertyValue[ iIndex ]
    if UsesDLL then
      Result := '' // for now
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
      // do nothing for now
    end
    else
    begin
      iObject.SetProperties;
    end;
    EndEdit;
  end;
end;

procedure TSigButton.fPaint(Sender: TObject);
begin
  if assigned( iObject ) then
//    TDSMButton( iObject ).OnPaint( Sender );
    if usesDLL then
    begin
      // try direct access
//      iObject.OnPaint( Sender );
    end
    else
    begin
      iObject.OnPaint( Sender );
    end;
end;

initialization
  SigButton32Load;
  with TSigButton_Last do
  begin
    Left := 0;
    Top  := 0;
    Right := 128; // Width
    Bottom := 64; // Height
  end;
  OldButton := nil;

finalization
  SigButton32Unload;

end.
