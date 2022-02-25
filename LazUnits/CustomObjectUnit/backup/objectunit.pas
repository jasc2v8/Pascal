
unit customobject;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes;

type

  TCustomObject = object
  private
  protected
  public
    procedure Start;
    procedure Stop;
  published
  end;

implementation

uses unit1;  //to access Form1.Memo1

procedure TCustomObject.Start;
begin
  Form1.Memo1.Append('Object Start!');
  //create objects
end;

procedure TCustomObject.Stop;
begin
  Form1.Memo1.Append('Object STOP!');
  //free objects
end;

end.
