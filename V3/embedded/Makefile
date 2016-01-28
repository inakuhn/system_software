### .........  MAKEFILE AUFGABE 2 .........................####
##   HTWG Konstanz-SYSO WS 15/16 ##
##   sigoetti/rabertol ##

#Programm um C zu compilieren#
CC =  /group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-gcc -static
#Flags für den C-Compiler: Zeige alle Warnungen, als wären sie Fehler, platziere Debug- Informationen in die ausführbare Datei.#
CFLAGS = -Wall -Wpedantic -Werror -g -std=c99
#Flags für den Compiler, damit er den Linker mit einbindet#
LDFLAGS = -lm
#Kommando für das Entfernen einer Datei#
RM = rm -f

# Variablen definieren#
TARGET = helloInit
OBJECTS = helloInit.o 
SOURCES = $(TARGET).c $(OBJECTS:.o=.c)
HEADERS = $(OBJECTS:.o=.h) 

# Clean up egal obs die entsprechende Datei gib oder nicht...#

.PHONY: all clean


all: $(TARGET)
clean:
	$(RM) $(TARGET) $(TARGET).o $(OBJECTS) depend
	
#Abhaengigkeiten#
	
depend: $(SOURCES) $(HEADERS)
	$(CC) -MM $(SOURCES) > $@

$(TARGET): $(TARGET).o $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ 
	
#Beziehe alle Header-Dateien mit ein, von denen dieses Programm abhängig ist:#

#include depend
