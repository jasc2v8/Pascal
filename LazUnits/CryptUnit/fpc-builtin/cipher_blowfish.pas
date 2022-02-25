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

unit cipher_blowfish;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, blowfish, base64;

function EnCrypt(aText:string; aKey:string):string;
function DeCrypt(aText:string; aKey:string):string;

implementation

function EnCrypt(aText:string; aKey:string):string;
var
  encoder: TBlowFishEncryptStream;
  stream: TStringStream;
begin
  stream:=TStringStream.Create('');
  encoder:=TBlowFishEncryptStream.Create(aKey,stream);
  encoder.WriteAnsiString(aText);
  encoder.Free;
  Result:=EncodeStringBase64(stream.DataString);
  stream.Free;
end;

function DeCrypt(aText:string; aKey:string):string;
var
  decoder: TBlowFishDeCryptStream;
  stream: TStringStream;
begin
  stream:=TStringStream.Create(DecodeStringBase64(AText));
  decoder:=TBlowFishDeCryptStream.Create(aKey,stream);
  Result:=decoder.ReadAnsiString;
  decoder.Free;
  stream.Free;
end;

end.

