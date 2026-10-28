unit UnitErrorObjects;

interface

uses
  Classes,
  Contnrs,
  ComCtrls,
  SysUtils,
  ErrorList,
  System.UITypes,
  System.Types;

type
  tErrorObject = class         // esentially file objects
  private
    fFileName: string;
    fSourceStrings: tStrings;
    fErrorList: tErrorList;
    fTitle: string;
    function GetTabText: string;
    function GetTabIndex: integer;
    procedure SetFileName(const Value: string);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    property FileName : string
             read fFileName
             write SetFileName;
    property TabIndex : integer
             read GetTabIndex;
    property SourceStrings : tStrings
             read fSourceStrings
             write fSourceStrings;
    property ErrorList : tErrorList
             read fErrorList
             write fErrorList;
    property Title : string
             read fTitle
             write fTitle;
    property TabText : string
             read GetTabText;

    procedure AssignSource( const pSource : tStrings );

  end;

  tErrorObjectList = class( tObjectList )
  private
    fObjectTabList: tTabControl;
    fTabIndex: integer;
    fSourceStrings: tStrings;
    procedure SetObjectTabList(const Value: tTabControl);
    function GetErrorObject(const i: integer): tErrorObject;
    procedure SetTabIndex(const Value: integer);
    procedure OnObjectTabListChange( Sender : tObject );
    procedure SetSourceStrings(const Value: tStrings);
  public
    property ObjectTabList : tTabControl
             read fObjectTabList
             write SetObjectTabList;
    property SourceStrings : tStrings
             read fSourceStrings
             write SetSourceStrings;
    property ErrorObject[ const i : integer ] : tErrorObject
             read GetErrorObject;
    procedure SetTabTexts;
    function Add( const pErrorObject : tErrorObject ) : integer; reintroduce;
    function Remove(AObject: TObject): Integer; reintroduce;
    property TabIndex : integer
             read fTabIndex
             write SetTabIndex;
  end;

var
  ErrorObjectList : tErrorObjectList;

implementation

{ tErrorObject }

procedure tErrorObject.AssignSource(const pSource: tStrings);
begin
  if assigned( pSource ) then
  begin
    pSource.Clear;
    if FileName <> '' then
    begin
      if FileExists( FileName ) then
      begin
        pSource.LoadFromFile( FileName );
      end
      else
      begin
        raise Exception.Create('File does not exist!');
      end;
    end
    else if assigned( SourceStrings ) then
    begin
      pSource.Assign( SourceStrings );
    end
    else
    begin
      raise Exception.Create('Error Source does not exist!');
    end;
  end;
end;

constructor tErrorObject.Create;
begin
  inherited Create;
  ErrorObjectList.Add( self );
end;

destructor tErrorObject.Destroy;
begin
  if assigned( ErrorObjectList ) then
  begin
    ErrorObjectList.Remove( self );
  end;
  inherited;
end;

function tErrorObject.GetTabIndex: integer;
begin
  Result := ErrorObjectList.IndexOf( self );
end;

function tErrorObject.GetTabText: string;
begin
  // if there is a title, use that
  Result := Title;
  if Result = '' then
  begin
    // no Title - try file name
    if FileName <> '' then
    begin
      Result := ExtractFileName( FileName );
    end
    else
    begin
      if assigned( SourceStrings ) then
      begin
        Result := SourceStrings.ClassName;
      end
      else
      begin
        Result := '???';
      end;
    end;
  end;
end;

procedure tErrorObject.SetFileName(const Value: string);
begin
  if fFileName <> Value then
  begin
    fFileName := Value;
    ErrorObjectList.SetTabTexts;
  end;
end;

{ tErrorObjectList }

function tErrorObjectList.Add(const pErrorObject: tErrorObject): integer;
begin
  Result := inherited Add( pErrorObject );
  SetTabTexts;
end;

function tErrorObjectList.GetErrorObject(const i: integer): tErrorObject;
begin
  Result := Items[ i ] as tErrorObject;
end;

procedure tErrorObjectList.OnObjectTabListChange(Sender: tObject);
begin
  self.TabIndex := fObjectTabList.TabIndex;
end;

function tErrorObjectList.Remove(AObject: TObject): Integer;
begin
  Result := inherited Remove( AObject );
  SetTabTexts;
end;

procedure tErrorObjectList.SetObjectTabList(const Value: tTabControl);
begin
  fObjectTabList := Value;
  SetTabTexts;
  if assigned( fObjectTabList ) then
  begin
    fObjectTabList.OnChange := OnObjectTabListChange;
  end;
end;

procedure tErrorObjectList.SetSourceStrings(const Value: tStrings);
begin
  fSourceStrings := Value;
end;

procedure tErrorObjectList.SetTabIndex(const Value: integer);
var
  iErrorObject : tErrorObject;
begin
  fTabIndex := Value;
  if assigned( fObjectTabList ) then
  begin
    if fObjectTabList.TabIndex <> fTabIndex then
    begin
      fObjectTabList.TabIndex := fTabIndex;
      if Assigned( fSourceStrings ) then
      begin
        iErrorObject := fObjectTabList.Tabs.Objects[ Tabindex ] as tErrorObject;
        if assigned( iErrorObject ) then
        begin
          iErrorObject.AssignSource( fSourceStrings );
        end;
      end;
    end;
  end;
end;

procedure tErrorObjectList.SetTabTexts;
var
  i: integer;
begin
  if assigned( fObjectTabList ) then
  begin
    with fObjectTabList.Tabs do
    begin
      Clear;
      for i := 0 to self.Count - 1 do
      begin
        AddObject( ErrorObject[ i ].TabText, ErrorObject[ i ] );
      end;
      if self.TabIndex >= Count then
      begin
        self.TabIndex := Count - 1;
      end
      else
      begin
        fObjectTabList.TabIndex := self.TabIndex;
      end;
    end;
  end;

end;

initialization
  ErrorObjectList := tErrorObjectList.Create( FALSE );

finalization
  ErrorObjectList.Free;
  ErrorObjectList := nil;

end.
