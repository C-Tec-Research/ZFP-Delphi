unit UnitEditArea;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ExtDlgs, StdCtrls;

type
  tSigFormType = (ftNormal, ftFloat ); // main form or daughter form used

type
  TFormEditArea = class(TForm)
    EditAreaName: TEdit;
    LabelAreaName: TLabel;
    RadioGroupStyle: TRadioGroup;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    OpenPictureDialogPicture: TOpenPictureDialog;
    LabelPicture: TLabel;
    SpeedButtonBrowse: TSpeedButton;
    EditFileName: TEdit;
    Panel1: TPanel;
    ImagePreview: TImage;
    procedure RadioGroupStyleClick(Sender: TObject);
    procedure EditAreaNameChange(Sender: TObject);
  private
    fPictureFile: string;
    fFormType: tSigFormType;
    fSigName: string;
    procedure SetPictureFile(const Value: string);
    procedure SetFormType(const Value: tSigFormType);
    procedure SetSigName(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    property PictureFile : string
             read fPictureFile
             write SetPictureFile;
    function Execute : boolean;
    procedure LoadPicture;
    property FormType : tSigFormType
             read fFormType
             write SetFormType;
    property AreaName : string
             read fSigName
             write SetSigName;
  end;

var
  FormEditArea: TFormEditArea;

implementation

{$R *.dfm}

{ TFormEditArea }

procedure TFormEditArea.EditAreaNameChange(Sender: TObject);
begin
  if fSigName <> EditAreaName.Text then
  begin
    fSigName := EditAreaName.Text;
  end;
end;

function TFormEditArea.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormEditArea.LoadPicture;
begin
  with OpenPictureDialogPicture do
  begin
    if Execute then
    begin
      PictureFile := FileName;
    end;
  end;
end;

procedure TFormEditArea.RadioGroupStyleClick(Sender: TObject);
begin
  case RadioGroupStyle.ItemIndex of
    0:
    begin
      if fFormType <> ftNormal then
      begin
        fFormType := ftNormal;
      end;
    end;
    1:
    begin
      if fFormType <> ftFloat then
      begin
        fFormType := ftFloat;
      end;
    end;
  end;
end;

procedure TFormEditArea.SetFormType(const Value: tSigFormType);
begin
  fFormType := Value;
  case Value of
    ftNormal:
    begin
      RadioGroupStyle.ItemIndex := 0;
    end;
    ftFloat:
    begin
      RadioGroupStyle.ItemIndex := 1;
    end;
  end;
end;

procedure TFormEditArea.SetPictureFile(const Value: string);
begin
  fPictureFile := Value;
  EditFileName.Text := ExtractFileName( Value );
  OpenPictureDialogPicture.InitialDir := ExtractFilePath( Value );
  OpenPictureDialogPicture.FileName := ExtractFileName( Value );
  try
    ImagePreview.Picture.LoadFromFile( Value );
  except
    ImagePreview.Picture := nil;
  end;
end;

procedure TFormEditArea.SetSigName(const Value: string);
begin
  fSigName := Value;
  EditAreaName.Text := Value;
end;

end.
