unit NTAMenu;

interface

uses

  SysUtils, Classes, Menus, ToolsApi, Controls, ImgList, Graphics, Forms, ComCtrls, windows;


type
  TNTATest = class
  private
    FMainMenu: TMainMenu; // used to store the delphi IDE main menu
    NewMenu: TMenuItem; // we will have to insert the menu
    FImageList: TCustomImageList; // used to store delphi IDE main menu and toolbars of the ImageList
    ImageIndex1: integer; // detection volume, please see the code behind
    IDEHandle: HWND; // the handle storage IDE

  protected
    procedure AddMenu; // join our menu
    procedure RemoveMenu; // unload our menu
    procedure ReCodeEditer (sender: TObject); // menu item of the incident
    procedure AboutForm (sender: TObject); // menu item 2 events
  public
    constructor Create;
    destructor Destroy; override;
  end;


//procedure Register;

var
  MyNTATest: TNTATest;

implementation


{
procedure Register;
begin
  MyNTATest.AddMenu;
  // And traditional methods of different components of the same name, this is not installed in the components panel icon
  // Instead of direct method calls AddMenu add to our menu
end;
}

{TNTATest}

constructor TNTATest.Create;
begin
  inherited Create;
  IDEHandle := (BorlandIDEServices as IOTAServices). GetParentHandle;
  // We use IOTAServices interface methods GetParentHandle the handle has been ide
end;


procedure TNTATest.AddMenu;
var
  MenuItem: array [0 .. 2] of TMenuItem;
  i: integer;
  Icon1: TIcon; // menu item of the icon
begin
  FMainMenu := (BorlandIDEServices as INTAServices). MainMenu;
  // We use the MainMenu property INTAServices directly from the IDE's main menu

  FImageList := (BorlandIDEServices as INTAServices).ImageList;
  // We use the ImageList property INTAServices directly from the IDE image list

  NewMenu := TMenuItem.Create (FMainMenu);
  // Create our menu

  NewMenu.Caption := 'hk.barton';

  ImageIndex1 := - 1; // not loading icon

  // The following code to use for and the case to add two menu items a little fuss, but
  // We have demonstrated a more general approach allows you to add more menu items, rather than simply copy the code.

  for i := 0 to 2 do
  begin
    MenuItem [i] := TMenuItem.Create (NewMenu); // create sub-menu item

    case i of
      0:
      begin
        MenuItem [i].Caption := 'InsertText';
        Icon1 := TIcon.Create;
        try
          Icon1.LoadFromFile( 'D:\MyWorks\MyComponent\OTATest\NewForm.ico');
          // I have the file upload from the hard drive icon to a menu item as an icon
        except
          On E: Exception do
          begin
            raise Exception.Create (E. Message);
            exit;
          end;
        end;
        ImageIndex1 := FImageList.AddIcon (Icon1);
        // Join the loading icon and return to a ImageIndex
        MenuItem [i].ImageIndex := ImageIndex1;
        MenuItem [i].OnClick := ReCodeEditer; // Add event handler
      end;

      1: MenuItem [i].Caption := '-'; // Of course, there is a division of symbols, is menu item 3
      2:
      begin
        MenuItem [i].Caption := 'About';
        MenuItem [i].OnClick := AboutForm;
      end;
    end;
    NewMenu.Add(MenuItem [i]); // add menu items
  end;

  FMainMenu.Items.Add(NewMenu); // Finally, add to our menu IDE main menu

end;


procedure TNTATest.ReCodeEditer (sender: TObject);
var
  Module: IOTAModuleServices;
  CurentMoudle: IOTAModule;
  IntfEditor: IOTAEditor;
  Editor: IOTASourceEditor;
  EditView: IOTAEditView;
  EditWriterPos: IOTAEditPosition;
  i: integer;
begin

  Module := BorlandIDEServices as IOTAModuleServices;
  CurentMoudle := Module.CurrentModule;

  // Use the CurrentModule methods IOTAModuleServices open the current engineering module

  if CurentMoudle = nil then
  begin
    messagebox (IDEHandle, 'the current document does not open the item', 'hkTest', MB_ICONINFORMATION);
    exit;
  end;

  // Traverse the project has been open all of the documents

  for i := 0 to CurentMoudle.ModuleFileCount-1 do
  begin

    IntfEditor := CurentMoudle.ModuleFileEditors [i];
    // IOTAModule the ModuleFileEditors [] attributes a IOTAEditor

    if IntfEditor.QueryInterface (IOTASourceEditor, Editor) = S_OK then
    begin
      // Check whether the traversal of the document is a code file and have started editing the code editor.
      // If it is through an out parameter will be a realization of Editor example IOTASourceEditor
      break;
    end;
  end;

  if Editor = nil then
  begin
    messagebox (IDEHandle, 'At present there is no code editor window', 'hkTest', MB_ICONINFORMATION);
    exit;
  end;

  EditView := Editor.EditViews [i];
  // Use IOTASourceEditor the EditViews [] attributes a IOTAEditView
  EditWriterPos := EditView.Position;
  // Use the Position property IOTAEditView a final IOTAEditPosition
  EditWriterPos.InsertText ('{/// This is add by the OTATest of hk.barton, enjoy days! ///}');
  // IOTAEditPosition the InsertText method of the current cursor position to the insertion line of code, here is his note.

end;


procedure TNTATest.AboutForm (sender: TObject);
// On a simple dialog box, note the parameters of IDEHandle
begin
  messagebox (IDEHandle, 'This is a test of OTA write by hk.barton', 'hkTest', MB_ICONINFORMATION);
end;


procedure TNTATest.ReMoveMenu;
// Uninstall Menu
begin

  if assigned (NewMenu) then
  begin
    NewMenu.Free;
  end;

end;


destructor TNTATest.Destroy;
begin
  MyNTATest.ReMoveMenu;

  if ImageIndex1 <> -1 then
  begin
    // If the icon in front of the work load is not unusual to release the icon, otherwise they will be released into the use of the icon itself delphi
    MyNTATest.FImageList.Delete (MyNTATest.ImageIndex1);
  end;
  inherited;
end;


initialization

  // In the component installation first created TNTATest

  MyNTATest := TNTATest.Create;

finalization

  // Uninstall the components released by MyNTATest

  MyNTATest.Free;

end.


