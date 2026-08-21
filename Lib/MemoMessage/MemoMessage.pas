unit MemoMessage;

interface

uses
  SysUtils,
  Classes,
  Controls,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Buttons,
  UnitMessageFile,
  MPlayer;

type
  TOnNotifyMessages = procedure ( Sender : TObject; NewVal : tSVMNotifyStatus ) of object;

  TMemoMessage = class(TCustomMemo)
  private
    { Private declarations }
  protected
    iSVMFile : tSVMFile;

    iTimer : TTimer;

    iOnSelectItem : TNotifyEvent;
    iOnNotifyMessages : tOnNotifyMessages;

    iMediaPlayer : TMediaPlayer;

    iOnActiveMessageChange : TChangeIndex;
    iOnLibraryActiveMessageChange : TChangeIndex;

    iLibraryPlayButton : TSpeedButton;
    iLibraryStopButton : TSpeedButton;
    iLibraryPrevButton : TSpeedButton;
    iLibraryNextButton : TSpeedButton;

    iMessagePlayButton : TSpeedButton;
    iMessageStopButton : TSpeedButton;
    iMessagePrevButton : TSpeedButton;
    iMessageNextButton : TSpeedButton;

    iFileName : string;

    iModuleType : tModuleType;
//    iFlashSize : tFlashSize;
    iOptimised : boolean;

    procedure fSetSelectMessageItem( NewVal : integer );

    procedure fOnClick( Sender : TObject );
    procedure fOnNotifyMessages( NewVal : tSVMNotifyStatus );

    procedure fOnMessageNextClick( Sender : TObject );
    procedure fOnMessagePrevClick( Sender : TObject );
    procedure fOnMessagePlayClick( Sender : TObject );
    procedure fOnMessageStopClick( Sender : TObject );
    procedure fOnLibraryNextClick( Sender : TObject );
    procedure fOnLibraryPrevClick( Sender : TObject );
    procedure fOnLibraryPlayClick( Sender : TObject );
    procedure fOnLibraryStopClick( Sender : TObject );

    procedure fSetMessageMemo;

    function fGetFileName : string;
    procedure fSetFileName( NewVal : string );

    function fGetDirty : boolean;

    function fGetNotes : tNotes;

    procedure fSetLibraryPlayButton(NewVal : TSpeedButton);
    procedure fSetLibraryStopButton( NewVal : TSpeedButton);
    procedure fSetLibraryNextButton(NewVal : TSpeedButton);
    procedure fSetLibraryPrevButton( NewVal : TSpeedButton);

    procedure fSetMessagePlayButton(NewVal : TSpeedButton);
    procedure fSetMessageStopButton( NewVal : TSpeedButton);
    procedure fSetMessageNextButton(NewVal : TSpeedButton);
    procedure fSetMessagePrevButton( NewVal : TSpeedButton);

    procedure fSetModuleType( NewVal : tModuleType );

//    procedure fSetFlashSize( NewVal : TFlashSize );

    function fGetMessageCount : integer;

    function fGetActiveMessage : integer;
    procedure fSetActiveMessage( NewVal : integer );

    function fGetActiveMessageElement : integer;
    procedure fSetActiveMessageElement( NewVal : integer );

    function fGetMessage( index : integer ) : tSVMMessage;

    function fGetCurrMessage : tSVMMessage;

    function fGetSVMLibrary : TSVMLibrary;

    function fGetMessageMatrix : tMessageMatrix;

    procedure fOnMessageChange( Sender : TObject; NewVal : integer );
    procedure fOnLibraryMessageChange( Sender : TObject; NewVal : integer );

    function fGetDelayStop : boolean;
    procedure fSetDelayStop( NewVal : boolean );

    procedure fSetOptimised( NewVal : boolean );

    procedure fSetSVMFile( NewVal : TSVMFile );
    { Protected declarations }
    property ReadOnly
             default TRUE;
    property Lines;
    property MaxLength;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnClick;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure Save;
    procedure Load;
    procedure New;
    procedure ImportAsCTec( ImportFileName : string );
    procedure ExportAsCTec( ExportFileName : string );
    procedure PlayActiveMessage;
    property IsDirty : boolean
             read fGetDirty;
    property MessageCount : integer
             read fGetMessageCount;
    property ActiveMessage : integer
             read fGetActiveMessage
             write fSetActiveMessage;
    property ActiveMessageElement : integer
             read fGetActiveMessageElement
             write fSetActiveMessageElement;
    property Message[ index : integer ] : tSVMMessage
             read fGetMessage;
    property CurrMessage : tSVMMessage
             read fGetCurrMessage;
    property SVMLibrary : TSVMLibrary
             read fGetSVMLibrary;
    property MessageMatrix : tMessageMatrix
             read fGetMessageMatrix;
    property DelayStop : boolean
             read fGetDelayStop
             write fSetDelayStop;
    property Notes : tNotes
             read fGetNotes;
    property Optimised : boolean
             read iOptimised
             write fSetOptimised;
    function IsCurrMessageUsed : boolean;
    function IsCurrMessageEntryUsed( var iLink : integer;
                                     var iEntry : integer;
                                     var iIsActivation : boolean ) : boolean;
    procedure MoveLibraryEntryUp; // moves currently active entry up one place
    procedure MoveLibraryEntryDown; // moves currently active entry up one place
    procedure MoveMessageEntryUp; // moves currently active entry up one place
    procedure MoveMessageEntryDown; // moves currently active entry up one place
    procedure SetMessageToCurrentLibraryEntry;
    procedure DeleteCurrentLibraryEntry;
    procedure DeleteCurrentMessageEntry;
    procedure InsertLibraryEntryBeforeCurrent;
    procedure InsertLibraryEntryAfterCurrent;
    procedure AddMessageBefore;
    procedure AddMessageAfter;
  published
    { Published declarations }
    property Align;
    property Alignment;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle;
    property Color
             default clBlack;
    property Constraints;
    property Cursor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FileName : string
             read fGetFileName
             write fSetFileName;
    property Font;
    property Height;  // 209
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HideSelection
             default FALSE;
    property Hint;
    property ImeMode;
    property ImeName;
    property Left;
//    property MediaPlayer : TMediaPlayer
//             read iMediaPlayer
//             write fSetMediaPlayer;
    property Name;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont
             default FALSE;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBars
             default ssVertical;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width; // 488

    property OnChange;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property onMouseDown;
    property OnMouseUp;
    property OnNotifyMessages : TOnNotifyMessages
             read iOnNotifyMessages
             write iOnNotifyMessages;
    property OnSelectItem : TNotifyEvent
             read iOnSelectItem
             write iOnSelectItem;
    property OnStartDock;
    property OnStartDrag;
    property LibraryPlayButton : TSpeedButton
             read iLibraryPlayButton
             write fSetLibraryPlayButton;
    property LibraryStopButton : TSpeedButton
             read iLibraryStopButton
             write fSetLibraryStopButton;
    property LibraryNextButton : TSpeedButton
             read iLibraryNextButton
             write fSetLibraryNextButton;
    property LibraryPrevButton : TSpeedButton
             read iLibraryPrevButton
             write fSetLibraryPrevButton;

    property MessagePlayButton : TSpeedButton
             read iMessagePlayButton
             write fSetMessagePlayButton;
    property MessageStopButton : TSpeedButton
             read iMessageStopButton
             write fSetMessageStopButton;
    property MessageNextButton : TSpeedButton
             read iMessageNextButton
             write fSetMessageNextButton;
    property MessagePrevButton : TSpeedButton
             read iMessagePrevButton
             write fSetMessagePrevButton;

    property ModuleType : TModuleType
             read iModuleType
             write fSetModuleType
             default mtAVAC;

//    property FlashSize : TFlashSize
//             read iFlashSize
//             write fSetFlashSize
//             default fsUnknown;
    property OnActiveMessageChange : TChangeIndex
             read iOnActiveMessageChange
             write iOnActiveMessageChange;
    property OnLibraryActiveMessageChange : TChangeIndex
             read iOnLibraryActiveMessageChange
             write iOnLibraryActiveMessageChange;
    property SVMFile : tSVMFile
             read iSVMFile
             write fSetSVMFile;
  end;

{$IFDEF ALLOWINSTALL}
procedure Register;
{$ENDIF}

implementation

{$IFDEF ALLOWINSTALL}
procedure Register;
begin
  RegisterComponents('SigNET', [TMemoMessage]);
end;
{$ENDIF}

constructor TMemoMessage.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  Color := clBlack;
  HideSelection := FALSE;
  ParentFont := FALSE;
  Font.Color := clLime;
  Font.Style := [fsBold];
  ReadOnly := TRUE;
  ScrollBars := ssVertical;
  OnClick := fOnClick;
  iSVMFile := TSVMFile.Create( nil );
  iMediaPlayer := TMediaPlayer.Create( self );
  if not (csDesigning in ComponentState) then
  begin
    iMediaPlayer.Parent := TWinControl( AOwner );
  end;
  iMediaPlayer.Visible := FALSE;
  iTimer := TTimer.Create( self );
  iModuleType := mtAVAC;
//  iFlashSize := fsUnknown;
  iOptimised := FALSE;
end;

procedure TMemoMessage.fSetSVMFile( NewVal : TSVMFile );
begin
  iSVMFile.Free;
  iSVMFile := NewVal;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.OnNotify := fOnNotifyMessages;
    iSVMFile.RegisterMediaPlayer( iMediaPlayer );
    iSVMFile.RegisterTimer( iTimer );
    iSVMFile.Flash.Messages.OnChange := fOnMessageChange;
    iSVMFile.Flash.SVMLibrary.OnChange := fOnLibraryMessageChange;
    iSVMFile.Flash.SVMLibrary.PlayButton := iLibraryPlayButton;
    iSVMFile.Flash.SVMLibrary.StopButton := iLibraryStopButton;
    iSVMFile.Flash.SVMLibrary.PrevButton := iLibraryPrevButton;
    iSVMFile.Flash.SVMLibrary.NextButton := iLibraryNextButton;
    iSVMFile.Flash.Messages.PlayButton := iMessagePlayButton;
    iSVMFile.Flash.Messages.StopButton := iMessageStopButton;
    iSVMFile.Flash.Messages.PrevButton := iMessagePrevButton;
    iSVMFile.Flash.Messages.NextButton := iMessageNextButton;
    iSVMFile.FileName := iFileName;
    iSVMFile.ModuleType := iModuleType;
//    iSVMFile.Flash.FlashSize := iFlashSize;
    iSVMFile.Optimised := iOptimised;
  end;
end;

destructor TMemoMessage.Destroy;
begin
  iSVMFile.Free;
  inherited Destroy;
end;

procedure TMemoMessage.fOnMessageChange( Sender : TObject; NewVal : integer );
begin
  if assigned( iOnActiveMessageChange ) then
  begin
    iOnActiveMessageChange( Sender, NewVal );
  end;
end;

procedure TMemoMessage.fOnLibraryMessageChange( Sender : TObject; NewVal : integer );
begin
  if assigned( iOnLibraryActiveMessageChange ) then
  begin
    iOnLibraryActiveMessageChange( Sender, NewVal );
  end;
end;

function TMemoMessage.fGetDirty : boolean;
begin
  if assigned( iSVMFile ) then
  begin
    result := iSVMFile.IsDirty;
  end
  else
  begin
    result := FALSE;
  end;
end;

function TMemoMessage.fGetFileName : string;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.FileName;
  end
  else
  begin
    Result := '';
  end
end;

procedure TMemoMessage.fSetFileName( NewVal : string );
begin
  iFileName := NewVal;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.FileName := NewVal;
  end;
end;

procedure TMemoMessage.fOnNotifyMessages( NewVal : tSVMNotifyStatus );
begin
  fSetMessageMemo;
  if assigned( iOnNotifyMessages ) then
  begin
    iOnNotifyMessages( self, NewVal );
  end;
end;

procedure TMemoMessage.fOnClick(Sender: TObject);
var
  iSelectMessageIndex : integer;
begin
  if assigned( iSVMFile ) then
  begin
    iSelectMessageIndex := iSVMFile.Flash.Messages.ActiveOption;
    if iSelectMessageIndex >= 0 then
    begin
      with iSVMFile.Flash.Messages.Item[ iSelectMessageIndex ] do
      begin
        fSetSelectMessageItem( GetIndexFromCaret( SelStart ));
      end;
    end;
  end;
  if assigned( iOnSelectItem ) then iOnSelectItem( self );
end;

procedure TMemoMessage.fSetSelectMessageItem( NewVal : integer );
var
  iSelectMessageIndex : integer;
begin
  iSelectMessageIndex := iSVMFile.Flash.Messages.ActiveOption;
  if (iSelectMessageIndex >= 0) and (NewVal >= 0 ) then
  begin
    with iSVMFile.Flash.Messages.Item[ iSelectMessageIndex ] do
    begin
      ActiveOption := NewVal;
      fSetMessageMemo;
    end;
  end;
end;

procedure TMemoMessage.fSetMessageMemo;
begin
  if assigned( iSVMFile ) then
  begin
    if assigned( iSVMFile.Flash.Messages.Curr ) then
    begin
      if Text <> iSVMFile.Flash.Messages.Curr.Text( iSVMFile.Flash.SVMLibrary ) then
      begin
        Text := iSVMFile.Flash.Messages.Curr.Text( iSVMFile.Flash.SVMLibrary );
      end;
      if iSVMFile.Flash.Messages.Curr.ActiveOption < 0 then
      begin
        SelStart := -1;
        SelLength := 0;
      end
      else
      begin
        SelStart := iSVMFile.Flash.Messages.Curr.GetStartOf( iSVMFile.Flash.Messages.Curr.ActiveOption );
        SelLength := iSVMFile.Flash.Messages.Curr.Curr.TextLength;
      end;
    end;
  end;
end;

procedure TMemoMessage.Save;
begin
  if FileName = '' then
  begin
    raise exception.Create( 'File Name not set' );
  end
  else
  begin
    if assigned( iSVMFile ) then
    begin
      iSVMFile.Save( FileName );
    end
    else
    begin
      raise Exception.Create( 'No file defined' );
    end;
  end;
end;

procedure TMemoMessage.Load;
begin
  if FileName = '' then
  begin
    raise exception.Create( 'File Name not set' );
  end
  else
  begin
    if assigned( iSVMFile ) then
    begin
      iSVMFile.Load( FileName );
    end
    else
    begin
      raise Exception.Create( 'No file defined' );
    end;
  end;
end;

procedure TMemoMessage.fSetLibraryPlayButton(NewVal : TSpeedButton);
begin
  iLibraryPlayButton := NewVal;
  NewVal.OnClick := fOnLibraryPlayClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.PlayButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetLibraryStopButton( NewVal : TSpeedButton);
begin
  iLibraryStopButton := NewVal;
  NewVal.OnClick := fOnLibraryStopClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.StopButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetLibraryNextButton(NewVal : TSpeedButton);
begin
  iLibraryNextButton := NewVal;
  NewVal.OnClick := fOnLibraryNextClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.NextButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetLibraryPrevButton( NewVal : TSpeedButton);
begin
  iLibraryPrevButton := NewVal;
  NewVal.OnClick := fOnLibraryPrevClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.PrevButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetMessagePlayButton(NewVal : TSpeedButton);
begin
  iMessagePlayButton := NewVal;
  NewVal.OnClick := fOnMessagePlayClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.PlayButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetMessageStopButton( NewVal : TSpeedButton);
begin
  iMessageStopButton := NewVal;
  NewVal.OnClick := fOnMessageStopClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.StopButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetMessageNextButton(NewVal : TSpeedButton);
begin
  iMessageNextButton := NewVal;
  NewVal.OnClick := fOnMessageNextClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.NextButton := NewVal;
  end;
end;

procedure TMemoMessage.fSetMessagePrevButton( NewVal : TSpeedButton);
begin
  iMessagePrevButton := NewVal;
  NewVal.OnClick := fOnMessagePrevClick;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.PrevButton := NewVal;
  end;
end;

procedure TMemoMessage.fOnMessageNextClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Next;
  end;
end;

procedure TMemoMessage.fOnMessagePrevClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Prev;
  end;
end;

procedure TMemoMessage.fOnMessagePlayClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Play;
  end;
end;

procedure TMemoMessage.fOnMessageStopClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Stop;
  end;
end;

procedure TMemoMessage.fOnLibraryPlayClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.Play;
  end;
end;

procedure TMemoMessage.fOnLibraryStopClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.Stop;
  end;
end;

procedure TMemoMessage.fOnLibraryNextClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.Next;
  end;
end;

procedure TMemoMessage.fOnLibraryPrevClick( Sender : TObject);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SVMLibrary.Prev;
  end;
end;

procedure TMemoMessage.ImportAsCTec( ImportFileName : string );
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.ImportAsCtec( ImportFileName );
  end
  else
  begin
    raise Exception.Create( 'No file defined' );
  end;
end;

procedure TMemoMessage.ExportAsCTec( ExportFileName : string );
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.ExportAsCtec( ExportFileName );
  end
  else
  begin
    raise Exception.Create( 'No file defined' );
  end;
end;

procedure TMemoMessage.fSetModuleType( NewVal : tModuleType );
begin
  iModuleType := NewVal;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.ModuleType := NewVal;
  end
end;

{
procedure TMemoMessage.fSetFlashSize( NewVal : TFlashSize );
begin
  iFlashSize := NewVal;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.FlashSize := NewVal;
  end;
end;
}

function TMemoMessage.fGetMessageCount : integer;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.Messages.Count;
  end
  else
  begin
    Result := 0;
  end;
end;

function TMemoMessage.fGetActiveMessage : integer;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.Messages.ActiveOption;
  end
  else
  begin
    Result := -1;
  end;
end;

procedure TMemoMessage.fSetActiveMessage( NewVal : integer);
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.ActiveOption := NewVal;
    fSetMessageMemo;
  end;
end;

function TMemoMessage.fGetActiveMessageElement : integer;
begin
  with iSVMFile.Flash.Messages do
  begin
    if assigned( Curr ) then Result := Curr.ActiveOption
    else Result := -1;
  end;
end;

procedure TMemoMessage.fSetActiveMessageElement( NewVal : integer);
begin
  if assigned( CurrMessage ) then
  begin
    with CurrMessage do
    begin
      if assigned( Curr ) then
      begin
        ActiveOption := NewVal;
        fSetMessageMemo;
      end
      else
      begin
//        raise exception.Create( 'No message Active to set active element of!' );
      end;
    end;
  end;
end;

function TMemoMessage.fGetMessage( index : integer ) : tSVMMessage;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.Messages.Item[ index ];
  end
  else
  begin
   Result := nil;
  end;
end;

function TMemoMessage.fGetCurrMessage : tSVMMessage;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.Messages.Curr;
  end
  else
  begin
    Result := nil;
  end;
end;

function TMemoMessage.fGetSVMLibrary : TSVMLibrary;
begin
  if assigned( iSVMFile ) then
  begin
    result := iSVMFile.Flash.SVMLibrary;
  end
  else
  begin
   Result := nil;
  end;
end;

function TMemoMessage.fGetMessageMatrix : TMessageMatrix;
begin
  if assigned( iSVMFile ) then
  begin
    result := iSVMFile.Flash.MessageMatrix;
  end
  else
  begin
   Result := nil;
  end;
end;

procedure TMemoMessage.PlayActiveMessage;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Play;
  end;
end;

function TMemoMessage.fGetDelayStop : boolean;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.Messages.Curr.DelayStop;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TMemoMessage.fSetDelayStop( NewVal : boolean );
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.Curr.DelayStop := NewVal;
  end;
end;

function TMemoMessage.fGetNotes : tNotes;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Notes;
  end
  else
  begin
    Result := nil;
  end;
end;

procedure TMemoMessage.fSetOptimised( NewVal : boolean );
begin
  iOptimised := NewVal;
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Optimised := NewVal;
  end;
end;

function TMemoMessage.IsCurrMessageUsed : boolean;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.IsCurrMessageUsed;
  end
  else
  begin
    Result := FALSE;
  end;
end;

function TMemoMessage.IsCurrMessageEntryUsed( var iLink : integer;
                                     var iEntry : integer;
                                     var iIsActivation : boolean ) : boolean;
begin
  if assigned( iSVMFile ) then
  begin
    Result := iSVMFile.Flash.IsCurrMessageEntryUsed( iLink, iEntry, iIsActivation );
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TMemoMessage.MoveLibraryEntryUp; // moves currently active entry up one place
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.MoveLibraryEntryUp;
  end;
end;

procedure TMemoMessage.MoveLibraryEntryDown; // moves currently active entry up one place
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.MoveLibraryEntryDown;
  end;
end;

procedure TMemoMessage.MoveMessageEntryUp; // moves currently active entry up one place
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.MoveMessageEntryUp;
  end;
end;

procedure TMemoMessage.New;
begin
  SVMFile.New;
end;

procedure TMemoMessage.MoveMessageEntryDown; // moves currently active entry up one place
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.MoveMessageEntryDown;
  end;
end;

procedure TMemoMessage.SetMessageToCurrentLibraryEntry;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.SetMessageToCurrentLibraryEntry;
  end;
end;

procedure TMemoMessage.DeleteCurrentLibraryEntry;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.DeleteCurrentLibraryEntry;
  end;
end;

procedure TMemoMessage.DeleteCurrentMessageEntry;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.DeleteCurrentMessageEntry;
  end;
end;

procedure TMemoMessage.InsertLibraryEntryBeforeCurrent;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.InsertLibraryEntryBeforeCurrent;
  end;
end;

procedure TMemoMessage.InsertLibraryEntryAfterCurrent;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.InsertLibraryEntryAfterCurrent;
  end;
end;

procedure TMemoMessage.AddMessageBefore;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.AddBefore;
  end;
end;

procedure TMemoMessage.AddMessageAfter;
begin
  if assigned( iSVMFile ) then
  begin
    iSVMFile.Flash.Messages.AddAfter;
  end;
end;

end.
