unit TimeSpinButton;

{
  version history
  v1.0.0.0       (07/09/04) Initial development
  v1.0.0.1       (08/09/04) Bug fix for assigning to value not resetting iMin or iHour
                            Bug fix for assigning Infinity value to Value not setting IsInfinity
                            Addition of LoadValue procedure for backwards compatibility in AFP tools
  v1.0.0.2       (19/06/05) Add Format capability for fixed minimum number of digits out
  v1.0.0.3       (07/10/05) Add InfinityText property to allow infinity to be represented by values other than '--'
}

interface

uses
  SysUtils, Classes, Controls, Spin, Windows;

type tTimeSpinButtonFormat = ( tsbS, tsbSS, tsbM_SS, tsbMM_SS, tsbH_MM_SS, tsbHH_MM_SS );

type
  TTimeSpinButton = class(TSpinEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
    iHour : LongInt;
    iMin : LongInt;
    iSec : LongInt;

    iInfinity : LongInt;  // value to return if at Infinity
    iIsInfinity : boolean;

    iMaxVal : LongInt;
    iMinVal : LongInt;

    iFormat : tTimeSpinButtonFormat;

    iInfinityText : string;

    function fGetValue: LongInt;
    procedure fSetValue (NewVal: LongInt);
    function fGetSec: LongInt;
    procedure fSetSec (NewVal: LongInt);
    function fGetMin: LongInt;
    procedure fSetMin (NewVal: LongInt);
    function fGetHour: LongInt;
    procedure fSetHour (NewVal: LongInt);

    procedure fSetIsInfinity (NewVal: Boolean);

    function fGetMaxVal: string;
    procedure fSetMaxVal (NewVal: string);
    function fGetMinVal: string;
    procedure fSetMinVal (NewVal: string);

    procedure fSetFormat( NewVal : tTimeSpinButtonFormat );

    procedure fSetText;

    function IsValidChar(Key: Char): Boolean; override;
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;

    procedure KeyPress(var Key: Char); override;

    procedure fUpdate;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    class function DecodeText( const NewVal : string ) : LongInt;
    class function EncodeText( const pFormat : tTimeSpinButtonFormat; const NewVal : longint ) : string;
    procedure LoadValue( const NewVal : LongInt );
  published
    { Published declarations }
    property Value : LongInt
             read fGetValue
             write fSetValue default 0;
    property Seconds : LongInt
             read fGetSec
             write fSetSec default 0;
    property Minutes : LongInt
             read fGetMin
             write fSetMin default 0;
    property Hours : LongInt
             read fGetHour
             write fSetHour default 0;
    property IsInfinity : boolean
             read iIsInfinity
             write fSetIsInfinity default FALSE;
    property Infinity : LongInt
             read iInfinity
             write iInfinity default -1;
    property Increment; // use parent increment
    property MaxValue : string
             read fGetMaxVal
             write fSetMaxVal;
    property MinValue : string
             read fGetMinVal
             write fSetMinVal;
    property Format : tTimeSpinButtonFormat
             read iFormat
             write fSetFormat default tsbMM_SS;
    property InfinityText : string
             read iInfinityText
             write iInfinityText;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TTimeSpinButton]);
end;

constructor TTimeSpinButton.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  Value := 0;
  Format := tsbMM_SS;
  IsInfinity := FALSE;
  Infinity := -1;
  MaxValue := '01:00';
  MinValue := '0';
  iInfinityText := '--';
end;

procedure TTimeSpinButton.LoadValue( const NewVal : LongInt );
begin
  Value := NewVal;
end;

function TTimeSpinButton.fGetValue: LongInt;
begin
  if IsInfinity then Result := iInfinity
  else Result := 3600 * iHour + 60 * iMin + iSec;
end;

procedure TTimeSpinButton.fSetValue (NewVal: LongInt);
begin
  if NewVal = Infinity then
  begin
    IsInfinity := TRUE;
  end
  else
  begin
    iHour := 0;
    iMin := 0;
    Seconds := NewVal;
  end;
end;

function TTimeSpinButton.fGetSec : LongInt;
begin
  Result := iSec;
end;

procedure TTimeSpinButton.fSetSec (NewVal: LongInt);
begin
  iIsInfinity := FALSE;
  iSec := NewVal mod 60;
  if NewVal >= 60 then
  begin
    Minutes := NewVal div 60;
  end;
  fSetText;
end;

procedure TTimeSpinButton.fSetIsInfinity (NewVal: Boolean);
begin
  iIsInfinity := NewVal;
  fSetText;
end;

function TTimeSpinButton.fGetMin : LongInt;
begin
  Result := iMin;
end;

procedure TTimeSpinButton.fSetMin (NewVal: LongInt);
begin
  iMin := NewVal mod 60;
  if NewVal >= 60 then
  begin
    Hours := NewVal div 60;
  end;
  fSetText;
end;

function TTimeSpinButton.fGetHour : LongInt;
begin
  Result := iHour;
end;

procedure TTimeSpinButton.fSetHour (NewVal: LongInt);
begin
  iHour := NewVal;  // might go on to days later!
  fSetText;
end;

class function TTimeSpinButton.DecodeText( const NewVal : string ) : LongInt;
var
  tempHour, TempMin, TempSec : LongInt;
  i : integer;
begin
  tempHour := 0;
  tempMin := 0;
  tempSec := 0;
  // assume seconds only
  for i := 1 to Length( NewVal ) do
  begin
    case NewVal[ i ] of
      '0'..'9':
      begin
        tempSec := 10 * TempSec + Ord( NewVal[ i ] ) - Ord( '0' );
      end;
      ':':
      begin
        tempHour := tempMin;
        tempMin := tempSec;
        tempSec := 0;
      end;
      #0..' ': // ignore spaces
      begin
      end;
      else // illegal char - ignore whole entry
      begin
        raise exception.Create('Illegal Value');
      end;
    end;
  end;
  // if we get here we have a (semi) legal time
  // note that we allow things like 64:05 (and indeed 66: 108 )
  // because we might want to add 120:00 for example
  result := 3600 * tempHour + 60 * tempMin + tempSec;
end;

class function TTimeSpinButton.EncodeText( const pFormat : tTimeSpinButtonFormat; const NewVal : longint ) : string;
begin

  if NewVal >= 360000 then
  begin
    Result := SysUtils.Format( '%d:%2.2u:%2.2u', [ NewVal div 3600, (NewVal mod 3600) div 60, NewVal mod 60 ] );
  end
  else if NewVal >= 3600 then
  begin
    case pFormat of
      tsbHH_MM_SS:
        Result := SysUtils.Format( '%2.2u:%2.2u:%2.2u', [ NewVal div 3600, (NewVal mod 3600) div 60, NewVal mod 60 ] );
      else
        Result := SysUtils.Format( '%d:%2.2u:%2.2u', [ NewVal div 3600, (NewVal mod 3600) div 60, NewVal mod 60 ] );
    end;
  end
  else if NewVal >= 60 then
  begin
    case pFormat of
      tsbHH_MM_SS:
        Result := SysUtils.Format( '00:%2.2u:%2.2u', [ NewVal div 60, NewVal mod 60 ] );
      tsbH_MM_SS:
        Result := SysUtils.Format( '0:%2.2u:%2.2u', [ NewVal div 60, NewVal mod 60 ] );
      tsbMM_SS:
        Result := SysUtils.Format( '%2.2u:%2.2u', [ NewVal div 60, NewVal mod 60 ] );
      else
        Result := SysUtils.Format( '%d:%2.2u', [ NewVal div 60, NewVal mod 60 ] );
    end;
  end
  else
  begin
    case pFormat of
      tsbHH_MM_SS:
        Result := SysUtils.Format( '00:00:%2.2u', [ NewVal ] );
      tsbH_MM_SS:
        Result := SysUtils.Format( '0:00:%2.2u', [ NewVal ] );
      tsbMM_SS:
        Result := SysUtils.Format( '00:%2.2u', [ NewVal ] );
      tsbM_SS:
        Result := SysUtils.Format( '0:%2.2u', [ NewVal ] );
      tsbSS:
        Result := SysUtils.Format( '%2.2u', [ NewVal ] );
      else
        Result := IntToStr( NewVal );
    end;
  end;
end;

function TTimeSpinButton.fGetMaxVal: string;
begin
  Result := EncodeText( iFormat, iMaxVal );
end;

procedure TTimeSpinButton.fSetMaxVal (NewVal: string);
begin
  iMaxVal := DecodeText( NewVal );
end;

function TTimeSpinButton.fGetMinVal: string;
begin
  Result := EncodeText( iFormat, iMinVal );
end;

procedure TTimeSpinButton.fSetMinVal (NewVal: string);
begin
  iMinVal := DecodeText( NewVal );
end;

function TTimeSpinButton.IsValidChar(Key: Char): Boolean;
begin
  case Key of
    '0'..'9',':',' ','-': Result := TRUE;
    else
    begin
      if EditorEnabled and (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE)) then Result := TRUE
      else Result := FALSE;
    end;
  end;
end;

procedure TTimeSpinButton.UpClick (Sender: TObject);
begin
  if iIsInfinity then
  begin
    Value := iMinVal;
  end
  else
  begin
    Value := Value + Increment;
    if Value > iMaxVal then IsInfinity := TRUE;
  end;
end;

procedure TTimeSpinButton.DownClick (Sender: TObject);
begin
  if iIsInfinity then
  begin
    Value := iMaxVal;
  end
  else
  begin
    Value := Value - Increment;
    if Value < iMinVal then IsInfinity := TRUE;
  end;
end;

procedure TTimeSpinButton.fSetText;
begin
  if IsInfinity then Text := InfinityText
  else Text := EncodeText( iFormat, Value );
end;

procedure TTimeSpinButton.fUpdate;
var
  iTestValue : LongInt;
begin
  if SameText( Text, '--' ) then
  begin
    IsInfinity := TRUE;
  end
  else if SameText( Text, InfinityText ) then
  begin
    IsInfinity := TRUE;
  end
  else
  begin
    iTestValue := DecodeText( Text );
    if (iTestValue >= iMinVal ) and ( iTestValue <= iMaxVal ) then
    begin
      Value := iTestValue;
    end
    else
    begin
      raise exception.Create( 'Range Error ' );
    end;
  end;
end;

procedure TTimeSpinButton.KeyPress(var Key: Char);
begin
  if Key = Chr(VK_RETURN) then
  begin
    fUpdate;
    Key := #0;
  end
  else
  begin
    inherited KeyPress(Key);
  end;
end;

procedure TTimeSpinButton.CMExit(var Message: TCMExit);
begin
//  inherited;
  fUpdate;
end;

procedure TTimeSpinButton.fSetFormat( NewVal : tTimeSpinButtonFormat );
begin
  if iFormat <> NewVal then
  begin
    iFormat :=  NewVal;
    fSetText;
  end;
end;

end.
