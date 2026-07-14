global Version := "1.0.4"

#Requires AutoHotkey v2.0

global ScriptDir := ""
SplitPath(A_LineFile, , &ScriptDir)

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

Disconnect(MainScriptName) {
    if ImageSearch(&x, &y, 0, 0, 816, 638, "*20 " ScriptDir "\Images\Disconnect.png") {
        return MainScriptName()
    }
}