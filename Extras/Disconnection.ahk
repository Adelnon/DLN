global Version := "1.0.2"

#Requires AutoHotkey v2.0

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

Disconnect(MainScriptName) {
    if ImageSearch(&x, &y, 0, 0, 816, 638, "*20 ..\Extras\Images\Disconnect.png") {
        return(MainScriptName())
    }
}