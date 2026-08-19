unit UnitFileTransfer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, SigSaveDialog,
  Vcl.ExtCtrls;

type
  TFormFileTransfer = class(TForm)
    SigSaveDialogTransfer: TSigSaveDialog;
    GroupBoxFileNameOnPC: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditFileNameOnPC: TEdit;
    SpeedButtonBrowse: TSpeedButton;
    RadioGroupFileNameOnPanel: TRadioGroup;
    procedure EditFileNameOnPCChange(Sender: TObject);
    procedure SpeedButtonBrowseClick(Sender: TObject);
  private
    fInitialFile: string;
    function GetPanelFileName: string;
    function GetPCFileName: string;
    { Private declarations }
  public
    { Public declarations }
    function Execute( const pCaption : string ) : boolean;
    property InitialFile : string
             read fInitialFile
             write fInitialFile;
    procedure BuildDestChoices;
    property PCFileName : string
             read GetPCFileName;
    property PanelFileName : string
             read GetPanelFileName;
  end;

var
  FormFileTransfer: TFormFileTransfer;

implementation

{$R *.dfm}

{ TFormFileTransfer }

procedure TFormFileTransfer.BuildDestChoices;
var
  SaveIndex : integer;
  iFileName : string;
  iPathName : string;
  iParentFolder : string;
begin
  SaveIndex := RadioGroupFileNameOnPanel.ItemIndex;
  with RadioGroupFileNameOnPanel.Items do
  begin
    Clear;
    iFileName := ExtractFileName( fInitialFile );
    iPathName := ExtractFileDir( fInitialFile );
    iParentFolder := ExtractFileName(iPathName );
    if iFileName <> '' then
    begin
      Add( iFileName );
      if iParentFolder <> '' then
      begin
        Add( iParentFolder + '\' + iFileName );
      end;
    end;
    if (SaveIndex >= Count) or (SaveIndex < 0) then
    begin
      RadioGroupFileNameOnPanel.ItemIndex := 0;
    end
    else
    begin
      RadioGroupFileNameOnPanel.ItemIndex := SaveIndex;
    end;
  end;

end;

procedure TFormFileTransfer.EditFileNameOnPCChange(Sender: TObject);
begin
  fInitialFile := EditFileNameOnPC.Text;
  BuildDestChoices;
end;

function TFormFileTransfer.Execute( const pCaption : string ) : boolean;
begin
  Caption := pCaption;
  EditFileNameOnPC.Text := fInitialFile;
  //BuildDestChoices;
  Result := ShowModal = mrOK;
end;

function TFormFileTransfer.GetPanelFileName: string;
begin
  if RadioGroupFileNameOnPanel.ItemIndex < 0 then
  begin
    Result := '';
  end
  else
  begin
    Result := RadioGroupFileNameOnPanel.Items[ RadioGroupFileNameOnPanel.ItemIndex ];
  end;
end;

function TFormFileTransfer.GetPCFileName: string;
begin
  Result := fInitialFile;
end;

procedure TFormFileTransfer.SpeedButtonBrowseClick(Sender: TObject);
begin
  SigSaveDialogTransfer.FileName := ExtractFileName( fInitialFile );
  SigSaveDialogTransfer.InitialDir := ExtractFileDir( fInitialFile );
  if SigSaveDialogTransfer.Execute then
  begin
    fInitialFile := SigSaveDialogTransfer.FileName;
    EditFileNameOnPC.Text := fInitialFile;
    //BuildDestChoices;
  end;
end;

end.
