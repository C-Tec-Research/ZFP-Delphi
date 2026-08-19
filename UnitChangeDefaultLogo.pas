unit UnitChangeDefaultLogo;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtDlgs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  VCL.Imaging.GIFImg;

type
  TFormChangeDefaultLogo = class(TForm)
    GroupBoxLogo: TGroupBox;
    ImageLogo: TImage;
    OpenPictureDialogLogo: TOpenPictureDialog;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Memo2: TMemo;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    procedure ImageLogoClick(Sender: TObject);
  private
    fFileName: string;
    fOversized: boolean;
    { Private declarations }
  public
    { Public declarations }
    property FileName : string
             read fFileName;
    function Execute : boolean;
    property Oversized : boolean
             read fOversized;
  end;

var
  FormChangeDefaultLogo: TFormChangeDefaultLogo;

implementation

{$R *.dfm}

{ TFormChangeDefaultLogo }

function TFormChangeDefaultLogo.Execute: boolean;
begin
  fFileName := '';
  if FileExists( 'Images\Logo.gif' ) then
  begin
    ImageLogo.Picture.LoadFromFile( 'Images\Logo.gif' );
  end
  else
  begin
    ImageLogo.Picture := nil;
  end;
  BitBtnOK.Enabled := FALSE;
  Result := ShowModal = mrOK;
end;

procedure TFormChangeDefaultLogo.ImageLogoClick(Sender: TObject);
var
  iLogo : string;
  iFile : file of byte;
begin
  with OpenPictureDialogLogo do
  begin
    iLogo := 'Images\Logo.gif';
    FileName := ExtractFileName( iLogo );
    if Execute then
    begin
      fFileName := FileName;
      if SameText( ExtractFileExt( FileName ), '.gif' )  then
      begin
        try
          ImageLogo.Picture.LoadFromFile( fFileName );
        except

        end;
        if assigned( ImageLogo.Picture ) then
        begin
          if (ImageLogo.Picture.Width > 150) or (ImageLogo.Picture.Height > 150) then
          begin
            fOversized := TRUE;
            raise Exception.Create('Error - Logo exceeds specified dimensions of 150 x 150 pixels and will not be sent to panels');
          end
          else
          begin
            AssignFile( iFile, fFileName );
            Reset( iFile );
            try
              if FileSize( iFile ) > 8192 then
              begin
                fOversized := TRUE;
                raise Exception.Create('Error - Logo exceeds maximum file size of 8192 bytes and will not be sent to panels');
              end;
            finally
              CloseFile( iFile );
            end;
            fOversized := FALSE;
            BitBtnOK.Enabled := TRUE;
          end;
        end;
      end
      else
      begin
        raise Exception.Create('Error - Must be GIF file');
      end;
    end;
  end;
end;

end.
