{
lazarus\components\mouseandkeyinput =KeyInputIntf.pas = KeyInput.Press
lazarus\lcl\lcltype.pas = VK key codes

add to  Send:
  Send(Key, RepeatN, Delay);
  Send(Shift, Key, RepeatN, Delay);

  Send(String, RepeatN, Delay);
  Send(Shift, String, RepeatN, Delay); //??

lcltype.pas
  VK_SHIFT=16     ssShift
  VK_CONTROL=17   ssCtrl
  VK_MENU=18      ssAlt
  VK_ALT=18       define in this unit

defines.inc
  MOD_ALT = 1;      //VK_MENU=18 ssAlt
  MOD_CONTROL = 2;  //VK_CONTROL=17 ssCtrl
  MOD_SHIFT = 4;    //VK_SHIFT=16 ssShift
  MOD_WIN = 8;      //don't test, use VK_LWIN instead
}
unit winunithid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, LCLType, MouseAndKeyInput,
  Windows,
  Dialogs; //debug with ShowMessage
type
  TOrdArray=array of byte;
const
  VK_ALT=VK_MENU;
var
  FKeyDelay: integer;

//procedure TestKeyInput;
//procedure TestKeyInputString;

procedure TestNewSend(const Keys: Array of Variant);
procedure TestNewSend(StringValue: string);
procedure TestNewSend(Key: Byte);

  FUNCTION TranslateKey(Key: Char): SHORT;
  FUNCTION TESTHID(Key: Byte): SHORT;

procedure SetKeyDelay(Delay: integer=0);
procedure Send(Key: word; RepeatCount: integer=1; Delay: integer=0);
procedure Send(Shift: Byte; Key: Byte; RepeatCount: integer=1; Delay: integer=0);
procedure Send(Shift: Byte; Key: Char; RepeatCount: integer=1; Delay: integer=0);
procedure Send(StringValue: string; RepeatCount: integer=1; Delay: integer=0);

procedure MouseClick(Button: TMouseButton=mbLeft; Shift: TShiftState=[];
  ScreenX: integer=0; ScreenY: Integer=0);

{ winunithid_tests.inc }

//procedure CloseWindow;


implementation

//{$I winunithid_tests.inc}

{procedure CloseWindow;
begin
  TestCloseWindow;
end;
}

{ fascinating!  VK_A='a'=$41, but Ord('a')=VK_NUMPAD1=$61 }
{ 0110 0001
  0100 0001
}

procedure TestKeyInputString;
var
  i: integer;
  Keys: String;
begin
    Keys:='1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'; //$30-$39+$41-$5A
  //output'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'; //$30-$39+$41-$5A

  //Keys:='1234567890abcdefghijklmnopqrstuvwxyz'; //VK keys not mapped to ASCII
  //output 1234567890123456789*+-./

  //Keys:=' `-=[]\;'',./~!@#$%^&*()_+{}|:"<>?abcABC'; //VK keys not mapped to ASCII
  //ouput 'bc'
  KeyInput.Press(Keys); //keyinputintf.pas
end;

procedure TestNewSend(const Keys: Array of Variant);
var
  index: Integer;
  Key: Char;
begin
  ////////////wip
  for index:=Low(Keys) to High(Keys) do begin
    Key:=Keys[index];
    if  ((Key>='a' {$61}) and (Key<='z' {$7A})) then begin
          TestNewSend(TranslateKey(Key));
    end else
    KeyInput.Press(Keys[1]);
  end;
end;
procedure TestNewSend(StringValue: string);
var
  index: Integer;
  Key: Char;
begin
  for index:=1 to Length(StringValue) do begin
    Key:=StringValue[index];
    if Ord(Key)<$61 then KeyInput.Apply([ssShift]);
    KeyInput.Press(TranslateKey(Key));
    if Ord(Key)<$61 then KeyInput.UnApply([ssShift]);
  end;
end;
procedure TestNewSend(Key: Byte);
begin
  KeyInput.Press(Key);
end;

FUNCTION TranslateKey(Key: Char): SHORT;
BEGIN
  Result:=VkKeyScanA(Key);
end;
FUNCTION TESTHID(Key: Byte): SHORT;
BEGIN
  KeyInput.Press(Key);
  KeyInput.Apply([ssShift]);
  KeyInput.Press(Key);
  KeyInput.UnApply([ssShift]);
end;
procedure MouseClick(Button: TMouseButton=mbLeft; Shift: TShiftState=[];
  ScreenX: integer=0; ScreenY: Integer=0);
begin
  MouseInput.Click(Button, Shift, ScreenX, ScreenY);
end;
procedure SetKeyDelay(Delay: integer=0);
begin
  FKeyDelay:=Delay;
end;
//TODO: allow for multiple VK_CONTROL+VK_MENU?
procedure Send(Shift: Byte; Key: Byte; RepeatCount: integer=1; Delay: integer=0);
begin
  case Shift of
    VK_SHIFT    : KeyInput.Apply([ssShift]);
    VK_CONTROL  : KeyInput.Apply([ssCtrl]);
    VK_ALT      : KeyInput.Apply([ssAlt]);  //VK_MENU
  end;
  //Sleep(500);
  Send(Key, RepeatCount, Delay);
  case Shift of
    VK_SHIFT    : KeyInput.UnApply([ssShift]);
    VK_CONTROL  : KeyInput.UnApply([ssCtrl]);
    VK_ALT      : KeyInput.UnApply([ssAlt]);
  end;
end;
procedure Send(Shift: Byte; Key: Char; RepeatCount: integer=1; Delay: integer=0);
begin
  Send(Shift, Ord(Key), RepeatCount, Delay);
end;
procedure Send(Key: word; RepeatCount: integer=1; Delay: integer=0);
var i: integer;
begin
  for i:=1 to RepeatCount do begin
    KeyInput.Press(Key);
    if (Delay=0) and (FKeyDelay>0) then
      Sleep(FKeyDelay)
    else
      Sleep(Delay);
  end;
end;
procedure Send(StringValue: string; RepeatCount: integer=1; Delay: integer=0);
var
  count,index: integer;
  Key: Byte;

  procedure _SendKey(Key: Byte);
  begin
    Send(Key, RepeatCount, Delay);
  end;

  procedure _ShiftKey(Key: Byte);
  begin
    Send(VK_SHIFT, Key, RepeatCount, Delay);
  end;

  procedure _ShiftKey(Key: Char);
  begin
    Send(VK_SHIFT, Ord(Key), RepeatCount, Delay);
  end;

begin
  //StringValue:=UpperCase(StringValue);
  for count:=1 to RepeatCount do begin
    index:=1;
    while (index <= Length(StringValue)) do begin
      Key:=Ord(StringValue[index]);

      ///ShowMessage('Key='+Key.ToString);
      ///ShowMessage('Key='+Ord('0').ToString);

      Case Key of                           //LCLType
        Ord(' ') : _SendKey(VK_SPACE);      //BA ';:'
        Ord('`') : _SendKey(VK_OEM_3);      //C0 '`~'
        Ord('-') : _SendKey(VK_OEM_MINUS);  //BD '-_'
        Ord('=') : _SendKey(VK_LCL_EQUAL);  //   '=+'
        Ord('[') : _SendKey(VK_OEM_4);      //DB '[{'
        Ord(']') : _SendKey(VK_OEM_6);      //DD ']}'
        Ord('\') : _SendKey(VK_OEM_5);      //DC '\|' 92
        Ord(';') : _SendKey(VK_OEM_1);      //BA ';:'
        Ord(''''): _SendKey(VK_OEM_7);      //DE 'single-quote/double-quote'
        Ord(',') : _SendKey(VK_OEM_COMMA);  //BC ','
        Ord('.') : _SendKey(VK_OEM_PERIOD); //BE '.'
        Ord('/') : _SendKey(VK_OEM_2);      //BF '/?'
        Ord('~') : _ShiftKey(VK_OEM_3);
        Ord('!') : _ShiftKey('1');
        Ord('@') : _ShiftKey('2');
        Ord('#') : _ShiftKey('3');
        Ord('$') : _ShiftKey('4');
        Ord('%') : _ShiftKey('5');
        Ord('^') : _ShiftKey('6');
        Ord('&') : _ShiftKey('7');
        Ord('*') : _ShiftKey('8');
        Ord('(') : _ShiftKey('9');
        Ord(')') : _ShiftKey('0');
        Ord('_') : _ShiftKey(VK_OEM_MINUS);
        Ord('+') : _ShiftKey(VK_OEM_PLUS);
        Ord('{') : _ShiftKey(VK_OEM_4);
        Ord('}') : _ShiftKey(VK_OEM_6);
        Ord('|') : _ShiftKey(VK_OEM_5);
        Ord(':') : _ShiftKey(VK_OEM_1);
        Ord('"') : _ShiftKey(VK_OEM_7);
        Ord('<') : _ShiftKey(VK_OEM_COMMA);
        Ord('>') : _ShiftKey(VK_OEM_PERIOD);
        Ord('?') : _ShiftKey(VK_OEM_2);
        //Ord('A') : _ShiftKey('a');
      else
        KeyInput.Press(Key);
      end;

      Inc(index);

      if (Delay=0) and (FKeyDelay>0) then
        Sleep(FKeyDelay)
      else
        Sleep(Delay);
    end;
  end;
end;

end.
