global Version := "1.0.0"

#Requires AutoHotkey v2.0

Unfullscreen() {
    activeWin := "A"
    if !WinExist(activeWin)
        return

    ; 1. Get active window position and size
    WinGetPos(&X, &Y, &W, &H, activeWin)

    ; 2. Check if the window matches the exact dimensions of the monitor it's on
    ; (This handles multiple monitors correctly)
    monitorIndex := MonitorGetPrimary()
    try monitorIndex := MonitorGetFromWindow(activeWin)
    MonitorGet(monitorIndex, &Left, &Top, &Right, &Bottom)
    
    monW := Right - Left
    monH := Bottom - Top

    ; 3. IF it matches screen dimensions, it's fullscreen. Turn it off.
    if (W == monW && H == monH) {
        ; Standard Windows Unmaximize
        WinRestore(activeWin)
        
        ; Force put the borders/title bar back in case it's a borderless window
        WinSetStyle("+0xC40000", activeWin) 
        
        ; Resize it to 80% of the screen so it's safely windowed
        newW := monW * 0.8
        newH := monH * 0.8
        newX := Left + (monW - newW) / 2
        newY := Top + (monH - newH) / 2
        
        WinMove(newX, newY, newW, newH, activeWin)
    }
}

; Helper function to find which monitor a window is currently on
MonitorGetFromWindow(hwnd) {
    monitorCount := MonitorGetCount()
    WinGetPos(&X, &Y, &W, &H, hwnd)
    winCX := X + W/2
    winCY := Y + H/2
    
    Loop monitorCount {
        MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
        if (winCX >= Left && winCX <= Right && winCY >= Top && winCY <= Bottom)
            return A_Index
    }
    return MonitorGetPrimary()
}

Resize() {
    WinWait("ahk_exe RobloxPlayerBeta.exe")
    Unfullscreen()
    WinMaximize("ahk_exe RobloxPlayerBeta.exe")
    Sleep(5000)
	WinMove(0,0,816,638,"ahk_exe RobloxPlayerBeta.exe")
    WinActivate("ahk_exe RobloxPlayerBeta.exe")
    WinGetPos(&wX, &wY, &wW, &wH, "ahk_exe RobloxPlayerBeta.exe")
    WinActivate("ahk_exe AutoHotkey64.exe")
    WinMove(wX+816,wY,,,"ahk_exe AutoHotkey64.exe")
    WinActivate("ahk_exe RobloxPlayerBeta.exe")
}