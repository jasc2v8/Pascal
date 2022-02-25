# How to prevent a known memory leak issue with Indy10

Edit:	C:\codetyphon\typhon\components\pl_Indy\source\IdCompilerDefines.inc

Change From:
	
		{.$DEFINE FREE_ON_FINAL}
		{$UNDEF FREE_ON_FINAL}
		
Change To:
	
		{$DEFINE FREE_ON_FINAL}
		{.$UNDEF FREE_ON_FINAL}
	
Recompile:

- Open a pl_indy sample project
- Project Inspector, Required Packages, double-click on pl_indy, then press Compile Package menu icon
		
# Background

- Project Options, Compiler Options: check Use Heaptrc unit.
- Run a sample pl_indy project
- Haptrc will shows a leak of 3 memory blocks
- After the edit and recompile above, run the sample pl_indy project again.
- Haptrc will show 0 memory blocks leaked

