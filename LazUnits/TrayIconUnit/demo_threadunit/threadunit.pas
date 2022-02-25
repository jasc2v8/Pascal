{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org> }

unit threadunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TThreadUnit }

  TThreadUnit = class(TThread)
  private
    FActive: boolean;
    FStatus: string;
    FName: string;
    procedure Update;
    procedure OnTerminate;
  protected
    procedure Execute; override;
  public
    property Active: boolean Read FActive Write FActive;
    property Status: string Read FStatus Write FStatus;
    property Name: string Read FName Write FName;
    constructor Create(CreateSuspended: Boolean);
  end;

implementation

uses Unit1;

{ TThreadUnit }

procedure TThreadUnit.OnTerminate;
begin
  Form1.Memo1.Append('Terminate : '+Name);
end;
procedure TThreadUnit.Update;
begin
  Form1.Memo1.Append(Status);
end;
procedure TThreadUnit.Execute;
var
  i: integer;
begin

  { simulate some work }

  while true do begin
    if Terminated then break;
    Sleep(Random(500)+500);
    Status:=Name+' count: '+i.ToString;

    if FActive then begin
      Inc(i);
      Synchronize(@Update);
    end;

  end;

  Synchronize(@OnTerminate);

end;
constructor TThreadUnit.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FActive:=True;
  FreeOnTerminate:=True;
end;

end.

