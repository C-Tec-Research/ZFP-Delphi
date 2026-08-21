unit SigFileHandler;

interface

uses
  SysUtils, Classes,
  Forms,
  SigRegistry,
  Dialogs,
  Controls,
  Menus;

type
  TCheckDirty = procedure( var IsDirty : boolean ) of object;

type
  TSigFileHandler = class(TComponent)
  private
    { Private declarations }
    iOwner : TCustomForm;
    iMainMenu : TMainMenu;
  protected
    { Protected declarations }
    iSigRegistry : tSigRegistry;
    iFileMenu : tMenuItem;
    iHelpMenu : tMenuItem;
    iHistory : array [ 0..9 ] of tMenuItem;
    iOwningForm : TForm;
    iCheckDirty : TCheckDirty;
    iChainClose : TCloseEvent;
    iOnFileNew : TNotifyEvent;
    iClearDirty : TNotifyEvent;
    iSaveDialog : TSaveDialog;
    procedure fExit( Sender : TObject );
    procedure fOnHistoryClick( Sender : TObject );

    procedure fClose( Sender : TObject; var Action : TCloseAction );

    procedure fFileNew( Sender : TObject );
    function fFileNewEx( Sender : TObject ) : TModalResult;

    procedure fFileSave( Sender : TObject );
    function fFileSaveEx( Sender : TObject ) : TModalResult;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent ); override;

    procedure ShowHistory;
  published
    { Published declarations }
    property SigRegistry : tSigRegistry
             read iSigRegistry
             write iSigRegistry;
    property CheckDirty : tCheckDirty
             read iCheckDirty
             write iCheckDirty;
    property ClearDirty : tNotifyEvent
             read iClearDirty
             write iClearDirty;
    property MainMenu : TMainMenu
             read iMainMenu
             write iMainMenu;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigFileHandler]);
end;

constructor TSigFileHandler.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  iOwner := TCustomForm( AOwner );
  iMainMenu := TMainMenu.Create( AOwner );
{
  iSigRegistry := TSigRegistry.Create( self );

  iSigRegistry.Key := Application.ExeName;

  with iMainMenu do
  begin
    iFileMenu := TMenuItem.Create( self );
    Items.Add( iFileMenu );
    iFileMenu.Caption := '&File';

    iHelpMenu := TMenuItem.Create( self );
    Items.Add( iHelpMenu );
    iHelpMenu.Caption := '&Help';

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := '&New';
    NewItem.ShortCut := TextToShortCut( 'Ctrl+N' );
    NewItem.Name := 'StdMenuNew';
    NewItem.OnClick := fFileNew;

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := '&Open';
    NewItem.ShortCut := TextToShortCut( 'Ctrl+O' );
    NewItem.Name := 'StdMenuOpen';

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := '&Save';
    NewItem.ShortCut := TextToShortCut( 'Ctrl+S' );
    NewItem.Name := 'StdMenuSave';
    NewItem.OnClick := fFileSave;

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := 'Save &As';
    NewItem.ShortCut := TextToShortCut( 'Ctrl+A' );
    NewItem.Name := 'StdMenuSaveAs';

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := '-';

    for i := 0 to 9 do
    begin
      iHistory[ i ] := TMenuItem.Create( self );
      iFileMenu.Add( iHistory[ i ] );
      iHistory[ i ].Tag := i;
      iHistory[ i ].OnClick := fOnHistoryClick;
    end;

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := '-';

    NewItem := TMenuItem.Create( self );
    iFileMenu.Add( NewItem );
    NewItem.Caption := 'E&xit';
    NewItem.ShortCut := TextToShortCut( 'Alt+F4' );
    NewItem.OnClick := fExit;

  end;

  ShowHistory;

  iChainClose := iOwningForm.OnClose;
  iOwningForm.OnClose := fClose;

  fFileNewEx( self );
}
end;

procedure TSigFileHandler.fClose( Sender : TObject; var Action : TCloseAction );
var
  iIsDirty : boolean;
begin
  iIsDirty := TRUE;
  if assigned( iCheckDirty ) then iCheckDirty( iIsDirty );
  if assigned( iChainClose ) then iChainClose( Sender, Action );
end;

procedure TSigFileHandler.fExit( Sender : TObject );
begin
  iOwningForm.Close;
end;

procedure TSigFileHandler.ShowHistory;
var
  i : integer;
  iCaption : string;
begin
  for i := 0 to 9 do
  begin
    iCaption := iSigRegistry.History[ i ];
    if iCaption = '' then
    begin
      iHistory[ i ].Visible := FALSE;
    end
    else
    begin
      iHistory[ i ].Caption := iCaption;
      iHistory[ i ].Visible := TRUE;
    end;
  end;
end;

procedure TSigFileHandler.fOnHistoryClick( Sender : TObject );
var
  iFile : string;
begin
  iFile := iSigRegistry.History[ TMenuItem( Sender ).Tag ];
end;

procedure TSigFileHandler.fFileNew( Sender : TObject );
begin
  fFileNewEx( Sender );
end;

function TSigFileHandler.fFileNewEx( Sender : TObject ) : tModalResult;
var
  iIsDirty : boolean;
begin
  Result := mrOK;
  iIsDirty := FALSE;
  if assigned( iCheckDirty ) then iCheckDirty( iIsDirty );
  if iIsDirty then
  begin
    Result := MessageDlg( 'File has changed. Do you wish to save changes?', mtWarning, mbYesNoCancel, 0 );
    case Result of
      mrYes:
      begin
        case fFileSaveEx( Sender ) of
          mrCancel:
          begin
            exit; // abort after all!
          end;
          // don't care about other cases, proceed anyway.
        end;
      end;
      mrCancel:
      begin
        exit;
      end;
      // mrNo just gets ignored
    end;
  end;
  if assigned( iOnFileNew ) then iOnFileNew( Sender );
  if assigned( iClearDirty ) then iClearDirty( Sender );
end;

procedure TSigFileHandler.fFileSave( Sender : TObject );
begin
  fFileSaveEx( Sender );
end;

function TSigFileHandler.fFileSaveEx( Sender : TObject ) : TModalResult;
begin
  Result := mrOK;
end;

end.
