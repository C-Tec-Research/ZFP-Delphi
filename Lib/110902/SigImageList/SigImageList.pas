unit SigImageList;

interface

uses
  Classes,
  Controls,
  Contnrs,
  SysUtils,
  Graphics;

type
  tImageObject = class
  private
    fFileName: string;
    fImageIndex: integer;
    fData: tObject;
    procedure SetFileName(const Value: string);
  protected
  public
    property FileName : string
             read fFileName
             write SetFileName;
    property ImageIndex : integer
             read fImageIndex
             write fImageIndex;
    property Data : tObject  // general object for use by host program
             read fData
             write fData;
  end;

type
  tSigImageList = class( tObjectList )
  private
    fImageList: tImageList;
    procedure SetImageList(const Value: tImageList);
    function GetImage(const i: integer): tImageObject;
    function LoadImage( const ImageName : string ) : integer;
  protected
  public
    constructor Create; reintroduce;
    function Add( NewFile : string ) : integer; reintroduce;
    function Insert( const index : integer; NewFile : string ) : integer; reintroduce;
    property ImageList : tImageList
             read fImageList
             write SetImageList;
    property Image[ const i : integer ] : tImageObject
             read GetImage;
    procedure Move( const pFrom, pTo : integer );
  end;


implementation

{ tSigImageList }

function tSigImageList.Add(NewFile: string): integer;
var
  i: Integer;
  iImageObject : tImageObject;
begin
  // we only add an image if it does not already exist
  for i := 0 to Count - 1 do
  begin
    if SameText( Image[ i ].FileName, NewFile ) then
    begin
      Result := Image[ i ].ImageIndex;
      exit;
    end;
  end;
  // not yet so create a new one
  iImageObject := tImageObject.Create;
  Result := inherited Add( iImageObject );
  iImageObject.FileName := NewFile;
  iImageObject.ImageIndex := LoadImage( NewFile );
end;

constructor tSigImageList.Create;
begin
  inherited Create( TRUE );
end;

function tSigImageList.GetImage(const i: integer): tImageObject;
begin
  Result := Items[ i ] as tImageObject;
end;

function tSigImageList.Insert(const index: integer; NewFile: string) : integer;
var
  i: Integer;
  iImageObject : tImageObject;
begin
  // we only add an image if it does not already exist
  for i := 0 to Count - 1 do
  begin
    if SameText( Image[ i ].FileName, NewFile ) then
    begin
      Result := Image[ i ].ImageIndex;
      exit;
    end;
  end;
  // not yet so create a new one
  iImageObject := tImageObject.Create;
  Result := index;
  inherited Insert( index, iImageObject );
  iImageObject.FileName := NewFile;
  iImageObject.ImageIndex := LoadImage( NewFile );
end;

function tSigImageList.LoadImage(const ImageName: string): integer;
var
  iBMP : tBitmap;
begin
  {
    adds and image to the image list, if it exists, returning the
    image index. If it does not exist, or the file does not exist
    returns -1;
  }
  if assigned( fImageList ) then
  begin
    if FileExists( ImageName ) then
    begin
      iBMP := tBitmap.Create;
      try
        iBMP.LoadFromFile( ImageName );
      except
        iBMP.Free;
        Result := -1;
        exit;
      end;
      Result := fImageList.Add( iBMP, nil );
      iBMP.Free;
    end
    else
    begin
      Result := -1;
    end;
  end
  else
  begin
    Result := -1;
  end;
end;

procedure tSigImageList.Move(const pFrom, pTo: integer);
var
  i : integer;
  iSave : tObject;
begin
  iSave := Items[ pFrom ];
  if pFrom < pTo then
    for i := pFrom downto pTo + 1 do
    begin
      Items[ i ] := Items[ i - 1 ];
    end
  else if pFrom > pTo then
  begin
    for i := pFrom to pTo - 1 do
    begin
      Items[ i ] := Items[ i + 1 ]
    end;
  end
  else
  begin
    //nothing to do
    exit;
  end;
  Items[ pTo ] := iSave;
end;

procedure tSigImageList.SetImageList(const Value: tImageList);
var
  i: Integer;
begin
  fImageList := Value;
  fImageList.Masked := FALSE;
  // add any existing values
  for i := 0 to Count - 1 do
  begin
    Image[ i ].ImageIndex := LoadImage( Image[ i ].FileName );
  end;
end;

{ tImageObject }

procedure tImageObject.SetFileName(const Value: string);
begin
  fFileName := Value;
end;

end.
