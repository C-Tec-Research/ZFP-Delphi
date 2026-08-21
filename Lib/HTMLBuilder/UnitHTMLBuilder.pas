unit UnitHTMLBuilder;

interface

uses
  System.Classes,
  System.Contnrs,
  System.SysUtils;

type
  tHTMLItem = class
  private
  protected
    function GetLineCount : integer; virtual; abstract;
    function GetText : string; virtual; abstract;
  public
    constructor Create; virtual;
    property LineCount : integer
             read GetLineCount;
    property Text : string
             read GetText;
    // procedure AddLines( const pStrings : tStrings; const pIndent : integer ); virtual; abstract;
  end;

  tHTMLItemList = class( tObjectList )
  private
    function GetItem(const i: integer): tHTMLItem;
    function GetLineCount: integer;
  protected
    function GetText: string; virtual;
  public
    constructor Create; virtual;
    function Add( const pItem : tHTMLItem ) : integer; reintroduce;
    property Item[ const i : integer ] : tHTMLItem
             read GetItem;
    property LineCount : integer
             read GetLineCount;
    property Text : string
             read GetText;
    // procedure AddLines( const pStrings : tStrings; const pIndent : integer );
  end;

  tHTMLPage = class( tHTMLItemList )
  protected
    function GetText: string; override;
  public
    constructor Create; override;
  end;

  tHTMLCompoundItem = class( tHTMLItem )
  private
  protected
    fChildren : tHTMLItemList;
    fClassText : string;
    function GetLineCount : integer; override;
    function GetText : string; override;
  public
    constructor Create( const pClassText : string ); reintroduce;
    destructor Destroy; override;
    function Add( const pItem : tHTMLItem ) : integer; virtual;
  end;

  tHTMLBody = class( tHTMLCompoundItem )
  public
    constructor Create;

  end;

  tHTMLHeader = class( tHTMLCompoundItem )
  public
    constructor Create;

  end;

  tHTMLTitle = class( tHTMLItem )
  private
    fCaption : string;
  protected
    function GetLineCount : integer; override; // ignore embedded cr/lf
    function GetText : string; override;
  public
    constructor Create( const pCaption : string ); reintroduce;

  end;

  tHTMLPlainText = class( tHTMLItem )
  private
    fText : string;
  protected
    function GetLineCount : integer; override; // ignore embedded cr/lf
    function GetText : string; override;
  public
    constructor Create( const pText : string ); reintroduce;
  end;

  tHTMLBlankLine = class( tHTMLItem )
  protected
    function GetLineCount : integer; override;
    function GetText : string; override;
  end;

  tHTMLStyle = ( htmlFloat, htmlLeft );
  tHTMLStyles = set of tHTMLStyle;

  tHTMLPara = class( tHTMLCompoundItem )
  public
    constructor Create; reintroduce;
  end;

  tHTMLSpecial = class( tHTMLCompoundItem )
  private
  protected
    function GetLineCount : integer; override;
    function GetText : string; override;
  public
    constructor Create( const pClassText : string );
  end;


  tHTMLTableElement = class( tHTMLSpecial )
  public
    constructor Create; reintroduce; overload;
    constructor Create( const pClassText : string ); overload;
  end;

  tHTMLTableHeader = class( tHTMLTableElement )
  public
    constructor Create; reintroduce;
  end;

  tHTMLTableRow = class( tHTMLCompoundItem )
  public
    constructor Create; reintroduce;
    function Add( const pElement : tHTMLTableElement ) : integer; reintroduce;
  end;

  tHTMLTable = class( tHTMLCompoundItem )
  public
    constructor Create; reintroduce;
    function Add( const pRow : tHTMLTableRow ) : integer; reintroduce;
  end;

  tHTMLListLine = class( tHTMLSpecial )
  public
    constructor Create;
    function Add( const pItem : tHTMLItem ) : integer; reintroduce; overload; override;
    function Add( const pText : string ) : integer; reintroduce; overload; virtual;
  end;

  tHTMLList = class( tHTMLCompoundItem )
  public
    constructor Create( const pOrdered : boolean ); reintroduce;
    function Add( const pItem : tHTMLListLine ) : integer; reintroduce; overload;
    function Add( const pText : string ) : integer; reintroduce; overload; virtual;
  end;

  tHTMLHeading = class( tHTMLSpecial )
  public
    constructor Create( const pLevel : integer ); reintroduce;
    function Add( const pItem : tHTMLItem ) : integer; reintroduce; overload; override;
    function Add( const pText : string ) : integer; reintroduce; overload; virtual;
  end;

  tHTMLBold = class( tHTMLSpecial )
  public
    constructor Create;
  end;

  tHTMLItalic = class( tHTMLSpecial )
  public
    constructor Create;
  end;

  tHTMLEmphasis = class( tHTMLSpecial )
  public
    constructor Create;
  end;

  tHTMLStrong = class( tHTMLSpecial )
  public
    constructor Create;
  end;

  tHTMLPlainLine = class( tHTMLItem )
  private
    fText : string;
  protected
    function GetLineCount : integer; override; // ignore embedded cr/lf
    function GetText : string; override;
  public
    constructor Create( const pText : string ); reintroduce;
  end;

  tHTMLImage = class( tHTMLItem )
  private
    fStyle : tHTMLStyles;
    fSource : string;
    fAlternateText : string;
    fHeight, fWidth : integer;
  protected
    function GetLineCount : integer; override;
    function GetText : string; override;
  public
    constructor Create( const pSource : string; const pAlternateText : string; const pStyle : tHTMLStyles;
                        const pHeight : integer = 0; const pWidth : integer = 0 ); reintroduce;
  end;

  tHTMLAnchorTag = class( tHTMLItem )
  private
    fStyle : tHTMLStyles;
    fSource : string;
    fAlternateText : string;
  protected
    function GetLineCount : integer; override;
    function GetText : string; override;
  public
    constructor Create( const pSource : string; const pAlternateText : string; const pStyle : tHTMLStyles ); reintroduce;
  end;

const
  NewLine = #$D + #$A;

implementation

{ tHTMLPage }

constructor tHTMLPage.Create;
begin
  inherited Create;
end;

function tHTMLPage.GetText: string;
begin
  Result := '<!DOCTYPE html><HTML>' + inherited GetText;
  Result := Result + NewLine + '</HTML>';
end;

{ tHTMLItemList }

function tHTMLItemList.Add(const pItem: tHTMLItem): integer;
begin
  Result := inherited Add( pItem );
end;

constructor tHTMLItemList.Create;
begin
  inherited Create( TRUE );
end;

function tHTMLItemList.GetItem(const i: integer): tHTMLItem;
begin
  Result := Items[ i ] as tHTMLItem;
end;

function tHTMLItemList.GetLineCount: integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    inc( Result, Item[ i ].LineCount);
  end;
end;

function tHTMLItemList.GetText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    Result := Result + NewLine + Item[ i ].Text;
  end;
end;

{ tHTMLItem }

constructor tHTMLItem.Create;
begin
  inherited Create;
end;

{ tHTMLCompoundItem }

function tHTMLCompoundItem.Add(const pItem: tHTMLItem): integer;
begin
  Result := fChildren.Add( pItem );
end;

constructor tHTMLCompoundItem.Create(const pClassText: string);
begin
  inherited Create;

  fChildren := tHTMLItemList.Create;
  fClassText := pClassText;
end;

destructor tHTMLCompoundItem.Destroy;
begin
  fChildren.Free;
  inherited;
end;

function tHTMLCompoundItem.GetLineCount: integer;
begin
  Result := 2 + fChildren.LineCount;
end;

function tHTMLCompoundItem.GetText: string;
begin
  Result := '<' + fClassText + '>' + NewLine + fChildren.Text + '</' + fClassText + '>' + NewLine;
end;

{ tHTMLPlainLine }

constructor tHTMLPlainLine.Create(const pText: string);
begin
  inherited Create;

  fText := pText;
end;

function tHTMLPlainLine.GetLineCount: integer;
begin
  Result := 1; // ignore embedded values
end;

function tHTMLPlainLine.GetText: string;
begin
  Result := fText + '<br>' + NewLine;
end;

{ tHTMLImage }

constructor tHTMLImage.Create(const pSource, pAlternateText: string;
                        const pStyle: tHTMLStyles;
                        const pHeight : integer = 0; const pWidth : integer = 0);
begin
  inherited Create;
  fSource := pSource;
  fAlternateText := pAlternateText;
  fStyle := pStyle;
  fHeight := pHeight;
  fWidth := pWidth;
end;

function tHTMLImage.GetLineCount: integer;
begin
  Result := 1;
end;

function tHTMLImage.GetText: string;
begin
  Result := '<img src = "' + fSource + '"';
  if fWidth <> 0 then
  begin
    Result := Result + ' width="' + IntToStr( fWidth ) + '"';
  end;
  if fHeight <> 0 then
  begin
    Result := Result + ' height="' + IntToStr( fHeight ) + '"';
  end;
  Result := Result + ' alt="' + fAlternateText + '"';
  if fStyle <> [] then
  begin
    Result := Result + 'style=';
    if htmlFloat in fStyle then
    begin
      Result := Result + 'float;';
    end;
    if htmlLeft in fStyle then
    begin
      Result := Result + 'left;';
    end;
  end;
  Result := Result + '>';
end;

{ tHTMLBody }

constructor tHTMLBody.Create;
begin
  inherited Create( 'BODY' );

end;

{ tHTMLBlankLine }

function tHTMLBlankLine.GetLineCount: integer;
begin
  Result := 1;
end;

function tHTMLBlankLine.GetText: string;
begin
  Result := '<br>' + NewLine;
end;

{ tHTMLHeader }

constructor tHTMLHeader.Create;
begin
  inherited Create( 'head' );

end;

{ tHTMLTitle }

constructor tHTMLTitle.Create( const pCaption : string );
begin
  inherited Create;

  fCaption := pCaption;
end;

function tHTMLTitle.GetLineCount: integer;
begin
  Result := 1;
end;

function tHTMLTitle.GetText: string;
begin
  Result := '<title>' + fCaption + '</title>' + NewLine;
end;

{ tHTMLSpecial }

constructor tHTMLSpecial.Create( const pClassText : string );
begin
  inherited Create( pClassText );

end;

function tHTMLSpecial.GetLineCount: integer;
begin
  Result := fChildren.LineCount;
  if Result = 0 then
  begin
    Result := 1;
  end;
end;

function tHTMLSpecial.GetText: string;
begin
  Result := fChildren.Text;
  if Copy( Result, Length( Result ) - 1 ) = NewLine then
  begin
    Result := '<' + fClassText + '>' + Copy( Result, 1, Length( Result ) - 1) + '</' + fClassText + '>' + NewLine;
  end
  else
  begin
    Result := '<' + fClassText + '>' + Result + '</' + fClassText + '>' + NewLine;
  end;
end;

{ tHTMLBold }

constructor tHTMLBold.Create;
begin
  inherited Create( 'b' );
end;

{ tHTMLItalic }

constructor tHTMLItalic.Create;
begin
  inherited Create( 'i' );
end;

{ tHTMLEmphasis }

constructor tHTMLEmphasis.Create;
begin
  inherited Create( 'em' );
end;

{ tHTMLStrong }

constructor tHTMLStrong.Create;
begin
  inherited Create( 'strong' );
end;

{ tHTMLPara }

constructor tHTMLPara.Create;
begin
  inherited Create( 'p' );
end;

{ tHTMLHeading }

function tHTMLHeading.Add(const pItem: tHTMLItem): integer;
begin
  Result := inherited
end;

function tHTMLHeading.Add(const pText: string): integer;
begin
  Result := inherited Add( tHTMLPlainText.Create( pText ));
end;

constructor tHTMLHeading.Create(const pLevel: integer);
begin
  inherited Create( 'h' + IntToStr( pLevel ) );
end;

{ tHTMLPlainText }

constructor tHTMLPlainText.Create(const pText: string);
begin
  inherited Create;
  fText := pText;
end;

function tHTMLPlainText.GetLineCount: integer;
begin
  Result := 0;
end;

function tHTMLPlainText.GetText: string;
begin
  Result := fText;
end;

{ tHTMLListLine }

function tHTMLListLine.Add(const pItem: tHTMLItem): integer;
begin
  Result := inherited Add( pItem );
end;

function tHTMLListLine.Add(const pText: string): integer;
begin
  Result := inherited Add( tHTMLPlainText.Create( pText ) );
end;

constructor tHTMLListLine.Create;
begin
  inherited Create( 'li' );
end;

{ tHTMLList }

function tHTMLList.Add(const pItem: tHTMLListLine): integer;
begin
  Result := inherited Add( pItem );
end;

function tHTMLList.Add(const pText: string): integer;
var
  iHTMLListLine : tHTMLListLine;
begin
  iHTMLListLine := tHTMLListLine.Create;
  iHTMLListLine.Add( pText );
  Result := Add( iHTMLListLine );
end;

constructor tHTMLList.Create(const pOrdered: boolean);
begin
  if pOrdered then
  begin
    inherited Create( 'ol' );
  end
  else
  begin
    inherited Create( 'ul' );
  end;
end;

{ tHTMLAnchorTag }

constructor tHTMLAnchorTag.Create(const pSource, pAlternateText: string;
  const pStyle: tHTMLStyles);
begin
  inherited Create;
  fSource := pSource;
  fAlternateText := pAlternateText;
  fStyle := pStyle;
end;

function tHTMLAnchorTag.GetLineCount: integer;
begin
  Result := 0;
end;

function tHTMLAnchorTag.GetText: string;
begin
  Result := '<a href="' + fSource + '">' + fAlternateText + '</a>';
end;

{ tHTMLTableElement }

constructor tHTMLTableElement.Create;
begin
  inherited Create( 'td' );
end;

constructor tHTMLTableElement.Create(const pClassText: string);
begin
  inherited Create( pClassText );
end;

{ tHTMLTableRow }

function tHTMLTableRow.Add(const pElement: tHTMLTableElement): integer;
begin
  Result := inherited Add( pElement );
end;

constructor tHTMLTableRow.Create;
begin
  inherited Create( 'tr' );
end;

{ tHTMLTable }

function tHTMLTable.Add(const pRow: tHTMLTableRow): integer;
begin
  Result := inherited Add( pRow );
end;

constructor tHTMLTable.Create;
begin
  inherited Create( 'table' );
end;

{ tHTMLTableHeader }

constructor tHTMLTableHeader.Create;
begin
  inherited create( 'th' );
end;

end.
