program demo;

{$mode objfpc}{$H+}
{$apptype gui}

uses
  Interfaces,
  Forms, unit1, htmlfileviewer;

{$R *.res}

begin
  Application.Title:='HTMLFileViewer Demo';
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(THelpForm, Viewer);
  Application.Run;
end.
