unit myFileUtils;
{move, copy, delete}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils;

function ChildPath(aPath: string): string;
function JoinPath(aDir, aFile: string): string;
function ParentPath(aPath: string): string;

implementation

function ChildPath(aPath: string): string;
begin
  aPath:=ExpandFileName(ChompPathDelim(aPath));
  Result:=Copy(aPath,aPath.LastIndexOf(DirectorySeparator)+2)
end;

function JoinPath(aDir, aFile: string): string;
begin
  Result:=IncludeTrailingPathDelimiter(aDir)+
          ExcludeTrailingPathDelimiter(aFile);
end;

function ParentPath(aPath: string): string;
begin
  Result:=ExpandFileName(IncludeTrailingPathDelimiter(aPath) + '..');
end;

end.

