unit ss2ncomm;

{ based on a comms panel, but supports single and multiple action lists }

interface

uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Companel, SS2NMsg, QueryMsg;

type
  TSS2NCommsPanel = class(TCommsPanel)
  private
    { Private declarations }
    function fReadSS2NMessage( index : integer ) : TSS2NMessage;
    function fReadCount : integer;
  protected
  	 counter : integer;
    { Protected declarations }
    MessageList : TList;
    iCanProcessMessage : Boolean;
    iActiveMessage : integer;
    isClosing : boolean;
    iCopyID : integer;
    isInTimer : boolean;
    procedure fTimerAction (Sender: TObject); override;
    { we need to intercept the OnAck, OnNak and OnTimeOut events}
    procedure MyOnAck(Sender: TObject); virtual;
    procedure MyOnNak(Sender: TObject); virtual;
    { to put these actions in place... }
    procedure Loaded; override;
    function TryToRemoveMessage( index : integer) : boolean;
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;

    procedure Add( const pMessage : TSS2NMessage );

    procedure Remove( pMessage : integer );
    property SS2NMessage[ index : integer ] : TSS2NMessage
             read fReadSS2NMessage;
             { note: unlike TList, this goes from 1 to count,
               not 0 to Count - 1 }
    property Count : integer
             read fReadCount;
    property ActiveMessage : integer
             read iActiveMessage;
  published
    { Published declarations }
    property CopyID : integer
             read iCopyID
             write iCopyID;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSS2NCommsPanel]);
end;

constructor TSS2NCommsPanel.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );

  MessageList := TList.Create;

  iCanProcessMessage := TRUE;

  iActiveMessage := 1;

  isClosing := FALSE;

  iCopyID := 0;

  isInTimer := FALSE;

  Counter := 0;
end;

destructor TSS2NCommsPanel.Destroy;
begin
  isClosing := TRUE;

  if (not (csDesigning in ComponentState )) then
  begin
    { wait for ss2n response to current message
      and dispose of all messages }
    while not iCanProcessMessage do
{        Application.ProcessMessages;}
		fTimerAction (self);
    { Now sign off }
    Text := '?00';
    { Throw reply away - we don't care }
  end;

  MessageList.Free;
  inherited Destroy;
end;

function TSS2NCommsPanel.fReadSS2NMessage( index : integer ) : TSS2NMessage;
begin
  if (index < 1) or (Index > Count) then
    raise ERangeError.Create('Index [' + IntToStr(index) + '] for ' + Name + 'out of range')
  else
    Result := TSS2NMessage( MessageList.Items[ index - 1]);
end;

function TSS2NCommsPanel.fReadCount : integer;
begin
  Result := MessageList.Count;
end;

procedure TSS2NCommsPanel.fTimerAction (Sender: TObject);
var
  NextActiveMessage : integer;
  LastMessage : integer;
begin
  { do the processTick action on all messages. This should
    only make messages available for processing }
  NextActiveMessage := 1;
  LastMessage := Count;
  inc(counter);
  while NextActiveMessage <= LastMessage do
  begin
    SS2NMessage[ NextActiveMessage ].ActionTick;

    { see if we can delete now }
    if TryToRemoveMessage( NextActiveMessage ) then
    begin
      Dec( LastMessage );
      if NextActiveMessage <= iActiveMessage then begin
           {If the message removed was equal to or less than the active message,
           decrement the active message to avoid it skipping messages. E.g. if
           Next message is 4 and activemessage is 4, the next message will then be
           actually no 3, but the active message is still 4, so a message is skipped}
           Dec (iActiveMessage);
{           if iActiveMessage < 0 then begin
               iActiveMessage := 0;
           end;}
      end;

      { we deleted a message, so there is one less in
        the list and we are poining to the message we
        want to deal with next }
    end
    else
    begin
      Inc( NextActiveMessage );
      { we did not delete the message, so try next one }
    end;
  end;
  if isClosing then
  begin
    iCanProcessMessage := TRUE;
  end
  else
  { see if it is OK to process a message }
  if iCanProcessMessage then
  begin
    { try to Find an active message above current }
    for NextActiveMessage := iActiveMessage + 1 to Count do
    begin
      if iCanProcessMessage
      and SS2NMessage[ NextActiveMessage ].CanSubmit
      and not isClosing then
      begin
        iCanProcessMessage := FALSE;
{        form1.memo1.lines.add (SS2NMessage[NextActiveMessage].Text + '  ' +
        	IntToStr (NextActiveMessage));}
        Text := SS2NMessage[ NextActiveMessage ].Text;
{        form1.memo1.lines.add (text);}
        iActiveMessage := NextActiveMessage;
      end;
    end;
    if iActiveMessage > Count then iActiveMessage := 0;
    { try to Find an active message below current }
    for NextActiveMessage := 1 to iActiveMessage do
    begin
      if iCanProcessMessage
      and SS2NMessage[ NextActiveMessage ].CanSubmit
      and not isClosing then
      begin
        iCanProcessMessage := FALSE;
        Text := SS2NMessage[ NextActiveMessage ].Text;
        iActiveMessage := NextActiveMessage;
      end;
    end;
  end;

  { then do the inherited stuff }
  inherited fTimerAction( Sender );

  { see if we had timed out }
  if  not isClosing
  and not iCanProcessMessage
  and (iActiveMessage > 0)
  and (iActiveMessage <= Count ) then
  begin
    { a message is active }
    if IsTimedOut then
    begin
      SS2NMessage[ iActiveMessage ].ActionTimeOut;
      iCanProcessMessage := TRUE;
    end;
  end;
end;

function TSS2NCommsPanel.TryToRemoveMessage( index : integer) : boolean;
begin
  { if we can remove message ...}
  if (index > 0) and (index <= count) then
  begin
    if isClosing or SS2NMessage[ index ].CanDelete then
    begin
      { do so }
      Remove( index );
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TSS2NCommsPanel.Remove( pMessage : integer );
begin
  { unconditional removal of message; if active, must ignore reply }
  SS2NMessage[ pMessage ].Free;
  MessageList.Delete( pMessage - 1 );
  MessageList.Pack;
end;

procedure TSS2NCommsPanel.Add( const pMessage : TSS2NMessage );
begin
  MessageList.Add( pMessage );
end;

procedure TSS2NCommsPanel.MyOnAck(Sender: TObject);
begin
  if  not isClosing
  and not iCanProcessMessage
  and (iActiveMessage > 0) and (iActiveMessage <= Count ) then
  begin
    if SS2NMessage[ iActiveMessage ].IsActive then
    begin
      { a message is active }
      SS2NMessage[ iActiveMessage ].ActionAck( Text );
    end;
  end;
  if Assigned (fOnAck) then fOnAck( Sender );
  iCanProcessMessage := TRUE;
end;

procedure TSS2NCommsPanel.MyOnNak(Sender: TObject);
begin
  if  not isClosing
  and not iCanProcessMessage
  and (iActiveMessage > 0)
  and (iActiveMessage <= Count ) then
  begin
    if SS2NMessage[ iActiveMessage ].IsActive then
    begin
      { a message is active }
      SS2NMessage[ iActiveMessage ].ActionNak;
    end;
  end;
  if Assigned (fOnNak) then fOnNak( Sender );
  iCanProcessMessage := TRUE;
end;

procedure TSS2NCommsPanel.Loaded;
var
  QueryMessage : TQueryMessage;
begin
  inherited Loaded;
  { now put my own special fuctions in place }
  ComPort1.OnAck := MyOnAck;
  ComPort1.OnNak := MyOnNak;
  { add a ? message to start things off }
  QueryMessage := TQueryMessage.Create( iCopyID);
  Add( QueryMessage);
  QueryMessage.Release;
end;

end.

