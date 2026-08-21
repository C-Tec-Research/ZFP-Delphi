unit SigBrand;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles;

type
  TSigNETBrand = class(TComponent)
  private
	 { Private declarations }
	 vIniFile : TIniFile;
	 vIniFileName : TFileName;
	 vLength : integer;
	 vSerialNo : array [1..64] of integer;
	 vSeedString : string;
	 vExpiryYear, vExpiryMonth : integer;
	 procedure AddValue( StringToAdd : string );
	 function fIsExpired : boolean;
	 function fDaysLeft : integer;
	 function fGetSerialNumber : string;
	 function IsIniFile: Boolean;

  protected
    { Protected declarations }
    procedure SetIniFile( NewName : TFileName );
    procedure SetLength( NewLength : integer );
    procedure SetSeedString(NewSeedString : string );
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure Reseed;

    property Expired : boolean
             read fIsExpired;
    property DaysLeft : integer
             read fDaysLeft;

    procedure EraseSection(const Section: string);
    function ReadBool (const Section, Ident: string; Default: Boolean): Boolean;
	 function ReadKeyBool (const Section, Ident: string; Default: Boolean): Boolean;
    function ReadInteger(const Section, Ident: string; Default: Longint): Longint;
    function ReadKeyInteger(const Section, Ident: string; Default: Longint): Longint;
	 function ReadExpiryYear(const Section, Ident: string): Longint;
    function ReadExpiryMonth(const Section, Ident: string): Longint;
    procedure ReadSection (const Section: string; Strings: TStrings);
    procedure ReadSectionValues(const Section: string; Strings: TStrings);
    function ReadString(const Section, Ident, Default: string): string;
    function ReadKeyString(const Section, Ident, Default: string): string;
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteInteger(const Section, Ident: string; Value: Longint);
    procedure WriteString(const Section, Ident, Value: string);
    function CheckSerialNumber( const Section, Ident : string ) : boolean;

  published
	 { Published declarations }

    property IniFile : TFileName
             read vIniFileName
             write SetIniFile;
	 property KeyLength : integer
             read vLength
				 write SetLength;
    property SeedString : string
				 read vSeedString
             write SetSeedString;
    property ExpiryYear : integer
             read vExpiryYear
             write vExpiryYear;
    property ExpiryMonth : integer
             read vExpiryMonth
             write vExpiryMonth;
  end;

type
  TSigNETBrandUnsecure = class(TSigNETBrand)
  public
    { Public declarations }
    procedure WriteSerialNumber( const Section, Ident : string );
end;

procedure Register;

implementation

const
  Serial_Codes = '0123456789QWERTYUIOPASDFGHJKLZXCVBNM';

procedure Register;
begin
  RegisterComponents('SigNET', [TSigNETBrand, TSigNETBrandUnsecure]);
end;

constructor TSigNETBrand.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  vLength := 10;
//  vInifileName := 'C:\windows\win.ini';
  vSeedString := 'Copyright (c) 1998, SigNET (AC) Ltd.';
  {if not (csDesigning in ComponentState) then }
  vExpiryYear := 1900;
  vExpiryMonth := 1;
  if not (csDesigning in ComponentState) then Reseed;
end;

destructor TSigNETBrand.Destroy;
begin
  vIniFile.Free;
  inherited Destroy;
end;

procedure TSigNETBrand.SetIniFile( NewName : TFileName );
begin
  vIniFile.Free;
  vIniFileName := NewName;
  vIniFile := TiniFile.Create( vIniFileName );
end;

procedure TSigNETBrand.SetLength( NewLength : integer );
begin
  if NewLength < 6 then NewLength := 6;
  if NewLength > 64 then NewLength := 64;
  vLength := NewLength;
  if not (csDesigning in ComponentState) then Reseed;
end;

procedure TSigNETBrand.SetSeedString(NewSeedString : string );
begin
  vSeedString := NewSeedString;
  if not (csDesigning in ComponentState) then Reseed;
end;

procedure TSigNETBrand.Reseed;
var
  i : integer;
begin
  RandSeed := vLength + Length( vSeedString );
  for i := 1 to vLength do
  begin
	 vSerialNo[ i ] := 1 + Random( Length( Serial_Codes ) );
  end;
  AddValue( vSeedString );
end;

procedure TSigNETBrand.AddValue( StringToAdd : string );

var
  i, j : integer;

begin
  for i := 1 to Length( StringToAdd) do
  begin
	 for j := 1 to vLength do
	 begin
		Inc( vSerialNo[ 1 + random( vLength ) ],
			  random( Ord(StringToAdd[i])));
		Inc( vSerialNo[ j ], random( Ord( StringToAdd[i]) ));
	 end;
  end;
  for i := 1 to vLength do
  begin
	 for j := 1 to Length( StringToAdd ) do
	 begin
		Inc( vSerialNo[ i ],
			  random( Ord( StringToAdd [ random( Length(StringToAdd) )])));
	 end;
	 vSerialNo [i] := vSerialNo[ i ] mod Length(Serial_Codes);
  end;
end;

procedure TSigNETBrand.EraseSection(const Section: string);
begin
  if IsIniFile then vIniFile.EraseSection( Section );
end;

function TSigNETBrand.ReadBool (const Section, Ident: string; Default: Boolean): Boolean;
var
  vResult, vDefault : string;
begin
  if IsIniFile then begin
	  if Default then vDefault := 'T' else vDefault := 'F';
	  vResult := vIniFile.ReadString( Section, Ident, vDefault );
	  case Ord(vResult[1]) of
		 Ord('1'), Ord('T'), Ord('t'): Result := True;
		 Ord('0'), Ord('F'), Ord('f'): Result := False;
	  else
		 Result := Default;
	  end;
  end
  else Result := false;
end;

function TSigNETBrand.ReadKeyBool (const Section, Ident: string; Default: Boolean): Boolean;
begin
  Result := ReadBool( Section, Ident, Default );
  if Result then AddValue( 'TRUE' ) else AddValue( 'FALSE' );
end;

function TSigNETBrand.ReadInteger(const Section, Ident: string; Default: Longint): Longint;
begin
  if IsIniFile then Result := vIniFile.ReadInteger( Section, Ident, Default )
  else Result := 0;
end;

function TSigNETBrand.ReadKeyInteger(const Section, Ident: string; Default: Longint): Longint;
begin
  Result := ReadInteger( Section, Ident, Default );
  AddValue( IntToStr( Result ));
end;

function TSigNETBrand.ReadExpiryYear(const Section, Ident: string): Longint;
begin
  vExpiryYear := ReadKeyInteger( Section, Ident, 1900 );
  Result := vExpiryYear;
end;

function TSigNETBrand.ReadExpiryMonth(const Section, Ident: string): Longint;
begin
  vExpiryMonth := ReadKeyInteger( Section, Ident, 1 );
  Result := vExpiryMonth;
end;

function TSigNETBrand.fIsExpired : boolean;
var
  Day, Month, Year : Word;
begin
  DecodeDate( Now, Year, Month, Day );
  if Year > ExpiryYear then Result := TRUE
  else if (Year = ExpiryYear) and (Month > ExpiryMonth) then Result := TRUE
  else Result := FALSE;
end;

function TSigNETBrand.fDaysLeft : integer;
var
  Day, Month, Year : Word;
begin
  DecodeDate( Now, Year, Month, Day );
  if Year > ExpiryYear then Result := 0
  else if (Year = ExpiryYear) and (Month > ExpiryMonth) then Result := 0
  else if (Year = ExpiryYear) and (Month = ExpiryMonth) then Result := 29 - Day
  else Result := -1;
end;

procedure TSigNETBrand.ReadSection (const Section: string; Strings: TStrings);
begin
  if IsIniFile then vIniFile.ReadSection( Section, Strings );
end;

procedure TSigNETBrand.ReadSectionValues(const Section: string; Strings: TStrings);
begin
  if IsIniFile then vIniFile.ReadSectionValues( Section, Strings );
end;

function TSigNETBrand.ReadString(const Section, Ident, Default: string): string;
begin
  if IsIniFile then Result := vIniFile.ReadString( Section, Ident, Default )
  else Result := '';
end;

function TSigNETBrand.ReadKeyString(const Section, Ident, Default: string): string;
begin
  Result := ReadString( Section, Ident, Default );
  AddValue( Result );
end;

procedure TSigNETBrand.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  if Value then WriteString( Section, Ident, 'TRUE' )
  else WriteString( Section, Ident, 'FALSE' );
end;

procedure TSigNETBrand.WriteInteger(const Section, Ident: string; Value: Longint);
begin
  if IsIniFile then vIniFile.WriteInteger( Section, Ident, Value );
end;

procedure TSigNETBrand.WriteString(const Section, Ident, Value: string);
begin
  if IsIniFile then vIniFile.WriteString( Section, Ident, Value );
end;

function TSigNETBrand.fGetSerialNumber : string;
var
  i : integer;
begin
  Result := '';
  for i := 1 to vLength do
  begin
	 Result := Result + Serial_Codes[ 1 + vSerialNo[ i ] ]
  end;
end;

function TSigNETBrand.CheckSerialNumber( const Section, Ident : string ) : boolean;
begin
  Result := (ReadString( Section, Ident, '') = fGetSerialNumber);
end;

procedure TSigNETBrandUnsecure.WriteSerialNumber( const Section, Ident : string );
begin
  WriteString( Section, Ident, fGetSerialNumber );
end;

function TSigNETBrand.IsIniFile: Boolean;
begin
	Result := (vIniFile <> nil);
end;

end.
