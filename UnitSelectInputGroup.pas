unit UnitSelectInputGroup;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.Buttons,
  UnitPCCfgFile, Vcl.ComCtrls, Vcl.ExtCtrls;  // for translation

type
  TOnAddObject = function (const NewName : string; var NewObject : TObject ) : boolean of object;
  TOnChangeTab = procedure( const TabIndex : integer; const TabOwnerObject : tObject ) of object;

type
  TFormSelectGlobalObject = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    TabControlObjects: TTabControl;
    LabelTabs: TLabel;
    Panel1: TPanel;
    LabelPrompt: TLabel;
    ListBoxIG: TListBox;
    LabelOr: TLabel;
    LabelNewPrompt: TLabel;
    LabelNewName: TLabel;
    EditNewObject: TEdit;
    SpeedButtonAddIG: TSpeedButton;
    procedure SpeedButtonAddIGClick(Sender: TObject);
    procedure EditNewObjectChange(Sender: TObject);
    procedure TabControlObjectsChange(Sender: TObject);
  private
    fOnAddObject: TOnAddObject;
    fOnChangeTab: TOnChangeTab;
    fCurrObject : tObject;
    fMaxNameLen : array[ 0..31 ] of integer;
    { Private declarations }
    procedure CheckVisibility;
    function Translate( const pVal : string ) : string;
    procedure SetOnAddObject(const Value: TOnAddObject);
  public
    { Public declarations }
    function Execute( const CurrObject : tObject; const pCaption : string ) : TObject;
    procedure Clear;
    procedure AddObject( const NewName : string; const NewObject : tObject ); // does NOT generate OnAddObject call!
    property OnAddObject : TOnAddObject  // Executed when user clicks 'Add' button
             read fOnAddObject
             write SetOnAddObject;
    procedure ClearTabs;
    procedure SetTab( const pTabIndex : integer );
    function AddTab( const NewText : string; const TabOwner : tObject; const pMaxNameLen : integer ) : integer;
    property OnChangeTab : TOnChangeTab
             read fOnChangeTab
             write fOnChangeTab;
    function FindObjectIndex( const iObject : tObject ) : integer;
  end;

var
  FormSelectGlobalObject: TFormSelectGlobalObject;

implementation

{$R *.dfm}

{ TFormSelectInputGroup }

procedure TFormSelectGlobalObject.AddObject(const NewName: string;
  const NewObject: tObject);
begin
  ListBoxIG.Items.AddObject( NewName, NewObject );
end;

function TFormSelectGlobalObject.AddTab( const NewText: string; const TabOwner : tObject;
                                         const pMaxNameLen : integer ): integer;
begin
  Result := TabControlObjects.Tabs.AddObject( Translate( NewText ), TabOwner);
  fMaxNameLen[ Result ] := pMaxNameLen;
end;

procedure TFormSelectGlobalObject.CheckVisibility;
begin
  LabelOr.Visible := FALSE;
  // if there is exactly 1 tab, clear it!
  with TabControlObjects.Tabs do
  begin
    if Count = 1 then
    begin
      Clear;
    end;
    LabelTabs.Visible := Count <> 0;
    EditNewObject.MaxLength := fMaxNameLen[ 0 ];
  end;
  if assigned( OnAddObject ) then
  begin
    if ListBoxIG.Items.Count > 0 then
    begin
      LabelOr.Visible := TRUE;
    end;
    EditNewObject.Text := '';
    SpeedButtonAddIG.Enabled := FALSE;
    EditNewObject.Visible := TRUE;
    SpeedButtonAddIG.Visible := TRUE;
    LabelNewPrompt.Visible := TRUE;
  end
  else
  begin
    EditNewObject.Visible := FALSE;
    SpeedButtonAddIG.Visible := FALSE;
    LabelNewPrompt.Visible := FALSE;
    LabelNewName.Visible := FALSE;
  end;
  if ListBoxIG.Items.Count > 0 then
  begin
    LabelPrompt.Visible := TRUE;
    ListBoxIG.Visible := TRUE;
  end
  else
  begin
    LabelPrompt.Visible := FALSE;
    ListBoxIG.Visible := FALSE;
  end;
end;

procedure TFormSelectGlobalObject.Clear;
begin
  ListBoxIG.Items.Clear;
end;

procedure TFormSelectGlobalObject.ClearTabs;
begin
  TabControlObjects.Tabs.Clear;
end;

procedure TFormSelectGlobalObject.EditNewObjectChange(Sender: TObject);
begin
  SpeedButtonAddIG.Enabled := EditNewObject.Text <> '';
end;

function TFormSelectGlobalObject.Execute( const CurrObject : tObject; const pCaption : string ): TObject;
var
  i : integer;
begin
  CheckVisibility;
  Caption := Translate( pCaption );
  fCurrObject := CurrObject;
  ListBoxIG.ItemIndex := FindObjectIndex( fCurrObject );
  case ShowModal of
    mrOK:
    begin
      for i := 0 to ListBoxIG.Items.Count - 1 do
      begin
        if ListBoxIG.Selected[ i ] then
        begin
          Result := ListBoxIG.Items.Objects[ i ];
          exit;
        end;
      end;
      // else
      Result := nil;
    end;
    mrNo:
    begin
      Result := nil;
    end;
    else   // cancel
    begin
      Result := fCurrObject;
    end;
  end;
  ClearTabs; // ready for next time
end;

function TFormSelectGlobalObject.FindObjectIndex(
  const iObject: tObject): integer;
begin
  for Result := 0 to ListBoxIG.Items.Count - 1 do
  begin
    if ListBoxIG.Items.Objects[ Result ] = iObject then
    begin
      exit;
    end;
  end;
  // else
  Result := -1;
end;

procedure TFormSelectGlobalObject.SetOnAddObject(const Value: TOnAddObject);
begin
  fOnAddObject := Value;
  CheckVisibility;
end;

procedure TFormSelectGlobalObject.SetTab(const pTabIndex: integer);
begin
  TabControlObjects.TabIndex := pTabIndex;
  EditNewObject.MaxLength := fMaxNameLen[ pTabIndex ];
  if assigned( OnChangeTab ) then
  begin
    Clear;
    OnChangeTab( pTabIndex, TabControlObjects.Tabs.Objects[ pTabIndex ] );
  end;
end;

procedure TFormSelectGlobalObject.SpeedButtonAddIGClick(Sender: TObject);
var
  iNewIG : tObject;
  iIndex : integer;
begin
  if assigned( OnAddObject ) then
  begin
    if OnAddObject( EditNewObject.Text, iNewIG ) then
    begin
      iIndex := ListBoxIG.Items.AddObject( EditNewObject.Text, iNewIG );
      ListBoxIG.Selected[ iIndex ] := TRUE;
      EditNewObject.Text := '';
      CheckVisibility;
    end;
  end;
end;

procedure TFormSelectGlobalObject.TabControlObjectsChange(Sender: TObject);
begin
  if assigned( OnChangeTab ) then
  begin
    Clear;
    with TabControlObjects do
    begin
      OnChangeTab( TabIndex, Tabs.Objects[ TabIndex ] );
      EditNewObject.MaxLength := fMaxNameLen[ TabIndex ];
    end;
    ListBoxIG.ItemIndex := FindObjectIndex( fCurrObject );
  end;
end;

function TFormSelectGlobalObject.Translate(const pVal: string): string;
begin
  Result := XFP4PgmCfg.Translate( pVal );
end;

end.
