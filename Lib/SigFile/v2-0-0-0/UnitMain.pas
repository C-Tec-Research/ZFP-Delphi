unit UnitMain;

interface

{
  To use this, create from repository - will copy to new file.
  Update version info.
  Change exe project name in project group window.
}

uses
  Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms,
  Dialogs, Menus,
  about, ExtCtrls, SigSaveDialog, SigRegistry,
  UnitUndoList, Buttons,
  SigFile, ImgList, PrevPrinter,
  UnitFiles,
  UnitTreeViewHelper,
  StdCtrls,
  SigFilePgmStatus, SigPanel,
  Vcl.ComCtrls, SigGeneralGrid, Vcl.Grids,
  Vcl.Samples.Spin, SigSpinEdit,
  Vcl.CheckLst,
  SigVariableEditorList;

type
  TFormMain = class(TForm)
    MainMenu: TMainMenu;
    Panel1: TPanel;
    PanelEditMode: TPanel;
    Panel3: TPanel;
    SigRegistry: TSigRegistry;
    SigSaveDialogMain: TSigSaveDialog;
    SpeedButtonUndo: TSpeedButton;
    SpeedButtonRedo: TSpeedButton;
    ImageListUndoRedo: TImageList;
    PreviewPrinterMain: TPreviewPrinter;
    PrintDialog: TPrintDialog;
    PrinterSetupDialog: TPrinterSetupDialog;
    SpeedButtonPrint: TSpeedButton;
    SpeedButtonPrintPreview: TSpeedButton;
    SpeedButtonPrintSetup: TSpeedButton;
    SpeedButtonNew: TSpeedButton;
    SpeedButtonOpen: TSpeedButton;
    SpeedButtonSave: TSpeedButton;
    SpeedButtonSaveAs: TSpeedButton;
    SpeedButtonBack: TSpeedButton;
    SpeedButtonForward: TSpeedButton;
    PageControlMain: TPageControl;
    TabSheetFiles: TTabSheet;
    SigPanel6: TSigPanel;
    SigPanel7: TSigPanel;
    SigPanel8: TSigPanel;
    SigPanel9: TSigPanel;
    SigPanel10: TSigPanel;
    SigPanel11: TSigPanel;
    MemoFilesSource: TMemo;
    SpeedButtonNewFile: TSpeedButton;
    SpeedButtonBuildSource: TSpeedButton;
    TabControlFiles: TTabControl;
    SigPanel12: TSigPanel;
    PageControlFiles: TPageControl;
    TabSheetRecord: TTabSheet;
    TabSheetIndexes: TTabSheet;
    TabSheetFile: TTabSheet;
    SigPanel13: TSigPanel;
    Label2: TLabel;
    EditFileBaseName: TEdit;
    TabSheetPas: TTabSheet;
    SigPanel14: TSigPanel;
    Label4: TLabel;
    MemoFileAdditionalTypes: TMemo;
    SigPanel17: TSigPanel;
    SigPanel18: TSigPanel;
    SigPanel19: TSigPanel;
    SigGeneralGridFields: TSigGeneralGrid;
    SigGridEditorFieldID: TSigGridEditor;
    SigGridEditorFieldName: TSigGridEditor;
    SigGridEditorFieldType: TSigGridEditor;
    SigGridEditorCompareStyle: TSigGridEditor;
    SpeedButtonAddField: TSpeedButton;
    Label5: TLabel;
    MemoAdditionalPrivateMembers: TMemo;
    Label6: TLabel;
    MemoAdditionalPublicMembers: TMemo;
    SigPanel20: TSigPanel;
    SigPanel21: TSigPanel;
    SigPanel22: TSigPanel;
    SpeedButtonAddIndexFile: TSpeedButton;
    TabControlIndexFiles: TTabControl;
    SigGridEditorIndexField: TSigGridEditor;
    SigGridEditorOrder: TSigGridEditor;
    SigGridEditorIndexCompare: TSigGridEditor;
    SigGridEditorIndexSeq: TSigGridEditor;
    PageControlIndexes: TPageControl;
    TabSheetIndexFields: TTabSheet;
    SigPanel23: TSigPanel;
    Label7: TLabel;
    Label8: TLabel;
    EditIndexExtension: TEdit;
    SigGeneralGridIndexes: TSigGeneralGrid;
    SigSpinEditIndexCount: TSigSpinEdit;
    TabSheetIndexFind: TTabSheet;
    SigPanel24: TSigPanel;
    SigGeneralGridFind: TSigGeneralGrid;
    SigGridEditorFindParm1: TSigGridEditor;
    SpeedButtonAddFindFunction: TSpeedButton;
    CheckBoxMirrorDataFields: TCheckBox;
    SigGridEditorFieldComment: TSigGridEditor;
    TabControlPasSources: TTabControl;
    SigPanel25: TSigPanel;
    SigPanel16: TSigPanel;
    MemoPasSource: TMemo;
    SigPanel15: TSigPanel;
    SpeedButtonSaveSource: TSpeedButton;
    CheckBoxInterceptBaseFile: TCheckBox;
    CheckBoxInterceptIndexFile: TCheckBox;
    SpeedButtonSaveAllSources: TSpeedButton;
    TabSheetEncryption: TTabSheet;
    SigPanel26: TSigPanel;
    TabControlEncryption: TTabControl;
    SigPanel27: TSigPanel;
    CheckListBoxEncryptionMethods: TCheckListBox;
    Label13: TLabel;
    ImageListChecked: TImageList;
    SpeedButtonDeleteFile: TSpeedButton;
    SpeedButtonDeleteSelectedField: TSpeedButton;
    SpeedButtonDeleteIndexFile: TSpeedButton;
    SigGridEditorKeyCount: TSigGridEditor;
    SigGridEditorMatchCount: TSigGridEditor;
    Label14: TLabel;
    TabSheetTreeView: TTabSheet;
    SigPanel28: TSigPanel;
    SigPanel29: TSigPanel;
    SigPanel30: TSigPanel;
    SigPanel31: TSigPanel;
    SigPanel32: TSigPanel;
    SigPanel33: TSigPanel;
    TreeViewDatabase: TTreeView;
    PageControlProperties: TPageControl;
    TabSheetDatabaseProperties: TTabSheet;
    SigPanelDatabaseProperties: TSigPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label11: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    EditFileUnitName: TEdit;
    MemoAdditionalTypes: TMemo;
    BitBtnFileBrowse: TBitBtn;
    EditDatabaseUnitName: TEdit;
    BitBtnDatabaseBrowse: TBitBtn;
    EditInterceptUnitName: TEdit;
    BitBtnInterceptBrowse: TBitBtn;
    EditFileListUnitName: TEdit;
    BitBtnFileListBrowse: TBitBtn;
    Label9: TLabel;
    EditDBBaseName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButtonUndoClick(Sender: TObject);
    procedure SpeedButtonRedoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonPrintClick(Sender: TObject);
    procedure SpeedButtonPrintPreviewClick(Sender: TObject);
    procedure SpeedButtonPrintSetupClick(Sender: TObject);
    procedure SpeedButtonNewClick(Sender: TObject);
    procedure SpeedButtonOpenClick(Sender: TObject);
    procedure SpeedButtonSaveClick(Sender: TObject);
    procedure SpeedButtonSaveAsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButtonBuildSourceClick(Sender: TObject);
    procedure BitBtnFileBrowseClick(Sender: TObject);
    procedure SpeedButtonSaveSourceClick(Sender: TObject);
    procedure BitBtnDatabaseBrowseClick(Sender: TObject);
    procedure EditFileUnitNameChange(Sender: TObject);
    procedure EditDatabaseUnitNameChange(Sender: TObject);
    procedure BitBtnInterceptBrowseClick(Sender: TObject);
    procedure BitBtnFileListBrowseClick(Sender: TObject);
    procedure EditInterceptUnitNameChange(Sender: TObject);
    procedure EditFileListUnitNameChange(Sender: TObject);
    procedure PageControlMainChange(Sender: TObject);
    procedure SpeedButtonSaveAllSourcesClick(Sender: TObject);
    procedure SpeedButtonDeleteFileClick(Sender: TObject);
  private
    { Private declarations }
    fUndoRedo : tUndoRedo;
    {!MyFile = tMyFile}
    fSigFile: tSigDBBFile;
    fUsesPrinter: boolean;
    fPageCount: integer;
    fPageNo: integer;
    fSaveFont: tFont;
    fCalculatingPageCount: boolean;
    fFooterTop: integer;
    fPrintPos: integer;
    fFooterFont: tFont;
    fUndoRedoNavigationHelper: tSigFilePgmStatus;
    fLoadButton : tBitBtn;
    fTreeViewHelper : TDBTreeViewHelper;
    procedure OnRedoableChange(const pObject: tSigBaseProperty;
      const pUndoAction: tSigFileUndoAction; const pUndoString: string);
    procedure OnRedoChange(NewVal: boolean);
    procedure OnUndoableChange(const pObject: tSigBaseProperty;
      const pUndoAction: tSigFileUndoAction; const pUndoString: string);
    procedure OnUndoChange(NewVal: boolean);
    procedure SetPageNo(const Value: integer);
    procedure OnNew( Sender : tObject );
    procedure OnLoad(Sender : tObject; var pOK : boolean; const pFileName : string );
    function  HijackLoad( const pFileName : string; var pIncludeInHistory : boolean ) : boolean; // returns true if hijacked
    procedure BuildDBTree;
  public
    { Public declarations }
    property UndoRedo : tUndoRedo
             read fUndoRedo;
    property UndoRedoNavigationHelper : tSigFilePgmStatus
             read fUndoRedoNavigationHelper;
    property SigFile : tSigDBBFile
             read fSigFile;
    property UsesPrinter : boolean
             read fUsesPrinter
             write fUsesPrinter;
    property CurrPageNo : integer
             read fPageNo
             write SetPageNo;
    property PageCount : integer
             read fPageCount
             write fPageCount;
    property SaveFont : tFont
             read fSaveFont;
    property FooterFont : tFont
             read fFooterFont;
    property CalculatingPageCount : boolean
             read fCalculatingPageCount
             write fCalculatingPageCount;
    property FooterTop : integer
             read fFooterTop
             write fFooterTop;
    property PrintPos : integer
             read fPrintPos
             write fPrintPos;

    procedure PrintCalculatePages;
    procedure PrintPrintPages;
    procedure PrintPages;
    procedure PrintSetup;
    procedure PrintSetupFooter;
    procedure PrintPreparePages;
    procedure PrintHeader;
    procedure PrintFooter;

    function Translate( const pVal : string ) : string; // currently does nothing but prepares for multilingual

    procedure BuildSources;
    procedure BuildDatabaseSources;
    procedure BuildPASSource;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.BitBtnInterceptBrowseClick(Sender: TObject);
begin
  fLoadButton := BitBtnInterceptBrowse;
  fSigFile.Load( '', 2 );
end;

procedure TFormMain.BitBtnFileListBrowseClick(Sender: TObject);
begin
  fLoadButton := BitBtnFileListBrowse;
  fSigFile.Load( '', 2 );
end;

procedure TFormMain.BitBtnDatabaseBrowseClick(Sender: TObject);
begin
  fLoadButton := BitBtnDatabaseBrowse;
  fSigFile.Load( '', 2 );
end;

procedure TFormMain.BitBtnFileBrowseClick(Sender: TObject);
begin
  fLoadButton := BitBtnFileBrowse;
  fSigFile.Load( '', 2 );
end;

procedure TFormMain.BuildDatabaseSources;
begin
  BuildPASSource;
  fSigFile.ShowPasSource;
end;

procedure TFormMain.BuildDBTree;
begin
  fTreeViewHelper.BuildTreeView;
end;

procedure TFormMain.BuildPASSource;
begin
  fSigFile.BuildFileSource( MemoFilesSource.Lines );
end;

procedure TFormMain.BuildSources;
begin
  BuildPASSource;
end;

procedure TFormMain.EditDatabaseUnitNameChange(Sender: TObject);
begin
  fSigFile.PasDatabaseName.Value := EditDatabaseUnitName.Text;
end;

procedure TFormMain.EditFileListUnitNameChange(Sender: TObject);
begin
  fSigFile.PasFileListName.Value := EditFileListUnitName.Text;
end;

procedure TFormMain.EditFileUnitNameChange(Sender: TObject);
begin
  fSigFile.PasFileName.Value := EditFileUnitName.Text;
end;

procedure TFormMain.EditInterceptUnitNameChange(Sender: TObject);
begin
  fSigFile.PasInterceptName.Value := EditInterceptUnitName.Text;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	{ Only allow the form to close if there is no modified information }
  if fSigFile.IsDirty then
  begin
    CanClose := SigSaveDialogMain.SaveIfDirty;
  end;
  if CanClose then
  begin
    SigRegistry.StoreMainWindowParms;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  fUndoRedo := tUndoRedo.Create;
  {
    here you create your descendant of tSigFileProperty
  }
  fSigFile := tSigDBBFile.Create( 'tMyFile', nil );
  fSigFile.OnNew := OnNew;
  fSigFile.OnLoad := OnLoad;
  fSigFile.HijackLoad := HijackLoad;

  fUndoRedo.OnUndoChange := self.OnUndoChange;
  fUndoRedo.OnRedoChange := self.OnRedoChange;

  // change the SigRegistry to current application unless set manually
  if SigRegistry.Key = '' then
  begin
    SigRegistry.Key := ExtractFileName( Application.ExeName );
  end;

  {
    Additional start up actions
  }
  fTreeViewHelper := TDBTreeviewHelper.Create;
  fTreeViewHelper.TreeView := TreeViewDatabase;
  fTreeViewHelper.SigFile := fSigFile;
  fTreeViewHelper.PageControlProperties := self.PageControlProperties;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  fTreeViewHelper.Free;
  fUndoRedo.Free;
  fSigFile.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin

  PageControlMain.ActivePage := TabSheetTreeView;
  {
    Remove the following line if you don't want SigRegistry to remember widows last status
  }
  SigRegistry.RestoreMainWindowParms;

  {
    here you set up your file interactions
  }
  fSigFile.Editor := self;
  fSigFile.SaveDialog := SigSaveDialogMain;
  fSigFile.AboutForm := AboutBox;
  fSigFile.MainMenu := MainMenu;
  // set up Undo/Redo
  fSigFile.OnPrepareUndoableAction := fUndoRedo.PrepareUndoableActionTag;
  fSigFile.OnUndoableAction := self.OnUndoableChange;
  fSigFile.OnCompleteUndoableAction := fUndoRedo.CompleteUndoableActionTag;
  fSigFile.OnRedoableAction := self.OnRedoableChange;
  fSigFile.OnUndoClick := self.SpeedButtonUndoClick;
  fSigFile.OnRedoClick := self.SpeedButtonRedoClick;
  fSigFile.UndoRedoImageList := self.ImageListUndoRedo;
  {
    if you use the printer set UsesPrinter to TRUE, else set it to FALSE
  }
  UsesPrinter := TRUE; // or false
  {
    you can fine tune printer usage here
  }
  if UsesPrinter then
  begin
    fSigFile.OnPrint := SpeedButtonPrintClick;
    fSigFile.OnPrintPreview := SpeedButtonPrintPreviewClick;
    fSigFile.OnPrinterSetup := SpeedButtonPrintSetupClick;
  end
  else
  begin
    SpeedButtonPrint.Visible := FALSE;
    SpeedButtonPrintPreview.Visible := FALSE;
    SpeedButtonPrintSetup.Visible := FALSE;
  end;
  {
    Here we add the temporary navigation objects to the file
  }
  fUndoRedoNavigationHelper := tSigFilePgmStatus.Create( 'Navigation Helper', fSigFile );
  fUndoRedoNavigationHelper.RegisterObject( self );
  {
    here you assign any editors to your SigFileFields
  }

  fSigFile.FilesListEditor := TabControlFiles;
  fSigFile.AddFileButton := SpeedButtonNewFile;
  fSigFile.BaseFileNameEditor := EditFileBaseName;
  fSigFile.AdditionTypes.Editor := MemoAdditionalTypes;
  fSigFile.FileAdditionalTypesEditor := MemoFileAdditionalTypes;
  fSigFile.FieldsEditor := SigGeneralGridFields;
  fSigFile.AddFieldButton := SpeedButtonAddField;
  fSigFile.DeleteFieldButton := SpeedButtonDeleteSelectedField;
  fSigFile.FileAdditionalPrivateMembersEditor := MemoAdditionalPrivateMembers;
  fSigFile.FileAdditionalPublicMembersEditor := MemoAdditionalPublicMembers;
  fSigFile.TabControlIndexFiles := TabControlIndexFiles;
  fSigFile.SpeedButtonAddIndexFile := SpeedButtonAddIndexFile;
  fSigFile.SpeedButtonDeleteIndexFile := SpeedButtonDeleteIndexFile;
  fSigFile.EditIndexExtension := EditIndexExtension;
  fSigFile.SigSpinEditIndexCount := SigSpinEditIndexCount;
  fSigFile.SigGeneralGridIndexes := SigGeneralGridIndexes;
  fSigFile.DBBaseNameEditor := EditDBBaseName;
  fSigFile.SigGeneralGridFind := SigGeneralGridFind;
  fSigFile.SpeedButtonAddFindFunction := SpeedButtonAddFindFunction;
  fSigFile.CheckBoxMirrorDataFields := CheckBoxMirrorDataFields;
  fSigFile.CheckBoxAddDataIntercept := CheckBoxInterceptBaseFile;
  fSigFile.CheckBoxAddIndexIntercept := CheckBoxInterceptIndexFile;
  fSigFile.TabControlPasSources := TabControlPasSources;
  fSigFile.MemoPasSource := MemoPasSource;

  fSigFile.IsDirty := FALSE;
  // if parameter is passed, load it, otherwise create New file
  if ParamCount = 0 then
  begin
    fSigFile.New;
  end
  else if ParamStr( 1 ) = '-last' then
  begin
    fSigFile.Load( SigRegistry.History[ 0 ] );
  end
  else
  begin
    fSigFile.Load( ParamStr( 1 ) );
  end;
  fUndoRedo.Clear;


end;

function TFormMain.HijackLoad(const pFileName: string;
  var pIncludeInHistory: boolean): boolean;
begin
  if SameText( ExtractFileExt( pFileName ), '.pas' )  then
  begin
    pIncludeInHistory := FALSE;
    {
    EditPASName.Text := pFileName;
    fSigFile.PasFileName.Value := pFileName;
    if FileExists( pFileName ) then
    begin
      MemoPas.Lines.LoadFromFile( pFileName );
    end;
    }
    if fLoadButton = BitBtnFileBrowse then
    begin
      EditFileUnitName.Text := pFileName;
      fSigFile.PasFileName.Value := pFileName;
      fSigFile.BuildFileName;
    end
    else if fLoadButton = BitBtnInterceptBrowse then
    begin
      EditInterceptUnitName.Text := pFileName;
      fSigFile.PasInterceptName.Value := pFileName;
    end
    else if fLoadButton = BitBtnFileListBrowse then
    begin
      EditFileListUnitName.Text := pFileName;
      fSigFile.PasFileListName.Value := pFileName;
    end
    else if fLoadButton = BitBtnDatabaseBrowse then
    begin
      EditDatabaseUnitName.Text := pFileName;
      fSigFile.PasDatabaseName.Value := pFileName;
    end;

    fSigfile.ShowPasSource;

    fLoadButton := nil;

    Result := TRUE;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TFormMain.SetPageNo(const Value: integer);
begin
  fPageNo := Value;
  if fPageNo > fPageCount then
  begin
    fPageCount := fPageNo;
  end;
end;

procedure TFormMain.SpeedButtonBuildSourceClick(Sender: TObject);
begin
  fSigFile.BuildFileSource( MemoFilesSource.Lines );
end;

procedure TFormMain.SpeedButtonDeleteFileClick(Sender: TObject);
begin
  case MessageDlg( 'This will delete the file and all indexes for it. Are you sure?', mtWarning,
                   [mbYes, mbCancel], 0) of
    mrYes:
    begin
      with fSigFile.DataBase.Files do
      begin
        if ActiveChild > 0 then
        begin
          Delete( ActiveChild, undoDelete2 );
        end;
      end;
    end;
  end;
end;

procedure TFormMain.SpeedButtonNewClick(Sender: TObject);
begin
  fSigFile.New(); // can add short format if desired
  fSigFile.BuildFileName;
  EditFileUnitName.Text := fSigFile.PasFileName.Value;
  EditInterceptUnitName.Text := fSigFile.PasInterceptName.Value;
  EditFileListUnitName.Text := fSigFile.PasFileListName.Value;
  EditDatabaseUnitName.Text := fSigFile.PasDatabaseName.Value;
  fSigFile.RefreshEditors;
  //BuildSources;
end;

procedure TFormMain.SpeedButtonOpenClick(Sender: TObject);
begin
  fSigFile.Load();
end;

procedure TFormMain.SpeedButtonPrintClick(Sender: TObject);
begin
  with PreviewPrinterMain do
  begin
    BeginDoc;
    with self.PrintDialog do
    begin
      {
        setup min, max pages etc here
      }
      PrintCalculatePages;
      MinPage := 1;
      MaxPage := PageCount;
      if Execute then
      begin
        PrintPages;
        EndDoc;
        Print;
      end
      else
      begin
        Abort;
      end;
    end;
  end;
end;

procedure TFormMain.SpeedButtonPrintPreviewClick(Sender: TObject);
begin
    with PreviewPrinterMain do
    begin
      BeginDoc;
      PrintPages;
      EndDoc;
      Preview;
    end;
end;

procedure TFormMain.SpeedButtonPrintSetupClick(Sender: TObject);
begin
  PrinterSetupDialog.Execute();
end;

procedure TFormMain.SpeedButtonRedoClick(Sender: TObject);
begin
  { Tag := }UndoRedo.Redo;
  { The tag returns eg the page you should be on after the redo is appliied }
end;

procedure TFormMain.SpeedButtonSaveAllSourcesClick(Sender: TObject);
var
  iStrings : TStringList;
begin
  iStrings := TStringList.Create;
  try
    with fSigFile do
    begin
      BuildRawSource( iStrings );
      iStrings.SaveToFile( fSigfile.PasFileName.Value );

      UpdateInterceptSource( iStrings );
      iStrings.SaveToFile( fSigfile.PasInterceptName.Value );

      BuildFileListsSource( iStrings );
      iStrings.SaveToFile( fSigfile.PasFileListName.Value );

      UpdateDBSource( iStrings );
      iStrings.SaveToFile( fSigfile.PasDatabaseName.Value );

    end;
  finally
    iStrings.Free;
    MessageDlg( 'Sources Saved.', mtInformation, [mbOK], 0 );
  end;
end;

procedure TFormMain.SpeedButtonSaveAsClick(Sender: TObject);
begin
  fSigFile.SaveAs();
end;

procedure TFormMain.SpeedButtonSaveClick(Sender: TObject);
begin
  fSigFile.Save(); // can add shortform if desired
end;

procedure TFormMain.SpeedButtonSaveSourceClick(Sender: TObject);
begin
  fSigFile.SaveSource;
end;

procedure TFormMain.SpeedButtonUndoClick(Sender: TObject);
begin
  { Tag := }UndoRedo.Undo;
  { The tag returns eg the page you should be on after the undo is applied }
end;

function TFormMain.Translate(const pVal: string): string;
begin
  Result := pVal;
end;

procedure TFormMain.OnLoad(Sender: tObject; var pOK: boolean;
  const pFileName: string);
begin
  if SameText( ExtractFileExt( pFileName ), '.dbb' )  then
  begin
    fSigFile.BuildFileName;
    EditFileUnitName.Text := fSigFile.PasFileName.Value;
    EditInterceptUnitName.Text := fSigFile.PasInterceptName.Value;
    EditFileListUnitName.Text := fSigFile.PasFileListName.Value;
    EditDatabaseUnitName.Text := fSigFile.PasDatabaseName.Value;
    fSigFile.RefreshEditors;
    BuildSources;
    fTreeViewHelper.BuildTreeView;
  end;
end;

procedure TFormMain.OnNew(Sender: tObject);
begin
end;

procedure TFormMain.OnRedoableChange(const pObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  fUndoRedo.RedoableAction( pObject, pUndoAction, pUndoString );
end;

procedure TFormMain.OnRedoChange(NewVal: boolean);
begin
  SpeedButtonRedo.Enabled := NewVal;
end;

procedure TFormMain.OnUndoableChange(const pObject: tSigBaseProperty;
  const pUndoAction: tSigFileUndoAction; const pUndoString: string);
begin
  {
    Here you do special undo redo actions. You can set UndoRedo.Tag
    separately, e.g. when page changes, or use the value directly here
  }
  case pUndoAction of
    undoClearUndoList:
    begin
      fUndoRedo.Clear;
    end;
    else
    begin
      fUndoRedo.UndoableAction( fUndoRedo.Tag, pObject, pUndoAction, pUndoString );
    end;
  end;
end;

procedure TFormMain.OnUndoChange(NewVal: boolean);
begin
  SpeedButtonUndo.Enabled := NewVal;
end;


procedure TFormMain.PageControlMainChange(Sender: TObject);
begin
  if PageControlMain.ActivePage = TabSheetTreeView then
  begin
    BuildDBTree;
  end
  else
  begin
    TabControlPasSources.OnChange( Sender );
  end;
end;

procedure TFormMain.PrintCalculatePages;
begin
  PageCount := 0;
  CurrPageNo := 0;
  PrintSetup;
  CalculatingPageCount := TRUE;
  PrintPreparePages;
end;

procedure TFormMain.PrintFooter;
var
  ileft : integer;
  iFooterText : string;
begin
  {
    Always print the footer first if a new page is required, then print
    the header if required. This is to make sure that PrintPos is set to
    the right value.
  }
  CurrPageNo := CurrPageNo + 1;
  if not CalculatingPageCount then
  begin
    if PageCount <> 1 then
    begin
      PreviewPrinterMain.NewPage;
    end;
    with PreviewPrinterMain.Canvas do
    begin
      SaveFont.Assign( Font );
      Font.Assign( FooterFont );
      iFooterText := 'Page ' + IntToStr( CurrPageNo ) + ' of ' + IntToStr( PageCount );
      PrintPos := FooterTop + TextHeight( iFooterText );
      iLeft := (PreviewPrinterMain.PageWidth - TextWidth( iFooterText )) div 2;
      TextOut( iLeft, PrintPos, iFooterText );
      Font.Assign( SaveFont );
    end;
  end;

  PrintPos := PreviewPrinterMain.OffsetY;

end;

procedure TFormMain.PrintHeader;
begin
  {
    Print your header here.
  }
end;

procedure TFormMain.PrintPages;
begin
  PrintCalculatePages;
  PrintPrintPages;
end;

procedure TFormMain.PrintPreparePages;
begin
  {
    Do your print actions here

    This routine will be called twice - once to calculate pages
    and once to actually print. If CalculatingPageCount is true
    you should not write anything to the canvas og PreviewPrinterMain
    but you should control VPos as if it were.
  }
end;

procedure TFormMain.PrintPrintPages;
begin
  PageCount := 0;
  CalculatingPageCount := FALSE;
  PrintPreparePages;
end;

procedure TFormMain.PrintSetup;
begin
  if not assigned( SaveFont ) then
  begin
    fSaveFont := TFont.Create;
  end;
  SaveFont.Assign( PreviewPrinterMain.Canvas.Font );
  {
    here you set up any required fonts etc. if they have not already
    been set up. FooterFont is used as a font to print the footer.
    It sets the printer font to its default, then sets its style to bold.
    This also shows how to set fonts up.
  }
  if not assigned( FooterFont ) then
  begin
    fFooterFont := TFont.Create;
    FooterFont.Assign( PreviewPrinterMain.Canvas.Font );
    FooterFont.Style := [fsBold];
  end;

  PrintSetupFooter;
end;

procedure TFormMain.PrintSetupFooter;
begin
  {
    This is a default footer. You may want to change its settings
  }
  FooterTop := PreviewPrinterMain.PrintableHeight + PreviewPrinterMain.OffsetY
               - 3 * PreviewPrinterMain.Canvas.TextHeight( 'XX' );

end;

end.
