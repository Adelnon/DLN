#Requires AutoHotkey v2.0
#SingleInstance Force

baseURL := "https://raw.githubusercontent.com/Adelnon/DLN/main/"

GAG2 := [
    "GAG2.ahk",
    "GAG2Maps.ahk",
    "JoinRBX.ahk",
    "Webhooks.ahk",
    "SaveFailed.png"
]

if !FileExist(A_MyDocuments "\DLN") {
    DirCreate(A_MyDocuments "\DLN")
}
if !FileExist(A_MyDocuments "\DLN\GAG2") {
    DirCreate(A_MyDocuments "\DLN\GAG2")
}

if FileExist(A_MyDocuments "\DLN\join_rbx.exe") {
    FileDelete(A_MyDocuments "\DLN\join_rbx.exe")
}
Download("https://github.com/Adelnon/DLN/releases/download/Exe/join_rbx.exe", A_MyDocuments "\DLN\join_rbx.exe")

GAG2Download() {
    if !FileExist(A_MyDocuments "\DLN\GAG2\GAG2.ahk") {
    }
    Download("https://raw.githubusercontent.com/Adelnon/DLN/main/GAG2/GAG2.ahk", A_MyDocuments "\DLN\GAG2\GAG2.ahk")
}