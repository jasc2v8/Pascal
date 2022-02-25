# LazCopyOptions
![Environment](https://img.shields.io/badge/Windows-XP,%20Vista,%207,%208,%2010-brightgreen.svg)
[![License](https://img.shields.io/badge/license-Unlicense-yellow.svg)](https://opensource.org/licenses/UNLICENSE)
[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

Overview
---
LazCopyOptions saves time by not having to manually reset all the desired options.

Use LazCopyOptions to:
  1. Copy Options to Other IDE Installations
  2. Copy Options to Other Projects
  3. Backup and Restore IDE and Project Options

Copy Options to Other IDE Installations
---
Lazarus IDE options are stored in several XML files.
Options that require a build of the IDE cannot be safely copied.
Options that don't require a build can be copied, including:

	($PrimaryConfigPath)\editoroptions.xml
		Font size, background color, right margin, etc.
	
	($PrimaryConfigPath)\environmentoptions.xml
		Environment options, IDE CoolBar, etc.
		The FPC and Lazarus paths must be updated after copying this file.
												
	($PrimaryConfigPath)\projectoptions.xml
		Used when creating a new project.
		Add build modes and compiler options to this file.
		Created by Project Options, "Set compiler options as default"
	
Copy Options to Other Projects
---
	($ProjPath)\project.lpi
		Project options are stored in this file (build modes and compiler options)

Backup and Restore IDE and Project Options
---
	Backup ($PrimaryConfigPath)\*.xml     to \backup\*.xml
	Backup ($ProjPath)\projectoptions.xml to \backup\myprojectoptions.xml

My IDE Option Preferences
---
Tools, Options, Environment ($PrimaryConfigPath\environmentoptions.xml):
  ```
  Window:			Check IDE title start with project name+directory+build mode
	Object Inspector:	Check show hints
	IDE CoolBar:		Add 'Project Options' button next to the 'Desktops' button
	IDE CoolBar:		Add 'Run without Debug' button next to the 'Run' button
```
Tools, Options, Editor ($PrimaryConfigPath\editoroptions.xml):
```
	General
		UNcheck Caret past end of line
		Check Home key and End key jumps to nearest..
	General Tab and Indent
		Tabs to spaces=2 tab widths
		UNcheck smart tabs
	Display
		Visible right margin=90 	{my printer's right edge, portrait mode}
		Font=Courier New, 14		{easier to read on my 32" monitor}
		Colors: Background=Cream	{easier on my eyes}
```
My Project Option Preferences
---
Project, Options ($ProjPath)\project.lpi):
```
	Build Modes
		Default, Debug, Release, Debug64, Release64
	Compiler commands, execute before
		C:\lazarus\execute_before.bat $Name($TargetFile())
		execute_before.bat will kill the project.exe if it is running
```		
Check "Set compiler options as default": Save to ($PrimaryConfigPath)\projectoptions.xml

References
---
Lazarus wiki (http://wiki.freepascal.org/):
```
	Multiple Lazarus
	IDE Macros in paths and filenames
	IDE Window: IDE Options Dialog
	IDE Window: Project Options
  ```
## Development Tools

This utility was developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.

It has been tested on both 32 and 64 bit versions of WinXP, Win7, and Win10 using Virtualbox.

### Donations

If this utility is useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.

Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors. 
