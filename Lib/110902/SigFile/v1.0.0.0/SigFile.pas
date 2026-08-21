unit SigFile;

interface

uses
  SigParse,
  SysUtils,
  Classes;

type

type
  tSigBaseProperty = class
end;

type
  tSigPropertyList = class( TList )
end;

type
  TSigFile = class(TComponent)
  protected
    iFileName : tFileName;
    iIsDirty : boolean;
    iPropertyList : tSigPropertyList;
  public
    constructor Create( AOwner : TComponent );
    property FileName : tFileName
             read iFileName
             write iFileName;
    function Save : boolean;
    function Load : boolean;
    property IsDirty : boolean
             read iIsDirty;
  published
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigFile]);
end;

constructor TSigFile.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  iFileName := '';
  iIsDirty := FALSE;
end;

function TSigFile.Save : boolean;
var
  f : TextFile;
begin
  if iFileName = '' then
  begin
    Result := FALSE;
  end
  else
  begin
    AssignFile(F, iFileName);
    Rewrite( F ); // Create new file

    // And finally close it
    CloseFile( F );
    // and reset dirty flag
    iIsDirty := FALSE;

    Result := TRUE;
  end;
end;

function tLrRfFile.Load : boolean;
var
  f : TextFile;
begin
  if iFileName = '' then
  begin
    Result := FALSE;
  end
  else
  begin
    AssignFile(F, iFileName);
    Reset( F ); // Go to start

    // And finally close it
    CloseFile( F );
    // and reset dirty flag
    iIsDirty := FALSE;

    Result := TRUE;
  end;
end;

end.
