unit XFPPanelComms;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, commspanel, PanelComms, Constants, Forms;

type
  TXFPPanelComms = class(TPanelComms)
  private
    { Private declarations }
  protected
    { Protected declarations }
    FPanelNumber : integer;
  public
    { Public declarations }
    procedure SendString(Data: string); override;
  published
    { Published declarations }
    property PanelNumber : integer
             Read FPanelNumber
             Write FPanelNumber;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('AFP', [TXFPPanelComms]);
end;
{$ENDIF}

{ This procedure sends the passed string to the AFP Panel. The checksum is calculated
and appended to the string. This procedure will also determine the parity which the
string is to be sent, and if it is the new protocol, it will prepend an SOH character }
procedure TXFPPanelComms.SendString(Data: string);
var
	Checksum: integer;
	Count: integer;
begin

  if Data = 'A' + #0 then
  begin
    PanelNumber := 0;
  end;

  { first, append the panel number }
  Data := chr(PanelNumber) + Data;

	{ Determine the checksum }
	Checksum := 0;
	for count := 1 to length(Data) do
		Checksum := Checksum + ord(Data[Count]);

	{ Append the checksum to the data }
	Data := Data + chr (Checksum mod 256);
  //CharsReceived := 0;
  Text := SOH + Data;
end;

end.
