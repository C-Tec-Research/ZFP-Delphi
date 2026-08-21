unit AdvancedCommsSelDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TDlgSelCommPort = class(TForm)
    RadioGroupCommsPorts: TRadioGroup;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    LabelError: TLabel;
  private
    fCommPortPrefixText: string;
    { Private declarations }
    function EnumPorts( PortList: TStrings ) : integer;
    function GetCommPortPrefixText: string;
    function GetPort: integer;
    procedure SetPort(const Value: integer);
    property Port : integer
             read GetPort
             write SetPort;
  public
    { Public declarations }
    function Execute( var pPort : integer ) : boolean;
    property CommPortPrefixText : string
             read GetCommPortPrefixText
             write fCommPortPrefixText;
  end;

var
  DlgSelCommPort: TDlgSelCommPort;

implementation

{$R *.dfm}

{ TForm2 }

function TDlgSelCommPort.EnumPorts(PortList: TStrings) : integer;
var
  MaxPorts      : integer;
  hPort         : THandle;
  PortNumber    : integer;
  PortName      : string;
begin
  Result := 0;
  if not assigned( PortList ) then
  begin
    exit;
  end;

  { where are we running on? }
  case Win32PlatForm of
    VER_PLATFORM_WIN32_NT: MaxPorts := 256;
    VER_PLATFORM_WIN32_WINDOWS: MaxPorts := 9;
    else
    begin
      exit;
    end;
  end;

  for PortNumber := 1 to MaxPorts do
  begin
    if PortNumber > 9 then
      PortName := '\\.\COM' + IntToStr( PortNumber ) // ask Microsoft why...
    else
      PortName := 'COM' + IntToStr( PortNumber );

    hPort := CreateFile( PChar( PortName ),
      GENERIC_READ or GENERIC_WRITE,
      0,
      nil,
      OPEN_EXISTING,
      0,
      0 );

   // note that ports already in use by other apps
   // will *NOT* be detected here
    if not ( hPort = INVALID_HANDLE_VALUE ) then
    begin
      PortList.Add( CommPortPrefixText + ' ' + IntToStr( PortNumber ) );
      inc( Result );
      CloseHandle( hPort );
    end;
  end;
end;

function TDlgSelCommPort.Execute(var pPort: integer): boolean;
begin
  RadioGroupCommsPorts.Items.Clear;  //BUG0000100
  if EnumPorts( RadioGroupCommsPorts.Items ) = 0 then
  begin
    RadioGroupCommsPorts.Visible := FALSE;
    LabelError.Visible := TRUE;
    ShowModal;
    Result := FALSE;
  end
  else
  begin
    RadioGroupCommsPorts.Visible := TRUE;
    LabelError.Visible := FALSE;
    Port := pPort;
    Result := ShowModal = mrOK;
    if Result then
    begin
      pPort := Port;
    end;
  end;
end;

function TDlgSelCommPort.GetCommPortPrefixText: string;
begin
  Result := fCommPortPrefixText;
  if Result = '' then
  begin
    Result := 'Comms Port';
  end;
end;

function TDlgSelCommPort.GetPort: integer;
var
  iText : string;
begin
  Result := RadioGroupCommsPorts.ItemIndex;
  if Result <> - 1 then
  begin
    iText := RadioGroupCommsPorts.Items[ RadioGroupCommsPorts.ItemIndex ];
    Result := StrToInt( Trim(Copy( iText, Length( CommPortPrefixText ) + 1 )));
  end;
end;

procedure TDlgSelCommPort.SetPort(const Value: integer);
var
  iText : string;
  i : integer;
begin
  for i := 0 to RadioGroupCommsPorts.Items.Count - 1 do
  begin
    iText := RadioGroupCommsPorts.Items[ i ];
    if StrToInt( Trim(Copy( iText, Length( CommPortPrefixText ) + 1 ))) = Value then
    begin
      RadioGroupCommsPorts.ItemIndex := i;
      exit;
    end;
  end;
  // else
  RadioGroupCommsPorts.ItemIndex := -1;
end;

end.
