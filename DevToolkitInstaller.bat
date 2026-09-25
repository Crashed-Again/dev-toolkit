@echo off
setlocal EnableDelayedExpansion
title dev-toolkit Installer

:: ---------------------------------------------------------------------
:: Enable ANSI colors (Windows 10+) for the neon banner
:: ---------------------------------------------------------------------
for /f %%A in ('echo prompt $E^|cmd') do set "ESC=%%A"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "YELLOW=%ESC%[93m"
set "RESET=%ESC%[0m"

:: ---------------------------------------------------------------------
:: App list: NAME / WINGET ID (blank if none) / FALLBACK URL / selected(1/0)
:: ---------------------------------------------------------------------
set "COUNT=15"

set "NAME1=LocalBG"                        & set "WID1="                            & set "URL1=https://localbg.app"                                  & set "SEL1=1"
set "NAME2=Upscayl"                        & set "WID2="                            & set "URL2=https://github.com/upscayl/upscayl/releases"          & set "SEL2=1"
set "NAME3=ytDownloader (by Andreww)"      & set "WID3="                            & set "URL3=https://github.com/aandrew-me/ytDownloader/releases"  & set "SEL3=1"
set "NAME4=VSCodium"                       & set "WID4=VSCodium.VSCodium"           & set "URL4=https://vscodium.com"                                  & set "SEL4=1"
set "NAME5=VirtualBox"                     & set "WID5=Oracle.VirtualBox"           & set "URL5=https://www.virtualbox.org/wiki/Downloads"             & set "SEL5=1"
set "NAME6=XnConvert"                      & set "WID6=XnSoft.XnConvert"            & set "URL6=https://www.xnview.com/en/xnconvert/"                  & set "SEL6=1"
set "NAME7=GitKraken"                      & set "WID7=Axosoft.GitKraken"           & set "URL7=https://www.gitkraken.com/git-client"                  & set "SEL7=1"
set "NAME8=scrcpy"                         & set "WID8=Genymobile.scrcpy"           & set "URL8=https://github.com/Genymobile/scrcpy"                  & set "SEL8=1"
set "NAME9=Blip Transfer"                  & set "WID9="                            & set "URL9=https://blip.net"                                      & set "SEL9=1"
set "NAME10=KDE Connect (Linux only)"      & set "WID10=KDE.KDEConnect"             & set "URL10=https://kdeconnect.kde.org/download.html"             & set "SEL10=0"
set "NAME11=Android Studio (incl. AVD)"    & set "WID11=Google.AndroidStudio"       & set "URL11=https://developer.android.com/studio"                 & set "SEL11=1"
set "NAME12=Everything"                    & set "WID12=voidtools.Everything"       & set "URL12=https://www.voidtools.com"                            & set "SEL12=1"
set "NAME13=Obsidian"                      & set "WID13=Obsidian.Obsidian"          & set "URL13=https://obsidian.md"                                  & set "SEL13=1"
set "NAME14=Audacity"                      & set "WID14=Audacity.Audacity"          & set "URL14=https://www.audacityteam.org/download/"               & set "SEL14=1"
set "NAME15=ONLYOFFICE"                    & set "WID15=ONLYOFFICE.DesktopEditors"  & set "URL15=https://www.onlyoffice.com/download-desktop.aspx"     & set "SEL15=1"

:MENU
cls
call :BANNER
echo ===============================================================
echo   dev-toolkit Installer
echo ===============================================================
echo.
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" (
        echo   [X] %%i. !NAME%%i!
    ) else (
        echo   [ ] %%i. !NAME%%i!
    )
)
echo.
echo ---------------------------------------------------------------
echo   Type a number to toggle it, or:
echo   A = select all    N = select none    I = install selected    Q = quit
echo ---------------------------------------------------------------
set "CHOICE="
set /p "CHOICE=Your choice: "

if /i "%CHOICE%"=="Q" goto :EOF
if /i "%CHOICE%"=="A" (
    for /L %%i in (1,1,%COUNT%) do set "SEL%%i=1"
    goto MENU
)
if /i "%CHOICE%"=="N" (
    for /L %%i in (1,1,%COUNT%) do set "SEL%%i=0"
    goto MENU
)
if /i "%CHOICE%"=="I" goto ENSURE_WINGET

:: toggle a numbered item if valid
set "VALID="
for /L %%i in (1,1,%COUNT%) do (
    if "%CHOICE%"=="%%i" set "VALID=1"
)
if defined VALID (
    if "!SEL%CHOICE%!"=="1" (set "SEL%CHOICE%=0") else (set "SEL%CHOICE%=1")
)
goto MENU

:: ---------------------------------------------------------------------
:: Make sure winget is available before installing anything
:: ---------------------------------------------------------------------
:ENSURE_WINGET
cls
where winget >nul 2>&1
if %ERRORLEVEL%==0 (
    set "WINGET_OK=1"
    goto INSTALL
)

echo ===============================================================
echo   winget was not found -- attempting to install it automatically
echo ===============================================================
echo.

set "WGET_PS=%TEMP%\install_winget.ps1"
> "%WGET_PS%" echo $ErrorActionPreference = 'Stop'
>> "%WGET_PS%" echo try {
>> "%WGET_PS%" echo     Write-Host 'Trying to register the built-in App Installer package...'
>> "%WGET_PS%" echo     Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
>> "%WGET_PS%" echo } catch {}
>> "%WGET_PS%" echo if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
>> "%WGET_PS%" echo     Write-Host 'Downloading latest App Installer (winget) from Microsoft/GitHub...'
>> "%WGET_PS%" echo     $ProgressPreference = 'SilentlyContinue'
>> "%WGET_PS%" echo     try {
>> "%WGET_PS%" echo         $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' -Headers @{ 'User-Agent' = 'dev-toolkit-installer' }
>> "%WGET_PS%" echo         $asset = $release.assets ^| Where-Object { $_.name -like '*.msixbundle' } ^| Select-Object -First 1
>> "%WGET_PS%" echo         $licAsset = $release.assets ^| Where-Object { $_.name -like '*License1.xml' } ^| Select-Object -First 1
>> "%WGET_PS%" echo         $bundlePath = Join-Path $env:TEMP $asset.name
>> "%WGET_PS%" echo         Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $bundlePath
>> "%WGET_PS%" echo         if ($licAsset) {
>> "%WGET_PS%" echo             $licPath = Join-Path $env:TEMP $licAsset.name
>> "%WGET_PS%" echo             Invoke-WebRequest -Uri $licAsset.browser_download_url -OutFile $licPath
>> "%WGET_PS%" echo             Add-AppxProvisionedPackage -Online -PackagePath $bundlePath -LicensePath $licPath -ErrorAction SilentlyContinue ^| Out-Null
>> "%WGET_PS%" echo         }
>> "%WGET_PS%" echo         Add-AppxPackage -Path $bundlePath -ErrorAction SilentlyContinue
>> "%WGET_PS%" echo     } catch {
>> "%WGET_PS%" echo         Write-Host ('Download/install step failed: ' + $_.Exception.Message)
>> "%WGET_PS%" echo     }
>> "%WGET_PS%" echo }
>> "%WGET_PS%" echo if (Get-Command winget -ErrorAction SilentlyContinue) { Write-Host 'winget is now available.' } else { Write-Host 'Automatic winget install did not succeed.' }

powershell -NoProfile -ExecutionPolicy Bypass -File "%WGET_PS%"
del "%WGET_PS%" >nul 2>&1
echo.

where winget >nul 2>&1
if %ERRORLEVEL%==0 (
    set "WINGET_OK=1"
    echo winget is ready. Continuing...
    timeout /t 2 >nul
) else (
    set "WINGET_OK=0"
    echo.
    echo Could not install winget automatically on this system.
    echo You can install it manually as "App Installer" from the Microsoft Store:
    echo https://apps.microsoft.com/detail/9nblggh4nns1
    echo.
    echo Continuing without winget -- apps with a winget package will have
    echo their download page opened in your browser instead of installing silently.
    echo.
    pause
)

:: ---------------------------------------------------------------------
:: Install selected apps
:: ---------------------------------------------------------------------
:INSTALL
cls
echo ===============================================================
echo   Installing selected apps...
echo ===============================================================
echo.

for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" (
        if "!WINGET_OK!"=="1" if not "!WID%%i!"=="" (
            echo Installing !NAME%%i! via winget...
            winget install -e --id !WID%%i! --accept-source-agreements --accept-package-agreements
            echo.
        ) else (
            echo No winget package for !NAME%%i! -- opening download page instead.
            start "" "!URL%%i!"
        )
    )
)

echo.
echo ===============================================================
echo   Done.
echo ===============================================================
pause
goto :EOF

:: ---------------------------------------------------------------------
:: Neon Bear banner
:: ---------------------------------------------------------------------
:BANNER
echo %MAGENTA%          .       .
echo %MAGENTA%         ( \     / )
echo %CYAN%          \'-.-'
echo %CYAN%          ( o o )
echo %YELLOW%           ) - (
echo %YELLOW%          /     \    %RESET%
echo %MAGENTA% _   _                 ____                %RESET%
echo %MAGENTA%^| \ ^| ^| ___  ___  _ __ ^| __ )  ___  __ _ _ __ %RESET%
echo %CYAN%^|  \^| ^|/ _ \/ _ \^| '_ \^|  _ \ / _ \/ _` ^| '__^|%RESET%
echo %CYAN%^| ^|\  ^|  __/ (_) ^| ^| ^| ^| ^|_) ^|  __/ (_^| ^| ^|   %RESET%
echo %YELLOW%^|_^| \_^|\___^|\___/^|_^| ^|_^|____/ \___^|\__,_^|_^|   %RESET%
echo.
exit /b
