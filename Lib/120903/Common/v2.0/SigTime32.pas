unit SigTime32;

interface
{
	v1.0.0
	This component acquires the time from SigTime32.DLL.  It reads the time,
	splits the time into its component parts and places those parts into the
	relevant property.

	It is designed so that custom DLL's can be written so that time can be
	synchronised from a common source across a network.

	However, the standard SigTime32.DLL acquires its time from the PC clock.

	It loads the DLL on the creation of the component, and releases it when it
	is destroyed.
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
	TSigTime = record
		Year,
		Month,
		Day,
		DayOfWeek,
		Hour,
		Minute,
		Second,
		Millisecond: Word;
	end;

type
	TSigTimeEx = record
		Year,
		Month,
		Day,
		DayOfWeek,
		Hour,
		Minute,
		Second,
		Millisecond,
		Status: Word;
	end;

type
	TGetSigTime = function (tsSigTime: TSigTime): Word;

type
  TSigTime32 = class(TComponent)
  private
	 { Private declarations }
	 iSigTime: TSigTime;
	 iSigTimeEx: TSigTimeEx;
	 iLoaded: Boolean;
	 function fGetDay: Word;
	 function fGetDayOfWeek: Word;
	 function fGetHour: Word;
	 function fGetMillisecond: Word;
	 function fGetMinute: Word;
	 function fGetMonth: Word;
	 function fGetSecond: Word;
	 function fGetStatus: Word;
	 function fGetSigTime: TSigTime;
	 function fGetSigTimeEx: TSigTimeEx;
	 function fGetWeekDay: string;
	 function fGetYear: Word;
  protected
	 { Protected declarations }
  public
	 { Public declarations }
	 property Day: Word read fGetDay;
	 property DayOfWeek: Word read fGetDayOfWeek;
	 property Hour: Word read fGetHour;
	 property IsLoaded: Boolean read iLoaded;
	 property Millisecond: Word read fGetMillisecond;
	 property Minute: Word read fGetMinute;
	 property Month: Word read fGetMonth;
	 property Second: Word read fGetSecond;
	 property SigTime: TSigTime read fGetSigTime;
	 property SigTimeEx: TSigTimeEx read fGetSigTimeEx;
	 property Status: Word read fGetStatus;
	 property WeekDay: string read fGetWeekDay;
	 property Year: Word read fGetYear;
	 constructor Create (AOwner: TComponent); override;
	 destructor Destroy; override;

  published
	 { Published declarations }

  end;
var
	GetSigTime: TGetSigTime;
	hSigTime: THandle;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigTime32]);
end;

{ TSigTime32 }


{ TSigTime32 }

constructor TSigTime32.Create(AOwner: TComponent);
var
	p: Pointer;
begin
	inherited Create (AOwner);
	iLoaded := false;
	{do not load DLL if in design mode}
	if not (csDesigning in ComponentState) then begin
		hSigTime := LoadLibrary ('SigTime32.DLL');

		{if error loading DLL, say so}
		if hSigTime < 32 then begin
			ShowMessage ('Fatal Error: Cannot load SIGTIME32.DLL');
		end
		else begin
			P := GetProcAddress (hSigTime, 'GetSigTime');
			if P = nil then
				ShowMessage ('Have not loaded function')
			else begin
				GetSigTime := TGetSigTime (P);
				{if we reach this point, then the function has loaded OK}
				iLoaded := true;
			end;
		end;
	end;
end;

destructor TSigTime32.Destroy;
begin
	{Do not bother to free DLL if in design mode}
	if (not ( csDesigning in ComponentState)) and iLoaded then begin
		FreeLibrary (hSigTime);
	end;
	inherited Destroy;
end;

function TSigTime32.fGetDay: Word;
begin
	Result := SigTime.Day;
end;

function TSigTime32.fGetDayOfWeek: Word;
begin
	Result := SigTime.DayOfWeek;
end;

function TSigTime32.fGetHour: Word;
begin
	Result := SigTime.Hour;
end;

function TSigTime32.fGetMillisecond: Word;
begin
	Result := SigTime.Millisecond;
end;

function TSigTime32.fGetMinute: Word;
begin
	Result := SigTime.Minute;
end;

function TSigTime32.fGetMonth: Word;
begin
	Result := SigTime.Month;
end;

function TSigTime32.fGetSecond: Word;
begin
	Result := SigTime.Second;
end;

function TSigTime32.fGetSigTime: TSigTime;
begin
	GetSigTime (iSigTime);
	Result := iSigTime;
end;

function TSigTime32.fGetSigTimeEx: TSigTimeEx;
begin
	{Acquire time}
	iSigTimeEx.Status := GetSigTime (iSigTime);
	{Re-map time from SigTime to SigTimeEx}
	iSigTimeEx.Year := iSigTime.Year;
	iSigTimeEx.Month := iSigTime.Month;
	iSigTimeEx.Day := iSigTime.Day;
	iSigTimeEx.DayOfWeek := iSigTime.DayOfWeek;
	iSigTimeEx.Hour := iSigTime.Hour;
	iSigTimeEx.Minute := iSigTime.Minute;
	iSigTimeEx.Second := iSigTime.Second;
	iSigTimeEx.Millisecond := iSigTime.Millisecond;
	Result := iSigTimeEx;
end;

function TSigTime32.fGetStatus: Word;
begin
	Result := GetSigTime (iSigTime);
end;

function TSigTime32.fGetWeekDay: string;
begin
	{Convert number of day into a string with day name in English}
	case SigTime.DayOfWeek of
		1: Result := 'Sunday';
		2: Result := 'Monday';
		3: Result := 'Tuesday';
		4: Result := 'Wednesday';
		5: Result := 'Thursday';
		6: Result := 'Friday';
		7: Result := 'Saturday';
	else
		Result := 'Unknown';
	end;
end;

function TSigTime32.fGetYear: Word;
begin
	Result := SigTime.Year;
end;

end.
