; Helper functions for making keybinds.

ZachKey_StripKeyModifiers(KeyString) {
    return RegExReplace(KeyString, "A)[^[:word:]]")
}