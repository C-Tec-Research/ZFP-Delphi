unit SigRegistry;

interface

uses
  Registry,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs;

type
  TSigRegistry = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iIsOpen : boolean; // whether key has been opened
    iRegistry : tRegistry;
    iHistory : array[0..9] of string;
    iKey : string;
    function fGetHistory( index : integer ) : string;
    procedure fSetKey( NewVal : string );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
    property History[ index : integer ] : string
             read fGetHistory;
    property Registry : tRegistry
             read iRegistry;
    procedure Open;
    procedure Close;
    procedure SetHistory( const NewVal : string );
  published
    { Published declarations }
    property Key : string
             read iKey
             write fSetKey;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigRegistry]);
end;

//------------- TSigRegistry -------------//

constructor TSigRegistry.Create( AOwner : TComponent );
begin
  inherited;
  iIsOpen := FALSE;
  iRegistry := tRegistry.Create;
end;

destructor TSigRegistry.Destroy;
var
  i : integer;
begin
  if iIsOpen then
  begin
    for i := 0 to 9 do
    begin
      iRegistry.WriteString( 'History ' + intToStr( i ), iHistory[ i ] );
    end;
  end;
  Close;
  iRegistry.Free;
  inherited;
end;

function TSigRegistry.fGetHistory( index : integer ) : string;
begin
  Open;
  Result := iHistory[ index ];
end;

procedure TSigRegistry.SetHistory( const NewVal : string );
var
  i : integer;
  SaveString, SaveString2 : string;
begin
  Open;
  SaveString := Newval;
  for i := 0 to 9 do
  begin
    SaveString2 := iHistory[ i ];
    iHistory[ i ] := SaveString;
    if SaveString2 = NewVal then break; // have reached old pos of new val
    SaveString := SaveString2;
  end;
end;

procedure TSigRegistry.fSetKey( NewVal : string );
begin
  Close;
  iKey := NewVal;
end;

procedure TSigRegistry.Open;
var
  i : integer;
begin
  if not iIsOpen then
  begin
    with iRegistry do
    begin
      OpenKey( iKey, TRUE );
      for i := 0 to 9 do
      begin
        iHistory[ i ] := ReadString( 'History ' + intToStr( i ));
      end;
    end;
    iIsOpen := TRUE;
  end;
end;

procedure tSigRegistry.Close;
begin
  if iIsOpen then
  begin
    iRegistry.CloseKey;
    iIsOpen := False;
  end;
end;

end.
