program OverbyteIcsWebAppServer;

{$R 'OverbyteIcsXpManifest.res' '..\..\..\Source\OverbyteIcsXpManifest.rc'}
{$R 'OverbyteIcsCommonVersion.res' '..\..\..\Source\OverbyteIcsCommonVersion.rc'}

uses
  Forms,
  OverbyteIcsIniFiles in '..\..\..\Source\OverbyteIcsIniFiles.pas',
  OverbyteIcsWebAppServerMain in 'OverbyteIcsWebAppServerMain.pas' {WebAppSrvForm},
  OverbyteIcsWebAppServerSessionData in 'OverbyteIcsWebAppServerSessionData.pas',
  OverbyteIcsWebAppServerLogin in 'OverbyteIcsWebAppServerLogin.pas',
  OverbyteIcsWebAppServerHelloWorld in 'OverbyteIcsWebAppServerHelloWorld.pas',
  OverbyteIcsWebAppServerUrlDefs in 'OverbyteIcsWebAppServerUrlDefs.pas',
  OverbyteIcsWebAppServerHttpHandlerBase in 'OverbyteIcsWebAppServerHttpHandlerBase.pas',
  OverbyteIcsWebAppServerDataModule in 'OverbyteIcsWebAppServerDataModule.pas' {WebAppSrvDataModule: TDataModule},
  OverbyteIcsWebAppServerCounter in 'OverbyteIcsWebAppServerCounter.pas',
  OverbyteIcsWebAppServerHomePage in 'OverbyteIcsWebAppServerHomePage.pas',
  OverbyteIcsWebAppServerConfig in 'OverbyteIcsWebAppServerConfig.pas',
  OverbyteIcsWebAppServerCounterView in 'OverbyteIcsWebAppServerCounterView.pas',
  OverbyteIcsWebAppServerHead in 'OverbyteIcsWebAppServerHead.pas',
  OverbyteIcsWebAppServerMailer in 'OverbyteIcsWebAppServerMailer.pas',
  OverbyteIcsFormDataDecoder in '..\..\..\Source\OverbyteIcsFormDataDecoder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TWebAppSrvForm, WebAppSrvForm);
  Application.CreateForm(TWebAppSrvDataModule, WebAppSrvDataModule);
  Application.Run;
end.
