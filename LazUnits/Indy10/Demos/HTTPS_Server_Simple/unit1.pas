{server icon from http://www.fasticon.com}

unit unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Controls, Forms, StdCtrls,
  LCLIntf, httpswebserver;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    btnStartStop: TButton;
    btnOpenLog: TButton;
    btnClearLog: TButton;
    procedure btnStartStopClick(Sender: TObject);
    procedure btnOpenLogClick(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    LogFile: string;
  protected
  public
  end;

var
  Form1 : TForm1;
  MyServer: THTTPWebServer;

implementation

{$R *.lfm}

procedure TForm1.btnStartStopClick(Sender: TObject);
begin
  if MyServer.ServerActive then begin
    MyServer.Stop;
    Memo1.Append('Server stopped');
    btnStartStop.Caption:='Start Server';
  end else begin
    LogFile:=GetCurrentDir + DirectorySeparator +
      ChangeFileExt(ExtractFileName(Application.ExeName),'.log');
    MyServer.LogFile:=LogFile;

    MyServer.Start;
    Memo1.Append('Server started');
    btnStartStop.Caption:=Uppercase('stop server');
  end;
end;

procedure TForm1.btnClearLogClick(Sender: TObject);
begin
  if FileExists(LogFile) then DeleteFile(LogFile);
  Memo1.Append('Log cleared');
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MyServer.Stop;
end;

procedure TForm1.btnOpenLogClick(Sender: TObject);
begin
  OpenDocument(LogFile);
end;

end.
