program HTTPS_WebServer;

{$mode objfpc}{$H+}

uses
  Forms, Interfaces, unit1;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
