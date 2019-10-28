; Customizations for my Ducky One 2 fullsize keyboard.
; Keys set here:
;   [^+]Calculator: [enable, disable, toggle] the rating mode.
;   F9-F12, PrintScr: (when in rating mode) Set track rating 1-5.
;   ^F9: (when in rating mode) Remove song rating.
;   ^PrintScr: (when in rating mode) Undo song rating.
;   
;   VolumeMute: Previous song.
;   VolumeDown: Play/Pause.
;   VolumeUp: Next song.
;   +Volume[Mute,Up,Down]: Original volume button function.

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
;   * Format for the window title must begin with "<%rating%>"
;   * Keys F20-F24 should be bound to set track rating 1-5, respectively
;   * Key F19 should be bound to unset track rating
RatingModeRate(rating) {
    key := ZachKey_StripKeyModifiers(A_ThisHotkey)

    if (not ModeRatingOn) {
        send {%A_ThisHotkey%}
        return
    }
    
    global ModeRatingOn
    static last_rating := -1
    static last_rating_title := ""

    foobar := WinExist("ahk_exe foobar2000.exe")

    if (rating == -1) {
        ; Undo the last-made rating for this song.
        if (foobar) {
            ; First make sure it's the same song so we don't undo back to another song's rating.
            WinGetTitle, foobar_title, ahk_id %foobar%,,,
            current_title := RegExReplace(foobar_title, "^(.*)<[1-5?]>[[:space:]]+\[foobar2000\]$", "$1")
            if (current_title != last_rating_title)
                return
        }
        if (last_rating >= 0)
            rating := last_rating 
        return
    } else {
        ; If we have a zero or positive rating, set the song's rating to that.
        shifted := 19 + rating
        shifted = F%shifted%

        if (foobar) {
            ; Get the currently playing track and its rating from the f2k titlebar string.
            WinGetTitle, foobar_title, ahk_id %foobar%,,,
            last_rating := RegExReplace(foobar_title, "^.*<([1-5?])>[[:space:]]+\[foobar2000\]$", "$1")
            last_rating_title := RegExReplace(foobar_title, "^(.*)<[1-5?]>[[:space:]]+\[foobar2000\]$", "$1")
            if (last_rating == "?")
                last_rating := 0
        }
        send {%shifted%}
    }
}

; Enable or disable ModeRating.
ModeRatingSet(val) {
    global ModeRatingOn
    ModeRatingOn := val
    if (ModeRatingOn) {
        Menu, Tray, Icon, %A_ScriptDir%/res/star-full.ico,,1
        SoundPlay, %A_ScriptDir%/Res/Sounds/on.wav
    } else  {
        Menu, Tray, Icon, %A_ScriptDir%/res/star-hollow.ico,,1
        SoundPlay, %A_ScriptDir%/Res/Sounds/off.wav
    }
}

; {{{1 Keybindings

; {{{2 Basic

$Volume_Mute::Media_Prev
$Volume_Down::Media_Play_Pause
$Volume_Up::Media_Next

+Volume_Mute::Volume_Mute
+Volume_Down::Volume_Down
+Volume_Up::Volume_Up

; {{{2 Scripted

; Keys:
;   F9-F12, PrintScr: (when in rating mode) Set track rating 1-5.
;   ^F9: (when in rating mode) Remove song rating.
;   ^PrintScr: (when in rating mode) Undo song rating.

; Toggle or set rating mode.
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

; vim: fdm=marker: