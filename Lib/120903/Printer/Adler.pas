unit Adler;

{* adler32.c -- compute the Adler-32 checksum of a data stream
 * Copyright (C) 1995-1996 Mark Adler
 * For conditions of distribution and use, see copyright notice in zlib.h
}

interface

   function Adler32(Adler: longint; buf: PChar; len: longint): longint;

   function CheckSumFile(const FileName: string): integer;


implementation

uses SysUtils, Classes;

{$O+,W-}

function Adler32(Adler: longint; buf: PChar; len: longint): longint;
const
   BASE : longint = 65521;    // largest prime smaller than 65536
   NMAX = 5552;               // NMAX is the largest n such that 255n(n+1)/2 + (n+1)(BASE-1) <= 2^32-1
var
   s1, s2   : longint;
   k        : integer;

   procedure Do1(buf: PChar; i: integer);
   begin
      s1 := s1 + byte(buf[i]);
      s2 := s2 + s1;
   end;

   procedure Do2(buf: PChar; i: integer);
   begin
      Do1(buf, i);
      Do1(buf, i+1);
   end;

   procedure Do4(buf: PChar; i: integer);
   begin
      Do2(buf, i);
      Do2(buf, i+2);
   end;

   procedure Do8(buf: PChar; i: integer);
   begin
      Do4(buf, i);
      Do4(buf, i+4);
   end;

   procedure Do16(buf: PChar);
   begin
      Do8(buf, 0);
      Do8(buf, 8);
   end;

begin
   s1 := adler and $ffff;
   s2 := (adler SHR 16) and $ffff;

   if buf = nil then begin
      Result := 1;
      exit;
   end;

   while (len > 0) do begin
      if (len < NMAX) then
         k := len
      else
         k := NMAX;

      len := len - k;

      while (k >= 16) do begin
         DO16(buf);
         buf := buf + 16;
         k := k - 16;
      end;

      if (k <> 0) then repeat
         s1 := s1 + byte(buf[0]);
         Inc(buf);
         s2 := s2 + s1;
         k := k - 1;
      until k = 0;

      s1 := s1 mod BASE;
      s2 := s2 mod BASE;
   end;

   Result := (s2 shl 16) or s1;
end;


function CheckSumFile(const FileName: string): integer;
const
   BUFSIZE = $10000;
var
   fs       : TFileStream;
   buf      : array[0..BUFSIZE] of char;
   NumRead  : integer;
begin
   Result := 0;
   fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
   try
      repeat
         NumRead := fs.Read(buf, BUFSIZE);
         if NumRead > 0 then begin
            Result := Adler32(Result, @buf, NumRead);
         end;
      until NumRead < BUFSIZE;
   finally
      fs.Free;
   end;
end;



end.
