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

{ with help from: http://pp4s.co.uk/main/tu-form2-help-demo-laz.html }

unit htmlfileviewer;

{$mode objfpc}{$H+}

{$R res.rc} //comment out if no resources used

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  FileUtil, LazFileUtils,
  IpHtml,   //turbopower_ipro
  lclintf,  //OpenURL
  Windows;  //RT_RCDATA

type
  TSimpleIpHtml = class(TIpHtml)
  public
    property OnGetImageX;
  end;

  { THelpForm }

  THelpForm = class(TForm)
      IpHtmlPanel1: TIpHtmlPanel;
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure ExtractResources;
      procedure DeleteResources;
      procedure IpHtmlPanel1HotClick(Sender: TObject);
      procedure HTMLGetImageX(Sender: TIpHtmlNode;const URL: string;var Picture: TPicture);
    private
      TempDir: string;
      Resources: TStringList;
      procedure ShowHelpForm;
    public
      procedure OpenFile(const Filename: string);
      procedure OpenResource(const Resourcename : string);
      procedure OpenURL(const aURL : string);
  end;
const
  RES_DIR='res';
  SHOW_FILEPATH_IN_HELP_FORM_CAPTION=true;
  DS=DirectorySeparator;
var
  HelpForm: THelpForm;
implementation

{$R *.lfm}

{ Resources }

procedure THelpForm.DeleteResources;
var
  i: integer;
  f: string;
begin
  try
    for i:=0 to Resources.Count-1 do begin
      f:=TempDir+Resources.ValueFromIndex[i];
      if FileExists(f) then sysutils.DeleteFile(f);
    end;
    if DirectoryExists(TempDir) then
      RemoveDir(TempDir);
  finally
    Resources.Free;
  end;
end;
procedure THelpForm.ExtractResources;
var
  i,q1: integer;
  S: TResourceStream;
  buff: TStringList;
  ResName,ResValue: string;
begin
  buff:=TStringList.Create;
  Resources:=TStringList.Create;

  try
    S:=TResourceStream.Create(HInstance, RES_DIR, RT_RCDATA);
  except
    ShowMessage('Error extracting resources');
    Exit;
  end;

  try
    buff.LoadFromStream(S);
    for i:=1 to buff.Count-1 do begin
      ResName:=Trim(Copy(buff[i],1,Pos('RCDATA',buff[i])-2));
      q1:=buff[i].IndexOf('"');
      ResValue:=Trim(Copy(buff[i],q1+2,buff[i].Length-q1-2));

      if ResName<>'' then begin
        Resources.Add(ResName+'='+ExtractFileName(ResValue));
      end;

    end;
  finally
    FreeAndNil(S);
    buff.Free;
  end;

  ForceDirectories(TempDir);

  try
    for i:=0 to Resources.Count-1 do begin
      S:=TResourceStream.Create(HInstance, Resources.Names[i], RT_RCDATA);
      S.SaveToFile(TempDir+Resources.ValueFromIndex[i]);
      FreeAndNil(S);
    end;
  finally
    FreeAndNil(S);
  end;
end;

{ HelpForm }

procedure THelpForm.ShowHelpForm;
begin
  if HelpForm.WindowState<>wsNormal then
    HelpForm.WindowState:=wsNormal;
  HelpForm.Show;
end;

procedure THelpForm.FormCreate(Sender: TObject);
begin
  HelpForm.Caption:='Help';
  TempDir:=GetTempDir(false)+RES_DIR+DS;
  ExtractResources;
end;
procedure THelpForm.FormDestroy(Sender: TObject);
begin
  DeleteResources;
end;
procedure THelpForm.HTMLGetImageX(Sender: TIpHtmlNode; const URL: string;
          var Picture: TPicture);
var
  PicCreated: boolean;
begin
  try
    if FileExistsUTF8(TempDir+URL) then
      begin
        PicCreated := False;
        if Picture = nil then
          begin
            Picture := TPicture.Create;
            PicCreated := True;
          end;
        Picture.LoadFromFile(TempDir+URL);
      end;
  except
    if PicCreated then
      Picture.Free;
    Picture := nil;
  end;
end;
procedure THelpForm.IpHtmlPanel1HotClick(Sender: TObject);
var
  NodeA : TIpHtmlNodeA;
  i: integer;
  s: string;
  anchor, filename: string;
begin
  if IpHtmlPanel1.HotNode is TIpHtmlNodeA then
    begin
      NodeA := TIpHtmlNodeA(IpHtmlPanel1.HotNode);
      s:=Trim(NodeA.HRef);
      i:=Pos('#',s);
      if i=0 then begin
        if FileExists(TempDir+s) then
          OpenFile(TempDir+s)
        else
          OpenResource(s);
      end
      else if i=1 then begin
        anchor:=Copy(s,2,MaxInt);
        IpHtmlPanel1.MakeAnchorVisible(anchor);
      end else begin
        filename:=Trim(Copy(s,1,i-1));
        anchor:=Trim(Copy(s,i+1,MaxInt));
        if FileExists(TempDir+filename) then
          OpenFile(TempDir+filename)
        else
          OpenResource(filename);
        IpHtmlPanel1.MakeAnchorVisible(anchor);
      end;
    end;
end;
procedure THelpForm.OpenFile(const Filename : string);
var
  fs : TFileStream;
  NewHTML : TSimpleIpHtml;
begin
  if not FileExists(Filename) then Exit;
  ShowHelpForm;
  try
    fs := TFileStream.Create(Filename, fmOpenRead);
    try
      NewHTML := TSimpleIpHtml.Create; // Note: will be freed by IpHtmlPanel1
      NewHTML.OnGetImageX := @HTMLGetImageX;
      NewHTML.LoadFromStream(fs);
    finally
      fs.Free;
    end;
    IpHtmlPanel1.SetHtml(NewHTML);
    if SHOW_FILEPATH_IN_HELP_FORM_CAPTION then
      HelpForm.Caption:='Help - '+Filename;
  except
    on E: Exception do
      begin
        MessageDlg('Unable to open HTML file', 'HTML File: ' + Filename + #13 +
                 'Error: ' + E.Message,mtError, [mbCancel], 0);
      end;
  end;
end;
procedure THelpForm.OpenResource(const Resourcename : string);
begin
  if Resources.Count=0 then Exit;
  ShowHelpForm;
  OpenFile(TempDir+Resourcename);
end;
procedure THelpForm.OpenURL(const aURL : string);
begin
  lclintf.OpenURL(aURL);
end;

end.
