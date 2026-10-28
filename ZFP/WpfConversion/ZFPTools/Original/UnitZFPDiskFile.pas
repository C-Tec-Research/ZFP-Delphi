unit UnitZFPDiskFile;

{
  These are files that can be sent to a panel
}

interface
  uses
    System.SysUtils,
    System.Classes,
    System.IOUtils,
    ErrorList,
    UnitSigStrings,
    Common,
    SigFile,
    VCL.StdCtrls;

type
  tZFPDiskFile = class( tSigRelativeFileProperty )
  private
    function GetFileExists: boolean;
  protected
  public
    property FileExists : boolean
             read GetFileExists;
    procedure ExportFile( const pPanel : integer; pList : tStrings; const FileOverride : string = ''; const ClearOnEntry : boolean = TRUE ); virtual;
    procedure ImportFile( var pPanel : integer; const pList : tStrings; var pIndex : integer );
    function ImportFileRequest( const pPanel : integer; const pNameOverride : string ) : string;
    procedure SaveDataFile( const pData : tStrings );
    procedure SaveDataFileAs( const pFileName : string; const pData : tStrings; pChangeValue : boolean = TRUE );
  end;

  tZFPTempTextFile = class( TStringList )
    // This is not a real file and is just used to transfer generic data, although
    // it can, of course, be loaded from and save to a real file.
  private
    fFileName: string;
  protected
  public
    property FileName : string
             read fFileName
             write fFileName;
    procedure ExportFile( const pPanel : integer; pList : tStrings; const TrimLines : boolean = TRUE; const ClearOnEntry : boolean = TRUE );
    procedure ImportFile( var pPanel : integer; const pList : tStrings; var pIndex : integer; pIsSigMemo : boolean = TRUE );
    function ImportFileRequest( const pPanel : integer ) : string;

  end;

  tZFPDiskFileList = class( tSigObjectList )
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty ); override;
  end;

implementation

{ tZFPDiskFileList }

constructor tZFPDiskFileList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tZFPDiskFile );

end;

{ tZFPDiskFile }

procedure tZFPDiskFile.ExportFile( const pPanel : integer; pList: tStrings; const FileOverride : string; const ClearOnEntry : boolean);
var
  iCS : word;
  iByte : byte;
  i, j, iOffset, iLen : integer;
  iBytes : TBytes;
  iRec : string;
  iName : string;
const
  MaxRecLen = 48; // data entries
begin
  if ClearOnEntry then
  begin
    pList.Clear;
  end;
  if FileOverride = '' then
  begin
    iName := ExtractFileName( Value );
  end
  else
  begin
    iName := FileOverride;
  end;
  if FileExists then
  begin
    pList.Add( '300,BEGIN,' + IntToStr( pPanel ));
    pList.Add( '300,1,"' + iName + '"' );
    iBytes := tFile.ReadAllBytes( Value );
    // add data
    iCS := Word( -1 );
    iLen := Length( iBytes );
    iOffset := 0;
    j := 0;
    iRec := '300,2,' + IntToStr( iOffset ) + ',';
    if iLen > MaxRecLen then
    begin
      iRec := iRec + IntToStr( MaxRecLen );
    end
    else
    begin
      iRec := iRec + IntToStr( iLen );
    end;
    for i := 0 to Length( iBytes ) - 1 do
    begin
      iByte := iBytes[ i ];
      iCS := iCS + iByte;
      iRec := iRec + ',' + IntToStr( iByte );
      inc( iOffset );
      inc( j );
      dec( iLen );
      if j >= MaxRecLen then
      begin
        j := 0;
        pList.Add( iRec );
        iRec := '300,2,' + IntToStr( iOffset ) + ',';
        if iLen > MaxRecLen then
        begin
          iRec := iRec + IntToStr( MaxRecLen );
        end
        else
        begin
          iRec := iRec + IntToStr( iLen );
        end;
      end;
    end;
    // last rec, if any
    if j <> 0 then
    begin
      pList.Add( iRec );
    end;
    // CS
    pList.Add( '300,3,' + IntToStr( iCS ));
    pList.Add( '300,END,' + IntToStr( pPanel ) )
  end;
end;

function tZFPDiskFile.GetFileExists: boolean;
begin
  if Value = '' then
  begin
    Result := FALSE;
  end
  else begin
    Result := System.SysUtils.FileExists( Value );
  end;
end;

procedure tZFPDiskFile.ImportFile( var pPanel : integer; const pList : tStrings; var pIndex : integer );
var
  i, j, k : integer;
  iList : tInfiniteStringList;      // needs smartening up!
  iBytes : TBytes;
  iLen, iRecLen : integer;
begin
  iList := tInfiniteStringList.Create;
  iLen := 0;
  try
    for i := pIndex to pList.Count - 1 do
    begin
      CommaListToStringList( pList[ i ], iList, TRUE );
      if iList[ 1 ] = 'BEGIN' then
        // ignore
      else if iList[ 1 ] = 'END' then
      begin
        pIndex := i;
        tFile.WriteAllBytes( Value, iBytes );
        exit;
      end
      else if iList[ 1 ] = '1' then
      begin
        //Value := iList[ 2 ];     // file name on panel, which we ignore
      end
      else if iList[ 1 ] = '2' then
      begin
{
    iRec := '300,2,' + IntToStr( iOffset ) + ',';
    if iLen > MaxRecLen then
    begin
      iRec := iRec + IntToStr( MaxRecLen );
    end
    else
    begin
      iRec := iRec + IntToStr( iLen );
    end;
}
        // iList[ 2 ] = Offset, which we ignore
        // iList[ 3 ] is record length, which we add to current
        iRecLen := StrToInt( iList[ 3 ] );
        SetLength( iBytes, iLen + iRecLen );
        j := 4;
        for k := iLen to iLen + iRecLen - 1 do
        begin
          iBytes[ k ] := StrToInt( iList[ j ] );
          inc( j );
        end;
        inc( iLen, iRecLen);
      end;
    end;
    // No END record if we get here
    raise Exception.Create('No ''END'' record found');
  finally
    iList.Free;
    //SetLength( iBytes, 0 ); // free the space
  end;
end;

function tZFPDiskFile.ImportFileRequest(const pPanel: integer; const pNameOverride : string): string;
begin
  Result := '300,REQUEST,' + IntToStr( pPanel ) + ',' + pNameOverride;
end;

procedure tZFPDiskFile.SaveDataFile(const pData: tStrings );
begin
  SaveDataFileAs( Value, pData, FALSE );
end;

procedure tZFPDiskFile.SaveDataFileAs(const pFileName: string;
  const pData: tStrings; pChangeValue: boolean);
var
  iBytes : TBytes;
  iItems : tInfiniteStringList;
  i, j, k, iLen : integer;
  iErrorList : tErrorList;
  iError : string;
begin
  iItems := tInfiniteStringList.Create;
  iErrorList := OwnerFile.ErrorList;
  try
    i := 0;
    if pData.Count < 4 then
    begin
      iError := OwnerFile.Translate( 'Illegal Disk File Source (too small)' );
      if assigned( iErrorList ) then
      begin
        iErrorList.Add( es_Error, 0, iError, self );
        exit;
      end
      else
      begin
        raise Exception.Create( iError );
      end;
    end;
    CommaListToStringList( pData[ i ], iItems, TRUE );
    // should be  300,BEGIN,xx
    if iItems[ 0 ] <> '300' then
    begin
      iError := OwnerFile.Translate( 'Illegal Disk File Source (wrong record type)' );
      if assigned( iErrorList ) then
      begin
        iErrorList.Add( es_Error, 0, iError, self );
      end
      else
      begin
        raise Exception.Create( iError );
      end;
    end;
    if iItems[ 1 ] <> 'BEGIN' then
    begin
      iError := OwnerFile.Translate( 'Illegal Disk File Source (no BEGIN record)');
      if assigned( iErrorList ) then
      begin
        iErrorList.Add( es_Error, 0, iError, self );
      end
      else
      begin
        raise Exception.Create( iError );
      end;
    end;
    k := 0;
    iLen := 0;
    for i := 1 to pData.Count - 1 do
    begin
      CommaListToStringList( pData[ i ], iItems, TRUE );
      if iItems[ 1 ] = '2' then
      begin
        // a data record
        inc( iLen, iItems.Count - 4 );
        SetLength( iBytes, iLen );
        for j := 4 to iItems.Count - 1 do
        begin
          iBytes[ k ] := StrToInt( iItems[ j ] );
          inc( k );
        end;
      end;
    end;
    tFile.WriteAllBytes( pFileName , iBytes );
    if pChangeValue then
    begin
      Value := pFileName;
    end;
  finally
    iItems.Free;
  end;
end;

{ tZFPTempTextFile }

procedure tZFPTempTextFile.ExportFile(const pPanel: integer; pList: tStrings; const TrimLines : boolean;
  const ClearOnEntry: boolean);
var
  i, j : integer;
  iCS : word;
  iLine : string;
  iTempStrings : TStringList;
  iOldCount, iNewCount : integer;
begin
  if ClearOnEntry then
  begin
    pList.Clear;
  end;
  if FileName <> '' then
  begin
    iCS := Word( -1 );
    iTempStrings := TStringList.Create;
    try
      iOldCount := Count;
      iTempStrings.Text := Wraptext(self.text, 196 );
      iNewCount := iTempStrings.Count;
      if iOldCount = iNewCount then
      begin
        pList.Add( '301,BEGIN,' + IntToStr( pPanel ));
      end
      else
      begin
        pList.Add( '301,BEGIN,' + IntToStr( pPanel ));
      end;
      pList.Add( '301,1,"' + FileName + '"' );
      // add data
      for i := 0 to iNewCount - 1 do
      begin
        if TrimLines then
        begin
          iLine := Trim(iTempStrings[ i ] );
        end
        else
        begin
          iLine := iTempStrings[ i ];
        end;
        //iLine := '"' + iLine + '"';
        for j := 1 to Length( iLine ) do
        begin
          inc( iCS, Ord( iLine[ j ] ));
        end;
        //pList.Add( '301,2,' + IntToStr( i ) + ',' + IntToStr( Length( iLine )) + ',' + iLine);
        pList.Add( '301,2,' + IntToStr( i ) + ',' + IntToStr( Length( iLine )) + ',"' + iLine + '"');
      end;
      pList.Add( '301,3,' + IntToStr( iCS ));
      pList.Add( '301,END,' + IntToStr( pPanel ) )
    finally
      iTempStrings.Free;
    end;
  end;
end;

procedure tZFPTempTextFile.ImportFile(var pPanel: integer;
  const pList: tStrings;  var pIndex : integer; pIsSigMemo : boolean );
var
  i : integer;
  iList : tInfiniteStringList;      // needs smartening up!
  //iPos : integer;
  iLast : integer;
  iLine : string;
begin
  self.Clear;
  fFileName := '';
  iLast := -1;
  iList := tInfiniteStringList.Create;
  try
    for i := pIndex to pList.Count - 1 do
    begin
      CommaListToStringList( pList[ i ], iList, TRUE );
      if iList[ 1 ] = 'BEGIN' then
        // ignore
      else if iList[ 1 ] = 'END' then
      begin
        pIndex := i;
        exit;
      end
      else if iList[ 1 ] = '1' then
      begin
        fFileName := iList[ 2 ];
      end
      else if iList[ 1 ] = '2' then
      begin
        if pIsSigMemo then
        begin
          if iLast = -1 then
          begin
            if not SameText( Copy( Trim( iList[ 4 ] ),1, 5), 'Memo ') then
            begin
              pIsSigMemo := FALSE; // not a SigMemo after all!
            end;
            iLast := Add( iList[ 4 ] ); // either way
          end
          else if Pos( '//', Trim( iList[ 4 ] ) ) = 1 then
          begin
            iLast := Add( iList[ 4 ] );
          end
          else if SameText( Trim( iList[ 4 ] ), 'End Memo' ) then
          begin
            iLast := Add( iList[ 4 ] );
          end
          else
          begin
            iLine := self[ iLast ] + ' ' + iList[ 4 ];
            self[iLast ] := iLine;
          end;
        end
        else
        begin
          Add( iList[ 4 ] );
        end;
      end;
    end;
  finally
    iList.Free;
  end;
end;

function tZFPTempTextFile.ImportFileRequest(const pPanel: integer): string;
begin
  Result := '301,REQUEST,' + IntToStr( pPanel ) + ',"' + FileName + '"';
end;

end.

