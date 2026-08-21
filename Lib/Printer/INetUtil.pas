unit INetUtil;

interface

uses SysUtils, Classes, Windows, WinINet;

type
   TOnReadEvent = procedure(Sender: TObject; NumRead: integer) of object;

   INetHelper = class(TComponent)
   protected
      FURL        : string;
      FOnRead     : TOnReadEvent;
      FTimeOut    : integer;
   public
      Data        : TMemoryStream;
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      procedure   GetURL;
      function    HTML: string;
   published
      property    URL: string read FURL write FURL;
      property    OnRead: TOnReadEvent read FOnRead write FOnRead;
      property    TimeOut: integer read FTimeOut write FTimeOut;
   end;

   procedure INetCheck(b: LongBool);
   function  URL_To_MemStream(const URL: string; OnRead: TOnReadEvent = nil; TimeOutMS: DWORD = 0): TMemoryStream;
   procedure FTP_Put(const DestServer, UserName, UserPass, DestDir, FileName, RemoteName: string);


implementation

uses Forms, Controls;

function URL_To_MemStream(const URL: string; OnRead: TOnReadEvent = nil; TimeOutMS: DWORD = 0): TMemoryStream;
const
   CR = #13#10;
var
   hi, ui   : HINTERNET;
   buf      : array[1..8192] of char;
   rc       : boolean;
   NumRead  : DWORD;
   ms       : TMemoryStream;
   hdrs     : string;
begin
   hi := InternetOpen('DSA Web Forms', INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
   INetCheck(LongBool(hi));

   if TimeOutMS > 0 then begin
      INetCheck(InternetSetOption(hi, INTERNET_OPTION_RECEIVE_TIMEOUT, @TimeOutMS, sizeof(TimeOutMS)));
      INetCheck(InternetSetOption(hi, INTERNET_OPTION_SEND_TIMEOUT, @TimeOutMS, sizeof(TimeOutMS)));
   end;

   hdrs := 'Accept: */*';

   ui := InternetOpenURL(hi, PChar(URL), PChar(hdrs), DWORD(-1), 0 {INTERNET_FLAG_RAW_DATA}, 0);
   INetCheck(LongBool(ui));

   ms := TMemoryStream.Create;
   try
      repeat
         rc := InternetReadFile(ui, @buf, sizeof(buf), NumRead);
         INetCheck(rc);
         ms.Write(buf, NumRead);
         if Assigned(OnRead) then
            OnRead(nil, NumRead);
      until (not rc) or (NumRead = 0);
      ms.Position := 0;

      InternetCloseHandle(ui);
      InternetCloseHandle(hi);

      Result := ms;
   except
      ms.Free;
      raise;
   end;
end;


procedure INetCheck(b: LongBool);
var
   ErrNum   : integer;
   TmpErr   : DWORD;
   Len      : DWORD;
   Buf      : array[0..4096] of char;
   s        : string;
begin
   if not b then begin
      ErrNum := GetLastError;
      case ErrNum of
         ERROR_INTERNET_EXTENDED_ERROR : begin
            Len := sizeof(Buf);
            InternetGetLastResponseInfo(TmpErr, Buf, Len);
            Buf[Len] := #0;
            s := Format('Win32 Error %d:'#13#10#13#10'%s', [ErrNum, Buf]);
            end;

         { Internet API error returns }
         ERROR_INTERNET_TIMEOUT                      : s := 'INTERNET_TIMEOUT ';
         ERROR_INTERNET_INTERNAL_ERROR               : s := 'INTERNET_INTERNAL_ERROR';
         ERROR_INTERNET_INVALID_URL                  : s := 'INTERNET_INVALID_URL ';
         ERROR_INTERNET_UNRECOGNIZED_SCHEME          : s := 'INTERNET_UNRECOGNIZED_SCHEME ';
         ERROR_INTERNET_NAME_NOT_RESOLVED            : s := 'INTERNET_NAME_NOT_RESOLVED ';
         ERROR_INTERNET_PROTOCOL_NOT_FOUND           : s := 'INTERNET_PROTOCOL_NOT_FOUND';
         ERROR_INTERNET_INVALID_OPTION               : s := 'INTERNET_INVALID_OPTION';
         ERROR_INTERNET_BAD_OPTION_LENGTH            : s := 'INTERNET_BAD_OPTION_LENGTH ';
         ERROR_INTERNET_OPTION_NOT_SETTABLE          : s := 'INTERNET_OPTION_NOT_SETTABLE ';
         ERROR_INTERNET_SHUTDOWN                     : s := 'INTERNET_SHUTDOWN';
         ERROR_INTERNET_INCORRECT_USER_NAME          : s := 'INTERNET_INCORRECT_USER_NAME ';
         ERROR_INTERNET_INCORRECT_PASSWORD           : s := 'INTERNET_INCORRECT_PASSWORD';
         ERROR_INTERNET_LOGIN_FAILURE                : s := 'INTERNET_LOGIN_FAILURE ';
         ERROR_INTERNET_INVALID_OPERATION            : s := 'INTERNET_INVALID_OPERATION ';
         ERROR_INTERNET_OPERATION_CANCELLED          : s := 'INTERNET_OPERATION_CANCELLED ';
         ERROR_INTERNET_INCORRECT_HANDLE_TYPE        : s := 'INTERNET_INCORRECT_HANDLE_TYPE ';
         ERROR_INTERNET_INCORRECT_HANDLE_STATE       : s := 'INTERNET_INCORRECT_HANDLE_STATE';
         ERROR_INTERNET_NOT_PROXY_REQUEST            : s := 'INTERNET_NOT_PROXY_REQUEST ';
         ERROR_INTERNET_REGISTRY_VALUE_NOT_FOUND     : s := 'INTERNET_REGISTRY_VALUE_NOT_FOUND';
         ERROR_INTERNET_BAD_REGISTRY_PARAMETER       : s := 'INTERNET_BAD_REGISTRY_PARAMETER';
         ERROR_INTERNET_NO_DIRECT_ACCESS             : s := 'INTERNET_NO_DIRECT_ACCESS';
         ERROR_INTERNET_NO_CONTEXT                   : s := 'INTERNET_NO_CONTEXT';
         ERROR_INTERNET_NO_CALLBACK                  : s := 'INTERNET_NO_CALLBACK ';
         ERROR_INTERNET_REQUEST_PENDING              : s := 'INTERNET_REQUEST_PENDING ';
         ERROR_INTERNET_INCORRECT_FORMAT             : s := 'INTERNET_INCORRECT_FORMAT';
         ERROR_INTERNET_ITEM_NOT_FOUND               : s := 'INTERNET_ITEM_NOT_FOUND';
         ERROR_INTERNET_CANNOT_CONNECT               : s := 'INTERNET_CANNOT_CONNECT';
         ERROR_INTERNET_CONNECTION_ABORTED           : s := 'INTERNET_CONNECTION_ABORTED';
         ERROR_INTERNET_CONNECTION_RESET             : s := 'INTERNET_CONNECTION_RESET';
         ERROR_INTERNET_FORCE_RETRY                  : s := 'INTERNET_FORCE_RETRY ';
         ERROR_INTERNET_INVALID_PROXY_REQUEST        : s := 'INTERNET_INVALID_PROXY_REQUEST ';

         ERROR_INTERNET_HANDLE_EXISTS                : s := 'INTERNET_HANDLE_EXISTS ';
         ERROR_INTERNET_SEC_CERT_DATE_INVALID        : s := 'INTERNET_SEC_CERT_DATE_INVALID ';
         ERROR_INTERNET_SEC_CERT_CN_INVALID          : s := 'INTERNET_SEC_CERT_CN_INVALID ';
         ERROR_INTERNET_HTTP_TO_HTTPS_ON_REDIR       : s := 'INTERNET_HTTP_TO_HTTPS_ON_REDIR';
         ERROR_INTERNET_HTTPS_TO_HTTP_ON_REDIR       : s := 'INTERNET_HTTPS_TO_HTTP_ON_REDIR';
         ERROR_INTERNET_MIXED_SECURITY               : s := 'INTERNET_MIXED_SECURITY';
         ERROR_INTERNET_CHG_POST_IS_NON_SECURE       : s := 'INTERNET_CHG_POST_IS_NON_SECURE';
         ERROR_INTERNET_POST_IS_NON_SECURE           : s := 'INTERNET_POST_IS_NON_SECURE';

         { FTP API errors }
         ERROR_FTP_TRANSFER_IN_PROGRESS              : s := 'FTP_TRANSFER_IN_PROGRESS ';
         ERROR_FTP_DROPPED                           : s := 'FTP_DROPPED    ';

         { gopher API errors }
         ERROR_GOPHER_PROTOCOL_ERROR                 : s := 'GOPHER_PROTOCOL_ERROR';
         ERROR_GOPHER_NOT_FILE                       : s := 'GOPHER_NOT_FILE';
         ERROR_GOPHER_DATA_ERROR                     : s := 'GOPHER_DATA_ERROR';
         ERROR_GOPHER_END_OF_DATA                    : s := 'GOPHER_END_OF_DATA ';
         ERROR_GOPHER_INVALID_LOCATOR                : s := 'GOPHER_INVALID_LOCATOR ';
         ERROR_GOPHER_INCORRECT_LOCATOR_TYPE         : s := 'GOPHER_INCORRECT_LOCATOR_TYPE';
         ERROR_GOPHER_NOT_GOPHER_PLUS                : s := 'GOPHER_NOT_GOPHER_PLUS ';
         ERROR_GOPHER_ATTRIBUTE_NOT_FOUND            : s := 'GOPHER_ATTRIBUTE_NOT_FOUND ';
         ERROR_GOPHER_UNKNOWN_LOCATOR                : s := 'GOPHER_UNKNOWN_LOCATOR ';

         { HTTP API errors }
         ERROR_HTTP_HEADER_NOT_FOUND                 : s := 'HTTP_HEADER_NOT_FOUND';
         ERROR_HTTP_DOWNLEVEL_SERVER                 : s := 'HTTP_DOWNLEVEL_SERVER';
         ERROR_HTTP_INVALID_SERVER_RESPONSE          : s := 'HTTP_INVALID_SERVER_RESPONSE ';
         ERROR_HTTP_INVALID_HEADER                   : s := 'HTTP_INVALID_HEADER';
         ERROR_HTTP_INVALID_QUERY_REQUEST            : s := 'HTTP_INVALID_QUERY_REQUEST ';
         ERROR_HTTP_HEADER_ALREADY_EXISTS            : s := 'HTTP_HEADER_ALREADY_EXISTS ';
         ERROR_HTTP_REDIRECT_FAILED                  : s := 'HTTP_REDIRECT_FAILED ';

         else RaiseLastWin32Error;
      end;

      raise Exception.Create(s);
   end;
end;

procedure FTP_Put(const DestServer, UserName, UserPass, DestDir, FileName, RemoteName: string);
var
   hi, fi   : HINTERNET;
begin
   // Stat := 'Initializing Internet Functions';
   hi := InternetOpen('Auto FTP', INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
   INetCheck(LongBool(hi));

   // Stat := 'Connecting to Host';
   fi := InternetConnect(hi, PChar(DestServer), INTERNET_DEFAULT_FTP_PORT,
       PChar(UserName), PChar(UserPass), INTERNET_SERVICE_FTP, 0, 0);
   INetCheck(LongBool(fi));

   // Stat := 'Sending File';
   // InternetSetStatusCallback(fi, @Send_Status);
   INetCheck(FtpPutFile(fi, PChar(FileName), PChar(DestDir + RemoteName), FTP_TRANSFER_TYPE_BINARY, 1));

   InternetCloseHandle(fi);
   InternetCloseHandle(hi);

   // Stat := 'Transfer Complete';
end;


constructor INetHelper.Create(AOwner: TComponent);
begin
   inherited;
   Data := TMemoryStream.Create;
end;

destructor INetHelper.Destroy;
begin
   Data.Free;
   inherited;
end;

procedure INetHelper.GetURL;
var
   ms : TMemoryStream;
begin
   ms := URL_To_MemStream(URL, OnRead, TimeOut);
   Data.LoadFromStream(ms);
   ms.Free;
   Data.Position := 0;
end;


function INetHelper.HTML: string;
var
   ss : TStringStream;
begin
   ss := TStringStream.Create('');
   ss.CopyFrom(Data, 0);
   Result := ss.DataString;
   ss.Free;
end;

end.
