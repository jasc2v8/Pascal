{ Windows Admin Launch Tool (WALT) by jasc2v8 at yahoo dot com

walt v1.1.0

https://www.winhelponline.com/blog/shell-commands-to-access-the-special-folders/

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
  {Windows,}
  Classes, SysUtils, FileUtil, Forms, Controls, Dialogs, StdCtrls,
  WinAutoKey;
type

  { TForm1 }

  TForm1 = class(TForm)
    btnLaunch: TButton;
    btnCancel: TButton;
    ListBox: TListBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnLaunchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure ListBoxKeyPress(Sender: TObject; var Key: char);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure _DoControlClick(Ctl: THandle; const Button: TMouseButton=mbLeft);
var
  ScreenX, ScreenY: Integer;
begin
  MouseGetPos(ScreenX, ScreenY);
  ControlClick(Ctl,Button);
  MouseMove(ScreenX, ScreenY);
end;

procedure SendStartRun(Ctl: THandle; Item: String); //run shell:AppData
begin
  if LeftStr(Item,1)<>'{' then begin
    _DoControlClick(Ctl,mbRight);
    WinSleep;
    Send([VK_UP, VK_UP, VK_UP, VK_RETURN]);
    WinSleep;
    Send(Item);
    Send(VK_RETURN);
  end;
end;

procedure SendSearchRun(Ctl: THandle; Item: String); //search run shell:AppData
begin
  if LeftStr(Item,1)<>'{' then begin
    _DoControlClick(Ctl);
    WinSleep;  //need a little extra time for the search window to appear

    {when the search button is pressed, the control class changes from
    Shell_TrayWnd to the desktop with no Class name
    Therefore, wait for Shell_TrayWnd to close}
    WinWaitClose(hWin('','','Shell_TrayWnd'),2);

    Send(['run', VK_RETURN]);

    WinWait('Run','Type the name of a program','',5);
    Send([Item, VK_RETURN]);
  end;
end;

procedure SendSearch(Ctl: THandle; Item: String); //search %appdata%
begin
  if LeftStr(Item,1)<>'{' then begin
    _DoControlClick(Ctl);
    WinSleep;
    WinWaitClose(hWin('','','Shell_TrayWnd'),2);
    Send(Item);
    Send(VK_RETURN);
  end;
end;

{ TForm1 }

procedure TForm1.btnLaunchClick(Sender: TObject);
var
  hTray, hStart, hSearch: THandle;
  s: string;
  i: integer;
begin

  hTray:=hWin('','','Shell_TrayWnd');
  hStart:=hCtl(hTray,'Start','Start');

  //if search button then hSearch:=hCtl(hTray,'Type here to search','TrayButton', 4103);
  //if search editbox then hSearch:=hCtl(hTray,'Type here to search','Static', 4101);
  //therefore, just search for text
  hSearch:=hCtl(hTray,'Type here to search');

  if (hTray=0) or (hStart=0) or (hSearch=0) then begin
    ShowMessage(Format('Error getting control handles.'+LE+
      'Handles: hTray=%x, hStart=%x, hSearch=%x',[hTray,hStart,hSearch]));
  end;

  i:=ListBox.ItemIndex;

  if i>=0 then begin
    s:=ListBox.Items[i];
    if LeftStr(s,1)='%' then
      SendSearch(hSearch, s)      //search %appdata%
    else
      //SendStartRun(hStart, s);   //works, but lets stay away from the Start button
      SendSearchRun(hSearch, s);   //search run shell:AppData
  end;

end;

procedure TForm1.btnCancelClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.ListBoxDblClick(Sender: TObject);
begin
  if ListBox.ItemIndex>=0 then begin
    WinSleep(WAK.KeyDelay*50);
    BtnLaunchClick(Self);
  end;
end;

procedure TForm1.ListBoxKeyPress(Sender: TObject; var Key: char);
begin
  if Key=Chr(VK_RETURN) then BtnLaunchClick(Self);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  i, j: integer;
begin
  btnLaunch.SetFocus;

  for i:=ListBox.Count-1 downto 0 do begin

    j:=Pos('//',ListBox.Items[i]);
    if j<>0 then begin
      ListBox.Items.Delete(i);
    end;

    j:=Pos('=',ListBox.Items[i]);
    if j<>0 then
      ListBox.Items[i]:='%'+Copy(ListBox.Items[i],1,j-1)+'%';
  end;

end;

end.

