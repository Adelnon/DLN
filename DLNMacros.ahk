global Version := "1.0.0"

#Requires AutoHotkey v2.0
#SingleInstance Force

global BaseURL := "https://raw.githubusercontent.com/Adelnon/DLN/main/"

CheckVersion(Version, BaseURL "DLNMacros.ahk", A_ScriptFullPath)

maingui := Gui()
maingui.Show()

global GAG2 := [
    "GAG2.ahk",
    "GAG2Maps.ahk",
    "Images/SaveFailed.png"
]

if !DirExist(A_MyDocuments "\DLN") {
    DirCreate(A_MyDocuments "\DLN")
}
if !DirExist(A_MyDocuments "\DLN\GAG2") {
    DirCreate(A_MyDocuments "\DLN\GAG2")
}
if !DirExist(A_MyDocuments "\DLN\GAG2\Images") {
    DirCreate(A_MyDocuments "\DLN\GAG2\Images")
}

if !FileExist(A_MyDocuments "\DLN\join_rbx.exe") {
    Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", A_MyDocuments "\DLN\join_rbx.exe")
}


GAG2Download() {
    for file in GAG2 {
        Download(BaseURL "GAG2/" . file, A_MyDocuments "\DLN\GAG2\" . file)
    }
}

F1::GAG2Download()

CheckVersion(localVersion, url, selfPath) {
    tmp := A_Temp "\dln_update.ahk"
    try Download(url, tmp)
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
            Download(url, selfPath)
            MsgBox("Updated! Restarting...")
            Reload()
        }
    }
}