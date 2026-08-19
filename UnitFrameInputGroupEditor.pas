unit UnitFrameInputGroupEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitFrameGlobalObjectEditor,
  Vcl.ImgList, SigGeneralGrid, SigVariableEditorList, Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls,
  System.UITypes,
  UnitDeviceEditorHelper,
  UnitObjectEditorHelper,
  UnitPCCfgFile,
  //SigNETStringGrid,
  //SigNET.TStringGrid,
  Vcl.Buttons, Vcl.StdCtrls, UnitFrameErrorList, Vcl.Menus,
  SigPanel, System.ImageList;

type
  TFrameInputGroupEditor = class(TFrameGlobalObjectEditor)
    TabSheetModalOverides2: TTabSheet;
    TabControlIGModalOverrides2: TTabControl;
    SigVariableEditorListIGModalOverrides2: TSigVariableEditorList;
    TabSheetDevices: TTabSheet;
    PanelDevices: TPanel;
    SpeedButtonMirrorToOGs: TSpeedButton;
    PanelDeviceOptions: TPanel;
    SpeedButtonIncludeSelectionIn: TSpeedButton;
    ImageListDevicesSelected: TImageList;
    TabSheetDisablements: TTabSheet;
    TabSheetIGFaults: TTabSheet;
    SigPanel1: TSigPanel;
    PageControlIGDisablements: TPageControl;
    TabSheetDisablementDevices: TTabSheet;
    TabSheetIGDisablementObjects: TTabSheet;
    SigPanel2: TSigPanel;
    StringGridIGDisablementDevices: TStringGrid;
    StringGridIGFaultsDevices: TStringGrid;
    StringGridIGDisablementOthers: TStringGrid;
    procedure FrameResize(Sender: TObject);
  public
    StringGridDevices: TStringGrid;
  private
    fOnIncludeSelectionIn: tIncludeSelectionIn;
    fDeviceEditorHelper: tDeviceEditorHelper;
    fObjectEditorHelper: tObjectEditorHelper;
    fObjectsImageList: TImageList;

    function GetOnMirrorToOGs: tNotifyEvent;
    procedure SetOnMirrorToOGs(const Value: tNotifyEvent);
    procedure SetOnIncludeSelectionIn(const Value: tIncludeSelectionIn);
    procedure SetObjectsImageList(const Value: TImageList);
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearDevices( const pGrid : TSigNETStringGrid );
    procedure ClearObjects( const pGrid : TSigNETStringGrid );
    procedure AddDevice( const pPanel, pLoop, pPos, pSubDevice, pImageIndex : integer; const pName : string;
              pDevice : tObject );
    procedure AddObject( const pImageIndex : integer; const pName : string; const pID : integer; pObject : tObject );
    procedure SelectSubdevice( pSubdevice : tObject );

    property OnIncludeSelectionIn : tIncludeSelectionIn
             read fOnIncludeSelectionIn
             write SetOnIncludeSelectionIn;
    property DeviceEditorHelper : tDeviceEditorHelper
             read fDeviceEditorHelper;
    property ObjectEditorHelper : tObjectEditorHelper
             read fObjectEditorHelper;

    property OnMirrorToOGs : tNotifyEvent
             read GetOnMirrorToOGs
             write SetOnMirrorToOGs;
    property ObjectsImageList : TImageList
             read fObjectsImageList
             write SetObjectsImageList;
  end;

var
  FrameInputGroupEditor: TFrameInputGroupEditor;

implementation

{$R *.dfm}

procedure TFrameInputGroupEditor.AddDevice(const pPanel, pLoop, pPos, pSubDevice,
  pImageIndex: integer; const pName: string; pDevice : tObject);
begin
  fDeviceEditorHelper.AddDevice( pPanel, pLoop, pPos, pSubDevice, pImageIndex, pName, pDevice );
end;

procedure TFrameInputGroupEditor.AddObject(const pImageIndex: integer;
  const pName: string; const pID: integer; pObject: tObject);
begin
  fObjectEditorHelper.AddObject( pImageIndex, pName, pID, pObject );
end;

procedure TFrameInputGroupEditor.ClearDevices( const pGrid : TSigNETStringGrid );
begin
  fDeviceEditorHelper.SigNETStringGridDevices := pGrid;
  fDeviceEditorHelper.ClearDevices;
end;

procedure TFrameInputGroupEditor.ClearObjects(const pGrid: TSigNETStringGrid);
begin
  fObjectEditorHelper.SigNETStringGridObjects := pGrid;
  fObjectEditorHelper.ClearObjects;
end;

constructor TFrameInputGroupEditor.Create(AOwner: TComponent);
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

  fObjectEditorHelper := tObjectEditorHelper.Create;
  fObjectEditorHelper.ImageListObjectsSelected := self.ImageListDevicesSelected;

end;

destructor TFrameInputGroupEditor.Destroy;
begin
  fDeviceEditorHelper.Free;

  inherited;
end;

procedure TFrameInputGroupEditor.FrameResize(Sender: TObject);
begin
  inherited;
  // set up  component grid
  fDeviceEditorHelper.SetupGrid;
end;

function TFrameInputGroupEditor.GetOnMirrorToOGs: tNotifyEvent;
begin
  Result := SpeedButtonMirrorToOGs.OnClick;
end;

procedure TFrameInputGroupEditor.SelectSubdevice(pSubdevice: tObject);
begin
  fDeviceEditorHelper.SelectSubdevice( pSubDevice );
end;

procedure TFrameInputGroupEditor.SetObjectsImageList(const Value: TImageList);
begin
  fObjectsImageList := Value;
  fObjectEditorHelper.ImageListObjects := Value;
end;

procedure TFrameInputGroupEditor.SetOnIncludeSelectionIn(
  const Value: tIncludeSelectionIn);
begin
  fOnIncludeSelectionIn := Value;
  fDeviceEditorHelper.OnIncludeSelectionIn := Value;
end;

procedure TFrameInputGroupEditor.SetOnMirrorToOGs(const Value: tNotifyEvent);
begin
  SpeedButtonMirrorToOGs.OnClick := Value;
end;

end.
