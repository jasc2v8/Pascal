unit BlockInputUnit;

{$mode objfpc}{$H+}

interface
  function IsElevated: Boolean;
  function SetBlockInput(const State: Boolean=True): DWORD;

implementation

uses
  Forms, Windows;

function BlockInput(fBlockInput: Boolean): DWORD; stdcall; external 'user32.DLL';

//Block/Unblock keyboard and mouse input, requires run as Admin
function SetBlockInput(const State: Boolean=True): DWORD;
begin
  Result:=BlockInput(State);
  Application.ProcessMessages;
end;

function IsElevated: Boolean;
var
  hToken: HWND;
  Elevation: TOKEN_ELEVATION;
  cbSize: DWORD;
  Value: Integer;
begin
  Value:=0;
  if(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,@hToken )) then begin
    cbSize:=sizeof(TOKEN_ELEVATION);
    if(GetTokenInformation(hToken,TokenElevation,@Elevation,sizeof(Elevation),@cbSize)) then
      value:=Elevation.TokenIsElevated;
    if( hToken<>0 ) then
      CloseHandle( hToken );
  end;
  if Value=0 then
    Result:=False
  else
    Result:=True;
end;

end.
 
