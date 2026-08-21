unit WWW;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ScktComp, ExtCtrls, ISAPI, WABD_Objects, Menus, TrayIcon,
  FormSettings;

const
   WM_UPDATEICON = WM_USER + 1;

type
  TWWWForm = class(TForm)
    ServerSocket1: TServerSocket;
    TopPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    NameLab: TLabel;
    AddrLab: TLabel;
    PortLab: TLabel;
    ListenBut: TButton;
    MinimizeBut: TButton;
    TrayIcon1: TTrayIcon;
    WWWMenu: TPopupMenu;
    WWWServer1: TMenuItem;
    N1: TMenuItem;
    Shutdown1: TMenuItem;
    DisconBut: TButton;
    ListBox1: TListBox;
    WWWImage: TImage;
    WWWHitImage: TImage;
    FormSettings1: TFormSettings;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListenButClick(Sender: TObject);
    procedure ServerSocket1Listen(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormShow(Sender: TObject);
    procedure MinimizeButClick(Sender: TObject);
    procedure WWWServer1Click(Sender: TObject);
    procedure Shutdown1Click(Sender: TObject);
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure DisconButClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  protected
    SockList   : TList;
    DataList   : TStringList;
    procedure  CheckButtons;
    procedure  SetStat(const s: string);
    procedure  UpdateIcons(Hit: boolean);
    procedure  UpdateIconMsg(var Msg: TMessage); message WM_UPDATEICON;
    function   Is_Valid_HTTP_Request(const Request: string): boolean;
    procedure  Parse_HTTP_Request(const Request: string; var FileName, Hdrs, Data: string);
    function   Process_HTTP_Request(const FileName, Hdrs, Data: string): string;
    function   RunScript(const FileName, Hdrs, Data: string): string;
  public
    SesMgr     : TWABD_SessionMgr;
    property   Stat: string write SetStat;
  end;

var
  WWWForm: TWWWForm;

implementation

{$R *.DFM}

uses WinSock, WABD_ISAPI, BenTools, GenericTableSet;

const
   CR     = #13#10;

type
   TConnInfo = class
      WWWForm     : TWWWForm;
      FileName    : string;
      Hdrs        : string;
      Data        : string;
      RemoteHost  : string;
      ECB_Result  : string;
   end;


procedure TWWWForm.FormCreate(Sender: TObject);
const
   PORT = 80;
var
   wd       : TWSAdata;
   buf      : array[0..MAX_PATH] of char;
   buf2     : PChar;
   rc       : integer;
   he       : PHostEnt;
   in_addr  : PInAddr;
begin
   // Startup WinSock
   rc := WSAStartup($0101, wd);
   Assert(rc=0, 'Unable to Start WinSock');

   rc := gethostname(buf, sizeof(buf));
   Assert(rc=0, 'Unable to GetHostName');
   he := gethostbyname(buf);
   if he=nil then begin
      MessageDlg('FATAL ERROR:  Unable to GetHostByName'#13 +
      'Be sure to start Dial-Up Networking BEFORE you start the Server',
      mtError, [mbOk], 0);
      // Application.Terminate;
      exit;
   end;
   Assert(he<>nil, 'Unable to GetHostByName');
   in_addr := PInAddr(he.h_addr^);
   buf2 := inet_ntoa(in_addr^);

   NameLab.Caption := he.h_name;
   AddrLab.Caption := buf2;
   PortLab.Caption := IntToStr(PORT);

   SockList := TList.Create;
   DataList := TStringList.Create;
   CheckButtons;
end;

procedure TWWWForm.FormDestroy(Sender: TObject);
var
   rc : integer;
begin
   // Shutdown WinSock
   rc := WSACleanup;
   Assert(rc=0, 'Unable to Shutdown WinSock');

   SockList.Free;
   DataList.Free;
end;

procedure TWWWForm.ListenButClick(Sender: TObject);
begin
   with ServerSocket1 do begin
      Port := 80;
      Active := True;
   end;
   CheckButtons;
end;

procedure TWWWForm.CheckButtons;
var
   b : boolean;
begin
   b := ServerSocket1.Active;
   ListenBut.Enabled := not b;
   DisconBut.Enabled := b;
   MinimizeBut.Enabled := b;

   (Owner as TGenericTableSetForm).ButPanel.Visible := b;
end;

procedure TWWWForm.SetStat(const s: string);
begin
   ListBox1.ItemIndex := ListBox1.Items.Add(s);
end;

procedure TWWWForm.ServerSocket1Listen(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Stat := Format('%-6s  %-15s  %s', ['Start', Socket.LocalHost, FormatDateTime('ddd, d-mmm-yy  hh:nn:ss ampm', Now)]);
end;


procedure TWWWForm.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   {Stat := Format('%-20s  %-20s %-20s  Port %d',
      ['Client Hit', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]);}
end;

procedure TWWWForm.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   {Stat := Format('%-20s  %-20s %-20s  Port %d',
      ['Client Disconnected', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]);}
end;

function FmtHTMLResponse(const HTMLText: string): string;
const
   CR = #13#10;
var
   ResStr : string;
begin
   ResStr := Format(
      'HTTP/1.0 200 OK'+CR+
      'Content-Type: text/html'+CR+
      'Content-Length: %d'+CR+
      'Content:'+CR+CR, [Length(HTMLText)]) + HTMLText;
   Result := ResStr;
end;

procedure TWWWForm.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   s        : string;
   FileName : string;
   Data     : string;
   Hdrs     : string;
   i        : integer;
begin
   // TODO:  Make sure that we keep track of which socket we are adding to

   i := SockList.IndexOf(Socket);
   if i=-1 then begin
      i := SockList.Add(Socket);
      DataList.Add('');
   end;

   DataList[i] := DataList[i] + Socket.ReceiveText;

   if Is_Valid_HTTP_Request(DataList[i]) then begin
      UpdateIcons(True);

      Parse_HTTP_Request(DataList[i], FileName, Hdrs, Data);

      Stat := Format('%-6s  %-15s  %s', ['Hit', Socket.RemoteAddress, FileName + '  ' + Trim(Data)]);

      try
         s := Process_HTTP_Request(FileName, Hdrs, Data);
      except
         on E: Exception do begin
            s := '<HTML><BODY>Tracker Exception:  <P>' + e.Message + '</BODY></HTML>';
            Stat := 'ERROR: ' + e.Message;
         end;
      end;

      if Length(s) > 0 then Socket.SendText(s);
      Socket.Close;

      SockList.Delete(i);
      DataList.Delete(i);
   end else begin
      Stat := Format('%-6s  %-15s  %s', ['Partial', Socket.RemoteAddress, DataList[i]]);
      
      // This is here for debugging only - set a breakpoint on the line below
      Is_Valid_HTTP_Request(DataList[i]);
   end;
end;

procedure TWWWForm.UpdateIcons(Hit: boolean);
begin
   PostMessage(Self.Handle, WM_UPDATEICON, integer(Hit), 0);
end;

procedure TWWWForm.UpdateIconMsg(var Msg: TMessage);
var
   i     : TIcon;
   Hit   : boolean;
begin
   Hit := boolean(Msg.WParam);

   if Hit then i := WWWHitImage.Picture.Icon else i := WWWImage.Picture.Icon;
   (Owner as TGenericTableSetForm).WWWImage.Picture.Assign(i);
   TrayIcon1.Icon := i;  // You MUST use the := rather than "Assign" to update the icon on the tray
end;

function Get_Request_OpFile(const Request: string; var Op, FileName: string): boolean;
var
   p     : integer;
   tmp   : string;
begin
   // Determine what kind of HTTP Request (Get, Post, etc)
   Result := False;

   p := Pos(' ', Request);
   if p=0 then exit;
   Op := UpperCase(Copy(Request, 1, p-1));
   tmp := Copy(Request, p+1, Length(Request));

   p := Pos(' ', tmp);
   if p=0 then exit;
   FileName := Copy(tmp, 1, p-1);

   Result := True;
end;

function Get_Request_Data(const Request: string; var Data: string): boolean;
const
   CONLEN = 'CONTENT-LENGTH:';
var
   tmp   : string;
   p     : integer;
   Len   : integer;
begin
   Result := False;

   // Find the "Content-Length:" string
   tmp := UpperCase(Request);
   p := Pos(CONLEN, tmp);
   if p=0 then exit;

   // Find its numerical value
   tmp := Copy(tmp, p+Length(CONLEN), Length(tmp));
   p := Pos(CR, tmp);
   if p=0 then exit;
   tmp := Trim(Copy(tmp, 1, p-1));
   Len := StrToInt(tmp);

   // Check that Content-Length matches the data

   // The "Data" is all of the text past two CR's
   p := Pos(CR+CR, Request);
   if p=0 then exit;
   tmp := Copy(Request, p+4, Length(Request));  // +4 is to skip over CR+CR

   if Length(tmp) < Len then exit;

   Data := tmp;
   Result := True;
end;

function TWWWForm.Is_Valid_HTTP_Request(const Request: string): boolean;
var
   Op    : string;      // Operation - "Get", "Post", etc
   Data  : string;
   fn    : string;
begin
   Result := False;

   // Request should contain a CR+CR
   if Pos(CR+CR, Request)=0 then exit;

   // Request should end with a CR
   if Copy(Request, Length(Request)-1, 2)<>CR then exit;

   if not Get_Request_OpFile(Request, Op, fn) then exit;

   if Op = 'POST' then begin
      if not Get_Request_Data(Request, Data) then exit;
   end;

   Result := True;
end;

procedure TWWWForm.Parse_HTTP_Request(const Request: string; var FileName, Hdrs, Data: string);
var
   b   : boolean;
   Op  : string;
   tmp : string;
   p   : integer;
begin
   // Get the Operation
   b := Get_Request_OpFile(Request, Op, FileName);
   Assert(b);

   // Get the Headers
   p := Pos(CR, Request);
   tmp := Copy(Request, p+2, Length(Request));
   p := Pos(CR+CR, tmp);
   Hdrs := Copy(tmp, 1, p-1);

   // Get the FileName & Data
   if Op = 'POST' then begin
      b := Get_Request_Data(Request, Data);
      Assert(b);
   end else begin
      Data := '';
      p := Pos('?', FileName);
      if p<>0 then begin
         Data := Copy(FileName, p+1, Length(FileName));
         FileName := Copy(FileName, 1, p-1);
      end;
   end;
end;

// DummyResult - function was used during debugging
function DummyResult(const FileName, Hdrs, Data: string): string;
var
   s, ct : string;
begin
   ct := 'Current Time = ' + FormatDateTime('dddd, d-mmm-yy  hh:nn:ss ampm', Now);

   s := '<HTML><BODY>Received the following HTTP Request:<P>' +
      '<PRE>FileName: ' + FileName + '<P><P>' +
      'Headers: <P>' + Hdrs + '<P><P>' +
      'Data: <P>' + Data + '<P><P>' +
      '</PRE>(End of Request)<P>' + ct + '</BODY></HTML>';
   s := FmtHTMLResponse(s);

   Result := s;
end;

function SendFile(const FileName, ContentType: string): string;
var
   fs  : TFileStream;
   Len : integer;
   buf : string;
   ct  : string;
begin
   if not FileExists(FileName) then begin
      buf := '<HTML><BODY>File Not Found: ' + FileName + '</BODY></HTML>';
      Result := Format('HTTP/1.0 200 OK' + CR +
        'Content-Type: text/html' + CR +
         'Content-Length: %d' + CR +
         'Content:' + CR + CR, [Length(buf)]) + buf;
      exit;
   end;

   fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
   Len := fs.Size;
   SetLength(buf, Len);
   fs.Read(buf[1], Len);
   fs.Free;

   ct := '';
   if ContentType<>'' then ct := 'Content-Type: ' + ContentType + CR;

   // Send the Header
   Result := Format(
      'HTTP/1.0 200 OK' + CR +
      ct +
      'Content-Length: %d' + CR +
      'Content:' + CR + CR, [Len]) + buf;
end;


// ************************************************************************
// "ISAPI" functions

function GetServerVariable(hConn: HCONN; VariableName: PChar; Buffer: Pointer;
   var Size: DWORD ): BOOL stdcall;
var
   ci : TConnInfo;
begin
   ci := TConnInfo(hConn);
   Result := False;

   if UpperCase(VariableName) = 'SCRIPT_NAME' then begin
      StrPCopy(PChar(Buffer), ExtractFileName(ci.FileName));
      Size := Length(ci.FileName);
      Result := True;
   end;

   if (UpperCase(VariableName) = 'REMOTE_HOST') or
      (UpperCase(VariableName) = 'REMOTE_ADDR') then begin
      StrPCopy(PChar(Buffer), ci.RemoteHost);
      Size := Length(ci.RemoteHost);
      Result := True;
   end;
end;

function WriteClient(ConnID: HCONN; Buffer: Pointer; var Bytes: DWORD;
   dwReserved: DWORD ): BOOL stdcall;
var
   ci : TConnInfo;
begin
   ci := TConnInfo(ConnID);
   ci.ECB_Result := ci.ECB_Result + PChar(Buffer);
   Result := True;
end;

function ReadClient(ConnID: HCONN; Buffer: Pointer; var Size: DWORD): BOOL stdcall;
begin
   Result := False;
end;

function ServerSupport(hConn: HCONN; HSERRequest: DWORD; Buffer: Pointer;
   var Size: DWORD; var DataType: DWORD ): BOOL stdcall;
const
   RESPHDR : pchar = 'HTTP/1.0 200 OK'+CR;
var
   Len : DWORD;
begin
   Result := False;
   if HSERRequest = HSE_REQ_SEND_RESPONSE_HEADER then begin
      Result := True;
      Len := Length(RESPHDR);
      WriteClient(hConn, RESPHDR, Len, 0);
   end;
end;


// ************************************************************************
// RunScript

function TWWWForm.RunScript(const FileName, Hdrs, Data: string): string;
var
   ecb : TEXTENSION_CONTROL_BLOCK;
   ci  : TConnInfo;
begin
   ci := TConnInfo.Create;
   ci.FileName := FileName;
   ci.Hdrs     := Hdrs;
   ci.Data     := Data;

   FillChar(ecb, sizeof(ecb), 0);
   ecb.cbSize              := sizeof(ecb);
   ecb.dwVersion           := HSE_VERSION_MAJOR shl 16 + HSE_VERSION_MINOR;
   ecb.ConnID              := THandle(ci);
   ecb.dwHttpStatusCode    := 200;
   ecb.lpszMethod          := 'POST';
   ecb.lpszQueryString     := PChar(Data);
   ecb.lpszPathInfo        := PChar(FileName);
   ecb.lpszPathTranslated  := PChar(FileName);
   ecb.cbTotalBytes        := 0;

   ecb.GetServerVariable   := GetServerVariable;
   ecb.WriteClient         := WriteClient;
   ecb.ReadClient          := ReadClient;
   ecb.ServerSupportFunction  := ServerSupport;

   if SesMgr=nil then begin
      SesMgr := (Owner as TGenericTableSetForm).Create_WABD_SesMgr;
   end;

   SetRunLocal(False);
   Assert(SesMgr<>nil);
   Result := SesMgr.OnFormSubmit(ecb);

   Result := Format(
      'HTTP/1.0 200 OK'+CR+
      // 'Expires: ' + FormatDateTime('ddd, dd mmm yyyy hh:nn:ss EST', Now + TENMINUTES) + CR +
      'Content-Type: text/html'+CR+
      'Content-Length: %d'+CR+
      'Content:'+CR+CR, [Length(Result)]) + Result;

   ci.Free;
end;

function TWWWForm.Process_HTTP_Request(const FileName, Hdrs, Data: string): string;
var
   ext : string;
   fn  : string;
begin
   // Convert the FileName to this directory
   fn := FileName;
   FindReplace(fn, '/', '\');
   if Copy(fn, Length(fn), 1)='\' then fn := Copy(fn, 1, Length(fn)-1);

   if fn='' then fn := 'default.htm';
   if fn='data' then fn := 'data.scp';
   
   fn := ExtractFilePath(Application.ExeName) + fn;
   ext := UpperCase(ExtractFileExt(fn));

   if ext='.SCP' then begin
      Result := RunScript(fn, Hdrs, Data);
      exit;
   end;

   if (ext='.HTM') or (ext='.HTML') then begin
      Result := SendFile(fn, 'text/html');
      exit;
   end;

   if (ext='.JPG') or (ext='.JPEG') then begin
      Result := SendFile(fn, 'image/jpeg');
      exit;
   end;

   if (ext='.GIF') then begin
      Result := SendFile(fn, 'image/gif');
      exit;
   end;

   if (ext='.BMP') then begin
      Result := SendFile(fn, 'image/bmp');
      exit;
   end;

   // For security reasons, I am turning this off
   // Don't want them to be able to get just any file they want
   // Result := SendFile(fn, '');

   Result := '<HTML><BODY>Unknown File Type: ' + fn + '</BODY></HTML>';
end;

procedure TWWWForm.FormShow(Sender: TObject);
begin
   UpdateIcons(False);
end;

procedure TWWWForm.MinimizeButClick(Sender: TObject);
begin
   Application.Minimize;
   TrayIcon1.Active := True;
   TrayIcon1.ToolTip := Application.Title + ' - WWW Server';
   ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TWWWForm.WWWServer1Click(Sender: TObject);
begin
   ShowWindow(Application.Handle, SW_SHOW);
   Application.Restore;
   SetForegroundWindow(Handle);
   FormShow(Self);
   TrayIcon1.Active := False;
end;

procedure TWWWForm.Shutdown1Click(Sender: TObject);
begin
   WWWServer1Click(nil);
   ServerSocket1.Active := False;
   Application.MainForm.Close;
end;

procedure TWWWForm.ServerSocket1ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   Stat := Format('%-6s  %-15d  %s', ['Error', ErrorCode, SysErrorMessage(ErrorCode)]);
   ErrorCode := 0;
end;

procedure TWWWForm.DisconButClick(Sender: TObject);
begin
   ServerSocket1.Active := False;
   CheckButtons;
   Stat := Format('%-6s  %-15s  %s', ['Stop', '', FormatDateTime('ddd, d-mmm-yy  hh:nn:ss ampm', Now)]);
end;

procedure TWWWForm.FormDeactivate(Sender: TObject);
begin
   Hide;
end;

end.
