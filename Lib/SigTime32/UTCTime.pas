unit UTCTime;

interface

uses
  SysUtils,
  System.UITypes,
  DateUtils,
  VCL.Dialogs,
  VCL.Controls;

type
  TUTCDateTime = class
  private
    fLastTime : TDateTime;
    fForceDaylightSaving : boolean;
  protected
  public
    constructor Create; overload;

    property DaylightSaving : boolean
             read fForceDaylightSaving
             write fForceDaylightSaving;

    function UTCNow : TDateTime;  // this is UTC

    function LocalDateTime( pUTCDateTime : TDateTime ) : TDateTime;

  end;

implementation

{ TUTCDateTime }

constructor TUTCDateTime.Create;
begin
  inherited Create;
  fForceDayLightSaving := FALSE;
  case TTimeZone.Local.GetLocalTimeType( Now ) of
    lttAmbiguous:
    begin
      case MessageDlg( 'The current time is ' + TimeToStr( Now ) + '. Is this Daylight saving time?', mtInformation, [mbYes, mbNo], 0 ) of
        mrYes:
        begin
          fForceDaylightSaving := TRUE;
        end;
      end;
    end;
  end;
  fLastTime := TTimeZone.Local.ToUniversalTime( Now, fForceDaylightSaving );
end;

function TUTCDateTime.LocalDateTime(pUTCDateTime : TDateTime): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime( pUTCDateTime )
end;

function TUTCDateTime.UTCNow: TDateTime;
begin

  case TTimeZone.Local.GetLocalTimeType( Now ) of
    lttAmbiguous:
    begin
      Result  := TTimeZone.Local.ToUniversalTime( Now, fForceDaylightSaving );
      if not fForceDayLightSaving then
      begin
        if Result < fLastTime then
        begin
          fForceDayLightSaving := TRUE;
          Result  := TTimeZone.Local.ToUniversalTime( Now, fForceDaylightSaving );
        end;
      end;
    end;
    else
    begin
      if fForceDaylightSaving then
      begin
        fForceDayLightSaving := FALSE;
      end;
      Result  := TTimeZone.Local.ToUniversalTime( Now, fForceDaylightSaving );
    end;
  end;
  fLastTime := Result;
end;

end.
