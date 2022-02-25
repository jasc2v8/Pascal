unit main;

{$mode objfpc}{$H+}
{$hints off}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ShellCtrls, Buttons, Lclintf,
  Windows, ShellApi;

type
  { TMainForm }

  TMainForm = class(TForm)
    Images: TImageList;
    Panel1: TPanel;
    Panel2: TPanel;
    ShellListView: TShellListView;
    ShellTreeView: TShellTreeView;
    ShellSplitter: TSplitter;
    StatusBar: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure ShellListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ShellListViewClick(Sender: TObject);
    procedure ShellListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ShellListViewDblClick(Sender: TObject);
    procedure ShellListViewFileAdded(Sender: TObject; Item: TListItem);
    procedure ShellTreeViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeViewSelectionChanged(Sender: TObject);
  private
    function GetFileIcon(const aFilename: string): TIcon;
  public
    InitialImageCount: integer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormShow(Sender: TObject);
var
  i: integer;
begin

  {hide any drives that are empty - have to restart if insert CD for example}
  for i := 0 to ShellTreeView.Items.Count-1 do begin
    if not DirectoryExists(ShellTreeView.Items[i].Text) then
      ShellTreeView.Items[i].Visible := false;
  end;

  InitialImageCount:=Images.Count;
end;

procedure TMainForm.ShellListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
const
  LM = '  ';
var
  aStatus: string;
begin
  ShellListView.SortColumn := 0;
  aStatus := LM + ShellListView.Items.Count.ToString + ' items';
  if ShellListView.SelCount >0 then
    aStatus := aStatus + LM + LM + ShellListView.SelCount.ToString + ' selected';
  StatusBar.SimpleText:= aStatus;
end;

procedure TMainForm.ShellListViewClick(Sender: TObject);
var
  fn: String;
begin
  if ShellListView.ItemFocused <> nil then begin
    fn := ShellListView.GetPathFromItem(ShellListView.ItemFocused);
  end;
end;

procedure TMainForm.ShellListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ShellListView.SortColumn := Column.Index;
end;

procedure TMainForm.ShellListViewDblClick(Sender: TObject);
begin
  OpenDocument(ShellListView.GetPathFromItem(ShellListView.ItemFocused));
end;

procedure TMainForm.ShellListViewFileAdded(Sender: TObject; Item: TListItem);
var
  fn: string;
begin
  fn := ShellListView.GetPathFromItem(ShellLIstView.Items[Item.Index]);
  Images.AddIcon(GetFileIcon(fn));
  Item.ImageIndex := Images.Count-1;
end;

procedure TMainForm.ShellTreeViewChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
var
  i: integer;
begin
  for i := Images.Count-1 downto InitialImageCount do begin
    Images.Delete(i);
  end;
end;

procedure TMainForm.ShellTreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  if Node.Level = 0 then
    Node.ImageIndex := 0
  else if Node.Selected then
    Node.ImageIndex := 2
  else
    Node.ImageIndex := 1;
end;

procedure TMainForm.ShellTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  if Node.Level = 0 then
    Node.SelectedIndex := 0
  else if Node.Selected then
    Node.SelectedIndex := 2
  else
    Node.SelectedIndex := 1;
end;

procedure TMainForm.ShellTreeViewSelectionChanged(Sender: TObject);
begin
  if Assigned(ShellTreeView.Selected) and not DirectoryExists(ShellTreeView.Path) then
    ShellTreeView.Selected := nil;
end;

function TMainForm.GetFileIcon(const aFilename: string): TIcon;
var
  aBmp : graphics.TBitmap;
  myIconInfo: TIconInfo;
  SFI: SHFileInfo;
begin
  Result := TIcon.Create;
  if SHGetFileInfo(PChar(aFilename), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(SHFileInfo),
    SHGFI_SMALLICON or SHGFI_ICON)<>0 then begin
    if (sfi.hIcon <> 0) and (GetIconInfo(sfi.hIcon, myIconInfo)) then begin
      aBmp := graphics.TBitmap.Create;
      aBmp.LoadFromBitmapHandles(myIconInfo.hbmColor, myIconInfo.hbmMask, nil);
      Result.Assign(aBMP);
      aBmp.Free;
    end;
  end;
end;

end.

