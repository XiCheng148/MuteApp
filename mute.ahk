; ctrl + alt + shift + a
^!+a::
  WinGet, pid, PID, A
  run, nircmd.exe muteappvolume /%pid% 2, %A_ScriptDir%
Return
