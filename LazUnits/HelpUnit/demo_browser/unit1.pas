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


unit unit1;

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, htmlbrowser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnHelp: TButton;
    btnOpen: TButton;
    btnURL: TButton;
    btnFile: TButton;
    btnResource: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnFileClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnResourceClick(Sender: TObject);
    procedure btnURLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  end; 

var
  frmMain: TfrmMain;
  Viewer: THTMLBrowserViewer;

implementation
{$R *.lfm}

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  Viewer.OpenFile(GetCurrentDir+'\res\help.html');
end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    Viewer.OpenFile(OpenDialog1.FileName);
end;

procedure TfrmMain.btnFileClick(Sender: TObject);
begin
  Viewer.OpenFile(GetCurrentDir+'\res\index.html');
end;
procedure TfrmMain.btnResourceClick(Sender: TObject);
begin
  Viewer.OpenResource('index.html');
end;
procedure TfrmMain.btnURLClick(Sender: TObject);
begin
  Viewer.OpenURL('https://www.freepascal.org/');
end;
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Viewer:=THTMLBrowserViewer.Create;
end;
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Viewer.Free;
end;

end.
