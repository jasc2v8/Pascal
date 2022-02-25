unit winhid;

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

procedure SetKeyDelay(Delay: integer=0);
procedure Send(Key: word; RepeatCount: integer=1; Delay: integer=0);
procedure Send(Shift: Byte; Key: Byte; RepeatCount: integer=1; Delay: integer=0);
procedure Send(Shift: Byte; Key: Char; RepeatCount: integer=1; Delay: integer=0);
procedure Send(StringValue: string; RepeatCount: integer=1; Delay: integer=0);

implementation

procedure SetKeyDelay(Delay: integer);
begin
  FKeyDelay:=Delay;
end;
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
  StringValue:=UpperCase(StringValue);
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

