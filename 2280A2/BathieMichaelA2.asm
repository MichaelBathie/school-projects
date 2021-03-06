; Michael Bathie, 7835010
; Assignment 2, Question 1
;
; This program permutes a 16 bit number
;
; Register Dictionary:
; r0 holds temp values
; r1 holds a workable version of the original number
; r2 holds a mask for the starting point of the bit we're shifting
; r3 holds a mask for the destination of the bit we're shifting
; r4 will hold the 2's complement negation of the original number
; r5 holds the WriteStep and misc values when needed
; r6 will count the number of rounds
; r7 holds temp values

	.orig x3000 

; set up initial registers

	ld r1 NUMBER
	and r2, r2, #0
	and r3, r3, #0
	add r2, r2, #1
	add r3, r3, #1
	and r6, r6, #0
	ld r5 WRITESTEP
	
; ***** Compute the 2's complement *****

	and r4, r4, #0

; get the 2's complement negation
	not r4, r1
	add r4, r4, #1

; ***** Finish 2's complement computation *****

	br DESTLOOP

RUN
	ld r5 WRITESTEP
	add r2, r2, #0
	brzp OVER
	and r2, r2, #0 ;reset the bit counter if it's at the last bit
	add r2, r2, #1
	br SKIPOVER
OVER
	add r2, r2, r2
SKIPOVER
	add r3, r3, #0
	brn NEGATIVE

DESTLOOP ;increment by writestep
	add r3, r3, #0
	brn NEGATIVE
	add r3, r3, r3
	br OF
NEGATIVE
	and r3, r3, #0
	add r3, r3, #1
OF
	add r5, r5, #-1
	brp DESTLOOP

; check value of a bit
	and r5, r1, r2
	brz RUN	

; the bit we checked was one
; check the destination for this bit to see if it is the same.
; if it is, just go back to the start and run on the next set of bits
	and r5, r1, r3
	brnp RUN

; swap the two bits when the start bit is 1 and the destination bit is 0
SWAP1
	not r5, r1
	add r5, r5, r2
	and r4, r4, #0
	add r4, r1, r4
;	*** xor ***
	not r4, r4
	not r7, r5
	and r7, r7, r4
	not r7, r7
	not r4, r4
	and r0, r5, r4
	not r0, r0
	and r0, r7, r0
;	***     ***
	and r1, r0, r1
	add r1, r1, r3

CHECK

; ***** Compute the 2's complement *****

	and r4, r4, #0
	ld r0 NUMBER

; get the 2's complement negation
	not r4, r0
	add r4, r4, #1

; ***** Finish 2's complement computation *****

; increment the round counter
	add r6, r6, #1
	add r5, r1, r4
	brnp RUN

; we're done so print the output
	lea r0, OUTPUT
	trap x22
	ld r0 ASCII
	add r0, r6, r0
	OUT

	halt

	
; data area
NUMBER 	.fill x0001
WRITESTEP .fill #3
OUTPUT	.stringz "Number of rounds: "
ASCII .fill x30 ; ASCII offset for printing
	
	
	.end
