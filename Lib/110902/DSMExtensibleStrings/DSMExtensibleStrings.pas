unit DSMExtensibleStrings;

{
  this is really a set of strings that can be extended by incrementing the
  last digit. We use records to allow operator overloading.
}

interface

uses
  SysUtils,
  DSMList;

type
  tDSMExtensibleStringError = ( esConflict, esRange, esDuplicate, esNonExtensible, esIncludesNonExtensibleValues );

  tDSMExtensibleStringErrors = set of tDSMExtensibleStringError;

  eDSMExtensibleString = class( exception )

  end;

  tDSMExtensibleString = record
  private
    fError: tDSMExtensibleStringErrors;
    fText : string;
    fPresentValues : tDSMList;
    fIndex : integer;
  public
    property Error : tDSMExtensibleStringErrors
             read fError;

    function IsExtensible : boolean;

    class operator implicit( a : string ) : tDSMExtensibleString;
    class operator implicit( a : tDSMExtensibleString ) : string;
    class operator Add( a : tDSMExtensibleString; b : string ) : tDSMExtensibleString;
    class operator Positive( a : tDSMExtensibleString ) : string;
  end;

implementation

function SplitString( const pText : string; var pBase : string; var pExtension : integer ) : boolean;
var
  i : integer;
  iMul : integer;
begin
  Result := FALSE;
  pExtension := 0;
  pBase := '';
  iMul := 1;
  for i := Length( pText) downto 1 do
  begin
    case pText[ i ] of
      '0'..'9':
      begin
        Result := TRUE;
        inc( pExtension, iMul * (ord( pText[ i ] ) - ord( '0' )));
        iMul := iMul * 10;
      end;
      else
      begin
        pBase := Copy( pText, 1, i );
        exit;
      end;
    end;
  end;
end;

{ DtSMExtensibleString }


class operator tDSMExtensibleString.implicit(a: string): tDSMExtensibleString;
var
  iVal : integer;
  iBase : string;
begin
  with Result do
  begin
    fError := [];
    if SplitString( a, iBase, iVal ) then
    begin
      fText := iBase;
      if iVal > 9999 then
      begin
        fPresentValues := '';
        fError := fError + [esRange];
      end
      else
      begin
        fPresentValues := iVal;
      end;
      fIndex := iVal;
    end
    else
    begin
      Result.fText := a;
      fPresentValues := '';
      fError := fError + [esNonExtensible];
      fIndex := 0;
    end;
  end;
end;

class operator tDSMExtensibleString.Add(a: tDSMExtensibleString;
  b: string): tDSMExtensibleString;
var
  iBase : string;
  iVal : integer;
begin
  Result := a;
  with Result do
  begin
    if IsExtensible then
    begin
      if SplitString( b, iBase, iVal ) then
      begin
        if SameText( iBase, Result.fText )  then
        begin
          if iVal > 9999 then
          begin
            fError := fError + [ esRange ];
          end
          else if iVal <= fPresentValues then
          begin
            fError := fError + [ esDuplicate ];
          end
          else
          begin
            fPresentValues := fPresentValues + iVal;
            if iVal < fIndex then
            begin
              fIndex := iVal;
            end;
          end;
        end
        else
        begin
          fError := fError + [ esConflict ];
        end;
      end
      else
      begin
        fError := fError + [ esIncludesNonExtensibleValues ];
      end;
    end;
  end;
end;

class operator tDSMExtensibleString.implicit(a: tDSMExtensibleString): string;
begin
  if a.IsExtensible then
  begin
    Result := a.fText + IntToStr( a.fIndex );
  end
  else
  begin
    Result := a.fText;
  end;
end;

class operator tDSMExtensibleString.Positive(a: tDSMExtensibleString): string;
begin
  if esNonExtensible in a.fError then
  begin
    raise eDSMExtensibleString.Create( 'String is not extensible' );
  end;

  inc( a.fIndex );
  while (a.fIndex <= a.fPresentValues) do
  begin
    inc( a.fIndex );
  end;
  Result := a;
end;

function tDSMExtensibleString.IsExtensible: boolean;
begin
  Result := not ( esNonExtensible in fError );
end;

end.
