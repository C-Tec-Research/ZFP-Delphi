unit UnitImageSelector;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, SigNETStringGrid, ImgList,
  SigImageList;

type
  TFormImageSelector = class(TForm)
    SigNETStringGridUserImages: TSigNETStringGrid;
    BitBtn1: TBitBtn;
    ImageListUserImages: TImageList;
    procedure SigNETStringGridUserImagesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SigNETStringGridUserImagesSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
  private
    fImageIndex: integer;
    procedure SetImageIndex(const Value: integer);
    { Private declarations }
  public
    { Public declarations }

    property ImageIndex : integer
             read fImageIndex
             write SetImageIndex;
    property ImageList : tSigImageList
             read fImageList
             write SetImageList;

    function Execute( var pSelection : integer ) : boolean;
  end;

var
  FormImageSelector: TFormImageSelector;

implementation

{$R *.dfm}

{ TForm1 }

{ TForm1 }

function TFormImageSelector.Execute(var pSelection : integer ): boolean;
begin
  ImageIndex := pSelection;
  Result := ShowModal = mrOK;
  if Result then
  begin
    pSelection := ImageIndex;
  end;
end;

procedure TFormImageSelector.SetImageIndex(const Value: integer);
begin
  fImageIndex := Value;
end;

procedure TFormImageSelector.SigNETStringGridUserImagesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iIndex : integer;
begin
  iIndex := (ARow * SigNETStringGridUserImages.ColCount) + ACol;
  with SigNETStringGridUserImages.Canvas do
  begin
    Brush.Color := clWhite;
    Pen.Color := clWhite;
    if iIndex >= ImageListUserImages.Count then
    begin
      Rectangle( Rect );
    end
    else
    begin
      ImageListUserImages.Draw( Canvas, Rect.Left,Rect.Top, iIndex );
    end;
  end;
end;

procedure TFormImageSelector.SigNETStringGridUserImagesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  iIndex : integer;
begin
  iIndex := (ARow * SigNETStringGridUserImages.ColCount) + ACol;
  if iIndex < ImageListUserImages.Count then
  begin
    ImageIndex := iIndex;
    ModalResult := mrOK;
  end
  else
  begin
    CanSelect := FALSE;
  end;
end;

end.
