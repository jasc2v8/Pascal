program BulkInstallUtility;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, popup, debugHelper;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='Bulk Install Utility';
  
  RequireDerivedFormResource:=True;

  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPopup, frmPopup);
  Application.CreateForm(TDebugForm, DEBUG);  
  Application.Run;
end.

