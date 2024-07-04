#Requires AutoHotkey v2.0
#Include ./Logger.ahk
; #SingleInstance force
; Persistent

class KeyMapper{
    x := -1
    NOTE_DISPLAY := ['E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B', 'C', 'C#', 'D', 'D#']

    key_Midi := Map()
    leftHand_stringIndex := Map()
    midi_stringIndex := Map()


    strings := [
        ["NumpadDel", "LControl", "LWin", "LAlt", "RAlt", "RControl"],
        ["NumpadPgDn", "LShift", "z","x","c","v","b","n","m",",",".","/"],
        ["NumpadRight", "CapsLock", "a","s","d","f","g","h","j","k","l",";"],
        ["NumpadPgUp", "Tab", "q","w","e","r","t","y","u","i","o","p","[","]"],
        ["NumpadMult", "1", "2","3","4","5","6","7","8","9","0","-","="],
        ["PgUp", "Escape", "F1","F2","F3", "F4","F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"],
    ]
    relativeMidiIndex := [0, 5, 10, 15, 19, 24]

    playKeys := Map(
        "NumpadDel", 1, "NumpadIns", 1,
        "NumpadEnd", 2, "NumpadDown", 2, "NumpadPgDn", 2,
        "NumpadRight", 3, "NumpadClear", 3, "NumpadLeft", 3,
        "NumpadHome", 4, "NumpadUp", 4, "NumpadPgUp", 4,
        "Numlock", 5, "NumpadDiv", 5, "NumpadMult", 5,
        "Home", 6, "End", 6, "PgUp", 6,
    )
    playKeys.Default := -1
    ; playKeys := Map(
    ;     "NumpadIns", 1,
    ;     "NumpadDel", 2,
    ;     "NumpadEnd", 3, "NumpadDown", 3, "NumpadPgDn", 3,
    ;     "NumpadRight", 4, "NumpadClear", 4, "NumpadRight", 4,
    ;     "NumpadHome", 5, "NumpadUp", 5, "NumpadPgUp", 5,
    ;     "NumLock", 6, "NumpadDiv", 6, "NumpadMult", 6,
    ; )

    __New() {
        this.leftHand_stringIndex.Default := -1

        For i, string in this.strings {
            stringIndex := i
            startMidiIndex := this.relativeMidiIndex[i]

            For j, KN in string{
                midi := startMidiIndex + j - 1
                this.key_Midi.Set(KN, midi)
                this.midi_stringIndex.Set(midi, stringIndex)

                if (j > 1){
                    this.leftHand_stringIndex.Set(KN, stringIndex)
                }
            }
        }
    }
    ;============Checking==============
    isLeftHandKey(KN){
        return this.leftHand_stringIndex.Has(KN)
    }

    ;============Mapping===============
    ;0, 1 => NumpadDel
    mapPositionToKey(position, stringNo){
        if (position )
        return this.strings[stringNo][position + 1]
    }

    ;[3, 2, 0, 0, 3, 3] => ['LAlt', 'z', 'NumpadRight', 'NumpadPgUp', '3', 'F2']
    mapPositionsToKeys(positions){
        keys := ['','','','','','']

        For i, pos in positions{
            if (pos != this.x){
                keys[i] := this.strings[i][pos + 1]
            }
        }

        return keys
    }

    getMidi(KN){
        return this.key_Midi.Get(KN)
    }

    getMidis(keys){
        for i, key in keys{
            if(key != '' && this.key_Midi.Has(key)){
                keys[i] := this.getMidi(key)
            }
        }

        return keys
    }

    getStringIndex(midi){
        return this.midi_stringIndex.Get(midi)
    }

    getDisplayNote(midi){
        return this.NOTE_DISPLAY[Mod(midi, 12) + 1]
    }
}



;------------------------------------Test zone------------------------------------
; strings := [
;     ["NumpadDel", "LControl", "LWin", "LAlt", "RAlt", "RControl"],
;     ["NumpadPgDn", "LShift", "z","x","c","v","b","n","m",",",".","/"],
;     ["NumpadRight", "CapsLock", "a","s","d","f","g","h","j","k","l",";"],
;     ["NumpadPgUp", "Tab", "q","w","e","r","t","y","u","i","o","p","[","]"],
;     ["NumpadMult", "1", "2","3","4","5","6","7","8","9","0","-","="],
;     ["PgUp", "Escape", "F1","F2","F3", "F4","F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"],
; ]
; KeyMapper1 := KeyMapper()

; out := KeyMapper1.isLeftHandKey('NumpadIns')

; midi := KeyMapper1.getMidi('F1')
; out := KeyMapper1.getDisplayNote(midi)

; keys := KeyMapper1.mapPositionsToKeys([3, 2, 0, 0, 3, 3])
; out:=""
; for k, v in keys
    ; out .= v . ' '

; out := KeyMapper1.mapPositionToKey(0, 1)


; ToolTip('result: ' out)