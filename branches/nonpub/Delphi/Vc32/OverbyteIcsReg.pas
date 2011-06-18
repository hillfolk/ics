unit OverbyteIcsReg;

{$I OverbyteIcsDefs.inc}
{$IFDEF USE_SSL}
    {$I OverbyteIcsSslDefs.inc}
{$ENDIF}

interface

uses
  SysUtils, Classes,
  OverbyteIcsWSocket,
  OverbyteIcsDnsQuery,
  OverbyteIcsEmulVT,
  OverbyteIcsMimeDec,
  OverbyteIcsMultiProgressBar,
  OverbyteIcsTnCnx, OverbyteIcsTnEmulVT, OverbyteIcsTnScript,
  OverbyteIcsFtpCli, OverbyteIcsFtpSrv, OverbyteIcsMultipartFtpDownloader,
  OverbyteIcsHttpProt, OverbyteIcsHttpSrv, OverbyteIcsMultipartHttpDownloader,
  OverbyteIcsHttpAppServer,
  OverbyteIcsTimeList,
  OverbyteIcsCharsetComboBox,
  OverbyteIcsPop3Prot,
  OverbyteIcsSmtpProt,
  OverbyteIcsNntpCli,
  OverbyteIcsFingCli,
{$IFNDEF BCB}
  OverbyteIcsWSocketTS,
{$ENDIF}
  OverbyteIcsPing
{$IFDEF USE_SSL}
  , OverbyteIcsSslSessionCache
  , OverbyteIcsSslThrdLock
{$ENDIF}
{$IFDEF VCL}
  , OverbyteIcsLogger
{$ENDIF}
{$IFDEF WIN32}
  , OverbyteIcsWSocketE
  , OverbyteIcsWSocketS
{$ENDIF}
  ;

procedure Register;

implementation

uses
{$IFDEF WIN32}
{$IFDEF COMPILER10_UP}
  Windows,
  ToolsApi,
{$ENDIF}  
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors;
{$ELSE}
  DsgnIntf;
{$ENDIF}
{$ENDIF}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin

  RegisterComponents('Overbyte ICS', [
    TWSocket,
    TDnsQuery, TEmulVT, TFingerCli, TPing,
    TMimeDecode, TMimeDecodeEx, TMimeDecodeW,
    TMultiProgressBar,
    TTimeList,
    THttpAppSrv,
    TTnCnx, TTnEmulVT, TTnScript,
    TFtpClient, TFtpServer, TMultipartFtpDownloader,
    THttpCli, THttpServer, TMultipartHttpDownloader,
    TPop3Cli, TSyncPop3Cli,
    TSmtpCli, TSyncSmtpCli, THtmlSmtpCli,
    TNntpCli, THtmlNntpCli,
{$IFNDEF BCB}
    TWSocketThrdServer,
{$ENDIF}
    TIcsCharsetComboBox
{$IFDEF VCL}
    ,TIcsLogger
{$ENDIF}
  ]);

{$IFDEF USE_SSL}
  RegisterComponents('Overbyte ICS SSL', [
    TSslWSocket,
    TSslContext,
    TSslFtpClient, TSslFtpServer,
    TSslHttpCli, TSslHttpServer,
    TSslPop3Cli,
    TSslSmtpCli,
    TSslNntpCli,
    TSslAvlSessionCache,
{$IFNDEF BCB}
    TSslWSocketThrdServer,
{$ENDIF}
    TSslStaticLock
  {$IFNDEF NO_DYNLOCK}
    ,TSslDynamicLock
  {$ENDIF}
  {$IFNDEF OPENSSL_NO_ENGINE}
    ,TSslEngine
  {$ENDIF}
  ]);
{$ENDIF}

{$IFDEF WIN32}
  RegisterComponents('Overbyte ICS', [
    TWSocketServer
  ]);

{$IFDEF USE_SSL}
  RegisterComponents('Overbyte ICS SSL', [
    TSslWSocketServer
  ]);
{$ENDIF}

  RegisterPropertyEditor(TypeInfo(AnsiString), TWSocket, 'LineEnd',
    TWSocketLineEndProperty);
    
{$IFDEF COMPILER10_UP}
  ForceDemandLoadState(dlDisable); // Required to show our product icon on splash screen
{$ENDIF}

{$ENDIF}
end;

{$IFDEF COMPILER10_UP}
{$R OverbyteIcsProductIcon.res}
const
{$IFDEF COMPILER14_UP}
    sIcsSplashImg       = 'ICSPRODUCTICONBLACK';
{$ELSE}
    sIcsSplashImg       = 'ICSPRODUCTICON';
{$ENDIF}
    sIcsLongProductName = 'Internet Component Suite V7';
    sIcsFreeware        = 'Freeware';
    sIcsDescription     = sIcsLongProductName + #13#10 +
                          //'Copyright (C) 1996-2011 by François PIETTE'+ #13#10 +
                          // Actually there's source included with different
                          // copyright, so either all or none should be mentioned
                          // here.
                          'http://www.overbyte.be/' + #13#10 +
                          'svn://svn.overbyte.be/ics/trunk' + #13#10 +
                          'http://svn.overbyte.be:8443/svn/ics/trunk' + #13#10 +
                          'User and password = "ics"';

var
    AboutBoxServices: IOTAAboutBoxServices = nil;
    AboutBoxIndex: Integer = -1;

procedure PutIcsIconOnSplashScreen;
var
    hImage: HBITMAP;
begin
    if Assigned(SplashScreenServices) then begin
        hImage := LoadBitmap(FindResourceHInstance(HInstance), sIcsSplashImg);
        SplashScreenServices.AddPluginBitmap(sIcsLongProductName, hImage,
                                             FALSE, sIcsFreeware);
    end;
end;

procedure RegisterAboutBox;
begin
    if Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutBoxServices) then begin
        AboutBoxIndex := AboutBoxServices.AddPluginInfo(sIcsLongProductName,
          sIcsDescription, 0, FALSE, sIcsFreeware);
    end;
end;

procedure UnregisterAboutBox;
begin
  if (AboutBoxIndex <> -1) and Assigned(AboutBoxServices) then begin
    AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
    AboutBoxIndex := -1;
  end;
end;

initialization
  PutIcsIconOnSplashScreen;
  RegisterAboutBox;

finalization
  UnregisterAboutBox;
{$ENDIF COMPILER10_UP}

end.

