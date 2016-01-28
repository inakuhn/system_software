#!/bin/sh
MODULE=myzero
KO=/root/${MODULE}/${MODULE}.ko
ACCESS=/bin/access

echo "#################################################"
echo "#                Template                       #"
echo "#################################################"
echo "#################Information#####################"
modinfo ${KO}

dmesg -c > /dev/null

echo "##################Insmod#########################"
insmod ${KO}

echo "##################Lsmod##########################"
lsmod ${MODULE}

echo "##################Devices########################"
cat /proc/devices | grep -i ${MODULE}
if [ -f "$ACCESS" ]; then

echo "\##################Acces -R ######################"
  $ACCESS -r
  
echo "###############Acces -R -D 5 ####################"
  $ACCESS -r -d 5 
fi

printf "\n##################Rmmod##########################\n"
rmmod ${MODULE}

echo "##################Dmesg##########################"
dmesg -c

