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
  ExtCtrls, Menus, WinAutoKey, LCLType, ShellApi;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    Memo1: TMemo;
    miClose: TMenuItem;
    miShow: TMenuItem;
    miOpen: TMenuItem;
    miSend: TMenuItem;
    miExit: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure SendKeysAsync(Data: PtrInt);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure miSendClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;

  WINDOW_TITLE='Untitled - Notepad';

var
  Form1: TForm1;
  hNotepad: HWND;
  Count: Integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.SendKeysAsync(Data: PtrInt);
begin

  Send('Send async: The rain in Spain... Count='+Data.ToString+LE);

end;

procedure TForm1.ButtonOKClick(Sender: TObject);
begin
  if WinExists(hNotepad) then begin
    WinActivate(hNotepad);
    Inc(Count);
    Application.QueueAsyncCall(@SendKeysAsync,Count);
  end;
  Form1.Hide;
end;

procedure TForm1.miOpenClick(Sender: TObject);
begin

  if WinExists(hNotepad) then Exit;

  Memo1.Clear;

  ShellExecute(0, 'open', 'notepad.exe', nil, nil, SW_SHOWNORMAL);

  hNotepad:=WinWait('','','Notepad',2);
  if hNotepad=0 then begin
    Form1.Show;
    Memo1.Append('Error could not open Notepad');
    Exit;
  end;

end;

procedure TForm1.miSendClick(Sender: TObject);
begin

  if not WinExists(hNotepad) then Exit;

  Inc(Count);

  if not WinActivate(hNotepad) then begin
    Form1.Show;
    Memo1.Append('Error could not activate Notepad');
    Exit;
  end;

  Application.QueueAsyncCall(@SendKeysAsync,Count);

  Inc(Count);

  Send('Send sync: ...falls mainly on the plain. Count='+Count.ToString+LE);

end;

procedure TForm1.miCloseClick(Sender: TObject);
begin

  if not WinExists(hNotepad) then Exit;

  if not WinActivate(hNotepad) then begin
    Form1.Show;
    Memo1.Append('Error could not activate Notepad');
    Exit;
  end;

  Send([VK_ALT_DN, VK_F, VK_ALT_UP, VK_X, VK_N]); //close Notepad

end;

procedure TForm1.miExitClick(Sender: TObject);
begin

  if WinExists(hNotepad) then begin
    WinActivate(hNotepad);
    Send([VK_ALT_DN, VK_F, VK_ALT_UP, VK_X, VK_N]); //close Notepad
  end;

  Form1.Close;
end;

procedure TForm1.miShowClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  Application.ShowMainForm:=False;

  TrayIcon.Hint:='WinAutoKey Tray Example';
  TrayIcon.Visible:=True;

  TrayIcon.BalloonTitle:=Application.Title;
  TrayIcon.BalloonHint:='Right-Click on the [W] tray icon...';
  TrayIcon.ShowBalloonHint;

  Count:=0;

end;

end.

