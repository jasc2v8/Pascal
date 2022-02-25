# Creating OpenSSL Certs on Windows

Use the makecerts.cmd located in the folder \cert-demo-v3

		makecerts.cmd

Will generate many files, but these will be used:

		DEMO_RootCA.crt.pem
		DEMO_Server.crt.pem
		DEMO_Server.key.pem
		DEMO_Server.pfx

## Import Certs on Windows

See the document "How to Configure OpenSSL Certs on Windows"
The easiest method is to open: DEMO_Server.pfx

## Copy files to the SSL demos

The following are used by the demo projects:

		DEMO_RootCA.crt.pem
		DEMO_Server.crt.pem
		DEMO_Server.key.pem

