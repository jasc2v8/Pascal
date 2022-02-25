unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, DebugUnit;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOK: TButton;
    Memo1: TMemo;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonOKClick(Sender: TObject);
begin

end;
procedure TForm1.FormShow(Sender: TObject);
begin
DebugForm.Show;
Debugln('Ready');
end;
end.

