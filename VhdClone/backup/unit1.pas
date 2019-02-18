unit Unit1;

{
Program:  VhdCopy
Function: Copy vhd and set GUUID
Language: Pascal - Lazarus
Author:   jasc2v8
Created:  2/17/2018
Updated:  .

Version History
1.0.0 Initial release
      fixed memory leak with AProcess.Free
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ComCtrls, ExtCtrls, EditBtn, LazUTF8, Process, DateUtils,
  threadunit, ShellApi;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnExploreTo: TButton;
    ButtonRefresh: TButton;
    ButtonClone: TButton;
    BtnExploreFrom: TButton;
    ButtonUUID: TButton;
    DirEditFrom: TDirectoryEdit;
    DirEditTo: TDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    procedure BtnExploreToClick(Sender: TObject);
    procedure ButtonCloneClick(Sender: TObject);
    procedure BtnExploreFromClick(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ButtonUUIDClick(Sender: TObject);
    procedure DirEditFromAcceptDirectory(Sender: TObject; var Value: String);
    procedure DirEditFromEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1StartTimer(Sender: TObject);

  private
    procedure DoChangeUUID;
    procedure DoClone;
    procedure DoRefresh;

  public
    OpenFileName, SaveFileName: string;
    Running, Aborting: boolean;
    Thread1: TThreadUnit;

  end;

const
  DS=DirectorySeparator;
  LE=LineEnding;
  VBManageUnix = '/usr/lib/virtualbox/VBoxManage.exe';
  VBManageWin32 = '"C:\Program Files (x86)\Oracle\VirtualBox\VboxManage.exe"';
  VBManageWin64 = '"C:\Program Files\Oracle\VirtualBox\VboxManage.exe"';
var
  Form1: TForm1;
  AProcess: TProcess;
threadvar
  ThreadsRunningCount: integer;

implementation

//Uses Windows, InterfaceBase;

{$R *.lfm}

function PadString(aString: string; aPadchar: string; aLength: integer): string;
begin
  while Length(aString)<aLength do begin
    aString:=aString+aPadchar;
  end;
  Result:=aString;
end;

{ TForm1 }

procedure TForm1.Timer1StartTimer(Sender: TObject);
begin
  If Not Application.Active then
    FlashWindow(WidgetSet.AppHandle, True);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption:=Application.Title;
end;

procedure TForm1.ButtonCloneClick(Sender: TObject);
begin
  DoClone;
end;

procedure TForm1.BtnExploreFromClick(Sender: TObject);
begin
  ShellExecute(0,'open',PChar(DirEditFrom.Text),nil,nil,1);
end;

procedure TForm1.BtnExploreToClick(Sender: TObject);
begin
  ShellExecute(0,'open',PChar(DirEditTo.Text),nil,nil,1);
end;

procedure TForm1.ButtonRefreshClick(Sender: TObject);
begin
  DoRefresh;
end;

procedure TForm1.ButtonUUIDClick(Sender: TObject);
begin
  DoChangeUUID;
end;

procedure TForm1.DirEditFromAcceptDirectory(Sender: TObject; var Value: String);
begin
  DirEditFrom.Text:=Value;
  DirEditTo.Text:=Value;
  DoRefresh;
end;

procedure TForm1.DirEditFromEditingDone(Sender: TObject);
begin
  DirEditTo.Text:=DirEditFrom.Text;
  DoRefresh;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  DirEditFrom.Text:=GetCurrentDir;
  DirEditTo.Text:=GetCurrentDir;
  DoRefresh;
end;

procedure TForm1.DoChangeUUID;
var
  i: integer;
  params: array[0..3] of string;
begin
  ThreadsRunningCount:=0;

  For i:=0 to ListBox1.Count-1 do begin
    if ListBox1.Selected[i] then begin

      params[0]:=VBManageWin64;
      params[1]:='internalcommands';
      params[2]:='setuuid';
      params[3]:=ListBox1.Items[i];

    if FileExists(params[3]) then begin
      //DO NOTHING
    end;

    ListBox1.Items[i]:=PadString(ListBox1.Items[i],'*',90)+'CHANGING UUID...';

    Thread1:=TThreadUnit.Create(i, params, False);
    Inc(ThreadsRunningCount);
    ProgressBar1.Style:=pbstMarquee;
    ProgressBar1.Visible:=True;
    end;
  end;
end;

procedure TForm1.DoClone;
var
  i: integer;
  params: array[0..3] of string;
begin
  ThreadsRunningCount:=0;

  For i:=0 to ListBox1.Count-1 do begin
    if ListBox1.Selected[i] then begin
      params[0]:=VBManageWin64;
      params[1]:='clonehd';
      params[2]:=ListBox1.Items[i];
      params[3]:=DirEditTo.Text+DS+ExtractFileName(ListBox1.Items[i])+'_CLONED.vhd';

      if FileExists(params[3]) then begin
        RenameFile(params[3], params[3]+'.BAK');
        DeleteFile(params[3]);
      end;

      ListBox1.Items[i]:=PadString(ListBox1.Items[i],'*',90)+'CLONING...';
      Thread1:=TThreadUnit.Create(i, params, False);
      Inc(ThreadsRunningCount);

      ProgressBar1.Style:=pbstMarquee;
      ProgressBar1.Visible:=True;
    end;
  end;
end;

procedure TForm1.DoRefresh;
var
  VhdFiles: TStringList;
begin
  ListBox1.Clear;
  Application.ProcessMessages;
  Sleep(250);
  try
    VhdFiles:=TStringList.Create;
    FindAllFiles(VhdFiles, DirEditFrom.Text, '*.hdd;*.vdi;*.vhd;*.vmdk', false);
    ListBox1.Items:=VhdFiles;
  finally
    VhdFiles.Free;
  end;
end;

end.

