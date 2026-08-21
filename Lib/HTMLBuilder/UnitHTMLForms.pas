unit UnitHTMLForms;

interface

uses
  UnitHTMLBuilder;

type
  tHTMLForm = class( tHTMLCompoundItem )
  private
    fAction : string;
    fPost : boolean;
  protected
    function GetText : string; override;
  public
    constructor Create( const pAction : string; const pPost : boolean = FALSE );
  end;

  tHTMLInputStyle = ( isText, isPassword, isCheckBox, isRadio, iSubmit, isReset, isHidden, isImage, isFile, isButton );

  tHTMLSimpleInputItem = class( tHTMLItem )
  private
    fStyle : string;
    fType : string;
    fName : string;
  protected
    function fProperties : string; virtual;
    function GetText : string; override;
    function GetLineCount : integer; override;
  public
    constructor Create( const pStyle : string; const pType : string; const pName : string ); reintroduce;
  end;

  tHTMLCompoundInputItem = class( tHTMLCompoundItem )
  private
    fType : string;
    fName : string;
  protected
    function fProperties : string; virtual;
    function GetText : string; override;
  public
    constructor Create( const pStyle : string; const pType : string; const pName : string );
  end;

  tHTMLInput = class( tHTMLSimpleInputItem )
  private
    fDefaultValue : string;
  protected
    function fProperties : string; override;
  public
    constructor Create( const pName : string; const pDefaultValue : string = '' );
  end;

  tHTMLPasswordInput = class( tHTMLSimpleInputItem )
  private
  protected
  public
    constructor Create( const pName : string );
  end;

  tHTMLSubmitButton = class( tHTMLSimpleInputItem )
  private
    fButtonText : string;
  protected
    function fProperties : string; override;
  public
    constructor Create( const pButtonText : string );
  end;

  tHTMLTextArea = class( tHTMLCompoundInputItem )

  end;

  tHTMLSelect = class( tHTMLCompoundInputItem ) // select box


  end;

implementation

{ tHTMLForm }

constructor tHTMLForm.Create( const pAction : string; const pPost : boolean );
begin
  inherited Create( 'form' );
  fAction := pAction;
  fPost := pPost;
end;

function tHTMLForm.GetText: string;
begin
  Result := '<form action = "' + fAction + '" method=';
  if fPost then
  begin
    Result := Result + 'post';
  end
  else
  begin
    Result := Result + 'get';
  end;
  Result := Result + '>';
  Result := Result + fChildren.Text;
  Result := Result + '</form>' + Newline;
end;

{ tHTMLInput }

constructor tHTMLInput.Create(const pName : string; const pDefaultValue : string);
begin
  inherited Create( 'input', 'text', pName );
  fDefaultValue := pDefaultValue;
end;

function tHTMLInput.fProperties: string;
begin
  if fDefaultValue = '' then
  begin
    Result := '';
  end
  else
  begin
    Result := 'Value="' + fDefaultValue +'"';
  end;
end;

{ tHTMLSimpleInputItem }

constructor tHTMLSimpleInputItem.Create(const pStyle : string; const pType: string; const pName : string);
begin
  inherited Create;
  fStyle := pStyle;
  fType := pType;
  fName := pName;
end;

function tHTMLSimpleInputItem.fProperties: string;
begin
  Result := '';
end;

function tHTMLSimpleInputItem.GetLineCount: integer;
begin
  Result := 1;
end;

function tHTMLSimpleInputItem.GetText: string;
begin
  Result := '<' + fStyle;
  if fType <> '' then
  begin
    Result := Result + ' type="' + fType + '"';
  end;
  if fName <> '' then
  begin
    Result := Result + ' name="' + fName + '" ';
  end;
  if fProperties <> '' then
  begin
    Result := Result + fProperties;
  end;
  Result := Result + '>'  + NewLine;
end;

{ tHTMLPasswordInput }

constructor tHTMLPasswordInput.Create(const pName: string);
begin
  inherited Create( 'input', 'password', pName );
end;

{ tHTMLCompoundInputItem }

constructor tHTMLCompoundInputItem.Create(const pStyle : string; const pType, pName: string);
begin
  inherited Create( pStyle );
  fName := pName;
  fType := pType;
end;

function tHTMLCompoundInputItem.fProperties: string;
begin
  Result := '';
end;

function tHTMLCompoundInputItem.GetText: string;
begin
  Result := '<' + fClassText;
  if fType <> '' then
  begin
    Result := Result + ' type="' + fType + '"';
  end;
  if fName <> '' then
  begin
    Result := Result + ' name="' + fName + '" ';
  end;
  if fProperties <> '' then
  begin
    Result := Result + fProperties;
  end;
  Result := Result + '</' + fClassText + '>' + NewLine;;
end;

{ tHTMLSubmitButton }

constructor tHTMLSubmitButton.Create(const pButtonText: string);
begin
  inherited Create( 'input', 'submit', '' );
  fButtonText := pButtonText;
end;

function tHTMLSubmitButton.fProperties: string;
begin
  Result := 'value="' + fButtonText + '" ';
end;

end.
