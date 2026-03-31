Process, Priority, , High
SetBatchLines, -1
ListLines, Off
SetKeyDelay, -1, -1
SendMode, Event
CoordMode, Pixel, Window  
CoordMode, Mouse, Window  
CoordMode, ToolTip, Window 


safespotEmergency := false
mainWin := 0
regions := []
menaphiteBody := 0
menaphiteBodyFromSafespot := 0
safespot := 0
inventory := 0

Hotkey, ^f12, showLayout
Hotkey, ^f11, toggleScript
Hotkey, ^f10, reload
Hotkey, ^f9, pause

showNotificationMsg("Order of regions: body, safespot, body from safespot.")
return
	

pause:
	Pause, Toggle, 1
	if(A_IsPaused){
		showNotificationMsg("Script Paused")
	}else{
		showNotificationMsg("Script Unpaused")
	}
return

reload:
	showNotificationMsg("Reloading..")
	Sleep, 500
	Reload
return

toggleScript:
	
	if(regions.Count()<3){
		MsgBox, First define the body, safespot and body from safespot using Ctrl + leftClick
		return
	}

	if(toggleScript:=!toggleScript){
		setTimer, script, 300
		showNotificationMsg("Script On")
		return
	}

	setTimer, script, Off
	showNotificationMsg("Script Offing...")
	
return

^0::
	Critical
	safespotEmergency()
return


f:: ;emergency exit, for testing stuff. Save life sometimes xd
	ExitApp
return

1::
	;For test i needed
	if(inventory = 0){
		inventory := loadInventory()
		regions.push(crearRegion(inventory.x, inventory.y, inventory.x -1 +204, inventory.y -1 +276))
		MsgBox, % "inventory.x=" inventory.x
	}

return


^LButton::
	if(inventory = 0){
		inventory := loadInventory()
		regions.push(crearRegion(inventory.x, inventory.y, inventory.x -1 +204, inventory.y -1 +276))
	}

	makeRegion()

return

showLayout:

	if(inventory = 0){
		inventory := loadInventory()
		regions.push(crearRegion(inventory.x, inventory.y, inventory.x -1 +204, inventory.y -1 +276))

	}

	if (toggleLayout:=!toggleLayout){
		
		winActiva := WinExist("A")
		idGrafico := crearColeccionGraficos(regions.Count())
		dibujarColeccionRectangulos(idGrafico, regions, winActiva)

	}else{

		destruirColeccionGraficos(idGrafico)
		idGrafico := []
	}

return

script(){

	Global

	;New timing control, more presise

	;Ajust the delays as needed
	firstPicpoketTime := randomValue(580, 635) ;First picpocket exactly at this time
	secondPicpoketTime := randomValue(1260, 1285) ;Second picpocket exactly at this time
	
	stackMsg("firstPicpoketTime = " . firstPicpoketTime)
	stackMsg("secondPicpoketTime = " . secondPicpoketTime)
	
	knockOut()
	
	_QPC(1) ;Start measuring time with higher pressicion
	randomSleep(60, 120) ;Try to pickpocket in the same tick of knock out, or just after
	pickPocket()

	tControl := _QPC(0)
	_QPC(1)
	;Tooltip, % tControl
	Sleep, (firstPicpoketTime - tControl) ;Pickpock exactly at firstPicpoketTime
	pickPocket()
	
	tControl := _QPC(0)
	;Tooltip, % tControl
	Sleep, (secondPicpoketTime - tControl) ;Pickpock exactly at secondPicpoketTime
	pickPocket()


	randomSleep(1300, 1350)

	
	safespotCountdown(900000) ;Launch a safespoting function every desire time

}


;#################### Script fucn

pickPocket(){

	SetMouseDelay, randomValue(70, 90) ;Ensure a non constant click time. The proces is: Click down > wait random value > Click up
	Click ;Left click. Internaly performs {Left Click down} followed by {Left Click Up}

}

knockOut(){

	Global menaphiteBody

	;This function assumes the cursor is already in the menaphite body
	SetMouseDelay, randomValue(50, 90)
	Click, Right
	Sleep, 80 ;wait the menu to appear
	SetMouseDelay, 15 ;restore SetMouseDelay

	selectMenuOption(4) ;Option 4 > Knock Out
	

	moveToRegion(menaphiteBody) ;get back to menaphite body
	Sleep, 80 ;wait the menu to desappear

}

knockOutOnly(){

	;This function assumes the cursor is already in the menaphite body
	SetMouseDelay, randomValue(50, 90)
	Click, Right
	Sleep, 80 ;wait the menu to appear
	SetMouseDelay, 15 ;restore SetMouseDelay
	Sleep, 80 ;wait the menu to desappear

	selectMenuOption(4) ;Option 4 > Knock Out
}

selectMenuOption(n){
	
	;This function asumes the menu is visible now

	;Hard coded menu instead of looping, it says static to be initiated only the first time 
	;the function is executed, futher execution will no initiate the var again, wasting process time

	static option := [{x1: -33, y1:20, x2: 33, y2:36}
	,{x1:-33 , y1:37, x2:33 , y2:51}
	,{x1:-33 , y1:52, x2:33 , y2:66}
	,{x1:-33 , y1:67, x2:33 , y2:78}
	,{x1:-33 , y1:82, x2:33 , y2:96}
	,{x1:-33 , y1:97, x2:33 , y2:111}
	,{x1:-33 , y1:112, x2:33 , y2:126}
	,{x1:-33 , y1:127, x2:33 , y2:141}
	,{x1:-33 , y1:142, x2:33 , y2:156}
	,{x1:-33 , y1:157, x2:33 , y2:171}
	,{x1:-33 , y1:172, x2:33 , y2:186}
	,{x1:-33 , y1:187, x2:33 , y2:201}]
	
	;option[4] := {"x1":x1 , "y1":67, "x2":x2 , "y2":78}

	SetDefaultMouseSpeed, randomValue(1, 4) ;Some variation to mouse speed 0 = fastest, 100 = slowest (integers)
	
	;Choose a random point to click inside the option choosen
	x := randomValue(option[n].x1, option[n].x2)
	;x := option[n].x2 ;, test
	y := randomValue(option[n].y1+2, option[n].y2-2) ;+-2 to estrech the region
	;y := option[n].y2 ;, test
	
	MouseMove, x, y ,, rel
	randomSleep(90, 110) ;common human delay after reach a location

	SetMouseDelay, randomValue(50, 90) ;Explained in the pickpocket function
	Click ;Explained in the pickpocket function

}

safespotCountdown(time){

	Global safespotEmergency
	static tInitial := 0
	
	if(safespotEmergency){

		safespoting(10000) ;Time to sleep in the safespot
		tInitial := A_TickCount ;start measuring the time for the next safespot from this point
		safespotEmergency := false
		return
	
	}

	if(tInitial = 0){
		tInitial := A_TickCount
	}

	tElapsed  := (A_TickCount - tInitial)
	
	if (tElapsed  >= time){

		safespoting(10000) ;Time to sleep in the safespot
		tInitial := A_TickCount ;start measuring the time for the next safespot from this point

	}

}

safespoting(time){

	Global safespot, menaphiteBodyFromSafespot, inventory, menaphiteBody
	static cellWithFood := 2

 
	clicRegion(safespot) ;Move to safespot

	if(inventory !=0){ ;Verify if the inventory exist

		if(cellWithFood>28){ ;Verify food
		
			showNotificationMsg("Run out of food")
		
		}else{

			clicRegion(inventory.cells[cellWithFood].area) ;eat food

			cellWithFood++ ;Next time will eat from this cell
		}
	}
	
	Sleep, time ;Wait in the safespot
	
	moveToRegion(menaphiteBodyFromSafespot) 
	knockOutOnly() 
	randomSleep(160, 400) ;wait a bit while the player is moving to the front of thug before move the mouse to the corresponding new location of the body
	moveToRegion(menaphiteBody)
	randomSleep(800, 1200) ;Wait suficient after knock out from the safespot to move to the correct tile
	pickPocket()
	randomSleep(640, 650) 
	pickPocket()

	randomSleep(1300, 1350) 
	;Continue from the normal rutine after this
	
	
}

safespotEmergency(){

	Global safespotEmergency
	safespotEmergency := true ;Execute a safespot the next time the safespot functions is hiten
}




makeRegion(reset := 0){
	
	Global regions, menaphiteBody, safespot, menaphiteBodyFromSafespot
	static currentPoint := 1 
	static x1 = 0
	static y1 = 0
	static x2 = 0
	static y2 = 0
	
	if (reset){
		
		currentPoint := 1
		x1 := 0
		y1 := 0
	 	x2 := 0
	 	y2 := 0
		return
	
	}
	


	if(currentPoint == 1){
	
		MouseGetPos, x1, y1
		currentPoint++
	
	}else if (currentPoint == 2){
		
		MouseGetPos, x2, y2
		
		;Transforms the coordinates given into a correct region
		if(x2 < x1){
			temp := x1
			x1 := x2
			x2 := temp
		}

		if(y2 < y1){
			temp := y1
			y1 := y2
			y2 := temp
		}

		newRegion := {"x1":x1, "y1":y1, "x2":x2, "y2":y2}
		if(menaphiteBody = 0){
			menaphiteBody := newRegion
			regions.push(newRegion)
			showNotificationMsg("Body defined")
		}else if(safespot = 0){
			safespot := newRegion
			regions.push(newRegion)
			showNotificationMsg("safespot defined")
		}else if(menaphiteBodyFromSafespot = 0){
			menaphiteBodyFromSafespot := newRegion
			regions.push(newRegion)
			showNotificationMsg("Body from safespot defined")
		}
		
		
		currentPoint := 1
		x1 := 0
		y1 := 0
	 	x2 := 0
	 	y2 := 0

	
	}
}



loadInventory(){

	currentWindow :=  WinExist("A")

 	Control := 0
	
	ControlGet, Control, Hwnd, , SunAwtCanvas2, ahk_id %currentWindow%
	if (ErrorLevel){
		return false
	}
	ControlGetPos, X, Y, controlWidth, controlHeight, , ahk_id %Control%
	;WinGetPos, X, Y, controlWidth, controlHeight, ahk_id %currentWindow%
	
	
	;inventory position relative to control
	inventoryPosRelativeControl := {x:controlWidth-204, y:controlHeight-311}
	;invetory position relative to window 
	inventoryPosRelativeWindow := {x:(inventoryPosRelativeControl.x+X), y:(inventoryPosRelativeControl.y+Y), father:CURRENT_WINDOW}
	cells := {}
	cellsProperties := {width:32,height:32 ,marginTop:4, marginLeft:10}
	inventoryPropertys := {paddingLeft:13, paddingTop:11}

	;Defining the position of every cell of the inventory
	x1 := inventoryPosRelativeWindow.x+inventoryPropertys.paddingLeft
	y1 := inventoryPosRelativeWindow.y+inventoryPropertys.paddingTop
	count := 1
	y2 := 0
	x2 := 0
	;7 rows
	loop, 7 {

		y1 := y1 + cellsProperties.marginTop
		y2 := y1 + cellsProperties.height
		;4 colums
		loop, 4 {

			x1 := x1 + cellsProperties.marginLeft
			x2 := x1 + cellsProperties.width
			cells[count] := {x:x1, y:y1, area:{x1:x1, y1:y1, x2:x2, y2:y2}, width:cellsProperties.width, height:cellsProperties.height}
			x1 := x2
			count++
		}
		
		y1 := y2
		x1 := inventoryPosRelativeWindow.x+inventoryPropertys.paddingLeft
	}
	
	inventory :=  {x:inventoryPosRelativeWindow.x, y:inventoryPosRelativeWindow.y, cells:cells, baseColor:"0x29353E", father:inventoryPosRelativeWindow.father}
	return inventory
		
} 
























;#################### lib functions ##############

randomValue(min, max){
	return	distribucionAlObjetivo(min, ((min+max)//2), max)
}

crearPunto(x, y){
	
	if (x<0 or y<0){
		return 0
	}	
	return {"x":x, "y":y}
}

crearRegion(x1, y1, x2, y2){

	if (x1<0 or y1<0 or x2<0 or y2<0){
		return 0
	}

	if(x2 < x1){
		temp := x1
		x1 := x2
		x2 := temp
	}

	if(y2 < y1){
		temp := y1
		y1 := y2
		y2 := temp
	}

	return {"x1":x1, "y1":y1, "x2":x2, "y2":y2}

}


crearGrafico(cc:="0x3CFF3C") {

	Gui, New, +HwndGrafico  +AlwaysOnTop -Caption +E0x00000020 +E0x08000000 
	Gui, Color, %cc%
	return Grafico

}

crearColeccionGraficos(cantidad){

	ids := []
	loop, %cantidad%
		ids[A_Index] := crearGrafico()
	
	return ids
}

ocultarGrafico(hwndGrafico){

	if (!hwndGrafico)
		return

	Gui, %hwndGrafico%:Hide

}

ocultarColeccionGraficos(ids){

	loop, % ids.Count()
		ocultarGrafico(ids[A_Index]) 
			
}

mostrarGrafico(hwndGrafico){

	if (!hwndGrafico)
		return

	Gui, %hwndGrafico%:Show, NA
}

mostrarColeccionGraficos(ids){
	
	loop, % ids.Count()
		mostrarGrafico(ids[A_Index]) 
	
}

dibujarRectangulo(winHwnd:=0, punto:=0, hwndGrafico:=0, x1:=0, y1:=0, x2:=0, y2:=0, borde:=2){
    
    if (!hwndGrafico or x1<0 or y1<0 or x2<0 or y2<0){
        return 1
    }

    addX := 0, addY := 0 
    if (winHwnd != 0){
        
        win := WinExist("ahk_id " winHwnd)
        if !win
            return 2
        
        WinGetPos, wx, wy, , , ahk_id %win%
      	addX := wx
       	addY := wy
    }

    if(punto != 0){
        addX += punto.x
        addY += punto.y
    }

    x1+=addX
    y1+=addY
    x2+=addX
    y2+=addY

    w := x2 - x1
    h := y2 - y1
    w2:= w - borde
    h2:= h - borde
  
    Gui, %hwndGrafico%: Show, w%w% h%h% x%x1% y%y1% NA
    WinSet, Transparent, 255
    WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %borde%-%borde% %w2%-%borde% %w2%-%h2% %borde%-%h2% %borde%-%borde%, ahk_id %hwndGrafico%
    ;WinSet, ExStyle, +0x20, ahk_id %hwndGrafico%

    return 0
}

dibujarColeccionRectangulos(idGraficos, regiones, winHwnd:=0, punto:=0){

	loop, % idGraficos.Count()
		dibujarRectangulo(winHwnd, punto, idGraficos[A_Index], regiones[A_Index].x1, regiones[A_Index].y1, regiones[A_Index].x2, regiones[A_Index].y2)
	
}

destruirGrafico(hwndGrafico){
	
	if (!hwndGrafico)
		return

	Gui, %hwndGrafico%:Destroy
}

destruirColeccionGraficos(ids){
	
	loop, % ids.Count()
		destruirGrafico(ids[A_Index]) 
	
}


clicRegion(region, insetX:=0, insetY:=0){

    ;El caller se aseguro de que la region es valida
    mex := (region.x1 + region.x2)//2
    rax := distribucionAlObjetivo((region.x1+insetX), mex, (region.x2-insetX))

    mey := (region.y1 + region.y2)//2
    ray := distribucionAlObjetivo((region.y1+insetY), mey, (region.y2-insetY))

    MouseMove, rax, ray
    randomSleep(80, 120) 

    Click
    randomSleep(30, 80) 
    return 0

}


moveToRegion(region, inset:=0){

   ;El caller se aseguro de que la region es valida
    mex := (region.x1 + region.x2)//2
    rax := distribucionAlObjetivo((region.x1+inset), mex, (region.x2-inset))

    mey := (region.y1 + region.y2)//2
    ray := distribucionAlObjetivo((region.y1+inset), mey, (region.y2-inset))

    MouseMove, rax, ray
    randomSleep(80, 120)

}

distribucionAlObjetivo(ini, objetivo, fin){
  
    Random, izq, ini, objetivo
    Random, der, objetivo, fin
    Random, cerca, izq, der
    Return cerca

}

randomSleep(min:=30, max:=1000){
	;weigthed now
    rt := distribucionAlObjetivo(min, ((min+max)//2), max)
    Sleep, rt
}

showNotificationMsg(msg:="", centrar :=0){
    
   	CoordMode, ToolTip, Window
    
    if(centrar){
    	WinGetPos, X, Y, Width, Height, A
    	Tooltip, % msg, Width//2, Height//2, 1
    }else{
    	Tooltip, % msg , , , 1
    }

    setTimer, quitarTooltip, -2000
    return

    quitarTooltip:
        Tooltip, , , , 1
    return

}

_QPC(Reset := 0){ ; By SKAN,  http://goo.gl/nf7O4G,  CD:01/Sep/2014 | MD:02/Sep/2014

	static PrvQPC := 0, FRQ := 0, QPC := 0

	if !(FRQ)
		DllCall("QueryPerformanceFrequency", "Int64*", FRQ)

	DllCall("QueryPerformanceCounter", "Int64*", QPC)

	if (Reset){
	
		PrvQPC := QPC
		return QPC / FRQ
	
	}else {
	
		return (QPC - PrvQPC) / FRQ * 1000
	
	}
}


stackMsg(msg){

	Global safespot
	static id := 2
	static lastY := 0
	static count := 0
	
	x := safespot.x2 + 20
	y := lastY + 40

	if(lastY = 0){
		y := safespot.y1
	}

	Tooltip, % msg, x, y, id
	lastY := y
	id++
	count++

	if(count = 2){
		
		count := 0
		id := 2
		lastY := 0
	}

}