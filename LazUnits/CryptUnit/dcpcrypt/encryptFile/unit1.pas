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
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DCPrc4, DCPsha1;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonEnCrypt: TButton;
    ButtonDeCrypt: TButton;
    EditSource: TEdit;
    EditTarget: TEdit;
    LabelSource: TLabel;
    LabelDestination: TLabel;
    procedure ButtonEnCryptClick(Sender: TObject);
    procedure ButtonDeCryptClick(Sender: TObject);
  private
  public
    DCP_rc4_1: TDCP_rc4;
    DCP_sha1_1: TDCP_sha1;
  end;

var
  Form1: TForm1;
  KeyStr: string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonEnCryptClick(Sender: TObject);
var
  Cipher: TDCP_rc4;
  Source, Target: TFileStream;
begin

  if not FileExists(EditSource.Text) then begin
  ShowMessage('ERROR: Source file does not exist');
  Exit;
  end;

  if FileExists(EditTarget.Text) then
    RenameFile(EditTarget.Text, EditTarget.Text+'.bak');

  try
    Source:= TFileStream.Create(EditSource.Text,fmOpenRead);
    Target:= TFileStream.Create(EditTarget.Text,fmCreate);
    Cipher:= TDCP_rc4.Create(Self);
    Cipher.InitStr(KeyStr,TDCP_sha1);
    Cipher.EncryptStream(Source,Target,Source.Size);
    Cipher.Burn;
    Cipher.Free;
    Target.Free;
    Source.Free;
    ShowMessage('File encrypted');
  except
    ShowMessage('ERROR: File IO error');
  end;
end;

procedure TForm1.ButtonDeCryptClick(Sender: TObject);
var
  Cipher: TDCP_rc4;
  Source, Target: TFileStream;
  begin

  if not FileExists(EditTarget.Text) then begin
    ShowMessage('ERROR: Destination file does not exist');
    Exit;
  end;

   if FileExists(EditSource.Text) then
    RenameFile(EditSource.Text, EditSource.Text+'.bak');

   try
     Source:= TFileStream.Create(EditTarget.Text,fmOpenRead);
     Target:= TFileStream.Create(EditSource.Text,fmCreate);
     Cipher:= TDCP_rc4.Create(Self);
     Cipher.InitStr(KeyStr,TDCP_sha1);
     Cipher.DecryptStream(Source,Target,Source.Size);
     Cipher.Burn;
     Cipher.Free;
     Target.Free;
     Source.Free;
     ShowMessage('File decrypted');
   except
     ShowMessage('ERROR: File IO error');
   end;
  end;

end.


