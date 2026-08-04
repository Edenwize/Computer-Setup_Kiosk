# Computer Kiosk Setup

Scripts to automate settings, install Program-Manager, it's Programs, and Extract/Compress them.

## Explanation

Many Computer Kiosks reset daily (i.e. lab computers) but allow some customization. These scripts require PowerShell to run. The easy way for me to start PowerShell is by typing in the search box (*Type here to search*):

    # conhost powershell  # or
    terminal

Then download the script that downloads the other scripts :):

    curl.exe https://bit.ly/cskdo -Lo CSK-Download.ps1

The Execution Policy may need to be enabled before running a script:

    Set-ExecutionPolicy Unrestricted CurrentUser

The script-names should describe their basic functionality. Be sure to look through the scripts first to tailor them to your needs. The scripts are fairly-well commented:

    .\CSK-Download.ps1
    .\Archive-Extract.ps1
    .\Computer-Setup.ps1
    .\wt-start.ps1

## Program-Manager: Commands used regularly

I use a handy Program-Manager called [Scoop](https://scoop.sh/) ([Usage Guide](https://github.com/ScoopInstaller/Scoop/wiki)):

    scoop search _____                          # I usually use online version.
    scoop install _______
    scoop list                                  # Applications list that are installed.
    scoop update && scoop status                # Applications list that are updates.
    scoop update --all
    scoop cleanup --all ; scoop cache rm --all  # Apps rm prev-ver; rm instllrs..

# Finish

    .\Archive-Compress.ps1
    # Upload to cload (5-10 minutes)
