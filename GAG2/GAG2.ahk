global Version := "1.0.0"

#Requires AutoHotkey 2.0.0
#SingleInstance Force
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"

; EXTERNAL STUFF

#Include GAG2Maps.ahk
#Include ..\Extras\Webhooks.ahk
#Include ..\Extras\JoinRBX.ahk
#Include ..\Extras\Resize.ahk
#Include ..\Extras\Menus.ahk

; FILES CREATION

Create() {
    try {
        if !FileExist(A_MyDocuments "\DLN\Settings") {
            DirCreate(A_MyDocuments "\DLN\Settings")
        }
        if !FileExist(A_MyDocuments "\DLN\Settings\GAG2Settings.ini") {
            FileAppend("", A_MyDocuments "\DLN\Settings\GAG2Settings.ini")
        }
    }
}

Create()

; DOWNLOAD JOIN SYSTEM

if FileExist(A_MyDocuments "\DLN\join_rbx.exe") {
    FileDelete(A_MyDocuments "\DLN\join_rbx.exe")
}
Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", A_MyDocuments "\DLN\join_rbx.exe")

; VARIABLES

global DoPlantShop := 1
global DoSell      := 0
global DoGearShop  := 0
global Webhook     := ""
global Private     := ""

global Position    := "Garden"

; HOTKEYS

global StartKey    := "F1"
global PauseKey    := "F2"
global StopKey     := "F3"

; LOAD FILE

Load() {
    for Plant in Plants {
        try {
            Plant.Value    := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Plants", Plant.Name)
        }
    }
    for Gear in Gears {
        try {
            Gear.Value     := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Gears", Gear.Name)
        }
    }

    try {
        global DoPlantShop  := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoPlantShop")
    }

    try {
        global DoGearShop   := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoGearShop")
    }
    
    try {
        global DoSell       := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoSell")
    }

    try {
        global Webhook      := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Externals", "Webhook")
        global Private      := IniRead(A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Externals", "Private")
    }
}


Load()

; GUI STUFF

Main := Gui("+AlwaysOnTop")
Main.Title := "Grow A Garden 2 Macro"

; TOGGLES

Main.AddGroupBox("w100 h125 xs y+5", "Toggles").SetFont("s9")

Main.AddText("w90 h20 xp+2 yp+15","Plant Shop").SetFont("s8")
Main.AddCheckbox("w20 h20 xp+5 yp+15 vDoPlantShop Checked" DoPlantShop).OnEvent("Click", Func1)
Func1(ctrl, info) {
    global DoPlantShop := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoPlantShop")
}
Main.AddButton("Default w70 h20 xp+20 yp", "Settings").OnEvent("Click", PlantShopShow)
PlantShopShow(*) {
    PlantShop.Show()
}

Main.AddText("w90 h20 xp-25 yp+20","Gear Shop").SetFont("s8")
Main.AddCheckbox("w20 h20 xp+5 yp+15 vDoGearShop Checked" DoGearShop).OnEvent("Click", Func2)
Func2(ctrl, info) {
    global DoGearShop := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoGearShop")
}
Main.AddButton("Default w70 h20 xp+20 yp", "Settings").OnEvent("Click", GearShopShow)
GearShopShow(*) {
    GearShop.Show()
}

Main.AddText("w90 h20 xp-25 yp+20","Sell Plants").SetFont("s8")
Main.AddCheckbox("w20 h20 xp+5 yp+15 vDoSell Disabled Checked" DoSell).OnEvent("Click", Func3)
Func3(ctrl, info) {
    global DoSell := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Variables", "DoSell")
}

; HOTKEYS

Main.AddGroupBox("w80 h65 xs yp+30", "Hotkeys").SetFont("s9")
Main.AddText("w70 h20 xp+2 yp+15","Start Key: " StartKey).SetFont("s8")
Main.AddText("w70 h20 xp yp+15","Pause Key: " PauseKey).SetFont("s8")
Main.AddText("w70 h15 xp yp+15","Stop Key: " StopKey).SetFont("s8")

; EXTERNALS

Main.AddGroupBox("w200 h160 x+35 ys", "Externals").SetFont("s9")
Main.AddText("w90 h20 xp+2 yp+15","Webhook Link").SetFont("s8")
Main.AddEdit("w190 h20 xp+2 yp+15 vWebhook", Webhook).OnEvent("Change", Func4)
Func4(ctrl, info) {
    global Webhook := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Externals", "Webhook")
}

Main.AddText("w90 h20 xp-2 yp+25","Private Server Link").SetFont("s8")

Main.AddEdit("w190 h20 xp+2 yp+15 vPrivate", Private).OnEvent("Change", Func5)
Func5(ctrl, info) {
    global Private := ctrl.Value
    IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Externals", "Private")
}

; SHOW GUI

Main.OnEvent("Close", (*) => ExitApp())
Main.Show()

; PLANT VALUES

PlantShop := Gui("+AlwaysOnTop")

for Plant in Plants {
    try { 
        PlantShop.AddText("w200 h20 xs y+5", Plant.Name).SetFont("s10")
        PlantShop.AddCheckbox("h20 xp+170 v" Plant.Name " Checked" Plant.Value).OnEvent("Click", PlantSaving)
    }
}

PlantSaving(ctrl, info) {
    for Plant in Plants {
        if Plant.Name = ctrl.Name {
            Plant.Value := ctrl.Value
            IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Plants", ctrl.Name)
            break
        }
    }
}

; GEAR VALUES

GearShop := Gui("+AlwaysOnTop")

for Gear in Gears {
    try { 
        GearShop.AddText("w200 h20 xs y+5", Gear.Name).SetFont("s10")
        GearShop.AddCheckbox("h20 xp+170 v" Gear.Name " Checked" Gear.Value).OnEvent("Click", GearSaving)
    }
}

GearSaving(ctrl, info) {
    for Gear in Gears {
        if Gear.Name = ctrl.Name {
            Gear.Value := ctrl.Value
            IniWrite(ctrl.Value, A_MyDocuments "\DLN\Settings\GAG2Settings.ini", "Gears", ctrl.Name)
            break
        }
    }
}

; SCRIPTING

Joining() {
    if (Webhook != "") and (Private != "") {
        JoinGame(97598239454123, Webhook, Private)
    } else if (Webhook != "") {
        JoinGame(97598239454123, Webhook)
    } else if (Private != "") {
        JoinGame(97598239454123,,Private)
    } else {
        JoinGame(97598239454123)
    }
    SendWebhook(Webhook, "Resizing")
    Resize()
    Sleep(5000)
    if ImageSearch(&x, &y, 191, 167, 616, 485, "*20 " A_ScriptDir "\Images\SaveFailed.png") {
        return(MainScript())
    }
    count := 1
    loop {
        Sleep(1000)
        count += 1
        if PixelSearch(&x, &y, 260, 435, 564, 461, "0xffff00", 2) {
            break
        }
        if count = 30 {
            break
        }
    }
    SendEvent "{Click, " x "," y "}"
    Sleep(5000)
    if PixelSearch(&x, &y, 36, 553, 107, 562, "0x000000", 3) and PixelSearch(&x, &y, 799, 45, 745, 80, "0x000000", 3) {
        SendEvent "{Click, " x "," y ", Down}"
        Sleep(3000)
        SendEvent "{Click, " x "," y ", Up}"
        Sleep(1000)
    }
    Menus()
}

MainScript() {
    SendWebhook(Webhook, "Starting")
    Joining()
    loop {
        if DoPlantShop = 1 {
            PlantingScript()
        }
        if DoGearShop = 1 {
            GearingScript()
        }
        if DoSell = 1 {
            SellingScript()
        }
    }
}

; Colors
; Light Scroll Wheel   - bd9f91
; Light Green (Buy)    - 42c100
; Dark Green (Buy)     - 2e8800
; Light Red (No Stock) - df0000
; Dark Red (No Stock)  - 9f0000

PlantingScript() {
    SendWebhook(Webhook, "Starting Plant Buying")
    SendEvent "{Click," Coordinates[2].Value1 "," Coordinates[2].Value2 "}"
    Sleep(200)
    SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
    Sleep(1000)
    SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
    Sleep(200)
    SendEvent "{Right Down}"
    Sleep(1500)
    SendEvent "{Right Up}"
    Sleep(200)
    SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
    Sleep(500)
    global Position := "PlantShop"
    Sleep(200)
    SendEvent "{e}"
    Sleep(2000)
    if PixelSearch(&x, &y, 692, 104, 734, 142, "0xee2927", 5) or PixelSearch(&x, &y, 692, 104, 734, 142, "0xa71b1a", 5) {
        return(MainScript())
    }
    loop {
        SendEvent "{Click," Coordinates[5].Value1 ", 260, 0}"
        SendEvent "{WheelUp}"
        Sleep(50)
        if PixelSearch(&x, &y, 648, 217, 655, 224, "0xbd9f91", 5) {
            break
        }
    }
    SendEvent "{Click," Coordinates[5].Value1 ", 260}"
    for Plant in Plants {
        if PixelSearch(&x, &y, 690, 100, 732, 112, "0xee2523", 5) {
            return(MainScript())
        }
        if PixelSearch(&x, &y, 690, 100, 732, 112, "0xa72d2a", 5) {
            return(MainScript())
        }
        if Plant.Value = 1 {
            SendWebhook(Webhook, "Trying To Buy " Plant.Name)
            count := 1
            loop {
                if PixelSearch(&x, &y, 423, 353, 461, 560, "0x42c100", 5) or PixelSearch(&x, &y, 423, 353, 461, 560, "0x2e8800", 5) {
                    SendWebhook(Webhook, Plant.Name " In Shop; Buying")
                    SendEvent "{Click, " x "," y "}"
                    Sleep(50)
                    count += 1
                    if count = 20 {
                        SendWebhook(Webhook, "Tried Buying 20 Times; Stopped Trying To Buy")
                        break()
                    }
                } else if PixelSearch(&x, &y, 423, 353, 461, 560, "0xdf0000", 5) or PixelSearch(&x, &y, 423, 353, 461, 560, "0x9f0000", 5) {
                    SendWebhook(Webhook, "No Stock")
                    break
                }
            }
        }
        SendEvent "{Click," Coordinates[5].Value1 "," Coordinates[5].Value2 "}"
        Sleep(500)
    }
    SendEvent "{Click," Coordinates[4].Value1 "," Coordinates[4].Value2 "}"
    Sleep(500)
    loop(18) {
        SendEvent "{WheelDown}"
        Sleep(50)
    }
}

SellingScript() {

}

GearingScript() {
    if !Position = "PlantShop" {
        SendEvent "{Click," Coordinates[2].Value1 "," Coordinates[2].Value2 "}"
        Sleep(200)
        SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
        Sleep(1000)
        SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
        Sleep(200)
        SendEvent "{Right Down}"
        Sleep(1500)
        SendEvent "{Right Up}"
        Sleep(200)
        SendEvent "{Click," Coordinates[1].Value1 "," Coordinates[1].Value2 "}"
        Sleep(500)
    }
    SendEvent "{a Down}"
    SendEvent "{s Down}"
    Sleep(1100)
    SendEvent "{a Up}"
    Sleep(500)
    SendEvent "{s Up}"
    global Position := "GearShop"
    Sleep(200)
    SendEvent "{e}"
    Sleep(2000)
    if PixelSearch(&x, &y, 692, 104, 734, 142, "0xee2927", 5) or PixelSearch(&x, &y, 692, 104, 734, 142, "0xa71b1a", 5) {
        return(MainScript())
    }
    loop {
        SendEvent "{Click," Coordinates[5].Value1 ", 260, 0}"
        Sleep(50)
        SendEvent "{WheelUp}"
        Sleep(50)
        if PixelSearch(&x, &y, 648, 217, 655, 224, "0xbd9f91", 5) {
            break
        }
    }
    SendEvent "{Click," Coordinates[5].Value1 ", 260}"
    for Gear in Gears {
        if PixelSearch(&x, &y, 690, 100, 732, 112, "0xee2523", 5) {
            return(MainScript())
        }
        if PixelSearch(&x, &y, 690, 100, 732, 112, "0xa72d2a", 5) {
            return(MainScript())
        }
        if Gear.Value = 1 {
            SendWebhook(Webhook, "Trying To Buy " Gear.Name)
            count := 1
            loop {
                if PixelSearch(&x, &y, 310, 354, 463, 381, "0x42c100", 5) or PixelSearch(&x, &y, 310, 354, 463, 381, "0x2e8800", 5) {
                    SendWebhook(Webhook, Gear.Name " In Shop; Buying")
                    SendEvent "{Click, " x "," y "}"
                    Sleep(50)
                    count += 1
                    if count = 20 {
                        SendWebhook(Webhook, "Tried Buying 20 Times; Stopped Trying To Buy")
                        break()
                    }
                } else if PixelSearch(&x, &y, 310, 354, 463, 381, "0xdf0000", 3) or PixelSearch(&x, &y, 310, 354, 463, 381, "0x9f0000", 5) {
                    SendWebhook(Webhook, "No Stock")
                    break
                }
            }
        }
        SendEvent "{Click," Coordinates[5].Value1 "," Coordinates[5].Value2 "}"
        Sleep(500)
    }
    SendEvent "{Click," Coordinates[4].Value1 "," Coordinates[4].Value2 "}"
    Sleep(500)
    loop(18) {
        SendEvent "{WheelDown}"
        Sleep(50)
    }
}

F1::MainScript()
F2::Pause -1
F3::ExitApp()