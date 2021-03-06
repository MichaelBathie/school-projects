; Michael Bathie, 7835010
; COMP 2280, Wayne Franz
; Assignment 1, Question 2
;
; This program will store the 2's complement negation
; of an integer
;
; Register dictionary:
; r1 holds an integer to be negated
; r2 holds the negation of the data in r1

.orig x3000

; set up inital registers
LD r1, DATA1
and r2, r2, #0

; get the 2's complement negation
not r2, r1
add r2, r2, #1

;Next line was added later for testing

add r3, r1, r2

; stop the machine
halt

; data area - define any labels you use in your code here
; note: labels use capital letters by convention
DATA1 .fill #80

; tell the assembler this is the end of the source file
.end