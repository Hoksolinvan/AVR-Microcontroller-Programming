; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

	;ldi R16, 0b01011100
	;ldi R16, 0b10110110 


	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

; Your solution here.




tst r16  ;test to see if r16 register is cleared from the very beginning. If it is that means that there is nothing to clear in the register and jumps branches to CLEARED label because the Z-flag is set
breq CLEARED


ldi r18, 0b00000001   ;bit-mask used to identify the location of the "first rightmost 1"
ldi r19, 0b11111111   ;bit-mask to create the final result
ldi r28, 0			  ;Position up until the first zero after the "first rightmost 1" was discovered   
ldi r29, 0			  ;register used for comparison  (r29=r28+r31)
ldi r30, 0			  ;Set when the "first rightmost 1" and will continue to be set for all the other "rightmost 1" has been encountered
ldi r31, 0			  ;Number of zeros before the "first rightmost 1"



LOOP:
	mov r17, r16 ;Makes a copy of r16 into r17
	and r17, r18 ;Logical AND r17 with r18 to identify where the first 1 is located
	tst r30   ;If r30 is zero, then it would jump to INCREMENTED. Increments r31 to keep track of the number of 0's before the first rightmost 1 is discovered
	breq INCREMENTED


ANCHOR:
	tst r17 ;if the result of the previous AND results in a zero then it would jump conditionally to "NEXT" because the "first rightmost 1" is not located there
	breq NEXT
	inc r30 ;if the previous branch didn't work then it increases to 1 because it tells us that the "first rightmost 1" has been encountered and it jumps unconditionally to NEXT
	rjmp NEXT




NEXT: 
	tst r30 ;Within this NEXT label it tests to see if r30==0 and if it is not equal to 0 then it jumps to SECONDNEXT where it tests r17 to see if its equal to 0
	brne SECONDNEXT
	
SECONDANCHOR:
	lsl r18  ;moves the single bitmask to the next bit position
	rjmp loop
	


SECONDNEXT:
	tst r17      ;if r17 is currently equal to 0, then it branches to "THIRDNEXT" because it tells us that now the first 0 after the contiguous ones have been discovered. Otherwise it jumps to SECONDANCHOR unconditionally
	breq THIRDNEXT
	rjmp SECONDANCHOR

THIRDNEXT:
	add r29,r17 ;adds the expected value of zero from r17 into r29 (because r17 is the first 0 after the contiguous ones have been discovered)
	add r29,r30 ;adds the value of r30 to r29
	cp r30, r29  ;if the value is equal to zero. This verifies that r17 is indeed the first zero after the contiguous and r30 which is the "first rightmost 1" has already been set.
	breq POSITIONS  ;branches to POSITIONS to add the number of 0 needed from the first bit position to create the bitmask
	

INCREMENTED:
	inc r31   ;r31 stores the number of 0s before the first rightmost 1
	rjmp ANCHOR



POSITIONS:
	add r28, r30   ;adds the number of 1's that satisfies the condition that have been encountered 
	add r28, r31   ;adds the number of 0's before the first one
	rjmp FINALLOOP

FINALLOOP:
	lsl r19   ;creates the mask within r19
	dec r28   ;Decrements the loop counter
	tst r28
	brne FINALLOOP  ;if r28 isn't empty yet then we have to continue to loop it
	brne MASK		;otherwise branches to MASK



MASK:
	mov r25, r16  ;moves the value of r16 into r25
	and r25, r19  ;masks r25 with r19. Therefore, the final result is in R25
	rjmp reset_rightmost_stop  ;jumps to the end of the program


CLEARED: 
	MOV r25,r16  ;moves the value of 0b00000000 into r25


; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========
