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
  Classes, SysUtils, ComCtrls, process, ShellApi,
  dialogs;  //debug

type

  { TThreadUnit }

  TThreadUnit = class(TThread)
  private
    FStatus: string;
    FName: string;
    Fcmd: string;
    Fout: string;
    Fparams: array[0..3] of string;
    Fitem: integer;
    procedure Update;
    procedure OnTerminate;
  protected
    procedure Execute; override;
  public
    property Status: string Read FStatus Write FStatus;
    property Name: string Read FName Write FName;
    constructor Create(item: integer; params: array of string; CreateSuspended: Boolean);
  end;

implementation

uses Unit1;

{ TThreadUnit }

procedure TThreadUnit.OnTerminate;
begin
  Form1.ListBox1.Items[Fitem]:=Form1.ListBox1.Items[Fitem]+'DONE!';
  Dec(ThreadsRunningCount);
  if ThreadsRunningCount<=0 then begin
    Form1.ProgressBar1.Visible:=False;
    Form1.ProgressBar1.Style:=pbstNormal;
  end;
end;
procedure TThreadUnit.Update;
begin
  //not implemented
end;
procedure TThreadUnit.Execute;
var
  i: integer;
  r: boolean;
  AProcess: TProcess;
begin

  AProcess:=TProcess.Create(nil);
  AProcess.Executable:=Fparams[0];

  for i:=1 to Length(Fparams)-1 do begin
    AProcess.Parameters.Add(Fparams[i]);
  end;

  //AProcess.Options:=[poNoConsole];
  //AProcess.Options:=AProcess.Options+[poWaitOnExit, poNoConsole];
  AProcess.Options:=[poWaitOnExit, poNoConsole];
  //AProcess.Options:=[poWaitOnExit];
  AProcess.Execute;
  while AProcess.Running do begin
    Sleep(1);
  end;
  AProcess.Free;
  Synchronize(@OnTerminate);
end;

constructor TThreadUnit.Create(item: integer; params: array of string; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate:=True;
  //Fcmd:=cmd;
  Fout:='';
  Fparams:=params;
  Fitem:= item;
end;

end.

