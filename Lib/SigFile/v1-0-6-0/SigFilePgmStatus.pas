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
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    procedure Clear; override;

    property ControlAsObject : tObject
             read GetControlAsObject;

    procedure CheckStatus; virtual; abstract;

  end;

  tPageControlStatusEntry = class( tSigPgmStatusHelper )
  private
    fControl: tPageControl;
    fOnControlChange : tNotifyEvent;
    procedure OnControlChange( Sender : tObject );
  protected
    function GetControlAsObject: tObject; override;
    procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty ) ; override;
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tPageControl; pOwner : tSigCompoundProperty );

    property Control : tPageControl
             read fControl;

    procedure CheckStatus; override;
  end;

  tTabControlStatusEntry = class( tSigPgmStatusHelper )
  private
    fControl: tTabControl;
    fOnControlChange : tNotifyEvent;
    procedure OnControlChange( Sender : tObject );
  protected
    function GetControlAsObject: tObject; override;
    //procedure ExecuteOnChange(const pChangedObject : tSigBaseProperty ) ; override;
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tTabControl; pOwner : tSigCompoundProperty );

    property Control : tTabControl
             read fControl;

    procedure CheckStatus; override;
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
    procedure SetValue(const pValue: string); override;
  public
    constructor Create( pObject : tDrawGrid; pOwner : tSigCompoundProperty );

    property Control : tDrawGrid
             read fControl;

    procedure CheckStatus; override;
  end;

  tSigFilePgmStatus = class( tSigCompoundProperty )
  private
    function GetSigPgmStatusHelper(const i: integer): tSigPgmStatusHelper;
  protected
    procedure RefreshEditor; override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure RegisterObject( pObject : tObject; const IgnoreErrors : boolean = FALSE );
    procedure UnregisterObject( pObject : tObject );
    procedure CheckStatus;

    property SigPgmStatusHelper[ const i : integer ] : tSigPgmStatusHelper
             read GetSigPgmStatusHelper;
  end;

implementation

{ tSigFilePgmStatus }

procedure tSigFilePgmStatus.CheckStatus;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    SigPgmStatusHelper[ i ].CheckStatus;
  end;
end;

constructor tSigFilePgmStatus.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner );
  SaveWithFile := FALSE;

end;

function tSigFilePgmStatus.GetSigPgmStatusHelper(
  const i: integer): tSigPgmStatusHelper;
begin
  Result := Entry[ i ] as tSigPgmStatusHelper;
end;

procedure tSigFilePgmStatus.RefreshEditor;
begin
  inherited;

end;

procedure tSigFilePgmStatus.RegisterObject(pObject: tObject; const IgnoreErrors : boolean = FALSE);
var
  i : integer;
  iName : string;
  iDealtWith : boolean;
begin
  iName := pObject.ClassName;
  iDealtWith := FALSE;
  if pObject is tComponent then
  begin
    iDealtWith := TRUE;
    with pObject as tComponent do
    begin
      iName := Name;
      for i := 0 to ComponentCount - 1 do
      begin
        RegisterObject( Components[ i ], TRUE );
      end;
    end;
  end;
  if pObject is tForm then
  begin
    // already dealt with above a
  end
  else if pObject is tPageControl then
  begin
    tPageControlStatusEntry.Create( pObject as tPageControl, self );
  end
  else if pObject is tTabControl then
  begin
    tTabControlStatusEntry.Create( pObject as tTabControl, self );
  end
  else if (not IgnoreErrors) and (not iDealtWith) then
  begin
    raise exception.Create( 'Unable to register ' + iName );
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

procedure tPageControlStatusEntry.CheckStatus;
begin
  OnControlChange( self );
end;

constructor tPageControlStatusEntry.Create(pObject: tPageControl;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pObject.Name, pOwner );
  fControl := pObject;
  fOnControlChange := fControl.OnChange;
  fControl.OnChange := OnControlChange;
  if assigned( fControl ) then
  begin
    ValueAsInt := fControl.ActivePageIndex;
  end;
end;

procedure tPageControlStatusEntry.ExecuteOnChange(
  const pChangedObject: tSigBaseProperty);
begin
  inherited;
  if fControl.ActivePageIndex <> ValueAsInt then
  begin
    fControl.ActivePageIndex := ValueAsInt;
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

procedure tTabControlStatusEntry.CheckStatus;
begin
  OnControlChange( self );
end;

constructor tTabControlStatusEntry.Create(pObject: tTabControl;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pObject.Name, pOwner );
  fControl := pObject;
  fOnControlChange := fControl.OnChange;
  fControl.OnChange := OnControlChange;
end;

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

procedure tGridStatusEntry.CheckStatus;
begin
  // nothing at the moment
end;

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

{$IFDEF ALLOW_DELAYED_UPDATE}
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
{$ENDIF}

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

constructor tSigPgmStatusHelper.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  SaveWithFile := FALSE;
end;

end.
