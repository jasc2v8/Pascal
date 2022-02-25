{ TODO :
implement FBaseDir

FBaseDir:=GetCurrentDir+DS+'htmlbrowser';

res.rc
htmlbrowser RCDATA "htmlbrowser.rc"

function GetFileDir
Result:=GetCurrentDir+DS+'htmlbrowser';

GetResDir
..\Temp\htmlbrowser\index.html

index.html
<img src="poppy.jpg" title="" alt="poppy.jpg image">

.OpenFile
GetFileDir+'index.html'

.OpenRes
GetResDir+'index.html'

}

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

unit htmlbrowser;

{$mode objfpc}{$H+}

//{$IFNDEF htmlfileviewer_res_loaded}
//  {$DEFINE htmlbrowser_res_loaded}
{$R htmlbrowser.rc} //comment out if no resources used
//{$ENDIF}

interface

uses
  Classes, SysUtils,
  fileutil,   //DeleteFile
  lclintf,    //OpenURL
  Windows,    //RT_RCDATA
  Dialogs;    //ShowMessage

type
  THTMLBrowserViewer = class(TObject)
    private
      Resources: TStringList;
      FBaseDir: string;
    public
      constructor Create;
      destructor Destroy;  override;
      function GetResTemp: string;
      procedure DeleteExtractedResFiles;
      procedure ExtractResFiles;
      procedure OpenURL(aURL: string);
      procedure OpenFile(aFilename: string);
      procedure OpenResource(aFilename: string);
  end;
const
  DS=DirectorySeparator;

implementation

{ Resources }

function THTMLBrowserViewer.GetResTemp: string;
begin
  Result:=GetTempDir(false)+'res-htmlbrowser'+DS;
end;
procedure THTMLBrowserViewer.DeleteExtractedResFiles;
var
  i: integer;
  f: string;
begin
  try
    for i:=0 to Resources.Count-1 do begin
      f:=GetResTemp+Resources[i]+'.html';
      if FileExists(f) then sysutils.DeleteFile(f);
    end;
    if DirectoryExists(GetResTemp) then
      RemoveDir(GetResTemp);
  finally
    Resources.Free;
  end;
end;
procedure THTMLBrowserViewer.ExtractResFiles;
var
  i,q1: integer;
  S: TResourceStream;
  buff: TStringList;
  ResName,ResValue: string;
begin

  buff:=TStringList.Create;
  Resources:=TStringList.Create;

  try
    //S:=TResourceStream.Create(HInstance, 'res', RT_RCDATA);
    S:=TResourceStream.Create(HInstance, 'htmlbrowser', PChar(500));
  except
    Exit;
  end;

  try
    buff.LoadFromStream(S);
    for i:=1 to buff.Count-1 do begin
      //ResName:=Trim(Copy(buff[i],1,Pos('RCDATA',buff[i])-2));
      ResName:=Trim(Copy(buff[i],1,Pos('500',buff[i])-2));
      q1:=buff[i].IndexOf('"');
      ResValue:=Trim(Copy(buff[i],q1+2,buff[i].Length-q1-2));

      if ResName<>'' then begin
        Resources.Add(ResName+'='+ExtractFileName(ResValue));
        //ShowMessage('debug browswer ResName='+ResName+', ResValue='+ResValue);
      end;
    end;
  finally
    FreeAndNil(S);
    buff.Free;
  end;

  ForceDirectories(GetResTemp);

  try
    for i:=0 to Resources.Count-1 do begin
      //S:=TResourceStream.Create(HInstance, Resources.Names[i], RT_RCDATA);
      S:=TResourceStream.Create(HInstance, Resources.Names[i], PChar(500));
      S.SaveToFile(GetResTemp+Resources.ValueFromIndex[i]);
      FreeAndNil(S);
    end;
  finally
    FreeAndNil(S);
  end;
end;

{ THTMLBrowserViewer }
constructor THTMLBrowserViewer.Create;
begin
  inherited Create;
  ExtractResFiles;
end;
destructor THTMLBrowserViewer.Destroy;
begin
  DeleteExtractedResFiles;
  inherited;
end;
procedure THTMLBrowserViewer.OpenResource(aFilename: string);
begin

  if Resources.Count=0 then Exit;

  aFilename:=GetResTemp+aFilename;
  OpenFile(aFilename);
end;
procedure THTMLBrowserViewer.OpenFile(aFilename: string);
begin
  if ExtractFilePath(aFilename)='' then
    aFilename:=GetCurrentDir+DS+aFilename;
  lclintf.OpenURL('file:///'+aFilename);
end;
procedure THTMLBrowserViewer.OpenURL(aURL: string);
begin
  lclintf.OpenURL(aURL);
end;

end.
