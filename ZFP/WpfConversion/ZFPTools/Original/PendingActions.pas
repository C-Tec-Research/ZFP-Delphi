unit PendingActions;

interface

{*****************************************************************************
 *                                                                           *
 * The purpose of this is to generate a list of events that must occur after *
 * short delay (often zero, effectively). The event is added to the list     *
 * together with an optional object to be passed as a parameter to the event *
 * Once executed the event is optionally destroyed (if the new delay is less *
 * than zero).                                                               *
 *                                                                           *
 * Two events are considered the same if they have the same callback and the *
 * same object. Such events are usually merged, and the default merge action *
 * is da_Keep_Last.                                                          *
 *                                                                           *
 * Avoid creating a duplicate object from within a callback for that object, *
 * since it probably will not have the desired effect. Instead pass a new    *
 * delay back to the callback.                                               *
 *                                                                           *
 * tDuplicateAction can have the following values                            *
 *    da_Allow_Duplicates: Duplicates will be created without checking       *
 *    da_Keep_Earliest:    New duplicate objects will be ignored             *
 *    da_Keep_Latest:      New duplicate objects replace the old ones        *
 *    da_Keep_First:       Either the new or the old is kept depending on    *
 *                         which is FIRST to execute                         *
 *    da_Keep_Last:        Either the new or the old is kept depending on    *
 *                         which is LAST to execute                          *
 *                                                                           *
 ***************************************************************************** }

uses
  System.Contnrs,
  System.SysUtils,
  System.Generics.Collections;
  //TypedObjectList;

type
  tSigPendingActionList = class;
  tSigPendingAction = class;

  tDuplicateAction = ( da_Allow_Duplicates, da_Keep_First, da_Keep_Last, da_Keep_Earliest, da_Keep_Latest );

  tSigPendingActionEvent = procedure( const pObject : tObject; var pNewDelay : integer ) of object;

  tSigPendingAction = class
  private
    fDelay: integer;
    fOwner: tSigPendingActionList;
    fPendingActionEvent: tSigPendingActionEvent;
    fPendingObject: tObject;
    function GetCanDelete: boolean;
  public
    constructor Create( const pOwner : tSigPendingActionList;
                const pDelay : integer; const pObject : tObject;
                const pPendingActionEvent : tSigPendingActionEvent );
    property TimeLeft : integer
             read fDelay
             write fDelay;
    property Owner : tSigPendingActionList
             read fOwner;
    property PendingActionEvent : tSigPendingActionEvent
             read fPendingActionEvent;
    property PendingObject : tObject
             read fPendingObject;

    property CanDelete : boolean
             read GetCanDelete;

    function Execute : boolean; // reduces tick by one and executes function if defined. Returns True if owner is to destroy

    function Matches( const pObject : tObject;
                const pPendingActionEvent : tSigPendingActionEvent ) : boolean;
  end;

  TSigPendingActionList = class( TObjectList<TSigPendingAction> )
  private
    fDuplicateAction: tDuplicateAction;
    fActionExecuting: tSigPendingAction;
    function GetPendingAction(const i: integer): tSigPendingAction;
  public
    constructor Create; reintroduce;
    property PendingAction[ const i : integer ] : tSigPendingAction
             read GetPendingAction;
    property DuplicateAction : tDuplicateAction
             read fDuplicateAction
             default da_Keep_Last;

    procedure GetMatchingAction( const pPendingActionEvent : tSigPendingActionEvent; const pPendingObject : tObject;
              var pPendingAction : tSigPendingAction; var pIndex : integer );

    function Add( const pPendingActionEvent : tSigPendingActionEvent; const pObject : tObject = nil;
                  const pDelay : integer = 0 ) : integer; reintroduce; overload;
    function Add( const pPendingActionEvent : tSigPendingActionEvent; const pDelay : integer ) : integer; reintroduce; overload;
    function ExecuteTick : boolean; // returns TRUE if some events still pending;

    property ActionExecuting : tSigPendingAction
             read fActionExecuting;

  end;

  tSigPendingActionException = class( Exception )

  end;

implementation

{ tSigPendingActionList }


{ tSigPendingActionList }

function tSigPendingActionList.Add(
  const pPendingActionEvent: tSigPendingActionEvent; const pObject: tObject;
  const pDelay: integer): integer;
var
  iMatchingAction : tSigPendingAction;
begin

  Result := -1;
  if fDuplicateAction = da_Allow_Duplicates then
  begin
    iMatchingAction := nil;
  end
  else
  begin
    GetMatchingAction( pPendingActionEvent, pObject, iMatchingAction, Result );
  end;
  if not assigned( iMatchingAction ) then
  begin
    Result := inherited Add( tSigPendingAction.Create( self, pDelay, pObject, pPendingACtionEvent ));
    exit;
  end;
  if iMatchingAction = fActionExecuting then
  begin
    exit; // Recursive action in SigPendingAction ignored - nothing added;
  end;
  // to get here there must be a matching action. Update it accordingly
  case fDuplicateAction of
    da_Allow_Duplicates:
    begin
      exit; // should not get here!
    end;
    da_Keep_First:
    begin
      // first to execute
      if pDelay < iMatchingAction.TimeLeft then
      begin
        iMatchingAction.TimeLeft := pDelay;
      end;
    end;
    da_Keep_Last:
    begin
      // last to execute
      if pDelay > iMatchingAction.TimeLeft then
      begin
        iMatchingAction.TimeLeft := pDelay;
      end;
    end;
    da_Keep_Earliest:
    begin
      exit;
    end;
    da_Keep_Latest:
    begin
      iMatchingAction.TimeLeft := pDelay;
    end;
  end;
end;

function tSigPendingActionList.Add(
  const pPendingActionEvent: tSigPendingActionEvent;
  const pDelay: integer): integer;
begin
  Result := Add( pPendingActionEvent, nil, pDelay );
end;

constructor tSigPendingActionList.Create;
begin
  inherited Create( TRUE );
  fDuplicateAction := da_Keep_Last;
end;

function tSigPendingActionList.ExecuteTick: boolean;
var
  i: Integer;
begin
  if assigned( fActionExecuting ) then // avoid recursion
  begin
    Result := FALSE;
  end
  else
  begin
    for i := 0 to Count - 1 do
    begin
      fActionExecuting := PendingAction[ i ];
      fActionExecuting.Execute;
    end;
    fActionExecuting := nil;
    for i := Count - 1 downto 0 do
    begin
      if PendingAction[ i ].CanDelete then
      begin
        Delete( i );
      end;
    end;
    Pack;
    Result := Count > 0;
  end;
end;

procedure tSigPendingActionList.GetMatchingAction(
  const pPendingActionEvent: tSigPendingActionEvent; const pPendingObject : tObject;
  var pPendingAction: tSigPendingAction; var pIndex: integer);
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    pPendingAction := PendingAction[ i ];
    with pPendingAction do
    begin
      if Matches( pPendingObject, pPendingActionEvent ) then
      begin
        pIndex := i;
        exit;
      end;
    end;
  end;
  // else
  pPendingAction := nil;
  pIndex := -1;
end;

function tSigPendingActionList.GetPendingAction(
  const i: integer): tSigPendingAction;
begin
  Result := Items[ i ] as tSigPendingAction;
end;

{ tSigPendingAction }

constructor tSigPendingAction.Create( const pOwner : tSigPendingActionList;
            const pDelay: integer; const pObject : tObject;
            const pPendingActionEvent : tSigPendingActionEvent );
begin
  inherited Create;

  fOwner := pOwner;
  fDelay := pDelay;
  fPendingActionEvent := pPendingActionEvent;
  fPendingObject := pObject;

end;

function tSigPendingAction.Execute: boolean;
begin
  dec( fDelay );
  if fDelay >= 0 then
  begin
    Result := FALSE;
  end
  else if assigned( fPendingActionEvent ) then
  begin
    fPendingActionEvent( fPendingObject, fDelay );
    Result := (fDelay < 0);
  end
  else
  begin
    Result := TRUE;
  end;
end;

function tSigPendingAction.GetCanDelete: boolean;
begin
  Result := (fDelay < 0);
end;

function tSigPendingAction.Matches(const pObject: tObject;
  const pPendingActionEvent: tSigPendingActionEvent): boolean;
begin
{$LEGACYIFEND OFF}
{$IF CompilerVersion = 28}
  if (fPendingObject = pObject) and (Addr(fPendingActionEvent) = Addr(pPendingActionEvent) ) then
{$ELSE}
  if (fPendingObject = pObject) and (@fPendingActionEvent = @pPendingActionEvent ) then
//{$IFEND}
{$ENDIF}
  begin
    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

end.
