
unit sslClient10Main;

{$MODE Delphi}

interface

{ SIMPLE INDY 10 SSL CLIENT

  Written by Ralph Sickinger, Best Manufacturing Practices Center of Excellence (BMPCOE)

  e-mail: ralph@bmpcoe.org
  
  This program is a simply TCP Client that makes an SSL connection on port 3000.  To connect
  to a server, enter the IP address of the server in the box labeled "Host:", and then press
  the "Connect" button.  Once a connection has been established, the client displays any text
  received from the server in the memo area.  To send text to the server, enter it in the
  available edit box, and then press [enter].

  Note: in order to run this program, you must have libeay32.dll and ssleay32.dll installed where the
        application can find them  (either in the Windows System32 folder, or in the same folder as the
        application itself.  These files can be downloaded from:  http://indy.fulgan.com/SSL/

  Changes from Indy 9:

  * In order to compile the application, you'll have to add the Indy 10 source folders to
    the Project/Options/Directories-Conditionals/Search Path;
    e.g: C:\Indy10\Lib\Core;C:\Indy10\Lib\System;C:\Indy10\Lib\Protocols

  * All instances of IdTCPClient.ReadLn (or WriteLn) must be changed to IdTCPClient.IOHandler.ReadLn

}

uses
  SysUtils, Classes, Graphics, Forms, StdCtrls, ExtCtrls, Buttons,
  //Indy10.6.2.5494 (Laz Menu: Package, open indylaz_runtime.lpk, Use, Add to Project)
  IdIOHandler, IdIOHandlerSocket, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdIOHandlerStack, IdGlobal,
  //OpenSSL-1.0.2l-i386-win32 (libeay32.dll and ssleay32.dll)
  IdSSL, IdSSLOpenSSL;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ledConnected: TShape;
    btnConnect: TButton;
    edtHostAddr: TEdit;
    Label1: TLabel;
    Panel2: TPanel;
    Edit1: TEdit;
    Panel3: TPanel;
    Memo1: TMemo;
    btnExit: TSpeedButton;
    IdTCPClient: TIdTCPClient;
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    procedure btnConnectClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end; { TForm1 }

var
  Form1: TForm1;

{===================================================================================}
{===================================================================================}

implementation

{$R *.lfm}

{===================================================================================}

procedure TForm1.FormCreate(Sender: TObject);
begin
  left:= 80;
  top:= 540; //80

  IdSSLIOHandlerSocketOpenSSL:=TIdSSLIOHandlerSocketOpenSSL.Create;
  With IdSSLIOHandlerSocketOpenSSL do begin
    Destination := ':3000';
    MaxLineAction := maException;
    Port := 3000;
    DefaultPort := 0;
    SSLOptions.Method := sslvTLSv1;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 0;
    //Left = 344
    //Top = 8
  end;

  IdTCPClient:= TIdTCPClient.Create;
  With IdTCPClient do begin
    IOHandler := IdSSLIOHandlerSocketOpenSSL;
    ConnectTimeout := 0;
    IPVersion := Id_IPv4;
    Port := 3000;
    ReadTimeout := 0;
    //Left = 304
    //Top = 8
  end;

end; { FORM CREATE }

{===================================================================================}

procedure TForm1.btnConnectClick(Sender: TObject);
var
  line: string;
begin
  btnConnect.enabled:= false;
  IdTCPClient.Host:= edtHostAddr.text;
  try
    IdTCPClient.Connect;
    ledConnected.brush.color:= clLime;
    edit1.SetFocus;
  except
    btnConnect.Enabled:= true;
  end; { try/except }

  try
    line:= IdTCPClient.IOHandler.ReadLn;
    memo1.lines.add(line);
  except
    btnConnect.enabled:= true;
  end; { try/except }

  if btnConnect.Enabled then ledConnected.brush.color:= clRed;

end; { BTN CONNECT CLICK }

{===================================================================================}

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  line: string;
begin
  if (key = #13) then begin
    key:=#0;
    try
      IdTCPClient.IOHandler.writeln(edit1.text);   { Send the text to the server }
      edit1.text:= '';

      line:= IdTCPClient.IOHandler.ReadLn;         { Now wait for the server's response }
      memo1.lines.add(line);
    except
      btnConnect.enabled:= true;
      ledConnected.brush.color:= clRed;
    end; { try/except }
  end; { if (key = #13) }

end; { EDIT1 KEY PRESS }

{===================================================================================}

procedure TForm1.btnExitClick(Sender: TObject);
begin
  close;
end; { BTN EXIT CLICK }

{===================================================================================}
{===================================================================================}

end. {*}

