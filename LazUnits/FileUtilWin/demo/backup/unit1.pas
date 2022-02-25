unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, FileUtilWin;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonCopyDir: TButton;
    ButtonClear: TButton;
    ButtonCopyFile: TButton;
    DirEditSource: TDirectoryEdit;
    DirEditTarget: TDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonCopyDirClick(Sender: TObject);
    procedure ButtonCopyFileClick(Sender: TObject);
    procedure MemoLn(aLine: string);
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

procedure TForm1.MemoLn(aLine: string);
begin
  Memo1.Append(aLine);
end;

procedure TForm1.ButtonCopyFileClick(Sender: TObject);
var
  r: boolean;
  aSource, aTarget: string;
  sDir, sMask, tDir: string;
begin
  aSource:='D:\DEV\Work\pascal\pCopy\pCopy.lpr';
  aTarget:='E:\TEMP\CopyDir\pCopy\test.tmp';
  //ok aTarget:='E:\TEMP\test.tmp';
  //if ExtractFileName().IsEmpty then folder else file

  //aTarget:='E:\TEMP\backup\';

  {
  if FilenameIsDir(aTarget) then Debugln('is folder name');
  if FilenameIsFile(aTarget) then Debugln('is file name');

  Debugln('aSource='+aSource);
  Debugln('aTarget='+aTarget);
  Debugln('ExtractFileDir   =['+ExtractFileDir(aTarget)+']');
  Debugln('ExtractFilePath  =['+ExtractFilePath(aTarget)+']');
  Debugln('ExtractFileName  =['+ExtractFileName(aTarget)+']');
  Debugln('ExtractFileExt   =['+ExtractFileExt(aTarget)+']');
}
  if DirEditSource.Text<>'' then
    aSource:=DirEditSource.Text;

  if DirEditTarget.Text<>'' then
    aTarget:=DirEditTarget.Text;

  MemoLn('Copy '+aSource+' to '+aTarget);

  r:=CopyFileWin(aSource, aTarget);
  if not r then Memoln('COPY File ERROR');

  MemoLn('END');

  MemoLn('');

end;

procedure TForm1.ButtonClearClick(Sender: TObject);
var
  r: boolean;
begin
  //DirEditSource.Clear;
  //DirEditTarget.Clear;
  Memo1.Clear;

  r:=DelDirWin('e:\temp',true);
  if not r then Memoln('DelDir ERROR e:\temp') else Memoln('DelDir Success');
end;

procedure TForm1.ButtonCopyDirClick(Sender: TObject);
var
  r: boolean;
  aSource, aTarget: string;
  sDir, sMask, tDir: string;
begin
  aSource:='fileutilwin.pas';
  aTarget:='E:\TEMP\';

  if DirEditSource.Text<>'' then
    aSource:=DirEditSource.Text;

  if DirEditTarget.Text<>'' then
    aTarget:=DirEditTarget.Text;

  MemoLn('Copy '+aSource+' to '+aTarget);

  r:=CopyDirWin(aSource, aTarget);
  if not r then Memoln('COPY Dir ERROR');

  MemoLn('END CopyDir'+LE);

end;

end.
