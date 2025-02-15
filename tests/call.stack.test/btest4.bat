@echo off&setlocal
 for /L %%a in (1,1,2147483647) do (
    ping -n 1 -w 500 192.168.254.254 >NUL 2>&1
 )

