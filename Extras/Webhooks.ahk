global Version := "1.0.0"

#Requires AutoHotkey v2.0

SendWebhook(url, message) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        
        ; Discord/Slack expect the text inside a JSON object: {"content": "your message"}
        jsonPayload := '{"content": "' . message . '"}'
        
        whr.Send(jsonPayload)
        whr.WaitForResponse()
        
    } catch as err {
        MsgBox("Webhook failed!`n`n" . err.Message)
    }
}