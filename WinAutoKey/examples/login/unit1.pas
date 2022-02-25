{
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

For more information, please refer to <http://unlicense.org>
}

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  WinAutoKey, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    Memo1: TMemo;
    procedure ButtonOKClick(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure ClearKeyBuffer;
var
  i: integer;
begin
  i:=0;
  repeat
    GetKeyState(VK_ESCAPE);
    Inc(i);
  until i>10000;
end;

function IsAborted(Key: Word): Boolean;
var
  i: Word;
Begin
  Result:=False;
  Application.ProcessMessages;
  if GetVKeyState(Key)=1 then begin
    Form1.Memo1.Append('Aborted!');
    Application.BringToFront;
    Result:=True;
  end;
end;

procedure Memoln(Line: String);begin
  Form1.Memo1.Append(Line);
end;

{ TForm1 }

procedure TForm1.ButtonOKClick(Sender: TObject);
var
  i: integer;
  w: word;
begin

  Memoln('Start...');
  if IsAborted(VK_ESCAPE) then Exit;
  OpenURL('http://executeautomation.com/demosite/Login.html');

  if IsAborted(VK_ESCAPE) then Exit;
  WinWait('Execute Automation','','',5);

  SetKeyDelay(75); //slow down for demo

  Send(VK_TAB,2);
  if IsAborted(VK_ESCAPE) then Exit;

  Send(['Username',VK_TAB,'Password',VK_TAB,VK_RETURN]);
  if IsAborted(VK_ESCAPE) then Exit;
  WinSleep;

  Send(VK_TAB,12);
  Send([VK_RETURN,VK_DOWN,VK_RETURN,VK_TAB]);
  if IsAborted(VK_ESCAPE) then Exit;

  Send(['WAK',VK_TAB,'First',VK_TAB,'Middle']);
  Send(VK_TAB,4);
  Send([VK_SPACE, VK_TAB, VK_RETURN]);
  if IsAborted(VK_ESCAPE) then Exit;

  Memoln('End.');

  Application.Minimize;
  Application.Restore;
end;
end.

