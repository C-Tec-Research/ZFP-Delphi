unit Comm32;
//
// Version 1.2
//
// This Communications Component is implemented using separate Read and Write
// threads. Messages from the threads are posted to the Comm control which is
// an invisible window. To handle data from the comm port, simply
// attach a handler to 'OnReceiveData'. There is no need to free the memory
// buffer passed to this handler. If TAPI is used to open the comm port, some
// changes to this component are needed ('StartComm' currently opens the comm
// port). The 'OnRequestHangup' event is included to assist this.
//
// David Wann
// Stamina Software
// 7 Jun 96
// davidwann@hunterlink.net.au
//
// Changes since version 1.0
// * added stop-bit, parity properties
// * fixed Read-thread priority bug
//
// Changes since V1.1
// * Changed some variable names so they aren't so C-like (sorry)
// * Fixed the bug where you had to wait for StartComm before sending data
// * added Byte-size property
//
interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Misc;

const
	// messages from read/write threads
	PWM_GOTCOMMDATA = WM_USER + 1;
	PWM_REQUESTHANGUP = WM_USER + 2;
	PWM_THREADREADY = WM_USER +3;

type
	ECommsError = class( Exception );

	TParity = (pNone,pOdd,pEven,pMark,pSpace);
	TStopBits = (sb1_0,sb1_5,sb2_0);

	TReadThread = class( TThread )
	protected
		procedure Execute; override;
	public
		hCommFile: 			THandle;
		hCloseEvent:		THandle;
		hComm32Window:		THandle;
		function SetupCommEvent( lpOverlappedCommEvent: POverlapped;
						var dwEventMask: DWORD ): Boolean;
		function SetupReadEvent( lpOverlappedRead: POverlapped;
						szInputBuffer: PChar; dwSizeofBuffer: DWORD;
						var NumberOfBytesRead: DWORD ): Boolean;
		function HandleCommEvent( lpOverlappedCommEvent: POverlapped;
						var dwEventMask: DWORD; fRetrieveEvent: Boolean ): Boolean;
		function HandleReadEvent( lpOverlappedRead: POverlapped;
						szInputBuffer: PChar; dwSizeofBuffer: DWORD;
						var NumberOfBytesRead: DWORD ): Boolean;
		function HandleReadData( szInputBuffer: LPCSTR; dwSizeofBuffer: DWORD ): Boolean;
		function ReceiveData( lpNewString: PChar; dwSizeofNewString: DWORD ): BOOL;
		procedure PostHangupCall;
	end;

	TWriteThread = class( TThread )
	protected
		procedure Execute; override;
		function HandleWriteData( lpOverlappedWrite: POverlapped;
				pDataToWrite: PChar; dwNumberOfBytesToWrite: DWORD): Boolean;
	public
		hCommFile: 			THandle;
		hCloseEvent:		THandle;
		hComm32Window:		THandle;
		function WriteComm( pDataToWrite: LPCSTR; dwSizeofDataToWrite: DWORD ): Boolean;
		procedure PostHangupCall;
	end;

	TReceiveDataEvent = procedure( Buffer: Pointer; BufferLength: Word ) of object;

	TComm32 = class( TComponent )
	private
		{ Private declarations }
		ReadThread:				TReadThread;
		WriteThread:			TWriteThread;
		ThreadError,
		WriteCreated,
		ReadCreated:			Boolean;
		FCommsLogFileName,
		FCommPort:				string;
		hCommFile: 				THandle;
		hCloseEvent:			THandle;
		FOnReceiveData: 		TReceiveDataEvent;
		FOnRequestHangup:		TNotifyEvent;
		FHWnd:					THandle;
		FBaudRate:			DWORD;
		FParity: 				TParity;
		FStopBits:			TStopBits;
		FByteSize:			Byte;

		procedure SetCommsLogFileName( LogFileName: string );
		function GetReceiveDataEvent: TReceiveDataEvent;
		procedure SetReceiveDataEvent( AReceiveDataEvent: TReceiveDataEvent );
		function GetRequestHangupEvent: TNotifyEvent;
		procedure SetRequestHangupEvent( ARequestHangupEvent: TNotifyEvent );
		procedure CommWndProc( var msg: TMessage );
	protected
		{ Protected declarations }
		procedure CloseReadThread;
		procedure CloseWriteThread;
		procedure ReceiveData( Buffer: PChar; BufferLength: Word );
		procedure RequestHangup;
	public
		{ Public declarations }
		constructor Create( AOwner: TComponent ); override;
		destructor Destroy; override;
		function StartComm: Boolean;
		procedure StopComm;
		function WriteCommData( pDataToWrite: PChar; dwSizeofDataToWrite: Word ): Boolean;
	published
		{ Published declarations }
		property BaudRate: DWORD read FBaudRate write FBaudRate default 9600;
		property ByteSize: Byte read FByteSize write FByteSize default 8;
		property Parity: TParity read FParity write FParity default pNone;
		property StopBits: TStopBits read FStopBits write FStopBits default sb1_0;
		property CommPort: string read FCommPort write FCommPort;
		property CommsLogFileName: string read FCommsLogFileName write SetCommsLogFileName;
		property OnReceiveData: TReceiveDataEvent
				read GetReceiveDataEvent write SetReceiveDataEvent;
		property OnRequestHangup: TNotifyEvent
				read GetRequestHangupEvent write SetRequestHangupEvent;
	end;

const
// This is the message posted to the WriteThread
// When we have something to write.
	PWM_COMMWRITE = WM_USER+1;

// Default size of the Input Buffer used by this code.
	INPUTBUFFERSIZE = 2048;

var
	CommsLogFile:	Text; // means you can only debug 1 component at a time


procedure LogDebugInfo( outstr: PChar );
procedure LogDebugLastError( dwLastError: DWORD; szPrefix: PChar );
procedure Register;

implementation

var
	CommsLogName:	string; // used as a check if file is assigned

(******************************************************************************)
//									TCOMM32 PUBLIC METHODS
(******************************************************************************)

constructor TComm32.Create( AOwner: TComponent );
begin
	inherited Create( AOwner );
	FCommPort := 'COM2';
	FBaudRate := 9600;
	FParity := pNone;
	FByteSize := 8;
	FStopBits := sb1_0;
	FCommsLogFileName := '';
	CommsLogName := '';
	ReadThread := nil;
	WriteThread := nil;
	hCommFile := 0;
	if not (csDesigning in ComponentState) then
		FHWnd := AllocateHWnd(CommWndProc);
end;

destructor TComm32.Destroy;
begin
	if not (csDesigning in ComponentState) then
	begin
		DeallocateHWnd(FHwnd);
	end;
	inherited Destroy;
end;

//
//  FUNCTION: StartComm
//
//  PURPOSE: Starts communications over the comm port.
//
//  PARAMETERS:
//    hNewCommFile - This is the COMM File handle to communicate with.
//                   This handle is obtained from TAPI.
//
//  RETURN VALUE:
//    TRUE if able to setup the communications.
//
//  COMMENTS:
//
//    StartComm makes sure there isn't communication in progress already,
//    creates a Comm file, and creates the read and write threads.  It
//    also configures the hNewCommFile for the appropriate COMM settings.
//
//    If StartComm fails for any reason, it's up to the calling application
//    to close the Comm file handle.
//
//
function TComm32.StartComm: Boolean;
var
	commtimeouts:	TCommTimeouts;
	dcb:				Tdcb;
	commprop:		TCommProp;
	fdwEvtMask:		DWORD;
	hNewCommFile: THandle;
begin
	// Are we already doing comm?
	if (hCommFile <> 0) then
		raise ECommsError.Create( 'Already have a comm file open' );

	if CommsLogFileName <> '' then
	begin
		AssignFile( CommsLogFile, fCommsLogFileName );
		Rewrite( CommsLogFile );
	end;

	hNewCommFile := CreateFile(
							PChar(fCommPort),
							GENERIC_READ+GENERIC_WRITE,
							0, {not shared}
							nil, {no security ??}
							OPEN_EXISTING,
							{FILE_ATTRIBUTE_NORMAL+}FILE_FLAG_OVERLAPPED,
							0 {template} );
	if hNewCommFile = INVALID_HANDLE_VALUE then
		raise ECommsError.Create( 'Error opening com port' );

	// Is this a valid comm handle?
	if GetFileType( hNewCommFile ) <> FILE_TYPE_CHAR then
		raise ECommsError.Create( 'File handle is not a comm handle. ' );

	// Its ok to continue.

	hCommFile := hNewCommFile;

	// Setting and querying the comm port configurations.

	// Configure the comm settings.
	// NOTE: Most Comm settings can be set through TAPI, but this means that
	//       the CommFile will have to be passed to this component.

	GetCommState( hNewCommFile, dcb );
	GetCommProperties( hNewCommFile, commprop );
	GetCommMask( hCommFile, fdwEvtMask );
	GetCommTimeouts( hCommFile, commtimeouts );

	// The CommTimeout numbers will very likely change if you are
	// coding to meet some kind of specification where
	// you need to reply within a certain amount of time after
	// recieving the last byte.  However,  If 1/4th of a second
	// goes by between recieving two characters, its a good
	// indication that the transmitting end has finished, even
	// assuming a 1200 baud modem.

	commtimeouts.ReadIntervalTimeout         := 250;
	commtimeouts.ReadTotalTimeoutMultiplier  := 0;
	commtimeouts.ReadTotalTimeoutConstant    := 0;
	commtimeouts.WriteTotalTimeoutMultiplier := 0;
	commtimeouts.WriteTotalTimeoutConstant   := 0;

	SetCommTimeouts( hCommFile, commtimeouts );

	// fAbortOnError is the only DCB dependancy in TapiComm.
	// Can't guarentee that the SP will set this to what we expect.
	{dcb.fAbortOnError := False; NOT VALID}
	dcb.BaudRate := FBaudRate;
	dcb.Parity := Ord(FParity);
	dcb.StopBits := Ord(FStopBits);
	SetCommState( hNewCommFile, dcb );

	// Create the event that will signal the threads to close.
	hCloseEvent := CreateEvent( nil, True, False, nil );

	if hCloseEvent = 0 then
	begin
		 LogDebugLastError( GetLastError, 'Unable to CreateEvent: ' );
		 hCommFile := 0;
		 Result := False;
		 Exit
	end;

	// Create the Read thread.
	try
		ReadThread := TReadThread.Create( True {suspended} );
	except
		LogDebugLastError( GetLastError, 'Unable to create Read thread' );
		raise ECommsError.Create( 'Unable to create Read thread' );
	end;
	ReadThread.hCommFile := hCommFile;
	ReadThread.hCloseEvent := hCloseEvent;
	ReadThread.hComm32Window := FHWnd;
	ReadThread.Resume;

	// Comm threads should have a higher base priority than the UI thread.
	// If they don't, then any temporary priority boost the UI thread gains
	// could cause the COMM threads to loose data.
	ReadThread.Priority := tpHighest;

	// Create the Write thread.
	try
		WriteThread := TWriteThread.Create( True {suspended} );
	except
		LogDebugLastError( GetLastError, 'Unable to create Write thread' );
		raise ECommsError.Create( 'Unable to create Write thread' );
	end;
	WriteThread.hCommFile := hCommFile;
	WriteThread.hCloseEvent := hCloseEvent;
	WriteThread.hComm32Window := FHWnd;
	WriteThread.Resume;

	WriteThread.Priority := tpHigher;

	while not ((WriteCreated and ReadCreated) or ThreadError) do
		{Thread Error not Implemented as yet - use a timeout?}
		Application.ProcessMessages;

	// Everything was created ok.  Ready to go!
	Result := True;
end; {TComm32.StartComm}

//
//  FUNCTION: StopComm
//
//  PURPOSE: Stop and end all communication threads.
//
//  PARAMETERS:
//    none
//
//  RETURN VALUE:
//    none
//
//  COMMENTS:
//
//    Tries to gracefully signal all communication threads to
//    close, but terminates them if it has to.
//
//
procedure TComm32.StopComm;
begin
	// No need to continue if we're not communicating.
	if hCommFile = 0 then
		Exit;

	LogDebugInfo( 'Stopping the Comm' );

	 // Close the threads.
	CloseReadThread;
	CloseWriteThread;

	// Not needed anymore.
	CloseHandle( hCloseEvent );

	// Now close the comm port handle.
	CloseHandle( hCommFile );
	hCommFile := 0;
	if fCommsLogFileName <> '' then
		CloseFile( CommsLogFile );
end; {TComm32.StopComm}

//
//  FUNCTION: WriteCommData(PChar, Word)
//
//  PURPOSE: Send a String to the Write Thread to be written to the Comm.
//
//  PARAMETERS:
//    pszStringToWrite     - String to Write to Comm port.
//    nSizeofStringToWrite - length of pszStringToWrite.
//
//  RETURN VALUE:
//    Returns TRUE if the PostMessage is successful.
//    Returns FALSE if PostMessage fails or Write thread doesn't exist.
//
//  COMMENTS:
//
//    This is a wrapper function so that other modules don't care that
//    Comm writing is done via PostMessage to a Write thread.  Note that
//    using PostMessage speeds up response to the UI (very little delay to
//    'write' a string) and provides a natural buffer if the comm is slow
//    (ie:  the messages just pile up in the message queue).
//
//    Note that it is assumed that pszStringToWrite is allocated with
//    LocalAlloc, and that if WriteCommData succeeds, its the job of the
//    Write thread to LocalFree it.  If WriteCommData fails, then its
//    the job of the calling function to free the string.
//
//
function TComm32.WriteCommData( pDataToWrite: PChar; dwSizeofDataToWrite: Word ): Boolean;
var
	Buffer:	Pointer;
begin
	if WriteThread <> nil then
	begin
		Buffer := Pointer(LocalAlloc( LPTR, dwSizeofDataToWrite+1 ));
		Move( pDataToWrite^, Buffer^, dwSizeofDataToWrite );
		if PostThreadMessage( WriteThread.ThreadID, PWM_COMMWRITE,
					 WPARAM(dwSizeofDataToWrite), LPARAM(Buffer) ) then
		begin
			Result := true;
			Exit;
		end
		else
			LogDebugInfo( 'Failed to Post to Write thread. ' );
	end
	else
		LogDebugInfo( 'Write thread not created' );

	Result := False;
end; {TComm32.WriteCommData}

(******************************************************************************)
//									TCOMM32 PROTECTED METHODS
(******************************************************************************)

//
//  FUNCTION: CloseReadThread
//
//  PURPOSE: Close the Read Thread.
//
//  PARAMETERS:
//    none
//
//  RETURN VALUE:
//    none
//
//  COMMENTS:
//
//    Closes the Read thread by signaling the CloseEvent.
//    Purges any outstanding reads on the comm port.
//
//    Note that terminating a thread leaks memory.
//    Besides the normal leak incurred, there is an event object
//    that doesn't get closed.  This isn't worth worrying about
//    since it shouldn't happen anyway.
//
//
procedure TComm32.CloseReadThread;
begin
	// If it exists...
	if ReadThread <> nil then
	begin
		LogDebugInfo( 'Closing Read Thread ');

		// Signal the event to close the worker threads.
		SetEvent( hCloseEvent );

		// Purge all outstanding reads
		PurgeComm( hCommFile, PURGE_RXABORT + PURGE_RXCLEAR );

		// Wait 10 seconds for it to exit.  Shouldn't happen.
		if (WaitForSingleObject(ReadThread.Handle, 10000) = WAIT_TIMEOUT) then
		begin
			LogDebugInfo( 'Read thread not exiting.  Terminating it.' );
			ReadThread.Terminate;
		end;
		ReadThread.Free;
		ReadThread := nil;
	end;
end; {TComm32.CloseReadThread}


//
//  FUNCTION: CloseWriteThread
//
//  PURPOSE: Closes the Write Thread.
//
//  PARAMETERS:
//    none
//
//  RETURN VALUE:
//    none
//
//  COMMENTS:
//
//    Closes the write thread by signaling the CloseEvent.
//    Purges any outstanding writes on the comm port.
//
//    Note that terminating a thread leaks memory.
//    Besides the normal leak incurred, there is an event object
//    that doesn't get closed.  This isn't worth worrying about
//    since it shouldn't happen anyway.
//
//
procedure TComm32.CloseWriteThread;
begin
	// If it exists...
	if WriteThread <> nil then
	begin
		LogDebugInfo( 'Closing Write Thread' );

		// Signal the event to close the worker threads.
		SetEvent(hCloseEvent);

		// Purge all outstanding writes.
		PurgeComm(hCommFile, PURGE_TXABORT + PURGE_TXCLEAR);

		// Wait 10 seconds for it to exit.  Shouldn't happen.
		if WaitForSingleObject( WriteThread.Handle, 10000 ) = WAIT_TIMEOUT then
		begin
			LogDebugInfo( 'Write thread not exiting.  Terminating it.' );
			WriteThread.Terminate;
		end;
		WriteThread.Free;
		WriteThread := nil;
	end;
end; {TComm32.CloseWriteThread}

procedure TComm32.ReceiveData( Buffer: PChar; BufferLength: Word );
begin
	if Assigned(FOnReceiveData) then
		FOnReceiveData( Buffer, BufferLength );
end;

procedure TComm32.RequestHangup;
begin
	if Assigned(FOnRequestHangup) then
		FOnRequestHangup( Self );
end;

(******************************************************************************)
//									TCOMM32 PRIVATE METHODS
(******************************************************************************)

procedure TComm32.SetCommsLogFileName( LogFileName: string );
begin
	CommsLogName := LogFileName;
	FCommsLogFileName := LogFileName;
end;

procedure TComm32.CommWndProc( var msg: TMessage );
begin
	case msg.msg of
		PWM_GOTCOMMDATA:
		begin
			ReceiveData( PChar(msg.LParam), msg.WParam );
			LocalFree( msg.LParam );
		end;
		PWM_REQUESTHANGUP:
			RequestHangup;
		PWM_THREADREADY:
			if msg.WParam = 0 then
				ReadCreated := True
			else
				WriteCreated := True;
	end;
end;

function TComm32.GetReceiveDataEvent: TReceiveDataEvent;
begin
	Result := FOnReceiveData;
end;

procedure TComm32.SetReceiveDataEvent( AReceiveDataEvent: TReceiveDataEvent );
begin
	FOnReceiveData := AReceiveDataEvent;
end;

function TComm32.GetRequestHangupEvent: TNotifyEvent;
begin
	Result := FOnRequestHangup;
end;

procedure TComm32.SetRequestHangupEvent( ARequestHangupEvent: TNotifyEvent );
begin
	FOnRequestHangup := ARequestHangupEvent;
end;


(******************************************************************************)
//											READ THREAD
(******************************************************************************)

//
//  PROCEDURE: TReadThread.Execute
//
//  PURPOSE: This is the starting point for the Read Thread.
//
//  PARAMETERS:
//    None.
//
//  RETURN VALUE:
//    None.
//
//  COMMENTS:
//
//    The Read Thread uses overlapped ReadFile and sends any data
//    read from the comm port to the Comm32Window.  This is
//    eventually done through a PostMessage so that the Read Thread
//    is never away from the comm port very long.  This also provides
//    natural desynchronization between the Read thread and the UI.
//
//    If the CloseEvent object is signaled, the Read Thread exits.
//
//	  Separating the Read and Write threads is natural for a application
//    where there is no need for synchronization between
//    reading and writing.  However, if there is such a need (for example,
//    most file transfer algorithms synchronize the reading and writing),
//    then it would make a lot more sense to have a single thread to handle
//    both reading and writing.
//
//
procedure TReadThread.Execute;
var
	 szInputBuffer:	array[0..INPUTBUFFERSIZE-1] of Char;
	 nNumberOfBytesRead:	DWORD;

	 HandlesToWaitFor:	array[0..2] of THandle;
	 dwHandleSignaled:	DWORD;

	 dwEventMask:			DWORD;

	 // Needed for overlapped I/O (ReadFile)
	 overlappedRead:		TOverlapped;

	 // Needed for overlapped Comm Event handling.
	 overlappedCommEvent:	TOverlapped;
label
	EndReadThread;
begin

	FillChar( overlappedRead, Sizeof(overlappedRead), 0 );
	FillChar( overlappedCommEvent, Sizeof(overlappedCommEvent), 0 );

	// Lets put an event in the Read overlapped structure.
	overlappedRead.hEvent := CreateEvent( nil, True, True, nil);
	if overlappedRead.hEvent = 0 then
	begin
		 LogDebugLastError( GetLastError, 'Unable to CreateEvent: ' );
		 PostHangupCall;
		 goto EndReadThread;
	end;

	// And an event for the CommEvent overlapped structure.
	overlappedCommEvent.hEvent := CreateEvent( nil, True, True, nil);
	if overlappedCommEvent.hEvent = 0 then
	begin
		 LogDebugLastError( GetLastError, 'Unable to CreateEvent: ' );
		 PostHangupCall();
		 goto EndReadThread;
	end;

	// We will be waiting on these objects.
	HandlesToWaitFor[0] := hCloseEvent;
	HandlesToWaitFor[1] := overlappedCommEvent.hEvent;
	HandlesToWaitFor[2] := overlappedRead.hEvent;


	// Setup CommEvent handling.

	// Set the comm mask so we receive error signals.
	if not SetCommMask(hCommFile, EV_ERR) then
	begin
		LogDebugLastError( GetLastError, 'Unable to SetCommMask: ' );
		PostHangupCall;
		goto EndReadThread;
	end;

	// Start waiting for CommEvents (Errors)
	if not SetupCommEvent( @overlappedCommEvent,  dwEventMask ) then
	begin
		LogDebugLastError( GetLastError, 'Unable to SetupCommEvent1: ' );
		PostHangupCall;
		goto EndReadThread;
	end;

	// Start waiting for Read events.
	if not SetupReadEvent( @overlappedRead,
					szInputBuffer, INPUTBUFFERSIZE,
					 nNumberOfBytesRead ) then
	begin
		LogDebugLastError( GetLastError, 'Unable to SetupReadEvent: ' );
		PostHangupCall;
		goto EndReadThread;
	end;

	// Everything ready - tell main thread
	PostMessage( hComm32Window, PWM_THREADREADY, 0, 0 );

	// Keep looping until we break out.
	while True do
	begin
		// Wait until some event occurs (data to read; error; stopping).
		dwHandleSignaled :=
				WaitForMultipleObjects(3, @HandlesToWaitFor,
					False, INFINITE);

		 // Which event occured?
		case dwHandleSignaled of
			WAIT_OBJECT_0:     // Signal to end the thread.
			begin
				// Time to exit.
				OutputDebugString( 'Time to Exit' );
				goto EndReadThread;
			end;

			WAIT_OBJECT_0 + 1: // CommEvent signaled.
			begin
				// Handle the CommEvent.
				if not HandleCommEvent( @overlappedCommEvent,  dwEventMask, TRUE ) then
				begin
					PostHangupCall;
					LogDebugLastError( GetLastError, 'Unable HandleCommEvent: ' );
					goto EndReadThread;
				end;

				// Start waiting for the next CommEvent.
				if not SetupCommEvent( @overlappedCommEvent,  dwEventMask ) then
				begin
					PostHangupCall;
					LogDebugLastError( GetLastError, 'Unable to SetupCommEvent2: ' );
					goto EndReadThread;
				end;
				{break;??}
			end;

			WAIT_OBJECT_0 + 2: // Read Event signaled.
			begin
				// Get the new data!
				if not HandleReadEvent( @overlappedRead,
									szInputBuffer, INPUTBUFFERSIZE,
									 nNumberOfBytesRead ) then
				begin
					PostHangupCall;
					LogDebugLastError( GetLastError, 'Unable to HandleReadEvent: ' );
					goto EndReadThread;
				end;

				// Wait for more new data.
				if not SetupReadEvent( @overlappedRead,
									szInputBuffer, INPUTBUFFERSIZE,
									 nNumberOfBytesRead ) then
				begin
					PostHangupCall;
					goto EndReadThread;
				end;
				{break;}
			end;

			WAIT_FAILED:       // Wait failed.  Shouldn't happen.
			begin
				LogDebugLastError( GetLastError, 'Read WAIT_FAILED: ' );
				PostHangupCall;
				goto EndReadThread;
			end;

			else    // This case should never occur.
			begin
				LogDebugInfo( PChar('Unexpected Wait return value '+
							IntToStr(dwHandleSignaled)) );
				PostHangupCall;
				goto EndReadThread;
			end;
		end; {case dwHandleSignaled}
	end; {while True}

	// Time to clean up Read Thread.
 EndReadThread:

	LogDebugInfo( 'Read thread shutting down' );
	PurgeComm( hCommFile, PURGE_RXABORT + PURGE_RXCLEAR );
	CloseHandle( overlappedRead.hEvent );
	CloseHandle( overlappedCommEvent.hEvent );
end; {TReadThread.Execute}

//
//  FUNCTION: SetupReadEvent(LPOVERLAPPED, PChar, DWORD, LPDWORD)
//
//  PURPOSE: Sets up an overlapped ReadFile
//
//  PARAMETERS:
//    lpOverlappedRead      - address of overlapped structure to use.
//    szInputBuffer       - Buffer to place incoming bytes.
//    dwSizeofBuffer        - size of szInputBuffer.
//    NumberOfBytesRead  - address of DWORD to place the number of read bytes.
//
//  RETURN VALUE:
//    TRUE if able to successfully setup the ReadFile.  FALSE if there
//    was a failure setting up or if the CloseEvent object was signaled.
//
//  COMMENTS:
//
//    This function is a helper function for the Read Thread.  This
//    function sets up the overlapped ReadFile so that it can later
//    be waited on (or more appropriatly, so the event in the overlapped
//    structure can be waited upon).  If there is data waiting, it is
//    handled and the next ReadFile is initiated.
//    Another possible reason for returning FALSE is if the comm port
//    is closed by the service provider.
//
//
//
function TReadThread.SetupReadEvent( lpOverlappedRead: POverlapped;
	 szInputBuffer: PChar; dwSizeofBuffer: DWORD;
	 var NumberOfBytesRead: DWORD ): Boolean;
var
	 dwLastError: DWORD;
label
	StartSetupReadEvent;
begin

StartSetupReadEvent:

	Result := False;
	// Make sure the CloseEvent hasn't been signaled yet.
	// Check is needed because this function is potentially recursive.
	if WAIT_TIMEOUT <> WaitForSingleObject(hCloseEvent,0) then
		 Exit;

	// Start the overlapped ReadFile.
	if ReadFile( hCommFile,
				szInputBuffer^, dwSizeofBuffer,
				NumberOfBytesRead, lpOverlappedRead ) then
	begin
		 // This would only happen if there was data waiting to be read.

		LogDebugInfo( 'Data waiting for ReadFile: ');

		 // Handle the data.
		if not HandleReadData( szInputBuffer, NumberOfBytesRead ) then
			Exit;

		 // Start waiting for more data.
		goto StartSetupReadEvent;
	end;

	// ReadFile failed.  Expected because of overlapped I/O.
	dwLastError := GetLastError;


	// LastError was ERROR_IO_PENDING, as expected.
	if dwLastError = ERROR_IO_PENDING then
	begin
		 LogDebugInfo( 'Waiting for data from comm connection.' );
		 Result := True;
		 Exit;
	end;

	// Its possible for this error to occur if the
	// service provider has closed the port.  Time to end.
	if dwLastError = ERROR_INVALID_HANDLE then
	begin
		 LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
			  'Likely that the Service Provider has closed the port.' );
		 Exit;
	end;

	// Unexpected error. No idea what could cause this to happen.
	LogDebugLastError( dwLastError, 'Unexpected ReadFile error: ' );

	PostHangupCall;
end; {TReadThread.SetupReadEvent}

//
//  FUNCTION: HandleReadData(LPCSTR, DWORD)
//
//  PURPOSE: Deals with data after its been read from the comm file.
//
//  PARAMETERS:
//    szInputBuffer  - Buffer to place incoming bytes.
//    dwSizeofBuffer   - size of szInputBuffer.
//
//  RETURN VALUE:
//    TRUE if able to successfully handle the data.
//    FALSE if unable to allocate memory or handle the data.
//
//  COMMENTS:
//
//    This function is yet another helper function for the Read Thread.
//    It LocalAlloc()s a buffer, copies the new data to this buffer and
//    calls PostWriteToDisplayCtl to let the EditCtls module deal with
//    the data.  Its assumed that PostWriteToDisplayCtl posts the message
//    rather than dealing with it right away so that the Read Thread
//    is free to get right back to waiting for data.  Its also assumed
//    that the EditCtls module is responsible for LocalFree()ing the
//    pointer that is passed on.
//
//
function TReadThread.HandleReadData( szInputBuffer: LPCSTR; dwSizeofBuffer: DWORD ): Boolean;
var
	lpszPostedBytes: PChar;
begin
	Result := False;
	 // If we got data and didn't just time out empty...
	if dwSizeofBuffer <> 0 then
	begin
			// Do something with the bytes read.
		LogDebugInfo( 'Got something from Comm port!!!' );

		lpszPostedBytes := PChar( LocalAlloc( LPTR, dwSizeofBuffer+1 ) );

		if lpszPostedBytes = nil{NULL} then
		begin
			LogDebugLastError( GetLastError, 'LocalAlloc: ' );
			Exit;
		end;

		Move( szInputBuffer^, lpszPostedBytes^, dwSizeofBuffer );
		lpszPostedBytes[dwSizeofBuffer] := #0;

		Result := ReceiveData( lpszPostedBytes, dwSizeofBuffer );
	end;
end; {TReadThread.HandleReadData}

//
//  FUNCTION: HandleReadEvent(LPOVERLAPPED, PChar, DWORD, LPDWORD)
//
//  PURPOSE: Retrieves and handles data when there is data ready.
//
//  PARAMETERS:
//    lpOverlappedRead      - address of overlapped structure to use.
//    szInputBuffer       - Buffer to place incoming bytes.
//    dwSizeofBuffer        - size of szInputBuffer.
//    NumberOfBytesRead  - address of DWORD to place the number of read bytes.
//
//  RETURN VALUE:
//    TRUE if able to successfully retrieve and handle the available data.
//    FALSE if unable to retrieve or handle the data.
//
//  COMMENTS:
//
//    This function is another helper function for the Read Thread.  This
//    is the function that is called when there is data available after
//    an overlapped ReadFile has been setup.  It retrieves the data and
//    handles it.
//
//
function TReadThread.HandleReadEvent( lpOverlappedRead: POverlapped;
	 szInputBuffer: PChar; dwSizeofBuffer: DWORD;
	 var NumberOfBytesRead: DWORD ): Boolean;
var
	dwLastError: DWORD;
begin
	Result := False;
	if GetOverlappedResult( hCommFile,
			lpOverlappedRead^, NumberOfBytesRead, False ) then
	begin
		Result := HandleReadData( szInputBuffer, NumberOfBytesRead );
		Exit;
	end;

	// Error in GetOverlappedResult; handle it.

	dwLastError := GetLastError;

	// Its possible for this error to occur if the
	// service provider has closed the port.  Time to end.
	if dwLastError = ERROR_INVALID_HANDLE then
	begin
		LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
				'Likely that the Service Provider has closed the port.' );
		Exit;
	end;

	LogDebugLastError( dwLastError,
		  'Unexpected GetOverlappedResult Read Error: ' );

	PostHangupCall;
end; {TReadThread.HandleReadEvent}

//
//  FUNCTION: SetupCommEvent(LPOVERLAPPED, LPDWORD)
//
//  PURPOSE: Sets up the overlapped WaitCommEvent call.
//
//  PARAMETERS:
//    lpOverlappedCommEvent - Pointer to the overlapped structure to use.
//    dwEventMask          - Pointer to DWORD to received Event data.
//
//  RETURN VALUE:
//    TRUE if able to successfully setup the WaitCommEvent.
//    FALSE if unable to setup WaitCommEvent, unable to handle
//    an existing outstanding event or if the CloseEvent has been signaled.
//
//  COMMENTS:
//
//    This function is a helper function for the Read Thread that sets up
//    the WaitCommEvent so we can deal with comm events (like Comm errors)
//    if they occur.
//
//
function TReadThread.SetupCommEvent( lpOverlappedCommEvent: POverlapped;
	 var dwEventMask: DWORD ): Boolean;
var
	dwLastError: DWORD;
label
	StartSetupCommEvent;
begin

	Result := False;
StartSetupCommEvent:

	 // Make sure the CloseEvent hasn't been signaled yet.
	 // Check is needed because this function is potentially recursive.
	if WAIT_TIMEOUT <> WaitForSingleObject( hCloseEvent,0 ) then
		Exit;

	// Start waiting for Comm Errors.
	if WaitCommEvent( hCommFile, dwEventMask, lpOverlappedCommEvent ) then
	begin
		// This could happen if there was an error waiting on the
		// comm port.  Lets try and handle it.

		LogDebugInfo( 'Event (Error) waiting before WaitCommEvent.' );

		if not HandleCommEvent( nil, dwEventMask, False ) then
		{??? GetOverlappedResult does not handle "NIL" as defined by Borland}
			Exit;

		// What could cause infinite recursion at this point?
		goto StartSetupCommEvent;
	end;

	// We expect ERROR_IO_PENDING returned from WaitCommEvent
	// because we are waiting with an overlapped structure.

	dwLastError := GetLastError;

	// LastError was ERROR_IO_PENDING, as expected.
	if dwLastError = ERROR_IO_PENDING then
	begin
		LogDebugInfo( 'Waiting for a CommEvent (Error) to occur.' );
		Result := True;
		Exit
	end;

	// Its possible for this error to occur if the
	// service provider has closed the port.  Time to end.
	if dwLastError = ERROR_INVALID_HANDLE then
	begin
		LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
				'Likely that the Service Provider has closed the port.' );
		Exit;
	end;

	// Unexpected error. No idea what could cause this to happen.
	LogDebugLastError( dwLastError, 'Unexpected WaitCommEvent error: ' );
end; {TReadThread.SetupCommEvent}

//
//  FUNCTION: HandleCommEvent(LPOVERLAPPED, LPDWORD, BOOL)
//
//  PURPOSE: Handle an outstanding Comm Event.
//
//  PARAMETERS:
//    lpOverlappedCommEvent - Pointer to the overlapped structure to use.
//    dwEventMask          - Pointer to DWORD to received Event data.
//     fRetrieveEvent       - Flag to signal if the event needs to be
//                            retrieved, or has already been retrieved.
//
//  RETURN VALUE:
//    TRUE if able to handle a Comm Event.
//    FALSE if unable to setup WaitCommEvent, unable to handle
//    an existing outstanding event or if the CloseEvent has been signaled.
//
//  COMMENTS:
//
//    This function is a helper function for the Read Thread that (if
//    fRetrieveEvent == TRUE) retrieves an outstanding CommEvent and
//    deals with it.  The only event that should occur is an EV_ERR event,
//    signalling that there has been an error on the comm port.
//
//    Normally, comm errors would not be put into the normal data stream
//    as this sample is demonstrating.  Putting it in a status bar would
//    be more appropriate for a real application.
//
//
function TReadThread.HandleCommEvent( lpOverlappedCommEvent: POverlapped;
	 var dwEventMask: DWORD; fRetrieveEvent: Boolean ): Boolean;
var
	dwDummy:			DWORD;
	lpszOutput:		PChar;
	szError:			array[0..127] of Char;
	dwErrors,
	nOutput,
	dwLastError:	DWORD;
begin
	Result := False;

	szError[0] := #0;

	lpszOutput := PChar(LocalAlloc( LPTR, 256 ));
	if lpszOutput = nil{NULL} then
	begin
		LogDebugLastError( GetLastError, 'LocalAlloc: ' );
		Exit;
	end;

	// If this fails, it could be because the file was closed (and I/O is
	// finished) or because the overlapped I/O is still in progress.  In
	// either case (or any others) its a bug and return FALSE.
	if fRetrieveEvent then
		if not GetOverlappedResult( hCommFile,
					 lpOverlappedCommEvent^, dwDummy, False ) then
		begin
			dwLastError := GetLastError;

			// Its possible for this error to occur if the
			// service provider has closed the port.  Time to end.
			if dwLastError = ERROR_INVALID_HANDLE then
			begin
				LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
						  'Likely that the Service Provider has closed the port.' );
				Exit;
			end;

			LogDebugLastError( dwLastError,
					 'Unexpected GetOverlappedResult for WaitCommEvent: ' );
			Exit;
		end;

	// Was the event an error?
	if (dwEventMask and EV_ERR) <> 0 then
	begin
		// Which error was it?
		if not ClearCommError( hCommFile, dwErrors, nil ) then
		begin
			dwLastError := GetLastError;

			// Its possible for this error to occur if the
			// service provider has closed the port.  Time to end.
			if dwLastError = ERROR_INVALID_HANDLE then
			begin
				LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
					  'Likely that the Service Provider has closed the port.' );
				Exit;
			end;

			LogDebugLastError( GetLastError,'ClearCommError: ' );
			Exit;
		end;

		// Its possible that multiple errors occured and were handled
		// in the last ClearCommError.  Because all errors were signaled
		// individually, but cleared all at once, pending comm events
		// can yield EV_ERR while dwErrors equals 0.  Ignore this event.
		if dwErrors = 0 then
			strcat( szError, 'NULL Error' );

		if (dwErrors and CE_FRAME) <> 0 then
		begin
			if szError[0] <> #0 then
				strcat( szError, ' and ' );

			strcat( szError,'CE_FRAME' );
		end;

		if (dwErrors and CE_OVERRUN) <> 0 then
		begin
			if szError[0] <> #0 then
				strcat(szError, ' and ' );

			strcat( szError, 'CE_OVERRUN' );
		end;

		if (dwErrors and CE_RXPARITY) <> 0 then
		begin
			if szError[0] <> #0 then
				strcat( szError, ' and ' );

			strcat( szError, 'CE_RXPARITY' );
		end;

		if (dwErrors and not (CE_FRAME + CE_OVERRUN + CE_RXPARITY)) <> 0 then
		begin
			if szError[0] <> #0 then
				strcat( szError, ' and ' );

			strcat( szError, 'EV_ERR Unknown EvtMask' );
		end;

		nOutput := wsprintf(lpszOutput,
				PChar('Comm Event: '+szError+', EvtMask = '+IntToStr(dwErrors)) );

		ReceiveData( lpszOutput, nOutput ); {%DPW CHANGE THIS}
		Result := True;
		Exit
	end;

	// Should not have gotten here.  Only interested in ERR conditions.

	LogDebugInfo( PChar('Unexpected comm event '+IntToStr(dwEventMask)) );
end; {TReadThread.HandleCommEvent}

function TReadThread.ReceiveData( lpNewString: PChar; dwSizeofNewString: DWORD ): BOOL;
begin
	Result := PostMessage( hComm32Window, PWM_GOTCOMMDATA,
			WPARAM(dwSizeofNewString), LPARAM(lpNewString) );
end;

procedure TReadThread.PostHangupCall;
begin
	PostMessage( hComm32Window, PWM_REQUESTHANGUP, 0, 0 );
end;

(******************************************************************************)
//											WRITE THREAD
(******************************************************************************)

//
//  PROCEDURE: TWriteThread.Execute
//
//  PURPOSE: The starting point for the Write thread.
//
//  PARAMETERS:
//    lpvParam - unused.
//
//  RETURN VALUE:
//    DWORD - unused.
//
//  COMMENTS:
//
//    The Write thread uses a PeekMessage loop to wait for a string to write,
//    and when it gets one, it writes it to the Comm port.  If the CloseEvent
//    object is signaled, then it exits.  The use of messages to tell the
//    Write thread what to write provides a natural desynchronization between
//    the UI and the Write thread.
//
//
procedure TWriteThread.Execute;
var
	 msg:	TMsg;
	 dwHandleSignaled:	DWORD;
	 overlappedWrite:		TOverLapped;
label
	EndWriteThread;
begin

	// Needed for overlapped I/O.
	FillChar( overlappedWrite, SizeOf(overlappedWrite), 0 );  {0, 0, 0, 0, NULL}

	overlappedWrite.hEvent := CreateEvent( nil, True, True, nil );
	if overlappedWrite.hEvent = 0 then
	begin
		LogDebugLastError( GetLastError, 'Unable to CreateEvent: ' );
		PostHangupCall;
		goto EndWriteThread;
	end;

	// Everything ready - tell main thread
	PostMessage( hComm32Window, PWM_THREADREADY, 1, 0 );

	// This is the main loop.  Loop until we break out.
	while True do
	begin
		if not PeekMessage( msg, 0, 0, 0, PM_REMOVE ) then
		begin
			// If there are no messages pending, wait for a message or
			// the CloseEvent.
			dwHandleSignaled :=
				 MsgWaitForMultipleObjects(1, hCloseEvent, False,
						INFINITE, QS_ALLINPUT);

			case dwHandleSignaled of
				 WAIT_OBJECT_0:     // CloseEvent signaled!
				 begin
						// Time to exit.
						goto EndWriteThread;
				 end;

				 WAIT_OBJECT_0 + 1: // New message was received.
				 begin
						// Get the message that woke us up by looping again.
						continue;
				 end;

				 WAIT_FAILED:       // Wait failed.  Shouldn't happen.
				 begin
						LogDebugLastError( GetLastError, 'Write WAIT_FAILED: ' );
						PostHangupCall;
						goto EndWriteThread;
				 end;

				 else                // This case should never occur.
				 begin
						LogDebugInfo( PChar('Unexpected Wait return value '
													+IntToStr(dwHandleSignaled)) );
						PostHangupCall;
						goto EndWriteThread;
				 end;
			end;
		end;

		// Make sure the CloseEvent isn't signaled while retrieving messages.
		if WAIT_TIMEOUT <> WaitForSingleObject(hCloseEvent,0) then
			goto EndWriteThread;

		// Process the message.

		// This could happen if a dialog is created on this thread.
		// This doesn't occur in this sample, but might if modified.
		if msg.hwnd <> 0{NULL} then
		begin
			TranslateMessage(msg);
			DispatchMessage(msg);

			continue;
		end;

		// Handle the message.
		case msg.message of
			PWM_COMMWRITE:  // New string to write to Comm port.
			begin
				 LogDebugInfo( 'Writing to comm port' );

				 // Write the string to the comm port.  HandleWriteData
				 // does not return until the whole string has been written,
				 // an error occurs or until the CloseEvent is signaled.
				 if not HandleWriteData( @overlappedWrite,
							PChar(msg.lParam), DWORD(msg.wParam) ) then
				 begin
						// If it failed, either we got a signal to end or there
						// really was a failure.

						LocalFree( HLOCAL(msg.lParam) );
						goto EndWriteThread;
				 end;

				 // Data was sent in a LocalAlloc()d buffer.  Must free it.
				 LocalFree( HLOCAL(msg.lParam) );
			end;

			// What other messages could the thread get?
			else
			begin
				 LogDebugInfo( PChar('Unexpected message posted to Write thread: '+
						IntToStr(msg.message)) );
				 {break;}
			end;
		end; {case}
	end; {main loop}

	 // Thats the end.  Now clean up.
	EndWriteThread:

	 LogDebugInfo( 'Write thread shutting down' );

	 PurgeComm(hCommFile, PURGE_TXABORT + PURGE_TXCLEAR);

	 CloseHandle(overlappedWrite.hEvent);
end; {TWriteThread.Execute}


//
//  FUNCTION: HandleWriteData(LPOVERLAPPED, LPCSTR, DWORD)
//
//  PURPOSE: Writes a given string to the comm file handle.
//
//  PARAMETERS:
//    lpOverlappedWrite      - Overlapped structure to use in WriteFile
//    pDataToWrite      - String to write.
//    dwNumberOfBytesToWrite - Length of String to write.
//
//  RETURN VALUE:
//    TRUE if all bytes were written.  False if there was a failure to
//    write the whole string.
//
//  COMMENTS:
//
//    This function is a helper function for the Write Thread.  It
//    is this call that actually writes a string to the comm file.
//    Note that this call blocks and waits for the Write to complete
//    or for the CloseEvent object to signal that the thread should end.
//    Another possible reason for returning FALSE is if the comm port
//    is closed by the service provider.
//
//
function TWriteThread.HandleWriteData( lpOverlappedWrite: POverlapped;
	 pDataToWrite: PChar; dwNumberOfBytesToWrite: DWORD): Boolean;
var
	dwLastError,

	dwNumberOfBytesWritten,
	dwWhereToStartWriting,

	dwHandleSignaled:	DWORD;
	HandlesToWaitFor: array[0..1] of THandle;
begin
	dwNumberOfBytesWritten := 0;
	dwWhereToStartWriting := 0; // Start at the beginning.

	HandlesToWaitFor[0] := hCloseEvent;
	HandlesToWaitFor[1] := lpOverlappedWrite^.hEvent;

	 // Keep looping until all characters have been written.
	 repeat
		  // Start the overlapped I/O.
		  if not WriteFile(hCommFile,
					 pDataToWrite[ dwWhereToStartWriting ],
					 dwNumberOfBytesToWrite, dwNumberOfBytesWritten,
					 lpOverlappedWrite) then
		  begin
				// WriteFile failed.  Expected; lets handle it.
				dwLastError := GetLastError;

				// Its possible for this error to occur if the
				// service provider has closed the port.  Time to end.
				if (dwLastError = ERROR_INVALID_HANDLE) then
				begin
					 LogDebugInfo( 'ERROR_INVALID_HANDLE, '+
						  'Likely that the Service Provider has closed the port.' );
					 Result := False;
					 Exit;
				end;

				// Unexpected error.  No idea what.
				if dwLastError <> ERROR_IO_PENDING then
				begin
					 LogDebugLastError( dwLastError, 'Error to writing to CommFile' );

					 LogDebugInfo( 'Closing TAPI' );
					 PostHangupCall;
					 Result := False;
					 Exit;
				end;

				// This is the expected ERROR_IO_PENDING case.


				// Wait for either overlapped I/O completion,
				// or for the CloseEvent to get signaled.
				dwHandleSignaled :=
					 WaitForMultipleObjects(2, @HandlesToWaitFor,
						  False, INFINITE);

				case dwHandleSignaled of
					 WAIT_OBJECT_0:     // CloseEvent signaled!
					 begin
						  // Time to exit.
						  Result := False;
						  Exit;
					 end;

					 WAIT_OBJECT_0 + 1: // Wait finished.
					 begin
						  // Time to get the results of the WriteFile
					 end;

					 WAIT_FAILED: // Wait failed.  Shouldn't happen.
					 begin
						  LogDebugLastError( GetLastError, 'Write WAIT_FAILED: ' );
						  PostHangupCall;
						  Result := False;
						  Exit
					 end;

					 else // This case should never occur.
					 begin
						  LogDebugInfo( PChar('Unexpected Wait return value '+
													IntToStr(dwHandleSignaled)) );
						  PostHangupCall;
						  Result := False;
						  Exit
					 end;
				end; {case}

				if not GetOverlappedResult(hCommFile,
							lpOverlappedWrite^,
							dwNumberOfBytesWritten, TRUE) then
				begin
					 dwLastError := GetLastError();

					 // Its possible for this error to occur if the
					 // service provider has closed the port.
					 if dwLastError = ERROR_INVALID_HANDLE then
					 begin
						  LogDebugInfo('ERROR_INVALID_HANDLE, '+
								'Likely that the Service Provider has closed the port.');
						  Result := False;
						  Exit;
					 end;

					 // No idea what could cause another error.
					 LogDebugLastError( dwLastError, 'Error writing to CommFile while waiting');
					 LogDebugInfo('Closing TAPI');
					 PostHangupCall;
					 Result := False;
					 Exit;
				end;
		  end; {WriteFile failure}

		  // Some data was written.  Make sure it all got written.

		  Dec( dwNumberOfBytesToWrite, dwNumberOfBytesWritten );
		  Inc( dwWhereToStartWriting, dwNumberOfBytesWritten );
	 until (dwNumberOfBytesToWrite <= 0);  // Write the whole thing!

	 // Wrote the whole string.
	 Result := True;
end; {TWriteThread.HandleWriteData}

function TWriteThread.WriteComm( pDataToWrite: LPCSTR; dwSizeofDataToWrite: DWORD ): Boolean;
begin
	Result := PostThreadMessage( ThreadID, PWM_COMMWRITE,
					 WParam(dwSizeofDataToWrite), LParam(pDataToWrite) );
end;

procedure TWriteThread.PostHangupCall;
begin
	PostMessage( hComm32Window, PWM_REQUESTHANGUP, 0, 0 );
end;

(******************************************************************************)
//											DEBUG ROUTINES
(******************************************************************************)

//
//  FUNCTION: LogDebugLastError(..)
//
//  PURPOSE: Pretty print a line error to the debugging output.
//
//  PARAMETERS:
//    dwLastError - Actual error code to decipher.
//    pszPrefix   - String to prepend to the printed message.
//
//  RETURN VALUE:
//    none
//
//  COMMENTS:
//
//    Note that there is an internal string length limit of
//    MAXOUTPUTSTRINGLENGTH.  If this length is exceeded,
//    the behavior will be the same as wsprintf, although
//    it will be undetectable.  *KEEP szPrefix SHORT!*
//
//
procedure LogDebugLastError( dwLastError: DWORD; szPrefix: PChar );
var
	szLastError: PChar;
	szOutputLastError: array[0..MAXOUTPUTSTRINGLENGTH-1] of Char;
begin
	if szPrefix = nil then
		szPrefix := '';

	// Pretty print the error.
	szLastError := szFormatLastError(dwLastError, nil, 0);

	// The only reason FormatLastError should fail is "Out of memory".
	if szLastError = nil then
	begin
		wsprintf( szOutputLastError, PChar(szPrefix+'Out of memory') );

		LogDebugInfo( szOutputLastError );

		Exit;
	end;

	wsprintf( szOutputLastError,
			  PChar(szPrefix+'GetLastError returned: "'+szLastError+'"') );

	// Pointer returned from FormatLineError *must* be freed!
	LocalFree( HLOCAL(szLastError) );

	// Print it!
	LogDebugInfo( szOutputLastError );
end; {LogDebugLastError}

procedure LogDebugInfo( outstr: PChar );
begin
	if CommsLogName <> '' then
		Writeln( CommsLogFile, outstr );
end; {LogDebugInfo}

procedure Register;
begin
  RegisterComponents('SigNET', [TComm32]);
end;

end.
