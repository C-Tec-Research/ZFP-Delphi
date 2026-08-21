unit UnitSigPanelEditor;

interface

{$IFDEF ALLOWINSTALL}
uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  VCL.Forms,
  //ToolsAPI,
  DesignEditors,
  DesignMenus,
  DesignIntf,
  SigPanel;

type
  TCESigPanelStyleEditor = class( TComponentEditor )
  private
    function GetPanel: TSigPanel;
    procedure AddDefaultChild( Sender : TObject );
    procedure AddBaseChild( Sender : TObject );
    procedure AddTopChild( Sender : TObject );
    procedure AddBottomChild( Sender : TObject );
    procedure AddLeftChild( Sender : TObject );
    procedure AddRightChild( Sender : TObject );
    procedure AddFillChild( Sender : TObject );
    procedure AddChild( Sender : TObject; pStyle : TSigPanelStyle );
    procedure SetDefault( Sender : TObject );
    procedure SetBase( Sender : TObject );
    procedure SetTop( Sender : TObject );
    procedure SetBottom( Sender : TObject );
    procedure SetLeft( Sender : TObject );
    procedure SetRight( Sender : TObject );
    procedure SetFill( Sender : TObject );
    procedure SetSelf( Sender : TObject; pStyle : TSigPanelStyle );
  public
    function GetVerbCount : integer; override;
    function GetVerb( Index : integer ) : string; override;
    procedure ExecuteVerb( Index : integer ); override;
    procedure PrepareItem(Index: Integer; const AItem: IMenuItem); override;

    property Panel : TSigPanel
             read GetPanel;
  end;

procedure Register;
{$ENDIF}

implementation

{ TCESigPanelStyleEditor }

{$IFDEF ALLOWINSTALL}
procedure TCESigPanelStyleEditor.AddBaseChild(Sender: TObject);
begin
  AddChild( Sender, psBase );
end;

procedure TCESigPanelStyleEditor.AddBottomChild(Sender: TObject);
begin
  AddChild( Sender, psChildBottom );
end;

procedure TCESigPanelStyleEditor.AddChild(Sender: TObject; pStyle: TSigPanelStyle);
var
  iChild : TSigPanel;
  iParentForm : TCustomForm;
begin
    iParentForm := GetParentForm( Panel, FALSE );
    if assigned( iParentForm ) then
    begin
      iChild := TSigPanel.Create( Panel.Owner );
      iChild.Name := iParentForm.Designer.UniqueName( 'SigPanel' );
      iChild.Parent := Panel;
      iChild.PanelStyle := pStyle;
    end;
end;

procedure TCESigPanelStyleEditor.AddDefaultChild(Sender: TObject);
begin
  AddChild( Sender, psDefault );
end;

procedure TCESigPanelStyleEditor.AddFillChild(Sender: TObject);
begin
  AddChild( Sender, psChildFill );
end;

procedure TCESigPanelStyleEditor.AddLeftChild(Sender: TObject);
begin
  AddChild( Sender, psChildLeft );
end;

procedure TCESigPanelStyleEditor.AddRightChild(Sender: TObject);
begin
  AddChild( Sender, psChildRight );
end;

procedure TCESigPanelStyleEditor.AddTopChild(Sender: TObject);
begin
  AddChild( Sender, psChildTop );
end;

procedure TCESigPanelStyleEditor.ExecuteVerb(Index: integer);
begin
  { because we are using submenus, we do not need to execute
    any verbs. }
  //if Index < inherited GetVerbCount() then
  //begin
    inherited;
  //end
  //else
  //begin
  //  case Index - inherited GetVerbCount() of
  //    0: Panel.PanelStyle := psDefault;
  //    1: Panel.PanelStyle := psBase;
  //    2: Panel.PanelStyle := psChildTop;
  //    3: Panel.PanelStyle := psChildBottom;
  //    4: Panel.PanelStyle := psChildFill;
  //    5: Panel.PanelStyle := psChildLeft;
  //    6: Panel.PanelStyle := psChildRight;
  //  end;
  //end;
end;

function TCESigPanelStyleEditor.GetPanel: TSigPanel;
begin
  Result := Component as TSigPanel;
end;

function TCESigPanelStyleEditor.GetVerb(Index: integer): string;
begin
  if Index < inherited GetVerbCount() then
  begin
    Result := inherited GetVerb( Index );
  end
  else
  begin
    case Index - inherited GetVerbCount() of
      0: Result := 'Panel Style';
      1: Result := 'Add Child Panel';
      else inherited GetVerb( Index );
    end;
  end;
end;

function TCESigPanelStyleEditor.GetVerbCount: integer;
begin
  Result := inherited GetVerbCount() + 2;
end;


procedure TCESigPanelStyleEditor.PrepareItem(Index: Integer;
  const AItem: IMenuItem);
begin
  inherited;
  case Index - inherited GetVerbCount() of
    0: begin
         AItem.AddItem( 'psDefault', 0, Panel.PanelStyle = psDefault, TRUE, SetDefault );
         AItem.AddItem( 'psBase', 0, Panel.PanelStyle = psBase, TRUE, SetBase );
         AItem.AddItem( 'psChildTop', 0, Panel.PanelStyle = psChildTop, TRUE, SetTop );
         AItem.AddItem( 'psChildBottom', 0, Panel.PanelStyle = psChildBottom, TRUE, SetBottom );
         AItem.AddItem( 'psChildFill', 0, Panel.PanelStyle = psChildFill, TRUE, SetFill );
         AItem.AddItem( 'psChildLeft', 0, Panel.PanelStyle = psChildLeft, TRUE, SetLeft );
         AItem.AddItem( 'psChildRight', 0, Panel.PanelStyle = psChildRight, TRUE, SetRight );
       end;
    1: begin
         AItem.AddItem( 'psDefault', 0, FALSE, TRUE, AddDefaultChild );
         AItem.AddItem( 'psBase', 0, FALSE, TRUE, AddBaseChild );
         AItem.AddItem( 'psChildTop', 0, FALSE, TRUE, AddTopChild );
         AItem.AddItem( 'psChildBottom', 0, FALSE, TRUE, AddBottomChild );
         AItem.AddItem( 'psChildFill', 0, FALSE, TRUE, AddFillChild );
         AItem.AddItem( 'psChildLeft', 0, FALSE, TRUE, AddLeftChild );
         AItem.AddItem( 'psChildRight', 0, FALSE, TRUE, AddRightChild );
       end;
  end;
end;

procedure TCESigPanelStyleEditor.SetBase(Sender: TObject);
begin
  SetSelf( Sender, psBase );
end;

procedure TCESigPanelStyleEditor.SetBottom(Sender: TObject);
begin
  SetSelf( Sender, psChildBottom );
end;

procedure TCESigPanelStyleEditor.SetDefault(Sender: TObject);
begin
  SetSelf( Sender, psDefault );
end;

procedure TCESigPanelStyleEditor.SetFill(Sender: TObject);
begin
  SetSelf( Sender, psChildFill );
end;

procedure TCESigPanelStyleEditor.SetLeft(Sender: TObject);
begin
  SetSelf( Sender, psChildLeft );
end;

procedure TCESigPanelStyleEditor.SetRight(Sender: TObject);
begin
  SetSelf( Sender, psChildRight );
end;

procedure TCESigPanelStyleEditor.SetSelf(Sender: TObject;
  pStyle: TSigPanelStyle);
begin
  Panel.PanelStyle := pStyle;
end;

procedure TCESigPanelStyleEditor.SetTop(Sender: TObject);
begin
  SetSelf( Sender, psChildTop );
end;

procedure Register;
begin
  RegisterComponentEditor( TSigPanel, TCESigPanelStyleEditor );
end;
{$ENDIF}

end.
