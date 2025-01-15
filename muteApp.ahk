#SingleInstance Force

; 创建托盘菜单
Menu, Tray, NoStandard
Menu, Tray, Add, Change Hotkey, ChangeHotkey
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitApp

; 默认快捷键
currentHotkey := "^!+a"
Hotkey, %currentHotkey%, MuteToggle

MuteToggle:
  WinGet, pid, PID, A
  run, nircmd.exe muteappvolume /%pid% 2, %A_ScriptDir%
Return

ChangeHotkey:
  ; 禁用当前热键
  Hotkey, %currentHotkey%, Off
  
  ; 显示输入框
  InputBox, newHotkey, Change Hotkey, Tip：`n^ = Ctrl`n! = Alt`n+ = Shift`n# = Windows Key`n`n：`n^!+a = Ctrl+Alt+Shift+A`n^!a = Ctrl+Alt+A`n#a = Windows+A`n`nInput new hotkey：,,,,,,,, %currentHotkey%
  
  if !ErrorLevel 
  {
    ; 注册新热键
    Hotkey, %newHotkey%, MuteToggle
    currentHotkey := newHotkey
    
    ; 保存到配置文件
    IniWrite, %newHotkey%, config.ini, Hotkeys, MuteToggle
  }
  else  ; 用户点击了取消
  {
    ; 重新启用原来的热键
    Hotkey, %currentHotkey%, On
  }
Return

ExitApp:
ExitApp
