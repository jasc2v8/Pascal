# DebugUnit
![Environment](https://img.shields.io/badge/Windows-XP,%20Vista,%207,%208,%2010-brightgreen.svg)
[![License](https://img.shields.io/badge/license-unlicense-yellow.svg)](https://unlicense.org)
[![Donate](https://img.shields.io/badge/Donate-PayPal-red.svg)](https://www.paypal.me/JimDreherHome)

Adds or Removes a debug window with a debug Memo to the project.

Makes it easier to debug FPC/Lazarus projects under Windows.

## Methods
	
```pascal
procedure Debugln(Arg1: Variant);
procedure Debugln(Arg1, Arg2: Variant);
procedure Debugln(Arg1, Arg2, Arg3: Variant);
procedure Debugln(Arg1, Arg2, Arg3, Arg4: Variant);
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5: Variant);
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Variant);
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: Variant);
procedure Debugln(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: Variant);

procedure Debugln(Args: array of Variant);

procedure Debugln(Fmt:string; Args: array of Const);
```

## Examples

```pascal
Debugln('Unformatted output up to 8 Args of any Type:');
Debugln('--------------------------------------------');
Debugln(1,2,3,4,5,6,7,8);
Debugln('binary=', %010);
Debugln('boolean=', true);
Debugln('decimal=', 10);
Debugln('general=', 3.1415927);
Debugln('hex=', $0010);
Debugln('octal =', &0010);
Debugln('scientific=', 1.9E6);
Debugln('signed=', -100, ' or ', +100);
Debugln('string=', 'the quick brown fox');
Debugln('mixed bin=',%010,',bool=',true,',dec=',10,',gen=',3.1415927);

Debugln(LE+'Unformatted output with Array of Variant:');
Debugln('-----------------------------------------');
Debugln(['decimal', -1,true,3.1415,4,5]);
Debugln(['T1=', true,',T2=',false,',T3=',01.23]);

Debugln(LE+'Formatted output with Array of Const:');
Debugln('-------------------------------------');
Debugln('boolean    =%s or %s', [BoolToStr(true,false), BoolToStr(true,true)]);
Debugln('currency   =%m', [1000000.]);
Debugln('decimal    =%d', [-1]);
Debugln('float      =%f', [3.1415927]);
Debugln('general    =%g', [3.1415927]);
Debugln('hex        =%x', [-1]);
Debugln('number     =%n', [1000000.]);
Debugln('scientific =%e', [1.0e3]);
Debugln('string     =%s', ['the quick brown fox']);
Debugln('unsigned   =%u', [-1]);
Debugln('mixed cur  =%m, dec=%d',[1000000., 10]);
Debugln('mixed float=%f, num=%n',[3.1415927, 1000000.]);
```

## Development Tools

This utility was developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.

It has been tested on both 32 and 64 bit versions of WinXP, Win7, and Win10 using Virtualbox.

### Donations

If this utility is useful, or if the source code helps you in some way, then a small donation would be appreciated.  Just click on the "donation" button above.

Your donation is not tax deductible, but will be used to help promote freeware from myself and other software authors.  
