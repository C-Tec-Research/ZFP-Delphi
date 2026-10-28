unit UnitFrameIconEditor;

{
  This editor organises icons and allows new icons to be added.
  The images exist in subdirectoriesoff a names root with
  each subdirectory representing a tab on the editor. The currently
  selected icon is returned as an address but we can also directly
  access the graphics. In the root directory are special icons that
  the user cannot directly access. All entries must be loadable
  into the bitmap table. If allowed, a user can drag and drop images from
  one tab to another, and create tabs, cut, copy and paste, etc.

  One advantage of this approach is that a new install does not destroy
  anything the user has added.
}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtDlgs,
  ComCtrls,
  ExtCtrls,
  Contnrs,
  ImgList,
  StdCtrls,
  Buttons,
  Grids,
  System.UITypes,
  //SigNETStringGrid,
  SigNET.TStringGrid,
  UnitNewIconGroupName, System.ImageList;

type
  tNumberedFile = class
  private
    fFileName: string;
    fFilePosition: integer;
    fPath: string;
    fSuspendRename: boolean;
    fOldFileName, fNewFileName : string;
    fImageList: tImageList;
    function GetPositionalFileName: string;
    procedure SetFilePosition(const Value: integer);
    procedure SetSuspendRename(const Value: boolean);
  protected
    procedure SetPositionalFileName(const Value: string); virtual;
  public
    constructor Create( const pImageList : tImageList; const pPositionalFileName : string ); reintroduce; virtual;
    property FileName : string
             read fFileName
             write fFileName;          // name minus position  and path
    property Path : string
             read fPath
             write fPath;
    property FilePosition : integer
             read fFilePosition
             write SetFilePosition;
    property PositionalFileName : string
             read GetPositionalFileName
             write SetPositionalFileName;
    property SuspendRename : boolean
             read fSuspendRename
             write SetSuspendRename;
    property ImageList : tImageList
             read fImageList;
  end;

  tNumberedFileList = class( tObjectList )
  private
    fSuspendRename: boolean;
    fSearchRec : tSearchRec;
    fRootDir: string;
    fImageList: tImageList;
    function GetNumberedFile(const i: integer): tNumberedFile;
    procedure SetSuspendRename(const Value: boolean);
    procedure SetRootDir(const Value: string);
  protected
    function SearchPath : string; virtual; abstract;
    function SearchAttr : integer; virtual; abstract;
    function AddSearchChild : tNumberedFile; virtual; abstract;
  public
    constructor Create( const pImageList : tImageList ); reintroduce;
    procedure Add( pNumberedFile : tNumberedFile ); reintroduce; // because this can re-order the list it makes no sense to return the position

    property NumberedFile[ const i : integer ] : tNumberedFile
             read GetNumberedFile;
    property SuspendRename : boolean
             read fSuspendRename
             write SetSuspendRename;
    property RootDir : string // this iterates through the allowed files executing OnFindFile for each entry
             read fRootDir
             write SetRootDir;
    property ImageList : tImageList
             read fImageList;
  end;

  tIconObject = class( tNumberedFile )
  private
    fIconIndex: integer;
  public
    constructor Create( const pImageList : tImageList; const pPositionalFileName : string ); override;
    property IconIndex : integer
             read fIconIndex;
  end;

  tIconList = class( tNumberedFileList )
  protected
    function SearchPath : string; override;
    function SearchAttr : integer; override;
    function AddSearchChild : tNumberedFile; override;
  public
    function AddNamedChild( const pName : string ) : tIconObject;
  end;

  tTabObject = class( tNumberedFile )
  private
    fIconList: tIconList;
    function GetCount: integer;
    function GetIconObject(const i: integer): tIconObject;
  protected
    procedure SetPositionalFileName(const Value: string); override;
  public
    constructor Create( const pImageList : tImageList; const pPositionalFileName : string ); override;
    destructor Destroy; override;

    property IconList : tIconList
             read fIconList;
    property Count : integer
             read GetCount;
    property IconObject[ const i : integer ] : tIconObject
             read GetIconObject;
  end;

  tTabObjectList = class( tNumberedFileList )
  private
    function GetTabObject(const i: integer): tTabObject;
    function GetIconCount: integer;
    function GetIconObject(const index: integer): tIconObject;
  protected
    function SearchPath : string; override;
    function SearchAttr : integer; override;
    function AddSearchChild : tNumberedFile; override;
  public
    property TabObject[ const i : integer ] : tTabObject
             read GetTabObject;
    property IconCount : integer
             read GetIconCount;
    property IconObject[ const index : integer ] : tIconObject
             read GetIconObject;
    function AddNamedChild( const pName : string ) : tTabObject;
  end;

type
  TFrameIconEditor = class(TFrame)
    PanelEdit: TPanel;
    TabControlClasses: TTabControl;
    ImageListMain: TImageList;
    BitBtnLoadNew: TBitBtn;
    BitBtn1: TBitBtn;
    OpenPictureDialog: TOpenPictureDialog;
    StringGridMain: TStringGrid;
    procedure TabControlClassesChange(Sender: TObject);
    procedure SigNETStringGridMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtnLoadNewClick(Sender: TObject);
  private
    { Private declarations }
    fRootDir: string;
    fShowAll: boolean;
    fTabObjects : tTabObjectList;
    fAllTab: integer;
    fAllText: string;
    procedure SetRootDir(const Value: string);
    procedure SetShowAll(const Value: boolean);
    function GetIconWidth: integer;
    procedure SetIconWidth(const Value: integer);
    function GetIconHeight: integer;
    procedure SetIconHeight(const Value: integer);
    function GetAllowEdit: boolean;
    procedure SetAllowEdit(const Value: boolean);
    procedure SetAllText(const Value: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RebuildTabs;

    property ShowAll : boolean
             read fShowAll
             write SetShowAll;
    property RootDir : string
             read fRootDir
             write SetRootDir;
    property AllTab : integer
             read fAllTab
             write fAllTab;
    property IconWidth : integer
             read GetIconWidth
             write SetIconWidth;
    property IconHeight : integer
             read GetIconHeight
             write SetIconHeight;
    property AllowEdit : boolean
             read GetAllowEdit
             write SetAllowEdit;
    property AllText : string
             read fAllText
             write SetAllText;
  end;

implementation

{$R *.dfm}

{ TFrameIconEditor }

procedure TFrameIconEditor.BitBtn1Click(Sender: TObject);
var
  iNewTab : integer;
  iTabObject : tTabObject;
begin
  if FormNewIconGroupName.Execute( RootDir ) then
  begin
    iTabObject := self.fTabObjects.AddNamedChild( RootDir + FormNewIconGroupName.GroupName );
    iNewTab := TabControlClasses.Tabs.AddObject( iTabObject.FileName, iTabObject );
    TabControlClasses.TabIndex := iNewTab;
    StringGridMain.Invalidate;
  end;
end;

procedure TFrameIconEditor.BitBtnLoadNewClick(Sender: TObject);
var
  iTabObject : tTabObject;
  iCopyFrom : string;
  iCopyTo : string;
begin
  iTabObject := TabControlClasses.Tabs.Objects[ TabControlClasses.TabIndex ] as tTabObject;
  if assigned( iTabObject ) then
  begin
    with OpenPictureDialog do
    begin
      InitialDir := RootDir;
      if Execute then
      begin
        iCopyFrom := FileName;
        iCopyTo := iTabObject.IconList.RootDir + ExtractFileName( FileName );
        if FileExists( iCopyTo ) then
        begin
          raise exception.Create( 'Duplicate File' );
        end;
        CopyFile( @iCopyFrom, @iCopyTo, TRUE );
        iTabObject.IconList.AddNamedChild( iCopyTo );
        TabControlClassesChange( Sender );
      end;
    end;
  end;
end;

constructor TFrameIconEditor.Create(AOwner: TComponent);
begin
  inherited;
  fTabObjects := tTabObjectList.Create( ImageListMain );
  AllText := '<All>';
end;

destructor TFrameIconEditor.Destroy;
begin
  fTabObjects.Free;
  inherited;
end;

function TFrameIconEditor.GetAllowEdit: boolean;
begin
  Result := PanelEdit.Visible;
end;

function TFrameIconEditor.GetIconHeight: integer;
begin
  Result := ImageListMain.Height;
end;

function TFrameIconEditor.GetIconWidth: integer;
begin
  Result := ImageListMain.Width;
end;

procedure TFrameIconEditor.RebuildTabs;
var
  i : integer;
  iTabObject : tTabObject;
begin
  if RootDir = '' then
  begin
    exit;
  end;

  fTabObjects.RootDir := self.RootDir;

  with TabControlClasses.Tabs do
  begin
    Clear;
    if ShowAll then
    begin
      AllTab := AddObject( AllText, nil );
    end;
    for i := 0 to fTabObjects.Count - 1 do
    begin
      iTabObject := fTabObjects.TabObject[ i ];
      AddObject( iTabObject.fFileName, iTabObject );
    end;
  end;
  TabControlClasses.TabIndex := 0;
end;

procedure TFrameIconEditor.SetAllowEdit(const Value: boolean);
begin
  PanelEdit.Visible := Value;
end;

procedure TFrameIconEditor.SetAllText(const Value: string);
begin
  fAllText := Value;
end;

procedure TFrameIconEditor.SetIconHeight(const Value: integer);
begin
  ImageListMain.Height := Value;
end;

procedure TFrameIconEditor.SetIconWidth(const Value: integer);
begin
  ImageListMain.Width := Value;
end;

procedure TFrameIconEditor.SetRootDir(const Value: string);
begin
  fRootDir := Value;
  RebuildTabs;
end;

procedure TFrameIconEditor.SetShowAll(const Value: boolean);
begin
  fShowAll := Value;
  RebuildTabs;
end;

procedure TFrameIconEditor.SigNETStringGridMainDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iCellIndex, iTab, iImageIndex : integer;
  iTabObject : tTabObject;
  iSaveColour, iSavePenColour : tColor;
begin
  iCellIndex := ARow * StringGridMain.ColCount + ACol;
  iTab := TabControlClasses.TabIndex;
  if iTab < 0 then
  begin
    // should not get here
    with StringGridMain do
    begin
      iSaveColour := Canvas.Brush.Color;
      iSavePenColour := Canvas.Pen.Color;
      Canvas.Brush.Color := clWhite;
      Canvas.Pen.Color := clWhite;
      Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right+1, Rect.Bottom+1 );
      Canvas.Brush.Color := iSaveColour;
      Canvas.Pen.Color := iSavePenColour;
    end;
  end
  else
  begin
    iTabObject := TabControlClasses.Tabs.Objects[ iTab ] as tTabObject;
    if assigned( iTabObject ) then
    begin
      if iCellIndex >= iTabObject.Count then
      begin
        // should not get here
        with StringGridMain do
        begin
          iSaveColour := Canvas.Brush.Color;
          iSavePenColour := Canvas.Pen.Color;
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Color := clWhite;
          Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right+1, Rect.Bottom+1 );
          Canvas.Brush.Color := iSaveColour;
          Canvas.Pen.Color := iSavePenColour;
        end;
      end
      else
      begin
        with StringGridMain do
        begin
          iImageIndex := iTabObject.IconObject[ iCellIndex ].IconIndex;
          ImageListMain.Draw( Canvas, Rect.Left, Rect.Top, iImageIndex );
        end;
      end;
    end
    else
    begin
      if iCellIndex >= fTabObjects.IconCount then
      begin
        // should not get here
        with StringGridMain do
        begin
          iSaveColour := Canvas.Brush.Color;
          iSavePenColour := Canvas.Pen.Color;
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Color := clWhite;
          Canvas.Rectangle( Rect.Left, Rect.Top, Rect.Right+1, Rect.Bottom+1 );
          Canvas.Brush.Color := iSaveColour;
          Canvas.Pen.Color := iSavePenColour;
        end;
      end
      else
      begin
        with StringGridMain do
        begin
          iImageIndex := fTabObjects.IconObject[ iCellIndex ].IconIndex;
          ImageListMain.Draw( Canvas, Rect.Left, Rect.Top, iImageIndex );
        end;
      end;
    end;
  end;
end;

procedure TFrameIconEditor.TabControlClassesChange(Sender: TObject);
var
  iColCount, iColWidth, iRowCount, iIconCount, iMinRowCount : integer;
  iTabObject : tTabObject;
begin
  BitBtnLoadNew.Enabled := TabControlClasses.TabIndex = AllTab;
  iTabObject := TabControlClasses.Tabs.Objects[ TabControlClasses.TabIndex ] as tTabObject;
  with StringGridMain do
  begin
    iMinRowCount := 1 + ClientHeight div DefaultRowHeight;
    if RowCount < iMinRowCount then
    begin
      RowCount := iMinRowCount;
    end;
    iColWidth := DefaultColWidth + GridLineWidth;
    iColCount := (ClientWidth - GridLineWidth ) div iColWidth;
    if assigned( iTabObject ) then
    begin
      iIconCount := iTabObject.IconList.Count;
    end
    else
    begin
      iIconCount := fTabObjects.IconCount;
    end;
    iRowCount := 1 + (iIconCount div iColCount );
    if iRowCount < iMinRowCount then
    begin
      iRowCount := iMinRowCount;
    end;
    if ColCount <> iColCount then
    begin
      ColCount := iColCount;
    end;
    if RowCount < iRowCount then
    begin
      RowCount := iRowCount;
    end;

    Invalidate;
  end;
end;

{ tTabObject }

constructor tTabObject.Create( const pImageList : tImageList; const pPositionalFileName : string );
begin
  inherited;
  fIconList := tIconList.Create( pImageList );
end;

destructor tTabObject.Destroy;
begin
  fIconList.Free;
  inherited;
end;

function tTabObject.GetCount: integer;
begin
  Result := IconList.Count;
end;

function tTabObject.GetIconObject(const i: integer): tIconObject;
begin
  Result := fIconList.Items[ i ] as tIconObject;
end;

procedure tTabObject.SetPositionalFileName(const Value: string);
begin
  inherited;
  fIconList.RootDir := Value;
end;

{ tIconObject }

constructor tIconObject.Create( const pImageList : tImageList; const pPositionalFileName : string );
var
  iBitMap : tBitmap;
begin
  inherited;
  fIconIndex := -1;  // just in case of failure
  iBitMap := tBitMap.Create;
  try
    iBitmap.LoadFromFile( pPositionalFileName );
    fIconIndex := ImageList.Add( iBitMap, nil );
  finally
    iBitMap.Free;
  end;
end;

{ tTabObjectList }

function tTabObjectList.AddNamedChild(const pName: string): tTabObject;
begin
  Result := tTabObject.Create( ImageList, pName );
  Add( Result );
end;

function tTabObjectList.AddSearchChild: tNumberedFile;
begin
  Result := tTabObject.Create( ImageList, fSearchRec.Name );
  Add( Result );
end;

function tTabObjectList.GetIconCount: integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    inc( Result, TabObject[ i ].Count );
  end;
end;

function tTabObjectList.GetIconObject(const index: integer): tIconObject;
var
  iIndex : integer;
  i: Integer;
begin
  iIndex := index;
  for i := 0 to Count - 1 do
  begin
    with TabObject[ i ] do
    begin
      if iIndex < Count then
      begin
        Result := IconObject[ iIndex ];
        exit;
      end
      else
      begin
        dec( iIndex, Count );
      end;
    end;
  end;
  // else
  Result := nil;
end;

function tTabObjectList.GetTabObject(const i: integer): tTabObject;
begin
  Result := Items[ i ] as tTabObject;
end;

function tTabObjectList.SearchAttr: integer;
begin
  result := faDirectory;
end;

function tTabObjectList.SearchPath: string;
begin
  result := RootDir + '*.*';
end;

{ tNumberedFile }

constructor tNumberedFile.Create(const pImageList: tImageList; const pPositionalFileName : string);
begin
  inherited Create;
  fImageList := pImageList;
  PositionalFileName := pPositionalFileName;
end;

function tNumberedFile.GetPositionalFileName: string;
begin
  Result := Path + IntToStr( FilePosition ) + '_' + FileName;
end;

procedure tNumberedFile.SetFilePosition(const Value: integer);
begin
  // this implies a file must be renamed
  if SuspendRename then
  begin
    fFilePosition := Value;
    fNewFileName := PositionalFileName; // after changing index
  end
  else
  begin
    fOldFileName := PositionalFileName; // before changing index
    fFilePosition := Value;
    fNewFileName := PositionalFileName; // after changing index
    RenameFile( fOldFileName, fNewFileName );
  end;
end;

procedure tNumberedFile.SetPositionalFileName(const Value: string);
var
  iName : string;
  iPos : integer;
begin
  Path := ExtractFilePath( Value );
  iName := ExtractFileName( Value );
  iPos := Pos( '_', iName );
  FilePosition := StrToIntDef( Copy( iName, 1, iPos - 1 ), -1); // -1 = last. Will be replaced by owner
  FileName := Copy( iName, iPos + 1, Length( iName ));
  fNewFileName := Value;
  if not SuspendRename then
  begin
    fOldFileName := Value;
  end;
end;

procedure tNumberedFile.SetSuspendRename(const Value: boolean);
begin
  if fSuspendRename <> Value then
  begin
    fSuspendRename := Value;
    if Value then
    begin
      fOldFileName := PositionalFileName;
      fNewFileName := fOldFileName;
    end
    else if fOldFileName <> fNewFileName then
    begin
      RenameFile( fOldFileName, fNewFileName );
    end;
  end;
end;

{ tNumberedFileList }

procedure tNumberedFileList.Add(pNumberedFile: tNumberedFile);
var
  i, iPos, iVal : integer;
begin
  { adds or inserts. renumbers as appropriate }
  if pNumberedFile.FilePosition = 9999 then
  begin
    pNumberedFile.FilePosition := inherited Add( pNumberedFile );
  end
  else
  begin
    iPos := 0;
    iVal := pNumberedFile.FilePosition;
    for i := 0 to Count - 1 do
    begin
      if iVal >= NumberedFile[ i ].FilePosition then
      begin
        inherited Insert( i, pNumberedFile );
        iPos := i + 1;
        break;
      end;
    end;
    // renumber rest if needed
    for i := iPos to Count - 1 do
    begin
      inc( iVal );
      if NumberedFile[ i ].FilePosition < iVal then
      begin
        NumberedFile[ i ].FilePosition := iVal;
        inc( iVal );
      end
      else
      begin
        break;
      end;
    end;
  end;
end;

constructor tNumberedFileList.Create( const pImageList : tImageList );
begin
  inherited Create( TRUE );
  fImageList := pImageList;
end;

function tNumberedFileList.GetNumberedFile(const i: integer): tNumberedFile;
begin
  Result := Items[ i ] as tNumberedFile;
end;

procedure tNumberedFileList.SetRootDir(const Value: string);
var
  iChild : tNumberedFile;
begin
  if fRootDir <> Value then
  begin
    fRootDir := Value;
    // forces us to start a new list
    Clear;
    ImageList.Clear;
    if FindFirst( SearchPath, SearchAttr, fSearchRec ) = 0 then
    begin
      repeat
        iChild := AddSearchChild;
        iChild.PositionalFileName := fSearchRec.Name;
      until FindNext( fSearchRec ) <> 0;
      FindClose( fSearchRec );
    end;
  end;
end;

procedure tNumberedFileList.SetSuspendRename(const Value: boolean);
var
  i: Integer;
begin
  fSuspendRename := Value;
  for i := 0 to Count - 1 do
  begin
    NumberedFile[ i ].SuspendRename := Value;
  end;
end;

{ tIconList }

function tIconList.AddNamedChild(const pName: string): tIconObject;
begin
  result := tIconObject.Create( ImageList, pName );
  Add( Result );
end;

function tIconList.AddSearchChild: tNumberedFile;
begin
  result := tIconObject.Create( ImageList, fSearchRec.Name );
  Add( Result );
end;

function tIconList.SearchAttr: integer;
begin
  Result := 0;
end;

function tIconList.SearchPath: string;
begin
  Result := RootDir + '*.bmp';
end;

end.
