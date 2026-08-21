unit UnitFullName;

interface

uses
  System.SysUtils;

type
  TFullNameStyle = ( fnLastCommaFirstSpaceMiddle, fnFirstSpaceMiddleSpaceLast,
                     fnFirstSpaceLast, fnLastCommFirst );

  function GetFullName( const pStyle : TFullNameStyle; const LastName, FirstName, MiddleName : string ) : string;

implementation

  function GetFullName( const pStyle : TFullNameStyle; const LastName, FirstName, MiddleName : string ) : string;
  begin
    case pStyle of
      fnLastCommaFirstSpaceMiddle:
      begin
        Result := Trim(Trim(LastName) + ', ' + Trim( FirstName ) + ' ' + Trim(MiddleName ));
      end;
      fnFirstSpaceMiddleSpaceLast:
      begin
        Result := Trim( FirstName ) + ' ';
        if Trim( MiddleName ) <> '' then
        begin
          Result := Result + Trim( MiddleName ) + ' ';
        end;
        Result := Trim( Result + Trim( LastName ));
      end;
      fnFirstSpaceLast:
      begin
        Result := Trim(Trim( FirstName ) + ' ' + Trim( LastName ));
      end;
      fnLastCommFirst:
      begin
        Result := Trim(Trim(LastName) + ', ' + Trim( FirstName ) );
      end
      else
      begin
        Result := FirstName + ' ' + LastName;
      end;
    end;
  end;

end.
