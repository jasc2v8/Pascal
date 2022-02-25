{ get text from window in other app http://www.delphipages.com/forum/showthread.php?t=176341 }

{ Use Function names from AutoHotKey

WinActivate
WinExists (same as WinExist, GetHandle)

TODO:
  WinActivateBottom
WinActive
WinClose
  WinGet
  WinGetActiveStats
  WinGetActiveTitle
  WinGetClass
  WinGetPos
WinGetText
WinGetTitle
WinHide
WinKill
WinMaximize
  WinMenuSelectItem
WinMinimize
WinMinimizeAll
  WinMove
WinRestore
  WinSet
WinSetTitle
WinShow
  WinWait
  WinWaitActive
  WinWaitClose
}

unit winunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows,
  Dialogs, debugunit; //debug with ShowMessage

type

  TWinInfo = record
    WinHandle: HWND;
    WinClass: string;
    WinTitle: string;
    WinText: string;
    WinVisible: boolean;
  end;

  TMatchType=set of (mtExact, mtPartial, mtStartsWith);


function WinGetInfo(h: HWND): TWinInfo;

function GetStatusTEST: string;

function GetStatusText(h: HWND): string;

function WinActivate(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;

function WinActive(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;

function WinExists(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;

function WinList(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): TStringList;

procedure WinListProc(AList: TStringList; SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false);


const
  DS=DirectorySeparator;
  LE=LineEnding;

implementation

function WinActivate(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;
begin
  Result:=WinExists(SearchTitle, MatchType, CaseSensitive);
  if (Result<>0) then
    BringWindowToTop(Result); // and activate
end;
{
GetWindowInfo(hWnd: THandle, pwi : TWindowInfo)

function in delphi, is this exists in freepascal,because TWindowInfo sturcture has

tagWINDOWINFO = record
     cbSize: DWORD;
     rcWindow: TRect;
     rcClient: TRect;
     dwStyle: DWORD;
     dwExStyle: DWORD;
     dwWindowStatus: DWORD;
     cxWindowBorders: UINT;
     cyWindowBorders: UINT;
     atomWindowType: TAtom;
     wCreatorVersion: WORD;
  end;

}

function WinActive(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;
begin
  Result:=WinExists(SearchTitle, MatchType, CaseSensitive);
  if (Result<>0) then
    BringWindowToTop(Result); // and activate
end;
function WinExists(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): HWND;
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinTitle: string;
begin
  h:=FindWindow(nil, nil);
  while h<>0 do begin

    if IsWindowVisible(h) then
    begin

      Len:=GetWindowTextLengthW(h);
      SetLength(WBuf, Len);
      GetWindowTextW(h, LPWSTR(WBuf), Len+1);
      WinTitle:=WBuf;

      if not CaseSensitive then begin
        WinTitle:=UpperCase(WinTitle);
        SearchTitle:=UpperCase(SearchTitle);
      end;

      if MatchType=[mtExact] then
        if SearchTitle=WinTitle then
         Break;

      if MatchType=[mtPartial] then
        if Pos(SearchTitle, WinTitle)<>0 then
          Break;

      if MatchType=[mtStartsWith] then
        if LeftStr(WinTitle, Length(SearchTitle))=SearchTitle then
          Break;
    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
  Result:=h;
end;
function WinList(SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false): TStringList;
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle, WinClass: string;
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

      //WBuf:='';
      GetClassNameW(h, LPWSTR(WBuf), 64);
      SetLength(WBuf, 32);
      WinClass:=WBuf;


      Result.Add(Winhandle+': '+WinTitle+', Class: '+WinClass);

    end;

    h:=GetWindow(h, GW_HWNDNEXT);

  end;
end;
procedure WinListProc(AList: TStringList; SearchTitle: string;
  MatchType: TMatchType=[mtPartial]; CaseSensitive: boolean=false);
var
  h: HWND;
  Len: LongInt;
  WBuf: WideString;
  WinHandle, WinTitle: string;
begin

  h:=FindWindow(nil, nil);
  while h<>0 do begin

    //if IsWindowVisible(h) then
    if TRUE then
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
function GetStatusText(h: HWND): string;
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
function GetStatusTEST: string;
var
  ExplorerWnd: HWND;
  StatusWnd: HWND;
  //MM: TProcessMemMgr;
  Cnt, i, Len: Integer;
  PrcBuf: PChar;
  PartText: String;
  s: string;
begin
  s:='';
  ExplorerWnd := FindWindow('Tooltips_class32', nil);
  if ExplorerWnd = 0 then exit;
  //StatusWnd := FindWindowEx(ExplorerWnd, 0, 'Tooltips_class32', nil);
  //if StatusWnd = 0 then exit;
  try
    Cnt := SendMessage(StatusWnd, SB_GETPARTS, 0, 0);
    for i := 0 to Cnt - 1 do begin
      Len := LoWord(SendMessage(StatusWnd, SB_GETTEXTLENGTH, i, 0));
      if Len > 0 then begin
        SendMessage(StatusWnd, SB_GETTEXT, i, LongInt(PrcBuf));
        PartText:= PrcBuf;
      end else begin
        PartText:='';
      end;
      s:=PartText;
    end;
  finally
    //MM.Free;
  end;
  Result:=s;
end;
function WinGetInfo(h: HWND): TWinInfo;
var
  Info: TWinInfo;
  WBuf: array[0..MAX_PATH] of WChar;
begin
  if h=0 then begin
    Info.WinHandle:=0;
    Info.WinClass:='';
    Info.WinTitle:='';
    Info.WinText:='';
    Info.WinVisible:=false;
  end else begin
    Info.WinHandle:=h;

    GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
    Info.WinClass:=TrimRight(UnicodeString(WBuf));

    GetWindowTextW(h, LPWSTR(WBuf), MAX_PATH);
    Info.WinTitle:=UnicodeString(WBuf);

    SendMessageW(h, WM_GETTEXT, MAX_PATH, LPARAM(@WBuf));
    Info.WinText:=UnicodeString(WBuf);

    Info.WinVisible:=IsWindowVisible(h);
  end;
  Result:=Info;
end;

end.

