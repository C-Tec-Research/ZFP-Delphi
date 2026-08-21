unit UnitABus;

interface

uses
  SigFile;

type
  tABusSubdevice = class( tSigCompoundProperty )
  private
  protected
  public
  end;

  tABusSubDevices = class( tSigObjectList )
  private
    function GetSubDevice(const i: integer): tABusSubDevice;
  protected
  public
    property SubDevice[ const i : integer ] : tABusSubDevice
             read GetSubDevice;
  end;

  tABusDevice = class( tSigCompoundProperty )
  private
    fSubDevices: tABusSubDevices;
    function GetSubDevice(const i: integer): tABusSubDevice;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    property SubDevices : tABusSubDevices
             read fSubDevices;
    property SubDevice[ const i : integer ] : tABusSubDevice
             read GetSubDevice;
  end;

  tABusDevices = class( tSigObjectList )
  private
    function GetDevice(const i: integer): tABusDevice;
    function GetSubDevice(const i: integer): tABusSubDevice;
  protected
  public
    property Device[ const i : integer ] : tABusDevice
             read GetDevice;
    property SubDevice[ const i : integer ] : tABusSubDevice
             read GetSubDevice;
  end;


implementation

{ tABusDevice }

constructor tABusDevice.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fSubDevices := tABusSubDevices.Create( 'Subdevices', self );
end;

function tABusDevice.GetSubDevice(const i: integer): tABusSubDevice;
begin
  Result := SubDevices.SubDevice[ i ];
end;

{ tABusDevices }

function tABusDevices.GetDevice(const i: integer): tABusDevice;
begin
  Result := Entry[ i ] as tABusDevice;
end;

function tABusDevices.GetSubDevice(const i: integer): tABusSubDevice;
var
  j : integer;
  ii : integer;
begin
  ii := i;
  Result := nil;
  for j := 0 to Max do
  begin
    with Device[ i ].SubDevices do
    begin
      if Max <= ii then
      begin
        Result := SubDevice[ ii ];
      end
      else
      begin
        dec( ii, Max + 1 );
      end;
    end;
  end;
end;

{ tABusSubDevices }

function tABusSubDevices.GetSubDevice(const i: integer): tABusSubDevice;
begin
  Result := Entry[ i ] as tABusSubdevice;
end;

end.
