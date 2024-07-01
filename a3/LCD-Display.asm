;
; a3part-D.asm
;
; Part D of assignment #3
;
;
; Student name:
; Student ID:
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
; the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
; (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
; jmp timer3

.org 0x54
jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001
#define BUTTON_UP_MASK 0b00000010
#define BUTTON_DOWN_MASK 0b00000100
#define BUTTON_LEFT_MASK 0b00001000

#define BUTTON_RIGHT_ADC 0x032
#define BUTTON_UP_ADC 0x0b0 ; was 0x0c3
#define BUTTON_DOWN_ADC 0x160 ; was 0x17c
#define BUTTON_LEFT_ADC 0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024 ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

;initializating values
.def DATAH=r25
.def DATAL=r24


.equ ADCL_BTN=0x78
.equ ADCH_BTN=0x79

.equ RIGHTVALUE=BUTTON_RIGHT_ADC
.equ UPVALUE=BUTTON_UP_ADC
.equ DOWNVALUE=BUTTON_DOWN_ADC
.equ LEFTVALUE=BUTTON_LEFT_ADC

;initializes the top_line_content
ldi YL, low(top_line_content)
ldi YH, high(top_line_content)
ldi r22, ' '
st Y,r22
std Y+1,r22
std Y+2,r22
std Y+3,r22
std Y+4,r22
std Y+5,r22
std Y+6,r22
std Y+7,r22
std Y+8,r22
std Y+9,r22
std Y+10,r22
std Y+11,r22
std Y+12,r22
std Y+13,r22
std Y+14,r22
std Y+15,r22


;initialization of current_charset_index
ldi r21,0

ldi YL, low(current_charset_index)
ldi YH, high(current_charset_index)

ldi r22,0
st Y, r22
std Y+1, r22
std Y+2, r22
std Y+3, r22
std Y+4, r22
std Y+5, r22
std Y+6, r22
std Y+7, r22
std Y+8, r22
std Y+9, r22
std Y+10, r22
std Y+11, r22
std Y+12, r22
std Y+13, r22
std Y+14, r22
std Y+15, r22

;initialization of last_button_pressed, button_is_pressed, and current_char_index
sts last_button_pressed,r22
sts button_is_pressed, r22
sts current_char_index,r22
;clears register pair
clr YL
clr YH
; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ==== START OF "DO NOT TOUCH" SECTION ====
; =============================================

; initialize the ADC converter (which is needed
; to read buttons on shield). Note that we'll
; use the interrupt handler for timer 1 to
; read the buttons (i.e., every 10 ms)
;
ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
sts ADCSRA, temp
ldi temp, (1 << REFS0)
sts ADMUX, r16

; Timer 1 is for sampling the buttons at 10 ms intervals.
; We will use an interrupt handler for this timer.
ldi r17, high(TOP1)
ldi r16, low(TOP1)
sts OCR1AH, r17
sts OCR1AL, r16
clr r16
sts TCCR1A, r16
ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
sts TCCR1B, r16
ldi r16, (1 << OCIE1A)
sts TIMSK1, r16

; Timer 3 is for updating the LCD display. We are
; *not* able to call LCD routines from within an
; interrupt handler, so this timer must be used
; in a polling loop.
ldi r17, high(TOP3)
ldi r16, low(TOP3)
sts OCR3AH, r17
sts OCR3AL, r16
clr r16
sts TCCR3A, r16
ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
sts TCCR3B, r16
; Notice that the code for enabling the Timer 3
; interrupt is missing at this point.

; Timer 4 is for updating the contents to be displayed
; on the top line of the LCD.
ldi r17, high(TOP4)
ldi r16, low(TOP4)
sts OCR4AH, r17
sts OCR4AL, r16
clr r16
sts TCCR4A, r16
ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
sts TCCR4B, r16
ldi r16, (1 << OCIE4A)
sts TIMSK4, r16

sei

; =============================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

start:


	rcall lcd_init ;initializes the lcd


;infinite loop
stop:

	lds r16, 0x38 ;TIFR3
	andi r16, 0b00000010
	tst r16
	breq stop
	call timer3

rjmp stop


timer1:

;sets the bit of the ADC so that we can start accepting analog signals
	lds r16, ADCSRA
	ori r16, 0x40
	sts ADCSRA, r16

;waits until the ADCSRA ADC interrupt flag has been raised
wait:
	lds r16,ADCSRA
	andi r16, 0b00010000
	tst r16
	breq wait 

;get the converted values from the ADC
	lds DATAL, ADCL_BTN
	lds DATAH, ADCH_BTN


;creates an upperbound
	ldi r27, 0xE8
	ldi r28, 0x03


;if the upperbound is not exceeded this tells us that the buttons are being pressed
	cp DATAL, r27
	cpc DATAH, r28
	brlo button_pressed

;otherwise r19 is set and we return back to where we came from
	ldi r19, 0
	sts button_is_pressed, r19
reti

button_pressed:
;set the button_is_pressed value to 1
	ldi r19, 1
	sts button_is_pressed, r19


;conditional checking for right_button
	ldi r27, low(RIGHTVALUE)
	ldi r28, high(RIGHTVALUE)
	cp DATAL, r27
	cpc DATAH, r28
	brlt right_button_pressed

rjmp next1

next1:
;conditional checking for up_button
	ldi r27, low(UPVALUE)
	ldi r28, high(UPVALUE)
	cp DATAL, r27
	cpc DATAH, r28
	brlt up_button_pressed
rjmp next2

next2:
;conditional checking for down_button
	ldi r27, low(downvalue)
	ldi r28, high(downvalue)
	cp DATAL, r27
	cpc DATAH, r28
brlo down_button_pressed

next3:
;conditional checking for left_button
	ldi r27, low(leftvalue)
	ldi r28, high(leftvalue)
	cp DATAL, r27
	cpc DATAH, r28
brlo left_button_pressed
rjmp end_timer1


right_button_pressed:
;initializes the last_button_pressed with right_button value
	ldi r27,4
	sts LAST_BUTTON_PRESSED, r27
rjmp end_timer1

up_button_pressed:
;initializes the last_button_pressed with up_button value
	ldi r27,3
	sts LAST_BUTTON_PRESSED, r27
rjmp end_timer1

down_button_pressed:
;initializes the last_button_pressed with down_button value
	ldi r27,2
	sts LAST_BUTTON_PRESSED, r27
rjmp end_timer1

left_button_pressed:
;initializes the last_button_pressed with left_button value
	ldi r27,1
	sts LAST_BUTTON_PRESSED, r27
rjmp end_timer1

end_timer1:
reti

; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).
timer3:
;function prolog
	push r18
	push r19
	push YL
	push YH

	;clears the timer3 interrupt flag
	lds r16, 0x38 ;TIFR3
	ori r16, 0b00000010 
	sts 0x38, r16
	
	
	
	
	;Incessant refresh of top_line_contents
	ldi r18, 0
    ldi r19, 0
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18 

	ldi YL,low(top_line_content)
	ldi YH,high(top_line_content)

	ld r18, Y
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+1
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+2
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+3
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+4
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+5
    push r18
    rcall lcd_putchar
	pop r18

	ldd r18, Y+6
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+7
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+8
    push r18
    rcall lcd_putchar
    pop r18

	ldd r18, Y+9
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+10
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+11
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+12
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+13
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+14
    push r18
    rcall lcd_putchar
    pop r18
	ldd r18, Y+15
    push r18
    rcall lcd_putchar
    pop r18
	nop

	; If the button is not being pressed, write '-' to the LCD
   	ldi r18, 1
    ldi r19, 15
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18

	 ldi r18, '-'
    push r18
    rcall lcd_putchar
    pop r18

	;checks the condition of button_is_pressed
    lds r16, button_is_pressed
    cpi r16,1
    breq button_pressed1

    
	;function epilog if the condition was not satisfied above
	pop YH
	pop YL
	pop r19
	pop r18
	
    ret

button_pressed1:
    ; If the button is pressed, write '*' to the LCD
	ldi r18, 1
    ldi r19, 15
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18

    ldi r18, '*'
    push r18
    rcall lcd_putchar
    pop r18


	;checks last_button_pressed
	lds r22, last_button_pressed
	cpi r22, 1
	brne skip1
	
	left_button: ;Left Button
	ldi r18, 1
    ldi r19, 0
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18 

	ldi r18, 'L'
    push r18
    rcall lcd_putchar
    pop r18


	ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

		
	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18
	rjmp timer3_end



	skip1:
	lds r22, last_button_pressed
	cpi r22, 2
	brne skip2

	down_button: ;Down Button

	ldi r18, 1
    ldi r19, 0
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18 

	ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	ldi r18, 'D'
    push r18
    rcall lcd_putchar
    pop r18

	ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18
	rjmp timer3_end

	skip2:
	lds r22, last_button_pressed
	cpi r22, 3
	brne skip3

	up_button: ;UP button


	ldi r18, 1
	ldi r19, 0
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	ldi r18, 'U'
    push r18
    rcall lcd_putchar
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18
	rjmp timer3_end
	


	skip3:
	lds r22, last_button_pressed
	cpi r22, 4
	brne timer3_end
	right_button:
	ldi r18, 1
    ldi r19, 0
    push r18  ; row
    push r19  ; column
    rcall lcd_gotoxy
    pop r19
    pop r18 
	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18
	
	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	 ldi r18, ' '
    push r18
    rcall lcd_putchar
    pop r18

	ldi r18, 'R'
    push r18
    rcall lcd_putchar
    pop r18


	;function epilog
	timer3_end:
	
	pop YH
	pop YL
	pop r19
	pop r18
    ret

timer4:
;function prolog
push r21
push r16
push r1
push YL
push YH

;prepares the register for use
	clr r1
	clr r16

;checks if there were any button pressed
	lds r16, button_is_pressed
	cpi r16,0
	brne button__pressed
pop YH
pop YL
pop r1
pop r16
pop r21
reti

;checks the previous button pressed
button__pressed:
	lds r16, last_button_pressed
	cpi r16,1
	breq left__button_pressed
	cpi r16, 4
	breq right__button_pressed
rjmp right_up

;retrieves current_char_index value to see if its the left button
left__button_pressed:
	lds r16, current_char_index
	cpi r16,0
	brne inner_left_button_pressed
rjmp end
inner_left_button_pressed:
	dec r16
	sts current_char_index, r16
rjmp end


;retrieves current_char_index value to see if its the right button
right__button_pressed:
	lds r16, current_char_index
	cpi r16,15
	brne inner_right_button_pressed

pop YH
pop YL
pop r1
pop r16
pop r21
reti
inner_right_button_pressed: ;if it actually is we increment it then
	inc r16
	sts current_char_index, r16
rjmp end




;checks to see which button was pressed
right_up:
	cpi r16,2
	breq decrement
	cpi r16,3
	breq increment
brne end

increment:
	lds r1, current_char_index 
	ldi YL, low(current_charset_index)
	ldi YH, high(current_charset_index)


	clr r0 ;r0 is the zero register

	add YL, r1
	adc YH, r0 ;r0 is the zero register

	ld r21,Y
	inc r21
	st Y,r21 ;stored into current_charset_index
rjmp continue

decrement:
	lds r1, current_char_index 
	ldi YL, low(current_charset_index)
	ldi YH, high(current_charset_index)

	clr r0

	add YL,r1
	adc YH,r0 ;r0 is the zero register

	ld r21,Y
	cpi r21,0
	breq end
	dec r21
	st Y,r21 ;stored into current_charset_index


;procedure for updating lcd
continue:
	ldi ZL, low(available_charset<<1)
	ldi ZH, high(available_charset<<1)


	add ZL, r21
	adc ZH, r0 ;r1 is a zero-valued register

	lpm r16,Z

	tst r16
breq third_end ;if the value is loaded with zero, it will branch because either it has reached the null-terminator or it went beyond the range where there are no other values stored at those program memory locations


second_end: ;the character sequence was properly initialized within the range

	ldi ZL, low(top_line_content)
	ldi ZH, high(top_line_content)

	add ZL, r1 ;setting the position for top_line_content array
	adc ZH, r0

	st Z, r16
	;we don't need to set the character_charset_index for this because we didn't modified anything 
rjmp end

third_end: ;condition for when r21 exceeds the current available characterset
	dec r21
	ldi ZL, low(available_charset<<1)
	ldi ZH, high(available_charset<<1)
	add ZL, r21
	adc ZH, r0
	lpm r16, Z

	lds r1, current_char_index 
	ldi YL, low(top_line_content)
	ldi YH, high(top_line_content)

	add YL,r1
	adc YH,r0

	st Y, r16
;sts top_line_content,r16

	ldi XL, low(current_charset_index)
	ldi XH, high(current_charset_index)

	add XL,r1
	adc XH,r0

	st X,r21

;function epilog
end:
clr ZH
clr ZL
pop YH
pop YL
pop r1
pop r16
pop r21
reti


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
; if high bytes are different, look at lower bytes
cp r17, r19
breq compare_words_lower_byte

; since high bytes are different, use these to
; determine result
;
; if C is set from previous cp, it means r17 < r19
;
; preload r25 with 1 with the assume r17 > r19
ldi r25, 1
brcs compare_words_is_less_than
rjmp compare_words_exit

compare_words_is_less_than:
ldi r25, -1
rjmp compare_words_exit

compare_words_lower_byte:
clr r25
cp r16, r18
breq compare_words_exit

ldi r25, 1
brcs compare_words_is_less_than ; re-use what we already wrote...

compare_words_exit:
ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1 ; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1 ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16 ; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16 ; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1 ; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
