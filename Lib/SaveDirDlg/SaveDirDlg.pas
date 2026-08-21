unit SaveDirDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl;

type
  TFormSaveDirDlg = class(TForm)
    DriveComboBox: TDriveComboBox;
    DirectoryListBox: TDirectoryListBox;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    EditDirName: TEdit;
    LabelDir: TLabel;
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    iNameSet : boolean;
    function fGetName: string;
    procedure fSetName( NewVal : string );
  public
    { Public declarations }
    function Execute : boolean;
    property DirName : string
             read fGetName
             write fSetName;
  end;

var
  FormSaveDirDlg: TFormSaveDirDlg;

implementation

{$R *.dfm}

{ TForm1 }

function TFormSaveDirDlg.Execute: boolean;
begin
  ShowModal;
  if ModalResult = mrOK then
  begin
    if DirectoryExists( EditDirName.Text ) then
    begin
      Result := TRUE;
    end
    else
    begin
      if MessageDlg( 'Directory does not exist. Create it?', mtConfirmation, [ mbOK, mbCancel ], 0 ) = mrOK then
      begin
        if ForceDirectories( EditDirName.Text ) then
        begin
          Result := TRUE;
        end
        else
        begin
          MessageDlg( 'Unable to create directory.', mtConfirmation, [ mbAbort ], 0 );
          Result := FALSE;
        end;
      end
      else
      begin
        Result := FALSE;
      end;
    end;
  end
  else
  begin
    Result := FALSE;
  end;
end;

procedure TFormSaveDirDlg.DirectoryListBoxChange(Sender: TObject);
begin
  EditDirName.Text := DirectoryListBox.Directory;
end;

procedure TFormSaveDirDlg.FormShow(Sender: TObject);
begin
  if not iNameSet then
  begin
    EditDirName.Text := DirectoryListBox.Directory;
  end
  else
  begin
    iNameSet := FALSE;
  end;
end;

function TFormSaveDirDlg.fGetName: string;
begin
  Result := EditDirName.Text;
end;

procedure TFormSaveDirDlg.fSetName(NewVal: string);
begin
  if NewVal = '' then
  begin
    EditDirName.Text := '';
    iNameSet := FALSE;
  end
  else
  begin
    if DirectoryExists( NewVal ) then
    begin
      DirectoryListBox.Directory := NewVal;
      iNameSet := FALSE;
    end
    else
    begin
      EditDirName.Text := NewVal;
      iNameSet := TRUE;
    end;
  end;
end;

end.
