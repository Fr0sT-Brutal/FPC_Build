:: Batch file to build FPC & Lazarus from sources.
::   %1 - (opt) FPC|Laz
::   %1 - (opt) CPU target
::   %2 - (opt) OS target

@ECHO OFF

SETLOCAL

SET Base=%~dp0%
SET FPC_Opt=FPCOPT=""
SET Laz_Opt=FPCOPT="-O2 -g- -Xs"
SET Make_Opt=--quiet
SET FPCMin=%Base%\fpc-min\bin\i386-win32
SET FPCPath=%Base%\FPC
SET LazPath=%Base%\Lazarus

:: Use binaries from this path only
:: ! FPC makefile uses heuristic to determine OS so it needs ; in PATH for Windows
SET Path=%FPCMin%;blah

:: check for binary
CALL fpc.exe -iV 1>NUL 2>&1 || (ECHO No compiler fpc.exe found && GOTO :BuildErr)

:: Check parameters
IF NOT .%1.==.. (
	IF .%1.==.FPC. SET DoFPC=1
	IF .%1.==.Laz. SET DoLaz=1
) ELSE (
	SET DoFPC=1
	SET DoLaz=1
)

IF NOT .%2.==.. (
	IF .%3.==.. (ECHO Must be defined both CPU and OS targets! && GOTO :BuildErr)
	SET Cross=1
	SET TargCPU=%2
	SET TargOS=%3
) ELSE (
	SET TargCPU=i386
	SET TargOS=win32
)

:: Action
IF DEFINED DoFPC CALL :BuildFPC || GOTO :Err
IF DEFINED DoLaz CALL :BuildLaz || GOTO :Err
GOTO :EOF

:: ~~~ Build FPC ~~~
:: Uses externals: FPCMin, Make_Opt, FPCPath, TargCPU, TargOS, FPCOpt, Cross
:BuildFPC
	ECHO Making FPC for %TargCPU% %TargOS%

	PUSHD "%FPCPath%"
	SETLOCAL
	
	CALL make %Make_Opt% clean distclean || (ECHO Command "make clean" failed... && GOTO :BuildFPCErr)
	IF NOT DEFINED Cross (
		CALL make %Make_Opt% all %FPC_Opt% && make %Make_Opt% install INSTALL_PREFIX="%FPCPath%" || (ECHO Command "make all" for FPC failed... && GOTO :BuildFPCErr)
	) ELSE (
		rem Linux cross-compilation requires additional bin tools
		SET Path=%Path%;%Base%\fpc-min\bin\%TargCPU%-%TargOS%
		CALL make %Make_Opt% crossinstall %FPC_Opt% CPU_TARGET=%TargCPU% OS_TARGET=%TargOS% INSTALL_PREFIX="%FPCPath%" || (ECHO Command "make crossinstall" failed... && GOTO :BuildFPCErr)
	)

	SET NewFPC=%FPCPath%\bin\i386-win32
	:: Generate config (for base compiler only)
	IF NOT DEFINED Cross (
		CALL "%NewFPC%\fpcmkcfg.exe" -d basepath="%FPCPath%" -o "%NewFPC%\fpc.cfg" || (ECHO Generating config failed... && GOTO :BuildFPCErr)
	)

	:: Copy missing files to base dir of new FPC
	CALL "%SystemRoot%\System32\xcopy.exe" /D "%Base%\fpc-min\bin\*.*" "%NewFPC%\" 2>NUL 1>&2

	POPD
	:: xcopy might be setting error code to non-0, ignore
	EXIT /B 0

	:BuildFPCErr
	POPD
	EXIT /B 1

:: ~~~ Build Lazarus ~~~
:: Uses externals: Make_Opt, FPCPath, LazPath, TargCPU, TargOS, LazOpt
:BuildLaz
	ECHO Making Lazarus for %TargCPU% %TargOS%

	SETLOCAL
	SET Path=%FPCPath%;%FPCPath%\bin\i386-win32;blah

	PUSHD "%LazPath%"
	CALL make %Make_Opt% clean || (ECHO Command "make clean" failed... && GOTO :BuildLazErr)
	CALL make %Make_Opt% all %Laz_Opt% || (ECHO Command "make all" for Lazarus failed... && GOTO :BuildLazErr)
	POPD
	
	GOTO :EOF

	:BuildLazErr
	POPD
	EXIT /B 1

:Err
POPD
%ComSpec% /C EXIT 1