{ Skype Audio Manager (C) Copyright 2018 by James O. Dreher
  Right-click on the icon in the system tray to select audio device.
  For Skype for Business on Window 10
}

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  ExtCtrls, Menus, Windows, ShellApi, WinAutoKey, BlockInputUnit;

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
    function StartSkypePrompt: Boolean;
    procedure GetCurrentDevice;
    procedure ChangeDevice(const Device: String);
    procedure SetSelectedDevice(const Device: String);
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

procedure TForm1.SetSelectedDevice(const Device: String);
begin

  miHeadset.Checked:=False;
  miSpeakerPhone.Checked:=False;
  miCustomDevice.Checked:=False;

  Case UpperCase(Device) of
    'H' : miHeadset.Checked:=True;
    'E' : miSpeakerPhone.Checked:=True;
    'C' : miCustomDevice.Checked:=True;
  end;

  Case Device of
    'H' : TrayIcon.Hint:='Headset';
    'E' : TrayIcon.Hint:='Speaker Phone';
    'C' : TrayIcon.Hint:='Custom Device';
  end;

  Application.ProcessMessages;

  TrayIcon.BalloonHint:=TrayIcon.Hint+' selected.';
  TrayIcon.ShowBalloonHint;
end;

procedure TForm1.ChangeDevice(const Device: String);
var
  hw, ho: HWND;
begin

  if WinGetHandle(WINDOW_TITLE)=0 then begin
    if not StartSkypePrompt then Exit;
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

  try
    //Application.ProcessMessages;
    if IsElevated then SetBlockInput(True);  //does nothing if not run as admin
    //Application.ProcessMessages;
    Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
    Send(VK_V);                         // Audio DeVice
  finally
    //Application.ProcessMessages;
    if IsElevated then SetBlockInput(False);
    //Application.ProcessMessages;
  end;

  ho:=WinWait(OPTIONS_TITLE,'','',5);
  if ho=0 then begin
    Form1.Show;
    Memo1.Append('Timeout waiting for debug2: '+OPTIONS_TITLE);
    Exit;
  end;

  try
    //Application.ProcessMessages;
    if IsElevated then SetBlockInput(True);
    //Application.ProcessMessages;
    ControlFocus(hCtl(ho,'','',148));   //ComboBox1
    Send(Device);                       //Headphones, Echo Speakerphone, or Custom
    ControlFocus(hCtl(ho,'OK'));        //OK button
    Send(VK_RETURN);                    // Audio DeVice
  finally
    //Application.ProcessMessages;
    if IsElevated then SetBlockInput(False);
    //Application.ProcessMessages;
  end;

  SetSelectedDevice(Device);

end;

procedure TForm1.GetCurrentDevice;
var
  TextList: TStringList;
  hw, ho: HWND;
  CurrentDevice: String;
  Reply: integer;
begin

  TextList:=TStringList.Create;

  if WinGetHandle(WINDOW_TITLE)=0 then begin
    if not StartSkypePrompt then Exit;
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

  try
    if IsElevated then SetBlockInput(True);
    Send([VK_ALT_DN,VK_T,VK_ALT_UP]);   // Tools
    Send(VK_V);                         // Audio DeVice
  finally
    if IsElevated then SetBlockInput(False);
  end;

  ho:=WinWait(OPTIONS_TITLE,'','',5);
  if ho=0 then begin
    Form1.Show;
    Memo1.Append('Timeout waiting for debug1: '+OPTIONS_TITLE);
    Exit;
  end;

  TextList.Text:=WinGetText(ho);
  Send(VK_ESCAPE);

  Application.ProcessMessages;

  CurrentDevice:=UpperCase(TextList[4])[1];

  SetSelectedDevice(CurrentDevice);

  FreeAndNil(TextList);
end;

procedure TForm1.ButtonOKClick(Sender: TObject);
begin
  Form1.Hide;
end;

function TForm1.StartSkypePrompt: Boolean;
var
  Reply: integer;
  msg: String;
begin
  if IsElevated then
    msg:='(Is admin, input will be blocked)'
  else
    msg:='(Not admin, input won''t be blocked)';

  Reply:=MsgBox(msg+', Start Skype ?', Application.Title,
    MB_ICONQUESTION + MB_YESNO);
  if Reply=IDYES then begin
    ShellExecute(Handle, 'open', SKYPE_EXE, nil, nil, SW_SHOWNORMAL);
    Result:=True;
  end else begin
    TrayIcon.Hint:='Skype Not Running';
    miHeadset.Checked:=False;
    miSpeakerPhone.Checked:=False;
    miCustomDevice.Checked:=False;
    Result:=False;
  end;
end;

procedure TForm1.miStartSkypeClick(Sender: TObject);
begin
  if not WinExists(hWin(WINDOW_TITLE)) then begin
    //ShellExecute(Handle, 'open', SKYPE_EXE, nil, nil, SW_SHOWNORMAL);
    GetCurrentDevice;
  end;
end;

procedure TForm1.miHeadsetClick(Sender: TObject);
begin
  ChangeDevice('H');
end;

procedure TForm1.miSpeakerPhoneClick(Sender: TObject);
begin
  ChangeDevice('E');
end;

procedure TForm1.miCustomDeviceClick(Sender: TObject);
begin
  ChangeDevice('C');
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
var
  hw: HWND;
begin

  Application.ShowMainForm:=False;

  TrayIcon.Hint:='Skype Audio Manager';
  TrayIcon.BalloonTitle:=TrayIcon.Hint;
  TrayIcon.Visible:=True;

  SetTitleMatchMode(mtExact);
  SetTextMatchMode(mtStartsWith);

  SetKeyDelay(10);   //default 5ms
  SetWinDelay(200);   //default 100ms

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

