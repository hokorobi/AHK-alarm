[Japanese README](README-ja.md)

## Overview
An alarm application using Autohotkey v2.

## Command Line

alarm.ahk time [message1 message2 ...]

- time: Specify the time to display the alarm. There are formats for specifying elapsed time from the current time and for specifying a specific time.<br>
  "l" will display the list of alarms.

  - If only a number "N" is given, the alarm will display "N" minutes after the current time.<br>
    Adding "h", "m", or "s" to the number treats it as "hours", "minutes", or "seconds" respectively.<br>
    You can also combine them, such as 1h2m3s.

    - Example 1: alarm.ahk 10<br>
      Alarm will display in 10 minutes.
    - Example 2: alarm.ahk 1h10m<br>
      Alarm will display in 1 hour and 10 minutes.
    - Example 3: alarm.ahk 1m10s<br>
      Alarm will display in 1 minute and 10 seconds.

  - Specify a time<br>
    An alarm will display at the specified time in hh:mm format.<br>
    If the specified time has already passed today, it will be understood as the same time tomorrow.

    - Example 1: alarm.ahk 20:28<br>
      Alarm will display at the next 20:28.

  - l<br>
    Displays the list of alarms.

- message1 message2 ...: Messages to be displayed in the alarm. Combine all messages with a half-width space.

## Stopping the Alarm

Delete the corresponding line of the alarm from alarlm.lst located in the same folder as alarm.ahk.<br>
The process will remain, but the alarm window will no longer be displayed. 

