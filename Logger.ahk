#Requires AutoHotkey v2.0
; #SingleInstance force
; Persistent

class Logger {
    static maxItem := 15
    static items := Array()

    static displayToolTips(items){
        content := ""
        For i, item in items{
            item := items[items.Length - i + 1]
            content := content . this.toString(item) . "`n"
        }
    
        ToolTip(content)
    }

    static log(item){
        if (this.items.Length >= this.maxItem) {
            this.items.Pop()
        }

        this.items.InsertAt(1, item)
        this.displayToolTips(this.items)
    }

    static logArray(name, arr){
        out := name . ": ["

        for i, item in arr {
            out := out . item . ", "
        }

        out := SubStr(out, 1, StrLen(out) - 2)
        out := out . "]"
        this.log(out)
    }

    static logKey(name, map){
        out := name . ": {"

        for key, value in map {
            out := out . key . ", "
        }

        out := SubStr(out, 1, StrLen(out) - 2)
        out := out . "}"
        this.log(out)
    }

    static toString(item, depth:=3, indent:="") {
        result := ""
        if (IsObject(item)) {
            for key, value in item {
                result .= "  " . indent . key
                if (IsObject(value) && depth > 1) {
                    result .= "`n" . this.toString(value, depth - 1, indent . "  ") . "`n"
                }
                else {
                    result .= " = " . value . "`n"
                }
            }
        }
        else {
            result := item
        }
        return result
    }

    static compactAndjoinArray(separator, arr){
        out := ""
        for i, item in arr {
            if(item != ''){
                out := out . item . separator
            }
        }

        out := SubStr(out, 1, StrLen(out) - StrLen(separator))
        return out
    }
}

