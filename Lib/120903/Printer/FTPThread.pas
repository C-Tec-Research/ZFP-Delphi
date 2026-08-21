unit FTPThread;

interface

uses
  SysUtils, Classes, WinINet;

type
   TFTPMode = (ftpSend, ftpGet);
   TStatusProc = procedure(Sender: TObject; const StatMsg: string) of object;

   TFTPThread = class(TThread)
   protected
      NumBytes    : integer;
      ModeStr     : string;
      TmpStat     : string;
      procedure   Execute; override;
      procedure   DoFTP;
      procedure   SendStat(const StatMsg: string);
      procedure   CallStatProc;
   public
      LocalFile   : string;
      RemoteFile  : string;
      Host        : string;
      UserName    : string;
      Password    : string;
      FTPMode     : TFTPMode;
      FTPFlag     : integer;        // FTP_TRANSFER_TYPE_UNKNOWN is default
      UseConn     : HINTERNET;      // Use an existing connection (in which case Host, UserName, etc are not needed)
      StatProc    : TStatusProc;    // This is called inside of "Synchronize"
      ErrMsg      : string;
   end;


implementation

uses Windows, INetUtil;

// ***************************************************************************
// TWorkThread

procedure TFTPThread.SendStat(const StatMsg: string);
begin
   TmpStat := StatMsg;
   Synchronize(CallStatProc);
end;

procedure TFTPThread.CallStatProc;
begin
   if Assigned(StatProc) then
      StatProc(Self, TmpStat);
end;

procedure FTP_Status(hi: HINTERNET; Context: integer; Status: integer;
   StatusInfo: pointer; StatusInfoLen: integer); stdcall;
var
   ft : TFTPThread;
begin
   ft := TFTPThread(Context);

   case Status of
      INTERNET_STATUS_REQUEST_SENT,
      INTERNET_STATUS_RESPONSE_RECEIVED: begin
         ft.NumBytes := ft.NumBytes + PINT(StatusInfo)^;
         end;
   end;

   ft.SendStat(Format('%s = %1.0n', [ft.ModeStr, 0.0 + ft.NumBytes]));
end;

procedure TFTPThread.DoFTP;
var
   hi, fi   : HINTERNET;
begin
   if UseConn <> nil then begin
      fi := UseConn;
      hi := nil;
   end else begin
      SendStat('Initializing Internet Functions');
      hi := InternetOpen('VCS FTP', INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
      INetCheck(LongBool(hi));

      SendStat('Connecting to Host');
      fi := InternetConnect(hi, PChar(Host), INTERNET_DEFAULT_FTP_PORT,
          PChar(UserName), PChar(Password), INTERNET_SERVICE_FTP, 0, 0);
      INetCheck(LongBool(fi));
   end;

   NumBytes := 0;
   if FTPMode = ftpSend then begin
      SendStat('Sending File');
      ModeStr := 'Bytes Sent';
      InternetSetStatusCallback(fi, @FTP_Status);
      INetCheck(FtpPutFile(fi, PChar(LocalFile), PChar(RemoteFile), FTPFlag, integer(Self)));
      ModeStr := 'Send Complete';
   end else begin
      SendStat('Receiving File');
      ModeStr := 'Bytes Received';
      InternetSetStatusCallback(fi, @FTP_Status);
      INetCheck(FtpGetFile(fi, PChar(RemoteFile), PChar(LocalFile), False, 0,
         FTP_TRANSFER_TYPE_BINARY, integer(Self)));
      ModeStr := 'Receive Complete';
   end;

   if UseConn = nil then begin
      InternetCloseHandle(fi);
      InternetCloseHandle(hi);
   end;

   SendStat(Format('%s  %1.0n bytes', [ModeStr, 0.0 + NumBytes]));
end;

procedure TFTPThread.Execute;
begin
   try
      DoFTP;
   except
      on e: Exception do begin
         ErrMsg := e.Message;
         SendStat(ErrMsg);
      end;
   end;
end;


end.
