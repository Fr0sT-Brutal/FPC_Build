:: Batch file to build FPC & Lazarus from sources.
::   %1 - (opt) FPC|Laz - build target. If omitted, both will be built
::   %1 - (opt) CPU target. i386 if omitted. If not empty, cross-compilation will be launched
::   %3 - (opt) OS target. win32 if omitted. If not empty, cross-compilation will be launched

@ECHO OFF

SETLOCAL

SET Base=%~dp0%
SET FPC_Opt=OPT=""
SET Laz_Opt=OPT="-O2 -g- -Xs"
:: SET Make_Opt=--quiet
SET FPCMin=%Base%\fpc-min\bin\i386-win32
SET FPCPath=%Base%\FPC
SET LazPath=%Base%\Lazarus

:: Use binaries from this path only
:: ! FPC makefile uses heuristic to determine OS so it needs ; in PATH for Windows
SET Path=%FPCMin%;blah

:: check for binary
CALL fpc.exe -iV 1>NUL 2>&1 || (ECHO No compiler fpc.exe found && GOTO :Err)

:: Check parameters
IF NOT .%1.==.. (
	IF .%1.==.FPC. SET DoFPC=1
	IF .%1.==.Laz. SET DoLaz=1
) ELSE (
	SET DoFPC=1
	SET DoLaz=1
)

IF NOT .%2.==.. (
	IF .%3.==.. (ECHO Must be defined both CPU and OS targets! && GOTO :Err)
	SET Cross=1
	SET TargCPU=%2
	SET TargOS=%3
) ELSE (
	SET Cross=
	SET TargCPU=i386
	SET TargOS=win32
)

:: Action
IF DEFINED DoFPC CALL :BuildFPC || GOTO :Err
IF DEFINED DoLaz CALL :BuildLaz || GOTO :Err
GOTO :EOF

:: ~~~ Build FPC ~~~
:: Uses externals: Make_Opt, FPCPath, TargCPU, TargOS, FPC_Opt, Cross
:BuildFPC
	ECHO Making FPC for %TargCPU% %TargOS%

	PUSHD "%FPCPath%"
	SETLOCAL

	:: Copy some platform binaries to the new FPC - they could be required by build process
	CALL "%SystemRoot%\System32\xcopy.exe" /S /Y "%Base%\fpc-min\bin\%TargCPU%-%TargOS%" "bin\%TargCPU%-%TargOS%\" 2>NUL 1>&2
	:: ! cross-compilation for x86_64-linux requires as.exe but has x86_64-linux-*.exe
	COPY "bin\%TargCPU%-%TargOS%\%TargCPU%-%TargOS%-as.exe" "bin\%TargCPU%-%TargOS%\as.exe" 2>NUL 1>&2

	IF NOT DEFINED Cross (
		CALL make %Make_Opt% clean || (ECHO Command "make clean" for FPC failed... && GOTO :BuildFPCErr)
		rem ! make clean won't delete installed units
		RD /Q /S "units\%TargCPU%-%TargOS%" 2> nul
		CALL make %Make_Opt% all %FPC_Opt% || (ECHO Command "make all" for FPC failed... && GOTO :BuildFPCErr)
		CALL make %Make_Opt% install INSTALL_PREFIX="%FPCPath%" || (ECHO Command "install" for FPC failed... && GOTO :BuildFPCErr)
	) ELSE (
		CALL make %Make_Opt% clean CPU_TARGET=%TargCPU% OS_TARGET=%TargOS% || (ECHO Command "make clean" for FPC failed... && GOTO :BuildFPCErr)
		rem ! make clean won't delete installed units
		RD /Q /S "units\%TargCPU%-%TargOS%" 2> nul
		rem Linux cross-compilation requires additional bin tools
		rem SET Path=%Path%;%Base%\fpc-min\bin\%TargCPU%-%TargOS%
		CALL make %Make_Opt% crossinstall %FPC_Opt% CPU_TARGET=%TargCPU% OS_TARGET=%TargOS% INSTALL_PREFIX="%FPCPath%" || (ECHO Command "make crossinstall" failed... && GOTO :BuildFPCErr)
	)

	SET NewFPC=%FPCPath%\bin\%TargCPU%-%TargOS%
	:: Generate config (for base compiler only)
	IF NOT DEFINED Cross (
		CALL "%NewFPC%\fpcmkcfg.exe" -d basepath="%FPCPath%" -o "%NewFPC%\fpc.cfg" || (ECHO Generating config failed... && GOTO :BuildFPCErr)
	)

	POPD
	:: copy might be setting error code to non-0, ignore
	EXIT /B 0

	:BuildFPCErr
	POPD
	EXIT /B 1

:: ~~~ Build Lazarus ~~~
:: Uses externals: Make_Opt, FPCPath, LazPath, TargCPU, TargOS, LazOpt
:BuildLaz
	ECHO Making Lazarus for %TargCPU% %TargOS%

	SETLOCAL
	SET Path=%FPCPath%\bin\i386-win32;%FPCMin%;blah

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