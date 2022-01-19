# AVR
ARCH    = atmega103

PRG     = cdetect

CC      = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

COMMON  = -mmcu=$(ARCH)
CFLAGS  += $(COMMON) -g -Wall -Wimplicit -pedantic -fverbose-asm -fno-common -Wstrict-prototypes -finline-limit=800 -std=gnu99 -Os -DF_CPU=32000000UL
LDFLAGS += $(COMMON) -L/usr/local/avr/avr/lib -Wl,-Map=$(PRG).map

OBJECTS += $(patsubst %.c,%.o,$(shell echo *.c))

all:	$(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(PRG).elf
	$(OBJDUMP) -d $(PRG).elf > $(PRG).lss
	$(OBJCOPY) -j .data -j.text -O ihex   $(PRG).elf $(PRG).hex
	$(OBJCOPY) -j .data -j.text -O binary $(PRG).elf $(PRG).bin
	ls -l $(PRG).bin

clean:
	rm -f *.o *.elf *.bin *.hex *.eep *.lss *.map
