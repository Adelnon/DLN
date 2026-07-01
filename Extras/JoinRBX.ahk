global Version := "1.0.0"

#Requires AutoHotkey v2.0

TargetDir := A_MyDocuments "\DLN"

JoinGame(TargetPlaceID, WebhookURL := "", PrivateServerLink := "") {
    if ProcessExist("join_rbx.exe") {
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
        MsgBox("Failed to create config file!`nPath: " . ConfigPath . "`nError: " . err.Message)
        return
    }

    JoinExecutable := TargetDir . "\join_rbx.exe"

    try {
        if FileExist(JoinExecutable) {
            Run(JoinExecutable, TargetDir, "Hide")
            
            if ProcessWait("RobloxPlayerBeta.exe", 30) {
                try FileDelete(ConfigPath)
            } else {
                MsgBox("Failed to launch Roblox. Please check if Roblox is installed and try again.")
            }
        } else {
            MsgBox("Error: join_rbx.exe not found at:`n" . JoinExecutable)
        }
    } catch as err {
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
