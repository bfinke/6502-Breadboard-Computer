PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004
T1CH = $6005
ACR = $600B
IFR = $600D
IER = $600E



ticks = $0000
toggle_time = $0004

    .org $8000

reset:
    lda #%11111111 ; Set all pins on port A to output
    sta DDRA
    lda #0
    sta PORTA
    sta toggle_time
    jsr init_timer

loop:
    jsr update_led
    jmp loop

update_led:
    sec ; set carry bit ; we are doing subtraction betweens ticks and toggle_time to determine if we need to toggle the LED
    lda ticks
    sbc toggle_time
    cmp #25 ; this is checking to see if we have gone 250 ms, but if we needed more than 2560 ms, we need to start checking higher up in the ticks addresses
    bcc exit_update_led ; checks to see if carry bit flag was not set, indicating number being subtracted from is smaller than the number being subtracted
    lda #$01
    eor PORTA ; toggles LED
    sta PORTA
    lda ticks
    sta toggle_time ; this will keep doing toggle_time + 25 each time, so be careful, otherwise just reset it if you need to
    
exit_update_led:
    rts

init_timer:
    lda #0
    sta ticks
    sta ticks + 1
    sta ticks + 2
    sta ticks + 3
    ; 10 ms delay $270E based on 9998 clk cycles and a 1 MHz clock ; since there are N+2 cycles extra for the interrupt, that is why it's 9998 and not 10000
    lda #%01000000 ; timer in free run mode
    sta ACR
    lda #$0e
    sta T1CL
    lda #$27
    sta T1CH

    ; use this method to check if you want to have an interrupt request sent when the timer expires, otherwise use the delay1 below
    lda #%11000000
    sta IER
    cli ; enable interrupts on processor
    rts

; delay1:
;     bit IFR ; alternative function is it copies the bit 7 and bit 6 from the register into the negative and overflow flag of the processor, so since bit 6 in the IFR is for Timer 1, doing a bit test works also since it will copy the Timer 1 flag into the overflow flag of the CPU
;     bvc delay1; branch if overflow clear; if overflow flag isn't set by timer yet, stay in delay1
;     lda T1CL ; resets timer
;     rts

irq:
    bit T1CL ; technically reads the timer to clear it; personal note, seems like a bad idea to use this method since it would write strange values to the flags register on the CPU (I could wrong about this); but the flags registers resets at the end of the interrupt anyways so who knows????
    
    ;count interrupts
    inc ticks
    bne end_irq ; check if ticks rolled over ; branch if it doesn't equal 0
    inc ticks + 1
    bne end_irq
    inc ticks + 2
    bne end_irq
    inc ticks + 3

end_irq:
    rti


    .org $fffc
    .word reset
    .word irq