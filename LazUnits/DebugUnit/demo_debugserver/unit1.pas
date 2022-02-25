unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  dbugintf;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnDemo: TButton;
    Memo1: TMemo;
    procedure btnDemoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnDemoClick(Sender: TObject);
var
  i: integer;
begin
  Memo1.Append('Start Demo...');

  SendDateTime('Date/Time: ', Now);
  SendSeparator;
  SendMethodEnter('btnDemoClick');

  SendDebugEx('Demo Info', dlInformation);
  SendDebugEx('Demo Warning', dlWarning);
  SendDebugEx('Demo Error', dlError);
  SendSeparator;
  SendDebugFmt('Demo Fmt: %s=%d', ['value',69]);
  SendSeparator;
  SendDebugFmtEx('Demo: %s', ['a message'], dlInformation);
  SendDebugFmtEx('Demo: %s', ['a warning'], dlWarning);
  SendDebugFmtEx('Demo: %s', ['an error'], dlError);
  SendSeparator;

  SetDebuggingEnabled(False);
  for i:=1 to 10 do
    SendDebugFmt('Disabled count: %d', [i]); //will not show in debug viewer

  SetDebuggingEnabled(True);
  for i:=1 to 10 do
    SendDebugFmt('Enabled count: %d', [i]);

  SendMethodExit('btnDemoClick');
  SendSeparator;
  SendDateTime('Date/Time: ', Now);

  Memo1.Append('End Demo.');

end;
procedure TfrmMain.FormShow(Sender: TObject);
begin
  Memo1.Append('Watch the Debug Message Viewer while you press [Demo] ...');
  SendBoolean('GetDebuggingEnabled', GetDebuggingEnabled);
  SendSeparator;
end;
end.

