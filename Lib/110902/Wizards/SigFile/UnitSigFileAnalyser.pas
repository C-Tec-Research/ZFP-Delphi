unit UnitSigFileAnalyser;

interface

uses
  SysUtils,
  UnitProjectExportFile,
{$IFNDEF SIGDEBUG}
  ToolsAPI,
{$ENDIF}
  Classes,
  Common;

type
  tCommentForm = ( cfNone, cfCurlyBracket, cfBracketStar );

type
  tSigFileAnalyser = class
  private
    fSigFileDescendant: string;
    fUnitMain: tStringList;
    fUnitFiles: tStringlist;
    fMainForm: string;
    fPotentialEditors: TStringList;
    fPotentialEditorTypes: TStringList;
    fPotentialLabels: TStringList;
    procedure SetSigFileDescendant(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    function Match( var pLine : string; const pMatch : array of string; pAtEnd : boolean;
                    var pCommentForm : tCommentForm; const pMin : integer = -1; const pMax : integer = -1  ) : boolean;

    property UnitMain : tStringList
             read fUnitMain;
    property UnitFiles : tStringlist
             read fUnitFiles;
    property SigFileDescendant : string
             read fSigFileDescendant
             write SetSigFileDescendant;
    property MainFormType : string
             read fMainForm;
    property PotentialEditors : TStringList
             read fPotentialEditors;
    property PotentialLabels : TStringList
             read fPotentialLabels;

    function LoadFiles( pDirectory : string ) : boolean; // loads source files, if available, and populates fields
                                  // NOTE ProjectName MUST be set up before calling this.
    procedure ChangeSigName( const pProject : tProjectFile; const pOldName, pNewName : string );

    procedure ReadMain;
    procedure ReadMainForm( var i : integer; var pCommentForm : tCommentForm );
    function CheckPossibleEditor( var pLine : string; const pEditor : string; var pCommentForm : tCommentForm ) : boolean;
    function CheckPossibleLabel( var pLine : string; var pCommentForm : tCommentForm ) : boolean;
    procedure ReadUnitFiles;
  end;

implementation

{ tSigFileAnalyser }

procedure tSigFileAnalyser.ChangeSigName( const pProject : tProjectFile; const pOldName, pNewName : string );
var
  i, iModuleCount : integer;
  //pModule: IOTAModuleInfo;
  iFile : string;
  //iExt : string;
  iFileSrc : tStringList;
  iText, iText2 : string;
begin
  if not SameText( pOldName, pNewName ) then
  begin
    if assigned( pProject ) then
    begin
      iModuleCount := pProject.ModuleList.Count;
      iFileSrc := tStringList.Create;
      try
        for i := 0 to iModuleCount - 1 do
        begin
          iFile := pProject.ModuleList.Module[ i ].FileName.Value;
          if SameText( ExtractFileExt( iFile ), '.pas' ) then
          begin
            iFileSrc.LoadFromFile( iFile );
            iText := iFileSrc.Text;
            iText2 := ReplaceWord( iText, pOldName, pNewName, TRUE, TRUE );
            if iText <> iText2 then
            begin
              iFileSrc.Text := iText;
              iFileSrc.SaveToFile( iFile );
            end;
          end;
        end;
      finally
       iFileSrc.Free;
      end;
    end;
  end;
end;

function tSigFileAnalyser.CheckPossibleEditor(var pLine : string; const pEditor: string;
  var pCommentForm: tCommentForm) : boolean;
begin
  Result := Match( pLine, [':', pEditor, ';' ], TRUE, pCommentForm );
  if Result then
  begin
    PotentialEditors.Add( pLine + '{' + pEditor + '}' );
  end;

end;

function tSigFileAnalyser.CheckPossibleLabel(var pLine: string;
  var pCommentForm: tCommentForm): boolean;
begin
  Result := Match( pLine, [':', 'tLabel', ';' ], TRUE, pCommentForm );
  if Result then
  begin
    PotentialLabels.Add( pLine + '{tLabel}');
  end;
end;

constructor tSigFileAnalyser.Create;
begin
  inherited Create;
  fUnitMain := tStringList.Create;
  fUnitFiles := tStringlist.Create;
  fPotentialEditors := TStringList.Create;
  fPotentialEditorTypes := TStringList.Create;
  fPotentialLabels := TStringList.Create;

  fPotentialEditorTypes.Add( 'tSigSpinEdit' );
  fPotentialEditorTypes.Add( 'tSpinEdit' );
  fPotentialEditorTypes.Add( 'tEdit' );
  fPotentialEditorTypes.Add( 'tMaskEdit' );
  fPotentialEditorTypes.Add( 'tCheckBox' );
  fPotentialEditorTypes.Add( 'tComboBox' );
  fPotentialEditorTypes.Add( 'tRadioGroup' );
  fPotentialEditorTypes.Add( 'tCheckListBox' );
  fPotentialEditorTypes.Add( 'tCalendar' );
  fPotentialEditorTypes.Add( 'tMemo' );
  fPotentialEditorTypes.Add( 'tStringGrid' );
  fPotentialEditorTypes.Add( 'tSigStringGrid' );
  //fPotentialEditorTypes.Add( 'tForm' );
end;

destructor tSigFileAnalyser.Destroy;
begin
  fUnitMain.Free;
  fUnitFiles.Free;
  fPotentialEditors.Free;
  fPotentialEditorTypes.Free;
  fPotentialLabels.Free;;


  inherited;
end;

function tSigFileAnalyser.Match(var pLine: string; const pMatch: array of string;
  pAtEnd: boolean; var pCommentForm : tCommentForm; const pMin : integer = -1; const pMax : integer = -1): boolean;
var
  iMin, iMax : integer;
  iLine : string;
  iPos : integer;
begin
  { finds a complete set of strings, in sequence, at beginning or end of line}

  iLine := Trim( pLine );

  case pCommentForm of
    cfNone:
    begin
      if Copy( iLine, 1, 2 ) = '//' then
      begin
        Result := FALSE;
        exit;
      end
      else if Copy( iLine, 1, 1) = '{' then
      begin
        iLine := Copy( iLine, 2, Length( iLine ));
        pCommentForm := cfCurlyBracket;
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, pMin, pMax );
        exit;
      end
      else if Copy( iLine, 1, 2 ) = '(*' then
      begin
        iLine := Copy( iLine, 3, Length( iLine ));
        pCommentForm := cfBracketStar;
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, pMin, pMax );
        exit;
      end;
    end;
    cfCurlyBracket:
    begin
      iPos := pos( '}', iLine );
      if iPos = 0 then
      begin
        Result := FALSE;
      end
      else
      begin
        iLine := Copy( iLine, iPos + 1, Length( iLine ));
        pCommentForm := cfNone;
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, pMin, pMax );
      end;
      exit;
    end;
    cfBracketStar:
    begin
      iPos := pos( '*)', iLine );
      if iPos = 0 then
      begin
        Result := FALSE;
      end
      else
      begin
        iLine := Copy( iLine, iPos + 2, Length( iLine ));
        pCommentForm := cfNone;
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, pMin, pMax );
      end;
      exit;
    end;
  end;
  if pMin = -1 then
  begin
    iMin := Low( pMatch );
  end
  else
  begin
    iMin := pMin;
  end;
  if pMax = -1 then
  begin
    iMax := High( pMatch );
  end
  else
  begin
    iMax := pMax;
  end;

  if pAtEnd then
  begin
    if SameText( Copy( iLine, Length( iLine ) - Length( pMatch[ iMax ])+1, Length( pMatch[ iMax] )), pMatch[ iMax ] ) then
    begin
      iLine := Trim(Copy( iLine, 1, Length( iLine ) - Length( pMatch[ iMax ])));
      if iMax = iMin then
      begin
        Result := TRUE;
      end
      else
      begin
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, iMin, iMax - 1 );
      end;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    if SameText( Copy(iLine, 1, Length( pMatch [ iMin ] )), pMatch[ iMin ] ) then
    begin
      iLine := Trim(Copy( iLine, Length( pMatch[ iMin ] ) + 1, Length( iLine )));
      if iMax = iMin then
      begin
        Result := TRUE;
      end
      else
      begin
        Result := Match( iLine, pMatch, pAtEnd, pCommentForm, iMin + 1, iMax );
      end;
    end
    else
    begin
      Result := FALSE;
    end;
  end;
  if Result then
  begin
    pLine := iLine;
  end;
end;

function tSigFileAnalyser.LoadFiles(pDirectory: string): boolean;
begin
  Result := TRUE;  // assume OK
  fPotentialEditors.Clear;
  fPotentialLabels.Clear;
  // see if we have files to load
  if FileExists( pDirectory + 'UnitMain.pas' ) then
  begin
    UnitMain.LoadFromFile( pDirectory + 'UnitMain.pas' );
  end
  else
  begin
    UnitMain.Clear;
    Result := FALSE;
  end;
  if FileExists( pDirectory + 'UnitFiles.pas' ) then
  begin
    UnitFiles.LoadFromFile( pDirectory + 'UnitFiles.pas' );
  end
  else
  begin
    UnitFiles.Clear;
    Result := FALSE;
  end;
  if Result then
  begin
    // fill in fields and show pages
    SigFileDescendant := '';
    ReadMain;
    ReadUnitFiles;
  end
  else
  begin
    // hide pages
  end;
end;

procedure tSigFileAnalyser.ReadMain;
var
  i : integer;
  iLine : string;
  pCommentForm : tCommentForm;
begin
  with UnitMain do
  begin
    i := 0;
    pCommentForm := cfNone;
    while i < Count do
    begin
      iLine := Trim( Strings[ i ] );
      // form definition looks like
      //   TFormMain = class(TForm)
      // but name could have changed.
      if Match( iLine, ['=', 'class', '(', 'TForm', ')'], TRUE, pCommentForm ) then
      begin
        fMainForm := iLine;
        ReadMainForm( i, pCommentForm );
      end;
      inc( i );
    end;
  end;
end;

procedure tSigFileAnalyser.ReadMainForm(var i: integer; var pCommentForm : tCommentForm);
var
  iLine : string;
  j: integer;
label
  LContinue;
begin
  with UnitMain do
  begin
    while i < Count do
    begin
LContinue:
      inc( i );
      iLine := Trim( Strings[ i ] );
      // done at end
      if Match( iLine, ['end', ';' ], TRUE, pCommentForm ) then
      begin
        if iLine = '' then
        begin
          exit;
        end
        else
        begin
          // false positive; restore
         iLine := Trim( Strings[ i ] );
        end;
      end;
      if (iLine = '') then
      begin
        continue;
      end;
      // SigFile Type line looks like
      // fSigFile: tMyFile;
      if Match( iLine, ['fSigFile', ':'], FALSE, pCommentForm ) then
      begin
        if Length( iLine ) > 0 then
        begin
          // make sure not := !
          if iLine[ 1 ] <> '=' then
          begin
            if Match( iLine, [ ';' ], TRUE, pCommentForm ) then
            begin
              SigFileDescendant := iLine;
              continue;
            end;
          end;
        end;
      end;
      // possible editors
      if not CheckPossibleLabel( iLine, pCommentForm ) then
      begin
        for j := 0 to fPotentialEditorTypes.Count - 1 do
        begin
          if CheckPossibleEditor( iLine, fPotentialEditorTypes[ j ], pCommentForm ) then
          begin
            Goto LContinue;
          end;
        end;
      end;
    end;
  end;
end;

procedure tSigFileAnalyser.ReadUnitFiles;
var
  i, iPos : integer;
  iLine : string;
  pCommentForm : tCommentForm;
begin
  with UnitFiles do
  begin
    pCommentForm := cfNone;
    i := 0;
    while i < Count do
    begin
      iLine := Trim( Strings[ i ] );
      // properties appear over several lines in both files
      // in UnitFiles the look like
      //   tRS485SetupFile = class( tSigFileProperty )
      //   private
      //     fCommsPort: tSigIntegerProperty;
      //   public
      //     property CommsPort : tSigIntegerProperty
      //       read fCommsPort;

      inc( i );
    end;
  end;
end;

procedure tSigFileAnalyser.SetSigFileDescendant(const Value: string);
var
  iOldVal : string;
begin
  iOldVal := fSigFileDescendant;
  fSigFileDescendant := Value;
  // we now need to replace iOldVal with iNewVal in every file

end;

end.
