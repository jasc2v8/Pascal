{ C:\lazarus\184\fpc\3.0.4\source\packages\winunits-jedi\src\jwawinuser.pas  }

{ Use Function names from AutoHotKey

DONE: WinSetState //Shows, hides, minimizes, maximizes, or restores a window.

TODO:

WinGetText(h)
WinGetTitle(h)
WinGetClassList(h)
WinGetState

others:
  WinActivateBottom
  WinGet
  WinGetActiveStats
  WinGetActiveTitle
  WinGetPos
*WinGetText
*WinGetTitle
WinKill(h)          //kill process.exe of window?
  WinMenuSelectItem
WinMinimizeAll      //Win-D?
  WinMove
  WinSet
WinSetTitle
}

unit winunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows,
  Dialogs; //debug with ShowMessage

type
  TMatchType=set of (mtExact, mtPartial, mtStartsWith);

FUNCTION TEST(Key: Char): SHORT;

{ Human Input Devices }

function KeyState: SHORT;

procedure WinSend(h: HWND; Keys: String; RepeatCount: integer=1; Delay: integer=0);
procedure WinSend(h: HWND; Key: Word; RepeatCount: integer=1; Delay: integer=0);

{ Windows }

function WinActivate(const h: HWND): Boolean;

function WinActive(const h: HWND): Boolean;

function WinClose(const h: HWND): Boolean;

function WinExists(const Title: String; {const Text: String='';}
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=True): HWND;

function WinExistsEX(const Title: String; const ClassName: String;
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=True): HWND;

function WinGetClass(const h: HWND): String;

function WinGetHandle(const ExactTitleNoCase: WideString;
  const ExactClassNoCase: WideString=''): HWND;

function WinGetState(const h: HWND): UInt;

function WinSetState(const h: HWND; wp: TWindowPlacement; const Delay: Integer=0): Boolean;

function WinShow(const h: HWND; Delay: Integer=0): Boolean;
function WinHide(const h: HWND; Delay: Integer=0): Boolean;
function WinMinimize(const h: HWND; Delay: Integer=0): Boolean;
function WinMaximize(const h: HWND; Delay: Integer=0): Boolean;
function WinNormal(const h: HWND; Delay: Integer=0): Boolean;
function WinRestore(const h: HWND; Delay: Integer=0): Boolean;

function WinWaitActive(const Title: String; {const Text: string='';} const TimeOut: integer=0;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): Boolean;

function WinWaitClose(const Title: String; {const Text: string='';} const TimeOut: integer=0;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): Boolean;

function WinWait(const Title: String; {const Text: String='';} const TimeOut: Integer=0;
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=False): HWND;

//wip

function WinList(const SearchTitle: String;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): TStringList;

procedure WinListProc(AList: TStringList; const SearchTitle: String;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false);

//abandon?
function GetStatusTEST: String;

function GetStatusText(const h: HWND): String;

const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  FSendDelay: Integer;

implementation

FUNCTION TEST(Key: Byte): SHORT;
BEGIN
  Result:=VkKeyScanA(Key);
end;

{ Human Input Devices }

// TODO: WinAsyncKeyState(Key: integer): boolean  and $80?

//returns 1 if the key is down (or toggled on) or 0 if it is up (or toggled off).
function KeyState: SHORT;
begin
  Result:=GetAsyncKeyState(VK_ESCAPE);
end;
procedure WinSetSendDelay(Delay: integer=0);
begin
  FSendDelay:=Delay;
end;
procedure WinSend(h: HWND; Keys: String; RepeatCount: integer=1; Delay: integer=0);
var
  i,j: Integer;
begin
  for i:=1 to RepeatCount do begin
    for j:=1 to Length(Keys) do
      PostMessageW(h, WM_CHAR, Word(Keys[j]), 0);
    if (Delay=0) and (FSendDelay>0) then
      Sleep(FSendDelay)
    else
      Sleep(Delay);
  end;
end;
procedure WinSend(h: HWND; Key: Word; RepeatCount: integer=1; Delay: integer=0);
var
  i: Integer;
begin
  for i:=1 to RepeatCount do begin
    PostMessageW(h, WM_CHAR, Key, 0);
    if (Delay=0) and (FSendDelay>0) then
      Sleep(FSendDelay)
    else
      Sleep(Delay);
  end;
end;

{ Windows }

function WinActivate(const h: HWND): Boolean;
begin
  Result:=BringWindowToTop(h); // and activate
end;
function WinActive(const h: HWND): Boolean;
begin
  if h=GetForegroundWindow then
    Result:=True
  else
    Result:=False;
end;
function WinClose(const h: HWND): Boolean;
begin
  Result:=CloseWindow(h);
end;
//returns handle if window exists, or zero if not
//TODO: match Text in CHILD window
function WinExists(const Title: String; {const Text: String='';}
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=True): HWND;
var
  h: HWND;
  Len: LongInt;
  TitleParam: String;
  WBuf: WideString;
  WinTitle: String;
begin
  h:=FindWindow(nil, nil);
  while h<>0 do begin

    if IsWindowVisible(h) then
    begin

      Len:=GetWindowTextLengthW(h);
      SetLength(WBuf, Len);
      GetWindowTextW(h, LPWSTR(WBuf), Len+1);
      WinTitle:=WBuf;

      if NoCase then begin
        WinTitle:=UpperCase(WinTitle);
        TitleParam:=UpperCase(Title);
      end else
        TitleParam:=Title;

      if MatchType=[mtExact] then
        if TitleParam=WinTitle then
         Break;

      if MatchType=[mtPartial] then
        if Pos(TitleParam, WinTitle)<>0 then
          Break;

      if MatchType=[mtStartsWith] then
        if LeftStr(WinTitle, Length(TitleParam))=TitleParam then
          Break;
    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;

  //DEBUG ShowMessage('WinTitle=['+WinTitle+']');

  Result:=h;
end;
//returns handle if window exists, or zero if not
//TODO: match Text in CHILD window
function WinExistsEX(const Title: String; const ClassName: String;
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=True): HWND;
var
  h, hc: HWND;
  Len: LongInt;
  TitleParam: String;
  WBuf: WideString;
  WinTitle, WinClassName: String;
  MatchTitle, MatchClassName: Boolean;
begin
  MatchTitle:=False;
  MatchClassName:=False;

  //ok ShowMessage('Title='+Title+', ClassName='+ClassName);

  h:=FindWindow(nil, nil);

  while h<>0 do begin

    if IsWindowVisible(h) then
    begin

      Len:=GetWindowTextLengthW(h);
      SetLength(WBuf, Len);
      GetWindowTextW(h, LPWSTR(WBuf), Len+1);
      WinTitle:=WBuf;

      if NoCase then begin
        WinTitle:=UpperCase(WinTitle);
        TitleParam:=UpperCase(Title);
      end else
        TitleParam:=Title;

      if MatchType=[mtExact] then
        if TitleParam=WinTitle then
         MatchTitle:=True;

      if MatchType=[mtPartial] then
        if Pos(TitleParam, WinTitle)<>0 then
          MatchTitle:=True;

      if MatchType=[mtStartsWith] then
        if LeftStr(WinTitle, Length(TitleParam))=TitleParam then
          MatchTitle:=True;

      { Class }

      if MatchTitle then begin
        hc:=0;
        //repeat
          hc := FindWindowEx(h, hc, 'Edit', nil );
        //until hc=0;
        WinClassName:=WinGetClass(hc);
        if WinClassName=ClassName then
          MatchClassName:=True;
      end;
    end;

    if MatchTitle and MatchClassName then begin
      //ShowMessage('Match BOTH');
      //Break;
      H:=0;
    end ELSE
      h:=GetWindow(h, GW_HWNDNEXT);

  end;

  //DEBUG ShowMessage('WinTitle=['+WinTitle+']');

  Result:=hc;
end;
function WinGetClass(const h: HWND): String;
var
  WBuf: array[0..MAX_PATH] of WChar;
begin
  GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
  Result:=UnicodeString(WBuf);
end;
function WinGetHandle(const ExactTitleNoCase: WideString;
  const ExactClassNoCase: WideString=''): HWND;
var
  lpWindowName: LPCWSTR;
  lpClassName: LPCWSTR;
begin
  if ExactTitleNoCase='' then
    lpWindowName:=nil
  else
    lpWindowName:=LPCWSTR(ExactTitleNoCase);

  if ExactClassNoCase='' then
    lpClassName:=nil
  else
    lpClassName:=LPCWSTR(ExactClassNoCase);

  Result:=FindWindowW(lpClassName, lpWindowName);
end;
//returns window state: show, hide, minimize, maximize, or restore.
function WinGetState(const h: HWND): UInt;
var
  wp: TWindowPlacement;
begin
  GetWindowPlacement(h, @wp);
  wp.length := SizeOf(wp);
  Result:=wp.showCmd;
end;
//Shows, hides, minimizes, maximizes, or restores a window.
function WinSetState(const h: HWND; wp: TWindowPlacement; const Delay: Integer=0): Boolean;
begin
  Sleep(Delay);
  Result:=SetWindowPlacement(h, @wp);
end;
function DoSetState(const h: HWND; showCmd: UINT; Delay: Integer=0): Boolean;
var
  wp: TWindowPlacement;
begin
  GetWindowPlacement(h, @wp);
  wp.showCmd:=showCmd;
  wp.length := SizeOf(wp);
  Sleep(Delay);
  Result:=SetWindowPlacement(h, @wp);
end;
function WinShow(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_SHOW,Delay);
end;
function WinHide(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_HIDE,Delay);
end;
function WinMinimize(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_MINIMIZE,Delay);
end;
function WinMaximize(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_MAXIMIZE,Delay);
end;
function WinNormal(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_NORMAL,Delay);
end;
function WinRestore(const h: HWND; Delay: Integer=0): Boolean;
begin
  Result:=DoSetState(h,SW_RESTORE,Delay);
end;
//wait until window is active. returns true or false if timeout.
function WinWaitActive(const Title: String; {const Text: String='';} const TimeOut: integer=0;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): Boolean;
var
  i: integer;
  h: HWND;
begin
  i:=0;
  Result:=False;
  while true do begin

    Sleep(250);

    h:=WinExists(Title);
    if h=0 then begin
      Result:=False;
      Break;
    end;

    if WinActive(h) then begin
      Result:=True;
      Break;
    end;

    Inc(i);
    if i>(TimeOut*4) then Break;
  end;
end;
//wait until window closes. returns true or false if timeout.
function WinWaitClose(const Title: String; {const Text: string='';} const TimeOut: integer=0;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): Boolean;
var
  i: integer;
begin
  i:=0;
  Result:=False;
  while true do begin
    Sleep(250);
    if WinExists(Title)=0 then begin
      Result:=True;
      Break;
    end;
    Inc(i);
    if i>(TimeOut*4) then Break;
  end;
end;
//wait until window exists. returns handle or zero if timeout.
function WinWait(const Title: String; {const Text: String='';} const TimeOut: Integer=0;
  const MatchType: TMatchType=[mtPartial]; const NoCase: Boolean=False): HWND;
var
  i: integer;
begin
  i:=0;
  Result:=0;
  while Result=0 do begin
    Sleep(250);
    Inc(i);
    if i>(TimeOut*4) then Break;
    Result:=WinExists(Title, {Text,} MatchType, NoCase);
  end;
end;
function WinList(const SearchTitle: String;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false): TStringList;
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle: String;
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

      Result.Add(Winhandle+': '+WinTitle);

    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
end;
procedure WinListProc(AList: TStringList; const SearchTitle: String;
  const MatchType: TMatchType=[mtPartial]; const CaseSensitive: Boolean=false);
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle: String;
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

      AList.Add(Winhandle+': '+WinTitle);

    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
end;
function GetStatusText(const h: HWND): String;
var
  hStatusBar: HWND;
  StatusBarText: array[0..$FFF] of Char;
  WBuf: WideString;
begin
  //WM_GETTEXTLENGTH

  Result := '';

  if h <> 0 then begin
    SendMessage(h, WM_GETTEXT, $FFF, Longint(@StatusBarText));
    Result := StrPas(StatusBarText);
  end;
end;
function GetStatusTEST: String;
var
  ExplorerWnd: HWND;
  StatusWnd: HWND;
  //MM: TProcessMemMgr;
  Cnt, i, Len: Integer;
  PrcBuf: PChar;
  PartText: String;
  Buf: String;
  StatusBarText: array[0..$FFF] of Char;
begin
  //ExplorerWnd := FindWindow(nil,'Quick Reference | AutoHotkey - Google Chrome');
  ExplorerWnd:=WinExists('Quick Reference | AutoHotkey - Google Chrome');
  //ExplorerWnd:=WinExists('#');

  if ExplorerWnd = 0 then begin
    Result:='did not find Internet Explorer_Server';
    exit;
  end;

  StatusWnd := FindWindowEx(ExplorerWnd, 0, 'msctls_statusbar32', nil);
  if StatusWnd = 0 then begin
    Result:='did not find msctls_statusbar32';
    exit;
  end;


  try
    Cnt := SendMessage(StatusWnd, SB_GETPARTS, 0, 0);
    for i := 0 to Cnt - 1 do begin
      Len := LoWord(SendMessage(StatusWnd, SB_GETTEXTLENGTH, i, 0));
      if Len > 0 then begin
        //PrcBuf := MM.AllocMem(Len + 1);
        //SendMessage(StatusWnd, SB_GETTEXT, i, LongInt(PrcBuf));
        SendMessage(StatusWnd, SB_GETTEXT, i, LongInt(@StatusBarText));
        //PartText := MM.ReadStr(PrcBuf);
        //MM.FreeMem(PrcBuf);
      end else begin
        //PartText := '';
        StatusBarText:='';
      end;
      //ListBox1.Items.Add(PartText);
      Buf:=Buf+StrPas(StatusBarText);
    end;
  finally
    //MM.Free;
  end;
  Result:=Buf;
end;
end.

