unit DDList;

interface

uses SysUtils, Classes, Windows, Messages, ComCtrls, ShellAPI;

type
   TDropFilesEvent = procedure(Sender: TObject; Files: TStringList) of object;

   TDragDropList = class(TListView)
   protected
      FOnDrop     : TDropFilesEvent;
      FAccept     : boolean;
      procedure   SetAccept(b: boolean);
      procedure   CreateWnd; override;
      procedure   DropFiles(var Message: TMessage); message WM_DROPFILES;
   public
      constructor Create(AOwner: TComponent); override;
   published
      property    AcceptDropFiles: boolean read FAccept write SetAccept default True;
      property    OnDropFiles: TDropFilesEvent read FOnDrop write FOnDrop;
   end;

   procedure Register;

implementation

constructor TDragDropList.Create(AOwner: TComponent);
begin
   inherited;
   FAccept := True;
end;

procedure TDragDropList.SetAccept(b: boolean);
begin
   FAccept := b;
   if not (csLoading in ComponentState) then
      RecreateWnd;
end;

procedure TDragDropList.CreateWnd;
begin
   inherited;
   DragAcceptFiles(Handle, AcceptDropFiles);
end;

procedure TDragDropList.DropFiles(var Message: TMessage);
var
   hDrop    : THandle;
   NumFiles : integer;
   i        : integer;
   buf      : array[0..MAX_PATH] of char;
   sl       : TStringList;
begin
   hDrop := Message.WParam;
   NumFiles := DragQueryFile(hDrop, $FFFFFFFF, nil, 0);

   sl := TStringList.Create;
   for i := 0 to NumFiles-1 do begin
      DragQueryFile(hDrop, i, buf, sizeof(buf));
      sl.Add(buf);
   end;

   DragFinish(hDrop);

   if Assigned(OnDropFiles) then
      OnDropFiles(Self, sl);

   sl.Free;
end;


procedure Register;
begin
   RegisterComponents('Samples', [TDragDropList]);
end;

end.
