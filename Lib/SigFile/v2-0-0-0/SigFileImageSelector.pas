unit SigFileImageSelector;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, SigNETStringGrid, ImgList,
  SigFileImageList, Menus, ExtDlgs;

type
  TFormImageSelector = class(TForm)
    SigNETStringGridUserImages: TSigNETStringGrid;
    BitBtn1: TBitBtn;
    ImageListUserImages: TImageList;
    PopupMenuOptions: TPopupMenu;
    InsertBefore1: TMenuItem;
    InsertAfter1: TMenuItem;
    Delete1: TMenuItem;
    Append1: TMenuItem;
    OpenPictureDialogImageSelector: TOpenPictureDialog;
    procedure SigNETStringGridUserImagesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SigNETStringGridUserImagesSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure SigNETStringGridUserImagesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure InsertBefore1Click(Sender: TObject);
    procedure SigNETStringGridUserImagesMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    fImageIndex: integer;
    fImageList: tSigFileImageList;
    fEditMode: boolean;
    fSelIndex : integer;
    procedure SetImageIndex(const Value: integer);
    procedure SetImageList(const Value: tSigFileImageList);
    procedure SetEditMode(const Value: boolean);
    { Private declarations }
    property EditMode : boolean
             read fEditMode
             write SetEditMode;
  public
    { Public declarations }

    property ImageIndex : integer
             read fImageIndex
             write SetImageIndex;
    property ImageList : tSigFileImageList
             read fImageList
             write SetImageList;

    function Execute( var pSelection : string ) : boolean;
    procedure Edit;
  end;

var
  FormImageSelector: TFormImageSelector;

implementation

{$R *.dfm}

procedure TFormImageSelector.Edit;
begin
  EditMode := TRUE;
  fImageIndex := -1;
  ShowModal;
end;

function TFormImageSelector.Execute(var pSelection : string ): boolean;
begin
  if assigned( fImageList ) then
  begin
    EditMode := FALSE;
    ImageIndex := fImageList.FileToIndex( pSelection );
    Result := ShowModal = mrOK;
    if Result then
    begin
      pSelection := fImageList.IndexToFile( ImageIndex );
    end;
  end
  else
  begin
    raise exception.Create( 'No images allocated' );
  end;
end;

procedure TFormImageSelector.InsertBefore1Click(Sender: TObject);
begin
  if assigned( fImageList ) then
  begin
    if OpenPictureDialogImageSelector.Execute then
    begin
      if fSelIndex <> -1 then
      begin
        fImageList.InsertNewChild( fSelIndex );
      end;
    end;
  end;
end;

procedure TFormImageSelector.SetEditMode(const Value: boolean);
begin
  fEditMode := Value;
  if Value then
  begin
    BitBtn1.Kind := bkOK;
  end
  else
  begin
    BitBtn1.Kind := bkCancel;
  end;
end;

procedure TFormImageSelector.SetImageIndex(const Value: integer);
begin
  fImageIndex := Value;
end;

procedure TFormImageSelector.SetImageList(const Value: tSigFileImageList);
begin
  fImageList := Value;
  fImageList.ImageList := ImageListUserImages;
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
    if iIndex > fImageList.Max then
    begin
      Rectangle( Rect );
    end
    else
    begin
      iIndex := fImageList.Image[ iIndex ].IconIndex;
      if iIndex < 0 then
      begin
        Rectangle( Rect );
      end
      else
      begin
        ImageListUserImages.Draw( Canvas, Rect.Left,Rect.Top, iIndex );
      end;
    end;
  end;
end;

procedure TFormImageSelector.SigNETStringGridUserImagesMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ARow, ACol : integer;
begin
  SigNETStringGridUserImages.MouseToCell( X, Y, ACol, ARow );
  fSelIndex := (ARow * SigNETStringGridUserImages.ColCount) + ACol;
end;

procedure TFormImageSelector.SigNETStringGridUserImagesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ARow, ACol, iSelIndex : integer;
begin
  SigNETStringGridUserImages.MouseToCell( X, Y, ACol, ARow );
  iSelIndex := (ARow * SigNETStringGridUserImages.ColCount) + ACol;
  if iSelIndex <> fSelIndex then
  begin
    if iSelIndex > fImageList.Max  then
    begin
      iSelIndex := fImageList.Max;
    end;
    fImageList.MoveChild( fSelIndex, iSelIndex );
    SigNETStringGridUserImages.Invalidate;
  end;
end;

procedure TFormImageSelector.SigNETStringGridUserImagesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  fSelIndex := (ARow * SigNETStringGridUserImages.ColCount) + ACol;
  if not EditMode then
    begin
    if fSelIndex < ImageListUserImages.Count then
    begin
      ImageIndex := fSelIndex;
      ModalResult := mrOK;
    end
    else
    begin
      CanSelect := FALSE;
    end;
  end;
end;

end.
