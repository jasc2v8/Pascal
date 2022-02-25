unit jdfile;

{ Version 0.4 Copyright (C) 2018 by James O. Dreher

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
  Classes, SysUtils, FileUtil, LazFileUtils,
  jdDebug;

function ChildPath(aPath: string): string;
function ParentPath(aPath: string): string;
function JoinPath(aDir, aFile: string): string;

function CopyDir(sourceDir, targetDir: string): boolean;
function DelDir(targetDir: string; OnlyChildren: boolean=False): boolean;
function MoveDir(sourceDir, targetDir: string): boolean;

function CopyFile(sourceFile, targetFile: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

function CopyFiles(sourceDir, fileMask, targetDir: string;
            SearchSubDirs: boolean=true;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

function MoveFiles(sourceDir, fileMask, targetDir: string;
            SearchSubDirs: boolean=true;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

implementation

function ChildPath(aPath: string): string;
begin
  aPath:=ExpandFileName(ChompPathDelim(aPath));
  Result:=Copy(aPath,aPath.LastIndexOf(DirectorySeparator)+2)
end;
function ParentPath(aPath: string): string;
begin
  Result:=ExpandFileName(IncludeTrailingPathDelimiter(aPath) + '..');
end;
function JoinPath(aDir, aFile: string): string;
begin
  Result:=CleanAndExpandDirectory(aDir)+Trim(aFile);
end;
function CopyDir(sourceDir, targetDir: string): boolean;
{ copy directory tree, force directores, overwrite, and preserve attributes }
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
        { form source and target path }
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        { create dir path - will copy empty dir }
        if (FileInfo.Attr and faDirectory)>0 then begin
          if not ForceDirectories(targetFile) then exit;
          if not CopyDir(sourceFile, targetFile) then exit;
        end else begin
          { if file is hidden or readonly then remove attributes }
          if (FileInfo.Attr and faReadOnly)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faReadOnly)
          else if (FileInfo.Attr and faHidden)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faHidden);
          { create dir if not exists and copy file with overwrite }
          if not ForceDirectories(targetDir) then exit;
          if not FileUtil.CopyFile(sourceFile, targetFile, true) then exit;
          { copy file attributes from source }
          FileSetAttrUTF8(targetFile, FileInfo.Attr);
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  Result:=true;
end;

function CopyFile(sourceFile, targetFile: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;
{ copy a file and force dirs, Options: overwrite, preserve attributes }
var
  attr, attrSource: integer;
  sourceDir, targetDir: string;
  sourceFileName, targetFileName: string;
begin
  Result:=false;
  sourceFile:=CleanAndExpandFilename(sourceFile);
  targetFile:=CleanAndExpandFilename(targetFile);

  sourceFileName:=ExtractFileName(sourceFile);
  targetDir:=ExtractFileDir(targetFile);
  targetFile:=targetDir+DirectorySeparator+sourceFileName;

  if not ForceDirectories(targetDir) then begin
    DebugLn('');
    DebugLn('ERROR targetDir='+targetDir);
    DebugLn('');
    exit;
  end;

  if PreserveAttributes then begin
    attrSource:=FileGetAttrUTF8(sourceFile);
    if (attrSource and faReadOnly)>0 then
      FileSetAttrUTF8(sourceFile, attrSource-faReadOnly)
    else if (attrSource and faHidden)>0 then
      FileSetAttrUTF8(sourceFile, attrSource-faHidden);
  end;

  if not FileUtil.CopyFile(sourceFile, targetFile, Flags) then begin
    DebugLn('ERROR sourceFile='+sourceFile);
    DebugLn('ERROR targetFile='+targetFile);
    exit;
  end;

  if PreserveAttributes then begin
    FileSetAttrUTF8(sourceFile, attrSource);
    FileSetAttrUTF8(targetFile, attrSource);
  end;
  Result:=true;
end;
function CopyFiles(sourceDir, fileMask, targetDir: string;
            SearchSubDirs: boolean=true;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;
{ copy files and force dirs, options: search sub dirs, overwrite, preserve attributes }
var
  FileInfo: TSearchRec;
  sourceFile, targetFile: String;
begin
  Result:=false;
  sourceDir:=CleanAndExpandDirectory(sourceDir);
  targetDir:=CleanAndExpandDirectory(targetDir);
  if FindFirstUTF8(sourceDir+fileMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        { form source and target path }
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if SearchSubDirs then begin
            { create dir path - will copy empty dir }
            if not ForceDirectories(targetFile) then exit;
            if not CopyFiles(sourceFile, fileMask, targetFile) then exit;
          end;
        end else begin
          { if file is hidden or readonly then remove attributes }
          if (FileInfo.Attr and faReadOnly)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faReadOnly)
          else if (FileInfo.Attr and faHidden)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faHidden);
          { create dir if not exists and copy file with overwrite }
          if not ForceDirectories(targetDir) then exit;
          if not FileUtil.CopyFile(sourceFile, targetFile, Flags) then exit;
          { copy file attributes from source }
          if PreserveAttributes then FileSetAttrUTF8(targetFile, FileInfo.Attr);
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  Result:=true;
end;
function DelDir(targetDir: string; OnlyChildren: boolean=False): boolean;
{ delete directory tree incl hidden and readonly files, OnlyChildren or parent dir }
var
  FileInfo: TSearchRec;
  targetFile: String;
begin
  targetDir:=CleanAndExpandDirectory(targetDir);
  Result:=true;
  if not DirectoryExistsUTF8(targetDir) then exit;
  Result:=false;
  if FindFirstUTF8(targetDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if not DelDir(targetFile, false) then exit;
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
{ TODO : TEST }
function MoveDir(sourceDir, targetDir: string): boolean;
{ move directory tree, overwrite and preserve attributes }
begin
  Result:=false;
  if not CopyDir(sourceDir, targetDir) then exit;
  if not DelDir(sourceDir, false) then exit;
  Result:=true;
end;
function MoveFiles(sourceDir, fileMask, targetDir: string;
            SearchSubDirs: boolean=true;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;
{ move files and force dirs, options: search sub dirs, overwrite, preserve attributes }
var
  FileInfo: TSearchRec;
  sourceFile, targetFile: String;
begin
  Result:=false;
  sourceDir:=CleanAndExpandDirectory(sourceDir);
  targetDir:=CleanAndExpandDirectory(targetDir);
  if FindFirstUTF8(sourceDir+fileMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        { form source and target path }
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if SearchSubDirs then begin
            { create dir path - will copy empty dir }
            if not ForceDirectories(targetFile) then exit;
            if not MoveFiles(sourceFile, fileMask, targetFile) then exit;
          end;
        end else begin
          { if file is hidden or readonly then remove attributes }
          if (FileInfo.Attr and faReadOnly)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faReadOnly)
          else if (FileInfo.Attr and faHidden)>0 then
            FileSetAttrUTF8(targetFile, FileInfo.Attr-faHidden);
          { create dir if not exists and copy file with overwrite }
          if not ForceDirectories(targetDir) then exit;
          if not FileUtil.CopyFile(sourceFile, targetFile, Flags) then exit;
          if not DeleteFileUTF8(sourceFile) then exit;
          { copy file attributes from source }
          if PreserveAttributes then FileSetAttrUTF8(targetFile, FileInfo.Attr);
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  Result:=true;
end;

end.

