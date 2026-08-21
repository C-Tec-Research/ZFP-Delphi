unit Sigtime;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TSigTIME_Data = Record
  Year, Month, Day : Word;
  Hour, Minute, Second, Millisecond : Word;
end;

type
  TSigTIME_DataEx = Record
  Year, Month, Day : Word;
  Hour, Minute, Second, Millisecond : Word;
  Status : Word;
end;

type
  TSigTIME = class(TComponent)
  private
    { Private declarations }
    iData : TSigTIME_Data;
    iStatus : Word;
    function fGetSigTimeData : TSigTIME_Data;
    function fGetSigTimeDataEx : TSigTIME_DataEx;
    function fGetSigTIMEStatus : Word;
  protected
    { Protected declarations }
  public
    { Public declarations }
    property TimeNow : TSigTIME_Data
             read fGetSigTimeData;
    property TimeNowEx : TSigTIME_DataEx
             read fGetSigTimeDataEx;
    property Status : Word
             read fGetSigTimeStatus;
  published
    { Published declarations }
  end;

procedure Register;

implementation

{ Link to SigTIME DLL }

function GetSigTIME( var data : TSigTIME_Data ) : Word;
         far; external 'SigTIME';

function TSigTIME.fGetSigTimeData : TSigTIME_Data;
begin
  iStatus := GetSigTIME( iData );
  Result := iData;
end;

function TSigTIME.fGetSigTimeDataEx : TSigTIME_DataEx;
begin
  iStatus := GetSigTIME( iData );
  Result.Year := iData.Year;
  Result.Month := iData.Month;
  Result.Day := iData.Day;
  Result.Hour := iData.Hour;
  Result.Minute := iData.Minute;
  Result.Second := iData.Second;
  Result.Millisecond := iData.Millisecond;
  Result.Status := iStatus;
end;

function TSigTIME.fGetSigTIMEStatus : Word;
begin
  iStatus := GetSigTIME( iData );
  Result := iStatus;
end;

procedure Register;
begin
  RegisterComponents('SigNET', [TSigTIME]);
end;

end.
