program StringExchangeClient;

{$MODE Delphi}

uses
  Forms, Interfaces,
  Unit1 in 'Unit1.pas' {ClientForm};

{$R *.res}

begin
  Application.Initialize;
  //personal preference Application.MainFormOnTaskbar := True;
  Application.CreateForm(TClientForm, ClientForm);
  Application.Run;
end.
