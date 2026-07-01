global Version := "1.0.0"

#Requires AutoHotkey v2.0
#SingleInstance Force

global BaseURL := "https://raw.githubusercontent.com/Adelnon/DLN/main/"

CheckVersion(Version, BaseURL "DLNMacros.ahk", A_ScriptFullPath)

if !DirExist(A_MyDocuments "\DLN") {
    DirCreate(A_MyDocuments "\DLN")
}
if !DirExist(A_MyDocuments "\DLN\Extras") {
    DirCreate(A_MyDocuments "\DLN\Extras")
}
if !FileExist(A_MyDocuments "\DLN\Extras\default.jpeg") {
    Download(BaseURL "Extras/default.jpeg", A_MyDocuments "\DLN\Extras\default.jpeg")
}
if !FileExist(A_MyDocuments "\DLN\join_rbx.exe") {
    Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", A_MyDocuments "\DLN\join_rbx.exe")
}

global Extras := [
    "JoinRBX.ahk",
    "Menus.ahk",
    "Resize.ahk",
    "Webhooks.ahk"
]

global General := [
    "AntiAFK.ahk"
]

global GAG2 := [
    "GAG2.ahk",
    "GAG2Maps.ahk",
    "Images/SaveFailed.png"
]

global PS99 := [
    "TradingPlaza.ahk"
]

; info per macro, key = filename without .ahk
; fill in real image/description/links per macro over time
global MacroInfo := Map(
    "AntiAFK", {img: A_MyDocuments "\DLN\Extras\default.jpeg", desc: "Keeps you from getting kicked for being AFK.", youtube: "", discord: ""},
    "GAG2", {img: "Extras\default.jpeg", desc: "Main Grow A Garden 2 macro.", youtube: "", discord: ""},
    "GAG2Maps", {img: "default.png", desc: "Map/teleport helper for GAG2.", youtube: "", discord: ""},
    "TradingPlaza", {img: "default.png", desc: "Trading Plaza automation for PS99.", youtube: "", discord: ""}
)

global CategoryMap := Map(
    "General", General,
    "Grow A Garden 2", GAG2,
    "Pet Simulator 99", PS99
)

global ImagesDir := A_MyDocuments "\DLN\Images\"

; ---------------- GUI ----------------

Main := Gui("+AlwaysOnTop")
Main.Title := "DLN Macros"
Main.SetFont("s9")

Main.AddText("x10 y10", "Game:")
CategoryDDL := Main.AddDropDownList("x10 y30 w320", ["General", "Grow A Garden 2", "Pet Simulator 99"])
CategoryDDL.OnEvent("Change", CategoryChanged)

; Macros box: left edge matches ddl left edge (x10)
MacroGroup := Main.AddGroupBox("x10 y65 w150 h180", "Macros")
MacroListBox := Main.AddListBox("x20 y85 w130 h155 vMacroList")
MacroListBox.OnEvent("Change", MacroSelected)

; Info box: right edge matches ddl right edge (10+320=330 -> 170+160=330), same y as Macros box
InfoGroup := Main.AddGroupBox("x170 y65 w160 h140", "Info")
MacroImage := Main.AddPicture("x220 y85 w60 h60 vMacroImage")
MacroNameText := Main.AddText("x180 y150 w140 h20 Center", "")
MacroNameText.SetFont("s11 bold")
MacroDescText := Main.AddText("x180 y172 w140 h30", "")
MacroDescText.SetFont("s8")

; Buttons below the info box: Download on top, Information + YouTube below it
DownloadBtn := Main.AddButton("x170 y210 w160 h22", "Start")
DownloadBtn.OnEvent("Click", (*) => StartMacro(CurrentMacro))

InfoBtn := Main.AddButton("x170 y237 w78 h22", "Information")
InfoBtn.OnEvent("Click", (*) => ShowInformation(CurrentMacro))
YoutubeBtn := Main.AddButton("x252 y237 w78 h22", "YouTube")
YoutubeBtn.OnEvent("Click", (*) => OpenYoutube(CurrentMacro))

; Discord moved to the right, under the info/buttons column
DiscordBtn := Main.AddButton("x170 y264 w160 h22", "Discord")
DiscordBtn.OnEvent("Click", (*) => OpenDiscord(CurrentMacro))

Main.OnEvent("Close", (*) => ExitApp())
Main.Show()

CategoryDDL.Value := 1
CategoryChanged()

; ---------------- Logic ----------------

global CurrentMacro := ""

CategoryChanged(*) {
    catName := CategoryDDL.Text
    arr := CategoryMap[catName]

    MacroListBox.Delete()
    names := []
    for file in arr {
        if InStr(file, ".ahk") {
            names.Push(RegExReplace(file, "\.ahk$", ""))
        }
    }
    for n in names {
        MacroListBox.Add([n])
    }

    ClearInfo()
    if names.Length {
        MacroListBox.Choose(1)
        MacroSelected()
    }
}

MacroSelected(*) {
    sel := MacroListBox.Text
    if !sel {
        ClearInfo()
        return
    }
    CurrentMacro := sel

    info := MacroInfo.Has(sel) ? MacroInfo[sel] : {img: "default.png", desc: "No description yet.", youtube: "", discord: ""}

    imgPath := ImagesDir . info.img
    if FileExist(imgPath) {
        MacroImage.Value := imgPath
    } else {
        MacroImage.Value := ""
    }

    MacroNameText.Value := sel
    MacroDescText.Value := info.desc
}

ClearInfo(*) {
    CurrentMacro := ""
    MacroImage.Value := ""
    MacroNameText.Value := ""
    MacroDescText.Value := ""
}

ShowInformation(macroName) {
    if !macroName
        return
    info := MacroInfo.Has(macroName) ? MacroInfo[macroName] : {desc: "No info available."}

    infoGui := Gui("+AlwaysOnTop", macroName " - Information")
    infoGui.SetFont("s9")
    infoGui.AddText("w300", info.desc)
    infoGui.AddButton("w80", "Close").OnEvent("Click", (*) => infoGui.Destroy())
    infoGui.Show()
}

DownloadMacro(macroName) {
    if !macroName {
        MsgBox("Select a macro first.")
        return
    }
    ; TODO: hook this into your actual download logic per category
    ; e.g. call GAG2Download() / GeneralDownload() depending on selected category
    MsgBox("Downloading " macroName "...")
}

OpenYoutube(macroName) {
    if !macroName
        return
    info := MacroInfo.Has(macroName) ? MacroInfo[macroName] : {youtube: ""}
    if info.youtube
        Run(info.youtube)
    else
        MsgBox("No YouTube link set for " macroName " yet.")
}

OpenDiscord(macroName) {
    if !macroName {
        MsgBox("Select a macro first.")
        return
    }
    info := MacroInfo.Has(macroName) ? MacroInfo[macroName] : {discord: ""}
    if info.discord
        Run(info.discord)
    else
        MsgBox("No Discord link set for " macroName " yet.")
}

; ---------------- Downloads ----------------

ExtrasDownload() {
    if !DirExist(A_MyDocuments "\DLN\Extras") {
        DirCreate(A_MyDocuments "\DLN\Extras")
    }
    for file in Extras {
        if !FileExist(A_MyDocuments "\DLN\Extras\" . file) {
            Download(BaseURL "Extras/" . file, A_MyDocuments "\DLN\Extras\" . file)
        } else {
            CheckVersion(Version, BaseURL "Extras/" . file, A_MyDocuments "\DLN\Extras\" . file)
        }
    }
}

GeneralDownload() {
    ExtrasDownload()
    if !DirExist(A_MyDocuments "\DLN\General") {
        DirCreate(A_MyDocuments "\DLN\General")
    }
    for file in General {
        if !FileExist(A_MyDocuments "\DLN\General\" . file) {
            Download(BaseURL "General/" . file, A_MyDocuments "\DLN\General\" . file)
        } else {
            CheckVersion(Version, BaseURL "General/" . file, A_MyDocuments "\DLN\General\" . file)
        }
    }
}

GAG2Download() {
    ExtrasDownload()
    if !DirExist(A_MyDocuments "\DLN\GAG2") {
        DirCreate(A_MyDocuments "\DLN\GAG2")
    }
    if !DirExist(A_MyDocuments "\DLN\GAG2\Images") {
        DirCreate(A_MyDocuments "\DLN\GAG2\Images")
    }
    for file in GAG2 {
        if !FileExist(A_MyDocuments "\DLN\GAG2\" . file) {
            Download(BaseURL "GAG2/" . file, A_MyDocuments "\DLN\GAG2\" . file)
        } else {
            CheckVersion(Version, BaseURL "GAG2/" . file, A_MyDocuments "\DLN\GAG2\" . file)
        }
    }
}

PS99Download() {
    ExtrasDownload()
    if !DirExist(A_MyDocuments "\DLN\PS99") {
        DirCreate(A_MyDocuments "\DLN\PS99")
    }
    for file in PS99 {
        if !FileExist(A_MyDocuments "\DLN\PS99\" . file) {
            Download(BaseURL "PS99/" . file, A_MyDocuments "\DLN\PS99\" . file)
        } else {
            CheckVersion(Version, BaseURL "PS99/" . file, A_MyDocuments "\DLN\PS99\" . file)
        }
    }
}

StartMacro(macroName) {
    if !macroName {
        MsgBox("Select a macro first.")
        return
    }

    catName := CategoryDDL.Text
    folder := ""

    if (catName = "General") {
        GeneralDownload()
        folder := "General"
    } else if (catName = "Grow A Garden 2") {
        GAG2Download()
        folder := "GAG2"
    } else if (catName = "Pet Simulator 99") {
        PS99Download()
        folder := "PS99"
    } else {
        MsgBox("Unknown category.")
        return
    }

    filePath := A_MyDocuments "\DLN\" folder "\" macroName ".ahk"

    if !FileExist(filePath) {
        MsgBox("Could not find " macroName " after download. Try again.")
        return
    }

    Run(filePath)
}

CheckVersion(localVersion, url, selfPath) {
    tmp := A_Temp "\dln_update.ahk"

    if FileExist(tmp)
        FileDelete(tmp)

    bustedUrl := url (InStr(url, "?") ? "&" : "?") "nocache=" A_TickCount "_" A_Now
    try Download(bustedUrl, tmp)
    catch {
        MsgBox("Download failed for: " bustedUrl)
        return
    }

    if !FileExist(tmp) {
        MsgBox("Download seemed to succeed but tmp file is missing!")
        return
    }

    content := FileRead(tmp)
    FileDelete(tmp)

    if !RegExMatch(content, 'global Version := "(.+)"', &m)  {
        MsgBox("no match found in:`n" content)
        return
    }

    remoteVersion := Trim(m[1], ' `r`n"')

    if (remoteVersion != localVersion) {
        if MsgBox("Update available! (" localVersion " → " remoteVersion ")`nUpdate now?", , "YesNo") = "Yes" {
            Download(url, selfPath)
            if (selfPath = A_ScriptFullPath) {
                MsgBox("Updated! Restarting...")
                Reload()
            }
        }
    }
}