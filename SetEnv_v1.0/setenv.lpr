{ Version 1.0 - Author jasc2v8 at yahoo dot com
This is free and unencumbered software released into the public domain.
For more information, please refer to <http://unlicense.org> }

{Sets or Removes System/User Environment Variables, designed for use with Inno Setup}

program setenv;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, CustApp, registry;

type

  TActionFlags = set of (afAdd, afAppend, afPrepend, afRemove);

  TRegKey = record
    ID: string;
    Root: longint;
    Sect: string;
    Name: string;
    Value: string;
    Action: TActionFlags;
  end;


  { TApp }

  TApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure ChangePath(aKey:TRegKey);
    procedure ChangeVar(aKey:TRegKey);
    procedure Display(aKey: TRegKey);
  end;

const
  LE = LineEnding;
  SysName = 'SYSTEM';
  SysRoot = longint(HKEY_LOCAL_MACHINE);
  SysSect = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
  UsrName = 'USER';
  UsrRoot = longint(HKEY_CURRENT_USER);
  UsrSect = 'Environment';
  ShortOptions = 'h:: q:: d:: s:: u:: n:: v:: a:: p:: r::';
  LongOptions  = 'help:: quiet:: display:: system:: user:: ' +
                 'name:: value:: append:: prepend:: remove::';

var
  Quiet: boolean=false;

{ TMyApplication }

procedure TApp.ChangePath(aKey: TRegKey);
var
  reg: TRegistry;
  aOldValue, aNewValue: string;
begin

  //writeln('DEBUG ChangePath');
  //writeln('DEBUG aKey.Name =',aKey.Name);
  //writeln('DEBUG aKey.Value=',aKey.Value);

  {remove leading or trailing semicolons}
  if aKey.Value.StartsWith(';') then aKey.Value:=Copy(aKey.Value,2,aKey.Value.Length);
  if aKey.Value.EndsWith(';')   then aKey.Value:=Copy(aKey.Value,1,aKey.Value.Length-1);

  reg := TRegistry.Create;

  try

    reg.RootKey := aKey.Root;

    if reg.OpenKey(aKey.Sect, false) then begin

      aOldValue:=reg.ReadString(aKey.Name);

      if aKey.Action = [afRemove] then begin

        {Remove}
        if not aOldValue.Contains(aKey.Value) then begin
          if not Quiet then
            writeln('Value not in ',aKey.ID,' PATH: ', aKey.Value);
        end else begin
          aNewValue:=StringReplace(aOldValue,';'+aKey.Value,'',[rfReplaceAll]);
          aNewValue:=StringReplace(aOldValue,aKey.Value+';','',[rfReplaceAll]);

          reg.WriteString('Path', aNewValue);
          //writeln('DEBUG ChangePath Remove Name='+aKey.Name, ', Value=', aNewValue);

          if not Quiet then
            writeln('Removed from '+aKey.ID,' PATH: ', aKey.Value);
        end;

      end else begin

        {Append or Prepend}
        if aOldValue.Contains(aKey.Value) then begin
          if not Quiet then
            writeln(aKey.ID,' PATH already contains: ' + aKey.Value);
        end else if aKey.Action = [afAppend] then begin
          {Append}
          if not aOldValue.EndsWith(';') then aOldValue:=aOldValue+';';
          aNewValue:=aOldValue+aKey.Value+';';
          if not Quiet then
            writeln('Appended to ', aKey.ID, ' ', aKey.Name, ': ',aKey.Value);
        end else begin
          {Prepend}
          if aOldValue.StartsWith(';') then aOldValue:=Copy(aOldValue,1,aOldValue.Length-1);
          aNewValue:=aKey.Value+';'+aOldValue;
          if not Quiet then
            writeln('Prepended to ', aKey.ID, ' ', aKey.Name, ': ',aKey.Value);
        end;

        reg.WriteString(aKey.Name, aNewValue);
        //writeln('DEBUG Change Path Name='+aKey.Name, ', Value=', aNewValue);

      end;

    end else
      {PATH key not found}
      if not Quiet then writeln('ERROR opening key: ', aKey.Sect);

  finally
    reg.Free;
  end;

end;

procedure TApp.ChangeVar(aKey: TRegKey);
var
  reg: TRegistry;
  aOldValue: string;
begin

  //writeln('DEBUG ChangeVar');

  reg := TRegistry.Create;

  try

    reg.RootKey := aKey.Root;

    if aKey.Action = [afAdd] then begin
      if reg.OpenKey(aKey.Sect, false) then begin

        aOldValue:=reg.ReadString(aKey.Name);
        if not aOldValue.Equals(aKey.Value) then begin

          reg.WriteString(aKey.Name, aKey.Value);
          if not Quiet then
            writeln(aKey.ID, ' Variable ',aKey.Name, ' set to: ', aKey.Value);

        end else
          if not Quiet then
            writeln(aKey.ID, ' ',aKey.Name+' already set to: "' + aKey.Value+'"');
      end;
    end;

    if aKey.Action = [afRemove] then begin
      if reg.OpenKey(aKey.Sect, false) then begin
        aOldValue:=reg.ReadString(aKey.Name);
        if aOldValue.IsEmpty then begin
          if not Quiet then
            writeln(aKey.ID,' Variable ', aKey.Name, ' does not exist');
        end else begin

          reg.DeleteValue(aKey.Name);
          if not Quiet then
            writeln(aKey.ID,' Varable ', aKey.Name, ' Removed');

          //writeln('DEBUG ChangeVar Delete Name='+aKey.Name, ', aOldValue=', aOldValue);

        end;
      end;
    end;

  finally
    reg.Free;
  end;

end;

procedure TApp.Display(aKey: TRegKey);
var
  reg: TRegistry;
  aOldValue: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := aKey.Root;
    if reg.OpenKey(aKey.Sect, false) then begin
      aOldValue:=reg.ReadString(aKey.Name);
      writeln(aKey.Name,'=',aOldValue);
    end;
  finally
    reg.Free;
  end;
end;

procedure TApp.DoRun;
var
  aKey: TRegKey;
  aAction: TActionFlags;
  aErr: string;

  iType: integer;

begin

  {check if all options are valid, case insensitive}
  CaseSensitiveOptions:=false;
  aErr := CheckOptions(ShortOptions, LongOptions, false);

  //writeln('DEBUG aErr=',aErr);

  if (aErr <>'') and (not Quiet) then begin
    writeln('Syntax error, invalid option, -h for help');
    Terminate;
    Exit;
  end;

  {default is System}
  aKey.ID   :=SysName;
  aKey.Root :=SysRoot;
  aKey.Sect :=SysSect;

  {get name, value}
  aKey.Name :=GetOptionValue('n', 'name');
  aKey.Value:=GetOptionValue('v', 'value');

{  writeln('DEBUG Name =',aKey.Name);
  writeln('DEBUG Value=',aKey.Value);
  Terminate;
  exit;}

  {get options}
  if HasOption('q', 'quiet') then Quiet:=true;

  if HasOption('h', 'help') or (ParamCount=0) then begin
    WriteHelp;
    Terminate;
    Exit;

  end else if HasOption('s','system') then begin
    aKey.ID   := SysName;
    aKey.Root := SysRoot;
    aKey.Sect := SysSect;

  end else if HasOption('u','user') then begin
    aKey.ID   := UsrName;
    aKey.Root := UsrRoot;
    aKey.Sect := UsrSect;
  end;

  if aKey.Name.IsEmpty then begin
    if not Quiet then writeln('Invalid syntax, must have a name');
    Terminate;
    Exit;
  end else
    aKey.Name:=UpperCase(aKey.Name);

  if HasOption('d','display') then begin
    Display(aKey);
    Terminate;
    Exit;
  end;

  if (aKey.Name='PATH') and (aKey.Value.IsEmpty) then begin
    if not Quiet then writeln('Invalid syntax, must have a value');
    Terminate;
    Exit;
  end else

  if UpperCase(aKey.Name)='PATH' then begin

    if HasOption('p','prepend') then
      aKey.Action:=[afPrepend]
    else
      aKey.Action:=[afAppend];

    if HasOption('r','remove') then
      aKey.Action:=[afRemove];

    ChangePath(aKey);

  end else begin

    if HasOption('r','remove') or (aKey.Value.IsEmpty)then
      aKey.Action:=[afRemove]
    else
      aKey.Action:=[afAdd];

    ChangeVar(aKey);
  end;

{
ShowException(Exception.Create('Must specify one: -s, --system, -u, --user'));
Terminate;
Exit
if not Quiet then writeln('DEBUG RegSection=',RegSection);
}
  // stop program loop
  Terminate;
end;

constructor TApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TApp.Destroy;
begin
  inherited Destroy;
end;

procedure TApp.WriteHelp;
begin
  if not Quiet then writeln(LE + 'Sets or Removes System/User Environment Variables' + LE + LE +
  'Help:' + LE +
  '  setenv -h | --help' + LE + LE +
  'Change a Variable:' + LE +
  '  setenv [--system|--user] --name "varname" --value "string" [--remove]' + LE +
  '  setenv [ -s     | -u   ]  -n    "varname"  -v     "string" [ -r     ]' + LE +
  '  setenv [ -s     | -u   ]  -n    "varname"  -v     ""       [ -r     ]' + LE +
  '  setenv [ -s     | -u   ]  -n    "varname"  -v              [ -r     ]' + LE +
  '  setenv [ -s     | -u   ]  -n    "varname"                  [ -r     ]' + LE + LE +
  'Change a PATH:' + LE +
  '  setenv [--system|--user] --name PATH --value "string" [--remove]' + LE +
  '  setenv [ -s     | -u   ]  -n    PATH  -v     "string" [ -r     ]' + LE + LE +
  'Display a Variable:' + LE +
  '  setenv [--display] [--system|--user] --name "varname"' + LE +
  '  setenv [ -d      ] [ -s     | -u   ]  -n    "varname"');
end;

var
  Application: TApp;

{$R *.res}

begin
  Application:=TApp.Create(nil);
  Application.Title:='Set Enviornment';
  Application.Run;
  Application.Free;
end.

