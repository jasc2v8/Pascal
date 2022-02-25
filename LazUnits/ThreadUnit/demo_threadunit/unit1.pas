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

{ with help from:
  http://wiki.freepascal.org/Example_of_multi-threaded_application:_array_of_threads
  https://www.getlazarus.org/forums/viewtopic.php?t=52 }

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  threadunit;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStartBoth: TButton;
    btnStartThread: TButton;
    btnStartProc: TButton;
    Memo1: TMemo;
    procedure btnStartBothClick(Sender: TObject);
    procedure btnStartProcClick(Sender: TObject);
    procedure btnStartThreadClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StopThreads;
  private

  public
    Thread1: TThreadUnit;
    Thread2: TThreadUnit;

  end;

var
  Form1: TForm1;

implementation


{$R *.lfm}

{ TForm1 }

procedure TForm1.btnStartThreadClick(Sender: TObject);
begin

  Thread1:=TThreadUnit.Create(True);
  Thread2:=TThreadUnit.Create(True);

  Thread1.Name:='T1';
  Thread2.Name:='T2';

  Thread1.Start;
  Thread2.Start;

end;

procedure TForm1.btnStartProcClick(Sender: TObject);
var
  i: integer;
begin

  for i:=1 to 10 do begin
    Sleep(500);
    Application.ProcessMessages;

    Memo1.Append('Unit1 count: '+i.ToString);
  end;

  Memo1.Append('Unit1 done.');

  StopThreads;

end;

procedure TForm1.btnStartBothClick(Sender: TObject);
begin
  btnStartThreadClick(nil);
  btnStartProcClick(nil);
end;

procedure TForm1.StopThreads;
begin
  if Assigned(Thread1) then begin
    Thread1.Terminate;
    Thread1.WaitFor;
    if not Thread1.FreeOnTerminate then FreeAndNil(Thread1);
  end;
  if Assigned(Thread2) then begin
    Thread2.Terminate;
    Thread2.WaitFor;
    if not Thread2.FreeOnTerminate then FreeAndNil(Thread2);
  end;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopThreads;
end;

end.

