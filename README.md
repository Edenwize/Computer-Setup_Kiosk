# Computer-Kiosk Setup

Computer-Kiosks usually reset daily (ie lab computers) but allow some customization. These scripts customize some settings… and require PowerShell to run. They automate: certain settings, and Extracting/Compressing all of this to upload to cloud storage. The script names describe their basic functionality. The scripts should be read before use for greater explanations and setting particular settings.

PowerShell start by typing in the search box (*Type here to search*):

    # conhost powershell  # or
    terminal

Script download that downloads the other scripts. Then run the script:

    cd $HOME\Downloads
    #curl.exe https://bit.ly/cskdo -Lo CSK-Download.ps1
    curl.exe https://raw.githubusercontent.com/Edenwize/Computer-Setup_Kiosk/refs/heads/main/CSK-Download.ps1 -Lo CSK-Download.ps1
    Set-ExecutionPolicy Unrestricted CurrentUser     # ExPol may need enabled for script to run
    .\CSK-Download.ps1

Archive download from your source then extract it:

    .\Archive-Extract.ps1

Computer setup with some basic settings, and start new terminal:

    .\Computer-Setup.ps1  ; `
    .\wt-start.ps1

Archive compress (so one can upload it) when work is finished:

    .\Archive-Compress.ps1

Files remove that were installed (if necessary: most systems reset the user environment after logout):

    .\Files-Remove.ps1

## Program-Manager

I use a handy Program-Manager called [Scoop](https://scoop.sh/). Commands used regularly ([Usage Guide](https://github.com/ScoopInstaller/Scoop/wiki)):

    scoop search    <program>                   # Search is better with the Websco version.
    scoop install   <program>
    scoop uninstall <program>
    scoop list                                  # Applications list that are installed.
    scoop update && scoop status                # Applications list that are updates.
    scoop update --all
    scoop cleanup --all ; scoop cache rm --all  # Apps rm prev-ver; rm instllrs..


