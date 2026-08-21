unit UnitdsmDB;

{
  This unit manages databases using the classical flat table design.

  These are foundation classes; only descendants should be used
}

interface

uses
  System.contnrs;

type

  TdsmFlatFile = class
  private
    fFlatFile : file;
    fCurrRec: integer;
    fFileName: string;
    fReadBlockSize: integer;
    procedure SetCurrRec(const Value: integer);
    procedure SetFileName(const Value: string);
    procedure SetReadBlockSize(const Value: integer);
  protected
    fReadBuffer : array of byte;
    property FileName : string
             read fFileName
             write SetFileName;     // for most databases the file name is not visible, but could be exposed in descendants
  public
    constructor Create;

    function RecSize : integer; virtual; abstract;

    property CurrRec : integer
             read fCurrRec
             write SetCurrRec;
    property ReadBlockSize : integer
             read fReadBlockSize
             write SetReadBlockSize;

  end;

  TdsmFlatFileList = class( tObjectList )
  private
  public
    constructor Create; reintroduce;
  end;

  TdsmDB = class
  private
    fFlatFiles: TdsmFlatFileList;
  protected
    property FlatFiles : TdsmFlatFileList
             read fFlatFiles;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TdsmDB }

constructor TdsmDB.Create;
begin
  inherited Create;

  fFlatFiles := TdsmFlatFileList.Create;
end;

destructor TdsmDB.Destroy;
begin
  fFlatFiles.Free;

  inherited;
end;

{ TdsmFlatFile }

constructor TdsmFlatFile.Create;
begin
  inherited Create;
  fCurrRec := -1;
  ReadBlockSize := 1; // also sets the buffer
end;

procedure TdsmFlatFile.SetCurrRec(const Value: integer);
begin
  fCurrRec := Value;
  if Value >= 0 then
  begin
    Seek( fFlatFile, Value );
    BlockRead( fFlatFile, fReadBuffer, fReadBlockSize );
  end;
end;

procedure TdsmFlatFile.SetFileName(const Value: string);
begin
  fFileName := Value;
  AssignFile( fFlatFile, fFileName );
  Reset( fFlatFile, RecSize );
end;

procedure TdsmFlatFile.SetReadBlockSize(const Value: integer);
begin
  fReadBlockSize := Value;
  SetLength( fReadBuffer, fReadBlockSize * self.RecSize );
end;

{ TdsmFlatFileList }

constructor TdsmFlatFileList.Create;
begin
  inherited Create( TRUE );
end;

end.
