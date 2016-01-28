#!/bin/sh
MODULE=lock
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

echo "##############################################"
echo "#                Lock Test                   #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}

echo "##################Insmod#######################"
insmod ${KO}

echo "##################Lsmod########################"
lsmod ${MODULE}

echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}


echo "##################Acess -l  ######################"
if [ -f "$ACCESS" ]; then
	$ACCESS -l
fi
echo "##################Rmmod########################"
rmmod ${MODULE}
echo "##################Dmesg########################"
dmesg -c
