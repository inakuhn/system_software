#!/bin/sh
MODULE=openclose
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
printf "\n##################Acces -O ######################\n"
  $ACCESS -o
printf "\n#################Acces -O #######################\n"
  $ACCESS -o
printf "\n##############Acces -O -T 5 #####################\n"
  $ACCESS -o -t 5 
fi
printf "\n##################Rmmod###########################\n"
rmmod ${MODULE}
echo "##################Dmesg###############################"
dmesg -c



