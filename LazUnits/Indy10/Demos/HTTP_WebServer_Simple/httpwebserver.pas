{DEPENDENCY: indylaz_runtime, see readme.txt}

unit httpwebserver;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, EventLog, LCLIntf,
  //Indy10.6.2.5494
  IdBaseComponent, IdComponent, IdContext,IdSocketHandle, IdGlobal, IdGlobalProtocols,
  IdCustomHTTPServer, IdHTTPServer;

type

  THTTPWebServer = object
  private
    FLogFile: string;
    FServerActive: boolean;
    MimeTable: TIdMimeTable;
    Server: TIdHTTPServer;
    Log: TEventLog;
    function GetMimeType(aFile: String): String;
    procedure FreeObjects;
    procedure ServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: String);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure ServerConnect(AContext: TIdContext);
    procedure ServerDisconnect(AContext: TIdContext);
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  protected
  public
    property LogFile: string read FLogFile write FLogFile;
    property ServerActive: boolean read FServerActive write FServerActive;
    procedure Start;
    procedure Stop;
  end;

const
  GIP='127.0.0.1';    //todo: create properties: Server.IP, .Port, .DocumentRoot
  GPORT='80';
  GROOT='.\HOME';
  GLOG='';
  VERBOSE=false;      //verbose = log client connect/disconnect messages

implementation

procedure THTTPWebServer.Start;
var
  Binding: TIdSocketHandle;
  msg: string;
begin

  if ServerActive then Exit;

  MimeTable:=TIdMimeTable.Create(true); //load from system OS

  if LogFile='' then LogFile:='default.log';

  Log:=TEventLog.Create(nil);
  Log.FileName:= LogFile;
  Log.LogType := ltFile;  //ltSystem;
  Log.Active  := true;

  Server:=TIdHTTPServer.Create;

  with Server do begin;
    OnStatus        := @ServerStatus;
    OnConnect       := @ServerConnect;
    OnDisconnect    := @ServerDisconnect;
    OnException     := @ServerException;
    OnCommandGet    := @ServerCommandGet;
    Scheduler       := nil; //use default Thread Scheduler
    MaxConnections  := 10;
    KeepAlive       := True;
  end;

  Server.Bindings.Clear;

  try
    Server.DefaultPort := StrToInt(GPORT);
    Binding := Server.Bindings.Add;
    Binding.IP := GIP;
    Binding.Port := StrToInt(GPORT);

    Server.Active := true;
    ServerActive  := Server.Active;

    Log.Info('Server Start');
    Log.Info('Bound to: ' + GIP + ' on port ' + GPORT);
    Log.Info('Doc Root: ' + GROOT);
    Log.Info('Log File: ' + LogFile);

    //verify default scheduler active: Log.Debug('ImplicitScheduler='+BoolToStr(Server.ImplicitScheduler,true));

  except
    on E : Exception do begin
      Log.Error('Server not started');
      Log.Error(E.Message);
      FreeObjects;
    end;
  end;
end;

procedure THTTPWebServer.Stop;
begin

  if not ServerActive then Exit;

  Server.Active := false;
  ServerActive  := Server.Active;

  Server.Bindings.Clear;

  Log.Info('Server stop');

  FreeObjects;

end;

procedure THTTPWebServer.ServerStatus(ASender: TObject; const AStatus: TIdStatus;
            const AStatusText: String);
begin
  Log.Info('Status: '+AStatusText);
end;

procedure THTTPWebServer.ServerException(AContext: TIdContext; AException: Exception);
begin
  Log.Warning('Exception: ' + AException.Message);
end;

procedure THTTPWebServer.ServerConnect(AContext: TIdContext);
begin
  if VERBOSE then Log.Info('Client Connect ip: ' + AContext.Connection.Socket.Binding.PeerIP);
end;

procedure THTTPWebServer.ServerDisconnect(AContext: TIdContext);
begin
  if VERBOSE then Log.Info('Client Disconnect ip: ' + AContext.Connection.Socket.Binding.PeerIP);
end;

function THTTPWebServer.GetMimeType(aFile: String): String;
begin
  Result := MimeTable.GetFileMimeType(aFile)
end;

procedure THTTPWebServer.FreeObjects;
begin
  Server.Free;
  MimeTable.Free;
  Log.Free;
end;

procedure THTTPWebServer.ServerCommandGet(AContext: TIdContext;
            ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LocalDoc : String;
begin
  LocalDoc:=ARequestInfo.Document;

  //Log.Debug('ARequestInfo.Document=[' + ARequestInfo.Document + ']');

  If (Length(LocalDoc)>0) and (LocalDoc[1]='/') then Delete(LocalDoc,1,1);
  If (Length(LocalDoc)=0) then LocalDoc:='index.html';
  LocalDoc:=IncludeTrailingPathDelimiter(GROOT)+LocalDoc;
  DoDirSeparators(LocalDoc);

  Log.Debug('Serving: ' + LocalDoc + ' to ' + ARequestInfo.Host);

  if ARequestInfo.Command='POST' then begin
    Log.Debug('Command=' + ARequestInfo.Command + LineEnding +
    'Params='+ARequestInfo.Params.Text + LineEnding +
    'UnparsedParams='+ARequestInfo.UnparsedParams);
    LocalDoc := IncludeTrailingPathDelimiter(GROOT) + 'welcome.html';
  end;

  if FileExists(LocalDoc) then begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := GetMimeType(LocalDoc);
    AResponseInfo.ContentStream := TFileStream.Create(LocalDoc, fmOpenRead + fmShareDenyWrite);
  end else begin
    AResponseInfo.ResponseNo := 404; // Not found
    AResponseInfo.ContentText := '';
  end;
end;
end.
