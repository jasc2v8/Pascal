[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

# Install Indy 10 on Lazarus

My docs and demos **do not** include the use of the Indy VCL components in a form, but they do explain how to use Indy as non-visual components in the source code.

## Download Links as of 03.07.2019

**Indy10.6.2.5494** and Indy10Demo from https://indy.fulgan.com/ZIP/

Delphi Demos (see my doc how to convert): https://github.com/tinydew4/indy-project-demos

## Install
- Unzip the Indy10 files
- Optionally, copy the source code folders to one Indy10 root folder

			E:\Indy10\Core
			E:\Indy10\Protocols
			E:\Indy10\Security
			E:\Indy10\System
			
- Optionally, prevent memory leaks by editing the IdCompilerDefines.inc files in several folders: Core, Protocols, SuperCore, System
	- Change From:
	
			{.$DEFINE FREE_ON_FINAL}
			{$UNDEF FREE_ON_FINAL}
		
	- Change To:
	
			{$DEFINE FREE_ON_FINAL}
			{.$UNDEF FREE_ON_FINAL}
		
- Add the paths to your IDE.
	- Lazarus Options, Project Options, Miscellaneous: Check "Main unit is Pascal source", others are personal preference.
	- Lazarus Options, Compiler Options, Paths: set the Lazarus project path to your Indy10 install
	- Add the same path for both the "Other Unit Files" and "Include Files"
	- Example:
	
			E:\Indy10\Core;E:\Indy10\Protocols;E:\Indy10\Security;E:\Indy10\System

## Convert from Delphi to Lazarus
- See my doc "Convert Indy10 Delphi to Lazarus"
- Explains how to remove the visual VCL components from the Delphi form, then insert in the source code and use as non-visual objects.

## OpenSSL	

- The OpenSSL site is: https://www.openssl.org/
- Pre-compiled binaries: https://wiki.openssl.org/index.php/Binaries
- My demos use **Openssl-1.0.2l-i386-win32**
	
## My Config

- Win10 Home, Lazarus v1.8.4 with Free Pascal v3.0.4
- Indy10.6.2.5494
- Openssl-1.0.2l-i386-win32

### Donations

If this units are useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.  Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors.
