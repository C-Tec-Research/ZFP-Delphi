unit UnitMacros;

{
  This is the foundation of a Macro handler.
  The macros are saved and loaded as JSON objects
  and as such can be send across TCP/IP if desired
}

interface

uses
  Rest.JSON,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  (*
  ISigMacro = interface
    ['{FA342E1C-03B4-412F-9DCB-62461EBDEED3}']
    function ToJSON : string;
    procedure Execute( const pTag : TObject );
    function GetName : string;
    procedure SetName( Value : string );
    function GetCommand : string;
    procedure SetCommand( Value : string );

    //function FromJSON( const pString : string ) : ISigMacro;

    property Name : string
             read GetName
             write SetName;
    property Command : string
             read GetCommand
             write SetCommand;

  end;
  *)

  //TSigMacro = class( TInterfacedObject, ISigMacro )
  TSigMacro = class
  private
    fName: string;
  protected
    fCommand: string;

    function GetName : string;
    procedure SetName( Value : string );
    function GetCommand : string;
    procedure SetCommand( Value : string );
  public
    constructor Create( const pName, pCmd : string ); overload;
    constructor Create; overload; virtual; // used for creating sample objects

    function ToJSON : string; virtual;
    class function FromJSON( const pString : string ) : TSigMacro; virtual; // override to generate specific macros
    procedure Execute( const pTag : TObject ); virtual;
    function Step( const pTag : TObject ) : boolean; virtual;

    property Name : string
             read GetName
             write SetName;

    property Command : string
             read GetCommand
             write SetCommand;
  end;

  TMacroList< T : TSigMacro > = class( TObjectList< T > )
  private
    fLastExecuted : integer;
    fSuspended : boolean;
    function GetMacro(const pWithName: string): T;
  public
    constructor Create;
    procedure Execute( const pTag : TObject ); overload;
    procedure Execute( const pTag : TObject; const pWithName : string ); overload;

    procedure Resume( const pTag : TObject ); virtual;
    procedure Suspend( const pTag : TObject ); virtual;

    property Macro[ const pWithName : string ] : T
             read GetMacro;

    property Suspended : boolean
             read fSuspended ;
  end;

  TOnExecuteSubMacro = procedure( const Sender : TObject; const pFile, pMacro : string ) of object; // a blank Macro means all

  TMacroStringLists< T : TSigMacro > = class;  // for lists we use the objects

  TMacroStringList< T : TSigMacro > = class( TStrings )
  private
    { This simple extension allows implicit LoadFromFile, SaveToFile etc.
      Not particularly efficient, but doesn't need to be...
    }
    fMacroList : TMacroList< T >;
    fSubMacros : TMacroStringLists< T >;
    fFileName : string;
    fAfterExecuteSubMacro: TOnExecuteSubMacro;
    fBeforeExecuteSubMacro: TOnExecuteSubMacro;
    fOnUnableToExecuteSubMacro: TOnExecuteSubMacro;
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;

  public
    constructor Create;
    destructor Destroy; override;

    property Name : string
             read fFileName;

    procedure LoadFromFile(const FileName: string); overload; override;

    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;

    procedure Execute( const pCalledBy : TMacroList< T > = nil ); overload; virtual;
    procedure Execute( const pWithName : string; const pCalledBy : TMacroList< T > = nil ); overload; virtual;

    property MacroList : TMacroList< T >      // use this to add/remove macros directly
             read fMacroList;

    function CreateSubMacro : TMacroStringList< T >; virtual;
    function LoadSubMacroList( const pFromFile : TFileName ) : TMacroStringList< T >;
    procedure ExecuteSubMacro( const pFromFile : TFileName ); overload; virtual;
    procedure ExecuteSubMacro( const pFromFile : TFileName; const pWithName : string ); overload; virtual;

    property BeforeExecuteSubMacro : TOnExecuteSubMacro
             read fBeforeExecuteSubMacro
             write fBeforeExecuteSubMacro;
    property AfterExecuteSubMacro : TOnExecuteSubMacro
             read fAfterExecuteSubMacro
             write fAfterExecuteSubMacro;
    property OnUnableToExecuteSubMacro : TOnExecuteSubMacro
             read fOnUnableToExecuteSubMacro
             write fOnUnableToExecuteSubMacro;
  end;

  TMacroStringLists< T : TSigMacro > = class( TObjectList< TMacroStringList<T>> )
    { Used to load macros for calling/executing from another macro}
  end;

implementation

{ TSigMacro }

constructor TSigMacro.Create(const pName, pCmd: string);
begin
  inherited Create;
  fName := pName;
  fCommand := pCmd;
end;

constructor TSigMacro.Create;
begin
  inherited Create;
end;

procedure TSigMacro.Execute;
begin
  { Used in case we cannot create an actual macro. Does nothing }
end;

class function TSigMacro.FromJSON(const pString : string ): TSigMacro;
begin
  Result := TJSON.JsonToObject<TSigMacro>( pString );
end;

function TSigMacro.GetCommand: string;
begin
  Result := fCommand;
end;

function TSigMacro.GetName: string;
begin
  Result := fName;
end;

procedure TSigMacro.SetCommand(Value: string);
begin
  fCommand := Value;
end;

procedure TSigMacro.SetName(Value: string);
begin
  fName := Value;
end;

function TSigMacro.Step(const pTag: TObject) : boolean;
begin
  Execute( pTag );
  Result := TRUE;
end;

function TSigMacro.ToJSON: string;
begin
  Result := TJSON.ObjectToJsonString( self );
end;

{ TMacroList<T> }

procedure TMacroList<T>.Execute( const pTag : TObject );
begin
  fLastExecuted := -1;
  Resume( pTag );
end;

constructor TMacroList<T>.Create;
begin
  inherited Create;
  fLastExecuted := -1;
end;

procedure TMacroList<T>.Execute( const pTag : TObject; const pWithName : string);
var
  iMacro : TSigMacro;
begin
  iMacro := Macro[ pWithName ];
  if assigned( iMacro ) then
  begin
    iMacro.Execute( pTag );
  end;
end;

procedure TMacroList<T>.Resume( const pTag : TObject );
var
  i: Integer;
begin
  i := fLastExecuted + 1;
  fSuspended := FALSE;
  while (not fSuspended) and (i < Count ) do
  begin
    fLastExecuted := i;
    Items[ i ].Execute( pTag );
    inc( i );
  end;
  if not fSuspended then
  begin
    // macro done - reset
    fLastExecuted := -1;
  end;
end;

function TMacroList<T>.GetMacro(const pWithName: string): T;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[ i ];
    if SameText( pWithName, Result.Name ) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

procedure TMacroList<T>.Suspend( const pTag : TObject );
begin
  fSuspended := TRUE;
end;

{ TMacroStringList<T> }

procedure TMacroStringList<T>.Clear;
begin
  inherited;
  fMacroList.Clear;
end;

constructor TMacroStringList<T>.Create;
begin
  inherited Create;
  fMacroList := TMacroList< T >.Create;
  fSubMacros := TMacroStringLists< T >.Create;
end;

function TMacroStringList<T>.CreateSubMacro: TMacroStringList<T>;
begin
  Result := TMacroStringList<T>.Create;
end;

procedure TMacroStringList<T>.Delete(Index: Integer);
begin
  inherited;
  fMacroList.Delete( Index );
end;

destructor TMacroStringList<T>.Destroy;
begin
  fMacroList.Free;
  fSubMacros.Free;
  inherited;
end;

procedure TMacroStringList<T>.Execute(const pWithName : string; const pCalledBy : TMacroList< T > = nil );
begin
  if assigned( pCalledBy ) then
  begin
    pCalledBy.Suspend( self );
  end;
  fMacroList.Execute( self, pWithName );
  if assigned( pCalledBy ) then
  begin
    pCalledBy.Resume( self );
  end;
end;

procedure TMacroStringList<T>.Execute( const pCalledBy : TMacroList< T > = nil );
begin
  if assigned( pCalledBy ) then
  begin
    pCalledBy.Suspend( self );
  end;
  fMacroList.Execute( self );
  if assigned( pCalledBy ) then
  begin
    pCalledBy.Resume( self );
  end;
end;

procedure TMacroStringList<T>.ExecuteSubMacro(const pFromFile: TFileName);
var
  iMacro : TMacroStringList< T >;
begin
  iMacro := LoadSubMacroList( pFromFile );
  if assigned( iMacro ) then
  begin
    if assigned( fBeforeExecuteSubMacro ) then
    begin
      fBeforeExecuteSubMacro( self, pFromFile, '' );
    end;
    iMacro.Execute( fMacroList );
    if assigned( fAfterExecuteSubMacro ) then
    begin
      fAfterExecuteSubMacro( self, pFromFile, '' );
    end;
  end else if assigned( fOnUnableToExecuteSubMacro ) then
  begin
    fOnUnableToExecuteSubMacro( self, pFromFile, '' );
  end;
end;

procedure TMacroStringList<T>.ExecuteSubMacro(const pFromFile: TFileName;
  const pWithName: string);
var
  iMacro : TMacroStringList< T >;
begin
  iMacro := LoadSubMacroList( pFromFile );
  if assigned( iMacro ) then
  begin
    if assigned( fBeforeExecuteSubMacro ) then
    begin
      fBeforeExecuteSubMacro( self, pFromFile, pWithName );
    end;
    iMacro.Execute( pWithName, fMacroList );
    if assigned( fAfterExecuteSubMacro ) then
    begin
      fAfterExecuteSubMacro( self, pFromFile, pWithName );
    end;
  end else if assigned( fOnUnableToExecuteSubMacro ) then
  begin
    fOnUnableToExecuteSubMacro( self, pFromFile, pWithName );
  end;
end;

function TMacroStringList<T>.Get(Index: Integer): string;
begin
  Result := fMacroList.Items[ Index ].ToJSON;
end;

function TMacroStringList<T>.GetCount: Integer;
begin
  Result := fMacroList.Count;
end;

procedure TMacroStringList<T>.Insert(Index: Integer; const S: string);
var
  iObject : TSigMacro;
begin
  inherited;
  iObject := T.FromJSON( S );
  if iObject is T then
  begin
    fMacroList.Insert( Index, iObject as T );
  end;
end;

procedure TMacroStringList<T>.LoadFromFile(const FileName: string);
begin
  inherited;
  fFileName := FileName;
end;

function TMacroStringList<T>.LoadSubMacroList(const pFromFile: TFileName) : TMacroStringList< T >;
var
  i: Integer;
begin
  // make sure not duplicate
  for i := 0 to fSubMacros.Count - 1 do
  begin
    Result := fSubMacros.Items[ i ];
    if SameText(Result.Name, pFromFile) then
    begin
      Exit;
    end;
  end;
  // else
  if FileExists( pFromFile ) then
  begin
    Result := CreateSubMacro;
    fSubMacros.Add( Result );
    Result.LoadFromFile( pFromFile );
  end
  else
  begin
    Result := nil;
  end;
end;

end.
