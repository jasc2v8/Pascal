program HelpUnitManager;

{$mode objfpc}{$H+}
{$apptype gui}

uses
  Interfaces,
  Forms, main, helpunit, helpunitresources, turbopoweripro;

{$R *.res}

begin
  Application.Title:='Using Help in Lazarus';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
