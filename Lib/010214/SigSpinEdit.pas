unit SigSpinEdit;

{ Spin edit that is restricted to values within range }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  TSigSpinEdit = class(TSpinEdit)
  private
    { Private declarations }
    function fIsValid : boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    property IsValid : boolean
             read fIsValid;  // True if the current contents of the Edit box are valid
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigSpinEdit]);
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
      if V < MinValue then Result := FALSE
      else if V > MaxValue then Result := FALSE
      else Result := TRUE;
    except
      Result := FALSE;
    end;
  end;
end;

end.
