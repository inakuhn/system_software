#!/bin/sh
#sigoetti&rabertol
#v1 first shell skript kernel confuguration
#Varible
#embedded path
DIRECTORY="embedded"
KERNELDIR="linux-4.2.3"
USERLANDDIR="userland"
USERLANDCONFIG="dev sbin bin usr/bin etc var tmp lib etc var proc sys"
CONFIGFILE="config/.config"
ZIP="linux-4.2.3.tar.xz"
SUB="sub"
INIT="helloinit"
BUSYBOX="busybox"
# http://stackoverflow.com/questions/18460186/writing-outputs-to-log-file-and-console
DIR_PATH=$(pwd)
STDOUTLOG="${DIR_PATH}/stdout_1.log"
ERRORLOG="${DIR_PATH}/serrorout_1.log"
#Linux Kernel dowload if not exist and unpack
linux_kernel(){
echo "##############################################" 
echo "#           Starting linux Configuration     #" 
echo "##############################################" 
cd $DIRECTORY
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
	tar xf $ZIP
	#remove zip 
	rm -rf $ZIP
	echo "##############################################"
	echo "#          Linux kernel unpacked             #"
	echo "##############################################"
	
fi

}

#Create Userland 
make_userland(){
echo "##############################################"
echo "#           Starting Userland                #"
echo "##############################################"
#check if in embedded
if [ -d "$DIRECTORY" ]; then
	cd $DIRECTORY
fi
#after delete create new userland or only create userland
if [ -d "$USERLANDDIR" ]; then
	rm -rf "$USERLANDDIR"
	echo "userland has been removed" 
fi
#Dowload Busybox
if [ ! -f busybox ]; then
    wget -nv https://burns.in.htwg-konstanz.de/labworks-SYSO_WS1516/syso_ws1516_skeleton/raw/master/V1/busybox
fi
#compiler program
#binary init initialization
echo "make binary init"  
gcc -m32 -static -o $INIT $INIT.c

echo "create userland directory" 
mkdir $USERLANDDIR
cd $USERLANDDIR
mkdir -p -v $USERLANDCONFIG
cd ..
chmod 755 *
cd $USERLANDDIR
cp ../$INIT ../$USERLANDDIR/bin
cp ../init ../$USERLANDDIR/sbin/init
chmod 777 ../$USERLANDDIR/sbin/init
cp ../$BUSYBOX bin
#zip datei
find . | cpio -o -H newc | gzip > ../initramfs_data.cpio.gz
cd ..
rm -rf $USERLANDDIR

}

move_config(){
echo "##############################################"
echo "#           Moving config                    #"
echo "##############################################"
#Dowload kernel or not

if [ -d "$KERNELDIR" ]; then
	echo "already rigth directory"
else
	if [ -d "$DIRECTORY" ]; then
		cd $DIRECTORY	
		# echo moving to embeeded......"
	else
		# echo "Changing directory......"
	cd ..
	fi
fi


# move .config from config to lunux-kernel
cp $CONFIGFILE $KERNELDIR
echo "##############################################"
echo "#           Finish configuration Set!!       #"
echo "##############################################"
}
start_kernel(){
echo "##############################################"
echo "#           compile kernel                   #"
echo "##############################################"
if [ -d "$KERNELDIR" ]; then
	echo "already rigth directory"
else 
	cd $DIRECTORY 
fi

#remove unsed data
rm -rf $INIT
rm -rf $BUSYBOX
cd $KERNELDIR

make ARCH=i386 CC="ccache gcc" -j 4 
echo "##############################################"
echo "#           Starting QEMU                    #"
echo "##############################################"
qemu-system-i386 -kernel arch/i386/boot/bzImage -m 20 -nographic -append 'console=ttyS0'  -initrd ../initramfs_data.cpio.gz
}

make_menu_config(){
cd $DIRECTORY
cd $KERNELDIR
make ARCH=i386 menuconfig

}

delete_data(){
echo "##############################################"
echo "#                Deleting files...           #"
echo "##############################################"
cd Documents/syso_ws1516_10/V1/$DIRECTORY
rm -rf $KERNELDIR
rm -rf initramfs_data.cpio.gz
cd ..
rm -rf errorout_1.log
rm -rf stdout_1.log
echo "##############################################"
echo "#                deleted files!              #"
echo "##############################################"

}
#---------Here starts Getopt and check if no argument------------------
# check if call with parameter
if [ -z "$1" ]; then
	echo "Making all..."
	#Invoke Linux Kernel
	linux_kernel
	#Invoke UserLand
	make_userland
	#Invoke config
	move_config
	#Invoke Start Linux QEMU
	start_kernel	

fi

# getopts 
while getopts hlucsqmd flag; do
	case $flag in
		h)
			echo "##############################################"
			echo "#                WELCOME                     #"
			echo "##############################################"
			printf "  sh V1.sh [Options] [Parameters]\n -l Linux Kernel configuration\n -u UserLand configuration\n -c copy .config file from ../config to linux kernel\n -s start qemu config\n -m make menuconfig\n -q start qemu\n-d delete and clean unneed data";
		;;
		l)
			echo "Kernel Start"
			#Invoke Kernel
			linux_kernel;
		;;
		u)
			echo "Preparing Userland...."
			#invoke UserLand
			make_userland;
		;;
		c)
			echo "Move Config to Linux Kernel...";
			#Invoke config
			move_config
		;;
		s)
			echo "Starting Kernel"
			#Start Kernel
			start_kernel;
		;;
		m)
			echo "Make menu config"
			#make menu config
			make_menu_config;
		;;
		q)
			echo "starting QEMU"
			#start qemu
			#TODO
		;;
		d)
			echo "deleting files..."
			cd 
			#deleting files
			delete_data
		;;
		?)
			exit;
		;;
  esac
done
shift $(( OPTIND - 1 ));

