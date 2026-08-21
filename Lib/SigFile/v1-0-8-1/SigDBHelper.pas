unit SigDBHelper;

(*******************************************************************************
 *                                                                             *
 * Used as interfaces between visual elements and the database.                *
 *                                                                             *
 *******************************************************************************)
interface

uses
  SigDBRawDB;

type
  TSigDBHelper = class;

  TSigDBHelperEvent = procedure( const Sender : TSigDBHelper ) of object;

  TSigDBHelper = class
  private
    fCurrentRec: int64;
    fNextUpdateIsAdd: boolean;
  protected
    fIndexFile: tSigDBIndexFile;
    procedure SetCurrentRec(const Value: int64);
              { Do not override this function. Override ShowCurrentFields instead;
                visual components }
    procedure SetNextUpdateIsAdd(const Value: boolean); virtual;
    procedure ShowCurrentFields; virtual; abstract;
              { override to set the visual editors from the field values }
    procedure SetCurrentFields; virtual; abstract;
              { override to set the field values from the visual editors }
  public
    constructor Create( const pIndexFile : tSigDBIndexFile );

    property IndexFile : tSigDBIndexFile
             read fIndexFile;
    property CurrentRec : int64
             read fCurrentRec
             write SetCurrentRec;
    property NextUpdateIsAdd : boolean
             read fNextUpdateIsAdd
             write SetNextUpdateIsAdd;

    procedure Update;
              { do no override this function; override SetCurrentFields instead
                by copying visual editors to current rec }
    procedure AbortUpdate;
    procedure DeleteUpdate;

  end;

implementation

{ TSigDBHelper }

procedure TSigDBHelper.AbortUpdate;
begin
  fNextUpdateIsAdd := FALSE;
  SetCurrentRec( fCurrentRec );
end;

constructor TSigDBHelper.Create(const pIndexFile: tSigDBIndexFile);
begin
  inherited Create;
  fIndexFile := pIndexFile;
end;

procedure TSigDBHelper.DeleteUpdate;
begin
  if fNextUpdateIsAdd then
  begin
    // just remove the update and refresh the fields - same as AbortUpdate
    AbortUpdate;
  end
  else
  begin
    fIndexFile.Delete( fCurrentRec );
  end;
end;

procedure TSigDBHelper.SetCurrentRec(const Value: int64);
begin
  fCurrentRec := Value;
  fIndexFile.Lock;
  try
    fIndexFile.ReadData( Value );
    ShowCurrentFields;
  finally
    fIndexFile.Unlock;
  end;
end;

procedure TSigDBHelper.SetNextUpdateIsAdd(const Value: boolean);
begin
  fNextUpdateIsAdd := Value;
end;

procedure TSigDBHelper.Update;
begin
  fIndexFile.Lock;
  try
    fIndexFile.ReadData( fCurrentRec );
    SetCurrentFields;
    fIndexFile.UpdateData;
  finally
    fIndexFile.Unlock;
  end;
end;

end.
