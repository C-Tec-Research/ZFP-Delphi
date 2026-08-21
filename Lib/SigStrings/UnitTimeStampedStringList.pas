unit UnitTimeStampedStringList;

interface

uses
  System.Classes,
  System.SysUtils;

type
  tSigTimeStampedStringList = class;

  tSigTimeStamp = class
  private
    fTimeStamp: TDateTime;
    fObject: tObject;
    fOwner: tSigTimeStampedStringList;
  protected
  public
    constructor Create( const pOwner : tSigTimeStampedStringList; const pObject : tObject = nil ); overload;
    constructor Create( const pOwner : tSigTimeStampedStringList; const pDateTime : TDateTime; const pObject : tObject = nil ); overload;

    destructor Destroy; override;

    property TimeStamp : TDateTime
             read fTimeStamp
             write fTimeStamp;
    property Data : tObject
             read fObject
             write fObject;
    property Owner : tSigTimeStampedStringList
             read fOwner;
  end;

  tSigTimeStampedStringList = class( tStringList )
  private
    FOwnsObject: Boolean;
    procedure QuickSort( L, R : integer );
    function GetTimeStamp(const i: integer): TDateTime;
    procedure SetTimeStamp(const i: integer; const Value: TDateTime);
  protected
    function GetObject(Index: Integer): TObject; override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
  public
    constructor Create; overload;
    constructor Create(OwnsObjects: Boolean); overload;
    destructor Destroy; override;
    function Add(const S: string): Integer; override;
    function AddObject(const S: string; AObject: TObject): Integer; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure InsertObject(Index: Integer; const S: string;
      AObject: TObject); override;
    procedure Sort; override;
    property OwnsObjects: Boolean
             read FOwnsObject
             write FOwnsObject;
    property TimeStamp[ const i: integer ] : TDateTime
             read GetTimeStamp
             write SetTimeStamp;
  end;

implementation

{ tSigTimeStamp }

constructor tSigTimeStamp.Create(const pOwner : tSigTimeStampedStringList; const pObject: tObject);
begin
  Create( pOwner, Now, pObject );
end;

constructor tSigTimeStamp.Create(const pOwner : tSigTimeStampedStringList; const pDateTime: TDateTime;
  const pObject: tObject);
begin
  inherited Create;
  fTimeStamp := pDateTime;
  fObject := pObject;
  fOwner := pOwner;
end;

destructor tSigTimeStamp.Destroy;
begin
  if fOwner.FOwnsObject then
  begin
    fObject.Free;
  end;

  inherited;
end;

{ tSigTimeStampedStringList }

function tSigTimeStampedStringList.Add(const S: string): Integer;
var
  iTimeStamp : tSigTimeStamp;
begin
  iTimeStamp := tSigTimeStamp.Create( self );
  inherited AddObject( S, iTimeStamp );
end;

function tSigTimeStampedStringList.AddObject(const S: string;
  AObject: TObject): Integer;
var
  iTimeStamp : tSigTimeStamp;
begin
  iTimeStamp := tSigTimeStamp.Create( self, AObject );
  Result := inherited AddObject( S, iTimeStamp );
end;

procedure tSigTimeStampedStringList.Assign(Source: TPersistent);
begin
  inherited;

end;

procedure tSigTimeStampedStringList.Clear;
begin
  inherited;

end;

constructor tSigTimeStampedStringList.Create(OwnsObjects: Boolean);
begin
  inherited Create( TRUE );
  FOwnsObject := OwnsObjects;
end;

constructor tSigTimeStampedStringList.Create;
begin
  inherited Create( TRUE );
  FOwnsObject := FALSE;
end;

procedure tSigTimeStampedStringList.Delete(Index: Integer);
begin
  inherited;

end;

destructor tSigTimeStampedStringList.Destroy;
begin

  inherited;
end;

function tSigTimeStampedStringList.GetObject(Index: Integer): TObject;
var
  iSigTimeStamp : tSigTimeStamp;
begin
  iSigTimeStamp := inherited GetObject( Index ) as tSigTimeStamp;
  Result := iSigTimeStamp.Data;
end;

function tSigTimeStampedStringList.GetTimeStamp(const i: integer): TDateTime;
var
  iSigTimeStamp : tSigTimeStamp;
begin
  iSigTimeStamp := inherited GetObject( i ) as tSigTimeStamp;
  Result := iSigTimeStamp.TimeStamp;
end;

procedure tSigTimeStampedStringList.Insert(Index: Integer; const S: string);
var
  iTimeStamp : tSigTimeStamp;
begin
  iTimeStamp := tSigTimeStamp.Create( self );
  inherited InsertObject( Index, S, iTimeStamp );

end;

procedure tSigTimeStampedStringList.InsertObject(Index: Integer;
  const S: string; AObject: TObject);
var
  iTimeStamp : tSigTimeStamp;
begin
  iTimeStamp := tSigTimeStamp.Create( self, AObject );
  inherited InsertObject( Index, S, iTimeStamp );

end;


procedure tSigTimeStampedStringList.PutObject(Index: Integer; AObject: TObject);
var
  iSigTimeStamp : tSigTimeStamp;
begin
  iSigTimeStamp := inherited GetObject( Index ) as tSigTimeStamp;
  iSigTimeStamp.Data := AObject;

end;

procedure tSigTimeStampedStringList.QuickSort( L, R: integer);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while TimeStamp[ I ] < TimeStamp[ P ] do
      begin
        Inc(I);
      end;
      while TimeStamp[ I ] > TimeStamp[ P ] do
      begin
        Dec(J);
      end;
      if I <= J then
      begin
        if I <> J then
        begin
          Exchange(I, J);
        end;
        if P = I then
        begin
          P := J;
        end
        else if P = J then
        begin
          P := I;
        end;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
    begin
      QuickSort(L, J);
    end;
    L := I;
  until I >= R;
end;

procedure tSigTimeStampedStringList.SetTimeStamp(const i: integer;
  const Value: TDateTime);
begin

end;

procedure tSigTimeStampedStringList.Sort;
begin
  if (not Sorted) and (Count > 1) then
  begin
    Changing;
    QuickSort( 0, Count - 1 );
    Changed;
  end;


end;

end.
