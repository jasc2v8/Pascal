rem https://medium.com/@tbusser/creating-a-browser-trusted-self-signed-ssl-certificate-2709ce43fd15
@echo off
setlocal

set exepath=D:\Software\DEV\Lang\Pascal\Packages\openssl-1.0.2l-i386-win32\OpenSSL.exe

echo ...View the Root Certificate

%exepath% x509 -noout -text -in rootCA.pem

echo ...View the Server Certificate

%exepath% x509 -noout -text -in server.crt

echo ...View the Certificate Bundle

%exepath%  pkcs12 -info -in server.pfx

:END
pause
endlocal
