#SingleInstance Off
ListLines 0
KeyHistory 0
SetWinDelay -1
SetControlDelay -1

global ArgTimeExplain := "  N minutes later: [0-9]+`n"
. "  H hours M minutes S seconds later: [0-9]+h[0-9]+m[0-9]+s`n"
. "  Next hour:minute: [0-2][0-9]:[0-5][0-9]`n"
. "  Show alarm list: l"
global ListFile := Format("{}\alarm.lst", A_ScriptDir)
global LogFile := Format("{}\alarm.log", A_ScriptDir)
global WindowMoveInterval := 100
global WindowMoveRange := 100
global WindowWidth := 600
global WindowHeight := 400
global DefaultMessage := "It's time!"

if (A_Args.length == 0) {
  MsgBox("Needs Arguments.`n`nUsage:`n  time [message]`n`ntime:`n" . ArgTimeExplain, "AHK-alarm")
  ExitApp
}

; Show alarm list
if (A_Args[1] == "l") {
  displayAlarmList()
  ExitApp
}

targetTime := getTargetTime(A_Args[1])
if (targetTime == 0) {
  MsgBox(Format("Invalid time format: {}`n`n{}", A_Args[1], ArgTimeExplain))
  ExitApp
}

global alarmString := Format("{} {}`n", FormatTime(targetTime, "M/d HH:mm:ss"), getMessage())
TraySetIcon(Format("{}\alarm.ico", A_ScriptDir), , true)
; Adding Notify
TrayTip(alarmString, "Alarm", 1)
; Set tray icon tooltip
A_IconTip := alarmString

SetTimer(Alarm, DateDiff(A_Now, targetTime, "Seconds")*1000)
FileAppend(alarmString, ListFile)
log("Add alarm: " . getArgs(), LogFile)

displayAlarmList() {
  if FileExist(ListFile) && FileGetSize(ListFile) > 0 {
    MsgBox(FileRead(ListFile), "Alarm List")
  } else {
    MsgBox("No alarms set yet.", "Alarm List")
  }
}

Alarm() {
  if (!FileExist(ListFile)) {
    log("Deleted list file: " . ListFile, LogFile)
    MsgBox("Deleted list file: " . ListFile, "AHK-Alarm")
    ExitApp
  }

  list := FileRead(ListFile)

  ; Remove the triggered alarm from the list
  newList := StrReplace(list, alarmString, , 1, &count)

  ; If the alarm was already deleted (not found in list), just log and exit.
  if (count == 0) {
    log("Deleted: " . getMessage(), LogFile)
    ExitApp
  }

  ; Write the updated list back to the file
  FileDelete(ListFile)
  FileAppend(newList, ListFile)

  ; Create and display the alarm GUI
  MyGui := Gui()
  MyGui.Opt("+AlwaysOnTop")
  MyGui.SetFont(Format("s32 w{}", WindowWidth))
  MyGui.Add("Text", Format("x0 w{} y150 Center", WindowWidth), getMessage())
  MyGui.Show(Format("w{} h{}", WindowWidth, WindowHeight))
  MyGui.GetPos(&x,&y)
  Loop 2 {
    Sleep(WindowMoveInterval)
    MyGui.Move(x-WindowMoveRange, y)
    Sleep(WindowMoveInterval)
    MyGui.Move(x, y-WindowMoveRange)
    Sleep(WindowMoveInterval)
    MyGui.Move(x, y+WindowMoveRange)
    Sleep(WindowMoveInterval)
    MyGui.Move(x+WindowMoveRange, y)
    Sleep(WindowMoveInterval)
    MyGui.Move(x, y)
  }
  log("Alarm: " . getMessage(), LogFile)
}

getTargetTime(inputTime) {
  ; Try parsing as a delta time (e.g., "10", "1h30m")
  temp := getDeltaSeconds(inputTime)
  now := A_Now
  if temp != 0 {
    return DateAdd(now, temp, "Seconds")
  }

  ; Try parsing as specific hour:minute (e.g., "14:30")
  if RegExMatch(inputTime, "^([0-2]?[0-9]):([0-5]?[0-9])$", &hm) {
    new := Format("{}{:02}{:02}00", SubStr(now, 1, 8), hm[1], hm[2], "00")
    if (new > now) {
      return new
    }

    tomorrow := DateAdd(now, 1, "Days")
    return Format("{}{:02}{:02}00", SubStr(tomorrow, 1, 8), hm[1], hm[2], "00")
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

getArgs() {
  args := ""
  Loop A_Args.Length {
    if (args == "") {
      args := A_Args[A_Index]
    } else {
      args := args . " " . A_Args[A_Index]
    }
  }
  return args
}

getMessage() {
  if (A_Args.Length <= 1) {
    return DefaultMessage
  }

  message := ""
  Loop A_Args.Length {
    if (A_Index == 1) {
      continue
    }

    if (message == "") {
      message := A_Args[A_Index]
    } else {
      message := message . " " . A_Args[A_Index]
    }
  }
  return message
}

log(text, file) {
  FileAppend(Format("{} {}`n", FormatTime(, "yyyy-MM-dd HH:mm:ss"), text), file)
}
