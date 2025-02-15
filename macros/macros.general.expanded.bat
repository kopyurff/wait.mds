@echo off
::          @errorLevel - sets error level equal to digital value following this macro.
::                  Note: macro has not any parameters, returns result as error level.
::                Sample: `%@errorLevel% 1`
::
set "@errorLevel=cmd /d /q /c exit /b"

::                @isok - checks adequacy of macros definition to the current state of delayed expansions.
::                  Note: macro has not any parameters, returns result as error level.
::                Sample: `%@isok% && echo OK || echo FAIL`
::          Dependencies: @errorLevel.
::
set @isok=(for /F %%z in ('echo wds_iso_') do if defined PATH (^
 set "%%ze="^&set "%%zp=^^^!PATH^^^!"^&call set "%%zp=%%%%zp:PATH=%%"^&call set "%%zp=%%%%zp:~1,-1%%"^&set "%%zc=C:\"^&^
 (if exist "^!%%zc^!" (^
  if not "^!%%ze^!"=="" if defined %%zp (set "%%zp=") else (set "%%zp=1")^
 ) else for /F %%y in ('"echo.^!%%zc^!"') do if exist "%%y" (set "%%zp=1") else (^
  (for /F %%x in ('echo."%%%%ze%%"') do (call set "%%zc=%%~x"))^&^
  (if not defined %%zc (call set "%%zp=%%%%zp:~1,-1%%"))^&^
  (if defined %%zp (set "%%zp=") else (set "%%zp=1"))^
 ))^&^
 set "%%zc="^&(if defined %%zp (set "%%zp=1") else (set "%%zp=0"))^
) else (set "%%zp=1"))^&for /F %%z in ('echo %%wds_iso_p%%') do set "wds_iso_p="^&%@errorLevel% %%z

::                @exit - exits running script until end of call stack of batch files.
::                        %~1 == optional numerical parameter to set the number of stack calls to quit (default value is 16 calls);
::                        %~2 == can be defined only with specified `%~1`, contains CSV list of parameter numbers inside stack to
::                               print.
::             Notes. #1: The macro is only for usual calls from a script file, only applicable to the `cmd.exe` console process;
::                    #2: If the call stack contains calls inside `if (..) else (..)` or `for-in-do (...)` blocks the leftover of
::                        code inside these blocks can continue to execute despite undergoing exit. This behavior, along with the 
::                        `exit` command inside such blocks, may affect this macro, which may require adjustments of `%~1` value.
::                Sample: `%@exit% 10 0,2,4`          - exit 10 calls in stack and print `0`, `2` and `4` arguments of its items.
::
set @exit=^
 for /F %%y in ('echo wds_ecs_') do for %%z in (1 2) do if %%z EQU 2 (^
  (if not defined %%ynum (set "%%ynum=16"))^&^
  (for /F "tokens=1,2" %%a in ('echo %%%%ynum%%') do (^
   (set /a "%%ynum=%%a"^>NUL 2^>^&1 ^|^| set "%%ynum=16")^&^
   (for /F %%c in ('echo %%%%ynum%%') do (set "%%ynum="^&for /L %%d in (1,1,%%c) do (^
    (if not "%%b"=="" (^
     (for %%e in (%%b) do if "%%e"=="0" (^
      call set "%%ynum=%%0"^&^
      (for /F "tokens=*" %%f in ('echo %%%%ynum%%') do (set "%%ynum=%%~nxf"))^
     ) else if defined %%ynum (call set "%%ynum=%%%%ynum%% %%%%e") else (call set "%%ynum=%%%%e"))^&^
     (for /F "delims=:" %%e in ('echo %%%%ynum%%') do (set "%%ynum=%%e"))^&^
     call echo #%%d: %%%%ynum%%^>con^&set "%%ynum="^
    ))^&^
    (if %%d LSS %%c (goto) 2^>NUL else (goto:eof))^
   )))^
  ))^
 ) else set %%ynum=

::               @error - reports error and exits running script.
::                        %~1 == the parameter, can serve for following:
::                            - custom prefix substring of the error message (to specify macro, subroutine, section name etc),
::                              this call exits only current context with the exit code `1`;
::                            Next 2 types perform termination of all call stack, only applicable to the `cmd.exe` console process:
::                            - wildcard `*` to exit script and report call stack;
::                            - numerical value with prefix `#` to exit only given number of calls (partial exit with report stack);
::                        %~2 == text of error message to print.
::                  Note: The macro is intended only for normal calls from a script file.
::
set @error=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_err_emp (^
  (for /F "tokens=1,*" %%a in ('echo %%wds_err_emp%%') do (^
   ((echo %%a ^| findstr /B /C:"#" ^| findstr [0-9])^>NUL 2^>^&1 ^&^& (^
    set "wds_err_pfx=#"^&set "wds_err_emp=%%a "^&call set "wds_err_emp=%%wds_err_emp:~1,-1%%"^
   ) ^|^| (if "%%a"=="*" (^
    set "wds_err_pfx=%%a"^&set "wds_err_emp=4096"^
   )))^&^
   (if defined wds_err_pfx (^
    (for /F "tokens=1,2,3" %%c in ('"call echo %%wds_err_emp%% %%wds_err_pfx%%"') do (^
     call set "wds_err_pfx=%%0"^&^
     echo.^&call echo ERROR [%%wds_err_pfx%%]: %%b.^>con^&echo CALL STACK EXIT:^>^>con^&^
     set "wds_err_pfx="^&^
     (for /L %%q in (1,1,%%c) do if not defined wds_err_pfx (^
      call set "wds_err_pfx=%% "^&^
      (for /F "tokens=2 delims=()" %%r in ('echo %%wds_err_pfx%%') do if /i "%%r"=="echo" (^
       set "wds_err_pfx="^&^
       call echo  [#%%q] %%0 %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9^>^>con^&^
       (goto) ^>NUL 2^>^&1^
      ))^
     ))^&^
     set "wds_err_pfx="^
    ))^
   ) else (call echo Error [%%a]: %%b.^&set "wds_err_emp="^&exit /b 1))^
  ))^
 )) else set wds_err_emp=

::        @echo_imprint - prints text into the same console line without caret return, supports masking of its own older output.
::                        %~1 == [optional: quoted text to print or variable name containing text].
::             Notes. #1: The call without parameter blanks current line by space symbols;
::                    #2: The macro is intended only for normal calls from a script file.
::
set @echo_imprint=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%y in ('echo wds_emp_') do (^
  (if defined %%ycrs (^
   (for /F "tokens=*" %%a in ('echo.%%%%yimp%%') do (^
    set "%%yimp="^&(if "%%~a"==%%a (set "%%yimp=%%~a") else if defined %%~a (call set "%%yimp=%%%%~a%%"))^
   ))^&^
   set "%%ybla="^&(set %%yaux="^^^|")^&^
   (for /F %%a in ('"copy /Z %%%%ycrs%% nul"') do if not defined %%ybla (^
    (for /F "skip=1" %%b in ('"echo prompt $H %%%%yaux:~-2,1%% cmd /d /q /k"') do (^
     (for /F "skip=4 tokens=2" %%c in ('mode con') do if not defined %%ybla for /L %%d in (1,1,%%c) do (^
      if defined %%ybla (call set "%%ybla= %%%%ybla%%") else (set "%%ybla= ")^
     ))^&^
     call set "%%ybla=%%%%ybla:~1%%"^&^
     (for /F "tokens=*" %%c in ('echo "%%%%ybla%%"') do (^<nul set /P "=%%b%%~c%%a"))^&^
     (if defined %%yimp for /F "tokens=*" %%c in ('echo."%%%%yimp%%"') do (^<nul set /P "=%%b%%~c%%a"))^
    ))^
   ))^
  ) else (^
   (for /F "tokens=1,2" %%a in ('echo."%%" @echo_imprint') do (^
    (call set %%ycrs="%%~a~dpf0")^&(call cmd /d /q /r "%%%%b%% %%%%yimp%%")^
   ))^&^
   set "%%ycrs="^&set "%%yimp="^
  ))^
 )) else set wds_emp_imp=

::           @imprintxy - prints text with shift of the row and the column and returns caret into initial position.
::                        %~1 == optional: quoted text to print or variable name containing text;
::            Precaution: It's optional parameter, but if specified it must reside before others at 1st position.
::                        Next optional parameters can be specified in any order:
::                      1:%~2 == positive horizontal digital shift of caret to target position;
::                      2:%~3 == positive vertical digital shift of caret to target position;
::                      3:%~4 == key value to specify blanking of string by space symbols (default, `1`), `0` to skip;
::                      4:%~5 == the digital value of width at target position to be blanked, default is until the row end.
::                      5:%~6 == optional service symbol, explicit char value as is (see also note #2).
::             Notes. #1: One of parameters `1:%~2` or `2:%~3` must have positive value;
::                    #2: The parameter `5:%~6` is for legacy consoles only and only for short unblanked strings to be printed.
::                        By default it uses ` ` symbol, specify another if it conflicts with background, for instance: `5:X` ;
::                    #3: Parameter `4:%~5` is valid only with key `3:%~4`;
::                    #4: The explicit string inside paramater `%~1` can have space symbols ` `, also supported `/CHR{20}`;
::                    #5: This macro can work without enabled delayed expansion;
::                    #6: The macro is intended only for normal calls from a script file.
::
set @imprintxy=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ixy_par for /F %%y in ('echo wds_ixy_') do (^
  (if defined %%yaux (^
   set "@imprintxy="^&^
   (for /F "tokens=2,3,4,5,*" %%a in ('echo.%%%%ypar%%') do (^
    set "%%ypar=%%e"^&^
    (for /F "tokens=*" %%f in ('"echo %%%%ypar:%%a=%%"') do if not "%%e"=="%%f" (^
     (for /F "tokens=*" %%g in ('cmd /d /q /r "for /F %%btokens%%b=%%b1%%b,%%b*%%b %%bdelims%%b=%%b%%a %%^^a in %%c'echo %%e'%%d do %%cecho %%^^a%%d^^^&%%cecho %%^^b%%d"') do ^
      if defined %%yimp (set %%ypar=%%g) else (set %%yimp=%%g)^
     )^
    ))^&^
    (for /F "skip=3 tokens=2 delims=:" %%f in ('mode con') do if defined %%yhy (^
     if not defined %%ywx (set "%%ywx=%%~f"^&call set "%%ywx=%%%%ywx: =%%")^
    ) else (^
     set "%%yhy=%%~f"^&call set "%%yhy=%%%%yhy: =%%"^
    ))^>NUL 2^>^&1^&^
    (for /F "tokens=2,3 delims=[.]" %%f in ('ver') do for %%h in (%%f%%g) do (^
     (if defined %%yver (if %%h EQU 100 (set /a "%%ywx+=1"^>NUL 2^>^&1) else (^
      set "%%ymax=for %%^^a in %%c%%%%yup%% %%%%yle%% %%%%ytw%% %%%%ybw%%%%d do %%cset %%yck=1%%%%ypar:~-2,1%%%%cfor %%^^b in %%c%%%%yup%% %%%%yle%% %%%%ytw%% %%%%ybw%%%%d do if %%^^a LSS %%^^b %%cset %%yck=%%d%%d%%%%ypar:~-2,1%%%%cif defined %%yck %%c%%cecho %%^^a%%d%%%%ypar:~-2,1%%%%cexit /b 0%%d%%d%%d%%d"^
     )))^&^
     set "%%yver=%%h"^
    ))^&^
    (for %%f in ("bk=1","up=0","le=0") do (set "%%y%%~f"))^&^
    (for /F "tokens=1,2,*" %%f in ('echo.%%%%ywx%% %%%%yhy%% - specified value must be inside range %%c0') do (^
     (for /F "tokens=*" %%i in ('echo.%%%%ypar%%') do for %%j in (%%i) do for /F "tokens=1,2 delims=:" %%k in ('echo.%%j') do if "%%~l"=="" (^
      (if defined %%yimp (echo Error [@imprintxy]: Multiple declaration of parameter #1.^&exit /b 1))^&^
      (if not defined %%~k (echo Error [@imprintxy]: Expected string value inside variable name `%%k` of parameter #1.^&exit /b 1))^&^
      call set "%%yimp=%%%%k%%"^
     ) else ((echo ",1,2,3,4,5," ^| findstr /C:",%%k,")^>NUL 2^>^&1) ^&^& (^
      set "%%ypar="^&^
      (if %%k EQU 1 (^
       set "%%ypar= %%h,%%f%%d."^&^
       (set /a "%%ydx=%%l")^>NUL 2^>^&1 ^&^& (if 0 LSS %%l if %%l LSS %%f (set "%%ypar="))^
      ) else if %%k EQU 2 (^
       set "%%ypar= %%h,%%g%%d."^&^
       (set /a "%%ydy=%%l")^>NUL 2^>^&1 ^&^& (if 0 LSS %%l if %%l LSS %%g (set "%%ypar="))^
      ) else if %%k EQU 3 (^
       if "%%l"=="0" (set "%%ybk=")^
      ) else if %%k EQU 4 (^
       set "%%ypar= %%h,%%f%%d."^&^
       (set /a "%%ybw=%%l")^>NUL 2^>^&1 ^&^& (if 0 LEQ %%l if %%l LSS %%f (set "%%ypar="))^
      ) else if %%k EQU 5 if not "%%~l"=="" (^
       set "%%yss=%%l"^&call set "%%yss=%%%%yss:~0,1%%"^
      ))^&^
      (if defined %%ypar (call echo Error [@imprintxy]: Expected digital value in parameter #%%k%%%%ypar%%^&exit /b 1))^
     ))^
    ))^&^
    (for /F "delims==" %%f in ('"set %%%%yaux:~-2,1%% find /V %%a%%y%%a %%%%yaux:~-2,1%% find /V /I %%aCOMPUTERNAME%%a %%%%yaux:~-2,1%% find /V /I %%aComSpec%%a %%%%yaux:~-2,1%% find /V /I %%aSystemRoot%%a %%%%yaux:~-2,1%% find /V /I %%aPath%%a %%%%yaux:~-2,1%% find /V /I %%aTEMP%%a"') do (set "%%f="))^>NUL 2^>^&1^&^
    (for /F "delims==" %%f in ('"set %%%%yaux:~-2,1%% findstr /V /I /BC:%%a%%y%%a /BC:%%aCOMPUTERNAME%%a /BC:%%acomspec%%a /BC:%%aSystemRoot%%a /BC:%%aPath%%a /BC:%%aTEMP%%a"') do (set "%%f="))^>NUL 2^>^&1^&^
    (if defined %%yimp (call set "%%yimp=%%%%yimp:/CHR{20}= %%"))^
   ))^&^
   (if defined %%ydx (^
    (if not defined %%ydy for /F %%a in ('echo.%%%%yver%%') do if %%a LSS 100 (set "%%ydy=1"^&(echo.)^>con) else (set "%%ydy=0"))^&^
    set "%%yle=1"^
   ) else if defined %%ydy (set "%%ydx=0") else (echo Error [@imprintxy]: One of parameters #1:2 or #2:3 must be defined.^&exit /b 1))^&^
   (for /F "skip=1" %%a in ('"echo prompt $E %%%%yaux:~-2,1%% cmd /d /q /k"') do (set "%%yes=%%a"))^&^
   (if defined %%ybk if defined %%ybw (^
    call set /a "%%ytmp=%%%%ywx%%-1-%%%%ydx%%"^>NUL 2^>^&1^&^
    (for /F "tokens=1,2" %%a in ('echo.%%%%ybw%% %%%%ytmp%%') do if %%b LSS %%a (^
     set "%%ybw=%%b"^
    ))^
   ) else (call set /a "%%ybw=%%%%ywx%%-1-%%%%ydx%%"^>NUL 2^>^&1) else (set "%%ybw="))^&^
   (if defined %%yimp (^
    set "%%ytw=1"^&call set "%%ypar=%%%%yimp%%"^&^
    (for %%a in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     call set "%%ytmp=%%%%ypar:~%%a,1%%"^&(if defined %%ytmp (call set "%%ypar=%%%%ypar:~%%a%%"^&set /a "%%ytw+=%%a"^>NUL))^
    ))^&^
    call set /a "%%ypar=%%%%ydx%%+%%%%ytw%%, %%ytmp=%%%%ywx%%-1-%%%%ydx%%-%%%%ytw%%"^>NUL 2^>^&1^&^
    (for /F "tokens=1,2,3" %%a in ('echo.%%%%ypar%% %%%%ywx%% %%%%ytmp%%') do if %%b LEQ %%a (^
     call set "%%yimp=%%%%yimp:~0,%%c%%"^&set /a "%%ytw-=%%c"^>NUL 2^>^&1^
    ))^
   ))^&^
   ((call echo ,%%%%yver%%,) ^| findstr /C:",100,")^>NUL 2^>^&1 ^&^& (^
    call set "%%yout=%%%%yes%%7"^&^
    (for /F "tokens=1,2" %%a in ('echo.%%%%ydx%% %%%%ydy%%') do (^
     (if 0 LSS %%b (call set "%%yout=%%%%yout%%%%%%yes%%[%%%%ydy%%A"))^&^
     (if 0 LSS %%a (call set "%%yout=%%%%yout%%%%%%yes%%[%%%%ydx%%C"))^
    ))^&^
    (if defined %%ybw (^
     (for /F %%a in ('echo.%%%%ybw%%') do for /L %%b in (1,1,%%a) do (call set "%%yout=%%%%yout%% "))^&^
     (if not defined %%yimp (call set "%%yout=%%%%yout%%%%%%yes%%8"))^&^
     (^<nul call set /p "=%%%%yout%%")^&^
     (if defined %%yimp (^
      (echo.)^&(^<nul call set /p "=%%%%yes%%[1A%%%%yes%%[%%%%ydx%%C%%%%yimp%%%%%%yes%%8")^
     ))^
    ) else (^<nul call set /p "=%%%%yout%%%%%%yimp%%%%%%yes%%8"))^>con^&^
    exit /b 0^
   )^&^
   (for /F "skip=4 delims=pR tokens=2" %%a in ('reg query hkcu\environment /V temp' ) do (set "%%ytab=%%a"))^&^
   (if not defined %%ytab for /F "tokens=2 delims=0123456789" %%a in ('shutdown /? %%%%yaux:~-2,1%% findstr /BC:E') do (set "%%ytab=%%a"))^&^
   (for /F "skip=1" %%a in ('"echo prompt $H %%%%yaux:~-2,1%% cmd /d /q /k"') do (set "%%ybs=%%a"))^&^
   (^
    call set /a "%%yup=2+%%%%ywx%%*(%%%%ydy%%-1)/8+(9-(%%%%ydx%%+6)/8)"^&(if defined %%yle (call set /a "%%yle=8-(%%%%ydx%%+6)%%8"))^
   )^>NUL 2^>^&1^&^
   (set %%ypar="^^^&")^&(for /F %%a in ('cmd /d /q /r "%%%%ymax%%"') do (set "%%ypar=%%a"))^&^
   (for /F "tokens=1,2" %%a in ('echo.%%%%ypar%% %%%%yle%%') do (^
    (for /L %%c in (1,1,%%a) do (^
     if defined %%ybss (call set "%%ybss=%%%%ybss%%%%%%ybs%%") else (call set "%%ybss=%%%%ybs%%")^
    ))^&^
    (if 0 LSS %%b (^
     if defined %%yss (call set "%%ybsl=%%%%yss%%%%%%ybss:~0,%%b%%") else (call set "%%ybsl= %%%%ybss:~0,%%b%%")^
    ))^
   ))^&^
   (for /F %%a in ('echo.%%%%yup%%') do if defined %%ybsl (^
    call set "%%yout=%%%%ytab%%%%%%ybss:~0,%%a%%%%%%ybsl%%"^
   ) else (^
    call set "%%yout=%%%%ytab%%%%%%ybss:~0,%%a%%"^
   ))^&^
   (if defined %%ybk (^
    (for /F %%a in ('echo.%%%%ybw%%') do for /L %%b in (1,1,%%a) do if defined %%ybks (^
     call set "%%ybks=%%%%ybks%%%%%%ybs%%"^&call set "%%yaux=%%%%yaux%% "^
    ) else (^
     call set "%%ybks=%%%%ybs%%"^&set "%%yaux= "^
    ))^&^
    call set "%%yaux=%%%%yaux%%%%%%ybks%%"^&^
    (if defined %%yout (call set "%%yout=%%%%yout%%%%%%yaux%%") else (call set "%%yout=%%%%yaux%%"))^
   ))^&^
   (if defined %%yimp if defined %%yout (call set "%%yout=%%%%yout%%%%%%yimp%%") else (call set "%%yout=%%%%yimp%%"))^&^
   (if defined %%yout (^
    (call echo %%%%yout%%)^&(for /F %%a in ('echo.%%%%ydy%%') do for /L %%c in (2,1,%%a) do (echo.))^
   ))^>con^
  ) else (^
   (for /F "tokens=1,2" %%a in ('echo."%%" @imprintxy') do (^
    (set %%yaux="^^^|")^&(for /F "tokens=*" %%c in ('start /b /i /realtime cmd /d /q /r "%%%%b%% " " ^^^^^ ( ) %%%%ypar%%"') do (echo %%c^&exit /b 0))^
   ))^&^
   set "%%yaux="^&set "%%ypar="^
  ))^
 ) else (echo Error [@imprintxy]: Absent parameters.^&exit /b 1)) else set wds_ixy_par=

::        @drop_conrows - clears the specified number of last console rows and moves the caret up to the highest cleared row.
::                        %~1 == number of rows to clear, explicit numeric positive value.
::
set @drop_conrows=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_dcr_par for /F %%y in ('echo wds_dcr_') do (^
  (if defined %%yaux for /F "tokens=1,2" %%a in ('"echo.%%%%yaux:~0,1%% %%%%yaux:~-2,1%%"') do (^
   set "%%yaux=,"^&(for /F "tokens=1 delims==" %%c in ('set') do (call set "%%yaux=%%%%yaux%%%%c,"))^&^
   (for %%c in (COMPUTERNAME,TEMP,SystemRoot,Path,%%ypar) do (call set "%%yaux=%%%%yaux:,%%c,=,%%"))^&^
   (for /F %%c in ('"echo.%%%%yaux:~1,-1%%"') do for %%d in (%%c) do (set "%%d="))^&^
   (for /F %%c in ('echo.%%%%ypar%%') do (^
    (for /F "delims==" %%d in ('"set %%b find /V /I %%aCOMPUTERNAME%%a %%b find /V /I %%aComSpec%%a %%b find /V /I %%aSystemRoot%%a %%b find /V /I %%aPath%%a %%b find /V /I %%aTEMP%%a"') do (set "%%d="))^>NUL 2^>^&1^&^
    (for /F "delims==" %%d in ('"set %%b findstr /V /I /BC:%%aCOMPUTERNAME%%a /BC:%%acomspec%%a /BC:%%aSystemRoot%%a /BC:%%aPath%%a /BC:%%aTEMP%%a"') do (set "%%d="))^>NUL 2^>^&1^&^
    (set /a "%%ydy=%%c")^>NUL 2^>^&1^&^
    (if defined %%ydy (^
     (for /F "skip=3 tokens=2 delims=:" %%d in ('mode con') do if defined %%yhy (^
      if not defined %%ywx (set "%%ywx=%%~d"^&call set "%%ywx=%%%%ywx: =%%")^
     ) else (^
      (for /F %%e in ('echo.%%~d') do if 0 LSS %%c if %%c LSS %%e (set "%%yhy=%%~e"))^&^
      (if not defined %%yhy (echo Error [@drop_conrows]: Parameter #1 value is out of console size.^&exit /b 1))^
     ))^>NUL 2^>^&1^
    ) else (^
     echo Error [@drop_conrows]: Expected positive numeric value in parameter #1.^&exit /b 1^
    ))^&^
    (for /F "tokens=2,3 delims=[." %%d in ('ver') do for /F "tokens=2" %%f in ('echo %%d%%e') do (^
     (if 100 LEQ %%f (set /a "%%ywx+=1"^>NUL 2^>^&1))^&^
     set "%%yver=%%f"^
    ))^
   ))^&(if not defined %%yver (echo Error [@drop_conrows]: Absent parameters, verify spaces.^&exit /b 1))^&^
   set /a "%%ydy+=1"^>NUL 2^>^&1^&^
   set "%%yec= "^&^
   (for /F %%c in ('echo.%%%%ywx%%') do for /L %%d in (3,1,%%c) do (call set "%%yec=%%%%yec%% "))^&^
   (for /F "skip=4 delims=pR tokens=2" %%c in ('reg query hkcu\environment /V temp') do (set "%%ytab=%%c"))^&^
   (if not defined %%ytab for /F "tokens=2 delims=0123456789" %%c in ('shutdown /? %%b findstr /BC:E') do (set "%%ytab=%%c"))^&^
   (for /F %%c in ('echo %%%%yver%%') do if 100 LEQ %%c (^
    for /F "tokens=1,2,3,4" %%d in ('"powershell -nop -ep Bypass -c $rui=$host.UI.RawUI;(''+($rui.WindowSize.Height)+' '+($rui.CursorPosition.Y-$rui.WindowPosition.Y+1)+' '+($rui.WindowPosition.Y+1)+' '+($rui.CursorPosition.Y+1)+'')"') do for /F "tokens=1,2,3,4,5" %%h in ('"echo A C J [ %%%%ydy%%"') do (^
     (if %%g LSS %%l (set "%%ydy=%%g"))^&^
     (for /F %%m in ('echo %%%%ydy%%') do (^
      (for /F "skip=1" %%n in ('"echo prompt $E %%b cmd /d /q /k"') do (set "%%yes=%%n"))^&^
      set "%%ypar=cmd /d /q /r powershell -nop -ep Bypass -c $vpo=%%%%yaux%%;$host.UI.RawUI.WindowPosition = New-Object System.Management.Automation.Host.Coordinates(0,$vpo)"^&^
      (if %%d LEQ %%m (^
       set /a "%%yhy=%%m+1"^>NUL^&^
       (^<nul call set /p "=%%%%yes%%%%k8;%%%%yhy%%;%%%%ywx%%t")^>con^&set "%%yout=1"^&(if %%m EQU %%g (set "%%yhy=%%m"))^
      ) else (^
       set "%%yhy=%%d"^&(if %%e LSS 0 (set "%%yout=1") else if %%d LEQ %%e (set "%%yout=1"))^
      ))^&^
      (if defined %%yout (call set /a "%%yaux=%%g-%%%%yhy%%"^&call %%%%ypar%%)^>NUL 2^>^&1)^&^
      (^
       (^<nul call set /p "=%%%%yes%%%%k%%%%ydy%%%%h%%%%yes%%%%k%%%%ywx%%%%i%%%%yes%%%%k%%j")^&(echo. )^&^
       (if %%m EQU %%g (^<nul call set /p "=%%%%yes%%%%k%%h"))^
      )^>con^&^
      (if %%d LSS %%m (^<nul call set /p "=%%%%yes%%%%k8;%%d;%%%%ywx%%t")^>con)^&^
      (if defined %%yout (^
       set /a "%%yhy=%%g-%%m"^&^
       (for /F %%n in ('echo %%%%yhy%%') do if %%d LSS %%n (call set "%%yaux=$host.UI.RawUI.CursorPosition.Y-%%d+1") else (set "%%yaux=0"))^&^
       (call %%%%ypar%%)^&^
       (^<nul call set /p "=%%%%yes%%%%k^^^!p")^>con^
      )^>NUL 2^>^&1)^
     ))^
    )^
   ) else (^
    call set "%%ya=%%%%ytab%%"^&call set "%%yb=%%%%ytab%%"^&call set "%%yp=%%%%ytab%%"^&^
    (for /F "skip=1" %%d in ('"echo prompt $H %%b cmd /d /q /k"') do (^
     call set /a "%%yup=11+%%%%ywx%%*(%%%%ydy%%-1)/8"^>NUL 2^>^&1^&^
     (for /F %%e in ('echo.%%%%yup%%') do for /L %%e in (1,1,%%e) do (call set "%%ya=%%%%ya%%%%d"))^&^
     call set /a "%%yup=11+%%%%ywx%%*%%%%ydy%%/8"^>NUL 2^>^&1^&^
     (for /F %%e in ('echo.%%%%yup%%') do for /L %%e in (1,1,%%e) do (call set "%%yb=%%%%yb%%%%d"))^&^
     call set /a "%%ypr=11+%%%%ywx%%/8"^>NUL 2^>^&1^&^
     (for /F %%e in ('echo.%%%%ypr%%') do for /L %%e in (1,1,%%e) do (call set "%%yp=%%%%yp%%%%d"))^
    ))^&^
    (if defined %%ya (^
     (call echo %%%%ya%%)^&^
     (for /F %%d in ('echo.%%%%ydy%%') do for /L %%e in (1,1,%%d) do (call echo.%%%%yec%% ^&call echo.%%%%yp%%))^&^
     (call echo %%%%yb%%)^
    ))^>con^
   ))^
  ) else (^
   (for /F %%a in ('echo.@drop_conrows') do (^
    (set %%yaux="^^^|")^&(for /F "tokens=*" %%b in ('start /b /i /realtime cmd /d /q /r "%%%%a%% %%%%ypar%%"') do (echo %%b^&exit /b 0))^
   ))^&^
   set "%%yaux="^&set "%%ypar="^
  ))^
 ) else (echo Error [@drop_conrows]: Absent parameters.^&exit /b 1)) else set wds_dcr_par=

::         @mac_wrapper - starts macro inside new cmd instance & reads result. Uses commas symbol (,) as parameters delimiter.
::                        %~1 == name of macro to run;
::                        %~2 == parameters of executed macro (with its internal specific delimiter);
::                        %~3 == parameters of executed macro to assign for caller (space symbol as delimiter);
::             Notes. #1: any macro with internal use of @mac_wrapper can not be called by @mac_wrapper;
::                    #2: this macro supports calls from sections with disabled delayed expansions;
::                    #3: if delayed expansions disabled, use escape control `^` before `=` in the parameters of wrapped macro;
::                    #4: if the called macro has not parameters, for proper work use space symbol (` `) as 2nd parameter;
::                    #5: if the called macro has not parameters and there are not values to report, omit 2nd & 3rd parameters;
::                    #6: the call of named label inside wrapped macro is not allowed, it fails with error.
::
set @mac_wrapper=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mwp_par (^
  (for /F "tokens=1,2,3 delims=," %%a in ('echo %%wds_mwp_par%%') do (^
   (for /F "tokens=1" %%d in ('echo %%~a') do if defined %%~d (^
    set "wds_mwp_rep="^&(set wds_mwp_quo="")^&(call set wds_mwp_quo=%%wds_mwp_quo:~1%%)^&^
    (if "^!wds_mwp_rep^!"=="" (^
     (if "%%~c"=="" (set wds_mwp_rep=" echo.^>nul") else (^
      (set wds_mwp_rep="")^&^
      (for %%e in (%%~c) do (call set wds_mwp_rep="%%wds_mwp_rep:~1,-1%%&(if defined %%e (echo ^%%wds_mwp_quo^%%%%e=^^^!%%e^^^!^%%wds_mwp_quo^%%) else (echo ^%%wds_mwp_quo^%%%%e=^%%wds_mwp_quo^%%))"))^
     ))^&^
     (for /F "tokens=*" %%e in ('cmd /d /q /e:on /v:on /r "((^!%%~d^! %%b)&%%wds_mwp_rep:~2,-1%%)"') do (^
      (set %%e^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (^
       for /F "tokens=1,2 delims==" %%f in ('"echo.%%~e"') do if not "%%f=%%g"=="%%~e" (echo %%e)^
      )^
     ))^
    ) else (^
     (set wds_mwp_sel="(for /F %%wds_mwp_quo%%usebackq tokens=*%%wds_mwp_quo%% %%p in (`cmd /d /q /e:on /v:on /r %%wds_mwp_quo%%%%wds_mwp_rep:~1,-1%%%%wds_mwp_quo%%`) do (echo %%p))")^&^
     (set wds_mwp_rep="")^&(set wds_mwp_amp="&")^&^
     (for %%e in (%%~c) do (call set wds_mwp_rep="%%wds_mwp_rep:~1,-1%%%%wds_mwp_amp:~1,-1%%(if defined %%e (echo %%%%wds_mwp_quo%%%%%%e%%%%wds_mwp_equ%%%%^!%%e^!%%%%wds_mwp_quo%%%%) else (echo %%%%wds_mwp_quo%%%%%%e%%%%wds_mwp_equ%%%%%%%%wds_mwp_quo%%%%))"))^&^
     (call set wds_mwp_rep="((!%%~d! %%b)%%wds_mwp_rep:~1,-1%%)")^&set "wds_mwp_equ=="^&^
     (for /F "tokens=*" %%e in ('cmd /d /q /e:on /v:on /r %%wds_mwp_sel%%') do (^
      (set %%e^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (^
       for /F "tokens=1,2 delims==" %%f in ('"echo.%%~e"') do if not "%%f=%%g"=="%%~e" (echo %%e)^
      )^
     ))^&^
     set "wds_mwp_sel="^&set "wds_mwp_amp="^&set "wds_mwp_equ="^
    ))^&^
    set "wds_mwp_quo="^&set "wds_mwp_rep="^
   ))^
  ))^&^
  set "wds_mwp_par="^
 ) else (echo Error [@mac_wrapper]: Absent parameters.^&exit /b 1)) else set wds_mwp_par=
 
::         @mac_wraperc - starts macro inside new cmd instance & reads result. Uses commas symbol (,) as its parameters delimiter.
::                        %~1 == name of macro to run;
::                        %~2 == parameters of executed macro (with its specific internal delimiter);
::                        %~3 == parameters of executed macro to assign for caller (space symbol as delimiter).
::                Remark: the use of this macro corresponds to the use of @mac_wrapper macro.
::               Warning: all variables to be reported must be undefined, if it's impossible - use @mac_wrapper.
::
set @mac_wraperc=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mwi_par (^
  (for /F "tokens=1,2,3 delims=," %%a in ('echo %%wds_mwi_par%%') do (^
   set "wds_mwi_par="^&^
   (for /F "tokens=1,*" %%d in ('echo %%~a %%~c') do if defined %%~d (^
    set "wds_mwi_rep=(%%%%d%% %%b)"^&^
    (for %%f in (%%e) do if defined %%f (^
     echo Error [@mac_wraperc]: Unset variable %%f or use @mac_wrapper macro.^&exit /b 1^
    ) else (^
     call set "wds_mwi_rep=%%wds_mwi_rep%%&(if defined %%f (call echo "%%f=%%%%%%f%%%%"))"^
    ))^&^
    (for /F "tokens=*" %%f in ('call cmd /d /q /e:on /v:on /r "%%wds_mwi_rep%%"') do (^
     (set %%f^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%f)^
    ))^&^
    set "wds_mwi_rep="^
   ))^
  ))^
 ) else (echo Error [@mac_wraperc]: Absent parameters.^&exit /b 1)) else set wds_mwi_par=

:: @mac_check & @istrue - starts custom macro, gets its result & sets errorlevel for caller. Uses comma symbol (,) as delimiter.
::                        %~1 == name of custom macro to run some check;
::                        %~2 == parameters of executed macro (space symbol as delimiter, 1st parameter reserved, skip it here);
::                        %~3 == parameters of executed macro to assign for caller (space symbol as delimiter);
::             Notes. #1: its use generally coincide with `@mac_wrapper` - see comments to this macro - the only specific
::                        limitation is the delimiter between parameters of the custom macro - it can be only space symbol;
::                    #2: the 1st parameter of custom macro must return result of its internal check - skip it inside `%~2`;
::                    #3: the `@mac_check` can be used only together with `@istrue`, sample:
::                        %@mac_check% @mymacro,arg2in arg3in,arg1out %@istrue% && echo "true <==> 0" || echo "false <==> 1"
::          Dependencies: @errorLevel.
::
set @mac_check=^
 (for %%x in (1 2) do if %%x EQU 2 (if defined wds_mct_par (^
  (for /F "tokens=1,2,3 delims=," %%a in ('echo.%%wds_mct_par%%') do (^
   (for /F %%d in ('echo %%~a') do if defined %%~d (^
    (set wds_mct_rep="")^&set "wds_mct_res="^&(call set wds_mct_quo=%%wds_mct_rep:~1%%)^&^
    (if "^!wds_mct_res^!"=="" (^
     (for %%e in (wds_mct_res %%~c) do (call set wds_mct_rep="%%wds_mct_rep:~1,-1%%&(if defined %%e (echo ^%%wds_mct_quo^%%%%e=^^^!%%e^^^!^%%wds_mct_quo^%%) else (echo ^%%wds_mct_quo^%%%%e=^%%wds_mct_quo^%%))"))^&^
     (for /F "tokens=*" %%e in ('cmd /d /q /e:on /v:on /r "((^!%%~d^! wds_mct_res %%b)&%%wds_mct_rep:~2,-1%%)"') do (^
      (set %%e^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (^
       (set wds_mct_rep="")^&^
       (for /F "tokens=1,2,3 delims==" %%f in ('"echo %%wds_mct_rep:~1%%=%%e"') do if not %%f==%%h (^
        echo Error [@mac_check], assign fail: %%e^
       ))^
      )^
     ))^
    ) else (^
     (set wds_mct_sel="(for /F %%wds_mct_quo%%usebackq tokens=*%%wds_mct_quo%% %%p in (`cmd /d /q /e:on /v:on /r %%wds_mct_quo%%%%wds_mct_rep:~1,-1%%%%wds_mct_quo%%`) do (echo %%p))")^&^
     (set wds_mct_amp="&")^&^
     (for %%e in (wds_mct_res %%~c) do (call set wds_mct_rep="%%wds_mct_rep:~1,-1%%%%wds_mct_amp:~1,-1%%(if defined %%e (echo %%%%wds_mct_quo%%%%%%e%%%%wds_mct_equ%%%%^!%%e^!%%%%wds_mct_quo%%%%) else (echo %%%%wds_mct_quo%%%%%%e%%%%wds_mct_equ%%%%%%%%wds_mct_quo%%%%))"))^&^
     (call set wds_mct_rep="((!%%~d! wds_mct_res %%b)%%wds_mct_rep:~1,-1%%)")^&set "wds_mct_equ=="^&^
     (for /F "tokens=*" %%e in ('cmd /d /q /e:on /v:on /r %%wds_mct_sel%%') do (^
      (set %%e^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (^
       (set wds_mct_rep="")^&^
       (for /F "tokens=1,2,3 delims==" %%f in ('"echo %%wds_mct_rep:~1%%=%%e"') do if not %%f==%%h (^
        echo Error [@mac_check], assign fail: %%e^
       ))^
      )^
     ))^&^
     set "wds_mct_sel="^&set "wds_mct_amp="^&set "wds_mct_equ="^
    ))^&^
    (for /F %%e in ('echo %%wds_mct_res%%') do (^
     (if %%~e NEQ 0 if %%~e NEQ 1 (set "wds_mct_res="))^&(if defined wds_mct_res (set "wds_mct_res=%%~e"))^
    ))^&^
    (if not defined wds_mct_res (echo Error [@mac_check]: Absent or unexpected result in the 1st parameter of custom macro "%%~d".^&exit /b 1))^&^
    set "wds_mct_quo="^&set "wds_mct_rep="^
   ))^
  ))^&^
  set "wds_mct_par="^
 ) else (echo Error [@mac_check]: Absent parameters.^&exit /b 1)) else (set wds_mct_par=
set @istrue=))^&for /F %%x in ('echo %%wds_mct_res%%') do set "wds_mct_res="^&%@errorLevel% %%x

::             @spinner - runs endless loop until its execution time will reach specified interval in msec.
::                        %~1 == waiting interval in msec.
::             Notes. #1: it does not check value of `%~1`, it must be a valid positive decimal number without quotes;
::                    #2: it is based on format of %time% HH:MM:SS.NN with arbitrary delimiters, but fixed length from the left;
::                    #3: the precision of spinner is within 30 msec (depends on current performance of host system);
::                    #4: see also `@sleep_wsh` macro for sleep using `WScript.Sleep` method of Windows Scripting Host.
::
set @spinner=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_spi_par (^
  call set "wds_spi_beg=%%time: =0%%"^&^
  (set wds_spi_run="(for /L %%^n in (1,1,2147483647) do (set wds_spi_end=$exc$time: =0$exc$$amp$(if not $quo$$exc$wds_spi_beg$exc$$quo$==$quo$$exc$wds_spi_end$exc$$quo$ (set wds_spi_bms=1$exc$wds_spi_beg:~9,2$exc$0$amp$set wds_spi_ems=1$exc$wds_spi_end:~9,2$exc$0$amp$set wds_spi_beg=$exc$wds_spi_end$exc$$amp$(if $exc$wds_spi_ems$exc$ LSS $exc$wds_spi_bms$exc$ (set /a $quo$wds_spi_ems+=1000$quo$$rab$NUL))$amp$set /a $quo$wds_spi_dif=$exc$wds_spi_ems$exc$-$exc$wds_spi_bms$exc$$quo$$rab$NUL$amp$set /a $quo$wds_spi_par-=$exc$wds_spi_dif$exc$$quo$$rab$NUL$amp$(if $exc$wds_spi_par$exc$ LSS $exc$wds_spi_dif$exc$ (exit /b 0))))))")^&^
  (set wds_spi_quo="")^&(set "wds_spi_amp=1^^^&1")^&(set wds_spi_exc="^^^^^!^^^!^^^!")^&(set wds_spi_rab="^^^>")^&^
  (for /F "tokens=1,2,3,4,5" %%a in ('"echo %%wds_spi_quo:~1%% %%wds_spi_amp:~-2,1%% %%wds_spi_exc:~1,-1%% %%wds_spi_exc:~-2,-1%% %%wds_spi_rab:~-2,1%%"') do (^
   set "wds_spi_quo="^&set "wds_spi_amp="^&set "wds_spi_exc="^&set "wds_spi_rab="^&^
   (call set wds_spi_run=%%wds_spi_run:$quo$=%%a%%)^&(call set wds_spi_run=%%wds_spi_run:$amp$=%%b%%)^&^
   (if "^!wds_spi_quo^!"=="" (call set wds_spi_run=%%wds_spi_run:$exc$=%%c%%) else (call set wds_spi_run=%%wds_spi_run:$exc$=%%d%%))^&^
   (call set wds_spi_run=%%wds_spi_run:$rab$=%%e%%)^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r %%wds_spi_run%%') do (echo %%a))^&^
  set "wds_spi_beg="^&set "wds_spi_run="^&set "wds_spi_par="^
 ) else (echo Error [@spinner]: Absent parameter.^&exit /b 1)) else set wds_spi_par=

::         @mac_spinner - runs endless loop until custom macro will exit.
::                        %~1 == name of custom macro to check exit condition.
::             Notes. #1: the macro can work with desabled delayed expansions, "!" notation can be used in custom macro always;
::                    #2: the custom macro runs in isolated context, can't use modified values in the body & return any values;
::                    #3: the custom macro can use any of its values during all its life cycle in the loop;
::                    #4: internal loop supports echo of custom messages;
::                    #5: to avoid side echo from arithmetic operations in macro use ^>NUL after each of them, s.a. @mac_loop.
::
set @mac_spinner=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_msp_mac (^
  for /F "tokens=1,2,4" %%a in ('echo." %%wds_msp_mac%% ." "%%"') do if defined %%b (^
   set "wds_msp_mac=%%b"^&^
   (for /F "tokens=*" %%d in ('cmd /d /q /e:on /v:on /r "for /L %%~ce in (1 1 2147483647) do (%%%%wds_msp_mac%%%%)"') do (echo %%d))^&^
   set "wds_msp_mac="^
  )^
 ) else (echo Error [@mac_spinner]: Absent custom macro parameter.^&exit /b 1)) else set wds_msp_mac=
 
::  @mac_loop & @mac_do - runs endless loop until custom macro will exit.
::                        %~1    == name of custom macro to check exit condition;
::                        %~2... == the list of variable names to report into the calling context on every step.
::             Notes. #1: the @mac_loop macro can only be used with the @mac_do macro, which defines the loop body, sample:
::                            `%@mac_loop% @mycustommacro varname1 varname2 %@mac_do% (echo "My loop body activities")`
::                        - the braces of the loop body are optional, can be omitted for in-one-string definition;
::                        - the empty body of the loop requires some dummy call after `@mac_do`, for instance: `empty.>nul`;
::                    #2: the macro can work with disabled delayed expansions, "!" notation can be used in custom macro always;
::                    #3: the custom macro runs in isolated context, can't use modified values in the body;
::                    #4: the custom macro can use any of its values during all its life cycle in the loop;
::                    #5: to avoid side effects of arithmetic any screen output is locked for custom macro;
::                    #6: The custom macro of the loop works within external context & has altered behavior:
::                        - the custom macro runs inside context of calling script, its `exit /b 0` defines end of the loop;
::                        - the exit of macro skips any initialisation of variables for external context, to work around it
::                          preliminary set all final values for output inside macro and only in the next step call exit;
::                        - the use of `%%` notation doesn't allow to read external values, work around with `%%%%` notation;
::                        - the quotation of variables to read values does not work with disabled delayed expansions of the 
::                          caller, in the case of enabled expansions the escape symbols behave themselves as if the quotes were
::                          not there (`^` <==> `^^^`);
::                        - the echo with redirection to file or to console allows tracing of custom macros.
::
set @mac_loop=^
 (for %%x in (1 2) do if %%x EQU 2 (if defined wds_mld_mac for /F %%p in ('echo wds_mld_') do for /F "tokens=1,*" %%a in ('echo %%%%pmac%%') do if defined %%~a (^
  (for %%d in (amp,car,exc,quo,rab) do (set "%%p%%d="))^&^
  (set "%%pmac=(%%%%pexc%%%%~a%%%%pexc%%)")^&^
  (call set "%%pmac=(%%%%pmac%%%%%%%%pcar%%%%%%%%%%prab%%%%NUL)")^&^
  (for %%c in (%%~b) do (call set "%%pmac=%%%%pmac%%%%%%%%pcar%%%%%%%%%%pamp%%%%(if defined %%c (echo %%p %%%%%%pquo%%%%%%c=%%%%%%pcar%%%%%%%%%%pcar%%%%%%%%%%pexc%%%%%%c%%%%%%pcar%%%%%%%%%%pcar%%%%%%%%%%pexc%%%%%%%%%%pquo%%%%) else (echo %%p %%%%%%pquo%%%%%%c=%%%%%%pquo%%%%))"))^&^
  (set %%pquo="")^&(set %%pamp="^^^&")^&(set %%pexc="^^^^^!^^^!^^^!")^&(set %%pcar="^^^^")^&(call set %%prab="%%%%%%pcar%%%%^>")^&^
  (for %%a in (amp,car,exc,quo,rab) do (call set "%%p%%a=%%%%p%%a:~-2,1%%"))^
 ) else (echo Error [@mac_loop]: Custom macro undefined.^&exit /b 1) else (echo Error [@mac_loop]: Absent parameters.^&exit /b 1)) else (set wds_mld_mac=
set @mac_do=))^&^
 for /F "tokens=*" %%x in ('cmd /d /q /e:on /v:on /r "echo.wds_mld_%%wds_mld_amp%%cmd /d /q /e:on /v:on /r %%wds_mld_quo%%(for /L %%^^x in (1 1 2147483647) do (%%wds_mld_mac%%%%wds_mld_car%%%%wds_mld_amp%%echo..))%%wds_mld_quo%%"') do ^
  if "%%x"=="wds_mld_" (^
   (for %%d in (amp,car,exc,mac,quo,rab) do (set "%%x%%d="))^
  ) else for /F "tokens=1,*" %%y in ('echo %%x') do if "%%y"=="wds_mld_" (^
   set %%z^>NUL 2^>^&1^
  ) else
 
::               @unset - drops definitions of variables by clearing their values.
::                        Macro has only optional parameters, but one of them must be present to select defined variables.
::                      Optional string parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~1 == prefix substring of variables name;
::                      2:%~2 == substring in an arbitrary position inside the variable name string;
::                      3:%~3 == suffix substring of variables name.
::                  Note: Any specified substring must be an explicit string value (quoted or unquoted).
::
set @unset=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_uns_aux (^
  (for /F %%p in ('echo wds_uns') do (^
   (set %%p_quo="")^&set "%%p_pfx="^&set "%%p_sub="^&set "%%p_sfx="^&^
   (if ^^^!%%p_quo^^^!=="" (^
    (for %%a in (^^^!%%p_aux^^^!) do (^
     set "%%p_aux=%%~a"^&set "%%p_sfl=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
     (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_pfx=^!%%p_sfl^!"))^&^
     (if ^^^!%%p_aux^^^! EQU 2 (set "%%p_sub=^!%%p_sfl^!"))^&^
     (if ^^^!%%p_aux^^^! EQU 3 (set "%%p_sfx=^!%%p_sfl^!"))^
    ))^
   ) else (^
    (for /F "tokens=1,2,3" %%a in ('echo.%%%%p_aux%%') do for %%d in ("%%~a","%%~b","%%~c") do (^
     (for /F "tokens=1,2 delims=:" %%e in ('echo %%~d') do if not "%%~f"=="" (^
      (if %%~e EQU 1 (set "%%p_pfx=%%~f"))^&(if %%~e EQU 2 (set "%%p_sub=%%~f"))^&(if %%~e EQU 3 (set "%%p_sfx=%%~f"))^
     ))^
    ))^
   ))^&^
   (if not defined %%p_pfx if not defined %%p_sub if not defined %%p_sfx (echo Error [@unset]: The parameters 1:#1, 2:#2 and 3:#3 are absent.^&exit /b 1))^&^
   (if defined %%p_sfx (^
    set "%%p_sfl=1"^&call set "%%p_aux=%%%%p_sfx%%"^&^
    (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     call set "%%p_chk=%%%%p_aux:~%%b,1%%"^&(if defined %%p_chk (call set "%%p_aux=%%%%p_aux:~%%b%%"^&set /a "%%p_sfl+=%%b"^>NUL))^
    ))^&^
    set "%%p_chk="^
   ) else (set "%%p_sfl=0"))^&^
   set "%%p_set=set"^&(if defined %%p_pfx (call set %%p_set="%%%%p_pfx%%"))^&(set %%p_bar="^^^|")^&^
   (if ^^^!%%p_quo^^^!=="" (^
    (if defined %%p_pfx (call set "%%p_set=set %%%%p_bar:~-2,1%% findstr /BC:%%%%p_set%%"))^&^
    (for /F "tokens=1 delims==" %%a in ('%%%%p_set%%') do (^
     set "wds_us_nam=%%a"^&^
     (if "^!%%p_sub^!"=="" (set "wds_us_sbs=") else (call set "wds_us_sbs=%%wds_us_nam:^!%%p_sub^!=%%"))^&^
     (if NOT "^!wds_us_nam^!"=="^!wds_us_sbs^!" (^
      (if ^^^!%%p_sfl^^^! EQU 0 (set "wds_us_sfx=") else (call set "wds_us_sfx=%%wds_us_nam:~-^!%%p_sfl^!,^!%%p_sfl^!%%"))^&^
      (if "^!%%p_sfx^!"=="^!wds_us_sfx^!" (^
       (if "^!wds_us_nam:%%p_=^!"=="^!wds_us_nam^!" (set "%%a="))^
      ))^
     ))^
    ))^>NUL 2^>^&1^&^
    set "wds_us_nam="^&set "wds_us_pfx="^&set "wds_us_sbs="^&set "wds_us_sfx="^
   ) else (^
    (if defined %%p_pfx (call set "%%p_set=set %%%%%%p_bar%%%% findstr /BC:%%%%p_set%%"))^&^
    (call set %%p_quo=%%%%p_quo:~1%%)^&(call set %%p_bar=%%%%p_bar:~-3,2%%)^&^
    (set %%p_sel="(for /F %%%%p_quo%%tokens=1 delims==%%%%p_quo%% %%^p in ('"%%%%p_set%%"') do (set %%%%p_quo%%wds_us_nam=%%^p%%%%p_quo%%&(if defined %%p_sub (set %%%%p_quo%%wds_us_sbs=!wds_us_nam:%%%%p_sub%%=!%%%%p_quo%%) else (set %%%%p_quo%%wds_us_sbs=[!wds_us_nam!]%%%%p_quo%%))&(if NOT %%%%p_quo%%!wds_us_sbs!%%%%p_quo%%==%%%%p_quo%%!wds_us_nam!%%%%p_quo%% (if defined %%p_sfx (call set %%%%p_quo%%wds_us_sfx=!wds_us_nam:~-%%%%p_sfl%%,%%%%p_sfl%%!%%%%p_quo%%) else (set %%%%p_quo%%wds_us_sfx=%%%%p_sfx%%%%%%p_quo%%))&(if %%%%p_quo%%%%%%p_sfx%%%%%%p_quo%%==%%%%p_quo%%!wds_us_sfx!%%%%p_quo%% if %%%%p_quo%%!wds_us_nam:%%p_=!%%%%p_quo%%==%%%%p_quo%%!wds_us_nam!%%%%p_quo%% (echo %%^p)))))")^&^
    (set %%p_tsk="(for /F %%%%p_quo%%usebackq tokens=*%%%%p_quo%% %%^p in (`cmd /d /q /e:on /v:on /r %%%%p_quo%%%%%%p_sel:~1,-1%%%%%%p_quo%%`) do (echo %%^p))")^&^
    (for /F "usebackq tokens=*" %%a in (`cmd /d /q /e:on /v:on /r %%%%p_tsk%%`) do (set "%%a="))^>NUL 2^>^&1^&^
    set "%%p_sel="^&set "%%p_tsk="^
   ))^&^
   (for %%a in (aux,bar,quo,pfx,pfl,sub,sfx,sfl,set) do (set "%%p_%%a="))^
  ))^
 ) else (echo Error [@unset]: Absent parameters.^&exit /b 1)) else set wds_uns_aux=

::           @unset_mac - removes all macro definitions except specified in parameters, uses `,` as params delimiter.
::                        %~1 == key argument to trigger the call of cleanup inside macro or to skip it:
::                           `[]`                     - starts always & rewrites `@unset_mac` and `@unset_avail` by plugs;
::                           `[...^^^...]`            - optional number of `^` for exact definition of calling context;
::                           `[^^^^^^^^^^^^^^^^^^^^]` - `for-in-do` macro block, defined & called with enabled expansions;
::                          - it starts in the nested contexts if its call corresponds to value `[]` of this parameter,
::                            that is, because the `^` symbols shrink inside nested contexts, they can be used as trigger;
::                        %~2 == list of macro names to keep definitions (names without prefix `@`);
::             Notes. #1: the macro only echoes macro names for their reset in the calling context (`for-in-do` blocks);
::                    #2: it uses the hardcoded list of this library macros;
::                    #3: macro always skip unset of own definition & @unset_alev, rewrites it by plug with '%~1' == `[]`;
::                    #4: for proper work avoid any leading & internal space symbols, samples:
::                        1. for /F "tokens=* %%a in ('cmd /d /q /r "!@unset_mac![^^^^^^^^^^^^^^^^^^^^],foo"') do set %%a
::                        2. for /F %%a in ('cmd /d /q /r "!@unset_mac![],anylibrarymacro1,anylibrarymacro2"') do set %%a
::
set @unset_mac=^
 for %%x in (1 2) do if defined wds_sco_sms (if %%x EQU 2 for /F "delims=, tokens=1,*" %%y in ('echo.%%wds_sco_sms%%') do if "%%y"=="[]" (^
  (for /F "tokens=1,2" %%a in ('"echo %%wds_sco_sms%% %%wds_sco_sms:[]=%%"') do if "%%a"=="%%b" (^
   echo "@unset_mac=set library.waitmds.unset_mac="^&echo "@unset_alev=set library.waitmds.unset_alev="^
  ))^&^
  set "wds_sco_sms=,activewindow,appbarect,binman,chcp_file,closewindow,code,comparefiles,compareshots,consoletext,coprocess,cptooem,cursorpos,date_span,disk_space,drop_conrows,echo_imprint,echo_params,enumA,enumB,environset,enwalue,error,errorLevel,event_item,events_reader,event_file,exist,exist_check,findcontrol,findshow,findwindow,fixedpath,fixedpath_parser,fixedpath_8d3,foregroundwindow,get_number,get_xnumber,hex,imprintxy,ipaddress,isok,istrue,library.waitmds.com,library.waitmds.vbs,mac_check,mac_do,mac_loop,mac_spinner,mac_wraperc,mac_wrapper,monitor,mouseclick,movetoscreen,movewindow,nicconfig,netdevs,oemtocp,obj_attrib,obj_newname,obj_size,perf_counter,pidofwindow,pid_title,procpriority,radix,rand,regvalue,repaint,res_select,runapp,runapp_getpid,runapp_wsh,screenrect,screenshot,screensize,sendkeys,sendmessage,shellfolder,shortcut,showdesktop,showwindow,shrink,sleep_wsh,shortpath,spinner,str_arrange,str_clean,str_decode,str_encode,str_isempty,str_length,str_plate,str_trim,str_unquote,str_upper,substr_extract,substr_get,substr_regex,substr_remove,syms_cutstr,syms_replace,sym_replace,taskinfo,time_span,title,title_pid,typeperf,typeperf_devs,typeperf_res_a,typeperf_res_b,typeperf_res_c,typeperf_res_d,typeperf_res_use,unset,web_avail,web_ip,windowcaptext,windowclass,windowrect,windowsofpid,windowstate,"^&^
  (for /F %%a in ('echo.%%~z') do for %%b in (%%a,unset_mac,unset_alev) do (call set "wds_sco_sms=%%wds_sco_sms:,%%b,=,%%"))^>NUL 2^>^&1^&^
  (for /F %%a in ('echo.%%wds_sco_sms%%') do for %%b in (%%a) do if defined @%%b (echo "@%%b="))^
 )) else set wds_sco_sms=

::          @unset_alev - removes environment definitions except specified in parameters, has only optional parameters.
::                        First three params with values to be excluded from reset, explicit values in CSV format without quotes:
::                        1:%~1 == names of macros with preceding `@` in definitions (without `@` prefix);
::                        2:%~2 == arbitrary substrings inside names or values;
::                        3:%~3 == the full names of the environment variables to keep;
::                        4:%~4 == one additional prefix substring of variables names to drop;
::                        Key values:
::                        5:%~5 == key value to treat values of `@unset_mac` and `@unset_alev` for nested calls:
::                               `0` - unset;
::                               `1` - overwrite by `set library.waitmds.unset_mac=` and by `set library.waitmds.unset_alev=`;
::                               `2` - exclude from reset (default);
::                        6:%~6 == any symbol to echo the environment names for reset in the calling context.
::             Notes. #1: it always exclude reset of environment variables `TEMP`, `SystemRoot` and `Path`;
::                    #2: it verifies preliminary search by checking names-only and returns exact result for reset;
::                    #3: the call of macro from `for-id-do` block with `5:%~5 == 1` requires "tokens=*" for proper nested plug.
::
set @unset_alev=for %%x in (1 2) do if defined wds_unset_alev_p (^
 if defined wds_ale_r for /F "tokens=1,*" %%p in ('"echo.wds_ale_ %%wds_unset_alev_p:,=+%%"') do (^
  set "%%pc=cmd /d /q /r "^&set "%%p11= "^&set "%%p12= "^&^
  (for /F "tokens=1,2,3,* delims= " %%r in ('echo /C:"[ [" " $b$ find /V /I "') do (^
   (set %%p21=set %%u@%%t %%u%%p%%t)^&^
   (set %%p31= %%uPath=%%t %%uTEMP=%%t %%uSystemRoot=%%t)^&^
   (set %%p32= %%rPath%%s %%rTEMP%%s %%rSystemRoot%%s)^&^
   (set %%pe1= %%u@unset_mac=%%t %%u@unset_alev=%%t)^&^
   (set %%pe2= %%r@unset_mac%%s %%r@unset_alev%%s)^&^
   (for %%a in (%%q) do for /F "tokens=1,2 delims=:" %%b in ('echo %%a') do (^
    (echo ",1,2,3," ^| findstr /C:",%%b,")^>NUL ^&^& (^
     set "%%pr=%%c"^&^
     (if %%b EQU 1 (^
      set "%%pm=1"^&^
      (call set %%p%%b1=%%%%p%%b1%% %%u@%%%%pr:+=%%t %%u@%%%%t)^&^
      (if %%b NEQ 2 (call set %%p%%b2=%%%%p%%b2%% %%r@%%%%pr:+=%%s %%r@%%%%s))^
     ) else (^
      (call set %%p%%b1=%%%%p%%b1%% %%u%%%%pr:+=%%t %%u%%%%t)^&^
      (if %%b NEQ 2 (call set %%p%%b2=%%%%p%%b2%% %%r%%%%pr:+=%%s %%r%%%%s))^
     ))^
    ) ^|^| (echo ",5,6," ";0;1;2;" ^| findstr /C:",%%b," /C:";%%c;")^>NUL ^&^& (^
     if %%b EQU 5 (^
      (if %%c NEQ 2 (set "%%pe1="^&set "%%pe2="))^&(if %%c EQU 1 (set "%%pj=1") else (set "%%pj="))^
     ) else if %%b%%c EQU 61 (echo $ "%%pr=")^
    ) ^|^| (if "%%~b"=="4" if not "%%~c"=="" (set "%%pd=%%~c"))^
   ))^
  ))^&^
  (if defined %%pe1 (set "%%pm=1"^&call set %%p11=%%%%p11%%%%%%pe1%%))^&(call set %%p11="set @%%%%p11:~1%%")^&^
  (set %%pb="^^^|")^&call set "%%pr=%%@unset_alev:~10,5%%"^&^
  (for /F %%a in ('echo "$b$=%%%%pb:~-2,1%%"') do (^
   (for /F "delims==" %%b in ('%%%%pc%%%%%%p11:%%~a%%') do (set "%%b="^&echo $ "%%b="))^&^
   call set "%%p21=%%%%p21:%%~a%%"^&^(call set %%p31="%%%%p21%%%%%%p31:%%~a%%")^&^
   (for /F "delims==" %%b in ('%%%%pc%%%%%%p31%%') do (set "%%b="^&echo $ "%%b="))^&^
   call set "%%pl=%%%%pr:~0,1%%"^&call set "%%pr=%%%%pr:~-1,1%%"^&^
   (set "%%pt=for /F "delims==" %%^h in %%%%pl%%'"%%%%pp%%"'%%%%pr%% do echo [%%^h[")^&^
   (if defined %%pm (^
    (if defined %%pe2 (call set %%p12=%%%%p12%%%%%%pe2%%))^&^
    (if defined %%pm (call set "%%p12= %%%%pb:~-2,1%% findstr /V /I%%%%p12%%"))^&^
    set "%%pp=set @"^&^
    (for /F "delims=[" %%b in ('%%%%pc%%"%%%%pt%%%%%%p12%%"') do (echo $ "%%b="))^
   ))^&^
   call set "%%pp=%%%%p21%%"^&^
   (for /F "delims=[" %%b in ('%%%%pc%%"%%%%pt%% %%%%pb:~-2,1%% findstr /V /I%%%%p32%%"') do (echo $ "%%b="))^&^
   (if defined %%pd for /F "delims==" %%b in ('%%%%pc%%"set %%%%pd%%"') do (echo $ "%%b="))^&^
   (if defined %%pj ((echo $ "@unset_alev=set library.waitmds.unset_alev=")^&(echo $ "@unset_mac=set library.waitmds.unset_mac=")))^
  )) 2^>^&1^&^
  exit /b 0^
 ) else (^
  set "wds_ale_r=@unset_alev"^&^
  (for /F "tokens=1,*" %%a in ('start /b /i /ABOVENORMAL cmd /d /q /r "%%%%wds_ale_r%%%%"') do if "%%~a"=="$" if defined wds_ale_r (set %%b) else (echo %%b))^&^
  (if defined wds_ale_r (set "wds_unset_alev_p="^&set "wds_ale_r="))^
 )) else set wds_unset_alev_p=

::              @runapp - runs new application using `start` command of cmd.exe.
::                        %~1 == the key parameter to set priority, can have next values (upper or lower case, digital synonym):
::                               `5` OR `/REALTIME`     - real time;     `4` OR `/HIGH`    - high;
::                               `3` OR `/ABOVENORMAL`  - above normal;  `2` OR `/NORMAL`  - normal priority;
::                               `1` OR `/BELOWNORMAL`  - below normal;  `0` OR `/LOW`     - idle;
::                        %~2 == the string to run application (the name of variable or quoted command string);
::                      Next parameter is valuable only if `%~2` has variable name, otherwise it's a suffix of `%~2` string:
::                        %~3 == the title of started user console (the name of variable or quoted title string).
::          Warnings. #1: the successful call of this macro gives the newly launched child process. As a result, if it is called
::                        inside the "for-in-do" block (macro `@mac_wrapper` etc), the calling process will hang until the child
::                        process will exit. Therefore its use is limited to usual calls from script;
::                    #2: this macro requires environment variable `COMSPEC` and `USERPROFILE` for proper work.
::             Notes. #1: macro is not designed to return any values, doesn't wait for the process to start;
::                    #2: if the command have controls `!`, `%`, `^`, `&` - macro executes it by auxiliary temporary batch file;
::                    #3: to avoid blocking of calling process it starts application by means of 2 new console windows;
::                    #4: keys of command `start` - prefix of `%~2`, application keys - suffix, e.g: `/min notepad.exe my.txt`.
::
set @runapp=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%y in ('echo wds_rua_') do if defined %%yrap (^
  (if defined %%ycmd (^
   (set %%yq="")^&(set %%yb="^^^|")^&(set %%yc="^^^^")^&(set %%ya="^^^&")^&(set %%ye="^^^!")^&(set %%yp="^%%")^&(set %%yr="^^^>")^&^
   (for %%a in (a,e,c,p,q,r) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
   (for /F %%a in ('cmd /d /q /r "(set runapp_shrink=@unset_mac)%%%%ya%%(call cmd /d /q /r %%%%yq%%%%%%runapp_shrink%%%%[]%%%%yq%%)"') do (set %%a))^&^
   set "@unset_mac="^&^
   (for /F "tokens=1,*" %%a in ('"echo %%%%yrap%%"') do (^
    (set %%yat="")^&set "%%y0="^&^
    (for /F "tokens=2,*" %%c in ('"echo %%%%yrap%%"') do if defined %%~c (^
     (for /F "tokens=*" %%e in ('echo %%%%~c%%') do (set "%%yrap=%%e"^&set "%%y0=%%e"))^&^
     (if "%%~d"==%%d (set %%yat="%%~d") else if defined %%d for /F "tokens=*" %%f in ('echo.%%%%d%%') do (set %%yat="%%~f"))^
    ) else if "%%~b"==%%b (set "%%yrap=%%b"^&set "%%y0=%%b"))^&^
    (if not defined %%y0 (echo Error [@runapp]: Undefined command string or it has unexpected format, use variable for it.^&exit /b 1))^&^
    set "%%yprl=%%~a"^&^
    (for %%c in ("5=/REALTIME" "4=/HIGH" "3=/ABOVENORMAL" "2=/NORMAL" "1=/BELOWNORMAL" "0=/LOW") do (call set "%%yprl=%%%%yprl:%%~c%%"^>NUL 2^>^&1))^&^
    set "%%y1=0"^&^
    (for %%c in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     call set "%%y2=%%%%y0:~%%c,1%%"^&^
     (if defined %%y2 (call set "%%y0=%%%%y0:~%%c%%"^&call set /a "%%y1+=%%c"^>NUL))^
    ))^&^
    (for /F "tokens=1,2,3,4,5,6" %%c in ('call echo %%%%y1%% "%%%%yc%%" %%%%ye%% %%%%yp%% "%%%%ya%%" %%%%yq%%') do (^
     (for /L %%i in (0,1,12) do (set "%%y%%i="))^&(for %%i in ("pfx=","fol=","cmd=""","pat=","exe=""","key=","qnm=0") do (set "%%y%%~i"))^&^
     (for /L %%i in (0,1,%%c) do for /F "tokens=*" %%j in ('echo."%%%%yrap:~%%i,1%%"') do (^
      (if defined %%y0 (set "%%y12=1") else if not "%%~j"==" " (^
       set "%%y0=1"^&set "%%y12="^&^
       (if defined %%y9 (^
        if "%%~j"=="/" (set "%%y2=1") else (^
         (if defined %%y1 if defined %%y11 if not defined %%ypfx (^
          (if "%%~j"=="%%h" (call set "%%y7=%%%%y7:%%h=%%"))^&^
          (if defined %%y7 (set "%%y1="^&(set %%ycmd="/\")^&(set %%yexe="/\")))^
         ))^&^
         set "%%y3=1"^&(if "%%~j"=="%%h" (set "%%y11=1"))^
        )^
       ) else (^
        (if "%%~j"=="%%h" (^
         set "%%y0="^&set "%%yqnm=1"^&set "%%y1=1"^&set "%%y7=%%h"^&set "%%y11=1"^
        ) else if "%%~j"=="/" (set "%%y2=1") else (set "%%y3=1"))^&^
        set "%%y9=1"^
       ))^
      ))^&^
      (if defined %%y0 (^
       (if defined %%y2 if "%%~j"==" " (^
        (for /F %%k in ('echo."%%%%y7%%"') do if %%k=="/" (echo Error [@runapp]: Empty command key.^&exit /b 1))^&^
        set "%%y0="^&set "%%y2="^&(call set "%%ypfx=%%%%ypfx%% ")^
       ))^&^
       (if defined %%y0 (^
        set "%%y5="^&set "%%y7=%%~j"^&set "%%y8=%%~j"^&^
        (if "%%~j%%~j"==%%d (set "%%y5=1"^&set "%%y6=1"^
        ) else if "%%~j"=="%%e" (set "%%y5=1"^&set "%%y6=1"^&set "%%y7=%%e"^&set "%%y8=%%e"^
        ) else if "%%~j"=="%%f" (set "%%y5=1"^&set "%%y6=1"^&set "%%y7=%%f"^&set "%%y8=%%f%%f"^
        ) else if "%%~j"=="%%~g" (set "%%y5=1"^&set "%%y6=1"^
        ) else if "%%~j"=="%%h" (^
         (if not defined %%y4 (set %%y4=""))^&set "%%y5=1"^&set "%%y7=/\"^&set "%%y8=/\"^&set /a "%%yqnm+=1"^>NUL^
        ))^&^
        (if defined %%y2 if defined %%y5 (echo Error [@runapp]: Control characters in keys prefix.^&exit /b 1))^&^
        (if defined %%y2 (^
         set "%%y11="^&(if defined %%ypfx (call set "%%ypfx=%%%%ypfx%%%%%%y7%%") else (call set "%%ypfx=%%%%y7%%"))^
        ) else (^
         (if defined %%y12 (^
          (if not defined %%ykey (if "%%~j"=="/" (set "%%ykey=1") else if defined %%y11 (^
           if defined %%y4 (set "%%ykey=1")^
          ) else if "%%~j"==" " (set "%%ykey=1")))^
         ) else (set "%%y4="^&set "%%y12=1"))^&^
         (if defined %%y4 (if "%%~j"==" " (set "%%y12="^&(call set %%y4=" %%%%y4:~1,-1%%")) else (^
          call set "%%y7=%%%%y4:~1,-1%%%%%%y7%%"^&call set "%%y8=%%%%y4:~1,-1%%%%%%y8%%"^&^
          (if "%%~j"=="%%h" (set %%y4="") else (set "%%y4="))^
         )))^&^
         (if defined %%y12 (^
          (if defined %%ykey (set "%%y12=") else if not "%%~j"=="\" (set "%%y12="))^&^
          (if defined %%y12 (^
           (if defined %%yfol (call set %%yfol="%%%%yfol:~1,-1%%\%%%%ycmd:~1,-1%%") else (call set %%yfol="%%%%ycmd:~1,-1%%"))^&^
           (if defined %%ypat (call set %%ypat="%%%%ypat:~1,-1%%\%%%%yexe:~1,-1%%") else (call set %%ypat="%%%%yexe:~1,-1%%"))^&^
           (set %%ycmd="")^&(set %%yexe="")^
          ) else (^
           (call set %%ycmd="%%%%ycmd:~1,-1%%%%%%y7%%")^&(call set %%yexe="%%%%yexe:~1,-1%%%%%%y8%%")^
          ))^
         ))^
        ))^
       ))^
      ))^
     ))^&^
     (if defined %%y9 (call set /a "%%yqnm=%%%%yqnm%%-%%%%yqnm%%/2*2"^>NUL^&call set "%%y9=%%%%yqnm:1=%%"))^&^
     (if not defined %%y9 (echo Error [@runapp]: Odd number of quotes or empty command string.^&exit /b 1))^&^
     (for %%i in (cmd,exe) do if defined %%y%%i (^
      (if defined %%y1 if defined %%y4 (call set %%y%%i="%%%%y%%i:~1,-3%%"))^&^
      (if defined %%ypat if defined %%y11 (call set %%y%%i="/\%%%%y%%i:~1,-1%%"))^&^
      call set "%%y%%i=%%%%y%%i:/\=%%h%%"^&^
      (for /F "tokens=*" %%j in ('"echo.%%%%y%%i:~1,-1%%"') do (set "%%y%%i=%%j"))^
     ))^&^
     (for %%i in (pat,fol) do if defined %%y%%i if defined %%y11 (call set %%y%%i="%%%%y%%i:~3,-1%%"))^&^
     (if defined %%ypfx (call set %%ypfx="%%%%ypfx%%%%%%yprl%% ") else (set %%ypfx="%%%%yprl%% "))^&^
     (if not defined %%yfol (set %%yfol="."))^&^
     set "%%y0="^&set "%%y1="^&^
     (if defined %%y6 (for /F "tokens=1,2,*" %%i in ('echo."(" ")" %%%%yfol%%') do for /L %%l in (1,1,25) do if defined %%y6 (^
      set "%%y2=0000%%l"^&call set "%%y2=wait.mds.auxiliary.file.id%%%%y2:~-4%%"^&^
      (for /F "tokens=1,*" %%m in ('echo %%%%y2%% "%%TEMP%%"') do if not exist "%%~n\%%m*" if not exist "%%~k\%%m*" (^
       (if defined %%ypat ((echo @echo off)^&^
        (for /F "tokens=*" %%o in ('"echo set %%ydir=%%%%ypat%%"') do (echo %%o))^&^
        (for /F "tokens=1,2,*" %%o in ('echo %%~iset %%ycom "%%%%ypat:~1,-1%%\%%m.bat"%%~j') do (echo %%o %%p=%%q))^&^
        (echo cd /d %%f%%ydir%%f)^&^
        (echo call %%f%%f%%ycom%%f%%f)^&^
        (echo %%~idel /f /a /q "%%f~f0"%%~j %%~g%%~g %%~iexit /b 0%%~j)^&^
        (set %%y0="%%~n\%%m.bat")^
       )^>^>"%%~n\%%m.bat")^&^
       ((echo @echo off)^&^
        (for /F "tokens=1,2,*" %%o in ('"echo %%~iset %%yrun %%%%yexe%%%%~j"') do (echo %%o %%p=%%q))^&^
        (call echo call cmd /d /q /r start %%%%ypfx:~1,-1%%%%%%yat%% %%f%%f%%yrun%%f%%f)^&^
        (echo %%~idel /f /a /q "%%f~f0"%%~j %%~g%%~g %%~iexit /b 0%%~j)^&^
        (set %%y1="%%~k\%%m.bat")^
       )^>^>"%%~k\%%m.bat"^&^
       (if defined %%ypat (set %%ycmd="%%~n\%%~m.bat") else (set %%ycmd="%%m.bat"))^&^
       call set "%%ycmd=/min cmd /d /q /r %%%%ycmd%%"^&(set %%ypfx="")^&set "%%y6="^
      ))^
     )) else (^
      (if defined %%yfol if defined %%y11 (^
       for /F "tokens=*" %%i in ('"echo.%%%%yfol:~0,-1%%\%%%%ycmd:~1%%"') do (set "%%ycmd=%%i")^
      ) else (^
       for /F "tokens=*" %%i in ('"echo.%%%%yfol:~1,-1%%\%%%%ycmd%%"') do (set "%%ycmd=%%i")^
      ))^&^
      call set "%%ycmd=%%%%ycmd:.\=%%"^
     ))^&^
     (for /F "tokens=1,*" %%i in ('echo "%%%%yr%%" "%%%%ypfx:~1,-1%%%%%%yat%% %%%%ycmd%%"') do (^
      (cmd /d /q /v:on /e:on /r "start %%hApplication starter%%h /i /b /min cmd /c start %%h@runapp: starting application...%%h /min cmd /c %%hecho Starting wait...%%~g%%~gecho.%%~iNUL%%~gpathping 127.0.0.1 -n -q 1 -p 50 %%~iNUL%%~gcmd /c start %%~j%%h")^
     ))^
    ))^
   ))^
  ) else (^
   set "%%ycmd="^&call set "%%ycmd=%%%%yrap%%"^&^
   (if not defined %%ycmd (echo Error [@runapp]: Command string has controls, assign value to variable and use its name for parameter #2.^&exit /b 1))^&^
   set "%%yrap="^&(for /F %%a in ('echo.@runapp') do (cmd /d /q /r "%%%%a%% %%%%ycmd%%") ^|^| (exit /b 1))^&^
   set "%%ycmd="^
  ))^
 ) else (echo Error [@runapp]: Absent parameters.^&exit /b 1)) else set wds_rua_rap=
 
::          @str_length - calculates length of string using binary search of last symbol.
::                        %~1 == the name of external variable containing string;
::                        %~2 == [optional: the name of external variable to set result, by default - `%~1_len`];
::                        %~3 == [optional: `1` to echo result instead of assigning, any other & empty one is for assigning].
::
set @str_length=^
 for %%m in (... ... 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1 0) do if defined wds_slm_len (^
  (if %%m NEQ 0 (^
   (if defined wds_slm_str (^
    call set "wds_slm_chk=%%wds_slm_str:~%%m,1%%"^&^
    (if defined wds_slm_chk (call set "wds_slm_str=%%wds_slm_str:~%%m%%"^&set /a "wds_slm_len+=%%m"^>NUL))^
   ))^
  ) else (^
   (if defined wds_slm_eco (call echo "%%wds_slm_lnn%%=%%wds_slm_len%%") else (^
    call set "%%wds_slm_lnn%%=%%wds_slm_len%%"^&^
    set "wds_slm_str="^&set "wds_slm_chk="^&set "wds_slm_lnn="^&set "wds_slm_eco="^
   ))^&^
   set "wds_slm_len="^
  ))^
 ) else if defined wds_slm_nam (^
  (for /F "tokens=1,2,3" %%a in ('echo %%wds_slm_nam%%') do (^
   set "wds_slm_nam=%%a"^&^
   (if defined %%a (call set "wds_slm_str=%%%%a%%"^&set "wds_slm_len=1") else (set "wds_slm_str="^&set "wds_slm_len=0"))^&^
   (if "%%~b"=="" (set "wds_slm_lnn=%%a_len") else (set "wds_slm_lnn=%%~b"))^&^
   (if "%%~c"=="1" (set "wds_slm_eco=1") else (set "wds_slm_eco="))^
  ))^&^
  set "wds_slm_nam="^
 ) else set wds_slm_nam=
 
::         @str_unquote - removes all quotation marks in the string.
::                        %~1 == the name of external variable containing string;
::                        %~2 == [optional: the symbol or string to insert instead of found quote symbols, by default - nothing].
::
set @str_unquote=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_unq_par (^
  (set wds_unq_quo="")^&^
  (for /F "tokens=1,2,3" %%a in ('echo %%wds_unq_quo:~1%% %%wds_unq_par%%') do if defined %%~b (call set %%~b=%%%%~b:%%a=%%c%%))^&^
  set "wds_unq_par="^&set "wds_unq_quo="^
 ) else (echo Error [@str_unquote]: Absent parameter.^&exit /b 1)) else set wds_unq_par=
 
:::   @fixedpath_8d3 - auxiliary macro for internal use by macro @fixedpath exclusively.
:::
set @fixedpath_8d3=^
 (for /F %%y in ('echo wds_fpn_') do (^
  (set "@fixedpath_8d3=")^&^
  (for /F %%a in ('"echo.1+%%%%y8:,=,2+%%"') do for %%b in (%%a) do for /F "tokens=1,2 delims=+" %%c in ('echo.%%b') do if %%c NEQ %%d (^
   for /F "tokens=*" %%e in ('echo.%%%%y%%d%%') do (set "%%y%%c=%%e")^
  ))^&^
  (for /F %%a in ('echo.%%%%yrs%%') do for /F "tokens=*" %%b in ('echo.%%%%y1%%') do for /F "tokens=*" %%c in ('echo.%%%%y2%%') do (^
   (if %%a LSS 4 if not %%b==%%c (exit /b 0))^&^
   set "%%yx="^&^
   (for /F "tokens=2 delims=:=" %%d in ('"fsutil behavior query disable8dot3"') do for /F %%e in ('echo.%%d') do if %%e NEQ 0 (^
    set "%%yx=%%e"^
   ))^&^
   (if %%a EQU 6 (^
    (if not %%b==%%c for /F "tokens=*" %%d in ('echo."%%%%yf:~1,-1%%%%~c" ""') do (^
     cmd /d /q /r "fsutil file setshortname %%d"^
    )^>NUL 2^>^&1)^&^
    echo %%y5=%%c^&exit /b 0^
   ))^&^
   (if 3 LSS %%a (set /a "%%yrs-=2"^>NUL))^
  ))^&^
  (set %%ya="^^^&")^&(set %%yc="^^^^")^&(set %%ye="^^^^^!^^^!^^^!")^&(set %%yp="^%%")^&(set %%yr="^^^>")^&(for %%a in (a,c,e,p,r) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  (for /F %%q in ('echo." ."') do for /F "tokens=1,2,3,4,5,*" %%a in ('echo."%%%%yc%%" %%%%ye%% %%%%yp%% "%%%%ya%%" %%%%yrs%% %%%%yrl%%') do (^
   (for /F "tokens=*" %%g in ('echo.%%%%y1%%') do for /F "tokens=*" %%h in ('echo.%%%%y2%%') do (^
    set "%%ygo=1"^&(if defined %%yrk (set %%y0="~") else (set %%y0="#"))^&^
    (for %%i in (1 2) do if defined %%ygo (^
     (for %%j in ("l=1","go=","no=","nl=0","ns=","ft=","pt=","el=0","es=","o=[+;,]","d=({'$#@-`})") do (set "%%y%%~j"))^&^
     (if %%i EQU 2 (set "%%yfn=1"^&call set "%%y3=%%%%y2:~1,-1%%") else (^
      (if %%g==%%h (set "%%yfn=1") else (set "%%yfn="))^&call set "%%y3=%%%%y1:~1,-1%%"^
     ))^&^
     (for %%j in (%%f) do (^
      call set "%%y4=%%%%y3:~%%j,1%%"^&(if defined %%y4 (call set "%%y3=%%%%y3:~%%j%%"^&call set /a "%%yl+=%%j"^>NUL))^
     ))^&^
     (for /F "tokens=*" %%j in ('echo.%%%%y%%i%%') do (set "%%y3=%%j"))^&^
     (for /F "tokens=1,2,3,4" %%j in ('echo.%%%%yl%% %%%%y0%% "%%%%yd%%" "%%%%yo%%"') do for /L %%n in (1,1,%%j) do for /F "tokens=*" %%o in ('echo."%%%%y3:~%%n,1%%"') do (^
      (if %%o==" " (set "%%yok=") else (^
       set "%%yok=1"^&^
       (if %%o=="=" (set "%%yok=") else if %%o==%%a (set "%%yok=") else if %%o=="%%b" (set "%%yok=") else if %%o=="%%c" (set "%%yok=") else if %%o==%%d (set "%%yok="))^&^
       (if defined %%yok if %%e EQU 3 if %%o==%%k (^
        (if defined %%yfn (set "%%yok=") else if defined %%yft (set "%%yok=") else if defined %%ypt (set "%%yok="))^&^
        set "%%yft=1"^
       ) else if %%o=="~" (set "%%yok=") else for /F %%p in ('echo."%%%%yd:%%~o=%%"') do if not %%p==%%l (set "%%yok="))^&^
       (if defined %%yok if not %%o=="~" for /F %%p in ('echo."%%%%yo:%%~o=%%"') do if not %%p==%%m (set "%%yok="))^
      ))^&^
      (if defined %%yok (^
       (if %%o=="." (^
        (if defined %%ypt (^
         (if defined %%yes (^
          (if defined %%yfn if defined %%yns (call set "%%yns=%%%%yns%%%%%%yes%%") else (call set "%%yns=%%%%yes%%"))^&^
          set "%%yes="^
         ))^&^
         set "%%yno=1"^&call set /a "%%ynl+=1+%%%%yel%%"^>NUL^&set "%%yel=0"^
        ))^&^
        set "%%ypt=1"^
       ) else if defined %%ypt (^
        set /a "%%yel+=1"^>NUL^&(if defined %%yfn if defined %%yes (call set "%%yes=%%%%yes%%%%~o") else (set "%%yes=%%~o"))^
       ) else (^
        set /a "%%ynl+=1"^>NUL^&(if defined %%yfn if defined %%yns (call set "%%yns=%%%%yns%%%%~o") else (set "%%yns=%%~o"))^
       ))^
      ) else (set "%%yno=1"))^
     ))^&^
     (if not defined %%yno for /F %%j in ('echo.%%%%ynl%%') do if 8 LSS %%j (set "%%yno=1"))^&^
     (if not defined %%yno for /F %%j in ('echo.%%%%yel%%') do if 3 LSS %%j (set "%%yno=1"))^&^
     (if defined %%yno if not %%g==%%h (set "%%ygo=1"))^
    ))^
   ))^&^
   (if defined %%yno (^
    (for /L %%g in (2,1,8) do (^
     set "%%y4=1"^&(for /L %%h in (2,1,%%g) do (call set "%%y3=%%%%y4%%"^&set /a "%%y4*=10"^>NUL))^&set /a "%%y4-=1"^>NUL^&^
     set /a "%%y5=8-%%g"^>NUL^&^
     (for /F "tokens=1,2,3" %%h in ('echo.%%%%y3%% %%%%y4%% %%%%y5%%') do for /L %%k in (%%h,1,%%i) do (^
      (if defined %%yrk (set "%%yfn=~") else (set "%%yfn=#"))^&^
      (if defined %%yns (^
       if defined %%yes (call set %%yfn=%%%%yns:~0,%%j%%%%%%yfn%%%%k.%%%%yes:~0,3%%) else (call set %%yfn=%%%%yns:~0,%%j%%%%%%yfn%%%%k)^
      ) else (^
       if defined %%yes (call set %%yfn=%%%%yfn%%%%k.%%%%yes:~0,3%%) else (call set %%yfn=%%%%yfn%%%%k)^
      ))^&^
      (for /F "tokens=*" %%l in ('echo."%%%%yf:~1,-1%%%%%%yfn%%"') do if not exist %%l (^
       (for /F "tokens=1,* delims=." %%m in ('"find "" ".%%%%yfn%%" 2%%%%yr%%%%%%ya%%1"') do (^
        call set "%%yfn=%%%%yfn:%%n=%%"^>NUL 2^>^&1^&^
        (if not defined %%yfn for /F "tokens=*" %%o in ('echo."%%%%yf:~1,-1%%%%%%y2:~1,-1%%" "%%n"') do (^
         ((cmd /d /q /r "fsutil file setshortname %%o")^>NUL 2^>^&1)^&^
         (if defined %%yx for /F "tokens=*" %%p in ('echo."%%%%yf:~1,-1%%%%n"') do if not exist %%p (^
          ((cmd /d /q /r "fsutil behavior set disable8dot3 0")^>NUL 2^>^&1)^&^
          ((cmd /d /q /r "fsutil file setshortname %%o")^>NUL 2^>^&1)^&^
          ((call cmd /d /q /r "fsutil behavior set disable8dot3 %%%%yx%%")^>NUL 2^>^&1)^
         ))^&^
         (for /F "tokens=*" %%p in ('echo."%%%%yf:~1,-1%%%%n"') do if exist %%p (echo %%y5="%%n"))^
        ))^&^
        exit /b 0^
       ))^
      ))^
     ))^
    ))^
   ))^
  ))^
 ))

:::   @fixedpath_parser - auxiliary macro for internal use by macro @fixedpath exclusively.
:::
set @fixedpath_parser=if defined wds_fpn_parser for /F %%y in ('echo wds_fpn_') do (^
 (for /F %%a in ('%%%%yru%%') do (set %%a))^&^
 (for /F %%a in ('echo.%%%%yrf%%') do if defined %%a for /F "tokens=*" %%b in ('echo.%%%%a%%') do (set "%%yrf=%%b"))^&^
 (for /F %%a in ('%%%%yrm%%') do if defined %%a (set "%%a="))^>NUL 2^>^&1^&^
 (for %%a in ("rev=1","l=1","n=1","s=1","y= findstr /i /r ","v=cmd /d /q /r ") do (set "%%y%%~a"))^&^
 (for /F %%q in ('echo." ."') do for /F "tokens=1,2,3,4" %%b in ('"call echo "%%%%yrc%%" %%%%yre%% %%%%yrp%% "%%%%yra%%""') do (^
  (call set %%yrf="%%%%yrf:%%q=%%")^&^
  (if defined %%yro (^
   (set %%yx="for /F %%qtokens=%%%%y9%%%%q %%da in ('%%qdir /a /-c %%%%yr2%%%%%%y5%%%%q') do if %%%%y8%% EQU 1 (echo.%%db) else (echo.%%da)")^&^
   (if defined %%yri for /F "tokens=*" %%f in ('cmd /d /q /r "%%%%yrj%%"') do (set %%f))^
  ) else for /F %%f in ('"echo.%%%%yrf:~-2,1%%"') do if "%%f"=="\" (set "%%ys="))^&^
  (for %%f in (j,m,c,e,p,a) do (set "%%yr%%f="))^&^
  call set %%yrf="%%%%yrf:~1,-1%%\"^&(for %%f in ("/CHR{20}= ","\.\=\","\\=\") do (call set %%yrf=%%%%yrf:%%~f%%))^&^
  call set "%%y5=%%%%yrf:~1,-1%%"^&^
  (for /F "tokens=*" %%h in ('echo.%%%%yrl%%') do (^
   (for %%f in (%%h) do (^
    call set "%%y6=%%%%y5:~%%f,1%%"^&^
    (if defined %%y6 (call set "%%y5=%%%%y5:~%%f%%"^&set /a "%%yl+=%%f"^>NUL))^
   ))^&^
   (for /F %%f in ('echo.%%%%yl%%') do for /L %%g in (1,1,%%f) do if defined %%yn (^
    (for /F "tokens=*" %%i in ('echo."%%%%yrf:~%%g,1%%"') do (^
     (if defined %%yrfv (^
      set "%%y5="^&^
      (if defined %%yro (^
       set "%%y6=."^&(if %%i=="*" (set "%%y6=.*") else if "%%~i%%~i"==%%b (set "%%y6=.*") else if not %%i=="?" if not %%i==" " if not %%i=="%%c" if not %%i=="%%d" if not %%i=="%%~e" (set "%%y6="))^&^
       (if not defined %%y6 if not "%%~i"=="\" (set "%%y5=1"))^&^
       (if defined %%y5 (^
        if defined %%yc (call set %%yr="%%%%yr:~1,-1%%\%%~i") else (set %%yr="\%%~i")^
       ) else (^
        (if defined %%yd (^
         (call set %%yd="%%%%yd:~1,-1%%%%%%y7%%%%%%yr:~1,-1%%")^&set "%%yc="^
        ) else (call set "%%yd=%%%%yr%%"^&(if not "%%~i"=="\" (set "%%yc="))))^&^
        call set "%%y7=%%%%y6%%"^&(set %%yr="")^
       ))^
      ) else if not "%%~i"=="\" (set "%%y5=1"^&set /a "%%yl+=1"^>NUL))^&^
      (if defined %%y5 if defined %%yc (^
       if defined %%yro (call set %%yc="%%%%yc:~1,-1%%%%~i") else for /F "tokens=*" %%j in ('echo.%%%%yc%%') do (set %%yc="%%~j%%~i")^
      ) else (set "%%yc=%%i"))^&^
      (if %%i=="\" (^
       (for %%j in (1,2,4,6,7,e) do (set "%%y%%j="))^&^
       (if defined %%yro (for /F "tokens=1,2,3 delims=<>" %%j in ('%%%%yv%%%%%%yrw%%') do if not defined %%y1 (^
        set "%%ye=1"^&set "%%y5=%%j"^&^
        (for /F "delims=\" %%m in ('"echo.%%%%y5:    =\%%"') do (^
         set "%%y5="^&(set %%y3= %%%%yrb:~-2,1%% findstr /c:)^&^
         (for %%n in (%%m) do (^
          (call set %%y4=%%%%y3%%"%%n")^&(if defined %%y5 (call set "%%y5=%%%%y5%%%%%%y4%%") else (call set "%%y5=%%%%y4%%"))^
         ))^&^
         (if "%%k"=="" (^
          set %%y3="%%j"^&set %%y8=2^&set "%%y9=*"^
         ) else (^
          set "%%ye="^&set %%y8=1^&set "%%y9=2,* delims=<>"^&^
          (if "%%k"=="JUNCTION" for /F "tokens=1,* delims=\" %%n in ('echo.%%l') do (^
           set "%%y3=%%~n"^&(call set %%y7="%%%%y3:~-2,2%%\%%o")^&(call set %%y7="%%%%y7:~1,-2%%")^&(call set %%y3="%%%%y3:~1,-4%%")^
          ) else (set %%y3="%%l"))^
         ))^&^
         set "%%y4="^&set "%%yl=3,4"^&^
         (for /F "tokens=*" %%n in ('%%%%yv%%%%%%yx%%') do if defined %%yl (^
          (set %%y4=" %%n")^&^
          (for /F %%o in ('echo.%%%%yl%%') do (^
           (for %%p in (%%o) do for /F "tokens=*" %%s in ('"echo.%%%%y%%p:%%m=%%"') do (set "%%y%%p=%%s"))^&^
           (if defined %%y7 for /F "tokens=*" %%p in ('echo.%%%%y7%%') do (call set "%%y4=%%%%y4: [%%~p]=%%"))^&^
           (for %%p in (%%o) do if "%%k"=="" (^
            for /F "tokens=2,*" %%t in ('echo.%%%%y%%p%%') do (set "%%y%%p=%%q%%u")^
           ) else (^
            for /F "tokens=1,*" %%t in ('echo.%%%%y%%p%%') do (set "%%y%%p=%%q%%u")^
           ))^
          ))^&^
          set "%%yl=4"^&^
          (for /F "tokens=*" %%o in ('echo.%%%%y3%%') do for /F "tokens=*" %%p in ('echo.%%%%y4%%') do (^
           (if %%o==%%p (set "%%yl=") else for /F "tokens=1,*" %%s in ('"echo.%%%%y3:%%~p=%%"') do (^
            if %%t==%%q (set "%%yl="^&set "%%y3=%%s%%q") else (set "%%y4=")^
           ))^
          ))^
         ))^&^
         (if defined %%yc if defined %%y4 for /F "tokens=*" %%n in ('echo.%%%%y4%%') do (^
          (for /F "tokens=*" %%m in ('echo.%%%%y3%%') do for /F "tokens=*" %%o in ('echo.%%%%yc%%') do (^
           set "%%y5="^&(if %%m==%%n (if %%m==%%o (set %%y5=1)) else if %%m==%%o (set %%y5=1) else if %%n==%%o (set %%y5=1))^&^
           (if defined %%y5 (^
            set "%%y1=%%m"^&set "%%y2=%%n"^&(if defined %%y7 (call set "%%y6=%%%%y7%%"))^&(if defined %%ye (set "%%yn="))^
           ))^
          ))^
         ))^
        ))^
       )^>NUL 2^>^&1) else for /F "tokens=*" %%j in ('echo.%%%%yc%%') do (^
        set "%%y3=%%j"^&set "%%y4=%%j"^&set "%%yd=[*]"^
       ))^&^
       (if defined %%y4 (^
        (if defined %%y1 (set "%%y5=1 2 6") else (set "%%y5=3 4 7"^&(if defined %%ye (set "%%yn="))))^&^
        (for /F "tokens=1,2,3" %%j in ('echo.%%%%y5%%') do (^
         (for /F "tokens=*" %%m in ('echo.%%%%y%%j%%') do for /F "tokens=*" %%n in ('echo.%%%%y%%k%%') do (^
          (for /F %%o in ('echo.%%%%yrs%%') do if %%o EQU 0 (set "%%y5=%%n") else if %%o EQU 1 (set "%%y5=%%m") else (^
           set "%%y5=%%m"^&set "%%y8=%%j,%%k"^&(for /F "tokens=*" %%p in ('cmd /d /q /r "%%@fixedpath_8d3%%"') do (set %%p))^
          ))^&^
          (if defined %%yn (^
           (call set %%y5="%%%%y5:~1,-1%%\")^&^
           (if defined %%y%%l for /F %%o in ('echo.%%%%y%%l%%') do (^
            if exist "%%~sdpnxo" (set %%yf="%%~sdpnxo\") else (set %%yf="%%%%y%%l:~1,-1%%\")^
           ) else (call set %%yf="%%%%yf:~1,-1%%%%%%y5:~1,-1%%"))^
          ))^
         ))^
        ))^&^
        (call set %%yrpv="%%%%yrpv:~1,-1%%%%%%yrnv:~1,-1%%")^&^
        (for /F "tokens=1,* delims=." %%n in ('echo.%%%%yd%%') do if "%%o"=="" (call set "%%yrnv=%%%%y5%%") else (^
         (set %%yrnv="")^&^
         (if defined %%yro (^
          set "%%yl=1"^&call set "%%y1=%%%%y5:~1,-1%%"^&^
          (for %%o in (%%h) do (^
           call set "%%y2=%%%%y1:~%%o,1%%"^&^
           (if defined %%y2 (call set "%%y1=%%%%y1:~%%o%%"^&call set /a "%%yl+=%%o"^>NUL))^
          ))^
         ))^&^
         set "%%y2="^&^
         (for /F %%o in ('echo.%%%%yrh%%') do (^
          (for /F %%p in ('echo.%%%%yl%%') do for /L %%s in (1,1,%%p) do for /F "tokens=*" %%t in ('echo."%%%%y5:~%%s,1%%"') do (^
           (if "%%~t%%~t"==%%b (^
            if %%o EQU 3 (set %%y1=/CHR{5E}) else if defined %%yrv (set "%%y2=%%%%yrc%%") else (set "%%y1=%%~t")^
           ) else if %%t=="%%c" (^
            if %%o EQU 3 (set %%y1=/CHR{21}) else if defined %%yrv (set "%%y2=%%%%yre%%") else (set "%%y1=%%c")^
           ) else if %%t=="%%d" (^
            if %%o EQU 3 (set %%y1=/CHR{25}) else (^
             (if defined %%yrv (set "%%y2=%%%%yrp%%") else (set "%%y1=%%d"))^&^
             (if defined %%yry if defined %%yrv (call set "%%y2=%%%%yrp%%%%%%y2%%") else (call set "%%y1=%%d%%%%y1%%"))^
            )^
           ) else if %%t==%%e (^
            if %%o EQU 3 (set %%y1=/CHR{26}) else if defined %%yrv (set "%%y2=%%%%yra%%") else (set "%%y1=%%~t")^
           ) else (^
            set "%%y2="^&set "%%y1=%%~t"^
           ))^&^
           (if defined %%y2 (call set "%%y1=%%%%yrr:~1,-1%%%%%%y2%%"))^&(call set %%yrnv="%%%%yrnv:~1,-1%%%%%%y1%%")^
          ))^
         ))^
        ))^&^
        (call set %%yrfv="%%%%yrfv:~1,-1%%%%%%yrnv:~1,-1%%")^&set "%%yrev=0"^
       ) else (set "%%yrev=1"^&set "%%yn="))^
      ))^
     ) else (^
      (if defined %%yc (call set %%yc="%%%%yc:~1,-1%%%%~i") else (set "%%yc=%%i"))^&^
      (if "%%~i"=="\" (^
       (for /F %%j in ('echo.%%%%yc%%') do (^
        (if not defined %%yro if not exist %%j (set "%%yn="))^&^
        set "%%yf=%%j"^&set "%%yrfv=%%j"^&(set %%yrpv="")^&set "%%yrnv=%%j"^
       ))^
      ))^
     ))^&^
     (if "%%~i"=="\" (set "%%yl=1"^&set "%%yd="^&set "%%yc="^&(set %%yr="")))^
    ))^
   ))^
  ))^
 ))^&^
 (if defined %%ys if not defined %%yro for %%a in (rfv,rnv) do for /F "tokens=*" %%b in ('"echo.%%%%y%%a:~1,-2%%"') do (set %%y%%a="%%b"))^&^
 (for %%a in (re,rf,rp,rn) do if defined %%y%%an if defined %%y%%av (call echo %%%%y%%an%%=%%%%y%%av%%) else (call echo "%%%%y%%an%%="))^
)

::           @fixedpath - obtains full path name according given search template.
::                        %~1 == variable name of caller to get common result (0/1 <=> Found/Absent, see also `1:%~3`..`3:%~5`);
::                        %~2 == the path to the object on disk (variable name of the caller or quoted string w/o spaces);
::                      Optional not required variable names with internal identifier and marker ":" to return result strings:
::                      1:%~3 == full path to object;
::                      2:%~4 == full path to the folder containing object;
::                      3:%~5 == name of the object without path;
::                             - if parameters `1:%~3`..`3:%~5` are absent, it assigns full path to `%~1`;
::                      Optional not required key parameters with internal identifier and marker ":":
::                      4:%~6 == specifies use of "8.3" alternative dos names in the result:
::                             `0` - default value to return full path containing full names;
::                             `1` - use short name (8d3) if it exists for any object in the path;
::                             `2` - use 8d3 always, create it if absent, skip controls: ! % & ^ ~ 
::                             `3` - use 8d3 always, create it if absent, skip symbols: ( ) ' ` $ # @ { } -
::                             `4` - use 8d3 always, modify existing names to drop controls: ! % & ^ ~ 
::                             `5` - use 8d3 always, modify existing names to drop symbols: ( ) ' ` $ # @ { } -
::                             `6` - cleanup any 8d3 names, return path containing only full names;
::                             - not allowed characters removed for any new name and option, namely: [ + ; , = ] . Space
::                      5:%~7 == use standard character `~` as number prefix in 8d3 name (`1`), default is `0` to use `#`;
::                      6:%~8 == specify handling of controls `!`, `%`, `&` or `^`:
::                             `0` - default value to return string corresponding current state of delayed expansions;
::                             `1` - return string corresponding disabled delayed expansions;
::                             `2` - return string corresponding enabled delayed expansions;
::                             `3` - encode controls using prefix `/CHR{`, suffix `}` & hex-codes of symbols;
::                      7:%~9 == enabled expansions target: string compatible with `!myfile!` (`1`), default `0` for `%myfile%`;
::                      8:%~10== get string to set value in format: `set MyVariable="path to object"` (`1`), default is `0`;
::                      9:%~11== don't check objects on disk, only adjust input string (`1`), default is `0`;
::                             - key invalidates values of `4:%~6`, `5:%~7` & `A:%~12`;
::                             - key invalidates any sense of `%~1`, use it to return result string instead of `1:%~3`;
::                      A:%~12== extract absolute path for relative (default, `1`), `0` to return relative path as is.
::                      B:%~13== `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: it can be called within context of enabled or disabled delayed expansions;
::                    #2: the state of delayed expansions must coincide for macro definition & for attribute `/v` of cmd.exe;
::                    #3: due to internal checks, it's compatible with @mac_check macro only for enabled expansions of caller, but
::                        the call of macro inside any wrapper of library modifies string for external caller & isn't recommended;
::                    #4: the input string is a search template, can have next key words:
::                             - wildcard `*` for any substring or its absense;
::                             - wildcard `?` for arbitrary symbol;
::                             - one or several prefixes `..\` as redirections to the root folders of relative path;
::                             - the template isn't exact set of symbols by itself for the following characters:
::                                   1. `!`, `%`, `&` and ` ` - treated as arbitrary symbol or `?`;
::                                   2. `^` - treated as any substring or `*`;
::                    #5: if adding of 8d3 name fails for locked object, it uses existing name in the result;
::                    #6: if `%~2` contains explicit string, the spaces symbols must be replaced by `/CHR{20}`;
::                    #7: key `8:%~10` serves to print string to file via redirection `(...)>>mypathdef.bat` after macro call;
::                    #8: macro initializes output parameters in given here order, several use of same name hides previous value;
::                    #9: due to internal check its call from another macro can fail with error, see @shortpath for sample & w/a;
::                    #A: macro is not designed for work with network folders, only for local drive locations.
::          Dependencies: @fixedpath_8d3, @fixedpath_parser, @unset_mac.
::
set @fixedpath=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_fpn_aux for /F %%y in ('echo wds_fpn_') do (^
  (for %%a in ("rf=","ren=","rfn=","rpn=","rnn=","rs=0","rh=0","rx=","rk=","re=","rv=","ry=","ro=0","ri=1","rz=","ra=","re=","rc=","rp=","ru=""","cmd=cmd /d /q /e:on /v:off /r ","rl=8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1") do (set "%%y%%~a"))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13" %%a in ('echo.%%%%yaux%%') do (^
   (if "%%~b"=="" (echo Error [@fixedpath]: Absent parameter #2.^&exit /b 1))^&^
   set "%%~a=1"^&(for /F %%n in ('"echo.%%%%~a%%"') do if not "%%n"=="1" (echo Error [@fixedpath]: Parameter #1 has unallowed variable name '%%~a'.^&exit /b 1))^&^
   (if defined PATH (^
    set "%%yrw=^^^!PATH^^^!"^&call set "%%yrw=%%%%yrw:PATH=%%"^&call set "%%yrw=%%%%yrw:~1,-1%%"^&set "%%yq=C:\"^&^
    (if exist "^!%%yq^!" (^
     set "%%yrv=1"^&(if not "^!%%yren^!"=="" if defined %%yrw (set "%%yrw=") else (set "%%yrw=1"))^
    ) else for /F %%n in ('"echo.^!%%yq^!"') do if exist "%%n" (set "%%yrw=1") else (^
     (for /F %%o in ('echo."%%%%yren%%"') do (call set "%%yq=%%~o"))^&^
     (if not defined %%yq (call set "%%yrw=%%%%yrw:~1,-1%%"))^&^
     (if defined %%yrw (set "%%yrw=") else (set "%%yrw=1"))^
    ))^
   ) else (echo Error [@fixedpath]: Undefined PATH variable.^&exit /b 1))^&^
   (if defined %%yrw (echo Error [@fixedpath]: Not adequate state of delayed expansions, redefine macro.^&exit /b 1))^&^
   set "%%yrf="^&^(if "%%~b"==%%b (set "%%yrf=%%~b") else if defined %%~b (call set "%%yrf=%%~b"))^&^
   (if not defined %%yrf (echo Error [@fixedpath]: Parameter #2 hasn't template to search source object.^&exit /b 1))^&^
   (for %%n in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m) do if not "%%n"=="" (^
    set "%%yaux=%%n"^&call set "%%yrw=%%%%yaux:~2%%"^&^
    (if defined %%yrw (call set /a "%%yaux=0x%%%%yaux:~0,1%%"^>NUL 2^>^&1)^>NUL ^&^& (for /F %%o in ('echo.%%%%yaux%%') do (^
           (if %%o EQU 1 (set "%%yq=rfn"^
     ) else if %%o EQU 2 (set "%%yq=rpn"^
     ) else if %%o EQU 3 (set "%%yq=rnn"^
     ) else (call set /a "%%yrw=0x%%%%yrw%%"^>NUL 2^>^&1)^>NUL ^&^& for /F %%p in ('echo.%%%%yrw%%') do (^
            (if %%o EQU 4 (if 0 LSS %%p if %%p LSS 7 (set "%%yrs=%%p"^&(if 1 LSS %%p (set %%yru=",fixedpath_8d3")))^
      ) else if %%o EQU 5 (if %%p EQU 1 (set "%%yrk=1")^
      ) else if %%o EQU 6 (if 0 LSS %%p if %%p LSS 4 (set "%%yrh=%%p")^
      ) else if %%o EQU 7 (if %%p EQU 1 (set "%%yrx=1")^
      ) else if %%o EQU 8 (if %%p EQU 1 (set "%%yry=1"^&set "%%yrz=1")^
      ) else if %%o EQU 9 (if %%p EQU 1 (set "%%yro=")^
      ) else if %%o EQU 10 (if %%p EQU 0 (set "%%yri=")^
      ) else if %%o EQU 11 (if %%p EQU 1 (set "%%yrz=1")^
      ))^&^
      set "%%yq="^
     ))^&^
     (if defined %%yq (^
      call set "%%%%yrw%%=1"^&(for /F %%p in ('"echo %%%%yrw%%"') do for /F %%r in ('"echo %%%%p%%"') do if not "%%r"=="1" (call set /a "%%yaux=%%o+2"^>NUL^&call echo Error [@fixedpath]: Parameter #%%o:%%%%yaux%% has unallowed variable name '%%%%yrw%%'.^&exit /b 1))^&^
      call set "%%y%%%%yq%%=%%%%yrw%%"^
     ))^
    )))^
   ))^&^
   set "%%yaux=1"^&(if not defined %%yrfn if not defined %%ypan if not defined %%yrnn (set "%%yaux="^&set "%%yrfn=%%~a"))^&^
   (if defined %%yaux (set "%%yren=%%~a"))^
  ))^&(if not defined %%yrf (echo Error [@fixedpath]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (if not defined %%yro (set "%%yrs=0"^&set "%%yri="))^&^
  (for /F %%a in ('echo.%%%%yrh%%') do if %%a EQU 0 (if "^!%%yrh^!"=="0" (set "%%yrh=2") else (set "%%yrh=1")))^&^
  (set %%yrr="")^&^
  (for /F %%a in ('echo.%%%%yrh%%') do (^
   (if %%a EQU 2 (set "%%yrw=1") else (set "%%yrx="^&(if defined %%yrv (set "%%yrw=1") else (set "%%yrw="))))^&^
   (if defined %%yrw if defined %%yry (^
    if defined %%yrx (set %%yrr="%%%%yrc%%") else if %%a EQU 2 (set %%yrr="%%%%yrc%%%%%%yrc%%%%%%yrc%%")^
   ) else if defined %%yrz (^
    (if defined %%yrv (^
     if defined %%yrx (set %%yrr="%%%%yrc%%") else if %%a EQU 2 (set %%yrr="%%%%yrc%%%%%%yrc%%%%%%yrc%%") else (set %%yrr="%%%%yrc%%")^
    ) else (^
     if not defined %%yrx (set %%yrr="%%%%yrc%%")^
    ))^
   ) else (^
    if %%a EQU 2 if not defined %%yrx (set %%yrr="%%%%yrc%%")^
   ))^&^
   (if %%a EQU 2 (set "%%yrv=1"))^
  ))^&^
  set "%%yq="^&^
  set "%%yr1=%%%%yf%%"^&set "%%yr2=%%%%yr1%%"^&^
  (for /F "tokens=1,2,3,4,5,6,*" %%a in ('"echo.%%%%yq%% %%%%yrp%% %%%%yrc%% %%%%yra%% %%%%yrb:~-2,1%% %%%%yrb:~0,1%% call cmd /d /q /r"') do for /F "tokens=1,*" %%h in ('echo.%%%%yru%% start /b /i /realtime cmd /d /q /r') do (^
   (set %%yaux="set %%yparser=@fixedpath_parser%%d(for /F %%atokens=*%%a %%bp in ('%%%%ycmd%%%%a%%%%%%yparser%%%%%%a') do (echo %%bp))")^&^
   (set %%yrw="call dir /a /x /-c %%%%yr2%% %%e%%%%yy%%/v /c:%%%%yrq%% %%e%%%%yy%%[0..9] %%e%%%%yy%%\: %%e%%%%yy%%%%%%yd:~1,-1%%")^&^
   (set %%yru=%%i "set fixedpath_shrink=@unset_mac%%d(%%g %%a%%b%%bfixedpath_shrink%%b%%b[]%%~h%%a)%%d(echo %%a@unset_mac=%%a)%%d(echo %%a%%yru=%%a)")^&^
   (set %%yrm=%%i "(for /F %%adelims==%%a %%bz in ('%%aset%%a') do (echo %%bz)) %%e findstr /vi /c:%%yr %%e findstr /bvi /c:path %%e findstr /bvi /c:comspec %%e findstr /vi /c:8d3")^&^
   (set %%yrj=%%g "(for /F %%ftokens=*%%f %%ba in ('echo.%%b%%yrf%%b') do (set %%yf=%%ba))%%d(for /F %%ftokens=1,* delims=\%%f %%ba in ('%%fecho.%%b%%yf:~1,-1%%b%%f') do (set %%f%%y0=%%ba%%f%%dcall set %%f%%y0=%%b%%y0:~1%%b%%f%%d(if defined %%y0 for /F %%fdelims=*%%f %%bc in ('echo.%%b%%y0%%b') do if not %%f%%bc%%f==%%f:%%f (set %%f%%y0=%%f))%%d(if not defined %%y0 for /F %%ftokens=*%%f %%bc in ('echo.%%b~dp0') do if %%f%%ba%%f==%%f..%%f (set %%f%%yr=%%b~sdpc%%f%%d(for /L %%bd in (1,1,2048) do ((for /F %%ftokens=1,* delims=\%%f %%be in ('%%fecho.%%b%%yf:~1,-1%%b%%f') do if %%f%%be%%f==%%f..%%f ((set %%yf=%%f%%bf%%f)%%d(for /F %%ftokens=*%%f %%bg in ('echo.%%f%%b%%yr%%b..\%%f') do (set %%f%%yr=%%b~sdpg%%f))) else (call echo %%yrf=%%f%%b%%yr%%b%%be\%%bf%%f%%dexit /b 0))))) else (echo %%yrf=%%f%%b~sdpc%%ba\%%bb%%f))))")^
  ))^&^
  (set %%yq="")^&(set %%yrb="^^^|")^&(set %%yrc="^^^^")^&(set %%yra="^^^&")^&(set %%yre="^^^^^!^^^!^^^!")^&(set %%yrp="^%%")^&^
  (for %%a in (ra,re,rc,rp,q) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  (call set %%yrq="%%%%yrc%%[ ]")^&^
  (for /F "tokens=*" %%a in ('start /b /i /ABOVENORMAL %%%%ycmd%%%%%%yaux%%') do if defined %%yrz (^
   if defined %%yry if defined %%yrv (call echo set %%a) else (echo set %%a) else if defined %%yrv (call echo %%a) else (echo %%a)^
  ) else (^
   if defined %%yrv (call set %%a) else (set %%a)^
  ))^&^
  (for %%a in (aux,cmd,q,r1,r2,ra,rb,rc,rd,re,ren,rf,rfn,rh,ri,rj,rl,rm,rk,rnn,ro,rp,rpn,rq,rr,rs,rt,ru,rv,rw,rx,ry,rz) do (set "%%y%%a="))^
 ) else (echo Error [@fixedpath]: Absent parameter.^&exit /b 1)) else set wds_fpn_aux=
 
::           @shortpath - converts object path string to the string of short "8.3" alternative dos names.
::                        %~1 == name of variable to assign path string with short names;
::                        %~2 == input quoted string value or variable name with path value;
::                        %~3 == [optional: any value after symbol `?` to echo result, for instance - `?e`].
::             Notes. #1: macro extracts full absolute path to object in the case of relative path;
::                    #2: for path with characters `!`, `%`, `&`, `^`, `~` it calls @fixedpath to cleanup names & to get result;
::                    #3: to have more extensive handling options for same purpose use @fixedpath macro.
::          Dependencies: @fixedpath, @fixedpath_8d3, @fixedpath_parser, @unset_mac.
::
set @shortpath=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_fsp_aux for /F %%y in ('echo wds_fsp_') do (^
  (if defined %%ytmp (^
   (for /F "tokens=1,*" %%a in ('echo %%%%ytmp%%') do (^
    (for /F %%c in ('echo." "') do (^
     set "%%yaux="^&^
     (if defined %%b for /F "tokens=*" %%d in ('echo.%%%%b%%') do (set "%%yaux=%%d") else if "%%~b"==%%b (set "%%yaux=%%b"))^&^
     (if defined %%yaux (^
      (call set %%yaux="%%%%yaux:%%c=%%")^&(call set "%%ytmp=%%%%yaux:~-2,1%%")^&^
      (call set "%%ytmp=%%%%ytmp:\=%%")^&(if defined %%ytmp (set %%ytmp="") else (set %%ytmp="\"))^&^
      (call set %%yaux=%%%%yaux:\%%c=%%c%%)^
     ) else (^
      echo Error [@shortpath]: Parameter #2 has empty path string.^&exit /b 1^
     ))^
    ))^&^
    set "%%~a=?"^&(for /F %%c in ('echo.%%%%~a%%') do if not "%%c"=="?" (echo Error [@shortpath]: Incorrect variable name `%%~a`.^&exit /b 1))^&^
    (for /F "tokens=*" %%c in ('echo.%%%%yaux%%') do if exist %%c for /F "tokens=*" %%d in ('echo."%%~sdpnxc%%%%ytmp:~1,-1%%"') do (^
     (echo %%~a=%%d)^&(echo "%%yaux=%%~a")^
    ) else (echo Error [@shortpath]: Source path %%c does not exist.^&exit /b 1))^
   ))^
  ) else (^
   (for /F "tokens=1,2 delims=?" %%a in ('echo.%%%%yaux%%') do for /F %%c in ('echo.@shortpath') do (^
    (if "%%~b"=="" (set "%%yeco=") else (set "%%yeco=1"))^&set "%%ytmp=%%a"^&set "%%yaux="^&^
    (if defined %%ytmp for /F "tokens=*" %%d in ('cmd /d /q /e:on /v:off /r "%%%%c%% %%%%ytmp%%"') do ((set %%d)^>NUL 2^>^&1 ^&^& (if defined %%yaux (^
     for /F %%e in ('echo.%%%%yaux%%') do for /F "tokens=*" %%f in ('echo.%%%%e%%') do if exist %%f (^
      if defined %%yeco (echo "%%e=%%f")^
     ) else (^
      set "%%yaux=on"^&(if not "^!%%yaux^!"=="on" (set "%%yaux=off"))^&^
      (for /F "tokens=1,2,3,4" %%g in ('echo.%%%%yaux%% %%a @fixedpath') do (^
       (set %%yaux=cmd /d /q /e:on /v:%%g /r "%%%%j%% %%h %%i 4:4 5:1 7:1 B:1")^&^
       (if defined %%yeco (cmd /d /q /e:on /v:%%g /r call %%%%yaux%%) else for /F "tokens=*" %%j in ('"call %%%%yaux%%"') do (^
        (set %%j)^>NUL 2^>^&1 ^|^| (echo %%j^&exit /b 1)^
       ))^
      ))^
     )^
    )) ^|^| (echo %%d^&exit /b 1)) else (echo Error [@shortpath]: Absent parameter.^&exit /b 1))^
   ))^&^
   set "%%yaux="^&set "%%ytmp="^
  ))^
 ) else (echo Error [@shortpath]: Absent parameter.^&exit /b 1)) else set wds_fsp_aux=

::          @get_number - sets numeric value to variable.
::                        %~1 == name of variable to assign digital value;
::                        %~2 == input string value;
::                        %~3 == [optional: any value after symbol `?` to echo result, for instance - `?e`].
::             Notes. #1: cleans leading symbols `+`, `-`, `0`;
::                    #2: the sign symbol `-` is valid only at 1st leftmost position of string;
::                    #3: works around internal issue of the script with leading zeroes (drops zeroes & returns decimal result);
::                    #4: in the case of failure it always returns zero.
::
set @get_number=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_sdi_par (^
  (for /F "tokens=1,2 delims=?" %%a in ('echo %%wds_sdi_par%%') do for /F "tokens=1,2" %%c in ('echo.%%a 0') do (^
   set "%%~c=0"^&^
   (for /F %%e in ('echo.%%%%~c%%') do if "%%e"=="0" (^
    (if not "%%~d"=="0" for /F "tokens=* delims=+,-,0 " %%f in ('echo.%%~d') do (^
     (set /a "wds_sdi_par=%%~f"^>NUL 2^>^&1)^>NUL ^&^& (for /F %%g in ('echo.%%wds_sdi_par%%') do if "%%~f"=="%%~g" (^
      set "wds_sdi_par=%%~d"^&^
      (for /F %%h in ('"echo.%%wds_sdi_par:~0,1%%"') do if "%%~h"=="-" (set "%%~c=-%%~f") else (set "%%~c=%%~f"))^
     ))^
    ))^&^
    (if not "%%~b"=="" for /F %%f in ('call echo.%%%%~c%%') do (echo asdasd "%%~c=%%f"))^
   ))^
  ))^&^
  set "wds_sdi_par="^
 ) else (echo Error [@get_number]: Absent parameters.^&exit /b 1)) else set wds_sdi_par=
 
::         @get_xnumber - sets the numeric value of a variable using the hex to decimal conversion of the input string.
::                        %~1 == name of variable to assign digital value;
::                        %~2 == input string value;
::                        %~3 == [optional: any value after symbol `?` to echo result, for instance - `?e`].
::             Notes. #1: cleans internal symbols `+`, `.`, `,`, ` `, takes their first 4 substrings & drops rest right substrings;
::                    #2: the sign symbol `-` after string cleanup can be at 1st position only;
::                    #3: works around internal issue of the script with leading zeroes (drops zeroes & returns decimal result);
::                    #4: in the case of failure it always returns zero.
::
set @get_xnumber=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_xdi_par (^
  (for /F "tokens=1,2 delims=?" %%a in ('"echo %%wds_xdi_par%%"') do (set "wds_xdi_par=%%a"^&set "wds_xdi_eco=%%~b"))^&^
  (for /F "tokens=1,*" %%a in ('"echo %%wds_xdi_par%%"') do if "%%~b"=="" (^
   if defined wds_xdi_eco (echo "%%~a=0") else (set "%%~a=0")^
  ) else (^
   (set wds_xdi_par="^^^^^ ^^^^^^^ ^^^&")^&^
   (for /F "tokens=1,2,3,4" %%c in ('"echo %%wds_xdi_par:~0,1%% %%wds_xdi_par:~2,1%% %%wds_xdi_par:~-2,1%% %%wds_xdi_par:~6,1%%^>"') do (^
    (set wds_xdi_par="(echo $q$%%~a=0$q$%%d%%eset $q$wds_sid_aux=%%~b$q$%%d%%e(for /F $q$tokens=1,2,3,4 delims=+., $q$ %%%%dc in ('echo %%wds_sid_aux%%') do (set $q$wds_sid_aux=%%%%dc%%%%dd%%%%de%%%%df$q$))%%d%%e(for /F $q$tokens=1,2 delims=-$q$ %%%%dc in ('echo $%%wds_sid_aux%%') do if $q$%%%%d~c$q$==$q$$$q$ (call set wds_sid_sgn=$q$%%wds_sid_aux:~0,1%%$q$%%d%%ecall set $q$wds_sid_aux=%%wds_sid_aux:~1%%$q$) else (set wds_sid_sgn=$q$$q$))%%d%%ecall set $q$wds_sid_par=%%wds_sid_aux:~-7,7%%$q$%%d%%e(for /F $q$tokens=*$q$ %%%%dc in ('echo %%wds_sid_par%%') do (call set $q$wds_sid_aux=%%wds_sid_aux:%%%%dc=%%$q$))%%d%%e(if not defined wds_sid_aux (call set $q$wds_sid_aux=%%wds_sid_par%%$q$%%d%%eset $q$wds_sid_par=$q$))%%d%%e(call set /a $q$wds_sid_aux=0x%%wds_sid_aux%%$q$%%fNUL 2%%f%%d%%e1)%%fNUL %%d%%e%%d%%e ((set $q$wds_sid_amp=1%%d%%d%%d%%e1$q$)%%d%%e(call set $q$wds_sid_amp=%%wds_sid_amp:~-2,1%%$q$)%%d%%e(call set /a $q$wds_sid_aux=(1000000*((%%wds_sid_aux%%%%wds_sid_amp%%251658240)/16777216))+(100000*((%%wds_sid_aux%%%%wds_sid_amp%%15728640)/1048576))+(10000*((%%wds_sid_aux%%%%wds_sid_amp%%983040)/65536))+(1000*((%%wds_sid_aux%%%%wds_sid_amp%%61440)/4096))+(100*((%%wds_sid_aux%%%%wds_sid_amp%%3840)/256))+(10*((%%wds_sid_aux%%%%wds_sid_amp%%240)/16))+(%%wds_sid_aux%%%%wds_sid_amp%%15)$q$)%%fNUL%%d%%e(if defined wds_sid_par ((for /F $q$tokens=*$q$ %%%%dc in ('echo %%wds_sid_aux%%') do if %%%%dc EQU 0 ((call set /a $q$wds_sid_par=0x%%wds_sid_par%%$q$%%fNUL 2%%f%%d%%e1)%%fNUL %%d%%e%%d%%e ((call set /a $q$wds_sid_par=(1000000*((%%wds_sid_par%%%%wds_sid_amp%%251658240)/16777216))+(100000*((%%wds_sid_par%%%%wds_sid_amp%%15728640)/1048576))+(10000*((%%wds_sid_par%%%%wds_sid_amp%%983040)/65536))+(1000*((%%wds_sid_par%%%%wds_sid_amp%%61440)/4096))+(100*((%%wds_sid_par%%%%wds_sid_amp%%3840)/256))+(10*((%%wds_sid_par%%%%wds_sid_amp%%240)/16))+(%%wds_sid_par%%%%wds_sid_amp%%15)$q$)%%fNUL%%d%%ecall echo $q$%%~a=%%wds_sid_sgn:~1,-1%%%%wds_sid_par%%$q$)) else ((call set /a $q$wds_sid_aux=%%wds_sid_sgn:~1,-1%%%%wds_sid_aux%%%%wds_sid_par%%$q$%%fNUL 2%%f%%d%%e1)%%fNUL %%d%%e%%d%%e (call echo $q$%%~a=%%wds_sid_aux%%$q$)))%%d%%eset $q$wds_sid_par=$q$) else (call echo $q$%%~a=%%wds_sid_sgn:~1,-1%%%%wds_sid_aux%%$q$))))")^&^
    (call set "wds_xdi_par=%%wds_xdi_par:$q$=%%c%%")^&^
    (for /F "tokens=*" %%g in ('cmd /d /q /r %%wds_xdi_par%%') do (if defined wds_xdi_eco (echo %%g) else (set %%g)))^
   ))^
  ))^&^
  set "wds_xdi_par="^
 ) else (echo Error [@get_xnumber]: Absent parameters.^&exit /b 1)) else set wds_xdi_par=

::                @rand - generates random number within given capacity range.
::                        %~1 == name of variable to set random digital value;
::                        %~2 == the capacity length of random digit to generate, available range [1...8];
::                        %~3 == [optional: any value after symbol `(` to echo result, used locally "(e)"].
::
set @rand=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_rnd_par (^
  (for /F "tokens=1,2 delims=()" %%a in ('"echo %%wds_rnd_par%%"') do (^
   (for /F "tokens=1,2" %%c in ('"echo %%a"') do if "%%~d"=="" (echo Error [@rand]: Absent capacity length in 2nd parameter.^&exit /b 1) else (^
    set "wds_rnd_par="^&^
    (for /F "tokens=* delims=+,-,0" %%e in ('echo %%~d') do (^
     ((set /a "wds_rnd_par=%%~e"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_rnd_par^!"=="%%~e" (set "wds_rnd_par=%%~e")))^&^
     (if defined wds_rnd_par for /F %%f in ('echo %%wds_rnd_par%%') do (^
      if %%~f LSS 1 (set "wds_rnd_par=") else if 8 LSS %%~d (set "wds_rnd_par=")^
     ))^
    ))^&^
    (if defined wds_rnd_par (set "wds_rnd_par=") else (echo Error [@rand]: Non-digital or out-of-range value in 2nd parameter.^&exit /b 1))^&^
    (for /L %%e in (1,1,%%~d) do for /F "tokens=2 delims=.+" %%f in ('wmic os get LocalDateTime /value') do (^
     set "wds_rnd_aux=%%f"^&^
     (if defined wds_rnd_par (call set "wds_rnd_par=%%wds_rnd_par%%%%wds_rnd_aux:~2,1%%") else (call set "wds_rnd_par=%%wds_rnd_aux:~2,1%%"))^
    ))^&^
    (for /F "tokens=* delims=0" %%e in ('echo %%wds_rnd_par%%') do if "%%b"=="" (set "%%~c=%%e") else (echo "%%~c=%%e"))^&^
    set "wds_rnd_aux="^
   ))^
  ))^&^
  set "wds_rnd_par="^
 ) else (echo Error [@rand]: Absent parameters.^&exit /b 1)) else set wds_rnd_par=
 
::         @echo_params - macro echoes list of parameters.
::                        %~1     == number of parameters to print using echo;
::                        %~2 ... == list of parameters to echo;
::
set @echo_params=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ech_par (^
  for /F "tokens=1,*" %%a in ('echo %%wds_ech_par%%') do (^
   set "wds_ech_par="^&^
   for ^/L ^%%c in (1,1,^%%a) do (^
    cmd /d /q /r "set "wds_ech_par=%%b"^&for /F "tokens=%%c" %%d in ('echo.%%wds_ech_par%%') do (echo %%d)"^
   )^
  )^
 ) else (echo Error [@echo_params]: Absent parameters.^&exit /b 1)) else set wds_ech_par=

::      @enumA & @enumB - macro echoes (prints) result of 'for /F' command one by one as a list of string values.
::                        %~1 == the 1st letter of result (%%a->%%z) which is specified inside 'for /F' command;
::                        %~2 == expected number of tokens inside 'for /F' command.
::             Notes. #1: the result of the 'for /F' command must be compatible with enumeration by 'for-in-do';
::                    #2: macro reports every value inside name `%%a`;
::                    #3: it reports values only if all expected number of output strings is non-empty;
::                    #4: this macro can be used only by usual script, it's not designed for use in macros.
::                Sample. Prints values from 3 to 4, corresponding letters of 'for /F' `d` (`%%d`) & `e` (`%%e`):
::                            for /F "tokens=2,3,4,5" %%c in ('echo 1 2 3 4 5') do (
::                              %@enumA% d 2 %@enumB% echo %%a
::                            )
::
set @enumA=(^
 set "wds_enu_cnt=1"^&^
 (for %%z in (a-"%%~a" b-"%%~b" c-"%%~c" d-"%%~d" e-"%%~e" f-"%%~f" g-"%%~g" h-"%%~h" i-"%%~i" j-"%%~j" k-"%%~k" l-"%%~l" m-"%%~m" n-"%%~n" o-"%%~o" p-"%%~p" q-"%%~q" r-"%%~r" s-"%%~s" t-"%%~t" u-"%%~u" v-"%%~v" w-"%%~w" x-"%%~x" y-"%%~y" z-"%%~z") do (^
  for /F "tokens=1,* delims=-" %%a in ('echo.%%z') do (^
   call set "wds_enu_%%a=%%wds_enu_cnt%%"^&^
   (call set "wds_enu_%%wds_enu_cnt%%=%%~b"^>NUL 2^>^&1 ^|^| (call set "wds_enu_%%wds_enu_cnt%%="))^&^
   call set /a "wds_enu_cnt+=1"^>NUL^
  )^
 ))^&^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_enu_par (^
  (for /F "tokens=1,2" %%a in ('echo.%%wds_enu_par%%') do if defined wds_enu_%%a (^
   for /F %%c in ('echo.%%wds_enu_%%a%%') do (set /a "wds_enu_par=%%b+%%c-1"^>NUL 2^>^&1) ^&^& for /F %%d in ('echo.%%wds_enu_par%%') do (^
    set "wds_enu_par="^&^
    (if defined wds_enu_%%d (^
     (for /L %%e in (%%c,1,%%d) do if defined wds_enu_par (^
      (call set wds_enu_par=%%wds_enu_par%% "%%wds_enu_%%e%%")^
     ) else (call set wds_enu_par="%%wds_enu_%%e%%"))^
    ))^
   )^
  ))^&^
  (for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (call set "wds_enu_%%wds_enu_%%a%%="^&set "wds_enu_%%a="))^&^
  set "wds_enu_cnt="^
 ) else (echo Error [@enum]: Absent parameters.^&exit /b 1)) else set wds_enu_par=
set @enumB=)^&if defined wds_enu_par for /F "tokens=*" %%a in ('echo.%%wds_enu_par%%') do set "wds_enu_par="^&for %%a in (%%a) do 

::           @ipaddress - macro returns local ip address matching prefix mask `###.###.###`.
::                        %~1 == the name of variable to return result (0/1 <=> True/False);
::                        %~2 == prefix string of address without quotes, e.g `192.168.0`;
::                        %~3 == [optional: the name of variable to return address, if not specified -> `%~1`];
::                        %~4 == [optional: any key to echo result instead of assigning, e.g. `(e)`].
::                  Note: @mac_check requires `%~3`, e.g: %@mac_check% @ipaddress,192.168.0 dummy %@istrue% && ...
::
set @ipaddress=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ipa_par for /F %%y in ('echo.wds_ipa_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%ypar%%') do (^
   set "%%ypar="^&(if "%%b"=="" (set "%%ypar=1") else if %%b=="%%~b" (set "%%ypar=1"))^&^
   (if defined %%ypar (echo Error [@ipaddress]: Absent or quoted address search mask in 2nd parameter.^&exit /b 1))^&^
   set "%%a=%%b"^&(for /F %%e in ('echo %%%%a%%') do if not "%%e"=="%%b" (echo Error [@ipaddress]: Incorrect variable name `%%a` in 1st parameter.^&exit /b 1))^&^
   (if not "%%~c"=="" (^
    set "%%c=%%b"^&(for /F %%e in ('echo %%%%c%%') do if not "%%e"=="%%b" (echo Error [@ipaddress]: Incorrect variable name `%%c` in 3rd parameter.^&exit /b 1))^
   ))^&^
   (for /F "tokens=1,* delims=:" %%e in ('ipconfig') do if not "%%~f"=="" for /F "tokens=1,2,3,4 delims=." %%g in ('echo %%~f') do if not "%%~j"=="" (^
    for /F %%k in ('echo %%~g') do for /F %%l in ('echo %%%%a%%') do if "%%~k.%%~h.%%~i"=="%%l" (^
     set "%%a=%%~k.%%~h.%%~i.%%~j"^
    )^
   ))^&^
   (for /F %%e in ('"echo %%%%a%%"') do if "%%e"=="%%b" (^
    if "%%~c"=="" (^
     if "%%~d"=="" (set "%%a=") else (echo "%%a=")^
    ) else (^
     if "%%~d"=="" (set "%%a=1"^&set "%%c=") else (echo "%%a=1"^&echo "%%c=")^
    )^
   ) else (^
    if "%%~c"=="" (^
     if not "%%~d"=="" (echo "%%a=%%e")^
    ) else (^
     if "%%~d"=="" (set "%%a=0"^&set "%%c=%%e") else (echo "%%a=0"^&echo "%%c=%%e")^
    )^
   ))^
  ))^&(if defined %%ypar (echo Error [@ipaddress]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@ipaddress]: Absent parameters.^&exit /b 1)) else set wds_ipa_par=

::           @web_avail - checks the internet connection is available or not.
::                        %~1 == the name of variable to return result (0/1 <=> True/False, @mac_check compatible);
::                        %~2 == [optional: any key to echo result instead of assigning, e.g. `(e)`].
::             Notes. #1: it is compatible with macro format of event type `m`, for instance to wait web connection:
::                        call %%wait.mds%% /t:m /i:@web_avail
::                    #2: in the case of absent connection this macro repeats checks until timeout 20 sec.
::
set @web_avail=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_iav_par for /F %%y in ('echo.wds_iav_') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%ypar%%') do (^
   set "%%a=1"^&(for /F %%c in ('echo %%%%a%%') do if not "%%c"=="1" (echo Error [@web_avail]: Incorrect variable name `%%a` in 1st parameter.^&exit /b 1))^&^
   (if "!PROMPT!"=="%PROMPT%" (^
    (set %%yq="")^&(set "%%ya=1^^^&1")^&(set %%ye="^^^^^^^^^^^^!^^^!^^^!")^&(set %%yr="^^^>")^
   ) else (^
    echo Error [@web_avail]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1^
   ))^&^
   (set %%ypar="set $q%%yb=,Path,TEMP,SystemRoot,UserProfile,$q$a(for /F $qdelims==$q %%h$ca in ('set') do if $q$e%%yb:,%%h$ca,=$e$q==$q$e%%yb$e$q (set $q%%h$ca=$q))$a(for /F $qtokens=* delims=0$q %%h$ca in ('$qecho $etime::0=:$e$q') do for /F $qtokens=1,2,3 delims=:,.$q %%h$cb in ('echo %%h$ca') do (set $q%%yh=%%h$cb$q$aset /a $q%%yb=3600*%%h$cb+60*%%h$cc+%%h$cd$q$rNUL 2$r$a1))$a(for /L %%h$cz in (1,1,75) do ((for /F $qtokens=*$q %%h$ca in ('ping www.google.com -n 1 -w 25') do if not $q%%h$c~a$q==$q$q (for /F $qtokens=2,4,6 delims=,=($q %%h$cb in ('$qecho.%%h$c~a$q') do if not $q%%h$c~b$q==$q$q (for /F $qtokens=1,2,3$q %%h$ce in ('echo.%%h$c~b %%h$c~c %%h$c~d') do (if $q%%h$c~e%%h$c~f%%h$c~g$q==$q110$q (echo 0$aexit /b 0)))))$a(for /F $qtokens=* delims=0$q %%h$ca in ('$qecho $etime::0=:$e$q') do for /F $qtokens=1,2,3 delims=:,.$q %%h$cb in ('echo %%h$ca') do if %%h$cb LSS $e%%yh$e (set /a $q%%ye=3600*(24+%%h$cb)+60*%%h$cc+%%h$cd-20$q$rNUL 2$r$a1) else (set /a $q%%ye=3600*%%h$cb+60*%%h$cc+%%h$cd-20$q$rNUL 2$r$a1))$a(if $e%%yb$e LEQ $e%%ye$e (echo 1$aexit /b 0))))$a(echo 1)")^&^
   (for /F "tokens=1,2,3,4,5,6" %%c in ('"echo %%%%yq:~1%% %%%%ya:~-2,1%% %%%%ye:~1,-1%% ^^^^^ %%%%yr:~-2,1%% %%"') do (^
    set "%%yq="^&set "%%ya="^&set "%%ye="^&set "%%yr="^&^
    (call set %%ypar=%%%%ypar:$q=%%c%%)^&(call set %%ypar=%%%%ypar:$a=%%d%%)^&(call set %%ypar=%%%%ypar:$e=%%e%%)^&^
    (call set %%ypar=%%%%ypar:$r=%%g%%)^&(call set %%ypar=%%%%ypar:h$c=%%)^&(call set %%ypar=%%%%ypar:$c=%%)^
   ))^&^
   (for /F %%c in ('cmd /d /q /e:on /v:on /r %%%%ypar%%') do if "%%~b"=="" (set "%%a=%%c") else (echo "%%a=%%c"))^&^
   set "%%ypar="^
  ))^&(if defined %%ypar (echo Error [@web_avail]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@web_avail]: Absent parameters.^&exit /b 1)) else set wds_iav_par=

::              @web_ip - returns local ip address of internet connection.
::                        %~1 == the name of variable to return current ip address;
::                        %~2 == [optional: any key to echo result instead of assigning, e.g. `(e)`].
::
set @web_ip=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wip_par for /F %%y in ('echo.wds_wip_') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%ypar%%') do (^
   set "%%a=1"^&(for /F %%c in ('echo %%%%a%%') do if not "%%c"=="1" (echo Error [@web_ip]: Incorrect variable name `%%a` in 1st parameter.^&exit /b 1))^&^
   set "%%ypar="^&^
   (for /F "tokens=2 delims=[]" %%c in ('"pathping www.google.com -q 1 -w 10 -h 1"') do if defined %%ypar (^
    for /F %%d in ('echo %%%%a%%') do if "%%d"=="1" (set "%%a=%%c"^&(if not "%%~b"=="" (echo "%%a=%%c")))^
   ) else (set "%%ypar=%%c"))^&^
   set "%%ypar="^
  ))^&(if defined %%ypar (echo Error [@web_ip]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@web_ip]: Absent parameters.^&exit /b 1)) else set wds_wip_par=

::            @regvalue - gets registry value and encodes it from Windows to console codepage.
::                        %~1 == name of variable to assign the registry value encoded to current codepage;
::                        %~2 == the key name of value (variable name or quoted string);
::                        %~3 == the name of value to retreive (variable name with string or quoted string);
::                        %~4 == [optional: any value to echo result instead of assigning it `%~1`].
::             Notes. #1: explicit quoted strings in `%~2` & `%~3` must have `/CHR{20}` instead of space symbols;
::                    #2: the empty response of query reports error but doesn't exit with error code.
::
set @regvalue=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_grv_aux for /F %%y in ('echo wds_grv_') do (^
  for /F "tokens=1,2,3,4" %%a in ('echo.%%%%yaux%%') do (^
   (if "%%~c"=="" (echo Error [@regvalue]: Absent parameter #3 with registry value name.^&exit /b 1))^&^
   (if not defined TEMP (echo Error [@regvalue]: Undefined environment varaiable `TEMP`.^&exit /b 1))^&^
   set "%%yaux="^&(if defined %%b for /F "tokens=*" %%e in ('echo.%%%%~b%%') do (set %%yaux="%%~e") else if "%%~b"==%%b (set "%%yaux=%%b"))^&^
   (if defined %%yaux for /F "tokens=*" %%e in ('"echo.%%%%yaux:/CHR{20}= %%"') do (^
    set "%%yaux="^&(if defined %%c for /F "tokens=*" %%f in ('echo.%%%%~c%%') do (set %%yaux="%%~f") else if "%%~b"==%%b (set "%%yaux=%%c"))^&^
    (if defined %%yaux for /F "tokens=*" %%f in ('"echo.%%%%yaux:/CHR{20}= %%"') do (^
     set "%%yfnm="^&^
     (for /F "tokens=2 delims=:" %%g in ('chcp') do for /F %%h in ('echo.%%~g') do (^
      (for /F "skip=1 tokens=*" %%i in ('wmic os get codeset') do for /F %%j in ('echo.%%~i') do (^
       (for /L %%k in (1,1,100) do if not defined %%yfnm (^
        set "%%yaux=0000%%k"^&^
        (for /F "tokens=*" %%l in ('echo."%%TEMP%%\wait.mds.auxiliary.file.id%%%%yaux:~-4%%.bat"') do if not exist %%l (^
         (set %%yaux="^^^|")^&(set %%yfnm="^^^>")^&^
         (for /F "tokens=1,3,4,5,6,7" %%m in ('echo." ." "%%%%yfnm:~-2,1%%" "%%" "(" ")" "%%%%yaux:~-3,2%%"') do (^
          (set %%yaux="1^^^&1")^&^
          (for /F "tokens=1,2,3,4" %%s in ('echo.for NUL /F "%%%%yaux:~-3,1%%"') do (^
           (echo @echo off)^&(echo @chcp %%~j%%~nNUL)^&^
           (echo %%~p%%s /F %%mtokens=2,*%%m %%~o%%~oa in %%~p'reg query %%e %%~r find /i %%f'%%~q do set wds_grv_res=%%m%%~o%%~o~b%%m%%~q^%%~nNUL 2%%~n%%~v1)^&^
           (echo @chcp %%~h%%~nNUL)^&^
           (echo echo %%~a=%%~owds_grv_res%%~o)^
          ))^
         ))^&^
         set "%%yfnm=%%l"^
        )^>%%l)^
       ))^
      ))^
     ))^&^
     (if defined %%yfnm (^
      (for /F "tokens=*" %%k in ('cmd /d /q /r call %%%%yfnm%%') do (set %%k)^>NUL 2^>^&1 ^|^| (^
       echo Error [@regvalue]: registry query error or item "%%~e\%%~f" is absent^
      ))^&^
      (call del /F /A /Q %%%%yfnm%%^>NUL 2^>^&1)^&set "%%yfnm="^
     ))^&^
     (if not "%%~d"=="" (set ^| find "%%~a=" ^| findstr /BC:"%%~a") 2^>^&1)^
    ))^
   ))^&^
   (if defined %%yaux (set "%%yaux=") else (^
    echo Error [@regvalue]: Unexpected values of the parameter #2 or #3.^&exit /b 1^
   ))^
  )^&(if defined %%yaux (echo Error [@regvalue]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@regvalue]: Absent parameters.^&exit /b 1)) else set wds_grv_aux=

::         @shellfolder - gets hardcoded system path to one of special folders.
::                        %~1 == name of variable identifies special folder, can have next values:
::                                 [in]  - the name of variable identifies special folder, allowed next names:
::                                     01. `AllUsersDesktop`;  02. `AllUsersStartMenu`; 03. `AllUsersPrograms`;
::                                     04. `AllUsersStartup`;  05. `Desktop`;           06. `Favorites`;
::                                     07. `Fonts`;            08. `MyDocuments`;       09. `NetHood`;
::                                     10. `PrintHood`;        11. `Programs`;          12. `Recent`;
::                                     13. `SendTo`;           14. `StartMenu`;         15. `Startup`;
::                                     16. `Templates`;        17. `AppData`;
::                                 [out] - the path string value, corresponding received name.
::
set @shellfolder=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ssf_aux for /F %%y in ('echo.%%wds_ssf_aux%%') do (^
  set "wds_ssf_aux=%%y"^&^
  (for %%a in ("AllUsersDesktop$1$Common Desktop","AllUsersStartMenu$1$Common Start Menu","AllUsersPrograms$1$Common Programs","AllUsersStartup$1$Common Startup","Desktop$2$Desktop","Favorites$2$Favorites","Fonts$2$Fonts","MyDocuments$2$Personal","NetHood$2$NetHood","PrintHood$2$PrintHood","Programs$2$Programs","Recent$2$Recent","SendTo$2$SendTo","StartMenu$2$Start Menu","Startup$2$Startup","Templates$2$Templates","AppData$2$AppData") do if defined wds_ssf_aux (^
   for /F "tokens=1,2,3 delims=$" %%b in ('echo.%%~a') do (^
    call set "wds_ssf_aux=%%wds_ssf_aux:%%b=%%"^&^
    (if not defined wds_ssf_aux (^
     (if %%c EQU 1 (^
      (set wds_ssf_aux="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")^
     ) else (^
      (set wds_ssf_aux="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")^
     ))^&^
     (set wds_ssf_nam="%%d")^&^
     (for /F "tokens=*" %%e in ('cmd /d /q /r "%%@regvalue%% %%b wds_ssf_aux wds_ssf_nam 1"') do (set %%e))^&^
     set "wds_ssf_aux="^&set "wds_ssf_nam="^
    ))^
   )^
  ))^&^
  (if defined wds_ssf_aux (echo Error [@shellfolder]: Not reserved special folder name `%%y`.^&exit /b 1))^
 ) else (echo Error [@shellfolder]: Absent parameter.^&exit /b 1)) else set wds_ssf_aux=

:::              @binman - auxiliary internal macro to do cleanups of known side effects, has not parameters.
:::
set @binman=^
 (if exist "TempWmicBatchFile.bat" (call del /F /A /Q "TempWmicBatchFile.bat")^>NUL 2^>^&1)^&^
 (if exist "*USERPROFILE*" (^
  set "wds_bmn_f=USERPROFILE"^&(call rd /S /Q ".\%%%%wds_bmn_f%%%%")^>NUL 2^>^&1^&set "wds_bmn_f="^
 ))
 
::             @oemtocp - converts string value from OEM codeset of Windows to the active console codepage.
::                        %~1 == name of variable to assign converted string;
::                        %~2 == the value to encode (variable name or quoted string);
::                        %~4 == [optional: any value to echo result instead of assigning it to `%~1`].
::             Notes. #1: explicit quoted string in `%~2` must have `/CHR{20}` instead of space symbols;
::                    #2: the source must be encoded in OEM codepage or macro can fail.
::
set @oemtocp=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_oec_aux for /F %%y in ('echo wds_oec_') do (^
  for /F "tokens=1,2,3" %%a in ('echo.%%%%yaux%%') do (^
   (if "%%~a"=="" (echo Error [@oemtocp]: Absent parameter #1 with output variable name.^&exit /b 1))^&^
   (if not defined TEMP (echo Error [@oemtocp]: Undefined environment varaiable `TEMP`.^&exit /b 1))^&^
   set "%%yaux="^&(if defined %%b for /F "tokens=*" %%e in ('"echo.%%%%~b%%"') do (set "%%yaux=%%e") else if "%%~b"==%%b (set "%%yaux=%%b"))^&^
   (if defined %%yaux for /F "tokens=*" %%e in ('"echo.%%%%yaux:/CHR{20}= %%"') do (^
    (if not "%%~c"=="" for /F "tokens=*" %%g in ('echo."%%TEMP%%\"') do (cd /d %%~dg%%~pg%%~ng%%~xg)^>NUL 2^>^&1)^&^
    set "%%yfnm="^&^
    (for /F "tokens=2 delims=:" %%g in ('chcp') do for /F %%h in ('echo.%%~g') do (^
     (for /F "skip=1 tokens=*" %%i in ('wmic os get codeset') do for /F %%j in ('echo.%%~i') do (^
      (for /L %%k in (1,1,100) do if not defined %%yfnm (^
       set "%%yaux=0000%%k"^&^
       (for /F "tokens=*" %%l in ('echo."%%TEMP%%\wait.mds.auxiliary.file.id%%%%yaux:~-4%%.bat"') do if not exist %%l (^
        (set %%yfnm="^^^>")^&^
        (for /F "tokens=1,3,4" %%m in ('echo." ." "%%%%yfnm:~-2,1%%" "%%"') do (^
         (echo @echo off)^&^
         (echo @chcp %%~j%%~nNUL)^&^
         (echo set %%mwds_oec_res=%%~e%%m)^&^
         (echo @chcp %%~h%%~nNUL)^&^
         (echo echo %%m%%~a=%%~owds_oec_res%%~o%%m)^
        ))^&^
        set "%%yfnm=%%l"^
       )^>%%l)^
      ))^
     ))^
    ))^&^
    (if defined %%yfnm (^
     (for /F "tokens=*" %%k in ('cmd /d /q /r call %%%%yfnm%%') do (set %%k)^>NUL 2^>^&1 ^|^| (echo Error [@oemtocp]: %%k))^&^
     (call del /F /A /Q %%%%yfnm%%^>NUL 2^>^&1)^&set "%%yfnm="^
    ))^&^
    (if not "%%~c"=="" (set ^| find "%%~a=" ^| findstr /BC:"%%~a") 2^>^&1)^
   ))^&^
   (if defined %%yaux (set "%%yaux=") else (^
    echo Error [@oemtocp]: Unexpected values of the parameter #2 or #3.^&exit /b 1^
   ))^&^
   !@binman!^
  )^&(if defined %%yaux (echo Error [@oemtocp]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@oemtocp]: Absent parameters.^&exit /b 1)) else set wds_oec_aux=
 
::             @cptooem - converts string value from active console codepage codeset to OEM codeset of Windows.
::                        %~1 == name of variable to assign converted string;
::                        %~2 == the value to encode (variable name or quoted string);
::                        %~4 == [optional: any value to echo result instead of assigning it to `%~1`].
::             Notes. #1: explicit quoted string in `%~2` must have `/CHR{20}` instead of space symbols;
::                    #2: the source must be encoded in active console codepage or macro can fail.
::
set @cptooem=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cpo_aux for /F %%y in ('echo wds_cpo_') do (^
  for /F "tokens=1,2,3" %%a in ('echo.%%%%yaux%%') do (^
   (if "%%~a"=="" (echo Error [@cptooem]: Absent parameter #1 with output variable name.^&exit /b 1))^&^
   (if not defined TEMP (echo Error [@cptooem]: Undefined environment varaiable `TEMP`.^&exit /b 1))^&^
   set "%%yaux="^&(if defined %%b for /F "tokens=*" %%e in ('"echo.%%%%~b%%"') do (set "%%yaux=%%e") else if "%%~b"==%%b (set "%%yaux=%%b"))^&^
   (if defined %%yaux for /F "tokens=*" %%e in ('"echo.%%%%yaux:/CHR{20}= %%"') do (^
    (if not "%%~c"=="" for /F "tokens=*" %%g in ('echo."%%TEMP%%\"') do (cd /d %%~dg%%~pg%%~ng%%~xg)^>NUL 2^>^&1)^&^
    set "%%yfnm="^&^
    (for /F "tokens=2 delims=:" %%g in ('chcp') do for /F %%h in ('echo.%%~g') do (^
     (for /F "skip=1 tokens=*" %%i in ('wmic os get codeset') do for /F %%j in ('echo.%%~i') do (^
      @chcp %%~h^>NUL^&^
      (for /L %%k in (1,1,100) do if not defined %%yfnm (^
       set "%%yaux=0000%%k"^&^
       (for /F "tokens=*" %%l in ('echo."%%TEMP%%\wait.mds.auxiliary.file.id%%%%yaux:~-4%%.bat"') do if not exist %%l (^
        (set %%yfnm="^^^>")^&^
        (for /F "tokens=1,3,4" %%m in ('echo." ." "%%%%yfnm:~-2,1%%" "%%"') do (^
         (echo @echo off)^&^
         (echo @chcp %%~h%%~nNUL)^&^
         (echo set %%mwds_cpo_res=%%~e%%m)^&^
         (echo @chcp %%~j%%~nNUL)^&^
         (echo echo %%m%%~a=%%~owds_cpo_res%%~o%%m)^
        ))^&^
        set "%%yfnm=%%l"^
       )^>%%l)^
      ))^&^
      (if defined %%yfnm (^
       (for /F "tokens=*" %%k in ('cmd /d /q /r call %%%%yfnm%%') do (set %%k) ^|^| (echo Error [@cptooem]: %%k))^&^
       (call del /F /A /Q %%%%yfnm%%^>NUL 2^>^&1)^&set "%%yfnm="^
      ))^&^
      @chcp %%~h^>NUL^
     ))^
    ))^&^
    (if not "%%~c"=="" (set ^| find "%%~a=" ^| findstr /BC:"%%~a") 2^>^&1)^
   ))^&^
   (if defined %%yaux (set "%%yaux=") else (^
    echo Error [@cptooem]: Unexpected values of the parameter #2 or #3.^&exit /b 1^
   ))^&^
   !@binman!^
  )^&(if defined %%yaux (echo Error [@cptooem]: Absent parameters, verify spaces.^&exit /b 1))^
 ) else (echo Error [@cptooem]: Absent parameters.^&exit /b 1)) else set wds_cpo_aux=

::--------------------------------------------------------
::-- Main group of macros, <-> @str_decode:
::--------------------------------------------------------

::        @syms_replace - replaces all instances of symbols in string by another symbols (strings).
::                        %~1 == the name of external variable containing string;
::                        %~2 == key parameter `1` to echo result instead of assigning, `0` is for assigning;
::                        %~3 == the number of different symbols with corresponding substitute in the next parameter(s);
::                     %~4... == the list of parameters containing quoted pairs "`old symbol`^=`new symbol (string)`" or
::                               variable name of the calling script containing values above (more reliable & commended).
::
set @syms_replace=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_rss_par (^
  (for /F "tokens=1,2,3,*" %%a in ('echo %%wds_rss_par%%') do (^
   set "wds_rss_nam=%%~a"^&(if defined %%~a (set wds_rss_src="^!%%~a^!") else (set "wds_rss_src="))^&^
   (set /a "wds_rss_eco=%%~b"^>NUL 2^>^&1)^>NUL ^&^& (echo.^>NUL) ^|^| (echo Error [@syms_replace]: Unexpected non-digital value of parameter #2.^&exit /b 1)^&^
   (set /a "wds_rss_cnt=%%~c"^>NUL 2^>^&1)^>NUL ^&^& (echo.^>NUL) ^|^| (echo Error [@syms_replace]: Unexpected non-digital value of parameter #3.^&exit /b 1)^&^
   (if ^^^!wds_rss_eco^^^! NEQ %%~b (echo Error [@syms_replace]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if defined %%~d (set "wds_rss_par=^!%%~d^!") else (set "wds_rss_par=%%d"))^
  ))^&^
  (if defined wds_rss_nam (^
   (if ^^^!wds_rss_eco^^^! NEQ 1 (set "^!wds_rss_nam^!=") else (echo "^!wds_rss_nam^!="))^&^
   (if defined wds_rss_src if 0 LSS ^^^!wds_rss_cnt^^^! if defined wds_rss_par (^
    (set wds_rss_quo="")^&(set wds_rss_quo=^^^!wds_rss_quo:~1^^^!)^&(set "wds_rss_amp=1^^^&1")^&(call set "wds_rss_amp=%%wds_rss_amp:~-2,1%%")^&^
    (for /L %%i in (1,1,^^^!wds_rss_cnt^^^!) do if defined wds_rss_par (^
     (for /F "tokens=1,*" %%j in ('"echo ^!wds_rss_par^!"') do if not "%%j"=="" (^
      set "wds_rss_par=%%k"^&set "wds_rss_ncs=%%~j"^&set "wds_rss_ocs=^!wds_rss_ncs:~0,1^!"^&(set wds_rss_ncs="^!wds_rss_ncs:~2^!")^&^
      (if defined wds_rss_ocs (^
       (call set "wds_rss_sel=^^^^^%%wds_rss_ocs%%")^&^
       (set wds_rss_sel="(for /L %%^^^^n in (1 1 2048000) do (if defined wds_rss_loc (for /F $wds_rss_quo$usebackq tokens=1,* delims=^!wds_rss_sel^!$wds_rss_quo$ %%^^^^x in (`call echo $wds_rss_quo$^%%wds_rss_loc^%%$wds_rss_quo$`) do (set wds_rss_loc=%%^^^^x$wds_rss_amp$(call echo wds_rss=beg=%%wds_rss_loc:~1%%)$wds_rss_amp$(set wds_rss_loc=%%^^^^y)$wds_rss_amp$(if defined wds_rss_loc (call set wds_rss_loc=^%%wds_rss_loc:~0,-1^%%))$wds_rss_amp$(if defined wds_rss_loc (call echo wds_rss=end=^%%wds_rss_loc^%%) else (call echo wds_rss=end=)))) else if %%^^^^n LEQ 2 (call set wds_rss_loc=^%%wds_rss_src:~1,-1^%%) else (exit /b 0)))")^&^
       (call set wds_rss_sel=%%wds_rss_sel:$wds_rss_quo$=^^^!wds_rss_quo^^^!%%)^&(set wds_rss_res="")^&^
       (call set wds_rss_sel=%%wds_rss_sel:$wds_rss_amp$=^^^!wds_rss_amp^^^!%%)^&(set /a wds_rss_lgt=-1)^>NUL^&^
       (for /F "usebackq tokens=1,2,* delims==" %%a in (`cmd /d /q /r ^^^!wds_rss_sel^^^!`) do if "%%a"=="wds_rss" (^
        (if "%%b"=="beg" (^
         (set "wds_rss_nbe=%%c")^&^
         (if defined wds_rss_nbe (^
          (if ^^^!wds_rss_src^^^!=="^!wds_rss_nbe:~0,-1^!" (set "wds_rss_dlm="^&set "wds_rss_nbe=^!wds_rss_nbe:~0,-1^!") else (^
           set "wds_rss_aux=^!wds_rss_nbe^!"^&set "wds_rss_len=1"^&^
           (for %%d in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
            set "wds_rss_chk=^!wds_rss_aux:~%%d,1^!"^&^
            (if defined wds_rss_chk (set "wds_rss_aux=^!wds_rss_aux:~%%d^!"^&set /a "wds_rss_len+=%%d"^>NUL))^
           ))^&^
           ((set /a "wds_rss_lgt-=^!wds_rss_len^!")^>NUL)^&((set /a "wds_rss_len+=1")^>NUL)^&^
           (call set "wds_rss_dlm=%%wds_rss_src:~^!wds_rss_len^!,-1%%")^
          ))^
         ) else (set "wds_rss_dlm=^!wds_rss_src:~1,-1^!"))^
        ) else (^
         (if defined wds_rss_nbe (set wds_rss_res="^!wds_rss_res:~1,-1^!^!wds_rss_nbe^!"))^&^
         (set wds_rss_src="%%c"^>NUL 2^>^&1)^&^
         set "wds_rss_nen=%%c"^&^
         (if defined wds_rss_dlm (^
          (if defined wds_rss_nen (^
           set "wds_rss_aux=^!wds_rss_nen^!"^&set "wds_rss_len=1"^&^
           (for %%d in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
            set "wds_rss_chk=^!wds_rss_aux:~%%d,1^!"^&^
            (if defined wds_rss_chk (set "wds_rss_aux=^!wds_rss_aux:~%%d^!"^&set /a "wds_rss_len+=%%d"^>NUL))^
           ))^&^
           call set "wds_rss_dlm=%%wds_rss_dlm:~0,-^!wds_rss_len^!%%"^
          ) else (set "wds_rss_len=0"))^&^
          (if defined wds_rss_dlm (^
           (if ^^^!wds_rss_lgt^^^! LSS 0 (^
            set "wds_rss_aux=^!wds_rss_dlm^!"^&set "wds_rss_lgt=1"^&^
            (for %%d in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
             set "wds_rss_chk=^!wds_rss_aux:~%%d,1^!"^&^
             (if defined wds_rss_chk (set "wds_rss_aux=^!wds_rss_aux:~%%d^!"^&set /a "wds_rss_lgt+=%%d"^>NUL))^
            ))^
           ) else (set /a "wds_rss_lgt-=^!wds_rss_len^!"^>NUL))^&^
           for /L %%a in (1,1,^^^!wds_rss_lgt^^^!) do (set wds_rss_res="^!wds_rss_res:~1,-1^!^!wds_rss_ncs:~1,-1^!")^
          ))^&^
          set "wds_rss_lgt=^!wds_rss_len^!"^
         ))^
        ))^
       ))^&^
       (set wds_rss_nbe=)^&(set wds_rss_nen=)^&(set "wds_rss_src=^!wds_rss_res^!"^>NUL 2^>^&1)^
      ))^
     ))^
    ))^&^
    set "wds_rss_src=^!wds_rss_src:~1,-1^!"^&^
    (if ^^^!wds_rss_eco^^^! NEQ 1 (^
     (if defined wds_rss_src (set "^!wds_rss_nam^!=^!wds_rss_src^!") else (set "^!wds_rss_src^!="))^&^
     (for %%a in (sel,quo,amp,dlm,lgt,len,ncs,ocs,res,src,chk,aux) do (set "wds_rss_%%a="))^
    ) else (^
     (if defined wds_rss_src (echo "^!wds_rss_nam^!=^!wds_rss_src^!") else (echo "^!wds_rss_src^!="))^
    ))^
   ))^
  ))^&^
  set "wds_rss_cnt="^&set "wds_rss_eco="^&set "wds_rss_nam="^&set "wds_rss_par="^
 ) else (echo Error [@syms_replace]: Absent parameters.^&exit /b 1)) else set wds_rss_par=
 
::         @sym_replace - replaces all instances of symbol in string by another symbol (string).
::                        %~1 == the name of external variable containing string;
::                        %~2 == the symbol to search and replace (symbol value or its variable);
::                        %~3 == [optional: the symbol or string to insert instead of found `%~2` symbol (value or variable)];
::                        %~4 == [optional: key parameter `1` to echo result instead of assigning, `0` is default].
::             Notes. #1: it always treats parameters `%~2` & `%~3` as explicit values if they are in quotation marks;
::                    #2: if source string contains `=` symbols, it calls `@syms_replace` to do task & to avoid specific error.
::          Dependencies: @syms_replace.
::
set @sym_replace=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_srm_par (^
  (for /F "tokens=1,2,3,4" %%a in ('"echo ^!wds_srm_par^!"') do (^
   set "wds_srm_nam=%%~a"^&(if defined %%~a (set wds_srm_src="^!%%a^!") else (set "wds_srm_src="))^&^
   (if "%%~b"==%%b (set "wds_srm_ocs=%%~b") else if defined %%~b (set "wds_srm_ocs=^!%%~b^!") else (set "wds_srm_ocs=%%b"))^&^
   (if "%%~c"==%%c (set "wds_srm_ncs=%%~c") else if defined %%~c (set "wds_srm_ncs=^!%%~c^!") else (set "wds_srm_ncs=%%c"))^&^
   set "wds_srm_eco=0"^&^
   (if ^^^!wds_srm_eco^^^! NEQ 0 (echo Error [@sym_replace]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set /a "wds_srm_eco=%%~d"^>NUL 2^>^&1)^>NUL^
  ))^&^
  (if defined wds_srm_nam (^
   (if ^^^!wds_srm_eco^^^! NEQ 1 (set "^!wds_srm_nam^!=") else (echo "^!wds_srm_nam^!="))^&^
   (if defined wds_srm_src if defined wds_srm_ocs (^
    (for /F "delims==" %%a in ('"echo %%wds_srm_src%%"') do if not "%%a"=="^!wds_srm_src^!" (^
     (set wds_srm_aux="^!wds_srm_ocs^!=^!wds_srm_ncs^!")^&^
     ((for /F "tokens=*" %%b in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_srm_src 1 1 wds_srm_aux"') do (set %%b))^>NUL 2^>^&1)^&^
     set "wds_srm_res=^!wds_srm_src^!"^&set "wds_srm_ocs="^
    ))^&^
    (if defined wds_srm_ocs (^
     (call set "wds_srm_sel=^^^^^%%wds_srm_ocs%%")^&^
     (set wds_srm_sel="(for /L %%^^^^n in (1 1 2048000) do (if defined wds_srm_loc (for /F $wds_srm_quo$usebackq tokens=1,* delims=^!wds_srm_sel^!$wds_srm_quo$ %%^^^^x in (`call echo $wds_srm_quo$^%%wds_srm_loc^%%$wds_srm_quo$`) do (set wds_srm_loc=%%^^^^x$wds_srm_amp$(call echo wds_srm=beg=%%wds_srm_loc:~1%%)$wds_srm_amp$(set wds_srm_loc=%%^^^^y)$wds_srm_amp$(if defined wds_srm_loc (call set wds_srm_loc=^%%wds_srm_loc:~0,-1^%%))$wds_srm_amp$(if defined wds_srm_loc (call echo wds_srm=end=^%%wds_srm_loc^%%) else (call echo wds_srm=end=)))) else if %%^^^^n LEQ 2 (call set wds_srm_loc=^%%wds_srm_src:~1,-1^%%) else (exit /b 0)))")^&^
     (set wds_srm_quo="")^&(set wds_srm_quo=^^^!wds_srm_quo:~1^^^!)^&(set "wds_srm_amp=1^^^&1")^&(call set "wds_srm_amp=%%wds_srm_amp:~-2,1%%")^&^
     (call set wds_srm_sel=%%wds_srm_sel:$wds_srm_quo$=^^^!wds_srm_quo^^^!%%)^&(set wds_srm_res="")^&^
     (call set wds_srm_sel=%%wds_srm_sel:$wds_srm_amp$=^^^!wds_srm_amp^^^!%%)^&(set wds_srm_aux="")^&^
     (for /F "usebackq tokens=1,2,* delims==" %%a in (`cmd /d /q /r ^^^!wds_srm_sel^^^!`) do if "%%a"=="wds_srm" (^
      (if "%%b"=="beg" (^
       call set "wds_srm_nbe=%%c"^&^
       (if defined wds_srm_nbe (call set "wds_srm_dlm=%%wds_srm_src:^!wds_srm_nbe^!=%%") else (set "wds_srm_dlm=^!wds_srm_src^!"))^
      ) else (^
       call set "wds_srm_nen=%%c"^&^
       (if defined wds_srm_nen (^
        set "wds_srm_aux=^!wds_srm_dlm^!"^&call set "wds_srm_dlm=%%wds_srm_dlm:^!wds_srm_nen^!=%%"^&^
        (if ^^^!wds_srm_aux^^^!==^^^!wds_srm_dlm^^^! (^
         call set "wds_srm_dlm=%%wds_srm_src:^!wds_srm_nen^!=%%"^&^
         (if defined wds_srm_nbe (call set "wds_srm_dlm=%%wds_srm_dlm:^!wds_srm_nbe^!=%%"))^
        ))^
       ))^&^
       set "wds_srm_dlm=^!wds_srm_dlm:~1,-1^!"^&^
       (if defined wds_srm_nbe if defined wds_srm_nen (^
        (set wds_srm_res="^!wds_srm_res:~1,-1^!^!wds_srm_nbe^!")^
       ) else (^
        call set "wds_srm_aux=%%wds_srm_src:^!wds_srm_nbe^!=%%"^&^
        if ^^^!wds_srm_aux^^^!=="^!wds_srm_dlm^!" (set wds_srm_res="^!wds_srm_res:~1,-1^!^!wds_srm_nbe^!") else (set wds_srm_aux="")^
       ))^&^
       (if defined wds_srm_dlm (^
        set "wds_srm_tmp=^!wds_srm_dlm^!"^&set "wds_srm_dml=1"^&^
        (for %%d in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
         set "wds_srm_chk=^!wds_srm_tmp:~%%d,1^!"^&^
         (if defined wds_srm_chk (set "wds_srm_tmp=^!wds_srm_tmp:~%%d^!"^&set /a "wds_srm_dml+=%%d"^>NUL))^
        ))^&^
        for /L %%d in (1,1,^^^!wds_srm_dml^^^!) do (set wds_srm_res="^!wds_srm_res:~1,-1^!^!wds_srm_ncs^!")^
       ))^&^
       (if defined wds_srm_nen (^
        (set wds_srm_src="^!wds_srm_nen^!")^
       ) else if defined wds_srm_nbe if ^^^!wds_srm_aux^^^!=="" (^
        (set wds_srm_res="^!wds_srm_res:~1,-1^!^!wds_srm_src:~1,-1^!")^
       ))^
      ))^
     ))^
    ))^&^
    set "wds_srm_res=^!wds_srm_res:~1,-1^!"^&^
    (if ^^^!wds_srm_eco^^^! NEQ 1 (^
     (if defined wds_srm_res (set "^!wds_srm_nam^!=^!wds_srm_res^!") else (set "^!wds_srm_nam^!="))^&^
     (for %%a in (sel,quo,amp,aux,dlm,dml,nbe,res,src,chk,tmp) do (set "wds_srm_%%a="))^
    ) else (^
     (if defined wds_srm_res (echo "^!wds_srm_nam^!=^!wds_srm_res^!") else (echo "^!wds_srm_nam^!="))^
    ))^
   ))^
  ))^&^
  set "wds_srm_eco="^&set "wds_srm_nam="^&set "wds_srm_ncs="^&set "wds_srm_ocs="^&set "wds_srm_par="^
 ) else (echo Error [@sym_replace]: Absent parameters.^&exit /b 1)) else set wds_srm_par=
 
::         @syms_cutstr - macro gets non-empty substrings delimited by symbol(s), the default symbol is quotation mark (`"`).
::                        %~1 == the variable name of the calling script with assigned source string;
::                      Two parameters to set delimiter symbol (variable name with string value or quoted string value):
::                      1:%~2 == the 1st delimiter symbol;
::                      2:%~3 == the 2nd right delimiter to extract 1st substring of every substring, empty by default;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      3:%~4 == start number of substring to extract (`<0` to run from end & to reverse order), `1` is default;
::                      4:%~5 == total number of substrings to extract;
::                      5:%~6 == variable name to assign the total number of found substrings in the string;
::                      6:%~7 == variable name to assign the returned number of substrings (with given parameter restrictions);
::                      7:%~8 == variable name to assign string with delimiter symbol(s) replaced by `9:%~10`;
::                      8:%~9 == variable name to assign found non-empty substrings in CSV quoted format;
::                      9:%~10== delimiter substring for `7:%~8`, empty by default (variable name or quoted delimiter string);
::                      A:%~11== key value specifies reporting of result:
::                               `0` - set values to parameters `5:%~6`, `6:%~7`, `7:%~8` & `8:%~9`;
::                               `1` - echo values for assigning them into `5:%~6`, `6:%~7`, `7:%~8` & `8:%~9` by the caller;
::                               `2` - default key value with next behavior:
::                                     - echo values for assigning them into `5:%~6`, `6:%~7` & `7:%~8` if they specified;
::                                     - ignore parameter `8:%~9`, echo found substrings one by one as is.
::             Notes. #1: according `for-in-do` each symbol inside `1:%~2` is delimiter, eg. `*?~=` gives set of `*` `?` `~` `=`;
::                    #2: space symbol as delimiter can be sent as value of external variable or as code `/CHR{20}`;
::                    #3: in the case reversive extraction of substrings from the end (`3:%~4` < 0):
::                               - the output to result string `8:%~9` has reversed order;
::                               - the output to result string `7:%~8` has direct order;
::                               - macro searches delimiters `1:%~2` & `2:%~3` in direct order;
::                    #4: if `A:%~11 == 2` and some substrings has only space symbols then they are reported as quoted strings;
::                    #5: to extract substrings between substring delimiters use `@substr_get` or `@substr_extract` macros.
::            Precaution: if the source string has control symbols or has several quoted substrings then the result can miss
::                        some symbols or can be altered.
::
set @syms_cutstr=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_scs_aux for /F %%p in ('echo wds_scs_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11" %%a in ('echo %%%%paux%%') do (^
   (if defined %%~a (call set "%%psrc=%%%%~a%%") else (set "%%psrc="))^&^
   (if defined %%psrc (^
    (set %%pdlv="")^&(call set %%pdlv=%%%%pdlv:~1%%)^&(set "%%pquo=^!%%pdlv^!")^&^
    (for %%l in ("sub=","ben=1","ton=2147483647","ben=1","tcv=0","fnv=0","rsv=","fsv=","den=","eco=2","non=0","sub=","drv=","dlm=","cmd=cmd /d /q /v:on /e:on /r ","amp=129") do (set "%%p%%~l"))^&^
    (if ^^^!%%pben^^^! NEQ 1 (echo Error [@syms_cutstr]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (for %%l in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k) do if not "%%l"=="" (^
     set "%%paux=%%l"^&set "%%ptmp=^!%%paux:~2^!"^&^
     (if defined %%ptmp (^
      (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
           (if ^^^!%%paux^^^! EQU 3 (set "%%psub=ben")^
       else if ^^^!%%paux^^^! EQU 4 (set "%%psub=ton")^
       else if ^^^!%%paux^^^! EQU 5 (set "%%ptcn=^!%%ptmp^!"^&set /a "%%pnon+=1"^>NUL)^
       else if ^^^!%%paux^^^! EQU 6 (set "%%pfnn=^!%%ptmp^!"^&set /a "%%pnon+=1"^>NUL)^
       else if ^^^!%%paux^^^! EQU 7 (set "%%prsn=^!%%ptmp^!"^&set /a "%%pnon+=1"^>NUL)^
       else if ^^^!%%paux^^^! EQU 8 (set "%%pfsn=^!%%ptmp^!"^&set /a "%%pnon+=1"^>NUL)^
       else if ^^^!%%paux^^^! EQU 10 (^
        (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1)^>NUL ^&^& (^
         if 0 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 2 (set "%%peco=^!%%ptmp^!")^
        )^
       ) else (^
        call set "%%paux=%%%%pamp:^!%%paux^!=%%"^&^
        (if not "^!%%paux^!"=="^!%%pamp^!" (^
         (for /F "tokens=*" %%m in ('"echo ^!%%ptmp^!"') do if "%%~m"==%%m (set "%%ptmp=%%~m") else (call set "%%ptmp=%%%%~m%%"))^&^
         (if defined %%ptmp (^
          set "%%ptmp=^!%%ptmp:/CHR{20}= ^!"^&^
          (if ^^^!%%paux^^^! EQU 29 (set "%%pdlv=^!%%ptmp^!") else if ^^^!%%paux^^^! EQU 19 (set "%%pdrv=^!%%ptmp^!") else (set "%%pden=^!%%ptmp^!"))^
         ))^
        ))^
       ))^&^
       (if defined %%psub (^
        (for /F "tokens=* delims=+,-,0" %%m in ('echo.%%%%ptmp%%') do (^
         (set /a "%%paux=%%~m"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%paux^!"=="%%~m" (^
          if "^!%%ptmp:~0,1^!"=="-" (if "^!%%psub^!"=="ben" (set "%%p^!%%psub^!=-%%~m")) else (set "%%p^!%%psub^!=%%~m")^
         ))^
        ))^&set "%%psub="^
       ))^
      )^
     ))^
    ))^
   ))^
  ))^&^
  (if ^^^!%%peco^^^! NEQ 2 if ^^^!%%pnon^^^! EQU 0 (echo Error [@syms_cutstr]: Absent return result parameters.^&exit /b 1))^&^
  (if defined %%psrc (^
   (set "%%psep=(for /L %%^^a in (0 1 128) do if $q$e#dlm:~%%^^a,1$e$q==$q$q (exit /b 0) else (echo $e#dlm:~%%^^a,1$e))")^&^
   (set "%%palp=(for /F tokens$c=$c1$c,$c2$c,$c3$c,$c4$c,$c5$c,$c6$c,$c7$c,$c8$c,$c9$c,$c10$c,$c11$c,$c12$c,$c13$c,$c14$c,$c15$c,$c16$c,$c17$c,$c18$c,$c19$c,$c20$c,$c21$c,$c22$c,$c23$c,$c24$c,$c25$c,$c*$c $cdelims$c=$c%%#dlm%% %%$ca in ('echo $c%%#sub$c%%') do ((echo 7%%$ca7)$u(echo 7%%$cb7)$u(echo 7%%$cc7)$u(echo 7%%$cd7)$u(echo 7%%$ce7)$u(echo 7%%$cf7)$u(echo 7%%$cg7)$u(echo 7%%$ch7)$u(echo 7%%$ci7)$u(echo 7%%$cj7)$u(echo 7%%$ck7)$u(echo 7%%$cl7)$u(echo 7%%$cm7)$u(echo 7%%$cn7)$u(echo 7%%$co7)$u(echo 7%%$cp7)$u(echo 7%%$cq7)$u(echo 7%%$cr7)$u(echo 7%%$cs7)$u(echo 7%%$ct7)$u(echo 7%%$cu7)$u(echo 7%%$cv7)$u(echo 7%%$cw7)$u(echo 7%%$cx7)$u(echo 7%%$cy7)$u(echo 7%%$cz7)))")^&^
   (set "%%pgel=(for /F $qusebackq tokens=*$q %%^^b in (`%%%%pcmd%%$q%%#alp%%$q`) do ((echo %%^^b)$a(exit /b 0)))")^&^
   (set "%%pget=(set #src=77)$a(for /L %%^^a in (1 1 4096) do if $e#sub$e EQU 77 (exit /b 0) else ((set #sub=$e#sub:~1,-1$e)$a(set $q#tmp=1$q)$a(for /F %%^^b in ('%%%%pcmd%%$q%%#alp%%$q') do (set $q#tmp=$q))$a(if defined #tmp (set $q#sub=$e#quo$e$e#sub$e$q))$a(for /F $qusebackq tokens=*$q %%^^b in (`%%%%pcmd%%$q%%#alp%%$q`) do ((if $e#src$e NEQ 77 (echo $c$e#src$c$e))$a(set #src=%%^^b)))$a(set #sub=$e#src$e)$a(set #src=77)))")^&^
   (set %%pcar="^^^^")^&(set %%pexc="^^^^^!^^^!^^^!")^&(for %%a in (car,exc) do (call set "%%p%%a=%%%%p%%a:~-2,1%%"))^&^
   (for %%a in (%%psep,%%palp,%%pgel,%%pget) do (^
    (call set %%a=%%%%a:$e=^^^!%%pexc^^^!%%)^&(call set %%a=%%%%a:$q=^^^!%%pquo^^^!%%)^&(call set %%a=%%%%a:$c=^^^!%%pcar^^^!%%)^&^
    set "%%a=^!%%a:$a=^%%%%pamp^%%^!"^&set "%%a=^!%%a:$u=^%%%%paux^%%^!"^&set "%%a=^!%%a:#=%%p^!"^
   ))^&^
   (set %%pamp="^^^&")^&call set "%%pamp=%%%%pamp:~-2,1%%"^&^
   (for %%a in (%%pdl,%%pdr) do if defined %%av (^
    set "%%ptmp="^&set "%%pdlm=^!%%av^!"^&set "%%av="^&^
    (for /F "tokens=*" %%b in ('%%%%pcmd%%"%%%%psep%%"') do (^
     (if "%%b"=="^!%%pquo^!" (set "%%ptmp=1") else (^
      (if defined %%av (set "%%av=^!%%av^!^%%%%pcar^%%%%b") else (set "%%av=^%%%%pcar^%%%%b"))^
     ))^
    ))^&^
    (if defined %%ptmp (^
     (if defined %%av (set "%%av=^!%%pquo^!^!%%av^!") else (set "%%av=^!%%pquo^!"))^&^
     set "%%as=^!%%pcar^!^!%%pamp^!"^
    ) else (set "%%as=^!%%pamp^!"))^
   ))^&^
   set "%%pdlm=^!%%pdlv^!"^&set "%%paux=^!%%pdls^!"^&set "%%psub=7^!%%psrc^!7"^&^
   (for /F "tokens=*" %%a in ('%%%%pcmd%%"%%%%pget%%"') do (^
    set "%%ptmp=%%a"^&(set "%%ptmp=^!%%ptmp:~1,-1^!")^&^
    (if defined %%pdrv (^
     set "%%pdlm=^!%%pdrv^!"^&set "%%paux=^!%%pdrs^!"^&set "%%psub=^!%%ptmp^!"^&^
     (for /F %%b in ('%%%%pcmd%%"%%%%pgel%%"') do (^
      set /a "%%ptcv+=1"^>NUL^&set "%%ps^!%%ptcv^!=%%b"^&call set "%%ps^!%%ptcv^!=%%%%ps^!%%ptcv^!:~1,-1%%"^
     ))^
    ) else (^
     set /a "%%ptcv+=1"^>NUL^&set "%%ps^!%%ptcv^!=^!%%ptmp^!"^
    ))^
   ))^&^
   (if 0 LSS ^^^!%%pben^^^! (set "%%pbeg=1"^&set "%%pstp=1"^&set "%%pend=^!%%ptcv^!") else (^
    set "%%pbeg=^!%%ptcv^!"^&set "%%pstp=-1"^&set "%%pend=1"^&set /a "%%pben+=^!%%ptcv^!+1"^>NUL^
   ))^&^
   set "%%pcnt=0"^&^
   (for /L %%a in (^^^!%%pbeg^^^!,^^^!%%pstp^^^!,^^^!%%pend^^^!) do (^
    (if 0 LSS ^^^!%%pstp^^^! (^
     (if ^^^!%%pben^^^! LEQ %%a (^
      set /a "%%pcnt+=1"^>NUL^&^
      (if ^^^!%%pcnt^^^! LEQ ^^^!%%pton^^^! (^
       set /a "%%pfnv+=1"^>NUL^&^
       (if defined %%prsv (^
        (if defined %%pden (set "%%prsv=^!%%prsv^!^!%%pden^!^!%%ps%%a^!") else (set "%%prsv=^!%%prsv^!^!%%ps%%a^!"))^&^
        (set %%pfsv=^^^!%%pfsv^^^!,"^!%%ps%%a^!")^
       ) else (set "%%prsv=^!%%ps%%a^!"^&(set %%pfsv="^!%%ps%%a^!")))^
      ) else if ^^^!%%peco^^^! EQU 2 (set "%%ps%%a="))^
     ) else if ^^^!%%peco^^^! EQU 2 (set "%%ps%%a="))^
    ) else (^
     (if %%a LEQ ^^^!%%pben^^^! (^
      set /a "%%pcnt+=1"^>NUL^&^
      (if ^^^!%%pcnt^^^! LEQ ^^^!%%pton^^^! (^
       set /a "%%pfnv+=1"^>NUL^&^
       (if defined %%prsv (^
        (if defined %%pden (set "%%prsv=^!%%ps%%a^!^!%%pden^!^!%%prsv^!") else (set "%%prsv=^!%%ps%%a^!^!%%prsv^!"))^&^
        (set %%pfsv=^^^!%%pfsv^^^!,"^!%%ps%%a^!")^
       ) else (set "%%prsv=^!%%ps%%a^!"^&(set %%pfsv="^!%%ps%%a^!")))^
      ) else if ^^^!%%peco^^^! EQU 2 (set "%%ps%%a="))^
     ) else if ^^^!%%peco^^^! EQU 2 (set "%%ps%%a="))^
    ))^&^
    (if ^^^!%%peco^^^! NEQ 2 (set "%%ps%%a="))^
   ))^&^
   (if ^^^!%%peco^^^! EQU 0 (^
    (if defined %%ptcn (set "^!%%ptcn^!=^!%%ptcv^!"))^&^
    (if defined %%pfnn (set "^!%%pfnn^!=^!%%pfnv^!"))^&^
    (if defined %%prsn if defined %%prsv (set "^!%%prsn^!=^!%%prsv^!") else (set "^!%%prsn^!="))^&^
    (if defined %%pfsn if defined %%pfsv (set "^!%%pfsn^!=^!%%pfsv^!") else (set "^!%%pfsn^!="))^
   ) else (^
    (if defined %%ptcn (echo "^!%%ptcn^!=^!%%ptcv^!"))^&^
    (if defined %%pfnn (echo "^!%%pfnn^!=^!%%pfnv^!"))^&^
    (if defined %%prsn if defined %%prsv (echo "^!%%prsn^!=^!%%prsv^!") else (echo "^!%%prsn^!="))^&^
    (if ^^^!%%peco^^^! EQU 1 (^
     (if defined %%pfsn if defined %%pfsv (echo "^!%%pfsn^!=^!%%pfsv^!") else (echo "^!%%pfsn^!="))^
    ) else (^
     (if ^^^!%%pnon^^^! NEQ 0 (echo.))^&^
     (for /L %%a in (^^^!%%pbeg^^^!,^^^!%%pstp^^^!,^^^!%%pend^^^!) do if defined %%ps%%a (^
      (if "^!%%ps%%a: =^!"=="" (echo "^!%%ps%%a^!") else (echo ^^^!%%ps%%a^^^!))^&^
      set "%%ps%%a="^
     ))^
    ))^
   ))^&^
   (for %%a in (alp,amp,beg,ben,car,cmd,cnt,den,der,dlm,dls,dlv,drs,drv,eco,end,exc,fnn,fnv,fsn,fsv,gel,get,non,quo,rsn,rsv,sep,src,stp,sub,tcn,tcv,tmp,ton) do (set "%%p%%a="))^
  ))^&^
  set "%%paux="^
 ) else (echo Error [@syms_cutstr]: Absent parameters.^&exit /b 1)) else set wds_scs_aux=

::           @pid_title - returns window caption (title) of the process with given identifier (PID).
::                        %~1 == PID value of the process hosting window;
::                        %~2 == variable name for title string;
::                        %~3 == [optional: key parameter `1` to echo result without assigning it, default is `0`}.
::
set @pid_title=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_pit_aux (^
  (for /F "tokens=1,2,3" %%a in ('echo %%wds_pit_aux%%') do if "%%~b"=="" (^
   echo Error [@pid_title]: The parameter #2 are absent.^&exit /b 1^
  ) else (^
   set "wds_pit_tp1=%%a"^&set "wds_pit_tp2=%%~b"^&set "wds_pit_eco=0"^&^
   (if ^^^!wds_pit_eco^^^! NEQ 0 (echo Error [@pid_title]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set /a "wds_pit_eco=%%~c"^>NUL 2^>^&1)^>NUL^
  ))^&^
  set "wds_pit_tit="^&^
  (if defined wds_pit_tp1 (^
   (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2" %%b in ('echo %%a') do for /F "tokens=1,2 delims=." %%c in ('echo %%b') do (set wds_pit_aux=%%c%%d))^&^
   (if ^^^!wds_pit_aux^^^! LSS 61 (^
    (for /F "skip=1 tokens=2,9 delims=," %%x in ('call tasklist /V /FO CSV') do if %%~x EQU ^^^!wds_pit_tp1^^^! (^
     set "wds_pit_tit=%%~y"^
    ))^
   ) else (^
    (for /F "skip=9 tokens=1,* delims=:" %%x in ('call tasklist /FI "pid eq ^!wds_pit_tp1^!" /V /FO LIST') do (^
     for /F "tokens=*" %%z in ('echo %%y') do (^
      set "wds_pit_tit=%%z"^
     )^
    ))^
   ))^
  ))^&^
  (if ^^^!wds_pit_eco^^^! NEQ 1 (^
   (if defined wds_pit_tp2 if defined wds_pit_tit (set "^!wds_pit_tp2^!=^!wds_pit_tit^!") else (set "^!wds_pit_tp2^!="))^&^
   set "wds_pit_tp1="^&set "wds_pit_tp2="^&set "wds_pit_eco="^&set "wds_pit_tit="^
  ) else (^
   (if defined wds_pit_tp2 if defined wds_pit_tit (echo "^!wds_pit_tp2^!=^!wds_pit_tit^!") else (echo "^!wds_pit_tp2^!="))^
  ))^&^
  set "wds_pit_aux="^
 ) else (echo Error [@pid_title]: Absent parameters.^&exit /b 1)) else set wds_pit_aux=

::               @title - depends on parameterization: gets window caption (title), its process identifier (PID) and current PID.
::                        %~1 == name of external variable for assigning string of window title;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~2 == name of variable for PID of the process showing window, by default current window PID;
::                      2:%~3 == name of variable with PID of the current process, to get PID of process with window;
::                      3:%~4 == name of variable to return `1` if the title of the process without window, `0` otherwise;
::                      4:%~5 == key parameter `1` to echo result without assigning it, default is `0`.
::           Remarks. #1: If `1:%~2` & `2:%~3` haven't valid values it returns data for current process & for current window;
::                    #2: If `2:%~3` has valid value it returns window title to `%~1` and its PID to `1:%~2`;
::                    #3: If `1:%~2` & `2:%~3` weren't specified it returns only title of the current window;
::                    #4: If `2:%~3` is not specified or hasn't value, but `1:%~2` has value, it calls `@pid_title` inside.
::          Dependencies: @pid_title.
::
set @title=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tit_aux (^
  (for /F %%p in ('echo wds_tit') do (^
   (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%p_aux%%') do (^
    (for %%f in ("sub=","wtn=%%~a","win=","wiv=0","cin=","civ=0","nwn=","eco=0") do (set "%%p_%%~f"))^&^
    (if not "^!%%p_wtn::=^!"=="^!%%p_wtn^!" (echo Error [@title]: Absent parameter #1.^&exit /b 1))^&^
    (if ^^^!%%p_wiv^^^! NEQ 0 (echo Error [@title]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (for %%f in (%%~b,%%~c,%%~d,%%~e) do if not "%%f"=="" (^
     set "%%p_aux=%%f"^&set "%%p_cnt=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
         (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_win=^!%%p_cnt^!"^&set "%%p_sub=wiv")^
     else if ^^^!%%p_aux^^^! EQU 2 (set "%%p_cin=^!%%p_cnt^!"^&set "%%p_sub=civ")^
     else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_nwn=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 4 ((set /a "%%p_eco=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL))^&^
     (if defined %%p_sub (^
      (for /F "tokens=* delims=+,-,0" %%g in ('"echo.%%^!%%p_cnt^!%%"') do (^
       (set /a "%%p_aux=%%~g"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%p_aux^!"=="%%~g" (set "%%p_^!%%p_sub^!=%%~g"))^
      ))^&set "%%p_sub="^
     ))^
    ))^
   ))^&^
   (if ^^^!%%p_civ^^^! NEQ 0 (set "%%p_wiv=0"))^&^
   (if ^^^!%%p_wiv^^^! EQU 0 (set "%%p_box=?") else if defined %%p_nwn (set "%%p_box=?") else (set "%%p_box="))^&^
   (if defined %%p_box (^
    (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2" %%b in ('echo %%a') do for /F "tokens=1,2 delims=." %%c in ('echo %%b') do (set %%p_ver=%%c%%d))^&^
    (if ^^^!%%p_ver^^^! LSS 61 (^
     (for /F "skip=1 tokens=2,9 delims=," %%a in ('call tasklist /V /FO CSV') do if %%~a EQU 0 (^
      set "%%p_box=%%~b"^
     ))^
    ) else (^
     (for /F "skip=9 tokens=1,* delims=:" %%a in ('call tasklist /FI "pid eq 0" /V /FO LIST') do (^
      for /F "tokens=*" %%c in ('echo %%b') do set "%%p_box=%%c"^
     ))^
    ))^
   ))^&^
   (if ^^^!%%p_wiv^^^! EQU 0 (^
    set "%%p_cnt=0"^&^
    (for /F "skip=2 tokens=1,2,3" %%a in ('"wmic process get parentprocessid^,processid^,name"') do if not "%%c"=="" (^
     (set "%%p_pnm^!%%p_cnt^!=%%a")^&(set "%%p_ppi^!%%p_cnt^!=%%b")^&(set "%%p_pid^!%%p_cnt^!=%%c")^&^
     set /a "%%p_cnt+=1"^>NUL^
    ))^&^
    set "%%p_aux="^&set "%%p_ppi="^&set "%%p_wtv=^!%%p_box^!"^&(set %%p_bar="^^^|")^&^
    (for /L %%a in (^^^!%%p_cnt^^^! -1 0) do (^
     (if ^^^!%%p_wiv^^^! EQU 0 if defined %%p_pnm%%a if defined %%p_pid%%a (^
      (if ^^^!%%p_civ^^^! NEQ 0 (^
       if defined %%p_ppi%%a if "^!%%p_civ^!"=="^!%%p_pid%%a^!" (^
        set "%%p_ppi=^!%%p_ppi%%a^!"^&set "%%p_aux=1"^
       )^
      ) else if "^!%%p_pnm%%a:wmic.exe=^!"=="" (set "%%p_ppi=^!%%p_ppi%%a^!"))^&^
      (if "^!%%p_ppi^!"=="^!%%p_pid%%a^!" (set "%%p_aux=1"))^&^
      (if defined %%p_aux (^
       set "%%p_aux="^&^
       (if ^^^!%%p_ver^^^! LSS 61 (^
        (for /F "tokens=2,9 delims=," %%b in ('"call tasklist /NH /V /FO CSV %%%%p_bar:~-2,1%% findstr /C:%%%%p_pid%%a%%"') do if %%~b EQU ^^^!%%p_pid%%a^^^! (^
         set "%%p_aux=%%~c"^&if ^^^!%%p_civ^^^! EQU 0 (set "%%p_civ=^!%%p_ppi^!")^
        ))^
       ) else (^
        (for /F "skip=9 tokens=1,* delims=:" %%b in ('call tasklist /FI "pid eq ^!%%p_pid%%a^!" /V /FO LIST') do (^
         for /F "tokens=*" %%d in ('echo %%c') do (^
          set "%%p_aux=%%d"^&if ^^^!%%p_civ^^^! EQU 0 (set "%%p_civ=^!%%p_ppi^!")^
         )^
        ))^
       ))^&^
       (if defined %%p_aux (^
        (if "^!%%p_box^!"=="^!%%p_aux^!" (^
         set "%%p_ppi=^!%%p_ppi%%a^!"^
        ) else (^
         set "%%p_wiv=^!%%p_pid%%a^!"^&set "%%p_wtv=^!%%p_aux^!"^
        ))^
       ) else (set "%%p_ppi=^!%%p_ppi%%a^!"))^
      ))^&^
      set "%%p_aux="^
     ))^&^
     set "%%p_pnm%%a="^&set "%%p_pid%%a="^&set "%%p_ppi%%a="^
    ))^&^
    (if ^^^!%%p_wiv^^^! EQU 0 (set "%%p_wiv=^!%%p_civ^!"))^
   ) else (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@pid_title^! ^!%%p_wiv^! %%p_wtv 1"') do (set %%a))^&^
    (if defined %%p_box if not defined %%p_wtv (set "%%p_wtv=^!%%p_box^!"))^
   ))^&^
   (if ^^^!%%p_eco^^^! NEQ 1 (^
    (if defined %%p_wtn (set "^!%%p_wtn^!=^!%%p_wtv^!"^>NUL 2^>^&1^&set "%%p_wtn="))^&set "%%p_wtv="^&^
    (if defined %%p_cin (set "^!%%p_cin^!=^!%%p_civ^!"^>NUL 2^>^&1^&set "%%p_cin="))^&set "%%p_civ="^&^
    (if defined %%p_win (set "^!%%p_win^!=^!%%p_wiv^!"^>NUL 2^>^&1^&set "%%p_win="))^&set "%%p_wiv="^&^
    (if defined %%p_nwn if "^!%%p_wtv^!"=="^!%%p_box^!" (set "^!%%p_nwn^!=1") else (set "^!%%p_nwn^!=0"))^&^
    (for %%a in (aux,bar,box,cnt,eco,nwn,ppi,ver) do (set "%%p_%%a="))^
   ) else (^
    (if defined %%p_wtn (echo "^!%%p_wtn^!=^!%%p_wtv^!"))^&^
    (if defined %%p_cin (echo "^!%%p_cin^!=^!%%p_civ^!"))^&^
    (if defined %%p_win (echo "^!%%p_win^!=^!%%p_wiv^!"))^&^
    (if defined %%p_nwn if "^!%%p_wtv^!"=="^!%%p_box^!" (echo "^!%%p_nwn^!=1") else (echo "^!%%p_nwn^!=0"))^
   ))^
  ))^
 ) else (echo Error [@title]: Absent parameters.^&exit /b 1)) else set wds_tit_aux=

::           @title_pid - finds PID of window using substring of caption (title) and returns total count of matched processes.
::                        %~1 == parameters for findstr.exe tool to search matches in window titles (value or its variable name);
::                        %~2 == variable name to return PID value of the process with 1st matched title;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == variable name to return number of processes with window titles matching search string;
::                      2:%~4 == variable name to return window title of the 1st matched process;
::                      3:%~5 == key parameter `1` to echo result without assigning it, default is `0`.
::                Sample: %@title_pid% %~n0 pid_proc1 1:procs_total 2:title_proc1
::             Notes. #1: The constant explicit string can not have space symbols or parsing of parameters fails (use variable);
::                    #2: Before use of this macro, check command: tasklist /V /FO:LIST | findstr /C:"`%~1`";
::                    #3: This macro uses `LIST` format of `tasklist` and searches specifically window captions.
::
set @title_pid=^
 for %%x in (1 2) do if %%x EQU 2 if defined wds_tpi_par (for /F %%p in ('echo wds_tpi_') do (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo %%%%ppar%%') do (^
   set "%%ppid=%%b"^&set "^!%%ppid^!="^&^
   (if not defined %%ppid (echo Error [@title_pid]: Absent parameter #2.^&exit /b 1))^&^
   (if defined %%a (set "%%pssp=^!%%a^!"^>NUL 2^>^&1) else (set "%%pssp=%%~a"))^&^
   set "%%pcnt="^&set "%%ptit="^&set "%%peco=0"^&^
   (if ^^^!%%peco^^^! NEQ 0 (echo Error [@title_pid]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%f in (%%~c,%%~d,%%~e) do if not "%%f"=="" (^
    set "%%ppar=%%f"^&set "%%ppds=^!%%ppar:~2^!"^&set "%%ppar=^!%%ppar:~0,1^!"^&^
    (if ^^^!%%ppar^^^! EQU 1 (set "%%pcnt=^!%%ppds^!"^&set "^!%%pcnt^!=0"^>NUL 2^>^&1))^&^
    (if ^^^!%%ppar^^^! EQU 2 (set "%%ptit=^!%%ppds^!"^&set "^!%%ptit^!="^>NUL 2^>^&1))^&^
    (if ^^^!%%ppar^^^! EQU 3 ((set /a "%%peco=^!%%ppds^!"^>NUL 2^>^&1)^>NUL))^
   ))^
  ))^&^
  (if defined %%pssp if defined %%ppid (^
   (set %%pbar="^^^|")^&call set "%%pquo=%%%%pbar:~-1,1%%"^&set "%%ppar="^&set "%%ppds=0"^&^
   (for /F "tokens=1,2,* delims=:" %%w in ('cmd /d /q /v:on /e:on /r "tasklist /V /FO:LIST %%%%pbar:~-2,1%% findstr /N /C:%%%%pquo%%PID:%%%%pquo%% /C:%%%%pquo%%%%%%pssp%%%%%%pquo%%"') do if "%%~x"=="PID" (^
    set /a "%%ppds=%%~w+7"^>NUL 2^>^&1^&^&set "%%ppar=%%y"^&set "%%ppar=^!%%ppar: =^!"^
   ) else if %%~w EQU ^^^!%%ppds^^^! for /F "tokens=*" %%z in ('echo %%y') do if NOT "%%~z"=="" (^
    (if defined %%pcnt (set /a "^!%%pcnt^!+=1"^>NUL 2^>^&1))^&^
    (if not defined ^^^!%%ppid^^^! (^
     set "^!%%ppid^!=^!%%ppar^!"^&^
     (if defined %%ptit (set "^!%%ptit^!=%%z"))^
    ))^
   ))^&^
   (if ^^^!%%peco^^^! EQU 1 (^
    (if defined ^^^!%%ppid^^^! (call echo "^!%%ppid^!=%%^!%%ppid^!%%") else (echo "^!%%ppid^!="))^&^
    (if defined %%pcnt if defined ^^^!%%pcnt^^^! (call echo "^!%%pcnt^!=%%^!%%pcnt^!%%") else (echo "^!%%pcnt^!="))^&^
    (if defined %%ptit if defined ^^^!%%ptit^^^! (call echo "^!%%ptit^!=%%^!%%ptit^!%%") else (echo "^!%%ptit^!="))^
   ) else (^
    (for %%a in (eco,bar,cnt,par,pds,pid,quo,ssp,tit) do (set "%%p%%a="))^
   ))^
  ))^
 )) else (echo Error [@title_pid]: Absent parameters.^&exit /b 1) else set wds_tpi_par=

::       @substr_remove - removes substrings inside delimiters.
::                        %~1 == variable name with source string, it will contain result string after completion;
::                        %~2 == left delimiter or variable name with left delimiter of substrings to delete;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == right delimiter of substrings (value or name of variable with value);
::                      2:%~4 == name of digital external variable to return number of deleted substrings;
::                      3:%~5 == number of substrings to delete, default is unlimited value;
::                      4:%~6 == substring number in the sequence of matching substrings to start deletions, negative is from end;
::                      5:%~7 == new delimiter or variable name with new delimiter string instead of deleted substrings;
::                      6:%~8 == key value `1` to keep leading & trailing delimiters, `0` to drop, default is to keep them (`1`).
::          Dependencies: @echo_params.
::
set @substr_remove=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ssr_aux (^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo %%wds_ssr_aux%%') do (^
   (if defined %%a if not "%%b"=="" (^
    set "wds_ssr_sn=%%~a"^&set "wds_ssr_ss=^!%%~a^!"^&(if defined %%~b (set "wds_ssr_bd=^!%%~b^!") else (set "wds_ssr_bd=%%b"))^
   ))^&^
   set "wds_ssr_ed="^&set "wds_ssr_nd="^&set "wds_ssr_emb=1"^&set "wds_ssr_qsd=0"^&set "wds_ssr_bdn=0"^&^
   (if ^^^!wds_ssr_bdn^^^! NEQ 0 (echo Error [@substr_remove]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for /F "usebackq tokens=*" %%i in (`cmd /d /q /r "^!@echo_params^! 6 %%~c %%~d %%~e %%~f %%~g %%~h"`) do if not "%%i"=="" (^
    set "wds_ssr_aux=%%i"^&set "wds_ssr_cnt=^!wds_ssr_aux:~2^!"^&set "wds_ssr_aux=^!wds_ssr_aux:~0,1^!"^&^
    (if ^^^!wds_ssr_aux^^^! EQU 1 ((if defined ^^^!wds_ssr_cnt^^^! (call set "wds_ssr_ed=%%^!wds_ssr_cnt^!%%") else (set "wds_ssr_ed=^!wds_ssr_cnt^!"))))^&^
    (if ^^^!wds_ssr_aux^^^! EQU 2 (set "wds_ssr_nmb=^!wds_ssr_cnt^!"^&set /a "^!wds_ssr_nmb^!=0"^>NUL 2^>^&1))^&^
    (if ^^^!wds_ssr_aux^^^! EQU 3 (set /a "wds_ssr_qsd=^!wds_ssr_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_ssr_aux^^^! EQU 4 (set /a "wds_ssr_bdn=^!wds_ssr_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_ssr_aux^^^! EQU 5 ((if defined ^^^!wds_ssr_cnt^^^! (call set "wds_ssr_nd=%%^!wds_ssr_cnt^!%%") else (set "wds_ssr_nd=^!wds_ssr_cnt^!"))))^&^
    (if ^^^!wds_ssr_aux^^^! EQU 6 (set /a "wds_ssr_emb=^!wds_ssr_cnt^!"^>NUL 2^>^&1)^>NUL)^
   ))^
  ))^&^
  (for %%a in (wds_ssr_ss wds_ssr_bd wds_ssr_ed) do if defined %%a (^
   set "%%a=^!%%a:/CHR{20}= ^!"^&set "wds_ssr_aux=^!%%a^!"^&set "%%al=1"^&^
   (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
    set "wds_ssr_res=^!wds_ssr_aux:~%%b,1^!"^&^
    (if defined wds_ssr_res (set "wds_ssr_aux=^!wds_ssr_aux:~%%b^!"^&set /a "%%al+=%%b"^>NUL))^
   ))^
  ))^&^
  (if not defined wds_ssr_ed (set "wds_ssr_ed=^!wds_ssr_bd^!"^&set "wds_ssr_edl=^!wds_ssr_bdl^!"))^&^
  (if defined wds_ssr_nd (set "wds_ssr_nd=^!wds_ssr_nd:/CHR{20}= ^!"))^&^
  (if 0 LSS ^^^!wds_ssr_ssl^^^! if 0 LSS ^^^!wds_ssr_bdl^^^! (^
   (if ^^^!wds_ssr_qsd^^^! EQU 0 (set "wds_ssr_qsd=1000000"))^&^
   (if ^^^!wds_ssr_bdn^^^! EQU 0 (set "wds_ssr_bdn=1"))^&^
   (if ^^^!wds_ssr_bdn^^^! LSS 0 (^
    set /a "wds_ssr_psb=^!wds_ssr_ssl^!-1"^>NUL^&set "wds_ssr_pss=-1"^&set "wds_ssr_pse=0"^&set "wds_ssr_bdn=-^!wds_ssr_bdn^!"^
   ) else (^
    set "wds_ssr_psb=0"^&set "wds_ssr_pss=1"^&set /a "wds_ssr_pse=^!wds_ssr_ssl^!-1"^>NUL^
   ))^&^
   (set wds_ssr_res="")^&set "wds_ssr_don=0"^&set "wds_ssr_cnt=0"^&^
   set "wds_ssr_pfp=^!wds_ssr_psb^!"^&set "wds_ssr_pos=^!wds_ssr_psb^!"^&set "wds_ssr_fbp=-1"^&^
   (for /L %%x in (^^^!wds_ssr_psb^^^!,^^^!wds_ssr_pss^^^!,^^^!wds_ssr_pse^^^!) do if ^^^!wds_ssr_don^^^! EQU 0 (^
    (if ^^^!wds_ssr_fbp^^^! LSS 0 (^
     (call set "wds_ssr_aux=%%wds_ssr_ss:~^!wds_ssr_pos^!,^!wds_ssr_bdl^!%%")^&^
     (if "^!wds_ssr_aux^!"=="^!wds_ssr_bd^!" (^
      set "wds_ssr_fbp=^!wds_ssr_pos^!"^&^
      (if 0 LSS ^^^!wds_ssr_pss^^^! (set /a "wds_ssr_pos+=^!wds_ssr_bdl^!"^>NUL) else (set /a "wds_ssr_pos-=1"^>NUL))^
     ) else (^
      set /a "wds_ssr_pos+=^!wds_ssr_pss^!"^>NUL^
     ))^
    ) else (^
     call set "wds_ssr_aux=%%wds_ssr_ss:~^!wds_ssr_pos^!,^!wds_ssr_edl^!%%"^&^
     (if "^!wds_ssr_aux^!"=="^!wds_ssr_ed^!" (^
      set /a "wds_ssr_cnt+=1"^>NUL^&^
      (if ^^^!wds_ssr_pss^^^! LSS 0 (^
       set /a "wds_ssr_aux=^!wds_ssr_fbp^!+^!wds_ssr_bdl^!"^>NUL^&^
       set /a "wds_ssr_ssl=^!wds_ssr_pfp^!-^!wds_ssr_aux^!+1"^>NUL^&^
       (call set wds_ssr_res="%%wds_ssr_ss:~^!wds_ssr_aux^!,^!wds_ssr_ssl^!%%^!wds_ssr_res:~1,-1^!")^&^
       set /a "wds_ssr_ssl=^!wds_ssr_fbp^!+^!wds_ssr_bdl^!-^!wds_ssr_pos^!"^>NUL^&^
       call set "wds_ssr_add=%%wds_ssr_ss:~^!wds_ssr_pos^!,^!wds_ssr_ssl^!%%"^&^
       set /a "wds_ssr_aux=^!wds_ssr_cnt^!-^!wds_ssr_bdn^!"^>NUL^&^
       set /a "wds_ssr_pos-=1"^>NUL^&^
       (if ^^^!wds_ssr_cnt^^^! LSS ^^^!wds_ssr_bdn^^^! (^
        (set wds_ssr_res="^!wds_ssr_add^!^!wds_ssr_res:~1,-1^!")^
       ) else if ^^^!wds_ssr_qsd^^^! LEQ ^^^!wds_ssr_aux^^^! (^
        (set wds_ssr_res="^!wds_ssr_add^!^!wds_ssr_res:~1,-1^!")^&^
        set "wds_ssr_don=1"^
       ) else (^
        (if defined ^^^!wds_ssr_nmb^^^! (set /a "^!wds_ssr_nmb^!+=1"^>NUL 2^>^&1)^>NUL)^&^
        (if ^^^!wds_ssr_emb^^^! EQU 1 (^
         (set wds_ssr_res="^!wds_ssr_nd^!^!wds_ssr_res:~1,-1^!")^
        ) else if 0 LSS ^^^!wds_ssr_pos^^^! if ^^^!wds_ssr_fbp^^^! LSS ^^^!wds_ssr_psb^^^! (^
         (set wds_ssr_res="^!wds_ssr_nd^!^!wds_ssr_res:~1,-1^!")^
        ))^
       ))^
      ) else (^
       set /a "wds_ssr_ssl=^!wds_ssr_fbp^!-^!wds_ssr_pfp^!"^>NUL^&^
       (call set wds_ssr_res="^!wds_ssr_res:~1,-1^!%%wds_ssr_ss:~^!wds_ssr_pfp^!,^!wds_ssr_ssl^!%%")^&^
       set "wds_ssr_aux=^!wds_ssr_fbp^!"^&^
       set /a "wds_ssr_ssl=^!wds_ssr_pos^!+^!wds_ssr_edl^!-^!wds_ssr_aux^!"^>NUL^&^
       call set "wds_ssr_add=%%wds_ssr_ss:~^!wds_ssr_aux^!,^!wds_ssr_ssl^!%%"^&^
       set /a "wds_ssr_aux=^!wds_ssr_cnt^!-^!wds_ssr_bdn^!"^>NUL^&^
       set /a "wds_ssr_pos+=^!wds_ssr_edl^!"^>NUL^&^
       (if ^^^!wds_ssr_cnt^^^! LSS ^^^!wds_ssr_bdn^^^! (^
        (set wds_ssr_res="^!wds_ssr_res:~1,-1^!^!wds_ssr_add^!")^
       ) else if ^^^!wds_ssr_qsd^^^! LEQ ^^^!wds_ssr_aux^^^! (^
        (set wds_ssr_res="^!wds_ssr_res:~1,-1^!^!wds_ssr_add^!")^&^
        set "wds_ssr_don=1"^
       ) else (^
        (if defined ^^^!wds_ssr_nmb^^^! (set /a "^!wds_ssr_nmb^!+=1"^>NUL 2^>^&1)^>NUL)^&^
        (if ^^^!wds_ssr_emb^^^! EQU 1 (^
         (set wds_ssr_res="^!wds_ssr_res:~1,-1^!^!wds_ssr_nd^!")^
        ) else if 0 LSS ^^^!wds_ssr_fbp^^^! if ^^^!wds_ssr_pos^^^! LSS ^^^!wds_ssr_pse^^^! (^
         (set wds_ssr_res="^!wds_ssr_res:~1,-1^!^!wds_ssr_nd^!")^
        ))^
       ))^
      ))^&^
      set "wds_ssr_pfp=^!wds_ssr_pos^!"^&set "wds_ssr_fbp=-1"^
     ) else (^
      set /a "wds_ssr_pos+=^!wds_ssr_pss^!"^>NUL^
     ))^
    ))^&^
    (if ^^^!wds_ssr_pss^^^! LSS 0 (if ^^^!wds_ssr_pos^^^! LSS ^^^!wds_ssr_pse^^^! set "wds_ssr_don=1") else (if ^^^!wds_ssr_pse^^^! LSS ^^^!wds_ssr_pos^^^! set "wds_ssr_don=1"))^
   ))^&^
   (if ^^^!wds_ssr_pss^^^! LSS 0 (^
    if ^^^!wds_ssr_pse^^^! LEQ ^^^!wds_ssr_pfp^^^! (^
     set /a "wds_ssr_ssl=^!wds_ssr_pfp^!-^!wds_ssr_pse^!+1"^>NUL^&^
     (call set wds_ssr_res="%%wds_ssr_ss:~^!wds_ssr_pse^!,^!wds_ssr_ssl^!%%^!wds_ssr_res:~1,-1^!")^
    )^
   ) else (^
    if ^^^!wds_ssr_pfp^^^! LEQ ^^^!wds_ssr_pse^^^! (^
     set /a "wds_ssr_ssl=^!wds_ssr_pse^!-^!wds_ssr_pfp^!+1"^>NUL^&^
     (call set wds_ssr_res="^!wds_ssr_res:~1,-1^!%%wds_ssr_ss:~^!wds_ssr_pfp^!,^!wds_ssr_ssl^!%%")^
    )^
   ))^&^
   set "^!wds_ssr_sn^!=^!wds_ssr_res:~1,-1^!"^
  ))^&^
  (for %%a in (aux,add,bd,bdl,bdn,cnt,don,ed,edl,emb,fbp,nd,pfp,pos,psb,pse,pss,qsd,res,nmb,sn,ss,ssl) do (set "wds_ssr_%%a="))^
 ) else (echo Error [@substr_remove]: Absent parameters.^&exit /b 1)) else set wds_ssr_aux=
 
::          @substr_get - extracts substrings inside delimiters & returns them as string.
::                        %~1 == variable name with source string, it will contain result string after completion;
::                        %~2 == left delimiter or variable name with left delimiter of substrings to delete;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == right delimiter of substrings (value or name of variable with value);
::                      2:%~4 == name of digital external variable to return number of found substrings;
::                      3:%~5 == number of substrings to search, default is unlimited value;
::                      4:%~6 == substring number in the sequence of matching substrings to start search, negative is from end;
::                      5:%~7 == delimiter or variable name with delimiter string to insert between found substrings.
::          Dependencies: @echo_params.
::
set @substr_get=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ssg_aux (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo %%wds_ssg_aux%%') do (^
   (if defined %%a if not "%%b"=="" (^
    set "wds_ssg_sn=%%~a"^&set "wds_ssg_ss=^!%%~a^!"^&(if defined %%~b (set "wds_ssg_bd=^!%%~b^!") else (set "wds_ssg_bd=%%b"))^
   ))^&^
   set "wds_ssg_ed="^&set "wds_ssg_nd="^&set "wds_ssg_qsd=0"^&set "wds_ssg_bdn=0"^&^
   (if ^^^!wds_ssg_bdn^^^! NEQ 0 (echo Error [@substr_get]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for /F "usebackq tokens=*" %%i in (`cmd /d /q /r "^!@echo_params^! 5 %%~c %%~d %%~e %%~f %%~g"`) do if not "%%i"=="" (^
    set "wds_ssg_aux=%%i"^&set "wds_ssg_cnt=^!wds_ssg_aux:~2^!"^&set "wds_ssg_aux=^!wds_ssg_aux:~0,1^!"^&^
    (if ^^^!wds_ssg_aux^^^! EQU 1 ((if defined ^^^!wds_ssg_cnt^^^! (call set "wds_ssg_ed=%%^!wds_ssg_cnt^!%%") else (set "wds_ssg_ed=^!wds_ssg_cnt^!"))))^&^
    (if ^^^!wds_ssg_aux^^^! EQU 2 (set "wds_ssg_nmb=^!wds_ssg_cnt^!"^&set /a "^!wds_ssg_nmb^!=0"^>NUL 2^>^&1))^&^
    (if ^^^!wds_ssg_aux^^^! EQU 3 (set /a "wds_ssg_qsd=^!wds_ssg_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_ssg_aux^^^! EQU 4 (set /a "wds_ssg_bdn=^!wds_ssg_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_ssg_aux^^^! EQU 5 ((if defined ^^^!wds_ssg_cnt^^^! (call set "wds_ssg_nd=%%^!wds_ssg_cnt^!%%") else (set "wds_ssg_nd=^!wds_ssg_cnt^!"))))^
   ))^
  ))^&^
  (for %%a in (wds_ssg_ss wds_ssg_bd wds_ssg_ed) do if defined %%a (^
   set "%%a=^!%%a:/CHR{20}= ^!"^&set "wds_ssg_aux=^!%%a^!"^&set "%%al=1"^&^
   (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
    set "wds_ssg_res=^!wds_ssg_aux:~%%b,1^!"^&^
    (if defined wds_ssg_res (set "wds_ssg_aux=^!wds_ssg_aux:~%%b^!"^&set /a "%%al+=%%b"^>NUL))^
   ))^
  ))^&^
  (if not defined wds_ssg_ed (set "wds_ssg_ed=^!wds_ssg_bd^!"^&set "wds_ssg_edl=^!wds_ssg_bdl^!"))^&^
  (if defined wds_ssg_nd (set "wds_ssg_nd=^!wds_ssg_nd:/CHR{20}= ^!"))^&^
  (if 0 LSS ^^^!wds_ssg_ssl^^^! if 0 LSS ^^^!wds_ssg_bdl^^^! (^
   (if ^^^!wds_ssg_qsd^^^! EQU 0 (set "wds_ssg_qsd=1000000"))^&^
   (if ^^^!wds_ssg_bdn^^^! EQU 0 (set "wds_ssg_bdn=1"))^&^
   (if ^^^!wds_ssg_bdn^^^! LSS 0 (^
    set /a "wds_ssg_psb=^!wds_ssg_ssl^!-1"^>NUL^&set "wds_ssg_pss=-1"^&set "wds_ssg_pse=0"^&set "wds_ssg_bdn=-^!wds_ssg_bdn^!"^
   ) else (^
    set "wds_ssg_psb=0"^&set "wds_ssg_pss=1"^&set /a "wds_ssg_pse=^!wds_ssg_ssl^!-1"^>NUL^
   ))^&^
   (set wds_ssg_res="")^&set "wds_ssg_don=0"^&set "wds_ssg_cnt=0"^&set "wds_ssg_pos=^!wds_ssg_psb^!"^&set "wds_ssg_fbp=-1"^&^
   (for /L %%x in (^^^!wds_ssg_psb^^^!,^^^!wds_ssg_pss^^^!,^^^!wds_ssg_pse^^^!) do if ^^^!wds_ssg_don^^^! EQU 0 (^
    (if ^^^!wds_ssg_fbp^^^! LSS 0 (^
     (call set "wds_ssg_aux=%%wds_ssg_ss:~^!wds_ssg_pos^!,^!wds_ssg_bdl^!%%")^&^
     (if "^!wds_ssg_aux^!"=="^!wds_ssg_bd^!" (^
      set "wds_ssg_fbp=^!wds_ssg_pos^!"^&^
      (if 0 LSS ^^^!wds_ssg_pss^^^! (set /a "wds_ssg_pos+=^!wds_ssg_bdl^!"^>NUL) else (set /a "wds_ssg_pos-=1"^>NUL))^
     ) else (^
      set /a "wds_ssg_pos+=^!wds_ssg_pss^!"^>NUL^
     ))^
    ) else (^
     call set "wds_ssg_aux=%%wds_ssg_ss:~^!wds_ssg_pos^!,^!wds_ssg_edl^!%%"^&^
     (if "^!wds_ssg_aux^!"=="^!wds_ssg_ed^!" (^
      set /a "wds_ssg_cnt+=1"^>NUL^&^
      (if ^^^!wds_ssg_pss^^^! LSS 0 (^
       set /a "wds_ssg_aux=^!wds_ssg_pos^!+^!wds_ssg_edl^!"^>NUL^&^
       set /a "wds_ssg_ssl=^!wds_ssg_fbp^!-^!wds_ssg_aux^!"^>NUL^&^
       call set "wds_ssg_add=%%wds_ssg_ss:~^!wds_ssg_aux^!,^!wds_ssg_ssl^!%%"^&^
       set /a "wds_ssg_aux=^!wds_ssg_cnt^!-^!wds_ssg_bdn^!"^>NUL^&^
       set /a "wds_ssg_pos-=1"^>NUL^&^
       (if ^^^!wds_ssg_qsd^^^! LEQ ^^^!wds_ssg_aux^^^! (^
        set "wds_ssg_don=1"^
       ) else if ^^^!wds_ssg_bdn^^^! LEQ ^^^!wds_ssg_cnt^^^! (^
        (if defined ^^^!wds_ssg_nmb^^^! (set /a "^!wds_ssg_nmb^!+=1")^>NUL)^&^
        (if ^^^!wds_ssg_bdn^^^! LSS ^^^!wds_ssg_cnt^^^! (set wds_ssg_res="^!wds_ssg_nd^!^!wds_ssg_res:~1,-1^!"))^&^
        (set wds_ssg_res="^!wds_ssg_add^!^!wds_ssg_res:~1,-1^!")^
       ))^
      ) else (^
       set /a "wds_ssg_aux=^!wds_ssg_fbp^!+^!wds_ssg_bdl^!"^>NUL^&^
       set /a "wds_ssg_ssl=^!wds_ssg_pos^!-^!wds_ssg_aux^!"^>NUL^&^
       call set "wds_ssg_add=%%wds_ssg_ss:~^!wds_ssg_aux^!,^!wds_ssg_ssl^!%%"^&^
       set /a "wds_ssg_aux=^!wds_ssg_cnt^!-^!wds_ssg_bdn^!"^>NUL^&^
       set /a "wds_ssg_pos+=^!wds_ssg_edl^!"^>NUL^&^
       (if ^^^!wds_ssg_qsd^^^! LEQ ^^^!wds_ssg_aux^^^! (^
        set "wds_ssg_don=1"^
       ) else if ^^^!wds_ssg_bdn^^^! LEQ ^^^!wds_ssg_cnt^^^! (^
        (if defined ^^^!wds_ssg_nmb^^^! (set /a "^!wds_ssg_nmb^!+=1")^>NUL)^&^
        (if ^^^!wds_ssg_bdn^^^! LSS ^^^!wds_ssg_cnt^^^! (set wds_ssg_res="^!wds_ssg_res:~1,-1^!^!wds_ssg_nd^!"))^&^
        (set wds_ssg_res="^!wds_ssg_res:~1,-1^!^!wds_ssg_add^!")^
       ))^
      ))^&^
      set "wds_ssg_fbp=-1"^
     ) else (^
      set /a "wds_ssg_pos+=^!wds_ssg_pss^!"^>NUL^
     ))^
    ))^&^
    (if ^^^!wds_ssg_pss^^^! LSS 0 (if ^^^!wds_ssg_pos^^^! LSS ^^^!wds_ssg_pse^^^! set "wds_ssg_don=1") else (if ^^^!wds_ssg_pse^^^! LSS ^^^!wds_ssg_pos^^^! set "wds_ssg_don=1"))^
   ))^&^
   set "^!wds_ssg_sn^!=^!wds_ssg_res:~1,-1^!"^
  ))^&^
  (for %%a in (aux,add,bd,bdl,bdn,cnt,don,ed,edl,nd,fbp,pos,psb,pse,pss,qsd,res,nmb,sn,ss,ssl) do (set "wds_ssg_%%a="))^
 ) else (echo Error [@substr_get]: Absent parameters.^&exit /b 1)) else set wds_ssg_aux=

::      @substr_extract - finds substrings of string inside given delimiters and prints (echoes) susbstrings (all or only matched).
::                        %~1 == variable name with source string;
::                        %~2 == left delimiter or variable name with left delimiter of substrings to search;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == right delimiter of substrings (value or name of variable with value);
::                      2:%~4 == number of substrings to search, default is unlimited value;
::                      3:%~5 == substring number in the sequence of matching substrings to start search, negative is from end;
::                      4:%~6 == key value `1` to print only matched substrings, default is `2` to print all parts of string;
::                      5:%~7 == key value `1` to print matched substrings with delimiters, default is `0` to remove them.
::          Dependencies: @echo_params.
::
set @substr_extract=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_spe_aux (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo %%wds_spe_aux%%') do (^
   (if defined %%a if not "%%b"=="" (^
    set "wds_spe_sn=%%~a"^&set "wds_spe_ss=^!%%~a^!"^&(if defined %%~b (set "wds_spe_bd=^!%%~b^!") else (set "wds_spe_bd=%%b"))^
   ))^&^
   set "wds_spe_ed="^&set "wds_spe_qsd=0"^&set "wds_spe_bdn=0"^&set "wds_spe_all=0"^&set "wds_spe_emb=0"^&^
   (if ^^^!wds_spe_emb^^^! NEQ 0 (echo Error [@substr_extract]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for /F "usebackq tokens=*" %%i in (`cmd /d /q /r "^!@echo_params^! 5 %%~c %%~d %%~e %%~f %%~g"`) do if not "%%i"=="" (^
    set "wds_spe_aux=%%i"^&set "wds_spe_cnt=^!wds_spe_aux:~2^!"^&set "wds_spe_aux=^!wds_spe_aux:~0,1^!"^&^
    (if ^^^!wds_spe_aux^^^! EQU 1 (^
     (if defined ^^^!wds_spe_cnt^^^! (call set "wds_spe_ed=%%^!wds_spe_cnt^!%%") else (set "wds_spe_ed=^!wds_spe_cnt^!"))^
    ))^&^
    (if ^^^!wds_spe_aux^^^! EQU 2 (set /a "wds_spe_qsd=^!wds_spe_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_spe_aux^^^! EQU 3 (set /a "wds_spe_bdn=^!wds_spe_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_spe_aux^^^! EQU 4 (set /a "wds_spe_all=^!wds_spe_cnt^!"^>NUL 2^>^&1)^>NUL)^&^
    (if ^^^!wds_spe_aux^^^! EQU 5 (set /a "wds_spe_emb=^!wds_spe_cnt^!"^>NUL 2^>^&1)^>NUL)^
   ))^
  ))^&^
  (for %%a in (wds_spe_ss wds_spe_bd wds_spe_ed) do if defined %%a (^
   set "%%a=^!%%a:/CHR{20}= ^!"^&set "wds_spe_aux=^!%%a^!"^&set "%%al=1"^&^
   (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
    set "wds_spe_sub=^!wds_spe_aux:~%%b,1^!"^&^
    (if defined wds_spe_sub (set "wds_spe_aux=^!wds_spe_aux:~%%b^!"^&set /a "%%al+=%%b"^>NUL))^
   ))^
  ))^&^
  (if not defined wds_spe_ed (set "wds_spe_ed=^!wds_spe_bd^!"^&set "wds_spe_edl=^!wds_spe_bdl^!"))^&^
  (if 0 LSS ^^^!wds_spe_ssl^^^! if 0 LSS ^^^!wds_spe_bdl^^^! (^
   (if ^^^!wds_spe_all^^^! EQU 0 (set "wds_spe_all=2"))^&^
   (if ^^^!wds_spe_all^^^! EQU 2 ((set wds_spe_pst="str=")^&(set wds_spe_psu="sub=")) else ((set wds_spe_pst="")^&(set wds_spe_psu="")))^&^
   (if ^^^!wds_spe_qsd^^^! EQU 0 (set "wds_spe_qsd=1000000"))^&^
   (if ^^^!wds_spe_bdn^^^! EQU 0 (set "wds_spe_bdn=1"))^&^
   (if ^^^!wds_spe_bdn^^^! LSS 0 (^
    set /a "wds_spe_psb=^!wds_spe_ssl^!-1"^>NUL^&set "wds_spe_pss=-1"^&set "wds_spe_pse=0"^&set "wds_spe_bdn=-^!wds_spe_bdn^!"^
   ) else (^
    set "wds_spe_psb=0"^&set "wds_spe_pss=1"^&set /a "wds_spe_pse=^!wds_spe_ssl^!-1"^>NUL^
   ))^&^
   (set wds_spe_sub="")^&set "wds_spe_don=0"^&set "wds_spe_cnt=0"^&^
   set "wds_spe_pfp=^!wds_spe_psb^!"^&set "wds_spe_pos=^!wds_spe_psb^!"^&set "wds_spe_fbp=-1"^&^
   (for /L %%x in (^^^!wds_spe_psb^^^!,^^^!wds_spe_pss^^^!,^^^!wds_spe_pse^^^!) do if ^^^!wds_spe_don^^^! EQU 0 (^
    (if ^^^!wds_spe_fbp^^^! LSS 0 (^
     (call set "wds_spe_aux=%%wds_spe_ss:~^!wds_spe_pos^!,^!wds_spe_bdl^!%%")^&^
     (if "^!wds_spe_aux^!"=="^!wds_spe_bd^!" (^
      set "wds_spe_fbp=^!wds_spe_pos^!"^&^
      (if 0 LSS ^^^!wds_spe_pss^^^! (set /a "wds_spe_pos+=^!wds_spe_bdl^!"^>NUL) else (set /a "wds_spe_pos-=1"^>NUL))^
     ) else (^
      set /a "wds_spe_pos+=^!wds_spe_pss^!"^>NUL^
     ))^
    ) else (^
     call set "wds_spe_aux=%%wds_spe_ss:~^!wds_spe_pos^!,^!wds_spe_edl^!%%"^&^
     (if "^!wds_spe_aux^!"=="^!wds_spe_ed^!" (^
      set /a "wds_spe_cnt+=1"^>NUL^&^
      (if ^^^!wds_spe_pss^^^! LSS 0 (^
       set /a "wds_spe_aux=^!wds_spe_fbp^!+^!wds_spe_bdl^!"^>NUL^&^
       set /a "wds_spe_ssl=^!wds_spe_pfp^!-^!wds_spe_aux^!+1"^>NUL^&^
       (call set "wds_spe_sub=%%wds_spe_ss:~^!wds_spe_aux^!,^!wds_spe_ssl^!%%")^&^
       set /a "wds_spe_ssl=^!wds_spe_fbp^!+^!wds_spe_bdl^!-^!wds_spe_pos^!"^>NUL^&^
       call set "wds_spe_add=%%wds_spe_ss:~^!wds_spe_pos^!,^!wds_spe_ssl^!%%"^&^
       set /a "wds_spe_aux=^!wds_spe_cnt^!-^!wds_spe_bdn^!"^>NUL^&^
       set /a "wds_spe_pos-=1"^>NUL^&^
       (if ^^^!wds_spe_cnt^^^! LSS ^^^!wds_spe_bdn^^^! (^
        (if ^^^!wds_spe_all^^^! EQU 2 (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_add^^^!^^^!wds_spe_sub^^^!))^
       ) else if ^^^!wds_spe_qsd^^^! LEQ ^^^!wds_spe_aux^^^! (^
        (if ^^^!wds_spe_all^^^! EQU 2 (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_add^^^!^^^!wds_spe_sub^^^!))^&^
        set "wds_spe_don=1"^
       ) else (^
        (if ^^^!wds_spe_all^^^! EQU 2 if defined wds_spe_sub (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_sub^^^!))^&^
        (if ^^^!wds_spe_emb^^^! EQU 1 (echo ^^^!wds_spe_psu:~1,-1^^^!^^^!wds_spe_add^^^!) else (call echo ^^^!wds_spe_psu:~1,-1^^^!%%wds_spe_add:~^^^!wds_spe_bdl^^^!,-^^^!wds_spe_edl^^^!%%))^
       ))^
      ) else (^
       set /a "wds_spe_ssl=^!wds_spe_fbp^!-^!wds_spe_pfp^!"^>NUL^&^
       (call set "wds_spe_sub=%%wds_spe_ss:~^!wds_spe_pfp^!,^!wds_spe_ssl^!%%")^&^
       set "wds_spe_aux=^!wds_spe_fbp^!"^&^
       set /a "wds_spe_ssl=^!wds_spe_pos^!+^!wds_spe_edl^!-^!wds_spe_aux^!"^>NUL^&^
       call set "wds_spe_add=%%wds_spe_ss:~^!wds_spe_aux^!,^!wds_spe_ssl^!%%"^&^
       set /a "wds_spe_aux=^!wds_spe_cnt^!-^!wds_spe_bdn^!"^>NUL^&^
       set /a "wds_spe_pos+=^!wds_spe_edl^!"^>NUL^&^
       (if ^^^!wds_spe_cnt^^^! LSS ^^^!wds_spe_bdn^^^! (^
        (if ^^^!wds_spe_all^^^! EQU 2 (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_sub^^^!^^^!wds_spe_add^^^!))^
       ) else if ^^^!wds_spe_qsd^^^! LEQ ^^^!wds_spe_aux^^^! (^
        (if ^^^!wds_spe_all^^^! EQU 2 (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_sub^^^!^^^!wds_spe_add^^^!))^&^
        set "wds_spe_don=1"^
       ) else (^
        (if ^^^!wds_spe_all^^^! EQU 2 if defined wds_spe_sub (echo ^^^!wds_spe_pst:~1,-1^^^!^^^!wds_spe_sub^^^!))^&^
        (if ^^^!wds_spe_emb^^^! EQU 1 (echo ^^^!wds_spe_psu:~1,-1^^^!^^^!wds_spe_add^^^!) else (call echo ^^^!wds_spe_psu:~1,-1^^^!%%wds_spe_add:~^^^!wds_spe_bdl^^^!,-^^^!wds_spe_edl^^^!%%))^
       ))^
      ))^&^
      set "wds_spe_pfp=^!wds_spe_pos^!"^&set "wds_spe_fbp=-1"^
     ) else (^
      set /a "wds_spe_pos+=^!wds_spe_pss^!"^>NUL^
     ))^
    ))^&^
    (if ^^^!wds_spe_pss^^^! LSS 0 (if ^^^!wds_spe_pos^^^! LSS ^^^!wds_spe_pse^^^! set "wds_spe_don=1") else (if ^^^!wds_spe_pse^^^! LSS ^^^!wds_spe_pos^^^! set "wds_spe_don=1"))^
   ))^&^
   (if ^^^!wds_spe_all^^^! EQU 2 (^
    (if ^^^!wds_spe_pss^^^! LSS 0 (^
     if ^^^!wds_spe_pse^^^! LEQ ^^^!wds_spe_pfp^^^! (^
      set /a "wds_spe_ssl=^!wds_spe_pfp^!-^!wds_spe_pse^!+1"^>NUL^&^
      (call echo ^^^!wds_spe_pst:~1,-1^^^!%%wds_spe_ss:~^^^!wds_spe_pse^^^!,^^^!wds_spe_ssl^^^!%%)^
     )^
    ) else (^
     if ^^^!wds_spe_pfp^^^! LEQ ^^^!wds_spe_pse^^^! (^
      set /a "wds_spe_ssl=^!wds_spe_pse^!-^!wds_spe_pfp^!+1"^>NUL^&^
      (call echo ^^^!wds_spe_pst:~1,-1^^^!%%wds_spe_ss:~^^^!wds_spe_pfp^^^!,^^^!wds_spe_ssl^^^!%%)^
     )^
    ))^
   ))^
  ))^&^
  (for %%a in (aux,add,bd,bdl,bdn,all,emb,cnt,don,ed,edl,fbp,pfp,pos,psb,pse,pss,qsd,sn,ss,ssl,pst,psu,sub) do (set "wds_spe_%%a="))^
 ) else (echo Error [@substr_extract]: Absent parameters.^&exit /b 1)) else set wds_spe_aux=

::        @substr_regex - extracts substring of symbols matching regular expression of `findstr.exe` tool.
::                        %~1 == name of variable with original string & to set result;
::                        %~2 == valid regular expression of findstr to search match of symbols in the string (string or variable);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == variable name of calling script to return result instead of `%~1`;
::                      2:%~4 == key parameter `1` to use `%~2` as is without preceding /r key of findstr, default is `0`;
::                      3:%~5 == key parameter `1` to echo result without assigning it, default is `0`.
::                Sample: `%~1 = a1! 3_4` & `%~2 = [0-9]" - gives result `134`.
::                  Note: argument `2:%~4` allows use of custom command line parameters for call of `findstr.exe`.
::
set @substr_regex=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_sgr_aux (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo %%wds_sgr_aux%%') do if "%%~b"=="" (^
   echo Error [@substr_regex]: Missing regular expression parameter.^&exit /b 1^
  ) else (^
   (if defined %%a (^
    set "wds_sgr_scn=%%a"^&set "wds_sgr_scv=^!%%a^!"^&(if defined %%b (set "wds_sgr_reg=^!%%b^!") else (set "wds_sgr_reg=%%b"))^&^
    set "wds_sgr_eco=0"^&set "wds_sgr_cus=0"^&^
    (if ^^^!wds_sgr_cus^^^! NEQ 0 (echo Error [@substr_regex]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (for %%p in (%%~c,%%~d,%%~e) do if not "%%p"=="" (^
     set "wds_sgr_aux=%%p"^&set "wds_sgr_len=^!wds_sgr_aux:~2^!"^&set "wds_sgr_aux=^!wds_sgr_aux:~0,1^!"^&^
     (if ^^^!wds_sgr_aux^^^! EQU 1 (set "wds_sgr_rsn=^!wds_sgr_len^!"))^&^
     (if ^^^!wds_sgr_aux^^^! EQU 2 ((set /a "wds_sgr_cus=^!wds_sgr_len^!"^>NUL 2^>^&1)^>NUL))^&^
     (if ^^^!wds_sgr_aux^^^! EQU 3 ((set /a "wds_sgr_eco=^!wds_sgr_len^!"^>NUL 2^>^&1)^>NUL))^
    ))^&^
    (if not "^!wds_sgr_eco^!"=="0" if not "^!wds_sgr_eco^!"=="1" (set "wds_sgr_eco=0"))^&^
    (if not "^!wds_sgr_cus^!"=="0" if not "^!wds_sgr_cus^!"=="1" (set "wds_sgr_cus=0"))^&^
    (if not defined %%a if defined wds_sgr_rsn (if ^^^!wds_sgr_eco^^^! NEQ 1 (set ^!wds_sgr_rsn^!="") else (echo ^!wds_sgr_rsn^!="")))^
   ))^
  ))^&^
  (if defined wds_sgr_scv (^
   set "wds_sgr_aux=^!wds_sgr_scv^!"^&set "wds_sgr_len=1"^&^
   (for %%d in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
    set "wds_sgr_rsv=^!wds_sgr_aux:~%%d,1^!"^&^
    (if defined wds_sgr_rsv (set "wds_sgr_aux=^!wds_sgr_aux:~%%d^!"^&set /a "wds_sgr_len+=%%d"^>NUL))^
   ))^&^
   set "wds_sgr_rsv="^&^
   (for /L %%a in (1,1,^^^!wds_sgr_len^^^!) do (^
    call set "wds_sgr_aux=%%wds_sgr_scv:~%%a,1%%"^&^
    (if ^^^!wds_sgr_cus^^^! NEQ 1 (^
     (echo.^^^!wds_sgr_aux^^^! ^| findstr /r ^^^!wds_sgr_reg^^^!^>nul ^&^& (^
      (if defined wds_sgr_rsv (set "wds_sgr_rsv=^!wds_sgr_rsv^!^!wds_sgr_aux^!") else (set "wds_sgr_rsv=^!wds_sgr_aux^!"))^
     ))^>NUL^
    ) else (^
     (echo.^^^!wds_sgr_aux^^^! ^| findstr ^^^!wds_sgr_reg^^^!^>nul ^&^& (^
      (if defined wds_sgr_rsv (set "wds_sgr_rsv=^!wds_sgr_rsv^!^!wds_sgr_aux^!") else (set "wds_sgr_rsv=^!wds_sgr_aux^!"))^
     ))^>NUL^
    ))^
   ))^&^
   (if defined wds_sgr_rsv (set wds_sgr_rsv="^!wds_sgr_rsv^!") else (set wds_sgr_rsv=""))^&^
   (if defined wds_sgr_rsn (^
    (if ^^^!wds_sgr_eco^^^! NEQ 1 (set "^!wds_sgr_rsn^!=^!wds_sgr_rsv:~1,-1^!") else (echo "^!wds_sgr_rsn^!=^!wds_sgr_rsv:~1,-1^!"))^
   ) else (^
    (if ^^^!wds_sgr_eco^^^! NEQ 1 (set "^!wds_sgr_scn^!=^!wds_sgr_rsv:~1,-1^!") else (echo "^!wds_sgr_scn^!=^!wds_sgr_rsv:~1,-1^!"))^
   ))^&^
   (if ^^^!wds_sgr_eco^^^! NEQ 1 for %%a in (scn,scv,reg,rsn,rsv,len,cus,eco) do (set "wds_sgr_%%a="))^
  ))^&^
  set "wds_sgr_aux="^
 ) else (echo Error [@substr_regex]: The parameters are absent.^&exit /b 1)) else set wds_sgr_aux=

::            @str_trim - cleans leading & trailing symbols (space, tab & quote) or specific substring instead of quote.
::                        %~1 == the name of external variable with string value.
::                        %~2 == [optional: the name of external variable with additional leading & trailing symbol to remove
::                                          or string symbol to search (arbitrary);
::             Notes. #1: Default empty value corresponds to removing of quotation marks (only leading & trailing);
::                    #2: It will treat undefined external variable as string parameter & will use its 1st symbol as delimiter;
::                    #3: To avoid unwanted deletions of leading & trailing quotes inside string set `" "` as %~2.
::                               ];
::                        %~3 == [optional: key value `1` to echo result instead of assigning, default is `0`].
::
set @str_trim=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_stm_tmp (^
  set wds_stm_tmp=^^^!wds_stm_tmp:" "="/CHR{20}"^^^!^&^
  (for /F "tokens=1,2,3" %%a in ('echo %%wds_stm_tmp%%') do if defined %%a (^
   set "wds_stm_snm=%%a"^&set "wds_stm_sv=^!%%a^!"^&^
   set "wds_stm_su=%%~b"^&^
   (if defined wds_stm_su (set "wds_stm_tmp=^!wds_stm_tmp:/CHR{20}= ^!") else (set wds_stm_su=""^&set "wds_stm_su=^!wds_stm_su:~1^!"))^&^
   set "wds_stm_eco=0"^&^
   (if ^^^!wds_stm_eco^^^! NEQ 0 (echo Error [@str_trim]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set /a "wds_stm_eco=%%~c"^>NUL 2^>^&1)^>NUL^&^
   (if defined wds_stm_sv (^
    (for %%d in (wds_stm_sv wds_stm_su) do (^
     set "wds_stm_tmp=^!%%d^!"^&set "%%dl=1"^&^
     (for %%e in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
      set "wds_stm_don=^!wds_stm_tmp:~%%e,1^!"^&^
      (if defined wds_stm_don (set "wds_stm_tmp=^!wds_stm_tmp:~%%e^!"^&set /a "%%dl+=%%e"^>NUL))^
     ))^
    ))^&^
    set "wds_stm_lft=0"^&set "wds_stm_ldn=0"^&set /a "wds_stm_rgt=^!wds_stm_svl^!-1"^>NUL^&set "wds_stm_rdn=0"^&^
    set /a "wds_stm_svl/=2"^>NUL^&set "wds_stm_don=0"^&^
    (for /L %%x in (0,1,^^^!wds_stm_svl^^^!) do if ^^^!wds_stm_don^^^! EQU 0 (^
     (if ^^^!wds_stm_ldn^^^! EQU 0 (^
      call set "wds_stm_tmp=%%wds_stm_sv:~^!wds_stm_lft^!,1%%"^&set "wds_stm_ldn=1"^&^
      (if "^!wds_stm_tmp^!"==" " (set "wds_stm_ldn=0") else if "^!wds_stm_tmp^!"=="	" (set "wds_stm_ldn=0"))^&^
      (if ^^^!wds_stm_ldn^^^! EQU 1 (^
       call set "wds_stm_tmp=%%wds_stm_sv:~^!wds_stm_lft^!,^!wds_stm_sul^!%%"^&^
       (if "^!wds_stm_tmp^!"=="^!wds_stm_su^!" (set "wds_stm_ldn=0"^&set /a "wds_stm_lft+=^!wds_stm_sul^!"^>NUL))^
      ) else (set /a "wds_stm_lft+=1"^>NUL))^
     ))^&^
     (if ^^^!wds_stm_lft^^^! LSS ^^^!wds_stm_rgt^^^! (^
      (if ^^^!wds_stm_rdn^^^! EQU 0 (^
       call set "wds_stm_tmp=%%wds_stm_sv:~^!wds_stm_rgt^!,1%%"^&set "wds_stm_rdn=1"^&^
       (if "^!wds_stm_tmp^!"==" " (set "wds_stm_rdn=0") else if "^!wds_stm_tmp^!"=="	" (set "wds_stm_rdn=0"))^&^
       (if ^^^!wds_stm_rdn^^^! EQU 1 (^
        set /a "wds_stm_tmp=^!wds_stm_rgt^!-^!wds_stm_sul^!+1"^>NUL^&call set "wds_stm_tmp=%%wds_stm_sv:~^!wds_stm_tmp^!,^!wds_stm_sul^!%%"^&^
        (if "^!wds_stm_tmp^!"=="^!wds_stm_su^!" (set "wds_stm_rdn=0"^&set /a "wds_stm_rgt-=^!wds_stm_sul^!"^>NUL))^
       ) else (set /a "wds_stm_rgt-=1"^>NUL))^
      ))^
     ))^&^
     (if ^^^!wds_stm_rgt^^^! LSS ^^^!wds_stm_lft^^^! (set "wds_stm_don=1") else (set /a "wds_stm_don=^!wds_stm_ldn^!*^!wds_stm_rdn^!"^>NUL))^
    ))^&^
    set /a "wds_stm_rgt+=1-^!wds_stm_lft^!"^>NUL^&^
    (call set wds_stm_sv=%%wds_stm_sv:~^^^!wds_stm_lft^^^!,^^^!wds_stm_rgt^^^!%%)^&^
    (if ^^^!wds_stm_eco^^^! NEQ 1 (^
     set "^!wds_stm_snm^!=^!wds_stm_sv^!"^&(for %%a in (tmp,snm,sv,svl,su,sul,don,lft,ldn,rgt,rdn,eco) do (set "wds_stm_%%a="))^
    ) else (^
     echo "^!wds_stm_snm^!=^!wds_stm_sv^!"^
    ))^
   ))^
  ))^
 ) else (echo Error [@str_trim]: Absent parameters.^&exit /b 1)) else set wds_stm_tmp=

::          @str_encode - encodes basic symbols of string using their hexadecimal ASCII codes.
::                        %~1 == name of variable with original string & to set string value;
::                        %~2 == [optional digital key value:
::                                 `0` - default basic set:            < > ! ^ & | % ( ) \ / { }
::                                 `1` - quotation marks:              "
::                                 `2` - basic set:                    * ? ~ =
::                                 `4` - basic set:                    : ` . '
::                                 `8` - basic set:                    @ $ _ - + # [ ] ; , TABULATION[	]
::                                `16` - space symbols:                 
::                                `32` - english letters (lower case): a b c d e f g h i j k l m n o p q r s t u v w x y z
::                                `64` - english letters (upper case): A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
::                               `128` - digits:                       0 1 2 3 4 5 6 7 8 9
::                                The arithmetic sum of subset values yields their combination.
::                               ];
::                        %~3 == [optional: prefix substring for character code presentation in string, default is "/CHR{"];
::                        %~4 == [optional: suffix substring for character code presentation in string, default is "}"].
::                        %~5 == [optional: key value `1` to echo result instead of assigning, default is `0`].
::  Sample of parameters: VarNameWithSomeString 0 "" "" 1  (default `%~2`, `%~3` & `%~4`, value of `%~5` is `1` for echo).
::          Dependencies: @syms_replace.
::
set @str_encode=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_sen_par (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo %%wds_sen_par%%') do if defined %%a (^
   set "wds_sen_sn=%%~a"^&set "wds_sen_ss=^!%%~a^!"^&^
   (if NOT "^!wds_sen_sn^!"=="%%~a" (echo Error [@str_encode]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "wds_sen_opt=0"^&^(set /a "wds_sen_opt=%%~b"^>NUL 2^>^&1)^>NUL^&^
   set "wds_sen_pfx=%%~c"^&set "wds_sen_sfx=%%~d"^&^
   set "wds_sen_eco=0"^&^(set /a "wds_sen_eco=%%~e"^>NUL 2^>^&1)^>NUL^
  ))^&^
  (if defined wds_sen_ss (^
   (if 128 LEQ ^^^!wds_sen_opt^^^! (set "wds_sen_dts=1"^&(set /a "wds_sen_opt-=128")^>NUL) else (set wds_sen_dts=0))^&^
   (if 64 LEQ ^^^!wds_sen_opt^^^! (set "wds_sen_uls=1"^&(set /a "wds_sen_opt-=64")^>NUL) else (set wds_sen_uls=0))^&^
   (set wds_sen_quot="")^&(call set "wds_sen_quot=%%wds_sen_quot:~1%%")^&(set wds_sen_labr="^^^<")^&(call set "wds_sen_labr=%%wds_sen_labr:~-2,1%%")^&(set wds_sen_rabr="^^^>")^&(call set "wds_sen_rabr=%%wds_sen_rabr:~-2,1%%")^&(set wds_sen_excl="^^^^^!^^^!^^^!")^&(call set "wds_sen_excl=%%wds_sen_excl:~1,-1%%")^&(set wds_sen_care="^^^^")^&(call set "wds_sen_care=%%wds_sen_care:~-2,1%%")^&(set wds_sen_ampe="^^^&")^&(call set "wds_sen_ampe=%%wds_sen_ampe:~-2,1%%")^&(set wds_sen_vbar="^^^|")^&(call set "wds_sen_vbar=%%wds_sen_vbar:~-2,1%%")^&(set wds_sen_perc="^%%")^&(call set "wds_sen_perc=%%wds_sen_perc:~-2,1%%")^&^
   (for %%i in ("\=\\" "{={{" "}=}}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^&^
   call set "wds_sen_ss=^%%wds_sen_ss:^!wds_sen_quot^!=\{JJ}^%%"^&^
   (for %%i in ("^!wds_sen_labr^!=\{KU}" "^!wds_sen_rabr^!=\{KW}" "^!wds_sen_excl^!=\{JI}" "^!wds_sen_ampe^!=\{JN}" "^!wds_sen_vbar^!=\{OU}" "(=\{JP}" ")=\{JQ}" "/=\{JX}" "\\=\{MU}" "}}=\{OV}" "{{=\{OT}") do (call set "wds_sen_ss=%%wds_sen_ss:%%~i%%"^>NUL 2^>^&1))^&^
   (set wds_sen_excl="^^^!")^&(call set "wds_sen_excl=%%wds_sen_excl:~1,-1%%")^&^
   call set "wds_sen_ss=%%wds_sen_ss:^!wds_sen_excl^!=\{JI}%%"^>NUL 2^>^&1^&^
   (for %%i in ("^!wds_sen_care^!=\{MW}" "^!wds_sen_perc^!=\{JM}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^&^
   (if ^^^!wds_sen_dts^^^! EQU 1 for %%i in ("0={0}" "1={1}" "2={2}" "3={3}" "4={4}" "5={5}" "6={6}" "7={7}" "8={8}" "9={9}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^&^
   (if ^^^!wds_sen_uls^^^! EQU 1 (^
    (set wds_sen_par="A={A}" "B={B}" "C={C}" "D={D}" "E={E}" "F={F}")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_sen_ss 1 6 wds_sen_par"') do (set %%a))^
   ))^&^
   (for %%i in ("\{JJ}=\{22}" "\{KU}=\{3C}" "\{KW}=\{3E}" "\{JI}=\{21}" "\{JN}=\{26}" "\{OU}=\{7C}" "\{JP}=\{28}" "\{JQ}=\{29}" "\{JX}=\{2F}" "\{MU}=\{5C}" "\{OT}=\{7B}" "\{OV}=\{7D}" "\{MW}=\{5E}" "\{JM}=\{25}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^&^
   (if ^^^!wds_sen_dts^^^! EQU 1 (^
    (for %%i in ("{0}=\{30}" "{1}=\{31}" "{2}=\{32}" "{3}=\{33}" "{4}=\{34}" "{5}=\{35}" "{6}=\{36}" "{7}=\{37}" "{8}=\{38}" "{9}=\{39}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^
   ))^&^
   (if ^^^!wds_sen_uls^^^! EQU 1 (^
    (for %%i in ("{A}=\{41}" "{B}=\{42}" "{C}=\{43}" "{D}=\{44}" "{E}=\{45}" "{F}=\{46}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^&^
    (set wds_sen_par="G=\{47}" "H=\{48}" "I=\{49}" "J=\{4A}" "K=\{4B}" "L=\{4C}" "M=\{4D}" "N=\{4E}" "O=\{4F}" "P=\{50}" "Q=\{51}" "R=\{52}" "S=\{53}" "T=\{54}" "U=\{55}" "V=\{56}" "W=\{57}" "X=\{58}" "Y=\{59}" "Z=\{5A}")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_sen_ss 1 20 wds_sen_par"') do (set %%a))^
   ))^&^
   (if 32 LEQ ^^^!wds_sen_opt^^^! (^
    set /a "wds_sen_opt-=32"^>NUL^&^
    (set wds_sen_par="a=\{61}" "b=\{62}" "c=\{63}" "d=\{64}" "e=\{65}" "f=\{66}" "g=\{67}" "h=\{68}" "i=\{69}" "j=\{6A}" "k=\{6B}" "l=\{6C}" "m=\{6D}" "n=\{6E}" "o=\{6F}" "p=\{70}" "q=\{71}" "r=\{72}" "s=\{73}" "t=\{74}" "u=\{75}" "v=\{76}" "w=\{77}" "x=\{78}" "y=\{79}" "z=\{7A}")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_sen_ss 1 26 wds_sen_par"') do (set %%a))^
   ))^&^
   (if 16 LEQ ^^^!wds_sen_opt^^^! (((set /a "wds_sen_opt-=16")^>NUL)^&set "wds_sen_ss=^!wds_sen_ss: =\{20}^!"^>NUL 2^>^&1))^&^
   (if 8 LEQ ^^^!wds_sen_opt^^^! (^
    set /a "wds_sen_opt-=8"^>NUL^&^
    (for %%i in ("@=\{40}" "$=\{24}" "_=\{5F}" "-=\{2D}" "+=\{2B}" "#=\{23}" "[=\{5B}" "]=\{5D}" ";=\{3B}" ",=\{2C}" "	=\{09}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^
   ))^&^
   (if 4 LEQ ^^^!wds_sen_opt^^^! (^
    set /a "wds_sen_opt-=4"^>NUL^&(for %%i in (":=\{3A}" "`=\{60}" ".=\{2E}" "'=\{27}") do (set "wds_sen_ss=^!wds_sen_ss:%%~i^!"^>NUL 2^>^&1))^
   ))^&^
   (if 2 LEQ ^^^!wds_sen_opt^^^! (^
    set /a "wds_sen_opt-=2"^>NUL^&^
    (set wds_sen_par="==\{3D}" "~=\{7E}" "?=\{3F}" "*=\{2A}")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_sen_ss 1 4 wds_sen_par"') do (set %%a))^
   ))^&^
   (if ^^^!wds_sen_opt^^^! LSS 1 (call set "wds_sen_ss=^%%wds_sen_ss:\{22}=^!wds_sen_quot^!^%%"))^&^
   (if defined wds_sen_pfx (call set "wds_sen_ss=^%%wds_sen_ss:\{=^!wds_sen_pfx^!^%%"^>NUL 2^>^&1) else (set "wds_sen_ss=^!wds_sen_ss:\{=/CHR{^!"^>NUL 2^>^&1))^&^
   (if defined wds_sen_sfx (call set "wds_sen_ss=^%%wds_sen_ss:}=^!wds_sen_sfx^!^%%"^>NUL 2^>^&1))^&^
   (if ^^^!wds_sen_eco^^^! NEQ 1 (^
    set "^!wds_sen_sn^!=^!wds_sen_ss^!"^>NUL 2^>^&1^&^
    (for %%a in (par,quot,labr,rabr,excl,care,ampe,vbar,perc,sn,ss,opt,pfx,sfx,dts,uls,eco) do (set "wds_sen_%%a="))^
   ) else (^
    echo "^!wds_sen_sn^!=^!wds_sen_ss^!"^
   ))^
  ))^
 ) else (echo Error [@str_encode]: Absent parameters.^&exit /b 1)) else set wds_sen_par=
 
::           @str_clean - removes selected sets of basic symbols from string.
::                        %~1 == name of variable with original string & to set string value;
::                        %~2 == [optional digital key value:
::                                 `0` - default basic set:            < > ! ^ & | % "
::                                 `1` - braces:                       ( )
::                                 `2` - basic set:                    * ? ~ =
::                                 `4` - basic set:                    : \ / ' ` .
::                                 `8` - basic set:                    @ $ _ - + # [ ] { } ; , TABULATION[	]
::                                `16` - space symbols:                 
::                                `32` - english letters (lower case): a b c d e f g h i j k l m n o p q r s t u v w x y z
::                                `64` - english letters (upper case): A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
::                               `128` - digits:                       0 1 2 3 4 5 6 7 8 9
::                               `256` - all code page selection dependent symbols (native languages characters)
::                                The arithmetic sum of subset values yields their combination.
::                               ];
::                        %~3 == [optional: key value `1` to echo result instead of assigning, default is `0`];
::                        %~4 == [optional: key value, valuable only for `256` type of conversion, can have values:
::                                 `1` - the source string encoded in OEM Windows codeset;
::                                 `0` - default value, the source string encoded in active codepage codeset;
::                                 Warning: the invalid value can lead to error in the case of a `256` conversion.
::                               ].
::          Dependencies: @cptooem, @oemtocp, @syms_replace.
::
set @str_clean=^
 for %%u in (1 2) do if %%u EQU 2 (if defined wds_scl_par (^
  (for /F "tokens=1,2,3,4" %%a in ('echo %%wds_scl_par%%') do if defined %%a (^
   set "wds_scl_sn=%%~a"^&set "wds_scl_ss=^!%%~a^!"^&^
   (if NOT "^!wds_scl_sn^!"=="%%~a" (echo Error [@str_clean]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "wds_scl_opt=0"^&(set /a "wds_scl_opt=%%~b"^>NUL 2^>^&1)^&^
   (if "%%~c"=="1" (set "wds_scl_eco=1") else (set "wds_scl_eco=0"))^&^
   (if "%%~d"=="1" (set "wds_scl_oem=oemtocp") else (set "wds_scl_oem=cptooem"))^
  ))^&^
  (if defined wds_scl_ss (^
   (if 256 LEQ ^^^!wds_scl_opt^^^! (set "wds_scl_loc=1"^&(set /a "wds_scl_opt-=256")^>NUL) else (set wds_scl_loc=0))^&^
   (if 128 LEQ ^^^!wds_scl_opt^^^! (set "wds_scl_dts=1"^&(set /a "wds_scl_opt-=128")^>NUL) else (set wds_scl_dts=0))^&^
   (if 64 LEQ ^^^!wds_scl_opt^^^! (set "wds_scl_uls=1"^&(set /a "wds_scl_opt-=64")^>NUL) else (set wds_scl_uls=0))^&^
   (if 32 LEQ ^^^!wds_scl_opt^^^! (set "wds_scl_lls=1"^&(set /a "wds_scl_opt-=32")^>NUL) else (set wds_scl_lls=0))^&^
   (set wds_scl_quot="")^&(call set "wds_scl_quot=%%wds_scl_quot:~1%%")^&(set wds_scl_labr="^^^<")^&(call set "wds_scl_labr=%%wds_scl_labr:~-2,1%%")^&(set wds_scl_rabr="^^^>")^&(call set "wds_scl_rabr=%%wds_scl_rabr:~-2,1%%")^&(set wds_scl_excl="^^^^^!^^^!^^^!")^&(call set "wds_scl_excl=%%wds_scl_excl:~1,-1%%")^&(set wds_scl_care="^^^^")^&(call set "wds_scl_care=%%wds_scl_care:~-2,1%%")^&(set wds_scl_ampe="^^^&")^&(call set "wds_scl_ampe=%%wds_scl_ampe:~-2,1%%")^&(set wds_scl_vbar="^^^|")^&(call set "wds_scl_vbar=%%wds_scl_vbar:~-2,1%%")^&(set wds_scl_perc="^%%")^&(call set "wds_scl_perc=%%wds_scl_perc:~-2,1%%")^&^
   call set "wds_scl_ss=^%%wds_scl_ss:^!wds_scl_quot^!=^%%"^&^
   (if defined wds_scl_ss for %%i in ("^!wds_scl_labr^!=" "^!wds_scl_rabr^!=" "^!wds_scl_excl^!=" "^!wds_scl_ampe^!=" "^!wds_scl_vbar^!=") do if defined wds_scl_ss (call set "wds_scl_ss=%%wds_scl_ss:%%~i%%"^>NUL 2^>^&1))^&^
   (set wds_scl_excl="^^^!")^&(call set "wds_scl_excl=%%wds_scl_excl:~1,-1%%")^&^
   call set "wds_scl_ss=%%wds_scl_ss:^!wds_sen_excl^!=%%"^>NUL 2^>^&1^&^
   (if defined wds_scl_ss for %%i in ("^!wds_scl_care^!=" "^!wds_scl_perc^!=") do (set "wds_scl_ss=^!wds_scl_ss:%%~i^!"^>NUL 2^>^&1))^&^
   ((set /a "wds_scl_brc=^!wds_scl_opt^!/2")^>NUL)^&((set /a "wds_scl_brc=^!wds_scl_opt^!-2*^!wds_scl_brc^!")^>NUL)^&^
   (if defined wds_scl_ss if ^^^!wds_scl_brc^^^! EQU 1 (for %%i in ("(=" ")=") do if defined wds_scl_ss (call set "wds_scl_ss=%%wds_scl_ss:%%~i%%"^>NUL 2^>^&1)))^&^
   (if defined wds_scl_ss if ^^^!wds_scl_dts^^^! EQU 1 (for %%i in ("0=" "1=" "2=" "3=" "4=" "5=" "6=" "7=" "8=" "9=") do if defined wds_scl_ss (set "wds_scl_ss=^!wds_scl_ss:%%~i^!"^>NUL 2^>^&1)))^&^
   (if defined wds_scl_ss (^
    (if ^^^!wds_scl_uls^^^! EQU 1 (^
     (if ^^^!wds_scl_lls^^^! EQU 1 (^
      (for %%i in ("a=" "b=" "c=" "d=" "e=" "f=" "g=" "h=" "i=" "j=" "k=" "l=" "m=" "n=" "o=" "p=" "q=" "r=" "s=" "t=" "u=" "v=" "w=" "x=" "y=" "z=") do if defined wds_scl_ss (set "wds_scl_ss=^!wds_scl_ss:%%~i^!"^>NUL 2^>^&1))^
     ) else (^
      (set wds_scl_par="A=" "B=" "C=" "D=" "E=" "F=" "G=" "H=" "I=" "J=" "K=" "L=" "M=" "N=" "O=" "P=" "Q=" "R=" "S=" "T=" "U=" "V=" "W=" "X=" "Y=" "Z=")^&^
      (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_scl_ss 1 26 wds_scl_par"') do (set %%a))^
     ))^
    ) else if ^^^!wds_scl_lls^^^! EQU 1 (^
     (set wds_scl_par="a=" "b=" "c=" "d=" "e=" "f=" "g=" "h=" "i=" "j=" "k=" "l=" "m=" "n=" "o=" "p=" "q=" "r=" "s=" "t=" "u=" "v=" "w=" "x=" "y=" "z=")^&^
     (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_scl_ss 1 26 wds_scl_par"') do (set %%a))^
    ))^
   ))^&^
   (if defined wds_scl_ss if 16 LEQ ^^^!wds_scl_opt^^^! (set /a "wds_scl_opt-=16"^&set "wds_scl_ss=^!wds_scl_ss: =^!")^>NUL 2^>^&1)^&^
   (if defined wds_scl_ss if 8 LEQ ^^^!wds_scl_opt^^^! (^
    set /a "wds_scl_opt-=8"^>NUL^&^
    (for %%i in ("@=" "$=" "_=" "-=" "+=" "#=" "[=" "]=" "{=" "}=" ";=" ",=" "	=") do if defined wds_scl_ss (set "wds_scl_ss=^!wds_scl_ss:%%~i^!"^>NUL 2^>^&1))^
   ))^&^
   (if defined wds_scl_ss if 4 LEQ ^^^!wds_scl_opt^^^! (^
    set /a "wds_scl_opt-=4"^>NUL^&^
    (for %%i in (":=" "\=" "/="  "'=" "`=" ".=") do if defined wds_scl_ss (set "wds_scl_ss=^!wds_scl_ss:%%~i^!"^>NUL 2^>^&1))^
   ))^&^
   (if defined wds_scl_ss if 2 LEQ ^^^!wds_scl_opt^^^! (^
    set /a "wds_scl_opt-=2"^>NUL^&^
    (set wds_scl_par="==" "~=" "?=" "*=")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_scl_ss 1 4 wds_scl_par"') do (set %%a))^
   ))^&^
   (if defined wds_scl_ss if ^^^!wds_scl_loc^^^! EQU 1 (^
    set "wds_scl_loc=^!wds_scl_ss^!"^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /r "%%@^!wds_scl_oem^!%% wds_scl_loc wds_scl_loc 1"') do (set %%a))^&^
    set "wds_scl_brc=^!wds_scl_ss^!"^&set "wds_scl_opt=0"^&^
    (for %%a in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     set "wds_scl_uls=^!wds_scl_ss:~%%a,1^!"^&^
     (if defined wds_scl_uls (set "wds_scl_ss=^!wds_scl_ss:~%%a^!"^&set /a "wds_scl_opt+=%%a"^>NUL))^
    ))^&^
    set "wds_scl_ss="^&^
    (for /L %%a in (0,1,^^^!wds_scl_opt^^^!) do (^
     set "wds_scl_uls=^!wds_scl_loc:~%%a,1^!"^&^
     (if defined wds_scl_uls if "^!wds_scl_uls^!"=="^!wds_scl_brc:~%%a,1^!" if defined wds_scl_ss (^
      set "wds_scl_ss=^!wds_scl_ss^!^!wds_scl_uls^!"^
     ) else (^
      set "wds_scl_ss=^!wds_scl_uls^!"^
     ))^
    ))^
   ))^&^
   (if not defined wds_scl_ss (set wds_scl_ss=""))^&^
   (if ^^^!wds_scl_eco^^^! NEQ 1 (^
    set "^!wds_scl_sn^!=^!wds_scl_ss^!"^>NUL 2^>^&1^&^
    (for %%a in (eco,sn,ss,opt,uls,lls,brc,dts,oem,loc,quot,labr,rabr,excl,care,ampe,vbar,perc) do (set "wds_scl_%%a="))^
   ) else (^
    (echo "^!wds_scl_sn^!=^!wds_scl_ss^!")^
   ))^
  ))^&^
  set "wds_scl_par="^
 ) else (echo Error [@str_clean]: Absent parameters.^&exit /b 1)) else set wds_scl_par=
 
::           @str_plate - overwites selected sets of basic symbols of string by the new specified symbol or string.
::                        %~1 == name of variable with original string & to set string value;
::                        %~2 == explicit quoted string to overwrite, supports `/CHR{20}` as space symbol;
::                        %~3 == [optional digital key value:
::                                 `0` - default basic set:            < > ! ^ & | % "
::                                 `1` - braces:                       ( )
::                                 `2` - basic set:                    * ? ~ =
::                                 `4` - basic set:                    : \ / ' ` .
::                                 `8` - basic set:                    @ $ _ - + # [ ] { } ; , TABULATION[	]
::                                `16` - space symbols:                 
::                                `32` - english letters (lower case): a b c d e f g h i j k l m n o p q r s t u v w x y z
::                                `64` - english letters (upper case): A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
::                               `128` - digits:                       0 1 2 3 4 5 6 7 8 9
::                               `256` - all code page selection dependent symbols (native languages characters)
::                                The arithmetic sum of subset values yields their combination.
::                               ];
::                        %~4 == [optional: key value to specify the result report:
::                                 `0` - default value, set variable name for calling context;
::                                 `1` - echo value as "<variable name>=<string value>";
::                                 `2` - echo value as "<string value>".
::                               ];
::                        %~5 == [optional: key value, valuable only for `256` type of conversion, can have values:
::                                 `1` - the source string encoded in OEM Windows codeset;
::                                 `0` - default value, the source string encoded in active codepage codeset;
::                                 Warning: the invalid value can lead to error in the case of a `256` conversion.
::                               ];
::                        %~6 == [optional: explicit string in quoted CSV format with custom substrings to replace].
::          Dependencies: @cptooem, @oemtocp, @syms_replace.
::
set @str_plate=^
 for %%u in (1 2) do if %%u EQU 2 (if defined wds_sps_par for /F %%y in ('echo wds_sps_') do (^
  (for /F "tokens=1,2,3,4,5,6" %%a in ('echo %%%%ypar%%') do if defined %%a (^
   set "%%ysn=%%~a"^&set "%%yss=^!%%~a^!"^&^
   (if NOT "^!%%ysn^!"=="%%~a" (echo Error [@str_plate]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if NOT "%%~b"==%%b (echo Error [@str_plate]: Expected quoted string in 2nd parameter.^&exit /b 1))^&^
   set "%%yopt=0"^&(set /a "%%yopt=%%~c"^>NUL 2^>^&1)^&^
   (if "%%~d"=="2" (set "%%yeco=2") else if "%%~d"=="1" (set "%%yeco=1") else (set "%%yeco=0"))^&^
   (if "%%~e"=="1" (set "%%yoem=oemtocp") else (set "%%yoem=cptooem"))^&^
   (if defined %%yss (^
    (if 256 LEQ ^^^!%%yopt^^^! (set "%%yloc=1"^&(set /a "%%yopt-=256")^>NUL) else (set %%yloc=0))^&^
    (if 128 LEQ ^^^!%%yopt^^^! (set "%%ydts=1"^&(set /a "%%yopt-=128")^>NUL) else (set %%ydts=0))^&^
    (if 64 LEQ ^^^!%%yopt^^^! (set "%%yuls=1"^&(set /a "%%yopt-=64")^>NUL) else (set %%yuls=0))^&^
    (if 32 LEQ ^^^!%%yopt^^^! (set "%%ylls=1"^&(set /a "%%yopt-=32")^>NUL) else (set %%ylls=0))^&^
    (set %%yquot="")^&(call set "%%yquot=%%%%yquot:~1%%")^&(set %%ylabr="^^^<")^&(call set "%%ylabr=%%%%ylabr:~-2,1%%")^&(set %%yrabr="^^^>")^&(call set "%%yrabr=%%%%yrabr:~-2,1%%")^&(set %%yexcl="^^^^^!^^^!^^^!")^&(call set "%%yexcl=%%%%yexcl:~1,-1%%")^&(set %%ycare="^^^^")^&(call set "%%ycare=%%%%ycare:~-2,1%%")^&(set %%yampe="^^^&")^&(call set "%%yampe=%%%%yampe:~-2,1%%")^&(set %%yvbar="^^^|")^&(call set "%%yvbar=%%%%yvbar:~-2,1%%")^&(set %%yperc="^%%")^&(call set "%%yperc=%%%%yperc:~-2,1%%")^&^
    call set "%%yss=^%%%%yss:^!%%yquot^!=%%~b^%%"^&^
    (if defined %%yss for %%i in ("^!%%ylabr^!=%%~b" "^!%%yrabr^!=%%~b" "^!%%yexcl^!=%%~b" "^!%%yampe^!=%%~b" "^!%%yvbar^!=%%~b") do if defined %%yss (call set "%%yss=%%%%yss:%%~i%%"^>NUL 2^>^&1))^&^
    (set %%yexcl="^^^!")^&(call set "%%yexcl=%%%%yexcl:~1,-1%%")^&^
    call set "%%yss=%%%%yss:^!wds_sen_excl^!=%%"^>NUL 2^>^&1^&^
    (if defined %%yss for %%i in ("^!%%ycare^!=%%~b" "^!%%yperc^!=%%~b") do (set "%%yss=^!%%yss:%%~i^!"^>NUL 2^>^&1))^&^
    ((set /a "%%ybrc=^!%%yopt^!/2")^>NUL)^&((set /a "%%ybrc=^!%%yopt^!-2*^!%%ybrc^!")^>NUL)^&^
    (if defined %%yss if ^^^!%%ybrc^^^! EQU 1 (for %%i in ("(=%%~b" ")=%%~b") do if defined %%yss (call set "%%yss=%%%%yss:%%~i%%"^>NUL 2^>^&1)))^&^
    (if defined %%yss if ^^^!%%ydts^^^! EQU 1 (for %%i in ("0=%%~b" "1=%%~b" "2=%%~b" "3=%%~b" "4=%%~b" "5=%%~b" "6=%%~b" "7=%%~b" "8=%%~b" "9=%%~b") do if defined %%yss (set "%%yss=^!%%yss:%%~i^!"^>NUL 2^>^&1)))^&^
    (if defined %%yss (^
     (if ^^^!%%yuls^^^! EQU 1 (^
      (if ^^^!%%ylls^^^! EQU 1 (^
       (for %%i in ("a=%%~b" "b=%%~b" "c=%%~b" "d=%%~b" "e=%%~b" "f=%%~b" "g=%%~b" "h=%%~b" "i=%%~b" "j=%%~b" "k=%%~b" "l=%%~b" "m=%%~b" "n=%%~b" "o=%%~b" "p=%%~b" "q=%%~b" "r=%%~b" "s=%%~b" "t=%%~b" "u=%%~b" "v=%%~b" "w=%%~b" "x=%%~b" "y=%%~b" "z=%%~b") do if defined %%yss (set "%%yss=^!%%yss:%%~i^!"^>NUL 2^>^&1))^
      ) else (^
       (set %%ypar="A=%%~b" "B=%%~b" "C=%%~b" "D=%%~b" "E=%%~b" "F=%%~b" "G=%%~b" "H=%%~b" "I=%%~b" "J=%%~b" "K=%%~b" "L=%%~b" "M=%%~b" "N=%%~b" "O=%%~b" "P=%%~b" "Q=%%~b" "R=%%~b" "S=%%~b" "T=%%~b" "U=%%~b" "V=%%~b" "W=%%~b" "X=%%~b" "Y=%%~b" "Z=%%~b")^&^
       (for /F "tokens=*" %%i in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! %%yss 1 26 %%ypar"') do (set %%i))^
      ))^
     ) else if ^^^!%%ylls^^^! EQU 1 (^
      (set %%ypar="a=%%~b" "b=%%~b" "c=%%~b" "d=%%~b" "e=%%~b" "f=%%~b" "g=%%~b" "h=%%~b" "i=%%~b" "j=%%~b" "k=%%~b" "l=%%~b" "m=%%~b" "n=%%~b" "o=%%~b" "p=%%~b" "q=%%~b" "r=%%~b" "s=%%~b" "t=%%~b" "u=%%~b" "v=%%~b" "w=%%~b" "x=%%~b" "y=%%~b" "z=%%~b")^&^
      (for /F "tokens=*" %%i in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! %%yss 1 26 %%ypar"') do (set %%i))^
     ))^
    ))^&^
    (if defined %%yss if 16 LEQ ^^^!%%yopt^^^! (set /a "%%yopt-=16"^&set "%%yss=^!%%yss: =^!")^>NUL 2^>^&1)^&^
    (if defined %%yss if 8 LEQ ^^^!%%yopt^^^! (^
     set /a "%%yopt-=8"^>NUL^&^
     (for %%i in ("@=%%~b" "$=%%~b" "_=%%~b" "-=%%~b" "+=%%~b" "#=%%~b" "[=%%~b" "]=%%~b" "{=%%~b" "}=%%~b" ";=%%~b" ",=%%~b" "	=%%~b") do if defined %%yss (set "%%yss=^!%%yss:%%~i^!"^>NUL 2^>^&1))^
    ))^&^
    (if defined %%yss if 4 LEQ ^^^!%%yopt^^^! (^
     set /a "%%yopt-=4"^>NUL^&^
     (for %%i in (":=%%~b" "\=%%~b" "/=%%~b" "'=%%~b" "`=%%~b" ".=%%~b") do if defined %%yss (set "%%yss=^!%%yss:%%~i^!"^>NUL 2^>^&1))^
    ))^&^
    (if defined %%yss if 2 LEQ ^^^!%%yopt^^^! (^
     set /a "%%yopt-=2"^>NUL^&^
     (set %%ypar="==%%~b" "~=%%~b" "?=%%~b" "*=%%~b")^&^
     (for /F "tokens=*" %%i in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! %%yss 1 4 %%ypar"') do (set %%i))^
    ))^&^
    (if defined %%yss if ^^^!%%yloc^^^! EQU 1 (^
     set "%%yloc=^!%%yss^!"^&^
     (for /F "tokens=*" %%i in ('cmd /d /q /r "%%@^!%%yoem^!%% %%yloc %%yloc 1"') do (set %%i))^&^
     set "%%ybrc=^!%%yss^!"^&set "%%yopt=0"^&^
     (for %%i in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
      set "%%yuls=^!%%yss:~%%i,1^!"^&^
      (if defined %%yuls (set "%%yss=^!%%yss:~%%i^!"^&set /a "%%yopt+=%%i"^>NUL))^
     ))^&^
     set "%%yss="^&^
     (for /L %%i in (0,1,^^^!%%yopt^^^!) do (^
      set "%%yuls=^!%%yloc:~%%i,1^!"^&^
      (if defined %%yuls if "^!%%yuls^!"=="^!%%ybrc:~%%i,1^!" if defined %%yss (^
       set "%%yss=^!%%yss^!^!%%yuls^!"^
      ) else (^
       set "%%yss=^!%%yuls^!"^
      ))^
     ))^
    ))^&^
    (if defined %%yss (^
     (for %%i in (%%f) do (call set "%%yss=%%%%yss:%%~i=%%~b%%"))^&^
     set "%%yss=^!%%yss:/CHR{20}= ^!"^
    ) else (set %%yss=""))^&^
    (if ^^^!%%yeco^^^! EQU 2 (echo ^^^!%%yss^^^!) else if ^^^!%%yeco^^^! EQU 1 (echo "^!%%ysn^!=^!%%yss^!") else (^
     set "^!%%ysn^!=^!%%yss^!"^>NUL 2^>^&1^&^
     (for %%i in (eco,sn,ss,opt,uls,lls,brc,dts,oem,loc,quot,labr,rabr,excl,care,ampe,vbar,perc) do (set "%%y%%i="))^
    ))^
   ))^
  ))^&^
  set "%%ypar="^
 ) else (echo Error [@str_plate]: Absent parameters.^&exit /b 1)) else set wds_sps_par=

::          @str_decode - replaces pseudo tags with codes by corresponding symbols of string.
::                        %~1 == name of variable with original string & to set string value;
::                        %~2 == [optional: prefix substring of the character code presentation in string, default is "/CHR{"];
::                        %~3 == [optional: suffix substring of the character code presentation in string, default is "}"];
::                        %~4 == [optional: key value `1` to echo result instead of assigning, default is `0`].
::                  Note: It expects quoted source string in the variable of parameter `%~1`.
::  Sample of parameters: VarNameWithSomeString "" "" 1  (default `%~2` and `%~3`, value of `%~4` is `1` for echo).
::
set @str_decode=^
 for %%u in (1 2) do if %%u EQU 2 (if defined wds_sde_par (^
  (for /F "tokens=1,2,3,4" %%a in ('echo %%wds_sde_par%%') do if defined %%a (^
   set "wds_sde_sn=%%~a"^&set "wds_sde_ss=^!%%~a^!"^&^
   (if NOT "^!wds_sde_sn^!"=="%%~a" (echo Error [@str_decode]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if "%%~b"=="" (set "wds_sde_pf=/CHR{"^&set "wds_sde_pfl=5") else (set "wds_sde_pf=%%~b"^&set "wds_sde_pfl=-1"))^&^
   (if "%%~c"=="" (set "wds_sde_sf=}"^&set "wds_sde_sfl=1") else (set "wds_sde_sf=%%~c"^&set "wds_sde_sfl=-1"))^&^
   set "wds_sde_eco=0"^&(set /a "wds_sde_eco=%%~d"^>NUL 2^>^&1)^>NUL^
  ))^&^
  (if defined wds_sde_ss (^
   (for %%a in ("7B^!wds_sde_sf^!={" "7D^!wds_sde_sf^!=}" "23^!wds_sde_sf^!=#" "24^!wds_sde_sf^!=$" "3A^!wds_sde_sf^!=:" "3B^!wds_sde_sf^!=;" "5B^!wds_sde_sf^!=[" "5D^!wds_sde_sf^!=]" "5F^!wds_sde_sf^!=_" "60^!wds_sde_sf^!=`" "20^!wds_sde_sf^!= " "27^!wds_sde_sf^!='" "2B^!wds_sde_sf^!=+" "2C^!wds_sde_sf^!=," "2D^!wds_sde_sf^!=-" "2E^!wds_sde_sf^!=." "09^!wds_sde_sf^!=	" "40^!wds_sde_sf^!=@" "3D^!wds_sde_sf^!==" "5C^!wds_sde_sf^!=\" "2F^!wds_sde_sf^!=/" "7E^!wds_sde_sf^!=~" "28^!wds_sde_sf^!=(" "30^!wds_sde_sf^!=0" "31^!wds_sde_sf^!=1" "32^!wds_sde_sf^!=2" "33^!wds_sde_sf^!=3" "34^!wds_sde_sf^!=4" "35^!wds_sde_sf^!=5" "36^!wds_sde_sf^!=6" "37^!wds_sde_sf^!=7" "38^!wds_sde_sf^!=8" "39^!wds_sde_sf^!=9" "41^!wds_sde_sf^!=A" "42^!wds_sde_sf^!=B" "43^!wds_sde_sf^!=C" "44^!wds_sde_sf^!=D" "45^!wds_sde_sf^!=E" "46^!wds_sde_sf^!=F" "47^!wds_sde_sf^!=G" "48^!wds_sde_sf^!=H" "49^!wds_sde_sf^!=I" "4A^!wds_sde_sf^!=J" "4B^!wds_sde_sf^!=K" "4C^!wds_sde_sf^!=L" "4D^!wds_sde_sf^!=M" "4E^!wds_sde_sf^!=N" "4F^!wds_sde_sf^!=O" "50^!wds_sde_sf^!=P" "51^!wds_sde_sf^!=Q" "52^!wds_sde_sf^!=R" "53^!wds_sde_sf^!=S" "54^!wds_sde_sf^!=T" "55^!wds_sde_sf^!=U" "56^!wds_sde_sf^!=V" "57^!wds_sde_sf^!=W" "58^!wds_sde_sf^!=X" "59^!wds_sde_sf^!=Y" "5A^!wds_sde_sf^!=Z" "61^!wds_sde_sf^!=a" "62^!wds_sde_sf^!=b" "63^!wds_sde_sf^!=c" "64^!wds_sde_sf^!=d" "65^!wds_sde_sf^!=e" "66^!wds_sde_sf^!=f" "67^!wds_sde_sf^!=g" "68^!wds_sde_sf^!=h" "69^!wds_sde_sf^!=i" "6A^!wds_sde_sf^!=j" "6B^!wds_sde_sf^!=k" "6C^!wds_sde_sf^!=l" "6D^!wds_sde_sf^!=m" "6E^!wds_sde_sf^!=n" "6F^!wds_sde_sf^!=o" "70^!wds_sde_sf^!=p" "71^!wds_sde_sf^!=q" "72^!wds_sde_sf^!=r" "73^!wds_sde_sf^!=s" "74^!wds_sde_sf^!=t" "75^!wds_sde_sf^!=u" "76^!wds_sde_sf^!=v" "77^!wds_sde_sf^!=w" "78^!wds_sde_sf^!=x" "79^!wds_sde_sf^!=y" "7A^!wds_sde_sf^!=z") do (^
    (call set "wds_sde_ss=%%wds_sde_ss:^!wds_sde_pf^!%%~a%%"^>NUL 2^>^&1)^
   ))^&^
   (set wds_sde_quo="")^&(call set "wds_sde_quo=%%wds_sde_quo:~1%%")^&(set wds_sde_lab="^^^<")^&(call set "wds_sde_lab=%%wds_sde_lab:~-2,1%%")^&(set wds_sde_rab="^^^>")^&(call set "wds_sde_rab=%%wds_sde_rab:~-2,1%%")^&(set wds_sde_amp="^^^&")^&(call set "wds_sde_amp=%%wds_sde_amp:~-2,1%%")^&(set wds_sde_bar="^^^|")^&(call set "wds_sde_bar=%%wds_sde_bar:~-2,1%%")^&(set wds_sde_per="^%%")^&(call set "wds_sde_per=%%wds_sde_per:~1,-1%%")^&^
   (set wds_sde_car="^^^^")^&^
   (if ^^^!wds_sde_eco^^^! NEQ 1 (^
    (call set "wds_sde_car=%%wds_sde_car:~-2,1%%")^&set "wds_sde_exc=^^^^^!^^^!^^^!"^
   ) else (^
    (call set "wds_sde_car=%%wds_sde_car:~-2,1%%%%wds_sde_car:~-2,1%%")^&set "wds_sde_exc="^
   ))^&^
   (call set "wds_sde_ss=%%wds_sde_ss:^!wds_sde_quo^!=^!wds_sde_pf^!22^!wds_sde_sf^!%%"^>NUL 2^>^&1)^&^
   (call set "wds_sde_ss=%%wds_sde_ss:^)=^!wds_sde_pf^!29^!wds_sde_sf^!%%"^>NUL 2^>^&1)^&^
   (call set "wds_sde_ss=%%wds_sde_ss:^!wds_sde_pf^!3F^!wds_sde_sf^!=?%%"^>NUL 2^>^&1)^&^
   (call set "wds_sde_ss=%%wds_sde_ss:^!wds_sde_pf^!2A^!wds_sde_sf^!=*%%"^>NUL 2^>^&1)^&^
   (call set wds_sde_ss=" %%wds_sde_ss:^!wds_sde_pf^!=)^!wds_sde_pf^!%%"^>NUL 2^>^&1)^&^
   (for %%a in (wds_sde_pf wds_sde_sf) do if ^^^!%%al^^^! LSS 0 (^
    set "wds_sde_sel=^!%%a^!"^&set "%%al=1"^&^
    (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     set "wds_sde_res=^!wds_sde_sel:~%%b,1^!"^&^
     (if defined wds_sde_res (set "wds_sde_sel=^!wds_sde_sel:~%%b^!"^&set /a "%%al+=%%b"^>NUL))^
    ))^
   ))^&^
   (set /a "wds_sde_sfb=^!wds_sde_pfl^!+2"^>NUL)^&(set /a "wds_sde_len=^!wds_sde_sfb^!+^!wds_sde_sfl^!"^>NUL)^&^
   (set wds_sde_sel="(for /L %%^^n in (1 1 2048000) do (if defined wds_sde_loc (for /F $wds_sde_quo$usebackq tokens=1,* delims=^)$wds_sde_quo$ %%^^x in (`call echo. ^%%wds_sde_loc^%%`) do ((call echo wds_sde beg %%^^x)$wds_sde_amp$(call echo wds_sde end %%^^y)$wds_sde_amp$(set wds_sde_loc=%%^^y)$wds_sde_amp$(if defined wds_sde_loc (call set wds_sde_loc=^%%wds_sde_loc:~^!wds_sde_len^!^%%)))) else if %%^^n LEQ 2 (call set $wds_sde_quo$wds_sde_loc=^%%wds_sde_ss:~1,-1^%%$wds_sde_quo$) else (exit /b 0)))")^&^
   (call set wds_sde_sel=%%wds_sde_sel:$wds_sde_quo$=^^^!wds_sde_quo^^^!%%)^&^
   (call set wds_sde_sel=%%wds_sde_sel:$wds_sde_amp$=^^^!wds_sde_amp^^^!%%)^&set "wds_sde_res= "^&^
   (for /F "usebackq tokens=*" %%a in (`cmd /d /q /r ^^^!wds_sde_sel^^^!`) do (^
    set "wds_sde_par=%%a"^&^
    (if defined wds_sde_par if "^!wds_sde_par:~0,7^!"=="wds_sde" (^
     (if "^!wds_sde_par:~8,3^!"=="beg" (^
      (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_par:~13^^^!)^
     ) else (^
      set "wds_sde_ss=^!wds_sde_par:~12^!"^&^
      (if defined wds_sde_ss (^
       (call set "wds_sde_par=%%wds_sde_ss:~^!wds_sde_sfb^!,^!wds_sde_sfl^!%%"^>NUL 2^>^&1)^&^
       (if "^!wds_sde_par^!"=="^!wds_sde_sf^!" (^
        set "wds_sde_par=0"^&^
        (call set "wds_sde_ss=%%wds_sde_ss:~^!wds_sde_pfl^!,2%%"^>NUL 2^>^&1)^&^
        (if       "^!wds_sde_ss^!"=="22" (^
         set "wds_sde_par=1"^&^
         (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_quo^^^!)^
        ) else if "^!wds_sde_ss^!"=="5E" (^
         set "wds_sde_par=1"^&^
         (call set wds_sde_res=%%wds_sde_res%%%%wds_sde_car%%)^
        ) else if "^!wds_sde_ss^!"=="21" (^
         set "wds_sde_par=1"^&^
         (if ^^^!wds_sde_eco^^^! NEQ 1 (^
          (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_pf^^^!21^^^!wds_sde_sf^^^!)^
         ) else (^
          (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_exc^^^!)^
         ))^
        ) else for %%d in ("25=wds_sde_per" "26=wds_sde_amp" "7C=wds_sde_bar" "3C=wds_sde_lab" "3E=wds_sde_rab" "29=)") do (^
         (call set wds_sde_sel=%%~d)^&^
         (if "^!wds_sde_ss^!"=="^!wds_sde_sel:~0,2^!" (^
          set "wds_sde_par=1"^&^
          (if defined ^^^!wds_sde_sel:~3^^^! (^
           (call set wds_sde_res=%%wds_sde_res%%%%^^^!wds_sde_sel:~3^^^!%%)^
          ) else (^
           (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_sel:~3^^^!)^
          ))^
         ))^
        ))^&^
        (if ^^^!wds_sde_par^^^! EQU 0 (call set wds_sde_res=%%wds_sde_res%%^^^!wds_sde_pf^^^!^^^!wds_sde_ss^^^!^^^!wds_sde_sf^^^!))^
       ) else (call set wds_sde_res=%%wds_sde_res%%%%wds_sde_ss:~0,^^^!wds_sde_len^^^!%%))^
      ))^
     ))^
    ))^
   ))^&^
   (set wds_sde_res=^^^!wds_sde_res:~2^^^!)^>NUL 2^>^&1^&^
   (if ^^^!wds_sde_eco^^^! NEQ 1 (^
    (for /F "tokens=*" %%a in ('echo."%%wds_sde_pf%%21%%wds_sde_sf%%=%%wds_sde_exc%%"') do (^
     (call set wds_sde_res=%%wds_sde_res:%%~a%%)^>NUL 2^>^&1^
    ))^&^
    (set ^^^!wds_sde_sn^^^!=^^^!wds_sde_res^^^!)^>NUL 2^>^&1^&^
    (for %%a in (res,sel,sfb,pfl,sfl,eco,quo,lab,len,rab,exc,car,amp,bar,per) do (set "wds_sde_%%a="))^
   ) else (^
    set ^^^!wds_sde_sn^^^!=^^^!wds_sde_res^^^!^>NUL 2^>^&1^&^
    echo "wds_sde_exc=^^^^^^^^^^^^!^^^!^^^!"^&^
    (set ^| find "^!wds_sde_sn^!=" ^| findstr /BC:"^!wds_sde_sn^!") 2^>^&1^&^
    echo "wds_sde_exc="^
   ))^
  ))^&^
  set "wds_sde_sn="^&set "wds_sde_ss="^&set "wds_sde_pf="^&set "wds_sde_sf="^&set "wds_sde_par="^
 ) else (echo Error [@str_decode]: Absent parameters.^&exit /b 1)) else set wds_sde_par=
 
::         @str_arrange - arranges and echoes string values in tabular order.
::                      First 2 parameters must follow internal identifiers and marker ":", their order sets arrangement of result:
::                        R:%~1 C:%~2  - the string contains data ordered by rows, number of rows & number of columns;
::                        C:%~1 R:%~2  - the string contains data ordered by columns, number of columns & number of rows;
::                      Two optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                        D:%~3 == the delimiter symbol of data items in the string, by default - space symbol (string or variable);
::                        E:%~4 == key value to set encoding/decoding mode:
::                                 `0` - do not encode/decode source string;
::                                 `1` - default automatic mode - encodes to identify presence of controls & decodes before echo;
::                                 `2` - encode, but do not decode;
::                      The last parameter is required, contains string to process:
::                        %~3 (%~4 or %~5) == the source string for arranged print on screen (string or variable).
::             Notes. #1: the delimiter can be arbitrary symbol except for any of the basic sets `0` & `1` of @str_encode macro;
::                    #2: in the case of encoding mode `0` the delimiter can be any symbol, but this macro can fail with error;
::                    #3: if output has modified string items without some controls, it can be caused by quote symbols too.
::          Dependencies: @echo_params, @str_encode, @syms_replace.
::
set @str_arrange=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_pse_par (^
  (for /F "usebackq tokens=1,2,3,4,*" %%a in (`"call echo %%wds_pse_par%%"`) do (^
   set "wds_pse_nop=0"^&set "wds_pse_ord=2"^&set "wds_pse_coc=0"^&set "wds_pse_roc=0"^&set "wds_pse_del= "^&set "wds_pse_enc=1"^&^
   (if ^^^!wds_pse_nop^^^! NEQ 0 (echo Error [@str_arrange]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for /F "usebackq tokens=*" %%y in (`cmd /d /q /r "^!@echo_params^! 4 %%a %%b %%c %%d"`) do if not "%%y"=="" (^
    set "wds_pse_aux=%%y"^&set "wds_pse_sel=^!wds_pse_aux:~2^!"^&set "wds_pse_aux=^!wds_pse_aux:~0,2^!"^&^
    (if "^!wds_pse_aux:R:=^!"=="" (set /a "wds_pse_nop+=1"^>NUL^&(set /a "wds_pse_roc=^!wds_pse_sel^!"^>NUL 2^>^&1)^>NUL^&(if ^^^!wds_pse_ord^^^! EQU 2 (set /a "wds_pse_ord=0")^>NUL)))^&^
    (if "^!wds_pse_aux:C:=^!"=="" (set /a "wds_pse_nop+=1"^>NUL^&(set /a "wds_pse_coc=^!wds_pse_sel^!"^>NUL 2^>^&1)^>NUL^&(if ^^^!wds_pse_ord^^^! EQU 2 (set /a "wds_pse_ord=1")^>NUL)))^&^
    (if "^!wds_pse_aux:D:=^!"=="" (set /a "wds_pse_nop+=1"^>NUL^&(if defined ^^^!wds_pse_sel^^^! (call set "wds_pse_del=%%^!wds_pse_sel^!%%") else (set "wds_pse_del=^!wds_pse_sel^!"))))^&^
    (if "^!wds_pse_aux:E:=^!"=="" (set /a "wds_pse_nop+=1"^>NUL^&(set /a "wds_pse_enc=^!wds_pse_sel^!"^>NUL 2^>^&1)^>NUL))^
   ))^&^
   (if 2 EQU ^^^!wds_pse_nop^^^! (^
    (if "%%~e"=="" (if "%%~d"=="" (set "wds_pse_par=%%c") else (set "wds_pse_par=%%c %%d")) else (set "wds_pse_par=%%c %%d %%e"))^
   ) else (^
    (if 3 EQU ^^^!wds_pse_nop^^^! (^
     (if "%%~e"=="" (set "wds_pse_par=%%d") else (set "wds_pse_par=%%d %%e"))^
    ) else (set "wds_pse_par=%%e"))^
   ))^&^
   (if defined ^^^!wds_pse_par^^^! (call set "wds_pse_par=%%^!wds_pse_par^!%%"))^
  ))^&^
  (if defined wds_pse_par if 0 LSS ^^^!wds_pse_roc^^^! if 0 LSS ^^^!wds_pse_coc^^^! if 2 LEQ ^^^!wds_pse_nop^^^! (^
   (if ^^^!wds_pse_enc^^^! NEQ 0 (^
    (for /F "tokens=*" %%b in ('cmd /d /q /v:on /e:on /r "^!@str_encode^! wds_pse_par 1 "" "" 1"') do (set %%b))^
   ))^&^
   set "wds_pse_aux=^!wds_pse_par:/CHR{=^!"^&^
   (if ^^^!wds_pse_enc^^^! EQU 1 (if "^!wds_pse_aux^!"=="^!wds_pse_par^!" (set "wds_pse_enc=0") else (set "wds_pse_enc=1")))^&^
   set "wds_pse_aux=^%%wds_pse_sub^%%"^&^
   (set wds_pse_sel="(for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,* delims=%%wds_pse_del%%" %%^^a in ('"echo ^^^!wds_pse_aux^^^!"') do ((echo 7%%^^^^a7)%%wds_pse_amp%%(echo 7%%^^^^b7)%%wds_pse_amp%%(echo 7%%^^^^c7)%%wds_pse_amp%%(echo 7%%^^^^d7)%%wds_pse_amp%%(echo 7%%^^^^e7)%%wds_pse_amp%%(echo 7%%^^^^f7)%%wds_pse_amp%%(echo 7%%^^^^g7)%%wds_pse_amp%%(echo 7%%^^^^h7)%%wds_pse_amp%%(echo 7%%^^^^i7)%%wds_pse_amp%%(echo 7%%^^^^j7)%%wds_pse_amp%%(echo 7%%^^^^k7)%%wds_pse_amp%%(echo 7%%^^^^l7)%%wds_pse_amp%%(echo 7%%^^^^m7)%%wds_pse_amp%%(echo 7%%^^^^n7)%%wds_pse_amp%%(echo 7%%^^^^o7)%%wds_pse_amp%%(echo 7%%^^^^p7)%%wds_pse_amp%%(echo 7%%^^^^q7)%%wds_pse_amp%%(echo 7%%^^^^r7)%%wds_pse_amp%%(echo 7%%^^^^s7)%%wds_pse_amp%%(echo 7%%^^^^t7)%%wds_pse_amp%%(echo 7%%^^^^u7)%%wds_pse_amp%%(echo 7%%^^^^v7)%%wds_pse_amp%%(echo 7%%^^^^w7)%%wds_pse_amp%%(echo 7%%^^^^x7)%%wds_pse_amp%%(echo 7%%^^^^y7)%%wds_pse_amp%%(echo 7%%^^^^z7)))")^&^
   (set wds_pse_amp="^^^&")^&(set "wds_pse_amp=^!wds_pse_amp:~-2,1^!")^&(set wds_pse_exc="^^^!")^&(call set "wds_pse_exc=%%wds_pse_exc:~1,-1%%")^&(set wds_pse_quo="")^&(call set "wds_pse_quo=%%wds_pse_quo:~0,1%%")^&^
   set "wds_pse_num=1"^&^
   (for /F "usebackq tokens=*" %%a in (`cmd /d /q /e:on /v:on /r "(call set wds_pse_sub=7%%wds_pse_exc%%wds_pse_par%%wds_pse_exc%%7)%%wds_pse_amp%%(set wds_pse_par=77)%%wds_pse_amp%%(for /L %%b in (1 1 4096) do if %%wds_pse_exc%%wds_pse_sub%%wds_pse_exc%% EQU 77 (exit /b 0) else ((set wds_pse_sub=%%wds_pse_exc%%wds_pse_sub:~1,-1%%wds_pse_exc%%)%%wds_pse_amp%%(for /F %%wds_pse_quo%%usebackq tokens=*%%wds_pse_quo%% %%c in (`cmd /d /q /r %%wds_pse_exc%%wds_pse_sel%%wds_pse_exc%%`) do ((if %%wds_pse_exc%%wds_pse_par%%wds_pse_exc%% NEQ 77 (echo %%wds_pse_exc%%wds_pse_par%%wds_pse_exc%%))%%wds_pse_amp%%(set wds_pse_par=%%c)))%%wds_pse_amp%%(set wds_pse_sub=%%wds_pse_exc%%wds_pse_par%%wds_pse_exc%%)%%wds_pse_amp%%(set wds_pse_par=77)))"`) do (^
    set "wds_pse_^!wds_pse_num^!=%%a"^&^call set "wds_pse_^!wds_pse_num^!=%%wds_pse_^!wds_pse_num^!:~1,-1%%"^&^
    set /a "wds_pse_num+=1"^>NUL^
   ))^&^
   set "wds_pse_par="^&set "wds_pse_aux="^&set "wds_pse_sel="^&set "wds_pse_num="^&^
   (if ^^^!wds_pse_ord^^^! EQU 0 (^
    (for /L ^%%e in (1,1,^^^!wds_pse_roc^^^!) do (^
     set /a "wds_pse_rnb=^!wds_pse_coc^!*(%%e-1)+1"^>NUL^&^
     (if defined wds_pse_^^^!wds_pse_rnb^^^! (^
      set /a "wds_pse_rne=^!wds_pse_coc^!*%%e"^>NUL^&^
      call set "wds_pse_row=%%wds_pse_^!wds_pse_rnb^!%%"^&call set "wds_pse_^!wds_pse_rnb^!="^&set /a "wds_pse_rnb+=1"^>NUL^&^
      (for /L %%f in (^^^!wds_pse_rnb^^^!,1,^^^!wds_pse_rne^^^!) do if defined wds_pse_%%f (^
       call set "wds_pse_row=^!wds_pse_row^!^!wds_pse_del^!^!wds_pse_%%f^!"^&set "wds_pse_%%f="^
      ))^&^
      (if ^^^!wds_pse_enc^^^! EQU 1 (^
       (for /F "tokens=*" %%f in ('cmd /d /q /v:on /e:on /r "^!@str_decode^! wds_pse_row "" "" 1"') do (set %%f))^
      ) else (echo ^^^!wds_pse_row^^^!))^
     ))^
    ))^&^
    set "wds_pse_rnb="^&set "wds_pse_rne="^
   ))^&^
   (if ^^^!wds_pse_ord^^^! EQU 1 (^
    (for /L ^%%e in (1,1,^^^!wds_pse_roc^^^!) do if defined wds_pse_%%e (^
     set "wds_pse_row=^!wds_pse_%%e^!"^&set "wds_pse_%%e="^&^
     (for /L %%f in (2,1,^^^!wds_pse_coc^^^!) do (^
      set /a "wds_pse_pos=^!wds_pse_roc^!*(%%f-1)+%%e"^>NUL^&^
      (if defined wds_pse_^^^!wds_pse_pos^^^! (call set "wds_pse_row=^!wds_pse_row^!^!wds_pse_del^!%%wds_pse_^!wds_pse_pos^!%%"^&set "wds_pse_^!wds_pse_pos^!="))^
     ))^&^
     (if ^^^!wds_pse_enc^^^! EQU 1 (^
      (for /F "tokens=*" %%f in ('cmd /d /q /v:on /e:on /r "^!@str_decode^! wds_pse_row "" "" 1"') do (echo %%f))^
     ) else (echo ^^^!wds_pse_row^^^!))^
    ))^&^
    set "wds_pse_pos="^
   ))^
  ))^&^
  (for %%a in (amp,exc,quo,ord,roc,coc,nop,del,row,enc) do (set "wds_pse_%%a="))^
 ) else (echo Error [@str_arrange]: Absent parameters.^&exit /b 1)) else set wds_pse_par=

::           @str_upper - converts external string to uppers case of letters, supports native letters.
::                        %~1 == name of variable with original string & to set string value with result.
::                        %~2 == [optional: key parameter `1` to skip decoding of string after convertion, by default `0`];
::                        %~3 == [optional: key value `1` to echo result instead of assigning, default is `0`].
::          Dependencies: @str_decode, @str_encode, @syms_replace.
::
set @str_upper=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_sup_snm (^
  (for /F "tokens=1,2,3" %%a in ('echo.%%wds_sup_snm%%') do if defined %%a (^
   set "wds_sup_snm=%%a"^&^
   (for /F "tokens=*" %%d in ('cmd /d /q /e:on /v:on /r "^!@str_encode^! %%a 3 "" "" 1"') do (set %%d))^&^
   set "wds_sup_str=^!%%a^!"^&^
   (if NOT "^!wds_sup_snm^!"=="%%a" (echo Error [@str_upper]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "wds_sup_nod=0"^&(if not "%%b"=="" ((set /a "wds_sup_nod=%%~b"^>NUL 2^>^&1)^>NUL))^&^
   set "wds_sup_eco=0"^&(if not "%%c"=="" ((set /a "wds_sup_eco=%%~c"^>NUL 2^>^&1)^>NUL))^
  ))^&^
  (if defined wds_sup_str (^
   set "wds_sup_res=^!wds_sup_str^!"^&set "wds_sup_len=1"^&^
   (for %%a in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
    set "wds_sup_sub=^!wds_sup_res:~%%a,1^!"^&^
    (if defined wds_sup_sub (set "wds_sup_res=^!wds_sup_res:~%%a^!"^&set /a "wds_sup_len+=%%a"^>NUL))^
   ))^&^
   set "wds_sup_res="^&^
   (set "wds_sup_amp=1^^^&1")^&(call set "wds_sup_amp=%%wds_sup_amp:~-2,1%%")^&(set wds_sup_rab="^^^>")^&(call set "wds_sup_rab=%%wds_sup_rab:~-2,1%%")^&^
   (for /L %%y in (0,255,^^^!wds_sup_len^^^!) do (^
    call set "wds_sup_sub=%%wds_sup_str:~%%y,255%%"^&^
    (if defined wds_sup_sub for /F "usebackq tokens=1,* delims=(" %%a in (`"find "" "^(^^^!wds_sup_sub^^^!" 2%%wds_sup_rab%%%%wds_sup_amp%%1"`) do (^
     (if defined wds_sup_res (set "wds_sup_res=^!wds_sup_res^!%%b") else (set "wds_sup_res=%%b"))^
    ))^
   ))^&^
   (if ^^^!wds_sup_nod^^^! EQU 0 (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@str_decode^! wds_sup_res "" "" 1"') do (set %%a))^
   ))^&^
   (if ^^^!wds_sup_eco^^^! NEQ 1 (^
    (set ^^^!wds_sup_snm^^^!=^^^!wds_sup_res^^^!)^>NUL 2^>^&1^&(for %%a in (res,len,num,lft,eco,sub,amp,rab,str,nod) do (set "wds_sup_%%a="))^
   ) else (^
    (echo "^!wds_sup_snm^!=^!wds_sup_res^!")^
   ))^
  ))^&^
  set "wds_sup_snm="^
 ) else (echo Error [@str_upper]: Absent parameters.^&exit /b 1)) else set wds_sup_snm=

::         @str_isempty - checks the parameter is the empty [quoted] string (it's compatible with @mac_check/@istrue macro).
::                        %~1 == variable name to return result ('0' - true) - required by @mac_check as hidden internal argument;
::                        %~2 == variable name of the caller string value;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == key value to unquote external string:
::                               `1` - remove any quotation marks from external string;
::                               `2` - replace quotation marks by another symbol, by default uses symbol `_`;
::                               `3` - reports empty string for quoted string `""`, but without modifications to source (default);
::                                   - values `1` & `3` result in empty string for quoted empty strings `""`;
::                      2:%~4 == the symbol (string) to replace quotation marks.
::
set @str_isempty=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ise_aux for /F %%p in ('echo wds_ise_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%paux%%') do (^
   set "%%pstn=%%~b"^&(if not "^!%%pstn::=^!"=="^!%%pstn^!" (set "%%pstn="))^&(if not defined %%pstn (echo Error [@str_isempty]: Absent 2nd parameter.^&exit /b 1))^&^
   (if defined %%~b (set "%%pstv=^!%%~b^!") else (set "%%pstv="))^&set "%%pres=%%~a"^&set "%%pact=3"^&set "%%psus="^&^
   (for %%e in (%%~c,%%~d) do for /F "tokens=1,2 delims=:" %%f in  ('"echo %%e"') do if not "%%~g"=="" (^
    (if %%~f EQU 1 (^
     set /a "%%paux=0%%~g"^>NUL 2^>^&1 ^&^& (if 0 LSS ^^^!%%paux^^^! if ^^^!%%paux^^^! LSS 4 (set "%%pact=^!%%paux^!"))^
    ) else if %%~f EQU 2 (set "%%psus=%%~g"))^
   ))^
  ))^&^
  (if defined %%pstv (^
   (set %%paux="")^&set "%%paux=^!%%paux:~1^!"^&^
   (if ^^^!%%pact^^^! NEQ 3 (^
    (if ^^^!%%pact^^^! EQU 1 (^
     call set "%%pstv=%%%%pstv:^!%%paux^!=%%"^
    ) else if ^^^!%%pact^^^! EQU 2 (^
     (if defined %%psus (call set "%%pstv=%%%%pstv:^!%%paux^!=^!%%psus^!%%") else (call set "%%pstv=%%%%pstv:^!%%paux^!=_%%"))^
    ))^&^
    (if defined %%pstv (set "^!%%pstn^!=^!%%pstv^!") else (set "^!%%pstn^!="))^
   ) else (call set "%%pstv=%%%%pstv:^!%%paux^!=%%"))^
  ))^&^
  (if defined %%pstv (set "^!%%pres^!=1") else (set "^!%%pres^!=0"))^&(for %%a in (act,aux,res,stn,stv,sus) do (set "wds_ise_%%a="))^
 ) else (echo Error [@str_isempty]: Absent parameters.^&exit /b 1)) else set wds_ise_aux=

::           @date_span - parses string with WMIC date time format to format "days.seconds" ("DDDDDD.SSSSS"), calculates timespan.
::                      It has only optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      Optional parameters with explicit values without quotes:
::                      1:%~1 == 1st datetime string with format YYYYMMDDHHMMSS.NNN+EEE, the fraction part is ignored;
::                      2:%~2 == the second date string with same format for calculation of timespan (see also 6:%~6);
::                      Optional parameters with names of variables of calling script to return result:
::                      3:%~3 == number of days inside date before delimiter `.` (`1:%~1`);
::                      4:%~4 == number of seconds inside date after delimiter `.` (`1:%~1`);
::                      5:%~5 == timespan in seconds between dates;
::                      6:%~6 == returns `1` if the order of dates wasn't changed & `0` if it was changed to have positive timespan;
::                      Key parameters:
::                      7:%~7 == `1` to return into `5:%~5` the timestamp in seconds since 01.01.1970 for date `1:%~1`, default `0`;
::                      8:%~8 == `1` to indicate that `2:%~2` has parsed value in format DDDDDD.SSSSS, default is `0`;
::                      9:%~9 == `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: the call with only single `3:%~3` parameter returns current datetime into variable name %~3;
::                    #2: one of optional parameters `3:%~3` -> `7:%~7` is required to return result;
::                    #3: parameter `2:%~2` has sense only with defined `5:%~5`, serves to define timespan in seconds;
::                    #4: in case of undefined `2:%~2` parameter, it calculates timespan between current date & `%~1` into `5:%~5`;
::                    #5: parameter `8:%~8` has sense only for defined `2:%~2` & `5:%~5`, improves performance by fewer activities;
::                    #6: for calculation of timespan it checks values of dates `1:%~1` & `2:%~2` to return positive difference;
::                    #7: the key `7:%~7` invalidates `2:%~2`, it's set equal to `19700101000000` & local time zone treated as UTC.
::
set @date_span=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_dts_aux (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%wds_dts_aux%%') do (^
   (for %%j in ("dt1=","dt2=","nds=","nss=","tsp=","dod=","nop=0","tst=","sp2=0","eco=0") do (set "wds_dts_%%~j"))^&^
   (if ^^^!wds_dts_nop^^^! NEQ 0 (echo Error [@date_span]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined SystemRoot (echo Error [@date_span]: Undefined variable `SystemRoot`.^&exit /b 1))^&^
   (for %%j in (%%~a,%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i) do if not "%%j"=="" (^
    set "wds_dts_aux=%%j"^&set "wds_dts_amp=^!wds_dts_aux:~2^!"^&^
    (if defined wds_dts_aux (^
     set "wds_dts_aux=^!wds_dts_aux:~0,1^!"^&^
     (if ^^^!wds_dts_aux^^^! EQU 1 (set "wds_dts_dt1=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 2 (set "wds_dts_dt2=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 3 (set /a "wds_dts_nop+=1"^>NUL^&set "wds_dts_nds=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 4 (set /a "wds_dts_nop+=1"^>NUL^&set "wds_dts_nss=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 5 (set /a "wds_dts_nop+=1"^>NUL^&set "wds_dts_tsp=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 6 (set /a "wds_dts_nop+=1"^>NUL^&set "wds_dts_dod=^!wds_dts_amp^!")^
     else if ^^^!wds_dts_aux^^^! EQU 7 (if ^^^!wds_dts_amp^^^! EQU 1 (set "wds_dts_tst=1"))^
     else if ^^^!wds_dts_aux^^^! EQU 8 (if ^^^!wds_dts_amp^^^! EQU 1 (set "wds_dts_sp2=1"))^
     else if ^^^!wds_dts_aux^^^! EQU 9 (if ^^^!wds_dts_amp^^^! EQU 1 (set "wds_dts_eco=1")))^
    ))^
   ))^
  ))^&(if not defined wds_dts_eco (echo Error [@date_span]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (if not defined wds_dts_dt1 if not defined wds_dts_dt2 if ^^^!wds_dts_nop^^^! EQU 1 (^
   (if defined wds_dts_nds (^
    (for /F "tokens=1,2 delims==" %%a in ('wmic os get LocalDateTime /value') do if not "%%b"=="" (^
     for /F "tokens=1 delims=." %%c in ("%%b") do (if ^^^!wds_dts_eco^^^! NEQ 1 (set "^!wds_dts_nds^!=%%c") else (echo "^!wds_dts_nds^!=%%c"))^
    ))^&^
    set "wds_dts_nop="^&set "wds_dts_sp2="^&set "wds_dts_amp="^&set "wds_dts_eco="^
   ) else if not defined wds_dts_tst (echo Error [@date_span]: Wrong parameters.^&exit /b 1))^
  ))^&^
  (if defined wds_dts_nop (^
   (if not defined wds_dts_dt1 for /F "tokens=1,2 delims==" %%a in ('wmic os get LocalDateTime /value') do if not "%%b"=="" (^
    for /F "tokens=1 delims=." %%c in ("%%b") do (set "wds_dts_dt1=%%c")^
   ))^&^
   (if defined wds_dts_tst (^
    (if not defined wds_dts_tsp (echo Error [@date_span]: Not defined parameter #5:5 to return timestamp.^&exit /b 1))^&^
    set "wds_dts_sp2=1"^&set "wds_dts_dt2=719528.0"^
   ))^&^
   (if defined wds_dts_tsp (^
    (if not defined wds_dts_dt2 (echo Error [@date_span]: Not defined parameter #2:2.^&exit /b 1))^&^
    (if ^^^!wds_dts_sp2^^^! EQU 1 (^
     (for /F "tokens=1,2 delims=." %%a in ('echo %%wds_dts_dt2%%') do (set "wds_dts_dd2=%%a"^&set "wds_dts_d2s=%%b"))^&^
     (if not defined wds_dts_d2s (echo Error [@date_span]: The input datetime #2:2 must have format DDDDDD.SSSSS.^&exit /b 1))^
    ) else (call set wds_dts_dt1=%%wds_dts_dt1%%","2 %%wds_dts_dt2%%))^
   ))^&^
   (set wds_dts_amp="^^^&")^&(call set "wds_dts_amp=%%wds_dts_amp:~-2,1%%")^&^
   (for %%a in ("1 ^!wds_dts_dt1^!") do for /F "tokens=1,2" %%b in (%%a) do if not "%%~c"=="" (^
    set wds_dts_aux=%%c^&^
    (for %%d in ("4 wds_dts_dy%%b","2 wds_dts_dm%%b","2 wds_dts_dd%%b","2 wds_dts_d%%bh","2 wds_dts_d%%bm","2 wds_dts_d%%bs") do (^
     (for /F "tokens=1,2" %%e in (%%d) do (^
      (for /F "tokens=* delims=0" %%g in ('"echo.%%wds_dts_aux:~0,%%e%%"') do (set /a "%%f=%%g"^>NUL 2^>^&1) ^|^| (^
       if "%%g"=="" (set "%%f=0") else (echo Error [@date_span]: Incorrect format of datetime.^&exit /b 1)^
      ))^&^
      set "wds_dts_aux=^!wds_dts_aux:~%%e^!"^
     ))^
    ))^&^
    set /a "wds_dts_aux=^!wds_dts_dy%%b^!/100"^>NUL^&^
    set /a "wds_dts_dd%%b=^!wds_dts_dd%%b^!+365*^!wds_dts_dy%%b^!+^!wds_dts_dy%%b^!/4-^!wds_dts_aux^!+^!wds_dts_aux^!/4"^>NUL^&^
    (for %%d in ("1 31","2 28","3 31","4 30","5 31","6 30","7 31","8 31","9 30","10 31","11 30") do for /F "tokens=1,2" %%e in (%%d) do (^
     if %%e LSS ^^^!wds_dts_dm%%b^^^! (set /a "wds_dts_dd%%b+=%%f"^>NUL)^
    ))^&^
    (if 2 LSS ^^^!wds_dts_dm%%b^^^! (^
     set /a "wds_dts_aux=^!wds_dts_aux^!*25"^>NUL^&set /a "wds_dts_dm%%b=^!wds_dts_dy%%b^!/4"^>NUL^&^
     (if ^^^!wds_dts_aux^^^! EQU ^^^!wds_dts_dm%%b^^^! (^
      set /a "wds_dts_dd%%b+=1"^>NUL^
     ) else (^
      set /a "wds_dts_dm%%b=^!wds_dts_dm%%b^!*4"^>NUL^&^
      (if ^^^!wds_dts_dy%%b^^^! EQU ^^^!wds_dts_dm%%b^^^! (set /a "wds_dts_dd%%b+=1"^>NUL))^
     ))^
    ))^&^
    set /a "wds_dts_d%%bs+=^!wds_dts_d%%bh^!*3600+^!wds_dts_d%%bm^!*60"^>NUL^&^
    set "wds_dts_dy%%b="^&set "wds_dts_dm%%b="^&set "wds_dts_d%%bh="^&set "wds_dts_d%%bm="^
   ))^&^
   (if defined wds_dts_nds (if ^^^!wds_dts_eco^^^! NEQ 1 (set "^!wds_dts_nds^!=^!wds_dts_dd1^!") else (echo "^!wds_dts_nds^!=^!wds_dts_dd1^!")))^&^
   (if defined wds_dts_nss (if ^^^!wds_dts_eco^^^! NEQ 1 (set "^!wds_dts_nss^!=^!wds_dts_d1s^!") else (echo "^!wds_dts_nss^!=^!wds_dts_d1s^!")))^&^
   (if defined wds_dts_tsp (^
    (if ^^^!wds_dts_dd1^^^! LSS ^^^!wds_dts_dd2^^^! (set "wds_dts_aux=") else (^
     (if ^^^!wds_dts_dd1^^^! EQU ^^^!wds_dts_dd2^^^! if ^^^!wds_dts_d1s^^^! LEQ ^^^!wds_dts_d2s^^^! (set "wds_dts_aux="))^
    ))^&^
    (if defined wds_dts_aux (^
     set "wds_dts_aux=^!wds_dts_dd1^!"^&set "wds_dts_dd1=^!wds_dts_dd2^!"^&set "wds_dts_dd2=^!wds_dts_aux^!"^&^
     set "wds_dts_aux=^!wds_dts_d1s^!"^&set "wds_dts_d1s=^!wds_dts_d2s^!"^&set "wds_dts_d2s=^!wds_dts_aux^!"^
    ))^&^
    (if defined wds_dts_dod (^
     (if defined wds_dts_aux (set "wds_dts_amp=1") else (set "wds_dts_amp=0"))^&^
     if ^^^!wds_dts_eco^^^! NEQ 1 (set "^!wds_dts_dod^!=^!wds_dts_amp^!") else (echo "^!wds_dts_dod^!=^!wds_dts_amp^!")^
    ))^&^
    set /a "wds_dts_aux=(^!wds_dts_dd2^!-^!wds_dts_dd1^!)*86400+^!wds_dts_d2s^!-^!wds_dts_d1s^!"^>NUL^&^
    (if ^^^!wds_dts_eco^^^! NEQ 1 (set "^!wds_dts_tsp^!=^!wds_dts_aux^!") else (echo "^!wds_dts_tsp^!=^!wds_dts_aux^!"))^
   ))^&^
   (if ^^^!wds_dts_eco^^^! NEQ 1 for %%a in (dd1,dd2,d1s,d2s,dod,nss,tsp,tst,dt1,dt2,amp,sp2,eco) do (set "wds_dts_%%a="))^
  ))^&^
  set "wds_dts_aux="^&set "wds_dts_nop="^&set "wds_dts_nds="^
 ) else (echo Error [@date_span]: The parameters are absent.^&exit /b 1)) else set wds_dts_aux=

::           @time_span - retrieves time values from a time string with usual format HH:MM:SS.NN, has only optional parameters.
::                      Input string values of time - without quotes and (!) all space symbols must be replaced by `0`:
::                      0:%~1 == the time string to be parsed with format HH:MM:SS.NNN (default is current time, see also `7:%~8`);
::                      1:%~2 == the second time string with same format for calculation of timespan;
::                      Names of variables of calling script to initialize (one of them required):
::                      2:%~3 == number of hours;
::                      3:%~4 == number of minutes;
::                      4:%~5 == number of seconds;
::                      5:%~6 == number of milliseconds;
::                      6:%~7 == number of milliseconds spent on internal macro activities;
::                      Optional not required parameters with internal identifier and marker ":":
::                      7:%~8 == key value:
::                               `0` - default value corresponds to default format of `0:%~1` & `1:%~2`, parse them both;
::                               `1` - specifies that `0:%~1` has number of milliseconds from midnight & it doesn't need parsing;
::                               `2` - specifies that `1:%~2` has number of milliseconds from midnight & it doesn't need parsing;
::                      8:%~9 == key value defines approach for calculation of timespan values & sets order of time parameters:
::                               `0` - gets biggest value of `0:%~1` & `1:%~2` (not recommended);
::                               `1` - default value, if time `0:%~1` is less than `1:%~2`, adds day length to `0:%~1`;
::                               `2` - if time `1:%~2` is less than `0:%~1`, adds day length to `1:%~2`;
::                      9:%~10== key value `1` to echo result instead of assigning, default is `0`;
::                      A:%~11== the name of variable with 1st time string to be parsed (in place of value `0:%~1`);
::                      B:%~12== the name of variable with 2nd time string to be parsed (in place of value `1:%~2`);
::                      C:%~13== the name of variable to return number of milliseconds in "0:%~1" (only with defined "1:%~2");
::                      D:%~14== the name of variable to return number of milliseconds in "1:%~2" (only with defined "1:%~2").
::             Notes. #1: if both `0:%~1` & `1:%~2` parameters undefined, it calculates the resulting values for current time;
::                    #2: if `0:%~1` undefined & `1:%~2` defined, it calculates timespan between current time & `1:%~2`;
::                    #3: for milliseconds it ignores last 3rd digit in string if present, returns result with trailing `0` always;
::                    #4: non-zero `7:%~8` requires both `0:%~1` & `1:%~2`, otherwise gives error (except `7:2` & `0:%~1` default);
::                    #5: `8:%~9` is only valuable with defined `1:%~2` or ignored;
::                    #6: if `0:%~1` undefined, it empirically adjusts the time values to macro exit time with precision 20 msec;
::                    #7: macro adjusts values of `0:%~1` or `1:%~2` to day length (range [0,86400000]);
::                    #8: the rules for `0:%~1` & `1:%~2` equally apply to values from parameters `A:%~11` & `B:%~12`.
::
set @time_span=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tms_aux (^
  set "wds_tms_ms0=1^!time:~9,2^!"^&set "wds_tms_aux=^!wds_tms_aux:,=.^!"^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14" %%a in ('echo %%wds_tms_aux%%') do (^
   (for %%o in ("nop=0","skp=0","ord=1","eco=0","tt1=","tt2=","nhs=","nms=","nss=","nsm=","nia=","m1n=","m2n=") do (set "wds_tms_%%~o"))^&^
   (if ^^^!wds_tms_nop^^^! NEQ 0 (echo Error [@time_span]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%o in (%%~a,%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n) do if not "%%o"=="" (^
    set "wds_tms_aux=%%o"^&set "wds_tms_tmp=^!wds_tms_aux:~2^!"^&set "wds_tms_aux=^!wds_tms_aux:~0,1^!"^&^
    (if defined wds_tms_tmp (^
     (if ^^^!wds_tms_aux^^^! EQU 0 (set "wds_tms_tt1=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 1 (set "wds_tms_tt2=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 2 (set /a "wds_tms_nop+=1"^>NUL^&set "wds_tms_nhs=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 3 (set /a "wds_tms_nop+=1"^>NUL^&set "wds_tms_nms=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 4 (set /a "wds_tms_nop+=1"^>NUL^&set "wds_tms_nss=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 5 (set /a "wds_tms_nop+=1"^>NUL^&set "wds_tms_nsm=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 6 (set /a "wds_tms_nop+=1"^>NUL^&set "wds_tms_nia=^!wds_tms_tmp^!")^
     else if ^^^!wds_tms_aux^^^! EQU 7 ((set /a "wds_tms_skp=^!wds_tms_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& echo.^>nul ^|^| set "wds_tms_nop=-10")^
     else if ^^^!wds_tms_aux^^^! EQU 8 ((set /a "wds_tms_ord=^!wds_tms_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& echo.^>nul ^|^| set "wds_tms_nop=-10")^
     else if ^^^!wds_tms_aux^^^! EQU 9 ((set /a "wds_tms_eco=^!wds_tms_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& echo.^>nul ^|^| set "wds_tms_nop=-10")^
     else (^
      (set /a "wds_tms_aux=0x^!wds_tms_aux^!"^>NUL 2^>^&1)^>NUL^&^
      (if ^^^!wds_tms_aux^^^! EQU 10 (call set "wds_tms_tt1=%%^!wds_tms_tmp^!%%")^
      else if ^^^!wds_tms_aux^^^! EQU 11 (call set "wds_tms_tt2=%%^!wds_tms_tmp^!%%")^
      else if ^^^!wds_tms_aux^^^! EQU 12 (call set "wds_tms_m1n=^!wds_tms_tmp^!")^
      else if ^^^!wds_tms_aux^^^! EQU 13 (call set "wds_tms_m2n=^!wds_tms_tmp^!"))^
     ))^
    ))^
   ))^
  ))^&(if ^^^!wds_tms_nop^^^! LEQ 0 (echo Error [@time_span]: Missing return result parameters or non-digital key arguments.^&exit /b 1))^&^
  set "wds_tms_aux=1"^&(if ^^^!wds_tms_skp^^^! NEQ 0 if ^^^!wds_tms_skp^^^! NEQ 2 (set "wds_tms_aux=2"))^&^
  (if ^^^!wds_tms_aux^^^! EQU 2 (^
   (if not defined wds_tms_tt1 (set "wds_tms_aux="))^&(if not defined wds_tms_tt2 (set "wds_tms_aux="))^&^
   (if defined wds_tms_aux (^
    ((set /a "wds_tms_tmp=^!wds_tms_tt1^!/86400000"^>NUL 2^>^&1)^>NUL ^&^& echo.^>nul ^|^| (echo Error [@time_span]: Non-digital value of parameter #1.^&exit /b 1))^&^
    set /a "wds_tms_ms1=^!wds_tms_tt1^!-^!wds_tms_tmp^!*86400000"^>NUL^&^
    (if ^^^!wds_tms_ms1^^^! LSS 0 (set /a "wds_tms_ms1+=86400000"^>NUL))^
   ) else (echo Error [@time_span]: Missing parameter #1 or #2.^&exit /b 1))^&^
   set "wds_tms_tt1=^!wds_tms_tt2^!"^
  ) else (^
   (if not defined wds_tms_tt1 (set "wds_tms_cor=1"^&set "wds_tms_tt1=^!time: =0^!"))^&^
   (if ^^^!wds_tms_skp^^^! EQU 2 (^
    (if defined wds_tms_tt2 (^
     ((set /a "wds_tms_tmp=^!wds_tms_tt2^!/86400000"^>NUL 2^>^&1)^>NUL ^&^& echo.^>nul ^|^| (echo Error [@time_span]: Non-digital value of parameter #2.^&exit /b 1))^&^
     set /a "wds_tms_ms2=^!wds_tms_tt2^!-^!wds_tms_tmp^!*86400000"^>NUL^&^
     (if ^^^!wds_tms_ms2^^^! LSS 0 (set /a "wds_tms_ms2+=86400000"^>NUL))^
    ) else (echo Error [@time_span]: Missing parameter #2.^&exit /b 1))^
   ) else (^
    (if defined wds_tms_tt2 (call set wds_tms_tt1=%%wds_tms_tt1%%","2 %%wds_tms_tt2%%))^
   ))^
  ))^&^
  (set wds_tms_tmp="^^^&")^&call set "wds_tms_tmp=%%wds_tms_tmp:~-2,1%%"^&^
  (for %%a in ("^!wds_tms_aux^! ^!wds_tms_tt1^!") do if defined wds_tms_tmp for /F "tokens=1,2" %%b in (%%a) do (^
   set "wds_tms_aux=%%~c"^&^
   (for /F "tokens=2,3 delims=0123456789" %%d in ('echo %%~c') do if "%%~d"=="" (set "wds_tms_aux=") else if "%%~e"=="" (set "wds_tms_aux=") else (^
    set "wds_tms_aux=^!wds_tms_aux:%%~d= ^!"^&set "wds_tms_aux=^!wds_tms_aux:%%~e= ^!"^
   ))^&^
   (if defined wds_tms_aux for /F "tokens=1,2,3,4,5" %%d in ('echo "%%wds_tms_tmp%%" %%wds_tms_aux%%') do (^
    set /a "wds_tms_ms%%b=0"^>NUL^&^
    (for %%i in ("1 1 23 %%e","60 1 59 %%f","60 1 59 %%g","100 10 99 %%h") do (^
     set "wds_tms_aux="^&^
     (for /F "tokens=1,2,3,4" %%j in (%%i) do (^
      (call set /a "wds_tms_aux=0x%%m" ^&^& (^
       call set /a "wds_tms_aux=(10*((%%wds_tms_aux%%%%~d240)/16))+(%%wds_tms_aux%%%%~d15)"^
      ))^>NUL 2^>^&1^&^
      (if defined wds_tms_aux if ^^^!wds_tms_aux^^^! LSS 0 (set "wds_tms_aux=") else if %%l LSS ^^^!wds_tms_aux^^^! (set "wds_tms_aux="))^&^
      (if defined wds_tms_aux (^
       set /a "wds_tms_ms%%b=%%k*(%%j*^!wds_tms_ms%%b^!+^!wds_tms_aux^!)"^>NUL^
      ) else (^
       echo Error [@time_span]: Incorrect format of time.^&exit /b 1^
      ))^
     ))^
    ))^
   ) else (echo Error [@time_span]: The time string `%%~c` has not any delimiters.^&exit /b 1))^
  ))^&^
  (if defined wds_tms_ms2 (^
   (if defined wds_tms_m1n if ^^^!wds_tms_eco^^^! NEQ 1 (set "^!wds_tms_m1n^!=^!wds_tms_ms1^!") else (echo "^!wds_tms_m1n^!=^!wds_tms_ms1^!"))^&^
   (if defined wds_tms_m2n if ^^^!wds_tms_eco^^^! NEQ 1 (set "^!wds_tms_m2n^!=^!wds_tms_ms2^!") else (echo "^!wds_tms_m2n^!=^!wds_tms_ms2^!"))^&^
   (if ^^^!wds_tms_ord^^^! EQU 0 (^
    (if ^^^!wds_tms_ms1^^^! LSS ^^^!wds_tms_ms2^^^! (set /a "wds_tms_ms1=^!wds_tms_ms2^!-^!wds_tms_ms1^!"^>NUL) else (set /a "wds_tms_ms1-=^!wds_tms_ms2^!"^>NUL))^
   ) else if ^^^!wds_tms_ord^^^! EQU 2 (^
    (if ^^^!wds_tms_ms2^^^! LSS ^^^!wds_tms_ms1^^^! (set /a "wds_tms_ms2+=86400000"^>NUL))^&^
    set /a "wds_tms_ms1=^!wds_tms_ms2^!-^!wds_tms_ms1^!"^>NUL^
   ) else (^
    (if ^^^!wds_tms_ms1^^^! LSS ^^^!wds_tms_ms2^^^! (set /a "wds_tms_ms1+=86400000"^>NUL))^&^
    set /a "wds_tms_ms1-=^!wds_tms_ms2^!"^>NUL^
   ))^
  ))^&^
  (if not defined wds_tms_cor if not defined wds_tms_nia (set "wds_tms_ms0="))^&^
  (for %%a in ("1 wds_tms_nsm","1000 wds_tms_nss","60 wds_tms_nms","60 wds_tms_nhs") do (^
   (for /F "tokens=1,2" %%b in (%%a) do (^
    set /a "wds_tms_ms1=^!wds_tms_ms1^!/%%b"^>NUL^&^
    (if defined wds_tms_ms0 (^
     set /a "wds_tms_ms0=1^!time:~9,2^!-^!wds_tms_ms0^!"^>NUL^&(if ^^^!wds_tms_ms0^^^! LSS 0 (set /a "wds_tms_ms0+=100"^>NUL))^&^
     (if defined wds_tms_nia (^
      (if ^^^!wds_tms_eco^^^! NEQ 1 (set /a "wds_tms_aux=121*^!wds_tms_ms0^!"^>NUL) else (set /a "wds_tms_aux=131*^!wds_tms_ms0^!"^>NUL))^&^
      set /a "wds_tms_aux=^!wds_tms_aux:~0,-2^!0"^>NUL^&^
      (if ^^^!wds_tms_eco^^^! NEQ 1 (set "^!wds_tms_nia^!=^!wds_tms_aux^!") else (echo "^!wds_tms_nia^!=^!wds_tms_aux^!"))^
     ))^&^
     (if defined wds_tms_cor (^
      set /a "wds_tms_ms0=9*^!wds_tms_ms0^!"^>NUL^&set /a "wds_tms_ms1+=^!wds_tms_ms0:~0,-1^!0"^>NUL^&^
      set "wds_tms_cor="^
     ))^&^
     set "wds_tms_ms0="^
    ))^&^
    (if defined %%c (^
     (if ^^^!wds_tms_eco^^^! NEQ 1 (set "^!%%c^!=^!wds_tms_ms1^!") else (echo "^!%%c^!=^!wds_tms_ms1^!"))^
    ))^
   ))^
  ))^&^
  (if ^^^!wds_tms_eco^^^! NEQ 1 for %%m in (aux,tt1,tt2,nhs,nms,nss,nsm,nia,nop,m1n,ms1,m2n,ms2,tmp,skp,ord,eco) do (set "wds_tms_%%m="))^
 ) else (echo Error [@time_span]: The parameters are absent.^&exit /b 1)) else set wds_tms_aux=
 
::          @obj_attrib - reads attributes of file or folder on disk, supports their modification.
::                        %~1 == name of variable of calling script to return fitness of its state (0/1 <=> True/False);
::                        %~2 == the full path to the object on disk (variable name of the caller or quoted string w/o spaces);
::                        %~3 == the attribute name to read, coincides with dos short name of attributes:
::                               `r` - read-only;  `s` - system;      `t` - temporary;  `l` - reparse point;
::                               `a` - archive;    `i` - not indexed; `o` - offline;
::                               `h` - hidden;     `c` - compressed;  `d` - directory;
::                               if it is expected to have switched off value of attribute, use prefix `~`, sample: "~r";
::                      Optional not required parameters with internal identifier and marker ":":
::                      1:%~4 == key value `1` to set value of attribute, default is `0` for no action;
::                      2:%~5 == number of msec to wait until specified attribute [150...86400000], default is `0` to no wait;
::                      3:%~6 == key value `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: `1:%~4` & `2:%~5` valuable only for attributes `r`,`a`,`s`,`h`,`i`, otherwise ignored;
::                    #2: Compatible with @mac_check macro, space symbols in `%~2` can be replaced by `/CHR{20}`.
::          Dependencies: @spinner, @time_span.
::
set @obj_attrib=^
 for %%z in (1 2) do if %%z EQU 2 (if defined wds_oba_aux for /F %%y in ('echo wds_oba_') do (^
  (for /F "tokens=1,2,3,4,5,6" %%a in ('echo.%%%%yaux%%') do (^
   set "%%ycrn=%%~a"^&(if not "^!%%ycrn^!"=="%%~a" (echo Error [@obj_attrib]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%g in ("aux=r,a,h,s,i","typ=0","neg=","sav=0","wto=0","eco=0","cmd=cmd /d /q /e:on /v:on /r ") do (set "wds_oba_%%~g"))^&^
   set "%%yatr=%%~c"^&^
   (if not defined %%yatr (echo Error [@obj_attrib]: Missing 3rd parameter.^&exit /b 1))^&^
   (if defined %%yatr if "^!%%yatr:~0,1^!"=="~" (set "%%yneg=~"^&set "%%yatr=^!%%yatr:~1^!"))^&^
   (if defined %%yatr for %%g in (r,a,h,s,i,c,t,o,d,l) do if defined %%yaux if "^!%%yatr:%%g=^!"=="" (^
    set "%%yatr=%%g"^&(if "^!%%yaux:%%g=^!"=="^!%%yaux^!" (set "%%ytyp=1"))^&set "%%yaux="^
   ))^&^
   (if defined %%yaux (echo Error [@obj_attrib]: Incorrect 3rd parameter with attribute value.^&exit /b 1))^&^
   (if "%%~b"==%%b (set "%%yobj=%%~b") else if defined %%b (set "%%yobj=^!%%~b^!"))^&^
   (set %%yq="")^&(call set "%%yq=%%%%yq:~1%%")^&(call set %%yobj="%%%%yobj:^!%%yq^!=%%")^&^
   set "%%yobj=^!%%yobj:\.\=\^!"^&(if "^!%%yobj:~-1,1^!"=="\" (set "%%yobj=^!%%yobj:~0,-1^!"))^&^
   set "%%yobj=^!%%yobj:/CHR{20}= ^!"^&set "%%yobj=^!%%yobj:\\=\^!"^&^
   (if not exist "^!%%yobj^!" (echo Error [@obj_attrib]: The object does not exist or incorrect path name in 2nd argument.^&exit /b 1))^&^
   (for %%g in (%%~d,%%~e,%%~f) do if not "%%g"=="" (^
    set "%%yaux=%%g"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (^
     set "%%yaux=^!%%yaux:~0,1^!"^&^
          (if ^^^!%%yaux^^^! EQU 1 (if ^^^!%%ytmp^^^! EQU 1 (set "%%ysav=1")^
     ) else if ^^^!%%yaux^^^! EQU 2 (^
      (set /a "%%yaux=0x^!%%ytmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if 150 LEQ ^^^!%%ytmp^^^! if ^^^!%%ytmp^^^! LEQ 86400000 (set "%%ywto=^!%%ytmp^!"))^
     ) else if ^^^!%%yaux^^^! EQU 3 (if ^^^!%%ytmp^^^! EQU 1 (set "%%yeco=1"))^
    ))^
   ))^
  ))^&(if not defined %%yeco (echo Error [@obj_attrib]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%ya="^^^&")^&(set %%ye="^^^^^!^^^!^^^!")^&(set %%yr="^^^>")^&(set "%%yp=^%%")^&^
  (for %%a in (a,e,r) do (call set "wds_oba_%%a=%%wds_oba_%%a:~-2,1%%"))^&^
  (if ^^^!%%ytyp^^^! EQU 0 (^
   (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2" %%b in ('echo %%a') do for /F "tokens=1,2 delims=." %%c in ('echo %%b') do if %%c%%d LSS 61 (set "%%yvla= ") else (set "%%yvla= /L"))^&^
   (set %%yvat="(for /F $qtokens=1 delims=:$q ^!%%yp^!a in ('attrib $e%%yobj$e$e%%yvla$e') do (set $q%%yatv=^!%%yp^!a$q$aset $q%%yatv=$e%%yatv: =$e$q$aset $q%%yatv=$e%%yatv:~0,-1$e$q$a(if defined %%yatv (echo %%yatv=$e%%yatv$e) else (echo %%yatv=))))")^&^
   (set %%ygat="(for /F ^!%%yp^!a in ('%%%%ycmd%%$e%%yvat$e') do (set $q^!%%yp^!a$q))$a(if defined %%yatv for /F $qtokens=*$q ^!%%yp^!a in ('echo $e%%yatr$e') do ((if $q$e%%yatv:^!%%yp^!a=$e$q==$q$e%%yatv$e$q (set $q%%yatv=$q) else (set $q%%yatv=^!%%yp^!a$q))))$a(if defined %%yneg if defined %%yatv (echo $q%%yatv=$q) else (echo $q%%yatv=$e%%yatr$e$q) else if defined %%yatv (echo $q%%yatv=$e%%yatv$e$q) else (echo $q%%yatv=$q))")^&^
   (for %%a in (vat,gat) do for %%b in (q,a,e) do (call set wds_oba_%%a=%%wds_oba_%%a:$%%b=^^^!wds_oba_%%b^^^!%%))^&^
   (for /F "tokens=*" %%a in ('%%%%ycmd%%^^^!%%ygat^^^!') do (set %%a))^&^
   (if not defined %%yatv (^
    (if ^^^!%%ywto^^^! NEQ 0 (^
     (set %%ywas="(for /F $qtokens=*$q ^!%%yp^!a in ('%%%%ycmd%%$q$e@time_span$e 5:%%ybeg 9:1$q') do (set ^!%%yp^!a))$a(for /L ^!%%yp^!n in (1,1,2147483647) do ((for /F $qtokens=*$q ^!%%yp^!a in ('%%%%ycmd%%$e%%ygat$e') do (set ^!%%yp^!a))$a(if defined %%yatv (echo $q%%yatv=$e%%yatv$e$q$aexit /b 0))$a(if $e%%ywto$e LEQ 0 (echo $q%%yatv=$q$aexit /b 0))$a(if 500 LSS $e%%ywto$e for /F $qtokens=*$q ^!%%yp^!a in ('%%%%ycmd%%$q$e@spinner$e 250$q') do (set ^!%%yp^!a)$rNUL)$a(for /F $qtokens=*$q ^!%%yp^!a in ('%%%%ycmd%%$q$e@time_span$e B:%%ybeg 5:%%ytsp 7:2 9:1$q') do (set ^!%%yp^!a))$aset /a $q%%ybeg+=$e%%ytsp$e$q$rNUL$a(if 86400000 LEQ $e%%ybeg$e (set /a $q%%ybeg-=86400000$q$rNUL))$aset /a $q%%ywto-=$e%%ytsp$e$q$rNUL))")^&^
     (for %%a in (q,a,e,r) do (call set %%ywas=%%%%ywas:$%%a=^^^!wds_oba_%%a^^^!%%))^&^
     (for /F "tokens=*" %%a in ('%%%%ycmd%%^^^!%%ywas^^^!') do (set %%a))^
    ))^
   ))^&^
   (if not defined %%yatv if ^^^!%%ysav^^^! EQU 1 (^
    (for /F "tokens=2 delims==" %%a in ('%%%%ycmd%%^^^!%%yvat^^^!') do (set "%%ytmp=%%a"))^&^
    set "%%yaux="^&^
    (if defined %%ytmp for %%a in (h,s) do if not "^!%%ytmp:%%a=^!"=="^!%%ytmp^!" (^
     (if defined %%yaux (set "%%yaux=^!%%yaux^!%%a") else (set "%%yaux=%%a"))^
    ))^&^
    (if defined %%yaux (^
     (call set %%ytmp="%%%%yaux:^!%%yatr^!=%%")^&^
     (if ^^^!%%ytmp^^^!=="^!%%yaux^!" (set "%%ytmp="))^
    ) else (set "%%ytmp="))^&^
    (if defined %%ytmp (^
     (for %%a in (h,s) do if not "^!%%yaux:%%a=^!"=="^!%%yaux^!" (^
      (if "^!%%yatr^!"=="%%a" (^
       (if defined %%yneg (set "%%ytmp=-%%a") else (set "%%ytmp=+%%a"))^
      ) else (^
       set "%%ytmp=+%%a"^
      ))^&^
      (if defined %%yatv (set "%%yatv=^!%%yatv^! ^!%%ytmp^!") else (set "%%yatv=^!%%ytmp^!"))^
     ))^&^
     attrib ^^^!%%yatv^^^! ^^^!%%yobj^^^!^^^!%%yvla^^^!^
    ) else (^
     (if defined %%yaux for %%a in (h,s) do if not "^!%%yaux:%%a=^!"=="^!%%yaux^!" (^
      (if defined %%yatv (set "%%yatv=^!%%yatv^! -%%a") else (set "%%yatv=-%%a"))^
     ))^&^
     (if defined %%yatv (attrib ^^^!%%yatv^^^! ^^^!%%yobj^^^!^^^!%%yvla^^^!))^&^
     (if defined %%yneg (attrib -^^^!%%yatr^^^! ^^^!%%yobj^^^!^^^!%%yvla^^^!) else (attrib +^^^!%%yatr^^^! ^^^!%%yobj^^^!^^^!%%yvla^^^!))^&^
     (if defined %%yatv (set "%%yatv=^!%%yatv:-=+^!"^&attrib ^^^!%%yatv^^^! ^^^!%%yobj^^^!^^^!%%yvla^^^!))^
    ))^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r ^^^!%%ygat^^^!') do (set %%a))^
   ))^
  ) else (^
   (if "^!%%yobj:~-2,1^!"=="\" (set %%yobj="^!%%yobj:~1,-2^!"))^&^
   set "%%ytmp="^&^
   (for /F "tokens=1,2,3,*" %%a in ('echo "%%%%yp%%%%ya%%%%yp%%" "%%%%yp%%" "%%%%yq%%" cmd /d /q /e:on /v:off /r') do (^
    (set %%yaux=call %%d "set %%ytmp=%%yobj%%~a(for /F %%~cdelims=*%%~c %%~ba in ('call echo.%%~b%%~b%%ytmp%%~b%%~b') do (echo %%yaux=%%~b~aa))")^&^
    (for /F "tokens=*" %%e in ('%%d "%%%%yaux%%"') do (set "%%ytmp=1"^&set "%%e"))^
   ))^&^
   (if defined %%ytmp (^
    call set "%%ytmp=%%%%yaux:^!%%yatr^!=%%"^&^
    (if "^!%%yaux^!"=="^!%%ytmp^!" (set "%%yatv=") else (set "%%yatv=^!%%yatr^!"))^&^
    (if defined %%yneg if defined %%yatv (set "%%yatv=") else (set "%%yatv=^!%%yatr^!"))^
   ) else (echo Error [@obj_attrib]: Failed to read object attributes.^&exit /b 1))^
  ))^&^
  (if defined %%yatv (set "%%yatv=0") else (set "%%yatv=1"))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (^
   set "^!%%ycrn^!=^!%%yatv^!"^&^
   (for %%a in (a,atr,atv,aux,cmd,crn,eco,e,gat,nam,neg,obj,p,pth,q,r,sav,tmp,typ,vat,vla,was,wto) do (set "wds_oba_%%a="))^
  ) else (echo "^!%%ycrn^!=^!%%yatv^!"))^
 )) else (echo Error [@obj_attrib]: The parameters are absent.^&exit /b 1)) else set wds_oba_aux=

::            @obj_size - gets size data of file or folder on disk.
::                        %~1 == the full path to the object on disk (variable name of the calling script or string w/o spaces);
::                      Optional result parameters as names of variables of calling script to initialize (one of them required):
::                      1:%~2 == size in bytes;
::                      2:%~3 == size in kilobytes;
::                      3:%~4 == size in megabytes;
::                      4:%~5 == size in gigabytes;
::                      5:%~6 == number of files in directory;
::                      6:%~7 == number of folders in directory;
::                      7:%~8 == overflow level of units (`1` - bytes, `2` - kb, `3` - mb & `4` - gb);
::                      8:%~9 == key value `1` to echo result instead of assigning, default is `0`.
::                Remark: because of precision limit it gives approximate sizes in KB, MB & GB for sizes bigger than 1 GB.
::
set @obj_size=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_obs_aux (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo %%wds_obs_aux%%') do (^
   (if defined %%a (set "wds_obs_obj=^!%%~a^!") else (set "wds_obs_obj=%%~a"))^&^
   (for %%p in ("nop=0","eco=0","sbn=","skn=","smn=","sgn=","fnn=","dnn=","oln=") do (set "wds_obs_%%~p"))^&^
   (if ^^^!wds_obs_nop^^^! NEQ 0 (echo Error [@obj_size]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%p in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i) do if not "%%p"=="" (^
    set "wds_obs_aux=%%p"^&set "wds_obs_quo=^!wds_obs_aux:~2^!"^&set "wds_obs_aux=^!wds_obs_aux:~0,1^!"^&^
    (if ^^^!wds_obs_aux^^^! EQU 1 (set /a "wds_obs_nop+=1"^>NUL^&set "wds_obs_sbn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 2 (set /a "wds_obs_nop+=1"^>NUL^&set "wds_obs_skn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 3 (set /a "wds_obs_nop+=1"^>NUL^&set "wds_obs_smn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 4 (set /a "wds_obs_nop+=1"^>NUL^&set "wds_obs_sgn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 5 (set "wds_obs_fnn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 6 (set "wds_obs_dnn=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 7 (set "wds_obs_oln=^!wds_obs_quo^!")^
    else if ^^^!wds_obs_aux^^^! EQU 8 ((set /a "wds_obs_eco=^!wds_obs_quo^!"^>NUL 2^>^&1)^>NUL))^
   ))^
  ))^&(if ^^^!wds_obs_nop^^^! EQU 0 (echo Error [@obj_size]: Missing return result parameters.^&exit /b 1))^&^
  (set wds_obs_quo="")^&(call set "wds_obs_quo=%%wds_obs_quo:~1%%")^&(set "wds_obs_amp=1^^^&1")^&(call set "wds_obs_amp=%%wds_obs_amp:~-2,1%%")^&(set wds_obs_rab="^^^>")^&(call set "wds_obs_rab=%%wds_obs_rab:~-2,1%%")^&(set wds_obs_bar="^^^|")^&(call set "wds_obs_bar=%%wds_obs_bar:~-2,1%%")^&^
  call set "wds_obs_obj=%%wds_obs_obj:^!wds_obs_quo^!=%%"^&set "wds_obs_obj=^!wds_obs_obj:\.\=\^!"^&^
  (set wds_obs_obj="^!wds_obs_obj:\\=\^!")^&^
  (for %%a in (^^^!wds_obs_obj^^^!) do (set "wds_obs_obj=%%~sfa"))^&^
  set "wds_obs_aux=1"^&set "wds_obs_slr=0"^&set "wds_obs_sur=0"^&set "wds_obs_dnv=0"^&set "wds_obs_fnv=0"^&set "wds_obs_olv=0"^&^
  (for /F "usebackq tokens=1,2 delims==" %%a in (`"wmic datafile where name^^='^!wds_obs_obj:\=\\^!' get /format:list 2%%wds_obs_rab%%%%wds_obs_amp%%1 %%wds_obs_bar%% findstr FileSize"`) do if not "%%~b"== "" (^
   set "wds_obs_aux="^&^
   call set "wds_obs_sur=%%b"^&set "wds_obs_slr=^!wds_obs_sur:~-9,9^!"^&call set "wds_obs_sur=%%wds_obs_sur:^!wds_obs_slr^!=%%"^&^
   (if defined wds_obs_sur for /F "tokens=* delims=0" %%c in ('echo.%%wds_obs_slr%%') do if "%%~c"=="" (set "wds_obs_slr=0") else (^
    (set /a "wds_obs_tmp=%%c"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_obs_tmp^!"=="%%c" (set "wds_obs_slr=%%c"))^
   ))^
  ))^&^
  (if defined wds_obs_aux (^
   (for /F "usebackq tokens=*" %%a in (`"wmic fsdir where name^^='^!wds_obs_obj:\=\\^!' get /format:list 2%%wds_obs_rab%%%%wds_obs_amp%%1 %%wds_obs_bar%% findstr Readable=TRUE"`) do if not "%%~a"== "" (^
    (for /F "tokens=*" %%b in ('dir /a /s /b "^!wds_obs_obj^!"') do (^
     set "wds_obs_aux=%%~ab"^&^
     (if "^!wds_obs_aux^!"=="^!wds_obs_aux:d=^!" (^
      set "wds_obs_rur=%%~zb"^&set "wds_obs_rlr=^!wds_obs_rur:~-9,9^!"^&call set "wds_obs_rur=%%wds_obs_rur:^!wds_obs_rlr^!=%%"^&^
      (if defined wds_obs_rur for /F "tokens=* delims=0" %%c in ('echo.%%wds_obs_rlr%%') do if "%%~c"=="" (set "wds_obs_rlr=0") else (^
       (set /a "wds_obs_tmp=%%c"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_obs_tmp^!"=="%%c" (set "wds_obs_rlr=%%c"))^
      ))^&^
      set /a "wds_obs_aux=^!wds_obs_slr^!+^!wds_obs_rlr^!"^>NUL^&^
      set "wds_obs_slr=^!wds_obs_aux:~-9,9^!"^&call set "wds_obs_aux=%%wds_obs_aux:^!wds_obs_slr^!=%%"^&^
      (if defined wds_obs_aux for /F "tokens=* delims=0" %%c in ('echo.%%wds_obs_slr%%') do if "%%~c"=="" (set "wds_obs_slr=0") else (^
       (set /a "wds_obs_tmp=%%c"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_obs_tmp^!"=="%%c" (set "wds_obs_slr=%%c"))^
      ))^&^
      (if defined wds_obs_rur (set /a "wds_obs_sur+=^!wds_obs_rur^!"^>NUL))^&^
      (if defined wds_obs_aux (set /a "wds_obs_sur+=^!wds_obs_aux^!"^>NUL))^&^
      set /a "wds_obs_fnv+=1"^>NUL^
     ) else (set /a "wds_obs_dnv+=1"^>NUL))^
    ))^&^
    set "wds_obs_rur="^&set "wds_obs_rlr="^&(if ^^^!wds_obs_sur^^^! EQU 0 (set "wds_obs_sur="))^
   ))^
  ))^&^
  (if defined wds_obs_sur (set "wds_obs_olv=1"^&set "wds_obs_sbv=^!wds_obs_sur^!^!wds_obs_slr^!") else (set "wds_obs_sbv=^!wds_obs_slr^!"))^&^
  (for /L %%a in (1,1,3) do (^
   set /a "wds_obs_slr=^!wds_obs_slr^!/1024"^>NUL^&^
   (if defined wds_obs_sur (^
    (if 1048576 LSS ^^^!wds_obs_sur^^^! (^
     set /a "wds_obs_sur=^!wds_obs_sur^!/1024"^>NUL^&^
     (if defined wds_obs_sur (set "wds_obs_s%%av=^!wds_obs_sur^!^!wds_obs_slr^!") else (set "wds_obs_s%%av=^!wds_obs_slr^!"))^
    ) else (^
     (if 1024 LEQ ^^^!wds_obs_sur^^^! (^
      set /a "wds_obs_sur=(1000*^!wds_obs_sur^!)/1024"^>NUL^&set "wds_obs_aux=^!wds_obs_sur:~-3,3^!"^&^
      (if "^!wds_obs_aux^!"=="^!wds_obs_sur^!" (set "wds_obs_sur=") else (^
       call set "wds_obs_sur=%%wds_obs_sur:~0,-3%%"^&^
       (for /F "tokens=* delims=0" %%b in ('echo.%%wds_obs_aux%%') do if "%%~b"=="" (set "wds_obs_aux=0") else (^
        (set /a "wds_obs_tmp=%%b"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_obs_tmp^!"=="%%b" (set "wds_obs_aux=%%b"))^
       ))^
      ))^&^
      set /a "wds_obs_slr+=1000000*^!wds_obs_aux^!"^>NUL^
     ) else if 1 LEQ ^^^!wds_obs_sur^^^! (^
      set /a "wds_obs_sur=(1000000*^!wds_obs_sur^!)/1024"^>NUL^&set "wds_obs_aux=^!wds_obs_sur:~-6,6^!"^&^
      (if "^!wds_obs_aux^!"=="^!wds_obs_sur^!" (set "wds_obs_sur=") else (^
       call set "wds_obs_sur=%%wds_obs_sur:~0,-6%%"^&^
       (for /F "tokens=* delims=0" %%b in ('echo.%%wds_obs_aux%%') do if "%%~b"=="" (set "wds_obs_aux=0") else (^
        (set /a "wds_obs_tmp=%%b"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_obs_tmp^!"=="%%b" (set "wds_obs_aux=%%b"))^
       ))^
      ))^&^
      set /a "wds_obs_slr+=1000*^!wds_obs_aux^!"^>NUL^
     ))^&^
     (if defined wds_obs_sur (set "wds_obs_s%%av=^!wds_obs_sur^!^!wds_obs_slr^!") else (set "wds_obs_s%%av=^!wds_obs_slr^!"))^
    ))^&^
    (if defined wds_obs_sur (set /a "wds_obs_olv+=1"^>NUL))^
   ) else (set "wds_obs_s%%av=^!wds_obs_slr^!"))^
  ))^&^
  (if ^^^!wds_obs_eco^^^! NEQ 1 (^
   (if defined wds_obs_sbn (set "^!wds_obs_sbn^!=^!wds_obs_sbv^!"))^&(if defined wds_obs_skn (set "^!wds_obs_skn^!=^!wds_obs_s1v^!"))^&^
   (if defined wds_obs_smn (set "^!wds_obs_smn^!=^!wds_obs_s2v^!"))^&(if defined wds_obs_sgn (set "^!wds_obs_sgn^!=^!wds_obs_s3v^!"))^&^
   (if defined wds_obs_fnn (set "^!wds_obs_fnn^!=^!wds_obs_fnv^!"))^&(if defined wds_obs_dnn (set "^!wds_obs_dnn^!=^!wds_obs_dnv^!"))^&^
   (if defined wds_obs_oln (set "^!wds_obs_oln^!=^!wds_obs_olv^!"))^&^
   (for %%m in (amp,aux,bar,fnn,fnv,dnn,dnv,oln,olv,nop,obj,eco,quo,rab,sbn,sbv,skn,s1v,smn,s2v,sur,slr,sgn,s3v,tmp) do (set "wds_obs_%%m="))^
  ) else (^
   (if defined wds_obs_sbn (echo "^!wds_obs_sbn^!=^!wds_obs_sbv^!"))^&(if defined wds_obs_skn (echo "^!wds_obs_skn^!=^!wds_obs_s1v^!"))^&^
   (if defined wds_obs_smn (echo "^!wds_obs_smn^!=^!wds_obs_s2v^!"))^&(if defined wds_obs_sgn (echo "^!wds_obs_sgn^!=^!wds_obs_s3v^!"))^&^
   (if defined wds_obs_fnn (echo "^!wds_obs_fnn^!=^!wds_obs_fnv^!"))^&(if defined wds_obs_dnn (echo "^!wds_obs_dnn^!=^!wds_obs_dnv^!"))^&^
   (if defined wds_obs_oln (echo "^!wds_obs_oln^!=^!wds_obs_olv^!"))^
  ))^
 ) else (echo Error [@obj_size]: The parameters are absent.^&exit /b 1)) else set wds_obs_aux=

::          @disk_space - gets total, free & used space of specified volume (for instance `C:`).
::                        %~1 == the drive letter (variable name of the calling script with value or drive letter explicitly);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~2 == key parameter defines units of result: `0` - bytes, `1` - kb, `2` - mb (default) & `3` - gb;
::                      Optional result parameters as names of variables of calling script to initialize (one of them required):
::                      2:%~3 == total space;
::                      3:%~4 == free space;
::                      4:%~5 == used space;
::                      5:%~6 == overflow flag of result (string-only) for given units (sum of `1` - total, `2` - free, `4` - used);
::                      6:%~7 == key value `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: because of precision limit it gives approximate sizes in KB, MB & GB for sizes bigger than 1 GB;
::                    #2: internally macro uses wmic tool for reading system data, it returns result only for local drives.
::
set @disk_space=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_vos_aux (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo %%wds_vos_aux%%') do (^
   (if defined %%a (set "wds_vos_dvl=^!%%~a^!") else (set "wds_vos_dvl=%%~a"))^&^
   (for %%h in ("nop=0","urt=2","eco=0","tsn=","fsn=","usn=") do (set "wds_vos_%%~h"))^&^
   (if ^^^!wds_vos_nop^^^! NEQ 0 (echo Error [@disk_space]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%h in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "wds_vos_aux=%%h"^&set "wds_vos_quo=^!wds_vos_aux:~2^!"^&set "wds_vos_aux=^!wds_vos_aux:~0,1^!"^&^
    (if ^^^!wds_vos_aux^^^! EQU 1 ((set /a "wds_vos_urt=^!wds_vos_quo^!"^>NUL 2^>^&1)^>NUL)^
    else if ^^^!wds_vos_aux^^^! EQU 2 (set /a "wds_vos_nop+=1"^>NUL^&set "wds_vos_tsn=^!wds_vos_quo^!")^
    else if ^^^!wds_vos_aux^^^! EQU 3 (set /a "wds_vos_nop+=1"^>NUL^&set "wds_vos_fsn=^!wds_vos_quo^!")^
    else if ^^^!wds_vos_aux^^^! EQU 4 (set /a "wds_vos_nop+=1"^>NUL^&set "wds_vos_usn=^!wds_vos_quo^!")^
    else if ^^^!wds_vos_aux^^^! EQU 5 (set "wds_vos_oln=^!wds_vos_quo^!")^
    else if ^^^!wds_vos_aux^^^! EQU 6 ((set /a "wds_vos_eco=^!wds_vos_quo^!"^>NUL 2^>^&1)^>NUL))^
   ))^
  ))^&(if ^^^!wds_vos_nop^^^! EQU 0 (echo Error [@disk_space]: Missing return result parameters.^&exit /b 1))^&^
  (set wds_vos_quo="")^&(call set "wds_vos_quo=%%wds_vos_quo:~1%%")^&call set "wds_vos_dvl=%%wds_vos_dvl:^!wds_vos_quo^!=%%"^&^
  set "wds_vos_dvl=^!wds_vos_dvl: =^!"^&set "wds_vos_dvl=^!wds_vos_dvl:'=^!"^&(set "wds_vos_dvl=^!wds_vos_dvl:~0,2^!")^&^
  (if not "^!wds_vos_dvl:~1,1^!"==":" (echo Error [@disk_space]: Unexpected drive letter parameter, expected for example 'C:'.^&exit /b 1))^&^
  (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2" %%b in ('echo %%a') do for /F "tokens=1,2 delims=." %%c in ('echo %%b') do (^
   (if %%c%%d LSS 61 (^
    set "wds_vos_aux=logicaldisk where Caption^='^!wds_vos_dvl^!' get Size"^
   ) else (^
    set "wds_vos_aux=volume where DriveLetter^='^!wds_vos_dvl^!' get Capacity"^
   ))^
  ))^&^
  (set wds_vos_nop="^^^|")^&^
  (for /F "usebackq tokens=1,2 delims==" %%a in (`"wmic %%wds_vos_aux%%,FreeSpace /value 2^>^&1 %%wds_vos_nop:~-2,1%% findstr [a-z]"`) do (^
   if "%%~a"=="FreeSpace" (^
    (if defined wds_vos_fsn (call set "wds_vos_fur=%%b") else if defined wds_vos_usn (call set "wds_vos_fur=%%b"))^
   ) else (^
    (if defined wds_vos_tsn (call set "wds_vos_tur=%%b"))^&(if defined wds_vos_usn (call set "wds_vos_uur=%%b"))^
   )^
  ))^&^
  set "wds_vos_olv=0"^&^
  (for %%a in ("wds_vos_tur=wds_vos_tlr=1","wds_vos_fur=wds_vos_flr=2","wds_vos_uur=wds_vos_ulr=4") do for /F "tokens=1,2,3 delims==" %%b in (%%a) do if defined %%b (^
   set "%%c=^!%%b:~-9,9^!"^&call set "%%b=%%%%b:^!%%c^!=%%"^&^
   (for /F "tokens=* delims=0" %%e in ('echo.%%%%c%%') do if "%%~e"=="" (set "%%c=0") else (^
    (set /a "wds_vos_tmp=%%e"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_vos_tmp^!"=="%%e" (set "%%c=%%e"))^
   ))^&^
   (if defined %%b (set /a "wds_vos_olv+=%%d"^>NUL))^
  ))^&^
  (if defined wds_vos_ulr (^
   set /a "wds_vos_uur-=^!wds_vos_fur^!"^>NUL^&^
   (if ^^^!wds_vos_ulr^^^! LSS ^^^!wds_vos_flr^^^! (^
    set /a "wds_vos_uur-=1"^>NUL^&set /a "wds_vos_ulr=(999999999-^!wds_vos_flr^!)+1+^!wds_vos_ulr^!"^>NUL^
   ) else (^
    set /a "wds_vos_ulr-=^!wds_vos_flr^!"^>NUL^
   ))^
  ))^&^
  (if 0 LSS ^^^!wds_vos_urt^^^! (set "wds_vos_olv=0"))^&^
  (for %%a in ("wds_vos_tur=wds_vos_tlr=1","wds_vos_fur=wds_vos_flr=2","wds_vos_uur=wds_vos_ulr=4") do for /F "tokens=1,2,3 delims==" %%b in (%%a) do if defined %%b (^
   (for /L %%e in (1,1,^^^!wds_vos_urt^^^!) do (^
    set /a "%%c=^!%%c^!/1024"^>NUL^&set "wds_vos_nop=0"^&^
    (if defined %%b (^
     (if 1048576 LSS ^^^!%%b^^^! (^
      set /a "%%b=^!%%b^!/1024"^>NUL^
     ) else (^
      (if 1024 LEQ ^^^!%%b^^^! (^
       set /a "%%b=(1000*^!%%b^!)/1024"^>NUL^&set "wds_vos_aux=^!%%b:~-3,3^!"^&^
       (if "^!wds_vos_aux^!"=="^!%%b^!" (set "%%b=") else (^
        call set "%%b=%%%%b:~0,-3%%"^&^
        (for /F "tokens=* delims=0" %%e in ('echo.%%wds_vos_aux%%') do if "%%~e"=="" (set "wds_vos_aux=0") else (^
         (set /a "wds_vos_tmp=%%e"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_vos_tmp^!"=="%%e" (set "wds_vos_aux=%%e"))^
        ))^
       ))^&^
       set /a "%%c+=1000000*^!wds_vos_aux^!"^>NUL^
      ) else if 1 LEQ ^^^!%%b^^^! (^
       set /a "%%b=(1000000*^!%%b^!)/1024"^>NUL^&set "wds_vos_aux=^!%%b:~-6,6^!"^&^
       (if "^!wds_vos_aux^!"=="^!%%b^!" (set "%%b=") else (^
        call set "%%b=%%%%b:~0,-6%%"^&^
        (for /F "tokens=* delims=0" %%e in ('echo.%%wds_vos_aux%%') do if "%%~e"=="" (set "wds_vos_aux=0") else (^
         (set /a "wds_vos_tmp=%%e"^>NUL 2^>^&1)^>NUL ^&^& (if "^!wds_vos_tmp^!"=="%%e" (set "wds_vos_aux=%%e"))^
        ))^
       ))^&^
       set /a "%%c+=1000*^!wds_vos_aux^!"^>NUL^
      ))^
     ))^&^
     (if defined %%b (set "wds_vos_nop=%%d"))^
    ))^
   ))^&^
   (if 0 LSS ^^^!wds_vos_urt^^^! (set /a "wds_vos_olv+=^!wds_vos_nop^!"^>NUL))^
  ))^&^
  (if ^^^!wds_vos_eco^^^! NEQ 1 (^
   (if defined wds_vos_tsn (if defined wds_vos_tur (set "^!wds_vos_tsn^!=^!wds_vos_tur^!^!wds_vos_tlr^!") else (set "^!wds_vos_tsn^!=^!wds_vos_tlr^!")))^&^
   (if defined wds_vos_fsn (if defined wds_vos_fur (set "^!wds_vos_fsn^!=^!wds_vos_fur^!^!wds_vos_flr^!") else (set "^!wds_vos_fsn^!=^!wds_vos_flr^!")))^&^
   (if defined wds_vos_usn (if defined wds_vos_uur (set "^!wds_vos_usn^!=^!wds_vos_uur^!^!wds_vos_ulr^!") else (set "^!wds_vos_usn^!=^!wds_vos_ulr^!")))^&^
   (if defined wds_vos_oln (set "^!wds_vos_oln^!=^!wds_vos_olv^!"))^&^
   (for %%m in (aux,tsn,tur,tlr,fsn,fur,flr,usn,uur,ulr,oln,olv,nop,dvl,quo,tmp,urt,eco) do (set "wds_vos_%%m="))^
  ) else (^
   (if defined wds_vos_tsn (if defined wds_vos_tur (echo "^!wds_vos_tsn^!=^!wds_vos_tur^!^!wds_vos_tlr^!") else (echo "^!wds_vos_tsn^!=^!wds_vos_tlr^!")))^&^
   (if defined wds_vos_fsn (if defined wds_vos_fur (echo "^!wds_vos_fsn^!=^!wds_vos_fur^!^!wds_vos_flr^!") else (echo "^!wds_vos_fsn^!=^!wds_vos_flr^!")))^&^
   (if defined wds_vos_usn (if defined wds_vos_uur (echo "^!wds_vos_usn^!=^!wds_vos_uur^!^!wds_vos_ulr^!") else (echo "^!wds_vos_usn^!=^!wds_vos_ulr^!")))^&^
   (if defined wds_vos_oln (echo "^!wds_vos_oln^!=^!wds_vos_olv^!"))^
  ))^
 ) else (echo Error [@disk_space]: The parameters are absent.^&exit /b 1)) else set wds_vos_aux=

::               @exist - checks the file/folder exists on disk, spins several checks.
::                        %~1 == name of variable of calling script to return common result (0/1 <==> True/False);
::                        %~2 == the full path to the object on disk (variable name of the calling script or string w/o spaces);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == name of variable of calling script to return count of successful object detections;
::                      2:%~4 == total number of checks (in/out), input default value is 3 checks (variable name or quoted number);
::                      3:%~5 == key parameter:
::                               `0` - default value to continue checks regardless of the current result;
::                               `1` - break if the item was not found;
::                               `2` - break if the item was found;
::                      4:%~6 == the name of variable to assign time spent (msec);
::                      5:%~7 == key parameter `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: the number of checks must be in range [1..100], parameter `2:%~4` can be value or its variable name;
::                    #2: it returns `0` (True) into `%~1` only in the case of all checks were successful.
::          Dependencies: @time_span.
::
set @exist=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_exs_aux for %%y in (wds_exs_) do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%yaux%%') do (^
   (for /F "tokens=*" %%p in ('cmd /d /q /e:on /v:on /r "^!@time_span^! 5:%%ybeg 9:1"') do (set %%p))^&^
   set "%%yren=%%~a"^&(if not "^!%%yren^!"=="%%~a" (echo Error [@exist]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if defined %%b (set "%%ydob=^!%%~b^!") else (set "%%ydob=%%~b"))^&^
   (if not defined %%ydob (echo Error [@exist]: Missing 2nd parameter.^&exit /b 1))^&^
   (for %%i in ("rev=1","rcn=","rcv=0","tsn=","ccv=3","cck=0","eco=0") do (set "wds_exs_%%~i"))^&^
   (for %%i in (%%~c,%%~d,%%~e,%%~f,%%~g) do if not "%%i"=="" (^
    set "%%yaux=%%i"^&set "%%yquo=^!%%yaux:~2^!"^&^
    (if defined %%yquo (^
     set "%%yaux=^!%%yaux:~0,1^!"^&^
         (if ^^^!%%yaux^^^! EQU 1 (set "%%yrcn=^!%%yquo^!")^
     else if ^^^!%%yaux^^^! EQU 2 (^
      (for /F "tokens=*" %%j in ('echo %%%%yquo%%') do (^
       (if "%%~j"==%%j (set "%%yquo=%%~j") else (set "%%yccn=%%~j"^&set "%%yquo=^!%%~j^!"))^&^
       (set /a "%%yaux=0x^!%%yquo^!"^>NUL 2^>^&1)^>NUL ^&^& (^
        if 0 LSS ^^^!%%yaux^^^! if ^^^!%%yaux^^^! LSS 257 (set "%%yccv=^!%%yquo^!")^
       )^
      ))^
     ) else if ^^^!%%yaux^^^! EQU 3 (^
      (set /a "%%ycck=^!%%yquo^!"^>NUL 2^>^&1)^>NUL^&^
      (if ^^^!%%ycck^^^! LSS 0 (set "%%ycck=0") else if 2 LSS ^^^!%%ycck^^^! (set "%%ycck=0"))^
     ) else if ^^^!%%yaux^^^! EQU 4 (set "%%ytsn=^!%%yquo^!")^
     else if ^^^!%%yaux^^^! EQU 5 (if ^^^!%%yquo^^^! EQU 1 (set "%%yeco=1")))^
    ))^
   ))^
  ))^&(if not defined %%yeco (echo Error [@exist]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%yquo="")^&(call set "%%yquo=%%%%yquo:~1%%")^&call set "%%ydob=%%%%ydob:^!%%yquo^!=%%"^&set "%%yquo="^&^
  set "%%yaux=^!%%yccv^!"^&set "%%yccv=0"^&set "%%ytsv=0"^&^
  (for /L %%a in (1,1,^^^!%%yaux^^^!) do if ^^^!%%yaux^^^! NEQ 0 (^
   (for /F "tokens=*" %%b in ('cmd /d /q /e:on /v:on /r "^!@time_span^! B:%%ybeg 5:%%ytsv 6:%%yaux 7:2 9:1"') do (set %%b))^&^
   set /a "%%ytsv+=5*^!%%yaux^!"/4^>NUL^&^
   (if exist "^!%%ydob^!" (^
    set /a "%%yrcv+=1"^>NUL^&^
    (if ^^^!%%ycck^^^! EQU 2 (set "%%yaux=0"))^
   ) else (^
    (if ^^^!%%ycck^^^! EQU 1 (set "%%yaux=0"))^
   ))^&^
   set /a "%%yccv+=1"^>NUL^
  ))^&^
  (if ^^^!%%yrcv^^^! EQU ^^^!%%yccv^^^! (set "%%yrev=0"))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (set "^!%%yren^!=^!%%yrev^!") else (echo "^!%%yren^!=^!%%yrev^!"))^&^
  (if defined %%yrcn (^
   (if ^^^!%%yeco^^^! NEQ 1 (set "^!%%yrcn^!=^!%%yrcv^!") else (echo "^!%%yrcn^!=^!%%yrcv^!"))^
  ))^&^
  (if defined %%yccn (^
   (if ^^^!%%yeco^^^! NEQ 1 (set "^!%%yccn^!=^!%%yccv^!") else (echo "^!%%yccn^!=^!%%yccv^!"))^
  ))^&^
  (if defined %%ytsn (^
   (if ^^^!%%yeco^^^! NEQ 1 (set "^!%%ytsn^!=^!%%ytsv^!") else (echo "^!%%ytsn^!=^!%%ytsv^!"))^
  ))^&^
  (if ^^^!%%yeco^^^! NEQ 1 for %%a in (aux,dob,rcn,rcv,ccn,ccv,eco,cck,ren,rev,tsn,tsv,beg) do (set "wds_exs_%%a="))^
 ) else (echo Error [@exist]: The parameters are absent.^&exit /b 1)) else set wds_exs_aux=

::         @exist_check - checks the file/folder exists using @exist macro, verifies result by comparing content of parent folder.
::                        %~1 == the name of the object on disk (variable name of the calling script or string w/o spaces);
::                        %~2 == name of variable of calling script to return digital result:
::                               `-3`      - the root folder was not found;
::                               `-2`      - the object was not found, content of folder had changes during checks;
::                               `-1`      - the object was not found and content of folder had not changes;
::                               `+0`      - the object was found at ~50 % of checks and content of folder had changes;
::                               `+1`      - the object was found and content of folder had not changes;
::                               `+2`      - the object was found, content of folder had changes during checks;
::                               `<empty>` - undefined result in the case of internal error in the process;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == the timeout value for case of uncertain results [5000...86400000], default is 3600000 msec;
::                      2:%~4 == key parameter `1` to echo result instead of assigning, default is `0`.
::          Dependencies: @exist, @time_span.
::
set @exist_check=^
 for %%z in (1 2) do if %%z EQU 2 (if defined wds_exc_aux for /F %%y in ('echo wds_exc_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%yaux%%') do (^
   (for /F "tokens=*" %%e in ('cmd /d /q /e:on /v:on /r "^!@time_span^! 5:%%ybeg 9:1"') do (set %%e))^&^
   set "%%yrcn=%%~b"^&^
   (if not "^!%%yrcn^!"=="%%~b" (echo Error [@exist_check]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if defined %%yrcn if not "^!%%yrcn::=^!"=="^!%%yrcn^!" (set "%%yrcn="))^&^
   (if not defined %%yrcn (echo Error [@exist_check]: Missing return result parameter.^&exit /b 1))^&^
   (if defined %%a (set "%%ydob=^!%%~a^!") else (set "%%ydob=%%a"))^&^
   set "%%ytov=3600000"^&set "%%yeco=0"^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%yaux=%%e"^&set "%%yq=^!%%yaux:~2^!"^&set "%%yaux=^!%%yaux:~0,1^!"^&^
    (if ^^^!%%yaux^^^! EQU 1 (^
     for /F "tokens=* delims=+,-,0" %%g in ('echo.%%%%yq%%') do ((set /a "%%yq=%%~g"^>NUL 2^>^&1)^>NUL ^&^& (^
      if "^!%%yq^!"=="%%~g" if 5000 LEQ %%~g if %%~g LEQ 86400000 (set "%%ytov=%%~g")^
     ))^
    ) else if ^^^!%%yaux^^^! EQU 2 (^
     (set /a "%%yeco=^!%%yq^!"^>NUL 2^>^&1)^>NUL^&(if not "^!%%yeco^!"=="0" if not "^!%%yeco^!"=="1" (set "%%yeco=0"))^
    ))^
   ))^
  ))^&(if not defined %%yeco (echo Error [@exist_check]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%yj="(for /F $qtokens=1,2,3,4$q %%^^a in ('echo #dob $q$e#q$e=$q $q\.\=\$q $q\\=\$q') do ((call set %%^^a=$q%%%%^^a:%%^^~b%%$q)$aset $q%%^^a=$e%%^^a:%%^^~c$e$q$aset $q%%^^a=$e%%^^a:%%^^~d$e$q))$a(for %%^^a in ($qc1o=$q,$qmod=0$q,$qpth=$q$q$q) do (set $q#%%^^~a$q))$a(for /L %%^^a in (1,1,4) do (set $q#mc%%^^a=$q$aset $q#fc%%^^a=$q))$a(for /L %%^^a in (1,1,2147483647) do ((for /F $qtokens=*$q %%^^b in ('cmd /d /q /e:on /v:on /r $q$e@time_span$e B:#beg 5:#tsp 7:2 9:1$q') do (set %%^^b))$a(if exist $e#pth$e (set /a $q#tot+=1$q$rNUL$aset $q#cnt=0$q$aset $q#fnd=0$q$a(for /F $qtokens=*$q %%^^b in ('$qdir /a /b $e#pth$e$q') do (set /a $q#cnt+=1$q$rNUL))$a(for /F $qtokens=*$q %%^^b in ('$qdir /a /b $e#sdo$e$q') do (set $q#fnd=1$q))$a(if defined #c1o if $e#c1o$e EQU $e#cnt$e (set $q#mod=1$q) else (set $q#mod=2$q))$aset $q#mc4=$e#mod$e$q$aset $q#c1o=$e#cnt$e$q$a(for /F $qtokens=*$q %%^^b in ('cmd /d /q /v:on /e:on /r $q$e@exist$e #cnt #sdo 2:$q1$q 5:1$q') do (set %%^^b))$a(if $e#cnt$e EQU 0 (set /a $q#fnd+=1$q$rNUL))$aset $q#fc4=$e#fnd$e$q$aset $q#chk=1$q$a(for %%^^b in ($q2 1$q,$q3 2$q,$q4 3$q) do for /F $qtokens=1,2$q %%^^c in ('echo %%^^~b') do ((if defined #fc%%^^c (set $q#mc%%^^d=$e#mc%%^^c$e$q$aset $q#fc%%^^d=$e#fc%%^^c$e$q) else (set $q#chk=0$q))))$a(if $e#chk$e EQU 1 ((if $e#tov$e LSS $e#tsp$e (set $q#chm=6$q$aset $q#chf=6$q) else (set $q#chm=0$q$aset $q#chf=0$q$a(for %%^^b in ($q1 2$q,$q1 3$q,$q1 4$q,$q2 3$q,$q2 4$q,$q3 4$q) do for /F $qtokens=1,2$q %%^^c in ('echo %%^^~b') do ((if $e#mc%%^^c$e EQU $e#mc%%^^d$e (set /a $q#chm+=1$q$rNUL))$a(if $e#fc%%^^c$e EQU $e#fc%%^^d$e (set /a $q#chf+=1$q$rNUL))))))$a(if $e#chm$e EQU 6 if $e#chf$e EQU 6 (set /a $q#fnd=$e#mod$e*($e#fnd$e-1)$q$rNUL$aecho $q#rcv=$e#fnd$e$q$aexit /b 0))))) else ((if $e#tov$e LSS $e#tsp$e (echo $q#rcv=-3$q$aexit /b 0))$a(for /F $qtokens=*$q %%^^b in ('$qcall echo.$e#dob$e$q') do ((set #pth=$q%%^^~db%%^^~spb$q)$a(set #fnm=$q%%^^~snb%%^^~sxb$q)$a(if $e#fnm$e==$q$q ((set #pth=$q$e#pth:~1,-2$e$q)$a(for /F $qtokens=*$q %%^^c in ('$qcall echo.$e#pth$e$q') do ((set #pth=$q%%^^~dc%%^^~spc$q)$a(set #fnm=$q%%^^~snc%%^^~sxc$q)))))))$a(set #sdo=$q$e#pth:~1,-1$e$e#fnm:~1,-1$e$q)))))")^&^
  (set %%yq="")^&(set %%ye="^^^^^!^^^!^^^!")^&(set %%ya="^^^&")^&(set %%yr="^^^>")^&^
  (for %%a in (q,a,e,r) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"^&(call set %%yj=%%%%yj:$%%a=^^^!%%y%%a^^^!%%)))^&^
  (call set %%yj=%%%%yj:#=%%y%%)^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r ^^^!%%yj^^^!') do (set %%a))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (^
   (if defined %%yrcn if defined %%yrcv (set "^!%%yrcn^!=^!%%yrcv^!") else (set "^!%%yrcn^!="))^&^
   (for %%a in (aux,a,beg,dob,eco,e,j,q,r,rcn,rcv,tov) do (set "%%y%%a="))^
  ) else (^
   (if defined %%yrcn if defined %%yrcv (echo "^!%%yrcn^!=^!%%yrcv^!") else (echo "^!%%yrcn^!="))^
  ))^
 ) else (echo Error [@exist_check]: The parameters are absent.^&exit /b 1)) else set wds_exc_aux=
 
::         @obj_newname - searches absent name in the specified location for the new object (file/folder) to be created.
::                        %~1 == name of external variable to set string of found name in format: `%~3digit%~4`;
::                      Optional quoted string values without spaces or variable names, after identifiers and marker ":":
::                      1:%~2 == path to create a new object, default is current folder;
::                      2:%~3 == prefix for file name;
::                      3:%~4 == suffix for file name (includes extension for a planned file, required for correct search);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      4:%~5 == create new empty file immediately (`1`), default is `0` (valuable only for new files);
::                      5:%~6 == key parameter `1` to return full name, default is `0` to return file name only;
::                      6:%~7 == key parameter `1` to echo result instead of assigning, default is `0`.
::             Notes. #1: `1:%~2`..`3:%~4` support replacement of space symbol by its code `/CHR{20}`;
::                    #2: macro creates new name by generating random digital substring of string, its total length is 4 digits;
::                    #3: the total number of attempts is 32, which roughly corresponds to failure in the case of the total number 
::                        of existing files in the folder `> 9950`. The process takes no more than 18 sec in worst case;
::                    #4: on search failure it sets an empty string to `%~1`.
::
set @obj_newname=^
 for %%z in (1 2) do if %%z EQU 2 (if defined wds_onn_aux for /F %%p in ('echo wds_onn') do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_nnn=%%~a"^&(if not "^!%%p_nnn^!"=="%%~a" (echo Error [@obj_newname]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if defined %%p_nnn if not "^!%%p_nnn::=^!"=="^!%%p_nnn^!" (set "%%p_nnn="))^&(if not defined %%p_nnn (echo Error [@obj_newname]: Missing return result parameter.^&exit /b 1))^&^
   (for %%g in ("quo=123","pat=","pfx=""","sfx=""","add=0","eco=0","nnv=","ful=0") do (set "%%p_%%~g"))^&^
   (for %%h in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "%%p_aux=%%h"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (^
     set "%%p_aux=^!%%p_aux:~0,1^!"^&call set "%%p_amp=%%%%p_quo:^!%%p_aux^!=%%"^&^
     (if "^!%%p_amp^!"=="^!%%p_quo^!" (^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (^
       (if 0 LEQ ^^^!%%p_tmp^^^! if ^^^!%%p_tmp^^^! LEQ 1 (^
        set %%p_amp=4^&^
        (for %%i in (add,ful,eco) do ((if ^^^!%%p_aux^^^! EQU ^^^!%%p_amp^^^! (set "%%p_%%i=^!%%p_tmp^!"))^&set /a "%%p_amp+=1"^>NUL))^
       ))^
      )^
     ) else (^
      (for /F "tokens=*" %%h in ('"echo ^!%%p_tmp^!"') do if "%%~h"==%%h (set "%%p_tmp=%%~h") else (call set "%%p_tmp=%%%%~h%%"))^&^
      (if defined %%p_tmp (^
       set "%%p_tmp=^!%%p_tmp:/CHR{20}= ^!"^&^
       (if ^^^!%%p_amp^^^! EQU 23 (set "%%p_pat=^!%%p_tmp^!") else if ^^^!%%p_amp^^^! EQU 13 (set %%p_pfx="^!%%p_tmp^!") else (set %%p_sfx="^!%%p_tmp^!"))^
      ))^
     ))^
    ))^
   ))^
  ))^&^
  (set "%%p_amp=1^^^&1")^&(set %%p_exc="^^^^^!^^^!^^^!")^&(set %%p_quo="")^&(set %%p_rab="^^^>")^&^
  (for %%a in (amp,exc,quo,rab) do (call set "%%p_%%a=%%%%p_%%a:~-2,1%%"))^&^
  (if not defined %%p_pat for /F "tokens=*" %%a in ('"echo.%%~n0%%~x0"') do (set "%%p_pat=%%~da%%~spa"))^&^
  call set "%%p_pat=%%%%p_pat:^!%%p_quo^!=%%\"^&set "%%p_pat=^!%%p_pat:\.\=\^!"^&set "%%p_pat=^!%%p_pat:\\=\^!"^&^
  (if exist "^!%%p_pat^!" (for %%a in ("^!%%p_pat^!") do (set "%%p_pat=%%~sfa")) else (^
   echo Error [@obj_newname]: Not valid path.^&exit /b 1^
  ))^&^
  set "%%p_sch=(for /L %%^^a in (1,1,16) do (set $q#nnv=$e#pfx:~1,-1$e$q$a(for /L %%^^b in (1,1,4) do for /F $qtokens=2 delims=.+$q %%^^c in ('wmic os get LocalDateTime /value') do (set $q#rdv=%%^^c$q$a(if defined #nnv (set $q#nnv=$e#nnv$e$e#rdv:~2,1$e$q) else (set $q#nnv=$e#rdv:~2,1$e$q))))$aset $q#nnv=$e#nnv$e$e#sfx:~1,-1$e$q$a(if not exist $q$e#nnv$e$q ((ping -n 1 -w 5 192.168.254.254 $rNUL 2$r$a1)$a(if not exist $q$e#nnv$e$q (echo $q#nnv=$e#nnv$e$q$aexit /b 0))))))"^&^
  (for %%a in ("$a=^%%%%p_amp^%%","$e=^%%%%p_exc^%%","$q=^%%%%p_quo^%%","$r=^%%%%p_rab^%%","#=%%p_") do (set "%%p_sch=^!%%p_sch:%%~a^!"))^&^
  (for %%a in (1 2) do if not defined %%p_nnv (^
   (for /F %%b in ('cmd /d /q /v:on /e:on /r "^!%%p_sch^!"') do (set %%b))^&^
   (if defined %%p_nnv if ^^^!%%p_add^^^! EQU 1 (^
    ((^<nul set /P "="^>^^^!%%p_pat^^^!^^^!%%p_nnv^^^!)^>NUL 2^>^&1)^&(if not exist "^!%%p_pat^!^!%%p_nnv^!" (set "%%p_nnv="))^
   ))^
  ))^&^
  (if ^^^!%%p_ful^^^! EQU 1 if defined %%p_nnv (set "%%p_nnv=^!%%p_pat^!^!%%p_nnv^!"))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 (^
   (if defined %%p_nnn if defined %%p_nnv (set "^!%%p_nnn^!=^!%%p_nnv^!") else (set "^!%%p_nnn^!="))^&^
   (for %%a in (add,amp,aux,eco,exc,ful,nnn,nnv,pat,pfx,quo,rab,sch,sfx,tmp) do (set "%%p_%%a="))^
  ) else (^
   (if defined %%p_nnn if defined %%p_nnv (echo "^!%%p_nnn^!=^!%%p_nnv^!") else (echo "^!%%p_nnn^!="))^
  ))^
 ) else (echo Error [@obj_newname]: The parameters are absent.^&exit /b 1)) else set wds_onn_aux=
 
::           @chcp_file - changes code page of input file to another code page of the output file.
::                        %~1 == name of the source file or external variable containing valid name of the file;
::                        %~2 == identifier of the code page of the source file;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == target code page identifier, by default active code page of current terminal window;
::                      2:%~4 == full name of target file, by default changes code page of input file.
::                Remark: The format of parameter for Unicode code pages is UTF-8 & UTF-16, other code pages identified by 
::                        their codes only. For example, `477`, `866`, `1251` etc.
::            Precaution: If `2:%~4` points to existing file, it deletes it before writing recoded symbols.
::
set @chcp_file=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ccf_aux (^
  (set wds_ccf_tsk="((if %%wds_ccf_quo%%%%wds_ccf_scp%%%%wds_ccf_quo%%==%%wds_ccf_quo%%UTF-8%%wds_ccf_quo%% (@chcp 65001%%wds_ccf_rab%%nul) else if not %%wds_ccf_quo%%%%wds_ccf_scp%%%%wds_ccf_quo%%==%%wds_ccf_quo%%UTF-16%%wds_ccf_quo%% (@chcp %%wds_ccf_scp%%%%wds_ccf_rab%%nul))%%wds_ccf_amp%%@%%wds_ccf_lab%%%%wds_ccf_sfn%%%%wds_ccf_rab%%%%wds_ccf_tfn%% (for /f %%wds_ccf_quo%%delims=%%wds_ccf_quo%% %%i in ('find /n /v %%wds_ccf_quo%%%%wds_ccf_quo%%') do @chcp %%wds_ccf_tcp%%%%wds_ccf_rab%%nul%%wds_ccf_amp%% set wds_ccf_str=%%i%%wds_ccf_amp%% cmd /v /c echo[%%wds_ccf_exc%%wds_ccf_str:*]%%wds_ccf_car%%%%wds_ccf_car%%=%%wds_ccf_exc%%)%%wds_ccf_amp%%if %%wds_ccf_rew%% EQU 1 (move /y %%wds_ccf_tfn%% %%wds_ccf_sfn%%%%wds_ccf_rab%%nul))")^&^
  (for /F "tokens=1,2,3,4" %%a in ('echo %%wds_ccf_aux%%') do (^
   (if "%%~a"=="" (echo Error [@chcp_file]: Absent argument #1.^&exit /b 1) else if defined %%~a (call set "wds_ccf_sfn=%%%%~a%%") else (set "wds_ccf_sfn=%%a"))^&^
   (for /F "usebackq tokens=*" %%i in (`call echo %%wds_ccf_sfn%%`) do if exist %%i (set "wds_ccf_sfn=%%~i") else (echo Error [@chcp_file]: The source file was not found.^&exit /b 1))^&^
   (if "%%~b"=="" (echo Error [@chcp_file]: Absent argument #2.^&exit /b 1) else (set "wds_ccf_scp=%%~b"))^&^
   (call set wds_ccf_tfn="%%wds_ccf_sfn%%.bak")^&set "wds_ccf_rew=1"^&^
   (for /F "tokens=2 delims=:" %%i in ('chcp') do for /F "tokens=*" %%j in ('echo %%i') do (set wds_ccf_tcp=%%j))^&^
   (for %%i in (%%~c %%~d) do if not "%%i"=="" (^
    (for /F "usebackq tokens=1,* delims=:" %%j in (`echo %%i`) do if not "%%~k"=="" (^
     (if %%j EQU 1 (^
      (if "%%~k"=="UTF-16" (echo Error [@chcp_file]: The file encoding to UTF-16 is impossible.^&exit /b 1))^&^
      (if "%%~k"=="UTF-8" (set "wds_ccf_tcp=65001") else (set "wds_ccf_tcp=%%~k"))^
     ))^&^
     (if %%j EQU 2 (^
      set "wds_ccf_rew=0"^&(if defined %%k (call set "wds_ccf_tfn=%%%%~k%%") else (set "wds_ccf_tfn=%%k"))^&^
      (for /F "usebackq tokens=*" %%l in (`call echo %%wds_ccf_tfn%%`) do ((set wds_ccf_tfn="%%~l")^&if exist "%%~l" (del /q /f "%%~l")))^
     ))^
    ))^
   ))^&^
   (call set wds_ccf_sfn="%%wds_ccf_sfn%%")^
  ))^&^
  (set "wds_ccf_exc=^^^!")^&(call set "wds_ccf_exc=%%wds_ccf_exc:~-1,1%%")^&(set wds_ccf_quo="")^&(call set wds_ccf_quo=%%wds_ccf_quo:~1%%)^&(set wds_ccf_lab="^^<")^&(call set "wds_ccf_lab=%%wds_ccf_lab:~-2,1%%")^&(set wds_ccf_rab="^^>")^&(call set "wds_ccf_rab=%%wds_ccf_rab:~-2,1%%")^&(set wds_ccf_car="^^^^")^&(call set "wds_ccf_car=%%wds_ccf_car:~-2,1%%")^&(set wds_ccf_amp="^^&")^&(call set "wds_ccf_amp=%%wds_ccf_amp:~-2,1%%")^&^
  call cmd /d /q /r %%wds_ccf_tsk%%^&^
  set "wds_ccf_aux="^&set "wds_ccf_sfn="^&set "wds_ccf_scp="^&set "wds_ccf_tcp="^&set "wds_ccf_tfn="^&set "wds_ccf_rew="^&set "wds_ccf_exc="^&set "wds_ccf_quo="^&(set "wds_ccf_lab=")^&(set "wds_ccf_rab=")^&(set "wds_ccf_car=")^&(set "wds_ccf_amp=")^&(set "wds_ccf_tsk=")^
 ) else (echo Error [@chcp_file]: Absent parameters.^&exit /b 1)) else set wds_ccf_aux=
 
::        @perf_counter - obtains localized counter of the typeperf.exe tool using its english name or its index value.
::                        %~1 == variable name in the context of calling script, contains:
::                                 [in]  - "english string name of counter" OR "index value of counter";
::                                 [out] - returns the found string value of the corresponding localized performance counter;
::                        %~2 == [optional: key argument to echo result (`1`) instead of assigning, default is `0`].
::            Precaution: If computer has several installed localized counters, it will return the 1st localised item from the top. 
::          Dependencies: @chcp_file, @unset_mac.
::
set @perf_counter=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tpc_csn (^
  (for /F "tokens=1,2" %%a in ('echo %%wds_tpc_csn%%') do (^
   (if defined %%~a (call set "wds_tpc_csv=%%%%~a%%") else (echo Error [@perf_counter]: Argument # 1 must be a name of defined variable in the context of caller.^&exit /b 1))^&^
   set "wds_tpc_csn=%%a"^&set "wds_tpc_eco=0"^&^
   (if ^^^!wds_tpc_eco^^^! NEQ 0 (echo Error [@perf_counter]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set /a "wds_tpc_eco=%%~b"^>NUL 2^>^&1)^>NUL^
  ))^&^
  (set wds_tpc_quo="")^&(call set wds_tpc_quo=%%wds_tpc_quo:~1%%)^&^
  (set wds_tpc_fnm="%ProgramFiles%\"wait.mds\wait.mds.auxiliary.file.id001)^&(call set wds_tpc_fnm="%%wds_tpc_fnm:^!wds_tpc_quo^!=%%")^&(set "wds_tpc_fnm=^!wds_tpc_fnm:^\^\=^\^!")^&^
  call set "wds_tpc_csv=%%wds_tpc_csv:^!wds_tpc_quo^!=%%"^&^
  (if not exist ^^^!wds_tpc_fnm^^^! (^
   (if ^^^!wds_tpc_eco^^^! EQU 1 for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],chcp_file"') do (set %%a))^&^
   (LODCTR /R^>NUL)^&(LODCTR /S:^^^!wds_tpc_fnm^^^!^>NUL)^&(cmd /d /q /v:on /e:on /r "^!@chcp_file^! wds_tpc_fnm UTF-16")^&^
   (if not exist ^^^!wds_tpc_fnm^^^! (echo Error [@perf_counter]: Failed to create counter index file.^&exit /b 1))^&^
   set "wds_tpc_fpc=0"^&^
   (for /F "usebackq eol=; tokens=*" %%c in (^^^!wds_tpc_fnm^^^!) do if ^^^!wds_tpc_fpc^^^! LSS 3 (^
    set "wds_tpc_cod=%%c"^&(if "^!wds_tpc_cod:~0,13^!"=="[PerfStrings_" (set /a "wds_tpc_fpc+=1"^>nul))^&^
    (if ^^^!wds_tpc_fpc^^^! LSS 3 (echo %%c))^
   ))^>"^!wds_tpc_fnm:~1,-1^!.bak"^&^
   (if ^^^!wds_tpc_fpc^^^! EQU 3 (^
    call move /y "^!wds_tpc_fnm:~1,-1^!.bak" ^^^!wds_tpc_fnm^^^!^
   ) else (^
    call del /f /a /q ^^^!wds_tpc_fnm^^^!.bak^
   ))^>nul 2^>^&1^
  ))^&^
  set "wds_tpc_cod="^&set "wds_tpc_fpc="^&^
  (for /F "usebackq eol=; tokens=1,* delims==" %%c in (^^^!wds_tpc_fnm^^^!) do if not defined wds_tpc_fpc (^
   (if defined wds_tpc_cod (^
    if "^!wds_tpc_cod^!"=="%%c" (set "wds_tpc_fpc=%%d")^
   ) else (^
    if "^!wds_tpc_csv^!"=="%%c" (set wds_tpc_cod=%%c) else if "^!wds_tpc_csv^!"=="%%d" (set wds_tpc_cod=%%c)^
   ))^
  ))^&^
  (if "^!wds_tpc_cod^!"=="" (echo Error [@perf_counter]: Failed to find counter inside index file.^&exit /b 1))^&^
  (if not defined wds_tpc_fpc (set "wds_tpc_fpc=^!wds_tpc_csv^!"))^&^
  (if ^^^!wds_tpc_eco^^^! NEQ 1 (^
   set "^!wds_tpc_csn^!=^!wds_tpc_fpc^!"^&^
   set "wds_tpc_csv="^&set "wds_tpc_eco="^&set "wds_tpc_fnm="^&set "wds_tpc_cod="^&set "wds_tpc_fpc="^&set "wds_tpc_quo="^
  ) else (^
   echo "^!wds_tpc_csn^!=^!wds_tpc_fpc^!"^
  ))^&^
  set "wds_tpc_csn="^
 ) else (echo Error [@perf_counter]: Absent parameters.^&exit /b 1)) else set wds_tpc_csn=

::            @typeperf - returns result of typeperf.exe query.
::                        %~1 == name of variable with template of query or with plain query string, returns found query string;
::                        %~2 == variable name to set returned names of values (delimiter - `,`);
::                        %~3 == variable name to set all returned values as one string (delimiter - `,` lines separator - `;`);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~4 == variable name to return count of internal elements of every reported line;
::                      2:%~5 == number of values to return, by default `1`, not valuable in the case of specified next parameter;
::                      3:%~6 == keys of typeperf.exe, by default "-sc 1";
::                      4:%~7 == key argument to echo result (`1`) instead of assigning it, default is `0`.
::                  Note: if device names have symbols `=`, `?` or `*`, it replaces them by their codes: `#3D;`, `#3F;` or `#2A;`.
::    Samples of queries:
:: 1. template with english names      : "[Network Interface]^(*^)\[Current Bandwidth]"    (template items in square brackets);
:: 2. template with corresponding index: "[510]^(*^)\[520]"                                (template items in square brackets);
:: 3. corresponding plain english query: "Network Interface^(*^)\Current Bandwidth"        (only OS-s w\o native language packages).
::                  Note: If performance counter has symbols `[` & `]`, use substitution `/CHR{5B}` & `/CHR{5D}`, respectively.
::          Dependencies: @echo_params, @chcp_file, @perf_counter, @substr_extract, @syms_replace, @unset_mac.
::
set @typeperf=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ctp_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],echo_params,chcp_file,perf_counter,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo %%wds_ctp_aux%%') do if defined %%a if not "%%~b%%~c"=="" (^
   set "wds_ctp_qvn=%%~a"^&set "wds_ctp_qvv=^!%%~a^!"^&set "wds_ctp_rns=%%~b"^&set "wds_ctp_rvs=%%~c"^&^
   (if NOT "^!wds_ctp_qvn^!"=="%%~a" (echo Error [@typeperf]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "wds_ctp_icn="^&set "wds_ctp_atr="^&^
   (for %%i in (%%~d,%%~e,%%~f,%%~g) do if not "%%i"=="" (^
    set "wds_ctp_aux=%%i"^&set "wds_ctp_quo=^!wds_ctp_aux:~2^!"^&set "wds_ctp_aux=^!wds_ctp_aux:~0,1^!"^&^
        (if ^^^!wds_ctp_aux^^^! EQU 1 (set "wds_ctp_icn=^!wds_ctp_quo^!")^
    else if ^^^!wds_ctp_aux^^^! EQU 2 ((set /a "wds_ctp_nmb=^!wds_ctp_quo^!"^>NUL 2^>^&1)^>NUL)^
    else if ^^^!wds_ctp_aux^^^! EQU 3 (set "wds_ctp_atr=^!wds_ctp_quo^!")^
    else if ^^^!wds_ctp_aux^^^! EQU 4 ((set /a "wds_ctp_eco=^!wds_ctp_quo^!"^>NUL 2^>^&1)^>NUL))^
   ))^
  ))^&^
  (if defined wds_ctp_qvn (^
   (if defined wds_ctp_atr (set wds_ctp_aux="wds_ctp_eco 0 1 0") else (set wds_ctp_aux="wds_ctp_nmb 1 25 1","wds_ctp_eco 0 1 0"))^&^
   (for %%a in (^^^!wds_ctp_aux^^^!) do for /F "tokens=1,2,3,4" %%b in ('echo %%~a') do (^
    (if defined %%~b (^
     (if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))^
    ) else (set "%%b=%%e"))^
   ))^&^
   (if defined wds_ctp_atr (set "wds_ctp_nmb=2048000") else (set "wds_ctp_atr=-sc ^!wds_ctp_nmb^!"^&set /a "wds_ctp_nmb+=1"^>NUL))^&^
   (set wds_ctp_quo="")^&(call set wds_ctp_quo=%%wds_ctp_quo:~1%%)^&(call set wds_ctp_qvv=%%wds_ctp_qvv:^^^!wds_ctp_quo^^^!=%%)^&^
   set "wds_ctp_aux=^!wds_ctp_qvv:[=^!"^&set "wds_ctp_aux=^!wds_ctp_aux:]=^!"^&^
   (if "^!wds_ctp_aux^!"=="^!wds_ctp_qvv^!" (^
    (set wds_ctp_qvv="^!wds_ctp_qvv:/CHR{5B}=[^!")^&(set "wds_ctp_qvv=^!wds_ctp_qvv:/CHR{5D}=]^!")^
   ) else (^
    set "wds_ctp_aux=^!wds_ctp_qvv^!"^&(set wds_ctp_qvv="")^&^
    (for /F "tokens=1,* delims==" %%a in ('cmd /d /q /e:on /v:on /r "^!@substr_extract^! wds_ctp_aux [ 1:]"') do (^
     set "wds_ctp_aux=%%b"^&set "wds_ctp_aux=^!wds_ctp_aux:/CHR{5B}=[^!"^&set "wds_ctp_aux=^!wds_ctp_aux:/CHR{5D}=]^!"^&^
     (if "%%a"=="str" (^
      (set wds_ctp_qvv="^!wds_ctp_qvv:~1,-1^!^!wds_ctp_aux^!")^
     ) else (^
      (for /F "tokens=*" %%c in ('cmd /d /q /v:on /e:on /r "^!@perf_counter^! wds_ctp_aux 1"') do (set %%c))^&^
      (set wds_ctp_qvv="^!wds_ctp_qvv:~1,-1^!^!wds_ctp_aux^!")^
     ))^
    ))^
   ))^&^
   set "wds_ctp_aux=0"^&set "wds_ctp_rhc=2048000"^&set "wds_ctp_rrc=1024000"^&set "wds_ctp_atr=typeperf ^!wds_ctp_qvv^! ^!wds_ctp_atr^!"^&^
   set "wds_ctp_atr=^!wds_ctp_atr:#3F;=?^!"^&set "wds_ctp_atr=^!wds_ctp_atr:#2A;=*^!"^&set "wds_ctp_atr=^!wds_ctp_atr:#3D;==^!"^&^
   (for /F "tokens=*" %%a in ('"echo %%wds_ctp_atr%%"') do for /F "tokens=*" %%b in ('cmd /d /q /r "%%a"') do (^
    set /a "wds_ctp_aux+=1"^>NUL^&^
    (if ^^^!wds_ctp_aux^^^! EQU 1 (set "wds_ctp_hed=%%b") else if ^^^!wds_ctp_aux^^^! LEQ ^^^!wds_ctp_nmb^^^! (^
     set "wds_ctp_rrc=-1"^&set "wds_ctp_row="^&^
     (for %%c in (%%b) do (^
      set /a "wds_ctp_rrc+=1"^>NUL^&^
      (if ^^^!wds_ctp_rrc^^^! EQU 1 (set "wds_ctp_row=%%c") else if 1 LSS ^^^!wds_ctp_rrc^^^! (set "wds_ctp_row=^!wds_ctp_row^!,%%c"))^
     ))^&^
     (if ^^^!wds_ctp_aux^^^! EQU 2 (^
      set "wds_ctp_rhc=-1"^&set "wds_ctp_tmp=^!wds_ctp_hed^!"^&^
      (for %%c in (1 2) do if ^^^!wds_ctp_rhc^^^! NEQ ^^^!wds_ctp_rrc^^^! (^
       (if %%c EQU 2 for /F "delims==?*" %%d in ('"echo %%wds_ctp_tmp%%"') do if not "%%d"=="^!wds_ctp_tmp^!" (^
        set "wds_ctp_rhc=-1"^&(set wds_ctp_hed="==#3D;" "?=#3F;" "*=#2A;")^&^
        ((for /F "tokens=*" %%e in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_ctp_tmp 1 3 wds_ctp_hed"') do (set %%e))^>NUL 2^>^&1)^
       ))^&^
       (if ^^^!wds_ctp_rhc^^^! LSS 0 for %%d in (^^^!wds_ctp_tmp^^^!) do (^
        set /a "wds_ctp_rhc+=1"^>NUL^&^
        (if ^^^!wds_ctp_rhc^^^! EQU 1 (set "wds_ctp_hed=%%d") else if 1 LSS ^^^!wds_ctp_rhc^^^! (set "wds_ctp_hed=^!wds_ctp_hed^!,%%d"))^
       ))^
      ))^&^
      (if ^^^!wds_ctp_rhc^^^! NEQ ^^^!wds_ctp_rrc^^^! (call echo Error [@typeperf]: Failed to query typeperf.exe using %%^^^!wds_ctp_qvn^^^!%%.^&exit /b 1))^&^
      set "wds_ctp_rws=^!wds_ctp_row^!"^
     ) else if ^^^!wds_ctp_rhc^^^! EQU ^^^!wds_ctp_rrc^^^! (set "wds_ctp_rws=^!wds_ctp_rws^!;^!wds_ctp_row^!"))^
    ))^
   ))^&^
   (set "wds_ctp_qvv=^!wds_ctp_qvv:[=/CHR{5B}^!")^&(set "wds_ctp_qvv=^!wds_ctp_qvv:]=/CHR{5D}^!")^&^
   (if ^^^!wds_ctp_eco^^^! NEQ 1 (^
    set "^!wds_ctp_qvn^!=^!wds_ctp_qvv^!"^&set "^!wds_ctp_rns^!=^!wds_ctp_hed^!"^&set "^!wds_ctp_rvs^!=^!wds_ctp_rws^!"^&^
    (if defined wds_ctp_icn (set "^!wds_ctp_icn^!=^!wds_ctp_rhc^!"))^&^
    (for %%a in (aux,icn,qvn,qvv,eco,nmb,atr,rns,rvs,rhs,rhc,rrc,hed,rws,row,quo,tmp) do (set "wds_ctp_%%a="))^
   ) else (^
    echo "^!wds_ctp_qvn^!=^!wds_ctp_qvv^!"^&echo "^!wds_ctp_rns^!=^!wds_ctp_hed^!"^&echo "^!wds_ctp_rvs^!=^!wds_ctp_rws^!"^&^
    (if defined wds_ctp_icn (echo "^!wds_ctp_icn^!=^!wds_ctp_rhc^!"))^
   ))^
  ))^
 ) else (echo Error [@typeperf]: Absent parameters.^&exit /b 1)) else set wds_ctp_aux=

::       @typeperf_devs - returns list of devices corresponding to query of typeperf.exe tool.
::                        %~1 == name of variable with template of query or with plain query string, returns found query string;
::                        %~2 == variable name to set returned list of devices (delimiter - `,`. See also note #3);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == variable name to return count of devices according query;
::                      2:%~4 == key argument to extract names of devices `1` (default value), any other value to return as is;
::                      3:%~5 == key argument to echo result (`1`) instead of assigning it to %~2 & 1:%~3, default is `0`.
::             Notes. #1: it drops datetime column of the typeperf.exe query response, checks result of query before return;
::                    #2: the format of query template corresponds to @typeperf macro;
::                    #3: the parameters `%~2` & `1:%~3` are not valuable in echo mode, macro prints names of devices as is;
::                    #4: if device names have symbols `=`, `?` or `*`, it replaces them by their codes: `#3D;`, `#3F;` or `#2A;`.
::          Dependencies: @echo_params, @chcp_file, @perf_counter, @substr_extract, @syms_replace, @unset_mac.
::
set @typeperf_devs=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tpd_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],echo_params,chcp_file,perf_counter,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo %%wds_tpd_aux%%') do (^
   set "wds_tpd_qvn=%%~a"^&(if defined wds_tpd_qvn if not "^!wds_tpd_qvn::=^!"=="^!wds_tpd_qvn^!" (set "wds_tpd_qvn="))^&^
   (if NOT "^!wds_tpd_qvn^!"=="%%~a" (echo Error [@typeperf_devs]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if defined wds_tpd_qvn if defined ^^^!wds_tpd_qvn^^^! (set "wds_tpd_qvv=^!%%~a^!") else (set "wds_tpd_qvn="))^&^
   (if not defined wds_tpd_qvn (echo Error [@typeperf_devs]: The parameter #1 is absent or hasn't assigned query string.^&exit /b 1))^&^
   set "wds_tpd_eco=0"^&set "wds_tpd_ext=1"^&set "wds_tpd_icn="^&^
   (for %%i in (%%~b,%%~c,%%~d,%%~e) do if not "%%i"=="" (^
    set "wds_tpd_aux=%%i"^&set "wds_tpd_quo=^!wds_tpd_aux:~2^!"^&set "wds_tpd_aux=^!wds_tpd_aux:~0,1^!"^&^
        (if ^^^!wds_tpd_aux^^^! EQU 1 (set "wds_tpd_icn=^!wds_tpd_quo^!")^
    else if ^^^!wds_tpd_aux^^^! EQU 2 ((set /a "wds_tpd_ext=0x^!wds_tpd_quo^!"^>NUL 2^>^&1)^>NUL)^
    else if ^^^!wds_tpd_aux^^^! EQU 3 ((set /a "wds_tpd_eco=0x^!wds_tpd_quo^!"^>NUL 2^>^&1)^>NUL))^
   ))^&^
   (if ^^^!wds_tpd_eco^^^! EQU 0 (^
    (if not "%%~b"=="" (set "wds_tpd_rns=%%~b"^&(if not "^!wds_tpd_rns::=^!"=="^!wds_tpd_rns^!" (set "wds_tpd_rns="))))^&^
    (if not defined wds_tpd_rns (echo Error [@typeperf_devs]: Absent parameter #2.^&exit /b 1))^
   ))^
  ))^&^
  (set wds_tpd_quo="")^&(call set wds_tpd_quo=%%wds_tpd_quo:~1%%)^&(call set wds_tpd_qvv=%%wds_tpd_qvv:^^^!wds_tpd_quo^^^!=%%)^&^
  set "wds_tpd_aux=^!wds_tpd_qvv:[=^!"^&set "wds_tpd_aux=^!wds_tpd_aux:]=^!"^&^
  (if "^!wds_tpd_aux^!"=="^!wds_tpd_qvv^!" (^
   (set wds_tpd_qvv="^!wds_tpd_qvv:/CHR{5B}=[^!")^&(set "wds_tpd_qvv=^!wds_tpd_qvv:/CHR{5D}=]^!")^
  ) else (^
   set "wds_tpd_aux=^!wds_tpd_qvv^!"^&(set wds_tpd_qvv="")^&^
   (for /F "usebackq tokens=1,* delims==" %%a in (`cmd /d /q /e:on /v:on /r "^!@substr_extract^! wds_tpd_aux [ 1:]"`) do (^
    set "wds_tpd_aux=%%b"^&set "wds_tpd_aux=^!wds_tpd_aux:/CHR{5B}=[^!"^&set "wds_tpd_aux=^!wds_tpd_aux:/CHR{5D}=]^!"^&^
    (if "%%a"=="str" (^
     (set wds_tpd_qvv="^!wds_tpd_qvv:~1,-1^!^!wds_tpd_aux^!")^
    ) else (^
     (for /F "tokens=*" %%c in ('cmd /d /q /v:on /e:on /r "^!@perf_counter^! wds_tpd_aux 1"') do (set %%c))^&^
     (set wds_tpd_qvv="^!wds_tpd_qvv:~1,-1^!^!wds_tpd_aux^!")^
    ))^
   ))^
  ))^&^
  (for %%a in ("#3D;==","#3F;=?","#2A;=*") do (set "wds_tpd_qvv=^!wds_tpd_qvv:%%~a^!"))^&^
  set "wds_tpd_aux=0"^&set "wds_tpd_rhc=2048000"^&set "wds_tpd_rrc=1024000"^&set "wds_tpd_tpc=typeperf ^!wds_tpd_qvv^! -sc 1"^&^
  (for /F "usebackq tokens=*" %%a in (`"echo ^!wds_tpd_tpc^!"`) do for /F "usebackq tokens=*" %%b in (`cmd /d /q /r "%%a"`) do (^
   set /a "wds_tpd_aux+=1"^>NUL^&^
   (if ^^^!wds_tpd_aux^^^! EQU 1 (set "wds_tpd_hed=%%b") else if ^^^!wds_tpd_aux^^^! LEQ 2 (^
    set "wds_tpd_rrc=-1"^&(for %%c in (%%b) do (set /a "wds_tpd_rrc+=1"^>NUL))^&^
    set "wds_tpd_rhc=-1"^&set "wds_tpd_tmp=^!wds_tpd_hed^!"^&^
    (for %%c in (1 2) do if ^^^!wds_tpd_rhc^^^! NEQ ^^^!wds_tpd_rrc^^^! (^
     (if %%c EQU 2 for /F "delims==?*" %%d in ('"echo %%wds_tpd_tmp%%"') do if not "%%d"=="^!wds_tpd_tmp^!" (^
      set "wds_tpd_rhc=-1"^&(set wds_tpd_hed="==#3D;" "?=#3F;" "*=#2A;")^&^
      ((for /F "tokens=*" %%e in ('cmd /d /q /v:on /e:on /r "^!@syms_replace^! wds_tpd_tmp 1 3 wds_tpd_hed"') do (set %%e))^>NUL 2^>^&1)^
     ))^&^
     (if ^^^!wds_tpd_rhc^^^! LSS 0 for %%d in (^^^!wds_tpd_tmp^^^!) do (^
      set /a "wds_tpd_rhc+=1"^>NUL^&^
      (if ^^^!wds_tpd_rhc^^^! EQU 1 (set "wds_tpd_hed=%%d") else if 1 LSS ^^^!wds_tpd_rhc^^^! (set "wds_tpd_hed=^!wds_tpd_hed^!,%%d"))^
     ))^
    ))^
   ))^
  ))^&^
  (if ^^^!wds_tpd_rhc^^^! NEQ ^^^!wds_tpd_rrc^^^! (call echo Error [@typeperf_devs]: Failed to query typeperf.exe using %%^^^!wds_tpd_qvn^^^!%%.^&exit /b 1))^&^
  (if ^^^!wds_tpd_ext^^^! EQU 1 (^
   set "wds_tpd_aux=^!wds_tpd_hed^!"^&set "wds_tpd_hed="^&(set "wds_tpd_ext=(")^&(set "wds_tpd_rrc=)")^&^
   (for /F "usebackq tokens=*" %%a in (`cmd /d /q /e:on /v:on /r "^!@substr_extract^! wds_tpd_aux wds_tpd_ext 1:wds_tpd_rrc 4:1"`) do (^
    (if defined wds_tpd_hed (set wds_tpd_hed=^^^!wds_tpd_hed^^^!,"%%a") else (set wds_tpd_hed="%%a"))^
   ))^
  ))^&^
  set "wds_tpd_qvv=^!wds_tpd_qvv:[=/CHR{5B}^!"^&set "wds_tpd_qvv=^!wds_tpd_qvv:]=/CHR{5D}^!"^&^
  (if not defined wds_tpd_hed (set wds_tpd_hed=""))^&^
  (if ^^^!wds_tpd_eco^^^! NEQ 1 (^
   set "^!wds_tpd_qvn^!=^!wds_tpd_qvv^!"^&set "^!wds_tpd_rns^!=^!wds_tpd_hed^!"^&^
   (if defined wds_tpd_icn (set "^!wds_tpd_icn^!=^!wds_tpd_rhc^!"))^&^
   (for %%a in (aux,icn,qvn,qvv,eco,ext,rns,rhc,rrc,hed,quo,tmp,tpc) do (set "wds_tpd_%%a="))^
  ) else (^
   (echo "^!wds_tpd_qvn^!=^!wds_tpd_qvv^!")^&(for %%a in (^^^!wds_tpd_hed^^^!) do (echo %%a))^
  ))^
 ) else (echo Error [@typeperf_devs]: Absent parameters.^&exit /b 1)) else set wds_tpd_aux=

::      @typeperf_res_a - queries typeperf to get usage of every device applied to their specific capacity (normalized percentage).
::                        %~1 == usage query - name of variable with "query template or plain query", returns plain query string;
::                        %~2 == capacity query - name of variable with "query template or plain query", returns plain query string;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == key parameter to define result type:
::                               `0` - default value to return values for maximally used device;
::                               `1` - total load of all requested devices, weighted by total capacity;
::                               `2` - total load of all requested devices, weighted by their specific capacity;
::                      2:%~4 == digital factor for value convertion after its division by capacity value, default is `1`;
::                      3:%~5 == external variable name for assigning usage percent of the capacity;
::                      4:%~6 == external variable name for assigning name(s) of reported device(s);
::                      5:%~7 == number of typeperf queries of current use of devices, default value is `1`, maximum is `25`;
::                      6:%~8 == key parameter for approach to obtain the load on each device in the case of their several queries:
::                               `0` - default value to get average use of every device through all queries;
::                               `1` - select minimum value;
::                               `2` - select maximum value;
::                      7:%~9 == external variable name for assigning capacity value of reported device(s);
::                      8:%~10== key argument to echo result (`1`) instead of assigning it, default is `0`.
::                Remark: The format of query template corresponds to @typeperf macro.
::               Warning: This macro searches all performance counters and calculates capacity factors at every call, for better
::                        performance use macro @typeperf_res_c (it supports same parameters, except "`1:%~3`==`2`").
::          Dependencies: @echo_params, @chcp_file, @perf_counter, @str_arrange, @str_clean, @str_encode, @substr_extract,
::                        @syms_replace, @typeperf, @unset_mac. Nominally: @cptooem, @oemtocp.
::
set @typeperf_res_a=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tpn_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],str_clean,oemtocp,cptooem,oemtocp,cptooem,str_arrange,str_decode,str_encode,typeperf,echo_params,chcp_file,perf_counter,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F %%p in ('echo wds_tpn') do (^
   (for /F "tokens=1,2,3,4,5,6,7,8,9,10" %%a in ('echo.%%%%p_aux%%') do (^
    (for %%k in ("1 %%p_uqn %%p_uqv %%~a","2 %%p_cqn %%p_cqv %%~b") do (^
     (for /F "tokens=1,2,3,4" %%l in ('"echo %%~k"') do (^
      set "%%m=%%o"^&^
      (if NOT "^!%%m^!"=="%%o" (echo Error [@typeperf_res_a]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
      (if defined %%m if not "^!%%m::=^!"=="^!%%m^!" (set "%%m="))^&^
      (if defined %%m if defined ^^^!%%m^^^! (set "%%n=^!%%o^!") else (set "%%m="))^&^
      (if not defined %%m (echo Error [@typeperf_res_a]: The parameter #%%l is absent or hasn't assigned query string.^&exit /b 1))^
     ))^
    ))^&^
    (for %%k in (typ,nor,dun,dcn,dnn,ndq,sel,eco) do (set "%%p_%%k="))^&^
    (for %%k in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j) do if not "%%k"=="" (^
     set "%%p_aux=%%k"^&set "%%p_cnt=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
     (if ^^^!%%p_aux^^^! EQU 1 ((set /a "%%p_typ=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 2 ((set /a "%%p_nor=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_dun=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 4 (set "%%p_dnn=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 5 ((set /a "%%p_ndq=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 6 ((set /a "%%p_sel=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 7 (set "%%p_dcn=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 8 ((set /a "%%p_eco=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL))^
    ))^
   ))^&^
   (if not defined %%p_dun if not defined %%p_dcn if not defined %%p_dnn (echo Error [@typeperf_res_a]: All parameters 3:#5, 4:#6, 7:#9 are absent.^&exit /b 1))^&^
   (for %%a in ("%%p_typ 0 2 0","%%p_nor 1 2147483647 1","%%p_ndq 1 25 1","%%p_sel 0 2 0","%%p_eco 0 1 0") do (^
    (for /F "tokens=1,2,3,4" %%b in ('echo %%~a') do if defined %%~b (^
     (if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))^
    ) else (set "%%b=%%e"))^
   ))^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf^! %%p_uqv %%p_urn %%p_urv 1:%%p_urc 2:^!%%p_ndq^! 4:1"') do (^
    (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
   ))^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf^! %%p_cqv %%p_crn %%p_crv 1:%%p_crc 4:1)"') do (^
    (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
   ))^&^
   (if ^^^!%%p_urc^^^! NEQ ^^^!%%p_crc^^^! (echo Error [@typeperf_res_a]: The result of 2 queries differs.^&exit /b 1))^&^
   set "%%p_aux=^!%%p_urn^!"^&set "%%p_urn="^&(for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@substr_extract^! %%p_aux ( 1:) 4:1"') do (set "%%p_aux=%%a"^&set "%%p_aux=^!%%p_aux:,=^!"^&if defined %%p_urn (set "%%p_urn=^!%%p_urn^!,^!%%p_aux^!") else (set "%%p_urn=^!%%p_aux^!")))^&^
   set "%%p_aux=^!%%p_crn^!"^&set "%%p_crn="^&(for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@substr_extract^! %%p_aux ( 1:) 4:1"') do (set "%%p_aux=%%a"^&set "%%p_aux=^!%%p_aux:,=^!"^&if defined %%p_crn (set "%%p_crn=^!%%p_crn^!,^!%%p_aux^!") else (set "%%p_crn=^!%%p_aux^!")))^&^
   set "%%p_urn=^!%%p_crn^!,^!%%p_crv^!,^!%%p_urn^!"^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@str_clean^! %%p_urn 1 1"') do (set %%a))^&^
   set "%%p_urv=^!%%p_urv:;=)(^!"^&set "%%p_urv=(^!%%p_urv^!)"^&^
   (for /F "tokens=1,2 delims==" %%a in ('cmd /d /q /v:on /e:on /r "^!@substr_extract^! %%p_urv ( 1:)"') do (^
    set "%%p_urv="^&^
    (for %%c in (%%b) do (^
     set "%%p_aux=%%~c"^&set "%%p_aux=^!%%p_aux:,=.^!"^&if defined %%p_urv (set "%%p_urv=^!%%p_urv^!,^!%%p_aux^!") else (set "%%p_urv=^!%%p_aux^!")^
    ))^&^
    set "%%p_cnt=0"^&^
    (for /F "tokens=1,2,3,4 delims=," %%c in ('cmd /d /q /v:on /e:on /r "^!@str_arrange^! C:4 R:^!%%p_urc^! D:, E:0 ^!%%p_urn^!,^!%%p_urv^!"') do (^
     (if not "%%~c"=="%%~e" (echo Error [@typeperf_res_a]: The device name from 2 queries does not coincide.^&exit /b 1))^&^
     set /a "%%p_cnt+=1"^>NUL^&^
     (set /a "%%p_ivc=%%~d"^>NUL 2^>^&1)^>NUL^&^
     set /a "%%p_ivc/=(100*^!%%p_nor^!)"^>NUL^&^
     (set /a "%%p_ivu=%%~f"^>NUL 2^>^&1)^>NUL^&^
     (if ^^^!%%p_ivc^^^! EQU 0 (set "%%p_ivu=0") else (^
      (if ^^^!%%p_typ^^^! NEQ 1 (set /a "%%p_ivu/=^!%%p_ivc^!")^>NUL)^
     ))^&^
     (if defined %%p_ivn^^^!%%p_cnt^^^! (^
      (if ^^^!%%p_sel^^^! EQU 0 (^
       call set /a "%%p_ivu^!%%p_cnt^!+=^!%%p_ivu^!"^>NUL^
      ) else (^
       call set "%%p_aux=%%%%p_ivu^!%%p_cnt^!%%"^&^
       (if ^^^!%%p_sel^^^! EQU 1 if ^^^!%%p_ivu^^^! LSS ^^^!%%p_aux^^^! (set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"))^&^
       (if ^^^!%%p_sel^^^! EQU 2 if ^^^!%%p_aux^^^! LSS ^^^!%%p_ivu^^^! (set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"))^
      ))^
     ) else (^
      set "%%p_ivn^!%%p_cnt^!=%%c"^&^
      set "%%p_ivc^!%%p_cnt^!=^!%%p_ivc^!"^&set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"^
     ))^
    ))^
   ))^&^
   set "%%p_ivn="^&set "%%p_ivc=0"^&set "%%p_ivu=0"^&^
   (for /L %%a in (1 1 ^^^!%%p_crc^^^!) do (^
    (if ^^^!%%p_typ^^^! EQU 0 (^
     call set "%%p_aux=%%%%p_ivu%%a%%"^&^
     (if ^^^!%%p_sel^^^! EQU 0 (set /a "%%p_aux/=^!%%p_ndq^!")^>NUL)^&^
     (if ^^^!%%p_aux^^^! LSS ^^^!%%p_ivu^^^! (^
      set "%%p_aux="^
     ) else if ^^^!%%p_aux^^^! EQU ^^^!%%p_ivu^^^! (^
      call set "%%p_aux=%%%%p_ivc%%a%%"^&(if ^^^!%%p_aux^^^! LEQ ^^^!%%p_ivc^^^! (set "%%p_aux="))^
     ))^&^
     (if defined %%p_aux (^
      (call set "%%p_ivn=%%%%p_ivn%%a%%")^&^
      (call set "%%p_ivc=%%%%p_ivc%%a%%")^&(call set "%%p_ivu=%%%%p_ivu%%a%%")^
     ))^
    ) else (^
     (call set /a "%%p_ivc+=%%%%p_ivc%%a%%")^>NUL^&call set "%%p_aux=%%%%p_ivu%%a%%"^&^
     (if ^^^!%%p_sel^^^! EQU 0 (set /a "%%p_aux/=^!%%p_ndq^!")^>NUL)^&^
     set /a "%%p_ivu+=^!%%p_aux^!"^>NUL^
    ))^&^
    (set "%%p_ivn%%a=")^&(set "%%p_ivc%%a=")^&(set "%%p_ivu%%a=")^
   ))^&^
   (if ^^^!%%p_typ^^^! EQU 0 (^
    (if defined %%p_dnn (^
     (if defined %%p_ivn (^
      (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=^!%%p_ivn^!") else (echo "^!%%p_dnn^!=^!%%p_ivn^!"))^
     ) else (^
      (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=") else (echo "^!%%p_dnn^!="))^
     ))^
    ))^&^
    (if defined %%p_dun (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dun^!=^!%%p_ivu^!") else (echo "^!%%p_dun^!=^!%%p_ivu^!")))^
   ) else (^
    (if defined %%p_dnn (^
     (if defined %%p_crn (^
      (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=^!%%p_crn^!") else (echo "^!%%p_dnn^!=^!%%p_crn^!"))^
     ) else (^
      (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=") else (echo "^!%%p_dnn^!="))^
     ))^
    ))^&^
    (if defined %%p_dun (^
     (if ^^^!%%p_typ^^^! EQU 1 (^
      (if ^^^!%%p_ivc^^^! NEQ 0 (set /a "%%p_ivu/=^!%%p_ivc^!")^>NUL else (set "%%p_ivu=0"))^
     ) else (^
      set /a "%%p_ivu/=^!%%p_urc^!"^>NUL^
     ))^
    ))^&^
    (if defined %%p_dun (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dun^!=^!%%p_ivu^!") else (echo "^!%%p_dun^!=^!%%p_ivu^!")))^
   ))^&^
   (if defined %%p_dcn (set /a "%%p_ivc*=100")^>NUL)^&^
   (if defined %%p_dcn (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dcn^!=^!%%p_ivc^!") else (echo "^!%%p_dcn^!=^!%%p_ivc^!")))^&^
   (if ^^^!%%p_eco^^^! EQU 0 (^
    set "^!%%p_uqn^!=^!%%p_uqv^!"^&set "^!%%p_cqn^!=^!%%p_cqv^!"^&^
    (for %%a in (aux,uqn,uqv,cqn,cqv,typ,nor,urn,urv,urc,crn,crv,crc,ivu,ivc,ivn,dcn,dnn,dun,ndq,sel,eco,cnt) do (set "%%p_%%a="))^
   ) else (^
    (echo "^!%%p_uqn^!=^!%%p_uqv^!")^&(echo "^!%%p_cqn^!=^!%%p_cqv^!")^
   ))^
  ))^
 ) else (echo Error [@typeperf_res_a]: Absent parameters.^&exit /b 1)) else set wds_tpn_aux=

::      @typeperf_res_b - queries typeperf to calculate current use of devices or to select device by its current use.
::                        %~1 == usage query - name of variable with "query template or plain query", returns plain query string;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~2 == key parameter to define result type:
::                               `0` - default value to return value for maximally used device;
::                               `1` - total use of all requested devices;
::                      2:%~3 == factor to avoid integer everflow or for conversion to units convenient for caller, default is `1`;
::                      3:%~4 == external variable name for assigning use value;
::                      4:%~5 == external variable name for assigning name(s) of reported device(s);
::                      5:%~6 == number of typeperf queries of current load of devices [1..25], default value is `1`;
::                      6:%~7 == key parameter for the approach to getting the load on each device in case of multiple queries:
::                               `0` - default value to get average use of every device through all queries;
::                               `1` - select minimum value;
::                               `2` - select maximum value;
::                      7:%~8 == key argument to extract names of devices `1`, another value to return as is (default `0`);
::                      8:%~9 == key argument to echo result (`1`) instead of assigning it, default is `0`.
::             Notes. #1: `6:%~7` is valuable only in case of defined `3:%~4` parameter;
::                    #2: the format of query template corresponds to @typeperf macro.
::          Dependencies: @echo_params, @chcp_file, @perf_counter, @str_arrange, @str_clean, @str_encode, @substr_extract,
::                        @syms_replace, @typeperf, @unset_mac. Nominally: @cptooem, @oemtocp.
::
set @typeperf_res_b=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tps_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],str_clean,oemtocp,cptooem,typeperf,echo_params,chcp_file,perf_counter,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F %%p in ('echo wds_tps') do (^
   (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%%%p_aux%%') do (^
    set "%%p_uqn=%%~a"^&(if NOT "^!%%p_uqn^!"=="%%~a" (echo Error [@typeperf_res_b]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (if defined %%p_uqn if not "^!%%p_uqn::=^!"=="^!%%p_uqn^!" (set "%%p_uqn="))^&^
    (if defined %%p_uqn if defined ^^^!%%p_uqn^^^! (set "%%p_uqv=^!%%~a^!") else (set "%%p_uqn="))^&^
    (if not defined %%p_uqn (echo Error [@typeperf_res_b]: The parameter #1 is absent or hasn't assigned query string.^&exit /b 1))^&^
    set "%%p_dun="^&set "%%p_dnn="^&^
    (for %%j in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i) do if not "%%j"=="" (^
     set "%%p_aux=%%j"^&set "%%p_cnt=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
     (if ^^^!%%p_aux^^^! EQU 1 ((set /a "%%p_typ=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 2 ((set /a "%%p_nor=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_dun=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 4 (set "%%p_dnn=^!%%p_cnt^!")^
     else if ^^^!%%p_aux^^^! EQU 5 ((set /a "%%p_ndq=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 6 ((set /a "%%p_sel=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 7 ((set /a "%%p_ext=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 8 ((set /a "%%p_eco=^!%%p_cnt^!"^>NUL 2^>^&1)^>NUL))^
    ))^
   ))^&^
   (if not defined %%p_dun if not defined %%p_dnn (echo Error [@typeperf_res_b]: Both parameters 3:#4 and 4:#5 are absent.^&exit /b 1))^&^
   (for %%a in ("%%p_typ 0 1 0","%%p_ndq 1 25 1","%%p_sel 0 2 0","%%p_ext 0 1 0","%%p_nor 1 2147483647 1","%%p_eco 0 1 0") do (^
    (for /F "tokens=1,2,3,4" %%b in ('echo %%~a') do if defined %%~b (^
     (if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))^
    ) else (set "%%b=%%e"))^
   ))^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf^! %%p_uqv %%p_urn %%p_urv 1:%%p_urc 2:^!%%p_ndq^! 4:1"') do (^
    (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
   ))^&^
   (if defined %%p_dnn (^
    (set "%%p_urn=^!%%p_urn:","=";"^!")^&set "%%p_urn=^!%%p_urn:,=.^!"^&(set %%p_urn=^^^!%%p_urn:";"=,^^^!)^&^
    (if ^^^!%%p_ext^^^! EQU 1 (^
     set "%%p_aux=^!%%p_urn^!"^&set "%%p_urn="^&(for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@substr_extract^! %%p_aux ( 1:) 4:1"') do (set "%%p_aux=%%a"^&set "%%p_aux=^!%%p_aux:,=^!"^&if defined %%p_urn (set "%%p_urn=^!%%p_urn^!,^!%%p_aux^!") else (set "%%p_urn=^!%%p_aux^!")))^
    ))^&^
    (if defined %%p_urn (^
     (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@str_clean^! %%p_urn 1 1"') do (set %%a))^&^
     (if defined %%p_urn (set %%p_urn="^!%%p_urn:,=","^!") else (set %%p_urn=""))^
    ) else (set %%p_urn=""))^&^
    set "%%p_cnt=0"^&(for %%c in (^^^!%%p_urn^^^!) do (set /a "%%p_cnt+=1"^>NUL^&set "%%p_ivn^!%%p_cnt^!=%%c"))^
   ))^&^
   (if 1 LSS ^^^!%%p_ndq^^^! (set "%%p_urv=^!%%p_urv:;=}{^!"^&set "%%p_urv={^!%%p_urv^!}"))^&^
   (if ^^^!%%p_ndq^^^! EQU 1 (set "%%p_aux=echo ^!%%p_urv^!") else (set "%%p_aux=^!@substr_extract^! %%p_urv { 1:} 4:1"))^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "%%%%p_aux%%"') do (^
    set "%%p_cnt=0"^&^
    (for %%b in (%%a) do (^
     (set /a "%%p_ivu=%%~b"^>NUL 2^>^&1)^>NUL^&set /a "%%p_ivu/=^!%%p_nor^!"^>NUL^&set /a "%%p_cnt+=1"^>NUL^&^
     (if defined %%p_ivn^^^!%%p_cnt^^^! (^
      (if ^^^!%%p_sel^^^! EQU 0 (^
       call set /a "%%p_ivu^!%%p_cnt^!+=^!%%p_ivu^!"^>NUL^
      ) else (^
       call set "%%p_aux=%%%%p_ivu^!%%p_cnt^!%%"^&^
       (if ^^^!%%p_sel^^^! EQU 1 if ^^^!%%p_ivu^^^! LSS ^^^!%%p_aux^^^! (set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"))^&^
       (if ^^^!%%p_sel^^^! EQU 2 if ^^^!%%p_aux^^^! LSS ^^^!%%p_ivu^^^! (set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"))^
      ))^
     ) else (set "%%p_ivu^!%%p_cnt^!=^!%%p_ivu^!"))^
    ))^
   ))^&^
   set "%%p_ivn="^&set "%%p_ivu=0"^&^
   (for /L %%a in (1 1 ^^^!%%p_urc^^^!) do (^
    (if defined %%p_ivu%%a (^
     set "%%p_aux=^!%%p_ivu%%a^!"^&^
     (if ^^^!%%p_sel^^^! EQU 0 (set /a "%%p_aux/=^!%%p_ndq^!")^>NUL)^&^
     (if ^^^!%%p_typ^^^! EQU 0 (^
      (if ^^^!%%p_ivu^^^! LSS ^^^!%%p_aux^^^! (^
       (if defined %%p_dnn (call set "%%p_ivn=%%%%p_ivn%%a%%"))^&(set "%%p_ivu=^!%%p_aux^!")^
      ))^
     ) else ((set /a "%%p_ivu+=^!%%p_aux^!")^>NUL))^&^
     set "%%p_ivu%%a="^
    ))^&^
    (if defined %%p_dnn (set "%%p_ivn%%a="))^
   ))^&^
   (if ^^^!%%p_eco^^^! NEQ 1 (^
    (if defined %%p_dun (set "^!%%p_dun^!=^!%%p_ivu^!"))^&^
    (if ^^^!%%p_typ^^^! EQU 0 (^
     (if defined %%p_dnn if defined %%p_ivn (set "^!%%p_dnn^!=^!%%p_ivn^!") else (set "^!%%p_dnn^!="))^
    ) else (^
     (if defined %%p_dnn if defined %%p_urn (set "^!%%p_dnn^!=^!%%p_urn^!") else (set "^!%%p_dnn^!="))^
    ))^&^
    set "^!%%p_uqn^!=^!%%p_uqv^!"^&^
    (for %%a in (aux,uqn,uqv,cqv,typ,urn,urv,ivu,ivn,sel,cnt,dun,dnn,ivn,ext,ndq,urc,nor,eco) do (set "%%p_%%a="))^
   ) else (^
    (if defined %%p_dun (echo "^!%%p_dun^!=^!%%p_ivu^!"))^&^
    (if ^^^!%%p_typ^^^! EQU 0 (^
     (if defined %%p_dnn if defined %%p_ivn (echo "^!%%p_dnn^!=^!%%p_ivn^!") else (echo "^!%%p_dnn^!="))^
    ) else (^
     (if defined %%p_dnn if defined %%p_urn (echo "^!%%p_dnn^!=^!%%p_urn^!") else (echo "^!%%p_dnn^!="))^
    ))^&^
    (echo "^!%%p_uqn^!=^!%%p_uqv^!")^
   ))^
  ))^
 ) else (echo Error [@typeperf_res_b]: Absent parameters.^&exit /b 1)) else set wds_tps_aux=

::      @typeperf_res_c - queries typeperf to get usage of every device applied to their specific capacity (normalized percentage).
::             Notes. #1: it is equivalent to @typeperf_res_a but stores part of its data in auxiliary file for better performance;
::                    #2: this macro has same set of parameters, except value of `1:%~3` can not be `2` (only `0` & `1`);
::                    #3: if macro uses files to read data, it ignores parameters `%~2` & `2:%~4`;
::                    #4: the home path of auxiliaty files is "%ProgramFiles%\wait.mds";
::                    #5: the names of auxiliaty files are "wait.mds.auxiliary.file.id002" & "wait.mds.auxiliary.file.id003";
::                    #6: for better performance the number of file lines is limited to 255 (it deletes files and fill them again).
::          Dependencies: @echo_params, @errorLevel, @chcp_file, @obj_newname, @perf_counter, @str_arrange, @str_clean, @str_encode,
::                        @substr_extract, @syms_replace, @typeperf, @typeperf_res_a, @unset_mac. Nominally: @cptooem, @oemtocp.
::
set @typeperf_res_c=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tpf_par (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],typeperf_res_a,typeperf_res_b,str_clean,oemtocp,cptooem,str_arrange,str_decode,errorLevel,obj_newname,typeperf,echo_params,chcp_file,perf_counter,str_encode,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F %%p in ('echo wds_tpf') do (^
   (for /F "tokens=1,2,3,4,5,6,7,8,9,10" %%a in ('echo.%%%%p_par%%') do (^
    (for %%k in ("1 %%p_uqn %%p_uqv %%~a","2 %%p_cqn %%p_cqv %%~b") do (^
     (for /F "tokens=1,2,3,4" %%l in ('"echo %%~k"') do (^
      set "%%m=%%o"^&^
      (if NOT "^!%%m^!"=="%%o" (echo Error [@typeperf_res_c]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
      (if defined %%m if not "^!%%m::=^!"=="^!%%m^!" (set "%%m="))^&^
      (if defined %%m if defined ^^^!%%m^^^! (set "%%n=^!%%o^!") else (set "%%m="))^&^
      (if not defined %%m (echo Error [@typeperf_res_c]: The parameter #%%l is absent or hasn't assigned query string.^&exit /b 1))^
     ))^
    ))^&^
    (for %%k in (typ,nor,dun,dnn,ndq,sel,dcn,eco) do (set "%%p_%%k="))^&^
    (for %%k in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j) do if not "%%k"=="" (^
     set "%%p_aux=%%k"^&set "%%p_tmp=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
     (if ^^^!%%p_aux^^^! EQU 1 ((set /a "%%p_typ=^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 2 ((set /a "%%p_nor=^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_dun=^!%%p_tmp^!")^
     else if ^^^!%%p_aux^^^! EQU 4 (set "%%p_dnn=^!%%p_tmp^!")^
     else if ^^^!%%p_aux^^^! EQU 5 ((set /a "%%p_ndq=^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 6 ((set /a "%%p_sel=^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 7 (set "%%p_dcn=^!%%p_tmp^!")^
     else if ^^^!%%p_aux^^^! EQU 8 ((set /a "%%p_eco=^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL))^
    ))^
   ))^&^
   (if not defined %%p_dun if not defined %%p_dcn if not defined %%p_dnn (echo Error [@typeperf_res_c]: All parameters 3:#5, 4:#6, 7:#9 are absent.^&exit /b 1))^&^
   set "%%p_par=3:%%p_duv 4:%%p_dnv"^&^
   (for %%a in ("%%p_typ 0 1 0 1","%%p_nor 1 2147483647 1 2","%%p_ndq 1 25 1 5","%%p_sel 0 2 0 6","%%p_eco 0 1 0") do (^
    (for /F "tokens=1,2,3,4,5" %%b in ('echo %%~a') do (^
     (if defined %%~b ((if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))) else (set "%%b=%%e"))^&^
     (if not "%%f"=="" (set "%%p_par=^!%%p_par^! %%f:^!%%b^!"))^
    ))^
   ))^&^
   (call %%@errorLevel%% 0)^&^
   (set %%p_quo="")^&(call set %%p_quo=%%%%p_quo:~1%%)^&^
   (for /F "tokens=*" %%a in ('echo "%%ProgramFiles%%\wait.mds"') do for %%b in (%%a) do (set "%%p_pat=%%b\"))^&^
   (call set "%%p_pat=%%%%p_pat:^!%%p_quo^!=%%")^&(set "%%p_pat=^!%%p_pat:^\^\=^\^!")^&^
   set "%%p_afn=^!%%p_pat^!wait.mds.auxiliary.file.id00"^&^
   set "%%p_vuq=^!%%p_uqv^!"^&^
   (for /F "tokens=1,2 delims==" %%a in ('"echo ^!%%p_vuq^!=%%p_vuq"') do if not "%%b"=="%%p_vuq" (^
    for /F "tokens=*" %%c in ('cmd /d /q /v:on /e:on /r "^!@str_encode^! %%p_vuq 3 "" "" 1"') do (set %%c)^
   ))^&^
   set "%%p_cnt=0"^&^
   (if exist "^!%%p_afn^!2" (^
    attrib -h -s +r "^!%%p_afn^!2"^>NUL 2^>^&1^&^
    (for /F "usebackq eol=; tokens=1,* delims==" %%a in ("^!%%p_afn^!2") do (^
     (if "%%a"=="^!%%p_vuq^!" (set "%%p_uvq=%%b") else if "%%b"=="^!%%p_vuq^!" (set "%%p_uvq=%%b"))^&^
     set /a "%%p_cnt+=1"^>NUL^
    ))^&^
    attrib +h +s -r "^!%%p_afn^!2"^>NUL 2^>^&1^
   ))^&^
   (if 255 LSS ^^^!%%p_cnt^^^! ((call del /f /a /q "^!%%p_afn^!2")^>nul))^&^
   (if defined %%p_uvq if exist "^!%%p_afn^!3" (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_b^! %%p_uvq ^!%%p_par^! 7:1 8:1"') do if ^^^!errorlevel^^^! EQU 0 (^
     set %%a^>NUL 2^>^&1^
    ))^>NUL 2^>^&1^&^
    (if ^^^!errorlevel^^^! EQU 0 (^
     call set "%%p_dnv=%%%%p_dnv:^!%%p_quo^!=%%"^&set "%%p_vdn=^!%%p_dnv^!"^&set /a "%%p_duv*=^!%%p_nor^!"^>NUL^&^
     (for /F "tokens=1,2 delims==" %%a in ('"echo ^!%%p_vdn^!=%%p_vdn"') do if not "%%b"=="%%p_vdn" (^
      for /F "tokens=*" %%c in ('cmd /d /q /v:on /e:on /r "^!@str_encode^! %%p_vdn 3 "" "" 1"') do (set %%c)^
     ))^&^
     set "%%p_cnt=0"^&^
     (if exist "^!%%p_afn^!3" (^
      attrib -h -s +r "^!%%p_afn^!3"^>NUL 2^>^&1^&^
      (for /F "usebackq eol=; tokens=1,* delims==" %%a in ("^!%%p_afn^!3") do (^
       (if "%%a"=="^!%%p_vdn^!" (^
        set "%%p_dcv=%%b"^&set /a "%%p_aux=^!%%p_dcv^!/100"^>NUL^&set /a "%%p_duv/=^!%%p_aux^!"^>NUL^&set "%%p_uqv=^!%%p_uvq^!"^
       ))^&^
       set /a "%%p_cnt+=1"^>NUL^
      ))^&^
      attrib +h +s -r "^!%%p_afn^!3"^>NUL 2^>^&1^
     ))^&^
     (if 255 LSS ^^^!%%p_cnt^^^! ((call del /f /a /q "^!%%p_afn^!3")^>nul))^
    ) else (call %%@errorLevel%% 0))^
   ))^&^
   (if not defined %%p_dcv (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_a^! %%p_uqv %%p_cqv ^!%%p_par^! 7:%%p_dcv 8:1"') do (^
     (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
    ))^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@obj_newname^! %%p_tmp 1:%%p_pat 2:%%%%p_quo%%wait.mds.temporary.file.%%%%p_quo%% 3:%%%%p_quo%%.bak%%%%p_quo%% 4:1 6:1"') do (set %%a))^&^
    (set %%p_bar="^^^|")^&^
    (for %%a in ("2 %%p_vuq %%p_uqv","3 %%p_vdn %%p_dcv") do if defined %%p_bar for /F "tokens=1,2,3" %%b in ('"echo %%~a"') do ((^
     (if %%b EQU 3 (^
      set "%%c=^!%%p_dnv^!"^&^
      (for /F "tokens=1,2 delims==" %%e in ('"echo ^!%%c^!=%%c"') do if not "%%f"=="%%c" (^
       for /F "tokens=*" %%g in ('cmd /d /q /v:on /e:on /r "^!@str_encode^! %%c 3 "" "" 1"') do (set %%g)^
      ))^
     ))^&^
     (if exist "^!%%p_afn^!%%b" (^
      set "%%p_aux=2"^&^
      (for /F "tokens=2" %%e in ('cmd /d /q /r "attrib %%%%p_quo%%^!%%p_afn^!%%b%%%%p_quo%% %%%%p_bar:~-2,1%% findstr /C:" SH ""') do (set "%%p_aux=0"))^&^
      (if ^^^!%%p_aux^^^! EQU 0 (^
       (for /F "usebackq eol=; tokens=1,* delims==" %%e in ("^!%%p_afn^!%%b") do if ^^^!%%p_aux^^^! NEQ 2 (^
        (if "%%e"=="^!%%c^!" (^
         if "%%f"=="^!%%d^!" (set "%%p_aux=2") else (set "%%p_aux=1"^&(echo ^^^!%%c^^^!=^^^!%%d^^^!)^>^>"^!%%p_pat^!^!%%p_tmp^!")^
        ) else (^
         (echo %%e=%%f)^>^>"^!%%p_pat^!^!%%p_tmp^!"^
        ))^
       ))^
      ))^
     ) else (set "%%p_aux=0"))^&^
     (if ^^^!%%p_aux^^^! EQU 0 (^
      (echo ^^^!%%c^^^!=^^^!%%d^^^!)^>^>"^!%%p_afn^!%%b"^
     ) else if ^^^!%%p_aux^^^! EQU 1 (^
      (call move /y "^!%%p_pat^!^!%%p_tmp^!" "^!%%p_afn^!%%b")^>nul^
     ))^&^
     (if exist "^!%%p_pat^!^!%%p_tmp^!" (^<nul set /P "="^>^^^!%%p_pat^^^!^^^!%%p_tmp^^^!)^>nul)^&^
     (if exist "^!%%p_afn^!%%b" (attrib +h +s -r "^!%%p_afn^!%%b")^>NUL 2^>^&1)^
    )^>NUL 2^>^&1 ^&^& (echo.^>nul) ^|^| (set "%%p_bar=")))^&^
    (if exist "^!%%p_pat^!^!%%p_tmp^!" (call del /f /a /q "^!%%p_pat^!^!%%p_tmp^!")^>nul)^
   ))^&^
   (if defined %%p_dun if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dun^!=^!%%p_duv^!") else (echo "^!%%p_dun^!=^!%%p_duv^!"))^&^
   (if defined %%p_dnn (^
    (if defined %%p_dnv (^
     (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=^!%%p_dnv^!") else (echo "^!%%p_dnn^!=^!%%p_dnv^!"))^
    ) else (^
     (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=") else (echo "^!%%p_dnn^!="))^
    ))^
   ))^&^
   (if defined %%p_dcn if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dcn^!=^!%%p_dcv^!") else (echo "^!%%p_dcn^!=^!%%p_dcv^!"))^&^
   (if ^^^!%%p_eco^^^! NEQ 1 (^
    set "^!%%p_uqn^!=^!%%p_uqv^!"^&set "^!%%p_cqn^!=^!%%p_cqv^!"^&^
    (for %%a in (afn,aux,bar,cnt,cqn,cqv,dcn,dcv,dnn,dnv,dun,duv,eco,ndq,nor,par,pat,quo,sel,tmp,typ,uqn,uqv,uvq,vdn,vuq) do (set "%%p_%%a="))^
   ) else (^
    (echo "^!%%p_uqn^!=^!%%p_uqv^!")^&(echo "^!%%p_cqn^!=^!%%p_cqv^!")^
   ))^
  ))^
 ) else (echo Error [@typeperf_res_c]: Absent parameters.^&exit /b 1)) else set wds_tpf_par=

::      @typeperf_res_d - queries typeperf to calculate current use of devices or to select device by its current use.
::             Notes. #1: it is equivalent to @typeperf_res_b but stores in auxiliary file the collation of localized
::                        counter to its search template for better performance;
::                    #2: the use of the macro has sense only with template of query, with plain query use @typeperf_res_b;
::                    #3: this macro has same set of parameters as @typeperf_res_b;
::                    #4: the name & location of its auxiliaty file is "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id002";
::                    #5: for better performance the number of file lines is limited to 255 (it deletes file and fill it again).
::          Dependencies: @echo_params, @errorLevel, @chcp_file, @obj_newname, @perf_counter, @str_arrange, @str_clean, @str_encode,
::                        @substr_extract, @syms_replace, @typeperf, @typeperf_res_b, @unset_mac. Nominally: @cptooem, @oemtocp.
::
set @typeperf_res_d=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_tpu_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],obj_newname,typeperf_res_b,str_encode,errorLevel,str_clean,oemtocp,cptooem,typeperf,echo_params,chcp_file,perf_counter,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F %%p in ('echo wds_tpu') do (^
   (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%%%p_aux%%') do (^
    set "%%p_uqn=%%~a"^&(if NOT "^!%%p_uqn^!"=="%%~a" (echo Error [@typeperf_res_d]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (if defined %%p_uqn if not "^!%%p_uqn::=^!"=="^!%%p_uqn^!" (set "%%p_uqn="))^&^
    (if defined %%p_uqn if defined ^^^!%%p_uqn^^^! (set "%%p_uqv=^!%%~a^!") else (set "%%p_uqn="))^&^
    (if not defined %%p_uqn (echo Error [@typeperf_res_d]: The parameter #1 is absent or hasn't assigned query string.^&exit /b 1))^&^
    set "%%p_dun="^&set "%%p_dnn="^&^
    (for %%j in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i) do if not "%%j"=="" (^
     set "%%p_aux=%%j"^&set "%%p_quo=^!%%p_aux:~2^!"^&set "%%p_aux=^!%%p_aux:~0,1^!"^&^
     (if ^^^!%%p_aux^^^! EQU 1 ((set /a "%%p_typ=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 2 ((set /a "%%p_nor=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_dun=^!%%p_quo^!")^
     else if ^^^!%%p_aux^^^! EQU 4 (set "%%p_dnn=^!%%p_quo^!")^
     else if ^^^!%%p_aux^^^! EQU 5 ((set /a "%%p_ndq=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 6 ((set /a "%%p_sel=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 7 ((set /a "%%p_ext=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%p_aux^^^! EQU 8 ((set /a "%%p_eco=^!%%p_quo^!"^>NUL 2^>^&1)^>NUL))^
    ))^
   ))^&^
   (if not defined %%p_dun if not defined %%p_dnn (echo Error [@typeperf_res_d]: Both parameters 3:#4 and 4:#5 are absent.^&exit /b 1))^&^
   set "%%p_aux=3:%%p_duv 4:%%p_dnv"^&^
   (for %%a in ("%%p_typ 0 1 0 1","%%p_nor 1 2147483647 1 2","%%p_ndq 1 25 1 5","%%p_sel 0 2 0 6","%%p_ext 0 1 1 7","%%p_eco 0 1 0") do (^
    (for /F "tokens=1,2,3,4,5" %%b in ('echo %%~a') do (^
     (if defined %%~b ((if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))) else (set "%%b=%%e"))^&^
     (if not "%%f"=="" (set "%%p_aux=^!%%p_aux^! %%f:^!%%b^!"))^
    ))^
   ))^&^
   (call %%@errorLevel%% 0)^&(set %%p_quo="")^&(call set %%p_quo=%%%%p_quo:~1%%)^&^
   (for /F "tokens=*" %%a in ('echo "%%ProgramFiles%%\wait.mds"') do for %%b in (%%a) do (set "%%p_pat=%%b\"))^&^
   call set "%%p_pat=%%%%p_pat:^!%%p_quo^!=%%"^&(set "%%p_pat=^!%%p_pat:^\^\=^\^!")^&^
   set "%%p_afn=^!%%p_pat^!wait.mds.auxiliary.file.id00"^&^
   set "%%p_vuq=^!%%p_uqv^!"^&^
   (for /F "tokens=1,2 delims==" %%a in ('"echo ^!%%p_vuq^!=%%p_vuq"') do if not "%%b"=="%%p_vuq" (^
    for /F "tokens=*" %%c in ('cmd /d /q /v:on /e:on /r "^!@str_encode^! %%p_vuq 3 "" "" 1"') do (set %%c)^
   ))^&^
   set "%%p_cnt=0"^&^
   (if exist "^!%%p_afn^!2" (^
    attrib -h -s +r "^!%%p_afn^!2"^>NUL 2^>^&1^&^
    (for /F "usebackq eol=; tokens=1,* delims==" %%a in ("^!%%p_afn^!2") do (^
     (if "%%a"=="^!%%p_vuq^!" (set "%%p_uvq=%%b") else if "%%b"=="^!%%p_vuq^!" (set "%%p_uvq=%%b"))^&^
     set /a "%%p_cnt+=1"^>NUL^
    ))^&^
    attrib +h +s -r "^!%%p_afn^!2"^>NUL 2^>^&1^
   ))^&^
   (if 255 LSS ^^^!%%p_cnt^^^! ((call del /f /a /q "^!%%p_afn^!2")^>nul))^&^
   (if defined %%p_uvq (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_b^! %%p_uvq ^!%%p_aux^! 8:1"') do if ^^^!errorlevel^^^! EQU 0 (^
     set %%a^>NUL 2^>^&1^
    ))^>NUL 2^>^&1^&^
    (if ^^^!errorlevel^^^! EQU 0 (set "%%p_uqv=^!%%p_uvq^!") else (set "%%p_uvq="^&call %%@errorLevel%% 0))^
   ))^&^
   (if not defined %%p_uvq (^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_b^! %%p_uqv ^!%%p_aux^! 8:1"') do (^
     (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
    ))^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@obj_newname^! %%p_tmp 1:%%p_pat 2:%%%%p_quo%%wait.mds.temporary.file.%%%%p_quo%% 3:%%%%p_quo%%.bak%%%%p_quo%% 4:1 6:1"') do (set %%a))^&^
    (set %%p_bar="^^^|")^&^
    (^
     (if exist "^!%%p_afn^!2" (^
      set "%%p_aux=2"^&^
      (for /F "tokens=2" %%a in ('cmd /d /q /r "attrib %%%%p_quo%%^!%%p_afn^!2%%%%p_quo%% %%%%p_bar:~-2,1%% findstr /C:" SH ""') do (set "%%p_aux=0"))^&^
      (if ^^^!%%p_aux^^^! EQU 0 (^
       (for /F "usebackq eol=; tokens=1,* delims==" %%a in ("^!%%p_afn^!2") do if ^^^!%%p_aux^^^! NEQ 2 (^
        (if "%%a"=="^!%%p_vuq^!" (^
         if "%%b"=="^!%%p_uqv^!" (set "%%p_aux=2") else (set "%%p_aux=1"^&(echo ^^^!%%p_vuq^^^!=^^^!%%p_uqv^^^!)^>^>"^!%%p_pat^!^!%%p_tmp^!")^
        ) else (^
         (echo %%a=%%b)^>^>"^!%%p_pat^!^!%%p_tmp^!"^
        ))^
       ))^
      ))^
     ) else (set "%%p_aux=0"))^&^
     (if ^^^!%%p_aux^^^! EQU 0 (^
      (echo ^^^!%%p_vuq^^^!=^^^!%%p_uqv^^^!)^>^>"^!%%p_afn^!2"^
     ) else if ^^^!%%p_aux^^^! EQU 1 (^
      (call move /y "^!%%p_pat^!^!%%p_tmp^!" "^!%%p_afn^!2")^>nul^
     ))^&^
     (if exist "^!%%p_afn^!2" (attrib +h +s -r "^!%%p_afn^!2")^>NUL 2^>^&1)^
    )^>NUL 2^>^&1^&^
    (if exist "^!%%p_pat^!^!%%p_tmp^!" (call del /f /a /q "^!%%p_pat^!^!%%p_tmp^!")^>nul)^
   ))^&^
   (if defined %%p_dun if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dun^!=^!%%p_duv^!") else (echo "^!%%p_dun^!=^!%%p_duv^!"))^&^
   (if defined %%p_dnn (^
    (if defined %%p_dnv (^
     (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=^!%%p_dnv^!") else (echo "^!%%p_dnn^!=^!%%p_dnv^!"))^
    ) else (^
     (if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_dnn^!=") else (echo "^!%%p_dnn^!="))^
    ))^
   ))^&^
   (if ^^^!%%p_eco^^^! NEQ 1 (^
    set "^!%%p_uqn^!=^!%%p_uqv^!"^&^
    (for %%a in (afn,aux,bar,cnt,dnn,dnv,dun,duv,eco,ext,ndq,nor,pat,quo,sel,tmp,typ,uqn,uqv,uvq,vuq) do (set "%%p_%%a="))^
   ) else (^
    (echo "^!%%p_uqn^!=^!%%p_uqv^!")^
   ))^
  ))^
 ) else (echo Error [@typeperf_res_d]: Absent parameters.^&exit /b 1)) else set wds_tpu_aux=
 
::    @typeperf_res_use - performs typeperf queries of devices by their hardcoded types, returns percent of their current use.
::                        %~1 == hardcoded type of objects to query. Supported nick names & corresponding query of device use:
::                               `1` OR `network` OR `n` - "[Network Interface](*)\[Bytes Total/sec]"     (default value);
::                               `2` OR `disk`    OR `d` - "[PhysicalDisk](*)\[% Disk Time]"          (`*` <==> `_Total`);
::                               `3` OR `volume`  OR `v` - "[LogicalDisk](*)\[% Free Space]"          (`*` <==> `_Total`);
::                               `4` OR `cpu`     OR `u` - "[Processor](*)\[% Processor Time]"        (`*` <==> `_Total`);
::                               `5` OR `task`    OR `t` - "[Process](*)\[% Processor Time]"          (`*` <==> `_Total`);
::                        %~2 == external variable name for assigning use value (percent);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == the specific device name in the query instead of wildcard `*` (variable name with string value);
::                      2:%~4 == number of typeperf queries of current use of devices [1..25], default value is `3`;
::                      3:%~5 == key argument to stop on errors (`1`), default is `0` to set `0 %` for absent "device";
::                      4:%~6 == key argument to echo result (`1`) instead of assigning it, default is `0`.
::             Notes. #1: to get valid specific item name instead of wildcard `*`, use macro @typeperf_devs with template above;
::                    #2: in the case of invalid device name it returns `0 %` (if `3:%~5`==`0`) & always sets errorlevel to `1`;
::                    #3: in the case of `task` type (`5`) it calculates activities of processes as follows:
::                               `*`             - subtracts `Idle` process time from `_Total` & divides it by number of CPU cores;
::                               `sometaskname`  - it returns result for the task without number in its name (in case of several 
::                                                 tasks with the same module typeperf.exe adds numeric suffixes to their names);
::                               `sometaskname*` - (Win7 and higher) returns total activities of all running tasks with substring
::                                                 "sometaskname" in module name.
::          Dependencies: @echo_params, @errorLevel, @chcp_file, @obj_newname, @perf_counter, @str_arrange, @str_clean, @str_encode,
::                        @substr_extract, @syms_replace, @typeperf, @typeperf_res_a, @typeperf_res_b, @typeperf_res_c, @typeperf_res_d,
::                        @unset_mac. Nominally: @cptooem, @oemtocp.
::
set @typeperf_res_use=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ruq_aux (^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_mac^![^^^^^^^^^^^^^^^^^^^^],typeperf_res_a,typeperf_res_b,typeperf_res_c,typeperf_res_d,str_clean,oemtocp,cptooem,str_arrange,str_decode,errorLevel,obj_newname,typeperf,echo_params,chcp_file,perf_counter,str_encode,substr_extract,syms_replace"') do (set %%a))^&^
  (for /F %%p in ('echo wds_ruq_') do (^
   (for /F "tokens=1,2,3,4,5,6" %%a in ('echo.%%%%paux%%') do (^
    set "%%pdun=%%~b"^&(if NOT "^!%%pdun^!"=="%%~b" (echo Error [@typeperf_res_use]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
    (if defined %%pdun if not "^!%%pdun::=^!"=="^!%%pdun^!" (set "%%pdun="))^&^
    (if not defined %%pdun (echo Error [@typeperf_res_use]: The parameter #2 is absent.^&exit /b 1))^&^
    set "%%ptyp=%%~a"^&(for %%f in ("network=1" "disk=2" "volume=3" "cpu=4" "task=5" "n=1" "d=2" "v=3" "u=4" "t=5") do (set "%%ptyp=^!%%ptyp:%%~f^!"^>NUL 2^>^&1))^&^
    set "%%pdnv="^&^
    (for %%g in (%%~c,%%~d,%%~e,%%~f) do if not "%%g"=="" (^
     set "%%paux=%%g"^&set "%%ptmp=^!%%paux:~2^!"^&^
     (if defined %%ptmp (^
      set "%%paux=^!%%paux:~0,1^!"^&^
      (if ^^^!%%paux^^^! EQU 1 (^
       if defined %%ptmp if defined ^^^!%%ptmp^^^! (^
        for /F "tokens=*" %%g in ('echo %%^^^!%%ptmp^^^!%%') do (set "%%pdnv=%%~g")^
       )^
      ) else if ^^^!%%paux^^^! EQU 2 ((set /a "%%pndq=^!%%ptmp^!"^>NUL 2^>^&1)^>NUL)^
      else if ^^^!%%paux^^^! EQU 3 ((set /a "%%perr=^!%%ptmp^!"^>NUL 2^>^&1)^>NUL)^
      else if ^^^!%%paux^^^! EQU 4 ((set /a "%%peco=^!%%ptmp^!"^>NUL 2^>^&1)^>NUL))^
     ))^
    ))^
   ))^&^
   (for %%a in ("%%ptyp 1 5 1","%%pndq 1 25 3","%%perr 0 1 0","%%peco 0 1 0") do for /F "tokens=1,2,3,4" %%b in ('echo %%~a') do (^
    if defined %%~b (^
     (if ^^^!%%b^^^! LSS %%c (set "%%b=%%e"))^&(if %%d LSS ^^^!%%b^^^! (set "%%b=%%e"))^
    ) else (set "%%b=%%e")^
   ))^&^
   (if defined %%pdnv (^
    (set "%%pdnv=^!%%pdnv:[=/CHR{5B}^!")^&(set "%%pdnv=^!%%pdnv:]=/CHR{5D}^!")^
   ) else (^
    (if ^^^!%%ptyp^^^! EQU 1 (set "%%pdnv=*") else (set "%%pdnv=_Total"))^
   ))^&^
   set "%%pduv=0"^&^
   (if ^^^!%%ptyp^^^! EQU 1 (^
    (set %%paux="[Network Interface](^!%%pdnv^!)\[Bytes Total/sec]")^&^
    (set %%ptmp="[Network Interface](^!%%pdnv^!)\[Current Bandwidth]")^&^
    (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_c^! %%paux %%ptmp 3:%%pduv 1:1 2:8 5:^!%%pndq^! 6:0 8:1"') do (^
     (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (if ^^^!%%perr^^^! EQU 1 (echo %%a^&exit /b 1))^
    ))^
   ) else (^
    (if ^^^!%%ptyp^^^! EQU 2 (set %%paux="[PhysicalDisk](^!%%pdnv^!)\[%% Disk Time]"))^&^
    (if ^^^!%%ptyp^^^! EQU 3 (set %%paux="[LogicalDisk](^!%%pdnv^!)\[%% Free Space]"))^&^
    (if ^^^!%%ptyp^^^! EQU 4 (set %%paux="[Processor](^!%%pdnv^!)\[%% Processor Time]"))^&^
    (if ^^^!%%ptyp^^^! EQU 5 (^
     (set %%paux="[Process](^!%%pdnv^!)\[%% Processor Time]")^&^
     (if "^!%%pdnv^!"=="_Total" (^
      (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_d^! %%paux 3:%%pduv 1:1 2:1 5:1 6:0 8:1"') do (^
       (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
      ))^&^
      (set %%paux="[Process](Idle)\[%% Processor Time]")^&^
      (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_d^! %%paux 3:%%ptmp 1:1 2:1 5:^!%%pndq^! 6:0 8:1"') do (^
       (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
      ))^&^
      set /a "%%pndq=(^!%%pduv^!+50)/100"^>NUL^&^
      (if ^^^!%%ptmp^^^! LSS ^^^!%%pduv^^^! (set /a "%%pduv-=^!%%ptmp^!"^>NUL) else (set "%%pduv=0"))^
     ) else (^
      (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_d^! %%paux 3:%%pduv 1:1 2:1 5:^!%%pndq^! 6:0 8:1"') do (^
       (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (if ^^^!%%perr^^^! EQU 1 (echo %%a^&exit /b 1))^
      ))^&^
      (if ^^^!errorlevel^^^! EQU 0 (^
       (set %%paux="[Process](_Total)\[%% Processor Time]")^&^
       (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_d^! %%paux 3:%%ptmp 1:1 2:1 5:1 6:0 8:1"') do (^
        (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (echo %%a^&exit /b 1)^
       ))^&^
       set /a "%%pndq=(^!%%ptmp^!+50)/100"^>NUL^
      ))^
     ))^&^
     (if 0 LSS ^^^!%%pndq^^^! (set /a "%%pduv/=^!%%pndq^!"^>NUL) else (set "%%pduv=0"))^
    ) else (^
     (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@typeperf_res_d^! %%paux 3:%%pduv 1:1 2:1 5:^!%%pndq^! 6:0 8:1"') do (^
      (set %%a^>NUL 2^>^&1) ^&^& (echo.^>nul) ^|^| (if ^^^!%%perr^^^! EQU 1 (echo %%a^&exit /b 1))^
     ))^
    ))^
   ))^&^
   (if 100 LSS ^^^!%%pduv^^^! (set "%%pduv=100"))^&^
   (if ^^^!%%peco^^^! NEQ 1 (^
    set "^!%%pdun^!=^!%%pduv^!"^&(for %%a in (aux,dnv,dun,duv,eco,err,ndq,tmp,typ) do (set "%%p%%a="))^
   ) else (echo "^!%%pdun^!=^!%%pduv^!"))^
  ))^
 ) else (echo Error [@typeperf_res_use]: Absent parameters.^&exit /b 1)) else set wds_ruq_aux=

::           @nicconfig - finds a network device that matches the input request and returns its data;
::                        %~1 == the name of variable to return current device state (0/1 <=> Enabled/Disabled);
::                      All next parameters are optional, must follow internal identifiers and marker ":" in arbitrary order; they
::                      contain only variable parameters - input values define device query, output only for undefined variables:
::                      0:%~2 == connection-specific DNS suffix;
::                      1:%~3 == the device name or its description;
::                      2:%~4 == physical MAC address;
::                      3:%~5 == DHCP enabled (1/0 <=> True/False, -1 <=> unreadable because of current code page);
::                      4:%~6 == autoconfiguration enabled (1/0 <=> True/False, -1 <=> unreadable because of current code page);
::                      5:%~7 == IPv4 address of device;
::                      6:%~8 == subnet mask;
::                      7:%~9 == default gateway;
::                      8:%~10== DHCP server;
::                      9:%~11== DNS servers (output: CSV list of server names as quoted strings);
::                      A:%~12== WINS server;
::                        - next 3 variable parameters are valuable only for Win7 & later:
::                      B:%~13== IPv6 address;
::                      C:%~14== DHCPv6 IAID;
::                      D:%~15== DHCPv6 client DUID;
::                      Key argument parameters:
::                      E:%~16== modify variables with input values by found values (`1`), default is `0` to skip.
::                      F:%~17== echo result (`1`) instead of assigning it, default is `0`.
::            Precaution: any specified variable (`%~1`, `0:%~2`-`E:%~16`) must be preliminary cleared (undefined), otherwise their
::                        values will be used for search of device.
::             Notes. #1: it returns data only for devices listed by the "ipconfig.exe" command;
::                    #2: the input string values must have only symbols to do search, without quotes;
::                    #3: the search of device names starts from the begin of every string, i.e. it treats them as prefixes
::                        of each other to find match, preliminary macro removes all space & control symbols from strings;
::                    #4: if the string containing item to search device has encoded symbols, it must decoded before use;
::                    #5: for all other items it searches exact match of values, but case insensitive;
::                    #6: macro returns result for 1st matched network device;
::                    #7: due to big size of macro & to big number of its parameters, it's recommended to use short variable names.
::          Dependencies: @binman, @cptooem, @oemtocp, @str_clean, @syms_replace, @unset_alev.
::
set @nicconfig=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_nic_aux for /F %%y in ('echo.wds_nic_') do if defined %%yt (^
  (for %%a in ("5=Error [@nicconfig]: ","6=D,C,B,A,9,8,7,6,5,4,3,2,1,0","c=","ir=","f=0","o=","e=0") do (set "wds_nic_%%~a"))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17" %%a in ('echo.%%%%yaux%%') do (^
   (if defined %%~a (set "%%yir=^!%%~a^!"))^&^
   set "%%~a=1"^&(if not "^!%%~a^!"=="1" (echo ^^^!%%y5^^^!Incorrect name `%%~a`.^&exit /b 1))^&^
   set "%%ynr=%%~a"^&^
   (for %%r in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n,%%~o,%%~p,%%~q) do if not "%%r"=="" (^
    set "%%yaux=%%r"^&set "%%yt=^!%%yaux:~2^!"^&set "%%yaux=^!%%yaux:~0,1^!"^&^
    (if defined %%yt (set /a "%%yn=0x^!%%yaux^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yn^^^! LSS 14 (^
      set "%%yn^!%%yaux^!=^!%%yt^!"^&^
      (if defined ^^^!%%yt^^^! (set "%%yf=1"^&call set "%%yi^!%%yaux^!=%%^!%%yt^!%%") else (set "%%yi^!%%yaux^!="))^
     ) else if ^^^!%%yn^^^! EQU 14 (if "^!%%yt^!"=="1" (set "%%yo=1")^
     ) else if ^^^!%%yn^^^! EQU 15 (if "^!%%yt^!"=="1" (set "%%ye=1")^
     ))^
    ))^
   ))^&^
   set "%%yaux="^
  ))^&(if ^^^!%%yf^^^! EQU 0 (echo ^^^!%%y5^^^!Absent input values.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /r "^!@unset_alev^! 1:binman,cptooem,oemtocp,str_clean,syms_replace 2:%%y 5:1 6:1"') do (set %%a))^&^
  (cd /d "^!TEMP^!")^&^
  (echo "%%ye=^!%%ye^!")^&^
  set "cvcp="^&set "n=0"^&(for %%a in (1,3,4) do if defined %%yn%%a (set "n=%%a"))^&^
  (if 0 LSS ^^^!n^^^! (^
   (for /F "tokens=2 delims=:" %%a in ('chcp') do for /F %%b in ('echo.%%~a') do (set "a=%%b"))^&^
   (for /F "skip=1 tokens=*" %%a in ('wmic os get codeset') do for /F %%b in ('echo.%%~a') do (set "b=%%b"))^&^
   (if ^^^!a^^^! NEQ ^^^!b^^^! (^
    (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2,3 delims=. " %%b in ('echo %%a') do if "%%b%%c"=="51" (^
     set "cvcp=1"^
    ))^&^
    (if 1 LSS ^^^!n^^^! (^
     set "i=^!time^!"^&^
     (for /F "tokens=1,2,3,4 delims=0123456789" %%a in ('echo.^^^!i^^^!') do for %%b in (" ","%%b","%%c","%%d") do if not "%%~b"=="" (^
      set "i=^!i:%%~b=^!"^
     ))^&^
     (call set %%yt="%%TEMP%%\wait.mds.auxiliary.file.id^!i^!.nicconfig.bak")^&^
     (if not exist ^^^!%%yt^^^! (^
      (echo..)^>^^^!%%yt^^^!^&^
      (for /F "tokens=2,3,4,5 delims=([/])" %%b in ('"^<nul copy /-Y nul ^!%%yt^!"') do if 1 LSS ^^^!n^^^! for /F "tokens=1,2,3,4" %%f in ('echo.%%~b %%~c %%~d %%~e') do (^
       set "t=?"^&(if not "%%~i"=="" (set "t=[%%~h]") else if not "%%~g"=="" (set "t=[%%~g]"))^&^
       (if "^!t:NO=^!"=="[]" (^
        set "n=0"^&(if "%%~i"=="" (set "%%yy=%%~f"^&set "%%yn=%%~g") else (set "%%yy=%%~g"^&set "%%yn=%%~i"))^
       ))^
      ))^&(call del /F /A /Q %%%%yt:^^^!i^^^!=*%%)^
     ))^
    ))^
   ))^>NUL 2^>^&1^&^
   (if 1 LSS ^^^!n^^^! (set "%%yy=Yes"^&set "%%yn=No"))^
  ))^&^
  (^^^!%%y3^^^!"^!@binman^!")^&^
  (if defined %%yi1 for /F %%a in ('^^^!%%y3^^^!"^!@str_clean^! %%yi1 287 1"') do (set %%a))^&^
  set "n=0"^&^
  (for /F "tokens=*" %%a in ('echo.": =~"') do for /F "tokens=1,* delims=:" %%b in ('"ipconfig /all%%%%y4:~-2,1%%echo.done"') do for /F %%d in ('echo.%%~b') do if defined n (^
   set "t=%%~b:%%~c"^&^
   (for /F "tokens=1,2 delims=~" %%e in ('"echo.^!t:%%~a^!"') do (^
    set "d=%%~e"^&^
    (if "^!d:~0,3^!"=="   " (if 1 LSS ^^^!n^^^! (^
     set "t="^&^
     (if ^^^!c^^^! LSS 0 (^
      if "^!d:DNS=^!"=="^!d^!" (set "vr=1"^&set "c=0") else (set "vr=0"^&set "v0=%%~f"^&set "c=1")^
     ) else if ^^^!c^^^! EQU 0 (^
      (if "^!d:DNS=^!"=="^!d^!" (set "t=1") else (set "v0=%%~f"))^&set "c=1"^
     ) else (set "t=1"))^&^
     (if defined t if ^^^!c^^^! EQU 1 (^
      set "v1=%%~f"^&set "c=2"^
     ) else if ^^^!c^^^! EQU 2 (^
      set "v2=%%~f"^&set "c=3"^
     ) else (^
      (for /F "tokens=1,*" %%g in ('"echo. . ^!d^!"') do (set "d=%%h"))^&^
      (if ^^^!vr^^^! EQU 1 (set "v=%%~f") else (^
       (if "%%~f"=="" (^
        if ^^^!c^^^! EQU 9 (set "v=^!d^!"^&set "d=DNS?")^
       ) else (^
        for /F "delims=( " %%g in ('"echo.%%~f"') do (set "v=%%g")^
       ))^&^
       (for /F "tokens=1,2,3,4 delims=." %%g in ('echo.^^^!v^^^!') do if "^!v^!"=="%%g.%%h.%%i.%%j" (^
        for /F "delims=0123456789" %%k in ('echo.%%g%%h%%i%%j~') do if "%%~k"=="~" (set "i=1") else (set "i=")^
       ) else (set "i="))^
      ))^&^
      set "b=1"^&^
      (if not defined i if ^^^!c^^^! LEQ 4 (^
       (if ^^^!c^^^! EQU 3 if "^!d:DHCP =^!"=="^!d^!" (set "b="))^&^
       (if defined b (^
        (if defined %%yn^^^!c^^^! (^
         (set "%%yt=^!v^!")^&^
         (if defined cvcp (^
          (for /F "tokens=*" %%g in ('^^^!%%y3^^^!"^!@oemtocp^! %%yt %%yt 1"') do (set %%g))^&^
          (for /F %%g in ('echo.^!%%yt^!') do (set "%%yt=%%~g"))^
         ))^&^
         (for /F "tokens=1,2" %%g in ('echo."%%%%yt:^!%%yy^!=%%" "%%%%yt:^!%%yn^!=%%"') do (^
          if "%%~g"=="" (set "v^!c^!=1") else if "%%~h"=="" (set "v^!c^!=0") else (set "v^!c^!=-1")^
         ))^
        ))^&^
        set /a "c+=1"^>NUL^&set "b="^
       ) else (set "b=1"))^
      ))^&^
      (if defined b if ^^^!vr^^^! EQU 0 if "DNS^!d:~3^!"=="^!d^!" (^
       (if defined v9 (set v9=^^^!v9^^^!,"^!v^!") else (set v9="^!v^!"))^&set "c=9"^
      ) else if defined i (^
       if "IP^!d:~2^!"=="^!d^!" (set "v5=^!v^!"^&set "c=5"^
       ) else if ^^^!c^^^! EQU 5 (set "v6=^!v^!"^&set "c=6"^
       ) else if ^^^!c^^^! EQU 6 (set "v7=^!v^!"^&set "c=7"^
       ) else if "DHCP^!d:~4^!"=="^!d^!" (set "v8=^!v^!"^&set "c=8"^
       ) else if not "^!d:WINS=^!"=="^!d^!" (set "vA=^!v^!"^&set "c=10"^
       )^
      ) else for %%g in ("IAID 12 C" "DUID 13 D" "Ipv6 11 B") do if defined b for /F "tokens=1,2,3" %%h in ('echo.%%~g') do if not "^!d:%%h=^!"=="^!d^!" (^
       set "b="^&set "v%%j=^!v^!"^&set "c=%%i"^
      ))^
     ))^
    )) else (^
     (if 1 LSS ^^^!n^^^! (^
      set "n="^&^
      (for %%g in (r,^^^!%%y6^^^!) do if not defined n if defined %%yi%%g (^
       set "t=^!v%%g^!"^&^
       (if "%%g"=="1" (^
        (for /F %%h in ('^^^!%%y3^^^!"^!@str_clean^! t 287 1"') do (set %%h))^&^
        (if "^!t^!"=="^!%%yi1^!" (^
         (if defined cvcp for /F "tokens=*" %%h in ('^^^!%%y3^^^!"^!@oemtocp^! v1 v1 1"') do (set %%h))^
        ) else (set "n=2"))^
       ) else for /F %%h in ('"echo.%%%%yi%%g:^!t^!=%%"') do (set "n=2"))^
      ))^
     ))^&^
     (if defined n (^
      set "c=-1"^&set "n=2"^&(for %%g in (^^^!%%y6^^^!) do (set "v%%g="))^&set "vr=1"^&set "v3=0"^&set "v4=0"^
     ))^
    ))^
   ))^
  ))^&^
  (if not defined n for %%g in (r,^^^!%%y6^^^!) do if defined %%yn%%g (^
   (if defined %%yo (set "%%yi%%g="))^&(if not defined %%yi%%g (echo "^!%%yn%%g^!=^!v%%g^!"))^
  ))^
 ) else (^
  set "%%yt=1"^&(if not "^!%%yt^!"=="1" (echo Error [@nicconfig]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  (for /F %%a in ('echo."%%"') do (^
   (set %%yt="set %%y5=@nicconfig%%%%y4:~-2,1%%(for /F %%%%y4:~0,1%%tokens=*%%%%y4:~0,1%% %%~ap in ('%%%%y3%%%%%%y4:~0,1%%%%%%%%y5%%%%^!%%yaux^!%%%%y4:~0,1%%') do (echo %%~ap))")^&^
   set "%%yaux="^&set "%%y3=cmd /d /q /e:on /v:on /r "^&(set %%y4="^^^&")^&^
   (for /F "tokens=*" %%b in ('start /b /i /ABOVENORMAL %%%%y3%%%%%%yt%%') do (^
    set "%%yt=%%b"^&^
    (if "^!%%yt:error [=^!"=="^!%%yt^!" (^
     if defined %%ye (if ^^^!%%ye^^^! NEQ 1 (set %%b) else (echo %%b)) else (set %%b)^
    ) else (echo %%b^&exit /b 1))^
   ))^
  ))^&(for %%a in (3,4,e,t) do (set "wds_nic_%%a="))^
 ) else (echo Error [@nicconfig]: Absent parameters.^&exit /b 1)) else set wds_nic_aux=

::             @netdevs - returns CSV lists of basic properties for currently active NIC devices;
::                      Except last optional arguments, all macro parameters are variable names for output of corresponding data;
::                        %~1 == the list of device names according typeperf.exe tool;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~2 == the list of device names according ipconfig.exe tool;
::                      2:%~3 == the list of IPv4 addresses;
::                      3:%~4 == the list of IPv6 addresses (Win Vista and later);
::                      4:%~5 == the list of physical MAC address;
::                      5:%~6 == the list of device indexes in query of `@typeperf` with "[Network Interface](*)\[Current Bandwidth]";
::                      6:%~7 == the count of active network devices;
::                      7:%~8 == the plain typeperf.exe query string for template "[Network Interface](*)\[Bytes Total/sec]";
::                      8:%~9 == the plain typeperf.exe query string for template "[Network Interface](*)\[Current Bandwidth]";
::                      Optional parameters:
::                      9:%~9 == custom digital shift to every index inside `5:%~6`, default is `0`;
::                      A:%~11== key `1` to return into `5:%~6` negative indexes for inactive devices, default is `0` to skip them;
::                      B:%~12== key argument to echo result (`1`) instead of assigning it, default is `0`.
::             Notes. #1: `6:%~7` & `7:%~8` <=> if found in auxiliaty file "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id002";
::                    #2: after installation of library the auxiliary file is empty, at 1st start it returns only `6:%~7` string;
::                    #3: performance counters can have encoded symbols, for reference see `@typeperf` & `@typeperf_devs` macros;
::                    #4: to allow indexes of enabled/disabled devices in `5:%~6` it counts device indexes starting from `1`;
::                    #5: macro encodes control symbols inside output strings `1:%~2` & `3:%~4` with prefix `#` and suffix `;`.
::          Dependencies: @echo_params, @cptooem, @chcp_file, @oemtocp, @perf_counter, @str_arrange, @str_clean,
::                        @str_decode, @str_encode, @substr_extract, @syms_replace, @typeperf_devs, @unset_alev.
::
set @netdevs=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_nwd_a for /F %%y in ('echo.wds_nwd_') do if defined %%yt (^
  set "%%y5=typeperf_devs,chcp_file,perf_counter,substr_extract"^&^
  (for /F "tokens=*" %%a in ('^^^!%%y3^^^!"^!@unset_alev^! 1:^!%%y5^!,str_arrange,str_encode,str_decode,echo_params,str_clean,oemtocp,cptooem,syms_replace 2:%%y 3:ProgramFiles 5:1 6:1"') do (set %%a))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo.%%%%ya%%') do (^
   set "%%~a=1"^&(if not "^!%%~a^!"=="1" (echo Error [@netdevs]: Incorrect variable name `%%~a`.^&exit /b 1))^&^
   (for /L %%m in (1,1,8) do (set "%%yn%%m="))^&(for %%m in ("n0=%%~a","vr=1","n=\","i=\","d=\","s=","x=1","e=0") do (set "%%y%%~m"))^&^
   (for %%m in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l) do if not "%%m"=="" (^
    set "%%ya=%%m"^&set "%%yt=^!%%ya:~2^!"^&^
    (if defined %%yt (set /a "n=0x^!%%ya:~0,1^!"^>NUL 2^>^&1) ^&^& (^
     (if ^^^!n^^^! LSS 9 (^
      set "%%yn^!n^!=^!%%yt^!"^
     ) else if ^^^!n^^^! EQU 9 (^
      set /a "%%ys=^!%%yt^!"^>NUL 2^>^&1^
     ) else if "^!%%yt^!"=="1" (if ^^^!n^^^! EQU 10 (set "%%yx=") else if ^^^!n^^^! EQU 11 (set "%%ye=1")))^
    ))^
   ))^&^
   set "%%ya="^
  ))^&(if defined %%ya (echo Error [@netdevs]: Absent parameters.^&exit /b 1))^&(echo "%%ye=^!%%ye^!")^&(set %%yb="^^^|")^&^
  (for /F "tokens=*" %%a in ('echo "^!ProgramFiles^!\wait.mds"') do for %%b in (%%a) do (set %%yf="%%~b\wait.mds.auxiliary.file.id002"))^&^
  set "a=[Network Interface](*)\["^&(set v="^!a^!Current Bandwidth]")^&(set w="^!a^!Bytes Total/sec]")^&^
  (if exist ^^^!%%yf^^^! for /F "usebackq eol=; tokens=1,* delims==" %%a in (^^^!%%yf^^^!) do if "%%~a"==^^^!v^^^! (^
   set "a=%%b"^&(if defined %%yn8 (set "%%yo8=%%b"))^
  ) else if "%%~a"==^^^!w^^^! (^
   set "a=%%b"^&(if defined %%yn7 (set "%%yo7=%%b"))^
  ))^&^
  (if defined %%yn7 if defined %%yn8 (^
   if defined %%yo7 if defined %%yo8 (set "q=^!%%yo8^!") else (set "q=^!v^!") else (set "q=^!w^!")^
  ) else (^
   if defined %%yo7 (set "q=^!%%yo7^!") else (set "q=^!w^!")^
  ) else if defined %%yn8 (^
   if defined %%yo8 (set "q=^!%%yo8^!") else (set "q=^!v^!")^
  ) else (^
   if defined a (set "q=^!a^!") else (set "q=^!v^!")^
  ))^&^
  set "c=0"^&set "a="^&set "b=^!q^!"^&^
  (for /F "tokens=*" %%a in ('^^^!%%y3^^^!"^!@typeperf_devs^! b Stub 3:1"') do if defined a (^
   set "d=%%~a"^&(for %%b in ("#3D;==","#3F;=?","#2A;=*") do (set "d=^!d:%%~b^!"))^&^
   (for /F %%b in ('^^^!%%y3^^^!"^!@str_clean^! d 287 1"') do (set %%b))^&^
   set /a "c-=1"^>NUL^&(set %%yi=^^^!%%yi^^^!"^!c^!"\)^&(set %%yd=^^^!%%yd^^^!"^!d^!"\)^&set "%%yn=^!%%yn^!%%a\"^
  ) else (^
   set %%a^&set "a=^!b^!"^
  ))^&^
  (for %%a in (^^^!%%y5^^^!) do (set "@%%a="))^&set "y=^!c:~1^!"^&set "z=^!y^!"^&call set "e=%%%%yb:~0,1%%"^&^
  (if not "^!q^!"=="^!a^!" (^
   (if exist ^^^!%%yf^^^! (^
    set "b="^&^
    (for /F "tokens=2" %%a in ('^^^!%%y3^^^!"attrib ^!%%yf^! %%%%yb:~-2,1%% findstr /C:^!e^! SH ^!e^!"') do (set "b=0"))^&^
    (if defined b (^
     (set b="^!%%yf:~1,-1^!.bak")^&^
     ((for /F "usebackq eol=; tokens=1,* delims==" %%a in (^^^!%%yf^^^!) do if not "%%~a"=="%%~b" (echo %%a=%%b))^&^
      (echo ^^^!q^^^!=^^^!a^^^!)^
     )^>^^^!b^^^!^&^
     (if exist ^^^!b^^^! (call move /y ^^^!b^^^! ^^^!%%yf^^^!))^>NUL 2^>^&1^
    ))^
   ) else (echo ^^^!q^^^!=^^^!a^^^!)^>^>^^^!%%yf^^^!)^&^
   (if defined %%yn7 if defined %%yo7 (set "%%yo8=^!a^!") else (set "%%yo7=^!a^!") else (set "%%yo8=^!a^!"))^&^
   (if exist ^^^!%%yf^^^! (attrib +h +s -r ^^^!%%yf^^^!))^>NUL 2^>^&1^
  ))^&^
  (for /L %%a in (0,1,8) do if defined %%yn%%a if %%a LSS 7 (^
   set "%%yo%%a=^!%%yi^!"^
  ) else if defined %%yo%%a (echo "^!%%yn%%a^!=^!%%yo%%a^!") else (echo "^!%%yn%%a^!="))^&^
  (for /F "tokens=2 delims=[" %%a in ('ver') do for /F "tokens=2,3 delims=. " %%b in ('echo %%a') do if %%b%%c EQU 51 (set "w=1"))^&^
  set "n=0"^&^
  (for /F "tokens=*" %%a in ('echo.": =~"') do for /F "tokens=1,* delims=:" %%b in ('"ipconfig /all%%%%y4:~-2,1%%echo.."') do for /F %%d in ('echo.%%~b') do (^
   set "a=%%~b:%%~c"^&^
   (for /F "tokens=1,2 delims=~" %%e in ('"echo.^!a:%%~a^!"') do (^
    set "a=%%~e"^&^
    (if "^!a:~0,3^!"=="   " (if 1 LSS ^^^!n^^^! (^
     set "b="^&^
     (if ^^^!c^^^! LSS 0 (^
      if "^!a:DNS=^!"=="^!a^!" (set "vr=1"^&set "c=0") else (set "vr=0"^&set "v0=%%~f"^&set "c=1")^
     ) else if ^^^!c^^^! EQU 0 (^
      (if "^!a:DNS=^!"=="^!a^!" (set "b=1") else (set "v0=%%~f"))^&set "c=1"^
     ) else (set "b=1"))^&^
     (if defined b if ^^^!c^^^! EQU 1 (set "v1=%%~f"^&set "c=2"^
     ) else if ^^^!c^^^! EQU 2 (set "v2=%%~f"^&set "c=3"^
     ) else (^
      (for /F "tokens=1,*" %%g in ('"echo. . ^!a^!"') do (set "a=%%h"))^&^
      (if ^^^!vr^^^! EQU 1 (set "b=%%~f") else (^
       (if "%%~f"=="" (^
        if ^^^!c^^^! EQU 9 (set "b=^!a^!"^&set "a=DNS?")^
       ) else for /F "delims=( " %%g in ('echo.%%~f') do (set "b=%%g"))^&^
       (for /F "tokens=1,2,3,4 delims=." %%g in ('echo.^^^!b^^^!') do if "^!b^!"=="%%g.%%h.%%i.%%j" (^
        for /F "delims=0123456789" %%k in ('echo.%%g%%h%%i%%j~') do if "%%~k"=="~" (set "i=1") else (set "i=")^
       ) else (set "i="))^
      ))^&^
      set "d=1"^&^
      (if not defined i if ^^^!c^^^! LEQ 4 (^
       (if ^^^!c^^^! EQU 3 (if not "^!a:DHCP =^!"=="^!a^!" (set "d=")) else (set "d="))^&^
       (if not defined d (set /a "c+=1"^>NUL))^
      ))^&^
      (if defined d if ^^^!vr^^^! EQU 0 (^
       (if defined i (if "IP^!a:~2^!"=="^!a^!" (set "v5=^!b^!")) else (if not "^!a:Ipv6=^!"=="^!a^!" (set "vB=^!b^!")))^&^
       set /a "c+=1"^>NUL^
      ))^
     ))^
    )) else (^
     (if ^^^!vr^^^! EQU 0 (^
      set "s=^!v1^!"^&(for /F %%g in ('^^^!%%y3^^^!"^!@str_clean^! s 287 1 ^!w^!"') do (set %%g))^&^
      set "a=^!%%yi:~0,-1^!^!%%yd:~0,-1^!^!%%yn^!"^&(for %%g in (i,d,n) do (set "%%y%%g=\"))^&^
      (for /F "tokens=1,2,3 delims=\" %%g in ('^^^!%%y3^^^!"^!@str_arrange^! C:3 R:^!z^! D:\ E:0 a"') do if %%h=="^!s^!" (^
       set /a "z-=1"^>NUL^&set "vn=%%~g"^&set "vn=^!vn:~1^!"^&set "v0=%%~i"^&^
       (for %%j in (0~0,1~1,2~5,3~B,4~2,5~n) do for /F "tokens=1,2 delims=~" %%k in ('echo.%%j') do if defined %%yn%%k (^
        (if %%k EQU 1 (^
         (if defined w for /F "tokens=*" %%m in ('^^^!%%y3^^^!"^!@oemtocp^! v1 v1 1"') do (set %%m))^&set "c=1"^
        ) else if %%k EQU 3 (set "c=1"))^&^
        (if defined c for /F "tokens=*" %%m in ('^^^!%%y3^^^!"^!@str_encode^! v%%l 3 ^!e^!#^!e^! ^!e^!;^!e^! 1"') do (set %%m))^&^
        (call set %%yo%%k=%%%%yo%%k:\%%g\=\"^!v%%l^!"\%%)^
       ))^
      ) else (^
       set "%%yi=^!%%yi^!%%g\"^&set "%%yd=^!%%yd^!%%h\"^&set "%%yn=^!%%yn^!%%i\"^
      ))^
     ))^&^
     set "c=-1"^&set /a "n+=1"^>NUL^&set "vr=1"^&(for %%g in (B,5,2,1,0) do (set "v%%g="))^
    ))^
   ))^
  ))^&^
  (for /L %%a in (0,1,5) do if defined %%yn%%a (^
   set "a="^&(if %%a LSS 5 (set "a=1") else if defined %%yx (set "a=1"))^&^
   (if defined a for /L %%b in (-1,-1,-^^^!y^^^!) do (set %%yo%%a=^^^!%%yo%%a:\"%%b"\=\^^^!))^&^
   (set %%yo%%a=^^^!%%yo%%a:"\"=","^^^!)^&^
   (if %%a EQU 5 if defined %%ys (^
    set "a=^!%%yo5:~1,-1^!"^&set "%%yo5=,"^&^
    (for %%b in (^^^!a^^^!) do (^
     set "b=%%~b"^&(if ^^^!b^^^! LSS 0 (set /a "b-=^!%%ys^!") else (set /a "b+=^!%%ys^!"))^&set "%%yo5=^!%%yo5^!^!b^!,"^
    )^>NUL 2^>^&1)^
   ) else (call set "%%yo5=%%%%yo5:^!e^!=%%"))^&^
   (echo "^!%%yn%%a^!=^!%%yo%%a:~1,-1^!")^
  ))^&^
  (if defined %%yn6 (set /a "y-=^!z^!"^>NUL^&echo "^!%%yn6^!=^!y^!"))^
 ) else (^
  set "%%yt=1"^&(if not "^!%%yt^!"=="1" (echo Error [@netdevs]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  (for /F %%a in ('echo."%%"') do (^
   (set %%yt="set %%y5=@netdevs%%~a%%y4:~-2,1%%~a(for /F %%~a%%y4:~0,1%%~a^^tokens=*%%~a%%y4:~0,1%%~a %%~ap in ('%%~a%%y3%%~a%%~a%%y4:~0,1%%~a%%~a%%~a%%y5%%~a%%~a^!%%ya^!%%~a%%y4:~0,1%%~a') do (echo %%~ap))")^&^
   set "%%ya="^&set "%%y3=cmd /d /q /e:on /v:on /r "^&(set %%y4="^^^&")^&^
   (for /F "tokens=*" %%b in ('start /b /i /ABOVENORMAL %%%%y3%%%%%%yt%%') do (^
    set "%%yt=%%b"^&^
    (if "^!%%yt:error [=^!"=="^!%%yt^!" (^
     if defined %%ye (if ^^^!%%ye^^^! NEQ 1 (set %%b) else (echo %%b)) else (set %%b)^
    ) else (echo %%b^&exit /b 1))^
   ))^
  ))^&(for %%a in (3,4,e,t) do (set "%%y%%a="))^
 ) else (echo Error [@netdevs]: Absent parameters.^&exit /b 1)) else set wds_nwd_a=

::          @res_select - executes specified task and selects the elements of its result matching a logical expression.
::            Precaution: macro uses semicolon symbol (`;`) as delimiter between parameters;
::                        %~1 == the logical expression to do selection of result strings, may include:
::                               1. the name(s) or subname(s) of searched item(s) (tokens or operands);
::                               2. logical binary operators `OR` & `AND` (`AND` has higher priority than `OR`);
::                               3. the asterisk symbol in the token means that the substring may be arbitrary (s.a. 5:%~8);
::                               4. the negation prefix symbol `~` is to check there are no items exist matching the operand;
::                        %~2 == the command to call inside macro, for example: "tasklist /v /fo:csv | findstr /v /c:SkipMe":
::                               1. it's recommended to avoid controls in the command;
::                               2. macro can handle quote `"` and bar `|` symbols;
::                               3. it process bar `|` separately, that is the left side is treated as command, the right side
::                                  with arbitrary number of "barred items" is used to restrict output.
::                        %~3 == the string to extract item substring from result string, for example: "tokens=1 delims=.";
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~4 == the name of variable to return all matched result items as one string (without internal quotes);
::                      2:%~5 == the name of variable to return total number of matched items in selected result;
::                      3:%~6 == the name of variable to return internal result of the raw query `%~2` before selection:
::                               `0` - query reported result;
::                               `1` - query reported result but some of strings were empty;
::                               `2` - it didn't report anything for selection by `%~1`;
::                      4:%~7 == key value `1` to encode & decode to avoid failure because of control symbols, default is `0`;
::                      5:%~8 == digital value or defined variable name with digital value
::                               - the input value `1` indicates that expression `%~1` uses `++` as wildcard `*` (that is, don't
::                                 spend time on replacing `*`), default is `0`;
::                               - the output value is always `1` to inform calling context that the `%~1` was modified;
::                      6:%~9 == the substring number in the selection string to check (negative from end, CSV format of "for");
::                      7:%~10== the substring number in the selection string to report (negative from end, CSV format of "for");
::                      8:%~11== the name of variable to assign time spent (msec);
::                      9:%~12== key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: parameters `%~1`, `%~2`, `%~3` & `5:%~8` can be (quoted) string values or variable names with values;
::                    #2: logical expression to select result:
::                     #2.1: the total number of tokens & binary operators in logical expression can not exceed 15;
::                     #2.2: the total count of tokens & binary operators in logical expression is always odd number;
::                     #2.3: if the operand string of the expression `%~1` has unmanageable controls, use `*` to skip them. The 
::                           whitespace symbols of operand can be replaced by `/CHR{20}` (they are treated as `*` wildcards);
::                     #2.4: if the token of expression `%~1` has controls conflicting with CSV format, substitute variable name
::                           `[VarNameWithToken]` - but avoid it and use only literal token items without space symbols ` `;
::                     #2.5: any token can have only one negation character `~` and it applies to all elements of the token, it 
::                           can be specified only inside its string (it will be ignored if it is the last symbol).
::                           Example: *~cmd*exe* - drop all strings with `cmd` & `exe` substrings;
::                     #2.6: every operand may have as much as 9 items between wildcards `*`;
::                     #2.7: the macro expands all literal items of operands and applies them to restrict initial selection set,
::                           i.e.: `<command %%~2> | findstr /I /C:"item1" /C:"item2"` ... ` /C:"item_last_found"`;
::                           It doesn't apply for operands with negation symbol `~`;
::                    #3: if parameters `%~1` & `5:%~8` are variable names, it modifies wildcards of expression & `5:%~8` value;
::                    #4: subselection of one of result items with `6:%~9`:
::                     #4.1: all output strings of the specified query must have same number of subitems;
::                     #4.2: the format of query result must be "for"-readable, e.g CSV: "subitem1","subitem2";
::                     #4.3: `7:%~10` is valuable only in the case of `6:%~9` defined, otherwise ignored;
::                     #4.4: if the raw query `%~2` returns result as a quoted CSV string then it clears all internal quotes to
::                           avoid interference, e.g CSV: "sub"item"1",""sub"item2" -> "subitem1","subitem2";
::                    #5: for proper work with @mac_wrapper, it is recommended to use escapes `^` inside `%~3` before symbols `=`;
::                    #6: the job with enabled `4:%~7` can proceed slowly, it's recommended to use this option only then it's 
::                        necessary & to use command expression `%~2` to restrict data set for processing with encoding.
::    Expression samples: #1. "NOTEP*.exe"; #2: "*EPAD"; #3: "~NOTE* and *PAD"; #4: "NOTE* or ~[VarNameWithToken2] and *PAD".
::          Dependencies: @echo_params, @str_arrange, @str_decode, @str_encode, @sym_replace, @syms_replace, @time_span.
::
set @res_select=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_trs_a for /F %%y in ('echo wds_trs_') do if defined %%y0 (^
  (for /F "tokens=*" %%a in ('%%%%y0%%"^!@unset_mac^![],time_span,str_arrange,str_decode,echo_params,str_encode,sym_replace,syms_replace"') do (set %%a))^&^
  set "%%ytsv=^!time: =0^!"^&(for %%a in (rsn,rnn,rqn,iwn,tsn,inu,onu,d) do (set "%%y%%a="))^&^
  (if not "^!%%ytsv:~2,1^!"==":" (echo Error [@res_select]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  (for /F "tokens=1,2,3,* delims=;" %%a in ('echo.%%%%ya%%') do (^
   (if "%%~c"=="" (echo Error [@res_select]: Parameter #3 is absent.^&exit /b 1))^&^
   (for /F "tokens=*" %%e in ('echo %%~a') do if defined %%~e (^
    set "%%ylen=%%~e"^&(for /F "tokens=*" %%f in ('echo %%%%~e%%') do (set "%%yx=%%~f"))^
   ) else (set "%%yx=%%~e"))^&^
   (for /F "tokens=*" %%e in ('echo %%~b') do if defined %%~e (^
    (for /F "tokens=*" %%f in ('echo %%%%~e%%') do (set "%%yc=%%~f"))^
   ) else (set "%%yc=%%~e"))^&^
   (for /F "tokens=*" %%e in ('echo %%~c') do if defined %%~e (^
    (for /F "tokens=*" %%f in ('echo %%%%~e%%') do (set "%%yf=%%~f"))^
   ) else (set "%%yf=%%~e"))^&^
   (for %%e in (%%d) do (^
    set "%%ya=%%~e"^&set "%%yq=^!%%ya:~2^!"^&^
    (if defined %%yq (^
     set "%%ya=^!%%ya:~0,1^!"^&^
           (if ^^^!%%ya^^^! EQU 1 (set "%%yrsn=^!%%yq^!"^
     ) else if ^^^!%%ya^^^! EQU 2 (set "%%yrnn=^!%%yq^!"^
     ) else if ^^^!%%ya^^^! EQU 3 (set "%%yrqn=^!%%yq^!"^
     ) else if ^^^!%%ya^^^! EQU 4 ((set /a "%%yedc=0x^!%%yq^!"^>NUL 2^>^&1)^>NUL^
     ) else if ^^^!%%ya^^^! EQU 5 (^
      set "%%yiwn=^!%%yq^!"^&^
      (if defined %%yiwn (^
       (call set /a "%%yiwc=0x%%^!%%yq^!%%"^>NUL 2^>^&1)^>NUL^&(if not defined %%yiwc (set "%%yiwc=0"))^
      ) else (^
       set "%%yiwn="^&(call set /a "%%yiwc=0x%%%%yq%%"^>NUL 2^>^&1)^>NUL^
      ))^
     ) else if ^^^!%%ya^^^! EQU 8 (set "%%ytsn=^!%%yq^!"^
     ) else if ^^^!%%ya^^^! EQU 9 ((set /a "%%yec=0x^!%%yq^!"^>NUL 2^>^&1)^>NUL^
     ) else (^
      (for %%f in ("6 inu","7 onu") do for /F "tokens=1,2" %%g in ('echo %%~f') do if ^^^!%%ya^^^! EQU %%g (^
       (for /F "tokens=* delims=+,-,0" %%i in ('echo %%%%yq%%') do (^
        (set /a "%%y%%h=%%i"^>NUL 2^>^&1^>NUL) ^&^& (^
         if "^!%%y%%h^!"=="%%i" (if "^!%%yq:~0,1^!"=="-" (set "%%y%%h=-%%i")) else (set "%%y%%h=")^
        ) ^|^| (set "%%y%%h=")^
       ))^
      ))^
     ))^
    ))^
   ))^&^
   (for %%e in (edc,iwc,ec) do if not "^!%%y%%~e^!"=="0" if not "^!%%y%%~e^!"=="1" (set "%%y%%e=0"))^&^
   (if ^^^!%%yedc^^^! NEQ 0 (set "%%yedc=2"))^
  ))^&^
  (set "%%ysc=;")^&(set %%yq="")^&(call set "%%yq=%%%%yq:~1%%")^&call set "%%yx=%%%%yx:^!%%yq^!=%%"^&set "%%yx=^!%%yx: =,^!"^&^
  set "%%ya=andor"^&set "%%yb=^!%%yx^!"^&set "%%yx="^&set "%%yrnv=1"^&^
  set "%%yb=^!%%yb:/CHR{20}=*^!"^&^
  (for /F "tokens=1,2,3 delims=," %%i in ('%%%%y0%%"^!@str_arrange^! C:3 R:15 D:, E:^!%%yedc^! 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,T,O,T,O,T,O,T,O,T,O,T,O,T,O,T,%%%%yb%%"') do (^
   set "%%yex%%i=%%k"^&^
   (if defined %%yex%%i (^
    (if "%%j"=="O" (^
     set "%%yb=^!%%ya:%%k=^!"^&(if "^!%%yb^!"=="^!%%ya^!" (echo Error [@res_select]: Expected `AND` or `OR` in even position of expression.^&exit /b 1))^&^
     (if "^!%%yb^!"=="or" (^
      set "%%yx=^!%%yx^!-"^&^
      (if defined %%yiwn if defined %%ylen (set "%%yv=^!%%yv^! AND "))^
     ) else (^
      set "%%yx=^!%%yx^!,"^&^
      (if defined %%yiwn if defined %%ylen (set "%%yv=^!%%yv^! OR "))^
     ))^
    ) else (^
     (for /F "tokens=1,2 delims=~" %%l in ('echo %%%%yex%%i%%') do if "%%m"=="" (^
      set "%%ynt%%i=0"^&^
      (for /F "tokens=1,2,3,4,5,6,7,8,9 delims=*" %%n in ('echo %%l') do for %%x in (%%n %%o %%p %%q %%r %%s %%t %%u %%v) do (^
       (if defined %%yd (set %%yd=^^^!%%yd^^^! /C:"%%x") else (set %%yd=/C:"%%x"))^
      ))^
     ) else (^
      set "%%yex%%i=%%l%%m"^&set "%%ynt%%i=1"^
     ))^&^
     (if "^!%%yex%%i:~0,1^!^!%%yex%%i:~-1,1^!"=="[]" (^
      set "%%yex%%i=^!%%yex%%i:~1,-1^!"^&^
      (if defined ^^^!%%yex%%i^^^! (call set %%yex%%i=%%^^^!%%yex%%i^^^!%%) else (set "%%ynt%%i=1"^&set "%%yex%%i=*"))^
     ))^&^
     (if ^^^!%%yiwc^^^! EQU 0 (^
      ((for /F "tokens=*" %%a in ('%%%%y0%%"^!@sym_replace^! %%yex%%i * ++ 1"') do (set %%a))^>NUL 2^>^&1)^&^
      (if not defined %%yex%%i (^
       set "%%ynt%%i=1"^&set "%%yex%%i=++"^
      ))^
     ))^&^
     (if defined %%yiwn if defined %%ylen (^
      (if defined %%yv (set "%%yv=^!%%yv^!^!%%yex%%i^!") else (set "%%yv=^!%%yex%%i^!"))^
     ))^&^
     (if defined %%yx (set "%%yx=^!%%yx^!%%i") else (set "%%yx=%%i"))^
    ))^&^
    set "%%yrnv=%%i"^
   ))^
  ))^&^
  set /a "%%ya=^!%%yrnv^!/2"^>NUL^&set /a "%%ya=^!%%ya^!*2"^>NUL^&^
  (if ^^^!%%ya^^^! EQU ^^^!%%yrnv^^^! (echo Error [@res_select]: Unexpected end of logical expression.^&exit /b 1))^&^
  (if ^^^!%%yedc^^^! EQU 0 (set "%%yedc="))^&^
  (if defined %%yd (set "%%yc=^!%%yc^! %%%%yb:~-2,1%% findstr /I ^!%%yd^!"))^&^
  set %%yc="for /F %%%%yq%%usebackq ^!%%yf^!%%%%yq%% %%^^z in (`%%%%yq%%^!%%yc^!%%%%yq%%`) do (%%%%yd:~-2,1%%nul set /p %%%%yq%%=%%^^z%%%%yq%%%%%%ya:~-2,1%%echo.)"^&^
  (set %%ya="^^^&")^&(set %%yb="^^^|")^&(set %%yd="^^^<")^&set "%%yrnv=0"^&set "%%yrqv=2"^&^
  (for /F "tokens=*" %%a in ('%%%%y0%%%%%%yc%%') do (^
   set "%%yb=%%a"^&^
   (if defined %%yedc for /F "tokens=*" %%b in ('%%%%y0%%"^!@str_encode^! %%yb 2 %%%%yq%%#%%%%yq%% %%%%yq%%%%%%ysc%%%%%%yq%% 1"') do (set %%b))^&^
   (if defined %%yinu (^
    (for /F %%b in ('echo ","') do if not "^!%%yb:%%b=^!"=="^!%%yb^!" (^
     set "%%yb=^!%%yb:%%b=#[X]^!"^&call set "%%yb=%%%%yb:^!%%yq^!=%%"^&set %%yb="^!%%yb:#[X]=%%b^!"^
    ))^&^
    (if ^^^!%%yinu^^^! LSS 0 (^
     set "%%ya=0"^&(for %%b in (^^^!%%yb^^^!) do (set /a "%%ya+=1"^>NUL))^&set /a "%%yinu+=1+^!%%ya^!"^>NUL^&^
     (if defined %%yonu if ^^^!%%yonu^^^! LSS 0 (set /a "%%yonu+=1+^!%%ya^!"^>NUL))^
    ))^&^
    set "%%ya=0"^&set "%%yc=1"^&set "%%ys="^&set "%%yrse="^&^
    (for %%b in (^^^!%%yb^^^!) do if defined %%yc (^
     set /a "%%ya+=1"^>NUL^&(if ^^^!%%ya^^^! EQU ^^^!%%yinu^^^! (set "%%ys=%%~b"))^&^
     (if defined %%yonu if ^^^!%%ya^^^! EQU ^^^!%%yonu^^^! (set "%%yrse=%%~b"))^&^
     (if defined %%ys if defined %%yonu (if defined %%yrse (set "%%yc=")) else (set "%%yc="))^
    ))^
   ) else (set "%%ys=^!%%yb^!"))^&^
   (if defined %%ys (^
    (if ^^^!%%yrqv^^^! EQU 2 (set "%%yrqv=0"))^&^
    set "%%yd=0"^&^
    (for %%b in (^^^!%%yx^^^!) do if ^^^!%%yd^^^! EQU 0 (^
     set "%%yc=%%b"^&set "%%yc=^!%%yc:-=,^!"^&set "%%yd=1"^&^
     (for %%c in (^^^!%%yc^^^!) do if ^^^!%%yd^^^! EQU 1 (^
      set "%%yf=^!%%ys^!"^&call set %%yc="%%%%yex%%c:++=","%%"^&set "%%yb="^&^
      (for %%d in (^^^!%%yc^^^!) do if defined %%yf if ^^^!%%yd^^^! EQU 1 (^
       (if "%%~d"=="" (set "%%yb=*") else (^
        (if defined %%yb (call set "%%yb=%%%%yf:^!%%yb^!%%~d=%%") else (call set "%%yb=%%%%yf:%%~d=%%"))^&^
        (if "^!%%yf^!"=="^!%%yb^!" (set "%%yd=0") else (^
         (if defined %%yb (set "%%yf=^!%%yb^!") else (set "%%yf="))^&^
         set "%%yb="^
        ))^
       ))^
      ))^&^
      (if ^^^!%%yd^^^! EQU 1 if not defined %%yb if defined %%yf (set "%%yd=0"))^&^
      (if ^^^!%%ynt%%c^^^! EQU 1 (set /a "%%yd^^=1"^>NUL))^
     ))^
    ))^&^
    (if ^^^!%%yd^^^! NEQ 0 (^
     (if defined %%yrsn (^
      (if defined %%yonu (set "%%yc=^!%%yrse^!") else (set "%%yc=%%~a"))^&^
      call set "%%yc=%%%%yc:^!%%yq^!=%%"^&^
      (if defined %%yb for /F "tokens=*" %%c in ('%%%%y0%%"^!@str_decode^! %%yc "" "" 1"') do (set %%c))^&^
      (if defined %%yrsv (set %%yrsv=^^^!%%yrsv^^^!,"^!%%yc^!") else (set %%yrsv="^!%%yc^!"))^
     ))^&^
     (if defined %%yrnn (set /a "%%yrnv+=1"^>NUL))^
    ))^
   ) else if ^^^!%%yrqv^^^! EQU 0 (set "%%yrqv=1"))^
  ))^>NUL 2^>^&1^&^
  (if ^^^!%%yec^^^! EQU 1 (echo "%%yec=1"))^&^
  (if defined %%yiwn if defined %%ylen (echo "^!%%ylen^!=^!%%yv^!"^&echo "^!%%yiwn^!=1"))^&^
  (if defined %%yrsn if defined %%yrsv (echo "^!%%yrsn^!=^!%%yrsv^!") else (echo "^!%%yrsn^!="))^&^
  (if defined %%yrnn (echo "^!%%yrnn^!=^!%%yrnv^!"))^&^
  (if defined %%yrqn (echo "^!%%yrqn^!=^!%%yrqv^!"))^&^
  (if defined %%ytsn (^
   (for /F "tokens=*" %%b in ('cmd /d /q /e:on /v:on /r "^!@time_span^! B:%%ytsv 5:%%ytsv 6:%%ya 9:1"') do (set %%b))^&^
   set /a "%%ytsv+=^!%%ya^!/5"^>NUL^&^
   echo "^!%%ytsn^!=^!%%ytsv^!"^
  ))^
 ) else (^
  set "%%y0=cmd /d /q /e:on /v:on /r "^&call set "%%y1=%%%%ya%%"^&set "%%ya="^&^
  (for /F "tokens=*" %%a in ('%%%%y0%%"^!@res_select^! %%%%y1%%"') do (^
   (for /F %%b in ('echo.%%a') do if "%%~b"=="Error" (echo %%a^&exit /b 1))^&^
   (if defined %%yec (echo %%a) else (set %%a))^
  ))^&^
  (if not defined %%yec (set "%%y0="^&set "%%y1="))^
 ) else (echo Error [@res_select]: Absent parameters.^&exit /b 1)) else set wds_trs_a=

:::      @events_reader - auxiliary macro for internal use by macro @event_file exclusively.
:::
set @events_reader=^
 (for /F %%y in ('echo wds_evf_') do if defined %%yf if defined %%yt if defined %%y3 if defined %%yq (^
  (if ^^^!%%y3^^^! NEQ 0 (^
   ((for /F "tokens=*" %%a in ('%%%%y0%%"^!@obj_attrib^! %%yaux %%yf r 1:1 3:1"') do (set %%a))^>NUL 2^>^&1)^&^
   (if ^^^!errorlevel^^^! EQU 1 (set "%%yaux=1"))^&(if ^^^!%%yaux^^^! EQU 1 (echo "%%yrrv=5"^&exit /b 1))^&^
   (if ^^^!%%y3^^^! EQU 1 (^
    (if defined %%yntp (set %%ycmp="^!%%yntp^!^!%%ytpv^!") else (set %%ycmp="^!%%ytpv^!"))^&^
    (if ^^^!%%yibd^^^! NEQ 0 (set "%%yaux=prv tov") else (set "%%yaux=prv tov bdv"))^&^
    (for %%c in (^^^!%%yaux^^^!) do if defined %%y%%c (set %%ycmp=^^^!%%ycmp^^^!,"^!%%y%%c^!"))^
   ))^&^
   echo "%%yeiv="^
  ) else (set "%%yrrv=0"))^&^
  (for %%a in ("cnt=0","blk=0","str=""","stl=0") do (set "%%y%%~a"))^&^
  (for /F "usebackq eol=; tokens=*" %%a in (^^^!%%yf^^^!) do if ^^^!%%yrrv^^^! EQU 0 (^
   set "%%yrow=%%a"^&^
   (if defined %%yrow (^
    set "%%ylen=0"^&^
    (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     set "%%ytmp=^!%%yrow:~%%b,1^!"^&(if defined %%ytmp (set "%%yrow=^!%%yrow:~%%b^!"^&set /a "%%ylen+=%%b"^>NUL))^
    ))^&^
    set "%%yrow=%%a"^&^
    (for /L %%b in (0,1,^^^!%%ylen^^^!) do (^
     set "%%ysym=^!%%yrow:~%%b,1^!"^&^
     (if ^^^!%%yblk^^^! EQU 0 (^
      if "^!%%ysym^!"=="{" for %%b in ("blk=1","fdn=0","fdv=0","eid=","etp=","epr=","eto=","bto=","com= ") do (set "%%y%%~b")^
     ) else (^
      (if "^!%%ysym^!"=="^!%%yq^!" (^
       (if ^^^!%%yfdn^^^! EQU 3 (^
        (if ^^^!%%yfdv^^^! EQU 0 (^
         set "%%yfdv=1"^&set "%%yfvq=0"^&set %%ystr=""^&set "%%ystl=0"^&set "%%ysym="^
        ) else (set "%%yfdv=2"^&set "%%yfvq=^!%%ystl^!"))^
       ) else (^
        (if ^^^!%%yfdn^^^! EQU 0 (^
         set "%%yfdn=1"^&set "%%yfnq=0"^&set %%ystr=""^&set "%%ystl=0"^&set "%%ysym="^
        ) else (set "%%yfdn=2"^&set "%%yfnq=^!%%ystl^!"))^
       ))^
      ) else if "^!%%ysym^!"==":" (^
       if ^^^!%%yfdn^^^! EQU 2 (set "%%yfdn=3"^&call set %%yfns="%%%%ystr:~1,^!%%yfnq^!%%"^&set "%%ysym=")^
      ) else if "^!%%ysym^!"=="," (^
       if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 2 (^
        call set %%yfvs="%%%%ystr:~1,^!%%yfvq^!%%"^&set "%%yfdv=3"^&set "%%ysym="^
       )^
      ) else if "^!%%ysym^!"=="}" (^
       (if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 2 (^
        call set %%yfvs="%%%%ystr:~1,^!%%yfvq^!%%"^&set "%%yfdv=3"^&set "%%ysym="^
       ))^&^
       (if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 3 (set "%%yblk=2"))^
      ) else if not "^!%%ysym^!"==" " (^
       (if ^^^!%%yfdn^^^! EQU 2 (set "%%yfdn=1"))^&(if ^^^!%%yfdv^^^! EQU 2 (set "%%yfdv=1"))^
      ))^&^
      (if defined %%ysym (set %%ystr="^!%%ystr:~1,-1^!^!%%ysym^!"^&set /a "%%ystl+=1"^>NUL))^&^
      (if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 3 (^
       set "%%yfdn=0"^&set "%%yfns=^!%%yfns:~1,-1^!"^&set "%%yfdv=0"^&set "%%yfvs=^!%%yfvs:~1,-1^!"^&^
       (if not defined %%yeid if "^!%%yfns:id=^!"=="" (set "%%yeid=^!%%yfvs^!"))^&^
       (if not defined %%yetp if "^!%%yfns:type=^!"=="" (set "%%yetp=^!%%yfvs^!"))^&^
       (if not defined %%yepr if "^!%%yfns:predicate=^!"=="" (set "%%yepr=^!%%yfvs^!"^&set "%%ycom=,^!%%ycom^!"))^&^
       (if not defined %%yeto if "^!%%yfns:timeout=^!"=="" (set "%%yeto=^!%%yfvs^!"^&set "%%ycom=,^!%%ycom^!"))^&^
       (if not defined %%ybto if "^!%%yfns:begindate=^!"=="" (set "%%ybto=^!%%yfvs^!"^&set "%%ycom=,^!%%ycom^!"))^
      ))^&^
      (if ^^^!%%yblk^^^! EQU 2 (^
       set "%%yblk=0"^&^
       (if defined %%yeid if defined %%yetp (^
        set "%%yneg=^!%%yetp:~0,1^!"^&(if "^!%%yneg^!"=="~" (set "%%yetp=^!%%yetp:~1^!") else (set "%%yneg="))^&^
        (for %%b in (f,a,p,i,c,n,d,v,u,t,h,l,r,w,s,m) do if defined %%yetp if "^!%%yetp:%%b=^!"=="" (^
         (if not defined %%yepr (set "%%yetp="^&(for %%c in (n,d,v,u,t) do if %%b==%%c (set "%%yetp=1"))))^&^
         (if defined %%yneg (if %%b==a (set "%%yetp=")) else if %%b==i (set "%%yetp="))^&^
         (if defined %%yetp (^
          (if defined %%yneg (set "%%yetp=^!%%yneg^!%%b") else (set "%%yetp=%%b"))^&^
          (if defined %%yepr (^
           set "%%yepr=^!%%yepr:/CHR{3F}=?^!"^&set "%%yepr=^!%%yepr:/CHR{2A}=*^!"^&set "%%yepr=^!%%yepr:/CHR{3D}==^!"^
          ))^&^
          (if ^^^!%%y3^^^! EQU 0 (if "^!%%yeid^!"=="^!%%yeiv^!" (^
           (if defined %%yetp if "^!%%yt^!"=="type" ((echo ^^^!%%yetp^^^!)^&exit /b 0))^&^
           (if defined %%yepr if "^!%%yt^!"=="predicate" ((echo ^^^!%%yepr^^^!)^&exit /b 0))^&^
           (if defined %%yeto if "^!%%yt^!"=="timeout" ((echo ^^^!%%yeto^^^!)^&exit /b 0))^&^
           (if defined %%ybto if "^!%%yt^!"=="begindate" ((echo ^^^!%%ybto^^^!)^&exit /b 0))^
          )) else if ^^^!%%y3^^^! EQU 1 (^
           set /a "%%ycnt+=1"^>NUL^&^
           (if ^^^!%%ycnt^^^! LSS 100 (^
            (set %%ytmp="^!%%yetp^!")^&(if ^^^!%%yibd^^^! NEQ 0 (set "%%yaux=epr eto") else (set "%%yaux=epr eto bto"))^&^
            (for %%c in (^^^!%%yaux^^^!) do if defined %%y%%c (set %%ytmp=^^^!%%ytmp^^^!,"^!%%y%%c^!"))^&^
            (if ^^^!%%ycmp^^^! EQU ^^^!%%ytmp^^^! (^
             (if defined %%yein (echo "%%yeiv=^!%%yeid^!"))^&set "%%yrrv=1"^
            ) else (^
             (if defined %%yfnd (^
              (for /F "tokens=*" %%c in ('echo "^!%%yeid^!"') do if "^!%%yfnd:%%c=^!"=="^!%%yfnd^!" (set "%%yfnd=^!%%yfnd^!,%%c"))^
             ) else (set %%yfnd="^!%%yeid^!"))^
            ))^
           ) else (set "%%yrrv=2"))^
          ) else (^
           if "^!%%yeid^!"=="^!%%yeiv^!" (echo "%%yeiv=^!%%yeid^!") else (^
            set "%%yaux=1"^&set "%%ycom=^!%%ycom:~0,-1^!"^&^
            (echo {^>^>^^^!%%yt^^^!)^&^
            (echo    "id": "^!%%yeid^!",^>^>^^^!%%yt^^^!)^&^
            (if defined %%ycom (^
             (echo    "type": "^!%%yetp^!"^^^!%%ycom:~0,1^^^!^>^>^^^!%%yt^^^!)^
            ) else (^
             (echo    "type": "^!%%yetp^!"^>^>^^^!%%yt^^^!)^
            ))^&^
            (if defined %%yepr (^
             echo    "predicate": "^!%%yepr^!"^^^!%%ycom:~1,1^^^!^>^>^^^!%%yt^^^!^&set /a "%%yaux+=1"^>NUL^
            ))^&^
            (if defined %%yeto (^
             call echo    "timeout": "^!%%yeto^!"%%%%ycom:~^^^!%%yaux^^^!,1%%^>^>^^^!%%yt^^^!^&^
             set /a "%%yaux+=1"^>NUL^
            ))^&^
            (if defined %%ybto (echo    "begindate": "^!%%ybto^!"^>^>^^^!%%yt^^^!))^&^
            (echo }^>^>^^^!%%yt^^^!)^
           )^
          ))^&set "%%yetp="^
         ))^
        ))^
       ))^
      ))^
     ))^
    ))^
   ))^
  ))^&^
  (if ^^^!%%y3^^^! NEQ 0 (^
   ((for /F "tokens=*" %%a in ('%%%%y0%%"^!@obj_attrib^! %%yaux %%yf ~r 1:1 3:1"') do (set %%a))^>NUL 2^>^&1)^&^
   (if ^^^!errorlevel^^^! EQU 1 (set "%%yaux=1"))^&(if ^^^!%%yaux^^^! EQU 1 (echo "%%yrrv=5"^&exit /b 1))^&^
   echo "%%yrrv=^!%%yrrv^!"^&(if ^^^!%%y3^^^! EQU 1 if ^^^!%%yrrv^^^! EQU 0 (echo "%%yfnd=^!%%yfnd^!"))^
  ))^
 ))
 
::          @event_file - adds or removes event from file [special macro for event file of library `wait.mds`].
::                        %~1 == full valid name of file with descriptors of events in JSON format:
::                               `ID`        - identifier of the event (must be unique);
::                               `Type`      - type of event (whithout prefix `/t:`, see description of library);
::                               `Predicate` - item of this event type (without prefix `/i:`, see description of library);
::                               `Timeout`   - optional timeout field for current event in msec;
::                               `BeginDate` - optional begin date to count timeout for event (wmic format `YYYYMMDDHHmmSS`);
::                             - it can be a name of variable containing file name or explicit quoted string without spaces;
::                        %~2 == the key value, defines action of macro call:
::                               `1` OR `add`    OR `a` - add new event to file;
::                               `2` OR `remove` OR `r` - remove event from file;
::                      Group of parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~3 == the identifier of event to remove (required for `%~2` equal to `1`, otherwise ignored);
::                      Required parameters for adding new event to file (also see description of library for valid values):
::                      2:%~4 == the name of variable to return identifier of added event;
::                      3:%~5 == type of event;
::                      4:%~6 == predicate item of event (variable name or explicit value, see notes #4 & #5);
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      5:%~7 == timeout value to set for the new event;
::                      6:%~8 == begin date value for timeout calculation of this peculiar new event (format `YYYYMMDDHHMMSS`);
::                      7:%~9 == key value `1` to set begin date of new event automatically by current date time, default is `0`;
::                      8:%~10== the name of variable to return result of specified task, can return next values:
::                               `0` - specified task completed successfully, success;
::                               `1` - event with specified attributes already exists in the file, failure adding;
::                               `2` - the number of events exceeds the limit value of 100, failure adding;
::                               `3` - event with the specified identifier was not found for deletion, deletion failure;
::                               `4` - event file was not found, (deletion) failure;
::                               `5` - event file has read-only attribute or macro failed to change attributes;
::                               `6` - temporal file exists & locked by some process, failed to proceed;
::                               `7` - invalid name of event file or the path doesn't exist, general failure;
::                      9:%~11== the parameter to specify behaviour if the file is read-only (waiting range [250...86400000]):
::                               `0` - don't wait, exit if blocked;
::                               `>0`- wait specified number of msec, exit if blocked (default value 600000 msec);
::                               `<0`- wait specified number of msec, unblock if read-only;
::                      A:%~12== key to ignore `BeginDate` field while searching events (default value `1`), `0` is to compare them;
::                      B:%~13== key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: macro synchronizes modification of file with event handling by changing read-only attribute;
::                    #2: parameters `6:%~8` & `7:%~9` is valuable only with defined `5:%~7`, otherwise ignored; 
::                    #3: it always encodes predicate of new event to avoid further problems with controls, do not precode it;
::                    #4: encoding skips event predicate delimiters: `?` - separates subitems & embracing apostrophes `'` to denote
::                        explicit string values. To avoid wrong number of subitems preliminary encode all symbols `?`;
::                    #5: it is advised that each item and separator be stored on a separate line in accordance with JSON standard;
::                    #6: the script ignores lines of file with 1st symbol `;`, they can be used only for temporal comments;
::                    #7: during deletion of any event macro rewrites file discarding all invalid event specifications & comments;
::                    #8: the event adding to a nonexistent file creates a new one, removing of sole event of the file deletes it.
::          Dependencies: @date_span, @events_reader, @fixedpath, @fixedpath_parser, @obj_attrib, @spinner, @str_encode, 
::                        @syms_replace, @time_span, @unset_alev. Nominally: @fixedpath_8d3.
::
set @event_file=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_evf_1 (for /F %%y in ('echo wds_evf_') do if defined %%y0 (^
  (for /F "tokens=*" %%a in ('%%%%y0%%"^!@unset_alev^! 1:date_span,events_reader,fixedpath,fixedpath_parser,obj_attrib,spinner,str_encode,syms_replace,time_span 2:%%y 5:1 6:1"') do (set %%a))^&^
  (set %%yq="")^&(call set "%%yq=%%%%yq:~1%%")^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13" %%a in ('echo.%%%%y1%%') do (^
   (for %%n in ("rrv=0","wro=2:600000","ibd=1","4=0","5=Error [@event_file]: ") do (set "%%y%%~n"))^&^
   (call set %%yf="%%%%yf:^!%%yq^!=%%")^&^
   (if not exist ^^^!%%yf^^^! for /F "tokens=*" %%n in ('echo ^^^!%%yf^^^!') do if not exist "%%~dn%%~pn" (^
    (for /F "tokens=*" %%o in ('%%%%y0%%"%%@fixedpath%% %%y2 %%yf 2:%%y2 6:2 7:1 9:1 B:1"') do (set %%o))^&^
    (if not exist ^^^!%%y2^^^! (^
     if defined %%yrrn (set "%%yrrv=7") else (echo ^^^!%%y5^^^!Invalid path to event file.^&exit /b 1)^
    ))^
   ))^&^
   set "@fixedpath="^&set "@fixedpath_parser="^&^
   set "%%y3=%%~b"^&(if defined %%y3 if not "^!%%y3::=^!"=="^!%%y3^!" (set "%%y3="))^&^
   (if defined %%y3 (^
    (for %%n in ("add=1" "remove=2" "a=1" "r=2") do (set "%%y3=^!%%y3:%%~n^!"^>NUL 2^>^&1))^&^
    (if ^^^!%%y3^^^! NEQ 1 if ^^^!%%y3^^^! NEQ 2 (set "%%y3="))^
   ))^&^
   (if not defined %%y3 (echo ^^^!%%y5^^^!Unknown macro action.^&exit /b 1))^&^
   (for %%n in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m) do if not "%%n"=="" (^
    set "%%y1=%%n"^&set "%%y2=^!%%y1:~2^!"^&^
    (if defined %%y2 (set /a "%%y1=0x^!%%y1:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%y3^^^! EQU 1 (^
      (if ^^^!%%y1^^^! EQU 2 (set /a "%%y4+=1"^>NUL^&set "%%yein=^!%%y2^!")^
      else if ^^^!%%y1^^^! EQU 3 (set /a "%%y4+=1"^>NUL^&set "%%ytpv=^!%%y2^!"^&^
       set "%%yntp=^!%%ytpv:~0,1^!"^&(if "^!%%yntp^!"=="~" (set "%%ytpv=^!%%ytpv:~1^!") else (set "%%yntp="))^&^
       (for %%o in (f,a,p,i,c,n,d,v,u,t,h,l,r,w,s,m) do if "^!%%ytpv:%%o=^!"=="" (^
        set "%%ytpv=%%o"^&set "%%y2="^&^
        (if defined %%yntp (if %%b==a (set "%%y2=1")) else if %%b==i (set "%%y2=1"))^
       ))^&^
       (if defined %%y2 (echo ^^^!%%y5^^^!Unsupported type of event.^&exit /b 1))^
      )^
      else if ^^^!%%y1^^^! EQU 4 (^
       set /a "%%y4+=1"^>NUL^&(if defined ^^^!%%y2^^^! (call set "%%yprv=%%^!%%y2^!%%") else (set "%%yprv=^!%%y2^!"))^&^
       (if defined %%yprv (^
        set "%%y1="^&^
        (for /L %%o in (1,1,4) do for /F "tokens=*" %%p in ('cmd /d /q /r "(for /F %%%%yq%%tokens=%%o delims=?%%%%yq%% %%p in ('echo %%%%yprv%%Z') do (echo %%p))"') do (^
         set "%%ycom=0"^&set "%%y2=%%p"^&(if "^!%%y2:~-1,1^!"=="Z" (set "%%y2=^!%%y2:~0,-1^!"))^&^
         (if defined %%y2 (^
          (if "^!%%y2:~0,1^!"=="'" if "^!%%y2:~-1,1^!"=="'" (set "%%ycom=1"^&set "%%y2=^!%%y2:~1,-1^!"))^&^
          (for /F "tokens=*" %%r in ('%%%%y0%%"^!@str_encode^! %%y2 11 # ; 1"') do (set %%r))^&^
          (if ^^^!%%ycom^^^! EQU 1 (set "%%y2='^!%%y2^!'"))^
         ))^&^
         (if %%o EQU 1 (if defined %%y2 (set "%%y1=^!%%y2^!") else (set "%%y1=")) else (if defined %%y2 (set "%%y1=^!%%y1^!?^!%%y2^!") else (set "%%y1==^!%%y1^!?")))^
        ))^&^
        set "%%yprv=^!%%y1^!"^
       ))^
      )^
      else if ^^^!%%y1^^^! EQU 5 (^
       set "%%ytov="^&^
       (for /F "tokens=* delims=+,-,0" %%o in ('echo.%%%%y2%%') do (^
        (set /a "%%y2=%%~o"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%y2^!"=="%%~o" (set "%%ytov=%%~o"))^
       ))^
      )^
      else if not defined %%ybdv (^
       (if ^^^!%%y1^^^! EQU 6 (set "%%ybdv=^!%%y2^!")^
       else if ^^^!%%y1^^^! EQU 7 if "^!%%y2^!"=="1" (^
        (for /F "tokens=*" %%o in ('%%%%y0%%"^!@date_span^! 3:%%ybdv 8:1"') do (set %%o))^
       ))^
      ))^
     ) else if ^^^!%%y1^^^! EQU 1 (^
      set "%%y4=3"^&set "%%yeiv=^!%%y2^!"^
     ))^&^
         (if ^^^!%%y1^^^! EQU 8 (set "%%yrrn=^!%%y2^!")^
     else if ^^^!%%y1^^^! EQU 10 ((set /a "%%yibd=^!%%y2^!"^>NUL 2^>^&1)^>NUL)^
     else if ^^^!%%y1^^^! EQU 11 (if "^!%%y2^!"=="1" (echo "%%y1="))^
     else if ^^^!%%y1^^^! EQU 9 (^
      (for /F "tokens=* delims=+,-,0" %%o in ('echo.%%%%y2%%') do if "%%~o"=="" (set "%%y2=0") else (^
       (set /a "%%yt=%%~o"^>NUL 2^>^&1)^>NUL ^&^& if "^!%%yt^!"=="%%~o" (^
        if "^!%%y2:~0,1^!"=="-" (set "%%y2=-%%~o") else (set "%%y2=%%~o")^
       )^
      ))^&^
      (if ^^^!%%y2^^^! EQU 0 (set "%%ywro= ") else (^
       (if ^^^!%%y2^^^! LSS 0 (set "%%y1=-1") else (set "%%y1=1"))^&set /a "%%y2*=^!%%y1^!"^>NUL^&^
       (if 250 LEQ ^^^!%%y2^^^! if ^^^!%%y2^^^! LEQ 86400000 (^
        if ^^^!%%y1^^^! LSS 0 (set "%%ywro=1:1 2:^!%%y2^!") else (set "%%ywro=2:^!%%y2^!")^
       ))^
      ))^
     ))^
    ))^
   ))^&^
   (for %%o in (@str_encode,@syms_replace,@date_span,@unset_alev,@unset_mac,TEMP,SystemRoot) do (set "%%o="))^
  ))^&^
  (if ^^^!%%y4^^^! NEQ 3 (echo ^^^!%%y5^^^!Some of required parameters missing or unreadable.^&exit /b 1))^&^
  (if ^^^!%%yrrv^^^! EQU 0 (^
   (set %%yt="^!%%yf:~1,-1^!.bak")^&(if exist ^^^!%%yt^^^! (call del /f /a /q %%%%yt%%)^>nul)^&^
   (if exist ^^^!%%yt^^^! (set "%%yrrv=6") else (^
    (if exist ^^^!%%yf^^^! (^
     (for /F "tokens=*" %%a in ('%%%%y0%%"^!@obj_attrib^! %%y1 %%yf ~r ^!%%ywro^! 3:1"') do (set %%a)^>NUL 2^>^&1)^
    ) else (set "%%y1=0"))^&^
    (if ^^^!%%y1^^^! EQU 0 (^
     (if exist ^^^!%%yf^^^! (^
      for /F "tokens=*" %%a in ('%%%%y0%%"^!@events_reader^!"') do (set %%a)^
     ) else (^
      if ^^^!%%y3^^^! EQU 1 (set "%%yrrv=0") else (set "%%yrrv=4")^
     ))^&^
     (if ^^^!%%yrrv^^^! EQU 0 (^
      (if ^^^!%%y3^^^! EQU 1 (^
       (if defined %%yfnd (^
        set "%%yeiv=1024"^&set "%%yeid=1024"^&^
        (for %%a in (512 256 128 64 32 16 8 4 2 1) do (^
         set /a "%%yeid-=%%a"^>NUL^&set "%%y1=000^!%%yeid^!"^&set "%%y1=^!%%y1:~-4,4^!"^&^
         call set "%%y2=%%%%yfnd:^!%%y1^!=%%"^&^
         (if "^!%%yfnd^!"=="^!%%y2^!" (set "%%yeiv=^!%%y1^!") else (set /a "%%yeid+=%%a"^>NUL))^
        ))^
       ) else (set "%%yeiv=0001"))^&^
       set "%%ycom= "^&(for %%a in (prv tov bdv) do if defined %%y%%a (set "%%ycom=,^!%%ycom^!"))^&^
       set "%%y1=1"^&set "%%ycom=^!%%ycom:~0,-1^!"^&^
       (echo {^>^>^^^!%%yf^^^!)^>NUL 2^>^&1 ^|^| (set "%%yrrv=7"^&(if not defined %%yrrn (echo Error [@event_file]: Invalid name of event file.^&exit /b 1)))^&^
       (if ^^^!%%yrrv^^^! EQU 0 (^
        (echo    "id": "^!%%yeiv^!",)^&^
        set "%%y2=^!%%ytpv^!"^&(if defined %%yntp (set "%%y2=^!%%yntp^!^!%%y2^!"))^&^
        (if defined %%ycom (set %%y2="^!%%y2^!"^^^!%%ycom:~0,1^^^!) else (set %%y2="^!%%y2^!"))^&^
        (echo    "type": ^^^!%%y2^^^!)^&^
        (if defined %%yprv (^
         echo    "predicate": "^!%%yprv^!"^^^!%%ycom:~1,1^^^!^&set /a "%%y1+=1"^>NUL^
        ))^&^
        (if defined %%ytov (^
         call echo    "timeout": "^!%%ytov^!"%%%%ycom:~^^^!%%y1^^^!,1%%^&set /a "%%y1+=1"^>NUL^
        ))^&^
        (if defined %%ybdv (echo    "begindate": "^!%%ybdv^!"))^&^
        (echo })^
       )^>^>^^^!%%yf^^^!)^
      ) else (^
       (if defined %%yeiv (^
        (if exist ^^^!%%yt^^^! (^
         (call move /y %%%%yt%% %%%%yf%%)^>nul 2^>^&1 ^|^| (set "%%yrrv=5")^
        ) else (^
         (call del /f /a /q %%%%yf%%)^>nul 2^>^&1) ^|^| (set "%%yrrv=5")^
        )^
       ) else (^
        set "%%yrrv=3"^&(if exist ^^^!%%yt^^^! (call del /f /a /q %%%%yt%%)^>nul 2^>^&1)^
       ))^
      ))^
     ))^
    ) else (set "%%yrrv=5"))^
   ))^
  ))^&^
  (if defined %%yrrn (echo "^!%%yrrn^!=^!%%yrrv^!"))^&(if defined %%yein (echo "^!%%yein^!=^!%%yeiv^!"))^
 ) else (^
  (for /F %%a in ('echo.%%%%y1%%') do if "%%~a"==%%a (set %%yf=%%~a) else if defined %%a (call set %%yf=%%%%a%%))^&^
  set "%%y5=Error [@event_file]: "^&^
  (if not defined %%yf (call echo %%%%y5%%Undefined file name parameter.^&exit /b 1))^&^
  set "%%y0=cmd /d /q /v:on /e:on /r "^&set "%%y3=@event_file"^&^
  (for /F "tokens=*" %%a in ('start /b /i /ABOVENORMAL %%%%y0%%"%%%%%%y3%%%%%%%%y1%%"') do (^
   set "%%y0=%%a"^&(if "^!%%y0:~0,5^!"=="Error" (echo %%a^&exit /b 0))^&^
   (if defined %%y1 (set %%a) else (echo %%a))^
  ))^&^
  (if defined %%y1 for %%a in (f,0,1,3,5) do (set "%%y%%a="))^
 )) else (echo Error [@event_file]: Absent parameters.^&exit /b 1)) else set wds_evf_1=

::          @event_item - gets specified attribute of event with given id [special macro for event file of library `wait.mds`].
::                        %~1 == valid path name to event file (variable or quoted string without spaces);
::                        %~2 == hardcoded name of attribute, supported options coincide with event field names:
::                           `type`       - get event type;
::                           `predicate`  - get event predicate;
::                           `timeout`    - get event timeout;
::                           `begindate`  - get event begin date;
::                        %~3 == event identifier (variable or quoted string);
::                        %~4 == variable name to return result;
::                        %~5 == [optional: any value to echo result instead of assigning to `%~4`].
::             Notes. #1: it performs case insensitive collation of attribute name (`%~2`);
::                    #2: if the event has not specified attribute or the event is not found, it doesn't do any output.
::          Dependencies: @events_reader, @unset_alev. Nominally: @obj_attrib, @time_span, @spinner.
::
set @event_item=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_evf_aux (for /F %%y in ('echo wds_evf_') do if defined %%y0 (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%yaux%%') do (^
   (if "%%~d"=="" (echo Error [@event_item]: Undefined 4th output parameter.^&exit /b 1))^&^
   set "%%yaux=%%~a"^&(if not "^!%%yaux^!"=="%%~a" (echo Error [@event_item]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set %%yf="")^&(if "%%~a"==%%a (set "%%yf=%%~a") else if defined %%~a (set "%%yf=^!%%~a^!"))^&^
   (set %%yq="")^&set "%%yq=^!%%yq:~1^!"^&(call set %%yf="%%%%yf:^!%%yq^!=%%")^&^
   (if not exist ^^^!%%~yf^^^! (echo Error [@event_item]: Event file `^^^!%%~yf^^^!` - parameter #1 - wasn't found.^&exit /b 1))^&^
   set "%%yt="^&set "%%yaux=%%~b"^&^
   (for %%f in (type,predicate,timeout,begindate) do for /F %%g in ('"echo.[^!%%yaux:%%f=^!]"') do if "%%g"=="[]" (set "%%yt=%%f"))^&^
   (if not defined %%yt (echo Error [@event_item]: The 2nd parameter has unsupported attribute name `%%~b`.^&exit /b 1))^&^
   set "%%yeiv="^&(if "%%~c"==%%c (set "%%yeiv=%%~c") else if defined %%~c (set "%%yeiv=^!%%~c^!"))^&^
   (if defined %%yeiv for /F "tokens=*" %%f in ('echo.%%%%yeiv%%') do (set "%%yeiv=%%~f"))^&^
   (if not defined %%yeiv (echo Error [@event_item]: The 3rd parameter `%%~c` has undefined value.^&exit /b 1))^&^
   set "%%~d=check"^&(if not "^!%%~d^!"=="check" (echo Error [@event_item]: The variable name `%%~d` in 4th parameter is unsupported.^&exit /b 1))^&^
   (if not "%%~e"=="" (echo "%%y0="))^&^
   set "%%yern=%%~d"^&set "%%yaux="^
  ))^&(if defined %%yaux (echo Error [@event_item]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('%%%%y0%%"^!@unset_alev^! 1:events_reader 2:%%y 3:^!%%yern^! 5:1 6:1"') do (set %%a))^&^
  set "%%y3=0"^&^
  (for /F "tokens=*" %%a in ('%%%%y0%%"^!@events_reader^!"') do (echo "^!%%yern^!=%%a"))^
 ) else (^
  set "%%y0=cmd /d /q /v:on /e:on /r "^&^
  (for /F "tokens=*" %%a in ('start /b /i /ABOVENORMAL %%%%y0%%"^!@event_item^!^!%%yaux^!"') do (^
   set "%%yaux=%%~a"^&(if "^!%%yaux:~0,5^!"=="Error" (echo %%a^&exit /b 0))^&^
   (if defined %%y0 (set %%a) else (echo %%a))^
  ))^&^
  (if defined %%y0 (set "%%yaux="^&set "%%y0="))^
 )) else (echo Error [@event_item]: Absent parameters.^&exit /b 1)) else set wds_evf_aux=
 
::       @runapp_getpid - runs application & returns its process identifier (PID).
::                        %~1 == the variable name of the calling script with assigned string to run application (see note #1);
::                        %~2 == the search string to find a started process (variable or value) (see also `8:%~11` & note #3);
::                        %~3 == the variable name to return found PID of the started process;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~4 == key value `0` to run application by @runapp_wsh (default), `1` to run it by @runapp;
::                      2:%~5 == the variable name to return result type, it returns next digital values:
::                               `+1`        - single instance of new running process was found, launcher console closed;
::                               `+2`        - single instance of new running process was found, launcher console locked & runs;
::                               `-0`        - timeout, failed to find result or some error in the process;
::                               `-1`        - multiple instances of new running processes, launcher console closed;
::                               `-2`        - multiple instances of new running processes, launcher console locked & runs;
::                      3:%~6 == [`1:%~4`=> @runapp]: the variable name to return PID of the launcher console (if it was locked);
::                      4:%~7 == key parameter to search window caption (`1`), default is `0` to search module names;
::                      5:%~8 == timeout value for search of the started process in msec [1000...86400000], default is 30000;
::                      6:%~9 == [`1:%~4`=> @runapp]: the key parameter to set priority of the process, default is `2` OR `/NORMAL`;
::                      7:%~10== [`1:%~4`=> @runapp_wsh]: value in range 1..7 to set the window mode of started application;
::                      8:%~11== key parameter (`1`) to use macro @res_select for extensive search options in `%~2`, default is `0`;
::                      9:%~12== key parameter with default `0` to search only processes with its own window, `1` to search all;
::                      A:%~13== [`9:%~12`=> 0]: the variable name to return window title (caption) of the started process;
::                      B:%~14== [`1:%~4`=> @runapp_wsh]: key parameter to echo result instead of assigning (`1`), default is `0`.
::          Warnings. #1: the call with `@runapp` from "for-in-do" & from @mac_wrapper locks calling process, not allowed;
::                    #2: the new console, started by this macro, has internal variables of `@runapp_getpid` and all variables of
::                        the calling context.
::             Notes. #1: for additional details about available parameter options see headers to @runapp & @runapp_wsh macros;
::                    #2: output of found PID or result:
::                               - in case of found multiple instances it returns PIDs as one CSV string: `PID#1,PID#2,...`;
::                               - in case of no matched results it undefines variable in the calling context;
::                    #3: [`8:%~11` == `1`] - see description of `@res_select` for more details:
::                               - it's recommended to use wildcard `*` instead of controls inside value of `%~2`;
::                               - all space symbols ` ` of logical operands must be raplaced with `/CHR{20}` or `*`;
::                    #4: [`8:%~11` == `0`] the explicit search string `%~2` can contain whitespace characters using the 
::                        replacement `/CHR{20}`, it applies for search with `@res_select` macro only with single operand;
::                    #5: with default value `0` of `8:%~11`, macro uses next calls of tasklist to search process with window:
::                               - by module names:  tasklist /FI "IMAGENAME eq %~2" ...;
::                               - by window titles: tasklist /FI "WINDOWTITLE eq %~2" ...;
::                        it's advised to do preliminary result check of commands above before use of search strings in this macro;
::                    #6: the call with search PID by `@res_select` macro (`8:%~11` == `1`) can be checked as follows:
::                               - for instance, we have "My text file.txt" file and want to open it with notepad.exe;
::                               - the call of this macro with search of started application by its window title:
::                                  set runcmd=notepad "My text file.txt"
::                                  %@runapp_getpid% runcmd "*text*/CHR{20}AND/CHR{20}*.txt*" res_pid 4:1 8:1
::                               - macro transforms it into corresponding call:
::                                  set "FindWndStr=*text* AND *.txt*"
::                                  set CmdToGetList="tasklist /fo:csv /v"
::                                  set SelectCmd="tokens=*"
::                                  %@res_select% FindWndStr;CmdToGetList;SelectCmd;1:FoundPID;4:1;6:-1;7:2
::                        the snippet above allows to check search result if the application is running in background.
::                               - the call of `@res_select` includes strings encoding because window titles can have controls. It
::                                 applies only to search of window titles (`4:%~7`). If the search of module names:
::                                  set "FindWndStr=*notepad*
::                                  set CmdToGetList="tasklist /fo:csv"
::                                  set SelectCmd="tokens=*"
::                                  %@res_select% FindWndStr;CmdToGetList;SelectCmd;1:FoundPID;6:1;7:2
::                        due to imprecise lookup, the snippet above will return the PID of all new Notepad applications launched
::                        after the current call of @runapp_getpid macro. In this case the search string must not have any control
::                        symbols in the search string, only logical tokens of `@res_select`;
::                    #7: The key value `9:%~12` equal to `1` increases performance by reducing internal activities of macro and
::                        has sense in the next cases:
::                               - if the target process is searched using the window title and there is no need to get window 
::                                 title by `A:%~13`;
::                               - if the target process is searched using the module name and it is necessary to get PID of 
::                                 started process without window.
::          Dependencies: @echo_params, @library.waitmds.vbs, @obj_newname, @pid_title, @res_select, @runapp, @runapp_wsh,
::                        @str_arrange, @str_decode, @str_encode, @sym_replace, @syms_replace, @time_span, @title, 
::                        @unset_alev, @unset_mac.
::
set @runapp_getpid=^
 (if defined wds_rai_p for /F "delims==" %%a in ('set wds_rai_') do (set "%%a="))^&^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_rai_p for /F %%p in ('echo wds_rai_') do if defined %%p0 (^
  (for /F "tokens=*" %%a in ('%%%%p0%%"^!@unset_alev^! 1:time_span,title,title_pid,pid_title,^!%%p5^! 2:%%p 5:1 6:1"') do (set %%a))^&^
  (for /F "tokens=*" %%a in ('%%%%p0%%"^!@time_span^! 5:%%pbg 9:1"') do (set %%a))^&^
  set "%%pbe=e"^&^
  (for /F "tokens=*" %%a in ('%%%%p0%%^^^!%%pis^^^!') do (set %%a))^&^
  (for %%a in (^^^!%%p5^^^!) do (set "@%%a="))^&^
  (if ^^^!%%pas^^^! EQU 0 (set "%%p5=%%pa") else (set "%%p5="^&set "%%pab=^!%%pae^!"))^&^
  (if ^^^!%%pra^^^! EQU 0 (set "%%pc=1"^&set "%%pcb=") else (^
   set "%%pc=0"^&(if defined %%p5 (set "%%p5=^!%%p5^!,%%pc") else (set "%%p5=%%pc"))^
  ))^&^
  (if defined %%p5 for /F "tokens=*" %%a in ('%%%%p0%%^^^!%%pwt^^^!') do (set %%a))^&^
  (if defined %%prtn (^
   set "%%prtv=0"^&^
   (if defined %%pab (^
    (if "^!%%pab:,=^!"=="^!%%pab^!" (set "%%prtv=1") else (set "%%prtv=-1"))^&^
    (if defined %%pcb (set /a "%%prtv*=2"^>NUL))^
   ))^
  ))^&^
  (if defined %%pab (echo "^!%%pran^!=^!%%pab^!") else (echo "^!%%pran^!="))^&^
  (if defined %%patn if defined %%patv (echo "^!%%patn^!=^!%%patv^!") else (echo "^!%%patn^!="))^&^
  (if defined %%prtn if defined %%prtv (echo "^!%%prtn^!=^!%%prtv^!") else (echo "^!%%prtn^!="))^&^
  (if defined %%prcn if defined %%pcb (echo "^!%%prcn^!=^!%%pcb^!") else (echo "^!%%prcn^!="))^
 ) else (^
  (for %%a in ("m=","rtn=","rcn=","wc=0","as=0","ra=0","pr=/NORMAL","to=30000","atn=","atv=","f=","mo=1","rs=0","ec=0","0=cmd /d /q /e:on /v:on /r ","1=Error [@runapp_getpid]: ","5=res_select,str_arrange,str_decode,echo_params,str_encode,sym_replace,syms_replace","6=tasklist /fo:csv /nh ") do (set "%%p%%~a"))^&^
  (if not "^!%%pwc^!"=="0" (call echo %%%%p1%%Enable delayed expansions.^&exit /b 1))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14" %%a in ('"echo.^!%%pp^!"') do (^
   set "%%pran=%%~c"^&(if defined %%pran if not "^!%%pran::=^!"=="^!%%pran^!" (set "%%pran="))^&^
   (if not defined %%pran (echo ^^^!%%p1^^^!Missing required 3rd parameter.^&exit /b 1))^&^
   set "%%p2=^!%%p1^!Not defined "^&^
   (if "%%a"=="%%~a" if defined %%a (set "%%pm=^!%%~a^!"))^&^
   (set %%pJ="")^&(set "%%pV=1^^^&1")^&(set %%pY="^^^^^!^^^!^^^!")^&(set %%pZ="^^^>")^&(set %%pb="^^^|")^&^
   (for %%n in (V,Y,J,Z) do (call set "%%p%%n=%%%%p%%n:~-2,1%%"))^&^
   (if defined %%pm for /F "tokens=1,*" %%n in ('"echo %%%%pm:~0,1%%%%%%pm:~-1,1%% %%%%pJ%%"') do if %%n=="" (set %%pm=^^^!%%pm:%%o=^^^!))^&^
   (if not defined %%pm (echo ^^^!%%p2^^^!command #1.^&exit /b 1))^&^
   (if "%%~b"==%%b (set "%%pf=%%~b") else if defined %%~b (set "%%pf=^!%%~b^!"))^&^
   (if defined %%pf (call set "%%pf=%%%%pf:^!%%pJ^!=%%") else (echo ^^^!%%p2^^^!search #2.^&exit /b 1))^&^
   (for %%o in (%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n) do if not "%%o"=="" (^
    set "%%pp=%%o"^&set "%%p4=^!%%pp:~2^!"^&^
    (if defined %%p4 (set /a "%%pp=0x^!%%pp:~0,1^!"^>NUL 2^>^&1) ^&^& (^
          if ^^^!%%pp^^^! EQU 2 (set "%%prtn=^!%%p4^!")^
     else if ^^^!%%pp^^^! EQU 3 (set "%%prcn=^!%%p4^!")^
     else if ^^^!%%pp^^^! EQU 5 (^
      (for /F "tokens=* delims=+,-,0" %%q in ('echo %%%%p4%%') do ((set /a "%%pp=%%q"^>NUL 2^>^&1)^>NUL ^&^& (^
       if "^!%%pp^!"=="%%q" if 1000 LEQ %%q if %%q LEQ 86400000 (set "%%pto=%%q")^
      )))^
     ) else if ^^^!%%pp^^^! EQU 6 (^
      (for %%q in ("/REALTIME" "/HIGH" "/ABOVENORMAL" "/NORMAL" "/BELOWNORMAL" "/LOW") do if defined %%p4 (^
       set /a "%%pp-=1"^>NUL^&call set "%%p4=%%%%p4:^!%%pp^!=%%~q%%"^&^
       (if "^!%%p4:%%~q=^!"=="" (set "%%ppr=%%~q"^&set "%%p4="))^
      ))^
     ) else if ^^^!%%pp^^^! EQU 7 (^
      (set /a "%%pp=0x^!%%p4^!"^>NUL 2^>^&1) ^&^& (if 0 LEQ ^^^!%%pp^^^! if ^^^!%%pp^^^! LSS 8 (set "%%pmo=^!%%pp^!"))^
     ) else if ^^^!%%pp^^^! EQU 10 (set "%%patn=^!%%p4^!")^
     else (^
      (set /a "%%p4=0x^!%%p4^!"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%p4^^^! EQU 1 (^
       for %%q in ("1=%%pra" "4=%%pwc" "8=%%prs" "9=%%pas" "11=%%pec") do ^
        for /F "tokens=1,2 delims==" %%r in ('echo.%%~q') do if "^!%%pp^!"=="%%r" (set "%%s=1")^
      ))^
     )^
    ))^
   ))^
  ))^&(if not defined %%pm (call echo %%%%p1%%Absent parameters.^&exit /b 1))^&^
  (if ^^^!%%prs^^^! EQU 1 (^
   (if ^^^!%%pwc^^^! EQU 0 (set %%p2="^!%%p6^!"^&set "%%pp=1"^&set "%%par=;6") else (^
    set "%%p2=^!%%p6^!/v"^&set "%%pp=-1"^&set "%%par=;4:1;6"^
   ))^&^
   (set %%p3="tokens=*")^&set "%%par=%%pf;%%p2;%%p3;1:%%pp^!%%par^!:^!%%pp^!;7:2;9:1"^
  ) else (set "%%pf=^!%%pf:/CHR{20}= ^!"))^&^
  set %%pid="set J#a=,JVset J#c=,JV(if Y#rsY EQU 1 ((for /F Jtokens=*J %%^^a in ('%%#0%%JY@res_selectY Y#arYJ') do (set %%^^a))ZNUL 2ZV1V(if defined #p for %%^^a in (Y#pY) do (set #a=Y#aY%%^^~a,))) else ((if Y#wcY EQU 0 (set #p=IMAGENAM) else (set #p=WINDOWTITL))V(for /F Jtokens=2 delims=,J %%^^a in ('Y#6Y/FI JY#pYE eq Y#fYJ') do if not J%%^^~aJ==JJ (set #a=Y#aY%%^^~a,))ZNUL 2ZV1))V(if Y#raY EQU 1 for /F Jtokens=2 delims=,J %%^^a in ('Y#6Y/FI JIMAGENAME eq cmd.exeJ /FI JSESSIONNAME eq ConsoleJ') do if not J%%^^~aJ==JJ (set #c=Y#cY%%^^~a,))ZNUL 2ZV1Vecho J#aY#beY=Y#a: =YJVecho J#cY#beY=Y#c: =YJ"^&^
  set %%pis="set J#c=0JVset J#n=0JVset J#ct=,JV(for /L %%^^a in (1,1,9999) do ((for /F Jtokens=*J %%^^b in ('%%#0%%Y#idY') do (set %%^^b))V(for %%^^b in (#a,#c) do if not JY%%^^bbYJ==J,J if not JY%%^^beYJ==J,J (set J#p=Y%%^^bb:~1,-1YJV(for %%^^c in (Y#pY) do (set J%%^^be=Y%%^^be:,%%^^c,=,YJ))))V(if not JY#ceYJ==J,J ((if 1 LSS %%^^a if not JY#aeYJ==J,J (set J#cb=Y#ceYJ))Vset J#p=Y#ct:~1,-1YJV(if defined #p for %%^^b in (Y#pY) do ((if JY#ce:,%%^^b,=YJ==JY#ceYJ (set J#ct=Y#ct:,%%^^b,=,YJVset /a J#n-=1JZNUL))))Vset J#p=Y#ce:~1,-1YJV(for %%^^b in (Y#pY) do if Y#nY LSS 1000 ((if JY#ct:,%%^^b,=YJ==JY#ctYJ (set J#ct=Y#ctY%%^^b,JVset /a J#n+=1JZNULV(if 0 LSS Y#cY (set J#ce=Y#ce:,%%^^b,=,YJ))))))V(if 1000 LEQ Y#nY (set J#ct=,JVset J#n=0J) else ((if 1 LSS %%^^a if not JY#aeYJ==J,J if not JY#ceYJ==J,J (set J#p=Y#ce:~1,-1YJV(for %%^^b in (Y#pY) do (set J#cb=Y#cb:,%%^^b,=,YJ))))))))V(if not JY#aeYJ==J,J ((if JY#ceYJ==J,J (set J#c=J) else if 2 LSS Y#cY (set J#c=J) else (set /a J#c+=1JZNUL))))V(if defined #c ((for /F Jtokens=*J %%^^b in ('%%#0%%JY@time_spanY B:#bg 5:#ts 7:2 9:1J') do (set %%^^b))V(if Y#toY LSS Y#tsY (set J#c=J))))V(if not defined #c ((for %%^^b in (#ae,#ce) do if JY%%^^bYJ==J,J (echo J%%^^b=J) else (echo J%%^^b=Y%%^^b:~1,-1YJ))Vexit /b 0))))"^&^
  set %%pwt="set #a=0%%%%pV%%^^set #ab=,%%%%pV%%^^set #cb=,%%%%pV%%(for /L %%^^a in (1,1,9999) do ((for %%^^b in (Y#5Y) do ((if defined %%^^be for %%^^c in (Y%%^^beY) do (set %%^^b=1%%%%pV%%(for /F Jtokens=2 delims=,J %%^^d in ('Jcall Y#6YY#b:~-2,1Y findstr /C:%%^^cJ') do if J%%^^cJ==J%%^^~dJ (set #p=%%^^c%%%%pV%%(for /F Jtokens=*J %%^^e in ('%%#0%%JY@titleY #4 1:#p 3:#p 4:1J') do (set %%^^e))%%%%pV%%(if Y#pY EQU 0 if JY#4:@runapp=YJ==JY#4YJ (if J%%^^bJ==J#aJ (set %%^^b=2) else (set #p=1)) else (if J%%^^bJ==J#aJ (set #p=1) else (set %%^^b=2)))%%%%pV%%(if Y#pY EQU 0 (set %%^^bb=Y%%^^bbY%%^^c,%%%%pV%%(if %%^^b==#a if defined #atn (echo J#atv=Y#4YJ))))))))))%%%%pV%%(if Y#aY LSS 2 ((for /F Jtokens=*J %%^^b in ('%%#0%%JY@time_spanY B:#bg 5:#ts 7:2 9:1J') do (set %%^^b))%%%%pV%%(if Y#toY LSS Y#tsY (set #a=2))))%%%%pV%%(if Y#aY EQU 2 ((for %%^^b in (Y#5Y) do if JY%%^^bbYJ==J,J (echo J%%^^bb=J) else (echo J%%^^bb=Y%%^^bb:~1,-1YJ))%%%%pV%%^^exit /b 0))))"^&^
  (for %%a in (id,is,wt) do (^
   (for %%b in (J,V,Y,Z) do (call set %%p%%a=%%%%p%%a:%%b=^^^!%%p%%b^^^!%%))^&set "%%p%%a=^!%%p%%a:#=%%p^!"^
  ))^&^
  set "%%pbe=b"^&^
  (for /F "tokens=*" %%a in ('%%%%p0%%%%%%pid%%') do (set %%a))^&^
  (if ^^^!%%pra^^^! NEQ 1 (^
   (for /F "tokens=*" %%a in ('%%%%p0%%"^!@runapp_wsh^! %%%%pmo%% %%pm"') do (echo %%a^&exit /b 1))^
  ) else (^
   set "%%pec=0"^&(cmd /d /q /r "^!@runapp^! %%%%ppr%% %%pm")^
  ))^&^
  set "%%pp="^&^
  (for /F "tokens=*" %%a in ('start /b /i /abovenormal %%%%p0%%"^!@runapp_getpid^! X"') do (^
   (for /F %%b in ('echo.%%a') do if "%%~b"=="Error" (echo %%a^&exit /b 1))^&^
   (if ^^^!%%pec^^^! EQU 1 (echo %%a) else (set %%a))^
  ))^&^
  (if ^^^!%%pec^^^! EQU 0 for /F "delims==" %%a in ('"set %%p"') do (set "%%a="))^
 ) else (echo Error [@runapp_getpid]: Absent parameters.^&exit /b 1)) else set wds_rai_p=
 
::--------------------------------------------------------
::-- Macros using VB script via cscript command tool:
::--------------------------------------------------------

:::@library.waitmds.vbs - auxiliary macro to obtain the full name of temporary file for the calling macro, creates this file.
:::                 Note: it has not parameters, reports result by screen printing.
:::
set @library.waitmds.vbs=^
 (for /F %%p in ('echo wds_ccl_') do if defined %%ppat (^
  set "%%pchk=,SystemRoot,Path,@obj_newname,library.waitmds.testruns,%%ppat,%%pcom,%%pchk,"^&^
  (for /F "delims==" %%a in ('set') do if "^!%%pchk:,%%a,=^!"=="^!%%pchk^!" (set "%%a="))^&^
  (for %%a in ("^!%%ppat^!") do (set "%%ppat=%%~sfa\"))^&^
  (set %%pchk="")^&set "%%pchk=^!%%pchk:~-1,1^!"^&^
  (call set "%%ppat=%%%%ppat:^!%%pchk^!=%%")^&(set "%%ppat=^!%%ppat:^\^\=^\^!")^&^
  set "%%ppfx=wait.mds.auxiliary.file.id"^&set "%%psfx=.vbs"^&set "%%pfnm=^!%%ppat^!^!%%ppfx^!*^!%%psfx^!*"^&set "%%ptmp=1"^&^
  (if exist "^!%%pfnm^!" for /F "tokens=*" %%a in ('dir /a /b /o:d "^!%%pfnm^!"') do if defined %%pchk (^
   set "%%pfnm=^!%%ppat^!%%~sna%%~sxa"^&^
   (if exist "^!%%pfnm^!" for /F "delims=:" %%b in ('attrib "^!%%pfnm^!"') do (^
    set "%%pchk=%%~b"^&set "%%pchk=^!%%pchk:~0,-1^!"^&^
    (if "^!%%pchk:a=^!"=="^!%%pchk^!" (^
     if exist "^!%%pfnm^!" for /F "tokens=2 delims==." %%c in ('"wmic datafile where name^=^'%%%%pfnm:\=\\%%' get lastModified /value 2>&1"') do for /F %%d in ('echo.%%c') do (^
      (pathping 127.0.0.1 -n -q 1 -p 750)^&^
      (if exist "^!%%pfnm^!" for /F "tokens=2 delims==." %%e in ('"wmic datafile where name^=^'%%%%pfnm:\=\\%%' get lastModified /value 2>&1"') do for /F %%f in ('echo.%%e') do (^
       if exist "^!%%pfnm^!" if "%%d"=="%%f" (del /f /a /q "^!%%pfnm^!") else (attrib +a -h -s "^!%%pfnm^!")^
      ))^
     )^
    ) else if exist "^!%%pfnm^!" (attrib -a -h -s "^!%%pfnm^!"))^
   ))^&^
   (if ^^^!%%ptmp^^^! LSS 4 (set /a "%%ptmp+=1") else (set "%%pchk="))^
  ))^>NUL 2^>^&1^&^
  set "%%pchk=fso.DeleteFile"^&(if defined library.waitmds.testruns (set "%%pchk='^!%%pchk^!"))^&^
  set "library.waitmds.testruns="^&set "%%ptim=250"^&^
  (for /F "tokens=1,2,3,*" %%a in ('"echo ^!%%pchk^! ( ) On Error Resume Next"') do (^
   (for /L %%e in (1,1,2147483647) do (^
    (for /L %%f in (1,1,5) do if defined %%pchk (^
     set "%%pfnm=^!time:~-2,2^!^!random:~0,2^!^!random:~-2,2^!"^&^
     (for /F "tokens=2 delims=.+" %%g in ('wmic os get LocalDateTime /value') do (^
      set "%%pchk=%%g"^&^
      set "%%pchk=^!%%ppat^!^!%%ppfx^!^!%%pfnm^!^!%%pchk:~2,1^!^!random:~0,2^!^!random:~-2,2^!^!time:~-2,2^!^!%%psfx^!"^&^
      (if not exist "^!%%pchk^!*" (^
       set "%%ptmp=^!%%pchk^!.bak.tmp"^&^
       ((echo %%d)^>"^!%%ptmp^!") ^&^& (set "%%pfnm=^!%%pchk^!"^&set "%%pchk=")^
      ))^
     ))^
    ))^&^
    (if defined %%pchk for /F "tokens=*" %%e in ('cmd /d /q /v:on /e:on /r "^!@obj_newname^! %%pfnm 1:%%ppat 2:%%ppfx 3:%%psfx 4:1 6:1"') do (^
     set %%e^&set "%%pfnm=^!%%ppat^!^!%%pfnm^!"^&set "%%ptmp=^!%%pfnm^!.bak.tmp"^&^
     (if not exist "^!%%ptmp^!" ((echo %%d)^>"^!%%ptmp^!"))^>NUL 2^>^&1^
    ))^&^
    (if exist "^!%%ptmp^!" (^
     (attrib +a -h -s "^!%%ptmp^!" ^| find "^!%%ptmp^!")^>NUL 2^>^&1 ^|^| (if exist "^!%%ptmp^!" (^
      (^
       (echo Dim wmo, fso : Set fso = CreateObject%%b"Scripting.FileSystemObject"%%c)^&^
       (echo %%a "^!%%pfnm^!")^&^
       (if defined %%pcom (echo ^^^!%%pcom^^^!))^
      )^>^>"^!%%ptmp^!" ^&^& (call move /y "^!%%ptmp^!" "^!%%pfnm^!.bak")^>NUL 2^>^&1 ^&^& (^
       set "%%ptmp=^!%%pfnm^!.bak"^&set "%%pc=0"^&^
       (if exist "^!%%ptmp^!" for /F "usebackq" %%f in ("^!%%ptmp^!") do if "%%f"=="Dim" (^
        set /a "%%pc+=1"^
       )^>NUL 2^>^&1)^&^
       (if ^^^!%%pc^^^! EQU 1 if exist "^!%%ptmp^!" for /F "delims=:" %%f in ('attrib "^!%%ptmp^!"') do (^
        set "%%pchk=%%~f"^&set "%%pchk=^!%%pchk:~0,-1^!"^&^
        (if not "^!%%pchk:a=^!"=="^!%%pchk^!" (echo "%%pfnm=^!%%pfnm^!"^&exit /b 0))^
       ))^
      )^
     ))^
    ))^&^
    set "%%pchk=1"^&^
    (^
     (if ^^^!%%ptim^^^! LSS 60000 (set /a "%%ptim+=250"))^&pathping 127.0.0.1 -n -q 1 -p ^^^!%%ptim^^^!^
    )^>NUL 2^>^&1^
   ))^
  ))^&^
  exit /b 1^
 ) else (^
  set "%%ppat=^!TEMP^!"^&^
  (for /F "tokens=*" %%a in ('start /b /i /abovenormal cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set %%a)) ^&^& (echo ^^^!%%pfnm^^^!.bak)^
 ))
 
::           @sleep_wsh - pauses calling process for a number of msec using `WScript.Sleep` method of Windows Scripting Host.
::                        %~1 == the time interval to sleep in msec (name of variable with interval or quoted string with interval).
::                  Note: for sleep intervals in range 50..100 msec use @spinner macro (smaller values are not valuable).
::          Dependencies: @library.waitmds.vbs, @obj_newname.
::
set @sleep_wsh=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_slp_aux for /F %%p in ('echo wds_slp') do (^
  (for /F %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_msc=%%~a"^&(if not "^!%%p_msc^!"=="%%~a" (echo Error [@sleep_wsh]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not "%%~a"==%%a if defined %%~a (set "%%p_msc=^!%%~a^!") else (echo Error [@sleep_wsh]: The 1st parameter is undefined.^&exit /b 1))^&^
   (set /a "%%p_aux=0x^!%%p_msc^!"^>NUL 2^>^&1)^>NUL ^&^& (set /a "%%p_msc-=80"^>NUL) ^|^| (echo Error [@sleep_wsh]: Expected positive digital value as 1st parameter.^&exit /b 1)^
  ))^&(if not defined %%p_msc (echo Error [@sleep_wsh]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%p_fnm=%%a"))^&^
  (if 0 LSS ^^^!%%p_msc^^^! (set "%%p_aux=WScript.Sleep(^!%%p_msc^!) : W") else (set "%%p_aux=W"))^&^
  (echo ^^^!%%p_aux^^^!Script.Echo "0")^>^>"^!%%p_fnm^!"^&^
  (call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   if 0 LSS ^^^!%%p_msc^^^! for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>nul)^
  ) ^|^| (echo Error [@sleep_wsh]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (for %%a in (aux,fnm,msc) do (set "%%p_%%a="))^
 ) else (echo Error [@sleep_wsh]: Absent parameters.^&exit /b 1)) else set wds_slp_aux=

::          @runapp_wsh - runs new application using `WScript.Shell` object of Windows Scripting Host.
::                        %~1 == the digital value in range [0...7] to define the mode of showing window. It matches the attribute
::                               `intWindowStyle` and the 2-nd parameter of the `WScript.Shell.Run` method. The value equal to '1'
::                               corresponds to normal window, `3` - maximized & `7` - minimized. See also `WScript` documentation
::                               for additional reference;
::                        %~2 == variable with string to run application or explicit string value in quotation marks.
::             Notes. #1: the command string `%~2`:
::                             - launches application using windows shell, string must begin with command without any prefixes;
::                             - the command can contain absolute path, but must be quoted in this case;
::                             - the parameters of command follows it as a suffix substring;
::                             - if parameters of the command substring have their own quotes:
::                                 1. the command substring must be enclosed in quotes too;
::                                 2. otherwise it will use 1st quoted parameter to extract path to set it as current folder;
::                             - to run a custom script use cmd.exe with key `/k` & filename as command parameters;
::                    #2: the application parameters run within context of vbs script file & can have vbs-related substrings;
::                    #3: macro is not designed to return any values, see also @runapp to run application by command `cmd\start`.
::          Dependencies: @library.waitmds.vbs, @obj_newname.
::
set @runapp_wsh=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_raw_aux for /F %%p in ('echo wds_raw_') do (^
  (for /F "tokens=1,*" %%a in ('echo.%%%%paux%%') do (^
   set "%%pmod="^&set "%%paux=%%~a"^&(if not "^!%%paux^!"=="%%~a" (echo Error [@runapp_wsh]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set /a "%%paux=0x%%~a"^>NUL 2^>^&1)^&(if 0 LEQ ^^^!%%paux^^^! if ^^^!%%paux^^^! LSS 8 (set "%%pmod=^!%%paux^!"))^&^
   (if not defined %%pmod (echo Error [@runapp_wsh]: Wrong 1st parameter, expected 0..7.^&exit /b 1))^&^
   (if "%%~b"==%%b (set "%%pcmd=%%~b") else if defined %%~b (set "%%pcmd=^!%%~b^!") else (echo Error [@runapp_wsh]: The command is undefined.^&exit /b 1))^
  ))^&(if not defined %%pmod (echo Error [@runapp_wsh]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%paux="")^&(set %%pfnm="^^^&")^&^
  (for /F "tokens=1,2" %%a in ('"echo.^!%%paux:~1^! ^!%%pfnm:~-2,1^!"') do (set "%%pcmd=^!%%pcmd:%%a=%%a %%b Chr(34) %%b %%a^!"))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%pfnm=%%a"))^&^
  (set %%paux="^^^&")^&(call set %%paux="%%%%paux:~-2,1%%")^&^
  (for /F "tokens=1,2,3" %%f in ('"echo ( ) %%%%paux%%"') do (^
   (echo Set wmo = WScript.CreateObject%%f"WScript.Shell"%%g : p = "")^&^
   (echo c = "^!%%pcmd^!")^&^
   (echo a = Split%%fc, Chr%%f34%%g%%g)^&^
   (echo If UBound%%fa%%g Then)^&^
   (echo  c = a%%f0%%g %%~h Chr%%f34%%g : b = Split%%fa%%f1%%g, "\"%%g)^&^
   (echo  If UBound%%fb%%g Then)^&^
   (echo   p = b%%f0%%g : For i = 1 To UBound%%fb%%g - 1 : p = p %%~h "\" %%~h b%%fi%%g : Next)^&^
   (echo   c = c %%~h b%%fUBound%%fb%%g%%g)^&^
   (echo  Else : c = c %%~h a%%f1%%g : End If)^&^
   (echo  For i = 2 To UBound%%fa%%g : c = c %%~h Chr%%f34%%g %%~h a%%fi%%g : Next)^&^
   (echo End If)^&^
   (echo If Len %%fp%%g Then wmo.CurrentDirectory = p)^&^
   (echo Return = wmo.Run%%fc, ^^^!%%pmod^^^!, false%%g : WScript.Echo "0")^
  )^>^>"^!%%pfnm^!")^&^
  (call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do (echo.^>nul)^
  ) ^|^| (echo Error [@runapp_wsh]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (for %%a in (aux,cmd,fnm,mod) do (set "%%p%%a="))^
 ) else (echo Error [@runapp_wsh]: Absent parameters.^&exit /b 1)) else set wds_raw_aux=
 
::            @sendkeys - sends sequence of keys to active window using `WScript.Shell.SendKeys` method of Windows Scripting Host.
::                        %~1 == name of variable with string of keys or its explicit string value in quotation marks.
::             Notes. #1: see documentation of `WScript.Shell.SendKeys` for more details;
::                    #2: internal representation of controls inside VBscript corresponds to their showing by `echo` command;
::                    #3: macro is not designed to return any values;
::                    #4: sample for foreground (active) window of calculator (c) Microsoft: `%@sendkeys% "2{+}3{=}"`.
::          Dependencies: @library.waitmds.vbs, @obj_newname.
::
set @sendkeys=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wsk_aux for /F %%p in ('echo wds_wsk') do (^
  (for /F %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_key=%%~a"^&(if not "^!%%p_key^!"=="%%~a" (echo Error [@sendkeys]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not "%%~a"==%%a if defined %%~a (set "%%p_key=^!%%~a^!") else (echo Error [@sendkeys]: The 1st parameter is undefined.^&exit /b 1))^
  ))^&^&(if not defined %%p_key (echo Error [@sendkeys]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set "%%p_lbr=(")^&(set "%%p_rbr=)")^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%p_fnm=%%a"))^&^
  (echo Set WshShell=WScript.CreateObject^^^!%%p_lbr^^^!"WScript.Shell"^^^!%%p_rbr^^^!)^>^>"^!%%p_fnm^!"^&^
  (echo WshShell.SendKeys^^^!%%p_lbr^^^!"^!%%p_key^!"^^^!%%p_rbr^^^! : WScript.Echo "0")^>^>"^!%%p_fnm^!"^&^
  (call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>nul)^
  ) ^|^| (echo Error [@sendkeys]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (for %%a in (aux,fnm,key,lbr,rbr,sfx) do (set "%%p_%%a="))^
 ) else (echo Error [@sendkeys]: Absent parameters.^&exit /b 1)) else set wds_wsk_aux=
 
::            @shortcut - macro creates Windows shortcut using `WScript.Shell->CreateShortcut`.
::                      Next parameters define new shortcut, can be variables or quoted strings with `/CHR{20}` instead of ` `:
::                        %~1 == the location of new shortcut (with file name of shortcut & its extension `.lnk`);
::                        %~2 == description or its name;
::                        %~3 == the command line of shortcut;
::                      Optional parameters in arbitrary order, must follow internal identifiers and marker ":":
::                      1:%~4 == working directory;
::                      2:%~5 == window style (integer value in range [0..11]);
::                      3:%~6 == icon location;
::                      4:%~7 == hot keys (the VBScript names of control symbols, delimiter - `+`);
::                      5:%~8 == arguments.
::                  Note: to avoid problems with starting of new shortcut, use `5:%~8` to set arguments of application.
::          Dependencies: @library.waitmds.vbs, @echo_params, @obj_newname.
::
set @shortcut=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_csc_aux for /F %%p in ('echo wds_csc') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux=%%~a"^&(if not "^!%%p_aux^!"=="%%~a" (echo Error [@shortcut]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set %%p_quo="")^&(set %%p_amp="^^^&")^&(set %%p_lbr="(")^&(set %%p_rbr=")")^&^
   (for %%k in (quo,amp,lbr,rbr) do (call set "%%p_%%k=%%%%p_%%k:~-2,1%%"))^&^
   (for %%k in ("scd=""","scw=3","sci=""","sch=""","sca=""") do (set "%%p_%%~k"))^&^
   set "%%p_spn=1"^&^
   (for /F "usebackq tokens=*" %%k in (`cmd /d /q /r "^!@echo_params^! 8 %%a %%b %%c %%d %%e %%f %%g %%h"`) do if not "%%~k"=="" (^
    set "%%p_spv=%%k"^&^
    (if ^^^!%%p_spn^^^! LSS 4 (set "%%p_spi=^!%%p_spn^!") else (^
     set "%%p_spi=10"^&^
     (set /a "%%p_spi=^!%%p_spv:~0,1^!"^>NUL 1^>^&2 ^&^& (^
      set /a "%%p_spi+=3"^>NUL^&set "%%p_spv=^!%%p_spv:~2^!"^
     ))^
    ))^&^
    (if defined %%p_spv for %%l in ("1 scl","2 scn","3 sct","4 scd","5 scw","6 sci","7 sch","8 sca") do for /F "tokens=1,2" %%m in (%%l) do if %%m EQU ^^^!%%p_spi^^^! (^
     set "%%p_%%n="^&^
     (for /F "tokens=*" %%o in ('echo.%%%%p_spv%%') do (^
      if "%%~o"==%%o (set "%%p_%%n=%%~o") else if defined %%~o (set "%%p_%%n=^!%%~o^!")^
     ))^&^
     (if defined %%p_%%n (^
      (if %%m NEQ 2 if %%m NEQ 3 if %%m NEQ 8 for /F %%o in ('echo.^^^!%%p_quo^^^!') do (^
        set %%p_%%n=^^^!%%p_%%n:%%o=^^^!))^&^
      (if %%m EQU 5 (^
       set "%%p_aux="^&^
       (set /a "%%p_aux=^!%%p_%%n^!"^>NUL 1^>^&2 ^&^& (^
        if ^^^!%%p_aux^^^! LSS 0 (set "%%p_aux=") else if 11 LSS ^^^!%%p_aux^^^! (set "%%p_aux=")^
       ))^&^
       (if not defined %%p_aux (echo Error [@shortcut]: The parameter #2:5 can have integer value in range 0..11.^&exit /b 1))^
      ) else (^
       set "%%p_%%n=^!%%p_%%n:/CHR{20}= ^!"^&^
       (for /F "tokens=1,2,3,4" %%q in ('"echo.^!%%p_quo^! ^!%%p_lbr^! ^!%%p_rbr^! ^!%%p_amp^!"') do (^
        (set %%p_%%n=^^^!%%p_%%n:%%q=%%q %%t Chr%%r34%%s %%t %%q^^^!)^
       ))^&^
       (set %%p_%%n="^!%%p_%%n^!")^
      ))^
     ) else if %%m LSS 4 (^
      echo Error [@shortcut]: Undefined parameter #%%m.^&exit /b 1^
     ) else (^
      set /a "%%p_aux=^!%%p_spi^!-3"^>NUL^&^
      echo Error [@shortcut]: Undefined parameter #^^^!%%p_aux^^^!:^^^!%%p_spi^^^!.^&exit /b 1^
     ))^
    ))^&^
    set /a "%%p_spn+=1"^>NUL^
   ))^&^
   set "%%p_aux="^
  ))^&(if defined %%p_aux (echo Error [@shortcut]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%p_fnm=%%a"))^&^
  (^
   (echo Set O = CreateObject^^^!%%p_lbr^^^!"WScript.Shell"^^^!%%p_rbr^^^!)^&^
   (echo Set Q = O.CreateShortcut^^^!%%p_lbr^^^!^^^!%%p_scl^^^!^^^!%%p_rbr^^^!)^&^
   (echo Q.Description = ^^^!%%p_scn^^^!)^&^
   (echo Q.TargetPath = ^^^!%%p_sct^^^!)^&^
   (echo Q.WorkingDirectory = ^^^!%%p_scd^^^!)^&^
   (echo Q.WindowStyle = ^^^!%%p_scw^^^!)^&^
   (echo Q.IconLocation = ^^^!%%p_sci^^^!)^&^
   (echo Q.HotKey = ^^^!%%p_sch^^^!)^&^
   (echo Q.Arguments = ^^^!%%p_sca^^^!)^&^
   (echo Q.Save)^&^
   (echo Err.Clear : WScript.Echo "0" : WScript.Quit 0)^
  )^>^>"^!%%p_fnm^!"^&^
  (call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   (for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo "%%a"^>nul))^&echo.^>nul^
  ) ^|^| (echo Error [@shortcut]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (for %%a in (aux,amp,fnm,lbr,quo,rbr,sca,scd,sch,sci,scl,scn,sct,scw,spi,spn,spv) do (set "%%p_%%a="))^
 ) else (echo Error [@shortcut]: Absent parameters.^&exit /b 1)) else set wds_csc_aux=
 
::                 @hex - converts decimal digit to hexadecimal string.
::                        %~1 == variable name to return result;
::                        %~2 == decimal digit to convert - explicit quoted value or external variable names with digital value;
::                        %~3 == [optional: key parameter to echo result instead of assigning (`1`), default is `0`].
::          Dependencies: @library.waitmds.vbs, @obj_newname.
::
set @hex=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_hex_aux for /F %%p in ('echo wds_hex') do (^
  (for /F "tokens=1,2,3" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_rsn=%%~a"^&(if not "^!%%p_rsn^!"=="%%~a" (echo Error [@hex]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%p_aux=0"^&(if "%%~b"==%%b (set "%%p_aux=%%~b") else if defined %%~b (set "%%p_aux=^!%%~b^!"))^&^
   set "%%p_dev="^&((set /a "%%p_eco=0x^!%%p_aux^!"^>NUL 2^>^&1)^>NUL ^&^& (set "%%p_dev=^!%%p_aux^!"))^&^
   (if not defined %%p_dev (echo Error [@hex]: The 2nd result parameter has not value.^&exit /b 1))^&^
   set "%%p_eco=0"^&(if not "%%~c"=="" (set /a "%%p_aux=0x%%~c"^>NUL 2^>^&1) ^&^& (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_eco=1")))^
  ))^&(if not defined %%p_eco (echo Error [@hex]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%p_fnm=%%a"))^&^
  set "%%p_aux=Hex(^!%%p_dev^!)"^&^
  (echo WScript.Echo ^^^!%%p_aux^^^!)^>^>"^!%%p_fnm^!"^&^
  (call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do if ^^^!%%p_eco^^^! NEQ 1 (set "^!%%p_rsn^!=%%a") else (echo "^!%%p_rsn^!=%%a")^
  ) ^|^| (echo Error [@hex]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (if ^^^!%%p_eco^^^! NEQ 1 for %%a in (aux,dev,eco,fnm,rsn) do (set "%%p_%%a="))^
 ) else (echo Error [@hex]: Absent parameters.^&exit /b 1)) else set wds_hex_aux=

::--------------------------------------------------------
::-- Macros using COM wrapper of Windows API:
::--------------------------------------------------------
(call set library.waitmds.filepath="%%~dp0..\wait.mds.bat")

:::@library.waitmds.com - auxiliary macro to check registration of COM library & to install it automatically.
:::            Notes. #1: it has not parameters, reports result by screen printing;
:::                   #2: performs check only once per every run by using value of global variable "%library.waitmds.filepath%";
:::                   #3: additionally serves to obtain the full name of temporary file for the calling macro, creates this file.
:::
set @library.waitmds.com=^
 (for /F %%p in ('echo wds_ccl_') do (^
  set "%%plib=library.waitmds.filepath"^&(set %%pchk="^^^|")^&(set %%pamp="^^^&")^&^
  call set "%%pchk=reg query HKCR\CLSID\{1a0c8df3-9520-4900-96bd-7b868e5f36e3}\InprocServer32\0.0.0.0 %%%%pchk:~-2,1%% find /i"^&^
  (if defined ^^^!%%plib^^^! (^
   (for /F %%a in ('%%%%pchk%% "WaitMdsApiWrapper.dll"') do if "%%~a"=="CodeBase" (set "^!%%plib^!="))^&^
   (if defined ^^^!%%plib^^^! (^
    (for /F "tokens=*" %%a in ('cmd /d /q /r "(set library.waitmds.filepath.local=^!%%plib^!)%%%%pamp:~-2,1%%(cmd /d /q /r call %%%%library.waitmds.filepath.local%%%% /sub:install 1 2)"') do (echo.^>nul))^&^
    (for /F %%a in ('%%%%pchk%% "WaitMdsApiWrapper.dll"') do if "%%~a"=="CodeBase" (set "^!%%plib^!="))^
   ))^
  ))^>NUL 2^>^&1^&^
  (if defined ^^^!%%plib^^^! (echo "") else (^
   echo "^!%%plib^!="^&^
   call set "%%pcom=Set wmo = CreateObject(^!%%pamp:~0,1^!WaitMdsApiWrapper^!%%pamp:~0,1^!)"^&^
   %%@library.waitmds.vbs%%^
  ))^
 ))

::            @taskinfo - returns tasks details. Macro has only optional parameters after internal identifier and marker ":".
::                      Variable names to set data and to return result, skip them to use default values or define preliminary:
::                      1:%~1 == variable name with process id (PID):
::                                 [in]  - the default `0` value to get data for current task, for another task set its PID;
::                                 [out] - always returns PID value of the process corresponding given parameterization;
::                      2:%~2 == variable name for PIDs of parent processes between specified task and the task hosting its window:
::                                 [in]  - the input value can change interpretation of `1:%~1` parameter, preliminary set values:
::                                       -  empty string to return result for value from `1:%~1` (default behaviour);
::                                       -  the result string from previous macro call to get PID of the caller (see sample below);
::                                 [out] - contains PIDs of intermediate processes as a string separated by comma symbol (`,`);
::                      Variable names to return result:
::                      3:%~3 == architecture of specified process, possible result values "x86", "x64", "unknown";
::                      4:%~4 == full file name of the specified process (running module, also known as executable);
::                      5:%~5 == window handle of the process hosting window;
::                      6:%~6 == PID of the process hosting window;
::                      7:%~7 == architecture of the process hosting window ("x86", "x64" or "unknown");
::                      8:%~8 == full file name of the process hosting window;
::                      Optional key parameters:
::                      9:%~9 == return string of intermediate PIDs in reverse order (`1`), default is `0`;
::                      A:%~10== echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: If you use the `start /b` command to start a process, a separate chain of children is created without 
::                        its own window. In this case, calling a macro inside such a child process with a broken inheritance 
::                        chain will artificially restore the hierarchy to the current console window process. If the calling
::                        macro doesn't belong to the process of interest, calling a macro will return incorrect result if
::                        the command  `start /b` was previously used to launch one of the running processes in their chain;
::                    #2: In the case of usual call it returns PIDs chain up to the process of calling context. The call inside 
::                        `for-in-do` block adds 2 volatile cmd.exe child processes to the end of the chain. It can be resolved 
::                        only by calling macro two times. The sample below gets caller pid (%callerPID%):
::                         set "intermediate="
::                         for ... ('cmd ... "^!@taskinfo^! 2:intermediate 9:1"') do ...
::                         for ... ('cmd ... "^!@taskinfo^! 2:intermediate 1:callerPID 9:1"') do ...
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @taskinfo=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gti_aux for /F %%y in ('echo wds_gti_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10" %%a in ('echo.%%%%yaux%%') do (^
   (for %%k in ("sin=","siv=0","iin=","iiv=","san=","smn=","whn=","win=","wan=","wmn=","ord=0","eco=0") do (set "%%y%%~k"))^&^
   (if not "^!%%yeco^!"=="0" (echo Error [@taskinfo]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%yquo=0"^&^
   (for %%k in (%%~a,%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j) do if not "%%k"=="" (^
    set "%%yaux=%%k"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 9 (^
      (set /a "%%ytmp=0x^!%%ytmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ytmp^^^! EQU 1 (set "%%yord=^!%%ytmp^!"))^
     ) else if ^^^!%%yaux^^^! EQU 10 (^
      (set /a "%%ytmp=0x^!%%ytmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ytmp^^^! EQU 1 (set "%%yeco=^!%%ytmp^!"))^
     ) else (^
      set "%%yamp=1"^&^
      (for %%l in (si,ii,sa,sm,wh,wi,wa,wm) do (^
       (if ^^^!%%yamp^^^! EQU ^^^!%%yaux^^^! (^
        set /a "%%yquo+=1"^>NUL^&set "%%y%%ln=^!%%ytmp^!"^&^
        (if ^^^!%%yaux^^^! EQU 1 (^
         for /F "tokens=* delims=+,-,0" %%l in ('"echo %%^!%%ytmp^!%%"') do (^
          (set /a "%%yaux=%%l"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%yaux^!"=="%%l" (set "%%ysiv=%%l"))^
         )^
        ) else if ^^^!%%yaux^^^! EQU 2 (^
         (if defined ^^^!%%ytmp^^^! for /F "tokens=1" %%m in ('echo %%^^^!%%ytmp^^^!%%') do (set "%%yiiv=%%~m"))^
        ))^
       ))^&^
       (set /a "%%yamp+=1")^>NUL^
      ))^
     ))^
    ))^
   ))^
  ))^&(if not defined %%yeco (echo Error [@taskinfo]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (if ^^^!%%yquo^^^! EQU 0 (echo Error [@taskinfo]: All output parameters are undefined.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@taskinfo]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  (set %%yquo="")^&set "%%yamp=1^^^&1"^&(set %%ylbr="(")^&(set %%yrbr=")")^&(for %%j in (quo amp lbr rbr) do (call set "%%y%%j=%%%%y%%j:~-2,1%%"))^&^
  set "%%ytmp=Dim san, smn, wan, wmn, sin, iin, win"^&^
  (if defined %%yiiv (^
   (if ^^^!%%yord^^^! EQU 1 (^
    set "%%yaux=^!%%yiiv^!"^&set "%%yiiv=,"^&(for %%a in (^^^!%%yaux^^^!) do (set "%%yiiv=%%a,^!%%yiiv^!"))^&^
    set "%%yiiv=^!%%yiiv:~0,-2^!"^
   ))^
  ) else if ^^^!%%ysiv^^^! EQU 0 (^
   ((echo ^^^!%%ytmp^^^!)^&^
    (echo wmo.GetTaskInfo sin, san, smn, iin, win, wan, wmn, "")^&^
    (echo WScript.Echo "%%yiiv=" ^^^!%%yamp^^^! iin)^
   )^>^>"^!%%yfnm^!"^&^
   (call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
    for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do (set "%%a")^
   ) ^|^| (echo Error [@taskinfo]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
   (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
    (if "%%~a"==%%a (set %%a))^&set "%%yfnm=%%a"^
   ))^
  ))^&^
  (if defined %%yiiv (set %%yiiv="^!%%yiiv^!") else (set %%yiiv=""))^&^
  ((echo ^^^!%%ytmp^^^!)^&^
   (echo sin = ^^^!%%ysiv^^^!)^&^
   (echo whn = wmo.GetTaskInfo^^^!%%ylbr^^^!sin, san, smn, iin, win, wan, wmn, ^^^!%%yiiv^^^!^^^!%%yrbr^^^!)^&^
   (if defined %%yiin (^
    (echo WScript.Echo "%%yiiv=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!iin^^^!%%yrbr^^^!)^&^
    set "%%yaux="^
   ) else (set "%%yaux=1"))^&^
   (for %%a in (si,sa,sm,wh,wi,wa,wm) do if defined %%y%%an (^
    (echo WScript.Echo "^!%%y%%an^!=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!%%an^^^!%%yrbr^^^!)^
   ))^
  )^>^>"^!%%yfnm^!"^&^
  (call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do (^
   (if defined %%yaux (^
    if ^^^!%%yeco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
   ) else (^
    set "%%a"^&set "%%yaux=1"^&^
    (if defined %%yiiv (^
     (if ^^^!%%yord^^^! EQU 1 (^
      call set "%%ytmp=^!%%yiiv^!"^&set "%%yiiv=,"^&(for %%a in (^^^!%%ytmp^^^!) do (set "%%yiiv=%%a,^!%%yiiv^!"))^&^
      set "%%yiiv=^!%%yiiv:~0,-2^!"^
     ))^&^
     (if ^^^!%%yeco^^^! NEQ 1 (set "^!%%yiin^!=^!%%yiiv^!") else (echo "^!%%yiin^!=^!%%yiiv^!"))^
    ))^
   ))^
  ) ^|^| (echo Error [@taskinfo]: R/W disk conflict or vbscript error.^&exit /b 1)^&^
  (if ^^^!%%yeco^^^! NEQ 1 for %%a in (amp,aux,eco,fnm,iin,iiv,lbr,ord,quo,rbr,san,sin,siv,smn,tmp,wan,whn,win,wmn) do (set "%%y%%a="))^
 ) else (echo Error [@taskinfo]: Absent parameters.^&exit /b 1)) else set wds_gti_aux=
 
::        @procpriority - reads or sets process priority by WS Host & WMI service, macro has only optional parameters after `:`.
::                      Next 2 parameters to find process - every item is variable name or quoted string, see also note #3:
::                      1:%~1 == process identifier(s) of running process(es) (see note #2);
::                      2:%~2 == module name(s) of running process(es) (name of executable, e.g.: `NoTePaD.ExE`, `calc.EXE`);
::                      One of next 2 parameters required to set macro action:
::                      3:%~3 == variable name to return the process priority after this macro action (see also `8:%~8`);
::                      4:%~4 == variable name to report PID of running processes found by module names;
::                      5:%~5 == variable name to report total number of found running processes;
::                      6:%~6 == priority value to set for process;
::                      Optional key parameters:
::                      7:%~7 == use WMI service to set & read priority level (`1`), default is `0` to use `wmic.exe` tool;
::                      8:%~8 == report the process's initial priority (`1`), default `0`, to return the resulting priority;
::                      9:%~9 == echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: the input & output priority value may be only one of the next string:
::                               - `REALTIME`, `HIGH`, `ABOVENORMAL`, `NORMAL`, `BELOWNORMAL` & `LOW`;
::                    #2: macro supports specification of several values inside `1:%~2` & `2:%~3` using CSV format, sample for PID:
::                               - `"1234",mypidvar1,mypidvar2,"7654", ...`
::                    #3: if both `1:%~1` & `2:%~2` are absent or `1:%~1` has only one pid value `0` then the macro will apply 
::                        action to current stack of processes beginning from the parent process with console window to the last child
::                        "cmd.exe" process. In case of plain call of macro the last process will not exist after exit and its pid or 
::                        priority will not belong to existing process. It ignores `7:%~7` in this mode and always uses WMI service.
::          Dependencies: @library.waitmds.vbs, @obj_newname (<==> `7:%~7` == `1`), @library.waitmds.com (<==> note #3).
::
set @procpriority=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wpp_aux for /F %%y in ('echo wds_wpp_') do (^
  (for %%a in ("err=Error [@procpriority]: ","pid=","mod=","prn=","prv=","fin=","fiv=","tnn=","tnv=0","spv=","uws=0","orp=0","eco=0","act=") do (set "%%y%%~a"))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%yaux%%') do (^
   (if not "^!%%yeco^!"=="0" (call echo %%%%yerr%%Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%i in ("%%~a","%%~b","%%~c","%%~d","%%~e","%%~f","%%~g","%%~h") do if not "%%~i"=="" (^
    set "%%yaux=%%~i"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 3 (^
      set "%%yprn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 4 (^
      set "%%yfin=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 5 (^
      set "%%ytnn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 6 (^
      (for %%j in ("REALTIME=256" "HIGH=128" "ABOVENORMAL=32768" "BELOWNORMAL=16384" "NORMAL=32" "LOW=64") do if defined %%ytmp (^
       (for /F "tokens=1,2 delims==" %%k in ('echo %%~j') do (^
        set "%%ytmp=^!%%ytmp:%%k=^!"^&(if not defined %%ytmp (set "%%yspv=%%l"))^
       ))^
      ))^&^
      (if defined %%ytmp (echo ^^^!%%yerr^^^!Parameter #6:6 can be only one of next strings REALTIME, HIGH, ABOVENORMAL, NORMAL, BELOWNORMAL or LOW.^&exit /b 1))^
     ) else if ^^^!%%yaux^^^! EQU 7 (if "^!%%ytmp^!"=="1" (set "%%yuws=1")^
     ) else if ^^^!%%yaux^^^! EQU 8 (if "^!%%ytmp^!"=="1" (set "%%yorp=1")^
     ) else if ^^^!%%yaux^^^! EQU 9 (if "^!%%ytmp^!"=="1" (set "%%yeco=1")^
     ) else (^
      set "%%ylbr="^&^
      (if ^^^!%%yaux^^^! EQU 1 (set "%%ylbr=1") else if ^^^!%%yaux^^^! EQU 2 if not defined %%ypid (set "%%ylbr=1"))^&^
      (if defined %%ylbr (^
       set "%%yrbr="^&set "%%ylbr=^!%%yerr^!Parameter #^!%%yaux^!:^!%%yaux^! has "^&^
       (for %%j in (^^^!%%ytmp^^^!) do (^
        (if "%%~j"==%%j (set "%%ytmp=%%~j") else if defined %%~j (set "%%ytmp=^!%%~j^!") else (echo ^^^!%%ylbr^^^!undefined variable `%%~j`.^&exit /b 1))^&^
        (if defined %%yrbr (^
         call set "%%yamp=%%%%yrbr:^!%%ytmp^!=%%"^&^
         (if "^!%%yamp^!"=="^!%%yrbr^!" (set "%%yrbr=^!%%yrbr^!,^!%%ytmp^!") else (echo ^^^!%%ylbr^^^!duplicates.^&exit /b 1))^
        ) else (set "%%yrbr=^!%%ytmp^!"))^
       ))^&^
       (if ^^^!%%yaux^^^! EQU 1 (set "%%ypid=^!%%yrbr^!"^&set "%%ymod=") else (set "%%ymod=^!%%yrbr^!"))^
      ))^
     ))^
    ))^
   ))^&^
   set "%%yaux="^
  ))^&(if defined %%yaux (call echo %%%%yerr%%Absent parameters, verify spaces.^&exit /b 1))^&^
  (if not defined %%ymod if defined %%ypid (if "^!%%ypid^!"=="0" (set "%%yuws=2")) else (set "%%yuws=2"^&set "%%ypid=0"))^&^
  (if not defined %%yprn if not defined %%yspv (echo ^^^!%%yerr^^^!Not defined parameters to read and set priority.^&exit /b 1))^&^
  set "%%ylbr=("^&set "%%yrbr=)"^&(set %%yexc="^^^^^!^^^!^^^!")^&(set %%yamp="^^^&")^&^
  (for %%a in (amp,exc) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  (if defined %%ypid (set "%%ylis=^!%%ypid^!") else (set "%%ylis=^!%%ymod^!"))^&^
  (if defined %%yspv (set "%%yaux=1"))^&^
  set "%%ytmp="^&(if defined %%yprn (set "%%ytmp=2") else if defined %%yfin (set "%%ytmp=2"))^&^
  (if defined %%yaux (if defined %%ytmp if ^^^!%%yorp^^^! EQU 1 (set "%%yaux=2,1") else (set "%%yaux=1,2")) else (set "%%yaux=2"))^&^
  (if ^^^!%%yuws^^^! EQU 0 for %%a in (^^^!%%yaux^^^!) do (^
   set "%%ytnv=0"^&^
   (for %%b in (^^^!%%ylis^^^!) do (^
    (if defined %%ypid (set "%%ytmp=processid='%%b'") else (set "%%ytmp=name='%%b'"))^&^
    (for /F "usebackq skip=1" %%c in (`"wmic process where %%%%ytmp%% get processid"`) do for /F %%d in ('echo.%%~c') do (^
     set "%%yaux="^&set "%%ytmp="^&^
     (if defined %%ymod for /F "usebackq skip=1" %%e in (`"wmic process where processid='%%d' get priority"`) do for /F %%f in ('echo.%%~e') do (^
      (if not defined %%yspv (set "%%yaux=%%f"))^&set "%%ytmp=1"^
     ) else (set "%%ytmp=1"))^&^
     (if defined %%ytmp (^
      (if %%a EQU 1 (call wmic process where processid='%%d' call setpriority ^^^!%%yspv^^^!) else (^
       (if defined %%yfin if defined %%yfiv (set "%%yfiv=^!%%yfiv^!,%%d") else (set "%%yfiv=%%d"))^&^
       (if defined %%yprn (^
        (if not defined %%yaux for /F "usebackq skip=1" %%e in (`"wmic process where processid='%%d' get priority"`) do for /F %%f in ('echo.%%~e') do (^
         set "%%yaux=%%f"^
        ))^&^
        (for %%g in ("24=REALTIME" "13=HIGH" "10=ABOVENORMAL" "8=NORMAL" "6=BELOWNORMAL" "4=LOW") do (set "%%yaux=^!%%yaux:%%~g^!"))^&^
        (if defined %%yprv (set "%%yprv=^!%%yprv^!,^!%%yaux^!") else (set "%%yprv=^!%%yaux^!"))^
       ))^
      ))^&^
      set /a "%%ytnv+=1"^>NUL^
     ))^
    ))^>NUL 2^>^&1^
   ))^
  ) else (^
   (if ^^^!%%yuws^^^! EQU 2 (^
    for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
     (if "%%~a"==%%a if %%a=="" (echo Error [@findwindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
    )^
   ) else for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.vbs^!"') do (set "%%yfnm=%%a"))^&^
   (^
    (echo Set objWMIService = GetObject^^^!%%ylbr^^^!"winmgmts:{impersonationLevel=impersonate}^!%%yexc^!\\.\root\cimv2"^^^!%%yrbr^^^!)^&^
    (if ^^^!%%yuws^^^! EQU 2 (^
     (echo Dim p : p = CStr^^^!%%ylbr^^^!wmo.PidOfWindow^^^!%%ylbr^^^!0^^^!%%yrbr^^^!^^^!%%yrbr^^^!)^&^
     (echo Do)^
    ))^&^
    (for %%a in (^^^!%%yaux^^^!) do for %%b in (^^^!%%ylis^^^!) do (^
     (if ^^^!%%yuws^^^! EQU 1 (^
      if defined %%ypid (set "%%yaux=ProcessId = '%%~b'") else (set "%%yaux=Name = '%%~b'")^
     ) else (set %%yaux=ProcessId = '" ^!%%yamp^! p ^!%%yamp^! "'))^&^
     (echo Set colProcessList = objWMIService.ExecQuery^^^!%%ylbr^^^!"SELECT * FROM Win32_Process WHERE ^!%%yaux^!"^^^!%%yrbr^^^!)^&^
     (echo For Each objProcess in colProcessList)^&^
     (if %%a EQU 1 (^
      if defined %%yspv (echo  objProcess.SetPriority^^^!%%ylbr^^^!^^^!%%yspv^^^!^^^!%%yrbr^^^!)^
     ) else (^
      (if defined %%yprn (echo  WScript.Echo Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^! ^^^!%%yamp^^^! "%%ytmp=" ^^^!%%yamp^^^! objProcess.Priority ^^^!%%yamp^^^! Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^!))^&^
      (if defined %%yfin (echo  WScript.Echo Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^! ^^^!%%yamp^^^! "%%yaux=" ^^^!%%yamp^^^! objProcess.ProcessId ^^^!%%yamp^^^! Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^!))^
     ))^&^
     (echo Next)^
    ))^&^
    (if ^^^!%%yuws^^^! EQU 2 (^
     (echo  p = wmo.CognateProc^^^!%%ylbr^^^!CLng^^^!%%ylbr^^^!p^^^!%%yrbr^^^!, "cmd.exe", False^^^!%%yrbr^^^!)^&^
     (echo Loop While CLng^^^!%%ylbr^^^!p^^^!%%yrbr^^^!)^
    ))^&^
    (echo Err.Clear : WScript.Echo "0" : WScript.Quit 0)^
   )^>^>"^!%%yfnm^!"^&^
   set "%%ytmp="^&set "%%yaux="^&^
   (call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
    for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do if "%%~a"=="0" (echo.^>nul) else (^
     set %%a^&^
     (if defined %%yprn if defined %%ytmp (^
      (for %%b in ("24=REALTIME" "13=HIGH" "10=ABOVENORMAL" "8=NORMAL" "6=BELOWNORMAL" "4=LOW") do if defined %%ytmp (^
       (for /F "tokens=1,2 delims==" %%c in ('echo %%~b') do if not "^!%%ytmp:%%c=^!"=="^!%%ytmp^!" (^
        (if defined %%yprv (set "%%yprv=^!%%yprv^!,%%d") else (set "%%yprv=%%d"))^&set "%%ytmp="^
       ))^
      ))^
     ))^&^
     (if defined %%yfin if defined %%yaux (^
      (if defined %%yfiv (set "%%yfiv=^!%%yfiv^!,^!%%yaux^!") else (set "%%yfiv=^!%%yaux^!"))^&set "%%yaux="^
     ))^&^
     set /a "%%ytnv+=1"^>NUL^
    )^
   ) ^|^| (echo ^^^!%%yerr^^^!R/W disk conflict or vbscript error.^&exit /b 1)^&^
   (if defined %%yprn if defined %%yfin (set /a "%%ytnv/=2"^>NUL))^
  ))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (^
   (if defined %%yprn if defined %%yprv (set "^!%%yprn^!=^!%%yprv^!") else (set "^!%%yprn^!="))^&^
   (if defined %%yfin if defined %%yfiv (set "^!%%yfin^!=^!%%yfiv^!") else (set "^!%%yfin^!="))^&^
   (if defined %%ytnn if defined %%ytnv (set "^!%%ytnn^!=^!%%ytnv^!") else (set "^!%%ytnn^!="))^&^
   (for %%a in (amp,aux,eco,err,exc,fin,fiv,fnm,lis,lbr,orp,pid,prn,prv,rbr,spv,tmp,tnn,tnv,uws) do (set "%%y%%a="))^
  ) else (^
   (if defined %%yprn if defined %%yprv (echo "^!%%yprn^!=^!%%yprv^!") else (echo "^!%%yprn^!="))^&^
   (if defined %%yfin if defined %%yfiv (echo "^!%%yfin^!=^!%%yfiv^!") else (echo "^!%%yfin^!="))^&^
   (if defined %%ytnn if defined %%ytnv (echo "^!%%ytnn^!=^!%%ytnv^!") else (echo "^!%%ytnn^!="))^
  ))^
 ) else (echo Error [@procpriority]: Absent parameters.^&exit /b 1)) else set wds_wpp_aux=
 
::          @findwindow - finds window using window class name & its captions, returns window handle.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~4`;
::                        %~2 == name of variable with class name or the class name string value in quotation marks;
::                        %~3 == name of variable with window caption or the caption string value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~4 == variable name to return handle to window, if absent it will return result into `%~1`;
::                      2:%~5 == timeout value in msec to wait until the specified window will be found, default is `0` to skip;
::                      3:%~6 == search substring of values `%~2` & `%~3` (`1`, default), or exact match of values (`0`);
::                      4:%~7 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: if `%~2` or `%~3` have explicit values the space symbols must be replaced by `/CHR{20}`;
::                    #2: if `2:%~5` has `1` value the result can contain several handles, separated by comma symbol;
::                    #3: with the default value `3:%~6 == 1` the search for the window class and its title is done as follows:
::                        - the search is carried out regardless of the case of characters;
::                        - search for strings without the symbol `*` is carried out by a simple check for the presence of a 
::                          substring in the string;
::                        - searching for strings with the character `*` interprets it as a wildcard for any substring, the 
::                          wildcard can be set in any part of the string, e.g: `*needed*arbitrary*substrings*of*title*`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @findwindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_fwh_aux for %%p in (wds_fwh_) do (^
  set "%%pwhn="^&^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%paux%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@findwindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%prsn (echo Error [@findwindow]: The 1st result parameter is undefined.^&exit /b 1))^&^
   (for %%h in ("cls=","cap=","whv=0","sub="s"","tmw=","eco=0") do (set "wds_fwh_%%~h"))^&^
   (if "%%~b"==%%b (set "%%pcls=%%~b") else if defined %%~b (set "%%pcls=^!%%~b^!"))^&(set %%pquo="")^&set "%%pamp=1^^^&1"^&^
   (if "%%~c"==%%c (set "%%pcap=%%~c") else if defined %%~c (set "%%pcap=^!%%~c^!"))^&(set %%plbr="(")^&(set %%prbr=")")^&^
   (for %%h in (quo amp lbr rbr) do (call set "wds_fwh_%%h=%%wds_fwh_%%h:~-2,1%%"))^&^
   (for %%h in (%%pcls %%pcap) do (^
    (if defined %%h (^
     set "%%h=^!%%h:/CHR{20}= ^!"^&^
     (for /F "tokens=1,*" %%i in ('"echo.. %%%%h:^!%%pquo^!=%%"') do if "%%~j"=="" (^
      set "%%h="^
     ) else for /F "tokens=1,*" %%k in ('echo.. %%%%h%%') do (set "%%h=%%~l"))^
    ))^&^
    (if defined %%h (^
     (call set %%h=%%%%h:^^^!%%pquo^^^!=^^^!%%pquo^^^! ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! ^^^!%%pquo^^^!%%)^&^
     (set %%h="^!%%h^!")^
    ) else (set %%h=""))^
   ))^&^
   (if ^^^!%%pcls^^^!=="" if ^^^!%%pcap^^^!=="" (echo Error [@findwindow]: Missing class and caption values.^&exit /b 1))^&^
   (for %%h in (%%~d,%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "%%paux=%%h"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%pwhn=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      for /F "tokens=* delims=+,-,0" %%i in ('echo.%%%%ptmp%%') do ((set /a "%%ptmp=%%~i"^>NUL 2^>^&1)^>NUL ^&^& (^
       if "^!%%ptmp^!"=="%%~i" (set "%%ptmw=%%~i")^
      ))^
     ) else (^
      (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1) ^&^& (if 0 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 1 (^
       (if ^^^!%%paux^^^! EQU 3 (if ^^^!%%ptmp^^^! EQU 0 (set %%psub="")) else if ^^^!%%paux^^^! EQU 4 (set "%%peco=^!%%ptmp^!"))^
      ))^
     ))^
    ))^
   ))^&^
   (if not defined %%pwhn (set "%%pwhn=^!%%prsn^!"^&set "%%prsn="))^
  ))^&(if not defined %%pwhn (echo Error [@findwindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@findwindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  (if ^^^!%%psub^^^!=="s" (set %%pcap=^^^!%%pcap^^^!, True))^&^
  set "%%psub=wmo.FindWindow^!%%psub:~1,-1^!(^!%%pcls^!, ^!%%pcap^!)"^&^
  (^
   (echo Dim h, n : h = ^^^!%%psub^^^!)^&^
   (if defined %%ptmw (^
    (echo n = ^^^!%%ptmw^^^! \ 75)^&^
    (echo For i = 0 To CLng^^^!%%plbr^^^!n^^^!%%prbr^^^!)^&^
    (echo  If Len^^^!%%plbr^^^!Replace^^^!%%plbr^^^!h, "0", ""^^^!%%prbr^^^!^^^!%%prbr^^^! Then Exit For)^&^
    (echo  WScript.Sleep^^^!%%plbr^^^!75^^^!%%prbr^^^! : h = ^^^!%%psub^^^!)^&^
    (echo Next)^
   ))^&^
   (echo WScript.Echo Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!h^^^!%%prbr^^^! ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^!)^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do if not %%a=="" (set "%%pwhv=%%~a")^
  ) ^|^| (echo Error [@findwindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (set "^!%%prsn^!=1") else (set "^!%%prsn^!=0"))^&^
   set "^!%%pwhn^!=^!%%pwhv^!"^&^
   (for %%a in (amp,aux,cap,cls,eco,fnm,lbr,pat,quo,rbr,rsn,sub,tmp,tmw,whn,whv) do (set "wds_fwh_%%a="))^
  ) else (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (echo "^!%%prsn^!=1") else (echo "^!%%prsn^!=0"))^&^
   echo "^!%%pwhn^!=^!%%pwhv^!"^
  ))^
 ) else (echo Error [@findwindow]: Absent parameters.^&exit /b 1)) else set wds_fwh_aux=

::         @windowstate - checks window state according given attribute.
::                        %~1 == variable name to return result (0/1 <==> True/False);
::                        %~2 == the attribute value to be checked, can have next values:
::                               `0` OR `IsWindow`        - the handle value corresponds to handle of an existing window;
::                               `1` OR `IsWindowVisible` - visibility of window;
::                               `2` OR `IsWindowEnabled` - enability of window;
::                               `3` OR `IsActive`        - window currently active (has focus);
::                               `4` OR `IsForeground`    - window currently foreground;
::                               `5` OR `IsHungAppWindow` - hung window or application;
::                               `6` OR `IsZoomed`        - zoomed or maximized window;
::                               `7` OR `IsIconic`        - iconic or minimized window;
::                               `8` OR `IsChild`         - it's a child window of another window (use with `2:%~5`);
::                               `9` OR `IsMenu`          - menu item window;
::                        %~3 == name of variable with window handle or the handle value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~4 == timeout digital value in msec to wait specified window state, default `0` to skip;
::                      2:%~5 == name of variable with parent window handle or its handle value in quotation marks (<==> `%~2==8`);
::                      3:%~6 == key parameter to negate result (`1`, true <-> false), default is `0`;
::                      4:%~7 == key parameter to echo result instead of assigning (`1`), default is `0`.
::                  Note: the result of macro is compatible with use of @mac_check.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @windowstate=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cws_aux for /F %%y in ('echo wds_cws_') do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%yaux%%') do (^
   set "%%yrsn=%%~a"^&(if not "^!%%yrsn^!"=="%%~a" (echo Error [@windowstate]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%yrsn (echo Error [@windowstate]: The 1st result parameter is undefined.^&exit /b 1))^&^
   (if not "%%~b"=="" (^
    set "%%yaux=[%%~b]"^&^
    (for %%h in ("[IsWindow]=[0]" "[IsWindowVisible]=[1]" "[IsWindowEnabled]=[2]" "[IsActive]=[3]" "[IsForeground]=[4]" "[IsHungAppWindow]=[5]" "[IsZoomed]=[6]" "[IsIconic]=[7]" "[IsChild]=[8]" "[IsMenu]=[9]") do (^
     call set "%%yaux=%%%%yaux:%%~h%%"^>NUL 2^>^&1^
    ))^&^
    (for /L %%h in (0,1,9) do if "^!%%yaux:[%%h]=^!"=="" (set "%%yatr=^!%%yaux:~1,-1^!"))^
   ))^&^
   (if not defined %%yatr (echo Error [@windowstate]: Not defined 2nd attribute parameter or not supported value.^&exit /b 1))^&^
   (for %%h in ("rsv=-1","tmw=","owh=0","neg=0","eco=0","hdl=0","aux=0") do (set "wds_cws_%%~h"))^&^
   (if "%%~c"==%%c (set "%%yaux=%%~c") else if defined %%~c (set "%%yaux=^!%%~c^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%h in ('echo %%%%yaux%%') do (^
    for /F "tokens=* delims=0123456789" %%i in ('echo.%%h?') do if "%%i"=="?" (set "%%yhdl=%%~h")^
   ))^&^
   (if ^^^!%%yhdl^^^! EQU 0 (echo Error [@windowstate]: Expected decimal non-zero value in 3rd parameter.^&exit /b 1))^&^
   (for %%h in (%%~d,%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "%%yaux=%%h"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 1 (^
      (for /F "tokens=* delims=+,-,0" %%i in ('echo %%%%ytmp%%') do (^
       (set /a "%%yaux=%%~i"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%yaux^!"=="%%~i" (set "%%ytmw=%%~i"))^
      ))^
     ) else if ^^^!%%yaux^^^! EQU 2 (^
      (for /F %%i in ('echo %%%%ytmp%%') do (^
       set "%%yaux="^&(if "%%~i"==%%i (set "%%yaux=%%~i") else if defined %%~i (set "%%yaux=^!%%~i^!"))^&^
       (for /F "tokens=* delims=+,-,0" %%j in ('echo.%%%%yaux%%') do (^
        for /F "tokens=* delims=0123456789" %%k in ('echo.%%j?') do if "%%k"=="?" (set "%%yowh=%%~j")^
       ))^
      ))^
     ) else (^
      (set /a "%%ytmp=0x^!%%ytmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ytmp^^^! EQU 1 (^
       if ^^^!%%yaux^^^! EQU 3 (set "%%yneg=1") else if ^^^!%%yaux^^^! EQU 4 (set "%%yeco=1")^
      ))^
     ))^
    ))^
   ))^&^
   (if ^^^!%%yatr^^^! EQU 8 if ^^^!%%yowh^^^! EQU 0 (echo Error [@windowstate]: Missing handle of parent window.^&exit /b 1))^
  ))^&(if not defined %%yeco (echo Error [@windowstate]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@windowstate]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  (set %%yhdl="^!%%yhdl^!")^&^
  set "%%ylbr=("^&set "%%yrbr=)"^&set "%%yamp=1^^^&1"^&(call set "%%yamp=%%%%yamp:~-2,1%%")^&^
        (if ^^^!%%yatr^^^! EQU 3 (set "%%yaux=R = wmo.ActiveWindow() = ^!%%yhdl^!"^
  ) else if ^^^!%%yatr^^^! EQU 4 (set "%%yaux=R = wmo.ForegroundWindow() = ^!%%yhdl^!"^
  ) else if ^^^!%%yatr^^^! EQU 8 (set "%%yaux=R = wmo.WindowIsChild(^!%%yowh^!, ^!%%yhdl^!)"^
  ) else (^
   (for %%a in ("0=IsWindow" "1=WindowIsVisible" "2=WindowIsEnabled" "5=WindowIsHung" "6=WindowIsZoomed" "7=WindowIsIconic" "9=WindowIsMenu" "8=WindowIsMenu") do (^
    (for /F "tokens=1,2 delims==" %%b in ('echo %%~a') do if ^^^!%%yatr^^^! EQU %%b (^
     set "%%yaux=R = wmo.%%c(^!%%yhdl^!)"^
    ))^
   ))^
  ))^&^
  (if ^^^!%%yneg^^^! EQU 1 (set "%%yaux=^!%%yaux^! : R = Not CBool(R)"))^&^
  ((echo Dim R : ^^^!%%yaux^^^!)^&^
   (if defined %%ytmw (^
    (echo Dim n : n = ^^^!%%ytmw^^^! \ 75)^&^
    (echo For i = 0 To CLng^^^!%%ylbr^^^!n^^^!%%yrbr^^^!)^&^
    (echo  If R Then Exit For)^&^
    (echo  WScript.Sleep 75 : ^^^!%%yaux^^^!)^&^
    (echo Next)^
   ))^&^
   set "%%yaux=Chr(34) ^!%%yamp^! CStr(CLng(R)) ^!%%yamp^! Chr(34)"^&^
   (echo WScript.Echo ^^^!%%yaux^^^!)^
  )^>^>"^!%%yfnm^!"^&^
  ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do if %%~a LSS 0 (set "%%yrsv=0") else (set "%%yrsv=1")^
  ) ^|^| (echo Error [@windowstate]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%yrsv^^^! LSS 0 (echo Error [@windowstate]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (^
   set "^!%%yrsn^!=^!%%yrsv^!"^&(for %%a in (amp,atr,aux,eco,fnm,hdl,lbr,neg,owh,rbr,rsn,rsv,tmp,tmw,whv) do (set "wds_cws_%%a="))^
  ) else (echo "^!%%yrsn^!=^!%%yrsv^!"))^
 ) else (echo Error [@windowstate]: Absent parameters.^&exit /b 1)) else set wds_cws_aux=

::        @activewindow - returns handle of currently focused (active) window.
::                        %~1 == variable name to return handle of window;
::                        %~2 == [optional: key parameter to echo result instead of assigning (`1`), default is `0`].
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @activewindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gaw_aux for /F %%p in ('echo wds_gaw') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_rsn=%%~a"^&(if not "^!%%p_rsn^!"=="%%~a" (echo Error [@activewindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%p_rsn (echo Error [@activewindow]: The 1st result parameter is undefined.^&exit /b 1))^&^
   (for %%f in ("rsv=-1","eco=0") do (set "%%p_%%~f"))^&^
   (if not "%%~b"=="" (^
    (set /a "%%p_tmp=0x%%~b"^>NUL 2^>^&1) ^&^& (if 0 LEQ ^^^!%%p_tmp^^^! if ^^^!%%p_tmp^^^! LEQ 1 (set "%%p_eco=^!%%p_tmp^!"))^
   ))^
  ))^&(if not defined %%p_eco (echo Error [@activewindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@activewindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_lbr=("^&set "%%p_rbr=)"^&^
  echo WScript.Echo wmo.ActiveWindow^^^!%%p_lbr^^^!^^^!%%p_rbr^^^!^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (set "%%p_rsv=%%a")^
  ) ^|^| (echo Error [@activewindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_rsv^^^! LSS 0 (echo Error [@activewindow]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 (^
   set "^!%%p_rsn^!=^!%%p_rsv^!"^&(for %%a in (aux,eco,fnm,hdl,lbr,rbr,rsn,rsv,tmp) do (set "%%p_%%a="))^
  ) else (echo "^!%%p_rsn^!=^!%%p_rsv^!"))^
 ) else (echo Error [@activewindow]: Absent parameters.^&exit /b 1)) else set wds_gaw_aux=
 
::    @foregroundwindow - returns handle of foreground window, supports bringing to foreground a window with given handle.
::                        %~1 == variable name to return handle of window;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == name of variable with handle of new foreground window or its handle value in quotation marks;
::                      2:%~3 == key parameter to set current window foreground (`1`, conceals value of `1:%~2`), default is `0`;
::                      3:%~4 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @foregroundwindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gfw_aux for /F %%p in ('echo wds_gfw') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_rsn=%%~a"^&(if not "^!%%p_rsn^!"=="%%~a" (echo Error [@foregroundwindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%p_rsn (echo Error [@foregroundwindow]: The 1st result parameter is undefined.^&exit /b 1))^&^
   (for %%e in ("rsv=-1","nhd=","cur=0","eco=0") do (set "%%p_%%~e"))^&^
   (for %%e in (%%~b,%%~c,%%~d) do if not "%%e"=="" (^
    set "%%p_aux=%%e"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%p_aux^^^! EQU 1 (^
      (for /F %%f in ('echo %%%%p_tmp%%') do (^
       set "%%p_aux=0"^&(if "%%~f"==%%f (set "%%p_aux=%%~e") else if defined %%~f (set "%%p_aux=^!%%~f^!"))^&^
       (for /F "tokens=* delims=+,-,0" %%g in ('echo %%%%p_aux%%') do (^
        for /F "tokens=* delims=0123456789" %%h in ('echo.%%g?') do if "%%h"=="?" (set %%p_nhd="%%~g")^
       ))^
      ))^
     ) else if ^^^!%%p_aux^^^! EQU 2 (^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%p_tmp^^^! EQU 1 (set "%%p_cur=1"))^
     ) else if ^^^!%%p_aux^^^! EQU 3 (^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%p_tmp^^^! EQU 1 (set "%%p_eco=1"))^
     ))^
    ))^
   ))^&^
   (if ^^^!%%p_cur^^^! EQU 1 (set "%%p_nhd=Split(wmo.WindowsOfPid(0), ",")(0)"))^
  ))^&(if not defined %%p_eco (echo Error [@foregroundwindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@foregroundwindow]: COM registration failed.^&exit /b 1) else (set %%a))^&^
   set "%%p_fnm=%%a"^
  ))^&^
  ((echo Dim nhd : nhd = 0)^&^
   (if defined %%p_nhd (^
    (echo nhd = ^^^!%%p_nhd^^^!)^&^
    (echo wmo.ShowWindow nhd, 6)^&^
    (echo wmo.ShowWindow nhd, 9)^&^
    (echo wmo.SetForeground nhd)^
   ))^&^
   set "%%p_aux=nhd = wmo.ForegroundWindow()"^&^
   (echo ^^^!%%p_aux^^^!)^&^
   (echo For i = 1 To 10)^&^
   (echo  If nhd Then Exit For)^&^
   (echo  WScript.Sleep 75 : ^^^!%%p_aux^^^!)^&^
   (echo Next)^&^
   set "%%p_aux=1^^^&1"^&(call set "%%p_aux=%%%%p_aux:~-2,1%%")^&set "%%p_aux=Chr(34) ^!%%p_aux^! CStr(nhd) ^!%%p_aux^! Chr(34)"^&^
   (echo WScript.Echo ^^^!%%p_aux^^^!)^
  )^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (set "%%p_rsv=%%~a")^
  ) ^|^| (echo Error [@foregroundwindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_rsv^^^! LSS 0 (echo Error [@foregroundwindow]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 (^
   set "^!%%p_rsn^!=^!%%p_rsv^!"^&(for %%a in (aux,cur,eco,fnm,hdl,nhd,rsn,rsv,tmp) do (set "%%p_%%a="))^
  ) else (echo "^!%%p_rsn^!=^!%%p_rsv^!"))^
 ) else (echo Error [@foregroundwindow]: Absent parameters.^&exit /b 1)) else set wds_gfw_aux=
 
::         @windowclass - returns class of the window with given handle.
::                        %~1 == name of variable with handle of window or its handle value in quotation marks;
::                        %~2 == variable name to return class of window;
::                        %~3 == [optional: key parameter to echo result instead of assigning (`1`), default is `0`].
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @windowclass=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wcl_aux for /F %%p in ('echo wds_wcl') do (^
  (for /F "tokens=1,2,3" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_wcn=%%~b"^&(if not "^!%%p_wcn^!"=="%%~b" (echo Error [@windowclass]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%p_wcn (echo Error [@windowclass]: The 2nd result parameter is undefined.^&exit /b 1))^&^
   (for %%d in ("wcv=","eco=0","hdl=0","aux=0") do (set "%%p_%%~d"))^&^
   (if "%%~a"==%%a (set "%%p_aux=%%~a") else if defined %%~a (set "%%p_aux=^!%%~a^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%d in ('echo.%%%%p_aux%%') do (^
    for /F "tokens=* delims=0123456789" %%e in ('echo.%%d?') do if "%%e"=="?" (set "%%p_hdl=%%~d")^
   ))^&^
   (if ^^^!%%p_hdl^^^! EQU 0 (echo Error [@windowclass]: Expected decimal non-zero value in 1st parameter.^&exit /b 1))^&^
   (if not "%%~c"=="" (^
    (set /a "%%p_tmp=0x%%~c"^>NUL 2^>^&1) ^&^& (if 0 LEQ ^^^!%%p_tmp^^^! if ^^^!%%p_tmp^^^! LEQ 1 (set "%%p_eco=^!%%p_tmp^!"))^
   ))^
  ))^&(if not defined %%p_eco (echo Error [@windowclass]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@windowclass]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  (^
   (set %%p_hdl="^!%%p_hdl^!")^&^
   set "%%p_aux=wmo.WindowClass(^!%%p_hdl^!)"^&(echo Dim str : str = ^^^!%%p_aux^^^!)^&^
   (set %%p_aux="^^^&")^&call set "%%p_tmp=%%%%p_aux:~-1,1%%"^&^&call set "%%p_aux=%%%%p_aux:~-2,1%%"^&^
   set "%%p_aux=^!%%p_tmp^!%%p_wcv=^!%%p_tmp^! ^!%%p_aux^! CStr(str)"^&^
   (echo str = ^^^!%%p_aux^^^! : Err.Clear : WScript.Echo str : WScript.Quit 0)^
  )^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   (for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (set "%%a"))^&echo.^>nul^
  ) ^|^| (echo Error [@windowclass]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 (^
   set "^!%%p_wcn^!=^!%%p_wcv^!"^&(for %%a in (aux,eco,fnm,hdl,tmp,wcn,wcv) do (set "%%p_%%a="))^
  ) else (echo "^!%%p_wcn^!=^!%%p_wcv^!"))^
 ) else (echo Error [@windowclass]: Absent parameters.^&exit /b 1)) else set wds_wcl_aux=
 
::       @windowcaptext - returns caption or text of the window with given handle.
::                        %~1 == name of variable with handle of window or its handle value in quotation marks;
::                        %~2 == variable name to return caption or text of window;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == key parameter to return window caption (`1`, default) or `0` to return window text;
::                      2:%~4 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @windowcaptext=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wct_aux for /F %%p in ('echo wds_wct') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_ctn=%%~b"^&(if not "^!%%p_ctn^!"=="%%~b" (echo Error [@windowcaptext]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%p_ctn (echo Error [@windowcaptext]: The 2nd result parameter is undefined.^&exit /b 1))^&^
   (for %%e in ("ctv=","cap=1","eco=0","hdl=0","aux=0") do (set "%%p_%%~e"))^&^
   (if "%%~a"==%%a (set "%%p_aux=%%~a") else if defined %%~a (set "%%p_aux=^!%%~a^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%e in ('echo.%%%%p_aux%%') do (^
    for /F "tokens=* delims=0123456789" %%f in ('echo.%%e?') do if "%%f"=="?" (set "%%p_hdl=%%~e")^
   ))^&^
   (if ^^^!%%p_hdl^^^! EQU 0 (echo Error [@windowcaptext]: Expected decimal non-zero value in 1st parameter.^&exit /b 1))^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%p_aux=%%e"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if 0 LEQ ^^^!%%p_tmp^^^! if ^^^!%%p_tmp^^^! LEQ 1 (^
      (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_cap=^!%%p_tmp^!") else if ^^^!%%p_aux^^^! EQU 2 (set "%%p_eco=^!%%p_tmp^!"))^
     ))^
    ))^
   ))^
  ))^&(if not defined %%p_eco (echo Error [@windowcaptext]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@windowcaptext]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  (if ^^^!%%p_cap^^^! NEQ 0 (set "%%p_aux=Caption") else (set "%%p_aux=Text"))^&^
  (^
   (set %%p_hdl="^!%%p_hdl^!")^&^
   set "%%p_aux=wmo.Window^!%%p_aux^!(^!%%p_hdl^!)"^&(echo Dim str : str = ^^^!%%p_aux^^^!)^&^
   (set %%p_aux="^^^&")^&call set "%%p_tmp=%%%%p_aux:~-1,1%%"^&call set "%%p_aux=%%%%p_aux:~-2,1%%"^&^
   set "%%p_aux=^!%%p_tmp^!%%p_ctv=^!%%p_tmp^! ^!%%p_aux^! CStr(str)"^&^
   (echo str = ^^^!%%p_aux^^^! : Err.Clear : WScript.Echo str : WScript.Quit 0)^
  )^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (set "%%a")^&echo.^>nul^
  ) ^|^| (echo Error [@windowcaptext]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 (^
   set "^!%%p_ctn^!=^!%%p_ctv^!"^&(for %%a in (aux,cap,ctn,ctv,eco,fnm,hdl,tmp) do (set "%%p_%%a="))^
  ) else (echo "^!%%p_ctn^!=^!%%p_ctv^!"))^
 ) else (echo Error [@windowcaptext]: Absent parameters.^&exit /b 1)) else set wds_wct_aux=
 
::          @windowrect - returns the window's client area rectangle or window rectangle in absolute coordinates.
::                        %~1 == name of variable with handle of window or its handle value in quotation marks;
::                      Variable names to return absolute coordinates of sides:
::                        %~2 == left;
::                        %~3 == top;
::                        %~4 == right;
::                        %~5 == bottom;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~6 == key parameter to return coordinates of client area (`1`, default) or `0` to return window area;
::                      2:%~7 == variable name to return width;
::                      3:%~8 == variable name to return height;
::                      4:%~9 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: if getting `%~4` and `%~5` is not needed, but only `2:%~7` and `3:%~8` are needed, then the order of
::                        initialization of variables inside the macro allows them to be overwritten when using the same names;
::                    #2: in case the macro is called for a minimized window, it changes it to normal view to get the correct 
::                        result and minimizes it back.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @windowrect=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_wcr_aux for /F %%p in ('echo wds_wcr_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%%%paux%%') do (^
   (for %%j in ("lfn=%%~b","tpn=%%~c","rin=%%~d","bon=%%~e","wca=1","eco=0") do (set "%%p%%~j"))^&^
   (if not "^!%%plfn^!"=="%%~b" (echo Error [@windowrect]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%phdl=0"^&set "%%paux=0"^&(if "%%~a"==%%a (set "%%paux=%%~a") else if defined %%~a (set "%%paux=^!%%~a^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%j in ('echo.%%%%paux%%') do (^
    for /F "tokens=* delims=0123456789" %%k in ('echo.%%j?') do if "%%k"=="?" (set "%%phdl=%%~j")^
   ))^&^
   (if ^^^!%%phdl^^^! EQU 0 (echo Error [@windowrect]: Expected decimal non-zero value in 1st parameter.^&exit /b 1))^&^
   set "%%paux=2"^&^
   (for %%j in (lf,tp,ri,bo) do if defined %%p%%jn (set /a "%%paux+=1"^>NUL) else (echo Error [@windowrect]: The result parameter #^^^!%%paux^^^! is undefined.^&exit /b 1))^&^
   (for %%j in (%%~f,%%~g,%%~h,%%~i) do if not "%%j"=="" (^
    set "%%paux=%%j"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
            if ^^^!%%paux^^^! EQU 1 (^
      if "^!%%ptmp^!"=="0" (set "%%pwca=0")^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      set "%%pwin=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 3 (^
      set "%%phen=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 4 (^
      if "^!%%ptmp^!"=="1" (set "%%peco=1")^
     )^
    ))^
   ))^
  ))^&(if not defined %%peco (echo Error [@windowrect]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@windowrect]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%plbr=("^&set "%%prbr=)"^&set "%%ptmp=1^^^&1"^&call set "%%ptmp=%%%%ptmp:~-2,1%%"^&^
  (^
   (echo Dim lf, tp, ri, bo, wi, he, rew : rew = 0)^&^
   (if ^^^!%%pwca^^^! NEQ 0 (set "%%paux=Client") else (^
    (echo If wmo.WindowIsIconic^^^!%%plbr^^^!^^^!%%phdl^^^!^^^!%%prbr^^^! Then wmo.ShowWindow "^!%%phdl^!", 1 : rew = 1)^&^
    set "%%paux=Window"^
   ))^&^
   echo wmo.^^^!%%paux^^^!Rect "^!%%phdl^!", lf, tp, ri, bo^&^
   (echo If rew Then wmo.ShowWindow "^!%%phdl^!", 2)^&^
   (if defined %%pwin (echo wi = CLng^^^!%%plbr^^^!ri^^^!%%prbr^^^! - CLng^^^!%%plbr^^^!lf^^^!%%prbr^^^!))^&^
   (if defined %%phen (echo he = CLng^^^!%%plbr^^^!bo^^^!%%prbr^^^! - CLng^^^!%%plbr^^^!tp^^^!%%prbr^^^!))^&^
   (for %%a in (ri,bo,lf,tp,wi,he) do if defined %%p%%an for /F "tokens=1,2" %%b in ('echo "^!%%p%%an^!=" CStr^^^!%%plbr^^^!%%a^^^!%%prbr^^^!') do (^
    echo WScript.Echo %%b ^^^!%%ptmp^^^! %%c^
   ))^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do if ^^^!%%peco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@windowrect]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (aux,bon,eco,fnm,hen,hdl,lbr,lfn,rbr,rin,tmp,ton,tpn,wca,win) do (set "%%p%%a="))^
 ) else (echo Error [@windowrect]: Absent parameters.^&exit /b 1)) else set wds_wcr_aux=

::          @showwindow - shows window according given command.
::                        %~1 == name of variable with handle of window or its handle value in quotation marks;
::                        %~2 == name of variable with command or command value in quotation marks.
::             Notes. #1: macro doesn't return any values;
::                    #2: the values of command `%~2` correspond to their values of windows API function ShowWindow (see MSDN).
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @showwindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_shw_aux for /F %%p in ('echo wds_shw') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux=%%~a"^&(if not "^!%%p_aux^!"=="%%~a" (echo Error [@showwindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%c in (1~hdl~%%a,2~cmd~%%b) do for /F "tokens=1,2,3 delims=~" %%d in ('echo %%c') do (^
    set "%%p_%%e="^&set "%%p_aux="^&(if "%%~f"==%%f (set "%%p_aux=%%~f") else if defined %%~f (set "%%p_aux=^!%%~f^!"))^&^
    (for /F "tokens=* delims=+,-,0" %%g in ('echo.%%%%p_aux%%') do (^
     for /F "tokens=* delims=0123456789" %%h in ('echo.%%g?') do if "%%h"=="?" (set "%%p_%%e=%%~g")^
    ))^&^
    (if not defined %%p_%%e if "%%e"=="cmd" if "%%~f"=="0" (set "%%p_%%e=0"))^&^
    (if not defined %%p_%%e (echo Error [@showwindow]: The parameter #%%d has non-digital value or undefined.^&exit /b 1))^
   ))^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@showwindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  echo wmo.ShowWindow "^!%%p_hdl^!", ^^^!%%p_cmd^^^! : WScript.Echo "0"^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL)^
  ) ^|^| (echo Error [@showwindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,fnm,hdl,cmd) do (set "%%p_%%a="))^
 ) else (echo Error [@showwindow]: Absent parameters.^&exit /b 1)) else set wds_shw_aux=
 
::            @findshow - finds window using its class name & caption, shows found window according given command.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~5`;
::                        %~2 == name of variable with class name or the class name string value in quotation marks;
::                        %~3 == name of variable with window caption or the caption string value in quotation marks;
::                        %~4 == name of variable with command or command value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~5 == variable name to return handles to window, if absent it will return result into `%~1`;
::                      2:%~6 == variable name to return number of found windows;
::                      3:%~7 == variable name to return the number of msec from start of scan when the first window was found;
::                      4:%~8 == timeout value in msec to wait until the specified window will be found, default is `0` to skip;
::                      5:%~9 == the number of msec to look for specified windows, default is exit with first found window;
::                      6:%~10== search substring of values `%~2` & `%~3` (`1`, default), or exact match of values (`0`);
::                      7:%~11== key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: this macro combines @findwindow & @showwindow to allow fast changes for new windows;
::                    #2: if `%~2` or `%~3` have explicit values the space symbols must be replaced by `/CHR{20}`;
::                    #3: for compatibility with @mac_check the `1:%~5` must always have some stub string value;
::                    #4: the parameter `3:%~7` is valuable with defined `4:%~8` or `5:%~9`, returns `0` if no windows found;
::                    #5: `5:%~9` invalidates `4:%~8` - it applies command to every window found during all specified timespan;
::                    #6: the result `1:%~5` (`%~1`) can contain several handles (separated by comma symbol), in the next cases:
::                        - if several windows was found at first successful scan (`6:%~10` <=> `1`, without `5:%~9`);
::                        - if several windows was found during specified timespan `5:%~9`;
::                    #7: in case of specified timespan `5:%~9` it returns all handles without check of windows present state;
::                    #8: the search for the strings of the window class and its title is carried out in the same way as in a 
::                        macro @findwindow (see description of this macro for more details).
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @findshow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_fsw_aux for /F %%y in ('echo wds_fsw_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11" %%a in ('echo.%%%%yaux%%') do (^
   set "%%yrsn=%%~a"^&(if not "^!%%yrsn^!"=="%%~a" (echo Error [@findshow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%yrsn (echo Error [@findshow]: The 1st result parameter is undefined.^&exit /b 1))^&^
   set "%%ycmd="^&(if "%%~d"==%%d (set "%%ycmd=%%~d") else if defined %%~d (set "%%ycmd=^!%%~d^!"))^&^
   (if defined %%ycmd for /F "tokens=* delims=+,-,0" %%l in ('echo.%%%%ycmd%%') do (^
    set "%%ycmd="^&^
    (if "%%~l"=="" (set "%%ycmd=0") else (^
     (set /a "%%ytmp=%%~l"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%ytmp^!"=="%%~l" (set "%%ycmd=%%~l"))^
    ))^
   ))^&^
   (if not defined %%ycmd (echo Error [@findshow]: Parameter #4 can have digital values 0..11.^&exit /b 1))^&^
   (for %%l in ("cls=","cap=","whn=","fnn=","1wn=","1wv=0","sub="s"","tmw=","mts=","eco=0") do (set "wds_fsw_%%~l"))^&^
   (if "%%~b"==%%b (set "%%ycls=%%~b") else if defined %%~b (set "%%ycls=^!%%~b^!"))^&^
   (if "%%~c"==%%c (set "%%ycap=%%~c") else if defined %%~c (set "%%ycap=^!%%~c^!"))^&^
   (set %%yquo="")^&set "%%yamp=1^^^&1"^&(set %%ylbr="(")^&(set %%yrbr=")")^&^
   (for %%l in (quo amp lbr rbr) do (call set "wds_fsw_%%l=%%wds_fsw_%%l:~-2,1%%"))^&^
   (for %%l in (%%ycls %%ycap) do (^
    (if defined %%l (^
     set "%%l=^!%%l:/CHR{20}= ^!"^&^
     (for /F "tokens=1,*" %%m in ('"echo.. %%%%l:^!%%yquo^!=%%"') do if "%%~n"=="" (^
      set "%%l="^
     ) else for /F "tokens=1,*" %%o in ('echo.. %%%%l%%') do (set "%%l=%%~p"))^
    ))^&^
    (if defined %%l (^
     (call set %%l=%%%%l:^^^!%%yquo^^^!=^^^!%%yquo^^^! ^^^!%%yamp^^^! Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^! ^^^!%%yamp^^^! ^^^!%%yquo^^^!%%)^&^
     (set %%l="^!%%l^!")^
    ) else (set %%l=""))^
   ))^&^
   (if ^^^!%%ycls^^^!=="" if ^^^!%%ycap^^^!=="" (echo Error [@findshow]: Missing class and caption values.^&exit /b 1))^&^
   (for %%l in (%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k) do if not "%%l"=="" (^
    set "%%yaux=%%l"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 1 (^
      set "%%ywhn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 2 (^
      set "%%yfnn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 3 (^
      set "%%y1wn=^!%%ytmp^!"^
     ) else (^
      (if ^^^!%%yaux^^^! NEQ 4 if ^^^!%%yaux^^^! NEQ 5 (^
       (set /a "%%ytmp=0x^!%%ytmp^!"^>NUL 2^>^&1) ^&^& (if 0 LEQ ^^^!%%ytmp^^^! if ^^^!%%ytmp^^^! LEQ 1 (^
        (if ^^^!%%yaux^^^! EQU 6 (if ^^^!%%ytmp^^^! EQU 0 (set %%ysub="")) else if ^^^!%%yaux^^^! EQU 7 (set "%%yeco=^!%%ytmp^!"))^&^
        set "%%ytmp="^
       ))^
      ))^&^
      (if defined %%ytmp for /F "tokens=* delims=+,-,0" %%m in ('echo.%%%%ytmp%%') do (set /a "%%ytmp=%%~m"^>NUL 2^>^&1) ^&^& (if "^!%%ytmp^!"=="%%~m" (^
       if ^^^!%%yaux^^^! EQU 4 (set "%%ytmw=%%~m") else if ^^^!%%yaux^^^! EQU 5 (set "%%ymts=%%~m")^
      )))^
     ))^
    ))^
   ))^&^
   (if defined %%ymts (set "%%ytmw="))^&(if not defined %%ywhn (set "%%ywhn=^!%%yrsn^!"^&set "%%yrsn="))^
  ))^&(if not defined %%yeco (echo Error [@findshow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@findshow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  (if ^^^!%%ysub^^^!=="s" (set %%ycap=^^^!%%ycap^^^!, True))^&^
  set "%%ysub=CStr(wmo.FindWindow^!%%ysub:~1,-1^!(^!%%ycls^!, ^!%%ycap^!))"^&^
  (set %%yaux="^^^<")^&call set "%%yaux=%%%%yaux:~-2,1%%"^&^
  (if defined %%ymts (set %%ytmp=" ") else (set %%ytmp=""))^&^
  set "%%ywhv=Dim m, f, t, n : f = 0 : t = 1000 * timer() : n = %%%%yfnv%% \ 25"^&^
  (^
   (echo Dim h, s, a, c, r : r = "" : c = 0 : s = ^^^!%%ysub^^^!)^&^
   (if defined %%ytmw (^
    set "%%yfnv=^!%%ytmw^!"^&(call echo ^^^!%%ywhv^^^!)^&^
    (echo For i = 0 To CLng^^^!%%ylbr^^^!n^^^!%%yrbr^^^!)^&^
    (echo  m = 1000 * timer^^^!%%ylbr^^^!^^^!%%yrbr^^^! - t : If m ^^^!%%yaux^^^! 0 Then m = m + 86400000)^&^
    (echo  If Len^^^!%%ylbr^^^!s^^^!%%yrbr^^^! Then)^&^
    (echo   WScript.Echo "%%y1wv=" ^^^!%%yamp^^^! CLng^^^!%%ylbr^^^!m^^^!%%yrbr^^^! : Exit For)^&^
    (echo  End If)^&^
    (echo  If ^^^!%%ytmw^^^! ^^^!%%yaux^^^! m Then Exit For)^&^
    (echo  WScript.Sleep^^^!%%ylbr^^^!25^^^!%%yrbr^^^! : s = ^^^!%%ysub^^^!)^&^
    (echo Next)^
   ))^&^
   (if defined %%ymts (^
    set "%%yfnv=^!%%ymts^!"^&(call echo ^^^!%%ywhv^^^!)^&^
    (echo For i = 0 To CLng^^^!%%ylbr^^^!n^^^!%%yrbr^^^!)^
   ))^&^
   (echo ^^^!%%ytmp:~1,-1^^^!a = Split^^^!%%ylbr^^^!s, ","^^^!%%yrbr^^^!)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!For j = 0 To UBound^^^!%%ylbr^^^!a^^^!%%yrbr^^^!)^&^
   (echo ^^^!%%ytmp:~1,-1^^^! If CBool^^^!%%ylbr^^^!Len^^^!%%ylbr^^^!a^^^!%%ylbr^^^!j^^^!%%yrbr^^^!^^^!%%yrbr^^^!^^^!%%yrbr^^^! And InStr^^^!%%ylbr^^^!r, a^^^!%%ylbr^^^!j^^^!%%yrbr^^^!^^^!%%yrbr^^^! = 0 Then)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!  If wmo.IsWindow^^^!%%ylbr^^^!a^^^!%%ylbr^^^!j^^^!%%yrbr^^^!^^^!%%yrbr^^^! Then)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!   c = c + 1)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!   If Len^^^!%%ylbr^^^!r^^^!%%yrbr^^^! Then r = r ^^^!%%yamp^^^! "," ^^^!%%yamp^^^! a^^^!%%ylbr^^^!j^^^!%%yrbr^^^! Else r = a^^^!%%ylbr^^^!j^^^!%%yrbr^^^!)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!   wmo.ShowWindow a^^^!%%ylbr^^^!j^^^!%%yrbr^^^!, ^^^!%%ycmd^^^!)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!  End If)^&^
   (echo ^^^!%%ytmp:~1,-1^^^! End If)^&^
   (echo ^^^!%%ytmp:~1,-1^^^!Next)^&^
   (if defined %%ymts (^
    (echo  m = 1000 * timer^^^!%%ylbr^^^!^^^!%%yrbr^^^! - t : If m ^^^!%%yaux^^^! 0 Then m = m + 86400000)^&^
    (echo  If f = 0 And c Then f = 1 : WScript.Echo "%%y1wv=" ^^^!%%yamp^^^! CLng^^^!%%ylbr^^^!m^^^!%%yrbr^^^!)^&^
    (echo  If ^^^!%%ymts^^^! ^^^!%%yaux^^^! m Then Exit For)^&^
    (echo  WScript.Sleep^^^!%%ylbr^^^!25^^^!%%yrbr^^^! : s = ^^^!%%ysub^^^!)^&^
    (echo Next)^
   ))^&^
   (echo WScript.Echo "%%ywhv=" ^^^!%%yamp^^^! r)^&^
   (echo WScript.Echo "%%yfnv=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!c^^^!%%yrbr^^^!)^&^
   (echo Err.Clear : WScript.Quit 0)^
  )^>^>"^!%%yfnm^!"^&^
  ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do (set "%%~a")^
  ) ^|^| (echo Error [@findshow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%yeco^^^! NEQ 1 (^
   (if defined %%yrsn if defined %%ywhv (set "^!%%yrsn^!=0") else (set "^!%%yrsn^!=1"))^&^
   (if defined %%ywhv (set "^!%%ywhn^!=^!%%ywhv^!") else (set "^!%%ywhn^!="))^&^
   (if defined %%yfnn (set "^!%%yfnn^!=^!%%yfnv^!"))^&^
   (if defined %%y1wn (set "^!%%y1wn^!=^!%%y1wv^!"))^&^
   (for %%a in (1wn,1wv,amp,aux,cap,cls,cmd,eco,fnm,fnn,fnv,lbr,mts,pat,quo,rbr,rsn,sub,tmp,tmw,whn,whv) do (set "wds_fsw_%%a="))^
  ) else (^
   (if defined %%yrsn if defined %%ywhv (echo "^!%%yrsn^!=0") else (echo "^!%%yrsn^!=1"))^&^
   (if defined %%ywhv (echo "^!%%ywhn^!=^!%%ywhv^!") else (echo "^!%%ywhn^!="))^&^
   (if defined %%yfnn (echo "^!%%yfnn^!=^!%%yfnv^!"))^&^
   (if defined %%y1wn (echo "^!%%y1wn^!=^!%%y1wv^!"))^
  ))^
 ) else (echo Error [@findshow]: Absent parameters.^&exit /b 1)) else set wds_fsw_aux=
 
::          @movewindow - moves window to the point in absolute coordinates, supports size change of window.
::                        %~1 == handle of window;
::                        %~2 == the coordinate of the left side of the window after moving;
::                        %~3 == the coordinate of the top side of the window after moving;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~4 == new width of window;
::                      2:%~5 == new height of window;
::                      3:%~6 == key parameter to set precisely the right side if the width has changed (`1`), default is `0`;
::                      4:%~7 == key parameter to set precisely the bottom side if the height has changed (`1`), default is `0`;
::                      5:%~8 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: 1st five parameters can be variable names with values or explicit digital values in quotation marks;
::                    #2: macro returns values to report window parameters after relocation (they can alter, only into variables).
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @movewindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mvw_aux for /F %%y in ('echo wds_mvw_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%yaux%%') do (^
   (for %%i in ("1=Error [@movewindow]: ","2=WScript.Echo ","3=","lfn=","tpn=","wdn=","wdv="0"","htn=","htv="0"","rgt=0","bot=0","eco=0","amp=") do (set "%%y%%~i"))^&^
   (if not "^!%%yeco^!"=="0" (echo ^^^!%%y1^^^!Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%i in (%%~d,%%~e,%%~f,%%~g,%%~h) do if not "%%i"=="" (^
    set "%%yaux=%%i"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 1 (set "%%ywdv=^!%%ytmp^!") else if ^^^!%%yaux^^^! EQU 2 (set "%%yhtv=^!%%ytmp^!") else (^
      (if ^^^!%%yaux^^^! EQU 3 (set "%%yamp=rgt"^
      ) else if ^^^!%%yaux^^^! EQU 4 (set "%%yamp=bot"^
      ) else if ^^^!%%yaux^^^! EQU 5 (set "%%yamp=eco"))^&^
      (if defined %%yamp ((if ^^^!%%ytmp^^^! EQU 1 (set "%%y^!%%yamp^!=1"))^&set "%%yamp="))^
     ))^
    ))^
   ))^&^
   (for %%i in (1~hd~%%a,2~lf~%%b,3~tp~%%c,4~wd~^^^!%%ywdv^^^!,5~ht~^^^!%%yhtv^^^!) do for /F "tokens=1,2,3 delims=~" %%j in ('echo %%i') do (^
    set "%%y%%kv="^&^
    (if "%%~l"==%%l (set "%%y%%kn="^&set "%%y%%kv=%%~l") else if defined %%~l (set "%%y3=1"^&set "%%y%%kn=%%~l"^&set "%%y%%kv=^!%%~l^!"))^&^
    (if defined %%y%%kv (^
     (if %%j EQU 2 (set "%%yaux=^!%%y%%kv:-=^!") else if %%j EQU 3 (set "%%yaux=^!%%y%%kv:-=^!") else (^
      (if %%j EQU 1 (^
       (if ^^^!%%y%%kv^^^! NEQ 0 (set "%%yaux=^!%%y%%kv^!") else (set "%%yaux="))^
      ) else (^
       set "%%yaux=^!%%y%%kv^!"^
      ))^
     ))^&^
     (if %%j EQU 1 (^
      (for /F "tokens=* delims=+,-,0" %%m in ('echo.%%%%yaux%%') do (^
       set "%%yaux="^&^
       (for /F "tokens=* delims=0123456789" %%n in ('echo.%%m?') do if "%%n"=="?" (^
        set "%%yaux=%%~m"^&set "%%y%%kv=%%~m"^
       ))^
      ))^
     ) else if defined %%yaux (set /a "%%yaux=0x^!%%yaux^!"^>NUL 2^>^&1)^>NUL ^|^| (set "%%yaux="))^&^
     (if not defined %%yaux (^
      echo ^^^!%%y1^^^!The parameter #%%j has non-digital value.^&exit /b 1^
     ))^
    ) else (echo ^^^!%%y1^^^!The parameter #%%j is undefined.^&exit /b 1))^
   ))^
  ))^&(if not defined %%yhtv (echo Error [@movewindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo ^^^!%%y1^^^!COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  set "%%yamp=1^^^&1"^&(set %%ylbr="(")^&(set %%yrbr=")")^&(for %%a in (amp lbr rbr) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  (^
   (echo Dim lf, tp, wd, ht, l, t, r, b, w, h)^&^
   (for %%a in (lf,tp,wd,ht) do (echo %%a = ^^^!%%y%%av^^^!))^&^
   (echo If Not wmo.IsWindow^^^!%%ylbr^^^!"^!%%yhdv^!"^^^!%%yrbr^^^! Then)^&^
   (echo  ^^^!%%y2^^^!"%%yaux=1" : WScript.Quit 0)^&^
   (echo End If)^&^
   (echo If wmo.WindowIsIconic^^^!%%ylbr^^^!"^!%%yhdv^!"^^^!%%yrbr^^^! Then)^&^
   (echo  Call wmo.ShowWindow^^^!%%ylbr^^^!"^!%%yhdv^!", 9^^^!%%yrbr^^^!)^&^
   (echo End If)^&^
   set /a "%%yaux=^!%%ywdv^!*^!%%yhtv^!"^>NUL^&^
   (if ^^^!%%yaux^^^! LEQ 0 (^
    (echo If wmo.WindowRect^^^!%%ylbr^^^!"^!%%yhdv^!", l, t, r, b^^^!%%yrbr^^^! Then)^&^
    (if ^^^!%%ywdv^^^! EQU 0 (echo  wd = CLng^^^!%%ylbr^^^!r^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!l^^^!%%yrbr^^^!))^&^
    (if ^^^!%%yhtv^^^! EQU 0 (echo  ht = CLng^^^!%%ylbr^^^!b^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!t^^^!%%yrbr^^^!))^&^
    (echo Else)^&^
    (echo  ^^^!%%y2^^^!"%%yaux=2" : WScript.Quit 0)^&^
    (echo End If)^
   ))^&^
   (echo If wd * ht = 0 Then)^&^
   (echo  ^^^!%%y2^^^!"%%yaux=3" : WScript.Quit 0)^&^
   (echo End If)^&^
   (echo If Not wmo.MoveWindow^^^!%%ylbr^^^!"^!%%yhdv^!", lf, tp, wd, ht, True^^^!%%yrbr^^^! Then)^&^
   (echo  ^^^!%%y2^^^!"%%yaux=4" : WScript.Quit 0)^&^
   (echo End If)^&^
   (if not "^!%%yrgt^!^!%%ybot^!"=="00" (^
    (echo If wmo.WindowRect^^^!%%ylbr^^^!"^!%%yhdv^!", l, t, r, b^^^!%%yrbr^^^! Then)^&^
    (echo  w = CLng^^^!%%ylbr^^^!r^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!l^^^!%%yrbr^^^!)^&^
    (echo  h = CLng^^^!%%ylbr^^^!b^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!t^^^!%%yrbr^^^!)^&^
    (echo Else)^&^
    (echo  ^^^!%%y2^^^!"%%yaux=2" : WScript.Quit 0)^&^
    (echo End If)^&^
    (if ^^^!%%yrgt^^^! EQU 0 (set "%%yaux=f") else (set "%%yaux=f + CLng(wd) - CLng(w)"))^&^
    (echo l = l^^^!%%yaux^^^!)^&^
    (if ^^^!%%ybot^^^! EQU 0 (set "%%yaux=p") else (set "%%yaux=p + CLng(ht) - CLng(h)"))^&^
    (echo t = t^^^!%%yaux^^^!)^&^
    set "%%yaux=CBool(lf - l) Or CBool(tp - t)"^&^
    (echo If ^^^!%%yaux^^^! Then)^&^
    (echo  If Not wmo.MoveWindow^^^!%%ylbr^^^!"^!%%yhdv^!", l, t, w, h, True^^^!%%yrbr^^^! Then)^&^
    (echo   ^^^!%%y2^^^!"%%yaux=4" : WScript.Quit 0)^&^
    (echo  End If)^&^
    (echo End If)^
   ))^&^
   (if defined %%y3 (^
    (echo If wmo.WindowRect^^^!%%ylbr^^^!"^!%%yhdv^!", lf, tp, wd, ht^^^!%%yrbr^^^! Then)^&^
    (echo  wd = CLng^^^!%%ylbr^^^!wd^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!lf^^^!%%yrbr^^^!)^&^
    (echo  ht = CLng^^^!%%ylbr^^^!ht^^^!%%yrbr^^^! - CLng^^^!%%ylbr^^^!tp^^^!%%yrbr^^^!)^&^
    (echo Else)^&^
    (echo  ^^^!%%y2^^^!"%%yaux=2" : WScript.Quit 0)^&^
    (echo End If)^
   ))^&^
   (echo ^^^!%%y2^^^!"%%yaux=0")^&^
   (for %%a in (lf,tp,wd,ht) do if defined %%y%%an (^
    (echo ^^^!%%y2^^^!"^!%%y%%an^!=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!%%a^^^!%%yrbr^^^!)^
   ))^
  )^>^>"^!%%yfnm^!"^&^
  set "%%yaux=%%yaux"^&^
  ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do (^
    (if "^!%%yaux^!"=="%%yaux" (^
     set "%%a"^
    ) else if ^^^!%%yaux^^^! EQU 0 (^
     (if ^^^!%%yeco^^^! EQU 0 (set "%%a") else (echo "%%a"))^
    ))^
   )^
  ) ^|^| (echo ^^^!%%y1^^^!R/W disk conflict or vbscript error.^&exit /b 1))^&^
  set "%%ytmp="^&^
  (if ^^^!%%yaux^^^! EQU 1 (set "%%ytmp=Invalid window handle"^
  ) else if ^^^!%%yaux^^^! EQU 2 (set "%%ytmp=Failed to get window rectangle"^
  ) else if ^^^!%%yaux^^^! EQU 3 (set "%%ytmp=Width or height of window is zero"^
  ) else if ^^^!%%yaux^^^! EQU 4 (set "%%ytmp=Failed to move window"))^&^
  (if defined %%ytmp (echo ^^^!%%y1^^^!^^^!%%ytmp^^^!.^&exit /b 1))^&^
  (if ^^^!%%yeco^^^! NEQ 1 for %%a in (1,2,3,amp,aux,bot,fnm,hdn,hdv,htn,htv,lbr,lfn,lfv,rbr,rgt,tpn,tpv,wdn,wdv,eco) do (set "%%y%%a="))^
 ) else (echo Error [@movewindow]: Absent parameters.^&exit /b 1)) else set wds_mvw_aux=

::         @sendmessage - sends message to the window with given handle.
::                        %~1 == handle of window;
::                        %~2 == message identifier (for more details see description of SendMessage API in MSDN);
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == `wParam` parameter of message, default is `0`;
::                      2:%~4 == `lParam` parameter of message, default is `0`.
::             Notes. #1: macro doesn't return any values;
::                    #2: all parameters can be variable names with values or explicit digital values in quotation marks.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @sendmessage=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_sms_aux for /F %%p in ('echo wds_sms') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux=%%~a"^&(if not "^!%%p_aux^!"=="%%~a" (echo Error [@sendmessage]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%e in ("wpr="0"","lpr="0"") do (set "%%p_%%~e"))^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%p_aux=%%e"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_wpr=^!%%p_tmp^!") else if ^^^!%%p_aux^^^! EQU 2 (set "%%p_lpr=^!%%p_tmp^!"))^
    ))^
   ))^&^
   (for %%e in (1~hdl~%%a,2~mid~%%b,3~wpr~^^^!%%p_wpr^^^!,4~lpr~^^^!%%p_lpr^^^!) do for /F "tokens=1,2,3 delims=~" %%f in ('echo %%e') do (^
    set "%%p_%%g="^&(if "%%~h"==%%h (set "%%p_%%g=%%~h") else if defined %%~h (set "%%p_%%g=^!%%~h^!"))^&^
    (if defined %%p_%%g (^
     (if ^^^!%%p_%%g^^^! NEQ 0 (^
      (for /F "tokens=* delims=+,-,0" %%i in ('echo.%%%%p_%%g%%') do (^
       set "%%p_%%g="^&^
       (for /F "tokens=* delims=0123456789" %%j in ('echo.%%i?') do if "%%j"=="?" (set "%%p_%%g=%%~i"))^
      ))^&^
      (if not defined %%p_%%g (echo Error [@sendmessage]: The parameter #%%f has non-digital value.^&exit /b 1))^
     ) else if %%f LSS 3 (echo Error [@sendmessage]: The parameter #%%f has `0` value.^&exit /b 1))^
    ) else (echo Error [@sendmessage]: The parameter #%%f is undefined.^&exit /b 1))^
   ))^
  ))^&(if not defined %%p_lpr (echo Error [@sendmessage]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@sendmessage]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  (echo wmo.SendMessage "^!%%p_hdl^!", ^^^!%%p_mid^^^!, ^^^!%%p_wpr^^^!, ^^^!%%p_lpr^^^! : WScript.Echo "0")^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL)^
  ) ^|^| (echo Error [@sendmessage]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,fnm,hdl,lpr,mid,tmp,wpr) do (set "%%p_%%a="))^
 ) else (echo Error [@sendmessage]: Absent parameters.^&exit /b 1)) else set wds_sms_aux=
 
::         @findcontrol - finds child window using handle of parent window & class name with caption of child window.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~5`;
::                        %~2 == name of variable with parent window handle or its digital value in quotation marks;
::                        %~3 == name of variable with class name or the class name string value in quotation marks;
::                        %~4 == name of variable with window caption or the caption string value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~5 == variable name to return handle to window, if absent it will return result into `%~1`;
::                      2:%~6 == timeout value in msec to wait until the specified window will be found, default is `0` to skip;
::                      3:%~7 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: if `%~2` or `%~3` have explicit values the space symbols must be replaced by `/CHR{20}`;
::                    #2: if several child windows match query the result will contain their handles separated by comma symbol;
::                    #3: the search for the strings of the window class and its title is carried out in the same way as in a 
::                        macro @findwindow with a set parameter `3:%~6 == 1` (see note #3 of this macro).
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @findcontrol=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_fcw_aux for /F %%p in ('echo wds_fcw_') do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%paux%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@findcontrol]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%prsn (echo Error [@findcontrol]: The 1st result parameter is undefined.^&exit /b 1))^&^
   (for %%h in ("whn=","whv=0","tmw=","eco=0","owh=0","aux=") do (set "wds_fcw_%%~h"))^&^
   (if "%%~b"==%%b (set "%%paux=%%~b") else if defined %%~b (set "%%paux=^!%%~b^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%h in ('echo.%%%%paux%%') do (^
    for /F "tokens=* delims=0123456789" %%i in ('echo.%%h?') do if "%%i"=="?" (set "%%powh=%%~h")^
   ))^&^
   (if ^^^!%%powh^^^! EQU 0 (echo Error [@findcontrol]: Invalid handle of parent window in 2nd parameter.^&exit /b 1))^&^
   (if "%%~c"==%%c (set "%%pcls=%%~c") else if defined %%~c (set "%%pcls=^!%%~c^!"))^&(set %%pquo="")^&set "%%pamp=1^^^&1"^&^
   (if "%%~d"==%%d (set "%%pcap=%%~d") else if defined %%~d (set "%%pcap=^!%%~d^!"))^&(set %%plbr="(")^&(set %%prbr=")")^&^
   (for %%h in (quo amp lbr rbr) do (call set "wds_fcw_%%h=%%wds_fcw_%%h:~-2,1%%"))^&^
   (for %%h in (%%pcls %%pcap) do (^
    (if defined %%h (^
     (call set %%h=%%%%h:^^^!%%pquo^^^!=^^^!%%pquo^^^! ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! ^^^!%%pquo^^^!%%)^&^
     (set %%h="^!%%h:/CHR{20}= ^!")^
    ) else (set %%h=""))^
   ))^&^
   (if ^^^!%%pcls^^^!=="" if ^^^!%%pcap^^^!=="" (echo Error [@findcontrol]: Missing class and caption values.^&exit /b 1))^&^
   (for %%h in (%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "%%paux=%%h"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%pwhn=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      for /F "tokens=* delims=+,-,0" %%i in ('echo.%%%%ptmp%%') do ((set /a "%%ptmp=%%~i"^>NUL 2^>^&1)^>NUL ^&^& (^
       if "^!%%ptmp^!"=="%%~i" (set "%%ptmw=%%~i")^
      ))^
     ) else if ^^^!%%paux^^^! EQU 3 (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=1")))^
    ))^
   ))^&^
   (if not defined %%pwhn (set "%%pwhn=^!%%prsn^!"^&set "%%prsn="))^
  ))^&(if not defined %%peco (echo Error [@findcontrol]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@findcontrol]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  (set %%powh="^!%%powh^!")^&set "%%paux=wmo.FindChildWindows(^!%%powh^!, ^!%%pcls^!, ^!%%pcap^!, True)"^&^
  (^
   (echo Dim h, n : h = ^^^!%%paux^^^!)^&^
   (if defined %%ptmw (^
    (echo n = ^^^!%%ptmw^^^! \ 75)^&^
    (echo For i = 0 To CLng^^^!%%plbr^^^!n^^^!%%prbr^^^!)^&^
    (echo  If Len^^^!%%plbr^^^!h^^^!%%prbr^^^! Then Exit For)^&^
    (echo  WScript.Sleep^^^!%%plbr^^^!75^^^!%%prbr^^^! : h = ^^^!%%paux^^^!)^&^
    (echo Next)^
   ))^&^
   (echo WScript.Echo Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!h^^^!%%prbr^^^! ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^!)^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do if not %%a=="" (set "%%pwhv=%%~a")^
  ) ^|^| (echo Error [@findcontrol]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (set "^!%%prsn^!=1") else (set "^!%%prsn^!=0"))^&^
   set "^!%%pwhn^!=^!%%pwhv^!"^&^
   (for %%a in (amp,aux,cap,cls,eco,fnm,lbr,owh,quo,rbr,rsn,tmp,tmw,whn,whv) do (set "wds_fcw_%%a="))^
  ) else (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (echo "^!%%prsn^!=1") else (echo "^!%%prsn^!=0"))^&^
   echo "^!%%pwhn^!=^!%%pwhv^!"^
  ))^
 ) else (echo Error [@findcontrol]: Absent parameters.^&exit /b 1)) else set wds_fcw_aux=
 
::         @closewindow - closes (destroys) or minimizes window with given handle depending on parameter.
::                        %~1 == variable name with handle of window or its explicit digital value in quotation marks;
::                        %~2 == [optional: key parameter to destroy the window (`1`, default), `0` for minimizing].
::                  Note: macro doesn't return any values.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @closewindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cmw_aux for /F %%p in ('echo wds_cmw') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux=%%~a"^&(if not "^!%%p_aux^!"=="%%~a" (echo Error [@closewindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%c in ("hdl=0","des=1") do (set "%%p_%%~c"))^&^
   (if defined %%p_aux (^
    (if not "%%~a"==%%a (set "%%p_aux=^!%%~a^!"))^&^
    (for /F "tokens=* delims=+,-,0" %%c in ('echo.%%%%p_aux%%') do (^
     for /F "tokens=* delims=0123456789" %%d in ('echo.%%c?') do if "%%d"=="?" (set "%%p_hdl=%%~c")^
    ))^
   ))^&^
   (if ^^^!%%p_hdl^^^! EQU 0 (echo Error [@closewindow]: The 1st parameter is undefined or has non-digital value.^&exit /b 1))^&^
   (if not "%%~b"=="" (^
    (set /a "%%p_aux=0x%%~b"^>NUL 2^>^&1) ^&^& (if ^^^!%%p_aux^^^! EQU 0 (set "%%p_des=0"))^
   ))^
  ))^&(if not defined %%p_des (echo Error [@closewindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@closewindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  (if ^^^!%%p_des^^^! NEQ 0 (set "%%p_aux=CloseWindow") else (set "%%p_aux=MinimizeWindow"))^&^
  echo wmo.^^^!%%p_aux^^^! "^!%%p_hdl^!" : WScript.Echo "0"^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL)^
  ) ^|^| (echo Error [@closewindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,des,fnm,hdl) do (set "%%p_%%a="))^
 ) else (echo Error [@closewindow]: Absent parameters.^&exit /b 1)) else set wds_cmw_aux=
 
::         @showdesktop - macro minimizes all windows & shows desktop.
::                  Note: macro doesn't return any values & has not parameters.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @showdesktop=^
 (for /F %%p in ('echo wds_sdt') do (^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@showdesktop]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_lbr=("^&set "%%p_rbr=)"^&^
  echo Dim hdl^>^>"^!%%p_fnm^!"^&^
  echo hdl = wmo.FindWindow^^^!%%p_lbr^^^!"Shell_TrayWnd", ""^^^!%%p_rbr^^^!^>^>"^!%%p_fnm^!"^&^
  echo Call wmo.SendMessage^^^!%%p_lbr^^^!hdl, 273, 419, 0^^^!%%p_rbr^^^!^>^>"^!%%p_fnm^!"^&^
  echo WScript.Echo "0"^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   (for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL))^
  ) ^|^| (echo Error [@showdesktop]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (fnm,lbr,rbr) do (set "%%p_%%a="))^
 ))
 
::             @repaint - repaints specified window or desktop.
::                        %~1 == [optional: name of variable with window handle or its value in quotation marks, default is `0`].
::             Notes. #1: macro doesn't return any values;
::                    #2: the call with `0` handle value updates desktop.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @repaint=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%p in ('echo wds_rep') do (^
  set "%%p_hdl=0"^&(if not "^!%%p_hdl^!"=="0" (echo Error [@repaint]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  (if defined %%p_aux for /F %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux="^&(if "%%~a"==%%a (set "%%p_aux=%%~a") else if defined %%~a (set "%%p_aux=^!%%~a^!"))^&^
   (if defined %%p_aux (^
    (for /F "tokens=* delims=+,-,0" %%b in ('echo.%%%%p_aux%%') do (^
     for /F "tokens=* delims=0123456789" %%c in ('echo.%%b?') do if "%%c"=="?" (set "%%p_hdl=%%~b")^
    ))^&^
    (if ^^^!%%p_hdl^^^! EQU 0 (echo Error [@repaint]: Parameter has non-digital value.^&exit /b 1))^
   ) else (echo Error [@repaint]: The 1st parameter is undefined.^&exit /b 1))^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@repaint]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  (set %%p_hdl="^!%%p_hdl^!")^&(set "%%p_aux=(^!%%p_hdl^!)")^&^
  (if ^^^!%%p_hdl^^^! NEQ 0 (echo If wmo.IsWindow^^^!%%p_aux^^^! Then^>^>"^!%%p_fnm^!"))^&^
  echo  wmo.Repaint^^^!%%p_aux^^^!^>^>"^!%%p_fnm^!"^&^
  (if ^^^!%%p_hdl^^^! NEQ 0 (echo End If^>^>"^!%%p_fnm^!"))^&^
  echo WScript.Echo "0"^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL)^
  ) ^|^| (echo Error [@repaint]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,fnm,hdl) do (set "%%p_%%a="))^
 )) else set wds_rep_aux=
  
::        @windowsofpid - returns window handles of the process with given identifier (PID).
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~3`;
::                        %~2 == name of variable with PID or its digital value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == variable name to return handles to windows, if absent it will return result into `%~1`;
::                      2:%~4 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: if the process hosts several windows, their handles will be separated by comma symbol in result;
::                    #2: for zero value of handle it returns window handles of the process hosting current process.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @windowsofpid=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gwp_aux for /F %%p in ('echo wds_gwp_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%paux%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@windowsofpid]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%ppid="^&set "%%paux=0"^&(if "%%~b"==%%b (set "%%paux=%%~b") else if defined %%~b (set "%%paux=^!%%~b^!"))^&^
   ((set /a "%%ptmp=0x^!%%paux^!"^>NUL 2^>^&1)^>NUL ^&^& (set "%%ppid=^!%%paux^!"))^&^
   (if not defined %%ppid (echo Error [@windowsofpid]: The 2nd parameter is undefined or has non-digital value of PID.^&exit /b 1))^&^
   (for %%e in ("whn=","whv=-1","eco=0") do (set "wds_gwp_%%~e"))^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%paux=%%e"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%pwhn=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=^!%%ptmp^!"))^
     ))^
    ))^
   ))^&^
   (if not defined %%pwhn (set "%%pwhn=^!%%prsn^!"^&set "%%prsn="))^
  ))^&(if not defined %%peco (echo Error [@windowsofpid]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@windowsofpid]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%plbr=("^&set "%%prbr=)"^&(set %%paux="^^^&")^&(call set "%%paux=%%%%paux:~-2,1%%")^&^
  (echo str = "%%pwhv=" ^^^!%%paux^^^! CStr^^^!%%plbr^^^!wmo.WindowsOfPid^^^!%%plbr^^^!^^^!%%ppid^^^!^^^!%%prbr^^^!^^^!%%prbr^^^! : Err.Clear : WScript.Echo str : WScript.Quit 0)^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do (set "%%a")^&echo.^>nul^
  ) ^|^| (echo Error [@windowsofpid]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%pwhv^^^! LSS 0 (echo Error [@windowsofpid]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (set "^!%%prsn^!=1") else (set "^!%%prsn^!=0"))^&^
   set "^!%%pwhn^!=^!%%pwhv^!"^&^
   (for %%a in (aux,eco,fnm,lbr,pid,rbr,rsn,tmp,whn,whv) do (set "wds_gwp_%%a="))^
  ) else (^
   (if defined %%prsn if ^^^!%%pwhv^^^! EQU 0 (echo "^!%%prsn^!=1") else (echo "^!%%prsn^!=0"))^&^
   echo "^!%%pwhn^!=^!%%pwhv^!"^
  ))^
 ) else (echo Error [@windowsofpid]: Absent parameters.^&exit /b 1)) else set wds_gwp_aux=

::         @pidofwindow - returns identifier (PID) of the process hosting window with given handle.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~3`;
::                        %~2 == name of variable with window handle or its digital value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == variable name to return PID, if absent it will return result into `%~1`;
::                      2:%~4 == key parameter to echo result instead of assigning (`1`), default is `0`.
::                  Note: for zero value of handle it returns PID of window process hosting current process.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @pidofwindow=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gpw_aux for /F %%p in ('echo wds_gpw_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%paux%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@pidofwindow]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%e in ("pin=","piv=-1","eco=0","hdl=","aux=0") do (set "wds_gpw_%%~e"))^&^
   (if "%%~b"==%%b (set "%%paux=%%~b") else if defined %%~b (set "%%paux=^!%%~b^!"))^&^
   (for /F "tokens=* delims=+,-,0" %%e in ('echo.%%%%paux%%') do if "%%~e"=="" (set "%%phdl=0") else (^
    for /F "tokens=* delims=0123456789" %%f in ('echo.%%e?') do if "%%f"=="?" (set "%%phdl=%%~e")^
   ))^&^
   (if not defined %%phdl (echo Error [@pidofwindow]: The 2nd parameter is undefined or has non-digital value of window handle.^&exit /b 1))^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%paux=%%e"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%ppin=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1) ^&^& (if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=^!%%ptmp^!"))^
     ))^
    ))^
   ))^&^
   (if not defined %%ppin (set "%%ppin=^!%%prsn^!"^&set "%%prsn="))^
  ))^&(if not defined %%peco (echo Error [@pidofwindow]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@pidofwindow]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%plbr=("^&set "%%prbr=)"^&^
  (echo WScript.Echo CStr^^^!%%plbr^^^!wmo.PidOfWindow^^^!%%plbr^^^!"^!%%phdl^!"^^^!%%prbr^^^!^^^!%%prbr^^^!^>^>"^!%%pfnm^!")^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do (set "%%ppiv=%%a")^
  ) ^|^| (echo Error [@pidofwindow]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%ppiv^^^! LSS 0 (echo Error [@pidofwindow]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 (^
   (if defined %%prsn if ^^^!%%ppiv^^^! EQU 0 (set "^!%%prsn^!=1") else (set "^!%%prsn^!=0"))^&^
   set "^!%%ppin^!=^!%%ppiv^!"^&^
   (for %%a in (aux,eco,fnm,hdl,lbr,pin,piv,rbr,rsn,tmp) do (set "wds_gpw_%%a="))^
  ) else (^
   (if defined %%prsn if ^^^!%%ppiv^^^! EQU 0 (echo "^!%%prsn^!=1") else (echo "^!%%prsn^!=0"))^&^
   echo "^!%%ppin^!=^!%%ppiv^!"^
  ))^
 ) else (echo Error [@pidofwindow]: Absent parameters.^&exit /b 1)) else set wds_gpw_aux=

::           @coprocess - returns PID of child or parent process depending on parameterization.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `2:%~3`;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == name of variable with PID or its value in quotation marks, default is current PID;
::                      2:%~3 == variable name to return PID, if absent it will return result into `%~1`;
::                      3:%~4 == key parameter to return parent PID (`1`), default is `0` to return child PID;
::                      4:%~5 == name of variable with full name of target running module or its quoted value;
::                      5:%~6 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @echo_params, @obj_newname.
::
set @coprocess=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cgp_a for /F %%p in ('echo wds_cgp_') do (^
  (for /F "tokens=1,2,3,4,5,6" %%a in ('echo.%%%%pa%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@coprocess]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%pmod=*"^&(for %%e in ("psn=","pid=0","par=0","eco=0","a=0") do (set "wds_cgp_%%~e"))^&^
   (for /F %%g in ('cmd /d /q /r "^!@echo_params^! 5 %%b %%c %%d %%e %%f"') do if not "%%~g"=="" (^
    set "%%pa=%%g"^&set "%%pt=^!%%pa:~2^!"^&^
    (if defined %%pt (set /a "%%pa=0x^!%%pa:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (echo ",1,4," ^| findstr /C:",^!%%pa^!,")^>NUL ^&^& (^
      (if ^^^!%%pa^^^! EQU 1 (set "%%pa=pid") else (set "%%pa=mod"))^&^
      (if "^!%%pt:~1,-1^!"==^^^!%%pt^^^! (set "%%p^!%%pa^!=^!%%pt:~1,-1^!") else if defined %%pt (call set "%%p^!%%pa^!=%%^!%%pt^!%%"))^&^
      (if "^!%%pa^!"=="pid" (^
       (for /F "tokens=* delims=+,-,0" %%h in ('echo.%%%%ppid%%') do if "%%~h"=="" (set "%%ppid=0") else (^
        for /F "tokens=* delims=0123456789" %%i in ('echo.%%h?') do if "%%i"=="?" (set "%%ppid=%%~h") else (set "%%ppid=0")^
       ))^&^
       (if ^^^!%%ppid^^^! EQU 0 (echo Error [@coprocess]: The parameter #1:2 is undefined or has non-digital value of the target process PID.^&exit /b 1))^
      ))^
     ) ^|^| (if ^^^!%%pa^^^! EQU 2 (^
      set "%%ppsn=^!%%pt^!"^
     ) else if ^^^!%%pt^^^! EQU 1 (^
      if ^^^!%%pa^^^! EQU 3 (set "%%ppar=1") else if ^^^!%%pa^^^! EQU 5 (set "%%peco=1")^
     ))^
    ))^
   ))^&^
   (if not defined %%ppsn (set "%%ppsn=^!%%prsn^!"^&set "%%prsn="))^
  ))^&(if not defined %%peco (echo Error [@coprocess]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@coprocess]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%plbr=("^&set "%%prbr=)"^&^
  (echo WScript.Echo CStr^^^!%%plbr^^^!wmo.CognateProc^^^!%%plbr^^^!^^^!%%ppid^^^!, "^!%%pmod^!", ^^^!%%ppar^^^!^^^!%%prbr^^^!^^^!%%prbr^^^!^>^>"^!%%pfnm^!")^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do (set "%%ppsv=%%a")^
  ) ^|^| (echo Error [@coprocess]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%ppsv^^^! LSS 0 (echo Error [@coprocess]: Failed to get result.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 (^
   (if defined %%prsn if ^^^!%%ppsv^^^! EQU 0 (set "^!%%prsn^!=1") else (set "^!%%prsn^!=0"))^&^
   set "^!%%ppsn^!=^!%%ppsv^!"^&^
   (for %%a in (a,eco,fnm,lbr,mod,par,pid,psn,psv,rbr,rsn,t) do (set "wds_cgp_%%a="))^
  ) else (^
   (if defined %%prsn if ^^^!%%ppsv^^^! EQU 0 (echo "^!%%prsn^!=1") else (echo "^!%%prsn^!=0"))^&^
   echo "^!%%ppsn^!=^!%%ppsv^!"^
  ))^
 ) else (echo Error [@coprocess]: Absent parameters.^&exit /b 1)) else set wds_cgp_a=
 
::          @screenshot - takes a screenshot of a window or screen and saves it to a file.
::                      Optional parameters with digital values, must follow internal identifier and marker ":":
::                      1:%~1 == identifier of monitor, default is `1`;
::                      2:%~2 == handle of window, default is `0` to do screenshot;
::                      3:%~3 == full file name to store snapshot, default is current folder & file name "snapshotYYMMddHHmmss.jpg";
::                      4:%~4 == take full snapshot `1`, default is `0` for client area only.
::             Notes. #1: macro doesn't return any values;
::                    #2: all parameters can be variable names with values or explicit values in quotation marks;
::                    #3: if `3:%~3` has explicit value the space symbols must be replaced by `/CHR{20}`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @screenshot=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%p in ('echo wds_spj') do (^
  (for %%a in ("mid=1","hdl=0","fil=""","ful=0") do (set "%%p_%%~a"))^&(if not "^!%%p_mid^!"=="1" (echo Error [@screenshot]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  (set %%p_quo="")^&(set %%p_lbr="(")^&(set %%p_rbr=")")^&(for %%a in (quo lbr rbr) do (call set "%%p_%%a=%%%%p_%%a:~-2,1%%"))^&^
  (if defined %%p_aux for /F "tokens=1,2,3,4" %%a in ('echo.%%%%p_aux%%') do (^
   (for %%e in (%%~a,%%~b,%%~c,%%~d) do if not "%%e"=="" (^
    set "%%p_aux=%%e"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     set "%%p_cnt=1"^&^
     (for %%f in (mid,hdl,fil,ful) do (^
      (if ^^^!%%p_aux^^^! EQU ^^^!%%p_cnt^^^! for /F %%g in ('echo.%%%%p_tmp%%') do (^
       set "%%p_tmp="^&(if "%%~g"==%%g (set "%%p_tmp=%%~g") else if defined %%~g (set "%%p_tmp=^!%%~g^!"))^&^
       (if defined %%p_tmp (^
        (if ^^^!%%p_aux^^^! EQU 1 (^
         set "%%p_%%f="^&^
         (for /F "tokens=* delims=+,-,0" %%h in ('echo.%%%%p_tmp%%') do if "%%~h"=="" (set "%%p_%%f=0") else (^
          for /F "tokens=* delims=0123456789" %%i in ('echo.%%h?') do if "%%i"=="?" (set "%%p_%%f=%%~h")^
         ))^
        ) else if ^^^!%%p_aux^^^! EQU 3 (^
         (call set %%p_%%f=%%%%p_tmp:^^^!%%p_quo^^^!=%%)^&(set %%p_%%f="^!%%p_%%f:/CHR{20}= ^!")^
        ) else (^
         (set /a "%%p_aux=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (set "%%p_%%f=^!%%p_tmp^!") ^|^| (set "%%p_%%f=")^
        ))^&^
        (if not defined %%p_%%f (echo Error [@screenshot]: Expected decimal value in parameter #^^^!%%p_cnt^^^!.^&exit /b 1))^
       ))^
      ))^&^
      set /a "%%p_cnt+=1"^>NUL^
     ))^
    ))^
   ))^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@screenshot]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  echo wmo.ScreenShot ^^^!%%p_mid^^^!, "^!%%p_hdl^!", ^^^!%%p_fil^^^!, ^^^!%%p_ful^^^! : WScript.Echo "0"^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>nul)^
  ) ^|^| (echo Error [@screenshot]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,cnt,fil,fnm,ful,hdl,lbr,mid,quo,rbr,tmp) do (set "%%p_%%a="))^
 )) else set wds_spj_aux=
 
::        @compareshots - performs a byte comparison of the data of two screenshots.
::                        %~1 == variable name to return result ('0' - all data bytes match, otherwise `1`, @mac_check compatible);
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == identifier of monitor, default is `1` (variable name or quoted value);
::                      2:%~3 == handle of window, default is `0` to do screen shot (variable name or quoted value);
::                      3:%~4 == full file name to store snapshots, default is %TEMP% folder & file name:
::                      "wait.mds.auxiliary.file.screenshot.id[Current window handle][Current window PID][Target window PID].jpg"
::                             - where expression in brackets contains value in the form of number in 64-base radix (see @radix);
::                      4:%~5 == name of variable to return detailed result of data comparison:
::                            `0`- the data scan didn't reveal different bytes                                            - PASS;
::                            `1`- files have different bytes                                                             - PASS;
::                            `2`- the size of one of files changed while reading its data, or an error reading the data - ERROR;
::                            `3`- the sizes of two files are different                                                   - PASS;
::                            `4`- one of the files is unreadable                                                        - ERROR;
::                            `5`- one of the files was not found                                     - no data to compare, FAIL;
::                            `6`- the window with given handle doesn't exist       - not available to get data to compare, FAIL;
::                            `7`- vbscript raised exception                                                              - FAIL;
::                               - it stops in the case of error with its message;
::                      5:%~6 == digital value of the target window process id, serves to get default file identifier (note #5);
::                      6:%~7 == key parameter to do only deletion of temporary file (`1`), default is `0`;
::                      7:%~8 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: Parameter `3:%~4` can have quoted explicit string, but all space symbols must be replaced by `/CHR{20}`;
::                    #2: For comparison it always takes snapshots of client area of the window or of the screen (without bars);
::                    #3: The 1st call serves to create temporary comparison file, it returns `1` into `%~1`, code `5` to `4:%~5`;
::                    #4: The default temporary file name allows to store only one screenshot per application process, if it has
::                        multiple windows to track, use custom temp files for other additional windows;
::                    #5: Parameters `5:%~6`, `6:%~7` apply only to temporary files with default name to create target identifier:
::                      - if `5:%~6` not defined, the deletion of file requires existing target window and process (`2:%~3`);
::                      - if `5:%~6` not defined, macro requires the same value of `2:%~3` that was used for its creation;
::                      - to find file for already closed window or process use `5:%~6` parameter with PID value;
::                      - parameter `5:%~6` can be used for comparison calls & for calls to delete file at the end.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @compareshots=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_css_3 for /F %%y in ('echo wds_css_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%y3%%') do (^
   (for %%i in ("1=Error [@compareshots]: ","2=WScript.Echo ","r=%%~a","m="1"","h="0"","f=""","t=","d=0","i="0"","e=0","7=") do (set "wds_css_%%~i"))^&^
   (if not "^!%%ye^!"=="0" (call echo %%%%y1%%Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%yr (echo ^^^!%%y1^^^!The parameter #1 value has incorrect ms-dos name.^&exit /b 1))^&^
   (for %%i in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h) do if not "%%i"=="" (^
    set "%%y3=%%i"^&set "%%y4=^!%%y3:~2^!"^&^
    (if defined %%y4 (set /a "%%y3=0x^!%%y3:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
           (if ^^^!%%y3^^^! EQU 1 (set "%%y7=m"^
     ) else if ^^^!%%y3^^^! EQU 2 (set "%%y7=h"^
     ) else if ^^^!%%y3^^^! EQU 3 (set "%%y7=f"^
     ) else if ^^^!%%y3^^^! EQU 4 (set "%%y7=t"^
     ) else if ^^^!%%y3^^^! EQU 5 (set "%%y7=i"^
     ) else if ^^^!%%y3^^^! EQU 6 (set "%%y7=d"^
     ) else if ^^^!%%y3^^^! EQU 7 (set "%%y7=e"))^&^
     (if defined %%y7 (^
      (if ^^^!%%y3^^^! LSS 6 (set "%%y^!%%y7^!=^!%%y4^!") else if ^^^!%%y4^^^! EQU 1 (set "%%y^!%%y7^!=1"))^&^
      set "%%y7="^
     ))^
    ))^
   ))^
  ))^&(if not defined %%ye (echo Error [@compareshots]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%y5="")^&set "%%y6=1^^^&1"^&(for %%a in (5 6) do (call set "wds_css_%%a=%%wds_css_%%a:~-2,1%%"))^&^
  set "%%y3=1"^&^
  (for %%a in (m,h,i,f,r,t) do for /F %%b in ('echo.%%wds_css_%%a%%') do (^
   (if ^^^!%%y3^^^! LSS 5 (^
    (if "%%~b"==%%b (set "wds_css_%%a=%%~b") else (set "wds_css_%%a=^!%%~b^!"))^&^
    (if ^^^!%%y3^^^! LSS 4 (^
     set "%%y4="^&^
     (for /F "tokens=* delims=+,-,0" %%c in ('echo.%%wds_css_%%a%%') do if "%%~c"=="" (set "%%y4=0") else (^
      set "%%y4="^&(for /F "tokens=* delims=0123456789" %%d in ('echo.%%c?') do if "%%d"=="?" (set "%%y4=%%~c"))^
     ))^&^
     (if defined %%y4 (set "wds_css_%%a=^!%%y4^!") else (^
      (for %%c in ("1=1:2","2=2:3","3=5:6") do (set "%%y3=^!%%y3:%%~c^!"))^&^
      echo ^^^!%%y1^^^!Parameter #^^^!%%y3^^^! undefined or has unexpected value.^&exit /b 1^
     ))^
    ) else (^
     (if defined wds_css_%%a (^
      call set "wds_css_%%a=%%wds_css_%%a:^!%%y5^!=%%"^&set "wds_css_%%a=^!wds_css_%%a:\\=\^!"^&(set %%yf="^!%%yf:/CHR{20}= ^!")^
     ) else (set %%yf=""))^
    ))^
   ) else if defined wds_css_%%a (set "wds_css_%%a=%%~b"))^&^
   set /a "%%y3+=1"^>NUL^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo ^^^!%%y1^^^!COM registration failed.^&exit /b 1) else (set %%a))^&set "%%y9=%%a"^
  ))^&^
  (set %%yh="^!%%yh^!")^&(set %%y6="^!%%y6^!")^&^
  (for /F "tokens=1,2,3" %%a in ('"echo ( ) ^!%%y6^!"') do (^
   (echo Dim r, t, m, h, tsn, f, sfn, sid, cwh, cwp, i)^&^
   (for %%d in (m,h,f) do if defined wds_css_%%d (echo %%d = ^^^!wds_css_%%d^^^!))^&^
   (if ^^^!%%yf^^^!=="" (^
    (for %%d in ("^!%%y9^!") do (echo tsn = "%%~dd%%~pd"))^
   ) else (^
    (for %%d in ("^!%%yf:~1,-1^!") do (echo tsn = "%%~dd%%~pd"))^
   ))^&^
   (set %%y3="0000000000000000")^&^
   (set %%y4="wait.mds.auxiliary.file.screenshot.id")^&^
   (if ^^^!%%yf^^^!=="" (^
    (if ^^^!%%yi^^^! EQU 0 (^
     (echo If Len%%ah%%b Then)^&^
     (echo  i = wmo.PidOfWindow%%ah%%b)^&^
     (echo  If CLng%%ai%%b = 0 Then)^&^
     (echo   ^^^!%%y2^^^!"%%y3=2" : r = 1 : t = 6)^&^
     (for %%d in (r,t) do if defined wds_css_%%d (^
      (echo   ^^^!%%y2^^^!"^!wds_css_%%d^!=" %%~c CStr%%a%%d%%b)^
     ))^&^
     (echo   WScript.Quit 0)^&^
     (echo  End If)^&^
     (echo Else)^&^
     (echo  i = 0)^&^
     (echo End If)^
    ) else (^
     (echo i = ^^^!%%yi^^^!)^
    ))^&^
    (echo cwp = wmo.PidOfWindow%%a0%%b : cwh = Split%%awmo.WindowsOfPid%%a0%%b, ","%%b%%a0%%b)^&^
    (echo sid = wmo.StrRadix%%a1, 10, "", "", cwh, 1, 16, "", "", -1%%b)^&^
    (echo sid = sid %%~c Right%%a^^^!%%y3^^^! %%~c Hex%%acwp%%b, 8%%b %%~c Right%%a^^^!%%y3^^^! %%~c Hex%%ai%%b, 8%%b)^&^
    (echo sid = wmo.StrRadix%%a1, 16, "", "", sid, 1, 64, "", "", -1%%b)^&^
    (echo If Err.Number Then ^^^!%%y2^^^!"%%y3=3" : ^^^!%%y2^^^!Err.Message : Err.Clear : WScript.Quit 0)^&^
    (echo f = ^^^!%%y4^^^! %%~c sid %%~c ".jpg")^
   ) else (^
    (echo sid = "")^
   ))^&^
   (echo For Each z In fso.GetFolder%%atsn%%b.Files)^&^
   (echo  If InStr%%az.Name, ^^^!%%y4^^^!%%b And InStr%%az.Name, sid%%b = 0 Then)^&^
   (echo   Dim cid : cid = Split%%aReplace%%az.Name, ^^^!%%y4^^^!, ""%%b, "."%%b%%a0%%b)^&^
   (echo   If Len%%acid%%b Then)^&^
   (echo    cid = wmo.StrRadix%%a1, 64, "", "", cid, 1, 16, "", "", -1%%b)^&^
   (echo    If Err.Number Then)^&^
   (echo     Err.Clear : cid = "")^&^
   (echo    Else)^&^
   (echo     cid = Right%%a^^^!%%y3^^^! %%~c cid, 32%%b)^&^
   (echo     cwh = wmo.StrRadix%%a1, 16, "", "", Left%%acid, 16%%b, 1, 10, "", "", -1%%b)^&^
   (echo     If wmo.IsWindow%%acwh%%b Then)^&^
   (echo      cwp = CLng%%a"%%~cH" %%~c Mid%%acid, 17, 8%%b%%b)^&^
   (echo      If Len%%awmo.WindowsOfPid%%acwp%%b%%b Then)^&^
   (echo       Dim tpi : tpi = CLng%%a"%%~cH" %%~c Right%%acid, 8%%b%%b)^&^
   (echo       cid = wmo.WindowsOfPid%%atpi%%b)^&^
   (echo      Else)^&^
   (echo       cid = "")^&^
   (echo      End If)^&^
   (echo     Else)^&^
   (echo      cid = "")^&^
   (echo     End If)^&^
   (echo    End If)^&^
   (echo   End If)^&^
   (echo   If cid = "" Then fso.DeleteFile tsn %%~c z.Name)^&^
   (echo  End If)^&^
   (echo Next)^&^
   (if ^^^!%%yd^^^! EQU 0 (^
    (echo sfn = tsn %%~c f %%~c ".bak")^&^
    (echo wmo.ScreenShot ^^^!%%ym^^^!, h, sfn, True : If Err.Number Then Err.Clear)^&^
    (echo If fso.FileExists%%asfn%%b Then)^&^
    (echo  t = wmo.CompareFileBytes%%asfn, tsn %%~c f%%b)^&^
    (echo  If Err.Number Then)^&^
    (echo   t = 7 : sfn = Err.Message : Err.Clear)^&^
    (echo  Else)^&^
    (echo   Select Case t)^&^
    (echo   Case 2 : sfn = "Volatile data")^&^
    (echo   Case 4 : sfn = "Unreadable data")^&^
    (echo   Case Else : sfn = "")^&^
    (echo   End Select)^&^
    (echo  End If)^&^
    (echo  ^^^!%%y2^^^!"%%y3=1" : ^^^!%%y2^^^!tsn %%~c f)^&^
    (echo End If)^&^
    (echo If Len%%asfn%%b Then ^^^!%%y2^^^!"%%y3=3" : ^^^!%%y2^^^!sfn : WScript.Quit 0 Else ^^^!%%y2^^^!"%%y3=2")^&^
    (echo If t = 1 Or t = 3 Then r = 0 Else If t Then r = 1 Else r = 0)^
   ) else (^
    (for %%d in ("If Err.Number Then"," t = 7 : r = 1 : Err.Clear","Else"," t = 0 : r = 0","End If") do (echo %%~d))^&^
    (echo ^^^!%%y2^^^!"%%y3=1" : ^^^!%%y2^^^!tsn %%~c f)^
   ))^&^
   (for %%d in (r,t) do if defined wds_css_%%d (^
    (echo ^^^!%%y2^^^!"^!wds_css_%%d^!=" %%~c CStr%%a%%d%%b)^
   ))^
  ))^>^>"^!%%y9^!"^&^
  set "%%y3=%%y3"^&^
  ((call move /y "^!%%y9^!" "^!%%y9:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%y9:~0,-4^!"') do (^
    (if "^!%%y3^!"=="%%y3" (^
     set "%%a"^
    ) else if ^^^!%%y3^^^! EQU 1 (^
     (if ^^^!%%yd^^^! EQU 0 (^
      if exist "%%a.bak" (move /y "%%a.bak" "%%a")^>nul^
     ) else (^
      if exist "%%a" (call del /f /a /q "%%a")^>nul^
     ))^&^
     set "%%y3=%%y3"^
    ) else if ^^^!%%y3^^^! EQU 2 (^
     (if ^^^!%%ye^^^! EQU 0 (set "%%a") else (echo "%%a"))^
    ) else (^
     echo ^^^!%%y1^^^!%%a.^&exit /b 1^
    ))^
   )^
  ) ^|^| (echo ^^^!%%y1^^^!R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%ye^^^! NEQ 1 for %%a in (1,2,3,4,5,6,9,d,e,h,m,i,r,f,t) do (set "wds_css_%%a="))^
 ) else (echo Error [@compareshots]: Absent parameters.^&exit /b 1)) else set wds_css_3=

::           @cursorpos - returns absolute coordinates of mouse pointer (cursor), moves it at another point if specified.
::                        %~1 == variable name to return horizontal X-coordinate or to move it to this value;
::                        %~2 == variable name to return vertical Y-coordinate or to move it to this value;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == key parameter to move pointer to coordinates `%~1` & `%~2` (`1`), default is `0`;
::                      2:%~4 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @cursorpos=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mcp_aux for /F %%p in ('echo wds_mcp') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_xpn=%%~a"^&(if not "^!%%p_xpn^!"=="%%~a" (echo Error [@cursorpos]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if "%%~b"=="" (echo Error [@cursorpos]: The 2nd parameter is undefined.^&exit /b 1))^&^
   (for %%e in ("xpv=","ypv=","ncp=0","eco=0") do (set "%%p_%%~e"))^&^
   set "%%p_ypn=%%~b"^&(if defined %%~a (set "%%p_xpv=^!%%~a^!"))^&(if defined %%~b (set "%%p_ypv=^!%%~b^!"))^&^
   (for %%e in (%%~c,%%~d) do if not "%%e"=="" (^
    set "%%p_aux=%%e"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%p_tmp^^^! EQU 1 (^
      (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_ncp=1") else if ^^^!%%p_aux^^^! EQU 2 (set "%%p_eco=1"))^
     ))^
    ))^
   ))^&^
   set "%%p_aux=1"^&^
   (if ^^^!%%p_ncp^^^! EQU 1 for %%e in (xp,yp) do (^
    (if defined ^^^!%%p_%%en^^^! (^
     (call set /a "%%p_tmp=0x%%^!%%p_%%en^!%%"^>NUL 2^>^&1)^>NUL ^&^& (call set "%%p_%%ev=%%^!%%p_%%en^!%%")^
    ))^&^
    (if defined %%p_%%ev (set /a "%%p_aux+=1")^>NUL else (echo Error [@cursorpos]: The parameter #^^^!%%p_aux^^^! is undefined or has non-digital value.^&exit /b 1))^
   ))^
  ))^&(if not defined %%p_eco (echo Error [@cursorpos]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@cursorpos]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_amp=1^^^&1"^&(set %%p_lbr="(")^&(set %%p_rbr=")")^&(for %%g in (amp lbr rbr) do (call set "%%p_%%g=%%%%p_%%g:~-2,1%%"))^&^
  echo Dim x, y^>^>"^!%%p_fnm^!"^&^
  (if ^^^!%%p_ncp^^^! NEQ 1 (set "%%p_aux=G") else (^
   (for %%a in ("x=^!%%p_xpv^!","y=^!%%p_ypv^!") do (echo %%~a^>^>"^!%%p_fnm^!"))^&set "%%p_aux=S"^
  ))^&^
  echo Call wmo.^^^!%%p_aux^^^!etCursorPos^^^!%%p_lbr^^^!x, y^^^!%%p_rbr^^^!^>^>"^!%%p_fnm^!"^&^
  (for %%a in (x,y) do (echo WScript.Echo "^!%%p_%%apn^!=" ^^^!%%p_amp^^^! CStr^^^!%%p_lbr^^^!%%a^^^!%%p_rbr^^^!^>^>"^!%%p_fnm^!"))^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do if ^^^!%%p_eco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@cursorpos]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 for %%a in (amp,aux,eco,fnm,lbr,ncp,rbr,tmp,xpn,xpv,ypn,ypv) do (set "%%p_%%a="))^
 ) else (echo Error [@cursorpos]: Absent parameters.^&exit /b 1)) else set wds_mcp_aux=
 
::          @mouseclick - emulates the mouse button click, if specified preliminary relocates pointer.
::                      Optional parameters with digital values, must follow internal identifier and marker ":":
::                      1:%~1 == number of button, which click will be emulated:
::                               `1`- left button, default value;
::                               `2`- middle button;
::                               `3`- right button;
::                      2:%~2 == sequence of emulated events:
::                               `1`- down & up of button, default value;
::                               `2`- button down (pressed);
::                               `3`- button up (released);
::                      3:%~3 == key parameter to move caret to coordinates `%~4:4` & `%~5:5` (`1`) before click, default is `0`;
::                      Next optional parameters valid only with `3:%~3` having `1`, must follow internal identifier and marker ":":
::                      4:%~4 == variable name with horizontal X-coordinate or its digital value in quotation marks;
::                      5:%~5 == variable name with vertical Y-coordinate or its digital value in quotation marks.
::                  Note: macro doesn't return any values.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @mouseclick=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%p in ('echo wds_mmc') do (^
  (if not defined %%p_aux (set %%p_aux=""))^&^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%p_aux%%') do (^
   set "%%p_aux=%%~a"^&(if not "^!%%p_aux^!"=="%%~a" (echo Error [@mouseclick]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (for %%e in ("nbn=1","bup=1","ncp=0","xmp=","ymp=") do (set "%%p_%%~e"))^&^
   (for %%f in (%%~a,%%~b,%%~c,%%~d,%%~e) do if not "%%f"=="" (^
    set "%%p_aux=%%f"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%p_aux^^^! LSS 4 (^
      set "%%p_bdn=1"^&^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if 0 LEQ ^^^!%%p_tmp^^^! if ^^^!%%p_tmp^^^! LEQ 3 (^
       (for %%g in (nbn,bup,ncp) do (^
        (if ^^^!%%p_aux^^^! EQU ^^^!%%p_bdn^^^! (^
         (if ^^^!%%p_aux^^^! LSS 3 (^
          (if 2 LEQ ^^^!%%p_tmp^^^! (set "%%p_%%g=^!%%p_tmp^!"))^
         ) else (^
          (if ^^^!%%p_tmp^^^! EQU 1 (set "%%p_%%g=1"))^
         ))^
        ))^&^
        set /a "%%p_bdn+=1"^>NUL^
       ))^
      ))^
     ) else (^
      set "%%p_bdn=4"^&^
      (for %%g in (xmp,ymp) do (^
       (if ^^^!%%p_aux^^^! EQU ^^^!%%p_bdn^^^! for /F %%h in ('echo ^^^!%%p_tmp^^^!') do (^
        set "%%p_tmp="^&(if "%%~h"==%%h (set "%%p_tmp=%%~h") else if defined %%~h (set "%%p_tmp=^!%%~h^!"))^&^
        (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (set "%%p_%%g=^!%%p_tmp^!"))^
       ))^&^
       set /a "%%p_bdn+=1"^>NUL^
      ))^
     ))^
    ))^
   ))^&^
   (if ^^^!%%p_ncp^^^! EQU 1 (^
    set "%%p_aux=1"^&(if defined %%p_xmp if defined %%p_ymp (set "%%p_aux="))^&^
    (if defined %%p_aux (echo Error [@mouseclick]: One of coordinate parameters has not valid digital value.^&exit /b 1))^
   ) else (^
    set "%%p_xmp=0"^&set "%%p_ymp=0"^
   ))^&^
   (if ^^^!%%p_bup^^^! EQU 3 (set "%%p_bdn=0") else (set "%%p_bdn=1"))^&^
   (if ^^^!%%p_bup^^^! EQU 2 (set "%%p_bup=0") else (set "%%p_bup=1"))^
  ))^&(if not defined %%p_nbn (echo Error [@mouseclick]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@mouseclick]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_aux=("^&set "%%p_tmp=)"^&^
  (echo Call wmo.MouseMoveClick^^^!%%p_aux^^^!^^^!%%p_nbn^^^!, ^^^!%%p_bdn^^^!, ^^^!%%p_bup^^^!, ^^^!%%p_ncp^^^!, ^^^!%%p_xmp^^^!, ^^^!%%p_ymp^^^!^^^!%%p_tmp^^^!)^>^>"^!%%p_fnm^!"^&^
  (echo WScript.Echo "0")^>^>"^!%%p_fnm^!"^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do (echo.^>NUL)^
  ) ^|^| (echo Error [@mouseclick]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (aux,bdn,bup,fnm,nbn,ncp,tmp,xmp,ymp) do (set "%%p_%%a="))^
 )) else set wds_mmc_aux=
 
::             @monitor - returns the id of the monitor matching the given request.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `1:%~3`;
::                        %~2 == type of query to search identifier of the monitor:
::                               `1`- hosting window with handle;
::                               `2`- containing point with absolute cooordinates;
::                               `3`- containing rectangle with absolute cooordinates and size;
::                      Optional parameter, must follow internal identifier and marker ":":
::                      1:%~3 == variable name to return identifier, if absent it will return result into `%~1`;
::                      Parameters with internal identifiers 2-5 are required & differs for every query, variables or quoted values:
::                            `1`- the monitor hosting window with handle, default `0` value for current window;
::                      2:%~4 == handle of window;
::                            `2`- the monitor containing point with absolute cooordinates:
::                      2:%~4 == X-coordinate of point;
::                      3:%~5 == Y-coordinate of point;
::                            `3`- the monitor containing rectangle with absolute cooordinates and size:
::                      2:%~4 == X-coordinate of the rectangle left side;
::                      3:%~5 == Y-coordinate of the rectangle top side;
::                      4:%~6 == width;
::                      5:%~7 == height;
::                      Optional parameter, must follow internal identifier and marker ":":
::                      6:%~8 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @monitor=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mon_aux for /F %%p in ('echo wds_mon_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%paux%%') do (^
   set "%%prsn=%%~a"^&(if not "^!%%prsn^!"=="%%~a" (echo Error [@monitor]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%pqtp="^&((set /a "%%ptmp=0x%%~b"^>NUL 2^>^&1)^>NUL ^&^& (if 1 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 3 (set "%%pqtp=^!%%ptmp^!")))^&^
   (if defined %%pqtp (^
    (if ^^^!%%pqtp^^^! EQU 1 (set "%%pamp=2") else if ^^^!%%pqtp^^^! EQU 2 (set "%%pamp=3") else (set "%%pamp=5"))^
   ) else (echo Error [@monitor]: The 2nd parameter has unknown type of query, accepted 1, 2 and 3.^&exit /b 1))^&^
   (for %%i in ("min=","miv=0","eco=0","pm2=0","pm3=","pm4=","pm5=") do (set "wds_mon_%%~i"))^&^
   (for %%i in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h) do if not "%%i"=="" (^
    set "%%paux=%%i"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%pmin=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 8 (^
      (set /a "%%ptmp=0x^!%%ptmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=1"))^
     ) else (^
      (for /L %%j in (2,1,^^^!%%pamp^^^!) do if ^^^!%%paux^^^! EQU %%j (^
       (for /F %%k in ('echo ^^^!%%ptmp^^^!') do (^
        set "%%paux="^&(if "%%~k"==%%k (set "%%paux=%%~k") else if defined %%~k (set "%%paux=^!%%~k^!"))^&^
        (if defined %%paux for /F "tokens=* delims=+,-,0" %%l in ('echo.%%%%paux%%') do if "%%~l"=="" (set "%%ppm%%j=0") else (^
         for /F "tokens=* delims=0123456789" %%m in ('echo.%%l?') do if "%%m"=="?" (set "%%ppm%%j=%%~l")^
        ))^
       ))^
      ))^
     ))^
    ))^
   ))^&^
   (for /L %%i in (2,1,^^^!%%pamp^^^!) do if not defined %%ppm%%i (echo Error [@monitor]: The parameter `%%i:[digit value]` is undefined or has non-valid value.^&exit /b 1))^
  ))^&(if not defined %%peco (echo Error [@monitor]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@monitor]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%pamp=1^^^&1"^&(set %%plbr="(")^&(set %%prbr=")")^&(for %%g in (amp lbr rbr) do (call set "wds_mon_%%g=%%wds_mon_%%g:~-2,1%%"))^&^
  (^
   (echo Dim id, ok : id = 0)^&^
   (if ^^^!%%pqtp^^^! EQU 1 (^
    (echo If ^^^!%%ppm2^^^! = 0 Or wmo.IsWindow^^^!%%plbr^^^!"^!%%ppm2^!"^^^!%%prbr^^^! Then)^&^
    (echo  id = wmo.MonitorFromWindow^^^!%%plbr^^^!"^!%%ppm2^!"^^^!%%prbr^^^!)^&^
    (echo End If)^
   ) else if ^^^!%%pqtp^^^! EQU 2 (^
    (echo id = wmo.MonitorFromPoint^^^!%%plbr^^^!^^^!%%ppm2^^^!, ^^^!%%ppm3^^^!^^^!%%prbr^^^!)^
   ) else (^
    (echo Dim r, b : r = ^^^!%%ppm2^^^! + ^^^!%%ppm4^^^! : b = ^^^!%%ppm3^^^! + ^^^!%%ppm5^^^!)^&^
    (echo id = wmo.MonitorFromRect^^^!%%plbr^^^!^^^!%%ppm2^^^!, ^^^!%%ppm3^^^!, r, b^^^!%%prbr^^^!)^
   ))^&^
   (echo id = id Mod 65536)^&^
   (if defined %%pmin (^
    (echo If id = 0 Then ok = 1 Else ok = 0)^&^
    (echo WScript.Echo "^!%%prsn^!=" ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!ok^^^!%%prbr^^^!)^&^
    set "%%paux=^!%%pmin^!"^
   ) else (^
    set "%%paux=^!%%prsn^!"^
   ))^&^
   (echo WScript.Echo "^!%%paux^!=" ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!id^^^!%%prbr^^^!)^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do if ^^^!%%peco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@monitor]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (amp,aux,eco,fnm,lbr,min,miv,pm2,pm3,pm4,pm5,qtp,rbr,rsn,tmp) do (set "wds_mon_%%a="))^
 ) else (echo Error [@monitor]: Absent parameters.^&exit /b 1)) else set wds_mon_aux=

::           @appbarect - returns rectangle of the application bar.
::                      Variable names to return absolute coordinates of its sides:
::                        %~1 == left;
::                        %~2 == top;
::                        %~3 == right;
::                        %~4 == bottom;
::                      Optional parameter:
::                        %~5 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @appbarect=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_abr_aux for /F %%p in ('echo wds_abr') do (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%p_aux%%') do (^
   (for %%f in ("lfn=%%~a","ton=%%~b","rin=%%~c","bon=%%~d","eco=0") do (set "%%p_%%~f"))^&^
   (if not "^!%%p_lfn^!"=="%%~a" (echo Error [@appbarect]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%p_aux=1"^&^
   (for %%f in (lf,to,ri,bo) do if defined %%p_%%fn (set /a "%%p_aux+=1"^>NUL) else (echo Error [@appbarect]: The result parameter #^^^!%%p_aux^^^! is undefined.^&exit /b 1))^&^
   (if not "%%~e"=="" ((set /a "%%p_aux=0x%%~e"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%p_aux^^^! EQU 1 (set "%%p_eco=1"))))^
  ))^&(if not defined %%p_eco (echo Error [@appbarect]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@appbarect]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_lbr=("^&set "%%p_rbr=)"^&^
  echo Dim lfv, tov, riv, bov^>^>"^!%%p_fnm^!"^&^
  echo wmo.AppBarRect lfv, tov, riv, bov^>^>"^!%%p_fnm^!"^&^
  set "%%p_aux=1^^^&1"^&call set "%%p_aux=%%%%p_aux:~-2,1%%"^&^
  (for %%a in (lf,to,ri,bo) do (^
   (echo WScript.Echo "^!%%p_%%an^!=" ^^^!%%p_aux^^^! CStr^^^!%%p_lbr^^^!%%av^^^!%%p_rbr^^^!)^>^>"^!%%p_fnm^!"^
  ))^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do if ^^^!%%p_eco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@appbarect]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 for %%a in (aux,bon,eco,fnm,lbr,lfn,rbr,rin,ton) do (set "%%p_%%a="))^
 ) else (echo Error [@appbarect]: Absent parameters.^&exit /b 1)) else set wds_abr_aux=
 
::          @screenrect - returns the monitor's client area rectangle, or the window rectangle inside the monitor's client area.
::                        %~1 == name of variable with identifier of monitor or its id value in quotation marks;
::                      Variable names to return absolute coordinates of sides:
::                        %~2 == left;
::                        %~3 == top;
::                        %~4 == right;
::                        %~5 == bottom;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~6 == name of variable with handle of window or its handle value in quotation marks;
::                      2:%~7 == key parameter to echo result instead of assigning (`1`), default is `0`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @screenrect=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_scr_aux for /F %%p in ('echo wds_scr') do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%p_aux%%') do (^
   (for %%h in ("lfn=%%~b","ton=%%~c","rin=%%~d","bon=%%~e","hdl=","eco=0") do (set "%%p_%%~h"))^&^
   (if not "^!%%p_lfn^!"=="%%~b" (echo Error [@screenrect]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%p_aux=2"^&(for %%h in (lf,to,ri,bo) do if defined %%p_%%hn (set /a "%%p_aux+=1"^>NUL) else (echo Error [@screenrect]: The result parameter #^^^!%%p_aux^^^! is undefined.^&exit /b 1))^&^
   set "%%p_mid=%%a"^&^
   (for %%h in (%%~f,%%~g) do if not "%%h"=="" (^
    set "%%p_aux=%%h"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%p_aux^^^! EQU 1 (^
      set "%%p_hdl=^!%%p_tmp^!"^
     ) else if ^^^!%%p_aux^^^! EQU 2 (^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%p_tmp^^^! EQU 1 (set "%%p_eco=1"))^
     ))^
    ))^
   ))^&^
   (for %%h in ("1~mid","6~hdl") do for /F "tokens=1,2 delims=~" %%i in ('echo %%~h') do if defined %%p_%%j for /F %%k in ('echo %%%%p_%%j%%') do (^
    set "%%p_%%j="^&set "%%p_aux="^&(if "%%~k"==%%k (set "%%p_aux=%%~k") else if defined %%~k (set "%%p_aux=^!%%~k^!"))^&^
    (if defined %%p_aux for /F "tokens=* delims=+,-,0" %%l in ('echo.%%%%p_aux%%') do (^
     for /F "tokens=* delims=0123456789" %%m in ('echo.%%l?') do if "%%m"=="?" (set %%p_%%j="%%~l")^
    ))^&^
    (if not defined %%p_%%j (echo Error [@screenrect]: Expected decimal non-zero value in parameter #%%i.^&exit /b 1))^
   ))^&^
   (if not defined %%p_hdl (set "%%p_hdl=0"))^
  ))^&(if not defined %%p_eco (echo Error [@screenrect]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@screenrect]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_lbr=("^&set "%%p_rbr=)"^&set "%%p_tmp=1^^^&1"^&call set "%%p_tmp=%%%%p_tmp:~-2,1%%"^&^
  (echo Dim lfv, tov, riv, bov)^>^>"^!%%p_fnm^!"^&^
  (echo wmo.ScreenClientArea ^^^!%%p_mid^^^!, ^^^!%%p_hdl^^^!, lfv, tov, riv, bov)^>^>"^!%%p_fnm^!"^&^
  (for %%a in (lf,to,ri,bo) do for /F "tokens=1,2" %%b in ('echo "^!%%p_%%an^!=" CStr^^^!%%p_lbr^^^!%%av^^^!%%p_rbr^^^!') do (^
   (echo WScript.Echo %%b ^^^!%%p_tmp^^^! %%c)^>^>"^!%%p_fnm^!"^
  ))^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do if ^^^!%%p_eco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@screenrect]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 for %%a in (aux,bon,eco,fnm,hdl,lbr,lfn,mid,rbr,rin,tmp,ton) do (set "%%p_%%a="))^
 ) else (echo Error [@screenrect]: Absent parameters.^&exit /b 1)) else set wds_scr_aux=
 
::          @screensize - returns the current screen resolution of the monitor, supports changing its resolution.
::                      Variable names with dimensions of screen:
::                        %~1 == width;
::                        %~2 == height;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == name of variable with identifier of monitor or its id value in quotation marks;
::                      2:%~4 == key parameter to changing resolution (`1`), default is `0` to read only;
::                      3:%~5 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: the call with '1:%~3' equal to `1` must have valid digital values in `%~1` & `%~2`;
::                    #2: if '1:%~3' equal to `1`, the `%~1` & `%~2` can be an explicit digital values in quotation marks;
::                    #3: if `%~1` & `%~2` are variable names, they always contain current screen resolution after completion.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @screensize=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_ssz_aux for /F %%p in ('echo wds_ssz') do (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%p_aux%%') do (^
   (for %%f in ("win=%%a","wiv=","hen=%%b","hev=","mid="1"","chg=0","eco=0") do (set "%%p_%%~f"))^&^
   (if not "^!%%p_chg^!"=="0" (echo Error [@screensize]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%p_aux=1"^&(for %%f in (wi,he) do if defined %%p_%%fn (set /a "%%p_aux+=1"^>NUL) else (echo Error [@screensize]: The parameter #^^^!%%p_aux^^^! is undefined.^&exit /b 1))^&^
   (for %%f in (%%~c,%%~d,%%~e) do if not "%%f"=="" (^
    set "%%p_aux=%%f"^&set "%%p_tmp=^!%%p_aux:~2^!"^&^
    (if defined %%p_tmp (set /a "%%p_aux=0x^!%%p_aux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%p_aux^^^! EQU 1 (^
      set "%%p_mid=^!%%p_tmp^!"^
     ) else (^
      (set /a "%%p_tmp=0x^!%%p_tmp^!"^>NUL 2^>^&1)^>NUL ^&^& (if ^^^!%%p_tmp^^^! EQU 1 (^
       (if ^^^!%%p_aux^^^! EQU 2 (set "%%p_chg=1") else if ^^^!%%p_aux^^^! EQU 3 (set "%%p_eco=1"))^
      ))^
     ))^
    ))^
   ))^&^
   (for %%f in ("1~win~wiv","2~hen~hev","3~mid~mid") do for /F "tokens=1,2,3 delims=~" %%h in ('echo %%~f') do if defined %%p_%%i for /F %%k in ('echo %%%%p_%%i%%') do (^
    set "%%p_aux="^&(if "%%~k"==%%k (set "%%p_%%i="^&set "%%p_aux=%%~k") else if defined %%~k (set "%%p_aux=^!%%~k^!"))^&^
    set "%%p_tmp="^&(if ^^^!%%p_chg^^^! EQU 1 (set "%%p_tmp=1") else if %%h EQU 3 (set "%%p_tmp=1"))^&^
    (if defined %%p_tmp (^
     set "%%p_%%j="^&^
     (if defined %%p_aux (set /a "%%p_tmp=0x^!%%p_aux^!"^>NUL 2^>^&1)^>NUL ^&^& (^
      if ^^^!%%p_tmp^^^! NEQ 0 (set "%%p_%%j=^!%%p_aux^!")^
     ))^&^
     (if not defined %%p_%%j (echo Error [@screensize]: Expected decimal non-zero value in parameter #%%h.^&exit /b 1))^
    ) else (set "%%p_%%j=0"))^
   ))^&^
   (if ^^^!%%p_chg^^^! EQU 0 (^
    set "%%p_aux=1"^&(for %%f in (wi,he) do if defined %%p_%%fn (set /a "%%p_aux+=1"^>NUL) else (echo Error [@screensize]: Undefined result variable in parameter #^^^!%%p_aux^^^!.^&exit /b 1))^
   ))^
  ))^&(if not defined %%p_eco (echo Error [@screensize]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@screensize]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%p_fnm=%%a"^
  ))^&^
  set "%%p_lbr=("^&set "%%p_rbr=)"^&set "%%p_tmp=1^^^&1"^&call set "%%p_tmp=%%%%p_tmp:~-2,1%%"^&^
  (echo Dim wi, he)^>^>"^!%%p_fnm^!"^&^
  (for %%a in (wi,he) do ((echo %%a = ^^^!%%p_%%av^^^!)^>^>"^!%%p_fnm^!"))^&^
  (if ^^^!%%p_chg^^^! EQU 1 (^
   (echo wmo.NewScreenResolution ^^^!%%p_mid^^^!, wi, he)^>^>"^!%%p_fnm^!"^
  ))^&^
  set "%%p_aux=1"^&^
  (if defined %%p_win if defined %%p_hen (^
   set "%%p_aux="^&^
   (echo wmo.GetScreenResolution ^^^!%%p_mid^^^!, wi, he)^>^>"^!%%p_fnm^!"^&^
   (for %%a in (wi,he) do for /F "tokens=1,2" %%b in ('echo "^!%%p_%%an^!=" CStr^^^!%%p_lbr^^^!%%a^^^!%%p_rbr^^^!') do (^
    (echo WScript.Echo %%b ^^^!%%p_tmp^^^! %%c)^>^>"^!%%p_fnm^!"^
   ))^
  ))^&^
  (if defined %%p_aux (echo WScript.Echo ".")^>^>"^!%%p_fnm^!")^&^
  ((call move /y "^!%%p_fnm^!" "^!%%p_fnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%p_fnm:~0,-4^!"') do if "%%~a"=="." (echo.^>nul) else (^
    if ^^^!%%p_eco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
   )^
  ) ^|^| (echo Error [@screensize]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%p_eco^^^! NEQ 1 for %%a in (aux,chg,eco,fnm,hen,hev,lbr,mid,rbr,tmp,win,wiv) do (set "%%p_%%a="))^
 ) else (echo Error [@screensize]: Absent parameters.^&exit /b 1)) else set wds_ssz_aux=

::        @movetoscreen - moves the window to the client area of the specified monitor.
::                        %~1 == name of variable with the handle of the window to be moved or its value in quotation marks;
::                      Optional parameter:
::                        %~2 == name of variable with identifier of monitor or its id value in quotation marks;
::                  Note: macro doesn't return any values.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @movetoscreen=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_mts_aux for /F %%y in ('echo wds_mts_') do (^
  (for /F "tokens=1,2" %%a in ('echo.%%%%yaux%%') do (^
   (for %%c in ("1=%%a","2="1"") do (set "%%y%%~c"))^&^
   (if not "^!%%y1^!"=="%%a" (echo Error [@movetoscreen]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%y1 (echo Error [@movetoscreen]: The parameter #1 is undefined.^&exit /b 1))^&^
   (if not "%%b"=="" (set "%%y2=%%b"))^&^
   (for %%c in (1,2) do (^
    (if defined %%y%%c for /F %%d in ('"echo %%%%y%%c%%"') do (^
     set "%%y%%c="^&set "%%yaux="^&(if "%%~d"==%%d (set "%%yaux=%%~d") else if defined %%~d (set "%%yaux=^!%%~d^!"))^&^
     (for /F "tokens=* delims=+,-,0" %%e in ('echo.%%%%yaux%%') do (^
      for /F "tokens=* delims=0123456789" %%f in ('echo.%%e?') do if "%%f"=="?" (set %%y%%c="%%~e")^
     ))^
    ))^&^
    (if not defined %%y%%c (echo Error [@movetoscreen]: Expected decimal non-zero value in parameter #%%c.^&exit /b 1))^
   ))^
  ))^&(if not defined %%y1 (echo Error [@movetoscreen]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@movetoscreen]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  (echo wmo.MoveToScrClient ^^^!%%y2^^^!, ^^^!%%y1^^^! : WScript.Echo "0")^>^>"^!%%yfnm^!"^&^
  ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%yfnm:~0,-4^!"') do (echo "%%a"^>nul)^
  ) ^|^| (echo Error [@movetoscreen]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (for %%a in (1,2,aux,fnm,tmp) do (set "%%y%%a="))^
 ) else (echo Error [@movetoscreen]: Absent parameters.^&exit /b 1)) else set wds_mts_aux=

::         @consoletext - reads text of specified console window.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `2:%~3`;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == name of variable with window handle of console or its quoted value (default "0", see also `6:%~7`);
::                      2:%~3 == variable name to return text, if it's skipped the text will be assigned to `%~1`;
::                      3:%~4 == first line to read, by default is `0` to start read from the last non-empty line;
::                      4:%~5 == number of lines to read, by default is `1` to read only one line;
::                      5:%~6 == delimiter between rows in the result (name of variable string or string in quotes, default is "");
::                      6:%~7 == key value `1` to indicate that `1:%~2` contains the process id, default is `0` for window handle;
::                      7:%~8 == value to set behaviour while reading another console (name of variable or digit in quotes):
::                               `1`- don't pause running process, read console as is;
::                               `2`- pause running console process to unblock text buffer;
::                               `4`- read console text by copying it;
::                                  - the sum of values means the combination of read attempts, the default value is `7` to use all;
::                                  - if `7:%~8` has variable, it will contain `1` when process had been paused, `0` if pause failed;
::                      8:%~9 == variable name to return the code type of result:
::                               `0`- Success;
::                               `1`- The process with ID has not window or invalid PID value;
::                               `2`- Internal error during job or too slow by timeout;
::                               `3`- Unexpected messages from injected reader;
::                               `4`- Failed to inject file or to create overlap window or the process has multiple windows;
::                               `5`- The text buffer of console application was blocked;
::                               `6`- Failed to get console handle;
::                               `7`- The process is not console application;
::                               `8`- Unknown architecture of target process, supported x86 or x64;
::                               `9`- Failed to write or to find injector file on disk, check access rights and library registration;
::                              `10`- Invalid window handle;
::                              `11`- The specified line wasn't found;
::                                  - if `8:%~9` defined, it assigns error message to output text;
::                      9:%~9 == variable name with string value to search in console. It will return given number of lines after
::                               found line. The macro performs case insensitive search. In order to search text after last empty 
::                               line in console, assign space symbol (` `) to variable. If specified, overrides `6:%~7`;
::                      A:%~10== key parameter to search substrings `9:%~9` (`1`), default is `0` to search all lines;
::                      B:%~11== key parameter to raise error in the case of internal failure (`1`), default is `0` to continue;
::                      C:%~12== key parameter to trim left spaces of every row of console (`1`), default is `0` to skip;
::                      D:%~13== digital parameter to set width of the text in the console, the default value is `80`, the range of
::                               values is [20 .. 8192]. The parameter is valid only for the console of Windows 10 or later OSes. In
::                               order to have width of the text equal to current width of the host console window set `0` value to
::                               this parameter;
::                      E:%~14== key parameter to define output of result:
::                               `0`- assign it to `2:%~3` (`%~1`) using delimiter `5:%~6` for several lines (default value);
::                               `1`- print it for external assigning to `2:%~3` (`%~1`) with delimiter `5:%~6`;
::                               `2`- print it line by line as is.
::             Notes. #1: If parameter `1:%~2` has default zero value, it will read text of current console;
::                    #2: The 1st line of console text with index `0` is the last non-empty row with any symbol;
::                    #3: Relatively to internal count from last line the concatenation of several lines has backward direction;
::                    #4: If parameter `5:%~6` has explicit string, all space symbols must be replaced by substring `/CHR{20}`;
::                    #5: Macro truncates trailing spaces for every line (workaround with `5:%~6`);
::                    #6: In echo modes `0` & `1` (`A:%~11`) the number of lines is restricted by 80 rows;
::                    #7: In echo mode `2` (`A:%~11`) it preliminary sets `%~1`, `7:%~8` & `8:%~9` - if they are defined;
::                    #8: Macro always pauses local host console to unblock its screen buffer.
::       Precautions. #1: In order to read text, the background functionality performs injection of dll into the process thread. 
::                        Also, in the case of the blocked text buffer, it performs pausing of the main thread. Very rarely it can 
::                        result in the remote or in the host console:
::                               - the result of it can be the crash, hang or improper work of unstable remote process;
::                               - the call with pausing takes more time (~100-200 ms);
::                               - the reading of console text as is can be blocked by hung application inside console, the pausing
::                                 resolves it;
::                               - the fast remote output can give partial text with lapses, the pausing resolves it too;
::                    #2: The target started by @runapp macro (i.e. child console) can have unstable work of injector, for w/a use
::                        @runapp_wsh to run console (independent process) or @mac_wrapper to read text (another child process);
::                    #3: If the value `D:%~13` is set to `0`, it can return text with the wrong width of another console window if
::                        it uses a font with a non-standard width other than `8` (Win10 and later).
::                Sample: 
::                        rem It uses dummy variable "v_linebelowout" to return numerical result into 1st parameter for @mac_check.
::                        set "v_findme=Can find me in console?"
::                        echo %v_findme%
::                        %@mac_check% @consoletext,2:v_linebelowout 9:v_findme %@istrue% && echo SUCCESS || echo FAILURE
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @consoletext=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gct_aux for /F %%y in ('echo wds_gct_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15" %%a in ('echo.%%%%yaux%%') do (^
   (for %%p in ("rtn=%%~a","ast=","sas=0","hdl=0","txn=","1st=0","num=1","del=""","pid=0","brn=","brv=7","trn=","rai=0","ltr=0","10w=80","eco=0") do (set "wds_gct_%%~p"))^&^
   (if ^^^!%%y1st^^^! NEQ 0 (echo Error [@consoletext]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%yrtn (echo Error [@consoletext]: The result parameter #1 is undefined.^&exit /b 1))^&^
   (set %%yquo="")^&set "%%yamp=1^^^&1"^&(set %%ylbr="(")^&(set %%yrbr=")")^&(for %%p in (quo amp lbr rbr) do (call set "wds_gct_%%p=%%wds_gct_%%p:~-2,1%%"))^&^
   (for %%p in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n,%%~o) do if not "%%p"=="" (^
    set "%%yaux=%%p"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yaux^^^! EQU 1 (^
      (for /F %%q in ('echo %%%%ytmp%%') do (^
       set "%%yhdl="^&set "%%yaux="^&(if "%%~q"==%%q (set "%%yaux=%%~q") else if defined %%~q (set "%%yaux=^!%%~q^!"))^&^
       (for /F "tokens=* delims=+,-,0" %%q in ('echo.%%%%yaux%%') do if "%%~q"=="" (set "%%yhdl=0") else (^
        for /F "tokens=* delims=0123456789" %%r in ('echo.%%q?') do if "%%r"=="?" (set %%yhdl="%%~q")^
       ))^&^
       (if not defined %%yhdl (echo Error [@consoletext]: Expected decimal value in parameter #1:2.^&exit /b 1))^
      ))^
     ) else if ^^^!%%yaux^^^! EQU 2 (^
      set "%%ytxn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 5 (^
      (for /F %%q in ('echo %%%%ytmp%%') do if "%%~q"==%%q (set "%%ydel=%%~q") else if defined %%~q (set "%%ydel=^!%%~q^!"))^&^
      (if defined %%ydel (^
       (call set %%ydel=%%%%ydel:^^^!%%yquo^^^!=^^^!%%yquo^^^! ^^^!%%yamp^^^! Chr^^^!%%ylbr^^^!34^^^!%%yrbr^^^! ^^^!%%yamp^^^! ^^^!%%yquo^^^!%%)^&^
       (set %%ydel="^!%%ydel:/CHR{20}= ^!")^
      ))^
     ) else if ^^^!%%yaux^^^! EQU 6 (^
      (if ^^^!%%ytmp^^^! EQU 1 (set "%%ypid=1"))^
     ) else if ^^^!%%yaux^^^! EQU 7 (^
      (for /F %%q in ('echo %%%%ytmp%%') do (^
       set "%%yaux="^&^
       (if "%%~q"==%%q (set /a "%%yaux=%%~q") else if defined %%~q (set "%%ybrn=%%~q"^&set /a "%%yaux=^!%%~q^!"))^>NUL 2^>^&1^&^
       (if defined %%yaux if ^^^!%%yaux^^^! LSS 1 (set "%%yaux=") else if 7 LSS ^^^!%%yaux^^^! (set "%%yaux="))^&^
       (if defined %%yaux (^
        set "%%ybrv=^!%%yaux^!"^
       ) else (^
        echo Error [@consoletext]: The #7:8 can only be 1,2,4 or their sum, check the quotes around the value or variable definition.^&exit /b 1^
       ))^
      ))^
     ) else if ^^^!%%yaux^^^! EQU 8 (^
      set "%%ytrn=^!%%ytmp^!"^
     ) else if ^^^!%%yaux^^^! EQU 9 (^
      if defined ^^^!%%ytmp^^^! (call set %%yast="%%^!%%ytmp^!%%")^
     ) else if ^^^!%%yaux^^^! EQU 10 (^
      if "^!%%ytmp^!"=="1" (set "%%ysas=1")^
     ) else if ^^^!%%yaux^^^! EQU 11 (^
      if ^^^!%%ytmp^^^! EQU 1 (set "%%yrai=1")^
     ) else if ^^^!%%yaux^^^! EQU 12 (^
      if ^^^!%%ytmp^^^! EQU 1 (set "%%yltr=1")^
     ) else if ^^^!%%yaux^^^! EQU 13 (^
      set /a "%%y10w=^!%%ytmp^!"^>NUL 2^>^&1^
     ) else if ^^^!%%yaux^^^! EQU 14 (^
      if 0 LSS ^^^!%%ytmp^^^! if ^^^!%%ytmp^^^! LEQ 3 (set "%%yeco=^!%%ytmp^!")^
     ) else (^
      set "%%ycnt=3"^&^
      (for %%q in (1st,num) do (^
       (if ^^^!%%ycnt^^^! EQU ^^^!%%yaux^^^! (^
        (set /a "%%yaux=0x^!%%ytmp^!"^>NUL 2^>^&1)^>NUL ^&^& (set "wds_gct_%%q=^!%%ytmp^!") ^|^| (echo Error [@consoletext]: Non-digital value in parameter #^^^!%%yaux^^^!:^^^!%%ycnt^^^! or zero number of lines.^&exit /b 1)^
       ))^&^
       set /a "%%ycnt+=1"^>NUL^
      ))^
     ))^
    ))^
   ))^&^
   (if not defined %%ytxn (set "%%ytxn=^!%%yrtn^!"^&set "%%yrtn="))^&^
   (if ^^^!%%yeco^^^! NEQ 2 if 80 LSS ^^^!%%ynum^^^! (set "%%ynum=80"))^
  ))^&(if not defined %%yeco (echo Error [@consoletext]: Absent parameters, verify spaces.^&exit /b 1))^&^
  set "%%yres=0"^&^
  (for %%a in (0,100) do if %%a EQU ^^^!%%yres^^^! (^
   (for /F "tokens=*" %%b in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
    (if "%%~b"==%%b if %%b=="" (echo Error [@consoletext]: COM registration failed.^&exit /b 1) else (set %%b))^&set "%%yfnm=%%b"^
   ))^&^
   (^
    (echo Dim res, rtn, txn, trn, pid, brn, dlm, ast, sas)^&^
    (echo pid = ^^^!%%yhdl^^^! : sas = ^^^!%%ysas^^^!)^&^
    (echo txn = "")^&^
    (if defined %%yast (echo ast = ^^^!%%yast^^^!) else (echo ast = ""))^&^
    set "%%yaux=If True Then"^&^
    (if ^^^!%%yhdl^^^! NEQ 0 if ^^^!%%ypid^^^! NEQ 1 (^
     set "%%yaux="^&^
     (echo pid = wmo.PidOfWindow^^^!%%ylbr^^^!pid^^^!%%yrbr^^^!)^&^
     (echo If CLng^^^!%%ylbr^^^!pid^^^!%%yrbr^^^! = 0 Then)^&^
     (echo  trn = 10)^&^
     (echo  txn = "Invalid window handle")^&^
     (echo  brn = 0)^&^
     (echo Else)^
    ))^&^
    (if defined %%yaux (echo ^^^!%%yaux^^^!))^&^
    (echo  brn = ^^^!%%ybrv^^^!)^&^
    (if ^^^!%%yeco^^^! EQU 2 (set "%%yaux=Chr(10)") else (set "%%yaux=^!%%ydel^!"))^&^
    (echo  dlm = ^^^!%%yaux^^^!)^&^
    set "%%yaux= trn = wmo.GetConsoleText(pid, ^!%%y1st^!, ^!%%ynum^!, dlm, txn, brn, ast, sas, ^!%%yltr^!, ^!%%y10w^!)"^&^
    (echo ^^^!%%yaux^^^!)^&^
    (echo  If trn = 10 Then WScript.Echo "%%yres=100" : Err.Clear : WScript.Quit 0)^&^
    (echo  If InStr^^^!%%ylbr^^^!txn, Chr^^^!%%ylbr^^^!"^!%%yamp^!H21"^^^!%%yrbr^^^!^^^!%%yrbr^^^! Then)^&^
    (echo   txn = wmo.GetDosString^^^!%%ylbr^^^!txn, ^^^!%%yeco^^^!^^^!%%yrbr^^^!)^&^
    (echo  End If)^&^
    (echo End If)^&^
    (echo res = trn : If res = 0 Then rtn = 0 Else rtn = 1)^&^
    (if ^^^!%%yeco^^^! EQU 2 (set "%%yaux=rtn,trn,brn,res") else (set "%%yaux=res,txn,rtn,trn,brn"))^&^
    set "%%yres=%%yres"^&^
    (for %%b in (^^^!%%yaux^^^!) do if defined wds_gct_%%b (^
     (echo WScript.Echo "^!wds_gct_%%b^!=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!%%b^^^!%%yrbr^^^!)^
    ))^&^
    (if ^^^!%%yeco^^^! EQU 2 (^
     (echo If res = 0 Then)^&^
     (echo  Dim rows, i : rows = Split^^^!%%ylbr^^^!txn, dlm^^^!%%yrbr^^^!)^&^
     (echo  For i = 0 To Ubound^^^!%%ylbr^^^!rows^^^!%%yrbr^^^!)^&^
     (echo   WScript.Echo "." ^^^!%%yamp^^^! rows^^^!%%ylbr^^^!i^^^!%%yrbr^^^!)^&^
     (echo  Next)^&^
     (echo Else)^&^
     (echo  WScript.Echo txn)^&^
     (echo End If)^
    ))^&^
    (echo Err.Clear : WScript.Echo "%%yaux" : WScript.Quit 0)^
   )^>^>"^!%%yfnm^!"^&^
   ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
    for /F "tokens=*" %%b in ('"cscript //nologo %%%%yquo%%^!%%yfnm:~0,-4^!%%%%yquo%%"') do if not "%%~b"=="%%yaux" (^
     if "^!%%yres^!"=="%%yres" (^
      set "%%b"^>NUL 2^>^&1^&(if "^!%%yres^!"=="%%yres" if 0 LSS ^^^!%%yeco^^^! (echo "%%b"))^
     ) else (^
      (if ^^^!%%yres^^^! NEQ 0 if ^^^!%%yrai^^^! EQU 1 (echo Error [@consoletext]: %%b.^&exit /b 1))^&^
      (if ^^^!%%yeco^^^! EQU 0 (set "%%b"^>NUL 2^>^&1) else if ^^^!%%yeco^^^! EQU 1 (echo "%%b") else (echo%%b))^
     )^
    )^
   ) ^|^| (echo Error [@consoletext]: R/W disk conflict or vbscript error.^&exit /b 1))^
  ))^&^
  (if ^^^!%%yres^^^! NEQ 0 if not defined %%ytrn (^
   (if ^^^!%%yeco^^^! EQU 0 (set "%%ytxn=") else if ^^^!%%yeco^^^! EQU 1 (echo "%%ytxn="))^
  ))^&^
  (if ^^^!%%yeco^^^! NEQ 1 for %%b in (10w,1st,amp,aux,ast,brn,brv,cnt,del,eco,fnm,hdl,lbr,ltr,num,pid,quo,rai,rbr,res,rtn,sas,tmp,trn,txn) do (set "wds_gct_%%b="))^
 ) else (echo Error [@consoletext]: Absent parameters.^&exit /b 1)) else set wds_gct_aux=

::              @shrink - shrinks data using LZW algorithm with adaptive arithmetic coding, supports string representation of data.
::                        %~1 == name of variable with source data according parameter `2:%~4`;
::                        %~2 == name of variable with target data according parameter `3:%~5`;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == key parameter `1` to perform shrinking of data (default), `0` for decompression;
::                      2:%~4 == default key value `1` for input file specifed by `%~1`, `0` for local string inside `%~1`;
::                      3:%~5 == default key value `1` for output file specifed by `%~2`, `0` to do output into variable `%~2`;
::                      4:%~6 == key parameter to set type of conversion:
::                                 `0`- plain LZW conversion (only for output/input binary files);
::                                 `1`- LZW conversion with arithmetic coding (only for output/input binary files);
::                                 `2`- default, LZW conversion with coding, the result is converted to a string representation of 
::                                      the numbers in the specified radix digit mapping;
::                                 `3`- LZW conversion with coding, the result is a hexadecimal string representation of the bytes;
::                      The following parameters apply only to compression of data (`1:%~3` <=> `1`):
::                      5:%~7 == `1` to set that the source can be converted to upper case, default `0` for case sensitive input;
::                      6:%~8 == `1` to drop UTF-8 signature inside source file, default `0` to keep it (&#EF;&#BB;&#BF);
::                      7:%~9 == the string length inside converted file, default `0` for single string (`4:%~6` <=> `2` & `3`);
::                                 - the parameter is ignored with value `3:%~5` <=> `0`.
::                      The following parameters apply only to converting data to string representation (`4:%~6` <=> `2`):
::                      8:%~10== name of variable for specification of digital radix for conversion of compressed bytes into string;
::                                 [in]  - digital value in range [2..214], default value is `86`;
::                                 [out] - returns radix size (see also `A:%~12` & `B:%~13`);
::                                 - the storage is not reliable for various code pages if radix is `> 86`;
::                                 - specifies internal default mapping, for custom mapping use `A:%~12`;
::                      9:%~11== the quantation length for convertion to string, default is `16`, minimum value is `8`;
::                                 - defines the length of the byte subarrays in the result compressed array that will be converted
::                                   to strings (numbers) of the specified radix;
::                                 - because of hyperbolic computational complexity it is not recommended to use more than `32`;
::                      A:%~12== name of variable to collate symbols to radix (`8:%~10`) using string of symbols:
::                                 [in]  - the string to collate symbols to radix & to set size of radix, default is "";
::                                 [out] - returns mapping string for given radix;
::                                 - non-empty input conceals input value of `8:%~10`;
::                                 - sample of custom collation for 6-base radix: "QWERTY"
::                      B:%~13== name of variable for collation to radix using string of symbol's hexadecimal codes:
::                                 [in]  - the string to collate symbols to radix & to set size of radix, default is "";
::                                 [out] - returns mapping string of hexadecimal codes for given radix;
::                                 - non-empty input conceals input values of `8:%~10` & `A:%~12`;
::                                 - sample for 6-base radix with same `QWERTY` but specified as their codes: "515745525459"
::                      C:%~14== key `1` to use random collation of radix symbols to their internal default set, default is `0`;
::                                 - it performs random mapping during shrinking (`1:%~3` <=> `1`), otherwise not valuable;
::                                 - key conceals input values of `A:%~12` & `B:%~13`, the size of radix is defined by `8:%~10`;
::                                 - this parameter requires one of `A:%~12` or `B:%~13` to return generated mapping;
::                      Optional parameters:
::                      D:%~15== variable name to define error handling & to report internal result:
::                                 [in]  - the digital value to define error handling:
::                                       `0`- skip, goon silently;
::                                       `1`- report & continue;
::                                       `2`- report & break (default);
::                                 [out] - returns internal digital code of error:
::                                       `0`- success;
::                                       `1`- error reading input value from memory (`2:%~4` <=> `0` & `E:%~16` <=> `1`);
::                                       `2`- attempt to assign output string with length more than 7500 (`3:%~5` <=> `0`);
::                                       `3`- output file doesn't exist (`3:%~5` <=> `1`);
::                                       `4`- error of initializing radix;
::                                       `5`- error of compression or decompression;
::                      E:%~16== key parameter to read input parameter from the memory of calling process `1`, default is `0`;
::                                 - `2:%~4` <=> `0` only, for transfer of "unreadable" internal strings with many control symbols;
::                      F:%~17== key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: Error messages report decimal identifiers of parameters, that is `A`..`F` <=> `10`..`15`;
::                    #2: Keys `5:%~7` & `6:%~8` change source data, must be not used without any reason;
::                    #3: for additional details on string conversion see @radix macro.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @shrink=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_lzw_ax for /F %%y in ('echo wds_lzw_') do (^
  (for %%a in ("1=Error [@shrink]: ","2=arameter #","3=WScript.Echo ") do (set "%%y%%~a"))^&^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17" %%a in ('echo.%%%%yax%%') do (^
   (for %%r in ("xn=%%~a","xv=""","yn=%%~b","yv=""","lz=1","xf=1","yf=1","nc=2","up=0","un=0","le=0","an=","av=86","ql=16","sn=","sv=""","cn=","cv=""","rd=0","rn=","rv=2","ev=0","ec=0","qm=","la=","la=","lb=0","rb=1") do (set "%%y%%~r"))^&^
   (if ^^^!%%ylz^^^! NEQ 1 (call echo %%%%y1%%Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%yax=1"^&(for %%r in (xn,yn) do if defined %%y%%r (set /a "%%yax=+1")^>NUL else (echo ^^^!%%y1^^^!Undefined result ^^^!%%y2^^^!^^^!%%yax^^^!.^&exit /b 1))^&^
   (for %%r in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n,%%~o,%%~p,%%~q) do if not "%%r"=="" (^
    set "%%yax=%%r"^&set "%%yau=^!%%yax:~2^!"^&^
    (if defined %%yau (set /a "%%yax=0x^!%%yax:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%yax^^^! EQU 10 (^
      set "%%ysn=^!%%yau^!"^
     ) else if ^^^!%%yax^^^! EQU 11 (^
      set "%%ycn=^!%%yau^!"^
     ) else (^
      (if ^^^!%%yax^^^! EQU 1 (set "%%yla=lz"^
      ) else if ^^^!%%yax^^^! EQU 2 (set "%%yla=xf"^
      ) else if ^^^!%%yax^^^! EQU 3 (set "%%yla=yf"^
      ) else if ^^^!%%yax^^^! EQU 4 (set "%%yla=nc"^&set "%%yrb=3"^
      ) else if ^^^!%%yax^^^! EQU 5 (set "%%yla=up"^
      ) else if ^^^!%%yax^^^! EQU 6 (set "%%yla=un"^
      ) else if ^^^!%%yax^^^! EQU 7 (set "%%yla=le"^&set "%%yrb=7500"^
      ) else if ^^^!%%yax^^^! EQU 8 (set "%%yan=^!%%yau^!"^&set "%%yqm=86"^&set "%%yla=av"^&set "%%ylb=2"^&set "%%yrb=214"^
      ) else if ^^^!%%yax^^^! EQU 9 (set "%%yla=ql"^&set "%%ylb=8"^&set "%%yrb=10240"^
      ) else if ^^^!%%yax^^^! EQU 12 (set "%%yla=rd"^
      ) else if ^^^!%%yax^^^! EQU 13 (set "%%yrn=^!%%yau^!"^&set "%%yqm=nothing"^&set "%%yla=rv"^&set "%%yrb=2"^
      ) else if ^^^!%%yax^^^! EQU 14 (set "%%yla=ev"^
      ) else if ^^^!%%yax^^^! EQU 15 (set "%%yla=ec"))^&^
      (if defined %%yqm if defined ^^^!%%yau^^^! (call set "%%yau=%%^!%%yau^!%%") else (set "%%yau=^!%%yqm^!"))^&^
      (if defined %%yla (^
       call set "%%yap=%%%%y^!%%yla^!%%"^&^
       (if ^^^!%%yap^^^! NEQ ^^^!%%yau^^^! (^
        set "%%y^!%%yla^!="^&^
        ((set /a "%%yap=0x^!%%yau^!"^>NUL 2^>^&1)^>NUL ^&^& (^
         (if 9 LSS ^^^!%%yap^^^! (^
          (if ^^^!%%yrb^^^! LSS 10 (set "%%yap=") else (^
           set "%%yap="^&^
           (for /F "tokens=* delims=+,-,0" %%s in ('echo.%%%%yau%%') do (^
            (set /a "%%yau=%%~s"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%yau^!"=="%%~s" (set "%%yap=%%~s"))^
           ))^
          ))^
         ))^&^
         (if defined %%yap if ^^^!%%ylb^^^! LEQ ^^^!%%yap^^^! if ^^^!%%yap^^^! LEQ ^^^!%%yrb^^^! (set "%%y^!%%yla^!=^!%%yap^!"))^
        ))^&^
        (if not defined %%y^^^!%%yla^^^! (^
         set /a "%%yqm=^!%%yax^!+2"^>NUL^&^
         echo ^^^!%%y1^^^!P^^^!%%y2^^^!^^^!%%yax^^^!:^^^!%%yqm^^^! must belong to [^^^!%%ylb^^^!..^^^!%%yrb^^^!], received `^^^!%%yau^^^!`.^&^
         exit /b 1^
        ))^
       ))^&^
       set "%%yqm="^&set "%%yla="^&set "%%ylb=0"^&set "%%yrb=1"^
      ))^
     ))^
    ))^
   ))^
  ))^&(if not defined %%yec (echo ^^^!%%y1^^^!Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%yqm="")^&(set %%yla="^^^<")^&set "%%yap=1^^^&1"^&(set %%ylb="(")^&(set %%yrb=")")^&(for %%a in (qm,la,ap,lb,rb) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  (for %%a in (x,y) do if ^^^!%%y%%af^^^! NEQ 0 (^
   (if defined ^^^!%%y%%an^^^! (^
    for /F "tokens=1,2" %%b in ('"echo.^!%%y%%an^! ^!%%yqm^!"') do (set %%y%%av="^!%%b:%%c=^!")^
   ) else (^
    (if %%a==x (set %%yax=1, source) else (set %%yax=2, target))^&^
    echo ^^^!%%y1^^^!P^^^!%%y2^^^!^^^!%%yax^^^! file name string is empty.^&exit /b 1^
   ))^
  ))^&^
  (if ^^^!%%yxf^^^! EQU 0 (if defined ^^^!%%yxn^^^! if ^^^!%%yev^^^! NEQ 1 (^
   set "%%yau=1"^&^
   ((call set "%%yxv=%%^!%%yxn^!:^!%%yqm^!=^!%%yqm^! ^!%%yap^! Chr^!%%ylb^!34^!%%yrb^! ^!%%yap^! ^!%%yqm^!%%"^>NUL 2^>^&1)^>NUL ^&^& (^
    (call set %%yau="%%%%yxv:^!%%yqm^!=%%"^>NUL 2^>^&1)^>NUL ^&^&^ (^
     (set %%yxv="^!%%yxv^!"^>NUL 2^>^&1)^>NUL^&^
     set "%%yau="^
    )^
   ))^&^
   (if defined %%yau (echo ^^^!%%y1^^^!Fail due to controls - use file or set key #E:16.^&exit /b 1))^
  )) else if ^^^!%%yyf^^^! EQU 1 if "^!%%yxv^!"=="^!%%yyv^!" (echo ^^^!%%y1^^^!Source and target coincide.^&exit /b 1))^&^
  (for %%a in (c,s) do if defined ^^^!%%y%%an^^^! for /F "tokens=*" %%b in ('echo %%%%y%%an%%') do (set %%y%%av="^!%%~b^!"))^&^
  (if ^^^!%%yxf^^^! EQU 1 (^
   (if not exist ^^^!%%yxv^^^! (echo ^^^!%%y1^^^!Absent source file.^&exit /b 1))^&^
   set "%%yev=0"^
  ))^&^
  (if ^^^!%%ylz^^^! EQU 0 (set "%%yrd=0"))^&^
  (if ^^^!%%yyf^^^! EQU 0 (^
   (if ^^^!%%ync^^^! LSS 2 (echo ^^^!%%y1^^^!Internal output only with p^^^!%%y2^^^!4:6 `2` or `3`.^&exit /b 1))^&^
   set "%%yle=0"^
  ))^&^
  (if ^^^!%%yav^^^! LSS 2 (set "%%yav=86"))^&(if 214 LSS ^^^!%%yav^^^! (set "%%yav=86"))^&^
  (if ^^^!%%yrd^^^! EQU 1 (^
   (if not defined %%ysn if not defined %%ycn (echo ^^^!%%y1^^^!No parameters to return radix as symbols or as their codes.^&exit /b 1))^&^
   set "%%yav=-^!%%yav^!"^
  ))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo ^^^!%%y1^^^!COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfn=%%a"^
  ))^&^
  (^
   (echo Dim ax, rn, xn, yn, an, sn, cn)^&^
   set "%%yax=x,y,a,s,c"^&^
   (if ^^^!%%yev^^^! EQU 1 (^
    (echo ax = wmo.EnvironSet^^^!%%ylb^^^!0, xn, "^!%%yxn^!", 1^^^!%%yrb^^^!)^&^
    (echo If 0 ^^^!%%yla^^^! ax And ax ^^^!%%yla^^^! 10 Then ^^^!%%y3^^^!"%%yax=1" : ^^^!%%y3^^^!xn : WScript.Quit)^&^
    set "%%yax=y,a,s,c"^
   ))^&^
   (for %%a in (^^^!%%yax^^^!) do (echo %%an = ^^^!%%y%%av^^^!))^&^
   (echo rn = 1)^&^
   (for %%a in (4,5) do (^
    set "%%yax="^&^
    (if %%a EQU 4 (^
     (if ^^^!%%ync^^^! EQU 2 (^
      (echo wmo.SetCodesOfBaseSymbols an, sn, cn)^&^
      set "%%yax=1"^
     ))^
    ) else (^
     (echo If Len^^^!%%ylb^^^!xn^^^!%%yrb^^^! Then rn = wmo.Shrink^^^!%%ylb^^^!^^^!%%ylz^^^!, xn, ^^^!%%yxf^^^!, yn, ^^^!%%yyf^^^!, ^^^!%%ync^^^!, ^^^!%%yup^^^!, ^^^!%%yql^^^!, ^^^!%%yun^^^!, 0, ^^^!%%yle^^^!, False^^^!%%yrb^^^!)^&^
     set "%%yax=1"^
    ))^&^
    (if defined %%yax (^
     (echo If Err.Number Or rn = 0 Then)^&^
     (echo  If Err.Number Then ax = Err.Description Else ax = "Internal error")^&^
     (echo  ^^^!%%y3^^^!"%%yax=%%a" : ^^^!%%y3^^^!ax : Err.Clear : WScript.Quit 0)^&^
     (echo End If)^
    ))^
   ))^&^
   (if ^^^!%%yyf^^^! EQU 1 (^
    (echo If Not fso.FileExists^^^!%%ylb^^^!yn^^^!%%yrb^^^! Then)^&^
    set "%%yax=3"^&set "%%yla=Absent output file"^&set "%%yau=ax,rn,an,sn,cn"^
   ) else (^
    (echo If Len^^^!%%ylb^^^!yn^^^!%%yrb^^^! ^^^!%%yla^^^!= 7500 Then)^&^
    (echo  yn = wmo.GetDosString^^^!%%ylb^^^!yn, ^^^!%%yec^^^!^^^!%%yrb^^^!)^&^
    (echo Else)^&^
    set "%%yax=2"^&set "%%yla=String length exceeds 7500"^&set "%%yau=ax,rn,yn,an,sn,cn"^
   ))^&^
   (echo  ^^^!%%y3^^^!"%%yax=^!%%yax^!" : ^^^!%%y3^^^!"^!%%yla^!" : WScript.Quit 0)^&^
   (echo End If)^&^
   (echo rn = 0 : ax = 0)^&^
   set "%%yax=%%yax"^&^
   (for %%a in (^^^!%%yau^^^!) do if defined %%y%%a (^
    (echo ^^^!%%y3^^^!"^!%%y%%a^!=" ^^^!%%yap^^^! CStr^^^!%%ylb^^^!%%a^^^!%%yrb^^^!)^
   ))^
  )^>^>"^!%%yfn^!"^&^
  ((call move /y "^!%%yfn^!" "^!%%yfn:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('start /b /i /abovenormal cscript //nologo "^!%%yfn:~0,-4^!"') do (^
    (if "^!%%yax^!"=="%%yax" (^
     set "%%a"^
    ) else if ^^^!%%yax^^^! NEQ 0 (^
     (if ^^^!%%yrv^^^! NEQ 0 (echo ^^^!%%y1:~0,-2^^^! #^^^!%%yax^^^!: %%a.))^&^
     (if ^^^!%%yrv^^^! EQU 2 (exit /b 1))^&^
     (if defined %%yrn if ^^^!%%yec^^^! EQU 0 (set "^!%%yrn^!=^!%%yax^!") else (echo "^!%%yrn^!=^!%%yax^!"))^
    ) else (^
     (if ^^^!%%yec^^^! EQU 0 (set "%%a") else (echo "%%a"))^
    ))^
   )^
  ) ^|^| (echo ^^^!%%y1^^^!R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%yec^^^! NEQ 1 for %%a in (1,2,3,an,ap,av,au,ax,cn,cv,ec,ev,fn,la,lb,le,lz,nc,ql,qm,rb,rd,rn,rv,sn,sv,up,un,xf,xn,xv,yf,yn,yv) do (set "%%y%%a="))^
 ) else (echo Error [@shrink]: Absent parameters.^&exit /b 1)) else set wds_lzw_ax=

::        @comparefiles - performs a byte comparison of the data of two files.
::                        %~1 == variable name to return result ('0' - all data bytes match, otherwise `1`, @mac_check compatible);
::                      Full names of files to compare (variable names or explicit quoted strings):
::                        %~2 == 1st file;
::                        %~3 == 2nd file;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~4 == name of variable to return detailed result of data comparison:
::                               `0`- the data scan didn't reveal different bytes, success;
::                               `1`- files have different bytes;
::                               `2`- the size of one of files changed while reading its data, or an error reading the data;
::                               `3`- the sizes of two files are different;
::                               `4`- one of the files is unreadable;
::                               `5`- one of the files was not found;
::                      2:%~5 == key parameter to echo result instead of assigning (`1`), default is `0`.
::                  Note: if `%~1` or `%~2` have explicit string values the space symbols must be replaced by `/CHR{20}`.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @comparefiles=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cfd_aux for /F %%p in ('echo wds_cfd_') do (^
  (for /F "tokens=1,2,3,4,5" %%a in ('echo.%%%%paux%%') do (^
   (for %%f in ("1fn=","2fn=","den=","eco=0") do (set "wds_cfd_%%~f"))^&(if not "^!%%peco^!"=="0" (echo Error [@comparefiles]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (set %%pquo="")^&set "%%pamp=1^^^&1"^&(set %%plbr="(")^&(set %%prbr=")")^&(for %%f in (quo amp lbr rbr) do (call set "wds_cfd_%%f=%%wds_cfd_%%f:~-2,1%%"))^&^
   set "%%pren=%%~a"^&set "%%paux=1"^&set "%%ptmp=2"^&^
   (for %%f in (%%b,%%c) do (^
    (if not "%%f"=="" (^
     (if "%%~f"==%%f (set "%%p^!%%paux^!fn=%%~f") else if defined %%~f (set "%%p^!%%paux^!fn=^!%%~f^!"))^&^
     (if defined %%p^^^!%%paux^^^!fn (^
      (call set %%p^^^!%%paux^^^!fn=%%%%p^^^!%%paux^^^!fn:^^^!%%pquo^^^!=%%)^&^
      (call set %%p^^^!%%paux^^^!fn="%%%%p^!%%paux^!fn:/CHR{20}= %%")^
     ))^
    ))^&^
    (if not defined %%p^^^!%%paux^^^!fn (echo Error [@comparefiles]: Missing file name #^^^!%%paux^^^! in parameter #^^^!%%ptmp^^^!.^&exit /b 1))^&^
    set /a "%%paux+=1"^>NUL^&set /a "%%ptmp+=1"^>NUL^
   ))^&^
   (if ^^^!%%p1fn^^^!==^^^!%%p2fn^^^! (echo Error [@comparefiles]: The names of files can not coincide.^&exit /b 1))^&^
   (for %%f in (%%~d,%%~e) do if not "%%f"=="" (^
    set "%%paux=%%f"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      set "%%pden=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 2 if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=1"))^
    ))^
   ))^
  ))^&(if not defined %%peco (echo Error [@comparefiles]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@comparefiles]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  (^
   (echo Dim ren, den)^&^
   (echo den = wmo.CompareFileBytes^^^!%%plbr^^^!^^^!%%p1fn^^^!, ^^^!%%p2fn^^^!^^^!%%prbr^^^!)^&^
   (echo If den Then ren = 1 Else ren = 0)^&^
   (for %%a in (ren,den) do if defined wds_cfd_%%a (^
    (echo WScript.Echo "^!wds_cfd_%%a^!=" ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!%%a^^^!%%prbr^^^!)^
   ))^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do if ^^^!%%peco^^^! NEQ 1 (set "%%a") else (echo "%%a")^
  ) ^|^| (echo Error [@comparefiles]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (1fn,2fn,amp,aux,den,eco,fnm,lbr,quo,rbr,ren,tmp) do (set "wds_cfd_%%a="))^
 ) else (echo Error [@comparefiles]: Absent parameters.^&exit /b 1)) else set wds_cfd_aux=

::          @environset - prints environment variables defined inside running instance of `cmd.exe` process.
::                        %~1 == quoted value or variable with handle of console window or PID of `cmd.exe` (see `2:%~3`);
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == the string with search mask for selection of variables, supported search options:
::                               `*`         - default value to echo all environment variables of target;
::                               `*varname`  - search names with arbitrary prefix and constant suffix "varname";
::                               `varname*`  - search names with constant prefix "varname" and arbitrary suffix;
::                               `*varname*` - echo variables with substring "varname" in their names;
::                      2:%~3 == key value `1` to search console with window handle in `%~1`, default is `0` for `%~1` with PID.
::                      3:%~4 == key value to set mode of selection:
::                               `0` - select values exactly corresponding to given identifier;
::                               `1` - get the latest definitions from the last child process (default);
::                               `2` - get the earliest definitions from the parent process.
::             Notes. #1: Reports an empty string `""` if no match was found;
::                    #2: The zero value inside `%~1` means that it will look current process.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @echo_params, @obj_newname.
::
set @environset=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_pes_aux for /F %%p in ('echo wds_pes_') do (^
  (for /F "tokens=1,2,3,4" %%a in ('echo.%%%%paux%%') do (^
   (set %%pmsk="*")^&(for %%e in ("phv=","hdl=0","sel=1") do (set "%%p%%~e"))^&^
   (if ^^^!%%phdl^^^! NEQ 0 (echo Error [@environset]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   set "%%paux=%%a"^&^
   (if "^!%%paux:~1,-1^!"==^^^!%%paux^^^! (set "%%paux=^!%%paux:~1,-1^!") else if defined %%paux (call set "%%paux=%%^!%%paux^!%%"))^&^
   (for /F "tokens=* delims=+,-,0" %%e in ('echo.%%%%paux%%') do if "%%~e"=="" (set "%%pphv=0") else (^
    for /F "tokens=* delims=0123456789" %%f in ('echo.%%e?') do if "%%f"=="?" (set %%pphv="%%~e")^
   ))^&^
   (if not defined %%pphv (echo Error [@environset]: The value of parameter #1 is undefined or has non-digital value.^&exit /b 1))^&^
   (set %%pquo="")^&set "%%pamp=1^^^&1"^&(set %%plbr="(")^&(set %%prbr=")")^&(for %%d in (quo amp lbr rbr) do (call set "%%p%%d=%%%%p%%d:~-2,1%%"))^&^
   (for /F %%e in ('cmd /d /q /r "^!@echo_params^! 3 %%~b %%~c %%~d"') do (^
    set "%%paux=%%e"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      (for /F %%f in ('"echo %%%%ptmp:^!%%pquo^!=%%"') do if not "%%~f"=="" (^
       (set %%pmsk="%%~f")^&set "%%pmsk=^!%%pmsk: =^!"^
      ))^
     ) else if ^^^!%%paux^^^! EQU 2 (^
      (if ^^^!%%ptmp^^^! EQU 1 (set "%%phdl=1"))^
     ) else if ^^^!%%paux^^^! EQU 3 (^
      (if 0 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 2 (set "%%psel=^!%%ptmp^!"))^
     ))^
    ))^
   ))^
  ))^&(if not defined %%phdl (echo Error [@environset]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@environset]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  (^
   (echo Dim pid, res, str, arr, i : pid = ^^^!%%pphv^^^! : res = 0)^&^
   (if ^^^!%%phdl^^^! EQU 1 (^
    (echo If CBool^^^!%%plbr^^^!pid^^^!%%prbr^^^! Then)^&^
    (echo  pid = wmo.PidOfWindow^^^!%%plbr^^^!pid^^^!%%prbr^^^!)^&^
    (echo  If CBool^^^!%%plbr^^^!pid^^^!%%prbr^^^! = "0" Then res = 1 : WScript.Echo "Error [@environset]: Invalid window handle")^&^
    (echo End If)^
   ))^&^
   (echo If res = 0 Then)^&^
   (echo  res = wmo.EnvironSet^^^!%%plbr^^^!pid, str, ^^^!%%pmsk^^^!, ^^^!%%psel^^^!^^^!%%prbr^^^!)^&^
   (echo  If res = 0 Or res = 10 Then)^&^
   (echo   If res = 0 Then)^&^
   (echo    arr = Split^^^!%%plbr^^^!wmo.GetDosString^^^!%%plbr^^^!str, False^^^!%%prbr^^^!, Chr^^^!%%plbr^^^!10^^^!%%prbr^^^!^^^!%%prbr^^^!)^&^
   (echo    For i = 0 To UBound^^^!%%plbr^^^!arr^^^!%%prbr^^^!)^&^
   (echo     WScript.Echo arr^^^!%%plbr^^^!i^^^!%%prbr^^^!)^&^
   (echo    Next)^&^
   (echo   Else)^&^
   (echo    res = 0 : WScript.Echo Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^!)^&^
   (echo   End If)^&^
   (echo  Else)^&^
   (echo   res = 1 : WScript.Echo "Error [@environset]: " ^^^!%%pamp^^^! str)^&^
   (echo  End If)^&^
   (echo End If)^&^
   (echo WScript.Quit res)^
  )^>^>"^!%%pfnm^!"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   (cscript //nologo "^!%%pfnm:~0,-4^!") ^|^| (exit /b 1)^
  ) ^|^| (echo Error [@environset]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (amp,aux,fnm,hdl,lbr,msk,phv,quo,rbr,sel,tmp) do (set "%%p%%a="))^
 ) else (echo Error [@environset]: Absent parameters.^&exit /b 1)) else set wds_pes_aux=
 
::             @enwalue - gets environment variable defined inside running instance of `cmd.exe` process and assigns it locally.
::                        %~1 == variable name to return result ('0' - true, @mac_check compatibility) - see also `2:%~3`;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~2 == variable name with window handle of console (default "0" for current process, see also `4:%~5`);
::                      2:%~3 == variable name to assign value locally, if it's skipped the value will be assigned to `%~1`;
::                      3:%~4 == variable name in the target process to read, if it's skipped will use name from `2:%~3` or `%~1`;
::                      4:%~5 == key value `1` to indicate that `1:%~2` contains the process id, default is `0` for window handle;
::                      5:%~6 == key value to set mode of selection:
::                               `0` - select value of the process exactly corresponding to given identifier or handler;
::                               `1` - get the latest definition from the last child process (default);
::                               `2` - get the earliest definition from the parent process;
::                      6:%~7 == variable name to return the code type of result:
::                              `-1`- Failed to find given name in the target process or it is not defined;
::                               `0`- Success;
::                               `1`- Queries from Wow64 process and queries of Wow64 process are not supported;
::                               `2`- The process is not console application;
::                               `3`- Failed to find cognate process with module `cmd.exe`;
::                               `4`- Unknown architecture of target process, supported x86 or x64;
::                               `5`- Failed to open target process;
::                               `6`- Failed to query the process basic information;
::                               `7`- Failed to read data inside PEB of the process;
::                               `8`- Failed to read parameters data;
::                               `9`- Run-time exception while execution (with system code of this error);
::                              `10`- Window handle is invalid (`4:%~5` <=> `0`);
::                              `11`- The query raised unhandled error (with text of error message);
::                      7:%~8 == key parameter to define behaviour in the case of error:
::                               `0`- skip, goon silently (default);
::                               `1`- report & continue;
::                               `2`- report & break;
::                               `3`- assign error message to result variable;
::                                  - error codes: `1` ... `11`, codes `0` and `-1` - usual output;
::                      8:%~9 == key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: If `2:%~3` defined, `%~1` has output `0` for result types `0` & `-1` (see `6:%~7`), `1` in other cases;
::                    #2: if the target or the source variable names contain controls (`(` & `)`) use quotes for their strings.
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @enwalue=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_gev_aux for /F %%p in ('echo wds_gev_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%%%paux%%') do (^
   (for %%j in ("rtn=%%~a","hpv=0","tgn=","scn=","upi=0","sel=1","trn=","rai=0","eco=0") do (set "wds_gev_%%~j"))^&^
   (if ^^^!%%phpv^^^! NEQ 0 (echo Error [@enwalue]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%prtn (echo Error [@enwalue]: The value of parameter #1 is the incorrect ms-dos name.^&exit /b 1))^&^
   (for %%j in (%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i) do if not "%%j"=="" (^
    set "%%paux=%%j"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (^
      (for /F "tokens=* delims=+,-,0" %%k in ('"echo.%%^!%%ptmp^!%%"') do if "%%~k"=="" (set "%%phpv=0") else (^
       for /F "tokens=* delims=0123456789" %%l in ('echo.%%k?') do if "%%l"=="?" (set %%phpv="%%~k")^
      ))^&^
      (if not defined %%phpv (echo Error [@enwalue]: Expected name of variable with decimal value in parameter #1:2.^&exit /b 1))^
     ) else if ^^^!%%paux^^^! EQU 4 (^
      if ^^^!%%ptmp^^^! EQU 1 (set "%%pupi=^!%%ptmp^!")^
     ) else if ^^^!%%paux^^^! EQU 5 (^
      if 0 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 2 (set "%%psel=^!%%ptmp^!")^
     ) else if ^^^!%%paux^^^! EQU 6 (^
      set "%%ptrn=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 7 (^
      if 0 LEQ ^^^!%%ptmp^^^! if ^^^!%%ptmp^^^! LEQ 3 (set "%%prai=^!%%ptmp^!")^
     ) else if ^^^!%%paux^^^! EQU 8 (^
      if ^^^!%%ptmp^^^! EQU 1 (set "%%peco=^!%%ptmp^!")^
     ) else (^
      (if ^^^!%%paux^^^! EQU 2 (set "%%paux=tgn") else if ^^^!%%paux^^^! EQU 3 (set "%%paux=scn") else (set "%%paux="))^&^
      (if defined %%paux for /F %%k in ('echo %%%%ptmp%%') do (set "%%p^!%%paux^!=%%~k"))^
     ))^
    ))^
   ))^&^
   (if not defined %%ptgn (set "%%ptgn=^!%%prtn^!"^&set "%%prtn="))^&(if not defined %%pscn (set "%%pscn=^!%%ptgn^!"))^
  ))^&(if not defined %%peco (echo Error [@enwalue]: Absent parameters, verify spaces.^&exit /b 1))^&^
  set "%%pamp=1^^^&1"^&(set %%plbr="(")^&(set %%prbr=")")^&(for %%a in (amp lbr rbr) do (call set "wds_gev_%%a=%%wds_gev_%%a:~-2,1%%"))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@enwalue]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  set "%%ptmp=WScript.Echo "^&^
  (^
   (echo Dim hpv, tgn, scn, res, rtn, trn)^&^
   (for %%a in (hpv,tgn,scn) do if %%a==hpv (echo %%a = ^^^!wds_gev_%%a^^^!) else (echo %%a = "^!wds_gev_%%a^!"))^&^
   (echo trn = 0)^&^
   (if ^^^!%%phpv^^^! NEQ 0 if ^^^!%%pupi^^^! NEQ 1 (^
    (echo hpv = wmo.PidOfWindow^^^!%%plbr^^^!hpv^^^!%%prbr^^^!)^&^
    (echo If CLng^^^!%%plbr^^^!hpv^^^!%%prbr^^^! = 0 Then)^&^
    (echo  trn = 10 : ^^^!%%ptmp^^^!"%%paux=10" : ^^^!%%ptmp^^^!"Invalid window handle")^&^
    (echo End If)^
   ))^&^
   (echo If trn = 0 Then)^&^
   (echo  trn = wmo.EnvironSet^^^!%%plbr^^^!hpv, tgn, scn, ^^^!%%psel^^^!^^^!%%prbr^^^!)^&^
   (echo  If trn = 10 Then)^&^
   (echo   ^^^!%%ptmp^^^!"%%paux=0" : ^^^!%%ptmp^^^!"^!%%ptgn^!=" : trn = -1 : tgn = "")^&^
   (echo  Else)^&^
   (echo   If Err.Number Or trn Then)^&^
   (echo    If Err.Number Then)^&^
   (echo     ^^^!%%ptmp^^^!"%%paux=10" : ^^^!%%ptmp^^^!Err.Description : Err.Clear)^&^
   (echo    Else)^&^
   (echo     ^^^!%%ptmp^^^!"%%paux=" ^^^!%%pamp^^^! trn : ^^^!%%ptmp^^^!tgn)^&^
   (echo    End If)^&^
   (echo   Else)^&^
   (echo    ^^^!%%ptmp^^^!"%%paux=0" : ^^^!%%ptmp^^^!"^!%%ptgn^!=" ^^^!%%pamp^^^! wmo.GetDosString^^^!%%plbr^^^!tgn, ^^^!%%peco^^^!^^^!%%prbr^^^!)^&^
   (echo   End If)^&^
   (echo  End If)^&^
   (echo End If)^&^
   set "%%paux=1"^&^
   (for %%a in (rtn,trn) do if defined wds_gev_%%a (^
    (if defined %%paux (^
     (echo If trn Then rtn = 1 Else rtn = 0)^&^
     (echo rtn = ^^^!%%plbr^^^!1 + trn ^^^!%%prbr^^^! \ 2 : If rtn Then rtn = 1)^&^
     set "%%paux="^
    ))^&^
    (echo ^^^!%%ptmp^^^!"^!wds_gev_%%a^!=" ^^^!%%pamp^^^! %%a)^
   ))^
  )^>^>"^!%%pfnm^!"^&^
  set "%%paux=%%paux"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%pfnm:~0,-4^!"') do (^
    (if "^!%%paux^!"=="%%paux" (^
     set "%%a"^
    ) else (^
     (if ^^^!%%paux^^^! NEQ 0 (^
      (if ^^^!%%prai^^^! EQU 3 (^
       (if ^^^!%%peco^^^! EQU 0 (set "^!%%ptgn^!=%%a") else (echo "^!%%ptgn^!=%%a"))^
      ) else if 0 LSS ^^^!%%prai^^^! (^
       (echo Error [@enwalue] #^^^!%%paux^^^!: %%a.)^&(if ^^^!%%prai^^^! EQU 2 (exit /b 1))^
      ))^&^
      set "%%paux=0"^
     ) else (^
      (if ^^^!%%peco^^^! EQU 0 (set "%%a") else (echo "%%a"))^
     ))^
    ))^
   )^
  ) ^|^| (if "^!%%paux^!"=="%%paux" (echo Error [@enwalue]: R/W disk conflict or vbscript error.^&exit /b 1)))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (amp,aux,eco,fnm,hpv,lbr,rai,rbr,rtn,scn,sel,tmp,tgn,trn,upi) do (set "wds_gev_%%a="))^
 ) else (echo Error [@enwalue]: Absent parameters.^&exit /b 1)) else set wds_gev_aux=

::               @radix - converts string with given radix to specifed target radix, supports custom collation of digits.
::                        %~1 == name of variable to return result;
::                        %~2 == name of variable with number of source radix or its value in quotation marks;
::                      Optional parameters, must follow internal identifier and marker ":" (names of variables or quoted values):
::                           - specification of source radix, one of next 3 parameters is required:
::                      1:%~3 == radix size in range [2..214], without collation - in range [2..256] (see `8:%~10`);
::                      2:%~4 == the string of symbols for explicit collation of digits (non-empty conceals input of `1:%~3`);
::                      3:%~5 == the string of symbol codes for explicit collation of digits (conceals input of `1:%~3` & `2:%~4`);
::                           - specification of target radix, one of next 3 parameters is required:
::                      4:%~6 == radix size in range [2..214], without collation - in range [2..256] (see `9:%~11`);
::                      5:%~7 == the string of symbols for explicit collation of digits (non-empty conceals input of `4:%~6`);
::                      6:%~8 == the string of symbol codes for explicit collation of digits (conceals input of `4:%~6` & `5:%~7`);
::                      Optional parameter:
::                      7:%~9 == the length of output value (name of variable or quoted value):
::                               [in]  - the output length to set, default is "-1" to not change;
::                               [out] - if `8:%~10` is variable name, returns length of result;
::                               - cuts left side of result if length is smaller, otherwise adds zero symbols (or zero codes);
::                      Optional key parameters:
::                      8:%~10== input value contains string of hexadecimal codes (`1`), default `0` for collated string;
::                      9:%~11== output value will contain string of hex-codes (`1`), default `0` for collated string;
::                      A:%~12== output value will use random collation of symbols to radix digits (`1`), default is `0`;
::                               - this key conceals any input of `5:%~7` & `6:%~8`, it requires:
::                                        #1. valid input value of radix in `4:%~6`, values of `5:%~7` & `7:%~9` are ignored;
::                                        #2. variable name `5:%~7` or `7:%~9` to return generated collation;
::                      B:%~13== key parameter to echo result instead of assigning (`1`), default is `0`.
::             Notes. #1: if parameters have explicit quoted values & they have spaces, replace them by /CHR{20};
::                    #2: if parameters `1:%~3`..`6:%~8` have variable names, their output values will correspond parameterization;
::                    #3: allowed radix symbols have ASCII codes 32..126 & 128..255, except: ! " % & ' < > ^ |
::                    #4: the default mapping of symbols depends on radix size. For sizes `<=86` it selects 1st symbols of string:
::                               0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_[]{}~@#$+=.,`; :\/*?()
::                        until given radix size. For bigger sizes it gets 1st symbol with ASCII code 32 until radix (see note #3);
::                    #5: if the source radix use default collation and `<= 36`, the digit symbols are case insensitive;
::                    #6: the mapping of radix `<= 86` gives reliable string, the bigger sizes become localization dependent - in
::                        case of ms-dos strings of english code page 437 the maximum size of radix is 107 - the next symbol with
::                        ASCII code `195` is control. The latter one will have different values for another code pages;
::                    #7: Windows folder and file names support symbols of default mapping for radix 79, but the last symbol #79 is 
::                        space (` `) and it can be lost if this digit will happen at the end of the file or folder;
::                    #8: if `8:%~10` or `9:%~11` is set, the corresponding number is a sequence of 2-symbol substrings, containing
::                        hexadecimal values of digits, they change from zero (`00`) until radix value, e.g.: 256 <-> `FF` (`255`);
::                    #9: it supports numbers recombination of same radix but with different mapping.
::                Sample: %@radix% x64val "3456789120" 1:"10" 4:"16" | echo x10 -^> x16: !x64val!
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @radix=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_rad_aux for /F %%y in ('echo wds_rad_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13" %%a in ('echo.%%%%yaux%%') do (^
   (for %%n in ("1=Error [@radix]: ","2=arameter #","3=WScript.Echo ","tgn=%%~a","son=%%b","sov=","srn=","srv=","ssn=","ssv=","scn=","scv=","trn=","trv=","tsn=","tsv=","tcn=","tcv=","len=","lev=-1","sma=1","tma=1","rnd=0","eco=0","lbr=","rbr=","amp=") do (set "%%y%%~n"))^&^
   (if ^^^!%%yeco^^^! NEQ 0 (call echo %%%%y1%%Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%yson (echo ^^^!%%y1^^^!Undefined source string in ^^^!%%y2^^^!2.^&exit /b 1))^&^
   (for %%n in (%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m) do if not "%%n"=="" (^
    set "%%yaux=%%n"^&set "%%ytmp=^!%%yaux:~2^!"^&^
    (if defined %%ytmp (set /a "%%yaux=0x^!%%yaux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
      (if ^^^!%%yaux^^^! EQU 1 (set "%%ylbr=srn"^
      ) else if ^^^!%%yaux^^^! EQU 2 (set "%%ylbr=ssn"^
      ) else if ^^^!%%yaux^^^! EQU 3 (set "%%ylbr=scn"^
      ) else if ^^^!%%yaux^^^! EQU 4 (set "%%ylbr=trn"^
      ) else if ^^^!%%yaux^^^! EQU 5 (set "%%ylbr=tsn"^
      ) else if ^^^!%%yaux^^^! EQU 6 (set "%%ylbr=tcn"^
      ) else if ^^^!%%yaux^^^! EQU 7 (set "%%ylbr=len"^
      ) else if ^^^!%%yaux^^^! EQU 8 (set "%%ylbr=sma"^&set "%%yrbr=1"^&set "%%yamp=0"^
      ) else if ^^^!%%yaux^^^! EQU 9 (set "%%ylbr=tma"^&set "%%yrbr=1"^&set "%%yamp=0"^
      ) else if ^^^!%%yaux^^^! EQU 10 (set "%%ylbr=rnd"^&set "%%yrbr=1"^&set "%%yamp=1"^
      ) else if ^^^!%%yaux^^^! EQU 11 (set "%%ylbr=eco"^&set "%%yrbr=1"^&set "%%yamp=1"))^&^
      (if defined %%ylbr (^
       (if defined %%yrbr (^
        (if ^^^!%%yrbr^^^! EQU ^^^!%%ytmp^^^! (set "%%y^!%%ylbr^!=^!%%yamp^!"))^
       ) else (^
        set "%%y^!%%ylbr^!=^!%%ytmp^!"^
       ))^&^
       set "%%ylbr="^&set "%%yrbr="^&set "%%yamp="^
      ))^
    ))^
   ))^
  ))^&(if not defined %%yeco (echo Error [@radix]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (for %%a in (so,sr,ss,sc,tr,ts,tc,le) do if defined %%y%%an for /F %%b in ('echo %%%%y%%an%%') do (^
   (if "%%~b"==%%b (^
    set "%%y%%an="^&set "%%y%%av=%%~b"^&set "%%y%%av=^!%%y%%av:/CHR{20}= ^!"^
   ) else (^
    set "%%y%%an=%%~b"^&set "%%y%%av=^!%%~b^!"^
   ))^
  ))^&^
  (if ^^^!%%yrnd^^^! EQU 1 (set "%%ytsv="^&set "%%ytcv="))^&^
  (for %%a in (s,t) do (^
   (if %%a==s (set "%%yaux=source"^&set "%%ylbr=1:3") else (set "%%yaux=target"^&set "%%ylbr=4:6"))^&^
   (if not defined %%y%%arv if not defined %%y%%asv if not defined %%y%%acv (echo ^^^!%%y1^^^!No any data for ^^^!%%yaux^^^! radix.^&exit /b 1))^&^
   (if defined %%y%%asv (set "%%y%%arv=0") else if defined %%y%%acv (set "%%y%%arv=0") else (^
    set "%%ytmp="^&(if ^^^!%%y%%ama^^^! EQU 1 (set "%%yrbr=214") else (set "%%yrbr=256"))^&^
    ((set /a "%%ytmp=0x^!%%y%%arv^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%ytmp^^^! LSS 2 (set "%%ytmp=") else if 0x^^^!%%yrbr^^^! LSS ^^^!%%ytmp^^^! (set "%%ytmp="))^
    ))^&^
    (if not defined %%ytmp (echo ^^^!%%y1^^^!The ^^^!%%yaux^^^! radix in p^^^!%%y2^^^!^^^!%%ylbr^^^! must be in range [2..^^^!%%yrbr^^^!].^&exit /b 1))^
   ))^&^
   (if not defined %%y%%asv (set %%y%%asv=""))^&(if not defined %%y%%acv (set %%y%%acv=""))^
  ))^&^
  (if defined %%ylev (^
   (if ^^^!%%ylev^^^! NEQ -1 (^
    ((set /a "%%ytmp=0x^!%%ylev^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%ytmp^^^! EQU 0 (set "%%ylev=") else if 29952 LSS ^^^!%%ytmp^^^! (set "%%ylev="))^
    ))^
   ))^
  ))^&^
  (if not defined %%ylev (echo ^^^!%%y1^^^!The target number length in p^^^!%%y2^^^!7:9 must be in range [1..7500] or set `-1` to do not changes.^&exit /b 1))^&^
  (if ^^^!%%yrnd^^^! EQU 1 (^
   (if not defined %%ytsn if not defined %%ytcn (^
    echo ^^^!%%y1^^^!P^^^!%%y2^^^!5:7 or p^^^!%%y2^^^!6:8 must be defined to return collation.^&exit /b 1^
   ))^&^
   set "%%ytrv=-^!%%ytrv^!"^
  ))^&^
  (set %%yquo="")^&set "%%yamp=1^^^&1"^&(set %%ylbr="(")^&(set %%yrbr=")")^&(for %%a in (quo amp lbr rbr) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  set "%%yaux=so,ss,sc,ts,tc"^&^
  (for %%a in (^^^!%%yaux^^^!) do (call set %%y%%av="%%%%y%%av:^!%%yquo^!=%%"))^&^
  (if ^^^!%%ysov^^^!=="" (echo ^^^!%%y1^^^!Undefined source string in ^^^!%%y2^^^!2.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo ^^^!%%y1^^^!COM registration failed.^&exit /b 1) else (set %%a))^&set "%%yfnm=%%a"^
  ))^&^
  set "%%yaux=^!%%yaux^!,sr,tr,le"^&^
  (echo Dim tg, ^^^!%%yaux^^^!)^>^>"^!%%yfnm^!"^&^
  (for %%a in (^^^!%%yaux^^^!) do (echo %%a = ^^^!%%y%%av^^^!)^>^>"^!%%yfnm^!")^&^
  (if 0 LSS ^^^!%%ysrv^^^! if ^^^!%%ysrv^^^! LSS 37 (^
  (echo so = UCase^^^!%%ylbr^^^!so^^^!%%yrbr^^^!)^>^>"^!%%yfnm^!"^
  ))^&^
  (echo tg = wmo.StrRadix^^^!%%ylbr^^^!^^^!%%ysma^^^!, sr, ss, sc, so, ^^^!%%ytma^^^!, tr, ts, tc, le^^^!%%yrbr^^^!)^>^>"^!%%yfnm^!"^&^
  (echo If Err.Number Then)^>^>"^!%%yfnm^!"^&^
  (echo  ^^^!%%y3^^^!"%%yaux=1" : ^^^!%%y3^^^!Err.Description : Err.Clear : WScript.Quit 0)^>^>"^!%%yfnm^!"^&^
  (echo Else)^>^>"^!%%yfnm^!"^&^
  (echo  ^^^!%%y3^^^!"%%yaux=0")^>^>"^!%%yfnm^!"^&^
  (echo End If)^>^>"^!%%yfnm^!"^&^
  (echo le = Len^^^!%%ylbr^^^!tg^^^!%%yrbr^^^!)^>^>"^!%%yfnm^!"^&^
  (for %%a in (sr,ss,sc,tg,tr,ts,tc,le) do if defined %%y%%an (^
   (echo ^^^!%%y3^^^!"^!%%y%%an^!=" ^^^!%%yamp^^^! CStr^^^!%%ylbr^^^!%%a^^^!%%yrbr^^^!)^>^>"^!%%yfnm^!"^
  ))^&^
  set "%%yaux=%%yaux"^&^
  ((call move /y "^!%%yfnm^!" "^!%%yfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('start /b /i /abovenormal cscript //nologo "^!%%yfnm:~0,-4^!"') do (^
    (if "^!%%yaux^!"=="%%yaux" (^
     set "%%a"^
    ) else if ^^^!%%yaux^^^! NEQ 0 (^
     echo ^^^!%%y1^^^!%%a.^&exit /b 1^
    ) else (^
     (if ^^^!%%yeco^^^! EQU 0 (set "%%a") else (echo "%%a"))^
    ))^
   )^
  ) ^|^| (echo ^^^!%%y1^^^!R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%yeco^^^! NEQ 1 for %%a in (1,2,3,amp,aux,eco,fnm,lbr,len,lev,quo,rbr,rnd,scn,scv,sma,son,sov,srn,srv,ssn,ssv,tcn,tcv,tgn,tma,tmp,trn,trv,tsn,tsv) do (set "%%y%%a="))^
 ) else (echo Error [@radix]: Absent parameters.^&exit /b 1)) else set wds_rad_aux=

::                @code - encodes string to sequence of hexadecimal codes of symbols or decodes this sequence to string.
::                        %~1 == variable name to return result string;
::                        %~2 == the source string - variable name or quoted string with `/CHR{20}` instead of space symbols;
::                      Optional parameters, must follow internal identifier and marker ":":
::                      1:%~3 == key parameter to decode sequence of codes (`1`), default is `0` to encode;
::                      Next 2 parameters to set prefix & suffix of codes, variable names or quoted strings:
::                      2:%~4 == prefix of code, default is `""`;
::                      3:%~5 == suffix of code, default is `""`;
::                      Optional key parameters:
::                      4:%~6 == read input parameter from the memory of process `1`, default `0` for usual read;
::                      5:%~7 == defines output of result & can have next values:
::                               `0`  - assign it to `%~1`;
::                               `1`  - print it for assigning to `%~1`;
::                               `2`  - print it as is.
::                  Note: see macros @str_encode & @str_decode for selective internal encoding & decoding.
::                Sample: %@code% resstr "Custom/CHR{20}string" 2:"/CHR{" 3:"}" | echo resstr = !resstr!
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @code=^
 for %%x in (1 2) do if %%x EQU 2 (if defined wds_cod_aux for /F %%p in ('echo wds_cod_') do (^
  (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo.%%%%paux%%') do (^
   (for %%h in ("tgt=%%~a","src=%%b","dec=0","pfx=""","sfx=""","mem=0","eco=0","lbr=0","rbr=1") do (set "wds_cod_%%~h"))^&^
   (if ^^^!%%pmem^^^! NEQ 0 (echo Error [@code]: Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
   (if not defined %%ptgt (echo Error [@code]: The value of parameter #1 is the incorrect ms-dos name.^&exit /b 1))^&^
   (if "%%~b"=="" (echo Error [@code]: The parameter #2 has not input value.^&exit /b 1))^&^
   (for %%h in (%%~c,%%~d,%%~e,%%~f,%%~g) do if not "%%h"=="" (^
    set "%%paux=%%h"^&set "%%ptmp=^!%%paux:~2^!"^&^
    (if defined %%ptmp (set /a "%%paux=0x^!%%paux:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
     (if ^^^!%%paux^^^! EQU 1 (set "%%plbr=dec"^
     ) else if ^^^!%%paux^^^! EQU 2 (set "%%ppfx=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 3 (set "%%psfx=^!%%ptmp^!"^
     ) else if ^^^!%%paux^^^! EQU 4 (set "%%plbr=mem"^
     ) else if ^^^!%%paux^^^! EQU 5 (set "%%plbr=eco"^&set "%%prbr=2"))^&^
     (if defined %%plbr (^
      ((set /a "%%paux=0x^!%%ptmp^!"^>NUL 2^>^&1)^>NUL ^&^& (^
       if 0 LSS ^^^!%%paux^^^! if ^^^!%%paux^^^! LEQ ^^^!%%prbr^^^! (set "%%p^!%%plbr^!=^!%%paux^!")^
      ))^&^
      set "%%plbr="^&set "%%prbr=1"^
     ))^
    ))^
   ))^
  ))^&(if not defined %%peco (echo Error [@code]: Absent parameters, verify spaces.^&exit /b 1))^&^
  (set %%pquo="")^&set "%%pamp=1^^^&1"^&(set %%plbr="(")^&(set %%prbr=")")^&(for %%a in (amp lbr rbr) do (call set "wds_cod_%%a=%%wds_cod_%%a:~-2,1%%"))^&^
  (for %%a in (src,pfx,sfx) do if not ^^^!wds_cod_%%a^^^!=="" for /F %%b in ('echo %%wds_cod_%%a%%') do (^
   set "%%paux="^&^
   (if ^^^!%%pmem^^^! NEQ 0 (^
    set "%%ptmp=^!%%~b^!"^>NUL 2^>^&1^&^
    (if defined %%ptmp (^
     set "%%paux=1"^
    ) else if ^^^!%%pmem^^^! EQU 1 (^
     echo Error [@code]: With key #4:6 the parameter #2 must be a variable name with assigned value.^&exit /b 1^
    ))^
   ))^&^
   (if defined %%paux (^
    set /a "%%pmem+=1"^>NUL^&set "wds_cod_%%a=%%~b"^
   ) else (^
    (if "%%~b"==%%b (set "wds_cod_%%a=%%~b"^&set "wds_cod_%%a=^!wds_cod_%%a:/CHR{20}= ^!") else (set "wds_cod_%%a=^!%%~b^!"))^&^
    ((call set "wds_cod_%%a=%%wds_cod_%%a:^!%%pquo^!=^!%%pquo^! ^!%%pamp^! Chr^!%%plbr^!34^!%%prbr^! ^!%%pamp^! ^!%%pquo^!%%"^>NUL 2^>^&1)^>NUL ^&^& (^
     (call echo "%%wds_cod_%%a:^!%%pquo^!=%%"^>nul)^>NUL 2^>^&1 ^&^&^ (echo.^>nul) ^|^| (^
      echo Error [@code]: Failed due to controls, try direct reading of strings from memory.^&exit /b 1^
     )^
    ))^&^
    (set wds_cod_%%a="^!wds_cod_%%a^!")^
   ))^
  ))^&^
  (if ^^^!%%psrc^^^!=="" (echo Error [@code]: The parameter #2 has not input value.^&exit /b 1))^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /v:on /e:on /r "^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo Error [@code]: COM registration failed.^&exit /b 1) else (set %%a))^&set "%%pfnm=%%a"^
  ))^&^
  (^
   set "%%ptmp=WScript.Echo "^&^
   (echo Dim res, tgt, src, pfx, sfx, i)^&^
   set "%%paux=1"^&^
   (for %%a in (src,pfx,sfx) do (^
    (if ^^^!%%paux^^^! LSS ^^^!%%pmem^^^! (^
     (echo res = wmo.EnvironSet^^^!%%plbr^^^!0, %%a, "^!wds_cod_%%a^!", 1^^^!%%prbr^^^!)^&^
     (echo If Err.Number Or res Then)^&^
     (echo  ^^^!%%ptmp^^^!"%%paux=" ^^^!%%pamp^^^! CStr^^^!%%plbr^^^!res^^^!%%prbr^^^!)^&^
     (echo  If Err.Number Then src = Err.Description : Err.Clear)^&^
     (echo  ^^^!%%ptmp^^^!src : WScript.Quit 0)^&^
     (echo End If)^
    ) else (^
     (echo %%a = ^^^!wds_cod_%%a^^^!)^
    ))^&^
    set /a "%%paux+=1"^>NUL^
   ))^&^
   (echo tgt = "")^&^
   (if ^^^!%%pdec^^^! EQU 0 (^
    (echo For i = 1 To Len^^^!%%plbr^^^!src^^^!%%prbr^^^!)^&^
    (echo  tgt = tgt ^^^!%%pamp^^^! pfx ^^^!%%pamp^^^! Right^^^!%%plbr^^^!"00" ^^^!%%pamp^^^! Hex^^^!%%plbr^^^!Asc^^^!%%plbr^^^!Mid^^^!%%plbr^^^!src, i, 1^^^!%%prbr^^^!^^^!%%prbr^^^!^^^!%%prbr^^^!, 2^^^!%%prbr^^^! ^^^!%%pamp^^^! sfx)^
   ) else (^
    (echo Dim lp, ls : lp = Len^^^!%%plbr^^^!pfx^^^!%%prbr^^^! : ls = Len^^^!%%plbr^^^!sfx^^^!%%prbr^^^!)^&^
    (echo For i = 1 To Len^^^!%%plbr^^^!src^^^!%%prbr^^^! Step lp + 2 + ls)^&^
    (echo  tgt = tgt ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!CInt^^^!%%plbr^^^!"^!%%pamp^!H" ^^^!%%pamp^^^! Mid^^^!%%plbr^^^!src, i + lp, 2^^^!%%prbr^^^!^^^!%%prbr^^^!^^^!%%prbr^^^!)^
   ))^&^
   (echo Next)^&^
   (echo ^^^!%%ptmp^^^!"%%paux=0" : tgt = wmo.GetDosString^^^!%%plbr^^^!tgt, ^^^!%%peco^^^!^^^!%%prbr^^^!)^&^
   (if ^^^!%%peco^^^! LSS 2 (^
    (echo ^^^!%%ptmp^^^!Chr^^^!%%plbr^^^!34^^^!%%prbr^^^! ^^^!%%pamp^^^! "^!%%ptgt^!=" ^^^!%%pamp^^^! tgt ^^^!%%pamp^^^! Chr^^^!%%plbr^^^!34^^^!%%prbr^^^!)^
   ) else (^
    (echo ^^^!%%ptmp^^^!tgt)^
   ))^
  )^>^>"^!%%pfnm^!"^&^
  set "%%paux=%%paux"^&^
  ((call move /y "^!%%pfnm^!" "^!%%pfnm:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('start /b /i /abovenormal cscript //nologo "^!%%pfnm:~0,-4^!"') do (^
    (if "^!%%paux^!"=="%%paux" (^
     set "%%a"^
    ) else (^
     (if ^^^!%%paux^^^! NEQ 0 (^
      (echo Error [@code] #^^^!%%paux^^^!: %%a.)^&exit /b 1^
     ) else (^
      (if ^^^!%%peco^^^! EQU 0 (set %%a) else (echo %%a))^
     ))^
    ))^
   )^
  ) ^|^| (echo Error [@code]: R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if ^^^!%%peco^^^! NEQ 1 for %%a in (amp,aux,dec,eco,fnm,lbr,mem,pfx,quo,rbr,sfx,src,tgt,tmp) do (set "wds_cod_%%a="))^
 ) else (echo Error [@code]: Absent parameters.^&exit /b 1)) else set wds_cod_aux=

::           @callstack - returns the current call stack in the specified `cmd.exe` command line interpreter process.
::                      It has only optional parameters, they must follow internal identifier and marker ":":
::                      1:%~1 == number of the cmd.exe process in the current stack of child processes where the call stack
::                               should be determined. A negative number is used to select the process number starting with
::                               the last child cmd.exe. The default value "-4" corresponds to the `cmd.exe` process of the
::                               current context in which the macro was called. The default value "-6" is used when `F:%~15`
::                               has value `1` and corresponds to the current context of macro call inside for-in-do block,
::                               for example: for /F ... %%a in ('cmd /d /q /v:on /e:on /r "!@callstack! ... F:1"') do ...;
::                      2:%~2 == explicit numerical value or variable name with input or output value. Specifies PID of the
::                               `cmd.exe` where the call stack should be determined. If an input value is specified, it 
::                               overrides `1:%~1`. In the case of variable name without any value in the calling context of
::                               macro, it will get PID using `1:%~1` and will assign it into this variable for next calls;
::                      3:%~3 == digital parameter to specify the number of the call stack string to return into result. The 
::                               1st call stack item has number `0`, the negative number is to set index from the last item
::                               and the value `-1` will return last string. If not specified, macro will print the raw call
::                               stack with line numbers, printing takes into account the value of parameter `E:%~14`;
::                      Optional parameters, but `3:%~3` or one of the next one must be specified:
::                      4:%~4 == variable name to return raw call stack as is;
::                      5:%~5 == variable name to return zero argument of command lines in the call stack;
::                      6:%~6 == variable name to return 1st argument of command lines in the call stack;
::                      7:%~7 == variable name to return 2nd argument of command lines in the call stack;
::                      8:%~8 == variable name to return 3rd argument of command lines in the call stack;
::                      9:%~9 == variable name to return 4th argument of command lines in the call stack;
::                      A:%~10== variable name to return 5th argument of command lines in the call stack;
::                      B:%~11== variable name to return 6th argument of command lines in the call stack;
::                      C:%~12== variable name to return 7th argument of command lines in the call stack;
::                      D:%~13== variable name to return 8th argument of command lines in the call stack;
::                            - parameters `5:%~5`-`D:%~13` allow conversion of strings using rules for ms-dos command line 
::                              arguments, identical to standard %~n0, %~d0 etc. It can be set as `myvarname~"format"`.
::                              For instance, to get only file names of the call stack use next specification of `5:%~5`:
::                                5:MyVariableNameToGetResult~nx
::                              The suffix `~nx` specifes to get only command name (`n`) and extension (`x`) from string.
::                      Optional key parameters:
::                      E:%~14== the default value `1` is to return full call stack containing calls of batch files and labels,
::                               `2` to return only calls of batch files in the stack, `3` to return only calls of labels. In 
::                               order to suppress error messages related to recurrent calls, use any of this value multiplied 
::                               by `4`;
::                      F:%~15== echo result instead of assigning it to variables (`1`), default is `0`.
::      Restrictions. #1: All called strings (command with its arguments) in stack must be unique or unequal to each other;
::                    #2: Strings of path to running file, file name and arguments of the called files and functions (labels)
::                        can only have symbols with ASCII codes in the range 0x29 and 0x7E. It means that they can have only
::                        english letters or another symbols from this code range above;
::                    #3: The explicit use of control symbols `!` and `%` inside strings is prohibited because they all are
::                        interpreted as delimiters of variables. It also internally drops controls `>`, `<`, `&` and `::`, the
::                        symbol `#` can not be used as 1st symbol of `%0` or `%1` arguments;
::                    #4: Any other usages of control symbols in the call string will work only if its string value in the file
::                        will coincide with its representation in the memory;
::                    #5: It will be unable to find any call like this "call myfile.bat %~2 %%3 %4" or similar one, because when
::                        it starts it doesn't have information about calling arguments in the given context, so it is unable to
::                        get context values of `%1`, `%2` etc. The work around for sample above:
::                         set "var1=%~2"&set "var2=%~3"&call set "var3=%%4"&call myfile.bat !var1! %%var2%% %var3%;
::                    #6: It identifies the call inside body of function, but it interprets any string "exit " as the end of its
::                        text segment. If it's wrong, move "exit" strings below the called item inside function (label) segment;
::                    #7: When looking up the values of argument variables in memory, it need a stored context with their values, 
::                        do not assign multiple values to argument variables for several calls, or use `setlocal` to create a 
::                        copy of the context in memory for each call;
::                    #8: All variable string arguments can be empty string. But the resulting call argument string can't consist 
::                        only of spaces or can't be empty;
::                    #9: It has next limitations on recursive calls with several inclusions of same items in the stack:
::                      - recursive calls contain several calls of one string. In order to have its string searchable at least one
::                        of argument variables must use annotation `%` or `!`, since the `%%` annotation is not expanded when it
::                        is stored in memory;
::                      - any loops of calls create ambiguity in the order of calls. If it creates error and to resolve it, add 
::                        variables as arguments with assigning values specific to the current context for every recursive call.
::                        Because the order of variable values within ambiguous loop is also uncertain, the order of given values
::                        can be defined only by adding them into calls before recursive call. Their later use inside a call loop
::                        defines proper order of calls inside stack with ambiguity;
::                      - when resolving ambiguities in recursions, the empty value of any argument variable is always considered
::                        first in order of initialisation sequence;
::                      - any recursive calls of functions (labels) must have some arguments, otherwise it will be dropped;
::                   #10: It doesn't support network locations, all started files must reside on the local disk for correct work;
::                   #11: To enable memory and disk searches, the line used to run the batch file must include the file extension.
::                        Specifying a path is optional; relative paths are also allowed;
::                   #12: A batch file is included in the call stack only if it was called using the `call` command. If you simply
::                        call a file as is, the macro will not find it in the stack.
::             Notes. #1: Macro prints directly to screen error messages if they had happen, follow their information to resolve;
::                    #2: See also the note #1 of %@taskinfo% macro.
::                Sample: %@callstack% 3:2 4:resvar 5:onlycommandpath~dp E:1
::          Dependencies: @library.waitmds.com, @library.waitmds.vbs, @obj_newname.
::
set @callstack=^
 for %%x in (1 2) do if %%x EQU 2 (for /F %%y in ('echo wds_bcs_') do if defined %%ypi (^
  (if not "^!%%ya:%%%%ya%%=^!"==" " for /F "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16" %%a in ('echo.%%%%ya%%') do (^
   (for %%q in (%%~a,%%~b,%%~c,%%~d,%%~e,%%~f,%%~g,%%~h,%%~i,%%~j,%%~k,%%~l,%%~m,%%~n,%%~o,%%~p) do if not "%%q"=="" (^
    set "%%ya=%%q"^&set "%%yt=^!%%ya:~2^!"^&^
    (if defined %%yt (set /a "%%ya=0x^!%%ya:~0,1^!"^>NUL 2^>^&1)^>NUL ^&^& (^
      set "%%ym="^&(if ^^^!%%ya^^^! LSS 4 (set "%%ym=1") else if 13 LSS ^^^!%%ya^^^! (set "%%ym=1"))^&^
      (if defined %%ym (^
       (if ^^^!%%ya^^^! EQU 2 (set "%%yz=1 2") else (set "%%yz=1"))^&^
       (for %%r in (^^^!%%yz^^^!) do if defined %%ym (^
        (for /F "tokens=* delims=-0123456789" %%s in ('"echo.^!%%yt^!?"') do if not "%%s"=="?" (set "%%ym="))^&^
        (if %%r EQU 1 if not defined %%ym if ^^^!%%ya^^^! EQU 2 (^
         if defined ^^^!%%yt^^^! (set "%%ym=1"^&call set "%%yt=%%^!%%yt^!%%") else (set "%%ypn=^!%%yt^!")^
        ))^
       ))^
      ) else (set "%%ym=1"))^&^
      (if defined %%ym (^
             (if ^^^!%%ya^^^! EQU 1 (set "%%ynp=^!%%yt^!"^&set "%%ypi=0"^
       ) else if ^^^!%%ya^^^! EQU 2 (if 0 LSS ^^^!%%yt^^^! (set "%%ypi=^!%%yt^!"^&set "%%ynp=0"^&set "%%ypn=")^
       ) else if ^^^!%%ya^^^! EQU 3 (set "%%yn=^!%%yt^!"^
       ) else if ^^^!%%ya^^^! EQU 4 (set "%%yrn=^!%%yt^!"^
       ) else if ^^^!%%ya^^^! EQU 14 ((echo ,2,3,4,8,12, ^| findstr /C:",^!%%yt^!,")^>NUL 2^>^&1 ^&^& (^
        (if 3 LSS ^^^!%%yt^^^! (set "%%ysk=1"^&set /a "%%yt/=4"^>NUL 2^>^&1))^&^
        set /a "%%ymo=^!%%yt^!-1"^>NUL 2^>^&1^
       )) else if ^^^!%%ya^^^! EQU 15 (if "^!%%yt^!"=="1" (set "%%ye=1")^
       ) else if 4 LSS ^^^!%%ya^^^! if ^^^!%%ya^^^! LSS 14 (^
        set /a "%%ya-=5"^>NUL^&^
        (for /F "tokens=1,2 delims=~" %%r in ('echo.%%%%yt%%') do (^
         set "%%yta=1"^&set "%%y^!%%ya^!n=%%r"^&set "%%y^!%%ya^!f=~%%s"^
        ))^
       ))^
      ))^
    ))^
   ))^
  ))^&^
  set "%%ya=library.waitmds."^&set "%%yv=^!%%ya^!com,^!%%ya^!vbs,obj_newname"^&set "%%ym=^!%%ya^!testruns,^!%%ya^!filepath"^&^
  (for /F "tokens=*" %%a in ('%%%%yc%%"^!@unset_alev^! 1:^!%%yv^! 3:^!%%ym^! 2:%%y 5:0 6:1"') do (^
   set %%a^&echo %%a^
  ))^&^
  set "%%yv=@^!%%yv:,=,@^!,^!%%ym^!"^&^
  (if ^^^!%%ypi^^^! EQU 0 if "^!%%ynp^!"=="-" if ^^^!%%ye^^^! EQU 1 (set "%%ynp=-6") else (set "%%ynp=-4"))^&^
  (set %%ym="^^^|")^&(for /F "tokens=*" %%a in ('"set %%%%ym:~-2,1%% find "%%y""') do (echo "%%a"))^
 ) else if defined %%yc (^
  (for %%a in ("np=-","pi=0","pn=","n=","rn=","rv=","sk=","mo=0","co=","ta=") do (set "%%y%%~a"))^&^
  (for /L %%a in (0,1,8) do (set "%%y%%an="^&set "%%y%%af="^&set "%%y%%av="))^&^
  (for /F "tokens=*" %%a in ('start /b /i /realtime %%%%yc%%"^!@callstack^! %%%%ya%%"') do (set %%a))^&^
  (if defined %%yn if not defined %%yrn if not defined %%ypn (^
   set "%%ya=1"^&(for /L %%a in (0,1,8) do if defined %%ya if defined %%y%%an (set "%%ya="))^&^
   (if defined %%ya (echo ^^^!%%y0^^^!No variables to return result.^&exit /b 1))^
  ))^&^
  (for /F "tokens=*" %%a in ('%%%%yc%%"^!@library.waitmds.com^!"') do (^
   (if "%%~a"==%%a if %%a=="" (echo ^^^!%%y0^^^!COM registration failed.^&exit /b 1) else (set %%a))^&set "%%ys=%%a"^
  ))^&^
  (for %%a in (^^^!%%yv^^^!) do (set "%%a="))^&^
  (set %%yq="")^&set "%%ym=1^^^&1"^&(set %%yl="(")^&(set %%yr=")")^&(set %%yv="^^^<")^&(for %%a in (q m l r v) do (call set "%%y%%a=%%%%y%%a:~-2,1%%"))^&^
  set "%%yt=WScript.Echo "^&set "%%yz=Chr(34)"^&set "%%yy=Chr(10)"^&^
  set "%%y1=^!%%yt^!^!%%yz^! ^!%%ym^! ^!%%yq^!%%yco=^!%%yq^! ^!%%ym^! rc ^!%%ym^! ^!%%yz^!"^&^
  set "%%y2=^!%%yt^!^!%%yz^! ^!%%ym^! ^!%%yq^!%%yre=1^!%%yq^! ^!%%ym^! ^!%%yz^!"^&^
  set "%%yf=Err.Clear : ^!%%yt^!^!%%yq^!0^!%%yq^! : WScript.Quit 0"^&^
  (^
   (echo Dim rr, tr, jr, rc, pi, np, ur, i, s, p, ra, n : pi = ^^^!%%ypi^^^! : np = ^^^!%%ynp^^^!)^&^
   (echo If pi = 0 Then)^&^
   (echo  wmo.GetTaskInfo 0,,,s)^&^
   (echo  p = Split^^^!%%yl^^^!s, ","^^^!%%yr^^^! : ur = UBound^^^!%%yl^^^!p^^^!%%yr^^^!)^&^
   (echo  If np ^^^!%%yv^^^! 0 Then np = ur + np)^&^
   (echo  If 0 ^^^!%%yv^^^!= np And np ^^^!%%yv^^^!= ur Then pi = p^^^!%%yl^^^!np^^^!%%yr^^^! Else pi = 0)^&^
   (echo  If pi = 0 Then)^&^
   (echo   rc = -7 : ^^^!%%y1^^^!)^&^
   (echo   ^^^!%%yt^^^!"^!%%y0^!The index ^!%%ynp^! is out of range")^&^
   (echo   ^^^!%%y2^^^!)^&(echo   ^^^!%%yf^^^!)^&^
   (echo  End If)^&^
   (echo End If)^&^
   (echo rr = wmo.BatchCallStack^^^!%%yl^^^!pi, ^^^!%%ymo^^^!, jr, tr, rc, 1^^^!%%yr^^^!)^&^
   (if defined %%ysk (set "%%ya=rc ^!%%yv^! 0") else (set "%%ya=CBool(rc)"))^&^
   (echo If ^^^!%%ya^^^! Then)^&^
   (echo  ^^^!%%y1^^^!)^&^
   (echo  ^^^!%%yt^^^!"^!%%y0^!Internal errors:")^&^
   (echo  Dim j : j = Split^^^!%%yl^^^!jr, ^^^!%%yy^^^!^^^!%%yr^^^!)^&^
   (echo  For i = 0 To UBound^^^!%%yl^^^!j^^^!%%yr^^^! : ^^^!%%yt^^^!j^^^!%%yl^^^!i^^^!%%yr^^^! : Next)^&^
   (echo  ^^^!%%y2^^^!)^&^
   (echo End If)^&^
   (echo If rc ^^^!%%yv^^^! 0 Then ^^^!%%yf^^^!)^&^
   (echo ra = Split^^^!%%yl^^^!rr, ^^^!%%yy^^^!^^^!%%yr^^^! : ur = UBound^^^!%%yl^^^!ra^^^!%%yr^^^!)^&^
   (if defined %%yn (^
    (echo n = ^^^!%%yn^^^! : If n ^^^!%%yv^^^! 0 Then n = ur + 1 + n)^&^
    (echo If n ^^^!%%yv^^^! 0 Or ur ^^^!%%yv^^^! n Then)^&^
    (echo  rc = -8 : ^^^!%%y1^^^!)^&^
    (echo  ^^^!%%yt^^^!"^!%%y0^!The call stack item index ^!%%yn^! is out of range")^&^
    (echo  ^^^!%%y2^^^!)^&(echo  ^^^!%%yf^^^!)^&^
    (echo Else)^&^
    (if defined %%yrn (echo  ^^^!%%yt^^^!^^^!%%yz^^^! ^^^!%%ym^^^! "%%yrv=" ^^^!%%ym^^^! ra^^^!%%yl^^^!n^^^!%%yr^^^! ^^^!%%ym^^^! ^^^!%%yz^^^!))^&^
    (if defined %%yta (^
     (echo  ra = Split^^^!%%yl^^^!Split^^^!%%yl^^^!tr, Chr^^^!%%yl^^^!13^^^!%%yr^^^!^^^!%%yr^^^!^^^!%%yl^^^!n^^^!%%yr^^^!, ^^^!%%yy^^^!^^^!%%yr^^^!)^&^
     (for /L %%a in (0,1,8) do if defined %%y%%an (^
      (echo  If %%a ^^^!%%yv^^^!= ur Then s = ra^^^!%%yl^^^!%%a^^^!%%yr^^^! else s = "")^&^
      (echo  ^^^!%%yt^^^!^^^!%%yz^^^! ^^^!%%ym^^^! "%%y%%av=" ^^^!%%ym^^^! s ^^^!%%ym^^^! ^^^!%%yz^^^!)^
     ))^
    ))^&^
    (echo End If)^&^
    (if defined %%ypn (^
     (echo ^^^!%%yt^^^!^^^!%%yz^^^! ^^^!%%ym^^^! "^!%%ypn^!=" ^^^!%%ym^^^! CStr^^^!%%yl^^^!pi^^^!%%yr^^^! ^^^!%%ym^^^! ^^^!%%yz^^^!)^
    ))^
   ) else (^
    (echo If ur = 0 And ra^^^!%%yl^^^!0^^^!%%yr^^^! = "" Then)^&^
    (echo  ^^^!%%yt^^^!"^!%%y0^!The process PID " ^^^!%%ym^^^! CStr^^^!%%yl^^^!pi^^^!%%yr^^^! ^^^!%%ym^^^! " has not any calls")^&^
    (echo Else)^&^
    (echo  For i = 0 To ur)^&^
    (echo   ^^^!%%yt^^^!"#" ^^^!%%ym^^^! i ^^^!%%ym^^^! ": " ^^^!%%ym^^^! ra^^^!%%yl^^^!i^^^!%%yr^^^!)^&^
    (echo  Next)^&^
    (echo End If)^
   ))^&^
   (echo ^^^!%%yf^^^!)^
  )^>^>"^!%%ys^!"^&^
  ((call move /y "^!%%ys^!" "^!%%ys:~0,-4^!")^>nul ^&^& (^
   for /F "tokens=*" %%a in ('cscript //nologo "^!%%ys:~0,-4^!"') do if not "%%~a"=="0" (^
    set "%%yt=%%a"^&^
    (if defined %%yco (^
     if defined %%yre (^
      If 0 LSS ^^^!%%yco^^^! (set "%%yco="^&set "%%yre=")^
     ) else (^
      if "^!%%yt:%%yre=^!"=="^!%%yt^!" (echo %%a^>con) else (echo.^>con^&set %%a)^
     )^
    ))^&^
    (if not defined %%yco (^
     if "^!%%yt:%%yco=^!"=="^!%%yt^!" (if defined %%yn (set %%a)^>NUL 2^>^&1 else (call echo %%a)) else (set %%a)^
    ))^
   )^
  ) ^|^| (echo ^^^!%%y0^^^!R/W disk conflict or vbscript error.^&exit /b 1))^&^
  (if defined %%yco if ^^^!%%yco^^^! LSS 0 (exit /b 1))^&^
  (if defined %%yn (^
   echo "%%yn=1"^&echo "%%ye=^!%%ye^!"^&^
   (if defined %%yta (^
    (for /L %%a in (0,1,8) do if defined %%y%%an if defined %%y%%af if defined %%y%%av (^
     set "%%ya=%%y%%av"^&^
     (for /F "tokens=*" %%b in ('%%%%yc%%"for /F %%%%yq%%tokens=*%%%%yq%% %%^c in %%%%yl%%'%%%%yq%%echo ^!%%%%ya%%^!%%%%yq%%'%%%%yr%% do echo %%^%%%%y%%af%%^c"') do (^
      call set "%%y%%av=%%b"^
     ))^
    ))^
   ))^&^
   (if defined %%yrn (call echo "^!%%yrn^!=^!%%yrv^!"))^&^
   (if defined %%ypn (call echo "^!%%ypn^!=%%^!%%ypn^!%%"))^&^
   (for /L %%a in (0,1,8) do if defined %%y%%an (call echo "^!%%y%%an^!=^!%%y%%av^!"))^
  )) 2^>NUL^
 ) else (^
  set "%%yc=0"^&set "%%y0=Error [@callstack]: "^&(if not "^!%%yc^!"=="0" (call echo %%%%y0%%Enable delayed expansions or use with @mac_wrapper.^&exit /b 1))^&^
  set "%%yc=cmd /d /q /v:on /e:on /r "^&set "%%ye=0"^&set "%%yn=0"^&^
  (for /F "tokens=*" %%a in ('%%%%yc%%"^!@callstack^! %%%%ya%%"') do (^
   set "%%yc=%%a"^&^
   (if "^!%%yc:~0,5^!"=="Error" (echo %%a^&exit /b 1) else if "^!%%yc:%%yn=^!"=="^!%%yc^!" if "^!%%yc:%%ye=^!"=="^!%%yc^!" (^
    if ^^^!%%ye^^^! EQU 1 (echo %%a) else if ^^^!%%yn^^^! EQU 1 (set %%a) else (call echo %%a)^
   ) else (set %%a) else (set "%%yn=1"))^
  ))^&^
  (for %%a in (0,a,e,c,n) do (set "%%y%%a="))^
 )) else set wds_bcs_a=
