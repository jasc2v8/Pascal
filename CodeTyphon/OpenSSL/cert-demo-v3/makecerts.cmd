@echo off
setlocal

REM PLEASE UPDATE THE FOLLOWING VARIABLES FOR YOUR SETTINGS

REM SET exepath=C:\OpenSSL\openssl-1.0.2r-i386-win32\OpenSSL.exe
REM I have openssl.exe on my PATH, therefore:
SET exepath=OpenSSL.exe
REM I have OPENSSL_CONF defined as a system environement variable, therefore:
REM SET OPENSSL_CONF=C:\OpenSSL\openssl-1.0.2r-i386-win32\OpenSSL.cfg

SET HOSTNAME=localhost
SET DOT=com
SET COUNTRY=US
SET STATE=CA
SET CITY=DEMO
SET ORGANIZATION=DEMO
SET ORGANIZATION_UNIT=DEMO
SET EMAIL=webmaster@%HOSTNAME%.%DOT%
SET PASSIN=demo
SET PASSOUT=demo
SET DAYS=365

SET /P AREYOUSURE=Are you sure you want to recreate keys as prior keys will be deleted (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

del /f /q *.cnf 2> nul
del /f /q *.csr 2> nul
del /f /q *.crt 2> nul
del /f /q *.ext 2> nul
del /f /q *.key 2> nul
del /f /q *.pem 2> nul
del /f /q *.pfx 2> nul
del /f /q *.srl 2> nul

(
echo [req]
echo prompt = no
echo default_bits = 2048
echo default_md = sha256
echo distinguished_name = dn
echo x509_extensions = v3_ca
echo:
echo [dn]
echo C = %COUNTRY%
echo ST = %STATE%
echo L = %CITY%
echo O = %ORGANIZATION%
echo OU = %ORGANIZATION_UNIT%
echo emailAddress = %EMAIL%
echo CN = %HOSTNAME%.%DOT%
echo:
echo [v3_ca]
echo subjectKeyIdentifier = hash
echo authorityKeyIdentifier = keyid:always,issuer
echo basicConstraints = critical, CA:true
echo keyUsage = critical, digitalSignature, cRLSign, keyCertSign
echo subjectAltName = @alt_names
echo [alt_names]
echo DNS.1 = localhost
echo IP.1  = 127.0.0.1
) > DEMO_openssl.cnf

(
echo basicConstraints = CA:FALSE
echo nsCertType = server
echo nsComment = "OpenSSL Generated Server Certificate"
echo subjectKeyIdentifier = hash
echo authorityKeyIdentifier = keyid,issuer:always
echo keyUsage = critical, digitalSignature, keyEncipherment
echo extendedKeyUsage = serverAuth
echo subjectAltName = @alt_names
echo [alt_names]
echo DNS.1 = localhost
echo IP.1  = 127.0.0.1
) > DEMO_v3.ext

echo:
echo INFO: Ignore any WARNING message re: can't open config file (it's not required)

echo:
echo INFO: Create the root CA key
echo:

	%exepath% genrsa -des3 ^
	-passout pass:%PASSOUT% -out DEMO_RootCA.key.pem 2048 

echo:
echo INFO: Create the root CA using the root CA key
echo:

	%exepath% req -x509 -new -nodes -sha256 -days %DAYS% -config DEMO_openssl.cnf ^
	-passin pass:%PASSIN% -key DEMO_RootCA.key.pem ^
	-out DEMO_RootCA.crt.pem ^
	
echo:
echo INFO: Create the SERVER CSR
echo:

	%exepath% req -new -nodes -config DEMO_openssl.cnf ^
	-out DEMO_Server.csr.pem ^
	-newkey rsa:2048 -keyout DEMO_Server.key.pem
			
echo:
echo INFO: Create the SERVER certificate signed issued by the self-signed root certificate
echo:

	%exepath% x509 -req -sha256 -days %DAYS% -extfile DEMO_v3.ext ^
	-in DEMO_Server.csr.pem ^
	-passin pass:%PASSIN% -CA DEMO_RootCA.crt.pem -CAkey DEMO_RootCA.key.pem -CAcreateserial ^
    -out DEMO_Server.crt.pem

echo:
echo INFO: Bundle the certificates and key into a single file
echo:

	copy DEMO_RootCA.crt.pem+DEMO_Server.crt.pem+DEMO_Server.key.pem %HOSTNAME%.pem

	%exepath% pkcs12 -export -in %HOSTNAME%.pem -out %HOSTNAME%.pfx

echo:
echo INFO: Finished.
echo:

:END
pause
endlocal
