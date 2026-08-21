unit Sesa;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, IniFiles, mmsystem;

const SESA_MIN_ZONE = 1;
const SESA_MAX_ZONE = 256;
const SESA_CONTROLLER = 1;

const SESA_INI_FILE = 'SigMAIN.INI';

const SESA_OK = 0;
const SESA_ZONE_RANGE_ERROR = 2;

const SESA_MAJOR_ZONE_FAULT = 2;
const SESA_ZONE_BUSY = 3;
const SESA_ZONE_NOT_DEFINED = 4;
const SESA_NO_VALID_ZONES = 5; 
const SESA_SOUND_CARD_BUSY = 6;

const Additive = 1;
type
  TSesaPanel = class(TPanel)
  private
    { Private declarations }
    iZone : Array [1..SESA_MAX_ZONE] of Boolean;
    iTimer : TTimer;
    iMessageFile : string;
    SESA_MessageNo : integer;
    IniFile : TIniFile;
    fOnMessageComplete : TNotifyEvent;

    iPlaying : boolean;

    procedure fOnTimer(Sender: TObject);
  protected
    { Protected declarations }
    { respond to the create message...}
    procedure WMCreate( var Message : TCREATESTRUCT) ;
              message WM_CREATE;
    { respond to the WAV file complete message }
    procedure MessageDone( var Message : TMessage ) ;
              message MM_MCINOTIFY;
  public
    { Public declarations }
    constructor Create( pOwner : TComponent ); override;
    destructor Destroy; override;

    procedure ClearAllZones;
    function AddZone( pZone : integer ) : integer;
    function PlayMessage( pMessageFile : String ) : integer;
    procedure EndMessage;
  published
    { Published declarations }
    property OnMessageComplete : TNotifyEvent
             read fOnMessageComplete
             write fOnMessageComplete;
    property Playing : boolean
    		  read iPlaying;
  end;

procedure Register;

implementation

{ uses certain functions from SigNET.DLL. }
uses
  SigLoad;

constructor TSesaPanel.Create( pOwner : TComponent );
begin
  inherited Create( pOwner );

  { Load SigNET.DLL}
  Sig1Load;

  { open the ini file }
  IniFile := TIniFile.Create( SESA_INI_FILE );

  { Set up timer }
  iTimer := TTimer.Create( self );
  iTimer.Interval := 100;  { 1/10 second }
  iTimer.OnTimer := fOnTimer;

  { Find the SESA Message number from the INI file }
  SESA_MessageNo := IniFile.ReadInteger( 'Hardware', 'SESA Message Slot', 255);

  ClearAllZones;
end;

destructor TSesaPanel.Destroy;
begin
  { we no longer exist, so don't let DLL talk to
    us }

  iTimer.Free;
  EndMessage;

  { Stop Timer Messages }
  SetNotifyWindow( HWND_BROADCAST, SESA_Controller);

  { unload SigNET.DLL }
  Sig1Unload;

  { close the ini file }
  IniFile.Free;

  inherited Destroy;
end;

procedure TSesaPanel.WMCreate( var Message : TCREATESTRUCT) ;
begin
  inherited; { in case my ancestors do anything}
  SetNotifyWindow( Handle, SESA_Controller);
  { direct responses to us }
  iPlaying := FALSE;
end;

procedure TSesaPanel.ClearAllZones;
var
  i : integer;
begin
  for i := 1 to SESA_MAX_ZONE do
  begin
    iZone[ i ] := FALSE;
  end;
end;

procedure TSesaPanel.fOnTimer(Sender: TObject);
begin
  { Process periodic actions of SigNET }
  if assigned( SigNET_Execute ) then SigNET_Execute;

end;

function TSesaPanel.AddZone( pZone : integer ) : integer;
begin
  if (pZone < SESA_MIN_ZONE) or (pZONE >= SESA_MAX_ZONE) then
  begin
     Result := SESA_ZONE_RANGE_ERROR;
  end
  else
  begin
    iZone[ pZone ] := TRUE;
    Result := SESA_OK;
  end;
end;

function TSesaPanel.PlayMessage( pMessageFile : String ) : integer;
var
  Channel_ID : integer;
  i : integer;
  Err, Busy : integer;
  ZoneCount : integer;
begin

  if not iPlaying then
  begin
    { prevent re-entrancy, etc }
    iPlaying := TRUE;

    { broadcasts the message file }
    iMessageFile := pMessageFile;

    { Default result - assume OK }
    Result := SESA_OK;

    { find channel ID }
    Channel_ID := vDiskDVAChannel;

    { Check for Sound card busy
      remember it could be in use by either controller }
    if ( vDVAPending( 0 ) = Channel_ID)
       or (vDVAPending( 1 ) = Channel_ID) then
    begin
      Result := SESA_SOUND_CARD_BUSY;
      iPlaying := FALSE;
    end;


    { Check for zones busy/in error }
    ZoneCount := 0;
    for i := SESA_MIN_ZONE to SESA_MAX_ZONE do
    begin
      if iZone[ i ] then
      begin
        if GzStatus( i, Err, Busy, SESA_CONTROLLER ) then
        begin
           { At least zone exists! }
           Inc( ZoneCount );
           { We ignore minor errors - we can still probably page }
           if (Err > 1) then
           begin
             { probably comms fault; }
             Result := SESA_MAJOR_ZONE_FAULT;
             iPlaying := FALSE;
           end;
           if (Busy <> 0)then
           begin
             { Do not override if zone is busy (even if technically we can) }
             Result := SESA_ZONE_BUSY;
             iPlaying := FALSE;
           end;
        end
        else
        begin
	  { no such zone - set warning }
          Result := SESA_ZONE_NOT_DEFINED;
        end;
      end;
    end;

    { Check some zones were defined }
    if (ZoneCount > 0) then
    begin

      SetNotifyWindow( Handle, SESA_Controller);
      { Make sure we get the message }

      { Change The message in the ini file to point to the WAV file }
      IniFile.WriteString( 'Hardware',
                         'Message ' + IntToStr( SESA_MessageNo ),
                         iMessageFile + ',Last SESA Message');

      { Set channel for Disk DVA output }
      SigNET_Change_Selected_Channel( Channel_ID, SESA_CONTROLLER );

      { Select the zones }
      for i := SESA_MIN_ZONE to SESA_MAX_ZONE do
      begin
        if iZone[ i ] then
        begin
          GzoneSelect( i, Additive, SESA_CONTROLLER );
        end;
      end;

      { and play }
      SigNET_Go_DVA( SESA_MessageNo, SESA_CONTROLLER );
    end
    else
    begin
      Result := SESA_NO_VALID_ZONES;
      iPlaying := FALSE;
    end;
  end;
end;

procedure TSesaPanel.MessageDone( var Message : TMessage );
begin
  EndMessage;
end;

procedure TSesaPanel.EndMessage;
begin
  if iPlaying then
  begin
    iPlaying := FALSE;

    { tell SigNET.DLL we are done }
{   if vDVAPending (SESA_CONTROLLER) > 0 then}
    	DDVA_Complete( SESA_CONTROLLER );
    { now tell our application by calling the OnMessageComplete
      event, if it is defined }
    if Assigned( fOnMessageComplete ) then
    begin
      fOnMessageComplete( self );
    end;
    ResetNodesSelected( FALSE, SESA_CONTROLLER );
  end;
end;

procedure Register;
begin
  RegisterComponents('SigNET', [TSesaPanel]);
end;

end.
