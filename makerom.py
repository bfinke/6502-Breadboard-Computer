# Please see this video for details:
# https://www.youtube.com/watch?v=yl8vPW5hydQ

rom = bytearray([0xea] * 2 ** 15)

rom[0] = 0xa9
rom[1] = 0x42

rom[2] = 0x8d
rom[3] = 0x00
rom[4] = 0x60

rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom.bin", "wb") as out_file:
    out_file.write(rom)
