unit UnitSigDBEditor;

(********************************************************************
 *                                                                  *
 * Attempt to integrate the DB editor into the IDE.                 *
 *                                                                  *
 * We start very much as if we were creating a wizard, with a       *
 * module and at least one view.                                    *
 * We start with a view that just gives memo box listing of the     *
 * file, but that will not be the main view ultimately. However it  *
 * should be relatively simple to implement. We do NOT use the main *
 * IDE code editor even though that would be simpler.               *
 *                                                                  *
 ********************************************************************
 *                                                                  *
 * v1.0.0.0 Basic implementation of a Wizard, but unlike the usual  *
 *          ones, derived from a more basic level.                  *
 *                                                                  *
 ********************************************************************)

interface

uses
  ToolsAPI;

type
  TSigDBEditor = class( TNotifierObject, IOTAWizard )
  private
  protected
  public
    { Expert UI strings }
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

    { Launch the AddIn }
    procedure Execute;
  end;

  // Values of interest
  {
  TOTAModuleType = type Integer;
  TOTAHandle = Pointer;
  TOTAAddress = UInt64;
  }
  { value for TOTAModuleType
    omtCustom        = 13; }
  (*
  sNonePersonality = 'None.Personality';
  { This is the default personality that is used to register default file
    personality traits. }
  sDefaultPersonality = 'Default.Personality';
  { The following are Borland created personalities }
  sDesignPersonality = 'Design.Personality';
  sGenericPersonality = 'Generic.Personality';

  { Gallery Categories }
  { You can now add your wizards to specific categories in the Gallery.
    You must first register or find your category before using it.
    The following categories will (probably) exist. }
  sCategoryRoot = 'Borland.Root';
  sCategoryGalileoOther = 'Borland.Galileo.Other';
  sCategoryDelphiNew = 'Borland.Delphi.New';
  sCategoryDelphiNewFiles = 'Borland.Delphi.NewFiles';
  sCategoryDelphiDotNetNew = 'Borland.Delphi.NET.New';
  sCategoryDelphiDotNetNewFiles = 'Borland.Delphi.NET.NewFiles';
  sCategoryCBuilderNew = 'Borland.CBuilder.New';
  sCategoryCBuilderNewFiles = 'Borland.CBuilder.NewFiles';
  sCategoryCurrentProject = 'Borland.CurrentProject';
  sCategoryCSharpNew = 'Borland.CSharp.New';
  sCategoryCSharpNewFiles = 'Borland.CSharp.NewFiles';
  sCategoryMarkupNew = 'Borland.Markup.New';
  sCategoryMarkupNewFiles = 'Borland.Markup.NewFiles';
  sCategoryVBNew = 'Borland.VB.New';
  sCategoryVBNewFiles = 'Borland.VB.NewFiles';
  sCategoryNewUnitTest = 'UnitTest.Test';

  { IOTAEditOptions now are associated with file types. See
    IOTAEditorServices for more information }
  cDefEdOptions = 'Borland.EditOptions.';
  cDefEdDefault = cDefEdOptions + 'Default';
  cDefEdPascal = cDefEdOptions + 'Pascal';
  cDefEdC = cDefEdOptions + 'C';
  cDefEdCSharp = cDefEdOptions + 'C#';
  cDefEdHTML = cDefEdOptions + 'HTML';
  cDefEdXML = cDefEdOptions + 'XML';
  cDefEdSQL = cDefEdOptions + 'SQL';
  cDefEdIDL = cDefEdOptions + 'IDL';
  cDefEdVisualBasic = cDefEdOptions + 'VisualBasic';
  cDefEdJavaScript = cDefEdOptions + 'JavaScript';
  cDefEdStyleSheet = cDefEdOptions + 'StyleSheet';
  cDefEdINI = cDefEdOptions + 'INI';
  cDefEdPHP = cDefEdOptions + 'PHP';

  { Designer command string constants.  These are strings so that new commands
    can be added without affecting the interfaces.  This allows commands to be
    added without affecting the IDE core. }

  dcAlign = 'Align';

  dcSize = 'Size';
  dcScale = 'Scale';
  dcTabOrder = 'TabOrder';
  dcCreationOrder = 'CreationOrder';
  dcLockControls = 'LockControls';
  dcFlipChildrenAll = 'FlipChildrenAll';
  dcFlipChildrenSelected = 'FilpChildrenSelected';

  { Use these constants calling INTAEditWindow.CreateDockableForm in order to
    fulfill a loose contract with all personalities who wish to implement a
    specific type of functionality.  For instance, a personality (or group of
    personalities) may ask to create a Borland.CodeExplorer dockable window.
    Then all subsequent personalities that ask to the Borland.CodeExplorer will
    get this same window.  This allows a *type* of window to share the same
    space with all the other personalities. }

  sBorlandEditorCodeExplorer = 'BorlandEditorCodeExplorer';

 { Some of the preset identifers that could be passed to
  INTAProjectMenuCreatorNotifier.  Other values could be file names.
 }
  sBaseContainer = 'BaseContainer';
  sFileContainer = 'FileContainer';
  sProjectContainer = 'ProjectContainer';
  sProjectGroupContainer = 'ProjectGroupContainer';
  sCategoryContainer = 'CategoryContainer';
  sDirectoryContainer = 'DirectoryContainer';
  sReferencesContainer = 'References';
  sContainsContainer = 'Contains';
  sRequiresContainer = 'Requires';
  sVirtualFoldContainer = 'VirtualFold';
  sBuildConfigContainer = 'BuildConfig';
  sOptionSetContainer = 'OptionSet';
  sTargetPlatformContainer = 'TargetPlatformContainer';

  vvfPrivate = $00;
  vvfProtected = $01;
  vvfPublic = $02;
  vvfPublished = $03;
  vvfVisMask = $04;
  vvfDeprecated = $08;

  sBaseConfigurationKey = 'Base';

  { These constants can be used to specify the priority of an INTACustomEditorSubView }
  svpHighest = Low(Integer);
  svpHigh = -255;
  svpNormal = 0;
  svpLow = 255;
  svpLowest = High(Integer);

  { Base user offset }
  pmmpUserOffset = 500000;

  { These constants should be used by addins in order to avoid collisions with built-in menu items.
    If a collision occurs, the order of the menu items may not be predictable }
  pmmpUserBuild = pmmpBuildSection + pmmpUserOffset;
  pmmpUserOpen = pmmpOpenSection + pmmpUserOffset;
  pmmpUserAdd = pmmpAddSection + pmmpUserOffset;
  pmmpUserRemove = pmmpRemoveSection + pmmpUserOffset;
  pmmpUserSave = pmmpSaveSection + pmmpUserOffset;
  pmmpUserRename = pmmpRenameSection + pmmpUserOffset;
  pmmpUserVersionControl = pmmpVersionControl + pmmpUserOffset;
  pmmpUserUtils = pmmpUtilsSection + pmmpUserOffset;
  pmmpUserReorder = pmmpReorderSection + pmmpUserOffset;
  pmmpUserOptions = pmmpOptionsSection + pmmpUserOffset;
  pmmpUserBuildConfig = pmmpUserOffset + pmmpBuildConfig;

  IOTAEditor = interface(IUnknown)
    ['{F17A7BD0-E07D-11D1-AB0B-00C04FB16FB3}']
    { Call this to register an IOTANotifier. The result is the index to be
      used when calling RemoveNotifier. If <0 then an error occurred. }
    function AddNotifier(const ANotifier: IOTANotifier): Integer;
    { Returns the actual filename of this module editor. Rename through
      IOTAModule}
    function GetFileName: string;
    { Returns the editor specific modified status }
    function GetModified: Boolean;
    { Returns the associated IOTAModule }
    function GetModule: IOTAModule;
    { Mark this editor modified.  The associated module will also be modified }
    function MarkModified: Boolean;
    { Call with the index obtained from AddNotifier }
    procedure RemoveNotifier(Index: Integer);
    { Show this editor.  If no views are active, at least one will be created }
    procedure Show;

    property FileName: string read GetFileName;
    property Modified: Boolean read GetModified;
    property Module: IOTAModule read GetModule;
  end;

  IOTASourceEditor70 = interface(IOTAEditor)
    ['{F17A7BD1-E07D-11D1-AB0B-00C04FB16FB3}']
    { Create and return an IOTAEditReader }
    function CreateReader: IOTAEditReader;
    { Create and return an IOTAEditWriter. Changes are not undoable }
    function CreateWriter: IOTAEditWriter;
    { Create and return an IOTAEditWriter. Changes are undoable }
    function CreateUndoableWriter: IOTAEditWriter;
    { Return the number of active views on this editor }
    function GetEditViewCount: Integer;
    { Return the Indexed view }
    function GetEditView(Index: Integer): IOTAEditView;
    { Returns the total number of lines in this source editor }
    function GetLinesInBuffer: Longint;
    { Change the syntax highlighter for this buffer or if shQuery is set,
      simply return the currently set highlighter.
      SetSyntaxHighlighter is deprecated. Use the IOTAEditOptions. }
    function SetSyntaxHighlighter(SyntaxHighlighter: TOTASyntaxHighlighter): TOTASyntaxHighlighter; deprecated;
    { These functions will affect all views on this buffer. }
    function GetBlockAfter: TOTACharPos;
    function GetBlockStart: TOTACharPos;
    function GetBlockType: TOTABlockType;
    function GetBlockVisible: Boolean;
    procedure SetBlockAfter(const Value: TOTACharPos);
    procedure SetBlockStart(const Value: TOTACharPos);
    procedure SetBlockType(Value: TOTABlockType);
    procedure SetBlockVisible(Value: Boolean);

    property BlockStart: TOTACharPos read GetBlockStart write SetBlockStart;
    property BlockAfter: TOTACharPos read GetBlockAfter write SetBlockAfter;
    property BlockType: TOTABlockType read GetBlockType write SetBlockType;
    property BlockVisible: Boolean read GetBlockVisible write SetBlockVisible;
    property EditViewCount: Integer read GetEditViewCount;
    property EditViews[Index: Integer]: IOTAEditView read GetEditView;
  end;

  IOTASourceEditor180 = interface(IOTASourceEditor70)
    ['{5D965803-8147-4D32-B8C5-712F6DDCF98E}']
    { Get the number of sub-Views on this editor.  This editor itself may be a
      sub view and may not be at index 0.  !!NOTE!! that this function will
      return 0 if this SourceEditor is not visible in any editor window.  You must
      call IOTAEditor.Show before using these functions to manipulate the views. }
    function GetSubViewCount: Integer;
    { Returns a view identifier for the given sub-view index.  This may just be
      the specific filename of the view or some other unique identifier }
    function GetSubViewIdentifier(Index: Integer): string;
    { Returns the sub-view index for this editor.  If this is the main source
      editor, its index will always be 0.  However for modules with more than
      one source editor, this may return > 0. (ie. Managed .cpp files with an
      associated .h file) }
    function GetSubViewIndex: Integer;
    { Switches the editor to the specified view by view index }
    procedure SwitchToView(Index: Integer); overload;
    { Switches the editor to the specified view by view identifier }
    procedure SwitchToView(const AViewIdentifier: string); overload;
  end;

  IOTASourceEditor = interface(IOTASourceEditor180)
    ['{4D460588-10A6-4CAD-87E7-5654266073F9}']
    { Switches the editor to the specified view by view index.
      The AViewContext parameter is passed along to the specified view which can be used
      to indicate any view-specific context or selection criteria. }
    procedure SwitchToView(Index: Integer; const AViewContext: TObject); overload;
    { Switches the editor to the specified view by view identifier.
      The AViewContext parameter is passed along to the specified view which can be used
      to indicate any view-specific context or selection criteria. }
    procedure SwitchToView(const AViewIdentifier: string; const AViewContext: TObject); overload;
  end;

  INTAServices = interface(INTAServices120)
    ['{8209041F-F37F-4570-88B8-6C310FFFF81A}']
    { Registers an INTACustomDockableForm with the IDE.  Registration is not
      required, but doing so will allow the form to participate in saving to and
      loading from a desktop state.  To ensure proper handling of the desktop
      state that is loaded during IDE startup, be sure to call
      RegisterDockableForm from within a "Register" procedure in your package.
      If you do not want your form to participate in desktop saving, you can
      call CreateDockableForm directly without first registering your form }
    procedure RegisterDockableForm(const CustomDockableForm: INTACustomDockableForm);
    { Unregisters a previously registered INTACustomDockableForm }
    procedure UnregisterDockableForm(const CustomDockableForm: INTACustomDockableForm);
    { Creates and displays an INTACustomDockableForm.  Returns the form instance
      that was created. }
    function CreateDockableForm(const CustomDockableForm: INTACustomDockableForm): TCustomForm;
  end;
  *)

implementation

end.
