unit AVRBootLoad;

(*
  This supports the AVRCo bootloader by creating the data to be sent to
  bootloader.
*)

interface

uses
  System.INIFiles,
  System.SysUtils,
  UnitReadHexFiles;

type

  THexFileType = (hexFlash, hexEEP, hexUsr );

  TBootFile = class( THexFile )
  private
    fFileType: THexFileType;
  public
    constructor Create( const pFileType : THexFileType; const pMemSize, pPageSize : integer );

    property FileType : THexFileType
             read fFileType;
  end;

  TTransferState = ( tsComplete,
                     tsInError,
                     tsRequestingLoaderID,
                     tsSendingPageAddress );

  TTransferAction = ( taHostControl,
                      taSendingFlash,
                      taSendingEEP,
                      taSendingUser,
                      taSendingFlashAll, // part of sending all
                      taSendingEEPAll,   // part of sending all
                      taSendingUsrAll);  // part of sending all

  TTransferErrorReason = ( errNone,
                           errNoHexFile,
                           errWaitingMoreChars,
                           errUnexpectedChar,
                           errTimeout,
                           errUserAbort,
                           errUnhandled );

  TTransferInfo = record
  private
    procedure InitialiseRequest;
    procedure RcvCharIdle;
    procedure RcvCharLoaderID;
  public
    TransferAction : TTransferAction;
    TransferState : TTransferState;
    HexFile : TBootFile;
    LastAddressSend : int64;
    ErrorReason : TTransferErrorReason;
    RequestString: string;
    ResponseString: string;
  public
    procedure AbortTransfer( const pTransferReason : TTransferErrorReason); // called e.g. after a time out

    procedure RcvChar( const pChar : char );

    // requests
    procedure RequestLoaderID;
  end;

  TAVRBootLoader = class
  private
    fHexFile : TBootFile;
    fEEPFile : TBootFile;
    fUsrFile : TBootFile;
    procedure LoadFile( var pFile : TBootFile; const pFileType : THexFileType; const pFileName : string; const pMemSize, pPageSize : integer );
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadHexFile( const pFileName : string; const pMemSize, pPageSize : integer{ = $8FFFF} );
    procedure LoadEEPFile( const pFileName : string; const pMemSize, pPageSize : integer{ = $FFFF} );
    procedure LoadUsrFile( const pFileName : string; const pMemSize, pPageSize : integer{ = $FFFF} );

    procedure LoadAllFiles( const pFileName : string );

  end;


implementation

{ TAVRBootLoader }

constructor TAVRBootLoader.Create;
begin
  inherited Create;

end;

destructor TAVRBootLoader.Destroy;
begin
  fHexFile.Free;
  inherited;
end;

procedure TAVRBootLoader.LoadEEPFile(const pFileName: string; const pMemSize, pPageSize : integer);
begin
  LoadFile( fEEPFile, hexEEP, pFileName, pMemSize, pPageSize );
end;

procedure TAVRBootLoader.LoadFile(var pFile: TBootFile; const pFileType : THexFileType; const pFileName: string;
  const pMemSize, pPageSize: integer);
begin
  if not assigned( pFile ) then
  begin
    pFile := TBootFile.Create( pFileType, pMemSize, pPageSize );
  end
  else
  begin
    pFile.MemSize := pMemSize;
    pFile.PageSize := pPageSize;
    pFile.fFileType := pFileType;
  end;
  pFile.LoadFromFile( pFileName );
end;

procedure TAVRBootLoader.LoadHexFile(const pFileName: string; const pMemSize, pPageSize : integer);
begin
  LoadFile( fHexFile, hexFlash, pFileName, pMemSize, pPageSize );
end;

procedure TAVRBootLoader.LoadAllFiles(const pFileName: string); // should not containe an extension, but can
var
  iProjectFile : TINIFile;
  iFile : string;
  iPath : string;
  iBaseFile: string;
  iFlashSize, iEEPSize, iUsrSize : integer;
  iFlashPageSize, iEEPPageSize, iUsrPageSize : integer;
begin
  // reads the project file to load other entities
  iFile := ChangeFileExt( pFileName, '.ppro' );
  iUsrSize := $FFFF;
  iUsrPageSize := $FFFF;
  if FileExists( iFile ) then
  begin
    iProjectFile := TINIFile.Create( iFile );
    try
      iPath := iProjectFile.ReadString( 'Output Paths', 'HexPath', '');
      iFlashSize := iProjectFile.ReadInteger( 'MainParams', 'FlashMax', $8FFFF );
      iEEPSize := iProjectFile.ReadInteger( 'MainParams', 'EEpromMax', $FFFF );
      iFlashPageSize := iProjectFile.ReadInteger( 'MainParams', 'PageSize', 256 );
      iEEPPageSize := iProjectFile.ReadInteger( 'MainParams', 'EPageSize', 32 );
    finally
      iProjectFile.Free;
    end;
  end
  else
  begin
    // try individual files;
    iPath := '';
    iFlashSize := $8FFFF;
    iEEPSize := $FFFF;
    iFlashPageSize := 256;
    iEEPPageSize := 32;
  end;
  if iPath = '' then
  begin
    iPath := ExtractFilePath( pFileName );
  end;
  iBaseFile := ChangeFileExt( ExtractFileName( pFileName ), '');

  FreeAndNil( fHexFile );
  FreeAndNil( fEEPFile );
  FreeAndNil( fUsrFile );

  iFile := iPath + iBaseFile + '.hex';
  if FileExists( iFile ) then
  begin
    LoadHexFile( iFile, iFlashSize, iFlashPageSize );
    iFile := iPath + iBaseFile + '.eep'; // optional
    if FileExists( iFile ) then
    begin
      LoadEEPFile( iFile, iEEPSize, iEEPPageSize );
    end;
    iFile := iPath + iBaseFile + '.usr'; // optional
    if FileExists( iFile ) then
    begin
      LoadUsrFile( iFile, iUsrSize, iUsrPageSize );
    end;
  end
  else
  begin
    raise Exception.Create(iFile + ' not found');
  end;
end;

procedure TAVRBootLoader.LoadUsrFile(const pFileName: string;
  const pMemSize, pPageSize: integer);
begin
  LoadFile( fUsrFile, hexUsr, pFileName, pMemSize, pPageSize );
end;

{ TTransferInfo }

procedure TTransferInfo.AbortTransfer(
  const pTransferReason: TTransferErrorReason);
begin
  TransferState := tsComplete;
  TransferAction := taHostControl;
end;

procedure TTransferInfo.InitialiseRequest;
begin
  ResponseString := '';
  ErrorReason := errNone;
  LastAddressSend := 0;
end;

procedure TTransferInfo.RcvChar(const pChar: char);
begin
  ResponseString := ResponseString + pChar;
  case TransferState of
    tsComplete:                         RcvCharIdle;
    tsInError:                      RcvCharIdle;
    tsRequestingLoaderID: ;
    tsSendingPageAddress: ;
  end;
end;

procedure TTransferInfo.RcvCharIdle;
begin
  ErrorReason := errUnexpectedChar;
  TransferState := tsInError;
end;

procedure TTransferInfo.RcvCharLoaderID;
begin
  if Length( ResponseString ) >= 2 then
  begin
    if ResponseString = 'FT' then
    begin
      TransferState := tsComplete;
      ErrorReason := errNone;
    end
    else
    begin
      TransferState := tsInError;
      ErrorReason := errUnexpectedChar;
    end;
  end
  else if Length( ResponseString ) = 1 then
  begin
    if ResponseString <> 'F' then
    begin
      TransferState := tsInError;
      ErrorReason := errUnexpectedChar;
    end;
  end;
end;

procedure TTransferInfo.RequestLoaderID;
begin
  InitialiseRequest;
  RequestString := '?';
  TransferState := tsRequestingLoaderID;
end;

{ TBootFile }

constructor TBootFile.Create(const pFileType: THexFileType; const pMemSize,
  pPageSize: integer);
begin
  inherited Create( pMemSize, pPageSize );
  fFileType := pFileType;
end;

end.
