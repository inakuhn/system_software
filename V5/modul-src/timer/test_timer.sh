#!/bin/sh
MODULE=timer
KO=/root/${MODULE}/${MODULE}.ko

PRINTK=/proc/sys/kernel/printk
BACKUP=$(cat ${PRINTK})
echo "3 4 1 3" > ${PRINTK} # Disable printk output

echo "##############################################"
echo "#                Template                    #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}

echo "##################Insmod#######################"
insmod ${KO}

echo "##################Lsmod########################"
lsmod ${MODULE}

echo "##################Sleep 10s ######################"
sleep 10

echo "7 4 1 7" > ${PRINTK} # Disable printk output

echo "##################Rmmod########################"
rmmod ${MODULE}

echo "##################Dmesg########################"
dmesg -c
