# LazHelp Unit

## Overview

Adds a help feature to Lazarus Projects with two options:
1. Browser
2. File Viewer

## Features

* Open online URLs
* Open local files
* Open resource files
* Show HTML Help files for a more professional look
* Show GitHub Markdown files using a Markdown extension in your Browser

## Browser

* Unit name HTMLBrowser.pas
* Open local files, resources files, and online URLs in your system browser.
* Add a Markdown viewer to your browser to read *.md files

## FileViewer

* Unit name HTMLFileViewer.pas with HTMLFileViewer.lfm
* Open local files and resources files in a help form.
* Open online URLs in your system browser, not in the help form.

## Notes

*__Markdown__*

I use the Google Chrome browser with a Markdown Viewer.
I recommend this free one by Simov
It's available from the Chrome Web Store, or:
https://github.com/simov/markdown-viewer

*__Resource Files__*

Caution using both HTMLBrowser and HTMLFileViewer in the same project.
Both will compile res.rc and will conflict if the same resource name is in both files.

*__Turbopower iPro TIpHtmlPanel component__*

HTMLFileViewer uses the Turbopower iPro TIpHtmlPanel component.
This component has several limitations, but works well for simple HTML help files.
Does not support: CSS or HTML 'pre' or 'code' tags.
Therefore no support for Markdown.md files.
GoBack and GoForward not implemented.
These do not work properly in the iPro TIpHtmlPanel component.
These could be implemented, but I decided to keep this unit simple.
  
## Development Tools

This utility was developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.  It has been tested on both 32 and 64 bit versions of WinXP, Win7, and Win10 using Virtualbox.
 

