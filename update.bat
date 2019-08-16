:: Batch file to create and update FPC & Lazarus repositories.

@ECHO OFF

SETLOCAL

SET Base=%~dp0%
SET FPGit=https://github.com/graemeg/freepascal.git
SET LazGit=https://github.com/graemeg/lazarus.git
SET FPCPath=%Base%\FPC
SET LazPath=%Base%\Lazarus

:: ~~~ Create or update repos ~~~

:: check for git binary
CALL git.exe --version 1>nul 2>&1 || (ECHO Git binary not found && GOTO :Err)

:: FPC

IF NOT EXIST "%FPCPath%\.git" (
	ECHO FreePascal repo not found - will create and update it
	CALL git.exe clone %FPGit% "%FPCPath%" || (ECHO Creation of Git repo failed... && rd /Q/S "%FPCPath%\.git" && GOTO :Err)
) ELSE (
	ECHO Updating FPC
	PUSHD "%FPCPath%"
	CALL git.exe pull || (POPD && ECHO Error updating FPC repo && GOTO :Err)
	POPD
)

:: Lazarus

IF NOT EXIST "%LazPath%\.git" (
	ECHO Lazarus repo not found - will create and update it
	CALL git.exe clone %LazGit% "%LazPath%" || (ECHO Creation of Git repo failed... & rd /Q/S "%LazPath%\.git" & GOTO :Err)
) ELSE (
	ECHO Updating Lazarus
	PUSHD "%LazPath%"
	CALL git.exe pull || (POPD && ECHO Error updating Lazarus repo && GOTO :Err)
	POPD
)

timeout /t 5
GOTO :EOF

:Err
PAUSE
"%ComSpec%" /C EXIT 1