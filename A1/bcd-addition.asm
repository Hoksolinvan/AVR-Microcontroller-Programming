; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
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
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;   *  0x94 in R16
;   *  0x09 in R17
; with the result of the addition being:
;   * 0x03 in R25
;   * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If 
; the digits are encoded as BCD, we would have
;   * 0x35 in R16
;   * 0x49 in R17
; with the result of the addition being:
;   * 0x84 in R25
;   * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).



    .cseg
    .org 0

	; Some test cases below for you to try. And as usual
	; your solution is expected to work with values other
	; than those provided here.
	;
	; Your code will always be tested with legal BCD
	; values in r16 and r17 (i.e. no need for error checking).

	; 94 + 9 = 03, carry = 1
	;ldi r16, 0x94
	;ldi r17, 0x09

	; 86 + 79 = 65, carry = 1
	 ;ldi r16, 0x86
	 ;ldi r17, 0x79

	; 35 + 49 = 84, carry = 0  
	 ;ldi r16, 0x35
	;ldi r17, 0x49

	; 32 + 41 = 73, carry = 0
	;ldi r16, 0x32
	;ldi r17, 0x41

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
		

	

		;Low nibble of r16
		MOV r18, r16
		ANDI r18, 0b00001111    ;we are only interested in the lower nibble

		;Low nibble of r17
		MOV r19, r17
		ANDI r19, 0b00001111   ;we are only interested in the lower nibble

		;High nibble of r16
		MOV r20, r16
		ANDI r20, 0b11110000   ;we are only interested in the higher nibble
		swap r20   ;swaps the position of the low nibble with the position of the high nibble

		;High nibble of r17
		MOV r21, r17
		ANDI r21, 0b11110000  ;we are only interested in the higher nibble
		swap r21  ;swaps the position of the low nibble with the position of the high nibble


		ADD r18,r19       
		cpi r18, 0b00001001     ;compares the value of r18 to see if its lower than, equal to, or higher than the binary representation of the value 9
		brmi next ;if r18 is lower than 9, branches because the N flag is set  ===branches to next label===
		breq next ;if r18 is equal to 9, branches because the Z flag is set    ===branches to next label===
		
		;If the previous condition doesn't work this tells us that r18 is higher than r19
		SUBI r18, 0b11111010  ;Adds binary equivalent of 6
		ANDI r18, 0b00001111  ;We are only interested in the lowernibble
		rjmp upperadder1      ;unconditionally transfer control to upperadder1

		next: ;this tells us that the previous addition of r18 and r19 doesn't exceed the value 9. Therefore, we don't have to consider the carry value.      
			ADD r20,r21
			cpi r20,0b00001001
			brmi secondnext  ;if r20 is lower than 9, branches because the N flag is set
			breq secondnext  ;if r20 is equal to 9, branches because the Z flag is set

		;Otherwise if the previous addition causes it to exceed the value of 9
		SUBI r20, 0b11111010 ;Adds the binary equivalent of 6
		LDI r24, 1  ;set r24 to 1, because it exceeded the value of 9
		ANDI r20, 0b00001111  ;we don't care about the higher nibble for this current register
		swap r20   ;swap the position of the higher nibble with the position of the lower nibble
		ADD r25,r18  ;adds the lower nibble of r18 to the lower nibble of r25
		ADD r25,r20  ;adds the higher nibble of r20 to the higher nibble of r25
		rjmp bcd_addition_end  ;The program finishes

		 



		secondnext:
			LDI r24, 0   ;set r24 to 0, because the to-be higher nibble addition didn't resulted in a value greater than 9		
			add r25, r18   ;adds the lower nibble of r18 to the lower nibble of r25
			swap r20       ;changes r20 position to the higher nibble instead
			add r25,r20    ;adds the higher nibble of r20 to the higher nibble of r25
			rjmp bcd_addition_end   ;the program finishes


		upperadder1:     ;if the previous lower nibble addition of r18 and r19 exceeded a value of 9
			ADD r20,r21    ;adds the value of r20 and r21
			SUBI r20,0b11111111   ;also adds an additional 1 because there was a half-carry
		
			CPI r20, 0b00001001  ;compares to see if the value of r20 exceeded the value of 9
			brmi secondnext  ;if r20 is lower than 09, branches because the N flag is set
			breq secondnext  ;if r20 is equal to 09, branches because the Z flag is set
			;if r20 is greater than the value of 9

		SUBI r20, 0b11111010  ;adds the value of r20 with 6 to reconfigure for BCD addition
		ANDI r20, 0b00001111  ;we are only interested in the lower nibble here
		LDI r24, 1     ;because the value of r20 exceeded 9 we load the value of 1 into r24
		ADD r25,r18    ;adds the lower nibble of r18 to r25
		swap r20      ;swap the lower nibble of r20 to be in the higher nibble position instead
		ADD r25,r20    ;adds the high nibble of r20 to the high nibble of r25
		rjmp bcd_addition_end   ;the program finishes




; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
