unit DSMTextFile;

interface

TDSMFileMode = (edsmRead, eDSMWrite );

TDSMTextFile = class
  private
    iFileName : string;
    iIndent := 0;
  public
    constructor Create( pFileName : string );
end;

implementation

constructor TDSMTextFile.Create( pFileName : string );
begin
  inherited Create;
  iFileName := pFileName;
  iIndent := 0;
end;

end.
