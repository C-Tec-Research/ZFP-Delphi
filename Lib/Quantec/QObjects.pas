unit QObjects;

interface

uses SysUtils, Classes, Objects, Constants;
//, AreaEquation;

type
  tQAreaArray = array [ 0.. 8 ] of integer;

type
	TSystemType = (stApolloLoop, stSysSensorLoop, stNittanLoop);


	TQSiteConfig1 = class (TSiteConfig)
          private
                FAttackCode: string;
                FCallCode: string;
                FNightModeTime: string;
                FDayModeTime: string;
                FNightModeAutoEnable: boolean;
                FPrinterEnabled: boolean;
                FLoggerSetting: integer;
                FPagerEnabled: boolean;
                FPagerLevel: integer;
                FEmergState: boolean;
                FAttackState: boolean;
                FAccTimeout: integer;
                FDivTimeout: integer;
                FClientTel: string;
                FInstallDate: string;
                FCommissionDate: string;
                FHTM2015Enable: boolean;
                FSurveyorEnable: boolean;
          public
          	constructor Create (AOwner: TComponent); override;
	  published
		property CallCode: string read FCallCode write FCallCode;
		property AttackCode: string read FAttackCode write FAttackCode;
                property NightModeTime: string read FNightModeTime write FNightModeTime;
                property DayModeTime: string read FDayModeTime write FDayModeTime;
                property NightModeAutoEnable: boolean read FNightModeAutoEnable write FNightModeAutoEnable;
                property HTM2015Enable: boolean read FHTM2015Enable write FHTM2015Enable;
                property SurveyorEnable: boolean read FSurveyorEnable write FSurveyorEnable;
                property PrinterEnabled: boolean read FPrinterEnabled write FPrinterEnabled;
                property PagerEnabled: boolean read FPagerEnabled write FPagerEnabled;
                property LoggerSetting: integer read FLoggerSetting write FLoggerSetting;
                property PagerLevel: integer read FPagerLevel write FPagerLevel;
                property AccTimeout: integer read FAccTimeout write FAccTimeout;
                property DivTimeout: integer read FDivTimeout write FDivTimeout;
                property EmergState: boolean read FEmergState write FEmergState;
                property AttackState: boolean read FAttackState write FAttackState;
                property ClientTel: string read FClientTel write FClientTel;
                property InstallDate: string read FInstallDate write FInstallDate;
                property CommissionDate: string read FCommissionDate write FCommissionDate;
	end;

	TQZone = class (TObject)
	private
		FName: string;

        public
//                AreaEqn: array [0..8] of integer;
//                DeviceEqn: array [0..8] of integer;
                AreaEqn:   tQAreaArray;
                DeviceEqn: tQAreaArray;

	published
		property Name: string read FName write FName;
        end;

	TQZoneList = class (TComponent)
	public
		Zone: array [0..MAX_ZONE+1] of TQZone;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
	end;

	TQGroup = class (TObject)
        public
//                PrimaryArea: array [0..8] of integer;
//                NightArea: array [0..8] of integer;
                PrimaryArea : tQAreaArray;
                NightArea:    tQAreaArray;
                Divert: array [0..8] of integer;
	end;

	TQGroupList = class (TComponent)
	public
		Group: array [0..MAX_GROUP] of TQGroup;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
	end;

	TQDeviceType = class (TObject)
	private
		FDevType: integer;
		FZone: integer;
                FTextPtr: integer;
		FName: string;
		FHint: string;
                FGroup: integer;
                FEnabled: integer;
		function GetHint: string;
	public
		constructor Create;
	published
		property DevType: integer read FDevType write FDevType;
		property Name: string read FName write FName;
		property Zone: integer read FZone write FZone;
		property Group: integer read FGroup write FGroup;
		property Hint: string read GetHint write FHint;
                property TextPtr: integer read FTextPtr write FTextPtr;
                property DeviceEnabled: integer read FEnabled write FEnabled;
	end;

       	TQLoop = class (TComponent)
	private
		FDevIndex: integer;
                FSystemType: TSystemType;
		FGroup: integer;
                FAsIOUnit: Boolean;
                function GetNoLoopDevices: integer;
	protected

	public
		Device: array[1..MAX_DEVICE] of TQDeviceType;
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
		function IsGroup (Index: integer): Boolean;
		function IsArea (Index: Integer): Boolean;
		function IsZone (Index: integer): Boolean;
		function ShortDeviceName (Index: integer): string;
		function FullDeviceName (Index: integer): string;
	published
		property DevIndex: integer read FDevIndex write FDevIndex;
		property SystemType: TSystemType read FSystemType write FSystemType;
		property Group: integer read FGroup write FGroup;
		property NoLoopDevices: integer read GetNoLoopDevices;
		property AsIOUnit: Boolean read FAsIOUnit write FAsIOUnit;
	end;


        TQCustomPlaceNames = class (TObject)
        protected
          iName : string;
        public
          property      Name: string
                        read iName
                        write iName;

        end;

        TDSMCustNames = class( TList )
          protected
            function fGetItems( const index : integer ) : TQCustomPlaceNames;
          public
            property Item[ const index : integer ] : TQCustomPlaceNames
                read fGetItems; default;
            function AddItem : Integer;
        end;


procedure Register;

implementation


procedure Register;
begin
	RegisterComponents ('AFP', [ TQZoneList, TQGroupList, TQSiteConfig1, TQLoop]);
end;

{ Custom Names }

function TDSMCustNames.fGetItems( const index : integer ) : TQCustomPlaceNames;
begin
  Result := TQCustomPlaceNames( Items[ index ] );
end;

function TDSMCustNames.AddItem : Integer;
begin
  result := Add( TQCustomPlaceNames.Create );
  Item[ Result ].Name := 'Custom ' + IntToStr( Count );
end;


{ TDeviceType }

constructor TQDeviceType.Create;
begin
  inherited;
	DevType := 0;
	Group := 0;
	Hint := '';
	Name := '';
	Zone := 1;
        TextPtr := 0;
end;

function TQDeviceType.GetHint: string;
begin
	Result := FHint;
end;

{ TQLoop }
constructor TQLoop.Create(AOwner: TComponent);
var
	i: integer;
begin
	inherited;
	{ Create device type for each index of loop }
	if not (csDesigning in ComponentState) then begin
		for i := 1 to MAX_DEVICE do Device[i] := TQDeviceType.Create;
	end;
end;

destructor TQLoop.Destroy;
var
	i: integer;
begin
	if not (csDesigning in ComponentState) then begin
		for i := 1 to 255 do Device[i].Free;
	end;
	inherited;
end;


{ TZoneList }

constructor TQZoneList.Create(AOwner: TComponent);
var
	Index: integer;
        Index1: integer;
begin
	inherited;
	{ Create a zone object for all zones, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_ZONE do begin
                  Zone[Index] := TQZone.Create;
		  Zone[Index].Name := 'Zone ' + IntToStr (Index);

                  for Index1 := 0 to 8 do begin
                    Zone[Index].AreaEqn[Index1] := 26;
                    Zone[Index].DeviceEqn[Index1] := 256;
                  end;
		end;
		{ Rename zone 0 }
		Zone[0].Name := ZONE_ZERO_NAME;
	end;
end;

destructor TQZoneList.Destroy;
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

{ TGroupList }

constructor TQGroupList.Create(AOwner: TComponent);
var
	Index: integer;
        Index1: integer;
begin
	inherited;
	{ Create a Group object for all groups, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_GROUP do begin
                  Group[Index] := TQGroup.Create;

                  for Index1 := 0 to 8 do begin
                    Group[Index].PrimaryArea[Index1] := 0;
                    Group[Index].NightArea[Index1] := 0;
                    Group[Index].Divert[Index1] := 0;
                  end;
		end;
	end;
end;

destructor TQGroupList.Destroy;
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


{ TAFPLoop }

function TQLoop.FullDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin
	if Index = 0 then
	  Result := 'Not fitted'

        { Determine type of device within Apollo loop }
	else case Index of
	 1: Result := 'Callpoint';
	 2: Result := 'Audio enabled callpoint';
	 3: Result := 'UnKnown';
	 4: Result := 'Corridor Display';
	 5: Result := 'Doorbell';
	 6: Result := 'Monitoring Point';
	 7: Result := 'Over-door Light / Addressable Sounder';
   8: Result := 'Network Controller';
   9: Result := 'Radio Receiver';
	else
 	  Result := '';
	end;
end;

function TQLoop.GetNoLoopDevices: integer;
begin
	{ Acquire the maximum number of devices for the correct system type }

        Result := MAX_DEVICE;
end;

function TQLoop.IsGroup (Index: integer): Boolean;
{ This function determines whether the device number 'index' is group-based or
zone-based }
begin

	Result := FALSE;

        if Device[Index].DevType = 4 then Result := TRUE;
        if Device[Index].DevType = 8 then Result := TRUE;
end;

function TQLoop.IsArea(Index: Integer): Boolean;
begin
        Result := FALSE;

        if Device[Index].DevType = 1 then Result := TRUE;
        if Device[Index].DevType = 5 then Result := TRUE;
        if Device[Index].DevType = 6 then Result := TRUE;
        if Device[Index].DevType = 9 then Result := TRUE;
end;

function TQLoop.IsZone(Index: integer): Boolean;
begin
        Result := FALSE;

        if Device[Index].DevType = 7 then Result := TRUE;
end;

function TQLoop.ShortDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin

	if Index = 0 then
	  Result := 'Not fitted'

        { Determine type of device within Apollo loop }
	else case Index of
	 1: Result := 'Callpoint';
	 2: Result := 'ACallpoint';
	 3: Result := 'UnKnown';
	 4: Result := 'Display';
	 5: Result := 'Doorbell';
	 6: Result := 'Mon Point';
	 7: Result := 'OD Light/Sounder';
   8: Result := 'Network Controller';
   9: Result := 'Radio Receiver';
         else
 	  Result := '';
	end;
end;



{ TSiteConfig1 }

constructor TQSiteConfig1.Create (AOwner: TComponent);
begin
	inherited;
	{ Initialise variables }
        CallCode := '1234';
        AttackCode := '4321';
end;

end.
