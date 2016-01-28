### .........  MAKEFILE TREIBER AUFGABE 4 .........................####
##   HTWG Konstanz-SYSO WS 15/16 ##
##   sigoetti/rabertol ##
#Programm um C zu compilieren#

CROSS_COMPILE=/group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-
ARCH=arm

ifneq ($(KERNELRELEASE),)
obj-m   := openclose.o

else
KDIR    := ../../buildroot/output/build/linux-4.2.3/
PWD     := $(shell pwd)

default:
		$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
endif


clean:
	rm *.symvers *.order *.ko *.mod.c *.mod.o *.o .openclose.ko.cmd .openclose.mod.o.cmd .openclose.o.cmd
