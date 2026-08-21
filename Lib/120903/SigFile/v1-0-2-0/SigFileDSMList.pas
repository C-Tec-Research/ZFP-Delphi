unit SigFileDSMList;

interface

uses
  SigFile,
  DSMList;

type
  tOnDSMListChange = procedure (const NewVal : string ) of object;

type
  tSigFileDSMList = class( tSigSimpleProperty )
  private
    fDSMList: tDSMList;
    fOnChange: tOnDSMListChange;
    function GetFirst: integer;
    function GetNext: integer;
    function GetCount: integer;
  protected
   procedure SetValue(const pValue: string); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property DSMList : tDSMList
             read fDSMList;
    {
      DSMist is deliberately read only. To assign to the DSMList, instead assign to
      'Value', which is perfectly valid. This ensures that all other mechanisms,
      like undo, OnChange etc are executed correctly, although a temporary
      tDSMList may need to be used.
    }

    property First : integer
             read GetFirst;
    property Next : integer
             read GetNext;
    property Count : integer
             read GetCount;
    property OnListChange : tOnDSMListChange
             read fOnChange
             write fOnChange;
  end;

implementation

{ tSigFileDSMList }

constructor tSigFileDSMList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
end;

function tSigFileDSMList.GetCount: integer;
begin
  Result := DSMList.Count;
end;

function tSigFileDSMList.GetFirst: integer;
begin
  Result := DSMList.First;
end;

function tSigFileDSMList.GetNext: integer;
begin
  Result := DSMList.Next;
end;

procedure tSigFileDSMList.SetValue(const pValue: string);
begin
  if Value <> pValue then
  begin
    fDSMList := pValue;
    inherited;
    if assigned (fOnChange ) then
    begin
      fOnChange( pValue );
    end;
  end;
end;

end.
