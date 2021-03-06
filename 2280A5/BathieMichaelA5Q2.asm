;Michael Bathie, 7835010
;COMP 2280, Wayne Franz
;Assignment 4, Question 2
;
;This program implements a finite state machine for a robot deployed on a far away planet

	.orig x3000
	
	LD R6, STACKBASE
	
	AND R1, R1, #0 ;counter to iterate through string

	LEA R2, MSG
	ADD R2, R2, R1
	LDR R3, R2, #0
	BRz DONE
	ADD R1, R1, #1

	ADD R6, R6, #-1
	STR R3, R6, #0 ;store the current character

	ADD R6, R6, #-1 ;space for return value

	;because we don't have a character yet just go to the start routine
	JSR START_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack

LOOP
	LEA R2, MSG
	ADD R2, R2, R1
	LDR R3, R2, #0
	BRz DONE

	ADD R6, R6, #-1
	STR R3, R6, #0 ;store the current character

	ADD R6, R6, #-1 ;space for return value

	LD R4, HALT_PROCESS_CHECK
	ADD R4, R4, R5
	BRnp NOT_HALT

	JSR HALT_PROCESS_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack

	LEA R4, HALT_VALUE
	LDR R0, R4, #0
	OUT

	LD R0, SPACE
	OUT

	BR NEXT

NOT_HALT

	LD R4, EXECUTE_ACTION_CHECK
	ADD R4, R4, R5
	BRnp NOT_EXECUTE_ACTION

	JSR EXECUTE_ACTION_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack

	BR NEXT

NOT_EXECUTE_ACTION

	LD R4, ACTION_START_CHECK
	ADD R4, R4, R5
	BRnp NOT_ACTION_START
	
	JSR ACTION_START_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack

	BR NEXT

NOT_ACTION_START

	LD R4, MESSAGE_START_CHECK
	ADD R4, R4, R5
	BRnp NOT_MESSAGE_START
	
	JSR MESSAGE_START_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack
	BR NEXT

NOT_MESSAGE_START

	JSR START_SUBROUTINE

	LDR R5, R6, #0 ;get result from the stack
	ADD R6, R6, #2 ;clear stack

NEXT
	ADD R1, R1, #1
	BR LOOP

DONE
	LEA R0, DONE_MESSAGE
	PUTS

	halt

;subroutine HALT_PROCESS_SUBROUTINE - handles the "H" message
;Data Dictionary
;R1 - parameter
;R2 - helper for calculations
;R3 - result

;Stack Frame
;FP-3 - saved R3
;FP-2 - saved R2
;FP-1 - saved R1
;FP+0 - return value
;FP+1 - instruction to process

HALT_PROCESS_SUBROUTINE
	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1 ;store R2
	STR R2, R6, #0 

	ADD R6, R6, #-1 ;store R3
	STR R3, R6, #0 

	LDR R1, R5, #1 ;get the parameter from the stack

	;find the next state

	LD R2, A_CHECK
	ADD R2, R2, R1
	BRnp NOT_A1

	LD R3, ACTION_START

	BR DONE_HALT

NOT_A1

	LD R2, H_CHECK
	ADD R2, R2, R1
	BRnp NOT_H1

	LD R3, HALT_PROCESS

	BR DONE_HALT

NOT_H1

	LD R3, START

DONE_HALT
	
	STR R3, R5, #0

	LDR R3, R6, #0 ;restore R3
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET	

;subroutine EXECUTE_ACTION_SUBROUTINE - handles the "A#" message
;Data Dictionary
;R1 - parameter
;R2 - helper for calculations
;R3 - result

;Stack Frame
;FP-3 - saved R3
;FP-2 - saved R2
;FP-1 - saved R1
;FP+0 - return value
;FP+1 - instruction to process

EXECUTE_ACTION_SUBROUTINE
	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1 ;store R2
	STR R2, R6, #0 

	ADD R6, R6, #-1 ;store R3
	STR R3, R6, #0 

	LDR R1, R5, #1 ;get the parameter from the stack

	;find the next state

	LD R2, A_CHECK
	ADD R2, R2, R1
	BRnp NOT_A2

	LD R3, ACTION_START

	BR DONE_EXECUTE_ACTION

NOT_A2

	LD R2, H_CHECK
	ADD R2, R2, R1
	BRnp NOT_H2

	LD R3, HALT_PROCESS

	BR DONE_EXECUTE_ACTION

NOT_H2

	LD R3, START

DONE_EXECUTE_ACTION
	
	STR R3, R5, #0

	LDR R3, R6, #0 ;restore R3
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET	

;subroutine ACTION_START_SUBROUTINE - handles the "A" message
;Data Dictionary
;R1 - parameter
;R2 - helper for calculations
;R3 - result

;Stack Frame
;Fp-5 - saved R7
;FP-4 - saved R0
;FP-3 - saved R3
;FP-2 - saved R2
;FP-1 - saved R1
;FP+0 - return value
;FP+1 - instruction to process

ACTION_START_SUBROUTINE

	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1 ;store R2
	STR R2, R6, #0 

	ADD R6, R6, #-1 ;store R3
	STR R3, R6, #0 

	ADD R6, R6, #-1 ;store R0
	STR R0, R6, #0

	ADD R6, R6, #-1 ;store R7
	STR R7, R6 #0

	LDR R1, R5, #1 ;get the parameter from the stack

	;find the next state
	
	;if the next character is a number then print A#
	LD R2, NUM
	ADD R2, R1, R2
	BRp NOT_NUM

	LEA R2, ACTION_VALUE
	LDR R0, R2, #0
	OUT
	
	AND R0, R0, #0
	ADD R0, R1, R0
	OUT

	LD R0, SPACE
	OUT

	LD R3, EXECUTE_ACTION

	BR DONE_ACTION_START

NOT_NUM
	LD R3, START

DONE_ACTION_START
	
	STR R3, R5, #0

	LDR R7, R6, #0 ;restore R7
	ADD R6, R6, #1

	LDR R0, R6, #0 ;restore R0
	ADD R6, R6, #1

	LDR R3, R6, #0 ;restore R3
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET

;subroutine MESSAGE_START_SUBROUTINE - handles the "<" message
;Data Dictionary
;R1 - parameter
;R2 - helper for calculations
;R3 - result

;Stack Frame
;FP-3 - saved R3
;FP-2 - saved R2
;FP-1 - saved R1
;FP+0 - return value
;FP+1 - instruction to process

MESSAGE_START_SUBROUTINE
	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1 ;store R2
	STR R2, R6, #0 

	ADD R6, R6, #-1 ;store R3
	STR R3, R6, #0 

	LDR R1, R5, #1 ;get the parameter from the stack

	;find the next state

	LD R2, A_CHECK
	ADD R2, R2, R1
	BRnp NOT_A3

	LD R3, ACTION_START

	BR DONE_MESSAGE_START

NOT_A3

	LD R2, H_CHECK
	ADD R2, R2, R1
	BRnp NOT_H3

	LD R3, HALT_PROCESS

	BR DONE_MESSAGE_START

NOT_H3

	LD R2, ANGLE_BRACKET_CHECK
	ADD R2, R2, R1
	BRnp NOT_ANGLE_BRACKET1

	LD R3, MESSAGE_START

	BR DONE_MESSAGE_START

NOT_ANGLE_BRACKET1

	LD R3, START

DONE_MESSAGE_START
	
	STR R3, R5, #0

	LDR R3, R6, #0 ;restore R3
	ADD R6, R6, #1

	LDR R2, R6, #0 ;restore R2
	ADD R6, R6, #1

	LDR R1, R6, #0 ;restore R1
	ADD R6, R6, #1

	LDR R5, R6, #0 ;restore R5
	ADD R6, R6, #1

	RET

;subroutine START_SUBROUTINE - processes the start of a message
;Data Dictionary
;R1 - parameter
;R2 - helper for calculations
;R3 - result

;Stack Frame
;FP-3 - saved R3
;FP-2 - saved R2
;FP-1 - saved R1
;FP+0 - return value
;FP+1 - instruction to process

START_SUBROUTINE
	ADD R6,R6,#-1 ;store R5
	STR R5, R6, #0

	ADD R5, R6, #1 ;make R5 point to the return value

	ADD R6, R6, #-1 ;store R1
	STR R1, R6, #0 

	ADD R6, R6, #-1 ;store R2
	STR R2, R6, #0 

	ADD R6, R6, #-1 ;store R3
	STR R3, R6, #0 

	LDR R1, R5, #1 ;get the parameter from the stack

	;find the next state

	LD R2, ANGLE_BRACKET_CHECK
	ADD R2, R2, R1
	BRnp NOT_ANGLE_BRACKET2

	LD R3, MESSAGE_START

	BR DONE_START

NOT_ANGLE_BRACKET2

	LD R3, START

DONE_START
	
	STR R3, R5, #0

	LDR R3, R6, #0 ;restore R3
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
MSG .stringz "<HA0xA3<<A1>"
;
;printing
;
SPACE .FILL #32
;
;used for checks if we're looking at a number
;
NUM .FILL #-57
;
;check what we were passed in subroutines
;
A_CHECK .FILL #-65
H_CHECK .FILL #-72
ANGLE_BRACKET_CHECK .FILL #-60
;
;Used for printing
;
ACTION_VALUE .stringz "A"
HALT_VALUE .stringz "H"
DONE_MESSAGE .stringz "Done"
;
;Used to check what state we must transition to 
;
MESSAGE_START_CHECK .FILL #-1
ACTION_START_CHECK .FILL #-2
EXECUTE_ACTION_CHECK .FILL #-3
HALT_PROCESS_CHECK .FILL #-4
;
;States (enum values)
;
START .FILL #0
MESSAGE_START .FILL #1
ACTION_START .FILL #2
EXECUTE_ACTION .FILL #3
HALT_PROCESS .FILL #4


	.end