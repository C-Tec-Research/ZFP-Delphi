unit UnitSigJSONDateTime;

interface

uses
  System.SysUtils,
  UnitSigJSON,
  ISO8601;

type
  TSigJSONDateTime = class( TSigJSONTextObject )
  private
    fDateTime: TDateTime;
    procedure SetDateTime(const Value: TDateTime);
    function GetValueAsISO8601Time: string;
    procedure SetValueAsISO8601Time(const Value: string);
    function GetValueAsISO8601DateTime: string;
    procedure SetValueAsISO8601DateTime(const Value: string);
  protected
    function GetJSON: string; override;             // by default we use ISO date timne format
    procedure FromJSON(var iValue: string); override;
  public
    property DateTime : TDateTime
             read fDateTime
             write SetDateTime;
    property ValueAsISO8601Time : string
             read GetValueAsISO8601Time
             write SetValueAsISO8601Time;
    property ValueAsISO8601DateTime : string
             read GetValueAsISO8601DateTime
             write SetValueAsISO8601DateTime;
    function IsDefault : boolean; override;
  end;


implementation

{ TSigJSONDateTime }

procedure TSigJSONDateTime.FromJSON(var iValue: string);
begin
  inherited;
  ValueAsISO8601DateTime := fJSONValue;
end;

function TSigJSONDateTime.GetJSON: string;
begin
  if Int( fDateTime ) = 0 then
  begin
    // a time, rather than a date
    Result := ValueAsISO8601Time;
  end
  else
  begin
    Result := ValueAsISO8601DateTime;
  end;
end;

function TSigJSONDateTime.GetValueAsISO8601DateTime: string;
begin
  Result := '"' + ISO8601DateTimeToStr( fDateTime ) +'"';
end;

function TSigJSONDateTime.GetValueAsISO8601Time: string;
begin
  Result := '"' + ISO8601TimeToStr( fDateTime ) + '"';
end;

function TSigJSONDateTime.IsDefault: boolean;
begin
  Result := DateTime = 0;
end;

procedure TSigJSONDateTime.SetDateTime(const Value: TDateTime);
begin
  fDateTime := Value;
  fJSONValue := DateTimeToStr( Value );
end;

procedure TSigJSONDateTime.SetValueAsISO8601DateTime(const Value: string);
begin
  fDateTime := ISO8601StrToDateTime( Value );
end;

procedure TSigJSONDateTime.SetValueAsISO8601Time(const Value: string);
begin
  fDateTime := ISO8601StrToDateTime( Value );
  fDateTime := Frac(DateTime);
end;

end.
