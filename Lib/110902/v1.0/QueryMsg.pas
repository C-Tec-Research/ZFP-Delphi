unit QueryMsg;

interface

Uses
  SS2NMsg, SysUtils;

type
  TQueryMessage = class( TSS2NMessage )
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create( CopyID : integer );


    { by default we do not want a retry limit on these messages }
    procedure ActionNak; override;
    procedure ActionTimeOut; override;
end;

implementation

constructor TQueryMessage.Create( CopyID : integer );
begin
  inherited Create(Format('?%.2X', [CopyID]));
  iTestString := 'DE000001';
end;

procedure TQueryMessage.ActionNak;
var
  AllowRetry : boolean;
begin
  { by default, never quit, but user can change }
  AllowRetry := TRUE;
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

procedure TQueryMessage.ActionTimeOut;
var
  AllowRetry : boolean;
begin
  { by default, never quit, but user can change }
  AllowRetry := TRUE;
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


end.


