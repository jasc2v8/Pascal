{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org>}

unit httpserverunit;

{$mode objfpc}{$H+}

interface

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  SysUtils, Classes, EventLog,
  //Indy10.6.2.5494 (Laz Menu: Package, open indylaz_runtime.lpk, Use, Add to Project)
  IdBaseComponent, IdComponent, IdContext,IdSocketHandle, IdGlobal, IdGlobalProtocols,
  IdAssignedNumbers, IdCustomHTTPServer, IdHTTPServer;

type

   { TServerThread }
   TServerThread = class(TThread)
     FLogFile: string;
     FIP: string;
     FPort: integer;
     FHome: string;
     procedure Execute; override;
   end;

   { TServer }
   TServer = Class(TIdHTTPServer)
     public
     LogFile: string;
     Home: string;
     procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
   end;

var
  Log: TEventLog;
  Server: TServer;

implementation

procedure WriteLog(const ET: TEventType; const msg: string);
begin
  Log.Active:=True; //open log file
  Log.Log(ET, msg);
  Log.Active:=False; //close log file to unlock it
end;

{ TServerThread }

procedure TServerThread.Execute;
var
  Binding: TIdSocketHandle;

begin

  try
    Server:=TServer.Create(nil);
    with Server do begin;
      OnCommandGet    := @ServerCommandGet;
      Scheduler       := nil; //use default thread scheduler
      MaxConnections  := 5;
      Home            := FHome;
      LogFile         := FLogFile;
    end;

    Log:=TEventLog.Create(nil);
    with Log do begin
      LogType := ltFile;
      Filename:=Server.LogFile; //default dir is C:\Windows\SysWOW64
      DefaultEventType := etDebug;
      AppendContent := True;
      Active:=false;
    end;

    Server.Bindings.Clear;
    Binding := Server.Bindings.Add;
    Binding.IP := FIP;
    Binding.Port := FPort;

    Server.Active := true;
    WriteLog(etInfo, 'Server Started');

    repeat
      Sleep(1000);
    until not true;

  finally
    Server.Free;
  end;
end;

{ TServer }

procedure TServer.ServerCommandGet(AContext: TIdContext;
            ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LocalDoc: string;

begin
  LocalDoc:=ARequestInfo.URI;
  If (Length(LocalDoc)>0) and (LocalDoc[1]='/') then Delete(LocalDoc,1,1);
  if LocalDoc='' then
    LocalDoc:=HOME + 'index.html'
  else
    LocalDoc:=HOME + LocalDoc;
  DoDirSeparators(LocalDoc); //fix back and forward slashes

  WriteLog(etDebug, 'LocalDoc=' + LocalDoc);

  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := MimeTable.GetFileMIMEType(LocalDoc);
  AResponseInfo.ContentStream := TFileStream.Create(LocalDoc, fmOpenRead + fmShareDenyWrite);
end;


end.
