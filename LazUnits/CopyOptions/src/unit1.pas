{ Version 1.0 - Author jasc2v8 at yahoo dot com

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org> }

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, FileCtrl, ComCtrls,
  LazFileUtils,strutils;

type

  { TMainForm }

  TMainForm = class(TForm)
    ButtonCopyProjectOptions: TButton;
    ButtonCopyIDEOptions: TButton;
    DirSource: TDirectoryEdit;
    DirTarget: TDirectoryEdit;
    FileTarget: TFileNameEdit;
    FileSource: TFileNameEdit;
    LabelFileFrom: TLabel;
    LabelFileTo: TLabel;
    HelpMemo: TMemo;
    LabelDirFrom: TLabel;
    LabelDirTo: TLabel;
    OptionFileList: TFileListBox;
    PageControl: TPageControl;
    TabProjectOptions: TTabSheet;
    HelpSheet: TTabSheet;
    TabIDEOptions: TTabSheet;
    procedure ButtonCopyIDEOptionsClick(Sender: TObject);
    procedure ButtonCopyProjectOptionsClick(Sender: TObject);
    procedure DirSourceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    gConfigDir: string;
  public

  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
  ENVOPTFILENAME='environmentoptions.xml';
var
  MainForm: TMainForm;

implementation

{$R *.lfm}

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
  Result:=CleanAndExpandDirectory(aDir)+CleanAndExpandFilename(aFile);
end;
function ReadTag(aFileName: string; aTag: string): string;
{ find tag then return value within quotes, value must be on the same line as the tag }
{ example: <LazarusDirectory Value="C:\lazarus\182"> returns text within quotes}
{ example: --primary-config-path=C:\lazarus\182 returns text after equals sign }
var
  q1, q2: integer;
  aList: TStringList;
  aLine: string;
begin
  Result:='';
  if not FileExists(aFileName) then exit;
  try
    aList:=TSTringList.Create;
    aList.LoadFromFile(aFileName);
    for aLine in aList do begin
      if Length(aLine) > 0 then begin
        if aLine.Contains(aTag) then begin
          if aLine.Contains('"') then begin
            q1:=aLine.IndexOf('"');
            q2:=aLine.LastIndexOf('"');
            Result:=Copy(aLine,q1+2,q2-q1-1);
            break;
          end else begin
            q1:=aLine.IndexOf('=');
            Result:=Copy(aLine,q1+2,aLine.Length);
            break;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(aList);
  end;
end;

{ TMainForm }

procedure TMainForm.ButtonCopyProjectOptionsClick(Sender: TObject);
{ source is *.xml myprojectoptions.xml or buildmodes.xml }
{ target is project.lpi }
var
  i,j: integer;
  MyProjectFile: string;
  ProjectFile, ProjectName: string;
  ProjectList, MyProjectList, OutputList: TStringList;
begin

  {get selected myprojectoptions.xml file}
  MyProjectFile:=Trim(FileSource.Text);

  if not FileExists(MyProjectFile) then begin
    ShowMessage('Error: File does not exist: '+LE+LE+MyProjectFile);
    Exit;
  end;

  {get selected project.lpi file}
  ProjectFile := Trim(FileTarget.FileName);

  if not FileExists(ProjectFile) then begin
    ShowMessage('Error: File does not exist: '+LE+LE+ProjectFile);
    Exit;
  end;

  {save project name}
  ProjectName:=ExtractFileNameWithoutExt(ExtractFileName(ProjectFile));

  {make a backup copy}
  CopyFile(ProjectFile, ProjectFile+'.bak', [cffOverwriteFile]);

  {create string lists}
  ProjectList:=TStringList.Create;
  MyProjectList:=TStringList.Create;
  OutputList:=TStringList.Create;

  {read project.lpi into list}
  ProjectList.LoadFromFile(ProjectFile);

  {read build modes xml into list}
  MyProjectList.LoadFromFile(MyProjectFile);

  {save ProjectList to OutputList until start tag is found}
  i:=0;
  repeat
    OutputList.Append(ProjectList[i]);
    Inc(i);
  until AnsiContainsText(ProjectList[i],'<BuildModes');

  {if no start tag then error}
  if (i=ProjectList.Count-1) then begin
    ShowMessage('Error: <BuildModes start tag not in file:'+LE+LE+ProjectFile);
    Exit;
  end;

  {find start tag in myprojectopions.xml}
  j:=0;
  repeat
    Inc(j);
  until AnsiContainsText(MyProjectList[j],'<BuildModes');

  {if no start tag then error}
  if (j=MyProjectList.Count-1) then begin
    ShowMessage('Error: <BuildModes start tag not in file:'+LE+LE+MyProjectFile);
    Exit;
  end;

  {save MyProjectList to OutputList until end tag is found, and fix project name}
  repeat
    if MyProjectList[j].Contains('project1') then begin
      if (not SameText(ProjectName,'project1')) then begin
        MyProjectList[j]:=StringReplace(MyProjectList[j], 'project1', ProjectName, []);
      end;
    end;
    OutputList.Append(MyProjectList[j]);
    Inc(j);
  until AnsiContainsText(MyProjectList[j],'</BuildModes');

  {advance ProjectList until end tag is found}
  repeat
    Inc(i);
  until AnsiContainsText(ProjectList[i],'</BuildModes');

  {finish saving ProjectList to OutputList}
  repeat
    OutputList.Append(ProjectList[i]);
    Inc(i);
  until i=ProjectList.Count;

  {save OutputList, overwrite Project.lpi file}
  OutputList.SaveToFile(ProjectFile);
  ShowMessage('Finished copying options to project file:'+LE+LE+ProjectFile);

  {cleanup}
  ProjectList.Free;
  MyProjectList.Free;
  OutputList.Free;

end;
procedure TMainForm.ButtonCopyIDEOptionsClick(Sender: TObject);
var
  source, target: string;
  OldLazDir, NewLazDir: string;
  OldCfgDir, NewCfgDir: string;
  i: integer;
  r: boolean;
  aXMLFile, aFileList: TStringList;
  aFile: string;
begin

  { get dirs }
  source:=JoinPath(Trim(DirSource.Text), ENVOPTFILENAME);
  OldLazDir:=ReadTag(source,'LazarusDirectory');

  source:=JoinPath(OldLazDir, 'lazarus.cfg');
  OldCfgDir:=ReadTag(source, '--primary-config-path');

  NewCfgDir:=Trim(DirTarget.Text);
  NewLazDir:=JoinPath(ParentPath(OldLazDir), ChildPath(NewCfgDir));

  { copy each file, making a backup of existing file }
  for i:=0 to OptionFileList.Items.Count-1 do begin
    if OptionFileList.Selected[i]=true then begin
      source:=OptionFileList.Directory+DS+OptionFileList.Items[i];
      target:=Trim(DirTarget.Text)+DS+OptionFileList.Items[i];
      CreateDirUTF8(Trim(DirTarget.Text));
      r:=CopyFile(target, target+'.bak', [cffOverwriteFile]);
      r:=CopyFile(source, target, [cffOverwriteFile]);
      if not r then ShowMessage('Error copying '+OptionFileList.Items[i]);
    end;
  end;

  aXMLFile:=TStringList.Create;
  aFileList:=TStringList.Create;

  aFileList:=FindAllFiles(NewCfgDir,'*.xml');

  { fix the paths in each XML file }
  { some may not have to be updated, could exclude these in future }
  for aFile in aFileList do begin
    aXMLFile.LoadFromFile(aFile);
    aXMLFile.Text:=StringReplace(aXMLFile.Text,OldLazDir,NewLazDir,[rfReplaceAll]);
    aXMLFile.Text:=StringReplace(aXMLFile.Text,OldCfgDir,NewCfgDir,[rfReplaceAll]);
    aXMLFile.SavetoFile(aFile);
  end;

  ShowMessage('Finished Copying IDE Options.');

  FreeAndNil(aXMLFile);
  FreeAndNil(aFileList);

end;
procedure TMainForm.DirSourceChange(Sender: TObject);
{ update the OptonFileList: TFileListBox after user changes directory }
var
  ConfigFile: string;
  i: integer;
begin

  OptionFileList.Sorted:=true;
  OptionFileList.Mask:='*.xml';

  ConfigFile:=Trim(DirSource.Text)+DS+'lazarus.cfg';
  OptionFileList.Directory:=ReadTag(ConfigFile,'--primary-config-path');

  if OptionFileList.Directory='' then
     OptionFileList.Directory:=DirSource.Text;

  for i:=0 to OptionFileList.Items.Count-1 do begin
    if  (OptionFileList.Items[i]='editoroptions.xml') or
        (OptionFileList.Items[i]=ENVOPTFILENAME) or
        (OptionFileList.Items[i]='projectoptions.xml') then
          OptionFileList.Selected[i]:=true;
  end;

end;
procedure TMainForm.FormShow(Sender: TObject);
var
  AppDatDir: string;
  fileList: TStringList;
begin

  { change to your work directory }
  //FileSource.InitialDir:='D:\DEV\Work\Pascal\';
  FileSource.InitialDir:=GetCurrentDir;
  FileTarget.InitialDir:=FileSource.InitialDir;

  FileSource.Filter:='Lazarus Options file|*.xml|All files|*.*';
  FileTarget.Filter:='Lazarus Project file|*.lpi|All files|*.*';

  { will be different on other OS platforms }
  AppDatDir:=SysUtils.GetEnvironmentVariable('LOCALAPPDATA');
  gConfigDir:=AppendPathDelim(AppDatDir)+'lazarus';

  fileList:=TStringList.Create;

  { set config source }
  if FileExists(JoinPath(AppDatDir, ENVOPTFILENAME)) then begin
      DirSource.Text:=AppDatDir;
  end else begin
    FindAllFiles(fileList, gConfigDir, ENVOPTFILENAME);
    if fileList.Count>0 then begin
        fileList.Sort;
        DirSource.Text:=ExtractFilePath(fileList[0]);
    end else begin
        DirSource.Text:=AppDatDir;
    end;
  end;

  DirTarget.Text:=gConfigDir+'\backup\';

  OptionFileList.Clear;
  DirSourceChange(nil);

  PageControl.ActivePage:=HelpSheet;

  FreeAndNil(fileList);

end;

end.
