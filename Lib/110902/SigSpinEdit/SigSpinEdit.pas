unit SigSpinEdit;

{ Spin edit that is restricted to values within range }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  TSigSpinEdit = class(TSpinEdit)
  private
    fNormalFont: tFont;
    fErrorFont: tFont;
    { Private declarations }
    function fIsValid : boolean;
    procedure SetReadOnly( NewVal : boolean );
    procedure SetNormalFont(const Value: tFont);
    procedure SetErrorFont(const Value: tFont);
  protected
    { Protected declarations }
    procedure Change; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property IsValid : boolean
             read fIsValid;  // True if the current contents of the Edit box are valid
  published
    { Published declarations }
    property ReadOnly
             write SetReadOnly;
    property NormalFont : tFont
             read fNormalFont
             write SetNormalFont;
    property ErrorFont : tFont
             read fErrorFont
             write SetErrorFont;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigSpinEdit]);
end;

procedure TSigSpinEdit.Change;
begin
  inherited Change;
  if IsValid then
  begin
    if assigned( fNormalFont ) then
    begin
      Font.Assign( fNormalFont );
    end;
  end
  else
  begin
    if assigned( fErrorFont ) then
    begin
      Font.Assign( fErrorFont );
    end;
  end;
end;

constructor TSigSpinEdit.Create(AOwner: TComponent);
begin
  inherited;

  fNormalFont := TFont.Create;
  fErrorFont := TFont.Create;

//  if assigned( Font ) then
//  begin
//    fNormalFont.Assign( Font );
//    fErrorFont.Assign( Font );
//  end;
end;

function TSigSpinEdit.fIsValid : boolean;
var
  V : LongInt;
begin
  { return TRUE if it is safe to Use VALUE property, or false otherwise }
  if Text = '' then
    Result := FALSE
  else
  begin
    try
      V := StrToInt( Text );
      if (MinValue = 0) and (MaxValue = 0) then Result := TRUE
      else if V < MinValue then Result := FALSE
      else if V > MaxValue then Result := FALSE
      else Result := TRUE;
    except
      Result := FALSE;
    end;
  end;
end;

procedure TSigSpinEdit.SetErrorFont(const Value: tFont);
begin
  if Value = nil then
  begin
    if Font <> nil then
    begin
      fErrorFont.Assign( Font );
    end;
  end
  else
  begin
    fErrorFont.Assign( Value );
  end;
end;

procedure TSigSpinEdit.SetNormalFont(const Value: tFont);
begin
  if Value = nil then
  begin
    if Font <> nil then
    begin
      fNormalFont.Assign( Font );
    end;
  end
  else
  begin
    fNormalFont.Assign( Value );
  end;
end;

procedure TSigSpinEdit.SetReadOnly(NewVal: boolean);
begin
  inherited ReadOnly := NewVal;
  Button.Visible := not NewVal;
end;

end.
