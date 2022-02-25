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

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  ExtCtrls,
  //cipher_blowfish;
  cipher_xor;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonCrypt: TButton;
    ButtonClear: TButton;
    EditResult: TLabeledEdit;
    EditPassword: TLabeledEdit;
    EditKey: TLabeledEdit;
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonCryptClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

{ TForm1 }

procedure TForm1.ButtonCryptClick(Sender: TObject);

begin

  if (EditPassword.Text='') or (EditKey.Text='') then begin
    EditResult.Text:='Enter password and key then press ENcode';
    Exit;
  end;

  if ButtonCrypt.Caption='ENcode' then begin
    EditResult.Text:=EnCrypt(EditPassword.Text, EditKey.Text);
    ButtonCrypt.Caption:='DEcode';
  end else begin
    EditResult.Text:=DeCrypt(EditResult.Text, EditKey.Text);
    ButtonCrypt.Caption:='ENcode';
  end;

end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  EditPassword.Clear;
  EditKey.Clear;
  EditResult.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.

