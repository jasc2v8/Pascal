[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

# Indy 10 OpenSSL Config

## The key difference between HTTP and HTTPS

Indy 10 HTTP uses TIdHTTPServer.

Indy 10 HTTPS uses the same TIdHTTPServer with the IO handler TIdServerIOHandlerSSLOpenSSL.

		OpenSSL:=TIdServerIOHandlerSSLOpenSSL.Create;
		
		Server:=TIdHTTPServer.Create;
		IOHandler:= OpenSSL;

## SSL Version and Ciphers

Choosing TLSv1.2 will be compatiable with all modern desktop and mobile browsers.
	
This is specifically not compatiable with older browsers for improved security.
	
		SSLOptions.SSLVersions := [sslvTLSv1_2];
	
This makes the cipher list easy to configure:
	
		OpenSSL.SSLOptions.CipherList := 'TLSv1.2:!NULL';
		
TLSv1.2 is reasonably secure until future Indy support of TLSv1.3 

## Reference Links as of 04.27.2019

https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices
	
https://www.openssl.org/docs/man1.0.2/man1/ciphers.html
	
https://www.indyproject.org/documentation/
	
## My Config

- Win10 Home, CodeTyphon v6.8
- Indy10.6.2.5494
- Openssl-1.0.2r-i386-win32

### Donations

If this units are useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.  Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors.
