:: ------------------------------------------------------------------------------------------------------------------
::      wait.mds.tests.macros.bat, set of tests to check the functionality of macros defined in the wait.mds library.
::
::                                            Copyright (C) 2013-2020 Anton Kopiev
::                                                      GNU General Public License
:: ------------------------------------------------------------------------------------------------------------------
::
:: Usage:
::  #1. The call without arguments of this script imports macros from file "..\wait.mds.bat" and runs suite of tests #3.1;
::  #2. The 1st argument is optional, defines the file to import macro definitions and can have next values:
::   #2.1. `/1` - the default import file "..\wait.mds.bat";
::   #2.2. `/2` - import file "..\macros\macros.general.collapsed.bat";
::   #2.3. `/3` - import file "..\macros\macros.general.expanded.bat";
::    The next two values needs preliminary installation of the library into target folder:
::   #2.4. `/4` - import file "%ProgramFiles%\wait.mds\wait.mds.lite.bat";
::   #2.5. `/5` - import file "%ProgramFiles%\wait.mds\wait.mds.bat";
::  #3. The 2nd argument (or the 1st argument - differs by a set of values) specifies set of tests and can have next values:
::   #3.1. The default call without arguments runs sets of tests `/b`, `/w` & `/p`;
::   #3.2. `/b` - runs basic set of tests;
::   #3.3. `/w` - runs only windows automation tests;
::   #3.4. `/p` - runs only @fixedpath & @shortpath set of tests;
::   #3.5. `/n` - runs only tests of network macros @netdevs, @nicconfig, @ipaddress, @web_avail & @web_ip;
::   #3.6. `/a` - runs all sets of tests (`/b`, `/w`, `/p` & `/l`);
::  #4. To skip deletion of temporary files in %TEMP% set "library.waitmds.testruns=1" below in code;
::  #5. The full set of tests takes 5-10 min of time;
::  #6. The total count of printed lines of full suite can exceed 300 rows. To view all printed lines on older OS-es use 
::      output redirection `>` to custom file.
::
@echo off&setlocal disabledelayedexpansion
call:tests_startup "%~1" "%~2" %%3 || goto:eof

setlocal enabledelayedexpansion

call %%tests.importMacros%%
%@isok% || (echo Error [%time%]: Macros have inadequate state of delayed expansions, last import failed&exit /b 1)

:: In order to keep temporary files undeleted in %TEMP% folder set the variable below to "1", "2" to pause call stack test:
set "library.waitmds.testruns="

%@taskinfo% 1:u_curPid 3:u_curArc 5:u_wndHdl 6:u_wndPid
echo [%time%]: curArc: %u_curArc%, curPid: %u_curPid%, wndPid: %u_wndPid%, wndHdl: %u_wndHdl%
call echo Macros: %%tests.importFile%%
call echo Root:   %%tests.homepath%%
call echo Events: %%tests.eventfile%%
     echo Status: subroutine importMacros ^& @isok: PASS
echo.

if not "%tests.set%"=="" if not "%tests.set%"=="a" (
 if "%tests.set%"=="w" (goto:windows_tests) else if "%tests.set%"=="p" (goto:path_tests) else if "%tests.set%"=="n" (goto:lan_tests) else if not "%tests.set%"=="b" goto:eof
)
::--------------------------------------------------------
::-- Basic macros test:
::--------------------------------------------------------
echo ----------------- %time:~0,8%: "%~n0" -----------------
%@errorlevel% 1 && (echo                @errorlevel: FAIL) || (
 echo                @errorlevel: PASS
 %@errorlevel% 0
)
set "u_str=[%time%]: @echo_imprint: "
for %%a in ("%u_str%the next string will blank previous...","%u_str%last imprint...","%u_str%done...") do (
 %@echo_imprint% "%%~a"
 (for /F %%a in ('timeout /T 1') do (echo.>nul)) >NUL 2>&1 && (echo.>nul) || (%@spinner% 750)
)
echo.
echo [%time%]: @spinner: 750 msec
%@spinner% 750
echo [%time%]: @sleep_wsh: 750 msec
%@sleep_wsh% "750"
set u_str="-2147483647"
echo [%time%]: @get_number: [%u_str%]
%@get_number% u_num1 %u_str%
set "u_res=[%time%]: @get_xnumber"
%@get_xnumber% u_num2 %u_str%
if !u_num1! EQU !u_num2! (echo %u_res% -^> PASS, number = %u_num1%) else (call echo %u_res% -^> FAIL, number#1 = %u_num1%, number#2 = %u_num2%)
%@hex% u_hex "65535"
echo [%time%]: @hex :   65535   -^> hex = %u_hex%
%@rand% u_num 4
echo [%time%]: @rand: [1..9999] -^> num = %u_num%
set "test_str=first *** second ****** third ***** fourth ************"
echo                !test_str!
%@str_length%test_str
echo [%time%]: @str_length: [%test_str_len%]
echo                @sym_replace: "*" "+"
%@sym_replace% test_str "*" "+"
echo [%time%]: !test_str!
echo                @mac_wrapper.@syms_replace: 0 4 "*^=+" "o^=O" "s^=S" "r^=R"
set "test_str=first *** second ****** third ***** fourth ************"
%@mac_wrapper% @syms_replace,test_str 0 4 "*^=+" "o^=O" "s^=S" "r^=R",test_str
echo [%time%]: %test_str%
set u_echoqss=first'second'third"fourth
set u_del='"
echo                @syms_cutstr: [%u_echoqss%] [%u_del%] [num - 3:-3]
set "u_res="&(set u_exp="u_tcn=4","u_fnn=2","u_rsn=first+second",second,first)&set "u_str=+"
for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r "!@syms_cutstr! u_echoqss 1:u_del 3:-3 5:u_tcn 6:u_fnn 7:u_rsn 8:u_fsn 9:u_str"') do (
 if defined u_res set "u_res=!u_res!,"
 set "u_res=!u_res!%%a"
)
if "!u_res!"=="!u_exp!" (set "u_rep=PASS") else (set "u_rep=FAIL")
echo                %u_rep% -^> %u_res%
set teststr="Hello someone "", called "Barabashka"..."
echo [%time%]: @str_unquote: %teststr%
%@str_unquote% teststr '
echo [%time%]: %teststr%
set u_bege=" ~h 5 `^^^^^^@#${}[~]?-_~=+\/*'^""~~;%%%%:,.1^(^)^|^^^!^^^!^^^! 3^&=~<>	w~ "
set u_ende=" ~h 5 `^^^^^^@#${}[~]?-_~=+\/*'^""~~;%%%%:,.1^(^)^|^^^!^^^!^^^! 3^&=~<>	w~ "
%@str_encode% u_ende 1 "\[" "]"
echo [%time%]: @str_encode: pfx="\[" sfx="]"
%@str_decode% u_ende "\[" "]"
if !u_bege!==!u_ende! (echo [!time!]: @str_decode: pfx="\[" sfx="]", test "<<->>" - PASS) else (
 echo [!time!]: @str_decode: pfx="\[" sfx="]", test "<<->>" - FAIL:
 echo    Expected: !u_bege!
 echo    Obtained: !u_ende!
)
echo                1. @title, 2. @mac_wraperc.@pid_title, 3. @title_pid:
%@title% u_caption 1:u_pid
set u_str=[%time%]: 1. Current proc -^> PID=%u_pid%, Title="%u_caption%"
echo !u_str:~0,73! ..."
set "u_caption="
%@mac_wraperc% @pid_title,%u_pid% u_caption,u_caption
set u_str=[%time%]: 2. Title of PID -^> "%u_caption%"
echo !u_str:~0,73! ..."
%@title_pid% %~n0 u_tpid 1:u_cpid 2:u_ftit
set u_str=[%time%]: 3. Search "%%~n0"-^> PID=%u_tpid% Found=%u_cpid% Title="%u_ftit%"
echo !u_str:~0,73! ..."
set u_test_echo=WORD BY WORD
echo                @echo_params: %u_test_echo%
(set u_exp="WORD","BY","WORD")&set "u_res="
for /F "usebackq tokens=*" %%a in (`cmd /d /q /r "!@echo_params! 7 %u_test_echo%"`) do (
 if defined u_res set "u_res=!u_res!,"
 (set u_res=!u_res!"%%a")
)
if !u_res!==!u_exp! (echo [!time!]: PASS -^> !u_res!) else (echo [!time!]: FAIL -^> !u_res!)
set u_arrange=x0-x1-x2-x3-x4-x5-x6-x7-x8-x9
echo                @str_arrange: %u_arrange% (x 14)
set u_arrange=!u_arrange:x=0!-!u_arrange:x=1!-!u_arrange:x=2!-!u_arrange:x=3!-!u_arrange:x=4!-!u_arrange:x=5!-!u_arrange:x=6!-!u_arrange:x=7!-!u_arrange:x=8!-!u_arrange:x=9!-!u_arrange:x=A!-!u_arrange:x=B!-!u_arrange:x=C!-!u_arrange:x=D!
echo [%time%]: C:20 R:7 D:- E:0
%@str_arrange% C:20 R:7 D:- E:0 %u_arrange%
echo [%time%]: {cmd - echo} R:7 C:20 D:- E:0
for /F "tokens=*" %%c in ('cmd /d /q /e:on /v:on /r "!@str_arrange! R:7 C:20 D:- E:0 u_arrange"') do (
  echo %%c
)
echo [%time%]: @substr_remove: "[" "]" "/CHR{20}"
set u_test_str=A[a]B[b]C[c]D[d]E[e]F[f]G[g]H[h]I[i]J[j]K[k]L[l]M[m]N[n]O[o]P[p]Q[q]R[r]S[s]T[t]U[u]V[v]W[w]X[x]Y[y]Z[z]
set u_str=%u_test_str%
%@substr_remove% u_str [ 1:] "5:/CHR{20}" 6:0 4:1 3:1000000000 2:u_cnt
echo [%time%]: {%u_cnt%}, {%u_str%}
echo                @substr_get: "[" "]" "/CHR{20}"
set u_str=%u_test_str%
%@substr_get% u_str [ 1:] "5:/CHR{20}" 4:1 3:1000000000 2:u_cnt
echo [%time%]: {%u_cnt%}, {%u_str%}
set u_str=[Network Interface]^(*^)\[Bytes Total/sec]
echo              @substr_extract: str="%u_str%"
(set u_exp="sub=Network Interface","str=(*)\","sub=Bytes Total/sec")&set "u_res="
for /F "usebackq tokens=*" %%a in (`cmd /d /q /e:on /v:on /r "!@substr_extract! u_str [ 1:]"`) do (
 if defined u_res set "u_res=!u_res!,"
 (set u_res=!u_res!"%%a")
)
if !u_res!==!u_exp! (echo [!time!]: PASS, !u_res!) else (echo [!time!]: FAIL, !u_res!)
set u_str="a1+ 3_4"
echo                @substr_regex: [%u_str%] regex: [0-9]
%@substr_regex% u_str [0-9] 1:u_res 2:0
if "!u_res!"=="134" (echo [!time!]: PASS, result: "!u_res!") else (echo [!time!]: FAIL, result: "!u_res!")
set u_source=" 	 "	hi "someone^^^!". 	" "
set u_str=!u_source!
echo                source     ^> [%u_source%] 
%@str_trim% u_str
echo [%time%]: @str_trim  ^> [%u_str%]
set u_str=!u_source!
%@str_clean% u_str
echo [%time%]: @str_clean ^> [%u_str%]
set u_str=!u_source!
%@str_plate% u_str "X"
echo [%time%]: @str_plate ^> [%u_str%]
set u_str=!u_source!
%@str_upper% u_str
echo [%time%]: @str_upper ^> [%u_str%]
set u_str=""
echo                @mac_check.@str_isempty.@istrue: u_str=[""] 1:2 2:~
%@mac_check% @str_isempty,u_str 1:2 2:~,u_str %@istrue% && set "u_res=FAIL, true ^<==^> 0" || set "u_res=PASS, false ^<==^> 1"
echo [%time%]: %u_res%, result string: %u_str%
set "u_text=So, what ~ parsing? In simple terms, ~ some rules. Its ~ deep learning ~."
set u_loopmacro1=(for /F "delims=,?.~ tokens=1,*" %%a in ('echo ^^^!u_text^^^!') do (^
  echo "u_left=%%a"^&^
  (if "%%b"=="" (exit /b 0) else (set "u_text=%%b"))^
 ))
set u_loopmacro2=(if defined u_text for /F "delims=,?.~ tokens=1,*" %%a in ('echo ^^^!u_text^^^!') do (^
  set "u_left=%%a"^&set "u_text=%%b"^
 ) else (exit /b 0))
set "u_res1="&echo [!time!]: @mac_spinner        - split string by custom macro #1
for /F "tokens=*" %%c in ('cmd /d /q /e:on /v:on /r "%%@mac_spinner%% u_loopmacro1"') do (
 set %%c
 set "u_res1=!u_res1!!u_left!,"
)
set "u_res2="&echo [!time!]: @mac_loop ^& @mac_do - split same string by custom macro #2
%@mac_loop% u_loopmacro2 u_left u_text %@mac_do% (
 set "u_res2=!u_res2!!u_left!,"
)
if "!u_res1!"=="!u_res2!" (echo [!time!]: PASS               ^<- result coincide) else (
 (echo [!time!]: FAIL, result strings:)&(echo #1: "!u_res1!")&(echo #2: "!u_res2!")
)
if defined u_text (set "u_res=FAIL") else (set "u_res=PASS")
echo                !u_res!               ^<- string must be unset by 2nd macro
set u_counter="%% Processor Time"
echo                @perf_counter: u_counter=[%u_counter%]
%@perf_counter% u_counter
echo [%time%]: u_counter=[%u_counter%]
set u_usequery="[Network Interface](*)\[Bytes Total/sec]"
echo                @typeperf: u_query=%u_usequery%
%@typeperf% u_usequery u_names u_values 1:u_count
echo [%time%]: query =[%u_usequery%] u_count=[%u_count%]
echo                names =[%u_names%]
echo                values=[%u_values%]
set u_capquery="[Network Interface](*)\[Current Bandwidth]"
echo                @typeperf_devs: %u_capquery%
%@typeperf_devs% u_capquery u_devs 1:u_count
echo [%time%]: u_query=%u_capquery%
echo                %u_count% devices ^> %u_devs%
call set u_devs=%%u_devs:"=%%
echo                @typeperf_res_a:
%@typeperf_res_a% u_usequery u_capquery 1:1 5:2 6:0 2:8 3:u_percent 7:u_capacity 4:u_device
echo [%time%]: usequery=[%u_usequery%]
echo                capquery=[%u_capquery%]
echo                usage   = %u_percent% %%
echo                capacity= %u_capacity%
if "!u_devs!"=="!u_device!" (set u_device=PASS) else (set u_device=FAIL)
echo                devices = %u_device% ^<=^> result of @typeperf_devs
(set /a "u_capacity/=100")&(set "u_percent=")&(set "u_device=")
echo                @typeperf_res_b: %u_usequery%
%@typeperf_res_b% u_usequery 1:1 6:0 3:u_percent 5:1 7:1 2:%u_capacity% 4:u_device
echo [%time%]: usequery=[%u_usequery%]
echo                usage   = %u_percent% %% (capacity = %u_capacity%)
call set u_device=%%u_device:"=%%
if "!u_devs!"=="!u_device!" (set u_device=PASS) else (set u_device=FAIL)
echo                devices = %u_device% ^<=^> result of @typeperf_devs
echo                @typeperf_res_c:
%@typeperf_res_c% u_usequery u_capquery 1:1 5:2 6:0 2:8 3:u_percent 7:u_capacity 4:u_device
echo [%time%]: usequery=[%u_usequery%]
echo                capquery=[%u_capquery%]
echo                usage   = %u_percent% %%
echo                capacity= %u_capacity%
if "!u_devs!"=="!u_device!" (set u_device=PASS) else (set u_device=FAIL)
echo                devices = %u_device% ^<=^> result of @typeperf_devs
set u_usequery="[PhysicalDisk](*)\[%% Disk Time]"
echo                @typeperf_res_d: %u_usequery%
%@typeperf_res_d% u_usequery 1:1 6:0 3:u_percent 5:1 7:1 2:1 4:u_device
echo [%time%]: usequery=[%u_usequery%]
echo                usage   = %u_percent% %%
echo                devices =[%u_device%]
echo                @typeperf_res_use: 
for %%a in (network disk volume cpu task) do (
 %@typeperf_res_use% %%a u_percent 2:1
 echo [!time!]: %%a = !u_percent! %%, errorlevel=!errorlevel!
)
echo                @unset: 1:te 2:str
%@unset% 1:te 2:str
set "u_res=PASS"
for %%a in (teststr,test_str,test_str_len) do if defined %%a set "u_res=FAIL"
echo [%time%]: %u_res%
echo                @date_span: 1:20200320092737 2:20200320102737
%@date_span% 3:u_daysnum 4:u_scdssnum 1:20200320092737 2:20200320102737 5:u_timespan 6:u_order
echo [%time%]: days.seconds{1}="%u_daysnum%.%u_scdssnum%", timespan="%u_timespan%", order="%u_order%"
echo                @time_span: 1:^%%time: =0^%%
%@time_span% 1:%time: =0% 5:u_msec 4:u_sec 3:u_min 2:u_hrs 6:u_nia
echo [%time%]: u_msec=%u_msec% u_sec=%u_sec% u_min=%u_min% u_hrs=%u_hrs% u_nia=%u_nia%
echo                @obj_size: "%temp%"
%@obj_size% temp 1:u_sizebt 2:u_sizekb 3:u_sizemb 4:u_sizegb 5:u_fnum 6:u_dnum 7:u_ovl
echo [%time%]: B=%u_sizebt%, K=%u_sizekb%, M=%u_sizemb%, G=%u_sizegb%, Fn=%u_fnum%, Dn=%u_dnum%, Ov=%u_ovl%
echo                @disk_space: "C:" (MB)
%@disk_space% C: 1:2 2:u_ts 3:u_fs 4:u_us 5:u_osl
echo [%time%]: total=[%u_ts%] free=[%u_fs%] used=[%u_us%] overflow=[%u_osl%]
echo                @obj_attrib: "{Event File}" "~r" [modify on]
%@mac_check% @obj_attrib,tests.eventfile ~r 2:150 1:1 %@istrue% && (echo [!time!]: PASS) || (echo [!time!]: FAIL)
echo                @exist: u_fndcnt 1:u_chkcnt 2:2 3:u_spent 4:0 (u_chkcnt=3)
set u_temp=%TEMP%
set u_chkcnt=3
%@exist% u_res u_temp 1:u_fndcnt 2:u_chkcnt 3:0 4:u_spent 5:0
if %u_res% EQU 0 (set u_res=PASS) else (set u_res=FAIL)
echo [%time%]: %u_res%, u_fndcnt=[%u_fndcnt%] u_chkcnt=[%u_chkcnt%] u_spent=[%u_spent%]
echo                @exist_check: "{Event File}"
%@exist_check% tests.eventfile u_res 1:5000
if !u_res! EQU 1 (echo [!time!]: PASS, u_res = !u_res! ^<- exists, no changes found) else (echo [!time!]: FAIL, u_res = !u_res!)
echo                @obj_newname: "%%TEMP%%, 2:"wds" 3:".txt""
%@obj_newname% u_newnam 1:u_temp 2:"wds" 3:".txt"
echo [%time%]: u_newnam=%u_newnam%
echo                @res_select "TSVN* or far";"tasklist";"tokens=1 delims=."
%@res_select% "TSVN* or far";"tasklist";"tokens^=1 delims^=.";1:u_selres;2:u_selnum;8:u_spent
echo [%time%]: u_spent=[%u_spent%] u_selres=[%u_selres%] u_selnum=[%u_selnum%]
echo                @event_file [add]: 3:~f 4:'wait.events.json' 5:20000 7:1
%@event_file% tests.eventfile 1 2:u_id 3:~f 4:'wait.events.json' 5:20000 7:1 8:u_res 9:-500
if %u_res% EQU 0 (set u_res=PASS) else (set u_res=FAIL)
echo [%time%]: %u_res%, new event id "%u_id%"
%@event_item% tests.eventfile predicate u_id u_pr
if "!u_pr!"=="'wait.events.json'" (set u_res=PASS) else (set u_res=FAIL)
echo [%time%]: @event_item (predicate) -^> %u_res%, @event_file [remove]:
%@event_file% tests.eventfile 2 1:%u_id% 8:u_res 9:-500
if %u_res% EQU 0 (set u_res=PASS) else (set u_res=FAIL)
echo [%time%]: %u_res% ^<-^> removing of event with id "%u_id%"

if defined tests.notepad.of.win11 (goto :tests_notepad_of_win11)
 (call set u_runcmd=/min notepad.exe %%tests.eventfile%%)
 echo                @runapp_getpid: [/min notepad.exe "{Event File}"], @runapp
 %@runapp_getpid% u_runcmd "notepad*" u_resapp1 1:1 2:u_restyp 3:u_rescmd 6:/LOW 5:60000 3:0 8:1 A:u_title
 if !u_restyp! EQU 1 (set u_res=PASS) else (set u_res=FAIL)
 echo [!time!]: !u_res!, PID: "!u_resapp1!", title: "!u_title!"
 if defined u_rescmd (echo                WARNING: found locked launcher console with PID !u_rescmd!)
 if defined u_rescmd (echo                ERROR: found some locked launcher console with PID !u_rescmd!)
 (call set u_runcmd="notepad.exe" %%tests.eventfile%%)
 echo                @runapp_getpid: ["notepad.exe" "{Event File}"], @runapp_wsh
 %@runapp_getpid% u_runcmd "notepad*" u_resapp2 1:0 2:u_restyp 3:u_rescmd 7:7 5:60000 4:0 A:u_title
 if !u_restyp! EQU 1 (set u_res=PASS) else (set u_res=FAIL)
 echo [!time!]: !u_res!, PID: "!u_resapp2!", title: "!u_title!"
 echo                @procpriority: [!u_resapp1!,!u_resapp2!] 4:LOW (wmic.exe)
 %@procpriority% 1:u_resapp1,u_resapp2 3:u_curpri 4:u_curpid 5:u_totnum 6:LOW
 (set u_res1="total: [!u_totnum!]; id's: [!u_curpid!]; priorities: [!u_curpri!]")
 echo [!time!]: !u_res1:~1,-1!
 echo                @procpriority: [!u_resapp1!,!u_resapp2!] (wmi service)
 %@procpriority% 1:"!u_resapp1!",u_resapp2 3:u_curpri 4:u_curpid 5:u_totnum 7:1
 (set u_res2="total: [!u_totnum!]; id's: [!u_curpid!]; priorities: [!u_curpri!]")
 if !u_res1!==!u_res2! (echo [!time!]: PASS) else (echo [!time!]: !u_res2:~1,-1! ^<- FAIL)
 for %%a in (1,2) do if defined u_resapp%%a (taskkill /PID !u_resapp%%a! /T /F)>NUL 2>&1
 goto:tests_notepad_of_win11_end
:tests_notepad_of_win11
 taskkill /IM notepad.exe /T /F>NUL 2>&1
 (call set u_runcmd=/min notepad.exe %%tests.eventfile%%)
 echo                @runapp_getpid: [/min notepad.exe "{Event File}"], @runapp
 %@runapp_getpid% u_runcmd "notepad*" u_resapp 1:1 2:u_restyp 3:u_rescmd 6:/LOW 5:60000 3:0 8:1 A:u_title
 if !u_restyp! EQU 1 (set u_res=PASS) else (set u_res=FAIL)
 echo [!time!]: !u_res!, PID: "!u_resapp!", title: "!u_title!"
 if defined u_rescmd (echo                WARNING: found locked launcher console with PID !u_rescmd!)
 if defined u_rescmd (echo                ERROR: found some locked launcher console with PID !u_rescmd!)
 taskkill /PID !u_resapp! /T /F>NUL 2>&1
 (call set u_runcmd="notepad.exe" %%tests.eventfile%%)
 echo                @runapp_getpid: ["notepad.exe" "{Event File}"], @runapp_wsh
 %@runapp_getpid% u_runcmd "notepad*" u_resapp 1:0 2:u_restyp 3:u_rescmd 7:7 5:60000 4:0 A:u_title
 if !u_restyp! EQU 1 (set u_res=PASS) else (set u_res=FAIL)
 echo [!time!]: !u_res!, PID: "!u_resapp!", title: "!u_title!"
 echo                @procpriority: [!u_resapp!] 4:LOW (wmic.exe)
 %@procpriority% 1:u_resapp 3:u_curpri 4:u_curpid 5:u_totnum 6:LOW
 (set u_res1="total: [!u_totnum!]; id's: [!u_curpid!]; priorities: [!u_curpri!]")
 echo [!time!]: !u_res1:~1,-1!
 echo                @procpriority: [!u_resapp!] (wmi service)
 %@procpriority% 1:"!u_resapp!" 3:u_curpri 4:u_curpid 5:u_totnum 7:1
 (set u_res2="total: [!u_totnum!]; id's: [!u_curpid!]; priorities: [!u_curpri!]")
 if !u_res1!==!u_res2! (echo [!time!]: PASS) else (echo [!time!]: !u_res2:~1,-1! ^<- FAIL)
 taskkill /PID !u_resapp! /T /F>NUL 2>&1
:tests_notepad_of_win11_end
echo                @shrink - environment variable: random map, radix 49, "<<->>"
set "u_shrink_src=A VBScript function can have an optional return statement. This is required if you want to return a value from a function. For example, you can pass two numbers in a function and then you can expect from the function to return their multiplication in your calling program."
set u_radix=49
%@shrink% u_shrink_src u_shrink_tgt 2:0 3:0 8:u_radix A:u_syms C:1 E:1
echo                radix   = %u_radix%
echo                symbols = "%u_syms%"
%@shrink% u_shrink_tgt u_shrink_tgt 1:0 2:0 3:0 A:u_syms
set "u_res= + files: LZW compress, uncompress ^& @comparefiles"
if "%u_shrink_src%"=="%u_shrink_tgt%" (echo [%time%]: PASS%u_res%) else (echo [%time%]: FAIL%u_res%)
for %%a in (son,lzw,lzw.unc) do (call set u_shrink_%%a="%%tests.eventfile:~1,-4%%%%a")
%@shrink% u_shrink_son u_shrink_lzw
%@shrink% u_shrink_lzw u_shrink_lzw.unc 1:0
echo [%time%]: @shrink ^<- DONE, @comparefiles:
%@mac_check%  @comparefiles, u_shrink_son u_shrink_lzw.unc %@istrue% && echo [!time!]: PASS || echo [!time!]: FAIL
call del /f /a /q "%%u_shrink_lzw:~1,-1%%*">nul
echo                @enwalue: (read local macro in memory, run value), ^<set mode^>:
%@enwalue% u_res 2:@sleep_wsh_1 3:@sleep_wsh 4:0 5:1 6:u_res_type 7:2 8:0
echo [%time%]: res = %u_res%, res_type = %u_res_type%
echo                ^<echo mode^>:
for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r "!@enwalue! u_res 2:@sleep_wsh_2 3:@sleep_wsh 4:0 5:1 6:u_res_type 7:2 8:1"') do (
 set %%a
)
echo [%time%]: res = %u_res%, res_type = %u_res_type%
(%@sleep_wsh_1% "50")&set "@sleep_wsh_1="
(%@sleep_wsh_2% "50")&set "@sleep_wsh_2="
echo                @enwalue: PASS
echo [%time%]: @environset: (read ^& assign macro from memory, run it):
set u_hdl=0
for /F "tokens=1,* delims==" %%a in ('cmd /d /q /e:on /v:on /r "!@environset! u_hdl 1:*@sleep_wsh*"') do if %%a=="" (
 echo [%time%]: FAIL
) else (
 set "@sleep_wsh_3=%%b"
 if defined @sleep_wsh_3 (echo [!time!]: ^<--- name was found ^& defined locally)
)
if defined @sleep_wsh_3 (
 (%@sleep_wsh_3% "50")&set "@sleep_wsh_3="
 echo                PASS
)
echo [%time%]: @radix: R-16 -^> R-86
%@radix% u_x86val "651C2A9FCA0AA41B9B2751C91F0" 1:"16" 4:"86"
if "%u_x86val%"=="EREWHON?;?NOWHERE" (set "u_res=PASS") else (set "u_res=FAIL")
echo [%time%]: R-86: "%u_x86val%"  ^<- %u_res%
echo                @code: forward - backward - compare
set "u_src=Custom string"
%@code% u_tgt u_src 2:"/CHR{" 3:"}" 4:1
echo [%time%]: Forward done via memory read
%@code% u_tgt u_tgt 1:1 2:"/CHR{" 3:"}"
if "%u_src%"=="%u_tgt%" (set "u_res=PASS") else (set "u_res=FAIL")
echo [%time%]: Backward done via usual read, common result - %u_res%
set u_con_src=[%time%]: @consoletext AND @imprintxy - 
echo %u_con_src%
%@imprintxy% "read line" 1:45 2:1
set "u_time=%time%"
set "u_con_src=!u_con_src!read line"
%@consoletext% u_con_tgt
if "%u_con_src%"=="%u_con_tgt%" (set "u_res=PASS") else (set "u_res=FAIL")
echo %u_con_tgt%          ^<- %u_res%
echo [%u_time%]: job end time of @imprintxy, next time of @consoletext ...
%@screensize% u_width u_height
echo [%time%]: @screensize   ^> width = %u_width%, height = %u_height%
%@appbarect% u_left u_top u_right u_bottom
echo [%time%]: @appbarect    ^> L = %u_left%, T = %u_top%, R = %u_right%, B = %u_bottom%
%@monitor% u_mon_id 1
echo [%time%]: @monitor      ^> mon_id = %u_mon_id%
%@pidofwindow% u_pid "0"
echo [%time%]: @pidofwindow  ^> ["0"] - current, pid = %u_pid%
%@windowsofpid% u_wnd "0"
echo [%time%]: @windowsofpid ^> ["0"] - current, handle = %u_wnd%
%@screenshot% 
if exist "snapshot*.jpg" (
 del /f /a /q "snapshot*.jpg"
 echo [%time%]: @screenshot   ^> only file creation - PASS
) else (
 echo [%time%]: @screenshot   ^> only file creation - FAIL
)
%@repaint%
echo [%time%]: @repaint      ^> (only call) - DONE
echo                @coprocess    ^> parent of cscript process, plain check:
%@coprocess% u_res 2:u_conpid 3:1 4:"cmd.exe"
echo [!time!]: PID = "!u_conpid!", result = "!u_res!", module "cmd.exe"
call:callstack_tests
:end_tests

::--------------------------------------------------------
::-- Windows automation tests:
::--------------------------------------------------------
:windows_tests
 if not defined tests.homepath (goto:end_tests) else if not "%tests.set%"=="w" if not "%tests.set%"=="a" if not "%tests.set%"=="" (goto:end_tests)
 if not "%tests.set%"=="w" (
  echo ----------------- %time:~0,8%: "%~n0" -----------------
  echo.
 )
 echo ---------- %time:~0,8%: "%~n0" - windows tests --------
 for %%a in (batch.bat,forms.exe) do (call set u_%%a="%%tests.homepath:~1,-1%%com.api.wrapper\test_%%a")
 if not exist !u_batch.bat! (echo Error [!time!]: the console script for tests doesn't exist [!u_batch.bat!]&exit /b 1)
 if not exist !u_forms.exe! (echo Error [!time!]: the windows forms application for tests doesn't exist [!u_forms.exe!]&exit /b 1)

 set "u_res="&set "u_exp=[^!time^!]: ^!u_res^! - "
 %@mac_check% @findwindow,"" "Console/CHR{20}for/CHR{20}tests" 1:u_conhdl,u_conhdl %@istrue% || (
  set "u_conhdl="
  set "u_batch.bat=cmd /d /q /k !u_batch.bat!"
  %@runapp_wsh% 1 u_batch.bat
  set "u_res=@runapp_wsh"
 )
 %@mac_check% @findwindow,"WindowsForms10.Window.8.app.0" "Form1" 1:u_apphdl,u_apphdl %@istrue% || (
  set "u_apphdl="
  %@runapp% 0 u_forms.exe
  if defined u_res (set "u_res=@runapp, !u_res!") else (set "u_res=@runapp")
 )
 %@foregroundwindow% u_curhdl 2:1
 if not defined u_conhdl (
  %@mac_check% @findwindow,"" "Console/CHR{20}for/CHR{20}tests" 1:u_conhdl 2:120000,u_conhdl %@istrue% || (
   if defined u_res (set "u_res=@runapp_wsh"&echo %u_exp%FAIL)
   echo [!time!] Error: the test console window wasn't found running.
   exit /b 1
  )
 )
 if not defined u_apphdl (
  %@mac_check% @findwindow,"WindowsForms10.Window.8.app.0" "Form1" 1:u_apphdl 2:120000,u_apphdl %@istrue% || (
   if defined u_res (set "u_res=@runapp"&echo %u_exp%FAIL)
   echo [!time!] Error: the windows forms application wasn't found running.
   exit /b 1
  )
 )
 if defined u_res (set "u_res=!u_res! ^& @findwindow") else (set "u_res=@findwindow")
 echo %u_exp%PASS, moving ^& sizes:
 for %%a in (cur,con,app) do %@movetoscreen% u_%%ahdl "1"
 echo [%time%]: @movetoscreen - done for 3 test windows (to monitor "1")
 %@screenrect% "1" u_scnlft u_scntop u_scnrgt u_scnbot
 set /a "u_res=!u_scnrgt!*!u_scnbot!"
 if 0 LSS !u_res! (
  echo [%time%]: screenrect = {%u_scnlft%, %u_scntop%, %u_scnrgt%, %u_scnbot%}
 ) else (
  echo [%time%]: screenrect, FAIL ^<- tried monitor with id #1, use screensize:
  set "u_scnlft=0"
  set "u_scntop=0"
  %@screensize% u_scnrgt u_scnbot
  echo [%time%]: screenrect = {!u_scnlft!, !u_scntop!, !u_scnrgt!, !u_scnbot!}
 )
 %@taskinfo% 5:u_curhdl
 echo [%time%]: curhdl = %u_curhdl%
 %@windowrect% u_curhdl u_left u_top u_curwdh u_curhgt 1:0 2:u_curwdh 3:u_curhgt
 echo [%time%]: current console.  width = %u_curwdh%, height = %u_curhgt% (@windowrect)
 %@windowrect% u_conhdl u_left u_top u_conwdh u_conhgt 1:0 2:u_conwdh 3:u_conhgt
 echo [%time%]: test console.     width = %u_conwdh%, height = %u_conhgt%
 %@windowrect% u_apphdl u_left u_top u_appwdh u_apphgt 1:0 2:u_appwdh 3:u_apphgt
 echo [%time%]: test application. width = %u_appwdh%, height = %u_apphgt%
 set /a "u_left=%u_curwdh%+400, u_right=1068-%u_scnrgt%+%u_scnlft%">NUL
 if 0 LSS %u_right% (echo Error [Tests]: the width of screen must more than 1068.&exit /b 1)
 echo                @showdesktop - collapse all
 %@showdesktop%
 echo [%time%]: Done.
 %@sleep_wsh% "750"
 echo                Rearrange windows, @movewindow:
 set "u_conwdh=400"&set "u_wdh=668"&set /a "u_hgt=%u_scnbot%-%u_scntop%"
 :windows_tests_L1
 set "u_curwdh=!u_wdh!"&set "u_curhgt=!u_hgt!"
 echo                Current      -^> to the right, height !u_curhgt!, width !u_curwdh!
 set /a "u_left=%u_scnrgt%-!u_curwdh!"
 %@movewindow% u_curhdl u_left u_scntop 1:u_curwdh 2:u_curhgt
 %@windowrect% u_curhdl u_lft u_top u_curwdh u_bot 1:0 2:u_curwdh 3:u_curhgt
 if !u_left! NEQ !u_lft! (echo                FAIL: left x-coordinate !u_left! ^<^> !u_lft!)
 if !u_scntop! NEQ !u_top! (echo                FAIL: top y-coordinate !u_scntop! ^<^> !u_top!)
 set "u_res="
 if !u_scnbot! LSS !u_bot! (set "u_res=bottom below screen edge"&set /a "u_hgt-=10")
 if !u_curwdh! NEQ !u_wdh! (
  if defined u_res (set "u_res=!u_res!, ")
  set "u_res=!u_res!width !u_curwdh! ^<^> !u_wdh!"&set "u_wdh=!u_curwdh!"
 )
 if defined u_res ((echo                MOVE TO FIX: !u_res!)&goto :windows_tests_L1)
 if !u_curhgt! NEQ !u_scnbot! (set "u_res=1") else if !u_curwdh! NEQ 668 (set "u_res=1")
 if defined u_res ( echo [%time%]: The size or position fixed)
 set /a "u_left=%u_scnrgt%-%u_scnrgt%">NUL
 set "u_conwdh=400"&set "u_wdh=400"&set "u_hgt=400"
 :windows_tests_L2
 set "u_conwdh=!u_wdh!"&set "u_conhgt=!u_hgt!"
 echo [%time%]: Test console -^> to the left of current, width !u_conwdh!, height !u_conhgt!
 set /a "u_left=!u_scnrgt!-!u_curwdh!-!u_conwdh!"
 %@movewindow% u_conhdl u_left u_scntop 1:u_conwdh 2:u_conhgt
 %@windowrect% u_conhdl u_lft u_top u_conwdh u_conhgt 1:0 2:u_conwdh 3:u_conhgt
 if !u_left! NEQ !u_lft! (echo                FAIL: left x-coordinate !u_left! ^<^> !u_lft!)
 if !u_scntop! NEQ !u_top! (echo                FAIL: top y-coordinate !u_scntop! ^<^> !u_top!)
 if !u_conwdh! NEQ !u_wdh! (
  echo                MOVE TO FIX: width !u_conwdh! ^<^> !u_wdh!
  set "u_wdh=!u_conwdh!"&set "u_hgt=!u_conhgt!"&goto :windows_tests_L2
 )
 if !u_wdh! NEQ 400 (echo [%time%]: The position fixed)
 echo [%time%]: Application  -^> to the left of main console and below test one
 set /a "u_left=!u_scnrgt!-!u_curwdh!-!u_appwdh!, u_top=!u_scntop!+!u_conhgt!"
 %@movewindow% u_apphdl u_left u_top
 echo [%time%]: Done - windows must be "stick" to each other...

 echo                ------ Console window testing -----
 echo                Window handle     = %u_conhdl%
 %@windowclass% u_conhdl u_concls
 echo [%time%]: @windowclass      = %u_concls%
 %@windowcaptext% u_conhdl u_concap 1:1
 echo [%time%]: @windowcaptext{1} = %u_concap%
 %@windowcaptext% u_conhdl u_concap 1:0
 echo [%time%]: @windowcaptext{0} = "%u_concap%"
 echo                Activate window, check result:
 %@foregroundwindow% u_hdl 1:u_conhdl
 if %u_hdl% EQU %u_conhdl% (echo [%time%]: @foregroundwindow - PASS) else (echo [%time%]: @foregroundwindow - FAIL)
 echo                @activewindow - will confirm it? Do check:
 %@activewindow% u_hdl
 if %u_hdl% EQU %u_conhdl% (echo [%time%]: @activewindow - PASS) else (echo [%time%]: @activewindow - FAIL)
 echo                @sendkeys "echo testvar=%%testvar%%~"
 (set u_keys=echo testvar={%%}testvar{%%}~)
 %@sendkeys% u_keys
 set "u_typed=testvar=Text to read"
 echo [%time%]: Expected output - "%u_typed%"
 echo                @consoletext: read 1st line after "echo" substring to confirm
 set "u_text=echo"
 %@consoletext% u_res 1:u_conhdl 2:u_text 9:u_text A:1
 call set "u_out=, console text: "%%u_text%%""
 if %u_res% EQU 0 if "!u_text!"=="" (
  %@consoletext% u_text 1:u_conhdl 3:3
  call set "u_out=, text: "%%u_text%%" [command prompt on 2 rows?]"
 )
 if "!u_typed!"=="!u_text!" (echo [%time%]: PASS!u_out!) else (echo [%time%]: FAIL!u_out!)

 for /F "tokens=1,2 delims==" %%a in ('echo %%u_typed%%') do (^
  echo                @enwalue: read value "%%a", expected "%%b"
  %@enwalue% u_value 1:u_conhdl 3:%%a
  call set "u_out=, "%%a" <-> "%%u_value%%""
  if "!u_value!"=="%%b" (echo [!time!]: PASS!u_out!) else (echo [!time!]: FAIL!u_out!)
 )
 echo                @closewindow: [`0`- minimize window]
 %@closewindow% u_conhdl 0
 echo [%time%]: @windowstate - `7` OR `IsIconic`
 %@mac_check% @windowstate,7 u_conhdl 1:2000 %@istrue% && (echo [!time!]: PASS) || (echo [!time!]: FAIL)
 echo                @findshow: `"9"` OR `SW_RESTORE`
 %@findshow% u_auxhdl "" "Console/CHR{20}for/CHR{20}tests" "9"
 echo [%time%]: @windowstate - `7` OR `IsIconic` (False ^<-^> True)
 %@mac_check% @windowstate,7 u_conhdl 1:2000 %@istrue% && (echo [!time!]: FAIL) || (echo [!time!]: PASS)
 if !u_auxhdl! NEQ !u_conhdl! (echo                FAIL, @findshow gave another handle "!u_auxhdl!" ^<^> "!u_conhdl!")

 echo                --- Windows application testing ---
 echo                Window handle     = %u_apphdl%
 %@windowclass% u_apphdl u_appcls
 echo [%time%]: @windowclass      = "%u_appcls%"
 %@windowcaptext% u_apphdl u_appcap 1:1
 echo [%time%]: @windowcaptext{1} = "%u_appcap%"
 %@windowcaptext% u_apphdl u_appcap 1:0
 echo [%time%]: @windowcaptext{0} = "%u_appcap%"
 %@pidofwindow% u_apppid u_apphdl
 echo [%time%]: @pidofwindow      = %u_apppid%
 %@windowsofpid% u_appaw1 u_apppid
 echo [%time%]: @windowsofpid     = "%u_appaw1%"
 echo                @findcontrol: "BUTTON" "Button1" - find target button
 %@mac_check% @findcontrol,u_apphdl "BUTTON" "Button1" 1:u_appbch 2:5000,u_appbch %@istrue% && (
  echo [!time!]: Button handle     = !u_appbch! ^<- PASS
 ) || (echo [!time!]: FAIL)
 %@windowrect% u_appbch u_left u_top u_right u_bottom
 echo [%time%]: Button rectangle: {%u_left%, %u_top%, %u_right%, %u_bottom%}
 set /a "u_left+=(%u_right%-%u_left%)/2">NUL
 set /a "u_top+=(%u_bottom%-%u_top%)/2">NUL
 echo                Button center:    {%u_left%, %u_top%}
 %@windowclass% u_appbch u_butcls
 echo [%time%]: @windowclass      = "%u_butcls%"
 %@windowcaptext% u_appbch u_butcap 1:1
 echo [%time%]: @windowcaptext{1} = "%u_butcap%"  ^<-- caption
 %@windowcaptext% u_appbch u_butcap 1:0
 echo [%time%]: @windowcaptext{0} = "%u_butcap%"  ^<-- text
 for %%a in (1,2) do (
  if %%a EQU 1 (
   echo                @cursorpos: move cursor to button
   %@cursorpos% u_left u_top 1:1
   echo [!time!]: @mouseclick: click button
   %@mouseclick%
  ) else (
   echo [!time!]: @mouseclick: move cursor ^& click button
   %@mouseclick% 3:1 4:u_left 5:u_top
  )
  %@sleep_wsh% "750"
  echo [!time!]: Foreground window:
  %@foregroundwindow% u_appcwh
  echo [!time!]: @foregroundwindow = !u_appcwh!
  %@windowclass% u_appcwh u_acwcls
  echo [!time!]: @windowclass      = "!u_acwcls!"
  %@windowcaptext% u_appcwh u_acwcap 1:1
  echo [!time!]: @windowcaptext{1} = "!u_acwcap!"  ^<-- caption
  %@windowcaptext% u_appcwh u_acwcap 1:0
  echo [!time!]: @windowcaptext{0} = "!u_acwcap!"  ^<-- text
  %@windowsofpid% u_appaw2 u_apppid
  echo [!time!]: @windowsofpid     = "!u_appaw2!"
  set "u_right=0"&set "u_bottom=0"&%@cursorpos% u_right u_bottom 1:1
  echo [!time!]: @cursorpos: cursor to the left top screen corner ^<-^> {!u_right!, !u_bottom!}
  echo                @compareshots: %%a/2 screenshots of child windows to compare:
  %@mac_check% @compareshots,2:u_appcwh 4:u_out,u_out %@istrue% && (
   if !u_out! EQU 0 (echo [!time!]: PASS - both screenshots coincide with each other) else (echo [!time!]: FAIL - screenshots has differences)
  ) || (
   if !u_out! EQU 5 (echo [!time!]: PASS - obtained 1st screenshot to compare) else (echo [!time!]: FAIL, typres = !u_out!)
  )
  echo                @closewindow: close opened child window...
  %@closewindow% u_appcwh 1
 )
 %@compareshots% res 2:u_apphdl 6:1
 echo                @findcontrol: "EDIT" "" - find edit box
 %@mac_check% @findcontrol,u_apphdl "EDIT" "" 1:u_appech,u_appech %@istrue%  && (echo [!time!]: PASS) || (echo [!time!]: FAIL)
 %@windowcaptext% u_appech u_appecc 1:1
 if "%u_appecc%"=="1234567890" (set "u_res=PASS") else (set "u_res=FAIL")
 echo [%time%]: @windowcaptext{1} = "%u_appecc%", %u_res%  ^<-- caption
 %@windowcaptext% u_appech u_appecc 1:0
 if "%u_appecc%"=="1234567890" (set "u_res=PASS") else (set "u_res=FAIL")
 echo [%time%]: @windowcaptext{0} = "%u_appecc%", %u_res%  ^<-- text
 echo                ---   ---   ---  ---   ---   ---
 echo [%time%]: Exit test application: @sendmessage `16` [WM_CLOSE], `0`, `0`
 %@sendmessage% u_apphdl "16"
 echo [%time%]: @windowstate - `0` OR `IsWindow` (False ^<-^> True)
 %@mac_check% @windowstate,0 u_apphdl 1:2000 3:1 %@istrue% && (echo [!time!]: PASS) || (echo [!time!]: FAIL)
 echo                @closewindow: destroy ^& exit test console
 %@closewindow% u_conhdl
 echo [%time%]: @windowstate - `0` OR `IsWindow` (False ^<-^> True)
 %@mac_check% @windowstate,0 u_conhdl 1:2000 3:1 %@istrue% && (echo [!time!]: PASS) || (echo [!time!]: FAIL)
 echo                ---   ---   ---  ---   ---   ---
 echo [%time%]: @shortcut: create, run ^& close
 set u_shortcutname="!tests.eventfile:~1,-1!.lnk"
 %@shortcut% u_shortcutname "My/CHR{20}shortcut" "c:\windows\notepad.exe" 1:tests.homepath 2:"7" 3:"notepad.exe,0" 5:tests.eventfile
 if exist !u_shortcutname! (
  start "" !u_shortcutname!
  %@mac_check% @findwindow,"Notepad" "wait.events" 1:u_handle 2:1000,u_handle %@istrue% && (
   set "u_res=PASS"
   for %%a in (!u_handle!) do %@closewindow% "%%a"
  ) || (set "u_res=FAIL, shortcut didn't start")
  del /F /A /Q !u_shortcutname! >NUL
 ) else (set "u_res=FAIL, shortcut wasn't created.")
 echo [%time%]: %u_res%
 if "%tests.set%"=="w" (
  set>envset.txt
  echo [%time%]: The environment set was saved to file `envset.txt`.
  echo ---------- %time:~0,8%: "%~n0" - windows tests --------
  goto:eof
 )
:end_windows_tests

::--------------------------------------------------------
::-- Tests of macros @fixedpath & @shortpath:
::--------------------------------------------------------
:path_tests
 if not defined tests.homepath (goto:end_tests) else if not "%tests.set%"=="p" if not "%tests.set%"=="a" if not "%tests.set%"=="" (goto:end_tests)
 set "u_teststr="&if "%tests.set%"=="" (set "u_teststr=1") else if "%tests.set%"=="a" (set "u_teststr=1")
 if defined u_teststr (
  echo ---------- %time:~0,8%: "%~n0" - windows tests --------
  echo.
 )
 echo ----------- %time:~0,8%: "%~n0" - path tests ----------
 echo [%time%]: @fixedpath ^> "..\(%%test) &^!^^.^^%%path^^%%.folder\+^^t^!e&s%%t^!%%^^.bat"
 if not exist "..\(%%test) &^!^^.^^%%path^^%%.folder" mkdir "..\(%%test) &^!^^.^^%%path^^%%.folder"
 echo.>"..\(%%test) &^!^^.^^%%path^^%%.folder\+^^t^!e&s%%t^!%%^^.bat"
 if exist "..\(%%test) &^!^^.^^%%path^^%%.folder\+^^t^!e&s%%t^!%%^^.bat" (
  set u_teststr="..\(?test) *.*path*.folder\+?t*e*s*t*.bat"

  echo      Suite #1: Added file, check disabled [DDE] ^& enabled [EDE] expansions
  %@mac_check% @fixedpath,u_teststr 1:u_testbat 6:2,u_testbat %@istrue% && (
   for %%a in (1 2 3) do for %%b in (1,2) do for %%c in (1,2) do (
    if %%c EQU 1 (
     call:fixedpath_tests %%a %%b %%c 0
    ) else for %%d in (0,1) do (
     call:fixedpath_tests %%a %%b %%c %%d
    )
   )
  ) || echo [!time!]: Failed to get file path name

  echo      Suite #2: Modify 8d3 names dropping "^!%%&^^~", standard dos numbers prefix
  %@fixedpath% u_res1 u_teststr 4:4 5:1 6:2 7:1 A:0
  echo [!time!]: !u_res1!
  echo                Cleanup any short ^(8d3^) names
  %@fixedpath% u_res2 u_teststr 4:6 6:2 7:1 A:0
  echo [!time!]: !u_res2!
  echo                Add only absent 8d3 without "^!%%&^^~()'`$#@{}", default prefix
  %@fixedpath% u_res3 u_teststr 4:3 6:2 7:1 A:0
  if !u_res1!==!u_res3! (
   echo                FAIL [ cleanup of names ]: repeat modifying all names:
   %@fixedpath% u_res3 u_teststr 4:5 6:2 7:1 A:0
  ) else (
   echo                PASS [ cleanup of names ]
  )
  echo [!time!]: !u_res3!
  echo                @shortpath:
  %@shortpath% u_res u_testbat
  echo [!time!]: !u_res!
  rmdir /s /q "..\(%%test) &^!^^.^^%%path^^%%.folder"
 ) else (echo                Failed to create test file.)
 echo                @shellfolder desktop
 %@shellfolder% desktop
 if exist %desktop% (set "u_res=PASS,") else (set "u_res=FAIL, not")
 echo [!time!]: !u_res! exist: !desktop!
 if "%tests.set%"=="p" (
  set>envset.txt
  echo [%time%]: The environment set was saved to file `envset.txt`.
  echo ----------- %time:~0,8%: "%~n0" - path tests ----------
  goto:eof
 )
:end_path_tests

::--------------------------------------------------------
::-- Tests of LAN macros @netdevs, @nicconfig & @ipaddress:
::--------------------------------------------------------
:lan_tests
 if not defined tests.homepath (goto:end_tests) else if not "%tests.set%"=="n" if not "%tests.set%"=="a" (goto:end_tests)
 if "%tests.set%"=="a" (
  echo ---------- %time:~0,8%: "%~n0" - path tests --------
  echo.
 )
 echo ----------- %time:~0,8%: "%~n0" - network tests ----------
 echo [%time%]: @netdevs:
 %@netdevs% u_tdevs 1:u_ndevs 2:u_ips 3:u_ip6 4:u_mac 5:u_idx 6:u_cnt 7:u_qnu 8:u_qnc
 echo [!time!]: DONE, NIC device names:
 echo  typeperf:    !u_tdevs!
 echo  ipconfig:    !u_ndevs!
 echo                Other data:
 echo  IPv4:        !u_ips!
 echo  IPv6:        !u_ip6!
 echo  MAC:         !u_mac!
 echo  Indexes:      !u_idx!
 echo  Count:        !u_cnt!
 echo                Localized typeperf query strings:
 echo  Usage:       !u_qnu!
 echo  Capacity:    !u_qnc!
 echo                @nicconfig, devices by typeperf names, compare IPv4 ^& MAC:
 set "u_tst=!u_tdevs!,!u_ips!,!u_mac!,!u_idx!"
 for /F "tokens=1,2,3,4 delims=," %%a in ('cmd /d /q /e:on /v:on /r "!@str_arrange! C:4 R:!u_cnt! D:, E:0 u_tst"') do (
  for %%b in (u_mac u_dhcp u_auto u_ip u_dnssfx u_auto u_adhcp u_mask u_gate u_sdhcp u_dnssrv u_dnssrv u_ipv6 u_ip6iaid u_ip6duid u_wins) do set "%%b="
  set "u_dev=%%~a"
  echo [!time!]: #%%d, '%%~a'
  %@mac_check% @nicconfig,4:u_auto 5:u_ip E:1 0:u_dnssfx 1:u_dev A:u_wins 2:u_mac 3:u_adhcp 6:u_mask 7:u_gate 8:u_sdhcp 9:u_dnssrv B:u_ipv6 C:u_ip6iaid D:u_ip6duid,u_dev u_mac u_ip u_dnssfx u_auto u_adhcp u_mask u_gate u_sdhcp u_dnssrv u_dnssrv u_ipv6 u_ip6iaid u_ip6duid u_wins %@istrue% && (
   if %%b=="!u_ip!" if %%c=="!u_mac!" (set "u_res=PASS") else (
    set "u_res=FAIL, MAC: %%c ^<^> "!u_mac!"
   ) else (
    set "u_res=FAIL, IPv4: %%b ^<^> "!u_ip!"
   )
   echo [!time!]: !u_res!
   echo  DNS Suffix:   !u_dnssfx!
   echo  Name:         !u_dev!
   echo  MAC Address:  !u_mac!
   echo  DHCP Enabled: !u_adhcp!
   echo  Autoconfig:   !u_auto!
   echo  IPv4:         !u_ip!
   echo  Subnet Mask:  !u_mask!
   echo  Gateway:      !u_gate!
   echo  DHCP Server:  !u_sdhcp!
   echo  DNS Servers: !u_dnssrv!
   echo  WINS Server:  !u_wins!
   echo  IPv6:         !u_ipv6!
   echo  DHCPv6 IAID:  !u_ip6iaid!
   echo  DHCPv6 DUID:  !u_ip6duid!
  )
 )
 echo [!time!]: DONE
 set "u_mask1="
 for /F "tokens=1,2,3,4 delims=." %%a in ('echo.!u_ip!') do if "!u_ip!"=="%%a.%%b.%%c.%%d" (
  for /F "delims=0123456789" %%e in ('echo.%%a%%b%%c%%d~') do if "%%~e"=="~" (
   set "u_mask1=%%a.%%b.%%c"
   echo [!time!]: @ipaddress, IP for "!u_mask1!" ^& compare with "x.x.x.%%d":
  )
 )
 if defined u_mask1 (
  %@ipaddress% u_ip1 !u_mask1!
  if "!u_ip!"=="!u_ip1!" (set "u_res=PASS") else (set "u_res=FAIL")
  echo [!time!]: !u_res!, IP = "!u_ip1!"
 ) else (
  echo [!time!]: @ipaddress, FAIL [because of previous test]
 )
 %@web_avail% u_res
 if !u_res! EQU 0 (set "u_rep=") else (set "u_rep=not ")
 echo [!time!]: @web_avail, internet !u_rep!available
 if !u_res! EQU 0 (
  %@web_ip% u_ip
  echo [!time!]: @web_ip, local internet IPv4 address: !u_ip!
 )
 set>envset.txt
 echo [%time%]: The environment set was saved to file `envset.txt`.
 echo ----------- %time:~0,8%: "%~n0" - network tests ----------
goto:eof

:end_tests
set>envset.txt
echo [%time%]: The environment set was saved to file `envset.txt`.
echo ----------------- %time:~0,8%: "%~n0" -----------------
echo.
goto:eof

::--------------------------------------------------------
::-- Subroutines:
::--------------------------------------------------------

:fixedpath_tests        - runs test suite for @fixedpath macro
::                        %~1 == code number of test type, `1` - direct call, `2` - call inside `for-in-do`, `3` - definition file;
::                        %~2 == context state of delayed expansion, `1` - disabled, `2` - enabled;
::                        %~3 == target (usage) state of delayed expansion, `1` - disabled, `2` - enabled;
::                        %~4 == target notation for work with variable value, `0` - %mypath%, `1` - !mypath!.
::
  if %2 EQU 2 (set "u_cxt_sene=on"&setlocal enabledelayedexpansion) else (set "u_cxt_sene=off"&setlocal disabledelayedexpansion)
  call %%tests.importMacros%%
  (if %1 EQU 1 (
   %@fixedpath% u_res u_teststr 1:u_testres 2:u_pat 3:u_nam 4:%4 6:%3 7:%4
  ) else if %1 EQU 2 (
   for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:%u_cxt_sene% /r "%%@fixedpath%% u_res u_teststr 1:u_testres 2:u_pat 3:u_nam 4:%4 6:%3 7:%4 B:1"') do (
    (set %%a)>NUL 2>&1 || (echo %%a&exit /b 1)
   )
  ) else if %1 EQU 3 (
   if %2 EQU 2 (
    (
     echo @echo off&echo :: Path definition file ...
     %@fixedpath% u_res u_teststr 1:u_testres 2:u_pat 3:u_nam 4:%4 6:%3 7:%4 8:1
     echo :: ... Path definition file
    ) >!u_testbat!
   ) else (
    (
     echo @echo off&echo :: Path definition file ...
     %@fixedpath% u_res u_teststr 1:u_testres 2:u_pat 3:u_nam 4:%4 6:%3 7:%4 8:1
     echo :: ... Path definition file
    ) >%u_testbat%
   )
  ))
  if %3 EQU 1 (setlocal disabledelayedexpansion) else if %3 EQU 2 (setlocal enabledelayedexpansion)
  if %1 EQU 3 call %%u_testbat%%
  if %4 EQU 0 (
   if exist %u_testres% (set "u_e=0") else (set "u_e=1"
    echo                CALL{%1, %2, %3, %4}, percent notation failure:
    echo                %u_testres% 
   )
  ) else (
   if exist !u_testres! (set "u_e=0") else (set "u_e=1"
    echo                CALL{%1, %2, %3, %4}, exclamation notation failure:
    echo                !u_testres!
   )
  )
  setlocal disabledelayedexpansion
  if %4 EQU 0 (if %u_e% EQU 0 (set "u_r=PASS") else (set "u_r=FAIL")) else (if %u_e% EQU 0 (set "u_r=PASS") else (set "u_r=FAIL"))
  set "u_r=%u_r%, type "
  if %1 EQU 1 (set u_r=%u_r%"direct"   ) else if %1 EQU 2 (set u_r=%u_r%"for-in-do") else (set u_r=%u_r%"via-file" )
  set "u_r=%u_r%, context = "
  if %2 EQU 1 (set "u_r=%u_r%DDE") else (set "u_r=%u_r%EDE")
  set "u_r=%u_r%, target = "
  if %3 EQU 1 (set "u_r=%u_r%DDE") else (set "u_r=%u_r%EDE")
  set "u_r=%u_r%, "
  if %4 EQU 1 (set "u_r=%u_r%!mypath!") else (set "u_r=%u_r%%%mypath%%")
  echo [%time%]: %u_r%
exit /b %u_e%
::--------------------------------------------------------

:callstack_tests
 setlocal
 set "dcr_test=               Call stack test (@callstack @exit @drop_conrows @consoletext):"
 (echo !dcr_test!)
 set "u_p=.\call.stack.test\"
 for %%a in ("1 start\test stack 1","2\test-stack-2","3\test-stack-3","4\test-stack-4") do if not exist "!u_p!dir %%~a.bat" (
  echo                FAIL: missing test file "!u_p!dir %%~a.bat"
  goto:eof  ::  Don't use `exit` command above calls inside functions to avoid problem with internal text parsing of @callstack...
 )
 :: The test example contains recurrent calls inside deeper calls, which results in ambiguity in the order of calls inside stack.
 :: The order of initialization of variable argument values inside call stack applies to determine the order of calls in the
 :: ambiguous portion of the stack. To do it robust, the top part of the stack with an unambiguous sequence is used to define the
 :: assignment sequence of these auxiliary variables:
 set "disambiglup1=1"&set "disambiglup2=1"
 call ".\call.stack.test\dir 1 start\test stack 1.bat" f11 f12 [#0] f14 %disambiglup1% %%disambiglup2%%
 echo [!time!]: %%@exit%% done, reading console text to check result...

 (set delim=",")
 %@consoletext% c_text 4:32 5:delim
 set "u_c=0"
 for %%a in ("!c_text!") do (
  if !u_c! EQU 15 (set "u_m1=%%a") else if !u_c! EQU 31 (set "u_m2=%%a") else if !u_c! LSS 15 (set "u_c!u_c!=%%a") else (
   set /a "u_a=!u_c!-16">NUL
   set "u_e!u_a!=%%a"
  )
  set /a "u_c+=1">NUL
 )
 set "u_c=0"
 for /L %%a in (0,1,14) do if not "!u_c%%a!"=="!u_e%%a!" (
  set "u_er_c!u_c!=!u_c%%a!"
  set "u_er_e!u_c!=!u_e%%a!"
  set /a "u_c+=1">NUL
 )
 %@drop_conrows% 32
 echo !u_m1:~1,-1!
 echo !u_m2:~1,-1!
 %@consoletext% c_text 3:3
 if 0 LSS !u_c! (
  echo                FAIL - %%@callstack%% or %%@exit%%, outputs differ:
  set /a "u_c-=1">NUL
  for /L %%a in (0,1,!u_c!) do (
   echo [CS#%%a]: !u_er_c%%a!
   echo [EX#%%a]: !u_er_e%%a!
  )
 ) else if "!c_text!"=="!dcr_test!" (
  echo                PASS - %%@callstack%%, %%@exit%%, %%@drop_conrows%% ^(%%@consoletext%%^)
 ) else (
  echo                PASS - %%@callstack%% ^& %%@exit%%, FAIL - %%@drop_conrows%%
 )
exit /b 0
::--------------------------------------------------------

:tests_startup          - initialization of tests, context with disable delayed expansion.
::
 set "tests.importMacros=1"&set "tests.set="&cmd /d /q /r exit /b 0
 (echo ",1,2,3,4,5," | findstr /C:",%~n1,")>nul && (
  set "tests.importMacros="
  (echo ",4,5," | findstr /C:",%~n1,")>nul && (if defined wait.mds if exist %wait.mds% set "tests.importMacros=%~n1") ^
                                           || (set "tests.importMacros=%~n1")
  (echo ",b,w,p,n,a," | findstr /C:",%~n2,")>nul && (set "tests.set=%~n2")
 ) || (echo ",b,w,p,n,a," | findstr /C:",%~n1,")>nul && (set "tests.set=%~n1")

 if "%tests.importMacros%"=="" echo Error [%time%]: install library before running tests from install folder...&exit /b 1

 for %%a in ("tests.homepath=%%~d0%%~p0","tests.homepath=%%tests.homepath:~0,-1%%") do call set %%a
 for %%a in ("%%tests.homepath%%\..") do set tests.homepath="%%~da%%~pa"

 if %tests.importMacros% EQU 1 (
  if not exist "%tests.homepath:~1,-1%wait.mds.bat" (echo Error [%time%]: the library file doesn't exist ["%tests.homepath:~1,-1%\wait.mds.bat"]&exit /b 1)
  (set tests.importFile="%tests.homepath:~1,-1%wait.mds.bat")
  (set tests.importMacros="%tests.homepath:~1,-1%wait.mds.bat" /sub:importMacros)
 ) else if %tests.importMacros% EQU 2 (
  if not exist "%tests.homepath:~1,-1%macros\macros.general.collapsed.bat" (echo Error [%time%]: file "%tests.homepath:~1,-1%macros\macros.general.collapsed.bat" doesn't exist, unable to import macros...&exit /b 1)
  (set tests.importFile="%tests.homepath:~1,-1%macros\macros.general.collapsed.bat")
  (set tests.importMacros="%tests.homepath:~1,-1%macros\macros.general.collapsed.bat")
 ) else if %tests.importMacros% EQU 3 (
  if not exist "%tests.homepath:~1,-1%macros\macros.general.expanded.bat" (echo Error [%time%]: file "%tests.homepath:~1,-1%macros\macros.general.expanded.bat" doesn't exist, unable to import macros...&exit /b 1)
  (set tests.importFile="%tests.homepath:~1,-1%macros\macros.general.expanded.bat")
  (set tests.importMacros="%tests.homepath:~1,-1%macros\macros.general.expanded.bat")
 ) else if %tests.importMacros% EQU 4 (
  for /F "tokens=*" %%a in (%wait.mds%) do (
   if not exist "%%~da%%~pawait.mds.lite.bat" (echo Error [%time%]: install folder has not file "%%~da%%~pawait.mds.lite.bat", install library before running tests...&exit /b 1)
   (set tests.importFile="%%~da%%~pawait.mds.lite.bat")
   (set tests.importMacros="%%~da%%~pawait.mds.lite.bat" /sub:importMacros)
  )
 ) else if %tests.importMacros% EQU 5 (
  (set tests.importFile="%wait.mds%")
  (set tests.importMacros="%wait.mds%" /sub:importMacros)
 )
 cls
 (set tests.eventfile="%tests.homepath:~1,-1%Tests\wait.events.json")

 if not exist "%tests.homepath:~1,-1%com.api.wrapper\test_batch.bat" (echo Error [%time%]: the console script for tests doesn't exist ["%tests.homepath:~1,-1%com.api.wrapper\test_batch.bat"]&exit /b 1)
 if not exist "%tests.homepath:~1,-1%com.api.wrapper\test_forms.exe" (echo Error [%time%]: the windows forms application for tests doesn't exist ["%tests.homepath:~1,-1%com.api.wrapper\test_forms.exe"]&exit /b 1)

 if defined @unset_mac (
  echo [%time%]: Unexpected definitions, recommended to restart Console ...
  if defined @unset %@unset% 1:wds_
  if defined @unset_mac for /F %%a in ('cmd /d /q /r "%%@unset_mac%%[]"') do set %%a
 )
 for /F "tokens=2,4,5 delims=[.]" %%a in ('ver') do for %%d in (%%a%%b) do if defined tests.notepad.of.win11 (
  if %%d LSS 1022000 (set "tests.notepad.of.win11=") else if %%c LEQ 346 (set "tests.notepad.of.win11=") else (
   echo WARNING: To run tests with the Windows 11 notepad version, the script will 
   echo          need to close all open windows of this editor...
   echo.
   timeout /NOBREAK /t 2 >NUL 2>&1
  )
 ) else (set "tests.notepad.of.win11=1")

 (setlocal enabledelayedexpansion
  if defined @unset_mac (set "rep=") else (set "rep=1")
  echo [%time%]: tests.importMacros - attempt to import or initialize macros ...
  call %%tests.importMacros%%
  if not defined @fixedpath (echo Error [%time%]: failed to import macros using %tests.importMacros%&exit /b 1)
  echo [%time%]: tests.importMacros - DONE
  if defined rep cls

  set "rep= will be created automatically, it takes ~2-4 min when it queried by a corresponding macro..."
  if exist "%ProgramFiles%\wait.mds\WaitMdsApiWrapper.tlb" (
   if not exist "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id001" (echo [%time%]: The performance counter index file!rep!)
  ) else (
   if exist "%ProgramFiles%\wait.mds\wait.mds.auxiliary.file.id001" (
    echo [%time%]: The COM server library!rep!
   ) else (
    echo [%time%]: The COM server library ^& the performance counter index file!rep!
   )
  )
 )
 echo.
exit /b 0
::--------------------------------------------------------
