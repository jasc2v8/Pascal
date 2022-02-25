unit MyServer;

{$mode objfpc}{$H+}

interface
uses
 IdHTTPServer, IdCustomHTTPServer, IdContext, IdSocketHandle, IdGlobal,
 IdSSL, IdSSLOpenSSL, IdSSLOpenSSLHeaders,
 SysUtils, EventLog;

type

  { THTTPServer }

  THTTPServer = class (TIdHTTPServer)
  public
    procedure InitComponent; override;
    procedure OnGet(AContext: TIdContext;ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure OpenSSLGetPassword(var Password: String);
    procedure OpenSSLStatusInfo(const AMsg: String);
  end;

var
  Log: TEventLog = nil;
  OpenSSL: TIdServerIOHandlerSSLOpenSSL = nil;

implementation

{ THTTPServer }

procedure THTTPServer.InitComponent;
var
  Binding: TIdSocketHandle;
begin
  {$IFDEF USE_ICONV}
    IdGlobal.GIdIconvUseTransliteration := True;
  {$ENDIF}

  inherited; //InitComponent;

  Log := TEventLog.Create(nil);
  Log.LogType := ltFile;
  Log.FileName := 'server.log';

  OpenSSL:=TIdServerIOHandlerSSLOpenSSL.Create;

  with OpenSSL do begin
    SSLOptions.SSLVersions := [sslvTLSv1_2];
    OnGetPassword := @OpenSSLGetPassword;
    OnStatusInfo  := @OpenSSLStatusInfo;
  end;

  Bindings.Clear;
  Binding := Bindings.Add;
  Binding.IP := '127.0.0.1';
  Binding.Port := 443;
  Binding.IPVersion := Id_IPv4;

  with OpenSSL.SSLOptions do begin
    CertFile      := 'DEMO_Server.crt.pem';
    KeyFile       := 'DEMO_Server.key.pem';
    RootCertFile  := 'DEMO_RootCA.crt.pem';
    CipherList    := 'TLSv1.2:!NULL';
  end;

  OnCommandGet := @OnGet;
  OnException  := @ServerException;
  IOHandler    := OpenSSL;

  Log.Info('Server Started on IP '+Binding.IP+' Port '+Binding.Port.ToString);

end;

procedure THTTPServer.OnGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ContentText := 'Hello world!';
end;

procedure THTTPServer.ServerException(AContext: TIdContext;
  AException: Exception);
begin
  Log.Warning('EXCEPTION: ' + AException.Message);
end;

procedure THTTPServer.OpenSSLGetPassword(var Password: String);
begin
  Password := 'demo';
end;

procedure THTTPServer.OpenSSLStatusInfo(const AMsg: String);
begin
  Log.Debug('SSL STATUS: ' + aMsg);
end;

FINALIZATION
  if Assigned(OpenSSL) then OpenSSL.Free;
  if Assigned(Log) then Log.Free;

end.

