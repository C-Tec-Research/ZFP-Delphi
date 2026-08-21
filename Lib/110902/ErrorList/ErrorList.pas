unit ErrorList;

interface

uses
  Contnrs,
  SysUtils,
  StdCtrls,
  classes;

type
  tError = class
  private
    fErrorLine: integer;
    fErrorPos: integer;
    fErrorText: string;
  public
    property ErrorLine : integer
             read fErrorLine;
    property ErrorPos : integer
             read fErrorPos;
    property ErrorText : string
             read fErrorText;
    function DetailedErrorText : string;
    constructor Create( pErrorLine, pErrPos : integer; pErrorText : string ); reintroduce; overload;
    constructor Create( pErrorLine : integer; pErrorText : string ); overload;
  end;

  tErrorList = class( tObjectList )
  private
    function GetError(const index: integer): tError;
  public
    constructor Create; reintroduce;
    property Error[ const index : integer ] : tError
             read GetError;
    procedure Add( const pErrorLine, pErrorPos : integer; pErrorText : string ); reintroduce; overload;
    procedure Add( const pErrorLine : integer; pErrorText : string ); overload;
    procedure Assign( pStrings : tStrings ); overload;
    procedure Assign( pMemo : tMemo ); overload;
    procedure LocateError( pMemo : tMemo; pIndex : integer );
  end;

implementation

{ tErrorList }

procedure tErrorList.Add(const pErrorLine, pErrorPos: integer;
  pErrorText: string);
begin
  inherited Add( tError.Create( pErrorLine, pErrorPos, pErrorText ));
end;

procedure tErrorList.Add(const pErrorLine: integer; pErrorText: string);
begin
  inherited Add( tError.Create( pErrorLine, pErrorText ));
end;

procedure tErrorList.Assign(pMemo: tMemo);
begin
  if Count = 0 then
  begin
    pMemo.Visible := FALSE;
  end
  else
  begin
    pMemo.Visible := TRUE;
    Assign( pMemo.Lines );
  end;
end;

procedure tErrorList.Assign(pStrings: tStrings);
var
  I: Integer;
begin
  pStrings.Clear;
  for I := 0 to Count - 1 do
  begin
    pStrings.Add( Error[ i ].DetailedErrorText);
  end;
end;

constructor tErrorList.Create;
begin
  inherited Create( TRUE );
end;

function tErrorList.GetError(const index: integer): tError;
begin
  Result := Items[ index ] as tError;
end;

procedure tErrorList.LocateError(pMemo: tMemo; pIndex: integer);
var
  iRow : integer;
begin
  pMemo.SelStart := 0;
  with Error[ pIndex ] do
  begin
    for iRow := 0 to ErrorLine - 1 do
    begin
      pMemo.SelStart := pMemo.SelStart + Length( pMemo.Lines[ iRow ] );
    end;
    if ErrorPos = 0 then
    begin
      pMemo.SelLength := Length( pMemo.Lines[ ErrorLine ] );
    end
    else
    begin
      pMemo.SelStart := pMemo.SelStart + ErrorPos;
    end;
  end;
end;

{ tError }

constructor tError.Create(pErrorLine, pErrPos: integer; pErrorText: string);
begin
  inherited Create;
  fErrorLine := pErrorLine;
  fErrorPos := pErrPos;
  fErrorText := pErrorText;
end;

constructor tError.Create(pErrorLine: integer; pErrorText: string);
begin
  Create( pErrorLine, 0, pErrorText );
end;

function tError.DetailedErrorText: string;
begin
  Result := 'Line ' + IntToStr( ErrorLine );
  if ErrorPos <> 0 then
  begin
    Result := Result + ', ' + IntToStr( ErrorPos );
  end;
  Result := Result + ':' + stringOfChar( ' ', 18 - Length( Result ) ) + ErrorText;
end;

end.
