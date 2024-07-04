#Requires AutoHotkey v2.0
#Include ./Logger.ahk
; #SingleInstance force
; Persistent


Class ChordSelector{
    KeyMapper1 := {}

    midi_ChordInterval := Map(
        "04", "",       ;Major
        "03", "m",      ;minor
        "0411", "maj7",    ;Major maj7
        "0410", "7",    ;Major 7
        
        "0311", "m maj7",    ;minor maj7
        "0310", "m 7",    ;minor 7

        "02", "sus2",

        "07","",
        "06","m"
    )

    chord_Positions := Map()

    __New(KeyMapper1) {
        this.KeyMapper1 := KeyMapper1

        x := -1

        this.quickKey_chord := Map(
            "x a", "C",

            "q", "D",
            "q Escape", "Dm",

            "z Tab", "E",
            "z", "Em",

            "x s", "F",
            "x s", "F",
            "c d", "F#m",
            "s q", "Fmaj7",

            "LAlt z", "G",
            "LAlt v", "Gm",

            "a", "A",
            "a q", "Asus2",
            "a q 1", "Am",
            "a 1", "Am",
            ; "", "A7",

            ; "", "B7",
            ; "", "Bm7",
            "LShift s", "Bb",

        )
        this.quickKey_chord.Default := "?"

    
        this.chord_Positions := Map(
            "C",    [x, 3, 2, 0, 1, 0],     ;X A - 1 -
            "D",    [x, x, 0, 2, 3, 2],    ; . - Q 3 f1
            "Dm",    [x, x, 0, 2, 3, 1],     ;. - Q 3 e
            "E",    [0, 2, 2, 1, 0, 0],     ;Z A t - -
            "Em",   [0, 2, 2, 0, 0, 0],     ;Z A - - -
            "F",    [1, 3, 3, 2, 1, 1], ;ctl;X S Q 1 e
            "F#m",  [2, 4, 4, 2, 2, 2], ;win;C D Q 2 f1
        "Fmaj7",    [x, x, 3, 2, 1, 0],     ;. S Q 1 -
            "G",    [3, 2, 0, 0, 3, 3], ;alt;Z - - - f2
            "Gm",   [3, 5, 5, 3, 3, 3], ;alt;V F W 3 f2
            "A",    [x, 0, 2, 2, 2, 0],     ;- A Q 2 -
           "Asus2", [x, 0, 2, 2, 0, 0],     ;- A Q - -
            "Am",   [x, 0, 2, 2, 1, 0],     ;-  A Q 1 -
            "A7",  [x, 0, 2, 0, 2, 0],     ;
            "B7",  [x, 2, 1, 2, 0, 2],     ;
            "Bm7",  [x, 2, 0, 2, 3, 0],     ;. D Q 3 f1   Bm mở
            "Bb",   [x, 1, 3, 3, 3, 1],      ;s S W 3 e
        )
        this.chord_Positions.Default := [0, 0, 0, 0, 0, 0]
        this.midi_ChordInterval.Default := "?"
    }


    getChord(chordName){
        return this.chord_Positions.Get(chordName)
    }

    findChord(keysDown){
        Logger.logKey("keysDown", keysDown)

        ;cách nhanh, đơn giản là hard-code tổ hợp key nào là chord nào
        keyDownEachString := this.getKeyDownPerString(keysDown)
        Logger.logArray('keyDownEachString', keyDownEachString)
        quickKey := Logger.compactAndjoinArray(' ', keyDownEachString)
        Logger.log('quickKey:"' . quickKey . '"')
        posibleChordName := this.quickKey_chord.Get(quickKey)
        Logger.log('quick posibleChordName: ' . posibleChordName)
        if (posibleChordName != '?'){
            return posibleChordName
        }


        midiDownEachString := this.KeyMapper1.getMidis(keyDownEachString)
        Logger.logArray('midiDownEachString', midiDownEachString)

        compactMidiDown := Array()
        for i, midi in midiDownEachString{
            if (midi != ''){
                compactMidiDown.Push(midi)
            }
        }
        Logger.logArray('compactMidiDown', compactMidiDown)

        if(compactMidiDown.Length = 0){
            return "Non"
        }

        chordName := this.sortedMidiDownToChordName(compactMidiDown)
        if (SubStr(chordName, -1) = '?'){
            posibleChordName := this.findAWayOut(midiDownEachString, compactMidiDown)
            if (posibleChordName != ''){
                chordName := posibleChordName
            }
        }

        return chordName
    }

    getMidiDownPerString(keysDown){
        midiDownEachString := ['', '', '', '', '', '']

        for KN, value in keysDown{
            stringIndex := this.KeyMapper1.leftHand_stringIndex.Get(KN)
            if (stringIndex >= 1){
                midiPrev := midiDownEachString[stringIndex]

                midiNext := this.KeyMapper1.getMidi(KN)
                if (midiPrev = '' || midiPrev < midiNext){
                    midiDownEachString[stringIndex] := midiNext
                }
            }
        }

        return midiDownEachString
    }
    getKeyDownPerString(keysDown){
        midiDownEachString := ['', '', '', '', '', '']
        keyDownEachString := ['', '', '', '', '', '']

        for KN, value in keysDown{
            stringIndex := this.KeyMapper1.leftHand_stringIndex.Get(KN)
            if (stringIndex >= 1){
                midiPrev := midiDownEachString[stringIndex]

                midiNext := this.KeyMapper1.getMidi(KN)
                if (midiPrev = '' || midiPrev < midiNext){
                    midiDownEachString[stringIndex] := midiNext
                    keyDownEachString[stringIndex] := KN
                }
            }
        }

        return keyDownEachString
    }


    sortedMidiDownToChordName(midiDown){
        rootMidi := midiDown[1]

        nomalizedChordInterval := ''
        for i, midi in midiDown{
            nomalizedChordInterval := nomalizedChordInterval . (midi - rootMidi)
        }
        Logger.log('nomalizedChordInterval ' nomalizedChordInterval)
        chordInterval := this.midi_ChordInterval.Get(nomalizedChordInterval)

        ; ToolTip('nomalizedChordInterval ' nomalizedChordInterval)
        rootNote := this.KeyMapper1.getDisplayNote(rootMidi)
        chordName := rootNote . chordInterval
        return chordName
    }

    findAWayOut(midiDownEachString, compactMidiDown){
    ;√      Em      [0 2 2 0 x x] R5Rm3 => x22xx -> Non
    ;       Fmaj7   [x x 3 2 1 0] R357  => R35

        ; x x 5 x => x 0 5 x
        {
            if (5 < compactMidiDown[1] && compactMidiDown[1] < 20){
                nearestRootMidi := this.createNearestRootMidi(midiDownEachString)
                compactMidiDown.InsertAt(1, nearestRootMidi)
            }

            posibleChordName := this.sortedMidiDownToChordName(compactMidiDown)
            if (SubStr(posibleChordName, -1) != '?'){
                Logger.log('posibleChordName ' posibleChordName)
                return posibleChordName
            }
        }

        ;buông 5 3
        {

        }

        ;chèn dây buông ở giữa

        ;chord reverse


        return ''
    }

    createNearestRootMidi(midiDownEachString){
        idleStringIndex := 1
        for i, midi in midiDownEachString{
            if(midi != ''){
                idleStringIndex := i - 1
                break
            }
        }

        Logger.log('idleStringIndex ' idleStringIndex)
        return this.KeyMapper1.relativeMidiIndex[idleStringIndex]
    }

}



; ChordSelector1 := ChordSelector()
; out := ChordSelector1.midi_ChordInterval.Get(3)

; ToolTip('result: ' out)












