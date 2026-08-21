unit SigBrand;

interface
{
********************************************************************************
Version 2.0 - modified by AD
	1. Included the following functions to read the values from the registry:
			ReadRegBool (Ident, default)
			ReadRegInteger (Ident, default)
			ReadRegString (Ident, default)
	where
		Ident = field name of value
		default = default value if field name does not exist
	2. Included the following functions to acquire KEY values from the registry:
			ReadRegKeyBool (Ident, default)
			ReadRegKeyInteger (Ident, default)
			ReadRegKeyString (Ident, default)
			ReadRegExpiryMonth (Ident)
			ReadRegExpiryYear (Ident)
			ReadRegStartMonth (Ident)
			ReadRegStartYear (Ident)
	3. Included the following functions to write values to the registry:
			WriteRegBool (Ident, value)
			WriteRegInteger (Ident, value)
			WriteRegString (Ident, value)
	4. Included the following functions for KEY values to be entered direct:
			UseKeyBool (Value)
			UseKeyInteger (Value)
			UseKeyString (Value)
			UseExpiryMonth (Value)
			UseExpiryYear (Value)
			UseStartMonth (Value)
			UseStartYear (Value)
	5. Included the following functions to expand on values read from an INI file:
			ReadStartMonth (Section, Ident)
			ReadStartYear (Section, Ident)
	6. Included the following properties:
			RegistryKey - Key where all values are obtained
			StartYear	- Year application started
			StartMonth	- Month application started
	7. Included the following function to check the serial number in the registry:
			CheckRegSerialNumber (Ident)
	8. Added 2 constants: OPEN_LICENCE_MONTH and OPEN_LICENCE_YEAR. If expiry date is set to this
		then that signifies that the licence is open.
********************************************************************************
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, Registry;

const
	OPEN_LICENCE_MONTH = 12;
	OPEN_LICENCE_YEAR = 2837;

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
	 vStartYear: integer;
	 vStartMonth: integer;
	 vRegistry: TRegistry;
	 vRegistryKey: string;
	 procedure AddValue( StringToAdd : string );
	 function fGetSerialNumber : string;
	 function IsIniFile: Boolean;
	 function fIsExpired: boolean;
	 function fDaysLeft: integer;

  protected
	 { Protected declarations }
	 procedure SetIniFile(const NewName : TFileName );
	 procedure SetRegistry(const NewKey: string);
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

	 {Erase unwanted data}
	 procedure EraseSection(const Section: string);
	 procedure EraseKey(const Ident: string);
	 {Read boolean values}
	 function ReadBool (const Section, Ident: string; Default: Boolean): Boolean;
	 function ReadRegBool (const Ident: string; Default: Boolean): Boolean;
	 function ReadKeyBool (const Section, Ident: string; Default: Boolean): Boolean;
	 function ReadRegKeyBool (const Ident: string; default: Boolean): Boolean;
	 procedure UseKeyBool (const Value: Boolean);
	 {Read integer values}
	 function ReadInteger(const Section, Ident: string; Default: integer): integer;
	 function ReadRegInteger (const  Ident: string; Default: integer): integer;
	 function ReadKeyInteger(const Section, Ident: string; Default: integer): integer;
	 function ReadRegKeyInteger (const Ident: string; Default: integer): integer;
	 procedure UseKeyInteger (const Value: integer);
	 {Read expiry dates}
	 function ReadExpiryYear(const Section, Ident: string): integer;
	 function ReadRegExpiryYear (const Ident: string): integer;
	 procedure UseExpiryYear (const Value: integer);
	 function ReadExpiryMonth(const Section, Ident: string): Longint;
	 function ReadRegExpiryMonth (const Ident: string): integer;
	 procedure UseExpiryMonth (const Value: integer);
	 {Read start dates}
	 function ReadStartYear (const Section, Ident: String): integer;
	 function ReadRegStartYear (const Ident: string): integer;
	 procedure UseStartYear (const Value: integer);
	 function ReadStartMonth (const Section, Ident: string): integer;
	 function ReadRegStartMonth (const Ident: string): integer;
	 procedure UseStartMonth (const Value: integer);
	 {Read values from a section}
	 procedure ReadSection (const Section: string; Strings: TStrings);
	 procedure ReadSectionValues(const Section: string; Strings: TStrings);
	 {Read string values}
	 function ReadString(const Section, Ident, Default: string): string;
	 function ReadRegString (const Ident, Default: string): string;
	 function ReadKeyString(const Section, Ident, Default: string): string;
	 function ReadRegKeyString (const Ident, Default: string): string;
	 procedure UseKeyString (const Value:string);
	 {Write to ini file}
	 procedure WriteBool(const Section, Ident: string; Value: Boolean);
	 procedure WriteInteger(const Section, Ident: string; Value: integer);
	 procedure WriteString(const Section, Ident, Value: string);
	 {write to registry}
	 procedure WriteRegBool (const Ident: string; Value: Boolean);
	 procedure WriteRegInteger (const Ident: string; Value: integer);
	 procedure WriteRegString (const Ident, Value: string);
	 {Check serial number in ini file}
	 function CheckSerialNumber( const Section, Ident : string ) : boolean;
	 {Check serial number in registry}
	 function CheckRegSerialNumber (const Ident: string): Boolean;

  published
	 { Published declarations }

	 property IniFile : TFileName
				 read vIniFileName
				 write SetIniFile;
	 property RegistryKey: string
				 read vRegistryKey
				 write SetRegistry;
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
	 property StartYear: integer
				 read vStartYear
				 write vStartYear;
	 property StartMonth: integer
				 read vStartMonth
				 write vStartMonth;
  end;

type
  TSigNETBrandUnsecure = class(TSigNETBrand)
  public
    { Public declarations }
	 procedure WriteSerialNumber( const Section, Ident : string );
	 procedure WriteRegSerialNumber (const Ident: string);
end;

procedure Register;

implementation

const
  Serial_Codes = '123456789QWERTYPASDFGHJKLXCVBNM';

procedure Register;
begin
  RegisterComponents('SigNET', [TSigNETBrand, TSigNETBrandUnsecure]);
end;

constructor TSigNETBrand.Create( AOwner: TComponent );
var
	iYear, iMonth, iDay: word;
begin
  inherited Create( AOwner );
  vLength := 8;
  vSeedString := 'Copyright (c) 1999, SigNET (AC) Ltd.';
  DecodeDate (Date, iYear, iMonth, iDay);
  vStartYear := iYear;
  vStartMonth := iMonth;
  vExpiryYear := iYear;
  vExpiryMonth := iMonth;
  vRegistryKey := '';
  if not (csDesigning in ComponentState) then Reseed;
end;

destructor TSigNETBrand.Destroy;
begin
  vIniFile.Free;
  inherited Destroy;
end;

procedure TSigNETBrand.SetIniFile(const NewName : TFileName );
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

procedure TSigNETBrand.EraseKey (const Ident: string);
begin
	try
		vRegistry.DeleteValue (Ident);
	finally
	end;
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
  if (Year = ExpiryYear) and (Month = ExpiryMonth) then Result := 29 - Day
  else if (Year = OPEN_LICENCE_YEAR) and (Month = OPEN_LICENCE_MONTH) then Result := -1
  else Result := 0
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

procedure TSigNETBrandUnsecure.WriteRegSerialNumber(const Ident: string);
begin
	WriteRegString (Ident, fGetSerialNumber);
end;

procedure TSigNETBrandUnsecure.WriteSerialNumber( const Section, Ident : string );
begin
  WriteString( Section, Ident, fGetSerialNumber );
end;

function TSigNETBrand.IsIniFile: Boolean;
begin
	Result := (vIniFile <> nil);
end;

function TSigNETBrand.CheckRegSerialNumber(const Ident: string): Boolean;
begin
	Result := (ReadRegString(Ident, '') = fGetSerialNumber);
end;

function TSigNETBrand.ReadRegExpiryMonth(const Ident: string): longint;
begin
  vExpiryMonth := ReadRegKeyInteger (Ident, 1900);
  Result := vExpiryMonth;
end;

function TSigNETBrand.ReadRegExpiryYear(const Ident: string): Longint;
begin
  vExpiryYear := ReadRegKeyInteger (Ident, 1900);
  Result := vExpiryYear;
end;

function TSigNETBrand.ReadRegKeyBool(const Ident: string; default: Boolean): Boolean;
begin
	Result := ReadRegBool (Ident, Default);

	{use this to construct serial number}
	UseKeyBool (Result);
end;

function TSigNETBrand.ReadRegKeyInteger(const Ident: string;
  Default: Integer): integer;
begin
	Result := ReadRegInteger (Ident, Default);

	{use this to construct serial number}
	UseKeyInteger (Result);
end;

function TSigNETBrand.ReadRegKeyString(const Ident, Default: string): string;
begin
	Result := ReadRegString (Ident, Default);

	{Use this to construct serial number}
	UseKeyString (Result);
end;

function TSigNETBrand.ReadRegStartMonth(const Ident: string): integer;
begin
	Result := ReadRegInteger (Ident, 1);

	{Use this to construct serial number}
	UseKeyInteger (Result);
end;

function TSigNETBrand.ReadRegStartYear (const Ident: string): integer;
begin
	Result := ReadRegInteger (Ident, 1900);

	{Use this to construct serial number}
	UseKeyInteger (Result);
end;

function TSigNETBrand.ReadStartMonth(const Section, Ident: string): integer;
begin
  vStartMonth := ReadKeyInteger( Section, Ident, 1 );
  Result := vStartMonth;
end;

function TSigNETBrand.ReadStartYear(const Section, Ident: String): longint;
begin
  vStartYear := ReadKeyInteger( Section, Ident, 1900 );
  Result := vStartYear
end;

procedure TSigNETBrand.SetRegistry(const NewKey: string);
begin
	{If there has been a key already assigned, close it}
	if vRegistryKey <> '' then begin
		try
			vRegistry.CloseKey;
		finally
			vRegistry.Free;
		end;
	end;

	{Open the registry ready for use. The root key is always defined as HKEY_CURRENT_USER}
	vRegistry := TRegistry.Create;
	vRegistry.RootKey := HKEY_CURRENT_USER;
	{Point the registry key to the new key}
	vRegistryKey := NewKey;
end;


procedure TSigNETBrand.WriteRegBool(const Ident: string; Value: Boolean);
begin
	{Write the Boolean value to the registry}
	try
		if vRegistry.OpenKey (vRegistryKey, true) then begin
			vRegistry.WriteBool (Ident, Value);
			vRegistry.CloseKey;
		end;
	finally
	end;
end;

procedure TSigNETBrand.WriteRegInteger(const Ident: string; Value: Integer);
begin
	try
		if vRegistry.OpenKey (vRegistryKey, true) then begin
			vRegistry.WriteInteger (Ident, Value);
			vregistry.CloseKey;
		end;
	finally
	end;
end;

procedure TSigNETBrand.WriteRegString(const Ident, Value: string);
begin
	try
		if vRegistry.OpenKey (vRegistryKey, true) then begin
			vRegistry.WriteString (Ident, Value);
			vRegistry.CloseKey;
		end;
	finally
	end;
end;

function TSigNETBrand.ReadRegBool(const Ident: string; Default: Boolean): Boolean;
begin
	{try to open the key}
	try
		if vRegistry.OpenKey (vRegistryKey, false) then begin
			{If successful, read the value and return it}
			Result := vRegistry.ReadBool (Ident);
			vRegistry.CloseKey;
		end
		else begin
			{if unsuccessful, use default value}
			Result := default;
		end;
	finally
	end;
end;

function TSigNETBrand.ReadRegInteger(const Ident: string; Default: Integer): integer;
begin
	try
		{try to open the key}
		if vRegistry.OpenKey (vRegistryKey, false) then begin
			{If successfull, read the value and return it}
			Result := vRegistry.ReadInteger (Ident);
			vRegistry.CloseKey;
		end
		else begin
			{if unsuccessful, use default value}
			Result := default;
		end;
	finally
	end;
end;

function TSigNETBrand.ReadRegString(const Ident, Default: string): string;
begin
	try
		{try to open the key}
		if vRegistry.OpenKey (vRegistryKey, false) then begin
			{If successful, read the value and return it}
			Result := vRegistry.ReadString (Ident);
			vRegistry.CloseKey;
		end
		else begin
			{If unsuccessful, use default value}
			Result := default;
		end;
	finally
	end;
end;

procedure TSigNETBrand.UseExpiryMonth(const Value: integer);
begin
	AddValue (InttoStr (Value));
end;

procedure TSigNETBrand.UseExpiryYear(const Value: integer);
begin
	AddValue (IntToStr (Value));
end;

procedure TSigNETBrand.UseKeyBool(const Value: Boolean);
begin
	if Value then AddValue ('TRUE') else AddValue ('FALSE');
end;

procedure TSigNETBrand.UseKeyInteger(const Value: integer);
begin
	AddValue (InttoStr (Value));
end;

procedure TSigNETBrand.UseStartMonth(const Value: integer);
begin
	AddValue (InttoStr (Value));
end;

procedure TSigNETBrand.UseStartYear(const Value: integer);
begin
	AddValue (InttoStr (Value));
end;

procedure TSigNETBrand.UseKeyString(const Value: string);
begin
	AddValue (Value);
end;

end.
