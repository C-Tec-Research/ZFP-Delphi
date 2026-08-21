unit RichEditLog;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, ComCtrls,
  Contnrs,
  StrUtils,
  Graphics;

type
  tRELSubstitutionProc = procedure ( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer ) of object;

  tRELSubstitution = class
  private
    fSubstitutionText: string;
    fOnSubstitution: tRELSubstitutionProc;
    fMyLength: integer;
  public
    property SubstitutionText : string
             read fSubstitutionText;  // excluding angle brackets. Actual text will be <text> or <text(maxsize)>
    property OnSubstitution : tRELSubstitutionProc
             read fOnSubstitution;
    constructor Create( pText : string; pOnSubstitution : tRELSubstitutionProc );
    function IsMatch( const Text : string; const StartPos : integer; var SubsLength, MaxLen : integer ) : boolean;
    property MyLength : integer
             read fMyLength;
  end;

  tRELSubstitionList = class( tObjectList )
  private
    function GetItem(const index: integer): tRELSubstitution;
  public
    property Item[ const index : integer ] : tRELSubstitution
             read GetItem;
    function Add( NewVal : tRELSubstitution ) : integer; reintroduce;
    constructor Create; reintroduce;
    function GetMatch(  const Text : string; const StartPos : integer; var SubsLength, MaxLen : integer  ) : tRELSubstitutionProc;
  end;

  tOnInit = procedure( SubstitutionList : tRELSubstitionList ) of object;

  TRichEditLog = class(TRichEdit)
  private
    fRootDir: tFileName;
    fRootName: tFilename;
    fReportName: string;
    fOpenMessage: string;
    fCloseMessage: string;
    fSubstitutionList: tRELSubstitionList;
    fArchiveEnabled: boolean;
    fMaxLogSize: integer;
    fPrintOnArchive: boolean;
    fHeader: string;
    fOpen: boolean;
    fCloseDueToArchiveMessage: string;
    fOpenDueToArchiveMessage: string;
    fOnInit: tOnInit;
    fTempLog: tRichEditLog;
    fOwnsSubstitutionList: boolean;
    procedure SetOpen(const Value: boolean);
    { Private declarations }
    // tRELSubstitutionProc
    procedure fNow( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fTab( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fBold( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fNotBold( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fUnderline( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fNotUnderline( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fItalic( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fNotItalic( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fStrikeOut( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fNotStrikeOut( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fBlack( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fRed( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fBlue( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    procedure fGreen( var pAttr : TTextAttributes; var Text : string; const SubsPos, SubsLength : integer; const MaxSubsChars : integer );
    constructor CreateTemp( AOwner : tRichEditLog );
    property TempLog : tRichEditLog
             read fTempLog;
    property OwnsSubstitutionList : boolean
             read fOwnsSubstitutionList;
  protected
    { Protected declarations }
    property SubstitutionList : tRELSubstitionList
             read fSubstitutionList;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AppendText( NewVal : string ); // substitutable text, like HTML but expandable
    procedure Archive;
    procedure CopyAttr( var iSelStart : integer; var iSelLength : integer; const iChangeLen : integer; iAttr : tTextAttributes );
    function  ExtractLine( var OldVal : string ) : string;
    procedure FormatSelection( var iSelStart: integer; var iSelLength : integer );
    procedure InsertHeader;
    procedure InsertText( NewVal : string ); // at top of file
    procedure RemoveChars( const iSelStart : integer; var iSelLength : integer; const iCount : integer );
    procedure ReplaceWith( const iSelStart : integer; var iSelLength : integer; const iCount : integer; const NewText : string );
    procedure SaveToFile( FileName : tFileName );
    procedure LoadFromFile( FileName : tFileName );
    function IgnoreLine( NewVal : string ) : boolean;
    property Open : boolean
             read fOpen
             write SetOpen;
    procedure AddSubstitution( pText : string; pOnSubstitution : tRELSubstitutionProc );
  published
    { Published declarations }
    property RootDir : tFileName
             read fRootDir
             write fRootDir;
    property RootName : tFilename
             read fRootName
             write fRootName;
    property ReportName : string
             read fReportName
             write fReportName;
    property OpenMessage : string
             read fOpenMessage
             write fOpenMessage;
    property CloseMessage : string
             read fCloseMessage
             write fCloseMessage;
    property ArchiveEnabled : boolean
             read fArchiveEnabled
             write fArchiveEnabled default TRUE;
    property MaxLogSize : integer // max size before auto archiving.
             read fMaxLogSize
             write fMaxLogSize default 0;
    property PrintOnArchive : boolean
             read fPrintOnArchive
             write fPrintOnArchive default FALSE;
    property Header : string
             read fHeader
             write fHeader;
    property CloseDueToArchiveMessage : string
             read fCloseDueToArchiveMessage
             write fCloseDueToArchiveMessage;
    property OpenDueToArchiveMessage : string
             read fOpenDueToArchiveMessage
             write fOpenDueToArchiveMessage;
    property OnInit : tOnInit
             read fOnInit
             write fOnInit;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TRichEditLog]);
end;

{ TRichEditLog }

procedure TRichEditLog.AddSubstitution(pText: string;
  pOnSubstitution: tRELSubstitutionProc);
begin
  with fSubstitutionList do
  begin
    Add( tRELSubstitution.Create( pText, pOnSubstitution ));
  end;
end;

procedure TRichEditLog.AppendText(NewVal: string);
begin
  if ArchiveEnabled then
  begin
    if MaxLogSize > 0 then
    begin
      if Length( Text ) > MaxLogSize then
      begin
        Archive;
      end;
    end;
  end;
  TempLog.Clear;
  TempLog.InsertText( NewVal ); // temporarily stores lines to be added
  Text := Text + TempLog.Text;
end;

procedure TRichEditLog.Archive;
var
  iDateTime : tDateTime;
  iFileName : string;
  iYear, iMonth, iDay, iHour, iMinute, iSecond, iMSec : word;
  iArchiveEnabled : boolean;
begin
  iArchiveEnabled := ArchiveEnabled;
  ArchiveEnabled := FALSE; // prevent infinite loop

  // print and archive log file
  iDateTime := Date + Time;
  DecodeDate( iDateTime, iYear, iMonth, iDay );
  DecodeTime( iDateTime, iHour, iMinute, iSecond, iMSec );
  if not DirectoryExists( RootDir )then
  begin
    CreateDir( RootDir );
  end;
  iFileName := Format( RootDir + '\%2.2u%2.2u%2.2u%2.2u%2.2u%2.2u.rtf', [iYear mod 100, iMonth,
                       iDay, iHour, iMinute, iSecond] );
  if Header <>'' then
  begin
    self.InsertHeader;
  end;
  if CloseDueToArchiveMessage <> '' then
  begin
    AppendText( CloseDueToArchiveMessage );
  end;
  if PrintOnArchive then
  begin
    try
      Print( 'SCL Fault Log - ' + TimeToStr( iDateTime ) );
    except
    end;
  end;
  Lines.SaveToFile( iFileName );
  Clear;
  if OpenDueToArchiveMessage <> '' then
  begin
    AppendText( OpenDueToArchiveMessage );
  end;

  ArchiveEnabled := iArchiveEnabled;
end;

procedure TRichEditLog.CopyAttr(var iSelStart, iSelLength: integer;
  const iChangeLen: integer; iAttr: tTextAttributes);
begin
  SelStart := iSelStart;
  SelLength := iChangeLen;
  SelAttributes := iAttr;
  iSelStart := iSelStart + iChangeLen;
  iSelLength := iSelLength - iChangeLen;

end;

constructor TRichEditLog.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  ArchiveEnabled := TRUE;
  fSubstitutionList := tRELSubstitionList.Create;
  fOwnsSubstitutionList := TRUE;
  AddSubstitution( 'DATETIME', fNow );
  AddSubstitution( 'TAB', fTab );
  AddSubstitution( 'BOLD', fBold );
  AddSubstitution( '-BOLD', fNotBold );
  AddSubstitution( 'UL', fUnderline );
  AddSubstitution( '-UL', fNotUnderline );
  AddSubstitution( 'IT', fItalic );
  AddSubstitution( '-IT', fNotItalic );
  AddSubstitution( 'STRIKE', fStrikeOut );
  AddSubstitution( '-STRIKE', fNotStrikeout );
  AddSubstitution( 'BLACK', fBlack );
  AddSubstitution( 'BLUE', fBlue );
  AddSubstitution( 'RED', fRed );
  AddSubstitution( 'GREEN', fGreen );
  fTempLog := CreateTemp( self );
end;

constructor TRichEditLog.CreateTemp(AOwner: tRichEditLog);
begin
  inherited Create( AOwner.Owner );
  fSubstitutionList := AOwner.SubstitutionList;
  fOwnsSubstitutionList := FALSE;
end;

destructor TRichEditLog.Destroy;
begin
  if OwnsSubstitutionList then
  begin
    fSubstitutionList.Free;
    fTempLog.Free;
  end;
  inherited;
end;

function TRichEditLog.ExtractLine(var OldVal: string): string;
var
  iStart : integer;
  iSubs : string;
begin
  iSubs := '<CR>';
  iStart := Pos( iSubs, UpperCase( OldVal ));
  if iStart = 0 then
  begin
    Result := OldVal;
    OldVal := '';
  end
  else
  begin
    Result := Copy( OldVal, 1, iStart - 1); // omit <cr>
    OldVal := Copy( OldVal, iStart + Length( iSubs ), 255 );
  end;

end;

procedure TRichEditLog.fBlack(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Color := clBlack;
end;

procedure TRichEditLog.fBlue(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Color := clBlue;
end;

procedure TRichEditLog.fBold(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style + [fsBold];
end;

procedure TRichEditLog.fGreen(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Color := clGreen;
end;

procedure TRichEditLog.fItalic(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style + [fsItalic];
end;

procedure TRichEditLog.fNotBold(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style - [fsBold];
end;

procedure TRichEditLog.fNotItalic(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style - [fsItalic];
end;

procedure TRichEditLog.fNotStrikeOut(var pAttr: TTextAttributes;
  var Text: string; const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style - [fsStrikeOut];
end;

procedure TRichEditLog.fNotUnderline(var pAttr: TTextAttributes;
  var Text: string; const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style - [fsUnderline];
end;

procedure TRichEditLog.fNow(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  // date time now.
  Text := DateTimeToStr( Now );
  if MaxSubsChars > 0 then
  begin
    if Length( Text ) > MaxSubsChars then
    begin
      Text := Copy( Text, Length( Text ) - MaxSubsChars, MaxSubsChars );
    end;
  end;
end;

procedure TRichEditLog.FormatSelection(var iSelStart, iSelLength: integer);
var
  iAttr, iNewAttr : TTextAttributes;
  iSubsPos : integer;
  iLength, iCmdCount : integer;
  Action : tRELSubstitutionProc;
  iText, iSubsText : string;
begin
  // set all to default
  SelStart := iSelStart;
  SelLength := iSelLength;
  iAttr := DefAttributes;

  iSubsPos := 1;
  iNewAttr := iAttr;

  // now find substititions
  while TRUE do
  begin
    iText := Copy( Text, iSelStart + 1, iSelLength);
    iSubsPos := PosEx( '<', iText, iSubsPos );
    if iSubsPos = 0 then
    begin
      CopyAttr( iSelStart, iSelLength, iSelLength, iAttr );
      // Reset to default
      exit;
    end
    else
    begin
      Action := fSubstitutionList.GetMatch( iText,
         iSubsPos, iLength, iCmdCount );
      if assigned( Action ) then
      begin
        Action( iNewAttr, iSubsText, iSubsPos, iLength, iCmdCount );
        if (iCmdCount > 3) and (Length( iSubsText ) > iCmdCount) then
        begin
          iSubstext := Copy( iSubsText, 1, iCmdCount - 3 ) + '...';
        end;
        if (iNewAttr.Color <> iAttr.Color) or ( iNewAttr.Style <> iAttr.Style ) then
        begin
          CopyAttr( iSelStart, iSelLength, iSubsPos - iSelStart, iAttr );
          iAttr := iNewAttr;
        end;
        ReplaceWith( iSelStart + iSubsPos, iSelLength, iCmdCount, iSubsText );
      end
      else
      begin
        inc( iSubsPos );
      end;
    end;
  end;
end;

procedure TRichEditLog.fRed(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Color := clRed;
end;

procedure TRichEditLog.fStrikeOut(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style + [fsStrikeOut];
end;

procedure TRichEditLog.fTab(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
const
  cTab = chr( 9 );
begin
  Text := cTab;
end;

procedure TRichEditLog.fUnderline(var pAttr: TTextAttributes; var Text: string;
  const SubsPos, SubsLength, MaxSubsChars: integer);
begin
  pAttr.Style := pAttr.Style + [fsUnderline];
end;

function TRichEditLog.IgnoreLine(NewVal: string): boolean;
begin
  result := Pos( '<IGNORE>', UpperCase( NewVal )) > 0;
  // this is hardwired rather than be in substitution list
end;

procedure TRichEditLog.InsertHeader;
begin
  InsertText( Header );
end;

procedure TRichEditLog.InsertText(NewVal: string);
var
  iTempString, iLine : string;
  iLineStart, iLineLength : integer;
begin
  if NewVal <> '' then
  begin
    iTempString := NewVal;
    iLine := ExtractLine( iTempString );
    InsertText( iTempString ); // recursive

    if not IgnoreLine( iLine ) then
    begin
      Lines.Insert( 0, iLine );
      iLineStart := 0;
      iLineLength := Length( Lines[ 0 ] );
      FormatSelection( iLineStart, iLineLength );
    end;
  end;
end;

procedure TRichEditLog.LoadFromFile(FileName: tFileName);
begin
  Lines.LoadFromFile( FileName );
end;

procedure TRichEditLog.RemoveChars(const iSelStart: integer;
  var iSelLength: integer; const iCount: integer);
begin
  if iCount > 0 then
  begin
    SelStart := iSelStart;
    SelLength := iCount;
    SelText := '';
    dec( iSelLength, iCount );
  end;
end;

procedure TRichEditLog.ReplaceWith(const iSelStart: integer;
  var iSelLength: integer; const iCount: integer; const NewText: string);
begin
  SelStart := iSelStart;
  SelLength := iCount;
  SelText := NewText;
  iSelLength := iSelLength + Length( NewText ) - iCount;
end;

procedure TRichEditLog.SaveToFile(FileName: tFileName);
begin
  Lines.SaveToFile( FileName );
end;

procedure TRichEditLog.SetOpen(const Value: boolean);
begin
  fOpen := Value;
  if Value then
  begin
    // attempt to open
    try
      LoadFromFile( RootDir + RootName );
      if OpenMessage <> '' then
      begin
        AppendText( OpenMessage );
      end;
    except
      Clear;
//      fOpen := FALSE;
    end;
  end
  else
  begin
    // closing
    if CloseMessage <> '' then
    begin
      AppendText( CloseMessage );
      SaveToFile( ReportName );
    end;
  end;
end;

{ tRELSubstitution }

constructor tRELSubstitution.Create(pText: string;
  pOnSubstitution: tRELSubstitutionProc);
begin
  inherited Create;
  fSubstitutionText := UpperCase( pText );
  fOnSubstitution := pOnSubstitution;
  fMyLength := Length( pText );
end;

function tRELSubstitution.IsMatch( const Text : string; const StartPos : integer; var SubsLength, MaxLen : integer) : boolean;
var
  iPos2 : integer;
  iMaxText : integer;
begin
  { the preceding '<' will have been detected by our owner. We need to check if
    the substitution text is ourselves and if a maxlength is specified }
  iMaxText := 0; // no limit
  if SameText( SubstitutionText, Copy( Text, StartPos + 1, MyLength )) then
  begin
    iPos2 := StartPos + MyLength + 1;
    if Text[ iPos2 ] = '(' then
    begin
      while iPos2 < Length( Text ) do
      begin
        inc( iPos2 );
        case Text[ iPos2 ] of
          '0'..'9':
          begin
            iMaxText := iMaxText * 10 + Ord( Text[ iPos2 ] ) - Ord( '0' );
          end;
          ')':
          begin
            inc( iPos2 );
            break;
          end;
          else
          begin
            // syntax error
            Result := FALSE;
            exit;
          end;
        end;
      end;
    end;
    if Text[ iPos2 ] = '>' then
    begin
      Result := TRUE;
      SubsLength := iPos2 - StartPos;
      Maxlen := iMaxText;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

{ tRELSubstitionList }

function tRELSubstitionList.Add(NewVal: tRELSubstitution): integer;
begin
  Result := inherited Add( NewVal );
end;

constructor tRELSubstitionList.Create;
begin
  inherited Create( TRUE );
end;

function tRELSubstitionList.GetItem(const index: integer): tRELSubstitution;
begin
  Result := Items[ index ] as tRELSubstitution;
end;

function tRELSubstitionList.GetMatch( const Text : string; const StartPos : integer; var SubsLength, MaxLen : integer ): tRELSubstitutionProc;
var
  i : integer;
begin
  for i := 0 to Count - 1 do
  begin
    with Item[ i ]  do
    begin
      if IsMatch(Text, StartPos, SubsLength, MaxLen) then
      begin
        Result := OnSubstitution;
        exit;
      end;
    end;
  end;
  // else
  Result := nil;
end;

end.
