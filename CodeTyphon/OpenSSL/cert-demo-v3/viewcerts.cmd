@echo off
setlocal

SET exepath=openssl.exe
SET PASSIN=demo

echo:
echo INFO: View the Root Certificate: DEMO_RootCA.crt.pem
echo:

	%exepath% x509 -noout -text -in DEMO_RootCA.crt.pem

echo:
echo INFO: View the Server Certificate: DEMO_Server.crt.pem
echo:

	%exepath% x509 -noout -text ^
	-passin pass:%PASSIN% -in DEMO_Server.crt.pem

echo:
echo INFO: View the Certificate Bundle: DEMO_Server.pfx
echo:

	%exepath%  pkcs12 -info ^
	-passin pass:%PASSIN% -passout pass:%PASSIN% -in DEMO_Server.pfx

:END
pause
endlocal
