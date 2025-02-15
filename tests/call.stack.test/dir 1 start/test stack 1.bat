:: test~stack~1.bat
:: This example contains recurrent calls inside deeper calls, which results in ambiguity in the order of calls in the
:: stack. To resolve ambiguities, the order of the values of variable arguments to called files and functions is used.
@echo off&setlocal enabledelayedexpansion

:: Various activities for testing internal functionality:
call cd /d "%%~sdp0">nul

set "var=TEST #1"
call:myfunc_test-stack-1.1 a11 a12 a13
call:myfunc_test-stack-1.2 a21 a22 a23
call:myfunc_test-stack-1.3 a31 a32 a33
call:myfunc_test-stack-1.4 a41 a42 a43
call:myfunc_test-stack-1.5 a51 a52 a53
call "..\btest1.bat" b11 b12 b13
call "..\btest2.bat" b21 b22 b23
call "..\btest3.bat" b31 b32 b33

set "var2=test-stack-2.bat"
set "var3=f22"
set "var4=f23"

:: call next file:
echo c-1---f-2-1>nul
set "disambiglup1=2"&set "disambiglup2=2"
call "..\dir 2\%%var2%%" f21 !var3! [#1] %var4% %%disambiglup1%% !disambiglup2!
echo e-1---f-2-1 ^<- macro @exit failure

exit /b 0
:myfunc_test-stack-1.1
exit /b 0
:myfunc_test-stack-1.2
exit /b 0
:myfunc_test-stack-1.3
exit /b 0
:myfunc_test-stack-1.4
exit /b 0
:myfunc_test-stack-1.5
exit /b 0
