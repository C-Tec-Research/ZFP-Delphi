unit SigFileRichEdit;

interface

uses
  SigFile,
  ComCtrls,
  ErrorList,
  Classes,
  AnsiStrings,
  SysUtils;

  {
    This creates a sigFile Wrapper to an RTF object.
    It requires a RichEdit component to be added to it and
    a tSigFileProperty ownwer (not a SigCompoundObject).
    It's property value on saving is the file name
    of the RTF file which should be in the same directory
    as the parent file
  }

type
  TSigRTFProperty = class( TSigSimpleProperty )
  private
    fRichEdit: tRichEdit;
    fOwner : tSigFileProperty;
    function GetRelativeFileName: string;
    procedure SetRelativeFileName(const pValue: string);
    function GetLines: TStrings;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
    property RichEdit : tRichEdit
             read fRichEdit
             write fRichEdit;
    property FileName : string
             read GetRelativeFileName
             write SetRelativeFileName;
    procedure Save( pSaveFile : tStrings; pShortFormat : boolean = FALSE; pIndent : integer = 0  ); override;
    function Load( pFile : tStrings; var pLine : integer; pErrors : tErrorList = nil ) : boolean; override;
    procedure Clear; override;
    property Lines : TStrings
             read GetLines;
  end;

implementation

{ TSigRTFProperty }

procedure TSigRTFProperty.Clear;
begin
  inherited;
  if assigned( fRichEdit ) then
  begin
    fRichEdit.Lines.Clear;
  end;
end;

constructor TSigRTFProperty.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fOwner := pOwner as TSigFileProperty;
end;

function TSigRTFProperty.GetLines: TStrings;
begin
  if assigned( fRichEdit ) then
  begin
    Result := fRichEdit.Lines;
  end
  else
  begin
    Result := nil;
  end;
end;

function TSigRTFProperty.GetRelativeFileName: string;
begin
  Result := Value;
end;

function TSigRTFProperty.Load(pFile: tStrings; var pLine: integer;
  pErrors: tErrorList): boolean;
var
  sFileName : string;
begin
  Result := inherited Load( pFile, pLine, pErrors );
  if assigned( fRichEdit ) then
  begin
    if FileName = '' then
    begin
      // by default same name as owner, but with RTF extension
      sFileName := ChangeFileExt( fOwner.FileName, '.rtf' );
    end
    else
    begin
      sFileName := ExtractFilePath( fOwner.FileName ) + FileName;
    end;
    if FileExists( sFileName ) then
    begin
      fRichEdit.Lines.LoadFromFile( sFileName );
    end
    else
    begin
      fRichEdit.Lines.Clear;
    end;
  end
  else
  begin
    if assigned( pErrors ) then
    begin
      pErrors.Add( pLine, 'Error - No component to receive RTF file "' + FileName + '".' );
    end;
  end;
end;

procedure TSigRTFProperty.Save(pSaveFile: tStrings; pShortFormat: boolean;
  pIndent: integer);
var
  sFileName : string;
begin
  inherited;
  if assigned( fRichEdit ) then
  begin
    if FileName <> '' then
    begin
      sFileName := ExtractFilePath( fOwner.FileName ) + FileName;
      fRichEdit.Lines.SaveToFile( sFileName );
    end;
  end;
end;

procedure TSigRTFProperty.SetRelativeFileName(const pValue: string);
begin
  Value := pValue;
end;

end.
