unit UnitBLOB;

{
  This unit defines Binary Large Object and StringList fields (TBLOB and TLAST).
  These are stored in randomly named files and the name of the file is stored
  as a relative file name. No comparisons are supported (except file name
  comparison which is pointless). The storage directory is global, but can be
  different for BLOB and LAST structures. Note that only one directory for
  each type can be specified, even if multiple databases are used!.
}

interface

uses
  System.Classes,
  System.SysUtils;

type
  TBLOB = record
  private
    class var fStorageDIR : string;
  public
    FileName : string[ 38 ];
    procedure StoreData( const pStream : TMemoryStream );
    procedure RetrieveData( const pStream : TMemoryStream );
    function FullName : string;
    class procedure SetStorageDIR( const pNewVal : string ); static;
    class function GetStorageDIR : string; static;
    const
      cFileType = '.BLOB';
  end;

  TLAST = record
  private
    class var fStorageDIR : string;
  public
    FileName : string[ 38 ];
    procedure StoreData( const pStream : TStrings );
    procedure RetrieveData( const pStream : TStrings );
    function FullName : string;
    class procedure SetStorageDIR( const pNewVal : string ); static;
    class function GetStorageDIR : string; static;
    const
      cFileType = '.LAST';
  end;

implementation

{ TBLOB }

{ TBLOB }

function TBLOB.FullName: string;
begin
  Result := fStorageDir + string(FileName) + cFileType;
end;

class function TBLOB.GetStorageDIR: string;
begin
  Result := fStorageDir;
end;

procedure TBLOB.RetrieveData(const pStream: TMemoryStream);
begin
  if FileName = '' then
  begin
    raise EFileNotFoundException.Create('File not found');
  end
  else
  begin
    pStream.LoadFromFile( FullName );
  end;
end;

class procedure TBLOB.SetStorageDIR(const pNewVal: string);
begin
  fStorageDir := Trim(pNewVal);
  if Length( fStorageDir ) > 0 then
  begin
    if fStorageDir[ Length( FStorageDir ) ] <> System.SysUtils.PathDelim then
    begin
      fStorageDir := fStorageDir + System.SysUtils.PathDelim;
    end;
  end;
end;

procedure TBLOB.StoreData(const pStream: TMemoryStream);
var
  iGUID : TGUID;
begin
  if FileName = '' then
  begin
    // yet to assign!
    repeat
      CreateGUID( iGUID );
      FileName := ShortString( GUIDToString( iGUID ) );
    until not FileExists( FullName );
  end;
  pStream.SaveToFile( FullName );
end;

{ TLAST }

function TLAST.FullName: string;
begin
  Result := fStorageDir + string(FileName) + cFileType;
end;

class function TLAST.GetStorageDIR: string;
begin
  Result := fStorageDir;
end;

procedure TLAST.RetrieveData(const pStream: TStrings);
begin
  if FileName = '' then
  begin
    raise EFileNotFoundException.Create('File not found');
  end
  else
  begin
    pStream.LoadFromFile( FullName );
  end;
end;

class procedure TLAST.SetStorageDIR(const pNewVal: string);
begin
  fStorageDir := Trim(pNewVal);
  if Length( fStorageDir ) > 0 then
  begin
    if fStorageDir[ Length( FStorageDir ) ] <> System.SysUtils.PathDelim then
    begin
      fStorageDir := fStorageDir + System.SysUtils.PathDelim;
    end;
  end;
end;

procedure TLAST.StoreData(const pStream: TStrings);
var
  iGUID : TGUID;
begin
  if FileName = '' then
  begin
    // yet to assign!
    repeat
      CreateGUID( iGUID );
      FileName := ShortString( GUIDToString( iGUID ) );
    until not FileExists( FullName );
  end;
  pStream.SaveToFile( FullName );
end;

end.
