{

Program:    Pascal Delete Utility
Function:   Yet another alternative to Windows del and rmdir
Copyright:  Copyright (C) 2018 by James O. Dreher
License:    https://opensource.org/licenses/MIT
Created:    8/10/2018
LazProject: project inspector, add lazUtils
            Compiler Options, Config and Target, UNcheck win32 gui
Usage:``    pdel /h

  pdel /s path           del path tree, then path

  pdel /opt path         del files in path
  pdel /opt path\*       del files in path
  pdel /opt path\*.*     same as \*

  pdel /opt path\sub     del path\sub files

  pdel /opt path\file.ext  del file.ext

  pdel /opt path\file.*  del matching files in path
  pdel /opt path\*.ext  del matching files in path

  pdel /opt path\f?le.*  del matching files in path
  pdel /opt path\*.e?t  del matching files in path

  pdel /opt @list        del matching dir and files in list.txt

  pdel e:\temp\*.l* /s    will delete parent dir temp

}

program pdel;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, CustApp, FileUtil, LazFileUtils, StrUtils;

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  private
    FOptAll : boolean;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    property OptAll: boolean read FOptAll write FOptAll;
    procedure DoHelp;
    function HasOpt(Opt: string): boolean;
    function DoDel(sPath: string): boolean;
    function DoDelList(aTextFile, aTargetDir: string): boolean;
    function DoInstall: boolean;
    function DoUnInstall: boolean;
  end;

const
  DS=DirectorySeparator;
  LE=LineEnding;

{ TMyApplication }

{procedure DebugLn(aLine: string);
begin
  Writeln('DEBUG: '+aLine)
end;}
function RestoreAttributes(aFile: string; Attributes: LongInt): LongInt;
begin
  Result:=FileSetAttrUTF8(aFile, Attributes);
end;
function RemoveAttributes(aFile: string; attrArray: Array of LongInt): LongInt;
var
  i: integer;
  attrSave: LongInt;
begin
  attrSave:=FileGetAttrUTF8(aFile);
  for i:=Low(attrArray) to High(attrArray) do begin
    if (attrSave and attrArray[i])>0 then
        FileSetAttrUTF8(aFile, attrSave-attrArray[i]);
  end;
  Result:=attrSave;
end;
function ChildPath(aPath: string): string;
begin
  aPath:=ExpandFileName(ChompPathDelim(aPath));
  Result:=Copy(aPath,aPath.LastIndexOf(DS)+2);
end;
function ParentPath(aPath: string): string;
begin
  Result:=ExpandFileName(IncludeTrailingPathDelimiter(aPath) + '..');
end;
function JoinPath(aDir, aFile: string): string;
begin
  Result:=CleanAndExpandDirectory(aDir)+Trim(aFile);
end;
function TMyApplication.DoInstall: boolean;
var
  sPath, tPath: string;
begin
  sPath:=ExeName;
  tPath:=JoinPath(GetEnvironmentVariable('SystemRoot'),ExtractFilename(sPath));

  if not FileUtil.CopyFile(sPath, tPath, [cffOverwriteFile]) then
    Writeln('Error installing '+sPath+' - run as Admin')
  else
    Writeln('Success installing to '+tPath);

end;
function TMyApplication.DoUnInstall: boolean;
var
  sPath, tPath: string;
begin
  sPath:=ExeName;
  tPath:=JoinPath(GetEnvironmentVariable('SystemRoot'),ExtractFilename(sPath));

  if not SysUtils.FileExists(tPath) then
    Writeln('Not installed')
  else if not DeleteFileUTF8(tPath) then
    Writeln('Error Un-installing '+sPath+' - run as Admin')
  else
     Writeln('Success Un-installing from '+sPath);
end;
function TMyApplication.DoDelList(aTextFile, aTargetDir: string): boolean;
var
  i: integer;
  aList: TStringList;
  aLine, aPath: String;

begin
  i:=0;
  aList:=TStringList.Create;

  if ExtractFileExt(aTextFile)='' then
    aTextFile:=aTextFile+'.txt';

  if not FileExists(aTextFile) then begin
    writeln('Error '+aTextFile+' does not exist');
    Exit;
  end;

  aList.LoadFromFile(aTextFile);

  for aLine in aList do begin
    Inc(i);
    if (not aLine.isEmpty) and (not aLine.StartsWith('//')) then begin
      aPath:=Trim(aLine);
      if not DoDel(aPath) then
        Writeln('Error deleting '+aPath);
    end;
  end;
  aList.Free;
end;
function TMyApplication.DoDel(sPath: string): boolean;
var
  i: integer;
  src: TSearchRec;
  sDir, tDir, sFile, tFile, fMask: String; //s=source, t=target
  Flags: TCopyFileFlags;
  ans: string;
  sFileAttr, tFileAttr: LongInt;
  aExt: string;
begin

  Result:=false;

   if ChildPath(sPath).Contains('*') or ChildPath(sPath).Contains('?') then begin
     sDir:=ParentPath(sPath);
     fMask:=ChildPath(sPath);
   end else if FileExists(sPath) then begin
     sDir:=ExtractFileDir(sPath);
     fMask:=ExtractFileName(sPath);
   end else begin
     if DirectoryExists(sPath) then begin
       sDir:=sPath;
       fMask:=GetAllFilesMask;
     end else begin
       Writeln('Error path not found: '+sPath);
       Terminate;
       Exit;
     end;
   end;

  if (fMask<>GetAllFilesMask) and
     (not sPath.Contains('*')) and
     (not sPath.Contains('?')) then
    if not FileExists(sPath) then begin
      writeln('Error file not found: '+sPath);
      Terminate;
      Exit;
    end;

  if FindFirst(JoinPath(sDir,fMask),faAnyFile,src)=0 then begin
    repeat

      if (src.Name<>'.') and (src.Name<>'..') and (src.Name<>'') then begin

        sFile:=JoinPath(sDir,src.Name);

        if ChildPath(tDir).Contains('*') then begin
          if (ChildPath(tDir)='*.*') or (ChildPath(tDir)='*') then begin
            tDir:=ParentPath(tDir);
            tFile:=JoinPath(tDir, ExtractFileName(sFile))
          end else if ChildPath(tDir).StartsWith('*.') then
            tFile:=JoinPath(ParentPath(tDir), ExtractFileNameOnly(sFile)+ExtractFileExt(tDir))
          else if ChildPath(tDir).EndsWith('.*') then
            tFile:=JoinPath(ParentPath(tDir),ExtractFileNameOnly(tDir)+ExtractFileExt(sFile));
        end else begin
          if ExtractFileExt(tDir)='' then
            tFile:=JoinPath(tDir,src.Name)
          else begin
            tFile:=tDir;
            tDir:=ExtractFileDir(tFile);
          end;
        end;

        if (src.Attr and faDirectory)>0 then begin

          if HasOpt('S') then begin
            if not DoDel(sFile) then exit;
          end;

        end else begin

          if HasOpt('L') then begin
            ans:='N';
            Writeln('Delete '+sFile);
          end else begin

            if not HasOpt('Q') then Writeln(sFile);

            if (FileGetAttrUTF8(sFile) and faReadOnly)>0 then
              RemoveAttributes(sFile,[faReadOnly]);

            if not DeleteFileUTF8(sFile) then
              Writeln('Error deleting '+sFile);
            end;

          end;
        end;
    until FindNext(src)<>0;
  end;

  if HasOpt('S') then begin
    if HasOpt('L') then
      Writeln('Remove '+ExtractFileDir(sFile))
    else begin
      Writeln(ExtractFileDir(sFile));
      if not RemoveDirUTF8(ExtractFileDir(sFile)) then
            Writeln('Error deleting '+ExtractFileDir(sFile));
    end;
  end;

  FindClose(src);
  Result:=true;

end;
procedure TMyApplication.DoRun;
var
  i: integer;
  sPath: string='';
  tPath: string='';
begin

  if HasOpt('H') or HasOpt('?') then begin
    DoHelp;
    Terminate;
    Exit;
  end;

  if HasOpt('I') then begin
    DoInstall;
    Terminate;
    Exit;
  end;

  if HasOpt('U') then begin
    DoUninstall;
    Terminate;
    Exit;
  end;

  //TODO: hard-coded version
  if HasOpt('V') then begin
    Writeln(LE+'Pascal Delete Utility (pdel) version 1.0.0 '+
    'Copyright (C) 2018 by Jim Dreher'+
    ', released under the MIT license.');
    Terminate;
    Exit;
  end;

  for i:=1 to ParamCount do begin
     if not ParamStr(i).StartsWith('/') and not ParamStr(i).StartsWith('-') then
      if sPath.IsEmpty then
        sPath:=ParamStr(i)
      else
        if tPath.IsEmpty then
          tPath:=ParamStr(i);
  end;

  if sPath.StartsWith('@') then begin
    Delete(sPath,1,1);
    DoDelList(sPath,tPath);
    Terminate;
    Exit;
  end;

  if sPath.IsEmpty then begin
    Writeln('Error no path to delete');
    Terminate;
    Exit;
  end;

  if not DoDel(sPath) then
    {Writeln('Error copying '+sPath+' to '+tPath)};

  Terminate;
  Exit;

end;

procedure TMyApplication.DoHelp;
begin
  writeln(LE+
  '  pdel [-options|/options] [@list|path]'+LE+LE+
  '  h|?  List options and how to use them.'+LE+
  '  i    Install on PATH in C:\Windows (run as Admin).'+LE+
  '  l    List files without deleting.'+LE+
  '  q    Don''t display filenames during delete.'+LE+
  '  s    Delete subdirectories and parent directory. Used to delete dir tree.'+LE+
  '  u    Uninstall from PATH in C:\Windows (run as Admin).'+LE+
  '  v    Display version information.'+LE);
end;
function TMyApplication.HasOpt(Opt: string): boolean;
begin
  Result:=false;
  OptionChar:='-';
  if HasOption(UpperCase(Opt)) or HasOption(LowerCase(Opt)) then Result:=true;
  OptionChar:='/';
  if HasOption(UpperCase(Opt)) or HasOption(LowerCase(Opt)) then Result:=true;
end;
constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;
destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;
var
  Application: TMyApplication;

{$R *.res}

begin
  Application:=TMyApplication.Create(nil);
  Application.Run;
  Application.Free;
end.

