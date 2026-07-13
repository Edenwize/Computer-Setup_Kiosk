## ARCHIVE CREATE FROM LISTS (INCLUSIONS AND EXCLUSIONS) AND WITH UPDATE CAPABILITIES (USING 7ZIP).
#
# List of Excludes requires using relative paths if archiving non-root. Also avoid using generic
# names as 7zip excludes has the ability for general matching (like "Downloads" will match 
# "Music\Downloads").
#
# 7zip (and almost all other archiving programs that I know of [MS-Zip, tar...]) lacks being able to
# archive links (soft links, hard links, and junctions): MS-Zip fails to do them; .7z fails to do
# them AND junctions get copied as directories (which can make for LARGE archives); 7-zip's WIM works
# some with symbolic links but can have extraction problems (junctions are created as a blank file, 
# and hard-links are copied); and tar only works on a Linux-like filesystem. Using `dism.exe` works and
# is a nice container solution, however it does require administrative rights and I lack knowing
# if it works good with lists (made more for disk copies). 'wimlib' works and can be used be a regular
# user but I have yet to find out how to do it with lists. In short, links are best removed from
# archive and then recreated after extraction.

## VARIABLES
#
$TYPE = "Files"
$LCTN = "Library"
# $LOCL = "-Locale"
$CONT = "wim"
$CMPR = "7z"
#
$PATH_CONT = "$env:USERPROFILE\Downloads\${TYPE}_${LCTN}${LOCL}.$CONT"
$PATH_CMPR = "$env:USERPROFILE\Downloads\${TYPE}_${LCTN}${LOCL}.$CMPR"
#
$LIST_INCL = "$env:TEMP\archive-includes.txt"
$LIST_EXCL = "$env:TEMP\archive-excludes.txt"

## LISTS FOR INCLUDE AND EXCLUDE FILES.
#
$INCL_FILES = @(
  # ".config"
  # "AppData\LocalLow\Daggerfall Workshop"
  # "AppData\Roaming\Microsoft\Windows\PowerShell"
  # ".vscode"
  # "WindowsTerminal.lnk"
  ".scrap"
  "AppData\Roaming\.config"
  "AppData\Roaming\Microsoft\Windows\My Games\Neverball-dev"
  "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
  "Documents"
  "Program-Manager"
  #
) | Out-File -Encoding utf8 -Force $LIST_INCL
#
foreach ( $file in $INCL_FILES ) {
  if   ( Test-Path -Path $file ) {}
  else { Write-Output "List for includes is missing: $file" }
}
#
$EXCL_FILES = @(
  "desktop.ini"
  "Documents\My Music"
  "Documents\My Pictures"
  "Documents\My Shapes"
  "Documents\My Videos"
  "~\Downloads\"
) | Out-File -Encoding utf8 -Force $LIST_EXCL

# LIST OF JUNCTIONS/SOFT-LINKS CREATE AND ADD TO LIST FOR EXCLUDES.
#
cmd.exe /C dir /AL /S /B $env:SCOOP | foreach {$_.Replace("$env:USERPROFILE\","")} | Out-File -Append -Encoding utf8 $LIST_EXCL

## ARCHIVE
#
Push-Location $env:USERPROFILE
#
# CONTAINER: WIM (RECOMMENDED)---FASTER, OFFERS REASONABLE COMPRESSION.
7zr.exe u $PATH_CONT -up0q0r2x1y2z1w2 -ir@"$LIST_INCL" -xr@"$LIST_EXCL" -ms=off -snh -snl
#
# COMPRESSION ONLY (compression [low-high]: -mx=[0-9])
# 7zr.exe u $PATH_CMPR -up0q0r2x1y2z1w2 -ir@"$LIST_INCL" -xr@"$LIST_EXCL" -ms=off -snh -snl -mx=5
#
Pop-Location
