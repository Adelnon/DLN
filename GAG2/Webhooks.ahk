#Requires AutoHotkey v2.0
#SingleInstance Force

SendWebhook(url, message) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        
        ; Discord/Slack expect the text inside a JSON object: {"content": "your message"}
        jsonPayload := '{"content": "' . message . '"}'
        
        whr.Send(jsonPayload)
        whr.WaitForResponse()
        
        ToolTip("Webhook sent!")
        SetTimer () => ToolTip(), -2000
    } catch as err {
        MsgBox("Webhook failed!`n`n" . err.Message)
    }
}