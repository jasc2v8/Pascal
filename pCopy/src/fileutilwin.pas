unit fileutilwin;

{ Version 0.1 Copyright (C) 2018 by James O. Dreher

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

function CopyDirWin(sourceDir, targetDir: string;
                    Flags: TCopyFileFlags=[cffOverwriteFile];
                    PreserveAttributes: boolean=true): boolean;

function CopyDirWinEC(sourceDir, targetDir: string;
                    Flags: TCopyFileFlags=[cffOverwriteFile];
                    PreserveAttributes: boolean=true): integer;

function DelDirWin(targetDir: string; OnlyChildren: boolean=False): boolean;

function MoveDirWin(sourceDir, targetDir: string): boolean;

function CopyFileWin(sourceFile, targetFile: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

function CopyFilesWin(sourceDir, fileMask, targetDir: string;
            SearchSubDirs: boolean=true;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

function MoveFilesWin(sourceDir, fileMask, targetDir: string;
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

function CopyDirWin(sourceDir, targetDir: string;
                    Flags: TCopyFileFlags=[cffOverwriteFile];
                    PreserveAttributes: boolean=true): boolean;

{ copy directory tree, force directores, overwrite, and preserve attributes }
{ Result: 0=success, 1=sourceDir not exist, 2=err create targetDir,
          3=err set attributes, 4=err copy dir, 5=error copy files }
var
  sourceFile, targetFile: String;
  FileInfo: TSearchRec;
begin
  Result:=false;

  sourceDir:=CleanAndExpandDirectory(sourceDir);
  targetDir:=CleanAndExpandDirectory(targetDir);

  if DirectoryExistsUTF8(sourceDir) then
    if (Flags=[cffOverwriteFile]) then DelDirWin(targetDir)
  else
    Exit;

  if not ForceDirectories(targetDir) then //will create empty dir
    Exit;

  if FindFirstUTF8(sourceDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if not CopyDirWin(sourceFile, targetFile, Flags, PreserveAttributes) then
            Exit;
        end else begin
          if not CopyFileWin(sourceFile, targetFile, Flags, PreserveAttributes) then
            Exit;
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;

  { copy dir attributes - file attributes copied with CopyFileWin above }
  if PreserveAttributes then
    FileSetAttrUTF8(targetDir, FileGetAttrUTF8(sourceDir));

  FindCloseUTF8(FileInfo);
  Exit(True);
end;

//CopyWinDirErr
//CopyWinDirErrCheck
//CopyWinDirErrCode
//CopyWinDirEC
//CopyWinDir
//CopyWinDirErrChk

function CopyDirWinEC(sourceDir, targetDir: string;
                    Flags: TCopyFileFlags=[cffOverwriteFile];
                    PreserveAttributes: boolean=true): integer;

{ copy directory tree, force directores, overwrite, and preserve attributes }
{ Result: 0=success, 1=sourceDir not exist, 2=err create targetDir,
          3=err set attributes, 4=err copy dir, 5=error copy files }
const
  { move to top to make global? do NOT move to fileutilwin.inc }
  ERR_SUCCESS=0;
  ERR_DIR_NOT_EXIST=1;
  ERR_CREATE_DIR=2;
  ERR_SET_ATTRIBUTES=3;
  ERR_COPY_DIR=4;
  ERR_COPY_FILE=5;
var
  ErrCode: integer;
  FileInfo: TSearchRec;
  sourceFile, targetFile: String;
begin

  sourceDir:=CleanAndExpandDirectory(sourceDir);
  targetDir:=CleanAndExpandDirectory(targetDir);

  { force overwrite, del dir }
  if DirectoryExistsUTF8(sourceDir) then
    if (Flags=[cffOverwriteFile]) then DelDirWin(targetDir)
  else
    Exit(ERR_DIR_NOT_EXIST);

  if not ForceDirectories(targetDir) then //will create empty dir
    Exit(ERR_CREATE_DIR);

  if FindFirstUTF8(sourceDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then begin
        sourceFile:=sourceDir+FileInfo.Name;
        targetFile:=targetDir+FileInfo.Name;
        if (FileInfo.Attr and faDirectory)>0 then begin
          if CopyDirWinEC(sourceFile, targetFile, Flags, PreserveAttributes) >0 then
            Exit(ERR_COPY_DIR);
        end else begin
          if not CopyFileWin(sourceFile, targetFile, Flags, PreserveAttributes) then
            Exit(ERR_COPY_FILE);
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;

  { copy dir attributes - file attributes copied with CopyFileWin above }
  if PreserveAttributes then
    FileSetAttrUTF8(targetDir, FileGetAttrUTF8(sourceDir));

  FindCloseUTF8(FileInfo);
  Exit(ERR_SUCCESS);
end;

function CopyFileWin(sourceFile, targetFile: string;
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

  if not ForceDirectories(targetDir) then exit;

  if PreserveAttributes then begin
    attrSource:=FileGetAttrUTF8(sourceFile);
    if (attrSource and faReadOnly)>0 then
      FileSetAttrUTF8(sourceFile, attrSource-faReadOnly)
    else if (attrSource and faHidden)>0 then
      FileSetAttrUTF8(sourceFile, attrSource-faHidden);
  end;

  if not FileUtil.CopyFile(sourceFile, targetFile, Flags) then exit;

  if PreserveAttributes then begin
    FileSetAttrUTF8(sourceFile, attrSource);
    FileSetAttrUTF8(targetFile, attrSource);
  end;
  Result:=true;
end;
function CopyFilesWin(sourceDir, fileMask, targetDir: string;
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
            if not ForceDirectories(targetDir) then exit;
            if not CopyFilesWin(sourceFile, fileMask, targetFile) then exit;
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
function DelDirWin(targetDir: string; OnlyChildren: boolean=False): boolean;
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
{ TODO : TEST }
function MoveDirWin(sourceDir, targetDir: string): boolean;
{ move directory tree, overwrite and preserve attributes }
begin
  Result:=false;
  if CopyDirWinEC(sourceDir, targetDir) >0 then exit;
  if not DelDirWin(sourceDir, false) then exit;
  Result:=true;
end;
function MoveFilesWin(sourceDir, fileMask, targetDir: string;
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
            if not ForceDirectories(targetDir) then exit;
            if not MoveFilesWin(sourceFile, fileMask, targetFile) then exit;
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

