unit UnitControlUtils;

interface

uses
  Controls;

function AbsTop( const VControl : tControl ) : integer;
function AbsLeft( const VControl : tControl ) : integer;

implementation

function AbsTop( const VControl : tControl ) : integer;
begin
  Result := VControl.Top;
  if assigned( VControl.Parent ) then
  begin
    Result := Result + AbsTop( VControl.Parent );
  end;
end;

function AbsLeft( const VControl : tControl ) : integer;
begin
  Result := VControl.Left;
  if assigned( VControl.Parent ) then
  begin
    Result := Result + AbsLeft( VControl.Parent );
  end;
end;

end.
