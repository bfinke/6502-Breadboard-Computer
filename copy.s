; ----------------------------------------------------------------------------------- 
; Program: Comedy Movie Quotes
; About: Will select a random movie quote based on the random output from an Arduino.
;        Quotes are some of my favorites from a few of my favorite comedy movies.
;        Happy Gilmore, Naked Gun, Airplane!, Spaceballs
; -----------------------------------------------------------------------------------

; Versatile interface controller registers
PORTB = $6000 ; data port B
PORTA = $6001 ; data port A
DDRB = $6002 ; data direction register B
DDRA = $6003 ; data direction register A
T1CL = $6004 ; low order timer1 counter
T1CH = $6005 ; high order timer1 counter
ACR = $600B ; auxiliary control register
PCR = $600C ; peripheral control register
IFR = $600D ; interrupt flag register
IER = $600E ; interrupt enable register

counter = $0000 ; counts up to random value of the random quote
idle = $0001 ; program hault flag
timer_counts = $0002 ; count each time 10 ms passes
message_interrupted = $0003 ; interrupt in the middle of a message flag
line_counter = $0004 ; counts number of lines printed on the screen
extra_lines = $0005 ; quote > 15 lines flag

; Display bits
E  = %10000000 ; enable read/write
RW = %01000000 ; read/write
RS = %00100000 ; register select

    .org $8000

reset:
    ; Initialize stack pointer
    ldx #$ff
    txs             
    cli ; enables interrupts on processor

    ; Initialize versatile interface controller
    lda #$82 ; intialize interrupt enable register ; set bit and CA1
    sta IER
    lda #$00 ; initialize peripheral control register to be negative edge triggered (controls the interrupts)
    sta PCR
    lda #%11111111 ; set all pins on port B to output
    sta DDRB
    lda #%11100000 ; set pins 5-7 to output and 0-4 to input
    sta DDRA

    ; Initialize screen
    lda #%00111000 ; set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00001110 ; display on; cursor on; blink off
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00000110 ; increment and shift cursor; don't shift display
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00000001 ; clear display
    jsr lcd_instruction

    ; Initialize variables
    lda #$00
    sta counter
    sta timer_counts
    sta message_interrupted
    sta line_counter
    sta extra_lines

    lda #$01 ; set program to start in idle (not doing anything)
    sta idle

    ; Initalize timer
    lda #%00000000 ; timer in one-shot mode
    sta ACR

loop: ; really just using this to hault the computer at the end
    ldx #0 ; reset pointer position in quote
    lda idle
    cmp #$01 ; check idle flag
    bne get_m0 ; will stay in loop if idle flag is set
    jmp loop

get_m0:
    lda counter
    cmp #0 ; check if quote is #0
    beq print0
    jmp get_m1

print0:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print0
    lda m0,x ; grab each char from the quote
    beq end_of_line0 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print0
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char0
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print0

end_of_line0:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print0

skip_char0:
    inx
    lda blank
    jsr print_char
    jmp print0

end_print0:
    jmp end_print

get_m1:
    cmp #1 ; check if quote is #1
    beq print1
    jmp get_m2

print1:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print1
    lda m1,x ; grab each char from the quote
    beq end_of_line1 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print1
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char1
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print1

end_of_line1:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print1

skip_char1:
    inx
    lda blank
    jsr print_char
    jmp print1

end_print1:
    jmp end_print
    
get_m2:
    cmp #2 ; check if quote is #2
    beq print2
    jmp get_m3

print2:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print2
    lda m2,x ; grab each char from the quote
    beq end_of_line2 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print2
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char2
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print2

end_of_line2:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print2

skip_char2:
    inx
    lda blank
    jsr print_char
    jmp print2

end_print2:
    jmp end_print
    
get_m3:
    cmp #3 ; check if quote is #3
    beq print3
    jmp get_m4

print3:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print3
    lda m3,x ; grab each char from the quote
    beq end_of_line3 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print3
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char3
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print3

end_of_line3:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print3

skip_char3:
    inx
    lda blank
    jsr print_char
    jmp print3

end_print3:
    jmp end_print

get_m4:
    cmp #4 ; check if quote is #4
    beq print4
    jmp get_m5

print4:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print4
    lda m4,x ; grab each char from the quote
    beq end_of_line4 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print4
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char4
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print4

end_of_line4:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print4

skip_char4:
    inx
    lda blank
    jsr print_char
    jmp print4

end_print4:
    jmp end_print
    
get_m5:
    cmp #5 ; check if quote is #5
    beq print5
    jmp get_m6
    
print5:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print5
    lda m5,x ; grab each char from the quote
    beq end_of_line5 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print5
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char5
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print5

end_of_line5:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print5

skip_char5:
    inx
    lda blank
    jsr print_char
    jmp print5

end_print5:
    jmp end_print

get_m6:
    cmp #6 ; check if quote is #6
    beq print6
    jmp get_m7

print6:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print6
    lda m6,x ; grab each char from the quote
    beq end_of_line6 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print6
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char6
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print6

end_of_line6:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print6

skip_char6:
    inx
    lda blank
    jsr print_char
    jmp print6

end_print6:
    jmp end_print

get_m7:
    cmp #7 ; check if quote is #7
    beq print7
    jmp get_m8

print7:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print7
    lda m7,x ; grab each char from the quote
    beq end_of_line7 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print7
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char7
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print7

end_of_line7:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print7

skip_char7:
    inx
    lda blank
    jsr print_char
    jmp print7

end_print7:
    jmp end_print
    
get_m8:
    cmp #8 ; check if quote is #8
    beq print8
    jmp get_m9

print8:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print8
    lda m8,x ; grab each char from the quote
    beq end_of_line8 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print8
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char8
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print8

end_of_line8:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print8

skip_char8:
    inx
    lda blank
    jsr print_char
    jmp print8

end_print8:
    jmp end_print
    
get_m9:
    cmp #9 ; check if quote is #9
    beq print9
    jmp get_m10

print9:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print9
    lda extra_lines
    cmp #1 ; check if CPU needs to load in second half of message
    beq print9_1
    lda m9,x ; grab each char from the first half of quote
    jmp print9_2

print9_1:
    lda m9_15,x ; grab each char from the second half of quote
    
print9_2:
    beq end_of_line9 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message (first and second half)
    beq end_print9_part1 ; check if we read 16 lines and have more or end print
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char9
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print9

end_print9_part1:
    lda #0
    sta line_counter ; fixes strange line counting error that I can't figure out
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    ldx #0
    inc extra_lines ; set extra lines flag (tells CPU to load in second half of quote)
    lda extra_lines
    cmp #1
    beq print9_1
    jmp end_print9


end_of_line9:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print9

skip_char9:
    inx
    lda blank
    jsr print_char
    jmp print9

end_print9:
    jmp end_print
    
get_m10:
    cmp #10 ; check if quote is #10
    beq print10
    jmp get_m11

print10:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print10
    lda m10,x ; grab each char from the quote
    beq end_of_line10 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print10
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char10
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print10

end_of_line10:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print10

skip_char10:
    inx
    lda blank
    jsr print_char
    jmp print10

end_print10:
    jmp end_print
    
get_m11:
    cmp #11 ; check if quote is #11
    beq print11
    jmp get_m12

print11:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print11
    lda m11,x ; grab each char from the quote
    beq end_of_line11 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print11
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char11
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print11

end_of_line11:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print11

skip_char11:
    inx
    lda blank
    jsr print_char
    jmp print11

end_print11:
    jmp end_print
    
get_m12:
    cmp #12 ; check if quote is #12
    beq print12
    jmp get_m13

print12:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print12
    lda m12,x ; grab each char from the quote
    beq end_of_line12 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print12
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char12
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print12

end_of_line12:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print12

skip_char12:
    inx
    lda blank
    jsr print_char
    jmp print12

end_print12:
    jmp end_print

get_m13:
    cmp #13 ; check if quote is #13
    beq print13
    jmp get_m14

print13:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print13
    lda m13,x ; grab each char from the quote
    beq end_of_line13 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print13
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char13
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print13

end_of_line13:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print13

skip_char13:
    inx
    lda blank
    jsr print_char
    jmp print13

end_print13:
    jmp end_print

get_m14:
    cmp #14 ; check if quote is #14
    beq print14
    jmp get_m15

print14:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print14
    lda m14,x ; grab each char from the quote
    beq end_of_line14 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print14
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char14
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print14

end_of_line14:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print14

skip_char14:
    inx
    lda blank
    jsr print_char
    jmp print14

end_print14:
    jmp end_print
    
get_m15:
    jmp print15

print15:
    lda message_interrupted
    cmp #1 ; check if message was interrupted
    beq end_print15
    lda m15,x ; grab each char from the quote
    beq end_of_line15 ; checks for null terminating char (end of line)
    cmp message_terminator ; checks end of message
    beq end_print15
    cmp message_ignore ; check for ignore char in message (basically if text can't fill up entire line, move to the next line faster)
    beq skip_char15
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jsr delay
    jmp print15

end_of_line15:
    inx ; move to char on next line
    ldy #0 ; initialize blanks counter
    jsr print_blanks
    jmp print15

skip_char15:
    inx
    lda blank
    jsr print_char
    jmp print15

end_print15:
    jmp end_print

m0:     .asciiz "My fingers hurt."
m0_1:   .asciiz "Oh, well, now~~~"
m0_2:   .asciiz "your back's~~~~~" 
m0_3:   .asciiz "gonna hurt,~~~~~" 
m0_4:   .asciiz "'cause you just~" 
m0_5:   .asciiz "pulled landscap-" 
m0_6:   .asciiz "-ing duty.~~~~~~" 
m0_7:   .asciiz "Anybody else's~~" 
m0_8:   .asciiz "fingers hurt?..." 
m0_9:   .asciiz "I didn't think~~" 
m0_10:  .asciiz "so._"

m1:     .asciiz "Oh, you can~~~~~"
m1_1:   .asciiz "count. Good for~"
m1_2:   .asciiz "you. And you can"
m1_3:   .asciiz "count, on me,~~~"
m1_4:   .asciiz "waiting for you~"
m1_5:   .asciiz "in the parking~~"
m1_6:   .asciiz "lot._"

m2:     .asciiz "How's that nice~"
m2_1:   .asciiz "girlfriend of~~~"
m2_2:   .asciiz "yours? Oh, she~~"
m2_3:   .asciiz "got hit by a car"
m2_4:   .asciiz "She's dead._"

m3:     .asciiz "You like that,~~"
m3_1:   .asciiz "old man? You~~~~"
m3_2:   .asciiz "want a piece of~"
m3_3:   .asciiz "me? I don't want"
m3_4:   .asciiz "a piece of you,~"
m3_5:   .asciiz "I want the whole"
m3_6:   .asciiz "thing! Now~~~~~~"
m3_7:   .asciiz "you're gonna get"
m3_8:   .asciiz "it, Bobby! The~~"
m3_9:   .asciiz "price is wrong~~"
m3_10:   .asciiz "bitch!_"

m4:     .asciiz "Would you like~~"
m4_1:   .asciiz "something to~~~~"
m4_2:   .asciiz "read? Do you~~~~"
m4_3:   .asciiz "have anything~~~"
m4_4:   .asciiz "light? How about"
m4_5:   .asciiz "this leaflet,~~~"
m4_6:   .asciiz "'Famous Jewish~~"
m4_7:   .asciiz "Sports Legends?_"

m5:     .asciiz "He's on life~~~~"
m5_1:   .asciiz "support. Doctors"
m5_2:   .asciiz "say he's got a~~"
m5_3:   .asciiz "50-50 chance of~"
m5_4:   .asciiz "living, though~~"
m5_5:   .asciiz "there's only a~~"
m5_6:   .asciiz "ten percent~~~~~"
m5_7:   .asciiz "chance of that._"

m6:     .asciiz "All right,~~~~~~"
m6_1:   .asciiz "Stephanie,~~~~~~"
m6_2:   .asciiz "gently extend~~~"
m6_3:   .asciiz "your arm. Extend"
m6_4:   .asciiz "your middle~~~~~"
m6_5:   .asciiz "finger. Very~~~~"
m6_6:   .asciiz "good! Well done._"

m7:     .asciiz "Hey! The missing"
m7_1:   .asciiz "evidence in the~"
m7_2:   .asciiz "Kelner case! My~"
m7_3:   .asciiz "God, he really~~"
m7_4:   .asciiz "was innocent! He"
m7_5:   .asciiz "went to the~~~~~"
m7_6:   .asciiz "chair two years~"
m7_7:   .asciiz "ago, Frank._"

m8:     .asciiz "I am your~~~~~~~"
m8_1:   .asciiz "father's~~~~~~~~" 
m8_2:   .asciiz "brother's~~~~~~~"
m8_3:   .asciiz "cousin's former~"
m8_4:   .asciiz "roommate. What's"
m8_5:   .asciiz "that make us?~~~"
m8_6:   .asciiz "Absolutely~~~~~~"
m8_7:   .asciiz "nothing! Which~~"
m8_8:   .asciiz "is what you are~"
m8_9:   .asciiz "about to become._"

m9:     .asciiz "Who made that~~~"
m9_1:   .asciiz "man a gunner. I~"
m9_2:   .asciiz "did sir. He's my"
m9_3:   .asciiz "cousin. Who is~~"
m9_4:   .asciiz "he? He's an~~~~~"
m9_5:   .asciiz "asshole sir. I~~"
m9_6:   .asciiz "know that!~~~~~~"
m9_7:   .asciiz "What's his name?"
m9_8:   .asciiz "That is his name"
m9_9:   .asciiz "sir. Asshole,~~~"
m9_10:  .asciiz "Major Asshole!~~"
m9_11:  .asciiz "And his cousin?~"
m9_12:  .asciiz "He's an asshole~"
m9_13:  .asciiz "too sir.~~~~~~~~"
m9_14:  .asciiz "Gunner's mate~~~_" ; end of part one
m9_15:  .asciiz "First Class~~~~~" 
m9_16:  .asciiz "Philip Asshole!~"
m9_17:  .asciiz "How many~~~~~~~~"
m9_18:  .asciiz "assholes do we~~"
m9_19:  .asciiz "have on this~~~~"
m9_20:  .asciiz "ship, anyway?~~~"
m9_21:  .asciiz "Yo! I knew it.~~"
m9_22:  .asciiz "I'm surrounded~~"
m9_23:  .asciiz "by assholes!~~~~"
m9_24:  .asciiz "Keep firing~~~~~"
m9_25:  .asciiz "assholes!_"

m10:    .asciiz "So the combinat-"
m10_1:  .asciiz "-ion is... one,~"
m10_2:  .asciiz "two, three, four"
m10_3:  .asciiz ", five? That's~~"
m10_4:  .asciiz "the stupidest~~~"
m10_5:  .asciiz "combination I've"
m10_6:  .asciiz "heard in my life"
m10_7:  .asciiz "That's the kind~"
m10_8:  .asciiz "of thing an~~~~~"
m10_9:  .asciiz "idiot would have"
m10_10: .asciiz "on his luggage!_"

m11:    .asciiz "Are we being too"
m11_1:  .asciiz "literal? No you~"
m11_2:  .asciiz "fool, we're~~~~~"
m11_3:  .asciiz "following orders"
m11_4:  .asciiz "We were told to~"
m11_5:  .asciiz "comb the desert,"
m11_6:  .asciiz "so we're combing"
m11_7:  .asciiz "it. Found~~~~~~~"
m11_8:  .asciiz "anything yet?~~~"
m11_9:  .asciiz "Nothing yet sir."
m11_10: .asciiz "How about you?~~"
m11_11: .asciiz "Not a thing sir."
m11_12: .asciiz "What about you~~"
m11_13: .asciiz "guys? We ain't~~"
m11_14: .asciiz "found shit!_"

m12:    .asciiz "You have the~~~~"
m12_1:  .asciiz "ring, and I see~"
m12_2:  .asciiz "your Schwartz is"
m12_3:  .asciiz "as big as mine.~"
m12_4:  .asciiz "Now let's see~~~"
m12_5:  .asciiz "how well you~~~~"
m12_6:  .asciiz "handle it._"

m13:    .asciiz "What shall we do"
m13_1:  .asciiz "now, Sir? Well,~"
m13_2:  .asciiz "are we stopped?~"
m13_3:  .asciiz "We're stopped,~~"
m13_4:  .asciiz "Sir. Good. Well~"
m13_5:  .asciiz "why don't we~~~~"
m13_6:  .asciiz "take a five~~~~~"
m13_7:  .asciiz "minute break?~~~"
m13_8:  .asciiz "Very good, Sir.~"
m13_9:  .asciiz "Smoke if you~~~~"
m13_10: .asciiz "got'em._"

m14:    .asciiz "What's the~~~~~~"
m14_1:  .asciiz "matter, Colonel~"
m14_2:  .asciiz "Sandurz?~~~~~~~~"
m14_3:  .asciiz "CHICKEN?_"

m15:    .asciiz "What was it we~~"
m15_1:  .asciiz "had for dinner~~"
m15_2:  .asciiz "tonight? Well,~~"
m15_3:  .asciiz "we had a choice~"
m15_4:  .asciiz "of steak or fish"
m15_5:  .asciiz "Yes, yes, I~~~~~"
m15_6:  .asciiz "remember, I had~"
m15_7:  .asciiz "lasagna._"

blank:              .asciiz " "
message_terminator: .asciiz "_"
message_ignore:     .asciiz "~"

print_blanks:
    ; Check if message was interrupted
    lda message_interrupted
    cmp #1
    beq end_print

    ; Print 24 blank (space) characters (40 (2x) character lines, 16 visable)
    lda blank
    jsr print_char
    iny
    cpy #24
    bne print_blanks

    ; Check if both lines are full on screen
    inc line_counter
    lda line_counter
    cmp #2
    beq clear_screen
    rts

clear_screen:
    jsr delay ; wait a bit before clearing the screen so you can read the message
    jsr delay
    jsr delay
    jsr delay
    lda #%00000001 ; clear display
    jsr lcd_instruction
    lda #%00000010 ; put cursor back at start (Home)
    jsr lcd_instruction
    lda #0 ; reset line counter
    sta line_counter
    rts

end_print:
    lda message_interrupted
    cmp #1
    beq message_restart ; message interrupted, don't enable idle flag
    lda #$01
    eor idle
    sta idle
    jsr clear_screen
    
message_restart:
    lda #0 ; interrupt occurred in the middle of quote, reset flag
    sta message_interrupted
    jmp loop

delay:
    ; 10 ms delay $270E based on 9998 + (N + 2 *for interrupt*) clk cycles and a 1 MHz clock
    lda #$0e
    sta T1CL
    lda #$27
    sta T1CH ; timer starts when loading this register

delay1:
    bit IFR ; copy timer overflow flag into processor
    bvc delay1 ; branch if overflow clear; if overflow flag isn't set by timer yet, stay in delay1
    lda T1CL ; resets timer
    clv ; clear overflow flag
    inc timer_counts
    lda timer_counts
    cmp #10 ; check if 100 ms have passed
    bne delay
    and #0 ; reset timer_counts
    sta timer_counts
    rts

lcd_wait:
    pha ; prevent overwriting the value stored the in the a register when lcd_instruction calls lcd_wait by pushing it to the stack
    lda #%00000000 ; set data direction of B to input
    sta DDRB

lcd_busy:
    lda #RW ; read busy flag     
    sta PORTA
    lda #(RW | E) ; toggle enable bit
    sta PORTA
    lda PORTB ; store contents of data register B
    and #%10000000 ; zero out all bits that aren't the busy flag (and operation also sets the zero flag)
    bne lcd_busy ; if a != b ; branch if not equal (checks the zero flag) ; if zero flag is 1, then it jumps back up to lcd_busy

    lda #RW ; clear enable bit
    sta PORTA
    lda #%11111111 ; set data direction of B to output
    sta DDRB
    pla
    rts

lcd_instruction:
    jsr lcd_wait ; wait until busy flag isn't set
    sta PORTB
    lda #0 ; clear RS/RW/E bits
    sta PORTA
    lda #E ; set E bit to send instruction
    sta PORTA
    lda #0 ; clear RS/RW/E bits
    sta PORTA
    rts ; return from subroutine

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS ; set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E) ; set E bit to send instruction
    sta PORTA
    lda #RS ; clear E bits
    sta PORTA
    rts ; return from subroutine

nmi: ; unused
    rts

irq:
    ; Check if message was interrupted
    lda idle ; will be 0 if interrupted
    cmp #0
    beq interrupted
        
    ; Disable end of program flag
    lda #$01
    eor idle
    sta idle
    jmp irq1
    
interrupted:
    lda #$01
    eor message_interrupted ; set message interrupt flag
    sta message_interrupted

irq1:
    ; Reset line counter, counter, extra lines
    lda #0
    sta line_counter
    sta counter
    sta extra_lines

    ; Reset screen
    lda #%00000001 ; clear display
    jsr lcd_instruction
    lda #%00000010 ; put cursor back at start (Home)
    jsr lcd_instruction

    ; Initialize value of number we are trying to convert
    lda PORTA ; read the random message number
    and #%00001111 ; isolate last 4 bits

num_finder:
    sec
    sbc #$01
    bcc found_num
    inc counter
    jmp num_finder

found_num:    
    rti

    .org $fffa 
    .word nmi ; interrupt but triggered when pin is pulled from high to low (egde-triggered); can't be disabled
    .word reset ; goes to reset routine when reset is pulled low
    .word irq ; interrupt but continually is interrupted while pin is low; can be turned on and off for timing depend actions