#!/bin/sh
#sigoetti&rabertol
#v3_2 shell skript buildroot
#Varible
#----------------------------embedded path--------------------------
SUB_DIRECTORY="embedded"
MAIN_DIR_PATH=$(pwd)
UDHCPDIR="script/simple.script"
CROSS_COMPILE="/group/SYSO_WS1516/armv6j-rpi-linux-gnueabihf/bin/armv6j-rpi-linux-gnueabihf-"
PATCH_PATH="https://burns.in.htwg-konstanz.de/labworks-SYSO_WS1516/syso_ws1516_skeleton/blob/master/V3/linux-smsc95xx_allow_mac_setting.patch"
DTB_NAME="bcm2835-rpi-b.dtb"
V_EXPRESS_NAME="vexpress-v2p-ca9.dtb"
RPI_PATH="/srv/tftp/rpi/2"
DTB_PATH="arch/arm/boot/dts"
IMAGE_FILE="arch/arm/boot/zImage"
IMAGE_FILE_NAME="zImage"
TFTPBOOT="tftpboot.scr"
BUILDROOTCONFIGDIR="buildrootconfig"
BUILDROOTCONFIG="buildroot/.config"
BUILDROOTIMG="buildroot/output/images"
BUILDROOT="buildroot"
BUILDROOTLINUX="buildroot/output/build/linux-4.2.3/.config"
BUILDROOTBUSYBOX="buildroot/output/build/busybox-1.24.1/.config"
CONFIGFILE="config/.config"
BUSYCONFIG="busyboxconfig/.config"

#-------------------Buildroot Download--------------------------
get_buildroot(){
go_to_embedded
echo "###################################################"
echo "#          Get Buildroot                          #"
echo "###################################################" 
if [ -d "$BUILDROOT" ]; then
		echo "buildroot already downloaded!"
		move_config_into_buildroot
	else
echo "###################################################"
echo "#          Dowloading Buildroot                   #"
echo "###################################################" 
		git clone  "git://git.buildroot.net/buildroot"
		cd $BUILDROOT
		git checkout 1daa4c95a4bb93621292dd5c9d24285fcddb4026
		move_config_into_buildroot
	fi   
	
}

make_buildroot_config(){
echo "###################################################"
echo "#           Buildroot Makemeunu config            #"
echo "###################################################"
	go_to_embedded
	cd $BUILDROOT
	make menuconfig
	reset_path
}


save_buildroot_config(){
echo "###################################################"
echo "#   save_buildroot_config  					    #"
echo "###################################################"
	go_to_embedded
	cp $BUILDROOTCONFIG $BUILDROOTCONFIGDIR
echo "###################################################"
echo "#   buildroot config saved   					    #"
echo "###################################################"
}
move_config_into_buildroot(){
echo "###################################################"
echo "#   moving buildrootconfiguration  into buildroot #"
echo "###################################################"
	go_to_embedded
	cp $BUILDROOTCONFIGDIR/.config $BUILDROOT
echo "###################################################"
echo "#   moved buildrootconfiguration  into buildroot  #"
echo "###################################################"

}
compile_buildroot(){
	reset_path
	echo "##############################################"
	echo "#           compile buildroot                #"
	echo "##############################################"
	go_to_build_root
	make source #das sollte den kernel selbst holen können....
	make
	echo "##############################################"
	echo "#            buildroot compiled              #"
	echo "##############################################"
}


start_qemu(){
	echo "##############################################"
	echo "#           Starting QEMU                    #"
	echo "##############################################"
	go_to_embedded
	cd $KERNELDIR
	QEMU_AUDIO_DRV=none qemu-system-arm -M vexpress-a9 -append "console=ttyAMA0" -net nic,vlan=0,macaddr=00:00:00:00:10:00 -net vde,sock=/tmp/vde2-tap0.ctl  -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -m 10 -nographic -initrd ../initramfs_data.cpio.gz 
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
	go_to_buildroot_images
	ls
	cp $DTB_NAME $RPI_PATH
	reset_path
}
move_kernel_image(){
	go_to_buildroot_images
	ls
	cp $IMAGE_FILE_NAME $RPI_PATH
	reset_path
}
move_ramfs(){
	go_to_buildroot_images
	mkimage -A arm -O linux -T ramdisk -C none -n "rootfs.cpio" -d rootfs.cpio rootfs.cpio.uboot
	cp rootfs.cpio.uboot $RPI_PATH
}
move_tftboot(){
	go_to_embedded
	mkimage -A arm -O linux -T script -C none -d tftpboot.scr.txt tftpboot.scr
	cp $TFTPBOOT $RPI_PATH
}
start_qemu(){
	echo "##############################################"
	echo "#           Starting QEMU                    #"
	echo "##############################################"
	go_to_buildroot_images
	QEMU_AUDIO_DRV=none qemu-system-arm -M vexpress-a9 -append "console=ttyAMA0" -net nic,vlan=0,macaddr=00:00:00:00:10:00 -net vde,sock=/tmp/vde2-tap0.ctl  -kernel zImage -dtb vexpress-v2p-ca9.dtb -m 24 -nographic -initrd rootfs.cpio
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
	rm -rf $BUILDROOT
	rm -rf linux-4.2.3
	rm -rf tftpboot.scr
	rm -rf rootfs.cpio.uboot
	cd ..
	rm -rf $ERRORLOG.log
	rm -rf $STDOUTLOG.log
	echo "##############################################"
	echo "#                deleted files!              #"
	echo "##############################################"
	reset_path
}
#------make menu kernel and busybox ----------#
make_menu_kernel(){
	echo "##############################################"
	echo "#           Linux Menuconfig                 #"
	echo "##############################################"
	go_to_build_root
	make linux-menuconfig
}
make_menu_busybox(){
	echo "##############################################"
	echo "#           Make Menu Busybox                #"
	echo "##############################################"
	go_to_build_root
	make busybox-menuconfig
}
#------move menu kernel and busybox ----------#
move_linux_config(){
	echo "##############################################"
	echo "#           move Linux .config               #"
	echo "##############################################"
	go_to_embedded
	cp $BUILDROOTLINUX $CONFIGFILE
	
	
}
move_busybox_config(){
	echo "##############################################"
	echo "#           move Busybox .config             #"
	echo "##############################################"
	go_to_embedded
	cp $BUILDROOTBUSYBOX $BUSYCONFIG
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
go_to_build_root(){
	reset_path
	cd $SUB_DIRECTORY 
	cd $BUILDROOT
}
go_to_buildroot_images(){
	reset_path
	cd $SUB_DIRECTORY
	cd $BUILDROOTIMG

}
delete_tar(){
	echo "##############################################"
	echo "#               deleting tars                #"
	echo "##############################################"
	go_to_build_root
	cd output/build
	rm -rf mynull-1.0.0
	rm -rf myzero-1.0.0
	rm -rf template-1.0.0
	rm -rf openclose-1.0.0
	rm -rf tasklet-1.0.0
	rm -rf timer-1.0.0
	rm -rf kthread-1.0.0
	rm -rf wq-1.0.0
	rm -rf lock-1.0.0
	rm -rf open_once-1.0.0
	rm -rf buf-1.0.0
	go_to_build_root
echo "##############################################"
echo "#                tars  removed               #"
echo "##############################################"

}
delete_all(){
	echo "##############################################"
	echo "#               deleting tars                #"
	echo "##############################################"
	go_to_build_root
	cd output/build
	rm -rf mynull-1.0.0
	rm -rf myzero-1.0.0
	rm -rf template-1.0.0
	rm -rf openclose-1.0.0
	rm -rf tasklet-1.0.0
	rm -rf timer-1.0.0
	rm -rf kthread-1.0.0
	rm -rf wq-1.0.0
	rm -rf lock-1.0.0
	rm -rf open_one-1.0.0
	rm -rf buf-1.0.0
	go_to_build_root
	cd dl
	rm -rf mynull-1.0.0.tar.gz
	rm -rf myzero-1.0.0.tar.gz
	rm -rf template-1.0.0.tar.gz
	rm -rf openclose-1.0.0.tar.gz
	rm -rf tasklet-1.0.0.tar.gz
	rm -rf timer-1.0.0.tar.gz
	rm -rf kthread-1.0.0.tar.gz
	rm -rf wq-1.0.0.tar.gz
	rm -rf lock-1.0.0.tar.gz
	rm -rf open_once-1.0.0.tar.gz
	rm -rf buf-1.0.0.tar.gz
echo "##############################################"
echo "#                tars  removed               #"
echo "##############################################"

}


#---------Here starts Getopt and check if no argument------------------
# check if call with parameter
if [ -z "$1" ]; then
	echo "Download Quellen"
	delete_tar
	get_buildroot
	compile_buildroot
	start_qemu
fi


print_help(){
	echo "##############################################"
	echo "#                WELCOME                     #"
	echo "##############################################"
	echo " sh V1.sh [Options] [Parameters]"
	echo " -h\tHelp"
	echo " -d\tdelete and clean unneed data"
	echo " --qe\tStart QEMU"	
	echo " --run\tDownload Quellen, Patchen von Quellen"
	echo " --mvrpi\tMove Files to RPI"
	echo " --br\tDownload Buildroot"
	echo " --mbr\tMake Buildroot menuconfig"
	echo " --ml\tMake linux menuconfig"
	echo " --mbusy\tMake Busybox menuconfig"
	echo " --mvbr\tSaving buildroot config"
	echo " --mvl\tMove linux .config to config"
	echo " --mvbusy\tMove Busybox .config to busyboxconfig"
	echo " --makebr\tCompile Buildroot"
	echo " --dtar\tDelete target"
	
	
	
}

# Execute getopt
ARGS=$(getopt -o hd -l "run,mvrpi,br,mbr,mvbr,makebr,qe,ml,mbusy,mvl,mvbusy,dtar" -n "$0" -- "$@");

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

	-d)
		shift
		echo "deleting files..."
		cd 
		delete_data
	;;
	--ml)
	shift
	make_menu_kernel
	;;

	--run)
	shift
		echo "Download Quellen"
		get_buildroot
			
	;;

	--mbusy)
	shift
		make_menu_busybox
	;;
	--mvbusy)
	shift
		move_busybox_config
	;;
	--mvl)
	shift
		move_linux_config
	;;
	--br)
	shift
	echo "get buildroot"
	get_buildroot
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
	--mbr)
		shift
		echo "make menu config buildroot"
		#make
		make_buildroot_config
		;;
	--mvbr)
		shift
		echo "saving buildroot config"
		#make
		save_buildroot_config
		;;
	--makebr)
		shift
		echo "compiling buildroot...."
		#make
		compile_buildroot
		;;
	--dtar)
		shift
		delete_all
		;;
	--)
	
	  shift;
	  break;
	;;
esac
done
