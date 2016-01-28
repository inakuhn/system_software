### .........  MAKEFILE TREIBER AUFGABE 4 .........................####
##   HTWG Konstanz-SYSO WS 15/16 ##
##   sigoetti/rabertol ##
#Programm um C zu compilieren#

CROSS_COMPILE=/group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-
ARCH=arm
DIRECTORYS = openclose template mynull myzero


ifneq ($(KERNELRELEASE),)
obj-m   := template.o

else
KDIR    := ../../../V3/embedded/buildroot/output/build/linux-4.2.3/
PWD     := $(shell pwd)

default:
	for dic in $(DIRECTORYS) ; do cd $$dic && ls && make && make clean && cd .. ; done	
endif

clean:
	rm *.symvers *.order *.ko *.mod.c *.mod.o *.o .template.ko.cmd .template.mod.o.cmd .template.o.cmd
