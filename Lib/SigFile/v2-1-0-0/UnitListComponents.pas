unit UnitListComponents;

(*******************************************************************************
 *                                                                             *
 * This unit provides a unified interface for multiple components that are     *
 * handled in a common way - for example variuos list box and combo box style  *
 * controls.                                                                   *
 *                                                                             *
 *******************************************************************************)

interface

uses
  FMX.Edit,
  FMX.Controls,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Forms,
  System.SysUtils,
  System.Classes,
  SigFrameGrid;

type
  TSigFile7TestListComponent = class
  private
    fControl: TControl;
    fListBoxItemClick : TCustomListBox.TItemClickEvent;
    fFrameGridIndexChanged : TFrameGridIndexChanged;
    function GetItemIndex: integer;
    procedure SetItemIndex(const Value: integer);
    function GetItems: TStrings;
    procedure ListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure OnFrameGridIndexChanged( Sender : TSigFrameGrid; const pIndex, pCol, pRow : integer; const pFrame : TFrame );

  protected
  public
    constructor Create( const pControl : TControl; const pUseStandardIntercepts,
                        pUseStandardSelectors : boolean );

    property Control  : TControl
             read fControl
             write fControl;

    procedure Clear;

    procedure ChangeItemText(const pItem : TObject; const Value: string);
    procedure AddItemText(const pItem : TObject; const pValue: string);
    procedure RemoveItemText(const pItem : TObject);

    property ItemIndex : integer
             read GetItemIndex
             write SetItemIndex;
    property Items : TStrings
             read GetItems;
  end;

  TSigFile7TextComponent = class
  private
    fControl: TControl;
    fOnChange: TNotifyEvent;
    fUseStandardIntercepts : boolean;
    function GetText: string;
    procedure SetText(const Value: string);
    procedure OnTextChange( Sender : TObject );
    procedure OnComboBoxChange( Sender : TObject );
    procedure OnCheckBoxChange( Sender : TObject );
  protected
  public
    constructor Create( const pControl : TControl; const pUseStandardIntercepts : boolean );

    property Control  : TControl
             read fControl
             write fControl;

    property Text : string
             read GetText
             write SetText;

    property OnChange : TNotifyEvent
             read fOnChange
             write fOnChange;
  end;

implementation

uses
  SigFile7;

{ TSigFile7TestListComponent }

procedure TSigFile7TestListComponent.AddItemText(const pItem: TObject;
  const pValue: string);
begin
  Items.AddObject( pValue, pItem );
end;

procedure TSigFile7TestListComponent.ChangeItemText(const pItem: TObject;
  const Value: string);
var
  i: Integer;
begin
  with Items do
  begin
    for i := 0 to Count - 1 do
    begin
      if Objects[ i ] = pItem then
      begin
        Items[ i ] := Value;
      end;
    end;
  end;
end;

procedure TSigFile7TestListComponent.Clear;
begin
  if assigned( fControl ) then
  begin
    if fControl is TCustomComboBox then
    with fControl as TCustomComboBox do
    begin
      Items.Clear;
    end
    else if fControl is TCustomListBox then
    with fControl as TCustomListBox do
    begin
      Items.Clear;
    end
    else if fControl is TSigFrameGrid then
    with fControl as TSigFrameGrid do
    begin
      Strings.Clear;
    end
    else if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0001)Unsupported component');
    end;
  end;
end;

constructor TSigFile7TestListComponent.Create(const pControl: TControl; const pUseStandardIntercepts,
            pUseStandardSelectors : boolean );
begin
  inherited Create;

  fControl := pControl;

  if pUseStandardIntercepts then
  begin
    // to do
  end;
  if pUseStandardSelectors then
  begin
    if pControl is TCustomListBox then
    begin
      fListBoxItemClick := (pControl as TCustomListBox).OnItemClick;
      (pControl as TCustomListBox).OnItemClick := ListBoxItemClick;
    end
    else if pControl is TSigFrameGrid then
    begin
      fFrameGridIndexChanged := (pControl as TSigFrameGrid).OnIndexChanged;
      (pControl as TSigFrameGrid).OnIndexChanged := OnFrameGridIndexChanged;
    end
    else
    begin
      // to do
    end;
  end;
end;

function TSigFile7TestListComponent.GetItemIndex: integer;
begin
  if assigned( fControl ) then
  begin
    if fControl is TCustomComboBox then
    with fControl as TCustomComboBox do
    begin
      Result := ItemIndex;
    end
    else if fControl is TCustomListBox then
    with fControl as TCustomListBox do
    begin
      Result := ItemIndex;
    end
    else if fControl is TSigFrameGrid then
    with fControl as TSigFrameGrid do
    begin
      Result := ItemIndex;
    end
    else if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0002)Unsupported component');
    end
    else
    begin
      Result := -1;
    end;
  end
  else
  begin
    Result := -1;
  end;
end;

function TSigFile7TestListComponent.GetItems: TStrings;
begin
  if assigned( fControl ) then
  begin
    if fControl is TCustomComboBox then
    with fControl as TCustomComboBox do
    begin
      Result := Items;
    end
    else if fControl is TCustomListBox then
    with fControl as TCustomListBox do
    begin
      Result := Items;
    end
    else if fControl is TSigFrameGrid then
    with fControl as TSigFrameGrid do
    begin
      Result := Strings;
    end
    else if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0003)Unsupported component');
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure TSigFile7TestListComponent.ListBoxItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if assigned( Item.Data ) then
  begin
    if Item.Data is TSigFile7BaseData then
    begin
      (Item.Data as TSigFile7BaseData).Active := TRUE;
{
    end
    else if assigned( Sender.TagObject ) then
    begin
      if Sender.TagObject is TSigFile7BaseProperty then
      begin
        (Sender.TagObject as TSigFile7BaseProperty).SetItemIndex( Sender, Item.Data );
      end;
}
    end;
  end;
  if assigned( fListBoxItemClick ) then
  begin
    fListBoxItemClick( Sender, Item );
  end;
end;

procedure TSigFile7TestListComponent.OnFrameGridIndexChanged(
  Sender: TSigFrameGrid; const pIndex, pCol, pRow: integer;
  const pFrame: TFrame);
begin
  if assigned( Sender.Data[ pIndex ] ) then
  begin
    if Sender.Data[ pIndex ] is TSigFile7BaseData then
    begin
      (Sender.Data[ pIndex ] as TSigFile7BaseData).Active := TRUE;
    end;
  end;
  if assigned( fFrameGridIndexChanged ) then
  begin
    fFrameGridIndexChanged( Sender, pIndex, pCol, pRow, pFrame );
  end;
end;

procedure TSigFile7TestListComponent.RemoveItemText(const pItem: TObject);
var
  i: Integer;
begin
  for i := 0 to Items.Count -1 do
  begin
    if Items.Objects[i] = pItem then
    begin
      Items.Delete( i );
      exit;
    end;
  end;
end;

procedure TSigFile7TestListComponent.SetItemIndex(const Value: integer);
begin
  if assigned( fControl ) then
  begin
    if fControl is TCustomComboBox then
    with fControl as TCustomComboBox do
    begin
      ItemIndex := Value;
    end
    else if fControl is TCustomListBox then
    with fControl as TCustomListBox do
    begin
      ItemIndex := Value;
    end
    else if fControl is TSigFrameGrid then
    with fControl as TSigFrameGrid do
    begin
      ItemIndex := Value;
    end
    else if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0004)Unsupported component');
    end;
  end;
end;

{ TSigFile7TextComponent }

constructor TSigFile7TextComponent.Create(const pControl: TControl; const pUseStandardIntercepts : boolean);
begin
  inherited Create;

  fControl := pControl;

  fUseStandardIntercepts := pUseStandardIntercepts;
  if pUseStandardIntercepts then
  begin
    if fControl is TCustomEdit then
    begin
      fOnChange := ( fControl as TCustomEdit ).OnChange;
      ( fControl as TCustomEdit ).OnChange := OnTextChange;
    end
    else if fControl is TCheckBox then
    begin
      // note that this test MUST come before test for TTextControl because
      // TCheckBox is descended from TTextControl
      fOnChange := ( fControl as TCheckBox ).OnChange;
      ( fControl as TCheckBox ).OnChange := OnCheckBoxChange;
    end
    else if fControl is TTextControl then
    begin
    end
    else if fControl is TCustomComboBox then
    begin
      fOnChange := ( fControl as TComboBox ).OnChange;
      ( fControl as TComboBox ).OnChange := OnComboBoxChange;
    end
    else if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0005)Unsupported component');
    end;
  end;
end;

function TSigFile7TextComponent.GetText: string;
begin
  if fControl is TCustomEdit then
  begin
    Result := ( fControl as TCustomEdit ).Text;
  end
  else if fControl is TCheckBox then
  begin
      // note that this test MUST come before test for TTextControl because
      // TCheckBox is descended from TTextControl
    if (fControl as TCheckBox).IsChecked then
    begin
      Result := 'TRUE';
    end
    else
    begin
      Result := 'FALSE';
    end;
  end
  else if fControl is TTextControl then
  begin
    Result := ( fControl as TTextControl ).Text;
  end
  else if fControl is TImageControl then
  begin
    Result := fControl.TagString;
  end
  else if fControl is TCustomComboBox then
  begin
    Result := IntToStr(( fControl as TCustomComboBox ).ItemIndex);
  end
  else if not (csDesigning in fControl.ComponentState) then
  begin
    raise Exception.Create('(0006)Unsupported component');
  end;
end;

procedure TSigFile7TextComponent.OnCheckBoxChange(Sender: TObject);
begin
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
  if Sender is TCheckBox then
  begin
    with Sender as TCheckBox do
    begin
      if assigned( TagObject ) then
      begin
        if TagObject is TSigFile7BaseData then
        begin
          if IsChecked then
          begin
            (TagObject as TSigFile7BaseData).Text := 'TRUE';
          end
          else
          begin
            (TagObject as TSigFile7BaseData).Text := 'FALSE';
          end;
        end
        else if TagObject is TSigFile7BooleanProperty then
        begin
          (TagObject as TSigFile7BooleanProperty).Value := IsChecked;
        end
        else if TagObject is TSigFile7BaseProperty then
        begin
          if IsChecked then
          begin
            (TagObject as TSigFile7IntegerProperty).Text := 'TRUE';
          end
          else
          begin
            (TagObject as TSigFile7IntegerProperty).Text := 'FALSE';
          end;
        end;
      end;
    end;
  end;


end;

procedure TSigFile7TextComponent.OnComboBoxChange(Sender: TObject);
begin
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
  if Sender is TComboBox then
  begin
    with Sender as TComboBox do
    begin
      if assigned( TagObject ) then
      begin
        if TagObject is TSigFile7BaseData then
        begin
          (TagObject as TSigFile7BaseData).Text := IntToStr( ItemIndex );
        end
        else if TagObject is TSigFile7IntegerProperty then
        begin
          (TagObject as TSigFile7IntegerProperty).Value := ItemIndex;
        end
        else if TagObject is TSigFile7BaseProperty then
        begin
          (TagObject as TSigFile7BaseProperty).Text := IntToStr( ItemIndex );
        end;
      end;
    end;
  end;

end;

procedure TSigFile7TextComponent.OnTextChange(Sender: TObject);
begin
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
  if Sender is TCustomEdit then
  begin
    with Sender as TCustomEdit do
    begin
      if assigned( TagObject ) then
      begin
        if TagObject is TSigFile7BaseProperty then
        begin
          (TagObject as TSigFile7BaseProperty).Text := Text;
        end
        else if TagObject is TSigFile7BaseData then
        begin
          (TagObject as TSigFile7BaseData).Text := Text;
        end;
      end;
    end;
  end;
end;

procedure TSigFile7TextComponent.SetText(const Value: string);
begin
  if fControl is TCustomEdit then
  begin
    ( fControl as TCustomEdit ).Text := Value;
  end
  else if fControl is TCheckBox then
  begin
    // note that this test MUST come before test for TTextControl because
    // TCheckBox is descended from TTextControl
    if SameText( Value, 'TRUE' ) then
    begin
      (fControl as TCheckBox).IsChecked := TRUE;
    end
    else if Value = '1' then
    begin
      (fControl as TCheckBox).IsChecked := TRUE;
    end
    else
    begin
      (fControl as TCheckBox).IsChecked := FALSE;
    end;
  end
  else if fControl is TTextControl then
  begin
    ( fControl as TTextControl ).Text := Value;
  end
  else if fControl is TImageControl then
  begin
    if FileExists( Value ) then
    begin
      fControl.Visible := TRUE;
      (fControl as TImageControl).LoadFromFile( Value );
      fControl.TagString := Value;
    end
    else
    begin
      fControl.Visible := FALSE;
      fControl.TagString := '';
    end;
  end
  else if fControl is TCustomComboBox then
  begin
    (fControl as TCustomComboBox).ItemIndex := StrToIntDef( Value, 0 );
  end
  else if fUseStandardIntercepts then
  begin
    if not (csDesigning in fControl.ComponentState) then
    begin
      raise Exception.Create('(0008)Unsupported component');
    end;
  end;
end;

end.
