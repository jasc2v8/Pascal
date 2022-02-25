unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CustomObject;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStartStop: TButton;
    Memo1: TMemo;
    procedure btnStartStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  MyObject: TCustomObject;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnStartStopClick(Sender: TObject);
begin

  if btnStartStop.Caption='Start' then begin
    Memo1.Append('Start');
    btnStartStop.Caption:='STOP';
    MyObject.Start;
  end else begin
    Memo1.Append('STOP');
    btnStartStop.Caption:='Start';
    MyObject.Stop;
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Memo1.Append('FormClose');
  //Application.ProcessMessages;
  Sleep(1000);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Exit; //disable
  Memo1.Append('FormClose');
  CanClose:=true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Exit; //disable
  Memo1.Append('FormDestroy');
  Application.ProcessMessages;
  Sleep(3000);
end;

begin
  //your code upon start
end.

