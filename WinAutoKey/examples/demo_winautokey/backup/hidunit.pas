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
unit hidunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, MouseAndKeyInput,
  Dialogs; //debug with ShowMessage
type
  TOrdArray=array of byte;
const
  VK_ALT=VK_MENU;
var
  FKeyDelay: integer;

function KeyState: SHORT;
procedure SetKeyDelay(Delay: integer=0);
procedure Send(Key: word; RepeatNumber: integer=1; Delay: integer=0);
procedure Send(StringValue: string; RepeatNumber: integer=1; Delay: integer=0);
procedure Send(Shift: word; Key: word; RepeatNumber: integer=1; Delay: integer=0);

implementation



//K:= LCLIntf.GetAsyncKeyState(VK_ESCAPE);
//Memo1.Append('K=' + K.ToString);

procedure SetKeyDelay(Delay: integer=0);
begin
  FKeyDelay:=Delay;
end;
procedure Send(Key: word; RepeatNumber: integer=1; Delay: integer=0);
var i: integer;
begin
  for i:=1 to RepeatNumber do begin
    KeyInput.Press(Key);
    if (Delay=0) and (FKeyDelay>0) then
      Sleep(FKeyDelay)
    else
      Sleep(Delay);
  end;
end;
{ only the most common unshifted keys are supported for now}
{ one shift key defined: Shift-';'=':' for the colon in http://www.domain.com }
{ add more shift keys if needed }
procedure Send(StringValue: string; RepeatNumber: integer=1; Delay: integer=0);
var
  count,index: integer;
  Key: Byte;
begin
  StringValue:=UpperCase(StringValue);
  for count:=1 to RepeatNumber do begin
    index:=1;
    while (index <= Length(StringValue)) do begin
      Key:=Ord(StringValue[index]);
      if (Key>=Ord('0')) and (Key<=Ord('9')) and
         (Key>=Ord('A')) and (Key<=Ord('Z'))then
         //no need to convert
         KeyInput.Press(Key)
      else begin
        Case Key of
          Ord(';') : Key:=VK_OEM_1;      //BA ';:'
          Ord(':') : Key:=$E9;           //E9-F5 OEM specific
          Ord('+') : Key:=VK_OEM_PLUS;   //BB '+'
          Ord(',') : Key:=VK_OEM_COMMA;  //BC ','
          Ord('-') : Key:=VK_OEM_MINUS;  //BD '-'
          Ord('.') : Key:=VK_OEM_PERIOD; //BE '.'
          Ord('/') : Key:=VK_OEM_2;      //BF '/?'
          Ord('`') : Key:=VK_OEM_3;      //C0 '`~'
          Ord('[') : Key:=VK_OEM_4;      //DB '[{'
          Ord('\') : Key:=VK_OEM_5;      //DC '\|' 92
          Ord(']') : Key:=VK_OEM_6;      //DD ']}'
         Ord('''') : Key:=VK_OEM_7;      //DE 'single-quote/double-quote'
        end;
        Case Key of
          $E9 : Send(VK_SHIFT,VK_OEM_1,1,0);
        else
          KeyInput.Press(Key);
        end;
      end;

      Inc(index);

      if (Delay=0) and (FKeyDelay>0) then
        Sleep(FKeyDelay)
      else
        Sleep(Delay);
    end;
  end;
end;
//TODO: can this be called with VK_ALT or must it be VK_MENU?
//TODO: allow for multiple VK_CONTROL+VK_MENU
procedure Send(Shift: word; Key: word; RepeatNumber: integer=1; Delay: integer=0);
begin
  case Shift of
    VK_SHIFT    : KeyInput.Apply([ssShift]);
    VK_CONTROL  : KeyInput.Apply([ssCtrl]);
    //VK_MENU     : KeyInput.Apply([ssAlt]);
    VK_ALT      : KeyInput.Apply([ssAlt]);
  end;
  Send(Key, RepeatNumber, Delay);
  case Shift of
    VK_SHIFT    : KeyInput.UnApply([ssShift]);
    VK_CONTROL  : KeyInput.UnApply([ssCtrl]);
    //VK_MENU     : KeyInput.UnApply([ssAlt]);
    VK_ALT      : KeyInput.UnApply([ssAlt]);
  end;
end;

end.
