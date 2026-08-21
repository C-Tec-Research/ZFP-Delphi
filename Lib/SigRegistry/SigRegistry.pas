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
    function ReadInteger( const pName : string ) : integer; overload;
    function ReadInteger( const pName : string; DefaultValue : integer ) : integer; overload;
    procedure WriteInteger( const pName : string; NewVal : integer );
    function ReadBoolean( const pName : string ) : boolean; overload;
    function ReadBoolean( const pName : string; DefaultValue : boolean ) : boolean; overload;
    procedure WriteBoolean( const pName : string; NewVal : boolean );
    function ReadString( const pName : string ) : string; overload;
    function ReadString( const pName : string; DefaultValue : string ) : string; overload;
    procedure WriteString( const pName : string; NewVal : string );
    procedure StoreMainWindowParms;
    procedure RestoreMainWindowParms;
  published
    { Published declarations }
    property Key : string
             read iKey
             write fSetKey;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TSigRegistry]);
end;
{$ENDIF}

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
  if not (csDesigning in ComponentState) then
  begin
    if iIsOpen then
    begin
      for i := 0 to 9 do
      begin
        iRegistry.WriteString( 'History ' + intToStr( i ), iHistory[ i ] );
      end;
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

procedure TSigRegistry.StoreMainWindowParms;
begin
  Open;
  if assigned( Application ) then
  begin
    if assigned( Application.MainForm ) then
    begin
      iRegistry.WriteInteger( 'Main Window Monitor', Application.MainForm.Monitor.MonitorNum );
      case Application.MainForm.WindowState of
        wsMaximized:
        begin
          iRegistry.WriteString( 'Main Window State', 'Maximized' );
        end;
        wsNormal:
        begin
          iRegistry.WriteString( 'Main Window State', 'Normal' );
        end;
        // don't save minimizes state!
      end;
      iRegistry.WriteInteger( 'Main Window Top', Application.MainForm.Top );
      iRegistry.WriteInteger( 'Main Window Left', Application.MainForm.Left );
      iRegistry.WriteInteger( 'Main Window Width', Application.MainForm.Width );
      iRegistry.WriteInteger( 'Main Window Height', Application.MainForm.Height );
    end;
  end;
end;

procedure TSigRegistry.WriteBoolean(const pName: string; NewVal: boolean);
begin
  Open;
  iRegistry.WriteBool( pName, NewVal );
end;

procedure TSigRegistry.WriteInteger(const pName: string; NewVal: integer);
begin
  Open;
  iRegistry.WriteInteger( pName, NewVal );
end;

procedure TSigRegistry.WriteString(const pName: string; NewVal: string);
begin
  Open;
  iRegistry.WriteString( pName, NewVal );
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

function TSigRegistry.ReadBoolean(const pName: string): boolean;
begin
  Open;
  Result := iRegistry.ReadBool( pName );
end;

function TSigRegistry.ReadBoolean(const pName: string;
  DefaultValue: boolean): boolean;
begin
  try
    Result := ReadBoolean( pName );
  except
    Result := DefaultValue;
  end;
end;

function TSigRegistry.ReadInteger(const pName: string;
  DefaultValue: integer): integer;
begin
  try
    Result := ReadInteger( pName );
  except
    Result := DefaultValue;
  end;
end;

function TSigRegistry.ReadString(const pName: string): string;
begin
  Open;
  Result := iRegistry.ReadString( pName );
end;

function TSigRegistry.ReadString(const pName: string;
  DefaultValue: string): string;
begin
  try
    Result := ReadString( pName );
  except
    Result := DefaultValue;
  end;
end;

procedure TSigRegistry.RestoreMainWindowParms;
var
  s : string;
  iMonitor : integer;
begin
  Open;
  if assigned( Application ) then
  begin
    if assigned( Application.MainForm ) then
    begin
      try
        iMonitor := iRegistry.ReadInteger( 'Main Window Monitor' );
      except
        iMonitor := 0;
      end;
      try
        s := iRegistry.ReadString( 'Main Window State' );
        if s = 'Maximized' then
        begin
          if (iMonitor > 0) and (iMonitor < Screen.MonitorCount) then
          begin
            Application.MainForm.Top := iRegistry.ReadInteger( 'Main Window Top' );
            Application.MainForm.Left := iRegistry.ReadInteger( 'Main Window Left' );
            Application.MainForm.Width := iRegistry.ReadInteger( 'Main Window Width' );
            Application.MainForm.Height := iRegistry.ReadInteger( 'Main Window Height' );
            Application.MainForm.WindowState := wsMaximized;
          end
          else
          begin
            Application.MainForm.WindowState := wsMaximized;
          end;
        end
        else if s = 'Normal' then
        begin
          Application.MainForm.WindowState := wsNormal;
          if (iMonitor >= 0) and (iMonitor < Screen.MonitorCount) then
          begin
            Application.MainForm.Top := iRegistry.ReadInteger( 'Main Window Top' );
            Application.MainForm.Left := iRegistry.ReadInteger( 'Main Window Left' );
            Application.MainForm.Width := iRegistry.ReadInteger( 'Main Window Width' );
            Application.MainForm.Height := iRegistry.ReadInteger( 'Main Window Height' );
          end;
        end;
        // ignore anything else
      except
        // do nothing
      end;
    end;
  end;
end;

function TSigRegistry.ReadInteger( const pName : string ): integer;
begin
  Open;
  Result := iRegistry.ReadInteger( pName );
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
