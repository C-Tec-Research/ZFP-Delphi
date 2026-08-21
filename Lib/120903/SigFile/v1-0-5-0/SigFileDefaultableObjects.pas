unit SigFileDefaultableObjects;

(*
  Supports objects that can be defaulted to other objects. The editors can be
  Variable and may visually change when a default object is assigned
*)

interface

uses
  SigFile,
  SigVariableEditor,
  SigImage,
  SysUtils,
  StdCtrls,
  Controls;

type
  tDefaultableBool = ( db_Default, db_FALSE, db_TRUE );

  tSigDefaultableBooleanProperty = class( tSigSimpleProperty )
  private
    fDefaultProperty: tSigSimpleProperty;
    fEditor: TSigVariableEditor;
    fImageList: tImageList;
    procedure SetDefaultProperty(const Value: tSigSimpleProperty);
    function GetValueAsBool: boolean;
    procedure SetValueAsBool(const pValue: boolean);
    function GetValueAsDefaultableBool: tDefaultableBool;
    procedure SetValueAsDefaultableBool(const pValue: tDefaultableBool);
    procedure SetEditor(const Value: TSigVariableEditor);
    procedure SetupEditor;
    procedure OnEditorChange( Sender : tObject );
    procedure SetImageList(const Value: tImageList);
    function GetDefaultValue: boolean;
  protected
    procedure SetValue(const pValue: string); override;
    procedure SetEditorUpdatePending(const Value: boolean); override;
  public
    property DefaultProperty : tSigSimpleProperty // we don't own this
             read fDefaultProperty
             write SetDefaultProperty;
    property ValueAsBool : boolean
             read GetValueAsBool
             write SetValueAsBool;
    property ValueAsDefaultableBool : tDefaultableBool
             read GetValueAsDefaultableBool
             write SetValueAsDefaultableBool;
    property Editor : TSigVariableEditor
             read fEditor
             write SetEditor;
    property ImageList : tImageList
             read fImageList
             write SetImageList;
    property DefaultValue : boolean
             read GetDefaultValue;
  end;

implementation

{ tSigDefaultableBooleanProperty }

function tSigDefaultableBooleanProperty.GetDefaultValue: boolean;
begin
  if assigned( DefaultProperty ) then
  begin
    if DefaultProperty is tSigBooleanProperty then
    begin
      with DefaultProperty as tSigBooleanProperty do
      begin
        Result := ValueAsBool;
      end;
    end
    else if DefaultProperty is tSigDefaultableBooleanProperty then
    begin
      with DefaultProperty as tSigDefaultableBooleanProperty do
      begin
        Result := ValueAsBool;
      end;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function tSigDefaultableBooleanProperty.GetValueAsBool: boolean;
begin
  case ValueAsDefaultableBool of
    db_Default:
    begin
      Result := DefaultValue;
    end;
    db_FALSE:
    begin
      Result := FALSE;
    end;
    db_TRUE:
    begin
      Result := TRUE;
    end;
    else
    begin
      Result := FALSE;
    end;
  end;
end;

function tSigDefaultableBooleanProperty.GetValueAsDefaultableBool: tDefaultableBool;
begin
  if SameText( Value, 'TRUE' ) then
  begin
    Result := db_TRUE;
  end
  else if SameText( Value, 'FALSE') then
  begin
    Result := db_FALSE;
  end
  else
  begin
    Result := db_default;
  end;
end;

procedure tSigDefaultableBooleanProperty.OnEditorChange(Sender: tObject);
begin
  case fEditor.EditorStyle of
    vesNone: ;
    vesMaskEdit: ;
    vesSpinEdit: ;
    vesComboBox:
    begin
      ValueAsDefaultableBool := tDefaultableBool( fEditor.EditorAsComboBox.ItemIndex );
    end;
    vesCheckbox:
    begin
      if ValueAsBool <> fEditor.EditorAsCheckBox.Checked then
      begin
        ValueAsBool := fEditor.EditorAsCheckBox.Checked;
      end;
    end;
    vesButton: ;
    vesImage:
    begin
      // we toggle  through the various states
      case ValueAsDefaultableBool of
        db_Default:
        begin
          ValueAsDefaultableBool := db_FALSE;
        end;
        db_FALSE:
        begin
          ValueAsDefaultableBool := db_TRUE;
        end;
        db_TRUE:
        begin
          ValueAsDefaultableBool := db_Default;
        end;
      end;
    end;
  end;
end;

procedure tSigDefaultableBooleanProperty.SetDefaultProperty(
  const Value: tSigSimpleProperty);
begin
  fDefaultProperty := Value;
  SetupEditor;
end;

procedure tSigDefaultableBooleanProperty.SetEditor(
  const Value: TSigVariableEditor);
begin
  if fEditor <> Value then
  begin
    if assigned( fEditor ) then
    begin
      // return any hijacked functions
      fEditor.OnChange := nil;
    end;
    fEditor := Value;
    if assigned( fEditor ) then
    begin
      fEditor.OnChange := OnEditorChange;
      SetupEditor;
    end;
  end;
end;

procedure tSigDefaultableBooleanProperty.SetEditorUpdatePending(
  const Value: boolean);
begin
  if EditorUpdatePending and not Value then
  begin
    inherited;
    SetupEditor;
  end
  else
  begin
    inherited;
  end;
end;

procedure tSigDefaultableBooleanProperty.SetImageList(const Value: tImageList);
begin
  fImageList := Value;
  SetupEditor;
end;

procedure tSigDefaultableBooleanProperty.SetupEditor;
begin
  if EditorInhibited then
  begin
    EditorUpdatePending := TRUE;
  end
  else
  begin
    // we assume owner sets label text first!
    if assigned( fEditor ) then
    begin
      if assigned( ImageList ) then
      begin
        fEditor.EditorStyle := vesImage;
        if assigned( DefaultProperty ) then
        begin
          case ValueAsDefaultableBool of
            db_Default:
            begin
              if DefaultValue then
              begin
                fEditor.EditorAsImage.ImageIndex := 2;
              end
              else
              begin
                fEditor.EditorAsImage.ImageIndex := 3;
              end;
            end;
            db_FALSE:
            begin
              fEditor.EditorAsImage.ImageIndex := 0;
            end;
            db_TRUE:
            begin
              fEditor.EditorAsImage.ImageIndex := 1;
            end;
          end;
        end
        else
        begin
          if ValueAsBool then
          begin
            fEditor.EditorAsImage.ImageIndex := 1;
          end
          else
          begin
            fEditor.EditorAsImage.ImageIndex := 0;
          end
        end;
      end
      else
      begin
        if assigned( DefaultProperty ) then
        begin
          fEditor.EditorStyle := vesComboBox;
          with fEditor.EditorAsComboBox do
          begin
            Style := csDropDownList;
            Items.Clear;
            if DefaultValue then
            begin
              Items.Add( 'Default(True)' );
            end
            else
            begin
              Items.Add( 'Default(False)' );
            end;
            Items.Add( 'False' );
            Items.Add( 'True' );
            ItemIndex := Ord( ValueAsDefaultableBool );
          end;
        end
        else
        begin
          fEditor.EditorStyle := vesCheckbox;
          fEditor.EditorAsCheckBox.Checked := ValueAsBool;
        end;
      end;
    end;

  end;

end;

procedure tSigDefaultableBooleanProperty.SetValue(const pValue: string);
begin
  try
    if Value <> pValue then
    begin
      inherited;
      SetupEditor;
    end
    else
    begin
      inherited;
    end;
  except

  end;
end;

procedure tSigDefaultableBooleanProperty.SetValueAsBool(const pValue: boolean);
begin
  if pValue then
  begin
    Value := 'TRUE';
  end
  else
  begin
    Value := 'FALSE';
  end;
end;


procedure tSigDefaultableBooleanProperty.SetValueAsDefaultableBool(
  const pValue: tDefaultableBool);
begin
  case pValue of
    db_Default:
    begin
      Value := 'DEFAULT';
    end;
    db_FALSE:
    begin
      Value := 'FALSE';
    end;
    db_TRUE:
    begin
      Value := 'TRUE';
    end;
  end;
end;

end.
