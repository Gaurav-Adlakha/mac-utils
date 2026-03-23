on open location theURL
    set profileFile to (POSIX path of (path to home folder)) & ".chrome_active_profile"
    try
        set profileKey to do shell script "tr -d '\\n' < " & quoted form of profileFile
        set chromeBin to "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        do shell script quoted form of chromeBin & " --profile-directory=" & quoted form of profileKey & " " & quoted form of theURL & " &"
    on error errMsg
        do shell script "open -a 'Google Chrome' " & quoted form of theURL
    end try
end open location
