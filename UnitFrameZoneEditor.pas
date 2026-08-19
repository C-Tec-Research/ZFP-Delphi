unit UnitFrameZoneEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameGlobalObjectEditor,
  Vcl.ImgList, SigGeneralGrid, UnitFrameErrorList, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, SigVariableEditorList,
  Vcl.Grids, Vcl.ExtCtrls,
  //SigNETStringGrid,
  SigNET.TStringGrid,
  UnitPCCfgFile,
  UnitDeviceEditorHelper,
  System.Contnrs,
  UITypes, Vcl.Menus, System.ImageList;

type
  tIncludeSelectionIn = procedure( pObjects : tObjectList ) of object;

type
  TFrameZoneEditor = class(TFrameGlobalObjectEditor)
    TabSheetDevices: TTabSheet;
    PanelDevices: TPanel;
    PanelDeviceOptions: TPanel;
    SpeedButtonIncludeSelectionIn: TSpeedButton;
    ImageListDevicesSelected: TImageList;
    procedure FrameResize(Sender: TObject);
  public
    StringGridDevices: TStringGrid;
  private
    { Private declarations }
    fOnIncludeSelectionIn: tIncludeSelectionIn;
    fDeviceEditorHelper: tDeviceEditorHelper;
    procedure SetOnIncludeSelectionIn(const Value: tIncludeSelectionIn);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure ClearDevices;
    procedure AddDevice( const pPanel, pLoop, pPos, pSubDevice, pImageIndex : integer; const pName : string;
              pDevice : tObject );
    procedure SelectSubdevice( pSubdevice : tObject );

    property OnIncludeSelectionIn : tIncludeSelectionIn
             read fOnIncludeSelectionIn
             write SetOnIncludeSelectionIn;
    property DeviceEditorHelper : tDeviceEditorHelper
             read fDeviceEditorHelper;
  end;

var
  FrameZoneEditor: TFrameZoneEditor;

implementation

{$R *.dfm}

{ TFrameZoneEditor }

procedure TFrameZoneEditor.AddDevice(const pPanel, pLoop, pPos, pSubDevice,
  pImageIndex: integer; const pName: string; pDevice : tObject);
begin
  fDeviceEditorHelper.AddDevice( pPanel, pLoop, pPos, pSubDevice, pImageIndex, pName, pDevice );
end;

procedure TFrameZoneEditor.AfterConstruction;
begin
  inherited;

end;

procedure TFrameZoneEditor.ClearDevices;
begin
  fDeviceEditorHelper.ClearDevices;
end;

constructor TFrameZoneEditor.Create(AOwner: TComponent);
begin
  inherited;

  StringGridDevices := TStringGrid.Create( self );
  StringGridDevices.Parent := PanelDevices;
  StringGridDevices.DefaultColWidth := 32;
  StringGridDevices.DefaultRowHeight := 32;
  StringGridDevices.Align := alClient;
  StringGridDevices.TabOrder := 1;

  fDeviceEditorHelper := tDeviceEditorHelper.Create;
  fDeviceEditorHelper.SpeedButtonIncludeSelectionIn := self.SpeedButtonIncludeSelectionIn;
  fDeviceEditorHelper.SigNETStringGridDevices := self.StringGridDevices;
  fDeviceEditorHelper.ImageListDevicesSelected := self.ImageListDevicesSelected;
  fDeviceEditorHelper.PanelDeviceOptions := self.PanelDeviceOptions;

end;

destructor TFrameZoneEditor.Destroy;
begin
  fDeviceEditorHelper.Free;

  inherited;
end;

procedure TFrameZoneEditor.FrameResize(Sender: TObject);
begin
  inherited;
  // set up  component grid
  fDeviceEditorHelper.SetupGrid;
end;

procedure TFrameZoneEditor.SelectSubdevice(pSubdevice: tObject);
begin
  fDeviceEditorHelper.SelectSubdevice( pSubDevice );
end;

procedure TFrameZoneEditor.SetOnIncludeSelectionIn(
  const Value: tIncludeSelectionIn);
begin
  fOnIncludeSelectionIn := Value;
  fDeviceEditorHelper.OnIncludeSelectionIn := Value;
end;

end.
