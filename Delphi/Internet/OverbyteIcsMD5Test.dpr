program OverbyteIcsMD5Test;

uses
  Forms,
  OverbyteIcsMD5Test1 in 'OverbyteIcsMD5Test1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.