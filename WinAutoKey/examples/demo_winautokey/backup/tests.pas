unit tests;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, LCLType, MouseAndKeyInput,
  Windows, //VkKeyScanA
  Dialogs; //debug with ShowMessage

procedure TestKeyInput;
procedure TestKeyInputTranslate;
procedure TestKeyInputTranslateAllKeys;



procedure NewSend(const VK1: Byte; const VK2: Byte; const VK3: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);

procedure NewSend(const VK1: Byte; const VK2: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);

procedure NewSend(const VK1: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);

procedure NewSend(const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);

//procedure NewSend(const StringValue: String;  Count: Integer=1; Delay: Integer=0);

implementation

//only sends VK keys mapped in LCLType, not ASCII codes
procedure TestKeyInput;
var
  i: integer;
  Keys: String;
begin

  //output'0123456789abcdefghijklmnopqrstuvwxyz'; //$30-$39+$61-$7A
  for i:=VK_0 to VK_Z do                          //$30-$39+$41-$5A
    KeyInput.Press(i); //keyinputintf.pas
  KeyInput.Press(VK_RETURN);

  //output '9a' ignores unmapped key $3A
  //KeyInput.Press(VK_9);
  //KeyInput.Press($3A);
  //KeyInput.Press(VK_A);

  KeyInput.Press(VK_A);     //input: 'A' = $41, output: 'a' = $61, ok: Shift for 'A'
  KeyInput.Press(Ord('A')); //input: 'A' = $41, output: 'a' = $61, ok: Shift for 'A'
  KeyInput.Press(Ord('a')); //input:          , output: '1' = $61, ok: VK_NUMPAD1
  KeyInput.Press(VK_RETURN);

  //no KeyInput.Press('1234567890abcdefghijklmnopqrstuvwxyz'); //lowercase not mapped
  //ok KeyInput.Press('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'); //uppercase is mapped
  KeyInput.Apply([ssShift]);
  KeyInput.Press('1234567890abc'); //output='!@#$%^&*()123' //lowercase not mapped
  KeyInput.Press(VK_RETURN);
  KeyInput.Press('1234567890ABC'); //output='!@#$%^&*()ABC' //uppercase is mapped
  KeyInput.UnApply([ssShift]);
  KeyInput.Press(VK_RETURN);

  KeyInput.Press('a'); //output='1' //lowercase not mapped
  KeyInput.Press('A'); //output='a' //lowercase not mapped
  KeyInput.Press(VK_RETURN);

  //KeyInput.Press(VK_SHIFT); //does not 'stick', use [ssShift]

end;
//translates VK mapped keys to ASCII key codes, with ssShift
procedure TestKeyInputTranslate;
  FUNCTION TranslateKey(Key: Char): SHORT;
  BEGIN
    Result:=VkKeyScanA(Key);
  END;
begin
  KeyInput.Press('A');               //output: 'a'
  KeyInput.Press('a');               //output: '1'
  KeyInput.Press(TranslateKey('A')); //output: 'a'=$61
  KeyInput.Press(TranslateKey('a')); //output: 'a'=$61 SUCCESS!
  KeyInput.Press(VK_RETURN);

  KeyInput.Press('1');               //output: '1'
  KeyInput.Press('!');               //output: '1'
  KeyInput.Press(TranslateKey('1')); //output: '1'
  KeyInput.Press(TranslateKey('!')); //output: '1'
  KeyInput.Press(VK_RETURN);

  KeyInput.Apply([ssShift]);
  KeyInput.Press('1');               //output: '!'
  KeyInput.Press(TranslateKey('1')); //output: '!'
  KeyInput.UnApply([ssShift]);
  KeyInput.Press(VK_RETURN);

  //KeyInput.Press('[');              //out: '' //not mapped
  //KeyInput.Press('{');              //out: '' //not mapped
  KeyInput.Press(TranslateKey('['));  //out: '[' SUCCESS!
  KeyInput.Apply([ssShift]);
  //KeyInput.Press('[')               //out: '' //not mapped
  KeyInput.Press(TranslateKey('['));  //out: '{' SUCCESS!
  KeyInput.UnApply([ssShift]);
  KeyInput.Press(VK_RETURN);

end;
//translates VK mapped keys to ASCII key codes, with ssShift
//uses windows.VkKeyScanA
procedure TestKeyInputTranslateAllKeys;
const
  UnShift = '`1234567890-=q[]\a;''z,./';
  Shift   = '~!@#$%^&*()_+Q{}|A:"Z<>?';
var
  i: integer;
begin

  KeyInput.Press('1');
  KeyInput.Press(VK_LCL_MINUS);

  for i:=1 to Length(UnShift) do              //string starts at 1
    KeyInput.Press(VkKeyScanA(UnShift[i]));   //1-`1234567890-=q[]\a;'z,./ SUCCESS!

  KeyInput.Press(VK_RETURN);

  KeyInput.Press('2');
  KeyInput.Press(VK_LCL_MINUS);

  for i:=1 to Length(Shift) do begin
    KeyInput.Apply([ssShift]);
    KeyInput.Press(VkKeyScanA(Shift[i]));      //2-~!@#$%^&*()_+Q{}|A:"Z<>? SUCCESS!
    KeyInput.UnApply([ssShift]);
  end;

end;
//Byte unsigned 8 bits $00-$ff,  Shortint signed 8 bits $00-$7f,
procedure _SendKey(const Key: Byte; const Delay: Integer);
begin
  KeyInput.Press(Key);
  Sleep(Delay);
end;
procedure _SendStr(const StringValue: String; const Delay: Integer);
var
  j: Integer;
  Key: Char;
begin
  for j:=1 to Length(StringValue) do begin
    Key:=StringValue[j];
    if Key<'a' then KeyInput.Apply([ssShift]);
    KeyInput.Press(VkKeyScanA(Key));
    if Key<'a' then KeyInput.UnApply([ssShift]);
  end;
  Sleep(Delay);  //no delay on StringValue on purpose
end;
procedure NewSend(const VK1: Byte; const VK2: Byte; const VK3: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);
var
  i: Integer;
  Key: Char;
begin
  for i:=1 to Count do begin
    if VK1<>0 then          _SendKey(VK1,Delay);
    if VK2<>0 then          _SendKey(VK2,Delay);
    if VK3<>0 then          _SendKey(VK3,Delay);
    if StringValue<>'' then _SendStr(StringValue, Delay);
    if VK4<>0 then          _SendKey(VK4,Delay);
  end;
end;

procedure NewSend(const VK1: Byte; const VK2: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);
begin
  NewSend(VK1,VK2,0,StringValue,VK4,Count,Delay);
end;

procedure NewSend(const VK1: Byte;
  const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);
begin
  NewSend(VK1,0,0,StringValue,VK4,Count,Delay);

end;

procedure NewSend(const StringValue: String; const VK4: Byte=0;
  const Count: Integer=1; const Delay: Integer=0);
begin
  NewSend(0,0,0,StringValue,VK4,Count,Delay);
end;
{
procedure NewSend(const StringValue: String;
  Count: Integer=1; Delay: Integer=0);
begin
  NewSend(0,0,0,StringValue,0,Count,Delay);
}
end;

end.

