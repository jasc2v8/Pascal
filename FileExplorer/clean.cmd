@echo off
rmdir /s /q backup
rmdir /s /q lib
del *.dbg
del *.log
rem del *.lps = project settings
del *.res
del *.exe
echo Directory cleaned.
pause