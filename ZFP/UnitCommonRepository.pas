unit UnitCommonRepository;

{
  No plans to actually show this at the moment - it is just a repository
  for all the common element
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USBBulkTransferMode,
  Dialogs;

type
  TFormCommonRepository = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fUSBBulkTransferList : tUSBBulkTransferList;
  public
    { Public declarations }
    function CheckForDevices : integer;
    property USBBulkTransferList : tUSBBulkTransferList
             read fUSBBulkTransferList;
  end;

var
  FormCommonRepository: TFormCommonRepository;

implementation

{$R *.dfm}

{ TFormCommonRepository }

function TFormCommonRepository.CheckForDevices: integer;
begin
  fUSBBulkTransferList.CheckInfo;
  Result := fUSBBulkTransferList.Count;
end;

procedure TFormCommonRepository.FormCreate(Sender: TObject);
begin
  fUSBBulkTransferList := tUSBBulkTransferList.Create;
end;

procedure TFormCommonRepository.FormDestroy(Sender: TObject);
begin
  fUSBBulkTransferList.Free;
end;

end.
