program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unit1
  { you can add units after this } ;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='WinAutoKey Tray App Template';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

