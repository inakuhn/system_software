#!/bin/sh
MODULE=buf
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

echo "##############################################"
echo "#                Buf                   #"
echo "##############################################"
echo "#################Information##################"
modinfo ${KO}
dmesg -c > /dev/null


echo "##################Insmod#######################"
insmod ${KO}

echo "##################Lsmod########################"
lsmod ${MODULE}

echo "##################Devices######################"
cat /proc/devices | grep -i ${MODULE}

if [ -f "$ACCESS" ]; then

echo "\n##################Acces -B ######################\n"
  $ACCESS -b
    
fi

echo "\n##################Rmmod########################"
rmmod ${MODULE}

echo "\n##################Dmesg########################"
dmesg -c
