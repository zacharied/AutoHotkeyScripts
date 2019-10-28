#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#IfWinActive ahk_class FFXIVGAME
; Anti-RSI binding for right-click context menus.
; Not currently functioning.
NumpadMult::
{
    Click, right
    MouseMove, 10, 10, 0, Relative
    Sleep, 1000
    Send {LButton Down}
    Send {LButton Up}
}