; ctrl + alt + w
^!w::
    WinGet, activeProcessName, ProcessName, A
    if !activeProcessName
        Return
    Run, SoundVolumeView.exe /Switch "%activeProcessName%",, Hide
Return
