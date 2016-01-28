#!/bin/sh
#sigoetti&rabertol
#v3_1 shell skript kernel configuration
#Varible
#----------------------------embedded path--------------------------
SUB_DIRECTORY="embedded"
KERNELDIR="linux-4.2.3"
USERLANDDIR="userland"
USERLANDCONFIG="dev dev/pts sbin bin usr/bin etc var tmp lib etc var proc sys"
CONFIGFILE="config/.config"
ZIP_FILE="linux-4.2.3.tar.xz"
HELLO_INIT="helloInit"
INIT="init"
BUSYBOX="busybox"
BUSYCONFIG="busyboxconfig/.config"
BUSYCONFIGFILE="busyboxconfig"
BUSYDIR="busybox-1.24.1"
MAIN_DIR_PATH=$(pwd)
STDOUTLOG="stdout_2"
ERRORLOG="errorout_2"
UDHCPDIR="script/simple.script"
CROSS_COMPILE="/group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-"
PATCH_PATH="https://burns.in.htwg-konstanz.de/labworks-SYSO_WS1516/syso_ws1516_skeleton/blob/master/V3/linux-smsc95xx_allow_mac_setting.patch"
DTB_NAME="bcm2835-rpi-b.dtb"
V_EXPRESS_NAME="vexpress-v2p-ca9.dtb"
RPI_PATH="/srv/tftp/rpi/2"
DTB_PATH="arch/arm/boot/dts"
IMAGE_FILE="arch/arm/boot/zImage"
TFTPBOOT="tftpboot.scr"
PASSWD="passwd"
#--------Linux Kernel dowload if not exist and unpack---------------
linux_kernel(){
	echo "##############################################" 
	echo "#           Starting linux Configuration     #" 
	echo "##############################################" 
	go_to_embedded
	#Dowload kernel or not
	if [ -d "$KERNELDIR" ]; then
		echo "linux-kernel already downloaded!"
	else
		echo "Download linux-kernel and unpack!"
		echo "##############################################" 
		echo "#           Dowloading linux Kernel...       #" 
		echo "##############################################" 
		wget -nv https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.2.3.tar.xz
		echo "##############################################" 
		echo "#           Unpacking linux Kernel...        #" 
		echo "##############################################"  
		tar xf $ZIP_FILE
		#remove zip 
		rm -rf $ZIP_FILE
		echo "##############################################"
		echo "#          Linux kernel unpacked             #"
		echo "##############################################"
		chmod 755 *
		#Patch Kernel
		add_patch
	fi
	
	reset_path
}
add_patch(){
echo "################################################"
echo "#                Patch Kernel                  #"
echo "################################################"
go_to_embedded
cp linux-smsc95xx_allow_mac_setting.patch $KERNELDIR
cd $KERNELDIR
patch -p1 <../linux-smsc95xx_allow_mac_setting.patch
}

#-----------------Create Userland--------------------------------- 
make_userland(){
	echo "##############################################"
	echo "#           Creating Userland                #"
	echo "##############################################"
	#go to subdirectory
	go_to_embedded
	#after delete create new userland or only create userland
	if [ -d "$USERLANDDIR" ]; then
		rm -rf "$USERLANDDIR"
		echo "userland has been removed" 
	fi
	echo "create userland directory" 
	mkdir $USERLANDDIR
	cd $USERLANDDIR
	mkdir -p -v $USERLANDCONFIG
	cd ..
	chmod 755 *
	reset_path
	echo "##############################################"
	echo "#           Created Userland                 #" 
	echo "##############################################"

}
#------------------------- c configurator -----------------------------
c_generator(){
	echo "##############################################"
	echo "#           Compiling c program           #"
	echo "##############################################"	
	go_to_embedded
	chmod 755 *
	#compiler program
	#binary init initialization
	echo "make binary init"  
	make 
	rm $HELLO_INIT.o
	echo "##############################################"
	echo "#           Compiled c program               #"
	echo "##############################################"
}


#-------------------------busybox from web and self configurated----------------------
busybox_generator_from_scratch(){
	go_to_embedded
	#Dowload Busybox raw
	if [ ! -d busybox-1.24.1 ]; then
		wget -v http://busybox.net/downloads/busybox-1.24.1.tar.bz2
	echo "##############################################" 
	echo "#           Unpacking linux Busybox...       #" 
	echo "##############################################"
		tar xf busybox-1.24.1.tar.bz2
		#remove zip 
		rm -rf busybox-1.24.1.tar.bz2
	echo "##############################################"
	echo "#          Busybox unpacked                  #"
	echo "##############################################"
	fi	
}

moving_busybox_config(){
	echo "##############################################"
	echo "#           Moving Busybox .config            #"
	echo "##############################################"
	go_to_embedded
	# move .config from busyboxconfig to busybox-folder
	cp $BUSYCONFIG $BUSYDIR
	echo "##############################################"
	echo "#          Moved .config to Busybox          #"
	echo "##############################################"
	


}
compile_busybox(){
	echo "##############################################"
	echo "#           compile busybox                  #"
	echo "##############################################"	
	go_to_embedded
	cd $BUSYDIR
	
	make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE
	cd ..
	#move compiled busybox one folder up where the other one used to be
	cp $BUSYDIR/busybox busybox
	echo "##############################################"
	echo "#            Busybox compiled                #"
	echo "##############################################"	
	
}



#------------------ moving files to initramfs---------------------------
moving_datas_to_initramfs(){
	echo "##############################################"
	echo "#        Moving files to initramfs           #"
	echo "##############################################"
	go_to_userland
	chmod +x ../init
	chmod 755 *
	cp ../$HELLO_INIT ../$USERLANDDIR/bin
	cp ../init ../$USERLANDDIR/sbin/init
	chmod 777 ../$USERLANDDIR/sbin/init
	cp ../$BUSYBOX bin
	cp ../$UDHCPDIR ../$USERLANDDIR/etc
	cp ../$PASSWD ../$USERLANDDIR/etc
	reset_path
	echo "##############################################"
	echo "#        finished files to initramfs         #"
	echo "##############################################"

}
#------------------ zip generator --------------------------------------
packing_user_land(){
	go_to_userland
	find . | cpio -o -H newc | gzip > ../initramfs_data.cpio.gz
	cd ..
	rm -rf $USERLANDDIR
	reset_path
}

move_config(){
	echo "##############################################"
	echo "#           Moving Kernel config             #"
	echo "##############################################"
	#Dowload kernel or not
	reset_path
	#new: go to embedded
	cd $SUB_DIRECTORY
	# move .config from config to linux-kernel
	cp $CONFIGFILE $KERNELDIR
	echo "##############################################"
	echo "#           Moved Kernel .config             #"
	echo "##############################################"
	reset_path
}
compile_kernel(){
	reset_path
	echo "##############################################"
	echo "#           compile kernel                   #"
	echo "##############################################"
	#new version!!!
	cd $SUB_DIRECTORY 
	#remove unsed data
	rm -rf $HELLO_INIT
	rm -rf $BUSYBOX
	cd $KERNELDIR
	ls
	make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE -j 4 
	echo "##############################################"
	echo "#            kernel compiled                 #"
	echo "##############################################"



}
start_qemu(){
	echo "##############################################"
	echo "#           Starting QEMU                    #"
	echo "##############################################"
	go_to_embedded
	cd $KERNELDIR
	QEMU_AUDIO_DRV=none qemu-system-arm -M vexpress-a9 -append "console=ttyAMA0 init=/sbin/init" -net nic,vlan=0,macaddr=00:00:00:00:10:01 -net vde,sock=/tmp/vde2-tap0.ctl  -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -m 20 -nographic -initrd ../initramfs_data.cpio.gz 
}

make_menu_config(){
	reset_path
	cd $SUB_DIRECTORY
	cd $KERNELDIR
	make ARCH=arm menuconfig
	reset_path
}
make_menu_config_busybox(){
	reset_path
	cd $SUB_DIRECTORY
	cd $BUSYDIR
	ls
	make ARCH=arm menuconfig
	reset_path
}
make_DTB(){
	reset_path
	cd $SUB_DIRECTORY
	cd $KERNELDIR
	make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE ${DTB_NAME}
	reset_path	
}
make_V_EXPRESS(){
	reset_path
	cd $SUB_DIRECTORY
	cd $KERNELDIR
	make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE ${V_EXPRESS_NAME}
	reset_path	
}
move_to_rpi(){
	echo "##############################################"
	echo "#                Moving files to RPI...      #"
	echo "##############################################"
	move_dtb
	move_kernel_image
	move_ramfs
	move_tftboot
	echo "##############################################"
	echo "#                Moved files to RPI...      #"
	echo "##############################################"
	
}
move_dtb(){
	reset_path
	cd $SUB_DIRECTORY
	cd $KERNELDIR
	cd $DTB_PATH
	cp $DTB_NAME $RPI_PATH
	reset_path
}
move_kernel_image(){
	reset_path
	cd $SUB_DIRECTORY
	cd $KERNELDIR
	cp $IMAGE_FILE $RPI_PATH
	reset_path
}
move_ramfs(){
	go_to_embedded
	mkimage -A arm -O linux -T ramdisk -C none -n "initramfs_data.cpio.gz" -d initramfs_data.cpio.gz rootfs.cpio.uboot
	ls
	cp rootfs.cpio.uboot $RPI_PATH
}
move_tftboot(){
	go_to_embedded
	mkimage -A arm -O linux -T script -C none -d tftpboot.scr.txt tftpboot.scr
	cp $TFTPBOOT $RPI_PATH
}

delete_data(){
	echo "##############################################"
	echo "#                Deleting files...           #"
	echo "##############################################"
	reset_path
	cd $SUB_DIRECTORY
	rm -rf $KERNELDIR
	rm -rf initramfs_data.cpio.gz
	rm -rf $BUSYDIR
	rm -rf rootfs.cpio.uboot
	cd ..
	rm -rf $ERRORLOG.log
	rm -rf $STDOUTLOG.log
	echo "##############################################"
	echo "#                deleted files!              #"
	echo "##############################################"
	reset_path
}

#-----------------reset file path----------------------------------------
reset_path(){
cd 
cd $MAIN_DIR_PATH

}
go_to_userland(){
	reset_path
	cd $SUB_DIRECTORY 
	cd $USERLANDDIR

}
go_to_embedded(){
	reset_path
	cd $SUB_DIRECTORY 
}



#---------Here starts Getopt and check if no argument------------------
# check if call with parameter
if [ -z "$1" ]; then
	echo "Making all..."
	reset_path
	#Invoke Linux Kernel
	linux_kernel
	#Invoke UserLand
	make_userland
	c_generator
	echo "##############################################"
	echo "#           Starting Busybox                 #"
	echo "##############################################"	
	#dowloadbusybox
	busybox_generator_from_scratch
	#movingconfig
	moving_busybox_config
	# compile busybox
	compile_busybox
	echo "##############################################"
	echo "#           Finished Busybox                 #"
	echo "##############################################"
	#moving datas to user land
	moving_datas_to_initramfs
	#zip datei
	packing_user_land
	#Invoke config
	move_config
	compile_kernel
	#make dtbs
	#make_DTB
	#make_V_EXPRESS
	#Invoke Start Linux QEMU
	start_qemu	

fi
move_config_from_kernel(){
	echo "##############################################"
	echo "#  Moving .config from kernel to config      #"
	echo "##############################################"
	#Dowload kernel or not
	go_to_embedded
	# move .config from config to linux-kernel
	cp $KERNELDIR/.config $CONFIGFILE
	echo "##############################################"
	echo "#           Moved Kernel .config             #"
	echo "##############################################"
	reset_path
}
move_config_from_busybox(){
	echo "##############################################"
	echo "#Moving .config from busybox to busyboxconfig#"
	echo "##############################################"
	#Dowload kernel or not
	go_to_embedded
	# move .config from config to linux-kernel
	cp $BUSYDIR/.config $BUSYCONFIGFILE
	echo "##############################################"
	echo "#           Moved Busybox .config            #"
	echo "##############################################"
	reset_path

}
print_help(){
	echo "##############################################"
	echo "#                WELCOME                     #"
	echo "##############################################"
	echo " sh V1.sh [Options] [Parameters]"
	echo " -l\tLinux Kernel configuration" 
	echo " -u\tUserLand configuration"
	echo " -c\tcopy .config file from ../config to linux kernel"
	echo " -m\tmake menuconfig"
	echo " -d\tdelete and clean unneed data"
	echo " --dn\tDownload Quellen"
	echo " --mb\tOpen BusyBox Config"
	echo " --pa\tPatchen von Quellen"
	echo " --cp\tKopieren Ihrer GitLab Sourcen"
	echo " --co\tCompilieren der Quellen"
	echo " --qe\tQemu starten + Fenster mit Terminal zur seriellen Schnittstelle"
	echo " --mvk\tMove from linux-4.2.3 .config to config file"
	echo " --mvb\tMove from busybox-1.24.1 .config to busyboxconfig file"
	echo " --dtb\tMake DTB Datei"
	echo " --vex\tMake Vexpress Datei"
	echo " --mvrpi\tMove Files to RPI"
}

# Execute getopt
ARGS=$(getopt -o hlucsqmd -l "dn,pa,cp,co,qe,mb,mvk,mvb,dtb,vex,mvrpi" -n "$0" -- "$@");

#Bad arguments
if [ $? -ne 0 ];
then
  exit 1
fi

eval set -- "$ARGS";

while true; do
  case "$1" in

	-h)
		shift
		print_help
		
	;;
	-l)
		shift
		echo "Kernel Start"
		#Invoke Kernel
		linux_kernel;
	;;
	-u)
		shift
		echo "Preparing Userland...."
		#Invoke UserLand
		make_userland
		c_generator
		echo "##############################################"
		echo "#           Starting Busybox                 #"
		echo "##############################################"	
		#dowloadbusybox
		busybox_generator_from_scratch
		#movingconfig
		moving_busybox_config
		# compile busybox
		compile_busybox
		echo "##############################################"
		echo "#           Finished Busybox                 #"
		echo "##############################################"
		
		#moving datas to user land
		moving_datas_to_initramfs
		#zip datei
		packing_user_land
	;;
	-c)
		shift
		echo "Move Config to Linux Kernel...";
		#Invoke config
		move_config
		;;

	-m)
		shift
		echo "Make menu config Linux Kernel"
		#make menu config
		make_menu_config;
	;;
	-d)
		shift
		echo "deleting files..."
		cd 
		#deleting files
		delete_data
	;;
	--dn)
	shift
		echo "Download Quellen"
		linux_kernel
		busybox_generator_from_scratch
	;;
	--pa)
	shift
		echo "Patchen von Quellen"
			#add patch
			add_patch
			#Linux 
			move_config
			#BusyBox
			moving_busybox_config
			
	;;
	--mvk)
	shift
		echo "Move from kernel .config to config"
		move_config_from_kernel

	;;
	--mvb)
	shift
		echo "Move from busybox .config to config"
		move_config_from_busybox

	;;
	--cp)
	shift
		echo "Kopieren Ihrer GitLab Sourcen"
		echo "git CheckOut!"
		git checkout HEAD
	;;
	--co)
	shift
		echo "Compilieren der Quellen"
			#Linux 
			move_config
			compile_kernel
			#BusyBox compilierung
			#movingconfig
			moving_busybox_config
			# compile busybox
			compile_busybox
		
	;;
	--dtb)
	shift
	echo "make DTB"
	make_DTB
	;;
	
	--vex)
	shift
	echo "make vexpress"
	make_V_EXPRESS
	;;
	
	
	--qe)
	shift
		echo "Qemu starten + Fenster mit Terminal zur seriellen Schnittstelle"
		start_qemu
	;;
	--mvrpi)
	shift
		echo "Move Files to rpi"
		move_to_rpi
	;;
	--mb)
		shift
		echo "open busy box menu config"
		#make
		make_menu_config_busybox
		;;
	--)
	
	  shift;
	  break;
	;;
esac
done
