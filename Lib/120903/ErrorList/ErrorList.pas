unit ErrorList;

interface

uses
  Contnrs,
  SysUtils,
  StdCtrls,
  classes;

type
  tErrorSeverity = (es_Default, es_Error, es_Warning, es_Hint );

  tOnTranslate = function( const pText : string ) : string of object;

  tErrorList = class;

  tError = class
  private
    fErrorLine: integer;
    fErrorPos: integer;
    fErrorText: string;
    fErrorObject: tObject;
    fSeverity: tErrorSeverity;
    fErrorList: tErrorList;
  public
    destructor Destroy; override;
    property ErrorLine : integer
             read fErrorLine;
    property ErrorPos : integer
             read fErrorPos;
    property ErrorText : string
             read fErrorText;
    function DetailedErrorText : string;
    constructor Create( pOwner : tErrorList; pErrorLine, pErrPos : integer; pErrorText : string ); reintroduce; overload;
    constructor Create( pOwner : tErrorList; pErrorLine : integer; pErrorText : string ); overload;
    constructor Create( pOwner : tErrorList; pSeverity : tErrorSeverity; pErrorLine, pErrPos : integer; pErrorText : string ); overload;
    constructor Create( pOwner : tErrorList; pSeverity : tErrorSeverity; pErrorLine : integer; pErrorText : string ); overload;
    property ErrorObject : tObject
             read fErrorObject
             write fErrorObject;
    property Severity : tErrorSeverity
             read fSeverity
             write fSeverity;
    property ErrorList : tErrorList
             read fErrorList
             write fErrorList;
  end;

  tErrorObjects = class( tObjectList )
  private
    fOnNewAdd: tNotifyEvent;
  public
    constructor Create; reintroduce;
    function Add( iObject : tObject ) : integer; reintroduce; // do not allow duplicates
    property OnNewAdd : tNotifyEvent
             read fOnNewAdd
             write fonNewAdd;
  end;

  tErrorList = class( tObjectList )
  private
    fOnTranslate: tOnTranslate;
    fErrorCount: integer;
    fHintCount: integer;
    fWarningCount: integer;
    fDefaultCount: integer;
    function GetError(const index: integer): tError;
  protected
    fErrorObjects : tErrorObjects;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure Clear; override;

    property Error[ const index : integer ] : tError
             read GetError;
    procedure Add( const pErrorLine, pErrorPos : integer; pErrorText : string; pErrorObject : tObject = nil ); reintroduce; overload;
    procedure Add( const pErrorLine : integer; pErrorText : string; pErrorObject : tObject = nil ); overload;
    procedure Add( const pSeverity : tErrorSeverity; const pErrorLine, pErrorPos : integer; pErrorText : string; pErrorObject : tObject = nil ); reintroduce; overload;
    procedure Add( const pSeverity : tErrorSeverity; const pErrorLine : integer; pErrorText : string; pErrorObject : tObject = nil ); overload;
    procedure Assign( pStrings : tStrings ); overload;
    procedure Assign( pMemo : tMemo ); overload;
    procedure LocateError( pMemo : tMemo; pIndex : integer );

    property OnTranslate : tOnTranslate
             read fOnTranslate
             write fOnTranslate;
    function Translate( pText : string ) : string;

    property ErrorCount : integer
             read fErrorCount;
    property WarningCount : integer
             read fWarningCount;
    property HintCount : integer
             read fHintCount;
    property DefaultCount : integer
             read fDefaultCount;
  end;

implementation

{ tErrorList }

procedure tErrorList.Add(const pErrorLine, pErrorPos: integer;
  pErrorText: string; pErrorObject : tObject = nil);
var
  iError : tError;
begin
  iError := tError.Create( self, pErrorLine, pErrorPos, pErrorText );
  if assigned( pErrorObject ) then
  begin
    iError.ErrorObject := pErrorObject;
    fErrorObjects.Add( pErrorObject ); // to allow autodestruction on exit
  end;
  inherited Add( iError );
  inc( fDefaultCount );
end;

procedure tErrorList.Add(const pErrorLine: integer; pErrorText: string; pErrorObject : tObject = nil);
var
  iError : tError;
begin
  iError := tError.Create( self, pErrorLine, pErrorText );
  begin
    iError.ErrorObject := pErrorObject;
    fErrorObjects.Add( pErrorObject ); // to allow autodestruction on exit
  end;
  inherited Add( iError );
  inc( fDefaultCount );
end;

procedure tErrorList.Add(const pSeverity: tErrorSeverity; const pErrorLine,
  pErrorPos: integer; pErrorText: string; pErrorObject: tObject);
var
  iError : tError;
begin
  iError := tError.Create( self, pSeverity, pErrorLine, pErrorPos, pErrorText );
  begin
    iError.ErrorObject := pErrorObject;
    fErrorObjects.Add( pErrorObject ); // to allow autodestruction on exit
  end;
  inherited Add( iError );
  case pSeverity of
    es_Default: inc( fDefaultCount );
    es_Error:   inc( fErrorCount );
    es_Warning: inc( fWarningCount );
    es_Hint:    inc( fHintCount );
  end;
end;

procedure tErrorList.Add(const pSeverity: tErrorSeverity;
  const pErrorLine: integer; pErrorText: string; pErrorObject: tObject);
var
  iError : tError;
begin
  iError := tError.Create( self, pSeverity, pErrorLine, pErrorText );
  iError.ErrorObject := pErrorObject;
  if assigned( pErrorObject ) then
  begin
    fErrorObjects.Add( pErrorObject ); // to allow autodestruction on exit
  end;
  inherited Add( iError );
  case pSeverity of
    es_Default: inc( fDefaultCount );
    es_Error: inc( fErrorCount );
    es_Warning: inc( fWarningCount );
    es_Hint: inc( fHintCount );
  end;
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
    pStrings.AddObject( Error[ i ].DetailedErrorText, Error[ i ] );
  end;
end;

procedure tErrorList.Clear;
begin
  inherited;

  fErrorCount   := 0;
  fHintCount    := 0;
  fWarningCount := 0;
  fDefaultCount := 0;
end;

constructor tErrorList.Create;
begin
  inherited Create( TRUE );
  fErrorObjects := tErrorObjects.Create;

end;

destructor tErrorList.Destroy;
begin
  fErrorObjects.Free;
  inherited;
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

function tErrorList.Translate(pText: string): string;
begin
  if assigned( fOnTranslate ) then
  begin
    Result := fOnTranslate( pText );
  end
  else
  begin
    Result := pText;
  end;
end;

{ tError }

constructor tError.Create(pOwner : tErrorList; pErrorLine, pErrPos: integer; pErrorText: string);
begin
  inherited Create;
  fErrorList := pOwner;
  fErrorLine := pErrorLine;
  fErrorPos := pErrPos;
  fErrorText := pErrorText;
end;

constructor tError.Create(pOwner : tErrorList; pErrorLine: integer; pErrorText: string);
begin
  Create( pOwner, pErrorLine, 0, pErrorText );
end;

constructor tError.Create(pOwner : tErrorList; pSeverity: tErrorSeverity; pErrorLine,
  pErrPos: integer; pErrorText: string);
begin
  Create( pOwner, pErrorLine, pErrPos, pErrorText );
  fSeverity := pSeverity;
end;

constructor tError.Create(pOwner : tErrorList; pSeverity: tErrorSeverity; pErrorLine: integer;
  pErrorText: string);
begin
  Create( pOwner, pErrorLine, 0, pErrorText );
  fSeverity := pSeverity;
end;

destructor tError.Destroy;
begin
  inherited;
end;

function tError.DetailedErrorText: string;
begin
  case fSeverity of
    es_Default: Result := '';
    es_Error:   Result := fErrorList.Translate( 'Error' );
    es_Warning: Result := fErrorList.Translate( 'Warning' );
    es_Hint: Result    := fErrorList.Translate( 'Hint' );
    else
    begin
      Result := '';
    end;
  end;
  Result := '';
  if ErrorLine <> 0 then
  begin
    Result := fErrorList.Translate( 'Line' ) + ' ' + IntToStr( ErrorLine );
  end;
  if ErrorPos <> 0 then
  begin
    if ErrorLine <> 0 then
    begin
      Result := Result + ', ';
    end;
    Result := Result + IntToStr( ErrorPos );
  end;
  if (ErrorPos <> 0) or (ErrorLine <> 0) then
  begin
    Result := Result + ':' + stringOfChar( ' ', 18 - Length( Result ) );
  end;
  Result := Result + ErrorText;
end;

{ tErrorObjects }

function tErrorObjects.Add(iObject: tObject): integer;
begin
  for Result := 0 to Count - 1 do
  begin
    if iObject = self.Items[ Result ] then
    begin
      exit; // already exists
    end;
  end;
  // else
  Result := inherited Add( iObject );
  if assigned( fOnNewAdd ) then
  begin
    fOnNewAdd( iObject );
  end;
end;

constructor tErrorObjects.Create;
begin
  inherited Create( TRUE );
end;

end.
