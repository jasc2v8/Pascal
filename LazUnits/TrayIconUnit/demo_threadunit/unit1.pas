{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org> }

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus,
  threadunit;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    Memo1: TMemo;
    miShow: TMenuItem;
    miStart: TMenuItem;
    miStop: TMenuItem;
    miExit: TMenuItem;
    PopupMenu1: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miStartClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
    procedure miStopClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  Form1: TForm1;
  Thread1: TThreadUnit;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonOKClick(Sender: TObject);
begin
  Form1.Hide;
  if miStart.Checked then
    miStart.Checked:=False
  else
    miStart.Checked:=True;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(Thread1) then begin
    Thread1.Terminate;
    Thread1.WaitFor;
    if not Thread1.FreeOnTerminate then FreeAndNil(Thread1);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TrayIcon.Hint:='Demo ThreadUnit';
  TrayIcon.Visible:=True;
  Thread1:=TThreadUnit.Create(False);
  miStartClick(nil);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //don't show the form, only the tray icon
end;

procedure TForm1.miExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.miStartClick(Sender: TObject);
begin
  if miStart.Checked then Exit;
  miStart.Checked:=True;
  miStop.Checked:=False;
  Thread1.Active:=True;
  Memo1.Append('Thread Started');
end;

procedure TForm1.miStopClick(Sender: TObject);
begin
  if miStop.Checked then Exit;
  miStart.Checked:=False;
  miStop.Checked:=True;
  Thread1.Active:=False;
  Memo1.Append('Thread Stopped');
end;

procedure TForm1.miShowClick(Sender: TObject);
begin
  Form1.Show;
end;


procedure TForm1.TrayIconClick(Sender: TObject);
begin
  Form1.Show;
end;

end.

