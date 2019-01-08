#pragma compile(FileVersion, 1.6.6.0)
#pragma compile(Icon, .\images\upsicon.ico)
#pragma compile(Out, .\Build\upsclient.exe)
#pragma compile(Compression, 1)
#pragma compile(Comments, 'Windows NUT Client')
#pragma compile(FileDescription, Windows NUT Client. This is a NUT windows client for monitoring your ups hooked up to your favorite linux server.)
#pragma compile(LegalCopyright, Freeware)
#pragma compile(ProductName, WinNUT-Client)
#pragma compile(Compatibility, win7, win8, win81, win10)
;
#include <GUIConstants.au3>
#include <Misc.au3>
#Include <Constants.au3>
#include <Array.au3>
#include <TrayConstants.au3>
#include "nutGlobal.au3"
#include "nutDraw.au3"
#include "nutColor.au3"
#include "nutOption.au3"
#include "nutGui.au3"
#include "nutNetwork.au3"
#Include "nutTreeView.au3"

If UBound(ProcessList(@ScriptName)) > 2 Then Exit

;This function repaints all needles when required and passes on control
;to internal AUTOIT repaint handler
;This is registered for WM_PAINT event
Func rePaint()
	repaintNeedle($needle6 , $battCh ,$dial6 ,0 , 100 )
	repaintNeedle($needle4 ,  $battVol ,$dial4 ,getOption("minbattv") , getOption("maxbattv") )
	repaintNeedle($needle5 , $upsLoad ,$dial5 ,getOption("minupsl") , getOption("maxupsl") )
	repaintNeedle($needle1 , $inputVol ,$dial1, getOption("mininputv") , getOption("maxinputv") )
	repaintNeedle($needle2 , $outputVol , $dial2, getOption("minoutputv") , getOption("maxoutputv"))
	repaintNeedle($needle3 , $inputFreq , $dial3 ,getOption("mininputf"), getOption("maxinputf") )
	return $GUI_RUNDEFMSG
EndFunc

Func prefGui()
	Local $Iipaddr = 0
	Local $Iport = 0
	Local $Iupsname = 0
	Local $Idelay = 0
	Local $tempcolor1 , $tempcolor2
	Local $result = 0
	$tempcolor2 = $clock_bkg
	$tempcolor1 = $panel_bkg
	ReadParams()
	if $guipref <> 0 Then
		GuiDelete($guipref)
		$guipref = 0
	EndIf
	$minimizetray = GetOption("minimizetray")
	If $minimizetray == 1 Then
		TraySetClick(0)
	EndIf
	$guipref = GUICreate("Preferences", 364, 331, 190, 113,-1,-1,$gui  )
	GUISetIcon(@tempdir & "upsicon.ico")
	$Bcancel = GUICtrlCreateButton("Cancel", 286, 298, 75, 25, 0)
	$Bapply = GUICtrlCreateButton("Apply", 206, 298, 75, 25, 0)
	$Bok = GUICtrlCreateButton("OK", 126, 298, 75, 25, 0)
	$Tconnection = GUICtrlCreateTab(0, 0, 361, 289)
	$TSconnection = GUICtrlCreateTabItem("Connection")
	$Iipaddr = GUICtrlCreateInput(GetOption("ipaddr"), 74, 37, 249, 21)
	$Lipaddr = GUICtrlCreateLabel("UPS host :", 16, 40, 59, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	$Lport = GUICtrlCreateLabel("UPS port :", 16, 82, 59, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	$Iport = GUICtrlCreateInput(GetOption("port"), 74, 77, 73, 21)
	$Lname = GUICtrlCreateLabel("UPS name :", 16, 122, 59, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	$Iupsname = GUICtrlCreateInput(GetOption("upsname"), 74, 120, 249, 21)
	$Ldelay = GUICtrlCreateLabel("Delay :", 16, 162, 51, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	$Idelay = GUICtrlCreateInput(GetOption("delay"), 74, 159, 73, 21)
	$Checkbox1 = GUICtrlCreateCheckbox("ACheckbox1", 334, 256, 17, 17,BitOr($BS_AUTOCHECKBOX,$WS_TABSTOP ),$WS_EX_STATICEDGE )
	$Label9 = GUICtrlCreateLabel("Re-establish connection", 217, 256, 115, 17)

	$TabSheet2 = GUICtrlCreateTabItem("Colors")
	GUICtrlCreateLabel("Panel background color", 16, 48, 131, 25)
	GUICtrlCreateLabel("Analogue background color", 16, 106, 179, 25)
	$colorchoose1 = GUICtrlCreateLabel("", 232, 40, 25, 25,Bitor($SS_SUNKEN,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetBkColor(-1, $panel_bkg)
	$colorchoose2 = GUICtrlCreateLabel("", 232, 104, 25, 25,Bitor($SS_SUNKEN,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetBkColor(-1, $clock_bkg)
	GUICtrlCreateTabItem("Calibration")
	GUICtrlCreateLabel("Input Voltage", 16, 56, 75, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel("Input Frequency", 16, 96, 91, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel("Output Voltage", 16, 136, 91, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel("UPS Load", 16, 176, 91, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel("Battery Voltage", 16, 216, 91, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel("Min", 136, 32, 23, 19)
	GUICtrlCreateLabel("Max", 219, 32, 25, 19)
	$lminInputVoltage = GUICtrlCreateInput(GetOption("mininputv"), 121, 56, 49, 23)
	$lmaxInputVoltage = GUICtrlCreateInput(GetOption("maxinputv"), 210, 56, 49, 23)
	$lminInputFreq = GUICtrlCreateInput(GetOption("mininputf"), 121, 96, 49, 23)
	$lmaxInputFreq = GUICtrlCreateInput(GetOption("maxinputf"), 210, 96, 49, 23)
	$lminOutputVoltage = GUICtrlCreateInput(GetOption("minoutputv"), 121, 136, 49, 23)
	$lmaxOutputVoltage = GUICtrlCreateInput(GetOption("maxoutputv"), 210, 136, 49, 23)
	$lminUpsLoad = GUICtrlCreateInput(GetOption("minupsl"), 121, 176, 49, 23)
	$lmaxUpsLoad = GUICtrlCreateInput(GetOption("maxupsl"), 210, 176, 49, 23)
	$lminBattVoltage = GUICtrlCreateInput(GetOption("minbattv"), 121, 216, 49, 23)
	$lmaxBattVoltage = GUICtrlCreateInput(GetOption("maxbattv"), 210, 216, 49, 23)

	$TabSheet1 = GUICtrlCreateTabItem("Misc")
	GUICtrlCreateLabel("Minimize to tray", 16, 42, 99, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	$chMinimizeTray = GUICtrlCreateCheckbox("MinimizeTray", 224, 39, 17, 17,BitOr($BS_AUTOCHECKBOX,$WS_TABSTOP ),$WS_EX_STATICEDGE)
	$lblstartminimized = GUICtrlCreateLabel("Start Minimized", 16, 84, 99, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	$chstartminimized = GUICtrlCreateCheckbox("StartMinimized", 224, 81, 17, 17,BitOr($BS_AUTOCHECKBOX,$WS_TABSTOP ),$WS_EX_STATICEDGE)
	$lblclosetotray = GUICtrlCreateLabel("Close to Tray", 16, 126, 99, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	$chclosetotray = GUICtrlCreateCheckbox("ClosetoTray", 224, 123, 17, 17,BitOr($BS_AUTOCHECKBOX,$WS_TABSTOP ),$WS_EX_STATICEDGE)
	if GetOption("minimizetray") == 0 Then
		GuiCtrlSetState($chMinimizeTray, $GUI_UNCHECKED)
		GuiCtrlSetState($chstartminimized, $GUI_UNCHECKED)
		GuiCtrlSetState($chclosetotray, $GUI_UNCHECKED)
		GUICtrlSetState($lblstartminimized, $GUI_DISABLE)
		GUICtrlSetState($chstartminimized, $GUI_DISABLE)
		GUICtrlSetState($lblclosetotray, $GUI_DISABLE)
		GUICtrlSetState($chclosetotray, $GUI_DISABLE)
	Else
		GuiCtrlSetState($chMinimizeTray , $GUI_CHECKED)
		GUICtrlSetState($lblstartminimized,$GUI_ENABLE)
		GUICtrlSetState($chstartminimized,$GUI_ENABLE)
		GUICtrlSetState($lblclosetotray, $GUI_ENABLE)
		GUICtrlSetState($chclosetotray, $GUI_ENABLE)
		if GetOption("minimizeonstart") == 0 Then
			GuiCtrlSetState($chstartminimized, $GUI_UNCHECKED)
		Else
			GuiCtrlSetState($chstartminimized, $GUI_CHECKED)
		EndIf
		if GetOption("closetotray") == 0 Then
			GuiCtrlSetState($chclosetotray, $GUI_UNCHECKED)
		Else
			GuiCtrlSetState($chclosetotray, $GUI_CHECKED)
		EndIf
	EndIf

	$lblstartwithwindows = GUICtrlCreateLabel("Start with Windows", 16, 168, 99, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	$chStartWithWindows = GUICtrlCreateCheckbox("Startwithwindows", 224, 167, 17, 17,BitOr($BS_AUTOCHECKBOX,$WS_TABSTOP ),$WS_EX_STATICEDGE)
	if $runasexe == True Then
		GUICtrlSetState($chStartWithWindows,$GUI_ENABLE)
		GUICtrlSetState($lblstartwithwindows,$GUI_ENABLE)
		if GetOption("startwithwindows") == 0 Then
			GuiCtrlSetState($chStartWithWindows , $GUI_UNCHECKED)
		Else
			GuiCtrlSetState($chStartWithWindows , $GUI_CHECKED)
		EndIf
	Else
		GuiCtrlSetState($chStartWithWindows , $GUI_UNCHECKED)
		GUICtrlSetState($lblstartwithwindows,$GUI_DISABLE)
		GUICtrlSetState($chStartWithWindows,$GUI_DISABLE)
	EndIf
	GUICtrlCreateLabel("Shutdown if battery lower then", 16, 210, 179, 17, BitOR($SS_BLACKRECT,$SS_GRAYFRAME,$SS_LEFTNOWORDWRAP))
	$lshutdownPC = GUICtrlCreateInput(GetOption("shutdownpc"), 217, 207, 25, 23)
	GUICtrlCreateLabel("%", 248, 210, 15, 19)

	GUICtrlCreateTabItem("")
	GuiSetState(@SW_DISABLE,$gui )
	GUISetState(@SW_SHOW,$guipref)

	While 1
		$nMsg1 = GUIGetMsg()
		Switch $nMsg1
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $Bapply, $Bok
				SetOption("ipaddr",GuiCtrlRead($Iipaddr ) , "string")
				SetOption("port",GuiCtrlRead($Iport ) , "number")
				SetOption("upsname",GuiCtrlRead($Iupsname ) , "string")
				SetOption("delay",GuiCtrlRead($Idelay ) , "number")
				SetOption("mininputv",GuiCtrlRead($lminInputVoltage ) , "number")
				SetOption("maxinputv",GuiCtrlRead($lmaxInputVoltage ) , "number")
				SetOption("minoutputv",GuiCtrlRead($lminOutputVoltage ) , "number")
				SetOption("maxoutputv",GuiCtrlRead($lmaxOutputVoltage ) , "number")
				SetOption("mininputf",GuiCtrlRead($lminInputFreq ) , "number")
				SetOption("maxinputf",GuiCtrlRead($lmaxInputFreq ) , "number")
				SetOption("minupsl",GuiCtrlRead($lminUpsLoad ) , "number")
				SetOption("maxupsl",GuiCtrlRead($lmaxUpsLoad ) , "number")
				SetOption("minbattv",GuiCtrlRead($lminBattVoltage ) , "number")
				SetOption("maxbattv",GuiCtrlRead($lmaxBattVoltage ) , "number")
				SetOption("shutdownpc",GuiCtrlRead($lshutdownPC ) , "number")
				$minimizetray = GuiCtrlRead($chMinimizeTray)
				If $minimizetray == $GUI_CHECKED Then
					SetOption("minimizetray",1 , "number")
					$startminimized = GuiCtrlRead($chstartminimized)
					If $startminimized == $GUI_CHECKED Then
						SetOption("minimizeonstart",1 , "number")
					Else
						SetOption("minimizeonstart",0 , "number")
					EndIf
					$closetotray = GuiCtrlRead($chclosetotray)
					If $closetotray == $GUI_CHECKED Then
						SetOption("closetotray",1 , "number")
					Else
						SetOption("closetotray",0 , "number")
					EndIf
				Else
					SetOption("minimizetray",0 , "number")
					SetOption("minimizeonstart",0 , "number")
					SetOption("closetotray",0 , "number")
				EndIf
				If $runasexe == True Then
					$startwithwindows = GuiCtrlRead($chStartWithWindows)
					$linkexe = @StartupDir & "\Upsclient.lnk"
					if $startwithwindows == $GUI_CHECKED Then
						SetOption("startwithwindows" , 1 , "number")
						if FileExists($linkexe) == 0 Then
							FileCreateShortcut(@ScriptFullPath, $linkexe)
						EndIf
					Else
						if FileExists($linkexe) <> 0 Then
							FileDelete($linkexe)
						EndIf
						SetOption("startwithwindows" , 0 , "number")
					EndIf
				Else
					SetOption("startwithwindows" , 0 , "number")
				EndIf
				$panel_bkg = $tempcolor1
				$clock_bkg = $tempcolor2
				$clock_bkg_bgr = RGBtoBGR($clock_bkg)
				GuiSetBkColor($clock_bkg , $dial1)
				GuiSetBkColor($clock_bkg , $dial2)
				GuiSetBkColor($clock_bkg , $dial3)
				GuiSetBkColor($clock_bkg , $dial4)
				GuiSetBkColor($clock_bkg , $dial5)
				GuiSetBkColor($clock_bkg , $dial6)
				GUISetBkColor($panel_bkg ,  $wPanel )
				$result = 1
				WriteParams()
				setTrayMode()
				if $nMsg1 == $Bok then
					ExitLoop
				EndIf
			Case $Bcancel
				ExitLoop
			Case $colorchoose1
				$tempcolor1 = _ChooseColor ( 2, 0,2)
				if $tempcolor1 <> -1 Then
					;$panel_bkg = $tempcolor
					GuiCtrlSetBkColor($colorchoose1,$tempcolor1)
				Else
					$tempcolor1 = $panel_bkg
				EndIf
				$result = 1
			Case $colorchoose2
				$tempcolor2 = _ChooseColor ( 2, 0,2)
				if $tempcolor2 <> -1 Then
					;$panel_bkg = $tempcolor
					GuiCtrlSetBkColor($colorchoose2,$tempcolor2)
				Else
					$tempcolor2 = $clock_bkg
				EndIf
				$result = 1
			Case $chMinimizeTray
				$minimizetray = GuiCtrlRead($chMinimizeTray)
				If $minimizetray == $GUI_CHECKED Then
					GUICtrlSetState($lblstartminimized,$GUI_ENABLE)
					GUICtrlSetState($chstartminimized,$GUI_ENABLE)
					GUICtrlSetState($lblclosetotray, $GUI_ENABLE)
					GUICtrlSetState($chclosetotray, $GUI_ENABLE)
				Else
					GuiCtrlSetState($chstartminimized, $GUI_UNCHECKED)
					GuiCtrlSetState($chclosetotray, $GUI_UNCHECKED)
					GUICtrlSetState($lblstartminimized,$GUI_DISABLE)
					GUICtrlSetState($chstartminimized,$GUI_DISABLE)
					GUICtrlSetState($lblclosetotray, $GUI_DISABLE)
					GUICtrlSetState($chclosetotray, $GUI_DISABLE)
				EndIf
		EndSwitch
	WEnd
	If $minimizetray == 1 Then
		TraySetClick(8)
	EndIf
	GuiDelete($guipref)
	If (WinGetState($gui) <> 17 ) Then
		GuiSetState(@SW_ENABLE,$gui )
		WinActivate($gui)
	EndIf
	$guipref = 0
	return $result
EndFunc

Func updateVarList()
	$selected = _GUICtrlTreeViewGetTree1($TreeView1, "." , 0)
	GuiCtrlSetData($varselected , $selected)
	$upsval = ""
	$upsdesc = ""
	$checkstatus1 = GetUPSVar(GetOption("upsname") , $selected , $upsval)
	$checkstatus2 = GetUPSDescVar(GetOption("upsname") , $selected , $upsdesc)
	if $checkstatus1 == -1 or $checkstatus2 == -1 Then
		$upsval = ""
		$upsdesc = ""
	EndIf
	if GuiCtrlRead($varvalue ) <> $upsval Then
		GuiCtrlSetData($varvalue , $upsval)
	EndIf
	if GuiCtrlRead($vardesc ) <> $upsdesc Then
		GuiCtrlSetData($vardesc , $upsdesc)
	EndIf
EndFunc

Func varlistGui()
	$varlist = ""
	$templist = ""
	AdlibUnregister()
	$status1 = ListUPSVars(GetOption("upsname") , $varlist)
	$varlist = StringReplace($varlist , GetOption("upsname") , "")
	$vars = StringSplit($varlist , "VAR",1)
	AdlibRegister("Update",1000)
	$guilistvar = GUICreate("LIST UPS Variables", 365, 331, 196, 108, -1 , -1 , $gui)
	GUISetIcon(@tempdir & "upsicon.ico")
	$TreeView1 = GUICtrlCreateTreeView(0, 8, 361, 169)
	;$state = GUICtrlSetImage($TreeView1, @ScriptDir & "\light.ico", -1 , 4)

	$Group1 = GUICtrlCreateGroup("Item properties", 0, 184, 361, 105, $BS_CENTER)
	$Label1 = GUICtrlCreateLabel("Name :", 8, 200, 38, 17)
	$Label2 = GUICtrlCreateLabel("Value :", 8, 232, 37, 17)
	$Label3 = GUICtrlCreateLabel("Description :", 8, 264, 63, 17)
	$varselected = GUICtrlCreateLabel("", 50, 200, 291, 17, $SS_SUNKEN)
	$varvalue = GUICtrlCreateLabel("", 50, 232, 291, 17, $SS_SUNKEN)
	$vardesc = GUICtrlCreateLabel("", 72, 264, 283, 17, $SS_SUNKEN)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$Button1 = GUICtrlCreateButton("Reload", 80, 296, 65, 25, 0)
	$Button2 = GUICtrlCreateButton("Clear", 200, 296, 65, 25, 0)
	GuiSetState(@SW_DISABLE,$gui )
	GUISetState(@SW_SHOW , $guilistvar)

	$varcount = Ubound($vars) - 2
	$varlist = "";
	for $i = 3 to $varcount

		if $i == $varcount Then
			ContinueLoop
		EndIf
		$templist = StringSplit($vars[$i],'"')
		$curpath = StringStripWS($templist[1],3)
		_addPath($TreeView1, $curpath )
	Next
	_SetIcons($TreeView1, 0)
	_GUICtrlTreeView_Expand($TreeView1,0,false)

	AdlibUnregister()
	AdlibRegister("updateVarList",500)
	While 1
		$nMsg = GUIGetMsg(1)
		if ($nMsg[0] == $GUI_EVENT_CLOSE) Then
			AdlibUnregister()
			GuiSetState(@SW_ENABLE,$gui )
			GuiDelete($guilistvar)
			WinActivate($gui)
			AdlibRegister("Update",1000)

			return
		EndIf
		if ($nMsg[0] == $Button2) Then
			;_GUICtrlTreeViewDeleteAllItems ( $TreeView1 )
		EndIf
	WEnd
EndFunc

Func GetUPSInfo()
	Local $status = 0
	$mfr = ""
	$name = ""
	$serial = ""
	$firmware = ""
	if $socket == 0 Then ; not connected to server/connection lost
		Return
	EndIf
	$status = GetUPSVar(GetOption("upsname") ,"ups.mfr" , $mfr)
	if $status = -1 then ;UPS name wrong or variable not supported or connection lost

		if $socket == 0 Then
			Return
		EndIf
		if StringInStr($errorstring,"UNKNOWN-UPS") <> 0 Then
			$mfr = ""
			WriteLog("Disconnecting from server")
			TCPSend($socket,"LOGOUT")
			TCPCloseSocket($socket)
			WriteLog("Disconnected from server")
			$socket = 0
			ResetGui()
			Return
		EndIf
	EndIf

	$status = GetUPSVar(GetOption("upsname") ,"ups.model" , $name)
	if $status = -1 then
		if $socket == 0 Then
			Return
		EndIf
		$name =""
	EndIf

	$status = GetUPSVar(GetOption("upsname") ,"ups.serial" , $serial)
	if $status = -1 then
		if $socket == 0 Then
			Return
		EndIf
		$serial =""
	EndIf

	$status = GetUPSVar(GetOption("upsname") ,"ups.firmware" , $firmware)
	if $status = -1 then
		if $socket == 0 Then
			Return
		EndIf
		$firmware =""
	EndIf
EndFunc

Func SetUPSInfo()
	if $socket == 0 Then ;if not connected or connection lost
		$mfr = ""
		$name = ""
		$serial = ""
		$firmware = ""
	EndIf
	GuiCtrlSetData($upsmfr,$mfr)
	GuiCtrlSetData($upsmodel,$name)
	GuiCtrlSetData($upsserial,$serial)
	GuiCtrlSetData($upsfirmware,$firmware)
EndFunc

Func GetData()
	Local $status = "0"
	$ups_name = GetOption("upsname")
	if $socket == 0 then
		return -1
	EndIf
	GetUPSVar($ups_name ,"battery.charge" , $battch)
	GetUPSVar($ups_name ,"battery.voltage",$battVol)
	GetUPSVar($ups_name ,"input.frequency",$inputFreq)
	GetUPSVar($ups_name ,"input.voltage",$inputVol)
	GetUPSVar($ups_name ,"output.voltage",$outputVol)
	GetUPSVar($ups_name ,"ups.load",$upsLoad)
	GetUPSVar($ups_name ,"ups.status",$upsstatus)
	return 0
EndFunc

Func Nothing()
	Return
EndFunc

Func UpdateValue(byref $needle , $value , $label , $whandle ,$min = 170, $max = 270, $force = 0)
	$oldval = Round (GuiCtrlRead($label))
	if $oldval < $min Then
		$oldval = $min
	EndIf
	if $oldval > $max Then
		$oldval = $max
	EndIf
	if $oldval == Round($value) and $force == 0 Then
		Return
	EndIf
	GuiCtrlSetData($label , $value )
	$value = Round($value )
	if $value < $min Then
		$value = $min
	EndIf
	if $value > $max Then
		$value = $max
	EndIf
	$oldneedle = ($oldval - $min) / ( ($max - $min ) / 100 )
	if $oldneedle > 0 or $oldneedle == 0 then
		DrawNeedle(15 + $oldneedle ,$clock_bkg_bgr , $whandle , $needle)
	EndIf
	$setneedle =($value - $min)/ ( ($max - $min ) / 100 )
	DrawNeedle(15 + $setneedle ,0x0 , $whandle , $needle)

EndFunc

Func ResetGui()
	if $socket == 0  Then
		$battVol = 0
		$battCh = 0
		$upsLoad = 0
		$inputVol = 0
		$outputVol = 0
		$inputFreq = 0
	EndIf
	UpdateValue($needle4 , 0 , $battv ,$dial4 , getOption("minbattv"), getOption("maxbattv") )
	UpdateValue($needle5 , 0 , $upsl , $dial5 , getOption("minupsl") , getOption("maxupsl") )
	UpdateValue($needle6 , 0 , $upsch , $dial6 , 0 , 100 )
	UpdateValue($needle1 , 0, $inputv ,$dial1 , getOption("mininputv") , getOption("maxinputv"))
	UpdateValue($needle2 , 0, $outputv ,$dial2 , getOption("minoutputv") , getOption("maxoutputv"))
	UpdateValue($needle3 , 0, $inputf , $dial3 , getOption("mininputf") , getOption("maxinputf") )
	GuiCtrlSetBkColor( $upsonline , $gray )
	GuiCtrlSetBkColor($upsonbatt , $gray )
	GUICtrlSetBkColor($upsoverload , $gray )
	GUICtrlSetBkColor($upslowbatt , $gray )
	if ($socket <> 0 ) Then
		SetUPSInfo()
	EndIf
	rePaint()
EndFunc

Func Update()
	;if $socket == 0 Then
	;	Return
	;EndIf
	$status = GetData()
	if $socket == 0 then ; connection lost so throw all needles to left
		ResetGui()
		Return
	EndIf
	$trayStatus  = ""
	if $upsstatus == "OL" Then
		SetColor($green , $wPanel , $upsonline )
		SetColor(0xffffff , $wPanel , $upsonbatt )
		$trayStatus  = $trayStatus & "UPS On Line"
	Else
		SetColor($yellow , $wPanel , $upsonbatt )
		SetColor(0xffffff , $wPanel , $upsonline )
		$trayStatus  = $trayStatus & "UPS On Batt"
	EndIf
	if $upsLoad > 100 Then
		SetColor($red , $wPanel , $upsoverload )
	Else
		SetColor(0xffffff , $wPanel , $upsoverload )
	EndIf
	if $battCh < 40 Then
		SetColor($red , $wPanel , $upslowbatt )
		$trayStatus  = $trayStatus & @LF &  "Low Battery"
	Else
		SetColor(0xffffff , $wPanel , $upslowbatt )
		$trayStatus  = $trayStatus & @LF &  "Battery OK"
	EndIf
	UpdateValue($needle4 , $battVol , $battv , $dial4 , getOption("minbattv") , getOption("maxbattv") )
	UpdateValue($needle5 , $upsLoad , $upsl , $dial5 , getOption("minupsl") , getOption("maxupsl") )
	UpdateValue($needle6 , $battCh , $upsch , $dial6 , 0 , 100 )
	UpdateValue($needle1 , $inputVol, $inputv , $dial1 ,getOption("mininputv") , getOption("maxinputv"))
	UpdateValue($needle2 , $outputVol, $outputv , $dial2 , getOption("minoutputv") , getOption("maxoutputv"))
	UpdateValue($needle3 , $inputFreq , $inputf , $dial3 , getOption("mininputf") , getOption("maxinputf") )
	rePaint()
	TraySetToolTip($ProgramDesc & " - " & $ProgramVersion & @LF &  $trayStatus )
	;if connection to UPS is in fact alive and charge below shutdown setting and ups is not online
	;add different from status 0 when UPS not connected but NUT is running
	if ($battch <  GetOption("shutdownpc")) and ($upsstatus <>  "0") and ($upsstatus <>  "OL" and $socket <> 0) Then
		Shutdown(13) ;Shutdown PC if battery charge lower then given percentage and UPS offline
	EndIf
EndFunc

Func DrawDial($left , $top , $basescale , $title , $units , ByRef $value , ByRef $needle , $scale = 1 , $leftG = 20, $rightG = 70)
	Local $group = 0
	$group = GUICreate(" " & $title, 150, 120, $left, $top, BitOR($WS_CHILD, $WS_DLGFRAME), $WS_EX_CLIENTEDGE, $gui)
	GUISetBkColor($clock_bkg,$group)
	GuiSwitch($group)
	GuiCtrlCreateLabel($title,0,0,150,14,$SS_CENTER )

	for $x = 0 to 100 step 10
		if StringinStr($x / 20,".") = 0 Then
			GUICtrlCreateLabel("",$x * 1.2 + 15 , 15  , 1 , 15 , $SS_BLACKRECT)
			GuiCtrlSetState(-1,$GUI_DISABLE)
			if $x < 100 Then
				$test = GUICtrlCreateLabel("",$x * 1.2  + 16,15  , 11 , 5 , 0 )
				GuiCtrlSetState(-1,$GUI_DISABLE)
				if $x < $rightG and $x > $leftG then
					GUICtrlSetBkColor($test , 0x00ff00)
				Else
					GUICtrlSetBkColor($test , 0xff0000)
				EndIf
			EndIf
			$scalevalue = $basescale + $x / $scale
			switch $scalevalue
				Case 0 to 9
					GuiCtrlCreateLabel($scalevalue , $x * 1.2 + 13 , 25 , 20 , 10 )
				Case 10 to 99
					GuiCtrlCreateLabel($scalevalue , $x * 1.2 + 10 , 25 , 20 , 10 )
				Case 100 to 1000
					GuiCtrlCreateLabel($scalevalue , $x * 1.2 + 7 , 25 , 20 , 10 )
			EndSwitch
			GUICtrlSetFont(-1,7)
		Else
			GUICtrlCreateLabel("",$x * 1.2  + 15 , 15  , 1 , 5 , $SS_BLACKRECT )
			GuiCtrlSetState(-1,$GUI_DISABLE)
			$test = GUICtrlCreateLabel("", $x *1.2  + 16 ,15  , 11 , 5 , 0 )
			;GuiCtrlSetState(-1,$GUI_DISABLE)
			if $x < $rightG and $x > $leftG then
				GUICtrlSetBkColor($test , 0x00ff00)
			Else
				GUICtrlSetBkColor($test , 0xff0000)
			EndIf
		EndIf
	Next
	if $units =="%" then
		$value = GUICtrlCreateLabel(0 , 10  ,100  , 40 , 15, $SS_LEFT)
	Else
		$value = GUICtrlCreateLabel(220 , 10  ,100  , 40 , 15, $SS_LEFT)
	EndIf
	$label2 = GUICtrlCreateLabel($units , 116  ,100  , 25 , 15 ,$SS_RIGHT )
	$needle = GUICtrlCreateGraphic(10  ,35  , 120 , 60 )
	;GUICtrlSetBkColor(-1,$aqua)
	;$fill = GuiCtrlCreateGraphic(0 , 0 , 150 , 120)

	GuiSetState(@SW_SHOW,$group)
	;GuiCtrlSetBkColor(-1,0x00ffff)
	$result  = $group
	return $group
EndFunc

Func OpenMainWindow()
	$gui = GUICreate($ProgramDesc, 640, 380, -1 , -1,Bitor($GUI_SS_DEFAULT_GUI ,$WS_CLIPCHILDREN))
	GUISetIcon(@tempdir & "upsicon.ico")
	$fileMenu = GUICtrlCreateMenu("&File")
	$listvarMenu = GuiCtrlCreateMenuItem("&List UPS Vars",$fileMenu)
	$exitMenu = GUICtrlCreateMenuItem("&Exit", $fileMenu)
	$editMenu = GUICtrlCreateMenu("&Connection")
	$reconnectMenu = GUICtrlCreateMenuItem("&Reconnect",$editMenu)
	$settingsMenu = GUICtrlCreateMenu("&Settings")
	$settingssubMenu = GUICtrlCreateMenuItem("&Preferences",$settingsMenu)
	$helpMenu = GUICtrlCreateMenu("&Help")
	$aboutMenu = GUICtrlCreateMenuItem("About", $helpMenu)
	$log = GUICtrlCreateCombo("", 5, 335, 630, 25,Bitor($CBS_DROPDOWNLIST,0))
	;$Group8 = GUICtrlCreateGroup("", 0, 0, 598 + 25, 65)

	;	GuiSwitch($gui)
	$wPanel = GUICreate("", 150, 250,0, 70,BitOR($WS_CHILD, $WS_DLGFRAME), $WS_EX_CLIENTEDGE, $gui)
	GUISetBkColor($panel_bkg , $wPanel)
	$Label1 = GUICtrlCreateLabel("UPS On Line", 8, 8, 110, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsonline = GUICtrlCreateLabel("", 121, 8, 15, 17, BitOR($SS_CENTER,$SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label2 = GUICtrlCreateLabel("UPS On Battery", 8, 32, 110, 18,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsonbatt = GUICtrlCreateLabel("", 121, 32, 15, 17, BitOR($SS_CENTER,$SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label3 = GUICtrlCreateLabel("UPS Overload", 8, 56, 110, 18,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsoverload = GUICtrlCreateLabel("", 121, 56, 15, 17, BitOR($SS_CENTER,$SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label4 = GUICtrlCreateLabel("UPS Battery low", 8, 80, 110, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upslowbatt = GUICtrlCreateLabel("", 121, 80, 15, 17, BitOR($SS_CENTER,$SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label5 = GUICtrlCreateLabel("Manufacturer :", 8, 110, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsmfr = GUICtrlCreateLabel($mfr, 8, 128, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label14 = GUICtrlCreateLabel("Name :", 8, 142, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsmodel = GUICtrlCreateLabel($name, 8, 160, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label15 = GUICtrlCreateLabel("Serial :", 8, 174, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsserial = GUICtrlCreateLabel($serial, 8, 190, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label16 = GUICtrlCreateLabel("Firmware :", 8, 204, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsfirmware = GUICtrlCreateLabel($firmware, 8, 222, 130, 17,Bitor($SS_LEFTNOWORDWRAP,$GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")

	;$wPanel = GUICtrlCreateGroup("", 0, 70, 130 + 25, 240)
	GuiSwitch($gui)
	$Group8 = GUICreate("", 638, 60,0, 0,BitOR($WS_CHILD, $WS_BORDER), 0, $gui)
	$exitb = GUICtrlCreateButton("Exit", 10, 10, 73, 40, 0)
	$toolb = GUICtrlCreateButton("Settings", 102, 10, 73, 40, 0)
	GUISetState(@SW_SHOW,$Group8)
	GUISetState(@SW_SHOW,$wPanel)
	GUISetState(@SW_SHOW,$gui)
	$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100 )
	$dial1 = DrawDial(160, 70 , GetOption("mininputv") , "Input Voltage" , "V" , $inputv , $needle1 , $calc)
	$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100 )
	$dial2 = DrawDial(480, 70 , GetOption("minoutputv") , "Output Voltage" , "V" , $outputv , $needle2 , $calc)
	$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100 )
	$dial3 = DrawDial(320, GetOption("maxinputf") , GetOption("mininputf") , "Input Frequency" , "Hz" , $inputf , $needle3 , $calc )
	$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100 )
	$dial4 = DrawDial(480, 200 , GetOption("minbattv") , "Battery Voltage" , "V" , $battv , $needle4 , $calc , 20 , 120)
	$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100 )
	$dial5 = DrawDial(320, 200 , 0 , "UPS Load" , "%" , $upsl , $needle5 , $calc , -1 , 80)
	$dial6 = DrawDial(160, 200 , 0 , "Battery Charge" , "%" , $upsch , $needle6 , 1 , 30 , 101)
EndFunc

Func aboutGui()
	AdlibUnregister()
	$minimizetray = GetOption("minimizetray")
	If $minimizetray == 1 Then
		TraySetClick(0)
	EndIf
	$guiabout = GUICreate("About", 324, 220, 271, 178)
	GUISetIcon(@tempdir & "upsicon.ico")
	$GroupBox1 = GUICtrlCreateGroup("", 8, 0, 308, 184)
	$Image1 = GUICtrlCreatePic(@tempdir & "ups.jpg", 16, 16, 104, 104, BitOR($SS_NOTIFY,$WS_GROUP))
	$Label10 = GUICtrlCreateLabel($ProgramDesc, 128, 16, 180 , 18, $WS_GROUP)
	$Label11 = GUICtrlCreateLabel("Version " & $ProgramVersion, 128, 34, 180, 18, $WS_GROUP)
	$Label12 = GUICtrlCreateLabel("Copyright Michael Liberman" & @LF & "2006-2007", 128, 52, 270, 44, $WS_GROUP)
	$Label13 = GUICtrlCreateLabel("Based from Winnut Sf https://sourceforge.net/projects/winnutclient/", 16, 128, 270, 44, $WS_GROUP)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$Button11 = GUICtrlCreateButton("&OK", 126, 188, 72, 24)
	GUISetState(@SW_SHOW,$guiabout)
	GuiSetState(@SW_DISABLE,$gui)
	While 1
		$nMsg2 = GUIGetMsg()
		Switch $nMsg2
			Case $GUI_EVENT_CLOSE, $Button11
				GuiDelete($guiabout)
				$guiabout = 0
				If (WinGetState($gui) <> 17 ) Then
					GuiSetState(@SW_ENABLE,$gui )
					WinActivate($gui)
				EndIf
				if $haserror == 0 Then
					AdlibRegister("Update",1000)
				EndIf
				If $minimizetray == 1 Then
					TraySetClick(8)
				EndIf
				ExitLoop
		EndSwitch
	WEnd
EndFunc

func mainLoop()
	$minimizetray = GetOption("minimizetray")
	While 1
		if ($minimizetray == 1) Then
			$tMsg = TrayGetMsg()
			Switch $tMsg
				Case $TRAY_EVENT_PRIMARYDOUBLE
					GuiSetState(@SW_SHOW, $gui)
					GuiSetState(@SW_RESTORE ,$gui )
					TraySetState($TRAY_ICONSTATE_HIDE)
				Case $idTrayExit
					TCPSend($socket,"LOGOUT")
					TCPCloseSocket($socket)
					TCPShutdown()
					Exit
				Case $idTrayAbout
					aboutGui()
				Case $idTrayPref
					AdlibUnregister()
					$changedprefs = prefGui()
					if $changedprefs == 1 Then
						$painting = 1
						GuiDelete($dial1)
						GuiDelete($dial2)
						GuiDelete($dial3)
						GuiDelete($dial5)
						GuiDelete($dial4)
						DrawError(160 , 70 , "Delete")
						$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100 )
						$dial1 = DrawDial(160, 70 , GetOption("mininputv") , "Input Voltage" , "V" , $inputv , $needle1 , $calc)
						$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100 )
						$dial2 = DrawDial(480, 70 , GetOption("minoutputv") , "Output Voltage" , "V" , $outputv , $needle2 , $calc)
						$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100 )
						$dial3 = DrawDial(320, GetOption("maxinputf") , GetOption("mininputf") , "Input Frequency" , "Hz" , $inputf , $needle3 , $calc )
						$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100 )
						$dial4 = DrawDial(480, 200 , GetOption("minbattv") , "Battery Voltage" , "V" , $battv , $needle4 , $calc , 20 , 120)
						$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100 )
						$dial5 = DrawDial(320, 200 , 0 , "UPS Load" , "%" , $upsl , $needle5 , $calc , -1 , 80)
						$painting = 0
					EndIf
					if $haserror == 0 Then
						Update()
						AdlibRegister("Update",1000)
					EndIf
			EndSwitch
		EndIf
		$nMsg = GUIGetMsg(1)
		if GetOption("closetotray") == 0 Then
			if ($nMsg[0] == $GUI_EVENT_CLOSE and $nMsg[1]==$gui)  or $nMsg[0] == $exitMenu or $nMsg[0] == $exitb then
				TCPSend($socket,"LOGOUT")
				TCPCloseSocket($socket)
				TCPShutdown()
				Exit
			EndIf
		Else
			if $nMsg[0] == $exitMenu or $nMsg[0] == $exitb then
				TCPSend($socket,"LOGOUT")
				TCPCloseSocket($socket)
				TCPShutdown()
				Exit
			EndIf
			if ($nMsg[0] == $GUI_EVENT_CLOSE and $nMsg[1]==$gui) Then
				GuiSetState(@SW_HIDE , $gui)
				TraySetState($TRAY_ICONSTATE_SHOW)
			EndIf
		EndIf
		if ($nMsg[0] == $GUI_EVENT_MINIMIZE and $nMsg[1]==$gui and $minimizetray ==1) Then;minimize to tray
			GuiSetState(@SW_HIDE , $gui)
			TraySetState($TRAY_ICONSTATE_SHOW)
		EndIf
		if $nMsg[0] == $toolb or $nMsg[0]==$settingssubMenu Then
			AdlibUnregister()
			$changedprefs = prefGui()
			if $changedprefs == 1 Then
				$painting = 1
				GuiDelete($dial1)
				GuiDelete($dial2)
				GuiDelete($dial3)
				GuiDelete($dial5)
				GuiDelete($dial4)
				DrawError(160 , 70 , "Delete")
				$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100 )
				$dial1 = DrawDial(160, 70 , GetOption("mininputv") , "Input Voltage" , "V" , $inputv , $needle1 , $calc)
				$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100 )
				$dial2 = DrawDial(480, 70 , GetOption("minoutputv") , "Output Voltage" , "V" , $outputv , $needle2 , $calc)
				$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100 )
				$dial3 = DrawDial(320, GetOption("maxinputf") , GetOption("mininputf") , "Input Frequency" , "Hz" , $inputf , $needle3 , $calc )
				$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100 )
				$dial4 = DrawDial(480, 200 , GetOption("minbattv") , "Battery Voltage" , "V" , $battv , $needle4 , $calc , 20 , 120)
				$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100 )
				$dial5 = DrawDial(320, 200 , 0 , "UPS Load" , "%" , $upsl , $needle5 , $calc , -1 , 80)
				$painting = 0
			EndIf
			if $haserror == 0 Then
				Update()
				AdlibRegister("Update",1000)
			EndIf
		EndIf
		if $nMsg[0] == $aboutMenu Then
			aboutGui()
		EndIf

		if ($nMsg[0] == $listvarMenu) Then
			varlistGui()
		EndIf
		If $nMsg[0]== $reconnectMenu then
			AdlibUnregister()
			ConnectServer() ;;aaaaa
			Opt("TCPTimeout",3000)
			GetUPSInfo()
			SetUPSInfo()
			AdlibRegister("Update",1000)
		EndIf
	WEnd
EndFunc

func setTrayMode()
	$minimizetray = GetOption("minimizetray")
	if $minimizetray == 1 Then
		TraySetIcon(@tempdir & "upsicon.ico")
		TraySetState($TRAY_ICONSTATE_SHOW)
		Opt("TrayAutoPause", 0) ; Le script n'est pas mis en pause lors de la sélection de l'icône de la zone de notification.
		Opt("TrayMenuMode", 3) ; Les items ne sont pas cochés lorsqu'ils sont sélectionnés.

		TraySetClick(8)
		TraySetToolTip($ProgramDesc & " - " & $ProgramVersion )

	Else
		TraySetState($TRAY_ICONSTATE_HIDE)
	EndIf
EndFunc

;HERE STARTS MAIN SCRIPT
Fileinstall(".\images\ups.jpg", @tempdir & "ups.jpg",1)
Fileinstall(".\images\upsicon.ico", @tempdir & "upsicon.ico",1)

TraySetState($TRAY_ICONSTATE_HIDE)
$status = TCPStartup ( )
if $status == false Then
	MsgBox(48,"Critical Error","Couldn't startup TCP")
	Exit
EndIf

Opt("GUIDataSeparatorChar", ".")
$status = InitOptionDATA()
if $status == -1 Then
	MsgBox(48,"Critical Error","Couldn't initialize Options")
	Exit
EndIf

ReadParams()
setTrayMode()

;Determine if running as exe or script
If StringRight( @ScriptName, 4 ) == ".exe" Then
	$runasexe = True
EndIf

$idTrayPref = TrayCreateItem("Preferences")
TrayCreateItem("")
$idTrayAbout = TrayCreateItem("About")
TrayCreateItem("")
$idTrayExit = TrayCreateItem("Exit")

OpenMainWindow()
if ( GetOption("minimizeonstart") == 1 and GetOption("minimizetray") == 1 ) Then
	GuiSetState(@SW_HIDE , $gui)
	TraySetState($TRAY_ICONSTATE_SHOW)
EndIf
$ProgramVersion = _GetScriptVersion()
$status = ConnectServer()
Opt("TCPTimeout",3000)
GetUPSInfo()
SetUPSInfo()
Update()
GuiRegisterMsg(0x000F,"rePaint")
AdlibRegister("Update",GetOption("delay"))
mainLoop()