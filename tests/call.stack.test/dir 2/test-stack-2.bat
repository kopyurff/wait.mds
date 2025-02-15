:: test~stack~2.bat
:: This example contains recurrent calls, which results in ambiguity in the order of calls in the stack. To resolve
:: ambiguities, the order of the values of variable arguments to called files and functions is used.
::
@echo off&setlocal
set "var=TEST #2"
set "var1=TEST ~2"

echo c-2---f-3-1>nul
set "disambiglup1=3"&set "disambiglup2=3"
call "..\dir 3\test-stack-3.bat" f311 f312 [#2] f314 %disambiglup1% %%disambiglup2%%
echo e-2---f-3-1 ^<- macro @exit failure