{ Version 1.0 - Author jasc2v8 at yahoo dot com

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org> }

unit Unit1;

{ The objective of this demo is to prove dbugsrv is thread-safe }
{ Tested as thread-safe on Windows only }
{ https://www.freepascal.org/docs-html/fcl/dbugintf/index-5.html }
{ Debug Message Viewer, File, Quit: terminate dbugsrv process }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  threadunit, dbugintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStartThread: TButton;
    btnStartUnit: TButton;
    btnStartBoth: TButton;
    Memo1: TMemo;
    procedure btnStartBothClick(Sender: TObject);
    procedure btnStartUnitClick(Sender: TObject);
    procedure btnStartThreadClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure StopThreads;

  public
    Threads: array of TThreadUnit;
    nThreads: integer;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnStartThreadClick(Sender: TObject);
var
  i: integer;
begin

  nThreads:=8;

  SetLength(Threads,nThreads);

  for i:=0 to nThreads-1 do begin;
    Threads[i]:=TThreadUnit.Create(True);
    Threads[i].Name:='T'+i.ToString;
    Threads[i].Start;
  end;

end;
procedure TForm1.btnStartUnitClick(Sender: TObject);
var
  i: integer;
begin

  for i:=1 to 10 do begin
    Sleep(500);
    Application.ProcessMessages;
    Memo1.Append('Unit1 count: '+i.ToString);
    SendDebugFmt('Unit1 count: %d', [i]);
  end;

  Memo1.Append('Unit1 done.');
  SendDebug('Unit1 done.');

  StopThreads;

end;
procedure TForm1.btnStartBothClick(Sender: TObject);
begin
  SendDateTime('Date/Time: ', Now);
  SendSeparator;
  SendMethodEnter('btnStartBothClick');

  btnStartThreadClick(nil);
  btnStartUnitClick(nil);

  SendMethodExit('btnStartBothClick');
  SendSeparator;
  SendDateTime('Date/Time: ', Now);
end;

procedure TForm1.StopThreads;
var
  i: integer;
begin
  for i:=Low(Threads) to High(Threads) do begin
    if Assigned(Threads[i]) then begin
      Threads[i].Terminate;
      Threads[i].WaitFor;
      FreeAndNil(Threads[i]);
    end;
  end;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopThreads;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //SendDebug('FormShow');
  SendBoolean('GetDebuggingEnabled', GetDebuggingEnabled);
  SendDebugEx('Demo Info', dlInformation);
  SendDebugEx('Demo Warning', dlWarning);
  SendDebugEx('Demo Error', dlError);
  SendSeparator;
  SendDebugFmtEx('Demo: %s', ['a message'], dlInformation);
  SendDebugFmtEx('Demo: %s', ['a warning'], dlWarning);
  SendDebugFmtEx('Demo: %s', ['an error'], dlError);
  SendSeparator;
end;

end.
