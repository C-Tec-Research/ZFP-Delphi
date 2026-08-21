unit LCDEdit;

interface

uses
  SysUtils, Classes, Controls, Grids,
  Graphics;

type
  TLCDEdit = class(TStringGrid)
  private
    fEnabledColour: TColor;
    fDisabledColour: TColor;
    fEnabledFontColour: TColor;
    fDisabledFontColour: TColor;
    procedure SetEnabledColour(const Value: TColor);
    procedure SetDisabledColour(const Value: TColor);
    procedure SetEnabledFontColour(const Value: TColor);
    procedure SetDisabledFontColour(const Value: TColor);
    function GetText(const Line: integer): string;
    procedure SetText(const Line: integer; const Value: string);
    function GetTopLine: string;
    procedure SetTopLine(const Value: string);
    { Private declarations }
  protected
    { Protected declarations }
    procedure SetEnabled(Value: Boolean); override;
    procedure fActionKey( Sender : TObject; var Key : char );
  public
    { Public declarations }
    property Text[ const Line : integer ] : string
             read GetText
             write SetText;
  published
    { Published declarations }
    constructor Create( AOwner : TComponent ); override;
    destructor Destroy; override;
    property FixedRows
             default 0;
    property FixedCols
             default 0;
    property RowCount
             default 2;
    property ColCount
             default 20;
    property DefaultColWidth
             default 18;
    property EnabledBGColour : TColor
             read fEnabledColour
             write SetEnabledColour
             default clBlack;
    property DisabledBGColour : TColor
             read fDisabledColour
             write SetDisabledColour
             default clSilver;
    property EnabledFGColour : TColor
             read fEnabledFontColour
             write SetEnabledFontColour
             default clLime;
    property DisabledFGColour : TColor
             read fDisabledFontColour
             write SetDisabledFontColour
             default clGray;
    property TopLine : string
             read GetTopLine
             write SetTopLine;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TLCDEdit]);
end;

{ TLCDEdit }

constructor TLCDEdit.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  FixedRows := 0;
  FixedCols := 0;
  RowCount := 2;
  ColCount := 20;
  DefaultColWidth := 18;
  EnabledBGColour := clBlack;
  DisabledBGColour := clSilver;
  EnabledFGColour := clLime;
  DisabledFGColour := clGray;
  Font.Name := 'Courier New';
end;

destructor TLCDEdit.Destroy;
begin
  inherited;
end;

function TLCDEdit.GetText(const Line: integer): string;
var
  i: Integer;
begin
  if Line >= RowCount then
  begin
    Result := '';
  end
  else
  begin
    Result := '';
    for i := 0 to ColCount - 1 do
    begin
      if Cells[ i, Line ] = '' then
      begin
        Result := Result + ' ';
      end
      else
      begin
        Result := Result + Cells[ i, Line ];
      end;
    end;
  end;
end;

function TLCDEdit.GetTopLine: string;
begin
  Result := Text[ 0 ];
end;

procedure TLCDEdit.SetDisabledColour(const Value: TColor);
begin
  fDisabledColour := Value;
  if not Enabled then
  begin
    Color := Value;
  end;
end;

procedure TLCDEdit.SetDisabledFontColour(const Value: TColor);
begin
  fDisabledFontColour := Value;
  if not Enabled then
  begin
    Font.Color := Value;
  end;
end;

procedure TLCDEdit.SetEnabled(Value: Boolean);
begin
  inherited;
  if Value then
  begin
    Color := EnabledBGColour;
    Font.Color := EnabledFGColour;
  end
  else
  begin
    Color := DisabledBGColour;
    Font.Color := DisabledFGColour;
  end;
end;

procedure TLCDEdit.SetEnabledColour(const Value: TColor);
begin
  fEnabledColour := Value;
  if Enabled then
  begin
    Color := Value;
  end;
end;

procedure TLCDEdit.SetEnabledFontColour(const Value: TColor);
begin
  fEnabledFontColour := Value;
  if Enabled then
  begin
    Font.Color := Value;
  end;
end;

procedure TLCDEdit.SetText(const Line: integer; const Value: string);
var
  i: Integer;
begin
  for i := 1 to ColCount do
  begin
    Cells[ i - 1, Line ] := Value[ i ];
  end;
end;

procedure TLCDEdit.SetTopLine(const Value: string);
begin
  Text[ 0 ] := Value;
end;

end.
