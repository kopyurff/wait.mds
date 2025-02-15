@echo off&setlocal&cls
:: ------------------------------------------------------------------------------------------------------------------
::      wait.mds.tests.events.bat, the test suite to do basic checks of events handling by the wait.mds library.
::
::                                            Copyright (C) 2013-2020 Anton Kopiev
::                                                      GNU General Public License
:: ------------------------------------------------------------------------------------------------------------------
::
:: Notes:
::  #1. The 1st argument defines set of tests:
::    #1.1 Any its value except `/a` or `a` runs only tests of events in isolated context with enabled expansions;
::    #1.2 With `/a` value it runs preliminary 2 rounds of tests with disabled expansions, the 1st round works with
::         shared context and uses external import of macros from batch file (it corresponds to `/c /macro` keys);
::  #2. The 2nd argument requires 1st argument and can have next values:
::    #2.1 `/w` - requires preliminary installation and runs tests using the lite version of library installed into
::         the home folder  ("%ProgramFiles%\wait.mds\wait.mds.lite.bat") and the registered variable `%wait.mds%`;
::    #2.2. `/t` - defines variable `library.waitmds.testruns` to keep last temporary files in the `%TEMP%` folder
::         without their immediate deletion;
::
::  #3 The default call without any arguments runs only single round of test suite from #1.1, uses install version 
::     of library ("..\wait.mds.bat");
::
for %%a in ("tests.homepath=%%~d0%%~p0","tests.homepath=%%tests.homepath:~0,-1%%","use.install.version=") do call set %%a
for %%a in ("%%tests.homepath%%\..") do set tests.homepath="%%~da%%~pa"
if "%~n1"=="a" (set "test_runnum=1") else (set "test_runnum=4")
if "%~n2"=="t" (set library.waitmds.testruns=1) else set "use.install.version=1"
if "%~n2"=="w" set "use.install.version="
call:initialize_tests || goto:eof

echo ~~~~~~~~~~~~~~~~~~~~~ %time:~0,8%: "%~n0" ~~~~~~~~~~~~~~~~~~~~~
echo ^> Windows application process id:     "apppid" = %u_apppid%
echo ^> Application test window handle:     "apphdl" = %u_apphdl%
echo ^> Application test window {class*}:   "appcls" = "WindowsForms10.Window"
echo ^> Application test window caption:    "appcap" = "Form1"
echo ^> The handle of its button "Button1": "buthdl" = %u_buthdl%
echo ^> Console test window handle:         "conhdl" = %u_conhdl%
echo ^> Test items of the console:
echo ^>     - last text line:       "exptxt" = %u_exptxt%
echo ^>     - environment variable: "envvar" = %u_envvar%
echo ^>     - value of variable:    "envval" = %u_envval%
echo ^> Local custom macro for tests:       "@mymacro"
echo ^> Events:                             "evefil"     = ^>^>
(<nul set /p "=>")&(echo %u_evefile%)
echo ^> Library:                            "%%wait.mds%%" = ^>^>
(<nul set /p "=>")&(echo %wait.mds%)

:wait.mds.events.tests.loop
 if %test_runnum% LSS 3 (set "testmode=/c /macro") else (set "testmode=")
 if %test_runnum% EQU 1 (
  setlocal ENABLEEXTENSIONS DISABLEDELAYEDEXPANSION
  call %%wait.mds%% /sub:importMacros
  call:get_mymacro
 ) else (
  setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
  if %test_runnum% LSS 3 (
   call %%wait.mds%% /sub:importMacros
  ) else (
   call %%wait.mds%% /sub:importMacros "%%~snx0"
  )
  call:get_mymacro
 )
 if not defined @isok goto:wait.mds.events.tests.error
 %@isok% || (echo Error [%time%]: Macros have inadequate state of delayed expansions, last import failed&exit /b 1)
 if not defined @isok (
  :wait.mds.events.tests.error
  echo Error [%time%]: Failed import of macros for tests&exit /b 1
 )

 echo/
 if %test_runnum% EQU 1 (
  echo ~ %time:~0,8%: test run #1 - communicative mode, disabled delayed expansions ~~
 ) else if %test_runnum% EQU 2 (
  echo ~~ %time:~0,8%: test run #2 - communicative mode, enabled delayed expansions ~~
 ) else if %test_runnum% EQU 3 (
  echo ~~~~~~~~~~~~~ %time:~0,8%: test run #3 - silent or buffered mode ~~~~~~~~~~~~~~
 ) else (
  echo ~ %time:~0,8%: Partial run of tests in silent mode [use key /a for all tests] ~
 )
 echo [%time%]: Event "f", file "evefil", expected "UNLOCKED":
 call %%wait.mds%% %testmode% /w:5000 2500 /t:f /i:u_evefile /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "p", wait process module "cmd*" ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:p /i:"cmd*" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "c", window caption "*tests#2A;" ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:c /i:"*tests#2A;" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "~i", wait process id "apppid" exit ^<=^> TIMEOUT:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:~i /i:u_apppid /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, TIMEOUT
 echo                Event "a", attribute "~r" of "evefil" ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:a /i:u_evefile?"~r" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "h", window "apphdl", wait state "2" ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:h /i:u_apphdl?"2" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "h", "apphdl" owns button "buthdl", s.8 ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:h /i:u_buthdl?"8"?u_apphdl /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "l", window "appcls"-"appcap" exists ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:l /i:"WindowsForms10.Window"?"Form1"?"0" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "s", frozen screenshot of "apphdl" window ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:25000 2500 /t:s /i:"%u_apphdl%" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "r", console "conhdl", has text "exptxt" ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:30000 2500 /t:r /i:u_conhdl?u_exptxt /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "w", console "envvar"="envval" [explicit] ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:w /i:"%u_conhdl%"?"testvar"?"Text to read" /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "w", console "envvar"="envval" [variables] ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:w /i:u_conhdl?u_envvar?u_envval /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "n", wait network devices idle state ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:n /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "d", wait disk devices idle state ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:d /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "~v", wait disk free space ^>3%% ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:~v /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "~u", wait CPU activities ^>3%% ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:~u /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "~t", wait task activities ^>3%% ^<=^> UNLOCKED:
 call %%wait.mds%% %testmode% /w:5000 2500 /t:~t /r:u_evecom /n:u_evetyp
 call:report_test_result %u_evecom%, u_evetyp, UNLOCKED
 echo                Event "e", check events from file "wait.events.json":
 call %%wait.mds%% %testmode% /w:5000 2500 /t:e /i:"wait.events.json" /r:u_evecom /n:u_evetyp
 call echo [%time%]: %u_evecom%, check expected result for every event:
 (set u_expeve="01-F ~f timeout","02-C c","03-P","04-I","05-N n","06-D d","07-V ~v","08-U ~u","09-T ~t","10-M1 m","11-M2 m","12-A a","13-L-APP l","14-L-BUTTON l","15-H h","16-R r","17-W w","18-S s","19-BAD-PARAMETERS ~p bad parameters","20-ERROR w error")
 for %%a in (%u_expeve%) do for /F "tokens=1,* delims= " %%b in ('"echo %%~a"') do (
  set "u_result="
  for %%d in (%u_evetyp%) do for /F "tokens=1,* delims= " %%e in ('"echo %%~d"') do if %%b==%%e (
   if %%c==%%f (set u_result=PASS, id "%%b", reported "%%c") else (set u_result=FAIL, id "%%b", received "%%f", expected "%%c")
   call echo                %%u_result%%
  )
  if not defined u_result (
   if "%%~c"=="" (set u_result=PASS, id "%%b", not reported) else (set u_result=FAIL, id "%%b", not reported, expected "%%c")
   call echo                %%u_result%%
  )
 )
set /a "test_runnum+=1"
if %test_runnum% LSS 4 (
 call %%wait.mds%% /sub:unsetMacros
 goto:wait.mds.events.tests.loop
) else (
 echo                @closewindow: close test windows ^& exit tests...
 %@closewindow% u_conhdl
 %@closewindow% u_apphdl
 %@compareshots% u_result 5:u_apppid 6:1
 call %%wait.mds%% /sub:unsetMacros
)
set>envset.txt
echo [%time%]: The environment set was saved to file `envset.txt`.
echo ~~~~~~~~~~~~~~~~~~~~~ %time:~0,8%: "%~n0" ~~~~~~~~~~~~~~~~~~~~~
goto:eof

::--------------------------------------------------------
::-- Subroutines:
::--------------------------------------------------------
:initialize_tests
  echo Tests initialization, starting of test applications ....
  if not exist "%tests.homepath:~1,-1%com.api.wrapper\test_batch.bat" (echo Error [%time%]: the console script for tests doesn't exist ["%tests.homepath:~1,-1%com.api.wrapper\test_batch.bat"]&exit /b 1)
  if not exist "%tests.homepath:~1,-1%com.api.wrapper\test_forms.exe" (echo Error [%time%]: the windows forms application for tests doesn't exist ["%tests.homepath:~1,-1%com.api.wrapper\test_forms.exe"]&exit /b 1)
  if not exist "%tests.homepath:~1,-1%wait.mds.bat" (echo Error [%time%]: the library file doesn't exist ["%tests.homepath:~1,-1%\wait.mds.bat"]&exit /b 1)
  if defined use.install.version (call set wait.mds="%%tests.homepath:~1,-1%%wait.mds.bat") else (
   if not defined wait.mds (echo Error [%time%]: install library to register variable `wait.mds`, currently it's undefined&exit /b 1)
   call set wait.mds=%%wait.mds:"=%%
   call set wait.mds="%%wait.mds%%"
  )
  if not exist %wait.mds% (echo Error [%time%]: the library file doesn't exist [%wait.mds%]&exit /b 1)
  (call set u_evefile="%%tests.homepath:~1,-1%%Tests\wait.events.json")
  call:tests_startup
  call %%wait.mds%% /sub:importMacros
  if defined @isok (
   %@isok% || (echo Error [%time%]: Macros have inadequate state of delayed expansions, last import failed&exit /b 1)
  ) else (
   echo Error [%time%]: Macros import failed&exit /b 1
  )
  %@mac_check% @findwindow,"" "Console/CHR{20}for/CHR{20}tests" 1:u_conhdl,u_conhdl %@istrue% || (
   (call set u_aux="%%tests.homepath:~1,-1%%com.api.wrapper\test_batch.bat" 2)&set "u_conhdl="&%@runapp% 0 u_aux
  )
  %@mac_check% @findwindow,"WindowsForms10.Window" "Form1" 1:u_apphdl,u_apphdl %@istrue% || (
   (call set u_aux="%%tests.homepath:~1,-1%%com.api.wrapper\test_forms.exe")&set "u_apphdl="&%@runapp% 0 u_aux
  )
  if not defined u_conhdl (
   %@mac_check% @findwindow,"" "Console/CHR{20}for/CHR{20}tests" 1:u_conhdl 2:25000,u_conhdl %@istrue% || (echo [%time%] Error: the test console window wasn't found running.&exit /b 1)
  )
  if not defined u_apphdl (
   %@mac_check% @findwindow,"WindowsForms10.Window" "Form1" 1:u_apphdl 2:25000,u_apphdl %@istrue% || (echo [%time%] Error: the windows forms application wasn't found running.&exit /b 1)
  )
  %@mac_wrapper% @findcontrol,u_buthdl u_apphdl "BUTTON" "Button1",u_buthdl
  %@mac_wrapper% @pidofwindow,u_apppid u_apphdl,u_apppid
  (set u_exptxt=----  "Read this text"  ----)&(set "u_envvar=testvar")&(set "u_envval=Text to read")
  %@mac_wrapper% @foregroundwindow,u_curhdl 2:1,u_curhdl
 exit /b 0
::--------------------------------------------------------
:tests_startup
  (setlocal enabledelayedexpansion
   set "rep= will be created automatically, it takes ~2-4 min when it queried by a corresponding macro..."
   if exist "%ProgramFiles%\wait.mds\WaitMdsApiWrapper.tlb" (
    if not exist "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id001" (echo.&echo [%time%]: The performance counter index file!rep!&echo.)
   ) else (
    if exist "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id001" (
     echo.&echo [%time%]: The COM server library!rep!&echo.
    ) else (
     echo.&echo [%time%]: The COM server library ^& the performance counter index file!rep!&echo.
    )
   )
  )
 exit /b 0
::--------------------------------------------------------
:report_test_result
  if %~1==%~3 (set u_result=PASS) else (set u_result=FAIL)
  call echo [%time%]: %u_result% - %~1, event "%%%~2%%"
  set "%~2="
 exit /b 0
::--------------------------------------------------------
:get_mymacro
  set @mymacro=^
   for %%y in (1 2) do if %%y EQU 2 for /F %%z in ('echo.%%wds_mtm_par%%') do (^
    set "%%z=0"^
   ) else set wds_mtm_par=
 exit /b 0
::--------------------------------------------------------