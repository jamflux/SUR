::DISCLAIMER: this tool can be used for free, the credits to JamFlux and other authors must be visible where the ROM has been published
@echo off
mode con: cols=78 lines=14
cls
setlocal enabledelayedexpansion
set app_name=Simple Unpack and Repack - Android Tool
set app_description=Extract and Repack system formats for android 5-10
title %app_name% [v2.0] [64bits] %authors%
set authors=[by JamFlux]
set cecho=bins\cecho.exe
set busybox=bins\busybox.exe
mode con: cols=78 lines=14


:dragNdrop
if exist *.txt del *.txt > nul
echo ----------------------------------------------->> log.txt
echo -----  S.U.R. Tool %authors% started  ----- >> log.txt
echo -----            %time%             ----- >> log.txt
echo ----------------------------------------------->> log.txt
if (%1)==() goto start0
if (%~x1)==(.xz) (
echo ---- XZ compression detected: >> log.txt
echo      Extracting %~nx1 >> log.txt
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}XZ compression{#} detected, unpacking:
echo.
%cecho%  	-{0a}%~n1%{#}
echo.
echo.
echo.
bins\7z x "%~nx1" >nul
)
for %%a in ("*.img") do set sys_image="%%a"
ren %sys_image% system.img >nul
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting{#} system image:
echo.
%cecho%  	-{0a}%sys_image%{#}
echo.
echo.
echo.
call :make_dirs
echo ---- imgextractor.exe:  %time% -Unpacking system.img >> log.txt
bins\imgextractor.exe "system.img" >> log.txt
if exist system move /y system 01-Project\ >nul 2>nul
if exist system_fs_config move /y system_fs_config 01-Project\1-Sources\fs_config >nul 2>nul
if exist system_file_contexts move /y system_file_contexts 01-Project\1-Sources\file_contexts >nul 2>nul
if exist system_size.txt move /y system_size.txt 01-Project\1-Sources\sys_size.txt >nul 2>nul
if exist system.raw.img !busybox! rm -rf system.raw.img >nul
if exist system.img move /y system.img 01-Project\1-Sources\ >nul 2>nul
set /p size=<"01-Project\1-Sources\sys_size.txt"
if exist 01-Project\1-Sources\system.img echo system.img format found >> 01-Project\temp\system.img.txt
if exist 01-Project\system\system\build.prop echo SAR: System As Root ROM >> 01-Project\temp\SAR
if exist 01-Project\temp\SAR if exist 01-Project\system\system\vendor\bin\hw (
!busybox! rm -rf 01-Project\temp\SAR >nul
call :fc_finder
)
if exist 01-Project\temp\SAR call :fs_generator
if exist 01-Project\1-Sources\system.img !busybox! rm -rf 01-Project\1-Sources\system.img >nul 2>nul
goto ROMs_menu

:start0
mode con: cols=45 lines=3
REM .bat con permisos de administrador - Admin privileges
:-------------------------------------
REM  --> Analizando los permisos
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls" "%SYSTEMROOT%\system32\config\system"
)
 
REM --> Si hay error es que no hay permisos de administrador.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
 
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
 
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
 
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

::New script
mode con: cols=78 lines=14

:files_checker
if not exist "bins\file.list" (
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-Can't continue, {04}[files.txt]{#} is missing
echo.
echo.
%cecho%  	-Please, {0a}reinstall{#} this tool.
echo.
echo.
echo.
pause>nul
exit
)
set verificando=null
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{04}Error found:{#} 
echo.
echo.
for /f "delims=" %%a in ('type bins\file.list') do if not exist "%%a" (
	set verificando=y
	%cecho%  	-Can't continue, {04}[%%~na%%~xa]{#} is missing
	echo.
	)
if "!verificando!"=="y" (
	echo.
	%cecho%  	-Please, {0a}reinstall{#} this tool.
	echo.
	pause>nul
	exit
)

:description
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
echo.
echo.
%cecho%  	 {4f}%app_description%{#}
echo.
echo.
echo.
timeout /t 3 /nobreak > nul

:check_1
set system=01-Project\system\system
if exist 01-Project\system\build.prop set system=01-Project\system
if exist %system%\build.prop echo ---- Exists a previous ROM: >> log.txt
if exist %system%\build.prop (goto found_project) else (goto start)


:found_project
call :get_ROMs_name
call :get_ROMs_name
echo      %rname% >> log.txt
call :detect_vendor
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-ROM detected, named: {0b}!rname!{#}
echo.
echo.
echo  	-Please, decide:
echo.
echo  	1. Work on it		2. New project
echo.
set /p number=*       Select an option: 
if "%number%"=="1" goto ROMs_menu
if "%number%"=="2" goto start
if not "%number%"=="1" if not "%number%"=="2" goto found_project


:start
if exist %rname% echo      %rname% [Skipped] >> log.txt
set STARTTIME=%TIME%
echo ---- New project started: %time% >> log.txt
if exist 01-Project rmdir /q /s 01-Project
if exist 02-Output rmdir /q /s 02-Output
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-Please, {0a}select{#} a ROMs .zip file
echo.
echo.
echo.
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta %dialog%') do set "file=%%p"
echo ---- The selected ROM's zip file is: >> log.txt
echo      %file% >> log.txt
call :make_dirs
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting{#} ROMs files...
echo.
echo.
echo.
echo ---- Extracting ROMs files: >> log.txt
::--->commands
bins\7z x "%file%" -o01-Project\1-Sources install >nul
bins\7z x "%file%" -o01-Project\1-Sources config >nul
bins\7z x "%file%" -o01-Project\1-Sources firmware >nul
bins\7z x "%file%" -o01-Project\1-Sources magisk >nul
bins\7z x "%file%" -o01-Project\1-Sources firmware-update >nul
bins\7z x "%file%" -o01-Project\1-Sources META-INF >nul
bins\7z e "%file%" n system.new.dat.br -o01-Project\1-Sources >nul
bins\7z e "%file%" n system.new.dat -o01-Project\1-Sources >nul
bins\7z e "%file%" n system.img -o01-Project\1-Sources >nul
bins\7z e "%file%" n payload.bin -o01-Project\1-Sources >nul
bins\7z e "%file%" n vendor.new.dat.br -o01-Project\1-Sources >nul
bins\7z e "%file%" n vendor.new.dat -o01-Project\1-Sources >nul
bins\7z e "%file%" n vendor.img -o01-Project\1-Sources >nul
bins\7z e "%file%" n system.transfer.list -o01-Project\1-Sources >nul
bins\7z e "%file%" n vendor.transfer.list -o01-Project\1-Sources >nul
bins\7z e "%file%" n boot.img -o01-Project\1-Sources >nul
::bins\7z e "%file%" n file_contexts -o01-Project\1-Sources >nul
::bins\7z e "%file%" n file_contexts.bin -o01-Project\1-Sources >nul
::<---commands
if exist 01-Project\1-Sources\install echo      install [OK] >> log.txt
if exist 01-Project\1-Sources\config echo      config [OK] >> log.txt
if exist 01-Project\1-Sources\firmware echo      firmware [OK] >> log.txt
if exist 01-Project\1-Sources\magisk echo      magisk [OK] >> log.txt
if exist 01-Project\1-Sources\firmware-update echo      firmware-update [OK] >> log.txt
if exist 01-Project\1-Sources\META-INF echo      META-INF [OK] >> log.txt
if exist 01-Project\1-Sources\system.new.dat.br echo      system.new.dat.br [OK] >> log.txt
if exist 01-Project\1-Sources\system.new.dat echo      system.new.dat [OK] >> log.txt
if exist 01-Project\1-Sources\system.img echo      system.img [OK] >> log.txt
if exist 01-Project\1-Sources\payload.bin echo      payload.bin [OK] >> log.txt
if exist 01-Project\1-Sources\vendor.new.dat.br echo      vendor.new.dat.br [OK] >> log.txt
if exist 01-Project\1-Sources\vendor.new.dat echo      vendor.new.dat [OK] >> log.txt
if exist 01-Project\1-Sources\vendor.img echo      vendor.img [OK] >> log.txt
if exist 01-Project\1-Sources\system.transfer.list echo      system.transfer.list [OK] >> log.txt
if exist 01-Project\1-Sources\vendor.transfer.list echo      vendor.transfer.list [OK] >> log.txt
if exist 01-Project\1-Sources\boot.img echo      boot.img [OK] >> log.txt
if exist 01-Project\1-Sources\file_contexts echo      file_contexts [OK] >> log.txt
if exist 01-Project\1-Sources\file_contexts.bin echo      file_contexts.bin [OK] >> log.txt
if exist 01-Project\1-Sources\vendor.* (goto un_vendor) else goto identify_format


:un_vendor
echo ---- Vendor image detected: >> log.txt
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Vendor image detected.{#} Please, decide:
echo.
echo.
echo  	1. Unpack			2. Skip
echo.
set /p number=*       Select an option: 
if "%number%"=="1" goto un_vendor_ok
if "%number%"=="2" goto identify_format
if not "%number%"=="1" if not "%number%"=="2" goto un_vendor

:un_vendor_ok
echo      Extracting vendor image... >> log.txt
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Unpacking Vendor{#} image...
echo.
echo.
echo.
::--->commands
echo ---- brotli.exe:  %time% -Decrypting brotli compression... >> log.txt
if exist 01-Project\1-Sources\vendor.new.dat.br bins\brotli -dj 01-Project\1-Sources\vendor.new.dat.br >nul

echo ---- sdat2img.exe:  %time% -Converting sparse android data image [.DAT] to EXT4 vendor image >> log.txt
if exist 01-Project\1-Sources\vendor.new.dat bins\sdat2img 01-Project\1-Sources\vendor.transfer.list 01-Project\1-Sources\vendor.new.dat 01-Project\1-Sources\vendor.img >> log.txt

echo ---- imgextractor.exe:  %time% -Unpacking vendor.img >> log.txt
if exist 01-Project\1-Sources\vendor.img bins\imgextractor 01-Project\1-Sources\vendor.img 01-Project\vendor >>log.txt

::<---commands
move /y 01-Project\vendor_size.txt 01-Project\1-Sources\vend_size.txt >nul 2>nul
if exist 01-Project\1-Sources\vend_size.txt set /p vsize=<"01-Project\1-Sources\vend_size.txt"
if exist 01-Project\1-Sources\vendor.new.dat !busybox! rm -rf 01-Project\1-Sources\vendor.new.dat >nul
if exist 01-Project\1-Sources\vendor.transfer.list !busybox! rm -rf 01-Project\1-Sources\vendor.transfer.list >nul
if exist 01-Project\1-Sources\vendor.img !busybox! rm -rf 01-Project\1-Sources\vendor.img >nul
if exist 01-Project\1-Sources\vendor_fs_config move /y 01-Project\1-Sources\vendor_fs_config 01-Project\1-Sources\fs_configv >nul 2>nul
move /y 01-Project\1-Sources\vendor_file_contexts 01-Project\1-Sources\file_contextsv >nul 2>nul
if exist 01-Project\vendor\lib\hw echo      Vendor image extracted [OK] >> log.txt


:identify_format
echo ---- System compression format is: >> log.txt
::Looking for system compression format
if exist 01-Project\1-Sources\system.new.dat.br echo new.dat.br format found >> 01-Project\temp\system.new.dat.br.txt
if exist 01-Project\1-Sources\system.new.dat echo new.dat format found >> 01-Project\temp\system.new.dat.txt
if exist 01-Project\1-Sources\system.img echo system.img format found >> 01-Project\temp\system.img.txt
if exist 01-Project\1-Sources\payload.bin echo payload.bin format found >> 01-Project\temp\system.img.txt
if exist 01-Project\1-Sources\payload.bin echo payload.bin format found >> 01-Project\temp\payload.info
for /r 01-Project\temp %%a in (*txt) do set format=%%~na
echo      %format% >> log.txt
if not "%format%"=="system.new.dat.br" if not "%format%"=="system.new.dat" if not "%format%"=="system.img" goto not_supported
if exist 01-Project\1-Sources\payload.bin call :un_payload
if exist 01-Project\1-Sources\system.img call :Extract_SYS
if exist 01-Project\1-Sources\system.new.dat call :un_pack_dat
if exist 01-Project\1-Sources\system.new.dat.br call :un_brotli


:not_supported
if exist 01-Project rmdir /q /s 01-Project
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-Sorry, format {04}not supported{#}
echo.
echo.
echo.
timeout /t 3 /nobreak > nul & exit


:already_deodexed
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Can't proceed:{#}
echo.
echo.
%cecho%  	-{0a}It seems that the ROM was already deodexed{#}
echo.
echo.
echo.
timeout /t 2 /nobreak > nul & goto ROMs_menu


:Extract_SYS
echo ---- Extracting system.img files: >> log.txt
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting system{#} Image...
echo.
echo.
echo.
::--->commands
echo ---- imgextractor.exe:  %time% -Unpacking system.img >> log.txt
if exist 01-Project\1-Sources\system.img bins\imgextractor 01-Project\1-Sources\system.img 01-Project\system >> log.txt
::<---commands
if exist 01-Project\1-Sources\vendor.img echo ---- imgextractor.exe:  %time% -Unpacking vendor.img >> log.txt
if exist 01-Project\1-Sources\vendor.img (
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting vendor{#} Image...
echo.
echo.
bins\imgextractor 01-Project\1-Sources\vendor.img 01-Project\vendor >>log.txt
move /y 01-Project\vendor_size.txt 01-Project\1-Sources\vend_size.txt >nul 2>nul
if exist 01-Project\1-Sources\vend_size.txt set /p vsize=<"01-Project\1-Sources\vend_size.txt"
if exist 01-Project\1-Sources\vendor.img !busybox! rm -rf 01-Project\1-Sources\vendor.img >nul
if exist 01-Project\1-Sources\vendor_fs_config move /y 01-Project\1-Sources\vendor_fs_config 01-Project\1-Sources\fs_configv >nul 2>nul
move /y 01-Project\1-Sources\vendor_file_contexts 01-Project\1-Sources\file_contextsv >nul 2>nul
if exist 01-Project\vendor\lib\hw echo      Vendor image extracted [OK] >> log.txt
)
echo ---- ROM's files extraction finished: %time% >> log.txt
set ENDTIME=%TIME%
call :time
echo      Elapsed Time: %DURATION% >> log.txt
call :boot_status
call :detect_vendor
if exist 01-Project\system\system\build.prop echo      system.img extracted [OK] [SAR] >> log.txt
if exist 01-Project\system\build.prop echo      system.img extracted [OK] [AOnly] >> log.txt
move /y 01-Project\system_size.txt 01-Project\1-Sources\sys_size.txt >nul 2>nul
move /y 01-Project\1-Sources\system_file_contexts 01-Project\1-Sources\file_contexts >nul 2>nul
if exist 01-Project\1-Sources\file_contextsv type 01-Project\1-Sources\file_contextsv >> 01-Project\1-Sources\file_contexts
if exist 01-Project\1-Sources\system_fs_config move /y 01-Project\1-Sources\system_fs_config 01-Project\1-Sources\fs_config >nul 2>nul
set /p size=<"01-Project\1-Sources\sys_size.txt"
if exist 01-Project\system\system\build.prop echo SAR: System As Root ROM >> 01-Project\temp\SAR
if exist 01-Project\temp\SAR if exist 01-Project\system\system\vendor\bin\hw (
!busybox! rm -rf 01-Project\temp\SAR >nul
call :fc_finder
)
if exist 01-Project\temp\SAR call :fs_generator
if exist 01-Project\1-Sources\system.img !busybox! rm -rf 01-Project\1-Sources\system.img >nul 2>nul
if exist 01-Project\1-Sources\system.new.dat !busybox! rm -rf 01-Project\1-Sources\system.new.dat >nul
if exist 01-Project\1-Sources\system.transfer.list !busybox! rm -rf 01-Project\1-Sources\system.transfer.list >nul
goto ROMs_menu


:un_payload
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting payload.bin{#} images...
echo.
echo.
echo.
echo ---- Payload.bin format found: >> log.txt
echo      Extracting inside payload images... >> log.txt
if not exist "01-Project\temp\payload" mkdir "01-Project\temp\payload"
::--->commands
echo ---- payload_dumper.exe:  %time% -Unpacking payload.bin >> log.txt
if exist 01-Project\1-Sources\payload.bin bins\payload_dumper --out 01-Project\temp\payload 01-Project\1-Sources\payload.bin >> log.txt
::<---commands
echo ---- The extracted images were: >> log.txt
if exist 01-Project\temp\payload\system.img echo      Extracted system.img EXT4 [OK] >> log.txt
if exist 01-Project\temp\payload\vendor.img echo      Extracted vendor.img EXT4 [OK] >> log.txt
if exist 01-Project\temp\payload\boot.img echo      Extracted boot.img EXT4 [OK] >> log.txt
if exist 01-Project\temp\payload\system.img  move /y 01-Project\temp\payload\system.img 01-Project\1-Sources >nul 2>nul
if exist 01-Project\temp\payload\vendor.img  move /y 01-Project\temp\payload\vendor.img 01-Project\1-Sources >nul 2>nul
if exist 01-Project\temp\payload\boot.img  move /y 01-Project\temp\payload\boot.img 01-Project\1-Sources >nul 2>nul
if exist 01-Project\temp\payload rmdir /q /s 01-Project\temp\payload
if exist 01-Project\1-Sources\payload.bin !busybox! rm -rf 01-Project\1-Sources\payload.bin >nul
goto:eof


:un_brotli
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Decompressing brotli{#} format...
echo.
echo.
echo.
echo ---- Decompressing brotli format >> log.txt
::--->commands
echo ---- brotli.exe:  %time% -Decrypting brotli compression... >> log.txt
bins\brotli -dj 01-Project/1-Sources/system.new.dat.br >nul
::<---commands
if exist 01-Project/1-Sources/system.new.dat echo      Extracted system.new.dat [OK] >> log.txt
goto un_pack_dat


:un_pack_dat
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Extracting sparse{#} system format...
echo.
echo.
echo.
echo ---- sdat2img.exe:  %time% -Converting sparse android data image [.DAT] to EXT4 system image >> log.txt
::--->commands
bins\sdat2img 01-Project\1-Sources\system.transfer.list 01-Project\1-Sources\system.new.dat 01-Project\1-Sources\system.img >>log.txt
::<---commands
if exist 01-Project/1-Sources/system.img echo      Extracted system.img EXT4 [OK] >> log.txt
goto Extract_SYS


:ROMs_menu
if exist 02-Output rmdir /q /s 02-Output
set system=01-Project\system\system
if exist 01-Project\system\build.prop set system=01-Project\system
if exist system !busybox! rm -rf system >nul
call :boot_status
call :get_ROMs_name
call :rom_info
if exist system.img !busybox! rm -rf system.img >nul
::Know api SDK version
for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.build.version.sdk="'
) do (
    set "api=%%#"
)
echo      ROM's name is: %rname% >> log.txt
echo      Deodexed: %status% - Format: %format% - System size: %size% - Api: %api% >> log.txt
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}  -DM Verity: {0b}!boot_status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
echo  	1. ROM Options  2. Resize system image  3. Rebuild ROM
echo.
set /p number=*       Select an option: 
if "%number%"=="1" goto rom_option
if "%number%"=="2" goto resize
if "%number%"=="3" goto rebuild
if not "%number%"=="1" if not "%number%"=="2" if not "%number%"=="3"  goto ROMs_menu


:resize
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
::--->commands
set /p size=*       Change system image size to: 
if exist 01-Project\1-Sources\sys_size.txt !busybox! rm -rf 01-Project\1-Sources\sys_size.txt >nul
echo %size% >> 01-Project\1-Sources\sys_size.txt
set /p size=<"01-Project\1-Sources\sys_size.txt"
::<---commands
goto ROMs_menu


:rom_option
call :get_ROMs_name
call :rom_info
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
echo  	1. Change ROM's name   2. Add 1-DNS        3. Deodex 8+
echo.
echo  	4. Remove DM verity    5. Zipalign apks    6. Go Back
echo.
set /p number=*       Select an option: 
if "%number%"=="1" goto rom_name
if "%number%"=="2" goto dns_1
if "%number%"=="3" goto deodexer
if "%number%"=="4" goto patch_boot
if "%number%"=="5" goto zipaligning
if "%number%"=="6" goto ROMs_menu
if not "%number%"=="1" if not "%number%"=="2" if not "%number%"=="3" if not "%number%"=="4" if not "%number%"=="5" if not "%number%"=="6" goto rom_option


:rom_name
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
set /p new_rname=*       Change the ROM's name for: 
::--->commands
if exist %system%\build.prop bins\sfk replace %system%\build.prop "/ro.build.display.id=!rname!/ro.build.display.id=!new_rname!/" -yes > nul
::<---commands
call :get_ROMs_name
echo ---- ROM's name changed to: %rname% >> log.txt
goto rom_option


:dns_1
if exist 01-Project\system\build.prop !busybox! sed '/dns/d' 01-Project\system\build.prop >> build.prop
if exist 01-Project\system\system\build.prop !busybox! sed '/dns/d' 01-Project\system\system\build.prop >> build.prop
if exist 01-Project\system\system\build.prop !busybox! mv build.prop 01-Project\system\system
if exist build.prop !busybox! mv build.prop 01-Project\system
timeout /t 1 /nobreak > nul
if exist %system%\build.prop echo net.dns1=1.1.1.1 >> %system%\build.prop
if exist %system%\build.prop echo net.dns2=1.0.0.1 >> %system%\build.prop
timeout /t 1 /nobreak > nul
::--->commands
if exist %system%\build.prop bins\dos2unix -q 01-Project\system\build.prop
::<---commands
echo ---- Added 1.1.1.1 DNS to build.prop >> log.txt
goto rom_option


:patch_boot
::--->commands
bins\rmverity 01-Project\1-Sources\boot.img >nul 2>nul
if exist %vendor%\default.prop bins\sfk replace %vendor%\default.prop "/secure=0/secure=1/" -yes > nul
if exist %vendor%\etc\fstab.qcom bins\sfk replace %vendor%\etc\fstab.qcom "/,verify//" -yes > nul
if exist %vendor%\etc\fstab.qcom bins\sfk replace %vendor%\etc\fstab.qcom "/forceencrypt=/encryptable=/" -yes > nul
if exist %vendor%\etc\fstab.qcom bins\sfk replace %vendor%\etc\fstab.qcom "/forcefdeorfbe=/encryptable=/" -yes > nul
if exist %vendor%\etc\fstab.qcom bins\sfk replace %vendor%\etc\fstab.qcom "/fileencryption=/encryptable=/" -yes > nul
if exist %vendor%\etc\fstab.qcom bins\sfk replace %vendor%\etc\fstab.qcom "/.dmverity=true/.dmverity=false/" -yes > nul
if exist %system%\recovery-from-boot.p !busybox! rm -rf %system%\recovery-from-boot.p > nul
::<---commands
echo ---- DM Verity removed >> log.txt
goto rom_option


:zipaligning
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-{0a}Zipaligning{#} ROM's apks and jars...
echo.
echo.
echo.
echo ---- Zipaligning apks and jars... >> log.txt
::--->commands
for /R %%X in (*.jar) do bins\zipalign -f 4 "%%X" "%%~dpX%%~nX.newjar" >nul 2>nul
for /R %%X in (*.newjar) do move /Y "%%X" "%%~dpX%%~nX.jar" >nul 2>nul
for /R %%X in (*.apk) do bins\zipalign -f 4 "%%X" "%%~dpX%%~nX.new" >nul 2>nul
for /R %%X in (*.new) do move /Y "%%X" "%%~dpX%%~nX.apk" >nul 2>nul
::<---commands
echo      All apks and jars were zipaligned [OK] >> log.txt
goto rom_option


:file_contexts_finder
echo      file_contexts not found, looking for it... >> log.txt
if exist 01-Project\1-Sources\file_contexts !busybox! rm -rf 01-Project\1-Sources\file_contexts >nul 2>nul
::--->commands
bins\fc_finder "01-Project" "01-Project\1-Sources\un_file_contexts" "plat_file_contexts|vendor_file_contexts|nonplat_file_contexts"
if exist 01-Project\1-Sources\un_file_contexts !busybox! sort -u < 01-Project\1-Sources\un_file_contexts >> 01-Project/1-Sources/file_contexts
if exist 01-Project\1-Sources\un_file_contexts !busybox! rm -rf 01-Project\1-Sources\un_file_contexts >nul 2>nul
if exist 01-Project\1-Sources\file_contexts bins\dos2unix -q 01-Project\1-Sources\file_contexts
::<---commands
if exist 01-Project\1-Sources\file_contexts goto rebuild_yes


:rebuild
echo ---- Rebuild process started: %time% >> log.txt
set STARTTIME=%TIME%
echo      Checking requisites... >> log.txt
if exist 01-Project\1-Sources\file_contexts (goto rebuild_yes) else (goto file_contexts_finder)
:rebuild_yes
echo      file_contexts exists [OK] >> log.txt
if exist 01-Project\temp\1.version !busybox! rm -rf 01-Project\temp\1.version
if exist 01-Project\temp\2.version !busybox! rm -rf 01-Project\temp\2.version
if exist 01-Project\temp\3.version !busybox! rm -rf 01-Project\temp\3.version
if exist 01-Project\temp\4.version !busybox! rm -rf 01-Project\temp\4.version
if %api% equ 21 echo 1 >> 01-Project\temp\1.version
if %api% equ 22 echo 2 >> 01-Project\temp\2.version
if %api% equ 23 echo 3 >> 01-Project\temp\3.version
if %api% geq 24 echo 4 >> 01-Project\temp\4.version
for /r 01-Project\temp %%a in (*version) do set version=%%~na
echo      Sparse compression value is:  %version% (No needed for system.img format) >> log.txt
if exist 01-Project\temp\payload.info goto make_payload
if "!boot_status!"=="Null" goto make_payload
if "!format!"=="system.img" goto make_img
if "!format!"=="system.new.dat" goto make_dat
if "!format!"=="system.new.dat.br" goto make_dat_br


:make_payload
call :get_ROMs_name
if not exist 02-Output mkdir 02-Output
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-{0a}Repacking{#} to its original format...
echo.
echo.
::--->commands
if exist 01-Project\temp\SAR (
	echo      Repacking to: %format% format... [SAR] >> log.txt
    bins\make_ext4fs -T 2009110000 -S 01-Project/1-Sources/file_contexts -C 01-Project\1-Sources\fs_config -l %size% -L / -a / -s %~dp0/02-Output/system.img "01-Project/system/" >nul 2>nul>> log.txt
 ) else ( 
 	echo      Repacking to: %format% format... [Aonly] >> log.txt
    bins\make_ext4fs -s -L system -T 2009110000 -S 01-Project\1-Sources\file_contexts -C 01-Project\1-Sources\fs_config -l %size% -a system %~dp0\02-Output\system.img 01-Project\system\ >nul 2>nul>> log.txt
 )
 ::<---commands
if not exist 02-Output\system.img echo      Repacking system to: %format% [Failed] >> log.txt
if not exist 02-Output\system.img goto ROMs_menu
if exist 02-Output\system.img echo      Repacking to: %format% [OK] >> log.txt
if exist 01-Project\vendor call :build_vendor2
if exist 01-Project\1-Sources\boot.img copy /y 01-Project\1-Sources\boot.img 02-Output >nul 2>nul
if exist bins\fastboot.7z bins\7z e bins\fastboot.7z -o02-Output >nul
goto finish


:make_img
call :get_ROMs_name
if not exist 02-Output mkdir 02-Output
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-{0a}Repacking{#} to its original format...
echo.
echo.
::--->commands
if exist 01-Project\temp\SAR (
	echo      Repacking to: %format% format... [SAR] >> log.txt
    bins\make_ext4fs -T 2009110000 -S 01-Project/1-Sources/file_contexts -C 01-Project\1-Sources\fs_config -l %size% -L / -a / %~dp0/02-Output/system.img "01-Project/system/" >nul 2>nul>> log.txt
 ) else ( 
 	echo      Repacking to: %format% format... [Aonly] >> log.txt
    bins\make_ext4fs -L system -T 2009110000 -S 01-Project\1-Sources\file_contexts -C 01-Project\1-Sources\fs_config -l %size% -a system %~dp0\02-Output\system.img 01-Project\system\ >nul 2>nul>> log.txt
 )
 ::<---commands
if not exist 02-Output\system.img echo      Repacking system to: %format% [Failed] >> log.txt
if not exist 02-Output\system.img goto ROMs_menu
if exist 02-Output\system.img echo      Repacking to: %format% [OK] >> log.txt
if exist 01-Project\vendor call :build_vendor2
call :just_zip
goto finish


:make_dat
call :get_ROMs_name
if not exist 02-Output mkdir 02-Output
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-{0a}Repacking{#} to its original format...
echo.
echo.
::--->commands
if exist 01-Project\temp\SAR (
	echo      Repacking to: %format% format... [SAR] >> log.txt
    bins\make_ext4fs -T 2009110000 -S 01-Project/1-Sources/file_contexts -C 01-Project\1-Sources\fs_config -l %size% -L / -a / -s %~dp0/02-Output/system.img "01-Project/system/" >nul 2>nul>> log.txt
 ) else ( 
 	echo      Repacking to: %format% format... [Aonly] >> log.txt
    bins\make_ext4fs -s -L system -T 2009110000 -S 01-Project\1-Sources\file_contexts -C 01-Project\1-Sources\fs_config -l %size% -a system %~dp0\02-Output\system.img 01-Project\system\ >nul 2>nul>> log.txt
 )
::<---commands
if not exist 02-Output\system.img echo      Repacking system.img [Failed] >> log.txt
if not exist 02-Output\system.img goto ROMs_menu
if exist 02-Output\system.img echo      Repacking system.img [OK] >> log.txt
if exist 01-Project\vendor call :build_vendor
::--------------new.dat part--------------::
timeout /t 1 /nobreak >nul
echo ---- img2sdat.exe:  %time% -Repacking to sparse android data image [system.new.DAT] >> log.txt
if exist %~dp0\02-Output\system.img bins\img2sdat %~dp0\02-Output\system.img  -o %~dp0\02-Output -v %version% >> log.txt
timeout /t 1 /nobreak >nul
if exist %~dp0\02-Output\vendor.img echo      img2sdat.exe:  %time% -Repacking to sparse android data image [vendor.new.DAT] >> log.txt
if exist %~dp0\02-Output\vendor.img bins\img2sdat %~dp0\02-Output\vendor.img  -o %~dp0\02-Output -v %version% -p vendor >> log.txt
timeout /t 1 /nobreak >nul
if not exist 02-Output\system.new.dat echo      Repacking system.new.dat [Failed] >> log.txt
if not exist 02-Output\system.new.dat goto ROMs_menu
if exist 02-Output\system.new.dat echo      Repacking system.new.dat [OK] >> log.txt
if exist 02-Output\vendor.new.dat echo      Repacking vendor.new.dat [OK] >> log.txt
::--------------new.dat part--------------::
if exist %~dp0\02-Output\system.img !busybox! rm -rf %~dp0\02-Output\system.img >nul
if exist %~dp0\02-Output\vendor.img !busybox! rm -rf %~dp0\02-Output\vendor.img >nul
::--->commands
fsutil file createnew %~dp0\02-Output\system.patch.dat 0 >nul
fsutil file createnew %~dp0\02-Output\vendor.patch.dat 0 >nul
::<---commands
call :just_zip
goto finish


:make_dat_br
call :get_ROMs_name
if not exist 02-Output mkdir 02-Output
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-{0a}Repacking{#} to its original format...
echo.
echo.
::--->commands
if exist 01-Project\temp\SAR (
	echo      Repacking to: %format% format... [SAR] >> log.txt
    bins\make_ext4fs -T 2009110000 -S 01-Project/1-Sources/file_contexts -C 01-Project\1-Sources\fs_config -l %size% -L / -a / -s %~dp0/02-Output/system.img "01-Project/system/" >nul 2>nul>> log.txt
 ) else ( 
 	echo      Repacking to: %format% format... [Aonly] >> log.txt
    bins\make_ext4fs -s -L system -T 2009110000 -S 01-Project\1-Sources\file_contexts -C 01-Project\1-Sources\fs_config -l %size% -a system %~dp0\02-Output\system.img 01-Project\system\ >nul 2>nul>> log.txt
 )
::<---commands
if not exist 02-Output\system.img echo      Repacking system.img [Failed] >> log.txt
if not exist 02-Output\system.img goto ROMs_menu
if exist 02-Output\system.img echo      Repacking system.img [OK] >> log.txt
if exist 01-Project\vendor call :build_vendor
::--------------new.dat part--------------::
timeout /t 1 /nobreak >nul
echo ---- img2sdat.exe:  %time% -Repacking to sparse android data image [system.new.DAT] >> log.txt
if exist %~dp0\02-Output\system.img bins\img2sdat %~dp0\02-Output\system.img  -o %~dp0\02-Output -v %version% >> log.txt
timeout /t 1 /nobreak >nul
if exist %~dp0\02-Output\vendor.img echo ---- img2sdat.exe:  %time% -Repacking to sparse android data image [vendor.new.DAT] >> log.txt
if exist %~dp0\02-Output\vendor.img bins\img2sdat %~dp0\02-Output\vendor.img  -o %~dp0\02-Output -v %version% -p vendor >> log.txt
timeout /t 1 /nobreak >nul
if not exist 02-Output\system.new.dat echo      Repacking system.new.dat [Failed] >> log.txt
if not exist 02-Output\system.new.dat goto ROMs_menu
if exist 02-Output\system.new.dat echo      Repacking system.new.dat [OK] >> log.txt
if exist 02-Output\vendor.new.dat echo      Repacking vendor.new.dat [OK] >> log.txt
::--------------new.dat part--------------::
::--------------new.dat.br part--------------::
timeout /t 1 /nobreak >nul
if exist %~dp0\02-Output\system.new.dat bins\brotli.exe -6 -j -w 24 %~dp0\02-Output\system.new.dat >nul 2>nul
timeout /t 1 /nobreak >nul
if exist %~dp0\02-Output\vendor.new.dat bins\brotli.exe -6 -j -w 24 %~dp0\02-Output\vendor.new.dat >nul 2>nul
timeout /t 1 /nobreak >nul
if not exist 02-Output\system.new.dat.br echo      Repacking system.new.dat.br [Failed] >> log.txt
if not exist 02-Output\system.new.dat.br goto ROMs_menu
if exist 02-Output\system.new.dat.br echo      Repacking system.new.dat.br [OK] >> log.txt
if exist 02-Output\vendor.new.dat.br echo      Repacking vendor.new.dat.br [OK] >> log.txt
::--------------new.dat.br part--------------::
if exist %~dp0\02-Output\system.img !busybox! rm -rf %~dp0\02-Output\system.img >nul
if exist %~dp0\02-Output\vendor.img !busybox! rm -rf %~dp0\02-Output\vendor.img >nul
::--->commands
fsutil file createnew %~dp0\02-Output\system.patch.dat 0 >nul
fsutil file createnew %~dp0\02-Output\vendor.patch.dat 0 >nul
::<---commands
call :just_zip
goto finish


:build_vendor
echo ---- make_ext4fs.exe:  %time% -Repacking to sparse vendor.img >> log.txt
echo                         used commands: make_ext4fs -s -L vendor -T 2009110000 -S file_contextsv -C fs_configv -l %vsize% -a vendor vendor.img vendor\ >> log.txt
::--->commands
bins\make_ext4fs -s -L vendor -T 2009110000 -S 01-Project\1-Sources\file_contextsv -C 01-Project\1-Sources\fs_configv -l %vsize% -a vendor %~dp0\02-Output\vendor.img 01-Project\vendor\ >nul 2>nul >> log.txt
::<---commands
if exist 02-Output\vendor.img echo      Repacking vendor.img [OK] >> log.txt
goto:eof
:build_vendor2
echo ---- make_ext4fs.exe:  %time% -Repacking to EXT4 vendor.img >> log.txt
echo                         used commands: make_ext4fs -L vendor -T 2009110000 -S file_contextsv -C fs_configv -l %vsize% -a vendor vendor.img vendor\ >> log.txt
::--->commands
bins\make_ext4fs -L vendor -T 2009110000 -S 01-Project\1-Sources\file_contextsv -C 01-Project\1-Sources\fs_configv -l %vsize% -a vendor %~dp0\02-Output\vendor.img 01-Project\vendor\ >nul 2>nul >> log.txt
::<---commands
if exist 02-Output\vendor.img echo      Repacking vendor image [OK] >> log.txt
goto:eof


:just_zip
echo ---- Zipping new ROM:  %time% >> log.txt
call :get_ROMs_name
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-Almost Done. Now {0a}Zipping{#}...
echo.
echo.
echo.
if exist %system%\build.prop for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.build.version.release="'
) do (
    set "release=%%#"
)
if exist %system%\build.prop for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.product.device="'
) do (
    set "device=%%#"
)
if exist %system%\build.prop for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.product.system.device="'
) do (
    set "device=%%#"
)
if exist %system%\build.prop for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.build.version.incremental="'
) do (
    set "rom_version=%%#"
)
echo      New ROM's zip name is: >> log.txt
echo      %rname%_%device%_%rom_version%_%release%.zip >> log.txt 
if exist 01-Project\1-Sources\vendor.new.dat copy /y 01-Project\1-Sources\vendor.new.dat 02-Output >nul 2>nul
if exist 01-Project\1-Sources\vendor.new.dat.br copy /y 01-Project\1-Sources\vendor.new.dat.br 02-Output >nul 2>nul
if exist 01-Project\1-Sources\vendor.transfer.list copy /y 01-Project\1-Sources\vendor.transfer.list 02-Output >nul 2>nul
copy /y bins\zip-sample.zip 02-Output >nul 2>nul
copy /y bins\7z.exe 02-Output >nul 2>nul
copy /y bins\7z.dll 02-Output >nul 2>nul
copy /y 01-Project\1-Sources\boot.img 02-Output >nul 2>nul
copy /y 01-Project\1-Sources\file_contexts 02-Output >nul 2>nul
if exist 01-Project\1-Sources\install xcopy /e /i /y 01-Project\1-Sources\install 02-Output\install >nul 2>nul
if exist 01-Project\1-Sources\config xcopy /e /i /y 01-Project\1-Sources\config 02-Output\config >nul 2>nul
if exist 01-Project\1-Sources\firmware xcopy /e /i /y 01-Project\1-Sources\firmware 02-Output\firmware >nul 2>nul
if exist 01-Project\1-Sources\magisk xcopy /e /i /y 01-Project\1-Sources\magisk 02-Output\magisk >nul 2>nul
if exist 01-Project\1-Sources\firmware-update xcopy /e /i /y 01-Project\1-Sources\firmware-update 02-Output\firmware-update >nul 2>nul
if exist 01-Project\1-Sources\META-INF xcopy /e /i /y 01-Project\1-Sources\META-INF 02-Output\META-INF >nul 2>nul
cd 02-Output
if exist install 7z a "zip-sample.zip" -o+ install -y >nul 2>nul
if exist config 7z a "zip-sample.zip" -o+ config -y >nul 2>nul
if exist firmware 7z a "zip-sample.zip" -o+ firmware -y >nul 2>nul
if exist magisk 7z a "zip-sample.zip" -o+ magisk -y >nul 2>nul
if exist firmware-update 7z a "zip-sample.zip" -o+ firmware-update -y >nul 2>nul
if exist META-INF 7z a "zip-sample.zip" -o+ META-INF -y >nul 2>nul
if exist system.new.dat.br 7z a "zip-sample.zip" -o+ system.new.dat.br -y >nul 2>nul
if exist system.new.dat 7z a "zip-sample.zip" -o+ system.new.dat -y >nul 2>nul
if exist system.patch.dat 7z a "zip-sample.zip" -o+ system.patch.dat -y >nul 2>nul
if exist system.img 7z a "zip-sample.zip" -o+ system.img -y >nul 2>nul
if exist system.transfer.list 7z a "zip-sample.zip" -o+ system.transfer.list -y >nul 2>nul
if exist vendor.new.dat.br 7z a "zip-sample.zip" -o+ vendor.new.dat.br -y >nul 2>nul
if exist vendor.new.dat 7z a "zip-sample.zip" -o+ vendor.new.dat -y >nul 2>nul
if exist vendor.patch.dat 7z a "zip-sample.zip" -o+ vendor.patch.dat -y >nul 2>nul
if exist vendor.img 7z a "zip-sample.zip" -o+ vendor.img -y >nul 2>nul
if exist vendor.transfer.list 7z a "zip-sample.zip" -o+ vendor.transfer.list -y >nul 2>nul
if exist boot.img 7z a "zip-sample.zip" -o+ boot.img -y >nul 2>nul
if exist file_contexts 7z a "zip-sample.zip" -o+ file_contexts -y >nul 2>nul
move /y zip-sample.zip %rname%_%device%_%rom_version%_%release%.zip >nul 2>nul
echo      Zipped, now cleaning directories and files... >> log.txt
if exist firmware-update rmdir /q /s firmware-update >nul 2>nul
if exist install rmdir /q /s install >nul 2>nul
if exist config rmdir /q /s config >nul 2>nul
if exist firmware rmdir /q /s firmware >nul 2>nul
if exist magisk rmdir /q /s magisk >nul 2>nul
if exist META-INF rmdir /q /s META-INF >nul 2>nul
if exist system.new.dat.br del system.new.dat.br >nul 2>nul
if exist system.new.dat del system.new.dat >nul 2>nul
if exist system.patch.dat del system.patch.dat >nul 2>nul
if exist system.img del system.img >nul 2>nul
if exist system.transfer.list del system.transfer.list >nul 2>nul
if exist vendor.new.dat.br del vendor.new.dat.br >nul 2>nul
if exist vendor.new.dat del vendor.new.dat >nul 2>nul
if exist vendor.patch.dat del vendor.patch.dat >nul 2>nul
if exist vendor.img del vendor.img >nul 2>nul
if exist vendor.transfer.list del vendor.transfer.list >nul 2>nul
if exist boot.img del boot.img >nul 2>nul
if exist file_contexts del file_contexts >nul 2>nul
if exist 7z.exe del 7z.exe >nul 2>nul
if exist 7z.dll del 7z.dll >nul 2>nul
cd ..
goto:eof


:finish
call :get_ROMs_name
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
%cecho%  	{0a}ROM's Info{#}
echo.
%cecho%  	-Name: {0b}!rname!{#}  -Deodexed: {0b}!status!{#}
echo.
%cecho%  	-Format: {0b}!format!{#}  -System size: {0b}!size!{#} -Api: {0b}!api!{#}
echo.
echo.
%cecho%  	-All seems to be {0a}Done.{#}
echo.
echo.
%cecho%  	-Go to {0a}02-Output{#} folder.
echo.
echo ---- Rebuild process finished: %time% >> log.txt
set ENDTIME=%TIME%
call :time
echo      Elapsed Time: %DURATION% >> log.txt
if exist log.txt move /y log.txt 02-Output >nul 2>nul
pause>nul & exit

:make_dirs
::prepare folders
if exist "01-Project" rmdir /s /q "01-Project"
if exist "02-Output" rmdir /s /q "02-Output"
if not exist "01-Project" mkdir "01-Project"
if not exist "01-Project\1-Sources" mkdir "01-Project\1-Sources"
if not exist "01-Project\temp" mkdir "01-Project\temp"
if not exist "01-Project\1-Sources" mkdir "01-Project\1-Sources"
::Copying extracted files to source folder
goto:eof

:boot_status
if exist 01-Project\temp\boot_status !busybox! rm -rf 01-Project\temp\boot_status >nul
if exist 01-Project\1-Sources\boot.img (
bins\rmverity -s 01-Project\1-Sources\boot.img >> 01-Project\temp\boot_status
for /f "tokens=1" %%s in (01-Project\temp\boot_status) do set boot_status=%%s
echo ---- Kernel DM Verity active: !boot_status! >> log.txt
) else (
if exist 01-Project\temp\boot_status !busybox! rm -rf 01-Project\temp\boot_status >nul
echo Null >> 01-Project\temp\boot_status
for /f "tokens=1" %%s in (01-Project\temp\boot_status) do set boot_status=%%s
echo ---- Kernel DM Verity active: !boot_status! >> log.txt
)
goto:eof

:detect_vendor
set vendor=
if exist 01-Project\system\system\vendor\app set vendor=01-Project\system\system\vendor
if exist 01-Project\system\vendor\app set vendor=01-Project\system\vendor
if exist 01-Project\vendor\app set vendor=01-Project\vendor
echo      Vendor detected in: %vendor% >> log.txt
goto:eof

:get_ROMs_name
for /f "Tokens=2* Delims==" %%# in (
    'type "%system%\build.prop" ^| findstr "ro.build.display.id="'
) do (
    set "rname=%%#"
)
if "%rname%"=="" call :name_maker
goto:eof
:name_maker
if exist %system%\build.prop echo ro.build.display.id=NoName >> %system%\build.prop
::if exist %system%\build.prop type 01-Project\temp\NoName >> %system%\build.prop
goto:eof


:rom_info
::Know size in bytes for system when building process start
set /p size=<"01-Project\1-Sources\sys_size.txt"
::Know size in bytes for vendor when building process start
if exist 01-Project\vendor set /p vsize=<"01-Project\1-Sources\vend_size.txt"
::Know format from original .zip
for /r 01-Project\temp %%a in (*txt) do set format=%%~na
timeout /t 1 /nobreak > nul
::Know deodex status
call :deodex_status
goto:eof


:deodex_status
if exist 01-Project\temp\status.info del 01-Project\temp\status.info >nul 2>nul
set exts=*.odex *.vdex
For /R 01-Project\system %%A in (%exts%) do (
  if exist %%A goto odexed
  )
goto deodexed
:odexed
echo No>> 01-Project\temp\status.info
goto status
:deodexed
echo Yes>> 01-Project\temp\status.info
goto status
:status
cls
set /p status=<"01-Project\temp\status.info"
goto:eof


:deodexer
call :deodex_status
::check_api
if %api% LEQ 25 (goto rom_option) else (goto next_api)
:next_api
if "%api%"=="26" (goto deodex_oreo) else (goto next_api1)
:next_api1
if "%api%"=="27" (goto deodex_oreo) else (goto next_api2)
:next_api2
if "%api%"=="28" (goto deodex_pie) else (goto next_api3)
:next_api3
if "%api%"=="29" (goto deodex_pie) else (goto rom_option)


:deodex_oreo
call :rom_info
:deodex_oreo_yes
if not exist %system%\framework\oat goto already_deodexed
echo ---- Deodex process started: %time% >> log.txt
set STARTTIME=%TIME%
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-Preparing for deodex {0a}Oreo ROM{#} ...
echo      Oreo ROM detected >> log.txt
echo.
echo.

::::::::::::::::::::::::::::::::::::::::::::VENDOR-PART::::::::::::::::::::::::::::::::::::::::::::

:vendor_de_vdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}vendor{#} files ...
	echo.
	echo.
for /r %vendor%\app %%b in (*.apk) do (
	if not exist vendor_files mkdir vendor_files >nul
	copy /y "%%b" vendor_files >nul 2>nul
	)	
for /r %vendor%\app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" vendor_files >nul 2>nul
	bins\vdexExtractor -i vendor_files --ignore-crc-error >nul 2>nul
	cd vendor_files
	del %%~na.vdex >nul
	if exist %%~na_classes.dex move /y  %%~na_classes.dex classes.dex >nul 2>nul
	if exist %%~na_classes2.dex move /y %%~na_classes2.dex classes2.dex >nul 2>nul
	if exist %%~na_classes3.dex move /y %%~na_classes3.dex classes3.dex >nul 2>nul
	if exist %%~na_classes4.dex move /y %%~na_classes4.dex classes4.dex >nul 2>nul
	if exist %%~na_classes5.dex move /y %%~na_classes5.dex classes4.dex >nul 2>nul
	cd ..
	if exist vendor_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist vendor_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist vendor_files\classes.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes.dex >nul 2>nul
	if exist vendor_files\classes2.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes2.dex >nul 2>nul
	if exist vendor_files\classes3.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes3.dex >nul 2>nul
	if exist vendor_files\classes4.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes4.dex >nul 2>nul
	if exist vendor_files\classes5.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes5.dex >nul 2>nul
	cd vendor_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist vendor_files\%%~na.apk move /y vendor_files\%%~na.apk %vendor%\app\%%~na >nul 2>nul
	if exist %vendor%\app\%%~na\oat\arm64 rmdir /q /s %vendor%\app\%%~na\oat\arm64 >nul 2>nul
	if exist %vendor%\app\%%~na\oat\arm rmdir /q /s %vendor%\app\%%~na\oat\arm >nul 2>nul
)
if exist vendor_files rmdir /q /s vendor_files >nul 2>nul
::::::::::::::::::::::::::::::::::::::::::::VENDOR-PART::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::FRAMEWORK-PART::::::::::::::::::::::::::::::::::::::::::::			

:fram_de_vdex
if exist %system%\framework\oat\arm64 rmdir /q /s %system%\framework\oat\arm >nul 2>nul
if exist %system%\framework\arm64 rmdir /q /s %system%\framework\arm >nul 2>nul
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}framework{#} files ...
	echo.
	echo.
for /r %system%\framework %%b in (*.jar) do (
	if not exist fram_files mkdir fram_files >nul
	copy /y "%%b" fram_files >nul 2>nul
	)
for /r %system%\framework %%b in (*.vdex) do (
	copy /y "%%b" fram_files >nul 2>nul
	)
cd fram_files
rename "boot-*.vdex" "/////*.vdex"
cd ..
bins\vdexExtractor -i fram_files --ignore-crc-error >nul 2>nul
cd fram_files
if exist boot.vdex move /y boot.vdex QPerformance.vdex >nul 2>nul
if exist boot_classes.dex move /y boot_classes.dex QPerformance_classes.dex >nul 2>nul
cd ..
for /r fram_files %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.jar ... >> log.txt
	echo.
	echo.
	cd fram_files
	del %%~na.vdex >nul
	if exist %%~na_classes.dex move /y  %%~na_classes.dex classes.dex >nul 2>nul
	if exist %%~na_classes2.dex move /y %%~na_classes2.dex classes2.dex >nul 2>nul
	if exist %%~na_classes3.dex move /y %%~na_classes3.dex classes3.dex >nul 2>nul
	if exist %%~na_classes4.dex move /y %%~na_classes4.dex classes4.dex >nul 2>nul
	if exist %%~na_classes5.dex move /y %%~na_classes5.dex classes4.dex >nul 2>nul
	cd ..
	if exist fram_files\classes.dex echo      %%~na.jar deodexed [OK] >> log.txt
	if not exist fram_files\classes.dex echo      %%~na.jar [Already Deodexed or Failed] >> log.txt
	if exist fram_files\classes.dex bins\aapt add fram_files\%%~na.jar fram_files\classes.dex >nul 2>nul
	if exist fram_files\classes2.dex bins\aapt add fram_files\%%~na.jar fram_files\classes2.dex >nul 2>nul
	if exist fram_files\classes3.dex bins\aapt add fram_files\%%~na.jar fram_files\classes3.dex >nul 2>nul
	if exist fram_files\classes4.dex bins\aapt add fram_files\%%~na.jar fram_files\classes4.dex >nul 2>nul
	if exist fram_files\classes5.dex bins\aapt add fram_files\%%~na.jar fram_files\classes5.dex >nul 2>nul
	cd fram_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist fram_files\%%~na.jar move /y fram_files\%%~na.jar %system%\framework\ >nul 2>nul
	if exist %system%\framework\arm64 rmdir /q /s %system%\framework\arm64 >nul 2>nul
	if exist %system%\framework\arm rmdir /q /s %system%\framework\arm >nul 2>nul
	if exist %system%\framework\oat rmdir /q /s %system%\framework\oat >nul 2>nul
)
if exist fram_files rmdir /q /s fram_files >nul 2>nul

::::::::::::::::::::::::::::::::::::::::::::FRAMEWORK-PART::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::APP-PART::::::::::::::::::::::::::::::::::::::::::::

:app_de_vdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}app{#} files ...
	echo.
	echo.
for /r %system%\app %%b in (*.apk) do (
	if not exist app_files mkdir app_files >nul
	copy /y "%%b" app_files >nul 2>nul
	)	
for /r %system%\app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" app_files >nul 2>nul
	bins\vdexExtractor -i app_files --ignore-crc-error >nul 2>nul
	cd app_files
	del %%~na.vdex >nul
	if exist %%~na_classes.dex move /y  %%~na_classes.dex classes.dex >nul 2>nul
	if exist %%~na_classes2.dex move /y %%~na_classes2.dex classes2.dex >nul 2>nul
	if exist %%~na_classes3.dex move /y %%~na_classes3.dex classes3.dex >nul 2>nul
	if exist %%~na_classes4.dex move /y %%~na_classes4.dex classes4.dex >nul 2>nul
	if exist %%~na_classes5.dex move /y %%~na_classes5.dex classes4.dex >nul 2>nul
	cd ..
	if exist app_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist app_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist app_files\classes.dex bins\aapt add app_files\%%~na.apk app_files\classes.dex >nul 2>nul
	if exist app_files\classes2.dex bins\aapt add app_files\%%~na.apk app_files\classes2.dex >nul 2>nul
	if exist app_files\classes3.dex bins\aapt add app_files\%%~na.apk app_files\classes3.dex >nul 2>nul
	if exist app_files\classes4.dex bins\aapt add app_files\%%~na.apk app_files\classes4.dex >nul 2>nul
	if exist app_files\classes5.dex bins\aapt add app_files\%%~na.apk app_files\classes5.dex >nul 2>nul
	cd app_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist app_files\%%~na.apk move /y app_files\%%~na.apk %system%\app\%%~na >nul 2>nul
	if exist %system%\app\%%~na\oat\arm64 rmdir /q /s %system%\app\%%~na\oat\arm64 >nul 2>nul
	if exist %system%\app\%%~na\oat\arm rmdir /q /s %system%\app\%%~na\oat\arm >nul 2>nul
)
if exist app_files rmdir /q /s app_files >nul 2>nul
::::::::::::::::::::::::::::::::::::::::::::APP-PART::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::PRIV-APP-PART::::::::::::::::::::::::::::::::::::::::::::

:priv-app_de_vdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}priv-app{#} files ...
	echo.
	echo.
for /r %system%\priv-app %%b in (*.apk) do (
	if not exist priv-app_files mkdir priv-app_files >nul
	copy /y "%%b" priv-app_files >nul 2>nul
	)
for /r %system%\priv-app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" priv-app_files >nul 2>nul
	bins\vdexExtractor -i priv-app_files --ignore-crc-error >nul 2>nul
	cd priv-app_files
	del %%~na.vdex >nul
	if exist %%~na_classes.dex move /y  %%~na_classes.dex classes.dex >nul 2>nul
	if exist %%~na_classes2.dex move /y %%~na_classes2.dex classes2.dex >nul 2>nul
	if exist %%~na_classes3.dex move /y %%~na_classes3.dex classes3.dex >nul 2>nul
	if exist %%~na_classes4.dex move /y %%~na_classes4.dex classes4.dex >nul 2>nul
	if exist %%~na_classes5.dex move /y %%~na_classes5.dex classes4.dex >nul 2>nul
	cd ..
	if exist priv-app_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist priv-app_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist priv-app_files\classes.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes.dex >nul 2>nul
	if exist priv-app_files\classes2.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes2.dex >nul 2>nul
	if exist priv-app_files\classes3.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes3.dex >nul 2>nul
	if exist priv-app_files\classes4.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes4.dex >nul 2>nul
	if exist priv-app_files\classes5.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes5.dex >nul 2>nul
	cd priv-app_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	cd ..
	if exist priv-app_files\%%~na.apk move /y priv-app_files\%%~na.apk %system%\priv-app\%%~na >nul 2>nul
	if exist %system%\priv-app\%%~na\oat\arm64 rmdir /q /s %system%\priv-app\%%~na\oat\arm64 >nul 2>nul
	if exist %system%\priv-app\%%~na\oat\arm rmdir /q /s %system%\priv-app\%%~na\oat\arm >nul 2>nul
)
if exist priv-app_files rmdir /q /s priv-app_files >nul 2>nul
echo ---- Deodex process finished: %time% >> log.txt
set ENDTIME=%TIME%
call :time
echo      Elapsed Time: %DURATION% >> log.txt
::::::::::::::::::::::::::::::::::::::::::::PRIV-APP-PART::::::::::::::::::::::::::::::::::::::::::::

del /S /Q *.vdex >nul 2>nul
del /S /Q *.odex >nul 2>nul
if exist %system%\framework\boot.jar del %system%\framework\boot.jar >nul 2>nul
if exist %system%\framework\miui.jar del %system%\framework\miui.jar >nul 2>nul
::if exist %system%\framework\miuisdk.jar del %system%\framework\miuisdk.jar >nul 2>nul
if exist %system%\framework\miuisystem.jar del %system%\framework\miuisystem.jar >nul 2>nul
cd %system%
for /f "delims=" %%i in ('dir /s /b /ad ^| sort /r') do rd "%%i" >nul 2>nul
cd %~dp0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto rom_option


:deodex_pie
call :rom_info
:deodex_pie_yes
if not exist %system%\framework\oat goto already_deodexed
echo ---- Deodex process started: %time% >> log.txt
set STARTTIME=%TIME%
cls
echo.
echo         *****************************************************
%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
echo.
echo         *****************************************************
echo.
%cecho%  	-Preparing for deodex {0a}Pie ROM{#} ...
echo      Pie or Quiche ROM detected >> log.txt
echo.
echo.

::::::::::::::::::::::::::::::::::::::::::::VENDOR-PART::::::::::::::::::::::::::::::::::::::::::::

:vendor_de_cdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}vendor{#} files ...
	echo.
	echo.
for /r %vendor%\app %%b in (*.apk) do (
	if not exist vendor_files mkdir vendor_files >nul
	copy /y "%%b" vendor_files >nul 2>nul
	)
for /r %vendor%\app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" vendor_files >nul 2>nul
	bins\vdexExtractor -i vendor_files --ignore-crc-error >nul 2>nul
	cd vendor_files
	del %%~na.vdex >nul
	cd ..
	bins\flinux bins\compact_dex_converter vendor_files\%%~na_classes.cdex >nul 2>&1
	if exist vendor_files\%%~na_classes2.cdex bins\flinux bins\compact_dex_converter vendor_files\%%~na_classes2.cdex >nul 2>nul
	if exist vendor_files\%%~na_classes3.cdex bins\flinux bins\compact_dex_converter vendor_files\%%~na_classes3.cdex >nul 2>nul
	if exist vendor_files\%%~na_classes4.cdex bins\flinux bins\compact_dex_converter vendor_files\%%~na_classes4.cdex >nul 2>nul
	if exist vendor_files\%%~na_classes5.cdex bins\flinux bins\compact_dex_converter vendor_files\%%~na_classes5.cdex >nul 2>nul
	cd vendor_files
	del %%~na_classes.cdex >nul
	if exist %%~na_classes2.cdex del %%~na_classes2.cdex >nul 2>nul
	if exist %%~na_classes3.cdex del %%~na_classes3.cdex >nul 2>nul
	if exist %%~na_classes4.cdex del %%~na_classes4.cdex >nul 2>nul
	if exist %%~na_classes5.cdex del %%~na_classes5.cdex >nul 2>nul
	ren %%~na_classes.cdex.new classes.dex >nul
	if exist %%~na_classes2.cdex.new move /y %%~na_classes2.cdex.new classes2.dex >nul 2>nul
	if exist %%~na_classes3.cdex.new move /y %%~na_classes3.cdex.new classes3.dex >nul 2>nul
	if exist %%~na_classes4.cdex.new move /y %%~na_classes4.cdex.new classes4.dex >nul 2>nul
	if exist %%~na_classes5.cdex.new move /y %%~na_classes5.cdex.new classes4.dex >nul 2>nul
	cd ..
	if exist vendor_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist vendor_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist vendor_files\classes.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes.dex >nul 2>nul
	if exist vendor_files\classes2.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes2.dex >nul 2>nul
	if exist vendor_files\classes3.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes3.dex >nul 2>nul
	if exist vendor_files\classes4.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes4.dex >nul 2>nul
	if exist vendor_files\classes5.dex bins\aapt add vendor_files\%%~na.apk vendor_files\classes5.dex >nul 2>nul
	cd vendor_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist vendor_files\%%~na.apk move /y vendor_files\%%~na.apk %vendor%\app\%%~na >nul 2>nul
	if exist %vendor%\app\%%~na\oat\arm64 rmdir /q /s %vendor%\app\%%~na\oat\arm64 >nul 2>nul
	if exist %vendor%\app\%%~na\oat\arm rmdir /q /s %vendor%\app\%%~na\oat\arm >nul 2>nul
)
if exist vendor_files rmdir /q /s vendor_files >nul 2>nul
::::::::::::::::::::::::::::::::::::::::::::VENDOR-PART::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::FRAMEWORK-PART::::::::::::::::::::::::::::::::::::::::::::			

:fram_de_cdex
if exist %system%\framework\oat\arm64 rmdir /q /s %system%\framework\oat\arm >nul 2>nul
if exist %system%\framework\arm64 rmdir /q /s %system%\framework\arm >nul 2>nul
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}framework{#} files ...
	echo.
	echo.
for /r %system%\framework %%b in (*.jar) do (
	if not exist fram_files mkdir fram_files >nul
	copy /y "%%b" fram_files >nul 2>nul
	)
for /r %system%\framework %%b in (*.vdex) do (
	copy /y "%%b" fram_files >nul 2>nul
	)
cd fram_files
rename "boot-*.vdex" "/////*.vdex"
cd ..
bins\vdexExtractor -i fram_files --ignore-crc-error >nul 2>nul
cd fram_files
if exist boot.vdex move /y boot.vdex QPerformance.vdex >nul 2>nul
if exist boot_classes.cdex move /y boot_classes.cdex QPerformance_classes.cdex >nul 2>nul
cd ..
for /r fram_files %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.jar ... >> log.txt
	echo.
	echo.
	cd fram_files
	del %%~na.vdex >nul
	cd ..
	bins\flinux bins\compact_dex_converter fram_files\%%~na_classes.cdex >nul 2>&1
	if exist fram_files\%%~na_classes2.cdex bins\flinux bins\compact_dex_converter fram_files\%%~na_classes2.cdex >nul 2>nul
	if exist fram_files\%%~na_classes3.cdex bins\flinux bins\compact_dex_converter fram_files\%%~na_classes3.cdex >nul 2>nul
	if exist fram_files\%%~na_classes4.cdex bins\flinux bins\compact_dex_converter fram_files\%%~na_classes4.cdex >nul 2>nul
	if exist fram_files\%%~na_classes5.cdex bins\flinux bins\compact_dex_converter fram_files\%%~na_classes5.cdex >nul 2>nul
	cd fram_files
	del %%~na_classes.cdex >nul
	if exist %%~na_classes2.cdex del %%~na_classes2.cdex >nul 2>nul
	if exist %%~na_classes3.cdex del %%~na_classes3.cdex >nul 2>nul
	if exist %%~na_classes4.cdex del %%~na_classes4.cdex >nul 2>nul
	if exist %%~na_classes5.cdex del %%~na_classes5.cdex >nul 2>nul
	if exist %%~na_classes.cdex.new move /y  %%~na_classes.cdex.new classes.dex >nul
	if exist %%~na_classes2.cdex.new move /y %%~na_classes2.cdex.new classes2.dex >nul 2>nul
	if exist %%~na_classes3.cdex.new move /y %%~na_classes3.cdex.new classes3.dex >nul 2>nul
	if exist %%~na_classes4.cdex.new move /y %%~na_classes4.cdex.new classes4.dex >nul 2>nul
	if exist %%~na_classes5.cdex.new move /y %%~na_classes5.cdex.new classes4.dex >nul 2>nul
	cd ..
	if exist fram_files\classes.dex echo      %%~na.jar deodexed [OK] >> log.txt
	if not exist fram_files\classes.dex echo      %%~na.jar [Already Deodexed or Failed] >> log.txt
	if exist fram_files\classes.dex bins\aapt add fram_files\%%~na.jar fram_files\classes.dex >nul 2>nul
	if exist fram_files\classes2.dex bins\aapt add fram_files\%%~na.jar fram_files\classes2.dex >nul 2>nul
	if exist fram_files\classes3.dex bins\aapt add fram_files\%%~na.jar fram_files\classes3.dex >nul 2>nul
	if exist fram_files\classes4.dex bins\aapt add fram_files\%%~na.jar fram_files\classes4.dex >nul 2>nul
	if exist fram_files\classes5.dex bins\aapt add fram_files\%%~na.jar fram_files\classes5.dex >nul 2>nul
	cd fram_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist fram_files\%%~na.jar move /y fram_files\%%~na.jar %system%\framework\ >nul 2>nul
	if exist %system%\framework\arm64 rmdir /q /s %system%\framework\arm64 >nul 2>nul
	if exist %system%\framework\arm rmdir /q /s %system%\framework\arm >nul 2>nul
	if exist %system%\framework\oat rmdir /q /s %system%\framework\oat >nul 2>nul
)
if exist fram_files rmdir /q /s fram_files >nul 2>nul

::::::::::::::::::::::::::::::::::::::::::::FRAMEWORK-PART::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::APP-PART::::::::::::::::::::::::::::::::::::::::::::

:app_de_cdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}app{#} files ...
	echo.
	echo.
for /r %system%\app %%b in (*.apk) do (
	if not exist app_files mkdir app_files >nul
	copy /y "%%b" app_files >nul 2>nul
	)
for /r %system%\app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" app_files >nul 2>nul
	bins\vdexExtractor -i app_files --ignore-crc-error >nul 2>nul
	cd app_files
	del %%~na.vdex >nul
	cd ..
	bins\flinux bins\compact_dex_converter app_files\%%~na_classes.cdex >nul 2>&1
	if exist app_files\%%~na_classes2.cdex bins\flinux bins\compact_dex_converter app_files\%%~na_classes2.cdex >nul 2>nul
	if exist app_files\%%~na_classes3.cdex bins\flinux bins\compact_dex_converter app_files\%%~na_classes3.cdex >nul 2>nul
	if exist app_files\%%~na_classes4.cdex bins\flinux bins\compact_dex_converter app_files\%%~na_classes4.cdex >nul 2>nul
	if exist app_files\%%~na_classes5.cdex bins\flinux bins\compact_dex_converter app_files\%%~na_classes5.cdex >nul 2>nul
	cd app_files
	del %%~na_classes.cdex >nul
	if exist %%~na_classes2.cdex del %%~na_classes2.cdex >nul 2>nul
	if exist %%~na_classes3.cdex del %%~na_classes3.cdex >nul 2>nul
	if exist %%~na_classes4.cdex del %%~na_classes4.cdex >nul 2>nul
	if exist %%~na_classes5.cdex del %%~na_classes5.cdex >nul 2>nul
	ren %%~na_classes.cdex.new classes.dex >nul
	if exist %%~na_classes2.cdex.new move /y %%~na_classes2.cdex.new classes2.dex >nul 2>nul
	if exist %%~na_classes3.cdex.new move /y %%~na_classes3.cdex.new classes3.dex >nul 2>nul
	if exist %%~na_classes4.cdex.new move /y %%~na_classes4.cdex.new classes4.dex >nul 2>nul
	if exist %%~na_classes5.cdex.new move /y %%~na_classes5.cdex.new classes4.dex >nul 2>nul
	cd ..
	if exist app_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist app_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist app_files\classes.dex bins\aapt add app_files\%%~na.apk app_files\classes.dex >nul 2>nul
	if exist app_files\classes2.dex bins\aapt add app_files\%%~na.apk app_files\classes2.dex >nul 2>nul
	if exist app_files\classes3.dex bins\aapt add app_files\%%~na.apk app_files\classes3.dex >nul 2>nul
	if exist app_files\classes4.dex bins\aapt add app_files\%%~na.apk app_files\classes4.dex >nul 2>nul
	if exist app_files\classes5.dex bins\aapt add app_files\%%~na.apk app_files\classes5.dex >nul 2>nul
	cd app_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	if exist classes5.dex del classes5.dex >nul 2>nul
	cd ..
	if exist app_files\%%~na.apk move /y app_files\%%~na.apk %system%\app\%%~na >nul 2>nul
	if exist %system%\app\%%~na\oat\arm64 rmdir /q /s %system%\app\%%~na\oat\arm64 >nul 2>nul
	if exist %system%\app\%%~na\oat\arm rmdir /q /s %system%\app\%%~na\oat\arm >nul 2>nul
)
if exist app_files rmdir /q /s app_files >nul 2>nul
::::::::::::::::::::::::::::::::::::::::::::APP-PART::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::PRIV-APP-PART::::::::::::::::::::::::::::::::::::::::::::

:priv-app_de_cdex
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Copying {0a}priv-app{#} files ...
	echo.
	echo.
for /r %system%\priv-app %%b in (*.apk) do (
	if not exist priv-app_files mkdir priv-app_files >nul
	copy /y "%%b" priv-app_files >nul
	)
for /r %system%\priv-app %%a in (*.vdex) do (
	cls
	echo.
	echo         *****************************************************
	%cecho% 	-{06}Welcome to S.U.R.{#} 			{03}[by JamFlux]{#}
	echo.
	echo         *****************************************************
	echo.
	%cecho%  	-Deodexing {0a}%%~na{#} ...
	echo      Deodexing %%~na.apk ... >> log.txt
	echo.
	echo.
	copy /y "%%a" priv-app_files >nul
	bins\vdexExtractor -i priv-app_files --ignore-crc-error >nul 2>nul
	cd priv-app_files
	del %%~na.vdex >nul
	cd ..
	bins\flinux bins\compact_dex_converter priv-app_files\%%~na_classes.cdex >nul 2>&1
	if exist priv-app_files\%%~na_classes2.cdex bins\flinux bins\compact_dex_converter priv-app_files\%%~na_classes2.cdex >nul 2>nul
	if exist priv-app_files\%%~na_classes3.cdex bins\flinux bins\compact_dex_converter priv-app_files\%%~na_classes3.cdex >nul 2>nul
	if exist priv-app_files\%%~na_classes4.cdex bins\flinux bins\compact_dex_converter priv-app_files\%%~na_classes4.cdex >nul 2>nul
	if exist priv-app_files\%%~na_classes5.cdex bins\flinux bins\compact_dex_converter priv-app_files\%%~na_classes5.cdex >nul 2>nul
	cd priv-app_files
	del %%~na_classes.cdex >nul
	if exist %%~na_classes2.cdex del %%~na_classes2.cdex >nul 2>nul
	if exist %%~na_classes3.cdex del %%~na_classes3.cdex >nul 2>nul
	if exist %%~na_classes4.cdex del %%~na_classes4.cdex >nul 2>nul
	if exist %%~na_classes5.cdex del %%~na_classes5.cdex >nul 2>nul
	ren %%~na_classes.cdex.new classes.dex >nul
	if exist %%~na_classes2.cdex.new move /y %%~na_classes2.cdex.new classes2.dex >nul 2>nul
	if exist %%~na_classes3.cdex.new move /y %%~na_classes3.cdex.new classes3.dex >nul 2>nul
	if exist %%~na_classes4.cdex.new move /y %%~na_classes4.cdex.new classes4.dex >nul 2>nul
	if exist %%~na_classes5.cdex.new move /y %%~na_classes5.cdex.new classes5.dex >nul 2>nul
	cd ..
	if exist priv-app_files\classes.dex echo      %%~na.apk deodexed [OK] >> log.txt
	if not exist priv-app_files\classes.dex echo      %%~na.apk [Already Deodexed or Failed] >> log.txt
	if exist priv-app_files\classes.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes.dex >nul 2>nul
	if exist priv-app_files\classes2.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes2.dex >nul 2>nul
	if exist priv-app_files\classes3.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes3.dex >nul 2>nul
	if exist priv-app_files\classes4.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes4.dex >nul 2>nul
	if exist priv-app_files\classes5.dex bins\aapt add priv-app_files\%%~na.apk priv-app_files\classes5.dex >nul 2>nul
	cd priv-app_files
	del classes.dex >nul 2>nul
	if exist classes2.dex del classes2.dex >nul 2>nul
	if exist classes3.dex del classes3.dex >nul 2>nul
	if exist classes4.dex del classes4.dex >nul 2>nul
	cd ..
	if exist priv-app_files\%%~na.apk move /y priv-app_files\%%~na.apk %system%\priv-app\%%~na >nul 2>nul
	if exist %system%\priv-app\%%~na\oat\arm64 rmdir /q /s %system%\priv-app\%%~na\oat\arm64 >nul 2>nul
	if exist %system%\priv-app\%%~na\oat\arm rmdir /q /s %system%\priv-app\%%~na\oat\arm >nul 2>nul
)
if exist priv-app_files rmdir /q /s priv-app_files >nul 2>nul
echo ---- Deodex process finished: %time% >> log.txt
set ENDTIME=%TIME%
call :time
echo      Elapsed Time: %DURATION% >> log.txt
::::::::::::::::::::::::::::::::::::::::::::PRIV-APP-PART::::::::::::::::::::::::::::::::::::::::::::

del /S /Q *.vdex >nul 2>nul
del /S /Q *.odex >nul 2>nul
if exist %system%\framework\boot.jar del %system%\framework\boot.jar >nul 2>nul
if exist %system%\framework\miui.jar del %system%\framework\miui.jar >nul 2>nul
::if exist %system%\framework\miuisdk.jar del %system%\framework\miuisdk.jar >nul 2>nul
if exist %system%\framework\miuisystem.jar del %system%\framework\miuisystem.jar >nul 2>nul
cd %system%
for /f "delims=" %%i in ('dir /s /b /ad ^| sort /r') do rd "%%i" >nul 2>nul
cd %~dp0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto rom_option

:time
rem Change formatting for the start and end times
    for /F "tokens=1-4 delims=:.," %%a in ("%STARTTIME%") do (
       set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )
	for /F "tokens=1-4 delims=:.," %%a in ("%ENDTIME%") do (
       set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )
	rem Calculate the elapsed time by subtracting values
    set /A elapsed=end-start
	rem Format the results for output
    set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
    if %hh% lss 10 set hh=0%hh%
    if %mm% lss 10 set mm=0%mm%
    if %ss% lss 10 set ss=0%ss%
    if %cc% lss 10 set cc=0%cc%
	set DURATION=%hh%:%mm%:%ss%,%cc%
	goto:eof
	
:fs_generator
::--->commands
if exist 01-Project\1-Sources\fs_config !busybox! rm -rf 01-Project\1-Sources\fs_config >nul 2>nul
bins\fs_generator 01-Project\1-Sources\system.img >>01-Project\1-Sources\fs_config
::<---commands
:fc_finder
::file_contexts maker::
if exist 01-Project\1-Sources\file_contexts !busybox! rm -rf 01-Project\1-Sources\file_contexts >nul 2>nul
::--->commands
bins\fc_finder "01-Project" "01-Project\1-Sources\un_file_contexts" "plat_file_contexts|vendor_file_contexts|nonplat_file_contexts"
if exist 01-Project\1-Sources\un_file_contexts !busybox! sort -u < 01-Project\1-Sources\un_file_contexts >> 01-Project/1-Sources/file_contexts
if exist 01-Project\1-Sources\un_file_contexts !busybox! rm -rf 01-Project\1-Sources\un_file_contexts >nul 2>nul
if exist 01-Project\1-Sources\file_contexts bins\dos2unix -q 01-Project\1-Sources\file_contexts
::<---commands
goto:eof


