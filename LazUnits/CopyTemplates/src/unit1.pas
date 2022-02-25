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
  FileCtrl, EditBtn, strutils, lclintf, LCLType, fileutilwin, htmlbrowser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnHelp: TButton;
    btnOpen: TButton;
    btnSave: TButton;
    DirectoryEdit: TDirectoryEdit;
    ListBox: TListBox;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    procedure btnHelpClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure DirectoryEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;
const
  DS=DirectorySeparator;
  LE=LineEnding;
var
  frmMain: TfrmMain;
  Viewer: THTMLBrowserViewer;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  //lclintf.OpenURL('help.html');
  Viewer.OpenResource('help.html');
end;
function DirectoryIsEmpty(Directory: string): Boolean;
var
  aList: TStringList;
  SR: TSearchRec;
  i: Integer;
begin
  Result:=False;
  aList:=TStringList.Create;
  aList:=FindAllFiles(Directory,'*', False);
  if aList.Count=0 then Result:=True;
  aList.Free;
end;
procedure TfrmMain.DirectoryEditChange(Sender: TObject);
var
  i: integer;
  Dir: string;
  DirList: TStringList;
  aName: string;
begin
  ListBox.Clear;
  Dir:=IncludeTrailingPathDelimiter(DirectoryEdit.Directory);
  DirList:=TStringList.Create;
  DirList:=FindAllDirectories(Dir, False);
  For i:=DirList.Count-1 downto 0 do begin
    aName:=ExtractFilename(DirList[i]);
    if not UpperCase(ExtractFilename(DirList[i])).StartsWith('TEMPLATE') then begin
      DirList.Delete(i);
    end;
  end;
  if DirList.Count=0 then
    ListBox.Items.Add('No templates found in this directory.')
  else
    ListBox.Items.Assign(DirList);
  ListBox.ItemIndex:=0;
  DirList.Free;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Viewer.Free;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  i: integer;
  Reply: integer;
  SourceDir, TargetDir: string;
begin

  if ListBox.Count=0 then Exit;

  if SelectDirectoryDialog.Execute then
    TargetDir:=SelectDirectoryDialog.FileName
  else
    Exit;

  if not DirectoryIsEmpty(TargetDir) then begin
    if QuestionDlg(Application.Title,'Directory is Not Empty, Overwrite?',
      mtWarning,[mrYes,'&Yes',mrNo,'&No','IsDefault'],0) <>IDYES then Exit;
  end;

  for i:=0 to ListBox.Count-1 do begin

    if not ListBox.Selected[i] then
      Continue;

    SourceDir:=ExpandFileName(ListBox.Items[i]);

    if CopyDirWin(SourceDir, TargetDir) then
      ShowMessage('Template saved to:'+LE+LE+TargetDir)
    else
      ShowMessage('Error saving Template');
  end;
end;
procedure TfrmMain.btnOpenClick(Sender: TObject);
begin
  if ListBox.Count=0 then Exit;
  OpenDocument(Listbox.Items[Listbox.ItemIndex]);
end;
procedure TfrmMain.FormShow(Sender: TObject);
begin
  Viewer:=THTMLBrowserViewer.Create;
  Viewer.ExtractResFiles;
  DirectoryEdit.Directory:=GetCurrentDir;
  //DirectoryEditChange(nil);
  if ListBox.Count=0 then
    ShowMessage('Error no templates found');
end;
end.
