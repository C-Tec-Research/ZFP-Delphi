unit UnitParseZFPRec;

interface

uses
  Classes,
  SysUtils;

type
  tRecvRecType = ( rrt_Other, rrt_BEGIN, rrt_END, rrt_REQUEST, rrt_ACK, rrt_NAK,
                   rrt_CSFAIL, rrt_TIMEOUT, rrt_Error, rrt_IAM, rrt_WAIT );

function ParseZFPRec( const pRec : string; pResult : TStrings; var pID : integer;
                      var pPanel : integer; var pParm : integer ) : tRecvRecType;

implementation

function ParseZFPRec( const pRec : string; pResult : TStrings; var pID : integer;
                      var pPanel : integer; var pParm : integer ) : tRecvRecType;
var
  iPos : integer;
  iRec, iVal : string;
  iCol : integer;
begin
  Result := rrt_Error; // assume failure
  pID := -1;
  // leave panel intact
  pParm := -1;
  pResult.Clear;
  iRec := pRec;
  iPos := Pos( ',', iRec );
  iCol := 0;
  while iPos > 0 do
  begin
    iVal := Copy( iRec, 1, iPos - 1 );
    inc( iCol );
    pResult.Add(iVal );
    case iCol of
      1: // record ID
      begin
        pID := StrToIntDef( iVal, -1 );
      end;
      2: // possibly record type
      begin
        if SameText( iVal, 'BEGIN' ) then
        begin
          Result := rrt_BEGIN;
        end
        else if SameText( iVal, 'END' ) then
        begin
          Result := rrt_END;
        end
        else if SameText( iVal, 'REQUEST' ) then
        begin
          Result := rrt_REQUEST;
        end
        else if SameText( iVal, 'ACK' ) then
        begin
          Result := rrt_ACK;
        end
        else if SameText( iVal, 'NAK' ) then
        begin
          Result := rrt_NAK;
        end
        else if SameText( iVal, 'CSFAIL' ) then
        begin
          Result := rrt_CSFAIL;
        end
        else if SameText( iVal, 'TIMEOUT' ) then
        begin
          Result := rrt_TIMEOUT;
        end
        else if SameText( iVal, 'IAM' ) then
        begin
          Result := rrt_IAM;
        end
        else if SameText( iVal, 'WAIT' ) then
        begin
          Result := rrt_WAIT;
        end
        else
        begin
          Result := rrt_OTHER;
        end
      end;
      3:
      begin
        case Result of
          rrt_Other: ; // do nothing
          rrt_BEGIN,
          rrt_END,
          rrt_REQUEST:
          begin
            // column 3 is panel ID
            pPanel := StrToIntDef( iVal, -1 );
          end;
          rrt_WAIT,
          rrt_ACK,
          rrt_NAK,
          rrt_CSFAIL:
          begin
            // column 3 is a checksum rcvd by the panel, or, in case of WAIT, special delay
            pParm := StrToIntDef( iVal, -1 );
          end;
          rrt_TIMEOUT: ;
          rrt_Error: ;
        end;
      end;
    end;
    iRec := Copy( iRec, iPos + 1, Length( iRec ));
    iPos := Pos( ',', iRec );
  end;
  inc( iCol );
  pResult.Add(iRec );
  case iCol of
    1: // record ID
    begin
      pID := StrToIntDef( iRec, -1 );
    end;
    2: // possibly record type
    begin
      if SameText( iRec, 'BEGIN' ) then
      begin
        Result := rrt_BEGIN;
      end
      else if SameText( iRec, 'END' ) then
      begin
        Result := rrt_BEGIN;
      end
      else if SameText( iRec, 'REQUEST' ) then
      begin
        Result := rrt_REQUEST;
      end
      else if SameText( iRec, 'ACK' ) then
      begin
        Result := rrt_ACK;
      end
      else if SameText( iRec, 'NAK' ) then
      begin
        Result := rrt_NAK;
      end
      else if SameText( iRec, 'CSFAIL' ) then
      begin
        Result := rrt_CSFAIL;
      end
      else if SameText( iRec, 'TIMEOUT' ) then
      begin
        Result := rrt_TIMEOUT;
      end
      else
      begin
        Result := rrt_OTHER;
      end
    end;
    3:
    begin
      case Result of
        rrt_Other: ; // do nothing
        rrt_BEGIN,
        rrt_END,
        rrt_REQUEST:
        begin
          // column 3 is panel ID
          pPanel := StrToIntDef( iRec, -1 );
        end;
        rrt_WAIT,
        rrt_ACK,
        rrt_NAK,
        rrt_CSFAIL:
        begin
          // column 3 is a checksum rcvd by the panel, or, in case of WAIT, delay supplied by panel
          pParm := StrToIntDef( iRec, -1 );
        end;
        rrt_TIMEOUT: ;
        rrt_Error: ;
      end;
    end;
  end;
end;

end.
