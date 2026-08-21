unit Olbytype;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Outline, SigOline;

type
  TOutlineByType = class(TOutline)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;
    procedure Clear;

    procedure AddSigNETObject( SigNETObject : TSigNETObject );

    procedure Edit; { edits currently selected item }

  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TOutlineByType]);
end;

constructor TOutlineByType.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
end;

procedure TOutlineByType.Clear;
begin
  inherited Clear;
  Add( 0, 'Ring');
  Add( 1, 'WCTL');
end;

procedure TOutlineByType.AddSigNETObject( SigNETObject : TSigNETObject );
var
  IndexItem : LongInt;
begin
  if SigNETObject <> nil then
  begin
    IndexItem := GetTextItem( SigNETObject.TypeAsText );
    if IndexItem > 0 then
    begin
      AddChildObject( IndexItem, SigNETObject.Description,
                    SigNETObject );
    end;
  end;
end;

procedure TOutlineByType.Edit; { Edits the currently selected item }
begin
  if SelectedItem = 0 then
  begin
    { No item selected - Ignore }
  end
  else if Items[ SelectedItem ].Level = 1 then
  begin
    { Top level - not editable }
  end
  else
  begin
    { pass on to child to deal with }
    with TSigNETObject(Items[ SelectedItem ].Data) as TSigNETObject do
    begin
      Edit;
      { repaint text }
      Items[ SelectedItem ].Text := Description;
    end;
  end;
end;

end.
