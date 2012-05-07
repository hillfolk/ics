program IcsFtpTst;

uses
  FMX.Forms, OverbyteIcsIniFiles in '..\..\..\Source\OverbyteIcsIniFiles.pas',
  FMX.Types,
  IcsFtpTst1 in 'IcsFtpTst1.pas' {FtpReceiveForm},
  IcsFtpTst2 in 'IcsFtpTst2.pas' {DirectoryForm};

{$R *.res}

begin
  Application.Initialize;
  GlobalDisableFocusEffect := TRUE;
  Application.CreateForm(TFtpReceiveForm, FtpReceiveForm);
  Application.CreateForm(TDirectoryForm, DirectoryForm);
  Application.Run;
end.
