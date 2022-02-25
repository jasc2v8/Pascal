//todo:

//change mouse from _SendKeyApply to _SendKeyDown???  [ssShift} to VK_SHIFT
//IsWindowHung?  SendTimeout?

{ Windows Auto Key

0.116 Add VK and math functions from LCLType, now WAK can be standalone in Uses - yes!
0.115 Change WinWait functions from i<(Timeout*4) to i<=(Timeout*4)
0.114 Change ControlClick add Button
0.113 Add MouseGetPos
0.112 Add JwaWinType, remove Windows
0.111 Fix WinActive, SetForegroundWindow if not hiding or minimizing window
0.110 Fix WinActivate, move isIconic to end, add SetForegroundWindow
0.109 Fix WinActivate, if already active then exit
0.108 Fix WinActivate, restore before attach thread
0.107 Fix MsgBox, add Result
0.106 Change WinActivate to restore window if iconic (minimized)
0.105 Add MsgBox
0.104 Fix hWinCallBack so MatchText works properly
0.103 Fixed ControlFocus
0.102 Fixed WinActivate
0.101 Change WinSleep default=WAK.WinDelay
0.100 Reset WAK delay defaults
0.99 Changed Delay to MilliSeconds
0.98 Removed DelayOverride in WinSleep(MilliSeconds)
0.97 Changed Settings to WAK
0.96 Removed DelayOverride for keyboard and mouse, kept in WinSleep, increased defaults
0.95 is WinSleep DelayOverride=0 working?
0.94 Change WinSleep DelayOverride: integer=-1
0.93 Change WinWait back to seconds
0.92 Add ControlClick
0.91 Add ControlGetPos
0.90 Cleanup some compiler errors by initialzing variables and using {H-}
0.89 Change WinWait* to delay first, then loop
0.88 Change WinGetText to EnumWindows, hWin works well
0.87 Testing hWin
0.86 Begin change hWin to EnumWindows - needs testing
0.85 Fixed hCtl - works well now
0.84 Change WinGetTextENUM to WinGetText, greatly simplified using gTextBuf
0.83 Fixed WinGetTextENUM using Windows sd call - ouch!
0.82 add WinGetTextENUM
0.81 Before fixing WinGetText to enumchildwindows
0.80 Finish hWin, hCtl.  Fixed WinSetState
0.79 Decided to go with WinFunction(h) and hWnd(), added ControlGetHandle and GetText
0.78 Begin to consider FindTitle: Variant, and ControlGetHandle
0.77 Change .LastFound to .LastUsed and update many functions
0.76 Change to winautokey_title_class_text, fix WinExist to WinExists
0.75 Archive as winautokey_title_text, change to (Title, Class, Text)
0.74 Add WinGetHandle - yeah!
0.73 Add WinGetText
0.72 Add _GetTag
0.71 Change WinGetHandleNEW to WinGetHandle, added Buttons
0.71 Change WinGetHandleNEW, reduce matches
0.70 Change WinGetHandleNEW so it returns child handle
0.69 WinGetHandleNEW tests OK
0.68 Change to [PARAMS]
0.67 Begin to add _ReadParams
0.66 Document specs for Params Array of String [1..8]
0.65 Change WinWait to use WinGetHandle
0.64 Change WinWaitActive to use WinGetHandle
0.63 Change WinWaitClose to use WinGetHandle
0.62 Change WinWait to use WinGetHandle
0.61 Change WinExist to use WinGetHandle
0.60 Begin to add Settings.LastUsed, needs work
0.59 Add 'ACTIVE' and 'LAST' to WinGetHandle
0.58 Change WinExistNEW to WinGetHandle
0.57 debug WinExistNEW
0.56 Fixed WinClose
0.55 Update Unit1
0.54 Add Settings
0.53 Verified to use Sleep() with Application.ProcessMessages
0.52 Add Mouse functions and eliminate MouseAndKeyInput
0.51 Changed GetKeyState, Fixed Send, add FWinDelay to Win functions,
  fixed WinWait functions, changed Send(String) to add key delay, put delay back in Send

}

{ Design concepts
  -Use function names from AutoIT and/or AutoHotKey
  -Not a full implementation, for learning purposes and basic usage
  -Use jwawinuser
  -mouseandkeyinput not used, but could be added if needed
  -UTF8 support

  Not Supported, and not Planned to Support:
  - Title: REGEXPTITLE, REGEXPCLASS, X \ Y \ W \ H, INSTANCE
  - Control: ClassNN
  - TextMatchMode: Fast (only match certain controls, exclude edit controls)

}

unit winautokey;

{$mode objfpc}{$H+}

interface

{Ctrl-Shift-C to add interface template to implementation}

uses
  Classes, SysUtils, Forms,
  {Windows,}  //not used, use Jwa units
  JwaWinType, JwaWinUser, //SendInput
  {MouseAndKeyInput,} //not used but can be optionally added
  LCLType,  //VK keys
  Variants,
  Controls, //TMouseButton = (mbLeft, mbRight, mbMiddle, mbExtra1, mbExtra2)
  DebugUnit;
const

  { VK constants from LCLtype }

  //------------
  // KeyFlags (High word part !!!)
  //------------
    KF_EXTENDED = $100;
    KF_DLGMODE = $800;
    KF_MENUMODE = $1000;
    KF_ALTDOWN = $2000;
    KF_REPEAT = $4000;
    KF_UP = $8000;

  // TShortCut additions:
    scMeta = $1000;

  //-------------
  // Virtual keys
  //-------------
  //
  // Basic keys up to $FF have values and meaning compatible with the Windows API as described here:
  // http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/WinUI/WindowsUserInterface/UserInput/VirtualKeyCodes.asp
  //
  // Starting with $100 and upwards the key constants are LCL additions
  //
    VK_UNKNOWN    = 0; // defined by LCL
    VK_LBUTTON    = 1;
    VK_RBUTTON    = 2;
    VK_CANCEL     = 3;
    VK_MBUTTON    = 4;
    VK_XBUTTON1   = 5;
    VK_XBUTTON2   = 6;
    VK_BACK       = 8;  // The "Backspace" key, dont confuse with the
                        // Android BACK key which is mapped to VK_ESCAPE
    VK_TAB        = 9;
    VK_CLEAR      = 12;
    VK_RETURN     = 13; // The "Enter" key, also used for a keypad center press
    VK_SHIFT      = 16; // See also VK_LSHIFT, VK_RSHIFT
    VK_CONTROL    = 17; // See also VK_LCONTROL, VK_RCONTROL
    VK_MENU       = 18; // The ALT key. Also called "Option" in Mac OS X. See also VK_LMENU, VK_RMENU
    VK_PAUSE      = 19; // Pause/Break key
    VK_CAPITAL    = 20; // CapsLock key
    VK_KANA       = 21;
    VK_HANGUL     = 21;
    VK_JUNJA      = 23;
    VK_FINAL      = 24;
    VK_HANJA      = 25;
    VK_KANJI      = 25;
    VK_ESCAPE     = 27; // Also used for the hardware Back key in Android
    VK_CONVERT    = 28;
    VK_NONCONVERT = 29;
    VK_ACCEPT     = 30;
    VK_MODECHANGE = 31;
    VK_SPACE      = 32;
    VK_PRIOR      = 33; // Page Up
    VK_NEXT       = 34; // Page Down
    VK_END        = 35;
    VK_HOME       = 36;
    VK_LEFT       = 37;
    VK_UP         = 38;
    VK_RIGHT      = 39;
    VK_DOWN       = 40;
    VK_SELECT     = 41;
    VK_PRINT      = 42; // PrintScreen key
    VK_EXECUTE    = 43;
    VK_SNAPSHOT   = 44;
    VK_INSERT     = 45;
    VK_DELETE     = 46;
    VK_HELP       = 47;
    VK_0          = $30;
    VK_1          = $31;
    VK_2          = $32;
    VK_3          = $33;
    VK_4          = $34;
    VK_5          = $35;
    VK_6          = $36;
    VK_7          = $37;
    VK_8          = $38;
    VK_9          = $39;
    //3A-40 Undefined
    VK_A          = $41;
    VK_B          = $42;
    VK_C          = $43;
    VK_D          = $44;
    VK_E          = $45;
    VK_F          = $46;
    VK_G          = $47;
    VK_H          = $48;
    VK_I          = $49;
    VK_J          = $4A;
    VK_K          = $4B;
    VK_L          = $4C;
    VK_M          = $4D;
    VK_N          = $4E;
    VK_O          = $4F;
    VK_P          = $50;
    VK_Q          = $51;
    VK_R          = $52;
    VK_S          = $53;
    VK_T          = $54;
    VK_U          = $55;
    VK_V          = $56;
    VK_W          = $57;
    VK_X          = $58;
    VK_Y          = $59;
    VK_Z          = $5A;

    VK_LWIN       = $5B; // In Mac OS X this is the Apple, or Command key. Windows Key in PC keyboards
    VK_RWIN       = $5C; // In Mac OS X this is the Apple, or Command key. Windows Key in PC keyboards
    VK_APPS       = $5D; // The PopUp key in PC keyboards
    // $5E reserved
    VK_SLEEP      = $5F;

    VK_NUMPAD0    = 96; // $60
    VK_NUMPAD1    = 97;
    VK_NUMPAD2    = 98;
    VK_NUMPAD3    = 99;
    VK_NUMPAD4    = 100;
    VK_NUMPAD5    = 101;
    VK_NUMPAD6    = 102;
    VK_NUMPAD7    = 103;
    VK_NUMPAD8    = 104;
    VK_NUMPAD9    = 105;
    VK_MULTIPLY   = 106; // VK_MULTIPLY up to VK_DIVIDE are usually in the numeric keypad in PC keyboards
    VK_ADD        = 107;
    VK_SEPARATOR  = 108;
    VK_SUBTRACT   = 109;
    VK_DECIMAL    = 110;
    VK_DIVIDE     = 111;
    VK_F1         = 112;
    VK_F2         = 113;
    VK_F3         = 114;
    VK_F4         = 115;
    VK_F5         = 116;
    VK_F6         = 117;
    VK_F7         = 118;
    VK_F8         = 119;
    VK_F9         = 120;
    VK_F10        = 121;
    VK_F11        = 122;
    VK_F12        = 123;
    VK_F13        = 124;
    VK_F14        = 125;
    VK_F15        = 126;
    VK_F16        = 127;
    VK_F17        = 128;
    VK_F18        = 129;
    VK_F19        = 130;
    VK_F20        = 131;
    VK_F21        = 132;
    VK_F22        = 133;
    VK_F23        = 134;
    VK_F24        = 135; // $87

    // $88-$8F unassigned

    VK_NUMLOCK    = $90;
    VK_SCROLL     = $91;

    // $92-$96  OEM specific
    // $97-$9F  Unassigned

    // not in VCL defined:
    //MWE: And should not be used.
    //     The keys they are on map to another VK

  //  VK_SEMICOLON  = 186;
  //  VK_EQUAL      = 187; // $BB
  //  VK_COMMA      = 188;
  //  VK_POINT      = 190;
  //  VK_SLASH      = 191;
  //  VK_AT         = 192;

    // VK_L & VK_R - left and right Alt, Ctrl and Shift virtual keys.
    // When Application.ExtendedKeysSupport is false, these keys are
    // used only as parameters to GetAsyncKeyState() and GetKeyState().
    // No other API or message will distinguish left and right keys in this way
    //
    // When Application.ExtendedKeysSupport is true, these keys will be sent
    // on KeyDown / KeyUp instead of the generic VK_SHIFT, VK_CONTROL, etc.
    VK_LSHIFT     = $A0;
    VK_RSHIFT     = $A1;
    VK_LCONTROL   = $A2;
    VK_RCONTROL   = $A3;
    VK_LMENU      = $A4; // Left ALT key (also named Option in Mac OS X)
    VK_RMENU      = $A5; // Right ALT key (also named Option in Mac OS X)

    VK_BROWSER_BACK        = $A6;
    VK_BROWSER_FORWARD     = $A7;
    VK_BROWSER_REFRESH     = $A8;
    VK_BROWSER_STOP        = $A9;
    VK_BROWSER_SEARCH      = $AA;
    VK_BROWSER_FAVORITES   = $AB;
    VK_BROWSER_HOME        = $AC;
    VK_VOLUME_MUTE         = $AD;
    VK_VOLUME_DOWN         = $AE;
    VK_VOLUME_UP           = $AF;
    VK_MEDIA_NEXT_TRACK    = $B0;
    VK_MEDIA_PREV_TRACK    = $B1;
    VK_MEDIA_STOP          = $B2;
    VK_MEDIA_PLAY_PAUSE    = $B3;
    VK_LAUNCH_MAIL         = $B4;
    VK_LAUNCH_MEDIA_SELECT = $B5;
    VK_LAUNCH_APP1         = $B6;
    VK_LAUNCH_APP2         = $B7;

    // VK_OEM keys are utilized only when Application.ExtendedKeysSupport is false

    // $B8-$B9 Reserved
    VK_OEM_1               = $BA; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the ';:' key
    VK_OEM_PLUS            = $BB; // For any country/region, the '+' key
    VK_OEM_COMMA           = $BC; // For any country/region, the ',' key
    VK_OEM_MINUS           = $BD; // For any country/region, the '-' key
    VK_OEM_PERIOD          = $BE; // For any country/region, the '.' key
    VK_OEM_2               = $BF; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the '/?' key
    VK_OEM_3               = $C0; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the '`~' key
    // $C1-$D7 Reserved
    // $D8-$DA Unassigned
    VK_OEM_4               = $DB; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the '[{' key
    VK_OEM_5               = $DC; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the '\|' key
    VK_OEM_6               = $DD; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the ']}' key
    VK_OEM_7               = $DE; // Used for miscellaneous characters; it can vary by keyboard.
                                  // For the US standard keyboard, the 'single-quote/double-quote' key
    VK_OEM_8               = $DF; // Used for miscellaneous characters; it can vary by keyboard.

    // $E0 Reserved
    // $E1 OEM specific
    VK_OEM_102             = $E2; // Either the angle bracket key or the backslash key on the RT 102-key keyboard

    // $E3-$E4 OEM specific

    VK_PROCESSKEY          = $E7; // IME Process key

    // $E8 Unassigned
    // $E9-$F5 OEM specific

    VK_ATTN       = $F6;
    VK_CRSEL      = $F7;
    VK_EXSEL      = $F8;
    VK_EREOF      = $F9;
    VK_PLAY       = $FA;
    VK_ZOOM       = $FB;
    VK_NONAME     = $FC;
    VK_PA1        = $FD;
    VK_OEM_CLEAR  = $FE;

    VK_HIGHESTVALUE = $FFFF;
    VK_UNDEFINED  = $FF; // defined by LCL

  //==============================================
  // LCL aliases for more clear naming of keys
  //==============================================

    VK_LCL_EQUAL       = VK_OEM_PLUS;  // The "=+" Key
    VK_LCL_COMMA       = VK_OEM_COMMA; // The ",<" Key
    VK_LCL_POINT       = VK_OEM_PERIOD;// The ".>" Key
    VK_LCL_SLASH       = VK_OEM_2;     // The "/?" Key
    VK_LCL_SEMI_COMMA  = VK_OEM_1;     // The ";:" Key
    VK_LCL_MINUS       = VK_OEM_MINUS; // The "-_" Key
    VK_LCL_OPEN_BRAKET = VK_OEM_4;     // The "[{" Key
    VK_LCL_CLOSE_BRAKET= VK_OEM_6;     // The "]}" Key
    VK_LCL_BACKSLASH   = VK_OEM_5;     // The "\|" Key
    VK_LCL_TILDE       = VK_OEM_3;     // The "`~" Key
    VK_LCL_QUOTE       = VK_OEM_7;     // The "'"" Key

    VK_LCL_ALT        = VK_MENU;
    VK_LCL_LALT       = VK_LMENU;
    VK_LCL_RALT       = VK_RMENU;

    VK_LCL_CAPSLOCK   = VK_CAPITAL;

  //==============================================
  // New LCL defined keys
  //==============================================

    VK_LCL_POWER      = $100;
    VK_LCL_CALL       = $101;
    VK_LCL_ENDCALL    = $102;
    VK_LCL_AT     = $103; // Not equivalent to anything < $FF, will only be sent by a primary "@" key
                          // but not for a @ key as secondary action of a "2" key for example

const

  { const common }

  DS=DirectorySeparator;
  LE=LineEnding;

  { const keyboard }

  CR              = VK_RETURN; //same as ASCII 13 = $0D, should be OK for general use
  VK_CR           = VK_RETURN;

  { const keyboard - modified VK keys from LCLType }

  VK_SHIFT_DOWN   = VK_SHIFT;  //Use either VK_SHIFT or VK_SHIFT_DOWN
  VK_SHIFT_DN     = VK_SHIFT;
  VK_SHIFT_UP     = VK_SHIFT or KF_UP;

  VK_CONTROL_DOWN = VK_CONTROL;
  VK_CONTROL_DN   = VK_CONTROL;
  VK_CONTROL_UP   = VK_CONTROL or KF_UP;

  VK_CTRL_DOWN    = VK_CONTROL;
  VK_CTRL_DN      = VK_CONTROL;
  VK_CTRL_UP      = VK_CONTROL or KF_UP;

  VK_MENU_DOWN    = VK_MENU;
  VK_MENU_DN      = VK_MENU;
  VK_MENU_UP      = VK_MENU or KF_UP;

  VK_ALT          = VK_MENU;
  VK_ALT_DOWN     = VK_MENU;
  VK_ALT_DN       = VK_MENU;
  VK_ALT_UP       = VK_MENU or KF_UP;

  { const windows }

  mtStartsWith=1;
  mtSubstring=2;
  mtExact=3;
  QUARTER_SECOND=250; //WinWait Timeout

type
  TSettings = record
    CaseSensitive: Boolean;
    KeyDelay: integer;
    LastUsed: integer;
    MouseDelay: integer;
    TitleMatchMode: integer;
    TextMatchMode: integer;
    WinDelay: integer;
  end;

  ThWin = record
    Handle: HWND;
    FindTitle: String;
    FindText: String;
    FindClass: String;
    FindID: integer;
    IsMatch: Boolean;
  end;
  PThWin = ^ThWin;

var
  WAK: TSettings;
  gCount: Integer=0;
  gTextBuf: String='';

{ inteface LCLType }
{ interface common }

procedure SetMatchCaseSensitive(const CaseSensitive: Boolean=False);
procedure SetTitleMatchMode(const MatchMode: integer);
procedure SetTextMatchMode(const MatchMode: integer);
procedure SetWinDelay(const MilliSeconds: Integer=100);

procedure WinSleep(MilliSeconds: Integer=-1);

function MsgBox(const Msg: String; const Caption: String; const Flags: LongInt): Integer;

{ interface keyboard }

function GetKeyState(const VK: Integer): Integer;

procedure SetKeyDelay(const MilliSeconds: integer=5);
procedure SetMouseDelay(const MilliSeconds: integer=10);

procedure Send(const Key: Word; const RepeatCount: integer=1);
procedure Send(const Text: string; const RepeatCount: integer=1);
Procedure Send(const Keys: Array of Variant; const RepeatCount: Integer=1);

{ interface mouse }

procedure MouseClick(const Button: TMouseButton=mbLeft; const Shift: TShiftState=[];
const ScreenX: integer=-1; const ScreenY: Integer=-1; const RepeatCount: integer=1);

procedure MouseDown(Button: TMouseButton; Shift: TShiftState);
procedure MouseGetPos(out ScreenX: Integer; out ScreenY: Integer);
procedure MouseMove(ScreenX, ScreenY: Integer);
procedure MouseUp(Button: TMouseButton; Shift: TShiftState);

{ interface controls }

//function hCtlCallBack(h: HWND; lp: LPARAM): LongBool; stdcall;

function hCtl(const h: HWND; const FindCtlText: string='';
  const FindCtlClass: string=''; const ID: integer=0): HWND;

procedure ControlClick(h: HWND; const Button: TMouseButton=mbLeft; const Shift: TShiftState=[];
  const ScreenX: integer=-1; const ScreenY: Integer=-1; const RepeatCount: integer=1);


function ControlFocus(const hControl: HWND): Boolean;

function ControlGetHandle(const h: HWND; const FindCtlText: string='';
  const FindCtlClass: string=''; const ID: integer=0): HWND;

function ControlGetPos(const h: HWND): RECT;

function ControlGetText(const h: HWND): String;

{ interface windows }

function hWin(const FindTitle: String=''; FindText: String='';
  FindClass: String=''): HWND;

function WinActivate(const h: HWND): Boolean;
function WinActive(const h: HWND): Boolean;
function WinClose(const h: HWND): Boolean;

function WinExists(const h: HWND): Boolean;

function WinGetClass(const h: HWND): String;

function WinGetHandle(const FindTitle: String=''; FindText: String='';
  FindClass: String=''): HWND;

function WinGetState(const h: HWND): UInt;
function WinSetState(const h: HWND; showCmd: integer): Boolean;

function WinGetText(const h: HWND): String;
function WinGetTitle(const h: HWND): String;

function WinShow(const h: HWND): Boolean;
function WinHide(const h: HWND): Boolean;
function WinMinimize(const h: HWND): Boolean;
function WinMaximize(const h: HWND): Boolean;
function WinNormal(const h: HWND): Boolean;
function WinRestore(const h: HWND): Boolean;

function WinWaitActive(const h: HWND; const Timeout: Integer=0): Boolean;

function WinWaitNotActive(const h: HWND; const Timeout: Integer=0): Boolean;

function WinWaitClose(const h: HWND; const Timeout: Integer=0): Boolean;

function WinWait(const FindTitle: String=''; const FindText: String='';
  const FindClass: String=''; const Timeout: Integer=0): HWND;

//wip

function WinList(const FindTitle: String): TStringList;

procedure WinListProc(AList: TStringList; const FindTitle: String);

implementation

{ implementation LCLType }

function MathRound(AValue: ValReal): Int64; inline;
begin
  if AValue >= 0 then
    Result := Trunc(AValue + 0.5)
  else
    Result := Trunc(AValue - 0.5);
end;

function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer;
begin
  if nDenominator = 0 then
    Result := -1
  else
  if nNumerator = nDenominator then
    Result := nNumber
  else
    Result := MathRound(int64(nNumber) * int64(nNumerator) / nDenominator);
end;

{ implementation common }

procedure SetKeyDelay(const MilliSeconds: Integer=5);
begin
  WAK.KeyDelay:=MilliSeconds;
end;

procedure SetMouseDelay(const MilliSeconds: Integer=10);
begin
  WAK.MouseDelay:=MilliSeconds;
end;

procedure SetMatchCaseSensitive(const CaseSensitive: Boolean=False);
begin
  WAK.CaseSensitive:=CaseSensitive;
end;

procedure SetTitleMatchMode(const MatchMode: integer);
begin
  WAK.TitleMatchMode:=MatchMode;
end;

procedure SetTextMatchMode(const MatchMode: integer);
begin
  WAK.TextMatchMode:=MatchMode;
end;

procedure SetWinDelay(const MilliSeconds: Integer=100);
begin
  if MilliSeconds<0 then
    WAK.WinDelay:=0
  else
    WAK.WinDelay:=MilliSeconds;
end;

//MilliSeconds=WAK.KeyDelay, WAK.WinDelay, WAK.MouseDelay, or Integer(ms)
procedure WinSleep(MilliSeconds: Integer=-1);
begin
  if MilliSeconds=-1 then MilliSeconds:=WAK.WinDelay;
  Application.ProcessMessages;
  Sleep(MilliSeconds)
end;

{ implementation keyboard }

procedure _SendKeyInput(Flag: DWORD; Key: Word);
var
  Input: TInput;
begin
  Input := Default(TInput);
  Input.type_ := INPUT_KEYBOARD;
  Input.ki.dwFlags := Flag;
  Input.ki.wVk := Key;
  SendInput(1, @Input, SizeOf(Input));
  WinSleep(WAK.KeyDelay);
end;

procedure _SendKeyDown(Key: Word);
begin
  _SendKeyInput(0, Key);
end;

procedure _SendKeyUp(Key: Word);
begin
  _SendKeyInput(KEYEVENTF_KEYUP, Key);
end;

procedure _SendKeyPress(Key: Word);
begin
  _SendKeyDown(Key);
  _SendKeyUp(Key);
end;

procedure _SendKeyApply(Shift: TShiftState);
begin
  if ssCtrl in Shift then _SendKeyDown(VK_CONTROL);
  if ssAlt in Shift then _SendKeyDown(VK_MENU);
  if ssShift in Shift then _SendKeyDown(VK_SHIFT);
end;

procedure _SendKeyUnapply(Shift: TShiftState);
begin
  if ssShift in Shift then _SendKeyUp(VK_SHIFT);
  if ssCtrl in Shift then _SendKeyUp(VK_CONTROL);
  if ssAlt in Shift then _SendKeyUp(VK_MENU);
end;

// TODO: WinAsyncKeyState(Key: integer): boolean  and $80?
//returns 1 if the key is down (or toggled on) or 0 if it is up (or toggled off).
function GetKeyState(const VK: Integer): Integer;
begin
  Result:=GetAsyncKeyState(VK);
end;

//Send Ctrl/Shift/Alt and VK Key
procedure Send(const Key: Word; const RepeatCount: Integer=1);
var
  i: Integer;
begin
  if (Key=VK_SHIFT) or (Key=VK_CONTROL) or (Key=VK_MENU) then begin
   _SendKeyDown(Key);
  end
  else if (Key=VK_SHIFT_UP) or (Key=VK_CONTROL_UP) or (Key=VK_MENU_UP) then begin
    _SendKeyUp(Key xor KF_UP);
  end
  else begin
    for i:=1 to RepeatCount do begin
      _SendKeyPress(Key);
    end;
  end;
end;

procedure Send(const Text: string; const RepeatCount: integer=1);
var
  i,j: Integer;
  Key: Word;
begin
  for i:=1 to RepeatCount do begin
    for j:=1 to Length(Text) do begin
      Key:=VkKeyScanExA(Text[j],0);
      if Key and KF_EXTENDED<>0 then _SendKeyDown(VK_SHIFT);
      _SendKeyPress(Key);
      if Key and KF_EXTENDED<>0 then _SendKeyUp(VK_SHIFT);
    end;
  end;
end;

Procedure Send(const Keys: Array of Variant; const RepeatCount: Integer=1);
var
  i,j: Integer;
begin
  for i:=1 to RepeatCount do begin
    for j:=Low(Keys) to High(Keys) do begin
      if varType(Keys[j])=varString then
        Send(VarToStr(Keys[j]))
      else
        Send(Word(Keys[j]));
    end;
  end;
end;

{ implementation mouse }

procedure _SendMouseInput(Flag: DWORD; MouseData: DWORD = 0);
var
  Input: TInput;
begin
  Input := Default(TInput);
  Input.mi.mouseData := MouseData;
  Input.type_ := INPUT_MOUSE;
  Input.mi.dwFlags := Flag;
  SendInput(1, @Input, SizeOf(Input));
  WinSleep(WAK.MouseDelay);
end;

procedure _SendMouseInput(Flag: DWORD; X, Y: Integer);
var
  Input: TInput;
begin
  Input := Default(TInput);
  Input.type_ := INPUT_MOUSE;
  Input.mi.dx := MulDiv(X, 65535, Screen.Width - 1);  //horizontal
  Input.mi.dy := MulDiv(Y, 65535, Screen.Height - 1); //vertical
  Input.mi.dwFlags := Flag or MOUSEEVENTF_ABSOLUTE;
  SendInput(1, @Input, SizeOf(Input));
  WinSleep(WAK.MouseDelay);
end;

procedure _SendMouseDown(Button: TMouseButton);
var
  Flag: DWORD;
begin
  case Button of
    mbRight: Flag := MOUSEEVENTF_RIGHTDOWN;
    mbMiddle: Flag := MOUSEEVENTF_MIDDLEDOWN;
  else
    Flag := MOUSEEVENTF_LEFTDOWN;
  end;
  _SendMouseInput(Flag);
end;

procedure _SendMouseUp(Button: TMouseButton);
var
  Flag: DWORD;
begin
  case Button of
    mbRight: Flag := MOUSEEVENTF_RIGHTUP;
    mbMiddle: Flag := MOUSEEVENTF_MIDDLEUP;
  else
    Flag := MOUSEEVENTF_LEFTUP;
  end;
  _SendMouseInput(Flag);
end;

procedure _SendMouseMove(ScreenX, ScreenY: Integer);
begin
  _SendMouseInput(MOUSEEVENTF_MOVE, ScreenX, ScreenY);
end;

//Controls: TMouseButton = (mbLeft, mbRight, mbMiddle, mbExtra1, mbExtra2);
//Classes: TShiftStateEnum = (ssShift, ssAlt, ssCtrl, etc...)
procedure MouseClick(const Button: TMouseButton; const Shift: TShiftState=[];
  const ScreenX: integer=-1; const ScreenY: Integer=-1;
  const RepeatCount: integer=1);
var
  i: Integer;
begin
  for i:=1 to RepeatCount do begin
    MouseMove(ScreenX, ScreenY);
    MouseDown(Button, Shift);
    MouseUp(Button, Shift);
    WinSleep(WAK.MouseDelay);
  end;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState);
begin
  _SendKeyApply(Shift);
  try
    _SendMouseDown(Button);
  finally
    _SendKeyUnApply(Shift);
  end;
  Application.ProcessMessages;
end;

procedure MouseGetPos(out ScreenX: Integer; out ScreenY: Integer);
var
  pt: Point;
begin
  GetCursorPos(pt);
  ScreenX:=pt.X;
  ScreenY:=pt.Y;
end;

procedure MouseUp(Button: TMouseButton; Shift: TShiftState);
begin
  _SendKeyApply(Shift);
  try
    _SendMouseUp(Button);
  finally
    _SendKeyUnApply(Shift);
  end;
  Application.ProcessMessages;
end;

procedure MouseMove(ScreenX, ScreenY: Integer);
begin
  SetCursorPos(ScreenX, ScreenY);
  Application.ProcessMessages;
end;

{ implementation windows }

//mtStartsWith=1; mtSubstring=2; mtExact=3;
function _DoMatch(MatchMode: Integer; S1: String; S2: String): Boolean;
begin

  Result:=False;

  if not WAK.CaseSensitive then begin
    S1:=AnsiUpperCase(S1);
    S2:=AnsiUpperCase(S2);
  end;

  //Debugln('S1=',S1);
  //Debugln('S2=',S2);

  if (MatchMode=mtStartsWith) and (Pos(S1, S2)=1) then
    Result:=True
  else if (MatchMode=mtSubstring) and (Pos(S1, S2)>0) then
    Result:=True
  else if (MatchMode=mtExact) and (S1=S2) then
    Result:=True;
end;

function hCtlCallBack(h: HWND; lp: LPARAM): LongBool; stdcall;
var
  WBuf: array[0..MAX_PATH] of WChar;
  CtlClassName, CtlText: String;
  MatchID, MatchClass, MatchText: Boolean;
  Ctl: PThWin;
  cid: integer;
begin

  Ctl:={%H-}PThWin(lp);

  Result:=True;
  MatchID:=False;
  MatchClass:=False;
  MatchText:=False;

  WBuf:=''; //just to avoid the warning 'does not seem to be initialized'

  if IsWindowVisible(h) then begin

    cid:=GetDlgCtrlID(h);
    if (cid<>0) and (cid=Ctl^.FindID) then MatchID:=True;

    {if MatchID then begin
      Debugln('cid=', cid);
      Debugln('ControlID=', Ctl^.FindControlID);
      Debugln('MatchID=', MatchID);
    end;}

    GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
    CtlClassName:=TrimRight(UnicodeString(WBuf));
    MatchClass:=_DoMatch(WAK.TitleMatchMode, Ctl^.FindClass, CtlClassName);

    //if CtlClassName<>'' then Debugln('CtlClassName=', CtlClassName);
    //if Ctl^.FindClassName<>'' then Debugln('Ctl^.FindClassName=', Ctl^.FindClassName);

    SendMessageW(h, WM_GETTEXT, MAX_PATH, {%H-}LPARAM(@WBuf));
    CtlText:=TrimRight(UnicodeString(WBuf));
    MatchText:=_DoMatch(WAK.TextMatchMode, Ctl^.FindText, CtlText);

    //if CtlText<>'' then Debugln('CtlText=', CtlText);
    //if Ctl^.FindText<>'' then Debugln('Ctl^.FindText=', Ctl^.FindText);

    if MatchID or
      (MatchClass and MatchText) or
      (MatchClass and (Ctl^.FindText='')) or
      (MatchText and (Ctl^.FindClass='')) then begin
        //Debugln('MatchID exit=', MatchID);
        Ctl^.Handle:=h;
        Ctl^.IsMatch:=True;
        Result:=False;
    end;

  end;

end;

//Finds the handle to a control on the parent window.  Returns the handle and Ctl.IsMatch;
function hCtl(const h: HWND; const FindCtlText: string='';
  const FindCtlClass: string=''; const ID: integer=0): HWND;
var
  //Ctl: ThCtl;
  Ctl: ThWin;
begin

  Result:=0;

  if h=0 then Exit;

  Ctl.Handle:=0;
  Ctl.FindID:=ID;
  Ctl.FindClass:=FindCtlClass;
  Ctl.FindText:=FindCtlText;

  if IsWindowVisible(h) then begin
    EnumChildWindows(h, @hCtlCallBack, {%H-}LPARAM(@Ctl));
  end;

  if  Ctl.IsMatch then begin
    //Debugln('Ctl.Handle=', IntToHex(Ctl.Handle,4));
    Result:=Ctl.Handle;
  end;

end;

procedure ControlClick(h: HWND; const Button: TMouseButton=mbLeft; const Shift: TShiftState=[];
  const ScreenX: integer=-1; const ScreenY: Integer=-1; const RepeatCount: integer=1);
var
  i: integer;
  r: TRECT;
  AxisX, AxisY: integer;
begin

  r:=ControlGetPos(h);

  if ScreenX=-1 then
    AxisX:=r.Centerpoint.X
  else
    AxisX:=ScreenX;

  if ScreenY=-1 then
    AxisY:=r.Centerpoint.Y
  else
    AxisY:=ScreenY;

  MouseClick(Button,[],AxisX, AxisY, RepeatCount);
end;

function ControlFocus(const hControl: HWND): Boolean;
var
  pt: Point;
  hOther: HWND;
  currentThreadId, otherThreadId: DWORD;
  ControlID: Integer;
  hActiveWindow: HWND;

begin
  Result:=False;
  try
    hOther:=GetForegroundWindow();

    if (hOther=0) then begin
      GetCursorPos(pt);
      hOther := WindowFromPoint(pt);
    end;

    otherThreadId:=GetWindowThreadProcessId(hOther, nil);
    currentThreadId:=GetCurrentThreadId();

    if(otherThreadId=0) then begin
      Exit;
    end;

    if(otherThreadId<>currentThreadId) then
      AttachThreadInput(otherThreadId, currentThreadId, True);

    if SetFocus(hControl)<>0 then begin
      hActiveWindow:=GetActiveWindow;
      ControlID:=GetDlgCtrlID(hControl);
      SendMessage(hActiveWindow, DM_SETDEFID, ControlID, 0);
      Result:=True;
      WinSleep(WAK.WinDelay);
    end;

  finally
    if(otherThreadId<>currentThreadId) then
      AttachThreadInput(otherThreadId, currentThreadId, False);
  end;

end;

function ControlGetHandle(const h: HWND; const FindCtlText: string='';
  const FindCtlClass: string=''; const ID: integer=0): HWND;
begin
  Result:=hCtl(h, FindCtlText, FindCtlClass, ID);
end;
function ControlGetPos(const h: HWND): TRect;
var
  r: TRect;
begin
  if GetWindowRect(h, r) then
    Result:=r
  else
    Result:=Default(TRect);
end;

function ControlGetText(const h: HWND): String;
var
  WBuf: array[0..MAX_PATH] of WChar;
begin
  Result:='';
  if h=0 then Exit;
  SendMessageW(h, WM_GETTEXT, MAX_PATH, {%H-}LPARAM(@WBuf));
  Result:=TrimRight(UnicodeString(WBuf));
end;

function hWinCallBack(h: HWND; lp: LPARAM): LongBool; stdcall;
var
  WBuf: array[0..MAX_PATH] of WChar;
  MatchTitle, MatchClass, MatchText: Boolean;
  WinTitle, WinClass, WinText: String;
  Win: PThWin;
begin

  Win:={%H-}PThWin(lp);

  Result:=True; //keep searching

  MatchTitle:=False;
  MatchClass:=False;
  MatchText:=False;
  Win^.IsMatch:=False;

  WBuf:=''; //avoid compiler warnings

  if IsWindowVisible(h) then begin

    if Win^.FindTitle<>'' then begin
      GetWindowTextW(h, LPWSTR(WBuf), MAX_PATH);
      WinTitle:=TrimRight(UnicodeString(WBuf));
      MatchTitle:=_DoMatch(WAK.TitleMatchMode, Win^.FindTitle, WinTitle);
    end;

    if Win^.FindClass<>'' then begin
      GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
      WinClass:=TrimRight(UnicodeString(WBuf));
      MatchClass:=_DoMatch(WAK.TitleMatchMode, Win^.FindClass, WinClass);
    end;

    if Win^.FindText<>'' then begin
      WinText:=WinGetText(h);
      WinText:=StringReplace(WinText, LineEnding, '',[rfReplaceAll]);
      MatchText:=_DoMatch(WAK.TextMatchMode, Win^.FindText, WinText);
    end;

    if MatchTitle and (Win^.FindClass='') and (Win^.FindText='') then
      Result:=False
    else if MatchClass and MatchTitle and (Win^.FindText='') then
      Result:=False
    else if MatchClass and (Win^.FindTitle='') and (Win^.FindText='') then
      Result:=False
    else if MatchText and MatchTitle and MatchClass then
      Result:=False
    else if MatchText and (Win^.FindTitle='') and MatchClass then
      Result:=False
    else if MatchText and MatchTitle and (Win^.FindClass='') then
      Result:=False;

    if not Result then begin
      Win^.IsMatch:=True;
      Win^.Handle:=h;
    end;

  end; //IsWindowVisible

end;

//Get handle of window with matching Title [and/or Class [or Text]]
function hWin(const FindTitle: String=''; FindText: String='';
  FindClass: String=''): HWND;
var
  Win: ThWin;
begin

  Result:=0;

  if (FindTitle='') and (FindClass='') and (FindText='') then begin
    Result:=WAK.LastUsed;
    Exit;
  end;

  if UpperCase(FindTitle)='ACTIVE' then begin
    Result:=GetForegroundWindow;
    Exit;
  end;

  if UpperCase(FindTitle)='LAST' then begin
    Result:=WAK.LastUsed;
    Exit;
  end;

  Win.Handle:=0;
  Win.FindTitle:=FindTitle;
  Win.FindText:=FindText;
  Win.FindClass:=FindClass;
  Win.IsMatch:=False;

 // Debugln('Findtitle='+Win.FindTitle);

  EnumWindows(@hWinCallBack, {%H-}LPARAM(@Win));

  if  Win.IsMatch then begin
    //Debugln('Ctl.Handle=', IntToHex(Ctl.Handle,4));
    WAK.LastUsed:=Win.Handle;
    Result:=Win.Handle;
  end;

end;

function MsgBox(const Msg: String; const Caption: String; const Flags: LongInt): Integer;
begin

  Result:=Application.MessageBox(PChar(Msg), PChar(Caption), Flags);

end;

function WinActivate(const h: HWND): Boolean;
var
  pt: Point;
  hOther: HWND;
  currentThreadId, otherThreadId: DWORD;
begin
  Result:=True;

  if WinActive(h) then Exit;

  try
    hOther:=GetForegroundWindow();

    if (hOther=0) then begin
      GetCursorPos(pt);
      hOther := WindowFromPoint(pt);
    end;

    otherThreadId:=GetWindowThreadProcessId(hOther, nil);
    currentThreadId:=GetCurrentThreadId();

    if(otherThreadId=0) then begin
      Result:=False;
      Exit;
    end;

    if(otherThreadId<>currentThreadId) then
      AttachThreadInput(otherThreadId, currentThreadId, True);

      Result:=BringWindowToTop(h); // and activate

    if Result then begin
      WAK.LastUsed:=h;
      WinSleep(WAK.WinDelay);
    end;

  finally
    if(otherThreadId<>currentThreadId) then
      AttachThreadInput(otherThreadId, currentThreadId, False);

    if IsIconic(h) then WinRestore(h);

  end;
end;

//Checks if window is the active foreground
function WinActive(const h: HWND): Boolean;
begin
  if h=GetForegroundWindow then
    Result:=True
  else
    Result:=False;
end;

//Closes a window. If windows prompts on close then user must intervene.
function WinClose(const h: HWND): Boolean;
begin
  Result:=PostMessage(h, WM_CLOSE, 0, 0);
  WinSleep(WAK.WinDelay);
end;

//Finds a window. If exists then returns handle, else zero.
function WinExists(const h: HWND): Boolean;
begin
  Result:=False;
  if h<>0 then begin
    Result:=True;
    WAK.LastUsed:=h;
  end;
end;

//Get the window class name.
function WinGetClass(const h: HWND): String;
var
  WBuf: array[0..MAX_PATH] of WChar;
begin
  WBuf:=''; //avoid compiler warnings
  GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
  Result:=UnicodeString(WBuf);
end;

function EnumGetTextCallBack(hc: HWND; lp: LPARAM): LongBool; stdcall;
var
  Win: PThWin;
  WBuf: array[0..MAX_PATH] of WChar;
  Text: String;
begin
  Win:={%H-}PThWin(lp);
  WBuf:=''; //avoid compiler warnings
  //Win^.FindText:='';  //do not clear the text buffer, we want to append every pass
  if IsWindowVisible(hc) then begin
    SendMessageW(hc, WM_GETTEXT, MAX_PATH, {%H-}LPARAM(@WBuf));
    Text:=TrimRight(UnicodeString(WBuf));
    if Text<>'' then begin
      if Length(Text)+Length(TextBuf)<$FFFF then
        Win^.FindText:=Win^.FindText+Text+LineEnding;
    end;
  end;
  Result:=True;   //keep searching for child windows
end;

//Returns up to 65Kb of visible text from window.
function WinGetText(const h: HWND): String;
var
  Win: ThWin;
begin
  Win.FindText:='';
  Result:='';
  if h=0 then Exit;
  if IsWindowVisible(h) then begin
    EnumChildWindows(h, @EnumGetTextCallBack, {%H-}LPARAM(@Win));
  end;
  Result:=Win.FindText;
end;

//Returns window title. Does not check if window is visible.
function WinGetTitle(const h: HWND): String;
var
  WBuf: array[0..MAX_PATH] of WChar;
begin
  Result:='';
  if h=0 then exit;
  WBuf:=''; //avoid compiler warnings
  GetWindowTextW(h, LPWSTR(WBuf), MAX_PATH);
  Result:=TrimRight(UnicodeString(WBuf));
end;

//Get handle of window with matching Title [and/or Text [and/or Class]]
function WinGetHandle(const FindTitle: String=''; FindText: String='';
  FindClass: String=''): HWND;
begin
  Result:=hWin(FindTitle, FindText, FindClass);
end;

//returns window state: show, hide, minimize, maximize, or restore.
function WinGetState(const h: HWND): UInt;
var
  wp: TWindowPlacement;
begin
  wp:=Default(TWindowPlacement);  //optional
  GetWindowPlacement(h, wp);
  wp.length := SizeOf(wp);
  Result:=wp.showCmd;
end;

//Show, hide, minimize, maximize, restore, etc. a window.  if succes then T, else F
//showCmd: SW_HIDE, SW_MINIMIZE, SW_MAXIMIZE, SW_NORMAL, SW_RESTORE
function WinSetState(const h: HWND; showCmd: integer): Boolean;
begin
  Result:=ShowWindow(h, showCmd);
  if (showCmd<>SW_HIDE) and (showCmd<>SW_MINIMIZE) and (showCmd<>SW_FORCEMINIMIZE) then
    SetForegroundWindow(h);
  WinSleep(WAK.WinDelay);
end;

function WinShow(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_SHOW);
end;
function WinHide(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_HIDE);
end;
function WinMinimize(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_MINIMIZE);
end;
function WinMaximize(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_MAXIMIZE);
end;
function WinNormal(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_NORMAL);
end;
function WinRestore(const h: HWND): Boolean;
begin
  Result:=WinSetState(h,SW_RESTORE);
end;

//Wait until window is active. If found then true, else false = timeout.
function WinWaitActive(const h: HWND; const Timeout: Integer=0): Boolean;
var
  i: integer;
begin
  i:=0;
  Result:=False;
  WinSleep(WAK.WinDelay);
  while i<=(Timeout*4) do begin
    if WinActive(h) then begin
      Result:=True;
      WAK.LastUsed:=h;
      Break;
    end;
    WinSleep(QUARTER_SECOND);
    Inc(i);
  end;
end;

//Wait until window is not active. If success then true, else false is a timeout.
function WinWaitNotActive(const h: HWND; const Timeout: Integer=0): Boolean;
var
  i: integer;
begin
  i:=0;
  Result:=False;
  while i<=(Timeout*4) do begin
    if not WinActive(h) then begin
      Result:=True;
      WAK.LastUsed:=h;
      Break;
    end;
    WinSleep(QUARTER_SECOND);
    Inc(i);
  end;
end;

//Wait until window closes. If success then True, else False due to timeout.
function WinWaitClose(const h: HWND; const Timeout: Integer=0): Boolean;
var
  i: integer;
begin
  Result:=False;
  i:=0;
  while i<=(Timeout*4) do begin
    if not IsWindow(h) then begin
      Result:=True;
      Break;
    end;
    WinSleep(QUARTER_SECOND);
    Inc(i);
  end;
end;

//Wait until window exists. If found then HWND, else 0 due to timeout.
//Polls about every 100ms, Timeout in milliseconds e.g. 1e3=1000=1 second

function WinWait(const FindTitle: String=''; const FindText: String='';
  const FindClass: String=''; const Timeout: Integer=0): HWND;
var
  i: integer;
  h: HWND;

begin
  i:=0;
  Result:=0;
  while i<(Timeout*4) do begin
    WinSleep(QUARTER_SECOND);
    h:=hWin(FindTitle, FindText, FindClass);
    if h<>0 then begin
      Result:=h;
      WAK.LastUsed:=h;
      Break;
    end;
    Inc(i);
  end;
end;

function WinList(const FindTitle: String): TStringList;
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle: String;
  MatchTitle: Boolean;
begin
  Result:=TStringList.Create;

  h:=FindWindow(nil, nil);
  while h<>0 do begin

    if IsWindowVisible(h) then
    begin

      WinHandle:=IntToHex(h,4);

      Len:=GetWindowTextLengthW(h);
      SetLength(WBuf, Len);

      GetWindowTextW(h, LPWSTR(WBuf), Len+1);
      WinTitle:=WBuf;

      MatchTitle:=_DoMatch(WAK.TitleMatchMode, FindTitle, WinTitle);

      if MatchTitle then
        Result.Add(Winhandle+': '+WinTitle);

    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
end;
procedure WinListProc(AList: TStringList; const FindTitle: String);
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle: String;
  MatchTitle: Boolean;
begin

  h:=FindWindow(nil, nil);
  while h<>0 do begin

    if IsWindowVisible(h) then
    begin

      WinHandle:=IntToHex(h,4);

      Len:=GetWindowTextLengthW(h);
      SetLength(WBuf, Len);
      GetWindowTextW(h, LPWSTR(WBuf), Len+1);
      WinTitle:=WBuf;

      MatchTitle:=_DoMatch(WAK.TitleMatchMode, FindTitle, WinTitle);

      if MatchTitle then
        AList.Add(Winhandle+': '+WinTitle);

    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
end;


initialization
  WAK.CaseSensitive:=False;  //True AutoIT, False AutoHotKey
  WAK.KeyDelay:=5;           //5ms AutoIT for older PC, 50ms for new and faster PC
  WAK.LastUsed:=0;           //Most recently used by WinExist, WinActive, WinWait
  WAK.MouseDelay:=10;        //10ms AutoIT
  WAK.TitleMatchMode:=1;     //mtStartsWith=1,mtSubString=2,mtExact=3
  WAK.TextMatchMode:=2;      //mtStartsWith=1,mtSubString=2,mtExact=3
  WAK.WinDelay:=100;         //100ms AutoIT for older PC, 200ms for new and faster PC
  {AutoHotKey
  g.WinDelay = 100;
	g.ControlDelay = 20;
	g.KeyDelay = 10;
	g.MouseDelay = 10;
  }

end.

