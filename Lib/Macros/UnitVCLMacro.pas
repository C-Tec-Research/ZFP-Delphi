unit UnitVCLMacro;

interface

uses
  System.Generics.Collections,
  System.Classes,
  System.UITypes,
  System.SysUtils,
  VCL.Controls,
  VCL.ComCtrls,
  VCL.Forms,
  VCL.Buttons,
  VCL.Dialogs,
  VCL.StdCtrls,
  SigFile;

type
  TRecordedAction = (raClick, raClickItem, raEnterText, raPause );
  TPlayback = procedure( const pAction : TRecordedAction; const pClickItem : integer; const pTextItem : string ) of object;

  TRecordedLine = class( TSigCompoundProperty )
  private
    fComponentName : TSigTextProperty;
    fAction : TSigEnum< TRecordedAction >;
    fClickItem : TSigIntegerProperty;
    fEditText : TSigTextProperty;
    fPlayback: TPlayback;
    function GetComponentName: string;
    procedure SetComponentName(const Value: string);
    function GetAction: TRecordedAction;
    procedure SetAction(const Value: TRecordedAction);
    function GetClickItem: integer;
    procedure SetClickItem(const Value: integer);
    function GetEditText: string;
    procedure SetEditText(const Value: string);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;

    procedure Playback;

    property ComponentName : string
             read GetComponentName
             write SetComponentName;
    property Action : TRecordedAction
             read GetAction
             write SetAction;
    property ClickItem : integer
             read GetClickItem
             write SetClickItem;
    property EditText : string
             read GetEditText
             write SetEditText;
    property OnPlayback : TPlayback
             read fPlayback
             write fPlayBack;

  end;

  TRecordedMacro = class( TSigObjectList < TRecordedLine > )
  private
    fMacroName: TSigTextProperty;
    function GetMacroName: string;
    procedure SetMacroName(const Value: string);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property MacroName : string
             read GetMacroName
             write SetMacroName;
  end;

  TRecordedMacros = class( TSigObjectList< TRecordedMacro > )

  end;

  TMacroFile = class( TSigFileProperty )
  private
    fRecordedMacros: TRecordedMacros;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property RecordedMacros : TRecordedMacros
             read fRecordedMacros;
  end;

  TVCLMacro = class;

  TVCLMacroEntry = class
  private
  protected
    fOwner: TVCLMacro;
    fControl: TControl;
    procedure Playback ( const pAction : TRecordedAction; const pClickItem : integer; const pTextItem : string ); virtual; abstract;
  public
    constructor Create( const pOwner : TVCLMacro; const pControl : TControl );
    //destructor Destroy; override;
    property Owner : TVCLMacro
             read fOwner;
    property Control : TControl
             read fControl;
  end;

  TVCLSpeedButtonEntry = class (TVCLMacroEntry)
  private
    function GetControl: TSpeedButton;
  protected
    fOnClick : TNotifyEvent;
    procedure OnClick( Sender : TObject );
    procedure Playback ( const pAction : TRecordedAction; const pClickItem : integer; const pTextItem : string ); override;
  public
    constructor Create( const pOwner : TVCLMacro; const pControl : TSpeedButton );
    destructor Destroy; override;
    property Control : TSpeedButton
             read GetControl;
  end;

  TVCLPageControlEntry = class(TVCLMacroEntry)
  private
    function GetControl: TPageControl;
  protected
    fOnChange : TNotifyEvent;
    procedure OnChange( Sender : TObject );
    procedure Playback ( const pAction : TRecordedAction; const pClickItem : integer; const pTextItem : string ); override;
  public
    constructor Create( const pOwner : TVCLMacro; const pControl : TPageControl );
    destructor Destroy; override;
    property Control : TPageControl
             read GetControl;
  end;

  TVCLComboBoxEntry = class(TVCLMacroEntry)
  private
    function GetControl: TComboBox;
  protected
    fOnChange : TNotifyEvent;
    fOnClick : TNotifyEvent;
    procedure OnChange( Sender : TObject );
    procedure OnClick( Sender : TObject );
    procedure Playback ( const pAction : TRecordedAction; const pClickItem : integer; const pTextItem : string ); override;
  public
    constructor Create( const pOwner : TVCLMacro; const pControl : TComboBox );
    destructor Destroy; override;
    property Control : TComboBox
             read GetControl;
  end;

  TVCLMacro = class( TObjectList< TVCLMacroEntry > )
    // The idea is that this intercepts a number of components and actions
    // and records them or plays them back
  private
    fRecording: boolean;
    fPaused : boolean;
    fCanPause : boolean;
    fMainForm: TForm;
    fMacroFile: TMacroFile;
    fRecordButton: TControl;
    fCurrentMacro : TRecordedMacro;
    fPlayButton: TControl;
    fLoadButton: TControl;
    fMacroNameEditor: TControl;
    fSaveButton: TControl;
    fStopButton: TControl;
    fPauseButton: TControl;
    procedure SetMainForm(const Value: TForm);
    procedure RegisterComponents( const pComponent : TControl );
    procedure UnRegisterComponent( const pComponent : TControl );
    procedure SetRecordButton(const Value: TControl);
    procedure SetLoadButton(const Value: TControl);
    procedure SetSaveButton(const Value: TControl);
    procedure SetStopButton(const Value: TControl);
    procedure SetMacroNameEditor(const Value: TControl);
    procedure SetPlayButton(const Value: TControl);
    procedure SetPauseButton(const Value: TControl);
    procedure SetRecording(const Value: boolean);
    procedure SetControl( const pNewButton : TControl; var pButton : TControl; var pOnClickEvent : TNotifyEvent; const pNewOnClickEvent : TNotifyEvent );
    procedure SetPaused(const Value: boolean);
    procedure GetNameEditorText;
  protected
    fOnRecordClick : TNotifyEvent;
    fOnPlayClick : TNotifyEvent;
    fOnStopClick : TNotifyEvent;
    fOnPauseClick : TNotifyEvent;
    fOnSaveClick : TNotifyEvent;
    fOnMacroNameEditorExit : TNotifyEvent;
    procedure OnRecordClick( Sender : TObject );
    procedure OnPlayClick( Sender : TObject );
    procedure OnStopClick( Sender : TObject );
    procedure OnPauseClick( Sender : TObject );
    procedure OnSaveClick( Sender : TObject );
    procedure OnClick( pNotifyEvent : TNotifyEvent; Sender : TObject );
    procedure OnNameEditorExit( Sender : TObject );
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    property Recording : boolean
             read fRecording
             write SetRecording;
    property Paused : boolean
             read fPaused
             write SetPaused;
    property CanPause : boolean
             read fCanPause
             write SetPaused;
    property MainForm : TForm
             read fMainForm
             write SetMainForm;
    property MacroFile : TMacroFile
             read fMacroFile;
    property RecordButton : TControl
             read fRecordButton
             write SetRecordButton;
    property StopButton : TControl
             read fStopButton
             write SetStopButton;
    property PlayButton : TControl
             read fPlayButton
             write SetPlayButton;
    property PauseButton : TControl
             read fPauseButton
             write SetPauseButton;
    property MacroNameEditor : TControl
             read fMacroNameEditor
             write SetMacroNameEditor;
    property LoadButton : TControl
             read fLoadButton
             write SetLoadButton;
    property SaveButton : TControl
             read fSaveButton
             write SetSaveButton;
  end;


implementation

{ TVCLMacro }

constructor TVCLMacro.Create;
begin
  inherited Create;

  fMacroFile := TMacroFile.Create( 'Macro File', nil );

end;

destructor TVCLMacro.Destroy;
begin

  fMacroFile.Free;

  inherited;
end;

procedure TVCLMacro.GetNameEditorText;
begin
  if assigned( fMacroNameEditor ) then
  begin
    if assigned(fCurrentMacro) then
    begin
      if fMacroNameEditor is TEdit then
      begin
        fCurrentMacro.MacroName := (fMacroNameEditor as TEdit).Text;
      end
      else if fMacroNameEditor is TComboBox then
      begin
        fCurrentMacro.MacroName := (fMacroNameEditor as TComboBox).Text;
      end;
    end;
  end;
end;

procedure TVCLMacro.OnClick(pNotifyEvent: TNotifyEvent; Sender: TObject);
begin
  if assigned( pNotifyEvent ) then
  begin
    pNotifyEvent( Sender );
  end;
end;

procedure TVCLMacro.OnNameEditorExit(Sender: TObject);
begin
  GetNameEditorText;
end;

procedure TVCLMacro.OnPauseClick(Sender: TObject);
begin
  if Recording then
  begin
    if Paused then
    begin

    end
    else
    begin
      Paused := TRUE;
    end;
  end;
  OnClick( fOnPauseClick, Sender );
end;

procedure TVCLMacro.OnPlayClick(Sender: TObject);
begin
  OnClick( fOnPlayClick, Sender );
end;

procedure TVCLMacro.OnRecordClick(Sender: TObject);
begin
  if Recording then
  begin
    case MessageDlg('This will restart the macro. Are you sure that you want to do this?', mtWarning, [mbYes, mbNo], 0) of
      mrYes:
      begin
        Recording := TRUE;
      end;
    end;

  end
  else
  begin
    Recording := TRUE;
  end;
  OnClick( fOnRecordClick, Sender );
end;

procedure TVCLMacro.OnSaveClick(Sender: TObject);
begin
  // to do
end;

procedure TVCLMacro.OnStopClick(Sender: TObject);
begin
  Recording := FALSE;
  OnClick( fOnStopClick, Sender );
end;

procedure TVCLMacro.RegisterComponents(const pComponent: TControl);
var
  i: Integer;
begin
  // see if we can handle this one
  if      pComponent is TSpeedButton then
  begin
    if  (pComponent <> fRecordButton)
    and (pComponent <> fStopButton )
    and (pComponent <> fSaveButton )
    and (pComponent <> fLoadButton )
    and (pComponent <> fPlayButton )
    and (pComponent <> fPauseButton ) then
    begin
      Add( TVCLSpeedButtonEntry.Create( self, pComponent as TSpeedButton ));
    end;
  end
  else if pComponent is TPageControl then Add( TVCLPageControlEntry.Create( self, pComponent as TPageControl ))
  else if pComponent is TComboBox then Add( TVCLComboBoxEntry.Create( self, pComponent as TCombobox ))
  else ;
  // and its components
  for i := 0 to pComponent.ComponentCount - 1 do
  begin
    if pComponent.Components[ i ] is TControl then
    begin
      RegisterComponents( pComponent.Components[ i ] as TControl );
    end;
  end;
end;

procedure TVCLMacro.SetLoadButton(const Value: TControl);
begin
  fLoadButton := Value;
end;

procedure TVCLMacro.SetMacroNameEditor(const Value: TControl);
begin
  if assigned( fMacroNameEditor ) then
  begin
    if fMacroNameEditor is TEdit then
    begin
      with fMacroNameEditor as TEdit do
      begin
        OnExit := fOnMacroNameEditorExit;
      end;
    end
    else if fMacroNameEditor is TComboBox then
    begin
      with fMacroNameEditor as TComboBox do
      begin
        OnExit := fOnMacroNameEditorExit;
      end;
    end;
    RegisterComponents( fMacroNameEditor );
  end;
  fMacroNameEditor := Value;
  if assigned( fMacroNameEditor ) then
  begin
    UnRegisterComponent( fMacroNameEditor );
    if fMacroNameEditor is TEdit then
    begin
      with fMacroNameEditor as TEdit do
      begin
        fOnMacroNameEditorExit := OnExit;
        OnExit := OnNameEditorExit;
      end;
    end
    else if fMacroNameEditor is TComboBox then
    begin
      with fMacroNameEditor as TComboBox do
      begin
        fOnMacroNameEditorExit := OnExit;
        OnExit := OnNameEditorExit;
      end;
    end;
  end;
end;

procedure TVCLMacro.SetMainForm(const Value: TForm);
begin
  fMainForm := Value;
  Clear;
  // go through the children
  RegisterComponents( Value );
end;

procedure TVCLMacro.SetPauseButton(const Value: TControl);
begin
  SetControl( Value, fPauseButton, fOnPauseClick, OnPauseClick );
end;

procedure TVCLMacro.SetPaused(const Value: boolean);
begin
  fPaused := Value;
end;

procedure TVCLMacro.SetPlayButton(const Value: TControl);
begin
  SetControl( Value, fPlayButton, fOnPlayClick, OnPlayClick );
end;

procedure TVCLMacro.SetRecordButton(const Value: TControl);
begin
  SetControl( Value, fRecordButton, fOnRecordClick, OnRecordClick );
end;

procedure TVCLMacro.SetRecording(const Value: boolean);
begin
  fRecording := Value;
  if Value then
  begin
    if assigned( fCurrentMacro ) then
    begin
      fCurrentMacro.Clear;
    end
    else
    begin
      fCurrentMacro := fMacroFile.RecordedMacros.AddNewChild;
    end;
    GetNameEditorText;
    if assigned( fRecordButton ) then
    begin
      fRecordButton.Enabled := FALSE;
    end;
    if assigned( fStopButton ) then
    begin
      fStopButton.Enabled := TRUE;
    end;
    if assigned( fSaveButton ) then
    begin
      fSaveButton.Enabled := FALSE;
    end;
    if assigned( fLoadButton ) then
    begin
      fLoadButton.Enabled := FALSE;
    end;
  end
  else
  begin
    if assigned( fRecordButton ) then
    begin
      fRecordButton.Enabled := TRUE;
    end;
    if assigned( fStopButton ) then
    begin
      fStopButton.Enabled := FALSE;
    end;
    if assigned( fSaveButton ) then
    begin
      fSaveButton.Enabled := TRUE;
    end;
    if assigned( fLoadButton ) then
    begin
      fLoadButton.Enabled := TRUE;
    end;
  end;
end;

procedure TVCLMacro.SetSaveButton(const Value: TControl);
begin
  SetControl( Value, fSaveButton, fOnSaveClick, OnSaveClick );
end;

procedure TVCLMacro.SetControl(const pNewButton: TControl;
  var pButton: TControl; var pOnClickEvent: TNotifyEvent;
  const pNewOnClickEvent: TNotifyEvent);
begin
  if assigned( pButton ) then
  begin
    // return the OnClick event
    if pButton is TSpeedButton then
    begin
      with pButton as TSpeedButton do
      begin
        OnClick := pOnClickEvent;
      end;
    end;
    pOnClickEvent := nil;
    // and reregister it
    RegisterComponents( pButton );
  end;
  pButton := pNewButton;
  if assigned( pButton ) then
  begin
    if pButton is TSpeedButton then
    begin
      UnRegisterComponent( pButton );
      with pButton as TSpeedButton do
      begin
        pOnClickEvent := OnClick;
        OnClick := pNewOnClickEvent;
      end;
    end
    else
    begin
      raise Exception.Create('Unable to assign macro button');
    end;
  end;
end;

procedure TVCLMacro.SetStopButton(const Value: TControl);
begin
  fStopButton := Value;
  if assigned( Value ) then
  begin
    UnRegisterComponent( Value );
    if Value is TSpeedButton then
    begin
      with Value as TSpeedButton do
      begin
        fOnStopClick := OnClick;
        OnClick := OnStopClick;
      end;
    end;
  end;
end;

procedure TVCLMacro.UnRegisterComponent(const pComponent: TControl);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[ i ].Control = pComponent then
    begin
      Delete( i );
      exit;
    end;
  end;
end;

{ TVCLMacroEntry }

constructor TVCLMacroEntry.Create(const pOwner: TVCLMacro; const pControl : TControl);
begin
  inherited Create;
  fOwner := pOwner;
  fControl := pControl;
end;

{ TRecordedLine }

constructor TRecordedLine.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fComponentName := TSigTextProperty.Create( 'ComponentName', self );
  fAction := TSigEnum< TRecordedAction >.Create( 'Action', self );
  fClickItem := TSigIntegerProperty.Create( 'ClickItem', self );
  fEditText := TSigTextProperty.Create( 'EditText', self );

end;

function TRecordedLine.GetAction: TRecordedAction;
begin
  Result := TRecordedAction( fAction.ValueAsInt );
end;

function TRecordedLine.GetClickItem: integer;
begin
  Result := fClickItem.ValueAsInt;
end;

function TRecordedLine.GetComponentName: string;
begin
  Result := fComponentName.Value;
end;

function TRecordedLine.GetEditText: string;
begin
  Result := fEditText.Value;
end;

procedure TRecordedLine.Playback;
begin
  if assigned( fPlayback ) then
  begin
    fPlayback( Action, ClickItem, EditText );
  end;
end;

procedure TRecordedLine.SetAction(const Value: TRecordedAction);
begin
  fAction.ValueAsInt := Ord( Value );
end;

procedure TRecordedLine.SetClickItem(const Value: integer);
begin
  fClickItem.ValueAsInt := Value;
end;

procedure TRecordedLine.SetComponentName(const Value: string);
begin
  fComponentName.Value := Value;
end;

procedure TRecordedLine.SetEditText(const Value: string);
begin
  fEditText.Value := Value;
end;

{ TVCLSpeedButtonEntry }

constructor TVCLSpeedButtonEntry.Create(const pOwner: TVCLMacro;
  const pControl: TSpeedButton);
begin
  inherited Create( pOwner, pControl );
  if assigned( pControl ) then
  begin
    fOnClick := pControl.OnClick;
    pControl.OnClick := OnClick;
  end;
end;

destructor TVCLSpeedButtonEntry.Destroy;
begin
  if assigned( fControl ) then
  begin
    with fControl as TSpeedButton do
    begin
      OnClick := fOnClick;
    end;
  end;
  inherited;
end;

function TVCLSpeedButtonEntry.GetControl: TSpeedButton;
begin
  Result := fControl as TSpeedButton;
end;

procedure TVCLSpeedButtonEntry.OnClick(Sender: TObject);
var
  iLine : TRecordedLine;
begin
  if Owner.Recording then
  begin
    iLine := Owner.fCurrentMacro.AddNewChild;
    iLine.Action := raClick;
    iLine.OnPlayback := Playback;
  end;
  if assigned( fOnClick ) then
  begin
    fOnClick( Sender );
  end;
end;

procedure TVCLSpeedButtonEntry.Playback(const pAction: TRecordedAction;
  const pClickItem: integer; const pTextItem: string);
begin
  case pAction of
    raClick:
    begin
      (fControl as TSpeedButton ).Click;
    end;
    raClickItem: ;
    raEnterText: ;
    else ;
  end;
end;

{ TVCLPageControlEntry }

constructor TVCLPageControlEntry.Create(const pOwner: TVCLMacro;
  const pControl: TPageControl);
begin
  inherited Create( pOwner, pControl );
  if assigned( pControl ) then
  begin
    fOnChange := pControl.OnChange;
    pControl.OnChange := OnChange;
  end;
end;

destructor TVCLPageControlEntry.Destroy;
begin
  if assigned( fControl ) then
  begin
    with fControl as TPageControl do
    begin
      OnChange := fOnChange;
    end;
  end;

  inherited;
end;

function TVCLPageControlEntry.GetControl: TPageControl;
begin
  Result := fControl as TPageControl;
end;

procedure TVCLPageControlEntry.OnChange(Sender: TObject);
var
  iLine : TRecordedLine;
begin
  if Owner.Recording then
  begin
    iLine := Owner.fCurrentMacro.AddNewChild;
    iLine.Action := raClickItem;
    iLine.ClickItem := (fControl as TPageControl).ActivePageIndex;
    iLine.OnPlayback := Playback;
  end;
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
end;

procedure TVCLPageControlEntry.Playback(const pAction: TRecordedAction;
  const pClickItem: integer; const pTextItem: string);
begin
  case pAction of
    raClick: ;
    raClickItem:
    begin
      (fControl as TPageControl).ActivePageIndex := pClickItem;
    end;
    raEnterText: ;
    else ;
  end;
end;

{ TVCLComboBoxEntry }

constructor TVCLComboBoxEntry.Create(const pOwner: TVCLMacro;
  const pControl: TComboBox);
begin
  inherited Create( pOwner, pControl );
  if assigned( pControl ) then
  begin
    fOnClick := pControl.OnClick;
    pControl.OnClick := OnClick;
    fOnChange := pControl.OnChange;
    pControl.OnChange := OnChange;
  end;
end;

destructor TVCLComboBoxEntry.Destroy;
begin
  if assigned( fControl ) then
  begin
    with fControl as TComboBox do
    begin
      OnChange := fOnChange;
      OnClick  := fOnClick;
    end;
  end;

  inherited;
end;

function TVCLComboBoxEntry.GetControl: TComboBox;
begin
  Result := fControl as TComboBox;
end;

procedure TVCLComboBoxEntry.OnChange(Sender: TObject);
var
  iLine : TRecordedLine;
begin
  if Owner.Recording then
  begin
    iLine := Owner.fCurrentMacro.AddNewChild;
    iLine.Action := raEnterText;
    iLine.EditText := Control.Text;
    iLine.OnPlayback := Playback;
  end;
  if assigned( fOnChange ) then
  begin
    fOnChange( Sender );
  end;
end;

procedure TVCLComboBoxEntry.OnClick(Sender: TObject);
var
  iLine : TRecordedLine;
begin
  if Owner.Recording then
  begin
    iLine := Owner.fCurrentMacro.AddNewChild;
    iLine.Action := raClickItem;
    iLine.ClickItem := Control.ItemIndex;
    iLine.OnPlayback := Playback;
  end;
  if assigned( fOnClick ) then
  begin
    fOnClick( Sender );
  end;
end;

procedure TVCLComboBoxEntry.Playback(const pAction: TRecordedAction;
  const pClickItem: integer; const pTextItem: string);
begin
  case pAction of
    raClick: ;
    raClickItem:
    begin
      Control.ItemIndex := pClickItem;
    end;
    raEnterText:
    begin
      Control.Text := pTextItem;
    end
    else ;
  end;
end;

{ TMacroFile }

constructor TMacroFile.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;

  fRecordedMacros := TRecordedMacros.Create( 'Macros', self );
end;

{ TRecordedMacro }

constructor TRecordedMacro.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fMacroName := TSigTextProperty.Create( 'Macro Name', self );
end;

function TRecordedMacro.GetMacroName: string;
begin
  Result := fMacroName.Value;
end;

procedure TRecordedMacro.SetMacroName(const Value: string);
begin
  fMacroName.Value := Value;
end;

end.
