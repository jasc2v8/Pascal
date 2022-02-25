unit StringExchangeClientUnit1;

{$MODE Delphi}

{

    03.07.2019
    Updated for Indy 10.6 by jasc2v8@yahoo.com 3/7/2019
    Replaced: TIdTextEncoding.Default
    With:     IndyTextEncoding_OSDefault

    03.03.2012
    String Exchange Client Demo
    It just shows how to send and receive String.
    No error handling
    Most of the code is bdlm's.
    Adnan, Email: helloy72@yahoo.com

    HINT : define different ouputfolder for x32 and x64 compiled *.exe's
    outPutFolder C:\12_SourceForgeCode\indy10\buildx32\
    outPutFolder C:\12_SourceForgeCode\indy10\buildx64\

}

interface

uses
  SysUtils, Classes, Forms, Dialogs, StdCtrls,
  //Indy10.6.2.5494 (Laz Menu: Package, open indylaz_runtime.lpk, Use, Add to Project)
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal;

type

  { TClientForm }

  TClientForm = class(TForm)
    CheckBoxConnectDisconnet: TCheckBox;
    ButtonSendString: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    IdTCPClient1: TIdTCPClient;
    procedure CheckBoxConnectDisconnetClick(Sender: TObject);
    procedure ButtonSendStringClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ClientForm: TClientForm;

implementation

{$R *.lfm}

{ TForm1 }

procedure TClientForm.ButtonSendStringClick(Sender: TObject);
var
  LLine: String;
begin

  IF CheckBoxConnectDisconnet.Checked then begin
    IdTCPClient1.IOHandler.WriteLn(Edit1.Text, IndyTextEncoding_OSDefault);
    //personal preference Edit1.Text := '';
    LLine := IdTCPClient1.IOHandler.ReadLn();
    if ( LLine = 'OK' ) then
        Memo1.Lines.Add('Server says it has received your String');
  end else
    Memo1.Lines.Add('Client is not connected to Server');


end;

procedure TClientForm.FormCreate(Sender: TObject);
begin
  IdTCPClient1:=TIdTCPClient.Create;
  with IdTCPClient1 do begin
    OnDisconnected := IdTCPClient1Disconnected;
    OnConnected := IdTCPClient1Connected;
    ConnectTimeout := 0;
    IPVersion := Id_IPv4;
    Port := 0;
    ReadTimeout := -1;
  end
end;

procedure TClientForm.CheckBoxConnectDisconnetClick(Sender: TObject);
begin
  if ( CheckBoxConnectDisconnet.Checked = True ) then
  begin
    IdTCPClient1.Host := '127.0.0.1';
    IdTCPClient1.Port := 6000;
    IdTCPClient1.Connect;
  end
  else
    IdTCPClient1.Disconnect;
end;

procedure TClientForm.IdTCPClient1Connected(Sender: TObject);
begin
  Memo1.Lines.Add('Client connected with server');
end;

procedure TClientForm.IdTCPClient1Disconnected(Sender: TObject);
begin
  Memo1.Lines.Add('Client disconnected from server');
end;

end.
