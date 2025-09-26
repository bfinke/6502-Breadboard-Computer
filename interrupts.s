; Registers on the 6502
; A - accumulator register (lda)
; X - index register x (ldx)
; Y - index register y (ldy)
; SP - stack pointer (indirect access with TSX/TXS)
; PC - program counter (indirect access with JMP/JSR/rts
; P - process status register (indirect access holds flags) (bne and beq check the flags stored in this register)

; "#" in the load functions means you are loading a literal value into the registers and not from memory

; RAM addresses are from $0000 to $3fff

; these are memory addresses
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c ; peripheral control register
IFR = $600d ; interrupt flag register
IER = $600e ; interrupt enable register

value = $0200 ; (2 bytes/16 bits) address where we are storing the value (the right half of the number is $0200 and the left half is $0201)
mod10 = $0202 ; (2 bytes/16 bits) address of the left half of the algorithm
message = $0204 ; 6 bytes long (5 characters and a null terminating char)
counter = $020a ; 2 bytes

E  = %10000000
RW = %01000000
RS = %00100000

    .org $8000 ; setting the start location for where to write the program in the ROM

reset:
    ; Initialize stack pointer
    ldx #$ff        ; Load x with $ff
    txs             ; Transfer x to stack
    cli ; clear interrupt disable bit ; by default, IRQ is disabled so we need to enable it

    lda #$82 ; intialize interrupt enable register ; set bit and CA1
    sta IER
    lda #$00 ; initialize peripheral control register to be negative edge triggered (controls the interrupts)
    sta PCR

    lda #%11111111  ; Set all pins on port B to output
    sta DDRB

    lda #%11100000 ; Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000      ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00001110      ; Display on; cursor on; blink off
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00000110      ; Increment and shift cursor; don't shift display
    jsr lcd_instruction ; jump to subroutine LCD instruction
    lda #%00000001      ; clear display
    jsr lcd_instruction

    lda #0 ; initialize counter to 0
    sta counter
    sta counter + 1

loop: ; really just using this to hault the computer at the end (its currently just continually printing out the value of counter)
    lda #%00000010      ; put cursor back at start (Home)
    jsr lcd_instruction
    
    ; Initialize as an empty string (basically setting the null terminating char)
    lda #0
    sta message

    ; UNDERSTAND FOR BELOW (16 zeros | 2 byte/16 bit number)
    ; Initialize value of number we are trying to convert
    sei ; set interrupt disable ; basically will prevent interrupts from happening until this time sensitive code runs first; this only disables interrupts for the irq and not nmi
    lda counter
    sta value ; REMEMBER this is part of the RAM address lines
    lda counter + 1 ; this is because it is a 2 byte number so we have to load the second half
    sta value + 1
    cli ; reenable interrupts

divide:
    ; Initialize the remainder to be zero
    lda #%0 ; initialize the left half of the algorithm as 0. Since we have a 16 bit number, we can shift the bits up to 16 times to the left when doing the division algorithm
    sta mod10 ; left half of data
    sta mod10 + 1 ; right half of data
    clc ; clear carry bit, just to make sure we don't get strange results

    ldx #16 ; max amount of time you can loop before moving the next part

divloop:
    ; Rotate quotient and remainder
    rol value ; rotate value to the left (just shifting to the left)
    rol value + 1 ; adding that carry bit each time
    rol mod10
    rol mod10 + 1

    ; a and y registers = dividend - divisor
    sec ; set carry bit
    lda mod10 ; load right half of mod10 part
    sbc #10 ; subtract with carry
    tay ; transfer from a to y register ; save low byte in Y (right half)
    lda mod10 + 1 ; load in left half 
    sbc #0 ; subtract 0 since their is implicitly zeros on the other half
    bcc ignore_result; branch on carry clear ; branch if dividend < divisor (after doing the subtraction, we would've gotten a negative number from having to borrow more than once on the carry bit)
    sty mod10 ; move the result of the right half of subraction to be the new contents of the mod10 (dividend)
    sta mod10 + 1 ; same thing but left side of result now is the new dividend

ignore_result:
    dex ; decrement x (indicates we have done a loop) regardless of whether the subtract failed or worked, we will still move down this routine since we will get to it from the failed result (branch on carry clear) or once we hit the end of the divloop routine)
    bne divloop; branches if zero flag isn't set (haven't hit the end of the loop)
    rol value ; shift in the last bit of the quotient
    rol value + 1

    lda mod10 ; this is the remainder in the lower half (right side)
    clc ; clear the carry for safety
    adc #"0" ; add with carry ; add ascii "0" to convert to ascii digit
    jsr push_char

    ; if value != 0, then continue dividing
    lda value
    ora value + 1 ; simplified approach to checking if any bit are a 1 in which case we don't have 0 as a final result
    bne divide; branch if value isn't equal to 0

    ldx #0 ; set x to 0
print:
    lda message,x ; use the address of message and add what's in the x register
    beq loop ; checks if zero flag is set in which case the branch is taken (loop) (end of message)
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jmp print

number: .word 1729 ; this will converted to binary on the ROM when compiled ironically :)

; Add the char from the a register to the beginning of the null-terminated string
push_char:
    pha ; push the new first char on to the stack
    ldy #0 ; index into the message

char_loop:
    lda message,y ; load message at y index ; get char on string and put into x
    tax ; transfer a to x
    pla ; pull new char
    sta message,y ; store new char front of string
    iny
    txa ; transfer back the char at the old position
    pha ; push it to the stack
    bne char_loop ; if a is zero, hit the end of string (null-terminated)

    pla ; pull off remainding null-terminator part
    sta message,y ; add to end of string

    rts


lcd_wait:
    pha ; prevent overwriting the value stored the in the a register when lcd_instruction calls lcd_wait by pushing it to the stack
    lda #%00000000 ; set data direction of B to input
    sta DDRB
    ; since assembly executes sequentially, the next line run is lda #RW which is below ; if there was a rts command, then it would otherwise go back to the original location in the program from where the jsr was called, but instead, its just following the order of memory and pulling the next location in the ROM
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
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set E bit to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    rts ; return from subroutine

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS         ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)   ; Set E bit to send instruction
    sta PORTA
    lda #RS         ; Clear E bits
    sta PORTA
    rts ; return from subroutine

nmi:
irq:
    ; stupid software delay to prevent overwriting data (JUST MAKE A DEBOUNCE CIRCUIT!!!!)
    pha
    txa
    pha
    tya
    pha
    
    inc counter
    bne exit_irq; counter doesn't rollover
    inc counter + 1

exit_irq:
    ; create a delay in software instead of deal with debounce circuit :(
    ldx #$ff
    ldy #$ff
    
delay: ; create a delay in software instead of deal with debounce circuit :(
    dex
    bne delay
    dey
    bne delay

    bit PORTA ; bit comparison ; it will overwrite some of the processor flag, but it will be reading port A which will clear the interrupt
    
    ; stupid software delay from earlier
    pla
    tay
    pla
    tax
    pla

    rti ; return from interrupt

    .org $fffa 
    .word nmi ; interrupt but triggered when pin is pulled from high to low (egde-triggered); can't be disabled
    .word reset ; goes to reset routine when reset is pulled low
    .word irq ; interrupt but continually is interrupted while pin is low; can be turned on and off for timing depend actions