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
    ButtonClose: TButton;
    Label1: TLabel;
    miStartSkype: TMenuItem;
    miCustomDevice: TMenuItem;
    miAbout: TMenuItem;
    miHeadset: TMenuItem;
    miSpeakerPhone: TMenuItem;
    miExit: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure StartSkype;
    procedure CheckSelectedDevice(const Device: Word);
    procedure GetCurrentDeviceAsync(Data: PtrInt);
    procedure ChangeDeviceAsync(Data: PtrInt);
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure miCustomDeviceClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miHeadsetClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miSpeakerPhoneClick(Sender: TObject);
    procedure miStartSkypeClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;

  WINDOW_TITLE='Skype for Business';
  OPTIONS_TITLE='Skype for Business - Options';
  SKYPE_EXE='"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\'+
    'Microsoft Office 2013\Skype for Business 2015.lnk"';

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.CheckSelectedDevice(const Device: Word);
begin

  miHeadset.Checked:=False;
  miSpeakerPhone.Checked:=False;
  miCustomDevice.Checked:=False;

  Case Device of
    VK_H : miHeadset.Checked:=True;
    VK_E : miSpeakerPhone.Checked:=True;
    VK_C : miCustomDevice.Checked:=True;
  end;

  Case Device of
    VK_H : TrayIcon.Hint:='Headset';
    VK_E : TrayIcon.Hint:='Speaker Phone';
    VK_C : TrayIcon.Hint:='Custom Device';
  end;

  Application.ProcessMessages;

  TrayIcon.BalloonHint:=TrayIcon.Hint+' selected.';
  TrayIcon.ShowBalloonHint;
end;

procedure TForm1.StartSkype;
begin
  ShellExecute(Handle, 'open', SKYPE_EXE, nil, nil, SW_SHOWNORMAL);
  miHeadset.Enabled:=true;
  miSpeakerPhone.Enabled:=true;
  miCustomDevice.Enabled:=true;
end;

procedure TForm1.ChangeDeviceAsync(Data: PtrInt);
var
  hw, ho: HWND;
begin

  hw:=WinGetHandle(WINDOW_TITLE);
  if hw=0 then begin
    StartSkype;
    Exit;
  end;

  if not WinActivate(hw) then begin
    ShowMessage('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
  Send(VK_V);                         // Audio DeVice

  ho:=WinWait(OPTIONS_TITLE,'','',2);
  if ho=0 then begin
    ShowMessage('Timeout waiting for: '+OPTIONS_TITLE);
    Exit;
  end;

  ControlFocus(hCtl(ho,'','',148));    //ComboBox1

  Send(Data);                          //Headphones, Echo Speakerphone, or Custom

  ControlFocus(hCtl(ho,'OK'));         //OK button
  Send(VK_RETURN);

  CheckSelectedDevice(Data);
end;

procedure TForm1.GetCurrentDeviceAsync(Data: PtrInt);
var
  TextList: TStringList;
  hw, ho: HWND;
  CurrentDevice: Word;
begin

  TextList:=TStringList.Create;

  hw:=WinGetHandle(WINDOW_TITLE);
  if hw=0 then begin
    StartSkype;
  end;

  hw:=WinWait(WINDOW_TITLE,'Find someone or dial a number','',15);
  if hw=0 then begin
    ShowMessage('Error timeout waiting for window: '+WINDOW_TITLE);
    Exit;
  end;

  if not WinActivate(hw) then begin
    ShowMessage('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  { currently selected device }

  Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
  Send(VK_V);                         // Audio DeVice

  ho:=WinWait(OPTIONS_TITLE,'','',2);
  if ho=0 then begin
    ShowMessage('Timeout waiting for: '+OPTIONS_TITLE);
    Exit;
  end;

  TextList.Text:=WinGetText(ho);
  Send(VK_ESCAPE);

  Application.ProcessMessages;

  CurrentDevice:=Ord(UpperCase(TextList[4])[1]);

  CheckSelectedDevice(CurrentDevice);

  FreeAndNil(TextList);
end;

procedure TForm1.ButtonCloseClick(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.miStartSkypeClick(Sender: TObject);
begin
  Application.QueueAsyncCall(@GetCurrentDeviceAsync,0);
end;

procedure TForm1.miHeadsetClick(Sender: TObject);
begin
  if not miHeadset.Checked then
    Application.QueueAsyncCall(@ChangeDeviceAsync,VK_H);
end;

procedure TForm1.miSpeakerPhoneClick(Sender: TObject);
begin
  if not miSpeakerPhone.Checked then
    Application.QueueAsyncCall(@ChangeDeviceAsync,VK_E);
end;

procedure TForm1.miCustomDeviceClick(Sender: TObject);
begin
  if not miCustomDevice.Checked then
    Application.QueueAsyncCall(@ChangeDeviceAsync,VK_C);
end;

procedure TForm1.miAboutClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.miExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  Application.ShowMainForm:=False;

  TrayIcon.Hint:='Skype Audio Manager';
  TrayIcon.BalloonTitle:=TrayIcon.Hint;
  TrayIcon.Visible:=True;

  SetTitleMatchMode(mtExact);
  SetTextMatchMode(mtStartsWith);

  SetKeyDelay(10);   //default 5ms
  SetWinDelay(200);   //default 100ms

  //don't auto start skype Application.QueueAsyncCall(@GetCurrentDeviceAsync,0);
  miHeadset.Enabled:=false;
  miSpeakerPhone.Enabled:=false;
  miCustomDevice.Enabled:=false;
end;
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  h: HWND;
  Reply: integer;
begin

  h:=hWin(WINDOW_TITLE);

  if WinExists(h) then begin
    Reply:=Application.MessageBox('Exit '+WINDOW_TITLE+'?',
      PChar(Application.Title), MB_ICONQUESTION + MB_YESNO);
    if Reply=IDYES then begin
        WinActivate(h);
        Send([VK_ALT_DN,VK_F,VK_ALT_UP,VK_X]);
    end else
      CloseAction:=caHide
    end;
end;
end.

