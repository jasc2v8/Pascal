# Lazarus EventLog Unit

## Overview

A TEventLogCustom class that is similar, but less functional, than the FPC TEventLog class.

## Features

1. Log file is not locked, can be shared between units
2. User can edit the log file while the program is running to make notes for debugging
3. Log file is formatted for CSV input to sort very large log files
4. Uses abbreviated event types ('DBG', 'ERR', 'INF', 'WRN')
5. Log file fields are of uniform width (TIMESTAMP, TYPE, MESSAGE)

## Development Tools

This utility was developed using the Lazarus IDE version 1.8.4 with Free Pascal version 3.0.4.  It has been tested on both 32 and 64 bit versions of WinXP, Win7, and Win10 using Virtualbox.
 

