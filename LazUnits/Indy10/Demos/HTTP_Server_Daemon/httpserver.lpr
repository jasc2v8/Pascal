{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org>}
{
Source: https://forum.lazarus.freepascal.org/index.php?topic=20274.0

  -i --install: register the daemon. This has no effect under unix.
  -u --uninstall: unregister the daemon. This has no effect under unix.
  -r --run: start the daemon on Unix. Windows does this normally itself.

How to use on Windows:

  1 Install the service from command line (run as admin): httpserver -i
    The service will auto start when Windows boots.

  2 Start the service:
    With Services.msc: 'start' menu inside the windows services manager
    Or CMD as Admin  : net start httpserver

  3 Stop the service:
    With Services.msc: 'stop' menu inside the windows services manager
    Or CMD as Admin  : net stop httpserver

  4 Uninstall the service from command line (run as admin): httpserver -u

  Close services.msc before issuing pause/continue/stop commands above

  If service won't stop then:
    >sc.exe queryex <SERVICE_NAME> (note the PID number)
    >taskkill /f /pid <SERVICE_PID>
    >DemoDaemon -u

  For Internet access, open a port for the service on the router and firewall.
}

program httpserver;

{$mode objfpc}{$H+}
{$apptype console}
{$define usecthreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes, SysUtils, EventLog, DaemonApp, httpserverunit;

type

  { TDemoDaemon }

  TDemoDaemon = class(TCustomDaemon)
  private
    FThread: TServerThread;
  public
    function Install: boolean; override;
    function Start : Boolean; override;
    function UnInstall: boolean; override;
    procedure WriteLog(const ET: TEventType; const msg: string);
  end;

{ TDemoDaemon }

function TDemoDaemon.Install: boolean;
begin
  Result := inherited Install;
  WriteLog(etInfo, 'Daemon.Install: ' + BoolToStr(Result, True));
end;

function TDemoDaemon.Start: Boolean;
begin
  Result:=inherited Start;

  {init server params, then start server thread}
  WriteLog(etInfo, 'Daemon.Start: ' + BoolToStr(result,true));
  FThread:=TServerThread.Create(True);
  with FThread do begin
    FLogFile:=ChangeFileExt(ParamStr(0), '.log');
    FIP:='127.0.0.1';
    FPort:=80;
    FHome:=ExtractFilePath(Application.ExeName)+'HOME\';
    FreeOnTerminate:=true;
    Start;
  end;
end;

function TDemoDaemon.UnInstall: boolean;
begin
  Result := inherited UnInstall;
  WriteLog(etInfo, 'Daemon.Uninstall: ' + BoolToStr(Result, True));
end;

procedure TDemoDaemon.WriteLog(const ET: TEventType; const msg: string);
var
  Log: TEventLog;
begin
  {open, write, then close the log file to unlock it}
  Log:=TEventLog.Create(nil);
  try
    with Log do begin
      LogType := ltFile;
      DefaultEventType := etDebug;
      AppendContent := True;
      FileName := ChangeFileExt(ParamStr(0), '.log');
      Active:=true;
    end;
    Log.Log(ET, msg);
    Log.Active:=False; //close log file to unlock it
  finally
    FreeAndNil(Log);
  end;
end;

{ TDemoDaemonMapper }

type
  TDemoDaemonMapper = class(TCustomDaemonMapper)
    constructor Create(AOwner: TComponent); override;
  end;

constructor TDemoDaemonMapper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with DaemonDefs.Add as TDaemonDef do
  begin
    DaemonClassName := 'TDemoDaemon';
    Name            := 'HTTPServer';
    DisplayName     := 'HTTP Server Demo';
    WinBindings.ServiceType := stWin32;
    WinBindings.StartType   := stAuto;
  end;
end;

{$R *.res}

begin
  RegisterDaemonClass(TDemoDaemon);
  RegisterDaemonMapper(TDemoDaemonMapper);
  with Application do begin
    Title := 'HTTP Server Demo';
    Initialize;
    Run;
  end;
end.
