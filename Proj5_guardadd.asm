TITLE Temperature Statistics Program     (Proj5_guardadd.asm)

; Author: Daniel Guardado
; Last Modified:	5/23/2026
; OSU email address: guardadd@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5               Due Date: 5/24/2026
; Description: ******This file is provided as a template from which you may work
;              when developing assembly projects in CS271.*****

INCLUDE Irvine32.inc

DAYS_MEASURED = 14
TEMPS_PER_DAY = 11
MIN_TEMP = 20
MAX_TEMP = 80
ARRAYSIZE = DAYS_MEASURED*TEMPS_PER_DAY

.data

	intro1			BYTE	"Welcome to Temperature Statistics Program by Daniel Guardado",13,10,0
	intro2			BYTE	"This program generates a series of temperature readings, X per day for Y days",13,10
					BYTE	"(depending on CONSTANTs), and performs some basic statistics on them: daily",13,10
					BYTE	"high and low and average high and low temps. It then prints these results, ",13,10
					BYTE	"with descriptive titles.",13,10,0

	tempArray		DWORD ARRAYSIZE	DUP(?)
	dailyHighs		DWORD DAYS_MEASURED	DUP(?)
	dailyLows		DWORD DAYS_MEASURED	DUP(?)
	avgHighTemp		DWORD ?
	avgLowTemp		DWORD ?

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
	
	; test
	mov		eax, dailyHighs[0]
	call	WriteInt
	call	crlf
	mov		eax, dailyHighs[1*4]
	call	WriteInt
	call	crlf
	mov		eax, dailyHighs[2*4]
	call	WriteInt
	call	crlf
	mov		eax, dailyHighs[3*4]
	call	WriteInt
	call	crlf
	mov		eax, dailyHighs[4*4]
	call	WriteInt
	call	crlf
	mov		eax, dailyHighs[13*4]
	call	WriteInt
	call	crlf

	Invoke	ExitProcess,0
main ENDP

printGreeting PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+8]
	call	WriteString
	mov		edx, [ebp+12]
	call	WriteString

	pop		ebp
	ret		8
printGreeting ENDP

generateTemperatures PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]
	mov		ecx, ARRAYSIZE

	_arrayFill:
		mov		eax, (MAX_TEMP-MIN_TEMP)+1
		call	RandomRange
		add		eax, MIN_TEMP
		
		mov		[esi], eax
		add		esi, TYPE DWORD
		loop	_arrayFill

	pop		ebp
	ret		4
generateTemperatures ENDP

; traverse 11 rows of tempArray, find highest temp per row, set current dailyHighs index with valuem, if counter is 11/>10 (end of current row),
; increase counter for dailyHighs array, reset tempArray counter to 11. Keep going until last tempArray element is seen. Find highest 14 temps.
findDailyHighs PROC
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+8]	; tempArray
	mov		ebx, [ebp+12]	; dailyHighs
	mov		edx, 0			; tempArray row and dailyHighs counter, 0-13 (cover 14 days)

	_dayRowLoop:
		cmp		edx, DAYS_MEASURED
		je		_finished

		mov		eax, MIN_TEMP	; start at '20' to only ever get highest temps for dailyHighs
		mov		ecx, 0

		_tempColumnLoop:
			cmp		ecx, TEMPS_PER_DAY
			je		_rowFinished

			cmp		eax, [esi+ecx*4]
			jl		_setNewHigh

			inc		ecx
			jmp		_tempColumnLoop

		_setNewHigh:
			mov		eax, [esi+ecx*4]
			inc		ecx
			jmp		_tempColumnLoop

		_rowFinished:
			mov		[ebx+edx*4], eax
			add		esi, TEMPS_PER_DAY * 4
			inc		edx
			jmp		_dayRowLoop
	_finished:
		pop		ebp
		ret		8
findDailyHighs ENDP


END main