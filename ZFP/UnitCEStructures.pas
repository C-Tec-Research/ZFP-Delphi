unit UnitCEStructures;

interface

{
  These are structures built from C&E structures to mimic the files sent to the panel
}

uses
  Contnrs,
  SysUtils,
  Classes;

type
  tOPSequence = class
  private
    fModalSequence : array[ 0..3 ] of integer;
    fDefaultSeq: integer;
    fCurrMode: integer;
    fCurrModeSeq: integer;
    fOPGroup: integer;
    procedure SetDefaultSeq(const Value: integer);
    function GetModalSeq(const pMode: integer): integer;
    procedure SetModalSeq(const pMode, Value: integer);
    procedure SetCurrModeSeq(const Value: integer);
  public
    constructor Create;
    property DefaultSeq : integer
             read fDefaultSeq
             write SetDefaultSeq;
    property OPGroup : integer
             read fOPGroup
             write fOPGroup;
    property ModalSeq[ const pMode : integer ] : integer
             read GetModalSeq
             write SetModalSeq;
    property CurrMode : integer
             read fCurrMode
             write fCurrMode;
    property CurrModeSeq : integer
             read fCurrModeSeq
             write SetCurrModeSeq;
    function Text : string;
  end;

  tOPSequences = class( tObjectList )
  private
    fCurrModeSeq: integer;
    fCurrSeq: tOPSequence;
    fCurrMode: integer;
    fOPGroup: integer;
    function GetOPSequence(const i: integer): tOPSequence;
    procedure SetCurrModeSeq(const Value: integer);
    procedure SetCurrSeq(const Value: tOPSequence);
    procedure SetCurrMode(const Value: integer);
    procedure SetOPGroup(const Value: integer);
    procedure AddOPSequence;
  public
    constructor Create; reintroduce;
    property OPSequence[ const i : integer ] : tOPSequence
             read GetOPSequence;
    property CurrMode : integer
             read fCurrMode
             write SetCurrMode;
    property CurrModeSeq : integer
             read fCurrModeSeq
             write SetCurrModeSeq;
    property CurrSeq : tOPSequence
             read fCurrSeq
             write SetCurrSeq;
    property OPGroup : integer
             read fOPGroup
             write SetOPGroup;
  end;

  tCELine = class
  private
    fIPGroup: integer;
    fOPSequences: tOPSequences;
    fCurrMode: integer;
    fCurrModeSeq: integer;
    fIPInputGroupState: integer;
    fOPGroup: integer;
    procedure SetCurrMode(const Value: integer);
    procedure SetCurrModeSeq(const Value: integer);
    procedure SetOPGroup(const Value: integer);
    procedure SetIPGroup(const Value: integer);
  protected
  public
    constructor Create;
    destructor Destroy; override;

    property IPGroup : integer
             read fIPGroup
             write SetIPGroup;
    property IPGroupState : integer
             read fIPInputGroupState
             write fIPInputGroupState;
    property OPSequences : tOPSequences
             read fOPSequences;
    property CurrMode : integer
             read fCurrMode
             write SetCurrMode;
    property CurrModeSeq : integer
             read fCurrModeSeq
             write SetCurrModeSeq;
    property OPGroup : integer
             read fOPGroup
             write SetOPGroup;

    procedure AddCELine( pList : tStrings );
  end;

  TCELines = class( tObjectList )
  private
    fCurrInputGroup: integer;
    fCurrCELine: tCELine;
    fCurrMode: integer;
    fIPInputGroupState: integer;
    fOPGroup: integer;
    fCurrModeSeq: integer;
    function GetCELine(const i: integer): tCELine;
    procedure SetCurrInputGroup(const Value: integer);
    procedure SetCurrMode(const Value: integer);
    procedure SetCurrCELine(const Value: tCELine);
    procedure SetIPInputGroupState(const Value: integer);
    procedure SetOPGroup(const Value: integer);
    procedure SetCurrModeSeq(const Value: integer);
    property CurrCELine : tCELine
             read fCurrCELine
             write SetCurrCELine;
  public
    constructor Create; reintroduce;
    procedure AddCELines( pList : tStrings );
    procedure AddNewLine;

    property CurrentCELine : tCELine
             read fCurrCELine;
    property CELine[ const i : integer ] : tCELine
             read GetCELine;
    property CurrInputGroup : integer
             read fCurrInputGroup
             write SetCurrInputGroup;
    property CurrMode : integer
             read fCurrMode
             write SetCurrMode;
    property IPGroupState : integer
             read fIPInputGroupState
             write SetIPInputGroupState;
    property OPGroup : integer
             read fOPGroup
             write SetOPGroup;
    property CurrModeSeq : integer
             read fCurrModeSeq
             write SetCurrModeSeq;
  end;

implementation

{ tCELine }

procedure tCELine.AddCELine(pList: tStrings);
var
  iLine : string;
  i : integer;
begin
  iLine := '30,' + IntToStr( IPGroup ) + ',' + IntToStr( IPGroupState );
  with OPSequences do
  begin
    for i := 0 to Count - 1 do
    begin
      iLine := iLine + OPSequence[ i ].Text;
    end;
  end;
  pList.Add( iLine );
end;

constructor tCELine.Create;
begin
  inherited;

  fIPGroup := -1;
  fOPSequences := tOPSequences.Create;
  fIPInputGroupState := -1;
  fCurrMode := -1;
  fCurrModeSeq := -1;
  fOPGroup := -1;
end;

destructor tCELine.Destroy;
begin
  fOPSequences.Free;

  inherited;
end;

procedure tCELine.SetCurrMode(const Value: integer);
begin
  if fCurrMode <> Value then
  begin
    fCurrMode := Value;
    fOPSequences.CurrMode := Value;
  end;
end;

procedure tCELine.SetCurrModeSeq(const Value: integer);
begin
  if fCurrModeSeq <> Value then
  begin
    fCurrModeSeq := Value;
    fOPSequences.CurrModeSeq := Value;
  end;
end;

procedure tCELine.SetIPGroup(const Value: integer);
begin
  fIPGroup := Value;
end;

procedure tCELine.SetOPGroup(const Value: integer);
begin
  if fOPGroup <> Value then
  begin
    fOPGroup := Value;
    fOPSequences.OPGroup := Value;
  end;
end;

{ tOPSequence }

constructor tOPSequence.Create;
var
  i: Integer;
begin
  inherited Create;
  fDefaultSeq := -1;
  for i := 0 to 3 do
  begin
    fModalSequence[ i ] := -1; // -1 = use default
  end;
  fCurrMode := -1; // default seq
  fCurrModeSeq := -1;
  fOPGroup := -1;
end;

function tOPSequence.GetModalSeq(const pMode: integer): integer;
begin
  Result := fModalSequence[ pMode ];
  if Result = -1 then
  begin
    Result := DefaultSeq;
  end;
end;

procedure tOPSequence.SetCurrModeSeq(const Value: integer);
begin
  fCurrModeSeq := Value;
  if fCurrMode = -1 then
  begin
    DefaultSeq := Value;
  end
  else
  begin
    ModalSeq[ fCurrMode ] := Value;
  end;
end;

procedure tOPSequence.SetDefaultSeq(const Value: integer);
begin
  fDefaultSeq := Value;
end;

procedure tOPSequence.SetModalSeq(const pMode, Value: integer);
begin
  fModalSequence[ pMode ] := Value;
end;

function tOPSequence.Text: string;
var
  i: Integer;
  iSeq : integer;
begin
  Result := ',' + IntToStr( fOPGroup );
  for i := 0 to 3 do
  begin
    iSeq := ModalSeq[ i ];
    if iSeq = -1 then
    begin
      iSeq := fDefaultSeq;
    end;
    if iSeq = -1 then
    begin
      Result := Result + ',-';
    end
    else
    begin
      Result := Result + ',' + IntToStr( iSeq );
    end;
  end;
end;

{ tOPSequences }

procedure tOPSequences.AddOPSequence;
var
  i : integer;
begin
  if assigned( fCurrSeq ) then
  begin
    if fCurrSeq.CurrModeSeq <> self.CurrModeSeq then
    begin
      fCurrSeq := nil;
    end
    else if fCurrSeq.OPGroup <> self.OPGroup then
    begin
      fCurrSeq := nil;
    end;
  end;
  if CurrModeSeq = -1 then
  begin
    exit;
  end;
  if OPGroup = -1 then
  begin
    exit;
  end;
  if not assigned( fCurrSeq ) then
  begin
    for i := 0 to Count-1 do
    begin
      with OPSequence[ i ] do
      begin
        if CurrModeSeq <> self.CurrModeSeq then
        begin
          continue;
        end;
        if OPGroup <> self.OPGroup then
        begin
          continue;
        end;
      end;
      // found
      fCurrSeq := OPSequence[ i ];
    end;
  end;
  // else
  if not assigned( fCurrSeq ) then
  begin
    fCurrSeq := tOPSequence.Create;
    Add( fCurrSeq );
  end;
  fCurrSeq.CurrMode := self.CurrMode;
  fCurrSeq.CurrModeSeq := self.CurrModeSeq;
  fCurrSeq.OPGroup := self.OPGroup;
end;

constructor tOPSequences.Create;
begin
  inherited Create( TRUE );

  fCurrMode := -1;
  fCurrModeSeq := -1;
  fOPGroup := -1;
end;

function tOPSequences.GetOPSequence(const i: integer): tOPSequence;
begin
  Result := Items[ i ] as tOPSequence;
end;

procedure tOPSequences.SetCurrMode(const Value: integer);
begin
  if fCurrMode <> Value then
  begin
    fCurrMode := Value;
    AddOPSequence;
  end;
end;

procedure tOPSequences.SetCurrModeSeq(const Value: integer);
begin
  if fCurrModeSeq <> Value then
  begin
    fCurrModeSeq := Value;
    AddOPSequence;
  end;
end;

procedure tOPSequences.SetCurrSeq(const Value: tOPSequence);
begin
  fCurrSeq := Value;
  if assigned( Value ) then
  begin
    Value.CurrMode := self.CurrMode;
    Value.CurrModeSeq := self.CurrModeSeq;
  end;
end;

procedure tOPSequences.SetOPGroup(const Value: integer);
begin
  if fOPGroup <> Value then
  begin
    fOPGroup := Value;
    AddOPSequence;
  end;
end;

{ tCELines }

procedure tCELines.AddCELines(pList: tStrings);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    CELine[ i ].AddCELine( pList );
  end;
end;

procedure tCELines.AddNewLine;
var
  i : integer;
begin
  if assigned( fCurrCELine) then
  begin
    if fCurrCELine.IPGroup <> fCurrInputGroup then
    begin
      fCurrCELine := nil;
    end
    else if fCurrCELine.IPGroupState <> fIPInputGroupState then
    begin
      fCurrCELine := nil;
    end;
  end;
  if fCurrInputGroup = -1 then
  begin
    exit;
  end;
  if fIPInputGroupState = -1 then
  begin
    exit;
  end;
  if not assigned( fCurrCELine ) then
  begin
    for i := 0 to Count - 1 do
    begin
      with CELine[ i ] do
      begin
        if IPGroup <> self.fCurrInputGroup then
        begin
          continue;
        end;
        if IPGroupState <> self.fIPInputGroupState then
        begin
          continue;
        end;
      end;
      fCurrCELine := CELine[ i ];
    end;
    if not assigned( fCurrCELine ) then
    begin
      fCurrCELine := tCELine.Create;
      Add( fCurrCELine );
    end;
  end;
  fCurrCELine.IPGroup := fCurrInputGroup;
  fCurrCELine.IPGroupState := fIPInputGroupState;
  fCurrCELine.OPGroup := fOPGroup;
  fCurrCELine.CurrMode := fCurrMode;
  fCurrCELine.CurrModeSeq := fCurrModeSeq;
end;

constructor tCELines.Create;
begin
  inherited Create( TRUE );

  fCurrInputGroup := -1;
  fCurrMode := -1;
  fIPInputGroupState := -1;
  fOPGroup := -1;
  fCurrModeSeq := -1;

end;

function tCELines.GetCELine(const i: integer): tCELine;
begin
  Result := Items[ i ] as tCELine;
end;

procedure tCELines.SetCurrCELine(const Value: tCELine);
begin
  fCurrCELine := Value;
  if assigned( Value ) then
  begin
    Value.CurrMode := self.CurrMode;
    Value.IPGroupState := self.IPGroupState;
    Value.CurrModeSeq := self.CurrModeSeq;
  end;
end;

procedure tCELines.SetCurrInputGroup(const Value: integer);
begin
  if fCurrInputGroup <> Value then
  begin
    fCurrInputGroup := Value;
    AddNewLine;
  end;
end;

procedure tCELines.SetCurrMode(const Value: integer);
begin
  fCurrMode := Value;
  if assigned( CurrCELine ) then
  begin
    CurrCELine.CurrMode := Value;
  end;
end;

procedure tCELines.SetCurrModeSeq(const Value: integer);
begin
  if fCurrModeSeq <> Value then
  begin
    fCurrModeSeq := Value;
    AddNewLine;
  end;
end;

procedure tCELines.SetIPInputGroupState(const Value: integer);
begin
  if fIPInputGroupState <> Value then
  begin
    fIPInputGroupState := Value;
    AddNewLine;
  end;
end;

procedure tCELines.SetOPGroup(const Value: integer);
begin
  if fOPGroup <> Value then
  begin
    fOPGroup := Value;
    AddNewLine;
  end;
end;

end.
