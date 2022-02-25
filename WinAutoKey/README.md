![Environment](https://img.shields.io/badge/Windows-XP,%20Vista,%207,%208,%2010-brightgreen.svg)
[![Release](https://img.shields.io/github/release/jasc2v8/WinAutoKey.svg)](https://github.com/jasc2v8/WinAutoKey/releases)
[![License](https://img.shields.io/badge/license--GPL-3.0-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0.en.html)
![TotalDownloads](https://img.shields.io/github/downloads/jasc2v8/WinAutoKey/total.svg)
[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

# WinAutoKey

A freeware automation unit for Free Pascal and the Lazarus IDE on the Windows operating system.

WinAutoKey is designed to be used with the Object-Pascal dialect of Free Pascal, and the Lazarus rapid-development IDE, versus the BASIC-like syntax and less-functional IDEs of other popular automation tools.

With WinAutoKey you don't have to try and remember a second programming language - everything is written in Pascal!

## Design objectives:

1. No third party packages required - uses the standard FPC/Lazarus distribution.

1. Use function names from AutoIT and/or AutoHotKey. Not intended to be full a full implementation of these tools.

1. UTF8 support.

1. Windows operating system only.

1. Promote the use of the Free Pascal language and Lazarus IDE.

## Why Another Automation Tool for Windows?

Other automation tools, such as AutoIt and AutoHotKey, are fantastic tools with great documentation.  However, the BASIC-like syntax of these tools can be difficult to remember and cumbersome to use.  Free Pascal is a modern object-oriented programming language that is mature, well documented, easy to use, and features rapid-development using the Lazarus IDE.

## Getting Started

1. Start with the login and savelinks examples.

2. Note the use of hCtl and hWin functions to search by window title, text, or class.

3. Use tools such as [Au3Info](https://www.autoitscript.com/site/autoit/downloads/) (download zip), or [WinSpy.exe](https://sourceforge.net/projects/winspyex/) to identify the window title, text, and class to search for.

## Not Supported, and not Planned to Support:

1. Title: REGEXPTITLE, REGEXPCLASS, X \ Y \ W \ H, INSTANCE

1. Control: ClassNN

1. TextMatchMode: Fast (only match certain controls, exclude edit controls)

## Development Tools

These units were developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.  They have been tested only on 64 bit Win10.

## Donations

If this utility is useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.  Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors.
