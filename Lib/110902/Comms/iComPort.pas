unit iComPort;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComDrv32;

type
  TNotifyEvent = procedure (Sender: TObject) of object;
  TNotifyInputEvent = procedure (Sender: TObject; Data: string) of object;

  TIntegrityCommPort = class(TCommPortDriver)
  private
    iChecksummed: Boolean;						// Does packet have checksum appended
    iTimeoutCheck: DWord;						// Check for input timeout
    iInputData: string;							// Input data
    iDataLength: Word;							// Length of data
    iInvalidInputData: string;				// Invalid input data
    iOutputData: string;
    iWaitingSynchroniseData : boolean;
    iRcvZeroCount : integer;					//	Output data
    FInputTimeout: Word;						// MSecs for input timeout
    FOnInput: TNotifyInputEvent;				// Event for valid input
    FOnInvalidInput: TNotifyInputEvent;	// Event for invalid input
    FOnInputTimeout: TNotifyEvent;			// Event for input timeout
    FOnOutputTimeout: TNotifyEvent;
    FOnRcvSynchroniseRecord: TNotifyEvent;
    { Private declarations }
  protected
    { Protected declarations }
    FTempPacket: string;						// Temp packet buffer
    procedure TimerWndProc (var Msg: TMessage); override;
    function CalculateChecksum (Data: string): char;
    function ValidateChecksum (Packet: string): Boolean;
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ); override;
    property InputData: string read iInputData;
    property InvalidInputData: string read iInvalidInputData;
    property OutputData: string read iOutputData;
    function TransmitData (Data: string): Boolean;
    function Connect: Boolean;
    function SendSynchroniseData : boolean;
    procedure WaitSynchroniseData;
  published
    { Published declarations }
    property DataLength: Word read iDataLength write iDataLength; // zero implies variable length record
    property Checksummed: Boolean read iChecksummed write iChecksummed;
    property InputTimeOut: Word read FInputTimeout write FInputTimeout;
    property OnInput: TNotifyInputEvent read FOnInput write FOnInput;
    property OnInvalidInput: TNotifyInputEvent read FOnInvalidInput write FOnInvalidInput;
    property OnInputTimeout: TNotifyEvent read FOnInputTimeout write FOnInputTimeout;
    property OnOutputTimeout: TNotifyEvent read FOnOutputTimeout write FOnOutputTimeout;
    property OnRcvSynchroniseRecord : TNotifyEvent
             read FOnRcvSynchroniseRecord
             write FOnRcvSynchroniseRecord;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TIntegrityCommPort]);
end;

{ TIntegrityCommPort }

constructor TIntegrityCommPort.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  iChecksummed := FALSE;         // Does packet have checksum appended
  iTimeoutCheck := GetTickCount;
  iInputData := '';
  iDataLength := 0;              // Length of data excluding CS; 0 = variable length
  iInvalidInputData := '';	  // Invalid input data
  iOutputData := '';
  iWaitingSynchroniseData := FALSE; // assume that we are master
  iRcvZeroCount := 0;					//	Output data
  FInputTimeout := 4000;						// MSecs for input timeout
  FTempPacket := '';						// Temp packet buffer
end;

function TIntegrityCommPort.CalculateChecksum(Data: string): char;
var
  Count: DWord;
  Total,
  Checksum: byte;
begin
  {Initialise the total}
  Total := 0;
  // check size of data, if fixed record length
  if iDataLength > 0 then
  begin
    if Length( Data ) <> iDataLength then
    begin
{
      raise ERangeError.Create('CS requested for incorrectly sized record (' +
        IntToStr( Length( Data ) ) + ' bytes)');
}
      ShowMessage( 'CS requested for incorrectly sized record (' +
        IntToStr( Length( Data ) ) + ' bytes)');
      Result := char(255);
      Exit;
    end;
  end;

  {For each character of the data, convert that character into a number then
  add it to the running total}
  for Count := 1 to Length (Data) do begin
    Total := Total + Ord (Data[Count]);
  end;

  {Now acquire the checksum, remember to checksum to -1}
  Checksum := 255 - Total;

  {Now return the checksum as a character}
  Result := Chr(Checksum);
end;

function TIntegrityCommPort.Connect: Boolean;
begin
  Result := inherited Connect;
  {Start counter when comms are connected}
  iTimeoutCheck := GetTickCount;
end;

procedure TIntegrityCommPort.TimerWndProc(var Msg: TMessage);
var
  sInBuffer: pchar;		// temporary buffer acquired from input buffer
  sInString: string;	// compiled string from data received
  nDataSize: integer;	// amount of data received
  nCounter: Word; 		// number of current byte of packet
  TotalLen: Word;		// Total length of packet
begin
  {Ensure that the OnReceiveData event occurs}
  inherited TimerWndProc (Msg);
  if (msg.Msg = WM_TIMER) and Connected then
  begin
    {if timer message was given and input event handlers have been assigned}
    if (nRead <> 0) then
    begin
      nDataSize := nRead;
      sInString := FTempPacket;
      {Remember that the counter is start at the character after the last one
       in the temporary packet buffer}
      nCounter := Length (sInString) + 1;
      {If at the beginning of a packet, restart the time-out count. This will
      	mostly affect the first packet to be received after comms has been
      	established}
      if FTempPacket = '' then iTimeoutCheck := GetTickCount;

      	  // Parse incoming text
      sInBuffer := FTempInBuffer;
      {Set the total length. Checksummed packets are always 1 greater than the
       data length}
      TotalLen := iDataLength;
      if Checksummed then inc (TotalLen);
      while nDataSize > 0 do
      begin
        sInString := sInString + sInBuffer^;
        inc (nCounter);
        if sInBuffer^ = char( 0 ) then
        begin
          // could be part of sync record
          inc( iRcvZeroCount );
        end
        else if sInBuffer = char( $FF ) then
        begin
          // could be end of sync record
          if (iDataLength > 0)  and (iRcvZeroCount >= iDataLength) then
          begin // is a synch record - drop it and
                // execute the onSync event
            sInString := '';
            nCounter := 1;
            iWaitingSynchroniseData := FALSE;
            if assigned( FOnRcvSynchroniseRecord ) then
            begin
              FOnRcvSynchroniseRecord( self );
            end;
          end;
          iRcvZeroCount := 0;
        end
        else
        begin
          iRcvZeroCount := 0;
        end;
        {generate event handlers for valid and invalid input data. If it is
         not checksummed, assume all data is valid}
        if (nCounter > TotalLen) then
        begin
          if Checksummed and (not ValidateChecksum (sInstring)) then
          begin
            {Checksum is incorrect}
	          {Remember to strip checksum from final data string}
	          iInvalidInputData := Copy (sInString, 1, iDataLength);
	          if Assigned (FOnInvalidInput) then FOnInvalidInput (Self, iInvalidInputData);
          end
          else
          begin
	          {Checksum is correct or not present}
	          if Checksummed then
	          {Remember to strip checksum from final input data string}
	          iInputData := Copy (sInString, 1, iDataLength)
          else
	          {No checksum, so packet is data string}
	          iInputData := sInstring;
	          if Assigned (FOnInput) and not iWaitingSynchroniseData then
            begin
	            FOnInput (Self, iInputData);
            end;
          end;
          {Reset counters}
          nCounter := 1;
	        sInString := '';
	        iTimeoutCheck := GetTickCount;
        end; {on input event handlers}

        {move to next byte for processing}
        dec( nDataSize );
        inc( sInBuffer );
      end; {While DataSize > 0}
      FTempPacket := sInString;
    end; {if data was read}

    {Check for input timeout here}
    if ((GetTickCount - iTimeoutCheck) > FInputTimeout) and Assigned (FOnInputTimeout) then
    begin
      FOnInputTimeout (Self);
      iTimeoutCheck := GetTickCount;
      // Clear the buffer
      iInvalidInputData := FTempPacket;
      FTempPacket := '';
    end;
  end; {if message was timer message}
end;

function TIntegrityCommPort.TransmitData(Data: string): Boolean;
var
	Len: integer;
	Packet: string;
	BytesWritten: integer;
begin
	{Determine the length of the data packet}
	Len := Length (Data);
	if Checksummed then begin
		Packet := Data + CalculateChecksum (Data);
		inc (Len);
	end
	else
		Packet := Data;

	{Set the output data property}
	iOutputData := Data;
	{$IFOPT H+}
	// New syle pascal string (NULL terminated)
	BytesWritten := SendData( pchar(Packet), len );
	{$ELSE}
	// Old style pascal string (s[0] = length)
	BytesWritten := SendData( pchar(@Packet[1]), len );
	{$ENDIF}
	{If the number of bytes written is the length of the data packet, return true
	otherwise return false}
	Result := (BytesWritten = abs(Len));
	{If a negative number is returned, that indicates a time out has occurred.}
	if (BytesWritten < 0) and Assigned (FOnOutputTimeout) then begin
		{Trigger the output time out}
		FOnOutputTimeout (Self);
	end;
end;

function TIntegrityCommPort.ValidateChecksum(Packet: string): Boolean;
var
	Data: string;
	Checksum: char;
	PacketLength: DWord;
begin
	{Split the packet into its data and checksum components}
	PacketLength := Length(Packet);
	Data := Copy (Packet, 0, PacketLength - 1);
	Checksum := Packet[PacketLength];

	{Compare the checksum with the calculated checksum, then return the result}
	Result := (CheckSum = CalculateChecksum (Data));
end;

function TIntegrityCommPort.SendSynchroniseData : boolean;
var
  Packet: string;
begin
  if iDataLength > 0 then
  begin
    Packet := StringOfChar( char($00), iDataLength );
    Result := TransmitData( Packet );
    // flush any recieved data so far
    iInvalidInputData := FTempPacket;
    FTempPacket := '';
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TIntegrityCommPort.WaitSynchroniseData;
begin
  iWaitingSynchroniseData := TRUE;
end;

end.
