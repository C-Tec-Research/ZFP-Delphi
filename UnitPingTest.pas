unit UnitPingTest;

interface

uses
  Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Spin, SigSpinEdit, Buttons,
  UnitCommonRepository,
  USBBulkTransferMode,
  UnitRecordTypes,
  UnitTransferInterface,
  CheckLst, ExtCtrls;

type
  tPingMode = (pmIdle, pmReceivingHeader, pmReceiving );

type
  TFormTest = class(TForm)
    BitBtn2: TBitBtn;
    GroupBoxDevicesConnected: TGroupBox;
    SpeedButtonCheckDevices: TSpeedButton;
    GroupBoxPing: TGroupBox;
    Label1: TLabel;
    SigSpinEditTxPacketSize: TSigSpinEdit;
    Label2: TLabel;
    SigSpinEditPacketsToSend: TSigSpinEdit;
    ProgressBarPacketsSent: TProgressBar;
    SpeedButtonPing: TSpeedButton;
    RadioGroupDevicesConnected: TRadioGroup;
    LabelNoDevicesFound: TLabel;
    TimerPing: TTimer;
    Label3: TLabel;
    SigSpinEditRxPacketSize: TSigSpinEdit;
    procedure SigSpinEditPacketsToSendChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButtonCheckDevicesClick(Sender: TObject);
    procedure SpeedButtonPingClick(Sender: TObject);
    procedure TimerPingTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    TxPingBuffer : array of byte;
    RxPingBuffer : array of byte;
    NumBytes2Send : DWord;
    NumBytes2Read : DWord;
    TxPacketSize : DWord;
    RxPacketSize : DWord;
    NumPackets : integer;
    fActivePort : tUSBBulkTransfer;
    PingMode : tPingMode;
    PacketsSent : integer;
    Packetsrcvd : integer;
    PingStarted : tDateTime;
    BytesWritten : DWord;
    BytesRead : DWord;
    fTransferInterface: tTransferInterface;
    fActivePortIndex: integer;
    procedure SetActivePortIndex(const Value: integer);
 public
    { Public declarations }
    function Execute : boolean;
    property TransferInterface : tTransferInterface
             read fTransferInterface;
    property ActivePort : tUSBBulkTransfer
             read fActivePort;
    property ActivePortIndex : integer
             read fActivePortIndex
             write SetActivePortIndex;
    procedure CheckForDevices;
  end;

var
  FormTest: TFormTest;

implementation

{$R *.dfm}

procedure TFormTest.CheckForDevices;
var
  i: Integer;
  iCount : integer;
begin
  RadioGroupDevicesConnected.Items.Clear;
  LabelNoDevicesFound.Visible := FALSE;
  iCount := FormCommonRepository.CheckForDevices;
  for i := 0 to iCount - 1 do
  begin
    RadioGroupDevicesConnected.Items.Add( FormCommonRepository.USBBulkTransferList.Entry[ i ].Name );
  end;
  if iCount > 0 then
  begin
    RadioGroupDevicesConnected.ItemIndex := 0;
  end
  else
  begin
    LabelNoDevicesFound.Visible := TRUE;
  end;
end;

function TFormTest.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormTest.FormCreate(Sender: TObject);
begin
  fTransferInterface := tTransferInterface.Create( 2, 2 );
end;

procedure TFormTest.FormShow(Sender: TObject);
begin
  CheckForDevices;
end;

procedure TFormTest.SetActivePortIndex(const Value: integer);
begin
  fActivePortIndex := Value;
  if Value < 0 then
  begin
    fActivePort := nil;
  end
  else
  begin
    if Value >= FormCommonRepository.USBBulkTransferList.Count then
    begin
      raise exception.Create( 'Connection index out of bounds' );
    end;
    fActivePort := FormCommonRepository.USBBulkTransferList.Entry[ Value ];
  end;
  RadioGroupDevicesConnected.ItemIndex := Value;
end;

procedure TFormTest.SigSpinEditPacketsToSendChange(Sender: TObject);
begin
  ProgressBarPacketsSent.Max := SigSpinEditPacketsToSend.Value
end;

procedure TFormTest.SpeedButtonCheckDevicesClick(Sender: TObject);
begin
  CheckForDevices;
end;

procedure TFormTest.SpeedButtonPingClick(Sender: TObject);
var
   i : integer;
begin
  ActivePortIndex := RadioGroupDevicesConnected.ItemIndex;
  if ActivePortIndex >= 0 then
  begin
    PacketsSent := 0;
    PacketsRcvd := 0;
    ActivePort.Timeout := (1000);
    TxPacketSize := SigSpinEditTxPacketSize.Value;
    RxPacketSize := SigSpinEditRxPacketSize.Value;
    NumPackets := SigSpinEditPacketsToSend.Value;
    ProgressBarPacketsSent.Max := NumPackets;
    SetLength( RxPingBuffer, RxPacketSize );
    // build legit return record
    with ActivePort, TransferInterface do
    begin
      StartRec( rcSOH, cPing );
      for i := 1 to TxPacketSize do
      begin
        AddByte( Byte( i ));
      end;
      EndRec;
      NumBytes2Send  := WriteRecLen + 3;
      NumBytes2Read  := WriteRecLen;
      SetLength( TxPingBuffer, NumBytes2Send );
      // build send buffer text
      TxPingBuffer[ 0 ] := 1; // CMD_ECHO_BULK;
      TxPingBuffer[ 1 ] := WriteRecLen and $FF;
      TxPingBuffer[ 2 ] := WriteRecLen shr 8;
      for i := 0 to WriteRecLen - 1 do
      begin
        TxPingBuffer[ i + 3 ] := WriteBuffer[ i ];
      end;
    end;
    PingStarted := Time;
    TimerPing.Enabled := TRUE;
  end;

end;

procedure TFormTest.TimerPingTimer(Sender: TObject);
var
  //iBytesRead : DWord;
  iDataSize : DWord;
  i : integer;
begin
  //case PingMode of
    if PingMode = pmIdle then
    begin
      if PacketsRcvd >= NumPackets then
      begin
        // done
        TimerPing.Enabled := FALSE;
      end
      else
      begin
        if not ActivePort.IsOpen then
        begin
          ActivePort.Open;
        end;
        // send packet, wait for reply
        //ActivePort.StartExchange( TxPingBuffer, BytesWritten, RxPingBuffer, RxPacketSize, BytesRead );
        ActivePort.StartExchange( TxPingBuffer, Length( TxPingBuffer ), BytesWritten, RxPingBuffer, TransferInterface.HeaderSize , BytesRead );
        if BytesWritten <> Length( TxPingBuffer ) then
        begin
          TimerPing.Enabled := FALSE;
          ActivePort.Close;
          raise exception.Create( 'Cannot send complete record - Error code : ' + IntToStr( ActivePort.LastError ));
        end;
        inc( PacketsSent );
        PingMode := pmReceivingHeader;
      end;
    end;
    if PingMode = pmReceivingHeader then
    begin
      if ActivePort.ReadReady( BytesRead ) then
      begin
        PingMode := pmReceiving;
        iDataSize := 0;
        for i := 1 to TransferInterface.DataSizeDigits do
        begin
          iDataSize := RxPingBuffer[ 1 + i ] + 256 * iDataSize;
        end;
        ActivePort.Read( RxPingBuffer, iDataSize + TransferInterface.ChecksumDigits, BytesRead );
      end
      else
      begin
        case ActivePort.LastError of
          WAIT_TIMEOUT:
          begin
            PingMode := pmIdle;
            ActivePort.CancelRead;
            TimerPing.Enabled := FALSE;
            ActivePort.Close;
            raise exception.Create( 'Cannot read record - Timed Out ');
          end;
          ERROR_IO_PENDING:
          begin
            if BytesRead >= NumBytes2Read then
            begin
              inc( PacketsRcvd );
              PingMode := pmIdle;
              // check first byte OK
              if RxPingBuffer[ 0 ] <> 0 then
              begin
                TimerPing.Enabled := FALSE;
                ActivePort.Close;
                raise exception.Create( 'Unexpected record rcvd' );
              end;
            end;
          end;
          else
          begin
            TimerPing.Enabled := FALSE;
            PingMode := pmIdle;
            ActivePort.Close;
            raise exception.Create( 'Cannot read record - Error code : ' + IntToStr( ActivePort.LastError ));
          end;
        end;
      end;
    end;
    if PingMode = pmReceiving then
    begin
      //Start of rcv
      if ActivePort.ReadReady( BytesRead ) then
      begin
        inc( PacketsRcvd );
        PingMode := pmIdle;
        // check first byte OK
        if RxPingBuffer[ 0 ] <> 1 then
        begin
          TimerPing.Enabled := FALSE;
          ActivePort.Close;
          raise exception.Create( 'Unexpected record rcvd' );
        end;
      end
      else
      begin
        case ActivePort.LastError of
          WAIT_TIMEOUT:
          begin
            PingMode := pmIdle;
            ActivePort.CancelRead;
            TimerPing.Enabled := FALSE;
            ActivePort.Close;
            raise exception.Create( 'Cannot read record - Timed Out ');
          end;
          ERROR_IO_PENDING:
          begin
            if BytesRead >= NumBytes2Read then
            begin
              inc( PacketsRcvd );
              PingMode := pmIdle;
              // check first byte OK
              if RxPingBuffer[ 0 ] <> 1 then
              begin
                TimerPing.Enabled := FALSE;
                ActivePort.Close;
                raise exception.Create( 'Unexpected record rcvd' );
              end;
            end;
          end;
          else
          begin
            TimerPing.Enabled := FALSE;
            PingMode := pmIdle;
            ActivePort.Close;
            raise exception.Create( 'Cannot read record - Error code : ' + IntToStr( ActivePort.LastError ));
          end;
        end;
      end;
    end;
  //end;
  ProgressBarPacketsSent.Position := PacketsSent;
end;

end.
