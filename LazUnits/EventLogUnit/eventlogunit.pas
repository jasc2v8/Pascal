{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org> }

{ Features:
  1. Log file is not locked, can be shared between units
  2. User can edit the log file while the program is running to make notes for debugging
  3. Log file is formatted for CSV input to sort very large log files
  4. Uses abbreviated event types ('DBG', 'ERR', 'INF', 'WRN')
  5. Log file fields are of uniform width (TIMESTAMP, TYPE, MESSAGE)
}

unit eventlogunit;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TEventType = (etDebug, etError, etInfo, etWarning);

  TEventLogCustom = class
  private
    FActive: boolean;
    FAppend: boolean;               //TODO - any use case to NOT append?
    FDefaultEventType: TEventType;
    FFileName: string;
    FLogSizeMax: int64;             //TODO
  public
    property Active: boolean read FActive write FActive;
    property FileName: string read FFileName write FFileName;
    constructor Create(LogFileName: string; LogActive: boolean = true); overload;
    //destructor Destroy; override;
    procedure Debug(const msg: string);
    procedure Error(const msg: string);
    procedure Info(const msg: string);
    procedure Warning(const msg: string);
    procedure Message(const et: TEventType; const msg: string);
    procedure Message(msg: string);
    procedure WriteLog(msg: string);
  published
  end;

const
  COMMA = ', ';
  EVENT_TYPES: array [TEventType] of string = ('DBG', 'ERR', 'INF', 'WRN');

implementation

function GetDateTime: string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

{TEventLogCustom}

constructor TEventLogCustom.Create(LogFileName: string; LogActive: boolean = true); overload;
begin
  inherited Create;
  Active:=LogActive;
  if LogFileName.IsEmpty then
    FileName := 'default.log'
  else
    FileName := LogFileName;
  FLogSizeMax:= 1024 * 1000;
  FDefaultEventType:= etDebug;
end;

{destructor TEventLogCustom.Destroy;
begin
  inherited Destroy;

end;
}
procedure TEventLogCustom.WriteLog(msg: string);
var
  f: TextFile;
  fBin: File;
  aNewName: string;
begin
  if not Active then Exit;
  AssignFile(f,FileName);
  FileMode:=fmOpenReadWrite;
  if FileExists(FileName) then
    Append(f)
  else
    Rewrite(f);
  WriteLn(f,msg);
  CloseFile(f);

  Exit;

  //TODO:
  AssignFile(fBin,FileName);
  aNewName:=ChangeFileExt(FileName,'.')+FormatDateTime('yyyymmddhhnnss',Now)+'.log';
  if FileSize(fBin) >= FLogSizeMax then
    Rename(fBin,aNewName);
end;

procedure TEventLogCustom.Debug(const msg: string);
begin
  Message(etDebug, msg);
end;

procedure TEventLogCustom.Error(const msg: string);
begin
  Message(etError, msg);
end;

procedure TEventLogCustom.Info(const msg: string);
begin
  Message(etInfo, msg);
end;

procedure TEventLogCustom.Warning(const msg: string);
begin
  Message(etWarning, msg);
end;

procedure TEventLogCustom.Message(const et: TEventType; const msg: string);
begin
  WriteLog(GetDateTime + COMMA + EVENT_TYPES[et] + COMMA + msg);
end;

procedure TEventLogCustom.Message(msg: string);
begin
  WriteLog(GetDateTime + COMMA + EVENT_TYPES[FDefaultEventType] + COMMA + msg);
end;

end.

