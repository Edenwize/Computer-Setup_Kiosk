## FILES REMOVE THAT WERE PART OF ARCHIVE.
###
### Some kiosk managers may leave files on the computer. This script will remove
### files left behind on the kiosk that are recorded in the 
### `Archive-Compress.ps1 script.
#
# $files += $file | Get-ChildItem -Force -Recurse | Remove-Item -Force -Recurse

$FILE_INCS = "$env:TEMP\archive-includes.txt"
if ( -not (Test-Path $FILE_INCS) ) {
  Write-Output "File missing: $FILE_INCS"
  exit
}

#
Push-Location $env:USERPROFILE
#
$ANSWER = Read-Host "Files remove that were extracted from the Archive?"
if ( $ANSWER -eq "y" -or $ANSWER -eq "Y") {
  $LIST_FILES = Get-Content $FILE_INCS
  foreach ( $file in $LIST_FILES ) {
    if ( Test-Path -Path $file ) {
      $file | Remove-Item -Force -Recurse
    }
  }
}
#
Pop-Location

