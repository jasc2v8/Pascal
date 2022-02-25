@echo off
SET /P AREYOUSURE=Are you sure you want to DELETE all certificates and keys in this folder (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

del /f /q *.cnf 2> nul
del /f /q *.csr 2> nul
del /f /q *.crt 2> nul
del /f /q *.ext 2> nul
del /f /q *.key 2> nul
del /f /q *.pem 2> nul
del /f /q *.pfx 2> nul
del /f /q *.srl 2> nul

:END
pause
endlocal
