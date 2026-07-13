Many Computer Kiosks reset daily (i.e. lab computers) but allow some customization. These scripts setup some basic options and application environment (program manager and archive creation). 

These scripts require Powershell to run. The easy way for me to start Powershell is by typing in the search box (*Type here to search*):

    conhost powershell  # or
    terminal

Then download the script to download the other scripts :):

    curl.exe https://bit.ly/cskdo -Lo CSK-Download.ps1

The Execution Policy may need to be enabled before running a script:

    Set-ExecutionPolicy Unrestricted CurrentUser

The script-names should decscibe their basic functionality. Be sure to look through the scripts first to tailor them to your needs. The scripts are farely-well commented.
