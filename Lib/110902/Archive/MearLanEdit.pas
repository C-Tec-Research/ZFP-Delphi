unit MearLanEdit;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  stdctrls;

type
  TMearLanEdit = class(TWinControl)
  private
    { Private declarations }
    iRoot : tMearLanPlaceHolder;
    ScrollBarHoriz: TScrollBar;
    ScrollBarVert: TScrollBar;
  protected
    { Protected declarations }
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

    procedure New;
    function IsDirty : boolean;
    function Save : boolean;
    procedure RedoTargeted;
    procedure UndoTargeted;
    procedure Down;
    procedure Up;

    procedure Load( pObjectName : ShortString );

  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DSM', [TMearLanEdit]);
end;

constructor TMearLanEdit.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  iRoot := nil;
  ScrollBarHoriz := TScrollBar.Create( self );
  ScrollBarVert := TScrollBar.Create( self );
  ScrollBarHoriz.Parent := self;
  ScrollBarVert.Parent := self;
  with ScrollBarHoriz do
  begin
    Visible := FALSE;
    Height := 16;
  end;
  with ScrollBarVert do
  begin
    Visible := FALSE;
    Width := 16;
  end;
end;

procedure TMearLanEdit.New;
begin
  iRoot.Free;
  iRoot := tMearLanPlaceHolder.Create( self, ScrollBarVert, ScrollBarHoriz );
  iRoot.FirstChild := tMearLanEditableObject.Create( iRoot );
  iRoot.SetGlobalEditOutput;
end;

function TMearLanEdit.IsDirty : boolean;
begin
  if assigned( iRoot ) then
  begin
    Result := iRoot.IsDirty;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TMearLanEdit.Save : boolean;
begin
  if assigned( iRoot ) then
  begin
    Result := iRoot.Save( 0 );
  end
  else
  begin
    Result := TRUE; // no error on save attempt
  end;
end;

procedure TMearLanEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  // resize scroll bars and check visibility
  with ScrollBarHoriz do
  begin
    Top := Message.nHeight - ClientHeight;
    Left := 0;
    Width := Message.nWidth - ScrollBarVert.Width;
    Visible := TRUE;
  end;

  with ScrollBarVert do
  begin
    Top := 0;
    Left := Message.nWidth - ClientWidth;
    Height := Message.nHeight - ScrollBarHoriz.Height;
    Visible := TRUE;
  end;

  if assigned( iRoot ) then
  begin
    iRoot.SetGlobalEditOutput;
  end;
end;

procedure TMearLanEdit.RedoTargeted;
begin
  if assigned( iRoot ) then
  begin
    iRoot.RedoTargeted;
  end;
end;

procedure TMearLanEdit.UndoTargeted;
begin
  if assigned( iRoot ) then
  begin
    iRoot.UndoTargeted;
  end;
end;

procedure TMearLanEdit.Down;
begin
  if assigned( iRoot ) then
  begin
    iRoot.Down;
  end;
end;

procedure TMearLanEdit.Up;
begin
  if assigned( iRoot ) then
  begin
    iRoot.Up;
  end;
end;

procedure TMearLanEdit.Load( pObjectName : ShortString );
begin
  iRoot.Free;
  iRoot := tMearLanPlaceHolder.Create( self, ScrollBarVert, ScrollBarHoriz );
  iRoot.Load( pObjectName );
end;

end.
