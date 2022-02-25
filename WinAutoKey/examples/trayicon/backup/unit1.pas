{ Skype Audio Manager (C) Copyright 2018 by James O. Dreher
  Right-click on the icon in the system tray to select audio device.
  For Skype for Business on Window 10
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

  //SetTitleMatchMode(mtExact);
  //SetKeyDelay(10);    //default 5ms
  //SetWinDelay(200);   //default 100ms

  TrayIcon.Hint:='WinAutoKey Tray Example';
  TrayIcon.Visible:=True;

  TrayIcon.BalloonTitle:=Application.Title;
  TrayIcon.BalloonHint:='Right-Click on the [W] tray icon...';
  TrayIcon.ShowBalloonHint;

  Count:=0;

end;

end.

