unit UnitSigComponentEditor;

interface

{$IFDEF ALLOWINSTALL}
uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Forms,
  SigPanel,
  UnitFormChangeName,
  DesignEditors,
  DesignMenus,
  DesignIntf;

type
  TCESigComponentEditor = class( TComponentEditor )
  private
    function GetControl: TWinControl;
    procedure AddDefaultChild( Sender : TObject );
    procedure AddBaseChild( Sender : TObject );
    procedure AddTopChild( Sender : TObject );
    procedure AddBottomChild( Sender : TObject );
    procedure AddLeftChild( Sender : TObject );
    procedure AddRightChild( Sender : TObject );
    procedure AddFillChild( Sender : TObject );
    procedure AddChild( Sender : TObject; pStyle : TSigPanelStyle );
    procedure SetNone( Sender : TObject );
    procedure SetTop( Sender : TObject );
    procedure SetBottom( Sender : TObject );
    procedure SetLeft( Sender : TObject );
    procedure SetRight( Sender : TObject );
    procedure SetClient( Sender : TObject );
    procedure SetSelf( Sender : TObject; pAlign : TAlign );
  public
    function GetVerbCount : integer; override;
    function GetVerb( Index : integer ) : string; override;
    procedure ExecuteVerb( Index : integer ); override;
    procedure PrepareItem(Index: Integer; const AItem: IMenuItem); override;

    property Control : TWinControl
             read GetControl;
    procedure ChangeName;

  end;

procedure Register;
{$ENDIF}

implementation

{ TCESigPanelStyleEditor }

{$IFDEF ALLOWINSTALL}
procedure TCESigComponentEditor.AddBaseChild(Sender: TObject);
begin
  AddChild( Sender, psBase );
end;

procedure TCESigComponentEditor.AddBottomChild(Sender: TObject);
begin
  AddChild( Sender, psChildBottom );
end;

procedure TCESigComponentEditor.AddChild(Sender: TObject;
  pStyle: TSigPanelStyle);
var
  iChild : TSigPanel;
  iParentForm : TCustomForm;
begin
    iParentForm := GetParentForm( Control, FALSE );
    if assigned( iParentForm ) then
    begin
      iChild := TSigPanel.Create( Control.Owner );
      iChild.Name := iParentForm.Designer.UniqueName( 'SigPanel' );
      iChild.Parent := Control;
      iChild.PanelStyle := pStyle;
    end;
end;

procedure TCESigComponentEditor.AddDefaultChild(Sender: TObject);
begin
  AddChild( Sender, psDefault );
end;

procedure TCESigComponentEditor.AddFillChild(Sender: TObject);
begin
  AddChild( Sender, psChildFill );
end;

procedure TCESigComponentEditor.AddLeftChild(Sender: TObject);
begin
  AddChild( Sender, psChildLeft );
end;

procedure TCESigComponentEditor.AddRightChild(Sender: TObject);
begin
  AddChild( Sender, psChildRight );
end;

procedure TCESigComponentEditor.AddTopChild(Sender: TObject);
begin
  AddChild( Sender, psChildTop );
end;

procedure TCESigComponentEditor.ChangeName;
var
  iParentForm : TCustomForm;
begin
  if not assigned( FormName ) then
  begin
//    iParentForm := GetParentForm( Control, FALSE );
    iParentForm := nil;
    FormName := TFormName.Create( iParentForm );
  end;
  try
    FormName.Top := Control.Top;
    FormName.Left := Control.Left;
    Control.Name := FormName.Execute( Control.Name, Control.ClassName );
    Designer.Modified;
  finally
    FreeAndNil( FormName );
  end;
end;

procedure TCESigComponentEditor.ExecuteVerb(Index: integer);
begin
  case Index - inherited GetVerbCount() of
    0: ChangeName;
    else inherited;
  end;
  {
  if Component is TSigPanel then
  begin
    inherited;
  end
  else   if Index < inherited GetVerbCount() then
  begin
    inherited;
  end
  else
  begin
    case Index - inherited GetVerbCount() of
      0: Control.Align := alNone;
      1: Control.Align := alTop;
      2: Control.Align := alBottom;
      3: Control.Align := alLeft;
      4: Control.Align := alRight;
      5: Control.Align := alClient;
    end;
  end;
  }
end;

function TCESigComponentEditor.GetControl: TWinControl;
begin
  Result := Component as TWinControl;
end;

function TCESigComponentEditor.GetVerb(Index: integer): string;
begin
  if Index < inherited GetVerbCount() then
  begin
    Result := inherited GetVerb( Index );
  end
  else
  begin
    if IsPublishedProp( Control, 'Align' ) then
    begin
      case Index - inherited GetVerbCount() of
        0: Result := 'Rename';
        1: Result := 'Align';
        2: Result := 'Add Child Panel';
        else inherited GetVerb( Index );
      end;
    end
    else
    begin
      case Index - inherited GetVerbCount() of
        0: Result := 'Rename';
        1: Result := 'Add Child Panel';
        else inherited GetVerb( Index );
      end;
    end;
  end;
  {
  if Component is TSigPanel then
  begin
    Result := inherited GetVerb( Index );
  end
  else if Index < inherited GetVerbCount() then
  begin
    Result := inherited GetVerb( Index );
  end
  else
  begin
    case Index - inherited GetVerbCount() of
      0: Result := 'None';
      1: Result := 'Top';
      2: Result := 'Bottom';
      3: Result := 'Left';
      4: Result := 'Right';
      5: Result := 'Client';
      else Result := 'no change';
    end;
    Result := 'Align to ' + Result;
  end;
  }
end;

function TCESigComponentEditor.GetVerbCount: integer;
begin
  if IsPublishedProp( Control, 'Align' ) then
  begin
    Result := inherited GetVerbCount() + 3;
  end
  else
  begin
    Result := inherited GetVerbCount() + 2;
  end;
end;


procedure TCESigComponentEditor.PrepareItem(Index: Integer;
  const AItem: IMenuItem);
begin
  inherited;
  if IsPublishedProp( Control, 'Align' ) then
  begin
    case Index - inherited GetVerbCount() of
      1: begin
           AItem.AddItem( 'alNone', 0, Control.Align = alNone, TRUE, SetNone );
           AItem.AddItem( 'alTop', 0, Control.Align = alTop, TRUE, SetTop );
           AItem.AddItem( 'alBottom', 0, Control.Align = alBottom, TRUE, SetBottom );
           AItem.AddItem( 'alClient', 0, Control.Align = alClient, TRUE, SetClient );
           AItem.AddItem( 'alLeft', 0, Control.Align = alLeft, TRUE, SetLeft );
           AItem.AddItem( 'alRight', 0, Control.Align = alRight, TRUE, SetRight );
         end;
      2: begin
           AItem.AddItem( 'psDefault', 0, FALSE, TRUE, AddDefaultChild );
           AItem.AddItem( 'psBase', 0, FALSE, TRUE, AddBaseChild );
           AItem.AddItem( 'psChildTop', 0, FALSE, TRUE, AddTopChild );
           AItem.AddItem( 'psChildBottom', 0, FALSE, TRUE, AddBottomChild );
           AItem.AddItem( 'psChildFill', 0, FALSE, TRUE, AddFillChild );
           AItem.AddItem( 'psChildLeft', 0, FALSE, TRUE, AddLeftChild );
           AItem.AddItem( 'psChildRight', 0, FALSE, TRUE, AddRightChild );
         end;
    end;
  end
  else
  begin
    case Index - inherited GetVerbCount() of
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
end;

procedure TCESigComponentEditor.SetBottom(Sender: TObject);
begin
  SetSelf( Sender, alBottom );
end;

procedure TCESigComponentEditor.SetClient(Sender: TObject);
begin
  SetSelf( Sender, alClient );
end;

procedure TCESigComponentEditor.SetLeft(Sender: TObject);
begin
  SetSelf( Sender, alLeft );
end;

procedure TCESigComponentEditor.SetNone(Sender: TObject);
begin
  SetSelf( Sender, alNone );
end;

procedure TCESigComponentEditor.SetRight(Sender: TObject);
begin
  SetSelf( Sender, alRight );
end;

procedure TCESigComponentEditor.SetSelf(Sender: TObject; pAlign: TAlign);
begin
  Control.Align := pAlign;
end;

procedure TCESigComponentEditor.SetTop(Sender: TObject);
begin
  SetSelf( Sender, alTop );
end;

procedure Register;
begin
  RegisterComponentEditor( TWinControl, TCESigComponentEditor );
  RegisterComponentEditor( TTabSheet, TCESigComponentEditor );
  RegisterComponentEditor( TTreeView, TCESigComponentEditor );
end;
{$ENDIF}

end.
