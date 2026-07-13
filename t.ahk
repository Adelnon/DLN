global Version := "1.0.0"

#Requires AutoHotkey v2.0
#SingleInstance Force

global BaseURL := "https://raw.githubusercontent.com/Adelnon/DLN/main/"
global DiscordLink := "https://discord.gg/f6QY2XhBf4"

CheckVersion(Version, BaseURL "DLNMacros.ahk", A_ScriptFullPath)

Main := Gui("+AlwaysOnTop")
Main.Title := "Grow A Garden 2 Macro"

CategoryDDL := Main.AddDropDownList(, ["General", "GAG2", "PS99"])
CategoryDDL.OnEvent("Change", CategoryChanged)

; --- Macros box: lists the macros available for the selected category ---
MacroGroup := Main.AddGroupBox("x10 y38 w150 h155", "Macros")
MacroListBox := Main.AddListBox("x20 y58 w130 h125 vMacroList")
MacroListBox.OnEvent("Change", MacroSelected)

; --- Info box: title/description and the macro-specific buttons.
;     These change depending on the selected macro. ---
InfoGroup := Main.AddGroupBox("x170 y38 w160 h125", "Info")
MacroNameText := Main.AddText("x180 y51 w140 h18 Center", "")
MacroNameText.SetFont("s11 bold")
MacroDescText := Main.AddText("x180 y73 w140 h40", "")
MacroDescText.SetFont("s8")

DownloadBtn := Main.AddButton("x180 y116 w140 h22", "Start")
DownloadBtn.OnEvent("Click", (*) => StartMacro(CurrentMacro))

InfoBtn := Main.AddButton("x180 y141 w68 h22", "Information")
InfoBtn.OnEvent("Click", (*) => ShowInformation(CurrentMacro))

YoutubeBtn := Main.AddButton("x252 y141 w68 h22", "YouTube")
YoutubeBtn.OnEvent("Click", (*) => OpenYoutube(CurrentMacro))

; --- Discord: one fixed link, the same everywhere, never tied to a macro.
;     Sits under the Info box, in the extra height Macros has over Info,
;     same width as the Info box. ---
DiscordBtn := Main.AddButton("x170 y168 w160 h22", "Discord")
DiscordBtn.OnEvent("Click", (*) => OpenDiscord())

Main.OnEvent("Close", (*) => ExitApp())
Main.Show()

global CurrentMacro := ""

global Extras := [
    "JoinRBX.ahk",
    "Menus.ahk",
    "Resize.ahk",
    "Webhooks.ahk"
]

global General := [
    {file: "AntiAFK.ahk", show: true}
]

global GAG2 := [
    {file: "GAG2.ahk", show: true},
    {file: "GAG2Extras/GAG2Maps.ahk", show: false},
    {file: "Images/SaveFailed.png", show: false}
]

global PS99 := [
    {file: "TradingPlaza.ahk", show: true}
]

global MacroInfo := Map(
    "AntiAFK", {desc: "Keeps you from getting kicked for being AFK.", youtube: ""},
    "GAG2", {desc: "Main Grow A Garden 2 macro.", youtube: ""},
    "TradingPlaza", {desc: "Trading Plaza automation for PS99.", youtube: ""}
)

global CategoryMap := Map(
    "General", General,
    "GAG2", GAG2,
    "PS99", PS99
)

CategoryDDL.Value := 1
CategoryChanged()

if !DirExist(A_MyDocuments "\DLN") {
    DirCreate(A_MyDocuments "\DLN")
}

ExtrasDownload()

; ---------------- GUI logic ----------------

CategoryChanged(*) {
    catName := CategoryDDL.Text
    arr := CategoryMap[catName]

    MacroListBox.Delete()
    names := []
    for entry in arr {
        if entry.show && InStr(entry.file, ".ahk")
            names.Push(RegExReplace(entry.file, "\.ahk$", ""))
    }
    for n in names
        MacroListBox.Add([n])

    ClearInfo()
    if names.Length {
        MacroListBox.Choose(1)
        MacroSelected()
    }
}

MacroSelected(*) {
    global CurrentMacro
    sel := MacroListBox.Text
    if !sel {
        ClearInfo()
        return
    }
    CurrentMacro := sel

    info := MacroInfo.Has(sel) ? MacroInfo[sel] : {desc: "No description yet.", youtube: ""}

    MacroNameText.Value := sel
    MacroDescText.Value := info.desc
}

ClearInfo(*) {
    global CurrentMacro
    CurrentMacro := ""
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

OpenYoutube(macroName) {
    if !macroName
        return
    info := MacroInfo.Has(macroName) ? MacroInfo[macroName] : {youtube: ""}
    if info.youtube
        Run(info.youtube)
    else
        MsgBox("No YouTube link set for " macroName " yet.")
}

OpenDiscord(*) {
    Run(DiscordLink)
}

StartMacro(macroName) {
    if !macroName {
        MsgBox("Select a macro first.")
        return
    }

    catName := CategoryDDL.Text
    switch catName {
        case "General": GeneralDownload()
        case "GAG2": GAG2Download()
        case "PS99": PS99Download()
        default:
            MsgBox("Unknown category.")
            return
    }

    filePath := A_MyDocuments "\DLN\" catName "\" macroName ".ahk"

    if !FileExist(filePath) {
        MsgBox("Could not find " macroName " after download. Try again.")
        return
    }

    Run(filePath)
}

; ---------------- Downloads ----------------

; Downloads every file in fileList for the given folder.
; - Missing files are grabbed immediately, no prompt (first-time install).
; - Existing files with a version mismatch are queued as updates.
; - If promptForUpdates is true, ONE combined prompt covers the whole
;   category (not one per file). If false (Extras), updates apply silently.
DownloadCategoryFiles(folder, fileList, promptForUpdates) {
    localDir := A_MyDocuments "\DLN\" folder
    if !DirExist(localDir)
        DirCreate(localDir)

    toInstall := []
    toUpdate := []

    for entry in fileList {
        file := IsObject(entry) ? entry.file : entry

        localPath := localDir "\" StrReplace(file, "/", "\")
        parentDir := RegExReplace(localPath, "\\[^\\]+$")
        if !DirExist(parentDir)
            DirCreate(parentDir)

        remoteUrl := BaseURL folder "/" file

        if !FileExist(localPath) {
            toInstall.Push({path: localPath, url: remoteUrl})
        } else {
            remoteVersion := GetRemoteVersion(remoteUrl)
            if (remoteVersion != "" && remoteVersion != Version)
                toUpdate.Push({path: localPath, url: remoteUrl})
        }
    }

    for item in toInstall
        Download(item.url, item.path)

    if toUpdate.Length {
        doUpdate := true
        if promptForUpdates
            doUpdate := (MsgBox("A new version of " folder " is available. Update now?", , "YesNo") = "Yes")
        if doUpdate {
            for item in toUpdate
                Download(item.url, item.path)
        }
    }
}

ExtrasDownload() {
    localDir := A_MyDocuments "\DLN\Extras"
    if !DirExist(localDir)
        DirCreate(localDir)
    if !FileExist(localDir "\join_rbx.exe")
        Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", localDir "\join_rbx.exe")

    DownloadCategoryFiles("Extras", Extras, false)
}

GeneralDownload() {
    ExtrasDownload()
    DownloadCategoryFiles("General", General, true)
}

GAG2Download() {
    ExtrasDownload()
    DownloadCategoryFiles("GAG2", GAG2, true)
}

PS99Download() {
    ExtrasDownload()
    DownloadCategoryFiles("PS99", PS99, true)
}

GetRemoteVersion(url) {
    tmp := A_Temp "\dln_version_check.ahk"

    if FileExist(tmp)
        FileDelete(tmp)

    bustedUrl := url (InStr(url, "?") ? "&" : "?") "nocache=" A_TickCount "_" A_Now
    try Download(bustedUrl, tmp)
    catch {
        return ""
    }

    if !FileExist(tmp)
        return ""

    content := FileRead(tmp)
    FileDelete(tmp)

    if !RegExMatch(content, 'global Version := "(.+)"', &m)
        return ""

    return Trim(m[1], ' `r`n"')
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
        if MsgBox("A new version is available. Update now?", , "YesNo") = "Yes" {
            Download(url, selfPath)
            MsgBox("Updated! Restarting...")
            Reload()
        }
    }
}
