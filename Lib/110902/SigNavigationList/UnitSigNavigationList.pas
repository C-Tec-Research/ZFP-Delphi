unit UnitSigNavigationList;

{
  Maintains a list of 'locations' or jumps that a user can navigate to and from.
  A bit like an Undo/redo list but only navigates locations.

  Locations are store in a tJumpObject or descendant defined externally to the list

  Stack might also be a descendant of tNavigationList.

}

interface

uses
  Contnrs,
  Buttons,
  Classes;

type

  tJumpObject = class;

  tJumpMode = ( jmBack, jmForward );

  tOnJumpNavigate = procedure( const Sender : tJumpObject; const pMode : tJumpMode ) of object;

  tJumpObject = class( tObject )
  private
    fOnJumpNavigate: tOnJumpNavigate;
  public
    property OnJumpNavigate : tOnJumpNavigate
             read fOnJumpNavigate
             write fOnJumpNavigate;
    procedure JumpNavigate( const pMode : tJumpMode ); virtual;  // just calls OnJumpNavigate if defined. Descendants may do more
                                      // Called when Forward or Back button pressed
  end;

  tNavigationStack = class( tObjectStack )
  private
    fJumpMode: tJumpMode;
    fButton: tSpeedButton;
    fOnJumpNavigate: tOnJumpNavigate;
    procedure SetButton(const Value: tSpeedButton);
  public
    constructor Create( const pMode : tJumpMode );
    destructor Destroy; override;
    procedure Clear; reintroduce;
    procedure Push( NewVal :  tJumpObject ); reintroduce;
    function Pop : tJumpObject; reintroduce;
    function Peek : tJumpObject; reintroduce;
    property JumpMode : tJumpMode
             read fJumpMode;
    property Button : tSpeedButton
             read fButton
             write SetButton;
    property OnJumpNavigate : tOnJumpNavigate
             read fOnJumpNavigate
             write fOnJumpNavigate;
  end;

  tNavigationList = class
  private
    fBackButton: tSpeedButton;
    fOnBackClick : tNotifyEvent;
    fOnForwardClick : tNotifyEvent;
    fBackList :  tNavigationStack;
    fForwardList : tNavigationStack;
    fForwardButton: tSpeedButton;
    fOnJumpNavigate: tOnJumpNavigate;
    fVisible: boolean;
    procedure SetBackButton(const Value: tSpeedButton);
    procedure OnBackClick( Sender : tObject );
    procedure OnForwardClick( Sender : tObject );
    procedure SetForwardButton(const Value: tSpeedButton);
    procedure SetOnJumpNavigate(const Value: tOnJumpNavigate);
    procedure SetVisible(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddJump( NewVal : tJumpObject );

    property BackButton : tSpeedButton
             read fBackButton
             write SetBackButton;
    property ForwardButton : tSpeedButton
             read fForwardButton
             write SetForwardButton;
    property OnJumpNavigate : tOnJumpNavigate
             read fOnJumpNavigate
             write SetOnJumpNavigate;
    property Visible : boolean
             read fVisible
             write SetVisible;
  end;

implementation

{ tNavigationList }

procedure tNavigationList.AddJump(NewVal: tJumpObject);
begin
  fBackList.Push( NewVal );
  fForwardList.Clear;
end;

constructor tNavigationList.Create;
begin
  inherited Create;

  fBackList  :=  tNavigationStack.Create( jmBack );
  fForwardList := tNavigationStack.Create( jmForward );
end;

destructor tNavigationList.Destroy;
begin
  fBackList.Free;
  fForwardList.Free;

  inherited;
end;

procedure tNavigationList.OnBackClick(Sender: tObject);
var
  iJumpObject : tJumpObject;
begin
  iJumpObject := fBackList.Pop;
  if assigned( iJumpObject ) then
  begin
    fForwardList.Push( iJumpObject );
  end;
  if assigned( fOnBackClick ) then
  begin
    fOnBackClick( Sender );
  end;
end;

procedure tNavigationList.OnForwardClick(Sender: tObject);
var
  iJumpObject : tJumpObject;
begin
  iJumpObject := fForwardList.Pop;
  if assigned( iJumpObject ) then
  begin
    fBackList.Push( iJumpObject );
  end;
  if assigned( fOnForwardClick ) then
  begin
    fOnForwardClick( Sender );
  end;
end;

procedure tNavigationList.SetBackButton(const Value: tSpeedButton);
begin
  if assigned( fBackButton ) then
  begin
    fBackButton.OnClick := fOnBackClick;
  end;
  fBackButton := Value;
  fBackList.Button := Value;
  if assigned( fBackButton) then
  begin
    fOnBackClick := fBackButton.OnClick;
    fBackButton.OnClick := OnBackClick;
    fBackButton.Visible := fVisible;
  end;
end;

procedure tNavigationList.SetForwardButton(const Value: tSpeedButton);
begin
  if assigned( fForwardButton ) then
  begin
    fForwardButton.OnClick := fOnForwardClick;
  end;
  fForwardButton := Value;
  fForwardList.Button := Value;
  if assigned( fForwardButton) then
  begin
    fOnForwardClick := fForwardButton.OnClick;
    fForwardButton.OnClick := OnForwardClick;
    fForwardButton.Visible := fVisible;
  end;
end;

procedure tNavigationList.SetOnJumpNavigate(const Value: tOnJumpNavigate);
begin
  fOnJumpNavigate := Value;
  if not assigned( fBackList.OnJumpNavigate) then
  begin
    fBackList.OnJumpNavigate := Value;
  end;
  if not assigned( fForwardList.OnJumpNavigate) then
  begin
    fForwardList.OnJumpNavigate := Value;
  end;
end;

procedure tNavigationList.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  if assigned( fBackButton ) then
  begin
    fBackButton.Visible := Value;
  end;
  if assigned( fForwardButton ) then
  begin
    fForwardButton.Visible := Value;
  end;
end;

{ tNavigationStack }

procedure tNavigationStack.Clear;
var
  iJumpObject : tJumpObject;
begin
  while Count > 0 do
  begin
    iJumpObject := inherited Pop as tJumpObject;    // no Jump Navigate!
    iJumpObject.Free;
  end;
  if assigned( fButton ) then
  begin
    fButton.Enabled := FALSE;
  end;
end;

constructor tNavigationStack.Create(const pMode: tJumpMode);
begin
  inherited Create;
  fJumpMode := pMode;
end;

destructor tNavigationStack.Destroy;
begin
  Clear;
  inherited;
end;

function tNavigationStack.Peek: tJumpObject;
begin
  Result := inherited Peek as tJumpObject;
end;

function tNavigationStack.Pop: tJumpObject;
begin
  Result := inherited Pop as tJumpObject;
  if assigned( fButton ) then
  begin
    fButton.Enabled := Count > 0;
  end;
  if assigned( Result ) then
  begin
    Result.JumpNavigate( fJumpMode );
  end;
end;

procedure tNavigationStack.Push(NewVal: tJumpObject);
begin
  inherited Push( NewVal );
  if not assigned( NewVal.OnJumpNavigate ) then
  begin
    NewVal.OnJumpNavigate := OnJumpNavigate;
  end;
  if assigned( fButton ) then
  begin
    fButton.Enabled := TRUE;
  end;
end;

procedure tNavigationStack.SetButton(const Value: tSpeedButton);
begin
  fButton := Value;
  if assigned( fButton ) then
  begin
    if Count > 0 then
    begin
      fButton.Enabled := TRUE;
    end
    else
    begin
      fButton.Enabled := FALSE;
    end;
  end;
end;

{ tJumpObject }

procedure tJumpObject.JumpNavigate( const pMode : tJumpMode );
begin
  if assigned( fOnJumpNavigate ) then
  begin
    fOnJumpNavigate( self, pMode );
  end;
end;

end.
