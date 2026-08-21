unit TimeSpinButton;

{
  version history
  v1.0.0.0       (07/09/04) Initial development
  v1.0.0.1       (08/09/04) Bug fix for assigning to value not resetting iMin or iHour
                            Bug fix for assigning Infinity value to Value not setting IsInfinity
                            Addition of LoadValue procedure for backwards compatibility in AFP tools
  v1.0.0.2       (19/06/05) Add Format capability for fixed minimum number of digits out
  v1.0.0.3       (07/10/05) Add InfinityText property to allow infinity to be represented by values other than '--'
  v1.0.0.4       (18/04/07) Add IsInfinityAllowed property to allow infinity to be available
}

interface

uses
  SysUtils, Classes, Controls, Spin, Windows;

type tTimeSpinButtonFormat = ( tsbS, tsbSS, tsbM_SS, tsbMM_SS, tsbH_MM_SS, tsbHH_MM_SS );

type
  TTimeSpinButton = class(TSpinEdit)
  private
    fOnChange: tNotifyEvent;
    procedure fOnChangeFirst( Sender : tObject );
    { Private declarations }
  protected
    { Protected declarations }
    fHour : LongInt;
    fMin : LongInt;
    fSec : LongInt;

    fInfinity : LongInt;  // value to return if at Infinity
    fIsInfinity : boolean;

    fMaxVal : LongInt;
    fMinVal : LongInt;

    fFormat : tTimeSpinButtonFormat;

    fInfinityText : string;

    fInfinityAllowed : boolean;

    function GetValue: LongInt;
    procedure SetValue (NewVal: LongInt);
    function GetSec: LongInt;
    procedure SetSec (NewVal: LongInt);
    function GetMin: LongInt;
    procedure SetMin (NewVal: LongInt);
    function GetHour: LongInt;
    procedure SetHour (NewVal: LongInt);

    procedure SetIsInfinity (NewVal: Boolean);

    function GetMaxVal: string;
    procedure SetMaxVal (NewVal: string);
    function GetMinVal: string;
    procedure SetMinVal (NewVal: string);

    procedure SetFormat( NewVal : tTimeSpinButtonFormat );

    procedure SetText;

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
             read GetValue
             write SetValue default 0;
    property Seconds : LongInt
             read GetSec
             write SetSec default 0;
    property Minutes : LongInt
             read GetMin
             write SetMin default 0;
    property Hours : LongInt
             read GetHour
             write SetHour default 0;
    property IsInfinity : boolean
             read fIsInfinity
             write SetIsInfinity default FALSE;
    property Infinity : LongInt
             read fInfinity
             write fInfinity default -1;
    property Increment; // use parent increment
    property MaxValue : string
             read GetMaxVal
             write SetMaxVal;
    property MinValue : string
             read GetMinVal
             write SetMinVal;
    property Format : tTimeSpinButtonFormat
             read fFormat
             write SetFormat default tsbMM_SS;
    property InfinityText : string
             read fInfinityText
             write fInfinityText;
    property IsInfinityAllowed : boolean
             read fInfinityAllowed
             write fInfinityAllowed default TRUE;
    property OnChange : tNotifyEvent
             read fOnChange
             write fOnChange;
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
  fInfinityText := '--';
  fInfinityAllowed := TRUE;
  inherited OnChange := fOnChangeFirst;
end;

procedure TTimeSpinButton.LoadValue( const NewVal : LongInt );
begin
  Value := NewVal;
end;

function TTimeSpinButton.GetValue: LongInt;
begin
  if IsInfinity then
  begin
    Result := fInfinity;
  end
  else
  begin
    Result := 3600 * fHour + 60 * fMin + fSec;
  end;
end;

procedure TTimeSpinButton.fOnChangeFirst(Sender: tObject);
var
  iVal : integer;
begin
  if SameText( Text, fInfinityText ) or (Text = '--') then
  begin
    fIsInfinity := TRUE;
    if assigned( fOnChange ) then
    begin
      fOnChange( sender );
    end;
  end
  else
  begin
  try
    iVal := DecodeText( Text );
    if iVal >= 0 then
    begin
      fIsInfinity := FALSE;
      fHour := iVal div 3600;
      dec( iVal, fHour * 3600 );
      fMin := iVal div 60;
      fSec := iVal - 60 * fMin;
    end;
    if assigned( fOnChange ) then
    begin
      fOnChange( sender );
    end;
  except;
  end;
  end;
end;

procedure TTimeSpinButton.SetValue (NewVal: LongInt);
begin
  if Value <> NewVal then
  begin
    if NewVal = Infinity then
    begin
      IsInfinity := TRUE;
    end
    else
    begin
      fHour := 0;
      fMin := 0;
      Seconds := NewVal;
    end;
  end;
end;

function TTimeSpinButton.GetSec : LongInt;
begin
  Result := fSec;
end;

procedure TTimeSpinButton.SetSec (NewVal: LongInt);
begin
  fIsInfinity := FALSE;
  fSec := NewVal mod 60;
  if NewVal >= 60 then
  begin
    Minutes := NewVal div 60;
  end;
  SetText;
end;

procedure TTimeSpinButton.SetIsInfinity (NewVal: Boolean);
begin
  fIsInfinity := NewVal;
  SetText;
end;

function TTimeSpinButton.GetMin : LongInt;
begin
  Result := fMin;
end;

procedure TTimeSpinButton.SetMin (NewVal: LongInt);
begin
  fMin := NewVal mod 60;
  if NewVal >= 60 then
  begin
    Hours := NewVal div 60;
  end;
  SetText;
end;

function TTimeSpinButton.GetHour : LongInt;
begin
  Result := fHour;
end;

procedure TTimeSpinButton.SetHour (NewVal: LongInt);
begin
  fHour := NewVal;  // might go on to days later!
  SetText;
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

function TTimeSpinButton.GetMaxVal: string;
begin
  Result := EncodeText( fFormat, fMaxVal );
end;

procedure TTimeSpinButton.SetMaxVal (NewVal: string);
begin
  fMaxVal := DecodeText( NewVal );
end;

function TTimeSpinButton.GetMinVal: string;
begin
  Result := EncodeText( fFormat, fMinVal );
end;

procedure TTimeSpinButton.SetMinVal (NewVal: string);
begin
  fMinVal := DecodeText( NewVal );
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
  if fIsInfinity then
  begin
    Value := fMinVal;
  end
  else
  begin
    Value := Value + Increment;
    if Value > fMaxVal then
      if IsInfinityAllowed = TRUE then
        IsInfinity := TRUE
      else
        Value := fMinVal;
  end;
end;

procedure TTimeSpinButton.DownClick (Sender: TObject);
begin
  if fIsInfinity then
  begin
    Value := fMaxVal;
  end
  else
  begin
    Value := Value - Increment;
    if Value < fMinVal then
      if IsInfinityAllowed = TRUE then
        IsInfinity := TRUE
      else
        Value := fMaxVal;
  end;
end;

procedure TTimeSpinButton.SetText;
begin
  if IsInfinity then Text := InfinityText
  else Text := EncodeText( fFormat, Value );
end;

procedure TTimeSpinButton.fUpdate;
var
  iTestValue : LongInt;
begin
  if SameText( Text, '--' ) then
  begin
    if IsInfinityAllowed = TRUE then
      IsInfinity := TRUE;
  end
  else if SameText( Text, InfinityText ) then
  begin
    if IsInfinityAllowed = TRUE then
      IsInfinity := TRUE;
  end
  else
  begin
    iTestValue := DecodeText( Text );
    if (iTestValue >= fMinVal ) and ( iTestValue <= fMaxVal ) then
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

procedure TTimeSpinButton.SetFormat( NewVal : tTimeSpinButtonFormat );
begin
  if fFormat <> NewVal then
  begin
    fFormat :=  NewVal;
    SetText;
  end;
end;

end.
