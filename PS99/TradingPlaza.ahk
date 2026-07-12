global Version := "1.0.0"

#Requires AutoHotkey 2.0.0
#SingleInstance Force
CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
#Include ..\Extras\Webhooks.ahk
#Include ..\Extras\JoinRBX.ahk
#Include ..\Extras\Resize.ahk
#Include ..\Extras\Menus.ahk

ItemMap := Map(
    "Item", "Piñata",
)
CostMap := Map(
    "Price", "35000",
)
ButtonsMap := Map(
    "Pet", {y:200},
    "Item", {y:240},
    "Potion", {y:280},
    "Enchant", {y:320},
    "Ultimate", {y:360},
    "Egg", {y:400},
    "Booth", {y:440}
)
AmountMap := Map(
    "1/4", {x:161, y:226},
    "Half", {x:121, y:258},
    "3/4", {x:81, y:226}
)

KindNum := 0
AmountNum := 0
KindValue := 0
AmountValue := 0
Failsafe := 0

try {
    LoadSettings()
}

ObjToMap(Obj, Depth:=5, IndentLevel:="")
{
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
    if Type(Obj) = "String" {
      Obj := [Obj]
    }
	for k,v in Obj
	{
		List.= IndentLevel k
		if (IsObject(v) && Depth>1)
			List.="`n" ObjToMap(v, Depth-1, IndentLevel . "    ")
		Else
			List.=":" v
		List.="/\"
	}
	
  NewMap := Map()
  SplitArray := StrSplit(List, "/\")
  for __ArrayNum, SplitText in SplitArray {
    ValueSplit := StrSplit(SplitText, ":")
    
    if InStr(SplitText, ":") {
      NewMap[ValueSplit[1]] := ValueSplit[2]
      ; OutputDebug('`n' ValueSplit[1] " : " ValueSplit[2])
    }
  }

  return NewMap
}

MainGUI := Gui()

MainGUI.AddText("w200 h20 y5 Section", "Items").SetFont("s12 w700")
for Setting, SettingValue in ItemMap {
    MainGUI.AddText("w150 h20 xs", Setting ":").SetFont("s10")
    MainGUI.AddEdit("w120 h20 yp xp+140 v" Setting, SettingValue).OnEvent("Change", (Kind, *) => Func1())
}
Func1(*) {
    SubmitValues := ObjToMap(MainGUI.Submit(false))
    for Key, Value in SubmitValues {
        ItemMap[Key] := Value
    }
}

MainGUI.AddText("w150 h20 xs", "Kind being sold:").SetFont("s10")
MainGUI.AddDropDownList("w120 yp xp+140 Choose" KindNum, ["Pet","Item","Potion","Enchant","Ultimate","Egg","Booth"]).OnEvent("Change", (Kind, *) => TheFunction1(Kind))
MainGUI.AddText("w150 h20 xs", "Amount being sold:").SetFont("s10")
MainGUI.AddDropDownList("w120 yp xp+140 vAmount Choose" AmountNum, ["Min","1/4","Half","3/4","Max"]).OnEvent("Change", (Kind, *) => TheFunction2(Kind))

TheFunction1(Kind, *) {
    global KindNum := Kind.Value
    global KindValue := Kind.Text
}

TheFunction2(Kind, *) {
    global AmountNum := Kind.Value
    global AmountValue := Kind.Text
}

MainGUI.AddText("w200 h20 x10 Section", "Prices").SetFont("s12 w700")
for Setting, SettingValue in CostMap {
    MainGUI.AddText("w150 h20 xs", Setting ":").SetFont("s10")
    MainGUI.AddEdit("w120 h20 yp xp+140 v" Setting, SettingValue).OnEvent("Change", (Kind, *) => Func2())
}
Func2(*) {
    SubmitValues := ObjToMap(MainGUI.Submit(false))
    for Key, Value in SubmitValues {
        CostMap[Key] := Value
    }
}

SaveButton := MainGUI.AddButton("Default w280 h35 x5 y+5", "Save Settings")
SaveButton.SetFont("s22 w1000")
SaveButton.OnEvent("Click", Save)
Save(*) {
    if not FileExist(A_MyDocuments "\Settings") {
        DirCreate(A_MyDocuments "\Settings")
    }
    if FileExist(A_MyDocuments "\Settings\Settings.ini") {
        FileDelete(A_MyDocuments "\Settings\Settings.ini")
        FileAppend("", A_MyDocuments "\Settings\Settings.ini")
    }
    for Key, Value in ItemMap {
        IniWrite(Value, A_MyDocuments "\Settings\Settings.ini", "ItemMap", Key)
    }
    for Key, Value in CostMap {
        IniWrite(Value, A_MyDocuments "\Settings\Settings.ini", "CostMap", Key)
    }
    IniWrite(KindNum, A_MyDocuments "\Settings\Settings.ini", "Numbers", "KindNum")
    IniWrite(AmountNum, A_MyDocuments "\Settings\Settings.ini", "Numbers", "AmountNum")
    IniWrite(KindValue, A_MyDocuments "\Settings\Settings.ini", "Numbers", "KindValue")
    IniWrite(AmountValue, A_MyDocuments "\Settings\Settings.ini", "Numbers", "AmountValue")
}

MainGUI.AddText("w200 h20 x10 y+5 Section", "Controls").SetFont("s12 w700")
MainGUI.AddText("w150 h15 xs", "F1 = Start").SetFont("s10")
MainGUI.AddText("w150 h15 xs", "F2 = Pause/Continue").SetFont("s10")
MainGUI.AddText("w150 h15 xs", "F3 = Stop").SetFont("s10")
MainGUI.AddText("w150 h20 xs", "Start in booth GUI").SetFont("s12 w700")

MainGUI.OnEvent("Close", (*) => ExitApp())

MainGUI.Show("Center")

CleanUI() {
    loop {
        if PixelSearch(&mX,&mY,610,150,640,200,"0xff0a4b",2) {
            Click(mX,mY)
            Sleep(500)
            if PixelSearch(&mX,&mY,641,150,670,200,"0xff0a4b",2) {
                Click(mX,mY)
                Sleep(500)
            }
        } else if PixelSearch(&mX,&mY,730,120,755,170,"0xff0a4b",2) {
            Click(mX,mY)
            Sleep(500)
            if PixelSearch(&mX,&mY,756,150,780,200,"0xff0a4b",2) {
                Click(mX,mY)
                Sleep(500)
            }
        } else {
            break
        }
    }
}

Main() {
    IDs:=WinGetList("ahk_exe RobloxPlayerBeta.exe")
    loop {
        For ID in IDs {
            WinMove(,,816,638,"ahk_id " ID)
            WinActivate("ahk_id " ID)
            WinGetPos(&X, &Y, &W, &H, ID)
            WinActivate("ahk_exe AutoHotkey64.exe")
            WinMove(X+816,Y,,,"ahk_exe AutoHotkey64.exe")
            WinActivate("ahk_id " ID)
            Sleep(1000)
            SendEvent "{Click, 400, 200, 0}"
            Sleep(1000)
            Menus()
            loop {
                if not PixelSearch(&mX,&mY,80,260,150,470,"0xa9fcfd",3) {
                    if not PixelSearch(&mX,&mY,80,400,150,470,"0x76f1fb",3) or not PixelSearch(&mX,&mY,730,120,780,160,"0xff1e6c",2) {
                        CleanUI()
                        SendEvent "{E}"
                        break
                    }
                } else {
                    MsgBox("Be close to your booth so after closing and reopening UI it doesn't open some other booth.")
                    break(2)
                }
                SendEvent "{Click, 400, 200, 0}"
                loop {
                    Sleep(500)
                    if PixelSearch(&mX,&mY,80,400,150,470,"0x76f1fb",3) {
                        Click(mX,mY,0)
                        Sleep(1000)
                        Click(mX,mY)
                        Sleep(1000)
                    } 
                    if PixelSearch(&mX,&mY,151,400,220,470,"0x77f1fb",3) {
                        Click(mX,mY)
                        Sleep(1000)
                    } else if PixelSearch(&cX,&cY,200,430,380,480,"0x84f710",3) and PixelSearch(&mX,&mY,430,420,610,480,"0xff1c6a",3) {
                        CleanUI()
                        SendEvent "{E}"
                        Sleep(500)
                        break(2)
                    } else if PixelSearch(&mX,&mY,410,430,490,480,"0x90f915",3) {
                        CleanUI()
                        SendEvent "{E}"
                        Sleep(500)
                        break(2)
                    } else {
                        break
                    }
                    Failsafe += 1
                    if Failsafe = 20 {
                        CleanUI()
                        SendEvent "{E}"
                        global Failsafe := 0
                    }
                }
                Sleep(1000)
                SendEvent "{Click, 30," ButtonsMap[KindValue].y "}"
                Sleep(1000)
                if PixelSearch(&mX,&mY,240,170,241,171,"0x272930",0) or PixelSearch(&mX,&mY,240,170,241,171,"0x393b3d",0) {
                    SendEvent "{Click, 300, 450}"
                    Sleep(500)
                    CleanUI()
                    SendEvent "{E}"
                    break()
                }
                SendEvent "{Click, 710, 140}"
                Sleep(1000)
                SendText ItemMap["Item"]
                Sleep(1000)
                if PixelSearch(&mX,&mY,120,215,121,216,"0xffffff",3) {
                    CleanUI()
                    SendEvent "{E}"
                    break()
                }
                if AmountValue = "Min" {
                    SendEvent "^{Click, 130, 220}"
                } else if AmountValue = "Max" {
                    SendEvent "+{Click, 120, 180}"
                } else {
                    SendEvent "{Click, " AmountMap[AmountValue].x ", " AmountMap[AmountValue].y "}"
                }
                Sleep(1000)
                loop {
                    if PixelSearch(&mX,&mY,325,500,480,520,"0x76f1fb",3) {
                        Click(mX,mY,0)
                        Sleep(1000)
                        Click(mX-1,mY-1)
                        Sleep(1000)
                    } else {
                        break()
                    }
                    Failsafe += 1
                    if Failsafe = 20 {
                        CleanUI()
                        SendEvent "{E}"
                        global Failsafe := 0
                    }
                }
                Sleep(1000)
                if PixelSearch(&mX,&mY,320,420,480,460,"0x8cf813",3) {
                    SendEvent "{Click, 400, 330}"
                    Sleep(500)
                    SendText CostMap["Price"]
                    Sleep(500)
                    loop {
                        if PixelSearch(&mX,&mY,420,420,450,460,"0x8cf813",3) {
                            Click(mX,mY)
                            Sleep(500)
                        } 
                        if PixelSearch(&mX,&mY,451,420,480,460,"0x8cf813",3) {
                            Click(mX,mY)
                            Sleep(500)
                        } else {
                            break()
                        }
                        Failsafe += 1
                        if Failsafe = 20 {
                            CleanUI()
                            SendEvent "{E}"
                            global Failsafe := 0
                        }
                    }
                    SendEvent "{Click, 400, 200, 0}"
                    Sleep(1000)
                    loop {
                        if PixelSearch(&mX,&mY,205,420,215,480,"0x96fa17",3) {
                            Click(mX,mY)
                            Sleep(500)
                        }
                        if PixelSearch(&mX,&mY,216,420,230,480,"0x96fa17",3) {
                            Click(mX,mY)
                            Sleep(500)
                        } else {
                            break()
                        }
                        Failsafe += 1
                        if Failsafe = 20 {
                            CleanUI()
                            SendEvent "{E}"
                            global Failsafe := 0
                        }
                    }
                } else {
                    CleanUI()
                    SendEvent "{E}"
                }
            }
        }
    }
}

F1::Main()
F2::Pause -1
F3::ExitApp()
F4::MainGUI.Show

LoadSettings() {
    if FileExist(A_MyDocuments "\Settings\Settings.ini") {
        for Key, Value in ItemMap { ; a map has a value and a key its like "something", true, yk the 2nd thing is key
            try {
                ItemMap[Key] := IniRead(A_MyDocuments "\Settings\Settings.ini", "ItemMap", Key) ; so you have the map you wanna load stuff into and it reads the ini file called settings ini in documents pets go then theres the section called toggles map and which key it should load
            }
        }
        for Key, Value in CostMap {
            try {
                CostMap[Key] := IniRead(A_MyDocuments "\Settings\Settings.ini", "CostMap", Key)
            }
        }
        try {
            global KindNum := IniRead(A_MyDocuments "\Settings\Settings.ini", "Numbers", "KindNum")
            global AmountNum := IniRead(A_MyDocuments "\Settings\Settings.ini", "Numbers", "AmountNum")
            global KindValue := IniRead(A_MyDocuments "\Settings\Settings.ini", "Numbers", "KindValue")
            global AmountValue := IniRead(A_MyDocuments "\Settings\Settings.ini", "Numbers", "AmountValue")
        }
    }
}