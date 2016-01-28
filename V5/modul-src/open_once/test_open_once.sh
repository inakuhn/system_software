#!/bin/sh
MODULE=open_once
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
	$ACCESS -m
fi
echo "##################Rmmod########################"
rmmod ${MODULE}
echo "##################Dmesg########################"
dmesg -c
