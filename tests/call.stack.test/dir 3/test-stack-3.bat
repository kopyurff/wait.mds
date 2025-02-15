:: test~stack~3.bat
:: This example contains recurrent calls, which results in ambiguity in the order of calls in the stack. To resolve
:: ambiguities, the order of the values of variable arguments to called files and functions is used.
:: This file starts ambiguous loop of calls inside stack...
@echo off
setlocal&setlocal enabledelayedexpansion
set "var=TEST #3"
set "var1=TEST~3"
set "var2=TEST$3"

cd /d "..\dir 4">nul
if "%~1"=="f321" (
 echo c-3---f-4-4>nul
 set "disambiglup1=2"&set "disambiglup2=2"
 call "test-stack-4.bat" f441 f442 [#c] f444 %%disambiglup1%% %%disambiglup2%%
)
if "%~1"=="f321" (
 echo e-3---f-4-4 ^<- macro @exit failure
 exit /b 0
)

set "callit=test-stack-4.bat"
set "arg1=f411"
set "arg2=f414"
set "arg3=p314"

echo c-3---p-3-1>nul
set "disambiglup1="&set "disambiglup2="
call:myfunc_test-stack-3.1 p311 p312 [#3] %arg3% %disambiglup1% %disambiglup2%
echo e-3---p-3-1 ^<- macro @exit failure
exit /b 0

:myfunc_test-stack-3.1
 echo c-3-1-p-3-2>nul
 call:myfunc_test-stack-3.2 p321 p322 [#4] p324 %disambiglup1% %disambiglup2%
 echo e-3-1-p-3-2 ^<- macro @exit failure
exit /b 0

:myfunc_test-stack-3.2
 echo c-3-2-f-4-1>nul
 call %%callit%% !arg1! f412 [#5] %arg2% !disambiglup1! !disambiglup2! :: hi
 echo e-3-2-f-4-1 ^<- macro @exit failure
exit /b 0
