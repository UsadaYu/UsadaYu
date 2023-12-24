set_input_method(LocaleID) {
  DllCall("LoadKeyboardLayout", "Str", Format("{:08X}", LocaleID), "UInt", 1)
  ControlGet, hwnd, Hwnd,, , A
  PostMessage, 0x50, 0, LocaleID,, ahk_id %hwnd%  ; WM_INPUTLANGCHANGEREQUEST
}

get_current_locale_id() {
  WinGet, hwnd, ID, A
  threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
  hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
  Return hkl & 0xFFFF
}

#SingleInstance Force
#Persistent

; 读取配置
configPath := A_Temp "\shourcut_config.ini"

; 读取热键配置
IniRead, CurrentHotkey, %configPath%, Settings, Hotkey, F7

; 读取用户名密码配置
IniRead, Username, %configPath%, Credentials, Username, admin
IniRead, Password, %configPath%, Credentials, Password, admin123

; 初始热键绑定
Hotkey, %CurrentHotkey%, LoginProcedure

; 创建托盘菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 更改热键, ChangeHotkeyHandler
Menu, Tray, Add, 设置用户名密码, SetCredentialsHandler  ; 新增配置项
Menu, Tray, Add
Menu, Tray, Add, 退出脚本, ExitScriptHandler
Menu, Tray, Default, 更改热键
Menu, Tray, Tip, 自动登录脚本`n当前热键: %CurrentHotkey%

return

; 登录功能
LoginProcedure:
  originalLocaleID := get_current_locale_id()
  set_input_method(0x0409)  ; 切换到英文

  Sleep, 5
  Loop, Parse, Username
  {
    SendInput, {Text}%A_LoopField%
    Sleep 10
    SendInput, {End}
    Sleep 10
  }
  Sleep, 10

  SendInput, {Tab}
  Sleep, 20

  Loop, Parse, Password
  {
    SendInput, {Text}%A_LoopField%
    Sleep 10
    SendInput, {End}
    Sleep 10
  }
  Sleep, 20

  SendInput, {Enter}

  set_input_method(originalLocaleID)  ; 恢复原始输入法
return

; 新增的凭证设置处理程序
SetCredentialsHandler:
  ; 获取当前用户名
  InputBox, NewUser, 用户名设置, 请输入新的用户名: ,, 300, 150,,,,, %Username%
  if ErrorLevel  ; 用户取消
    return

  ; 获取当前密码
  InputBox, NewPass, 密码设置, 请输入新的密码: ,, 300, 150,,,,, %Password%
  if ErrorLevel  ; 用户取消
    return

  ; 更新配置
  Username := NewUser
  Password := NewPass
  IniWrite, %Username%, %configPath%, Credentials, Username
  IniWrite, %Password%, %configPath%, Credentials, Password

  TrayTip, 配置已更新, 用户名和密码已保存, 1, 1
return

; 更改热键处理程序
ChangeHotkeyHandler:
  InputBox, NewHotkey, 更改热键, 请输入新的快捷键组合: ,, 300, 150,,,,, %CurrentHotkey%
  if ErrorLevel  ; 用户取消
    return

  ; 尝试验证新热键
  try {
    Hotkey, %NewHotkey%, TempValidateHotkey, On
    Hotkey, %NewHotkey%, TempValidateHotkey, Off
  } catch {
    MsgBox, 4112, 错误, 无效的热键组合: %NewHotkey%
    return
  }

  ; 更新热键绑定
  Hotkey, %CurrentHotkey%, Off  ; 禁用旧热键
  CurrentHotkey := NewHotkey
  Hotkey, %CurrentHotkey%, LoginProcedure, On  ; 启用新热键

  ; 更新配置和提示
  IniWrite, %CurrentHotkey%, %configPath%, Settings, Hotkey
  Menu, Tray, Tip, 自动登录脚本`n当前热键: %CurrentHotkey%
  TrayTip, 热键已更新, 新热键: %CurrentHotkey%, 1, 1
return

TempValidateHotkey:
return

; 退出脚本
ExitScriptHandler:
ExitApp
return
