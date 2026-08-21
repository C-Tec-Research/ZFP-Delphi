unit SigPanel;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls;

  {Like a normal panel but different defaults}
type
  TSigPanelStyle = (psDefault, psBase, psChildTop, psChildBottom, psChildFill,
                    psChildLeft, psChildRight );

  TSigPanel = class(TPanel)
  private
    fPanelStyle: tSigPanelStyle;
    procedure SetPanelStyle(const Value: tSigPanelStyle);
    function GetBevelOuter: TPanelBevel;
    function GetParentBackground: boolean;
    function GetShowCaption: boolean;
    procedure SetBevelOuter(const Value: TPanelBevel);
    procedure SetShowCaption(const Value: boolean);
    function GetAlign: TAlign;
    procedure SetAlign(const Value: TAlign);
    { Private declarations }
  protected
    { Protected declarations }
    procedure SetParentBackground(Value: Boolean); override;
  public
    { Public declarations }
  published
    { Published declarations }
    constructor Create(AOwner: TComponent); override;

    property Align : TAlign
             read GetAlign
             write SetAlign;
    property ShowCaption : boolean
             read GetShowCaption
             write SetShowCaption
             default FALSE;
    property ParentBackground : boolean
             read GetParentBackground
             write SetParentBackground
             default FALSE;
    property BevelOuter : TPanelBevel
             read GetBevelOuter
             write SetBevelOuter
             default bvLowered;
    property PanelStyle : tSigPanelStyle
             read fPanelStyle
             write SetPanelStyle
             default psDefault;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TSigPanel]);
end;
{$ENDIF}

{ TSigPanel }

constructor TSigPanel.Create(AOwner: TComponent);
begin
  inherited;

  ShowCaption := FALSE;
  ParentBackground := FALSE;
  BevelOuter := bvLowered;

  PanelStyle := psDefault;
end;

function TSigPanel.GetAlign: TAlign;
begin
  Result := inherited Align;
end;

function TSigPanel.GetBevelOuter: TPanelBevel;
begin
  Result := inherited BevelOuter;
end;

function TSigPanel.GetParentBackground: boolean;
begin
  Result := inherited ParentBackground;
end;

function TSigPanel.GetShowCaption: boolean;
begin
  Result := inherited ShowCaption;
end;

procedure TSigPanel.SetAlign(const Value: TAlign);
begin
  inherited Align := Value;
  fPanelStyle := psDefault;
end;

procedure TSigPanel.SetBevelOuter(const Value: TPanelBevel);
begin
  inherited BevelOuter := Value;
  fPanelStyle := psDefault;
end;

procedure TSigPanel.SetPanelStyle(const Value: tSigPanelStyle);
begin
  fPanelStyle := Value;

  case fPanelStyle of
    psDefault: ;
    psBase:
    begin
      inherited BevelOuter := bvLowered;
      Align := alClient;
    end;
    psChildTop:
    begin
      if Parent is TPanel then
      begin
        case (Parent as TPanel).BevelOuter of
          bvNone:    inherited BevelOuter := bvLowered;
          bvLowered: inherited BevelOuter := bvRaised;
          bvRaised:  inherited BevelOuter := bvLowered;
          bvSpace:   inherited BevelOuter := bvLowered;
        end;
      end
      else
      begin
        inherited BevelOuter := bvLowered;
      end;
      inherited Align := alTop;
    end;
    psChildBottom:
    begin
      if Parent is TPanel then
      begin
        case (Parent as TPanel).BevelOuter of
          bvNone:    inherited BevelOuter := bvLowered;
          bvLowered: inherited BevelOuter := bvRaised;
          bvRaised:  inherited BevelOuter := bvLowered;
          bvSpace:   inherited BevelOuter := bvLowered;
        end;
      end
      else
      begin
        inherited BevelOuter := bvLowered;
      end;
      inherited Align := alBottom;
    end;
    psChildFill:
    begin
      if Parent is TPanel then
      begin
        case (Parent as TPanel).BevelOuter of
          bvNone:    inherited BevelOuter := bvLowered;
          bvLowered: inherited BevelOuter := bvRaised;
          bvRaised:  inherited BevelOuter := bvLowered;
          bvSpace:   inherited BevelOuter := bvLowered;
        end;
      end
      else
      begin
        inherited BevelOuter := bvLowered;
      end;
      inherited Align := alClient;
    end;
    psChildLeft:
    begin
      if Parent is TPanel then
      begin
        case (Parent as TPanel).BevelOuter of
          bvNone:    inherited BevelOuter := bvLowered;
          bvLowered: inherited BevelOuter := bvRaised;
          bvRaised:  inherited BevelOuter := bvLowered;
          bvSpace:   inherited BevelOuter := bvLowered;
        end;
      end
      else
      begin
        inherited BevelOuter := bvLowered;
      end;
      inherited Align := alLeft;
    end;
    psChildRight:
    begin
      if Parent is TPanel then
      begin
        case (Parent as TPanel).BevelOuter of
          bvNone:    inherited BevelOuter := bvLowered;
          bvLowered: inherited BevelOuter := bvRaised;
          bvRaised:  inherited BevelOuter := bvLowered;
          bvSpace:   inherited BevelOuter := bvLowered;
        end;
      end
      else
      begin
        inherited BevelOuter := bvLowered;
      end;
      inherited Align := alRight;
    end;
  end;
end;

procedure TSigPanel.SetParentBackground(Value: Boolean);
begin
  inherited;
end;

procedure TSigPanel.SetShowCaption(const Value: boolean);
begin
  inherited ShowCaption := Value;
end;

end.
