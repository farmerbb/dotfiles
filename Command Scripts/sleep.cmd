@echo off

powercfg -h off
rundll32.exe powrprof.dll,SetSuspendState 0,1,0
powercfg -h on