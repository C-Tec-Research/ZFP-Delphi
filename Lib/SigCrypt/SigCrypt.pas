unit SigCrypt;

interface

uses
  DCPCrypt2,
  DCPrijndael,
  System.SysUtils;

type
  TDCP_rijndaelKey = array[ 0..15] of byte;
  TDCP_rijndaelBlock = array[ 0..15] of byte;

  TXMegaCrypt =  class( TDCP_rijndael )
  private
    fKey: TDCP_rijndaelKey;
    procedure SetKey(const Value: TDCP_rijndaelKey);
  {
    Rolf's implementation

    var
    Cipher2   : TDCP_rijndael;
...
    Cipher2 := TDCP_rijndael.create(nil);
...
    Cipher2.Init(iniVect, 128, @Key);
    Cipher2.EncryptCBC(@source, dest, count);

    Here is example from author
  procedure TForm1.btnEncryptClick(Sender: TObject);
  var
    i: integer;
    Cipher: TDCP_rc4;
    KeyStr: string;
  begin
    KeyStr:= '';
    if InputQuery('Passphrase','Enter passphrase',KeyStr) then  // get the passphrase
    begin
      Cipher:= TDCP_rc4.Create(Self);
      Cipher.InitStr(KeyStr,TDCP_sha1);         // initialize the cipher with a hash of the passphrase
      for i:= 0 to Memo1.Lines.Count-1 do       // encrypt the contents of the memo
        Memo1.Lines[i]:= Cipher.EncryptString(Memo1.Lines[i]);
      Cipher.Burn;
      Cipher.Free;
    end;
  end;

  procedure TForm1.btnDecryptClick(Sender: TObject);
  var
    i: integer;
    Cipher: TDCP_rc4;
    KeyStr: string;
  begin
    KeyStr:= '';
    if InputQuery('Passphrase','Enter passphrase',KeyStr) then  // get the passphrase
    begin
      Cipher:= TDCP_rc4.Create(Self);
      Cipher.InitStr(KeyStr,TDCP_sha1);         // initialize the cipher with a hash of the passphrase
      for i:= 0 to Memo1.Lines.Count-1 do       // decrypt the contents of the memo
        Memo1.Lines[i]:= Cipher.DecryptString(Memo1.Lines[i]);
      Cipher.Burn;
      Cipher.Free;
    end;
  end;

  Uses 128 bit keys = 16 bytes

  }
  protected

  public
    {
    We are not interested in using like a component, so Create takes no paramaters
    and calls inherited Create( nil );
    }
    constructor Create; reintroduce;

    {
    We can either generate a random key or assign a stored Key
    }
    property Key : TDCP_rijndaelKey
             read fKey
             write SetKey;

    function CreateKey : TDCP_rijndaelKey;

    function BlockToHex( const pBlock : TDCP_rijndaelBlock ) : string;
    function HexToBlock( var pHex : string; var pBlock : TDCP_rijndaelBlock ) : integer;
  end;

  TSigCrypt = class
  private
    fLength : integer;
    fLengthPos : integer;
    fSeed : string;
    fValues : string;
    fModV, fModS, fModI : integer;
  const
    cValues = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+=-_!@#~/\"£$%^&*(){}[]"''|`';
  protected

  public
    constructor Create( const pLength, pLengthPos : integer; const pSeed : string );
    function Encrypt( const pString : string ) : string;
    function Decrypt( const pString : string ) : string;
  end;

  TSigCryptFullChar = UInt32;
  TSigCryptFullValue = array of TSigCryptFullChar;

  TSigCryptFull = class  // similar but for full 32 bit words
  private
    fCurr1, fCurr2 : TSigCryptFullChar;
    fSave1, fSave2 : TSigCryptFullChar;
    fBuffer : TSigCryptFullValue;
    procedure Decrypt(const Value: TSigCryptFullValue);
    function Encrypt: TSigCryptFullValue;
  protected
  public
    constructor Create;
    function Random : UInt32;
    procedure Clear;
    procedure Add( const Value : TSigCryptFullChar ); overload;
    procedure Add( const Value : string ); overload;

    function RemoveC : TSigCryptFullChar;
    function RemoveS : string;

    property Crypt : TSigCryptFullValue
             read Encrypt
             write Decrypt;
  end;

implementation



{ TSigCrypt }

constructor TSigCrypt.Create(const pLength, pLengthPos: integer; const pSeed: string);
var
  i, iMod: Integer;
begin
  inherited Create;
  fLength := pLength;
  fLengthPos := pLengthPos;
  fSeed := pSeed;
  fModV := Length( cValues );
  fModS := Length( fSeed );
  iMod := fLength - 1;
  fValues := '';
  fModI := 1;
  for i := 1 to fModV do
  begin
    fValues := fValues + cValues[ iMod + 1 ];
    iMod := (iMod * fLength) mod fModV; // shuffle the allowable values string
    fModI := (fModI * fLength) mod fModV;
  end;
  Randomize;
end;

function TSigCrypt.Decrypt(const pString: string): string;
var
  iLength : char;
  iLengthV : integer;
  i, j, k : integer;
  iTemp : string;
begin
  // extract length char
  iLength := pString[ fLengthPos ];
  iLengthV := Pos( iLength, fValues ) - 1;
  iLengthV := (iLengthV * fModI ) mod fModV;
  // now ceate the normalised string
  iTemp := Copy( pString, 1, fLengthPos ) + Copy( pstring, fLength + 1 );
  Result := '';
  // some of the string will be rubbish
  for i := 1 to iLengthV do
  begin
    j := Pos( iTemp[ i ], fValues ) - 1;
    dec( j, iLengthV );
    if j < 0 then
    begin
      inc( j, fModV );
    end;
    k := Pos( fSeed[ ((i - 1) mod fModS)  + 1 ], fValues );
    dec( j, k );
    if j < 0 then
    begin
      inc( j, fModV );
    end;
    Result := Result + fValues[ j + 1 ];
  end;
end;

function TSigCrypt.Encrypt(const pString: string): string;
var
  iLength : char;
  iLengthV : integer;
  i, j : integer;
  iTemp : string;
begin
  iLengthV := (Length( pString ) * fLengthPos) mod fModV;
  iLength := fValues[ iLengthV + 1 ];
  iTemp := '';
  for i := 1 to Length( pString ) do
  begin
    j := Pos( pString[ i ], fValues ) + Pos( fSeed[ ((i - 1) mod fModS) + 1 ], fValues );
    j := ( j + iLengthV) mod  fModV;
    iTemp := iTemp + fValues[ j + 1 ];
  end;
  // pad to length - 1
  for i := Length( pString ) + 1 to fLength do
  begin
    j := Random( fModV );
    iTemp := iTemp + fValues[ 1 + j ];
  end;
  // now put length byte where it should be
  Result := Copy( iTemp, 1, fLengthPos ) + iLength + Copy( iTemp, fLengthPos + 1 );
end;

{ TSigCryptFull }

procedure TSigCryptFull.Add(const Value: TSigCryptFullChar);
var
  i : integer;
begin
  i := Length( fBuffer );
  SetLength( fBuffer, i + 1 );
  fBuffer[ i ] := Value;
end;

procedure TSigCryptFull.Add(const Value: string);
var
  i : integer;
  iW : Uint32;
  j : integer;
begin
  j := 0;
  i := 1;
  iW := Length( Value );
  while j < Length( Value ) do
  begin
    inc( j );
    inc( iW, Ord( Value[ j ] ) shl (16 * i) );
    inc( i );
    if i = 2 then
    begin
      i := 0;
      Add( iW );
      iW := 0;
    end;
  end;
  // if not exactly divisible by 4...
  if i <> 0 then
  begin
    Add( iW );
  end;
end;

procedure TSigCryptFull.Clear;
begin
  SetLength( fBuffer, 2 ); // for key
end;

constructor TSigCryptFull.Create;
begin
  inherited Create;
  Clear;
  System.Randomize;
  fCurr1 := 1 + System.Random( $FFFFFFF );
  fCurr2 := 1 + System.Random( $FFFFFFF );
end;

procedure TSigCryptFull.Decrypt(const Value: TSigCryptFullValue);
var
  i : integer;
begin
  Clear;
  fBuffer := Value;
  fSave1 := fCurr1;
  fSave2 := fCurr2;
  // the first 2 values contain real seeds
  fCurr1 := not fBuffer[ 0 ];
  fCurr2 := fBuffer[ 1 ] xor fCurr1;
  for i := 2 to Length( fBuffer ) - 1 do
  begin
    fBuffer[ i ] := fBuffer[ i ] xor Random;
  end;
  fCurr1 := fSave1;
  fCurr2 := fSave2;
  RemoveC; // get rid of seed from buffer
  RemoveC; // get rid of seed from buffer
end;

function TSigCryptFull.Encrypt: TSigCryptFullValue;
var
  i: Integer;
begin
  Result := fBuffer;
  // the first 2 values contain real seeds
  Result[ 0 ] := not fCurr1;
  Result[ 1 ] := fCurr2 xor fCurr1;
  for i := 2 to Length( Result ) - 1 do
  begin
    Result[ i ] := Result[ i ] xor Random;
  end;
end;

function TSigCryptFull.Random: UInt32;
begin
  fCurr1 := 36969 * ( fCurr1 and 65535 ) + ( fCurr1 shr 16 );
  fCurr2 := 18000 * ( fCurr2 and 65535 ) + ( fCurr2 shr 16 );
  Result := (fCurr1 shl 16) + fCurr2;
end;

function TSigCryptFull.RemoveC: TSigCryptFullChar;
begin
  Result := fBuffer[ 0 ];
  fBuffer := Copy( fBuffer, 1 );
end;

function TSigCryptFull.RemoveS: string;
var
  i, iL : integer;
  iW : Uint32;
  j : integer;
  iC : char;
begin
  j := 0;
  i := 1;
  iW := RemoveC;
  iL := iW and $FFFF;
  iC := char( iW shr 16 );
  Result := iC;
  while i < iL do
  begin
    if (j = 0 ) then
    begin
      j := 1;
      iW := RemoveC;
    end
    else
    begin
      dec( j );
    end;
    Result := Result + char( iW and $FFFF );
    iW := iW shr 16;
    inc( i );
  end;
end;

{ TXMegaCrypt }

function TXMegaCrypt.BlockToHex(const pBlock: TDCP_rijndaelBlock): string;
begin
  raise Exception.Create('To do');
end;

constructor TXMegaCrypt.Create;
begin
  inherited Create( nil );
end;

function TXMegaCrypt.CreateKey: TDCP_rijndaelKey;
var
  i: Integer;
begin
  Burn;
  Randomize;
  for i := 0 to 15 do
  begin
    fKey[ i ] := Byte( System.Random( 256 ) );
  end;
  Init( fKey, 128, nil );
  Result := fKey;
end;

function TXMegaCrypt.HexToBlock(var pHex: string;
  var pBlock: TDCP_rijndaelBlock): integer;
begin
  raise Exception.Create('To do');
end;

procedure TXMegaCrypt.SetKey(const Value: TDCP_rijndaelKey);
begin
  fKey := Value;
  Burn;
  Init( fKey, 128, nil );
end;

end.
