unit main;

{$mode objfpc}{$H+}

{ version history:
  1.0.2 fixed memory leaks by freeing buf32 and FileVerInfo
  1.0.1 enhancements: improve check updates, change to run as administrator
  1.0.0 initial release
}

interface

uses
  Classes, SysUtils, FileUtil, Forms, popup, Controls, Graphics, Dialogs, Grids,
  StdCtrls, Menus, ComCtrls, registry, strutils, LazFileUtils, fileinfo, winpeimagereader,
  LCLType, lclintf, lazutf8,process, ShellApi, debugHelper, cpu;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    MenuItem1: TMenuItem;
    miRename: TMenuItem;
    miUpdate: TMenuItem;
    MenuItem10: TMenuItem;
    miUpdateInstall: TMenuItem;
    miArchive: TMenuItem;
    miExplore: TMenuItem;
    miProperties: TMenuItem;
    miDownload: TMenuItem;
    miGetOnlineVersions: TMenuItem;
    mMain: TMainMenu;
    miFile: TMenuItem;
    miFileOpen: TMenuItem;
    miRestart: TMenuItem;
    miQuit: TMenuItem;
    miSpacer1: TMenuItem;
    miFileSave: TMenuItem;
    miHelp: TMenuItem;
    miOnlineHelp: TMenuItem;
    miInstall: TMenuItem;
    miAbout: TMenuItem;
    miSpacer2: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    miSelectAll: TMenuItem;
    mPopup: TPopupMenu;
    SaveDialog: TSaveDialog;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    StatusBar: TStatusBar;
    Grid: TStringGrid;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miDownloadClick(Sender: TObject);
    procedure miFileOpenClick(Sender: TObject);
    procedure miGetOnlineVersionsClick(Sender: TObject);
    procedure miInstallClick(Sender: TObject);
    procedure miOnlineHelpClick(Sender: TObject);
    procedure miQuitClick(Sender: TObject);
    procedure miRenameClick(Sender: TObject);
    procedure miRestartClick(Sender: TObject);
    procedure miFileSaveClick(Sender: TObject);
    procedure miUpdateClick(Sender: TObject);
    procedure miUpdateInstallClick(Sender: TObject);
    procedure miArchiveClick(Sender: TObject);
    procedure miExploreClick(Sender: TObject);
    procedure miPropertiesClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    
    procedure SelectAll;
    procedure Start;
    procedure ShowStatus(aString: string);
    procedure GetLibraryList;
    procedure GetInstalledList;
    procedure CheckFileNames(aList: TStringList);
    procedure CheckUpdates;
    procedure LoadGrid;
    procedure UpdateGrid(column: integer);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private

  public
    gFirstActivation: boolean;
  end;

const

  {set debug flag}
  gDEBUG=false;

  colCategory=0; colLibName=1; colInsVer=2;
  colLibVer=3; colUpdVer=4; colOnlineVer=5;
  DS=DirectorySeparator;
  LE=LineEnding;
  {$ifdef WIN32}
    ThisExeIs32bit=true;
  {$else}
    ThisExeIs32bit=false;
  {$endif}

var
  frmMain: TfrmMain;
  gLibList, gInsList, gUpdList, gOnlList: TStringList;
  gLibDir: string;

  {interface for findonline}
  function ExtractLibFileName(spath: string): string;

implementation

{$R *.lfm}

uses findonline;

var FindOnlineThread: TFindOnline;

function MessageDlgEx(const aCaption: string; const AMsg: string; ADlgType: TMsgDlgType;
  AButtons: TMsgDlgButtons; AParent: TForm): TModalResult;
var
  MsgFrm: TForm;
begin
  MsgFrm := CreateMessageDialog(AMsg, ADlgType, AButtons);
  try
    MsgFrm.Caption:=aCaption;
    MsgFrm.Position := poDefaultSizeOnly;
    MsgFrm.FormStyle := fsSystemStayOnTop;
    MsgFrm.Left := AParent.Left + (AParent.Width - MsgFrm.Width) div 2;
    MsgFrm.Top := AParent.Top + (AParent.Height - MsgFrm.Height) div 2;
    Result := MsgFrm.ShowModal;
  finally
    MsgFrm.Free
  end;
end;

function ShowProperties(sLibPath: string): integer;
var
  sMsg: string;
  FileVerInfo: TFileVersionInfo;
begin

  FileVerInfo:=TFileVersionInfo.Create(nil);
  FileVerInfo.FileName:=sLibPath;

  try
    FileVerInfo.ReadFileInfo;
    sMsg:=
    'Company              : '+FileVerInfo.VersionStrings.Values['CompanyName']+LE+
    'File description     : '+FileVerInfo.VersionStrings.Values['FileDescription']+LE+
    'File version            : '+FileVerInfo.VersionStrings.Values['FileVersion']+LE+
    'Internal name       : '+FileVerInfo.VersionStrings.Values['InternalName']+LE+
    'Legal copyright    : '+FileVerInfo.VersionStrings.Values['LegalCopyright']+LE+
    'Original filename : '+FileVerInfo.VersionStrings.Values['OriginalFilename']+LE+
    'Product name      : '+FileVerInfo.VersionStrings.Values['ProductName']+LE+
    'Product version   : '+FileVerInfo.VersionStrings.Values['ProductVersion']+LE+LE+
    '(Ctrl-C to copy text above)';
  except
    sMsg:='Error reading file information';
  end;

  FreeAndNil(FileVerInfo);

  Result:=MessageDlgEx('Properties',sLibPath+LE+LE+sMsg,mtCustom,[mbOK,mbCancel],frmMain);

end;

function GetWindowsBits: string;
begin
  Result:='64';
  if (GetEnvironmentVariable('PROGRAMFILES(x86)').IsEmpty) then
    Result:='32';
end;

function ThisExeIs32bitOn64bitWindows: boolean;
begin
  Result:=false;
  if (ThisExeIs32bit) and (GetWindowsBits='64') then
    Result:=true;
end;

procedure GetKeyList(aKey: string; out aList: TStringList);
var
 reg: TRegistry;
 buf: TStringList;
 i: integer;
 sname, sversion: string;
begin
  buf:=TStringList.Create;

  reg:=TRegistry.Create;
  reg.RootKey:=HKEY_LOCAL_MACHINE;

  if ThisExeIs32bitOn64bitWindows then
    reg.Access := KEY_READ or KEY_WOW64_64KEY;

  try
    reg.OpenKeyReadOnly(aKey);
    reg.GetKeyNames(buf);
    reg.CloseKey;

    for i:=0 to buf.Count-1 do begin
      reg.OpenKeyReadOnly(aKey+buf[i]);
      sname:=reg.ReadString('DisplayName');
      sversion:=reg.ReadString('DisplayVersion');
      if (not sname.IsEmpty) then
        aList.Append(sname+' '+sversion);
      reg.CloseKey;
    end;
  finally
    reg.Free;
    buf.Free;
  end;
end;

function ExtractOnlineFileName(spath: string): string;
{Softpedia returns: 'filename version.ext' or 'filename version / beta.ext'}
var
  sfile: string;
  ipos: integer;
begin
  sfile:=ExtractFileNameWithoutExt(ExtractFileName(spath));
  ipos:=sfile.LastIndexOf('/');
  if ipos<>-1 then begin
    sfile:=Trim(LeftStr(sfile,ipos));
    Result:=LeftStr(sfile,ipos);
  end;
  ipos:=sfile.LastIndexOf(' ');
  if ipos<>-1 then begin
    sfile:=Trim(LeftStr(sfile,ipos));
    Result:=LeftStr(sfile,ipos);
  end;
end;

function ExtractLibCategory(spath: string): string;
var sdir: string;
begin
  sdir:=ExtractFileDir(spath);
  Result:=MidStr(sdir, sdir.LastIndexOf('\')+2, sdir.Length);
end;

function ExtractLibFileName(spath: string): string;
var
  ipos: integer;
begin
  spath:=ExtractFileName(spath);
  ipos:=spath.LastIndexOf(' ');
  Result:=LeftStr(spath,ipos);
end;

function ExtractLibVersion(spath: string): string;
var
  sversion: string;
  i, ispace: integer;
begin
  ispace:=spath.LastIndexOf(' ');

  if ispace=-1 then begin
    Result:='';
    exit;
  end;

  sversion:=MidStr(spath,ispace+2,spath.Length);

  sversion:=StringsReplace(sversion,['v'],[''],[rfReplaceAll]);

  ispace:=sversion.LastIndexOf('.');

  if ispace>0 then begin
    sversion:=LeftStr(sversion,ispace);
  end;

  for i:=1 to sversion.Length do begin
    if (MidStr(sversion,i,1)<>'.') and 
       ( (MidStr(sversion,i,1)>Char('9')) or
         (MidStr(sversion,i,1)<Char('0')) ) then begin
      Result:='';
      exit;
    end;
  end;
  Result:=sversion;
end;

procedure FindInList(aList: TStringlist; aSearch: string;
            out iFound: integer; out aFound: string);

  function Mash(aString: string): string;
  begin
    Mash:=StringsReplace(aString, [' '], [''], [rfReplaceAll, rfIgnoreCase]);
  end;

  var
    i: integer;
  begin
    iFound:=-1;
    aFound:='';
    for i:=0 to aList.Count-1 do begin
      if AnsiContainsText(Mash(aList[i]), Mash(aSearch)) then begin
        iFound:=i;
        aFound:=aList[i];
        break;
      end;
    end;
end;  

function IsInList(aList: TStringList; searchText: string): boolean;
var
  i: integer;
begin
  Result:=false;
  for i:=0 to aList.Count-1 do begin
    if AnsiContainsText(aList[i], searchText) then begin
      Result:=true;
      exit;
    end;
  end;
end;

procedure FindNameGetVersion(
            aStringList: TStringlist;
            astring: string;
            out aversion: string);
var
  i: integer;
begin
  aversion:='';
  for i:=0 to aStringList.Count-1 do begin
    if AnsiContainsText(aStringList[i], astring) then begin
      aversion:=ExtractLibVersion(aStringList[i]);
      break;
    end;
  end;
end;

procedure FindNameGetOnlineVersion(
            aStringList: TStringlist;
            astring: string;
            out aversion: string);
var
  i,ipos: integer;
  stemp: string;
begin
  aversion:='';
  for i:=0 to aStringList.Count-1 do begin
    if AnsiContainsText(aStringList[i], astring) then begin
      stemp:=aStringList[i];
      ipos:=stemp.LastIndexOf('|');
      if ipos<>-1 then begin
        aversion:=Trim(MidStr(stemp,ipos+2,stemp.Length));
        break;
      end;
      ipos:=stemp.LastIndexOf('|');
      if ipos=-1 then begin
        aversion:='?';
        break;
      end
    end;
  end;
end;

function MoveFile(sSource: string; sTarget: string): boolean;
begin
  if CopyFile(sSource, STarget, [cffOverwriteFile]) then begin
    DeleteFileUTF8(sSource);
    Result:=true;
  end
  else begin
    ShowMessage('Error Copying: '+sSource);
    Result:=false;
  end; 
end;

{ TfrmMain }

procedure TfrmMain.SelectAll;
var
  orect: TGridRect;
begin
  orect.Top:=1;
  orect.Bottom:=Grid.RowCount-1;
  orect.Left:=0;
  orect.Right:=Grid.ColCount;
  Grid.Selection:=orect;
  //ShowStatus('Ready: '+Grid.RowCount.toString+' files selected');
end;

procedure TfrmMain.ShowStatus(aString: string);
begin
    StatusBar.Simpletext:=aString;
end;

procedure TfrmMain.GetLibraryList;
{find library files in gLibDir, then load in gLibList and gUpdList}
var
  i: integer;
  allFiles: TStringList;
begin
  
  ShowStatus('Getting List of Library Files...');
  Application.ProcessMessages;
  
  allFiles:=TStringList.Create;
  
  FindAllFiles(allFiles, gLibDir, '*.exe;*.msi', true);
  
  for i:=0 to allFiles.Count-1 do begin
    if allFiles[i].Contains('\Updates') then
      gUpdList.Add(allFiles[i])
    else begin
      if not allFiles[i].Contains('BulkInstallUtility.exe') and
         not allFiles[i].Contains('\Archive')then begin
           gLibList.Add(allFiles[i]);
         end;
    end;
  end;
  allFiles.Free;
  gLibList.Sort;
  gUpdList.Sort;
end;

procedure TfrmMain.GetInstalledList;
{find installed programs with uninstall keys in registry, add name+version to gUnInsList}
const
  Key32on64bit='Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\';
  Key32or64bit='Software\Microsoft\Windows\CurrentVersion\Uninstall\';
var
  buf, buf32: TStringList;
  i, i1, i2: Integer;
  sitem, sname, sversion: string;
begin
  buf:=TStringList.Create;
  buf32:=TStringList.Create;

  GetKeyList(Key32on64bit, buf32);
  GetKeyList(Key32or64bit, buf);

  buf.AddStrings(buf32);

  for i:=0 to buf.Count-1 do begin

    {exclude Microsoft and Windows programs}
    if (Pos('Microsoft',buf[i])=1) or
       (Pos('Security Update',buf[i])=1) or
       (Pos('Service Pack',buf[i])=1) or
       (Pos('Update for',buf[i])=1) or
       (Pos('WinRT',buf[i])=1) or
       (Pos('Windows',buf[i])=1) then
      Continue;

    {remove (notes in parenthesis)}
    i1:=Pos('(',buf[i]);
    if i1<>0 then begin
      i2:=Pos(')',buf[i]);
      sitem:=Trim(LeftStr(buf[i],i1-2)+MidStr(buf[i],i2+1,buf[i].Length));
      end
    else
      sitem:=Trim(buf[i]);

    {deconstruct file name and version, strip out 'v' in version, re-construct}
    sitem:=sitem+'.ext';
    sname:=ExtractLibFileName(sitem);
    sversion:=ExtractLibVersion(sitem);
    sversion:=StringsReplace(sversion, ['v'], [''],[rfReplaceAll, rfIgnoreCase]);
    sitem:=sname+' '+sversion+'.ext';

    gInsList.Add(sitem);

  end;

  gInsList.Sort;

  buf.Free;
  buf32.Free;
end;

procedure TfrmMain.CheckUpdates;
{if a file is in Updates, but not in a category, prompt to move to a category}
var
  i, reply: integer;
  spath, sFileName, sLibFileName: string;

begin

  for i:=0 to gUpdList.Count-1 do begin
    
    spath:=gUpdList[i];
    sFileName:=ExtractFileName(spath);
    sLibFileName:=ExtractLibFileName(spath);

    if not IsInList(gLibList, sLibFileName) then begin

      reply:=MessageDlg('Check Updates',
            'Not  in Library: '+sFileName+LE+LE+
            'Move to Library?', mtConfirmation,
            [mbYes,mbNo,mbCancel],'');

      if reply=mrCancel then exit;

      if reply=mrNo then continue;

      SaveDialog.InitialDir:=gLibDir;
      SaveDialog.FileName:=spath;

      if frmMain.SaveDialog.Execute then begin

        FileUtil.CopyFile(spath, SaveDialog.Filename);
        DeleteFile(spath);
        gLibList.Add(SaveDialog.FileName);
        gLibList.Sort;

        gUpdList.Delete(i);
        gUpdList.Add('');
        gUpdList.Sort;
      end;
    end;
  end;
end;  

procedure TfrmMain.CheckFileNames(aList: TStringList);
{ check files for proper format: "file name 0.0.0" }
var
  i: integer;
  sfile, spath, sdir, sname, sversion, scategory: string;

begin
  
  for i:=0 to aList.Count-1 do begin
    
    spath:=aList[i];
 
    sname:=ExtractLibFileName(spath);
    scategory:=ExtractLibCategory(spath);
    sversion:=ExtractLibVersion(spath);

    if sname.isEmpty or sversion.isEmpty or scategory.isEmpty then begin

      sdir:=ExtractFileDir(spath);  
      sfile:=ExtractFileName(spath);
    
      //Sentence case, replace certain chars with a single space
      sfile:=UpperCase(LeftStr(sfile,1))+RightStr(sfile,sfile.Length-1);
      sfile:=StringsReplace(sfile, ['_v','_','-'], [' ',' ',' '],[rfReplaceAll, rfIgnoreCase]);
      sfile:=CreateAbsolutePath(sfile,sdir);

      frmPopup.Caption:='Rename Library File';
      frmPopup.LabeledEdit1.EditLabel.Caption:=
        'Improper Filename in Library, should be: ''file name 0.0.0.exe'':';
      frmPopup.LabeledEdit1.Caption:=spath;
      frmPopup.LabeledEdit2.Caption:=sfile;
      frmPopup.LabeledEdit2.Show;

      if (frmPopup.ShowModal=mrCancel) then exit;
        
      if frmPopup.Edit2Text='' then
        ShowMessage('Error did not enter new filename for : '+LE+LE+frmPopup.Edit1Text)
      else begin
         if not RenameFileUTF8(frmPopup.Edit1Text, frmPopup.Edit2Text) then
           ShowMessage('Error renaming file: '+frmPopup.Edit2Text)
         else begin
           aList.Delete(i);
           aList.Add(frmPopup.Edit2Text);
           aList.Sort;
         end;
      end;    
    end;
  end;
end; 
 
procedure TfrmMain.LoadGrid;
{load in StringGrid}
{todo: if online versions exist, save before clearding grid, then restore?}
var
 i: integer;
 spath, sname, sUpdVer, sInsVer: string;
begin

  Grid.Enabled:=false;

  //delete existing rows, if any
  if Grid.RowCount>1 then begin
    for i:=Grid.RowCount-1 downto 1 do
      Grid.DeleteRow(i);
  end;

  //load gInsList and gUpdList
  for i:=0 to gLibList.Count-1 do begin

    spath:=gLibList[i];
    sname:=ExtractLibFileName(spath);

    FindNameGetVersion(gInsList, sname, sInsVer);
    FindNameGetVersion(gUpdList, sname, sUpdVer);

    Grid.InsertRowWithValues(i+1,[
      ExtractLibCategory(spath),
      ExtractLibFileName(spath),
      sInsVer,
      ExtractLibVersion(spath),
      sUpdVer,
      ''
      ]);        
    end;
    
  {delete last rows that are empty}
  for i:=Grid.RowCount-1 downto 1 do
    if (Grid.Cells[1,i].IsEmpty) then
      Grid.DeleteRow(i);
  Grid.Row:=1;
  Grid.Enabled:=true;
end;

procedure TfrmMain.UpdateGrid(column: integer);
{Load install version from gInsList}
var
 i: integer;
 sname, sInsVer, sOnlineVer: string;
begin
  
  {temporarily prevent user from sorting columns}
  Grid.Enabled:=false;
  
  for i:=1 to Grid.RowCount-1 do begin
      
    sname:=Grid.Cells[colLibName,i];
    
    if column=colInsVer then begin     
      FindNameGetVersion(gInsList, sname, sInsVer);
      if sInsVer.IsEmpty then sInsVer:='?';
      Grid.Cells[column,i]:=sInsVer;
    end;

    if column=colOnlineVer then begin     
      FindNameGetOnlineVersion(gOnlList, sname, sOnlineVer);
      Grid.Cells[column,i]:=sOnlineVer;
    end;

  Grid.Enabled:=true;
  ShowStatus('Ready');
  end;
end;

procedure TfrmMain.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{Ctrl-A handler to select all rows}
begin
  if (Key = vk_A) and (ssCtrl in Shift) then begin
    SelectAll;
  end;
end;   

procedure TfrmMain.FormCreate(Sender: TObject);
begin
 
  if (ParamCount=1) and (DirPathExists(ParamStr(1))) then
    gLibDir:=ParamStr(1)
  else
    gLibDir:=GetCurrentDir;
  
  //if gDEBUG then gLibDir:='d:\BulkLibrary';

  gFirstActivation:=true;

  gLibList:=TStringList.Create;
  gInsList:=TStringList.Create;
  gUpdList:=TStringList.Create;
  gOnlList:=TStringList.Create;
  
  Grid.InsertRowWithValues(1,['','','','','','']);
  
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if gDEBUG then gLibList.SaveToFile('debug_gLibList.txt');
  if gDEBUG then gInsList.SaveToFile('debug_gInsList.txt');
  if gDEBUG then gUpdList.SaveToFile('debug_gUpdList.txt');
  if gDEBUG then gOnlList.SaveToFile('debug_gOnlist.txt');

  gLibList.Free;
  gInsList.Free;
  gUpdList.Free;
  gOnlList.Free;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  MessageDlgEx('About',
    'Bulk Install Utility'+LE+LE+
    'Copyright (C) 2018 by jasc2v8 at gmail dot com'+LE+LE+
    'Developed with Free Pascal and the Lazarus IDE',
    mtCustom,[mbOK],frmMain);
end;

procedure TfrmMain.miDownloadClick(Sender: TObject);
const
  sSearchSite='http://www.softpedia.com/dyn-search.php?search_term=';
var
  sLibName, sSearchName, surl: string;
  orect: TGridRect;
begin
  orect := Grid.SelectedRange[0];
  Grid.Row:=orect.top;
  sLibName:=Grid.Cells[colLibName,orect.top];
  sSearchName:=StringsReplace(sLibName, [' '], ['%20'],[rfReplaceAll, rfIgnoreCase]);
  surl:=sSearchSite+sSearchName;
  OpenURL(surl);
end;

procedure TfrmMain.miFileOpenClick(Sender: TObject);
var
  i, reply: integer;
  lib: string;
begin

  if not SelectDirectoryDialog.Execute then exit;

  lib:=SelectDirectoryDialog.FileName;

  if not lib.Contains('BulkLibrary') then begin
    reply:=MessageDlg(frmMain.Caption,
            'CAUTION: The Selected Folder may not be a'+LE+
            'valid Bulk Library, do you want to continue?', mtConfirmation,
            [mbYes,mbNo],'');
    if reply<>mrYes then exit;
  end;

  gLibDir:=lib;

  for i:=1 to Grid.RowCount-1 do
    Grid.Rows[i].Clear;

  gLibList.Clear;
  gInsList.Clear;
  gUpdList.Clear;
  gOnlList.Clear;

  Start;

end;

procedure TfrmMain.miGetOnlineVersionsClick(Sender: TObject);
var
  i,j: integer;
  orect: TGridRect;
  sName: string;
begin
    for i := 0 to Grid.SelectedRangeCount-1 do begin
      orect := Grid.SelectedRange[i];
      for j:=orect.Top to orect.Bottom do begin
        sName:=Grid.Cells[colLibName,j];
        Grid.Cells[colOnlineVer,j]:='Loading...';
        FindOnlineThread:=TFindOnline.Create(True);
        FindOnlineThread.Title:=sName;
        FindOnlineThread.Start;
        Grid.Columns[ColOnlineVer].Visible:=true;
      end;
    end;
    FreeAndNil(FindOnlineThread);
end;

procedure TfrmMain.miInstallClick(Sender: TObject);
var
  i,j, index: integer;
  bResult: boolean;
  sName, sPath, sExt, sOutput,sVer: string;
  reply: integer;
  orect: TGridRect;

begin
  bResult:=false;

  frmMain.WindowState:=wsMinimized;

  for i := 0 to Grid.SelectedRangeCount-1 do begin
    orect := Grid.SelectedRange[i];
    for j:=orect.Top to orect.Bottom do begin

      sName:=Grid.Cells[colLibName,j];
      FindInList(gLibList,sName,index,sPath);
      sExt:=ExtractFileExt(sPath);
      sVer:=ExtractLibVersion(sPath);

      reply:=MessageDlg(frmMain.Caption,
        'Install '+sName+'?', mtConfirmation, [mbYes,mbNo,mbCancel],'');
      if reply=mrCancel then break;

      if reply=mrYes then begin
        if sExt = '.exe' then
          bResult:=RunCommandInDir(GetCurrentDir,sPath,[],sOutput)
        else
          bResult:=RunCommandInDir(GetCurrentDir, 'msiexec', ['/i', sPath], sOutput);
      end;

      if bResult then
        Grid.Cells[colInsVer,j]:=sVer;
    end;
  end;

  reply:=MessageDlg(frmMain.Caption,
    'Installs Complete, press OK to continue...', mtInformation, [mbOK],'');

  Application.ProcessMessages;
  Sleep(500);
  frmMain.WindowState:=wsNormal
end;

procedure TfrmMain.miOnlineHelpClick(Sender: TObject);
const
  URL='https://github.com/jasc2v8/BulkInstallUtility/blob/master/README.md';
begin
  OpenURL(URL);
end;

procedure TfrmMain.miQuitClick(Sender: TObject);
begin
  frmMain.Close;
end;

procedure TfrmMain.miRenameClick(Sender: TObject);
var
  orect: TGridRect;
  sLibName, sLibPathOld, sLibPathNew, sPath, sName, sExe: String;
  i,j,index: integer;
begin
  for i := 0 to Grid.SelectedRangeCount-1 do begin
    orect := Grid.SelectedRange[i];
    for j:=orect.Top to orect.Bottom do begin

      sLibName:=Grid.Cells[colLibName,orect.top];
      FindInList(gLibList,sLibName,index,sLibPathOld);

      sPath:=ExtractFilePath(sLibPathOld);
      sName:=ExtractFileNameWithoutExt(ExtractFileName(sLibPathOld));
      sExe:=ExtractFileExt(sLibPathOld);

      frmPopup.Caption:='Rename Library File';
      frmPopup.LabeledEdit1.EditLabel.Caption:='Rename from:';
      frmPopup.LabeledEdit2.EditLabel.Caption:='Rename to:';
      frmPopup.LabeledEdit1.Caption:=sName;
      frmPopup.LabeledEdit2.Caption:=sName;
      frmPopup.LabeledEdit2.Show;

      if frmPopup.ShowModal=mrCancel then exit;
      if frmPopup.Edit2Text=frmPopup.Edit1Text then Continue;
      if frmPopup.Edit2Text='' then Continue;

      sName:=frmPopup.Edit2Text;
      sLibPathNew:=sPath+sName+sExe;

      if not RenameFileUTF8(sLibPathOld, sLibPathNew) then
        ShowMessage('Error renaming file: '+frmPopup.Edit2Text)
      else begin
       gLibList[index]:=sLibPathNew;
       Grid.Cells[colLibName,orect.top]:=ExtractLibFileName(sLibPathNew);
       Grid.Cells[colLibVer,orect.top]:=ExtractLibVersion(sLibPathNew);
      end;
    end;
  end;
end;

procedure TfrmMain.miRestartClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
  Close;
end;

procedure TfrmMain.miFileSaveClick(Sender: TObject);
var
  i: integer;
  f: textfile;
  fmt1, fmt2, fmt3, filename: string;

begin

  fmt1 := '%-20s';
  fmt2 := '%-30s';
  fmt3 := '%-15s';

  {open text file}
  filename:='BulkInstallUtility_Save.txt';
  AssignFile(f, filename);
  Rewrite(f);

  {write headers}
  write(f,format(fmt1,['Category']));
  write(f,format(fmt2,['Library Name']));
  write(f,format(fmt3,['Installed']));
  write(f,format(fmt3,['Library']));
  write(f,format(fmt3,['Update']));
  writeln(f,format(fmt3,['Online']));

  {write rows}
  for i := 1 to Grid.RowCount-1 do begin
      write(f,format(fmt1,[Grid.Cells[colCategory,i]]));
      write(f,format(fmt2,[Grid.Cells[colLibName,i]]));
      write(f,format(fmt3,[Grid.Cells[colInsVer,i]]));
      write(f,format(fmt3,[Grid.Cells[colLibVer,i]]));
      write(f,format(fmt3,[Grid.Cells[colUpdVer,i]]));
      writeln(f,format(fmt3,[Grid.Cells[colOnlineVer,i]]));
  end;

  CloseFile(f);

  ShellExecute(0,PChar('open'), PChar(filename),nil,nil,SW_SHOWNORMAL)

end;

procedure TfrmMain.miUpdateInstallClick(Sender: TObject);
begin
  miUpdateClick(self);
  miInstallClick(self);
end;

procedure TfrmMain.miUpdateClick(Sender: TObject);
var
  i, j, iLib, iUpd, reply: integer;
  sLibCat, sLibPath, sLibName, sLibFileName: string;
  sArcPath,sUpdPath,sUpdName,sCatPath: string;
  sSource,sTarget: String;
  orect: TGridRect;
begin
  for i := 0 to Grid.SelectedRangeCount-1 do begin
    orect := Grid.SelectedRange[i];
    for j:=orect.Top to orect.Bottom do begin

      if not Grid.Cells[colUpdVer,j].isEmpty then begin

        {load variables}
        sLibCat:=Grid.Cells[colCategory,j];
        sLibName:=Grid.Cells[colLibName,j];
        FindInList(gLibList, sLibName, iLib, sLibPath);
        sLibFileName:=ExtractFileName(sLibPath);
        sArcPath:=gLibDir+DS+'Archive'+DS+sLibFileName;

        FindInList(gUpdList, sLibName, iUpd, sUpdPath);
        sUpdName:=ExtractFileName(sUpdPath);
        sCatPath:=gLibDir+DS+sLibCat+DS+sUpdName;

        {ask user}
        reply:=MessageDlg(frmMain.Caption,
        'Update '+sUpdName+'?', mtConfirmation, [mbYes,mbNo,mbCancel],'');
        if reply=mrCancel then break;
        if reply<>mrYes then continue;

        {move library file to archive}
        sSource:=sLibPath;
        sTarget:=sArcPath;
        if not MoveFile(sSource, sTarget) then
          break;

        {move updates file to library in the same category}
        sSource:=sUpdPath;
        sTarget:=sCatPath;
        if not MoveFile(sSource, sTarget) then
          break;

        {update Grid libVersion and update version}
        Grid.Cells[colLibVer,j]:=ExtractLibVersion(sTarget);
        Grid.Cells[colUpdVer,j]:='';

        {update gLibList}
        gLibList.Delete(iLib);
        gLibList.Add(sTarget);
        gLibList.Sort;

        {update gUpdList}
        gUpdList.Delete(iUpd);
        gUpdList.Sort;

      end;
    end;
  end;
end;

procedure TfrmMain.miArchiveClick(Sender: TObject);
var
  i,j, iUpd, iLib, reply: integer;
  sLibName, sLibPath, sLibVer, sUpdVer, sUpdPath: string;
  sUpdArcPath, sLibArcPath: string;
  orect: TGridRect;

begin

  for i := 0 to Grid.SelectedRangeCount-1 do begin
    orect := Grid.SelectedRange[i];
    for j:=orect.Top to orect.Bottom do begin

      sLibName:=Grid.Cells[colLibName,j];
      FindInList(gLibList, sLibName, iLib, sLibPath);
      sLibVer:=ExtractLibVersion(sLibPath);

      FindInList(gUpdList, sLibName, iUpd, sUpdPath);
      if iUpd=-1 then sUpdPath:='';

      sLibVer:=Grid.Cells[colLibVer,j];
      sUpdVer:=Grid.Cells[colUpdVer,j];

      sUpdArcPath:=gLibDir+DS+'Archive'+DS+ExtractFileName(sUpdPath);
      sLibArcPath:=gLibDir+DS+'Archive'+DS+ExtractFileName(sLibPath);

      if not sUpdVer.IsEmpty then begin

        reply:=MessageDlg(frmMain.Caption,
            'Archive '+sLibName+' - Update Version?', mtConfirmation,
            [mbYes,mbNo,mbCancel],'');

        if reply=mrCancel then break;

        if reply=mrYes then begin
          if MoveFile(sUpdPath, sUpdArcPath) then begin
            Grid.Cells[colUpdVer,j]:='';
            gUpdList.Delete(iUpd);
            gUpdList.Sort;
            LoadGrid;
          end;
        end;
      end;

      if not sLibVer.IsEmpty then begin

        reply:=MessageDlg(frmMain.Caption,
            'Archive '+sLibName+' - Library Version?', mtConfirmation,
            [mbYes,mbNo,mbCancel],'');

        if reply=mrCancel then break;

        if reply=mrYes then begin
          if MoveFile(sLibPath, sLibArcPath) then begin
            Grid.Cells[colLibVer,j]:='';
            gLibList.Delete(iLib);
            gLibList.Sort;
            LoadGrid;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.miExploreClick(Sender: TObject);
var
  orect: TGridRect;
  sLibName, sLibPath, sFolder: String;
  index: integer;
begin
  orect := Grid.SelectedRange[0];
  Grid.Row:=orect.top;
  sLibName:=Grid.Cells[colLibName,orect.top];
  FindInList(gLibList, sLibName,index,sLibPath);
  sFolder:=ExtractFileDir(sLibPath);
  SysUtils.ExecuteProcess(UTF8ToSys('explorer.exe'), sFolder, []);

end;

procedure TfrmMain.miPropertiesClick(Sender: TObject);
var
  i,j, iUpd, iLib: integer;
  sLibName, sLibPath, sUpdPath: string;
  orect: TGridRect;

begin

  for i := 0 to Grid.SelectedRangeCount-1 do begin
    orect := Grid.SelectedRange[i];
    for j:=orect.Top to orect.Bottom do begin

      sLibName:=Grid.Cells[colLibName,j];
      FindInList(gLibList, sLibName, iLib, sLibPath);
      FindInList(gUpdList, sLibName, iUpd, sUpdPath);
      if iUpd=-1 then sUpdPath:='';

      if not sUpdPath.IsEmpty then
        if ShowProperties(sUpdPath)=mrCancel then
          exit;

      if not sLibPath.IsEmpty then
        if ShowProperties(sLibPath)=mrCancel then
          exit;
    end;
  end;
end;

procedure TfrmMain.miSelectAllClick(Sender: TObject);
begin
  SelectAll;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject);
begin
  
  if Assigned(FindOnlineThread) then begin
    if not FindOnlineThread.Finished then begin
      FindOnlineThread.Terminate;
      FindOnlineThread.WaitFor;
    end;
  end;



end;

procedure TfrmMain.Start;
begin
  GetLibraryList;
  CheckFileNames(gLibList);
  CheckFileNames(gUpdList);
  CheckUpdates;
  GetInstalledList;
  LoadGrid;

  ShowStatus('Ready');

end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin

  if gFirstActivation then
     gFirstActivation:=false
  else
    exit;

  if gDEBUG then DEBUG.Show;

  Start;

end;

end.

