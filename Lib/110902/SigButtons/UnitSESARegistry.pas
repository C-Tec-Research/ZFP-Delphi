unit UnitSESARegistry;

interface

uses
  Registry,
  SysUtils;

type
  tSESARegistry = class( tRegistry )
  protected
    function fGetHistory( Index : integer ) : string;
  public
    procedure SetHistory( NewVal : string );
    property History[ Index : integer ] : string
             read fGetHistory;
end;

var
  SESARegistry : tSESARegistry;

implementation

function tSESARegistry.fGetHistory( Index : integer ) : string;
begin
  result := ReadString( 'History ' + IntToStr( Index ));
end;

procedure tSESARegistry.SetHistory( NewVal  : string );
var
  TempVal1, TempVal2 : string;
  i : integer;
begin
  TempVal1 := NewVal;
  for i := 0 to 9 do
  begin
    if TempVal1 = '' then exit; // done
    TempVal2 := History[ i ];
    if TempVal1 = TempVal2 then Exit; // done
    WriteString( 'History ' + IntToStr( i ), TempVal1 );
    TempVal1 := TempVal2;
  end;
end;

initialization
  SESARegistry := tSESARegistry.Create;
  SESARegistry.OpenKey( '\Software\SigNET\SESA Central', TRUE );
  if ParamStr( 1 ) <> '' then
  begin
    SESARegistry.SetHistory( ParamStr( 1 ));
  end;

finalization
  SESARegistry.CloseKey;
  SESARegistry.Free;

end.
