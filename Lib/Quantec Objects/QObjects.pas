unit QObjects;

interface

uses SysUtils, Classes, Objects,
     Contnrs,
     SigFile,
     UnitPagingMode;
//, AreaEquation;

//type
//	TSystemType = (stApolloLoop, stSysSensorLoop, stNittanLoop);

type
//  tQAreaArray = array [ 0.. 8 ] of integer;
  tQAreaArray = class( tSigIntegerArray )
  private
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    function ValueAsNumericList( const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function ValueAsAlphaList( const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function ValueAsList( const Alpha : boolean; const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function SubList( const Alpha : boolean; const Offset : integer; iFirst, iCurr : integer ) : string;
    function ValueAsNumericColumns( const Offset : integer; const iMin : integer; const IgnoreVal : integer; const Width : integer ) : string;
    function ValueAsAlphaColumns( const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function ValueAsColumns( const Alpha : boolean; const Offset : integer; const iMin : integer; const IgnoreVal : integer; const Width : integer = 1 ) : string;
    function ValueAsNumericItems( const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function ValueAsAlphaItems( const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    function ValueAsItems( const Alpha : boolean; const Offset : integer; const iMin : integer; const IgnoreVal : integer ) : string;
    procedure Clear; override;
  end;

  TQZone = class (TSigCompoundProperty )
	private
		FName: TSigSimpleProperty;
    fMaxEqu: TSigIntegerProperty;
    fAreaEqn: tQAreaArray;
    fDeviceEqn: tQAreaArray;
    procedure SetAreaEqn(const Value: tQAreaArray);
    procedure SetMaxEqu(const Value: integer);
    function GetName: string;
    procedure SetName(const pValue: string);
    function GetMaxEqu: integer;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property AreaEqn:   tQAreaArray
             read fAreaEqn
             write SetAreaEqn;
    property DeviceEqn: tQAreaArray
             read fDeviceEqn;
		property Name: string
             read GetName
             write SetName;
    property MaxEqu : integer
             read GetMaxEqu
             write SetMaxEqu;
    procedure Clear; override;
  end;

  TQZoneObjectList = class( TSigObjectArray )
  private
    function GetItem(const Index: integer): tQZone;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property Item[ const Index : integer ] : tQZone
             read GetItem; default;
  end;

	TQZoneList = class (TSigCompoundProperty)
  private
    fZone: TQZoneObjectList;
    fZoneZeroName : TSigSimpleProperty;
    fDefaultAreaEqu : TSigIntegerProperty;
    fDefaultDevEqu : TSigIntegerProperty;
    FZoneDefaultPrefix: TSigSimpleProperty;
    function GetZoneZeroName: string;
    procedure SetZoneZeroName(const pValue: string);
    procedure SetMax_Zone(const Value: integer);
    function GetDefaultAreaEqu: integer;
    function GetDefaultDevEqu: integer;
    function GetMax_Zone: integer;
    procedure SetDefaultAreaEqu(const Value: integer);
    procedure SetDefaultDevEqu(const Value: integer);
    function GetZoneDefaultPrefix: string;
    procedure SetZoneDefaultPrefix(const pValue: string);
	public
//		Zone: array [0..MAX_ZONE+1] of TQZone;
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
		property Zone:  TQZoneObjectList
             read fZone;
    property Max_Zone : integer
             read GetMax_Zone
             write SetMax_Zone;
    property Zone_Zero_Name : string
             read GetZoneZeroName
             write SetZoneZeroName;
    property ZoneDefaultPrefix : string
             read GetZoneDefaultPrefix
             write SetZoneDefaultPrefix;
    property DefaultAreaEqu : integer
             read GetDefaultAreaEqu
             write SetDefaultAreaEqu;
    property DefaultDevEqu : integer
             read GetDefaultDevEqu
             write SetDefaultDevEqu;
	end;

	TQGroup = class (tSigCompoundProperty)
  private
    fPrimaryArea: tQAreaArray;
    fNightArea: tQAreaArray;
    fDivert: tQAreaArray;
    procedure SetNightArea(const Value: tQAreaArray);
    procedure SetPrimaryArea(const Value: tQAreaArray);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property PrimaryArea : tQAreaArray
             read fPrimaryArea
             write SetPrimaryArea;
    property NightArea   : tQAreaArray
             read fNightArea
             write SetNightArea;
    property Divert      : tQAreaArray
             read fDivert;
	end;

  TQGroupList = class( TSigObjectArray )
  private
    function GetItem(const Index: integer): tQGroup;
    function GetMaxGroup: integer;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property Group[ const Index : integer ] : tQGroup
             read GetItem; default;
    property Max_Group : integer
             read GetMaxGroup;
  end;

  TQDeviceType = class (tSigCompoundProperty)
  private
    FDevType: TSigIntegerProperty;
    FZone: TSigIntegerProperty;
    FTextPtr: TSigIntegerProperty;
    FName: TSigSimpleProperty;
    FHint: TSigSimpleProperty;
    FGroup: TSigIntegerProperty;
    FEnabled: TSigBooleanProperty;
    function GetHint: string;
    procedure SetHint(const pValue: string);
    function GetDevType: integer;
    procedure SetDevType(const Value: integer);
    function GetName: string;
    procedure SetName(const pValue: string);
    function GetZone: integer;
    procedure SetZone(const Value: integer);
    function GetGroup: integer;
    procedure SetGroup(const Value: integer);
    function GetTextPtr: integer;
    procedure SetTextPtr(const Value: integer);
    function GetDeviceEnabled: boolean;
    function GetDeviceEnabledAsChar: char;
    procedure SetDeviceEnabled(const Value: boolean);
    procedure SetEnabledAsChar(const Value: char);
    function GetDeviceEnabledAsInt: integer;
    procedure SetDeviceEnabledAsInt(const Value: integer);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
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
    property TextPtr: integer
             read GetTextPtr
             write SetTextPtr;
    property DeviceEnabled: boolean
             read GetDeviceEnabled
             write SetDeviceEnabled;
    property DeviceEnabledAsChar : char
             read GetDeviceEnabledAsChar
             write SetEnabledAsChar;
    property DeviceEnabledAsInt : integer
             read GetDeviceEnabledAsInt
             write SetDeviceEnabledAsInt;
  end;

  type TQDeviceTypeList = class( tSigObjectArray )
  private
    function GetItem(const Index: integer): TQDeviceType;
    function GetMaxDeviceType: integer;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property Item[ const Index : integer ] : TQDeviceType
             read GetItem; default;
    property Max_Device_Type : integer
             read GetMaxDeviceType;
		function ShortDeviceName (Index: integer): string;
		function FullDeviceName (Index: integer): string;
		function IsArea (Index: Integer): Boolean;
		function IsGroup (Index: integer): Boolean;
		function IsZone (Index: integer): Boolean;
  end;

  TQCustomPlaceNames = class (tSigCompoundProperty)
  private
    function GetName: string;
    procedure SetName(const pValue: string);
  protected
    fName : TSigSimpleProperty;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property Name: string
             read GetName
             write SetName;
  end;

  TDSMCustNames = class( tSigObjectArray )
  protected
    function fGetItems( const index : integer ) : TQCustomPlaceNames;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property Item[ const index : integer ] : TQCustomPlaceNames
             read fGetItems; default;
  end;

const
	MAX_ZONE7A99 = 32;    // version dependant value

implementation


uses
  ImgData;

{ Custom Names }

constructor TDSMCustNames.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited Create( pPropertyName, pOwner, TQCustomPlaceNames );
end;

function TDSMCustNames.fGetItems( const index : integer ) : TQCustomPlaceNames;
begin
  Result := Entry[ index ] as TQCustomPlaceNames;
end;


{ TDeviceType }

constructor TQDeviceType.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited;

  FDevType := TSigIntegerProperty.Create( 'Device Type', self );
  FZone := TSigIntegerProperty.Create( 'Zone', self );
  FTextPtr := TSigIntegerProperty.Create( 'Text Pointer', self );
  FName := TSigSimpleProperty.Create( 'Name', self );
  FHint := TSigSimpleProperty.Create( 'Hint', self );
  FGroup := TSigIntegerProperty.Create( 'Group', self );
  FEnabled := TSigBooleanProperty.Create( 'Enabled', self );

  DevType := 0;
  Group := 0;
  Hint := '';
  Name := '';
  Zone := 1;
  TextPtr := 0;
end;

function TQDeviceType.GetDeviceEnabledAsChar: char;
begin
  if DeviceEnabled then
  begin
    Result := #1;
  end
  else
  begin
    Result := #0;
  end;
end;

function TQDeviceType.GetDeviceEnabledAsInt: integer;
begin
  if DeviceEnabled then
  begin
    Result := 1;
  end
  else
  begin
    Result := 0;
  end;
end;

function TQDeviceType.GetDevType: integer;
begin
  Result := FDevType.ValueAsInt;
end;

function TQDeviceType.GetDeviceEnabled: boolean;
begin
  Result := FEnabled.ValueAsBool;
end;

function TQDeviceType.GetGroup: integer;
begin
  Result := FGroup.ValueAsInt;
end;

function TQDeviceType.GetHint: string;
begin
	Result := FHint.Value;
end;

function TQDeviceType.GetName: string;
begin
  Result := FName.Value;
end;

function TQDeviceType.GetTextPtr: integer;
var
  iOwner : TQuantecSiteFileNew;
begin
  Result := FTextPtr.ValueAsInt;
  iOwner := GetOwnerOfType( TQuantecSiteFileNew ) as TQuantecSiteFileNew;
  if Result > (iOwner.CustomNameCount + ImgData.Data.CfgFile.StandardNameCount) then
  begin
    Result := 0;
  end;
end;

function TQDeviceType.GetZone: integer;
begin
  Result := FZone.ValueAsInt;
end;

procedure TQDeviceType.SetDeviceEnabledAsInt(const Value: integer);
begin
  DeviceEnabled := Value <> 0;
end;

procedure TQDeviceType.SetDevType(const Value: integer);
begin
  FDevType.ValueAsInt := Value;
  DeviceEnabled := Value <> 0;
end;

procedure TQDeviceType.SetDeviceEnabled(const Value: boolean);
begin
  FEnabled.ValueAsBool := Value;
end;

procedure TQDeviceType.SetEnabledAsChar(const Value: char);
begin
  DeviceEnabled := Value <> #0;
end;

procedure TQDeviceType.SetGroup(const Value: integer);
begin
  FGroup.ValueAsInt := Value;
end;

procedure TQDeviceType.SetHint(const pValue: string);
begin
  FHint.Value := pValue;
end;

procedure TQDeviceType.SetName(const pValue: string);
begin
  FName.Value := pValue;
end;

procedure TQDeviceType.SetTextPtr(const Value: integer);
begin
  FTextPtr.ValueAsInt := Value;
end;

procedure TQDeviceType.SetZone(const Value: integer);
begin
  FZone.ValueAsInt := Value;
end;

{ TZoneList }

constructor TQZoneList.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
var
	Index: integer;
  Index1: integer;
begin
	inherited;
  fZone := TQZoneObjectList.Create( 'Zone', self );
  fZoneZeroName := TSigSimpleProperty.Create( 'Zone Zero Name', self );
  fDefaultAreaEqu := TSigIntegerProperty.Create( 'Default Area Eqn', self );
  fDefaultDevEqu := TSigIntegerProperty.Create( 'Default Dev Eqn', self );
  FZoneDefaultPrefix := TSigSimpleProperty.Create( 'Zone Default Prefix', self );

  DefaultAreaEqu := 26;
  DefaultDevEqu := 256;

  fZoneZeroName.Value := 'No Zone Allocated';

  Max_Zone := 32;

  for Index := 0 to MAX_ZONE do
  begin
    Zone[Index].Name := 'Zone ' + IntToStr (Index);
    for Index1 := 0 to 8 do
    begin
      Zone[Index].AreaEqn[Index1] := 26;
      Zone[Index].DeviceEqn[Index1] := 256;
    end;
  end;
		{ Rename zone 0 }
  Zone[0].Name := ZONE_ZERO_NAME;
end;

function TQZoneList.GetDefaultAreaEqu: integer;
begin
  Result := fDefaultAreaEqu.ValueAsInt;
end;

function TQZoneList.GetDefaultDevEqu: integer;
begin
  Result := fDefaultDevEqu.ValueAsInt;
end;

function TQZoneList.GetMax_Zone: integer;
begin
  Result := Zone.Max;
end;

function TQZoneList.GetZoneDefaultPrefix: string;
begin
  Result := FZoneDefaultPrefix.Value;
end;

function TQZoneList.GetZoneZeroName: string;
begin
  Result := fZoneZeroName.Value;
end;

procedure TQZoneList.SetDefaultAreaEqu(const Value: integer);
begin
  fDefaultAreaEqu.ValueAsInt := Value;
end;

procedure TQZoneList.SetDefaultDevEqu(const Value: integer);
begin
  fDefaultDevEqu.ValueAsInt := Value;
end;

procedure TQZoneList.SetMax_Zone(const Value: integer);
begin
  Zone.Max := Value;
end;

procedure TQZoneList.SetZoneDefaultPrefix(const pValue: string);
begin
  FZoneDefaultPrefix.Value := pValue;
end;

procedure TQZoneList.SetZoneZeroName(const pValue: string);
begin
  fZoneZeroName.Value := pValue;
end;

{ tQAreaArray }

procedure tQAreaArray.Clear;
begin
  inherited;
end;

constructor tQAreaArray.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  Max := 8;
end;

{ TQZone }

procedure TQZone.Clear;
begin
  inherited;
end;

constructor TQZone.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited;
  FName := TSigSimpleProperty.Create( 'Name', self );
  fMaxEqu := TSigIntegerProperty.Create( 'Max Equ', self );
  fAreaEqn :=   tQAreaArray.Create( 'Area Eqn', self );
  fDeviceEqn := tQAreaArray.Create( 'Device Eqn', self );

  MaxEqu := 8;
end;


function TQZone.GetMaxEqu: integer;
begin
  Result := fMaxEqu.ValueAsInt;
end;

function TQZone.GetName: string;
begin
  Result := FName.Value;
end;

procedure TQZone.SetAreaEqn(const Value: tQAreaArray);
var
  i: Integer;
begin
  for i := 0 to fAreaEqn.Max do
  begin
    fAreaEqn[ i ] := Value[ i ];
  end;
end;

procedure TQZone.SetMaxEqu(const Value: integer);
begin
  fMaxEqu.ValueAsInt := Value;
  fAreaEqn.Max := Value;
  fDeviceEqn.Max := Value;
end;

procedure TQZone.SetName(const pValue: string);
begin
  FName.Value := pValue;
end;

{ TQGroup }

constructor TQGroup.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited;
  fPrimaryArea := tQAreaArray.Create( 'Primary Area', self );
  fNightArea   := tQAreaArray.Create( 'Night Area', self );
  fDivert      := tQAreaArray.Create( 'Divert', self );

  fPrimaryArea.Max := 8;
  fNightArea.Max := 8;
  fDivert.Max := 8;
end;

procedure TQGroup.SetNightArea(const Value: tQAreaArray);
var
  i: Integer;
begin
  for i := 0 to fNightArea.Max do
  begin
    fNightArea[ i ] := Value[ i ];
  end;
end;

procedure TQGroup.SetPrimaryArea(const Value: tQAreaArray);
var
  i: Integer;
begin
  for i := 0 to fPrimaryArea.Max do
  begin
    fPrimaryArea[ i ] := Value[ i ];
  end;
end;

{ TQZoneObjectList }

constructor TQZoneObjectList.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited Create( pPropertyName, pOwner, TQZone  );
//  fDefaultAreaEqu := 26;
//  fDefaultDevEqu  := 256;
//  fZoneZeroName := 'No zone allocated';
end;

function TQZoneObjectList.GetItem(const Index: integer): tQZone;
begin
  Result := Entry[ index ] as tQZone;
end;

{ TQGroupList }

constructor TQGroupList.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited Create( pPropertyName, pOwner, tQGroup );
end;

function TQGroupList.GetItem(const Index: integer): tQGroup;
begin
  Result := Entry[ index ] as tQGroup;
end;

function TQGroupList.GetMaxGroup: integer;
begin
  Result := MAX;
end;

{ TQDeviceTypeList }

constructor TQDeviceTypeList.Create( pPropertyName : string; pOwner : tSigCompoundProperty );
begin
  inherited Create( pPropertyName, pOwner, TQDeviceType );
end;

function TQDeviceTypeList.FullDeviceName(Index: integer): string;
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

function TQDeviceTypeList.GetItem(const Index: integer): TQDeviceType;
begin
  Result := Entry[ index ] as tQDeviceType;
end;

function TQDeviceTypeList.GetMaxDeviceType: integer;
begin
  Result := Max;
end;

function TQDeviceTypeList.IsArea(Index: Integer): Boolean;
begin
  case Item[ index ].DevType of
    1, 5, 6, 9:
    begin
      Result := TRUE;
    end;
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function TQDeviceTypeList.IsGroup(Index: integer): Boolean;
begin
  case Item[Index].DevType of
    4, 8:
    begin
      Result := TRUE;
    end;
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function TQDeviceTypeList.IsZone(Index: integer): Boolean;
begin
  case Item[ index ].DevType of
    7:
    begin
      Result := TRUE;
    end;
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function TQDeviceTypeList.ShortDeviceName(Index: integer): string;
begin
  { Determine type of device within Apollo loop }
  if Index = 0 then
  begin
    Result := 'Not fitted'
  end
  else
  begin
    case Index of
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
end;

{ TQCustomPlaceNames }

constructor TQCustomPlaceNames.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fName := TSigSimpleProperty.Create( 'Name', self );
end;

function TQCustomPlaceNames.GetName: string;
begin
  Result := fName.Value;
end;

procedure TQCustomPlaceNames.SetName(const pValue: string);
begin
  fName.Value := pValue;
end;

function tQAreaArray.SubList(const Alpha: boolean; const Offset : integer; iFirst,
  iCurr: integer): string;
begin
  inc( iFirst, Offset );
  inc( iCurr, Offset );
  if Alpha then
  begin
    Result := char( iFirst );
  end
  else
  begin
    Result := IntToStr( iFirst );
  end;
  if iCurr <> iFirst then
  begin
    Result := Result + '-';
    if Alpha then
    begin
      Result := Result + char( iCurr );
    end
    else
    begin
      result := Result + IntToStr( iCurr );
    end;
  end;
end;

function tQAreaArray.ValueAsAlphaColumns(const Offset, iMin,
  IgnoreVal: integer): string;
begin
  Result := ValueAsColumns( TRUE, Offset, iMin, IgnoreVal );
end;

function tQAreaArray.ValueAsAlphaItems(const Offset, iMin,
  IgnoreVal: integer): string;
begin
  Result := ValueAsItems( TRUE, Offset, iMin, IgnoreVal );
end;

function tQAreaArray.ValueAsAlphaList(const Offset: integer; const iMin : integer; const IgnoreVal : integer): string;
begin
  Result := ValueAsList( TRUE, Offset, iMin, IgnoreVal );
end;

function tQAreaArray.ValueAsColumns(const Alpha: boolean; const Offset, iMin,
  IgnoreVal, Width: integer): string;
var
  i: Integer;
  s : string;
begin
  Result := '';
  for i := iMin to Max do
  begin
    if Item[ i ] <> IgnoreVal then
    begin
      // add to columnar list
      if Result <> '' then
      begin
        Result := Result + ' ';
      end;
      if Alpha then
      begin
        Result := Result + char( Item[ i ] + OffSet );
      end
      else
      begin
        s := IntToStr( Item[ i ] + Offset );
        while Length( s ) < Width do
        begin
          s := ' ' + s;
        end;
        Result := Result + s;
      end;
    end;
  end;
end;

function tQAreaArray.ValueAsItems(const Alpha: boolean; const Offset, iMin,
  IgnoreVal: integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := iMin to Max do
  begin
    if Item[ i ] <> IgnoreVal then
    begin
      // add to list
      if Result <> '' then
      begin
        Result := Result + ', ';
      end;
      if Alpha then
      begin
        Result := Result + char( Item[ i ] + OffSet );
      end
      else
      begin
        Result := Result + IntToStr( Item[ i ] + Offset );
      end;
    end;
  end;
end;

function tQAreaArray.ValueAsList(const Alpha: boolean; const Offset, iMin,
  IgnoreVal: integer): string;
var
  i, iFirst, iCurr : integer;
begin
  Result := '';
  iCurr  := IgnoreVal;
  iFirst  := IgnoreVal;
  for i := iMin to Max do
  begin
    if iCurr = IgnoreVal then
    begin
      iFirst := Item[ i ];
      iCurr := iFirst;
    end
    else if Item[ i ] = IgnoreVal then
    begin
      // ignore :-)
    end
    else if Item[ i ] = (iCurr + 1) then
    begin
      inc( iCurr );
    end
    else
    begin
      if Result <> '' then
      begin
        Result := Result + ', ';
      end;
      Result := Result + SubList( Alpha, Offset, iFirst, iCurr );
      iFirst := Item[ i ];
      iCurr := Item[ i ];
    end;
  end;
  // Finish list
  if iCurr <> IgnoreVal then
  begin
    if Result <> '' then
    begin
      Result := Result + ', ';
    end;
    Result := Result + SubList( Alpha, Offset, iFirst, iCurr );
  end;
end;

function tQAreaArray.ValueAsNumericColumns(const Offset, iMin, IgnoreVal,
  Width: integer): string;
begin
  Result := ValueAsColumns( FALSE, Offset, iMin, IgnoreVal, Width );
end;

function tQAreaArray.ValueAsNumericItems(const Offset, iMin,
  IgnoreVal: integer): string;
begin
  Result := ValueAsItems( FALSE, Offset, iMin, IgnoreVal );
end;

function tQAreaArray.ValueAsNumericList(const Offset: integer; const iMin : integer; const IgnoreVal : integer): string;
begin
  Result := ValueAsList( FALSE, Offset, iMin, IgnoreVal );
end;

end.
