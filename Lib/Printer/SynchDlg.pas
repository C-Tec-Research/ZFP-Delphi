unit SynchDlg;

{
   TODO:

   Keep stats
   Last read was 5 seconds ago (w/ timeout)
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, StdCtrls, ComCtrls, ExtCtrls, TableSet, DB, DBTables,
  FormSettings, TrayIcon, Menus, CompRecordsDlg, BenTools;

const
   COM_QUIT       = 'Quit';
   COM_TABLENAMES = 'TableNames';
   COM_SYNCHTABLE = 'SynchTable';   // Parameters: TableName
   COM_SYNCHREC   = 'SynchRecord';  // Parameters: TableName, PK, Adler-Checksum
   COM_SYNCHALL   = 'SynchAll';
   COM_ECHO       = 'Echo';
   COM_SENDRECORD = 'SendRecord';   // Parameters: TableName, PK
   COM_POSTRECORD = 'PostRecord';   // Parameters: TableName, PK

type
   TSynchType = (stMismatch, stLocalOnly, stRemoteOnly);

   TSynchRecord = class
      TableName   : string;
      PK          : string;
      SynchType   : TSynchType;
      RecData     : string;
   end;

   TSynchRecList = class(TOwnList)
   protected
      function    GetSynchRecord(i: integer): TSynchRecord;
   public
      NumMatch    : integer;
      procedure   AddSynchRec(TableName: string; PK: string; SynchType: TSynchType);
      function    FindRec(TableName: string; PK: string): TSynchRecord;
      property    SynchRecords[i: integer]: TSynchRecord read GetSynchRecord; default;
   end;

  TSynchForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ServerPanel: TPanel;
    Label1: TLabel;
    ServerPortEdit: TEdit;
    ListenBut: TButton;
    ServerSocket1: TServerSocket;
    ShutdownBut: TButton;
    ClientPanel: TPanel;
    Label2: TLabel;
    RemoteAddressEdit: TEdit;
    Label3: TLabel;
    RemotePortEdit: TEdit;
    ConnectBut: TButton;
    DisconBut: TButton;
    ClientSocket1: TClientSocket;
    SvrList: TListBox;
    ClientList: TListBox;
    FormSettings1: TFormSettings;
    SynchBut: TButton;
    MinTrayBut: TButton;
    TrayIcon1: TTrayIcon;
    TrayPopup: TPopupMenu;
    DataSynchronizationServer1: TMenuItem;
    N1: TMenuItem;
    Shutdown1: TMenuItem;
    SendBut: TButton;
    SendEdit: TEdit;
    procedure ListenButClick(Sender: TObject);
    procedure ShutdownButClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ServerSocket1Listen(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ConnectButClick(Sender: TObject);
    procedure DisconButClick(Sender: TObject);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1Accept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Connecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Lookup(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MinTrayButClick(Sender: TObject);
    procedure RestoreServerClick(Sender: TObject);
    procedure Shutdown1Click(Sender: TObject);
    procedure SendButClick(Sender: TObject);
    procedure SynchButClick(Sender: TObject);
  protected
    // Server
    NumServer  : integer;
    ServerBuf  : array[0..8192] of char;
    Con        : TCustomWinSocket;           // current Connection to client
    CurCom     : TStringList;
    procedure  ServerButs;
    procedure  ServerStat(const s: string);
    procedure  OnServerMsg(const s: string);
    procedure  Command_TableNames;
    procedure  Command_SynchAll;
    procedure  Command_SynchTable;
    procedure  Command_SendRecord;
    procedure  Command_PostRecord;
  protected
    // Client
    NumClient  : integer;
    ClientBuf  : array[0..8192] of char;
    ClientCom  : TStringList;
    ClientTabName  : string;
    ClientTab  : TTable;
    ClntChoice : TUserChoice;
    CompForm   : TCompRecordForm;
    PKList     : TStringList;
    SRecList   : TSynchRecList;
    procedure  ClientButs;
    procedure  BeginSynch;
    procedure  ClientStat(const s: string);
    procedure  OnClientMsg(const s: string);
    procedure  OnSynchTableMsg(const s: string);
    procedure  Send_Record_Request(const TableName: string; pk: string);
    procedure  Check_Missing_Records;
    procedure  Process_Record_Request(InLocal, InRemote: boolean);
    procedure  Get_User_Choice(InRemote: boolean);
    procedure  Do_Manual_Synchronization;
    // General
    function   AdlerFields(Table: TTable): integer;
    function   FindTable(TableName: string): TTable;
    function   FindTablePK(Table: TTable; pks: string): boolean;
    procedure  Record_to_StringList(Table: TTable; pk: string; sl: TStringList);
    procedure  Use_Local_Values;
    procedure  Use_Remote_Values;
  public
    TableSet   : TTableSetHelper;
  end;

   TMsgCallback = procedure(const Msg: string) of object;


var
  SynchForm: TSynchForm;

implementation

uses TableUtils, Adler, SocketErrors;

{$R *.DFM}

// ********************************************************************
// TSynchRecList

function TSynchRecList.GetSynchRecord(i: integer): TSynchRecord;
begin
   Result := Items[i];
end;

procedure TSynchRecList.AddSynchRec(TableName: string; PK: string; SynchType: TSynchType);
var
   sr : TSynchRecord;
begin
   sr := TSynchRecord.Create;
   sr.TableName := TableName;
   sr.PK        := PK;
   sr.SynchType := SynchType;
   Add(sr);
end;

function TSynchRecList.FindRec(TableName: string; PK: string): TSynchRecord;
var
   i : integer;
begin
   Result := nil;
   for i := 0 to Count-1 do
      if (SynchRecords[i].TableName = TableName) and
         (SynchRecords[i].PK = PK ) then
         Result := SynchRecords[i];
   Assert(Result<>nil, Format('Unable to Find Synch Record: %s, %s', [TableName, PK]));
end;


// ********************************************************************
// Socket Helper Functions

procedure NBSend(cw: TCustomWinSocket; const s: string);
var
   Len : integer;
   p   : pointer;
begin
   Len := Length(s);
   cw.SendBuf(Len, sizeof(Len));
   if Len > 0 then begin
      p := @s[1];
      cw.SendBuf(p^, Len);
   end;
end;


procedure ProcessRead(var BufSize: integer; Socket: TCustomWinSocket; buf: PChar;
   BufLen: integer; MsgCallback: TMsgCallback);
type
   PInteger = ^integer;
var
   NumRead  : integer;
   MsgSize  : integer;
   Msg      : string;
begin
   NumRead := Socket.ReceiveLength;
   if NumRead + BufSize >= BufLen then
      NumRead := BufLen - BufSize;

   if NumRead > 0 then
      BufSize := BufSize + Socket.ReceiveBuf(buf[BufSize], NumRead);

   while BufSize >= 4 do begin
      MsgSize := PInteger(buf)^;
      if BufSize >= MsgSize + 4 then begin
         SetLength(Msg, MsgSize);
         StrLCopy(PChar(Msg), @buf[4], MsgSize);
         Move(buf[MsgSize + 4], buf[0], BufSize - (MsgSize + 4));
         BufSize := BufSize - (MsgSize + 4);
         if Assigned(MsgCallback) then
            MsgCallback(Msg);
      end else
         break;
   end;
end;


// ********************************************************************
// TSynchForm

procedure TSynchForm.FormCreate(Sender: TObject);
begin
   NumServer := 0;
   NumClient := 0;
   CurCom    := TStringList.Create;
   ClientCom := TStringList.Create;
   PKList    := TStringList.Create;
   SRecList  := TSynchRecList.Create;
end;

procedure TSynchForm.FormDestroy(Sender: TObject);
begin
   CurCom.Free;
   ClientCom.Free;
   PKList.Free;
   SRecList.Free;
end;

procedure TSynchForm.FormShow(Sender: TObject);
begin
   ServerButs;
   ClientButs;
   PageControl1.ActivePage := TabSheet1;
end;

procedure TSynchForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
   FormSettings1.SaveSettings;
end;

procedure TSynchForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   mr : integer;
begin
   if (ServerSocket1.Socket.ActiveConnections > 0) or ClientSocket1.Active then begin
      mr := MessageDlg('Closing this dialog will disconnect all active connections.'#13#10 +
         'Are you sure you want to close?', mtWarning, mbYesNoCancel, 0);
      CanClose := mr = mrYes;
   end;
end;

procedure TSynchForm.RestoreServerClick(Sender: TObject);
begin
   ShowWindow(Application.Handle, SW_SHOW);
   Application.Restore;
   SetForegroundWindow(Handle);
   TrayIcon1.Active := False;
end;


// ********************************************************************
// General Helper functions

function TSynchForm.FindTable(TableName: string): TTable;
var
   i : integer;
   c : TComponent;
begin
   Assert(TableSet<>nil);
   Assert(TableSet.DataGroup<>nil);
   Result := nil;
   for i := 0 to TableSet.DataGroup.ComponentCount-1 do begin
      c := TableSet.DataGroup.Components[i];
      if c is TTable then
         if TTable(c).TableName = TableName then
            Result := TTable(c);
   end;
   Assert(Result<>nil, 'Unable to find Table: ' + TableName);
end;

function TSynchForm.FindTablePK(Table: TTable; pks: string): boolean;
var
   pkf : TField;
begin
   pkf := GetRequiredField(Table);
   Assert(pkf<>nil, 'Table has no Primary Key: ' + Table.TableName);
   if Table.IndexFieldNames <> pkf.FieldName then
      Table.IndexFieldNames := pkf.FieldName;
   Result := Table.FindKey([pks]);
end;

function TSynchForm.AdlerFields(Table: TTable): integer;
var
   s : string;
   i : integer;
   f : TField;
begin
   s := '';
   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if f.FieldKind = fkData then
         s := s + f.AsString + '__';
   end;

   Result := Adler32(0, @s[1], Length(s));
end;

procedure TSynchForm.Record_to_StringList(Table: TTable; pk: string; sl: TStringList);
var
   i : integer;
   f : TField;
begin
   Assert(Table<>nil);

   if not FindTablePK(Table, pk) then
      raise Exception.CreateFmt('Unable to find PK %s in Table %s', [pk, Table.TableName]);

   sl.Add(Table.TableName);
   sl.Add(pk);

   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if f.Visible or (f.FieldKind = fkData) then begin
         sl.Add(f.FieldName + '=' + EncodeStr(f.AsString));
      end;
   end;
end;


// ********************************************************************
// TSynchForm - Server

procedure TSynchForm.MinTrayButClick(Sender: TObject);
begin
   Application.Minimize;
   TrayIcon1.Active := True;
   TrayIcon1.ToolTip := Application.Title + ' - Data Synchronization Server';
   ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TSynchForm.Shutdown1Click(Sender: TObject);
begin
   RestoreServerClick(nil);
   ServerSocket1.Active := False;
   Application.MainForm.Close;
end;

procedure TSynchForm.ListenButClick(Sender: TObject);
begin
   ServerStat('');
   ServerStat('Server STARTUP - ' + FormatDateTime('ddd, mmm dd, yyyy hh:nn:ss ampm', Now));
   ServerSocket1.Port := StrToInt(ServerPortEdit.Text);
   ServerSocket1.Active := True;
   ServerButs;
end;

procedure TSynchForm.ShutdownButClick(Sender: TObject);
begin
   ServerStat('Server SHUTDOWN');
   ServerSocket1.Active := False;
   ServerButs;
end;

procedure TSynchForm.ServerButs;
var
   b : boolean;
begin
   b := ServerSocket1.Active;
   ListenBut.Enabled   := not b;
   ShutdownBut.Enabled := b;
   MinTrayBut.Enabled  := b;
end;

procedure TSynchForm.ServerSocket1Listen(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ServerStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Server Listening', Socket.LocalHost,
      '(' + Socket.LocalAddress + ')', Socket.LocalPort]));
end;

procedure TSynchForm.ServerStat(const s: string);
begin
   SvrList.ItemIndex := SvrList.Items.Add(s);
   Update;
end;

procedure TSynchForm.ServerSocket1Accept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ServerStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Accepted Connection', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]));
end;

procedure TSynchForm.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ServerStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Client Connected', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]));
end;

procedure TSynchForm.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ServerStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Client Disconnected', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]));
end;

procedure TSynchForm.ServerSocket1ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ServerStat(Format('%-20s  %-20d %-20s', ['Client Error', ErrorCode, SysErrorMessage(ErrorCode)]));
   ErrorCode := 0;
end;

procedure TSynchForm.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   len : integer;
begin
   len := sizeof(ServerBuf);
   Con := Socket;
   ProcessRead(NumServer, Socket, ServerBuf, len, OnServerMsg);
end;

function IsCommand(const s, CmdStr: string): boolean;
begin
   Result := StrLIComp(PChar(s), PChar(CmdStr), Length(CmdStr)) = 0;
end;

// ********************************************************************
// TSynchForm - Server - "Message Loop"

procedure TSynchForm.OnServerMsg(const s: string);
var
   Com : string;
begin
   CurCom.CommaText := s;
   ServerStat(Format('%-20s  %s', ['Client Command', CurCom.CommaText]));

   Com := CurCom[0];
   if IsCommand(Com, COM_QUIT) then begin
      Con.Close;
      exit;
   end;

   if IsCommand(Com, COM_ECHO) then begin
      NBSend(Con, s);
      exit;
   end;

   if IsCommand(Com, COM_TABLENAMES) then begin
      Command_TableNames;
      exit;
   end;

   if IsCommand(Com, COM_SYNCHALL) then begin
      Command_SynchAll;
      exit;
   end;

   if IsCommand(Com, COM_SYNCHTABLE) then begin
      Command_SynchTable;
      exit;
   end;

   if IsCommand(Com, COM_SENDRECORD) then begin
      Command_SendRecord;
      exit;
   end;

   if IsCommand(Com, COM_POSTRECORD) then begin
      Command_PostRecord;
      exit;
   end;

   NBSend(Con, 'UNKNOWN COMMAND!');
end;

procedure TSynchForm.Command_TableNames;
var
   i   : integer;
   c   : TComponent;
   sl  : TStringList;
begin
   sl := TStringList.Create;

   sl.Add('TABLENAMES');
   for i := 0 to TableSet.DataGroup.ComponentCount-1 do begin
      c := TableSet.DataGroup.Components[i];
      if c is TTable then
         sl.Add(TTable(c).TableName);
   end;
   NBSend(Con, sl.CommaText);
   
   sl.Free;
end;

procedure TSynchForm.Command_SynchAll;
var
   i   : integer;
   c   : TComponent;
begin
   for i := 0 to TableSet.DataGroup.ComponentCount-1 do begin
      c := TableSet.DataGroup.Components[i];
      if c is TTable then begin
         CurCom.Clear;
         CurCom.Add(COM_SYNCHTABLE);
         CurCom.Add(TTable(c).TableName);
         Command_SynchTable
      end;
   end;
   NBSend(Con, COM_SYNCHALL);
end;

procedure TSynchForm.Command_SynchTable;
var
   TableName : string;
   Table     : TTable;
   pk        : TField;
   chk       : integer;
   s         : string;
begin
   TableName := CurCom[1];
   Table := FindTable(TableName);

   s := Format('%s,%s,%s', [COM_SYNCHREC, Table.TableName, '*START*']);
   NBSend(Con, s);

   if Table<>nil then begin
      pk := GetRequiredField(Table);

      Table.First;
      while not Table.EOF do begin
         chk := AdlerFields(Table);
         s := Format('%s,%s,%s,%8.8x', [COM_SYNCHREC, Table.TableName, pk.AsString, chk]);
         NBSend(Con, s);
         ServerStat(Format('%-20s  %s', ['Sent Checksum', s]));

         Table.Next;
      end;
   end;

   s := Format('%s,%s,%s', [COM_SYNCHREC, Table.TableName, '*END*']);
   NBSend(Con, s);
end;

procedure TSynchForm.Command_SendRecord;
var
   TabName  : string;
   Table    : TTable;
   sl       : TStringList;
begin
   TabName := CurCom[1];
   Table   := FindTable(TabName);

   sl := TStringList.Create;
   try
      sl.Add(COM_SENDRECORD);
      Record_to_StringList(Table, CurCom[2] {pk}, sl);
      NBSend(Con, sl.CommaText);
   finally
      sl.Free;
   end;
end;

procedure TSynchForm.Command_PostRecord;
var
   TabName  : string;
   pk       : string;
   i        : integer;
   Table    : TTable;
   FoundPK  : boolean;
   f        : TField;
   v        : string;
begin
   TabName := CurCom[1];
   pk      := CurCom[2];
   Table   := FindTable(TabName);

   FoundPK := FindTablePK(Table, pk);

   if FoundPK then Table.Edit
      else Table.Append;

   for i := 0 to Table.FieldCount-1 do begin
      f := Table.Fields[i];
      if f.FieldKind = fkData then begin
         v := DecodeStr(CurCom.Values[f.FieldName]);
         f.AsString := v;
      end;
   end;

   Table.Post;
end;


// ********************************************************************
// TSynchForm - Client

procedure TSynchForm.ConnectButClick(Sender: TObject);
begin
   ClientStat('');
   ClientStat('Connecting to Server - ' + FormatDateTime('ddd, mmm dd, yyyy hh:nn:ss ampm', Now));
   ClientSocket1.Host := RemoteAddressEdit.Text;
   ClientSocket1.Port := StrToInt(RemotePortEdit.Text);
   ClientSocket1.Active := True;
end;

procedure TSynchForm.DisconButClick(Sender: TObject);
begin
   ClientStat('Disconnecting');
   ClientSocket1.Active := False;
end;

procedure TSynchForm.ClientButs;
var
   b : boolean;
begin
   b := ClientSocket1.Active;
   ConnectBut.Enabled := not b;
   DisconBut.Enabled := b;
   SendBut.Enabled := b;
   SynchBut.Enabled := not b;
end;

procedure TSynchForm.ClientStat(const s: string);
begin
   ClientList.ItemIndex := ClientList.Items.Add(s);
   Update;
end;

procedure TSynchForm.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ClientStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Connected', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]));
   ClientButs;
   BeginSynch;
end;

procedure TSynchForm.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ClientStat(Format('%-20s  %-20s %-20s  Port %d',
      ['Disconnected', Socket.RemoteHost,
      '(' + Socket.RemoteAddress + ')', Socket.RemotePort]));
   ClientButs;
end;

procedure TSynchForm.ClientSocket1Connecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ClientStat('Connecting');
end;

procedure TSynchForm.ClientSocket1Lookup(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ClientStat('Looking up address');
   ClientButs;
end;

procedure TSynchForm.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ClientStat(Format('%-20s %s', ['Client Socket Error', SocketErr(ErrorCode)]));
   // ErrorCode := 0;
   ClientButs;
end;

procedure TSynchForm.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ProcessRead(NumClient, Socket, ClientBuf, sizeof(ClientBuf), OnClientMsg);
end;

// ********************************************************************
// TSynchForm - Client - "Message Loop"

procedure TSynchForm.OnClientMsg(const s: string);
var
   i : integer;
begin
   ClientCom.CommaText := s;

   ClientStat(Format('%-20s  %-20s', ['Received Data', s]));

   if IsCommand(s, COM_SYNCHREC) then begin
      OnSynchTableMsg(s);
      exit;
   end;

   if IsCommand(s, COM_SENDRECORD) then begin
      // Process_Record_Request(True);
      SRecList.FindRec(ClientCom[1], ClientCom[2]).RecData := s;
      exit;
   end;

   if IsCommand(s, COM_SYNCHALL) then begin
      for i := 0 to SRecList.Count-1 do begin
         if SRecList[i].SynchType in [stMisMatch, stRemoteOnly] then
            Send_Record_Request(SRecList[i].TableName, SRecList[i].PK);
      end;
      NBSend(ClientSocket1.Socket, COM_ECHO + ' SENDREC_DONE');
      exit;
   end;

   if IsCommand(s, COM_ECHO) and (ClientCom[1] = 'SENDREC_DONE') then begin
      ClientStat('');
      ClientStat(Format('%-20s %-20s %10s', ['Table Name', 'Primary Key', 'Synch Type']));

      for i := 0 to SRecList.Count-1 do with SRecList.SynchRecords[i] do
         ClientStat(Format('%-20s %-20s %10d', [TableName, PK, Integer(SynchType)]));
      ClientStat(Format('Num Matching Records = %d', [SRecList.NumMatch]));

      if SRecList.Count > 0 then begin
         if MessageDlg(Format('Databases are NOT synchronized - %d records are different.'#13#10 +
            'Would you like to synchronize them?', [SRecList.Count]),
            mtWarning, mbYesNoCancel, 0) = mrYes then
            Do_Manual_Synchronization;
      end else begin
         MessageDlg('Databases are synchronized.', mtInformation, [mbOK], 0);
      end;

      SRecList.ClearItems;
      NBSend(ClientSocket1.Socket, COM_ECHO + ' SYNCH_ALL_DONE');

      ClientStat('');
      ClientStat('Waiting for Remote to finish');
      exit;
   end;

   if IsCommand(s, COM_ECHO) and (ClientCom[1] = 'SYNCH_ALL_DONE') then begin
      DisconButClick(nil);
      ClientStat('');
      ClientStat('Synchronization Finished');
   end;
end;

procedure TSynchForm.Check_Missing_Records;
var
   pkf : TField;
   pks : string;
   idx : integer;
begin
   // Process all records that are in the Local Table but NOT Remote
   PKList.Sorted := True;

   pkf := GetRequiredField(ClientTab);
   Assert(pkf<>nil);

   ClientTab.First;
   while not ClientTab.EOF do begin
      pks := pkf.AsString;

      if not PKList.Find(pks, idx) then begin
         SRecList.AddSynchRec(ClientTab.TableName, pks, stLocalOnly);
      end;

      ClientTab.Next;
   end;
end;

procedure TSynchForm.OnSynchTableMsg(const s: string);
var
   pk        : string;
   chk, chk2 : integer;
begin
   ClientCom.CommaText := s;
   ClientTab := FindTable(ClientCom[1]);

   if ClientCom[2] = '*START*' then begin
      PKList.Clear;
      PKList.Sorted := False;
      exit;
   end;

   if ClientCom[2] = '*END*' then begin
      Check_Missing_Records;
      exit;
   end;

   pk  := ClientCom[2];                // Remote Primary Key
   chk := StrToInt('$'+ClientCom[3]);  // Remote checksum

   PKList.Add(pk);

   if not FindTablePK(ClientTab, pk) then begin
      ClientStat(Format('%-20s  %s', ['NOT FOUND!', s]));
      SRecList.AddSynchRec(ClientTab.TableName, pk, stRemoteOnly);
   end else begin
      chk2 := AdlerFields(ClientTab);
      if chk2 <> chk then begin
         ClientStat(Format('%-20s  %s', ['MISMATCH!', s]));
         SRecList.AddSynchRec(ClientTab.TableName, pk, stMismatch);
      end else begin
         // ClientStat(Format('%-20s  %s', ['Record Match', s]));
         SRecList.NumMatch := SRecList.NumMatch + 1;
      end;
   end;
end;

procedure TSynchForm.Send_Record_Request(const TableName: string; pk: string);
var
   s : string;
begin
   s := Format('%s %s %s', [COM_SENDRECORD, TableName, pk]);
   NBSend(ClientSocket1.Socket, s);
end;

// ********************************************************************
// TSynchForm - Client - Manual Synchronization Functions

procedure TSynchForm.Get_User_Choice(InRemote: boolean);
var
   i        : integer;
   FoundPK  : boolean;
   f        : TField;
   v1, v2   : string;
begin
   if CompForm = nil then CompForm := TCompRecordForm.Create(Self);

   FoundPK := FindTablePK(ClientTab, ClientCom[2] {PK});
   CompForm.InitFields(ClientTab);

   for i := 0 to ClientTab.FieldCount-1 do begin
      f := ClientTab.Fields[i];
      if f.Visible then begin
         if FoundPK then v1 := f.AsString
            else v1 := '';
         v2 := DecodeStr(ClientCom.Values[f.FieldName]);
         CompForm.SetFieldValues(f, v1, v2);
      end;
   end;

   CompForm.GetUserChoice(FoundPK, InRemote);
end;

procedure TSynchForm.Process_Record_Request(InLocal, InRemote: boolean);
var
   uc : TUserChoice;
begin
   // Process the User's choice
   uc := ClntChoice;

   if ClntChoice = ucNone then begin
      Get_User_Choice(InRemote);
      uc := CompForm.UserChoice;

      if uc in [ucCancel, ucLocalAll, ucRemoteAll] then ClntChoice := uc;
      if uc in [ucNone, ucSkip, ucCancel] then exit;
   end;

   if ClntChoice = ucLocalAll then uc := ucLocal;
   if ClntChoice = ucRemoteAll then uc := ucRemote;

   if (uc = ucLocal) and InLocal then Use_Local_Values;
   if (uc = ucRemote) and InRemote then Use_Remote_Values;
end;

procedure TSynchForm.Use_Local_Values;
var
   sl : TStringList;
begin
   sl := TStringList.Create;
   sl.Add(COM_POSTRECORD);
   Record_to_StringList(ClientTab, ClientCom[2] {pk}, sl);
   ClientStat(Format('%-20s  %s', ['Posting Record', sl.CommaText]));
   NBSend(ClientSocket1.Socket, sl.CommaText);
   sl.Free;
end;

procedure TSynchForm.Use_Remote_Values;
var
   i       : integer;
   FoundPK : boolean;
   f       : TField;
   v       : string;
begin
   FoundPK := FindTablePK(ClientTab, ClientCom[2]);

   if FoundPK then ClientTab.Edit
      else ClientTab.Append;

   for i := 0 to ClientTab.FieldCount-1 do begin
      f := ClientTab.Fields[i];
      if f.FieldKind = fkData then begin
         v := DecodeStr(ClientCom.Values[f.FieldName]);
         f.AsString := v;
      end;
   end;

   ClientTab.Post;
end;

procedure TSynchForm.SendButClick(Sender: TObject);
begin
   ClientStat(Format('%-20s  %-20s', ['Sending Data', SendEdit.Text]));
   NBSend(ClientSocket1.Socket, SendEdit.Text);
end;

procedure TSynchForm.SynchButClick(Sender: TObject);
begin
   ConnectButClick(nil);
end;

procedure TSynchForm.BeginSynch;
var
   s : string;
begin
   SRecList.ClearItems;
   SRecList.NumMatch := 0;
   s := COM_SYNCHALL;
   ClientStat(Format('%-20s  %-20s', ['Sending Data', s]));
   NBSend(ClientSocket1.Socket, s);
end;

procedure TSynchForm.Do_Manual_Synchronization;
var
   i, j : integer;
   tmp  : TStringList;
begin
   ClntChoice := ucNone;
   tmp := TStringList.Create;

   for i := 0 to SRecList.Count-1 do with SRecList.SynchRecords[i] do begin
      // Must set up some globals first
      ClientTab := FindTable(TableName);
      
      ClientCom.Clear;
      ClientCom.Add(COM_SYNCHREC);
      ClientCom.Add(TableName);
      ClientCom.Add(PK);
      tmp.CommaText := RecData;
      for j := 3 to tmp.Count-1 do
         ClientCom.Add(tmp[j]);

      Process_Record_Request(SynchType in [stMisMatch, stLocalOnly],
         SynchType in [stMisMatch, stRemoteOnly]);
   end;

   tmp.Free;
end;


end.
