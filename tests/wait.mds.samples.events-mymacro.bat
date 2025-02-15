@echo off&setlocal&cls
:: ------------------------------------------------------------------------------------------------------------------
::      wait.mds.samples.events-mymacro.bat, contains sample of custom macro & subroutine to convert it to string for
::      storage it as a predicate value of event of type `m`.
::
::                                            Copyright (C) 2013-2020 Anton Kopiev
::                                                      GNU General Public License
:: ------------------------------------------------------------------------------------------------------------------
::
for %%a in ("tests.homepath=%%~d0%%~p0","tests.homepath=%%tests.homepath:~0,-1%%") do call set %%a
for %%a in ("%%tests.homepath%%\..") do set tests.homepath="%%~da%%~pa"
if not exist "%tests.homepath:~1,-1%\wait.mds.bat" (call echo Error [%time%]: the library file doesn't exist ["%%tests.homepath:~1,-1%%\wait.mds.bat"]&exit /b 1)

:: #1. The sample below always fires event by setting value `0` to external variable %%wds_mtm_par%%;
:: #2. To ignore specific call of macro without firing event set `1` to %%wds_mtm_par%%;
:: #3. During usual call for event validation:
::    - the macro runs in isolated context & doesn't need cleanups of local variables before completion at the end;
::    - the local context has enabled delayed extensions & allows use of exclamation controls (`!variable!`).
::
set @mymacro=^
 for %%y in (1 2) do if %%y EQU 2 for /F %%z in ('echo.%%wds_mtm_par%%') do (^
  set "%%z=0"^
 ) else set wds_mtm_par=

call:get_mymacroencoded "mymacro.txt"

goto:eof
:get_mymacroencoded - subroutine encodes @mymacro value to string value compatible with use inside events file.
::                    %~1 - file name to save encoded string.
::
  if not defined @mymacro goto:eof
  setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
  call "%%tests.homepath:~1,-1%%\wait.mds.bat" /sub:importMacros
  set "@mymacro_encoded=%@mymacro%"
  %@str_encode% @mymacro_encoded 11 "#" ";"
  for /L %%a in (1,1,8) do call set "@mymacro_encoded=%%@mymacro_encoded:  = %%"
  :: The next 2 strings contain decoding of encoded string, not required & can be removed:
  (set @mymacro_decoded="%@mymacro_encoded%")
  %@str_decode% @mymacro_decoded "#" ";"
  set | findstr /C:"@mymacro">"%~1"
  echo The encoded ^& original custom macro saved to "%~1"
exit /b 0
