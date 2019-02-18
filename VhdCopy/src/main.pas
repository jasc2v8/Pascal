unit main;

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
  Menus, ComCtrls, ExtCtrls, LazUTF8, Process, DateUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    Selected: TLabeledEdit;
    MAction: TMenuItem;
    MIClone: TMenuItem;
    MIHelp: TMenuItem;
    MIAbout: TMenuItem;
    MISetGuuid: TMenuItem;
    MIClearText: TMenuItem;
    MHelp: TMenuItem;
    MISave: TMenuItem;
    MMain: TMainMenu;
    Memo1: TMemo;
    MFile: TMenuItem;
    MIOpen: TMenuItem;
    MICancel: TMenuItem;
    MIQuit: TMenuItem;
    MISeparator1: TMenuItem;
    OpenDialog1: TOpenDialog;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure MIAboutClick(Sender: TObject);
    procedure MICancelClick(Sender: TObject);
    procedure MIClearTextClick(Sender: TObject);
    procedure MICloneClick(Sender: TObject);
    procedure MIHelpClick(Sender: TObject);
    procedure MIOpenClick(Sender: TObject);
    procedure MIQuitClick(Sender: TObject);
    procedure MISaveClick(Sender: TObject);
    procedure MISetGuuidClick(Sender: TObject);

  private
    procedure RunCopy;
    procedure RunSetGuuid;
    procedure SaveFile;

  public
    OpenFileName, SaveFileName: string;
    Running, Aborting: boolean;

  end;

var
    MainForm: TMainForm;

implementation

{$R *.lfm}


{ TMainForm }

procedure TMainForm.MIQuitClick(Sender: TObject);
begin
  {TODO are you sure?}
  Close;
end;
procedure TMainForm.MISaveClick(Sender: TObject);
begin
  SaveFile;
end;

procedure TMainForm.MISetGuuidClick(Sender: TObject);
begin
  RunSetGuuid;
end;
procedure TMainForm.MIOpenClick(Sender: TObject);
begin
  Memo1.Clear;
  OpenDialog1.InitialDir:=GetCurrentDir;
  OpenDialog1.Filter:=('All VHD Files|*.hdd;*.vdi;*.vhd;*.vmdk|All Files|*.*');
  if OpenDialog1.Execute then
    OpenFileName := OpenDialog1.Filename
  else
    OpenFileName:= '';
    Selected.Text:=OpenFileName;
end;
procedure TMainForm.MICancelClick(Sender: TObject);
begin
  if Running then
    Aborting:=true;
    Memo1.Append('Cancel: ' + DateTimeToStr(Now));
    ProgressBar1.Position:=0;
end;
procedure TMainForm.MIClearTextClick(Sender: TObject);
begin
  Memo1.Clear;
end;
procedure TMainForm.MICloneClick(Sender: TObject);
begin
  Memo1.Clear;
  SaveFile;
  RunSetGuuid;
end;

procedure TMainForm.MIHelpClick(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Append('File:');
  Memo1.Append('  Open       - select a virtual hard drive (VHD)');
  Memo1.Append('  Clone As   - copy the VHD and change its UUID');
  Memo1.Append('  Save As    - copy the VHD and retain its UUID');
  Memo1.Append('  Cancel     - copy or set UUID operation');
  Memo1.Append('  Quit       - terminates the application');
  Memo1.Append('');
  Memo1.Append('Tools:');
  Memo1.Append('  Clear Text - clear the text in the memo box');
  Memo1.Append('  Set UUID   - change the UUID of the selected VHD');
  Memo1.Append('');
  Memo1.Append('Help:');
  Memo1.Append('  About      - shows information about the application');
  Memo1.Append('  Usage      - shows these instructions');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
    //Memo1.Append('form create');
    //MainForm.Width := 1280;
    //MainForm.Height := 760;
end;

procedure TMainForm.MIAboutClick(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Append
  (
  'VhdCopy by jascv8 at yahoo dot com' + sLineBreak +
  sLineBreak +
  'Created with Free Pascal and Lazarus' + sLineBreak +
  sLineBreak +
  'Distributed under the MIT license' + sLineBreak +
  'https://opensource.org/licenses/MIT'
  );
end;
procedure TMainForm.SaveFile;
var
  StartTime, FinishTime: TDateTime;

begin

  if OpenFileName = '' then exit;

  SaveDialog1.FileName:=ExtractFileNameWithoutExt(OpenFileName) +
    '_copy' + ExtractFileExt(OpenFileName);

  if SaveDialog1.Execute then

    SaveFileName:=SaveDialog1.FileName;
    Selected.Text:=SaveFileName;

    if not FileExists(SaveFileName) or
      (MessageDlg('File exists: overwrite?',mtConfirmation,[mbYes,mbNo],0) = mrYes) then

       begin

        StartTime := Now;
        Memo1.Append('Start  : ' + FormatDateTime('h:mm:ss',Now));

        if not Running then
          begin
            RunCopy;
          end
        else
          begin
            ProgressBar1.Position:=0;
            Aborting:=true;
          end;

        FinishTime := Now;
        Memo1.Append('Start  : ' + FormatDateTime('h:mm:ss',Now));

        Memo1.Append('Elapsed: ' +
        format('%.d',[HoursBetween  (StartTime, FinishTime)])+ ':' +
        format('%.2d',[MinutesBetween(StartTime, FinishTime)])+ ':' +
        format('%.2d',[SecondsBetween(StartTime, FinishTime)])+ '.' +
        RightStr(format('%.3d',[MilliSecondsBetween(StartTime, FinishTime)]),3));

        ProgressBar1.Position:=0;

       end
  else
  SaveFileName:='';
  Selected.Text:=OpenFileName;
end;
procedure TMainForm.RunCopy;

{TFileStream is used vs sysutil FileCreate etc, for access to .position and .size}

var
  ifs, ofs: TFileStream;
  ifsCount: LongInt;
  Buffer: array[1..4096] of byte;

begin
  if Running then exit;
  Running:=true;

  try
    ifs:=TFileStream.Create(UTF8ToSys(OpenFileName),fmOpenRead);
    ofs:=TFileStream.Create(UTF8ToSys(SaveFileName),fmOpenWrite or fmCreate);

    try
      while true do
      begin

        // process all user events, like clicking on the button
        Application.ProcessMessages;
        if Aborting or Application.Terminated then break;

        // read
        ifsCount:=ifs.Read(Buffer[1],length(Buffer));
        if ifsCount=0 then break;

        // write
        ofsCount:=ofs.Write(Buffer[1],ifsCount);

        // show progress
        ProgressBar1.Position:=ProgressBar1.Min
               +((ProgressBar1.Max-ProgressBar1.Min+1)*ifs.Position) div ifs.Size;
      end;
    finally
      ifs.Free;
      ofs.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',E.Message,mtError,[mbCancel],0);
    end;
  end;
  Aborting:=false;
  Running:=false;
end;
procedure TMainForm.RunSetGuuid;

const
  BUF_SIZE = 2048; // Buffer size for reading the output in chunks
  VBManageUnix = '/usr/lib/virtualbox/VBoxManage.exe';
  VBManageWin32 = '"C:\Program Files (x86)\Oracle\VirtualBox\VboxManage.exe"';
  VBManageWin64 = '"C:\Program Files\Oracle\VirtualBox\VboxManage.exe"';

  {$IFDEF Unix}
    OS = 'UNIX';
  {$ELSE}
    OS = 'WINDOWS';
  {$ENDIF}

var
  AProcess     : TProcess;
  OutputStream : TStream;
  BytesRead    : longint;
  Buffer       : array[1..BUF_SIZE] of byte;
  VBManage     : string;

begin

  VBManage := VBManageUnix;

  if OS = 'WINDOWS' then
    if FileExists(VBManageWin32) then
      begin
         VBManage := VBManageWin32;
      end
    else
      begin
          VBManage := VBManageWin64;
      end;

  AProcess := TProcess.Create(nil);
  AProcess.Executable:=VBManage;
  AProcess.Parameters.Add('internalcommands');
  AProcess.Parameters.Add('sethduuid');
  AProcess.Parameters.Add(Selected.Text);

  //DEBUG show command line
  //Memo1.Append(AProcess.Executable);
  //Memo1.Append(AProcess.Parameters.Text);

  // Process option poUsePipes has to be used so the output can be captured.
  // Process option poWaitOnExit can not be used because that would block
  // this program, preventing it from reading the output data of the process.
  AProcess.Options := [poUsePipes, poNoConsole];

  // Start the process
  AProcess.Execute;

  // show progress
  ProgressBar1.Style:=pbstMarquee;

  // After AProcess has finished, the rest of the program will be executed.

  // Create a stream object to store the generated output in. This could
  // also be a file stream to directly save the output to disk.
  Aborting:=false;
  Running:=true;
  OutputStream := TMemoryStream.Create;

  // All generated output from AProcess is read in a loop until no more data is available
  repeat

    // process all user events, like clicking on the button
    Application.ProcessMessages;
    if Aborting or Application.Terminated then break;

    // Get the new data from the process to a maximum of the buffer size that was allocated.
    // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
    BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);

    // Add the bytes that were read to the stream for later usage
    OutputStream.Write(Buffer, BytesRead);

    // Show output
    with TStringList.Create do
    begin
      OutputStream.Position := 0;
      LoadFromStream(OutputStream);
      if BytesRead <> 0 then
        Memo1.Append(Text);
      Free;
    end;

    // Stop if no more data is available
    until BytesRead = 0;

  // Clean up
  AProcess.Free;
  ProgressBar1.Style:=pbstNormal;
  OutputStream.Free;
  Aborting:=false;
  Running:=false;

end;
end.

