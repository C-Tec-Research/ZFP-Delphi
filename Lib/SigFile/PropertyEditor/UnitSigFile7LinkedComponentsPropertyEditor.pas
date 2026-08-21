unit UnitSigFile7LinkedComponentsPropertyEditor;

interface
  uses
    Forms,
    DesignEditors,
    FMX.Controls,
    DlgLinkedComponents,
    System.Classes,
    SigFile7,
    DesignIntf;

type
  TSigFile7LinkedComponentsPropertyEditor = class( TClassProperty )
    public
      function GetAttributes: TPropertyAttributes; override;
      procedure Edit; override;
  end;

  procedure Register;



implementation

procedure Register;
begin
  RegisterPropertyEditor( TypeInfo( TSigFile7TextComponentList ), TSigFile7BaseProperty, 'Editors', TSigFile7LinkedComponentsPropertyEditor );
end;

{ TSigFile7LinkedComponentsPropertyEditor }

procedure TSigFile7LinkedComponentsPropertyEditor.Edit;
var
  iEditors : TSigFile7TextComponentList;
  i: integer;
  iForm : TForm;
  iComponent : TSigFile7BaseProperty;
  iOwner : TComponent;
begin
  FormSigFile7PropertyEditor:= TFormSigFile7PropertyEditor.Create( Application );
  try
    iEditors := TSigFile7TextComponentList( GetOrdValue );
    with FormSigFile7PropertyEditor do
    begin
      iComponent := GetComponent( 0 ) as TSigFile7BaseProperty;
      iForm := nil;
      if assigned( iComponent ) then
      begin
        iOwner := iComponent.Owner;
        while assigned( iOwner ) do
        begin
          if iOwner is TForm then
          begin
            iForm := iOwner as TForm;
            break;
          end;
          // else
          iOwner := iOwner.Owner;
        end;
        if assigned( iForm ) then
        begin
          ComponentName := iComponent.Name;

          for i := 0 to iEditors.Count - 1 do
          begin
            AddCurrentComponent( iEditors.Items[ i ].Control );
          end;
          // now list the allowed controls
          for i := 0 to iForm.ComponentCount - 1 do
          begin
            if iForm.Components[ i ] is TControl then
            begin
              if iComponent.IsLegalEditor( iForm.Components[ i ] as TControl ) then
              begin
                AddAllowableComponent( iForm.Components[ i ] as TControl );
              end;
            end;
          end;
          if Execute then
          begin
            iComponent.UnregisterAllEditors;
            for i := 0 to CurrentComponentCount - 1 do
            begin
              iComponent.RegisterEditor( CurrentComponent[ i ] as TControl );
            end;
          end;
        end;
      end;
    end;
  finally
    FormSigFile7PropertyEditor.Free;
  end;

end;

function TSigFile7LinkedComponentsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog, paReadOnly ] - [paSubProperties, paMultiSelect ];
end;

end.
