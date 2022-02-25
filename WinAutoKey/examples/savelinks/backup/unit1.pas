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
  Classes, SysUtils, Forms, StdCtrls,
  FileUtil, Controls, lclintf, DateUtils, Clipbrd,
  Windows,  //HWND
  WinAutoKey;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnSaveLinks: TButton;
    Memo1: TMemo;
    procedure btnClearClick(Sender: TObject);
    procedure btnSaveLinksClick(Sender: TObject);
    function ExtractLinks(h: HWND; const FirstLink: String; const LastLink: String): Boolean;
    procedure FormClick(Sender: TObject);
  private
  public
  end;
const
  HTML_DIR='.\html\';

var
  Form1: TForm1;
  CurDirSet: boolean;
  LinkCount: Integer;

implementation

{$R unit1.lfm}

function AbortKeyPressed: boolean;
begin
  Result:=False;
  Application.ProcessMessages;
  if GetKeyState(VK_ESCAPE)<>0 then Result:=True;
end;

function SaveLink: boolean;
var
  h: HWND;
begin
  Result:=False;

  Send([VK_SHIFT_DOWN, VK_F10, VK_SHIFT_UP]);
  Send(VK_DOWN, 4);
  Send(VK_RETURN);

  if AbortKeyPressed then begin
    Result:=False;
    Exit;
  end;

  h:=WinWait('Save As','','',5);
  if h=0 then Exit;

  if not CurDirSet then begin
    Send(VK_HOME);
    SetKeyDelay(0);
    Send(GetCurrentDir+'\html\');
    SetKeyDelay(5*3);
    CurDirSet:=true;
  end;

  Send(VK_RETURN);

  if not WinWaitClose(h,5) then Exit;

  Result:=True;
end;

function CopyLink: string;
begin
  Send([VK_SHIFT_DOWN, VK_F10, VK_SHIFT_UP]);
  Send(VK_DOWN,5);
  Send(VK_RETURN);
  Sleep(WAK.WinDelay);
  Result:=Clipboard.AsText;
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  Memo1.Clear;
end;

function TForm1.ExtractLinks(h: HWND;
  const FirstLink: String; const LastLink: String): Boolean;
var
  i,p: integer;
  ThisLink, ThisFileName: string;
  FoundFirstLink: Boolean;
begin
  i:=0;
  Result:=True;
  FoundFirstLink:=False;

  //find first link
  repeat

    if AbortKeyPressed then begin
      Break;
    end;

    WinActivate(h); //keep window on top

    Send(VK_TAB);
    ThisLink:=CopyLink;
    Inc(i);

    if CompareText(ThisLink,FirstLink)=0 then begin
      FoundFirstLink:=True;
      Break;
    end;

  until (ThisLink=LastLink) or (i=3 {MAX_LINKS}); //limit for demo

  if not FoundFirstLink then begin
    Application.Restore;
    Memo1.Append('Error first link not found.');
    Exit;
  end;

  //extract other links
  LinkCount:=0;
  repeat

    if AbortKeyPressed then begin
      Break;
    end;

    {depends on the web page
    if Pos('.htm',ThisLink)=0 then begin
      Send(VK_TAB);
      Continue;
    end;}

    p:=Pos('#',ThisLink);

    if (p<>0) then begin
      ThisLink:=Copy(ThisLink,1,p-1);
    end;

    ThisFileName:=ExtractFileName(ThisLink);

    if FileExists(HTML_DIR+ThisFileName) then begin
      Send(VK_TAB);
      Continue;
    end else if not SaveLink then begin
      Memo1.Append('TIMEOUT');
      Result:=False;
      Break;
    end;

    Inc(LinkCount);

    Send(VK_TAB);

    ThisLink:=CopyLink;

  until (ThisLink=LastLink) or (LinkCount=5); //debug

end;

{ save links as htm - for Chrome browser }
procedure TForm1.btnSaveLinksClick(Sender: TObject);
const

  WINDOW_URL='https://docs.microsoft.com/en-us/windows/desktop/';
  WINDOW_TITLE='Develop Windows desktop applications';
  FIRST_LINK='https://docs.microsoft.com/en-us/windows/desktop/choose-your-technology';
  LAST_LINK='https://docs.microsoft.com/en-us/windows/desktop/winrt/reference';

  //WINDOW_URL='https://www.autoitscript.com/autoit3/docs/functions.htm';
  //WINDOW_TITLE='Functions';
  //FIRST_LINK='https://www.autoitscript.com/autoit3/docs/functions/Abs.htm';
  //LAST_LINK='https://www.autoitscript.com/autoit3/docs/functions/WinWaitNotActive.htm';

  //WINDOW_URL='https://autohotkey.com/docs/commands/';
  //WINDOW_TITLE='Alphabetical Command and Function Index';
  //FIRST_LINK='https://autohotkey.com/docs/commands/Block.htm';
  //LAST_LINK='https://autohotkey.com/docs/commands/_WinActivateForce.htm';

var
  hChrome, hDemo, hWidget: HWND;
  StartTime, EndTime, TimeDiff: TDateTime;
  LinksPerSecond: Single;
  Yr,Mo,Day,Hr,Min,Sec,MS: Word;
begin
  Memo1.Clear;

  StartTime := Now;
  Memo1.Append('Start Time: '+FormatDateTime('hh:nn:ss.zzz',StartTime));

  SetKeyDelay(WAK.KeyDelay*2);  //default 10ms
  SetWinDelay(WAK.WinDelay*2);  //default 100ms

  hDemo:=WinGetHandle('Demo WinAutoKey SaveLinks');

  hChrome:=WinGetHandle(WINDOW_TITLE);

  if not WinExists(hChrome) then begin
    OpenURL(WINDOW_URL);
    hChrome:=WinWait(WINDOW_TITLE,'','',5);
    if hChrome=0 then begin
      Memo1.Append('Error cannot open window: '+WINDOW_TITLE);
      Exit;
    end;
  end;

  if not WinActivate(hChrome) then begin
    Memo1.Append('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  hWidget:=WinWait('', '','Chrome_WidgetWin_1',5);
  if hWidget=0 then begin
    WinActivate(hDemo);
    Memo1.Append('Error: Use the Chrome browser for this demo: '+WINDOW_TITLE);
    Exit;
  end;

  Application.Minimize;

  Send(VK_F5);  //refresh browser
  WinSleep(5000);

  Send(VK_F11); //full screen
  WinSleep(2500);

  //some links cannot be copied with Shift-F10, so view source to get to the links
  Send([VK_CONTROL_DOWN,VK_U,VK_CONTROL_UP]);

  //click on whitespace to clear any selected links
  MouseClick(mbLeft,[],5,5);

  if DirectoryExists(HTML_DIR) then
    DeleteDirectory(HTML_DIR,True)
  else
    ForceDirectories(HTML_DIR);

  //tab to first link - varies depending on the web page
  Send(VK_TAB,12);

  if ExtractLinks(hChrome, FIRST_LINK, LAST_LINK) then begin
    Send(VK_F11); //full screen off
    WinSleep(WAK.WinDelay);
    Send([VK_CONTROL_DOWN,VK_W,VK_CONTROL_UP]); //close tab
  end;

  Application.Restore;

  Memo1.Append('Number of Links saved: '+LinkCount.ToString);

  EndTime := Now;
  TimeDiff := EndTime - StartTime;
  Memo1.Append('End Time: '+FormatDateTime('hh:nn:ss.zzz',EndTime));
  Memo1.Append('Elapsed Time: '+FormatDateTime('hh:nn:ss.zzz',TimeDiff, [fdoInterval]));

  DecodeDateTime(TimeDiff,Yr,Mo,Day,Hr,Min,Sec,MS);
  if LinkCount>0 then
    LinksPerSecond:=((Min*60+Sec)/LinkCount)
  else
    LinksPerSecond:=0;
  Memo1.Append('Links per second: '+Format('%2.1n', [LinksPerSecond]));

  Memo1.SelStart:=Length(Memo1.Text); //scroll to bottom

end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

end.

