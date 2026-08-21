unit SigImage;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TSigImage = class(TImage)
  private
    { Private declarations }
  protected
    iImageIndex : integer;
    iImageList : tImageList;
    procedure fSetImageIndex( NewVal : integer );
    procedure fSetImageList( NewVal : tImageList );
    procedure fChangeImage;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ImageList : tImageList
             read iImageList
             write fSetImageList;
    property ImageIndex : integer
             read iImageIndex
             write fSetImageIndex
             default 0;
    property AutoSize
             default TRUE;
    property Transparent
             default TRUE;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigImage]);
end;

constructor TSigImage.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  iImageIndex := 0;
  iImageList := nil;
  AutoSize := TRUE;
  Transparent := TRUE;
end;

procedure TSigImage.fSetImageIndex( NewVal : integer );
begin
  if iImageIndex <> Newval then
  begin
    iImageIndex := NewVal;
    fChangeImage;
  end;
end;

procedure TSigImage.fSetImageList( NewVal : tImageList );
begin
  if iImageList <> NewVal then
  begin
    iImageList := NewVal;
    Width := NewVal.Width;
    Height := NewVal.Height;
    fChangeImage;
  end;
end;

procedure TSigImage.fChangeImage;
begin
  if assigned( iImageList ) then
  begin
    if iImageList.Count > iImageIndex then
    begin
      iImageList.GetBitmap( iImageIndex, Picture.Bitmap);
      Invalidate;
    end;
  end;
end;

end.
