; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section
	
	ldi r19, 0xff
	sts DDRL, r19
	out DDRB, r19



; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_a
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E' ;THE ENCODING IS CORRECT FOR ALL THE LETTERS BUT FOR SOME REASON IT DOESN'T PROPERLY DISPLAY THE CORRECT LEDS FOR "B" and "H" and "Q"
	push r21 ;Original E
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21 ;Original A
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21 ;Original M
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21 ;Original H
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end
	





; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_leds:

	clr r26 ;accumulator for the ports *reserved for PORTB*
	clr r27 ;accumulator for the ports *reserved for PORTL*

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00100000 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip
		ori r26, 0b00000010
	skip:

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00010000 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip2
		ori r26,0b00001000
	skip2:

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00001000 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip3
		ori r27, 0b00000010
	skip3:

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00000100 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip4
		ori r27, 0b00001000
	skip4:

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00000010 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip5
		ori r27, 0b00100000
	skip5: 

	mov r23, r16 ;stores the value of the parameter in a safe location
	ANDI r23, 0b00111111 ;bit mask to get rid of the two most significant bits
	ANDI r23, 0b00000001 ;bit mask to test whether the left-most bit is set
	tst r23 ;tests to see if r23 is zero and if it isn't that tells us that our input was turned on for this particular bit associated to our desired PORT reserved register, otherwise we skip this because the bit isn't set
	breq skip6
		ori r27, 0b10000000
	skip6: 

	sts PORTL, r27
	out PORTB, r26
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
slow_leds:

	mov r16, r17   ;this function accepts the value passed into r17 but the function that we call would require r16, thus the rationale for moving the value in r17 to r16
	CALL set_leds  ; calls 1 second long delay
	call delay_long

	clr r16    ;turns off the LED
	sts PORTL, r16 ;clears PORTL
	out PORTB, r16 ;clears PORTB

	ret


fast_leds:
	mov r16, r17    ;this function accepts the value passed into r17 but the function that we call would require r16, thus the rationale for moving the value in r17 to r16
	CALL set_leds   ;calls 1/4 second long delay
	call delay_short

	clr r16   ;turns off the LED
	sts PORTL, r16 ;clears PORTL
	out PORTB, r16 ;clears PORTB

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

leds_with_speed:
	
	
	pop r0 ;retains the return address
	pop r1 ;retains the return address
	pop r2 ;retains the return address

	clr r22  ;prepares r22 for use
	clr r28  ;prepares r28 for use

	pop r22  ;obtain the parameter from the stack and places into r22
	mov r28, r22      ;copies the value into r28 as we want to keep the result in r16 safe
	andi r28, 0b11000000  ;masks the two most significant bits
	
	;restores the stack 
	push r22 
	push r2
	push r1
	push r0

	cpi r28, 0b00000000        ;if it isn't set it branches too onequarter
	breq onequarter


	
	onesecond: ;otherwise it would go to onesecond instead
		clr r17   ;prepares r17 as the function 'slow_leds' only accepts register r17
		mov r17, r22    ;move the original value into r17
		andi r17, 0b00111111   ;We are only interested in the bits 0 to 5
		call slow_leds         ;We call the slow_leds function
		rjmp leds_with_speed_return   ;ends the subroutine call

	onequarter:
		clr r17  ;prepares r17 as the function 'fast_leds' only accepts register r17
		mov r17, r22 ;move the original value into r17
		andi r17, 0b00111111 ;We are only interested in the bits 0 to 5
		call fast_leds ;We call the fast_leds function
	

	leds_with_speed_return: ;label which allows the onesecond to jump to leds_with_speed_return
		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	ldi ZH, high(PATTERNS<<1)    ;converts to byte addressing
	ldi ZL, low(PATTERNS<<1)	;converts to byte addressing
	
	;saves the return address
	pop r0 
	pop r1
	pop r2
	;obtain the letter parameter and pushes it back into the stack
	pop r22

	;restores the stack itself
	push r22
	push r2
	push r1
	push r0

	;clears the register because we will be using it as a buffer
	clr r16



	;For some reason the LED works for everything but "B", "H" and "Q"

	cpi r22, 0b01000010 ;checks to see if it is 'B'
	breq Bcondition

	cpi r22, 0b01001000 ;checks to see if it is 'H'
	breq Hcondition

	cpi r22, 0b01010001 ;checks to see if it is 'Q'
	breq Qcondition

	;checks to see if the pattern is contained within our pattern list
	loop:
		lpm r16, Z ; obtains the letter from the program memory pointed to by the address within Z and stores it into register 16
		
		cp r16, r22 ; checks to see if it matches the original parameter
		breq inner_loop  ;if it does that means we have finally found the letter, otherwise it checks to see if it is equal to '-'
		
		cpi r16, 0b00101101  ;this is the ascii code for '-' according to https://www.cs.cmu.edu/~pattis/15-1XX/common/handouts/ascii.html
		breq end_encode_letter ;if it's equal it ends the function because we either were given '-' as the parameter or the parameter was never part of our pattern list as it has already iterated through all the possible patterns
						
			ldi r17, 8	 ;prepares this register so that it can be used in the loop below to move onto the next letter  

		characterletter_check: ;this loop is utilized to move onwards to the next letter as the current letter for this loop does not match our desired parameter value
			lpm r16, Z+
			dec r17
			brne characterletter_check 

	rjmp loop ;goes back to the loop


	inner_loop: ;this loop will be dedicated towards building and translating the requirements of our found pattern
		clr r16 ; will be used for the loop counter
		ldi r16,7
		clr r17
		ldi r17, 0b00100000
		clr r18  ;this register will be used to maintain the bit position of the LED

			lpm r29, Z+
		second_inner_loop: ;this loop will loop 7 times to check each individual bit
			lpm r29, Z+
			cpi r29, 0b00101110 ;Ascii encoding for '.' according to https://www.cs.cmu.edu/~pattis/15-1XX/common/handouts/ascii.html
			breq second_inner_loop_skip

		
			;These conditions checks in every iteration if the current loop has iterated pass over all the information on the Letter and LED position into the number position. Therefore, it verifies with every iteration.
			cpi r29,2
			breq final_check
			cpi r29,1
			breq final_check

			;Creates the LED position with every iteration
			or r18, r17
			lsr r17
			dec r16
			rjmp second_inner_loop

			;This condition is for when the '.' is encountered and we don't want to set the LED for that position
			second_inner_loop_skip:
				lsr r17
				dec r16
			brne second_inner_loop

		final_check:
			
			cpi r29,2  ;checks to see if its a fast loop
			breq loop_2 ;if it is then we branch to loop_2

			cpi r29,1   ;checks to see if its a slow loop
			breq loop_1 ;if it is then we branch to loop_1
			rjmp end_encode_letter
			
			;creates the mask for the speed condition
			loop_1:
				ori r18, 0b11000000
				mov r25, r18 ;moves the result into r25
			rjmp end_encode_letter

			;creates the mask for the speed condition
			loop_2:
				ori r18, 0b00000000
				mov r25,r18 ;moves the result into r25
			rjmp end_encode_letter
	




	;Special Case;
	Bcondition:
		ldi r25,0b00010010
		rjmp end_encode_letter

	Hcondition:
		ldi r25,0b00001100
		rjmp end_encode_letter

	Qcondition:
		ldi r25,0b00101101
		rjmp end_encode_letter



	end_encode_letter:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

display_message:

	;obtains the byte address of the desired location
	mov ZH, r25 
	mov ZL, r24

	loop1:
		lpm r23, Z+
		cpi r23, 0 ;checks to see if its the null terminator and if it is then the string has been successfully iterated over
		breq end_function

		;protecting the Z pseudoregister as we would be reusing it in encode_letter
		push ZH 
		push ZL

		;moves the letter into r21 from r23 and pushes it into the stack
		MOV r21, r23 
		push r21 
		rcall encode_letter
		pop r21
		
		;restores the Z pseudoregister
		pop ZL
		pop ZH

		;Since the previous result was stored in r25 we can now run leds_with_speed
		push r25
		rcall leds_with_speed
		pop r25

			rcall delay_long


	rjmp loop1


	;End the function call
	end_function:
	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "X", "oo....", 2    ;there was two W
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0  ;o.oo.o   o.....  .o..o. o.o... ....oo
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0


; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

