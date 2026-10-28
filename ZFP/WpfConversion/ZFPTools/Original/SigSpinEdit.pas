unit SigSpinEdit;

{ Spin edit that is restricted to values within range }

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  VCL.Samples.Spin;


type
  ExceptionSpecialValuesList = class( Exception )

  end;

type
  tSpecialValuesList = class( tStringList )
  private
  public
    function ValueToInt( const pString : string ) : integer;
    function IntToValue( const pVal : integer ) : string;
    procedure CheckValid;
    function IsValid( const pString : string ) : boolean; overload;
    function IsValid( const pVal : integer ) : boolean; overload;
  end;

type
  TSigSpinEdit = class(TSpinEdit)
  private
    fNormalFont: tFont;
    fErrorFont: tFont;
    fSpecialValues: tSpecialValuesList;
    { Private declarations }
    function GetIsValid : boolean;
    procedure SetReadOnly( NewVal : boolean );
    procedure SetNormalFont(const Value: tFont);
    procedure SetErrorFont(const Value: tFont);
    procedure SetSpecialValues(const Value: tSpecialValuesList);
    function GetValue: LongInt;
    procedure SetValue(const Value: LongInt);
  protected
    { Protected declarations }
    procedure Change; override;
    function IsValidChar(Key: Char): Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IsValid : boolean
             read GetIsValid;  // True if the current contents of the Edit box are valid
  published
    { Published declarations }
    property ReadOnly
             write SetReadOnly;
    property NormalFont : tFont
             read fNormalFont
             write SetNormalFont;
    property ErrorFont : tFont
             read fErrorFont
             write SetErrorFont;
    property SpecialValues : tSpecialValuesList
             read fSpecialValues
             write SetSpecialValues;
    property Value: LongInt
             read GetValue
             write SetValue;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TSigSpinEdit]);
end;
{$ENDIF}

procedure TSigSpinEdit.Change;
begin
  inherited Change;
  if IsValid then
  begin
    if assigned( fNormalFont ) then
    begin
      Font.Assign( fNormalFont );
    end;
  end
  else
  begin
    if assigned( fErrorFont ) then
    begin
      Font.Assign( fErrorFont );
    end;
  end;
end;

constructor TSigSpinEdit.Create(AOwner: TComponent);
begin
  inherited;

  fNormalFont := TFont.Create;
  fErrorFont := TFont.Create;

  fSpecialValues := tSpecialValuesList.Create;

//  if assigned( Font ) then
//  begin
//    fNormalFont.Assign( Font );
//    fErrorFont.Assign( Font );
//  end;
end;

destructor TSigSpinEdit.Destroy;
begin
  fSpecialValues.Free;
  fNormalFont.Free;
  fErrorFont.Free;
  inherited;
end;

function TSigSpinEdit.GetIsValid : boolean;
var
  V : LongInt;
begin
  { return TRUE if it is safe to Use VALUE property, or false otherwise }
  if SpecialValues.IsValid( Text ) then
  begin
    //V := SpecialValues.ValueToInt( Text );
    Result := TRUE;
  end
  else
  begin
    if Text = '' then
    begin
      Result := FALSE
    end
    else
    begin
      try
        V := StrToInt( Text );
        if (MinValue = 0) and (MaxValue = 0) then Result := TRUE
        else if V < MinValue then Result := FALSE
        else if V > MaxValue then Result := FALSE
        else Result := TRUE;
      except
        Result := FALSE;
      end;
    end;
  end;
end;

function TSigSpinEdit.GetValue: LongInt;
begin
  if SpecialValues.IsValid( Text ) then
  begin
    Result := SpecialValues.ValueToInt( Text );
  end
  else
  begin
    Result := inherited Value;
  end;
end;

function TSigSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  if SpecialValues.Count = 0 then
  begin
    Result := inherited IsValidChar( Key );
  end
  else
  begin
    Result := TRUE;
  end;
end;

procedure TSigSpinEdit.SetErrorFont(const Value: tFont);
begin
  if Value = nil then
  begin
    if Font <> nil then
    begin
      fErrorFont.Assign( Font );
    end;
  end
  else
  begin
    fErrorFont.Assign( Value );
  end;
end;

procedure TSigSpinEdit.SetNormalFont(const Value: tFont);
begin
  if Value = nil then
  begin
    if Font <> nil then
    begin
      fNormalFont.Assign( Font );
    end;
  end
  else
  begin
    fNormalFont.Assign( Value );
  end;
end;

procedure TSigSpinEdit.SetReadOnly(NewVal: boolean);
begin
  inherited ReadOnly := NewVal;
  Button.Visible := not NewVal;
end;

procedure TSigSpinEdit.SetSpecialValues(const Value: tSpecialValuesList);
begin
  fSpecialValues.Assign( Value );
  fSpecialValues.CheckValid;
end;

procedure TSigSpinEdit.SetValue(const Value: LongInt);
begin
  if SpecialValues.IsValid( Value ) then
  begin
    text := SpecialValues.IntToValue( Value );
  end
  else
  begin
    inherited Value := Value;
  end;
end;

{ tSpecialValuesList }

procedure tSpecialValuesList.CheckValid;
var
  i, iPos : integer;
  iString, iString2 : string;
begin
  for i := 0 to Count - 1 do
  begin
    iString := Strings[ i ];
    iPos := Pos( '=', iString );
    if iPos = 0 then
    begin
      raise Exception.Create('Invalid String "' + iString + '" in Special values table');
    end;
    try
      iString2 := Trim( Copy( iString, iPos + 1, 255 ));
      {j := }StrToInt( iString2 );
    except
      raise Exception.Create('Invalid Value "' + iString2 + '" in "' + iString + '" in Special values table');
    end;
  end;
end;

function tSpecialValuesList.IntToValue(const pVal: integer): string;
var
  i, iPos : integer;
  iString : string;
begin
  if assigned( self) then
  begin
    for i := 0 to Count - 1 do
    begin
      iString := Strings[ i ];
      iPos := Pos( '=', iString );
      if iPos = 0 then
      begin
        raise Exception.Create('Invalid Value "' + iString + '" in Special values table');
      end;
      if StrToInt( Trim( Copy( iString, iPos + 1, 255 ))) = pVal then
      begin
        Result := Trim( Copy( iString, 1, iPos - 1));
        exit;
      end;
    end;
  end;
  // else
  raise ExceptionSpecialValuesList.Create('Special Value not found');
end;

function tSpecialValuesList.IsValid(const pVal: integer): boolean;
var
  i, iPos : integer;
  iString : string;
begin
  if assigned( self) then
  begin
    for i := 0 to Count - 1 do
    begin
      iString := Strings[ i ];
      iPos := Pos( '=', iString );
      if iPos = 0 then
      begin
        raise Exception.Create('Invalid Value "' + iString + '" in Special values table');
      end;
      if StrToInt( Trim( Copy( iString, iPos + 1, 255 ))) = pVal then
      begin
        Result := TRUE;
        exit;
      end;
    end;
  end;
  // else
  Result := FALSE;
end;

function tSpecialValuesList.IsValid(const pString: string): boolean;
var
  i, iPos : integer;
  iString : string;
begin
  if assigned( self ) then
  begin
    for i := 0 to Count - 1 do
    begin
      iString := Strings[ i ];
      iPos := Pos( '=', iString );
      if iPos = 0 then
      begin
        raise Exception.Create('Invalid Value "' + iString + '" in Special values table');
      end;
      if SameText( Trim( pString ), Trim( Copy( iString, 1, iPos - 1))) then
      begin
        Result := TRUE;
        exit;
      end;
    end;
  end;
  // else
  Result := FALSE;
end;

function tSpecialValuesList.ValueToInt(const pString: string): integer;
var
  i, iPos : integer;
  iString : string;
begin
  if assigned( self ) then
  begin
    for i := 0 to Count - 1 do
    begin
      iString := Strings[ i ];
      iPos := Pos( '=', iString );
      if iPos = 0 then
      begin
        raise Exception.Create('Invalid Value "' + iString + '" in Special values table');
      end;
      if SameText( Trim( pString ), Trim( Copy( iString, 1, iPos - 1))) then
      begin
        Result := StrToInt( Trim( Copy( iString, iPos + 1, 255 )));
        exit;
      end;
    end;
  end;
  // else
  raise ExceptionSpecialValuesList.Create('Special Value not found');
end;

end.
