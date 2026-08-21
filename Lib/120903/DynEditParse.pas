unit DynEditParse;

interface

uses
    SysUtils,
    Common;

type TDynEditParseResult = (deError, deObject, deProperty, deIndexedProperty, deComment );

function DEParse( const Line : string;
                       var ObjectOrProperty : string;
                       var Index : string;
                       var Value : string;
                       var Comment : string ) : TDynEditParseResult;

implementation

function DEParse( const Line : string;
                       var ObjectOrProperty : string;
                       var Index : string;
                       var Value : string;
                       var Comment : string ) : TDynEditParseResult;
var
  i,j : integer;
  Line1 : string;
begin
  { Trim }
  Line1 := Trim( Line );

  i := Pos( '//', Line1 );
  if i > 0 then
  begin
    Comment := Trim( SubString( Line1, i + 2, Length( Line1 )));
    Line1 := Trim( SubString( Line1, 1, i - 1));
  end
  else
  begin
    Comment := '';
  end;
  i := Pos( '=', Line1 );
  if i > 0 then
  begin
    ObjectOrProperty := Trim( SubString( Line1, 1, i - 1 ));
    Value := Trim( SubString( Line1, i + 1, Length( Line1 ) ));
    Result := deProperty;
    // see if the property is indexed
    i := Pos( '[', ObjectOrProperty );
    if i > 0 then
    begin
      // is indexed
      j := Pos( ']', ObjectOrProperty );
      if j > i then
      begin
        Index := Trim( SubString( ObjectOrProperty, i + 1, j - i - 1 ));
        ObjectOrProperty := Trim( SubString( ObjectOrProperty, 1, i - 1 ));
        Result := deIndexedProperty
      end
      else
      begin
        // unbalanced parentheses
        Result := deError;
      end;
    end
    else
    begin
      i := Pos( '(', ObjectOrProperty );
      if (i > 0 ) then
      begin
        // is indexed
        j := Pos( ')', ObjectOrProperty );
        if j > i then
        begin
          Index := Trim( SubString( ObjectOrProperty, i + 1, j - i - 1 ));
          ObjectOrProperty := Trim( SubString( ObjectOrProperty, 1, i - 1 ));
          Result := deIndexedProperty
        end
        else
        begin
          // unbalanced parentheses
          Result := deError;
        end;
      end;
    end;
  end
  else
  begin
    ObjectOrProperty := Line1;
    Value := '';
    { Treat blank lines as comments }
    if Line1 = '' then Result := deComment
    else Result := deObject;
  end;
end;

end.
