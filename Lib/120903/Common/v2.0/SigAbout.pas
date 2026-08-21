unit SigAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Registry, SigBrand, Common;

type
  TfrmSigAbout = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnRegistration: TButton;
    lblValidFromText: TLabel;
    lblValidToText: TLabel;
    lblValidFrom: TLabel;
    lblValidTo: TLabel;
	 grpRegistration: TGroupBox;
	 txtCustomerName: TEdit;
	 txtSiteID: TEdit;
	 Label7: TLabel;
	 Label8: TLabel;
	 Label9: TLabel;
    btnOK: TBitBtn;
	 RegBrand: TSigNETBrand;
	 txtSerial1: TEdit;
	 txtSerial2: TEdit;
	 txtSerial3: TEdit;
	 txtSerial4: TEdit;
	 Label4: TLabel;
	 Label11: TLabel;
	 Label10: TLabel;
	 btnCancel: TBitBtn;
	 procedure btnRegistrationClick(Sender: TObject);
	 procedure btnOKClick(Sender: TObject);
	 procedure btnCancelClick(Sender: TObject);
	 procedure FormShow(Sender: TObject);
  private
	 { Private declarations }
	 function ExtractMonth (const sMonth: string): word;
	 function ExtractYear (const sYear: string): word;
	 procedure ReadKeyValues;
	 procedure ShowDates;
  protected
	 { Private declarations }
	 Name: String;
	 SiteID: string;
	 SerialNo: string;
	 StartMonth: word;
	 StartYear: word;
	 EndMonth: word;
	 EndYear: word;
	 function CheckSerialNo: Boolean;
	 procedure StoreRegData;
  public
	 { Public declarations }
	 AppName: string;
  end;

var
  frmSigAbout: TfrmSigAbout;

implementation

{$R *.DFM}

procedure TfrmSigAbout.btnRegistrationClick(Sender: TObject);
begin
	{Show the registration fields}
	grpRegistration.Show;
	btnCancel.Show;
	btnRegistration.Hide;
end;

procedure TfrmSigAbout.btnOKClick(Sender: TObject);
begin
	{If the group box is shown, check the serial number}
	if grpRegistration.Showing then begin
		ReadKeyValues;

		if CheckSerialNo then begin
			StoreRegData;
			Close;
		end
		else begin
			ShowMessage ('Invalid Serial number. Please re-enter carefully');
		end;
	end; {if serial number is to be checked}
end;

procedure TfrmSigAbout.btnCancelClick(Sender: TObject);
begin
	{Hide the registration fields}
	grpRegistration.Hide;
	btnCancel.Hide;
	btnRegistration.Show;
end;

procedure TfrmSigAbout.StoreRegData;
begin
	{try to store the relevant entries to the registry}
	RegBrand.WriteRegInteger ('ToMonth', EndMonth);
	RegBrand.WriteRegInteger ('ToYear', EndYear);
	RegBrand.WriteRegInteger ('FromMonth', StartMonth);
	RegBrand.WriteRegInteger ('FromYear', StartYear);
	RegBrand.WriteRegString ('Name', LowerCase (txtCustomerName.Text));
	RegBrand.WriteRegString ('SiteID', txtSiteID.Text);
end;

function TfrmSigAbout.CheckSerialNo: Boolean;
var
	sDescription: string;
	sVersion: string;
begin
	{First, write the serial number to the registry}
	sDescription := FindResourceValue ('FileDescription');
	sVersion := FindResourceValue ('FileVersion');

	{The key path will be defined as the FileDescription plus the first number of
	the version}
	RegBrand.RegistryKey := '\Software\SigNET\' + sDescription;
	RegBrand.KeyLength := 8;
	RegBrand.SeedString := sDescription + sVersion[1];
	{Ensure that the correct seed is used}
	RegBrand.Reseed;

	{Write the current serial number to the registry}
	RegBrand.WriteRegString ('Serial', txtSerial2.Text + txtSerial3.Text);

	{Now check that number}
	RegBrand.UseExpiryMonth (EndMonth);
	RegBrand.UseExpiryYear (EndYear);
	RegBrand.UseStartMonth (StartMonth);
	RegBrand.UseStartYear (StartYear);
	RegBrand.UseKeyString (LowerCase (txtCustomerName.Text));
	RegBrand.UseKeyString (txtSiteID.Text);

	Result := RegBrand.CheckRegSerialNumber ('Serial');
end;


function TfrmSigAbout.ExtractMonth(const sMonth: string): word;
begin
	Result := HexToInt (sMonth[4]);
end;

function TfrmSigAbout.ExtractYear(const sYear: string): word;
begin
	Result := ((StrToInt (sYear[1]) + 19) * 100) + StrToInt (Copy (sYear, 2, 2));
end;

procedure TfrmSigAbout.FormShow(Sender: TObject);
begin
	ShowDates;
end;

procedure TfrmSigAbout.ReadKeyValues;
begin
	{Acquire From date}
	StartMonth := ExtractMonth (txtSerial1.Text);
	StartYear := ExtractYear (txtSerial1.Text);

	{Acquire To Date}
	EndMonth := ExtractMonth (txtSerial4.Text);
	EndYear := ExtractYear (txtSerial4.Text);

	{Acquire customer information}
	Name := txtCustomerName.Text;
	SiteID := txtSiteID.Text;
	SerialNo := txtSerial2.Text + txtSerial3.Text;

	with RegBrand do begin
		RegistryKey := '\Software\SigNET\' + FindResourceValue ('FileDescription');
		Reseed;
		UseExpiryMonth (EndMonth);
		UseExpiryYear (EndYear);
		UseStartMonth (StartMonth);
		UseStartYear (StartYear);
		UseKeyString (Name);
		UseKeyString (SiteID);
	end;
end;

procedure TfrmSigAbout.ShowDates;
var
	ShowLabel: Boolean;
begin
	with RegBrand do begin
		RegistryKey := '\Software\SigNET\' + FindResourceValue ('FileDescription');
		try
			ExpiryMonth := ReadRegInteger ('ToMonth', 1);
			ExpiryYear := ReadRegInteger ('ToYear', 1900);
			StartMonth := ReadRegInteger ('FromMonth', 1);
			StartYear := ReadRegInteger ('FromYear', 1900);
		finally
			{Determine visiblity of start and expiry date labels}
			ShowLabel := not ((ExpiryMonth = OPEN_LICENCE_MONTH) and (ExpiryYear = OPEN_LICENCE_YEAR));
			lblValidFrom.Visible := ShowLabel;
			lblValidTo.Visible := ShowLabel;
			lblValidFromText.Visible := ShowLabel;
			lblValidToText.Visible := ShowLabel;
			btnRegistration.Visible := ShowLabel;
			{Show the start and expiry dates}
			lblValidFrom.Caption := FormatDateTime ('dddddd',
				EncodeDate (StartYear, StartMonth, 1));
			lblValidTo.Caption := FormatDateTime ('dddddd',
				EncodeDate (ExpiryYear, ExpiryMonth, 28));
		end;
	end;
end;

end.
