global Version := "1.0.0"

#Requires AutoHotkey 2.0.0
#SingleInstance Force
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
#Include ..\Extras\Webhooks.ahk
#Include ..\Extras\JoinRBX.ahk
#Include ..\Extras\Resize.ahk
#Include ..\Extras\Menus.ahk

Create() {
    try {
        if !DirExist(A_MyDocuments "\DLN\Settings") {
            DirCreate(A_MyDocuments "\DLN\Settings")
        }
        if !FileExist(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini") {
            FileAppend("", A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini")
        }
    }
}

global ExeWindow := "RobloxPlayerBeta"
global SleepTillLoop := 900000
global PositionBehindWindow := true
global AutoReconnect := false
global XPos := 800
global YPos := 600
global PosActive := false
global Color := "0x000000"
global ColorActive := false

LoadSettings()

MainGUI := GUI()

MainGUI.AddText("w150 h20 xs y5", "ExeWindow:").SetFont("s10")
MainGUI.AddEdit("w120 h20 yp xp+155 vExeWindow", ExeWindow).OnEvent("Change", Func1)
Func1(ctrl, info) {
    global ExeWindow := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "ExeWindow")
}

MainGUI.AddText("w150 h20 xs", "SleepTillLoop:").SetFont("s10")
MainGUI.AddEdit("w120 h20 yp xp+155 vSleepTillLoop", SleepTillLoop).OnEvent("Change", Func2)
Func2(ctrl, info) {
    global SleepTillLoop := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "SleepTillLoop")
}

MainGUI.AddText("w150 h20 xs", "ClickPosition:").SetFont("s10")
MainGUI.AddEdit("w50 h20 yp xp+155 vXPos", XPos).OnEvent("Change", Func3)
Func3(ctrl, info) {
    global XPos := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "XPos")
}

MainGUI.AddEdit("w50 h20 yp xp+50 vYPos", YPos).OnEvent("Change", Func4)
Func4(ctrl, info) {
    global YPos := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "YPos")
}
MainGUI.AddCheckBox("w20 h20 yp xp+55 vPosActive Checked" PosActive).OnEvent("Click", Func5)
Func5(ctrl, info) {
    global PosActive := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "PosActive")
}

MainGUI.AddText("w150 h20 xs", "OnlyClickColor:").SetFont("s10")
MainGUI.AddEdit("w100 h20 yp xp+155 vColor", Color).OnEvent("Change", Func6)
Func6(ctrl, info) {
    global Color := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "Color")
}
MainGUI.AddCheckBox("w20 h20 yp xp+105 vColorActive Checked" ColorActive).OnEvent("Click", Func7)
Func7(ctrl, info) {
    global ColorActive := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "ColorActive")
}

MainGUI.AddText("w150 h20 xs", "PositionBehindWindow:").SetFont("s10")
MainGUI.AddCheckBox("w20 h20 yp xp+260 vPositionBehindWindow Checked" PositionBehindWindow).OnEvent("Click", Func8)
Func8(ctrl, info) {
    global PositionBehindWindow := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "PositionBehindWindow")
}

MainGUI.AddText("w150 h20 xs", "AutoReconnect:").SetFont("s10")
MainGUI.AddCheckBox("w20 h20 yp xp+260 vAutoReconnect Checked" AutoReconnect).OnEvent("Click", Func9)
Func9(ctrl, info) {
    global AutoReconnect := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "AutoReconnect")
}

MainGUI.AddText("w200 h20 x10 y+5 Section", "Controls").SetFont("s12 w700")
MainGUI.AddText("w150 h15 xs", "F1 = Start").SetFont("s10")
MainGUI.AddText("w150 h15 xs", "F2 = Pause/Continue").SetFont("s10")
MainGUI.AddText("w150 h15 xs", "F3 = Stop").SetFont("s10")

MainGUI.OnEvent("Close", (*) => ExitApp())

MainGUI.Show("AutoSize Center")

Reconnect() {
    if AutoReconnect = 1 {
        if PixelSearch(&eX,&eY,280,370,280,370,"0x393b3d",0) and PixelSearch(&mX,&mY,450,420,450,420,"0xffffff",0) {
            loop {
                if PixelSearch(&eX,&eY,280,370,280,370,"0x393b3d",0) and PixelSearch(&mX,&mY,450,420,450,420,"0xffffff",0) {
                    Click(mX,mY)
                    Click(mX-1,mY-1)
                } else {
                    loop {
                        if PixelSearch(&mX,&mY,150,380,150,380,"0xffffff",0) {
                            Sleep(20000)
                            break(2)
                        }
                    }
                }
            }
        }
    }
}

AntiAFK() {
    loop {
        Window := WinGetID("A")
        IDs:= WinGetList("ahk_exe " ExeWindow.Value ".exe")
        WinGetPos(&cX,&cY,,,"A")
        For ID in IDs {
            WinActivate("ahk_id " ID)
            if AutoReconnect = 1 {
                WinMove(,,816,638,"ahk_id " ID)
            }
            if PositionBehindWindow = 1 {
                WinMove(cX,cY,,,"ahk_id " ID)
            }
            Reconnect()
            SendEvent "{Click, 408, 40}"
        }
        WinActivate(Window)
        Sleep(SleepTillLoop.Value)
    }
}

LoadSettings() {
    if FileExist(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini") {
        try {
            global ExeWindow := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "ExeWindow")
        }
        try {
            global SleepTillLoop := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "SleepTillLoop")
        }
        try {
            global XPos := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "XPos")
        }
        try {
            global YPos := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "YPos")
        }
        try {
            global PosActive := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "PosActive")
        }
        try {
            global Color := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "Color")
        }
        try {
            global ColorActive := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "ColorActive")
        }
        try {
            global AutoReconnect := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "AutoReconnect")
        }
        try {
            global PositionBehindWindow := IniRead(A_MyDocuments "\DLN\Settings\AntiAFKSettings.ini", "AntiAFK", "PositionBehindWindow")
        }
    }
}

F1::AntiAFK()
F2::Pause -1
F3::ExitApp()