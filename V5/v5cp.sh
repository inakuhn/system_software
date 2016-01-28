#!/bin/sh
#sigoetti&rabertol
#v3_2 shell skript buildroot
#Varible
MODULSRC="modul-src"
VER="-1.0.0"
END=".tar.gz"
V3BUILDROOTDL="../../V3/embedded/buildroot/dl"
DIR_PATH=$(pwd)

loop_loo(){
	cd $MODULSRC
	for d in * ; do
		if [ -d "$d" ]; then
		# Control will enter here if $DIRECTORY exists.
			tar -zcvf $d$VER$END $d
			cp $d$VER$END $V3BUILDROOTDL
			rm -rf $d$VER$END
		
		fi
	done		
}
link_modul_pacakege(){
	cd $DIR_PATH
	ls
	cd ..
	cd V3/embedded/buildroot/package
	
	rm -rf syso
	ln -s ../../../../V5/modul-package/ ./syso
}
copy_access()
{
	goto_acess
	make clean
	make
	cd ..
	cd ..
	cd V3/embedded/overlay
	cp ../../../V5/access/access bin
	goto_acess
	make clean
	echo "##############################################"
	echo "#                Done copy acess             #"
	echo "##############################################"
	
}
goto_acess()
{
	echo $DIR_PATH
	cd $DIR_PATH
	cd access

}

#---------Here starts Getopt and check if no argument------------------
# check if call with parameter
if [ -z "$1" ]; then
	echo "DL"

	loop_loo
fi


print_help(){
	echo "##############################################"
	echo "#                WELCOME                     #"
	echo "##############################################"
	echo " sh V1.sh [Options] [Parameters]"
	echo " -h\tHelp"
	echo " -c\tCopy to dl"
	echo " -v\tVerlinken syso"
	echo " -a\tMake and cops acess..."	
}

# Execute getopt
ARGS=$(getopt -o hcva -l "" -n "$0" -- "$@");

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

	-c)
		shift
	echo "##############################################"
	echo "#                Copy Files                  #"
	echo "##############################################"
		cd 
		loop_loo
	;;

	-v)
	shift
	echo "##############################################"
	echo "#                Verlinken...                #"
	echo "##############################################"
		cd 
		link_modul_pacakege
	;;
	-a)
	shift
	echo "##############################################"
	echo "#               Accesss...                   #"
	echo "##############################################"
		copy_access
	;;
	--)
	  shift;
	  break;
	;;
esac
done

