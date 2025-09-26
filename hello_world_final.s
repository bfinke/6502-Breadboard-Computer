; Registers on the 6502
; A - accumulator register (lda)
; X - index register x (ldx)
; Y - index register y (ldy)
; SP - stack pointer (indirect access with TSX/TXS)
; PC - program counter (indirect access with JMP/JSR/rts
; P - process status register (indirect access holds flags) (bne and beq check the flags stored in this register)

; "#" in the load functions means you are loading a literal value into the registers and not from memory

; these are memory addresses
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

    .org $8000 ; setting the start location for where to write the program in the ROM

reset:
    ; Initialize stack pointer
    ldx #$ff        ; Load x with $ff
    txs             ; Transfer x to stack

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

    ldx #0 ; set x to 0

print:
    lda message,x ; use the address of message and add what's in the x register
    beq loop ; checks if zero flag is set in which case the branch is taken (loop) (end of message)
    jsr print_char ; jump to subroutine print char to screen
    inx ; increment x
    jmp print

loop:
    jmp loop

message:    .asciiz "     Hello                                             World!" ; string in memory also adds a null (0) at the end ; each line on the screen is 16 characters, but each line internally is 40 character, so 80 characters total

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

    .org $fffc
    .word reset
    .word $0000