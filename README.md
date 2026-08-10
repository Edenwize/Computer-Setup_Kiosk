# Computer Kiosk Setup

Many Computer Kiosks reset daily (i.e. lab computers) but allow some customization. These scripts require PowerShell to run. These scripts automate: setting certain settings, unpacking an archive, and Extract/Compress all of this to upload to cloud storage.

To start PowerShell typing in the search box (*Type here to search*):

    # conhost powershell  # or
    terminal

Then download the script that downloads the other scripts :):

    curl.exe https://bit.ly/cskdo -Lo CSK-Download.ps1

The Execution Policy may need to be enabled before running a script:

    Set-ExecutionPolicy Unrestricted CurrentUser

The script-names should describe their basic functionality. Be sure to look through the scripts first to tailor them to your needs. The scripts are fairly-well commented:

    .\CSK-Download.ps1    ; `
    .\Archive-Extract.ps1 ; `
    .\Computer-Setup.ps1  ; `
    .\wt-start.ps1

## Program-Manager

I use a handy Program-Manager called [Scoop](https://scoop.sh/). Commands used regularly ([Usage Guide](https://github.com/ScoopInstaller/Scoop/wiki)):

    scoop search    <program>                   # Search is better with the Websco version.
    scoop install   <program>
    scoop uninstall <program>
    scoop list                                  # Applications list that are installed.
    scoop update && scoop status                # Applications list that are updates.
    scoop update --all
    scoop cleanup --all ; scoop cache rm --all  # Apps rm prev-ver; rm instllrs..

# Finish

    .\Archive-Compress.ps1
    # Archive upload to cloud (5-10 minutes)
