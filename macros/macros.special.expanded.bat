@echo off
goto:eof
::  ---------------------------------------------------------------------------------------------------------------------
::  SECTION OF CODE THAT CAN NOT BE USED INDEPENDENTLY - it contains only the source code in a form suitable for editing.
::  ----------------------------------------------- \/ \/ \/ \/ \/ \/ \/ ------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_wmc_evp         - reads event predicate string and gets parameters with checks.
set @wds_wmc_evp=^
 (for %%a in (%%wds_wmc_evp%%) do (set "%%a="))^&^
 for %%x in (1 2) do if %%x EQU 2 for /F %%y in ('echo wds_evm_') do (^
  (for /F "tokens=1,2,3,4,5,6,7,8,9" %%a in ('echo.%%%%yaux%%') do if not "%%g"=="" (^
   (for %%j in ("rev=0","tyn=%%d","tyv=%%c","lpn=%%e","a1n=%%f","a1v=","a2n=%%g","a2v=","a3n=%%h","a3v=") do (set "%%y%%~j"))^&^
   (if defined %%e (call set "%%ylpv=%%%%e%%") else (set "%%ylpv="))^&^
   (if "%%~b"==%%b (set "%%yren=") else (set "%%yren=%%b"))^&^
   (if defined %%ylpv (^
    set "%%y1=%%c"^&(for %%j in ("f=1","a=2","p=1","i=1","c=1","n=1","d=1","v=1","u=1","t=1","h=3","l=4","r=2","w=3","s=1","m=1","e=1") do (call set "%%y1=%%%%y1:%%~j%%"))^&^
    (set %%yquo="")^&call set "%%yquo=%%%%yquo:~1%%"^&^
    (for /L %%j in (4,-1,1) do (^
     set "%%y2=w3h3l2l4"^&(for /F "tokens=1,2" %%k in ('"echo %%%%y2%% %%%%y2:%%c%%j=%%"') do if not %%k==%%l (set "%%y2="))^&^
     set /a "%%yaux=%%j+4"^>NUL^&^
     (for /F "tokens=1,2,*" %%k in ('cmd /d /q /e:on /v:on /r "for /F %%%%yquo%%usebackq tokens=%%j,%%%%yaux%% delims=?%%%%yquo%% %%^n in (`echo lpv?a1v?a2v?a3v?^!%%ylpv^!?%%i%%i?%%i%%i?%%i%%i?%%i%%i`) do (echo %%%%y1%% %%^n %%^o)"') do (^
      (if %%m==%%i%%i (^
       (if %%j LEQ %%k if defined %%y2 (^
        (if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Event type `%%c` must have %%k predicate items, item #%%j undefined.))^&^
        exit /b 1^
       ))^&^
       set "%%y%%l="^
      ) else (^
       (if %%k LSS %%j ((if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Event type `%%c` can have only %%k predicate items, found item #%%j: check and replace control characters with their code, for example, the character `?` with the code `#3F;`.))^&exit /b 1))^&^
       set "%%y%%l=%%m"^&call set "%%ytmp=%%%%y%%l:~1,-1%%"^&^
       (for /F "tokens=*" %%n in ('"echo %%i%%%%ytmp%%%%i"') do (^
        (if %%n==%%m (^
         call set "%%y%%l=%%%%ytmp%%"^
        ) else (^
         (if defined %%m (^
          (if %%c==m (set "%%y%%l=%%m") else (^
           (call set "%%y%%l=%%%%m%%"^>NUL 2^>^&1) ^&^& (^
            (call echo %%%%y%%l%%^>NUL 2^>^&1) ^|^| (echo Error [%%a]: Event type `%%c` can not have unmanagable control symbols inside value of given predicate variable `%%m`^&exit /b 1)^
           ) ^|^| (set "%%y%%l=")^
          ))^
         ) else (set "%%y%%l="^&set "%%ytmp="))^&^
         (if not defined %%y%%l (^
          (if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Undefined variable `%%~m` of predicate item or this variable name is not allowed.))^&^
          exit /b 1^
         ))^&^
         (if defined %%m (set "%%ytmp=%%~m"^&(for /L %%o in (0,1,9) do if defined %%ytmp (call set "%%ytmp=%%%%ytmp:%%o=%%"))))^&^
         (if not defined %%ytmp (^
          (if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Incorrect variable name `%%~m` - absent markers of explicit value.))^&^
          exit /b 1^
         ))^
        ))^
       ))^
      ))^
     ))^
    ))^&^
    set "%%yaux=1"^&^
    (for %%j in (f,a,e) do if %%j==%%c for /F %%k in ('"echo.%%%%ylpv%%"') do if not defined %%k (^
     (for /F %%k in ('"echo.%%%%ylpv%%"') do if defined %%k (call set "%%ylpv=%%%%k%%"))^&^
     (for /F %%l in ('"echo.%%%%yquo%%"') do (call set "%%ylpv=%%%%ylpv:%%l=%%"))^&^
     (call set %%ylpv="%%%%ylpv:\\=\%%")^&set "%%yaux="^
    ))^&^
    (if defined %%yaux (^
     (if %%c==l (set "%%yaux=1") else (set "%%yaux="))^&^
     (for %%j in (r,w,s,h) do if %%j==%%c (^
      set "%%yaux="^&^
      (for /F "tokens=* delims=+,-,0" %%k in ('echo.%%%%ylpv%%') do (^
       set "%%ylpv=0"^&^
       ((set /a "%%ytmp=%%~k"^>NUL 2^>^&1)^>NUL ^&^& (set "%%yaux=%%~k"))^
      ))^&^
      (if defined %%yaux (^
       call set "%%ylpv=%%%%yaux%%"^&(if NOT %%c==h (set "%%yaux="))^
      ) else (^
       (if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Expected non-zero decimal handle in predicate 1st item.))^&^
       exit /b 1^
      ))^
     ))^
    ))^&^
    (if defined %%yaux (^
     (if %%c==h (call set "%%yaux=[%%%%ya1v%%]") else (call set "%%yaux=[%%%%ya2v%%]"))^&^
     (for %%j in ("[IsWindow]=[0]" "[IsWindowVisible]=[1]" "[IsWindowEnabled]=[2]" "[IsActive]=[3]" "[IsForeground]=[4]" "[IsHungAppWindow]=[5]" "[IsZoomed]=[6]" "[IsIconic]=[7]" "[IsChild]=[8]" "[IsMenu]=[9]") do (^
      call set "%%yaux=%%%%yaux:%%~j%%"^
     ))^&^
     call set "%%yaux=%%%%yaux:~1,-1%%"^&^
     (for /F %%j in ('echo %%%%yaux%%') do if 0 LSS %%j if %%j LSS 10 (^
      (if %%j EQU 8 (^
       (if %%c==h (call set "%%yaux=%%%%ya2v%%") else (call set "%%yaux=%%%%ya3v%%"))^&^
       (for /F "tokens=* delims=+,-,0" %%k in ('echo.%%%%yaux%%') do (^
        set "%%yaux="^&((set /a "%%ytmp=%%~k"^>NUL 2^>^&1)^>NUL ^&^& (set "%%yaux=%%~k"))^
       ))^&^
       (if defined %%yaux (^
        (if %%c==h (call set "%%ya2v=%%%%yaux%%") else (call set "%%ya3v=%%%%yaux%%"))^
       ) else (^
        (if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Expected non-zero decimal handle of parent window as a predicate last item.))^&^
        exit /b 1^
       ))^
      ))^
     ) else ((if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: @windowstate has not value `%%j` of 2nd key attribute, allowed [0..9].))^&exit /b 1))^
    ))^
   ))^&^
   (if not defined %%ylpv if not %%c==n if not %%c==d if not %%c==v if not %%c==u if not %%c==t ((if defined %%yren (call echo "%%%%yren%%=-3") else (echo Error [%%a]: Undefined predicate attribute `/i:`.))^&exit /b 1))^&^
   set "%%ytyv=%%c"^&^
   (for %%j in (re,ty,lp,a1,a2,a3) do if defined %%y%%jn if defined %%y%%jv (call echo "%%%%y%%jn%%=%%%%y%%jv%%") else (call echo "%%%%y%%jn%%="))^
  ))^
 ) else set wds_evm_aux=
:: @wds_wmc_evp         - reads event predicate string and gets parameters with checks.
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_wmc_dow         - performs waiting and checks time of start and finish.
set @wds_wmc_dow=^
 (for /F "delims==" %%a in ('set @') do if not "%%a"=="@time_span" (set "%%a="))^&^
 (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r "^!@time_span^! B:wds_wmc_beg 5:wds_dwt_tsp 7:2 9:1"') do (set %%a))^&^
 set /a "wds_wmc_beg+=^!wds_dwt_tsp^!"^>NUL^&(if 86400000 LEQ ^^^!wds_wmc_beg^^^! (set /a "wds_wmc_beg-=86400000"))^&^
 (if defined wds_wmc_out (^
  set /a "wds_wmc_out-=^!wds_dwt_tsp^!"^>NUL^&^
  (if ^^^!wds_wmc_out^^^! LSS ^^^!wds_wmc_stp^^^! (set /a "wds_wmc_stp=^!wds_wmc_out^!"^>NUL))^&^
  (if ^^^!wds_wmc_stp^^^! LEQ 0 (set "wds_wmc_out=0"))^
 ))^&^
 (if 0 LSS ^^^!wds_wmc_stp^^^! (^
  set "wds_dwt_msc=^!wds_wmc_stp^!"^&^
  (if 60 LSS ^^^!wds_wmc_ver^^^! (^
   set /a "wds_dwt_sec=^!wds_wmc_stp^!/1000"^>NUL^&set /a "wds_dwt_msc=^!wds_wmc_stp^!-^!wds_dwt_sec^!*1000"^>NUL^&^
   (if 0 LSS ^^^!wds_dwt_sec^^^! (set /a "wds_dwt_sec-=1"^>NUL^&set /a "wds_dwt_msc+=1000"^>NUL))^&^
   (if 0 LSS ^^^!wds_dwt_sec^^^! (^
    (timeout /T ^^^!wds_dwt_sec^^^! /nobreak)^>NUL 2^>^&1^&^
    set "wds_dwt_tsp=0"^
   ))^
  ) else (^
   set "wds_dwt_sec=0"^&set "wds_dwt_msc=^!wds_wmc_stp^!"^
  ))^&^
  (if 700 LSS ^^^!wds_dwt_msc^^^! (^
    set /a "wds_dwt_msc-=350"^>NUL^&^
    (pathping 127.0.0.1 -n -q 1 -p ^^^!wds_dwt_msc^^^!)^>NUL 2^>^&1^&^
    set "wds_dwt_tsp=0"^
  ))^&^
  (if ^^^!wds_dwt_tsp^^^! EQU 0 (^
   (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r "^!@time_span^! B:wds_wmc_beg 5:wds_dwt_tsp 7:2 9:1"') do (set %%a))^&^
   (set /a "wds_wmc_beg+=^!wds_dwt_tsp^!"^>NUL)^&(if 86400000 LEQ ^^^!wds_wmc_beg^^^! (set /a "wds_wmc_beg-=86400000"^>NUL))^&^
   (if defined wds_wmc_out (set /a "wds_wmc_out-=^!wds_dwt_tsp^!"^>NUL))^&^
   (if ^^^!wds_wmc_stp^^^! LEQ ^^^!wds_dwt_tsp^^^! (exit /b 0))^&^
   set /a "wds_dwt_spn=^!wds_wmc_stp^!-^!wds_dwt_tsp^!"^>NUL^
  ) else (^
   set "wds_dwt_spn=^!wds_wmc_stp^!"^
  ))^&^
  set wds_dwt_beg=^^^!time: =0^^^!^&^
  (set wds_dwt_dow="(for /L %%^^n in (1,1,2147483647) do (set wds_dwt_end=$wds_dwt_exc$time: =0$wds_dwt_exc$$wds_dwt_amp$(if not $wds_dwt_quo$$wds_dwt_exc$wds_dwt_beg$wds_dwt_exc$$wds_dwt_quo$==$wds_dwt_quo$$wds_dwt_exc$wds_dwt_end$wds_dwt_exc$$wds_dwt_quo$ (set wds_dwt_bms=1$wds_dwt_exc$wds_dwt_beg:~9,2$wds_dwt_exc$0$wds_dwt_amp$set wds_dwt_ems=1$wds_dwt_exc$wds_dwt_end:~9,2$wds_dwt_exc$0$wds_dwt_amp$set wds_dwt_beg=$wds_dwt_exc$wds_dwt_end$wds_dwt_exc$$wds_dwt_amp$(if $wds_dwt_exc$wds_dwt_ems$wds_dwt_exc$ LSS $wds_dwt_exc$wds_dwt_bms$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_dwt_ems+=1000$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$set /a $wds_dwt_quo$wds_dwt_dif=$wds_dwt_exc$wds_dwt_ems$wds_dwt_exc$-$wds_dwt_exc$wds_dwt_bms$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$set /a $wds_dwt_quo$wds_wmc_beg+=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$(if 86400000 LEQ $wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_wmc_beg-=86400000$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$(if defined wds_wmc_out (set /a $wds_dwt_quo$wds_wmc_out-=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$set /a $wds_dwt_quo$wds_dwt_spn-=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$(if $wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$ LEQ $wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_wmc_beg+=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$(if 86400000 LEQ $wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_wmc_beg-=86400000$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$(if defined wds_wmc_out (set /a $wds_dwt_quo$wds_wmc_out-=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$echo $wds_dwt_quo$wds_wmc_beg=$wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_amp$echo $wds_dwt_quo$wds_wmc_out=$wds_dwt_exc$wds_wmc_out$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_amp$exit /b 0))))))")^&^
  (set wds_dwt_quo="")^&(set wds_dwt_quo=^^^!wds_dwt_quo:~1^^^!)^&(set "wds_dwt_amp=1^^^&1")^&(call set "wds_dwt_amp=%%wds_dwt_amp:~-2,1%%")^&(set wds_dwt_exc="^^^!")^&(call set "wds_dwt_exc=%%wds_dwt_exc:~1,-1%%")^&(set wds_dwt_rab="^^^>")^&(call set "wds_dwt_rab=%%wds_dwt_rab:~-2,1%%")^&^
  (call set wds_dwt_dow=%%wds_dwt_dow:$wds_dwt_quo$=^^^!wds_dwt_quo^^^!%%)^&^
  (call set wds_dwt_dow=%%wds_dwt_dow:$wds_dwt_amp$=^^^!wds_dwt_amp^^^!%%)^&^
  (call set wds_dwt_dow=%%wds_dwt_dow:$wds_dwt_exc$=^^^!wds_dwt_exc^^^!%%)^&^
  (call set wds_dwt_dow=%%wds_dwt_dow:$wds_dwt_rab$=^^^!wds_dwt_rab^^^!%%)^&^
  (for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r ^^^!wds_dwt_dow^^^!') do (set %%a))^
 ))

::-------------- (partially) expanded string of macro: ---------------
(set wds_dwt_dow="
 (for /L %%^^n in (1,1,2147483647) do (
  set wds_dwt_end=$wds_dwt_exc$time: =0$wds_dwt_exc$$wds_dwt_amp$
  (if not $wds_dwt_quo$$wds_dwt_exc$wds_dwt_beg$wds_dwt_exc$$wds_dwt_quo$==$wds_dwt_quo$$wds_dwt_exc$wds_dwt_end$wds_dwt_exc$$wds_dwt_quo$ (
   set wds_dwt_bms=1$wds_dwt_exc$wds_dwt_beg:~9,2$wds_dwt_exc$0$wds_dwt_amp$
   set wds_dwt_ems=1$wds_dwt_exc$wds_dwt_end:~9,2$wds_dwt_exc$0$wds_dwt_amp$
   echo [dow.2.%%^^n] dwt_beg=$wds_dwt_exc$wds_dwt_beg$wds_dwt_exc$ dwt_end=$wds_dwt_exc$wds_dwt_end$wds_dwt_exc$ dwt_bms=$wds_dwt_exc$wds_dwt_bms$wds_dwt_exc$ dwt_ems=$wds_dwt_exc$wds_dwt_ems$wds_dwt_exc$ $wds_dwt_rab$$wds_dwt_rab$123.txt$wds_dwt_amp$
   set wds_dwt_beg=$wds_dwt_exc$wds_dwt_end$wds_dwt_exc$$wds_dwt_amp$
   (if $wds_dwt_exc$wds_dwt_ems$wds_dwt_exc$ LSS $wds_dwt_exc$wds_dwt_bms$wds_dwt_exc$ (
    set /a $wds_dwt_quo$wds_dwt_ems+=1000$wds_dwt_quo$$wds_dwt_rab$NUL
   ))$wds_dwt_amp$
   set /a $wds_dwt_quo$wds_dwt_dif=$wds_dwt_exc$wds_dwt_ems$wds_dwt_exc$-$wds_dwt_exc$wds_dwt_bms$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$
   set /a $wds_dwt_quo$wds_wmc_beg+=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$
   (if 86400000 LEQ $wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_wmc_beg-=86400000$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$
   (if defined wds_wmc_out (
    set /a $wds_dwt_quo$wds_wmc_out-=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL
   ))$wds_dwt_amp$
   set /a $wds_dwt_quo$wds_dwt_spn-=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$
   (if $wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$ LEQ $wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$ (
    set /a $wds_dwt_quo$wds_wmc_beg+=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL$wds_dwt_amp$
    (if 86400000 LEQ $wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$ (set /a $wds_dwt_quo$wds_wmc_beg-=86400000$wds_dwt_quo$$wds_dwt_rab$NUL))$wds_dwt_amp$
    (if defined wds_wmc_out (
     set /a $wds_dwt_quo$wds_wmc_out-=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_rab$NUL
    ))$wds_dwt_amp$
    echo $wds_dwt_quo$wds_wmc_beg=$wds_dwt_exc$wds_wmc_beg$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_amp$
    echo $wds_dwt_quo$wds_wmc_out=$wds_dwt_exc$wds_wmc_out$wds_dwt_exc$$wds_dwt_quo$$wds_dwt_amp$
    echo [dow.end] spn=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$ dif=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$ tsp=$wds_dwt_exc$wds_dwt_tsp$wds_dwt_exc$$wds_dwt_rab$$wds_dwt_rab$123.txt$wds_dwt_amp$
    exit /b 0
   ))$wds_dwt_amp$
   echo [dow.3.%%^^n] spn=$wds_dwt_exc$wds_dwt_spn$wds_dwt_exc$ dif=$wds_dwt_exc$wds_dwt_dif$wds_dwt_exc$ $wds_dwt_rab$$wds_dwt_rab$123.txt
  ))
 ))
")^&^
:: @wds_wmc_dow         - performs waiting and checks time of start and finish.
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_wmc_evh         - performs events handling.
set @wds_wmc_evh=^
 (for %%a in (%%wds_wmc_evh%%) do (set "%%a="))^&^
 for %%x in (1 2 3) do if %%x EQU 3 (for /F %%y in ('echo wds_ev^^^!wds_evh_aux^^^!_') do (^
  set "wds_evh_aux="^&^
  (for /F "tokens=1,2,3,4,5,6,7,8" %%a in ('echo.%%%%yaux%%') do (^
   set "%%y0=cmd /d /q /v:on /e:on /r "^&^
   (call set %%y7=%%%%y0%%"for /F "tokens=*" %%^^r in ('%%%%y0%%"^^^!@%%^%%y5%%^^^! %%^%%y6%%:1"') do echo %%^^r")^&^
   (for %%j in (%%c,%%d,%%e,%%f) do if defined %%j for /F "tokens=2 delims=#;" %%k in ('echo.%%%%j%%$') do if not "%%~k"=="" (^
    (call set %%j="%%%%j%%")^&^
    (for /F "tokens=*" %%l in ('%%%%y0%%"^!@str_decode^! %%j # ; 1"') do (set %%l^>NUL 2^>^&1)^>NUL)^&^
    call set "%%j=%%%%j:~1,-1%%"^
   ))^&^
   set "%%y1=em"^&^
   (if "^!%%y1:%%b=^!"=="^!%%y1^!" (^
    set "%%y1=fa"^&^
    (if "^!%%y1:%%b=^!"=="^!%%y1^!" (^
     set "%%y1=pic"^&^
     (if "^!%%y1:%%b=^!"=="^!%%y1^!" (^
      set "%%y1=lhrsw"^&^
      (if "^!%%y1:%%b=^!"=="^!%%y1^!" (^
       (for /F "tokens=*" %%j in ('%%%%y0%%"^!@typeperf_res_use^! %%b %%a 1:%%c 4:1"') do (set %%j^>NUL 2^>^&1)^>NUL)^&^
       (if ^^^!errorlevel^^^! EQU 0 (^
        (if 3 LSS ^^^!%%a^^^! (set "%%a=1") else (set "%%a=0"))^
       ) else (^
        set "%%a=-1"^&call %%@errorLevel%% 0^
       ))^
      ) else (^
       set "%%y1=lh"^&set "%%y5=windowstate"^&set "%%y6=%%a 0 %%c 4"^&^
       (if "^!%%y1:%%b=^!"=="^!%%y1^!" (^
        for /F "tokens=*" %%j in ('%%%%y7%%') do (set %%j^>NUL 2^>^&1)^>NUL^
       ) else (^
        set "%%y4="^&^
        (if %%b==l (^
         (if ^^^!%%e^^^! EQU 8 (^
          for /F "tokens=*" %%j in ('%%%%y0%%"^!@findcontrol^! %%a %%f %%c %%d 1:%%y2 2:250 3:1"') do (set %%j^>NUL 2^>^&1)^
         ) else (^
          for /F "tokens=*" %%j in ('%%%%y0%%"^!@findwindow^! %%a %%c %%d 1:%%y2 2:250 4:1"') do (set %%j^>NUL 2^>^&1)^
         ))^>NUL^&^
         set "%%y3=^!%%e^!"^&(if defined %%f (set "%%y4=^!%%f^!"))^
        ) else if %%b==h (^
         (for /F "tokens=*" %%j in ('%%%%y7%%') do (set %%j^>NUL 2^>^&1)^>NUL)^&^
         set "%%y2=^!%%c^!"^&set "%%y3=^!%%d^!"^&(if defined %%e (set "%%y4=^!%%e^!"))^
        ))^&^
        (if "^!%%a^!^!%%y3^!"=="00" (set "%%a=2") else (^
         set "%%y6= "^&(if defined %%y4 (set "%%y6=^!%%y6^!2:%%y4 "))^&set "%%y6=%%a ^!%%y3^! %%y2^!%%y6^!4"^
        ))^
       ))^&^
       (if ^^^!%%a^^^! EQU 2 (set "%%a=0") else if ^^^!%%a^^^! EQU 0 (^
            (if %%b==r (set "%%y5=consoletext"^&set "%%y6=%%c 1:"^^^!%%c^^^!" 4:10 8:%%a E:2 F")^
        else if %%b==s (set "%%y5=compareshots"^&set "%%y6=%%a 2:%%c 4:%%y2 7")^
        else if %%b==w (set "%%y5=enwalue"^&set "%%y6=%%y3 1:%%c 3:^!%%d^! 6:%%a 8"))^&^
        set "%%y3="^&^
        (for /F "tokens=*" %%j in ('%%%%y7%%') do if %%b==r (if defined %%y3 (^
         (if ^^^!%%a^^^! EQU 1 if "%%j"=="^!%%d^!" (set "%%a=0"))^
        ) else (^
         set %%j^&set "%%y3=1"^&^
         (if ^^^!%%a^^^! EQU 0 (set "%%a=1") else (^
          (echo 56 ^| findstr /c:"^!%%a^!")^>NUL 2^>^&1 ^&^& (set "%%a=-1") ^|^| (set "%%a=-2")^
         ))^&^
        )) else ((set %%j^>NUL 2^>^&1) ^|^| (^
         for /F "delims== tokens=2" %%k in ('"echo %%~j"') do if not "%%k"=="" (set "%%a=-2")^
        ))^>NUL)^&^
        (if %%b==s (^
         if ^^^!%%a^^^! EQU 0 (if ^^^!%%y2^^^! NEQ 0 (set "%%a=1")) else (set "%%a=-1")^
        ) else if %%b==w (^
         (if 2 LSS ^^^!%%a^^^! for /L %%j in (1,1,3) do if 2 LSS ^^^!%%a^^^! (^
          (if %%wds_wmc_ver%% LSS 60 (pathping 127.0.0.1 -n -q 1 -p %%j000) else (timeout /T %%j /nobreak))^>NUL 2^>^&1^&^
          (for /F "tokens=*" %%k in ('%%%%y7%%') do (set %%k^>NUL 2^>^&1)^>NUL)^
         ))^&^
         (if ^^^!%%a^^^! EQU 0 (^
          if not defined %%e (set "%%a=1") else if not "^!%%y3^!"=="^!%%e^!" (set "%%a=1")^
         ) else if ^^^!%%a^^^! LSS 0 (^
          if defined %%e (set "%%a=1") else (set "%%a=0")^
         ) else if 3 LSS ^^^!%%a^^^! (^
          if defined %%h (set "%%a=0") else (set "%%a=1")^
         ) else (set "%%a=-2"))^
        ))^
       ) else if ^^^!%%a^^^! EQU 1 (^
        if "^!%%y1:%%b=^!"=="^!%%y1^!" (set "%%a=-1") else if ^^^!%%y2^^^! NEQ 0 (set "%%a=-1")^
       ) else (set "%%a=-2"))^
      ))^
     ) else (^
            (if %%b==p ((set %%y2="tasklist")^&(set %%y3="tokens=1 delims=.")^&set "%%y4=9"^
      ) else if %%b==i ((set %%y2="tasklist /fo:csv")^&(set %%y3="tokens=*")^&set "%%y4=6:2;9"^
      ) else if %%b==c ((set %%y2="tasklist /v /fo:csv")^&(set %%y3="tokens=*")^&set "%%y4=4:1;6:-1;9"^
      ))^&^
      (for /F "tokens=*" %%j in ('%%%%y0%%"^!@res_select^! %%c;%%y2;%%y3;2:%%a;^!%%y4^!:1"') do (set %%j^>NUL 2^>^&1)^>NUL)^&^
      (if 0 LSS ^^^!%%a^^^! (set "%%a=0") else (set "%%a=1"))^
     ))^
    ) else (^
     (if defined ^^^!%%c^^^! (set "%%y8=^!%%c^!") else (set "%%y8=%%c"))^&^
     (if %%b==f (set "%%y5=exist"^&set "%%y6=%%a ^!%%y8^! 5") else (set "%%y5=obj_attrib"^&set "%%y6=%%a ^!%%y8^! ^!%%d^! 3"))^&^
     (for /F "tokens=*" %%j in ('%%%%y7%%') do (set %%j^>NUL 2^>^&1)^>NUL)^
    ))^
   ) else if %%b==m (^
    set "%%a=-1"^&^
    (^
     (for %%j in (1,3,4,7,8,9) do (set "%%y%%j="))^&set "%%a="^&^
     (set %%y6="(for /F %%^%%y1%%usebackq tokens=*%%^%%y1%% %%^^r in (`%%%%y0%%%%^%%y1%%%%^%%y5:~1,-1%%%%^%%y1%%`) do (echo %%^^r))")^&^
     (set %%y5="(for /F %%^%%y1%%usebackq delims==%%^%%y1%% %%^^r in (`set wds_`) do (set %%^^r=))%%^%%y2%%(for /F %%^%%y1%%usebackq delims==%%^%%y1%% %%^^r in (`set @wds_`) do (set %%^^r=))%%^%%y2%%")^&^
     (if defined ^^^!%%c^^^! (^
      (call set %%y5="(%%%%y5:~1,-1%%(^!%%%%c%%^! %%a)%%^%%y2%%(call echo %%a %%^%%a%%))")^
     ) else (^
      set "%%y8=%%c"^&^
      (call set %%y5="(%%%%y5:~1,-1%%(%%%%^%%y8%%%% %%a)%%^%%y2%%(call echo %%a %%^%%a%%))")^
     ))^&^
     (set %%y1="")^&(set %%y2="^^^&")^&(set %%y9="^^^!")^&(for %%j in (1,2,9) do (call set "%%y%%j=%%%%y%%j:~-2,1%%"))^&^
     (for /F "tokens=1,*" %%j in ('%%%%y0%%%%%%y6%%') do (set %%j=%%k^>NUL 2^>^&1)^>NUL ^|^| (set "%%a=-1"))^
    )^>NUL 2^>^&1^&^
    (if not defined %%a (set "%%a=-1"))^
   ) else if %%b==e (^
    for /F "tokens=*" %%j in ('%%%%y0%%"^!@wds_wmc_evr^!"') do (set %%j)^&^
    set "%%a=^!%%g^!"^
   ))^&^
   (if 0 LEQ ^^^!%%a^^^! if defined %%h if ^^^!%%a^^^! EQU 0 (set "%%a=1") else (set "%%a=0"))^&^
   set "%%g=^!%%a^!"^&^
   (if ^^^!%%a^^^! EQU -1 (set "%%a=1") else if ^^^!%%a^^^! EQU -2 if ^^^!%%ymcn^^^! EQU 0 (set "%%a=0"))^&^
   (if ^^^!%%ymcn^^^! EQU 1 (echo "%%a=^!%%a^!"))^
  ))^
 )) else if %%x EQU 2 (for /F "tokens=1,2,*" %%a in ('echo.%%wds_evh_aux%%') do (^
  set "wds_ev%%b_mcn=%%b"^&set "wds_ev%%b_aux=%%a %%c"^&set "wds_evh_aux=%%b"^
 )) else set wds_evh_aux=
:: @wds_wmc_evh         - performs events handling.
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_wmc_evr         - reads events file & checks events.
set @wds_wmc_evr=^
 (for %%a in (%%wds_wmc_evh%%) do (set "%%a="))^&(for /F %%y in ('echo wds_evr_') do (^
 set "wds_wmc_rtv="^&set "wds_wmc_hop=1"^&(for %%a in ("1=Error [wait.mds]: ","2=cmd /d /q /v:on /e:on /r ","hop=0","q=""","bk=0","str=""","stl=0") do (set "%%y%%~a"))^&^
 (if exist ^^^!wds_wmc_lpi^^^! (for %%a in ("~r 2:30000","r 1:1") do if ^^^!%%yhop^^^! EQU 0 for /F "tokens=1,2" %%b in ('echo %%~a') do (^
  for /F "tokens=*" %%d in ('%%%%y2%%"^!@obj_attrib^! %%yhop wds_wmc_lpi %%b %%c 3:1"') do (set %%d)^
 )) else (set "%%yhop=1"^&set "wds_wmc_rtv=^!%%y1^!The event file is absent."))^>NUL 2^>^&1^&^
 (if ^^^!%%yhop^^^! EQU 0 (^
  (call set "%%yq=%%%%yq:~1%%")^&^
  (for /F "usebackq eol=; tokens=*" %%a in (^^^!wds_wmc_lpi^^^!) do (^
   set "%%yrow=%%a"^&^
   (if defined %%yrow (^
    set "%%ylen=0"^&^
    (for %%b in (8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (^
     set "%%ytmp=^!%%yrow:~%%b,1^!"^&(if defined %%ytmp (set "%%yrow=^!%%yrow:~%%b^!"^&set /a "%%ylen+=%%b"^>NUL))^
    ))^&^
    set "%%yrow=%%a"^&^
    (for /L %%b in (0,1,^^^!%%ylen^^^!) do (^
     set "%%ysym=^!%%yrow:~%%b,1^!"^&^
     (if ^^^!%%ybk^^^! EQU 0 (^
      if "^!%%ysym^!"=="{" for %%b in ("bk=1","fdn=0","fdv=0","hop=0","id=","et=","ne=","rtv=","i1=","to=","bt=") do (set "%%y%%~b")^
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
       (if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 3 (set "%%ybk=2"))^
      ) else if not "^!%%ysym^!"==" " (^
       (if ^^^!%%yfdn^^^! EQU 2 (set "%%yfdn=1"))^&(if ^^^!%%yfdv^^^! EQU 2 (set "%%yfdv=1"))^
      ))^&^
      (if defined %%ysym (set %%ystr="^!%%ystr:~1,-1^!^!%%ysym^!"^&set /a "%%ystl+=1"^>NUL))^&^
      (if ^^^!%%yfdn^^^! EQU 3 if ^^^!%%yfdv^^^! EQU 3 (^
       set "%%yfdn=0"^&set "%%yfns=^!%%yfns:~1,-1^!"^&set "%%yfdv=0"^&set "%%yfvs=^!%%yfvs:~1,-1^!"^&^
       (if not defined %%yid if "^!%%yfns:id=^!"=="" (set "%%yid=^!%%yfvs^!"))^&^
       (if not defined %%yet if "^!%%yfns:type=^!"=="" (set "%%yet=^!%%yfvs^!"))^&^
       (if not defined %%yi1 if "^!%%yfns:predicate=^!"=="" (set "%%yi1=^!%%yfvs^!"))^&^
       set "%%y4="^&^
       (if not defined %%ybt if "^!%%yfns:begindate=^!"=="" (set "%%y4=1"))^&^
       (if not defined %%yto if "^!%%yfns:timeout=^!"=="" (set "%%y4=2"))^&^
       (if defined %%y4 (^
        (for /F "tokens=* delims=+,-,0" %%c in ('echo.^^^!%%yfvs^^^!') do (^
         (for /F "delims=0123456789" %%d in ('echo.%%c?') do if "%%d"=="?" (^
          set "%%yfvs=%%~c"^
         ) else if defined ^^^!%%yfvs^^^! (^
          for /F "tokens=* delims=+,-,0" %%e in ('"echo.%%^!%%yfvs^!%%"') do (set "%%yfvs=%%~e")^
         ) else (^
          set "%%y4="^&set "%%yhop=-3"^
         ))^&^
         (if ^^^!%%y4^^^! EQU 1 (^
          set "%%ybt=^!%%yfvs^!"^
         ) else (^
          (set /a "%%y4=^!%%yfvs^!"^>NUL 2^>^&1)^>NUL ^&^& (if "^!%%y4^!"=="^!%%yfvs^!" (set "%%yto=^!%%yfvs^!"))^
         ))^
        ))^>NUL 2^>^&1^
       ))^
      ))^&^
      (if ^^^!%%ybk^^^! EQU 2 (^
       set "%%ybk=0"^&^
       set "%%yne=^!%%yet:~0,1^!"^&^
       (if "^!%%yne^!"=="~" (set "%%yet=^!%%yet:~1^!") else (set "%%yne="))^&^
       (if defined %%yet for %%b in (f,a,p,i,c,n,d,v,u,t,h,l,r,w,s,m) do if "^!%%yet:%%b=^!"=="" (^
        (if ^^^!%%yhop^^^! EQU 0 (^
         (for /F "tokens=*" %%c in ('cmd /d /q /r "^!@wds_wmc_evp^! wait.mds %%yhop %%b %%yet %%yi1 %%yi2 %%yi3 %%yi4 '"') do (set %%c))^&^
         (if ^^^!%%yhop^^^! EQU 0 (^
          (for /F "tokens=*" %%c in ('%%%%y2%%"^!@wds_wmc_evh^! %%yhop 1 %%b %%yi1 %%yi2 %%yi3 %%yi4 %%yhop %%yne"') do (set %%c))^
         ))^
        ))^>NUL 2^>^&1^&^
        (if ^^^!%%yhop^^^! EQU 1 (^
         (if defined %%yto (^
          (if defined %%ybt (set "%%y4=^!%%ybt^!") else (set "%%y4=^!wds_wmc_evb^!"))^&^
          (call %%@errorLevel%% 0)^&^
          (for /F "tokens=*" %%d in ('%%%%y2%%"^!@date_span^! 2:^!%%y4^! 5:%%y5 6:%%y7 9:1"') do (set %%d))^&^
          (if ^^^!errorlevel^^^! EQU 0 (^
           (if ^^^!%%y7^^^! EQU 1 (^
            (if ^^^!%%y5^^^! LSS 2147483 (set /a "%%y5*=1000"^&set "%%y6=^!%%yto^!") else (set /a "%%y6=^!%%yto^!/1000"))^&^
            (if ^^^!%%y6^^^! LSS ^^^!%%y5^^^! (set "wds_wmc_hop=0"^&set "%%yrtv=%%b timeout"))^
           ))^
          ) else (set "%%yrtv=%%b bad parameters"))^
         ))^
        ) else if 0 EQU ^^^!%%yhop^^^! (set "wds_wmc_hop=0"^&set "%%yrtv=%%b"^
        ) else if -2 EQU ^^^!%%yhop^^^! (set "%%yrtv=%%b error"^
        ) else if -3 EQU ^^^!%%yhop^^^! (set "%%yrtv=%%b bad parameters"^
        ))^>NUL 2^>^&1^&^
        (if defined %%yrtv (^
         (if defined %%yne (set %%yne="^!%%yid^! ^!%%yne^!^!%%yrtv^!") else (set %%yne="^!%%yid^! ^!%%yrtv^!"))^&^
         (if defined wds_wmc_rtv (set "wds_wmc_rtv=^!wds_wmc_rtv^!,^!%%yne^!") else (set "wds_wmc_rtv=^!%%yne^!"))^
        ))^&^
        (call %%@errorLevel%% 0)^
       ))^
      ))^
     ))^
    ))^
   ))^
  ))^
 ))^&^
 (if exist ^^^!wds_wmc_lpi^^^! for /F "tokens=*" %%a in ('%%%%y2%%"^!@obj_attrib^! %%y3 wds_wmc_lpi ~r 1:1 3:1"') do (echo.))^>NUL 2^>^&1^&^
 echo "wds_wmc_hop=^!wds_wmc_hop^!"^&(if defined wds_wmc_rtv (echo "wds_wmc_rtv=^!wds_wmc_rtv^!"))^
))
:: @wds_wmc_evr         - reads events file & checks events.
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_wmc_eco         - communicative mode: assembles message string & reports it to screen.
::                Remark: depends on predefined %wds_wmc_typ%
set @wds_wmc_eco=^
 (if defined wds_wmc_eco (call echo %%wds_wmc_eco%%))^&^
 (if defined wds_wmc_out (call set "wds_wmc_aux=%%wds_wmc_out%% msec ") else (set "wds_wmc_aux="))^&^
 call set "wds_wmc_aux=%%wds_wmc_aux%%until the "^&^
 (if defined wds_wmc_atr for /F "tokens=1,2" %%a in ('"echo %%wds_wmc_atr:~0,1%% %%wds_wmc_atr:~-1,1%%"') do (^
  if "%%a"=="~" (set "wds_wmc_neg=~"^&set "wds_wmc_atr=%%b")^
 ))^&^
 (for %%a in ("f;file-$-$- be -found-absent","a;object-$-$- have -attribute -","p;process module-$-$- -start-exit","i;process with ID-$-$- - -exit","c;window title-$-$- be -found-absent","n;network device-$-$- be -active-idle","d;disk device-$-$- be -active-idle","v;free space of volume-$-$- -increase-be low","u;use of CPU-$-core $- be -active-idle","t;task-$-$- be -active-idle","h;state of window-$-$- be -`%wds_wmc_a1v%`-not `%wds_wmc_a1v%`","l;state of window '%%wds_wmc_a1v%%' ~-$-$- be -`%wds_wmc_a2v%`-not `%wds_wmc_a2v%`","r;text of console-$-$- be - -not","w;environment variable '%wds_wmc_a1v%' of console-$-$- have - -not","s;screenshot of window-$-$- -freeze-change","m;event of macro-$-$- -happen-not happen","e;event from file-$-$- -happen-not happen") do (^
  (for /F "tokens=1,2 delims=;" %%b in ('echo %%~a') do if "%%b"=="%wds_wmc_typ%" for /F "tokens=1,2,3,4,5,6 delims=-" %%d in ('echo %%~c') do (^
   (call set "wds_wmc_aux=%%wds_wmc_aux%%%%d ")^&^
   (if defined wds_wmc_lpi (^
    (if defined wds_wmc_atr (call set wds_wmc_aux=%%wds_wmc_aux%%"%%wds_wmc_atr%%" of ))^&^
    call set "wds_wmc_aux=%%wds_wmc_aux%%%%f"^&^
    (set wds_wmc_tmp="")^&(for /F "tokens=*" %%j in ('echo %%wds_wmc_tmp:~1%%') do (call set wds_wmc_tmp="%%wds_wmc_lpi:%%j=%%"))^&^
    call set "wds_wmc_aux=%%wds_wmc_aux:~0,-1%%%%wds_wmc_tmp%% "^
   ) else (^
    call set "wds_wmc_aux=%%wds_wmc_aux%%%%e"^&^
    call set "wds_wmc_aux=%%wds_wmc_aux:~0,-1%%"^
   ))^&^
   call set "wds_wmc_aux=%%wds_wmc_aux%%will%%g"^&^
   (if defined wds_wmc_neg (call set "wds_wmc_aux=%%wds_wmc_aux%%%%i") else (call set "wds_wmc_aux=%%wds_wmc_aux%%%%h"))^&^
   (if %%b==a (call set wds_wmc_aux=%%wds_wmc_aux%%"%%wds_wmc_a1v%%"))^&^
   (if %%b==r (call set wds_wmc_aux=%%wds_wmc_aux%%"%%wds_wmc_a1v%%"))^&^
   (if %%b==w (call set wds_wmc_aux=%%wds_wmc_aux%%"%%wds_wmc_a2v%%"))^
  ))^
 ))^&^
 call echo %%time:~0,8%%: Sleep %%wds_wmc_aux%%...
:: @wds_wmc_eco         - communicative mode: assembles message string & reports it to screen.
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @wds_ins_ckr         - checks security settings before library installation, fixes it if necessary.
set @wds_ins_ckr=for /F %%y in ('echo wds_ins_') do if "^!%%ytmp^!"=="%%ytmp" (^
 (if ^^^!wds_wmc_ver^^^! LSS 61 (echo 0^&exit /b 0))^&^
 set "zzz=,ComputerName,SystemDrive,SystemRoot,Path,Temp,@wds_ins_ckr,"^&^
 (for /F "delims==" %%a in ('set') do if "^!zzz:,%%a,=^!"=="^!zzz^!" (set "%%a="))^&^
 set "%%ycmd=cmd /d /q /e:on /v:on /r "^&^
 set "%%ytmp=%%ychk"^&set "%%ynum= 2+ 3- 4_ 5."^&^
 set "%%yrek=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"^&^
 (for /F "tokens=1,2,3,4,5,6,7" %%a in ('echo "ConsentPromptBehaviorAdmin" "EnableInstallerDetection" "EnableLUA" "EnableSecureUIAPaths" "^^^&" "^^^|" "^^^>"') do (^
  set "%%ynam=~2%%~a+023%%~b-034%%~c_045%%~d.05"^&^
  (for /F "skip=1" %%h in ('reg query ^^^!%%yrek^^^! 2%%~g%%~e1') do if "%%h"=="^!%%yrek^!" (^
   (for /F "tokens=1,3" %%i in ('reg query ^^^!%%yrek^^^! /t REG_DWORD %%~f findstr /i /C:%%a /C:%%b /C:%%c /C:%%d') do (^
    set "%%ycrn=%%i"^&set "%%ycrv=%%j"^&^
    (if defined %%ynum for /F "tokens=*" %%k in ('^^^!%%ycmd^^^!"^!@%%yckr^!"') do (set %%k))^
   ))^
  ))^&^
  (if not "^!%%ynam^!"=="~" (^
   set "%%ycrn="^&set "%%ycrv=-1"^&^
   (for /F "tokens=*" %%k in ('^^^!%%ycmd^^^!"^!@%%yckr^!"') do (set %%k))^
  ))^&^
  (if defined %%yrst (^
   (^
    (echo.******************************************************************************)^&^
    (echo The installer modified the following system settings [set value "0"]:)^&^
    (echo Computer Configuration:)^&^
    (echo  Policies\Windows Settings\Security Settings\Local Policies\Security Options:)^&^
    (echo   User Account Control:)^&^
    (for %%k in (^^^!%%yrst^^^!) do (echo   * %%~k))^&^
    (echo.)^&^
    (echo The location in the registry of applied changes is as follows:)^&^
    (echo  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System)^&^
    (echo.)^&^
    (echo In order to apply them, the computer must be restarted ...)^&^
    (echo.)^&^
    (echo.******************************************************************************)^
   )^>con^&^
   (if defined %%yfil (^
    ((echo if defined %%yok shutdown /r /t 30 /f)^&(echo call del /F /A /Q "^!%%yfil^!.bat"))^>^>"^!%%yfil^!.bat"^&^
    (call cscript //nologo "^!%%yfil^!.vbs")^
   ) else (shutdown /r /t 30 /f))^>NUL 2^>^&1^&^
   echo 1^&exit /b 0^
  ))^
 ))^&^
 echo 0^
) else if "^!%%ytmp^!"=="%%ychk" (^
 set "%%ynew=1"^&^
 (for /F "tokens=2,3" %%a in ('echo " " "^^^&"') do for %%c in (^^^!%%ynum^^^!) do (^
  (for /F "tokens=*" %%d in ('^^^!%%ycmd^^^!"for /F %%adelims=%%c tokens=1,2,3,*%%a %%^e in ('%%aecho ^!%%ynam^!%%a') do (echo %%a%%^e%%a^^^&echo %%a%%^f%%a^^^&echo %%a%%^g%%a^^^&echo %%a%%^h%%a)"') do if defined %%ynew (^
   (if defined %%ycrn (^
    if "^!%%ycrn^!"==%%d (^
     set "%%ynam=^!%%ynew^!"^&set "%%yrvn=%%~d"^&set "%%ynew="^&echo "%%ynum=^!%%ynum: %%c=^!"^
    ) else (^
     set "%%ynew=%%~d"^
    )^
   ) else if "^!%%ynew^!"=="1" (set "%%ynew=%%~d") else (set "%%yrvn=%%~d"^&set "%%ynew="))^
  ) else if defined %%yadd (^
   (if defined %%ycrn (echo "%%ynam=^!%%ynam^!%%~d"^&exit /b 0) else (set "%%ynew=1"^&set "%%yadd="))^
  ) else (^
   set "%%yadd=1"^&^
   (if not "^!%%ycrv^!"=="0x%%~d" (^
    (if "%%c"=="2+" (^
     set "%%yaux=Settings item name without prefix 'User Account Control'"^
    ) else if "%%c"=="3-" (^
     set "%%yaux=Behavior of the elevation prompt for adminstrators in Admin Approval Mode"^
    ) else if "%%c"=="4_" (^
     set "%%yaux=Detect application installations and prompt for elevation"^
    ) else if "%%c"=="5." (^
     set "%%yaux=Only elevate UIAccess applications that are installed in secure locations"^
    ) else (^
     set "%%yaux=Added registry value '^!%%yrvn^!'"^
    ))^&^
    (if defined %%yrst (set %%yrst=^^^!%%yrst^^^!,"^!%%yaux^!") else (set %%yrst="^!%%yaux^!"))^&^
    (echo "%%yrst=^!%%yrst^!")^&^
    reg add "^!%%yrek^!" /v "^!%%yrvn^!" /t REG_DWORD /d %%~d /f ^>NUL 2^>^&1 ^|^| (^
     (if not defined %%yfil (^
      set "%%ytmp=%%yfil"^&(for /F "tokens=*" %%e in ('^^^!%%ycmd^^^!"^!@%%yckr^!"') do (set %%e^&echo %%e))^
     ))^&^
     (echo reg add "^!%%yrek^!" /v "^!%%yrvn^!" /t REG_DWORD /d %%~d /f %%~b%%~b set "%%yok=1")^>^>"^!%%yfil^!.bat"^
    )^
   ))^
  ))^
 ))^
) else if "^!%%ytmp^!"=="%%yfil" (for /L %%a in (1,1,4096) do (^
 set "%%yfil=%temp%\wait.mds.auxiliary.file.id"^&^
 (for /L %%b in (1,1,4) do (set "%%yfil=^!%%yfil^!^!random:~0,2^!^!random:~-2,2^!"))^&^
 (if not exist "^!%%yfil^!.vbs" for /F "tokens=1,2" %%b in ('"echo ( )"') do (^
  (^
   (echo Dim uac, fso : Set fso = CreateObject%%b"Scripting.FileSystemObject"%%c)^&^
   (echo fso.DeleteFile "^!%%yfil^!.vbs")^&^
   (echo Set uac = CreateObject%%b"Shell.Application"%%c)^&^
   (echo uac.ShellExecute "^!%%yfil^!.bat", "", "", "runas", 0)^
  )^>"^!%%yfil^!.vbs"^&^
  ((echo @echo off)^&(echo setlocal enabledelayedexpansion))^>"^!%%yfil^!.bat"^&echo "%%yfil=^!%%yfil^!"^&exit /b 0^
 ))^
)) else (^
 set "%%ytmp=%%ytmp"^&(for /F "tokens=*" %%a in ('cmd /d /q /e:on /v:on /r "^!@%%yckr^!"') do (set "%%ytmp=%%a"))^
)^&if "^!%%ytmp^!"=="1" (exit /b 1) else (set "@%%yckr=")
:: @wds_ins_ckr         - checks security settings before library installation, fixes it if necessary.
:: ----------------------------------------------------------------------------

::                      Collapsed strings of macros with common purpose.
:: ----------------------------------------------------------------------------
:: @exist_check         - ....
set wds_exc_job=^
 (for /F "tokens=1,2,3,4" %%a in ('echo wds_exc_dob "^!wds_exc_q^!=" "\.\=\" "\\=\"') do (^
  (call set %%a="%%%%a:%%~b%%")^&set "%%a=^!%%a:%%~c^!"^&set "%%a=^!%%a:%%~d^!"^
 ))^&^
 (for %%a in ("c1o=","mod=0","pth=""") do (set "wds_exc_%%~a"))^&^
 (for /L %%a in (1,1,4) do (set "wds_exc_mc%%a="^&set "wds_exc_fc%%a="))^&^
 (for /L %%a in (1,1,2147483647) do (^
  (for /F "tokens=*" %%b in ('cmd /d /q /e:on /v:on /r "^!@time_span^! B:wds_exc_beg 5:wds_exc_tsp 7:2 9:1"') do (set %%b))^&^
  (if exist ^^^!wds_exc_pth^^^! (^
   set /a "wds_exc_tot+=1"^>NUL^&set "wds_exc_cnt=0"^&set "wds_exc_fnd=0"^&^
   (for /F "tokens=*" %%b in ('"dir /a /b ^!wds_exc_pth^!"') do (set /a "wds_exc_cnt+=1"^>NUL))^&^
   (for /F "tokens=*" %%b in ('"dir /a /b ^!wds_exc_sdo^!"') do (set "wds_exc_fnd=1"))^&^
   (if defined wds_exc_c1o if ^^^!wds_exc_c1o^^^! EQU ^^^!wds_exc_cnt^^^! (set "wds_exc_mod=1") else (set "wds_exc_mod=2"))^&^
   set "wds_exc_mc4=^!wds_exc_mod^!"^&set "wds_exc_c1o=^!wds_exc_cnt^!"^&^
   (for /F "tokens=*" %%b in ('cmd /d /q /v:on /e:on /r "^!@exist^! wds_exc_cnt wds_exc_sdo 2:"1" 5:1"') do (set %%b))^&^
   (if ^^^!wds_exc_cnt^^^! EQU 0 (set /a "wds_exc_fnd+=1"^>NUL))^&^
   set "wds_exc_fc4=^!wds_exc_fnd^!"^&set "wds_exc_chk=1"^&^
   (for %%b in ("2 1","3 2","4 3") do for /F "tokens=1,2" %%c in ('echo %%~b') do (^
    (if defined wds_exc_fc%%c (^
     set "wds_exc_mc%%d=^!wds_exc_mc%%c^!"^&set "wds_exc_fc%%d=^!wds_exc_fc%%c^!"^
    ) else (^
     set "wds_exc_chk=0"^
    ))^
   ))^&^
   (if ^^^!wds_exc_chk^^^! EQU 1 (^
    (if ^^^!wds_exc_tov^^^! LSS ^^^!wds_exc_tsp^^^! (^
     set "wds_exc_chm=6"^&set "wds_exc_chf=6"^
    ) else (^
     set "wds_exc_chm=0"^&set "wds_exc_chf=0"^&^
     (for %%b in ("1 2","1 3","1 4","2 3","2 4","3 4") do for /F "tokens=1,2" %%c in ('echo %%~b') do (^
      (if ^^^!wds_exc_mc%%c^^^! EQU ^^^!wds_exc_mc%%d^^^! (set /a "wds_exc_chm+=1"^>NUL))^&^
      (if ^^^!wds_exc_fc%%c^^^! EQU ^^^!wds_exc_fc%%d^^^! (set /a "wds_exc_chf+=1"^>NUL))^
     ))^
    ))^&^
    (if ^^^!wds_exc_chm^^^! EQU 6 if ^^^!wds_exc_chf^^^! EQU 6 (^
     set /a "wds_exc_fnd=^!wds_exc_mod^!*(^!wds_exc_fnd^!-1)"^>NUL^&^
     echo "wds_exc_rcv=^!wds_exc_fnd^!"^&exit /b 0^
    ))^
   ))^
  ) else (^
   (if ^^^!wds_exc_tov^^^! LSS ^^^!wds_exc_tsp^^^! (echo "wds_exc_rcv=-3"^&exit /b 0))^&^
   (for /F "tokens=*" %%b in ('"call echo.^!wds_exc_dob^!"') do (^
    (set wds_exc_pth="%%~db%%~spb")^&(set wds_exc_fnm="%%~snb%%~sxb")^&^
    (if ^^^!wds_exc_fnm^^^!=="" (^
     (set wds_exc_pth="^!wds_exc_pth:~1,-2^!")^&^
     (for /F "tokens=*" %%c in ('"call echo.^!wds_exc_pth^!"') do (^
      (set wds_exc_pth="%%~dc%%~spc")^&(set wds_exc_fnm="%%~snc%%~sxc")^
     ))^
    ))^
   ))^&^
   (set wds_exc_sdo="^!wds_exc_pth:~1,-1^!^!wds_exc_fnm:~1,-1^!")^
  ))^
 ))
:: @exist_check         - ....
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @runapp_getpid       - expanded "^!wds_rai_is^!" <-> quoted string %%wds_rai_is%%.
set wds_rai_id=^
 set "wds_rai_a=,"^&set "wds_rai_c=,"^&^
 (if ^^^!wds_rai_rs^^^! EQU 1 (^
  (for /F "tokens=*" %%a in ('%%wds_rai_0%%"^!@res_select^! ^!wds_rai_ar^!"') do (set %%a^>NUL 2^>^&1))^&^
  (if defined wds_rai_p for %%a in (^^^!wds_rai_p^^^!) do (set wds_rai_a=^^^!wds_rai_a^^^!%%~a,))^
 ) else (^
  (if ^^^!wds_rai_wc^^^! EQU 0 (set wds_rai_p=IMAGENAM) else (set wds_rai_p=WINDOWTITL))^&^
  (for /F "tokens=2 delims=," %%a in ('^^^!wds_rai_6^^^!/FI "^!wds_rai_p^!E eq ^!wds_rai_f^!"') do ^
   if not "%%~a"=="" (set wds_rai_a=^^^!wds_rai_a^^^!%%~a,)^
  )^>NUL 2^>^&1^
 ))^&^
 (if ^^^!wds_rai_ra^^^! EQU 1 ^
  for /F "tokens=2 delims=," %%a in ('^^^!wds_rai_6^^^!/FI "IMAGENAME eq cmd.exe" /FI "SESSIONNAME eq Console"') do ^
   if not "%%~a"=="" (set wds_rai_c=^^^!wds_rai_c^^^!%%~a,)^
 )^>NUL 2^>^&1^&^
 echo "wds_rai_a^!wds_rai_be^!=^!wds_rai_a: =^!"^&^
 echo "wds_rai_c^!wds_rai_be^!=^!wds_rai_c: =^!"

::                      - expanded "^!wds_rai_id^!" <-> quoted string ^^^!wds_rai_id^^^!.
set wds_rai_is=^
 set "wds_rai_c=0"^&set "wds_rai_n=0"^&set "wds_rai_ct=,"^&^
 (for /L %%a in (1,1,9999) do (^
  (for /F "tokens=*" %%b in ('%%wds_rai_0%%^^^!wds_rai_id^^^!') do (set %%b))^&^
  (for %%b in (wds_rai_a,wds_rai_c) do if not "^!%%bb^!"=="," if not "^!%%be^!"=="," (^
   set "wds_rai_p=^!%%bb:~1,-1^!"^&^
   (for %%c in (^^^!wds_rai_p^^^!) do (set "%%be=^!%%be:,%%c,=,^!"))^
  ))^&^
  (if not "^!wds_rai_ce^!"=="," (^
   (if 1 LSS %%a if not "^!wds_rai_ae^!"=="," (set "wds_rai_cb=^!wds_rai_ce^!"))^&^
   set "wds_rai_p=^!wds_rai_ct:~1,-1^!"^&^
   (if defined wds_rai_p for %%b in (^^^!wds_rai_p^^^!) do (^
    (if "^!wds_rai_ce:,%%b,=^!"=="^!wds_rai_ce^!" (^
     set "wds_rai_ct=^!wds_rai_ct:,%%b,=,^!"^&^
     set /a "wds_rai_n-=1"^>NUL^
    ))^
   ))^&^
   set "wds_rai_p=^!wds_rai_ce:~1,-1^!"^&^
   (for %%b in (^^^!wds_rai_p^^^!) do if ^^^!wds_rai_n^^^! LSS 1000 (^
    (if "^!wds_rai_ct:,%%b,=^!"=="^!wds_rai_ct^!" (^
     set "wds_rai_ct=^!wds_rai_ct^!%%b,"^&^
     set /a "wds_rai_n+=1"^>NUL^&^
     (if 0 LSS ^^^!wds_rai_c^^^! (set "wds_rai_ce=^!wds_rai_ce:,%%b,=,^!"))^
    ))^
   ))^&^
   (if 1000 LEQ ^^^!wds_rai_n^^^! (set "wds_rai_ct=,"^&set "wds_rai_n=0") else (^
    (if 1 LSS %%a if not "^!wds_rai_ae^!"=="," if not "^!wds_rai_ce^!"=="," (^
     set "wds_rai_p=^!wds_rai_ce:~1,-1^!"^&^
     (for %%b in (^^^!wds_rai_p^^^!) do (set "wds_rai_cb=^!wds_rai_cb:,%%b,=,^!"))^
    ))^
   ))^
  ))^&^
  (if not "^!wds_rai_ae^!"=="," (^
   (if "^!wds_rai_ce^!"=="," (set "wds_rai_c="^
   ) else if 2 LSS ^^^!wds_rai_c^^^! (set "wds_rai_c="^ 3
   ) else (set /a "wds_rai_c+=1"^>NUL))^
  ))^&^
  (if defined wds_rai_c (^
   (for /F "tokens=*" %%b in ('%%wds_rai_0%%"^!@time_span^! B:wds_rai_bg 5:wds_rai_ts 7:2 9:1"') do (set %%b))^&^
   (if ^^^!wds_rai_to^^^! LSS ^^^!wds_rai_ts^^^! (set "wds_rai_c="))^
  ))^&^
  (if not defined wds_rai_c (^
   (for %%b in (wds_rai_ae,wds_rai_ce) do if "^!%%b^!"=="," (echo "%%b=") else (echo "%%b=^!%%b:~1,-1^!"))^&^
   exit /b 0^
  ))^
 ))

:: Precaution           - expanded "^!wds_rai_wt^!" <-> quoted string ^^^!wds_rai_wt^^^!, `&` as %%wds_rai_V%%.
set wds_rai_wt=^
 set wds_rai_a=0^&set wds_rai_ab=,^&set wds_rai_cb=,^&^
 (for /L %%a in (1,1,9999) do (^
  (for %%b in (^^^!wds_rai_5^^^!) do (^
   (if defined %%be for %%c in (^^^!%%be^^^!) do (^
    set %%b=1^&^
    (for /F "tokens=2 delims=," %%d in ('"call ^!wds_rai_6^!^!wds_rai_b:~-2,1^! findstr /C:%%c"') do if "%%c"=="%%~d" (^
     set wds_rai_p=%%c^&^
     (for /F "tokens=*" %%e in ('%%wds_rai_0%%"^!@title^! wds_rai_4 1:wds_rai_p 3:wds_rai_p 4:1"') do (set %%e))^&^
     (if ^^^!wds_rai_p^^^! EQU 0 if "^!wds_rai_4:@runapp=^!"=="^!wds_rai_4^!" (^
      if "%%b"=="wds_rai_a" (set %%b=2) else (set wds_rai_p=1)^
     ) else (^
      if "%%b"=="wds_rai_a" (set wds_rai_p=1) else (set %%b=2)^
     ))^&^
     (if ^^^!wds_rai_p^^^! EQU 0 (^
      set %%bb=^!%%bb^!%%c,^&(if %%b==wds_rai_a if defined wds_rai_atn (echo "wds_rai_atv=^!wds_rai_4^!"))^
     ))^
    ))^
   ))^
  ))^&^
  (if ^^^!wds_rai_a^^^! LSS 2 (^
   (for /F "tokens=*" %%b in ('%%wds_rai_0%%"^!@time_span^! B:wds_rai_bg 5:wds_rai_ts 7:2 9:1"') do (set %%b))^&^
   (if ^^^!wds_rai_to^^^! LSS ^^^!wds_rai_ts^^^! (set wds_rai_a=2))^
  ))^&^
  (if ^^^!wds_rai_a^^^! EQU 2 (^
   (for %%b in (^^^!wds_rai_5^^^!) do if "^!%%bb^!"=="," (echo "%%bb=") else (echo "%%bb=^!%%bb:~1,-1^!"))^&^
   exit /b 0^
  ))^
 ))
:: @runapp_getpid       - ....
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @web_avail           - ....
set "wds_iav_b=,Path,TEMP,SystemRoot,UserProfile,"
(for /F "delims==" %%a in ('set') do if "!wds_iav_b:,%%a,=!"=="!wds_iav_b!" (set "%%a="))
(for /F "tokens=* delims=0" %%a in ('"echo !time::0=:!"') do for /F "tokens=1,2,3 delims=:,." %%b in ('echo %%a') do (
 set "wds_iav_h=%%b"&set /a "wds_iav_b=3600*%%b+60*%%c+%%d">NUL 2>&1
))
(for /L %%z in (1,1,75) do (
 (for /F "tokens=*" %%a in ('ping www.google.com -n 1 -w 25') do if not "%%~a"=="" (
  for /F "tokens=2,4,6 delims=,=(" %%b in ('"echo.%%~a"') do if not "%%~b"=="" (
   for /F "tokens=1,2,3" %%e in ('echo.%%~b %%~c %%~d') do (
    if "%%~e%%~f%%~g"=="110" (echo 0&exit /b 0)
   )
  )
 ))
 (for /F "tokens=* delims=0" %%a in ('"echo !time::0=:!"') do for /F "tokens=1,2,3 delims=:,." %%b in ('echo %%a') do if %%b LSS !wds_iav_h! (
  set /a "wds_iav_e=3600*(24+%%b)+60*%%c+%%d-20">NUL 2>&1
 ) else (
  set /a "wds_iav_e=3600*%%b+60*%%c+%%d-20">NUL 2>&1
 ))
 (if !wds_iav_b! LEQ !wds_iav_e! (echo 1&exit /b 0))
))
:: @web_avail           - ....
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: @fixedpath           - uses `%` as substitution symbol for `%%` inside quoted strings for internal calls

:: @fixedpath.wds_fpn_rj - cleanup of path format inside search string (inside @fixedpath_parser):
wds_fpn_rj=call cmd /d /q /r "
 (for /F "tokens=*" %%a in ('echo.%%wds_fpn_rf%%') do (
  set wds_fpn_f=%%a
 ))^&^
 (for /F "tokens=1,* delims=\" %%a in ('"echo.%%wds_fpn_f:~1,-1%%"') do (
  set "wds_fpn_0=%%a"^&^
  call set "wds_fpn_0=%%wds_fpn_0:~1%%"^&^
  (if defined wds_fpn_0 for /F "delims=*" %%c in ('echo.%%wds_fpn_0%%') do if not "%%c"==":" (
   set "wds_fpn_0="
  ))^&^
  (if not defined wds_fpn_0 for /F "tokens=*" %%c in ('echo.%%~dp0') do if "%%a"==".." (
    set "wds_fpn_r=%%~sdpc"^&^
    (for /L %%d in (1,1,2048) do (
      (for /F "tokens=1,* delims=\" %%e in ('"echo.%%wds_fpn_f:~1,-1%%"') do if "%%e"==".." (
        (set wds_fpn_f="%%f")^&^
        (for /F "tokens=*" %%g in ('echo."%%wds_fpn_r%%..\"') do (set "wds_fpn_r=%%~sdpg"))
      ) else (
        call echo wds_fpn_rf="%%wds_fpn_r%%%%e\%%f"^&^
        exit /b 0
       ))
     ))
  ) else (echo wds_fpn_rf="%%~sdpc%%a\%%b"))
 ))
"
:: @fixedpath           - ....
:: ----------------------------------------------------------------------------

::  ----------------------------------------------- /\ /\ /\ /\ /\ /\ /\ ------------------------------------------------
::  SECTION OF CODE THAT CAN NOT BE USED INDEPENDENTLY - it contains only the source code in a form suitable for editing.
::  ---------------------------------------------------------------------------------------------------------------------
