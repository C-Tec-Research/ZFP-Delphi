unit UnitSetAnalysis;

interface

  uses
    System.Classes,
    System.StrUtils,
    System.SysUtils,
    TypedObjectList,
    SigParse;


type
  TBitSetLine = class
  private
    fBitsetBase: string;
    fBitSet: string;
  protected
  public
    constructor Create( const pBitSet, pBitSetBase : string );
    property BitSet : string
             read fBitSet;
    property BitSetBase : string
             read fBitsetBase;
  end;

  TBitSetLines = class( TTypedObjectList<TBitSetLine> )
  private
    function GetBitSetBase(const pBitSet: string): string;
  protected
  public
    procedure ParseStrings( const pStrings : TStrings );

    property BitSetBase[ const pBitSet : string ] : string
             read GetBitSetBase;
  end;

implementation

{ TBitSetLines }

function TBitSetLines.GetBitSetBase(const pBitSet: string): string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    with Item[ i ] do
    begin
      if SameText(BitSet, pBitset) then
      begin
        Result := BitSetBase;
        exit;
      end;
    end;
  end;
  // else
  Result := '';
end;

procedure TBitSetLines.ParseStrings(const pStrings: TStrings);
var
  i, iPos: Integer;
  iBitSet : string;
  iBitSetBase : string;
  iResult : tSigNETParseResult;
  iSigProperty, iSigIndex, iSigValue, iSigComment : string;
begin
  for i := 0 to pStrings.Count - 1 do
  begin
    // we are looking for xxx = set of yyy;
    // we assume on one line. A weakness but a standard that we adhere to.
    iResult := SigNETParseDetail( pStrings[ i ], iSigProperty, iSigIndex, iSigValue, iSigComment );
    case iResult of
      spNone: ;
      spEq:
      begin
        if SameText( Copy( iSigValue, 1, 4), 'set ')  then
        begin
          iSigValue := Trim( Copy( iSigValue, 4 ));
          if SameText( Copy( iSigValue, 1, 3), 'of ')  then
          begin
            iSigValue := Trim( Copy( iSigValue, 3 ));
            iPos := Pos( ';', iSigValue );
            if iPos > 0 then
            begin
              iSigValue := Copy( iSigValue, 1, iPos - 1 );
            end;
            iBitset := iSigProperty;
            iBitSetBase := iSigValue;
            if BitSetBase[ iBitSet ] = '' then
            begin
              Add( TBitSetLine.Create( iBitSet, iBitsetBase ) );
            end;
          end;
        end;
      end;
      spUnbalancedBraces: ;
      spGT: ;
      spLT: ;
      spGE: ;
      spLE: ;
      spNE: ;
      spPlus: ;
      spMinus: ;
      spTimes: ;
      spDiv: ;
    end;
  end;
end;

{ TBitSetLine }

constructor TBitSetLine.Create(const pBitSet, pBitSetBase: string);
begin
  inherited Create;

  fBitSet := pBitSet;
  fBitSetBase := pBitSetBase;
end;

end.
