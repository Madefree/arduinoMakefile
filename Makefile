# Arduino makefile
#
# Modified by Daniele Sdei <danielesdei@gmail.com> to
# work on linux command line and sort out dependencies,
# for more information visit http://wiki.madefree.eu
#
# This makefile allows you to build sketches from the command line
# without the Arduino environment (or Java).
#
#
# Detailed instructions for using the makefile:
#
#  1. Copy this file into the folder with your sketch. There should be a
#     file with the same name as the folder and with the extension .pde
#     (e.g. foo.pde in the foo/ folder).
#
#  2. Below, modify the line containing "TARGET" to refer to the name of
#     of your program's file without an extension (e.g. TARGET = foo).
#
#  3. Modify the line containg "ARDUINO" to point the directory that
#     contains the Arduino core.
#
#  4. Modify the line containing "PORT" to refer to the filename
#     representing the USB or serial connection to your Arduino board
#     (e.g. PORT = /dev/tty.USB0).  If the exact name of this file
#     changes, you can use * as a wildcard (e.g. PORT = /dev/tty.USB*).
#
#  5. At the command line, change to the directory containing your
#     program's file and the makefile.
#
#  6. Type "make" and press enter to compile/verify your program.
#
#  7. Type "make upload", reset your Arduino board, and press enter  to
#     upload your program to the Arduino board.

PORT = /dev/ttyUSB0
TARGET := $(shell pwd | sed 's|.*/\(.*\)|\1|')
ARDUINO = /usr/share/arduino
ARDUINO_SRC = $(ARDUINO)/hardware/arduino/cores/arduino
ARDUINO_LIB_SRC = $(ARDUINO)/libraries
AVR_TOOLS_PATH = /usr/bin
AVRDUDE_PATH = /usr/bin
INCLUDE = -I$(ARDUINO_SRC) \
	-I$(ARDUINO_LIB_SRC)/EEPROM \
	-I$(ARDUINO_LIB_SRC)/Firmata \
	-I$(ARDUINO_LIB_SRC)/LiquidCrystal \
	-I$(ARDUINO_LIB_SRC)/Matrix \
	-I$(ARDUINO_LIB_SRC)/Servo \
	-I$(ARDUINO_LIB_SRC)/SoftwareSerial \
	-I$(ARDUINO_LIB_SRC)/SPI \
	-I$(ARDUINO_LIB_SRC)/Sprite \
	-I$(ARDUINO_LIB_SRC)/Stepper \
	-I$(ARDUINO_LIB_SRC)/Wire \
	-I$(ARDUINO_LIB_SRC)/Wire/utility \
	-I$(ARDUINO_LIB_SRC)
SRC = $(wildcard $(ARDUINO_SRC)/*.c) \
      $(wildcard $(ARDUINO_LIB_SRC)/Wire/utility/twi.c)
CXXSRC = applet/$(TARGET).cpp $(ARDUINO_SRC)/HardwareSerial.cpp \
	$(ARDUINO_LIB_SRC)/EEPROM/EEPROM.cpp \
	$(ARDUINO_LIB_SRC)/Firmata/Firmata.cpp \
	$(ARDUINO_LIB_SRC)/LiquidCrystal/LiquidCrystal.cpp \
	$(ARDUINO_LIB_SRC)/Matrix/Matrix.cpp \
	$(ARDUINO_LIB_SRC)/Servo/Servo.cpp \
	$(ARDUINO_LIB_SRC)/SoftwareSerial/SoftwareSerial.cpp \
	$(ARDUINO_LIB_SRC)/SPI/SPI.cpp \
	$(ARDUINO_LIB_SRC)/Sprite/Sprite.cpp \
	$(ARDUINO_LIB_SRC)/Stepper/Stepper.cpp \
	$(ARDUINO_LIB_SRC)/Wire/Wire.cpp \
	$(ARDUINO_SRC)/Print.cpp \
	$(ARDUINO_SRC)/Tone.cpp \
	$(ARDUINO_SRC)/WMath.cpp \
	$(ARDUINO_SRC)/WString.cpp
HEADERS = $(wildcard $(ARDUINO_SRC)/*.h) \
	  $(wildcard $(ARDUINO_LIB_SRC)/*/*.h) \
	  $(wildcard $(ARDUINO_LIB_SRC)/Wire/utility/twi.h)

MCU = atmega328p
F_CPU = 16000000
FORMAT = ihex
UPLOAD_RATE = 115200

# Name of this Makefile (used for "make depend").
MAKEFILE = Makefile

# Debugging format.
# Native formats for AVR-GCC's -g are stabs [default], or dwarf-2.
# AVR (extended) COFF requires stabs, plus an avr-objcopy run.
DEBUG = stabs

OPT = s

# Place -D or -U options here
CDEFS = -ffunction-sections -fdata-sections -DF_CPU=$(F_CPU)
CXXDEFS = -ffunction-sections -fdata-sections -DF_CPU=$(F_CPU)

# Compiler flag to set the C Standard level.
# c89   - "ANSI" C
# gnu89 - c89 plus GCC extensions
# c99   - ISO C99 standard (not yet fully implemented)
# gnu99 - c99 plus GCC extensions
CSTANDARD = -std=gnu99
CDEBUG = -g$(DEBUG)
CWARN = -Wall -Wstrict-prototypes
CTUNING = -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
#CEXTRA = -Wa,-adhlns=$(<:.c=.lst)

CFLAGS = $(CDEBUG) $(CDEFS) $(INCLUDE) -O$(OPT) $(CWARN) $(CSTANDARD) $(CEXTRA)
CXXFLAGS = $(CXXDEFS) $(INCLUDE) -O$(OPT)
#ASFLAGS = -Wa,-adhlns=$(<:.S=.lst),-gstabs 
LDFLAGS = 


# Programming support using avrdude. Settings and variables.
AVRDUDE_PROGRAMMER = stk500v1
AVRDUDE_PORT = $(PORT)
AVRDUDE_WRITE_FLASH = -U flash:w:applet/$(TARGET).hex
AVRDUDE_FLAGS = -F -C /etc/avrdude.conf -p $(MCU) -P $(AVRDUDE_PORT) \
  -c $(AVRDUDE_PROGRAMMER) -b $(UPLOAD_RATE)

# Program settings
CC = $(AVR_TOOLS_PATH)/avr-gcc 
CXX = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP = $(AVR_TOOLS_PATH)/avr-objdump
SIZE = $(AVR_TOOLS_PATH)/avr-size
NM = $(AVR_TOOLS_PATH)/avr-nm
AVRDUDE = $(AVRDUDE_PATH)/avrdude
REMOVE = rm -f
MV = mv -f

# Define all object files.
OBJ = $(SRC:.c=.o) $(CXXSRC:.cpp=.o) $(ASRC:.S=.o)

# Define all listing files.
LST = $(ASRC:.S=.lst) $(CXXSRC:.cpp=.lst) $(SRC:.c=.lst)

# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_CFLAGS = -mmcu=$(MCU) -I. $(CFLAGS)
ALL_CXXFLAGS = -mmcu=$(MCU) -I. $(CXXFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp $(ASFLAGS)


# Default target.
all: build

build: applet/$(TARGET).hex

eep: applet/$(TARGET).eep
lss: applet/$(TARGET).lss 
sym: applet/$(TARGET).sym


# Convert ELF to COFF for use in debugging / simulating in AVR Studio or VMLAB.
COFFCONVERT=$(OBJCOPY) --debugging \
--change-section-address .data-0x800000 \
--change-section-address .bss-0x800000 \
--change-section-address .noinit-0x800000 \
--change-section-address .eeprom-0x810000 


coff: applet/$(TARGET).elf
	$(COFFCONVERT) -O coff-avr applet/$(TARGET).elf applet/$(TARGET).cof


extcoff: applet/$(TARGET).elf
	$(COFFCONVERT) -O coff-ext-avr applet/$(TARGET).elf applet/$(TARGET).cof


.SUFFIXES: .elf .hex .eep .lss .sym .pde

.elf.hex:
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

.elf.eep:
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
.elf.lss:
	$(OBJDUMP) -h -S $< > $@

# Create a symbol table from ELF output file.
.elf.sym:
	$(NM) -n $< > $@


# Compile: create object files from C++ source files.
.cpp.o: $(HEADERS)
	$(CXX) -c $(ALL_CXXFLAGS) $< -o $@ 

# Compile: create object files from C source files.
.c.o: $(HEADERS)
	$(CC)  -c $(ALL_CFLAGS) $< -o $@ 


# Compile: create assembler files from C source files.
.c.s:
	$(CC) -S $(ALL_CFLAGS) $< -o $@


# Assemble: create object files from assembler source files.
.S.o:
	$(CC) -c $(ALL_ASFLAGS) $< -o $@



applet/$(TARGET).cpp: $(TARGET).pde
	test -d applet || mkdir applet
	echo '#include "WProgram.h"' > applet/$(TARGET).cpp
	echo '#include "avr/interrupt.h"' >> applet/$(TARGET).cpp
#	sed -n 's|^\(void .*)\).*|\1;|p' $(TARGET).pde | grep -v 'setup()' | \
#		grep -v 'loop()' >> applet/$(TARGET).cpp
	cat $(TARGET).pde >> applet/$(TARGET).cpp
	cat $(ARDUINO_SRC)/main.cpp >> applet/$(TARGET).cpp

# Link: create ELF output file from object files.
applet/$(TARGET).elf: applet/$(TARGET).cpp $(OBJ)
	$(CC) -Wl,--gc-sections $(ALL_CFLAGS) $(OBJ) --output $@ $(LDFLAGS)

pd_close_serial:
	echo 'close;' | /Applications/Pd-extended.app/Contents/Resources/bin/pdsend 34567 || true

# Program the device.  
upload: applet/$(TARGET).hex
	$(AVRDUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_WRITE_FLASH)


pd_test: build pd_close_serial upload

# Target: clean project.
clean:
	$(REMOVE) -- applet/$(TARGET).hex applet/$(TARGET).eep \
	applet/$(TARGET).cof applet/$(TARGET).elf $(TARGET).map \
	applet/$(TARGET).sym applet/$(TARGET).lss applet/$(TARGET).cpp \
	$(OBJ) $(LST) $(SRC:.c=.s) $(SRC:.c=.d) $(CXXSRC:.cpp=.s) $(CXXSRC:.cpp=.d)
	rmdir -- applet

depend:
	if grep '^# DO NOT DELETE' $(MAKEFILE) >/dev/null; \
	then \
		sed -e '/^# DO NOT DELETE/,$$d' $(MAKEFILE) > \
			$(MAKEFILE).$$$$ && \
		$(MV) $(MAKEFILE).$$$$ $(MAKEFILE); \
	fi
	echo '# DO NOT DELETE THIS LINE -- make depend depends on it.' \
		>> $(MAKEFILE); \
	$(CC) -M -mmcu=$(MCU) $(CDEFS) $(INCLUDE) $(SRC) $(ASRC) >> $(MAKEFILE)

.PHONY:	all build eep lss sym coff extcoff clean depend pd_close_serial pd_test
