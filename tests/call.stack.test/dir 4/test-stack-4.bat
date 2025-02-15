:: test-stack-4.bat
:: This example contains recurrent calls, which results in ambiguity in the order of calls in the stack. To resolve
:: ambiguities, the order of the values of variable arguments to called files and functions is used.
:: This file contains ambiguous loop of calls inside stack...
::
@echo off 
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

set "callit=args: 0 = %0 1 = %1 2 = %2 3 = %3 4 = %4 5 = %5"

if "%~1"=="f411" (
 echo c-4---f-4-2>nul
 set "disambiglup1=1"&set "disambiglup2="
 set "var1=f423"
)
if "%~1"=="f411" (
 call test-stack-4.bat f421 "f422 %var1%" [#6] f424 %%disambiglup1%% %%disambiglup2%%
)
if "%~1"=="f411" (
 echo e-4---f-4-2 ^<- macro @exit failure
 exit /b 0
)

if "%~1"=="f421" (
 set "disambiglup1=1"&set "disambiglup2=1"
 set "var=test-stack-4.bat"
 set "var1=test_stack_4"
 set "arg434=f434"
 set "var2=f434"
 set "var3=..\dir 4\"
) else if "%~1"=="f431" (
 set "disambiglup1=2"&set "disambiglup2=1"
 set "var1=test_stack_3"
) else if "%~1"=="f441" (
 set "disambiglup1=3"&set "disambiglup2=2"
)

echo c-4---p-4-1>nul
:: Since the variables "disambiglup1" and "disambiglup2" have different values each time the label functions
:: are called, this provides a unique memory representation of their call strings and allows to find them.
:: It requires annotation `%` or `!` to keep them in memory as values, but not as their name strings...
call:myfunc_test-stack-4.1 p411 p412 [#7#a#d] p414 !disambiglup1! %disambiglup2%
echo e-4-1-p-4-2 ^<- macro @exit failure

exit /b 0

:myfunc_test-stack-4.1
 if "%var1%"=="test_stack_3" (
  echo c-4-1-f-3-2>nul
  call "..\dir 3\test-stack-3.bat" f321 f322 [#b] f324 %disambiglup1% !disambiglup2!
 )
 if "%var1%"=="test_stack_3" (
  echo e-4-1-f-3-2 ^<- macro @exit failure
  goto:eof
 )
 echo c-4-1-p-4-2>nul
 call:myfunc_test-stack-4.2 p421 p422 [#8#e] p424 %disambiglup1% !disambiglup2!
 echo e-4-1-p-4-2 ^<- macro @exit failure
exit /b 0

:myfunc_test-stack-4.2
 if "%var1%"=="test_stack_4" (
  echo c-4-2-f-4-3>nul
  call "%%var3%%%%var%%" f431 %%var1%% [#9] %%arg434%% %%disambiglup1%% %%disambiglup2%% %var2%
 )
 if "%var1%"=="test_stack_4" (
  echo e-4-2-f-4-3 ^<- macro @exit failure
  goto:eof
 )
 echo [!time!]: %%@callstack%% ^^^& reversing the order of call stack strings ...
 set "z=0"
 for /F "tokens=1,*" %%a in ('cmd /d /q /v:on /e:on /r "!@callstack! F:1"') do (
  set "a=0"&set "b="&set "c="
  for %%c in (%%b) do (
   if !a! EQU 0 (
    for /F "tokens=*" %%d in ('echo %%c') do (set "b=%%~nxd")
    set "b=!b::=!"
   ) else if !a! EQU 3 (set "b=%%c") else if !a! EQU 5 (set "b=%%c") else if !a! EQU 6 (set "b=%%c") else (set "b=")
   if defined b if defined c (set "c=!c! !b!") else (set "c=!b!")
   set /a "a+=1">NUL
  )
  set /a "z+=1">NUL&set "a!z!=!c!"
 )
 set /a "y=!z!-14"&set "x=1"&set "w=$"&for /L %%a in (!z!,-1,!y!) do (set "w=!w!!a%%a!$"&echo #!x!: !a%%a!&set /a "x+=1">NUL)
 
 set "y=Internal errors:"
 %@mac_check% @consoletext,2:y 9:y A:1 %@istrue% && (
  echo                -- PAUSE --  some error was found, paused to fix it  -- PAUSE --
 ) || if "!w!"=="$myfunc_test-stack-4.2 [#8#e] 3 2$myfunc_test-stack-4.1 [#7#a#d] 3 2$test-stack-4.bat [#c] 2 2$test-stack-3.bat [#b] 2 1$myfunc_test-stack-4.1 [#7#a#d] 2 1$test-stack-4.bat [#9] 1 1$myfunc_test-stack-4.2 [#8#e] 1 1$myfunc_test-stack-4.1 [#7#a#d] 1 1$test-stack-4.bat [#6] 1$test-stack-4.bat [#5]$myfunc_test-stack-3.2 [#4]$myfunc_test-stack-3.1 [#3]$test-stack-3.bat [#2] 3 3$test-stack-2.bat [#1] 2 2$test stack 1.bat [#0] 1 1$" (
  set "w="
 ) else (
  echo                 -- PAUSE --  unexpected result, paused to fix it  -- PAUSE --
 )
 if defined w (
  echo [!time!]: Current task information:
  %@taskinfo% 1:u_curPid 5:u_wndHdl 6:u_wndPid 2:PIDs 9:1
  echo                All PIDs: !PIDs!, cur: !u_curPid!, wnd: !u_wndPid!. Console = !u_wndHdl!
  pause>NUL
  :repeat
   <nul set /p "=Are you sure you want to continue, please enter 'Y' to confirm: "&set /p "q="
  if /i "!q!"=="y" (
   %@drop_conrows% 4
  ) else (
   %@drop_conrows% 1
   goto:repeat
  )
 ) else if "!library.waitmds.testruns!"=="2" (
  echo [!time!]: Test run with "library.waitmds.testruns==2", paused.
  echo [!time!]: Current task information:
  %@taskinfo% 1:u_curPid 5:u_wndHdl 6:u_wndPid 2:PIDs 9:1
  echo                All PIDs: !PIDs!, cur: !u_curPid!, wnd: !u_wndPid!. Console = !u_wndHdl!
  pause>NUL
  %@drop_conrows% 3
 )
 echo [!time!]: %%@exit%% 15 calls, print arguments #0, #3, #5 ^^^& #6 of each call:
 %@exit% 15 0,3,5,6
 echo Macro @exit failure ...
exit /b 0
