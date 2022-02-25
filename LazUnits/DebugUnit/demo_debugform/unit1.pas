unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, DebugUnit;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    ButtonStart: TButton;
    Memo1: TMemo;
    procedure btnClearClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonStartClick(Sender: TObject);
var
 i: integer;

begin

  Memo1.Clear;

  DebugForm.Show;
  DebugForm.Memo.Clear;

  Memo1.Append('Start Demo');

  for i:=1 to 10 do begin
    Debugln('Count: %d', [i]);
  end;

  Memo1.Append('End Demo');

end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //DebugForm.Show;
end;

end.

