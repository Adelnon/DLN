global Version := "1.0.0"

#Requires AutoHotkey v2.0

Transparency() {
    SendEvent "{Escape}"
    Sleep(1000)
    SendEvent "{Tab}"
    Sleep(500)
    loop(30) {
        SendEvent "{Up}"
        Sleep(50)
    }
    loop(11) {
        SendEvent "{Down}"
        Sleep(50)
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