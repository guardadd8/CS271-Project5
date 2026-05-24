TITLE Temperature Statistics Program     (Proj5_guardadd.asm)

; Author: Daniel Guardado
; Last Modified:	5/23/2026
; OSU email address: guardadd@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5               Due Date: 5/24/2026
; Description:	This program generates a set amount of temperatures based on the days measured 
;				and the temperatures collected per day. The highest and lowest temperatures per
;				day are then collected in different sets and the averages of each collection
;				are then calculated. The full set of temperatures, along with the collection
;				of the highest temperatures, lowest temperatures, and averages are then displayed.

INCLUDE Irvine32.inc

DAYS_MEASURED = 14
TEMPS_PER_DAY = 11
MIN_TEMP = 20
MAX_TEMP = 80
ARRAYSIZE = DAYS_MEASURED*TEMPS_PER_DAY

.data
	intro1			BYTE	"Welcome to Temperature Statistics Program by Daniel Guardado",13,10,13,10,0
	intro2			BYTE	"This program generates temperature readings depending on the days measured and temperatures collected per day.",13,10
					BYTE	"Different statistics are then calculated such as the daily highest and lowest temperatures, as well as",13,10
					BYTE	"the average highest and lowest temperatures. All the temperatures along with the calculated values are ",13,10
					BYTE	"then printed with descriptive titles.",13,10,13,10,0
	allTempsMsg		BYTE	"Temperature readings (one row is one day):",13,10,0
	highestTempsMsg	BYTE	"Highest daily temperatures:",13,10,0
	lowestTempsMsg	BYTE	"Lowest daily temperatures:",13,10,0
	avgHighTempMsg	BYTE	"The (truncated) average high temperature was: ",0
	avgLowTempMsg	BYTE	"The (truncated) average low temperature was: ",0
	goodbyeMsg		BYTE	"Thanks for using Temperature Statistics Program. Goodbye.",0

	tempArray		DWORD ARRAYSIZE	DUP(?)		; Holds all generated temps
	dailyHighs		DWORD DAYS_MEASURED	DUP(?)	; Holds highest temps
	dailyLows		DWORD DAYS_MEASURED	DUP(?)	; Holds lowest temps
	averageHigh 	DWORD ?						; Holds average of highest temps
	averageLow		DWORD ?						; Holds average of lowest temps

.code
main PROC
	call	Randomize
	push	OFFSET intro2
	push	OFFSET intro1
	call	printGreeting

	push	OFFSET tempArray
	call	generateTemperatures

	push	OFFSET dailyHighs
	push	OFFSET tempArray
	call	findDailyHighs

	push	OFFSET dailyLows
	push	OFFSET tempArray
	call	findDailyLows

	push	OFFSET averageLow
	push	OFFSET averageHigh
	push	OFFSET dailyLows
	push	OFFSET dailyHighs
	call	calcAverageLowHighTemps

	push	TEMPS_PER_DAY
	push	DAYS_MEASURED
	push	OFFSET tempArray
	push	OFFSET allTempsMsg
	call	displayTempArray

	push	DAYS_MEASURED
	push	1
	push	OFFSET dailyHighs
	push	OFFSET highestTempsMsg
	call	displayTempArray

	push	DAYS_MEASURED
	push	1
	push	OFFSET dailyLows
	push	OFFSET lowestTempsMsg
	call	displayTempArray

	push	averageHigh
	push	OFFSET avgHighTempMsg
	call	displayTempWithString

	push	averageLow
	push	OFFSET avgLowTempMsg
	call	displayTempWithString

	push	OFFSET goodbyeMsg
	call	goodbye

	Invoke	ExitProcess,0
main ENDP

; ---------------------------------------------------------------------------------
; Name: printGreeting
;
; Description: Displays introductions.
;
; Preconditions: Introduction strings are initialized.
;
; Postconditions: Changes registers EDX.
;
; Receives:
;		[ebp + 12] = address of second intro string
;		[ebp + 8]  = address of first intro string
;
; Returns: none (prints strings to console)
; ---------------------------------------------------------------------------------
printGreeting PROC
	push	ebp
	mov		ebp, esp

	; Print intro1 and intro2
	mov		edx, [ebp+8]
	call	WriteString
	mov		edx, [ebp+12]
	call	WriteString

	pop		ebp
	ret		8
printGreeting ENDP

; ------------------------------------------------------------------------------
; Name: generateTemperatures
;
; Description: Generates random temperature values between a specified minimum
;              and maximum range and populates the passed array with them.
;
; Preconditions: Randomize should be called once in main to seed the generator.
;                ARRAYSIZE, MAX_TEMP, and MIN_TEMP must be defined.
;
; Postconditions: Changes registers EAX, ECX, ESI.
;
; Receives:
;		[ebp + 8]  = address of temperature array
;
; Returns: tempArray = array populated with random temperature values
; ------------------------------------------------------------------------------
generateTemperatures PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]					; tempArray address
	mov		ecx, ARRAYSIZE

	; Generate random values between max and min temp boundaries and move to temp array.
	_arrayFill:
		mov		eax, (MAX_TEMP-MIN_TEMP)+1	; Generate value between 0 and temp boundary difference
		call	RandomRange
		add		eax, MIN_TEMP				; Add min temp to fit value in boundaries
		
		mov		[esi], eax
		add		esi, TYPE DWORD				; Move to next array element
		loop	_arrayFill

	pop		ebp
	ret		4
generateTemperatures ENDP

; ---------------------------------------------------------------------------
; Name: findDailyHighs
;
; Description: Traverses the 2D temperature array row by row to find 
;              the maximum temperatures from each distinct day, storing
;              the values into a separate daily highs array.
;
; Preconditions: tempArray must be populated with valid temperature values.
;                DAYS_MEASURED and TEMPS_PER_DAY must be defined.
;
; Postconditions: Changes registers EAX, EBX, ECX, EDX, ESI.
;
; Receives:
;		[ebp + 12] = address of dailyHighs array
;		[ebp + 8]  = address of tempArray
;
; Returns: dailyHighs = array with highest temperature values
; ---------------------------------------------------------------------------
findDailyHighs PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]							; tempArray address
	mov		ebx, [ebp+12]							; dailyHighs address
	mov		edx, 0									; day counter
	
	; Find highest temperatures in every row and store them in dailyHighs.
	_dayRowLoop:
		cmp		edx, DAYS_MEASURED					; Check if temp array was fully traversed.
		je		_finished
		mov		eax, MIN_TEMP						; Start at min temp to only get highest temp.
		mov		ecx, 0

		_tempColumnLoop:
			cmp		ecx, TEMPS_PER_DAY				; Check if current row is finished.
			je		_rowFinished

			cmp		eax, [esi + ecx * 4]			; Check for new high temp.
			jl		_setNewHigh

			inc		ecx
			jmp		_tempColumnLoop

		; Set new highest temp.
		_setNewHigh:
			mov		eax, [esi + ecx * 4]
			inc		ecx
			jmp		_tempColumnLoop

		; Store highest temp found in row, move onto next row, move onto next dailyHighs index.
		_rowFinished:
			mov		[ebx + edx * 4], eax			; Store highest temp in current dailyHighs index.
			add		esi, TEMPS_PER_DAY * TYPE DWORD	; Move to next row.
			inc		edx
			jmp		_dayRowLoop

	_finished:
		pop		ebp
		ret		8
findDailyHighs ENDP

; --------------------------------------------------------------------------
; Name: findDailyLows
;
; Description: Traverses the 2D temperature array row by row to find 
;              the minimum temperatures from each distinct day, storing
;              the values into a separate daily lows array.
;
; Preconditions: tempArray must be populated with valid temperature values.
;                DAYS_MEASURED and TEMPS_PER_DAY must be defined.
;
; Postconditions: Changes registers EAX, EBX, ECX, EDX, ESI.
;
; Receives:
;		[ebp + 12] = address of dailyLows array
;		[ebp + 8]  = address of tempArray
;
; Returns: dailyLows = array with lowest temperature values
; --------------------------------------------------------------------------
findDailyLows PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]						; tempArray address
	mov		ebx, [ebp+12]						; dailyLows address
	mov		edx, 0								; day counter

	; Find lowest temperatures in every row and store them in dailyLows.
	_dayRowLoop:
		cmp		edx, DAYS_MEASURED				; Check if temp array was fully traversed.
		je		_finished
		mov		eax, MAX_TEMP					; Start at max temp to only get lowest temp.
		mov		ecx, 0			

		_tempColumnLoop:
			cmp		ecx, TEMPS_PER_DAY			; Check if current row is finished.
			je		_rowFinished

			cmp		eax, [esi + ecx * 4]		; Check for new low temp.
			jg		_setNewLow	

			inc		ecx
			jmp		_tempColumnLoop

		; Set new lowest temp.
		_setNewLow:
			mov		eax, [esi + ecx * 4]
			inc		ecx
			jmp		_tempColumnLoop

		; Store lowest temp found in row, move onto next row, move onto next dailyLows index.
		_rowFinished:
		mov		[ebx + edx * 4], eax			; Store lowest temp in current dailyLows index.
		add		esi, TEMPS_PER_DAY * TYPE DWORD	; Move to next row.
		inc		edx
		jmp		_dayRowLoop

	_finished:
		pop		ebp
		ret		8
findDailyLows ENDP

; -----------------------------------------------------------------------------
; Name: calcAverageLowHighTemps
;
; Description: Sums up the entries in both the daily high and daily low arrays, 
;              calculates their respective averages using division, and 
;              returns the final computed averages.
;
; Preconditions: dailyHighs and dailyLows arrays must be populated with proper
;                calculated temperature values. DAYS_MEASURED must be defined.
;
; Postconditions: Changes registers EAX, EBX, ECX, EDX, ESI, EDI.
;
; Receives:
;    [ebp + 20] = address of averageLow
;    [ebp + 16] = address of averageHigh
;    [ebp + 12] = address of dailyLows array
;    [ebp + 8]  = address of dailyHighs array
;
; Returns:
;		averageHigh = calculated average of highest temperatures
;       averageLow  = calculated average of lowest temperatures
; -----------------------------------------------------------------------------
calcAverageLowHighTemps PROC
	push	ebp
	mov		ebp, esp
	
	mov		esi, [ebp+8]				; dailyHighs array address
	mov		edi, [ebp+12]				; dailyLows array address
	mov		eax, 0						; high values accumulator
	mov		ebx, 0						; lowest values accumulator
	mov		ecx, 0						; accumulator loop counter

	; Sum highest and lowest temp values into different respective accumulators.
	_sumHighAndLow:
		add		eax, [esi + ecx * 4]	; Accumulated high values.
		add		ebx, [edi + ecx * 4]	; Accumulated low values.

		inc		ecx
		cmp		ecx, DAYS_MEASURED		; Check all days were traversed.
		jl		_sumHighAndLow

	; Calculate average of highest values, store in averageHigh, calculate average of lowest values, store in averageLow.
	_calcAverages:
		mov		ecx, DAYS_MEASURED
		
		; Divide accumulated high values by days measured and store quotient in averageHigh.
		cdq
		div		ecx
		mov		edx, [ebp+16]
		mov		[edx], eax

		; Divide accumulated low values by days measured and store quotient in averageLow.		
		mov		eax, ebx
		cdq
		div		ecx
		mov		edx, [ebp+20]
		mov		[edx], eax

	pop		ebp
	ret		16
calcAverageLowHighTemps ENDP

; ---------------------------------------------------------------------------------------
; Name: displayTempArray
;
; Description:	Displays a text title, then prints an array grid of elements where 
;				format depends on the row and columns values passed into parameters.
;
; Preconditions: Target array must be initialized. Title string must be null-terminated.
;
; Postconditions: Changes registers EAX, EBX, ECX, EDX, ESI.
;
; Receives:
;    [ebp + 20] = number of column elements per row
;    [ebp + 16] = number of rows to print
;    [ebp + 12] = address of the array to print
;    [ebp + 8]  = address of the title string to display
;
; Returns: none (displays text and data values to console)
; ---------------------------------------------------------------------------------------
displayTempArray PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+12]						; tempArray address
	mov		ecx, 0								; column counter	
	mov		ebx, 0								; row counter

	mov		edx, [ebp+8]						; Display array title.
	call	WriteString

	; Print all array numbers with whitespace padding.
	_displayArrayRow:
		cmp		ebx, [ebp+16]					; Check all rows have been traversed.
		jge		_finished

		mov		eax, [esi]						; Print current array value.
		call	WriteDec

		mov		al, ' '
		call	WriteChar
		call	WriteChar

		add		esi, TYPE DWORD
		inc		ecx
		cmp		ecx, [ebp+20]					; Check if traversed last row number.
		je		_jumpNextLine
		jmp		_displayArrayRow

	; Reset column counter, move to next row, increase row counter.
	_jumpNextLine:
		mov		ecx, 0
		inc		ebx
		call	CrLf
		jmp		_displayArrayRow

	_finished:
		call	CrLf
		pop		ebp
		ret		16
displayTempArray ENDP

; --------------------------------------------------------------------------
; Name: displayTempWithString
;
; Description: Displays a text description and a temperature average value.
;
; Preconditions: The description string must be null-terminated.
;
; Postconditions: Changes registers EAX, EDX.
;
; Receives:
;    [ebp + 12] = temperature average value
;    [ebp + 8]  = address of description string
;
; Returns: none (displays text and integer value to console)
; --------------------------------------------------------------------------
displayTempWithString PROC
	push	ebp
	mov		ebp, esp

	; Print highest/lowest temps average with description.
	mov		edx, [ebp+8]
	call	WriteString
	mov		eax, [ebp+12]
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ebp
	ret		8
displayTempWithString ENDP

; ------------------------------------------------------------
; Name: goodbye
;
; Description: Displays a farewell message to the user.
;
; Preconditions: The farewell string must be null-terminated.
;
; Postconditions: Changes registers EDX.
;
; Receives:
;    [ebp + 8] = address of farewell message
;
; Returns: none (displays farewell message to console)
; ------------------------------------------------------------
goodbye PROC
	push	ebp
	mov		ebp, esp

	; Print goodbye message.
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf

	pop		ebp
	ret		4
goodbye ENDP

END main