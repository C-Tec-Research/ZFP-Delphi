unit UnitMovingImageButtonProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UNITBASICBUTTONPROPS, StdCtrls, Spin, Grids, SigNETStringGrid,
  ComCtrls;

type
  TFormMovingImageButtomProperties = class(TFormBasicButtonProps)
    TabControlImageTables: TTabControl;
    SigNETStringGridImages: TSigNETStringGrid;
    Label5: TLabel;
    SpinEditImageTop: TSpinEdit;
    Label6: TLabel;
    SpinEditImageLeft: TSpinEdit;
    Label7: TLabel;
    SpinEditImageHeight: TSpinEdit;
    Label8: TLabel;
    SpinEditImageWidth: TSpinEdit;
    Label4: TLabel;
    SpinEditMaxImages: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure SpinEditMaxImagesChange(Sender: TObject);
    procedure SpinEditImageHeightChange(Sender: TObject);
    procedure SpinEditImageWidthChange(Sender: TObject);
  protected
    { Private declarations }
    iStateCount : integer;
    procedure fSetStateCount( NewVal : integer );
    procedure fSetStateText( Index : integer; NewVal : string );
    procedure fSetImageHeight( NewVal : integer );
    function fGetImageHeight: integer;
  public
    { Public declarations }
    property StateCount : integer
             read iStateCount
             write fSetStateCount;
    property StateText[ index : integer ] :string
             write fSetStateText;
    property ImageHeight : integer
             read fGetImageHeight
             write fSetImageHeight;
  end;

var
  FormMovingImageButtomProperties: TFormMovingImageButtomProperties;

implementation

{$R *.dfm}

procedure TFormMovingImageButtomProperties.FormCreate(Sender: TObject);
begin
  inherited;
  SigNETStringGridImages.RowHeights[ 0 ] := 16;
end;

procedure TFormMovingImageButtomProperties.fSetStateCount( NewVal : integer );
begin
  iStateCount := NewVal;
  SigNETStringGridImages.RowCount := NewVal + 1;
end;

procedure TFormMovingImageButtomProperties.fSetStateText( Index : integer; NewVal : string );
begin
  SigNETStringGridImages.Cells[ 0, Index ] := NewVal;
end;

procedure TFormMovingImageButtomProperties.fSetImageHeight( NewVal : integer );
begin
  SpinEditHeight.Value := NewVal;
end;

function TFormMovingImageButtomProperties.fGetImageHeight: integer;
begin
  Result := SpinEditHeight.Value;
end;

procedure TFormMovingImageButtomProperties.SpinEditMaxImagesChange(
  Sender: TObject);
begin
  inherited;
  SigNETStringGridImages.ColCount := SpinEditMaxImages.Value;
end;

procedure TFormMovingImageButtomProperties.SpinEditImageHeightChange(
  Sender: TObject);
begin
  inherited;
  SigNETStringGridImages.DefaultRowHeight := SpinEditImageHeight.Value;
end;

procedure TFormMovingImageButtomProperties.SpinEditImageWidthChange(
  Sender: TObject);
begin
  inherited;
  SigNETStringGridImages.DefaultColWidth := SpinEditImageWidth.Value;
end;

end.
