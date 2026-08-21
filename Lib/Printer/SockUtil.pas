unit SockUtil;

interface

uses SysUtils, WinSock;

const
   CR = #13#10;

   // Basic Functions
   function  GetLine(Sock: TSocket): string;
   procedure PutLine(Sock: TSocket; const s: string);
   procedure PutLineNoCR(Sock: TSocket; const s: string);
   function  GetLineCR(Sock: TSocket; Echo, Password: boolean): string;

   // Server Functions
   procedure StartListenSocket(Port: integer; var LisSock: TSocket; var ServerName, ServerAddress: string);


implementation

uses Dialogs, Windows;

function GetLine(Sock: TSocket): string;
var
   buf : array[0..$10000] of char;
   rc  : integer;
begin
   Result := '';
   repeat
      rc := recv(Sock, buf, sizeof(buf)-1, 0);
      if rc=SOCKET_ERROR then raise Exception.CreateFmt('Receive WSAError = %d', [rc]);
      buf[rc] := #0;
      Result := Result + buf;
   until StrLen(buf) < sizeof(buf)-1;  // What if its exactly 1024 bytes of real data?
end;


function GetLineCR(Sock: TSocket; Echo, Password: boolean): string;
var
   tmp : string;
   i   : integer;
begin
   Result := '';
   while Pos(#13#10, Result)=0 do begin
      tmp := GetLine(Sock);
      Result := Result + tmp;
      if Password then
         for i := 1 to Length(tmp) do
            if (tmp[i]<>#13) and (tmp[i]<>#10) then tmp[i] := '*';
      if Echo then PutLineNoCR(Sock, tmp);
   end;
   Result := Trim(Result);
end;


procedure PutLineNoCR(Sock: TSocket; const s: string);
var
   rc  : integer;
   tmp : string;
begin
   tmp := s;
   rc := send(Sock, tmp[1], Length(tmp), 0);
   if rc=SOCKET_ERROR then raise Exception.CreateFmt('Send WSAError = %d', [rc]);
end;

procedure PutLine(Sock: TSocket; const s: string);
begin
   PutLineNoCR(Sock, s+#13#10);
end;


procedure StartListenSocket(Port: integer; var LisSock: TSocket; var ServerName, ServerAddress: string);
const
   CR       = #13#10;
var
   wd       : TWSAdata;
   rc       : integer;
   sa       : TSockAddr;
   buf      : array[0..MAX_PATH] of char;
   buf2     : PChar;
   in_addr  : PInAddr;
   he       : PHostEnt;
begin
   // Startup WinSock
   rc := WSAStartup($0101, wd);
   Assert(rc=0, 'Unable to Start WinSock');

   LisSock := socket(PF_INET, SOCK_STREAM, 0);

   FillChar(sa, sizeof(sa), 0);
   sa.sin_family      := AF_INET;
   sa.sin_port        := htons(PORT);
   sa.sin_addr.S_addr := INADDR_ANY;
   rc := bind(LisSock, sa, sizeof(sa));
   if rc<>0 then
      raise Exception.Create('FATAL ERROR: Unable to bind to Server Socket!'#13#10'Shutting Down!');

   rc := gethostname(buf, sizeof(buf));
   Assert(rc=0, 'Unable to GetHostName');
   he := gethostbyname(buf);
   if he=nil then
      raise Exception.Create('FATAL ERROR:  Unable to GetHostByName'#13 +
         'Be sure to start Dial-Up Networking BEFORE you start the Server');

   in_addr := PInAddr(he.h_addr^);
   buf2 := inet_ntoa(in_addr^);

   ServerName := he.h_name;
   ServerAddress := buf2;

   // Listen
   rc := listen(LisSock, 10);
   Assert(rc=0, 'Unable to Listen');
end;



end.
