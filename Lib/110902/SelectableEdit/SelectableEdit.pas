unit SelectableEdit;

{
  This provides a common interface for edit controls
  consisting of selectable list, currently a
  combo box expected to be of type tDropDownList
  or a TRadioGroup, giving common properties
}

interface

uses
  Classes,
  Controls,
  ExtCtrls,
  StdCtrls,
  SysUtils;

type
  tSelectableEdit = class
  private
    fComboBox : TComboBox;
    fRadioGroup : TRadioGroup;
    fOnChange: TNotifyEvent;
    fGUIOnChange: TNotifyEvent;
    fEnabled: boolean;
    fItemIndex: integer;
    fVisible : boolean;
    function GetGUI: TWinControl;
    procedure SetGUI(const Value: TWinControl);
    procedure SetItemIndex(const Value: integer);
    function GetItems: tStrings;
    procedure SetEnabled(const Value: boolean);
    procedure fOnEditorChange(Sender: TObject);
    procedure SetVisible(const Value: boolean);
  public
    constructor Create;
    property GUI : TWinControl
             read GetGUI
             write SetGUI;
    property ItemIndex : integer
             read fItemIndex
             write SetItemIndex;
    property Items : tStrings
             read GetItems;
    property OnChange : TNotifyEvent
             read fOnChange
             write fOnChange;
    property Enabled : boolean
             read fEnabled
             write SetEnabled;
    property Visible : boolean
             read fVisible
             write SetVisible;
  end;

implementation

{ tSelectableEdit }

constructor tSelectableEdit.Create;
begin
  inherited Create;
  fEnabled := TRUE;
end;

procedure tSelectableEdit.fOnEditorChange(Sender: TObject);
begin
  if assigned( fComboBox ) then
  begin
    fItemIndex := fComboBox.ItemIndex;
  end
  else if assigned( fRadioGroup ) then
  begin
    fItemIndex := fRadioGroup.ItemIndex;
  end;

  if assigned( fOnChange) then
  begin
    fOnChange( Sender );
  end;
end;

function tSelectableEdit.GetGUI: TWinControl;
begin
  if assigned( fComboBox ) then
  begin
    Result := fComboBox;
  end
  else if assigned( fRadioGroup ) then
  begin
    Result := fRadioGroup;
  end
  else
  begin
    Result := nil;
  end;
end;

function tSelectableEdit.GetItems: tStrings;
begin
  if assigned( fComboBox ) then
  begin
    Result := fComboBox.Items;
  end
  else if assigned( fRadioGroup ) then
  begin
    Result := fRadioGroup.Items;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure tSelectableEdit.SetEnabled(const Value: boolean);
begin
  fEnabled := Value;
  if assigned( fComboBox ) then
  begin
    fComboBox.Enabled := Value;
  end
  else if assigned( fRadioGroup ) then
  begin
    fRadioGroup.Enabled := Value;
  end;
end;

procedure tSelectableEdit.SetGUI(const Value: TWinControl);
begin
{
  if assigned(fComboBox ) then
  begin
    if Value <> fComboBox then
    begin
      raise exception.Create('GUI already assigned' );
    end;
  end;
  if assigned(fRadioGroup ) then
  begin
    if Value <> fRadioGroup then
    begin
      raise exception.Create('GUI already assigned' );
    end;
  end;
}
  if assigned( fComboBox ) then
  begin
    fComboBox.OnChange := OnChange;
    fComboBox := nil;
  end
  else if assigned( fRadioGroup ) then
  begin
    fRadioGroup.OnClick := OnChange;
    fRadioGroup := nil;
  end;
  fGUIOnChange := nil;
  if not assigned( Value ) then
  begin
    fVisible := FALSE;
  end
  else if Value is tComboBox then
  begin
    fComboBox := Value as tComboBox;
    fComboBox.Style := csDropDownList;
    fComboBox.Enabled := fEnabled;
    OnChange := fComboBox.OnChange;
    fComboBox.OnChange := fOnEditorChange;
    fVisible := fComboBox.Visible;
    fRadioGroup := nil;
  end
  else if Value is tRadioGroup then
  begin
    fRadioGroup := Value as TRadioGroup;
    fComboBox := nil;
    fRadioGroup.Enabled := fEnabled;
    OnChange := fRadioGroup.OnClick;
    fRadioGroup.OnClick := fOnEditorChange;
    fVisible := fRadioGroup.Visible;
  end
  else if assigned( Value ) then
  begin
    raise exception.Create('Illegal GUI Type' );
  end;
end;

procedure tSelectableEdit.SetItemIndex(const Value: integer);
begin
  fItemIndex := Value;
  if assigned( fComboBox ) then
  begin
    fComboBox.ItemIndex := Value;
  end
  else if assigned( fRadioGroup ) then
  begin
    fRadioGroup.ItemIndex := Value;
  end;
end;

procedure tSelectableEdit.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  if assigned( fComboBox ) then
  begin
    fComboBox.Visible := Value;
  end
  else if assigned( fRadioGroup ) then
  begin
    fRadioGroup.Visible := Value;
  end;
end;

end.
