unit SigFileImageList;

interface

uses
  SigFile,
  ErrorList,
  Classes,
  Controls,
  Contnrs,
  SysUtils,
  Graphics;

type

  tSigFileImage = class( tSigCompoundProperty )
  private
    fFileName: tSigRelativeFileProperty;
    fIconIndex: integer;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property FileName : tSigRelativeFileProperty
             read fFileName;
    property IconIndex : integer // not a saved property!
             read fIconIndex
             write fIconIndex;
  end;

  tSigFileImageList = class( tSigObjectList )
  private
    fImageList: tImageList;
    procedure SetImageList(const Value: tImageList);
    function GetImage(const i: integer): tSigFileImage;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure BuildImageList;
    function Load( pFile : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;

    property ImageList : tImageList
             read fImageList
             write SetImageList;

    property Image[ const i : integer ] : tSigFileImage
             read GetImage;

    function FileToIndex( const pFile: string ) : integer;  // file name in absolute form
    function FileToIcon( const pFile: string ) : integer;

    function IndexToFile( const i : integer ) : string;

  end;

implementation

{ tSigFileImageList }

procedure tSigFileImageList.BuildImageList;
var
  i: integer;
  iFileName : string;
  iBMP : tBitmap;
begin
  if assigned( fImageList ) then
  begin
    with fImageList do
    begin
      Clear;
      for i := 0 to Max do
      begin
        iFileName := Image[ i ].FileName.Value;
        if FileExists( iFileName ) then
        begin
          iBMP := tBitmap.Create;
          iBMP.LoadFromFile( iFileName );
          Image[ i ].IconIndex := Add( iBMP, nil );
          iBMP.Free;
        end
        else
        begin
          Image[ i ].IconIndex := -1;
        end;
      end;
    end;
  end;
end;

constructor tSigFileImageList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyname, pOwner, tSigFileImage );

end;

function tSigFileImageList.FileToIcon(const pFile: string): integer;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if SameText( Image[ i ].FileName.Value, pFile ) then
    begin
      Result := Image[ i ].IconIndex;
      exit;
    end;
  end;
  // else
  Result := -1;
end;

function tSigFileImageList.FileToIndex(const pFile: string): integer;
var
  i: Integer;
begin
  for i := 0 to Max do
  begin
    if SameText( Image[ i ].FileName.Value, pFile ) then
    begin
      Result := i;
      exit;
    end;
  end;
  // else
  Result := -1;
end;

function tSigFileImageList.GetImage(const i: integer): tSigFileImage;
begin
  Result := Entry[ i ] as tSigFileImage;
end;

function tSigFileImageList.IndexToFile(const i: integer): string;
begin
  if i < 0 then
  begin
    Result := '';
  end
  else
  begin
    Result := Image[ i ].FileName.Value;
  end;
end;

function tSigFileImageList.Load(pFile: tStrings; var pLine: integer;
  pErrors: tErrorList): boolean;
begin
  Result := Inherited Load( pFile, pLine, pErrors );
  BuildImageList;
end;

procedure tSigFileImageList.SetImageList(const Value: tImageList);
begin
  fImageList := Value;
  BuildImageList;
end;

{ tSigFileImage }

constructor tSigFileImage.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fFileName := tSigRelativeFileProperty.Create( 'File Name', self );
  fIconIndex := -1;

end;

end.



