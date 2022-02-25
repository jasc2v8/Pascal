program StringExchangeServer;

{$MODE Delphi}

uses
  Forms, Interfaces,
  StringExchangeServerUnit1 in 'Unit1.pas' {StringServerForm};

{$R *.res}

begin
  Application.Initialize;
  //personal preference Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStringServerForm, StringServerForm);
  Application.Run;
end.
