{
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

For more information, please refer to <http://unlicense.org>
}

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnOpen: TButton;
    btnListAll: TButton;
    btnListVisible: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
    procedure btnClearClick(Sender: TObject);
    procedure btnListVisibleClick(Sender: TObject);
    procedure btnListAllClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
  WININFO_FILE='wininfo.csv';

var
  Form1: TForm1;
  WinList: TStringList;
  iWinCount, iCtlCount: Integer;
  hLast, hParent: HWND;
  ListVisible: boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnClearClick(Sender: TObject);
begin
  Application.ProcessMessages;
  Memo1.Clear;
  Memo1.Append('Ready.');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  WinList:=TStringList.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  WinList.Free;
end;

function hWinCallBack(h: HWND; {%H-}lp: LPARAM): LongBool; stdcall;
var
  WBuf: array[0..MAX_PATH] of WChar;
  WinParent, WinTitle, WinClass, WinText, WinVisible, WinHandle, WinParentHandle: String;
  WinInfo: string;
begin

  //not used Win:={%H-}PThWin(lp);

  Result:=True; //keep searching

  WBuf:=''; //avoid compiler warnings

  if IsWindowVisible(h) then
    WinVisible:='T'
  else
    WinVisible:='F';

  WinHandle:='0x'+IntToHex(h,8);

  {to test:
  browse to wikipedia in korean: https://ko.wikipedia.org/wiki/%EC%9D%BC%EB%B3%B8
  Copy text, paste in Notepad++, set encoding to UTF-8
  Run wininfo, will capture the visible text in Notepad++
  Open the CSV with Excel will show ? because Excel is not UTF-8
  Open the CSV with Notepad++, set encoding to UTF-8, will show Korean chars}

  GetWindowTextW(h, LPWSTR(WBuf), MAX_PATH);
  WinTitle:={%H-}TrimRight(UnicodeString(WBuf));
  WinTitle:=StringReplace(WinTitle, ',', ' ',[rfReplaceAll]);
  WinTitle:=StringReplace(WinTitle, LineEnding, '',[rfReplaceAll]);

  GetClassNameW(h, LPWSTR(WBuf), MAX_PATH);
  WinClass:={%H-}TrimRight(UnicodeString(WBuf));

  SendMessageW(h, WM_GETTEXT, MAX_PATH, {%H-}LPARAM(@WBuf));
  WinText:={%H-}TrimRight(UnicodeString(WBuf));
  WinText:=StringReplace(WinText, ',', ' ',[rfReplaceAll]);
  WinText:=StringReplace(WinText, LineEnding, '',[rfReplaceAll]);

  hParent:=GetParent(h);
  if hParent=0 then
    WinParent:='PARENT'
  else
    WinParent:='CHILD';

  WinParentHandle:='0x'+IntToHex(hParent,8);

  WinInfo:=WinParent+','+WinTitle+','+WinText+','+WinClass+','+WinVisible+','+
    WinHandle+','+WinParentHandle;

  if ListVisible and (WinVisible='T') or (not ListVisible) then
  WinList.Add(WinInfo);

  iCtlCount:=0;

  Inc(iWinCount);

end;

procedure TForm1.btnListAllClick(Sender: TObject);
var
  iDelay: integer;
begin

  iCtlCount:=0;
  iWinCount:=0;

  iDelay:=SpinEdit1.Value*1000;

  Memo1.Clear;
  if iDelay>0 then Memo1.Append('Delay...');

  WinList.Clear;
  WinList.Add('Relationship,Title,Text,Class,Visible,Handle,ParentHandle');

  Sleep(iDelay); //time to hover over link to show tooltip

  Memo1.Append('Working...');

  hParent:=0;
  hLast:=1;

  //not used EnumChildWindows(GetDesktopWindow(), @hWinCallBack, {%H-}LPARAM(@Win));
  EnumChildWindows(GetDesktopWindow(), @hWinCallBack, 0);

  WinList.SaveToFile(WININFO_FILE);

  //For i:=0 to WinList.Count-1 do begin
  // Memo1.Append(WinList[i]);
  //end;

  Memo1.Append('Finished, Count='+WinList.Count.ToString);
end;

procedure TForm1.btnOpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', WININFO_FILE, nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.btnListVisibleClick(Sender: TObject);
begin
  ListVisible:=True;
  btnListAllClick(nil);
  ListVisible:=False;
end;

end.

