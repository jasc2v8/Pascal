# LazFileUtilWin
![Environment](https://img.shields.io/badge/Windows-XP,%20Vista,%207,%208,%2010-brightgreen.svg)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

Adds features to the FPC/Lazarus file copy and delete functions.

CopyFileWin and CopyDirWin will force create the target directory.

## Methods
	
	function ChildPath(aPath: string): string;
	
	function ParentPath(aPath: string): string;
	
	function JoinPath(aDir, aFile: string): string;

	function CopyDirWin(sourceDir, targetDir: string): boolean;
	
	function CopyFileWin(sourcePath, targetPath: string;
            Flags: TCopyFileFlags=[cffOverwriteFile];
            PreserveAttributes: boolean=true): boolean;

	function DelDirWin(targetDir: string; OnlyChildren: boolean=False): boolean;
	
	function DelFileWin(targetFile: string): boolean;

	function FilenameIsDir(aPath: string): boolean;
	
	function FilenameIsFile(aPath: string): boolean;


## Development Tools

This utility was developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.

It has been tested on both 32 and 64 bit versions of WinXP, Win7, and Win10 using Virtualbox.

### Donations

If this utility is useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.

Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors.  

