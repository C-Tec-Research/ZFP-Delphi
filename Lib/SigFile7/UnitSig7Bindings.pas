unit UnitSig7Bindings;

{
  Some data/control links potentially exist within data, but this is only suitable
  for data in linear rather than list editors. For linear editors there is only
  one record current at a time. For list editors there may be several active
  at a time, one for each of several records.

  This unit defines a list of data record/control list pairs.

  This is similar in concept to live bindings, but is programatic

  Typically a data record will be bound to a (typically) frame and then
  children of the data passed (by name) are tied to specific controls or
  subframes, ond so an entire structure can be replicated.

  This is really non-visual. We are dealing with data elements, not
  their visual controlling components, which are effectively bypassed.

  FMX only.
}

interface

uses
  System.Generics.Collections,
  FMX.Controls,
  SigFile7;

type
  TSig7BindingList = class;
  TSig7Binding = class;

  TOnRegisterSig7Binding = procedure( pBinding : TSig7Binding; pData : TSigFile7BaseData; pControl : TControl );

  TSig7Binding = class
  private
    fData : TSigFile7BaseData;
    fComponentList : TSigFile7TextComponentList;
    fChildren : TSig7BindingList;
    fOnRegisterControl: TOnRegisterSig7Binding;
    fOnUnRegisterControl: TOnRegisterSig7Binding;
  protected

  public
    constructor Create( const pData : TSigFile7BaseData );
    destructor Destroy; override;

    procedure RegisterControl( const pControl : TControl );
    procedure UnRegisterControl( const pControl : TControl );

    procedure RegisterChildBinding( const pData : TSigFile7BaseData; pControl : TControl );
    procedure UnRegisterChildBinding( const pData : TSigFile7BaseData; pControl : TControl );

    procedure SetText( const pText : string );

    property OnRegisterConrol : TOnRegisterSig7Binding
             read fOnRegisterControl
             write fOnRegisterControl;
    property OnUnRegisterConrol : TOnRegisterSig7Binding
             read fOnUnRegisterControl
             write fOnUnRegisterControl;

    property Data : TSigFile7BaseData
             read fData;
  end;

  TSig7BindingList = class( TObjectList< TSig7Binding > )
  private
    function GetBinding(const pData: TSigFile7BaseData): TSig7Binding;
  protected
    procedure OnDataTextChange( const pSender : TObject; const pText : string );
  public
    procedure RegisterBinding( const pData : TSigFile7BaseData; const pControl : TControl );
    procedure UnRegisterBinding( const pData : TSigFile7BaseData; const pControl : TControl );
    property Binding[ const pData : TSigFile7BaseData ] : TSig7Binding
             read GetBinding;
  end;

implementation

{ TSig7Binding }

constructor TSig7Binding.Create(const pData: TSigFile7BaseData);
begin
  inherited Create;
  fData := pData;
  fComponentList := TSigFile7TextComponentList.Create;
  // we do not create fChildren unless needed. If we did we would
  // create an infinite loop and run out of stack space.
end;

destructor TSig7Binding.Destroy;
begin
  fComponentList.Free;
  fChildren.Free;
  inherited;
end;

procedure TSig7Binding.SetText(const pText: string);
begin
  fComponentList.SetText( pText );
end;

procedure TSig7Binding.RegisterChildBinding(const pData: TSigFile7BaseData;
  pControl: TControl);
begin
  if not assigned( fChildren ) then
  begin
    fChildren := TSig7BindingList.Create();
  end;
  fChildren.RegisterBinding( pData, pControl );
end;

procedure TSig7Binding.RegisterControl(const pControl: TControl);
begin
  if assigned( pControl ) then
  begin
    pControl.TagObject := fData;
    fComponentList.AddControl( pControl, TRUE );
  end;
end;

procedure TSig7Binding.UnRegisterChildBinding(const pData: TSigFile7BaseData;
  pControl: TControl);
begin
  if assigned( fChildren ) then
  begin
    fChildren.UnRegisterBinding( pData, pControl );
  end;
end;

procedure TSig7Binding.UnRegisterControl( const pControl: TControl);
begin
  fComponentList.Remove( pControl );
end;

{ TSig7BindingList }

function TSig7BindingList.GetBinding(
  const pData: TSigFile7BaseData): TSig7Binding;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[ i ];
    if Result.Data = pData then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

procedure TSig7BindingList.OnDataTextChange(const pSender: TObject;
  const pText: string);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Data = pSender then
    begin
      Items[ i ].SetText( pText );
      exit; // there can only be one element per sender
    end;
  end;
end;

procedure TSig7BindingList.RegisterBinding(const pData: TSigFile7BaseData;
  const pControl: TControl);
var
  iBinding : TSig7Binding;
begin
  if assigned( pData ) then
  begin
    iBinding := Binding[ pData ];
    if not assigned( iBinding ) then
    begin
      iBinding := TSig7Binding.Create( pData );
      Add( iBinding );
      pData.OnChangeText := OnDataTextChange;
    end;
    iBinding.RegisterControl( pControl );
  end;
end;

procedure TSig7BindingList.UnRegisterBinding(const pData: TSigFile7BaseData;
  const pControl: TControl);
var
  iBinding : TSig7Binding;
begin
  iBinding := Binding[ pData ];
  if assigned( iBinding ) then
  begin
    iBinding.UnRegisterControl( pControl );
  end;
end;

end.
