{ Skype Audio Manager (C) Copyright 2018 by James O. Dreher
  Right-click on the icon in the system tray to select audio device.
  For Skype for Business on Window 10
}

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  ExtCtrls, Menus, Windows, ShellApi, RunElevatedUnit, WinAutoKey;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    Memo1: TMemo;
    miStartSkype: TMenuItem;
    miCustomDevice: TMenuItem;
    miShow: TMenuItem;
    miHeadset: TMenuItem;
    miSpeakerPhone: TMenuItem;
    miExit: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure StartSkypePrompt;
    procedure GetCurrentDevice;
    procedure ChangeDevice(const Device: Word);
    procedure CheckSelectedDevice(const Device: Word);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure miCustomDeviceClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miHeadsetClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
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

procedure TForm1.ChangeDevice(const Device: Word);
var
  hw, ho: HWND;
begin

  hw:=WinGetHandle(WINDOW_TITLE);
  if hw=0 then begin
    StartSkypePrompt;
    Exit;
  end;

  if not WinActivate(hw) then begin
    Form1.Show;
    Memo1.Append('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  try
    SetBlockInput(True);  //does nothing if not run as admin
    Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
    Send(VK_V);                         // Audio DeVice
  finally
    SetBlockInput(False);
  end;

  ho:=WinWait(OPTIONS_TITLE,'','',2);
  if ho=0 then begin
    Form1.Show;
    Memo1.Append('Timeout waiting for: '+OPTIONS_TITLE);
    Exit;
  end;

  try
    SetBlockInput(True);
    ControlFocus(hCtl(ho,'','',148));   //ComboBox1
    Send(Device);                       //Headphones, Echo Speakerphone, or Custom
    ControlFocus(hCtl(ho,'OK'));        //OK button
    Send(VK_RETURN);                    // Audio DeVice
  finally
    SetBlockInput(False);
  end;

  CheckSelectedDevice(Device);

  todo fix so this is not necessary:
  //SetBlockInput(False);

end;

procedure TForm1.GetCurrentDevice;
var
  TextList: TStringList;
  hw, ho: HWND;
  CurrentDevice: Word;
  Reply: integer;
begin

  TextList:=TStringList.Create;

  hw:=WinGetHandle(WINDOW_TITLE);
  if hw=0 then begin
    StartSkypePrompt;
  end;

  hw:=WinWait(WINDOW_TITLE,'Find someone or dial a number','',15);
  if hw=0 then begin
    Form1.Show;
    Memo1.Append('Error timeout waiting for window: '+WINDOW_TITLE);
    Exit;
  end;

  if not WinActivate(hw) then begin
    Form1.Show;
    Memo1.Append('Error could not activate: '+WINDOW_TITLE);
    Exit;
  end;

  { currently selected device }

  try
    SetBlockInput(True);
    Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
    Send(VK_V);                         // Audio DeVice
  finally
    SetBlockInput(False);
  end;

  ho:=WinWait(OPTIONS_TITLE,'','',2);
  if ho=0 then begin
    Form1.Show;
    Memo1.Append('Timeout waiting for: '+OPTIONS_TITLE);
    Exit;
  end;

  TextList.Text:=WinGetText(ho);
  Send(VK_ESCAPE);

  Application.ProcessMessages;

  CurrentDevice:=Ord(UpperCase(TextList[4])[1]);

  CheckSelectedDevice(CurrentDevice);

  //WHY IS THIS NEEDED?
  //SetBlockInput(False);

  FreeAndNil(TextList);
end;

procedure TForm1.ButtonOKClick(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.StartSkypePrompt;
var
  Reply: integer;
begin
  Reply:=MsgBox('Skype not running, start Skype?', Application.Title,
    MB_ICONQUESTION + MB_YESNO);
  if Reply=IDYES then
    ShellExecute(Handle, 'open', SKYPE_EXE, nil, nil, SW_SHOWNORMAL)
  else begin
    TrayIcon.Hint:='Skype Not Running';
    miHeadset.Checked:=False;
    miSpeakerPhone.Checked:=False;
    miCustomDevice.Checked:=False;
  end
end;

procedure TForm1.miStartSkypeClick(Sender: TObject);
begin
  if not WinExists(hWin(WINDOW_TITLE)) then begin
    ShellExecute(Handle, 'open', SKYPE_EXE, nil, nil, SW_SHOWNORMAL);
    GetCurrentDevice;
  end;
end;

procedure TForm1.miHeadsetClick(Sender: TObject);
begin
  ChangeDevice(VK_H);
end;

procedure TForm1.miSpeakerPhoneClick(Sender: TObject);
begin
  ChangeDevice(VK_E);
end;

procedure TForm1.miCustomDeviceClick(Sender: TObject);
begin
  ChangeDevice(VK_C);
end;

procedure TForm1.miShowClick(Sender: TObject);
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

  //if minimized then not visible

  //if WinExists(hWin(WINDOW_TITLE)) then
  if not IsElevated then begin
    TrayIcon.BalloonHint:='WARNING - Requires Run As Admin to Block Input!';
    TrayIcon.ShowBalloonHint;
  end;

  GetCurrentDevice;

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
    end;
  end;
end;
end.

