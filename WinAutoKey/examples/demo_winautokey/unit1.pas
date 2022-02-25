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
  Classes, SysUtils, LResources, Forms, StdCtrls, ShellApi,
  FileUtil, Controls, lclintf, DateUtils, Dialogs,
  Windows, WinAutoKey, Clipbrd;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnPaint: TButton;
    btnMouse: TButton;
    btnExtract: TButton;
    btnWinState: TButton;
    btnNotepad: TButton;
    Memo1: TMemo;
    procedure btnMouseClick(Sender: TObject);
    procedure btnPaintClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnNotepadClick(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
    procedure btnWinStateClick(Sender: TObject);
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
var
  i: integer;
begin
  Result:=False;
  for i:=1 to 5 do begin
    Application.ProcessMessages;
    if GetKeyState(VK_ESCAPE)<>0 then begin
      Result:=True;
      Break;
    end;
    Sleep(10);
  end;
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
      //Debugln('ThisLink='+ThisLink);
      FoundFirstLink:=True;
      Break;
    end;

  until (ThisLink=LastLink) or (i=22 {MAX_LINKS});

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

  until (ThisLink=LastLink) or (LinkCount=5); //limit for demo

end;

{ save links as htm - for Chrome browser }
procedure TForm1.btnExtractClick(Sender: TObject);
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
  h: HWND;
  StartTime, EndTime, TimeDiff : TDateTime;
  LinksPerSecond: Single;
  Yr,Mo,Day,Hr,Min,Sec,MS: Word;
begin
  h:=0;
  Memo1.Clear;

  StartTime := Now;
  Memo1.Append('Start Time: '+FormatDateTime('hh:nn:ss.zzz',StartTime));

  SetKeyDelay(WAK.KeyDelay*10);  //default 10ms
  SetWinDelay(WAK.WinDelay*2);   //default 100ms

  { default StartsWith match, nocase }
  h:=WinGetHandle(WINDOW_TITLE);

  if not WinExists(h) then begin
    OpenURL(WINDOW_URL);
    h:=WinWait(WINDOW_TITLE,'','',5);
    if h=0 then begin
      Memo1.Append('Error cannot activate: '+WINDOW_TITLE);
      Exit;
    end;
  end;

  if not WinActive(h) then begin
    if not WinActivate(h) then begin
      Memo1.Append('Error could not activate: '+WINDOW_TITLE);
      Exit;
    end;
  end;

  Application.Minimize;

  WinRestore(h);
  Send(VK_F5);  //refresh browser
  WinSleep(WAK.WinDelay);
  Send(VK_F11); //full screen
  WinSleep(WAK.WinDelay);

  //some links cannot be copied with Shift-F10, so view source to get to the links
  Send([VK_CONTROL_DOWN,VK_U,VK_CONTROL_UP]);
  WinSleep(WAK.WinDelay);

  //click on whitespace to clear any selected links
  MouseClick(mbLeft,[],5,5);

  if DirectoryExists(HTML_DIR) then
    DeleteDirectory(HTML_DIR,True)
  else
    ForceDirectories(HTML_DIR);

  Send(VK_TAB,12);

  if ExtractLinks(h, FIRST_LINK, LAST_LINK) then begin
    Send(VK_F11); //full screen off
    WinSleep(WAK.WinDelay);
  end;

  Application.Restore;

  Memo1.Append('Number of Links saved: '+LinkCount.ToString);

  EndTime := Now;
  TimeDiff := EndTime - StartTime;
  Memo1.Append('End Time: '+FormatDateTime('hh:nn:ss.zzz',EndTime));
  Memo1.Append('Elapsed Time: '+FormatDateTime('hh:nn:ss.zzz',TimeDiff, [fdoInterval]));

  DecodeDateTime(TimeDiff,Yr,Mo,Day,Hr,Min,Sec,MS);
  LinksPerSecond:=((Min*60+Sec)/LinkCount);
  Memo1.Append('Links per second: '+Format('%2.1n', [LinksPerSecond]));

  Memo1.SelStart:=Length(Memo1.Text); //scroll to bottom

end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm1.btnPaintClick(Sender: TObject);
var
  hc, hPaint: HWND;
  CtlText: String;
begin
  { Lazarus changes the controlID each time, so controlID can't be used}
  {Notepad and MSPaint keep the same controlID each time, so use them}

  Memo1.Clear;

  hc:=WinGetHandle('ACTIVE');
  Memo1.Append('Handle for Active Window='+IntToHex(hc,4));

  hc:=WinGetHandle('Demo');
  Memo1.Append('Handle for Demo='+IntToHex(hc,4));

  hc:=WinGetHandle('');
  Memo1.Append('Handle for Last Found Window='+IntToHex(hc,4));

  CtlText:=ControlGetText(hCtl(hc, 'Clear') );
  Memo1.Append('Button Text='+CtlText);

  CtlText:=ControlGetText(hCtl(hc, 'MSPaint') );
  Memo1.Append('Button Text='+CtlText);

  //Paint.exe status bar 100% = 53251
  ShellExecute(Handle, 'open', 'mspaint.exe', nil, nil, SW_SHOWNORMAL);

  hPaint:=WinWait('Untitled - Paint','','',2);

  if hPaint=0 then Memo1.Append('Error opening Paint');
  Memo1.Append('MSPaint handle='+IntToHex(hPaint,4));

  CtlText:='';
  CtlText:=WinGetText(hPaint);
  Memo1.Append('MSPaint text='+CtlText);

  WinMinimize(hPaint);

  hc:=hCtl(hPaint, '','',53251);
  Memo1.Append('MSPaint static handle A='+IntToHex(hc,4));

  CtlText:=ControlGetText(hc);
  Memo1.Append('MSPaint static text A='+CtlText);

  hc:=hCtl(hPaint, '100%');
  Memo1.Append('MSPaint static handle B='+IntToHex(hc,4));

  hc:=hCtl(hPaint, '', 'Static');
  Memo1.Append('MSPaint static handle C='+IntToHex(hc,4));

  //CtlText:=ControlGetText(hCtl(hPaint, 0,'100%','Static'));

  Sleep(1000);
  WinClose(hPaint);

end;

procedure TForm1.btnMouseClick(Sender: TObject);
var
  hNotepad, hSaveAs, hBtnCancel, hc: HWND;
  WinText: string;
  r: TRECT;
begin
  Memo1.Clear;

  ShellExecute(Handle, 'open', 'c:\Windows\notepad.exe', nil, nil, SW_SHOWNORMAL);

  hNotepad:=WinWait('','','Notepad',2);
  Memo1.Append('hNotepad='+IntToHex(hNotepad,4));

  Send('The rain in Spain...');

  SetKeyDelay(500);  //slow down for demo

  Send([VK_ALT_DN, VK_F, VK_ALT_UP, VK_S]); //File, Save As

  hSaveAs:=WinWait('Save As','','',2);
  Memo1.Append('hSaveAs='+IntToHex(hSaveAs,4));

  ControlClick(hCtl(hSaveAs,'Cancel'));

  Send([VK_ALT_DN, VK_F4, VK_ALT_UP, VK_N]); //Close Window, no save

  SetKeyDelay(5);   //restore to default

end;

procedure TForm1.btnNotepadClick(Sender: TObject);
var
  hNotepad, hControl: HWND;
  WinText: string;
begin
  Memo1.Clear;

  ShellExecute(Handle, 'open', 'c:\Windows\notepad.exe', nil, nil, SW_SHOWNORMAL);
  Sleep(500);

  hNotepad:=WinWait('Untitled','','',2);
  Memo1.Append('WinWait Handle='+IntToHex(hNotepad,4));

  SetKeyDelay;
  Send(['The rain in Spain', VK_RETURN]);

  Sleep(250);

  hControl:=ControlGetHandle(hNotepad, '', 'Edit');
  Memo1.Append('Control Handle='+IntToHex(hControl,4));

  //demos of a few ways to get the control text
  WinText:=ControlGetText(hControl);
  Memo1.Append('Control Text1='+WinText);

  WinText:=ControlGetText(ControlGetHandle(hNotepad, 'the RAIN'));
  Memo1.Append('Control Text2='+WinText);

  WinText:=ControlGetText(hCtl(hNotepad,'THE RAIN', 'Edit'));
  Memo1.Append('Control Text3='+WinText);

  ShowMessage('Press ENTER to close Notepad');

  //bring Notepad to front, just to demo
  if not WinActivate(hNotepad) then Memo1.Append('ERROR activating window');
  Sleep(500);

  //close notepad
  if not WinClose(hNotepad) then Memo1.Append('ERROR closing window');
  Send(VK_N);

  Memo1.Append('Done.');

end;

procedure TForm1.btnWinStateClick(Sender: TObject);
var
  hNotepad: HWND;
  i: Integer;
  WINDOW_TITLE: String='Untitled - Notepad';
begin

  Memo1.Clear;
  i:=0;

  ShellExecute(Handle, 'open', 'c:\Windows\notepad.exe', nil, nil, SW_SHOWNORMAL);
  Sleep(500);

  hNotepad:=WinWait(WINDOW_TITLE, '','',5);
  if hNotepad=0 then begin
    Memo1.Append('Error does not exist: '+WINDOW_TITLE);
    Exit;
  end else
    Memo1.Append('Handle='+IntToHex(hNotepad,4));

  if not WinActive(hNotepad) then begin
    if not WinActivate(hNotepad) then begin
      Memo1.Append('Error could not activate: '+WINDOW_TITLE);
      Exit;
    end;
  end;

  Memo1.Append('Start: '+WINDOW_TITLE);

  Inc(i);
  Memo1.Append(Format('%d WinActivate',[i]));
  Sleep(250);

  WinHide(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinHide',[i]));
  Sleep(250);

  WinShow(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinShow',[i]));
  Sleep(250);

  WinMinimize(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinMinimize',[i]));
  Sleep(250);

  WinRestore(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinRestore',[i]));
  Sleep(250);

  WinMaximize(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinMaximize',[i]));
  Sleep(250);

  WinNormal(hNotepad);
  Inc(i);
  Memo1.Append(Format('%d WinNormal',[i]));
  Sleep(250);

  ShowMessage('Press ENTER to close Notepad');

  //bring Notepad to front, just to demo
  if not WinActivate(hNotepad) then Memo1.Append('ERROR activating window');
  Sleep(500);

  //close notepad
  if not WinClose(hNotepad) then Memo1.Append('ERROR closing window');
  Send(VK_N);

  Memo1.Append('Done.');
end;

end.

