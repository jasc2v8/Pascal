# Configuring the Windows certificate store

## Use a PFX file

Double-click on DEMO_Server.pfx to open Certificate Import Wizard
Choose Local Machine, Next, Next, enter password 'demo', Next
Choose Automatically select the certificate store
Next

## Use managecerts.cmd

All files must be in the same folder:

		managedcerts.cmd
		DEMO_RootCA.crt.pem
		DEMO_Server.crt.pem
		DEMO_Server.key.pem

Add certs to Personal and Trusted Store:

		managecerts.cmd -a

Remove certs from Personal and Trusted Store:

		managecerts.cmd -r

## Manually importing

Import certificates into the Windows certificate store.

Windows start menu, search "certificates", choose: "Manage computer certificates"

Personal context menu: All Tasks,

	Import: DEMO_RootCA.crt.pem
	
	Store: Trusted Root Certification Authorities
	
Personal context menu: All Tasks,

	Import: DEMO_Server.crt.pem
	
	Store: Personal
