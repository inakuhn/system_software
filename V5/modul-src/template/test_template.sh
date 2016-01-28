#!/bin/sh
MODULE=template
KO=/root/${MODULE}/${MODULE}.ko


echo "##############################################"
echo "#                Template                    #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}

echo "##################Insmod#######################"
insmod ${KO}

echo "##################Lsmod########################"
lsmod ${MODULE}

echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}

echo "##################Rmmod########################"
rmmod ${MODULE}

echo "##################Dmesg########################"
dmesg -c
echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}
