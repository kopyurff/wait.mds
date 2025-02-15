@echo off&setlocal&cls
:: ------------------------------------------------------------------------------------------------------------------
::      wait.mds.tests.subroutine.bat, test performs test of subroutine exported by the wait.mds library.
::
::                                            Copyright (C) 2013-2020 Anton Kopiev
::                                                      GNU General Public License
:: ------------------------------------------------------------------------------------------------------------------
::
:: Notes: 
::  #1. There is only one general purpose public procedure in the library, the file contains one test for it;
::  #2. The call with 1st argument `/w` serves to run tests using the lite version of library installed into the home
::      folder ("%ProgramFiles%\wait.mds\wait.mds.lite.bat") and the registered variable `%wait.mds%`.
::

if "%~n1"=="w" (
 if not defined wait.mds (echo Error [%time%]: install library to register variable `wait.mds`, currently it's undefined&exit /b 1)
 call set wait_mds=%%wait.mds:"=%%
 call set wait_mds="%%wait_mds%%"
) else (
 if not exist "..\wait.mds.bat" (echo Error [%time%]: the library file doesn't exist ["..\wait.mds.bat"]&exit /b 1)
 for %%a in ("wait_mds=%%~d0%%~p0","wait_mds=%%wait_mds:~0,-1%%") do call set %%a
 for %%a in ("%%wait_mds%%\..") do set wait_mds="%%~da%%~pawait.mds.bat"
)

echo ----------------- %time:~0,8%: "%~n0" -----------------
echo.^>
echo ^>             Library file:
echo ^>             %wait_mds%
echo.^>
echo %time:~0,11%0: newFileName: %%2 = "", %%3 = "new.file.prefix", %%4 = "suffix.ext"
set "u_pfx=new.file.prefix"
set "u_sfx=suffix.ext"
call %%wait_mds%% /sub:newFileName u_nfn "" %u_pfx% %u_sfx%
echo %time:~0,11%0: DONE - new file name: %u_nfn%
echo.
set>envset.txt
echo               The environment set was saved to file `envset.txt`.
echo ----------------- %time:~0,8%: "%~n0" -----------------
echo.

