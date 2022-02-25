{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org> }

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, LclIntf,
  EventLogUnit;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonWrite: TButton;
    ButtonOpen: TButton;
    Memo1: TMemo;
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonWriteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FLog: TEventLogCustom;
  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
  LOGFILE = 'demo.log';

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure Memoln(Fmt: String; Args: array of Const);begin
  Form1.Memo1.Append(Format(Fmt, Args));
end;

{ TForm1 }

procedure TForm1.ButtonWriteClick(Sender: TObject);
begin
  FLog.Info('Demo Started');
  FLog.Debug('Debug message');
  FLog.Error('Error message');
  FLog.Warning('Warning message');

  FLog.Message(etInfo, 'Demo Completed');

  FLog.Message(''); //DefaultEventType is etDebug

  Memo1.Append('Messages written to log file');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FLog.Free;
end;

procedure TForm1.ButtonOpenClick(Sender: TObject);
begin
  if FileExists(LOGFILE) then
    OpenDocument(LOGFILE)
  else
    Memo1.Append('Log file doesn''t exist');
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  FLog:=TEventLogCustom.Create(LOGFILE, true);
end;
end.

