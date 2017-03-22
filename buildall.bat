@ECHO OFF

SETLOCAL

call build.bat FPC || GOTO :Err
call build.bat FPC x86_64 win64 || GOTO :Err
call build.bat FPC i386 linux || GOTO :Err
call build.bat FPC x86_64 linux || GOTO :Err

call build.bat Laz || GOTO :Err

timeout /t 5
GOTO :EOF

:Err
PAUSE
"%ComSpec%" /C EXIT 1