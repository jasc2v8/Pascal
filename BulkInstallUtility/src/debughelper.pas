unit debugHelper;

{$mode objfpc}{$H+}

{
DebugForm.Append('Start');
DebugForm.Append('%s', 'test=');
DebugForm.Append('%s=%d', 'test=', 69);
DebugForm.Append('%s=%s', 'true', true);
DebugForm.Append('%s=%s', 'false', false);
DebugForm.Append('%s=%d', 'true', Integer(true));
DebugForm.Append('%s=%d', 'false', Integer(false));  
}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  { TDebugForm }

  TDebugForm = class(TForm)
    Memo: TMemo;
    ButtonClear: TButton;
    procedure ButtonClearClick(Sender: TObject);
    procedure Append(sText: string);
    procedure Append(sFormat:string; sText: string);
    procedure Append(sFormat:string; sText: string; iNumber: integer); 
    procedure Append(sFormat:string; sText: string; bFlag: boolean);
    procedure Append(sFormat:string; iNumber: integer);
  private

  public
   
  end;

var
  DEBUG: TDebugForm;

implementation

{$R *.lfm}

{ TDebugForm }

procedure TDebugForm.Append(sText: string);
begin
  Memo.Append(sText);
end;

procedure TDebugForm.Append(sFormat:string; sText: string);
begin
  sText:=Format(sFormat, [sText]);
  Memo.Append(sText);
end;

procedure TDebugForm.Append(sFormat:string; sText: string; iNumber: integer);
begin
  sText:=Format(sFormat, [sText,iNumber] );
  Memo.Append(sText);
end;

procedure TDebugForm.Append(sFormat:string; sText: string; bFlag: boolean);
var
  BOOL_TEXT: array[boolean] of string = ('False', 'True');
begin
  sText:=Format(sFormat, [sText,BOOL_TEXT[bFlag]] );
  Memo.Append(sText);
end;

procedure TDebugForm.Append(sFormat:string; iNumber: integer);
begin
  Memo.Append(Format(sFormat, [iNumber] ));
end;

procedure TDebugForm.ButtonClearClick(Sender: TObject);
begin
  Memo.Clear;
end;

end.

