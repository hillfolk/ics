program IcsWebAppServ;

uses
  FMX.Forms,
  Fmx.Types,
  IcsWebAppServerMain in 'IcsWebAppServerMain.pas' {WebAppSrvForm},
  OverbyteIcsWebAppServerConfig in '..\Internet\OverbyteIcsWebAppServerConfig.pas',
  OverbyteIcsWebAppServerCounter in '..\Internet\OverbyteIcsWebAppServerCounter.pas',
  OverbyteIcsWebAppServerCounterView in '..\Internet\OverbyteIcsWebAppServerCounterView.pas',
  OverbyteIcsWebAppServerDataModule in '..\Internet\OverbyteIcsWebAppServerDataModule.pas' {WebAppSrvDataModule: TDataModule},
  OverbyteIcsWebAppServerHead in '..\Internet\OverbyteIcsWebAppServerHead.pas',
  OverbyteIcsWebAppServerHelloWorld in '..\Internet\OverbyteIcsWebAppServerHelloWorld.pas',
  OverbyteIcsWebAppServerHomePage in '..\Internet\OverbyteIcsWebAppServerHomePage.pas',
  OverbyteIcsWebAppServerHttpHandlerBase in '..\Internet\OverbyteIcsWebAppServerHttpHandlerBase.pas',
  OverbyteIcsWebAppServerLogin in '..\Internet\OverbyteIcsWebAppServerLogin.pas',
  OverbyteIcsWebAppServerMailer in '..\Internet\OverbyteIcsWebAppServerMailer.pas',
  OverbyteIcsWebAppServerSessionData in '..\Internet\OverbyteIcsWebAppServerSessionData.pas',
  OverbyteIcsWebAppServerUrlDefs in '..\Internet\OverbyteIcsWebAppServerUrlDefs.pas';

{$R *.res}

begin
  Application.Initialize;
  GlobalDisableFocusEffect := TRUE;
  Application.CreateForm(TWebAppSrvForm, WebAppSrvForm);
  Application.CreateForm(TWebAppSrvDataModule, WebAppSrvDataModule);
  Application.Run;
end.
