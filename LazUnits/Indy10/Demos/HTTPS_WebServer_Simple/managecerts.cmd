@echo off

IF [%1]==[] (
	ECHO Valid paramaters are - to ADD or -r to REMOVE
	GOTO END
)

IF %1==-a (
   certutil -addstore "Root" "DEMO_RootCA.crt.pem"
   certutil -addstore "My"   "DEMO_Server.crt.pem"
) ELSE IF %1==-r (
   certutil -delstore "Root" "localhost.com"
   certutil -delstore "My"   "localhost.com"
) ELSE (
	echo Invalid parameter
)

:END
