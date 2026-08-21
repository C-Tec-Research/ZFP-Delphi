unit UnitSigFileGUI;

interface

uses
  Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls,
{$IFNDEF SIGDEBUG}
  ToolsAPI,
  DesignIntf,
{$ENDIF}
  UnitProjectExportFile,
  Grids,
  SigGeneralGrid,
  UnitSigFileAnalyser,
  SigFile, SigSaveDialog;

type
  TFormSigFileGUI = class(TForm)
    Panel1: TPanel;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    Panel2: TPanel;
    Label1: TLabel;
    EditApplicationName: TEdit;
    Panel3: TPanel;
    EditEditProjectDirectory: TEdit;
    Label2: TLabel;
    SpeedButtonBrowseProjectDirectory: TSpeedButton;
    PageControlMain: TPageControl;
    TabSheetSigFileEnums: TTabSheet;
    TabSheetGeneral: TTabSheet;
    Panel4: TPanel;
    CheckBoxUsesUndRedo: TCheckBox;
    CheckBoxUsesPrint: TCheckBox;
    GroupBoxCompanyName: TGroupBox;
    RadioButtonC_Tec: TRadioButton;
    RadioButtonSigNET: TRadioButton;
    RadioButtonOther: TRadioButton;
    EditCompanyName: TEdit;
    TabSheetCustomTypes: TTabSheet;
    TabSheetSigFileDescendant: TTabSheet;
    CheckBoxRestoreLastWindowsSetup: TCheckBox;
    CheckBoxReloadLastSavedFile: TCheckBox;
    CheckBoxUsesCfgFile: TCheckBox;
    OpenDialogProject: TOpenDialog;
    TabSheetInfo: TTabSheet;
    Panel5: TPanel;
    Panel6: TPanel;
    Label3: TLabel;
    EditModuleCount: TEdit;
    Panel7: TPanel;
    SigGeneralGridModuleInfo: TSigGeneralGrid;
    tSigGridEditorModuleType: tSigGridEditor;
    tSigGridEditorName: tSigGridEditor;
    tSigGridEditorFileName: tSigGridEditor;
    tSigGridEditorDesignClass: tSigGridEditor;
    Label4: TLabel;
    PageControl1: TPageControl;
    TabSheetSigFile: TTabSheet;
    TabSheetCfgFile: TTabSheet;
    Panel8: TPanel;
    Label5: TLabel;
    EditSigFileDescendant: TEdit;
    Panel9: TPanel;
    SpeedButtonExport: TSpeedButton;
    SpeedButtonImport: TSpeedButton;
    SigSaveDialogImportExport: TSigSaveDialog;
    procedure SpeedButtonBrowseProjectDirectoryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButtonExportClick(Sender: TObject);
    procedure SpeedButtonImportClick(Sender: TObject);
  private
    fFileName: string;
    fOnCreateProject: tNotifyEvent;
    fSigFileDescendant: string;
    fFileAnalyser: tSigFileAnalyser;
{$IFNDEF SIGDEBUG}
    fProject : IOTAProject;
{$ENDIF}
    fSigFile: tProjectFile;
    procedure SetFileName(const Value: string);
    procedure SetSigFileDescendant(const Value: string);
{$IFNDEF SIGDEBUG}
    procedure SetProject(const Value: IOTAProject);
{$ENDIF}
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
    procedure ShowModule( const pIndex : integer; const pModule : tSigModule );
{$IFNDEF SIGDEBUG}
    property Project : IOTAProject
             read fProject
             write SetProject;
{$ENDIF}
    property ProjectName : string
             read fFileName
             write SetFileName;
    property FileAnalyser : tSigFileAnalyser
             read fFileAnalyser;
    function CreateProject( const pFileName : string ) : boolean;
    property OnCreateProject : tNotifyEvent
             read fOnCreateProject
             write fOnCreateProject;

    function LoadFiles : boolean; // loads source files, if available, and populates fields
                                  // NOTE ProjectName MUST be set up before calling this.

    property SigFileDescendant : string
             read fSigFileDescendant
             write SetSigFileDescendant;
    procedure ShowPages( NewVal : boolean );

    property SigFile : tProjectFile
             read fSigFile;

    procedure ExportProject( const pFileName : string );

    procedure UpdateChanges;  // implement the changes
  end;

var
  FormSigFileGUI: TFormSigFileGUI;

{$IFNDEF SIGDEBUG}
type
  tSigFileExpert = class( TInterfacedObject, IOTARepositoryWizard, IOTANotifier,
                 IOTAMenuWizard, IOTAWizard )
  private
  protected
    fSigFormGUI : TFormSigFileGUI;
    fProject : IOTAProject;
  public
    { Expert UI strings }
    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Modified;
    procedure Destroyed;

    //IOTARepositoryWizard
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

    procedure Execute;

    function GetAuthor: string;
    function GetComment: string;
    function GetPage: string;
    function GetGlyph: Cardinal;
    //function GetStyle: TWizardStyle; override; stdcall;

    // IOTAMenuWizard
    function GetMenuText: string;

    { Launch the Expert }
    procedure OnCreateProject( Sender : tObject );

    // others


  end;
{$ENDIF}

{$IFNDEF SIGDEBUG}
  procedure Register;
{$ENDIF}

implementation

{$R *.dfm}

{$IFNDEF SIGDEBUG}
procedure Register;
begin
  RegisterPackageWizard( tSigFileExpert.Create );
end;
{$ENDIF}

{ TFormSigFileGUI }

function TFormSigFileGUI.CreateProject(const pFileName: string) : boolean;
var
  iFileName : string;
  iStrings : tStringList;
  iDirectory : string;
  iProjName : string;
  iLibRelPath : string;
  iSource, iDest : string;
const
  cSourceLib = 'C:\Delphi Projects\Templates\SigFile Template\';
begin
  //iFileName := ChangeFileExt( FileName, '.dproj' );  // make sure is a dproj
  Result := FALSE;
  iFileName := pFileName;
  if FileExists( iFileName ) then
  begin
    exit; // don't overwrite
  end;
  iStrings := tStringList.Create;
  try
    iDirectory := ExtractFilePath( iFileName ); // Path should exist but make sure
    Result := ForceDirectories( iDirectory );
    if not Result then exit;
    iProjName := ExtractFileName( iFileName );
    iProjName := ChangeFileExt( iProjName, '' );
    iLibRelPath := ExtractRelativePath( iDirectory, 'C:\Delphi Projects\Lib\' );
    with iStrings do
    begin
      // first Copy the pas and dfm files from C:\Delphi Projects\Templates\SigFile Template
      iSource := cSourceLib + 'about.dfm' + #0;
      iDest := iDirectory + 'about.dfm' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      iSource := cSourceLib + 'about.pas' + #0;
      iDest := iDirectory + 'about.pas' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      iSource := cSourceLib + 'UnitMain.dfm' + #0;
      iDest := iDirectory + 'UnitMain.dfm' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      iSource := cSourceLib + 'UnitMain.pas' + #0;
      iDest := iDirectory + 'UnitMain.pas' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      iSource := cSourceLib + 'UnitFiles.pas' + #0;
      iDest := iDirectory + 'UnitFiles.pas' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      iSource := cSourceLib + 'SigFileTemplate.res' + #0;
      iDest := iDirectory + iProjName + '.res' + #0;
      CopyFile( @iSource[1], @iDest[1], FALSE );
      // now create the dpr file
      Clear;
      Add( 'program ' + iProjName + ';');
      Add( '' );
      Add( 'uses');
      Add( '  Forms,' );
      Add( '  UnitMain in ''UnitMain.pas'' {FormMain},' );
      Add( '  about in ''about.pas'' {AboutBox},' );
      Add( '  UnitFiles in ''UnitFiles.pas'',' );
      Add( '  SelectableEdit in ''' + iLibRelPath + 'SelectableEdit\SelectableEdit.pas'',' );
      Add( '  SigFile in ''' + iLibRelPath + 'SigFile\SigFile.pas'',' );
      Add( '  ErrorList in ''' + iLibRelPath + 'ErrorList\ErrorList.pas'',' );
      Add( '  UnitUndoList in ''' + iLibRelPath + 'UndoRedo\UnitUndoList.pas'',' );
      Add( '  PrevPrinter in ''' + iLibRelPath + 'Printer\PrevPrinter.pas'';' );
      Add( '' );
      Add( '{$R *.res}' );
      Add( '' );
      Add( 'begin' );
      Add( '  Application.Initialize;' );
      Add( '  Application.MainFormOnTaskbar := True;' );
      Add( '  Application.CreateForm(TFormMain, FormMain);' );
      Add( '  Application.CreateForm(TAboutBox, AboutBox);' );
      Add( '  Application.Run;' );
      Add( 'end.' );
      SaveToFile( ChangeFileExt( iFileName, '.dpr' ));
    end;

  finally
    iStrings.Free;
  end;
end;

function TFormSigFileGUI.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormSigFileGUI.ExportProject(const pFileName: string);
begin

    fSigFile.SaveAs( pFileName );

end;

procedure TFormSigFileGUI.FormCreate(Sender: TObject);
begin
  // although TFormSigFileGUI 'owns' these, that is for convenience mainly
  fFileAnalyser := tSigFileAnalyser.Create;
  fSigFile := tProjectFile.Create( 'Project File', nil );
end;

procedure TFormSigFileGUI.FormDestroy(Sender: TObject);
begin
  fFileAnalyser.Free;
  fSigFile.Free;
end;

function TFormSigFileGUI.LoadFiles: boolean;
var
  iDirectory : string;
begin
  iDirectory := EditEditProjectDirectory.Text;
  Result := FileAnalyser.LoadFiles( iDirectory );
  PageControlMain.ActivePage := TabSheetInfo; // always visible
  SigFileDescendant := FileAnalyser.SigFileDescendant;
  ShowPages( Result );
end;

{$IFNDEF SIGDEBUG}
{ tSigFileExpert }

procedure tSigFileExpert.AfterSave;
begin
  // does nothing
end;

procedure tSigFileExpert.BeforeSave;
begin
  // does nothing
end;

procedure tSigFileExpert.Destroyed;
begin
  //
end;

procedure tSigFileExpert.Execute;
begin
  fSigFormGUI := TFormSigFileGUI.Create( nil );

  if assigned( BorlandIDEServices ) then
  begin
    fProject := GetActiveProject;
    fSigFormGUI.Project := fProject;
  end;
  with fSigFormGUI do
  begin
    {
      // We don't allow import when in Expert mode (but we do allow export)
    }
    SpeedButtonImport.Visible := FALSE;
    OnCreateProject := self.OnCreateProject;
    LoadFiles;
    if Execute then
    begin
      UpdateChanges();
      fProject.MarkModified;
    end;
  end;
  fSigFormGUI.Free;
end;

function tSigFileExpert.GetAuthor: string;
begin
  Result := 'D. S. Mear';
end;

function tSigFileExpert.GetComment: string;
begin
  Result := 'Maintains an SigFile based application';
end;

function tSigFileExpert.GetGlyph: Cardinal;
begin
  Result := 0;
end;

function tSigFileExpert.GetIDString: string;
begin
  Result := 'SigNET.tSigFileExpert';
end;

function tSigFileExpert.GetMenuText: string;
begin
  Result := 'Maintain SigFile Application';
end;

function tSigFileExpert.GetName: string;
begin
  Result := 'SigNET SigFile Application Wizard';
end;

function tSigFileExpert.GetPage: string;
begin
  Result := '';
end;

function tSigFileExpert.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure tSigFileExpert.Modified;
begin
  // ???
end;

procedure tSigFileExpert.OnCreateProject(Sender: tObject);
begin
  with fSigFormGUI  do
  begin
    CreateProject( ProjectName );
    with fSigFormGUI.SigGeneralGridModuleInfo do
    begin
      RowCount := 2; // debug
      Cell[ 0, 1 ] := IntToStr(  1 );
      Cell[ 1, 1 ] := '';
      Cell[ 2, 1 ] := '';
      Cell[ 3, 1 ] := ProjectName;
      Cell[ 4, 1 ] := '';
    end;
  end;
end;
{$ENDIF}

procedure TFormSigFileGUI.SetFileName(const Value: string);
begin
  fFileName := Value;
  EditApplicationName.Text := ExtractFileName( Value );
  EditEditProjectDirectory.Text := ExtractFilePath( Value );
end;

{$IFNDEF SIGDEBUG}
procedure TFormSigFileGUI.SetProject(const Value: IOTAProject);
var
  i, iModuleCount : integer;
  //iModule : IOTAModuleInfo;
begin
  fProject := Value;
  fSigFile.Assign( fProject );
  if assigned( fProject ) then
  begin
    ProjectName := fProject.FileName;
    fSigFile.ProjectName.Value := ProjectName;

    iModuleCount := Project.GetModuleCount;
    EditModuleCount.Text := IntToStr( iModuleCount );
    SigGeneralGridModuleInfo.RowCount := iModuleCount + 1;
    for i := 0 to iModuleCount - 1 do
    begin
      ShowModule( i + 1, fSigFile.ModuleList.Module[ i ] );
    end;
  end;
end;
{$ENDIF}

procedure TFormSigFileGUI.SetSigFileDescendant(const Value: string);
begin
  fSigFileDescendant := Value;
  EditSigFileDescendant.Text := Value;
end;

procedure TFormSigFileGUI.ShowModule(const pIndex: integer;
  const pModule: tSigModule);
begin
  with SigGeneralGridModuleInfo do
  begin
    Cell[ 0, pIndex ] := IntToStr( pIndex - 1 );
    Cell[ 1, pIndex ] := IntToStr( pModule.ModuleType.ValueAsInt );
    Cell[ 2, pIndex ] := pModule.Name.Value;
    Cell[ 3, pIndex ] := pModule.FileName.Value;
    Cell[ 4, pIndex ] := pModule.DesignClass.Value;
  end;
end;

procedure TFormSigFileGUI.ShowPages(NewVal: boolean);
begin
  TabSheetGeneral.TabVisible := NewVal;
  TabSheetSigFileEnums.TabVisible := NewVal;
  TabSheetCustomTypes.TabVisible := NewVal;
  TabSheetSigFileDescendant.TabVisible := NewVal;
end;

procedure TFormSigFileGUI.SpeedButtonBrowseProjectDirectoryClick(
  Sender: TObject);
begin
  with OpenDialogProject do
  begin
    FileName := EditApplicationName.Text;
    InitialDir := EditEditProjectDirectory.Text;
    if Execute then
    begin
      ProjectName := FileName;
      if not FileExists( FileName ) then
      begin
        if assigned( fOnCreateProject ) then
        begin
          fOnCreateProject( self );
        end;
      end;
    end;
  end;
end;

procedure TFormSigFileGUI.SpeedButtonExportClick(Sender: TObject);
begin
  SigSaveDialogImportExport.InitialDir := EditEditProjectDirectory.Text;
  fSigFile.SaveDialog := SigSaveDialogImportExport;
  fSigFile.Save();
end;

procedure TFormSigFileGUI.SpeedButtonImportClick(Sender: TObject);
var
  i, iModuleCount : integer;
  //iModule : IOTAModuleInfo;
begin
  fSigFile.SaveDialog := SigSaveDialogImportExport;
  fSigFile.Load();
  ProjectName := fSigFile.ProjectName.Value;

  iModuleCount := fSigFile.ModuleList.Max + 1;
  EditModuleCount.Text := IntToStr( iModuleCount );
  SigGeneralGridModuleInfo.RowCount := iModuleCount + 1;
  for i := 0 to iModuleCount - 1 do
  begin
    ShowModule( i + 1, fSigFile.ModuleList.Module[ i ] );
  end;
  LoadFiles();
end;

procedure TFormSigFileGUI.UpdateChanges;
begin
  if EditSigFileDescendant.Text <> FileAnalyser.SigFileDescendant then
  begin
    FileAnalyser.ChangeSigName( SigFile, FileAnalyser.SigFileDescendant, EditSigFileDescendant.Text );
  end;
end;

end.
