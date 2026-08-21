unit UnitTransparentBMP;

interface

uses
  Windows,
  Graphics;

type
  TSigGauge = class
  private
    fBitmap0: TBitmap;
    fBitmap100: tBitmap;
    fBitmapMask: TBitmap;
  public
    constructor Create;
    property Bitmap0 : TBitmap    // 0% bitmap
             read fBitmap0
             write fBitmap0;
    property Bitmap100 : TBitmap  // 100% bitmap - should be same size as 0% bitmap
             read fBitmap100
             write fBitmap100;
    property BitmapMask : TBitmap
             read fBitmapMask
             write fBitMapMask;
    procedure Draw( const Canvas : TCanvas );
  end;

implementation


procedure DrawTransparentBitmap(DC: HDC; hBmp : HBITMAP ;
    xStart: integer; yStart : integer; cTransparentColor : COLORREF);
  var
    bm: BITMAP;
    cColor: COLORREF;
    bmAndBack, bmAndObject, bmAndMem, bmSave:HBITMAP;
    bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBITMAP;
    hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave:HDC;
    ptSize: TPOINT;
  begin
    hdcTemp := CreateCompatibleDC(dc);
    SelectObject(hdcTemp, hBmp);// Select the bitmap
    GetObject(hBmp, sizeof(BITMAP), @bm);
    ptSize.x := bm.bmWidth;// Get width of bitmap
    ptSize.y := bm.bmHeight;// Get height of bitmap
    DPtoLP(hdcTemp, ptSize, 1);// Convert from device
    // to logical points
    // Create some DCs to hold temporary data.
    hdcBack:= CreateCompatibleDC(dc);
    hdcObject := CreateCompatibleDC(dc);
    hdcMem:= CreateCompatibleDC(dc);
    hdcSave:= CreateCompatibleDC(dc);
    // Create a bitmap for each DC. DCs are required for a number of
    // GDI functions.
    // Monochrome DC
    bmAndBack:= CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
    // Monochrome DC
    bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
    bmAndMem:= CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);
    bmSave := CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);
    // Each DC must select a bitmap object to store pixel data.
    bmBackOld:= SelectObject(hdcBack, bmAndBack);
    bmObjectOld := SelectObject(hdcObject, bmAndObject);
    bmMemOld:= SelectObject(hdcMem, bmAndMem);
    bmSaveOld:= SelectObject(hdcSave, bmSave);
    // Set proper mapping mode.
    SetMapMode(hdcTemp, GetMapMode(dc));
    // Save the bitmap sent here, because it will be overwritten.
    BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);
    // Set the background color of the source DC to the color.
    // contained in the parts of the bitmap that should be transparent
    cColor := SetBkColor(hdcTemp, cTransparentColor);
    // Create the object mask for the bitmap by performing a BitBlt
    // from the source bitmap to a monochrome bitmap.
    BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0,
    SRCCOPY);
    // Set the background color of the source DC back to the original
    // color.
    SetBkColor(hdcTemp, cColor);
    // Create the inverse of the object mask.
    BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0,
    NOTSRCCOPY);
    // Copy the background of the main DC to the destination.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, dc, xStart, yStart,
    SRCCOPY);
    // Mask out the places where the bitmap will be placed.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);
    // Mask out the transparent colored pixels on the bitmap.
    BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
    // XOR the bitmap with the background on the destination DC.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);
    // Copy the destination to the screen.
    BitBlt(dc, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0,
    SRCCOPY);
    // Place the original bitmap back into the bitmap sent here.
    BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);
    // Delete the memory bitmaps.
    DeleteObject(SelectObject(hdcBack, bmBackOld));
    DeleteObject(SelectObject(hdcObject, bmObjectOld));
    DeleteObject(SelectObject(hdcMem, bmMemOld));
    DeleteObject(SelectObject(hdcSave, bmSaveOld));
    // Delete the memory DCs.
    DeleteDC(hdcMem);
    DeleteDC(hdcBack);
    DeleteDC(hdcObject);
    DeleteDC(hdcSave);
    DeleteDC(hdcTemp);
  end;

(*
    procedure TForm1.Button1Click(Sender: TObject);
    begin
    DrawTransparentBitmap(Form1.Canvas.Handle, Image1.Picture.Bitmap.Handle, 10, 10, clWhite);
    end;
*)




{ TSigGauge }

{
procedure DrawTransparentBitmap(DC: HDC; hBmp : HBITMAP ;
    xStart: integer; yStart : integer; cTransparentColor : COLORREF);
}
constructor TSigGauge.Create;
begin
  inherited Create;
end;

procedure TSigGauge.Draw(const Canvas: TCanvas);
  var
    bm: BITMAP;
    cColor: COLORREF;
    bmAndBack, bmAndObject, bmAndMem, bmSave:HBITMAP;
    bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBITMAP;
    hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave:HDC;
    ptSize: TPOINT;
    dc : HDC;

  begin
    dc := Canvas.Handle;
    hdcTemp := CreateCompatibleDC(dc);

    SelectObject(hdcTemp, Bitmap100.Handle );// Select the bitmap
    GetObject(Bitmap100.Handle, sizeof(BITMAP), @bm);
    ptSize.x := bm.bmWidth;// Get width of bitmap
    ptSize.y := bm.bmHeight;// Get height of bitmap
    DPtoLP(hdcTemp, ptSize, 1);// Convert from device
    // to logical points
    // Create some DCs to hold temporary data.
    hdcBack:= CreateCompatibleDC(dc);
    hdcObject := CreateCompatibleDC(dc);
    hdcMem:= CreateCompatibleDC(dc);
    hdcSave:= CreateCompatibleDC(dc);
    // Create a bitmap for each DC. DCs are required for a number of
    // GDI functions.
    // Monochrome DC
    bmAndBack:= CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
    // Monochrome DC
    bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
    bmAndMem:= CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);
    bmSave := CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);
    // Each DC must select a bitmap object to store pixel data.
    bmBackOld:= SelectObject(hdcBack, bmAndBack);
    bmObjectOld := SelectObject(hdcObject, bmAndObject);
    bmMemOld:= SelectObject(hdcMem, bmAndMem);
    bmSaveOld:= SelectObject(hdcSave, bmSave);
    // Set proper mapping mode.
    SetMapMode(hdcTemp, GetMapMode(dc));
    // Save the bitmap sent here, because it will be overwritten.
    BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);
    // Set the background color of the source DC to the color.
    // contained in the parts of the bitmap that should be transparent
    cColor := SetBkColor(hdcTemp, cTransparentColor);
    // Create the object mask for the bitmap by performing a BitBlt
    // from the source bitmap to a monochrome bitmap.
    BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0,
    SRCCOPY);
    // Set the background color of the source DC back to the original
    // color.
    SetBkColor(hdcTemp, cColor);
    // Create the inverse of the object mask.
    BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0,
    NOTSRCCOPY);
    // Copy the background of the main DC to the destination.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, dc, xStart, yStart,
    SRCCOPY);
    // Mask out the places where the bitmap will be placed.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);
    // Mask out the transparent colored pixels on the bitmap.
    BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
    // XOR the bitmap with the background on the destination DC.
    BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);
    // Copy the destination to the screen.
    BitBlt(dc, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0,
    SRCCOPY);
    // Place the original bitmap back into the bitmap sent here.
    BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);
    // Delete the memory bitmaps.
    DeleteObject(SelectObject(hdcBack, bmBackOld));
    DeleteObject(SelectObject(hdcObject, bmObjectOld));
    DeleteObject(SelectObject(hdcMem, bmMemOld));
    DeleteObject(SelectObject(hdcSave, bmSaveOld));
    // Delete the memory DCs.
    DeleteDC(hdcMem);
    DeleteDC(hdcBack);
    DeleteDC(hdcObject);
    DeleteDC(hdcSave);
    DeleteDC(hdcTemp);
end;

end.
