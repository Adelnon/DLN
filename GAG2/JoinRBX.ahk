#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Webhooks.ahk

TargetDir := A_MyDocuments "\DLN"

JoinGame(TargetPlaceID, WebhookURL := "", PrivateServerLink := "") {
    if ProcessExist("join_rbx.exe") {
        ToolTip("Joiner is already running...")
        SetTimer () => ToolTip(), -2000
        return
    }

    GameName := GetRobloxGameName(TargetPlaceID)

    for procName in ["RobloxPlayerBeta.exe", "RobloxPlayerLauncher.exe"] {
        if ProcessExist(procName) {
            try {
                ProcessClose(procName)
                ProcessWaitClose(procName, 5)
            }
        }
    }

    ConfigPath := TargetDir . "\place_id.txt"
    ConfigContent := TargetPlaceID

    if (PrivateServerLink != "") {
        ConfigContent .= "`n" . PrivateServerLink
    }

    try {
        if FileExist(ConfigPath)
            FileDelete(ConfigPath)
        FileAppend(ConfigContent, ConfigPath)
    } catch as err {
        SendWebhook(WebhookURL, "Failed to create config file!`nPath: " . ConfigPath . "`nError: " . err.Message)
        MsgBox("Failed to create config file!`nPath: " . ConfigPath . "`nError: " . err.Message)
        return
    }

    JoinExecutable := TargetDir . "\join_rbx.exe"

    try {
        if FileExist(JoinExecutable) {
            Run(JoinExecutable, TargetDir, "Hide")
            
            ToolTip("Launching Roblox ID: " . TargetPlaceID)
            SetTimer () => ToolTip(), -2000
            
            if ProcessWait("RobloxPlayerBeta.exe", 30) {
                SendWebhook(WebhookURL, A_UserName . " successfully joined **" . GameName . "**")
                try FileDelete(ConfigPath)
            } else {
                SendWebhook(WebhookURL, "Failed to launch Roblox. Please check if Roblox is installed and try again.")
                MsgBox("Failed to launch Roblox. Please check if Roblox is installed and try again.")
            }
        } else {
            SendWebhook(WebhookURL, "Error: join_rbx.exe not found at:`n" . JoinExecutable)
            MsgBox("Error: join_rbx.exe not found at:`n" . JoinExecutable)
        }
    } catch as err {
        SendWebhook(WebhookURL, "Failed to launch join_rbx.exe`nError: " . err.Message)
        MsgBox("Failed to launch join_rbx.exe`nError: " . err.Message)
    }
}

GetRobloxGameName(placeId) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        
        universeUrl := "https://apis.roblox.com/universes/v1/places/" . placeId . "/universe"
        whr.Open("GET", universeUrl, false)
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0")
        whr.Send()
        
        if RegExMatch(whr.ResponseText, '"universeId":(\d+)', &uMatch) {
            universeId := uMatch[1]
            
            nameUrl := "https://games.roblox.com/v1/games?universeIds=" . universeId
            whr.Open("GET", nameUrl, false)
            whr.Send()
            
            if RegExMatch(whr.ResponseText, 'i)"name"\s*:\s*"([^"]+)"', &nMatch) {
                return nMatch[1]
            }
        }
    } catch {
        return "Roblox Game (" . placeId . ")"
    }
    return "Unknown Game (Login Required)"
}
