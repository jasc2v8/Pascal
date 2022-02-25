@echo off

REM Modify for your environment
REM Add to Project Options, Compiler Options, Compiler Commands, Execute Before: copy_demo_files.cmd

set SOURCE=C:\codetyphon\binRuntimes\i386-win32\
set TARGET=..\xbin

copy /Y %SOURCE%\libeay32.dll %TARGET%
copy /Y %SOURCE%\ssleay32.dll %TARGET%

copy /Y DEMO_RootCA.crt.pem %TARGET%
copy /Y DEMO_Server.crt.pem %TARGET%
copy /Y DEMO_Server.key.pem %TARGET%
