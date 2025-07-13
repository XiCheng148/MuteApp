;===============================================================================
; SCRIPT CONFIGURATION
;===============================================================================
#SingleInstance Force
#Persistent
SetWorkingDir, %A_ScriptDir%  ; 确保脚本在正确的目录下工作，以便找到 .exe 和 .ini 文件

;===============================================================================
; INITIALIZATION (Auto-Execute Section)
;===============================================================================

; 定义配置文件和键名
configFile := "config.ini"
configSection := "Hotkeys"
configKey := "MuteToggle"

; 检查依赖文件是否存在
if !FileExist("SoundVolumeView.exe")
{
    MsgBox, 48, Error, "SoundVolumeView.exe not found in the script's directory.`nPlease make sure it is placed in the same folder as the script.`n`nScript will now exit."
    ExitApp
}

; 创建托盘菜单 (Create Tray Menu)
Menu, Tray, NoStandard
Menu, Tray, Add, Change Hotkey, TrayMenu_ChangeHotkey
Menu, Tray, Add  ; Separator
Menu, Tray, Add, Exit, TrayMenu_Exit

; 从配置文件加载热键，如果不存在则使用默认值
; Load hotkey from config file, use default if it doesn't exist
IniRead, currentHotkey, %configFile%, %configSection%, %configKey%, ^!w

; 激活热键 (Activate the hotkey)
Hotkey, %currentHotkey%, MuteToggle

Return ; 结束自动执行区域 (End of the auto-execute section)

;===============================================================================
; HOTKEYS & SUBROUTINES
;===============================================================================

MuteToggle:
    ; 正确获取当前活动窗口的进程名
    ; Correctly get the process name of the active window
    WinGet, activeProcessName, ProcessName, A

    ; 如果没有获取到进程名，则不执行任何操作
    ; If no process name was retrieved, do nothing
    if !activeProcessName
        Return

    Run, SoundVolumeView.exe /Switch "%activeProcessName%",, Hide
Return

TrayMenu_ChangeHotkey:
    ; 禁用当前热键以防冲突
    ; Disable the current hotkey to prevent conflicts
    Hotkey, %currentHotkey%, Off

    ; 使用 continuation section 使提示文本更清晰
    ; Use a continuation section for a cleaner prompt text
    prompt =
    (
Tip:
^ = Ctrl
! = Alt
+ = Shift
# = Windows Key

Examples:
^!+a = Ctrl+Alt+Shift+A
^!a = Ctrl+Alt+A
#a = Windows+A

Input new hotkey:
    )

    InputBox, newHotkey, Change Hotkey, %prompt%,,,,,,,, %currentHotkey%

    ; ErrorLevel is 0 if OK was pressed, 1 if Cancel was pressed
    if ErrorLevel
    {
        ; 用户点击了取消，重新启用原来的热键
        ; User pressed Cancel, so re-enable the original hotkey
        Hotkey, %currentHotkey%, On
        Return
    }

    ; 尝试注册新热键以进行验证
    ; Try to register the new hotkey to validate it
    Hotkey, %newHotkey%, MuteToggle, On
    
    ; A_LastError will be non-zero if the hotkey is invalid or already in use by another program
    if (A_LastError != 0)
    {
        MsgBox, 48, Invalid Hotkey, The hotkey "%newHotkey%" is invalid or already in use.`nReverting to the previous hotkey.
        ; 验证失败，重新启用旧热键
        ; Validation failed, re-enable the old hotkey
        Hotkey, %currentHotkey%, On
    }
    else
    {
        ; 验证成功，更新变量并保存到文件
        ; Validation successful, update variable and save to file
        currentHotkey := newHotkey
        IniWrite, %newHotkey%, %configFile%, %configSection%, %configKey%
        ToolTip, Hotkey successfully changed to %currentHotkey%
        SetTimer, RemoveToolTip, -2000 ; 2秒后移除提示 (Remove tooltip after 2 seconds)
    }
Return

RemoveToolTip:
    ToolTip
Return

TrayMenu_Exit:
    ExitApp