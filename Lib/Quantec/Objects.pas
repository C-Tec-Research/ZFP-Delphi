unit Objects;

interface

uses SysUtils, Classes, Constants;

type
	TSystemType = (stApolloLoop, stSysSensorLoop, stNittanLoop);

	TSiteConfig = class (TComponent)
  private
    FDateEnabled: Boolean;
    FSoundersPulsed: Boolean;
    FCopyTime: Boolean;
		FFaultLockout: integer;
    FPhasedDelay: integer;
    FPanelLocation: string;
    FEngineerNo: string;
    FMaintenanceString: string;
    FEngineer: string;
		FMaintenanceDate: TDateTime;
		FAL3Code: string;
		FAL2Code: string;
    FClientName: string;
		FLoop2: string;
    FFrontPanel: string;
		FLoop1: string;
		FMainVersion: string;
		FInstaller: string;
    FClientAddress3: string;
    FClientAddress2: string;
    FClientAddress1: string;
		FClientAddress5: string;
    FClientAddress4: string;
    FInstallerAddress3: string;
    FInstallerAddress2: string;
    FInstallerAddress1: string;
    FInstallerAddress5: string;
    FInstallerAddress4: string;
    function GetMainVersion: string;
	public
		property ClientName: string read FClientName write FClientName;
		property ClientAddress1: string read FClientAddress1 write FClientAddress1;
		property ClientAddress2: string read FClientAddress2 write FClientAddress2;
		property ClientAddress3: string read FClientAddress3 write FClientAddress3;
		property ClientAddress4: string read FClientAddress4 write FClientAddress4;
		property ClientAddress5: string read FClientAddress5 write FClientAddress5;
		property InstallerName: string read FInstaller write FInstaller;
		property InstallerAddress1: string read FInstallerAddress1 write FInstallerAddress1;
		property InstallerAddress2: string read FInstallerAddress2 write FInstallerAddress2;
		property InstallerAddress3: string read FInstallerAddress3 write FInstallerAddress3;
		property InstallerAddress4: string read FInstallerAddress4 write FInstallerAddress4;
		property InstallerAddress5: string read FInstallerAddress5 write FInstallerAddress5;
		property MainVersion: string read GetMainVersion write FMainVersion;
		property FrontPanel:  string read FFrontPanel write FFrontPanel;
		property Loop1: string read FLoop1 write FLoop1;
		property Loop2: string read FLoop2 write FLoop2;

		constructor Create (AOwner: TComponent); override;

	published
		property AL2Code: string read FAL2Code write FAL2Code;
		property AL3Code: string read FAL3Code write FAL3Code;
		property PanelLocation: string read FPanelLocation write FPanelLocation;
		property Engineer: string read FEngineer write FEngineer;
		property EngineerNo: string read FEngineerNo write FEngineerNo;
		property MaintenanceString: string read FMaintenanceString write FMaintenanceString;
		property MaintenanceDate: TDateTime read FMaintenanceDate write FMaintenanceDate;
		property DateEnabled: Boolean read FDateEnabled write FDateEnabled;
		property PhasedDelay: integer read FPhasedDelay write FPhasedDelay;
		property SoundersPulsed: Boolean read FSoundersPulsed write FSoundersPulsed;
		property FaultLockout: integer read FFaultLockout write FFaultLockout;
		property CopyTime: Boolean read FCopyTime write FCopyTime;
	end;

	TZone = class (TObject)
	private
		FName: string;
    FMCP: Boolean;
    FDetector: Boolean;
		FRemoteDelay: integer;
		FSounderDelay: integer;
    FNonFire: Boolean;
	public
		Group: array [0..MAX_ZONE] of byte;	// Stores whether this group is in zone
		CCTS: array [0..MAX_CCTS] of byte;
		ZoneSet: array [0..MAX_ZONE] of Boolean;
	published
		property Name: string read FName write FName;
		property SounderDelay: integer read FSounderDelay  write FSounderDelay;
		property RemoteDelay: integer read FRemoteDelay write FRemoteDelay;
		property Detector: Boolean read FDetector write FDetector;
		property MCP: Boolean read FMCP write FMCP;
		property NonFire: Boolean read FNonFire write FNonFire;
	end;

	TZoneList = class (TComponent)
	public
		Zone: array [0..MAX_ZONE] of TZone;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
	end;

	TGroup = class (TObject)
	private
		FName: string;
	published
		property Name: string read FName write FName;
	end;

	TGroupList = class (TComponent)
	public
		Group: array [0..MAX_GROUP] of TGroup;
		OutputSet: array [0..MAX_ZONE] of TGroup;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
	end;

	TDeviceType = class (TObject)
	private
		FDevType: integer;
		FZone: integer;
		FName: string;
		FHint: string;
    FGroup: integer;
		function GetHint: string;
	public
		constructor Create;
	published
		property DevType: integer read FDevType write FDevType;
		property Name: string read FName write FName;
		property Zone: integer read FZone write FZone;
		property Group: integer read FGroup write FGroup;
		property Hint: string read GetHint write FHint;
	end;

	TAFPLoop = class (TComponent)
	private
		FDevIndex: integer;
    FSystemType: TSystemType;
		FGroup: integer;
    FAsIOUnit: Boolean;
    function GetNoLoopDevices: integer;
	protected

	public
		Device: array[1..MAX_DEVICE] of TDeviceType;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
		function IsGroup (Index: integer): Boolean;
		function IsSet (Index: Integer): Boolean;
		function IsZoneSet (Index: integer): Boolean;
		function ShortDeviceName (Index: integer): string;
		function FullDeviceName (Index: integer): string;
	published
		property DevIndex: integer read FDevIndex write FDevIndex;
		property SystemType: TSystemType read FSystemType write FSystemType;
		property Group: integer read FGroup write FGroup;
		property NoLoopDevices: integer read GetNoLoopDevices;
		property AsIOUnit: Boolean read FAsIOUnit write FAsIOUnit;
	end;

	TNetwork = class (TObject)
	private
    FBoolean: Boolean;
    FName: string;
	public
		property Name: string read FName write FName;
		property Fitted: Boolean read FBoolean write FBoolean;
	end;

	TRepeaterList = class (TComponent)
	private
		FSegment: integer;
		FPanelName: string;
	public
		Repeater: array [1..MAX_REPEATER] of TNetwork;
		Output: array [1..MAX_ZONAL_OUTPUT] of TNetwork;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
	published
		property PanelName: string read FPanelName write FPanelName;
		property Segment: integer read FSegment write FSegment;
	end;


procedure Register;

implementation

procedure Register;
begin
	RegisterComponents ('AFP', [TAFPLoop, TZoneList, TGroupList, TRepeaterList,
		TSiteConfig]);
end;

{ TDeviceType }

constructor TDeviceType.Create;
begin
  inherited;
	DevType := 0;
	Group := 0;
	Hint := '';
	Name := 'Unnamed Point';
	Zone := 1;
end;

function TDeviceType.GetHint: string;
begin
	Result := FHint;
end;

{ TLoop }

constructor TAFPLoop.Create(AOwner: TComponent);
var
	i: integer;
begin
	inherited;
	{ Create device type for each index of loop }
	if not (csDesigning in ComponentState) then begin
		for i := 1 to MAX_DEVICE do Device[i] := TDeviceType.Create;
	end;
end;

destructor TAFPLoop.Destroy;
var
	i: integer;
begin
	if not (csDesigning in ComponentState) then begin
		for i := 1 to 255 do Device[i].Free;
	end;
	inherited;
end;

{ TGroupList }

constructor TGroupList.Create(AOwner: TComponent);
var
	Index: integer;
begin
	inherited;
	{ Create a group object for all groups, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_GROUP do begin
			Group[Index] := TGroup.Create;
			Group[Index].Name := 'Group ' + IntToStr (Index);
		end;
	{ Create a set object for all sets, but not when in design mode }
  for Index := 0 to MAX_ZONE do begin
			OutputSet[Index] := TGroup.Create;
			OutputSet[Index].Name := 'Set ' + IntToStr (Index);
		end;

		{ Rename group 0 }
		Group[0].Name := GROUP_ZERO_NAME;
		OutputSet[0].Name := OUTPUT_SET_ZERO_NAME;
	end;
end;

destructor TGroupList.Destroy;
var
	Index: integer;
begin
	try
		{ Free memory created for group information, but not when in design mode }
		if not (csDesigning in ComponentState) then
			for Index := 1 to MAX_GROUP do Group[Index].Free;
	finally
		inherited;
	end;
end;

{ TZoneList }

constructor TZoneList.Create(AOwner: TComponent);
var
	Index: integer;
begin
	inherited;
	{ Create a zone object for all zones, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_ZONE do begin
			Zone[Index] := TZone.Create;
			Zone[Index].Name := 'Zone ' + IntToStr (Index);
			Zone[Index].SounderDelay := 10;
			Zone[Index].RemoteDelay := 10;
			Zone[Index].Detector := false;
			Zone[Index].MCP := false;
		end;
		{ Rename zone 0 }
		Zone[0].Name := ZONE_ZERO_NAME;
	end;
end;

destructor TZoneList.Destroy;
var
	Index: integer;
begin
	try
		{ Free memory created for zone information, but not when in design mode }
		if not (csDesigning in ComponentState) then
			for Index := 1 to MAX_ZONE do Zone[Index].Free;
	finally
		inherited;
	end;
end;

{ TAFPLoop }

function TAFPLoop.FullDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin
	if Index = 0 then
		Result := 'Not fitted'
	else case SystemType of
		{ Determine type of loop }
		stApolloLoop:
			begin
				{ Determine type of device within Apollo loop }
				case Index of
					1: Result := 'Addressable sounder/Sounder Control Unit';
					2: Result := 'I/O Unit';
					3: Result := 'Ionisation smoke detector';
					4: Result := 'Zone Monitor';
					5: Result := 'Optical smoke detector';
					6: Result := 'Temperature monitor';
					7: Result := 'Mini switch monitor';
					8: Result := 'High sensitivity optical smoke detector';
					9: Result := 'High temperature monitor';
					10: Result := 'XP95 Manual Call Point';
					11: Result := 'Series 90 Manual Call Point';
					12: Result := 'Output unit';
          13: Result := 'Multi-Sensor detector';
          14: Result := 'Flame detector';
          15: Result := 'Beam detector';
				else
					Result := '';
				end;
			end;

		stSysSensorLoop:
			begin
				{ Determine type of device within system sensor loop }
				case Index of
					1: Result := 'Temperature detector';
					2: Result := 'Ionisation smoke detector';
					3: Result := 'Optical smoke detector';
					4: Result := 'Omni sensor';
					5: Result := 'Manual call point';
					6: Result := 'Loop powered sounder';
					7: Result := 'Zone monitor';
					8: Result := 'Output unit';
				else
					Result := '';
				end;
			end;

		stNittanLoop:
			begin
				{ Determine type of device within Nittan loop }
				case Index of
					1: Result := 'Addressable sounder';
					2: Result := 'Output module';
					3: Result := 'Ionisation smoke detector';
					4: Result := 'Zone monitor';
					5: Result := 'Optical smoke detector';
					6: Result := 'Temperature monitor';
					7: Result := 'Manual call point';
					8: Result := 'Input module';
				else
					Result := '';
				end;
			end;
		else
			Result := '';
		end;
end;

function TAFPLoop.GetNoLoopDevices: integer;
begin
	{ Acquire the maximum number of devices for the correct system type }
	case SystemType of
		stApolloLoop: Result := MAX_POINTS_APOLLO;
		stSysSensorLoop: Result := MAX_POINTS_SYS_SENSOR;
		stNittanLoop: Result := MAX_POINTS_NITTAN;
	else
		{ If the system type is unrecognised, return 0 devices }
		Result := 0;
	end;
end;

function TAFPLoop.IsGroup (Index: integer): Boolean;
{ This function determines whether the device number 'index' is group-based or
zone-based }
begin
	Result := (((SystemType = stApolloLoop)    and (Device[Index].DevType = 1)) or
					   ((SystemType = stSysSensorLoop) and (Device[Index].DevType = 6)) or
					   ((SystemType = stNittanLoop)    and (Device[Index].DevType = 1)));
end;

function TAFPLoop.IsSet(Index: Integer): Boolean;
begin
	Result := (((SystemType = stApolloLoop) and (Device[Index].DevType = 12)) or
						 ((SystemType = stSysSensorLoop) and (Device[Index].DevType = 8)) or
						 ((SystemType = stNittanLoop) and (Device[Index].DevType = 2)));

end;

function TAFPLoop.IsZoneSet(Index: integer): Boolean;
begin
	Result := ((SystemType = stApolloLoop) and (Device[Index].DevType = 2));
end;

function TAFPLoop.ShortDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin
	if Index = 0 then
		Result := 'N/Fitted'
	else case SystemType of
		{ Determine type of loop }
		stApolloLoop:
			begin
				{ Determine type of device within Apollo loop }
				case Index of
					1: Result := 'Sndr/SCU';
					2: Result := 'I/O Unit';
					3: Result := 'Ion';
					4: Result := 'Zone Mon';
					5: Result := 'Opt';
					6: Result := 'Temp';
					7: Result := 'Sw Mon';
					8: Result := 'Hi Opt';
					9: Result := 'Hi Temp';
					10: Result := 'XP95 MCP';
					11: Result := 'S90 MCP';
					12: Result := 'O/P Unit';
          13: Result := 'MultiSen';
          14: Result := 'Flame';
          15: Result := 'Beam';
				else
					Result := '';
				end;
			end;

		stSysSensorLoop:
			begin
				{ Determine type of device within system sensor loop }
				case Index of
					1: Result := 'Temp';
					2: Result := 'Ion';
					3: Result := 'Opt';
					4: Result := 'Omni';
					5: Result := 'MCP';
					6: Result := 'Sounder';
					7: Result := 'Zone Mon';
					8: Result := 'O/P Unit';
				else
					Result := '';
				end;
			end;

		stNittanLoop:
			begin
				{ Determine type of device within Nittan loop }
				case Index of
					1: Result := 'Sounder';
					2: Result := 'O/P Mod';
					3: Result := 'Ion';
					4: Result := 'Zone Mon';
					5: Result := 'Opt';
					6: Result := 'Temp';
					7: Result := 'MCP';
					8: Result := 'I/P Mod';
				else
					Result := '';
				end;
			end;
		else
			Result := '';
		end;
end;


{ TRepeaterList }

constructor TRepeaterList.Create(AOwner: TComponent);
var
	i: integer;
begin
	inherited;
	{ Set up memory for each repeater object }
	for i := 1 to MAX_REPEATER do begin
		Repeater[i] := TNetwork.Create;
		Output[i] := TNetwork.Create;
	end;
	{ Default Segment number to 1 }
	Segment := 1;
	PanelName := 'Main Panel';
end;

destructor TRepeaterList.Destroy;
var
	i: integer;
begin
	inherited;

	{ Ensure memory used for each repeater object is freed }
	for i := 1 to MAX_REPEATER do begin
		Repeater[i].Free;
		Output[i].Free;
	end;
end;

{ TSiteConfig }

constructor TSiteConfig.Create (AOwner: TComponent);
begin
	inherited;
	{ Initialise variables }
	MainVersion := '';
	MaintenanceDate := Date;
	FaultLockOut := 10;
	PhasedDelay := 10;
	MaintenanceString := 'ANALOGUE FIRE PANEL - AFP';
end;

function TSiteConfig.GetMainVersion: string;
begin
	Result := FMainVersion;
	if FMainVersion = '' then Result := '08A00';
end;

end.
