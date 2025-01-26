#SingleInstance Off
ListLines 0
KeyHistory 0
SetWinDelay -1
SetControlDelay -1

argTimeExplain := "n分後: [0-9]+`nh時間m分s秒後: [0-9]+h[0-9]+m[0-9]+s`n次の時分: [0-2][0-9]:[0-5][0-9]"

if (A_Args.length == 0) {
  MsgBox("Needs Arguments.`n`ntime [message]`n`ntime:`n" . argTimeExplain)
  ExitApp
}

TraySetIcon(A_ScriptDir . "\alarm.ico", , true)
inputtime := A_Args[1]

if (getTargetTime(inputtime) == 0) {
  MsgBox("時間指定が不正です: " . inputtime . "`n`n" . argTimeExplain)
  ExitApp
}

s := FormatTime(getTargetTime(inputtime), "HH:mm:ss ") . getMessage()
; Notify
TrayTip(s, "Alarm", 1)
; Set tray icon tooltip
A_IconTip := s
; MsgBox(DateDiff(getTargetTime(), A_Now, "Seconds") . "秒")
SetTimer(Alarm, DateDiff(A_Now, getTargetTime(inputtime), "Seconds")*1000)
ESC::ExitApp

Alarm() {
  MyGui := Gui()
  MyGui.Opt("+AlwaysOnTop")
  MyGui.SetFont("s32 w600")
  MyGui.Add("Text", "x0 w600 y150 Center", getMessage())
  MyGui.Show("w600 h400")
  MyGui.GetPos(&x,&y)
  Loop 2 {
    Sleep(100)
    MyGui.Move(x-100, y)
    Sleep(100)
    MyGui.Move(x, y-100)
    Sleep(100)
    MyGui.Move(x, y+100)
    Sleep(100)
    MyGui.Move(x+100, y)
    Sleep(100)
    MyGui.Move(x, y)
  }
}

getTargetTime(inputtime) {
  temp := getDeltaSeconds(inputtime)
  now := A_Now
  if temp != 0 {
    return DateAdd(now, temp, "Seconds")
  }

  if RegExMatch(inputtime, "^([0-9]+):([0-9]+)$", &hm) {
    new :=  SubStr(now, 1, 8) . hm[1] . hm[2] . "00"
    if (new > now) {
      return new
    }

    tomorrow := DateAdd(now, 1, "Days")
    return SubStr(tomorrow, 1, 8) . hm[1] . hm[2] . "00"
  }
  return 0
}

getDeltaSeconds(inputtime) {
  if IsNumber(inputtime) {
    ; 数字だけなら分として扱う
    return inputtime*60
  }
  ; h 時間 m 分 s 秒
  if RegExMatch(inputtime, "^[0-9hms]+$") {
    h := 0
    m := 0
    s := 0
    total := 0
    temp := ""
    chars := StrSplit(inputtime, "")
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
        MsgBox("実装おかしいよ " . inputtime)
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
    message := "It's time!"
  }
  return message
}
