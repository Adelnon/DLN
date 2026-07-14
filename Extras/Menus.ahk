global Version := "1.0.1"

#Requires AutoHotkey v2.0
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

Transparency() {
    SendEvent "{Escape}"
    Sleep(1000)
    SendEvent "{Tab}"
    Sleep(500)
    loop(40) {
        SendEvent "{Up}"
        Sleep(50)
    }
    loop {
        SendEvent "{Down}"
        Sleep(50)
        if PixelSearch(&x, &y, 709, 496, 724, 506, "0xc2c2c3", 2) and PixelSearch(&x, &y, 349, 466, 361, 475, "0xf8f8f8", 2) and PixelSearch(&x, &y, 30, 490, 91, 500, "0xc2c2c3", 2) {
            break()
        }
    }
    loop(10) {
        SendEvent "{Right}"
        Sleep(50)
    }
    SendEvent "{Escape}"
}

ChatClose() {
    if PixelSearch(&x, &y, 140, 59, 140, 59, "0xf4f5f8", 0) {
        SendEvent "{Click, " x ", " y "}"
        Sleep(200)
    }
}
LeaderboardClose() {
    if PixelSearch(&x, &y, 763, 39, 777, 159, "0x121215", 0) and PixelSearch(&x, &y, 763, 39, 777, 159, "0xf7f7f8", 2) {
        SendEvent "{Tab}"
        Sleep(200)
    }
}

Menus() {
    Transparency()
    Sleep(1000)
    ChatClose()
    LeaderboardClose()
}