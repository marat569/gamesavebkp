:: Modular Version by Marat#0001 [discord] (credits of old authors can be found at the bottom of the file)

:: I found this script that was modified by multiple people, and made it modular -- so it works with any game

:: Setup is easy, create a new windows task that runs this bat file as admin and invisible

:: Edit the variables under "change this as needed" ONLY

:: Brief explination of variables

:: PATH is the location of the folder that will be zipped up/backed up

:: BACKUPPATH is the location of wherre the zip files will be stored

:: PREFIX is what the files will start with, a prefix of WL will have files named WL_Save_04-27-2023_17-21-39.rar

:: DYNAMICFILE is the file we check the hash of to see if it changed, if there was a change the script will create a new backup.

:: A good file to pick is the games actual save's file, what the game writes to; in Wo Long's example it would be SAVEDATA.BIN

:: WinRAR or 7zip is required for the script to work. The script assumes the install directory is the default one

:: If for some reason the install directory is different, change SZIPPATH or WRARPATH

:: 

:: Details related to other authors can be found on the bottom of the file
 


@echo off
SETLOCAL EnableDelayedExpansion
::================================CHANGE THESE AS NEEDED=====================================

::Universal Variables

::Location of the saves -- FOLDER THAT GETS BACKED UP
set PATH=C:\Users\desktop\Documents\KoeiTecmo\Wolong

::Location to save the backups to
set BACKUPPATH=T:\Save Bkp\Wo Long Save Backup

::What you want to name your files
set PREFIX=WL

::File we check for changes - sub-directory of PATH
set DYNAMICFILE=Savedata\33219362\SAVEDATA00\SAVEDATA.BIN








:: ====================================== DO NOT CHANGE ANYTHING BELOW =================================

::Log path
set LOGPATH=%BACKUPPATH%

::
set /a CHK=1
:: 
::
set /a TIMER=0
::
set DATEFORMAT=US

::If you are not using default path for 7zip or WinRar you can change them here
::It is ok to not have either, then standard zip format will be used if thats the case
::Reasons to use 7zip - Better compression, free (WILL BE PREFERRED OVER WINRAR IF INSTALLED)
::Reasons to use WinRar - Has 5% baked in recovery in case recovery is needed
set SZIPPATH=C:\Program Files\7-Zip
set WRARPATH=C:\Program Files\WinRAR



::
if %DATEFORMAT% == US goto DATEVALID
if %DATEFORMAT% == EU goto DATEVALID
if %DATEFORMAT% == YMD goto DATEVALID
cls
color 0C
echo Invalid date format %DATEFORMAT%
echo Must be either US, EU or YMD
echo.
pause
goto END
:DATEVALID
if %DATEFORMAT% == US set DF=MM-dd-yyyy_HH-mm-ss
if %DATEFORMAT% == EU set DF=dd-MM-yyyy_HH-mm-ss
if %DATEFORMAT% == YMD set DF=yyyy-MM-dd_HH-mm-ss
set /a USESZIP=0
set /a USEWRAR=0
if exist "%SZIPPATH%" (set /a USESZIP=1)
if %USESZIP% EQU 1 goto SKIPWINRAR
if exist "%WRARPATH%" (set /a USEWRAR=1)
:SKIPWINRAR
if %TIMER% == 0 goto SKIPTIMER

set /p CLK="How often do you want to backup (enter minutes): "
set /a SECS=%CLK%*60 
:SKIPTIMER
if %USESZIP% == 0 goto CHECKWRAR
if exist "%SZIPPATH%\7z.exe" (set SZIPPATH=%SZIPPATH%\7z.exe) else (set SZIPPATH=%SZIPPATH%\7za.exe)
if exist "%SZIPPATH%" (color 0A & echo Found 7zip & goto CHECKPATH)
cls
color 0E
echo WARNING! 
echo Cannot find 7-zip in %SZIPPATH%
echo Download it from https://www.7-zip.org/download.html
echo.
echo Checking for WinRar

:CHECKWRAR
if exist "%WRARPATH%\rar.exe" (set /a USEWRAR=1 & set /a USESZIP=0 & echo Found WinRar & color 0D) else (color 0F
	echo Could not find 7zip or Winrar
	echo Falling back to standard zip
	set /a USESZIP=0
	set /a USEWRAR=0)

:CHECKPATH
if exist "%PATH%" goto CHECKBACKUPPATH
cls
echo ERROR!
echo Cannot find %PATH% 
pause
goto END

:CHECKBACKUPPATH
if exist "%BACKUPPATH%" goto RUN
mkdir "%BACKUPPATH%"
if exist "%BACKUPPATH%" goto RUN
cls
echo ERROR!
echo Cannot create %BACKUPPATH%
echo To store backups in
echo Need Admin rights?
pause
goto END

:RUN
title Modular Save Backup - 2023
if not exist "%SystemRoot%\system32\WindowsPowerShell\v1.0\PowerShell.exe" (set /a PWRSH=0) else (set /a PWRSH=1)
if not exist "%BACKUPPATH%\%PREFIX%_last_cksum.txt" goto BACKUP
if %CHK% == 0 goto BACKUP

"%SystemRoot%\system32\CertUtil" -hashfile "%PATH%\%DYNAMICFILE%" MD5 > "%BACKUPPATH%\%PREFIX%_curr_cksum.txt"
	
for /f "tokens=1*delims=:" %%G in ('%SystemRoot%\system32\findstr /n "^" "%BACKUPPATH%\%PREFIX%_last_cksum.txt"') do if %%G equ 2 ( 
	set PREV=%%H)
	set PREV=%PREV: =%
	echo Previous: %PREV%
	
for /f "tokens=1*delims=:" %%G in ('%SystemRoot%\system32\findstr /n "^" "%BACKUPPATH%\%PREFIX%_curr_cksum.txt"') do if %%G equ 2 ( 
	set CURR=%%H)
	set CURR=%CURR: =%
	echo Current:  %CURR%

if "%PREV%" == "%CURR%" (
	echo Checksums match. New backup not needed.
	echo %date% %time% - Backup requested, file is same as last time. NOT backing up. >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	echo If you would like to backup either way, please set CHK=0 in the file. >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	echo Previous: %PREV% >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	echo Current:  %CURR% >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	echo. >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	goto TIMERCHECK
)

:BACKUP
if %CHK% == 1 "%SystemRoot%\system32\CertUtil" -hashfile "%PATH%\%DYNAMICFILE%" MD5 > "%BACKUPPATH%\%PREFIX%_last_cksum.txt"

if %PWRSH% == 1 (for /f %%d in ('%SystemRoot%\system32\WindowsPowerShell\v1.0\PowerShell.exe get-date -format "{%DF%}"') do set FILENAME=%PREFIX%_Save_%%d) else (goto ALTDATE) 

goto SKIPALTDATE
:ALTDATE
if 20 NEQ %date:~0,2% (set d=%date:~4,10%) else (set d=%date%)
if / == %date:~2,1% (set d=%date%)
if - == %date:~2,1% (set d=%date%)
set tm=%time:~0,8%
set d=%d:/=-% & set tm=%tm::=-% 
set tm=%tm:.=-% 
set FILENAME=%PREFIX%_Save_%d%_%tm%
set FILENAME=%FILENAME: =% 
:SKIPALTDATE
if %USESZIP% == 1 ("%SZIPPATH%" a -y "%BACKUPPATH%\%FILENAME%" "%PATH%")
if %USESZIP% == 1 goto NEXT
if %USEWRAR% == 1 ("%WRARPATH%\rar.exe" a -y -ep1 -rr5 "%BACKUPPATH%\%FILENAME%" "%PATH%") 
if %USEWRAR% == 1 goto NEXT
"%SystemRoot%\system32\WindowsPowerShell\v1.0\PowerShell.exe" Compress-Archive -LiteralPath "'%PATH%'" -DestinationPath "'%BACKUPPATH%\%FILENAME%.zip'" -Force
:NEXT
if not exist "%BACKUPPATH%\%PREFIX%_curr_cksum.txt" set CURR="N/A - First backup or CHK=0"
if exist "%BACKUPPATH%\%FILENAME%.*" (
	echo Saved %FILENAME% MD5: %CURR%
	echo Saved %FILENAME% MD5: %CURR% >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	echo. >> "%LOGPATH%\%PREFIX%_saves_log.txt"
	) else (echo ERROR - CANT CREATE BACKUP "%FILENAME%" >> "%LOGPATH%\%PREFIX%_saves_log.txt")
:TIMERCHECK
if %TIMER% == 1 ( 
	"%SystemRoot%\system32\TIMEOUT" /T %SECS% /NOBREAK
	goto RUN)

:END


:: So many people went through this, I have no idea who the original author is, if they plan on maintaining it, or care about it
:: I got the file from a discord friend who re-wrote some parts for Monster Hunter Rise, and then I re-wrote that
:: Below are names I've found, and keeping out of repect
:: Based on a very old script by  /u/Chrushev [reddit]
:: WRITEN BY DUXA 8/14/2018 [another very old credit]
