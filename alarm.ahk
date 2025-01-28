#SingleInstance Off
ListLines 0
KeyHistory 0
SetWinDelay -1
SetControlDelay -1

argTimeExplain := "N minutes later: [0-9]+`nH hours M minutes S seconds later: [0-9]+h[0-9]+m[0-9]+s`nNext hour:minute: [0-2][0-9]:[0-5][0-9]"
listfile := A_ScriptDir . "\alarm.lst"
windowMoveInterval := 100
windowMoveRange := 100
windowWidth := 600
windowHeight := 400
defaultMessage := " It's time!"

if (A_Args.length == 0) {
  MsgBox("Needs Arguments.`n`ntime [message]`n`ntime:`n" . argTimeExplain)
  ExitApp
}

TraySetIcon(A_ScriptDir . "\alarm.ico", , true)
inputTime := A_Args[1]

; View alarm list
if (inputTime == "l") {
  MsgBox(FileRead(listfile))
  ExitApp
}

if (getTargetTime(inputTime) == 0) {
  MsgBox("Invalid time format: " . inputTime . "`n`n" . argTimeExplain)
  ExitApp
}

s := FormatTime(getTargetTime(inputTime), "HH:mm:ss") . getMessage() . "`n"
; Adding Notify
TrayTip(s, "Alarm", 1)
; Set tray icon tooltip
A_IconTip := s

SetTimer(Alarm, DateDiff(A_Now, getTargetTime(inputTime), "Seconds")*1000)
FileAppend(s, listfile)

Alarm() {
  list := FileRead(listfile)
  newList := StrReplace(list, s, , 1, &count)
  ; Do not display the alarm if it has been deleted.
  if (count == 0) {
    ExitApp
  }
  FileDelete(listfile)
  FileAppend(newList, listfile)
  MyGui := Gui()
  MyGui.Opt("+AlwaysOnTop")
  MyGui.SetFont(Format("s32 w{}", windowWidth))
  MyGui.Add("Text", Format("x0 w{} y150 Center", windowWidth), getMessage())
  MyGui.Show(Format("w{} h{}", windowWidth, windowHeight))
  MyGui.GetPos(&x,&y)
  Loop 2 {
    Sleep(windowMoveInterval)
    MyGui.Move(x-windowMoveRange, y)
    Sleep(windowMoveInterval)
    MyGui.Move(x, y-windowMoveRange)
    Sleep(windowMoveInterval)
    MyGui.Move(x, y+windowMoveRange)
    Sleep(windowMoveInterval)
    MyGui.Move(x+windowMoveRange, y)
    Sleep(windowMoveInterval)
    MyGui.Move(x, y)
  }
}

getTargetTime(inputTime) {
  temp := getDeltaSeconds(inputTime)
  now := A_Now
  if temp != 0 {
    return DateAdd(now, temp, "Seconds")
  }

  if RegExMatch(inputTime, "^([0-2]?[0-9]):([0-5]?[0-9])$", &hm) {
    new := Format("{}{:02}{:02}00", SubStr(now, 1, 8), hm[1], hm[2], "00")
    if (new > now) {
      return new
    }

    tomorrow := DateAdd(now, 1, "Days")
    return Format("{}{:02}{:02}00", SubStr(now, 1, 8), hm[1], hm[2], "00")
  }
  return 0
}

getDeltaSeconds(inputTime) {
  if IsNumber(inputTime) {
    ; Treat it as minutes if it's only a number.
    return inputTime*60
  }
  ; H hours M minutes S seconds
  if RegExMatch(inputTime, "^[0-9hms]+$") {
    h := 0
    m := 0
    s := 0
    total := 0
    temp := ""
    chars := StrSplit(inputTime, "")
    for c in chars {
      if IsNumber(c) {
        temp := temp . c
      } else if (c == "s") {
        total := total + temp
        temp := 0
      } else if (c := "m") {
        total := total + temp*60
        temp := 0
      } else if (c := "h") {
        total := total + temp*3600
        temp := 0
      } else {
        MsgBox("It's an incorrect implementation. `ntime: " . inputTime)
        ExitApp
      }
    }
    return total
  }
  return 0
}

getMessage() {
  message := ""
  if (A_Args.Length > 1) {
    Loop A_Args.Length {
      if (A_Index == 1) {
        continue
      }
      message := message . " " . A_Args[A_Index]
    }
  } else {
    message := defaultMessage
  }
  return message
}
