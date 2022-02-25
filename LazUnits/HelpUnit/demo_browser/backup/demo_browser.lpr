program demo_browser;

{$mode objfpc}{$H+}
{$apptype gui}

uses
  Interfaces,
  Forms, demo_browser, htmlbrowser, htmlfileviewer;

{$R *.res}

begin
  Application.Title:='LazHelpUnit Demo';
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
