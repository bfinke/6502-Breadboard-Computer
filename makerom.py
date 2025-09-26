# Please see this video for details:
# https://www.youtube.com/watch?v=yl8vPW5hydQ

code = bytearray([0xa9, 0xff,           # lda #$ff (load register a) **setting to output)
                  0x8d, 0x02, 0x60,     # sta $6002 (store register a at adr 6002)
                  
                  0xa9, 0x55,           # lda #$55 (load register a)
                  0x8d, 0x00, 0x60,     # sta $6000 (store register a at adr 6000)
                  
                  0xa9, 0xaa,           # lda #$aa (load register a)
                  0x8d, 0x00, 0x60,     # sta $6000 (store register a at adr 6000)
                  
                  0x4c, 0x05, 0x80      # jump $8005 (the 8005 comes from the fact that each of the hex value listed are stored from 8000, 8001, ... so sending it to 8005 puts it at 0x09 which is a load command 0xa9)
                  ])    
rom = code + bytearray([0xea] * (2 ** 15 - len(code)))

rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom.bin", "wb") as out_file:
    out_file.write(rom)
