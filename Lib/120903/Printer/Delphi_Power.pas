unit Delphi_Power;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ShellAPI;

const
   DEF_URL = 'http://www.borland.com/delphi/';

type
   TDelphi_Power = class(TImage)
   protected
      FCanClick   : boolean;
      FURL        : string;
      procedure   SetCanClick(Value: boolean);
      procedure   MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
   public
      constructor Create(AOwner: TComponent); override;
   published
      property    CanClick: boolean read FCanClick write SetCanClick;
      property    JumpURL: string read FURL write FURL;
   end;

procedure Register;

implementation

{$R Delphi_Power_BMP.res}

procedure Register;
begin
  RegisterComponents('Samples', [TDelphi_Power]);
end;


// **********************************************************************
// TDelphi_Power

constructor TDelphi_Power.Create(AOwner: TComponent);
var
   bm : TBitmap;
begin
   inherited;

   FCanClick := True;
   Cursor    := crHandPoint;
   FURL      := DEF_URL;
   AutoSize  := True;
   Hint      := DEF_URL;
   ShowHint  := True;

   bm := TBitmap.Create;
   bm.Handle := LoadBitmap(hInstance, 'DELPHI_POWER');
   Picture.Graphic := bm;
   bm.Free;
end;

procedure TDelphi_Power.SetCanClick(Value: boolean);
begin
   FCanClick := Value;

   if CanClick then Cursor := crHandPoint
      else Cursor := crDefault;
end;

procedure TDelphi_Power.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   rc : integer;
begin
   inherited;
   rc := ShellExecute(0, 'open', PChar(FURL), nil, nil, SW_SHOWNORMAL);
   if rc <= 32 then
      raise Exception.CreateFmt('ShellExecute "%s" Failed with Error: %d', [FURL, rc]);
end;


end.
