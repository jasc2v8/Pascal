unit findonline;

{softpedia returns the following examples, need to test for each:
  file name 0.0.0
  file name 0.0.0 / 0.0.0 Beta
  file name 0.0.0 Build 0
  file name 0.0.0 r0
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TFindOnline }

  TFindOnline = class(TThread)
  private
    FStatus: string;
    FTitle: string;
    procedure Update;
    procedure OnTerminate;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    property Status: string Read FStatus Write FStatus;
    property Title: string Read FTitle Write FTitle;
  end;

implementation

uses main, fphttpclient, strutils;

{ TFindOnline }

procedure TFindOnline.OnTerminate;
begin
  frmMain.UpdateGrid(colOnlineVer);
  frmMain.StatusBar.SimpleText:='Ready';
end;

procedure TFindOnline.Update;
begin
  frmMain.StatusBar.SimpleText:=Status;
end;

procedure TFindOnline.Execute;
const
  SEARCH='http://www.softpedia.com/dyn-search.php?search_term=';
  TAG1='<h4 class="ln"><a href="';
  TAG2='title="';
  END2='">';
  STATUS_MESSAGE='Get Online Version: ';
var
  ipos: integer;
  buf, sname, snameurl, stemp, surl, sver: String;
  web: TFPHTTPClient;
  istart, iend, ilen: integer;
begin
  if Terminated then exit;

  sname:=Title;
  snameurl:=StringsReplace(sname, [' '], ['%20'],[rfReplaceAll, rfIgnoreCase]);

  Status:=STATUS_MESSAGE+sname;
  Synchronize(@Update);

  surl:=SEARCH+snameurl;

  try
    try
      web:=TFPHTTPClient.Create(nil);
      web.AddHeader('User-Agent', 'Mozilla/5.0');
      buf:=web.Get(surl);
    except
      {ignore error, user sees sver='?'}
    end;
  finally
    web.free;
  end;

  istart:=Pos(TAG1, buf);

  if istart=0 then begin
    sver:='?';
    end
  else begin
    iend:=istart+((TAG1.Length+surl.Length)*2);
    ilen:=iend-istart;
    buf :=MidStr(buf,istart,ilen);

    istart:=Pos(TAG2, buf)+TAG2.Length;
    ilen  :=buf.Length;
    buf   :=MidStr(buf,istart,ilen);

    istart:=1;
    iend  :=Pos(END2, buf);
    ilen  :=iend-istart;
    stemp :=Trim(MidStr(buf,istart,ilen));

    ipos:=Pos('Build',stemp);
    if ipos<>0 then
      stemp:=Trim(LeftStr(stemp,ipos));

    ipos:=Pos('Beta',stemp);
    if ipos<>0 then begin
      sname:=Trim(LeftStr(stemp,sname.Length));
      sver:=Trim(MidStr(stemp,sname.Length+2,stemp.Length));
      end
    else begin
      ipos:=stemp.LastIndexOf(' ');
      sver:=MidStr(stemp,ipos+2,stemp.Length);
      if (LeftStr(sver,1)<Char('0')) or (LeftStr(sver,1)>Char('9')) then begin
        stemp:=Trim(LeftStr(stemp,ipos));
        ipos:=stemp.LastIndexOf(' ');
        sver:=MidStr(stemp,ipos+2,stemp.Length);
      end;
    end;
    gOnlList.Add(sname+'|'+sver);
  end;

  gOnlList.Sort;
  Synchronize(@OnTerminate);
end;

constructor TFindOnline.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
end;


end.

