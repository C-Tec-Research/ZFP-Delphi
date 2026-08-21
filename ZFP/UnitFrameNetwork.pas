unit UnitFrameNetwork;

interface

  // This allows us to graphically represent the network.
  // Each panel will appear on a ring.
  // The ring is actually a rounded rectangle which the devices sit on
  // starting at 12 o'clock and moving clockwise.
  // each panel is physically tImage with superimposed name, by default panel n

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  SigImage,
  ImgList, Menus,
  UnitFiles,
  SigFile,
  StdCtrls;

type
  TFrameNetwork = class;

  tNodeType = ( ntPanel, ntRepeater );
  tOnSend = procedure( const pSender : integer ) of object;

  TVisualNode = class
    // a placeholder for all the visual elements for a single node
  private
    fSigImage: TSigImage;
    fNetworkParent: TFrameNetwork;
    fVisible: boolean;
    fTop: integer;
    fLeft: integer;
    fNodeType: tNodeType;
    fTag: integer;
    fParent: tWinControl;
    fLabelNodeNo: tLabel;
    fIndexNo: integer;
    fEditName: tEdit;
    fError: boolean;
    procedure fOnClick( Sender : tObject );
    procedure SetVisible(const Value: boolean);
    procedure SetTop(const Value: integer);
    procedure SetLeft(const Value: integer);
    procedure SetNodeType(const Value: tNodeType);
    procedure SetTag(const Value: integer);
    procedure SetParent(const Value: tWinControl);
    procedure fContextPopup(Sender: TObject; MousePos: TPoint;  var Handled: Boolean);
    procedure fOnNameChange( Sender : tObject );
    procedure SetError(const Value: boolean);
  public
    constructor Create(AOwner: TFrameNetwork; const pIndexNo : integer );
    property Image : TSigImage
             read fSigImage;
    property LabelNodeNo : tLabel
             read fLabelNodeNo;
    property NetworkParent : tFrameNetwork
             read fNetworkParent;
    property Visible : boolean
             read fVisible
             write SetVisible;
    property Top : integer
             read fTop
             write SetTop;
    property Left : integer
             read fLeft
             write SetLeft;
    property NodeType : tNodeType
             read fNodeType
             write SetNodeType;
    property Tag : integer
             read fTag
             write SetTag;
    property Parent : tWinControl
             read fParent
             write SetParent;
    property IndexNo : integer
             read fIndexNo;
    property EditName : tEdit
             read fEditName;
    property Error : boolean
             read fError
             write SetError;

  end;

  TFrameNetwork = class(TFrame)
    ScrollBoxMain: TScrollBox;
    ShapeRing: TShape;
    ImageListNodes: TImagelist;
    SigImage1: TSigImage;
    PopupMenuPanel: TPopupMenu;
    Panel1: TMenuItem;
    Network1: TMenuItem;
    Edit1: TMenuItem;
    DownloadChanges1: TMenuItem;
    DownloadAll1: TMenuItem;
    Properties1: TMenuItem;
    DownloadNetworkGlobalData1: TMenuItem;
    SendChangedPanelData1: TMenuItem;
    SendAllData1: TMenuItem;
    N1: TMenuItem;
    GetNetworkGlobalData1: TMenuItem;
    GetAllData1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    GetPanelData1: TMenuItem;
    N4: TMenuItem;
    PopupMenuNetwork: TPopupMenu;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    ZFP4Panel1: TMenuItem;
    EditNodeName: TEdit;
    LabelNodeNo: TLabel;
    procedure DownloadAll1Click(Sender: TObject);
  public
    const cMaxNodeCount = 256;

  private
    fNodeCount: integer;
    fLeftArmCount, fRightArmCount, fTopCount, fBottomCount : integer;
    fNodeImage : array [1..cMaxNodeCount ] of TVisualNode;
    fNetworkFile: tZFPFile;
    fOnSendAll: tOnSend;
    fActiveChild: integer;
    procedure SetNodeCount(const Value: integer);
    function GetNodeWidth: integer;
    function GetNodeHeight: integer;
    function GetNodeImage(const i: integer): TVisualNode;
    procedure SetNetworkFile(const Value: tZFPFile);
    procedure OnNodeCountChange( const Sender : tSigBaseProperty; const NewVal : integer );
    { Private declarations }
  public
    { Public declarations }
    destructor Destroy; override;
    property NodeCount : integer
             read fNodeCount
             write SetNodeCount;
    property NodeWidth : integer
             read GetNodeWidth;
    property NodeHeight : integer
             read GetNodeHeight;
    property NodeImage[ const i : integer ] : TVisualNode
             read GetNodeImage;
    function TopNodeIndex : integer;
    function BottomNodeIndex : integer;
    procedure Refresh;
    procedure ShowImage( const i : integer; const pTop, pLeft : integer );

    property NetworkFile : tZFPFile
             read fNetworkFile
             write SetNetworkFile;
    property OnSendAll : tOnSend
             read fOnSendAll
             write fOnSendAll;
    property ActiveChild : integer
             read fActiveChild
             write fActiveChild;

    procedure RecheckNameEditors;
  end;

implementation

{$R *.dfm}

{ TFrameNetwork }

function TFrameNetwork.BottomNodeIndex: integer;
begin
  Result := (NodeCount + 3) div 2;
  if Result > NodeCount then
  begin
    Result := 0;
  end;
end;

destructor TFrameNetwork.Destroy;
begin
  inherited;
end;

procedure TFrameNetwork.DownloadAll1Click(Sender: TObject);
begin
  // send all the data for the selected panel
  if ActiveChild <> -1 then
  begin
    fOnSendAll( ActiveChild );
  end;
end;

function TFrameNetwork.GetNodeHeight: integer;
begin
  Result := ImageListNodes.Height;
end;

function TFrameNetwork.GetNodeImage(const i: integer): TVisualNode;
begin
  Result := fNodeImage[ i ];
  if not assigned( Result ) then
  begin
    fNodeImage[ i ] := TVisualNode.Create( self, i );
    Result := fNodeImage[ i ];
  end;
end;

function TFrameNetwork.GetNodeWidth: integer;
begin
  Result := ImageListNodes.Width;
end;

procedure TFrameNetwork.OnNodeCountChange(const Sender : tSigBaseProperty; const NewVal: integer);
begin
  NodeCount := NewVal;
end;

procedure TFrameNetwork.RecheckNameEditors;
var
  i: Integer;
begin
  for i := 1 to fNodeCount do
  begin
    with fNodeImage[ i ] do
    begin
      Error := fNetworkParent.NetworkFile.NodeList.DuplicateName( Tag );
      if Error then
      begin
        fEditName.Font.Color := clRed;
        fEditName.Font.Style := [ fsBold, fsItalic ];
      end
      else
      begin
        fEditName.Font.Color := clWindowText;
        fEditName.Font.Style := [];
      end;
    end;
  end;
end;

procedure TFrameNetwork.Refresh;
var
  i: Integer;
  iMinRingWidth, iMinRingHeight : integer;
  iDesiredRingWidth, iDesiredRingHeight : integer;
  iArmCount : integer;
  iArmSep : integer;
  iArmStart : integer;
  iArmFixedDim : integer;
  iMaxHArmCount : integer;
  iTBNodeCount : integer;
  iMin : integer;
  iMax : integer;
begin
  // put everything on a loop, which has a 50 x 50 margin so every node can be seen
  // Extend loop as far as necessary. Nodes at 1 and 6 o'clock then vertically
  // down 2 side.
  // Sequence is clockwise around ring.
  // calculate ArmCounts

  ActiveChild := -1;
  iDesiredRingWidth := ClientWidth - (2 * NodeWidth );
  iMaxHArmCount := iDesiredRingWidth div (2 * NodeWidth );
  if iMaxHArmCount < 1 then
  begin
    iMaxHArmCount := 1;
  end;

  if fNodeCount < (2 * iMaxHArmCount ) then
  begin
    fRightArmCount := 0;
    fLeftArmCount := 0;
  end
  else
  begin
    fRightArmCount := (1 + fNodeCount - (2*iMaxHArmCount) ) div 2;
    fLeftArmCount := fRightArmCount;
  end;

  iTBNodeCount := fNodeCount - fLeftArmCount - fRightArmCount;
  fBottomCount := iTBNodeCount div 2;
  fTopCount := iTBNodeCount - fBottomCount;

  iMinRingWidth := 2 * ( fTopCount) * NodeWidth;
  iMinRingHeight := 2 * ( fRightArmCount ) * NodeHeight;

  // Try to fit ring near edges if possible
  ShapeRing.Visible := FALSE;
  ShapeRing.Parent := self;
  ShapeRing.Left := NodeWidth;
  if iMinRingWidth > iDesiredRingWidth then
  begin
    ShapeRing.Width := iMinRingWidth;
  end
  else
  begin
    ShapeRing.Width := iDesiredRingWidth;
  end;
  ShapeRing.Top := NodeHeight;
  iDesiredRingHeight := ClientHeight - (2 * NodeHeight );
  if iMinRingHeight > iDesiredRingHeight then
  begin
    ShapeRing.Height := iMinRingHeight;
  end
  else
  begin
    ShapeRing.Height := iDesiredRingHeight;
  end;
  ShapeRing.Parent := ScrollBoxMain;
  ShapeRing.Visible := TRUE;

  // top
  iMin := 1;
  iMax := fTopCount;
  if fTopCount > 0 then
  begin
    // Now position the device images.
    iArmSep := (ShapeRing.Width - fTopCount * NodeWidth) div fTopCount;
    iArmStart := ShapeRing.Left + (iArmSep div 2 );
    iArmFixedDim := ShapeRing.Top - ( NodeHeight div 2 );
    for i := iMin to iMax do
    begin
      with NodeImage[ i ] do
      begin
        ShowImage( i, iArmFixedDim, iArmStart );
        inc( iArmStart, NodeWidth + iArmSep );
      end;
    end;
  end;

  // right
  inc( iMin, fTopCount );
  inc( iMax, fRightArmCount );
  if fRightArmCount > 0 then
  begin
    iArmSep := (ShapeRing.Height - fRightArmCount * NodeHeight) div fRightArmCount;
    iArmStart := ShapeRing.Top + (iArmSep div 2 );
    iArmFixedDim := ShapeRing.Left + ShapeRing.Width - (NodeWidth div 2);
    for i := iMin to iMax do
    begin
      with NodeImage[ i ] do
      begin
        ShowImage( i, iArmStart, iArmFixedDim );
        inc( iArmStart, NodeHeight + iArmSep );
      end;
    end;
  end;

  // bottom
  inc( iMin, fRightArmCount );
  inc( iMax, fBottomCount );
  if fBottomCount > 0 then
  begin
    iArmSep := (ShapeRing.Width - fBottomCount * NodeWidth) div fBottomCount;
    iArmStart := ShapeRing.Left + (iArmSep div 2 );
    iArmFixedDim := ShapeRing.Top + ShapeRing.Height - ( NodeHeight div 2 );
    for i := iMax downto iMin do
    begin
      with NodeImage[ i ] do
      begin
        ShowImage( i, iArmFixedDim, iArmStart );
        inc( iArmStart, NodeWidth + iArmSep );
      end;
    end;
  end;

  // left
  inc( iMin, fBottomCount );
  inc( iMax, fLeftArmCount );
  if fLeftArmCount > 0 then
  begin
    iArmSep := (ShapeRing.Height - fLeftArmCount * NodeHeight) div fLeftArmCount;
    iArmStart := ShapeRing.Top + (iArmSep div 2 );
    iArmFixedDim := ShapeRing.Left - (NodeWidth div 2);
    for i := iMax downto iMin do
    begin
      with NodeImage[ i ] do
      begin
        ShowImage( i, iArmStart, iArmFixedDim );
        inc( iArmStart, NodeHeight + iArmSep );
      end;
    end;
  end;
end;

procedure TFrameNetwork.SetNetworkFile(const Value: tZFPFile);
begin
  fNetworkFile := Value;
  fNetworkFile.NodeList.OnCountChange := OnNodeCountChange;
  NodeCount := fNetworkFile.NodeList.Count;
end;

procedure TFrameNetwork.SetNodeCount(const Value: integer);
var
  i: Integer;
begin
  //for i := Value + 1 to NodeCount do
  for i := 1 to NodeCount do
  begin
    NodeImage[ i ].Visible := FALSE;
  end;
  fNodeCount := Value;
  Refresh;
end;

procedure TFrameNetwork.ShowImage(const i, pTop, pLeft: integer);
begin
  with NodeImage[ i ] do
  begin
    Visible := FALSE;
    //Parent := self;
    Parent := nil;
    Left := pLeft;
    Top := pTop;
    Parent := ScrollBoxMain;
    Visible := TRUE;
  end;
end;

function TFrameNetwork.TopNodeIndex: integer;
begin
  if NodeCount < 1 then
  begin
    Result := 0;
  end
  else
  begin
    Result := 1;
  end;
end;

{ TVisualNode }

constructor TVisualNode.Create(AOwner: TFrameNetwork; const pIndexNo : integer );
begin
  inherited Create;
  fNetworkParent := AOwner;
  fIndexNo := pIndexNo;

  fSigImage := TSigImage.Create( fNetworkParent );
  with fSigImage do
  begin
    Parent := fNetworkParent.ScrollBoxMain;
    ImageList := fNetworkParent.ImageListNodes;
    PopupMenu := fNetworkParent.PopupMenuPanel;
    Tag := pIndexNo;
    OnClick := fOnClick;
    OnContextPopup := fContextPopup;
  end;

  fLabelNodeNo := TLabel.Create( fNetworkParent );
  with fLabelNodeNo do
  begin
    Parent := fNetworkParent.ScrollBoxMain;
    Caption := fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].NetworkFile.PanelAddress.Address.Value;
    PopupMenu := fNetworkParent.PopupMenuPanel;
    Tag := pIndexNo;
    OnContextPopup := fContextPopup;
  end;

  fEditName := TEdit.Create( fNetworkParent );
  with fEditName do
  begin
    Parent := fNetworkParent.ScrollBoxMain;
    Width := fSigImage.Width;
    PopupMenu := fNetworkParent.PopupMenuPanel;
    Tag := pIndexNo;
    OnContextPopup := fContextPopup;
    OnChange := fOnNameChange;
  end;

  Visible := FALSE;
  if fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].IsRepeater then
  begin
    NodeType := ntRepeater;
  end
  else
  begin
    NodeType := ntPanel;
  end;

end;

procedure TVisualNode.fContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  NetworkParent.ActiveChild := fIndexNo - 1;
end;

procedure TVisualNode.fOnClick(Sender: tObject);
begin
  NetworkParent.ActiveChild := fIndexNo - 1;
end;

procedure TVisualNode.fOnNameChange(Sender: tObject);
begin
  Error := fNetworkParent.NetworkFile.NodeList.DuplicateName( Tag );
end;

procedure TVisualNode.SetError(const Value: boolean);
begin
  if fError <> Value then
  begin
    fError := Value;
    try
      fNetworkParent.RecheckNameEditors;
    except

    end;
  end;
end;

procedure TVisualNode.SetLeft(const Value: integer);
begin
  fLeft := Value;
  fSigImage.Left := Value;
  fLabelNodeNo.Left := Value;
  fEditName.Left := Value;
end;

procedure TVisualNode.SetNodeType(const Value: tNodeType);
begin
  fNodeType := Value;
  fSigImage.ImageIndex := Ord( fNodeType );
end;

procedure TVisualNode.SetParent(const Value: tWinControl);
begin
  fParent := Value;
  fSigImage.Parent := Value;
end;

procedure TVisualNode.SetTag(const Value: integer);
begin
  fTag := Value;
  fSigImage.Tag := Value;
  fLabelNodeNo.Tag := Value;
  fEditName.Tag := Value;
end;

procedure TVisualNode.SetTop(const Value: integer);
begin
  fTop := Value;
  fSigImage.Top := Value;
  fLabelNodeNo.Top := Value - ((3 * fLabelNodeNo.Height ) div 2);
  fEditName.Top := Value + fSigImage.Height + (fEditName.Height div 2);
end;

procedure TVisualNode.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  fSigImage.Visible := Value;
  fLabelNodeNo.Visible := Value;
  fEditName.Visible := Value;
  Tag := fIndexNo - 1;
  if Visible then
  begin
    fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].NameEditorNetwork := fEditName;
    fLabelNodeNo.Caption := fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].NetworkFile.PanelAddress.Address.Value;
    if fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].IsRepeater then
    begin
      NodeType := ntRepeater;
    end
    else
    begin
      NodeType := ntPanel;
    end;
  end
  else if fIndexNo <= fNetworkParent.NetworkFile.NodeList.Max then
  begin
    fNetworkParent.NetworkFile.NodeList.Node[ fIndexNo - 1 ].NameEditorNetwork := nil;
  end;
end;

end.
