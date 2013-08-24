{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  AnsiString implementation for use with ICS. Replace the builtin
              AnsiString type which doesn't exists in XE5 and upper.
              There are a number of support routines so that this suopport is
              transparent even when used on older Delphi versions natively
              supporting AnsiString.
Creation:     Augustus 13, 2013
Version:      1.00
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 2013 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium.
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Updates:


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit OverbyteIcsAnsiStrings;

{$I Include\OverbyteIcsDefs.inc}

interface

uses
  SysUtils
{$IFDEF COMPILER19_UP}
  ,System.Generics.Defaults
  ,System.Generics.Collections
{$ENDIF}
  ;

const
    LowOfString = {$IF CompilerVersion >= 24} Low(String) {$ELSE} 1 {$IFEND};

type
{$WARN SYMBOL_DEPRECATED OFF}
    TUnicodeCharSet = TSysCharSet;
{$WARN SYMBOL_DEPRECATED ON}
{$IFDEF ANDROID}
type
{$IFDEF COMPILER19_UP}

type
    AnsiChar = record
        Buffer : Byte;
        class operator Implicit(A: Char) : AnsiChar;
        class operator Implicit(A: String) : AnsiChar;
        class operator Implicit(A: Integer) : AnsiChar;
        class operator Equal(A: AnsiChar; B:AnsiChar) : Boolean;
        class operator NotEqual(A: AnsiChar; B:AnsiChar) : Boolean;
    end;

    PAnsiChar = ^AnsiChar;


    AnsiString = record
    private
        function  GetByte(NIndex: Integer): AnsiChar;
        procedure SetByte(NIndex: Integer; B : AnsiChar);
    public
        Buffer : TArray<Byte>;
        function  Length : Integer;
        procedure SetLength(L : Integer);
        class operator Implicit(A: Char) : AnsiString;
        class operator Implicit(A: AnsiChar) : AnsiString;
        class operator Implicit(A: String) : AnsiString;
        class operator Implicit(A: AnsiString) : String;
        class operator Implicit(A: AnsiString) : PAnsiChar;
        class operator Equal(A: AnsiString; B: Char) : Boolean;
        class operator NotEqual(A: AnsiString; B: Char) : Boolean;
        class operator Equal(A: AnsiString; B: AnsiString) : Boolean;
        class operator NotEqual(A: AnsiString; B: AnsiString) : Boolean;
        property Item[NIndex : Integer] : AnsiChar read  GetByte
                                                   write SetByte; default;
    end;

    // Very incomplete!
    RawByteString = record
    private
        function  GetByte(NIndex: Integer): AnsiChar;
        procedure SetByte(NIndex: Integer; B : AnsiChar);
    public
        Buffer : TArray<Byte>;
        function  Length : Integer;
        procedure SetLength(L : Integer);
        class operator Implicit(A: String) : RawByteString;
        property Item[NIndex : Integer] : AnsiChar read  GetByte
                                                   write SetByte; default;
    end;

    // Well, better than nothing :-(
    UTF8String    = type AnsiString;

{$ENDIF}
{$ENDIF}

function  AnsiLength(const S : AnsiString) : Integer;
procedure AnsiSetLength(var S : AnsiString; Len : Integer);
function  AnsiCharInSet(const C : AnsiChar; const S : TUnicodeCharSet) : Boolean;
function  AnsiOrd(const C : AnsiChar) : Integer;
// Convert bytes to their ascii representation
function  AnsiBytesToHexUpper(Bytes : PByte; Count : Integer) : AnsiString;
function  AnsiBytesToHexLower(Bytes : PByte; Count : Integer) : AnsiString;
function  AnsiBytesToRawByteHexLower(Bytes : PByte; Cnt : Integer) : RawByteString;

function  RawByteStringLength(const S: RawByteString) : Integer;
procedure RawByteStringSetLength(var S: RawByteString; Len : Integer);

{$IFDEF ANSISTRINGS_SELF_TEST}
function AnsiStringsUnitTest(out ErrMsg : String) : Boolean;
{$ENDIF}

implementation

function ByteToAsciiCodeUpper(N : Byte) : Byte;
begin
     if N < 10 then
         Result := Ord('0') + N
     else
         Result := Ord('A') + N - 10;
end;

function ByteToAsciiCodeLower(N : Byte) : Byte;
begin
     if N > 15 then
         raise ERangeError.Create('ByteToAsciiCodeLower');
     if N < 10 then
         Result := Ord('0') + N
     else
         Result := Ord('a') + N - 10;
end;

{$IFDEF ANDROID}

// Convert bytes to their ascii representation (uppercase)
function AnsiBytesToHexUpper(
    Bytes : PByte;
    Count : Integer) : AnsiString;
var
    I : Integer;
begin
    if Count = 0 then
        Result.SetLength(0)
    else if Count < 0 then
        raise ERangeError.Create('AnsiBytesToHexUpper count negative')
    else if Bytes = nil then
        raise ERangeError.Create('AnsiBytesToHexUpper nil pointer')
    else begin
        Result.SetLength(Count + Count);
        I := 0;
        while Count > 0 do begin
            Result.Buffer[I] := ByteToAsciiCodeUpper((Bytes^ shr 4) and 15);
            Inc(I);
            Result.Buffer[I] := ByteToAsciiCodeUpper(Bytes^ and 15);
            Inc(I);
            Dec(Count);
            Inc(Bytes);
        end;
    end;
end;

// Convert bytes to their ascii representation (lowercase)
function AnsiBytesToHexLower(
    Bytes : PByte;
    Count : Integer) : AnsiString;
var
    I : Integer;
begin
    if Count = 0 then
        Result.SetLength(0)
    else if Count < 0 then
        raise ERangeError.Create('AnsiBytesToHexLower count negative')
    else if Bytes = nil then
        raise ERangeError.Create('AnsiBytesToHexLower nil pointer')
    else begin
        Result.SetLength(Count + Count);
        I := 0;
        while Count > 0 do begin
            Result.Buffer[I] := ByteToAsciiCodeLower((Bytes^ shr 4) and 15);
            Inc(I);
            Result.Buffer[I] := ByteToAsciiCodeLower(Bytes^ and 15);
            Inc(I);
            Dec(Count);
            Inc(Bytes);
        end;
    end;
end;

function AnsiBytesToRawByteHexLower(
    Bytes : PByte;
    Cnt   : Integer) : RawByteString;
var
    I : Integer;
begin
    Result.SetLength(Cnt + Cnt);
    I := 0;
    while Cnt > 0 do begin
        Result.Buffer[I] := ByteToAsciiCodeLower((Bytes^ shr 4) and 15);
        Inc(I);
        Result.Buffer[I] := ByteToAsciiCodeLower(Bytes^ and 15);
        Inc(I);
        Dec(Cnt);
        Inc(Bytes);
    end;
end;

{ AnsiString }

function AnsiLength(const S : AnsiString) : Integer;
begin
    Result := S.Length;
end;

procedure AnsiSetLength(var S : AnsiString; Len : Integer);
begin
    S.SetLength(Len);
end;

function RawByteStringLength(const S: RawByteString) : Integer;
begin
    Result := S.Length;
end;

procedure RawByteStringSetLength(var S: RawByteString; Len : Integer);
begin
    SetLength(S.Buffer, Len);
end;

function AnsiCharInSet(const C : AnsiChar; const S : TUnicodeCharSet) : Boolean;
var
    Ch : Char;
begin
    for Ch in S do begin
        if Ord(Ch) = C.Buffer then begin
            Result := TRUE;
            Exit;
        end;
    end;
    Result := FALSE;
end;

function  AnsiOrd(const C : AnsiChar) : Integer;
begin
    Result := C.Buffer;
end;

function AnsiString.Length: Integer;
begin
    // We always have an extra byte for terminating nul byte
    // But the buffer may be not allocated yet
    Result := System.Length(Buffer) - 1;
    if Result < 0 then begin
        System.SetLength(Buffer, 1);
        Result := 0;
    end;
end;

class operator AnsiString.NotEqual(A: AnsiString; B: Char): Boolean;
begin
    if A.Length <> 1 then
        Result := TRUE
    else
        Result := A.Buffer[0] <> Ord(B);
end;

procedure AnsiString.SetByte(NIndex: Integer; B: AnsiChar);
begin
    // We use 1 based index
    Buffer[NIndex - 1] := Byte(B);
end;

procedure AnsiString.SetLength(L: Integer);
begin
    // We always add 1 for the nul terminating byte
    System.SetLength(Buffer, L + 1);
    Buffer[L] := 0;   // Set the nul terminating byte
end;

class operator AnsiString.Equal(A, B: AnsiString): Boolean;
var
    LA, LB : Integer;
    I      : Integer;
begin
    LA := A.Length;
    LB := B.Length;
    if LA <> LB then
        Exit(FALSE);
    for I := Low(A.Buffer) to High(A.Buffer) - 1 do begin // Ignore nul term.
        if A.Buffer[I] <> B.Buffer[I] then
            Exit(FALSE);
    end;
    Result := TRUE;
end;

class operator AnsiString.NotEqual(A, B: AnsiString): Boolean;
begin
    Result := not (A = B);
end;

class operator AnsiString.Equal(A: AnsiString; B: Char): Boolean;
begin
    if A.Length <> 1 then
        Result := FALSE
    else
        Result := A.Buffer[0] = Ord(B);
end;

function AnsiString.GetByte(NIndex: Integer): AnsiChar;
begin
    // We use 1 based index
    Result.Buffer := Buffer[NIndex - 1];
end;

class operator AnsiString.Implicit(A: AnsiString): String;
var
    L : Integer;
    I : Integer;
begin
    Result := '';
    L := A.Length;
    if L > 0 then begin
        for I := 0 to L - 1 do
            Result := Result + Char(A.Buffer[I]);
    end;
end;

class operator AnsiString.Implicit(A: String) : AnsiString;
var
    I   : Integer;
    Len : Integer;
begin
    Len := System.Length(A);
    Result.SetLength(Len);
    if Len > 0 then begin
        for I := 0 to Len - 1 do
            Result.Buffer[I] := Ord(A[I + LowOfString]);
    end;
    // Always terminate by a nul byte
    Result.Buffer[Len] := 0;
end;

class operator AnsiString.Implicit(A: AnsiString): PAnsiChar;
begin
    if A.Length = 0 then
        Result := nil
    else
        Result := @A.Buffer[0];
end;

class operator AnsiString.Implicit(A: AnsiChar): AnsiString;
begin
    Result.SetLength(1);
    Result.Buffer[0] := A.Buffer;
end;

class operator AnsiString.Implicit(A: Char): AnsiString;
begin
    Result.SetLength(1);
    Result.Buffer[0] := Ord(A);
end;

{ AnsiChar }

class operator AnsiChar.Implicit(A: String): AnsiChar;
begin
    if Length(A) <> 1 then
        raise ERangeError.Create('String length should be one');
    Result.Buffer := Ord(A[LowOfString]);
end;

class operator AnsiChar.Equal(A, B: AnsiChar): Boolean;
begin
    Result := A.Buffer = B.Buffer;
end;

class operator AnsiChar.Implicit(A: Char): AnsiChar;
begin
   Result.Buffer := Ord(A);
end;

class operator AnsiChar.NotEqual(A, B: AnsiChar): Boolean;
begin
    Result := A.Buffer <> B.Buffer;
end;

class operator AnsiChar.Implicit(A: Integer) : AnsiChar;
begin
    Result.Buffer := A;
end;

{ RawByteString }

function RawByteString.GetByte(NIndex: Integer): AnsiChar;
begin
    Result.Buffer := Buffer[NIndex - 1];
end;

procedure RawByteString.SetByte(NIndex: Integer; B: AnsiChar);
begin
    Buffer[NIndex - 1] := Byte(B);
end;

class operator RawByteString.Implicit(A: String): RawByteString;
var
    I   : Integer;
    Len : Integer;
begin
    Len := System.Length(A);
    Result.SetLength(Len);
    if Len > 0 then begin
        for I := 0 to Len - 1 do
            Result.Buffer[I] := Ord(A[I + LowOfString]);
    end;
    // Always terminate by a nul byte
    Result.Buffer[Len] := 0;
end;

function RawByteString.Length: Integer;
begin
    // We always have an extra byte for terminating nul byte
    // But the buffer may be not allocated yet
    Result := System.Length(Buffer) - 1;
    if Result < 0 then begin
        System.SetLength(Buffer, 1);
        Result := 0;
    end;
end;

procedure RawByteString.SetLength(L: Integer);
begin
    // We always have an extra byte for terminating nul byte
    System.SetLength(Buffer, L + 1);
    Buffer[L] := 0;
end;


{$ENDIF}

{$IFNDEF ANDROID}
function  AnsiLength(const S : AnsiString) : Integer;
begin
    Result := Length(S);
end;

procedure AnsiSetLength(var S : AnsiString; Len : Integer);
begin
    SetLength(S, Len);
end;

function RawByteStringLength(const S: RawByteString) : Integer;
begin
    Result := Length(S);
end;

procedure RawByteStringSetLength(var S: RawByteString; Len : Integer);
begin
    SetLength(S, Len);
end;

function  AnsiCharInSet(const C : AnsiChar; const S : TUnicodeCharSet) : Boolean;
begin
    Result := CharInSet(C, S);
end;

function  AnsiOrd(const C : AnsiChar) : Integer;
begin
    Result := Ord(C);
end;

// Convert bytes to their ascii representation (uppercase)
function AnsiBytesToHexUpper(
    Bytes : PByte;
    Count : Integer) : AnsiString;
var
    I : Integer;
begin
    SetLength(Result, Count + Count);
    I := 1;
    while Count > 0 do begin
        Result[I] := AnsiChar(ByteToAsciiCodeUpper((Bytes^ shr 4) and 15));
        Inc(I);
        Result[I] := AnsiChar(ByteToAsciiCodeUpper(Bytes^ and 15));
        Inc(I);
        Dec(Count);
        Inc(Bytes);
    end;
end;

// Convert bytes to their ascii representation (lowercase)
function AnsiBytesToHexLower(
    Bytes : PByte;
    Count : Integer) : AnsiString;
var
    I : Integer;
begin
    SetLength(Result, Count + Count);
    I := 1;
    while Count > 0 do begin
        Result[I] := AnsiChar(ByteToAsciiCodeLower((Bytes^ shr 4) and 15));
        Inc(I);
        Result[I] := AnsiChar(ByteToAsciiCodeLower(Bytes^ and 15));
        Inc(I);
        Dec(Count);
        Inc(Bytes);
    end;
end;

function AnsiBytesToRawByteHexLower(Bytes : PByte; Cnt : Integer) : RawByteString;
var
    I : Integer;
begin
    SetLength(Result, Cnt + Cnt);
    I := 0;
    while Cnt > 0 do begin
        Result[I] := AnsiChar(ByteToAsciiCodeLower((Bytes^ shr 4) and 15));
        Inc(I);
        Result[I] := AnsiChar(ByteToAsciiCodeLower(Bytes^ and 15));
        Inc(I);
        Dec(Cnt);
        Inc(Bytes);
    end;
end;

{$ENDIF}

{$IFDEF ANSISTRINGS_SELF_TEST}
// Returns FALSE if all tests are passed. Returns TRUE if one test failed
function AnsiStringsUnitTest(out ErrMsg : String) : Boolean;
var
    AChar1 : AnsiChar;
    AChar2 : AnsiChar;
    ABuf1  : AnsiString;
    ABuf2  : AnsiString;
    Len    : Integer;
    UBuf1  : String;
    UChar1 : Char;
    APtr1  : PAnsiChar;
    BBytes : array [0..10] of Byte;
begin
    Result := TRUE;  // Means failed
    try
{$IFDEF COMPILER19_UP}
        UChar1 := 'A';
        AChar1 := UChar1;
        if Ord('A') <> AChar1.Buffer then begin
            ErrMsg := 'Char assignation failed.';
            Exit;
        end;
{$ENDIF}

        AChar1 := 'A';
        if AnsiOrd(AChar1) <> Ord('A') then begin
            ErrMsg := 'AnsiOrd failed';
            Exit;
        end;

        APtr1 := @AChar1;
        if APtr1^ <> AChar1 then begin
            ErrMsg := 'Char to PAnsiChar or AnsiChar comparison failed.';
            Exit;
        end;

{$IFDEF COMPILER19_UP}
        AChar1 := 'H';
        if Ord('H') <> AChar1.Buffer then begin
            ErrMsg := 'AnsiChar assignation failed.';
            Exit;
        end;
{$ENDIF}

        AChar1 := 'H';
        AChar2 := 'H';
        if AChar2 <> AChar1 then begin
            ErrMsg := 'Comparison of two AnsiChar failed.';
            Exit;
        end;

        ABuf1 := 'A';
        Len   := AnsiLength(ABuf1);
        if (Len <> 1)
{$IFDEF COMPILER19_UP}
           or (ABuf1.Buffer[0] <> Ord('A'))
{$ENDIF}
           then begin
            ErrMsg := 'Implicit cast from unicode char failed.';
            Exit;
        end;

        if ABuf1 <> 'A' then begin
            ErrMsg := 'Comparison of AnsiString to Char failed.';
            Exit;
        end;

        UChar1 := 'A';
        if ABuf1 <> UChar1 then begin
            ErrMsg := 'Comparison of AnsiString to Char failed.';
            Exit;
        end;


        ABuf1 := 'Hello';   // Implicit cast from unicode string
        Len   := AnsiLength(ABuf1);
        if Len <> 5 then begin
            ErrMsg := 'Implicit cast from unicode string failed.';
            Exit;
        end;

{$IFDEF COMPILER19_UP}
        if Ord('H') <> ABuf1.Buffer[0] then begin
            ErrMsg := 'Comparison with AnsiChar failed.';
            Exit;
        end;
{$ENDIF}

        APtr1 := PAnsiChar(ABuf1);
        if APtr1^ <> ABuf1[1] then begin
            ErrMsg := 'AnsiString to PAnsiChar failed.';
            Exit;
        end;


        ABuf1 := AChar1;
        if AChar1 <> ABuf1[1] then begin
            ErrMsg := 'Assignation or comparison with AnsiChar failed.';
            Exit;
        end;

        ABuf2 := '';   // Implicit cast from empty unicode string
        Len   := AnsiLength(ABuf2);
        if Len <> 0 then begin
            ErrMsg := 'Implicit cast from empty unicode string failed.';
            Exit;
        end;

        ABuf2 := ABuf1;
        if ABuf2 <> ABuf1 then begin
            ErrMsg := 'Comparison failed.';
            Exit;
        end;

        ABuf1 := '';
        ABuf2 := '';
        if ABuf2 <> ABuf1 then begin
            ErrMsg := 'Comparison failed with empty values.';
            Exit;
        end;

        ABuf1 := 'Hello';
        UBuf1 := String(ABuf1);
        if UBuf1 <> 'Hello' then begin
            ErrMsg := 'Explicit cast to string failed.';
            Exit;
        end;

        ABuf1 := AnsiString(UBuf1);
        if ABuf1 <> 'Hello' then begin
            ErrMsg := 'Explicit cast to AnsiSstring failed.';
            Exit;
        end;

        ABuf1 := 'Hello';
        if AnsiLength(ABuf1) <> 5 then begin
            ErrMsg := 'AnsiLength failed';
            Exit;
        end;

        AnsiSetLength(ABuf1, 10);
        if AnsiLength(ABuf1) <> 10 then begin
            ErrMsg := 'AnsiSetLength failed';
            Exit;
        end;

        AChar1 := 'B';
        if not AnsiCharInSet(AChar1, ['A', 'B', 'C']) then begin
            ErrMsg := 'AnsiCharInSet failed to find';
            Exit;
        end;

        if AnsiCharInSet(AChar1, ['1', '2', '3']) then begin
            ErrMsg := 'AnsiCharInSet failed';
            Exit;
        end;

        if ByteToAsciiCodeLower(5) <> Ord('5') then begin
            ErrMsg := 'ByteToAsciiCodeLower failed with ''5''';
            Exit;
        end;

        if ByteToAsciiCodeLower(10) <> Ord('a') then begin
            ErrMsg := 'ByteToAsciiCodeLower failed with ''a''';
            Exit;
        end;

        if ByteToAsciiCodeUpper(10) <> Ord('A') then begin
            ErrMsg := 'ByteToAsciiCodeLower failed with ''A''';
            Exit;
        end;

        BBytes[0] := $12;
        BBytes[1] := $AB;
        BBytes[2] := $56;
        ABuf1 := AnsiBytesToHexUpper(@BBytes, 3);
        if ABuf1 <> '12AB56' then begin
            ErrMsg := 'AnsiBytesToHexUpper failed "' + ABuf1 + '" <> "12AB56"';
            Exit;
        end;

    except
        on E:Exception do begin
            ErrMsg := 'Failed. ' + E.ClassName + ': ' + E.Message;
            Exit;
        end;
    end;
    ErrMsg := '';
    Result := FALSE;  // Means all tests passed
end;

{$ENDIF}


end.
