unit Misc;

interface

uses
	Windows, SysUtils{, OLE2};

function szFormatLastError( dwLastError: DWORD;
	 szOutputBuffer: PChar; dwSizeofOutputBuffer: DWORD ): PChar;

function FormatLastError( dwLastError: DWORD ): string;

function DelphiIsRunning : boolean;

{C++ routines}
function iscntrl( ch: char ):Boolean;
function isalpha( ch: char ):Boolean;
function isdigit( ch: char ):Boolean;
function strtoul(pszBuffer: PChar; var ppszBuffer: PChar; Base: Integer): Integer;
//procedure mbstowcs( szw: POleStr; m_pszPath: PChar; len: Integer{sizeof(szw)});

const
	MAXOUTPUTSTRINGLENGTH = 4096;

implementation

function MAKELANGID( usPrimaryLanguage, usSubLanguage: Byte ): WORD;
begin
	Result := ((usSubLanguage shl 10) + usPrimaryLanguage);
end;

function FormatLastError( dwLastError: DWORD ): string;
var
	szTemp:	PChar;
begin
	szTemp := szFormatLastError( dwLastError, nil, 0 );
	Result := StrPas( szTemp );
	LocalFree( Integer(szTemp) );
end;

//
//  FUNCTION: FormatLastError(DWORD, LPSTR, DWORD)
//
//  PURPOSE: Pretty print a system error to a string.
//
//  PARAMETERS:
//    dwLastError          - Actual error code to decipher.
//    szOutputBuffer       - String buffer to pretty print to.
//    dwSizeofOutputBuffer - Size of String buffer.
//
//  RETURN VALUE:
//    Returns the buffer printed to.
//
//  COMMENTS:
//    If szOutputBuffer isn't big enough to hold the whole string,
//    then the string gets truncated to fit the buffer.
//
//    If szOutputBuffer == NULL, then dwSizeofOutputBuffer
//    is ignored, a buffer 'big enough' is LocalAlloc()d and
//    a pointer to it is returned.  However, its *very* important
//    that this pointer be LocalFree()d by the calling application.
//
//
function szFormatLastError( dwLastError: DWORD;
	 szOutputBuffer: PChar; dwSizeofOutputBuffer: DWORD ): PChar;
var
	dwRetFM,
	dwFlags: 					DWORD;
	dwGetLastError: 			DWORD;
//	szFormatMessageError:	LPSTR;
	szFormatMessageError:	string;
begin
	dwFlags := FORMAT_MESSAGE_FROM_SYSTEM;

	 // Should we allocate a buffer?
	 if szOutputBuffer = nil then
	 begin
			// Actually, we make FormatMessage allocate the buffer, if needed.
			dwFlags := dwFlags + FORMAT_MESSAGE_ALLOCATE_BUFFER;

			// minimum size FormatMessage should allocate.
			dwSizeofOutputBuffer := 1;
	 end;

	 // Make FormatMessage pretty print the system error.
(*
	 dwRetFM := FormatMessage(
			dwFlags, nil, dwLastError,
			MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
			PAnsiChar(@szOutputBuffer), dwSizeofOutputBuffer,
			nil);
*)

	 dwRetFM := FormatMessage(
			dwFlags, nil, dwLastError,
			MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
			@szOutputBuffer, dwSizeofOutputBuffer,
			nil);

	 // FormatMessage failed to print the error.
	 if dwRetFM = 0 then
	 begin
		  dwGetLastError := GetLastError;

		  // If we asked FormatMessage to allocate a buffer, then it
		  // might have allocated one.  Lets be safe and LocalFree it.
		  if (dwFlags and FORMAT_MESSAGE_ALLOCATE_BUFFER) <> 0 then
		  begin
				LocalFree(HLOCAL(szOutputBuffer));

				szOutputBuffer := PChar(LocalAlloc( LPTR, MAXOUTPUTSTRINGLENGTH ));
{				dwSizeofOutputBuffer := MAXOUTPUTSTRINGLENGTH;}

				if szOutputBuffer = nil then
				begin
					 OutputDebugString( 'Out of memory trying to FormatLastError' );
					 result := nil;
					 Exit;
				end;
		  end;

//		  szFormatMessageError := PChar(IntToStr(dwGetLastError));{
		  szFormatMessageError := IntToStr(dwGetLastError);{
				FormatLastError( dwGetLastError, nil, 0 );}

{
		  if szFormatMessageError = nil then
		  begin
				Result := nil;
				Exit;
		  end;
}

			wsprintf(szOutputBuffer,
				PChar('FormatMessage failed on error '+IntToStr(dwLastError)+' for the following reason: '+
					szFormatMessageError) );

//		  LocalFree( HLOCAL(szFormatMessageError) );
	 end;

	 Result := szOutputBuffer;
end;

function DelphiIsRunning : boolean;
var
	H1, H2, H3, H4 : Hwnd;
const
	A1 : array[0..12] of char = 'TApplication'#0;
	A2 : array[0..15] of char = 'TAlignPalette'#0;
	A3 : array[0..18] of char = 'TPropertyInspector'#0;
	A4 : array[0..11] of char = 'TAppBuilder'#0;
	T1 : array[0..6] of char = 'Delphi'#0;
begin
	H1 := FindWindow(A1, nil{T1});
	H2 := FindWindow(A2, nil);
	H3 := FindWindow(A3, nil);
	H4 := FindWindow(A4, nil);
	Result := (H1 <> 0) and (H2 <> 0) and
						(H3 <> 0) and (H4 <> 0);
end;

//
// C++ routines
//
(*
procedure mbstowcs( szw: POleStr; m_pszPath: PChar; len: Integer{sizeof(szw)});
begin
MultiByteToWideChar(
		CP_ACP,	// ANSI code page
		0,	// character-type options
		m_pszPath,	// address of string to map
		Length(m_pszPath), 	// number of characters in string
		szw,  // address of wide-character buffer
		len  	// size of buffer
	 );
end;
*)

function iscntrl( ch: char ):Boolean;
begin
//	Result := ch in [#0..#31,#127];
	Result := CharInSet( ch, [#0..#31,#127] );
end;

function isalpha( ch: char ):Boolean;
begin
//	Result := ch in ['a'..'z','A'..'Z'];
	Result := CharInSet( ch, ['a'..'z','A'..'Z'] );
end;

function isdigit( ch: char ):Boolean;
begin
//	Result := ch in ['0'..'9'];
	Result := CharInSet( ch, ['0'..'9'] );
end;

function strtoul(pszBuffer: PChar; var ppszBuffer: PChar; Base: Integer): Integer;
var
	str: string;
begin
	str := '';
	while isdigit( pszBuffer^ ) do
	begin
		str := str + pszBuffer^;
		Inc( pszBuffer );
	end;
	ppszBuffer := pszBuffer;
	Result := StrToInt( str );
end;

end.
