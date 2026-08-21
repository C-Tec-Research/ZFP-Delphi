unit SigImage;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TSigImage = class(TImage)
  private
    { Private declarations }
  protected
    fImageIndex : integer;
    fImageList : tImageList;
    procedure SetImageIndex( NewVal : integer );
    procedure SetImageList( NewVal : tImageList );
    procedure ChangeImage;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ImageList : tImageList
             read fImageList
             write SetImageList;
    property ImageIndex : integer
             read fImageIndex
             write SetImageIndex
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
  fImageIndex := 0;
  fImageList := nil;
  AutoSize := TRUE;
  Transparent := TRUE;
end;

procedure TSigImage.SetImageIndex( NewVal : integer );
begin
  fImageIndex := NewVal;
  ChangeImage;
end;

procedure TSigImage.SetImageList( NewVal : tImageList );
begin
  if ImageList <> NewVal then
  begin
    fImageList := NewVal;
    if assigned( NewVal ) then
    begin
      Width := NewVal.Width;
      Height := NewVal.Height;
      ChangeImage;
    end;
  end;
end;

procedure TSigImage.ChangeImage;
begin
  if assigned( fImageList ) then
  begin
    if fImageList.Count > fImageIndex then
    begin
      fImageList.GetBitmap( fImageIndex, Picture.Bitmap);
      Invalidate;
    end;
  end;
end;

end.
