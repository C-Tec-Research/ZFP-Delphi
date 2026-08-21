unit RTFGen;

interface

uses graphics,
     SysUtils;

type TRTFBase = class
  protected
    iData : AnsiString;
    NextElement  : TRTFBase;
    constructor Create( pData : AnsiString );
    procedure AddSibling( NewSibling : TRTFBase );
    function fRTFText : ANSIstring; virtual; abstract;
    property RTFText : ANSIstring
             read fRTFText;
end;

type TRTFCommand = class( TRTFBase )
  protected
    function fRTFText : ANSIstring; override;
  public
    constructor Create( pData : AnsiString );
    property RTFText
             read fRTFText;
end;

type TRTFText = class( TRTFBase )
  protected
    function fRTFText : ANSIstring; override;
  public
    constructor Create( pData : AnsiString );
    property Text : AnsiString
             read iData
             write iData;
    property RTFText
             read fRTFText;
end;

type TRTFGroup = class( TRTFBase )
  protected

    FirstChild : TRTFBase;
    LastChild  : TRTFBase;
    Parent     : TRTFBase;
    constructor Create( pData : AnsiString; pParent : TRTFGroup );

    function fRTFText : AnsiString; override;
  public
    procedure AddCommand( commandString : AnsiString );
    procedure AddText( commandString : AnsiString );
    function AddGroup( commandString : AnsiString ) : TRTFGroup;
    property RTFText
             read fRTFText;
end;

type TRTFGen = class( TRTFGroup )
  private
//    iFontTable : TRTFGroup;
    iFontCount : integer;
  public
    constructor Create;
    procedure AddSection;
    property FountCount : integer
             read iFontCount;
end;

implementation

constructor TRTFBase.Create( pData : AnsiString );
begin
  inherited Create;
  iData := pData;
  NextElement := nil;
end;

procedure TRTFBase.AddSibling( NewSibling : TRTFBase );
begin
  if NextElement <> nil then NextElement.AddSibling( NewSibling )
  else NextElement := NewSibling;
end;

constructor TRTFCommand.Create( pData : AnsiString );
begin
  inherited Create( pData );
end;

function TRTFCommand.fRTFText : ANSIstring;
begin
  result := '\' + iData;
  if NextElement <> nil then
  begin
    if NextElement is TRTFText then
      // add a terminating space
      result := result + ' ';
   Result := Result + NextElement.RTFText;
  end;
end;

constructor TRTFText.Create( pData : AnsiString );
begin
  inherited Create( pData );
end;

function TRTFText.fRTFText : ANSIstring;
begin
  result := iData;
  if NextElement <> nil then Result := Result + NextElement.RTFText;
end;

constructor TRTFGroup.Create( pData : AnsiString; pParent : TRTFGroup  );
begin
  inherited Create( pData );
  FirstChild := nil;
  LastChild := nil;
  Parent := pParent;
end;

function TRTFGroup.fRTFText : ANSIstring;
begin
  result := '{\' + iData;

  if FirstChild <> nil then
  begin
    if FirstChild is TRTFText then
      // add a terminating space
      result := result + ' ';
    Result := Result + FirstChild.RTFText;
  end;

  Result := Result + '}';

  if NextElement <> nil then
  begin
    if NextElement is TRTFText then
      // add a terminating space
      result := result + ' ';
    Result := Result + NextElement.RTFText;
  end;
end;


procedure TRTFGroup.AddCommand( commandString : AnsiString );
begin
  if FirstChild <> nil then FirstChild.AddSibling( TRTFCommand.Create( commandString ))
  else FirstChild := TRTFCommand.Create( commandString );
end;

procedure TRTFGroup.AddText( commandString : AnsiString );
begin
  if FirstChild <> nil then FirstChild.AddSibling( TRTFText.Create( commandString ))
  else FirstChild := TRTFText.Create( commandString );
end;

function TRTFGroup.AddGroup( commandString : AnsiString ) : TRTFGroup;
begin
  Result := TRTFGroup.Create( commandString, self );
  if FirstChild <> nil then FirstChild.AddSibling( Result )
  else FirstChild := Result;
end;


constructor TRTFGen.Create;
begin
  inherited Create( 'rtf1', nil );
  AddCommand( 'ansi' );
  AddCommand( 'deff0' );
  with AddGroup('fonttbl') do
  begin
    with AddGroup( 'f0' ) do
    begin
      {\f5\fswiss\fcharset0\fprq2 Arial;}
      AddCommand('fswiss');
      AddCommand('fcharset0');
      AddCommand('fprq2');
      AddText('Arial;');
    end;
  end;

  AddSection; // always at least 1 section
end;

procedure TRTFGen.AddSection;
begin
  AddCommand('sectd');
end;

end.
