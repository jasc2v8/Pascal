{ dependency: pl_indy
  Edit copy_demo_files.cmd before compiling
  Run this demo and note the tray icon to open log or exit
  Browse to http://localhost
  Demo will reply with "Hello world!"
}

unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, lclintf, MyServer;

type

  { TForm1 }

  TForm1 = class(TForm)
    miExit: TMenuItem;
    miOpenLog: TMenuItem;
    pmMain: TPopupMenu;
    TrayIcon: TTrayIcon;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miOpenLogClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Server : THTTPServer;
  end;

const
  LogFile = 'server.log';
var
  Form1: TForm1;

implementation

{$R *.frm}

{ TForm1 }

procedure TForm1.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.miOpenLogClick(Sender: TObject);
begin
  if FileExists(LogFile) then OpenDocument(LogFile);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Server := THTTPServer.Create(nil);
  Server.Active := True;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Server.Free;
end;

end.

