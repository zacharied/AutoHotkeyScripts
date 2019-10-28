; Use a foot pedal to control visual novels.
; There must be a file in <ScriptDir>/Res/vnlist.txt containing a
; newline-separated list of executable names to be searched by
; AHK when a foot pedal input is received.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include <AhkPedal/AhkPedal>

Menu, Tray, Icon, %A_ScriptDir%/Res/foot.ico

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
            ; Every application behaves a little bit differently when it comes
            ; to interpreting keystrokes. ControlSend is the ideal approach
            ; here since we wouldn't have to even focus the window, but this
            ; is not a perfect world and many apps won't accept input from
            ; ControlSend (hell, some won't even when they *are* focused).
            ; So, we decided to go with the unga bunga "focus and send" direct
            ; approach, as it seems to have the most compatibility.
            WinGetActiveTitle, currentWin
            WinActivate, ahk_id %win%
            Send {Enter down}
            Sleep 30
            Send {Enter up}
            WinActivate, %currentWin%
            didSend := True
        }
    }
    if (not didSend) {
        SoundPlay, %A_ScriptDir%/Res/sounds/click5.wav
    }
}

SendBreak() {
    Send {Pause}
}

SendEsc() {
    Send {Escape}
}