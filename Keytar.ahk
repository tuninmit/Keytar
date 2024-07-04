#Requires AutoHotkey v2.0
#SingleInstance force

#include AHKv2\Lib\AutoHotInterception.ahk
#Include ./ChordSelector.ahk
#Include ./KeyMapper.ahk

SetNumLockState("AlwaysOn")
SendMode("Input") ; Recommended for new scripts due to its superior speed and reliability.
Persistent()

global KEYTAR_MODE := 1
global KEYPI_MODE := 0
global mode := KEYTAR_MODE


;Initialize the library
global AHI := AutoHotInterception()

keyboardID := 1
AHI.SubscribeKeyboard(keyboardID, true, keyboardEvent)
; AHI.SubscribeMouseButtons(mouse, true, mouseButtonEvent)

global KeyMapper1 := KeyMapper()
global ChordSelector1 := ChordSelector(KeyMapper1)

;MX Key S exclusive mapping
'::keyboardEvent(329, 1)    ;PgUp
' up::keyboardEvent(329, 0)
/::keyboardEvent(337, 1)    ;PgDn
/ up::keyboardEvent(337, 0)
=::keyboardEvent(327, 1)    ;Home
= up::keyboardEvent(327, 0)
]::keyboardEvent(335, 1)    ;End
] up::keyboardEvent(335, 0)
Delete:: keyboardEvent(339, 1)  ;Delete
Delete up:: keyboardEvent(339, 0)


global x := -1 ;đánh dấu dây không đánh


;------------------------runtime data------------------------
global keysState := Map()
global keysDown := Map()
keysState.Default := 0

global currentChord := "Non"

global logs := ""

;------------------------Keytar logic------------------------
keyboardEvent(code, state){
    global keysState, ChordSelector1, KeyMapper1, mode, KEYPI_MODE


    if(mode = KEYPI_MODE){
        processKeyPi(code, state)
        return
    }

    KN := getKey(code)

    if (keysState.Get(KN) = state){
        return
    }
    keysState.Set(KN, state)
    updateKeysDown(KN, state)

    If (KeyMapper1.isLeftHandKey(KN)){
        Logger.log('----------------------')
        processChord(KN, state)
    }Else{
        processPlay(KN, state)
    }
}

updateKeysDown(KN, state){
    global keysDown

    if (state = 1){
        keysDown.Set(KN, 1)
    }else{
        keysDown.Delete(KN)
    }
}

processChord(KN, newState){
    global ChordSelector1, keysState, currentChord

    newChord := ChordSelector1.findChord(keysDown)
    ;???

    currentChord := newChord

    Logger.log("currentChord " currentChord)
}

processPlay(KN, state){
    global currentChord

    stringIndex := KeyMapper1.playKeys.Get(KN)
    If (stringIndex = -1){
        return
    }

    plug(currentChord, stringIndex, state)    
}

;------------------------Hyper Action------------------------
processKeyPi(code, state){
    AHI.SendKeyEvent(keyboardID, code, state)
}

plug(chordName, stringIndex, state){
    global KeyMapper1

    leftHand := 0
    string := KeyMapper1.strings[stringIndex]
    If (chordName != "Non"){
        chord := ChordSelector1.getChord(chordName)
        leftHand := chord[stringIndex]
    }Else{
        leftHand := findLeftHandHold(string)
    }

    If (leftHand = -1){
        return
    }

    KN := string[leftHand + 1]
    ; ToolTip("plug string " stringIndex " - " leftHand)

    press(KN, state)
}





;------------------------Simple Action------------------------
press(KN, state){
    AHI.SendKeyEvent(keyboardID, GetKeySC(KN), state)
}

findLeftHandHold(string){
    global keysState

    Loop string.Length{
        i := string.Length - A_Index + 1
        KN := string[i]
        If (keysState.Get(KN) = 1 && i != 1){
            ; updateTooltip("Holding " key)

            return i
        }
    }

    return -1
}

;------------------------Mấy hàm hiển thị/trợ giúp------------------------
getKey(code){
    return GetKeyName("sc" Format("{:X}",code))
}

indexOf(array, item){
    Loop array.Length
        If (array[A_Index] = item){
            Return A_Index
        }

    Return -1
}









