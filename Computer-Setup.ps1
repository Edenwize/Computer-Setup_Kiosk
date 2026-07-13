## COMPUTER SETUP ON A KIOSK (FOR A REGULAR USER).
#

## CONFIGURATION: VARIABLES FOR SCRIPT AND ENVIRONMENT CREATE.

## Variables for script.
#
$env:DSP_BRT              = "75"                                    # Display Brightness
$env:MSE_SNS              = "5"                                     # Mouse Sensitivity
$env:HOME                 = "$env:APPDATA\.config"                  # Home dir for Linux-apps
$env:SCOOP                = "$env:USERPROFILE\Program-Manager"      # Program-Manager install dir.
$env:INKSCAPE_PROFILE_DIR = "$env:SCOOP\persist\inkscape\settings"  # Vector editor pref loc
$env:XDG_CONFIG_HOME      = "$env:HOME"                             # Scoop uses this for a log file.

## Variables for environment (user).
#
$KEY_VALU = @{
  "DSP_BRT"               = $env:DSP_BRT
  "MSE_SNS"               = $env:MSE_SNS
  "HOME"                  = $env:HOME
  "SCOOP"                 = $env:SCOOP
  "INKSCAPE_PROFILE_DIR"  = $env:INKSCAPE_PROFILE_DIR
  "XDG_CONFIG_HOME"       = $env:XDG_CONFIG_HOME
}

## Paths of executable files add to.
#
$PATHS = @(                                                        # Paths with executables to add.
  "$env:USERPROFILE\Documents\PowerShell;"
  "$env:USERPROFILE\Program-Manager\shims;"
)

## Configuration files to replace path with CURRENT PATH.
#
$CONFIGS = @{
  #
  # Path types:  (Simple clobber replacement... PLEASE be careful with sensitive files!)
  #
  # "C:\Users\$env:USERNAME\path\..."     = "W"   # Windows-standard backslash separators.
  # "C:\\Users\\$env:USERNAME\\path\\..." = "2"   # Windows-standard backslash doubled (regex safe).
  # "C:/Users/$env:USERNAME/path/..."     = "L"   # Linux-standard forward-slash seps. (for ports).
  #
  "$env:HOME\.gitconfig"                                        = "L"
  "$env:SCOOP\persist\git-persist\etc\gitconfig"                = "L"
  "$env:SCOOP\persist\pwsh\PSReadLine\ConsoleHost_history.txt"  = "W"
  "$env:SCOOP\persist\vscode\data\user-data\User\settings.json" = "2"
  "$env:SCOOP\shims\*.shim"                                     = "W"
  #
  # "$env:SCOOP\apps\*\current\install.json"                      = "W"   # deprecated?!
  #
}

#
## Directories in home to hide..
#
$HOME_HIDE_DIRS = @(
  ".config"
  ".ms-ad"
  ".vscode"
  "3D Objects"
  "Contacts"
  # "Desktop"  # Protected and remains visible.
  # "Documents"
  # "Downloads"
  "Favorites"
  "Links"
  "Music"
  # "OneDrive"
  # "Pictures"
  # "Program-Manager"
  "Saved Games"
  "Searches"
  "Videos"
)
#
## Fonts to load.
#
$FNT_PTHS = @(
  "$env:SCOOP\apps\font_firago\current\FiraGO_TTF\*\*.ttf"
  "$env:SCOOP\apps\font_merriweather\current\*.ttf"
  "$env:SCOOP\apps\font_roboto-slab\current\*.ttf"
  "$env:SCOOP\apps\font_roboto\current\*.ttf"
  "$env:SCOOP\apps\windows-terminal\current\*.ttf"
)
#
# --- SECTION FOR CONFIGURING ENDS HERE ---

#
## ENVIRONMENTAL VARIABLES SET.
#
$KEY_VALU.GetEnumerator() | ForEach-Object {
  [System.Environment]::SetEnvironmentVariable("$($_.Key)", "$($_.Value)", "User")
  New-Item -Force -Path env:\$($_.Key) -Value "$($_.Value)" | Out-Null
  Write-Output "$($_.Key) : $($_.Value)"
}
  Write-Output "====="
#
## PATHS SET.
#
foreach ( $path in $PATHS ) {
  [System.Environment]::SetEnvironmentVariable("Path", $env:Path + "$path", "User")
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")
}

## LINKS RECREATE FOR PROGRAM MANAGER (SCOOP).
### THE ONLY ARCHIVE PROGRAMS ABLE TO PRESERVE THEM (THAT I KNOW OF) ARE DISM AND WIMLIB.
#
# Junctions recreate for application `current` directories (use those of newest date [assume they are the newest version], simple clobber creation).
#
$APP_DIRS = (Get-ChildItem -Directory -Exclude scoop  -Path $env:SCOOP\apps).FullName
foreach ( $app_dir in $APP_DIRS ) {
  $app_new = Get-ChildItem -Directory -Exclude current -Path $app_dir | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $app_cur = "$app_dir\current"
  if ( Test-Path $app_cur ) {
    Remove-Item -Force -Path $app_cur -Recurse }  ## This is dangerous, use only if sure.
    # echo "rm'd: $app_cur"
  New-Item -Force -ItemType Junction -Path $app_cur -Value $app_new | Select-Object -ExpandProperty FullName
}
#
## Junctions and Hard-Links recreate to persist directory (using the application's manifest).
#
$APPS_PSBL = (Get-ChildItem -Path $env:SCOOP\persist).Name
foreach ( $app in $APPS_PSBL ) { 
  if ( Test-Path $env:SCOOP\apps\$app ) {  # Use persist directory name and test if app is installed
    $MNFS_JSON = Get-Content -Path $env:SCOOP\apps\$app\current\manifest.json | Out-String | ConvertFrom-Json
    $app_prsts = $MNFS_JSON.persist
    foreach ( $prst in $app_prsts ) {
      if ( Test-Path -PathType Container $env:SCOOP\persist\$app\$prst ) {
        if ( Test-Path $env:SCOOP\apps\$app\current\$prst ) {
            Remove-Item -Force -Path $env:SCOOP\apps\$app\current\$prst -Recurse }
        ## if ( $? ) { echo "* Removed: $app_cur" }    #### keeps repeating rm'd wt\current
        New-Item -ItemType Junction -Path $env:SCOOP\apps\$app\current\$prst -Value $env:SCOOP\persist\$app\$prst -Force | Select-Object -ExpandProperty FullName }
      else {
        New-Item -ItemType HardLink -Path $env:SCOOP\apps\$app\current\$prst -Value $env:SCOOP\persist\$app\$prst -Force | Select-Object -ExpandProperty FullName
      }
    }
  }
}

## CONFIGURATION FILES: REPLACE PATH WITH CURRENT PATH.
#
$CONFIGS.GetEnumerator() | ForEach-Object {
  #
  if ( $($_.Value) -eq "W" ) {
    $_.Name | ForEach-Object {
      $files = Get-ChildItem -Path $_
      foreach ( $file in $files ) {
        (Get-Content -Path $file) -replace "C:\\Users\\.*?(\\)","$env:USERPROFILE\" `
        | Set-Content -Path $file
      }
    }
  }

  #
  if ( $($_.Value) -eq "2" ) {
    #
    $ENV_USEPRF_DBL = ($env:USERPROFILE) -replace "\\","\\"
    #
    $_.Name | ForEach-Object {
      $files = Get-ChildItem -Path $_
      foreach ( $file in $files ) {
        (Get-Content -Path $file) -replace "C:\\\\Users\\.*?(\\\\)","$ENV_USEPRF_DBL\\" `
          | Set-Content -Path $file
      }
    }
  }
#
  if ( $($_.Value) -eq "L" ) {
    #
    $ENV_USEPRF_FWS = ($env:USERPROFILE) -replace "\\","/"
    #
    $_.Name | ForEach-Object {
      $files = Get-ChildItem -Path $_
      foreach ( $file in $files ) {
        (Get-Content -Path $file) -replace "C:/Users/.*?(/)","$ENV_USEPRF_FWS/" `
          | Set-Content -Path $file
      }
    }
  }
}

## DIRECTORIES IN HOME TO HIDE.
#
foreach ( $home_hide_dir in $HOME_HIDE_DIRS ) {
  if ( Test-Path $env:USERPROFILE\$home_hide_dir ) {
    (Get-Item -Force $env:USERPROFILE\$home_hide_dir).Attributes="Hidden"
  }
}
#

## APPLICATIONS REGISTER AND FTA'S ASSOCIATE <https://setuserfta.com>
#
# $APP_REGS    = @{
#   "$env:SCOOP\apps\inkscape\current\bin\inkscape.exe" = ".svg"
#   "$env:SCOOP\apps\vscode\current\bin\code.cmd"       = ".code-workspace",".ini",".json",".log",".markdown",".md",".psm1",".ps1",".txt",".xml"
#   "$env:SCOOP\apps\waterfox-libportable\current\core\waterfox.exe" = ".htm", ".html", ".pdf", ".shtml", ".xht", ".xhtml", "ftp", "http", "https"
#   # "microsoft-edge", "microsoft-edge-holographic", 
# }
#
##
# $APP_REGS.GetEnumerator().ForEach({ foreach ( $value in $($_.Value) ) { echo "$($_.Key)---$value"} })
##
#
$APP_REGS    = @(
  "$env:SCOOP\apps\inkscape\current\bin\inkscape.exe"
  "$env:SCOOP\apps\vscode\current\bin\code.cmd"
  "$env:SCOOP\apps\waterfox-libportable\current\core\waterfox.exe"
)
#
foreach ( $app_reg in $APP_REGS ) {
  $program = $app_reg | Split-Path -Leaf
  New-Item -Force -Path "HKCU:\SOFTWARE\Classes\Applications\$program\shell\open\command\" | Out-Null
  New-ItemProperty -Force -Path "HKCU:\SOFTWARE\Classes\Applications\$program\shell\open\command\" -Name "(default)" -Value "$app_reg `"%1`"" | Select-Object -ExpandProperty PSPath
}
#
$EXTENSIONS = ( ".svg" )
foreach ( $extension in $EXTENSIONS ) {
  SetUserFTA.exe $extension Applications\inkscape.exe }
#
$EXTENSIONS = ( ".code-workspace",".ini",".json",".log",".markdown",".md",".psm1",".ps1",".txt",".xml" )
foreach ( $extension in $EXTENSIONS ) {
  SetUserFTA.exe $extension Applications\code.cmd }
#
$EXTENSIONS = ( "microsoft-edge", "microsoft-edge-holographic", ".htm", ".html", ".pdf", ".shtml", ".xht", ".xhtml", "ftp", "http", "https" )
foreach ( $extension in $EXTENSIONS ) {
  SetUserFTA.exe $extension Applications\waterfox.exe }

## DATE AND TIME (https://stackoverflow.com/q/36726738)
#
Set-ItemProperty -Path "HKCU:\Control Panel\International\" -Name sShortTime  -Value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International\" -Name sTimeFormat -Value "HH:mm:ss"
Set-ItemProperty -Path "HKCU:\Control Panel\International\" -Name sShortDate  -Value "yyMMdd ddd"
Set-ItemProperty -Path "HKCU:\Control Panel\International\" -Name sLongDate   -Value "yyyy, MMMM dd, dddd"
#
# Set-ItemProperty -Path "HKCU:\Control Panel\International\" -Name sShortDate  -Value "yy.MM.dd.ddd"
#
try   { Set-TimeZone -Id "Pacific Standard Time"
        tzutil.exe /s "Pacific Standard Time" }
catch {}

## FONT INSTALLS
# <https://github.com/EdenWise/Computer-Setup_Kiosk>
# <https://stackoverflow.com/q/60972345>
#
## Code (C#) for font additions.
#
$fontCSharpCode = @'
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
namespace FontResource
{
  public class AddRemoveFonts
  {
    [DllImport("gdi32.dll")]
    static extern int AddFontResource(string lpFilename);
    public static int AddFont(string fontFilePath) {
      try 
      {
        return AddFontResource(fontFilePath);
      }
      catch
      {
        return 0;
      }
    }
  }
}
'@
#
try   { Add-Type $fontCSharpCode }
catch {}
#
# Directory create for fonts that are local.
#
if ( -not ( Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" ) ) {
  mkdir "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
}
## List create of font locations.
#
foreach ( $fnt_pth in $FNT_PTHS ) {
  if   ( Test-Path -Path $fnt_pth ) { $FNT_LST += Get-ChildItem -Path $fnt_pth -Exclude "static" }
  else { Write-Output "Path fails to exists: $fnt_pth." }
}
#
# Fonts copy to local font directory.
#
foreach ( $fnt in $FNT_LST ) {
  if ( -not ( Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\$fnt" ) ) {
    cp $fnt.FullName "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
  }
}
#
$FNT_LST = Get-ChildItem -File -Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*.ttf"
#
## Fonts register and (add to font cache?!). <https://stackoverflow.com/a/58100621>
#
foreach ( $fnt in $FNT_LST ) {
  #
  # Font name acquire.
  #
  $FNT_DIR = $fnt | Split-Path -Parent
  $OBJ_SHL = New-Object -ComObject Shell.Application
  $SHL_DIR = $OBJ_SHL.Namespace($FNT_DIR)
  $SHL_FNT = $SHL_DIR.ParseName($fnt.Name)
  $FNT_NME = $SHL_DIR.GetDetailsOf($SHL_FNT, 21)
  #
  $reg_pth = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
  $INSTLLD = Get-ItemProperty -Path $reg_pth -Name "$FNT_NME (TrueType)" -ErrorAction SilentlyContinue
  if ( -not $INSTLLD ) {
    #
    # Font register.
    #
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$FNT_NME (TrueType)" -PropertyType String -Value "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\$fnt.Name" -Force | Out-Null
    #
    # Font (add to font cache?!).
    #
    [FontResource.AddRemoveFonts]::AddFont($fnt.FullName) | Out-Null
    if ( $? ) { Write-Output "Loading $($fnt.FullName)" }
  }
}

## KEYBOARD: NUMLOCK ON AND LEAVE ON, HOTKEY FOR INPUT LANGUAGE SWITCHING DISABLE
## https://superuser.com/a/813818/532630
#
if ( ! ( [console]::NumberLock ) ) { (New-Object -ComObject WScript.Shell).SendKeys('{NUMLOCK}') }
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard\" -Name "InitialKeyboardIndicators" -Value "2"
#
# https://www.elevenforum.com/t/turn-on-or-off-use-different-keyboard-layout-for-each-app-window-in-windows-11.4109/
#
# Set-WinLanguageBarOption
Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar
#
$HKCUKeyboardLayoutToggle = 'HKCU:\Keyboard Layout\Toggle\'
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Language Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Layout Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Hotkey' -Value 3

## VOLUME (https://stackoverflow.com/q/21355891/4515565)
#
function Volume_Set($volume) { $WshShell = New-Object -ComObject WScript.Shell;1..50 | ForEach-Object { $WshShell.SendKeys([char]174)}; $volume = $volume / 2;1..$volume | ForEach-Object { $WshShell.SendKeys([char]175) } }
Volume_Set -Volume 8

## DISPLAY: ADJUST BRIGHTNESS AND COLOR
#
$INP_OBJ = Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue
if ( $INP_OBJ ) {
  Invoke-CimMethod -InputObject $(Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods) -MethodName WmiSetBrightness -Arguments @{Timeout=10;Brightness=$env:DSP_BRT} -ErrorAction SilentlyContinue
}

#
# Copy-Item -Force "$env:USERPROFILE\Documents\= Computer Setup =\Profile_Display_Pima_12.icc" "C:\Windows\System32\spool\drivers\color\"
# colorcpl.exe

## MOUSE: BUTTONS SWAP (https://stackoverflow.com/q/4806575)
#
$api = Add-Type -PassThru -Namespace Win32 -Name Win32SwapMouseButton -MemberDefinition @'
    [DllImport("user32.dll")]
    public static extern bool SwapMouseButton(bool fSwap);
'@
$api::SwapMouseButton($True)

## MOUSE: SENSITIVITY ADJUST (https://stackoverflow.com/a/71195076), (https://bit.ly/3Ug2s8e)
#
Set-StrictMode -Off
$winApi = add-type -name user32 -namespace tq84 -passThru -memberDefinition '
  [DllImport("user32.dll")]
    public static extern bool SystemParametersInfo(
      uint uiAction,
      uint uiParam ,
      uint pvParam ,
      uint fWinIni
    );
'
$SPI_SETMOUSESPEED = 0x0071   # 113
$MSE_SEN_BFR       = $( (Get-ItemProperty "HKCU:\Control Panel\Mouse").MouseSensitivity )
$null = $winApi::SystemParametersInfo($SPI_SETMOUSESPEED, 0, $env:MSE_SNS, 0)
Set-ItemProperty "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -Value $env:MSE_SNS
   # Mouse Sensitivity only stored temporarily, needs to be changed in registry as well.
$MSE_SEN_AFT = $( (Get-ItemProperty "HKCU:\Control Panel\Mouse").MouseSensitivity )
" Mouse Sensitivity From: $MSE_SEN_BFR To: $MSE_SEN_AFT"

## MOUSE POINTER CHANGE TO INVERTED
#
Set-StrictMode -Version Latest
$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
$RegCursors.SetValue("","Windows Inverted")
$RegCursors.SetValue("CursorBaseSize",0x40)     # 64 FAIL
$RegCursors.SetValue("CursorBaseSize",0x20)     # 32
$RegCursors.SetValue("AppStarting","%SystemRoot%\cursors\wait_i.cur")
$RegCursors.SetValue("Arrow","%SystemRoot%\cursors\arrow_i.cur")
$RegCursors.SetValue("Crosshair","%SystemRoot%\cursors\cross_i.cur")
$RegCursors.SetValue("Hand","")
$RegCursors.SetValue("Help","%SystemRoot%\cursors\help_i.cur")
$RegCursors.SetValue("IBeam","%SystemRoot%\cursors\beam_i.cur")
$RegCursors.SetValue("No","%SystemRoot%\cursors\no_i.cur")
$RegCursors.SetValue("NWPen","%SystemRoot%\cursors\pen_i.cur")
$RegCursors.SetValue("SizeAll","%SystemRoot%\cursors\move_i.cur")
$RegCursors.SetValue("SizeNESW","%SystemRoot%\cursors\size1_i.cur")
$RegCursors.SetValue("SizeNS","%SystemRoot%\cursors\size4_i.cur")
$RegCursors.SetValue("SizeNWSE","%SystemRoot%\cursors\size2_i.cur")
$RegCursors.SetValue("SizeWE","%SystemRoot%\cursors\size3_i.cur")
$RegCursors.SetValue("UpArrow","%SystemRoot%\cursors\up_i.cur")
$RegCursors.SetValue("Wait","%SystemRoot%\cursors\busy_i.cur")
$RegCursors.Close()
$RegConnect.Close()
#
$CSharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
$CursorRefresh::SystemParametersInfo(0x2029, 0, 32, 0x01);
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)
# Out-Null here?!

## OTHER
#
# PowerShell: Profile location redefine.
#
# New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -PropertyType String -Value "$env:APPDATA\Microsoft\Windows" -Force | Out-Null
#
# Explorer: View set for default as "Details", https://superuser.com/a/1300695/532630
#
# Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\" -Force -Recurse
# Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU\" -Force -Recurse
# New-Item -Force -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}"
# New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" -Name FileOpenDialog -PropertyType DWord -Value 0x00000004
# New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" -Name LogicalViewMode -PropertyType DWord -Value 0x00000004
# #
# $FldrTypes = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes'
# $hkcuBags  = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags'

# gci $FldrTypes | gp | ? CanonicalName -match '\.SearchResults$' | %{
#     New-Item ('{0}\AllFolders\Shell\{1}' -f $hkcuBags , $_.PSChildName) -Force |
#         Set-ItemProperty -Name '(Default)' -Value (gp $_.PSPath).CanonicalName -PassThru |
#         New-ItemProperty -Name Mode            -value 4  |
#         New-ItemProperty -Name IconSize        -value 16 |
#         New-ItemProperty -Name LogicalViewMode -value 1  | Get-Item ### Dislpays key after creation
#     $hkcuBags | gci | ? PSChildName -match '\d+' | gci -s | ? PSChildName -eq $_.PSChildName | Remove-Item
# }


## WINDOWS-TERMINAL START
#
# wt.exe fails to find the settings?!
#echo "PowerShell: New settings loading..."
#Invoke-Command { . pwsh.exe -nologo } -NoNewScope
# conhost.exe powershell.exe -ExecutionPolicy Unrestricted -NoExit -NoProfile -Command "echo '$env:SCOOP\apps\scoop\current\bin\scoop.ps1 update pwsh,windows-terminal'"
# wt new-tab --help
# wt new-tab --profile "pwsh"
#
# $EXE_TERM = (Get-ChildItem -Path $env:SCOOP\apps\windows-terminal -Filter wt.exe -Recurse).FullName | Select-Object -First 1
#
#
# start $EXE_TERM
# start $env:USERPROFILE\WindowsTerminal.lnk
# Start-Process     -FilePath $EXE_TERM
# Invoke-Expression -Command  $EXE_TERM
# &($EXE_TERM)


## HELP
#
# Add script execution checks: https://bit.ly/4fkuBDb ; ScriptAnalyze: https://bit.ly/3SuMeXd
# Setting Windows PowerShell environment variables  https://stackoverflow.com/a/27524483/4515565
#
# [System.Environment]::SetEnvironmentVariable("SCOOP_GLOBAL","$env:SCOOP\","Machine")
#
# `New-Item -ItemType Junction`: target requires absolute path, mklink can be relative.
#

Pop-Location
# Shell restart or Close and open new shell
# Variables that are for process... remove.


# # store this shell's parent PID for later use
# $parentPID = $PID
# # get the the path of this shell's executable
# $thisExePath = (Get-Process -Id $PID).Path
# # start a new shell, same window
# Start-Process $thisExePath -NoNewWindow
# # stop this shell if it's still alive
# Stop-Process -Id $parentPID -Force

# Start-Process $PID -NoNewWindow && Stop-Process -Id $PID -Force
# Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Start-Process -NoNewWindow $_ }

# Set-ItemProperty HKCU:\Environment\ -Name INKSCAPE_PROFILE_DIR -Value "$env:USERPROFILE\AppData\Roaming\inkscape"
# By default set to %appdata%/inkscape... did I bother for certain reason??

# Variables Inside Single Quotes: https://stackoverflow.com/a/32127808/4515565
# Loops with multiple arrays:     https://stackoverflow.com/a/25192032/4515565
