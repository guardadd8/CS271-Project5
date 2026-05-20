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

.code
main PROC
	call Randomize
	push OFFSET intro1
	push OFFSET intro2
	call printGreeting
	
	Invoke ExitProcess,0
main ENDP

printGreeting PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		edx, [ebp+8]
	call	WriteString
	mov		edx, [ebp+12]
	call	WriteString

	popad
	pop ebp
	ret 8
printGreeting ENDP



END main