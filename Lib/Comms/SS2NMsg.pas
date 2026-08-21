unit SS2NMsg;

interface

type
  TSS2NMessage = class;
  TAckEvent = procedure( const Sender : TSS2NMessage; var ReturnString : string) of object;
  TNakEvent = procedure( const Sender : TSS2NMessage;
                         const RetryCount : integer;
                         var AllowRetry : boolean ) of object;
  TTimeoutEvent = procedure( const Sender : TSS2NMessage;
                             const RetryCount : integer;
                             var AllowRetry : boolean ) of object;
  TTickEvent = procedure( const Sender : TSS2NMessage ) of object;

  TSS2NMessage = class( TObject )
  private
    { Private declarations }
  protected
    { Protected declarations }
    iCanSubmit, iCanDelete : boolean;
    iSubmitString : string;
    iRetryCount : integer;
    iActive : boolean;
    iTestString : string;
    iReleased : boolean;
    iResubmitCount : integer; { 0 = permanent cyclic message.
                                normally this value is 1 or zero,
                                but may be other values }
    iResubmitPeriodCount : integer;
                           { number of comms panel
                             ticks before resubmit is allowed }
    iSubmitRemainingPeriodCount : integer;
                           { Countdown for resubmission }

    fOnAck : TAckEvent;
    fOnNak : TNakEvent; { every NACK }
    fOnTimeOut : TTimeOutEvent; { whenever a time out occurs }
    fOnTick : TTickEvent; { every tick - usually 1/10 second }
    function Submit : string; virtual;
    function fCanDelete : boolean;
  public
    { Public declarations }
    constructor Create( const pSubmitString : string ); virtual;

    destructor Destroy; override;

    { the following functions should only be
      used by Tss2nCommsPanel }
    procedure ActionAck( ReturnString :string ); virtual;
    procedure ActionNak; virtual;
    procedure ActionTimeOut; virtual;
    procedure ActionTick; virtual;

    { the following functions may be used by anyone }
    function Release : boolean;

    property CanSubmit : boolean
             read iCanSubmit
             write iCanSubmit;
    property CanDelete : boolean
             read fCanDelete
             write iCanDelete;
    property Text : string
             read Submit;
    property TestString : string
             read iTestString;
    property IsActive : boolean
             read iActive;
    property OnAck : TAckEvent
             read fOnAck
             write fOnAck;
    property OnNak : TNakEvent
             read fOnNak
             write fOnNak;
    property OnTimeOut : TTimeOutEvent
             read fOnTimeOut
             write fOnTimeOut;
    property OnTick : TTickEvent
             read fOnTick
             write fOnTick;
    property ResubmitCount : integer
             read iResubmitCount
             write iResubmitCount;
    property ResubmitPeriodCount : integer { in TSS2NCommsPanel Ticks }
             read iResubmitPeriodCount
             write iResubmitPeriodCount;
end;

implementation

constructor TSS2NMessage.Create( const pSubmitString : string );
begin
  inherited Create;
  iCanSubmit := FALSE;
  iCanDelete := FALSE;
  iSubmitString := pSubmitString;
  iRetryCount := 0;
  iActive := FALSE;
  iTestString := '';
  iReleased := FALSE;
  iResubmitCount := 1;
  iResubmitPeriodCount := 0;
end;

destructor TSS2NMessage.Destroy;
begin
  inherited Destroy;
end;

procedure TSS2NMessage.ActionAck( ReturnString :string );
begin
  iActive := FALSE;
  { allow the user to do any preliminary processing.
    Note that this function is commonly overriden,
    with ReturnString subsequently processed. }
  if Assigned( fOnAck ) then
  begin
    fOnAck( self, ReturnString );
  end;
end;

procedure TSS2NMessage.ActionNak;
var
  AllowRetry : boolean;
begin
  { decide default action }
  if iRetryCount < 3 then
  begin
    AllowRetry := TRUE;
  end
  else
  begin
    AllowRetry := FALSE;
  end;
  { allow the user to do any preliminary processing,
    and allow or block retries }
  if Assigned( fOnNak ) then fOnNak( self, iRetryCount, AllowRetry );
  inc( iRetryCount);
  if AllowRetry then
  begin
    { this resubmission does not act like a real one.
      increment the Resubmit Count unless it is a permananet message }
    if iResubmitCount > 0 then Inc( iResubmitCount );
    iCanSubmit := TRUE;
    iCanDelete := FALSE; { we may already have marked for deletion }
  end
  else
  begin
    iCanSubmit := FALSE;
  end;
  iActive := FALSE;
end;

procedure TSS2NMessage.ActionTimeOut;
var
  AllowRetry : boolean;
begin
  { decide default action }
  if iRetryCount < 3 then
  begin
    AllowRetry := TRUE;
  end
  else
  begin
    AllowRetry := FALSE;
  end;
  { allow the user to do any preliminary processing,
    and allow or block retries }
  if Assigned( fOnTimeOut ) then fOnTimeOut( self, iRetryCount, AllowRetry );
  inc( iRetryCount);
  if AllowRetry then
  begin
    { this resubmission does not act like a real one.
      increment the Resubmit Count unless it is a permananet message }
    if iResubmitCount > 0 then Inc( iResubmitCount );
    iCanSubmit := TRUE;
    iCanDelete := FALSE; { we may already have marked for deletion }
  end
  else
  begin
    iCanSubmit := FALSE;
  end;
  iActive := FALSE;
end;

function TSS2NMessage.Submit : string;
begin
  iCanSubmit := FALSE;
  Result := iSubmitString; { send the character }
  iActive := TRUE;
end;

function TSS2NMessage.Release : boolean;
begin
  if iActive or iCanSubmit then
  begin
    { cannot release if already active or
      already released }
    Result := FALSE;
  end
  else
  begin
    iCanSubmit := TRUE;
    { note - do not decrement iResubmit count on first
      release; this would lead to an incorrect count }
    Result := TRUE;
    iSubmitRemainingPeriodCount := iResubmitPeriodCount;
    { ready for next release }
  end;
  iReleased := TRUE;
end;

procedure TSS2NMessage.ActionTick;
begin
  if Assigned( fOnTick ) then fOnTick( self );
  if (iReleased) then
  begin
    Dec( iSubmitRemainingPeriodCount );
    if iSubmitRemainingPeriodCount <= 0 then
    begin
      if iResubmitCount > 0 then
      begin
        { limited submitCount }
        Dec( iResubmitCount );
        if iResubmitCount <= 0 then
        begin
          { we have submitted the maximum number of times.
            Remember, the first release does not decrement
            this count }
          iCanDelete := TRUE;
          iResubmitCount := 1; { do not allow to become permanent }
        end
        else
        begin
          { we are now elegible for resubmission }
          iCanSubmit := TRUE;
          iSubmitRemainingPeriodCount := iResubmitPeriodCount;
        end;
      end
      else
      begin
        if not iCanDelete then
        begin
          { permanent cyclic resubmission }
          iCanSubmit := TRUE;
          iSubmitRemainingPeriodCount := iResubmitPeriodCount;
        end;
      end;
    end;
  end;
end;

function TSS2NMessage.fCanDelete : boolean;
begin
  Result := iCanDelete and not iActive and not iCanSubmit;
  { we can delete if we are marked ready for deletion
    and are not active or ready to become active }
end;

end.
