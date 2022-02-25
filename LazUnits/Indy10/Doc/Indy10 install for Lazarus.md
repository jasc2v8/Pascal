[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

# Install Indy 10 on Lazarus

My docs and demos **do not** include the use of the Indy VCL components in a form ("design time"), but they do explain how to use Indy as non-visual components in the source code ("run time").

## Use My Run Time Package
- Download \Packages\indylaz_runtime.zip
- Unzip to your packages folder e.g. C:\lazarus\packages\indylaz_runtime
- Open your project
- Lazarus menu: Package, Open Package File (*.lpk)
- Select the package file e.g. C:\lazarus\packages\indylaz_runtime\indylaz_runtime.lpk
- The Package Viewer will open the package
- Packager Viewer menu: Use, Add to Project (no need to compile yet)
- The Project Inspector will show Required Packages: indylaz_runtime
- Compile your project and it will resolve the Indy unit include statements
- Note that my run time package includes the memory leak fixes

## Manual Installation

Download links valide as of 03.07.2019

**Indy10.6.2.5494** and Indy10Demo from https://indy.fulgan.com/ZIP/

Delphi Demos (see my doc how to convert): https://github.com/tinydew4/indy-project-demos

### Manual Config
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
- Explains how to remove the visual VCL components from the Delphi form, and use as non-visual objects ("run time").

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
