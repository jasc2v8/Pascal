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

unit threadunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Dialogs, dbugintf;

type

  { TThreadUnit }

  TThreadUnit = class(TThread)
  private
    FStatus: string;
    FName: string;
    procedure Update;
    procedure OnTerminate;
  protected
    procedure Execute; override;
  public
    property Status: string Read FStatus Write FStatus;
    property Name: string Read FName Write FName;
    constructor Create(CreateSuspended: Boolean);
  end;

implementation

uses Unit1;

{ TThreadUnit }

procedure TThreadUnit.OnTerminate;
begin
  Form1.Memo1.Append('Terminate: '+Name);
  SendDebug('Terminate: '+Name);
end;

procedure TThreadUnit.Update;
begin
  Form1.Memo1.Append(Status);
  SendDebug(Status);
end;

procedure TThreadUnit.Execute;
var
  i: integer;
begin

  { simulate some work }
  for i:=1 to 10 do begin
    if Terminated then break;
    Sleep(Random(500)+500);
    Status:=Format('%s count: %d', [Name, i]);
    Synchronize(@Update);
  end;

  Synchronize(@OnTerminate);

end;

constructor TThreadUnit.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := False; //must be false
end;


end.

