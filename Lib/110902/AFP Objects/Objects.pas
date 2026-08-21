unit Objects;

interface

{
  23/07/09 DSM take over.
           Move towards dynamic arrays and object lists where appropriate
           Make MAX_xxx properties
}


uses SysUtils, Classes,
     contnrs,
     SigFile,
     ErrorList,
     Windows;

(*
type
	TSystemType = (stApolloLoop, stSysSensorLoop, stNittanLoop);

	TSiteConfig = class (TSigCompoundProperty)
  private
    FDateEnabled: TSigBooleanProperty;
    FSoundersPulsed: TSigBooleanProperty;
    FCopyTime: TSigBooleanProperty;
		FFaultLockout: tSigIntegerProperty;
    FPhasedDelay: tSigIntegerProperty;
    FPanelLocation: tSigSimpleProperty;
    FEngineerNo: tSigSimpleProperty;
    FMaintenanceString: tSigSimpleProperty;
    FEngineer: tSigSimpleProperty;

		FMaintenanceDate: tSigDateTimeProperty;
		FAL3Code: tSigSimpleProperty;
		FAL2Code: tSigSimpleProperty;
    FClientName: tSigSimpleProperty;
		FLoop1: tSigSimpleProperty;
		FLoop2: tSigSimpleProperty;
    FFrontPanel: tSigSimpleProperty;
		FMainVersion: tSigSimpleProperty;
		FInstaller: tSigSimpleProperty;
{
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
}
    fClientAddress: tMemoProperty;
    fInstallerAddress: tMemoProperty;
    function GetInstallerAddress1: string;
    function GetInstallerAddress2: string;
    function GetInstallerAddress3: string;
    function GetInstallerAddress4: string;
    function GetInstallerAddress5: string;
    procedure SetInstallerAddress1(const Value: string);
    procedure SetInstallerAddress2(const Value: string);
    procedure SetInstallerAddress3(const Value: string);
    procedure SetInstallerAddress4(const Value: string);
    procedure SetInstallerAddress5(const Value: string);
    function GetClientAddress1: string;
    function GetClientAddress2: string;
    function GetClientAddress3: string;
    function GetClientAddress4: string;
    function GetClientAddress5: string;
    procedure SetClientAddress1(const Value: string);
    procedure SetClientAddress2(const Value: string);
    procedure SetClientAddress3(const Value: string);
    procedure SetClientAddress4(const Value: string);
    procedure SetClientAddress5(const Value: string);
    function GetMainVersion: string;
    function GetDateEnabled: Boolean;
    procedure SetDateEnabled(const pValue: Boolean);
    function GetSoundersPulsed: Boolean;
    procedure SetSoundersPulsed(const pValue: Boolean);
    function GetCopyTime: Boolean;
    procedure SetCopyTime(const pValue: Boolean);
    function GetFaultLockout: integer;
    procedure SetFaultLockout(const pValue: integer);
    function GetPhasedDelay: integer;
    procedure SetPhasedDelay(const pValue: integer);
    function GetPanelLocation: string;
    procedure SetPanelLocation(const pValue: string);
    function GetEngineerNo: string;
    procedure SetEngineerNo(const pValue: string);
    function GetMaintenanceString: string;
    procedure SetMaintenanceString(const pValue: string);
    function GetEngineer: string;
    procedure SetEngineer(const pValue: string);
    function GetMaintenanceDate: TDateTime;
    procedure SetMaintenanceDate(const pValue: TDateTime);
    function GetAL3Code: string;
    procedure SetAL3Code(const pValue: string);
    function GetAL2Code: string;
    procedure SetAL2Code(const pValue: string);
    function GetClientName: string;
    procedure SetClientName(const pValue: string);
    function GetLoop2: string;
    procedure SetLoop2(const pValue: string);
    function GetLoop1: string;
    procedure SetLoop1(const pValue: string);
    function GetFrontPanel: string;
    procedure SetFrontPanel(const pValue: string);
    procedure SetMainVersion(const pValue: string);
    function GetInstaller: string;
    procedure SetInstaller(const pValue: string);
    function GetOnVersionChange: tSigOnChange;
    procedure SetOnVersionChange(const Value: tSigOnChange);
	public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
//    destructor Destroy; override;

		property ClientName: string
             read GetClientName
             write SetClientName;
    property ClientAddress : tMemoProperty
             read fClientAddress;
		property ClientAddress1: string
             read GetClientAddress1
             write SetClientAddress1;
		property ClientAddress2:
             string read GetClientAddress2
             write SetClientAddress2;
		property ClientAddress3:
             string read GetClientAddress3
             write SetClientAddress3;
		property ClientAddress4:
             string read GetClientAddress4
             write SetClientAddress4;
		property ClientAddress5: string
             read GetClientAddress5
             write SetClientAddress5;
		property InstallerName: string
             read GetInstaller
             write SetInstaller;
    property InstallerAddress : tMemoProperty
             read fInstallerAddress;
		property InstallerAddress1: string
             read GetInstallerAddress1
             write SetInstallerAddress1;
		property InstallerAddress2: string
             read GetInstallerAddress2
             write SetInstallerAddress2;
		property InstallerAddress3: string
             read GetInstallerAddress3
             write SetInstallerAddress3;
		property InstallerAddress4: string
             read GetInstallerAddress4
             write SetInstallerAddress4;
		property InstallerAddress5: string
             read GetInstallerAddress5
             write SetInstallerAddress5;
		property MainVersion: string
             read GetMainVersion
             write SetMainVersion;
		property FrontPanel:  string
             read GetFrontPanel
             write SetFrontPanel;
		property Loop1: string
             read GetLoop1
             write SetLoop1;
		property Loop2: string
             read GetLoop2
             write SetLoop2;

		property AL2Code: string
             read GetAL2Code
             write SetAL2Code;
		property AL3Code: string
             read GetAL3Code
             write SetAL3Code;
		property PanelLocation: string
             read GetPanelLocation
             write SetPanelLocation;
		property Engineer: string
             read GetEngineer
             write SetEngineer;
		property EngineerNo: string
             read GetEngineerNo
             write SetEngineerNo;
		property MaintenanceString: string
             read GetMaintenanceString
             write SetMaintenanceString;
		property MaintenanceDate: TDateTime
             read GetMaintenanceDate
             write SetMaintenanceDate;
		property DateEnabled: Boolean
             read GetDateEnabled
             write SetDateEnabled;
		property PhasedDelay: integer
             read GetPhasedDelay
             write SetPhasedDelay;
		property SoundersPulsed: Boolean
             read GetSoundersPulsed
             write SetSoundersPulsed;
		property FaultLockout: integer
             read GetFaultLockout
             write SetFaultLockout;
		property CopyTime: Boolean
             read GetCopyTime
             write SetCopyTime;
    property OnMainVersionChange : tSigOnChange
             read GetOnVersionChange
             write SetOnVersionChange;
	end;
*)

type
	TZone = class (TSigCompoundProperty)
	private
		FName: TSigSimpleProperty;
    FMCP: TSigBooleanProperty;
    FDetector: TSigBooleanProperty;
		FRemoteDelay: TSigIntegerProperty;
		FSounderDelay: TSigIntegerProperty;
    FNonFire: TSigBooleanProperty;
    FCCTS : TSigByteArray;
    FZoneSet : tSigBooleanArray;       // work together!
    FGroup : TSigByteArray;            //
//    fMax_Zone: integer;
//    fMax_CCTS: integer;

    procedure SetMax_CCTS(const Value: integer);
    procedure SetMax_Zone(const Value: integer);
    function GetName: string;
    procedure SetName(const pValue: string);
    function GetMCP: Boolean;
    procedure SetMCP(const pValue: Boolean);
    function GetDetector: Boolean;
    procedure SetDetector(const pValue: Boolean);
    function GetRemoteDelay: integer;
    procedure SetRemoteDelay(const pValue: integer);
    function GetSounderDelay: integer;
    procedure SetSounderDelay(const pValue: integer);
    function GetNonFire: Boolean;
    procedure SetNonFire(const pValue: Boolean);
    function GetGroup(const i: integer): byte;
    procedure SetGroup(const i: integer; const Value: byte);
    function GetCCTS(const i: integer): byte;
    procedure SetCCTS(const i: integer; const Value: byte);
    function GetMax_CCTS: integer;
    function GetZoneSet(const i: integer): boolean;
    procedure SetZoneSet(const i: integer; const Value: boolean);
    function GetMax_Zone: integer;
	public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;

    property ZoneSet[ const i : integer ] : boolean
             read GetZoneSet
             write SetZoneSet;
    property Group[ const i : integer ] : byte
             read GetGroup
             write SetGroup;
    property CCTS[ const i : integer ] : byte
             read GetCCTS
             write SetCCTS;
		property Name: string
             read GetName
             write SetName;
		property SounderDelay: integer
             read GetSounderDelay
             write SetSounderDelay;
		property RemoteDelay: integer
             read GetRemoteDelay
             write SetRemoteDelay;
		property Detector: Boolean
             read GetDetector
             write SetDetector;
		property MCP: Boolean
             read GetMCP
             write SetMCP;
		property NonFire: Boolean
             read GetNonFire
             write SetNonFire;
    property Max_Zone : integer
             read GetMax_Zone
             write SetMax_Zone
             default 32;
    property Max_CCTS : integer
             read GetMax_CCTS
             write SetMax_CCTS
             default 4;
	end;

{
  TZoneObjectList = class( TObjectList )
  private
    fMax: integer;
    function GetItem(const Index: integer): tZone;
    procedure SetMax(const Value: integer);
  public
    constructor Create; reintroduce;
    property Item[ const Index : integer ] : tZone
             read GetItem; default;
    property Max : integer
             read fMax
             write SetMax;
  end;
}

	TZoneList = class (TSigObjectArray)
  private
    function GetMax_Zone: integer;
    procedure SetMax_Zone(const Value: integer);
    function GetZone(const i: integer): TZone;
	public
//		Zone: TZoneObjectList;
    const ZONE_ZERO_NAME = 'No zone allocated';
//		constructor Create (AOwner: TComponent); override;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
//		destructor Destroy; override;
    property Zone[ const i : integer ] : TZone
             read GetZone;
    property Max_Zone : integer
             read GetMax_Zone
             write SetMax_Zone
             default 32;
    function CreateChild( const pPropertyText : string; const pIndexText : string = '';
                          const pValue : string = ''; const pComment : string = '';
                          pErrors : tErrorList = nil; pErrorLine : integer = 0; pErrorPos : integer = 0 ) : tSigBaseProperty; override;
	end;

	TGroupList = class (tSigCompoundProperty)
  private
		fGroup: tSigObjectArray;
		fOutputSet: tSigObjectArray;
    fOutput_Set_Zero_Name: TSigSimpleProperty;
    fGroup_Zero_Name: TSigSimpleProperty;
    fGroup_DefaultNamePrefix: TSigSimpleProperty;
    fOutputSet_DefaultNamePrefix: TSigSimpleProperty;
    procedure SetGroup_DefaultNamePrefix(const pValue: string);
    procedure SetOutputSet_DefaultNamePrefix(const pValue: string);
    function GetMax_Group: integer;
    procedure SetGroup_Zero_Name(const pValue: string);
    procedure SetMax_Group(const Value: integer);
    procedure SetMax_OutputSet(const Value: integer);
    procedure SetOutput_Set_Zero_Name(const pValue: string);
    function GetMax_OutputSet: integer;
    function GetGroup(const i : integer): string;
    procedure SetGroup(const i : integer; const pValue: string);
    function GetOutputSet(const i: integer): string;
    procedure SetOutputSet(const i: integer; const pValue: string);
    function GetOutputSet_DefaultNamePrefix: string;
    function GetGroup_DefaultNamePrefix: string;
    function GetGroup_Zero_Name: string;
    function GetOutput_Set_Zero_Name: string;
  protected
	public
    constructor Create( pOwner : tSigCompoundProperty ); reintroduce;

    property OutputSet_DefaultNamePrefix : string
             read GetOutputSet_DefaultNamePrefix
             write SetOutputSet_DefaultNamePrefix;
    property Group_DefaultNamePrefix : string
             read GetGroup_DefaultNamePrefix
             write SetGroup_DefaultNamePrefix;
    property Group_Zero_Name : string
             read GetGroup_Zero_Name
             write SetGroup_Zero_Name;
    property Output_Set_Zero_Name : string
             read GetOutput_Set_Zero_Name
             write SetOutput_Set_Zero_Name;
    property Max_Group : integer
             read GetMax_Group   // during create this can differ from Group Max
             write SetMax_Group;
    property Max_OutputSet : integer  // during create this can differ from output.Max
             read GetMax_OutputSet
             write SetMax_OutputSet;
    property Group[ const i : integer ] : string
             read GetGroup
             write SetGroup;
    property OutputSet[ const i : integer ] : string
             read GetOutputSet
             write SetOutputSet;
	end;

	TDeviceType = class (TSigCompoundProperty)
	private
		FDevType: TSigIntegerProperty;
		FZone: TSigIntegerProperty;
		FHint: TSigSimpleProperty;
    FGroup: TSigIntegerProperty;
		function GetHint: string;
    function GetDevType: integer;
    function GetName: string;
    procedure SetDevType(const pValue: integer);
    procedure SetName(const pValue: string);
    function GetGroup: integer;
    function GetZone: integer;
    procedure SetGroup(const pValue: integer);
    procedure SetHint(const pValue: string);
    procedure SetZone(const pValue: integer);
	public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
		property DevType: integer
             read GetDevType
             write SetDevType;
		property Name: string
             read GetName
             write SetName;
		property Zone: integer
             read GetZone
             write SetZone;
		property Group: integer
             read GetGroup
             write SetGroup;
		property Hint: string
             read GetHint
             write SetHint;
	end;

  TDeviceTypeList = class( tSigObjectArray )
  private
    function GetItem(const Index: integer): tDeviceType;
    procedure SetMax_Device(const pValue: integer);
    function GetMax_Device: integer;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Item[ const Index : integer ] : tDeviceType
             read GetItem; default;
    property Max_Device : integer
             read GetMax_Device
             write SetMax_Device;
  end;

(*
	TAFPLoop = class (tSigCompoundProperty)
	private
		FDevIndex: TSigIntegerProperty;
    FSystemType: TSigSimpleProperty;
		FGroup: TSigIntegerProperty;
    FAsIOUnit: TSigBooleanProperty;
    fNotFittedShortName: tSigSimpleProperty;
    fUnknownShortName: tSigSimpleProperty;
    fNotFittedFullName: tSigSimpleProperty;
    fUnknownFullName: tSigSimpleProperty;
    fDevice: TDeviceTypeList;
    function GetMax_Device: integer;
    procedure SetMax_Device(const Value: integer);
    function GetNoLoopDevices: integer;
    function GetNotFittedFullName: string;
    procedure SetNotFittedFullName(const pValue: string);
    function GetUnknownShortName: string;
    procedure SetUnknownShortName(const pValue: string);
    function GetNotFittedShortName: string;
    procedure SetNotFittedShortName(const pValue: string);
    function GetDevIndex: integer;
    procedure SetDevIndex(const Value: integer);
    function GetSystemType: TSystemType;
    procedure SetSystemType(const Value: TSystemType);
    function GetGroup: integer;
    procedure SetGroup(const Value: integer);
    function GetAsIOUnit: Boolean;
    procedure SetAsIOUnit(const Value: Boolean);
    function GetUnknownFullName: string;
    procedure SetUnknownFullName(const pValue: string);
	protected

	public
		property Device: TDeviceTypeList
             read fDevice;
    const
      MAX_POINTS_APOLLO = 126;
      MAX_POINTS_SYS_SENSOR = 198;
      HALF_MAX_POINTS_SYS_SENSOR = 99;
      MAX_POINTS_NITTAN = 126;
      cSystemTypeText : Array[ Low( TSystemType ) .. High( TSystemType ) ] of string =
        ('Apollo', 'Sensor', 'Nittan' );

    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
		function IsGroup (Index: integer): Boolean;
		function IsSet (Index: Integer): Boolean;
		function IsZoneSet (Index: integer): Boolean;
		function ShortDeviceName (Index: integer): string;
		function FullDeviceName (Index: integer): string;
		property DevIndex: integer
             read GetDevIndex
             write SetDevIndex;
		property SystemType: TSystemType
             read GetSystemType
             write SetSystemType;
		property Group: integer
             read GetGroup
             write SetGroup;
		property NoLoopDevices: integer
             read GetNoLoopDevices;
		property AsIOUnit: Boolean
             read GetAsIOUnit
             write SetAsIOUnit;
    property Max_Device : integer
             read GetMax_Device
             write SetMax_Device;
    property UnknownFullName : string
             read GetUnknownFullName
             write SetUnknownFullName;
    property NotFittedFullName : string
             read GetNotFittedFullName
             write SetNotFittedFullName;
    property UnknownShortName : string
             read GetUnknownShortName
             write SetUnknownShortName;
    property NotFittedShortName : string
             read GetNotFittedShortName
             write SetNotFittedShortName;
	end;
*)

	TNetwork = class (tSigCompoundProperty)
	private
    FFitted: TSigBooleanProperty;
    FName: TSigSimpleProperty;
    function GetName: string;
    procedure SetName(const pValue: string);
    function GetFitted: Boolean;
    procedure SetFitted(const Value: Boolean);
	public
		property Name: string
             read GetName
             write SetName;
		property Fitted: Boolean
             read GetFitted
             write SetFitted;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
	end;

  TNetworkList = class( TSigObjectArray )
  private
    function GetItem(const Index: integer): tNetwork;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Item[ const Index : integer ] : tNetwork
             read GetItem; default;
  end;


	TRepeaterList = class (TSigCompoundProperty)
	private
		FSegment: TSigIntegerProperty;
		FPanelName: TSigSimpleProperty;
		FRepeater:  TNetworkList;
		FOutput:  TNetworkList;
    function GetMax_Repeater: integer;
    function GetMax_ZonalOutput: integer;
    procedure SetMax_Repeater(const Value: integer);
    procedure SetMax_ZonalOutput(const Value: integer);
    function GetPanelName: string;
    procedure SetPanelName(const pValue: string);
    function GetSegment: integer;
    procedure SetSegment(const Value: integer);
    function GetRepeater(const i: integer): TNetwork;
    function GetOutput(const i: integer): TNetwork;
	public
//		Repeater: array [1..MAX_REPEATER] of TNetwork;
//		Output: array [1..MAX_ZONAL_OUTPUT] of TNetwork;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
		property PanelName: string
             read GetPanelName
             write SetPanelName;
		property Segment: integer
             read GetSegment
             write SetSegment;
    property Max_Repeater : integer
             read GetMax_Repeater
             write SetMax_Repeater;
    property Max_Zonal_Output : integer
             read GetMax_ZonalOutput
             write SetMax_ZonalOutput;
    property Repeater[ const i : integer ] : TNetwork
             read GetRepeater;
    property Output[ const i : integer ] : TNetwork
             read GetOutput;
	end;


implementation


{ TDeviceType }

constructor TDeviceType.Create( pPropertyName : string; pOwner : tSigCompoundProperty  );
begin
  inherited;
  FDevType := TSigIntegerProperty.Create( 'Device Type', self );
  FZone := TSigIntegerProperty.Create( 'Zone', self );
  FHint := TSigSimpleProperty.Create( 'Hint', self );
  FGroup := TSigIntegerProperty.Create ('Group', self );

	DevType := 0;
	Group := 0;
	Hint := '';
	Name := 'Unnamed Point';
	Zone := 1;
end;

function TDeviceType.GetDevType: integer;
begin
  Result := fDevType.ValueAsInt;
end;

function TDeviceType.GetGroup: integer;
begin
  Result := fGroup.ValueAsInt;
end;

function TDeviceType.GetHint: string;
begin
	Result := FHint.Value;
end;

function TDeviceType.GetName: string;
begin
  Result := Value;
end;

function TDeviceType.GetZone: integer;
begin
  Result := fZone.ValueAsInt;
end;

procedure TDeviceType.SetDevType(const pValue: integer);
begin
  fDevType.ValueAsInt := pValue;
end;

procedure TDeviceType.SetGroup(const pValue: integer);
begin
  fGroup.ValueAsInt := pValue;
end;

procedure TDeviceType.SetHint(const pValue: string);
begin
  fHint.Value := pValue;
end;

procedure TDeviceType.SetName(const pValue: string);
begin
  Value := pValue;
end;

procedure TDeviceType.SetZone(const pValue: integer);
begin
  fZone.ValueAsInt := pValue;
end;

{ TGroupList }

constructor TGroupList.Create( pOwner : tSigCompoundProperty );
begin
	inherited Create( 'Group List', pOwner );

  fGroup := tSigObjectArray.Create( 'Groups', self, TSigSimpleProperty );
	fOutputSet := tSigObjectArray.Create( 'Output Set', self, TSigSimpleProperty );
  fOutput_Set_Zero_Name := TSigSimpleProperty.Create( 'Set Zero Name', self );
  fGroup_Zero_Name := TSigSimpleProperty.Create( 'Group Zero Name', self );
  fGroup_DefaultNamePrefix := TSigSimpleProperty.Create( 'Group Default Name Prefix', self );
  fOutputSet_DefaultNamePrefix := TSigSimpleProperty.Create( 'Output set Default Name Prefix', self );

  Group_Zero_Name := 'No group allocated';
  Group_DefaultNamePrefix := 'Group';
  Max_Group := 15;

  Output_Set_Zero_Name := 'No set allocated';
  OutputSet_DefaultNamePrefix := 'Set';
  Max_OutputSet := 32;

(*
	{ Create a group object for all groups, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_GROUP do begin
//			Group[Index] := TGroup.Create;
			Group[Index].Name := 'Group ' + IntToStr (Index);
		end;
	{ Create a set object for all sets, but not when in design mode }
    for Index := 0 to MAX_ZONE do begin
//			OutputSet[Index] := TGroup.Create;
			OutputSet[Index].Name := 'Set ' + IntToStr (Index);
		end;

		{ Rename group 0 }
		Group[0].Name := GROUP_ZERO_NAME;
		OutputSet[0].Name := OUTPUT_SET_ZERO_NAME;
	end;
*)
end;

function TGroupList.GetGroup(const i : integer ): string;
begin
  Result := fGroup.Entry[ i ].Value;
end;

function TGroupList.GetGroup_DefaultNamePrefix: string;
begin
  Result := fGroup_DefaultNamePrefix.Value;
end;

function TGroupList.GetGroup_Zero_Name: string;
begin
  Result := fGroup_Zero_Name.Value;
end;

function TGroupList.GetMax_Group: integer;
begin
  Result := fGroup.Max;
end;

function TGroupList.GetMax_OutputSet: integer;
begin
  Result := fOutputSet.Max;
end;

function TGroupList.GetOutputSet(const i: integer): string;
begin
  Result := fOutputSet.Entry[ i ].Value;
end;

function TGroupList.GetOutputSet_DefaultNamePrefix: string;
begin
  Result := fOutputSet_DefaultNamePrefix.Value;
end;

function TGroupList.GetOutput_Set_Zero_Name: string;
begin
  Result := fOutput_Set_Zero_Name.Value;
end;

procedure TGroupList.SetGroup(const i : integer; const pValue: string);
begin
  fGroup.Entry[ i ].Value := pValue;
end;

procedure TGroupList.SetGroup_DefaultNamePrefix(const pValue: string);
begin
  fGroup_DefaultNamePrefix.Value := pValue;
end;

procedure TGroupList.SetGroup_Zero_Name(const pValue: string);
begin
  fGroup_Zero_Name.Value := pValue;
  if fGroup.Max >= 0 then
  begin
    fGroup.Entry[ 0 ].Value := pValue;
  end;
end;

procedure TGroupList.SetMax_Group(const Value: integer);
var
  i, iFrom : integer;
begin
  {
    we do not set up elements of Group until default states have been read.
    This means that during reading of properties, default values might
    not be correct - they might be read later, so we delay constructing
    elements until later, see Loaded routine
  }
  iFrom := fGroup.Count;
  fGroup.Max := Value;
  if iFrom = 0 then
  begin
    fGroup.Entry[ 0 ].Value := Group_Zero_Name;
    inc( iFrom );
  end;
  for i := iFrom to Value do
  begin
    fGroup.Entry[ i ].Value := Group_DefaultNamePrefix + ' ' + IntToStr( i );
  end;
end;

procedure TGroupList.SetMax_OutputSet(const Value: integer);
var
  i, iFrom : integer;
begin
  {
    we do not set up elements of Group until default states have been read.
    This means that during reading of properties, default values might
    not be correct - they might be read later, so we delay constructing
    elements until later, see Loaded routine
  }
  iFrom := fOutputSet.Max;
  fOutputSet.Max := Value;
  if iFrom = 0 then
  begin
    fOutputSet.Entry[ iFrom ].Value := Output_Set_Zero_Name;
    inc( iFrom );
  end;
  for i := iFrom to Value do
  begin
    fOutputSet.Entry[ i ].Value := OutputSet_DefaultNamePrefix + ' ' + IntToStr( i );
  end;
end;

procedure TGroupList.SetOutputSet(const i: integer; const pValue: string);
begin
  fOutputSet.Entry[ i ].Value := pValue;
end;

procedure TGroupList.SetOutputSet_DefaultNamePrefix(const pValue: string);
begin
  fOutputSet_DefaultNamePrefix.Value := pValue;
end;

procedure TGroupList.SetOutput_Set_Zero_Name(const pValue: string);
begin
  fOutput_Set_Zero_Name.Value := pValue;
end;

{ TZoneList }

(*
constructor TZoneList.Create(AOwner: TComponent);
var
	Index: integer;
begin
	inherited;
  Zone := TZoneObjectList.Create;

  Max_Zone := 32;

	{ Create a zone object for all zones, but not when in design mode }
	if not (csDesigning in ComponentState) then begin
		for Index := 0 to MAX_ZONE do begin
//			Zone[Index] := TZone.Create;
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
*)

constructor TZoneList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, TZone );
//  ArrayElementCreationText := 'Object Zone';
  Max_Zone := 32;
end;

function TZoneList.CreateChild(const pPropertyText, pIndexText, pValue,
  pComment: string; pErrors: tErrorList; pErrorLine : integer; pErrorPos : integer): tSigBaseProperty;
var
  iZone : TZone;
begin
  Result := inherited CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors, pErrorLine, pErrorPos );
  if Result is TZone then
  begin
    iZone := Result as TZone;
    iZone.SounderDelay := 10;
    iZone.RemoteDelay := 10;
    iZone.Detector := false;
    iZone.MCP := false;
    Result := iZone;
  end;
{
  if SameText(pPropertyText, ArrayElementCreationText) then
  begin
    iZone := TZone.Create( ArrayElementCreationText, pIndexText, self );
    if pValue <> '' then
    begin
      iZone.Name := pValue;
    end
    else if pIndexText = '0' then
    begin
      iZone.Name := ZONE_ZERO_NAME;
    end
    else
    begin
      iZone.Name := 'Zone ' + pIndexText;
    end;
    iZone.SounderDelay := 10;
    iZone.RemoteDelay := 10;
    iZone.Detector := false;
    iZone.MCP := false;
    Result := iZone;
  end
  else
  begin
    Result := inherited CreateChild( pPropertyText, pIndexText, pValue, pComment, pErrors );
  end;
}
end;

function TZoneList.GetMax_Zone: integer;
begin
  Result := Max;
end;

function TZoneList.GetZone(const i: integer): TZone;
begin
  Result := Entry[ i ] as TZone;
end;

procedure TZoneList.SetMax_Zone(const Value: integer);
begin
  Max := Value;
end;

{ TAFPLoop }

(*
constructor TAFPLoop.Create( pPropertyName : string; pOwner : tSigCompoundProperty  );
begin
	inherited;
  fDevice := tDeviceTypeList.Create( 'Device', self );
  Max_Device := 255;

  fUnknownFullName := tSigSimpleProperty.Create( 'Unknown Full Name', self );
  fUnknownShortName := tSigSimpleProperty.Create( 'Unknown Short Name', self );
  FDevIndex := TSigIntegerProperty.Create( 'Device Index', self );
  FSystemType := TSigSimpleProperty.Create( 'System Type', self );
  FGroup := TSigIntegerProperty.Create( 'Group', self );
  FAsIOUnit := TSigBooleanProperty.Create( 'As IO Unit', self );
  fNotFittedShortName := tSigSimpleProperty.Create( 'Not Fitted Short Name', self );
  fNotFittedFullName := tSigSimpleProperty.Create( 'Not Fitted Full Name', self );

  NotFittedFullName := 'Not Fitted';
  NotFittedShortName := 'N/Fitted';

	{ Create device type for each index of loop }
{
	if not (csDesigning in ComponentState) then begin
		for i := 1 to MAX_DEVICE do Device[i] := TDeviceType.Create;
	end;
}
end;

function TAFPLoop.FullDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin
	if Index = 0 then
  begin
		Result := NotFittedFullName;
  end
	else
  begin
    Result := UnknownFullName;
    case SystemType of
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
				end;
			end;
		end;
  end;
end;

function TAFPLoop.GetAsIOUnit: Boolean;
begin
  Result := FAsIOUnit.ValueAsBool;
end;

function TAFPLoop.GetDevIndex: integer;
begin
  Result := FDevIndex.ValueAsInt;
end;

function TAFPLoop.GetGroup: integer;
begin
  Result := FGroup.ValueAsInt;
end;

function TAFPLoop.GetMax_Device: integer;
begin
  Result := Device.Max_Device;
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

function TAFPLoop.GetNotFittedFullName: string;
begin
  Result := fNotFittedFullName.Value;
end;

function TAFPLoop.GetNotFittedShortName: string;
begin
  Result := fNotFittedShortName.Value;
end;

function TAFPLoop.GetSystemType: TSystemType;
var
  i : TSystemType;
begin
  for i := Low( TSystemType ) to High( TSystemType ) do
  begin
    if AnsiSameText( cSystemTypeText[ i ], FSystemType.Value) then
    begin
      Result := i;
      exit;
    end;
  end;
  // else
  Result := stApolloLoop;
end;

function TAFPLoop.GetUnknownFullName: string;
begin
  Result := fUnknownFullName.Value;
end;

function TAFPLoop.GetUnknownShortName: string;
begin
  Result := fUnknownShortName.Value;
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

procedure TAFPLoop.SetAsIOUnit(const Value: Boolean);
begin
  FAsIOUnit.ValueAsBool := Value;
end;

procedure TAFPLoop.SetDevIndex(const Value: integer);
begin
  FDevIndex.ValueAsInt := Value;
end;

procedure TAFPLoop.SetGroup(const Value: integer);
begin
  FGroup.ValueAsInt := Value;
end;

procedure TAFPLoop.SetMax_Device(const Value: integer);
begin
  Device.Max_Device := Value;
end;

procedure TAFPLoop.SetNotFittedFullName(const pValue: string);
begin
  fNotFittedFullName.Value := pValue;
end;

procedure TAFPLoop.SetNotFittedShortName(const pValue: string);
begin
  fNotFittedShortName.Value := pValue;
end;

procedure TAFPLoop.SetSystemType(const Value: TSystemType);
begin
  FSystemType.Value := cSystemTypeText[ Value ];
end;

procedure TAFPLoop.SetUnknownFullName(const pValue: string);
begin
  fUnknownFullName.Value := pValue;
end;

procedure TAFPLoop.SetUnknownShortName(const pValue: string);
begin
  fUnknownShortName.Value := pValue;
end;

function TAFPLoop.ShortDeviceName(Index: integer): string;
{ This function determines the abbreviated name of the device }
begin
	if Index = 0 then
  begin
		Result := NotFittedShortName;
  end
	else
  begin
    Result := UnknownShortName;
    case SystemType of
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
				end;
			end;
		end;
  end;
end;
*)

{ TRepeaterList }

constructor TRepeaterList.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
	inherited;

	fRepeater:=  TNetworkList.Create( 'Repeaters', self );
  fOutput :=  TNetworkList.Create( 'Outputs', self );
  FPanelName := TSigSimpleProperty.Create( 'Panel Name', self );
  FSegment := TSigIntegerProperty.Create( 'Segment', self );

  Max_Repeater := 15;
  Max_Zonal_Output := 15;

(*
	{ Set up memory for each repeater object }
	for i := 1 to MAX_REPEATER do
  begin
		Repeater[i] := TNetwork.Create;
		Output[i] := TNetwork.Create;
	end;
*)
	{ Default Segment number to 1 }
	Segment := 1;
	PanelName := 'Main Panel';
end;

function TRepeaterList.GetMax_Repeater: integer;
begin
//		Repeater: array [1..MAX_REPEATER] of TNetwork;
//		Output: array [1..MAX_ZONAL_OUTPUT] of TNetwork;
  Result := FRepeater.Max;
end;

function TRepeaterList.GetMax_ZonalOutput: integer;
begin
  Result := FOutput.Max;
end;

function TRepeaterList.GetOutput(const i: integer): TNetwork;
begin
  Result := fOutput.Item[ i ];
end;

function TRepeaterList.GetPanelName: string;
begin
  Result := FPanelName.Value;
end;

function TRepeaterList.GetRepeater(const i: integer): TNetwork;
begin
  Result := FRepeater.Item[ i ];
end;

function TRepeaterList.GetSegment: integer;
begin
  Result := FSegment.ValueAsInt;
end;

procedure TRepeaterList.SetMax_Repeater(const Value: integer);
begin
  FRepeater.Max := Value;
end;

procedure TRepeaterList.SetMax_ZonalOutput(const Value: integer);
begin
  FOutput.Max := Value;
end;

procedure TRepeaterList.SetPanelName(const pValue: string);
begin
  FPanelName.Value := pValue;
end;

procedure TRepeaterList.SetSegment(const Value: integer);
begin
  FSegment.ValueAsInt := Value;
end;

{ TSiteConfig }

(*
constructor TSiteConfig.Create (AOwner: TComponent);
var
  i: Integer;
begin
	inherited;
	{ Initialise variables }
	MainVersion := '';
	MaintenanceDate := Date;
	FaultLockOut := 10;
	PhasedDelay := 10;
	MaintenanceString := 'ANALOGUE FIRE PANEL - AFP';
  fClientAddress := tStringList.Create;
  fInstallerAddress := tStringList.Create;
  for i := 1 to 5 do
  begin
    ClientAddress.Add( '' );  // give 5 lines minimum
    InstallerAddress.Add( '' );  // give 5 lines minimum
  end;
end;

destructor TSiteConfig.Destroy;
begin
  fClientAddress.Free;
  fInstallerAddress.Free;
  inherited;
end;

constructor TSiteConfig.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
var
  i: Integer;
begin
  inherited;
  FDateEnabled := tSigBooleanProperty.Create( 'Date Enabled', self );
  FSoundersPulsed := TSigBooleanProperty.Create( 'Sounders Pulsed', self );
  FCopyTime := TSigBooleanProperty.Create( 'Copy Time', self );
  FFaultLockout := tSigIntegerProperty.Create( 'Fault Lockout', self );
  FPhasedDelay := tSigIntegerProperty.Create( 'Phased Delay', self );
  FPanelLocation := tSigSimpleProperty.Create( 'Panel Location', self);
  FEngineerNo := tSigSimpleProperty.Create( 'Engineer No', self );
  FMaintenanceString := tSigSimpleProperty.Create('Maintenance String', self);
  FEngineer := tSigSimpleProperty.Create( 'Engineer', self );
  FMaintenanceDate := tSigDateTimeProperty.Create( 'Maintenance Date', self );
  FAL3Code := tSigSimpleProperty.Create( 'AL3 Code', self );
  FAL2Code := tSigSimpleProperty.Create( 'AL2 Code', self );
  FClientName := tSigSimpleProperty.Create( 'Client Name', self );
  FLoop1 := tSigSimpleProperty.Create( 'Loop 1', self );
  FLoop2 := tSigSimpleProperty.Create( 'Loop 2', self );
  FFrontPanel := tSigSimpleProperty.Create( 'Front Panel', self );
  FMainVersion := tSigSimpleProperty.Create( 'Firmware Version', self );
  FInstaller := tSigSimpleProperty.Create( 'Installer', self );
  fClientAddress := tMemoProperty.Create( 'Client Address', self );
  fInstallerAddress := tMemoProperty.Create( 'Installer Address', self );

	MainVersion := '';
	MaintenanceDate := Date;
	FaultLockOut := 10;
	PhasedDelay := 10;
	MaintenanceString := 'ANALOGUE FIRE PANEL - AFP';
  for i := 1 to 5 do
  begin
    fClientAddress.Add( '' );
    fInstallerAddress.Add( '' );
  end;
end;

function TSiteConfig.GetAL2Code: string;
begin
  Result := FAL2Code.Value;
end;

function TSiteConfig.GetAL3Code: string;
begin
  Result := FAL3Code.Value;
end;

function TSiteConfig.GetClientAddress1: string;
begin
  Result := ClientAddress[ 0 ];
end;

function TSiteConfig.GetClientAddress2: string;
begin
  Result := ClientAddress[ 1 ];
end;

function TSiteConfig.GetClientAddress3: string;
begin
  Result := ClientAddress[ 2 ];
end;

function TSiteConfig.GetClientAddress4: string;
begin
  Result := ClientAddress[ 3 ];
end;

function TSiteConfig.GetClientAddress5: string;
begin
  Result := ClientAddress[ 4 ];
end;

function TSiteConfig.GetClientName: string;
begin
  Result := FClientName.Value;
end;

function TSiteConfig.GetCopyTime: Boolean;
begin
  Result := fCopyTime.ValueAsBool;
end;

function TSiteConfig.GetDateEnabled: Boolean;
begin
  Result := FDateEnabled.ValueAsBool;
end;

function TSiteConfig.GetEngineer: string;
begin
  Result := fEngineer.Value;
end;

function TSiteConfig.GetEngineerNo: string;
begin
  Result := FEngineerNo.Value;
end;

function TSiteConfig.GetFaultLockout: integer;
begin
  Result := FFaultLockout.ValueAsInt;
end;

function TSiteConfig.GetFrontPanel: string;
begin
  Result := FFrontPanel.Value;
end;

function TSiteConfig.GetInstaller: string;
begin
  Result := fInstaller.Value;
end;

function TSiteConfig.GetInstallerAddress1: string;
begin
  Result := InstallerAddress[ 0 ];
end;

function TSiteConfig.GetInstallerAddress2: string;
begin
  Result := InstallerAddress[ 1 ];
end;

function TSiteConfig.GetInstallerAddress3: string;
begin
  Result := InstallerAddress[ 2 ];
end;

function TSiteConfig.GetInstallerAddress4: string;
begin
  Result := InstallerAddress[ 3 ];
end;

function TSiteConfig.GetInstallerAddress5: string;
begin
  Result := InstallerAddress[ 4 ];
end;

function TSiteConfig.GetLoop1: string;
begin
  Result := FLoop1.Value;
end;

function TSiteConfig.GetLoop2: string;
begin
  Result := FLoop2.Value;
end;

function TSiteConfig.GetMaintenanceDate: TDateTime;
begin
  Result := FMaintenanceDate.ValueAsDateTime;
end;

function TSiteConfig.GetMaintenanceString: string;
begin
  Result := FMaintenanceString.Value;
end;

function TSiteConfig.GetMainVersion: string;
begin
	Result := FMainVersion.Value;
//	if Result = '' then Result := '00A00';
end;

function TSiteConfig.GetOnVersionChange: tSigOnChange;
begin
  Result := FMainVersion.OnChange;
end;

function TSiteConfig.GetPanelLocation: string;
begin
  Result := FPanelLocation.Value;
end;

function TSiteConfig.GetPhasedDelay: integer;
begin
  result := FPhasedDelay.ValueAsInt;
end;

function TSiteConfig.GetSoundersPulsed: Boolean;
begin
  Result := FSoundersPulsed.ValueAsBool;
end;

procedure TSiteConfig.SetAL2Code(const pValue: string);
begin
  FAL2Code.Value := pValue;
end;

procedure TSiteConfig.SetAL3Code(const pValue: string);
begin
  FAL3Code.Value := pValue;
end;

procedure TSiteConfig.SetClientAddress1(const Value: string);
begin
  ClientAddress[ 0 ] := Value;
end;

procedure TSiteConfig.SetClientAddress2(const Value: string);
begin
  ClientAddress[ 1 ] := Value;
end;

procedure TSiteConfig.SetClientAddress3(const Value: string);
begin
  ClientAddress[ 2 ] := Value;
end;

procedure TSiteConfig.SetClientAddress4(const Value: string);
begin
  ClientAddress[ 3 ] := Value;
end;

procedure TSiteConfig.SetClientAddress5(const Value: string);
begin
  ClientAddress[ 4 ] := Value;
end;

procedure TSiteConfig.SetClientName(const pValue: string);
begin
  FClientName.Value := pValue;
end;

procedure TSiteConfig.SetCopyTime(const pValue: Boolean);
begin
  fCopyTime.ValueAsBool := pValue;
end;

procedure TSiteConfig.SetDateEnabled(const pValue: Boolean);
begin
  FDateEnabled.ValueAsBool := pValue;
end;

procedure TSiteConfig.SetEngineer(const pValue: string);
begin
  fEngineer.Value := pValue;
end;

procedure TSiteConfig.SetEngineerNo(const pValue: string);
begin
  FEngineerNo.Value := pValue;
end;

procedure TSiteConfig.SetFaultLockout(const pValue: integer);
begin
  FFaultLockout.ValueAsInt := pValue;
end;

procedure TSiteConfig.SetFrontPanel(const pValue: string);
begin
  FFrontPanel.Value := pValue;
end;

procedure TSiteConfig.SetInstaller(const pValue: string);
begin
  FInstaller.Value := pValue;
end;

procedure TSiteConfig.SetInstallerAddress1(const Value: string);
begin
  InstallerAddress[ 0 ] := Value;
end;

procedure TSiteConfig.SetInstallerAddress2(const Value: string);
begin
  InstallerAddress[ 1 ] := Value;
end;

procedure TSiteConfig.SetInstallerAddress3(const Value: string);
begin
  InstallerAddress[ 2 ] := Value;
end;

procedure TSiteConfig.SetInstallerAddress4(const Value: string);
begin
  InstallerAddress[ 3 ] := Value;
end;

procedure TSiteConfig.SetInstallerAddress5(const Value: string);
begin
  InstallerAddress[ 4 ] := Value;
end;

procedure TSiteConfig.SetLoop1(const pValue: string);
begin
  FLoop1.Value := pValue;
end;

procedure TSiteConfig.SetLoop2(const pValue: string);
begin
  FLoop2.Value := pValue;
end;

procedure TSiteConfig.SetMaintenanceDate(const pValue: TDateTime);
begin
  FMaintenanceDate.ValueAsDateTime := pValue;
end;

procedure TSiteConfig.SetMaintenanceString(const pValue: string);
begin
  FMaintenanceString.Value := pValue;
end;

procedure TSiteConfig.SetMainVersion(const pValue: string);
begin
  FMainVersion.Value := pValue;
end;

procedure TSiteConfig.SetOnVersionChange(const Value: tSigOnChange);
begin
  FMainVersion.OnChange := Value;
end;

procedure TSiteConfig.SetPanelLocation(const pValue: string);
begin
  FPanelLocation.Value := pValue;
end;

procedure TSiteConfig.SetPhasedDelay(const pValue: integer);
begin
  FPhasedDelay.ValueAsInt := pValue;
end;

procedure TSiteConfig.SetSoundersPulsed(const pValue: Boolean);
begin
  FSoundersPulsed.ValueAsBool := pValue;
end;
*)

{ TZone }

constructor TZone.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited;
  FName := TSigSimpleProperty.Create( 'Name', self);
  FMCP := TSigBooleanProperty.Create( 'MCP', self );
  FDetector := TSigBooleanProperty.Create( 'Detector', self );
  FNonFire := TSigBooleanProperty.Create( 'Non-Fire', self );
  FRemoteDelay := TSigIntegerProperty.Create( 'Remote Delay', self );
  FSounderDelay := TSigIntegerProperty.Create( 'Sounder Delay', self );
  FGroup := TSigByteArray.Create( 'Group', self );
  FCCTS := TSigByteArray.Create( 'CCTS', self );
  FZoneSet := tSigBooleanArray.Create( 'Zone Set', self );
  Max_Zone := 32;
  Max_CCTS := 4;
end;

function TZone.GetCCTS(const i: integer): byte;
begin
  Result := FCCTS[ i ];
end;

function TZone.GetDetector: Boolean;
begin
  Result := FDetector.ValueAsBool;
end;

function TZone.GetGroup(const i: integer): byte;
begin
  Result := FGroup[ i ];
end;

function TZone.GetMax_CCTS: integer;
begin
  Result := FCCTS.Max;
end;

function TZone.GetMax_Zone: integer;
begin
  Result := FZoneSet.Max;
end;

function TZone.GetMCP: Boolean;
begin
  Result := FMCP.ValueAsBool;
end;

function TZone.GetName: string;
begin
  Result := FName.Value;
end;

function TZone.GetNonFire: Boolean;
begin
  Result := FNonFire.ValueAsBool;
end;

function TZone.GetRemoteDelay: integer;
begin
  Result := FRemoteDelay.ValueAsInt;
end;

function TZone.GetSounderDelay: integer;
begin
  Result := FSounderDelay.ValueAsInt;
end;

function TZone.GetZoneSet(const i: integer): boolean;
begin
  Result := FZoneSet[ i ];
end;

procedure TZone.SetCCTS(const i: integer; const Value: byte);
begin
  FCCTS[ i ] := Value;
end;

procedure TZone.SetDetector(const pValue: Boolean);
begin
  FDetector.ValueAsBool := pValue;
end;

procedure TZone.SetGroup(const i: integer; const Value: byte);
begin
  FGroup[ i ] := Value;
end;

procedure TZone.SetMax_CCTS(const Value: integer);
begin
  FCCTS.Max := Value + 1;
end;

procedure TZone.SetMax_Zone(const Value: integer);
begin
  FZoneSet.Max := Value + 1;
  FGroup.Max := Value + 1;
end;

procedure TZone.SetMCP(const pValue: Boolean);
begin
  FMCP.ValueAsBool := pValue;
end;

procedure TZone.SetName(const pValue: string);
begin
  FName.Value := pValue;
end;

procedure TZone.SetNonFire(const pValue: Boolean);
begin
  FNonFire.ValueAsBool := pValue;
end;

procedure TZone.SetRemoteDelay(const pValue: integer);
begin
  FRemoteDelay.ValueAsInt := pValue;
end;

procedure TZone.SetSounderDelay(const pValue: integer);
begin
  FSounderDelay.ValueAsInt := pValue;
end;

procedure TZone.SetZoneSet(const i: integer; const Value: boolean);
begin
  FZoneSet[ i ] := Value;
end;

{ TDeviceTypeList }

constructor TDeviceTypeList.Create( pPropertyName : string; pOwner : tSigCompoundProperty  );
begin
  inherited Create( pPropertyName, pOwner, TDeviceType );
end;

function TDeviceTypeList.GetItem(const Index: integer): tDeviceType;
begin
  Result := Entry[ index ] as tDeviceType;
end;

function TDeviceTypeList.GetMax_Device: integer;
begin
  Result := Max;
end;

procedure TDeviceTypeList.SetMax_Device(const pValue: integer);
begin
  Max := pValue;
end;

{ TNetworkList }

constructor TNetworkList.Create( pPropertyName : string; pOwner : tSigCompoundProperty  );
begin
  inherited Create( pPropertyName, pOwner, TNetwork );
end;

function TNetworkList.GetItem(const Index: integer): tNetwork;
begin
  Result := Entry[ index ] as tNetwork;
end;

{ TNetwork }

constructor TNetwork.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  FFitted := TSigBooleanProperty.Create( 'Fitted', self );
  FName := TSigSimpleProperty.Create( 'Name', self );
end;

function TNetwork.GetFitted: Boolean;
begin
  Result := FFitted.ValueAsBool;
end;

function TNetwork.GetName: string;
begin
  Result := FName.Value;
end;

procedure TNetwork.SetFitted(const Value: Boolean);
begin
  FFitted.ValueAsBool := Value;
end;

procedure TNetwork.SetName(const pValue: string);
begin
  FName.Value := pValue;
end;

end.
