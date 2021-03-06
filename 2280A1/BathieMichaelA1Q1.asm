; Michael Bathie, 7835010
; COMP 2280, Wayne Franz
; Assignment 1, Question 1
;
; This program implements the bitwise OR and XOR operations.
;
; Register dictionary:
; r1 holds a 16 bit number
; r2 holds a 16 bit number
; r3 holds the "or" of r1 and r2
; r4 holds the "xor" of r1 and r2
; r5 holds the "not" of r1
; r6 holds the "not" of r2
; r7 holds the "not" of r1 and r2

.orig x3000

; set up initial registers
LD r1, DATA1
LD r2, DATA2
and r3, r3, #0

; compute the "or" of r1 and r2
not r5, r1
not r6, r2
and r3, r5, r6
not r3, r3

; compute the "xor" of r1 and 2
and r7, r1, r2
not r7, r7
and r4, r3, r7

halt

; data area
DATA1 .fill #86
DATA2 .fill #150

.end