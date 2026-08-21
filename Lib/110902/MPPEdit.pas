unit MPPEdit;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls,
  StdCtrls;

type
  TMPPEdit = class(TShape)
  {
    this component is a rectangle or rounded rectangle
    with two TImage components, one of which is visible
    at any one time, plus a TEdit to the right.
  }
  private
    { Private declarations }
  protected
    { Protected declarations }
    iSelectedActive : boolean;
    iImageWidth : integer;
    iSelActive : TImage;
    iUnselActive : TImage;
    iEdit : TEdit;
    procedure fSetImageWidth( NewVal : integer );
    procedure fSetLeft( NewVal : integer );
    function fGetLeft : integer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property ImageWidth : integer
             read iImageWidth
             write fSetImageWidth;
    property Left : integer
             read fGetLeft
             write fSetLeft;
  end;

  TMPPEditList = class( TList )
  {
    although not a visible component, it is an
    array of visible objects and has many similar
    properties
  }
  private
    { Private declarations }
    iRowCount : integer;
    iColCount : integer;
    iOwner : tComponent;
    iLeft, iTop : integer;
    iRowHeight, iColWidth : integer;
    iParent : TWinControl;
    iVisible : boolean;
  protected
    { Protected declarations }
//    iSelectedActive : boolean;
    procedure fSetEntries( NewColCount, NewRowCount : integer );
    procedure fSetRowCount( NewVal : integer );
    procedure fSetColCount( NewVal : integer );
    function fGetButtons( index : integer ) : TMPPEdit;
    procedure fSetXY;
    procedure fSetTop( NewVal : integer );
    procedure fSetLeft( NewVal : integer );
    procedure fSetRowHeight( NewVal : integer );
    procedure fSetColWidth( NewVal : integer );
    procedure fSetParent( NewVal : TWinControl );
    procedure fSetVisible( NewVal : boolean );
  public
    { Public declarations }
    constructor Create( AOwner : TComponent );
    property RowCount : integer
             read iRowCount
             write fSetRowCount;
    property ColCount : integer
             read iColCount
             write fSetColCount;
    property Buttons[ index : integer ] : TMPPEdit
             read fGetButtons;
    property Left : integer
             read iLeft
             write fSetLeft;
    property Top : integer
             read iTop
             write fSetTop;
    property RowHeight : integer
             read iRowHeight
             write fSetRowHeight;
    property ColWidth : integer
             read iColWidth
             write fSetColWidth;
    property Parent : TWinControl
             read iParent
             write fSetParent;
    property Visible : boolean
             read iVisible
             write fSetVisible;
  end;

//procedure Register;

implementation

{
procedure Register;
begin
  RegisterComponents('SigNET', [TMPPEdit]);
end;
}

constructor TMPPEdit.Create( AOwner : TComponent );
begin
  inherited;
  iSelectedActive := FALSE;
  iImageWidth := 64;
  iSelActive := TImage.Create( AOwner );
  iUnselActive := TImage.Create( AOwner );
  iEdit := TEdit.Create( AOwner );
  iEdit.Left := self.Left + iImageWidth;
end;

procedure TMPPEdit.fSetImageWidth( NewVal : integer );
begin
  if iImageWidth <> NewVal then
  begin
    iImageWidth := NewVal;
    iEdit.Left := self.Left + iImageWidth;
  end;
end;

procedure TMPPEdit.fSetLeft( NewVal : integer );
begin
  inherited Left := NewVal;
  iEdit.Left := self.Left + iImageWidth;
end;

function TMPPEdit.fGetLeft : integer;
begin
  Result := inherited Left;
end;

//-------------------- List -----------------------

constructor TMPPEditList.Create( AOwner : TComponent );
begin
  inherited Create;
  iOwner := AOwner;
  iRowCount := 0;
  iColCount := 0;
  iLeft := 4;
  iTop  := 4;
  iColWidth := 20;
  iRowHeight := 20;
  iParent := nil;
  iVisible := FALSE;
end;

procedure TMPPEditList.fSetRowCount( NewVal : integer );
begin
  if NewVal <> iRowCount then
  begin
    fSetEntries( iColCount, NewVal );
    iRowCount := NewVal;
  end;
end;

procedure TMPPEditList.fSetColCount( NewVal : integer );
begin
  if NewVal <> iColCount then
  begin
    fSetEntries( NewVal, iRowCount );
    iColCount := NewVal;
  end;
end;

function TMPPEditList.fGetButtons( index : integer ) : TMPPEdit;
begin
  Result := TMPPEdit( Items[ index ] );
end;


procedure TMPPEditList.fSetEntries( NewColCount, NewRowCount : integer );
var
  i, iOldCount, iNewCount : integer;
  iNewItem : TMPPEdit;
begin
  iOldCount := iColCount * iRowCount;
  iNewCount := NewColCount * NewRowCount;
  if iOldCount > iNewCount then
  begin
    // items to free, based on old entries
    for i := iNewCount to iOldCount - 1 do
    begin
      Buttons[ i ].Free;
    end;
  end
  else if iNewCount > iOldCount then
  begin
    // items to add
    for i := iOldCount to iNewCount - 1 do
    begin
      iNewItem := TMPPEdit.Create( iOwner );
      if assigned( iParent ) then
      begin
        iNewItem.Parent := iParent;
      end;
      Add( iNewItem );
      iNewItem.Visible := iVisible;
    end;
  end;
  fSetXY;
end;

procedure TMPPEditList.fSetXY;
var
  i, j, k : integer;
  iX, iY : integer;
begin
  k := 0;
  iX := iLeft;
  for i := 1 to iColCount do
  begin
    iY := iTop;
    for j := 1 to iRowCount do
    begin
      Buttons[ k ].Left := iX;
      Buttons[ k ].Top := iY;
      inc( iY, iRowHeight );
    end;
    inc( iX, iColWidth );
  end;
end;

procedure TMPPEditList.fSetTop( NewVal : integer );
begin
  if NewVal <> iTop then
  begin
    iTop := NewVal;
    fSetXY;
  end;
end;

procedure TMPPEditList.fSetLeft( NewVal : integer );
begin
  if NewVal <> iLeft then
  begin
    iLeft := NewVal;
    fSetXY;
  end;
end;

procedure TMPPEditList.fSetRowHeight( NewVal : integer );
begin
  if NewVal <> iRowHeight then
  begin
    iRowHeight := NewVal;
    fSetXY;
  end;
end;

procedure TMPPEditList.fSetColWidth( NewVal : integer );
begin
  if NewVal <> iColWidth then
  begin
    iColWidth := NewVal;
    fSetXY;
  end;
end;

procedure TMPPEditList.fSetParent( NewVal : TWinControl );
var
  i : integer;
begin
  if iParent <> NewVal then
  begin
    iParent := NewVal;
    for i := 0 to Count - 1 do
    begin
      Buttons[ i ].Parent := iParent;
    end;
  end;
end;

procedure TMPPEditList.fSetVisible( NewVal : boolean );
var
  i : integer;
begin
  if iVisible <> NewVal then
  begin
    iVisible := NewVal;
    for i := 0 to Count-1 do
    begin
      Buttons[ i ].Visible := NewVal;
    end;
  end;
end;

end.
