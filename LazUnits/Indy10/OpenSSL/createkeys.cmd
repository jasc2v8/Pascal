rem
rem to create certs for demo projects, enter the password 'demo'
rem
rem https://medium.com/@tbusser/creating-a-browser-trusted-self-signed-ssl-certificate-2709ce43fd15
@echo off
setlocal
:PROMPT
SET /P AREYOUSURE=Are you sure you want to recreate keys as prior keys will be deleted (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

del /f /q *.key
del /f /q *.csr
del /f /q *.crt
del /f /q *.pfx

set exepath=D:\Software\DEV\Lang\Pascal\Packages\openssl-1.0.2l-i386-win32\OpenSSL.exe

echo ...Create a root certificate

%exepath% genrsa -des3 -out rootCA.key 2048

%exepath% req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem -config createkeys.cnf

echo ...Create an SSL certificate issued by the self created root certificate

%exepath% req -new -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config createkeys.cnf
		
%exepath% x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial ^
        -out server.crt -days 500 -sha256 -extfile v3.ext

echo ...Bundle the server certificate and private key into a single file

%exepath% pkcs12 -inkey server.key -in server.crt -export -out server.pfx

echo ...Finished. Please read the instructions on How to Config Certs on Windows

:END
pause
endlocal
