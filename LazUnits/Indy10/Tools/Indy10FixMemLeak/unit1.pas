unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn,
  LazFileUtils //CleanAndExpandDirectory
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonStart: TButton;
    DirectoryEdit: TDirectoryEdit;
    Memo1: TMemo;
    procedure ButtonStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FindFilesRecursive(aPath: string);
  private
    fileCount : Longint;
  public

  end;

const
  ROOTDIR='C:\lazarus\packages\Indy10';
  OLD_PATTERN_1 = '{.$DEFINE FREE_ON_FINAL}';
  NEW_PATTERN_1 = '{$DEFINE FREE_ON_FINAL}';
  OLD_PATTERN_2 = '{$UNDEF FREE_ON_FINAL}';
  NEW_PATTERN_2 = '{.$UNDEF FREE_ON_FINAL}';

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure DoEdit(sourceFile: string);
var
  aList: TStringList;
  s: string;
begin
  aList:=TStringList.Create;
  CopyFile(sourceFile, sourceFile + '.original');
  try
    aList.LoadFromFile(sourceFile);
    s := aList.Text;
    s := StringReplace(s, OLD_PATTERN_1, NEW_PATTERN_1, [rfReplaceAll]);
    s := StringReplace(s, OLD_PATTERN_2, NEW_PATTERN_2, [rfReplaceAll]);
    aList.Text := s;
    aList.SaveToFile(sourceFile);
  finally
    aList.Free;
  end;
end;

procedure TForm1.FindFilesRecursive(aPath: string);
var
  Info: TSearchRec;
  sourceFile: String;
begin
  aPath:=CleanAndExpandDirectory(aPath);

  If FindFirst(aPath+GetAllFilesMask, faAnyFile, Info)=0 then begin
    repeat
      with Info do begin
        if (Name<>'.') and (Name<>'..') and (Name<>'') then begin
          If (Attr and faDirectory) >0 then begin
            sourceFile:=ExtractFilePath(aPath)+Name;
            FindFilesRecursive(sourceFile);
          end else begin
            sourceFile:=ExtractFilePath(aPath)+Name;
            if Name = 'IdCompilerDefines.inc' then begin
              Memo1.Append(sourceFile);
              DoEdit(sourceFile);
              Inc(fileCount);
            end;
          end;
        end;
      end;
    until FindNext(info)<>0;
  end;
  FindClose(Info);
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
var
  aPath: string;

begin
  fileCount:=0;
  Memo1.Clear;

  aPath:=DirectoryEdit.Text;

  FindFilesRecursive(aPath);

  Memo1.Append(Format('Total Files Edited: %d Files',[fileCount]));

end;

procedure TForm1.FormShow(Sender: TObject);
begin
  DirectoryEdit.Text:=ROOTDIR;
end;

end.

