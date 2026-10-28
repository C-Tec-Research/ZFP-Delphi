unit UnitFrameOutputGroupEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameGlobalObjectEditor,
  Vcl.ImgList, SigGeneralGrid, SigVariableEditorList, Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls, UnitPCCfgFile, Vcl.StdCtrls, Vcl.Buttons,
  UnitDeviceEditorHelper,
  SigNET.TStringGrid,
  System.UITypes, UnitFrameErrorList, Vcl.Menus, System.ImageList;

type
  TFrameOutputGroupEditor = class(TFrameGlobalObjectEditor)
    TabSheetDevices: TTabSheet;
    PanelDeviceOptions: TPanel;
    SpeedButtonIncludeSelectionIn: TSpeedButton;
    ImageListDevicesSelected: TImageList;
    PanelDevices: TPanel;
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

    procedure Setup; override;
  end;

var
  FrameOutputGroupEditor: TFrameOutputGroupEditor;

implementation

{$R *.dfm}

{ TFrameOutputGroupEditor }

procedure TFrameOutputGroupEditor.AddDevice(const pPanel, pLoop, pPos,
  pSubDevice, pImageIndex: integer; const pName: string; pDevice: tObject);
begin
  fDeviceEditorHelper.AddDevice( pPanel, pLoop, pPos, pSubDevice, pImageIndex, pName, pDevice );
end;

procedure TFrameOutputGroupEditor.ClearDevices;
begin
  fDeviceEditorHelper.ClearDevices;
end;

constructor TFrameOutputGroupEditor.Create(AOwner: TComponent);
begin
  inherited;

  StringGridDevices := TStringGrid.Create( self );
  StringGridDevices.Parent := PanelDevices; //TabSheetDevices;
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

destructor TFrameOutputGroupEditor.Destroy;
begin
  fDeviceEditorHelper.Free;

  inherited;
end;

procedure TFrameOutputGroupEditor.SelectSubdevice(pSubdevice: tObject);
begin
  fDeviceEditorHelper.SelectSubdevice( pSubDevice );
end;

procedure TFrameOutputGroupEditor.SetOnIncludeSelectionIn(
  const Value: tIncludeSelectionIn);
begin
  fOnIncludeSelectionIn := Value;
  fDeviceEditorHelper.OnIncludeSelectionIn := Value;
end;

procedure TFrameOutputGroupEditor.Setup;
begin
  inherited;
  // set up  component grid
  fDeviceEditorHelper.SetupGrid;
end;

end.
