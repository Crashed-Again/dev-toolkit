@echo off
setlocal EnableDelayedExpansion
title dev-toolkit Installer

:: ---------------------------------------------------------------------
:: Enable ANSI colors
:: ---------------------------------------------------------------------
for /f %%A in ('echo prompt $E^|cmd') do set "ESC=%%A"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "YELLOW=%ESC%[93m"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "GREY=%ESC%[90m"
set "RESET=%ESC%[0m"

:: ---------------------------------------------------------------------
:: Script version (used by self-update check)
:: ---------------------------------------------------------------------
set "SCRIPT_VERSION=1.1.0"

:: ---------------------------------------------------------------------
:: Mode flags
::   MODE=install (default) | uninstall
:: ---------------------------------------------------------------------
set "MODE=install"
set "REBOOT_NEEDED=0"

:: ---------------------------------------------------------------------
:: App list
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

:: =====================================================================
:: STARTUP: elevate? + self-update check
:: =====================================================================
call :CHECK_ADMIN
call :CHECK_SELF_UPDATE

:: =====================================================================
:: MAIN MENU
:: =====================================================================
:MENU
cls
call :BANNER

if /i "%MODE%"=="uninstall" (
    echo %RED%===============================================================%RESET%
    echo %RED%   dev-toolkit Installer    [ UNINSTALL MODE ]%RESET%
    echo %RED%===============================================================%RESET%
) else (
    echo ===============================================================
    echo   dev-toolkit Installer
    echo ===============================================================
)
echo.
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" (
        echo   %GREEN%[X]%RESET% %%i. !NAME%%i!
    ) else (
        echo   %GREY%[ ]%RESET% %%i. !NAME%%i!
    )
)
echo.
echo ---------------------------------------------------------------
if /i "%MODE%"=="uninstall" (
    echo   Numbers toggle   A = all   N = none   I = UNINSTALL   M = install mode
) else (
    echo   Numbers toggle   A = all   N = none   I = install   U = update   R = remove
)
echo   W = check winget   ? = help   Q = quit
echo ---------------------------------------------------------------
set "CHOICE="
set /p "CHOICE=Your choice: "

if /i "%CHOICE%"=="Q" goto :EOF
if /i "%CHOICE%"=="?" goto HELP
if /i "%CHOICE%"=="W" goto CHECK_WINGET
if /i "%CHOICE%"=="A" (
    for /L %%i in (1,1,%COUNT%) do set "SEL%%i=1"
    goto MENU
)
if /i "%CHOICE%"=="N" (
    for /L %%i in (1,1,%COUNT%) do set "SEL%%i=0"
    goto MENU
)
if /i "%CHOICE%"=="I" (
    if /i "%MODE%"=="uninstall" goto ENSURE_WINGET
    goto ENSURE_WINGET
)
if /i "%CHOICE%"=="U" (
    if /i "%MODE%"=="uninstall" goto MENU
    goto UPDATE_MODE
)
if /i "%CHOICE%"=="R" (
    if /i "%MODE%"=="uninstall" (
        set "MODE=install"
    ) else (
        set "MODE=uninstall"
    )
    goto MENU
)
if /i "%CHOICE%"=="M" (
    set "MODE=install"
    goto MENU
)

:: toggle a numbered item
set "VALID="
for /L %%i in (1,1,%COUNT%) do (
    if "%CHOICE%"=="%%i" set "VALID=1"
)
if defined VALID (
    if "!SEL%CHOICE%!"=="1" (set "SEL%CHOICE%=0") else (set "SEL%CHOICE%=1")
)
goto MENU

:: =====================================================================
:: ADMIN CHECK -- offer to relaunch elevated
:: =====================================================================
:CHECK_ADMIN
net session >nul 2>&1
if %ERRORLEVEL%==0 (
    set "IS_ADMIN=1"
    exit /b
)
set "IS_ADMIN=0"
cls
call :BANNER
echo ===============================================================
echo   Not running as Administrator
echo ===============================================================
echo.
echo   Some installs / uninstalls may need elevation. You can:
echo     [E] Relaunch this script elevated ^(recommended^)
echo     [C] Continue without elevation
echo     [Q] Quit
echo.
set "ELEV="
set /p "ELEV=Choice [E/C/Q]: "
if /i "!ELEV!"=="Q" exit /b 1
if /i "!ELEV!"=="E" (
    echo.
    echo   Requesting elevation...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b 1
)
exit /b

:: =====================================================================
:: SELF-UPDATE CHECK
:: =====================================================================
:CHECK_SELF_UPDATE
set "UPDATE_URL=https://raw.githubusercontent.com/example/dev-toolkit/main/version.txt"
set "LATEST="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing -Uri '%UPDATE_URL%' -TimeoutSec 4).Content.Trim() } catch { }" 2^>nul`) do set "LATEST=%%V"
if not defined LATEST exit /b
if /i "!LATEST!"=="%SCRIPT_VERSION%" exit /b
echo.
echo   %YELLOW%[i] A newer dev-toolkit is available: %SCRIPT_VERSION% -^> !LATEST!%RESET%
echo       %GREY%%UPDATE_URL%%RESET%
echo.
timeout /t 2 >nul
exit /b

:: =====================================================================
:: CHECK WINGET
:: =====================================================================
:CHECK_WINGET
cls
call :BANNER
echo ===============================================================
echo   winget status check
echo ===============================================================
echo.
where winget >nul 2>&1
if not %ERRORLEVEL%==0 (
    echo   %RED%[X] winget was NOT found on this system.%RESET%
    echo.
    echo   Install manually as "App Installer" from the Microsoft Store:
    echo     https://apps.microsoft.com/detail/9nblggh4nns1
    echo.
    echo   Or return and press I -- the installer will try to set it up.
    echo.
    pause
    goto MENU
)
echo   %GREEN%[OK] winget is installed.%RESET%
echo.
echo   --- Version -----------------------------------------------
winget --version
echo.
echo   --- Sources -----------------------------------------------
winget source list
echo.
echo   --- Connectivity test -------------------------------------
winget search --id Microsoft.PowerToys --accept-source-agreements >nul 2>&1
if %ERRORLEVEL%==0 (
    echo   %GREEN%[OK] winget sources are reachable.%RESET%
) else (
    echo   %YELLOW%[!]  winget could not reach its sources.%RESET%
    echo        Try: winget source reset --force
)
echo.
pause
goto MENU

:: =====================================================================
:: HELP
:: =====================================================================
:HELP
cls
call :BANNER
echo ===============================================================
echo   Help
echo ===============================================================
echo.
echo   MENU KEYS
echo     ^<number^>   Toggle that app's selection
echo     A          Select all
echo     N          Select none
echo     I          Install ^(or Uninstall, if in remove mode^)
echo     U          Update mode: winget upgrade all selected installed apps
echo     R          Toggle install/remove mode
echo     M          Force install mode
echo     W          Check winget status ^(version, sources, connectivity^)
echo     ?          This help screen
echo     Q          Quit
echo.
echo   MODES
echo     Install    Default. winget installs silently; apps without a
echo                winget ID get batched into one browser-open prompt.
echo     Uninstall  Press R. Then I uninstalls selected apps via winget.
echo.
echo   WINGET FALLBACK
echo     If winget is missing, the script offers to install it
echo     automatically via PowerShell. If that fails, apps without a
echo     winget ID will have their download pages opened in a browser.
echo.
echo   ADMIN / ELEVATION
echo     On startup you can press E to relaunch elevated. Recommended
echo     for VirtualBox, Android Studio and other system-wide apps.
echo.
echo   SELF-UPDATE
echo     The script checks %UPDATE_URL%
echo     at startup and warns if a newer version is available.
echo.
echo   REBOOT
echo     If any install returns exit code 3010 ^(reboot required^) the
echo     script offers to reboot when finished.
echo.
echo   VERSION: %SCRIPT_VERSION%
echo.
pause
goto MENU

:: =====================================================================
:: ENSURE WINGET
:: =====================================================================
:ENSURE_WINGET
cls
where winget >nul 2>&1
if %ERRORLEVEL%==0 (
    set "WINGET_OK=1"
    if /i "%MODE%"=="uninstall" goto UNINSTALL
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
    if /i "%MODE%"=="uninstall" goto UNINSTALL
    goto INSTALL
) else (
    set "WINGET_OK=0"
    echo.
    echo Could not install winget automatically.
    echo You can install "App Installer" from the Microsoft Store:
    echo https://apps.microsoft.com/detail/9nblggh4nns1
    echo.
    if /i "%MODE%"=="uninstall" (
        echo Cannot uninstall without winget. Returning to menu.
        pause
        goto MENU
    )
    echo Continuing without winget -- apps with a winget ID will have
    echo their download page opened in your browser instead.
    echo.
    pause
)

:: =====================================================================
:: INSTALL (with progress bar + reboot detection)
:: =====================================================================
:INSTALL
cls
echo ===============================================================
echo   Installing selected apps...
echo ===============================================================
echo.

:: Count how many winget installs we'll do (for the progress bar)
set "TOTAL_WINGET=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" if "!WINGET_OK!"=="1" if not "!WID%%i!"=="" (
        set /a TOTAL_WINGET+=1
    )
)

set "STEP=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" (
        if "!WINGET_OK!"=="1" if not "!WID%%i!"=="" (
            set /a STEP+=1
            call :PROGRESS !STEP! !TOTAL_WINGET! "!NAME%%i!"
            winget install -e --id !WID%%i! --accept-source-agreements --accept-package-agreements --silent
            set "RC=!ERRORLEVEL!"
            if "!RC!"=="3010" (
                set "REBOOT_NEEDED=1"
                echo   %YELLOW%[i] !NAME%%i! requested a reboot to finish.%RESET%
            ) else if not "!RC!"=="0" (
                echo   %YELLOW%[!] !NAME%%i! returned exit code !RC!.%RESET%
            )
            echo.
        )
    )
)

:: ---- Batch the "no winget package" apps into one prompt ----
set "WEBCOUNT=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" (
        if "!WINGET_OK!"=="0" (
            set /a WEBCOUNT+=1
            set "WEBNAME!WEBCOUNT!=!NAME%%i!"
            set "WEBURL!WEBCOUNT!=!URL%%i!"
        ) else if "!WID%%i!"=="" (
            set /a WEBCOUNT+=1
            set "WEBNAME!WEBCOUNT!=!NAME%%i!"
            set "WEBURL!WEBCOUNT!=!URL%%i!"
        )
    )
)

if !WEBCOUNT!==0 goto INSTALL_DONE

echo.
echo ===============================================================
echo   The following apps have no winget package and will be
echo   opened in your browser as download pages:
echo ===============================================================
echo.
set "WEBLIST="
for /L %%j in (1,1,!WEBCOUNT!) do (
    echo     - !WEBNAME%%j!
    if defined WEBLIST (
        set "WEBLIST=!WEBLIST! ^& !WEBNAME%%j!"
    ) else (
        set "WEBLIST=!WEBNAME%%j!"
    )
)
echo.
echo   Combined: !WEBLIST!
echo.
set "OPENALL="
set /p "OPENALL=Open all of them now? [Y/N]: "

if /i "!OPENALL!"=="Y" (
    for /L %%j in (1,1,!WEBCOUNT!) do (
        echo   Opening !WEBNAME%%j! ...
        start "" "!WEBURL%%j!"
    )
    echo.
    echo   All download pages have been opened.
) else (
    echo.
    echo   Skipped. You can install these manually later.
)

:INSTALL_DONE
call :REBOOT_PROMPT
echo.
echo ===============================================================
echo   Done.
echo ===============================================================
pause
goto MENU

:: =====================================================================
:: UNINSTALL
:: =====================================================================
:UNINSTALL
cls
echo ===============================================================
echo   %RED%Uninstalling selected apps...%RESET%
echo ===============================================================
echo.

set "TOTAL_UN=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" if not "!WID%%i!"=="" (
        set /a TOTAL_UN+=1
    )
)

if !TOTAL_UN!==0 (
    echo   None of the selected apps have a winget ID -- nothing to uninstall.
    echo   Apps without a winget ID must be removed manually.
    echo.
    pause
    goto MENU
)

set "STEP=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" if not "!WID%%i!"=="" (
        set /a STEP+=1
        call :PROGRESS !STEP! !TOTAL_UN! "!NAME%%i!"
        winget uninstall -e --id !WID%%i! --accept-source-agreements
        set "RC=!ERRORLEVEL!"
        if "!RC!"=="3010" (
            set "REBOOT_NEEDED=1"
            echo   %YELLOW%[i] !NAME%%i! requested a reboot to finish.%RESET%
        ) else if not "!RC!"=="0" (
            echo   %YELLOW%[!] !NAME%%i! returned exit code !RC!.%RESET%
        )
        echo.
    )
)

echo ===============================================================
echo   Uninstall pass complete.
echo ===============================================================
call :REBOOT_PROMPT
pause
goto MENU

:: =====================================================================
:: UPDATE MODE
:: =====================================================================
:UPDATE_MODE
cls
if "%WINGET_OK%"=="1" goto UPDATE_RUN
where winget >nul 2>&1
if not %ERRORLEVEL%==0 (
    echo winget is required for update mode. Please install it first.
    pause
    goto MENU
)
set "WINGET_OK=1"

:UPDATE_RUN
echo ===============================================================
echo   Update mode -- winget upgrade for selected apps
echo ===============================================================
echo.

set "TOTAL_UP=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" if not "!WID%%i!"=="" (
        set /a TOTAL_UP+=1
    )
)

if !TOTAL_UP!==0 (
    echo   None of the selected apps have a winget ID -- nothing to update.
    echo.
    pause
    goto MENU
)

set "STEP=0"
for /L %%i in (1,1,%COUNT%) do (
    if "!SEL%%i!"=="1" if not "!WID%%i!"=="" (
        set /a STEP+=1
        call :PROGRESS !STEP! !TOTAL_UP! "!NAME%%i!"
        winget upgrade -e --id !WID%%i! --accept-source-agreements --accept-package-agreements
        set "RC=!ERRORLEVEL!"
        if "!RC!"=="3010" (
            set "REBOOT_NEEDED=1"
            echo   %YELLOW%[i] !NAME%%i! requested a reboot to finish.%RESET%
        ) else if not "!RC!"=="0" (
            echo   %YELLOW%[!] !NAME%%i! upgrade returned exit code !RC!.%RESET%
        )
        echo.
    )
)

echo ===============================================================
echo   Update pass complete.
echo ===============================================================
call :REBOOT_PROMPT
pause
goto MENU

:: =====================================================================
:: PROGRESS -- [n/total] name + tiny spinner
::   %1 = step   %2 = total   %3 = name
:: =====================================================================
:PROGRESS
set "PCT=0"
set /a PCT=(%1 * 100) / %2
set "BAR="
set /a FILLED=%PCT% / 5
for /L %%b in (1,1,20) do (
    if %%b LEQ %FILLED% (
        set "BAR=!BAR!#"
    ) else (
        set "BAR=!BAR!."
    )
)
echo   [%1/%2] !BAR! %PCT%%% -- %~3
exit /b

:: =====================================================================
:: REBOOT PROMPT
:: =====================================================================
:REBOOT_PROMPT
:: Also catch the standard Windows "pending reboot" registry flags
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" >nul 2>&1 && set "REBOOT_NEEDED=1"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" >nul 2>&1 && set "REBOOT_NEEDED=1"

if "!REBOOT_NEEDED!"=="1" (
    echo.
    echo   %YELLOW%===============================================================%RESET%
    echo   %YELLOW%  A reboot is recommended to finish some changes.%RESET%
    echo   %YELLOW%===============================================================%RESET%
    echo.
    set "RB="
    set /p "RB=Reboot now? [Y/N]: "
    if /i "!RB!"=="Y" (
        echo   Rebooting in 10 seconds... press Ctrl+C to cancel.
        shutdown /r /t 10 /c "dev-toolkit: finishing installs"
    ) else (
        echo   Skipped. Remember to reboot later.
    )
)
exit /b

:: =====================================================================
:: NEON BANNER
:: =====================================================================
:BANNER
echo %MAGENTA% _______                     __________%RESET%
echo %MAGENTA% \      \   ____  ____   ____\______   \ ____ _____ _______%RESET%
echo %CYAN% /   ^|   \_/ __ \/  _ \ /    \^|    ^|  _// __ \\__  \\_  __ \%RESET%
echo %CYAN%/    ^|    \  ___(  ^<_^> )   ^|  \    ^|   \  ___/ / __ \^|  ^| \/%RESET%
echo %YELLOW%\____^|__  /\___  ^>____/^|___^|  /______  /\___  ^>____  /__^|%RESET%
echo %YELLOW%        \/     \/           \/       \/     \/     \/%RESET%
echo.
exit /b
