unit SigFrameGrid;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Types,
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Forms,
  FMX.Layouts;

type
  TFrameClass = class of TFrame;
  TSigFrameGrid = class;

  TFrameHolder = class
  {
    A placeholder for TFrames specifically designed for
    TSigFrameGrid to add the extra fields needed for TSigFrameGrid

    The frames are all meant to be the same size although they can

    span 2 columns

    Note that Frames must not destroy themselves - they must call
    RemoveFrame!
  }
  private
    fFrame: TFrame;
    fCellRow: integer;
    fCellCol: integer;
    fItemIndex: integer;
    fData: TObject;
    fText: string;
    fOwner: TSigFrameGrid;
    procedure SetSpecialData(const Value: TObject);
    function GetOwnerGrid: TSigFrameGrid;
    function GetOccupies2Cells: boolean;
    procedure SetFrame(const Value: TFrame);
  protected
  public
    constructor Create( pOwner : TSigFrameGrid );
    destructor Destroy; override;

    property Owner : TSigFrameGrid
             read fOwner;
    property Frame : TFrame
             read fFrame
             write SetFrame;
    property Occupies2Cells : boolean
             read GetOccupies2Cells;
    property CellRow : integer
             read fCellRow
             write fCellRow;
    property CellCol : integer
             read fCellCol
             write fCellCol;
    property ItemIndex : integer
             read fItemIndex
             write fItemIndex;
    property Data : TObject
             read fData
             write SetSpecialData;
    property Text : string
             read fText
             write fText;
    property OwnerGrid : TSigFrameGrid
             read GetOwnerGrid;
  end;

  TOnAddFrame = procedure( Sender : TSigFrameGrid; const pFrame : TFrame ) of Object;
  TFrameGridIndexChanged = procedure( Sender : TSigFrameGrid; const pIndex, pCol, pRow : integer; const pFrame : TFrame ) of Object;
  TOnChangeData = procedure( Sender : TSigFrameGrid; const pIndex : integer; const pFrame : TFrame; pData : TObject ) of Object;
  TOnGetFrameOccupies2Cells = function( const pFrame : TFrame ) : boolean of Object;

  TSigGridFrameStrings = class( TStrings )
  private
    fOwner: TSigFrameGrid;
  protected
    function Get(Index: Integer): string; override;
    procedure Put(Index: Integer; const S: string); override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create( const pOwner : TSigFrameGrid );
    destructor Destroy; override;
    property Owner : TSigFrameGrid
             read fOwner;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    function AddObject(const S: string; AObject: TObject): Integer; override;

    procedure InsertObject(Index: Integer; const S: string;
      AObject: TObject); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
  end;

  TSigFrameGridStyle = ( gsGrid, gsList );

  TCreateFrame = function( pIndex : integer; pData : TObject ) : TFrame of Object;
  TSigFrameGrid = class(TScrollBox)
  private
    fMinFrameWidth: single;
    fOptFrameWidth: single;
    fOptFrameHeight: single;
    fFrames : TObjectList< TFrameHolder >;
    fMinMarginPercent: single;
    fOnAddFrame: TOnAddFrame;
    fItemIndex: integer;
    fOnIndexChanged: TFrameGridIndexChanged;
    fOnCreateFrame: TCreateFrame;
    fOnChangeData: TOnChangeData;
    fOnGetFrameOccupies2Cells: TOnGetFrameOccupies2Cells;
    fStrings : TStrings;  // actually TSigGridFrameStrings;
    fSigFrameGridStyle: TSigFrameGridStyle;
    procedure SetMinFrameWidth(const Value: single);
    procedure SetOptFrameWidth(const Value: single);
    procedure SetOptFrameHeight(const Value: single);
    procedure SetMinMarginPercent(const Value: single);
    procedure SetItemIndex(const Value: integer);
    function GetItemData(const pIndex: integer): TObject;
    function GetItem(const pIndex: integer): TFrame;
    procedure SetItemData(const pIndex: integer; const Value: TObject);
    function GetItemCount: integer;
    { Private declarations }
  protected
    { Protected declarations }
    procedure SetHeight(const Value: Single); override;
    procedure SetWidth(const Value: Single); override;
    procedure CalculateGridDimensions( pMin, pOptimal, HostSize : single; var Count : integer; var Size : single );
   procedure DoEndUpdate; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function UniqueCellName : string;

    procedure Clear;

    procedure PlaceFrames; // a kind of Invalidate!
    procedure PlaceGridFrames; // a kind of Invalidate!
    procedure PlaceListFrames; // a kind of Invalidate!
    procedure Resize; override;
    procedure AddFrame( const pFrameClass : TFrameClass; const pOccupies2Cells : boolean;
                        const pTagObject : TObject );
    procedure RemoveFrame( pFrame : TFrame );
    procedure SelectFrame( const pFrame : TFrame );
    property Item[ const pIndex : integer ] : TFrame
             read GetItem;
    property ItemCount : integer
             read GetItemCount;
    property Data[ const pIndex : integer ] : TObject
             read GetItemData
             write SetItemData;
    property Strings : TStrings
             read fStrings;
  published
    { Published declarations }
    property MinFrameWidth : single
             read fMinFrameWidth
             write SetMinFrameWidth;
    property OptFrameWidth : single
             read fOptFrameWidth
             write SetOptFrameWidth;
    property OptFrameHeight : single
             read fOptFrameHeight
             write SetOptFrameHeight;
    property MinMarginPercent : single
             read fMinMarginPercent
             write SetMinMarginPercent;
    property OnAddFrame : TOnAddFrame
             read fOnAddFrame
             write fOnAddFrame;
    property OnIndexChanged : TFrameGridIndexChanged
             read fOnIndexChanged
             write fOnIndexChanged;
    property ItemIndex : integer
             read fItemIndex
             write SetItemIndex
             default -1;
    property OnCreateFrame : TCreateFrame
             read fOnCreateFrame
             write fOnCreateFrame;
    property OnChangeData : TOnChangeData
             read fOnChangeData
             write fOnChangeData;
    property OnGetFrameOccupies2Cells : TOnGetFrameOccupies2Cells
             read fOnGetFrameOccupies2Cells
             write fOnGetFrameOccupies2Cells;
    property SigFrameGridStyle : TSigFrameGridStyle
             read fSigFrameGridStyle
             write fSigFrameGridStyle
             default gsGrid;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigFile7', [TSigFrameGrid]);
end;

{ TSigFrameGrid }

procedure TSigFrameGrid.AddFrame(const pFrameClass: TFrameClass;
  const pOccupies2Cells: boolean; const pTagObject: TObject);
var
  iFrame : TFrame;
  iFrameHolder : TFrameHolder;
  iIndex : integer;
begin
  iFrameHolder := TFrameHolder.Create( self );
  iFrame := pFrameClass.Create( self );
  iFrameHolder.Frame := iFrame;
  iFrame.TagObject := pTagObject;
  iIndex := fFrames.Add( iFrameHolder );
  iFrame.Name := pFrameClass.ClassName + IntToStr( iIndex );
  iFrameHolder.ItemIndex := iIndex;
  if assigned( fOnAddFrame ) then
  begin
    fOnAddFrame( self, iFrame );
  end;
  PlaceFrames;
end;

procedure TSigFrameGrid.CalculateGridDimensions(pMin, pOptimal, HostSize: single;
  var Count: integer; var Size: single);
var
  iMaxCount,iOptimalCount : integer;
begin
  if pMin = 0 then
  begin
    Count := 0;
    Size := 0;
    exit;
  end
  else
  begin
    iMaxCount := Trunc( HostSize / pMin );
    case iMaxCount of
      0:
      begin
        Count := 0;
        Size := 0;
      end;
      1:
      begin
        Count := 2;                   // to allow double width on col calc
        Size := pMin;
      end;
      else
      begin
        if pOptimal = 0 then
        begin
          Count := iMaxCount;
          Size := HostSize / iMaxCount;  // we already know fMaxCount > 1
        end
        else
        begin
          iOptimalCount := Trunc( HostSize / pOptimal );
          //if iOptimalCount = 0 then
          if iOptimalCount < 2 then
          begin
            Count := iMaxCount;
            Size := HostSize / iMaxCount;  // we already know fMaxCount > 1
          end
          else
          begin
            Count := iOptimalCount;
            Size := HostSize / iOptimalCount;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSigFrameGrid.Clear;
begin
  if assigned( fFrames ) then
  begin
    fFrames.Clear;
  end;
  PlaceFrames;
end;

constructor TSigFrameGrid.Create(AOwner: TComponent);
begin
  inherited;

  fItemIndex := -1;
  fFrames := TObjectList< TFrameHolder >.Create( TRUE );
  fStrings := TSigGridFrameStrings.Create( self );
end;

destructor TSigFrameGrid.Destroy;
begin
  fStrings.Free;
  fFrames.OwnsObjects := FALSE; // avoid double deletion
  fFrames.Free;
  inherited;
end;

procedure TSigFrameGrid.DoEndUpdate;
begin
  inherited;
  PlaceFrames;
end;

function TSigFrameGrid.GetItemData(const pIndex: integer): TObject;
begin
  Result := fFrames[ pIndex ].Data;
end;

function TSigFrameGrid.GetItem(const pIndex: integer): TFrame;
begin
  Result := fFrames[ pIndex ].Frame;
end;

function TSigFrameGrid.GetItemCount: integer;
begin
  Result := fFrames.Count;
end;

procedure TSigFrameGrid.PlaceFrames;
begin
  case fSigFrameGridStyle of
    gsGrid: PlaceGridFrames;
    gsList: PlaceListFrames;
  end;
end;

procedure TSigFrameGrid.PlaceGridFrames;
var
  iMargin : single;
  iFrameWidth, iFrameHeight : single;
  iTop, iLeft, iWidth, iHeight : single;
  i, iRow, iCol : integer;
  iOccupies2Cells : boolean;
  iCellWidth : single;
  iColCount : integer;
  iMinMargin, i2xMinMargin : single;
begin
  // see how much room we can place around each frame
  if FUpdating = 0 then
  begin
    if assigned( fFrames ) then
    begin
      if fFrames.Count = 0 then
      begin
        // nothing to draw!
        exit;
      end;
      if OptFrameWidth = 0 then
      begin
        exit;
      end;
      CalculateGridDimensions( MinFrameWidth, OptFrameWidth, Width, iColCount, iCellWidth);
      if iColCount = 0 then
      begin
        exit;
      end;
      iMinMargin := iCellWidth * MinMarginPercent / 100.0;
      i2xMinMargin := 2 * iMinMargin;
      if (iCellWidth - OptFrameWidth) >= i2xMinMargin then
      begin
        iFrameWidth := OptFrameWidth;
        iFrameHeight := OptFrameHeight;
        iMargin := (iCellWidth - iFrameWidth ) / 2;
      end
      else
      begin
        iMargin := iMinMargin;
        iFrameWidth := iCellWidth - i2xMinMargin;
        iFrameHeight := (OptFrameHeight * iFrameWidth ) / OptFrameWidth;
      end;
      iRow := 0;
      iCol := 0;
      iTop := iMargin;
      iLeft := iMargin;
      for i := 0 to fFrames.Count - 1 do
      begin
        if assigned( fFrames[ i ] ) and assigned( fFrames[ i ].Frame ) then
        begin
          iOccupies2Cells := fFrames[ i ].Occupies2Cells;
          if iOccupies2Cells then
          begin
            if iColCount > 1 then
            begin
              if iCol >= (iColCount - 1) then
              begin
                iRow := iRow + 1;
                iCol := 0;
                iTop := iTop + iFrameHeight + (2 * iMargin);
                iLeft := iMargin;
              end;
            end;
          end;
          with fFrames[ i ] do
          begin
            iHeight := iFrameHeight;
            CellRow := iRow;
            CellCol := iCol;
            ItemIndex := i;
            if iOccupies2Cells then
            begin
              iWidth := 2 * (iFrameWidth + iMargin );
              Inc( iCol, 2);
            end
            else
            begin
              iWidth := iFrameWidth;
              Inc( iCol );
            end;
            Frame.SetBounds( iLeft, iTop, iWidth, iHeight );
          end;
          if iCol >= iColCount then
          begin
            iRow := iRow + 1;
            iCol := 0;
            iTop := iTop + iFrameHeight + (2 * iMargin);
            iLeft := iMargin;
          end
          else
          begin
            iLeft := iLeft + iWidth + iMargin;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSigFrameGrid.PlaceListFrames;
var
  iFrameWidth, iFrameHeight : single;
  iTop, iLeft, iWidth, iHeight : single;
  i, iRow : integer;
begin
  // see how much room we can place around each frame
  if FUpdating = 0 then
  begin
    if assigned( fFrames ) then
    begin
      if fFrames.Count = 0 then
      begin
        // nothing to draw!
        exit;
      end;
      if OptFrameHeight = 0 then
      begin
        exit;
      end;
      iFrameWidth := Width;
      if assigned( VScrollBar ) then
      begin
        iFrameWidth := iFrameWidth - VScrollBar.Width;
      end;
      if iFrameWidth < fMinFrameWidth then
      begin
        iFrameWidth := fMinFrameWidth;
      end;
      iFrameHeight := OptFrameHeight; // lists not scaled
      iRow := 0;
      iTop := 0;
      iLeft := 0;
      for i := 0 to fFrames.Count - 1 do
      begin
        if assigned( fFrames[ i ] ) then
        begin
          with fFrames[ i ] do
          begin
            iHeight := iFrameHeight;
            CellRow := iRow;
            CellCol := 0;
            ItemIndex := i;
            iWidth := iFrameWidth;
            Frame.SetBounds( iLeft, iTop, iWidth, iHeight );
          end;
          iRow := iRow + 1;
          iTop := iTop + iFrameHeight;
        end;
      end;
    end;
  end;
end;

procedure TSigFrameGrid.RemoveFrame(pFrame: TFrame);
var
  i: Integer;
  iFrameHolder : TFrameHolder;
begin
  if assigned( fFrames ) then
  begin
    for i := 0 to fFrames.Count - 1 do
    begin
      iFrameHolder := fFrames[ i ];
      if iFrameHolder.Frame = pFrame then
      begin
        fFrames.Delete( i ); // fFrames does not own iFrameHolder, so it does not detroy it
        iFrameHolder.Free;
        PlaceFrames;
        exit;
      end;
    end;
  end;
end;

procedure TSigFrameGrid.Resize;
begin
  inherited;
  PlaceFrames;
end;

procedure TSigFrameGrid.SelectFrame(const pFrame: TFrame);
var
  i: Integer;
begin
  if assigned( pFrame ) then
  begin
    for i := 0 to fFrames.Count - 1 do
    begin
      if fFrames[ i ].Frame = pFrame then
      begin
        ItemIndex := i;
        exit;
      end;
    end;
  end;
  // else (Note also drop through if pFrame not found in fFrames)
  ItemIndex := -1;
end;

procedure TSigFrameGrid.SetItemData(const pIndex: integer; const Value: TObject);
begin
  fFrames[ pIndex ].Data := Value;
end;

procedure TSigFrameGrid.SetHeight(const Value: Single);
begin
  inherited;
  PlaceFrames;
end;

procedure TSigFrameGrid.SetItemIndex(const Value: integer);
begin
  if fItemIndex <> Value then
  begin
    fItemIndex := Value;
    if assigned( fOnIndexChanged ) then
    begin
      if fItemIndex = -1 then
      begin
        fOnIndexChanged( self, fItemIndex, -1, -1, nil );
      end
      else
      begin
        with fFrames[ fItemIndex ] do
        begin
          fOnIndexChanged( self, fItemIndex, CellCol, CellRow, Frame );
        end;
      end;
    end;
  end;
end;

procedure TSigFrameGrid.SetMinFrameWidth(const Value: single);
begin
  fMinFrameWidth := Value;
  PlaceFrames;
end;

procedure TSigFrameGrid.SetMinMarginPercent(const Value: single);
begin
  fMinMarginPercent := Value;
  PlaceFrames;
end;

procedure TSigFrameGrid.SetOptFrameHeight(const Value: single);
begin
  fOptFrameHeight := Value;
  PlaceFrames;
end;

procedure TSigFrameGrid.SetOptFrameWidth(const Value: single);
begin
  fOptFrameWidth := Value;
  PlaceFrames;
end;

procedure TSigFrameGrid.SetWidth(const Value: Single);
begin
  inherited;
  PlaceFrames;
end;

function TSigFrameGrid.UniqueCellName: string;
var
  iNameIndex : integer;
  i : Integer;
  iDone : boolean;
begin
  iNameIndex := 0;
  iDone := FALSE;
  while not iDone do
  begin
    iDone := TRUE;
    Result := Name + 'Cell' + IntToStr( iNameIndex );
    for i := 0 to fFrames.Count - 1 do
    begin
      if SameText( Item[ i ].Name, Result ) then
      begin
        iDone := FALSE;
        inc( iNameIndex );
        Result := Name + 'Cell' + IntToStr( iNameIndex );
        // we do not break here because names are usually in sequence
        // so we end up going through the list fewer times in practice
      end;
    end;
  end;
end;

{ TSigGridFrameStrings }

function TSigGridFrameStrings.AddObject(const S: string;
  AObject: TObject): Integer;
begin
  Result := GetCount;
  InsertObject(Result, S, AObject);
end;

procedure TSigGridFrameStrings.Clear;
begin
  inherited;
  fOwner.fFrames.Clear;
end;

constructor TSigGridFrameStrings.Create(const pOwner: TSigFrameGrid);
begin
  inherited Create;
  fOwner := pOwner;
end;

procedure TSigGridFrameStrings.Delete(Index: Integer);
begin
  BeginUpdate;
  try
    Owner.fFrames.Delete( index );
  finally
    EndUpdate;
  end;
end;

destructor TSigGridFrameStrings.Destroy;
begin

  inherited;
end;

procedure TSigGridFrameStrings.Exchange(Index1, Index2: Integer);
begin
  Owner.fFrames.Exchange( Index1, Index2 );
end;

function TSigGridFrameStrings.Get(Index: Integer): string;
begin
  Result := Owner.fFrames[ Index ].Text;
end;

function TSigGridFrameStrings.GetCount: Integer;
begin
  Result := fOwner.fFrames.Count;
end;

function TSigGridFrameStrings.GetObject(Index: Integer): TObject;
begin
  Result := fOwner.fFrames[ Index ].Data;
end;

procedure TSigGridFrameStrings.Insert(Index: Integer; const S: string);
var
  iFrameHolder : TFrameHolder;
begin
  BeginUpdate;
  try
    iFrameHolder := TFrameHolder.Create( fOwner );
    iFrameHolder.Text := S;
    Owner.fFrames.Insert( Index, iFrameHolder );
    if assigned( Owner.OnCreateFrame ) then
    begin
      iFrameHolder.Frame := Owner.OnCreateFrame( Index, nil );
    end;
  finally
    EndUpdate;
  end;
end;

procedure TSigGridFrameStrings.InsertObject(Index: Integer; const S: string;
  AObject: TObject);
var
  iFrameHolder : TFrameHolder;
begin
  BeginUpdate;
  try
    iFrameHolder := TFrameHolder.Create( fOwner );
    iFrameHolder.Text := S;
    Owner.fFrames.Insert( Index, iFrameHolder );
    iFrameHolder.fData := AObject; // we use fData here because we do not want secondary actions to occur
    if assigned( Owner.OnCreateFrame ) then
    begin
      iFrameHolder.Frame := Owner.OnCreateFrame( Index, AObject );
    end;
  finally
    EndUpdate;
  end;
end;

procedure TSigGridFrameStrings.Move(CurIndex, NewIndex: Integer);
begin
  BeginUpdate;
  try
    fOwner.fFrames.Move( CurIndex, NewIndex );
  finally
    EndUpdate
  end;
end;

procedure TSigGridFrameStrings.Put(Index: Integer; const S: string);
begin
  Owner.fFrames[ Index ].Text := S;
  // note our ancestor (TStrings) destroys and reinserts. This is MUCH faster
end;

procedure TSigGridFrameStrings.PutObject(Index: Integer; AObject: TObject);
begin
  BeginUpdate;
  try
    fOwner.fFrames[ Index ].Data := AObject;
  finally
    EndUpdate;
  end;
end;

procedure TSigGridFrameStrings.SetUpdateState(Updating: Boolean);
begin
  if not Updating then
  begin
    Owner.PlaceFrames;
  end;
end;

{ TFrameHolder }

constructor TFrameHolder.Create(pOwner: TSigFrameGrid);
begin
  inherited Create;
  fOwner := pOwner;
end;

destructor TFrameHolder.Destroy;
begin
  fFrame.Free;
  inherited;
end;

function TFrameHolder.GetOccupies2Cells: boolean;
begin
  if not assigned( Frame ) then
  begin
    Result := FALSE;
  end
  else if assigned( OwnerGrid.OnGetFrameOccupies2Cells ) then
  begin
    Result := OwnerGrid.OnGetFrameOccupies2Cells( Frame );
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TFrameHolder.GetOwnerGrid: TSigFrameGrid;
begin
  Result := Owner as TSigFrameGrid
end;

procedure TFrameHolder.SetFrame(const Value: TFrame);
begin
  if assigned( fFrame ) then
  begin
    fFrame.Free;
  end;
  fFrame := Value;
  if assigned( fFrame ) then
  begin
    fFrame.Parent := fOwner;
    fFrame.Name := Owner.UniqueCellName;
  end;
end;

procedure TFrameHolder.SetSpecialData(const Value: TObject);
begin
  fData := Value;
  if assigned( Frame ) then
  begin
    if assigned( OwnerGrid.OnChangeData ) then
    begin
      OwnerGrid.OnChangeData( OwnerGrid, ItemIndex, Frame, fData );
    end;
  end
  else
  begin
    if assigned( OwnerGrid.OnCreateFrame ) then
    begin
      Frame := OwnerGrid.OnCreateFrame( ItemIndex, fData );
    end;
  end;
end;

end.
