unit Splash;

interface
{
Licence details:
	Order of licence keys:
	ExpiryMonth
	ExpiryYear
	StartMonth
	StartYear
	Name
	SiteID

These keys make it consistent with the SigAbout registration box
}

{
********************************************************************************
Version 2.0
	1. Licence details now obtained from  registry.
	2. Seed string now obtained from application resource information
	3. Eliminated the requirement for the 4 constants defined in v1.0
	4. Now supports true open licencing.
	5. Has a start date as well as an expiry date.
********************************************************************************

********************************************************************************
Version 1.0
The splash screen requires 4 constants defined in the Version.pas file attached
to the current project. These are:

AppDescription - Title for the application - appears in the panel and the title bar
AppVersion - Version number of the application - appears in the title bar
AppIniFile - Name of ini file where the software security is stored
UseCurrentPath - Determines whether the ini file is in the current path or not. If not then the ini file will be found in the Windows directory
********************************************************************************
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellApi, ExtCtrls, Buttons, Version, SigBrand, Common;


type
  TfrmSplash = class(TForm)
	 SplashImage: TImage;
	 Panel: TPanel;
	 btnOK: TBitBtn;
	 lblStatus: TLabel;
	 Timer: TTimer;
	 Brand: TSigNETBrand;
	 procedure FormShow(Sender: TObject);
	 procedure ShowMainForm(Sender: TObject);
  private
	 { Private declarations }
	 function CheckSerialNo: Boolean;
	 procedure ReadKeyValues;
	 procedure SetSeed;
	 function VersionInfo(const sVersion: string): string;
  public
	 { Public declarations }
	 DemoMode : Bool;
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.DFM}

function TfrmSplash.CheckSerialNo: Boolean;
{Checks the serial number. If it is not correct, the appliaction is placed into
demo mode}
begin
	{Set the seed string}
	SetSeed;
	if Brand.ReadRegString ('Serial', 'DEMO') = 'DEMO' then begin
		DemoMode := true;
		Result := false;
	end
	else with Brand do begin
		{Read in the various values, then write the resulting serial number to the ini file}
		ReadKeyValues;
		Result := CheckRegSerialNumber ('Serial');
		DemoMode := false;
	end;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
var
	FullVersion : Boolean;
	Year, Month, Day : Word;
	sDescription: string;
	sVersion: string;
	sCaption: string;
begin
	{Change the caption of the form to that of the application}
	sDescription := FindResourceValue ('FileDescription');
	sVersion := FindResourceValue ('FileVersion');
	frmSplash.Caption := sDescription + ' v' + VersionInfo (sVersion);

	{Check the serial number to see if it is valid}
	FullVersion := CheckSerialNo;

	{Determine the licence status}
	if DemoMode then begin
		sCaption := 'Demonstation version of ' + sDescription
	end
	else if not FullVersion then begin
		sCaption := 'Invalid serial number.  Starting demonstration version.';
		DemoMode := true;
	end
	else with Brand do begin
		sCaption := sDescription;
		if (ExpiryMonth = OPEN_LICENCE_MONTH) and (ExpiryYear = OPEN_LICENCE_YEAR) then begin
			Timer.Enabled := true;
			btnOk.Hide;
			lblStatus.Hide;
			Panel.Caption := sCaption;
		end
		else if Expired then begin
			sCaption := sCaption +
				'. The expiry date has passed. ' + sDescription + ' will continue in ' +
				'demonstration mode. Please contact SigNET (AC) Ltd. for the full program.';
		end
		else if DaysLeft > 0 then begin
			sCaption := sCaption + '. There are ' + IntToStr(DaysLeft) +
										  ' days left until this software expires.';
		end
		else begin
			DecodeDate (Date, Year, Month, Day);
			sCaption := sCaption + '. This version will expire in ' +
				FormatDateTime ('mmmm yyyy', EncodeDate (ExpiryYear, ExpiryMonth, 28)) + '.';
		end;
	end; {full version}
	{Display caption}
	lblStatus.Caption := sCaption;
end;

procedure TfrmSplash.ReadKeyValues;
{This function includes all the values that are to be included in the key for
the serial number. Rememeber that the order is important
The return value of this function determines whether the application is to be
run in demo mode}
var
	s: string;
begin
	with Brand do begin
		{Now determine the key strings, and use the relevant values}
		ExpiryMonth := ReadRegExpiryMonth ('ToMonth');
		ExpiryYear := ReadRegExpiryYear ('ToYear');
		StartMonth := ReadRegStartMonth ('FromMonth');
		StartYear := ReadRegStartYear ('FromYear');
		s := ReadRegKeyString ('Name', '');
		s := ReadRegKeyString ('SiteID', '');
	end;
end;

procedure TfrmSplash.SetSeed;
var
	sDescription: string;
	sVersion: string;
begin
	sDescription := FindResourceValue ('FileDescription');
	sVersion := FindResourceValue ('FileVersion');
	Brand.SeedString := sDescription + sVersion[1];
	Brand.RegistryKey := '\Software\SigNET\' + sDescription;
end;

procedure TfrmSplash.ShowMainForm(Sender: TObject);
begin
	{If the splash screen is showing, hide it and show the main form}
	if frmSplash.Showing then begin
		Hide;
	end;
end;

function TfrmSplash.VersionInfo(const sVersion: string): string;
{This function returns the major.minor version from the string passed}
var
	i: integer;
	j: integer;
begin
	i := 0;
	Result := '';

	for j := 1 to 2 do begin
		repeat
			inc (i);
			if sVersion[i] <> '.' then Result := Result + sVersion[i];
		until sVersion[i] = '.';
		{Add the '.' between major and minor version numbers}
		if j = 1 then Result := Result + '.';
	end;
end;

end.
