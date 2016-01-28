### .........  MAKEFILE TREIBER AUFGABE 4 .........................####
##   HTWG Konstanz-SYSO WS 15/16 ##
##   sigoetti/rabertol ##
#Programm um C zu compilieren#

CROSS_COMPILE=/group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-
ARCH=arm
FILE= template


ifneq ($(KERNELRELEASE),)
obj-m   := template.o

else
KDIR    := ../../../V3/embedded/buildroot/output/build/linux-4.2.3/
PWD     := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
endif

clean:
	rm -rf *.symvers *.order *.mod.c *.o .$(FILE).ko.cmd .$(FILE).mod.o.cmd .$(FILE).o.cmd .tmp_versions
