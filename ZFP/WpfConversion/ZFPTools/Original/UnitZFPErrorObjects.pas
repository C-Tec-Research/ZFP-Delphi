unit UnitZFPErrorObjects;

{
  It is important to remember that these are transient objects added to error
  lists and can be destroyed at any time
}

interface

uses
  UnitFiles,
  SigFile;

type
  tZFPErrorObject = class
  protected
    fErrorObject: tObject;
  public
    constructor Create( pObject : tObject );
    property ErrorObject : tObject
             read fErrorObject;
  end;

  tZFPCandEError = class( tZFPErrorObject )
  private
    function GetCETreeProperty: tCETreeProperty;
  public
    constructor Create( pObject : tCETreeProperty );
    property CETreeProperty : tCETreeProperty
             read GetCETreeProperty;
  end;

  tZFPIntegerError = class( tZFPErrorObject )
  protected
    function GetValue: integer;
  public
    constructor Create( pObject : tSigIntegerProperty );
    property Value : integer
             read GetValue;
  end;

  tZFPSegmentError = class( tZFPIntegerError )
  public
    property Segment : integer
             read Getvalue;
  end;

  TBaseInputGroupError = class( TZFPErrorObject )
  public
    constructor Create( pObject : TBaseInputGroup );
  end;

implementation

{ tZFPCandEError }

constructor tZFPCandEError.Create(pObject: tCETreeProperty);
begin
  inherited Create( pObject );
end;

function tZFPCandEError.GetCETreeProperty: tCETreeProperty;
begin
  Result := fErrorObject as tCETreeProperty;
end;

{ tZFPErrorObject }

constructor tZFPErrorObject.Create(pObject: tObject);
begin
  inherited Create;

  fErrorObject := pObject;
end;

{ tZFPIntegerError }

constructor tZFPIntegerError.Create(pObject: tSigIntegerProperty);
begin
  inherited Create( pObject );
end;

function tZFPIntegerError.GetValue: integer;
begin
  with fErrorObject as tSigIntegerProperty do
  begin
    Result := ValueAsInt;
  end;
end;

{ tBaseInputGroupError }

constructor tBaseInputGroupError.Create(pObject: tBaseInputGroup);
begin
  inherited Create( pObject );
end;

end.
