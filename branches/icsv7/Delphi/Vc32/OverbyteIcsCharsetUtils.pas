{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Arno Garrels <arno.garrels@gmx.de>
Description:  A place for MIME-charset stuff.
              This work is still incomplete and of course not tested with all
              exotic codepages! Also not every codepage is installed
              and available on all Windows versions by default. Use function
              GetSystemCodePageList() to get the codepages installed and
              available on the system.
              Unfortunately the Microsoft docs do say nothing about mapping
              MIME charsets to Windows codepage numbers, so many mappings
              are not proved to be correct. I used the following URLs
              as information source:
              http://msdn.microsoft.com/en-us/library/ms776446.aspx
              http://www.iana.org/assignments/character-sets
Creation:     July 17, 2008
Version:      1.02
EMail:        http://www.overbyte.be       francois.piette@overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 2002-2008 by Fran�ois PIETTE
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

              4. You must register this software by sending a picture postcard
                 to Francois PIETTE. Use a nice stamp and mention your name,
                 street address, EMail address and any comment you like to say.

Sample:   Usage GetSystemCodePageList():
          uses Contnrs;
          [..]
          var
              OwnsList : TObjectList;
              I : Integer;
          begin
              OwnsList := TObjectList.Create;
              try
                  GetCodePageList(OwnsList);
                  for I := 0 to OwnsList.Count -1 do
                        Memo1.Lines.Add(TCodePageObj(OwnsList[I]).CodePageName);
              finally
                  OwnsList.Free;
              end;
          end;

History:
Jul 20, 2008 V1.01 A. Garrels added CodePageToMimeCharsetString();
Jul 29, 2008 V1.02 A. Garrels added global var IcsSystemCodePage. Changed type
                   of one local var from AnsiString to CsuString.



//
// Windows codepage Identifiers, June 2008, for a current list try
// http://msdn.microsoft.com/en-us/library/ms776446.aspx
//
    CP_037            = 037;  //  IBM037          IBM EBCDIC US-Canada
    CP_437            = 437;  //  IBM437          OEM United States
    CP_500            = 500;  //  IBM500          IBM EBCDIC International
    CP_708            = 708;  //  ASMO-708        Arabic (ASMO 708)
    CP_709            = 709;  //  Arabic          (ASMO-449+, BCON V4) //none Mime
    CP_710            = 710;  //                  Arabic - Transparent Arabic //none Mime
    CP_720            = 720;  //  DOS-720         Arabic (Transparent ASMO); Arabic (DOS) //none Mime
    CP_737            = 737;  //  ibm737          OEM Greek (formerly 437G); Greek (DOS)  //none Mime
    CP_775            = 775;  //  ibm775          OEM Baltic; Baltic (DOS)  //none Mime
    CP_850            = 850;  //  ibm850          OEM Multilingual Latin 1; Western European (DOS)
    CP_852            = 852;  //  ibm852          OEM Latin 2; Central European (DOS)
    CP_855            = 855;  //  IBM855          OEM Cyrillic (primarily Russian)
    CP_857            = 857;  //  ibm857          OEM Turkish; Turkish (DOS)
    CP_858            = 858;  //  IBM00858        OEM Multilingual Latin 1 + Euro symbol
    CP_860            = 860;  //  IBM860          OEM Portuguese; Portuguese (DOS)
    CP_861            = 861;  //  ibm861          OEM Icelandic; Icelandic (DOS)
    CP_862            = 862;  //  DOS-862         OEM Hebrew; Hebrew (DOS)
    CP_863            = 863;  //  IBM863          OEM French Canadian; French Canadian (DOS)
    CP_864            = 864;  //  IBM864          OEM Arabic; Arabic (864)
    CP_865            = 865;  //  IBM865          OEM Nordic; Nordic (DOS)
    CP_866            = 866;  //  cp866           OEM Russian; Cyrillic (DOS)
    CP_869            = 866;  //  ibm869          OEM Modern Greek; Greek, Modern (DOS)
    CP_870            = 870;  //  IBM870          IBM EBCDIC Multilingual/ROECE (Latin 2); IBM EBCDIC Multilingual Latin 2
    CP_874            = 874;  //  windows-874     ANSI/OEM Thai (same as 28605, ISO 8859-15); Thai (Windows)
    CP_875            = 875;  //  cp875           IBM EBCDIC Greek Modern // none Mime
    CP_932            = 932;  //  shift_jis       ANSI/OEM Japanese; Japanese (Shift-JIS)
    CP_936            = 936;  //  gb2312          ANSI/OEM Simplified Chinese (PRC, Singapore); Chinese Simplified (GB2312)
    CP_949            = 949;  //  ks_c_5601-1987  ANSI/OEM Korean (Unified Hangul Code)
    CP_950            = 950;  //  big5            ANSI/OEM Traditional Chinese (Taiwan; Hong Kong SAR, PRC); Chinese Traditional (Big5)
    CP_1026           = 1026; //  IBM1026         IBM EBCDIC Turkish (Latin 5)
    CP_1047           = 1047; //  IBM01047        IBM EBCDIC Latin 1/Open System
    CP_1140           = 1140; //  IBM01140        IBM EBCDIC US-Canada (037 + Euro symbol); IBM EBCDIC (US-Canada-Euro)
    CP_1141           = 1141; //  IBM01141        IBM EBCDIC Germany (20273 + Euro symbol); IBM EBCDIC (Germany-Euro)
    CP_1142           = 1142; //  IBM01142        IBM EBCDIC Denmark-Norway (20277 + Euro symbol); IBM EBCDIC (Denmark-Norway-Euro)
    CP_1143           = 1143; //  IBM01143        IBM EBCDIC Finland-Sweden (20278 + Euro symbol); IBM EBCDIC (Finland-Sweden-Euro)
    CP_1144           = 1144; //  IBM01144        IBM EBCDIC Italy (20280 + Euro symbol); IBM EBCDIC (Italy-Euro)
    CP_1145           = 1145; //  IBM01145        IBM EBCDIC Latin America-Spain (20284 + Euro symbol); IBM EBCDIC (Spain-Euro)
    CP_1146           = 1146; //  IBM01146        IBM EBCDIC United Kingdom (20285 + Euro symbol); IBM EBCDIC (UK-Euro)
    CP_1147           = 1147; //  IBM01147        IBM EBCDIC France (20297 + Euro symbol); IBM EBCDIC (France-Euro)
    CP_1148           = 1148; //  IBM01148        IBM EBCDIC International (500 + Euro symbol); IBM EBCDIC (International-Euro)
    CP_1149           = 1149; //  IBM01149        IBM EBCDIC Icelandic (20871 + Euro symbol); IBM EBCDIC (Icelandic-Euro)
    CP_1200           = 1200; //  utf-16          Unicode UTF-16, little endian byte order (BMP of ISO 10646); available only to managed applications
    CP_1201           = 1201; //  unicodeFFFE     Unicode UTF-16, big endian byte order; available only to managed applications
    CP_1250           = 1250; //  windows-1250    ANSI Central European; Central European (Windows)
    CP_1251           = 1251; //  windows-1251    ANSI Cyrillic; Cyrillic (Windows)
    CP_1252           = 1252; //  windows-1252    ANSI Latin 1; Western European (Windows)
    CP_1253           = 1253; //  windows-1253    ANSI Greek; Greek (Windows)
    CP_1254           = 1254; //  windows-1254    ANSI Turkish; Turkish (Windows)
    CP_1255           = 1255; //  windows-1255    ANSI Hebrew; Hebrew (Windows)
    CP_1256           = 1256; //  windows-1256    ANSI Arabic; Arabic (Windows)
    CP_1257           = 1257; //  windows-1257    ANSI Baltic; Baltic (Windows)
    CP_1258           = 1258; //  windows-1258    ANSI/OEM Vietnamese; Vietnamese (Windows)
    CP_1361           = 1361; //  Johab           Korean (Johab)  // none mime
    CP_10000          = 10000;//  macintosh           MAC Roman; Western European (Mac)
    CP_10001          = 10001;//  x-mac-japanese      Japanese (Mac)
    CP_10002          = 10002;//  x-mac-chinesetrad   MAC Traditional Chinese (Big5); Chinese Traditional (Mac)
    CP_10003          = 10003;//  x-mac-korean        Korean (Mac)
    CP_10004          = 10004;//  x-mac-arabic        Arabic (Mac)
    CP_10005          = 10005;//  x-mac-hebrew        Hebrew (Mac)
    CP_10006          = 10006;//  x-mac-greek         Greek (Mac)
    CP_10007          = 10007;//  x-mac-cyrillic      Cyrillic (Mac)
    CP_10008          = 10008;//  x-mac-chinesesimp   MAC Simplified Chinese (GB 2312); Chinese Simplified (Mac)
    CP_10010          = 10010;//  x-mac-romanian      Romanian (Mac)
    CP_10017          = 10017;//  x-mac-ukrainian     Ukrainian (Mac)
    CP_10021          = 10021;//  x-mac-thai          Thai (Mac)
    CP_10029          = 10029;//  x-mac-ce            MAC Latin 2; Central European (Mac)
    CP_10079          = 10079;//  x-mac-icelandic     Icelandic (Mac)
    CP_10081          = 10081;//  x-mac-turkish       Turkish (Mac)
    CP_10082          = 10082;//  x-mac-croatian      Croatian (Mac)
    CP_12000          = 12000;//  utf-32              Unicode UTF-32, little endian byte order; available only to managed applications
    CP_12001          = 12001;//  utf-32BE            Unicode UTF-32, big endian byte order; available only to managed applications
    CP_20000          = 20000;//  x-Chinese_CNS       CNS Taiwan; Chinese Traditional (CNS)
    CP_20001          = 20001;//  x-cp20001           TCA Taiwan
    CP_20002          = 20002;//  x_Chinese-Eten      Eten Taiwan; Chinese Traditional (Eten)
    CP_20003          = 20003;//  x-cp20003           IBM5550 Taiwan
    CP_20004          = 20004;//  x-cp20004           TeleText Taiwan
    CP_20005          = 20005;//  x-cp20005           Wang Taiwan
    CP_20105          = 20105;//  x-IA5               IA5 (IRV International Alphabet No. 5, 7-bit); Western European (IA5)
    CP_20106          = 20106;//  x-IA5-German        IA5 German (7-bit)
    CP_20107          = 20107;//  x-IA5-Swedish       IA5 Swedish (7-bit)
    CP_20108          = 20108;//  x-IA5-Norwegian     IA5 Norwegian (7-bit)
    CP_20127          = 20127;//  us-ascii            US-ASCII (7-bit)
    CP_20261          = 20261;//  x-cp20261           T.61
    CP_20269          = 20269;//  x-cp20269           ISO 6937 Non-Spacing Accent
    CP_20273          = 20273;//  IBM273              IBM EBCDIC Germany
    CP_20277          = 20277;//  IBM277              IBM EBCDIC Denmark-Norway
    CP_20278          = 20278;//  IBM278              IBM EBCDIC Finland-Sweden
    CP_20280          = 20280;//  IBM280              IBM EBCDIC Italy
    CP_20284          = 20284;//  IBM284              IBM EBCDIC Latin America-Spain
    CP_20285          = 20285;//  IBM285              IBM EBCDIC United Kingdom
    CP_20290          = 20290;//  IBM290              IBM EBCDIC Japanese Katakana Extended
    CP_20297          = 20297;//  IBM297              IBM EBCDIC France
    CP_20420          = 20420;//  IBM420              IBM EBCDIC Arabic
    CP_20423          = 20423;//  IBM423              IBM EBCDIC Greek
    CP_20424          = 20424;//  IBM424              IBM EBCDIC Hebrew
    CP_20833          = 20833;//  x-EBCDIC-KoreanExtended   IBM EBCDIC Korean Extended
    CP_20838          = 20838;//  IBM-Thai            IBM EBCDIC Thai
    CP_20866          = 20866;//  koi8-r              Russian (KOI8-R); Cyrillic (KOI8-R)
    CP_20871          = 20871;//  IBM871              IBM EBCDIC Icelandic
    CP_20880          = 20880;//  IBM880              IBM EBCDIC Cyrillic Russian
    CP_20905          = 20905;//  IBM905              IBM EBCDIC Turkish
    CP_20924          = 20924;//  IBM00924            IBM EBCDIC Latin 1/Open System (1047 + Euro symbol)
    CP_20932          = 20932;//  EUC-JP              Japanese (JIS 0208-1990 and 0121-1990) This is a typo! actually (JIS X 0208-1990 & 0212-1990)
    CP_20936          = 20936;//  x-cp20936           Simplified Chinese (GB2312); Chinese Simplified (GB2312-80)
    CP_20949          = 20949;//  x-cp20949           Korean Wansung
    CP_21025          = 21025;//  cp1025              IBM EBCDIC Cyrillic Serbian-Bulgarian
    //21027 		(deprecated)
    CP_21866          = 21866;//  koi8-u              Ukrainian (KOI8-U); Cyrillic (KOI8-U)
    CP_28591          = 28591;//  iso-8859-1          ISO 8859-1 Latin 1; Western European (ISO)
    CP_28592          = 28592;//  iso-8859-2          ISO 8859-2 Central European; Central European (ISO)
    CP_28593          = 28593;//  iso-8859-3          ISO 8859-3 Latin 3
    CP_28594          = 28594;//  iso-8859-4          ISO 8859-4 Baltic
    CP_28595          = 28595;//  iso-8859-5          ISO 8859-5 Cyrillic
    CP_28596          = 28596;//  iso-8859-6          ISO 8859-6 Arabic
    CP_28597          = 28597;//  iso-8859-7          ISO 8859-7 Greek
    CP_28598          = 28598;//  iso-8859-8          ISO 8859-8 Hebrew; Hebrew (ISO-Visual)
    CP_28599          = 28599;//  iso-8859-9          ISO 8859-9 Turkish
    CP_28603          = 28603;//  iso-8859-13         ISO 8859-13 Estonian
    CP_28605          = 28605;//  iso-8859-15         ISO 8859-15 Latin 9
    CP_29001          = 29001;//  x-Europa            Europa 3
    CP_38598          = 38598;//  iso-8859-8-i        ISO 8859-8 Hebrew; Hebrew (ISO-Logical)
    CP_50220          = 50220;//  iso-2022-jp         ISO 2022 Japanese with no halfwidth Katakana; Japanese (JIS)
    CP_50221          = 50221;//  csISO2022JP         ISO 2022 Japanese with halfwidth Katakana; Japanese (JIS-Allow 1 byte Kana)
    CP_50222          = 50222;//  iso-2022-jp         ISO 2022 Japanese JIS X 0201-1989; Japanese (JIS-Allow 1 byte Kana - SO/SI)
    CP_50225          = 50225;//  iso-2022-kr         ISO 2022 Korean
    CP_50227          = 50227;//  x-cp50227           ISO 2022 Simplified Chinese; Chinese Simplified (ISO 2022)
    CP_50229          = 50229;//  ISO 2022            Traditional Chinese
    CP_50930          = 50930;//                      EBCDIC Japanese (Katakana) Extended
    CP_50931          = 50931;//                      EBCDIC US-Canada and Japanese
    CP_50933          = 50933;//                      EBCDIC Korean Extended and Korean
    CP_50935          = 50935;//                      EBCDIC Simplified Chinese Extended and Simplified Chinese
    CP_50936          = 50936;//                      EBCDIC Simplified Chinese
    CP_50937          = 50937;//                      EBCDIC US-Canada and Traditional Chinese
    CP_50939          = 50939;//                      EBCDIC Japanese (Latin) Extended and Japanese
    CP_51932          = 51932;//  euc-jp              EUC Japanese
    CP_51936          = 51936;//  EUC-CN              EUC Simplified Chinese; Chinese Simplified (EUC)
    CP_51949          = 51949;//  euc-kr              EUC Korean
    CP_51950          = 51950;//                      EUC Traditional Chinese
    CP_52936          = 52936;//  hz-gb-2312          HZ-GB2312 Simplified Chinese; Chinese Simplified (HZ)
    CP_54936          = 54936;//  GB18030             Windows XP and later: GB18030 Simplified Chinese (4 byte); Chinese Simplified (GB18030)
    CP_57002          = 57002;//  x-iscii-de          ISCII Devanagari
    CP_57003          = 57003;//  x-iscii-be          ISCII Bengali
    CP_57004          = 57004;//  x-iscii-ta          ISCII Tamil
    CP_57005          = 57005;//  x-iscii-te          ISCII Telugu
    CP_57006          = 57006;//  x-iscii-as          ISCII Assamese
    CP_57007          = 57007;//  x-iscii-or          ISCII Oriya
    CP_57008          = 57008;//  x-iscii-ka          ISCII Kannada
    CP_57009          = 57009;//  x-iscii-ma          ISCII Malayalam
    CP_57010          = 57010;//  x-iscii-gu          ISCII Gujarati
    CP_57011          = 57011;//  x-iscii-pa          ISCII Punjabi
    CP_65000          = 65000;//  utf-7               Unicode (UTF-7)
    CP_65001          = 65001;//  utf-8               Unicode (UTF-8)


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit OverbyteIcsCharsetUtils;

{$I OverbyteIcsDefs.inc}

{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}
{$B-}             { Enable partial boolean evaluation   }
{$T-}             { Untyped pointers                    }
{$X+}             { Enable extended syntax              }
{$H+}             { Use long strings                    }
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}

interface

uses
    Windows, Sysutils, Classes, Contnrs;

type
    CsuString = String;
    { Proc. InitializeCharsetInfos depends on the order of the items of this }
    { set!                                                                   }
    TMimeCharset = (
      UTF_8,
      WIN_1250,
      WIN_1251,
      WIN_1252,
      WIN_1253,
      WIN_1254,
      WIN_1255,
      WIN_1256,
      WIN_1257,
      WIN_1258,
      ISO_8859_1,
      ISO_8859_2,
      ISO_8859_3,
      ISO_8859_4,
      ISO_8859_5,
      ISO_8859_6,
      ISO_8859_7,
      ISO_8859_8,
      ISO_8859_9,
      ISO_8859_13,
      ISO_8859_15,
      ISO_2022_JP,   //?
      ISO_2022_JP_1, //?
      ISO_2022_JP_2, //?
      ISO_2022_KR,
      ISO_2022_CN,
      ISO_2022_CN_EXT,
      EUC_JP,
      GB_2312_80,
      GB_2312,
      KOI8_R,
      KOI8_U,
      UTF_16LE,
      UTF_16BE,
      UTF_7,
      Shift_JIS,
      GBK,
      BIG_5,
      ks_c_5601_1987,
      IBM_037,
      IBM_437,
      IBM_500,
      IBM_850,
      IBM_852,
      IBM_855,
      IBM_857,
      IBM_00858,
      IBM_860,
      IBM_861,
      IBM_862,
      IBM_863,
      IBM_864,
      IBM_865,
      IBM_866,
      IBM_869,
      IBM_870,
      IBM_1026,
      IBM_01047,
      IBM_01140,
      IBM_01141,
      IBM_01142,
      IBM_01143,
      IBM_01144,
      IBM_01145,
      IBM_01146,
      IBM_01147,
      IBM_01148,
      IBM_01149,
      MACINTOSH,
      US_ASCII,
      T_61
      );

    PCharsetInfo = ^TCharsetInfo;
    TCharsetInfo = record
        MimeCharset : TMimeCharset;
        CodePage    : Cardinal;    // matching windows codepage
        MimeName    : CsuString;  // prefered MIME name and alias list space separated
    end;
    TCharsetInfos = array of TCharsetInfo;

    PCPInfoExA = ^TCPInfoExA;
    {$EXTERNALSYM _CPINFOEXA}
    _CPINFOEXA = record
        MaxCharSize         : Cardinal;                                 { max length (bytes) of a char }
        DefaultChar         : array[0..MAX_DEFAULTCHAR - 1] of Byte;    { default character }
        LeadByte            : array[0..MAX_LEADBYTES - 1] of Byte;      { lead byte ranges }
        UnicodeDefaultChar  : WideChar;
        CodePage            : Cardinal;
        CodePageName        : array[0..MAX_PATH] of AnsiChar;
    end;
    TCPInfoExA = _CPINFOEXA;
    {$EXTERNALSYM CPINFOEXA}
    CPINFOEXA = _CPINFOEXA;

    PCPInfoExW = ^TCPInfoExW;
    {$EXTERNALSYM _CPINFOEXW}
    _CPINFOEXW = record
        MaxCharSize         : Cardinal;                                 { max length (bytes) of a char }
        DefaultChar         : array[0..MAX_DEFAULTCHAR - 1] of Byte;    { default character }
        LeadByte            : array[0..MAX_LEADBYTES - 1] of Byte;      { lead byte ranges }
        UnicodeDefaultChar  : WideChar;
        CodePage            : Cardinal;
        CodePageName        : array[0..MAX_PATH] of WideChar;
    end;
    TCPInfoExW = _CPINFOEXW;
    {$EXTERNALSYM CPINFOEXW}
    CPINFOEXW = _CPINFOEXW;

{$IFDEF UNICODE}
    PCPInfoEx = PCPInfoExW;
    {$EXTERNALSYM CPINFOEX}
    CPINFOEX  = CPINFOEXW;
    TCPInfoEx = TCPInfoExW;
{$ELSE}
    PCPInfoEx = PCPInfoExA;
    {$EXTERNALSYM CPINFOEX}
    CPINFOEX  = CPINFOEXA;
    TCPInfoEx = TCPInfoExA;
{$ENDIF}

    TCodePageObj = class
    private
        FCodePage     : Cardinal;
        FCodePageName : String;
    public
        property CodePage: Cardinal read FCodePage;
        property CodePageName: String read FCodePageName;
    end;

function  CodePageToMimeCharset(ACodePage: Cardinal): TMimeCharset;
function  CodePageToMimeCharsetString(ACodePage: Cardinal): CsuString;
function  GetMimeInfo(AMimeCharSet: TMimeCharset): PCharSetInfo; overload;
function  GetMimeInfo(const AMimeCharSetString: CsuString): PCharSetInfo; overload;
function  MimeCharsetToCharsetString(AMimeCharSet: TMimeCharset): CsuString;
function  MimeCharsetToCodePage(AMimeCharSet: TMimeCharset): Cardinal; overload;
function  MimeCharsetToCodePage(const AMimeCharSetString: CsuString): Cardinal; overload;

function  IsValidAnsiCodePage(ACodePage: Cardinal): Boolean; // includes UTF-8 and UTF-7
function  IsSingleByteCodePage(ACodePage: Cardinal): Boolean;
procedure GetSystemCodePageList(AOwnsObjectList : TObjectList);

function  GetCPInfoExA(CodePage: UINT; dwFlags : DWORD; lpCPInfoEx: PCPInfoExA): LongBOOL; stdcall;
function  GetCPInfoExW(CodePage: UINT; dwFlags : DWORD; lpCPInfoEx: PCPInfoExW): LongBOOL; stdcall;
function  GetCPInfoEx(CodePage: UINT; dwFlags : DWORD; lpCPInfoEx: PCPInfoEx): LongBOOL; stdcall;

var
    IcsSystemCodePage     : Cardinal;
    IcsSystemMaxCharSize  : Integer;
    IcsSystemIsSingleByte : Boolean;

implementation

var
    CharsetInfos : TCharsetInfos;

threadvar
    CPList : TObjectList;

function GetCPInfoExW; external kernel32 name 'GetCPInfoExW';
function GetCPInfoExA; external kernel32 name 'GetCPInfoExA';
function GetCPInfoEx;  external kernel32 name {$IFDEF UNICODE}'GetCPInfoExW' {$ELSE} 'GetCPInfoExA' {$ENDIF};


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function IsValidAnsiCodePage(ACodePage: Cardinal): Boolean;
var
    Info : _CpInfo;
begin
    Result := GetCPInfo(ACodePage, Info);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function IsSingleByteCodePage(ACodePage: Cardinal): Boolean;
var
    Info : _CpInfo;
begin
    if not GetCPInfo(ACodePage, Info) then
        raise Exception.Create('Codepage "' + IntToStr(ACodePage) + '" is no valid Ansi codepage');
    Result := Info.MaxCharSize = 1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function CpEnumNameProc(ACodePage : PChar) : Cardinal ; stdcall;
var
    Info : TCpInfoEx;
    Cp   : TCodePageObj;
begin
    CP := TCodePageObj.Create;
    Cp.FCodePage := StrToIntDef(ACodePage, 0);
    if (Cp.CodePage <> 0) then
    begin
        if GetCPInfoEx(Cp.CodePage, 0, @Info) then
        begin
            CP.FCodePageName := PChar(@Info.CodePageName[0]);
            CPList.Add(CP);
        end
        else
            CP.Free;
    end
    else
        CP.Free; 
    Result := 1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure GetSystemCodePageList(AOwnsObjectList : TObjectList);
begin
    CPList := AOwnsObjectList;
    CPList.OwnsObjects := TRUE;
    CPList.Clear;
    try
        EnumSystemCodePages(@CpEnumNameProc, CP_SUPPORTED);
    finally
        CPList := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ http://www.iana.org/assignments/character-sets }
function CodePageToMimeCharset(ACodePage: Cardinal): TMimeCharset;
begin
    case ACodePage of
        037   :  Result := IBM_037;
        437   :  Result := IBM_437;
        500   :  Result := IBM_500;
        850   :  Result := IBM_850;
        852   :  Result := IBM_852;
        855   :  Result := IBM_855;
        857   :  Result := IBM_857;
        858   :  Result := IBM_00858;
        860   :  Result := IBM_860;
        861   :  Result := IBM_861;
        862   :  Result := IBM_862;
        863   :  Result := IBM_863;
        864   :  Result := IBM_864;
        865   :  Result := IBM_865;
        866   :  Result := IBM_866;
        869   :  Result := IBM_869;
        870   :  Result := IBM_870;

        932   :  Result := Shift_JIS;
        936   :  Result := GBK;
        949   :  Result := ks_c_5601_1987;
        950   :  Result := BIG_5;

        1026  :  Result := IBM_1026;
        1047  :  Result := IBM_01047;
        1140  :  Result := IBM_01140;
        1141  :  Result := IBM_01141;
        1142  :  Result := IBM_01142;
        1143  :  Result := IBM_01143;
        1144  :  Result := IBM_01144;
        1145  :  Result := IBM_01145;
        1146  :  Result := IBM_01146;
        1147  :  Result := IBM_01147;
        1148  :  Result := IBM_01148;
        1149  :  Result := IBM_01149;

        1200  :  Result := UTF_16LE;
        1201  :  Result := UTF_16BE;

        1250  :  Result := WIN_1250;
        1251  :  Result := WIN_1251;
        1252  :  Result := WIN_1252;
        1253  :  Result := WIN_1253;
        1254  :  Result := WIN_1254;
        1255  :  Result := WIN_1255;
        1256  :  Result := WIN_1256;
        1257  :  Result := WIN_1257;
        1258  :  Result := WIN_1258;

        10000 :  Result := MACINTOSH;

        20866 :  Result := KOI8_R;

        20127 :  Result := US_ASCII;
        20261 :  Result := T_61;
        20936 :  Result := GB_2312_80;
        21866 :  Result := KOI8_U;

        28591 :  Result := ISO_8859_1;
        28592 :  Result := ISO_8859_2;
        28593 :  Result := ISO_8859_3;
        28594 :  Result := ISO_8859_4;
        28595 :  Result := ISO_8859_5;
        708,
        28596 :  Result := ISO_8859_6; //ASMO-708
        28597 :  Result := ISO_8859_7;
        28598,
        38598 :  Result := ISO_8859_8;
        28599 :  Result := ISO_8859_9;
        28603 :  Result := ISO_8859_13;
        874,
        28605 :  Result := ISO_8859_15;
        50220 :  Result := ISO_2022_JP;   // ? iso-2022-jp  ISO 2022 Japanese with no halfwidth Katakana; Japanese (JIS)
        50221 :  Result := ISO_2022_JP_1; // ? csISO2022JP  ISO 2022 Japanese with halfwidth Katakana; Japanese (JIS-Allow 1 byte Kana)
        50222 :  Result := ISO_2022_JP_2; // ? iso-2022-jp  ISO 2022 Japanese JIS X 0201-1989; Japanese (JIS-Allow 1 byte Kana - SO/SI)
        50225 :  Result := ISO_2022_KR;

        50227 :  Result := ISO_2022_CN;
        50229 :  Result := ISO_2022_CN_EXT;

        51932 :  Result := EUC_JP;
        51936 :  Result := GB_2312;

        65000 :  Result := UTF_7;
        65001 :  Result := UTF_8;

        else
            Result := WIN_1252;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function  CodePageToMimeCharsetString(ACodePage: Cardinal): CsuString;
var
    CS : TMimeCharset;
begin
    CS := CodePageToMimeCharset(ACodePage);
    Result := MimeCharsetToCharsetString(CS);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetMimeInfo(AMimeCharSet: TMimeCharset): PCharSetInfo;
begin
    Result := @CharsetInfos[Ord(AMimeCharSet)];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetMimeInfo(const AMimeCharSetString: CsuString): PCharSetInfo;
var
    I, J, Y, Len : Integer;
    S : CsuString;
begin
    if Length(AMimeCharSetString) > 0 then
    begin
        S := LowerCase(AMimeCharSetString);
        for I := Low(CharsetInfos) to High(CharsetInfos) do
        begin
            Len := Length(CharsetInfos[I].MimeName);
            Y := 1;
            for J := 1 to Len do
            begin
                if CharsetInfos[I].MimeName[J] = #$20 then
                begin
                    if S = Copy(CharsetInfos[I].MimeName, Y, J - Y) then
                    begin
                        Result := @CharsetInfos[I];
                        Exit;
                    end;
                    Y := J + 1;
                end
                else if J = Len then
                begin
                    if Y = 1 then
                    begin
                        if S = CharsetInfos[I].MimeName then
                        begin
                            Result := @CharsetInfos[I];
                            Exit;
                        end;
                    end
                    else
                        if S = Copy(CharsetInfos[I].MimeName, Y, J - Y + 1) then
                        begin
                            Result := @CharsetInfos[I];
                            Exit;
                        end;
                end;
            end;
        end;
    end;
    Result := GetMimeInfo(WIN_1252); // default
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function MimeCharsetToCodePage(AMimeCharSet: TMimeCharset): Cardinal;
begin
    Result := GetMimeInfo(AMimeCharSet)^.CodePage;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function MimeCharsetToCodePage(const AMimeCharSetString: CsuString): Cardinal;
var
    P : PCharsetInfo;
begin
    P := GetMimeInfo(AMimeCharSetString);
    if P <> nil then
        Result := P.CodePage
    else
        Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function MimeCharsetToCharsetString(AMimeCharSet: TMimeCharset): CsuString;
var
    Idx : Integer;
    P   : PCharsetInfo;
begin
    P   := GetMimeInfo(AMimeCharSet);
    Idx := Pos(' ', P^.MimeName) - 1;
    if Idx <= 0 then
        Result := P^.MimeName
    else
        Result := Copy(P^.MimeName, 1, Idx);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ The order here must match the item order of TMimeCharset !}
{ http://www.iana.org/assignments/character-sets }
procedure InitializeCharsetInfos;
var
    I    : Integer;
    Info : _CpInfo;
begin
    //--
    IcsSystemCodePage := GetAcp;
    IcsSystemMaxCharSize := 1;
    if GetCPInfo(IcsSystemCodePage, Info) then
        IcsSystemMaxCharSize := Info.MaxCharSize;
    IcsSystemIsSingleByte := IcsSystemMaxCharSize = 1;
    //--

    SetLength(CharsetInfos, 71);
    I := -1;
    Inc(I);
    CharsetInfos[I].MimeCharset   := UTF_8;
    CharsetInfos[I].CodePage      := CP_UTF8;
    CharsetInfos[I].MimeName      := CsuString('utf-8');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1250;
    CharsetInfos[I].CodePage      := 1250;
    CharsetInfos[I].MimeName      := CsuString('windows-1250');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1251;
    CharsetInfos[I].CodePage      := 1251;
    CharsetInfos[I].MimeName      := CsuString('windows-1251');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1252;
    CharsetInfos[I].CodePage      := 1252;
    CharsetInfos[I].MimeName      := CsuString('windows-1252');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1253;
    CharsetInfos[I].CodePage      := 1253;
    CharsetInfos[I].MimeName      := CsuString('windows-1253');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1254;
    CharsetInfos[I].CodePage      := 1254;
    CharsetInfos[I].MimeName      := CsuString('windows-1254');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1255;
    CharsetInfos[I].CodePage      := 1255;
    CharsetInfos[I].MimeName      := CsuString('windows-1255');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1256;
    CharsetInfos[I].CodePage      := 1256;
    CharsetInfos[I].MimeName      := CsuString('windows-1256');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1257;
    CharsetInfos[I].CodePage      := 1257;
    CharsetInfos[I].MimeName      := CsuString('windows-1257');
    Inc(I);
    CharsetInfos[I].MimeCharset   := WIN_1258;
    CharsetInfos[I].CodePage      := 1258;
    CharsetInfos[I].MimeName      := CsuString('windows-1258');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_1;
    CharsetInfos[I].CodePage      := 28591;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-1 iso_8859-1:1987 iso-ir-100 iso_8859-1 latin1 l1 ibm819 cp819 csisoatin1');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_2;
    CharsetInfos[I].CodePage      := 28592;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-2 iso_8859-2:1987 iso-ir-101 iso_8859-2 latin2 l2 csisolatin2');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_3;
    CharsetInfos[I].CodePage      := 28593;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-3 iso_8859-3:1988 iso-ir-109 iso_8859-3 latin3 l3 csisolatin3');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_4;
    CharsetInfos[I].CodePage      := 28594;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-4 iso_8859-4:1988 iso-ir-110 iso_8859-4 latin4 l4 csisolatin4');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_5;
    CharsetInfos[I].CodePage      := 28595;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-5 iso_8859-5:1988 iso-ir-144 iso_8859-5 cyrillic csisolatincyrillic');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_6;
    CharsetInfos[I].CodePage      := 28596;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-6 iso_8859-6:1987 iso-ir-127 iso_8859-6 ecma-114 asmo-708 arabic csisolatinarabic');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_7;
    CharsetInfos[I].CodePage      := 28597;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-7 iso_8859-7:1987 iso-ir-126 iso_8859-7 elot_928 ecma-118 greek greek8 csisolatingreek');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_8;
    CharsetInfos[I].CodePage      := 28598;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-8 iso_8859-8:1988 iso-ir-138 iso_8859-8 hebrew csisolatinhebrew');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_9;
    CharsetInfos[I].CodePage      := 28599;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-9 iso_8859-9:1989 iso-ir-148 iso_8859-9 latin5 l5 csisolatin5');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_13;  //Estonia
    CharsetInfos[I].CodePage      := 28603;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-13');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_8859_15;
    CharsetInfos[I].CodePage      := 28605;
    CharsetInfos[I].MimeName      := CsuString('iso-8859-15 iso_8859-15 latin-9');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_JP;   // ??
    CharsetInfos[I].CodePage      := 50220;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-jp csiso2022jp');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_JP_1; // ?? // not listed at IANA
    CharsetInfos[I].CodePage      := 50221;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-jp-1');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_JP_2; // ??
    CharsetInfos[I].CodePage      := 50222;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-jp-2 csiso2022jp2');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_KR;
    CharsetInfos[I].CodePage      := 50225;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-kr csiso2022kr');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_CN;
    CharsetInfos[I].CodePage      := 50227;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-cn');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ISO_2022_CN_EXT;
    CharsetInfos[I].CodePage      := 50229;
    CharsetInfos[I].MimeName      := CsuString('iso-2022-cn-ext');
    Inc(I);
    CharsetInfos[I].MimeCharset   := EUC_JP;
    CharsetInfos[I].CodePage      := 51932;
    CharsetInfos[I].MimeName      := CsuString('euc-jp cseucpkdfmtjapanese extended_unix_code_packed_format_for_japanese');
    Inc(I);
    CharsetInfos[I].MimeCharset   := GB_2312_80;
    CharsetInfos[I].CodePage      := 20936;
    CharsetInfos[I].MimeName      := CsuString('gb_2312-80 iso-ir-58 chinese csiso58gb231280');
    Inc(I);
    CharsetInfos[I].MimeCharset   := GB_2312;
    CharsetInfos[I].CodePage      := 51936;
    CharsetInfos[I].MimeName      := CsuString('gb2312 csgb2312 euc-cn');
    Inc(I);
    CharsetInfos[I].MimeCharset   := KOI8_R;
    CharsetInfos[I].CodePage      := 20866;
    CharsetInfos[I].MimeName      := CsuString('koi8-r cskoi8r');
    Inc(I);
    CharsetInfos[I].MimeCharset   := KOI8_U;
    CharsetInfos[I].CodePage      := 21866;
    CharsetInfos[I].MimeName      := CsuString('koi8-u');
    Inc(I);
    CharsetInfos[I].MimeCharset   := UTF_16LE;
    CharsetInfos[I].CodePage      := 1200;
    CharsetInfos[I].MimeName      := CsuString('utf-16 utf-16le');
    Inc(I);
    CharsetInfos[I].MimeCharset   := UTF_16BE;
    CharsetInfos[I].CodePage      := 1201;
    CharsetInfos[I].MimeName      := CsuString('utf-16be');
    Inc(I);
    CharsetInfos[I].MimeCharset   := UTF_7;
    CharsetInfos[I].CodePage      := CP_UTF7;
    CharsetInfos[I].MimeName      := CsuString('utf-7');
    Inc(I);
    CharsetInfos[I].MimeCharset   := Shift_JIS;
    CharsetInfos[I].CodePage      := 932;
    CharsetInfos[I].MimeName      := CsuString('shift_jis ms_kanji csshiftjis');
    Inc(I);
    CharsetInfos[I].MimeCharset   := GBK;
    CharsetInfos[I].CodePage      := 936;
    CharsetInfos[I].MimeName      := CsuString('gbk cp936 ms936 windows-936');
    Inc(I);
    CharsetInfos[I].MimeCharset   := BIG_5;
    CharsetInfos[I].CodePage      := 950;
    CharsetInfos[I].MimeName      := CsuString('big5 csbig5 big-5');
    Inc(I);
    CharsetInfos[I].MimeCharset   := ks_c_5601_1987;
    CharsetInfos[I].CodePage      := 949;
    CharsetInfos[I].MimeName      := CsuString('ks_c_5601-1987 iso-ir-149 ks_c_5601-1989 ksc_5601 korean csksc56011987');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_037;
    CharsetInfos[I].CodePage      := 037;
    CharsetInfos[I].MimeName      := CsuString('ibm037 cp037 ebcdic-cp-us ebcdic-cp-ca ebcdic-cp-wt ebcdic-cp-n csibm037');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_437;
    CharsetInfos[I].CodePage      := 437;
    CharsetInfos[I].MimeName      := CsuString('ibm437 cp437 437 cspc8codepage437');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_500;
    CharsetInfos[I].CodePage      := 500;
    CharsetInfos[I].MimeName      := CsuString('ibm500 cp500 ebcdic-cp-be ebcdic-cp-ch csibm500');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_850;
    CharsetInfos[I].CodePage      := 850;
    CharsetInfos[I].MimeName      := CsuString('ibm850 cp850 cspc850multilingual');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_852;
    CharsetInfos[I].CodePage      := 852;
    CharsetInfos[I].MimeName      := CsuString('ibm852 852 cp852 cspcp852');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_855;
    CharsetInfos[I].CodePage      := 855;
    CharsetInfos[I].MimeName      := CsuString('ibm855 cp855 855 csibm855');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_857;
    CharsetInfos[I].CodePage      := 857;
    CharsetInfos[I].MimeName      := CsuString('ibm857 cp857 857 csibm857');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_00858;
    CharsetInfos[I].CodePage      := 858;
    CharsetInfos[I].MimeName      := CsuString('ibm00858 ccsid00858 cp00858 pc-multilingual-850+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_860;
    CharsetInfos[I].CodePage      := 860;
    CharsetInfos[I].MimeName      := CsuString('ibm860 cp860 860 csibm860');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_861;
    CharsetInfos[I].CodePage      := 861;
    CharsetInfos[I].MimeName      := CsuString('ibm861 cp861 861 cp-is csibm861');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_862;
    CharsetInfos[I].CodePage      := 862;
    CharsetInfos[I].MimeName      := CsuString('ibm862 cp862 862 cspc862latinhebrew');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_863;
    CharsetInfos[I].CodePage      := 863;
    CharsetInfos[I].MimeName      := CsuString('ibm863 cp863 863 csibm863');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_864;
    CharsetInfos[I].CodePage      := 864;
    CharsetInfos[I].MimeName      := CsuString('ibm864 cp864 csibm864');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_865;
    CharsetInfos[I].CodePage      := 865;
    CharsetInfos[I].MimeName      := CsuString('ibm865 cp865 865 csibm865');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_866;
    CharsetInfos[I].CodePage      := 866;
    CharsetInfos[I].MimeName      := CsuString('ibm866 cp866 866 csibm866');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_869;
    CharsetInfos[I].CodePage      := 869;
    CharsetInfos[I].MimeName      := CsuString('ibm869 cp869 869 cp-gr csibm869');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_870;
    CharsetInfos[I].CodePage      := 870;
    CharsetInfos[I].MimeName      := CsuString('ibm870 cp870 ebcdic-cp-roece ebcdic-cp-yu csibm870');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_1026;
    CharsetInfos[I].CodePage      := 1026;
    CharsetInfos[I].MimeName      := CsuString('ibm1026 cp1026 csibm1026');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01047;
    CharsetInfos[I].CodePage      := 1047;
    CharsetInfos[I].MimeName      := CsuString('ibm1047 ibm-1047');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01140;
    CharsetInfos[I].CodePage      := 1140;
    CharsetInfos[I].MimeName      := CsuString('ibm01140 ccsid01140 cp01140 ebcdic-us-37+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01141;
    CharsetInfos[I].CodePage      := 1141;
    CharsetInfos[I].MimeName      := CsuString('ibm01141 ccsid01141 cp01141 ebcdic-de-273+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01142;
    CharsetInfos[I].CodePage      := 1142;
    CharsetInfos[I].MimeName      := CsuString('ibm01142 ccsid01142 cp01142 ebcdic-dk-277+euro ebcdic-no-277+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01143;
    CharsetInfos[I].CodePage      := 1143;
    CharsetInfos[I].MimeName      := CsuString('ibm01143 ccsid01143 cp01143 ebcdic-fi-278+euro ebcdic-se-278+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01144;
    CharsetInfos[I].CodePage      := 1144;
    CharsetInfos[I].MimeName      := CsuString('ibm01144 ccsid01144 cp01144 ebcdic-it-280+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01145;
    CharsetInfos[I].CodePage      := 1145;
    CharsetInfos[I].MimeName      := CsuString('ibm01145 ccsid01145 cp01145 ebcdic-es-284+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01146;
    CharsetInfos[I].CodePage      := 1146;
    CharsetInfos[I].MimeName      := CsuString('ibm01146 ccsid01146 cp01146 ebcdic-gb-285+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01147;
    CharsetInfos[I].CodePage      := 1147;
    CharsetInfos[I].MimeName      := CsuString('ibm01147 ccsid01147 cp01147 ebcdic-fr-297+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01148;
    CharsetInfos[I].CodePage      := 1148;
    CharsetInfos[I].MimeName      := CsuString('ibm01148 ccsid01148 cp01148 ebcdic-international-500+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := IBM_01149;
    CharsetInfos[I].CodePage      := 1149;
    CharsetInfos[I].MimeName      := CsuString('ibm01149 ccsid01149 cp01149 ebcdic-is-871+euro');
    Inc(I);
    CharsetInfos[I].MimeCharset   := MACINTOSH;
    CharsetInfos[I].CodePage      := 10000;
    CharsetInfos[I].MimeName      := CsuString('macintosh mac csmacintosh');
    Inc(I);
    CharsetInfos[I].MimeCharset   := US_ASCII;
    CharsetInfos[I].CodePage      := 20127;
    CharsetInfos[I].MimeName      := CsuString('us-ascii  ascii us ansi_x3.4-1968 iso-ir-6 ansi_x3.4-1986 iso_646.irv:1991 iso646-us ibm367 cp367 csascii');
    Inc(I);
    CharsetInfos[I].MimeCharset   := T_61; //7-bit or 8-bit?
    CharsetInfos[I].CodePage      := 20261;
    CharsetInfos[I].MimeName      := CsuString('t.61-8bit t.61-7bit iso-ir-103 iso-ir-102 csiso103t618bit csiso102t617bit');


end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

initialization
    InitializeCharsetInfos;

finalization


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
end.

