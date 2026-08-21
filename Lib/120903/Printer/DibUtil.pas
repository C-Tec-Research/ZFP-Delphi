unit DibUtil;

interface

uses SysUtils, Windows;

// To use Palette arrays, turn off range checking
{$R-}

const
   NULL : THandle = THandle(0);

type
   HDIB = THandle;
   
   PColor8  = ^byte;
   PColor24 = ^TColor24;
   TColor24 = packed record
      Blu, Grn, Red: byte;
   end;

function WIDTHBYTES(bits: integer): integer;
function CreateDIB(dwWidth, dwHeight: DWORD; wBitCount: WORD): HDIB;
function FindDIBits(lpDIB: LPSTR): LPSTR;
function PaletteSize(lpDIB: LPSTR): WORD;
function DIBNumColors(lpDIB: LPSTR): WORD;
function DIBToBitmap(phDIB: HDIB; hPal: HPALETTE): HBITMAP;
function BitmapToDIB(phBitmap: HBITMAP; hPal: HPALETTE): HDIB;
function CreateDIBPalette(phDIB: HDIB): HPALETTE;
function GetPixel8(lpDIBits: LPSTR; x, y, Wid: integer): PColor8;
function GetPixel24(lpDIBits: LPSTR; x, y, Wid: integer): PColor24;
function LoadDIB(fn: string): HDIB;
function ReadDIBFile(hFile: THandle): HDIB;
function PaintDIB(ihdc: HDC; lpDCRect: PRect; phDIB: HDIB; lpDIBRect: PRect; hPal: HPALETTE): integer;
function DIBWidth(p: pointer): integer;
function DIBHeight(p: pointer): integer;


implementation

procedure ValidBits(var Bits: WORD);
begin
   if Bits <= 1 then
      Bits := 1
   else if Bits <= 4 then
      Bits := 4
   else if Bits <= 8 then
      Bits := 8
   {else if Bits <= 16 then
      Bits := 16}
   else if Bits <= 24 then
      Bits := 24
   {else if Bits <= 32 then
      Bits := 32;}
end;

// WIDTHBYTES performs DWORD-aligning of DIB scanlines.  The "bits"
// parameter is the bit count for the scanline (biWidth * biBitCount),
// and this macro returns the number of DWORD-aligned bytes needed
// to hold those bits.

function WIDTHBYTES(bits: integer): integer;
begin
   Result := (bits + 31) div 32 * 4;
end;

function RECTWIDTH(R: PRect): integer;
begin
   Result := R^.Right - R^.Left;
end;

function RECTHEIGHT(R: PRect): integer;
begin
   Result := R^.Bottom - R^.Top;
end;

function DIBHeight(p: pointer): integer;
begin
   Result := PBitmapInfoHeader(p)^.biHeight;
end;

function DIBWidth(p: pointer): integer;
begin
   Result := PBitmapInfoHeader(p)^.biWidth;
end;


{*************************************************************************
 *
 * CreateDIB()
 *
 * Parameters:
 *
 * DWORD dwWidth    - Width for new bitmap, in pixels
 * DWORD dwHeight   - Height for new bitmap
 * WORD  wBitCount  - Bit Count for new DIB (1, 4, 8, or 24)
 *
 * Return Value:
 *
 * HDIB             - Handle to new DIB
 *
 * Description:
 *
 * This function allocates memory for and initializes a new DIB by
 * filling in the BITMAPINFOHEADER, allocating memory for the color
 * table, and allocating memory for the bitmap bits.  As with all
 * HDIBs, the header, colortable and bits are all in one contiguous
 * memory block.  This function is similar to the CreateBitmap()
 * Windows API.
 *
 * The colortable and bitmap bits are left uninitialized (zeroed) in the
 * returned HDIB.
 *
 *
 ************************************************************************}

function CreateDIB(dwWidth, dwHeight: DWORD; wBitCount: WORD): HDIB;
var
   bi             : TBitmapInfoHeader;
   lpbi           : PBitmapInfoHeader;
   dwLen          : DWORD;
   ihDIB           : HDIB;
   dwBytesPerLine : DWORD;
begin
   // Make sure bits per pixel is valid

   ValidBits(wBitCount);

   // Initialize BITMAPINFOHEADER

   bi.biSize            := sizeof(TBitmapInfoHeader);
   bi.biWidth           := dwWidth;
   bi.biHeight          := dwHeight;
   bi.biPlanes          := 1;
   bi.biBitCount        := wBitCount;
   bi.biCompression     := BI_RGB;
   bi.biSizeImage       := 0;
   bi.biXPelsPerMeter   := 0;
   bi.biYPelsPerMeter   := 0;
   bi.biClrUsed         := 0;
   bi.biClrImportant    := 0;

   // calculate size of memory block required to store the DIB.  This
   // block should be big enough to hold the BITMAPINFOHEADER, the color
   // table, and the bits

   dwBytesPerLine := WIDTHBYTES(wBitCount * dwWidth);
   dwLen := bi.biSize + PaletteSize(LPSTR(@bi)) + (dwBytesPerLine * dwHeight);

   ihDIB := GlobalAlloc(GHND, dwLen);

   if ihDIB=0 then begin
      Result := 0;
      exit;
   end;

   lpbi := GlobalLock(ihDIB);
   lpbi^ := bi;

   // Since we don't know what the colortable and bits should contain,
   // just leave these blank.  Unlock the DIB and return the HDIB.

   GlobalUnlock(ihDIB);

   Result := ihDIB;
end;


{*************************************************************************
 *
 * PaletteSize()
 *
 * Parameter:
 *
 * LPSTR lpDIB      - pointer to packed-DIB memory block
 *
 * Return Value:
 *
 * WORD             - size of the color palette of the DIB
 *
 * Description:
 *
 * This function gets the size required to store the DIB's palette by
 * multiplying the number of colors by the size of an RGBQUAD (for a
 * Windows 3.0-style DIB) or by the size of an RGBTRIPLE (for an OS/2-
 * style DIB).
 *
 ************************************************************************}

function PaletteSize(lpDIB: LPSTR): WORD;
begin
   Result := DIBNumColors(lpDIB) * sizeof(TRGBQUAD);
end;

{*************************************************************************
 *
 * DIBNumColors()
 *
 * Parameter:
 *
 * LPSTR lpDIB      - pointer to packed-DIB memory block
 *
 * Return Value:
 *
 * WORD             - number of colors in the color table
 *
 * Description:
 *
 * This function calculates the number of colors in the DIB's color table
 * by finding the bits per pixel for the DIB (whether Win3.0 or OS/2-style
 * DIB). If bits per pixel is 1: colors=2, if 4: colors=16, if 8: colors=256,
 * if 24, no colors in color table.
 *
 ************************************************************************}

function DIBNumColors(lpDIB: LPSTR): WORD;
var
   wBitCount   : WORD;
   dwClrUsed   : DWORD;
begin
   dwClrUsed := PBitmapInfoHeader(lpDIB)^.biClrUsed;
   if dwClrUsed<>0 then begin
      Result := dwClrUsed;
      exit;
   end;

   wBitCount := PBitmapInfoHeader(lpDIB)^.biBitCount;

   case wBitCount of
      1: Result := 2;
      4: Result := 16;
      8: Result := 256;
   else Result := 0;
   end;
end;


{*************************************************************************
 *
 * BitmapToDIB()
 *
 * Parameters:
 *
 * HBITMAP hBitmap  - specifies the bitmap to convert
 *
 * HPALETTE hPal    - specifies the palette to use with the bitmap
 *
 * Return Value:
 *
 * HDIB             - identifies the device-dependent bitmap
 *
 * Description:
 *
 * This function creates a DIB from a bitmap using the specified palette.
 *
 ************************************************************************}

function BitmapToDIB(phBitmap: HBITMAP; hPal: HPALETTE): HDIB;
var
   bm             : Windows.TBITMAP;
   bi             : TBitmapInfoHeader;
   lpbi           : PBitmapInfoHeader;
   bi2            : TBitmapInfo;
   dwLen          : DWORD;
   ihDIB, h        : THandle;
   DC             : Windows.HDC;
   biBits         : WORD;
   rc             : integer;
begin
   if phBitmap=NULL then begin
      Result := 0;
      exit;
   end;

   if GetObject(phBitmap, sizeof(bm), LPSTR(@bm))=0 then begin
      Result := 0;
      exit;
   end;

   if (hPal = HPalette(nil)) then
      hPal := GetStockObject(DEFAULT_PALETTE);

   biBits := bm.bmPlanes * bm.bmBitsPixel;

   // Make sure bits per pixel is valid

   ValidBits(biBits);

   // Initialize BITMAPINFOHEADER

   bi.biSize            := sizeof(TBitmapInfoHeader);
   bi.biWidth           := bm.bmWidth;
   bi.biHeight          := bm.bmHeight;
   bi.biPlanes          := 1;
   bi.biBitCount        := biBits;
   bi.biCompression     := BI_RGB;
   bi.biSizeImage       := 0;
   bi.biXPelsPerMeter   := 0;
   bi.biYPelsPerMeter   := 0;
   bi.biClrUsed         := 0;
   bi.biClrImportant    := 0;

   dwLen := bi.biSize + PaletteSize(LPSTR(@bi));

   DC := GetDC(NULL);

   hPal := SelectPalette(DC, hPal, False);
   RealizePalette(DC);

   ihDIB := GlobalAlloc(GHND, dwLen);

   if ihDIB = NULL then begin
      SelectPalette(DC, hPal, True);
      RealizePalette(DC);
      ReleaseDC(NULL, DC);
      Result := 0;
      exit;
   end;

   lpbi  := PBitmapInfoHeader(GlobalLock(ihDIB));
   lpbi^ := bi;

   bi2.bmiHeader := lpbi^;
   GetDIBits(DC, phBitmap, 0, bi.biHeight, nil, bi2, DIB_RGB_COLORS);

   bi := lpbi^;

   GlobalUnlock(ihDIB);

   if bi.biSizeImage = 0 then
      bi.biSizeImage := WIDTHBYTES(bm.bmWidth * biBits) * bm.bmHeight;

   dwLen := bi.BiSize + PaletteSize(LPSTR(@bi)) + bi.biSizeImage;

   h := GlobalReAlloc(ihDIB, dwLen, 0);
   if h <> NULL then
      ihDIB := h
   else begin
      GlobalFree(ihDIB);
      SelectPalette(DC, hPal, True);
      RealizePalette(DC);
      ReleaseDC(NULL, DC);
      Result := NULL;
      exit;
   end;

   lpbi := PBitmapInfoHeader(GlobalLock(ihDIB));

   bi2.bmiHeader := lpbi^;
   rc := GetDIBits(DC, phBitmap, 0, bi.biHeight, LPSTR(lpbi) + lpbi^.biSize + PaletteSize(LPSTR(lpbi)),
      bi2, DIB_RGB_COLORS);
   if rc=0 then begin
      GlobalUnlock(ihDIB);
      SelectPalette(DC, hPal, True);
      RealizePalette(DC);
      ReleaseDC(NULL, DC);
      Result := NULL;
      exit;
   end;

   bi := lpbi^;
   GlobalUnlock(ihDIB);
   SelectPalette(DC, hPal, True);
   RealizePalette(DC);
   ReleaseDC(NULL, DC);
   Result := ihDIB;

end;

{*************************************************************************
 *
 * FindDIBBits()
 *
 * Parameter:
 *
 * LPSTR lpDIB      - pointer to packed-DIB memory block
 *
 * Return Value:
 *
 * LPSTR            - pointer to the DIB bits
 *
 * Description:
 *
 * This function calculates the address of the DIB's bits and returns a
 * pointer to the DIB bits.
 *
 ************************************************************************}

function FindDIBits(lpDIB: LPSTR): LPSTR;
begin
   Result := (lpDIB + PDWORD(lpDIB)^ + PaletteSize(lpDIB));
end;

function GetPixel24(lpDIBits: LPSTR; x, y, Wid: integer): PColor24;
var
   h : integer;
begin
   h := WIDTHBYTES(24 * Wid);
   Result := PColor24(lpDIBits + h*y + x*3);
end;

function GetPixel8(lpDIBits: LPSTR; x, y, Wid: integer): PColor8;
var
   h : integer;
begin
   h := WIDTHBYTES(8 * Wid);
   Result := PColor8(lpDIBits + h*y + x);
end;

{*************************************************************************
 *
 * DIBToBitmap()
 *
 * Parameters:
 *
 * HDIB hDIB        - specifies the DIB to convert
 *
 * HPALETTE hPal    - specifies the palette to use with the bitmap
 *
 * Return Value:
 *
 * HBITMAP          - identifies the device-dependent bitmap
 *
 * Description:
 *
 * This function creates a bitmap from a DIB using the specified palette.
 * If no palette is specified, default is used.
 *
 * NOTE:
 *
 * The bitmap returned from this funciton is always a bitmap compatible
 * with the screen (e.g. same bits/pixel and color planes) rather than
 * a bitmap with the same attributes as the DIB.  This behavior is by
 * design, and occurs because this function calls CreateDIBitmap to
 * do its work, and CreateDIBitmap always creates a bitmap compatible
 * with the hDC parameter passed in (because it in turn calls
 * CreateCompatibleBitmap).
 *
 * So for instance, if your DIB is a monochrome DIB and you call this
 * function, you will not get back a monochrome HBITMAP -- you will
 * get an HBITMAP compatible with the screen DC, but with only 2
 * colors used in the bitmap.
 *
 * If your application requires a monochrome HBITMAP returned for a
 * monochrome DIB, use the function SetDIBits().
 *
 * Also, the DIBpassed in to the function is not destroyed on exit. This
 * must be done later, once it is no longer needed.
 *
 ************************************************************************}

function DIBToBitmap(phDIB: HDIB; hPal: HPALETTE): HBITMAP;
var
   lpDIBHdr, lpDIBBits  : LPSTR;
   ihBitmap             : HBITMAP;
   ihDC                 : HDC;
   HOldPal              : HPALETTE;
   bi                   : TBitmapInfoHeader;
   bi2                  : TBitmapInfo;
begin
   HOldPal := 0;

   if phDIB=0 then begin
      Result := 0;
      exit;
   end;

   lpDIBHdr := GLobalLock(phDIB);
   lpDIBBIts := FindDIBits(lpDIBHdr);

   ihDC := GetDC(THandle(nil));
   if ihDC=0 then begin
      GlobalUnlock(phDIB);
      Result := 0;
      exit;
   end;

   if hPal<>0 then
      hOldPal := SelectPalette(ihDC, hPal, False);

   RealizePalette(ihDC);

   bi             := PBitmapInfoHeader(lpDIBHdr)^;
   bi2.bmiHeader  := PBitmapInfoHeader(lpDIBHdr)^;
   ihBitmap := CreateDIBitmap(ihDC, bi, CBM_INIT, lpDIBBIts, bi2, DIB_RGB_COLORS);

   if hOldPal<>0 then
      SelectPalette(ihDC, hOldPal, False);

   ReleaseDC(0, ihDC);
   GlobalUnlock(phDIB);

   Result := ihBitmap;
end;


{*************************************************************************
 *
 * LoadDIB()
 *
 * Loads the specified DIB from a file, allocates memory for it,
 * and reads the disk file into the memory.
 *
 *
 * Parameters:
 *
 * LPSTR lpFileName - specifies the file to load a DIB from
 *
 * Returns: A handle to a DIB, or NULL if unsuccessful.
 *
 * NOTE: The DIB API were not written to handle OS/2 DIBs; This
 * function will reject any file that is not a Windows DIB.
 *
 *************************************************************************}

function LoadDIB(fn: string): HDIB;
var
   ihDIB     : HDIB;
   hFile    : THandle;
begin
   SetCursor(LoadCursor(0, IDC_WAIT));
   hFile := CreateFile(PChar(fn), GENERIC_READ, FILE_SHARE_READ, PSecurityAttributes(0),
      OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, NULL);

   if hFile<>INVALID_HANDLE_VALUE then begin
      ihDIB := ReadDIBFile(hFile);
      CloseHandle(hFile);
      Result := ihDIB;
   end else
      Result := 0;
   SetCursor(LoadCursor(0, IDC_ARROW));
end;

{*************************************************************************
 *
 * Function:  ReadDIBFile (int)
 *
 *  Purpose:  Reads in the specified DIB file into a global chunk of
 *            memory.
 *
 *  Returns:  A handle to a dib (hDIB) if successful.
 *            NULL if an error occurs.
 *
 * Comments:  BITMAPFILEHEADER is stripped off of the DIB.  Everything
 *            from the end of the BITMAPFILEHEADER structure on is
 *            returned in the global memory handle.
 *
 *
 * NOTE: The DIB API were not written to handle OS/2 DIBs, so this
 * function will reject any file that is not a Windows DIB.
 *
 *************************************************************************}

function ReadDIBFile(hFile: THandle): HDIB;
label
   ErrExit, ErrExitNoUnlock, OKExit;
var
   bmfHeader   : TBITMAPFILEHEADER;
   nNumColors  : UINT;                // Number of colors in table
   ihDIB       : THANDLE;
   hDIBtmp     : THANDLE;             // Used for GlobalRealloc() //MPB
   lpbi        : PBitmapInfoHeader;
   offBits     : DWORD;
   dwRead      : DWORD;
   buf         : pointer;
begin
   // Allocate memory for header & color table. We'll enlarge this
   // memory as needed.

   ihDIB := GlobalAlloc(GMEM_MOVEABLE, sizeof(TBITMAPINFOHEADER) +
           256 * sizeof(TRGBQUAD));

   if ihDIB=0 then begin
     Result := 0;
     exit;
   end;

   lpbi := PBITMAPINFOHEADER(GlobalLock(ihDIB));

   if lpbi=Pointer(0) then begin
       GlobalFree(ihDIB);
       Result := 0;
       exit;
   end;

   // read the BITMAPFILEHEADER from our file

   if not ReadFile(hFile, bmfHeader, sizeof (TBITMAPFILEHEADER),
           dwRead, POverlapped(0)) then
       goto ErrExit;

   if sizeof(TBITMAPFILEHEADER) <> dwRead then 
       goto ErrExit;

   if bmfHeader.bfType <> $4d42 then goto ErrExit; // 'BM'

   // read the BITMAPINFOHEADER

   if not ReadFile(hFile, LPSTR(lpbi)^, sizeof(TBITMAPINFOHEADER), dwRead,
           POverlapped(0)) then goto ErrExit;

   if (sizeof(TBITMAPINFOHEADER) <> dwRead) then goto ErrExit;

   // Check to see that it's a Windows DIB -- an OS/2 DIB would cause
   // strange problems with the rest of the DIB API since the fields
   // in the header are different and the color table entries are
   // smaller.
   //
   // If it's not a Windows DIB (e.g. if biSize is wrong), return NULL.

   if (lpbi^.biSize = sizeof(TBITMAPCOREHEADER)) then goto ErrExit;

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

   GlobalUnlock(ihDIB);
   hDIBtmp := GlobalReAlloc(ihDIB, lpbi^.biSize + nNumColors *
           sizeof(TRGBQUAD) + lpbi^.biSizeImage, 0);

   if (hDIBtmp = 0) then // can't resize buffer for loading
       goto ErrExitNoUnlock //MPB
   else
       ihDIB := hDIBtmp;

   lpbi := PBITMAPINFOHEADER(GlobalLock(ihDIB));

   // read the color table
   buf := LPSTR((lpbi)) + lpbi^.biSize;
   ReadFile (hFile, buf^,
           nNumColors * sizeof(TRGBQUAD), dwRead, POverlapped(0));

   // offset to the bits from start of DIB header

   offBits := lpbi^.biSize + nNumColors * sizeof(TRGBQUAD);

   // If the bfOffBits field is non-zero, then the bits might *not* be
   // directly following the color table in the file.  Use the value in
   // bfOffBits to seek the bits.

   if (bmfHeader.bfOffBits <> 0) then
       SetFilePointer(hFile, bmfHeader.bfOffBits, Pointer(0), FILE_BEGIN);

   buf := LPSTR(lpbi) + offBits;
   if (ReadFile(hFile, buf^, lpbi^.biSizeImage, dwRead, POverlapped(0))) then
       goto OKExit;


ErrExit:
   GlobalUnlock(ihDIB);

ErrExitNoUnlock:
   GlobalFree(ihDIB);
   Result := 0;
   exit;

OKExit:
   GlobalUnlock(ihDIB);
   Result := ihDIB;
   exit;
end;


{*************************************************************************
 *
 * CreateDIBPalette()
 *
 * Parameter:
 *
 * HDIB hDIB        - specifies the DIB
 *
 * Return Value:
 *
 * HPALETTE         - specifies the palette
 *
 * Description:
 *
 * This function creates a palette from a DIB by allocating memory for the
 * logical palette, reading and storing the colors from the DIB's color table
 * into the logical palette, creating a palette from this logical palette,
 * and then returning the palette's handle. This allows the DIB to be
 * displayed using the best possible colors (important for DIBs with 256 or
 * more colors).
 *
 ************************************************************************}

function CreateDIBPalette(phDIB: HDIB): HPALETTE;
var
   lpPal          : PLogPalette;
   hLogPal        : THandle;
   hPal           : HPALETTE;
   i, wNumColors  : integer;
   lpbi           : LPSTR;
   lpbmi          : PBitmapInfo;
begin
   hPal := 0;

   if phDIB=0 then begin
      Result := 0;
      exit;
   end;

   lpbi := GlobalLock(phDIB);
   lpbmi := PBitmapInfo(lpbi);
   wNumColors := DIBNumColors(lpbi);
   if wNumColors<>0 then begin
      hLogPal := GlobalAlloc(GHND, sizeof(TLOGPALETTE)+sizeof(TPALETTEENTRY)*wNumColors);
      if hLogPal=0 then begin
         GlobalUnlock(phDIB);
         Result := 0;
         exit;
      end;
      lpPal := PLogPalette(GlobalLock(hLogPal));
      lpPal^.palVersion := $0300;
      lpPal^.palNumEntries := wNumColors;

      for i := 0 to wNumColors-1 do begin
         lpPal^.palPalEntry[i].peRed   := lpbmi^.bmiColors[i].rgbRed;
         lpPal^.palPalEntry[i].peGreen := lpbmi^.bmiColors[i].rgbGreen;
         lpPal^.palPalEntry[i].peBlue  := lpbmi^.bmiColors[i].rgbBlue;
         lpPal^.palPalEntry[i].peFlags := 0;
      end;

      hPal := CreatePalette(lpPal^);
      GlobalUnlock(hLogPal);
      GlobalFree(hLogPal);
      if hPal=0 then begin
         Result := 0;
         exit;
      end;
   end;

   GlobalUnlock(phDIB);
   Result := hPal;
end;

{*************************************************************************
 *
 * PaintDIB()
 *
 * Parameters:
 *
 * iHDC hDC          - DC to do output to
 *
 * LPRECT lpDCRect  - rectangle on DC to do output to
 *
 * HDIB hDIB        - handle to global memory with a DIB spec
 *                    in it followed by the DIB bits
 *
 * LPRECT lpDIBRect - rectangle of DIB to output into lpDCRect
 *
 * Return Value:
 *
 * BOOL             - TRUE if DIB was drawn, FALSE otherwise
 *
 * Description:
 *   Painting routine for a DIB.  Calls StretchDIBits() or
 *   SetDIBitsToDevice() to paint the DIB.  The DIB is
 *   output to the specified DC, at the coordinates given
 *   in lpDCRect.  The area of the DIB to be output is
 *   given by lpDIBRect.
 *
 * NOTE: This function always selects the palette as background. Before
 * calling this function, be sure your palette is selected to desired
 * priority (foreground or background).
 *
 *
 ************************************************************************}

function PaintDIB(ihdc: HDC; lpDCRect: PRect; phDIB: HDIB; lpDIBRect: PRect; hPal: HPALETTE): integer;
var
   lpDIBHdr    : LPSTR;
   lpDIBBits   : LPSTR;
   bSuccess    : integer;
   hOldPal     : HPALETTE;
begin
   hOldPal  := 0;
   // Check for valid DIB handle

   if (phDIB = 0) then begin
      Result := 0;
      exit;
   end;

   // Lock down the DIB, and get a pointer to the beginning of the bit
   // buffer

   lpDIBHdr  := GlobalLock(phDIB);
   lpDIBBits := FindDIBits(lpDIBHdr);

   // Select and realize our palette as background

   if (hPal<>0) then begin
      hOldPal := SelectPalette(ihDC, hPal, TRUE);     // I changed this from TRUE to FALSE to fix Palette Problems -bpz
      RealizePalette(ihDC);
   end;

   // Make sure to use the stretching mode best for color pictures

   SetStretchBltMode(ihDC, COLORONCOLOR);

   // Determine whether to call StretchDIBits() or SetDIBitsToDevice()

   if ((RECTWIDTH(lpDCRect) = RECTWIDTH(lpDIBRect)) and
           (RECTHEIGHT(lpDCRect) = RECTHEIGHT(lpDIBRect))) then
      bSuccess := SetDIBitsToDevice(ihDC, lpDCRect^.left, lpDCRect^.top,
         RECTWIDTH(lpDCRect), RECTHEIGHT(lpDCRect), lpDIBRect^.left,
         DIBHeight(lpDIBHdr) - lpDIBRect^.top -
         RECTHEIGHT(lpDIBRect), 0, DIBHeight(lpDIBHdr), lpDIBBits,
         PBITMAPINFO(lpDIBHdr)^, DIB_RGB_COLORS)
   else
      bSuccess := StretchDIBits(ihDC, lpDCRect^.left, lpDCRect^.top,
         RECTWIDTH(lpDCRect), RECTHEIGHT(lpDCRect), lpDIBRect^.left,
         lpDIBRect^.top, RECTWIDTH(lpDIBRect), RECTHEIGHT(lpDIBRect),
         lpDIBBits, PBITMAPINFO(lpDIBHdr)^, DIB_RGB_COLORS, SRCCOPY);

   // Unlock the memory block

   GlobalUnlock(phDIB);

   // Reselect old palette

   if (hOldPal<>0) then
      SelectPalette(ihDC, hOldPal, FALSE);

   // Return with success/fail flag
   Result := bSuccess;
end;

end.
