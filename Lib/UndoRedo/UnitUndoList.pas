unit UnitUndoList;

interface

uses
  Contnrs,
  ComCtrls,
  SigFile,
  System.SysUtils;

type
  tOnUndoRedoChange = procedure ( Newval : boolean ) of object;

type
  tUndoRedoRec = class
  private
    fTag: integer;
    fUndoAction: tSigFileUndoAction;
    fUndoObject: tSigBaseProperty;
    fUndoString: string;
  public
    property Tag : integer
             read fTag
             write fTag;
    property UndoObject : tSigBaseProperty
             read fUndoObject
             write fUndoObject;
    property UndoAction : tSigFileUndoAction
             read fUndoAction
             write fUndoAction;
    property UndoString : string
             read fUndoString
             write fUndoString;
  end;

  tUndoRedoStack = class( TObjectStack )
  private
  public
    destructor Destroy; override;
    procedure Push( NewVal :  tUndoRedoRec ); reintroduce;
    function Pop : tUndoRedoRec; reintroduce;
    function Peek : tUndoRedoRec; reintroduce;
    procedure Clear;
  end;

  tUndoCount = class
  private
    fCount: integer;
  public
    property Count : integer
             read fCount
             write fCount;
  end;

  tUndoCountStack = class( TObjectStack )
    // this allows undo actions to be grouped in sets
  private
  public
    destructor Destroy; override;
    procedure Push( NewVal :  tUndoCount ); reintroduce;
    function Pop : tUndoCount; reintroduce;
    function Peek : tUndoCount; reintroduce;
    procedure Clear;
  end;

  tUndoRedo = class
  private
    fUndoStack: tUndoRedoStack;
    fRedoStack: tUndoRedoStack;
    FOnUndoChange: tOnUndoRedoChange;
    FOnRedoChange: tOnUndoRedoChange;
    fAccumulatesimilarActions: boolean;
    fForceSimilarActionBreak: boolean;
    fGroupUndoActive: integer;
    fGroupUndoLevel : integer;
    fUndoCountStack: tUndoCountStack;
    fRedoCountStack: tUndoCountStack;
    fGroupRedoActive: boolean;
    fUndoActive : integer;
    fRedoActive : integer;
    fRedoableTag : integer;
    fTag: integer;
    fOwner : tSigFileProperty;
    procedure SetOnUndoChange(const Value: tOnUndoRedoChange);
    procedure SetOnRedoChange(const Value: tOnUndoRedoChange);
    procedure SetGroupUndoActive(const Value: boolean);
    procedure SetGroupRedoActive(const Value: boolean);
    function GetGroupUndoActive: boolean;
    function GetGroupRedoActive: boolean;
    function GetRedoActive: boolean;
    function GetUndoActive: boolean;
    procedure SetRedoActive(const Value: boolean);
    procedure SetUndoActive(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;

    property Owner : tSigFileProperty
             read fOwner
             write fOwner;
    property UndoStack : tUndoRedoStack
             read fUndoStack;
    property RedoStack : tUndoRedoStack
             read fRedoStack;
    function CanUndo : boolean;
    function CanRedo : boolean;
    property OnUndoChange : tOnUndoRedoChange
             read FOnUndoChange
             write SetOnUndoChange;
    property OnRedoChange : tOnUndoRedoChange
             read FOnRedoChange
             write SetOnRedoChange;
    procedure UndoableAction( const pTag : integer; const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure RedoableAction( const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure PrepareUndoableActionTag( const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure UndoableActionTag( const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure CompleteUndoableActionTag( const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    procedure RedoableActionTag( const pUndoObject : tSigBaseProperty;
                              const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    //procedure RedoableAction( const pTag : integer; const pUndoObject : tSigBaseProperty;
    //                          const pUndoAction : tSigFileUndoAction; const pUndoString : string );
    function Undo : integer; // performs the undo action and returns the active tag at the time
    function Redo : integer; // performs the undo action and returns the active tag at the time
    procedure Clear;
    property AccumulateSimilarActions : boolean
             read fAccumulatesimilarActions
             write fAccumulateSimilarActions;
    property ForceSimilarActionBreak : boolean
             read fForceSimilarActionBreak
             write fForceSimilarActionBreak;
    property GroupUndoActive : boolean
             read GetGroupUndoActive
             write SetGroupUndoActive;
    property GroupRedoActive : boolean
             read GetGroupRedoActive
             write SetGroupRedoActive;
    property UndoActive : boolean
             read GetUndoActive
             write SetUndoActive;
    property RedoActive : boolean
             read GetRedoActive
             write SetRedoActive;
    property UndoCountStack : tUndoCountStack
             read fUndoCountStack;
    property RedoCountStack : tUndoCountStack
             read fRedoCountStack;
    property Tag : integer
             read fTag
             write fTag;
  end;

implementation

{ tUndoRedo }

function tUndoRedo.CanRedo: boolean;
begin
  Result := fRedoStack.Count <> 0;
end;

function tUndoRedo.CanUndo: boolean;
begin
  Result := fUndoStack.Count <> 0;
end;

procedure tUndoRedo.Clear;
begin
  UndoStack.Clear;
  if assigned( OnUndoChange ) then
  begin
    OnUndoChange( FALSE );
  end;
  RedoStack.Clear;
  if assigned( OnRedoChange ) then
  begin
    OnRedoChange( FALSE );
  end;
end;

procedure tUndoRedo.CompleteUndoableActionTag(
  const pUndoObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if fGroupUndoLevel > 0 then
  begin
    dec( fGroupUndoLevel );
  end
  else
  begin
    GroupUndoActive := FALSE;
  end;
end;

constructor tUndoRedo.Create;
begin
  inherited Create;
  fUndoStack := tUndoRedoStack.Create;
  fRedoStack := tUndoRedoStack.Create;
  fUndoCountStack := tUndoCountStack.Create;
  fRedoCountStack := tUndoCountStack.Create;
end;

destructor tUndoRedo.Destroy;
begin
  fUndoStack.Free;
  fRedoStack.Free;
  fUndoCountStack.Free;
  fRedoCountStack.Free;
  inherited;
end;

function tUndoRedo.GetGroupRedoActive: boolean;
begin
  Result := fGroupRedoActive;
end;

function tUndoRedo.GetGroupUndoActive: boolean;
begin
  Result := fGroupUndoActive > 0;
end;

function tUndoRedo.GetRedoActive: boolean;
begin
  Result := fRedoActive > 0;
end;

function tUndoRedo.GetUndoActive: boolean;
begin
  Result := fUndoActive > 0;
end;

procedure tUndoRedo.PrepareUndoableActionTag(
  const pUndoObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
begin
  if GroupUndoActive then
  begin
    inc( fGroupUndoLevel );
  end
  else
  begin
    GroupUndoActive := TRUE;
    fGroupUndoLevel := 0;
  end;
end;

function tUndoRedo.Redo: integer;
var
  iUndoRedoRec : tUndoRedoRec;
  iRedoCount : tUndoCount;
  i : integer;
  iFirstObject, iLastObject : tSigBaseProperty;
begin
  Result := -1;
  if CanRedo then
  begin
    iFirstObject := nil;
    RedoActive := TRUE;
    try
      iRedoCount := RedoCountStack.Pop;
      while iRedoCount.Count = 0 do
      begin
        // remove any false positives! (but there shouldn't be any on REDO!
        iRedoCount := RedoCountStack.Pop;
      end;
      GroupUndoActive := iRedoCount.Count > 1;
      for i := 1 to iRedoCount.Count do
      begin
        iUndoRedoRec := RedoStack.Pop;
        if RedoStack.Count = 0 then
        begin
          if assigned( OnRedoChange ) then
          begin
            OnRedoChange( FALSE );
          end;
        end;
        Result := iUndoRedoRec.Tag;
        iLastObject := iUndoRedoRec.UndoObject;
        if not assigned( iFirstObject ) then
        begin
          iFirstObject := iLastObject;
        end;
        iLastObject.Redo( iUndoRedoRec.UndoAction, iUndoRedoRec.UndoString );
        iUndoRedoRec.Free;
      end;
    finally
      RedoActive := FALSE;
      if assigned( iFirstObject ) then
      begin
        iFirstObject.OnCompleteRedo;
      end;
    end;
  end;
end;

procedure tUndoRedo.RedoableAction( const pUndoObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  iUndoRedoRec : tUndoRedoRec;
  iRedoCount : tUndoCount;
begin
  iUndoRedoRec := tUndoRedoRec.Create;
  iUndoRedoRec.Tag := fRedoableTag;
  iUndoRedoRec.UndoObject := pUndoObject;
  iUndoRedoRec.UndoString := pUndoString;
  iUndoRedoRec.UndoAction := pUndoAction;
  if RedoStack.Count = 0 then
  begin
    if assigned( OnRedoChange ) then
    begin
      OnRedoChange( TRUE );
    end;
  end;
  RedoStack.Push( iUndoRedoRec );

  if GroupRedoActive then
  begin
    iRedoCount := RedoCountStack.Peek;
    iRedoCount.Count := iRedoCount.Count + 1;
  end
  else
  begin
    iRedoCount := tUndoCount.Create;
    iRedoCount.Count := 1;
    RedoCountStack.Push( iRedoCount );
  end;

end;

procedure tUndoRedo.RedoableActionTag(const pUndoObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  RedoableAction( pUndoObject, pUndoAction, pUndoString );
end;

procedure tUndoRedo.SetGroupRedoActive(const Value: boolean);
var
  iRedoCount : tUndoCount;
begin
  if Value and not GroupRedoActive then
  begin
    iRedoCount := tUndoCount.Create;
    fRedoCountStack.Push( iRedoCount );
  end;
  fGroupRedoActive := Value;
end;

procedure tUndoRedo.SetGroupUndoActive(const Value: boolean);
var
  iUndoCount : tUndoCount;
begin
  if Value and not GroupUndoActive then
  begin
    iUndoCount := tUndoCount.Create;
    fUndoCountStack.Push( iUndoCount );
  end;
  if Value then
  begin
    inc( fGroupUndoActive );
  end
  else if GroupUndoActive then
  begin
    dec( fGroupUndoActive );
  end;
end;

procedure tUndoRedo.SetOnRedoChange(const Value: tOnUndoRedoChange);
begin
  FOnRedoChange := Value;
  FOnRedoChange( CanRedo );
end;

procedure tUndoRedo.SetOnUndoChange(const Value: tOnUndoRedoChange);
begin
  FOnUndoChange := Value;
  fOnUndoChange( CanUndo );
end;

procedure tUndoRedo.SetRedoActive(const Value: boolean);
begin
  if Value then
  begin
    if not RedoActive then
    begin
      if assigned( fOwner ) then
      begin
        fOwner.AmRedoing := TRUE;
      end;
    end;
    inc( fRedoActive );
  end
  else if RedoActive then
  begin
    if fRedoACtive = 1 then
    begin
      {
        This slightly ugly construct is necessary because typically the
        owner completes any pending actions (usually involving ActiveChild
        which can change many times during a block undo) which, if UndoActive is
        false will kill the block undo group, making the next undo action incomplete
      }
      if assigned( fOwner ) then
      begin
        fOwner.AmRedoing := FALSE;
      end;
    end;
    dec( fRedoActive );
  end;
end;

procedure tUndoRedo.SetUndoActive(const Value: boolean);
begin
  if Value then
  begin
    if not UndoActive then
    begin
      fOwner.AmUndoing := TRUE;
    end;
    inc( fUndoActive );
  end
  else if UndoActive then
  begin
    if fUndoActive = 1 then
    begin
      {
        This slightly ugly construct is necessary because typically the
        owner completes any pending actions (usually involving ActiveChild
        which can change many times during a block undo) which, if UndoActive is
        false will kill the redo stack
      }
      fOwner.AmUndoing := FALSE;
    end;
    dec( fUndoActive );
  end;
end;

function tUndoRedo.Undo: integer;
var
  iUndoRedoRec : tUndoRedoRec;
  iUndoCount : tUndoCount;
  i : integer;
  iLastObject : tSigBaseProperty;
begin
  UndoActive := TRUE;
  try
    Result := -1;
    if CanUndo then
    begin
      iLastObject := nil;
      iUndoCount := UndoCountStack.Pop;
      while iUndoCount.Count = 0 do
      begin
        // remove any false positives!
        iUndoCount := UndoCountStack.Pop;
      end;
      GroupRedoActive := iUndoCount.Count > 1;
      for i := 1 to iUndoCount.Count do
      begin
        iUndoRedoRec := UndoStack.Pop;
        if UndoStack.Count = 0 then
        begin
          if assigned( OnUndoChange ) then
          begin
            OnUndoChange( FALSE );
          end;
        end;
        fRedoableTag := iUndoRedoRec.Tag;
        Result := fRedoableTag;
        iLastObject := iUndoRedoRec.UndoObject;
        iLastObject.Undo( iUndoRedoRec.UndoAction, iUndoRedoRec.UndoString );
        iUndoRedoRec.Free;
      end;
      if assigned( iLastObject ) then
      begin
        iLastObject.OnCompleteUndo;
      end;
    end;
  finally
    UndoActive := FALSE;
  end;
end;

procedure tUndoRedo.UndoableAction(const pTag: integer;
  const pUndoObject: tSigBaseProperty; const pUndoAction: tSigFileUndoAction;
  const pUndoString: string);
var
  iUndoRedoRec : tUndoRedoRec;
  iUndoCount : tUndoCount;
begin
  if UndoActive then
  begin
    // cannot create an undoable action when undoing - should be a redoable action
    raise Exception.Create('Internal Error when undoing');
  end;
  if not RedoActive then
  begin
    // new undoable action. Clear the Redo list
    fRedoStack.Clear;
    fRedoCountStack.Clear;
    if assigned( OnRedoChange ) then
    begin
      OnRedoChange( FALSE );
    end;
    GroupRedoActive := FALSE;
  end;
  if fAccumulatesimilarActions then
  begin
    if ForceSimilarActionBreak then
    begin
      ForceSimilarActionBreak := FALSE;
    end
    else
    begin
      iUndoRedoRec := UndoStack.Peek;
      // same object and action?
      if (iUndoRedoRec.Tag = pTag) and (iUndoRedoRec.UndoObject = pUndoObject) and (iUndoRedoRec.UndoAction = pUndoAction) then
      begin
        exit;
      end;
    end;
  end;
  iUndoRedoRec := tUndoRedoRec.Create;
  iUndoRedoRec.Tag := pTag;
  iUndoRedoRec.UndoObject := pUndoObject;
  iUndoRedoRec.UndoString := pUndoString;
  iUndoRedoRec.UndoAction := pUndoAction;

  if UndoStack.Count = 0 then
  begin
    if assigned( OnUndoChange ) then
    begin
      OnUndoChange( TRUE );
    end;
  end;
  UndoStack.Push( iUndoRedoRec );

  if GroupUndoActive then
  begin
    iUndoCount := UndoCountStack.Peek;
    iUndoCount.Count := iUndoCount.Count + 1;
  end
  else
  begin
    iUndoCount := tUndoCount.Create;
    iUndoCount.Count := 1;
    UndoCountStack.Push( iUndoCount );
  end;
end;

procedure tUndoRedo.UndoableActionTag(const pUndoObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  UndoableAction( fTag, pUndoObject, pUndoAction, pUndoString );
end;

{ tUndoRedoStack }

procedure tUndoRedoStack.Clear;
var
  iUndoRedoRec : tUndoRedoRec;
begin
  while Count > 0 do
  begin
    iUndoRedoRec := Pop;
    iUndoRedoRec.Free;
  end;
end;

destructor tUndoRedoStack.Destroy;
begin
  Clear;
  inherited;
end;

function tUndoRedoStack.Peek: tUndoRedoRec;
begin
  Result := (inherited Peek) as tUndoRedoRec;
end;

function tUndoRedoStack.Pop: tUndoRedoRec;
begin
  Result := (inherited Pop) as tUndoRedoRec;
end;

procedure tUndoRedoStack.Push(NewVal: tUndoRedoRec);
begin
  inherited Push( NewVal );
end;

{ tUndoCountStack }

procedure tUndoCountStack.Clear;
var
  iValue : tUndoCount;
begin
  while Count > 0 do
  begin
    iValue := Pop;
    iValue.Free;
  end;
end;

destructor tUndoCountStack.Destroy;
begin
  Clear;
  inherited;
end;

function tUndoCountStack.Peek: tUndoCount;
begin
  Result := inherited Peek as tUndoCount;
end;

function tUndoCountStack.Pop: tUndoCount;
begin
  Result := inherited Pop as tUndoCount;
end;

procedure tUndoCountStack.Push(NewVal: tUndoCount);
begin
  inherited Push( NewVal );
end;

end.
