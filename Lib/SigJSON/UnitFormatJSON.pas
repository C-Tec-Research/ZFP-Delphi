unit UnitFormatJSON;

interface

uses
  System.Classes,
  System.SysUtils;

type TJSONFormatter = class
  protected
    class function IndentStr( const pStr : string; const pCount : integer ) : string;
  public
    class procedure FormatJSON( const pJSON : string; const pFormattedJSON : TStrings;
                                const pIndentString : string = #9 );
end;

implementation

{ TJSONFormatter }

class procedure TJSONFormatter.FormatJSON(const pJSON: string;
  const pFormattedJSON: TStrings; const pIndentString: string);
var
  i, iIndentCount : integer;
  iLine : string;
  InQuotes : boolean;
  iLastLine : integer;
begin
  pFormattedJSON.Clear;
  iLine := '';
  iIndentCount := 0;
  InQuotes := FALSE;
  iLastLine := 0;
  for i := 1 to Length( pJSON ) do
  begin
    if InQuotes then
    begin
      iLine := iLine + pJSON[ i ];
      case pJSON[ i ] of
        '"':
        begin
          InQuotes := FALSE;
        end;
      end;
    end
    else
    begin
      case pJSON[ i ] of
        '{', '[':
        begin
          iLine := iLine + pJSON[ i ];
          pFormattedJSON.Add( iLine );
          inc( iIndentCount );
          iLine := IndentStr( pIndentString, iIndentCount );
        end;
        '}', ']':
        begin
          if Trim( iLine ) <> '' then
          begin
            // allow for case of successive terminators to avoid extra blank lines
            pFormattedJSON.Add( iLine );
          end;
          dec( iIndentCount );
          iLine := IndentStr( pIndentString, iIndentCount ) + pJSON[ i ];
          iLastLine := pFormattedJSON.Add( iLine );
          iLine := IndentStr( pIndentString, iIndentCount );
        end;
        ',':
        begin
          if Trim( iLine ) = '' then
          begin
            pFormattedJSON[ iLastLine ] := pFormattedJSON[ iLastLine ] + pJSON[ i ];
          end
          else
          begin
            iLine := iLine + pJSON[ i ];
            pFormattedJSON.Add( iLine );
          end;
          iLine := IndentStr( pIndentString, iIndentCount );
        end;
        '"':
        begin
          iLine := iLine + pJSON[ i ];
          InQuotes := TRUE;
        end;
        else
        begin
          iLine := iLine + pJSON[ i ];
        end;
      end;
    end;
  end;
end;

class function TJSONFormatter.IndentStr(const pStr: string;
  const pCount: integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to pCount do
  begin
    Result := Result + pStr;
  end;
end;

end.
