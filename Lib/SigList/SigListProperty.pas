unit SigListProperty;

interface

uses
  SigFile,
  SigList,
  System.SysUtils;

type
  tSigListProperty = class( tSigTextProperty )
  private
    function GetSigList: tSigList;
    procedure SetSigList(const Value: tSigList);
  protected
    procedure SetValue(const pValue: string); override;
  public
    property ValueAsSigList : tSigList
             read GetSigList
             write SetSigList;
  end;

  tSigTimeListProperty = class( tSigTextProperty )
  private
    function GetSigList: tSigTimeList;
    procedure SetSigList(const Value: tSigTimeList);
  protected
    procedure SetValue(const pValue: string); override;
    procedure fOnEditChange( Sender : tObject ); override;
    //procedure fOnEditExit( Sender : tObject ); override;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); overload; override;
    property ValueAsSigTimeList : tSigTimeList
             read GetSigList
             write SetSigList;
  end;

implementation

{ tSigListProperty }

function tSigListProperty.GetSigList: tSigList;
begin
  Result := Value;
end;

procedure tSigListProperty.SetSigList(const Value: tSigList);
begin
  self.Value := Value;
end;

procedure tSigListProperty.SetValue(const pValue: string);
begin
  if tSigList.IsValidList( Value ) then
  begin
    inherited;
  end
  else
  begin
    raise Exception.Create('"' + Value + '" is not a valid List');
  end;
end;

{ tSigTimeListProperty }

constructor tSigTimeListProperty.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  //UpdateOnEditorChange := FALSE;
  //UpdateOnEditorExit := TRUE;
end;

procedure tSigTimeListProperty.fOnEditChange(Sender: tObject);
begin
  //try
    inherited;
  //except
  //  // ignore errors except on exit
  //end;

end;

function tSigTimeListProperty.GetSigList: tSigTimeList;
begin
  Result := Value;
end;

procedure tSigTimeListProperty.SetSigList(const Value: tSigTimeList);
begin
  self.Value := Value;
end;

procedure tSigTimeListProperty.SetValue(const pValue: string);
begin
  if tSigTimeList.IsValidList( Value ) then
  begin
    inherited;
  end
  else
  begin
    raise Exception.Create('"' + Value + '" is not a valid Time List');
  end;

end;

end.

