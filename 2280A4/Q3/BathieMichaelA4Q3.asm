; Michael Bathie, 7835010
; COMP 2280, Wayne Franz
; Assignment 4, Question 3
;
; This program implements left and right shifts with wrap around
;
; Data Dictionary:
; R6 - Stack
; R4 - Key
; R0 - User input & result after shifting

	.orig x3000

	LD R6, STACKBASE
	LD R4, Key

RUN
	LEA R0, PROMPT
	PUTS
	GETC
	OUT

	ADD R6, R6, #-1 	
	STR R0, R6, #0 ;store the user input on the stack

	ADD R6, R6, #-1 	
	STR R4, R6, #0 ;store Key on the stack

	ADD R6, R6, #-1 ;leave one spot for the return value

	LEA R0, NEW_LINE
	PUTS

	JSR shiftLeftN
	LEA R0, ENCRYPT
	PUTS

	LDR R0, R6, #0 ;get result from stack and print it
	OUT

	ADD R6, R6, #3 ;reset stack

	ADD R6, R6, #-1 	
	STR R0, R6, #0 ;store encrypted input on the stack

	ADD R6, R6, #-1 	
	STR R4, R6, #0 ;store Key on the stack

	ADD R6, R6, #-1 ;leave one spot for the return value

	LEA R0, NEW_LINE
	PUTS

	JSR shiftRightN
	LEA R0, DECRYPT
	PUTS

	LDR R0, R6, #0 ;get result from stack and print it 
	OUT

	LEA R0, NEW_LINE
	PUTS ;new lines
	PUTS
	PUTS
	ADD R6, R6, #3

	BR RUN

	halt

;subroutine encryptChar - accepts an ASCII character value and shifts all bits 1 to the left
;Data dictionary
;R1 - holds the original and shifted version of the number
;R2 - holds a mask to check if a wrap occurs

;Stack Frame:
;FP-3 - saved R2
;FP-2 - saved R1
;FP-1 - saved FP (R5)
;FP+0 - return value
;FP+1 - number to be shifted

encryptChar
	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1
	STR R2, R6, #0

	LDR R1, R5, #1 ;get our parameter from the stack

	;now do the shifting
	LD R2, WRAP_CHECK 
	AND R2, R2, R1

	ADD R1, R1, R1

	ADD R2, R2, #0
	BRz NO_WRAP1
	ADD R1, R1, #1 ;if we have wrap around, add 1 for the bit that fell off

NO_WRAP1
	STR R1, R5, #0

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET

;subroutine shiftLeftN - accepts a 16-bit number and a value for the numbers of times to shift it left (with wrap around)
;Data dictionary
;R1 - number that needs to be shifted & the result after shifting
;R2 - number of times to shift the number
;R3 - result from the shift

;Stack Frame:
;FP-4 - Saved R7
;FP-3 - Saved R2
;FP-2 - Saved R1
;FP-1 - Saved FP (R5)
;FP+0 - return value
;FP+1 - number of times to shift
;FP+2 - number to be shifted 

shiftLeftN
	ADD R6, R6, #-1 ;store R5
	STR R5, R6 #0

	ADD R5, R6, #1 ;make R5 point at the retun value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6 #0

	ADD R6, R6, #-1 ;store R2
	STR R2, R6 #0

	ADD R6, R6, #-1 ;store R7
	STR R7, R6 #0

	LDR R1, R5, #2 ;get number from stack
	LDR R2, R5, #1 ;get number of shifts from stack

	;begin shifting
	BRz noShifts
LOOP	
	ADD R6, R6, #-1 ;space on stack for new value to be shifted
	STR R1, R6, #0
	ADD R6, R6, #-1 ;space on stack for return value
	JSR encryptChar

	LDR R1, R6, #0 ;get return value from stack
	ADD R6, R6, #2 ;pop two values off stack

	ADD R2, R2, #-1
	BRp LOOP

	STR R1, R5, #0 ;get result

noShifts
	LDR R7, R6, #0 ;restore R7
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET

;subroutine decryptChar - Takes an ASCII character value and shifts all the bits right once
;Data dictionary
;R1 - Value to be shifted & result after shifting
;R2 - bit masks
;R3 - loop counter

;Stack Frame:
;FP-4 - Saved R3
;FP-3 - Saved R2
;FP-2 - Saved R1
;FP-1 - Saved FP (R5)
;FP+0 - return value
;FP+1 - number to shift

decryptChar
	ADD R6, R6, #-1 ;store R5
	STR R5, R6 #0
	
	ADD R5, R6, #1

	ADD R6, R6, #-1 ;store R1
	STR R1, R6 #0

	ADD R6, R6, #-1 ;store R2
	STR R2, R6 #0

	ADD R6, R6, #-1 ;store R3
	STR R3, R6 #0

	LDR R1, R5, #1 ;get our number from the stack

	;begin shifting.
	;for right shifting, the number will be shifted left 15 times.
	
	AND R3, R3, #0
	ADD R3, R3, #15

LOOP1
	LD R2, WRAP_CHECK
	AND R2, R2, R1 ;checking if we have to wrap around a bit
	BRz NO_WRAP
	
	ADD R1, R1, R1
	ADD R1, R1, #1 ;add 1 for the bit to wrap around
	BR SKIP ;dont shift twice

NO_WRAP
	ADD R1, R1, R1

SKIP
	ADD R3, R3, #-1
	BRp LOOP1
	
	STR R1, R5, #0

	LDR R3, R6, #0 ;restore R3
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET

;subroutine shiftRightN - accepts a 16-bit number and a value for the numbers of times to shift it right (with wrap around)
;Data dictionary
;R1 - number that needs to be shifted & the result after shifting
;R2 - number of times to shift the number
;R3 - result from the shift

;Stack Frame:
;FP-4 - Saved R7
;FP-3 - Saved R2
;FP-2 - Saved R1
;FP-1 - Saved FP (R5)
;FP+0 - return value
;FP+1 - number of times to shift
;FP+2 - number to be shifted 

shiftRightN
	ADD R6, R6, #-1 ;store R5
	STR R5, R6 #0

	ADD R5, R6, #1 ;make R5 point at the retun value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6 #0

	ADD R6, R6, #-1 ;store R2
	STR R2, R6 #0

	ADD R6, R6, #-1 ;store R7
	STR R7, R6 #0

	LDR R1, R5, #2 ;get number from stack
	LDR R2, R5, #1 ;get number of shifts from stack

	;begin shifting
	BRz noShifts1
LOOP2	
	ADD R6, R6, #-1 ;space on stack for new value to be shifted
	STR R1, R6, #0
	ADD R6, R6, #-1 ;space on stack for return value
	JSR decryptChar

	LDR R1, R6, #0 ;get return value from stack
	ADD R6, R6, #2 ;pop two values off stack

	ADD R2, R2, #-1
	BRp LOOP2

	STR R1, R5, #0 ;get result

noShifts1
	LDR R7, R6, #0 ;restore R7
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET


;Data Area
STACKBASE .FILL x4000
Key .FILL #3 ;how many times to shift the value
WRAP_CHECK .FILL b1000000000000000
PROMPT .stringz "Enter a char: "
ENCRYPT .stringz "Encrypted char: "
DECRYPT .stringz "Decrypted char: "
NEW_LINE .stringz "\n"

	.end