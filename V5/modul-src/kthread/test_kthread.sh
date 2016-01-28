#!/bin/sh
MODULE=kthread
KO=/root/${MODULE}/${MODULE}.ko

echo "##############################################"
echo "#                Template                    #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}

echo "##################Insmod#######################"
insmod ${KO}
sleep 10
echo "##################Lsmod########################"
lsmod ${MODULE}


echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}


echo "##################Rmmod########################"
rmmod ${MODULE}

echo "##################Dmesg########################"
dmesg -c
