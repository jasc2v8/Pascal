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
    miCustom: TMenuItem;
    miShow: TMenuItem;
    miHeadphones: TMenuItem;
    miSpeakerphone: TMenuItem;
    miExit: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure Async(Data: PtrInt);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miExitClick(Sender: TObject);
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

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Async(Data: PtrInt);
var
  h, hNotepad, hPaint: Integer {HWND};
begin

  Memo1.Clear;

  ShellExecute(Handle, 'open', 'notepad.exe', nil, nil, SW_SHOWNORMAL);

  hNotepad:=WinWait('','','Notepad',2);
  Memo1.Append('hNotepad='+IntToHex(hNotepad,4));

  ShellExecute(Handle, 'open', 'mspaint.exe', nil, nil, SW_SHOWNORMAL);

  hPaint:=WinWait('','','MSPaintApp',2);
  Memo1.Append('hPaint='+IntToHex(hPaint,4));

  if not WinActivate(hNotepad) then begin
    Form1.Show;
    Memo1.Append('Error could not activate Notepad');
    Exit;
  end;

  Send('The rain in Spain...');

  if not WinActivate(hPaint) then begin
    Form1.Show;
    Memo1.Append('Error could not activate Paint');
    Exit;
  end;

  Send([VK_ALT_DN, VK_F4, VK_ALT_UP]); //close Paint

  if not WinActivate(hNotepad) then begin
    Form1.Show;
    Memo1.Append('Error could not activate Notepad');
    Exit;
  end;

  Send([VK_ALT_DN, VK_F, VK_ALT_UP, VK_A]); //Notepad save as

  h:=WinWait('Save As','','',2);
  Memo1.Append('h='+IntToHex(h,4));

  WinActivate(h);

  ControlFocus(hCtl(h, 'Cancel','Button'));

  Send(VK_RETURN);

  Send([VK_ALT_DN, VK_F, VK_ALT_UP, VK_X, VK_N]); //close Notepad

exit;

  WinSleep(1000);

  hNotepad:=WinGetHandle(WINDOW_TITLE);
  if hNotepad=0 then begin
    Form1.Show;
    Memo1.Append('Error Skype window not found'+WINDOW_TITLE);
    Exit;
  end;

  if not WinActivate(hNotepad) then begin
    Form1.Show;
    Memo1.Append('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  //Form1.Hide;
end;

procedure TForm1.ButtonOKClick(Sender: TObject);
begin
  Application.QueueAsyncCall(@Async,0);
  Form1.Hide;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  Application.ShowMainForm:=False;

  TrayIcon.Hint:='WinAutoKey Tray Template';
  TrayIcon.Visible:=True;

  //SetTitleMatchMode(mtExact);
  //SetKeyDelay(50);   //default 5ms
  SetWinDelay(500);   //default 100ms

  Application.QueueAsyncCall(@Async,0);

end;

procedure TForm1.FormShow(Sender: TObject);
begin

end;

procedure TForm1.miExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.miShowClick(Sender: TObject);
begin
  //ShowMessage('Show');
  Form1.Show;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
begin
  Form1.Show;
end;

end.

