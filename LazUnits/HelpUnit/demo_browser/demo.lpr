program demo;

{$mode objfpc}{$H+}
{$apptype gui}

uses
  Interfaces,
  Forms, unit1, htmlbrowser;

{$R *.res}

begin
  Application.Title:='HTMLBrowser Demo';
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
