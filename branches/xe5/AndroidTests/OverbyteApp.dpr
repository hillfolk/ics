program OverbyteApp;

uses
  FMX.Forms,
  TabbedTemplate in 'TabbedTemplate.pas' {TabbedForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTabbedForm, TabbedForm);
  Application.Run;
end.
