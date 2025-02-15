@echo off
rem echo.>"consolereader.out"
title "Console for tests"

if "%~1"=="2" (
 for /L %%a in (0,1,9) do (
  if "%random:~-1,1%"=="%%a" (echo ----  "Read this text"  ----) else (echo Some string #%%a ...)
 )
) else (echo ----  "Read this text"  ----)

set "testvar=Text to read"

ping -n 1 -w 500 192.168.254.254 >NUL 2>&1
if "%~1"=="1" for /L %%a in (1,1,2147483647) do echo %%a
if "%~1"=="2" for /L %%a in (1,1,2147483647) do echo %%a>nul