unit UnitShortNameAndIconEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, UnitFrameIconEditor,
  UnitPCCfgFile;

type
  tOnGetExpandedShortText = function ( const pVal : string ) : string of object;
  TFormShortNameAndIconEditor = class(TForm)
    Panel1: TPanel;
    LabelSubDeviceIcon: TLabel;
    ImageSubDevice: TImage;
    EditSubunitBriefText: TEdit;
    Label43: TLabel;
    Panel2: TPanel;
    LabelDeviceType: TLabel;
    EditSubDeviceType: TEdit;
    Panel3: TPanel;
    Panel4: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditFullBriefText: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    FrameIconEditor1: TFrameIconEditor;
    procedure FormCreate(Sender: TObject);
    procedure EditFullBriefTextChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FrameIconEditor1BitBtnLoadNewClick(Sender: TObject);
  private
    fOnGetExpandedShortText: tOnGetExpandedShortText;
    fBriefText: string;
    function GetDeviceType: string;
    procedure SetDeviceType(const Value: string);
    procedure SetBriefText(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;

    property OnGetExpandedShortText : tOnGetExpandedShortText
             read fOnGetExpandedShortText
             write fOnGetExpandedShortText;
    property DeviceType : string
             read GetDeviceType
             write SetDeviceType;
    property BriefText : string
             read fBriefText
             write SetBriefText;
  end;

var
  FormShortNameAndIconEditor: TFormShortNameAndIconEditor;

implementation

{$R *.dfm}

{ TFormShortNameAndIconEditor }

procedure TFormShortNameAndIconEditor.EditFullBriefTextChange(Sender: TObject);
begin
  BriefText := EditFullBriefText.Text;
end;

function TFormShortNameAndIconEditor.Execute: boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TFormShortNameAndIconEditor.FormCreate(Sender: TObject);
begin
  EditSubunitBriefText.Text := '';
  EditSubDeviceType.Text := '';
  EditFullBriefText.Text := '';
  fBriefText := '';
end;

procedure TFormShortNameAndIconEditor.FormShow(Sender: TObject);
begin
  FrameIconEditor1.AllText := UnitPCCfgFile.XFP4PgmCfg.Translate( '<All>' );
end;

procedure TFormShortNameAndIconEditor.FrameIconEditor1BitBtnLoadNewClick(
  Sender: TObject);
begin
  FrameIconEditor1.BitBtnLoadNewClick(Sender);

end;

function TFormShortNameAndIconEditor.GetDeviceType: string;
begin
  Result := EditSubDeviceType.Text;
end;

procedure TFormShortNameAndIconEditor.SetBriefText(const Value: string);
begin
  fBriefText := Value;
  if EditSubunitBriefText.Text <> Value then
  begin
    EditSubunitBriefText.Text := Value;
  end;
  if assigned( OnGetExpandedShortText ) then
  begin
    EditSubunitBriefText.Text := OnGetExpandedShortText( Value );
  end;
end;

procedure TFormShortNameAndIconEditor.SetDeviceType(const Value: string);
begin
  EditSubDeviceType.Text := Value;
end;

end.
