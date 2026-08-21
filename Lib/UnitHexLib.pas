unit UnitHexLib;

{
  HexLib is a proprietry extension to the Intel Hex format.
  Intel Hex files can be imported into and exported from
  a HexLib file.

  The file can also import assembler files to determine EEPROM names
  and locations for version mapping

  Intel Hex Format
    :10008000AF5F67F0602703E0322CFA92007780C361
    : = start of record (change)
    ? = start of query record
    * = error record
    = = user defined record (not directly supported)
     10 = Rec Length in hex excluding start of record and checksum
       0080 = load address
           00 = record type
             AF5F67F0602703E0322CFA92007780C3 = data
                                             61 = checksum
     Sum of all bytes excluding record start but including checksum = 00

  Record types
    Intel Hex
      00 - Data
      01 - EOF record
      02 - Extended segment address record
      03 - Start Segment address record
      04 - Extended linear address record
      05 - Start linear address record
    Extensions for hexlib files
      F0 - EEPROM data
      F1 - EOF record
      FE - EEPROM Map - data = 3 byes of version data and variable length name
      FF - Version number - 3 hex digits Major, Minor and Build

      E0 - I2C EEPROM or Flash data
      E1 - EOF Record
      E2 - Extended segment address record

}

interface

uses
  Common,
  Contnrs,
  Classes,
  SysUtils;

type
  tIntelHexRecord = class
  private
    fAddress: word;
  published
  public
    property Address : word
             read fAddress
             write fAddress;
    function Data : string; virtual; abstract; // the data part of the record
    procedure SetData( NewVal : string ); virtual; abstract;
    function Rec( Delim : char = ':' ) : string;
    class function DataType : byte; virtual; abstract;
  end;

  tIntelHexEmptyRecord = class( tIntelHexRecord )
  public
    function Data : string; override;
    procedure SetData( NewVal : string ); override;
  end;

  tIntelHexFixedDataRecord = class( tIntelHexRecord )
  private
    fDataString: string;
  public
    property DataString : string
             read fDataString
             write fDataString;
    function Data : string; override;
    procedure SetData( NewVal : string ); override;
  end;

  tIntelHexDataRecord = class( tIntelHexFixedDataRecord )
  published
  public
    class function DataType : byte; override;
  end;

  tIntelHexEOF = class( tIntelHexEmptyRecord )
  public
    class function DataType : byte; override;
  end;

  tIntelHexExtendedSegmentAddressRecord = class( tIntelHexFixedDataRecord )
  public
    class function DataType : byte; override;
  end;

  tIntelHexStartSegmentAddressRecord = class( tIntelHexEmptyRecord )
  public
    class function DataType : byte; override;
  end;

  tIntelHexExtendedLinearAddressRecord = class( tIntelHexFixedDataRecord )
  public
    class function DataType : byte; override;
  end;

  tIntelHexStartLinearAddressRecord = class( tIntelHexEmptyRecord )
  public
    class function DataType : byte; override;
  end;

//------------------- extensions ----------------

  tIntelHexEEPROMDataRecord = class( tIntelHexFixedDataRecord )
  published
  public
    class function DataType : byte; override;
  end;

  tIntelHexVersionRecord = class( tIntelHexRecord )
  private
    fVersionMinor: byte;
    fVersionMajor: byte;
    fVersionBuild: byte;
  published
  public
    property VersionMajor : byte
             read fVersionMajor
             write fVersionMajor;
    property VersionMinor : byte
             read fVersionMinor
             write fVersionMinor;
    property VersionBuild : byte
             read fVersionBuild
             write fVersionBuild;
    function Data : string; override;
    procedure SetData( NewVal : string ); override;
    class function DataType : byte; override;
  end;

  tIntelHexMapRecord = class( tIntelHexVersionRecord )
  private
    fName: string;
  published
  public
    property Name : string
             read fName
             write fName;
    function Data : string; override;
    procedure SetData( NewVal : string ); override;
    class function DataType : byte; override;
  end;

  tIntelHexEEPROM_EOF = class( tIntelHexEmptyRecord )
  public
    class function DataType : byte; override;
  end;

{ tIntelHexFile }

  tIntelHexFile = class( tObjectList )
  private
    fVersionRec : tIntelHexVersionRecord;
    fIsDirty: boolean;
    fFileName: string;
    fMigrationList: tStringList;
    function GetVersionBuild: integer;
    function GetVersionMajor: integer;
    function GetVersionMinor: integer;
    function GetItem(const index: integer): tIntelHexRecord;
    procedure SetVersionBuild(const Value: integer);
    procedure SetVersionMajor(const Value: integer);
    procedure SetVersionMinor(const Value: integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile( const pFileName : string );
    procedure ImportHexFile( const pFileName : string );
    procedure ImportEEPFile( const pFileName : string );
    procedure ImportASMFile( const pFileName : string ); // the most difficult
    procedure ClearHexFileRecords;
    procedure ClearEEPFileRecords;
    procedure ClearASMFileRecords; // for current version only!
    procedure SaveToFile( const pFileName : string );
    procedure SaveToStringList( pStringList : tStrings );
    function Add( NewVal : tIntelHexRecord ) : integer; reintroduce;
    function IntelHexObject( FromString : string ) : tIntelHexRecord;
    function IntelEEPObject( FromString : string ) : tIntelHexRecord;
             // takes a hex record and creates the EEP equivaleny
    property VersionMajor : integer
             read GetVersionMajor
             write SetVersionMajor;
    property VersionMinor : integer
             read GetVersionMinor
             write SetVersionMinor;
    property VersionBuild : integer
             read GetVersionBuild
             write SetVersionBuild;
    property Item[ const index : integer ] : tIntelHexRecord
             read GetItem;
    property IsDirty : boolean
             read fIsDirty;
    property FileName : string
             read fFileName;
    procedure New;
    property MigrationList : tStringList
             read fMigrationList;
    procedure SaveMigrationListToStringList( pStringList : tStrings );
    procedure AddMigrationEntry( vMajor, vMinor, vBuild : integer );
    function Version : string;
  end;

implementation

{ tIntelHexRecord }

function tIntelHexRecord.Rec( Delim : char = ':' ): string;
var
  CS : byte;
  i : integer;
begin
  CS := 0;
  Result := Data;
  Result := Delim + IntToHex( Length( Result ) div 2, 2 )
                  + IntToHex( Address, 4 )
                  + IntToHex( DataType, 2 )
                  + Result;
  for i := 1 to (Length( Result ) div 2) do
  begin
    dec( CS, HexToInt( Copy( Result, 2 * i, 2 )));
  end;
  Result := Result + IntToHex( CS, 2 );

end;

{ tIntelHexDataRecord }

class function tIntelHexDataRecord.DataType: byte;
begin
  Result := $00;
end;

{ tIntelHexEOF }

class function tIntelHexEOF.DataType: byte;
begin
  Result := $01;
end;

{ tIntelHexEmptyRecord }

function tIntelHexEmptyRecord.Data: string;
begin
  Result := '';
end;

procedure tIntelHexEmptyRecord.SetData(NewVal: string);
begin
  if NewVal <> '' then
  begin
    raise exception.Create('Illegal Data');
  end;
end;

{ tIntelHexFixedDataRecord }

function tIntelHexFixedDataRecord.Data: string;
begin
  Result := fDataString;
end;

procedure tIntelHexFixedDataRecord.SetData(NewVal: string);
begin
  fDataString := NewVal;
end;

{ tIntelHexExtendedSegmentAddressRecord }

class function tIntelHexExtendedSegmentAddressRecord.DataType: byte;
begin
  Result := $02;
end;

{ tIntelHexStartSegmentAddressRecord }

class function tIntelHexStartSegmentAddressRecord.DataType: byte;
begin
  Result := $03;
end;

{ tIntelHexExtendedLinearAddressRecord }

class function tIntelHexExtendedLinearAddressRecord.DataType: byte;
begin
  Result := $04;
end;

{ tIntelHexStartLinearAddressRecord }

class function tIntelHexStartLinearAddressRecord.DataType: byte;
begin
  Result := $05;
end;

{ tIntelHexEEPROMDataRecord }

class function tIntelHexEEPROMDataRecord.DataType: byte;
begin
  Result := $F0;
end;

{ tIntelHexVersionRecord }

function tIntelHexVersionRecord.Data: string;
begin
  Result := IntToHex( VersionMajor, 2 )
          + IntToHex( VersionMinor, 2 )
          + IntToHex( VersionBuild, 2 );
end;

class function tIntelHexVersionRecord.DataType: byte;
begin
  Result := $FF;
end;

procedure tIntelHexVersionRecord.SetData(NewVal: string);
begin
  if Length( NewVal ) <> 6 then
  begin
    raise exception.Create( 'Illegal Data Length' );
  end;
  // else
  VersionMajor := HexToInt( Copy( NewVal, 1, 2 ));
  VersionMinor := HexToInt( Copy( NewVal, 3, 2 ));
  VersionBuild := HexToInt( Copy( NewVal, 5, 2 ));
end;

{ tIntelHexMapRecord }

function tIntelHexMapRecord.Data: string;
var
  i : integer;
begin
  Result := inherited Data;
  for i := 0 to Length( fName ) do
  begin
   Result := Result + IntToHex( Ord( fName[ i ] ), 2);
  end;
end;

class function tIntelHexMapRecord.DataType: byte;
begin
  Result := $FE;
end;

procedure tIntelHexMapRecord.SetData(NewVal: string);
begin
  if Length( NewVal ) < 6 then
  begin
    raise exception.Create( 'Data too short');
  end;
  inherited SetData( Copy( NewVal, 1, 6 ));
  Name := Copy( NewVal, 7, Length( NewVal ));
end;

{ tIntelHexEEPROM_EOF }

class function tIntelHexEEPROM_EOF.DataType: byte;
begin
  Result := $F1;
end;

{ tIntelHexFile }

function tIntelHexFile.Add(NewVal: tIntelHexRecord): integer;
begin
  Result := inherited Add( NewVal );
end;

procedure tIntelHexFile.AddMigrationEntry(vMajor, vMinor, vBuild: integer);
var
  v : string;
  i: Integer;
begin
  v := 'v' + IntToStr( vMajor )
     + '.' + IntToStr( vMinor )
     + '.' + IntToStr( vBuild );
  if SameText( v, Version ) then
  begin
    exit;
  end;
  for i := 0 to MigrationList.Count - 1 do
  begin
    if MigrationList[ i ] = v then
    begin
      // duplicate
      exit;
    end;
    if MigrationList[ i ] < v then
    begin
      // descending list so insert here
      MigrationList.Insert( i, v);
      exit;
    end;
  end;
  // new entry to add at end
  MigrationList.Add( v );
end;

procedure tIntelHexFile.ClearASMFileRecords;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    case Item[ i ].DataType of
      $FE:
      begin
        with Item[ i ] as tIntelHexMapRecord do
        begin
          if (VersionMajor = self.VersionMajor)
          and (VersionMinor = self.VersionMinor)
          and (VersionBuild = self.VersionBuild)
          then
          begin
            Items[ i ] := nil;
          end;
        end;
      end;
    end;
  end;
  Pack;
end;

procedure tIntelHexFile.ClearEEPFileRecords;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    case Item[ i ].DataType of
      $F0, $F1:
      begin
        Items[ i ] := nil;
      end;
    end;
  end;
  Pack;
end;

procedure tIntelHexFile.ClearHexFileRecords;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    case Item[ i ].DataType of
      1, 2, 3, 4, 5:
      begin
        Items[ i ] := nil;
      end;
    end;
  end;
  Pack;
end;

constructor tIntelHexFile.Create;
begin
  inherited Create( TRUE );
  fMigrationList := tStringList.Create;
end;

destructor tIntelHexFile.Destroy;
begin
  MigrationList.Free;
  inherited;
end;

function tIntelHexFile.GetItem(const index: integer): tIntelHexRecord;
begin
  Result := Items[ index ] as tIntelHexRecord;
end;

function tIntelHexFile.GetVersionBuild: integer;
begin
  if assigned( fVersionRec ) then
  begin
    Result := fVersionRec.VersionBuild;
  end
  else
  begin
    Result := 0;
  end;
end;

function tIntelHexFile.GetVersionMajor: integer;
begin
  if assigned( fVersionRec ) then
  begin
    Result := fVersionRec.VersionMajor;
  end
  else
  begin
    Result := 0;
  end;
end;

function tIntelHexFile.GetVersionMinor: integer;
begin
  if assigned( fVersionRec ) then
  begin
    Result := fVersionRec.VersionMinor;
  end
  else
  begin
    Result := 0;
  end;
end;

procedure tIntelHexFile.ImportASMFile(const pFileName: string);
var
  iFile : tStringList;
  i: integer;
  iIntelHexRecord : tIntelHexMapRecord;
  vMajorFound, vMinorFound, vBuildFound : boolean;
  iPos : integer;
  iLeft, iRight : string;
  iComment : string;
begin
  // go through list twice; once to get version and once
  // to create map records if version number exists
  vMajorFound := FALSE;
  vMinorFound := FALSE;
  vBuildFound := FALSE;
  iFile := tStringList.Create;
  iFile.LoadFromFile( pFileName );
  for i := 0 to iFile.Count - 1 do
  begin
    iPos := Pos( ' .EQU ', iFile[ i ] );
    if iPos > 0 then
    begin
      iLeft := Trim( Copy( iFile[ i ], 1, iPos ));
      iRight := Trim( Copy( iFile[ i ], iPos + 6, 255 ));
      if SameText( iLeft, 'Version.cVersionMajor') then
      begin
        iPos := Pos( ';', iRight );
        if iPos > 0 then
        begin
          iRight := Trim( Copy( iRight, 1, iPos - 1));
        end;
        if iRight[ Length( iRight ) ] = 'h' then
        begin
          VersionMajor := HexToInt( Copy( iRight, 1, Length( iRight ) -1));
        end
        else
        begin
          VersionMajor := StrToInt( iRight );
        end;
        vMajorFound := TRUE;
      end
      else if SameText( iLeft, 'Version.cVersionMinor') then
      begin
        iPos := Pos( ';', iRight );
        if iPos > 0 then
        begin
          iRight := Trim( Copy( iRight, 1, iPos - 1));
        end;
        if iRight[ Length( iRight ) ] = 'h' then
        begin
          VersionMinor := HexToInt( Copy( iRight, 1, Length( iRight ) -1));
        end
        else
        begin
          VersionMinor := StrToInt( iRight );
        end;
        vMinorFound := TRUE;
      end
      else if SameText( iLeft, 'Version.cVersionBuild') then
      begin
        iPos := Pos( ';', iRight );
        if iPos > 0 then
        begin
          iRight := Trim( Copy( iRight, 1, iPos - 1));
        end;
        if iRight[ Length( iRight ) ] = 'h' then
        begin
          VersionBuild := HexToInt( Copy( iRight, 1, Length( iRight ) -1));
        end
        else
        begin
          VersionBuild := StrToInt( iRight );
        end;
        vBuildFound := TRUE;
      end;
    end;
  end;
  // if version found then create mapping records
  if vMajorFound or vMinorFound or vBuildFound then
  begin
    fIsDirty := TRUE;
    // remove existing records to allow multiple load of same file
    ClearASMFileRecords;
    for i := 0 to iFile.Count - 1 do
    begin
      iPos := Pos( ' .EQU ', iFile[ i ] );
      if iPos > 0 then
      begin
        iLeft := Trim( Copy( iFile[ i ], 1, iPos ));
        iRight := Trim( Copy( iFile[ i ], iPos + 6, 255 ));
        // is there a comment?
        iPos := Pos( ';', iRight );
        if iPos > 0 then
        begin
          iComment := Copy( iRight, iPos, 255 );
          iRight := Trim( Copy( iRight, 1, iPos - 1));
          // is it in EEPROM?
          iPos := Pos( 'EEPROM', UpperCase( iComment ));
          if iPos > 0 then
          begin
            // yes. We store location. When retrieving we sort by location
            // in both versions and copy length to next named location
            // Thus we do not need size, which is just as well as we
            // can't always get it
            // Exclude the global EEPROM record
            if not SameText( iLeft, 'EEPROM') then
            begin
              iIntelHexRecord := tIntelHexMapRecord.Create;
              iIntelHexRecord.VersionMajor := self.VersionMajor;
              iIntelHexRecord.VersionMinor := self.VersionMinor;
              iIntelHexRecord.VersionBuild := self.VersionBuild;
              if iRight[ Length( iRight ) ] = 'h' then
              begin
                iIntelHexRecord.Address := HexToInt( Copy( iRight, 1, Length( iRight ) -1));
              end
              else
              begin
                iIntelHexRecord.Address := StrToInt( iRight );
              end;
              iIntelHexRecord.Name := iLeft;
              Add( iIntelHexRecord );
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure tIntelHexFile.ImportEEPFile(const pFileName: string);
var
  iFile : tStringList;
  i: integer;
  iIntelHexRecord : tIntelHexRecord;
begin
  ClearEEPFileRecords;
  iFile := tStringList.Create;
  iFile.LoadFromFile( pFileName );
  for i := 0 to iFile.Count - 1 do
  begin
    iIntelHexRecord := IntelEEPObject( iFile[ i ] );
    Add( iIntelHexRecord );
  end;
  iFile.Free;
  fIsDirty := TRUE;
end;

procedure tIntelHexFile.ImportHexFile(const pFileName: string);
var
  iFile : tStringList;
  i: integer;
  iIntelHexRecord : tIntelHexRecord;
begin
  ClearHexFileRecords;
  iFile := tStringList.Create;
  iFile.LoadFromFile( pFileName );
  for i := 0 to iFile.Count - 1 do
  begin
    iIntelHexRecord := IntelHexObject( iFile[ i ] );
    Add( iIntelHexRecord );
  end;
  iFile.Free;
  fIsDirty := TRUE;
end;

function tIntelHexFile.IntelEEPObject(FromString: string): tIntelHexRecord;
var
  iRecType : byte;
  CS : byte;
  i: Integer;
  iDataLen : integer;
begin
  if Length( FromString )< 11 then
  begin
    raise exception.Create('Illegal Intel Hex record - too short');
  end;
  if FromString[ 1 ] <> ':' then
  begin
    raise exception.Create('Illegal Intel Hex Record start character' );
  end;

  CS := 0;
  for i := 1 to Length( FromString ) div 2 do
  begin
    inc( CS, HexToInt( Copy( FromString, 2 * i, 2 )));
  end;

  if CS <> 0 then
  begin
    raise exception.Create( 'Check sum Fail' );
  end;

  iDataLen := HexToInt( Copy( FromString, 2, 2 ));
  if iDataLen * 2 <> Length( FromString ) - 11 then
  begin
    raise exception.Create( 'Length Mismatch' );
  end;

  iRecType := HexToInt( Copy( FromString, 8, 2));
  if iRecType = tIntelHexDataRecord.DataType then
  begin
    Result := tIntelHexEEPROMDataRecord.Create;   // note diff type!
  end
  else if iRecType = tIntelHexEOF.DataType then
  begin
    Result := tIntelHexEEPROM_EOF.Create;         // note different type
  end
  else
  begin
    // all other record types illegal for now
    raise exception.Create( 'Illegal record type' );
  end;

  Result.Address := HexToInt( Copy( FromString, 4, 4 ));
  Result.SetData( Copy( FromString, 10, iDataLen * 2 ));

end;

function tIntelHexFile.IntelHexObject(FromString: string): tIntelHexRecord;
var
  iRecType : byte;
  CS : byte;
  i: Integer;
  iDataLen : integer;
begin
  if Length( FromString )< 11 then
  begin
    raise exception.Create('Illegal Intel Hex record - too short');
  end;
  if FromString[ 1 ] <> ':' then
  begin
    raise exception.Create('Illegal Intel Hex Record start character' );
  end;

  CS := 0;
  for i := 1 to Length( FromString ) div 2 do
  begin
    inc( CS, HexToInt( Copy( FromString, 2 * i, 2 )));
  end;

  if CS <> 0 then
  begin
    raise exception.Create( 'Check sum Fail' );
  end;

  iDataLen := HexToInt( Copy( FromString, 2, 2 ));
  if iDataLen * 2 <> Length( FromString ) - 11 then
  begin
    raise exception.Create( 'Length Mismatch' );
  end;

  iRecType := HexToInt( Copy( FromString, 8, 2));
  if iRecType = tIntelHexDataRecord.DataType then
  begin
    Result := tIntelHexDataRecord.Create;
  end
  else if iRecType = tIntelHexEOF.DataType then
  begin
    Result := tIntelHexEOF.Create;
  end
  else if iRecType = tIntelHexExtendedSegmentAddressRecord.DataType then
  begin
    Result := tIntelHexExtendedSegmentAddressRecord.Create;
  end
  else if iRecType = tIntelHexStartSegmentAddressRecord.DataType then
  begin
    Result := tIntelHexStartSegmentAddressRecord.Create;
  end
  else if iRecType = tIntelHexExtendedLinearAddressRecord.DataType then
  begin
    Result := tIntelHexExtendedLinearAddressRecord.Create;
  end
  else if iRecType = tIntelHexStartLinearAddressRecord.DataType then
  begin
    Result := tIntelHexStartLinearAddressRecord.Create;
  end
  else if iRecType = tIntelHexEEPROMDataRecord.DataType then
  begin
    Result := tIntelHexEEPROMDataRecord.Create;
  end
  else if iRecType = tIntelHexVersionRecord.DataType then
  begin
    Result := tIntelHexVersionRecord.Create;
  end
  else if iRecType = tIntelHexMapRecord.DataType then
  begin
    Result := tIntelHexMapRecord.Create;
  end
  else if iRecType = tIntelHexEEPROM_EOF.DataType then
  begin
    Result := tIntelHexEEPROM_EOF.Create;
  end
  else
  begin
    raise exception.Create( 'Illegal record type' );
  end;

  Result.Address := HexToInt( Copy( FromString, 4, 4 ));
  Result.SetData( Copy( FromString, 10, iDataLen * 2 ));

end;

procedure tIntelHexFile.LoadFromFile( const pFileName: string );
var
  iFile : tStringList;
  i: integer;
  iIntelHexRecord : tIntelHexRecord;
begin
  Clear;
  fVersionRec := nil;
  iFile := tStringList.Create;
  iFile.LoadFromFile( pFileName );
  for i := 0 to iFile.Count - 1 do
  begin
    iIntelHexRecord := IntelHexObject( iFile[ i ] );
    Add( iIntelHexRecord );
    if iIntelHexRecord is tIntelHexMapRecord then
    begin
      with iIntelHexRecord as tIntelHexMapRecord do
      begin
        AddMigrationEntry( VersionMajor, VersionMinor, VersionBuild );
      end;
    end
    else if iIntelHexRecord is tIntelHexVersionRecord then
    begin
      if assigned( fVersionRec ) then
      begin
        raise exception.Create( 'Duplicate version record' );
      end;
      fVersionRec := iIntelHexRecord as tIntelHexVersionRecord;
    end;
  end;
  iFile.Free;
  fIsDirty := FALSE;
  fFileName := pFileName;
end;

procedure tIntelHexFile.New;
begin
  fVersionRec := nil;
  Clear;
  MigrationList.Clear;
  fFileName := '';
  fIsDirty := FALSE;
end;

procedure tIntelHexFile.SaveMigrationListToStringList(pStringList: tStrings);
begin
  pStringList.Clear;
  pStringList.Assign( MigrationList );
end;

procedure tIntelHexFile.SaveToFile(const pFileName: string);
var
  iFile : tStringList;
begin
  iFile := tStringList.Create;
  SaveToStringList( iFile );
  iFile.SaveToFile( pFileName );
  iFile.Free;
  fIsDirty := FALSE;
  fFileName := pFileName;
end;

procedure tIntelHexFile.SaveToStringList(pStringList: tStrings);
var
  i: Integer;
begin
  pStringList.Clear;
  for i := 0 to Count - 1 do
  begin
    pStringList.Add( Item[ i ].Rec );
  end;
end;

procedure tIntelHexFile.SetVersionBuild(const Value: integer);
begin
  if not assigned( fVersionRec ) then
  begin
    fVersionRec := tIntelHexVersionRecord.Create;
    Add( fVersionRec );
  end;
  fVersionRec.VersionBuild := Value;
end;

procedure tIntelHexFile.SetVersionMajor(const Value: integer);
begin
  if not assigned( fVersionRec ) then
  begin
    fVersionRec := tIntelHexVersionRecord.Create;
    Add( fVersionRec );
  end;
  fVersionRec.VersionMajor := Value;
end;

procedure tIntelHexFile.SetVersionMinor(const Value: integer);
begin
  if not assigned( fVersionRec ) then
  begin
    fVersionRec := tIntelHexVersionRecord.Create;
    Add( fVersionRec );
  end;
  fVersionRec.VersionMinor := Value;
end;

function tIntelHexFile.Version: string;
begin
  if assigned( fVersionRec ) then
  begin
    with fVersionRec do
    begin
      Result := 'v' + IntToStr( VersionMajor )
              + '.' + IntToStr( VersionMinor )
              + '.' + IntToStr( VersionBuild );
    end;
  end
  else
  begin
    Result := '<None>';
  end;
end;

end.
