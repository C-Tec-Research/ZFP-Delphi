unit DynEditDLL;

{ Handles the DLL Interface, including DLL based DynEdit Objects }

interface

uses
  Classes,
  Forms,
  Windows,
  ComCtrls,
  SysUtils,
  Graphics,
  DynEditConstructorButton,
  DynEditObject;

{ the various DLL function prototypes }
type TPlaceableObjectCount = function : Integer; stdcall;
type TPlaceableObjectPage = procedure( Dest : PChar ); stdcall;
type TGetBitmapFileName = procedure( index : integer; BitmapFileName : PChar ); stdcall;
type TGetHintText = procedure( index : integer; HintText : PChar ); stdcall;
type TGetCursor = function ( index : integer ): HCURSOR; stdcall;
type TDrawObjectGhost = procedure ( const Canvas : TCanvas; index : integer;
            var Rect : TRect ); stdcall;
type TClearObjectGhost = procedure ( const Canvas : TCanvas; index : integer;
            var Rect : TRect ); stdcall;


type
  TDynEditDLL = class( TObject )
  private
    { Private declarations }
  protected
    { Protected declarations }
    iDLLFileName : string;
    iHandle : HINST;
    fPlaceableObjectCount : TPlaceableObjectCount;
    fPlaceableObjectPage : TPlaceableObjectPage;
    fGetBitmapFileName : TGetBitmapFileName;
    fGetHintText : TGetHintText;
    fGetCursor : TGetCursor;
    fDrawObjectGhost : TDrawObjectGhost;
    fClearObjectGhost : TClearObjectGhost;
    function fGetPlaceableObjectCount : integer;
  public
    constructor Create( pHandle : HINST; pDLLFileName : string );
    destructor Destroy; override;

    procedure AddConstructorPage( TabControlObjects : TTabControl );
    procedure SetObjectConstructorBitmap( DynEditConstructorButton : TDynEditConstructorButton );

    procedure DrawObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
    procedure ClearObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );

{
    function CreateObject( ObjectType : string ) : TDynEditObject;
}
    function CreateObjectByIndex( index : integer ) : TDynEditObject;

    property PlaceableObjectCount : integer
             read fGetPlaceableObjectCount;
end;

type
  TDynEditDLLList = class(TList)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function fGetDLLItem( index : integer ) : TDynEditDLL;
  public
    { Public declarations }
    destructor Destroy; override;

    class function IsValidDLL( Handle : HINST ) : boolean;

    function AddDLL( DLLName : string ) : boolean;

    procedure AddConstructorPages( TabControlObjects : TTabControl );

    property DynEditDLLItem[ index : integer ] : TDynEditDLL
             read fGetDLLItem;
  published
    { Published declarations }
end;

implementation

{----------------------- TDynEditDLL -------------------}

constructor TDynEditDLL.Create( pHandle : HINST; pDLLFileName : string );
begin
  inherited Create;
  iDLLFileName := pDLLFileName;
  iHandle := pHandle;
  fPlaceableObjectCount := GetProcAddress( iHandle, 'PlaceableObjectCount' );
  fPlaceableObjectPage := GetProcAddress( iHandle, 'PlaceableObjectPage' );
  fGetBitmapFileName := GetProcAddress( iHandle, 'GetBitmapFileName' );
  fGetHintText := GetProcAddress( iHandle, 'GetHintText' );
  fGetCursor := GetProcAddress( iHandle, 'GetCursor' );
  fDrawObjectGhost := GetProcAddress( iHandle, 'DrawObjectGhost' );
  fClearObjectGhost := GetProcAddress( iHandle, 'ClearObjectGhost' );
end;

destructor TDynEditDLL.Destroy;
begin
  FreeLibrary( iHandle );
  inherited Destroy;
end;

procedure TDynEditDLL.AddConstructorPage( TabControlObjects : TTabControl );
var
  PageName : PChar;
begin
  PageName := StrAlloc( 255 );
  StrCopy( PageName, 'Empty' );
  fPlaceableObjectPage( PageName );
  TabControlObjects.Tabs.Add( PageName );
  StrDispose( PageName );
end;

function TDynEditDLL.fGetPlaceableObjectCount : integer;
begin
  Result := fPlaceableObjectCount;
end;

procedure TDynEditDLL.SetObjectConstructorBitmap( DynEditConstructorButton : TDynEditConstructorButton );
var
  Temp : PChar;
begin
  Temp := StrAlloc( 255 );
  with DynEditConstructorButton do
  begin
    if Assigned( fGetBitmapFileName ) then
    begin
      fGetBitmapFileName( InternalIndex, Temp );
      Glyph.LoadFromFile( Temp );
      NumGlyphs := 4;
    end
    else
    begin

    end;

    if Assigned( fGetHintText ) then
    begin
      fGetHintText( InternalIndex, Temp );
      Hint := Temp;
    end
    else
    begin
      Hint := '';
    end;

    if Assigned( fGetCursor ) then
    begin
      Screen.Cursors[ InternalIndex ] := fGetCursor( InternalIndex );
    end
    else
    begin
      Screen.Cursors[ InternalIndex ] := LoadCursor(0, IDC_ARROW);
    end;
  end;
  StrDispose( Temp );
end;

procedure TDynEditDLL.DrawObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
begin
  if assigned( fDrawObjectGhost ) then
     fDrawObjectGhost( Canvas, index, Rect )
  else
    Canvas.DrawFocusRect( Rect );

end;

procedure TDynEditDLL.ClearObjectGhost( const Canvas : TCanvas; index : integer;
            var Rect : TRect );
begin
  if assigned( fClearObjectGhost ) then
     fClearObjectGhost( Canvas, index, Rect )
  else
    Canvas.DrawFocusRect( Rect );
    
end;


{------------------------ TDynEditDLLList --------------}

destructor TDynEditDLLList.Destroy;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    DynEditDLLItem[ i ].Free;
  end;
  inherited Destroy;
end;

function TDynEditDLLList.fGetDLLItem( index : integer ) : TDynEditDLL;
begin
  result := Items[ index ];
end;

function TDynEditDLLList.AddDLL( DLLName : string ) : boolean;
var
  Handle : HINST;
begin
  { check that the DLL Exists }
  Handle := LoadLibrary( PChar(DLLName) );
  if Handle > 0 then
  begin
    Result := IsValidDLL( Handle );
    if Result then Add( TDynEditDLL.Create( Handle, DLLName ));
  end
  else
  begin
    Result := FALSE;
  end;
end;

class function TDynEditDLLList.IsValidDLL( Handle : HINST ) : boolean;
begin
  Result := TRUE;
  if GetProcAddress( Handle, 'PlaceableObjectCount' ) = nil
     then Result := FALSE;
  if GetProcAddress( Handle, 'PlaceableObjectPage' ) = nil
     then Result := FALSE;
  { GetBitmapFileName is an optional function - there may be
    no constructor buttons }
end;

procedure TDynEditDLLList.AddConstructorPages( TabControlObjects : TTabControl );
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    DynEditDLLItem[ i ].AddConstructorPage( TabControlObjects );
  end;
end;


end.
