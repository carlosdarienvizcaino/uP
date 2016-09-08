;
; StringTransformation.asm
;
; Created: 9/7/2016 7:32:09 PM
; Author : Carlos
;

.nolist	
.include "ATxmega128A1Udef.inc"
.list 

; Create Constants
.EQU STRING_ADDRESS = 0x100
.EQU OUTPUT_ADDRESS = 0x2000
.EQU PROGRAM_ADDRESS = 0X200
.EQU END_OF_WORD  = 0
.EQU A_BOUND = 0x41
.EQU Z_BOUND = 0x5A
.EQU Aa_BOUND = 0x61
.EQU Zz_BOUND = 0x7A
.EQU DIFF = 0x20

; Create Register Aliases
.DEF tempChar = r15
.DEF currentChar = r16
.DEF boundReg = r17
.DEF diffReg = r18

.org 0x000
	rjmp MAIN

; &Hello$World&AZaz should be converted to &hELLO$wORLD&azAZ
.org STRING_ADDRESS
	Word: .DB "&Hello$World&AZaz"

.dseg
.org OUTPUT_ADDRESS
OUTPUT : .BYTE 1

.cseg
.org PROGRAM_ADDRESS
MAIN:

	; Point Z to beginning of word
	ldi ZL, low(Word << 1)
	ldi ZH, high(Word << 1)

	; Point Z to the begging of output (new word) memory
	ldi YL, low(OUTPUT_ADDRESS)
	ldi YH, high(OUTPUT_ADDRESS)

	; Load diff value to reg
	ldi diffReg, DIFF

	LOOP:
		; Load current character 
		lpm currentChar, Z+
		
		; If current character is less than A
		cpi currentChar, A_BOUND
		brlo NOT_A_LETTER

		; If current character is greater than Z
		ldi boundReg, Z_BOUND
		mov tempChar, currentChar
		sub tempChar, boundReg
		breq CONVERT_TO_LOWER_CASE
		brpl IGNORE_CAPITAL_CASE

		; Convert Capital Case to Lower Case and Save it
		CONVERT_TO_LOWER_CASE:
		mov tempChar, currentChar
		add tempChar, diffReg
		st Y+, tempChar
		rjmp END_OF_LOOP

		IGNORE_CAPITAL_CASE:
		; If current character is less than a
		cpi currentChar, Aa_BOUND
		brlo NOT_A_LETTER

		; If current Character is greater than z
		ldi boundReg, Zz_BOUND
		mov tempChar, currentChar
		sub tempChar, boundReg
		breq CONVERT_TO_UPPER_CASE
		brpl NOT_A_LETTER

		; Convert Lower Case to Upper Case and Save it
		CONVERT_TO_UPPER_CASE: 
		mov tempChar, currentChar
		sub tempChar, diffReg
		st Y+, tempChar
		rjmp END_OF_LOOP

		NOT_A_LETTER:
		; Save the character althoug is not a letter
		st Y+, currentChar
		
		END_OF_LOOP:
		; If end of word
		cpi currentChar, END_OF_WORD
		brne LOOP


END: rjmp END