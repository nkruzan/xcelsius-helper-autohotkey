SetBatchLines -1
SetWinDelay, 0
SetTitleMatchMode, RegEx
#Persistent
#NoTrayIcon
SetBatchLines, -1
OnExit, SaveSettingsAndExit
Run, "C:\Program Files\Business Objects\Crystal Xcelsius Designer 4.5\xcelsius.exe"
WinWaitActive,Crystal Xcelsius Designer 4.5 ahk_class (Afx:400000:b:10011:6).*
;Sleep, 2500
;MsgBox Found Window

SettingsList = USEAUTOPOSITION,USEHOTKEYS,USETOOLWINDOWSTYLE,TIMERFREQUENCY
PositionsList = PROPERTIESX,PROPERTIESH,PROPERTIESW,PROPERTIESY
; DEFAULT SETTINGS **********************************************************
USEHOTKEYS 			:= 1 	; Enable Hotkeys ?
USEAUTOPOSITION 	:= 1 	; Remember window position ?
USETOOLWINDOWSTYLE 	:= 1 	; Use Tool Window Style ? (Small caption)
TIMERFREQUENCY 		:= 10 	; How often to check for new windows and user defined window position
;Saved user placement values - blank to start off
PROPERTIESX := 0
PROPERTIESY := 0
PROPERTIESH := 0
PROPERTIESW := 0
; ************************************************************************
if FileExist("XcelsiusHelper.ini") {
	Loop, Parse, SettingsList, `,
		IniRead, %A_LoopField%, XcelsiusHelper.ini, SETTINGS,%A_LoopField%, % %A_LoopField%
	Loop, Parse, PositionsList, `,
		IniRead, %A_LoopField%, XcelsiusHelper.ini, POSITIONS,%A_LoopField%, % %A_LoopField%
	}
if USEHOTKEYS 
	GoSub, InitHotKeys
GoSub, FindMainWindow
Return

;Esc::ExitApp

HidePropertiesWindow:
hProperties := WinExist("Properties ahk_class #32770 ahk_pid " . Xcelsius_PID)
if  (hProperties) {
	WinClose, ahk_id %hProperties%
	}else{
		Send % A_ThisHotkey
		}
Return


InitHotKeys:
; Not yet implemented
Return
;ahk_class Afx:400000:b:10011:6:750899
;:1a0891
FindMainWindow:
if !hMain := WinExist("Crystal Xcelsius Designer 4.5 ahk_class (Afx:400000:b:10011:6).*") {
	SetTimer, FindMainWindow, -500
	Return
	}
;Sleep, 5000
WinGet, Xcelsius_PID, PID, ahk_id %hMain%
;MsgBox Window Found
SetTimer, WatchWindows, -%TIMERFREQUENCY%
Return

SaveSettingsAndExit:
Loop, Parse, SettingsList, `,
	IniWrite, % %A_LoopField%, XcelsiusHelper.ini, SETTINGS,%A_LoopField%
if USEAUTOPOSITION {
	Loop, Parse, PositionsList, `,
		IniWrite, % %A_LoopField%, XcelsiusHelper.ini, POSITIONS,%A_LoopField%
	}
ExitApp
Return

WatchWindows:
if !WinExist("Crystal Xcelsius Designer 4.5 ahk_class (Afx:400000:b:10011:6).*") {
	GoTo SaveSettingsAndExit
	}

ControlGet, hCanvas, Hwnd,,Afx:400000:81, ahk_id %hMain%
hProperties := WinExist("Properties ahk_class #32770 ahk_pid " . Xcelsius_PID)
if  (hProperties) {
	if (hProperties = hProperties_Old) {
		WinGetPos, PROPERTIESX, PROPERTIESY, PROPERTIESW, PROPERTIESH, ahk_id %hProperties%
		}else{
			WinSet, Trans, 0, ahk_id %hProperties%
			if USETOOLWINDOWSTYLE {
				WinGet, ExStyle, ExStyle, ahk_id %hProperties%
				if !(ExStyle & 0x80) { ; if not already a toolwindow
					WinSet, ExStyle, +0x80, ahk_id %hProperties% ; make it one
					}
				}
			WinGetPos, mX, mY, mW, mH, ahk_id %hMain%
			WinGetPos, cX, cY, cW, cH, ahk_id %hCanvas%
			;ControlGetPos, cX, cY, cW, cH,Afx:400000:81, ahk_id %hMain%
			;OffSetLeft 		:= cX
			OffSetRight 	:= mW - (cX + cW)
			;OffSetTop 		:= cY
			OffSetBottom 	:= mH - (cY + cH)
			WinGetPos, pX, pY, pW, pH, ahk_id %hProperties%
			if ((PROPERTIESX||PROPERTIESY||PROPERTIESW||PROPERTIESH)&&USEAUTOPOSITION)
				WinMove,ahk_id %hProperties%,,PROPERTIESX, PROPERTIESY, PROPERTIESW, PROPERTIESH
			else
				WinMove,ahk_id %hProperties%,,mW - (OffSetRight + pW),mH - (OffSetBottom+cH),pW,cH
			hProperties_Old := hProperties
			WinSet, Trans, 255, ahk_id %hProperties%
			}
	}
if USETOOLWINDOWSTYLE {
	hObjectBrowser := WinExist("Object Browser ahk_class #32770 ahk_pid " . Xcelsius_PID)
	if  ((hObjectBrowser)&&(hObjectBrowser != hObjectBrowser_Old)){
		hObjectBrowser_Old := hObjectBrowser
		WinGet, ExStyle, ExStyle, ahk_id %hObjectBrowser%
		if !(ExStyle & 0x80) { ; if not already a toolwindow
			WinSet, ExStyle, +0x80, ahk_id %hObjectBrowser% ; make it one
			}
		}
	hComponents := WinExist("Components ahk_class #32770 ahk_pid " . Xcelsius_PID)
	if  ((hComponents)&&(hComponents != hComponents_Old)){
		hComponents_Old := hComponents
		WinGet, ExStyle, ExStyle, ahk_id %hComponents%
		if !(ExStyle & 0x80) { ; if not already a toolwindow
			WinSet, ExStyle, +0x80, ahk_id %hComponents% ; make it one
			}
		}
	}
SetTimer, WatchWindows, -%TIMERFREQUENCY%
Return


