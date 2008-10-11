{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Fran�ois PIETTE
Object:       This program is a demo for TMimeDecode component.
              TMimeDecode is a component whose job is to decode MIME encoded
              EMail messages (file attach). You can use it for example to
              decode messages received with a POP3 component.
              MIME is described in RFC-1521. headers are described if RFC-822.
Creation:     March 08, 1998
Version:      7.00
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1998-2007 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
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
Updates:
Sep 13, 1998  V1.01 Added part and header end numbering
Feb 16/02/99  V1.02 In OnPartLine event handler, assemble line of text for
              display.
May 04, 2002  V1.03 Adapted InLineDecodeLine event to new Len argument.
              Added file store for UUEncoded files.
Nov 01, 2002  V1.04 Changed PChar arguments to Pointer to work around Delphi 7
              bug with PAnsiChar<->PChar (change has be done in component).
Oct 11, 2008  V7.00 Angus added MIME header encoding and decoding
              Added TMimeDecodeEx test button (uses no events)
              Fixed MimeDecode1InlineDecode events for D2009 (still Ansi)



 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit OverbyteIcsMimeDemo1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IniFiles,
  OverbyteIcsMimeUtils, OverbyteIcsMimeDec, OverbyteIcsUtils;

const
  MimeDemoVersion    = 700;
  CopyRight : String = ' MimeDemo (c) 1998-2008 F. Piette V7.00 ';

type
  TMimeDecodeForm = class(TForm)
    Panel1: TPanel;
    FileEdit: TEdit;
    DecodeButton: TButton;
    Memo1: TMemo;
    MimeDecode1: TMimeDecode;
    Label1: TLabel;
    ClearButton: TButton;
    TextEdit: TEdit;
    Label2: TLabel;
    Decode64Button: TButton;
    Encode64Button: TButton;
    DecAutoHeaderButton: TButton;
    DecOneHeaderButton: TButton;
    EncodeOneHdrButton: TButton;
    DecodeFileExButton: TButton;
    MimeDecodeEx1: TMimeDecodeEx;
    procedure DecodeButtonClick(Sender: TObject);
    procedure MimeDecode1PartBegin(Sender: TObject);
    procedure MimeDecode1PartEnd(Sender: TObject);
    procedure MimeDecode1PartHeaderLine(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure MimeDecode1HeaderLine(Sender: TObject);
    procedure MimeDecode1PartLine(Sender: TObject; Data: Pointer;
      DataLen: Integer);
    procedure MimeDecode1HeaderBegin(Sender: TObject);
    procedure MimeDecode1HeaderEnd(Sender: TObject);
    procedure MimeDecode1PartHeaderBegin(Sender: TObject);
    procedure MimeDecode1PartHeaderEnd(Sender: TObject);
    procedure MimeDecode1InlineDecodeBegin(Sender: TObject;
                                           Filename: AnsiString);
    procedure MimeDecode1InlineDecodeEnd(Sender: TObject;
                                         Filename: AnsiString);
    procedure MimeDecode1InlineDecodeLine(Sender: TObject;
                                          Line: Pointer; Len : Integer);
    procedure Decode64ButtonClick(Sender: TObject);
    procedure Encode64ButtonClick(Sender: TObject);
    procedure DecAutoHeaderButtonClick(Sender: TObject);
    procedure DecOneHeaderButtonClick(Sender: TObject);
    procedure EncodeOneHdrButtonClick(Sender: TObject);
    procedure DecodeFileExButtonClick(Sender: TObject);
  private
    FInitialized   : Boolean;
    FIniFileName   : String;
    FLineBuf       : array [0..255] of AnsiChar;
    FCharCnt       : Integer;
    FFileStream    : TFileStream;
    FFileName      : String;
    procedure Display(Msg: String);
  end;

var
  MimeDecodeForm: TMimeDecodeForm;

implementation

{$R *.DFM}
const
    SectionData   = 'Data';
    SectionWindow = 'Window';
    KeyTop        = 'Top';
    KeyLeft       = 'Left';
    KeyWidth      = 'Width';
    KeyHeight     = 'Height';
    KeyFile       = 'FileName';
    KeyText       = 'TextEdit';


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.FormCreate(Sender: TObject);
begin
    FIniFileName := LowerCase(ExtractFileName(Application.ExeName));
    FIniFileName := Copy(FIniFileName, 1, Length(FIniFileName) - 3) + 'ini';
    Memo1.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if not FInitialized then begin
        FInitialized        := TRUE;
        IniFile   := TIniFile.Create(FIniFileName);
        Top       := IniFile.ReadInteger(SectionWindow, KeyTop,    Top);
        Left      := IniFile.ReadInteger(SectionWindow, KeyLeft,   Left);
        Width     := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height    := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        FileEdit.Text := IniFile.ReadString(SectionData,  KeyFile,   'mime-demo1.txt');
        TextEdit.Text := IniFile.ReadString(SectionData,  KeyText,   'some text to encode');
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteInteger(SectionWindow, KeyTop,    Top);
    IniFile.WriteInteger(SectionWindow, KeyLeft,   Left);
    IniFile.WriteInteger(SectionWindow, KeyWidth,  Width);
    IniFile.WriteInteger(SectionWindow, KeyHeight, Height);
    IniFile.WriteString(SectionData,    KeyFile,   FileEdit.Text);
    IniFile.WriteString(SectionData,    KeyText,   TextEdit.Text);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.DecodeButtonClick(Sender: TObject);
begin
    Memo1.Clear;
    Update;
    MimeDecode1.DecodeFile(FileEdit.Text);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.Display(Msg: String);
begin
    Memo1.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1PartBegin(Sender: TObject);
begin
    Display('--------- PART ' +
            IntToStr(MimeDecode1.PartNumber) +
            ' BEGIN ----------');
    FCharCnt := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1PartEnd(Sender: TObject);
begin
    if FCharCnt > 0 then begin
        Display(StrPas(FLineBuf));
        FCharCnt := 0;
    end;

    Display('--------- PART ' +
            IntToStr(MimeDecode1.PartNumber) +
            ' END ----------');
    { Close file, if any }
    if Assigned(FFileStream) then begin
        FFileStream.Destroy;
        FFileStream := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Decoded data arrives here. This routine suppose that we have text data    }
{ organized in lines.                                                       }
procedure TMimeDecodeForm.MimeDecode1PartLine(
    Sender  : TObject;
    Data    : Pointer;
    DataLen : Integer);
var
    I : Integer;
begin
    { Copy data to LineBuf until CR/LF }
    I := 0;
    while (I < DataLen) do begin
        if PAnsiChar(Data)[I] = #13 then   { Just ignre CR }
            Inc(I)
        else if PAnsiChar(Data)[I] = #10 then begin { LF is end of line }
            FLineBuf[FCharCnt] := #0;
            Display(StrPas(FLineBuf));
            FCharCnt := 0;
            Inc(I);
        end
        else begin
            FLineBuf[FCharCnt] := PAnsiChar(Data)[I];
            Inc(FCharCnt);
            Inc(I);
        end;
        if FCharCnt >= (High(FLineBuf) - 1) then begin
            { Buffer overflow, display data accumulated so far }
            FLineBuf[High(FLineBuf) - 1] := #0;
            Display(StrPas(FLineBuf));
            FCharCnt := 0;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1PartHeaderLine(Sender: TObject);
begin
    Display('Part header: ' + StrPas(MimeDecode1.CurrentData));
end;



{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1HeaderLine(Sender: TObject);
begin
    Display('Msg header: ' + StrPas(MimeDecode1.CurrentData));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1HeaderBegin(Sender: TObject);
begin
    Display('--------- HEADER BEGIN ----------');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1HeaderEnd(Sender: TObject);
begin
    Display('--------- HEADER END ----------');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1PartHeaderBegin(Sender: TObject);
begin
    Display('--------- PART ' +
            IntToStr(MimeDecode1.PartNumber) +
            ' HEADER BEGIN ----------');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1PartHeaderEnd(Sender: TObject);
begin
    Display('--------- PART ' +
            IntToStr(MimeDecode1.PartNumber) +
            ' HEADER END ----------');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1InlineDecodeBegin(
   Sender   : TObject;
   FileName : AnsiString);
begin
    Display('--------- INLINE begin. Filename is ''' + FileName + '''');
    Display('');
    FFileName := FileNAme;
    if Assigned(FFileStream) then
        FFileStream.Destroy;        { Close previous file, if any }
    FFileStream := TFileStream.Create('MimeFile_' + FFileName, fmCreate);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1InlineDecodeEnd(
   Sender   : TObject;
   Filename : AnsiString);
begin
    Display('--------- INLINE end');
    { Close file, if any }
    if Assigned(FFileStream) then begin
        FFileStream.Destroy;
        FFileStream := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.MimeDecode1InlineDecodeLine(
  Sender : TObject;
  Line   : Pointer;
  Len    : Integer);
var
    LastLine : String;
    DataLine : String;
begin
    if (Line = nil) or (Len <= 0) then
        Exit;
    { If any file assigned, then write data to it }
    if Assigned(FFileStream) then
        FFileStream.Write(Line^, Len);

    SetLength(DataLine, Len);
    Move(Line^, DataLine[1], Len);
    if Memo1.Lines.Count < 1 then
        Memo1.Lines.Add(DataLine)
    else begin
        LastLine := Memo1.Lines.Strings[Memo1.Lines.Count - 2];
        Memo1.Lines.Delete(Memo1.Lines.Count - 1);
        Memo1.Lines.Delete(Memo1.Lines.Count - 1);
        LastLine := LastLine + DataLine;
        Memo1.Lines.Add(LastLine);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure TMimeDecodeForm.Decode64ButtonClick(Sender: TObject);
var
    Buf : String;
    I   : Integer;
    Txt : String;
begin
    Buf := Base64Decode(TextEdit.Text);
    TextEdit.Text := Buf;
    Txt := '';
    for I := 1 to Length(Buf) do begin
        if (Buf[I] <= '!') or (Buf[I] > '~') then
            Txt := Txt + '$' + IntToHex(Ord(Buf[I]), 2)
        else
            Txt := Txt + Buf[I];
    end;
    Memo1.Lines.Add(Txt);
end;

procedure TMimeDecodeForm.Encode64ButtonClick(Sender: TObject);
var
    Buf : String;
begin
    Buf := Base64Encode(TextEdit.Text);
    TextEdit.Text := Buf;
    Memo1.Lines.Add(Buf);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ few examples of encoded header lines (koi8-r is Cyrillic, GB2312 is Chinese,
8859-1 is Latin/Western European, 8859-5 is Latin/Cyrillic, 8859-6 is Latin/Arabic,
windows-1252 is a superset of 8859-1, see OverbyteIcsCharsetUtils for a full list  )  }

const
    TotHeaders = 23 ;
var
    TestHeaders: array [1..TotHeaders] of string = (
        '=?US-ASCII?Q?Keith_Moore?= <moore@cs.utk.edu>',
        '=?ISO-8859-1?Q?Andr=E9?= Pirard <PIRARD@vm1.ulg.ac.be>',
        '=?ISO-8859-1?B?SWYgeW91IGNhbiByZWFkIHRoaXMgeW8=?=',
        '=?ISO-8859-2?B?dSB1bmRlcnN0YW5kIHRoZSBleGFtcGxlLg==?=',
        '=?ISO-8859-1?Q?a?= b=?ISO-8859-1?Q?a_b?=',
        '=?ISO-8859-1?Q?a?=  =?ISO-8859-1?Q?b?=',
        '=?iso-8859-1?q?Fred=20Mace?= <fredmace@yahoo.co.uk>',
        '=?ISO-8859-1?Q?Re=3A_=5Btwsocket=5D?= Encoded mail headers',
        '=?ISO-8859-1?B?aGk=?=',
        '=?GB2312?B?yczO8cOz0tc=?= <hk@163.com>',
        '=?GB2312?B?sOzA7c/juNvTosPAufq8yrmry77Qrbvh?=',
        '=?utf-8?B?TWljcm9zb2Z0IE91dGxvb2sgVGVzdCBNZXNzYWdl?=',
        '=?ISO-8859-1?b?UmU6S2V5cyB0byBzdGF5aW5nIHlvdW5n?=',
        '=?iso-8859-5?B?+szB1MEg4s/U18nOwQ==?= <dnevnik@liveinternet.ru>',
        '"eap2s@mtsu.eduruss.txt}" <dunman@magsys.co.uk>',
        '=?koi8-r?B?9C7yLiDs1cLRztPLycog?= <yujiko@barryland.com>',
        '=?koi8-r?B?NSDUy8EuIMTM0SDP0sfBzsnawdTP0s/XICDQ0sHaxM7Jy8/XIMkgzQ==?=',
        '=?windows-1252?Q?Don=92t_be_Blue!_Heat_up_October_with_these_Scorching_Deals_Only_at_Screwfix_?=',
        '=?iso-8859-1?Q?Integral_512MB_Pen_Drives_For_Just_=A31.29?=',
        '=?utf-8?B?QW5ndXMgZmFpdCBsYSBmw6p0ZSDDoCBGcmFuw6dvaXMgcXVhbmQgbCfDqXTDqSBhcnJpdmU=?=',
        '=?utf-8?Q?Angus_fait_la_f=C3=AAte_=C3=A0_Fran=C3=A7ois_quand_l''=C3=A9t=C3=A9_arrive?=',  // note escaped '' added
        '=?iso-8859-1?B?QW5ndXMgZmFpdCBsYSBm6nRlIOAgRnJhbudvaXMgcXVhbmQgbCfpdOkgYXJyaXZl?=',
        '=?iso-8859-1?Q?Angus_fait_la_f=EAte_=E0_Fran=E7ois_quand_l''=E9t=E9_arrive?=' );          // note escaped '' added

procedure TMimeDecodeForm.DecAutoHeaderButtonClick(Sender: TObject);
var
    I: integer;
    DecStr, CharSet: AnsiString;
begin
    Display('Auto decoding test MIME Encoded Header Lines');
    for I := 1 to TotHeaders do begin
        DecStr := MimeDecodeEx1.DecodeHeaderLine (TestHeaders[I], CharSet);
        Display('Raw Header: ' + TestHeaders[I]);
        Display('8-bit Header: ' + DecStr + ' [CharSet=' + CharSet + ']');
        Display('Unicode Header: ' + MimeDecodeEx1.DecodeHeaderLineWide (TestHeaders[I]));
        Display('');
    end;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.DecOneHeaderButtonClick(Sender: TObject);
var
    DecStr, CharSet: AnsiString;
begin
    DecStr := MimeDecodeEx1.DecodeHeaderLine (TextEdit.Text, CharSet);
    Display('Raw Header: ' + TextEdit.Text);
    Display('8-bit Header: ' + DecStr + ' [CharSet=' + CharSet + ']');
    Display('Unicode Header: ' + MimeDecodeEx1.DecodeHeaderLineWide (TextEdit.Text));
    Display('');
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.EncodeOneHdrButtonClick(Sender: TObject);
var
    U8String: RawByteString;
begin
    Display('Raw Text: ' + TextEdit.Text);
    U8String := StringToUtf8 (TextEdit.Text);
    Display('UTF-8 Text: ' + U8String);
    Display('UTF-8 Binary: ' + HdrEncodeInLine(U8String,
                                    SpecialsRFC822, 'B', 'utf-8', 72, false));
    Display('UTF-8 Quoted: ' + HdrEncodeInLine(U8String,
                                    SpecialsRFC822, 'Q', 'utf-8', 72, false));
    Display('ISO-8859-1 Binary: ' + HdrEncodeInLine(TextEdit.Text,
                                SpecialsRFC822, 'B', 'iso-8859-1', 72, false));
    Display('ISO-8859-1 Quoted: ' + HdrEncodeInLine(TextEdit.Text,
                                SpecialsRFC822, 'Q', 'iso-8859-1', 72, false));
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.DecodeFileExButtonClick(Sender: TObject);
var
    I: integer;
begin
    Display('MIME Decoding ' + FileEdit.Text);
    MimeDecodeEx1.DecodeFileEx(FileEdit.Text);   // decodes without using events, into arrays, see below
    Display('Total header lines found: ' + IntToStr (MimeDecodeEx1.HeaderLines.Count) +
                             ', Length ' + IntToStr (MimeDecodeEx1.MimeDecode.LengthHeader));
    if MimeDecodeEx1.DecParts = 0 then
        Display('No parts found to decode')
    else begin
        for I := 0 to Pred (MimeDecodeEx1.DecParts) do begin
            with MimeDecodeEx1.PartInfos [I] do begin
                Display('Part ' + IntToStr (I) +  ', Content: ' + PContentType +
                    ', Size: ' + IntToStr (PartStream.Size) +
                    ', Name: ' + PName + ', FileName: ' + PFileName +
                    ', Encoding: ' + PEncoding + ', Charset: ' + PCharset);
                 // the content of each part is in PartStream
                 // but we don't attempt to display it here, only the size
            end;
        end;
        MimeDecodeEx1.Reset ;  // clear streams to free memory
    end;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMimeDecodeForm.ClearButtonClick(Sender: TObject);
begin
    Memo1.Clear;
end;


end.

