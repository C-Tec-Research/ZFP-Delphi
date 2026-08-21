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
    fSigFileBase: TSigDBFileBase;
    //fIndexDB: tSigDBIndex;
    function GetDataFile: TSigDBFileBase;
    function GetIndexFile: TSigDBIndexFile;
  protected
    function GetSigFileBase: TSigDBFileBase; virtual;
    procedure SetSigFileBase(const Value: TSigDBFileBase); virtual;
    procedure SetCurrentRec(const Value: int64); virtual;
    procedure ShowCurrentFields; virtual; abstract;
              { override to set the visual editors from the field values }
    procedure SetCurrentFields; virtual; abstract;
              { override to set the field values from the visual editors }
  public
    property SigDBFileBase : TSigDBFileBase
             read GetSigFileBase
             write SetSigFileBase;
    property CurrentRec : int64
             read fCurrentRec
             write SetCurrentRec;

    property DataFile : TSigDBFileBase
             read GetDataFile;
    property IndexFile : TSigDBIndexFile
             read GetIndexFile;

    //property IndexDB : tSigDBIndex
    //         read fIndexDB
    //         write fIndexDB;

    function FieldTitle( const pFieldID : integer ) : string; virtual;
    function FieldCount : integer; virtual;
    function FieldAsText( const pFieldID : integer ) : string; virtual;
  end;


implementation

{ TSigDBHelper }

function TSigDBHelper.FieldAsText(const pFieldID: integer): string;
begin
  if assigned( DataFile ) then
  begin
    Result := DataFile.FieldAsText( pFieldID );
  end
  else
  begin
    Result := '';
  end;
end;

function TSigDBHelper.FieldCount: integer;
begin
  if assigned( DataFile ) then
  begin
    Result := DataFile.FieldCount;
  end
  else
  begin
    Result := 0;
  end;
end;

function TSigDBHelper.FieldTitle(const pFieldID: integer): string;
begin
  if assigned( DataFile ) then
  begin
    // for now keep original order. Later use index field order maybe
    Result := DataFile.FieldTitle( pFieldID );
  end
  else
  begin
    Result := '';
  end;
end;

function TSigDBHelper.GetDataFile: TSigDBFileBase;
begin
  if assigned( fSigFileBase ) then
  begin
    if fSigFileBase is TSigDBIndexFile then
    begin
      Result := (fSigFileBase as TSigDBIndexFile).DataFile;
    end
    else
    begin
      Result := fSigFileBase;
    end;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigDBHelper.GetIndexFile: TSigDBIndexFile;
begin
  if assigned( fSigFileBase ) then
  begin
    if fSigFileBase is TSigDBIndexFile then
    begin
      Result := fSigFileBase as TSigDBIndexFile;
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigDBHelper.GetSigFileBase: TSigDBFileBase;
begin
  Result := fSigFileBase;
end;

procedure TSigDBHelper.SetCurrentRec(const Value: int64);
begin
  if assigned( fSigFileBase ) then
  begin
    fCurrentRec := Value;
    fSigFileBase.Lock;
    try
      fSigFileBase.Read( Value );
      ShowCurrentFields;
    finally
      fSigFileBase.Unlock;
    end;
  end;
end;

procedure TSigDBHelper.SetSigFileBase(const Value: TSigDBFileBase);
begin
  fSigFileBase := Value;
end;

end.
