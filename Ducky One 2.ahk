#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; {{{1 Global

SetCapsLockState, AlwaysOff
SetNumLockState, AlwaysOn
SetScrollLockState, AlwaysOff

ModeRatingOn := False
ModeRatingSet(ModeRatingOn)

#z::Reload

; {{{2 Functions

; Sends the F-key corresponding to the "set track rating" action in f2k.
; Can be passed -1 to undo the most recent rating.
; Prerequisites:
;   F2K
;   * Format for the window title must end with "<%rating%>"
;   * Keys F20-F24 should be bound to set track rating 1-5, respectively
;   * Key F19 should be bound to unset track rating
RatingModeRate(rating) {
    key := NhtKey_StripKeyModifiers(A_ThisHotkey)
    
    global ModeRatingOn
    static last_rating := -1

    if (rating == -1) {
        if (last_rating >= 0) 
            rating := last_rating 
        else 
            return
    }

    shifted := 19 + rating
    shifted = F%shifted%

    if (ModeRatingOn) {
        foobar := WinExist("ahk_exe foobar2000.exe")
        if (foobar) {
            WinGetTitle, foobar_title, ahk_id %foobar%,,,
            last_rating := RegExReplace(foobar_title, "^.*<([1-5?])>[[:space:]]+\[foobar2000\]$", "$1")
            if (last_rating == "?")
                last_rating := 0
        }
        send {%shifted%}
    } else 
        send {%key%}
}

ModeRatingSet(val) {
    global ModeRatingOn
    ModeRatingOn := val
    if (ModeRatingOn) 
        Menu, Tray, Icon, %A_ScriptDir%\res\star-full.ico,,1
    else 
        Menu, Tray, Icon, %A_ScriptDir%\res\star-hollow.ico,,1
}

; {{{1 Keybindings

; {{{2 Basic

Volume_Mute::Media_Prev
Volume_Down::Media_Play_Pause
Volume_Up::Media_Next

; {{{2 Scripted

Launch_App2::ModeRatingSet(not ModeRatingOn)
+Launch_App2::ModeRatingSet(True)
^Launch_App2::ModeRatingSet(False)

$F9::RatingModeRate(1)
$F10::RatingModeRate(2)
$F11::RatingModeRate(3)
$F12::RatingModeRate(4)
$PrintScreen::RatingModeRate(5)

$^F9::RatingModeRate(0)
$^PrintScreen::RatingModeRate(-1)

; {{{2 Window-specific

; Anki numpad control
#IfWinActive ahk_exe anki.exe
Numpad0::^z   ; Undo
NumpadDot::r  ; Play audio
Numpad5::!    ; Suspend
Numpad6::=    ; Bury
#IfWinActive

; vim: fdm=marker:
