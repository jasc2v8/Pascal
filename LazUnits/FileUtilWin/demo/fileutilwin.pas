unit fileutilwin;

{ FileUtilWin Version 1.0.0 Copyright (C) 2018 by James O. Dreher

  License: https://opensource.org/licenses/MIT

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazFileUtils;

function ChildPath(aPath: string): string;
function ParentPath(aPath: string): string;
function JoinPath(aDir, aFile: string): string;

function CopyDirWin(sourceDir, targetDir: string): boolean;
function CopyFileWin(sourcePath, targetPath: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

function DelDirWin(targetDir: string; OnlyChildren: boolean=False): boolean;
function DelFileWin(targetFile: string): boolean;

function FilenameIsDir(aPath: string): boolean;
function FilenameIsFile(aPath: string): boolean;

const
  DS=DirectorySeparator;
  LE=LineEnding;
implementation

function FilenameIsDir(aPath: string): boolean;
begin
  Result:=False;
  if ExtractFileName(aPath)='' then
    Result:=True;
end;
function FileNameIsFile(aPath: string): boolean;
begin
  Result:=True;
  if ExtractFileName(aPath)='' then
    Result:=False;
end;
function ChildPath(aPath: string): string;
begin
  aPath:=ExpandFileName(ChompPathDelim(aPath));
  Result:=Copy(aPath,aPath.LastIndexOf(DS)+2)
end;
function ParentPath(aPath: string): string;
begin
  Result:=ExpandFileName(IncludeTrailingPathDelimiter(aPath) + '..');
end;
function JoinPath(aDir, aFile: string): string;
begin
  Result:=CleanAndExpandDirectory(aDir)+Trim(aFile);
end;
function CopyDirWin(sourceDir, targetDir: string): boolean;
var
  FileInfo: TSearchRec;
  sourceFile, targetFile: String;
begin
  Result:=false;
  sourceDir:=CleanAndExpandDirectory(sourceDir);
  targetDir:=CleanAndExpandDirectory(targetDir);
  if FindFirstUTF8(sourceDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if not ForceDirectories(targetDir) then exit;
          if not CopyDirWin(sourceFile, targetFile) then exit;
        end else begin
          if not CopyFileWin(sourceFile, targetFile) then
            exit;
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  Result:=true;
end;
function CopyFileWin(sourcePath, targetPath: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;
var
  attrSource, attrTarget: integer;
  targetDir: string;
begin
  Result:=false;
  sourcePath:=CleanAndExpandFilename(sourcePath);
  targetPath:=CleanAndExpandFilename(targetPath);

  if FilenameIsDir(targetPath) then begin
    targetDir:=targetPath;
    targetPath:=targetDir+ExtractFileName(sourcePath);
  end else begin
    targetDir:=ExtractFilePath(targetPath);
  end;

  if not ForceDirectories(targetDir) then
    exit;

  if PreserveAttributes then
    attrSource:=FileGetAttrUTF8(sourcePath);

  if cffOverwriteFile in Flags then begin
    if FileExists(targetPath) then begin
      attrTarget:=FileGetAttrUTF8(targetPath);
      if (attrTarget and faReadOnly)>0 then
        FileSetAttrUTF8(targetPath, attrTarget-faReadOnly)
      else if (attrTarget and faHidden)>0 then
        FileSetAttrUTF8(targetPath, attrTarget-faHidden);
    end;
  end;

  if not FileUtil.CopyFile(sourcePath, targetPath, Flags) then
    exit;

  if PreserveAttributes then
    FileSetAttrUTF8(targetPath, attrSource);

  Result:=true;
end;
function DelDirWin(targetDir: string; OnlyChildren: boolean=False): boolean;
var
  FileInfo: TSearchRec;
  targetFile: String;
begin
  Result:=false;
  if not DirectoryExistsUTF8(targetDir) then exit;
  targetDir:=CleanAndExpandDirectory(targetDir);
  if FindFirstUTF8(targetDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if not DelDirWin(targetFile, false) then exit;
        end else begin
          if (FileInfo.Attr and faReadOnly)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faReadOnly);
          if not DeleteFileUTF8(targetFile) then exit;
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  if (not OnlyChildren) and (not RemoveDirUTF8(targetDir)) then exit;
  Result:=true;
end;
function DelFileWin(targetFile: string): boolean;
begin
  Result:=DeleteFileUTF8(targetFile);
end;

end.

