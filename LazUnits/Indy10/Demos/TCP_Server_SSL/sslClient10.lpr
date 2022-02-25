program sslClient10;

{$MODE Delphi}

uses
  Forms, Interfaces,
  sslClient10Main in 'sslClient10Main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

