; Use a foot pedal to control visual novels.
; There must be a file in <ScriptDir>/Res/vnlist.txt containing a
; newline-separated list of executable names to be searched by
; AHK when a foot pedal input is received.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include <AhkPedal/AhkPedal>

Menu, Tray, Icon, Res/foot.ico

VnList := GetVns()

pedal := new AhkPedal(allowRelease:=false)
pedal.SetHandler(0, onPress:="SendBreak")
pedal.SetHandler(1, onPress:="SendEsc")
pedal.SetHandler(2, onPress:="NextLine")

GetVns() {
    file := FileOpen(A_ScriptDir . "/Res/vnlist.txt", "r")
    if (not file) {
        MsgBox % "VN list file not found. The line advance button will not work."
        return
    }

    out := StrSplit(file.Read(), "`n")
    file.Close()

    return out
}

NextLine() {
    global VnList
    didSend := False
    for i in VnList {
        win := WinExist("ahk_exe" . VnList[i])
        if (win) {
            WinGetActiveTitle, currentWin
            WinActivate, ahk_id %win%
            ControlSend, , {Enter}, ahk_id %win%
            WinActivate, %currentWin%
            didSend := True
        }
    }
    if (not didSend) {
        SoundPlay, Res/sounds/click5.wav
    }
}

SendBreak() {
    Send {Pause}
}

SendEsc() {
    Send {Escape}
}