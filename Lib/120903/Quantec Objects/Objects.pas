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
