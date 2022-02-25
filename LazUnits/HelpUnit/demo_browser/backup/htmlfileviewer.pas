{ TODO:

property ShowFilenameInCaption: boolean;
property ShowFilenameWithoutExtInCaption: boolean;

}

{ from http://pp4s.co.uk/main/tu-form2-help-demo-laz.html }

unit htmlfileviewer;

{$mode objfpc}{$H+}

{$R htmlfileviewer.rc} //comment out if no resources used

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  FileUtil, IpHtml, LazFileUtils, lclintf, LazHelpHTML,
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
    procedure HTMLGetImageX(Sender: TIpHtmlNode;const URL: string;var Picture: TPicture);
    procedure IpHtmlPanel1HotClick(Sender: TObject);
    function GetResTemp: string;
    procedure ExtractResources;
    procedure DeleteExtractedResources;

    private
      ResDir: string;
      Resources: TStringList;
    public
      procedure OpenFile(const Filename: string);
      procedure OpenResource(const Resourcename : string);
      procedure OpenURL(const aURL : string);
  end;

const
  DS=DirectorySeparator;


var
  HelpForm: THelpForm;

implementation

{$R *.lfm}

{ Resources }

function THelpForm.GetResTemp: string;
begin
  Result:=GetTempDir(false)+'res-htmlfileviewer'+DS;
end;
procedure THelpForm.DeleteExtractedResources;
var
  i: integer;
  f: string;
begin
  try
    for i:=0 to Resources.Count-1 do begin
      f:=GetResTemp+Resources.ValueFromIndex[i];
      if FileExists(f) then sysutils.DeleteFile(f);
    end;
    if DirectoryExists(GetResTemp) then
      RemoveDir(GetResTemp);
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
    //S:=TResourceStream.Create(HInstance, 'res', RT_RCDATA);
    S:=TResourceStream.Create(HInstance, 'htmlfileviewer', PChar(600));
  except

    ShowMessage('debug error reading resources');

    Exit;
  end;

  try
    buff.LoadFromStream(S);
    for i:=1 to buff.Count-1 do begin
      //ResName:=Trim(Copy(buff[i],1,Pos('RCDATA',buff[i])-2));
      ResName:=Trim(Copy(buff[i],1,Pos('600',buff[i])-2));
      q1:=buff[i].IndexOf('"');
      ResValue:=Trim(Copy(buff[i],q1+2,buff[i].Length-q1-2));

      if ResName<>'' then begin
        Resources.Add(ResName+'='+ExtractFileName(ResValue));
        //ShowMessage('debug file ResName='+ResName+', ResValue='+ResValue);
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
      S:=TResourceStream.Create(HInstance, Resources.Names[i], PChar(600));
      S.SaveToFile(GetResTemp+Resources.ValueFromIndex[i]);
      FreeAndNil(S);
    end;
  finally
    FreeAndNil(S);
  end;
end;

{ HelpForm }

procedure THelpForm.FormCreate(Sender: TObject);
begin
  ResDir:=GetResTemp;
  ExtractResources;
end;
procedure THelpForm.FormDestroy(Sender: TObject);
begin
  DeleteExtractedResources;
end;
procedure THelpForm.HTMLGetImageX(Sender: TIpHtmlNode; const URL: string;
          var Picture: TPicture);
var
  PicCreated: boolean;
begin
  try
    if FileExistsUTF8(ResDir+URL) then
      begin
        PicCreated := False;
        if Picture = nil then
          begin
            Picture := TPicture.Create;
            PicCreated := True;
          end;
        Picture.LoadFromFile(ResDir+URL);
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
        if FileExists(ResDir+s) then
          OpenFile(ResDir+s)
        else
          OpenResource(s);
      end
      else if i=1 then begin
        anchor:=Copy(s,2,MaxInt);
        IpHtmlPanel1.MakeAnchorVisible(anchor);
      end else begin
        filename:=Trim(Copy(s,1,i-1));
        anchor:=Trim(Copy(s,i+1,MaxInt));
        if FileExists(ResDir+filename) then
          OpenFile(ResDir+filename)
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
  HelpForm.Show;
  ResDir:=ExtractFilePath(Filename);
  try
    fs := TFileStream.Create(Filename, fmOpenRead);
    try
      NewHTML := TSimpleIpHtml.Create; // Note: Will be freed by IpHtmlPanel1
      NewHTML.OnGetImageX := @HTMLGetImageX;
      NewHTML.LoadFromStream(fs);
    finally
      fs.Free;
    end;
    IpHtmlPanel1.SetHtml(NewHTML);
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
  HelpForm.Show;
  OpenFile(GetResTemp+Resourcename);
end;
procedure THelpForm.OpenURL(const aURL : string);
begin
  // browser lclintf.OpenURL(aURL);
  IpHtmlPanel1.OpenURL(aURL);
end;

end.
