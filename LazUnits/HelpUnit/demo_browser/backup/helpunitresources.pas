unit helpunitresources;

{$mode objfpc}{$H+}

{$R myhelpfiles.rc}

interface

uses
  Classes, SysUtils, lclintf,
  Windows, //RT_RCDATA
  fileutil,
  LazFileUtils,
  LResources,
  Dialogs; //ShowMessage

  function GetResTemp: string;
  procedure ExtractResFiles;
  procedure DeleteExtractedResFiles;

implementation

const
  DS=DirectorySeparator;

var
  myhelpfiles: TStringList;

function GetResTemp: string;
begin
  Result:=GetTempDir(false)+'helptmp'+DS;
end;
procedure DeleteExtractedResFiles;
var
  i: integer;
  f: string;
begin
  try
    for i:=0 to myhelpfiles.Count-1 do begin
      f:=GetResTemp+myhelpfiles[i]+'.html';
      if FileExists(f) then DeleteFileUTF8(f);
    end;
    if DirectoryExistsUTF8(GetResTemp) then
      RemoveDirUTF8(GetResTemp);
  finally
    myhelpfiles.Free;
  end;
end;
procedure ExtractResFiles;
var
  i: integer;
  S: TResourceStream;
  buff: TStringList;
begin
  buff:=TStringList.Create;
  myhelpfiles:=TStringList.Create;
  try
    S := TResourceStream.Create(HInstance, 'myhelpfiles', RT_RCDATA);
    buff.LoadFromStream(S);
    for i:=1 to buff.Count-1 do begin
      myhelpfiles.Add(Copy(buff[i],1,Pos('RCDATA',buff[i])-2));
    end;
  finally
    FreeAndNil(S);
    buff.Free;
  end;
  ForceDirectoriesUTF8(GetResTemp);
  try
    for i:=0 to myhelpfiles.Count-1 do begin
      S:=TResourceStream.Create(HInstance, myhelpfiles[i], RT_RCDATA);
      S.SaveToFile(GetResTemp+myhelpfiles[i]+'.html');
      FreeAndNil(S);
    end;
  finally
    FreeAndNil(S);
  end;
end;
end.
