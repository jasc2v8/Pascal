{ Version 2.0 - Author jasc2v8 at yahoo dot com

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

unit debugunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  { TDebugForm }

  TDebugForm = class(TForm)
    Memo: TMemo;
    ButtonClear: TButton;
    procedure ButtonClearClick(Sender: TObject);
  private

  public

  end;

var
  DebugForm: TDebugForm;

  procedure Debugln(Arg1: Variant);
  procedure Debugln(Arg1, Arg2: Variant);
  procedure Debugln(Arg1, Arg2, Arg3: Variant);
  procedure Debugln(Arg1, Arg2, Arg3, Arg4: Variant);
  procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5: Variant);
  procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Variant);
  procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: Variant);
  procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: Variant);

  procedure Debugln(Args: array of Variant);

  procedure Debugln(Fmt:string; Args: array of Const);

implementation

{$R *.lfm}

{ TDebugForm }

procedure Debugln(Arg1: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1);  //will write boolean True or False
  sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3, Arg4: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  WriteStr(sbuf,Arg4); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  WriteStr(sbuf,Arg4); sout:=sout+sbuf;
  WriteStr(sbuf,Arg5); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  WriteStr(sbuf,Arg4); sout:=sout+sbuf;
  WriteStr(sbuf,Arg5); sout:=sout+sbuf;
  WriteStr(sbuf,Arg6); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  WriteStr(sbuf,Arg4); sout:=sout+sbuf;
  WriteStr(sbuf,Arg5); sout:=sout+sbuf;
  WriteStr(sbuf,Arg6); sout:=sout+sbuf;
  WriteStr(sbuf,Arg7); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: Variant);
var
  sbuf, sout: string;
begin
  WriteStr(sbuf,Arg1); sout:=sout+sbuf;
  WriteStr(sbuf,Arg2); sout:=sout+sbuf;
  WriteStr(sbuf,Arg3); sout:=sout+sbuf;
  WriteStr(sbuf,Arg4); sout:=sout+sbuf;
  WriteStr(sbuf,Arg5); sout:=sout+sbuf;
  WriteStr(sbuf,Arg6); sout:=sout+sbuf;
  WriteStr(sbuf,Arg7); sout:=sout+sbuf;
  WriteStr(sbuf,Arg8); sout:=sout+sbuf;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Args: array of Variant);
var
  i: integer;
  sbuf, sout: string;
begin
  for i:=Low(Args) to High(Args) do begin
    WriteStr(sbuf, Args[i]);
    sout:=sout+sbuf;
  end;
  DebugForm.Memo.Append(sout);
end;
procedure Debugln(Fmt:string; Args: array of Const);
begin
  DebugForm.Memo.Append(Format(Fmt, Args));
end;
procedure TDebugForm.ButtonClearClick(Sender: TObject);
begin
  Memo.Clear;
end;

end.

