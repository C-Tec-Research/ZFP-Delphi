unit DibGraphic;

interface

uses Windows, SysUtils, Graphics, DibUtil, Classes, Forms, Controls;

type
   TDIB = class(TGraphic)
   private
      hDIB        : HDIB;
      FWidth      : integer;
      FHeight     : integer;
      FBitCount   : integer;
      lpDIB       : LPSTR;
      lpDIBits    : LPSTR;
      PalBits     : LPSTR;
      FPal        : HPALETTE;
      PalChange   : boolean;
   protected
      constructor Create; override;
      destructor  Destroy; override;
      procedure   Draw(ACanvas: TCanvas; const Rect: TRect); override;
      function    GetEmpty: Boolean; override;
      function    GetHeight: Integer; override;
      function    GetWidth: Integer; override;
      procedure   SetHeight(Value: Integer); override;
      procedure   SetWidth(Value: Integer); override;
      function    GetPal(i: integer): TRGBQuad;
      procedure   SetPal(i: integer; p: TRGBQuad);
      function    GetPixel(x,y: integer): integer;
      procedure   SetPixel(x,y: integer; c: integer);
      function    ReadDIBStream(Stream: TStream): HDIB;
      procedure   SetInternals;
      function    GetPalette: HPALETTE;
   public
      procedure   FocusPalette;
      procedure   Assign(Source: TPersistent); override;
      procedure   LoadFromStream(Stream: TStream); override;
      procedure   SaveToStream(Stream: TStream); override;
      procedure   LoadFromClipboardFormat(AFormat: Word; AData: THandle; APalette: HPALETTE); override;
      procedure   SaveToClipboardFormat(var AFormat: Word; var AData: THandle; var APalette: HPALETTE); override;
      procedure   CreateDIB(Wid, Hgt, BitCount : integer);
      procedure   GrayPal;
      procedure   MakeBitmap(var b: TBitmap);
      property    BitCount:integer read FBitCount;
      property    Pal[i: integer]: TRGBQuad read GetPal write SetPal;
      property    Pixel[x,y: integer]: integer read GetPixel write SetPixel;
      property    Palette:HPALETTE read GetPalette;
   end;


implementation

constructor TDIB.Create;
begin
   inherited;
   hDIB        := 0;
   FWidth      := 0;
   FHeight     := 0;
   FBitCount   := 0;
   lpDIB       := nil;
   lpDIBits    := nil;
   PalBits     := nil;
   FPal        := 0;
   PalChange   := False;
end;

destructor TDIB.Destroy;
begin
   if hDIB<>0 then GlobalFree(hDIB);
   hDIB := 0;
   if FPal<>0 then DeleteObject(FPal);
   FPal := 0;
   inherited;
end;

procedure TDIB.Draw(ACanvas: TCanvas; const Rect: TRect);
var
   DIBR : TRect;
begin
   DIBR := Classes.Rect(0, 0, FWidth-1, FHeight-1);
   PaintDIB(ACanvas.Handle, @Rect, hDIB, @DIBR, Palette);
end;

function TDIB.GetEmpty: Boolean;
begin
   Result := (hDIB = 0);
end;

function TDIB.GetHeight: Integer;
begin
   Result := FHeight;
end;

function TDIB.GetWidth: Integer;
begin
   Result := FWidth;
end;

procedure TDIB.SetHeight(Value: Integer);
begin
   raise Exception.Create('SetHeight not supported');
end;

procedure TDIB.SetWidth(Value: Integer);
begin
   raise Exception.Create('SetWidth not supported');
end;

// LoadFromStream is the way to open a DIB
procedure TDIB.LoadFromStream(Stream: TStream);
begin
   Screen.Cursor := crHourGlass;
   try
      hDIB        := ReadDIBStream(Stream);
      if hDIB=0 then raise Exception.Create('Unable to Load DIB Stream');
      SetInternals;
      FocusPalette;  // Is this right? -bpz
   finally
      Screen.Cursor := crDefault;
   end;
end;

function TDIB.ReadDIBStream(Stream: TStream): HDIB;
var
   bmfHeader   : TBITMAPFILEHEADER;
   nNumColors  : UINT;                // Number of colors in table
   hDIB        : THANDLE;
   hDIBtmp     : THANDLE;             // Used for GlobalRealloc() //MPB
   lpbi        : PBitmapInfoHeader;
   offBits     : DWORD;
   buf         : pointer;
begin
   // Allocate memory for header & color table. We'll enlarge this
   // memory as needed.

   hDIB := GlobalAlloc(GMEM_MOVEABLE, sizeof(TBITMAPINFOHEADER) +
           256 * sizeof(TRGBQUAD));

   if hDIB=0 then begin
     Result := 0;
     exit;
   end;

   lpbi := PBITMAPINFOHEADER(GlobalLock(hDIB));

   if lpbi=Pointer(0) then begin
       GlobalFree(hDIB);
       Result := 0;
       exit;
   end;

   // read the BITMAPFILEHEADER from our file
   try
      Stream.ReadBuffer(bmfHeader, sizeof (TBITMAPFILEHEADER));
   except
      on Exception do begin
         GlobalFree(hDIB);
         Result := 0;
         exit;
      end;
   end;

   if bmfHeader.bfType <> $4d42 then begin
      GlobalFree(hDIB);
      Result := 0;
      exit;
   end;

   // read the BITMAPINFOHEADER
   try
      Stream.ReadBuffer(LPSTR(lpbi)^, sizeof(TBITMAPINFOHEADER));
   except
      on Exception do begin
         GlobalFree(hDIB);
         Result := 0;
         exit;
      end;
   end;

   // Check to see that it's a Windows DIB -- an OS/2 DIB would cause
   // strange problems with the rest of the DIB API since the fields
   // in the header are different and the color table entries are
   // smaller.
   //
   // If it's not a Windows DIB (e.g. if biSize is wrong), return NULL.

   if (lpbi^.biSize = sizeof(TBITMAPCOREHEADER)) then begin
      GlobalFree(hDIB);
      Result := 0;
      exit;
   end;

   // Now determine the size of the color table and read it.  Since the
   // bitmap bits are offset in the file by bfOffBits, we need to do some
   // special processing here to make sure the bits directly follow
   // the color table (because that's the format we are susposed to pass
   // back)

   nNumColors := lpbi^.biClrUsed;
   if (nNumColors = 0) then begin
       // no color table for 24-bit, default size otherwise

       if (lpbi^.biBitCount <> 24)then
           nNumColors := 1 shl lpbi^.biBitCount; // standard size table
   end;

   // fill in some default values if they are zero

   if (lpbi^.biClrUsed = 0) then
       lpbi^.biClrUsed := nNumColors;

   if (lpbi^.biSizeImage = 0) then begin
       lpbi^.biSizeImage := ((((lpbi^.biWidth * lpbi^.biBitCount) +
               31) and (not 31)) shr 3) * lpbi^.biHeight;
   end;

   // get a proper-sized buffer for header, color table and bits

   GlobalUnlock(hDIB);
   hDIBtmp := GlobalReAlloc(hDIB, lpbi^.biSize + nNumColors *
           sizeof(TRGBQUAD) + lpbi^.biSizeImage, 0);

   if (hDIBtmp = 0) then begin   // can't resize buffer for loading
      GlobalFree(hDIB);
      Result := 0;
      exit;
   end else
       hDIB := hDIBtmp;

   lpbi := PBITMAPINFOHEADER(GlobalLock(hDIB));

   // read the color table
   buf := LPSTR((lpbi)) + lpbi^.biSize;
   Stream.ReadBuffer(buf^, nNumColors * sizeof(TRGBQUAD));

   // offset to the bits from start of DIB header

   offBits := lpbi^.biSize + nNumColors * sizeof(TRGBQUAD);

   // If the bfOffBits field is non-zero, then the bits might *not* be
   // directly following the color table in the file.  Use the value in
   // bfOffBits to seek the bits.

   if (bmfHeader.bfOffBits <> 0) then
      Stream.Seek(bmfHeader.bfOffBits, 0);

   buf := LPSTR(lpbi) + offBits;
   Stream.ReadBuffer(buf^, lpbi^.biSizeImage);

   GlobalUnlock(hDIB);
   Result := hDIB;
end;

{*************************************************************************
 *
 * SaveDIB()
 *
 * Saves the specified DIB into the specified file name on disk.  No
 * error checking is done, so if the file already exists, it will be
 * written over.
 *
 * Parameters:
 *
 * HDIB hDib - Handle to the dib to save
 *
 * LPSTR lpFileName - pointer to full pathname to save DIB under
 *
 * Return value: 0 if successful, or one of:
 *        ERR_INVALIDHANDLE
 *        ERR_OPEN
 *        ERR_LOCK
 *
 *************************************************************************}

procedure TDIB.SaveToStream(Stream: TStream);
var
   bmfHdr       : TBitmapFileHeader;
   dwDIBSize    : DWORD;
   lpBI         : PBitmapInfoHeader;
   dwBmBitsSize : DWORD;
begin
   if (hDib=0) then raise Exception.Create('No DIB Loaded');

   // Get a pointer to the DIB memory, the first of which contains
   // a BITMAPINFO structure

   lpBI := PBitmapInfoHeader(lpDIB);

   // Fill in the fields of the file header

   // Fill in file type (first 2 bytes must be "BM" for a bitmap)

   bmfHdr.bfType := $4d42;  // "BM"

   // Calculating the size of the DIB is a bit tricky (if we want to
   // do it right).  The easiest way to do this is to call GlobalSize()
   // on our global handle, but since the size of our global memory may have
   // been padded a few bytes, we may end up writing out a few too
   // many bytes to the file (which may cause problems with some apps,
   // like HC 3.0).
   //
   // So, instead let's calculate the size manually.
   //
   // To do this, find size of header plus size of color table.  Since the
   // first DWORD in both BITMAPINFOHEADER and BITMAPCOREHEADER conains
   // the size of the structure, let's use this.

   // Partial Calculation

   dwDIBSize := lpBI^.biSize + PaletteSize(LPSTR(lpBI));

   // Now calculate the size of the image

   // It's an RLE bitmap, we can't calculate size, so trust the biSizeImage
   // field

   if ((lpBI^.biCompression = BI_RLE8) or (lpBI^.biCompression = BI_RLE4)) then
       dwDIBSize := dwDIBSize + lpBI^.biSizeImage
   else begin

       // It's not RLE, so size is Width (DWORD aligned) * Height

       dwBmBitsSize := WIDTHBYTES((lpBI^.biWidth)*(lpBI^.biBitCount)) * lpBI^.biHeight;

       dwDIBSize := dwDIBSize + dwBmBitsSize;

       // Now, since we have calculated the correct size, why don't we
       // fill in the biSizeImage field (this will fix any .BMP files which
       // have this field incorrect).

       lpBI^.biSizeImage := dwBmBitsSize;
   end;

   // Calculate the file size by adding the DIB size to sizeof(BITMAPFILEHEADER)
                   
   bmfHdr.bfSize := dwDIBSize + sizeof(TBITMAPFILEHEADER);
   bmfHdr.bfReserved1 := 0;
   bmfHdr.bfReserved2 := 0;

   // Now, calculate the offset the actual bitmap bits will be in
   // the file -- It's the Bitmap file header plus the DIB header,
   // plus the size of the color table.
    
   bmfHdr.bfOffBits := sizeof(TBITMAPFILEHEADER) + lpBI^.biSize +
           PaletteSize(LPSTR(lpBI));

   // Write the file header

   Stream.WriteBuffer(bmfHdr, sizeof(TBitmapFileHeader));

   // Write the DIB header and the bits -- use local version of
   // MyWrite, so we can write more than 32767 bytes of data

   Stream.WriteBuffer(lpBI^, dwDIBSize);
end;

procedure TDIB.LoadFromClipboardFormat(AFormat: Word; AData: THandle; APalette: HPALETTE);
begin
   raise Exception.Create('LoadFromClipboardFormat not supported');
end;

procedure TDIB.SaveToClipboardFormat(var AFormat: Word; var AData: THandle; var APalette: HPALETTE);
begin
   raise Exception.Create('SaveToClipboardFormat not supported');
end;

function TDIB.GetPal(i: integer): TRGBQuad;
var
   pQuad : LPSTR;
begin
   pQuad := PalBits + sizeof(TRGBQuad) * i;
   Result := PRGBQuad(pQuad)^;
end;

function ColorMatch(c1, c2: TRGBQuad): boolean;
var
   p1, p2 : PChar;
begin
   p1 := @c1;
   p2 := @c2;
   if (p1[0]=p2[0]) and (p1[1]=p2[1]) and (p1[2]=p2[2]) then Result := True
      else Result := False;
end;

procedure TDIB.SetPal(i: integer; p: TRGBQuad);
var
   pQuad : LPSTR;
begin
   if not ColorMatch(GetPal(i), p) then begin
      pQuad := PalBits + sizeof(TRGBQuad) * i;
      PRGBQuad(pQuad)^ := p;
      PalChange := True;
      Changed(Self);
   end;
end;

function TDIB.GetPixel(x,y: integer): integer;
var
   p24 : PColor24;
begin
   y := Height - y - 1;
   case BitCount of
      8  : Result := GetPixel8(lpDIBits, x, y, FWidth)^;
      24 : begin
         p24 := GetPixel24(lpDIBits, x, y, FWidth);
         Result := RGB(p24^.Red, p24^.Grn, p24^.Blu);
      end;
   else
      raise Exception.Create('DIB Bit Count not supported' + IntToStr(BitCount));
   end;
end;

procedure TDIB.SetPixel(x,y: integer; c: integer);
var
   p24 : PColor24;
begin
   y := Height - y - 1;
   case BitCount of
      8  : GetPixel8(lpDIBits, x, y, FWidth)^ := c;
      24 : begin
         p24 := GetPixel24(lpDIBits, x, y, FWidth);
         p24^.Red := c and 255;
         p24^.Grn := (c shr 8) and 255;
         p24^.Blu := (c shr 16) and 255;
      end;
   else
      raise Exception.Create('DIB Bit Count not supported' + IntToStr(BitCount));
   end;
   Changed(Self);
end;

procedure TDIB.CreateDIB(Wid, Hgt, BitCount : integer);
begin
   if hDIB<>0 then GlobalFree(hDIB);
   hDIB := DibUtil.CreateDIB(Wid, Hgt, BitCount);
   SetInternals;
   Changed(Self);
end;

procedure TDIB.SetInternals;
begin
   lpDIB       := GlobalLock(hDIB);
   lpDIBits    := FindDIBits(lpDIB);
   PalBits     := lpDIB + PBitmapInfoHeader(lpDIB)^.biSize;
   FWidth      := PBitmapInfoHeader(lpDIB)^.biWidth;
   FHeight     := PBitmapInfoHeader(lpDIB)^.biHeight;
   FBitCount   := PBitmapInfoHeader(lpDIB)^.biBitCount;
   PalChange   := True;
end;

// Need to add reference counting to this later
procedure TDIB.Assign(Source: TPersistent);
var
   sd     : TDIB;
   p      : PChar;
   NumCol : integer;
   s      : integer;
   i      : integer;
begin
   if Source=Self then
      raise Exception.Create('Assigning TDib to Myself!');

   sd := Source as TDIB;
   if hDIB<>0 then GlobalFree(hDIB);

   case sd.BitCount of
      1  : NumCol := 2;
      4  : NumCol := 16;
      8  : NumCol := 256;
   else
      NumCol := 0;
   end;
   s := PBitmapInfoHeader(sd.lpDIB)^.biSize + sizeof(TRGBQuad) * NumCol;                 // Header + Palette
   s := s + WIDTHBYTES(sd.Width * sd.BitCount) * sd.Height;    // + actual image size

   hDIB := GlobalAlloc(GHND, s);
   if hDIB=0 then raise Exception.Create('Unable to allocate Memory in TDIB.Assign');
   p := GlobalLock(hDIB);
   for i := 0 to s-1 do
      p[i] := sd.lpDIB[i];
   GlobalUnlock(hDIB);
   SetInternals;
   Changed(Self);
end;

procedure TDIB.GrayPal;
var
   i  : integer;
   RQ : TRGBQuad;
begin
   // Fix up the DIB Color Palette
   for i := 0 to 255 do begin
      RQ.rgbRed   := i;
      RQ.rgbGreen := i;
      RQ.rgbBlue  := i;
      Pal[i] := RQ;
   end;
end;

procedure TDIB.MakeBitmap(var b: TBitmap);
var
   R : TRect;
begin
   b.Width  := Width;
   b.Height := Height;
   R := Rect(0, 0, Width-1, Height-1);
   Draw(b.Canvas, R);
end;

function TDIB.GetPalette: HPALETTE;
begin
   if PalChange then begin
      PalChange := False;
      if FPal<>0 then DeleteObject(FPal);
      FPal := CreateDIBPalette(hDIB);
      // MessageBeep(0);
   end;
   Result := FPal;
end;

procedure TDib.FocusPalette;
var
  Focus: HWND;
  DC: HDC;
  OldPal: HPALETTE;
begin
   Focus := GetFocus;
   DC := GetDC(Focus);
   if Palette <> 0 then begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
   end else
      OldPal := 0;

   if OldPal <> 0 then
      SelectPalette(DC, OldPal, False);

   ReleaseDC(Focus, DC);
end;


end.

