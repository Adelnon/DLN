global Version := "1.0.2"

#Requires AutoHotkey v2.0
#SingleInstance Force

global BaseURL := "https://raw.githubusercontent.com/Adelnon/DLN/main/"

CheckVersion(Version, BaseURL "DLNMacros.ahk", A_ScriptFullPath)

maingui := Gui()
maingui.Show()

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

if !DirExist(A_MyDocuments "\DLN") {
    DirCreate(A_MyDocuments "\DLN")
}
if !FileExist(A_MyDocuments "\DLN\join_rbx.exe") {
    Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", A_MyDocuments "\DLN\join_rbx.exe")
}

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

F1::GAG2Download()
F2::GeneralDownload()

CheckVersion(localVersion, url, selfPath) {
    tmp := A_Temp "\dln_update.ahk"
    bustedUrl := url (InStr(url, "?") ? "&" : "?") "nocache=" A_TickCount "_" A_Now
    try Download(bustedUrl, tmp)
    catch
        return

    content := FileRead(tmp)
    FileDelete(tmp)

    if !RegExMatch(content, 'global Version := "(.+)"', &m)  {
        MsgBox("no match found in:`n" content)
        return
    }

    remoteVersion := Trim(m[1], ' `r`n"')
    
    MsgBox("local: " localVersion "`nremote: " remoteVersion)  ; debug

    if (remoteVersion != localVersion) {
        if MsgBox("Update available! (" localVersion " → " remoteVersion ")`nUpdate now?", , "YesNo") = "Yes" {
            Download(url, selfPath)  ; hier bewusst OHNE nocache, damit die echte Datei gespeichert wird
            MsgBox("Updated! Restarting...")
            Reload()
        }
    }
}