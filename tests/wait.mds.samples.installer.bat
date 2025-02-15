@echo off&cls
:: ------------------------------------------------------------------------------------------------------------------
::      wait.mds.samples.installer.bat, contains bonus samples for installer defined in the wait.mds library.
::
::                                            Copyright (C) 2013-2020 Anton Kopiev
::                                                      GNU General Public License
:: ------------------------------------------------------------------------------------------------------------------
::
:: Notes: 
::  #1. The default call with only `%~1` argument runs full installation (deinstallation) of COM library & creation
::      (deletion) of performance keys index file (depending on value of `%~1`);
::  #2. The values of arguments `%~1` & `%~2` coincide with `install` subroutine arguments of wait.mds library:
::                        %~1 == key value for calls to install or uninstall files:
::                                `/install`   or  `1` - default value to add & register files;
::                                `/uninstall` or  `0` - unregister & remove files;
::                        %~2 == key value:
::                                `/all`       or  `1` - default to do full install/uninstall;
::                                `/vb`        or  `2` - add COM wrapper for Windows api;
::                                `/tpc`       or  `3` - add file with typeperf counters;
::                                `/lib`       or  `4` - add help file & its shortcut, lite version & its environment variable;
::  #3. The call `/install` & `/all` keys adds source vbscript & VB.NET files into folder "%ProgramData%\wait.mds";
::  #4. The call with single argument `%~1` == `1` preliminary deinstalls COM library & removes all installed earlier files.
::
call:initialize "%~1" "%~2" || goto:eof_

if %isf_k1% EQU 1 if "%~n2"=="" (
 call echo [%%time%%]: Preliminary deinstallation of all files...
 call %%wait.mds.installer%% /sub:install 0 1
 call echo [%%time%%]: DONE.
)
if %isf_k1% EQU 1 (
 if %isf_k2% EQU 1 echo [%time%]: Started full installation of wait.mds library files...
 if %isf_k2% EQU 2 echo [%time%]: Started installation of COM wrapper for Windows api...
 if %isf_k2% EQU 3 echo [%time%]: Started creation of index file with typeperf counters...
 if %isf_k2% EQU 4 echo [%time%]: Started creation of help ^& shrunk library version files...
) else (
 if %isf_k2% EQU 1 echo [%time%]: Started full deinstallation of wait.mds library files...
 if %isf_k2% EQU 2 echo [%time%]: Started deinstallation of COM wrapper for Windows api...
 if %isf_k2% EQU 3 echo [%time%]: Started deletion of index file with typeperf counters...
 if %isf_k2% EQU 4 echo [%time%]: Started deletion of help ^& shrunk library version files...
)
call %%wait.mds.installer%% /sub:install %isf_k1% %isf_k2%

echo [%time%]: DONE.
goto:eof_
:initialize
  for /F "tokens=1 delims==" %%a in ('set') do if defined isf_set (call set "isf_set=%%isf_set%%%%a,") else (set "isf_set=,wait.mds,%%a,")

  if not exist "..\wait.mds.bat" (echo Error [%time%]: the library file doesn't exist ["..\wait.mds.bat"]&exit /b 1)
  for %%a in ("wait.mds.installer=%%~d0%%~p0","wait.mds.installer=%%wait.mds.installer:~0,-1%%") do call set %%a
  for %%a in ("%%wait.mds.installer%%\..") do set wait.mds.installer="%%~da%%~pawait.mds.bat"
  for %%a in ("1=%~n1","2=%~n2") do set "isf_k%%~a"
  if not defined isf_k1 (echo Error [%time%]: missing value of 1st argument.&exit /b 1)
  for %%a in ("install=1","uninstall=0") do (call set "isf_k1=%%isf_k1:%%~a%%")
  for %%a in ("all=1","vbs=2","tpc=3","lib=4") do if defined isf_k2 (call set "isf_k2=%%isf_k2:%%~a%%") else set "isf_k2=1"
  set "isf_kc=1"
  for %%a in (1,0) do if "%isf_k1%"=="%%a" set "isf_kc="
  if defined isf_kc (echo Error [%time%]: unknown value of 1st argument.&exit /b 1)
  set "isf_kc=1"
  for %%a in (1,2,3,4) do if "%isf_k2%"=="%%a" set "isf_kc="
  if defined isf_kc (echo Error [%time%]: unknown value of 2nd argument.&exit /b 1)
 exit /b 0
:eof_
for /F "tokens=1 delims==" %%a in ('set') do (echo "%isf_set%" | findstr /v /i /c:",%%a,")>nul && (set "%%a=")
