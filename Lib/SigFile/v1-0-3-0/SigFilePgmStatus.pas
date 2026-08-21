unit SigFilePgmStatus;

interface

{
  This is a helper set to store program status, primarily for Undo/Redo purposes.
  There are a number of standard ones, handled via register and unregister.
  The state can be stored in a file too, if required. To do this just set the
  SaveWithFile option to TRUE (default is FALSE) but make sure that the
  tSigFilePgmStatus object is the last one or the state will not
  necessarily restore correctly.
}

uses
  SysUtils,
  Classes,
  ComCtrls,
  SigFile,
  Grids,
  Forms;

type

  tSigPgmStatusHelper =  class( tSigBaseIntegerProperty )
  private
  protected
    function GetControlAsObject: tObject; virtual; abstract;
  public
    procedure Clear; override;

    property ControlAsObject : tObject
             read GetControlAsObject;
  end;

  tPageControlStatusEntry = class( tSigPgmStatusHelper )
  private
    fControl: tPageControl;
    fOnControlChange : tNotifyEvent;
    procedure OnControlChange( Sender : tObject );
  protected
    function GetControlAsObject: tObject; override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty ) ; override;
    procedure SetEditorUpdatePending(const Value: boolean); override;
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tPageControl; pOwner : tSigCompoundProperty );

    property Control : tPageControl
             read fControl;
  end;

  tTabControlStatusEntry = class( tSigPgmStatusHelper )
  private
    fControl: tTabControl;
    fOnControlChange : tNotifyEvent;
    procedure OnControlChange( Sender : tObject );
  protected
    function GetControlAsObject: tObject; override;
    //procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty ) ; override;
    procedure SetEditorUpdatePending(const Value: boolean); override;
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tTabControl; pOwner : tSigCompoundProperty );

    property Control : tTabControl
             read fControl;
  end;

  tGridStatusEntry = class( tSigPgmStatusHelper )
  private
    { Value stored as 'Col, Row'}
    fControl: tDrawGrid;
    fRow, fCol : integer;
    fOnSelectCell : TSelectCellEvent;
    procedure OnSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
  protected
    function GetControlAsObject: tObject; override;
    procedure SetEditorUpdatePending(const Value: boolean); override;
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tDrawGrid; pOwner : tSigCompoundProperty );

    property Control : tDrawGrid
             read fControl;
  end;

  tSigFilePgmStatus = class( tSigCompoundProperty )
  private
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure RegisterObject( pObject : tObject; const IgnoreErrors : boolean = FALSE );
    procedure UnregisterObject( pObject : tObject );
  end;

implementation

{ tSigFilePgmStatus }

constructor tSigFilePgmStatus.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner );
  SaveWithFile := FALSE;

end;

procedure tSigFilePgmStatus.RegisterObject(pObject: tObject; const IgnoreErrors : boolean = FALSE);
var
  i : integer;
begin
  if pObject is tForm then
  begin
    with pObject as tForm do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        RegisterObject( Components[ i ], TRUE );
      end;
    end;
  end
  else if pObject is tPageControl then
  begin
    tPageControlStatusEntry.Create( pObject as tPageControl, self );
  end
  else if pObject is tTabControl then
  begin
    tTabControlStatusEntry.Create( pObject as tTabControl, self );
  end
  {
  else if pObject is tDrawGrid then
  begin
    tGridStatusEntry.Create( pObject as tDrawGrid, self );
  end
  }
  else if not IgnoreErrors then
  begin
    raise exception.Create( 'Unable to register ' + pObject.ClassName );
  end;
end;

procedure tSigFilePgmStatus.UnregisterObject(pObject: tObject);
var
  i: integer;
  iChild : tSigPgmStatusHelper;
begin
  for i := 0 to Count - 1 do
  begin
    iChild := Children.Item[ i ] as tSigPgmStatusHelper;
    if iChild.ControlAsObject = pObject then
    begin
      Children.Remove( iChild );
      exit;
    end;
  end;
end;

{ tPageControlStatusEntry }

constructor tPageControlStatusEntry.Create(pObject: tPageControl;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pObject.Name, pOwner );
  fControl := pObject;
  fOnControlChange := fControl.OnChange;
  fControl.OnChange := OnControlChange;
end;

procedure tPageControlStatusEntry.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty);
begin
  inherited;
  if fControl.ActivePageIndex <> ValueAsInt then
  begin
    if EditorInhibited then
    begin
      EditorUpdatePending := TRUE;
    end
    else
    begin
      fControl.ActivePageIndex := ValueAsInt;
    end;
  end;
end;

function tPageControlStatusEntry.GetControlAsObject: tObject;
begin
  Result := Control;
end;

procedure tPageControlStatusEntry.OnControlChange(Sender: tObject);
begin
  if fControl.ActivePageIndex <> ValueAsInt then
  begin
    ValueAsInt := fControl.ActivePageIndex;
  end;
  if assigned( fOnControlChange ) then
  begin
    fOnControlChange( Sender );
  end;
end;

procedure tPageControlStatusEntry.SetEditorUpdatePending(const Value: boolean);
begin
  if EditorUpdatePending and not Value  then
  begin
    inherited;
    if fControl.ActivePageIndex <> ValueAsInt then
    begin
      fControl.ActivePageIndex := ValueAsInt;
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure tPageControlStatusEntry.SetValue(const pValue: string);
var
  iValue : integer;
begin
  try
    iValue := StrToInt( pValue );
    if fControl.ActivePageIndex <> iValue then
    begin
      fControl.ActivePageIndex := iValue
    end;
  except
  end;
  inherited;
end;

{ tTabControlStatusEntry }

constructor tTabControlStatusEntry.Create(pObject: tTabControl;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pObject.Name, pOwner );
  fControl := pObject;
  fOnControlChange := fControl.OnChange;
  fControl.OnChange := OnControlChange;
end;

(*
procedure tTabControlStatusEntry.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty);
begin
  inherited;
  if fControl.TabIndex <> ValueAsInt then
  begin
    if EditorInhibited then
    begin
      EditorUpdatePending := TRUE;
    end
    else
    begin
      fControl.TabIndex := ValueAsInt;
    end;
  end;
end;
*)

function tTabControlStatusEntry.GetControlAsObject: tObject;
begin
  Result := Control;
end;

procedure tTabControlStatusEntry.OnControlChange(Sender: tObject);
begin
  if fControl.TabIndex <> ValueAsInt then
  begin
    ValueAsInt := fControl.TabIndex;
  end;
  if assigned( fOnControlChange ) then
  begin
    fOnControlChange( Sender );
  end;
end;

procedure tTabControlStatusEntry.SetEditorUpdatePending(const Value: boolean);
begin
  if EditorUpdatePending and not Value  then
  begin
    inherited;
    if fControl.TabIndex <> ValueAsInt then
    begin
      fControl.TabIndex := ValueAsInt;
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure tTabControlStatusEntry.SetValue(const pValue: string);
var
  iValue : integer;
begin
  try
    iValue := StrToInt( pValue );
    if fControl.TabIndex <> iValue then
    begin
      inherited;
      fControl.TabIndex := iValue;
      fControl.OnChange( self );
    end
    else
    begin
      inherited;
    end;
  except
  end;
end;

{ tSigPgmStatusHelper }

{ tGridStatusEntry }

constructor tGridStatusEntry.Create(pObject: tDrawGrid;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pObject.Name, pOwner );
  fControl := pObject;
  fOnSelectCell := fControl.OnSelectCell;
  fControl.OnSelectCell := OnSelectCell;
  fCol := fControl.Selection.Left;
  fRow := fControl.Selection.Top;
  Value := IntToStr( fCol ) + ',' + IntToStr( fRow );

end;

function tGridStatusEntry.GetControlAsObject: tObject;
begin
  Result := Control;
end;

procedure tGridStatusEntry.OnSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  Value := IntToStr( ACol ) + ',' + IntToStr( ARow );
  if assigned( fOnSelectcell ) then
  begin
    fOnSelectCell( Sender, ACol, ARow, CanSelect );
  end;
end;

procedure tGridStatusEntry.SetEditorUpdatePending(const Value: boolean);
var
  iCol, iRow : integer;
  iPos : integer;
  iSelection : TGridRect;
begin
  if EditorUpdatePending and not Value  then
  begin
    inherited;
    iPos := Pos( ',', self.Value );
    if iPos = 0 then
    begin
      iCol := 0;
      iRow := 0;
    end
    else
    begin
      iCol := StrToIntDef( Copy( self.Value, 1, iPos - 1 ), 0 );
      iRow := StrToIntDef( Copy( self.Value, iPos + 1, 255), 0 );
    end;
    if (iCol <> fCol) or (iRow <> fRow) then
    begin
      fRow := iRow;
      fCol := iCol;
      with iSelection do
      begin
        Top := fRow;
        Bottom := fRow;
        Left := fCol;
        Right := fCol;
      end;
      fControl.Selection := iSelection;
      fControl.Invalidate
    end;
  end
  else
  begin
    inherited;
  end;

end;

procedure tGridStatusEntry.SetValue(const pValue: string);
var
  iRow, iCol : integer;
  iPos : integer;
  iSelection : TGridRect;
begin
  try
    inherited;
    iPos := Pos( ',', Value );
    if iPos = 0 then
    begin
      iCol := 0;
      iRow := 0;
    end
    else
    begin
      iCol := StrToIntDef( Copy( Value, 1, iPos - 1 ), 0 );
      iRow := StrToIntDef( Copy( Value, iPos + 1, 255), 0 );
    end;
    if (iCol <> fCol) or (iRow <> fRow) then
    begin
      fRow := iRow;
      fCol := iCol;
      with iSelection do
      begin
        Top := fRow;
        Bottom := fRow;
        Left := fCol;
        Right := fCol;
      end;
      fControl.Invalidate
    end;

  except
  end;

end;

{ tSigPgmStatusHelper }

procedure tSigPgmStatusHelper.Clear;
begin
  //inherited;  No clear action for these!

end;

end.
